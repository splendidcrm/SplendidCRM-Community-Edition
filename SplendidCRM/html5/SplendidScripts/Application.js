/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function Application_Modules(callback, context)
{
	// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
	var xhr = SystemCacheRequest('MODULES', 'MODULE_NAME asc');
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=MODULES&$orderby=MODULE_NAME asc', 'GET');
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
							MODULES = new Object();
							for ( var i = 0; i < result.d.results.length; i++ )
							{
								var sMODULE_NAME = result.d.results[i].MODULE_NAME;
								MODULES[sMODULE_NAME] = result.d.results[i];
							}
							//alert(dumpObj(MODULES, 'MODULES'));
							callback.call(context||this, 1, MODULES);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'Application_Modules'));
				}
			});
		}
	}
	try
	{
		if ( MODULES == null )
			xhr.send();
		else
			callback.call(context||this, 1, MODULES);
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'Application_Modules'));
	}
}

function Application_Config(callback, context)
{
	// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
	var xhr = SystemCacheRequest('CONFIG', 'NAME asc', 'NAME,VALUE');
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=CONFIG&$select=NAME,VALUE&$orderby=NAME asc', 'GET');
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
							CONFIG = new Object();
							for ( var i = 0; i < result.d.results.length; i++ )
							{
								var sNAME = result.d.results[i].NAME;
								CONFIG[sNAME] = result.d.results[i].VALUE;
							}
							//alert(dumpObj(CONFIG, 'CONFIG'));
							callback.call(context||this, 1, CONFIG);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'Application_Config'));
				}
			});
		}
	}
	try
	{
		if ( CONFIG == null )
			xhr.send();
		else
			callback.call(context||this, 1, CONFIG);
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'Application_Config'));
	}
}

function Application_Teams(callback, context)
{
	// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
	var xhr = SystemCacheRequest('TEAMS', 'NAME asc', 'ID,NAME');
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TEAMS&$select=ID,NAME&$orderby=NAME asc', 'GET');
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
							TEAMS = new Object();
							for ( var i = 0; i < result.d.results.length; i++ )
							{
								var sID = result.d.results[i].ID;
								TEAMS[sID] = result.d.results[i];
							}
							//alert(dumpObj(TEAMS, 'TEAMS'));
							callback.call(context||this, 1, TEAMS);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'Application_Teams'));
				}
			});
		}
	}
	try
	{
		// 01/01/2012 Paul.  Make this call more efficient by checking the enabled flag. 
		var b = SplendidCache.Config('enable_team_management');
		if ( b === undefined || b == null || b == false )
			b = false;
		else if ( b == 'true' || b == 'on' || b == '1' || b == true || b == 1 )
			b = true;
		
		if ( b )
		{
			if ( TEAMS == null )
				xhr.send();
			else
				callback.call(context||this, 1, TEAMS);
		}
		else
		{
			TEAMS = new Object();
			callback.call(context||this, 1, TEAMS);
		}
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'Application_Teams'));
	}
}

// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
function Application_Users(callback, context)
{
	var xhr = SystemCacheRequest('USERS', 'USER_NAME asc', 'ID,USER_NAME,NAME');
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=USERS&$select=ID,USER_NAME,NAME&$orderby=USER_NAME asc', 'GET');
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
							USERS = new Object();
							for ( var i = 0; i < result.d.results.length; i++ )
							{
								var sID = result.d.results[i].ID;
								USERS[sID] = result.d.results[i];
							}
							//alert(dumpObj(USERS, 'USERS'));
							callback.call(context||this, 1, USERS);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'Application_Users'));
				}
			});
		}
	}
	try
	{
		// 12/31/2017 Paul. Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		var b = SplendidCache.Config('enable_dynamic_assignment');
		if ( b === undefined || b == null || b == false )
			b = false;
		else if ( b == 'true' || b == 'on' || b == '1' || b == true || b == 1 )
			b = true;
		
		if ( b )
		{
			if ( USERS == null )
				xhr.send();
			else
				callback.call(context||this, 1, USERS);
		}
		else
		{
			USERS = new Object();
			callback.call(context||this, 1, USERS);
		}
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'Application_Users'));
	}
}

// 02/27/2016 Paul.  Combine all layout gets. 
function Application_GetAllLayouts(callback, context)
{
	var dtStart = new Date();
	var xhr = SystemCacheRequestAll('GetAllLayouts');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			var dtEnd = new Date();
			var nSeconds = Math.round((dtEnd.getTime() - dtStart.getTime()) / 1000);
			callback(2, 'Application_GetAllLayouts took ' + nSeconds.toString() + ' seconds');
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							//alert(dumpObj(result.d, 'd'));
							GRIDVIEWS_COLUMNS         = result.d.GRIDVIEWS_COLUMNS        ;
							DETAILVIEWS_FIELDS        = result.d.DETAILVIEWS_FIELDS       ;
							EDITVIEWS_FIELDS          = result.d.EDITVIEWS_FIELDS         ;
							DETAILVIEWS_RELATIONSHIPS = result.d.DETAILVIEWS_RELATIONSHIPS;
							DYNAMIC_BUTTONS           = result.d.DYNAMIC_BUTTONS          ;
							TERMINOLOGY_LISTS         = result.d.TERMINOLOGY_LISTS        ;
							TERMINOLOGY               = result.d.TERMINOLOGY              ;
							TAX_RATES                 = result.d.TAX_RATES                ;
							DISCOUNTS                 = result.d.DISCOUNTS                ;
							callback(1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
						}
						else
						{
							callback(-1, xhr.responseText);
						}
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback(-1, result.ExceptionDetail.Message);
						else
							callback(-1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback(-1, SplendidError.FormatError(e, 'Application_GetAllLayouts'));
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
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback(-1, SplendidError.FormatError(e, 'Application_GetAllLayouts'));
	}
}

