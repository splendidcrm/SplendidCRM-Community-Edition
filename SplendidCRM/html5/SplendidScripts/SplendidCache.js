/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 10/12/2012 Paul.  Rename objects to be consistent with CRM layout tables. 
var TAB_MENU                  = null;
var CONFIG                    = null;
var MODULES                   = null;
var TEAMS                     = null;
// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
var USERS                     = null;
var GRIDVIEWS_COLUMNS         = new Object();
var DETAILVIEWS_FIELDS        = new Object();
var EDITVIEWS_FIELDS          = new Object();
var DETAILVIEWS_RELATIONSHIPS = new Object();
// 02/16/2016 Paul.  Add EditView Relationships for the new layout editor. 
var EDITVIEWS_RELATIONSHIPS   = new Object();
var DYNAMIC_BUTTONS           = new Object();
var TERMINOLOGY               = new Object();
var TERMINOLOGY_LISTS         = new Object();
// 03/01/2016 Paul.  Order management lists. 
var TAX_RATES                 = new Object();
var DISCOUNTS                 = new Object();

var SplendidCache =
{
	Reset: function()
	{
		TAB_MENU                  = null;
		CONFIG                    = null;
		MODULES                   = null;
		TEAMS                     = null;
		// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
		USERS                     = null;
		GRIDVIEWS_COLUMNS         = new Object();
		DETAILVIEWS_FIELDS        = new Object();
		EDITVIEWS_FIELDS          = new Object();
		DETAILVIEWS_RELATIONSHIPS = new Object();
		EDITVIEWS_RELATIONSHIPS   = new Object();
		DYNAMIC_BUTTONS           = new Object();
		TERMINOLOGY               = new Object();
		TERMINOLOGY_LISTS         = new Object();
		TAX_RATES                 = new Object();
		DISCOUNTS                 = new Object();
	}
	// 11/29/2011 Paul.  We are having an issue with the globals getting reset, so we need to re-initialize. 
	, IsInitialized: function()
	{
		return (CONFIG != null);
	}
	, UserID: function()
	{
		return sUSER_ID;
	}
	, UserName: function()
	{
		return sUSER_NAME;
	}
	, FullName: function()
	{
		// 10/26/2012 Paul.  The full name might be empty. 
		if ( sFULL_NAME == null || sFULL_NAME == '' )
			return sUSER_NAME;
		return sFULL_NAME;
	}
	// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
	, Picture: function()
	{
		return sPICTURE;
	}
	, UserLang: function()
	{
		// 11/27/2012 Paul.  We should always have a language. 
		if ( sUSER_LANG == null || sUSER_LANG == '' )
			return 'en-US';
		return sUSER_LANG;
	}
	// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
	, UserTheme: function()
	{
		if ( sUSER_THEME == null || sUSER_THEME === undefined || sUSER_THEME == '' )
			return 'Atlantic';
		return sUSER_THEME;
	}
	, UserDateFormat: function()
	{
		return sUSER_DATE_FORMAT;
	}
	, UserTimeFormat: function()
	{
		return sUSER_TIME_FORMAT;
	}
	, TeamID: function()
	{
		return sTEAM_ID;
	}
	, TeamName: function()
	{
		return sTEAM_NAME;
	}
	// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
	, NumberFormatInfo: function()
	{
		var info = new Object();
		info.CurrencyDecimalDigits    = !isFinite(+sUSER_CurrencyDecimalDigits  ) ? 2 : Math.abs(sUSER_CurrencyDecimalDigits);
		info.CurrencyDecimalSeparator = (sUSER_CurrencyDecimalSeparator == '' || sUSER_CurrencyDecimalSeparator == null) ? '.' : sUSER_CurrencyDecimalSeparator;
		info.CurrencyGroupSeparator   = (sUSER_CurrencyGroupSeparator   == '' || sUSER_CurrencyGroupSeparator   == null) ? ',' : sUSER_CurrencyGroupSeparator  ;
		info.CurrencyGroupSizes       = !isFinite(+sUSER_CurrencyGroupSizes     ) ? 3 : Math.abs(sUSER_CurrencyGroupSizes);
		info.CurrencyNegativePattern  = !isFinite(+sUSER_CurrencyNegativePattern) ? 0 : +sUSER_CurrencyNegativePattern;
		info.CurrencyPositivePattern  = !isFinite(+sUSER_CurrencyPositivePattern) ? 0 : +sUSER_CurrencyPositivePattern;
		info.CurrencySymbol           = sUSER_CurrencySymbol;
		return info;
	}
	, TabMenu: function()
	{
		return TAB_MENU;
	}
	, Config: function(sNAME)
	{
		if ( CONFIG == null )
			return null;
		return CONFIG[sNAME];
	}
	, Team: function(sID)
	{
		return TEAMS[sID.toLowerCase()];
	}
	// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
	, User: function(sID)
	{
		if ( USERS != null )
			return USERS[sID.toLowerCase()];
		else
			return sID;
	}
	, Module: function(sMODULE_NAME)
	{
		return MODULES[sMODULE_NAME];
	}
	, GridViewColumns: function(sGRID_NAME)
	{
		return GRIDVIEWS_COLUMNS[sGRID_NAME];
	}
	, DetailViewFields: function(sDETAIL_NAME)
	{
		return DETAILVIEWS_FIELDS[sDETAIL_NAME];
	}
	, EditViewFields: function(sEDIT_NAME)
	{
		return EDITVIEWS_FIELDS[sEDIT_NAME];
	}
	, DetailViewRelationships: function(sDETAIL_NAME)
	{
		return DETAILVIEWS_RELATIONSHIPS[sDETAIL_NAME];
	}
	, DynamicButtons: function(sVIEW_NAME)
	{
		return DYNAMIC_BUTTONS[sVIEW_NAME];
	}
	, Terminology: function(sTerm)
	{
		return TERMINOLOGY[sUSER_LANG + '.' + sTerm];
	}
	, TerminologyList: function(sListName)
	{
		return TERMINOLOGY_LISTS[sUSER_LANG + '.' + sListName];
	}
	// 03/01/2016 Paul.  Order management lists. 
	, TaxRates: function(sID)
	{
		return TAX_RATES[sID];
	}
	, Discounts: function(sID)
	{
		return DISCOUNTS[sID];
	}

	, SetGridViewColumns: function(sGRID_NAME, data)
	{
		GRIDVIEWS_COLUMNS[sGRID_NAME] = data;
	}
	, SetDetailViewFields: function(sDETAIL_NAME, data)
	{
		DETAILVIEWS_FIELDS[sDETAIL_NAME] = data;
	}
	, SetEditViewFields: function(sEDIT_NAME, data)
	{
		EDITVIEWS_FIELDS[sEDIT_NAME] = data;
	}
	, SetDetailViewRelationships: function(sDETAIL_NAME, data)
	{
		DETAILVIEWS_RELATIONSHIPS[sDETAIL_NAME] = data;
	}
	// 02/16/2016 Paul.  Add EditView Relationships for the new layout editor. 
	, SetEditViewRelationships: function(sEDIT_NAME, data)
	{
		EDITVIEWS_RELATIONSHIPS[sEDIT_NAME] = data;
	}
	, SetDynamicButtons: function(sVIEW_NAME, data)
	{
		DYNAMIC_BUTTONS[sVIEW_NAME] = data;
	}
};



