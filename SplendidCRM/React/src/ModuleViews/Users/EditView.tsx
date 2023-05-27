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
import * as ReactDOM from 'react-dom';
import * as qs from 'query-string';
import { RouteComponentProps, withRouter }                                      from 'react-router-dom'                          ;
import moment from 'moment';
import { observer }                                                             from 'mobx-react'                                ;
import { FontAwesomeIcon }                                                      from '@fortawesome/react-fontawesome'            ;
// 2. Store and Types. 
import { EditComponent }                                                        from '../../types/EditComponent'                 ;
import { HeaderButtons }                                                        from '../../types/HeaderButtons'                 ;
import EDITVIEWS_FIELD                                                          from '../../types/EDITVIEWS_FIELD'               ;
import DYNAMIC_BUTTON                                                           from '../../types/DYNAMIC_BUTTON'                ;
// 3. Scripts. 
import Sql                                                                      from '../../scripts/Sql'                         ;
import L10n                                                                     from '../../scripts/L10n'                        ;
import Security                                                                 from '../../scripts/Security'                    ;
import Credentials                                                              from '../../scripts/Credentials'                 ;
import SplendidCache                                                            from '../../scripts/SplendidCache'               ;
import SplendidDynamic_EditView                                                 from '../../scripts/SplendidDynamic_EditView'    ;
import { Crm_Config, Crm_Modules }                                              from '../../scripts/Crm'                         ;
import { AuthenticatedMethod, LoginRedirect, GetUserProfile, GetMyUserProfile } from '../../scripts/Login'                       ;
import { sPLATFORM_LAYOUT }                                                     from '../../scripts/SplendidInitUI'              ;
import { EditView_LoadItem, EditView_LoadLayout, EditView_RemoveField, EditView_FindField, EditView_HideField } from '../../scripts/EditView';
import { UpdateModule }                                                         from '../../scripts/ModuleUpdate'                ;
import { CreateSplendidRequest, GetSplendidResult }                             from '../../scripts/SplendidRequest'             ;
import { jsonReactState, Application_ClearStore }                               from '../../scripts/Application'                 ;
// 4. Components and Views. 
import ErrorComponent                                                           from '../../components/ErrorComponent'           ;
import DumpSQL                                                                  from '../../components/DumpSQL'                  ;
import DynamicButtons                                                           from '../../components/DynamicButtons'           ;
import HeaderButtonsFactory                                                     from '../../ThemeComponents/HeaderButtonsFactory';

interface IEditViewProps extends RouteComponentProps<any>
{
	MODULE_NAME        : string;
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
	MyAccount?         : boolean;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IEditViewState
{
	__total                   : number;
	__sql                     : string;
	loadedKey                 : string;
	item                      : any;
	originalItem              : any;
	layout                    : EDITVIEWS_FIELD[];
	layoutSettings            : EDITVIEWS_FIELD[];
	layoutEmailOptions        : EDITVIEWS_FIELD[];
	layoutSmtpView            : EDITVIEWS_FIELD[];
	layoutGoogleOptions       : EDITVIEWS_FIELD[];
	layoutICloudOptions       : EDITVIEWS_FIELD[];
	EDIT_NAME                 : string;
	DUPLICATE                 : boolean;
	LAST_DATE_MODIFIED        : Date;
	SUB_TITLE                 : any;
	editedItem                : any;
	dependents                : Record<string, Array<any>>;
	error                     : any;

	smtpserver                : string;
	sExchangeServerURL        : string;
	bGoogleAppsEnabled        : boolean;
	biCloudEnabled            : boolean;
	bfacebookEnableLogin      : boolean;
	isDuplicate               : boolean;

	lblSmtpAuthorizedStatus?  : string;
	lblGoogleAuthorizedStatus?: string;
	lblCloudAuthorizedStatus? : string;
	lblOfficeAuthorizedStatus?: string;
}

// 09/18/2019 Paul.  Give class a unique name so that it can be debugged.  Without the unique name, Chrome gets confused.
@observer
export default class EditView extends React.Component<IEditViewProps, IEditViewState>
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
		let EDIT_NAME = props.MODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		let smtpserver          : string  = Crm_Config.ToString ('smtpserver'          );
		let sExchangeServerURL  : string  = Crm_Config.ToString ('Exchange.ServerURL'  );
		let bGoogleAppsEnabled  : boolean = Crm_Config.ToBoolean('GoogleApps.Enabled'  );
		let biCloudEnabled      : boolean = Crm_Config.ToBoolean('iCloud.Enabled'      );
		let bfacebookEnableLogin: boolean = Crm_Config.ToBoolean('facebook.EnableLogin');
		let isDuplicate         : boolean = location.pathname.includes('Duplicate');

