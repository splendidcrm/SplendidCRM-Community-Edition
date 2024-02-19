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
import { RouteComponentProps, withRouter }          from '../Router5'                         ;
import { observer }                                 from 'mobx-react'                               ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'           ;
// 2. Store and Types. 
import { EditComponent }                            from '../../../types/EditComponent'             ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'             ;
import EDITVIEWS_FIELD                              from '../../../types/EDITVIEWS_FIELD'           ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                     ;
import L10n                                         from '../../../scripts/L10n'                    ;
import Security                                     from '../../../scripts/Security'                ;
import Credentials                                  from '../../../scripts/Credentials'             ;
import SplendidCache                                from '../../../scripts/SplendidCache'           ;
import SplendidDynamic_EditView                     from '../../../scripts/SplendidDynamic_EditView';
import { Crm_Config }                               from '../../../scripts/Crm'                     ;
import { Admin_GetReactState }                      from '../../../scripts/Application'             ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                   ;
import { EditView_LoadItem, EditView_LoadLayout, EditView_FindField, EditView_HideField } from '../../../scripts/EditView'                ;
import { UpdateModule }                             from '../../../scripts/ModuleUpdate'            ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'         ;
// 4. Components and Views. 
import ErrorComponent                               from '../../../components/ErrorComponent'       ;
import DumpSQL                                      from '../../../components/DumpSQL'              ;
import DynamicButtons                               from '../../../components/DynamicButtons'       ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';

const MODULE_NAME   : string = 'OutboundEmail';

interface IAdminEditViewProps extends RouteComponentProps<any>
{
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
	editedItem        : any;
	dependents        : Record<string, Array<any>>;
	error?            : any;

	lblSmtpAuthorizedStatus?  : string;
	lblGoogleAuthorizedStatus?: string;
	lblOfficeAuthorizedStatus?: string;
	bExchangeEnabled          : boolean;
	bOffice365Enabled         : boolean;
	bGoogleAppsEnabled        : boolean;
}

