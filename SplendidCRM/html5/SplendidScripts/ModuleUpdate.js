/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function DeleteModuleItem(sMODULE_NAME, sID, callback, context)
{
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
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

function UpdateCache(sMODULE_NAME, row, sID)
{
	//alert('UpdateCache(' + sMODULE_NAME + ', ' + sID + ')');
	// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
	// 12/01/2014 Paul.  Do not cache for mobile client. 
	if ( bENABLE_OFFLINE && !bMOBILE_CLIENT && window.localStorage )
	{
		SplendidStorage.foreach(function(status, key, value)
		{
			if ( status == 1 )
			{
				// 11/28/2011 Paul.  Remove module lists, but not the default. 
				if ( key.indexOf('Rest.svc/GetModuleList?ModuleName=' + sMODULE_NAME + '&') > 0 )
				{
					var bFound = false;
					var result = JSON.parse(value);
					// 12/06/2014 Paul.  Make sure that cached value is a valid result. 
					if ( result.d !== undefined && result.d.results !== undefined )
					{
						var rows = result.d.results;
						for ( var i = 0; i < rows.length; i++ )
						{
							if ( rows[i]['ID'] == sID )
							{
								rows[i] = row;
								bFound = true;
							}
						}
						if ( !bFound )
						{
							// 11/28/2011 Paul.  If the item does not exist, then add it to the end. 
							rows.push(row);
						}
						value = JSON.stringify(result);
						SplendidStorage.setItem(key, value, function(status, message)
						{
						});
					}
				}
			}
		});
	}
}

function UpdateModule(sMODULE_NAME, row, sID, callback, context)
{
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
	else if ( sMODULE_NAME == null )
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
							// 10/11/2011 Paul.  We only need this logic if Offline has been enabled. 
							// Firefox will throw an exception when localStorage is called within a browser extension. 
							// 10/19/2011 Paul.  IE6 does not support localStorage. 
							// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
							if ( bENABLE_OFFLINE && window.localStorage && (sID !== undefined && sID != null && sID != '') )
							{
								var key = sREMOTE_SERVER + 'Rest.svc/GetModuleItem?ModuleName=' + sMODULE_NAME + '&ID=' + sID;
								var arrOFFLINE_CACHE = new Object();
								if ( localStorage['OFFLINE_CACHE'] != null )
								{
									arrOFFLINE_CACHE = JSON.parse(localStorage['OFFLINE_CACHE']);
								}
								if ( arrOFFLINE_CACHE[key] != null )
								{
									// 10/07/2011 Paul.  Delete is not working. 
									delete arrOFFLINE_CACHE[key];
									// 10/16/2011 Paul.  Lets try using delete, but if it fails, then copy the object. 
									if ( arrOFFLINE_CACHE[key] != null )
									{
										var arrNEW_CACHE = new Object();
										for ( var keyCopy in arrOFFLINE_CACHE )
										{
											if ( key != keyCopy )
												arrNEW_CACHE[keyCopy] = arrOFFLINE_CACHE[keyCopy];
										}
										arrOFFLINE_CACHE = arrNEW_CACHE;
									}
									//alert(dumpObj(arrOFFLINE_CACHE, 'delete cache item'));
									localStorage['OFFLINE_CACHE'] = JSON.stringify(arrOFFLINE_CACHE);
								}
							}
							// 10/16/2011 Paul.  sID is now a parameter so that it can be distinguished from Offline ID for a new record. 
							// We want to make sure to send a NULL for new records so that the ID is generated on the server with a true GUID. 
							// JavaScript cannot generate a true GUID, but this generated value should be valid on the single device. 
							sID = result.d;
							
							// 11/28/2011 Paul.  We need to update any cached list. 
							UpdateCache(sMODULE_NAME, row, sID);
							
							callback.call(context||this, 1, sID);
						}
						else
						{
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else if ( result.status == 0 )
					{
						// 10/02/2011 Paul.  When offline, we need to save to a separate area. 
						// 10/19/2011 Paul.  IE6 does not support localStorage. 
						// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
						if ( bENABLE_OFFLINE && window.localStorage )
						{
							var arrOFFLINE_CACHE = new Object();
							if ( localStorage['OFFLINE_CACHE'] != null )
							{
								arrOFFLINE_CACHE = JSON.parse(localStorage['OFFLINE_CACHE']);
							}
							// 10/16/2011 Paul.  sID is now a parameter so that it can be distinguished from Offline ID for a new record. 
							// We want to make sure to send a NULL for new records so that the ID is generated on the server with a true GUID. 
							// JavaScript cannot generate a true GUID, but this generated value should be valid on the single device. 
							//var sID = row['ID'];
							if ( sID === undefined || sID == null || sID == '' )
							{
								// http://www.broofa.com/2008/09/javascript-uuid-function/
								sID = Math.uuid().toLowerCase();
								//row['ID'] = sID;
							}
							var key = sREMOTE_SERVER + 'Rest.svc/GetModuleItem?ModuleName=' + sMODULE_NAME + '&ID=' + sID;
							if ( arrOFFLINE_CACHE[key] == null )
								arrOFFLINE_CACHE[key] = new Object();
							// 10/11/2011 Paul.  We are having problems with the iterator key, so save within the object. 
							arrOFFLINE_CACHE[key].KEY           = key;
							arrOFFLINE_CACHE[key].ID            = sID;
							arrOFFLINE_CACHE[key].NAME         = row['NAME'];
							arrOFFLINE_CACHE[key].MODULE_NAME   = sMODULE_NAME;
							arrOFFLINE_CACHE[key].DATE_CACHED   = (new Date()).toDateString();
							arrOFFLINE_CACHE[key].DATE_MODIFIED = arrOFFLINE_CACHE[key].DATE_CACHED
							if ( row['DATE_MODIFIED'] !== undefined )
								arrOFFLINE_CACHE[key].DATE_MODIFIED = row['DATE_MODIFIED'];
							if ( row['FIRST_NAME'] !== undefined )
							{
								row['NAME'] = row['FIRST_NAME'] + ' ' + row['LAST_NAME'];
								arrOFFLINE_CACHE[key].NAME = row['NAME'];
							}
							
							var result = { 'd': { 'results': row } };
							// 10/06/2011 Paul.  By storing the offline cached data in the same location as the online cached data, we can reduce the customizations. 
							localStorage[key] = JSON.stringify(result);
							localStorage['OFFLINE_CACHE'] = JSON.stringify(arrOFFLINE_CACHE);
							
							// 11/28/2011 Paul.  We need to update any cached list. 
							UpdateCache(sMODULE_NAME, row, sID);
							
							callback.call(context||this, 3, sID);
						}
						else
						{
							callback.call(context||this, -1, 'Offline save is not suported at this time.');
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

function UpdateModuleTable(sTABLE_NAME, row, sID, callback, context)
{
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
	else if ( sTABLE_NAME == null )
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

function DeleteRelatedItem(sPRIMARY_MODULE, sPRIMARY_ID, sRELATED_MODULE, sRELATED_ID, callback, context)
{
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
	else if ( sPRIMARY_MODULE == null )
	{
		callback.call(context||this, -1, 'DeleteRelatedItem: sPRIMARY_MODULE is invalid.');
		return;
	}
	else if ( sRELATED_MODULE == null )
	{
		callback.call(context||this, -1, 'DeleteRelatedItem: sRELATED_MODULE is invalid.');
		return;
	}
	else if ( sPRIMARY_ID == null )
	{
		callback.call(context||this, -1, 'DeleteRelatedItem: sPRIMARY_ID is invalid.');
		return;
	}
	else if ( sRELATED_ID == null )
	{
		callback.call(context||this, -1, 'DeleteRelatedItem: sRELATED_ID is invalid.');
		return;
	}
	var row = new Object();
	row['ModuleName'   ] = sPRIMARY_MODULE;
	row['ID'           ] = sPRIMARY_ID    ;
	row['RelatedModule'] = sRELATED_MODULE;
	row['RelatedID'    ] = sRELATED_ID    ;
	
	var xhr = CreateSplendidRequest('Rest.svc/DeleteRelatedItem', 'POST');
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
						// 10/28/2012 Paul.  It does not make sense to allow deletes at this time. 
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'DeleteRelatedItem'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'DeleteRelatedItem'));
	}
}

function UpdateRelatedItem(sPRIMARY_MODULE, sPRIMARY_ID, sRELATED_MODULE, sRELATED_ID, callback, context)
{
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
	else if ( sPRIMARY_MODULE == null )
	{
		callback.call(context||this, -1, 'UpdateRelatedItem: sPRIMARY_MODULE is invalid.');
		return;
	}
	else if ( sRELATED_MODULE == null )
	{
		callback.call(context||this, -1, 'UpdateRelatedItem: sRELATED_MODULE is invalid.');
		return;
	}
	else if ( sPRIMARY_ID == null )
	{
		callback.call(context||this, -1, 'UpdateRelatedItem: sPRIMARY_ID is invalid.');
		return;
	}
	else if ( sRELATED_ID == null )
	{
		callback.call(context||this, -1, 'UpdateRelatedItem: sRELATED_ID is invalid.');
		return;
	}
	var row = new Object();
	row['ModuleName'   ] = sPRIMARY_MODULE;
	row['ID'           ] = sPRIMARY_ID    ;
	row['RelatedModule'] = sRELATED_MODULE;
	row['RelatedID'    ] = sRELATED_ID    ;
	
	var xhr = CreateSplendidRequest('Rest.svc/UpdateRelatedItem', 'POST');
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
						// 10/28/2012 Paul.  It does not make sense to allow deletes at this time. 
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'UpdateRelatedItem'));
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
		callback.call(context||this, -1, SplendidError.FormatError(e, 'UpdateRelatedItem'));
	}
}

