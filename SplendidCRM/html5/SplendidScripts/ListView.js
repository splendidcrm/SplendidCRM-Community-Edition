/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function ListView_LoadAllLayouts(callback, context)
{
	var xhr = SystemCacheRequestAll('GetAllGridViewsColumns');
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
							//alert(dumpObj(result.d, 'd'));
							GRIDVIEWS_COLUMNS = result.d.results;
							callback.call(context||this, 1, null);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadAllLayouts'));
				}
			}, context||this);
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadAllLayouts'));
	}
}

function ListView_LoadTable(sTABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, callback, context)
{
	// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
	if ( sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '' )
	{
		sSORT_FIELD     = '';
		sSORT_DIRECTION = '';
	}
	var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=' + sTABLE_NAME + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION) + '&$select=' + escape(sSELECT) + '&$filter=' + escape(sFILTER), 'GET');
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
							// 10/04/2011 Paul.  ListView_LoadTable returns the rows. 
							callback.call(context||this, 1, result.d.results);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadTable'));
				}
			}, context||this);
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadTable'));
	}
}

// 06/13/2017 Paul.  Add pagination. 
function ListView_LoadTablePaginated(sTABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, nTOP, nSKIP, callback, context)
{
	// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
	if ( sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '' )
	{
		sSORT_FIELD     = '';
		sSORT_DIRECTION = '';
	}
	var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=' + sTABLE_NAME + '&$top=' + nTOP + '&$skip=' + nSKIP + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION) + '&$select=' + escape(sSELECT) + '&$filter=' + escape(sFILTER), 'GET');
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
							// 10/04/2011 Paul.  ListView_LoadTable returns the rows. 
							// 04/21/2017 Paul.  We need to return the total when using nTOP. 
							callback.call(context||this, 1, result.d.results, result.__total);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadTable'));
				}
			}, context||this);
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadTable'));
	}
}

// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
function ListView_LoadModule(sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, callback, context)
{
	// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
	if ( sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '' )
	{
		sSORT_FIELD     = '';
		sSORT_DIRECTION = '';
	}
	var xhr = CreateSplendidRequest('Rest.svc/GetModuleList?ModuleName=' + sMODULE_NAME + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION) + '&$select=' + escape(sSELECT) + '&$filter=' + escape(sFILTER), 'GET');
	xhr.SearchValues = rowSEARCH_VALUES;
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
							// 10/04/2011 Paul.  ListView_LoadModule returns the rows. 
							// 04/21/2017 Paul.  We need to return the total when using nTOP. 
							callback.call(context||this, 1, result.d.results, result.__total);
						}
						else
						{
							// 05/18/2017 Paul.  We can get an error with status == 200. 
							if ( result.ExceptionDetail !== undefined )
								callback.call(context||this, -1, result.ExceptionDetail.Message);
							else
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadModule'));
				}
			}, context||this);
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadModule'));
	}
}

// 04/22/2017 Paul.  Add pagination. 
function ListView_LoadModulePaginated(sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, callback, context)
{
	// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
	if ( sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '' )
	{
		sSORT_FIELD     = '';
		sSORT_DIRECTION = '';
	}
	var xhr = CreateSplendidRequest('Rest.svc/GetModuleList?ModuleName=' + sMODULE_NAME + '&$top=' + nTOP + '&$skip=' + nSKIP + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION) + '&$select=' + escape(sSELECT) + '&$filter=' + escape(sFILTER), 'GET');
	xhr.SearchValues = rowSEARCH_VALUES;
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
							// 10/04/2011 Paul.  ListView_LoadModule returns the rows. 
							// 04/21/2017 Paul.  We need to return the total when using nTOP. 
							callback.call(context||this, 1, result.d.results, result.__total);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadModule'));
				}
			}, context||this);
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadModule'));
	}
}

