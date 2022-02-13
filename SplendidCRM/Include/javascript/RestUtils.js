/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 10/24/2014 Paul.  bREMOTE_ENABLED needs to be in the UI page so that it can be quickly accessed by the Formatting functions. 
// 06/24/2017 Paul.  We need a way to turn off bootstrap for BPMN, ReportDesigner and ChatDashboard. 
var bDESKTOP_LAYOUT  = false;
var sPLATFORM_LAYOUT               = '';
var sIMAGE_SERVER                  = sREMOTE_SERVER;
var bREMOTE_ENABLED                = false;
var bIS_MOBILE                     = false;
var sAUTHENTICATION                = '';
var sUSER_NAME                     = '';
var sPASSWORD                      = '';
var sUSER_ID                       = '';
var sUSER_LANG                     = 'en-US';
// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
var sUSER_THEME                    = 'Atlantic';
var sUSER_DATE_FORMAT              = 'MM/dd/yyyy';
var sUSER_TIME_FORMAT              = 'h:mm tt';
var sUSER_CURRENCY_ID              = 'E340202E-6291-4071-B327-A34CB4DF239B';
var sUSER_TIMEZONE_ID              = 'BFA61AF7-26ED-4020-A0C1-39A15E4E9E0A';
var sFULL_NAME                     = '';
// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
var sPICTURE                       = '';
var sTEAM_ID                       = '';
var sTEAM_NAME                     = '';
var bIS_OFFLINE                    = false;
var bENABLE_OFFLINE                = false;
var cbNetworkStatusChanged         = null;
// 11/25/2014 Paul.  Add SignalR fields. 
var sUSER_EXTENSION                = '';
var sUSER_FULL_NAME                = '';
var sUSER_PHONE_WORK               = '';
var sUSER_SMS_OPT_IN               = '';
var sUSER_PHONE_MOBILE             = '';
var sUSER_TWITTER_TRACKS           = '';
var sUSER_CHAT_CHANNELS            = '';
// 09/09/2020 Paul.  Add PhoneBurner SignalR support. 
var sUSER_PHONE_BURNER_GROUP       = '';
// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
var sUSER_CurrencyDecimalDigits    = '2';
var sUSER_CurrencyDecimalSeparator = '.';
var sUSER_CurrencyGroupSeparator   = ',';
var sUSER_CurrencyGroupSizes       = '3';
var sUSER_CurrencyNegativePattern  = '0';
var sUSER_CurrencyPositivePattern  = '0';
var sUSER_CurrencySymbol           = '$';
// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
var sPRIMARY_ROLE_NAME             = '';
// 06/15/2019 Paul.  sPopupWindowOptions is used by the Dashboard Editor. 
var sPopupWindowOptions = '';
var SelectionUI_chkMain_Clicked    = null;

var L10n                      = new Object();
var Crm                       = new Object();
Crm.Config                    = new Object();
Crm.Modules                   = new Object();
var background                = new Object();
var Security                  = new Object();
var chrome                    = new Object();
chrome.extension              = new Object();
// 01/18/2015 Paul.  SplendidCache is used by ChatDashboard PopupViewUI. 
var SplendidCache             = new Object();
var SplendidError             = new Object();
var ctlActiveMenu             = new Object();
// 01/24/2018 Paul.  The Calendar needs to determine if Calls module is enabled. 
var MODULES                   = new Object();
var CONFIG                    = new Object();
var GRIDVIEWS_COLUMNS         = new Object();
var EDITVIEWS_FIELDS          = new Object();
var DETAILVIEWS_FIELDS        = new Object();
var DETAILVIEWS_RELATIONSHIPS = new Object();
var EDITVIEWS_RELATIONSHIPS   = new Object();
var TERMINOLOGY               = new Object();
var TERMINOLOGY_LISTS         = new Object();

L10n.Term = function(sTerm)
{
	if ( TERMINOLOGY[sTerm] === undefined )
	{
		// 05/31/2017 Paul.  Dashboard uses culture in lookup. 
		if ( TERMINOLOGY[sUSER_LANG + '.' + sTerm] === undefined )
		{
			return sTerm;
		}
		sTerm = sUSER_LANG + '.' + sTerm;
	}
	return TERMINOLOGY[sTerm];
};

