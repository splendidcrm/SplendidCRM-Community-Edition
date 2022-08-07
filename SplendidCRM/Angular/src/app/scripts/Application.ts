/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import { Injectable                          } from '@angular/core'                      ;
import { Location                            } from '@angular/common'                    ;
import { Router                              } from '@angular/router'                    ;
import { openDB, deleteDB, wrap, unwrap      } from 'idb'                                ;
import { SplendidRequestService              } from '../scripts/SplendidRequest'         ;
import { SplendidCacheService                } from '../scripts/SplendidCache'           ;
import { CredentialsService                  } from '../scripts/Credentials'             ;
import { StartsWith, UpdateApplicationTheme  } from '../scripts/utility'                 ;
import Sql                                     from '../scripts/Sql'                     ;
import SINGLE_SIGN_ON                          from '../types/SINGLE_SIGN_ON'            ;

const storeName: string  = 'SplendidCRMReactClient';

@Injectable({
	providedIn: 'root'
})
export class ApplicationService
{
	private bIsInitializing      : boolean = false;
	// 07/01/2017 Paul.  Cache IsAuthenticated for 1 second. 
	private lastIsAuthenticated  : number  = 0;
	private enableReactStateCache: boolean = false;

	constructor(private router: Router, private SplendidRequest: SplendidRequestService, protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService)
	{
		//console.log(this.constructor.name + '..constructor', SplendidRequest, SplendidCache, Credentials);
		// 05/27/2022 Paul.  TODO. 
		this.enableReactStateCache = true; // !window['cordova'];
	}

	public UpdateLastAuthenticated()
	{
		this.lastIsAuthenticated = (new Date()).getTime();
	}

	public async GetReactLoginState() : Promise<any>
	{
		let json: any = await this.SplendidRequest.SystemCacheRequestAll('GetReactLoginState');
		// 07/12/2019 Paul.  Don't overwrite valid values. 
		if ( this.SplendidCache.jsonReactState == null )
		{
			// 02/17/2020 Paul.  Update the theme as soon as we have the default. 
			this.Credentials.sUSER_THEME = json.d.CONFIG['default_theme'];
			this.SplendidCache.SetCONFIG(json.d.CONFIG);
			this.Credentials.sUSER_LANG = json.d.CONFIG['default_language'];
			this.SplendidCache.SetTERMINOLOGY(json.d.TERMINOLOGY);
			UpdateApplicationTheme(this.Credentials);
		}
		if ( Sql.IsEmptyString(this.Credentials.sUSER_LANG) )
		{
			this.Credentials.sUSER_LANG = 'en-US';
		}
		// 11/18/2019 Paul.  Include Authentication method. 
		// 11/20/2020 Paul.  Always update sAUTHENTICATION as it can change if site changes. 
		//if ( Sql.IsEmptyString(Credentials.sAUTHENTICATION) )
		{
			this.Credentials.sAUTHENTICATION = json.d.AUTHENTICATION;
		}
		return json.d.SingleSignOnSettings;
	}

