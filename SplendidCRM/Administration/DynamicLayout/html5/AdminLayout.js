/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 02/11/2016 Paul.  Add support for new layout editor. 
function AdminLayout_Update(sTABLE_NAME, sVIEW_NAME, obj, callback, context)
{
	if ( Sql.IsEmptyString(sTABLE_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_Update: sTABLE_NAME is invalid.');
		return;
	}
	else if ( Sql.IsEmptyString(sVIEW_NAME) && sTABLE_NAME != 'TERMINOLOGY' )
	{
		callback.call(context||this, -1, 'AdminLayout_Update: sVIEW_NAME is invalid.');
		return;
	}
	else if ( obj == null )
	{
		callback.call(context||this, -1, 'AdminLayout_Update: row is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/UpdateAdminLayout?TableName=' + sTABLE_NAME + '&ViewName=' + sVIEW_NAME, 'POST', 'application/octet-stream');
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
							callback.call(context||this, 1);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_Update'));
				}
			});
		}
	}
	try
	{
		xhr.send(JSON.stringify(obj));
	}
	catch(e)
	{
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_Update'));
	}
}

function AdminLayout_Delete(sTABLE_NAME, sVIEW_NAME, obj, callback, context)
{
	if ( Sql.IsEmptyString(sTABLE_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_Delete: sTABLE_NAME is invalid.');
		return;
	}
	else if ( Sql.IsEmptyString(sVIEW_NAME) && sTABLE_NAME != 'TERMINOLOGY' )
	{
		callback.call(context||this, -1, 'AdminLayout_Delete: sVIEW_NAME is invalid.');
		return;
	}
	else if ( obj == null )
	{
		callback.call(context||this, -1, 'AdminLayout_Delete: row is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/DeleteAdminLayout?TableName=' + sTABLE_NAME + '&ViewName=' + sVIEW_NAME, 'POST', 'application/octet-stream');
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
							callback.call(context||this, 1);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_Delete'));
				}
			});
		}
	}
	try
	{
		xhr.send(JSON.stringify(obj));
	}
	catch(e)
	{
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_Delete'));
	}
}

function AdminLayout_GetModules(callback, context)
{
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminLayoutModules', 'GET');
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
							// 07/18/2018 Paul.  Save the module list so that we can test module validity. 
							if ( result.d instanceof Array )
							{
								var arrModules = result.d;
								MODULES = new Object();
								for ( var i = 0; i < arrModules.length; i++ )
								{
									var module = arrModules[i];
									MODULES[module.ModuleName] = module;
								}
							}
							callback.call(context||this, 1, result.d);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetModules'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetModules'));
	}
}

function AdminLayout_GetAllLists(callback, context)
{
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminLayoutTerminologyLists', 'GET');
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
							for ( var sListName in result.d.results )
							{
								TERMINOLOGY_LISTS[sListName] = result.d.results[sListName];
							}
							callback.call(context||this, 1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetAllLists'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetAllLists'));
	}
}

function AdminLayout_GetTerminology(callback, context)
{
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminLayoutTerminology', 'GET');
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
							//alert(dumpObj(result.d.results, 'result'));
							for ( var i = 0; i < result.d.results.length; i++ )
							{
								var obj = result.d.results[i];
								//Terminology_SetTerm( obj['MODULE_NAME'], obj['NAME'], obj['DISPLAY_NAME']);
								//Terminology_SetListTerm(obj['LIST_NAME'], obj['NAME'], obj['DISPLAY_NAME']);
								if ( obj['LIST_NAME'] == null )
								{
									TERMINOLOGY[Sql.ToString(obj['MODULE_NAME']) + '.' + obj['NAME']] = obj['DISPLAY_NAME'];
									//console.log(Sql.ToString(obj['MODULE_NAME']) + '.' + obj['NAME'] + ' = ' + obj['DISPLAY_NAME']);
								}
								else
								{
									TERMINOLOGY['.' + obj['LIST_NAME'] + '.' + obj['NAME']] = obj['DISPLAY_NAME'];
									//console.log('.' + obj['LIST_NAME'] + '.' + obj['NAME'] + ' = ' + obj['DISPLAY_NAME']);
								}
							}
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetTerminology'));
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
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetTerminology'));
	}
};

// 05/09/2016 Paul.  Specify LayoutType. 
// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
function AdminLayout_GetModuleFields(sMODULE_NAME, sLayoutType, sLayoutName, callback, context)
{
	if ( Sql.IsEmptyString(sMODULE_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_GetModuleFields: sMODULE_NAME is invalid.');
		return;
	}
	// 05/09/2016 Paul.  Specify LayoutType. 
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminLayoutModuleFields?ModuleName=' + sMODULE_NAME + '&LayoutType=' + sLayoutType + '&LayoutName=' + sLayoutName, 'GET');
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
							callback.call(context||this, 1, result.d);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetModuleFields'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetModuleFields'));
	}
}

function AdminLayout_GetRelationshipFields(sTABLE_NAME, sMODULE_NAME, callback, context)
{
	if ( Sql.IsEmptyString(sTABLE_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_GetRelationshipFields: sTABLE_NAME is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminLayoutRelationshipFields?TableName=' + sTABLE_NAME + '&ModuleName=' + sMODULE_NAME, 'GET');
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
							callback.call(context||this, 1, result.d);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetRelationshipFields'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetRelationshipFields'));
	}
}

