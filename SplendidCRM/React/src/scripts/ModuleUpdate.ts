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

export async function DeleteModuleItem(sMODULE_NAME: string, sID: string, bADMIN_MODE?: boolean): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		let sUrl = null;
		if ( bADMIN_MODE )
		{
			sUrl = 'Administration/Rest.svc/DeleteAdminModuleItem';
		}
		else
		{
			sUrl = 'Rest.svc/DeleteModuleItem';
		}
		let sBody: string = '{"ModuleName": ' + JSON.stringify(sMODULE_NAME) + ', "ID": ' + JSON.stringify(sID) + '}';
		let res = await CreateSplendidRequest(sUrl, 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
		//if ( result.status == 0 )
		// 10/06/2011 Paul.  It does not make sense to allow deletes at this time. 
		//reject('A record cannot be deleted when offline.');
	}
}

export async function DeleteModuleRecurrences(sMODULE_NAME: string, sID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		let sUrl = null;
		sUrl = 'Rest.svc/DeleteModuleRecurrences';
		let sBody: string = '{"ModuleName": ' + JSON.stringify(sMODULE_NAME) + ', "ID": ' + JSON.stringify(sID) + '}';
		let res = await CreateSplendidRequest(sUrl, 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
		//if ( result.status == 0 )
		// 10/06/2011 Paul.  It does not make sense to allow deletes at this time. 
		//reject('A record cannot be deleted when offline.');
	}
}

// 05/13/2018 Paul.  Not got to save to cache at this time. 
/*
export async function UpdateCache(sMODULE_NAME, row, sID): Promise<any>
{
	return new Promise(function(resolve, reject)
	{
		//alert('UpdateCache(' + sMODULE_NAME + ', ' + sID + ')');
		// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
		// 12/01/2014 Paul.  Do not cache for mobile client. 
		if ( bENABLE_OFFLINE && !bMOBILE_CLIENT && window.localStorage )
		{
			SplendidStorage.foreach(function(status, key, value)
			{
				if ( status == 1 )
				{
					// 11/28/2011 Paul.  Remove module lists, but not the default. 
					if ( key.indexOf('Rest.svc/GetModuleList?ModuleName=' + sMODULE_NAME + '&') > 0 )
					{
						var bFound = false;
						var result = JSON.parse(value);
						// 12/06/2014 Paul.  Make sure that cached value is a valid result. 
						if ( result.d !== undefined && result.d.results !== undefined )
						{
							var rows = result.d.results;
							for ( var i = 0; i < rows.length; i++ )
							{
								if ( rows[i]['ID'] == sID )
								{
									rows[i] = row;
									bFound = true;
								}
							}
							if ( !bFound )
							{
								// 11/28/2011 Paul.  If the item does not exist, then add it to the end. 
								rows.push(row);
							}
							value = JSON.stringify(result);
							SplendidStorage.setItem(key, value, function(status, message)
							{
							});
						}
					}
				}
			});
		}
	});
}
*/

export async function UpdateAdminConfig(row: any): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( row == null )
	{
		throw new Error('UpdateModule: row is invalid.');
	}
	else
	{
		let sBody = JSON.stringify(row);
		let sUrl = null;
		sUrl = 'Administration/Rest.svc/UpdateAdminConfig';
		let res = await CreateSplendidRequest(sUrl, 'POST', 'application/octet-stream', sBody);
		let json = await GetSplendidResult(res);
	}
}

// 11/25/2020 Paul.  We need a way to call a generic procedure.  Security is still managed through SYSTEM_REST_TABLES. 
export async function AdminProcedure(sPROCEDURE_NAME: string, row: any): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sPROCEDURE_NAME == null )
	{
		throw new Error('AdminProcedure: sPROCEDURE_NAME is invalid.');
	}
	else if ( row == null )
	{
		throw new Error('AdminProcedure: row is invalid.');
	}
	else
	{
		let sUrl = null;
		sUrl = 'Administration/Rest.svc/AdminProcedure';
		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest(sUrl + '?ProcedureName=' + sPROCEDURE_NAME, 'POST', 'application/octet-stream', sBody);
		let json = await GetSplendidResult(res);
		json.d.__sql = json.__sql;
		return (json.d);
	}
}

