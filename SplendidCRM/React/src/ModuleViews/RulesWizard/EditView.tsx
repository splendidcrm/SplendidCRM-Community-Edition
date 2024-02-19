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
import { RouteComponentProps }                        from '../Router5'                         ;
import { observer }                                   from 'mobx-react'                               ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'           ;
// 2. Store and Types. 
import ACL_FIELD_ACCESS                               from '../../types/ACL_FIELD_ACCESS'              ;
import { EditComponent }                              from '../../types/EditComponent'                 ;
import { HeaderButtons }                              from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                            from '../../scripts/Sql'                         ;
import L10n                                           from '../../scripts/L10n'                        ;
import Security                                       from '../../scripts/Security'                    ;
import Credentials                                    from '../../scripts/Credentials'                 ;
import SplendidCache                                  from '../../scripts/SplendidCache'               ;
import SplendidDynamic                                from '../../scripts/SplendidDynamic'             ;
import SplendidDynamic_EditView                       from '../../scripts/SplendidDynamic_EditView'    ;
import { Crm_Config, Crm_Modules }                    from '../../scripts/Crm'                         ;
import { Trim }                                       from '../../scripts/utility'                     ;
import { AuthenticatedMethod, LoginRedirect }         from '../../scripts/Login'                       ;
import { sPLATFORM_LAYOUT }                           from '../../scripts/SplendidInitUI'              ;
import { EditView_LoadItem, EditView_LoadLayout }     from '../../scripts/EditView'                    ;
import { CreateSplendidRequest, GetSplendidResult }   from '../../scripts/SplendidRequest'             ;
// 4. Components and Views. 
import ErrorComponent                                 from '../../components/ErrorComponent'           ;
import DumpSQL                                        from '../../components/DumpSQL'                  ;
import HeaderButtonsFactory                           from '../../ThemeComponents/HeaderButtonsFactory';
import SplendidGrid                                   from '../../components/SplendidGrid'             ;
import QueryBuilder                                   from '../../ReportDesigner/QueryBuilder'         ;
import RuleBuilder                                    from './RuleBuilder'                             ;

let bDebug: boolean = false;
const RULES_WIZARD_MODULE_NAME: string = 'RulesWizard';

interface IEditViewProps extends RouteComponentProps<any>
{
	ID?                : string;
	LAYOUT_NAME        : string;
	// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
	CONTROL_VIEW_NAME? : string;
	callback?          : any;
	rowDefaultSearch?  : any;
	onLayoutLoaded?    : any;
	onSubmit?          : any;
	isSearchView?      : boolean;
	isUpdatePanel?     : boolean;
	isQuickCreate?     : boolean;
	DuplicateID?       : string;
	ConvertModule?     : string;
	ConvertID?         : string;
	// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
	fromLayoutName?    : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IEditViewState
{
	__total              : number;
	__sql                : string;
	item                 : any;
	layout               : any;
	EDIT_NAME            : string;
	DUPLICATE            : boolean;
	LAST_DATE_MODIFIED   : Date;
	SUB_TITLE            : any;
	editedItem           : any;
	dependents           : Record<string, Array<any>>;
	activeTab            : string;
	SOURCE               : string;
	USE_TRANSACTION      : boolean;

	IMPORT_STATUS?       : string;
	IMPORT_SUCCESS?      : string;
	IMPORT_SUCCESS_COUNT?: number;
	IMPORT_DUPLICATE?    : string;
	IMPORT_FAILED?       : string;
	IMPORT_FAILED_COUNT? : number;
	ProcessedFileID?     : string;

	showPreviewFilter    : boolean;
	showPreviewRules     : boolean;
	previewKey           : number;

	error?               : any;
}

// 09/18/2019 Paul.  Give class a unique name so that it can be debugged.  Without the unique name, Chrome gets confused.
@observer
export default class RulesWizardEditView extends React.Component<IEditViewProps, IEditViewState>
{
	private _isMounted    : boolean = false;
	private themeURL      : string;
	private legacyIcons   : boolean = false;
	private refMap        : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons = React.createRef<HeaderButtons>();
	private PARENT_ID     : string = null;
	private PARENT_TYPE   : string = null;
	private queryBuilder  = React.createRef<QueryBuilder>();
	private ruleBuilder  = React.createRef<RuleBuilder>();
	private previewGrid  = React.createRef<SplendidGrid>();
	private splendidGrid = React.createRef<SplendidGrid>();

	public get data (): any
	{
		const { ID } = this.props;
		let isDuplicate = location.pathname.includes('Duplicate');
		let row: any      = Object.assign({ID: isDuplicate ? null : ID}, this.queryBuilder.current.data, this.ruleBuilder.current.data);
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		// 08/26/2019 Paul.  There does not seem to be a need to save date in DATE_TIME field here as this is used for search views. 
		if ( nInvalidFields == 0 )
		{
		}
		return row;
	}

