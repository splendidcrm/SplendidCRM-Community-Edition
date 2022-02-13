/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
// 2. Store and Types. 
// 3. Scripts. 
import Credentials from '../scripts/Credentials';
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest';

export async function AutoComplete_ModuleMethod(sMODULE_NAME, sMETHOD, sREQUEST)
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		if ( sMODULE_NAME == 'Teams' )
		{
			sMODULE_NAME = 'Administration/Teams';
		}
		else if (sMODULE_NAME == 'Tags')
		{
			sMODULE_NAME = 'Administration/Tags';
		}
		// 06/07/2017 Paul.  Add NAICSCodes module. 
		else if (sMODULE_NAME == 'NAICSCodes')
		{
			sMODULE_NAME = 'Administration/NAICSCodes';
		}
		// 06/05/2018 Paul.  sREQUEST has already been stringified. 
		var sBody = sREQUEST;
		let res = await CreateSplendidRequest(sMODULE_NAME + '/AutoComplete.asmx/' + sMETHOD, 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return json.d;
	}
}

