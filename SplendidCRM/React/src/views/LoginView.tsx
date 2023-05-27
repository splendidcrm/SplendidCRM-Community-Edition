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
import { RouteComponentProps, withRouter }           from 'react-router-dom'              ;
import { FontAwesomeIcon }                           from '@fortawesome/react-fontawesome';
import { observer }                                  from 'mobx-react'                    ;
// 2. Store and Types. 
import SINGLE_SIGN_ON                                from '../types/SINGLE_SIGN_ON'       ;
// 3. Scripts. 
import Sql                                           from '../scripts/Sql'                ;
import L10n                                          from '../scripts/L10n'               ;
import Credentials                                   from '../scripts/Credentials'        ;
import AuthenticationContext                         from '../scripts/adal'               ;
import SplendidCache                                 from '../scripts/SplendidCache'      ;
import { EndsWith, Trim, screenWidth, screenHeight } from '../scripts/utility'            ;
import { Crm_Config }                                from '../scripts/Crm'                ;
import { Login, ForgotPassword, IsAuthenticated }    from '../scripts/Login'              ;
import { Application_GetReactLoginState }            from '../scripts/Application'        ;
import { AppName, AppVersion }                       from '../AppVersion'                 ;
// 4. Components and Views. 
import { RouterStore }                               from 'mobx-react-router'             ;
import { StartsWith }                                from '../scripts/utility'            ;

interface ILoginViewProps extends RouteComponentProps<any>
{
	routing?             : RouterStore;
	initState            : any;
}

interface ILoginViewState
{
	REMOTE_SERVER        : string;
	USER_NAME            : string;
	PASSWORD             : string;
	FORGOT_USER_NAME     : string;
	FORGOT_EMAIL         : string;
	forgotPassword       : boolean;
	forgotError          : string;
	loading              : boolean;
	loggingIn            : boolean;
	error                : any;
	bADFS_SINGLE_SIGN_ON : boolean;
	bAZURE_SINGLE_SIGN_ON: boolean;
	adalInstance         : any;
	oSingleSignOnContext : SINGLE_SIGN_ON
}

@observer
class LoginView extends React.Component<ILoginViewProps, ILoginViewState>
{
	private _isMounted = false;

