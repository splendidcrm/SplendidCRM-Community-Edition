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

// 05/26/2019 Paul.  Terminology is retrieved in Application_GetReactState. 
/*
export async function Terminology_LoadAllTerms(): Promise<any>
{
	let res = await SystemCacheRequestAll('GetAllTerminology');
	let json = await GetSplendidResult(res);
	SplendidCache.SetTERMINOLOGY(json.d.results);
	// 05/07/2013 Paul. Return the entire TERMINOLOGY table. 
	return ({ 'sUSER_LANG': Credentials.sUSER_LANG, 'TERMINOLOGY': SplendidCache.TERMINOLOGY, 'TERMINOLOGY_LISTS': SplendidCache.TERMINOLOGY_LISTS });
}
*/

// 05/26/2019 Paul.  Terminology Lists are retrieved in Application_GetReactState. 
/*
export async function Terminology_LoadAllLists(): Promise<any>
{
	let res = await SystemCacheRequestAll('GetAllTerminologyLists');
	let json = await GetSplendidResult(res);
	SplendidCache.SetTERMINOLOGY_LISTS(json.d.results);
	// 05/07/2013 Paul. Return the entire TERMINOLOGY table. 
	return ({ 'sUSER_LANG': Credentials.sUSER_LANG, 'TERMINOLOGY': SplendidCache.TERMINOLOGY, 'TERMINOLOGY_LISTS': SplendidCache.TERMINOLOGY_LISTS });
}
*/

export function Terminology_SetTerm(sMODULE_NAME, sNAME, sDISPLAY_NAME)
{
	SplendidCache.SetTerm(sMODULE_NAME, sNAME, sDISPLAY_NAME)
}

export function Terminology_SetListTerm(sLIST_NAME, sNAME, sDISPLAY_NAME)
{
	SplendidCache.SetListTerm(sLIST_NAME, sNAME, sDISPLAY_NAME);
}

// 05/26/2019 Paul.  Terminology is retrieved in Application_GetReactState. 
/*
export async function Terminology_LoadGlobal(): Promise<any>
{
	// 04/27/2019 Paul.  Instead of loaded flag, use specific term. 
	if (SplendidCache.TERMINOLOGY[Credentials.sUSER_LANG + '.LBL_BROWSER_TITLE'] == null)
	{
		// 09/05/2011 Paul.  Include LBL_NEW_FORM_TITLE for the tab menu. 
		// 06/11/2012 Paul.  Wrap Terminology requests for Cordova. 
		let res = await TerminologyRequest(null, null, 'NAME asc', Credentials.sUSER_LANG);
		//let res = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=NAME asc&$filter=' + encodeURIComponent('(LANG eq \'' + sUSER_LANG + '\' and (MODULE_NAME is null or MODULE_NAME eq \'Teams\' or NAME eq \'LBL_NEW_FORM_TITLE\'))'), 'GET');
		let json = await GetSplendidResult(res);
		for (let i = 0; i < json.d.results.length; i++)
		{
			var obj = json.d.results[i];
			if (obj['LIST_NAME'] == null)
				Terminology_SetTerm(obj['MODULE_NAME'], obj['NAME'], obj['DISPLAY_NAME']);
			else
				Terminology_SetListTerm(obj['LIST_NAME'], obj['NAME'], obj['DISPLAY_NAME']);
		}
		// 10/04/2011 Paul. Return the entire TERMINOLOGY table. 
		return ({ 'sUSER_LANG': Credentials.sUSER_LANG, 'TERMINOLOGY': SplendidCache.TERMINOLOGY, 'TERMINOLOGY_LISTS': SplendidCache.TERMINOLOGY_LISTS });
	}
	else
	{
		return { 'sUSER_LANG': Credentials.sUSER_LANG, 'TERMINOLOGY': SplendidCache.TERMINOLOGY, 'TERMINOLOGY_LISTS': SplendidCache.TERMINOLOGY_LISTS };
	}
}
*/

