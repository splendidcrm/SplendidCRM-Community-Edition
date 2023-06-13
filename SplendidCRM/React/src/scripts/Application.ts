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
import { openDB, deleteDB, wrap, unwrap }           from 'idb';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'               ;
import Credentials                                  from '../scripts/Credentials'       ;
import SplendidCache                                from '../scripts/SplendidCache'     ;
import { CreateSplendidRequest, GetSplendidResult } from './SplendidRequest'            ;
import { AdminRequestAll, SystemCacheRequestAll }   from '../scripts/SystemCacheRequest';
import { UpdateApplicationTheme, StartsWith }       from '../scripts/utility'           ;
import { GetUserSession }                           from '../scripts/Login'             ;
import SignalRStore                                 from '../SignalR/SignalRStore'      ;

// 07/11/2019 Paul.  Keep original React State object for debugging. 
let jsonReactState: any = null;
export { jsonReactState }
const storeName: string = 'SplendidCRMReactClient';
// 07/14/2021 Paul.  Don't cache on the mobile apps. 
let enableReactStateCache: boolean = !window.cordova;

export async function Application_UpdateStoreLastDate()
{
	try
	{
		if ( enableReactStateCache )
		{
			// https://github.com/jakearchibald/idb
			let db = await openDB(Credentials.RemoteServer, 1,
			{
				upgrade(db)
				{
					db.createObjectStore(storeName);
				}
			});
			let now: Date = new Date();
			await db.put(storeName, now.getTime(), 'GetReactState.LastDate');
		}
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' ' + 'Application_UpdateStoreLastDate', error);
	}
}

// 07/14/2021 Paul.  Use indexedDB to cache session state. 
export async function Application_ClearStore()
{
	try
	{
		if ( enableReactStateCache )
		{
			// https://github.com/jakearchibald/idb
			let db = await openDB(Credentials.RemoteServer, 1,
			{
				upgrade(db)
				{
					db.createObjectStore(storeName);
				}
			});
			await db.delete(storeName, 'GetReactState'           );
			await db.delete(storeName, 'GetReactState.LastDate'  );
			await db.delete(storeName, 'GetReactState.AdminState');
			await db.delete(storeName, 'GetReactState.USER_SESSION'       );
			await db.delete(storeName, 'GetReactState.SessionStateTimeout');
		}
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' ' + 'Application_ClearStore', error);
	}
}

export function Application_ResetReactState()
{
	jsonReactState = null;
}

export async function Application_GetReactLoginState(): Promise<any>
{
	//let ar dtStart = new Date();
	let res = await SystemCacheRequestAll('GetReactLoginState');
	let json = await GetSplendidResult(res);
	//console.log((new Date()).toISOString() + ' ' + 'Application_GetReactLoginState', json);
	// 06/03/2023 Paul.  A Docker app can initialize the database, so watch for it when attempting to login. 
	if ( typeof(json) === 'string' && json.indexOf('The SplendidCRM database is being built.') > 0 )
	{
		console.log((new Date()).toISOString() + ' ' + 'Application_GetReactLoginState', 'The SplendidCRM database is being built.');
		window.location.href = Credentials.RemoteServer;
		return {};
	}
	//let dtEnd = new Date();
	//let nSeconds = Math.round((dtEnd.getTime() - dtStart.getTime()) / 1000);
	//console.log((new Date()).toISOString() + ' ' + 'Application_GetReactLoginState', json.d);
	// 07/12/2019 Paul.  Don't overwrite valid values. 
	if ( jsonReactState == null )
	{
		// 02/17/2020 Paul.  Update the theme as soon as we have the default. 
		Credentials.sUSER_THEME = json.d.CONFIG['default_theme'];
		SplendidCache.SetCONFIG(json.d.CONFIG);
		Credentials.sUSER_LANG = json.d.CONFIG['default_language'];
		SplendidCache.SetTERMINOLOGY(json.d.TERMINOLOGY);
		// 12/10/2022 Paul.  Allow Login Terminology Lists to be customized. 
		SplendidCache.SetTERMINOLOGY_LISTS        (json.d.TERMINOLOGY_LISTS        );
		// 12/07/2022 Paul.  Allow the LoginView to be customized. 
		SplendidCache.SetREACT_CUSTOM_VIEWS(json.d.REACT_CUSTOM_VIEWS);
		UpdateApplicationTheme();
	}
	if ( Sql.IsEmptyString(Credentials.sUSER_LANG) )
	{
		Credentials.sUSER_LANG = 'en-US';
	}
	// 11/18/2019 Paul.  Include Authentication method. 
	// 11/20/2020 Paul.  Always update sAUTHENTICATION as it can change if site changes. 
	//if ( Sql.IsEmptyString(Credentials.sAUTHENTICATION) )
	{
		Credentials.sAUTHENTICATION = json.d.AUTHENTICATION;
	}
	//console.log((new Date()).toISOString() + 'Loading login state took ' + nSeconds.toString() + ' seconds');
	return json.d.SingleSignOnSettings;
}