// 07/05/2021 Paul.  We need a way to call a generic procedure.  Security is still managed through SYSTEM_REST_TABLES. 
export async function ExecProcedure(sPROCEDURE_NAME: string, row: any): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sPROCEDURE_NAME == null )
	{
		throw new Error('ExecProcedure: sPROCEDURE_NAME is invalid.');
	}
	else if ( row == null )
	{
		throw new Error('ExecProcedure: row is invalid.');
	}
	else
	{
		let sUrl = null;
		sUrl = 'Rest.svc/ExecProcedure';
		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest(sUrl + '?ProcedureName=' + sPROCEDURE_NAME, 'POST', 'application/octet-stream', sBody);
		let json = await GetSplendidResult(res);
		json.d.__sql = json.__sql;
		return (json.d);
	}
}

export async function UpdateModule(sMODULE_NAME: string, row: any, sID: string, bADMIN_MODE?: boolean): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sMODULE_NAME == null )
	{
		throw new Error('UpdateModule: sMODULE_NAME is invalid.');
	}
	else if ( row == null )
	{
		throw new Error('UpdateModule: row is invalid.');
	}
	else
	{
		let sBody = JSON.stringify(row);
		let sUrl = null;
		if ( bADMIN_MODE )
		{
			sUrl = 'Administration/Rest.svc/UpdateAdminModule';
		}
		else
		{
			sUrl = 'Rest.svc/UpdateModule';
		}
		let res = await CreateSplendidRequest(sUrl + '?ModuleName=' + sMODULE_NAME, 'POST', 'application/octet-stream', sBody);
		let json = await GetSplendidResult(res);
		// 10/11/2011 Paul.  We only need this logic if Offline has been enabled. 
		// Firefox will throw an exception when localStorage is called within a browser extension. 
		// 10/19/2011 Paul.  IE6 does not support localStorage. 
		// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
		// 05/13/2018 Paul.  Not got to save to cache at this time. 
		/*
		if ( bENABLE_OFFLINE && window.localStorage && (sID !== undefined && sID != null && sID != '') )
		{
			var key = sREMOTE_SERVER + 'Rest.svc/GetModuleItem?ModuleName=' + sMODULE_NAME + '&ID=' + sID;
			var arrOFFLINE_CACHE = new Object();
			if ( localStorage['OFFLINE_CACHE'] != null )
			{
				arrOFFLINE_CACHE = JSON.parse(localStorage['OFFLINE_CACHE']);
			}
			if ( arrOFFLINE_CACHE[key] != null )
			{
				// 10/07/2011 Paul.  Delete is not working. 
				delete arrOFFLINE_CACHE[key];
				// 10/16/2011 Paul.  Lets try using delete, but if it fails, then copy the object. 
				if ( arrOFFLINE_CACHE[key] != null )
				{
					var arrNEW_CACHE = new Object();
					for ( var keyCopy in arrOFFLINE_CACHE )
					{
						if ( key != keyCopy )
							arrNEW_CACHE[keyCopy] = arrOFFLINE_CACHE[keyCopy];
					}
					arrOFFLINE_CACHE = arrNEW_CACHE;
				}
				//alert(dumpObj(arrOFFLINE_CACHE, 'delete cache item'));
				localStorage['OFFLINE_CACHE'] = JSON.stringify(arrOFFLINE_CACHE);
			}
		}
		*/
		// 10/16/2011 Paul.  sID is now a parameter so that it can be distinguished from Offline ID for a new record. 
		// We want to make sure to send a NULL for new records so that the ID is generated on the server with a true GUID. 
		// JavaScript cannot generate a true GUID, but this generated value should be valid on the single device. 
		sID = json.d;

		// 11/28/2011 Paul.  We need to update any cached list. 
		// 05/13/2018 Paul.  Not got to save to cache at this time. 
		//UpdateCache(sMODULE_NAME, row, sID);

		return (sID);
		/*
			if ( result.status == 0 )
			{
				// 10/02/2011 Paul.  When offline, we need to save to a separate area. 
				// 10/19/2011 Paul.  IE6 does not support localStorage. 
				// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
				if ( bENABLE_OFFLINE && window.localStorage )
				{
					var arrOFFLINE_CACHE = new Object();
					if ( localStorage['OFFLINE_CACHE'] != null )
					{
						arrOFFLINE_CACHE = JSON.parse(localStorage['OFFLINE_CACHE']);
					}
					// 10/16/2011 Paul.  sID is now a parameter so that it can be distinguished from Offline ID for a new record. 
					// We want to make sure to send a NULL for new records so that the ID is generated on the server with a true GUID. 
					// JavaScript cannot generate a true GUID, but this generated value should be valid on the single device. 
					//var sID = row['ID'];
					if ( sID === undefined || sID == null || sID == '' )
					{
						// http://www.broofa.com/2008/09/javascript-uuid-function/
						sID = Math.uuid().toLowerCase();
						//row['ID'] = sID;
					}
					var key = sREMOTE_SERVER + 'Rest.svc/GetModuleItem?ModuleName=' + sMODULE_NAME + '&ID=' + sID;
					if ( arrOFFLINE_CACHE[key] == null )
						arrOFFLINE_CACHE[key] = new Object();
					// 10/11/2011 Paul.  We are having problems with the iterator key, so save within the object. 
					arrOFFLINE_CACHE[key].KEY           = key;
					arrOFFLINE_CACHE[key].ID            = sID;
					arrOFFLINE_CACHE[key].NAME         = row['NAME'];
					arrOFFLINE_CACHE[key].MODULE_NAME   = sMODULE_NAME;
					arrOFFLINE_CACHE[key].DATE_CACHED   = (new Date()).toDateString();
					arrOFFLINE_CACHE[key].DATE_MODIFIED = arrOFFLINE_CACHE[key].DATE_CACHED
					if ( row['DATE_MODIFIED'] !== undefined )
						arrOFFLINE_CACHE[key].DATE_MODIFIED = row['DATE_MODIFIED'];
					if ( row['FIRST_NAME'] !== undefined )
					{
						row['NAME'] = row['FIRST_NAME'] + ' ' + row['LAST_NAME'];
						arrOFFLINE_CACHE[key].NAME = row['NAME'];
					}
					
					var result = { 'd': { 'results': row } };
					// 10/06/2011 Paul.  By storing the offline cached data in the same location as the online cached data, we can reduce the customizations. 
					localStorage[key] = JSON.stringify(result);
					localStorage['OFFLINE_CACHE'] = JSON.stringify(arrOFFLINE_CACHE);
					
					// 11/28/2011 Paul.  We need to update any cached list. 
					UpdateCache(sMODULE_NAME, row, sID);
					
					callback.call(context||this, 3, sID);
				}
				else
				{
					callback.call(context||this, -1, 'Offline save is not suported at this time.');
				}
			}
			*/
	}
}

