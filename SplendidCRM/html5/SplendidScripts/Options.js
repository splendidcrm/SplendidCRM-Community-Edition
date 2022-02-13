/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function ShowOptionsDialog(cbLoginComplete)
{
	try
	{
		if ( cbLoginComplete === undefined )
		{
			cbLoginComplete = function(status, message)
			{
				if ( status == 1 )
				{
					// 08/26/2014 Paul.  This is not the best place to set the last login value. 
					//localStorage['LastLoginRemote'] = false;
					SplendidError.SystemMessage('');
				}
			};
		}
		LoginViewUI_Load('divMainLayoutPanel', 'divMainActionsPanel', cbLoginComplete, function(status, message)
		{
			if ( status == 1 )
			{
				SplendidError.SystemMessage('');
			}
			else
			{
				SplendidError.SystemMessage(message);
			}
		});
	}
	catch(e)
	{
		SplendidError.SystemError(e, 'Options.js ShowOptionsDialog()');
	}
}