// 05/26/2019 Paul.  Terminology Lists are retrieved in Application_GetReactState. 
/*
export async function Terminology_LoadList(sLIST_NAME): Promise<any>
{
	// 06/11/2012 Paul.  Wrap Terminology requests for Cordova. 
	let res = await TerminologyRequest(null, sLIST_NAME, 'LIST_NAME asc', Credentials.sUSER_LANG);
	//let res = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=LIST_NAME asc, LIST_ORDER asc, NAME asc&$filter=' + encodeURIComponent('(LANG eq \'' + sUSER_LANG + '\' and MODULE_NAME is null and LIST_NAME eq \'' + sLIST_NAME + '\')'), 'GET');
	let json = await GetSplendidResult(res);
	for (let i = 0; i < json.d.results.length; i++)
	{
		var obj = json.d.results[i];
		Terminology_SetListTerm(sLIST_NAME, obj['NAME'], obj['DISPLAY_NAME']);
	}
	// 10/04/2011 Paul. Return the entire TERMINOLOGY table. 
	return ({ 'sUSER_LANG': Credentials.sUSER_LANG, 'TERMINOLOGY': SplendidCache.TERMINOLOGY, 'TERMINOLOGY_LISTS': SplendidCache.TERMINOLOGY_LISTS });
}
*/

// 05/26/2019 Paul.  Terminology Lists are retrieved in Application_GetReactState. 
/*
export async function Terminology_LoadCustomList(sLIST_NAME): Promise<any>
{
	let res = await CreateSplendidRequest('Rest.svc/GetCustomList?ListName=' + sLIST_NAME, 'GET');
	let json = await GetSplendidResult(res);
	for (let i = 0; i < json.d.results.length; i++)
	{
		var obj = json.d.results[i];
		Terminology_SetListTerm(sLIST_NAME, obj['NAME'], obj['DISPLAY_NAME']);
	}
	// 10/04/2011 Paul. Return the entire TERMINOLOGY table. 
	return ({ 'sUSER_LANG': Credentials.sUSER_LANG, 'TERMINOLOGY': SplendidCache.TERMINOLOGY, 'TERMINOLOGY_LISTS': SplendidCache.TERMINOLOGY_LISTS });
}
*/

// 05/26/2019 Paul.  Terminology is retrieved in Application_GetReactState. 
/*
export async function Terminology_LoadModule(sMODULE_NAME): Promise<any>
{
	// 04/27/2019 Paul.  Instead of loaded flag, use specific term.  Every module will now have LBL_NEW_FORM_TITLE. 
	if (SplendidCache.TERMINOLOGY[Credentials.sUSER_LANG + '.' + sMODULE_NAME + '.LBL_NEW_FORM_TITLE'] == null)
	{
		// 06/11/2012 Paul.  Wrap Terminology requests for Cordova. 
		let res = await TerminologyRequest(sMODULE_NAME, null, 'NAME asc', Credentials.sUSER_LANG);
		//let res = await CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=NAME asc&$filter=' + encodeURIComponent('(LANG eq \'' + sUSER_LANG + '\' and MODULE_NAME eq \'' + sMODULE_NAME + '\' and LIST_NAME is null)'), 'GET');
		let json = await GetSplendidResult(res);
		for (let i = 0; i < json.d.results.length; i++)
		{
			var obj = json.d.results[i];
			Terminology_SetTerm(sMODULE_NAME, obj['NAME'], obj['DISPLAY_NAME']);
		}
		// 10/04/2011 Paul. Return the entire TERMINOLOGY table. 
		return ({ 'sUSER_LANG': Credentials.sUSER_LANG, 'TERMINOLOGY': SplendidCache.TERMINOLOGY, 'TERMINOLOGY_LISTS': SplendidCache.TERMINOLOGY_LISTS });
	}
	else
	{
		return { 'sUSER_LANG': Credentials.sUSER_LANG, 'TERMINOLOGY': SplendidCache.TERMINOLOGY, 'TERMINOLOGY_LISTS': SplendidCache.TERMINOLOGY_LISTS };
	}
}
*/