// 11/23/2020 Paul.  Allow update of module table, such as TERMINOLOGY_LIST
export async function UpdateModuleTable(sTABLE_NAME: string, row: any, sID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sTABLE_NAME == null )
	{
		throw new Error('UpdateModuleTable: sTABLE_NAME is invalid.');
	}
	else if ( row == null )
	{
		throw new Error('UpdateModuleTable: row is invalid.');
	}
	else
	{
		let sUrl = null;
		sUrl = 'Rest.svc/UpdateModuleTable';
		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest(sUrl + '?TableName=' + sTABLE_NAME, 'POST', 'application/octet-stream', sBody);
		let json = await GetSplendidResult(res);
		sID = json.d;
		return (sID);
		//if ( result.status == 0 )
		//reject('Offline save is not suported at this time.');	
	}
}

// 03/17/2020 Paul.  React Client needs the ability to create a Stream Post. 
export async function InsertModuleStreamPost(sMODULE_NAME: string, row: any, sID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sMODULE_NAME == null )
	{
		throw new Error('InsertModuleStreamPost: sMODULE_NAME is invalid.');
	}
	else if ( row == null )
	{
		throw new Error('InsertModuleStreamPost: row is invalid.');
	}
	else
	{
		row['ID'] = sID;
		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/InsertModuleStreamPost?ModuleName=' + sMODULE_NAME, 'POST', 'application/octet-stream', sBody);
		let json = await GetSplendidResult(res);
	}
}

