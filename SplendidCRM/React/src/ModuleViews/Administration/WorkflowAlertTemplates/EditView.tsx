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
import * as React from 'react';
import { RouteComponentProps, withRouter }          from 'react-router-dom'                         ;
import { observer }                                 from 'mobx-react'                               ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'           ;
// 2. Store and Types. 
import { EditComponent }                            from '../../../types/EditComponent'             ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'             ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                     ;
import L10n                                         from '../../../scripts/L10n'                    ;
import Security                                     from '../../../scripts/Security'                ;
import Credentials                                  from '../../../scripts/Credentials'             ;
import SplendidCache                                from '../../../scripts/SplendidCache'           ;
import SplendidDynamic_EditView                     from '../../../scripts/SplendidDynamic_EditView';
import { Crm_Config }                               from '../../../scripts/Crm'                     ;
import { Admin_GetReactState }                      from '../../../scripts/Application'             ;
import { base64ArrayBuffer }                        from '../../../scripts/utility'                 ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                   ;
import { EditView_LoadItem, EditView_LoadLayout }   from '../../../scripts/EditView'                ;
import { UpdateModule }                             from '../../../scripts/ModuleUpdate'            ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'         ;
// 4. Components and Views. 
import ErrorComponent                               from '../../../components/ErrorComponent'       ;
import DumpSQL                                      from '../../../components/DumpSQL'              ;
import DynamicButtons                               from '../../../components/DynamicButtons'       ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';

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
	ATTACHMENTS?         : any[];
	editedItem        : any;
	dependents        : Record<string, Array<any>>;
	error?            : any;
}

@observer
export default class WorkflowAlertTemplatesEditView extends React.Component<IAdminEditViewProps, IAdminEditViewState>
{
	private _isMounted   : boolean = false;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons = React.createRef<HeaderButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();