// 05/21/2017 Paul.  HTML5 Dashboard requires aggregates. 
function ListView_LoadTableWithAggregate(sTABLE_NAME, sORDER_BY, sSELECT, sFILTER, sGROUP_BY, sAGGREGATE, callback, context)
{
	// https://www.visualstudio.com/en-us/docs/report/analytics/aggregated-data-analytics
	var sAPPLY = '';
	if ( !Sql.IsEmptyString(sGROUP_BY) && !Sql.IsEmptyString(sAGGREGATE) )
	{
		// Aggregate types: count, countdistinct, sum, avg, min, max
		sAPPLY = 'groupby((' + sGROUP_BY + '), aggregate(' + sAGGREGATE + '))';
	}
	var obj = new Object();
	obj['$orderby'] = sORDER_BY;
	obj['$select' ] = sSELECT  ;
	obj['$filter' ] = sFILTER  ;
	obj['$apply'  ] = sAPPLY   ;
	var xhr = CreateSplendidRequest('Rest.svc/PostModuleTable?TableName=' + sTABLE_NAME, 'POST', 'application/octet-stream');
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
							// 10/04/2011 Paul.  ListView_LoadModule returns the rows. 
							// 04/21/2017 Paul.  We need to return the total when using nTOP. 
							callback.call(context||this, 1, result.d.results, result.__total);
						}
						else
						{
							// 05/18/2017 Paul.  We can get an error with status == 200. 
							if ( result.ExceptionDetail !== undefined )
								callback.call(context||this, -1, result.ExceptionDetail.Message);
							else
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadModule'));
				}
			}, context||this);
		}
	}
	try
	{
		xhr.send(JSON.stringify(obj));
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadModule'));
	}
}

// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
function ListView_LoadLayout_Raw(sGRID_NAME, callback, context)
{
	// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
	var xhr = SystemCacheRequest('GRIDVIEWS_COLUMNS', 'COLUMN_INDEX asc', null, 'GRID_NAME', sGRID_NAME, true);
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=GRIDVIEWS_COLUMNS&$orderby=COLUMN_INDEX asc&$filter=' + encodeURIComponent('(GRID_NAME eq \'' + sGRID_NAME + '\' and DEFAULT_VIEW eq 0)'), 'GET');
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
							SplendidCache.SetGridViewColumns(sGRID_NAME, result.d.results);
							// 10/03/2011 Paul.  ListView_LoadLayout returns the layout. 
							var layout = SplendidCache.GridViewColumns(sGRID_NAME);
							callback.call(context||this, 1, layout);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadLayout'));
				}
			}, context||this);
		}
	}
	try
	{
		// 10/03/2011 Paul.  ListView_LoadLayout returns the layout. 
		var layout = SplendidCache.GridViewColumns(sGRID_NAME);
		if ( layout == null )
		{
			xhr.send();
		}
		else
		{
			callback.call(context||this, 1, layout);
		}
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadLayout'));
	}
}

// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
function ListView_LoadLayout(sGRID_NAME, callback, context)
{
	if ( Sql.IsEmptyString(sPRIMARY_ROLE_NAME) )
	{
		ListView_LoadLayout_Raw(sGRID_NAME, callback, context);
	}
	else
	{
		ListView_LoadLayout_Raw(sGRID_NAME + '.' + sPRIMARY_ROLE_NAME, function(status, message)
		{
			if ( status == 1 )
			{
				var layout = message;
				if ( layout === undefined || layout == null || layout.length == 0 )
				{
					ListView_LoadLayout_Raw(sGRID_NAME, callback, context);
				}
				else
				{
					callback.call(context||this, 1, layout);
				}
			}
			else
			{
				callback.call(context||this, status, message);
			}
		}, context);
	}
}

// 03/25/2020 Paul.  New service call as the process list has special filtering rules. 
function ListView_LoadProcessPaginated(sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, nTOP, nSKIP, bMyList, callback, context)
{
	var obj = new Object();
	obj['$top'         ] = nTOP       ;
	obj['$skip'        ] = nSKIP      ;
	obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
	obj['$select'      ] = sSELECT    ;
	obj['$filter'      ] = sFILTER    ;
	obj['MyList'       ] = bMyList    ;
	var xhr = CreateSplendidRequest('Processes/Rest.svc/PostModuleList', 'POST', 'application/octet-stream');
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
							// 10/04/2011 Paul.  ListView_LoadModule returns the rows. 
							// 04/21/2017 Paul.  We need to return the total when using nTOP. 
							callback.call(context||this, 1, result.d.results, result.__total);
						}
						else
						{
							// 05/18/2017 Paul.  We can get an error with status == 200. 
							if ( result.ExceptionDetail !== undefined )
								callback.call(context||this, -1, result.ExceptionDetail.Message);
							else
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadProcessPaginated'));
				}
			}, context||this);
		}
	}
	try
	{
		xhr.send(JSON.stringify(obj));
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'ListView_LoadProcessPaginated'));
	}
}

