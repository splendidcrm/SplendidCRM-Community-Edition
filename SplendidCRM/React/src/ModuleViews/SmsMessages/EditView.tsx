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
import * as qs from 'query-string';
import { RouteComponentProps, withRouter }          from 'react-router-dom'                                ;
import { observer }                                 from 'mobx-react'                                      ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'                  ;
// 2. Store and Types. 
import { EditComponent }                            from '../../types/EditComponent'                       ;
import { HeaderButtons }                            from '../../types/HeaderButtons'                       ;
import EDITVIEWS_FIELD                              from '../../types/EDITVIEWS_FIELD'                     ;
// 3. Scripts. 
import Sql                                          from '../../scripts/Sql'                               ;
import L10n                                         from '../../scripts/L10n'                              ;
import Security                                     from '../../scripts/Security'                          ;
import Credentials                                  from '../../scripts/Credentials'                       ;
import SplendidCache                                from '../../scripts/SplendidCache'                     ;
import SplendidDynamic_EditView                     from '../../scripts/SplendidDynamic_EditView'          ;
import { FormatEmailDisplayName }                   from '../../scripts/EmailUtils'                        ;
import { Crm_Config, Crm_Modules }                  from '../../scripts/Crm'                               ;
import { NormalizeDescription, XssFilter }          from '../../scripts/EmailUtils'                        ;
import { Trim, StartsWith }                         from '../../scripts/utility'                           ;
import { FromJsonDate }                             from '../../scripts/Formatting'                        ;
import { base64ArrayBuffer }                        from '../../scripts/utility'                           ;
import { AuthenticatedMethod, LoginRedirect }       from '../../scripts/Login'                             ;
import { sPLATFORM_LAYOUT }                         from '../../scripts/SplendidInitUI'                    ;
import { EditView_LoadItem, EditView_LoadLayout, EditView_HideField }   from '../../scripts/EditView'      ;
import { UpdateModule }                             from '../../scripts/ModuleUpdate'                      ;
import { CreateSplendidRequest, GetSplendidResult } from '../../scripts/SplendidRequest'                   ;
import { jsonReactState }                           from '../../scripts/Application'                       ;
// 4. Components and Views. 
import ErrorComponent                               from '../../components/ErrorComponent'                 ;
import DumpSQL                                      from '../../components/DumpSQL'                        ;
import DynamicButtons                               from '../../components/DynamicButtons'                 ;
import HeaderButtonsFactory                         from '../../ThemeComponents/HeaderButtonsFactory'      ;
import PopupSmsNumbers                              from './PopupSmsNumbers'                               ;

const MODULE_NAME: string = 'SmsMessages';

interface IEditViewProps extends RouteComponentProps<any>
{
	ID?                : string;
	LAYOUT_NAME        : string;
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
	MODULE_TITLE         : string;
	REQUEST_TYPE         : string;
	SMS_TYPE             : string;
	EDIT_NAME            : string;
	DUPLICATE            : boolean;
	LAST_DATE_MODIFIED   : Date;
	SUB_TITLE            : any;
	ATTACHMENTS?         : any[];
	READ_ONLY?           : boolean;
	editedItem           : any;
	dependents           : Record<string, Array<any>>;
	error                : any;
	popupOpen            : boolean;
	addressFields        : string;
}

// 09/18/2019 Paul.  Give class a unique name so that it can be debugged.  Without the unique name, Chrome gets confused.
@observer
export default class SmsMessagesEditView extends React.Component<IEditViewProps, IEditViewState>
{
	private _isMounted   : boolean = false;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons = React.createRef<HeaderButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private PARENT_ID    : string = null;
	private PARENT_TYPE  : string = null;
	private SAVED_ID     : string = null;

