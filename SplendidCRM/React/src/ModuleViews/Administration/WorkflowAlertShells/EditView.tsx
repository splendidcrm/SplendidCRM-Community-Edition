/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
import React from 'react';
import qs from 'query-string';
import { XMLParser, XMLBuilder }                    from 'fast-xml-parser'                              ;
import { RouteComponentProps }                      from '../Router5'                                   ;
import { observer }                                 from 'mobx-react'                                   ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'               ;
// 2. Store and Types. 
import { EditComponent }                            from '../../../types/EditComponent'                 ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                         ;
import L10n                                         from '../../../scripts/L10n'                        ;
import Security                                     from '../../../scripts/Security'                    ;
import Credentials                                  from '../../../scripts/Credentials'                 ;
import SplendidCache                                from '../../../scripts/SplendidCache'               ;
import SplendidDynamic_EditView                     from '../../../scripts/SplendidDynamic_EditView'    ;
import { Crm_Modules }                              from '../../../scripts/Crm'                         ;
import { Admin_GetReactState }                      from '../../../scripts/Application'                 ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                       ;
import { EditView_LoadItem, EditView_LoadLayout, EditView_HideField }   from '../../../scripts/EditView';
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'             ;
// 4. Components and Views. 
import ErrorComponent                               from '../../../components/ErrorComponent'           ;
import DumpSQL                                      from '../../../components/DumpSQL'                  ;
import DynamicButtons                               from '../../../components/DynamicButtons'           ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';
import XomlBuilder                                  from './XomlUserBuilder'                            ;

interface IAdminEditViewProps extends RouteComponentProps<any>
{
	MODULE_NAME       : string;
	ID                : string;
	LAYOUT_NAME?      : string;
	callback?         : any;
	rowDefaultSearch? : any;
	onLayoutLoaded?   : any;
	onSubmit?         : any;
	DuplicateID?      : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IAdminEditViewState
{
	__total           : number;
	__sql             : string;
	item              : any;
	layout            : any;
	EDIT_NAME         : string;
	DUPLICATE         : boolean;
	LAST_DATE_MODIFIED: Date;
	SUB_TITLE         : any;
	PARENT_ID         : string;
	editedItem        : any;
	dependents        : Record<string, Array<any>>;
	error?            : any;
}

@observer
export default class WorkflowAlertShellsEditView extends React.Component<IAdminEditViewProps, IAdminEditViewState>
{
	private _isMounted           : boolean = false;
	private refMap               : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons        = React.createRef<HeaderButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private xomlBuilder          = React.createRef<XomlBuilder>();

	public get data (): any
	{
		let row: any = {};
		// 08/27/2019 Paul.  Move build code to shared object. 
		SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		let currentItem: any = Object.assign({}, this.state.item, this.state.editedItem, row, this.xomlBuilder.current.data);
		if ( this.state.PARENT_ID != null )
			currentItem.PARENT_ID = this.state.PARENT_ID;
		if ( currentItem['SOURCE_TYPE'] == 'normal message' )
			currentItem.CUSTOM_TEMPLATE_ID = null;
		return currentItem;
	}

	public validate(): boolean
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.Validate(this.refMap);
		if ( this.xomlBuilder.current != null && !this.xomlBuilder.current.validate() )
		{
			this.setState({ error: this.xomlBuilder.current.error() });
		}
		return (nInvalidFields == 0);
	}

