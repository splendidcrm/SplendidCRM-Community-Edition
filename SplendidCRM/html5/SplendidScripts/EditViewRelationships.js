/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function EditViewRelationships_LoadAllLayouts(callback, context)
{
	var xhr = SystemCacheRequestAll('GetAllEditViewsRelationships');
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
							EDITVIEWS_RELATIONSHIPS = result.d.results;
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'EditViewRelationships_LoadAllLayouts'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'EditViewRelationships_LoadAllLayouts'));
	}
}

function EditViewRelationships_LoadLayout(sEDIT_NAME, callback, context)
{
	// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
	var xhr = SystemCacheRequest('EDITVIEWS_RELATIONSHIPS', 'RELATIONSHIP_ORDER asc', null, 'EDIT_NAME', sEDIT_NAME);
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=EDITVIEWS_RELATIONSHIPS&$orderby=RELATIONSHIP_ORDER asc&$filter=' + encodeURIComponent('EDIT_NAME eq \'' + sEDIT_NAME + '\''), 'GET');
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
							SplendidCache.SetEditViewRelationships(sEDIT_NAME, result.d.results);
							// 10/04/2011 Paul.  EditViewRelationships_LoadLayout returns the layout. 
							var layout = SplendidCache.EditViewRelationships(sEDIT_NAME);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'EditViewRelationships_LoadLayout'));
				}
			});
		}
	}
	try
	{
		var layout = SplendidCache.EditViewRelationships(sEDIT_NAME);
		if ( layout == null )
			xhr.send();
		else
			callback.call(context||this, 1, layout);
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'EditViewRelationships_LoadLayout'));
	}
}

