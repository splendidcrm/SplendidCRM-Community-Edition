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

// 05/26/2019 Paul.  EditViewRelationships are retrieved in Application_GetAllLayouts. 
/*
export async function EditViewRelationships_LoadAllLayouts(): Promise<any>
{
	let res = await SystemCacheRequestAll('GetAllEditViewsRelationships');
	let json = await GetSplendidResult(res);
	SplendidCache.SetEDITVIEWS_RELATIONSHIPS(json.d.results);
	return (json.d.results);
}
*/

export async function EditViewRelationships_LoadLayout(sEDIT_NAME): Promise<any>
{
	let layout = SplendidCache.EditViewRelationships(sEDIT_NAME);
	if ( layout == null )
	{
		// 05/26/2019 Paul.  We will no longer lookup missing layout values if not in the cache. 
		//console.log((new Date()).toISOString() + ' ' + sEDIT_NAME + ' not found in EditViewRelationships');
		/*
		// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
		let res = await SystemCacheRequest('EDITVIEWS_RELATIONSHIPS', 'RELATIONSHIP_ORDER asc', null, 'EDIT_NAME', sEDIT_NAME);
		//var xhr = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=EDITVIEWS_RELATIONSHIPS&$orderby=RELATIONSHIP_ORDER asc&$filter=' + encodeURIComponent('EDIT_NAME eq \'' + sEDIT_NAME + '\''), 'GET');
		let json = await GetSplendidResult(res);
		SplendidCache.SetEditViewRelationships(sEDIT_NAME, json.d.results);
		// 10/04/2011 Paul.  EditViewRelationships_LoadLayout returns the layout. 
		layout = SplendidCache.EditViewRelationships(sEDIT_NAME);
		return (json.d.results);
		*/
	}
	return layout;
}

