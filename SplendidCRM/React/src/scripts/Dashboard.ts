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
// 2. Types
// 3. Scripts
import Sql                                          from './Sql'                  ;
import L10n                                         from './L10n'                 ;
import Security                                     from './Security'             ;
import Credentials                                  from './Credentials'          ;
import SplendidCache                                from './SplendidCache'        ;
import { CreateSplendidRequest, GetSplendidResult } from './SplendidRequest'      ;
import { ListView_LoadModule }                      from './ListView'             ;
import { DynamicLayout_Compile }                    from './DynamicLayout_Compile';
// 4. Components and Views. 
// 5. Dashlets
import DashletFactory from '../Dashlets';

export async function DashboardApps_LoadAll(): Promise<any>
{
	// 06/05/2017 Paul.  Only get apps that are enabled. 
	let res = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=DASHBOARD_APPS&$orderby=NAME asc&$filter=APP_ENABLED eq 1', 'GET');
	let json = await GetSplendidResult(res);
	return json.d;
}

export async function Dashboards(sCATEGORY: string, bForceUpdate?: boolean): Promise<any>
{
	try
	{
		// 06/05/2017 Paul.  Only get apps that are enabled. 
		let dashboards = null;
		if ( !bForceUpdate )
		{
			dashboards = SplendidCache.GetDashboards(sCATEGORY);
			if ( dashboards == null )
			{
				dashboards = SplendidCache.GetDashboards(sCATEGORY + '.Default');
			}
		}
		// 10/25/2020 Paul.  The dashboard will attempt to laod before the state has been fully loaded. 
		if ( dashboards == null && !Sql.IsEmptyString(Security.USER_ID()) )
		{
			//console.log('Dashboards could not find ' + sCATEGORY + ' in DASHBOARDS cache');
			let sSEARCH_FILTER = "ASSIGNED_USER_ID eq \'" + Security.USER_ID() + "\' and CATEGORY eq \'" + sCATEGORY + "\'";
			// 02/23/2020 Paul.  ASSIGNED_USER_ID is used to determine if the dashboard is global. 
			let d = await ListView_LoadModule('Dashboard', 'NAME', 'asc', 'ID, NAME, ASSIGNED_USER_ID', sSEARCH_FILTER, null);
			if ( d != null && d.results != null && d.results.length > 0 )
			{
				SplendidCache.SetDashboards(sCATEGORY, d.results);
				return d.results;
			}
			// 06/08/2021 Paul.  If no dashboards exist, it could be because they were deleted for this category, so remove from list. 
			SplendidCache.DeleteDashboardCategory(sCATEGORY);
			sSEARCH_FILTER = "ASSIGNED_USER_ID is null and CATEGORY eq \'" + sCATEGORY + "\'";
			// 02/23/2020 Paul.  ASSIGNED_USER_ID is used to determine if the dashboard is global. 
			d = await ListView_LoadModule('Dashboard', 'NAME', 'asc', 'ID, NAME, ASSIGNED_USER_ID', sSEARCH_FILTER, null);
			if ( d != null && d.results != null && d.results.length > 0 )
			{
				SplendidCache.SetDashboards(sCATEGORY + '.Default', d.results);
				return d.results;
			}
			return null;
		}
		return dashboards;
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' Dashboards' + sCATEGORY, error);
		throw ('Dashboards ' + sCATEGORY + ': ' + error.message);
	}
}

export async function Dashboards_LoadItem(sID): Promise<any>
{
	try
	{
		let dashboards = SplendidCache.GetDashboards('Home');
		if ( dashboards != null && dashboards.length > 0 )
		{
			for ( let i = 0; i < dashboards.length; i++ )
			{
				if ( sID == dashboards[i].ID )
				{
					return dashboards[i];
				}
			}
		}
		dashboards = SplendidCache.GetDashboards('Home.Default');
		if ( dashboards != null && dashboards.length > 0 )
		{
			for ( let i = 0; i < dashboards.length; i++ )
			{
				if ( sID == dashboards[i].ID )
				{
					return dashboards[i];
				}
			}
		}
		dashboards = SplendidCache.GetDashboards('Dashboard');
		if ( dashboards != null && dashboards.length > 0 )
		{
			for ( let i = 0; i < dashboards.length; i++ )
			{
				if ( sID == dashboards[i].ID )
				{
					return dashboards[i];
				}
			}
		}
		dashboards = SplendidCache.GetDashboards('Dashboard.Default');
		if ( dashboards != null && dashboards.length > 0 )
		{
			for ( let i = 0; i < dashboards.length; i++ )
			{
				if ( sID == dashboards[i].ID )
				{
					return dashboards[i];
				}
			}
		}

		//console.log('Dashboards_LoadItem could not find ' + sID + ' in DASHBOARDS cache');
		let res = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=DASHBOARDS&$filter=' + encodeURIComponent('ID eq \'' + sID + '\''), 'GET');
		let json = await GetSplendidResult(res);
		if ( json.d != null && json.d.results != null && json.d.results.length > 0 )
			return json.d.results[0];
		return null;
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' Dashboards_LoadItem' + sID, error);
		throw ('Dashboards_LoadItem ' + sID + ': ' + error.message);
	}
}