	public get data (): any
	{
		let row: any = {};
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
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

	constructor(props: IAdminEditViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		let EDIT_NAME = props.MODULE_NAME + '.EditView';
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
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
			editedItem       : null,
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
	
	private loadWorkflowRelated = async (sBASE_MODULE: string) =>
	{
		try
		{
			let res  = await CreateSplendidRequest('Administration/Workflows/Rest.svc/GetRelatedModules?BASE_MODULE=' + sBASE_MODULE, 'GET');
			let json = await GetSplendidResult(res);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadWorkflowRelated', json);
			if ( json.d != null && json.d.results != null )
			{
				let arrListValues = [];
				for ( let i: number = 0; i < json.d.results.length; i++ )
				{
					let row: any = json.d.results[i];
					// 11/25/2008 Paul.  Only show one-to-many as we can only lookup one value. 
					// RELATIONSHIP_MANY = 0
					if ( !Sql.ToBoolean(row['RELATIONSHIP_MANY']) )
					{
						arrListValues.push(row['MODULE_NAME']);
						SplendidCache.SetListTerm('WorkflowRelated', row['MODULE_NAME'], row['DISPLAY_NAME'] );
					}
				}
				SplendidCache.SetTerminologyList('WorkflowRelated', arrListValues);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private loadWorkflowColumns = async (sMODULE_NAME: string) =>
	{
		try
		{
			let res  = await CreateSplendidRequest('Administration/Workflows/Rest.svc/WorkflowFilterColumns?MODULE_NAME=' + sMODULE_NAME, 'GET');
			let json = await GetSplendidResult(res);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadWorkflowColumns', json);
			if ( json.d != null && json.d.results != null )
			{
				let arrListValues = [];
				arrListValues.push('href_link');
				SplendidCache.SetListTerm('WorkflowColumns', 'href_link', L10n.Term('WorkflowAlertTemplates.LBL_LINK_TO_RECORD') );
				for ( let i: number = 0; i < json.d.results.length; i++ )
				{
					let row: any = json.d.results[i];
					arrListValues.push(row['ColumnName']);
					SplendidCache.SetListTerm('WorkflowColumns', row['ColumnName'], row['DISPLAY_NAME'] );
				}
				SplendidCache.SetTerminologyList('WorkflowColumns', arrListValues);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private load = async () =>
	{
		const { MODULE_NAME, ID, rowDefaultSearch, DuplicateID } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			let res  = await CreateSplendidRequest('Administration/Workflows/Rest.svc/GetWorkflowModules', 'GET');
			let json = await GetSplendidResult(res);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', json);
			if ( json.d != null && json.d.results != null )
			{
				let arrListValues = [];
				for ( let i: number = 0; i < json.d.results.length; i++ )
				{
					let row: any = json.d.results[i];
					arrListValues.push(row['MODULE_NAME']);
					SplendidCache.SetListTerm('WorkflowModules', row['MODULE_NAME'], row['DISPLAY_NAME'] );
				}
				SplendidCache.SetTerminologyList('WorkflowModules', arrListValues);
				if ( json.d.results.length > 0 )
				{
					let row: any = json.d.results[0];
					let BASE_MODULE: string = row['MODULE_NAME'];
					await this.loadWorkflowRelated(BASE_MODULE);
					await this.loadWorkflowColumns(BASE_MODULE);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
		try
		{
			const layout = EditView_LoadLayout(EDIT_NAME);
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
						this.props.onLayoutLoaded();
					}
				});
				if ( !Sql.IsEmptyString(DuplicateID) )
				{
					await this.LoadItem(MODULE_NAME, DuplicateID);
				}
				else
				{
					await this.LoadItem(MODULE_NAME, ID);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private LoadItem = async (sMODULE_NAME: string, sID: string) =>
	{
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(sMODULE_NAME, sID, true);
				let item: any = d.results;
				let ATTACHMENTS       : any[] = null;
				let LAST_DATE_MODIFIED: Date = null;
				// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
				if ( item != null && item['DATE_MODIFIED'] !== undefined )
				{
					LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
				}
				if ( item != null )
				{
					let BASE_MODULE: string = item['BASE_MODULE'];
					await this.loadWorkflowRelated(BASE_MODULE);
					await this.loadWorkflowColumns(BASE_MODULE);
					item.VariableText = this.BuildVariableText(BASE_MODULE, null, 'href_link', null);
					item.VariableType = 'future';
				}
				if ( this._isMounted )
				{
					ATTACHMENTS = item.ATTACHMENTS;
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState(
					{
						item              ,
						SUB_TITLE         ,
						ATTACHMENTS       ,
						__sql             : d.__sql,
						LAST_DATE_MODIFIED,
					});
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
		}
		else
		{
			let arrWorkflowModules = SplendidCache.TerminologyList('WorkflowModules');
			if ( arrWorkflowModules != null && arrWorkflowModules.length > 0 )
			{
				let BASE_MODULE: string = arrWorkflowModules[0];

				let item: any = {};
				item.BASE_MODULE  = BASE_MODULE;
				item.VariableText = this.BuildVariableText(BASE_MODULE, null, 'href_link', null);
				item.VariableType = 'future';
				this.setState(
				{
					item
				});
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

	private BuildVariableText = (BASE_MODULE: string, RELATED: string, VariableName: string, VariableType: string) =>
	{
		let VariableText: string = '';
		if ( !Sql.IsEmptyString(RELATED) )
		{
			if ( VariableName == 'href_link' )
			{
				VariableText = '{::href_link::' + BASE_MODULE + '::' + RELATED + '::href_link::}';
			}
			else
			{
				VariableText = '{::' + VariableType + '::' + BASE_MODULE + '::' + RELATED + '::' + VariableName.toLowerCase() + '::}';
			}
		}
		else
		{
			if ( VariableName == 'href_link' )
			{
				VariableText = '{::href_link::' + BASE_MODULE + '::href_link::}';
			}
			else
			{
				VariableText = '{::' + VariableType + '::' + BASE_MODULE + '::' + VariableName.toLowerCase() + '::}';
			}
		}
		return VariableText;
	}

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
		const { editedItem } = this.state;
		const currentItem = Object.assign({}, this.state.item, editedItem);
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
		if ( PARENT_FIELD == 'BASE_MODULE' )
		{
			this.loadWorkflowColumns(DATA_VALUE).then(() =>
			{
				let ref = this.refMap['VariableName'];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, 'WorkflowColumns', 'list', item);
				}
				ref = this.refMap['VariableText'];
				if ( ref )
				{
					let VariableText: string = this.BuildVariableText(DATA_VALUE, null, 'href_link', null);
					ref.current.updateDependancy(PARENT_FIELD, VariableText, 'value', item);
					this._onChange('VariableText', VariableText);
				}
			})
			.catch((error) =>
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
			});
			this.loadWorkflowRelated(DATA_VALUE).then(() =>
			{
				let ref = this.refMap['RELATED'];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, 'WorkflowRelated', 'list', item);
				}
			})
			.catch((error) =>
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
			});
		}
		else if ( PARENT_FIELD == 'RELATED' )
		{
			if ( !Sql.IsEmptyString(DATA_VALUE) )
			{
				this.loadWorkflowColumns(DATA_VALUE).then(() =>
				{
					let ref = this.refMap['VariableName'];
					if ( ref )
					{
						ref.current.updateDependancy(PARENT_FIELD, 'WorkflowColumns', 'list', item);
					}
					ref = this.refMap['VariableText'];
					if ( ref )
					{
						let VariableText: string = this.BuildVariableText(currentItem['BASE_MODULE'], DATA_VALUE, 'href_link', null);
						ref.current.updateDependancy(PARENT_FIELD, VariableText, 'value', item);
						this._onChange('VariableText', VariableText);
					}
				})
				.catch((error) =>
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
				});
			}
			else
			{
				this.loadWorkflowColumns(currentItem['BASE_MODULE']).then(() =>
				{
					let ref = this.refMap['VariableName'];
					if ( ref )
					{
						ref.current.updateDependancy(PARENT_FIELD, 'WorkflowColumns', 'list', item);
					}
					ref = this.refMap['VariableText'];
					if ( ref )
					{
						let VariableText: string = this.BuildVariableText(currentItem['BASE_MODULE'], null, 'href_link', null);
						ref.current.updateDependancy(PARENT_FIELD, VariableText, 'value', item);
						this._onChange('VariableText', VariableText);
					}
				})
				.catch((error) =>
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
				});
			}
		}
		else if ( PARENT_FIELD == 'VariableName' )
		{
			let VariableType: string = 'future';
			let VariableName: string = DATA_VALUE;
			let ref = this.refMap['VariableType'];
			if ( ref )
			{
				VariableType = ref.current.data.value;
			}
			ref = this.refMap['VariableText'];
			if ( ref )
			{
				let VariableText: string = this.BuildVariableText(currentItem['BASE_MODULE'], currentItem['RELATED'], VariableName, VariableType);
				ref.current.updateDependancy(PARENT_FIELD, VariableText, 'value', item);
				this._onChange('VariableText', DATA_VALUE);
			}
		}
		else if ( PARENT_FIELD == 'VariableType' )
		{
			let VariableType: string = DATA_VALUE;
			let VariableName: string = '';
			let ref = this.refMap['VariableName'];
			if ( ref )
			{
				VariableName = ref.current.data.value;
			}
			ref = this.refMap['VariableText'];
			if ( ref )
			{
				let VariableText: string = this.BuildVariableText(currentItem['BASE_MODULE'], currentItem['RELATED'], VariableName, VariableType);
				ref.current.updateDependancy(PARENT_FIELD, VariableText, 'value', item);
				this._onChange('VariableText', VariableText);
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
		const { ID, MODULE_NAME, history, location } = this.props;
		const { LAST_DATE_MODIFIED, item, editedItem } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveNew':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					row = {
						ID: isDuplicate ? null : ID
					};
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
					if ( nInvalidFields == 0 )
					{
						if ( this.state.ATTACHMENTS && this.state.ATTACHMENTS.length > 0 )
						{
							row.ATTACHMENTS = this.state.ATTACHMENTS;
						}
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
							row.ID = await UpdateModule(MODULE_NAME, row, isDuplicate ? null : ID, true);
							// 02/22/2021 Paul.  A number of admin modules support SaveNew.
							if ( sCommandName == 'SaveNew' )
							{
								history.push(`/Reset/Administration/${MODULE_NAME}/Edit/`);
							}
							else
							{
								history.push(`/Reset/Administration/${MODULE_NAME}/View/` + row.ID);
							}
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
					if ( Sql.IsEmptyString(ID) )
						history.push(`/Reset/Administration/${MODULE_NAME}/List`);
					else
						history.push(`/Reset/Administration/${MODULE_NAME}/View/${ID}`);
					break;
				}
				case 'InsertVariable':
				{
					let ref = this.refMap['VariableText'];
					if ( ref )
					{
						let VariableText: string = ref.current.data.value;
						if ( !Sql.IsEmptyString(VariableText) )
						{
							let ref = this.refMap['BODY_HTML'];
							if ( ref )
							{
								ref.current.updateDependancy('VariableText', VariableText, 'insert', null);
							}
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

	private _onAddAttachment = () =>
	{
		let { ATTACHMENTS } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onAddAttachment');
		if ( !ATTACHMENTS )
		{
			ATTACHMENTS = [];
		}
		ATTACHMENTS.push({});
		this.setState({ ATTACHMENTS });
	}

	private _onAttachment = (e, index) =>
	{
		let { ATTACHMENTS } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onAttachment', index);
		try
		{
			let FILE_NAME: string = e.target.value;
			let files = e.target.files;
			if ( files.length > 0 )
			{
				let file = files[0];
				let nMaxSize: number = Crm_Config.ToInteger('upload_maxsize');
				if ( file.size > nMaxSize )
				{
					let error = 'uploaded file was too big: max filesize: ' + nMaxSize;
					this.setState({ error });
				}
				else
				{
					// http://www.javascripture.com/FileReader
					let reader = new FileReader();
					reader.onload = () =>
					{
						let arrayBuffer = reader.result;
						let NAME     : string = file.name;
						let TYPE     : string = file.type;
						let DATA     : string = base64ArrayBuffer(arrayBuffer);
						
						let image: any = new Object();
						let arrFileParts = NAME.split('.');
						image.FILENAME       = NAME;
						image.FILE_EXT       = arrFileParts[arrFileParts.length - 1];
						image.FILE_MIME_TYPE = TYPE;
						image.FILE_DATA      = DATA;
						ATTACHMENTS[index] = image;
						this.setState({ ATTACHMENTS });
					};
					reader.readAsArrayBuffer(file);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onAttachment', error);
		}
	}

	private _onRemoveAttachment = (e, index) =>
	{
		let { ATTACHMENTS } = this.state;
		if ( ATTACHMENTS && index < ATTACHMENTS.length )
		{
			if ( ATTACHMENTS[index].ID )
			{
				ATTACHMENTS[index].deleted = true;
			}
			else
			{
				ATTACHMENTS.splice(index, 1);
			}
			this.setState({ ATTACHMENTS });
		}
	}

	public render()
	{
		const { MODULE_NAME, ID, DuplicateID, callback } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, ATTACHMENTS, error } = this.state;
		const { __total, __sql } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME, layout, item);
		// 09/09/2019 Paul.  We need to wait until item is loaded, otherwise fields will not get populated. 
		//if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) || !Sql.IsEmptyString(DuplicateID))) )
		// 03/12/2021 Paul.  item is always initialized. 
		if ( layout == null || item == null )
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
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<div>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				<div id={!!callback ? null : "content"}>
					{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, 'tabForm', this.Page_Command) }
					<div className='tabForm'>
						<div className='tabEditView' style={ {display: 'flex', flexFlow: 'row wrap', width: '100%'} }>
							<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 100%'} }>
								<div id='ctlEditView_Emails_EditView_ATTACHMENTS_LABEL' className='dataLabel' style={ {width: '15%'} }>
									{ L10n.Term('Emails.LBL_ATTACHMENTS') }
								</div>
								<div id='ctlEditView_Emails_EditView_ATTACHMENTS' className='dataField' style={ {width: '85%'} }>
									{ ATTACHMENTS
									? ATTACHMENTS.map((attachment, index) => 
									{
										if ( attachment.deleted )
										{
											return null;
										}
										else if ( attachment.NOTE_ATTACHMENT_ID )
										{
											return (
											<div>
												<a
													id={ attachment.NOTE_ATTACHMENT_ID }
													key={ attachment.NOTE_ATTACHMENT_ID }
													href={ Credentials.RemoteServer + 'Notes/Attachment.aspx?ID=' + attachment.NOTE_ATTACHMENT_ID }
													target='_blank'
												>
													{ attachment.FILENAME }
												</a>
												<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onRemoveAttachment(e, index) }>
													<FontAwesomeIcon icon='minus' size='lg' style={ {marginLeft: '4px'} } />
												</span>
											</div>);
										}
										else if ( attachment.FILENAME === undefined )
										{
											return (
											<div>
												<input
													type='file'
													onChange={ (e) => this._onAttachment(e, index) }
												/>
											</div>);
										}
										else
										{
											return (
											<div>
												<span
													id={ 'newAttachment_' + index }
													key={ 'newAttachment_' + index }
												>
													{ attachment.FILENAME }
												</span>
												<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onRemoveAttachment(e, index) }>
													<FontAwesomeIcon icon='minus' size='lg' style={ {marginLeft: '4px'} } />
												</span>
											</div>);
										}
									})
									: null
									}
									<div>
										<button className='button' onClick={ this._onAddAttachment }>{ L10n.Term('Emails.LBL_ADD_FILE') }</button>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
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