L10n.GetList = function(sListName)
{
	if ( TERMINOLOGY_LISTS[sListName] === undefined )
	{
		// 05/31/2017 Paul.  Dashboard uses culture in lookup. 
		if ( TERMINOLOGY_LISTS[sUSER_LANG + '.' + sListName] === undefined )
		{
			return sListName;
		}
		sListName = sUSER_LANG + '.' + sListName;
	}
	return TERMINOLOGY_LISTS[sListName];
};

L10n.GetListTerms = function(sListName)
{
	// 03/18/2018 Paul.   Dashboard uses culture in lookup, so we need to convert the list ID to the Term. 
	var bUseLang = false;
	var arrTerms = new Array();
	var arrList = TERMINOLOGY_LISTS[sListName];
	if ( arrList === undefined )
	{
		arrList = TERMINOLOGY_LISTS[sUSER_LANG + '.' + sListName];
		// 05/31/2017 Paul.  Dashboard uses culture in lookup. 
		if ( arrList === undefined )
		{
			return sListName;
		}
		bUseLang = true;
	}
	if ( arrList != null )
	{
		for ( var i = 0; i < arrList.length; i++ )
		{
			var sTerm = (bUseLang ? sUSER_LANG + '.' : '') + '.' + sListName + '.' + arrList[i];
			if ( TERMINOLOGY[sTerm] === undefined )
			{
				arrTerms.push(arrList[i]);
			}
			else
			{
				arrTerms.push(TERMINOLOGY[sTerm]);
			}
		}
	}
	return arrTerms;
};

L10n.ListTerm = function(sLIST_NAME, sNAME)
{
	var sEntryName = '.' + sLIST_NAME + '.' + sNAME;
	return L10n.Term(sEntryName);
}

L10n.TableColumnName = function(sModule, sDISPLAY_NAME)
{
	// 04/19/2018 Paul.  MODIFIED_BY_ID is not the correct name, use MODIFIED_USER_ID instead. 
	if (   sDISPLAY_NAME == 'ID'              
		|| sDISPLAY_NAME == 'DELETED'         
		|| sDISPLAY_NAME == 'CREATED_BY'      
		|| sDISPLAY_NAME == 'CREATED_BY_ID'   
		|| sDISPLAY_NAME == 'CREATED_BY_NAME' 
		|| sDISPLAY_NAME == 'DATE_ENTERED'    
		|| sDISPLAY_NAME == 'MODIFIED_USER_ID'
		|| sDISPLAY_NAME == 'DATE_MODIFIED'   
		|| sDISPLAY_NAME == 'DATE_MODIFIED_UTC'
		|| sDISPLAY_NAME == 'MODIFIED_BY'     
		|| sDISPLAY_NAME == 'MODIFIED_USER_ID'
		|| sDISPLAY_NAME == 'MODIFIED_BY_NAME'
		|| sDISPLAY_NAME == 'ASSIGNED_USER_ID'
		|| sDISPLAY_NAME == 'ASSIGNED_TO'     
		|| sDISPLAY_NAME == 'ASSIGNED_TO_NAME'
		|| sDISPLAY_NAME == 'TEAM_ID'         
		|| sDISPLAY_NAME == 'TEAM_NAME'       
		|| sDISPLAY_NAME == 'TEAM_SET_ID'     
		|| sDISPLAY_NAME == 'TEAM_SET_NAME'   
		|| sDISPLAY_NAME == 'TEAM_SET_LIST'   
		|| sDISPLAY_NAME == 'ID_C'            
		|| sDISPLAY_NAME == 'AUDIT_ID'        
		|| sDISPLAY_NAME == 'AUDIT_ACTION'    
		|| sDISPLAY_NAME == 'AUDIT_DATE'      
		|| sDISPLAY_NAME == 'AUDIT_COLUMNS'   
		|| sDISPLAY_NAME == 'AUDIT_TABLE'     
		|| sDISPLAY_NAME == 'AUDIT_TOKEN'     
		|| sDISPLAY_NAME == 'LAST_ACTIVITY_DATE'
		|| sDISPLAY_NAME == 'TAG_SET_NAME'    
		|| sDISPLAY_NAME == 'PENDING_PROCESS_ID'
		)
	{
		if ( L10n.Term('.LBL_' + sDISPLAY_NAME) != null )
			sDISPLAY_NAME = L10n.Term('.LBL_' + sDISPLAY_NAME);
	}
	else
	{
		if ( L10n.Term(sModule + '.LBL_' + sDISPLAY_NAME) != null )
			sDISPLAY_NAME = L10n.Term(sModule + '.LBL_' + sDISPLAY_NAME);
	}
	return sDISPLAY_NAME;
}