	public async GetReactState(source: string): Promise<any>
	{
		//console.log('Application_GetReactState', source);
		//let dtStart = new Date();
		// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
		// 07/14/2021 Paul.  Use indexedDB to cache session state. 
		let res = null;
		let responseText: string = null;
		let bCachedState: boolean = false;
		let db: any = null;
		try
		{
			if ( this.enableReactStateCache )
			{
				// https://github.com/jakearchibald/idb
				db = await openDB(this.Credentials.RemoteServer, 1,
				{
					upgrade(db: any)
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
						let CURRENT_USER_SESSION: string = await this.GetUserSession();
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
							console.log('Application_GetReactState: User has changed, ignoring cached ReactState');
						}
					}
				}
			}
		}
		catch(error)
		{
			console.error('Application_GetReactState: Failed to retrieve ReactState from cache', error);
		}
		//console.log('Application_GetReactState bCachedState', bCachedState);
		let json: any = null;
		if ( !bCachedState )
		{
			responseText = await this.SplendidRequest.SystemCacheRequestAll('GetReactState');
		}
		if ( !bCachedState && typeof(responseText) == 'string' )
		{
			if ( Sql.IsEmptyString(responseText) )
			{
				responseText = "Unknown status";
				/*
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
				*/
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
		if ( typeof(responseText) == 'string' )
		{
			if ( StartsWith(responseText, '<html>') )
			{
				throw (this.Credentials.sREMOTE_SERVER + ' is not a avlid service URL.');
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
		}
		else
		{
			json = responseText;
		}
		//let dtEnd = new Date();
		//let nSeconds = Math.round((dtEnd.getTime() - dtStart.getTime()) / 1000);
		//console.log('Application_GetReactState took ' + nSeconds.toString() + ' seconds');
		// 07/30/2022 Paul.  Rare case, but needs to be accounted for. 
		if ( json == null || json.d == null )
		{
			console.error('Application_GetReactState missing data');
			return;
		}
		else if ( json.d.TERMINOLOGY == null || json.d.TERMINOLOGY.length == 0 )
		{
			console.warn('Application_GetReactState missing data', json.d.TERMINOLOGY);
		}
		this.SplendidCache.jsonReactState = json.d;

		// 07/14/2021 Paul.  Use indexedDB to cache session state. 
		try
		{
			// 08/21/2021 Paul.  Provide a way to disable the cache. 
			if ( this.enableReactStateCache && json.d.CONFIG )
			{
				this.enableReactStateCache = !Sql.ToBoolean(json.d.CONFIG['disableReactStateCache']);
				if ( !this.enableReactStateCache )
					console.log('Application_GetReactState: ReactStateCache has been disabled');
			}
			if ( db != null && !bCachedState && this.enableReactStateCache )
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
			console.error('Application_GetReactState: Failed to save ReactState to cache', error);
		}

		// 05/17/2019 Paul.  Include Config, Modules and Tabe Menu in main layout query. 
		this.SplendidCache.SetCONFIG                   (json.d.CONFIG                   );
		this.SplendidCache.SetMODULES                  (json.d.MODULES                  );
		this.SplendidCache.SetTAB_MENU                 (json.d.TAB_MENU                 );
		// 07/21/2019 Paul.  We need UserAccess control for buttons. 
		this.SplendidCache.SetMODULE_ACL_ACCESS        (json.d.MODULE_ACL_ACCESS        );
		this.SplendidCache.SetACL_ACCESS               (json.d.ACL_ACCESS               );
		this.SplendidCache.SetACL_FIELD_ACCESS         (json.d.ACL_FIELD_ACCESS         );
		// 01/22/2021 Paul.  Some customizations may be dependent on role name. 
		this.SplendidCache.SetACL_ROLES                (json.d.ACL_ROLES                );
		// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
		this.SplendidCache.SetGRIDVIEWS                (json.d.GRIDVIEWS                );
		this.SplendidCache.SetGRIDVIEWS_COLUMNS        (json.d.GRIDVIEWS_COLUMNS        );
		this.SplendidCache.SetDETAILVIEWS_FIELDS       (json.d.DETAILVIEWS_FIELDS       );
		this.SplendidCache.SetEDITVIEWS_FIELDS         (json.d.EDITVIEWS_FIELDS         );
		this.SplendidCache.SetDETAILVIEWS_RELATIONSHIPS(json.d.DETAILVIEWS_RELATIONSHIPS);
		this.SplendidCache.SetEDITVIEWS_RELATIONSHIPS  (json.d.EDITVIEWS_RELATIONSHIPS  );
		this.SplendidCache.SetDYNAMIC_BUTTONS          (json.d.DYNAMIC_BUTTONS          );
		// 08/15/2019 Paul.  Add support for menu shortcuts. 
		this.SplendidCache.SetSHORTCUTS                (json.d.SHORTCUTS                );
		this.SplendidCache.SetTERMINOLOGY_LISTS        (json.d.TERMINOLOGY_LISTS        );
		this.SplendidCache.SetTERMINOLOGY              (json.d.TERMINOLOGY              );
		// 07/01/2019 Paul.  The SubPanelsView needs to understand how to manage all relationships. 
		this.SplendidCache.SetRELATIONSHIPS            (json.d.RELATIONSHIPS            );
		this.SplendidCache.SetTAX_RATES                (json.d.TAX_RATES                );
		this.SplendidCache.SetDISCOUNTS                (json.d.DISCOUNTS                );
		// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
		this.SplendidCache.SetTIMEZONES                (json.d.TIMEZONES                );
		this.SplendidCache.SetCURRENCIES               (json.d.CURRENCIES               );
		// 05/26/2020 Paul.  Languages was returned, but not set. 
		this.SplendidCache.SetLANGUAGES                (json.d.LANGUAGES                );
		// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
		this.SplendidCache.SetFAVORITES                (json.d.FAVORITES                );
		this.SplendidCache.SetLAST_VIEWED              (json.d.LAST_VIEWED              );
		this.SplendidCache.SetSAVED_SEARCH             (json.d.SAVED_SEARCH             );
		// 05/10/2019 Paul.  Saved search needs to know the available columns. 
		this.SplendidCache.SetMODULE_COLUMNS           (json.d.MODULE_COLUMNS           );
		// 05/24/2019 Paul.  Dashboards and Dashlets are now included. 
		this.SplendidCache.SetDASHBOARDS               (json.d.DASHBOARDS               );
		this.SplendidCache.SetDASHBOARDS_PANELS        (json.d.DASHBOARDS_PANELS        );
		this.SplendidCache.SetUSERS                    (json.d.USERS                    );
		this.SplendidCache.SetTEAMS                    (json.d.TEAMS                    );
		this.SplendidCache.SetREACT_CUSTOM_VIEWS       (json.d.REACT_CUSTOM_VIEWS       );
		// 05/03/2020 Paul.  Emails.EditView should use cached list of signatures. 
		this.SplendidCache.SetSIGNATURES               (json.d.SIGNATURES               );
		// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundMail. 
		this.SplendidCache.SetOUTBOUND_EMAILS          (json.d.OUTBOUND_EMAILS          );
		// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundSms. 
		this.SplendidCache.SetOUTBOUND_SMS             (json.d.OUTBOUND_SMS             );

		//console.log('Application_GetReactState TabMenu', json.d.TAB_MENU);
		//console.log('Application_GetReactState TERMINOLOGY', json.d.TERMINOLOGY);
		// 12/23/2019 Paul.  Return the team tree as an object tree instead of XML. 
		this.Credentials.SetTeamTree                   (json.d.TEAM_TREE                );
		// 05/28/2019 Paul.  Set the profile last so that any obserable on bIsAuthenticated will fire after state completely set. 
		this.Credentials.SetUserProfile                (json.d.USER_PROFILE             , this.SplendidCache);
		// 09/19/2020 Paul.  Provide events to start/stop SignalR. 
		// 06/15/2021 Paul.  Allow SignalR to be disabled.
		// 05/21/2022 Paul.  TODO.  Add support for Signal-R. 
		//if ( !Sql.ToBoolean(this.SplendidCache.Config('SignalR.Disabled')) )
		//	SignalRStore.Startup();

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
		//console.log('Application_GetReactState Done loading', status, (!status ? json.d : null));
		//console.log((new Date()).toISOString() + ' Loading all layouts took ' + nSeconds.toString() + ' seconds');
		return json.d;
	}

	public async Admin_GetReactState(sCaller?: string): Promise<any>
	{
		//console.log('Admin_GetReactState from ' + sCaller);
		var dtStart = new Date();
		// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
		// 07/14/2021 Paul.  Use indexedDB to cache session state. 
		let res = null;
		let responseText: string = null;
		let bCachedState: boolean = false;
		let db: any = null;
		try
		{
			if ( this.enableReactStateCache )
			{
				// https://github.com/jakearchibald/idb
				db = await openDB(this.Credentials.RemoteServer, 1,
				{
					upgrade(db: any)
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
						let CURRENT_USER_SESSION: string = await this.GetUserSession();
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
							console.log('Admin_GetReactState: User has changed, ignoring cached ReactState');
						}
					}
				}
			}
		}
		catch(error)
		{
			console.error('Admin_GetReactState: Failed to retrieve ReactState from cache', error);
		}
		//console.log('Admin_GetReactState bCachedState', bCachedState);
		let json: any = null;
		if ( !bCachedState )
		{
			json = await this.SplendidRequest.AdminRequestAll('GetReactState');
			responseText = json;
		}
		// 05/21/2022 Paul.  TODO.  Handle invalid page error returned as html. 
		/*
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
		*/

		var dtEnd = new Date();
		var nSeconds = Math.round((dtEnd.getTime() - dtStart.getTime()) / 1000);
		//console.log('Admin_GetReactState took ' + nSeconds.toString() + ' seconds');
		// 07/30/2022 Paul.  Rare case, but needs to be accounted for. 
		if ( json == null || json.d == null )
		{
			console.error('Admin_GetReactState missing data');
			return;
		}
		else if ( json.d.TERMINOLOGY == null || json.d.TERMINOLOGY.length == 0 )
		{
			console.warn('Admin_GetReactState missing data', json.d.TERMINOLOGY);
		}
		this.SplendidCache.jsonReactState = json.d;

		// 07/14/2021 Paul.  Use indexedDB to cache session state. 
		try
		{
			// 08/21/2021 Paul.  Provide a way to disable the cache. 
			if ( this.enableReactStateCache && json.d.CONFIG )
			{
				this.enableReactStateCache = !Sql.ToBoolean(json.d.CONFIG['disableReactStateCache']);
				if ( !this.enableReactStateCache )
					console.log('Admin_GetReactState: ReactStateCache has been disabled');
			}
			if ( db != null && !bCachedState && this.enableReactStateCache )
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
			console.error('Admin_GetReactState: Failed to save ReactState to cache', error);
		}

		// 05/17/2019 Paul.  Include Config, Modules and Tabe Menu in main layout query. 
		this.SplendidCache.SetCONFIG                   (json.d.CONFIG                   );
		this.SplendidCache.SetMODULES                  (json.d.MODULES                  );
		this.SplendidCache.SetTAB_MENU                 (json.d.TAB_MENU                 );
		// 07/21/2019 Paul.  We need UserAccess control for buttons. 
		this.SplendidCache.SetMODULE_ACL_ACCESS        (json.d.MODULE_ACL_ACCESS        );
		this.SplendidCache.SetACL_ACCESS               (json.d.ACL_ACCESS               );
		this.SplendidCache.SetACL_FIELD_ACCESS         (json.d.ACL_FIELD_ACCESS         );
		// 01/22/2021 Paul.  Some customizations may be dependent on role name. 
		this.SplendidCache.SetACL_ROLES                (json.d.ACL_ROLES                );
		// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
		this.SplendidCache.SetGRIDVIEWS                (json.d.GRIDVIEWS                );
		this.SplendidCache.SetGRIDVIEWS_COLUMNS        (json.d.GRIDVIEWS_COLUMNS        );
		this.SplendidCache.SetDETAILVIEWS_FIELDS       (json.d.DETAILVIEWS_FIELDS       );
		this.SplendidCache.SetEDITVIEWS_FIELDS         (json.d.EDITVIEWS_FIELDS         );
		this.SplendidCache.SetDETAILVIEWS_RELATIONSHIPS(json.d.DETAILVIEWS_RELATIONSHIPS);
		this.SplendidCache.SetEDITVIEWS_RELATIONSHIPS  (json.d.EDITVIEWS_RELATIONSHIPS  );
		this.SplendidCache.SetDYNAMIC_BUTTONS          (json.d.DYNAMIC_BUTTONS          );
		// 08/15/2019 Paul.  Add support for menu shortcuts. 
		this.SplendidCache.SetSHORTCUTS                (json.d.SHORTCUTS                );
		this.SplendidCache.SetTERMINOLOGY_LISTS        (json.d.TERMINOLOGY_LISTS        );
		this.SplendidCache.SetTERMINOLOGY              (json.d.TERMINOLOGY              );
		// 07/01/2019 Paul.  The SubPanelsView needs to understand how to manage all relationships. 
		this.SplendidCache.SetRELATIONSHIPS            (json.d.RELATIONSHIPS            );
		this.SplendidCache.SetTAX_RATES                (json.d.TAX_RATES                );
		this.SplendidCache.SetDISCOUNTS                (json.d.DISCOUNTS                );
		// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
		this.SplendidCache.SetTIMEZONES                (json.d.TIMEZONES                );
		this.SplendidCache.SetCURRENCIES               (json.d.CURRENCIES               );
		// 05/26/2020 Paul.  Languages was returned, but not set. 
		this.SplendidCache.SetLANGUAGES                (json.d.LANGUAGES                );
		// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
		this.SplendidCache.SetFAVORITES                (json.d.FAVORITES                );
		this.SplendidCache.SetLAST_VIEWED              (json.d.LAST_VIEWED              );
		this.SplendidCache.SetSAVED_SEARCH             (json.d.SAVED_SEARCH             );
		// 05/10/2019 Paul.  Saved search needs to know the available columns. 
		this.SplendidCache.SetMODULE_COLUMNS           (json.d.MODULE_COLUMNS           );
		// 05/24/2019 Paul.  Dashboards and Dashlets are now included. 
		this.SplendidCache.SetDASHBOARDS               (json.d.DASHBOARDS               );
		this.SplendidCache.SetDASHBOARDS_PANELS        (json.d.DASHBOARDS_PANELS        );
		this.SplendidCache.SetUSERS                    (json.d.USERS                    );
		this.SplendidCache.SetTEAMS                    (json.d.TEAMS                    );
		this.SplendidCache.SetREACT_CUSTOM_VIEWS       (json.d.REACT_CUSTOM_VIEWS       );
		this.SplendidCache.SetADMIN_MENU               (json.d.ADMIN_MENU               );
		// 05/03/2020 Paul.  Emails.EditView should use cached list of signatures. 
		this.SplendidCache.SetSIGNATURES               (json.d.SIGNATURES               );
		// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundMail. 
		this.SplendidCache.SetOUTBOUND_EMAILS          (json.d.OUTBOUND_EMAILS          );
		// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundSms. 
		this.SplendidCache.SetOUTBOUND_SMS             (json.d.OUTBOUND_SMS             );
		// 12/23/2019 Paul.  Return the team tree as an object tree instead of XML. 
		this.Credentials.SetTeamTree                   (json.d.TEAM_TREE                );
		// 05/28/2019 Paul.  Set the profile last so that any obserable on bIsAuthenticated will fire after state completely set. 
		this.Credentials.SetUserProfile                (json.d.USER_PROFILE             , this.SplendidCache);
		// 09/19/2020 Paul.  Provide events to start/stop SignalR. 
		// 06/15/2021 Paul.  Allow SignalR to be disabled.
		// 05/21/2022 Paul.  TODO.  Add support for Signal-R. 
		//if ( !Sql.ToBoolean(this.SplendidCache.Config('SignalR.Disabled')) )
		//	SignalRStore.Startup();
	
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
		//console.log('Admin_GetReactState ADMIN_MENU', json.d.ADMIN_MENU);
		//console.log((new Date()).toISOString() + ' Loading all admin layouts took ' + nSeconds.toString() + ' seconds');
		return status;
	}

	public async Init(source: string): Promise<boolean>
	{
		//console.log(this.constructor.name + '.Init', source, window.location.href);
		if ( !this.SplendidCache.IsInitialized && !this.bIsInitializing )
		{
			this.bIsInitializing = true;
			try
			{
				this.SplendidCache.Reset();
				// 10/19/2020 Paul.  Load Admin state
				if ( window.location.href.indexOf('/Administration/') > 0 )
				{
					await this.Admin_GetReactState(source);
				}
				else
				{
					await this.GetReactState(source);
				}
				//console.log(this.constructor.name + '.Init GetReactState Done');
				// 06/23/2019 Paul.  Update last authenticated so that next request will not hit the server. 
				this.UpdateLastAuthenticated();
				//status = await IsAuthenticated('SplendidUI_Init');
				//console.log(this.constructor.name + '.Init IsAuthenticated', status);
			
				// 09/02/2019 Paul.  After authentication, change the theme to user selected value. 
				UpdateApplicationTheme(this.Credentials);
			}
			catch(error)
			{
				console.error(this.constructor.name + '.Init', error);
			}
			this.bIsInitializing = false;
			this.SplendidCache.IsInitialized = true;
			//console.log(this.constructor.name + '.Init Done');
			this.SplendidCache.VerifyReactState();
		}
		else if ( this.SplendidCache.IsInitialized )
		{
			console.log(this.constructor.name + '.Init Already Initialized');
		}
		else if ( this.bIsInitializing )
		{
			//console.log(this.constructor.name + '.Init is initializing');
		}
		return this.SplendidCache.IsInitialized;
	}

	public async UpdateStoreLastDate(): Promise<void>
	{
		try
		{
			if ( this.enableReactStateCache )
			{
				// https://github.com/jakearchibald/idb
				let db = await openDB(this.Credentials.RemoteServer, 1,
				{
					upgrade(db: any)
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
			console.error('Application_UpdateStoreLastDate', error);
		}
	}

	// 07/14/2021 Paul.  Use indexedDB to cache session state. 
	public async ClearStore(): Promise<void>
	{
		try
		{
			if ( this.enableReactStateCache )
			{
				// https://github.com/jakearchibald/idb
				let db = await openDB(this.Credentials.RemoteServer, 1,
				{
					upgrade(db: any)
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
			console.error('Application_ClearStore', error);
		}
	}

	public async IsAuthenticated(source: string): Promise<any>
	{
		// 05/29/2022 Paul.  TODO.  May want to re-enable this early check, but for now it always forces redirect to login. 
		//if ( !this.Credentials.ValidateCredentials )
		//{
		//	// 04/28/2019 Paul.  Ignore for now so we can test the request failure below. 
		//	//throw new Error('Invalid connection information.');
		//	return false;
		//}
		// 07/01/2017 Paul.  Cache IsAuthenticated for 1 second. 
		if ( this.lastIsAuthenticated > 0 )
		{
			let diff = new Date();
			diff.setTime(diff.getTime() - this.lastIsAuthenticated);
			var timeElapsed = diff.getTime();
			//console.log((new Date()).toISOString() + ' ' + 'IsAuthenticated ' + source, timeElapsed);
			if ( timeElapsed < 1000 )
			{
				return true;
			}
		}

		//console.log((new Date()).toISOString() + ' ' + 'IsAuthenticated ' + source, this.lastIsAuthenticated);
		try
		{
			let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/IsAuthenticated');
			if ( Sql.ToBoolean(json.d) )
			{
				//console.log((new Date()).toISOString() + ' ' + 'IsAuthenticated successful ' + source, this.lastIsAuthenticated);
				this.lastIsAuthenticated = (new Date()).getTime();
				if ( this.Credentials.sUSER_ID == '' )
				{
					// 05/07/2013 Paul.  Replace GetUserID and GetUserLanguage with GetUserProfile. 
					try
					{
						// 05/27/2019 Paul.  Moved GetUserProfile to SplendidUI_Init. 
						//let profile = await GetUserProfile();
						// 11/28/2011 Paul.  Reset after getting the language. 
						await this.Init('IsAuthenticated ' + source);
						//SplendidCache.VerifyReactState();
						return true;
					}
					catch(error)
					{
						this.lastIsAuthenticated = 0;
						//console.log((new Date()).toISOString() + ' ' + 'IsAuthenticated SplendidUI_Init ' + source, error);
						return false;
					}
				}
				else
				{
					// 07/14/2021 Paul.  Use indexedDB to cache session state. 
					// 10/30/2021 Paul.  Must wait for update to finish. 
					await this.UpdateStoreLastDate();
					return true;
				}
			}
			else
			{
				//console.warn((new Date()).toISOString() + ' ' + 'IsAuthenticated failed ' + source, this.lastIsAuthenticated);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + 'IsAuthenticated ' + source, error);
		}
		// 07/14/2021 Paul.  Use indexedDB to cache session state. 
		// 10/30/2021 Paul.  Must wait for clear to finish before reloading. 
		await this.ClearStore();
		return false;
	}

	public async GetUserID(): Promise<any>
	{
		try
		{
			let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/GetUserID');
			return json.d;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + 'GetUserID', error);
		}
		return null;
	}

	// 07/15/2021 Paul.  React Client needs to access the ASP.NET_SessionId. 
	public async GetUserSession(): Promise<any>
	{
		try
		{
			let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/GetUserSession');
			return json.d;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + 'GetUserSession', error);
		}
		return null;
	}

	public async Logout(): Promise<any>
	{
		// 07/01/2017 Paul.  Reset IsAuthenticated immediately upon login/logout. 
		this.lastIsAuthenticated = 0;

		if ( !this.Credentials.ValidateCredentials )
		{
			throw new Error('Invalid connection information.');
		}
		else
		{
			try
			{
				// 09/19/2020 Paul.  Provide events to start/stop SignalR.
				// 05/28/2022 Paul.  TODO.  Add support for SignalR. 
				//SignalRStore.Shutdown();
				let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/Logout');
				//console.log((new Date()).toISOString() + ' ' + 'Logout complete', json);
			}
			catch(error)
			{
				// 06/23/2019 Paul.  Ignore any error and just continue. 
				console.error((new Date()).toISOString() + ' ' + 'Logout', error);
			}
			// 07/14/2021 Paul.  Use indexedDB to cache session state. 
			// 10/30/2021 Paul.  Must wait for clear to finish before reloading. 
			await this.ClearStore();
			// 08/09/2018 Paul.  Setting to text value of null is wrong. 
			this.Credentials.SetUSER_ID('');
			this.Credentials.ClearStorage();
			this.SplendidCache.Reset();
			try
			{
				// 12/25/2018 Paul.  Logout should perform Azure or ADFS logout.
				// 05/28/2022 Paul.  TODO.  Add support for SignalR. 
				/*
				let oSingleSignOnContext = await this.SingleSignOnSettings();
				if ( oSingleSignOnContext != null && !Sql.IsEmptyString(oSingleSignOnContext.instance) )
				{
					let adalInstance = new AuthenticationContext(
					{
						instance             : oSingleSignOnContext.instance ,
						tenant               : oSingleSignOnContext.tenant   ,
						clientId             : oSingleSignOnContext.clientId ,
						endpoints            : oSingleSignOnContext.endpoints,
						redirectUri          : (window.location.origin + window.location.pathname),
						postLogoutRedirectUri: this.Credentials.RemoteServer,
					});
					adalInstance.logOut();
					return false;
				}
				*/
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
	public async Login(username: string, password: string): Promise<any>
	{
		var sBody = JSON.stringify({
			'UserName': username,
			'Password': password,
			'MobileClient': this.Credentials.bMOBILE_CLIENT,
			'Version': '6.0'
		});
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/Login', 'POST', 'application/json; charset=UTF-8', sBody);
		if ( json.d.length == 36 )
		{
			this.lastIsAuthenticated = 0;
			// 05/13/2018 Paul.  We will likely want to move the location where we save the this.Credentials. 
			// 02/26/2019 Paul.  We need to save the credentials before setting the profile as it resets everyting. 
			this.Credentials.SaveCredentials('CRM', username, password);
			//this.Credentials.SetUSER_ID(json.d);
			// 05/07/2013 Paul.  Replace GetUserLanguage with GetUserProfile. 
			// 05/27/2019 Paul.  Moved GetUserProfile to SplendidUI_Init. 
			//let profile = await GetUserProfile();
			//this.lastIsAuthenticated = (new Date()).getTime();
			// 09/09/2014 Paul.  Reset after getting the language. 
			// 05/24/2019 Paul.  Move init to caller. 
			//await SplendidUI_Init('LoginView.Login');
			//window.addEventListener("beforeunload", beforeUnloadListener);
			return this.Credentials.sUSER_ID;
		}
		else
		{
			throw new Error('Login should return Guid.');
		}
	}

	// 02/18/2020 Paul.  Allow React Client to forget password. 
	public async ForgotPassword(username: string, email: string): Promise<any>
	{
		var sBody = JSON.stringify({
			'UserName': username,
			'Email': email,
		});
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/ForgotPassword', 'POST', 'application/json; charset=UTF-8', sBody);
		return json.d;
	}

	public async AuthenticatedMethod(unused: any, source: string): Promise<number>
	{
		// 05/29/2022 Paul.  TODO.  May want to re-enable this early check, but for now it always forces redirect to login. 
		//if ( !this.Credentials.ValidateCredentials )
		//{
		//	//throw new Error('Invalid connection information.');
		//	return 0;
		//}
		//console.log((new Date()).toISOString() + ' ' + 'AuthenticatedMethod', source, props.location.pathname + props.location.search);
		// 06/23/2019 Paul.  IsAuthenticated will catch any errors and return simple true/false. 
		let bAuthenticated: boolean = await this.IsAuthenticated('AuthenticatedMethod ' + source);
		if ( bAuthenticated )
		{
			if ( !this.SplendidCache.IsInitialized )
			{
				//await SplendidUI_Init('AuthenticatedMethod ' + source);
				// 10/12/2019 Paul.  Include search query string. 
				this.router.navigateByUrl('/Reload' + window.location.pathname + window.location.search);
				return 2;
			}
			return 1;
		}
		else
		{
			let sAUTHENTICATION: string = this.Credentials.GetAUTHENTICATION();
			let sUSER_NAME     : string = this.Credentials.GetUSER_NAME()     ;
			let sPASSWORD      : string = this.Credentials.GetPASSWORD()      ;
			// 10/14/2011 Paul.  Make sure that we do not attempt to login if we do not have a password as it will eventually lock-out the user. 
			if ( sAUTHENTICATION == 'CRM' && !Sql.IsEmptyString(sUSER_NAME) && !Sql.IsEmptyString(sPASSWORD) )
			{
				try
				{
					let id = await this.Login(sUSER_NAME, sPASSWORD);
					// 08/30/2011 Paul.  Now may be a good time to run SplendidInit. 
					// 10/04/2011 Paul.  Return the user information for the Safari Extension. 
					// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
					// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
					// 02/28/2018 Paul.  When the session times-out and we re-authenticate, we need to load config, modules and global cache. 
					// 05/24/2019 Paul.  We are still having issues with rendering while loading, so use a separate view. 
					// await SplendidUI_Init('AuthenticatedMethod ' + source);
					// 10/12/2019 Paul.  Include search query string. 
					this.router.navigateByUrl('/Reload' + window.location.pathname + window.location.search);
					return -2;
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

	public async Version(): Promise<any>
	{
		// 04/29/2017 Paul.  Automatically offline if the server is not defined. 
		if ( this.Credentials.bMOBILE_CLIENT && Sql.IsEmptyString(this.Credentials.RemoteServer) )
		{
			throw new Error('Remote Server is not defined.');
		}
		else
		{
			let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/Version');
			return json.d;
		}
	}

	public async Edition(): Promise<any>
	{
		if ( this.Credentials.bMOBILE_CLIENT && Sql.IsEmptyString(this.Credentials.RemoteServer) )
		{
			throw new Error('Remote Server is not defined.');
		}
		else
		{
			let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/Edition');
			return json.d;
		}
	}


	// 04/30/2017 Paul.  Add support for single-sign-on. 
	public async SingleSignOnSettings(): Promise<SINGLE_SIGN_ON>
	{
		//console.log((new Date()).toISOString() + ' ' + 'SingleSignOnSettings', this.Credentials.RemoteServer);
		// 04/29/2017 Paul.  Automatically offline if the server is not defined. 
		if ( this.Credentials.bMOBILE_CLIENT && Sql.IsEmptyString(this.Credentials.RemoteServer) )
		{
			throw new Error('Remote Server is not defined.');
		}
		else
		{
			// 04/29/2017 Paul.  Use 2 second timeout for SingleSignOnSettings. 
			// 07/03/2017 Paul.  We must specify timeout function otherwise we get an uncaught canceled event. Increase to 8 seconds. 
			let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/SingleSignOnSettings', 'GET');
			return json.d;
		}
	}

	public LoginRedirect(history: any, sFrom: string)
	{
		console.log((new Date()).toISOString() + ' ' + 'LoginRedirect', sFrom);
		this.router.navigateByUrl('/login');
	}

	public async GetUserProfile(): Promise<any>
	{
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/GetUserProfile', 'POST', 'application/json; charset=UTF-8', null);
		return json.d;
	}

	// 10/09/2020 Paul.  The difference between GetUserProfile and GetMyUserProfile is that GetMyUserProfile gets all the data need in My Profile screen, but former just gets runtime data. 
	public async GetMyUserProfile(): Promise<any>
	{
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/GetMyUserProfile', 'GET');
		json.d.__sql = json.__sql;
		return json.d;
	}

}
