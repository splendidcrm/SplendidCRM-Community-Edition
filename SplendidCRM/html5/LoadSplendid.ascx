<%@ Control CodeBehind="LoadSplendid.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.html5.LoadSplendid" %>
<script runat="server">
/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
</script>
<script type="text/javascript">
function ClearSystemMessage()
{
	SplendidError.ClearError();
	SplendidError.ClearAlert();
}

function LoadSplendid()
{
	try
	{
		// 04/23/2013 Paul.  New approach to menu management. 
		sPRODUCT_TITLE    = 'SplendidCRM <%# Application["CONFIG.service_level"] %>';
		// 04/03/2018 Paul.  Allow proxy to so mask https. 
		// 04/23/2018 Paul.  Build in javascript to allow proxy handling. 
		sREMOTE_SERVER    = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port: '') + '<%# Sql.ToString(Application["rootURL"]) %>';
		// 06/29/2017 Paul.  AssemblyVersion is needed for HTML5 Dashboard. 
		sAssemblyVersion  = '<%# Sql.ToString(Application["SplendidVersion"]) %>';
		sIMAGE_SERVER     = '../';
		sPLATFORM_LAYOUT  = '';
		if ( isMobileDevice() )
		{
			sPLATFORM_LAYOUT  = '.Mobile';
			var divFooterCopyright = document.getElementById('divFooterCopyright');
			if ( divFooterCopyright != null )
				divFooterCopyright.style.display = 'none';
		}
		
		sAUTHENTICATION   = '<%# Security.IsWindowsAuthentication() || Security.IsAuthenticated() ? "Windows" : "CRM" %>';
		bWINDOWS_AUTH     =  <%# Security.IsWindowsAuthentication() ? "true" : "false" %>;
		bIS_OFFLINE       = false;
		// 10/16/2016 Paul.  Remove offline ability by treating like mobile client. 
		// 04/30/2017 Paul.  Mobile Client must be treated separately. 
		bMOBILE_CLIENT    = false;
		// 10/16/2016 Paul.  Remove offline ability by treating like mobile client. 
		bENABLE_OFFLINE   = false; // (window.XMLHttpRequest !== undefined);
		sUSER_ID          = '<%# Security.USER_ID   %>';
		sUSER_NAME        = '<%# Sql.EscapeJavaScript(Security.USER_NAME) %>';
		// 06/10/2016 Paul.  Set the full name. 
		sFULL_NAME        = '<%# Sql.EscapeJavaScript(Security.FULL_NAME) %>';
		sTEAM_ID          = '<%# Security.TEAM_ID   %>';
		sTEAM_NAME        = '<%# Sql.EscapeJavaScript(Security.TEAM_NAME) %>';
		sUSER_LANG        = '<%# L10n.NAME          %>';
		sUSER_DATE_FORMAT = '<%# Sql.EscapeJavaScript(Sql.ToString(Session["USER_SETTINGS/DATEFORMAT"   ])) %>';
		sUSER_TIME_FORMAT = '<%# Sql.EscapeJavaScript(Sql.ToString(Session["USER_SETTINGS/TIMEFORMAT"   ])) %>';
		// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
		// 06/18/2015 Paul.  THEME and not DEFAULT_THEME. 
		sUSER_THEME       = '<%# Sql.EscapeJavaScript(Sql.ToString(Session["USER_SETTINGS/THEME"        ])) %>';
		// 10/16/2016 Paul.  Add support for Arctic link. 
		if ( sUSER_THEME != 'Six' && sUSER_THEME != 'Atlantic' && sUSER_THEME != 'Seven' && sUSER_THEME != 'Arctic' )
			sUSER_THEME = 'Atlantic';
		sPASSWORD         = '';
		// 06/18/2015 Paul.  Change the style file based on the theme. 
		var lnkThemeStyle = document.getElementById('lnkThemeStyle');
		// 10/16/2016 Paul.  Add support for Arctic link. 
		if ( lnkThemeStyle != null && (sUSER_THEME == 'Six' || sUSER_THEME == 'Atlantic' || sUSER_THEME == 'Seven' || sUSER_THEME == 'Arctic') )
		{
			lnkThemeStyle.href = 'Themes/' + sUSER_THEME + '/style.css';
		}
		// 01/10/2017 Paul.  Add support for ADFS or Azure AD Single Sign on. 
		bADFS_SINGLE_SIGN_ON   = <%# Sql.ToBoolean(Application["CONFIG.ADFS.SingleSignOn.Enabled" ]) ? "true" : "false" %>;
		bAZURE_SINGLE_SIGN_ON  = <%# Sql.ToBoolean(Application["CONFIG.Azure.SingleSignOn.Enabled"]) ? "true" : "false" %>;
		if ( bADFS_SINGLE_SIGN_ON )
		{
			// https://technet.microsoft.com/en-us/windows-server-docs/identity/ad-fs/development/single-page-application-with-ad-fs
			adalInstance = new AuthenticationContext(
			{
				instance:    '<%# Sql.ToString(Application["CONFIG.ADFS.SingleSignOn.Authority"]) %>',
				tenant:      'adfs',
				clientId:    '<%# Sql.ToString(Application["CONFIG.ADFS.SingleSignOn.ClientId" ]) %>',
				postLogoutRedirectUri: window.location.origin
				//endpoints: { '<%# Sql.ToString(Application["CONFIG.ADFS.SingleSignOn.Realm"  ]) %>': '<%# Sql.ToString(Application["CONFIG.ADFS.SingleSignOn.Realm"]) %>' }
			});
		}
		else if ( bAZURE_SINGLE_SIGN_ON )
		{
			// https://hjnilsson.com/2016/07/20/authenticated-azure-cors-request-with-active-directory-and-adal-js/
			adalInstance = new AuthenticationContext(
			{
				instance: 'https://login.microsoftonline.com/',
				tenant:   '<%# Sql.ToString(Application["CONFIG.Azure.SingleSignOn.AadTenantDomain"]) %>',
				clientId: '<%# Sql.ToString(Application["CONFIG.Azure.SingleSignOn.AadClientId"    ]) %>',
				postLogoutRedirectUri: window.location.origin,
				endpoints: { '<%# Sql.ToString(Application["CONFIG.Azure.SingleSignOn.Realm"]) %>': '<%# Sql.ToString(Application["CONFIG.Azure.SingleSignOn.AadClientId"]) %>' }
			});
		}
		
		// 11/25/2014 Paul.  Add SignalR fields. 
		sUSER_EXTENSION      = '<%# Sql.EscapeJavaScript(Sql.ToString(Session["EXTENSION"   ])) %>';
		sUSER_FULL_NAME      = '<%# Sql.EscapeJavaScript(Sql.ToString(Session["FULL_NAME"   ])) %>';
		sUSER_PHONE_WORK     = '<%# Sql.EscapeJavaScript(Sql.ToString(Session["PHONE_WORK"  ])) %>';
		sUSER_SMS_OPT_IN     = '<%# Sql.EscapeJavaScript(Sql.ToString(Session["SMS_OPT_IN"  ])) %>';
		sUSER_PHONE_MOBILE   = '<%# Sql.EscapeJavaScript(Sql.ToString(Session["PHONE_MOBILE"])) %>';
		sUSER_TWITTER_TRACKS = '';
		sUSER_CHAT_CHANNELS  = '<%# SplendidCache.MyChatChannels() %>';
		// 09/09/2020 Paul.  Add PhoneBurner SignalR support. 
		sUSER_PHONE_BURNER_GROUP = '<%# (Security.IsAuthenticated() && Sql.ToBoolean(Application["CONFIG.PhoneBurner.Enabled"]) && !Sql.IsEmptyString(Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthAccessToken"])) ? Security.USER_ID.ToString() : String.Empty %>';
		
		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		sUSER_CurrencyDecimalDigits    = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyDecimalDigits     %>';
		sUSER_CurrencyDecimalSeparator = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyDecimalSeparator  %>';
		sUSER_CurrencyGroupSeparator   = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyGroupSeparator    %>';
		sUSER_CurrencyGroupSizes       = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyGroupSizes[0]     %>';
		sUSER_CurrencyNegativePattern  = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyNegativePattern   %>';
		sUSER_CurrencyPositivePattern  = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyPositivePattern   %>';
		sUSER_CurrencySymbol           = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencySymbol            %>';
		
		// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
		sPRIMARY_ROLE_NAME   = '<%# Sql.EscapeJavaScript(Security.PRIMARY_ROLE_NAME) %>';
		// 06/15/2019 Paul.  sPopupWindowOptions is used by the Dashboard Editor. 
		sPopupWindowOptions = '<%= SplendidCRM.Crm.Config.PopupWindowOptions() %>';
		
		try
		{
			// 11/26/2014 Paul.  The server stub does not account for the virtual directory, so update the URL. 
			// 09/28/2018 Paul.  SignalR may not be supported. 
			if ( $.connection !== undefined )
			{
				$.connection.hub.url = sREMOTE_SERVER + '/signalr';
				// 11/25/2014 Paul.  Needs to be started after the variables are setup. 
				SignalR_Connection_Start();
			}
		}
		catch(e)
		{
		}
		
		SplendidStorage.maxDatabase = <%# Sql.ToInteger(Application["CONFIG.html5.max_database"]) %>;
		cbNetworkStatusChanged = NetworkStatusChanged;
		arrUserContextMenu =
		[ { id: 'lnkHeaderSystemLog'      , text: '.LBL_SYSTEM_LOG'      , action: ShowSystemLog       }
		, { id: 'lnkHeaderSplendidStorage', text: '.LBL_SPLENDID_STORAGE', action: ShowSplendidStorage }
		, { id: 'lnkHeaderCacheAll'       , text: '.LBL_CACHE_ALL'       , action: CacheAllModules     }
		// 06/27/2017 Paul.  Add reload link. 
		, { id: 'lnkHeaderReload'         , text: '.LBL_RELOAD'          , action: Reload              }
		, { id: 'divHeader_lnkLogout'     , text: '.LBL_LOGOUT'          , action: null                }
		];
		
		Terminology_SetTerm(''     , 'NTC_LOGIN_MESSAGE'      , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".NTC_LOGIN_MESSAGE"          )) %>');
		Terminology_SetTerm(''     , 'LBL_ENABLE_OFFLINE'     , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_ENABLE_OFFLINE"         )) %>');
		Terminology_SetTerm(''     , 'LBL_ONLINE'             , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_ONLINE"                 )) %>');
		Terminology_SetTerm(''     , 'LBL_OFFLINE'            , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_OFFLINE"                )) %>');
		Terminology_SetTerm(''     , 'LBL_SEARCH_BUTTON_LABEL', '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_SEARCH_BUTTON_LABEL"    )) %>');
		Terminology_SetTerm(''     , 'LBL_CLEAR_BUTTON_LABEL' , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_CLEAR_BUTTON_LABEL"     )) %>');
		Terminology_SetTerm(''     , 'LBL_CACHE_SELECTED'     , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_CACHE_SELECTED"         )) %>');
		Terminology_SetTerm(''     , 'NTC_CACHE_CONFIRMATION' , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".NTC_CACHE_CONFIRMATION"     )) %>');
		Terminology_SetTerm('Users', 'LBL_USER_NAME'          , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], "Users.LBL_USER_NAME"         )) %>');
		Terminology_SetTerm('Users', 'LBL_PASSWORD'           , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], "Users.LBL_PASSWORD"          )) %>');
		Terminology_SetTerm('Users', 'LBL_LOGIN_BUTTON_LABEL' , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], "Users.LBL_LOGIN_BUTTON_LABEL")) %>');
		Terminology_SetTerm('Users', 'LBL_ERROR'              , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], "Users.LBL_ERROR"             )) %>');
		Terminology_SetTerm('Users', 'ERR_INVALID_PASSWORD'   , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], "Users.ERR_INVALID_PASSWORD"  )) %>');
		// 06/27/2017 Paul.  Add reload link. 
		Terminology_SetTerm(''     , 'LBL_RELOAD'             , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_RELOAD"                 )) %>');
		//Terminology_SetTerm(''     , 'LNK_ABOUT'              , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LNK_ABOUT"                  )) %>');
		
		// 06/20/2015 Paul.  Provide a way to go directly to the DetailView or EditView of a record. 
		sINIT_MODE   = getQuerystring('mode'  );
		sINIT_MODULE = getQuerystring('module');
		sINIT_ID     = getQuerystring('id'    );
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.SplendidStorage.Init(function(status, message)
		{
			bgPage.IsOnline(function(status, message)
			{
				var divHeader_divOnlineStatus = ctlActiveMenu.divOnlineStatus();
				if ( status == 1 )
				{
					// 09/28/2011 Paul.  Site is online. 
					if ( divHeader_divOnlineStatus != null )
						divHeader_divOnlineStatus.innerHTML = L10n.Term('.LBL_ONLINE');
					bIS_OFFLINE = false;
				}
				else if ( status == 0 )
				{
					// 09/28/2011 Paul.  Site is offline. 
					if ( divHeader_divOnlineStatus != null )
						divHeader_divOnlineStatus.innerHTML = L10n.Term('.LBL_OFFLINE');
					bIS_OFFLINE = true;
				}
				else if ( status < 0 )
				{
					SplendidError.SystemMessage(message);
					if ( divHeader_divOnlineStatus != null )
						divHeader_divOnlineStatus.innerHTML = L10n.Term('Users.LBL_ERROR');
					bIS_OFFLINE = true;
				}
				bgPage.IsAuthenticated(function(status, message)
				{
					try
					{
						if ( status == 1 )
						{
							var rowDefaultSearch = null;
							var sLastModuleTab = '';
							if ( window.localStorage )
								sLastModuleTab = localStorage['LastActiveModule'];
							else
								sLastModuleTab = getCookie('LastActiveModule');
							if ( !Sql.IsEmptyString(sLastModuleTab) )
								sSTARTUP_MODULE = sLastModuleTab;
							var sLayoutPanel  = 'divMainLayoutPanel';
							var sActionsPanel = 'divMainActionsPanel';
							SplendidUI_Init(sLayoutPanel, sActionsPanel, sSTARTUP_MODULE, rowDefaultSearch, function(status, message)
							{
								// 10/10/2011 Paul.  Once the globals have been loaded, we can update the header. 
								if ( status == 3 )
								{
									LoginViewUI_UpdateHeader(sLayoutPanel, sActionsPanel, true)
								}
								else if ( status == 1 )
								{
									SplendidError.SystemMessage('');
								}
								else
								{
									SplendidError.SystemMessage(message);
								}
							});
						}
						else if ( status == 0 )
						{
							ShowOptionsDialog();
						}
						else
						{
							SplendidError.SystemMessage(message);
						}
					}
					catch(e)
					{
						SplendidError.SystemError(e, 'default.html IsAuthenticated()');
					}
				});
			});
		});
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'LoadSplendid');
	}
}