	constructor(props: ILoginViewProps)
	{
		super(props);
		let REMOTE_SERVER: string = (Credentials.bMOBILE_CLIENT ? localStorage.getItem('REMOTE_SERVER') : '');
		let USER_NAME    : string = localStorage.getItem('USER_NAME');
		if ( Credentials.bMOBILE_CLIENT && REMOTE_SERVER != null )
		{
			Credentials.SetREMOTE_SERVER(REMOTE_SERVER);
		}
		this.state =
		{
			REMOTE_SERVER        ,
			USER_NAME            ,
			PASSWORD             : '',
			FORGOT_USER_NAME     : '',
			FORGOT_EMAIL         : '',
			forgotPassword       : false,
			forgotError          : null,
			loading              : true,
			loggingIn            : false,
			error                : null,
			bADFS_SINGLE_SIGN_ON : false,
			bAZURE_SINGLE_SIGN_ON: false,
			adalInstance         : null,
			oSingleSignOnContext : null,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { history } = this.props;
		this._isMounted = true;
		try
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', Credentials.RemoteServer);
			// 08/11/2019 Paul.  If redirected to login after session timeout, we need to reset. 
			// 12/07/2022 Paul.  Must reset in DynamicLoginView, otherwise we lose our login state. 
			//SplendidCache.Reset();
			let oSingleSignOnContext = null;
			// 08/03/2020 Paul.  If the RemoteServer is provided or if not mobile client. 
			// 12/07/2022 Paul.  This first call to Application_GetReactLoginState() is performed in DynamicLoginView. 
			//if ( !Credentials.bMOBILE_CLIENT || !Sql.IsEmptyString(Credentials.RemoteServer) )
			//	oSingleSignOnContext = await Application_GetReactLoginState();
			// 05/30/2019 Paul.  The component may be unmounted by the time the custom view is generated. 
			if ( this._isMounted )
			{
				this.setState({ error: '' });
			}
			// 06/23/2019 Paul.  IsAuthenticated will catch any errors and return simple true/false. 
			let bAuthenticated: boolean = await IsAuthenticated(this.constructor.name + '.componentDidMount');
			if ( bAuthenticated )
			{
				let sLastActiveModule = Sql.ToString(localStorage.getItem('ReactLastActiveModule'));
				if ( Sql.IsEmptyString(sLastActiveModule) )
				{
					sLastActiveModule = '/Home';
				}
				if ( !StartsWith(sLastActiveModule, '/') )
				{
					sLastActiveModule = '/' + sLastActiveModule;
				}
				history.push('/Reload' + sLastActiveModule);
			}
			else
			{
				// 06/24/2019 Paul.  SingleSigneOn data is now returnd in the ReactLoginState to reduce the requests. 
				// https://hjnilsson.com/2016/07/20/authenticated-azure-cors-request-with-active-directory-and-adal-js/
				//let oSingleSignOnContext = await SingleSignOnSettings();
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount oSingleSignOnContext', oSingleSignOnContext);
				if ( oSingleSignOnContext != null && !Sql.IsEmptyString(oSingleSignOnContext.instance) )
				{
					this.initSingleSignOn(oSingleSignOnContext);
				}
				else
				{
					// 08/11/2019 Paul.  Re-authenticate if credentials found. 
					let sAUTHENTICATION: string = Credentials.GetAUTHENTICATION();
					let sUSER_NAME     : string = Credentials.GetUSER_NAME()     ;
					let sPASSWORD      : string = Credentials.GetPASSWORD()      ;
					if ( sAUTHENTICATION == 'CRM' && !Sql.IsEmptyString(sUSER_NAME) && !Sql.IsEmptyString(sPASSWORD) )
					{
						this.setState({ USER_NAME: sUSER_NAME, PASSWORD: sPASSWORD, loading: false }, () =>
						{
							this.handleOnSubmit(null);
						});
					}
					// 04/20/2021 Paul.  Add support for forced https. 
					else if ( window.location.protocol == 'http:' && Crm_Config.ToBoolean('Site.Https') )
					{
						window.location.href = 'https://' + window.location.host + window.location.pathname + window.location.search;
					}
				}
				if ( this.state.loading )
				{
					this.setState({ loading: false });
				}
			}
		}
		catch(error)
		{
			this.setState({ loading: false, error: error.message });
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private initSingleSignOn = (oSingleSignOnContext) =>
	{
		try
		{
			//console.log((new Date()).toISOString() + ' ' + 'Active Directory Tenant: ' + oSingleSignOnContext.tenant);
			let adalInstance: any = new AuthenticationContext(
			{
				instance             : oSingleSignOnContext.instance ,
				tenant               : oSingleSignOnContext.tenant   ,
				clientId             : oSingleSignOnContext.clientId ,
				endpoints            : oSingleSignOnContext.endpoints,
				//redirectUri          : (window.location.origin + window.location.pathname),
				postLogoutRedirectUri: Credentials.RemoteServer,
				// 01/28/2022 Paul.  Need to prevent redirect after successful get token. 
				navigateToLoginRequestUrl: false,
			});
			// 01/28/2022 Paul.  We must now save the hash as handleWindowCallback will clear it due to navigateToLoginRequestUrl flag. 
			let hash: string = window.location.hash;
			// 11/09/2019 Paul.  Without this handle call, the getcachedToken fails. 
			adalInstance.handleWindowCallback();

			let bADFS_SINGLE_SIGN_ON : boolean = (oSingleSignOnContext.tenant == 'adfs');
			let bAZURE_SINGLE_SIGN_ON: boolean = !bADFS_SINGLE_SIGN_ON;
			this.setState(
			{
				bADFS_SINGLE_SIGN_ON ,
				bAZURE_SINGLE_SIGN_ON,
				adalInstance         ,
				oSingleSignOnContext ,
			});

			if ( adalInstance.isCallback(hash) )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount isCallback', hash);
				let token = adalInstance.getCachedToken(oSingleSignOnContext.clientId);
				if ( token )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount token', token);
					let user = adalInstance.getCachedUser();
					if ( user )
					{
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount user', user);
						// user.userName
						// user.profile.email
						// user.profile.family_name
						// user.profile.given_name
						// user.profile.name
						//alert('azure cached user ' + dumpObj(user));
						// 12/20/2018 Paul.  Try and extract from unique name first. 
						let sUSER_NAME = '';
						if ( user.profile.unique_name !== undefined )
						{
							sUSER_NAME = user.profile.unique_name;
						}
						else
						{
							sUSER_NAME = user.userName;
						}
						if ( sUSER_NAME.indexOf('@') > 0 )
						{
							sUSER_NAME = sUSER_NAME.split('@')[0];
						}
						else if ( sUSER_NAME.indexOf('\\') )
						{
							sUSER_NAME = sUSER_NAME.substring(sUSER_NAME.indexOf('\\') + 1);
						}
						let sPASSWORD  = adalInstance._getItem(adalInstance.CONSTANTS.STORAGE.IDTOKEN);
						this.setState({ USER_NAME: sUSER_NAME, PASSWORD: sPASSWORD, loading: false }, () =>
						{
							// 12/20/2018 Paul.  The token will be null when logging out. 
							this.handleOnSubmit(null);
						});
					}
				}
			}
			else
			{
				// 11/06/2019 Paul.  Must acquire the token. 
				this.AdalLogin();
			}
		}
		catch(error)
		{
			this.setState({ loading: false, error: error.message });
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.initSingleSignOn', error);
		}
	}