Crm.Config.ToInteger = function(sName)
{
	return Sql.ToInteger(CONFIG[sName]);
}
Crm.Config.ToString = function(sName)
{
	return Sql.ToString(CONFIG[sName]);
}
// 09/16/2018 Paul.  Create a multi-tenant system. 
Crm.Config.enable_multi_tenant_teams = function ()
{
	return Sql.ToBoolean(CONFIG['enable_multi_tenant_teams']);
}
Crm.Config.enable_team_management = function()
{
	return Sql.ToBoolean(CONFIG['enable_team_management']);
}
Crm.Config.require_team_management = function()
{
	return Sql.ToBoolean(CONFIG['require_team_management']);
}
Crm.Config.enable_dynamic_teams = function()
{
	return Sql.ToBoolean(CONFIG['enable_dynamic_teams']);
}
// 12/11/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
Crm.Config.enable_dynamic_assignment = function()
{
	return Sql.ToBoolean(CONFIG['enable_dynamic_assignment']);
}
Crm.Config.require_user_assignment = function()
{
	return Sql.ToBoolean(CONFIG['require_user_assignment']);
}
// 06/26/2018 Paul.  Data Privacy uses the module enabled flag. 
// 07/01/2018 Paul.  The Data Privacy module is not returned via the REST API, so we need to simulate the flag. 
// 08/10/2018 Paul.  Needed to add enable_data_privacy to RestUtils.js. 
Crm.Config.enable_data_privacy = function()
{
	return Sql.ToBoolean(CONFIG['enable_data_privacy']);
}
Crm.Config.enable_speech = function()
{
	return Sql.ToBoolean(CONFIG['enable_speech']);
}
// 01/18/2015 Paul.  Crm.Modules.TableName is used by SearchViewUI. 
Crm.Modules.TableName = function(sMODULE)
{
	// 01/18/2015 Paul.  Instead of requiring the MODULES table, just cheat and convert to upper case. 
	switch ( sMODULE )
	{
		case 'ProjectTask':  sMODULE = 'PROJECT_TASK';  break;
	}
	return sMODULE.toUpperCase();
}

Security.USER_ID = function()
{
	return sUSER_ID;
};
Security.USER_NAME = function()
{
	return sUSER_NAME;
};
Security.TEAM_ID = function()
{
	return sTEAM_ID;
};
Security.USER_TIME_FORMAT = function()
{
	return sUSER_TIME_FORMAT;
};
Security.USER_DATE_FORMAT = function()
{
	return sUSER_DATE_FORMAT;
};
Security.PICTURE = function()
{
	return sPICTURE;
};
Security.USER_THEME = function()
{
	return sUSER_THEME;
};
// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
Security.NumberFormatInfo = function()
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

// 01/18/2015 Paul.  SplendidError.SystemError() was used on ChatDashboard. 
SplendidError.FormatError = function(e, method)
{
	return e.message + '<br>\n' + dumpObj(e, method);
};
// 01/18/2015 Paul.  SplendidError.SystemError() was used on ChatDashboard. 
SplendidError.SystemError = function(e, method)
{
	var message = SplendidError.FormatError(e, method);
	SplendidError.SystemMessage(message);
}
SplendidError.SystemStatus = function(message)
{
}
// 06/29/2017 Paul.  SystemLog is now needed in SplendidInitUI.js. 
SplendidError.SystemLog = function(message)
{
}
SplendidError.SystemAlert = function(e, method)
{
	alert(dumpObj(e, method));
};
SplendidError.SystemMessage = function(message)
{
	var divError = document.getElementById('divError');
	divError.innerHTML = message;
};

function DetailViewUI()
{
	this.MODULE  = null;
	this.ID      = null;
}
DetailViewUI.prototype.Load = function(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, callback)
{
	window.location.href = sREMOTE_SERVER + sMODULE_NAME + '/view.aspx?ID=' + sID;
}