	public get data (): any
	{
		let row: any = {};
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
		let item = (props.rowDefaultSearch ? props.rowDefaultSearch : null);
		let EDIT_NAME = MODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
		// 08/11/2020 Paul.  SmsMessages.EditView.Inline is not supported 
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) && props.LAYOUT_NAME != 'SmsMessages.EditView.Inline' )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		this.state =
		{
			__total           : 0,
			__sql             : null,
			item              ,
			layout            : null,
			MODULE_TITLE      : null,
			REQUEST_TYPE      : null,
			SMS_TYPE          : 'draft',
			EDIT_NAME         ,
			DUPLICATE         : false,
			LAST_DATE_MODIFIED: null,
			SUB_TITLE         : null,
			editedItem        : null,
			dependents        : {},
			error             : null,
			popupOpen         : false,
			addressFields     : null,
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
				if ( jsonReactState == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount jsonReactState is null');
				}
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
					if ( jsonReactState == null )
					{
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount jsonReactState is null');
					}
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
		const { ID, DuplicateID } = this.props;
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
				this.PARENT_ID   = Sql.ToString(queryParams['PARENT_ID']);
				this.PARENT_TYPE = await Crm_Modules.ParentModule(this.PARENT_ID);
				if ( !Sql.IsEmptyString(this.PARENT_TYPE) )
				{
					rowDefaultSearch = await Crm_Modules.LoadParent(this.PARENT_TYPE, this.PARENT_ID);
					if ( rowDefaultSearch === undefined || rowDefaultSearch == null )
					{
						rowDefaultSearch = {};
					}
					bParentFound = true;
					if ( this.PARENT_TYPE == 'Cases' )
					{
						let sMacro: string = Crm_Config.ToString('inbound_email_case_subject_macro');
						if ( !Sql.IsEmptyString(sMacro) )
						{
							sMacro = '[CASE:%1]';
						}
						rowDefaultSearch['NAME'] = sMacro.replace('%1', this.PARENT_ID);
					}
					else if ( this.PARENT_TYPE == "Contacts" || this.PARENT_TYPE == "Leads" || this.PARENT_TYPE == "Prospects" || this.PARENT_TYPE == "Users" )
					{
						// 05/13/2008 Paul.  Prepopulate the TO field for Accounts, Contacts, Leads, Prospects and Users.  All of these modules have an EMAIL1 field. 
						// 09/05/2008 Paul.  Prepopulate with any email supported by vwQUEUE_EMAIL_ADDRESS.  
						// 08/05/2006 Paul.  When an email is composed from a Lead, automatically set the To address. 
						let PARENT_TABLE      = Crm_Modules.TableName(this.PARENT_TYPE);
						let obj = new Object();
						obj['TableName'    ] = 'vw' + PARENT_TABLE + '_SmsNumbers';
						obj['$orderby'     ] = 'NAME asc';
						obj['$select'      ] = 'ID,NAME,PHONE_MOBILE';
						obj['$filter'      ] = 'PARENT_ID eq \'' + this.PARENT_ID + '\'';
						let sBody: string = JSON.stringify(obj);
						let res  = await CreateSplendidRequest('Rest.svc/PostModuleTable', 'POST', 'application/octet-stream', sBody);
						let json = await GetSplendidResult(res);
						if ( json.d.results != null )
						{
							rowDefaultSearch['TO_NUMBER'   ] = '';
							rowDefaultSearch['TO_NUMBER_ID'] = '';
							if ( json.d.results.length > 0 )
							{
								let item: any = json.d.results[0];
								rowDefaultSearch['TO_NUMBER'   ] = item['PHONE_MOBILE'];
								rowDefaultSearch['TO_NUMBER_ID'] = item['ID'          ];
							}
						}
					}
					// 03/19/2021 Paul.  If we initialize rowDefaultSearch, then we need to set assigned and team values. 
					if ( !bParentFound || !Crm_Config.ToBoolean('inherit_assigned_user') )
					{
						rowDefaultSearch['ASSIGNED_SET_LIST'] = Security.USER_ID()  ;
						rowDefaultSearch['ASSIGNED_USER_ID' ] = Security.USER_ID()  ;
						rowDefaultSearch['ASSIGNED_TO'      ] = Security.USER_NAME();
						rowDefaultSearch['ASSIGNED_TO_NAME' ] = Security.FULL_NAME();
					}
					if ( !bParentFound || !Crm_Config.ToBoolean('inherit_team') )
					{
						rowDefaultSearch['TEAM_ID'          ] = Security.TEAM_ID()  ;
						rowDefaultSearch['TEAM_NAME'        ] = Security.TEAM_NAME();
						rowDefaultSearch['TEAM_SET_LIST'    ] = Security.TEAM_ID()  ;
						rowDefaultSearch['TEAM_SET_NAME'    ] = Security.TEAM_ID()  ;
					}
				}
				else
				{
					this.setState( {error: 'Parent ID [' + this.PARENT_ID + '] was not found.'} );
				}
			}
			// 03/01/2021 Paul.  Need to initialize old signature value. 
			let REQUEST_TYPE: string = null;
			let SMS_TYPE    : string = 'draft';
			queryParams = qs.parse(location.search.toLowerCase());
			if ( !Sql.IsEmptyString(queryParams['type']) )
			{
				REQUEST_TYPE = Sql.ToString(queryParams['type']);
				SMS_TYPE     = Sql.ToString(queryParams['type']);
				if ( SMS_TYPE != 'archived' )
					SMS_TYPE = "draft";
			}
			let MODULE_TITLE: string = (SMS_TYPE != 'archived' ? L10n.Term('SmsMessages.LBL_NEW_FORM_TITLE') : L10n.Term('SmsMessages.LBL_ARCHIVED_MODULE_NAME'));
			let layout = EditView_LoadLayout(EDIT_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			if ( this._isMounted )
			{
				if ( !Sql.IsEmptyString(ID) && Sql.IsEmptyString(DuplicateID) )
				{
					if ( SMS_TYPE == 'archived' )
						EditView_HideField(layout, 'DATE_START', true);
					if ( SMS_TYPE != 'draft' )
						EditView_HideField(layout, 'MAILBOX_ID', true);
				}
				this.SMS_TYPE_Changed(SMS_TYPE, layout);
				this.setState(
				{
					layout            : layout,
					item              : (rowDefaultSearch ? rowDefaultSearch : null),
					MODULE_TITLE      ,
					REQUEST_TYPE      ,
					SMS_TYPE          ,
					editedItem        : null
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
		const { callback, isSearchView, isUpdatePanel } = this.props;
		// 03/01/2021 Paul.  Need to initialize old signature value. 
		let { layout, MODULE_TITLE } = this.state;
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(sMODULE_NAME, sID);
				let item: any = d.results;
				let sRequestType: string = null;
				let queryParams = qs.parse(location.search.toLowerCase());
				if ( !Sql.IsEmptyString(queryParams['type']) )
				{
					sRequestType = Sql.ToString(queryParams['type']);
				}
				if ( this._isMounted )
				{
					let ATTACHMENTS       : any[] = null;
					let LAST_DATE_MODIFIED: Date = null;
					let SMS_TYPE          : string = this.state.SMS_TYPE;
					if ( item )
					{
						// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
						if ( item['DATE_MODIFIED'] !== undefined )
						{
							LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
						}
						SMS_TYPE = Sql.ToString(item['TYPE']).toLowerCase();
						let sSMS_STATUS: string = Sql.ToString(item['STATUS']).toLowerCase();
						// 06/30/2007 Paul.  A forward or reply is just like a draft. 
						if ( sRequestType == 'forward' || sRequestType == 'reply' || sRequestType == 'replyall' )
						{
							let sFROM_NUMBER: string = Sql.ToString(item['FROM_NUMBER']);
							
							SMS_TYPE = 'draft';
							item['ASSIGNED_TO'     ] = Security.USER_NAME();
							item['ASSIGNED_USER_ID'] = Security.USER_ID();
							if ( sRequestType == 'forward' )
							{
								item['TO_NUMBER'       ] = '';
							}
							else if ( sRequestType == 'reply' )
							{
								item['TO_NUMBER'       ] = sFROM_NUMBER;
							}
							else if ( sRequestType == 'replyall' )
							{
								item['TO_NUMBER'       ] = sFROM_NUMBER;
							}
							item['DATE_START'     ] = null;
							if ( Sql.ToString(item['PARENT_TYPE']) == 'Cases' )
							{
								let gPARENT_ID: string = Sql.ToGuid(item['PARENT_ID']);
								let sMacro    : string = Crm_Config.ToString('inbound_email_case_subject_macro').replace('%1', gPARENT_ID);
								let sNAME     : string = Sql.ToString(item['NAME']);
								if ( !sNAME.toLowerCase().indexOf(sMacro.toLowerCase()) )
								{
									if (sNAME.length + sMacro.length + 1 > 200 )
									{
										// 04/10/2013 Paul.  Truncate the name if greater than 200 so that there is enough space for RE:
										sNAME = sNAME.substr(0, 200 - sMacro.length);
									}
									item['NAME'] = sNAME + ' ' + sMacro;
								}
							}
							// 04/10/2013 Paul.  Another option is for the email to be simply associated to a Case (not the parent).  A reply should use the CASE_ID. 
							else if ( !Sql.IsEmptyString(Request['CASE_ID']) )
							{
								let gPARENT_ID: string = Sql.ToGuid(Request['CASE_ID']);
								let sMacro    : string = Crm_Config.ToString('inbound_email_case_subject_macro').replace('%1', gPARENT_ID);
								let sNAME     : string = Sql.ToString(item['NAME']);
								if ( !sNAME.toLowerCase().indexOf(sMacro.toLowerCase()) )
								{
									if (sNAME.length + sMacro.length + 1 > 200 )
									{
										// 04/10/2013 Paul.  Truncate the name if greater than 200 so that there is enough space for RE:
										sNAME = sNAME.substr(0, 200 - sMacro.length);
									}
									item['NAME'] = sNAME + ' ' + sMacro;
								}
							}
						}
						// 04/29/2011 Paul.  Forward should include attachments. 
						// 09/25/2013 Paul.  Include attachments when duplicating. 
						// 03/11/2021 Paul.  RequestType null for an unsent email. 
						if ( sRequestType == null || sRequestType == 'forward' || sRequestType == 'reply_attachments' || !Sql.IsEmptyGuid(this.props.DuplicateID) )
						{
							ATTACHMENTS = item.ATTACHMENTS;
						}
						else
						{
							item.ATTACHMENTS = null;
						}
						// 12/20/2006 Paul.  Editing is not allowed for sent emails. 
						// 01/13/2008 Paul.  Editing is not allowed for campaign emails. 
						// 01/13/2008 Paul.  Editing is not allowed for inbound emails, and they have their own viewer. 
						// 05/15/2008 Paul.  Allow editing of an email that previously generated a send_error. 
						if ( ( SMS_TYPE == 'out' && sSMS_STATUS == 'draft') || SMS_TYPE == 'sent' || SMS_TYPE == 'campaign' || SMS_TYPE == 'inbound' )
						{
							// 01/21/2006 Paul.  Editing is not allowed for sent emails. 
							// 04/16/2021 Paul.  Do not redirect during precompile as it stops it. 
							if ( !this.props.isPrecompile )
							{
								this.props.history.push(`/Reset/${MODULE_NAME}/View/${sID}`);
								return;
							}
						}
						switch ( SMS_TYPE )
						{
							case 'archived':
								MODULE_TITLE  = L10n.Term('SmsMessages.LBL_ARCHIVED_MODULE_NAME');
								break;
							case 'out'     :
								MODULE_TITLE  = L10n.Term('SmsMessages.LBL_LIST_FORM_SENT_TITLE');
								break;
							default        :
								MODULE_TITLE  = L10n.Term('SmsMessages.LBL_NEW_FORM_TITLE' );
								break;
						}
					}
					this.SMS_TYPE_Changed(SMS_TYPE, layout);
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState(
					{
						item              ,
						layout            ,
						MODULE_TITLE      ,
						SUB_TITLE         ,
						ATTACHMENTS       ,
						__sql             : d.__sql,
						LAST_DATE_MODIFIED,
						SMS_TYPE          ,
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
			Sql.SetPageTitle(sMODULE_NAME, null, null);
		}
	}

	private SMS_TYPE_Changed = (SMS_TYPE: string, layout: EDITVIEWS_FIELD[]) =>
	{
		if ( layout && layout.length > 0 )
		{
			for ( let i = 0; i < layout.length; i++ )
			{
				let lay: EDITVIEWS_FIELD = layout[i];
				if ( lay.DATA_FIELD == 'MAILBOX_ID' )
				{
					if ( SMS_TYPE == 'archived' )
					{
						lay.hidden        = true ;
						lay.UI_REQUIRED   = false;
						lay.DATA_REQUIRED = false;
					}
					else if ( Crm_Config.ToBoolean('SmsMessages.RequireSelectMailbox') )
					{
						lay.hidden        = false;
						lay.UI_REQUIRED   = true ;
						lay.DATA_REQUIRED = true ;
						lay.DATA_FORMAT   = 'force';
					}
				}
				else if ( lay.DATA_FIELD == 'DATE_START' )
				{
					lay.hidden        = (SMS_TYPE != 'archived');
					lay.UI_REQUIRED   = !lay.hidden;
					lay.DATA_REQUIRED = !lay.hidden;
				}
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
		let { editedItem } = this.state;
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
		const { LAST_DATE_MODIFIED, editedItem, SMS_TYPE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Send':
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					row = {
						ID: isDuplicate ? null : ID
					};
					// 01/24/2021 Paul.  In case of send failure, make sure to reuse the new ID. 
					if ( !Sql.IsEmptyString(this.SAVED_ID) )
					{
						row.ID = this.SAVED_ID;
					}
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
					if ( nInvalidFields == 0 )
					{
						if ( sCommandName == 'Send' )
						{
							// 01/21/2006 Paul.  Mark an email as ready-to-send.   Type becomes "out" and Status stays at "draft". 
							// 01/24/2021 Paul.  SMS_TYPE is a state variable, not a record value. 
							if ( SMS_TYPE == 'draft' )
								row['TYPE'] = 'out';
							// 01/21/2006 Paul.  Address error only when sending. 
							if ( Sql.IsEmptyString(row['TO_NUMBER']) )
							{
								this.setState({ error: L10n.Term('SmsMessages.ERR_NOT_ADDRESSED') });
								return;
							}
						}
						if ( this.state.ATTACHMENTS && this.state.ATTACHMENTS.length > 0 )
						{
							row.ATTACHMENTS = this.state.ATTACHMENTS;
						}
						// 11/20/2005 Paul.  SugarCRM 3.5.1 lets bad data flow through.  We clear the hidden values if the visible values are empty. 
						// There still is the issue of the data getting out of sync if the user manually edits the visible values. 
						// 03/11/2021 Paul.  Build current item in case record not edited. 
						let currentItem = Object.assign({}, this.state.item, this.state.editedItem);
						row['TO_NUMBER'    ] = currentItem['TO_NUMBER'    ];
						// 07/21/2013 Paul.  From values will come from mailbox. 
						row['FROM_NUMBER'] = null;
						let mailbox: any = SplendidCache.GetOutboundSms(row['MAILBOX_ID']);
						if ( mailbox )
						{
							row['FROM_NUMBER'] = Sql.ToString(mailbox['FROM_NUMBER']);
						}

						if ( LAST_DATE_MODIFIED != null )
						{
							row['LAST_DATE_MODIFIED'] = LAST_DATE_MODIFIED;
						}
						if ( sCommandName == 'SaveDuplicate' || sCommandName == 'SaveConcurrency' )
						{
							row[sCommandName] = true;
						}
						// 01/24/2021 Paul.  Status will be updated after sending, but we may have issues with concurrency that we want to ignore. 
						row['SaveConcurrency'] = true;
						try
						{
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.Busy();
							}
							row.ID = await UpdateModule(MODULE_NAME, row, isDuplicate ? null : ID);
							this.SAVED_ID = row.ID;
							// 01/24/2021 Paul.  Allow SendEmail from React Client. 
							if ( sCommandName == 'Send' )
							{
								let d: any = await EditView_LoadItem(MODULE_NAME, this.SAVED_ID);
								let item: any = d.results;
								if ( item != null )
								{
									// 01/23/2021 Paul.  Update the last modified to prevent a concurrency error if the user tries to save again. 
									let LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
									let error: string = Sql.ToString(item['STATUS']) + ', ' + Sql.ToString(item['TYPE']);
									this.setState({ item, LAST_DATE_MODIFIED, error });
									let obj: any =
									{
										ID: this.SAVED_ID
									};
									let sBody: string = JSON.stringify(obj);
									let res = await CreateSplendidRequest('Rest.svc/SendText', 'POST', 'application/json; charset=utf-8', sBody);
									let json = await GetSplendidResult(res);
									if ( json.d == 'sent' )
									{
										// 10/15/2019 Paul.  Redirect to parent if provided. 
										if ( !Sql.IsEmptyGuid(this.PARENT_ID) )
										{
											history.push(`/Reset/${this.PARENT_TYPE}/View/${this.PARENT_ID}`);
										}
										else
										{
											history.push(`/Reset/${MODULE_NAME}/View/` + this.SAVED_ID);
										}
									}
									else
									{
										if ( this.headerButtons.current != null )
										{
											this.headerButtons.current.NotBusy();
										}
										this.setState({ item, LAST_DATE_MODIFIED, error: json.d });
									}
								}
								else
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.NotBusy();
									}
									this.setState({ error: 'Could not retrieve saved record: ' + this.SAVED_ID });
								}
							}
							else
							{
								// 10/15/2019 Paul.  Redirect to parent if provided. 
								if ( !Sql.IsEmptyGuid(this.PARENT_ID) )
								{
									history.push(`/Reset/${this.PARENT_TYPE}/View/${this.PARENT_ID}`);
								}
								else
								{
									history.push(`/Reset/${MODULE_NAME}/View/` + this.SAVED_ID);
								}
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
					// 10/15/2019 Paul.  Redirect to parent if provided. 
					if ( !Sql.IsEmptyGuid(this.PARENT_ID) )
					{
						history.push(`/Reset/${this.PARENT_TYPE}/View/${this.PARENT_ID}`);
					}
					else if ( Sql.IsEmptyString(ID) )
					{
						history.push(`/Reset/${MODULE_NAME}/List`);
					}
					else
					{
						history.push(`/Reset/${MODULE_NAME}/View/${ID}`);
					}
					break;
				}
				case 'SmsAddressesPopup':
				{
					this.setState({ popupOpen: true, addressFields: sCommandArguments });
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

	private UpdateDependancy(DATA_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any)
	{
		let ref = this.refMap[DATA_FIELD];
		if ( ref && ref.current )
		{
			ref.current.updateDependancy(null, DATA_VALUE, PROPERTY_NAME, item);
		}
	}

	private _onSelect = (value: { Action: string, ID: string, NAME: string, PHONE_MOBILE: string }) =>
	{
		const { addressFields } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', value);
		if ( value.Action == 'SingleSelect' )
		{
			let currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			let error: any = null;
			if ( Sql.IsEmptyGuid(value.ID) )
			{
				currentItem['TO_NUMBER'   ] = null;
				currentItem['TO_NUMBER_ID'] = null;
				this.UpdateDependancy('TO_NUMBER', '', 'value');
			}
			else
			{
				currentItem['TO_NUMBER'   ] = Sql.ToString(currentItem['TO_NUMBER'   ]) + value.PHONE_MOBILE;
				currentItem['TO_NUMBER_ID'] = Sql.ToString(currentItem['TO_NUMBER_ID']) + value.ID          ;
				this.UpdateDependancy('TO_NUMBER', currentItem['TO_NUMBER'], 'value');
			}
			this.setState({ error, popupOpen: false, editedItem: currentItem }, async () =>
			{
				try
				{
				}
				catch(error)
				{
					this.setState({ error: error });
				}
			});
		}
		else if ( value.Action == 'Close' )
		{
			this.setState({ popupOpen: false });
		}
	}

	private _onButtonsLoaded = async () =>
	{
		const { SMS_TYPE } = this.state;
		let arrMAILBOX_COUNT: string[] = L10n.GetList('OutboundMail');
		// 08/12/2019 Paul.  Here is where we can disable buttons immediately after they were loaded. 
		if ( this.headerButtons.current != null )
		{
			this.headerButtons.current.ShowButton  ('Save', (SMS_TYPE == 'draft' || SMS_TYPE == 'archived'));
			this.headerButtons.current.ShowButton  ('Send', (SMS_TYPE == 'draft'));
			this.headerButtons.current.EnableButton('Send', arrMAILBOX_COUNT && arrMAILBOX_COUNT.length > 0);
		}
		if ( this.dynamicButtonsBottom.current != null )
		{
			this.dynamicButtonsBottom.current.ShowButton  ('Save', (SMS_TYPE == 'draft' || SMS_TYPE == 'archived'));
			this.dynamicButtonsBottom.current.ShowButton  ('Send', (SMS_TYPE == 'draft'));
			this.dynamicButtonsBottom.current.EnableButton('Send', arrMAILBOX_COUNT && arrMAILBOX_COUNT.length > 0);
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
		const { ID, LAYOUT_NAME, DuplicateID, ConvertID, isSearchView, isUpdatePanel, isQuickCreate, callback } = this.props;
		const { item, layout, MODULE_TITLE, EDIT_NAME, SUB_TITLE, ATTACHMENTS, error, popupOpen } = this.state;
		const { __total, __sql } = this.state;
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
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<React.Fragment>
				<PopupSmsNumbers
					isOpen={ popupOpen }
					callback={ this._onSelect }
					MODULE_NAME='Contacts'
				/>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_TITLE, MODULE_NAME, ID, SUB_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: !isSearchView && !isUpdatePanel, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				{ LAYOUT_NAME && LAYOUT_NAME.indexOf('.MassUpdate') < 0
				? <DumpSQL SQL={ __sql } />
				: null
				}
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, (isSearchView || isQuickCreate ? null : 'tabForm'), this.Page_Command, isSearchView) }
				<div className='tabForm'>
					<div className='tabEditView' style={ {display: 'flex', flexFlow: 'row wrap', width: '100%'} }>
						<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 100%'} }>
							<div id='ctlEditView_SmsMessages_EditView_ATTACHMENTS_LABEL' className='dataLabel' style={ {width: '15%'} }>
								{ L10n.Term('SmsMessages.LBL_ATTACHMENT') }
							</div>
							<div id='ctlEditView_SmsMessages_EditView_ATTACHMENTS' className='dataField' style={ {width: '85%'} }>
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
									<button className='button' onClick={ this._onAddAttachment }>{ L10n.Term('SmsMessages.LBL_ADD_FILE') }</button>
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
					onLayoutLoaded={ this._onButtonsLoaded }
					Page_Command={ this.Page_Command }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.dynamicButtonsBottom }
				/>
				: null
				}
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