// 02/27/2016 Paul.  Combine all layout gets. 
export async function Application_GetReactState(source): Promise<any>
{
	//console.log((new Date()).toISOString() + ' ' + 'Application_GetReactState', source);
	//let dtStart = new Date();
	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	// 07/14/2021 Paul.  Use indexedDB to cache session state. 
	let res = null;
	let responseText: string = null;
	let bCachedState: boolean = false;
	let db: any = null;
	try
	{
		if ( enableReactStateCache )
		{
			// https://github.com/jakearchibald/idb
			db = await openDB(Credentials.RemoteServer, 1,
			{
				upgrade(db)
				{
					db.createObjectStore(storeName);
				}
			});
			let sLastDate: string = await db.get(storeName, 'GetReactState.LastDate');
			if ( !Sql.IsEmptyString(sLastDate) )
			{
				let sSessionStateTimeout: string = await db.get(storeName, 'GetReactState.SessionStateTimeout');
				let nSessionStateTimeout: number = Sql.ToInteger(sSessionStateTimeout);
				if ( nSessionStateTimeout <= 0 )
					nSessionStateTimeout = 20;
				let dtExpiredDate: Date = new Date(sLastDate + nSessionStateTimeout * 60000);
				let now: Date = new Date();
				if ( dtExpiredDate > now )
				{
					let CACHED_USER_SESSION : string = await db.get(storeName, 'GetReactState.USER_SESSION');
					let CURRENT_USER_SESSION: string = await GetUserSession();
					if ( CACHED_USER_SESSION == CURRENT_USER_SESSION )
					{
						// 07/14/2021 Paul.  We don't need to test the AdminState flag as it includes all normal user data. 
						responseText = await db.get(storeName, 'GetReactState');
						if ( !Sql.IsEmptyString(responseText) && responseText.length > 1000000)
						{
							bCachedState = true;
						}
					}
					else
					{
						console.log((new Date()).toISOString() + ' ' + 'Application_GetReactState: User has changed, ignoring cached ReactState');
					}
				}
			}
		}
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' ' + 'Application_GetReactState: Failed to retrieve ReactState from cache', error);
	}
	//console.log((new Date()).toISOString() + ' ' + 'Application_GetReactState bCachedState', bCachedState);
	if ( !bCachedState )
	{
		res = await SystemCacheRequestAll('GetReactState');
		responseText = await res.text();
	}

	let json = null;
	if ( !bCachedState && !res.ok )
	{
		if ( Sql.IsEmptyString(responseText) )
		{
			responseText = res.statusText;
			if ( Sql.IsEmptyString(responseText) )
			{
				switch ( res.status )
				{
					case 404:  responseText = '404 Not Found'            ;  break;
					case 403:  responseText = '403 Forbidden'            ;  break;
					case 500:  responseText = '500 Internal Server Error';  break;
					case 503:  responseText = '503 Service Unavailable'  ;  break;
					case 504:  responseText = '504 Gateway Timeout'      ;  break;
					default:   responseText = 'HTTP Error ' + res.status.toString();  break;
				}
			}
		}
		else if (StartsWith(responseText, '<?xml'))
		{
			// https://stackoverflow.com/questions/10585029/parse-an-html-string-with-js
			let doc = document.implementation.createHTMLDocument('');
			doc.documentElement.innerHTML = responseText;
			let body: any = doc.getElementsByTagName('body');
			if (body != null && body.length > 0)
				responseText = body[0].innerText;
			else
				responseText = doc.documentElement.innerText;
		}
		else if (StartsWith(responseText, '{'))
		{
			json = JSON.parse(responseText);
			if (json !== undefined && json != null)
			{
				if (json.ExceptionDetail !== undefined)
				{
					console.error(json.ExceptionDetail.Message);
					throw new Error(json.ExceptionDetail.Message);
				}
			}
		}
		console.error(responseText);
		throw new Error(responseText);
	}
	if (StartsWith(responseText, '<html>'))
	{
		throw (res.url + ' is not a avlid service URL.');
	}
	//console.log('GetSplendidResult', responseText);
	if ( StartsWith(responseText, '{') )
	{
		json = JSON.parse(responseText);
		if (json !== undefined && json != null)
		{
			if (json.ExceptionDetail !== undefined)
			{
				console.error(json.ExceptionDetail.Message);
				throw new Error(json.ExceptionDetail.Message);
			}
		}
	}
	else
	{
		json = responseText;
	}
	//let dtEnd = new Date();
	//let nSeconds = Math.round((dtEnd.getTime() - dtStart.getTime()) / 1000);
	//console.log((new Date()).toISOString() + ' ' + 'Application_GetReactState took ' + nSeconds.toString() + ' seconds');
	// 07/30/2022 Paul.  Rare case, but needs to be accounted for. 
	if ( json == null || json.d == null )
	{
		console.error((new Date()).toISOString() + ' ' + 'Application_GetReactState missing data');
		return;
	}
	else if ( json.d.TERMINOLOGY == null || json.d.TERMINOLOGY.length == 0 )
	{
		console.warn((new Date()).toISOString() + ' ' + 'Application_GetReactState missing data', json.d.TERMINOLOGY);
	}
	jsonReactState = json.d;

	// 07/14/2021 Paul.  Use indexedDB to cache session state. 
	try
	{
		// 08/21/2021 Paul.  Provide a way to disable the cache. 
		if ( enableReactStateCache && json.d.CONFIG )
		{
			enableReactStateCache = !Sql.ToBoolean(json.d.CONFIG['disableReactStateCache']);
			if ( !enableReactStateCache )
				console.log((new Date()).toISOString() + ' ' + 'Application_GetReactState: ReactStateCache has been disabled');
		}
		if ( db != null && !bCachedState && enableReactStateCache )
		{
			let now: Date = new Date();
			await db.put(storeName, responseText , 'GetReactState'           );
			await db.put(storeName, now.getTime(), 'GetReactState.LastDate'  );
			await db.put(storeName, false        , 'GetReactState.AdminState');
			await db.put(storeName, json.d.USER_PROFILE.USER_SESSION, 'GetReactState.USER_SESSION'       );
			await db.put(storeName, json.d.SessionStateTimeout      , 'GetReactState.SessionStateTimeout');
		}
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' ' + 'Application_GetReactState: Failed to save ReactState to cache', error);
	}

	// 05/17/2019 Paul.  Include Config, Modules and Tabe Menu in main layout query. 
	SplendidCache.SetCONFIG                   (json.d.CONFIG                   );
	SplendidCache.SetMODULES                  (json.d.MODULES                  );
	SplendidCache.SetTAB_MENU                 (json.d.TAB_MENU                 );
	// 07/21/2019 Paul.  We need UserAccess control for buttons. 
	SplendidCache.SetMODULE_ACL_ACCESS        (json.d.MODULE_ACL_ACCESS        );
	SplendidCache.SetACL_ACCESS               (json.d.ACL_ACCESS               );
	SplendidCache.SetACL_FIELD_ACCESS         (json.d.ACL_FIELD_ACCESS         );
	// 01/22/2021 Paul.  Some customizations may be dependent on role name. 
	SplendidCache.SetACL_ROLES                (json.d.ACL_ROLES                );
	// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	SplendidCache.SetGRIDVIEWS                (json.d.GRIDVIEWS                );
	SplendidCache.SetGRIDVIEWS_COLUMNS        (json.d.GRIDVIEWS_COLUMNS        );
	SplendidCache.SetDETAILVIEWS_FIELDS       (json.d.DETAILVIEWS_FIELDS       );
	SplendidCache.SetEDITVIEWS_FIELDS         (json.d.EDITVIEWS_FIELDS         );
	SplendidCache.SetDETAILVIEWS_RELATIONSHIPS(json.d.DETAILVIEWS_RELATIONSHIPS);
	SplendidCache.SetEDITVIEWS_RELATIONSHIPS  (json.d.EDITVIEWS_RELATIONSHIPS  );
	SplendidCache.SetDYNAMIC_BUTTONS          (json.d.DYNAMIC_BUTTONS          );
	// 08/15/2019 Paul.  Add support for menu shortcuts. 
	SplendidCache.SetSHORTCUTS                (json.d.SHORTCUTS                );
	SplendidCache.SetTERMINOLOGY_LISTS        (json.d.TERMINOLOGY_LISTS        );
	SplendidCache.SetTERMINOLOGY              (json.d.TERMINOLOGY              );
	// 07/01/2019 Paul.  The SubPanelsView needs to understand how to manage all relationships. 
	SplendidCache.SetRELATIONSHIPS            (json.d.RELATIONSHIPS            );
	SplendidCache.SetTAX_RATES                (json.d.TAX_RATES                );
	SplendidCache.SetDISCOUNTS                (json.d.DISCOUNTS                );
	// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
	SplendidCache.SetTIMEZONES                (json.d.TIMEZONES                );
	SplendidCache.SetCURRENCIES               (json.d.CURRENCIES               );
	// 05/26/2020 Paul.  Languages was returned, but not set. 
	SplendidCache.SetLANGUAGES                (json.d.LANGUAGES                );
	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	SplendidCache.SetFAVORITES                (json.d.FAVORITES                );
	SplendidCache.SetLAST_VIEWED              (json.d.LAST_VIEWED              );
	SplendidCache.SetSAVED_SEARCH             (json.d.SAVED_SEARCH             );
	// 05/10/2019 Paul.  Saved search needs to know the available columns. 
	SplendidCache.SetMODULE_COLUMNS           (json.d.MODULE_COLUMNS           );
	// 05/24/2019 Paul.  Dashboards and Dashlets are now included. 
	SplendidCache.SetDASHBOARDS               (json.d.DASHBOARDS               );
	SplendidCache.SetDASHBOARDS_PANELS        (json.d.DASHBOARDS_PANELS        );
	SplendidCache.SetUSERS                    (json.d.USERS                    );
	SplendidCache.SetTEAMS                    (json.d.TEAMS                    );
	SplendidCache.SetREACT_CUSTOM_VIEWS       (json.d.REACT_CUSTOM_VIEWS       );
	// 05/03/2020 Paul.  Emails.EditView should use cached list of signatures. 
	SplendidCache.SetSIGNATURES               (json.d.SIGNATURES               );
	// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundMail. 
	SplendidCache.SetOUTBOUND_EMAILS          (json.d.OUTBOUND_EMAILS          );
	// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundSms. 
	SplendidCache.SetOUTBOUND_SMS             (json.d.OUTBOUND_SMS             );

	//console.log((new Date()).toISOString() + ' ' + 'Application_GetReactState TabMenu', json.d.TAB_MENU);
	//console.log((new Date()).toISOString() + ' ' + 'Application_GetReactState TERMINOLOGY', json.d.TERMINOLOGY);
	// 12/23/2019 Paul.  Return the team tree as an object tree instead of XML. 
	Credentials.SetTeamTree                   (json.d.TEAM_TREE                );
	// 05/28/2019 Paul.  Set the profile last so that any obserable on bIsAuthenticated will fire after state completely set. 
	Credentials.SetUserProfile                (json.d.USER_PROFILE             );
	// 09/19/2020 Paul.  Provide events to start/stop SignalR. 
	// 06/15/2021 Paul.  Allow SignalR to be disabled.
	if ( !Sql.ToBoolean(SplendidCache.Config('SignalR.Disabled')) )
		SignalRStore.Startup();

	// 05/28/2019 Paul.  We are getting an empty modules list, not sure why.  Use that to determine success. 
	// 05/28/2019 Paul.  The Modules list being empty seems to be a missing Application.Lock() in SplendidInit.InitApp(). 
	let nModules = 0;
	if ( json.d.MODULES != null )
	{
		for ( let module in json.d.MODULES )
		{
			nModules++;
			break;
		}
	}
	//let status = nModules > 0 && json.d.USER_PROFILE != null && json.d.USER_PROFILE.USER_ID != null;
	//console.log((new Date()).toISOString() + ' ' + 'Application_GetReactState Done loading', status, (!status ? json.d : null));
	//console.log((new Date()).toISOString() + ' Loading all layouts took ' + nSeconds.toString() + ' seconds');
	return json.d;
}