SplendidCache.IsInitialized = function()
{
	return true;
}

SplendidCache.GridViewColumns = function(sGRID_NAME)
{
	return GRIDVIEWS_COLUMNS[sGRID_NAME];
}
SplendidCache.EditViewFields = function(sEDIT_NAME)
{
	return EDITVIEWS_FIELDS[sEDIT_NAME];
}
SplendidCache.DetailViewFields = function(sEDIT_NAME)
{
	return DETAILVIEWS_FIELDS[sEDIT_NAME];
}
SplendidCache.DetailViewRelationships = function(sDETAIL_NAME)
{
	return DETAILVIEWS_RELATIONSHIPS[sDETAIL_NAME];
}
SplendidCache.EditViewRelationships = function(sEDIT_NAME)
{
	return EDITVIEWS_RELATIONSHIPS[sEDIT_NAME];
}
SplendidCache.SetGridViewColumns = function(sGRID_NAME, data)
{
	GRIDVIEWS_COLUMNS[sGRID_NAME] = data;
}
SplendidCache.SetEditViewFields = function(sEDIT_NAME, data)
{
	EDITVIEWS_FIELDS[sEDIT_NAME] = data;
}
SplendidCache.SetDetailViewFields = function(sDETAIL_NAME, data)
{
	DETAILVIEWS_FIELDS[sDETAIL_NAME] = data;
}
SplendidCache.SetDetailViewRelationships = function(sDETAIL_NAME, data)
{
	DETAILVIEWS_RELATIONSHIPS[sDETAIL_NAME] = data;
}
SplendidCache.SetEditViewRelationships = function(sEDIT_NAME, data)
{
	EDITVIEWS_RELATIONSHIPS[sEDIT_NAME] = data;
}
// 01/24/2018 Paul.  The Calendar needs to determine if Calls module is enabled. 
SplendidCache.Module = function(sMODULE_NAME)
{
	return MODULES[sMODULE_NAME];
}

SplendidCache.Config = function(sName)
{
	if ( CONFIG[sName] === undefined )
		return null;
	return CONFIG[sName];
};

background.SplendidCache = SplendidCache;
try
{
	// 01/15/2015 Paul.  ListView_LoadModule will be included in ChatDashboard, but not Calendar.  Catch and ignore the error. 
	background.ListView_LoadModule       = ListView_LoadModule;
	background.ListView_LoadLayout       = ListView_LoadLayout;
	background.EditView_LoadLayout       = EditView_LoadLayout;
	// 01/18/2015 Paul.  We need a special Terminology_LoadModule that will not prepend the sUSER_LANG. 
	//background.Terminology_LoadModule    = Terminology_LoadModule;
	background.AutoComplete_ModuleMethod = AutoComplete_ModuleMethod;
}
catch(e)
{
	// 07/03/2016 Paul.  Log the error. 
	if ( console !== undefined )
		console.log(e.message);
}
try
{
	background.Application_Modules   = Application_Modules;
	background.DetailView_LoadLayout = DetailView_LoadLayout;
}
catch(e)
{
	// 07/03/2016 Paul.  Log the error. 
	if ( console !== undefined )
		console.log(e.message);
}
try
{
	// 07/03/2016 Paul.  BPMN needs new functions. 
	background.Application_Config         = Application_Config        ;
	background.ListView_LoadAllLayouts    = ListView_LoadAllLayouts   ;
	background.EditView_LoadAllLayouts    = EditView_LoadAllLayouts   ;
	background.Terminology_LoadAllLists   = Terminology_LoadAllLists  ;
	background.Terminology_LoadAllTerms   = Terminology_LoadAllTerms  ;
}
catch(e)
{
	// 07/03/2016 Paul.  Log the error. 
	if ( console !== undefined )
		console.log(e.message);
}
// 06/24/2017 Paul.  New responsive design requires paginated function. 
try
{
	background.ListView_LoadModulePaginated = ListView_LoadModulePaginated;
}
catch(e)
{
	if ( console !== undefined )
		console.log(e.message);
}

