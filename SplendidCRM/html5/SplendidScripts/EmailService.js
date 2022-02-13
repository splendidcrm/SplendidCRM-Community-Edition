/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function EmailService_ParseEmail(request, callback, context)
{
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
	var xhr = CreateSplendidRequest('BrowserExtensions/EmailService.svc/ParseEmail');
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
						// 10/19/2011 Paul.  EmailService_ParseEmail now returns the result without the d. 
						if ( result.d !== undefined )
							callback.call(context||this, 1, result.d);
						else
							callback.call(context||this, -1, xhr.responseText);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'EmailService_ParseEmail'));
				}
			});
		}
	}
	try
	{
		xhr.send('{"EmailHeaders": ' + JSON.stringify(request) + '}');
	}
	catch(e)
	{
		callback.call(context||this, -1, SplendidError.FormatError(e, 'EmailService_ParseEmail'));
	}
}

function EmailService_ArchiveEmail(request, callback, context)
{
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
	var xhr = CreateSplendidRequest('BrowserExtensions/EmailService.svc/ArchiveEmail', 'POST', 'application/octet-stream');
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
						// 10/19/2011 Paul.  EmailService_ArchiveEmail now returns the result without the d. 
						if ( result.d !== undefined )
							callback.call(context||this, 1, result.d);
						else
							callback.call(context||this, -1, xhr.responseText);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'EmailService_ArchiveEmail'));
				}
			});
		}
	}
	try
	{
		xhr.send(request);
	}
	catch(e)
	{
		callback.call(context||this, -1, SplendidError.FormatError(e, 'EmailService_ArchiveEmail'));
	}
}

function EmailService_SetEmailRelationships(sID, arrSelection, callback, context)
{
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
	var xhr = CreateSplendidRequest('BrowserExtensions/EmailService.svc/SetEmailRelationships');
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
						// 10/19/2011 Paul.  EmailService_SetEmailRelationships now returns the result without the d. 
						if ( result.d !== undefined )
							callback.call(context||this, 1, result.d);
						else
							callback.call(context||this, -1, xhr.responseText);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'EmailService_SetEmailRelationships'));
				}
			});
		}
	}
	try
	{
		xhr.send('{"ID": ' + JSON.stringify(sID) + ', "Selection": ' + JSON.stringify(arrSelection) + '}');
	}
	catch(e)
	{
		callback.call(context||this, -1, SplendidError.FormatError(e, 'EmailService_SetEmailRelationships'));
	}
}

