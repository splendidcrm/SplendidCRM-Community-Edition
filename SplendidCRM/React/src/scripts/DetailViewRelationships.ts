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
import SplendidCache from '../scripts/SplendidCache';

// 05/26/2019 Paul.  DetailViewRelationships are retrieved in Application_GetAllLayouts. 
/*
export async function DetailViewRelationships_LoadAllLayouts()
{
	let res = await SystemCacheRequestAll('GetAllDetailViewsRelationships');
	let json = await GetSplendidResult(res);
	SplendidCache.SetDETAILVIEWS_RELATIONSHIPS(json.d.results);
	return (json.d.results);
}
*/

export async function DetailViewRelationships_LoadLayout(sDETAIL_NAME): Promise<any>
{
	let layout = SplendidCache.DetailViewRelationships(sDETAIL_NAME);
	if ( layout == null )
	{
		// 05/26/2019 Paul.  We will no longer lookup missing layout values if not in the cache. 
		//console.log((new Date()).toISOString() + ' ' + sDETAIL_NAME + ' not found in DetailViewRelationships');
		/*
		// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
		let res = await SystemCacheRequest('DETAILVIEWS_RELATIONSHIPS', 'RELATIONSHIP_ORDER asc', null, 'DETAIL_NAME', sDETAIL_NAME);
		//var xhr = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=DETAILVIEWS_RELATIONSHIPS&$orderby=RELATIONSHIP_ORDER asc&$filter=' + encodeURIComponent('DETAIL_NAME eq \'' + sDETAIL_NAME + '\''), 'GET');
		let json = await GetSplendidResult(res);
		SplendidCache.SetDetailViewRelationships(sDETAIL_NAME, json.d.results);
		// 10/03/2011 Paul.  DetailView_LoadLayout returns the layout. 
		layout = SplendidCache.DetailViewRelationships(sDETAIL_NAME);
		return (json.d.results);
		*/
	}
	return layout;
}

