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
import Sql                                          from '../scripts/Sql'            ;
import Credentials                                  from '../scripts/Credentials'    ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest';

export async function ProcessButtons_GetProcessStatus(gPENDING_PROCESS_ID): Promise<any>
{
	let res = await CreateSplendidRequest('Processes/Rest.svc/GetProcessStatus?ID=' + gPENDING_PROCESS_ID, 'GET');
	let json = await GetSplendidResult(res);
	// 10/04/2011 Paul.  DetailViewUI.LoadItem returns the row. 
	return (json.d.results);
}

export async function ProcessButtons_GetProcessHistory(gPENDING_PROCESS_ID): Promise<any>
{
	let res = await CreateSplendidRequest('Processes/Rest.svc/GetProcessHistory?ID=' + gPENDING_PROCESS_ID, 'GET');
	let json = await GetSplendidResult(res);
	json.d.__title = json.__title;
	return (json.d);
}

export async function ProcessButtons_GetProcessNotes(gPENDING_PROCESS_ID): Promise<any>
{
	let res = await CreateSplendidRequest('Processes/Rest.svc/GetProcessNotes?ID=' + gPENDING_PROCESS_ID, 'GET');
	let json = await GetSplendidResult(res);
	json.d.__title = json.__title;
	return (json.d);
}

export async function ProcessButtons_DeleteProcessNote(gPROCESS_NOTE_ID): Promise<any>
{
	let res = await CreateSplendidRequest('Processes/Rest.svc/DeleteProcessNote?ID=' + gPROCESS_NOTE_ID, 'POST', 'application/octet-stream', null);
	let json = await GetSplendidResult(res);
	return null;
}

export async function ProcessButtons_AddProcessNote(gPROCESS_NOTE_ID, sPROCESS_NOTE): Promise<any>
{
	let res = await CreateSplendidRequest('Processes/Rest.svc/AddProcessNote?ID=' + gPROCESS_NOTE_ID, 'POST', 'application/octet-stream', sPROCESS_NOTE);
	let json = await GetSplendidResult(res);
	return null;
}

export async function ProcessButtons_ProcessAction(sACTION, gPENDING_PROCESS_ID, gPROCESS_USER_ID, sPROCESS_NOTES): Promise<any>
{
	if (! Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		let obj = new Object();
		obj['ACTION'            ] = sACTION            ;
		obj['PENDING_PROCESS_ID'] = gPENDING_PROCESS_ID;
		obj['PROCESS_USER_ID'   ] = gPROCESS_USER_ID   ;
		obj['PROCESS_NOTES'     ] = sPROCESS_NOTES     ;
		let sBody = JSON.stringify(obj);
		let res = await CreateSplendidRequest('Processes/Rest.svc/ProcessAction', 'POST', 'application/octet-stream', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

export async function ProcessButtons_ProcessUsers(gTEAM_ID, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER): Promise<any>
{
	// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
	if ( sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '' )
	{
		sSORT_FIELD = '';
		sSORT_DIRECTION = '';
	}
	let res = await CreateSplendidRequest('Processes/Rest.svc/ProcessUsers?TEAM_ID=' + gTEAM_ID + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION) + '&$select=' + escape(sSELECT) + '&$filter=' + escape(sFILTER), 'GET');
	let json = await GetSplendidResult(res);
	// 10/04/2011 Paul.  ListView_LoadModule returns the rows. 
	return (json.d.results);
}

export async function LoadProcessPaginated(sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bMyList): Promise<any>
{
	// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
	if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
	{
		sSORT_FIELD = '';
		sSORT_DIRECTION = '';
	}
	//console.log('ListView_LoadModulePaginated ADMIN_MODE', bADMIN_MODE);
	// 08/17/2019 Paul.  Post version so that we can support large filter requests.  This is common with the UnifiedSearch. 
	let obj = new Object();
	obj['$top'         ] = nTOP       ;
	obj['$skip'        ] = nSKIP      ;
	obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
	obj['$select'      ] = sSELECT    ;
	obj['$filter'      ] = sFILTER    ;
	obj['MyList'       ] = bMyList    ;
	// 11/16/2019 Paul.  We will be ignoring the $filter as we transition to $searchvalues to avoid the security issue of passing full SQL query as a paramter. 
	if ( rowSEARCH_VALUES != null )
	{
		obj['$searchvalues'] = rowSEARCH_VALUES;
	}
	let res = null;
	obj['ModuleName'] = sMODULE_NAME;
	let sBody: string = JSON.stringify(obj);
	res = await CreateSplendidRequest('Processes/Rest.svc/PostModuleList', 'POST', 'application/octet-stream', sBody);
	
	//xhr.SearchValues = rowSEARCH_VALUES;
	let json = await GetSplendidResult(res);
	// 10/04/2011 Paul.  ListView_LoadModule returns the rows. 
	// 04/21/2017 Paul.  We need to return the total when using nTOP. 
	// 05/13/2018 Paul.  Instead of returning just the results, we will need to return everything to get the total. 
	// 05/17/2018 Paul.  Copy total to d to simplfy the return value. 
	json.d.__total = json.__total;
	json.d.__sql = json.__sql;
	return (json.d);
}

export async function ProcessButtons_LoadItem(ID: string)
{
	let res = await CreateSplendidRequest('Processes/Rest.svc/GetModuleItem?ID=' + ID + '&$accessMode=view', 'GET');
	let json = await GetSplendidResult(res);
	// 11/19/2019 Paul.  Change to allow return of SQL. 
	json.d.__sql = json.__sql;
	return json.d;
}

