/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
 
var sPRODUCT_TITLE  = 'SplendidCRM';
// 0621/2017 Paul.  Change startup module to Home. 
var sSTARTUP_MODULE = 'Home';
var oSingleSignOnContext = null;

function LoginViewUI_UpdateHeader(sLayoutPanel, sActionsPanel, bShow)
{
	try
	{
		if ( ctlActiveMenu == null )
			return;
		var divHeader_divAuthenticated   = ctlActiveMenu.divAuthenticated();
		var divHeader_spnWelcome         = ctlActiveMenu.spnWelcome();
		var divHeader_spnUserName        = ctlActiveMenu.spnUserName();
		var divHeader_spnLogout          = ctlActiveMenu.spnLogout();
		var divHeader_lnkLogout          = ctlActiveMenu.lnkLogout();
		// 08/22/2014 Paul.  Add SyncNow for offline client. 
		var divHeader_spnSyncNow         = ctlActiveMenu.spnSyncNow();
		var divHeader_lnkSyncNow         = ctlActiveMenu.lnkSyncNow();
		var divHeader_divOnlineStatus    = ctlActiveMenu.divOnlineStatus();
		var divHeader_divOfflineCache    = ctlActiveMenu.divOfflineCache();
		var divHeader_divSplendidStorage = ctlActiveMenu.divSplendidStorage();
		var lnkHeaderCacheAll            = ctlActiveMenu.lnkCacheAll();
		var lnkHeaderSystemLog           = ctlActiveMenu.lnkSystemLog();
		var lnkHeaderSplendidStorage     = ctlActiveMenu.lnkSplendidStorage();
		
		var bgPage = chrome.extension.getBackgroundPage();
		if ( lnkHeaderCacheAll          != null ) lnkHeaderCacheAll.innerHTML              = L10n.Term('.LBL_CACHE_ALL'       );
		if ( lnkHeaderSystemLog         != null ) lnkHeaderSystemLog.innerHTML             = L10n.Term('.LBL_SYSTEM_LOG'      );
		if ( lnkHeaderSplendidStorage   != null ) lnkHeaderSplendidStorage.innerHTML       = L10n.Term('.LBL_SPLENDID_STORAGE');
		if ( divHeader_divAuthenticated != null ) divHeader_divAuthenticated.style.display = (bShow ? 'inline'                  : 'none');
		if ( divHeader_spnWelcome       != null ) divHeader_spnWelcome.innerHTML           = (bShow ? L10n.Term('.NTC_WELCOME') : '');
		if ( divHeader_spnUserName      != null ) divHeader_spnUserName.innerHTML          = (bShow ? (sUSER_NAME + ' ' + sTEAM_NAME) : '');
		if ( divHeader_spnLogout        != null ) divHeader_spnLogout.style.display        = (bWINDOWS_AUTH ? 'none' : 'inline');
		if ( divHeader_divOnlineStatus  != null ) divHeader_divOnlineStatus.innerHTML      =  bgPage.GetIsOffline() ? L10n.Term('.LBL_OFFLINE') : L10n.Term('.LBL_ONLINE');
		if ( divHeader_lnkLogout        != null )
		{
			divHeader_lnkLogout.style.display = (bWINDOWS_AUTH ? 'none' : 'block');
			divHeader_lnkLogout.innerHTML     = (bShow ? L10n.Term('.LBL_LOGOUT' ) : '');
			divHeader_lnkLogout.onclick = function()
			{
				LoginViewUI_PageCommand(sLayoutPanel, sActionsPanel, 'Logout', null, null);
			};
		}
		// 08/22/2014 Paul.  Add SyncNow for offline client. 
		// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
		if ( divHeader_spnSyncNow       != null )
			divHeader_spnSyncNow.style.display = (bShow && bREMOTE_ENABLED && !bMOBILE_CLIENT ? 'block' : 'none');
		if ( divHeader_lnkSyncNow       != null )
		{
			divHeader_lnkSyncNow.style.display = (bShow && bREMOTE_ENABLED && !bMOBILE_CLIENT ? 'block' : 'none');
			divHeader_lnkSyncNow.innerHTML     = (bShow && bREMOTE_ENABLED && !bMOBILE_CLIENT ? L10n.Term('Offline.LNK_OFFLINE_DASHBOARD' ) : '');
			divHeader_lnkSyncNow.onclick = function()
			{
				ShowOfflineDashboard();
			};
		}
		if ( divHeader_divSplendidStorage != null )
		{
			// 10/25/2012 Paul.  Don't display the storage buttons unless caching is enabled. 
			divHeader_divSplendidStorage.style.display = (bShow && bLIST_VIEW_ENABLE_SELECTION ? 'inline' : 'none');
		}
		
		if ( divHeader_divOnlineStatus != null && bgPage.SplendidStorage !== undefined && bgPage.SplendidStorage.db != null )
		{
			divHeader_divOnlineStatus.innerHTML += ' Web SQL';
		}
		
		if ( divHeader_divOfflineCache != null )
		{
			if ( divHeader_divOfflineCache.childNodes != null )
			{
				while ( divHeader_divOfflineCache.childNodes.length > 0 )
				{
					divHeader_divOfflineCache.removeChild(divHeader_divOfflineCache.firstChild);
				}
			}
			divHeader_divOfflineCache.style.display = 'none';
			// 10/19/2011 Paul.  IE6 does not support localStorage. 
			// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
			if ( window.localStorage && localStorage['OFFLINE_CACHE'] != null )
			{
				var arrOFFLINE_CACHE = JSON.parse(localStorage['OFFLINE_CACHE']);
				//alert(dumpObj(arrOFFLINE_CACHE, 'arrOFFLINE_CACHE'));
				// 10/07/2011 Paul.  arrOFFLINE_CACHE.length is not valid. 
				var nOFFLINE_CACHE_length = 0;
				for ( var key in arrOFFLINE_CACHE )
				{
					nOFFLINE_CACHE_length++;
				}
				
				divHeader_divOfflineCache.style.display = (bShow && nOFFLINE_CACHE_length > 0) ? 'inline' : 'none';
				
				var divSubmit = document.createElement('div');
				divHeader_divOfflineCache.appendChild(divSubmit);
				var btnSubmit = document.createElement('input');
				btnSubmit.type      = 'submit';
				btnSubmit.value     = L10n.Term('.LBL_SUBMIT_BUTTON_LABEL');
				btnSubmit.title     = L10n.Term('.LBL_SUBMIT_BUTTON_LABEL');
				btnSubmit.className = 'button';
				btnSubmit.onclick   = function()
				{
					var oEditViewUI = new EditViewUI();
					oEditViewUI.SubmitOffline(sLayoutPanel, sActionsPanel, 'Save');
				}
				divSubmit.appendChild(btnSubmit);
				
				// 03/16/2014 Paul.  Add hidden buttons for Save Duplicate and Save Concurrency. 
				var btnSubmit_SaveDuplicate = document.createElement('input');
				btnSubmit_SaveDuplicate.type          = 'submit';
				btnSubmit_SaveDuplicate.id            = 'btnSubmit_SaveDuplicate';
				btnSubmit_SaveDuplicate.value         = L10n.Term('.LBL_SAVE_DUPLICATE_LABEL');
				btnSubmit_SaveDuplicate.title         = L10n.Term('.LBL_SAVE_DUPLICATE_LABEL');
				btnSubmit_SaveDuplicate.className     = 'button';
				btnSubmit_SaveDuplicate.style.display = 'none';
				btnSubmit_SaveDuplicate.onclick   = function()
				{
					var oEditViewUI = new EditViewUI();
					oEditViewUI.SubmitOffline(sLayoutPanel, sActionsPanel, 'SaveDuplicate');
				}
				divSubmit.appendChild(btnSubmit_SaveDuplicate);
				
				var btnSubmit_SaveConcurrency = document.createElement('input');
				btnSubmit_SaveConcurrency.type          = 'submit';
				btnSubmit_SaveConcurrency.id            = 'btnSubmit_SaveConcurrency';
				btnSubmit_SaveConcurrency.value         = L10n.Term('.LBL_SAVE_CONCURRENCY_LABEL');
				btnSubmit_SaveConcurrency.title         = L10n.Term('.LBL_SAVE_CONCURRENCY_LABEL');
				btnSubmit_SaveConcurrency.className     = 'button';
				btnSubmit_SaveConcurrency.style.display = 'none';
				btnSubmit_SaveConcurrency.onclick   = function()
				{
					var oEditViewUI = new EditViewUI();
					oEditViewUI.SubmitOffline(sLayoutPanel, sActionsPanel, 'SaveConcurrency');
				}
				divSubmit.appendChild(btnSubmit_SaveConcurrency);
				divSubmit.style.display = (bShow && !bgPage.GetIsOffline() && nOFFLINE_CACHE_length > 0) ? 'inline' : 'none';
				
				for ( var key in arrOFFLINE_CACHE )
				{
					var oCached = arrOFFLINE_CACHE[key];
					var divItem = document.createElement('div');
					divHeader_divOfflineCache.appendChild(divItem);
					
					var sModuleLabel = oCached.MODULE_NAME;
					// 10/28/2012 Paul.  The module might be a relationship name. 
					if ( !StartsWith(oCached.MODULE_NAME, 'vw') )
					{
						sModuleLabel = L10n.ListTerm('moduleList', oCached.MODULE_NAME);
						sModuleLabel = Crm.Modules.SingularModuleName(sModuleLabel);
					}
					
					var aView = document.createElement('a');
					divItem.appendChild(aView);
					aView.href = '#';
					aView.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID)
					{
						var oDetailViewUI = new DetailViewUI();
						// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
						oDetailViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, function(status, message)
						{
							if ( status == 1 )
							{
								SplendidError.SystemMessage('');
							}
							else
							{
								SplendidError.SystemMessage(message);
							}
						}, this);
					}, sLayoutPanel, sActionsPanel, oCached.MODULE_NAME, oCached.ID);
					
					/*
					var imgView = document.createElement('img');
					aView.appendChild(imgView);
					imgView.align             = 'absmiddle';
					imgView.style.height      = '16px';
					imgView.style.width       = '16px';
					imgView.style.borderWidth = '0px';
					imgView.src               = sIMAGE_SERVER + 'App_Themes/Six/images/view_inline.gif';
					imgView.alt               = L10n.Term('.LNK_VIEW');
					imgView.style.padding     = '2px';
					imgView.style.border      = 'none';
					*/

					var spnItem = document.createElement('span');
					aView.appendChild(spnItem);
					spnItem.innerHTML = sModuleLabel + ': ' + oCached.NAME;
					spnItem.style.padding = '2px';
				}
			}
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'LoginViewUI_UpdateHeader');
	}
}