	public validate(): boolean
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.Validate(this.refMap);
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

	constructor(props: IEditViewProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		let item = (props.rowDefaultSearch ? props.rowDefaultSearch : null);
		let EDIT_NAME = RULES_WIZARD_MODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		this.state =
		{
			__total                : 0,
			__sql                  : null,
			item                   ,
			layout                 : null,
			EDIT_NAME              ,
			DUPLICATE              : false,
			LAST_DATE_MODIFIED     : null,
			SUB_TITLE              : null,
			editedItem             : null,
			dependents             : {},
			error                  : null,
			activeTab              : 'Module'      ,
			SOURCE                 : 'excel'       ,
			USE_TRANSACTION        : true          ,

			showPreviewFilter      : false         ,
			showPreviewRules       : false         ,
			previewKey             : 0             ,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { isSearchView } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount ' + this.props.ID, this.props.location.pathname + this.props.location.search);
		this._isMounted = true;
		try
		{
			// 05/29/2019 Paul.  In search mode, EditView will not redirect to login. 
			if ( Sql.ToBoolean(isSearchView) )
			{
				if ( Credentials.bIsAuthenticated )
				{
					await this.load();
				}
			}
			else
			{
				let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
				if ( status == 1 )
				{
					if ( Credentials.ADMIN_MODE )
					{
						Credentials.SetADMIN_MODE(false);
					}
					await this.load();
				}
				else
				{
					LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	async componentDidUpdate(prevProps: IEditViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate Reset ' + this.state.EDIT_NAME, this.props.location,  prevProps.location);
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { ID } = this.props;
				const { item, layout, EDIT_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + EDIT_NAME, item);
				if ( layout != null && error == null )
				{
					if ( ID == null || item != null )
					{
						this.props.onComponentComplete(RULES_WIZARD_MODULE_NAME, null, EDIT_NAME, item);
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
		const { ID, DuplicateID, ConvertModule, ConvertID } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			// 10/12/2019 Paul.  Add support for parent assignment during creation. 
			let rowDefaultSearch: any = this.props.rowDefaultSearch;
			let queryParams: any = qs.parse(location.search);
			// 10/13/2020 Paul.  Correct parent found condition. 
			let bParentFound: boolean = (rowDefaultSearch !== undefined && rowDefaultSearch != null);
			if ( !Sql.IsEmptyGuid(queryParams['PARENT_ID']) )
			{
				this.PARENT_ID   = queryParams['PARENT_ID'];
				this.PARENT_TYPE = await Crm_Modules.ParentModule(this.PARENT_ID);
				if ( !Sql.IsEmptyString(this.PARENT_TYPE) )
				{
					rowDefaultSearch = await Crm_Modules.LoadParent(this.PARENT_TYPE, this.PARENT_ID);
					bParentFound = true;
				}
				else
				{
					this.setState( {error: 'Parent ID [' + this.PARENT_ID + '] was not found.'} );
				}
			}
			// 05/28/2020 Paul.  Ignore missing SearchSubpanel. 
			const layout = EditView_LoadLayout(EDIT_NAME, this.props.isSearchView);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			if ( this._isMounted )
			{
				this.setState(
				{
					layout: layout,
					item: (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem: null
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load onLayoutLoaded');
						this.props.onLayoutLoaded();
					}
				});
				if ( !Sql.IsEmptyString(DuplicateID) )
				{
					await this.LoadItem(DuplicateID);
				}
				else
				{
					await this.LoadItem(ID);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private LoadItem = async (sID: string) =>
	{
		const { callback, isSearchView, isUpdatePanel } = this.props;
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(RULES_WIZARD_MODULE_NAME, sID);
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
						SplendidCache.AddLastViewed(RULES_WIZARD_MODULE_NAME, sID, sNAME);
					}
				}
				if ( this._isMounted )
				{
					Sql.SetPageTitle(RULES_WIZARD_MODULE_NAME, item, 'NAME');
					
					let SUB_TITLE   : any     = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState(
					{
						item              ,
						SUB_TITLE         ,
						__sql             : d.__sql,
						LAST_DATE_MODIFIED,
						activeTab         : 'BusinessRules',
					});
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
		}
		else if ( !callback && !isSearchView && !isUpdatePanel )
		{
			Sql.SetPageTitle(RULES_WIZARD_MODULE_NAME, null, null);
			let lstModules: any[] = L10n.GetList('RulesModules');
			if ( lstModules != null && lstModules.length > 0 )
			{
				let MODULE_NAME: string = lstModules[0];
				let item: any = { MODULE_NAME };
				this.setState({ item });
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
			if ( DATA_FIELD == 'MODULE_NAME' )
			{
				this.setState({ editedItem: item });
			}
			else
			{
				this.setState({ editedItem: item });
			}
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
		let { dependents } = this.state;
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

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, history, location } = this.props;
		const { LAST_DATE_MODIFIED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					let row: any      = Object.assign({ID: isDuplicate ? null : ID}, this.queryBuilder.current.data, this.ruleBuilder.current.data);
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
					if ( nInvalidFields == 0 )
					{
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
							row.RULE_TYPE = 'Wizard';
							let sBody = JSON.stringify(row);
							let sUrl: string = 'RulesWizard/Rest.svc/UpdateModule';
							let res = await CreateSplendidRequest(sUrl, 'POST', 'application/octet-stream', sBody);
							let json = await GetSplendidResult(res);
							row.ID = json.d;
							history.push(`/Reset/${RULES_WIZARD_MODULE_NAME}/`);
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
					// 10/15/2019 Paul.  Redirect to parent if provided. 
					if ( !Sql.IsEmptyGuid(this.PARENT_ID) )
					{
						history.push(`/Reset/${this.PARENT_TYPE}/View/${this.PARENT_ID}`);
					}
					else if ( Sql.IsEmptyString(ID) )
					{
						history.push(`/Reset/${RULES_WIZARD_MODULE_NAME}/List`);
					}
					else
					{
						// 06/14/2021 Paul.  This module cannot be viewed. 
						//history.push(`/Reset/${RULES_WIZARD_MODULE_NAME}/View/${ID}`);
						history.push(`/Reset/${RULES_WIZARD_MODULE_NAME}/List`);
					}
					break;
				}
				case 'Filter.Preview':
				{
					this.setState(
					{
						showPreviewFilter: true,
						showPreviewRules : false,
						previewKey       : this.state.previewKey + 1,
						activeTab        : 'ModuleFilter',
					});
					break;
				}
				case 'Rules.Preview':
				case 'Rules.Submit':
				{
					try
					{
						if ( this.headerButtons.current != null )
						{
							this.headerButtons.current.Busy();
						}
						let row: any      = Object.assign({}, this.state.item, this.queryBuilder.current.data, this.ruleBuilder.current.data);
						row.Preview       = (sCommandName == 'Rules.Preview');
						row.UseTrasaction = this.state.USE_TRANSACTION;
						row.RULE_TYPE     = 'Wizard';
						let sBody = JSON.stringify(row);
						let sUrl: string = 'RulesWizard/Rest.svc/SubmitRules';
						let res = await CreateSplendidRequest(sUrl, 'POST', 'application/octet-stream', sBody);
						let json = await GetSplendidResult(res);
						
						let IMPORT_SUCCESS_COUNT: number = json.SuccessCount;
						let IMPORT_FAILED_COUNT : number = json.FailedCount;
						let IMPORT_STATUS       : string = json.Status;
						let IMPORT_SUCCESS      : string = L10n.Term("RulesWizard.LBL_SUCCESSFULLY" ).replace('{0}', IMPORT_SUCCESS_COUNT);
						let IMPORT_FAILED       : string = L10n.Term("RulesWizard.LBL_FAILED_IMPORT" ).replace('{0}', IMPORT_FAILED_COUNT);
						let ProcessedFileID     : string = json.ProcessedFileID;
						this.setState(
						{
							showPreviewFilter   : false,
							showPreviewRules    : true,
							previewKey          : this.state.previewKey + 1,
							activeTab           : 'Results',
							IMPORT_SUCCESS_COUNT,
							IMPORT_FAILED_COUNT ,
							IMPORT_STATUS       ,
							IMPORT_SUCCESS      ,
							IMPORT_FAILED       ,
							ProcessedFileID     ,
						});
					}
					catch(error)
					{
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
					}
					finally
					{
						if ( this.headerButtons.current != null )
						{
							this.headerButtons.current.NotBusy();
						}
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

	private _onTabChange = (key) =>
	{
		this.setState({ activeTab: key });
	}

	private _onUSE_TRANSACTION = (e) =>
	{
		this.setState({ USE_TRANSACTION: e.target.checked });
	}

	private _onPreviewGridLayoutLoaded = async () =>
	{
		if ( this.previewGrid.current != null )
		{
			this.previewGrid.current.Search(null, null);
		}
	}

	private _onFiltersGridLayoutLoaded = async () =>
	{
		if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(null, null);
		}
	}

	private LoadPreviewRules = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		const { ProcessedFileID } = this.state;
		let res = await CreateSplendidRequest('RulesWizard/Rest.svc/GetPreviewRules?ProcessedFileID=' + ProcessedFileID + '&$top=' + nTOP + '&$skip=' + nSKIP + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION), 'GET');
		let json = await GetSplendidResult(res);
		json.d.__total = json.__total;
		json.d.__sql   = '';
		return (json.d);
	}

	private LoadFilter = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		// 06/15/2021 Paul.  Must included editedItems. 
		let obj: any = Object.assign({}, this.state.item, this.state.editedItem, this.queryBuilder.current.data);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadFilter item: ', this.state.item);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadFilter data: ', this.queryBuilder.current.data);
		obj['$top'            ] = nTOP          ;
		obj['$skip'           ] = nSKIP         ;
		obj['$orderby'        ] = Sql.ToString(sSORT_FIELD + ' ' + sSORT_DIRECTION);
		obj['$select'         ] = Sql.ToString(sSELECT);

		let sBody = JSON.stringify(obj);
		let res = await CreateSplendidRequest('RulesWizard/Rest.svc/GetPreviewFilter', 'POST', 'application/octet-stream', sBody);
		let json = await GetSplendidResult(res);
		json.d.__total = json.__total;
		json.d.__sql   = json.__sql;
		return (json.d);
	}

	private BootstrapColumns = (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) =>
	{
		let readonly      : boolean = true;
		let isPopupView   : boolean = false;
		let RELATED_MODULE: string  = null;
		let disableView   : boolean = true;
		let disableEdit   : boolean = true;
		let disableRemove : boolean = true;
		// 04/20/2017 Paul.  Build DataTables columns. 
		let arrDataTableColumns = [];
		let objDataColumn: any = {};
		if ( !readonly && !isPopupView )
		{
			// 05/28/2020 Paul.  Use RELATED_MODULE instead of cbRemove to determine of the related formatter is used. 
			if ( !Sql.IsEmptyString(RELATED_MODULE) )
			{
				// 06/19/2020 Paul.  Don't create column in related view and 
				// 10/12/2020 Paul.  Add width attribute. 
				if ( !disableView || !disableEdit || !disableRemove )
				{
					objDataColumn =
					{
						key            : 'editview',
						text           : null,
						dataField      : 'empty1',
						headerFormatter: (this.previewGrid.current != null ? this.previewGrid.current.renderHeader             : null),
						formatter      : (this.previewGrid.current != null ? this.previewGrid.current.editviewRelatedFormatter : null),
						headerClasses  : 'listViewThS2',
						headerStyle    : {padding: 0, margin: 0},
						sort           : false,
						isDummyField   : true,
						attrs          : { width: '1%' },
						formatExtraData:
						{
							data:
							{
								GRID_NAME: sLIST_MODULE_NAME,
								DATA_FIELD: null,
								fnRender: null,
								layout: layout
							}
						}
					};
					// 01/07/2018 Paul.  Force first column to be displayed. 
					arrDataTableColumns.push(objDataColumn);
				}
			}
			else
			{
				objDataColumn =
				{
					key            : 'editview',
					text           : null,
					dataField      : 'empty1',
					headerFormatter: (this.previewGrid.current != null ? this.previewGrid.current.renderHeader            : null),
					formatter      : (this.previewGrid.current != null ? this.previewGrid.current.editviewColumnFormatter : null),
					headerClasses  : 'listViewThS2',
					headerStyle    : {padding: 0, margin: 0},
					sort           : false,
					isDummyField   : true,
					attrs          : { width: '1%' },
					formatExtraData:
					{
						data:
						{
							GRID_NAME: sLIST_MODULE_NAME,
							DATA_FIELD: null,
							fnRender: null,
							layout: layout
						}
					}
				};
				// 01/07/2018 Paul.  Force first column to be displayed. 
				arrDataTableColumns.push(objDataColumn);
			}
		}
		objDataColumn =
		{
			key            : 'columnRowNumber',
			text           : L10n.Term('RulesWizard.LBL_LIST_IMPORT_ROW_NUMBER'),
			dataField      : 'IMPORT_ROW_NUMBER',
			classes        : null,
			style          : null,
			headerClasses  : 'listViewThS2',
			headerStyle    : {whiteSpace: 'nowrap'},
			headerFormatter: (this.previewGrid.current != null ? this.previewGrid.current.renderHeader         : null),
			formatter      : (this.previewGrid.current != null ? this.previewGrid.current.boundColumnFormatter : null),
			sort           : 'IMPORT_ROW_NUMBER',
			isDummyField   : false,
			formatExtraData: {
				data: {
					GRID_NAME   : sLIST_MODULE_NAME,
					DATA_FIELD  : 'IMPORT_ROW_NUMBER',
					COLUMN_INDEX: 0,
					layout      : {DATA_FIELD: 'IMPORT_ROW_NUMBER', DATA_FORMAT: '{0:N0}'}
				}
			}
		};
		// 04/24/2022 Paul.  Move Arctic style override to style.css. 
		arrDataTableColumns.push(objDataColumn);
		objDataColumn =
		{
			key            : 'columnRowStatus',
			text           : L10n.Term('RulesWizard.LBL_LIST_IMPORT_ROW_STATUS'),
			dataField      : 'IMPORT_ROW_STATUS',
			classes        : null,
			style          : null,
			headerClasses  : 'listViewThS2',
			headerStyle    : {whiteSpace: 'nowrap'},
			headerFormatter: (this.previewGrid.current != null ? this.previewGrid.current.renderHeader         : null),
			formatter      : (this.previewGrid.current != null ? this.previewGrid.current.boundColumnFormatter : null),
			sort           : 'IMPORT_ROW_STATUS',
			isDummyField   : false,
			formatExtraData: {
				data: {
					GRID_NAME   : sLIST_MODULE_NAME,
					DATA_FIELD  : 'IMPORT_ROW_STATUS',
					COLUMN_INDEX: 0,
					layout      : {DATA_FIELD: 'IMPORT_ROW_STATUS'}
				}
			}
		};
		// 04/24/2022 Paul.  Move Arctic style override to style.css. 
		arrDataTableColumns.push(objDataColumn);
		objDataColumn =
		{
			key            : 'columnRowError',
			text           : L10n.Term('RulesWizard.LBL_LIST_IMPORT_ROW_ERROR'),
			dataField      : 'IMPORT_ROW_ERROR',
			classes        : null,
			style          : null,
			headerClasses  : 'listViewThS2',
			headerStyle    : {whiteSpace: 'nowrap'},
			headerFormatter: (this.previewGrid.current != null ? this.previewGrid.current.renderHeader         : null),
			formatter      : (this.previewGrid.current != null ? this.previewGrid.current.boundColumnFormatter : null),
			sort           : 'IMPORT_ROW_ERROR',
			isDummyField   : false,
			formatExtraData: {
				data: {
					GRID_NAME   : sLIST_MODULE_NAME,
					DATA_FIELD  : 'IMPORT_ROW_ERROR',
					COLUMN_INDEX: 0,
					layout      : {DATA_FIELD: 'IMPORT_ROW_ERROR'}
				}
			}
		};
		// 04/24/2022 Paul.  Move Arctic style override to style.css. 
		arrDataTableColumns.push(objDataColumn);

		let bEnableTeamManagement = Crm_Config.enable_team_management();
		let bEnableDynamicTeams = Crm_Config.enable_dynamic_teams();
		let bEnableDynamicAssignment = Crm_Config.enable_dynamic_assignment();
		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		let oNumberFormat = Security.NumberFormatInfo();
		if ( Crm_Config.ToString('currency_format') == 'c0' )
		{
			oNumberFormat.CurrencyDecimalDigits = 0;
		}
		if ( layout != null )
		{
			for ( let nLayoutIndex = 0; layout != null && nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				let COLUMN_TYPE                = lay.COLUMN_TYPE               ;
				let COLUMN_INDEX               = lay.COLUMN_INDEX              ;
				let HEADER_TEXT                = lay.HEADER_TEXT               ;
				let SORT_EXPRESSION            = lay.SORT_EXPRESSION           ;
				let ITEMSTYLE_WIDTH            = lay.ITEMSTYLE_WIDTH           ;
				// 11/02/2020 Paul.  Apply layout defined style. 
				let ITEMSTYLE_CSSCLASS         = Sql.ToString(lay.ITEMSTYLE_CSSCLASS);
				let ITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN;
				let ITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN  ;
				// 10/30/2020 Paul.  ITEMSTYLE_WRAP defaults to true. 
				let ITEMSTYLE_WRAP             = (lay.ITEMSTYLE_WRAP == null ? true : lay.ITEMSTYLE_WRAP);
				let DATA_FIELD                 = lay.DATA_FIELD                ;
				let DATA_FORMAT                = lay.DATA_FORMAT               ;
				let URL_FIELD                  = lay.URL_FIELD                 ;
				let URL_FORMAT                 = lay.URL_FORMAT                ;
				let URL_TARGET                 = lay.URL_TARGET                ;
				let LIST_NAME                  = lay.LIST_NAME                 ;
				let URL_MODULE                 = lay.URL_MODULE                ;
				let URL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD        ;
				let VIEW_NAME                  = lay.VIEW_NAME                 ;
				let MODULE_NAME                = lay.MODULE_NAME               ;
				let MODULE_TYPE                = lay.MODULE_TYPE               ;
				let PARENT_FIELD               = lay.PARENT_FIELD              ;

				if ( (DATA_FIELD == 'TEAM_NAME' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( bEnableTeamManagement )
					{
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						// 04/03/2021 Paul.  Apply single rule. 
						if ( bEnableDynamicTeams && DATA_FORMAT != '1' && Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('single') < 0 )
						{
							HEADER_TEXT = '.LBL_LIST_TEAM_SET_NAME';
							DATA_FIELD  = 'TEAM_SET_NAME';
						}
						else
						{
							HEADER_TEXT = '.LBL_LIST_TEAM_NAME';
							DATA_FIELD  = 'TEAM_NAME';
						}
					}
					else
					{
						// 10/24/2012 Paul.  Clear the sort so that there would be no term lookup. 
						HEADER_TEXT     = null;
						SORT_EXPRESSION = null;
						COLUMN_TYPE     = 'Hidden';
					}
				}
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				// 04/03/2021 Paul.  Dynamic Assignment must be managed here as well as in SplendidGrid. 
				else if ( DATA_FIELD == 'ASSIGNED_TO' || DATA_FIELD == 'ASSIGNED_TO_NAME' || DATA_FIELD == 'ASSIGNED_SET_NAME' )
				{
					// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
					if ( bEnableDynamicAssignment && Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('single') < 0 )
					{
						HEADER_TEXT = '.LBL_LIST_ASSIGNED_SET_NAME';
						DATA_FIELD  = 'ASSIGNED_SET_NAME';
					}
					else if ( DATA_FIELD == 'ASSIGNED_SET_NAME' )
					{
						HEADER_TEXT = '.LBL_LIST_ASSIGNED_USER';
						DATA_FIELD  = 'ASSIGNED_TO_NAME';
					}
				}
				// 01/18/2010 Paul.  A field is either visible or not.  At this time, we will not only show a field to its owner. 
				let bIsReadable: boolean = true;
				// 08/02/2010 Paul.  The JavaScript and Hover fields will not have a data field. 
				if ( SplendidCache.bEnableACLFieldSecurity && !Sql.IsEmptyString(DATA_FIELD) )
				{
					let gASSIGNED_USER_ID: string = null;
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}

				if (   COLUMN_TYPE == 'BoundColumn'
				  && ( DATA_FORMAT == 'Date'
					|| DATA_FORMAT == 'DateTime'
					|| DATA_FORMAT == 'Currency'
					|| DATA_FORMAT == 'Image'
					|| DATA_FORMAT == 'MultiLine'
					// 08/26/2014 Paul.  Ignore ImageButton. 
					|| DATA_FORMAT == 'ImageButton'
				   )
				)
				{
					COLUMN_TYPE = 'TemplateColumn';
				}
				if ( DATA_FORMAT == 'ImageButton' && URL_FORMAT == 'Preview' )
				{
					bIsReadable = bIsReadable && SplendidDynamic.StackedLayout(SplendidCache.UserTheme);
				}
				// 08/20/2016 Paul.  The hidden field is a DATA_FORMAT, not a COLUMN_TYPE, but keep COLUMN_TYPE just in case anyone used it. 
				// 07/22/2019 Paul.  Apply ACL Field Security. 
				if ( !bIsReadable || COLUMN_TYPE == 'Hidden' || DATA_FORMAT == 'Hidden' )
				{
					continue;  // 04/23/2017 Paul.  Return instead of continue as we are in a binding function. 
				}
				if ( COLUMN_TYPE == 'TemplateColumn' )
				{
					// 04/20/2017 Paul.  Build DataTables columns. 
					// 01/22/2020 Paul.  Apply wrap flag. 
					// 11/02/2020 Paul.  Apply layout defined style. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : ITEMSTYLE_CSSCLASS,
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: (this.previewGrid.current != null ? this.previewGrid.current.renderHeader            : null),
						formatter      : (this.previewGrid.current != null ? this.previewGrid.current.templateColumnFormatter : null),
						sort           : (SORT_EXPRESSION != null),
						isDummyField   : false,
						formatExtraData:
						{
							data:
							{
								GRID_NAME   : sLIST_MODULE_NAME,
								DATA_FIELD  : DATA_FIELD,
								COLUMN_INDEX: COLUMN_INDEX,
								layout      : lay
							}
						}
					};
					// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
					// 04/24/2022 Paul.  Move Arctic style override to style.css. 
					if ( ITEMSTYLE_HORIZONTAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_HORIZONTAL_ALIGN;
					}
					if ( ITEMSTYLE_VERTICAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_VERTICAL_ALIGN;
					}
					if ( ITEMSTYLE_WIDTH != null )
					{
						objDataColumn.attrs = { width: ITEMSTYLE_WIDTH };
					}
					// 07/25/2017 Paul.  Try and force the NAME column to always be displayed on mobile portrait mode. 
					// https://datatables.net/extensions/responsive/classes
					if ( DATA_FIELD == "NAME" )
					{
						objDataColumn.classes = ' all';
					}
					objDataColumn.classes = Trim(objDataColumn.classes);

					arrDataTableColumns.push(objDataColumn);
				}
				else if ( COLUMN_TYPE == 'BoundColumn' )
				{
					// 04/20/2017 Paul.  Build DataTables columns. 
					// 01/22/2020 Paul.  Apply wrap flag. 
					// 11/02/2020 Paul.  Apply layout defined style. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : ITEMSTYLE_CSSCLASS,
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: (this.previewGrid.current != null ? this.previewGrid.current.renderHeader         : null),
						formatter      : (this.previewGrid.current != null ? this.previewGrid.current.boundColumnFormatter : null),
						sort           : (SORT_EXPRESSION != null),
						isDummyField   : false,
						formatExtraData: {
							data: {
								GRID_NAME   : sLIST_MODULE_NAME,
								DATA_FIELD  : DATA_FIELD,
								COLUMN_INDEX: COLUMN_INDEX,
								layout      : lay
							}
						}
					};
					// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
					// 04/24/2022 Paul.  Move Arctic style override to style.css. 
					if ( ITEMSTYLE_HORIZONTAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_HORIZONTAL_ALIGN;
					}
					if ( ITEMSTYLE_VERTICAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_VERTICAL_ALIGN;
					}
					if ( ITEMSTYLE_WIDTH != null )
					{
						objDataColumn.attrs = { width: ITEMSTYLE_WIDTH };
					}
					objDataColumn.classes = Trim(objDataColumn.classes);
					arrDataTableColumns.push(objDataColumn);
				}
			}
			// 05/17/2018 Paul.  Defer finalize. 
			//if ( this.BootstrapColumnsFinalize != null )
			//	arrDataTableColumns = this.BootstrapColumnsFinalize(sLIST_MODULE_NAME, arrDataTableColumns);
		}
		
		// 11/04/2020 Paul.  Legacy icons means that the remove is on the right. 
		if ( !readonly && !isPopupView && this.legacyIcons )
		{
			// 05/28/2020 Paul.  Use RELATED_MODULE instead of cbRemove to determine of the related formatter is used. 
			if ( !Sql.IsEmptyString(RELATED_MODULE) )
			{
				// 06/19/2020 Paul.  Don't create column in related view and 
				// 10/12/2020 Paul.  Add width attribute. 
				if ( !disableView || !disableEdit || !disableRemove )
				{
					objDataColumn =
					{
						key            : 'editview',
						text           : null,
						dataField      : 'empty1',
						formatter      : (this.previewGrid.current != null ? this.previewGrid.current.editviewRelatedFormatterLegacy : null),
						headerClasses  : 'listViewThS2',
						headerStyle    : {padding: 0, margin: 0},
						headerFormatter: (this.previewGrid.current != null ? this.previewGrid.current.renderHeader : null),
						sort           : false,
						isDummyField   : true,
						attrs          : { width: '1%' },
						formatExtraData:
						{
							data:
							{
								GRID_NAME: sLIST_MODULE_NAME,
								DATA_FIELD: null,
								fnRender: null,
								layout: layout
							}
						}
					};
					// 01/07/2018 Paul.  Force first column to be displayed. 
					arrDataTableColumns.push(objDataColumn);
				}
			}
		}
		return arrDataTableColumns;
	}

	public render()
	{
		// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
		const { ID, LAYOUT_NAME, CONTROL_VIEW_NAME, DuplicateID, ConvertID, isSearchView, isUpdatePanel, isQuickCreate, callback } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, error } = this.state;
		const { activeTab, showPreviewFilter, showPreviewRules, previewKey } = this.state;
		const { USE_TRANSACTION, IMPORT_STATUS, IMPORT_SUCCESS, IMPORT_DUPLICATE, IMPORT_FAILED, IMPORT_FAILED_COUNT, ProcessedFileID } = this.state;
		const { __total, __sql } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME, layout, item);
		// 09/09/2019 Paul.  We need to wait until item is loaded, otherwise fields will not get populated. 
		// 09/18/2019 Paul.  Include ConvertID. 
		if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) || !Sql.IsEmptyString(DuplicateID) || !Sql.IsEmptyString(ConvertID))) )
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
		if ( SplendidCache.IsInitialized )
		{
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
			let styCheckbox = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '6px', marginRight: '6px' };
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			if ( Crm_Config.ToBoolean('enable_legacy_icons') )
			{
				styCheckbox.transform = 'scale(1.0)';
				styCheckbox.marginBottom = '2px';
			}
			let MODULE_NAME: string = currentItem['MODULE_NAME'];
			return (
			<React.Fragment>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME: 'RulesWizard', ID, SUB_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: !isSearchView && !isUpdatePanel, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				{ LAYOUT_NAME && LAYOUT_NAME.indexOf('.MassUpdate') < 0
				? <DumpSQL SQL={ __sql } />
				: null
				}
				<ul id='pnlSearchTabs' className='tablist' style={ {paddingBottom: '5px'} }>
					<li>
						<a id='linkRulesWizard1' onClick={ (e) => { e.preventDefault(); return this._onTabChange('Module'); } } href='#' className={ activeTab == 'Module' ? 'current' : null }>{ L10n.Term('RulesWizard.LBL_WIZARD_STEP1') }</a>
					</li>
					<li>
						<a id='linkRulesWizard2' onClick={ (e) => { e.preventDefault(); return this._onTabChange('ModuleFilter'); } } href='#' className={ activeTab == 'ModuleFilter' ? 'current' : null }>{ L10n.Term('RulesWizard.LBL_WIZARD_STEP2') }</a>
					</li>
					<li>
						<a id='linkRulesWizard3' onClick={ (e) => { e.preventDefault(); return this._onTabChange('BusinessRules'); } } href='#' className={ activeTab == 'BusinessRules' ? 'current' : null }>{ L10n.Term('RulesWizard.LBL_WIZARD_STEP3') }</a>
					</li>
					<li>
						<a id='linkRulesWizard4' onClick={ (e) => { e.preventDefault(); return this._onTabChange('Results'); } } href='#' className={ activeTab == 'Results' ? 'current' : null }>{ L10n.Term('RulesWizard.LBL_WIZARD_STEP4') }</a>
					</li>
				</ul>
				<div style={ {display: (activeTab == 'Module' ? 'block' : 'none')} }>
					{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, (isSearchView || isQuickCreate ? null : 'tabForm'), this.Page_Command, isSearchView, CONTROL_VIEW_NAME) }
				</div>
				<div style={ {display: (activeTab == 'ModuleFilter' ? 'block' : 'none')} }>
					<QueryBuilder row={ currentItem } Modules={ MODULE_NAME } DATA_FIELD='FILTER_XML' UseSQLParameters={ true } ShowRelated={ true } onChanged={ this._onChange } ref={ this.queryBuilder} />
					{ showPreviewFilter
					? <div style={ {width: '100%'} }>
						<SplendidGrid
							key={ 'splendidGrid_' + previewKey }
							onLayoutLoaded={ this._onFiltersGridLayoutLoaded }
							MODULE_NAME={ MODULE_NAME }
							GRID_NAME={ MODULE_NAME + '.ListView' }
							SORT_FIELD='NAME'
							SORT_DIRECTION='asc'
							ADMIN_MODE={ false }
							AutoSaveSearch={ false }
							deferLoad={ true }
							disableEdit={ true }
							disableView={ true }
							enableSelection={ false }
							cbCustomLoad={ this.LoadFilter }
							enableMassUpdate={ false }
							scrollable
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.splendidGrid }
						/>
					</div>
					: null
					}
				</div>
			`	<div style={ {display: (activeTab == 'BusinessRules' ? 'block' : 'none')} }>
					<RuleBuilder RULE_TYPE='Wizard' row={ currentItem } onChanged={ this._onChange } ref={ this.ruleBuilder} />
				</div>
				<div style={ {display: (activeTab == 'Results' ? 'block' : 'none')} }>
					<div id='lblStatus'         >{ IMPORT_STATUS    }</div>
					<div id='lblSuccessCount'   >{ IMPORT_SUCCESS   }</div>
					<div id='lblFailedCount'    >{ IMPORT_FAILED    }</div>
					<br />
					<div>
						{ L10n.Term('Import.LBL_USE_TRANSACTION') }
						<input type='checkbox' className='checkbox' style={ styCheckbox } checked={ USE_TRANSACTION } onClick={ this._onUSE_TRANSACTION } />
					</div>
					{ showPreviewRules
					? <div style={ {width: '100%'} }>
						<SplendidGrid
							key={ 'previewGrid_' + previewKey }
							onLayoutLoaded={ this._onPreviewGridLayoutLoaded }
							MODULE_NAME={ RULES_WIZARD_MODULE_NAME }
							GRID_NAME={ MODULE_NAME + '.ListView' }
							SORT_FIELD='IMPORT_ROW_STATUS,IMPORT_ROW_NUMBER'
							SORT_DIRECTION='asc'
							deferLoad={ true }
							disableEdit={ true }
							disableView={ true }
							enableSelection={ false }
							scrollable
							cbCustomLoad={ this.LoadPreviewRules }
							cbCustomColumns={ this.BootstrapColumns }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.previewGrid }
						/>
					</div>
					: null
					}
				</div>
			</React.Fragment>
			);
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

