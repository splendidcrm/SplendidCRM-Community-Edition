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
// 2. Store and Types. 
import SINGLE_SIGN_ON                               from '../types/SINGLE_SIGN_ON';
// 3. Scripts. 
import Sql                                          from './Sql'                  ;
import Credentials                                  from './Credentials'          ;
import SplendidCache                                from './SplendidCache'        ;
import AuthenticationContext                        from './adal'                 ;
import { bMOBILE_CLIENT }                           from './SplendidInitUI'       ;
import { SplendidUI_Init }                          from './SplendidInitUI'       ;
import { CreateSplendidRequest, GetSplendidResult } from './SplendidRequest'      ;
import SignalRStore                                 from '../SignalR/SignalRStore';
import { Application_ClearStore, Application_UpdateStoreLastDate } from './Application'          ;

// 07/01/2017 Paul.  Cache IsAuthenticated for 1 second. 
let lastIsAuthenticated = 0;

export function UpdateLastAuthenticated()
{
	lastIsAuthenticated = (new Date()).getTime();
}

export async function IsAuthenticated(source): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		// 04/28/2019 Paul.  Ignore for now so we can test the request failure below. 
		//throw new Error('Invalid connection information.');
		return false;
	}
	// 07/01/2017 Paul.  Cache IsAuthenticated for 1 second. 
	if ( lastIsAuthenticated > 0 )
	{
		let diff = new Date();
		diff.setTime(diff.getTime() - lastIsAuthenticated);
		var timeElapsed = diff.getTime();
		//console.log((new Date()).toISOString() + ' ' + 'IsAuthenticated ' + source, timeElapsed);
		if ( timeElapsed < 1000 )
		{
			return true;
		}
	}

	//console.log((new Date()).toISOString() + ' ' + 'IsAuthenticated ' + source, lastIsAuthenticated);
	try
	{
		let res = await CreateSplendidRequest('Rest.svc/IsAuthenticated');
		let json = await GetSplendidResult(res);
		if ( Sql.ToBoolean(json.d) )
		{
			//console.log((new Date()).toISOString() + ' ' + 'IsAuthenticated successful ' + source, lastIsAuthenticated);
			lastIsAuthenticated = (new Date()).getTime();
			if ( Credentials.sUSER_ID == '' )
			{
				// 05/07/2013 Paul.  Replace GetUserID and GetUserLanguage with GetUserProfile. 
				try
				{
					// 05/27/2019 Paul.  Moved GetUserProfile to SplendidUI_Init. 
					//let profile = await GetUserProfile();
					// 11/28/2011 Paul.  Reset after getting the language. 
					await SplendidUI_Init('IsAuthenticated ' + source);
					//SplendidCache.VerifyReactState();
					return true;
				}
				catch(error)
				{
					lastIsAuthenticated = 0;
					//console.log((new Date()).toISOString() + ' ' + 'IsAuthenticated SplendidUI_Init ' + source, error);
					return false;
				}
			}
			else
			{
				// 07/14/2021 Paul.  Use indexedDB to cache session state. 
				// 10/30/2021 Paul.  Must wait for update to finish. 
				await Application_UpdateStoreLastDate();
				return true;
			}
		}
		else
		{
			//console.warn((new Date()).toISOString() + ' ' + 'IsAuthenticated failed ' + source, lastIsAuthenticated);
		}
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' ' + 'IsAuthenticated ' + source, error);
	}
	// 07/14/2021 Paul.  Use indexedDB to cache session state. 
	// 10/30/2021 Paul.  Must wait for clear to finish before reloading. 
	await Application_ClearStore();
	return false;
}

export async function GetUserID(): Promise<any>
{
	try
	{
		let res = await CreateSplendidRequest('Rest.svc/GetUserID');
		let json = await GetSplendidResult(res);
		return json.d;
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' ' + 'GetUserID', error);
	}
	return null;
}

// 07/15/2021 Paul.  React Client needs to access the ASP.NET_SessionId. 
export async function GetUserSession(): Promise<any>
{
	try
	{
		let res = await CreateSplendidRequest('Rest.svc/GetUserSession');
		let json = await GetSplendidResult(res);
		return json.d;
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' ' + 'GetUserSession', error);
	}
	return null;
}