function LoginViewUI_ClearModuleLists(bClearAll, callback)
{
	var arrKeys = new Array();
	var bgPage = chrome.extension.getBackgroundPage();
	bgPage.SplendidStorage.foreach(function(status, key, value)
	{
		if ( status == 1 )
		{
			// 11/28/2011 Paul.  Remove module lists, but not the default. 
			// 09/11/2012 Paul.  Remove items. 
			if ( key.indexOf('Rest.svc/GetModuleList?') > 0 || key.indexOf('Rest.svc/GetModuleItem?') > 0 )
			{
				arrKeys.push(key);
			}
			// 03/10/2013 Paul.  On dev systems, multiple virtual directories will save their data to a single localStorage. 
			// This is causing an out-of-memory error. 
			else if ( StartsWith(key, 'http') && (bClearAll || !StartsWith(key, sREMOTE_SERVER)) )
			{
				arrKeys.push(key);
			}
		}
		else if ( status == 0 )
		{
			//if ( arrKeys.length == 0 )
			//	SplendidError.SystemLog('Nothing to remove from cache');
			while ( arrKeys.length > 0 )
			{
				var key = arrKeys.pop();
				SplendidStorage.removeItem(key);
				SplendidError.SystemLog('Removed item from cache: ' + key);
			}
			if ( callback )
			{
				callback(0, '');
			}
		}
	});
}

function LoginViewUI_NormalizeRemoteServer(sREMOTE_SERVER)
{
	sREMOTE_SERVER = Trim(sREMOTE_SERVER);
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
	if ( !EndsWith(sREMOTE_SERVER, '/') )
		sREMOTE_SERVER += '/';
	// 12/11/2014 Paul.  Prepend http:// if not provided. 
	if ( !StartsWith(sREMOTE_SERVER.toLocaleLowerCase(), 'http://') && !StartsWith(sREMOTE_SERVER.toLocaleLowerCase(), 'https://') )
		sREMOTE_SERVER = 'http://' + sREMOTE_SERVER;
	return sREMOTE_SERVER;
}