@observer
export default class OutboundEmailEditView extends React.Component<IAdminEditViewProps, IAdminEditViewState>
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
		let EDIT_NAME = MODULE_NAME + '.EditView';
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		let bExchangeEnabled  : boolean = !Sql.IsEmptyString(Crm_Config.ToString('Exchange.ServerURL'));
		let bOffice365Enabled : boolean = !Sql.IsEmptyString(Crm_Config.ToString('Exchange.ClientID' ));
		let bGoogleAppsEnabled: boolean = Crm_Config.ToBoolean('GoogleApps.Enabled');
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
			editedItem        : null,
			dependents        : {},
			error             : null,
			bExchangeEnabled  ,
			bOffice365Enabled ,
			bGoogleAppsEnabled,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
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
		const { ID, rowDefaultSearch, DuplicateID } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			const layout = EditView_LoadLayout(EDIT_NAME);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
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
				let LAST_DATE_MODIFIED: Date = null;
				let lblGoogleAuthorizedStatus: string = '';
				let lblOfficeAuthorizedStatus: string = '';
				// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
				if ( item != null && item['DATE_MODIFIED'] !== undefined )
				{
					LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
					// 03/24/2021 Paul.  We have noticed some bad data.  Correct as React is case-significant. 
					if ( item['MAIL_SENDTYPE'] == 'office365' )
					{
						item['MAIL_SENDTYPE'] = 'Office365'
					}
					this.MAIL_SENDTYPE_Changed(this.state.layout, item['MAIL_SENDTYPE']);
				}
				// 07/13/2020 Paul.  Process the GoogleApps OAuth code after loading the item. 
				let queryParams : any = qs.parse(location.search);
				if ( !Sql.IsEmptyString(queryParams['oauth_host']) )
				{
					let oauth_host: string = Sql.ToString(queryParams['oauth_host']);
					let error     : string = Sql.ToString(queryParams['error'     ]);
					let code      : string = Sql.ToString(queryParams['code'      ]);
					if ( oauth_host == 'GoogleApps' )
					{
						item['MAIL_SENDTYPE'] = 'GoogleApps';
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
									lblGoogleAuthorizedStatus: L10n.Term('OAuth.LBL_AUTHORIZING'),
									lblOfficeAuthorizedStatus: '',
								});
								if ( this._isMounted )
								{
									let redirect_url: string  = window.location.origin;
									redirect_url += window.location.pathname.replace(this.props.location.pathname, '');
									redirect_url += '/GoogleOAuth';

									let obj: any =
									{
										code        ,
										redirect_url,
									};
									//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', redirect_url);
									
									let sBody: string = JSON.stringify(obj);
									let res  = await CreateSplendidRequest('Administration/' + MODULE_NAME + '/Rest.svc/GoogleApps_Authorize?ID=' + sID, 'POST', 'application/octet-stream', sBody);
									let json = await GetSplendidResult(res);
									item['GOOGLEAPPS_OAUTH_ENABLED'] = true;
									//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', json);
									lblGoogleAuthorizedStatus = L10n.Term('OAuth.LBL_TEST_SUCCESSFUL');
									this.setState({ lblGoogleAuthorizedStatus });
									this.props.history.replace(sID);
								}
							}
							catch(error)
							{
								console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
								lblGoogleAuthorizedStatus = error.message;
								this.setState({ lblGoogleAuthorizedStatus });
								this.props.history.replace(sID);
							}
						}
					}
					else if ( oauth_host == 'Office365' )
					{
						item['MAIL_SENDTYPE'] = 'Office365';
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
									lblGoogleAuthorizedStatus: '',
									lblOfficeAuthorizedStatus: L10n.Term('OAuth.LBL_AUTHORIZING'),
								});
								if ( this._isMounted )
								{
									//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem code', AUTHORIZATION_CODE);
									let redirect_url      : string = window.location.origin;
									redirect_url += window.location.pathname.replace(this.props.location.pathname, '');
									redirect_url += '/Office365OAuth';
									let obj: any =
									{
										code        ,
										redirect_url,
									};
									// 11/09/2019 Paul.  We cannot use ADAL because we are using the response_type=code style of authentication (confidential) that ADAL does not support. 
									let sBody: string = JSON.stringify(obj);
									let res  = await CreateSplendidRequest('Administration/' + MODULE_NAME + '/Rest.svc/Office365_Authorize?ID=' + sID, 'POST', 'application/octet-stream', sBody);
									let json = await GetSplendidResult(res);
									item['OFFICE365_OAUTH_ENABLED'] = true;
									//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', json);
									lblOfficeAuthorizedStatus = L10n.Term('OAuth.LBL_TEST_SUCCESSFUL');
									this.setState({ lblOfficeAuthorizedStatus });
									this.props.history.replace(sID);
								}
							}
							catch(error)
							{
								console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
								lblOfficeAuthorizedStatus = error.message;
								this.setState({ lblOfficeAuthorizedStatus });
								this.props.history.replace(sID);
							}
						}
					}
				}
				if ( this._isMounted )
				{
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState({ item, SUB_TITLE, __sql: d.__sql, LAST_DATE_MODIFIED });
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
		else if ( PARENT_FIELD == 'MAIL_SENDTYPE' )
		{
			this.MAIL_SENDTYPE_Changed(this.state.layout, DATA_VALUE);
			if ( DATA_VALUE == 'GoogleApps' )
			{
				let ref = this.refMap['MAIL_SMTPSERVER'];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, 'smtp.gmail.com', 'value', null);
				}
				ref = this.refMap['MAIL_SMTPPORT'];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, '587', 'value', null);
				}
				ref = this.refMap['MAIL_SMTPAUTH_REQ'];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, true, 'value', null);
				}
				ref = this.refMap['MAIL_SMTPSSL'];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, true, 'value', null);
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
				case 'Test':
				{
					await this._onSmtpTest();
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

	private MAIL_SENDTYPE_Changed = (layout: EDITVIEWS_FIELD[], mail_sendtype: string) =>
	{
		const { bOffice365Enabled, bGoogleAppsEnabled} = this.state;
		let bSmtp    : boolean = (mail_sendtype == 'smtp');
		let bExchange: boolean = (mail_sendtype == 'Exchange-Password');
		EditView_HideField(layout, 'MAIL_SMTPSERVER'  , !bSmtp);
		EditView_HideField(layout, 'MAIL_SMTPPORT'    , !bSmtp);
		EditView_HideField(layout, 'MAIL_SMTPAUTH_REQ', !bSmtp);
		EditView_HideField(layout, 'MAIL_SMTPSSL'     , !bSmtp);
		EditView_HideField(layout, 'MAIL_SMTPUSER'    , !(bSmtp || bExchange));
		EditView_HideField(layout, 'MAIL_SMTPPASS'    , !(bSmtp || bExchange));
		this._onButtonsLoaded();
		if ( !bOffice365Enabled )
		{
			this.setState({ lblOfficeAuthorizedStatus: L10n.Term(MODULE_NAME + '.LBL_OFFICE365_NOT_ENABLED') });
		}
		if ( !bGoogleAppsEnabled )
		{
			this.setState({ lblGoogleAuthorizedStatus: L10n.Term(MODULE_NAME + '.LBL_GOOGLEAPPS_NOT_ENABLED') });
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
			});
			if ( this._isMounted )
			{
				const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
				let obj: any = {};
				obj.from_addr         = currentItem['FROM_ADDR'         ];
				obj.from_name         = currentItem['FROM_NAME'         ];
				obj.mail_sendtype     = currentItem['MAIL_SENDTYPE'     ];
				obj.mail_smtpuser     = currentItem['MAIL_SMTPUSER'     ];
				obj.mail_smtppass     = currentItem['MAIL_SMTPPASS'     ];
				obj.mail_smtpserver   = currentItem['MAIL_SMTPSERVER'   ];
				obj.mail_smtpport     = currentItem['MAIL_SMTPPORT'     ];
				obj.mail_smtpauth_req = currentItem['MAIL_SMTPAUTH_REQ' ];
				obj.mail_smtpssl      = currentItem['MAIL_SMTPSSL'      ];
				let sBody: string = JSON.stringify(obj);
				let res  = await CreateSplendidRequest('Administration/' + MODULE_NAME + '/Rest.svc/SendTestMessage?ID=' + this.props.ID, 'POST', 'application/octet-stream', sBody);
				let json = await GetSplendidResult(res);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSmtpTest', json);
				if ( this._isMounted )
				{
					this.setState(
					{
						lblSmtpAuthorizedStatus : json.d,
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
			});
		}
	}

	private _onGoogleAppsAuthorize = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGoogleAppsAuthorize');
		// https://console.cloud.google.com/apis/credentials
		let client_id      : string = Crm_Config.ToString('GoogleApps.ClientID');
		let access_type    : string = 'offline';
		let approval_prompt: string = 'force';
		let response_type  : string = 'code';
		let scope          : string = 'profile';
		// 07/13/2020 Paul.  The redirect_url cannot include parameters.  Use state variable instead. 
		let state          : string = 'OutboundEmail:' + this.props.ID;
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
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
		try
		{
			let obj: any = {};
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Administration/' + MODULE_NAME + '/Rest.svc/GoogleApps_Delete?ID=' + this.props.ID, 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			currentItem['GOOGLEAPPS_OAUTH_ENABLED'] = false;
			this.setState({ editedItem: currentItem, lblGoogleAuthorizedStatus: '' });
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
			let obj: any = {};
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Administration/' + MODULE_NAME + '/Rest.svc/GoogleApps_Test?ID=' + this.props.ID, 'POST', 'application/octet-stream', sBody);
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
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Administration/' + MODULE_NAME + '/Rest.svc/GoogleApps_RefreshToken?ID=' + this.props.ID, 'POST', 'application/octet-stream', sBody);
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onOffice365Authorize');

		// 11/28/2020 Paul.  Outlook REST API has been deprecated.  Use Microsoft Graph instead. https://docs.microsoft.com/en-us/outlook/rest/compare-graph
		let client_id      : string = Crm_Config.ToString('Exchange.ClientID');
		let response_type  : string = 'code';
		// 12/29/2020 Paul.  Update scope to allow sync of contacts, calendars and mailbox. 
		let scope          : string = "openid offline_access Mail.ReadWrite Mail.Send Contacts.ReadWrite Calendars.ReadWrite MailboxSettings.ReadWrite User.Read";
		// 07/13/2020 Paul.  The redirect_url cannot include parameters.  Use state variable instead. 
		let state          : string = 'OutboundEmail:' + this.props.ID;
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
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
		try
		{
			let obj: any = {};
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Administration/' + MODULE_NAME + '/Rest.svc/Office365_Delete?ID=' + this.props.ID, 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			currentItem['OFFICE365_OAUTH_ENABLED'] = false;
			this.setState({ editedItem: currentItem, lblOfficeAuthorizedStatus: '' });
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
			let obj: any = {};
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Administration/' + MODULE_NAME + '/Rest.svc/Office365_Test?ID=' + this.props.ID, 'POST', 'application/octet-stream', sBody);
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
			let sBody: string = JSON.stringify(obj);
			let res  = await CreateSplendidRequest('Administration/' + MODULE_NAME + '/Rest.svc/Office365_RefreshToken?ID=' + this.props.ID, 'POST', 'application/octet-stream', sBody);
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

	private _onButtonsLoaded = () =>
	{
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
		// 08/12/2019 Paul.  Here is where we can disable buttons immediately after they were loaded. 
		if ( this.headerButtons.current != null )
		{
			this.headerButtons.current.ShowButton('Test', (Sql.IsEmptyString(currentItem['MAIL_SENDTYPE']) || currentItem['MAIL_SENDTYPE'] == 'smtp' || currentItem['MAIL_SENDTYPE'] == 'Exchange-Password'));
		}
		if ( this.headerButtons.current != null )
		{
			this.dynamicButtonsBottom.current.ShowButton('Test', (Sql.IsEmptyString(currentItem['MAIL_SENDTYPE']) || currentItem['MAIL_SENDTYPE'] == 'smtp' || currentItem['MAIL_SENDTYPE'] == 'Exchange-Password'));
		}
	}

	public render()
	{
		const { ID, DuplicateID, callback } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, error } = this.state;
		const { lblSmtpAuthorizedStatus, lblGoogleAuthorizedStatus, lblOfficeAuthorizedStatus } = this.state;
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
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<div>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				<div id={!!callback ? null : "content"}>
					{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, 'tabForm', this.Page_Command) }
					{ (currentItem['MAIL_SENDTYPE'] == 'smtp' || currentItem['MAIL_SENDTYPE'] == 'Exchange-Password')
					? <div>
						<div className='tabForm'>
							<span id='lblSmtpAuthorizedStatus' className='error'>{ lblSmtpAuthorizedStatus }</span>
						</div>
					</div>
					: null
					}
					{ currentItem['MAIL_SENDTYPE'] == 'Office365'
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
					{ currentItem['MAIL_SENDTYPE'] == 'GoogleApps'
					? <div>
						<h4 style={ {marginTop: '6px'} }>{ L10n.Term('Users.LBL_GOOGLEAPPS_OPTIONS_TITLE') }</h4>
						<div className='tabForm'>
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
				</div>
				{ !callback && headerButtons
				? <DynamicButtons
					ButtonStyle="EditHeader"
					VIEW_NAME={ EDIT_NAME }
					row={ item }
					Page_Command={ this.Page_Command }
					onLayoutLoaded={ this._onButtonsLoaded }
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