export async function Admin_GetReactState(sCaller?: string): Promise<any>
{
	//console.log((new Date()).toISOString() + ' ' + 'Admin_GetReactState from ' + sCaller);
	var dtStart = new Date();
	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	// 07/14/2021 Paul.  Use indexedDB to cache session state. 
	let res = null;
	let responseText: string = null;
	let bCachedState: boolean = false;
	let db: any = null;
	try
	{
		if ( enableReactStateCache )
		{
			// https://github.com/jakearchibald/idb
			db = await openDB(Credentials.RemoteServer, 1,
			{
				upgrade(db)
				{
					db.createObjectStore(storeName);
				}
			});
			let sLastDate: string = await db.get(storeName, 'GetReactState.LastDate');
			if ( !Sql.IsEmptyString(sLastDate) )
			{
				let sSessionStateTimeout: string = await db.get(storeName, 'GetReactState.SessionStateTimeout');
				let nSessionStateTimeout: number = Sql.ToInteger(sSessionStateTimeout);
				if ( nSessionStateTimeout <= 0 )
					nSessionStateTimeout = 20;
				let dtExpiredDate: Date = new Date(sLastDate + nSessionStateTimeout * 60000);
				let now: Date = new Date();
				if ( dtExpiredDate > now )
				{
					let CACHED_USER_SESSION : string = await db.get(storeName, 'GetReactState.USER_SESSION');
					let CURRENT_USER_SESSION: string = await GetUserSession();
					if ( CACHED_USER_SESSION == CURRENT_USER_SESSION )
					{
						// 07/14/2021 Paul.  Make sure that the state does apply to admin login. 
						let sAdminState: string = await db.get(storeName, 'GetReactState.AdminState');
						if ( Sql.ToBoolean(sAdminState) )
						{
							responseText = await db.get(storeName, 'GetReactState');
							if ( !Sql.IsEmptyString(responseText) && responseText.length > 1000000)
							{
								bCachedState = true;
							}
						}
					}
					else
					{
						console.log((new Date()).toISOString() + ' ' + 'Admin_GetReactState: User has changed, ignoring cached ReactState');
					}
				}
			}
		}
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' ' + 'Admin_GetReactState: Failed to retrieve ReactState from cache', error);
	}
	//console.log((new Date()).toISOString() + ' ' + 'Admin_GetReactState bCachedState', bCachedState);
	if ( !bCachedState )
	{
		res = await AdminRequestAll('GetReactState');
		responseText = await res.text();
	}

	let json = null;
	if ( !bCachedState && !res.ok )
	{
		if ( Sql.IsEmptyString(responseText) )
		{
			responseText = res.statusText;
			if ( Sql.IsEmptyString(responseText) )
			{
				switch ( res.status )
				{
					case 404:  responseText = '404 Not Found'            ;  break;
					case 403:  responseText = '403 Forbidden'            ;  break;
					case 500:  responseText = '500 Internal Server Error';  break;
					case 503:  responseText = '503 Service Unavailable'  ;  break;
					case 504:  responseText = '504 Gateway Timeout'      ;  break;
					default:   responseText = 'HTTP Error ' + res.status.toString();  break;
				}
			}
		}
		else if (StartsWith(responseText, '<?xml'))
		{
			// https://stackoverflow.com/questions/10585029/parse-an-html-string-with-js
			let doc = document.implementation.createHTMLDocument('');
			doc.documentElement.innerHTML = responseText;
			let body: any = doc.getElementsByTagName('body');
			if (body != null && body.length > 0)
				responseText = body[0].innerText;
			else
				responseText = doc.documentElement.innerText;
		}
		else if (StartsWith(responseText, '{'))
		{
			json = JSON.parse(responseText);
			if (json !== undefined && json != null)
			{
				if (json.ExceptionDetail !== undefined)
				{
					console.error(json.ExceptionDetail.Message);
					throw new Error(json.ExceptionDetail.Message);
				}
			}
		}
		console.error(responseText);
		throw new Error(responseText);
	}
	if (StartsWith(responseText, '<html>'))
	{
		throw (res.url + ' is not a avlid service URL.');
	}
	//console.log('GetSplendidResult', responseText);
	if ( StartsWith(responseText, '{') )
	{
		json = JSON.parse(responseText);
		if (json !== undefined && json != null)
		{
			if (json.ExceptionDetail !== undefined)
			{
				console.error(json.ExceptionDetail.Message);
				throw new Error(json.ExceptionDetail.Message);
			}
		}
	}
	else
	{
		json = responseText;
	}

	var dtEnd = new Date();
	var nSeconds = Math.round((dtEnd.getTime() - dtStart.getTime()) / 1000);
	//console.log((new Date()).toISOString() + ' ' + 'Admin_GetReactState took ' + nSeconds.toString() + ' seconds');
	// 07/30/2022 Paul.  Rare case, but needs to be accounted for. 
	if ( json == null || json.d == null )
	{
		console.error((new Date()).toISOString() + ' ' + 'Admin_GetReactState missing data', json);
		return;
	}
	else if ( json.d.TERMINOLOGY == null || json.d.TERMINOLOGY.length == 0 )
	{
		console.warn((new Date()).toISOString() + ' ' + 'Admin_GetReactState missing data', json.d.TERMINOLOGY);
	}
	jsonReactState = json.d;

	// 07/14/2021 Paul.  Use indexedDB to cache session state. 
	try
	{
		// 08/21/2021 Paul.  Provide a way to disable the cache. 
		if ( enableReactStateCache && json.d.CONFIG )
		{
			enableReactStateCache = !Sql.ToBoolean(json.d.CONFIG['disableReactStateCache']);
			if ( !enableReactStateCache )
				console.log((new Date()).toISOString() + ' ' + 'Admin_GetReactState: ReactStateCache has been disabled');
		}
		if ( db != null && !bCachedState && enableReactStateCache )
		{
			let now: Date = new Date();
			await db.put(storeName, responseText , 'GetReactState'           );
			await db.put(storeName, now.getTime(), 'GetReactState.LastDate'  );
			await db.put(storeName, true         , 'GetReactState.AdminState');
			await db.put(storeName, json.d.USER_PROFILE.USER_SESSION, 'GetReactState.USER_SESSION'       );
			await db.put(storeName, json.d.SessionStateTimeout      , 'GetReactState.SessionStateTimeout');
		}
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' ' + 'Admin_GetReactState: Failed to save ReactState to cache', error);
	}

	// 05/17/2019 Paul.  Include Config, Modules and Tabe Menu in main layout query. 
	SplendidCache.SetCONFIG                   (json.d.CONFIG                   );
	SplendidCache.SetMODULES                  (json.d.MODULES                  );
	SplendidCache.SetTAB_MENU                 (json.d.TAB_MENU                 );
	// 07/21/2019 Paul.  We need UserAccess control for buttons. 
	SplendidCache.SetMODULE_ACL_ACCESS        (json.d.MODULE_ACL_ACCESS        );
	SplendidCache.SetACL_ACCESS               (json.d.ACL_ACCESS               );
	SplendidCache.SetACL_FIELD_ACCESS         (json.d.ACL_FIELD_ACCESS         );
	// 01/22/2021 Paul.  Some customizations may be dependent on role name. 
	SplendidCache.SetACL_ROLES                (json.d.ACL_ROLES                );
	// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	SplendidCache.SetGRIDVIEWS                (json.d.GRIDVIEWS                );
	SplendidCache.SetGRIDVIEWS_COLUMNS        (json.d.GRIDVIEWS_COLUMNS        );
	SplendidCache.SetDETAILVIEWS_FIELDS       (json.d.DETAILVIEWS_FIELDS       );
	SplendidCache.SetEDITVIEWS_FIELDS         (json.d.EDITVIEWS_FIELDS         );
	SplendidCache.SetDETAILVIEWS_RELATIONSHIPS(json.d.DETAILVIEWS_RELATIONSHIPS);
	SplendidCache.SetEDITVIEWS_RELATIONSHIPS  (json.d.EDITVIEWS_RELATIONSHIPS  );
	SplendidCache.SetDYNAMIC_BUTTONS          (json.d.DYNAMIC_BUTTONS          );
	// 08/15/2019 Paul.  Add support for menu shortcuts. 
	SplendidCache.SetSHORTCUTS                (json.d.SHORTCUTS                );
	SplendidCache.SetTERMINOLOGY_LISTS        (json.d.TERMINOLOGY_LISTS        );
	SplendidCache.SetTERMINOLOGY              (json.d.TERMINOLOGY              );
	// 07/01/2019 Paul.  The SubPanelsView needs to understand how to manage all relationships. 
	SplendidCache.SetRELATIONSHIPS            (json.d.RELATIONSHIPS            );
	SplendidCache.SetTAX_RATES                (json.d.TAX_RATES                );
	SplendidCache.SetDISCOUNTS                (json.d.DISCOUNTS                );
	// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
	SplendidCache.SetTIMEZONES                (json.d.TIMEZONES                );
	SplendidCache.SetCURRENCIES               (json.d.CURRENCIES               );
	// 05/26/2020 Paul.  Languages was returned, but not set. 
	SplendidCache.SetLANGUAGES                (json.d.LANGUAGES                );
	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	SplendidCache.SetFAVORITES                (json.d.FAVORITES                );
	SplendidCache.SetLAST_VIEWED              (json.d.LAST_VIEWED              );
	SplendidCache.SetSAVED_SEARCH             (json.d.SAVED_SEARCH             );
	// 05/10/2019 Paul.  Saved search needs to know the available columns. 
	SplendidCache.SetMODULE_COLUMNS           (json.d.MODULE_COLUMNS           );
	// 05/24/2019 Paul.  Dashboards and Dashlets are now included. 
	SplendidCache.SetDASHBOARDS               (json.d.DASHBOARDS               );
	SplendidCache.SetDASHBOARDS_PANELS        (json.d.DASHBOARDS_PANELS        );
	SplendidCache.SetUSERS                    (json.d.USERS                    );
	SplendidCache.SetTEAMS                    (json.d.TEAMS                    );
	SplendidCache.SetREACT_CUSTOM_VIEWS       (json.d.REACT_CUSTOM_VIEWS       );
	SplendidCache.SetADMIN_MENU               (json.d.ADMIN_MENU               );
	// 05/03/2020 Paul.  Emails.EditView should use cached list of signatures. 
	SplendidCache.SetSIGNATURES               (json.d.SIGNATURES               );
	// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundMail. 
	SplendidCache.SetOUTBOUND_EMAILS          (json.d.OUTBOUND_EMAILS          );
	// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundSms. 
	SplendidCache.SetOUTBOUND_SMS             (json.d.OUTBOUND_SMS             );
	// 12/23/2019 Paul.  Return the team tree as an object tree instead of XML. 
	Credentials.SetTeamTree                   (json.d.TEAM_TREE                );
	// 05/28/2019 Paul.  Set the profile last so that any obserable on bIsAuthenticated will fire after state completely set. 
	Credentials.SetUserProfile                (json.d.USER_PROFILE             );
	// 09/19/2020 Paul.  Provide events to start/stop SignalR. 
	// 06/15/2021 Paul.  Allow SignalR to be disabled.
	if ( !Sql.ToBoolean(SplendidCache.Config('SignalR.Disabled')) )
		SignalRStore.Startup();
	
	// 05/28/2019 Paul.  We are getting an empty modules list, not sure why.  Use that to determine success. 
	// 05/28/2019 Paul.  The Modules list being empty seems to be a missing Application.Lock() in SplendidInit.InitApp(). 
	let nModules = 0;
	if ( json.d.MODULES != null )
	{
		for ( let module in json.d.MODULES )
		{
			nModules++;
			break;
		}
	}
	let status = nModules > 0 && json.d.USER_PROFILE != null && json.d.USER_PROFILE.USER_ID != null;
	//console.log((new Date()).toISOString() + ' ' + 'Admin_GetReactState ADMIN_MENU', json.d.ADMIN_MENU);
	//console.log((new Date()).toISOString() + ' Loading all admin layouts took ' + nSeconds.toString() + ' seconds');
	return status;
}