function LoginViewUI_PageCommand(sLayoutPanel, sActionsPanel, sCommandName, sCommandArguments, cbLoginComplete)
{
	try
	{
		if ( sCommandName == 'Login' )
		{
			var txtREMOTE_SERVER  = document.getElementById(sLayoutPanel + '_ctlLoginView_txtREMOTE_SERVER' );
			var txtUSER_NAME      = document.getElementById(sLayoutPanel + '_ctlLoginView_txtUSER_NAME'     );
			var txtPASSWORD       = document.getElementById(sLayoutPanel + '_ctlLoginView_txtPASSWORD'      );
			var chkENABLE_OFFLINE = document.getElementById(sLayoutPanel + '_ctlLoginView_chkENABLE_OFFLINE');
			if ( txtUSER_NAME != null )
				sUSER_NAME = txtUSER_NAME.value;
			if ( txtPASSWORD != null )
				sPASSWORD  = txtPASSWORD.value;
			// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
			if ( bMOBILE_CLIENT && txtREMOTE_SERVER != null )
			{
				txtREMOTE_SERVER.value = LoginViewUI_NormalizeRemoteServer(txtREMOTE_SERVER.value);
				sREMOTE_SERVER = txtREMOTE_SERVER.value;
				sIMAGE_SERVER  = txtREMOTE_SERVER.value;
			}

			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.Login(function(status, message)
			{
				var spnError = document.getElementById(sLayoutPanel + '_ctlLoginView_lblError');
				if ( status == 0 )
				{
					// 09/30/2011 Paul.  If there is no response, check against the stored values. 
					// 10/19/2011 Paul.  IE6 does not support localStorage. 
					// 11/27/2011 Paul.  The USER_NAME is not case-significant, so don't require it here either. 
					// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
					// 10/21/2012 Paul.  We have removed the Enable Offline checkbox because it is always enabled. 
					if ( (chkENABLE_OFFLINE == null || chkENABLE_OFFLINE.checked) && window.localStorage && Sql.ToString(localStorage['USER_NAME']).toLowerCase() == sUSER_NAME.toLowerCase() && localStorage['USER_HASH'] == Sha1.hash(sPASSWORD) )
					{
						sUSER_ID          = localStorage['USER_ID'         ];
						sUSER_NAME        = localStorage['USER_NAME'       ];
						sFULL_NAME        = localStorage['FULL_NAME'       ];
						// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
						sPICTURE          = localStorage['PICTURE'         ];
						sTEAM_ID          = localStorage['TEAM_ID'         ];
						sTEAM_NAME        = localStorage['TEAM_NAME'       ];
						sUSER_LANG        = localStorage['USER_LANG'       ];
						// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
						sUSER_THEME       = localStorage['USER_THEME'      ];
						sUSER_DATE_FORMAT = localStorage['USER_DATE_FORMAT'];
						sUSER_TIME_FORMAT = localStorage['USER_TIME_FORMAT'];
						sUSER_CURRENCY_ID = localStorage['USER_CURRENCY_ID'];
						sUSER_TIMEZONE_ID = localStorage['USER_TIMEZONE_ID'];
						// 12/01/2014 Paul.  Add SignalR fields. 
						sUSER_EXTENSION      = Sql.ToString(localStorage['USER_EXTENSION'     ]);
						sUSER_FULL_NAME      = Sql.ToString(localStorage['USER_FULL_NAME'     ]);
						sUSER_PHONE_WORK     = Sql.ToString(localStorage['USER_PHONE_WORK'    ]);
						sUSER_SMS_OPT_IN     = Sql.ToString(localStorage['USER_SMS_OPT_IN'    ]);
						sUSER_PHONE_MOBILE   = Sql.ToString(localStorage['USER_PHONE_MOBILE'  ]);
						sUSER_TWITTER_TRACKS = Sql.ToString(localStorage['USER_TWITTER_TRACKS']);
						sUSER_CHAT_CHANNELS  = Sql.ToString(localStorage['USER_CHAT_CHANNELS' ]);
						// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
						sUSER_CurrencyDecimalDigits    = Sql.ToString(localStorage['USER_CurrencyDecimalDigits'   ]);
						sUSER_CurrencyDecimalSeparator = Sql.ToString(localStorage['USER_CurrencyDecimalSeparator']);
						sUSER_CurrencyGroupSeparator   = Sql.ToString(localStorage['USER_CurrencyGroupSeparator'  ]);
						sUSER_CurrencyGroupSizes       = Sql.ToString(localStorage['USER_CurrencyGroupSizes'      ]);
						sUSER_CurrencyNegativePattern  = Sql.ToString(localStorage['USER_CurrencyNegativePattern' ]);
						sUSER_CurrencyPositivePattern  = Sql.ToString(localStorage['USER_CurrencyPositivePattern' ]);
						sUSER_CurrencySymbol           = Sql.ToString(localStorage['USER_CurrencySymbol'          ]);
						// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
						sPRIMARY_ROLE_NAME   = Sql.ToString(localStorage['PRIMARY_ROLE_NAME'  ]);
					}
					else
					{
						message = L10n.Term('Users.ERR_INVALID_PASSWORD');
						status  = -1;
					}
				}
				if ( status == 0 || status == 1 )
				{
					spnError.innerHTML = 'Login successful';
					// 09/30/2011 Paul.  Don't fetch UI files if we are offline. 
					// 11/27/2011 Paul.  bENABLE_OFFLINE is a global flag, so we cannot turn off just for UI. 
					// bENABLE_OFFLINE must remain enabled in order to retrieved cached UI data when attempting to use offline. 
					// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
					
					// 10/16/2012 Paul.  Always load the global layout cache if it has not been loaded. 
					//bENABLE_OFFLINE = window.localStorage ? chkENABLE_OFFLINE.checked : false;
					// 10/12/2011 Paul.  If we are online, we should take this time to clear local storage.  
					// The concern is that we will be caching all searches and we need a way to clear this before the storage becomes full. 
					// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
					if ( status == 1 && window.localStorage )
					{
						// 10/12/2011 Paul.  Make sure not to clear offline cached data. 
						// 10/12/2011 Paul.  For now, lets just clear module lists. 
						// 11/28/2011 Paul.  We must clear the lists, otherwise searches will eventually exhaust available memory. 
						LoginViewUI_ClearModuleLists();
						// 04/16/2017 Paul.  Allow the global cache to be reloaded after successful login. 
						bGLOBAL_LAYOUT_CACHE = false;
					}
					
					// 09/09/2014 Paul.  GetUserProfile is already called in Login, so don't call again. 
					//bgPage.GetUserProfile(function(status, message)
					//{
						// 10/19/2011 Paul.  IE6 does not support localStorage. 
						// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
						if ( status == 1 && window.localStorage )
						{
							localStorage['USER_ID'         ] = sUSER_ID         ;
							// 01/07/2018 Paul.  Change to use the same value provided so that a customer can customize the USER_NAME. 
							// 12/20/2018 Paul.  txtUSER_NAME will be null when using ADFS. 
							if ( txtUSER_NAME != null )
								localStorage['USER_NAME'       ] = txtUSER_NAME.value;
							else
								localStorage['USER_NAME'       ] = sUSER_NAME       ;
							localStorage['FULL_NAME'       ] = sFULL_NAME       ;
							// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
							localStorage['PICTURE'         ] = sPICTURE         ;
							localStorage['TEAM_ID'         ] = sTEAM_ID         ;
							localStorage['TEAM_NAME'       ] = sTEAM_NAME       ;
							localStorage['USER_HASH'       ] = Sha1.hash(sPASSWORD);
							localStorage['USER_LANG'       ] = sUSER_LANG       ;
							// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
							localStorage['USER_THEME'      ] = sUSER_THEME      ;
							localStorage['USER_DATE_FORMAT'] = sUSER_DATE_FORMAT;
							localStorage['USER_TIME_FORMAT'] = sUSER_TIME_FORMAT;
							localStorage['USER_CURRENCY_ID'] = sUSER_CURRENCY_ID;
							localStorage['USER_TIMEZONE_ID'] = sUSER_TIMEZONE_ID;
							// 12/01/2014 Paul.  Add SignalR fields. 
							localStorage['USER_EXTENSION'     ] = sUSER_EXTENSION     ;
							localStorage['USER_FULL_NAME'     ] = sUSER_FULL_NAME     ;
							localStorage['USER_PHONE_WORK'    ] = sUSER_PHONE_WORK    ;
							localStorage['USER_SMS_OPT_IN'    ] = sUSER_SMS_OPT_IN    ;
							localStorage['USER_PHONE_MOBILE'  ] = sUSER_PHONE_MOBILE  ;
							localStorage['USER_TWITTER_TRACKS'] = sUSER_TWITTER_TRACKS;
							localStorage['USER_CHAT_CHANNELS' ] = sUSER_CHAT_CHANNELS ;
							// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
							if ( bMOBILE_CLIENT )
							{
								localStorage['REMOTE_SERVER'  ] = sREMOTE_SERVER;
							}
							// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
							localStorage['USER_CurrencyDecimalDigits'   ] = sUSER_CurrencyDecimalDigits   ;
							localStorage['USER_CurrencyDecimalSeparator'] = sUSER_CurrencyDecimalSeparator;
							localStorage['USER_CurrencyGroupSeparator'  ] = sUSER_CurrencyGroupSeparator  ;
							localStorage['USER_CurrencyGroupSizes'      ] = sUSER_CurrencyGroupSizes      ;
							localStorage['USER_CurrencyNegativePattern' ] = sUSER_CurrencyNegativePattern ;
							localStorage['USER_CurrencyPositivePattern' ] = sUSER_CurrencyPositivePattern ;
							localStorage['USER_CurrencySymbol'          ] = sUSER_CurrencySymbol          ;
							// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
							localStorage['PRIMARY_ROLE_NAME'  ] = sPRIMARY_ROLE_NAME  ;
						}
						// 09/30/2011 Paul.  Clear the password for security reasons. 
						// 11/27/2011 Paul.  Clearing the password prevents automatic re-authentication when the connection is restored. 
						//sPASSWORD = '';
						// 11/28/2011 Paul.  We need to save the user name and password so that we can re-authenticate when the connection is restored. 
						// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
						if ( window.sessionStorage )
						{
							sessionStorage['PASSWORD'        ] = sPASSWORD        ;
							sessionStorage['USER_ID'         ] = sUSER_ID         ;
							sessionStorage['USER_NAME'       ] = sUSER_NAME       ;
							sessionStorage['FULL_NAME'       ] = sFULL_NAME       ;
							// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
							sessionStorage['PICTURE'         ] = sPICTURE         ;
							sessionStorage['TEAM_ID'         ] = sTEAM_ID         ;
							sessionStorage['TEAM_NAME'       ] = sTEAM_NAME       ;
							sessionStorage['USER_LANG'       ] = sUSER_LANG       ;
							// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
							sessionStorage['USER_THEME'      ] = sUSER_THEME      ;
							sessionStorage['USER_DATE_FORMAT'] = sUSER_DATE_FORMAT;
							sessionStorage['USER_TIME_FORMAT'] = sUSER_TIME_FORMAT;
							sessionStorage['USER_CURRENCY_ID'] = sUSER_CURRENCY_ID;
							sessionStorage['USER_TIMEZONE_ID'] = sUSER_TIMEZONE_ID;
							// 12/01/2014 Paul.  Add SignalR fields. 
							sessionStorage['USER_EXTENSION'     ] = sUSER_EXTENSION     ;
							sessionStorage['USER_FULL_NAME'     ] = sUSER_FULL_NAME     ;
							sessionStorage['USER_PHONE_WORK'    ] = sUSER_PHONE_WORK    ;
							sessionStorage['USER_SMS_OPT_IN'    ] = sUSER_SMS_OPT_IN    ;
							sessionStorage['USER_PHONE_MOBILE'  ] = sUSER_PHONE_MOBILE  ;
							sessionStorage['USER_TWITTER_TRACKS'] = sUSER_TWITTER_TRACKS;
							sessionStorage['USER_CHAT_CHANNELS' ] = sUSER_CHAT_CHANNELS ;
							// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
							if ( bMOBILE_CLIENT )
							{
								sessionStorage['REMOTE_SERVER'] = sREMOTE_SERVER;
							}
							// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
							sessionStorage['USER_CurrencyDecimalDigits'   ] = sUSER_CurrencyDecimalDigits   ;
							sessionStorage['USER_CurrencyDecimalSeparator'] = sUSER_CurrencyDecimalSeparator;
							sessionStorage['USER_CurrencyGroupSeparator'  ] = sUSER_CurrencyGroupSeparator  ;
							sessionStorage['USER_CurrencyGroupSizes'      ] = sUSER_CurrencyGroupSizes      ;
							sessionStorage['USER_CurrencyNegativePattern' ] = sUSER_CurrencyNegativePattern ;
							sessionStorage['USER_CurrencyPositivePattern' ] = sUSER_CurrencyPositivePattern ;
							sessionStorage['USER_CurrencySymbol'          ] = sUSER_CurrencySymbol          ;
							// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
							sessionStorage['PRIMARY_ROLE_NAME'  ] = sPRIMARY_ROLE_NAME  ;
						}
						
						// 03/19/2016 Paul.  OfficeAddin will only use the Seven theme. 
						if ( sPLATFORM_LAYOUT == '.OfficeAddin' )
							sUSER_THEME = 'Seven';
						// 06/18/2015 Paul.  Change the style file based on the theme. 
						var lnkThemeStyle = document.getElementById('lnkThemeStyle');
						if ( lnkThemeStyle != null && (sUSER_THEME == 'Six' || sUSER_THEME == 'Atlantic' || sUSER_THEME == 'Seven') )
						{
							// 03/19/2016 Paul.  OfficeAddin requires full path. 
							lnkThemeStyle.href = sREMOTE_SERVER + 'html5/Themes/' + sUSER_THEME + '/style.css';
						}
						// 08/24/2014 Paul.  Remember the last successful login location and repeat on startup. 
						localStorage['LastLoginRemote'] = false;
						// 12/10/2014 Paul.  After successful login, clear the form so that the user will see a change on a slow device. 
						LoginViewUI_Clear(sLayoutPanel, sActionsPanel, function(status, message)
						{
						});
						
						// 12/07/2014 Paul.  Load last active module after login. 
						var sLastModuleTab = '';
						if ( window.localStorage )
							sLastModuleTab = localStorage['LastActiveModule'];
						else
							sLastModuleTab = getCookie('LastActiveModule');
						if ( !Sql.IsEmptyString(sLastModuleTab) )
							sSTARTUP_MODULE = sLastModuleTab;
						var rowDefaultSearch = null;
						SplendidUI_Init(sLayoutPanel, sActionsPanel, sSTARTUP_MODULE, rowDefaultSearch, function(status, message)
						{
							if ( status == 1 )
							{
								LoginViewUI_UpdateHeader(sLayoutPanel, sActionsPanel, true);
								// 10/16/2012 Paul.  Always load the global layout cache if it has not been loaded. 
								//if ( bENABLE_OFFLINE )
								{
									SplendidUI_Cache(function(status, message)
									{
										if ( status == 2 )
										{
											SplendidError.SystemMessage(message);
										}
									});
								}
								if ( cbLoginComplete != null )
									cbLoginComplete(1, null);
								SplendidError.SystemMessage('');
							}
							else
							{
								SplendidError.SystemMessage(message);
							}
						});
						
						// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
						// 12/02/2014 Paul.  We need to start the connection when the page is loaded on the Mobile Client. 
						/*
						if ( status == 1 && bMOBILE_CLIENT )
						{
							try
							{
								// 11/26/2014 Paul.  The server stub does not account for the virtual directory, so update the URL. 
								$.connection.hub.url = sREMOTE_SERVER + '/signalr';
								// 11/25/2014 Paul.  Needs to be started after the variables are setup. 
								SignalR_Connection_Start();
							}
							catch(e)
							{
							}
						}
						*/
					//});
				}
				else
				{
					spnError.innerHTML = message;
				}
			});
		}
		else if ( sCommandName == 'Logout' )
		{
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.Logout(function(status, message)
			{
				try
				{
					// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
					if ( bMOBILE_CLIENT )
					{
						try
						{
							SignalR_Connection_Stop();
						}
						catch(e)
						{
						}
					}
					ClearSystemMessage();
					SplendidError.ClearAllErrors();
					// 11/28/2011 Paul.  We need to save the user name and password so that we can re-authenticate when the connection is restored. 
					if ( window.XMLHttpRequest )
					{
						sessionStorage.clear();
					}
					sUSER_NAME  = '';
					sUSER_ID    = '';
					sUSER_THEME = '';
					// 10/15/2011 Paul.  sTabMenuCtl is a div tag now so that we can do more with the panel. 
					// 04/23/2013 Paul.  New approach to menu management. 
					var sLayoutPanel  = 'divMainLayoutPanel';
					var sActionsPanel = 'divMainActionsPanel';
					ctlActiveMenu = new TabMenuUI_None(sLayoutPanel, sActionsPanel);
					// 03/19/2016 Paul.  Office Addin will only use the Seven theme. 
					if ( sPLATFORM_LAYOUT == '.OfficeAddin' )
					{
						sUSER_THEME = 'Seven';
						ctlActiveMenu = new TabMenuUI_OfficeAddin(sLayoutPanel, sActionsPanel);
					}
					ctlActiveMenu.RenderHeader();
					SplendidUI_Clear(sLayoutPanel, sActionsPanel);
					LoginViewUI_Load(sLayoutPanel, sActionsPanel
					, function(status, message)  // cbLoginComplete
					{
						if ( status == 1 )
						{
							// 08/26/2014 Paul.  This is not the best place to set the last login value. 
							//localStorage['LastLoginRemote'] = false;
							SplendidError.SystemMessage('');
						}
					}
					, function(status, message)  // callback
					{
						if ( status == 1 )
						{
							SplendidError.SystemMessage('');
						}
						else
						{
							SplendidError.SystemMessage(message);
						}
					});
				}
				catch(e)
				{
					SplendidError.SystemError(e, 'LoginViewUI_PageCommand Logout()');
				}
			});
			// 12/25/2018 Paul.  Logout should perform Azure or ADFS logout. 
			// 12/25/2018 Paul.  Not sure why we cannot place inside the logout return, but it does not seem to return.  Could be an issue with the ASP.NET Session ID. 
			if ( (bADFS_SINGLE_SIGN_ON || bAZURE_SINGLE_SIGN_ON) && adalInstance != null )
			{
				adalInstance.config.postLogoutRedirectUri = window.location.href;
				adalInstance.logOut();
			}
		}
		else
		{
			SplendidError.SystemMessage('LoginViewUI_PageCommand: Unknown command ' + sCommandName);
		}
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'LoginViewUI_PageCommand');
	}
}

