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
import GRIDVIEWS_COLUMN                             from '../types/GRIDVIEWS_COLUMN' ;
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'            ;
import Credentials                                  from '../scripts/Credentials'    ;
import SplendidCache                                from '../scripts/SplendidCache'  ;
import { Crm_Modules }                              from '../scripts/Crm'            ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest';

export async function ListView_LoadTable(sTABLE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, bADMIN_MODE: boolean): Promise<any>
{
	// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
	if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
	{
		sSORT_FIELD = '';
		sSORT_DIRECTION = '';
	}
	let obj = new Object();
	obj['TableName'    ] = sTABLE_NAME;
	obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
	// 12/11/2022 Paul.  An uninitialized sSELECT can be {}, and that will be treated as SYSTEMCOLLECTIONSGENERICDICTIONARY2SYSTEMSTRING. 
	obj['$select'      ] = typeof(sSELECT) == 'object' ? '*' : sSELECT;
	obj['$filter'      ] = sFILTER;
	// 11/16/2019 Paul.  We will be ignoring the $filter as we transition to $searchvalues to avoid the security issue of passing full SQL query as a paramter. 
	if ( rowSEARCH_VALUES != null )
	{
		obj['$searchvalues'] = rowSEARCH_VALUES;
	}
	let sBody: string = JSON.stringify(obj);
	let res = null;
	if ( bADMIN_MODE )
	{
		res = await CreateSplendidRequest('Administration/Rest.svc/PostAdminTable', 'POST', 'application/octet-stream', sBody);
	}
	else
	{
		res = await CreateSplendidRequest('Rest.svc/PostModuleTable', 'POST', 'application/octet-stream', sBody);
	}
	let json = await GetSplendidResult(res);
	// 10/04/2011 Paul.  ListView_LoadTable returns the rows. 
	// 05/17/2018 Paul.  Copy total to d to simplfy the return value. 
	json.d.__total = json.__total;
	json.d.__sql = json.__sql;
	return (json.d);
}

// 06/13/2017 Paul.  Add pagination. 
export async function ListView_LoadTablePaginated(sTABLE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE: boolean, archiveView: boolean): Promise<any>
{
	// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
	if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
	{
		sSORT_FIELD = '';
		sSORT_DIRECTION = '';
	}
	//console.log('ListView_LoadTablePaginated ADMIN_MODE', bADMIN_MODE);
	let obj = new Object();
	obj['TableName'    ] = sTABLE_NAME;
	obj['$top'         ] = nTOP       ;
	obj['$skip'        ] = nSKIP      ;
	obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
	// 12/11/2022 Paul.  An uninitialized sSELECT can be {}, and that will be treated as SYSTEMCOLLECTIONSGENERICDICTIONARY2SYSTEMSTRING. 
	obj['$select'      ] = typeof(sSELECT) == 'object' ? '*' : sSELECT;
	obj['$filter'      ] = sFILTER    ;
	if( Sql.ToBoolean(archiveView) )
	{
		obj['$archiveView'] = archiveView;
	}
	// 11/16/2019 Paul.  We will be ignoring the $filter as we transition to $searchvalues to avoid the security issue of passing full SQL query as a paramter. 
	if ( rowSEARCH_VALUES != null )
	{
		obj['$searchvalues'] = rowSEARCH_VALUES;
	}
	let sBody: string = JSON.stringify(obj);
	let res = null;
	if ( bADMIN_MODE )
	{
		res = await CreateSplendidRequest('Administration/Rest.svc/PostAdminTable', 'POST', 'application/octet-stream', sBody);
	}
	else
	{
		res = await CreateSplendidRequest('Rest.svc/PostModuleTable', 'POST', 'application/octet-stream', sBody);
	}
	let json = await GetSplendidResult(res);
	// 10/04/2011 Paul.  ListView_LoadTable returns the rows. 
	// 04/21/2017 Paul.  We need to return the total when using nTOP. 
	// 05/27/2018 Paul.  Copy total to d to simplfy the return value. 
	json.d.__total = json.__total;
	json.d.__sql = json.__sql;
	return (json.d);
}

// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
export async function ListView_LoadModule(sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any): Promise<any>
{
	// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
	if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
	{
		sSORT_FIELD = '';
		sSORT_DIRECTION = '';
	}
	// 08/17/2019 Paul.  Post version so that we can support large filter requests.  This is common with the UnifiedSearch. 
	let obj = new Object();
	obj['ModuleName'   ] = sMODULE_NAME;
	obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
	// 12/11/2022 Paul.  An uninitialized sSELECT can be {}, and that will be treated as SYSTEMCOLLECTIONSGENERICDICTIONARY2SYSTEMSTRING. 
	obj['$select'      ] = typeof(sSELECT) == 'object' ? '*' : sSELECT;
	obj['$filter'      ] = sFILTER;
	// 11/16/2019 Paul.  We will be ignoring the $filter as we transition to $searchvalues to avoid the security issue of passing full SQL query as a paramter. 
	if ( rowSEARCH_VALUES != null )
	{
		obj['$searchvalues'] = rowSEARCH_VALUES;
	}
	// 09/17/2024 Paul.  Send duplicate filter info.  (not really needed here, but just good to follow the pattern). 
	if (rowSEARCH_VALUES != null && rowSEARCH_VALUES['DUPLICATE_FILTER'] != null && Array.isArray(rowSEARCH_VALUES['DUPLICATE_FILTER']) && rowSEARCH_VALUES['DUPLICATE_FILTER'].length > 0)
	{
		obj['$duplicatefields'] = rowSEARCH_VALUES['DUPLICATE_FILTER'].join(',');
		// 09/17/2024 Paul.  Must remove DUPLICATE_FILTER from $searchvalues. 
		obj['$searchvalues'] = Sql.DeepCopy(rowSEARCH_VALUES);
		delete obj['$searchvalues'].DUPLICATE_FILTER;
	}
	let sBody = JSON.stringify(obj);
	let res = await CreateSplendidRequest('Rest.svc/PostModuleList', 'POST', 'application/octet-stream', sBody);
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

// 12/15/2019 Paul.  Add export. 
export async function ListView_ExportModule(sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE: boolean, archiveView: boolean, sEXPORT_RANGE: string, sEXPORT_FORMAT: string, arrSELECTED_ITEMS: string[]): Promise<any>
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
	obj['$top'          ] = nTOP          ;
	obj['$skip'         ] = nSKIP         ;
	obj['$orderby'      ] = Sql.ToString(sSORT_FIELD + ' ' + sSORT_DIRECTION);
	obj['$select'       ] = Sql.ToString(sSELECT       );
	obj['$filter'       ] = Sql.ToString(sFILTER       );
	obj['$exportformat' ] = Sql.ToString(sEXPORT_FORMAT);
	obj['$exportrange'  ] = Sql.ToString(sEXPORT_RANGE );
	obj['$selecteditems'] = (arrSELECTED_ITEMS ? arrSELECTED_ITEMS.join(',') : null);
	if( Sql.ToBoolean(archiveView) )
	{
		obj['$archiveView'] = archiveView;
	}
	// 11/16/2019 Paul.  We will be ignoring the $filter as we transition to $searchvalues to avoid the security issue of passing full SQL query as a paramter. 
	if ( rowSEARCH_VALUES != null )
	{
		obj['$searchvalues'] = rowSEARCH_VALUES;
	}
	// 09/09/2019 Paul.  Send duplicate filter info. 
	if (rowSEARCH_VALUES != null && rowSEARCH_VALUES['DUPLICATE_FILTER'] != null && Array.isArray(rowSEARCH_VALUES['DUPLICATE_FILTER']) && rowSEARCH_VALUES['DUPLICATE_FILTER'].length > 0)
	{
		obj['$duplicatefields'] = rowSEARCH_VALUES['DUPLICATE_FILTER'].join(',');
		// 09/17/2024 Paul.  Must remove DUPLICATE_FILTER from $searchvalues. 
		obj['$searchvalues'] = Sql.DeepCopy(rowSEARCH_VALUES);
		delete obj['$searchvalues'].DUPLICATE_FILTER;
	}
	obj['ModuleName'] = sMODULE_NAME;
	// 08/11/2020 Paul.  Both methods work.  The problem with Excel was that we needed to issue Response.Flush() before the Response.End(). 
	if ( false )
	{
		// 08/11/2020 Paul.  This approach uses tradiational get to a web page. 
		let url: string = null;
		for ( let item in obj )
		{
			if ( url == null )
				url = Credentials.RemoteServer + 'Import/ExportModule.aspx?';
			else
				url += '&';
			if ( typeof(obj[item]) == 'object' )
				url += item + '=' + encodeURIComponent(JSON.stringify(obj[item]));
			else
				url += item + '=' + encodeURIComponent(obj[item]);
		}
		// 02/20/2022 Paul.  Remove last parameter due to compiler error.  Not in W3C spec. 
		window.open(url, 'SplendidExport', null);
	}
	else
	{
		let sBody: string = JSON.stringify(obj);
		let res: Response = await CreateSplendidRequest('Import/ExportModule.aspx', 'POST', 'application/octet-stream', sBody);

		// https://stackoverflow.com/questions/16086162/handle-file-download-from-ajax-post
		let filename   : string = '';
		let type       : string = res.headers.get('Content-Type');
		let disposition: string = res.headers.get('Content-Disposition');
		if ( disposition && disposition.indexOf('attachment') !== -1 )
		{
			var filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
			var matches = filenameRegex.exec(disposition);
			if ( matches != null && matches[1] )
			{
				filename = matches[1].replace(/['"]/g, '');
			}
			let blob        = await res.blob();
			let downloadUrl = window.URL.createObjectURL(blob);
			let a           = document.createElement("a");
			a.href          = downloadUrl;
			a.download      = filename;
			document.body.appendChild(a);
			a.click();
			setTimeout(function () { window.URL.revokeObjectURL(downloadUrl); }, 100); // cleanup
		}
		else
		{
			let json = await GetSplendidResult(res);
			throw(json);
		}
	}
}

// 04/22/2017 Paul.  Add pagination. 
export async function ListView_LoadModulePaginated(sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE: boolean, archiveView: boolean): Promise<any>
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
	// 12/11/2022 Paul.  An uninitialized sSELECT can be {}, and that will be treated as SYSTEMCOLLECTIONSGENERICDICTIONARY2SYSTEMSTRING. 
	obj['$select'      ] = typeof(sSELECT) == 'object' ? '*' : sSELECT;
	obj['$filter'      ] = sFILTER    ;
	if( Sql.ToBoolean(archiveView) )
	{
		obj['$archiveView'] = archiveView;
	}
	// 11/16/2019 Paul.  We will be ignoring the $filter as we transition to $searchvalues to avoid the security issue of passing full SQL query as a paramter. 
	if ( rowSEARCH_VALUES != null )
	{
		obj['$searchvalues'] = rowSEARCH_VALUES;
	}
	// 09/09/2019 Paul.  Send duplicate filter info. 
	if (rowSEARCH_VALUES != null && rowSEARCH_VALUES['DUPLICATE_FILTER'] != null && Array.isArray(rowSEARCH_VALUES['DUPLICATE_FILTER']) && rowSEARCH_VALUES['DUPLICATE_FILTER'].length > 0)
	{
		obj['$duplicatefields'] = rowSEARCH_VALUES['DUPLICATE_FILTER'].join(',');
		// 09/17/2024 Paul.  Must remove DUPLICATE_FILTER from $searchvalues. 
		obj['$searchvalues'] = Sql.DeepCopy(rowSEARCH_VALUES);
		delete obj['$searchvalues'].DUPLICATE_FILTER;
	}
	let res = null;
	if ( bADMIN_MODE )
	{
		obj['TableName'] = Crm_Modules.TableName(sMODULE_NAME);
		let sBody: string = JSON.stringify(obj);
		res = await CreateSplendidRequest('Administration/Rest.svc/PostAdminTable', 'POST', 'application/octet-stream', sBody);
	}
	else
	{
		obj['ModuleName'] = sMODULE_NAME;
		let sBody: string = JSON.stringify(obj);
		res = await CreateSplendidRequest('Rest.svc/PostModuleList', 'POST', 'application/octet-stream', sBody);
	}
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

// 05/21/2017 Paul.  HTML5 Dashboard requires aggregates. 
export async function ListView_LoadTableWithAggregate(sTABLE_NAME: string, sORDER_BY: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, sGROUP_BY: string, sAGGREGATE: string): Promise<any>
{
	// https://www.visualstudio.com/en-us/docs/report/analytics/aggregated-data-analytics
	let sAPPLY = '';
	if (!Sql.IsEmptyString(sGROUP_BY) && !Sql.IsEmptyString(sAGGREGATE))
	{
		// Aggregate types: count, countdistinct, sum, avg, min, max
		sAPPLY = 'groupby((' + sGROUP_BY + '), aggregate(' + sAGGREGATE + '))';
	}
	let obj = new Object();
	obj['TableName'    ] = sTABLE_NAME;
	obj['$orderby'     ] = sORDER_BY;
	// 12/11/2022 Paul.  An uninitialized sSELECT can be {}, and that will be treated as SYSTEMCOLLECTIONSGENERICDICTIONARY2SYSTEMSTRING. 
	obj['$select'      ] = typeof(sSELECT) == 'object' ? '' : sSELECT;
	obj['$filter'      ] = sFILTER;
	obj['$apply'       ] = sAPPLY;
	// 11/16/2019 Paul.  We will be ignoring the $filter as we transition to $searchvalues to avoid the security issue of passing full SQL query as a paramter. 
	if ( rowSEARCH_VALUES != null )
	{
		obj['$searchvalues'] = rowSEARCH_VALUES;
	}
	let sBody = JSON.stringify(obj);
	let res = await CreateSplendidRequest('Rest.svc/PostModuleTable', 'POST', 'application/octet-stream', sBody);
	let json = await GetSplendidResult(res);
	// 10/04/2011 Paul.  ListView_LoadModule returns the rows. 
	// 04/21/2017 Paul.  We need to return the total when using nTOP. 
	// 05/13/2018 Paul.  Instead of returning just the results, we will need to return everything to get the total. 
	// 05/17/2018 Paul.  Copy total to d to simplfy the return value. 
	json.d.__total = json.__total;
	json.d.__sql = json.__sql;
	return (json.d);
}

// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
export function ListView_LoadLayout(GRID_NAME: string, ignoreMissing?: boolean)
{
	let layout: any[] = null;
	if ( Sql.IsEmptyString(Credentials.sPRIMARY_ROLE_NAME) )
	{
		layout = SplendidCache.GridViewColumns(GRID_NAME, ignoreMissing);
	}
	else
	{
		layout = SplendidCache.GridViewColumns(GRID_NAME + '.' + Credentials.sPRIMARY_ROLE_NAME, true);
		if ( layout === undefined || layout == null || layout.length == 0 )
		{
			layout = SplendidCache.GridViewColumns(GRID_NAME, ignoreMissing);
		}
	}
	// 05/26/2019 Paul.  We will no longer lookup missing layout values if not in the cache. 
	if ( layout == null )
	{
		if ( !ignoreMissing )
		{
			// 01/08/2021 Paul.  No lnoger needed. 
			//console.warn((new Date()).toISOString() + ' ' + GRID_NAME + ' not found in ListViews');
		}
	}
	else
	{
		// 11/02/2019 Paul.  Return a clone of the layout so that we can dynamically modify the layout. 
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		let newArray: any[] = [];
		layout.forEach((item) =>
		{
			newArray.push(Object.assign({hidden: false}, item));
		});
		layout = newArray;
	}
	return layout;
}

// 08/22/2019 Paul.  Add streams. 
export async function ListView_LoadStreamPaginated(sMODULE_NAME: string, gID: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number): Promise<any>
{
	// 01/26/2020 Paul.  Make sure that an empty filter does not get sent as "null". 
	let res = await CreateSplendidRequest('Rest.svc/GetModuleStream?ModuleName=' + sMODULE_NAME + (gID ? '&ID=' + gID : '') + '&$top=' + nTOP + '&$skip=' + nSKIP + '&$select=' + encodeURIComponent(sSELECT) + '&$filter=' + (Sql.IsEmptyString(sFILTER) ? '' : encodeURIComponent(sFILTER)), 'GET');
	let json = await GetSplendidResult(res);
	json.d.__total = json.__total;
	json.d.__sql = json.__sql;
	return (json.d);
}

export async function ListView_LoadActivitiesPaginated(sPARENT_TYPE: string, gPARENT_ID: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, archiveView: boolean): Promise<any>
{
	// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
	if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
	{
		sSORT_FIELD = '';
		sSORT_DIRECTION = '';
	}
	//console.log('ListView_LoadActivitiesPaginated ADMIN_MODE', bADMIN_MODE);
	// 08/17/2019 Paul.  Post version so that we can support large filter requests.  This is common with the UnifiedSearch. 
	// 01/26/2020 Paul.  Make sure that an empty filter does not get sent as "null". 
	let res = await CreateSplendidRequest('Rest.svc/GetActivitiesList?IncludeRelationships=1' + (Sql.ToBoolean(archiveView) ? '&$archiveView=1' : '') + '&PARENT_TYPE=' + sPARENT_TYPE + '&PARENT_ID=' + gPARENT_ID + '&$top=' + nTOP + '&$skip=' + nSKIP + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION) + '&$select=' + encodeURIComponent(sSELECT) + '&$filter=' + (Sql.IsEmptyString(sFILTER) ? '' : encodeURIComponent(sFILTER)), 'GET');
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

export async function AutoComplete_ModuleMethod(sMODULE_NAME: string, sMETHOD: string, sREQUEST: any)
{
	if ( sMODULE_NAME == 'Teams' )
		sMODULE_NAME = 'Administration/Teams';
	else if ( sMODULE_NAME == 'Tags' )
		sMODULE_NAME = 'Administration/Tags';
	// 06/07/2017 Paul.  Add NAICSCodes module. 
	else if ( sMODULE_NAME == 'NAICSCodes' )
		sMODULE_NAME = 'Administration/NAICSCodes';
	let sBody = JSON.stringify(sREQUEST);
	let res = await CreateSplendidRequest(sMODULE_NAME + '/AutoComplete.asmx/' + sMETHOD, 'POST', 'application/json; charset=utf-8', sBody);
	let json = await GetSplendidResult(res);
	return (json.d);
}

