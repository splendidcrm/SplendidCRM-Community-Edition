/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

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
		//console.log('GetSplendidResult: bMOBILE_CLIENT = ' + bMOBILE_CLIENT + ', bENABLE_OFFLINE = ' + bENABLE_OFFLINE);
		//alert(dumpObj(xhr, 'xhr.status = ' + xhr.status));
		if ( xhr.responseText.length > 0 )
		{
			SplendidStorage.getItem(xhr.url, function(status, item)
			{
				// 10/01/2011 Paul.  We still get status 200 on previously fetched pages even when offline. 
				// 10/19/2011 Paul.  IE6 does not support localStorage. 
				// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
				if ( bIS_OFFLINE && window.localStorage )
				{
					// 10/01/2011 Paul.  If this is a POST, then we must be online. 
					// 10/01/2011 Paul.  If we have results, but have no saved results, then we are online. 
					if ( xhr.Method == 'POST' || ((item === undefined || item == null) && xhr.Method != 'POST') )
					{
						bIS_OFFLINE = false;
					}
					if ( !bIS_OFFLINE && cbNetworkStatusChanged != null )
						cbNetworkStatusChanged();
				}
				// 06/21/2017 Paul.  Capture the HTML 404 error. 
				result = new Object();
				result.status = xhr.status;
				// 07/21/2018 Paul.  Allow HTML tag to have attributes. 
				if ( StartsWith(xhr.responseText, '<html') )
				{
					result.ExceptionDetail = new Object();
					result.ExceptionDetail.Message = xhr.url + ' is not a valid service URL.'
					callback.call(context||this, result);
					return;
				}
				result = JSON.parse(xhr.responseText);
				// 10/19/2011 Paul.  Change location of status so that we can support IE6. 
				result.status = xhr.status;
				// 10/19/2011 Paul.  IE6 does not support localStorage. 
				// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
				// 01/01/2012 Paul.  Firefox is throwing an exception on localStorage when called within a browser extension. 
				// Component returned failure code: 0x80040111 (NS_ERROR_NOT_AVAILABLE) [nsIDOMStorageWindow.localStorage]
				// 02/02/2012 Paul.  We need to use the bENABLE_OFFLINE flag, not the bIS_OFFLINE flag. 
				// 12/01/2014 Paul.  Do not cache for mobile client. 
				if ( bENABLE_OFFLINE && !bMOBILE_CLIENT && window.localStorage )
				{
					// 10/06/2011 Paul.  Whether we are online or offline, we need to check the offline cache. 
					// 10/21/2011 Paul.  Keep the offline cache within localStorage. 
					if ( xhr.url.indexOf('Rest.svc/GetModuleItem?ModuleName=') > 0 && localStorage['OFFLINE_CACHE'] != null )
					{
						var arrOFFLINE_CACHE = JSON.parse(localStorage['OFFLINE_CACHE']);
						//alert(dumpObj(arrOFFLINE_CACHE, 'arrOFFLINE_CACHE loading'));
						if ( arrOFFLINE_CACHE[xhr.url] !== undefined && arrOFFLINE_CACHE[xhr.url] != null )
						{
							result = JSON.parse(item);
							// 10/19/2011 Paul.  Change location of status so that we can support IE6. 
							result.status = xhr.status;
							//alert('using cached version ' + dumpObj(result, ''));
							callback.call(context||this, result);
						}
						else if ( !bIS_OFFLINE && bENABLE_OFFLINE && xhr.Method != 'POST' )
						{
							SplendidStorage.setItem(xhr.url, xhr.responseText, function(status, message)
							{
								// 10/22/2011 Paul.  Save to web site was successful, so failure here is less of an issue. 
								callback.call(context||this, result);
							});
						}
						// 03/28/2012 Paul.  We still need to return the result.  This solves a major problem we were having with IE9 offline mode. 
						else
						{
							callback.call(context||this, result);
						}
					}
					else
					{
						if ( !bIS_OFFLINE && bENABLE_OFFLINE && xhr.Method != 'POST' )
						{
							SplendidStorage.setItem(xhr.url, xhr.responseText, function(status, message)
							{
								// 10/22/2011 Paul.  Save to web site was successful, so failure here is less of an issue. 
								callback.call(context||this, result);
							});
						}
						else
						{
							callback.call(context||this, result);
						}
					}
				}
				else
				{
					callback.call(context||this, result);
				}
			});
		}
		// 09/25/2011 Paul.  Chrome is returning 0 when the actual response is 405. 
		// 10/02/2011 Paul.  IE8 returns 2 when offline. 
		// 11/26/2011 Paul.  IE8 is returning 12029 when ethernet cable is disconnected. (xhr.statusText == 'Unknown')
		// 11/27/2011 Paul.  http://msdn.microsoft.com/en-us/library/aa385465.aspx, http://ajaxref.com/assets/005/5560.pdf
		// 12002  ERROR_INTERNET_TIMEOUT
		// 12007  ERROR_INTERNET_NAME_NOT_RESOLVED
		// 12029  ERROR_INTERNET_CANNOT_CONNECT
		// 12030  ERROR_INTERNET_CONNECTION_ABORTED
		// 12031  ERROR_INTERNET_CONNECTION_RESET
		// 12152  ERROR_HTTP_INVALID_SERVER_RESPONSE
		else if ( xhr.status == 0 || xhr.status == 2 || xhr.status == 12002 || xhr.status == 12007 || xhr.status == 12029 || xhr.status == 12030 || xhr.status == 12031 || xhr.status == 12152 )
		{
			if ( !bIS_OFFLINE )
			{
				bIS_OFFLINE = true;
				if ( cbNetworkStatusChanged != null )
					cbNetworkStatusChanged();
			}
			SplendidStorage.getItem(xhr.url, function(status, item)
			{
				// 10/19/2011 Paul.  IE6 does not support localStorage. 
				//alert(xhr.url + '\r\n, bENABLE_OFFLINE = ' + '' + bENABLE_OFFLINE + '\r\n, status = ' + status + '\r\n, item = ' + item + '\r\n, localStorage[key] = ' + localStorage[xhr.url]);
				if ( status == 1 && item !== undefined && item != null )
				{
					result = JSON.parse(item);
					// 10/02/2011 Paul.  Firefox already returns status 200 when offline and page has been fetched. 
					// Safari on iPad returns status 0, so we need to return 200 for normal behavior. 
					// 10/02/2011 Paul.  We use a special splendidStatus field because the status field is read-only on iPad. 
					// 10/19/2011 Paul.  Change location of status so that we can support IE6. 
					result.status = 200;
					//alert(dumpObj(xhr, 'result.status = ' + result.status));
					callback.call(context||this, result);
				}
				// 11/26/2011 Paul.  IsAuthenticated is a special POST request that needs to return success if the user was previously authenticated. 
				// 11/26/2011 Paul.  IE8 Work Offline will throw an exception in xhr.send() and return: 
				// name: Error number: -2146697208 description: The download of the specified resource has failed. message: The download of the specified resource has failed. 
				else if ( xhr.url.indexOf('Rest.svc/IsAuthenticated') > 0 )
				{
					if ( sUSER_ID === undefined || sUSER_ID == '' || sUSER_ID == null )
						result = { 'status': 0, 'd': false };
					else
						result = { 'status': 0, 'd': true };
					callback.call(context||this, result);
				}
				else
				{
					//alert('bENABLE_OFFLINE = ' + bENABLE_OFFLINE + ', localStorage[xhr.url] = ' + localStorage[xhr.url]);
					// 11/27/2011 Paul.  0, 2, 12029 and 12007 should all return 0 as that is the convention for offline. 
					var sMessage = 'No response (' + xhr.status + ').  ' /* + xhr.url */;
					SplendidError.SystemLog(sMessage + xhr.url);
					result = { 'status': 0, 'ExceptionDetail': { 'status': xhr.status, 'Message': sMessage } };
					callback.call(context||this, result);
				}
			});
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
		// 06/21/2017 Paul.  We don't want an ugly popup error if the Remote Server request fails. 
		//SplendidError.SystemAlert(e, 'GetSplendidResult');
		callback.call(context||this, result);
	}
}