export async function Logout(): Promise<any>
{
	// 07/01/2017 Paul.  Reset IsAuthenticated immediately upon login/logout. 
	lastIsAuthenticated = 0;

	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		try
		{
			// 09/19/2020 Paul.  Provide events to start/stop SignalR. 
			SignalRStore.Shutdown();
			let res = await CreateSplendidRequest('Rest.svc/Logout');
			let json = await GetSplendidResult(res);
			//console.log((new Date()).toISOString() + ' ' + 'Logout complete', json);
		}
		catch(error)
		{
			// 06/23/2019 Paul.  Ignore any error and just continue. 
			console.error((new Date()).toISOString() + ' ' + 'Logout', error);
		}
		// 07/14/2021 Paul.  Use indexedDB to cache session state. 
		// 10/30/2021 Paul.  Must wait for clear to finish before reloading. 
		await Application_ClearStore();
		// 08/09/2018 Paul.  Setting to text value of null is wrong. 
		Credentials.SetUSER_ID('');
		Credentials.ClearStorage();
		SplendidCache.Reset();
		try
		{
			// 12/25/2018 Paul.  Logout should perform Azure or ADFS logout. 
			let oSingleSignOnContext = await SingleSignOnSettings();
			if ( oSingleSignOnContext != null && !Sql.IsEmptyString(oSingleSignOnContext.instance) )
			{
				let adalInstance = new AuthenticationContext(
				{
					instance             : oSingleSignOnContext.instance ,
					tenant               : oSingleSignOnContext.tenant   ,
					clientId             : oSingleSignOnContext.clientId ,
					endpoints            : oSingleSignOnContext.endpoints,
					redirectUri          : (window.location.origin + window.location.pathname),
					postLogoutRedirectUri: Credentials.RemoteServer,
				});
				adalInstance.logOut();
				return false;
			}
		}
		catch(error)
		{
			// 06/23/2019 Paul.  Ignore any error and just continue. 
			console.error((new Date()).toISOString() + ' ' + 'Logout SingleSignOnSettings', error);
		}
		// 05/29/2019 Paul.  Clear the local storage. 
		//window.removeEventListener('beforeunload', beforeUnloadListener);
		return true;
	}
}

// 05/13/2018 Paul.  At some point we will change back to using the Credential values instead of the passed-in values. 
export async function Login(username: string, password: string): Promise<any>
{
	var sBody = JSON.stringify({
		'UserName': username,
		'Password': password,
		'MobileClient': Credentials.bMOBILE_CLIENT,
		'Version': '6.0'
	});
	let res = await CreateSplendidRequest('Rest.svc/Login', 'POST', 'application/json; charset=UTF-8', sBody);
	let json = await GetSplendidResult(res);
	if ( json.d.length == 36 )
	{
		lastIsAuthenticated = 0;
		// 05/13/2018 Paul.  We will likely want to move the location where we save the credentials. 
		// 02/26/2019 Paul.  We need to save the credentials before setting the profile as it resets everyting. 
		Credentials.SaveCredentials('CRM', username, password);
		//Credentials.SetUSER_ID(json.d);
		// 05/07/2013 Paul.  Replace GetUserLanguage with GetUserProfile. 
		// 05/27/2019 Paul.  Moved GetUserProfile to SplendidUI_Init. 
		//let profile = await GetUserProfile();
		//lastIsAuthenticated = (new Date()).getTime();
		// 09/09/2014 Paul.  Reset after getting the language. 
		// 05/24/2019 Paul.  Move init to caller. 
		//await SplendidUI_Init('LoginView.Login');
		//window.addEventListener("beforeunload", beforeUnloadListener);
		return Credentials.sUSER_ID;
	}
	else
	{
		throw new Error('Login should return Guid.');
	}
}

// 02/18/2020 Paul.  Allow React Client to forget password. 
export async function ForgotPassword(username: string, email: string): Promise<any>
{
	var sBody = JSON.stringify({
		'UserName': username,
		'Email': email,
	});
	let res = await CreateSplendidRequest('Rest.svc/ForgotPassword', 'POST', 'application/json; charset=UTF-8', sBody);
	let json = await GetSplendidResult(res);
	return json.d;
}

