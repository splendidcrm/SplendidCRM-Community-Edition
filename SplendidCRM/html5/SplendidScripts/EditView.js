/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function EditView_LoadAllLayouts(callback, context)
{
	var xhr = SystemCacheRequestAll('GetAllEditViewsFields');
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
							EDITVIEWS_FIELDS = result.d.results;
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'EditView_LoadAllLayouts'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'EditView_LoadAllLayouts'));
	}
}

function EditView_LoadItem(sMODULE_NAME, sID, callback, context)
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
							// 10/04/2011 Paul.  EditViewUI.LoadItem returns the row. 
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'EditView_LoadItem'));
				}
			});
		}
	}
	try
	{
		// 10/07/2011 Paul.  We want to allow an empty ID to return a valid empty result. 
		// 10/10/2011 Paul.  Sql object is not available in the background page. 
		if ( sID === undefined || sID == null || sID == '' )
		{
			var row = new Object();
			row['ID'] = null;
			callback.call(context||this, 1, row);
		}
		else
		{
			xhr.send();
		}
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'EditView_LoadItem'));
	}
}

// 03/30/2016 Paul.  Convert requires special processing. 
function EditView_ConvertItem(sMODULE_NAME, sSOURCE_MODULE_NAME, sSOURCE_ID, callback, context)
{
	var xhr = CreateSplendidRequest('Rest.svc/ConvertModuleItem?ModuleName=' + sMODULE_NAME + '&SourceModuleName=' + sSOURCE_MODULE_NAME + '&SourceID=' + sSOURCE_ID, 'GET');
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'EditView_LoadItem'));
				}
			});
		}
	}
	try
	{
		if ( sSOURCE_ID === undefined || sSOURCE_ID == null || sSOURCE_ID == '' )
		{
			var row = new Object();
			row['ID'] = null;
			callback.call(context||this, 1, row);
		}
		else
		{
			xhr.send();
		}
	}
	catch(e)
	{
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'EditView_LoadItem'));
	}
}

// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
function EditView_LoadLayout_Raw(sEDIT_NAME, callback, context)
{
	// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
	var xhr = SystemCacheRequest('EDITVIEWS_FIELDS', 'FIELD_INDEX asc', null, 'EDIT_NAME', sEDIT_NAME, true);
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=EDITVIEWS_FIELDS&$orderby=FIELD_INDEX asc&$filter=' + encodeURIComponent('(EDIT_NAME eq \'' + sEDIT_NAME + '\' and DEFAULT_VIEW eq 0)'), 'GET');
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
							SplendidCache.SetEditViewFields(sEDIT_NAME, result.d.results);
							// 10/04/2011 Paul.  EditView_LoadLayout returns the layout. 
							var layout = SplendidCache.EditViewFields(sEDIT_NAME);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'EditView_LoadLayout'));
				}
			});
		}
	}
	try
	{
		// 10/03/2011 Paul.  EditView_LoadLayout returns the layout. 
		var layout = SplendidCache.EditViewFields(sEDIT_NAME);
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'EditView_LoadLayout'));
	}
}

// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
function EditView_LoadLayout(sEDIT_NAME, callback, context)
{
	if ( Sql.IsEmptyString(sPRIMARY_ROLE_NAME) )
	{
		EditView_LoadLayout_Raw(sEDIT_NAME, callback, context);
	}
	else
	{
		EditView_LoadLayout_Raw(sEDIT_NAME + '.' + sPRIMARY_ROLE_NAME, function(status, message)
		{
			if ( status == 1 )
			{
				var layout = message;
				if ( layout === undefined || layout == null || layout.length == 0 )
				{
					EditView_LoadLayout_Raw(sEDIT_NAME, callback, context);
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

