/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

var Crm     = new Object();
Crm.Config  = new Object();
Crm.Modules = new Object();
Crm.Teams   = new Object();
// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
Crm.Users   = new Object();

// 09/16/2018 Paul.  Create a multi-tenant system. 
Crm.Config.enable_multi_tenant_teams = function ()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return Sql.ToBoolean(bgPage.SplendidCache.Config('enable_multi_tenant_teams'));
}

Crm.Config.enable_team_management = function ()
{
	var bgPage = chrome.extension.getBackgroundPage();
	// 09/16/2018 Paul.  Create a multi-tenant system. 
	return Sql.ToBoolean(bgPage.SplendidCache.Config('enable_team_management')) || Sql.ToBoolean(bgPage.SplendidCache.Config('enable_multi_tenant_teams'));
}

Crm.Config.require_team_management = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	// 09/16/2018 Paul.  Create a multi-tenant system. 
	return Sql.ToBoolean(bgPage.SplendidCache.Config('require_team_management')) || Sql.ToBoolean(bgPage.SplendidCache.Config('enable_multi_tenant_teams'));
}

Crm.Config.enable_dynamic_teams = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return Sql.ToBoolean(bgPage.SplendidCache.Config('enable_dynamic_teams'));
}

// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Crm.Config.enable_dynamic_assignment = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return Sql.ToBoolean(bgPage.SplendidCache.Config('enable_dynamic_assignment'));
}

Crm.Config.require_user_assignment = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return Sql.ToBoolean(bgPage.SplendidCache.Config('require_user_assignment'));
}

// 06/26/2018 Paul.  Data Privacy uses the module enabled flag. 
// 07/01/2018 Paul.  The Data Privacy module is not returned via the REST API, so we need to simulate the flag. 
Crm.Config.enable_data_privacy = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return Sql.ToBoolean(bgPage.SplendidCache.Config('enable_data_privacy'));
}

// 08/31/2012 Paul.  Add support for speech. 
Crm.Config.enable_speech = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return Sql.ToBoolean(bgPage.SplendidCache.Config('enable_speech'));
}

Crm.Config.ToBoolean = function(sName)
{
	var bgPage = chrome.extension.getBackgroundPage();
	return Sql.ToBoolean(bgPage.SplendidCache.Config(sName));
}

Crm.Config.ToInteger = function(sName)
{
	var bgPage = chrome.extension.getBackgroundPage();
	return Sql.ToInteger(bgPage.SplendidCache.Config(sName));
}

Crm.Config.ToString = function(sName)
{
	var bgPage = chrome.extension.getBackgroundPage();
	return Sql.ToString(bgPage.SplendidCache.Config(sName));
}

Crm.Modules.TableName = function(sMODULE)
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.Module(sMODULE).TABLE_NAME;
}

Crm.Modules.SingularTableName = function(sTABLE_NAME)
{
	if ( Right(sTABLE_NAME, 3) == 'IES' && sTABLE_NAME.length > 3 )
		sTABLE_NAME = sTABLE_NAME.substring(0, sTABLE_NAME.length - 3) + 'Y';
	else if ( Right(sTABLE_NAME, 1) == 'S' )
		sTABLE_NAME = sTABLE_NAME.substring(0, sTABLE_NAME.length - 1);
	return sTABLE_NAME;
}

Crm.Modules.SingularModuleName = function(sMODULE)
{
	if ( Right(sMODULE, 3) == 'ies' && sMODULE.length > 3 )
		sMODULE = sMODULE.substring(0, sMODULE.length - 3) + 'y';
	else if ( Right(sMODULE, 1) == 's' )
		sMODULE = sMODULE.substring(0, sMODULE.length - 1);
	return sMODULE;
}

Crm.Modules.ExchangeFolders = function(sMODULE)
{
	var bgPage = chrome.extension.getBackgroundPage();
	var oModule = bgPage.SplendidCache.Module(sMODULE);
	// 10/24/2014 Paul.  The module should not return NULL, but we don't want to generate an error here. 
	if ( oModule === undefined )
		return false;
	return Sql.ToBoolean(oModule.EXCHANGE_SYNC) && Sql.ToBoolean(oModule.EXCHANGE_FOLDERS);
}

Crm.Modules.ItemName = function(sMODULE_NAME, sID, callback, context)
{
	var bgPage = chrome.extension.getBackgroundPage();
	bgPage.DetailView_LoadItem(sMODULE_NAME, sID, function(status, message)
	{
		if ( status == 1 )
			callback.call(context, status, message['NAME']);
		else
			callback.call(context, status, null);
	}, context);
}



Crm.Teams.Name = function(sID)
{
	var bgPage = chrome.extension.getBackgroundPage();
	var rowTeam = bgPage.SplendidCache.Team(sID);
	if ( rowTeam !== undefined && rowTeam != null )
		return rowTeam.NAME;
	else
		return '';
}
// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
Crm.Users.Name = function(sID)
{
	var bgPage = chrome.extension.getBackgroundPage();
	var rowUser = bgPage.SplendidCache.User(sID);
	if ( rowUser !== undefined && rowUser != null )
		return rowUser.USER_NAME;
	else
		return '';
}

var Security = new Object();
Security.USER_ID = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.UserID();
}

Security.USER_NAME = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.UserName();
}

Security.FULL_NAME = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.FullName();
}

// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
Security.PICTURE = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.Picture();
}

Security.USER_LANG = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.UserLang();
}

// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
Security.USER_THEME = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.UserTheme();
}

Security.USER_DATE_FORMAT = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.UserDateFormat();
}

Security.USER_TIME_FORMAT = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.UserTimeFormat();
}

Security.TEAM_ID = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.TeamID();
}

Security.TEAM_NAME = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.TeamName();
}

// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
Security.NumberFormatInfo = function()
{
	var bgPage = chrome.extension.getBackgroundPage();
	return bgPage.SplendidCache.NumberFormatInfo();
}

