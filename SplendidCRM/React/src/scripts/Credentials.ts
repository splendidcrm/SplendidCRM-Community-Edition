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
import { observable }        from 'mobx'                       ;
import moment                from 'moment'                     ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                   from '../scripts/Sql'             ;
import L10n                  from '../scripts/L10n'            ;
import Aes                   from '../scripts/aes'             ;
import SplendidCache         from '../scripts/SplendidCache'   ;
import { Crm_Config }        from '../scripts/Crm'             ;
import { FromJsonDate }      from '../scripts/Formatting'      ;

function IsMobileClient()
{
	let bMOBILE_CLIENT: boolean = false;
	if ( window.cordova && window.cordova.platformId )
	{
		bMOBILE_CLIENT = (window.cordova.platformId == 'android' || window.cordova.platformId == 'ios' || window.location.pathname == '/android_asset/www/index.html' );
	}
	//console.log((new Date()).toISOString() + ' IsMobileClient', bMOBILE_CLIENT);
	return bMOBILE_CLIENT;
}

class CredentialsStore
{
	bMOBILE_CLIENT                 = IsMobileClient();
	sREMOTE_SERVER                 = '';
	// 07/01/2023 Paul.  ASP.NET Core will not have /React in the base. 
	sREACT_BASE                    = '';
	sAUTHENTICATION                = '';
	sUSER_NAME                     = '';
	sEXCHANGE_ALIAS                = '';
	// 01/22/2021 Paul.  Exchange Email is used to control some access. 
	sEXCHANGE_EMAIL                = '';
	sPASSWORD                      = '';
	sUSER_ID                       = '';
	sUSER_LANG                     = 'en-US';
	@observable
	bIsAuthenticated               = false;
	// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
	@observable
	sUSER_THEME                    = null;
	// 05/24/2018 Paul.  Change to moment format. 
	// http://momentjs.com/docs/#/displaying/
	// https://docs.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings
	sUSER_DATE_FORMAT              = 'MM/DD/YYYY';
	sUSER_TIME_FORMAT              = 'h:mm a';
	// 09/19/2024 Paul.. Guids are returned from api in lower case. 
	sUSER_CURRENCY_ID              = 'e340202e-6291-4071-b327-a34cb4df239b';
	sUSER_TIMEZONE_ID              = 'bfa61af7-26ed-4020-a0c1-39a15e4e9e0a';
	// 10/28/2021 Paul.  This is our indicator to redirect to User Wizard. 
	sORIGINAL_TIMEZONE_ID          = null;
	sFULL_NAME                     = '';
	// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
	sPICTURE                       = '';
	sTEAM_ID                       = '';
	sTEAM_NAME                     = '';
	TEAM_TREE                      = null;
	bIS_OFFLINE                    = false;
	@observable
	ADMIN_MODE                     = false;
	bENABLE_OFFLINE                = false;
	cbNetworkStatusChanged         = null;
	// 11/25/2014 Paul.  Add SignalR fields. 
	sUSER_EXTENSION                = '';
	sUSER_FULL_NAME                = '';
	sUSER_PHONE_WORK               = '';
	sUSER_SMS_OPT_IN               = '';
	sUSER_PHONE_MOBILE             = '';
	sUSER_TWITTER_TRACKS           = '';
	sUSER_CHAT_CHANNELS            = '';
	// 09/17/2020 Paul.  Add PhoneBurner SignalR support. 
	dtPHONEBURNER_TOKEN_EXPIRES_AT = null;
	// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
	sUSER_CurrencyDecimalDigits    = '2';
	sUSER_CurrencyDecimalSeparator = '.';
	sUSER_CurrencyGroupSeparator   = ',';
	sUSER_CurrencyGroupSizes       = '3';
	sUSER_CurrencyNegativePattern  = '0';
	sUSER_CurrencyPositivePattern  = '0';
	sUSER_CurrencySymbol           = '$';
	// 10/16/2021 Paul.  Add support for user currency. 
	bUSER_CurrencyUSDollars        = true;
	dUSER_CurrencyCONVERSION_RATE  = 1.0;
	// 01/22/2021 Paul.  Customizations may be based on the PRIMARY_ROLE_ID and not the name. 
	sPRIMARY_ROLE_ID               = '';
	// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
	sPRIMARY_ROLE_NAME             = '';
	// 03/02/2019 Paul.  We need to know if they are an admin or admin delegate. 
	bIS_ADMIN                      = false;
	bIS_ADMIN_DELEGATE             = false;
	// 05/07/2019 Paul.  Maintain SearchView state. 
	bSAVE_QUERY                    = false;
	// 12/20/2019 Paul.  Observe the sidebar width. 
	// 03/29/2021 Paul.  Allow display of impersonation state. 
	USER_IMPERSONATION             = false;
	showLeftCol                    = true;
	showTeamTree                   = false;
	@observable
	viewMode                       = null;
	// 08/28/2020 Paul.  Android is having trouble loading image from file system, so use base64. 
	SplendidCRM_Logo = 'data:image/gif;base64,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';