	private handleOnSubmit = async (e) =>
	{
		const { REMOTE_SERVER, USER_NAME, PASSWORD } = this.state;
		const { history, location } = this.props;
		if ( e != null )
		{
			e.preventDefault();
		}
		this.setState({ loggingIn: true });
		try
		{
			// 05/18/2019 Paul.  Login will call SplendidUI_Init(). 
			await Login(USER_NAME, PASSWORD);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handleOnSubmit Login complete');

			// 08/14/2020 Paul.  On android, we don't seem to be getting an exception with a login failure. 
			let status = true;
			if ( Credentials.bMOBILE_CLIENT )
			{
				localStorage.setItem('REMOTE_SERVER', REMOTE_SERVER);
				localStorage.setItem('USER_NAME'    , USER_NAME    );
				status = await IsAuthenticated(this.constructor.name + '.handleOnSubmit');
			}
			if ( status )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handleOnSubmit IsAuthenticated', status);
				if ( location.state )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handleOnSubmit location.state', location.state);
					// 08/30/2020 Paul.  from no longer works. 
					history.push('/Reload' + location.pathname + location.search);
				}
				else
				{
					let sLastActiveModule = Sql.ToString(localStorage.getItem('ReactLastActiveModule'));
					if ( Sql.IsEmptyString(sLastActiveModule) )
					{
						sLastActiveModule = '/Home';
					}
					if ( !StartsWith(sLastActiveModule, '/') )
					{
						sLastActiveModule = '/' + sLastActiveModule;
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handleOnSubmit sLastActiveModule', sLastActiveModule);
					history.push('/Reload' + sLastActiveModule);
				}
			}
			else
			{
				this.setState({ loggingIn: false, error: 'Failed to authenticated after login.  Seems like a cookie problem.' });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.handleOnSubmit', error);
			this.setState({ loggingIn: false, error: error.message, forgotError: null });
		}
	}

