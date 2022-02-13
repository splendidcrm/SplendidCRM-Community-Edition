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
import { formatDate, FromJsonDate }                 from '../scripts/Formatting'     ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest';

export async function CalendarView_GetCalendar(sDATE_START, sDATE_END, gASSIGNED_USER_ID)
{
	let res = await CreateSplendidRequest('Rest.svc/GetCalendar?DATE_START=' + encodeURIComponent(sDATE_START) + '&DATE_END=' + encodeURIComponent(sDATE_END) + '&ASSIGNED_USER_ID=' + encodeURIComponent(gASSIGNED_USER_ID), 'GET');
	let json = await GetSplendidResult(res);
	return json.d;
}

// 06/05/2020 Paul.  The dates are in json format as this allows us to use the value that is returned from the REST API. 
export async function GetInviteesActivities(sDATE_START: string, sDATE_END: string, sINVITEE_LIST: string)
{
	let res = await CreateSplendidRequest('Rest.svc/GetInviteesActivities?DATE_START=' + encodeURIComponent(Sql.ToString(sDATE_START)) + '&DATE_END=' + encodeURIComponent(Sql.ToString(sDATE_END)) + '&INVITEE_LIST=' + encodeURIComponent(Sql.ToString(sINVITEE_LIST)), 'GET');
	let json = await GetSplendidResult(res);
	// 06/06/2020 Paul.  Pre-convert the dates to a date object so that it does not needed to be done on render. 
	if ( json.d && json.d.results )
	{
		let InviteesActivities: any[] = json.d.results;
		for ( let j: number = 0; j < InviteesActivities.length; j++ )
		{
			let invitee: any = InviteesActivities[j];
			for ( let j: number = 0; j < invitee.Activities.length; j++ )
			{
				let activity: any = invitee.Activities[j];
				activity.dtDATE_START = (activity.DATE_START ? FromJsonDate(activity.DATE_START) : null);
				activity.dtDATE_END   = (activity.DATE_END   ? FromJsonDate(activity.DATE_END  ) : null);
			}
		}
	}
	json.d.__total = json.__total;
	json.d.__sql = json.__sql;
	return json.d;
}

// 06/06/2020 Paul.  The dates are in json format as this allows us to use the value that is returned from the REST API. 
export async function GetInviteesList(sFIRST_NAME: string, sLAST_NAME: string, sEMAIL: string, sDATE_START: string, sDATE_END: string, nTOP: number, nSKIP: number, sORDER_BY: string)
{
	let res = await CreateSplendidRequest('Rest.svc/GetInviteesList?DATE_START=' + encodeURIComponent(Sql.ToString(sDATE_START)) + '&DATE_END=' + encodeURIComponent(Sql.ToString(sDATE_END)) + '&FIRST_NAME=' + encodeURIComponent(Sql.ToString(sFIRST_NAME)) + '&LAST_NAME=' + encodeURIComponent(Sql.ToString(sLAST_NAME)) + '&EMAIL=' + encodeURIComponent(Sql.ToString(sEMAIL)) + '&$top=' + nTOP + '&$skip=' + nSKIP + '&$orderby=' + encodeURIComponent(sORDER_BY), 'GET');
	let json = await GetSplendidResult(res);
	// 06/06/2020 Paul.  Pre-convert the dates to a date object so that it does not needed to be done on render. 
	if ( json.d && json.d.results )
	{
		let InviteesActivities: any[] = json.d.results;
		for ( let j: number = 0; j < InviteesActivities.length; j++ )
		{
			let invitee: any = InviteesActivities[j];
			for ( let j: number = 0; j < invitee.Activities.length; j++ )
			{
				let activity: any = invitee.Activities[j];
				activity.dtDATE_START = (activity.DATE_START ? FromJsonDate(activity.DATE_START) : null);
				activity.dtDATE_END   = (activity.DATE_END   ? FromJsonDate(activity.DATE_END  ) : null);
			}
		}
	}
	json.d.__total = json.__total;
	json.d.__sql = json.__sql;
	return json.d;
}