export async function DeleteRelatedItem(sPRIMARY_MODULE: string, sPRIMARY_ID: string, sRELATED_MODULE: string, sRELATED_ID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sPRIMARY_MODULE == null )
	{
		throw new Error('DeleteRelatedItem: sPRIMARY_MODULE is invalid.');
	}
	else if ( sRELATED_MODULE == null )
	{
		throw new Error('DeleteRelatedItem: sRELATED_MODULE is invalid.');
	}
	else if ( sPRIMARY_ID == null )
	{
		throw new Error('DeleteRelatedItem: sPRIMARY_ID is invalid.');
	}
	else if ( sRELATED_ID == null )
	{
		throw new Error('DeleteRelatedItem: sRELATED_ID is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['ModuleName'   ] = sPRIMARY_MODULE;
		row['ID'           ] = sPRIMARY_ID    ;
		row['RelatedModule'] = sRELATED_MODULE;
		row['RelatedID'    ] = sRELATED_ID    ;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/DeleteRelatedItem', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

// 10/16/2020 Paul.  Regions.Countries is an example of a table that is deleted by value, not by guid. 
export async function DeleteRelatedValue(sPRIMARY_MODULE: string, sPRIMARY_ID: string, sRELATED_TABLE: string, sRELATED_VALUE: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sPRIMARY_MODULE == null )
	{
		throw new Error('DeleteRelatedValue: sPRIMARY_MODULE is invalid.');
	}
	else if ( sRELATED_TABLE == null )
	{
		throw new Error('DeleteRelatedValue: sRELATED_TABLE is invalid.');
	}
	else if ( sPRIMARY_ID == null )
	{
		throw new Error('DeleteRelatedValue: sPRIMARY_ID is invalid.');
	}
	else if ( sRELATED_VALUE == null )
	{
		throw new Error('DeleteRelatedValue: sRELATED_VALUE is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['ModuleName'  ] = sPRIMARY_MODULE;
		row['ID'          ] = sPRIMARY_ID    ;
		row['RelatedTable'] = sRELATED_TABLE ;
		row['RelatedValue'] = sRELATED_VALUE ;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/DeleteRelatedValue', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

export async function UpdateRelatedItem(sPRIMARY_MODULE: string, sPRIMARY_ID: string, sRELATED_MODULE: string, sRELATED_ID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sPRIMARY_MODULE == null )
	{
		throw new Error('UpdateRelatedItem: sPRIMARY_MODULE is invalid.');
	}
	else if ( sRELATED_MODULE == null )
	{
		throw new Error('UpdateRelatedItem: sRELATED_MODULE is invalid.');
	}
	else if ( sPRIMARY_ID == null )
	{
		throw new Error('UpdateRelatedItem: sPRIMARY_ID is invalid.');
	}
	else if ( sRELATED_ID == null )
	{
		throw new Error('UpdateRelatedItem: sRELATED_ID is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['ModuleName'   ] = sPRIMARY_MODULE;
		row['ID'           ] = sPRIMARY_ID    ;
		row['RelatedModule'] = sRELATED_MODULE;
		row['RelatedID'    ] = sRELATED_ID    ;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/UpdateRelatedItem', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

// 07/09/2019 Paul.  UpdateRelatedList is identical to UpdateRelatedItem but accepts an array. 
export async function UpdateRelatedList(sPRIMARY_MODULE: string, sPRIMARY_ID: string, sRELATED_MODULE: string, arrRELATED_ID): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sPRIMARY_MODULE == null )
	{
		throw new Error('UpdateRelatedItem: sPRIMARY_MODULE is invalid.');
	}
	else if ( sRELATED_MODULE == null )
	{
		throw new Error('UpdateRelatedItem: sRELATED_MODULE is invalid.');
	}
	else if ( sPRIMARY_ID == null )
	{
		throw new Error('UpdateRelatedItem: sPRIMARY_ID is invalid.');
	}
	else if ( arrRELATED_ID == null || !Array.isArray(arrRELATED_ID) )
	{
		throw new Error('UpdateRelatedItem: arrRELATED_ID is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['ModuleName'   ] = sPRIMARY_MODULE;
		row['ID'           ] = sPRIMARY_ID;
		row['RelatedModule'] = sRELATED_MODULE;
		row['RelatedList'  ] = arrRELATED_ID;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/UpdateRelatedList', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

export async function UpdateRelatedValues(sPRIMARY_MODULE: string, sPRIMARY_ID: string, sRELATED_TABLE: string, arrRELATED_VALUE): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sPRIMARY_MODULE == null )
	{
		throw new Error('UpdateRelatedItem: sPRIMARY_MODULE is invalid.');
	}
	else if ( sRELATED_TABLE == null )
	{
		throw new Error('UpdateRelatedItem: sRELATED_TABLE is invalid.');
	}
	else if ( sPRIMARY_ID == null )
	{
		throw new Error('UpdateRelatedItem: sPRIMARY_ID is invalid.');
	}
	else if ( arrRELATED_VALUE == null || !Array.isArray(arrRELATED_VALUE) )
	{
		throw new Error('UpdateRelatedItem: arrRELATED_VALUE is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['ModuleName'   ] = sPRIMARY_MODULE ;
		row['ID'           ] = sPRIMARY_ID     ;
		row['RelatedTable' ] = sRELATED_TABLE  ;
		row['RelatedValues'] = arrRELATED_VALUE;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/UpdateRelatedValues', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

export async function AddToFavorites(sMODULE: string, gID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sMODULE == null )
	{
		throw new Error('AddToFavorites: sMODULE is invalid.');
	}
	else if ( gID == null )
	{
		throw new Error('AddToFavorites: gID is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['MODULE'] = sMODULE;
		row['ID'    ] = gID;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/AddToFavorites', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

export async function RemoveFromFavorites(sMODULE: string, gID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sMODULE == null )
	{
		throw new Error('RemoveFromFavorites: sMODULE is invalid.');
	}
	else if ( gID == null )
	{
		throw new Error('RemoveFromFavorites: gID is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['MODULE'] = sMODULE;
		row['ID'    ] = gID;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/RemoveFromFavorites', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

export async function AddSubscription(sMODULE: string, gID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sMODULE == null )
	{
		throw new Error('AddSubscription: sMODULE is invalid.');
	}
	else if ( gID == null )
	{
		throw new Error('AddSubscription: gID is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['MODULE'] = sMODULE;
		row['ID'    ] = gID;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/AddSubscription', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

export async function RemoveSubscription(sMODULE: string, gID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sMODULE == null )
	{
		throw new Error('RemoveSubscription: sMODULE is invalid.');
	}
	else if ( gID == null )
	{
		throw new Error('RemoveSubscription: gID is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['MODULE'] = sMODULE;
		row['ID'    ] = gID;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/RemoveSubscription', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
	}
}

export async function UpdateSavedSearch(gID: string, sSEARCH_MODULE: string, sCONTENTS: string, sNAME: string, gDEFAULT_SEARCH_ID: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sSEARCH_MODULE == null)
	{
		throw new Error('UpdateRelatedItem: sSEARCH_MODULE is invalid.');
	}
	else
	{
		let row: any =new Object();
		row['ID'               ] = gID               ;
		row['SEARCH_MODULE'    ] = sSEARCH_MODULE    ;
		row['CONTENTS'         ] = sCONTENTS         ;
		row['NAME'             ] = sNAME             ;
		row['DEFAULT_SEARCH_ID'] = gDEFAULT_SEARCH_ID;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/UpdateSavedSearch', 'POST', 'application/octet-stream', sBody);
		let json = await GetSplendidResult(res);
		gID = json.d;
		return gID;
	}
}

export async function DeleteSavedSearch(gID: string, sSEARCH_MODULE: string): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		let row: any =new Object();
		row['ID'               ] = gID               ;
		row['SEARCH_MODULE'    ] = sSEARCH_MODULE    ;

		let sBody: string = JSON.stringify(row);
		let res = await CreateSplendidRequest('Rest.svc/DeleteSavedSearch', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
	}
}

export async function MassDeleteModule(sMODULE_NAME: string, arrID_LIST, bADMIN_MODE?: boolean): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		let sUrl = null;
		if ( bADMIN_MODE )
		{
			sUrl = 'Administration/Rest.svc/MassDeleteAdminModule';
		}
		else
		{
			sUrl = 'Rest.svc/MassDeleteModule';
		}
		let sBody: string = '{"ModuleName": ' + JSON.stringify(sMODULE_NAME) + ', "ID_LIST": ' + JSON.stringify(arrID_LIST) + '}';
		// 02/11/2021 Paul.  Add support for admin MassDelete. 
		let res = await CreateSplendidRequest(sUrl, 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
		//if ( result.status == 0 )
		// 10/06/2011 Paul.  It does not make sense to allow deletes at this time. 
		//reject('A record cannot be deleted when offline.');
	}
}

export async function MassUpdateModule(sMODULE_NAME, row, arrID_LIST, bADMIN_MODE?): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else if ( sMODULE_NAME == null )
	{
		throw new Error('UpdateModule: sMODULE_NAME is invalid.');
	}
	else if ( row == null )
	{
		throw new Error('UpdateModule: row is invalid.');
	}
	else
	{
		row.ID_LIST = arrID_LIST;
		let sBody = JSON.stringify(row);
		let sUrl = null;
		if ( bADMIN_MODE )
		{
			sUrl = 'Administration/Rest.svc/MassUpdateAdminModule';
		}
		else
		{
			sUrl = 'Rest.svc/MassUpdateModule';
		}
		let res = await CreateSplendidRequest(sUrl + '?ModuleName=' + sMODULE_NAME, 'POST', 'application/octet-stream', sBody);
		await GetSplendidResult(res);
	}
}

// 07/16/2019 Paul.  Add support for Rest API for MassSync/MassUnsync. 
export async function MassSync(sMODULE_NAME, arrID_LIST): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		let sBody: string = '{"ModuleName": ' + JSON.stringify(sMODULE_NAME) + ', "ID_LIST": ' + JSON.stringify(arrID_LIST) + '}';
		let res = await CreateSplendidRequest('Rest.svc/MassSync', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
		//if ( result.status == 0 )
		// 10/06/2011 Paul.  It does not make sense to allow deletes at this time. 
		//reject('A record cannot be deleted when offline.');
	}
}

export async function MassUnsync(sMODULE_NAME, arrID_LIST): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		let sBody: string = '{"ModuleName": ' + JSON.stringify(sMODULE_NAME) + ', "ID_LIST": ' + JSON.stringify(arrID_LIST) + '}';
		let res = await CreateSplendidRequest('Rest.svc/MassUnsync', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
		//if ( result.status == 0 )
		// 10/06/2011 Paul.  It does not make sense to allow deletes at this time. 
		//reject('A record cannot be deleted when offline.');
	}
}

// 07/16/2019 Paul.  Add support for Rest API for ArchiveMoveData/ArchiveRecoverData. 
export async function ArchiveMoveData(sMODULE_NAME, arrID_LIST): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		let sBody: string = '{"ModuleName": ' + JSON.stringify(sMODULE_NAME) + ', "ID_LIST": ' + JSON.stringify(arrID_LIST) + '}';
		let res = await CreateSplendidRequest('Rest.svc/ArchiveMoveData', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
		//if ( result.status == 0 )
		// 10/06/2011 Paul.  It does not make sense to allow deletes at this time. 
		//reject('A record cannot be deleted when offline.');
	}
}

export async function ArchiveRecoverData(sMODULE_NAME, arrID_LIST): Promise<any>
{
	if ( !Credentials.ValidateCredentials )
	{
		throw new Error('Invalid connection information.');
	}
	else
	{
		let sBody: string = '{"ModuleName": ' + JSON.stringify(sMODULE_NAME) + ', "ID_LIST": ' + JSON.stringify(arrID_LIST) + '}';
		let res = await CreateSplendidRequest('Rest.svc/ArchiveRecoverData', 'POST', 'application/json; charset=utf-8', sBody);
		let json = await GetSplendidResult(res);
		return 1;
		//if ( result.status == 0 )
		// 10/06/2011 Paul.  It does not make sense to allow deletes at this time. 
		//reject('A record cannot be deleted when offline.');
	}
}