function AdminLayout_GetEditViewEvents(sEDIT_NAME, callback, context)
{
	if ( Sql.IsEmptyString(sEDIT_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_GetEditViewEvents: sEDIT_NAME is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=EDITVIEWS&$filter=' + encodeURIComponent('NAME eq \'' + sEDIT_NAME + '\''), 'GET');
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetEditViewEvents'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetEditViewEvents'));
	}
}

function AdminLayout_GetDetailViewEvents(sDETAIL_NAME, callback, context)
{
	if ( Sql.IsEmptyString(sDETAIL_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_GetDetailViewEvents: sDETAIL_NAME is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=DETAILVIEWS&$filter=' + encodeURIComponent('NAME eq \'' + sDETAIL_NAME + '\''), 'GET');
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetDetailViewEvents'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetDetailViewEvents'));
	}
}

function AdminLayout_GetListViewEvents(sGRID_NAME, callback, context)
{
	if ( Sql.IsEmptyString(sGRID_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_GetListViewEvents: sGRID_NAME is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=GRIDVIEWS&$filter=' + encodeURIComponent('NAME eq \'' + sGRID_NAME + '\''), 'GET');
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetListViewEvents'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetListViewEvents'));
	}
}

function AdminLayout_GetEditViewFields(sEDIT_NAME, bDEFAULT_VIEW, callback, context)
{
	bDEFAULT_VIEW = Sql.ToBoolean(bDEFAULT_VIEW);
	if ( Sql.IsEmptyString(sEDIT_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_GetEditViewFields: sEDIT_NAME is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=EDITVIEWS_FIELDS&$filter=' + encodeURIComponent('EDIT_NAME eq \'' + sEDIT_NAME + '\' and DEFAULT_VIEW eq \'' + bDEFAULT_VIEW + '\''), 'GET');
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
							if ( !bDEFAULT_VIEW )
								SplendidCache.SetEditViewFields(sEDIT_NAME, result.d.results);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetEditViewFields'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetEditViewFields'));
	}
}

function AdminLayout_GetDetailViewFields(sDETAIL_NAME, bDEFAULT_VIEW, callback, context)
{
	bDEFAULT_VIEW = Sql.ToBoolean(bDEFAULT_VIEW);
	if ( Sql.IsEmptyString(sDETAIL_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_GetDetailViewFields: sDETAIL_NAME is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=DETAILVIEWS_FIELDS&$filter=' + encodeURIComponent('DETAIL_NAME eq \'' + sDETAIL_NAME + '\' and DEFAULT_VIEW eq \'' + bDEFAULT_VIEW + '\''), 'GET');
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
							if ( !bDEFAULT_VIEW )
								SplendidCache.SetDetailViewFields(sDETAIL_NAME, result.d.results);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetDetailViewFields'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetDetailViewFields'));
	}
}

function AdminLayout_GetListViewColumns(sGRID_NAME, bDEFAULT_VIEW, callback, context)
{
	bDEFAULT_VIEW = Sql.ToBoolean(bDEFAULT_VIEW);
	if ( Sql.IsEmptyString(sGRID_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_GetListViewColumns: sGRID_NAME is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=GRIDVIEWS_COLUMNS&$filter=' + encodeURIComponent('GRID_NAME eq \'' + sGRID_NAME + '\' and DEFAULT_VIEW eq \'' + bDEFAULT_VIEW + '\''), 'GET');
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
							if ( !bDEFAULT_VIEW )
								SplendidCache.SetGridViewColumns(sGRID_NAME, result.d.results);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetListViewColumns'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetListViewColumns'));
	}
}

function AdminLayout_GetDetailViewRelationships(sDETAIL_NAME, callback, context)
{
	if ( Sql.IsEmptyString(sDETAIL_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_GetDetailViewRelationships: sDETAIL_NAME is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=DETAILVIEWS_RELATIONSHIPS&$filter=' + encodeURIComponent('DETAIL_NAME eq \'' + sDETAIL_NAME + '\''), 'GET');
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
							SplendidCache.SetDetailViewRelationships(sDETAIL_NAME, result.d.results);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetDetailViewRelationships'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetDetailViewRelationships'));
	}
}

function AdminLayout_GetEditViewRelationships(sEDIT_NAME, callback, context)
{
	if ( Sql.IsEmptyString(sEDIT_NAME) )
	{
		callback.call(context||this, -1, 'AdminLayout_GetEditViewRelationships: sEDIT_NAME is invalid.');
		return;
	}
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=EDITVIEWS_RELATIONSHIPS&$filter=' + encodeURIComponent('EDIT_NAME eq \'' + sEDIT_NAME + '\''), 'GET');
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
							// 03/14/2016 Paul.  SetEditViewRelationships does not exist as it is not supported on HTML5 client. 
							//SplendidCache.SetEditViewRelationships(sEDIT_NAME, result.d.results);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetEditViewRelationships'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AdminLayout_GetEditViewRelationships'));
	}
}