window.onload = function()
{
	Terminology_SetTerm(''     , 'NTC_WELCOME'            , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".NTC_WELCOME"                )) %>');
	Terminology_SetTerm(''     , 'LBL_LOGOUT'             , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_LOGOUT"                 )) %>');
	Terminology_SetTerm(''     , 'LBL_SYSTEM_LOG'         , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_SYSTEM_LOG"             )) %>');
	Terminology_SetTerm(''     , 'LBL_CACHE_ALL'          , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_CACHE_ALL"              )) %>');
	Terminology_SetTerm(''     , 'LBL_SPLENDID_STORAGE'   , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_SPLENDID_STORAGE"       )) %>');
	Terminology_SetTerm(''     , 'LBL_ONLINE'             , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_ONLINE"                 )) %>');
	Terminology_SetTerm(''     , 'LBL_OFFLINE'            , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_OFFLINE"                )) %>');
	// 06/27/2017 Paul.  Add reload link. 
	Terminology_SetTerm(''     , 'LBL_RELOAD'             , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LBL_RELOAD"                 )) %>');
	Terminology_SetTerm(''     , 'LNK_ABOUT'              , '<%# Sql.EscapeJavaScript(L10N.Term(Application, Request["HTTP_ACCEPT_LANGUAGE"], ".LNK_ABOUT"                  )) %>');
	
	var sLayoutPanel  = 'divMainLayoutPanel';
	var sActionsPanel = 'divMainActionsPanel';
	sIMAGE_SERVER     = '../';
	ctlActiveMenu = new TabMenuUI_None(sLayoutPanel, sActionsPanel);
	ctlActiveMenu.RenderHeader();

	// 05/06/2013 Paul.  Return early when debugging, otherwise LoadSplendid will get called twice. 
	<%-- Sql.ToBoolean(Request["debug"]) ? "LoadSplendid(); return;" : String.Empty --%>
	// 10/16/2016 Paul.  Remove offline ability by treating like mobile client. 
	LoadSplendid();
	return;
	/*
	if ( window.applicationCache !== undefined )
	{
		try
		{
			var nManifestProgress = 1;
			
			window.applicationCache.addEventListener('cached', LoadSplendid, false);
			window.applicationCache.addEventListener('cached', function()
			{
				SplendidError.SystemMessage('manifest cached');
			}, false);
			
			window.applicationCache.addEventListener('noupdate', LoadSplendid, false);
			window.applicationCache.addEventListener('noupdate', function()
			{
				SplendidError.SystemMessage('manifest noupdate');
			}, false);
			
			window.applicationCache.addEventListener('obsolete', LoadSplendid, false);
			window.applicationCache.addEventListener('obsolete', function()
			{
				SplendidError.SystemMessage('manifest obsolete');
			}, false);
			
			window.applicationCache.addEventListener('checking', function()
			{
				SplendidError.SystemMessage('manifest checking');
			}, false);
			
			window.applicationCache.addEventListener('downloading', function()
			{
				SplendidError.SystemMessage('manifest downloading');
			}, false);
			
			window.applicationCache.addEventListener('progress', function()
			{
				SplendidError.SystemMessage('manifest progress ' + nManifestProgress);
				nManifestProgress++;
			}, false);
			
			window.applicationCache.addEventListener('error', LoadSplendid, false);
			window.applicationCache.addEventListener('error', function()
			{
				SplendidError.SystemMessage('manifest error');
			}, false);
			
			// 09/27/2011 Paul.  updateready does not always fire as document. 
			// https://developer.mozilla.org/en/Offline_resources_in_Firefox
			window.applicationCache.addEventListener('updateready', function(e)
			{
				SplendidError.SystemMessage('manifest update ready ');
				// 10/16/2011 Paul.  An easier alternative to swapCache() is just to reload the entire page at a time suitable for the user, using location.reload().
				// http://www.whatwg.org/specs/web-apps/current-work/#applicationcache
				//window.applicationCache.swapCache();
				//window.onload = LoadSplendid;
				// Even after swapping the cache the currently loaded page won't use it until it is reloaded, so force a reload so it is current.
				//window.location.reload(true);
				Reload();
			}, false);
		}
		catch(e)
		{
			alert('default.aspx onload ' + e.message);
		}
	}
	else
	{
		LoadSplendid();
	}
	*/
}
</script>
