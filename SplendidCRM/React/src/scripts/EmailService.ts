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

export async function EmailService_ParseEmail(request): Promise<any>
{
	if (!Credentials.ValidateCredentials)
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		var sBody = '{"EmailHeaders": ' + JSON.stringify(request) + '}';
		let res = await CreateSplendidRequest('BrowserExtensions/EmailService.svc/ParseEmail', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return json.d;
	}
}

export async function EmailService_ArchiveEmail(request): Promise<any>
{
	if (!Credentials.ValidateCredentials)
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		let res = await CreateSplendidRequest('BrowserExtensions/EmailService.svc/ArchiveEmail', 'POST', 'application/octet-stream', JSON.stringify(request));
		let json = await GetSplendidResult(res);
		return json.d;
	}
}

export async function EmailService_SetEmailRelationships(sID, arrSelection): Promise<any>
{
	if (!Credentials.ValidateCredentials)
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		var sBody = '{"ID": ' + JSON.stringify(sID) + ', "Selection": ' + JSON.stringify(arrSelection) + '}';
		let res = await CreateSplendidRequest('BrowserExtensions/EmailService.svc/SetEmailRelationships', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return json.d;
	}
}