function LoginViewUI_Clear(sLayoutPanel, sActionsPanel, callback)
{
	try
	{
		var divMainLayoutPanel = document.getElementById(sLayoutPanel);
		if ( divMainLayoutPanel != null && divMainLayoutPanel.childNodes != null )
		{
			while ( divMainLayoutPanel.childNodes.length > 0 )
			{
				divMainLayoutPanel.removeChild(divMainLayoutPanel.firstChild);
			}
		}
		var divMainActionsPanel = document.getElementById(sActionsPanel);
		if ( divMainActionsPanel != null && divMainActionsPanel.childNodes != null )
		{
			while ( divMainActionsPanel.childNodes.length > 0 )
			{
				divMainActionsPanel.removeChild(divMainActionsPanel.firstChild);
			}
		}
		LoginViewUI_UpdateHeader(sLayoutPanel, sActionsPanel, false);
		callback(1, null);
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'LoginViewUI_Clear'));
	}
}

// 01/10/2017 Paul.  Add support for ADFS or Azure AD Single Sign on. 
// 04/16/2017 Paul.  Use Bootstrap for responsive design.
function LoginViewUI_LoadView(sLayoutPanel, sActionsPanel, bActiveDirectory, cbLoginComplete, callback)
{
	try
	{
		var divMainLayoutPanel = document.getElementById(sLayoutPanel);
		var rowMain = document.createElement('div');
		rowMain.className = 'row';
		divMainLayoutPanel.appendChild(rowMain);
		var colMain = document.createElement('div');
		colMain.className = 'col-lg-6 col-lg-offset-3 col-md-8 col-md-offset-2 col-sm-10 col-sm-offset-1';
		rowMain.appendChild(colMain);
		var x_panel = document.createElement('div');
		x_panel.className = 'x_panel';
		colMain.appendChild(x_panel);

		var x_title = document.createElement('div');
		// 04/29/2017 Paul.  Title is truncated for no reason on small screens. 
		//x_title.className = 'x_title';
		x_panel.appendChild(x_title);
		var h2 = document.createElement('h2');
		x_title.appendChild(h2);
		var txt = document.createTextNode(sPRODUCT_TITLE);
		h2.appendChild(txt);
		var fix = document.createElement('div');
		fix.className = 'clearfix';
		x_title.appendChild(fix);

		var x_content = document.createElement('div');
		x_content.className = 'x_content';
		x_panel.appendChild(x_content);

		var x_form = document.createElement('div');
		x_form.className = 'form-horizontal form-label-left';
		x_content.appendChild(x_form);

		var group = document.createElement('div');
		group.className = 'form-group';
		x_form.appendChild(group);

		//var br = document.createElement('br');
		//x_content.appendChild(br);
		var divInstructions = document.createElement('div');
		divInstructions.className = 'col-md-10 col-sm-10 col-xs-12 col-md-offset-2';
		group.appendChild(divInstructions)
		txt = document.createTextNode(L10n.Term('.NTC_LOGIN_MESSAGE'));
		divInstructions.appendChild(txt);

		var lblError = document.createElement('div');
		lblError.className = 'col-md-10 col-sm-10 col-xs-12 col-md-offset-2 error';
		group.appendChild(lblError);
		lblError.id        = sLayoutPanel + '_ctlLoginView_lblError';

		// 01/10/2017 Paul.  Add support for ADFS or Azure AD Single Sign on. 
		if ( !bActiveDirectory || bMOBILE_CLIENT )
		{
			// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
			// 01/02/2017 Paul.  Only show when using mobile devices, not on HTML5 Offline Client. 
			// 04/30/2017 Paul.  The Remote Server textbox needs display for mobile and offline clients. 
			if ( bMOBILE_CLIENT || bREMOTE_ENABLED || Sql.IsEmptyString(sREMOTE_SERVER) )
			{
				group = document.createElement('div');
				group.className = 'form-group';
				x_form.appendChild(group);
				var label = document.createElement('label');
				label.className = 'control-label col-md-3 col-sm-3 col-xs-12';
				label.for       =  sLayoutPanel + '_ctlLoginView_txtREMOTE_SERVER';
				group.appendChild(label);
				txt = document.createTextNode(L10n.Term('Offline.LBL_REMOTE_SERVER'));
				label.appendChild(txt);

				var divInput = document.createElement('div');
				divInput.className = 'col-md-9 col-sm-6 col-xs-12';
				group.appendChild(divInput);
				var txtREMOTE_SERVER = document.createElement('input');
				txtREMOTE_SERVER.id        = sLayoutPanel + '_ctlLoginView_txtREMOTE_SERVER';
				txtREMOTE_SERVER.type      = 'text';
				txtREMOTE_SERVER.className = 'form-control col-md-7 col-xs-12';
				divInput.appendChild(txtREMOTE_SERVER);
				txtREMOTE_SERVER.onkeypress = function(e)
				{
					return RegisterEnterKeyPress(e, sLayoutPanel + '_ctlLoginView_btnLogin');
				};
				if ( window.localStorage && localStorage['REMOTE_SERVER'] !== undefined )
				{
					txtREMOTE_SERVER.value = localStorage['REMOTE_SERVER'];
					var bgPage = chrome.extension.getBackgroundPage();
					// 05/02/2017 Paul.  Don't repeat settings get operation if we already have adal instance. 
					if ( !Sql.IsEmptyString(txtREMOTE_SERVER.value) && (adalInstance == null || adalInstance.REMOTE_SERVER !== txtREMOTE_SERVER.value) )
					{
						// 05/07/2017 Paul.  The trailing slash is required, so make sure to normalize the server URL. 
						sREMOTE_SERVER = LoginViewUI_NormalizeRemoteServer(txtREMOTE_SERVER.value);
						// cordova plugin add cordova-plugin-ms-adal
						bgPage.SingleSignOnSettings(function(status, message)
						{
							if ( status == 1 )
							{
								if ( bMOBILE_CLIENT )
								{
									localStorage['REMOTE_SERVER'] = sREMOTE_SERVER;
								}
								oSingleSignOnContext = message;
								if ( !Sql.IsEmptyString(oSingleSignOnContext.instance) )
								{
									SplendidError.SystemLog('Active Directory Tenant: ' + oSingleSignOnContext.tenant);
									// Active Directory Authentication Library (ADAL) plugin for Apache Cordova apps
									// https://github.com/AzureAD/azure-activedirectory-library-for-cordova
									try
									{
										if ( bMOBILE_CLIENT )
										{
											var authority = oSingleSignOnContext.instance;
											if ( !EndsWith(authority, '/') )
												authority += '/';
											authority += oSingleSignOnContext.tenant;
											if ( oSingleSignOnContext.tenant == 'adfs' )
												authority += '/ls';
											Microsoft.ADAL.AuthenticationContext.createAsync(authority, (oSingleSignOnContext.tenant != 'adfs'))
											.then(function (context)
											{
												adalInstance = context;
												adalInstance.REMOTE_SERVER = sREMOTE_SERVER;
												console.log("Created authentication context for authority URL: " + context.authority);
												if ( !bADFS_SINGLE_SIGN_ON && !bAZURE_SINGLE_SIGN_ON )
												{
													bADFS_SINGLE_SIGN_ON  = oSingleSignOnContext.tenant == 'adfs';
													bAZURE_SINGLE_SIGN_ON = !bADFS_SINGLE_SIGN_ON;
													LoginViewUI_Load(sLayoutPanel, sActionsPanel, cbLoginComplete, callback);
												}
											},
											function(message)
											{
												$('#' + sLayoutPanel + '_ctlLoginView_lblError').text(message);
												SplendidError.SystemMessage(message);
											});
										}
										else
										{
											adalInstance = new AuthenticationContext(
											{
												instance : oSingleSignOnContext.instance,
												tenant   : oSingleSignOnContext.tenant,
												clientId : oSingleSignOnContext.clientId,
												endpoints: oSingleSignOnContext.endpoints,
												postLogoutRedirectUri: window.location.origin
											});
											// 04/30/2017 Paul.  If Single-Sign-On is enabled, then we need to redraw the login view. 
											if ( !bADFS_SINGLE_SIGN_ON && !bAZURE_SINGLE_SIGN_ON )
											{
												bADFS_SINGLE_SIGN_ON  = oSingleSignOnContext.tenant == 'adfs';
												bAZURE_SINGLE_SIGN_ON = !bADFS_SINGLE_SIGN_ON;
												LoginViewUI_Load(sLayoutPanel, sActionsPanel, cbLoginComplete, callback);
											}
										}
									}
									catch(e)
									{
										SplendidError.SystemError(e, 'LoginViewUI_LoadView Single-Sign-On');
									}
								}
								else
								{
									if ( bADFS_SINGLE_SIGN_ON || bAZURE_SINGLE_SIGN_ON )
									{
										bADFS_SINGLE_SIGN_ON  = false;
										bAZURE_SINGLE_SIGN_ON = false;
										LoginViewUI_Load(sLayoutPanel, sActionsPanel, cbLoginComplete, callback);
									}
								}
							}
							else
							{
								SplendidError.SystemMessage(message);
							}
						}, this);
					}
				}
				// 04/30/2017 Paul.  If the server changes, then we need to recheck the single-sign-on settings. 
				txtREMOTE_SERVER.onblur = function()
				{
					var bgPage = chrome.extension.getBackgroundPage();
					var txtREMOTE_SERVER = document.getElementById(sLayoutPanel + '_ctlLoginView_txtREMOTE_SERVER');
					// 05/02/2017 Paul.  Don't repeat settings get operation if we already have adal instance. 
					if ( txtREMOTE_SERVER != null && !Sql.IsEmptyString(txtREMOTE_SERVER.value) && (adalInstance == null || adalInstance.REMOTE_SERVER !== txtREMOTE_SERVER.value) )
					{
						// 05/07/2017 Paul.  The trailing slash is required, so make sure to normalize the server URL. 
						sREMOTE_SERVER = LoginViewUI_NormalizeRemoteServer(txtREMOTE_SERVER.value);
						// 06/21/2017 Paul.  Clear previous error. 
						$('#' + sLayoutPanel + '_ctlLoginView_lblError').text('');
						bgPage.SingleSignOnSettings(function(status, message)
						{
							if ( status == 1 )
							{
								if ( bMOBILE_CLIENT )
								{
									localStorage['REMOTE_SERVER'] = sREMOTE_SERVER;
								}
								oSingleSignOnContext = message;
								if ( !Sql.IsEmptyString(oSingleSignOnContext.instance) )
								{
									SplendidError.SystemLog('Active Directory Tenant: ' + oSingleSignOnContext.tenant);
									try
									{
										if ( bMOBILE_CLIENT )
										{
											var authority = oSingleSignOnContext.instance;
											if ( !EndsWith(authority, '/') )
												authority += '/';
											authority += oSingleSignOnContext.tenant;
											if ( oSingleSignOnContext.tenant == 'adfs' )
												authority += '/ls';
											Microsoft.ADAL.AuthenticationContext.createAsync(authority, (oSingleSignOnContext.tenant != 'adfs'))
											.then(function (context)
											{
												adalInstance = context;
												adalInstance.REMOTE_SERVER = sREMOTE_SERVER;
												console.log("Created authentication context for authority URL: " + context.authority);
												if ( !bADFS_SINGLE_SIGN_ON && !bAZURE_SINGLE_SIGN_ON )
												{
													bADFS_SINGLE_SIGN_ON  = oSingleSignOnContext.tenant == 'adfs';
													bAZURE_SINGLE_SIGN_ON = !bADFS_SINGLE_SIGN_ON;
													LoginViewUI_Load(sLayoutPanel, sActionsPanel, cbLoginComplete, callback);
												}
											},
											function(message)
											{
												$('#' + sLayoutPanel + '_ctlLoginView_lblError').text(message);
												SplendidError.SystemMessage(message);
											});
										}
										else
										{
											adalInstance = new AuthenticationContext(
											{
												instance : oSingleSignOnContext.instance,
												tenant   : oSingleSignOnContext.tenant,
												clientId : oSingleSignOnContext.clientId,
												endpoints: oSingleSignOnContext.endpoints,
												postLogoutRedirectUri: window.location.origin
											});
											// 04/30/2017 Paul.  If Single-Sign-On is enabled, then we need to redraw the login view. 
											if ( !bADFS_SINGLE_SIGN_ON && !bAZURE_SINGLE_SIGN_ON )
											{
												bADFS_SINGLE_SIGN_ON  = oSingleSignOnContext.tenant == 'adfs';
												bAZURE_SINGLE_SIGN_ON = !bADFS_SINGLE_SIGN_ON;
												LoginViewUI_Load(sLayoutPanel, sActionsPanel, cbLoginComplete, callback);
											}
										}
									}
									catch(e)
									{
										$('#' + sLayoutPanel + '_ctlLoginView_lblError').text(e.message);
										SplendidError.SystemError(e, 'LoginViewUI_LoadView Single-Sign-On');
									}
								}
								else
								{
									if ( bADFS_SINGLE_SIGN_ON || bAZURE_SINGLE_SIGN_ON )
									{
										bADFS_SINGLE_SIGN_ON  = false;
										bAZURE_SINGLE_SIGN_ON = false;
										LoginViewUI_Load(sLayoutPanel, sActionsPanel, cbLoginComplete, callback);
									}
								}
							}
							else
							{
								$('#' + sLayoutPanel + '_ctlLoginView_lblError').text(message);
								SplendidError.SystemMessage(message);
							}
						});
					}
				};
			}
		}
		if ( !bActiveDirectory )
		{
			group = document.createElement('div');
			group.className = 'form-group';
			x_form.appendChild(group);
			var label = document.createElement('label');
			label.className = 'control-label col-md-3 col-sm-3 col-xs-12';
			label.for       =  sLayoutPanel + '_ctlLoginView_txtUSER_NAME';
			group.appendChild(label);
			txt = document.createTextNode(L10n.Term('Users.LBL_USER_NAME'));
			label.appendChild(txt);

			var divInput = document.createElement('div');
			divInput.className = 'col-md-9 col-sm-6 col-xs-12';
			group.appendChild(divInput);
			var txtUSER_NAME = document.createElement('input');
			txtUSER_NAME.id        = sLayoutPanel + '_ctlLoginView_txtUSER_NAME';
			txtUSER_NAME.type      = 'text';
			txtUSER_NAME.className = 'form-control col-md-7 col-xs-12';
			divInput.appendChild(txtUSER_NAME);
			txtUSER_NAME.onkeypress = function(e)
			{
				return RegisterEnterKeyPress(e, sLayoutPanel + '_ctlLoginView_btnLogin');
			};
			// 11/29/2011 Paul.  Make logins easier by recalling the last login. 
			// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
			if ( window.localStorage && localStorage['USER_NAME'] !== undefined )
				txtUSER_NAME.value = localStorage['USER_NAME'];

			group = document.createElement('div');
			group.className = 'form-group';
			x_form.appendChild(group);
			var label = document.createElement('label');
			label.className = 'control-label col-md-3 col-sm-3 col-xs-12';
			label.for       =  sLayoutPanel + '_ctlLoginView_txtPASSWORD';
			group.appendChild(label);
			txt = document.createTextNode(L10n.Term('Users.LBL_PASSWORD'));
			label.appendChild(txt);

			var divInput = document.createElement('div');
			divInput.className = 'col-md-9 col-sm-6 col-xs-12';
			group.appendChild(divInput);
			var txtPASSWORD = document.createElement('input');
			txtPASSWORD.id        = sLayoutPanel + '_ctlLoginView_txtPASSWORD';
			txtPASSWORD.type      = 'password';
			txtPASSWORD.className = 'form-control col-md-7 col-xs-12';
			divInput.appendChild(txtPASSWORD);
			txtPASSWORD.onkeypress = function(e)
			{
				return RegisterEnterKeyPress(e, sLayoutPanel + '_ctlLoginView_btnLogin');
			};
			var divSolidLine = document.createElement('div');
			divSolidLine.className = 'ln_solid';
			x_form.appendChild(divSolidLine);
		}
		
		group = document.createElement('div');
		group.className = 'form-group';
		x_form.appendChild(group);
		var divButtons = document.createElement('div');
		divButtons.className = 'col-md-6 col-sm-6 col-xs-12 col-md-offset-2';
		group.appendChild(divButtons);
		
		var btnLogin = document.createElement('button');
		divButtons.appendChild(btnLogin);
		btnLogin.id        = sLayoutPanel + '_ctlLoginView_btnLogin';
		btnLogin.type      = 'submit';
		btnLogin.className = 'btn btn-primary';
		txt = document.createTextNode(L10n.Term('Users.LBL_LOGIN_BUTTON_LABEL'));
		btnLogin.appendChild(txt);
		btnLogin.onclick   = function()
		{
			$('#' + sLayoutPanel + '_ctlLoginView_lblError').text('');
			// 01/10/2017 Paul.  Add support for ADFS or Azure AD Single Sign on. 
			if ( !bActiveDirectory )
			{
				LoginViewUI_PageCommand(sLayoutPanel, sActionsPanel, 'Login', null, cbLoginComplete);
			}
			else if ( bMOBILE_CLIENT && adalInstance != null )
			{
				try
				{
					var txtREMOTE_SERVER = document.getElementById(sLayoutPanel + '_ctlLoginView_txtREMOTE_SERVER' );
					// 05/03/2017 Paul.  As we are using the MobileClientId to validate the token, we must also use it as the resourceUrl when acquiring the token. 
					// 05/03/2017 Paul.  Instead of validating against the resource, validate against the clientId as it is easier. 
					var resourceUrl      = oSingleSignOnContext.mobileId;
					// 05/03/2017 Paul.  ADFS still requires a Uri. 
					if ( oSingleSignOnContext.tenant == 'adfs' )
						resourceUrl = LoginViewUI_NormalizeRemoteServer(txtREMOTE_SERVER.value);
					var appId            = oSingleSignOnContext.mobileId;
					var redirectUrl      = oSingleSignOnContext.mobileRedirectUrl;
					if ( Sql.IsEmptyString(redirectUrl) )
						redirectUrl = 'http://SplendidMobile';
					SplendidError.SystemLog('ADAL Resource URL: ' + resourceUrl);
					
					adalInstance.acquireTokenAsync(resourceUrl, appId, redirectUrl)
					.then(function(authResult)
					{
						console.log('Acquired token successfully: ' + authResult);
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
						if ( authResult.userInfo.identityProvider == 'live.com' )
							sUSER_NAME = authResult.userInfo.uniqueId.replace('live.com#', '');
						else
							sUSER_NAME = authResult.userInfo.uniqueId.split('\\')[1];
						// 05/03/2017 Paul.  The accessToken includes a signature to validate on the server. 
						sPASSWORD  = authResult.accessToken;
						LoginViewUI_PageCommand(sLayoutPanel, sActionsPanel, 'Login', null, cbLoginComplete);
					},
					function(message)
					{
						$('#' + sLayoutPanel + '_ctlLoginView_lblError').text(message);
					});
				}
				catch(e)
				{
					SplendidError.SystemError(e, 'LoginViewUI_LoadView acquireTokenAsync()');
				}
			}
			else if ( adalInstance != null )
			{
				adalInstance.login();
			}
			else
			{
				SplendidError.SystemMessage('ADAL Instance/Context is null.');
			}
		};
		// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
		if ( bREMOTE_ENABLED && !bMOBILE_CLIENT )
		{
			var aWorkOnline = document.createElement('a');
			aWorkOnline.href = '#';
			aWorkOnline.style.paddingLeft = '6px';
			// 12/31/2014 Paul.  Firefox does not like innerText. Use createTextNode. 
			txt = document.createTextNode(L10n.Term('Offline.LNK_WORK_ONLINE'));
			aWorkOnline.appendChild(txt);
			aWorkOnline.onclick = BindArguments(function(sLayoutPanel, sActionsPanel, cbLoginComplete, callback)
			{
				ClientLoginViewUI_Load(sLayoutPanel, sActionsPanel, cbLoginComplete, callback)
			}, sLayoutPanel, sActionsPanel, cbLoginComplete, callback);
			divButtons.appendChild(aWorkOnline);
		}

		// <div id="divFooterCopyright" align="center" class="copyRight">
		var divFooterCopyright = document.getElementById('divFooterCopyright');
		// 12/10/2014 Paul.  No copyright on a mobile device. 
		if ( divFooterCopyright == null && !bIsMobile )
		{
			divFooterCopyright = document.createElement('footer');
			divFooterCopyright.id        = 'divFooterCopyright';
			divFooterCopyright.align     = 'center';
			divFooterCopyright.className = 'pull-right';
			divMainLayoutPanel.appendChild(divFooterCopyright);

			// Copyright &copy; 2005-2013 <a id="lnkSplendidCRM" href="http://www.splendidcrm.com" target="_blank" class="copyRightLink">SplendidCRM Software, Inc.</a> All Rights Reserved.<br />
			txt = document.createTextNode('Copyright (C) 2005-2017 ');
			divFooterCopyright.appendChild(txt);

			var lnkSplendidCRM = document.createElement('a');
			lnkSplendidCRM.id        = 'lnkSplendidCRM';
			lnkSplendidCRM.className = 'copyRightLink';
			lnkSplendidCRM.href      = 'http://www.splendidcrm.com';
			// 12/31/2014 Paul.  Firefox does not like innerText. Use createTextNode. 
			lnkSplendidCRM.appendChild(document.createTextNode('SplendidCRM Software, Inc.'));
			lnkSplendidCRM.target    = '_blank';
			divFooterCopyright.appendChild(lnkSplendidCRM);
			txt = document.createTextNode(' All Rights Reserved.');
			divFooterCopyright.appendChild(txt);
		}

		// 01/10/2017 Paul.  Add support for ADFS or Azure AD Single Sign on. 
		if ( !bActiveDirectory )
		{
			if ( txtUSER_NAME.value.length > 0 )
				txtPASSWORD.focus();
			else
				txtUSER_NAME.focus();
		}
		else
		{
			btnLogin.focus();
		}
		callback(1, null);
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'LoginViewUI_LoadView'));
	}
}