	Reset()
	{
		// 08/01/2019 Paul.  The remote server never gets reset. 
		//this.sREMOTE_SERVER                 = '';
		this.sAUTHENTICATION                = '';
		this.sUSER_NAME                     = '';
		this.sPASSWORD                      = '';
		this.sUSER_ID                       = '';
		this.sEXCHANGE_ALIAS                = '';
		// 01/22/2021 Paul.  Exchange Email is used to control some access. 
		this.sEXCHANGE_EMAIL                = '';
		this.bIsAuthenticated               = false;
		this.sUSER_LANG                     = 'en-US';
		// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
		this.sUSER_THEME                    = null;
		// 05/24/2018 Paul.  Change to moment format. 
		// http://momentjs.com/docs/#/displaying/
		// https://docs.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings
		this.sUSER_DATE_FORMAT              = 'MM/DD/YYYY';
		this.sUSER_TIME_FORMAT              = 'h:mm a';
		// 09/19/2024 Paul.. Guids are returned from api in lower case. 
		this.sUSER_CURRENCY_ID              = 'e340202e-6291-4071-b327-a34cb4df239b';
		this.sUSER_TIMEZONE_ID              = 'bfa61af7-26ed-4020-a0c1-39a15e4e9e0a';
		// 10/28/2021 Paul.  This is our indicator to redirect to User Wizard. 
		this.sORIGINAL_TIMEZONE_ID          = null;
		this.sFULL_NAME                     = '';
		// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
		this.sPICTURE                       = '';
		this.sTEAM_ID                       = '';
		this.sTEAM_NAME                     = '';
		this.TEAM_TREE                      = null;
		this.bIS_OFFLINE                    = false;
		this.ADMIN_MODE                     = false;
		this.bENABLE_OFFLINE                = false;
		this.cbNetworkStatusChanged         = null;
		// 11/25/2014 Paul.  Add SignalR fields. 
		this.sUSER_EXTENSION                = '';
		this.sUSER_FULL_NAME                = '';
		this.sUSER_PHONE_WORK               = '';
		this.sUSER_SMS_OPT_IN               = '';
		this.sUSER_PHONE_MOBILE             = '';
		this.sUSER_TWITTER_TRACKS           = '';
		this.sUSER_CHAT_CHANNELS            = '';
		// 09/17/2020 Paul.  Add PhoneBurner SignalR support. 
		this.dtPHONEBURNER_TOKEN_EXPIRES_AT = null;
		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		this.sUSER_CurrencyDecimalDigits    = '2';
		this.sUSER_CurrencyDecimalSeparator = '.';
		this.sUSER_CurrencyGroupSeparator   = ',';
		this.sUSER_CurrencyGroupSizes       = '3';
		this.sUSER_CurrencyNegativePattern  = '0';
		this.sUSER_CurrencyPositivePattern  = '0';
		this.sUSER_CurrencySymbol           = '$';
		// 10/16/2021 Paul.  Add support for user currency. 
		this.bUSER_CurrencyUSDollars        = true;
		this.dUSER_CurrencyCONVERSION_RATE  = 1.0;
		// 01/22/2021 Paul.  Customizations may be based on the PRIMARY_ROLE_ID and not the name. 
		this.sPRIMARY_ROLE_ID               = '';
		// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
		this.sPRIMARY_ROLE_NAME             = '';
		// 03/02/2019 Paul.  We need to know if they are an admin or admin delegate. 
		this.bIS_ADMIN                      = false;
		this.bIS_ADMIN_DELEGATE             = false;
		// 05/07/2019 Paul.  Maintain SearchView state. 
		this.bSAVE_QUERY                    = false;
		// 03/29/2021 Paul.  Allow display of impersonation state. 
		this.USER_IMPERSONATION             = false;
	}

	get GetIsOffline()
	{
		return this.bIS_OFFLINE;
	}

	get GetEnableOffline()
	{
		return this.bENABLE_OFFLINE;
	}

	// 12/09/2014 Paul.  Remote Server is on the background page of the browser extensions. 
	get RemoteServer()
	{
		if ( this.sREMOTE_SERVER == null )
		{
			if ( window.location.pathname == '/android_asset/www/index.html' )
			{
				this.sREMOTE_SERVER = './';
			}
		}
		return this.sREMOTE_SERVER;
	}

	// 07/01/2023 Paul.  ASP.NET Core will not have /React in the base. 
	public get ReactBase()
	{
		return this.sREACT_BASE;
	}

	get ValidateCredentials()
	{
		if ( this.sREMOTE_SERVER === null || this.sREMOTE_SERVER.length == 0 )
		{
			//alert('ValidateCredentials sREMOTE_SERVER is invalid ' + sREMOTE_SERVER);
			return false;
		}
		if ( this.sAUTHENTICATION === null || (this.sAUTHENTICATION != 'CRM' && this.sAUTHENTICATION != 'Basic' && this.sAUTHENTICATION != 'Windows' && this.sAUTHENTICATION != 'SingleSignOn') )
		{
			//alert('ValidateCredentials sAUTHENTICATION is invalid ' + sAUTHENTICATION);
			return false;
		}
		return true;
	}

	SetViewMode(mode)
	{
		this.viewMode = mode;
	}

