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
import { XMLParser, XMLBuilder }                       from 'fast-xml-parser'            ;
import { observable, _resetGlobalState }               from 'mobx'                       ;
// 2. Store and Types. 
import MODULE                                          from '../types/MODULE'            ;
import ACL_ACCESS                                      from '../types/ACL_ACCESS'        ;
import ACL_FIELD_ACCESS                                from '../types/ACL_FIELD_ACCESS'  ;
// 3. Scripts. 
import Sql                                             from '../scripts/Sql'             ;
import Security                                        from '../scripts/Security'        ;
import Credentials                                     from '../scripts/Credentials'     ;
import { Crm_Config }                                  from '../scripts/Crm'             ;
import { UpdateSavedSearch }                           from '../scripts/ModuleUpdate'    ;
import { StartsWith, EndsWith }                        from '../scripts/utility'         ;
import { jsonReactState, Application_ResetReactState } from '../scripts/Application'     ;
import { ReportDesignerModules }                       from '../ReportDesigner/ReportDesignerModules';
// 4. Components and Views. 

const TeamHierarchyModule: string = 'TeamHierarchy';

export class CultureInfo
{
	CurrencyDecimalDigits   : number;
	CurrencyDecimalSeparator: string;
	CurrencyGroupSeparator  : string;
	CurrencyGroupSizes      : number;
	CurrencyNegativePattern : number;
	CurrencyPositivePattern : number;
	CurrencySymbol          : string;
}

export class SplendidCacheStore
{
	// 10/12/2012 Paul.  Rename objects to be consistent with CRM layout tables. 
	TAB_MENU                  : any     = null;
	CONFIG                    : any     = null;
	MODULES                   : any     = null;
	TEAMS                     : any     = null;
	// 07/21/2019 Paul.  We need UserAccess control for buttons. 
	MODULE_ACL_ACCESS         : any     = null;
	ACL_ACCESS                : any     = null;
	ACL_FIELD_ACCESS          : any     = null;
	// 01/22/2021 Paul.  Some customizations may be dependent on role name. 
	ACL_ROLES                 : any     = null;
	// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
	USERS                     : any     = null;
	// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	GRIDVIEWS                 : any     = new Object();
	GRIDVIEWS_COLUMNS         : any     = new Object();
	DETAILVIEWS_FIELDS        : any     = new Object();
	EDITVIEWS_FIELDS          : any     = new Object();
	DETAILVIEWS_RELATIONSHIPS : any     = new Object();
	// 02/16/2016 Paul.  Add EditView Relationships for the new layout editor. 
	EDITVIEWS_RELATIONSHIPS   : any     = new Object();
	DYNAMIC_BUTTONS           : any     = new Object();
	// 08/15/2019 Paul.  Add support for menu shortcuts. 
	SHORTCUTS                 : any     = new Object();
	TERMINOLOGY               : any     = new Object();
	TERMINOLOGY_LISTS         : any     = new Object();
	// 07/01/2019 Paul.  The SubPanelsView needs to understand how to manage all relationships. 
	RELATIONSHIPS             : any     = new Object();
	// 03/01/2016 Paul.  Order management lists. 
	TAX_RATES                 : any     = new Object();
	DISCOUNTS                 : any     = new Object();
	// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
	TIMEZONES                 : any     = new Object();
	CURRENCIES                : any     = new Object();
	LANGUAGES                 : any     = new Object();
	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	FAVORITES                 : any     = new Object();
	LAST_VIEWED               : any     = new Object();
	SAVED_SEARCH              : any     = new Object();
	// 05/10/2019 Paul.  Saved search needs to know the available columns. 
	MODULE_COLUMNS            : any     = new Object();
	// 04/29/2019 Paul.  When FAVORITES, LAST_VIEWED or SAVED_SEARCH changes, increment this number.  It is watched in the TopNav. 
	@observable
	NAV_MENU_CHANGE           : number  = 0;
	// 02/25/2019 Paul.  New method to fetch the React Custom Views. 
	REACT_CUSTOM_VIEWS        : any     = new Object();
	// 02/28/2019 Chase. Cache compiled React Custom Views to avoid recompilation.
	COMPILED_CUSTOM_VIEWS     : any     = new Object();
	REACT_DASHLETS            : any     = new Object();
	// 03/01/2019 Paul.  New method to fetch the compiled React Custom Views. 
	COMPILED_DASHLETS         : any     = new Object();
	// 05/24/2019 Paul.  Dashboards and Dashlets are now included. 
	DASHBOARDS                : any     = new Object();
	DASHBOARDS_PANELS         : any     = new Object();
	// 05/03/2020 Paul.  Emails.EditView should use cached list of signatures. 
	SIGNATURES                : any     = new Object();
	// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundMail. 
	OUTBOUND_EMAILS           : any     = new Object();
	// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundSms. 
	OUTBOUND_SMS              : any     = new Object();
	// 04/04/2021 Paul.  Cache the ArchiveViewExists flag. 
	ARCHIVE_VIEWS             : any     = new Object();
	// 03/03/2019 Paul.  AdminMenu. 
	ADMIN_MENU                : any     = null;
	@observable
	IsInitialized             : boolean = false;
	// 07/22/2019 Paul.  Field level security may not be enabled. 
	bEnableACLFieldSecurity   : boolean = false;
	// 01/18/2020 Paul.  Current Team Hierarchy can change outside of TeamTree. 
	@observable
	nTeamHierarchyCounter     : number = 0;
	// 05/06/2021 Paul.  Track browser history changes so that we can determine if last event was a POP event. 
	lastHistoryAction         : string = null;
	lastHistoryLocation       : any    = null;
	gridLastPage              : any    = {};
	// 09/05/2021 Paul.  BusinessProcesses needs to cache the report designer modules. 
	designerModules           : ReportDesignerModules = null;

	get UserID(): string
	{
		return Credentials.sUSER_ID;
	}

	get UserName(): string
	{
		return Credentials.sUSER_NAME;
	}

	get FullName(): string
	{
		// 10/26/2012 Paul.  The full name might be empty. 
		if ( Sql.IsEmptyString(Credentials.sFULL_NAME) )
			return Credentials.sUSER_NAME;
		return Credentials.sFULL_NAME;
	}

	// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
	get Picture(): string
	{
		return Credentials.sPICTURE;
	}

	get UserLang(): string
	{
		// 11/27/2012 Paul.  We should always have a language. 
		if ( Sql.IsEmptyString(Credentials.sUSER_LANG) )
			return 'en-US';
		return Credentials.sUSER_LANG;
	}

