/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function TabMenu_Load(callback, context)
{
	// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
	var xhr = SystemCacheRequest('TAB_MENUS', 'TAB_ORDER asc');
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TAB_MENUS&$orderby=TAB_ORDER asc', 'GET');
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
							TAB_MENU = result.d.results;
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'TabMenu_Load'));
				}
			});
		}
	}
	try
	{
		if ( TAB_MENU == null )
			xhr.send();
		else
			callback.call(context||this, 1, TAB_MENU);
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'TabMenu_Load'));
	}
}
