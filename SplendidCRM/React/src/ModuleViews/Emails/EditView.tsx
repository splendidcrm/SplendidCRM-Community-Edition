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
import { EditView_LoadItem, EditView_LoadLayout }   from '../../scripts/EditView'                          ;
import { UpdateModule }                             from '../../scripts/ModuleUpdate'                      ;
import { CreateSplendidRequest, GetSplendidResult } from '../../scripts/SplendidRequest'                   ;
import { jsonReactState }                           from '../../scripts/Application'                       ;
// 4. Components and Views. 
import ErrorComponent                               from '../../components/ErrorComponent'                 ;
import DumpSQL                                      from '../../components/DumpSQL'                        ;
import DynamicButtons                               from '../../components/DynamicButtons'                 ;
import HeaderButtonsFactory                         from '../../ThemeComponents/HeaderButtonsFactory'      ;
import PopupEmailAddresses                          from './PopupEmailAddresses'                           ;

const MODULE_NAME: string = 'Emails';

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
	EMAIL_TYPE           : string;
	EDIT_NAME            : string;
	DUPLICATE            : boolean;
	LAST_DATE_MODIFIED   : Date;
	SUB_TITLE            : any;
	NOTE_ID?             : string;
	NOTE_NAME?           : string;
	NOTE_ATTACHMENT_ID?  : string;
	SIGNATURE_HTML?      : string;
	ATTACHMENTS?         : any[];
	KB_ATTACHMENTS?      : any[];
	TEMPLATE_ATTACHMENTS?: any[];
	READ_ONLY?           : boolean;
	editedItem           : any;
	dependents           : Record<string, Array<any>>;
	error                : any;
	popupOpen            : boolean;
	addressFields        : string;
}