// 01/18/2015 Paul.  We need a special Terminology_LoadModule that will not prepend the sUSER_LANG. 
background.Terminology_LoadModule = function(sMODULE_NAME, callback, context)
{
	// 06/11/2012 Paul.  Wrap Terminology requests for Cordova. 
	var xhr = TerminologyRequest(sMODULE_NAME, null, 'NAME asc', sUSER_LANG);
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=NAME asc&$filter=' + encodeURIComponent('(LANG eq \'' + sUSER_LANG + '\' and MODULE_NAME eq \'' + sMODULE_NAME + '\' and LIST_NAME is null)'), 'GET');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							TERMINOLOGY[sUSER_LANG + '.' + sMODULE_NAME + '.Loaded'] = true;
							//alert(dumpObj(result, 'result'));
							for ( var i = 0; i < result.d.results.length; i++ )
							{
								var obj = result.d.results[i];
								//Terminology_SetTerm(sMODULE_NAME, obj['NAME'], obj['DISPLAY_NAME']);
								TERMINOLOGY[sMODULE_NAME + '.' + obj['NAME']] = obj['DISPLAY_NAME'];
							}
							// 10/04/2011 Paul. Return the entire TERMINOLOGY table. 
							callback.call(context||this, 1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
						}
						else
						{
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else
					{
						if ( result.status == 0 )
							callback.call(context||this, 0, result.ExceptionDetail.Message);
						else if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'Terminology_LoadModule'));
				}
			}, context||this);
		}
	}
	try
	{
		if ( TERMINOLOGY[sUSER_LANG + '.' + sMODULE_NAME + '.Loaded'] == null )
			xhr.send();
		else
			callback.call(context||this, 1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'Terminology_LoadModule'));
	}
}

background.RemoteServer = function()
{
	return sREMOTE_SERVER;
};

// 06/01/2017 Paul.  Delete need for dashboard. 
background.DeleteModuleItem = function(sMODULE_NAME, sID, callback, context)
{
	var xhr = CreateSplendidRequest('Rest.svc/DeleteModuleItem', 'POST');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						callback.call(context||this, 1, null);
					}
					else if ( result.status == 0 )
					{
						// 10/06/2011 Paul.  It does not make sense to allow deletes at this time. 
						callback.call(context||this, -1, 'A record cannot be deleted when offline.');
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'DeleteModuleItem'));
				}
			});
		}
	}
	try
	{
		xhr.send('{"ModuleName": ' + JSON.stringify(sMODULE_NAME) + ', "ID": ' + JSON.stringify(sID) + '}');
	}
	catch(e)
	{
		callback.call(context||this, -1, SplendidError.FormatError(e, 'DeleteModuleItem'));
	}
}


// 10/26/2016 Paul.  Missing method for ChatDashboard. 
background.UpdateModule = function(sMODULE_NAME, row, sID, callback, context)
{
	if ( sMODULE_NAME == null )
	{
		callback.call(context||this, -1, 'UpdateModule: sMODULE_NAME is invalid.');
		return;
	}
	else if ( row == null )
	{
		callback.call(context||this, -1, 'UpdateModule: row is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Rest.svc/UpdateModule?ModuleName=' + sMODULE_NAME, 'POST', 'application/octet-stream');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							sID = result.d;
							callback.call(context||this, 1, sID);
						}
						else
						{
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else if ( result.status == 0 )
					{
						callback.call(context||this, -1, 'Offline save is not suported at this time.');
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'UpdateModule'));
				}
			});
		}
	}
	try
	{
		xhr.send(JSON.stringify(row));
	}
	catch(e)
	{
		callback.call(context||this, -1, SplendidError.FormatError(e, 'UpdateModule'));
	}
}

background.UpdateModuleTable = function(sTABLE_NAME, row, sID, callback, context)
{
	if ( sTABLE_NAME == null )
	{
		callback.call(context||this, -1, 'UpdateModuleTable: sTABLE_NAME is invalid.');
		return;
	}
	else if ( row == null )
	{
		callback.call(context||this, -1, 'UpdateModuleTable: row is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Rest.svc/UpdateModuleTable?TableName=' + sTABLE_NAME, 'POST', 'application/octet-stream');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							sID = result.d;
							callback.call(context||this, 1, sID);
						}
						else
						{
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'UpdateModuleTable'));
				}
			});
		}
	}
	try
	{
		xhr.send(JSON.stringify(row));
	}
	catch(e)
	{
		callback.call(context||this, -1, SplendidError.FormatError(e, 'UpdateModuleTable'));
	}
}