	LoadCredentials()
	{
		try
		{
			//alert('LoadCredentials');
			// 08/01/2019 Paul.  The remote server will only get loaded on a mobile app. 
			//this.sREMOTE_SERVER                 = (localStorage.getItem('REMOTE_SERVER'                ) !== null) ? localStorage.getItem('REMOTE_SERVER'                ) : '';
			this.sAUTHENTICATION                = (localStorage.getItem('AUTHENTICATION'               ) !== null) ? localStorage.getItem('AUTHENTICATION'               ) : '';
			this.sUSER_NAME                     = (localStorage.getItem('USER_NAME'                    ) !== null) ? localStorage.getItem('USER_NAME'                    ) : '';
			this.sFULL_NAME                     = (localStorage.getItem('FULL_NAME'                    ) !== null) ? localStorage.getItem('FULL_NAME'                    ) : '';
			this.sEXCHANGE_ALIAS                = (localStorage.getItem('EXCHANGE_ALIAS'               ) !== null) ? localStorage.getItem('EXCHANGE_ALIAS'               ) : '';
			// 01/22/2021 Paul.  Exchange Email is used to control some access. 
			this.sEXCHANGE_EMAIL                = (localStorage.getItem('EXCHANGE_EMAIL'               ) !== null) ? localStorage.getItem('EXCHANGE_EMAIL'               ) : '';
			// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
			this.sPICTURE                       = (localStorage.getItem('PICTURE'                      ) !== null) ? localStorage.getItem('PICTURE'                      ) : '';
			this.sUSER_LANG                     = (localStorage.getItem('USER_LANG'                    ) !== null) ? localStorage.getItem('USER_LANG'                    ) : '';
			// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
			this.sUSER_THEME                    = (localStorage.getItem('USER_THEME'                   ) !== null) ? localStorage.getItem('USER_THEME'                   ) : '';
			this.sUSER_DATE_FORMAT              = (localStorage.getItem('USER_DATE_FORMAT'             ) !== null) ? localStorage.getItem('USER_DATE_FORMAT'             ) : '';
			this.sUSER_TIME_FORMAT              = (localStorage.getItem('USER_TIME_FORMAT'             ) !== null) ? localStorage.getItem('USER_TIME_FORMAT'             ) : '';
			this.sUSER_CURRENCY_ID              = (localStorage.getItem('USER_CURRENCY_ID'             ) !== null) ? localStorage.getItem('USER_CURRENCY_ID'             ) : '';
			this.sUSER_TIMEZONE_ID              = (localStorage.getItem('USER_TIMEZONE_ID'             ) !== null) ? localStorage.getItem('USER_TIMEZONE_ID'             ) : '';
			// 10/28/2021 Paul.  This is our indicator to redirect to User Wizard. 
			this.sORIGINAL_TIMEZONE_ID          = (localStorage.getItem('ORIGINAL_TIMEZONE_ID'         ) !== null) ? localStorage.getItem('ORIGINAL_TIMEZONE_ID'         ) : '';
			// 12/01/2014 Paul.  Add SignalR fields. 
			this.sUSER_EXTENSION                = (localStorage.getItem('USER_EXTENSION'               ) !== null) ? localStorage.getItem('USER_EXTENSION'               ) : '';
			this.sUSER_FULL_NAME                = (localStorage.getItem('USER_FULL_NAME'               ) !== null) ? localStorage.getItem('USER_FULL_NAME'               ) : '';
			this.sUSER_PHONE_WORK               = (localStorage.getItem('USER_PHONE_WORK'              ) !== null) ? localStorage.getItem('USER_PHONE_WORK'              ) : '';
			this.sUSER_SMS_OPT_IN               = (localStorage.getItem('USER_SMS_OPT_IN'              ) !== null) ? localStorage.getItem('USER_SMS_OPT_IN'              ) : '';
			this.sUSER_PHONE_MOBILE             = (localStorage.getItem('USER_PHONE_MOBILE'            ) !== null) ? localStorage.getItem('USER_PHONE_MOBILE'            ) : '';
			this.sUSER_TWITTER_TRACKS           = (localStorage.getItem('USER_TWITTER_TRACKS'          ) !== null) ? localStorage.getItem('USER_TWITTER_TRACKS'          ) : '';
			this.sUSER_CHAT_CHANNELS            = (localStorage.getItem('USER_CHAT_CHANNELS'           ) !== null) ? localStorage.getItem('USER_CHAT_CHANNELS'           ) : '';
			// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
			this.sUSER_CurrencyDecimalDigits    = (localStorage.getItem('USER_CurrencyDecimalDigits'   ) !== null) ? localStorage.getItem('USER_CurrencyDecimalDigits'   ) : '2';
			this.sUSER_CurrencyDecimalSeparator = (localStorage.getItem('USER_CurrencyDecimalSeparator') !== null) ? localStorage.getItem('USER_CurrencyDecimalSeparator') : '.';
			this.sUSER_CurrencyGroupSeparator   = (localStorage.getItem('USER_CurrencyGroupSeparator'  ) !== null) ? localStorage.getItem('USER_CurrencyGroupSeparator'  ) : ',';
			this.sUSER_CurrencyGroupSizes       = (localStorage.getItem('USER_CurrencyGroupSizes'      ) !== null) ? localStorage.getItem('USER_CurrencyGroupSizes'      ) : '3';
			this.sUSER_CurrencyNegativePattern  = (localStorage.getItem('USER_CurrencyNegativePattern' ) !== null) ? localStorage.getItem('USER_CurrencyNegativePattern' ) : '0';
			this.sUSER_CurrencyPositivePattern  = (localStorage.getItem('USER_CurrencyPositivePattern' ) !== null) ? localStorage.getItem('USER_CurrencyPositivePattern' ) : '0';
			// 10/16/2021 Paul.  Add support for user currency. 
			this.bUSER_CurrencyUSDollars        = (localStorage.getItem('USER_CurrencyUSDollars'       ) !== null) ? Sql.ToBoolean(localStorage.getItem('USER_CurrencyUSDollars'      )) : true;
			this.dUSER_CurrencyCONVERSION_RATE  = (localStorage.getItem('USER_CurrencyCONVERSION_RATE' ) !== null) ? Sql.ToFloat  (localStorage.getItem('USER_CurrencyCONVERSION_RATE')) : 1.0;

			this.sUSER_CurrencySymbol           = (localStorage.getItem('USER_CurrencySymbol'          ) !== null) ? localStorage.getItem('USER_CurrencySymbol'          ) : '$';
			// 01/22/2021 Paul.  Customizations may be based on the PRIMARY_ROLE_ID and not the name. 
			this.sPRIMARY_ROLE_ID               = (localStorage.getItem('PRIMARY_ROLE_ID'              ) !== null) ? localStorage.getItem('PRIMARY_ROLE_ID'              ) : '';
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			this.sPRIMARY_ROLE_NAME             = (localStorage.getItem('PRIMARY_ROLE_NAME'            ) !== null) ? localStorage.getItem('PRIMARY_ROLE_NAME'            ) : '';
			// 12/20/2019 Paul.  Observe the sidebar width. 
			let bEnableTeamManagement: boolean = Crm_Config.enable_team_management();
			let bEnableTeamHierarchy : boolean = Crm_Config.enable_team_hierarchy();
			this.showLeftCol  = (localStorage.getItem('showLeftCol' ) !== null) ? Sql.ToBoolean(localStorage.getItem('showLeftCol' )) : true;
			this.showTeamTree = (localStorage.getItem('showTeamTree') !== null) ? Sql.ToBoolean(localStorage.getItem('showTeamTree')) : bEnableTeamManagement && bEnableTeamHierarchy;

			// 06/18/2015 Paul.  Change the style file based on the theme. 
			// 05/13/2018 Paul.  We will not be changing the theme dynamically. 
			//var lnkThemeStyle = document.getElementById('lnkThemeStyle');
			//if ( lnkThemeStyle != null && (sUSER_THEME == 'Six' || sUSER_THEME == 'Atlantic' || sUSER_THEME == 'Seven') )
			//{
			//	// 03/19/2016 Paul.  OfficeAddin requires full path. 
			//	lnkThemeStyle.href = sREMOTE_SERVER + 'html5/Themes/' + sUSER_THEME + '/style.css';
			//}
			this.UserLanguageUpdated();

			//if ( this.sREMOTE_SERVER !== null && this.sREMOTE_SERVER.length > 0 && Right(this.sREMOTE_SERVER, 1) != '/' )
			//{
			//	this.sREMOTE_SERVER += '/';
			//}
			try
			{
				// 08/01/2019 Paul.  We only save the password on localhost.  We may enable on a hardware device. 
				if ( this.sREMOTE_SERVER != null && this.sREMOTE_SERVER.indexOf('://localhost') > 0 )
				{
					this.sPASSWORD = (localStorage.getItem('PASSWORD') !== null) ? localStorage.getItem('PASSWORD') : '';
					if ( this.sPASSWORD !== null && this.sPASSWORD.length > 0 )
					{
						this.sPASSWORD = Aes.Ctr.decrypt(this.sPASSWORD, 'Splendid', 256)
					}
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadCredentials', error);
				this.sPASSWORD = '';
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadCredentials', error);
			alert('LoadCredentials ' + error.message);
		}
	}
	SetUSER_ID       (obj)
	{
		this.sUSER_ID = obj;
		this.bIsAuthenticated = !Sql.IsEmptyString(this.sUSER_ID);
		if (  !this.bIsAuthenticated )
		{
			this.Reset();
		}
	}
	GetAUTHENTICATION()
	{
		let sAUTHENTICATION: string = localStorage.getItem('AUTHENTICATION');
		return sAUTHENTICATION;
	}
	GetUSER_NAME()
	{
		let sUSER_NAME: string = localStorage.getItem('USER_NAME');
		return sUSER_NAME
	}
	GetPASSWORD()
	{
		let sPASSWORD: string = null;
		try
		{
			// 08/01/2019 Paul.  We only save the password on localhost.  We may enable on a hardware device. 
			if ( this.sREMOTE_SERVER != null && this.sREMOTE_SERVER.indexOf('://localhost') > 0 )
			{
				sPASSWORD = localStorage.getItem('PASSWORD');
				if ( sPASSWORD !== null && sPASSWORD.length > 0 )
				{
					sPASSWORD = Aes.Ctr.decrypt(sPASSWORD, 'Splendid', 256)
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.GetPASSWORD', error);
			sPASSWORD = '';
		}
		return sPASSWORD;
	}

	UserLanguageUpdated()
	{
		let options =
		{
			monthNames     : L10n.GetListTerms('month_names_dom'      ),
			monthNamesShort: L10n.GetListTerms('short_month_names_dom'),
			dayNames       : L10n.GetListTerms('day_names_dom'        ),
			dayNamesShort  : L10n.GetListTerms('short_day_names_dom'  ),
		};
		moment.updateLocale(this.sUSER_LANG.substring(0, 2),
		{
			months      : options.monthNames,
			monthsShort : options.monthNamesShort,
			weekdays    : options.dayNames,
			weekdaysShort: options.dayNamesShort
		});
	}
	// 12/20/2019 Paul.  Observe the sidebar width. 
	ThemeUpdated()
	{
		// 04/24/2022 Paul.  Same should apply to Pacific theme. 
		if ( SplendidCache.UserTheme == 'Arctic' || SplendidCache.UserTheme == 'Pacific' )
		{
			let bEnableTeamManagement: boolean = Crm_Config.enable_team_management();
			let bEnableTeamHierarchy : boolean = Crm_Config.enable_team_hierarchy();
			let showLeftCol : boolean = (localStorage.getItem('showLeftCol' ) !== null) ? Sql.ToBoolean(localStorage.getItem('showLeftCol' )) : true;
			let showTeamTree: boolean = (localStorage.getItem('showTeamTree') !== null) ? Sql.ToBoolean(localStorage.getItem('showTeamTree')) : bEnableTeamManagement && bEnableTeamHierarchy;
			this.showLeftCol  = showLeftCol ;
			this.showTeamTree = showTeamTree;
		}
	}
	SetUSER_DATE_FORMAT(obj)
	{
		// 05/24/2018 Paul.  Change to moment format. 
		// http://momentjs.com/docs/#/displaying/
		// https://docs.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings
		this.sUSER_DATE_FORMAT = obj.replace('yyyy', 'YYYY').replace('yy', 'YY');
		// 05/24/2018 Paul.  Days are painful because dddd is full date, but we need to convert dd to DD.
		this.sUSER_DATE_FORMAT = this.sUSER_DATE_FORMAT.replace('dddd', 'DDDD').replace('dd', 'DD').replace('d', 'D').replace('DDDD', 'dddd');
	}
	SetUSER_TIME_FORMAT(obj)
	{
		// 05/24/2018 Paul.  Change to moment format. 
		// http://momentjs.com/docs/#/displaying/
		this.sUSER_TIME_FORMAT = obj.replace('tt', 'a');
	}
	SetREMOTE_SERVER                (obj) { this.sREMOTE_SERVER                 = obj; }
	// 07/01/2023 Paul.  ASP.NET Core will not have /React in the base. 
	SetREACT_BASE                   (obj) { this.sREACT_BASE                    = obj; }
	SetAUTHENTICATION               (obj) { this.sAUTHENTICATION                = obj; }
	SetUSER_NAME                    (obj) { this.sUSER_NAME                     = obj; }
	SetUSER_LANG                    (obj) { this.sUSER_LANG                     = obj; }
	SetPASSWORD                     (obj) { this.sPASSWORD                      = obj; this.UserLanguageUpdated(); }
	SetUSER_THEME                   (obj) { this.sUSER_THEME                    = obj; }
	SetUSER_CURRENCY_ID             (obj) { this.sUSER_CURRENCY_ID              = obj; }
	SetUSER_TIMEZONE_ID             (obj) { this.sUSER_TIMEZONE_ID              = obj; }
	SetFULL_NAME                    (obj) { this.sFULL_NAME                     = obj; }
	SetPICTURE                      (obj) { this.sPICTURE                       = obj; }
	SetTEAM_ID                      (obj) { this.sTEAM_ID                       = obj; }
	SetTEAM_NAME                    (obj) { this.sTEAM_NAME                     = obj; }
	SetIS_OFFLINE                   (obj) { this.bIS_OFFLINE                    = obj; }
	SetADMIN_MODE                   (obj) { this.ADMIN_MODE                     = obj; }
	SetENABLE_OFFLINE               (obj) { this.bENABLE_OFFLINE                = obj; }
	SetUSER_EXTENSION               (obj) { this.sUSER_EXTENSION                = obj; }
	SetUSER_FULL_NAME               (obj) { this.sUSER_FULL_NAME                = obj; }
	SetUSER_PHONE_WORK              (obj) { this.sUSER_PHONE_WORK               = obj; }
	SetUSER_SMS_OPT_IN              (obj) { this.sUSER_SMS_OPT_IN               = obj; }
	SetUSER_PHONE_MOBILE            (obj) { this.sUSER_PHONE_MOBILE             = obj; }
	SetUSER_TWITTER_TRACKS          (obj) { this.sUSER_TWITTER_TRACKS           = obj; }
	SetUSER_CHAT_CHANNELS           (obj) { this.sUSER_CHAT_CHANNELS            = obj; }
	// 09/17/2020 Paul.  Add PhoneBurner SignalR support. 
	SetPHONEBURNER_TOKEN_EXPIRES_AT (obj) { this.dtPHONEBURNER_TOKEN_EXPIRES_AT = obj; }

	SetUSER_CurrencyDecimalDigits   (obj) { this.sUSER_CurrencyDecimalDigits    = obj; }
	SetUSER_CurrencyDecimalSeparator(obj) { this.sUSER_CurrencyDecimalSeparator = obj; }
	SetUSER_CurrencyGroupSeparator  (obj) { this.sUSER_CurrencyGroupSeparator   = obj; }
	SetUSER_CurrencyGroupSizes      (obj) { this.sUSER_CurrencyGroupSizes       = obj; }
	SetUSER_CurrencyNegativePattern (obj) { this.sUSER_CurrencyNegativePattern  = obj; }
	SetUSER_CurrencyPositivePattern (obj) { this.sUSER_CurrencyPositivePattern  = obj; }
	SetUSER_CurrencySymbol          (obj) { this.sUSER_CurrencySymbol           = obj; }
	// 01/22/2021 Paul.  Customizations may be based on the PRIMARY_ROLE_ID and not the name. 
	SetPRIMARY_ROLE_ID              (obj) { this.sPRIMARY_ROLE_ID               = obj; }
	SetPRIMARY_ROLE_NAME            (obj) { this.sPRIMARY_ROLE_NAME             = obj; }

	// 12/23/2019 Paul.  Return the team tree as an object tree instead of XML. 
	SetTeamTree                     (obj)
	{
		//console.log((new Date()).toISOString() + ' ' + 'TEAM_TREE', obj);
		this.TEAM_TREE                      = obj;
	}
	
	SetUserProfile(obj)
	{
		this.sUSER_ID                       = obj.USER_ID                     ;
		this.sUSER_NAME                     = obj.USER_NAME                   ;
		this.sFULL_NAME                     = obj.FULL_NAME                   ;
		this.sEXCHANGE_ALIAS                = obj.EXCHANGE_ALIAS              ;
		// 01/22/2021 Paul.  Exchange Email is used to control some access. 
		this.sEXCHANGE_EMAIL                = obj.EXCHANGE_EMAIL              ;
		// 11/25/2014 Paul.  sUSER_PICTURE is used by the ChatDashboard. 
		this.sPICTURE                       = obj.PICTURE                     ;
		this.sTEAM_ID                       = obj.TEAM_ID                     ;
		this.sTEAM_NAME                     = obj.TEAM_NAME                   ;
		this.sUSER_LANG                     = obj.USER_LANG                   ;
		this.UserLanguageUpdated();
		// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
		this.sUSER_THEME                    = obj.USER_THEME                   ;
		this.SetUSER_DATE_FORMAT(obj.USER_DATE_FORMAT);
		this.SetUSER_TIME_FORMAT(obj.USER_TIME_FORMAT);
		this.sUSER_CURRENCY_ID              = obj.USER_CURRENCY_ID             ;
		this.sUSER_TIMEZONE_ID              = obj.USER_TIMEZONE_ID             ;
		// 10/28/2021 Paul.  This is our indicator to redirect to User Wizard. 
		this.sORIGINAL_TIMEZONE_ID          = obj.ORIGINAL_TIMEZONE_ID         ;
		// 12/01/2014 Paul.  Add SignalR fields. 
		// 12/09/2014 Paul.  Can't use Sql.ToString as it will not be defined for browser extensions. 
		this.sUSER_EXTENSION                = obj.USER_EXTENSION               ;
		this.sUSER_FULL_NAME                = obj.USER_FULL_NAME               ;
		this.sUSER_PHONE_WORK               = obj.USER_PHONE_WORK              ;
		this.sUSER_SMS_OPT_IN               = obj.USER_SMS_OPT_IN              ;
		this.sUSER_PHONE_MOBILE             = obj.USER_PHONE_MOBILE            ;
		this.sUSER_TWITTER_TRACKS           = obj.USER_TWITTER_TRACKS          ;
		this.sUSER_CHAT_CHANNELS            = obj.USER_CHAT_CHANNELS           ;
		// 09/17/2020 Paul.  Add PhoneBurner SignalR support. 
		this.dtPHONEBURNER_TOKEN_EXPIRES_AT = FromJsonDate(obj.PHONEBURNER_TOKEN_EXPIRES_AT);
		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		this.sUSER_CurrencyDecimalDigits    = obj.USER_CurrencyDecimalDigits   ;
		this.sUSER_CurrencyDecimalSeparator = obj.USER_CurrencyDecimalSeparator;
		this.sUSER_CurrencyGroupSeparator   = obj.USER_CurrencyGroupSeparator  ;
		this.sUSER_CurrencyGroupSizes       = obj.USER_CurrencyGroupSizes      ;
		this.sUSER_CurrencyNegativePattern  = obj.USER_CurrencyNegativePattern ;
		this.sUSER_CurrencyPositivePattern  = obj.USER_CurrencyPositivePattern ;
		this.sUSER_CurrencySymbol           = obj.USER_CurrencySymbol          ;
		// 10/16/2021 Paul.  Add support for user currency. 
		this.bUSER_CurrencyUSDollars        = true;
		this.dUSER_CurrencyCONVERSION_RATE  = 1.0;
		let currency: any = SplendidCache.Currencies(this.sUSER_CURRENCY_ID);
		if ( currency != null )
		{
			let gBASE_CURRENCY = SplendidCache.Config('base_currency');
			// 09/19/2024 Paul.. Guids are returned from api in lower case. 
			if ( Sql.IsEmptyGuid(gBASE_CURRENCY) )
				gBASE_CURRENCY = 'e340202e-6291-4071-b327-a34cb4df239b';
			this.bUSER_CurrencyUSDollars       = (this.sUSER_CURRENCY_ID.toUpperCase() == gBASE_CURRENCY.toUpperCase());
			this.dUSER_CurrencyCONVERSION_RATE = currency.CONVERSION_RATE;
			if ( this.dUSER_CurrencyCONVERSION_RATE <= 0 )
				this.dUSER_CurrencyCONVERSION_RATE = 1.0;
		}

		// 01/22/2021 Paul.  Customizations may be based on the PRIMARY_ROLE_ID and not the name. 
		this.sPRIMARY_ROLE_ID               = obj.PRIMARY_ROLE_ID              ;
		// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
		this.sPRIMARY_ROLE_NAME             = obj.PRIMARY_ROLE_NAME            ;
		// 03/02/2019 Paul.  We need to know if they are an admin or admin delegate. 
		this.bIS_ADMIN                      = (obj.IS_ADMIN === undefined ? false : obj.IS_ADMIN);
		this.bIS_ADMIN_DELEGATE             = (obj.IS_ADMIN_DELEGATE === undefined ? false : obj.IS_ADMIN_DELEGATE)
		// 05/07/2019 Paul.  Maintain SearchView state. 
		this.bSAVE_QUERY                    = Sql.ToBoolean(obj.SAVE_QUERY)    ;
		// 05/28/2019 Paul.  Set the profile last so that any obserable on bIsAuthenticated will fire after state completely set. 
		this.bIsAuthenticated               = !Sql.IsEmptyString(this.sUSER_ID);
		// 12/16/2019 Paul.  Menu needs to know if logout should be displayed. 
		this.sAUTHENTICATION                = obj.AUTHENTICATION               ;
		// 03/29/2021 Paul.  Allow display of impersonation state. 
		this.USER_IMPERSONATION             = Sql.ToBoolean(obj.USER_IMPERSONATION);
		this.UserLanguageUpdated();
		this.ThemeUpdated();

		try
		{
			localStorage.setItem('REMOTE_SERVER'                , this.sREMOTE_SERVER                );
			localStorage.setItem('AUTHENTICATION'               , this.sAUTHENTICATION               );
			localStorage.setItem('USER_NAME'                    , this.sUSER_NAME                    );
			localStorage.setItem('FULL_NAME'                    , this.sFULL_NAME                    );
			localStorage.setItem('EXCHANGE_ALIAS'               , this.sEXCHANGE_ALIAS               );
			// 01/22/2021 Paul.  Exchange Email is used to control some access. 
			localStorage.setItem('EXCHANGE_EMAIL'               , this.sEXCHANGE_EMAIL               );

			// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
			localStorage.setItem('PICTURE'                      , this.sPICTURE                      );
			localStorage.setItem('USER_LANG'                    , this.sUSER_LANG                    );
			// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
			localStorage.setItem('USER_THEME'                   , this.sUSER_THEME                   );
			localStorage.setItem('USER_DATE_FORMAT'             , this.sUSER_DATE_FORMAT             );
			localStorage.setItem('USER_TIME_FORMAT'             , this.sUSER_TIME_FORMAT             );
			localStorage.setItem('USER_CURRENCY_ID'             , this.sUSER_CURRENCY_ID             );
			localStorage.setItem('USER_TIMEZONE_ID'             , this.sUSER_TIMEZONE_ID             );
			// 10/28/2021 Paul.  This is our indicator to redirect to User Wizard. 
			localStorage.setItem('ORIGINAL_TIMEZONE_ID'         , this.sORIGINAL_TIMEZONE_ID         );

			// 12/01/2014 Paul.  Add SignalR fields. 
			localStorage.setItem('USER_EXTENSION'               , this.sUSER_EXTENSION               );
			localStorage.setItem('USER_FULL_NAME'               , this.sUSER_FULL_NAME               );
			localStorage.setItem('USER_PHONE_WORK'              , this.sUSER_PHONE_WORK              );
			localStorage.setItem('USER_SMS_OPT_IN'              , this.sUSER_SMS_OPT_IN              );
			localStorage.setItem('USER_PHONE_MOBILE'            , this.sUSER_PHONE_MOBILE            );
			localStorage.setItem('USER_TWITTER_TRACKS'          , this.sUSER_TWITTER_TRACKS          );
			localStorage.setItem('USER_CHAT_CHANNELS'           , this.sUSER_CHAT_CHANNELS           );
			localStorage.setItem('PRIMARY_ROLE_ID'              , this.sPRIMARY_ROLE_ID              );
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			localStorage.setItem('PRIMARY_ROLE_NAME'            , this.sPRIMARY_ROLE_NAME            );

			// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
			localStorage.setItem('USER_CurrencyDecimalDigits'   , this.sUSER_CurrencyDecimalDigits   );
			localStorage.setItem('USER_CurrencyDecimalSeparator', this.sUSER_CurrencyDecimalSeparator);
			localStorage.setItem('USER_CurrencyGroupSeparator'  , this.sUSER_CurrencyGroupSeparator  );
			localStorage.setItem('USER_CurrencyGroupSizes'      , this.sUSER_CurrencyGroupSizes      );
			localStorage.setItem('USER_CurrencyNegativePattern' , this.sUSER_CurrencyNegativePattern );
			localStorage.setItem('USER_CurrencyPositivePattern' , this.sUSER_CurrencyPositivePattern );
			localStorage.setItem('USER_CurrencySymbol'          , this.sUSER_CurrencySymbol          );
			// 10/16/2021 Paul.  Add support for user currency. 
			localStorage.setItem('USER_CurrencyUSDollars'       , Sql.ToString(this.bUSER_CurrencyUSDollars      ));
			localStorage.setItem('USER_CurrencyCONVERSION_RATE' , Sql.ToString(this.dUSER_CurrencyCONVERSION_RATE));

			// 08/01/2019 Paul.  We only save the password on localhost.  We may enable on a hardware device. 
			if ( this.sREMOTE_SERVER != null && this.sREMOTE_SERVER.indexOf('://localhost') > 0 )
			{
				// 08/05/2019 Paul.  Refreshing the browser will clear sPASSWORD, so don't bother to save after refresh. 
				if ( !Sql.IsEmptyString(this.sPASSWORD) )
				{
					localStorage.setItem('PASSWORD', Aes.Ctr.encrypt(this.sPASSWORD, 'Splendid', 256));
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.SetUserProfile', error);
			alert('SetUserProfile ' + error.message);
		}
	}

	ClearStorage()
	{
		// 08/01/2019 Paul.  The remote server will only get loaded on a mobile app. 
		//localStorage.removeItem('REMOTE_SERVER'                );
		localStorage.removeItem('AUTHENTICATION'               );
		// 09/04/2020 Paul.  Don't clear the user on logout. 
		//localStorage.removeItem('USER_NAME'                    );
		localStorage.removeItem('FULL_NAME'                    );
		// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
		localStorage.removeItem('PICTURE'                      );
		localStorage.removeItem('USER_LANG'                    );
		// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
		localStorage.removeItem('USER_THEME'                   );
		localStorage.removeItem('USER_DATE_FORMAT'             );
		localStorage.removeItem('USER_TIME_FORMAT'             );
		localStorage.removeItem('USER_CURRENCY_ID'             );
		localStorage.removeItem('USER_TIMEZONE_ID'             );

		// 12/01/2014 Paul.  Add SignalR fields. 
		localStorage.removeItem('USER_EXTENSION'               );
		localStorage.removeItem('USER_FULL_NAME'               );
		localStorage.removeItem('USER_PHONE_WORK'              );
		localStorage.removeItem('USER_SMS_OPT_IN'              );
		localStorage.removeItem('USER_PHONE_MOBILE'            );
		localStorage.removeItem('USER_TWITTER_TRACKS'          );
		localStorage.removeItem('USER_CHAT_CHANNELS'           );
		// 01/22/2021 Paul.  Customizations may be based on the PRIMARY_ROLE_ID and not the name. 
		localStorage.removeItem('PRIMARY_ROLE_ID'              );
		// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
		localStorage.removeItem('PRIMARY_ROLE_NAME'            );

		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		localStorage.removeItem('USER_CurrencyDecimalDigits'   );
		localStorage.removeItem('USER_CurrencyDecimalSeparator');
		localStorage.removeItem('USER_CurrencyGroupSeparator'  );
		localStorage.removeItem('USER_CurrencyGroupSizes'      );
		localStorage.removeItem('USER_CurrencyNegativePattern' );
		localStorage.removeItem('USER_CurrencyPositivePattern' );
		localStorage.removeItem('USER_CurrencySymbol'          );
		// 10/16/2021 Paul.  Add support for user currency. 
		localStorage.removeItem('USER_CurrencyUSDollars'       );
		localStorage.removeItem('USER_CurrencyCONVERSION_RATE' );
		// 08/01/2019 Paul.  We only save the password on localhost.  We may enable on a hardware device. 
		if ( this.sREMOTE_SERVER != null && this.sREMOTE_SERVER.indexOf('://localhost') > 0 )
		{
			localStorage.removeItem('PASSWORD');
		}
	}

	SaveCredentials(sAuthentication, sUserName, sPassword)
	{
		try
		{
			//alert('SaveCredentials ' + sRemoteServer + ' ' + sAuthentication + ' ' + sUserName + ' ' + sPassword);
			this.sAUTHENTICATION = sAuthentication;
			this.sUSER_NAME      = sUserName      ;
			this.sPASSWORD       = sPassword      ;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.SaveCredentials', error);
			alert('SaveCredentials ' + error.message);
		}
	}
}
const credentials = new CredentialsStore();
export default credentials;

