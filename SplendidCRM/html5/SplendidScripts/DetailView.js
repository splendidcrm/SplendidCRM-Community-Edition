/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function DetailView_LoadAllLayouts(callback, context)
{
	var xhr = SystemCacheRequestAll('GetAllDetailViewsFields');
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
							DETAILVIEWS_FIELDS = result.d.results;
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'DetailView_LoadAllLayouts'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'DetailView_LoadAllLayouts'));
	}
}

function DetailView_LoadItem(sMODULE_NAME, sID, callback, context)
{
	var xhr = CreateSplendidRequest('Rest.svc/GetModuleItem?ModuleName=' + sMODULE_NAME + '&ID=' + sID, 'GET');
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
							// 10/04/2011 Paul.  DetailViewUI.LoadItem returns the row. 
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'DetailView_LoadItem'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'DetailView_LoadItem'));
	}
}

// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
function DetailView_LoadLayout_Raw(sDETAIL_NAME, callback, context)
{
	// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
	var xhr = SystemCacheRequest('DETAILVIEWS_FIELDS', 'FIELD_INDEX asc', null, 'DETAIL_NAME', sDETAIL_NAME, true);
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=DETAILVIEWS_FIELDS&$orderby=FIELD_INDEX asc&$filter=' + encodeURIComponent('(DETAIL_NAME eq \'' + sDETAIL_NAME + '\' and DEFAULT_VIEW eq 0)'), 'GET');
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
							SplendidCache.SetDetailViewFields(sDETAIL_NAME, result.d.results);
							// 10/03/2011 Paul.  DetailView_LoadLayout returns the layout. 
							var layout = SplendidCache.DetailViewFields(sDETAIL_NAME);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'DetailView_LoadLayout'));
				}
			});
		}
	}
	try
	{
		// 10/03/2011 Paul.  DetailView_LoadLayout returns the layout. 
		var layout = SplendidCache.DetailViewFields(sDETAIL_NAME);
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'DetailView_LoadLayout'));
	}
}

// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
function DetailView_LoadLayout(sDETAIL_NAME, callback, context)
{
	if ( Sql.IsEmptyString(sPRIMARY_ROLE_NAME) )
	{
		DetailView_LoadLayout_Raw(sDETAIL_NAME, callback, context);
	}
	else
	{
		DetailView_LoadLayout_Raw(sDETAIL_NAME + '.' + sPRIMARY_ROLE_NAME, function(status, message)
		{
			if ( status == 1 )
			{
				var layout = message;
				if ( layout === undefined || layout == null || layout.length == 0 )
				{
					DetailView_LoadLayout_Raw(sDETAIL_NAME, callback, context);
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

