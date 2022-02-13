/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function AutoComplete_ModuleMethod(sMODULE_NAME, sMETHOD, sREQUEST, callback, context)
{
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
	if ( sMODULE_NAME == 'Teams' )
		sMODULE_NAME = 'Administration/Teams';
	else if ( sMODULE_NAME == 'Tags' )
		sMODULE_NAME = 'Administration/Tags';
	// 06/07/2017 Paul.  Add NAICSCodes module. 
	else if ( sMODULE_NAME == 'NAICSCodes' )
		sMODULE_NAME = 'Administration/NAICSCodes';
	var xhr = CreateSplendidRequest(sMODULE_NAME + '/AutoComplete.asmx/' + sMETHOD);
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
						callback.call(context||this, 1, result.d);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AutoComplete_ModuleMethod'));
				}
			});
		}
	}
	try
	{
		xhr.send(sREQUEST);
	}
	catch(e)
	{
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AutoComplete_ModuleMethod'));
	}
}

