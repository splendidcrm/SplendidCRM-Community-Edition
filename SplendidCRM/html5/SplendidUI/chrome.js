/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

var backgroundPage = new Object();
var chrome         = new Object();
chrome.extension   = new Object();
chrome.extension.getBackgroundPage = function()
{
	return backgroundPage;
}

try
{
	// Storage.js
	backgroundPage.SplendidStorage                        = SplendidStorage;
	// Login.js
	backgroundPage.GetUserID                              = GetUserID;
	backgroundPage.GetUserName                            = GetUserName;
	backgroundPage.GetTeamID                              = GetTeamID;
	backgroundPage.GetTeamName                            = GetTeamName;
	backgroundPage.GetUserLanguage                        = GetUserLanguage;
	backgroundPage.GetUserProfile                         = GetUserProfile;
	backgroundPage.IsAuthenticated                        = IsAuthenticated;
	backgroundPage.Login                                  = Login;
	backgroundPage.AuthenticatedMethod                    = AuthenticatedMethod;
	backgroundPage.IsOnline                               = IsOnline;
	// 04/30/2017 Paul.  Add support for single-sign-on. 
	backgroundPage.SingleSignOnSettings                   = SingleSignOnSettings;
	// Credentials.js
	backgroundPage.GetIsOffline                           = GetIsOffline;
	backgroundPage.GetEnableOffline                       = GetEnableOffline;
	// 12/09/2014 Paul.  Remote Server is on the background page of the browser extensions. 
	backgroundPage.RemoteServer                           = RemoteServer;
	// SplendidCache.js
	backgroundPage.SplendidCache                          = SplendidCache;
	// AutoComplete.js
	backgroundPage.AutoComplete_ModuleMethod              = AutoComplete_ModuleMethod;
	// Logout.js
	backgroundPage.Logout                                 = Logout;
	// Terminology.js
	backgroundPage.Terminology_SetTerm                    = Terminology_SetTerm;
	backgroundPage.Terminology_SetListTerm                = Terminology_SetListTerm;
	backgroundPage.Terminology_LoadGlobal                 = Terminology_LoadGlobal;
	backgroundPage.Terminology_LoadList                   = Terminology_LoadList;
	backgroundPage.Terminology_LoadModule                 = Terminology_LoadModule;
	backgroundPage.Terminology_LoadCustomList             = Terminology_LoadCustomList;
	backgroundPage.Terminology_LoadAllLists               = Terminology_LoadAllLists;
	backgroundPage.Terminology_LoadAllTerms               = Terminology_LoadAllTerms;
	// Application.js
	backgroundPage.Application_Modules                    = Application_Modules;
	backgroundPage.Application_Config                     = Application_Config;
	backgroundPage.Application_Teams                      = Application_Teams;
	// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
	backgroundPage.Application_Users                      = Application_Users;
	// 02/27/2016 Paul.  Combine all layout gets. 
	backgroundPage.Application_GetAllLayouts              = Application_GetAllLayouts;
	// TabMenu.js
	backgroundPage.TabMenu_Load                           = TabMenu_Load;
	// ListView.js
	backgroundPage.ListView_LoadTable                     = ListView_LoadTable;
	backgroundPage.ListView_LoadModule                    = ListView_LoadModule;
	backgroundPage.ListView_LoadLayout                    = ListView_LoadLayout;
	backgroundPage.ListView_LoadAllLayouts                = ListView_LoadAllLayouts;
	// 06/13/2017 Paul.  Add pagination. 
	backgroundPage.ListView_LoadTablePaginated            = ListView_LoadTablePaginated;
	// 04/22/2017 Paul.  Add pagination. 
	backgroundPage.ListView_LoadModulePaginated           = ListView_LoadModulePaginated;
	// 05/21/2017 Paul.  HTML5 Dashboard requires aggregates. 
	backgroundPage.ListView_LoadTableWithAggregate        = ListView_LoadTableWithAggregate;
	// 03/25/2020 Paul.  New service call as the process list has special filtering rules. 
	backgroundPage.ListView_LoadProcessPaginated          = ListView_LoadProcessPaginated;
	// DetailView.js
	backgroundPage.DetailView_LoadItem                    = DetailView_LoadItem;
	backgroundPage.DetailView_LoadLayout                  = DetailView_LoadLayout;
	backgroundPage.DetailView_LoadAllLayouts              = DetailView_LoadAllLayouts;
	// EditView.js
	backgroundPage.EditView_LoadItem                      = EditView_LoadItem;
	backgroundPage.EditView_LoadLayout                    = EditView_LoadLayout;
	backgroundPage.EditView_LoadAllLayouts                = EditView_LoadAllLayouts;
	// 03/30/2016 Paul.  Convert requires special processing. 
	backgroundPage.EditView_ConvertItem                   = EditView_ConvertItem;
	// DetailViewRelationships.js
	backgroundPage.DetailViewRelationships_LoadLayout     = DetailViewRelationships_LoadLayout;
	backgroundPage.DetailViewRelationships_LoadAllLayouts = DetailViewRelationships_LoadAllLayouts;
	// DynamicButtons.js
	backgroundPage.DynamicButtons_LoadLayout              = DynamicButtons_LoadLayout;
	backgroundPage.DynamicButtons_LoadAllLayouts          = DynamicButtons_LoadAllLayouts;
	// ModuleUpdate.js
	backgroundPage.DeleteModuleItem                       = DeleteModuleItem;
	backgroundPage.UpdateModule                           = UpdateModule;
	backgroundPage.UpdateModuleTable                      = UpdateModuleTable;
	backgroundPage.DeleteRelatedItem                      = DeleteRelatedItem;
	backgroundPage.UpdateRelatedItem                      = UpdateRelatedItem;
	// CalendarView.js
	backgroundPage.CalendarView_GetCalendar               = CalendarView_GetCalendar;
	// 08/20/2016 Paul.  ProcessButtons.js.  Wrap in a catch as it may not be included. 
	try
	{
		backgroundPage.ProcessButtons_GetProcessStatus    = ProcessButtons_GetProcessStatus;
		backgroundPage.ProcessButtons_ProcessAction       = ProcessButtons_ProcessAction;
		backgroundPage.ProcessButtons_ProcessUsers        = ProcessButtons_ProcessUsers;
	}
	catch(e)
	{
	}
	// 05/14/2017 Paul.  Dashboard.js
	try
	{
		backgroundPage.DashboardApps_LoadAll                  = DashboardApps_LoadAll;
		backgroundPage.Dashboards_LoadItem                    = Dashboards_LoadItem;
		backgroundPage.Dashboards_LoadPanels                  = Dashboards_LoadPanels;
	}
	catch(e)
	{
	}
}
catch(e)
{
	alert('chrome.js ' + e.message);
}