// 07/01/2017 Paul.  Cache IsAuthenticated for 1 second. 
var lastIsAuthenticated = 0;

// 01/18/2015 Paul.  IsAuthenticated is used by ChatDashboard PopupViewUI. 
background.IsAuthenticated = function(callback, context)
{
	// 07/01/2017 Paul.  Cache IsAuthenticated for 1 second. 
	if ( lastIsAuthenticated > 0 )
	{
		var diff = new Date();
		diff.setTime(diff - lastIsAuthenticated);
		var timeElapsed = diff.getTime();
		if ( timeElapsed < 1000 )
		{
			//console.log('lastIsAuthenticated cached ' + timeElapsed);
			callback.call(context||this, 1, '');
			return;
		}
	}

	var xhr = CreateSplendidRequest('Rest.svc/IsAuthenticated');
	// 12/21/2014 Paul.  Use 2 second timeout for IsAuthenticated. 
	// 07/03/2017 Paul.  We must specify timeout function otherwise we get an uncaught canceled event. Increase to 8 seconds. 
	xhr.timeout = 8000;
	xhr.ontimeout = function (e)
	{
		callback.call(context||this, -1, 'IsAuthenticated timeout');
	};
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							if ( result.d == true )
							{
								// 07/01/2017 Paul.  Cache IsAuthenticated for 1 second. 
								lastIsAuthenticated = (new Date()).getTime();
								callback.call(context||this, 1, '');
							}
							else
							{
								callback.call(context||this, 0, '');
							}
						}
						else
						{
							lastIsAuthenticated = 0;
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else
					{
						lastIsAuthenticated = 0;
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					lastIsAuthenticated = 0;
					callback.call(context||this, -1, SplendidError.FormatError(e, 'IsAuthenticated'));
				}
			});
		}
	}
	try
	{
		xhr.send();
	}
	catch(e)
	{
		lastIsAuthenticated = 0;
		// 03/28/2012 Paul.  We need to return a status and a message, not a result object. 
		if ( Security.USER_ID() == '' )
			callback.call(context||this, 0, '');
		else
			callback.call(context||this, 1, '');
	}
}

// 01/18/2015 Paul.  AuthenticatedMethod is used by ChatDashboard PopupViewUI. 
background.AuthenticatedMethod = function AuthenticatedMethod(callback, context)
{
	background.IsAuthenticated(function(status, message)
	{
		if ( status == 1 )
		{
			callback.call(context||this, 1, null);
		}
		else if ( status == 0 )
		{
			callback.call(context||this, status, 'Failed to authenticate. Please login again. ');
		}
		else
		{
			callback.call(context||this, status, message);
		}
	}, context);
}

chrome.extension.getBackgroundPage = function()
{
	return background;
};

function CreateSplendidRequest(sPath, sMethod, sContentType)
{
	// http://www.w3.org/TR/XMLHttpRequest/
	var xhr = null;
	try
	{
		if ( window.XMLHttpRequest )
			xhr = new XMLHttpRequest();
		else if ( window.ActiveXObject )
			xhr = new ActiveXObject("Msxml2.XMLHTTP");
		
		var url = sREMOTE_SERVER + sPath;
		if ( sMethod === undefined )
			sMethod = 'POST';
		if ( sContentType === undefined )
			sContentType = 'application/json; charset=utf-8';
		xhr.open(sMethod, url, true);
		if ( sAUTHENTICATION == 'Basic' )
			xhr.setRequestHeader('Authorization', 'Basic ' + Base64.encode(sUSER_NAME + ':' + sPASSWORD));
		xhr.setRequestHeader('content-type', sContentType);
		// 09/27/2011 Paul.  Add the URL to the object for debugging purposes. 
		// 10/19/2011 Paul.  IE6 does not allow this. 
		if ( window.XMLHttpRequest )
		{
			xhr.url    = url;
			xhr.Method = sMethod;
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'CreateSplendidRequest');
	}
	return xhr;
}