// 02/20/2021 Paul.  GetReactMenu() is primarily used by Admin ConfigureTabs page. 
export async function Admin_GetReactMenu(sCaller?: string): Promise<any>
{
	//console.log((new Date()).toISOString() + ' ' + 'Admin_GetReactMenu from ' + sCaller);
	let res = await AdminRequestAll('GetReactMenu');
	let json = await GetSplendidResult(res);

	jsonReactState = json.d;
	SplendidCache.SetTAB_MENU(json.d.TAB_MENU);
	SplendidCache.NAV_MENU_CHANGE++;
}

// 04/04/2021 Paul.  Cache the ArchiveViewExists flag. 
export async function ArchiveViewExists(VIEW_NAME: string): Promise<any>
{
	let bExists: boolean = false;
	if ( SplendidCache.ARCHIVE_VIEWS[VIEW_NAME] === undefined )
	{
		let res = await CreateSplendidRequest('Rest.svc/ArchiveViewExists?VIEW_NAME=' + VIEW_NAME, 'GET');
		let json = await GetSplendidResult(res);
		bExists = json.d;
		SplendidCache.ARCHIVE_VIEWS[VIEW_NAME] = bExists;
	}
	else
	{
		bExists = SplendidCache.ARCHIVE_VIEWS[VIEW_NAME];
	}
	return bExists;
}