function LoginViewUI_Load(sLayoutPanel, sActionsPanel, cbLoginComplete, callback)
{
	try
	{
		LoginViewUI_Clear(sLayoutPanel, sActionsPanel, function(status, message)
		{
			if ( status == 1 )
			{
				// 01/10/2017 Paul.  Add support for ADFS or Azure AD Single Sign on. 
				if ( Sql.ToBoolean(bADFS_SINGLE_SIGN_ON) || Sql.ToBoolean(bAZURE_SINGLE_SIGN_ON) )
				{
					// 05/01/2017 Paul.  adalInstance is also used on MobileClient. 
					// Azure will redirect and we land back here after Single-Sign-On. 
					if ( !bMOBILE_CLIENT && adalInstance.getCachedUser() )
					{
						LoginViewUI_LoadView(sLayoutPanel, sActionsPanel, true, cbLoginComplete, function (status, message)
						{
							if ( status == 1 )
							{
								var user = adalInstance.getCachedUser();
								// user.userName
								// user.profile.email
								// user.profile.family_name
								// user.profile.given_name
								// user.profile.name
								//alert('azure cached user ' + dumpObj(user));
								// 12/20/2018 Paul.  Try and extract from unique name first. 
								if ( user.profile.unique_name !== undefined )
									sUSER_NAME = user.profile.unique_name;
								else
									sUSER_NAME = user.userName;
								if ( sUSER_NAME.indexOf('@') > 0 )
									sUSER_NAME = sUSER_NAME.split('@')[0];
								else if ( sUSER_NAME.indexOf('\\') )
									sUSER_NAME = sUSER_NAME.substring(sUSER_NAME.indexOf('\\') + 1);
								sPASSWORD  = adalInstance._getItem(adalInstance.CONSTANTS.STORAGE.IDTOKEN);
								// 12/20/2018 Paul.  The token will be null when logging out. 
								if ( sPASSWORD != null )
									LoginViewUI_PageCommand(sLayoutPanel, sActionsPanel, 'Login', null, cbLoginComplete);
							}
							else
							{
								callback(status, message);
							}
						});
					}
					else if ( !bMOBILE_CLIENT && adalInstance.isCallback(window.location.hash) )
					{
						adalInstance.handleWindowCallback();
						//var idtoken = adalInstance._getItem(adalInstance.CONSTANTS.STORAGE.IDTOKEN);
						//alert('azure callback ' + idtoken);
					}
					else
					{
						LoginViewUI_LoadView(sLayoutPanel, sActionsPanel, true, cbLoginComplete, function (status, message)
						{
							if ( status == 1 )
							{
								callback(1, '');
							}
							else
							{
								callback(status, message);
							}
						});
					}
				}
				else
				{
					LoginViewUI_LoadView(sLayoutPanel, sActionsPanel, false, cbLoginComplete, function (status, message)
					{
						if ( status == 1 )
						{
							callback(1, '');
						}
						else
						{
							callback(status, message);
						}
					});
				}
			}
			else
			{
				callback(status, message);
			}
		});
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'LoginViewUI_Load'));
	}
}