	public clear(): void
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		SplendidDynamic_EditView.Clear(this.refMap);
		if ( this._isMounted )
		{
			this.setState({ editedItem: {} });
		}
	}

	constructor(props: IAdminEditViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		let EDIT_NAME = props.MODULE_NAME + '.EditView';
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		let PARENT_ID: string = null;
		let queryParams: any = qs.parse(location.search);
		if ( !Sql.IsEmptyString(queryParams['PARENT_ID']) )
		{
			PARENT_ID = queryParams['PARENT_ID'];
		}
		this.state =
		{
			__total           : 0,
			__sql             : null,
			item              : (props.rowDefaultSearch ? props.rowDefaultSearch : null),
			layout            : null,
			EDIT_NAME         ,
			DUPLICATE         : false,
			LAST_DATE_MODIFIED: null,
			SUB_TITLE         : null,
			PARENT_ID         ,
			editedItem        : null,
			dependents        : {},
			error             : null
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.props;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				// 07/06/2020 Paul.  Admin_GetReactState will also generate an exception, but catch anyway. 
				if ( !(Security.IS_ADMIN() || SplendidCache.AdminUserAccess(MODULE_NAME, 'edit') >= 0) )
				{
					throw(L10n.Term('.LBL_INSUFFICIENT_ACCESS'));
				}
				// 10/27/2019 Paul.  In case of single page refresh, we need to make sure that the AdminMenu has been loaded. 
				if ( SplendidCache.AdminMenu == null )
				{
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
				}
				if ( !Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(true);
				}
				await this.load();
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	async componentDidUpdate(prevProps: IAdminEditViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { MODULE_NAME, ID } = this.props;
				const { item, layout, EDIT_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + EDIT_NAME, item);
				if ( layout != null && error == null )
				{
					if ( ID == null || item != null )
					{
						this.props.onComponentComplete(MODULE_NAME, null, EDIT_NAME, item);
					}
				}
			}
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}
	
	private load = async () =>
	{
		const { MODULE_NAME, ID, DuplicateID } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			const layout = EditView_LoadLayout(EDIT_NAME);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			// 06/05/2021 Paul.  Must initialize rowDefaultSearch in order for xomlBuilder to get initial state. 
			let rowDefaultSearch: any = this.props.rowDefaultSearch;
			// 07/01/2021 Paul.  Don't initialize item if duplicate provided. 
			if ( Sql.IsEmptyGuid(ID) && Sql.IsEmptyGuid(DuplicateID) )
			{
				// 06/05/2021 Paul.  Must initialize rowDefaultSearch in order for xomlBuilder to get initial state. 
				// 06/06/2021 Paul.  Only initialize if new record, otherwise the EditView will not update with value from LoadItem. 
				rowDefaultSearch = {};
				let lstTYPE       : any[] = L10n.GetList('workflow_type_dom'       );
				let lstSTATUS     : any[] = L10n.GetList('workflow_status_dom'     );
				let lstBASE_MODULE: any[] = L10n.GetList('WorkflowModules'         );
				let lstRECORD_TYPE: any[] = L10n.GetList('workflow_record_type_dom');
				let lstFIRE_ORDER : any[] = L10n.GetList('workflow_fire_order_dom' );
				rowDefaultSearch.TYPE        = (lstTYPE       .length > 0 ? lstTYPE       [0] : null);
				rowDefaultSearch.STATUS      = (lstSTATUS     .length > 0 ? lstSTATUS     [0] : null);
				rowDefaultSearch.BASE_MODULE = (lstBASE_MODULE.length > 0 ? lstBASE_MODULE[0] : null);
				rowDefaultSearch.RECORD_TYPE = (lstRECORD_TYPE.length > 0 ? lstRECORD_TYPE[0] : null);
				rowDefaultSearch.FIRE_ORDER  = (lstFIRE_ORDER .length > 0 ? lstFIRE_ORDER [0] : null);
			}
			EditView_HideField(layout, 'CUSTOM_TEMPLATE_ID', true);

			// 06/11/2021 Paul.  Instead of pre-caching WorkflowAlertTemplates, just fetch every time. 
			let obj = new Object();
			obj['TableName'    ] = Crm_Modules.TableName('WorkflowAlertTemplates');
			obj['$orderby'     ] = 'NAME asc';
			obj['$select'      ] = 'ID,NAME';
			let sBody = JSON.stringify(obj);
			let res = await CreateSplendidRequest('Administration/Rest.svc/PostAdminTable', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			if ( json.d != null && json.d.results != null )
			{
				let arrListValues = [];
				for ( let i: number = 0; i < json.d.results.length; i++ )
				{
					let row: any = json.d.results[i];
					arrListValues.push(row['ID']);
					SplendidCache.SetListTerm('WorkflowAlertTemplates', row['ID'], row['NAME'] );
				}
				SplendidCache.SetTerminologyList('WorkflowAlertTemplates', arrListValues);
			}
			if ( this._isMounted )
			{
				this.setState(
				{
					layout      ,
					item        : (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem  : null,
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						this.props.onLayoutLoaded();
					}
				});
				if ( !Sql.IsEmptyString(DuplicateID) )
				{
					// 02/06/2024 Paul.  layout may not be available from state, so pass as parameter. 
					await this.LoadItem(MODULE_NAME, DuplicateID, layout);
				}
				else
				{
					// 02/06/2024 Paul.  layout may not be available from state, so pass as parameter. 
					await this.LoadItem(MODULE_NAME, ID, layout);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	// 02/06/2024 Paul.  layout may not be available from state, so pass as parameter. 
	private LoadItem = async (sMODULE_NAME: string, sID: string, layout: any[]) =>
	{
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				let options: any = 
				{
					attributeNamePrefix: ''     ,
					// 02/18/2024 Paul.  parser v4 creates object for Value. 
					// 02/18/2024 Paul.  When tag name is also Value, v4 creates an array, which is wrong and bad. 
					//<CustomProperties>
					//	<CustomProperty>
					//		<Name>crm:Module</Name>
					//		<Value>Accounts</Value>
					//	</CustomProperty>
					//	<CustomProperty>
					//		<Name>crm:Related</Name>
					//		<Value>
					//	</Value>
					//	</CustomProperty>
					//</CustomProperties>
					//textNodeName       : 'Value',
					ignoreAttributes   : false  ,
					ignoreNameSpace    : true   ,
					parseAttributeValue: true   ,
					trimValues         : false  ,
				};
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				const parser = new XMLParser(options);

				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(sMODULE_NAME, sID, true);
				let item: any = d.results;
				let LAST_DATE_MODIFIED: Date = null;
				// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
				if ( item != null && item['DATE_MODIFIED'] !== undefined )
				{
					LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
				}
				// 06/14/2021 Paul.  This module does not have a view layout, so we need to treat editing as last viewed. 
				if ( item != null )
				{
					let sNAME = Sql.ToString(item['NAME']);
					if ( !Sql.IsEmptyString(sNAME) )
					{
						SplendidCache.AddLastViewed(sMODULE_NAME, sID, sNAME);
					}
				}
				if ( item != null )
				{
					let sRDL: string = Sql.ToString(item['RDL']);
					if ( !Sql.IsEmptyString(sRDL) )
					{
						// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
						let reportXml: any = parser.parse(sRDL);
						// 05/20/2020 Paul.  A single record will not come in as an array, so convert to an array. 
						if ( reportXml.Filters && reportXml.Filters.Filter && !Array.isArray(reportXml.Filters.Filter) )
						{
							let table1: any = reportXml.Filters.Filter;
							reportXml.Filters.Filter = [];
							reportXml.Filters.Filter.push(table1);
						}
						if ( reportXml.Report && reportXml.Report.CustomProperties && Array.isArray(reportXml.Report.CustomProperties.CustomProperty) )
						{
							let arrCustomProperty: any[] = reportXml.Report.CustomProperties.CustomProperty;
							for ( let i: number = 0; i < arrCustomProperty.length; i++ )
							{
								let prop: any = arrCustomProperty[i];
								let sName : string = prop.Name;
								let sValue: string = prop.Value;
								switch ( sName )
								{
									case 'crm:Module'        :  item['BASE_MODULE'] = sValue;  break;
								}
							}
						}
					}
					let SOURCE_TYPE: string = Sql.ToString(item['SOURCE_TYPE']);
					EditView_HideField(layout, 'CUSTOM_TEMPLATE_ID', SOURCE_TYPE == 'normal message');
					EditView_HideField(layout, 'ALERT_TEXT'        , SOURCE_TYPE != 'normal message');
				}
				if ( this._isMounted )
				{
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState(
					{
						layout            ,
						item              ,
						SUB_TITLE         ,
						__sql             : d.__sql,
						LAST_DATE_MODIFIED,
						PARENT_ID         : Sql.ToString(item['PARENT_ID'])
					});
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
		}
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.editedItem;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
		if ( this._isMounted )
		{
			this.setState({ editedItem: item });
		}
	}

	private _createDependency = (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string): void =>
	{
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			dependents[PARENT_FIELD].push( {DATA_FIELD, PROPERTY_NAME} );
		}
		else
		{
			dependents[PARENT_FIELD] = [ {DATA_FIELD, PROPERTY_NAME} ]
		}
		if ( this._isMounted )
		{
			this.setState({ dependents: dependents });
		}
	}

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE);
		let { dependents, layout } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			let dependentIds = dependents[PARENT_FIELD];
			for ( let i = 0; i < dependentIds.length; i++ )
			{
				let ref = this.refMap[dependentIds[i].DATA_FIELD];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, dependentIds[i].PROPERTY_NAME, item);
				}
			}
		}
		if ( PARENT_FIELD == 'SOURCE_TYPE' )
		{
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			EditView_HideField(layout, 'CUSTOM_TEMPLATE_ID', DATA_VALUE == 'normal message');
			EditView_HideField(layout, 'ALERT_TEXT'        , DATA_VALUE != 'normal message');
			let refCUSTOM_TEMPLATE_ID = this.refMap['CUSTOM_TEMPLATE_ID'];
			if ( refCUSTOM_TEMPLATE_ID )
			{
				let bEnabled: boolean = false;
				if ( currentItem != null )
					bEnabled = (currentItem['SOURCE_TYPE'] == 'custom template');
				refCUSTOM_TEMPLATE_ID.current.updateDependancy(PARENT_FIELD, bEnabled, 'enabled', currentItem);
			}
			let refALERT_TEXT = this.refMap['ALERT_TEXT'];
			if ( refALERT_TEXT )
			{
				let bEnabled: boolean = false;
				if ( currentItem != null )
					bEnabled = (currentItem['SOURCE_TYPE'] == 'normal message');
				refALERT_TEXT.current.updateDependancy(PARENT_FIELD, bEnabled, 'enabled', currentItem);
			}
			this.setState({ layout });
		}
	}

	private _onFieldDidMount = (DATA_FIELD: string, component: any): void =>
	{
		const { item } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onFieldDidMount', DATA_FIELD);
		try
		{
			if ( DATA_FIELD == 'CUSTOM_TEMPLATE_ID' )
			{
				let bEnabled: boolean = false;
				if ( item != null )
					bEnabled = (item['SOURCE_TYPE'] == 'custom template');
				component.updateDependancy(null, bEnabled, 'enabled', null);
			}
			else if ( DATA_FIELD == 'ALERT_TEXT' )
			{
				let bEnabled: boolean = false;
				if ( item != null )
					bEnabled = (item['SOURCE_TYPE'] == 'normal message');
				component.updateDependancy(null, bEnabled, 'enabled', null);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onFieldDidMount ' + DATA_FIELD, error.message);
			this.setState({ error });
		}
	}

	// 06/15/2018 Paul.  The SearchView will register for the onSubmit event. 
	private _onSubmit = (): void =>
	{
		try
		{
			if ( this.props.onSubmit )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit');
				this.props.onSubmit();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	private UpdateModule = async (row: any, sID: string) =>
	{
		if ( !Credentials.ValidateCredentials )
		{
			throw new Error('Invalid connection information.');
		}
		else if ( row == null )
		{
			throw new Error(this.constructor.name + '.UpdateModule: row is invalid.');
		}
		else
		{
			let sBody: string = JSON.stringify(row);
			let res = await CreateSplendidRequest('Administration/WorkflowAlertShells/Rest.svc/UpdateModule', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			sID = json.d;
		}
		return sID;
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, MODULE_NAME, history, location } = this.props;
		const { LAST_DATE_MODIFIED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					if ( this.validate() )
					{
						let isDuplicate = location.pathname.includes('Duplicate');
						row = this.data;
						row.ID = (isDuplicate ? null : ID);
						if ( LAST_DATE_MODIFIED != null )
						{
							row['LAST_DATE_MODIFIED'] = LAST_DATE_MODIFIED;
						}
						if ( sCommandName == 'SaveDuplicate' || sCommandName == 'SaveConcurrency' )
						{
							row[sCommandName] = true;
						}
						try
						{
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.Busy();
							}
							row.ID = await this.UpdateModule(row, isDuplicate ? null : ID);
							history.push(`/Reset/Administration/Workflows/View/` + this.state.PARENT_ID);
						}
						catch(error)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.NotBusy();
							}
							if ( this._isMounted )
							{
								if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.ShowButton('SaveDuplicate', true);
									}
									this.setState( {error: L10n.Term(error.message) } );
								}
								else if ( error.message.includes('.ERR_CONCURRENCY_OVERRIDE') )
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.ShowButton('SaveConcurrency', true);
									}
									this.setState( {error: L10n.Term(error.message) } );
								}
								else
								{
									this.setState({ error });
								}
							}
						}
					}
					break;
				}
				case 'Cancel':
				{
					// 06/14/2021 Paul.  Redirect to parent if provided. 
					let PARENT_TYPE: string = 'Workflows';
					let PARENT_ID  : string = (this.state.item ? this.state.item['PARENT_ID'] : null );
					if ( !Sql.IsEmptyGuid(PARENT_ID) )
					{
						history.push(`/Reset/${PARENT_TYPE}/View/${PARENT_ID}`);
					}
					else if ( Sql.IsEmptyString(ID) )
					{
						// 06/14/2021 Paul.  This module does not have a list view. 
						history.push(`/Reset/Administration/${PARENT_TYPE}/List`);
					}
					else
					{
						// 06/14/2021 Paul.  This module cannot be viewed. 
						history.push(`/Reset/Administration/${PARENT_TYPE}/List`);
					}
					break;
				}
				default:
				{
					if ( this._isMounted )
					{
						this.setState( {error: sCommandName + ' is not supported at this time'} );
					}
					break;
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	public render()
	{
		const { MODULE_NAME, ID, DuplicateID, callback } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, PARENT_ID, error } = this.state;
		const { __total, __sql } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME, layout, item);
		// 09/09/2019 Paul.  We need to wait until item is loaded, otherwise fields will not get populated. 
		if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) || !Sql.IsEmptyString(DuplicateID))) )
		{
			if ( error )
			{
				return (<ErrorComponent error={error} />);
			}
			else
			{
				return null;
			}
		}
		this.refMap = {};
		let onSubmit = (this.props.onSubmit ? this._onSubmit : null);
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<div>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				<div id={!!callback ? null : "content"}>
					{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, this._onFieldDidMount, this._onChange, this._onUpdate, onSubmit, 'tabForm', this.Page_Command) }
				</div>
				
				{ !Sql.IsEmptyString(currentItem['BASE_MODULE'])
				? <XomlBuilder
					row={ currentItem }
					Modules={ currentItem['BASE_MODULE'] }
					PARENT_ID={ PARENT_ID }
					DATA_FIELD='RDL'
					DesignWorkflow={ true }
					PrimaryKeyOnly={ false }
					UseSQLParameters={ false }
					DesignChart={ false }
					ShowRelated={ true }
					ShowModule={ false }
					onChanged={ this._onChange }
					ref={ this.xomlBuilder }
				/>
				: null
				}
				{ !callback && headerButtons
				? <DynamicButtons
					ButtonStyle="EditHeader"
					VIEW_NAME={ EDIT_NAME }
					row={ item }
					Page_Command={ this.Page_Command }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.dynamicButtonsBottom }
				/>
				: null
				}
			</div>
			);
		}
		else if ( error )
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.render', error);
			return (<ErrorComponent error={error} />);
		}
		else
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
			</div>);
		}
	}
}

// 04/27/2020 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 