function GetSplendidResult(xhr, callback, context)
{
	var result = null;
	try
	{
		//alert(dumpObj(xhr, 'xhr.status = ' + xhr.status));
		if ( xhr.responseText.length > 0 )
		{
			result = JSON.parse(xhr.responseText);
			result.status = xhr.status;
			callback.call(context||this, result);
		}
		else if ( xhr.status == 0 || xhr.status == 2 || xhr.status == 12002 || xhr.status == 12007 || xhr.status == 12029 || xhr.status == 12030 || xhr.status == 12031 || xhr.status == 12152 )
		{
		}
		else if ( xhr.status == 405 )
		{
			var sMessage = 'Method Not Allowed.  ' + xhr.url;
			result = { 'status': xhr.status, 'ExceptionDetail': { 'status': xhr.status, 'Message': sMessage } };
			callback.call(context||this, result);
		}
		else
		{
			result = { 'status': xhr.status, 'ExceptionDetail': { 'status': xhr.status, 'Message': xhr.statusText + '(' + xhr.status + ')' } };
			callback.call(context||this, result);
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'GetSplendidResult');
		callback.call(context||this, result);
	}
}

function TerminologyRequest(sMODULE_NAME, sLIST_NAME, sOrderBy, sUSER_LANG)
{
	var sUrl = 'Rest.svc/GetModuleTable?TableName=TERMINOLOGY';
	if ( sOrderBy !== undefined && sOrderBy != null )
		sUrl += '&$orderby=' + sOrderBy;
	if ( sMODULE_NAME == null && sLIST_NAME == null )
	{
		sUrl += '&$filter=' + encodeURIComponent('(LANG eq \'' + sUSER_LANG + '\' and (MODULE_NAME is null or MODULE_NAME eq \'Teams\' or NAME eq \'LBL_NEW_FORM_TITLE\'))');
	}
	else
	{
		sUrl += '&$filter=' + encodeURIComponent('(LANG eq \'' + sUSER_LANG + '\'');
		if ( sMODULE_NAME != null )
			sUrl += ' and MODULE_NAME eq \'' + sMODULE_NAME + '\'';
		else
			sUrl += ' and MODULE_NAME is null';
		if ( sLIST_NAME != null )
			sUrl += ' and LIST_NAME eq \'' + sLIST_NAME + '\'';
		else
			sUrl += ' and LIST_NAME is null';
		sUrl += ')';
	}
	var xhr = CreateSplendidRequest(sUrl, 'GET');
	return xhr;
}

function SystemCacheRequest(sTableName, sOrderBy, sSelectFields, sFilterField, sFilterValue, bDefaultView)
{
	var sUrl = 'Rest.svc/GetModuleTable?TableName=' + sTableName;
	if ( sSelectFields !== undefined && sSelectFields != null )
		sUrl += '&$select=' + sSelectFields;
	if ( sOrderBy !== undefined && sOrderBy != null )
		sUrl += '&$orderby=' + sOrderBy;
	if ( sFilterField !== undefined && sFilterField != null && sFilterValue !== undefined && sFilterValue != null )
	{
		sUrl += '&$filter=' + encodeURIComponent('(' + sFilterField + ' eq \'' + sFilterValue + '\'');
		if ( bDefaultView !== undefined && bDefaultView === true )
			sUrl += ' and DEFAULT_VIEW eq 0';
		sUrl += ')';
	}
	var xhr = CreateSplendidRequest(sUrl, 'GET');
	return xhr;
}

function BindArguments(fn)
{
	var args = [];
	for ( var n = 1; n < arguments.length; n++ )
		args.push(arguments[n]);
	return function () { return fn.apply(this, args); };
}

function RegisterEnterKeyPress(e, sSubmitID)
{
	if ( e != null )
	{
		if ( e.which == 13 )
		{
			var btnSubmit = document.getElementById(sSubmitID);
			if ( btnSubmit != null )
				btnSubmit.click();
			return false;
		}
	}
	else if ( event != null )
	{
		if ( event.keyCode == 13 )
		{
			event.returnValue = false;
			event.cancel = true;
			var btnSubmit = document.getElementById(sSubmitID);
			if ( btnSubmit != null )
				btnSubmit.click();
		}
	}
}

function ValidateCredentials()
{
	return true;
}

function isMobileDevice()
{
	return Sql.ToBoolean(bIS_MOBILE);
}

function isMobileLandscape()
{
	var nWindowWidth = $(window).width();
	return (nWindowWidth >= 800);
}