		this.state =
		{
			__total             : 0,
			__sql               : null,
			loadedKey           : 'ctlEditView_',
			item                ,
			originalItem        : null,
			layout              : null,
			layoutSettings      : null,
			layoutEmailOptions  : null,
			layoutSmtpView      : null,
			layoutGoogleOptions : null,
			layoutICloudOptions : null,
			EDIT_NAME           ,
			DUPLICATE           : false,
			LAST_DATE_MODIFIED  : null,
			SUB_TITLE           : null,
			editedItem          : null,
			dependents          : {},
			error               : null,
			smtpserver          ,
			sExchangeServerURL  ,
			bGoogleAppsEnabled  ,
			biCloudEnabled      ,
			bfacebookEnableLogin,
			isDuplicate         ,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { isSearchView } = this.props;
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
		const { MODULE_NAME, ID, DuplicateID, MyAccount } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			// 10/12/2019 Paul.  Add support for parent assignment during creation. 
			// 07/13/2020 Paul.  Process the GoogleApps OAuth code after loading the item. 
			let rowDefaultSearch         : any = this.props.rowDefaultSearch;
			// 10/13/2020 Paul.  Make the condition more explicit. 
			if ( rowDefaultSearch === undefined || rowDefaultSearch == null )
			{
				let default_theme       : string  = Crm_Config.ToString ('default_theme'       );
				let default_language    : string  = Crm_Config.ToString ('default_language'    );
				let default_date_format : string  = Crm_Config.ToString ('default_date_format' );
				let default_time_format : string  = Crm_Config.ToString ('default_time_format' );
				let default_timezone    : string  = Crm_Config.ToString ('default_timezone'    );
				let default_currency    : string  = Crm_Config.ToString ('default_currency'    );
				let save_query          : boolean = Crm_Config.ToBoolean('save_query'          );
				let group_tabs          : boolean = Crm_Config.ToBoolean('group_tabs'          );
				let subpanel_tabs       : boolean = Crm_Config.ToBoolean('subpanel_tabs'       );
				if ( Sql.IsEmptyString(default_theme) )
					default_theme = 'Arctic';
				rowDefaultSearch =
				{
					THEME        : default_theme      ,
					LANG         : default_language   ,
					DATE_FORMAT  : default_date_format,
					TIME_FORMAT  : default_time_format,
					TIMEZONE_ID  : default_timezone   ,
					CURRENCY_ID  : default_currency   ,
					SAVE_QUERY   : save_query         ,
					GROUP_TABS   : group_tabs         ,
					SUBPANEL_TABS: subpanel_tabs      ,
				};
			}
			// 02/08/2021 Paul.  We need to make sure that a non-user enters this view. 
			let   allow_admin_roles   : boolean = Crm_Config.ToBoolean('allow_admin_roles'   );
			if ( !MyAccount )
			{
				if ( !Security.IS_ADMIN() && !(allow_admin_roles && SplendidCache.AdminUserAccess('Users', 'edit') >= 0) )
				{
					// 02/08/2021 Paul.  Reload instead of Reset so that we can re-authenticate after failed admin authentication. 
					// 02/08/2021 Paul.  Must clear the IsInitialized flag in order to force a reload. 
					SplendidCache.IsInitialized = false;
					// 07/14/2021 Paul.  Use indexedDB to cache session state. 
					// 10/30/2021 Paul.  Must wait for clear to finish before reloading. 
					await Application_ClearStore();
					this.props.history.push(`/Reload/Users/EditMyAccount`);
					return;
				}
			}

			const layout              : EDITVIEWS_FIELD[] = EditView_LoadLayout(EDIT_NAME);
			let   layoutSettings      : EDITVIEWS_FIELD[] = EditView_LoadLayout(EDIT_NAME + '.Settings'      );
			let   layoutEmailOptions  : EDITVIEWS_FIELD[] = EditView_LoadLayout('Users.EditMailOptions'      );
			let   layoutSmtpView      : EDITVIEWS_FIELD[] = EditView_LoadLayout('Users.SmtpView'             );
			let   layoutGoogleOptions : EDITVIEWS_FIELD[] = EditView_LoadLayout('Users.EditGoogleAppsOptions');
			let   layoutICloudOptions : EDITVIEWS_FIELD[] = EditView_LoadLayout('Users.EditICloudOptions'    );
			this.MAIL_SENDTYPE_Changed(layoutSmtpView, null);
			if ( !Sql.IsEmptyGuid(ID) )
			{
				let layPASSWORD: EDITVIEWS_FIELD = EditView_FindField(layoutSettings, 'PASSWORD');
				if ( layPASSWORD )
				{
					layPASSWORD.hidden = true;
				}
			}
			if ( !Security.IS_ADMIN() )
			{
				EditView_RemoveField(layoutSettings, 'IS_ADMIN'            );
				EditView_RemoveField(layoutSettings, 'Users.LBL_ADMIN_TEXT');
				EditView_RemoveField(layoutSettings, 'SYSTEM_GENERATED_PASSWORD'               );
				EditView_RemoveField(layoutSettings, 'Users.LBL_SYSTEM_GENERATED_PASSWORD_TEXT');
			}
			if ( !allow_admin_roles || !(SplendidCache.AdminUserAccess('Users', 'edit') >= 0) )
			{
				EditView_RemoveField(layoutSettings, 'IS_ADMIN_DELEGATE');
				EditView_RemoveField(layoutSettings, 'Users.LBL_ADMIN_DELEGATE_TEXT');
			}
			let layDATE_FORMAT: EDITVIEWS_FIELD = EditView_FindField(layoutSettings, 'DATE_FORMAT');
			if ( layDATE_FORMAT != null )
			{
				layDATE_FORMAT.LIST_NAME = 'DateFormat.' + Security.USER_LANG();
			}
			let layTIME_FORMAT: EDITVIEWS_FIELD = EditView_FindField(layoutSettings, 'TIME_FORMAT');
			if ( layTIME_FORMAT != null )
			{
				layTIME_FORMAT.LIST_NAME = 'TimeFormat.' + Security.USER_LANG();
			}
			let layMAIL_SMTPPASS: EDITVIEWS_FIELD = EditView_FindField(layoutSmtpView, 'MAIL_SMTPPASS');
			if ( layMAIL_SMTPPASS != null )
			{
				layMAIL_SMTPPASS.DATA_REQUIRED = false;
				layMAIL_SMTPPASS.UI_REQUIRED = false;
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			if ( this._isMounted )
			{
				this.setState(
				{
					layout                   ,
					layoutSettings           ,
					layoutEmailOptions       ,
					layoutSmtpView           ,
					layoutGoogleOptions      ,
					layoutICloudOptions      ,
					item                     : (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem               : null,
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
					await this.LoadItem(MODULE_NAME, DuplicateID, layoutSmtpView);
				}
				else
				{
					await this.LoadItem(MODULE_NAME, ID, layoutSmtpView);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private MAIL_SENDTYPE_Changed = (layoutSmtpView: EDITVIEWS_FIELD[], MAIL_SENDTYPE: string) =>
	{
		let bSmtp: boolean = (MAIL_SENDTYPE == 'smtp');
		EditView_HideField(layoutSmtpView, 'MAIL_SMTPSERVER'  , !bSmtp);
		EditView_HideField(layoutSmtpView, 'MAIL_SMTPPORT'    , !bSmtp);
		EditView_HideField(layoutSmtpView, 'MAIL_SMTPAUTH_REQ', !bSmtp);
		EditView_HideField(layoutSmtpView, 'MAIL_SMTPSSL'     , !bSmtp);
	}

	private LoadItem = async (sMODULE_NAME: string, sID: string, layoutSmtpView: EDITVIEWS_FIELD[]) =>
	{
		const { callback, isSearchView, isUpdatePanel, MyAccount } = this.props;
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				let d: any = null;
				if ( MyAccount )
				{
					// 10/05/2020 Paul.  Use the GetMyUserProfile call just in case the User module has been disabled for the user. 
					d = await GetMyUserProfile();
				}
				else
				{
					d = await EditView_LoadItem(sMODULE_NAME, sID);
				}
				let item: any = d.results;
				
				let LAST_DATE_MODIFIED: Date = null;
				let lblGoogleAuthorizedStatus: string = '';
				let lblOfficeAuthorizedStatus: string = '';
				if ( item != null )
				{
					// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
					if ( item['DATE_MODIFIED'] !== undefined )
					{
						LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
					}
					// 11/09/2020 Paul.  We need to initialize default values if the current value is null. 
					// This will allow the theme to be disabled while ensuring that the default is used. 
					if ( item['LANG'         ] == null ) item['LANG'         ] = Crm_Config.ToString ('default_language'     );
					if ( item['THEME'        ] == null ) item['THEME'        ] = Crm_Config.ToString ('default_theme'        );
					if ( item['DATE_FORMAT'  ] == null ) item['DATE_FORMAT'  ] = Crm_Config.ToString ('default_date_format'  );
					if ( item['TIME_FORMAT'  ] == null ) item['TIME_FORMAT'  ] = Crm_Config.ToString ('default_time_format'  );
					if ( item['CURRENCY_ID'  ] == null ) item['CURRENCY_ID'  ] = Crm_Config.ToString ('default_currency'     );
					if ( item['TIMEZONE_ID'  ] == null ) item['TIMEZONE_ID'  ] = Crm_Config.ToString ('default_timezone'     );
					if ( item['GROUP_TABS'   ] == null ) item['GROUP_TABS'   ] = Crm_Config.ToBoolean('default_group_tabs'   );
					if ( item['SUBPANEL_TABS'] == null ) item['SUBPANEL_TABS'] = Crm_Config.ToBoolean('default_subpanel_tabs');
					
					this.MAIL_SENDTYPE_Changed(layoutSmtpView, item['MAIL_SENDTYPE']);
					// 07/13/2020 Paul.  Process the GoogleApps OAuth code after loading the item. 
					let queryParams : any = qs.parse(location.search);
					if ( !Sql.IsEmptyString(queryParams['oauth_host']) )
					{
						let oauth_host: string = Sql.ToString(queryParams['oauth_host']);
						let error     : string = Sql.ToString(queryParams['error'     ]);
						let code      : string = Sql.ToString(queryParams['code'      ]);
						if ( oauth_host == 'GoogleApps' )
						{
							// 04/01/2021 Paul.  We are no longer going to save the user record prior to OAuth Authorize, so update the send type with OAuth response. 
							item['MAIL_SENDTYPE'] = 'GoogleApps';
							this.MAIL_SENDTYPE_Changed(layoutSmtpView, item['MAIL_SENDTYPE']);
							if ( !Sql.IsEmptyString(error) )
							{
								lblGoogleAuthorizedStatus = error;
							}
							else if ( !Sql.IsEmptyString(code) )
							{
								try
								{
									this.setState(
									{
										lblSmtpAuthorizedStatus  : '',
										lblCloudAuthorizedStatus : '',
										lblGoogleAuthorizedStatus: L10n.Term('OAuth.LBL_AUTHORIZING'),
										lblOfficeAuthorizedStatus: '',
									});
									if ( this._isMounted )
									{
										let redirect_url: string  = window.location.origin;
										redirect_url += window.location.pathname.replace(this.props.location.pathname, '');
										redirect_url += '/GoogleOAuth';

										let obj: any = {};
										obj.ID            = (this.props.MyAccount ? Security.USER_ID() : this.props.ID);
										obj.MAIL_SENDTYPE = Sql.ToString(item['MAIL_SENDTYPE']);
										obj.code          = code;
										obj.redirect_url  = redirect_url;
										//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', redirect_url);
										
										let sBody: string = JSON.stringify(obj);
										let res  = await CreateSplendidRequest('Users/Rest.svc/GoogleApps_Authorize', 'POST', 'application/octet-stream', sBody);
										let json = await GetSplendidResult(res);
										// 02/09/2017 Paul.  Update the email address. 
										// 07/14/2020 Paul.  If email not accessible, just ignore as we have a valid token. 
										if ( !Sql.IsEmptyString(json.d) )
											item['EMAIL1'                  ] = json.d;
										item['GOOGLEAPPS_OAUTH_ENABLED'] = true;
										//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', json);
										lblGoogleAuthorizedStatus = L10n.Term('OAuth.LBL_TEST_SUCCESSFUL');
										this.setState({ lblGoogleAuthorizedStatus });
										// 10/08/2020 Paul.  MyAccount editing is no longer under Administration.
										this.props.history.replace(this.props.MyAccount ? '/Users/EditMyAccount' : '/Administration/Users/Edit/' + this.props.ID);
									}
								}
								catch(error)
								{
									// 10/08/2020 Paul.  MyAccount editing is no longer under Administration.
									console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
									lblGoogleAuthorizedStatus = error.message;
									this.setState({ lblGoogleAuthorizedStatus });
									this.props.history.replace(this.props.MyAccount ? '/Users/EditMyAccount' : '/Administration/Users/Edit/' + this.props.ID);
								}
							}
						}
						else if ( oauth_host == 'Office365' )
						{
							// 04/01/2021 Paul.  We are no longer going to save the user record prior to OAuth Authorize, so update the send type with OAuth response. 
							item['MAIL_SENDTYPE'] = 'Office365';
							this.MAIL_SENDTYPE_Changed(layoutSmtpView, item['MAIL_SENDTYPE']);
							if ( !Sql.IsEmptyString(error) )
							{
								lblGoogleAuthorizedStatus = error;
							}
							else if ( !Sql.IsEmptyString(code) )
							{
								try
								{
									this.setState(
									{
										lblSmtpAuthorizedStatus  : '',
										lblCloudAuthorizedStatus : '',
										lblGoogleAuthorizedStatus: '',
										lblOfficeAuthorizedStatus: L10n.Term('OAuth.LBL_AUTHORIZING'),
									});
									if ( this._isMounted )
									{
										let redirect_url: string  = window.location.origin;
										redirect_url += window.location.pathname.replace(this.props.location.pathname, '');
										redirect_url += '/Office365OAuth';

										let obj: any = {};
										obj.ID            = (this.props.MyAccount ? Security.USER_ID() : this.props.ID);
										obj.MAIL_SENDTYPE = Sql.ToString(item['MAIL_SENDTYPE']);
										obj.code          = code;
										obj.redirect_url  = redirect_url;
										//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', redirect_url);
										
										let sBody: string = JSON.stringify(obj);
										let res  = await CreateSplendidRequest('Users/Rest.svc/Office365_Authorize', 'POST', 'application/octet-stream', sBody);
										let json = await GetSplendidResult(res);
										// 02/09/2017 Paul.  Update the email address. 
										// 07/14/2020 Paul.  If email not accessible, just ignore as we have a valid token. 
										if ( !Sql.IsEmptyString(json.d) )
											item['EMAIL1'                  ] = json.d;
										item['OFFICE365_OAUTH_ENABLED'] = true;
										//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', json);
										lblOfficeAuthorizedStatus = L10n.Term('OAuth.LBL_TEST_SUCCESSFUL');
										this.setState({ lblOfficeAuthorizedStatus });
										// 10/08/2020 Paul.  MyAccount editing is no longer under Administration.
										this.props.history.replace(this.props.MyAccount ? '/Users/EditMyAccount' : '/Administration/Users/Edit/' + this.props.ID);
									}
								}
								catch(error)
								{
									// 10/08/2020 Paul.  MyAccount editing is no longer under Administration.
									console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
									lblOfficeAuthorizedStatus = error.message;
									this.setState({ lblOfficeAuthorizedStatus });
									this.props.history.replace(this.props.MyAccount ? '/Users/EditMyAccount' : '/Administration/Users/Edit/' + this.props.ID);
								}
							}
						}
					}
				}
				if ( this._isMounted )
				{
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any    = Sql.DataPrivacyErasedField(item, 'NAME');
					// 07/04/2020 Paul.  We need to change the key so that the loaded data replaces the default data. 
					let loadedKey: string = 'ctlEditView_' + sID;
					this.setState(
					{
						item                     ,
						originalItem             : item,
						SUB_TITLE                ,
						__sql                    : d.__sql,
						LAST_DATE_MODIFIED       ,
						loadedKey                ,
						lblGoogleAuthorizedStatus,
						lblOfficeAuthorizedStatus,
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

	private UpdateDependancy(DATA_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any)
	{
		let ref = this.refMap[DATA_FIELD];
		if ( ref && ref.current )
		{
			ref.current.updateDependancy(null, DATA_VALUE, PROPERTY_NAME, item);
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
		// 10/21/2020  Paul.  Populate City, State and Country when postal code changes. 
		else if ( PARENT_FIELD == 'ADDRESS_POSTALCODE' && item != null )
		{
			if ( !Sql.IsEmptyString(item.CITY) )
			{
				this.UpdateDependancy('ADDRESS_CITY', item.CITY, 'value', item);
			}
			if ( !Sql.IsEmptyString(item.STATE) )
			{
				this.UpdateDependancy('ADDRESS_STATE', item.STATE, 'value', item);
			}
			if ( !Sql.IsEmptyString(item.COUNTRY) )
			{
				this.UpdateDependancy('ADDRESS_COUNTRY', item.COUNTRY, 'value', item);
			}
		}
		else if ( PARENT_FIELD == 'LANG' )
		{
			let ref = this.refMap['DATE_FORMAT'];
			if ( ref )
			{
				ref.current.updateDependancy(PARENT_FIELD, 'DateFormat.' + DATA_VALUE, 'list', item);
			}
			ref = this.refMap['TIME_FORMAT'];
			if ( ref )
			{
				ref.current.updateDependancy(PARENT_FIELD, 'TimeFormat.' + DATA_VALUE, 'list', item);
			}
		}
		else if ( PARENT_FIELD == 'MAIL_SENDTYPE' )
		{
			this.MAIL_SENDTYPE_Changed(this.state.layoutSmtpView, DATA_VALUE);
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
		const { ID, MODULE_NAME, MyAccount, history, location } = this.props;
		const { LAST_DATE_MODIFIED, originalItem, isDuplicate } = this.state;
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
					row = {
						ID: isDuplicate ? null : ID
					};
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
					if ( nInvalidFields == 0 )
					{
						if ( LAST_DATE_MODIFIED != null )
						{
							row['LAST_DATE_MODIFIED'] = LAST_DATE_MODIFIED;
						}
						// 07/08/2020 Paul.  Don't update unchanged passwords. 
						if ( row['MAIL_SMTPPASS'] == Sql.sEMPTY_PASSWORD )
						{
							delete row['MAIL_SMTPPASS'];
						}
						// 07/08/2020 Paul.  Google uses OAuth, so no GOOGLEAPPS_PASSWORD. 
						if ( row['ICLOUD_PASSWORD'] == Sql.sEMPTY_PASSWORD )
						{
							delete row['ICLOUD_PASSWORD'];
						}
						// 07/09/2020 Paul.  Password only applies when creating a new user or creating a duplicate. 
						if ( !Sql.IsEmptyGuid(ID) || isDuplicate )
						{
							delete row['PASSWORD'];
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
							// 07/09/2020 Paul.  Even though USERS is an admin table, all updating will be run through the primary API instead of the Admin API.
							// This is so that we can keep all the password processing code in one location. 
							row.ID = await UpdateModule(MODULE_NAME, row, (isDuplicate ? null : ID), false);
							// 03/24/2021 Paul.  We may need to enable Exchange Sync.  Office365 is enabled in Office365_Authorize. 
							if ( row['MAIL_SENDTYPE'] == 'Exchange-Password' )
							{
								let res  = await CreateSplendidRequest('Users/Rest.svc/EnableExchangeSync?ID=' + row.ID, 'POST', 'application/octet-stream', null);
								let json = await GetSplendidResult(res);
							}
							// 07/02/2020 Paul.  Redirect to MyAccount. 
							if ( MyAccount )
							{
								if ( originalItem && (originalItem['THEME'] != row['THEME'] || originalItem['LANG'] != row['LANG']) )
								{
									SplendidCache.IsInitialized = false;
									// 07/14/2021 Paul.  Use indexedDB to cache session state. 
									// 10/30/2021 Paul.  Must wait for clear to finish before reloading. 
									await Application_ClearStore();
									history.push(`/Reload/${MODULE_NAME}/MyAccount`);
								}
								else if ( originalItem && (originalItem['DATE_FORMAT'] != row['DATE_FORMAT'] || originalItem['TIME_FORMAT'] != row['TIME_FORMAT'] || originalItem['CURRENCY_ID'] != row['CURRENCY_ID']) )
								{
									let user: any = await GetUserProfile();
									Credentials.SetUserProfile(user);
									history.push(`/Reset/${MODULE_NAME}/MyAccount`);
								}
								else
								{
									history.push(`/Reset/${MODULE_NAME}/MyAccount`);
								}
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
					// 07/02/2020 Paul.  Redirect to MyAccount. 
					if ( MyAccount )
					{
						history.push(`/Reset/${MODULE_NAME}/MyAccount`);
					}
					else if ( Sql.IsEmptyString(ID) )
					{
						history.push(`/Reset/Administration/${MODULE_NAME}/List`);
					}
					else
					{
						history.push(`/Reset/Administration/${MODULE_NAME}/View/${ID}`);
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

	private _onButtonsLoaded = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onButtonsLoaded');
		let bFacebookEnabled: boolean = Crm_Config.ToBoolean('facebook.EnableLogin') && !Sql.IsEmptyString(Crm_Config.ToString('facebook.AppID'));
		// 08/12/2019 Paul.  Here is where we can disable buttons immediately after they were loaded. 
		if ( this.headerButtons.current != null )
		{
			this.headerButtons.current.ShowButton('Facebook', bFacebookEnabled);
		}
		if ( this.dynamicButtonsBottom.current != null )
		{
			this.dynamicButtonsBottom.current.ShowButton('Facebook', bFacebookEnabled);
		}
	}

	private _onButtonLink = (lay: DYNAMIC_BUTTON) =>
	{
		this.Page_Command(lay.COMMAND_NAME, null);
	}

	private _onFieldDidMount = (DATA_FIELD: string, component: any): void =>
	{
		const { item } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onFieldDidMount', DATA_FIELD);
		try
		{
			if ( DATA_FIELD == 'THEME' )
			{
				let disable_theme_change: boolean = Crm_Config.ToBoolean('disable_theme_change');
				if ( disable_theme_change )
				{
					component.updateDependancy(null, false, 'enabled', null);
				}
			}
			if ( item )
			{
				// 12/06/2005 Paul.  A user can only edit his own user name if Windows Authentication is off. 
				if ( DATA_FIELD == 'USER_NAME' )
				{
					// 11/26/2006 Paul.  A user cannot edit their own user name. This is a job for the admin. 
					let bUSER_NAME_Enabled: boolean = false;
					// 12/06/2005 Paul.  An administrator can always edit the user name.  This is to allow him to pre-add any NTLM users. 
					if ( SplendidCache.AdminUserAccess('Users', 'edit') >= 0 )
						bUSER_NAME_Enabled = true;
					component.updateDependancy(null, bUSER_NAME_Enabled, 'enabled', null);
				}
				else if ( DATA_FIELD == 'STATUS' )
				{
					let bSTATUS_Enabled   : boolean = false;
					if ( SplendidCache.AdminUserAccess('Users', 'edit') >= 0 )
						bSTATUS_Enabled = true;
					component.updateDependancy(null, bSTATUS_Enabled, 'enabled', null);
				}
				else if ( !Sql.IsEmptyString(DATA_FIELD) && DATA_FIELD.indexOf('Users.LBL_') >= 0 )
				{
					component.updateDependancy(null, 'dataField', 'class', null);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onFieldDidMount ' + DATA_FIELD, error.message);
			this.setState({ error });
		}
	}

	private _onSmtpTest = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSmtpTest');
		try
		{
			this.setState(
			{
				lblSmtpAuthorizedStatus : L10n.Term('OAuth.LBL_TESTING'),
				lblCloudAuthorizedStatus: '',
			});
			if ( this._isMounted )
			{
				const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
				let obj: any = {};
				obj.ID                = currentItem['ID'               ];
				obj.FROM_ADDR         = currentItem['EMAIL1'           ];
				obj.FROM_NAME         = currentItem['FIRST_NAME'       ] + ' ' + currentItem['LAST_NAME'];
				obj.MAIL_SENDTYPE     = currentItem['MAIL_SENDTYPE'    ];
				obj.MAIL_SMTPUSER     = currentItem['MAIL_SMTPUSER'    ];
				obj.MAIL_SMTPPASS     = currentItem['MAIL_SMTPPASS'    ];
				obj.MAIL_SMTPSERVER   = currentItem['MAIL_SMTPSERVER'  ];
				obj.MAIL_SMTPPORT     = currentItem['MAIL_SMTPPORT'    ];
				obj.MAIL_SMTPAUTH_REQ = currentItem['MAIL_SMTPAUTH_REQ'];
				obj.MAIL_SMTPSSL      = currentItem['MAIL_SMTPSSL'     ];
				let sBody: string = JSON.stringify(obj);
				let res  = await CreateSplendidRequest('Users/Rest.svc/SendTestMessage', 'POST', 'application/octet-stream', sBody);
				let json = await GetSplendidResult(res);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSmtpTest', json);
				if ( this._isMounted )
				{
					this.setState(
					{
						lblSmtpAuthorizedStatus : json.d,
						lblCloudAuthorizedStatus: '',
					});
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSmtpTest', error);
			this.setState(
			{
				lblSmtpAuthorizedStatus : error.message,
				lblCloudAuthorizedStatus: '',
			});
		}
	}

	private _onICloudTest = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onICloudTest');
		try
		{
			this.setState(
			{
				lblSmtpAuthorizedStatus : '',
				lblCloudAuthorizedStatus: L10n.Term('OAuth.LBL_TESTING'),
			});
			if ( this._isMounted )
			{
				const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
				//await this.iCloud_getAuthToken(currentItem['ICLOUD_USERNAME'  ], currentItem['ICLOUD_PASSWORD'  ]);
				let obj: any = {};
				obj.ID                   = currentItem['ID'                  ];
				obj.MAIL_SMTPUSER        = currentItem['MAIL_SMTPUSER'       ];
				obj.MAIL_SMTPPASS        = currentItem['MAIL_SMTPPASS'       ];
				obj.ICLOUD_USERNAME      = currentItem['ICLOUD_USERNAME'     ];
				obj.ICLOUD_PASSWORD      = currentItem['ICLOUD_PASSWORD'     ];
				obj.ICLOUD_SECURITY_CODE = currentItem['ICLOUD_SECURITY_CODE'];
				let sBody: string = JSON.stringify(obj);
				let res  = await CreateSplendidRequest('Users/Rest.svc/iCloud_Validate', 'POST', 'application/octet-stream', sBody);
				let json = await GetSplendidResult(res);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onICloudTest', json);
				if ( this._isMounted )
				{
					this.setState(
					{
						lblSmtpAuthorizedStatus : '',
						lblCloudAuthorizedStatus: json.d,
					});
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onICloudTest', error);
			this.setState(
			{
				lblSmtpAuthorizedStatus : '',
				lblCloudAuthorizedStatus: error.message,
			});
		}
	}

	private _onGoogleAppsAuthorize = async () =>
	{
		const { ID, MODULE_NAME } = this.props;
		const { editedItem, isDuplicate } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGoogleAppsAuthorize');
		// 11/29/2020 Paul.  We need to update the send type if it changed as the OAuth redirect will lose this information. 
		// 04/01/2021 Paul.  We are no longer going to save the user record prior to OAuth Authorize, so update the send type with OAuth response. 
		//if ( !isDuplicate && !Sql.IsEmptyString(editedItem['MAIL_SENDTYPE']) )
		//{
		//	let row: any = { ID, MAIL_SENDTYPE: editedItem['MAIL_SENDTYPE'] };
		//	await UpdateModule(MODULE_NAME, row, ID, false);
		//}

		let client_id      : string = Crm_Config.ToString('GoogleApps.ClientID');
		let access_type    : string = 'offline';
		let approval_prompt: string = 'force';
		let response_type  : string = 'code';
		let scope          : string = 'profile';
		// 07/13/2020 Paul.  The redirect_url cannot include parameters.  Use state variable instead. 
		let state          : string = (this.props.MyAccount ? Security.USER_ID() : this.props.ID);
		let redirect_url   : string = window.location.origin;
		redirect_url += window.location.pathname.replace(this.props.location.pathname, '');
		redirect_url += '/GoogleOAuth';
		scope              += escape(' https://www.googleapis.com/auth/calendar');
		scope              += escape(' https://www.googleapis.com/auth/tasks'   );
		scope              += escape(' https://mail.google.com/'                );
		scope              += escape(' https://www.google.com/m8/feeds'         );
		let authenticateUrl = 'https://accounts.google.com/o/oauth2/auth'
		                    + '?client_id='       + client_id
		                    + '&access_type='     + access_type
		                    + '&approval_prompt=' + approval_prompt
		                    + '&response_type='   + response_type
		                    + '&redirect_uri='    + encodeURIComponent(redirect_url)
		                    + '&scope='           + scope
		                    + '&state='           + encodeURIComponent(state)
		                    ;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGoogleAppsAuthorize', redirect_url);
		window.location.href = authenticateUrl;
	}

	private _onGoogleAppsDelete = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGoogleAppsDelete');
		try
		{
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			let obj: any = {};
			obj.ID   = (this.props.MyAccount ? Security.USER_ID() : this.props.ID);
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Users/Rest.svc/GoogleApps_Delete', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			currentItem['GOOGLEAPPS_OAUTH_ENABLED'] = false;
			this.setState({ editedItem: currentItem });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onGoogleAppsDelete', error);
			this.setState({ lblGoogleAuthorizedStatus: error.message });
		}
	}

	private _onGoogleAppsTest = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGoogleAppsTest');
		try
		{
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			let obj: any = {};
			obj.ID   = (this.props.MyAccount ? Security.USER_ID() : this.props.ID);
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Users/Rest.svc/GoogleApps_Test', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			this.setState({ lblGoogleAuthorizedStatus: json.d });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onGoogleAppsTest', error);
			this.setState({ lblGoogleAuthorizedStatus: error.message });
		}
	}

	private _onGoogleAppsRefreshToken = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGoogleAppsRefreshToken');
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
		try
		{
			let obj: any = {};
			obj.ID   = (this.props.MyAccount ? Security.USER_ID() : this.props.ID);
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Users/Rest.svc/GoogleApps_RefreshToken', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			currentItem['GOOGLEAPPS_OAUTH_ENABLED'] = true;
			this.setState(
			{
				editedItem               : currentItem,
				lblGoogleAuthorizedStatus: L10n.Term('OAuth.LBL_TEST_SUCCESSFUL'),
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onGoogleAppsRefreshToken', error);
			currentItem['GOOGLEAPPS_OAUTH_ENABLED'] = false;
			this.setState(
			{
				editedItem               : currentItem,
				lblGoogleAuthorizedStatus: error.message
			});
		}
	}

	private _onOffice365Authorize = async () =>
	{
		const { ID, MODULE_NAME } = this.props;
		const { editedItem, isDuplicate } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onOffice365Authorize');
		// 11/29/2020 Paul.  We need to update the send type if it changed as the OAuth redirect will lose this information. 
		// 04/01/2021 Paul.  We are no longer going to save the user record prior to OAuth Authorize, so update the send type with OAuth response. 
		//if ( !isDuplicate && !Sql.IsEmptyString(editedItem['MAIL_SENDTYPE']) )
		//{
		//	let row: any = { ID, MAIL_SENDTYPE: editedItem['MAIL_SENDTYPE'] };
		//	await UpdateModule(MODULE_NAME, row, ID, false);
		//}

		// 11/28/2020 Paul.  Outlook REST API has been deprecated.  Use Microsoft Graph instead. https://docs.microsoft.com/en-us/outlook/rest/compare-graph
		let client_id      : string = Crm_Config.ToString('Exchange.ClientID');
		let response_type  : string = 'code';
		// 12/29/2020 Paul.  Update scope to allow sync of contacts, calendars and mailbox. 
		let scope          : string = "openid offline_access Mail.ReadWrite Mail.Send Contacts.ReadWrite Calendars.ReadWrite MailboxSettings.ReadWrite User.Read";
		// 07/13/2020 Paul.  The redirect_url cannot include parameters.  Use state variable instead. 
		let state          : string = (this.props.MyAccount ? Security.USER_ID() : this.props.ID);
		let redirect_url   : string = window.location.origin;
		redirect_url += window.location.pathname.replace(this.props.location.pathname, '');
		redirect_url += '/Office365OAuth';
		// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
		let tenant         : string = Crm_Config.ToString('Exchange.DirectoryTenantID');
		if ( Sql.IsEmptyString(tenant) )
			tenant = 'common';
		let authenticateUrl: string = 'https://login.microsoftonline.com/'+ tenant + '/oauth2/v2.0/authorize'
		                   + '?response_type=' + response_type
		                   + '&client_id='     + client_id
		                   + '&redirect_uri='  + encodeURIComponent(redirect_url)
		                   + '&scope='         + escape(scope)
		                   + '&state='         + state
		                   + '&response_mode=query';
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onOffice365Authorize', redirect_url);
		window.location.href = authenticateUrl;
	}

	private _onOffice365Delete = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onOffice365Delete');
		try
		{
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			let obj: any = {};
			obj.ID   = (this.props.MyAccount ? Security.USER_ID() : this.props.ID);
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Users/Rest.svc/Office365_Delete', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			currentItem['OFFICE365_OAUTH_ENABLED'] = false;
			this.setState({ editedItem: currentItem });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onOffice365Delete', error);
			this.setState({ lblOfficeAuthorizedStatus: error.message });
		}
	}

	private _onOffice365Test = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onOffice365Test');
		try
		{
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			let obj: any = {};
			obj.ID   = (this.props.MyAccount ? Security.USER_ID() : this.props.ID);
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Users/Rest.svc/Office365_Test', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			this.setState({ lblOfficeAuthorizedStatus: json.d });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onOffice365Test', error);
			this.setState({ lblOfficeAuthorizedStatus: error.message });
		}
	}

	private _onOffice365RefreshToken = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onOffice365RefreshToken');
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
		try
		{
			let obj: any = {};
			obj.ID   = (this.props.MyAccount ? Security.USER_ID() : this.props.ID);
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Users/Rest.svc/Office365_RefreshToken', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			currentItem['OFFICE365_OAUTH_ENABLED'] = true;
			this.setState(
			{
				editedItem               : currentItem,
				lblOfficeAuthorizedStatus: L10n.Term('OAuth.LBL_TEST_SUCCESSFUL'),
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onOffice365RefreshToken', error);
			currentItem['OFFICE365_OAUTH_ENABLED'] = false;
			this.setState(
			{
				editedItem               : currentItem,
				lblOfficeAuthorizedStatus: error.message
			});
		}
	}

	public render()
	{
		const { MODULE_NAME, ID, LAYOUT_NAME, DuplicateID, isSearchView, isUpdatePanel, isQuickCreate, callback } = this.props;
		const { item, layout, layoutSettings, layoutEmailOptions, layoutSmtpView, layoutGoogleOptions, layoutICloudOptions, EDIT_NAME, SUB_TITLE, error } = this.state;
		const { smtpserver,sExchangeServerURL, bGoogleAppsEnabled, biCloudEnabled, bfacebookEnableLogin, isDuplicate } = this.state;
		const { lblSmtpAuthorizedStatus, lblGoogleAuthorizedStatus, lblCloudAuthorizedStatus, lblOfficeAuthorizedStatus } = this.state;
		const { __total, __sql, loadedKey } = this.state;
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
		if ( SplendidCache.IsInitialized )
		{
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<React.Fragment key={ loadedKey }>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: !isSearchView && !isUpdatePanel, onLayoutLoaded: this._onButtonsLoaded, onButtonLink: this._onButtonLink, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				{ LAYOUT_NAME && LAYOUT_NAME.indexOf('.MassUpdate') < 0
				? <DumpSQL SQL={ __sql } />
				: null
				}
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layoutSettings      , this.refMap, callback, this._createDependency, this._onFieldDidMount, this._onChange, this._onUpdate, onSubmit, (isSearchView || isQuickCreate ? null : 'tabForm'), this.Page_Command) }
				<h4>{ L10n.Term('Users.LBL_USER_SETTINGS') }</h4>
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layout              , this.refMap, callback, this._createDependency, this._onFieldDidMount, this._onChange, this._onUpdate, onSubmit, (isSearchView || isQuickCreate ? null : 'tabForm'), this.Page_Command) }
				<h4>{ L10n.Term('Users.LBL_MAIL_OPTIONS_TITLE') }</h4>
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layoutEmailOptions  , this.refMap, callback, this._createDependency, this._onFieldDidMount, this._onChange, this._onUpdate, onSubmit, (isSearchView || isQuickCreate ? null : 'tabForm'), this.Page_Command) }
				{ (currentItem['MAIL_SENDTYPE'] == 'smtp' || currentItem['MAIL_SENDTYPE'] == 'Exchange-Password')
				? <div>
					<h4 style={ {marginTop: '6px'} }>{ L10n.Term('Users.LBL_SMTP_TITLE') }</h4>
					<div className='tabForm'>
						{ SplendidDynamic_EditView.AppendEditViewFields(item, layoutSmtpView      , this.refMap, callback, this._createDependency, this._onFieldDidMount, this._onChange, this._onUpdate, onSubmit, null, this.Page_Command) }
						<div style={ {margin: '4px'} }>
							<button className='button' onClick={ this._onSmtpTest }>  { L10n.Term('Users.LBL_EMAIL_TEST') }  </button>
							&nbsp;
							<span id='lblSmtpAuthorizedStatus' className='error'>{ lblSmtpAuthorizedStatus }</span>
						</div>
					</div>
				</div>
				: null
				}
				{ !isDuplicate && currentItem['MAIL_SENDTYPE'] == 'Office365'
				? <div>
					<h4 style={ {marginTop: '6px'} }>{ L10n.Term('Users.LBL_OFFICE365_OPTIONS_TITLE') }</h4>
					<div className='tabForm'>
						<div style={ {margin: '4px'} }>
							{ Sql.ToBoolean(currentItem['OFFICE365_OAUTH_ENABLED'])
							? <span id='lblOffice365Authorized' style={ {marginRight: '10px'} }>{ L10n.Term('OAuth.LBL_AUTHORIZED') }</span>
							: null
							}
							{ !Sql.ToBoolean(currentItem['OFFICE365_OAUTH_ENABLED'])
							? <button className='button' onClick={ this._onOffice365Authorize    } style={ {marginRight: '10px'} }>  { L10n.Term('OAuth.LBL_AUTHORIZE_BUTTON_LABEL') }  </button>
							: null
							}
							{ Sql.ToBoolean(currentItem['OFFICE365_OAUTH_ENABLED'])
							? <button className='button' onClick={ this._onOffice365Delete       } style={ {marginRight: '10px'} }>  { L10n.Term('OAuth.LBL_DELETE_BUTTON_LABEL') }  </button>
							: null
							}
							{ Sql.ToBoolean(currentItem['OFFICE365_OAUTH_ENABLED'])
							? <button className='button' onClick={ this._onOffice365Test         } style={ {marginRight: '10px'} }>  { L10n.Term('OAuth.LBL_TEST_BUTTON_LABEL') }  </button>
							: null
							}
							{ Sql.ToBoolean(currentItem['OFFICE365_OAUTH_ENABLED'])
							? <button className='button' onClick={ this._onOffice365RefreshToken } style={ {marginRight: '10px'} }>  { L10n.Term('OAuth.LBL_REFRESH_TOKEN_LABEL') }  </button>
							: null
							}
							<span id='lblOfficeAuthorizedStatus' className='error'>{ lblOfficeAuthorizedStatus }</span>
						</div>
					</div>
				</div>
				: null
				}
				{ !isDuplicate && bGoogleAppsEnabled
				? <div>
					<h4 style={ {marginTop: '6px'} }>{ L10n.Term('Users.LBL_GOOGLEAPPS_OPTIONS_TITLE') }</h4>
					<div className='tabForm'>
						{ SplendidDynamic_EditView.AppendEditViewFields(item, layoutGoogleOptions , this.refMap, callback, this._createDependency, this._onFieldDidMount, this._onChange, this._onUpdate, onSubmit, null, this.Page_Command) }
						<div style={ {margin: '4px'} }>
							{ Sql.ToBoolean(currentItem['GOOGLEAPPS_OAUTH_ENABLED'])
							? <span id='lblGoogleAppsAuthorized' style={ {marginRight: '10px'} }>{ L10n.Term('OAuth.LBL_AUTHORIZED') }</span>
							: null
							}
							{ !Sql.ToBoolean(currentItem['GOOGLEAPPS_OAUTH_ENABLED'])
							? <button className='button' onClick={ this._onGoogleAppsAuthorize    } style={ {marginRight: '10px'} }>  { L10n.Term('OAuth.LBL_AUTHORIZE_BUTTON_LABEL') }  </button>
							: null
							}
							{ Sql.ToBoolean(currentItem['GOOGLEAPPS_OAUTH_ENABLED'])
							? <button className='button' onClick={ this._onGoogleAppsDelete       } style={ {marginRight: '10px'} }>  { L10n.Term('OAuth.LBL_DELETE_BUTTON_LABEL') }  </button>
							: null
							}
							{ Sql.ToBoolean(currentItem['GOOGLEAPPS_OAUTH_ENABLED'])
							? <button className='button' onClick={ this._onGoogleAppsTest         } style={ {marginRight: '10px'} }>  { L10n.Term('OAuth.LBL_TEST_BUTTON_LABEL') }  </button>
							: null
							}
							{ Sql.ToBoolean(currentItem['GOOGLEAPPS_OAUTH_ENABLED'])
							? <button className='button' onClick={ this._onGoogleAppsRefreshToken } style={ {marginRight: '10px'} }>  { L10n.Term('OAuth.LBL_REFRESH_TOKEN_LABEL') }  </button>
							: null
							}
							<span id='lblGoogleAuthorizedStatus' className='error'>{ lblGoogleAuthorizedStatus }</span>
						</div>
					</div>
				</div>
				: null
				}
				{ biCloudEnabled
				? <div>
					<h4 style={ {marginTop: '6px'} }>{ L10n.Term('Users.LBL_ICLOUD_OPTIONS_TITLE') }</h4>
					<div className='tabForm'>
						{ SplendidDynamic_EditView.AppendEditViewFields(item, layoutICloudOptions, this.refMap, callback, this._createDependency, this._onFieldDidMount, this._onChange, this._onUpdate, onSubmit, null, this.Page_Command) }
						<div style={ {margin: '4px'} }>
							<button className='button' onClick={ this._onICloudTest }>  { L10n.Term('Users.LBL_EMAIL_TEST') }  </button>
							&nbsp;
							<span id='lblCloudAuthorizedStatus' className='error'>{ lblCloudAuthorizedStatus }</span>
						</div>
					</div>
				</div>
				: null
				}
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