	private NormalizeRemoteServer(sREMOTE_SERVER)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.NormalizeRemoteServer', sREMOTE_SERVER);
		sREMOTE_SERVER = Trim(Sql.ToString(sREMOTE_SERVER));
		if ( EndsWith(sREMOTE_SERVER, '.asmx') || EndsWith(sREMOTE_SERVER, '.aspx') || EndsWith(sREMOTE_SERVER, '.svc') )
		{
			var nLastSlash = sREMOTE_SERVER.lastIndexOf('/');
			if ( nLastSlash > 0 )
				sREMOTE_SERVER = sREMOTE_SERVER.substring(0, nLastSlash + 1);
			else
			{
				// 08/17/2014 Paul.  Case-insignificant replacements. 
				sREMOTE_SERVER = sREMOTE_SERVER.replace(/sync.asmx/gi, '');
				sREMOTE_SERVER = sREMOTE_SERVER.replace(/Rest.svc/gi, '');
			}
		}
		if ( !Sql.IsEmptyString(sREMOTE_SERVER) )
		{
			if ( !EndsWith(sREMOTE_SERVER, '/') )
				sREMOTE_SERVER += '/';
			// 12/11/2014 Paul.  Prepend https:// if not provided. 
			if ( !StartsWith(sREMOTE_SERVER.toLocaleLowerCase(), 'http://') && !StartsWith(sREMOTE_SERVER.toLocaleLowerCase(), 'https://') )
				sREMOTE_SERVER = 'https://' + sREMOTE_SERVER;
		}
		return sREMOTE_SERVER;
	}
	
	private AdalLogin = () =>
	{
		const { adalInstance, oSingleSignOnContext } = this.state;
		try
		{
			let resourceUrl      = oSingleSignOnContext.mobileId;
			// 05/03/2017 Paul.  ADFS still requires a Uri. 
			if ( oSingleSignOnContext.tenant == 'adfs' )
			{
				resourceUrl = this.NormalizeRemoteServer(Credentials.RemoteServer);
			}
			let redirectUrl      = oSingleSignOnContext.mobileRedirectUrl;
			if ( Sql.IsEmptyString(redirectUrl) )
			{
				redirectUrl = 'http://SplendidMobile';
			}
			//console.log((new Date()).toISOString() + ' ' + 'ADAL Resource URL: ' + resourceUrl);
			
			//adalInstance.acquireTokenRedirect(resourceUrl);
			adalInstance.acquireToken(resourceUrl, (message, token, msg) =>
			{
				if ( !msg )
				{
					//console.log((new Date()).toISOString() + ' ' + 'Acquired token successfully:', token);
					/*
					// Azure response. 
					authResult.accessToken
					authResult.expiresOn
					authResult.idToken
					authResult.isMultipleResourceRefreshToken = true
					authResult.statusCode = 'Succeeded'
					authResult.tenantId
					authResult.userInfo.displayableId = 'Paul Rony'
					authResult.userInfo.userId        = guid
					authResult.userInfo.familyName    = 'Rony'
					authResult.userInfo.givenName     = 'Paul'
					authResult.userInfo.identityProvider = 'live.com'
					authResult.userInfo.uniqueId         = 'live.com#sales@splendidcrm.com'
					sUSER_NAME = authResult.userInfo.uniqueId.replace('live.com#', '');
					sPASSWORD  = authResult.idToken;
					LoginViewUI_PageCommand(sLayoutPanel, sActionsPanel, 'Login', null, cbLoginComplete);

					// ADFS 4.0 response. 
					authResult.accessToken
					authResult.expiresOn
					authResult.idToken
					authResult.isMultipleResourceRefreshToken = true
					authResult.statusCode = 'Succeeded'
					authResult.userInfo.userId        = 'xxxxxxx'  // not a guid
					authResult.userInfo.identityProvider = 'https://adfs.splendidcrm.com/adfs'
					authResult.userInfo.uniqueId         = 'domain\\username'
					sUSER_NAME = authResult.userInfo.uniqueId.split('\\')[1];
					sPASSWORD  = authResult.idToken;
					LoginViewUI_PageCommand(sLayoutPanel, sActionsPanel, 'Login', null, cbLoginComplete);
					*/
					/*
					let sUSER_NAME = null;
					if ( authResult.userInfo.identityProvider == 'live.com' )
						sUSER_NAME = authResult.userInfo.uniqueId.replace('live.com#', '');
					else
						sUSER_NAME = authResult.userInfo.uniqueId.split('\\')[1];
					// 05/03/2017 Paul.  The accessToken includes a signature to validate on the server. 
					let sPASSWORD  = authResult.accessToken;
					this.setState({ USER_NAME: sUSER_NAME, PASSWORD: sPASSWORD }, () =>
					{
						// 12/20/2018 Paul.  The token will be null when logging out. 
						this.handleOnSubmit(null);
					});
					*/
				}
				else if ( message != null 
				         && ( message.indexOf('AADSTS16002') >= 0 // old sid - https://github.com/salvoravida/react-adal/issues/46
				           || message.indexOf('AADSTS50076') >= 0 // MFA support - https://github.com/salvoravida/react-adal/pull/45
				           || message.indexOf('AADSTS50079') >= 0 // MFA support
				            )
				        )
				{
					adalInstance.acquireTokenRedirect(resourceUrl);
				}
				else
				{
					if ( msg == 'login required' || msg == 'Token Renewal Failed' )
					{
						adalInstance.login();
					}
					else
					{
						this.setState({ error: message });
					}
				}
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AdalLogin', error);
			this.setState({ error: error.message });
		}
	}

	private WindowsLogin = async () =>
	{
		const { history } = this.props;
		try
		{
			await Login('', '');
			let bAuthenticated: boolean = await IsAuthenticated(this.constructor.name + '.WindowsLogin');
			if ( bAuthenticated )
			{
				let sLastActiveModule = Sql.ToString(localStorage.getItem('ReactLastActiveModule'));
				if ( Sql.IsEmptyString(sLastActiveModule) )
				{
					sLastActiveModule = '/Home';
				}
				if ( !StartsWith(sLastActiveModule, '/') )
				{
					sLastActiveModule = '/' + sLastActiveModule;
				}
				history.push('/Reload' + sLastActiveModule);
			}
		}
		catch(error)
		{
			this.setState({ error: error.message });
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
		}
	}

	private _onRemoteServerChange = (e): void =>
	{
		let value = e.target.value;
		this.setState({ REMOTE_SERVER: value });
	}

	private _onRemoteServerBlur = async (e) =>
	{
		let REMOTE_SERVER: string = this.NormalizeRemoteServer(this.state.REMOTE_SERVER);
		try
		{
			this.setState({ REMOTE_SERVER, error: '' }, async () =>
			{
				Credentials.SetREMOTE_SERVER(REMOTE_SERVER);
				if ( !Sql.IsEmptyString(REMOTE_SERVER) )
				{
					// 11/19/2020 Paul.  Must catch possible async exception. 
					try
					{
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRemoteServerBlur REMOTE_SERVER', REMOTE_SERVER);
						let oSingleSignOnContext = await Application_GetReactLoginState();
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRemoteServerBlur oSingleSignOnContext', oSingleSignOnContext);
						if ( oSingleSignOnContext !== undefined && oSingleSignOnContext != null && !Sql.IsEmptyString(oSingleSignOnContext.instance) )
						{
							this.initSingleSignOn(oSingleSignOnContext);
							// 11/15/2020 Paul.  Save server on success.  Mostly for developement purposes. 
							localStorage.setItem('REMOTE_SERVER', REMOTE_SERVER);
						}
					}
					catch(error)
					{
						this.setState({ error: error.message });
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
					}
				}
			});
		}
		catch(error)
		{
			this.setState({ error: error.message });
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
		}
	}

	private _onUserNameChange = (e): void =>
	{
		let value = e.target.value;
		this.setState({ USER_NAME: value });
	}

	private _onPasswordChange = (e): void =>
	{
		let value = e.target.value;
		this.setState({ PASSWORD: value });
	}

	private _onKeyDown = async (event) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' )
		{
			await this.handleOnSubmit(null);
		}
	}

	private _onForgotUserNameChange = (e): void =>
	{
		let value = e.target.value;
		this.setState({ FORGOT_USER_NAME: value });
	}

	private _onForgotEmailChange = (e): void =>
	{
		let value = e.target.value;
		this.setState({ FORGOT_EMAIL: value });
	}

	private _toggleForgotPassword = (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._toggleForgotPassword', error, info);
		e.preventDefault();
		this.setState({ forgotPassword: !this.state.forgotPassword });
		return false;
	}

	private _handleForgetPassword = async (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._handleForgetPassword', error, info);
		const { FORGOT_USER_NAME, FORGOT_EMAIL } = this.state;
		if ( e != null )
		{
			e.preventDefault();
		}
		this.setState({ loggingIn: true });
		try
		{
			let sStatus: string = await ForgotPassword(FORGOT_USER_NAME, FORGOT_EMAIL);
			this.setState({ loggingIn: false, error: null, forgotError: sStatus });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._handleForgetPassword', error);
			this.setState({ loggingIn: false, error: null, forgotError: error.message });
		}
	}

	private _onForgotKeyDown = async (event) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' )
		{
			await this._handleForgetPassword(null);
		}
	}

	public render()
	{
		const { REMOTE_SERVER, USER_NAME, PASSWORD, FORGOT_USER_NAME, FORGOT_EMAIL, forgotPassword, forgotError, error, loading, loggingIn, bADFS_SINGLE_SIGN_ON, bAZURE_SINGLE_SIGN_ON } = this.state;
		const shadowStyles: React.CSSProperties =
		{
			position      : 'absolute',
			top           : 0,
			bottom        : 0,
			right         : 0,
			left          : 0,
			zIndex        : 1,
			background    : 'grey',
			opacity       : 0.6,
			display       : 'flex',
			justifyContent: 'center',
			alignItems    : 'center',
		};
		// 05/16/2020 Paul.  Don't show User Name and Password fields if Windows Authentication. 
		let bMOBILE_CLIENT        : boolean = Credentials.bMOBILE_CLIENT;
		let bWindowsAuthentication: boolean = Credentials.sAUTHENTICATION == 'Windows';
		let bActiveDirectory      : boolean = bADFS_SINGLE_SIGN_ON || bAZURE_SINGLE_SIGN_ON;
		let theme                 : string = SplendidCache.UserTheme;
		let themeURL              : string = Credentials.RemoteServer + 'App_Themes/' + theme + '/';
		let sAppName              : string = Crm_Config.ToString('application_name');
		if ( Sql.IsEmptyString(sAppName) )
		{
			sAppName = AppName + ' ' + Crm_Config.ToString('service_level');
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', themeURL);
		let cssBorder: any =
		{
			border        : 'none',
			borderCollapse: 'collapse',
			width         : '500px',
			marginTop     : '80px',
			marginBottom  : '80px'
		};
		let width  = screenWidth();
		let height = screenHeight();
		if ( bMOBILE_CLIENT )
		{
			cssBorder.width     = '80%' ;
			cssBorder.marginTop = '20px';
		}
		if ( height < 600 )
		{
			cssBorder.marginTop = '20px';
		}
		if ( width < 600 )
		{
			cssBorder.width = '80%';
		}
		else if ( width < 400 )
		{
			cssBorder.width = '95%';
		}
		// 04/24/2022 Paul.  Subtract 60 for header with logo and 60 for copyright. 
		return (
			<React.Fragment>
				{ !loading
				? <div className="loginForm" style={ {height: (height - 60 - 60) + 'px'} }>
				<div  id="divLoginView" style={ {display: 'flex', justifyContent: 'center'} }>
					<table className="LoginActionsShadingTable" cellSpacing="0" cellPadding="0" style={ cssBorder }>
							<tr>
								<td className="LoginActionsShadingHorizontal" colSpan={ 3 }></td>
							</tr>
							<tr>
								<td className="LoginActionsShadingVertical"></td>
								<td>
									<table className="LoginActionsInnerTable" cellSpacing="0" cellPadding="0" style={ {width: '100%', border: 'none', borderCollapse: 'collapse'} }>
									<tr>
										<td style={ {paddingTop: '20px', paddingBottom: '20px', paddingLeft: '40px', paddingRight: '40px'} }>
											<table className='loginAppName' cellSpacing="2" cellPadding="0">
											<tr>
												<td>
													<span style={ {fontFamily: 'Arial', fontSize: '14pt', fontWeight: 'bold'} }>
														{ sAppName + (bMOBILE_CLIENT ? ' ' + L10n.Term('.LNK_MOBILE_CLIENT') : '' )}
													</span>
													&nbsp;
													<span style={ {fontFamily: 'Arial', fontSize: '10pt'} }>
														{ AppVersion }
													</span>
												</td>
											</tr>
										</table>
										{ !bActiveDirectory && !bWindowsAuthentication
										? <table id="ctlLoginView_tblUser" cellSpacing="2" cellPadding="0" style={ {borderWidth: '0px', width: '100%'} }>
											<tr>
												<td colSpan={ 2 } style={ {fontSize: '12px', paddingTop: '5px'} }>
													<span id="ctlLoginView_lblInstructions" className="loginInstructions">{ L10n.Term('.NTC_LOGIN_MESSAGE') }</span>
												</td>
											</tr>
											<tr id="ctlLoginView_trError">
												<td colSpan={ 2 }>
													<span id="ctlLoginView_lblError" className="error">{ error }</span>
												</td>
											</tr>
											{ bMOBILE_CLIENT
											? <tr id="ctlLoginView_trServer">
												<td className="dataLabel" style={ {} }>
													{ L10n.Term('Offline.LBL_REMOTE_SERVER') }
												</td>
												<td className="loginField" style={ {width: '70%'} }>
													<input
														id="ctlLoginView_txtREMOTE_SERVER"
														type="text"
														value={ REMOTE_SERVER }
														onChange={ this._onRemoteServerChange }
														onBlur={ this._onRemoteServerBlur }
														onKeyDown={ this._onKeyDown }
														autoFocus={ Sql.IsEmptyString(REMOTE_SERVER) }
														placeholder={ (theme == 'Arctic' || theme == 'Pacific') ? Sql.ToString(L10n.Term('Offline.LBL_REMOTE_SERVER')).replace(':', '') : null }
													/> &nbsp;
												</td>
											</tr>
											: null
											}
											<tr id="ctlLoginView_trUserName">
												<td className="dataLabel" style={ {} }>
													{ L10n.Term('Users.LBL_USER_NAME') }
												</td>
												<td className="loginField" style={ {width: '70%'} }>
													<input
														id="ctlLoginView_txtUSER_NAME"
														type="text"
														value={ USER_NAME }
														onChange={ this._onUserNameChange }
														onKeyDown={ this._onKeyDown }
														autoFocus={ !bMOBILE_CLIENT || !Sql.IsEmptyString(REMOTE_SERVER) }
														placeholder={ (theme == 'Arctic' || theme == 'Pacific') ? Sql.ToString(L10n.Term('Users.LBL_USER_NAME')).replace(':', '') : null }
													/> &nbsp;
												</td>
											</tr>
											<tr id="ctlLoginView_trPassword">
												<td className="dataLabel" style={ {} }>
													{ L10n.Term('Users.LBL_PASSWORD') }
												</td>
												<td className="loginField" style={ {width: '70%'} }>
													<input
														id="ctlLoginView_txtPASSWORD"
														type="password"
														value={ PASSWORD }
														onChange={ this._onPasswordChange }
														onKeyDown={ this._onKeyDown }
														autoFocus={ (!bMOBILE_CLIENT || !Sql.IsEmptyString(REMOTE_SERVER)) && !Sql.IsEmptyString(USER_NAME) }
														placeholder={ (theme == 'Arctic' || theme == 'Pacific') ? Sql.ToString(L10n.Term('Users.LBL_PASSWORD')).replace(':', '') : null }
													/> &nbsp;
												</td>
											</tr>
										</table>
										: null
										}
										{ bActiveDirectory
										? <table cellSpacing="2" cellPadding="0" style={ {borderWidth: '0px', width: '100%', textAlign: 'center'} }>
											<tr>
												<td style={ {whiteSpace: 'nowrap'} }>
													<table cellSpacing="2" cellPadding="4" style={ {border: 'none', width: '100%'} }>
														<tr>
															<td align="left">
																<input
																	id="ctlLoginView_btnAdalLogin"
																	type="submit"
																	value={ "  " + L10n.Term("Users.LBL_LOGIN_BUTTON_LABEL") + "  " }
																	onClick={ this.AdalLogin }
																	title={ L10n.Term("Users.LBL_LOGIN_BUTTON_LABEL") }
																	className="button"
																	disabled={ loading }
																/>
															</td>
															<td>
																<span id="ctlLoginView_lblError" className="error" style={ {fontSize: '12pt'} }>{ error }</span>
															</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
										: null
										}
										{ bWindowsAuthentication
										? <table cellSpacing="2" cellPadding="0" style={ {borderWidth: '0px', width: '100%', textAlign: 'center'} }>
											<tr>
												<td style={ {whiteSpace: 'nowrap'} }>
													<table cellSpacing="2" cellPadding="4" style={ {border: 'none', width: '100%'} }>
														<tr>
															<td align="left">
																<input
																	id="ctlLoginView_btnWindowsLogin"
																	type="submit"
																	value={ "  " + L10n.Term("Users.LBL_LOGIN_BUTTON_LABEL") + "  " }
																	onClick={ this.WindowsLogin }
																	title={ L10n.Term("Users.LBL_LOGIN_BUTTON_LABEL") }
																	className="button"
																	disabled={ loading }
																/>
															</td>
															<td>
																<span id="ctlLoginView_lblError" className="error" style={ {fontSize: '12pt'} }>{ error }</span>
															</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
										: null
										}
										{ !bActiveDirectory && !bWindowsAuthentication
										? <table cellSpacing="2" cellPadding="0" style={ {borderWidth: '0px', width: '100%', textAlign: 'center'} }>
											<tr>
												{ theme != 'Pacific' && theme != 'Arctic'
												? <td style={ {} }>&nbsp;</td>
												: null
												}
												<td style={ {width: '70%', whiteSpace: 'nowrap'} }>
													<table cellSpacing="2" cellPadding="0" style={ {border: 'none', width: '100%'} }>
														<tr>
															<td align="left">
																<input
																	id="ctlLoginView_btnLogin"
																	type="submit"
																	value={ "  " + L10n.Term("Users.LBL_LOGIN_BUTTON_LABEL") + "  " }
																	onClick={ this.handleOnSubmit }
																	title={ L10n.Term("Users.LBL_LOGIN_BUTTON_LABEL") }
																	className="button"
																	disabled={ loading }
																/>
															</td>
															<td></td>
														</tr>
													</table>
												</td>
											</tr>
											<tr id="ctlLoginView_trShowForgotPassword">
												<td align="left" colSpan={ 2 } style={ {paddingTop: '10px'} }>
													<a className="utilsLink" href="#" onClick={ this._toggleForgotPassword }>
														<img src='data:image/gif;base64,R0lGODlhCAAIAIABAF16ov///yH5BAEAAAEALAAAAAAIAAgAAAIPRI6gGLttopIS2gtfMqcAADs=' style={ {borderWidth: '0px', height: '8px', width: '8px', verticalAlign: 'middle'} } />&nbsp;
														<span>{ L10n.Term('Users.LBL_FORGOT_PASSWORD') }</span>
													</a>
												</td>
											</tr>
										</table>
										: null
										}
										{ forgotPassword
										? <div id="ctlLoginView_pnlForgotPassword">
											<table cellSpacing="2" cellPadding="0" style={ {border: 'none', width: '100%'} }>
												<tr id="ctlLoginView_trForgotError">
													<td colSpan={ 2 }>
														<span id="ctlLoginView_lbForgotlError" className="error">{ forgotError }</span>
													</td>
												</tr>
												<tr>
													<td className="dataLabel" style={ {} }>
														{ L10n.Term('Users.LBL_USER_NAME') }
													</td>
													<td className="loginField" style={ {width: '70%'} }>
														<input
															id="ctlLoginView_txtFORGOT_USER_NAME"
															type="text"
															value={ FORGOT_USER_NAME }
															onChange={ this._onForgotUserNameChange }
															onKeyDown={ this._onForgotKeyDown }
															placeholder={ (theme == 'Arctic' || theme == 'Pacific') ? Sql.ToString(L10n.Term('Users.LBL_USER_NAME')).replace(':', '') : null }
														/>
													</td>
												</tr>
												<tr>
													<td className="dataLabel" style={ {} }>
														{ L10n.Term('Users.LBL_EMAIL') }
													</td>
													<td className="loginField" style={ {width: '70%'} }>
														<input
															id="ctlLoginView_txtFORGOT_EMAIL"
															type="text"
															value={ FORGOT_EMAIL }
															onChange={ this._onForgotEmailChange }
															onKeyDown={ this._onForgotKeyDown }
															placeholder={ (theme == 'Arctic' || theme == 'Pacific') ? Sql.ToString(L10n.Term('Users.LBL_EMAIL')).replace(':', '') : null }
														/>
													</td>
												</tr>
											</table>
												<table cellSpacing="2" cellPadding="0" style={ {border: 'none', width: '100%'} }>
												<tr>
													{ theme != 'Pacific' && theme != 'Arctic'
													? <td style={ {} }>&nbsp;</td>
													: null
													}
													<td style={ {width: '70%'} }>
														<input
															id="ctlLoginView_btnForgotPassword"
															type="submit"
															onClick={ this._handleForgetPassword }
															value={ "  " + L10n.Term(".LBL_SUBMIT_BUTTON_LABEL") + "  " }
															title={ L10n.Term(".LBL_SUBMIT_BUTTON_LABEL") }
															className="button"
														/>
													</td>
												</tr>
											</table>
										</div>
										: null
										}
										</td>
									</tr>
								</table>
								</td>
								<td className="LoginActionsShadingVertical"></td>
							</tr>
							<tr>
								<td className="LoginActionsShadingHorizontal" colSpan={ 3 }></td>
							</tr>
						</table>
					</div>
				</div>
				: null
				}
				{ loading || loggingIn
				? <div id={ this.constructor.name + '_spinner' } style={ shadowStyles }>
					<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
				  </div>
				: null
				}
			</React.Fragment>
		);
	}

}

export default withRouter(LoginView);