	// 09/02/2019 Paul.  The React Client will support some themes. 
	get UserTheme(): string
	{
		let USER_THEME: string = Credentials.sUSER_THEME;
		if ( Sql.IsEmptyString(USER_THEME) )
		{
			USER_THEME = this.Config('default_theme');
			if ( Sql.IsEmptyString(USER_THEME) )
			{
				USER_THEME = 'Atlantic';
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UserTheme', USER_THEME);
		return USER_THEME;
	}

	get UserDateFormat(): string
	{
		return Credentials.sUSER_DATE_FORMAT;
	}

	get UserTimeFormat(): string
	{
		return Credentials.sUSER_TIME_FORMAT;
	}

	get TeamID(): string
	{
		return Credentials.sTEAM_ID;
	}

	get TeamName(): string
	{
		return Credentials.sTEAM_NAME;
	}

	// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
	get NumberFormatInfo(): CultureInfo
	{
		let info = new CultureInfo();
		info.CurrencyDecimalDigits    = !isFinite(+Credentials.sUSER_CurrencyDecimalDigits) ? 2 : Math.abs(+Credentials.sUSER_CurrencyDecimalDigits);
		info.CurrencyDecimalSeparator = (Credentials.sUSER_CurrencyDecimalSeparator == '' || Credentials.sUSER_CurrencyDecimalSeparator == null) ? '.' : Credentials.sUSER_CurrencyDecimalSeparator;
		info.CurrencyGroupSeparator   = (Credentials.sUSER_CurrencyGroupSeparator   == '' || Credentials.sUSER_CurrencyGroupSeparator == null) ? ',' : Credentials.sUSER_CurrencyGroupSeparator;
		info.CurrencyGroupSizes       = !isFinite(+Credentials.sUSER_CurrencyGroupSizes) ? 3 : Math.abs(+Credentials.sUSER_CurrencyGroupSizes);
		info.CurrencyNegativePattern  = !isFinite(+Credentials.sUSER_CurrencyNegativePattern) ? 0 : Math.abs(+Credentials.sUSER_CurrencyNegativePattern);
		info.CurrencyPositivePattern  = !isFinite(+Credentials.sUSER_CurrencyPositivePattern) ? 0 : Math.abs(+Credentials.sUSER_CurrencyPositivePattern);
		info.CurrencySymbol           =  Credentials.sUSER_CurrencySymbol;
		return info;
	}

	get TabMenu()
	{
		return this.TAB_MENU;
	}

	get AdminMenu()
	{
		return this.ADMIN_MENU;
	}

	Reset()
	{
		this.TAB_MENU                  = null;
		this.CONFIG                    = null;
		this.MODULES                   = null;
		this.TEAMS                     = null;
		this.USERS                     = null;
		// 07/21/2019 Paul.  We need UserAccess control for buttons. 
		this.MODULE_ACL_ACCESS         = null;
		this.ACL_ACCESS                = null;
		this.ACL_FIELD_ACCESS          = null;
		// 01/22/2021 Paul.  Some customizations may be dependent on role name. 
		this.ACL_ROLES                 = null;
		// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
		this.GRIDVIEWS                 = new Object();
		this.GRIDVIEWS_COLUMNS         = new Object();
		this.DETAILVIEWS_FIELDS        = new Object();
		this.EDITVIEWS_FIELDS          = new Object();
		this.DETAILVIEWS_RELATIONSHIPS = new Object();
		this.EDITVIEWS_RELATIONSHIPS   = new Object();
		this.DYNAMIC_BUTTONS           = new Object();
		// 08/15/2019 Paul.  Add support for menu shortcuts. 
		this.SHORTCUTS                 = new Object();
		this.TERMINOLOGY               = new Object();
		this.TERMINOLOGY_LISTS         = new Object();
		// 07/01/2019 Paul.  The SubPanelsView needs to understand how to manage all relationships. 
		this.RELATIONSHIPS             = new Object();
		this.TAX_RATES                 = new Object();
		this.DISCOUNTS                 = new Object();
		// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
		this.TIMEZONES                 = new Object();
		this.CURRENCIES                = new Object();
		this.LANGUAGES                 = new Object();
		// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
		this.FAVORITES                 = new Object();
		this.LAST_VIEWED               = new Object();
		this.SAVED_SEARCH              = new Object();
		// 05/10/2019 Paul.  Saved search needs to know the available columns. 
		this.MODULE_COLUMNS            = new Object();
		// 02/25/2019 Paul.  New method to fetch the React Custom Views. 
		this.REACT_CUSTOM_VIEWS        = new Object();
		// 02/28/2019 Chase. Cache compiled React Custom Views to avoid recompilation.
		this.COMPILED_CUSTOM_VIEWS     = new Object();
		this.REACT_DASHLETS            = new Object();
		// 03/01/2019 Paul.  New method to fetch the compiled React Custom Views. 
		this.COMPILED_DASHLETS         = new Object();
		// 05/24/2019 Paul.  Dashboards and Dashlets are now included. 
		this.DASHBOARDS                = new Object();
		this.DASHBOARDS_PANELS         = new Object();
		// 05/03/2020 Paul.  Emails.EditView should use cached list of signatures. 
		this.SIGNATURES                = new Object();
		// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundMail. 
		this.OUTBOUND_EMAILS           = new Object();
		// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundSms. 
		this.OUTBOUND_SMS              = new Object();
		// 04/04/2021 Paul.  Cache the ArchiveViewExists flag. 
		this.ARCHIVE_VIEWS             = new Object();

		this.ADMIN_MENU                = null;
		// 05/16/2019 Paul.  We need to re-initialize after reset. 
		this.IsInitialized             = false;
		// 07/22/2019 Paul.  Field level security may not be enabled. 
		this.bEnableACLFieldSecurity   = false;
		// 07/11/2019 Paul.  Keep original React State object for debugging. 
		Application_ResetReactState();
		// 05/06/2021 Paul.  Track browser history changes so that we can determine if last event was a POP event. 
		this.lastHistoryAction         = null;
		this.lastHistoryLocation       = null;
		this.gridLastPage              = {};
		// 09/05/2021 Paul.  BusinessProcesses needs to cache the report designer modules. 
		this.designerModules           = null;
		if ( Credentials.bMOBILE_CLIENT )
		{
			this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + '.NTC_LOGIN_MESSAGE'          ] = 'Please login.'  ;
			this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + 'Offline.LBL_REMOTE_SERVER'   ] = 'Remote Server:' ;
			this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + 'Users.LBL_USER_NAME'         ] = 'User Name:'     ;
			this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + 'Users.LBL_PASSWORD'          ] = 'Password'       ;
			this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + 'Users.LBL_LOGIN_BUTTON_LABEL'] = 'Login'          ;
			this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + 'Users.LBL_FORGOT_PASSWORD'   ] = 'Forgot Password';
			this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + 'Users.LBL_EMAIL'             ] = 'Email address'  ;
			this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + '.LBL_SUBMIT_BUTTON_LABEL'    ] = 'Submit'         ;
			this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + '.LNK_MOBILE_CLIENT'          ] = 'Mobile Client'  ;
		}
	}

	Config(sNAME: string)
	{
		if ( this.CONFIG == null )
		{
			return null;// console.log((new Date()).toISOString() + ' ' + 'SplendidCache: CONFIG is null, ' + sNAME);
		}
		else if ( this.CONFIG[sNAME] == null )
		{
			return null;// console.log((new Date()).toISOString() + ' ' + 'SplendidCache: CONFIG could not find ' + sNAME, this.CONFIG, jsonReactState);
		}
		return this.CONFIG[sNAME];
	}

	Team(sID: string)
	{
		if ( this.TEAMS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TEAMS is null, ' + sID);
			return null;
		}
		else if ( this.TEAMS[sID.toLowerCase()] == null )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: TEAMS could not find ' + sID, this.TEAMS);
			return sID;
		}
		return this.TEAMS[sID.toLowerCase()];
	}

	// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
	User(sID: string)
	{
		if ( this.USERS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: USERS is null, ' + sID);
			return null;
		}
		else if ( this.USERS[sID.toLowerCase()] == null )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: USERS could not find ' + sID, this.USERS);
			return sID;
		}
		return this.USERS[sID.toLowerCase()];
	}

	Module(sMODULE_NAME: string, sCaller?: string)
	{
		if ( this.MODULES == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: MODULES is null, ' + sMODULE_NAME + ' from ' + sCaller);
			return null;
		}
		else if ( this.MODULES[sMODULE_NAME] == null )
		{
			// 01/09/2020 Paul.  Ignore request for help module. 
			if ( sMODULE_NAME != 'Help' && sMODULE_NAME != 'Reload' )
			{
				//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: MODULES could not find ' + sMODULE_NAME + ' from ' + sCaller, this.MODULES);
			}
			return null;
		}
		return this.MODULES[sMODULE_NAME];
	}

	// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	GridViews(GRID_NAME: string, ignoreMissing?: boolean)
	{
		if ( this.GRIDVIEWS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: GRIDVIEWS is null, ' + GRID_NAME);
			return null;
		}
		else if ( this.GRIDVIEWS[GRID_NAME] == null )
		{
			if ( !ignoreMissing )
			{
				//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: GRIDVIEWS could not find ' + GRID_NAME, this.GRIDVIEWS);
			}
			return null;
		}
		return this.GRIDVIEWS[GRID_NAME];
	}

	// 07/07/2020 Paul.  Ignore missing during DynamicLayout. 
	GridViewColumns(GRID_NAME: string, ignoreMissing?: boolean)
	{
		if ( this.GRIDVIEWS_COLUMNS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: GRIDVIEWS_COLUMNS is null, ' + GRID_NAME);
			return null;
		}
		else if ( this.GRIDVIEWS_COLUMNS[GRID_NAME] == null )
		{
			if ( !ignoreMissing )
			{
				//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: GRIDVIEWS_COLUMNS could not find ' + GRID_NAME, this.GRIDVIEWS_COLUMNS);
			}
			return null;
		}
		return this.GRIDVIEWS_COLUMNS[GRID_NAME];
	}

	// 07/07/2020 Paul.  Ignore missing during DynamicLayout. 
	DetailViewFields(sDETAIL_NAME: string, ignoreMissing?: boolean)
	{
		if ( this.DETAILVIEWS_FIELDS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DETAILVIEWS_FIELDS is null, ' + sDETAIL_NAME);
			return null;
		}
		else if ( this.DETAILVIEWS_FIELDS[sDETAIL_NAME] == null )
		{
			if ( !ignoreMissing )
			{
				//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: DETAILVIEWS_FIELDS could not find ' + sDETAIL_NAME, this.DETAILVIEWS_FIELDS);
			}
			return null;
		}
		return this.DETAILVIEWS_FIELDS[sDETAIL_NAME];
	}

	// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
	EditViewFields(sEDIT_NAME: string, ignoreMissing?: boolean)
	{
		if ( this.EDITVIEWS_FIELDS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: EDITVIEWS_FIELDS is null, ' + sEDIT_NAME);
			return null;
		}
		else if ( this.EDITVIEWS_FIELDS[sEDIT_NAME] == null && !EndsWith(sEDIT_NAME, '.Inline') && sEDIT_NAME != 'Activities.EditView' )
		{
			if ( !ignoreMissing )
			{
				// 01/08/2021 Paul.  No lnoger needed. 
				//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: EDITVIEWS_FIELDS could not find ' + sEDIT_NAME, this.EDITVIEWS_FIELDS);
			}
			return null;
		}
		return this.EDITVIEWS_FIELDS[sEDIT_NAME];
	}

	DetailViewRelationships(sDETAIL_NAME: string)
	{
		if ( this.DETAILVIEWS_RELATIONSHIPS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DETAILVIEWS_RELATIONSHIPS is null, ' + sDETAIL_NAME);
			return null;
		}
		else if ( this.DETAILVIEWS_RELATIONSHIPS[sDETAIL_NAME] == null )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: DETAILVIEWS_RELATIONSHIPS could not find ' + sDETAIL_NAME, this.DETAILVIEWS_RELATIONSHIPS);
			return null;
		}
		return this.DETAILVIEWS_RELATIONSHIPS[sDETAIL_NAME];
	}

	EditViewRelationships(sEDIT_NAME: string)
	{
		if ( this.EDITVIEWS_RELATIONSHIPS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: EDITVIEWS_RELATIONSHIPS is null, ' + sEDIT_NAME);
			return null;
		}
		else if ( this.EDITVIEWS_RELATIONSHIPS[sEDIT_NAME] == null )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: EDITVIEWS_RELATIONSHIPS could not find ' + sEDIT_NAME, this.EDITVIEWS_RELATIONSHIPS);
			return null;
		}
		return this.EDITVIEWS_RELATIONSHIPS[sEDIT_NAME];
	}

	DynamicButtons(sVIEW_NAME: string)
	{
		if ( this.DYNAMIC_BUTTONS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DYNAMIC_BUTTONS is null, ' + sVIEW_NAME);
			return null;
		}
		// 05/21/2019 Paul.  It is common for a panel not to have dynamic buttons. 
		//else if ( this.DYNAMIC_BUTTONS[sVIEW_NAME] == null )
		//{
		//	//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: DYNAMIC_BUTTONS could not find ' + sVIEW_NAME, this.DYNAMIC_BUTTONS);
		//	return null;
		//}
		return this.DYNAMIC_BUTTONS[sVIEW_NAME];
	}

	// 08/15/2019 Paul.  Add support for menu shortcuts. 
	Shortcuts(sMODULE_NAME: string)
	{
		if ( this.SHORTCUTS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: SHORTCUTS is null, ' + sMODULE_NAME);
			return null;
		}
		//else if ( this.SHORTCUTS[sVIEW_NAME] == null )
		//{
		//	//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: SHORTCUTS could not find ' + sMODULE_NAME, this.SHORTCUTS);
		//	return null;
		//}
		return this.SHORTCUTS[sMODULE_NAME];
	}

	Terminology(sTerm: string)
	{
		if ( this.TERMINOLOGY == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY is null, ' + sTerm);
			return null;
		}
		else if ( this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + sTerm] == null )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY could not find ' + sTerm, this.TERMINOLOGY);
			return sTerm;
		}
		return this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + sTerm];
	}

	// 05/15/2020 Paul.  EmailTemplates needs to be able to insert CampaignTrackers. 
	SetTerminology(sTerm: string, sDisplayName: string)
	{
		if ( this.TERMINOLOGY == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY is null, ' + sTerm);
			return null;
		}
		this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + sTerm] = sDisplayName;
	}


	TerminologyList(sListName: string)
	{
		if ( this.TERMINOLOGY_LISTS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY_LISTS is null, ' + sListName);
			return null;
		}
		else if ( this.TERMINOLOGY_LISTS[Credentials.sUSER_LANG + '.' + sListName] == null )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY_LISTS could not find ' + sListName, this.TERMINOLOGY_LISTS);
			return null;
		}
		return this.TERMINOLOGY_LISTS[Credentials.sUSER_LANG + '.' + sListName];
	}

	// 05/15/2020 Paul.  EmailTemplates needs to be able to insert CampaignTrackers. 
	SetTerminologyList(sListName: string, arrListValues)
	{
		if ( this.TERMINOLOGY_LISTS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY_LISTS is null, ' + sListName);
			return null;
		}
		this.TERMINOLOGY_LISTS[Credentials.sUSER_LANG + '.' + sListName] = arrListValues;
	}

	// 07/01/2019 Paul.  The SubPanelsView needs to understand how to manage all relationships. 
	Relationship(sLHS_MODULE, sRHS_MODULE)
	{
		if ( this.RELATIONSHIPS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: RELATIONSHIPS is null, ' + sLHS_MODULE);
			return null;
		}
		else if ( this.RELATIONSHIPS[sLHS_MODULE] == null )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: sLHS_MODULE could not find ' + sLHS_MODULE, this.RELATIONSHIPS);
			return null;
		}
		let arrLHS = this.RELATIONSHIPS[sLHS_MODULE];
		// 09/15/2022 Paul.  Separate relationship lookup into two passes.  
		// The goal here is to allow meetings_contacts to be found before contact_meetings is found. 
		// RHS == RHS && LHS == LHS should have a higher prioirty than RHS == LHS && LHS == RHS. 
		for ( let i = 0; i < arrLHS.length; i++ )
		{
			let relationship = arrLHS[i];
			if ( relationship.RHS_MODULE == sRHS_MODULE && relationship.LHS_MODULE == sLHS_MODULE )
			{
				return relationship;
			}
		}
		for ( let i = 0; i < arrLHS.length; i++ )
		{
			let relationship = arrLHS[i];
			if ( relationship.RHS_MODULE == sLHS_MODULE && relationship.LHS_MODULE == sRHS_MODULE )
			{
				return relationship;
			}
		}
		//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: sLHS_MODULE could not find ' + sLHS_MODULE + ' => ' + sRHS_MODULE, this.RELATIONSHIPS);
		return null;
	}

	// 03/01/2016 Paul.  Order management lists. 
	TaxRates(sID: string)
	{
		if ( this.TAX_RATES == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TAX_RATES is null, ' + sID);
			return null;
		}
		else if ( this.TAX_RATES[sID] == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TAX_RATES could not find ' + sID, this.TAX_RATES);
			return sID;
		}
		return this.TAX_RATES[sID];
	}

	Discounts(sID: string)
	{
		if ( this.DISCOUNTS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DISCOUNTS is null, ' + sID);
			return null;
		}
		else if ( this.DISCOUNTS[sID] == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DISCOUNTS could not find ' + sID, this.DISCOUNTS);
			return sID;
		}
		return this.DISCOUNTS[sID];
	}

	// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
	Timezones(sID: string)
	{
		if ( this.TIMEZONES == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TIMEZONES is null, ' + sID);
			return null;
		}
		else if ( this.TIMEZONES[sID] == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TIMEZONES could not find ' + sID, this.TIMEZONES);
			return sID;
		}
		return this.TIMEZONES[sID];
	}

	// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
	Currencies(sID: string)
	{
		if ( this.CURRENCIES == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: CURRENCIES is null, ' + sID);
			return null;
		}
		else if ( this.CURRENCIES[sID] == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: CURRENCIES could not find ' + sID, this.CURRENCIES);
			return sID;
		}
		return this.CURRENCIES[sID];
	}

	// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
	Languages(sID: string)
	{
		if ( this.LANGUAGES == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: LANGUAGES is null, ' + sID);
			return null;
		}
		else if ( this.LANGUAGES[sID] == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: LANGUAGES could not find ' + sID, this.LANGUAGES);
			return sID;
		}
		return this.LANGUAGES[sID];
	}

	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	Favorites(sMODULE_NAME: string)
	{
		if ( this.FAVORITES == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: FAVORITES is null, ' + sMODULE_NAME);
			return null;
		}
		return this.FAVORITES[sMODULE_NAME];
	}

	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	LastViewed(sMODULE_NAME: string)
	{
		if ( this.LAST_VIEWED == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: LAST_VIEWED is null, ' + sMODULE_NAME);
			return null;
		}
		return this.LAST_VIEWED[sMODULE_NAME];
	}

	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	DefaultSavedSearch(sMODULE_NAME: string): any
	{
		if ( this.SAVED_SEARCH == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: SAVED_SEARCH is null, ' + sMODULE_NAME);
			return null;
		}
		// 05/08/2019 Paul.  Each module can have a collection of saved searches.  The default has NAME == null. 
		else if ( this.SAVED_SEARCH[sMODULE_NAME] != null )
		{
			for ( let i = 0; i < this.SAVED_SEARCH[sMODULE_NAME].length; i++ )
			{
				if ( Sql.IsEmptyString(this.SAVED_SEARCH[sMODULE_NAME][i]['NAME']) )
				{
					return this.SAVED_SEARCH[sMODULE_NAME][i];
				}
			}
		}
		return null;
	}

	UpdateTeamHierarchy = async (team) =>
	{
		let sTEAM_NAME: string = null;
		let sTEAM_ID  : string = null;
		if ( team != null )
		{
			sTEAM_NAME = team.NAME;
			sTEAM_ID   = team.ID  ;
		}
		let objSavedSearch: any = 
		{
			SavedSearch: 
			{
				SearchFields:
				{
					Field:
					[
						{ '@Name': 'NAME', '@Type': 'TextBox', Value: sTEAM_NAME},
						{ '@Name': 'ID'  , '@Type': 'TextBox', Value: sTEAM_ID  }
					]
				}
			}
		};
		// https://www.npmjs.com/package/fast-xml-parser
		let options: any = 
		{
			attributeNamePrefix: '@',
			textNodeName       : 'Value',
			ignoreAttributes   : false,
			ignoreNameSpace    : true ,
			parseAttributeValue: true ,
			trimValues         : false,
			format             : true,
			// 02/17/2024 Paul.  parser v4 requires suppressBooleanAttributes, otherwise Visible does not include ="true"
			allowBooleanAttributes: true,
			suppressBooleanAttributes: false,
		};
		// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
		const builder = new XMLBuilder(options);
		let sXML: string = '<?xml version="1.0" encoding="UTF-8"?>' + builder.build(objSavedSearch);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClickTeam', sXML);

		// 01/12/202- Paul.  Before resetting, update the cached version. 
		let gID: string = null;
		let teamHierarchy = this.SavedSearches(TeamHierarchyModule);
		if ( teamHierarchy != null && teamHierarchy.length > 0 )
		{
			let search = teamHierarchy[0];
			gID = search.ID;
			search.CONTENTS = sXML;
		}
		await UpdateSavedSearch(gID, TeamHierarchyModule, sXML, null, null);
		this.UpdateDefaultSavedSearch(TeamHierarchyModule, sXML, null);
		this.nTeamHierarchyCounter++;
	}

	// 08/10/2020 Paul.  Incorrect spelling of DEFAULT_SEARCH_ID caused failure. 
	UpdateDefaultSavedSearch(sMODULE_NAME: string, CONTENTS: string, DEFAULT_SEARCH_ID: string)
	{
		if ( this.SAVED_SEARCH == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: SAVED_SEARCH is null, ' + sMODULE_NAME);
			return null;
		}
		if ( this.SAVED_SEARCH[sMODULE_NAME] == null )
		{
			this.SAVED_SEARCH[sMODULE_NAME] = [];
		}
		let search: any = this.DefaultSavedSearch(sMODULE_NAME);
		if ( search != null )
		{
			search.CONTENTS = CONTENTS;
			search.DEFAULT_SEARCH_ID = DEFAULT_SEARCH_ID;
		}
		else
		{
			search = {};
			search.ID = null;
			search.NAME = null;
			search.CONTENTS = CONTENTS;
			search.DEFAULT_SEARCH_ID = DEFAULT_SEARCH_ID;
			this.SAVED_SEARCH[sMODULE_NAME].unshift(search);
		}
	}

	// 05/08/2019 Paul.  Return collection of saved searches per module. 
	SavedSearches(sMODULE_NAME: string): any
	{
		if ( this.SAVED_SEARCH == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: SAVED_SEARCH is null, ' + sMODULE_NAME);
			return null;
		}
		// 05/08/2019 Paul.  Each module can have a collection of saved searches.  The default has NAME == null. 
		return this.SAVED_SEARCH[sMODULE_NAME];
	}

	GetSavedSearch(sMODULE_NAME: string, sID: string): any
	{
		if ( this.SAVED_SEARCH == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: SAVED_SEARCH is null, ' + sMODULE_NAME);
			return null;
		}
		// 05/08/2019 Paul.  Each module can have a collection of saved searches.  The default has NAME == null. 
		else if ( this.SAVED_SEARCH[sMODULE_NAME] != null )
		{
			for ( let i = 0; i < this.SAVED_SEARCH[sMODULE_NAME].length; i++ )
			{
				let objSearch = this.SAVED_SEARCH[sMODULE_NAME][i];
				if ( sID == objSearch.ID )
				{
					return objSearch;
				}
			}
		}
		return null;
	}

	GetSelectedTeamHierarchy()
	{
		let currentTeamID  : string = null;
		let currentTeamName: string = null;
		let teamHierarchy = this.SavedSearches('TeamHierarchy');
		if ( teamHierarchy != null && teamHierarchy.length > 0 )
		{
			let search = teamHierarchy[0];
			if ( search != null && !Sql.IsEmptyString(search.CONTENTS) && StartsWith(search.CONTENTS, '<?xml') )
			{
				// https://www.npmjs.com/package/fast-xml-parser
				let options: any = 
				{
					attributeNamePrefix: '',
					textNodeName       : 'Value',
					ignoreAttributes   : false,
					ignoreNameSpace    : true,
					parseAttributeValue: true,
					trimValues         : false,
				};
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				const parser = new XMLParser(options);
				let xml = parser.parse(search.CONTENTS);
				if ( xml.SavedSearch != null && xml.SavedSearch.SearchFields !== undefined && xml.SavedSearch.SearchFields != null )
				{
					let xSearchFields = xml.SavedSearch.SearchFields;
					if ( xSearchFields.Field !== undefined && xSearchFields.Field != null )
					{
						let xFields: any = xSearchFields.Field;
						if ( Array.isArray(xFields) )
						{
							for ( let i = 0; i < xFields.length; i++ )
							{
								let xField = xFields[i];
								if ( xField.Name == 'ID' )
								{
									currentTeamID = xField.Value;
								}
								else if ( xField.Name == 'NAME' )
								{
									currentTeamName = xField.Value;
								}
							}
						}
					}
				}
			}
		}
		let team: any = null;
		// 02/03/2020 Paul.  Make sure to use IsEmptyGuid as value may be 00000000-0000-0000-0000-000000000000. 
		if ( !Sql.IsEmptyGuid(currentTeamID) )
		{
			team = this.Team(currentTeamID);
		}
		return team;
	}

	AddSavedSearch(sMODULE_NAME: string, sID: string, search: any)
	{
		if ( this.SAVED_SEARCH == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: SAVED_SEARCH is null, ' + sMODULE_NAME);
			return null;
		}
		if ( this.SAVED_SEARCH[sMODULE_NAME] == null )
		{
			this.SAVED_SEARCH[sMODULE_NAME] = [];
		}
		// 05/13/2019 Paul.  Just add to the end instead of trying to sort the list. 
		this.SAVED_SEARCH[sMODULE_NAME].push(sID, search);
	}

	RemoveSavedSearch(sMODULE_NAME: string, sID: string)
	{
		if ( this.SAVED_SEARCH == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: SAVED_SEARCH is null, ' + sMODULE_NAME);
			return null;
		}
		else if ( this.SAVED_SEARCH[sMODULE_NAME] != null )
		{
			for ( let i = 0; i < this.SAVED_SEARCH[sMODULE_NAME].length; i++ )
			{
				let objSearch = this.SAVED_SEARCH[sMODULE_NAME][i];
				if ( sID == objSearch.ID )
				{
					// 05/15/2019 Paul.  splice to modify list in-place. 
					this.SAVED_SEARCH[sMODULE_NAME].splice(i, 1);
					break;
				}
			}
		}
	}

	// 05/10/2019 Paul.  Saved search needs to know the available columns. 
	ModuleColumns(sMODULE_NAME: string): any
	{
		if ( this.MODULE_COLUMNS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: MODULE_COLUMNS is null, ' + sMODULE_NAME);
			return null;
		}
		else if ( this.MODULE_COLUMNS[sMODULE_NAME] == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: MODULE_COLUMNS could not find ' + sMODULE_NAME, this.MODULE_COLUMNS);
		}
		//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: MODULE_COLUMNS for ' + sMODULE_NAME, this.MODULE_COLUMNS[sMODULE_NAME]);
		return this.MODULE_COLUMNS[sMODULE_NAME];
	}

	// 02/25/2019 Paul.  New method to fetch the React Custom Views. 
	ReactCustomViews(sMODULE_NAME: string, sLAYOUT_TYPE: string, sVIEW_NAME: string)
	{
		if ( this.REACT_CUSTOM_VIEWS && this.REACT_CUSTOM_VIEWS[sMODULE_NAME] && this.REACT_CUSTOM_VIEWS[sMODULE_NAME][sLAYOUT_TYPE] && this.REACT_CUSTOM_VIEWS[sMODULE_NAME][sLAYOUT_TYPE][sVIEW_NAME] )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: REACT_CUSTOM_VIEWS found ' + sLAYOUT_TYPE + ' ' + sMODULE_NAME + '.' + sVIEW_NAME);
			return this.REACT_CUSTOM_VIEWS[sMODULE_NAME][sLAYOUT_TYPE][sVIEW_NAME];
		}
		return null;
	}

	// 02/28/2019 Chase.  New method to fetch the compiled React Custom Views. 
	CompiledCustomViews(sMODULE_NAME: string, sLAYOUT_TYPE: string, sVIEW_NAME: string)
	{
		if ( this.COMPILED_CUSTOM_VIEWS && this.COMPILED_CUSTOM_VIEWS[sMODULE_NAME] && this.COMPILED_CUSTOM_VIEWS[sMODULE_NAME][sLAYOUT_TYPE] && this.COMPILED_CUSTOM_VIEWS[sMODULE_NAME][sLAYOUT_TYPE][sVIEW_NAME] )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: COMPILED_CUSTOM_VIEWS found ' + sLAYOUT_TYPE + ' ' + sMODULE_NAME + '.' + sVIEW_NAME);
			return this.COMPILED_CUSTOM_VIEWS[sMODULE_NAME][sLAYOUT_TYPE][sVIEW_NAME];
		}
		return null;
	}

	// 02/28/2019 Chase. New method to store the compiled React Custom Views.
	SetCompiledCustomView(sMODULE_NAME: string, sLAYOUT_TYPE: string, sVIEW_NAME: string, view)
	{
		if ( this.COMPILED_CUSTOM_VIEWS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: COMPILED_CUSTOM_VIEWS is null');
			return null;
		}
		if ( this.COMPILED_CUSTOM_VIEWS[sMODULE_NAME] == null )
		{
			this.COMPILED_CUSTOM_VIEWS[sMODULE_NAME] = new Object();
		}
		if ( this.COMPILED_CUSTOM_VIEWS[sMODULE_NAME][sLAYOUT_TYPE] == null )
		{
			this.COMPILED_CUSTOM_VIEWS[sMODULE_NAME][sLAYOUT_TYPE] = new Object();
		}
		this.COMPILED_CUSTOM_VIEWS[sMODULE_NAME][sLAYOUT_TYPE][sVIEW_NAME] = view;
	}

	ReactDashlets(sDASHLET_NAME: string)
	{
		if ( this.REACT_DASHLETS && this.REACT_DASHLETS[sDASHLET_NAME] )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: REACT_DASHLETS found ' + sDASHLET_NAME);
			return this.REACT_DASHLETS[sDASHLET_NAME];
		}
		return null;
	}

	// 03/01/2019 Paul.  New method to fetch the compiled React Custom Views. 
	CompiledDashlets(sDASHLET_NAME: string)
	{
		if ( this.COMPILED_DASHLETS && this.COMPILED_DASHLETS[sDASHLET_NAME] )
		{
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: COMPILED_DASHLETS found, ' + sDASHLET_NAME);
			return this.COMPILED_DASHLETS[sDASHLET_NAME];
		}
		return null;
	}

	// 03/01/2019 Paul. New method to store the compiled React Custom Views.
	SetCompiledDashlet(sDASHLET_NAME: string, dashlet)
	{
		if ( this.COMPILED_DASHLETS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: COMPILED_DASHLETS is null');
			return null;
		}
		this.COMPILED_DASHLETS[sDASHLET_NAME] = dashlet;
	}

	// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	SetGridViews(GRID_NAME: string, data)
	{
		if ( this.GRIDVIEWS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: GRIDVIEWS is null');
			return null;
		}
		this.GRIDVIEWS[GRID_NAME] = data;
	}

	SetGridViewColumns(GRID_NAME: string, data)
	{
		if ( this.GRIDVIEWS_COLUMNS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: GRIDVIEWS_COLUMNS is null');
			return null;
		}
		this.GRIDVIEWS_COLUMNS[GRID_NAME] = data;
	}

	SetDetailViewFields(sDETAIL_NAME: string, data)
	{
		if ( this.DETAILVIEWS_FIELDS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DETAILVIEWS_FIELDS is null');
			return null;
		}
		this.DETAILVIEWS_FIELDS[sDETAIL_NAME] = data;
	}

	SetEditViewFields(sEDIT_NAME: string, data)
	{
		if ( this.EDITVIEWS_FIELDS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: EDITVIEWS_FIELDS is null');
			return null;
		}
		this.EDITVIEWS_FIELDS[sEDIT_NAME] = data;
	}

	SetDetailViewRelationships(sDETAIL_NAME: string, data)
	{
		if ( this.DETAILVIEWS_RELATIONSHIPS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DETAILVIEWS_RELATIONSHIPS is null');
			return null;
		}
		this.DETAILVIEWS_RELATIONSHIPS[sDETAIL_NAME] = data;
	}

	// 02/16/2016 Paul.  Add EditView Relationships for the new layout editor. 
	SetEditViewRelationships(sEDIT_NAME: string, data)
	{
		if ( this.EDITVIEWS_RELATIONSHIPS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: EDITVIEWS_RELATIONSHIPS is null');
			return null;
		}
		this.EDITVIEWS_RELATIONSHIPS[sEDIT_NAME] = data;
	}

	SetDynamicButtons(sVIEW_NAME: string, data)
	{
		if ( this.DYNAMIC_BUTTONS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DYNAMIC_BUTTONS is null');
			return null;
		}
		this.DYNAMIC_BUTTONS[sVIEW_NAME] = data;
	}

	SetTerm(sMODULE_NAME: string, sNAME: string, sDISPLAY_NAME: string)
	{
		if ( this.TERMINOLOGY == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY is null');
			return null;
		}
		if ( sMODULE_NAME == null )
		{
			sMODULE_NAME = '';
		}
		this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + sMODULE_NAME + '.' + sNAME] = sDISPLAY_NAME;
	}

	SetListTerm(sLIST_NAME: string, sNAME: string, sDISPLAY_NAME: string)
	{
		if ( this.TERMINOLOGY == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY is null');
			return null;
		}
		if ( this.TERMINOLOGY_LISTS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY_LISTS is null');
			return null;
		}
		this.TERMINOLOGY[Credentials.sUSER_LANG + '.' + '.' + sLIST_NAME + '.' + sNAME] = sDISPLAY_NAME;
		if ( this.TERMINOLOGY_LISTS[Credentials.sUSER_LANG + '.' + sLIST_NAME] == null )
		{
			this.TERMINOLOGY_LISTS[Credentials.sUSER_LANG + '.' + sLIST_NAME] = new Array();
		}
		this.TERMINOLOGY_LISTS[Credentials.sUSER_LANG + '.' + sLIST_NAME].push(sNAME);
	}

	AddLastViewed(sMODULE_NAME: string, sID: string, sNAME: string)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: AddLastViewed', sMODULE_NAME, sID, sNAME);
		if ( this.LAST_VIEWED == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: LAST_VIEWED is null');
			return null;
		}
		if ( this.LAST_VIEWED[sMODULE_NAME] == null )
		{
			this.LAST_VIEWED[sMODULE_NAME] = new Array();
		}
		if ( sNAME.length > 25 )
		{
			sNAME = sNAME.substr(0, 25) + '...';
		}
		for ( let i = this.LAST_VIEWED[sMODULE_NAME].length - 1; i >= 0; i-- )
		{
			let item = this.LAST_VIEWED[sMODULE_NAME][i];
			if ( item.ID == sID )
			{
				this.LAST_VIEWED[sMODULE_NAME].splice(i, 1);
			}
		}
		let item = { ID: sID, NAME: sNAME };
		// 11/25/2020 Paul.  Unshift so that newest item is at the top of the list. This was preventing latest item from being visible immediately. 
		this.LAST_VIEWED[sMODULE_NAME].unshift(item);

		// 11/25/2020 Paul.  Trim list as items are added. 
		let history_max_viewed: number = Crm_Config.ToInteger('history_max_viewed');
		if ( history_max_viewed == 0 )
		{
			history_max_viewed = 10;
		}
		if ( this.LAST_VIEWED[sMODULE_NAME].length > history_max_viewed )
		{
			let arr = new Array();
			for ( let i = 0; i < history_max_viewed && i < this.LAST_VIEWED[sMODULE_NAME].length; i++ )
			{
				arr.push(this.LAST_VIEWED[sMODULE_NAME][i]);
			}
			this.LAST_VIEWED[sMODULE_NAME] = arr;

		}
		// 04/29/2019 Paul.  When FAVORITES, LAST_VIEWED or SAVED_SEARCH changes, increment this number.  It is watched in the TopNav. 
		this.NAV_MENU_CHANGE++;
	}

	// 07/21/2019 Paul.  We need UserAccess control for buttons. 
	SetMODULE_ACL_ACCESS(obj)
	{
		this.MODULE_ACL_ACCESS = obj;
	}

	SetACL_ACCESS(obj)
	{
		this.ACL_ACCESS = obj;
	}

	SetACL_FIELD_ACCESS(obj)
	{
		this.ACL_FIELD_ACCESS = obj;
	}

	// 01/22/2021 Paul.  Some customizations may be dependent on role name. 
	SetACL_ROLES(obj)
	{
		this.ACL_ROLES = obj;
	}

	// 05/12/2018 Paul.  React requires setters. 
	SetTAB_MENU(obj)
	{
		this.TAB_MENU = obj;
	}

	SetMODULES(obj)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SplendidCache.SetMODULES', obj);
		this.MODULES = obj;
	}

	SetCONFIG(obj)
	{
		this.CONFIG = obj;
		// 07/22/2019 Paul.  Field level security may not be enabled. 
		if ( obj != null )
		{
			this.bEnableACLFieldSecurity = Sql.ToBoolean(this.CONFIG['bEnableACLFieldSecurity']);
		}
	}

	// 10/26/2019 Paul.  Admin needs to be able to change config values instead of reloading the entire table. 
	SetConfigValue(sNAME, oVALUE)
	{
		// 03/24/2021 Paul.  Don't set if too early in the loading process. 
		if ( this.CONFIG != null )
		{
			this.CONFIG[sNAME] = oVALUE;
		}
	}

	SetTEAMS(obj)
	{
		this.TEAMS = obj;
	}

	SetUSERS(obj)
	{
		this.USERS = obj;
	}

	// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
	SetGRIDVIEWS(obj)
	{
		this.GRIDVIEWS = obj;
	}

	SetGRIDVIEWS_COLUMNS(obj)
	{
		this.GRIDVIEWS_COLUMNS = obj;
	}

	SetDETAILVIEWS_FIELDS(obj)
	{
		this.DETAILVIEWS_FIELDS = obj;
	}

	SetEDITVIEWS_FIELDS(obj)
	{
		this.EDITVIEWS_FIELDS = obj;
	}

	SetDETAILVIEWS_RELATIONSHIPS(obj)
	{
		this.DETAILVIEWS_RELATIONSHIPS = obj;
	}

	SetEDITVIEWS_RELATIONSHIPS(obj)
	{
		this.EDITVIEWS_RELATIONSHIPS = obj;
	}

	SetDYNAMIC_BUTTONS(obj)
	{
		this.DYNAMIC_BUTTONS = obj;
	}

	// 08/15/2019 Paul.  Add support for menu shortcuts. 
	SetSHORTCUTS(obj)
	{
		this.SHORTCUTS = obj;
	}

	SetTERMINOLOGY_LISTS(obj)
	{
		// 12/10/2022 Paul.  Allow Login Terminology Lists to be customized. 
		this.TERMINOLOGY_LISTS = obj ? obj : {};
	}

	SetTERMINOLOGY(obj)
	{
		this.TERMINOLOGY = obj;
	}

	// 07/01/2019 Paul.  The SubPanelsView needs to understand how to manage all relationships. 
	SetRELATIONSHIPS(obj)
	{
		this.RELATIONSHIPS = obj;
	}

	SetTAX_RATES(obj)
	{
		this.TAX_RATES = obj;
	}

	SetDISCOUNTS(obj)
	{
		this.DISCOUNTS = obj;
	}

	// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
	SetTIMEZONES(obj)
	{
		this.TIMEZONES = obj;
	}

	SetCURRENCIES(obj)
	{
		this.CURRENCIES = obj;
	}

	SetLANGUAGES(obj)
	{
		this.LANGUAGES = obj;
	}

	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	SetFAVORITES(obj)
	{
		this.FAVORITES = obj;
	}

	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	SetLAST_VIEWED(obj)
	{
		this.LAST_VIEWED = obj;
	}

	// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
	SetSAVED_SEARCH(obj)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SetSAVED_SEARCH', obj);
		this.SAVED_SEARCH = obj;
	}

	// 05/10/2019 Paul.  Saved search needs to know the available columns. 
	SetMODULE_COLUMNS(obj)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SetMODULE_COLUMNS', obj);
		this.MODULE_COLUMNS = obj;
	}

	// 02/25/2019 Paul.  New method to fetch the React Custom Views. 
	SetREACT_CUSTOM_VIEWS(obj)
	{
		// 12/07/2022 Paul.  Allow the LoginView to be customized. 
		this.REACT_CUSTOM_VIEWS = obj ? obj : {};
		// 03/01/2019 Paul.  Clear compiled views. 
		this.COMPILED_CUSTOM_VIEWS = new Object();
		this.REACT_DASHLETS = obj ? obj['Dashlets'] : {};
		this.COMPILED_DASHLETS = new Object();
	}

	SetADMIN_MENU(obj)
	{
		this.ADMIN_MENU = obj;
	}

	SetDASHBOARDS(obj)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SetDASHBOARDS', obj);
		this.DASHBOARDS = obj;
	}

	GetDashboards(sCATEGORY): any
	{
		if ( this.DASHBOARDS == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DASHBOARDS is null');
			return null;
		}
		return this.DASHBOARDS[sCATEGORY];
	}

	SetDashboards(sCATEGORY, rows)
	{
		if ( this.DASHBOARDS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DASHBOARDS is null');
			return null;
		}
		this.DASHBOARDS[sCATEGORY] = rows;
		this.NAV_MENU_CHANGE++;
	}

	// 06/08/2021 Paul.  If no dashboards exist, it could be because they were deleted for this category, so remove from list. 
	DeleteDashboardCategory(sCATEGORY)
	{
		if ( this.DASHBOARDS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DASHBOARDS is null');
			return null;
		}
		if ( this.DASHBOARDS[sCATEGORY] !== undefined )
			delete this.DASHBOARDS[sCATEGORY];
		this.NAV_MENU_CHANGE++;
	}

	// 06/08/2021 Paul.  If no dashboards exist, it could be because they were deleted for this category, so remove from list. 
	DeleteDashboard(sCATEGORY, ID)
	{
		if ( this.DASHBOARDS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DASHBOARDS is null');
			return null;
		}
		if ( this.DASHBOARDS[sCATEGORY] !== undefined )
		{
			let rows: any[] = this.DASHBOARDS[sCATEGORY];
			if ( rows[ID] !== undefined )
			{
				delete rows[ID];
				this.DeleteDashboardPanels(ID);
			}
		}
		this.NAV_MENU_CHANGE++;
	}

	SetDASHBOARDS_PANELS(obj)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SetDASHBOARDS_PANELS', obj);
		this.DASHBOARDS_PANELS = obj;
	}

	GetDashboardPanels(sDASHBOARD_ID: string): any
	{
		if ( this.DASHBOARDS_PANELS == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DASHBOARDS_PANELS is null, ' + sDASHBOARD_ID);
			return null;
		}
		return this.DASHBOARDS_PANELS[sDASHBOARD_ID];
	}

	SetDashboardPanels(sDASHBOARD_ID: string, arrPANELS): any
	{
		if ( this.DASHBOARDS_PANELS == null )
		{
			this.DASHBOARDS_PANELS = new Object();
		}
		this.DASHBOARDS_PANELS[sDASHBOARD_ID] = arrPANELS;
	}

	// 06/08/2021 Paul.  If no dashboards exist, it could be because they were deleted for this category, so remove from list. 
	DeleteDashboardPanels(sDASHBOARD_ID: string): any
	{
		if ( this.DASHBOARDS_PANELS == null )
		{
			this.DASHBOARDS_PANELS = new Object();
		}
		if ( this.DASHBOARDS_PANELS[sDASHBOARD_ID] !== undefined )
			delete this.DASHBOARDS_PANELS[sDASHBOARD_ID];
	}

	// 05/03/2020 Paul.  Emails.EditView should use cached list of signatures. 
	SetSIGNATURES(obj)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SetSIGNATURES', obj);
		this.SIGNATURES = obj;
	}

	GetPrimarySignature(): any
	{
		if ( this.SIGNATURES == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: SIGNATURES is null');
			return null;
		}
		// 05/03/2020 Paul.  Loop through all and end when primary found.  Sort is effectively by json key. 
		let signature: any = null;
		for ( let sSIGNATURE_ID in this.SIGNATURES )
		{
			signature = this.SIGNATURES[sSIGNATURE_ID];
			if ( Sql.ToBoolean(signature['PRIMARY_SIGNATURE']) )
			{
				break;
			}
		}
		return signature;
	}

	GetSignature(ID): any
	{
		if ( this.SIGNATURES == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: SIGNATURES is null');
			return null;
		}
		return this.SIGNATURES[ID];
	}

	// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundMail. 
	SetOUTBOUND_EMAILS(obj)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SetOUTBOUND_EMAILS', obj);
		this.OUTBOUND_EMAILS = obj;
	}

	GetOutboundMail(ID): any
	{
		if ( this.OUTBOUND_EMAILS == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: OUTBOUND_EMAILS is null');
			return null;
		}
		return this.OUTBOUND_EMAILS[ID];
	}

	// 05/03/2020 Paul.  Emails.EditView should use cached list of OutboundSms. 
	SetOUTBOUND_SMS(obj)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SetOUTBOUND_SMS', obj);
		this.OUTBOUND_SMS = obj;
	}

	GetOutboundSms(ID): any
	{
		if ( this.OUTBOUND_SMS == null )
		{
			//console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: OUTBOUND_SMS is null');
			return null;
		}
		return this.OUTBOUND_SMS[ID];
	}

	// 07/21/2019 Paul.  We need UserAccess control for buttons. 
	GetUserAccess(sMODULE_NAME: string , sACCESS_TYPE: string, sCaller?: string): number
	{
		if ( this.MODULE_ACL_ACCESS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: MODULE_ACL_ACCESS is null, ' + sMODULE_NAME + ' ' + sACCESS_TYPE, jsonReactState);
			return ACL_ACCESS.NONE;
		}
		if ( Sql.IsEmptyString(sMODULE_NAME) )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: MODULE_NAME not specified for ' + sACCESS_TYPE + ' from ' + sCaller);
			return ACL_ACCESS.NONE;
		}
		// 12/14/2019 Paul.  Home is not returned from vwACL_ACCESS_ByModule as everyone is expected to have access to home. 
		if ( sMODULE_NAME == 'Home' )
		{
			return ACL_ACCESS.FULL_ACCESS;
		}
		else if ( this.MODULE_ACL_ACCESS[sMODULE_NAME] == null )
		{
			// 04/17/2020 Paul.  Ignore Employee access errors if the module is disabled. 
			if ( this.Module(sMODULE_NAME) != null )
				console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: MODULE_ACL_ACCESS could not find ' + sMODULE_NAME + ' ' + sACCESS_TYPE, jsonReactState);
			return ACL_ACCESS.NONE;
		}

		if ( this.ACL_ACCESS == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: ACL_ACCESS is null, ' + sMODULE_NAME + ' ' + sACCESS_TYPE, jsonReactState);
			return ACL_ACCESS.NONE;
		}
		if ( this.ACL_ACCESS[sMODULE_NAME] == null )
		{
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: ACL_ACCESS could not find ' + sMODULE_NAME + ' ' + sACCESS_TYPE, jsonReactState);
			return ACL_ACCESS.NONE;
		}

		let bIsAdmin = Security.IS_ADMIN();
		if ( bIsAdmin )
		{
			// 04/21/2016 Paul.  We need to make sure that disabled modules do not show related buttons. 
			if ( this.Module(sMODULE_NAME) != null )
				return ACL_ACCESS.FULL_ACCESS;
			else
				return ACL_ACCESS.NONE;  // 08/10/2017 Paul.  We need to return a negative number to prevent access, not zero. 
		}
		
		// 12/05/2006 Paul.  We need to combine Activity and Calendar related modules into a single access value. 
		let nACLACCESS = 0;
		// 08/10/2017 Paul.  We need to return a negative number to prevent access, not zero. 
		if ( this.Module(sMODULE_NAME) == null )
		{
			nACLACCESS = ACL_ACCESS.NONE;
		}
		else if ( sMODULE_NAME == "Calendar" )
		{
			// 12/05/2006 Paul.  The Calendar related views only combine Calls and Meetings. 
			let nACLACCESS_Calls    = this.GetUserAccess("Calls"   , sACCESS_TYPE);
			let nACLACCESS_Meetings = this.GetUserAccess("Meetings", sACCESS_TYPE);
			// 12/05/2006 Paul. Use the max value so that the Activities will be displayed if either are accessible. 
			nACLACCESS = Math.max(nACLACCESS_Calls, nACLACCESS_Meetings);
		}
		else if ( sMODULE_NAME == "Activities" )
		{
			// 12/05/2006 Paul.  The Activities combines Calls, Meetings, Tasks, Notes and Emails. 
			let nACLACCESS_Calls    = this.GetUserAccess("Calls"   , sACCESS_TYPE);
			let nACLACCESS_Meetings = this.GetUserAccess("Meetings", sACCESS_TYPE);
			let nACLACCESS_Tasks    = this.GetUserAccess("Tasks"   , sACCESS_TYPE);
			let nACLACCESS_Notes    = this.GetUserAccess("Notes"   , sACCESS_TYPE);
			let nACLACCESS_Emails   = this.GetUserAccess("Emails"  , sACCESS_TYPE);
			nACLACCESS = nACLACCESS_Calls;
			nACLACCESS = Math.max(nACLACCESS, nACLACCESS_Meetings);
			nACLACCESS = Math.max(nACLACCESS, nACLACCESS_Tasks   );
			nACLACCESS = Math.max(nACLACCESS, nACLACCESS_Notes   );
			nACLACCESS = Math.max(nACLACCESS, nACLACCESS_Emails  );
		}
		else
		{
			// 04/27/2006 Paul.  If no specific level is provided, then look to the Module level. 
			if ( this.ACL_ACCESS[sMODULE_NAME][sACCESS_TYPE] == null )
			{
				nACLACCESS = Sql.ToInteger(this.MODULE_ACL_ACCESS[sMODULE_NAME][sACCESS_TYPE]);
			}
			else
			{
				nACLACCESS = Sql.ToInteger(this.ACL_ACCESS[sMODULE_NAME][sACCESS_TYPE]);
			}
			if ( sACCESS_TYPE != "access" && nACLACCESS >= 0 )
			{
				// 04/27/2006 Paul.  The access type can over-ride any other type. 
				// A simple trick is to take the minimum of the two values.  
				// If either value is denied, then the result will be negative. 
				let nAccessLevel: number = 0;
				if ( this.ACL_ACCESS[sMODULE_NAME]['access'] == null )
				{
					nAccessLevel = Sql.ToInteger(this.MODULE_ACL_ACCESS[sMODULE_NAME]['access']);
				}
				else
				{
					nAccessLevel = Sql.ToInteger(this.ACL_ACCESS[sMODULE_NAME]['access']);
				}
				if ( nAccessLevel < 0 )
				{
					nACLACCESS = nAccessLevel;
				}
			}
		}
		return nACLACCESS;
	}

	GetRecordAccess(row: any, sMODULE_NAME: string , sACCESS_TYPE: string, sASSIGNED_USER_ID_FIELD: string): number
	{
		// 11/03/2017 Paul.  Remove is the same as edit.  We don't want to define another select field. 
		if ( sACCESS_TYPE == "remove" )
			sACCESS_TYPE = "edit";
		let nACLACCESS: number = this.GetUserAccess(sMODULE_NAME, sACCESS_TYPE, 'SplendidCache.GetRecordAccess');
		if ( row != null )
		{
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();
			if ( nACLACCESS == ACL_ACCESS.OWNER )
			{
				// 10/31/2017 Paul.  Don't check if sASSIGNED_USER_ID_FIELD exists in table because this is a coding error that we want to catch. 
				if ( !Sql.IsEmptyString(sASSIGNED_USER_ID_FIELD) )
				{
					// 01/24/2018 Paul.  sASSIGNED_USER_ID_FIELD is either ASSIGNED_USER_ID or CREATED_BY_ID. 
					let sASSIGNED_SET_LIST_FIELD: string = "ASSIGNED_SET_LIST";
					if ( bEnableDynamicAssignment && (sASSIGNED_USER_ID_FIELD == "ASSIGNED_USER_ID") && row.hasOwnProperty(sASSIGNED_SET_LIST_FIELD) )
					{
						let sASSIGNED_SET_LIST: string = Sql.ToString(row[sASSIGNED_SET_LIST_FIELD]).ToUpper();
						if ( sASSIGNED_SET_LIST.indexOf(Security.USER_ID()) < 0 && !Sql.IsEmptyString(sASSIGNED_SET_LIST) )
							nACLACCESS = ACL_ACCESS.NONE;
					}
					else
					{
						let gASSIGNED_USER_ID: string = Sql.ToGuid(row[sASSIGNED_USER_ID_FIELD]);
						if ( Security.USER_ID() != gASSIGNED_USER_ID && gASSIGNED_USER_ID != null )
							nACLACCESS = ACL_ACCESS.NONE;
					}
				}
			}
			// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
			let module:MODULE = this.Module(sMODULE_NAME);
			if ( module && Sql.ToBoolean(module.RECORD_LEVEL_SECURITY_ENABLED) )
			{
				// 10/31/2017 Paul.  FULL_ACCESS means that this is an Admin and Record ACL does not apply. 
				if ( nACLACCESS >= 0 && nACLACCESS < ACL_ACCESS.FULL_ACCESS )
				{
					let sRECORD_ACL_FIELD_NAME: string = "RECORD_LEVEL_SECURITY_" + sACCESS_TYPE.toUpperCase();
					// 10/31/2017 Paul.  Check if field exists because it is dynamically injected. 
					if ( row.hasOwnProperty(sRECORD_ACL_FIELD_NAME) )
					{
						// 10/31/2017 Paul.  Record ACL only applies if it takes away rights. 
						let nRECORD_ACLACCESS: number = Sql.ToInteger(row[sRECORD_ACL_FIELD_NAME]);
						if ( nRECORD_ACLACCESS < nACLACCESS )
							nACLACCESS = nRECORD_ACLACCESS;
					}
				}
			}
		}
		return nACLACCESS;
	}

	AdminUserAccess(sMODULE_NAME: string, sACCESS_TYPE: string, gASSIGNED_USER_ID?: string)
	{
		if ( Security.IS_ADMIN() )
			return ACL_ACCESS.ALL;
		let nACLACCESS: number = ACL_ACCESS.NONE;
		let bAllowAdminRoles: boolean = this.Config('allow_admin_roles');
		if ( bAllowAdminRoles )
		{
			if ( Security.IS_ADMIN_DELEGATE() )
			{
				nACLACCESS = this.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
			}
		}
		if ( !Sql.IsEmptyString(gASSIGNED_USER_ID) && nACLACCESS == ACL_ACCESS.OWNER && Security.USER_ID() != gASSIGNED_USER_ID )
		{
			nACLACCESS = ACL_ACCESS.NONE;
		}
		return nACLACCESS;
	}
		
	GetUserFieldSecurity(sMODULE_NAME: string, sFIELD_NAME: string): number
	{
		let nACLACCESS: number = ACL_FIELD_ACCESS.FULL_ACCESS;
		if ( this.bEnableACLFieldSecurity )
		{
			if ( this.ACL_FIELD_ACCESS == null )
			{
				console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: ACL_FIELD_ACCESS is null, ' + sMODULE_NAME + ' ' + sFIELD_NAME);
				return nACLACCESS;
			}
			if ( this.ACL_FIELD_ACCESS[sMODULE_NAME] == null )
			{
				// 07/23/2019 Paul.  If module not found, then there is no positive or negative rules, so the default is full access. 
				return nACLACCESS;
			}
			nACLACCESS = Sql.ToInteger(this.ACL_FIELD_ACCESS[sMODULE_NAME][sFIELD_NAME]);
			// 01/17/2010 Paul.  Zero is a special value that means NOT_SET, so grant full access. 
			if ( nACLACCESS == 0 )
			{
				nACLACCESS = ACL_FIELD_ACCESS.FULL_ACCESS;
			}
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: ACL_FIELD_ACCESS Found ' + sMODULE_NAME + ' ' + sFIELD_NAME, nACLACCESS);
		}
		return nACLACCESS;
	}

	// 01/22/2021 Paul.  Some customizations may be dependent on role name. 
	GetACLRoleAccess(sNAME: string) : boolean
	{
		if ( this.ACL_ROLES != null )
		{
			for ( let i = 0; i < this.ACL_ROLES.length; i++ )
			{
				let row: any = this.ACL_ROLES[i];
				if ( row['ROLE_NAME'] == sNAME )
				{
					return true;
				}
			}
		}
		return false;
	}

	VerifyReactState()
	{
		let nIssues = 0;
		if ( this.CONFIG == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: CONFIG is null');
		}
		if ( this.MODULES == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: MODULES is null');
		}
		if ( this.TAB_MENU == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TAB_MENU is null');
		}
		// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
		if ( this.GRIDVIEWS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: GRIDVIEWS is null');
		}
		if ( this.GRIDVIEWS_COLUMNS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: GRIDVIEWS_COLUMNS is null');
		}
		if ( this.DETAILVIEWS_FIELDS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DETAILVIEWS_FIELDS is null');
		}
		if ( this.EDITVIEWS_FIELDS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: EDITVIEWS_FIELDS is null');
		}
		if ( this.DETAILVIEWS_RELATIONSHIPS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DETAILVIEWS_RELATIONSHIPS is null');
		}
		if ( this.EDITVIEWS_RELATIONSHIPS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: EDITVIEWS_RELATIONSHIPS is null');
		}
		if ( this.DYNAMIC_BUTTONS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DYNAMIC_BUTTONS is null');
		}
		// 08/15/2019 Paul.  Add support for menu shortcuts. 
		if ( this.SHORTCUTS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: SHORTCUTS is null');
		}
		if ( this.TERMINOLOGY == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY is null');
		}
		if ( this.TERMINOLOGY_LISTS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: TERMINOLOGY_LISTS is null');
		}
		if ( this.RELATIONSHIPS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: RELATIONSHIPS is null');
		}
		if ( this.USERS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: USERS is null');
		}
		if ( this.TEAMS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: USERS is null');
		}
		if ( this.DASHBOARDS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DASHBOARDS is null');
		}
		if ( this.DASHBOARDS_PANELS == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: DASHBOARDS_PANELS is null');
		}
		if ( this.CONFIG != null && this.CONFIG['enable_team_management'] == null )
		{
			nIssues++;
			console.warn((new Date()).toISOString() + ' ' + 'SplendidCache: CONFIG enable_team_management not found.');
		}
		let nConfigItems = 0;
		if ( this.CONFIG != null )
		{
			for ( let value in this.CONFIG )
			{
				nConfigItems++;
			}
		}
		let nTerminologyItems = 0;
		if ( this.TERMINOLOGY != null )
		{
			for ( let value in this.TERMINOLOGY )
			{
				nTerminologyItems++;
			}
		}
		if ( nIssues == 0 )
		{
			this.Config('enable_team_management');
			//console.log((new Date()).toISOString() + ' ' + 'SplendidCache: React State Verified. ' + nConfigItems.toString() + ' CONFIG items. ' + nTerminologyItems.toString() + ' TERMINOLOGY items.');
		}
	}

	GetGridModule(layout): string
	{
		let MODULE_NAME : string = null;
		if ( layout != null && layout.length > 0 )
		{
			let GRID_NAME   : string   = Sql.ToString(layout[0].GRID_NAME );
			let arrGRID_NAME: string[] = GRID_NAME.split('.');
			if ( arrGRID_NAME.length > 0 )
			{
				if ( arrGRID_NAME[0] == "ListView" || arrGRID_NAME[0] == "PopupView" || arrGRID_NAME[0] == "Activities" )
				{
					MODULE_NAME = arrGRID_NAME[0];
				}
				// 01/18/2010 Paul.  A sub-panel should apply the access rules of the related module. 
				else if ( arrGRID_NAME.length > 1 && this.Module(arrGRID_NAME[1]) )
				{
					MODULE_NAME = arrGRID_NAME[1];
				}
				else
				{
					MODULE_NAME = arrGRID_NAME[0];
				}
			}
		}
		return MODULE_NAME;
	}

	BuildModuleTerminology(moduleName): string[]
	{
		let MODULE_TERMINOLOGY: string[] = [];
		MODULE_TERMINOLOGY.push('');
		for ( let sTerm in this.TERMINOLOGY )
		{
			let sSimpleTerm: string = sTerm.replace(Credentials.sUSER_LANG + '.', '');
			if (  sSimpleTerm == ".LBL_ID"                 // || sTerm == ".LBL_LIST_ID"              
			   || sSimpleTerm == ".LBL_DELETED"            // || sTerm == ".LBL_LIST_DELETED"         
			   || sSimpleTerm == ".LBL_CREATED_BY"         // || sTerm == ".LBL_LIST_CREATED_BY"      
			   || sSimpleTerm == ".LBL_CREATED_BY_ID"      // || sTerm == ".LBL_LIST_CREATED_BY_ID"   
			   || sSimpleTerm == ".LBL_CREATED_BY_NAME"    // || sTerm == ".LBL_LIST_CREATED_BY_NAME" 
			   || sSimpleTerm == ".LBL_DATE_ENTERED"       // || sTerm == ".LBL_LIST_DATE_ENTERED"    
			   || sSimpleTerm == ".LBL_MODIFIED_USER_ID"   // || sTerm == ".LBL_LIST_MODIFIED_USER_ID"
			   || sSimpleTerm == ".LBL_DATE_MODIFIED"      // || sTerm == ".LBL_LIST_DATE_MODIFIED"   
			   || sSimpleTerm == ".LBL_DATE_MODIFIED_UTC"  // || sTerm == ".LBL_LIST_DATE_MODIFIED_UTC"
			   || sSimpleTerm == ".LBL_MODIFIED_BY"        // || sTerm == ".LBL_LIST_MODIFIED_BY"     
			   || sSimpleTerm == ".LBL_MODIFIED_USER_ID"   // || sTerm == ".LBL_LIST_MODIFIED_USER_ID"
			   || sSimpleTerm == ".LBL_MODIFIED_BY_NAME"   // || sTerm == ".LBL_LIST_MODIFIED_BY_NAME"
			   || sSimpleTerm == ".LBL_ASSIGNED_USER_ID"   // || sTerm == ".LBL_LIST_ASSIGNED_USER_ID"
			   || sSimpleTerm == ".LBL_ASSIGNED_TO"        // || sTerm == ".LBL_LIST_ASSIGNED_TO"     
			   || sSimpleTerm == ".LBL_ASSIGNED_TO_NAME"   // || sTerm == ".LBL_LIST_ASSIGNED_TO_NAME"
			   || sSimpleTerm == ".LBL_TEAM_ID"            // || sTerm == ".LBL_LIST_TEAM_ID"         
			   || sSimpleTerm == ".LBL_TEAM_NAME"          // || sTerm == ".LBL_LIST_TEAM_NAME"       
			   || sSimpleTerm == ".LBL_TEAM_SET_ID"        // || sTerm == ".LBL_LIST_TEAM_SET_ID"     
			   || sSimpleTerm == ".LBL_TEAM_SET_NAME"      // || sTerm == ".LBL_LIST_TEAM_SET_NAME"   
			   || sSimpleTerm == ".LBL_ID_C"               // || sTerm == ".LBL_LIST_ID_C"            
			   || sSimpleTerm == ".LBL_LAST_ACTIVITY_DATE" // || sTerm == ".LBL_LIST_LAST_ACTIVITY_DATE"
			// 05/13/2016 Paul.  LBL_TAG_SET_NAME should be global. 
			   || sSimpleTerm == ".LBL_TAG_SET_NAME"       // || sTerm == ".LBL_LIST_TAG_SET_NAME"    
			// 07/18/2018 Paul.  Add Archive terms. 
			   || sSimpleTerm == ".LBL_ARCHIVE_BY"         // || sTerm == ".LBL_LIST_ARCHIVE_BY"       
			   || sSimpleTerm == ".LBL_ARCHIVE_BY_NAME"    // || sTerm == ".LBL_LIST_ARCHIVE_BY_NAME"  
			   || sSimpleTerm == ".LBL_ARCHIVE_DATE_UTC"   // || sTerm == ".LBL_LIST_ARCHIVE_DATE_UTC" 
			   || sSimpleTerm == ".LBL_ARCHIVE_USER_ID"    // || sTerm == ".LBL_LIST_ARCHIVE_USER_ID"  
			   || sSimpleTerm == ".LBL_ARCHIVE_VIEW"       // || sTerm == ".LBL_LIST_ARCHIVE_VIEW"     
			// 07/18/2018 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			   || sSimpleTerm == ".LBL_ASSIGNED_SET_ID"    // || sTerm == ".LBL_LIST_ASSIGNED_SET_ID"  
			   || sSimpleTerm == ".LBL_ASSIGNED_SET_NAME"  // || sTerm == ".LBL_LIST_ASSIGNED_SET_NAME"
			   )
			{
				MODULE_TERMINOLOGY.push(sSimpleTerm);
			}
			else if ( !Sql.IsEmptyString(moduleName) && StartsWith(sSimpleTerm, moduleName) )
			{
				MODULE_TERMINOLOGY.push(sSimpleTerm);
			}
		}
		return MODULE_TERMINOLOGY;
	}

	// 05/06/2021 Paul.  Track browser history changes so that we can determine if last event was a POP event. 
	HistoryChanged(location: any, action: string): void
	{
		this.lastHistoryAction   = action;
		this.lastHistoryLocation = location;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.HistoryChanged', location);
	}

	setGridLastPage(GRID_NAME: string, activePage: number): void
	{
		this.gridLastPage[GRID_NAME] = activePage;
	}

	getGridLastPage(GRID_NAME: string): number
	{
		let activePage: number = Sql.ToInteger(this.gridLastPage[GRID_NAME]);
		if ( activePage < 1 )
			activePage = 1;
		return activePage;
	}

	// 09/05/2021 Paul.  BusinessProcesses needs to cache the report designer modules. 
	public GetReportDesignerModules()
	{
		if ( this.designerModules == null )
			this.designerModules = new ReportDesignerModules();
		return this.designerModules;
	}

}

const splendidCache = new SplendidCacheStore();
export default splendidCache;