export async function AuthenticatedMethod(props, source): Promise<number>
{
	if ( !Credentials.ValidateCredentials )
	{
		//throw new Error('Invalid connection information.');
		return 0;
	}
	//console.log((new Date()).toISOString() + ' ' + 'AuthenticatedMethod', source, props.location.pathname + props.location.search);
	// 06/23/2019 Paul.  IsAuthenticated will catch any errors and return simple true/false. 
	let bAuthenticated: boolean = await IsAuthenticated('AuthenticatedMethod ' + source);
	if ( bAuthenticated )
	{
		if ( !SplendidCache.IsInitialized )
		{
			//await SplendidUI_Init('AuthenticatedMethod ' + source);
			// 10/12/2019 Paul.  Include search query string. 
			props.history.push('/Reload' + props.location.pathname + props.location.search);
		}
		return 1;
	}
	else
	{
		let sAUTHENTICATION: string = Credentials.GetAUTHENTICATION();
		let sUSER_NAME     : string = Credentials.GetUSER_NAME()     ;
		let sPASSWORD      : string = Credentials.GetPASSWORD()      ;
		// 10/14/2011 Paul.  Make sure that we do not attempt to login if we do not have a password as it will eventually lock-out the user. 
		if ( sAUTHENTICATION == 'CRM' && !Sql.IsEmptyString(sUSER_NAME) && !Sql.IsEmptyString(sPASSWORD) )
		{
			try
			{
				let id = await Login(sUSER_NAME, sPASSWORD);
				// 08/30/2011 Paul.  Now may be a good time to run SplendidInit. 
				// 10/04/2011 Paul.  Return the user information for the Safari Extension. 
				// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
				// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
				// 02/28/2018 Paul.  When the session times-out and we re-authenticate, we need to load config, modules and global cache. 
				// 05/24/2019 Paul.  We are still having issues with rendering while loading, so use a separate view. 
				// await SplendidUI_Init('AuthenticatedMethod ' + source);
				// 10/12/2019 Paul.  Include search query string. 
				props.history.push('/Reload' + props.location.pathname + props.location.search);
			}
			catch(error)
			{
				// 06/23/2019 Paul.  Ignore any exception. 
				console.error((new Date()).toISOString() + ' ' + 'AuthenticatedMethod Login', error);
			}
		}
		return 0;
	}
}

export async function Version(): Promise<any>
{
	// 04/29/2017 Paul.  Automatically offline if the server is not defined. 
	if ( bMOBILE_CLIENT && Sql.IsEmptyString(Credentials.RemoteServer) )
	{
		throw new Error('Remote Server is not defined.');
	}
	else
	{
		let res = await CreateSplendidRequest('Rest.svc/Version');
		let json = await GetSplendidResult(res);
		return json.d;
	}
}

export async function Edition(): Promise<any>
{
	if ( bMOBILE_CLIENT && Sql.IsEmptyString(Credentials.RemoteServer) )
	{
		throw new Error('Remote Server is not defined.');
	}
	else
	{
		let res = await CreateSplendidRequest('Rest.svc/Edition');
		let json = await GetSplendidResult(res);
		return json.d;
	}
}


// 04/30/2017 Paul.  Add support for single-sign-on. 
export async function SingleSignOnSettings(): Promise<SINGLE_SIGN_ON>
{
	//console.log((new Date()).toISOString() + ' ' + 'SingleSignOnSettings', Credentials.RemoteServer);
	// 04/29/2017 Paul.  Automatically offline if the server is not defined. 
	if ( bMOBILE_CLIENT && Sql.IsEmptyString(Credentials.RemoteServer) )
	{
		throw new Error('Remote Server is not defined.');
	}
	else
	{
		// 04/29/2017 Paul.  Use 2 second timeout for SingleSignOnSettings. 
		// 07/03/2017 Paul.  We must specify timeout function otherwise we get an uncaught canceled event. Increase to 8 seconds. 
		let res = await CreateSplendidRequest('Rest.svc/SingleSignOnSettings', 'GET');
		let json = await GetSplendidResult(res);
		return json.d;
	}
}

export function LoginRedirect(history, sFrom)
{
	//console.log((new Date()).toISOString() + ' ' + 'LoginRedirect', sFrom);
	history.push('/login');
}

export async function GetUserProfile(): Promise<any>
{
	let res = await CreateSplendidRequest('Rest.svc/GetUserProfile', 'POST', 'application/json; charset=UTF-8', null);
	let json = await GetSplendidResult(res);
	return json.d;
}

// 10/09/2020 Paul.  The difference between GetUserProfile and GetMyUserProfile is that GetMyUserProfile gets all the data need in My Profile screen, but former just gets runtime data. 
export async function GetMyUserProfile(): Promise<any>
{
	let res = await CreateSplendidRequest('Rest.svc/GetMyUserProfile', 'GET');
	let json = await GetSplendidResult(res);
	json.d.__sql = json.__sql;
	return json.d;
}

