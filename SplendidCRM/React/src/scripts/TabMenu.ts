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

export async function TabMenu_Load(): Promise<any>
{
	let layout = SplendidCache.TAB_MENU;
	if ( layout == null )
	{
		// 05/26/2019 Paul.  We will no longer lookup missing layout values if not in the cache. 
		//console.log((new Date()).toISOString() + ' Tab Menu is null');
		/*
		// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
		let res = await SystemCacheRequest('TAB_MENUS', 'TAB_ORDER asc');
		//var xhr = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TAB_MENUS&$orderby=TAB_ORDER asc', 'GET');
		let json = await GetSplendidResult(res);
		SplendidCache.SetTAB_MENU(json.d.results);
		return (json.d.results);
		*/
	}
	return layout;
}