export async function Dashboards_LoadPanels(sDASHBOARD_ID, bForceUpdate?: boolean): Promise<any>
{
	try
	{
		let panels = null;
		if ( !bForceUpdate )
		{
			panels = SplendidCache.GetDashboardPanels(sDASHBOARD_ID);
		}
		if ( panels == null )
		{
			//console.log('Dashboards_LoadPanels could not find ' + sDASHBOARD_ID + ' in DASHBOARDS_PANELS cache');
			let res = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=DASHBOARDS_PANELS&$orderby=PANEL_ORDER asc&$filter=' + encodeURIComponent('DASHBOARD_ID eq \'' + sDASHBOARD_ID + '\''), 'GET');
			let json = await GetSplendidResult(res);
			// 06/16/2019 Paul.  Set an empty list. 
			if ( json.d != null && json.d.results != null )
			{
				SplendidCache.SetDashboardPanels(sDASHBOARD_ID, json.d.results);
				return json.d.results;
			}
		}
		return panels;
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' Dashboards_LoadPanels' + sDASHBOARD_ID, error);
		throw ('Dashboards_LoadPanels ' + sDASHBOARD_ID + ': ' + error.message);
	}
}

export async function Dashboards_Dashlet(sDASHLET_NAME: string): Promise<any>
{
	/*
	// 03/01/2019 Paul.  We are transitioning from js to tsx (while keeping the code as js) to avoid Visual Studio Code errors on React project. 
	let res = await CreateSplendidRequest('React/src/DashletsJS/' + sDASHLET_NAME + '.js', 'GET');
	let responseText = await res.text();
	let json = null;
	if ( !res.ok )
	{
		if ( Sql.IsEmptyString(responseText) )
		{
			responseText = res.statusText;
		}
		else if ( StartsWith(responseText, '<?xml') )
		{
			// https://stackoverflow.com/questions/10585029/parse-an-html-string-with-js
			let doc = document.implementation.createHTMLDocument('');
			doc.documentElement.innerHTML = responseText;
			let body: any = doc.getElementsByTagName('body');
			if ( body != null && body.length > 0 )
				responseText = body[0].innerText;
			else
				responseText = doc.documentElement.innerText;
		}
		else if ( StartsWith(responseText, '{') )
		{
			json = JSON.parse(responseText);
			if ( json !== undefined && json != null )
			{
				if ( json.ExceptionDetail !== undefined )
				{
					console.error(json.ExceptionDetail.Message);
					throw new Error(json.ExceptionDetail.Message);
				}
			}
		}
		console.error(responseText);
		throw new Error(responseText);
	}
	if ( StartsWith(responseText, '<html>') )
	{
		throw (res.url + ' is not a avlid service URL.');
	}
	*/
	//console.log('Dashboards_Dashlet ' + sDASHLET_NAME, responseText);
	try
	{
		let responseText: string = SplendidCache.ReactDashlets(sDASHLET_NAME);
		if ( responseText != null )
		{
			// 02/02/2020 Paul.  Comment out includes so that we don't need to wrap code in a function. 
			responseText = responseText.replace(/\r\nimport/g, '\r\n//import');
			//console.log('Dashboards_Dashlet ' + sDASHLET_NAME, responseText);
			let dashlet = SplendidCache.CompiledDashlets(sDASHLET_NAME);
			if ( dashlet == null )
			{
				// 04/19/2020 Paul.  Move Babel transform to a separate file. 
				dashlet = await DynamicLayout_Compile(responseText);
				SplendidCache.SetCompiledDashlet(sDASHLET_NAME, dashlet);
			}
			return dashlet;
		}
		// 06/01/2019 Paul.  Fallback to using default dashlets. 
		return DashletFactory(sDASHLET_NAME);
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' Dashboards_Dashlet' + sDASHLET_NAME, error);
		throw ('Dashboards_Dashlet ' + sDASHLET_NAME + ': ' + error.message);
	}
}

export async function DashboardAddReport(DASHBOARD_ID: string, CATEGORY: string, REPORT_ID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( DASHBOARD_ID == null )
	{
		throw new Error('DashboardAddReport: DASHBOARD_ID is invalid.');
	}
	else if ( REPORT_ID == null )
	{
		throw new Error('DashboardAddReport: REPORT_ID is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['DASHBOARD_ID'] = DASHBOARD_ID;
		row['CATEGORY'    ] = CATEGORY    ;
		row['REPORT_ID'   ] = REPORT_ID   ;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/DashboardAddReport', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