// 09/18/2019 Paul.  Give class a unique name so that it can be debugged.  Without the unique name, Chrome gets confused.
@observer
export default class EmailsEditView extends React.Component<IEditViewProps, IEditViewState>
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
		// 08/11/2020 Paul.  Emails.EditView.Inline is not supported 
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) && props.LAYOUT_NAME != 'Emails.EditView.Inline' )
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
			EMAIL_TYPE        : 'draft',
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
					// 05/13/2008 Paul.  Prepopulate the TO field for Accounts, Contacts, Leads, Prospects and Users.  All of these modules have an EMAIL1 field. 
					// 09/05/2008 Paul.  Prepopulate with any email supported by vwQUEUE_EMAIL_ADDRESS.  
					// 08/05/2006 Paul.  When an email is composed from a Lead, automatically set the To address. 
					let obj = new Object();
					obj['TableName'    ] = 'vwQUEUE_EMAIL_ADDRESS';
					obj['$orderby'     ] = 'RECIPIENT_NAME asc';
					obj['$select'      ] = '*';
					obj['$filter'      ] = 'PARENT_ID eq \'' + this.PARENT_ID + '\'';
					let sBody: string = JSON.stringify(obj);
					let res  = await CreateSplendidRequest('Rest.svc/PostModuleTable', 'POST', 'application/octet-stream', sBody);
					let json = await GetSplendidResult(res);
					if ( json.d.results != null )
					{
						// 10/13/2020 Paul.  Make the condition more explicit. 
						if ( rowDefaultSearch === undefined || rowDefaultSearch == null )
						{
							rowDefaultSearch = {};
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
						rowDefaultSearch['TO_ADDRS'       ] = '';
						rowDefaultSearch['TO_ADDRS_IDS'   ] = '';
						rowDefaultSearch['TO_ADDRS_NAMES' ] = '';
						rowDefaultSearch['TO_ADDRS_EMAILS'] = '';
						// 09/05/2008 Paul.  Allow the possibility that there would be more than one email address associaed with the parent. 
						// vwQUEUE_EMAIL_ADDRESS has not been coded that way, but it may in the future. 
						for ( let i: number = 0; i < json.d.results.length; i++ )
						{
							let item: any = json.d.results[i];
							// 05/13/2008 Paul.  Populate all address fields. 
							if ( !Sql.IsEmptyString(rowDefaultSearch['TO_ADDRS'       ]) ) rowDefaultSearch['TO_ADDRS'       ] += '; ';
							if ( !Sql.IsEmptyString(rowDefaultSearch['TO_ADDRS_IDS'   ]) ) rowDefaultSearch['TO_ADDRS_IDS'   ] += ';';
							if ( !Sql.IsEmptyString(rowDefaultSearch['TO_ADDRS_NAMES' ]) ) rowDefaultSearch['TO_ADDRS_NAMES' ] += ';';
							if ( !Sql.IsEmptyString(rowDefaultSearch['TO_ADDRS_EMAILS']) ) rowDefaultSearch['TO_ADDRS_EMAILS'] += ';';
							// 10/13/2011 Paul.  We need to return the recipient ID and not the parent ID. 
							rowDefaultSearch['TO_ADDRS'       ] = rowDefaultSearch['TO_ADDRS'       ] = FormatEmailDisplayName(Sql.ToString(item['RECIPIENT_NAME']), Sql.ToString(item['EMAIL1']));
							rowDefaultSearch['TO_ADDRS_IDS'   ] = rowDefaultSearch['TO_ADDRS_IDS'   ] = Sql.ToString(item['RECIPIENT_ID'  ]);
							rowDefaultSearch['TO_ADDRS_NAMES' ] = rowDefaultSearch['TO_ADDRS_NAMES' ] = Sql.ToString(item['RECIPIENT_NAME']);
							rowDefaultSearch['TO_ADDRS_EMAILS'] = rowDefaultSearch['TO_ADDRS_EMAILS'] = Sql.ToString(item['EMAIL1'        ]);
						}
					}
				}
				else
				{
					this.setState( {error: 'Parent ID [' + this.PARENT_ID + '] was not found.'} );
				}
			}
			// 12/17/2014 Paul.  Allow the template to be a parameter. 
			if ( !Sql.IsEmptyGuid(queryParams['EMAIL_TEMPLATE_ID']) )
			{
				// 10/13/2020 Paul.  Make the condition more explicit. 
				if ( rowDefaultSearch === undefined || rowDefaultSearch == null )
				{
					rowDefaultSearch = {};
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
				rowDefaultSearch['EMAIL_TEMPLATE_ID'] = Sql.ToString(queryParams['EMAIL_TEMPLATE_ID']);
			}
			let KB_ATTACHMENTS: any[] = null;
			// 10/25/2009 Paul.  When sending a Knowledge Base article, we need to pre-populate the fields and attachments. 
			if ( !Sql.IsEmptyGuid(queryParams['KBDOCUMENT_ID']) )
			{
				// 10/13/2020 Paul.  Make the condition more explicit. 
				if ( rowDefaultSearch === undefined || rowDefaultSearch == null )
				{
					rowDefaultSearch = {};
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
				let KBDOCUMENT_ID: string = Sql.ToString(queryParams['KBDOCUMENT_ID']);
				const d = await EditView_LoadItem('KBDocuments', KBDOCUMENT_ID);
				let item: any = d.results;
				if ( item != null )
				{
					rowDefaultSearch['NAME'            ] = Sql.ToString(item['NAME'       ]);
					rowDefaultSearch['DESCRIPTION'     ] = Sql.ToString(item['DESCRIPTION']);
					KB_ATTACHMENTS = item.ATTACHMENTS;
				}
			}
			// 03/01/2021 Paul.  Need to initialize old signature value. 
			let SIGNATURE_HTML    : string = null;
			let NOTE_ID           : string = null;
			let NOTE_NAME         : string = null;
			let NOTE_ATTACHMENT_ID: string = null;
			if ( !Sql.IsEmptyGuid(queryParams['NOTE_ID']) )
			{
				NOTE_ID = Sql.ToString(queryParams['NOTE_ID']);
				const d = await EditView_LoadItem('Notes', NOTE_ID);
				let item: any = d.results;
				if ( item != null )
				{
					NOTE_NAME          = item['FILENAME'          ];
					NOTE_ATTACHMENT_ID = item['NOTE_ATTACHMENT_ID'];
				}
			}
			let REQUEST_TYPE: string = null;
			let EMAIL_TYPE  : string = 'draft';
			queryParams = qs.parse(location.search.toLowerCase());
			if ( !Sql.IsEmptyString(queryParams['type']) )
			{
				REQUEST_TYPE = Sql.ToString(queryParams['type']);
				EMAIL_TYPE   = Sql.ToString(queryParams['type']);
				if ( EMAIL_TYPE != 'archived' )
					EMAIL_TYPE = "draft";
			}
			let MODULE_TITLE: string = (EMAIL_TYPE != 'archived' ? L10n.Term('Emails.LBL_COMPOSE_MODULE_NAME') : L10n.Term('Emails.LBL_ARCHIVED_MODULE_NAME'));
			const layout = EditView_LoadLayout(EDIT_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			if ( this._isMounted )
			{
				if ( Sql.IsEmptyString(ID) && Sql.IsEmptyString(DuplicateID)  )
				{
					if ( layout && layout.length > 0 )
					{
						for ( let i = 0; i < layout.length; i++ )
						{
							let lay: EDITVIEWS_FIELD = layout[i];
							if ( lay.DATA_FIELD == 'SIGNATURE_ID' )
							{
								// 05/03/2020 Paul.  If this is a new record, then the signature is automatically applied. 
								let signature: any = SplendidCache.GetPrimarySignature();
								if ( signature != null )
								{
									// 10/13/2020 Paul.  Make the condition more explicit. 
									if ( rowDefaultSearch === undefined || rowDefaultSearch == null )
									{
										rowDefaultSearch = {};
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
									rowDefaultSearch['SIGNATURE_ID'] = Sql.ToString(signature['ID'            ]);
									rowDefaultSearch['DESCRIPTION' ] = Sql.ToString(signature['SIGNATURE_HTML']);
									// 03/01/2021 Paul.  Need to initialize old signature value. 
									SIGNATURE_HTML = Sql.ToString(signature['SIGNATURE_HTML']);
									lay.UI_REQUIRED = true;
								}
							}
						}
					}
				}
				this.EMAIL_TYPE_Changed(EMAIL_TYPE, layout);
				this.setState(
				{
					layout            : layout,
					item              : (rowDefaultSearch ? rowDefaultSearch : null),
					MODULE_TITLE      ,
					REQUEST_TYPE      ,
					EMAIL_TYPE        ,
					NOTE_ID           ,
					NOTE_NAME         ,
					NOTE_ATTACHMENT_ID,
					KB_ATTACHMENTS    ,
					SIGNATURE_HTML    ,
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
		let { layout, MODULE_TITLE, SIGNATURE_HTML } = this.state;
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
					let EMAIL_TYPE        : string = this.state.EMAIL_TYPE;
					if ( item )
					{
						// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
						if ( item['DATE_MODIFIED'] !== undefined )
						{
							LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
						}
						// 04/16/2006 Paul.  Since the Plug-in saves body in DESCRIPTION, we need to continue to use it as the primary source of data. 
						let sDESCRIPTION     : string = Sql.ToString(item['DESCRIPTION'     ]);
						// 12/03/2008 Paul.  The plain-text description may not contain anything.  If HTML exists, then always use it. 
						let sDESCRIPTION_HTML: string = Sql.ToString(item['DESCRIPTION_HTML']);
						if ( !Sql.IsEmptyString(sDESCRIPTION_HTML) )
							sDESCRIPTION = sDESCRIPTION_HTML;
						// 05/23/2010 Paul.  We only need to do the replacements if this the message is not HTML. 
						// 05/23/2010 Paul.  XssFilter will remove <html>, so we have to check first. 
						if ( !(sDESCRIPTION.indexOf("<html") >= 0 || sDESCRIPTION.indexOf("<body") >= 0 || sDESCRIPTION.indexOf("<br") >= 0) )
						{
							// 01/20/2008 Paul.  There is probably a regular expression filter that would do the following replacement better. 
							// 06/07/2009 Paul.  Email from the Outlook plug-in may not be in HTML, so we need to make it readable in the HTML editor. 
							// 06/04/2010 Paul.  Try and prevent excess blank lines. 
							sDESCRIPTION = NormalizeDescription(sDESCRIPTION);
						}
						sDESCRIPTION = XssFilter(sDESCRIPTION, Crm_Config.ToString('email_xss'));
						item['DESCRIPTION'] = sDESCRIPTION;

						EMAIL_TYPE = Sql.ToString(item['TYPE']).toLowerCase();
						let sEMAIL_STATUS: string = Sql.ToString(item['STATUS']).toLowerCase();
						// 06/30/2007 Paul.  A forward or reply is just like a draft. 
						if ( sRequestType == 'forward' || sRequestType == 'reply' || sRequestType == 'replyall' )
						{
							// 07/21/2013 Paul.  From values will come from mailbox. 
							let sFROM_NAME: string = Sql.ToString(item['FROM_NAME']);
							let sFROM_ADDR: string = Sql.ToString(item['FROM_ADDR']);
							let sFrom     : string = FormatEmailDisplayName(sFROM_NAME, sFROM_ADDR);
							// 06/30/2007 Paul.  We are going to use an HR tag as the delimiter. 
							let sReplyDelimiter: string = '';  //'> ';
							let sDATE_START    : string = FromJsonDate(item['DATE_START'], Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
							let sbReplyHeader  : string = '';
							//sbReplyHeader += (                  L10n.Term('Emails.LBL_FORWARD_HEADER') + '<br /><br />\r\n');
							sbReplyHeader += ('<br />\r\n');
							sbReplyHeader += ('<br />\r\n');
							sbReplyHeader += ('<hr />\r\n');
							sbReplyHeader += (sReplyDelimiter + '<b>' + L10n.Term('Emails.LBL_FROM'     ) + '</b> ' + Trim(sFrom)      + '<br />\r\n');
							sbReplyHeader += (sReplyDelimiter + '<b>' + L10n.Term('Emails.LBL_DATE_SENT') + '</b> ' + sDATE_START      + '<br />\r\n');
							sbReplyHeader += (sReplyDelimiter + '<b>' + L10n.Term('Emails.LBL_TO'       ) + '</b> ' + item['TO_ADDRS'] + '<br />\r\n');
							sbReplyHeader += (sReplyDelimiter + '<b>' + L10n.Term('Emails.LBL_SUBJECT'  ) + '</b> ' + item['NAME'    ] + '<br />\r\n');
							sbReplyHeader += (sReplyDelimiter + '<br />\r\n');
							item['DESCRIPTION'] = sbReplyHeader + item['DESCRIPTION'];
							// 09/10/2012 Paul.  Fire the event so that the signature will be populated. 
							let signature: any = SplendidCache.GetPrimarySignature();
							if ( signature != null )
							{
								item['SIGNATURE_ID'] = Sql.ToString(signature['ID'            ]);
								item['DESCRIPTION' ] = Sql.ToString(signature['SIGNATURE_HTML']) + item['DESCRIPTION'];
								// 03/01/2021 Paul.  Need to initialize old signature value. 
								SIGNATURE_HTML = Sql.ToString(signature['SIGNATURE_HTML']);
							}
							
							EMAIL_TYPE = 'draft';
							item['ASSIGNED_TO'     ] = Security.USER_NAME();
							item['ASSIGNED_USER_ID'] = Security.USER_ID();
							if ( sRequestType == 'forward' )
							{
								item['TO_ADDRS'       ] = '';
								item['TO_ADDRS_IDS'   ] = '';
								item['TO_ADDRS_NAMES' ] = '';
								item['TO_ADDRS_EMAILS'] = '';

								item['CC_ADDRS'       ] = '';
								item['CC_ADDRS_IDS'   ] = '';
								item['CC_ADDRS_NAMES' ] = '';
								item['CC_ADDRS_EMAILS'] = '';
							}
							else if ( sRequestType == 'reply' )
							{
								// 05/20/2009 Paul.  When replying, the FROM becomes the TO.  We were previously appending. 
								//txtTO_ADDRS_IDS    .Value = '';
								item['TO_ADDRS'       ] = sFROM_ADDR;
								item['TO_ADDRS_NAMES' ] = sFROM_NAME;
								item['TO_ADDRS_EMAILS'] = sFROM_ADDR;

								item['CC_ADDRS'       ] = '';
								item['CC_ADDRS_IDS'   ] = '';
								item['CC_ADDRS_NAMES' ] = '';
								item['CC_ADDRS_EMAILS'] = '';
							}
							else if ( sRequestType == 'replyall' )
							{
								// 05/20/2009 Paul.  When replying to all, we need to make sure that all fields are separated properly. 
								// 07/21/2013 Paul.  From values will come from mailbox. 
								if ( !Sql.IsEmptyString(item['TO_ADDRS'       ]) && !Sql.IsEmptyString(sFROM_ADDR) ) item['TO_ADDRS'       ] += ';';
								if ( !Sql.IsEmptyString(item['TO_ADDRS_NAMES' ]) && !Sql.IsEmptyString(sFROM_NAME) ) item['TO_ADDRS_NAMES' ] += ';';
								if ( !Sql.IsEmptyString(item['TO_ADDRS_EMAILS']) && !Sql.IsEmptyString(sFROM_ADDR) ) item['TO_ADDRS_EMAILS'] += ';';
								//txtTO_ADDRS_IDS    .Value = '';
								item['TO_ADDRS'       ] += sFROM_ADDR;
								item['TO_ADDRS_NAMES' ] += sFROM_NAME;
								item['TO_ADDRS_EMAILS'] += sFROM_ADDR;
							}
							item['DATE_START'     ] = null;
							// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
							// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
							// 07/21/2013 Paul.  From values will come from mailbox. 
							//item['FROM_NAME'       ] = Security.FULL_NAME();
							//item['FROM_ADDR'       ] = Security.EMAIL1();
							item['BCC_ADDRS'       ] = '';
							item['BCC_ADDRS_IDS'   ] = '';
							item['BCC_ADDRS_NAMES' ] = '';
							item['BCC_ADDRS_EMAILS'] = '';
							// 04/10/2013 Paul.  If this is a reply to a case, then insert the macro if it does not already exist. 
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
						if ( ( EMAIL_TYPE == 'out' && sEMAIL_STATUS == 'draft') || EMAIL_TYPE == 'sent' || EMAIL_TYPE == 'campaign' || EMAIL_TYPE == 'inbound' )
						{
							// 01/21/2006 Paul.  Editing is not allowed for sent emails. 
							// 04/16/2021 Paul.  Do not redirect during precompile as it stops it. 
							if ( !this.props.isPrecompile )
							{
								this.props.history.push(`/Reset/${MODULE_NAME}/View/${sID}`);
								return;
							}
						}
						// 11/17/2005 Paul.  Archived emails allow editing of the Date & Time Sent. 
						switch ( EMAIL_TYPE )
						{
							case 'archived':
								// 09/26/2013 Paul.  Format the header as a link. 
								// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
								MODULE_TITLE  = L10n.Term('Emails.LBL_ARCHIVED_MODULE_NAME');
								break;
							case 'inbound' :
								MODULE_TITLE  = L10n.Term('Emails.LBL_INBOUND_TITLE'       );
								break;
							case 'out'     :
								// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
								MODULE_TITLE  = L10n.Term('Emails.LBL_LIST_FORM_SENT_TITLE');
								break;
							case 'campaign':
								MODULE_TITLE  = L10n.Term('Emails.LBL_LIST_FORM_SENT_TITLE');
								break;
							default        :
								MODULE_TITLE  = L10n.Term('Emails.LBL_COMPOSE_MODULE_NAME' );
								break;
						}
					}
					this.EMAIL_TYPE_Changed(EMAIL_TYPE, layout);
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState(
					{
						item              ,
						layout            ,
						MODULE_TITLE      ,
						SUB_TITLE         ,
						ATTACHMENTS       ,
						SIGNATURE_HTML    ,
						__sql             : d.__sql,
						LAST_DATE_MODIFIED,
						EMAIL_TYPE        ,
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

	private EMAIL_TYPE_Changed = (EMAIL_TYPE: string, layout: EDITVIEWS_FIELD[]) =>
	{
		if ( layout && layout.length > 0 )
		{
			for ( let i = 0; i < layout.length; i++ )
			{
				let lay: EDITVIEWS_FIELD = layout[i];
				if ( lay.DATA_FIELD == 'MAILBOX_ID' )
				{
					if ( EMAIL_TYPE == 'archived' )
					{
						lay.hidden        = true ;
						lay.UI_REQUIRED   = false;
						lay.DATA_REQUIRED = false;
					}
					else if ( Crm_Config.ToBoolean('Emails.RequireSelectMailbox') )
					{
						lay.hidden        = false;
						lay.UI_REQUIRED   = true ;
						lay.DATA_REQUIRED = true ;
						lay.DATA_FORMAT   = 'force';
					}
				}
				else if ( lay.DATA_FIELD == 'DATE_START' )
				{
					lay.hidden        = (EMAIL_TYPE != 'archived');
					lay.UI_REQUIRED   = !lay.hidden;
					lay.DATA_REQUIRED = !lay.hidden;
				}
				else if ( lay.DATA_LABEL == 'Emails.LBL_NOTE_SEMICOLON' )
				{
					lay.hidden        = (EMAIL_TYPE != 'draft');
				}
				else if ( lay.DATA_FIELD == 'EMAIL_TEMPLATE_ID' )
				{
					lay.hidden        = (EMAIL_TYPE != 'draft');
				}
				else if ( lay.DATA_FIELD == 'PREPEND_TEMPLATE' || lay.DATA_LABEL == 'Emails.LBL_PREPEND_TEMPLATE' )
				{
					lay.hidden        = (EMAIL_TYPE != 'draft');
				}
				else if ( lay.DATA_FIELD == 'SIGNATURE_ID' )
				{
					lay.hidden        = (EMAIL_TYPE != 'draft');
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
		if ( PARENT_FIELD == 'SIGNATURE_ID' )
		{
			let signature: any = SplendidCache.GetSignature(DATA_VALUE);
			if ( signature )
			{
				let SIGNATURE_HTML: string = signature['SIGNATURE_HTML'];
				let ref = this.refMap['DESCRIPTION'];
				if ( ref )
				{
					let data: any = ref.current.data;
					let DESCRIPTION  : string = Sql.ToString(data.value);
					let OLD_SIGNATURE: string = Sql.ToString(this.state.SIGNATURE_HTML);
					if ( !Sql.IsEmptyString(OLD_SIGNATURE) )
					{
						if ( StartsWith(DESCRIPTION, OLD_SIGNATURE) )
						{
							DESCRIPTION = DESCRIPTION.substring(OLD_SIGNATURE.length);
						}
						// 09/10/2012 Paul.  The HTML editor can strip the CRLF, so we need to check for that. 
						else
						{
							OLD_SIGNATURE = OLD_SIGNATURE.replace(/[\r\n]/g, '');
							// 03/01/2021 Paul.  The HTML editor is also modifying BR tags. 
							OLD_SIGNATURE = OLD_SIGNATURE.replace(/<br\/>/g, '<br>');
							OLD_SIGNATURE = OLD_SIGNATURE.replace(/<br \/>/g, '<br>');
							if ( StartsWith(DESCRIPTION, OLD_SIGNATURE) )
							{
								DESCRIPTION = DESCRIPTION.substring(OLD_SIGNATURE.length);
							}
						}
					}
					DESCRIPTION = SIGNATURE_HTML + DESCRIPTION;
					// 03/01/2021 Paul.  There may not have been any edits up to this point. 
					if ( editedItem == null )
						editedItem = {};
					editedItem['DESCRIPTION'] = DESCRIPTION;
					ref.current.updateDependancy('SIGNATURE_ID', DESCRIPTION, 'value');
					this.setState({ editedItem, SIGNATURE_HTML });
				}
			}
		}
		// 03/01/2021 Paul.  PARENT_FIELD instead of this.PARENT_ID. 
		else if ( PARENT_FIELD == 'EMAIL_TEMPLATE_ID' )
		{
			EditView_LoadItem('EmailTemplates', DATA_VALUE).then((d) =>
			{
				let item: any = d.results;
				if ( item != null )
				{
					// 03/01/2021 Paul.  There may not have been any edits up to this point. 
					if ( editedItem == null )
						editedItem = {};
					let READ_ONLY: boolean = Sql.ToBoolean(item['READ_ONLY']);
					let SUBJECT  : string  = Sql.ToString (item['SUBJECT'  ]);
					let BODY_HTML: string  = Sql.ToString (item['BODY_HTML']);
					let currentItem = Object.assign({}, this.state.item, this.state.editedItem);
					// 03/05/2007 Michael.  We should use the Subject of the template, not the name.
					// 11/13/2006 Paul.  We switched to BODY_HTML a while back when FCKeditor was first implemented. 
					// 04/12/2011 Paul.  Allow template to be prepended to an email.  This is so that a reply can be prepended with a template response. 
					let refNAME = this.refMap['NAME'];
					if ( refNAME != null )
					{
						let data : any    = refNAME.current.data;
						let sNAME: string = Sql.ToString(data.value);
						if ( Sql.ToBoolean(currentItem['PREPEND_TEMPLATE']) )
						{
							if ( Sql.IsEmptyString(sNAME) )
							{
								editedItem['NAME'] = SUBJECT;
								refNAME.current.updateDependancy('EMAIL_TEMPLATE_ID', SUBJECT, 'value');
							}
						}
						else
						{
							editedItem['NAME'] = SUBJECT;
							refNAME.current.updateDependancy('EMAIL_TEMPLATE_ID', SUBJECT, 'value');
						}
						refNAME.current.updateDependancy('EMAIL_TEMPLATE_ID', !READ_ONLY, 'enabled');
					}
					let refDESCRIPTION = this.refMap['DESCRIPTION'];
					if ( refDESCRIPTION != null )
					{
						let data        : any    = refDESCRIPTION.current.data;
						let DESCRIPTION: string = Sql.ToString(data.value);
						if ( Sql.ToBoolean(currentItem['PREPEND_TEMPLATE']) )
						{
							DESCRIPTION = BODY_HTML + DESCRIPTION;
						}
						else
						{
							DESCRIPTION = BODY_HTML;
						}
						editedItem['DESCRIPTION'] = DESCRIPTION;
						refDESCRIPTION.current.updateDependancy('EMAIL_TEMPLATE_ID', DESCRIPTION, 'value');
						refDESCRIPTION.current.updateDependancy('EMAIL_TEMPLATE_ID', !READ_ONLY, 'enabled');
					}
					this.setState({ editedItem, READ_ONLY, TEMPLATE_ATTACHMENTS: item.ATTACHMENTS });
				}
			})
			.catch((error) =>
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
			});
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
		const { LAST_DATE_MODIFIED, editedItem, EMAIL_TYPE } = this.state;
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
							// 01/24/2021 Paul.  EMAIL_TYPE is a state variable, not a record value. 
							if ( EMAIL_TYPE == 'draft' )
								row['TYPE'] = 'out';
							// 01/21/2006 Paul.  Address error only when sending. 
							if ( Sql.IsEmptyString(row['TO_ADDRS']) && Sql.IsEmptyString(row['CC_ADDRS']) && Sql.IsEmptyString(row['BCC_ADDRS']) )
							{
								this.setState({ error: L10n.Term('Emails.ERR_NOT_ADDRESSED') });
								return;
							}
						}
						if ( this.state.KB_ATTACHMENTS && this.state.KB_ATTACHMENTS.length > 0 )
						{
							row.KB_ATTACHMENTS = this.state.KB_ATTACHMENTS;
						}
						if ( this.state.TEMPLATE_ATTACHMENTS && this.state.TEMPLATE_ATTACHMENTS.length > 0 )
						{
							row.TEMPLATE_ATTACHMENTS = this.state.TEMPLATE_ATTACHMENTS;
						}
						if ( this.state.NOTE_ATTACHMENT_ID )
						{
							if ( !row.TEMPLATE_ATTACHMENTS )
							{
								row.TEMPLATE_ATTACHMENTS = [];
							}
							row.TEMPLATE_ATTACHMENTS.push({ ID: this.state.NOTE_ID, NAME: this.state.NOTE_NAME, NOTE_ATTACHMENT_ID: this.state.NOTE_ATTACHMENT_ID })
						}
						if ( this.state.ATTACHMENTS && this.state.ATTACHMENTS.length > 0 )
						{
							row.ATTACHMENTS = this.state.ATTACHMENTS;
						}
						// 11/20/2005 Paul.  SugarCRM 3.5.1 lets bad data flow through.  We clear the hidden values if the visible values are empty. 
						// There still is the issue of the data getting out of sync if the user manually edits the visible values. 
						// 03/11/2021 Paul.  Build current item in case record not edited. 
						let currentItem = Object.assign({}, this.state.item, this.state.editedItem);
						row['TO_ADDRS_IDS'    ] = currentItem['TO_ADDRS_IDS'    ];
						row['TO_ADDRS_NAMES'  ] = currentItem['TO_ADDRS_NAMES'  ];
						row['TO_ADDRS_EMAILS' ] = currentItem['TO_ADDRS_EMAILS' ];
						row['CC_ADDRS_IDS'    ] = currentItem['CC_ADDRS_IDS'    ];
						row['CC_ADDRS_NAMES'  ] = currentItem['CC_ADDRS_NAMES'  ];
						row['CC_ADDRS_EMAILS' ] = currentItem['CC_ADDRS_EMAILS' ];
						row['BCC_ADDRS_IDS'   ] = currentItem['BCC_ADDRS_IDS'   ];
						row['BCC_ADDRS_NAMES' ] = currentItem['BCC_ADDRS_NAMES' ];
						row['BCC_ADDRS_EMAILS'] = currentItem['BCC_ADDRS_EMAILS'];
						if ( Sql.IsEmptyString(row['TO_ADDRS']) )
						{
							row['TO_ADDRS_IDS'    ] = null;
							row['TO_ADDRS_NAMES'  ] = null;
							row['TO_ADDRS_EMAILS' ] = null;
						}
						if ( Sql.IsEmptyString(row['CC_ADDRS']) )
						{
							row['CC_ADDRS_IDS'    ] = null;
							row['CC_ADDRS_NAMES'  ] = null;
							row['CC_ADDRS_EMAILS' ] = null;
						}
						if ( Sql.IsEmptyString(row['BCC_ADDRS']) )
						{
							row['BCC_ADDRS_IDS'   ] = null;
							row['BCC_ADDRS_NAMES' ] = null;
							row['BCC_ADDRS_EMAILS'] = null;
						}
						// 07/21/2013 Paul.  From values will come from mailbox. 
						row['FROM_ADDR'] = null;
						row['FROM_NAME'] = null;
						let mailbox: any = SplendidCache.GetOutboundMail(row['MAILBOX_ID']);
						if ( mailbox )
						{
							row['FROM_ADDR'] = Sql.ToString(mailbox['FROM_ADDR']);
							row['FROM_NAME'] = Sql.ToString(mailbox['FROM_NAME']);
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
						// 05/19/2023 Paul.  If we don't populate DESCRIPTION_HTML, then email will not be sent as HTML, leaving html tags in the body. 
						row['DESCRIPTION_HTML'] = row['DESCRIPTION'];
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
									let res = await CreateSplendidRequest('Rest.svc/SendEmail', 'POST', 'application/json; charset=utf-8', sBody);
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
				case 'EmailAddressesPopup':
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

	private _onSelect = (value: { Action: string, ID: string, NAME: string, EMAIL: string }) =>
	{
		const { addressFields } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', value);
		if ( value.Action == 'SingleSelect' )
		{
			let currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			let error: any = null;
			let arrAddressFields: string[] = addressFields.split(',');
			if ( arrAddressFields.length == 4 )
			{
				let ADDRS       : string = arrAddressFields[0];
				let ADDRS_IDS   : string = arrAddressFields[1];
				let ADDRS_NAMES : string = arrAddressFields[2];
				let ADDRS_EMAILS: string = arrAddressFields[3];
				if ( Sql.IsEmptyGuid(value.ID) )
				{
					currentItem[ADDRS       ] = null;
					currentItem[ADDRS_IDS   ] = null;
					currentItem[ADDRS_NAMES ] = null;
					currentItem[ADDRS_EMAILS] = null;
					this.UpdateDependancy(ADDRS, '', 'value');
				}
				else
				{
					if ( !Sql.IsEmptyString(currentItem[ADDRS       ]) ) currentItem[ADDRS       ] += ';';
					if ( !Sql.IsEmptyString(currentItem[ADDRS_IDS   ]) ) currentItem[ADDRS_IDS   ] += ';';
					if ( !Sql.IsEmptyString(currentItem[ADDRS_NAMES ]) ) currentItem[ADDRS_NAMES ] += ';';
					if ( !Sql.IsEmptyString(currentItem[ADDRS_EMAILS]) ) currentItem[ADDRS_EMAILS] += ';';
					currentItem[ADDRS       ] = Sql.ToString(currentItem[ADDRS       ]) + FormatEmailDisplayName(Sql.ToString(value.NAME), Sql.ToString(value.EMAIL));
					currentItem[ADDRS_IDS   ] = Sql.ToString(currentItem[ADDRS_IDS   ]) + value.ID   ;
					currentItem[ADDRS_NAMES ] = Sql.ToString(currentItem[ADDRS_NAMES ]) + value.NAME ;
					currentItem[ADDRS_EMAILS] = Sql.ToString(currentItem[ADDRS_EMAILS]) + value.EMAIL;
					this.UpdateDependancy(ADDRS, currentItem[ADDRS], 'value');
				}
			}
			else
			{
				error = 'Layout must have 4 fields, such as TO_ADDRS,TO_ADDRS_IDS,TO_ADDRS_NAMES,TO_ADDRS_EMAILS';
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
		const { EMAIL_TYPE } = this.state;
		let arrMAILBOX_COUNT: string[] = L10n.GetList('OutboundMail');
		// 08/12/2019 Paul.  Here is where we can disable buttons immediately after they were loaded. 
		if ( this.headerButtons.current != null )
		{
			this.headerButtons.current.ShowButton  ('Save', (EMAIL_TYPE == 'draft' || EMAIL_TYPE == 'archived'));
			this.headerButtons.current.ShowButton  ('Send', (EMAIL_TYPE == 'draft'));
			this.headerButtons.current.EnableButton('Send', arrMAILBOX_COUNT && arrMAILBOX_COUNT.length > 0);
		}
		if ( this.dynamicButtonsBottom.current != null )
		{
			this.dynamicButtonsBottom.current.ShowButton  ('Save', (EMAIL_TYPE == 'draft' || EMAIL_TYPE == 'archived'));
			this.dynamicButtonsBottom.current.ShowButton  ('Send', (EMAIL_TYPE == 'draft'));
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

	private _onRemoveKBAttachment = (e, index) =>
	{
		let { KB_ATTACHMENTS } = this.state;
		if ( KB_ATTACHMENTS && index < KB_ATTACHMENTS.length )
		{
			KB_ATTACHMENTS.splice(index, 1);
			this.setState({ KB_ATTACHMENTS });
		}
	}

	private _onRemoveTemplateAttachment = (e, index) =>
	{
		let { TEMPLATE_ATTACHMENTS } = this.state;
		if ( TEMPLATE_ATTACHMENTS && index < TEMPLATE_ATTACHMENTS.length )
		{
			TEMPLATE_ATTACHMENTS.splice(index, 1);
			this.setState({ TEMPLATE_ATTACHMENTS });
		}
	}

	private _onRemoveNote = (e) =>
	{
		this.setState({ NOTE_ID: null, NOTE_NAME: null, NOTE_ATTACHMENT_ID: null });
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
		const { item, layout, MODULE_TITLE, EDIT_NAME, SUB_TITLE, NOTE_ID, NOTE_NAME, NOTE_ATTACHMENT_ID, ATTACHMENTS, KB_ATTACHMENTS, TEMPLATE_ATTACHMENTS, error, popupOpen } = this.state;
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
				<PopupEmailAddresses
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
							<div id='ctlEditView_Emails_EditView_ATTACHMENTS_LABEL' className='dataLabel' style={ {width: '15%'} }>
								{ L10n.Term('Emails.LBL_ATTACHMENTS') }
							</div>
							<div id='ctlEditView_Emails_EditView_ATTACHMENTS' className='dataField' style={ {width: '85%'} }>
								{ KB_ATTACHMENTS
								? KB_ATTACHMENTS.map((attachment, index) => 
								{
									// 05/12/2020 Paul.  Don't need to check deleted flag as record is deleted. 
									return (
									<div>
										<a
											id={ attachment.KBDOCUMENT_ID }
											key={ attachment.KBDOCUMENT_ID }
											href={ Credentials.RemoteServer + 'Notes/Attachment.aspx?ID=' + attachment.KBDOCUMENT_ID }
											target='_blank'
										>
											{ attachment.FILENAME }
										</a>
										<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onRemoveKBAttachment(e, index) }>
											<FontAwesomeIcon icon='minus' size='lg' style={ {marginLeft: '4px'} } />
										</span>
									</div>);
								})
								: null
								}
								{ TEMPLATE_ATTACHMENTS
								? TEMPLATE_ATTACHMENTS.map((attachment, index) => 
								{
									// 05/12/2020 Paul.  Don't need to check deleted flag as record is deleted. 
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
										<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onRemoveTemplateAttachment(e, index) }>
											<FontAwesomeIcon icon='minus' size='lg' style={ {marginLeft: '4px'} } />
										</span>
									</div>);
								})
								: null
								}
								{ NOTE_ID && NOTE_ATTACHMENT_ID
								? <div>
									<a
										id={ 'lnkReportAttachment_' + NOTE_ATTACHMENT_ID }
										key={ 'lnkReportAttachment_' + NOTE_ATTACHMENT_ID }
										href={ Credentials.RemoteServer + 'Notes/Attachment.aspx?ID=' + NOTE_ATTACHMENT_ID }
										target='_blank'
									>
										{ NOTE_NAME }
									</a>
									<span style={ {cursor: 'pointer'} } onClick={ this._onRemoveNote }>
										<FontAwesomeIcon icon='minus' size='lg' style={ {marginLeft: '4px'} } />
									</span>
								</div>
								: null
								}
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

// 07/18/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 

