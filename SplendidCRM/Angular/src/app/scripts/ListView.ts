/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import { Injectable             } from '@angular/core'                      ;
import { SplendidRequestService } from '../scripts/SplendidRequest'         ;
import { SplendidCacheService   } from '../scripts/SplendidCache'           ;
import { CredentialsService     } from '../scripts/Credentials'             ;
import { CrmModulesService      } from '../scripts/Crm'                     ;
import Sql                        from '../scripts/Sql'                     ;

@Injectable({
	providedIn: 'root'
})
export class ListViewService
{
	constructor(private SplendidRequest: SplendidRequestService, protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, private Crm_Modules: CrmModulesService)
	{
	}

	public async LoadTable(sTABLE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, bADMIN_MODE: boolean): Promise<any>
	{
		// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
		if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
		{
			sSORT_FIELD = '';
			sSORT_DIRECTION = '';
		}
		let obj: any = new Object();
		obj['TableName'    ] = sTABLE_NAME;
		obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
		obj['$select'      ] = sSELECT;
		obj['$filter'      ] = sFILTER;
		// 11/16/2019 Paul.  We will be ignoring the $filter as we transition to $searchvalues to avoid the security issue of passing full SQL query as a paramter. 
		if ( rowSEARCH_VALUES != null )
		{
			obj['$searchvalues'] = rowSEARCH_VALUES;
		}
		let sBody: string = JSON.stringify(obj);
		let json: any = null;
		if ( bADMIN_MODE )
		{
			json = await this.SplendidRequest.CreateSplendidRequest('Administration/Rest.svc/PostAdminTable', 'POST', 'application/octet-stream', sBody);
		}
		else
		{
			json = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/PostModuleTable', 'POST', 'application/octet-stream', sBody);
		}
		// 10/04/2011 Paul.  LoadTable returns the rows. 
		// 05/17/2018 Paul.  Copy total to d to simplfy the return value. 
		json.d.__total = json.__total;
		json.d.__sql = json.__sql;
		return (json.d);
	}

	// 06/13/2017 Paul.  Add pagination. 
	public async LoadTablePaginated(sTABLE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE: boolean, archiveView: boolean): Promise<any>
	{
		// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
		if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
		{
			sSORT_FIELD = '';
			sSORT_DIRECTION = '';
		}
		//console.log('LoadTablePaginated ADMIN_MODE', bADMIN_MODE);
		let obj: any = new Object();
		obj['TableName'    ] = sTABLE_NAME;
		obj['$top'         ] = nTOP       ;
		obj['$skip'        ] = nSKIP      ;
		obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
		obj['$select'      ] = sSELECT    ;
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
		let json: any = null;
		if ( bADMIN_MODE )
		{
			json = await this.SplendidRequest.CreateSplendidRequest('Administration/Rest.svc/PostAdminTable', 'POST', 'application/octet-stream', sBody);
		}
		else
		{
			json = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/PostModuleTable', 'POST', 'application/octet-stream', sBody);
		}
		// 10/04/2011 Paul.  LoadTable returns the rows. 
		// 04/21/2017 Paul.  We need to return the total when using nTOP. 
		// 05/27/2018 Paul.  Copy total to d to simplfy the return value. 
		json.d.__total = json.__total;
		json.d.__sql = json.__sql;
		return (json.d);
	}

	// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
	public async LoadModule(sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any): Promise<any>
	{
		// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
		if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
		{
			sSORT_FIELD = '';
			sSORT_DIRECTION = '';
		}
		// 08/17/2019 Paul.  Post version so that we can support large filter requests.  This is common with the UnifiedSearch. 
		let obj: any = new Object();
		obj['ModuleName'   ] = sMODULE_NAME;
		obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
		obj['$select'      ] = sSELECT;
		obj['$filter'      ] = sFILTER;
		// 11/16/2019 Paul.  We will be ignoring the $filter as we transition to $searchvalues to avoid the security issue of passing full SQL query as a paramter. 
		if ( rowSEARCH_VALUES != null )
		{
			obj['$searchvalues'] = rowSEARCH_VALUES;
		}
		let sBody = JSON.stringify(obj);
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/PostModuleList', 'POST', 'application/octet-stream', sBody);
		//xhr.SearchValues = rowSEARCH_VALUES;
		// 10/04/2011 Paul.  LoadModule returns the rows. 
		// 04/21/2017 Paul.  We need to return the total when using nTOP. 
		// 05/13/2018 Paul.  Instead of returning just the results, we will need to return everything to get the total. 
		// 05/17/2018 Paul.  Copy total to d to simplfy the return value. 
		json.d.__total = json.__total;
		json.d.__sql = json.__sql;
		return (json.d);
	}

	// 12/15/2019 Paul.  Add export. 
	public async ExportModule(sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE: boolean, archiveView: boolean, sEXPORT_RANGE: string, sEXPORT_FORMAT: string, arrSELECTED_ITEMS: string[])
	{
		// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
		if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
		{
			sSORT_FIELD = '';
			sSORT_DIRECTION = '';
		}
		//console.log('LoadModulePaginated ADMIN_MODE', bADMIN_MODE);
		// 08/17/2019 Paul.  Post version so that we can support large filter requests.  This is common with the UnifiedSearch. 
		let obj: any = new Object();
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
		}
		obj['ModuleName'] = sMODULE_NAME;
		// 08/11/2020 Paul.  Both methods work.  The problem with Excel was that we needed to issue Response.Flush() before the Response.End().
		// 06/14/2022 Paul.  TODO.  Change back to fetch by data. 
		if ( true )
		{
			// 08/11/2020 Paul.  This approach uses tradiational get to a web page. 
			let url: string = null;
			for ( let item in obj )
			{
				if ( url == null )
					url = this.Credentials.RemoteServer + 'Import/ExportModule.aspx?';
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
			// 06/14/2022 Paul.  TODO.  Fetch file by data. 
			/*
			let sBody: string = JSON.stringify(obj);
			let res: Response = await this.SplendidRequest.CreateSplendidRequest('Import/ExportModule.aspx', 'POST', 'application/octet-stream', sBody);

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
			*/
		}
	}

	// 04/22/2017 Paul.  Add pagination. 
	public async LoadModulePaginated(sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE: boolean, archiveView: boolean): Promise<any>
	{
		// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
		if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
		{
			sSORT_FIELD = '';
			sSORT_DIRECTION = '';
		}
		//console.log('LoadModulePaginated ADMIN_MODE', bADMIN_MODE);
		// 08/17/2019 Paul.  Post version so that we can support large filter requests.  This is common with the UnifiedSearch. 
		let obj: any = new Object();
		obj['$top'         ] = nTOP       ;
		obj['$skip'        ] = nSKIP      ;
		obj['$orderby'     ] = sSORT_FIELD + ' ' + sSORT_DIRECTION;
		obj['$select'      ] = sSELECT    ;
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
		}
		let json: any = null;
		if ( bADMIN_MODE )
		{
			obj['TableName'] = this.Crm_Modules.TableName(sMODULE_NAME);
			let sBody: string = JSON.stringify(obj);
			json = await this.SplendidRequest.CreateSplendidRequest('Administration/Rest.svc/PostAdminTable', 'POST', 'application/octet-stream', sBody);
		}
		else
		{
			obj['ModuleName'] = sMODULE_NAME;
			let sBody: string = JSON.stringify(obj);
			json = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/PostModuleList', 'POST', 'application/octet-stream', sBody);
		}
		//xhr.SearchValues = rowSEARCH_VALUES;
		// 10/04/2011 Paul.  LoadModule returns the rows. 
		// 04/21/2017 Paul.  We need to return the total when using nTOP. 
		// 05/13/2018 Paul.  Instead of returning just the results, we will need to return everything to get the total. 
		// 05/17/2018 Paul.  Copy total to d to simplfy the return value. 
		json.d.__total = json.__total;
		json.d.__sql = json.__sql;
		return (json.d);
	}

	// 05/21/2017 Paul.  HTML5 Dashboard requires aggregates. 
	public async LoadTableWithAggregate(sTABLE_NAME: string, sORDER_BY: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, sGROUP_BY: string, sAGGREGATE: string): Promise<any>
	{
		// https://www.visualstudio.com/en-us/docs/report/analytics/aggregated-data-analytics
		let sAPPLY = '';
		if (!Sql.IsEmptyString(sGROUP_BY) && !Sql.IsEmptyString(sAGGREGATE))
		{
			// Aggregate types: count, countdistinct, sum, avg, min, max
			sAPPLY = 'groupby((' + sGROUP_BY + '), aggregate(' + sAGGREGATE + '))';
		}
		let obj: any = new Object();
		obj['TableName'    ] = sTABLE_NAME;
		obj['$orderby'     ] = sORDER_BY;
		obj['$select'      ] = sSELECT;
		obj['$filter'      ] = sFILTER;
		obj['$apply'       ] = sAPPLY;
		// 11/16/2019 Paul.  We will be ignoring the $filter as we transition to $searchvalues to avoid the security issue of passing full SQL query as a paramter. 
		if ( rowSEARCH_VALUES != null )
		{
			obj['$searchvalues'] = rowSEARCH_VALUES;
		}
		let sBody = JSON.stringify(obj);
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/PostModuleTable', 'POST', 'application/octet-stream', sBody);
		// 10/04/2011 Paul.  LoadModule returns the rows. 
		// 04/21/2017 Paul.  We need to return the total when using nTOP. 
		// 05/13/2018 Paul.  Instead of returning just the results, we will need to return everything to get the total. 
		// 05/17/2018 Paul.  Copy total to d to simplfy the return value. 
		json.d.__total = json.__total;
		json.d.__sql = json.__sql;
		return (json.d);
	}

	// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
	// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
	public LoadLayout(GRID_NAME: string, ignoreMissing?: boolean)
	{
		let layout: any[] = null;
		if ( Sql.IsEmptyString(this.Credentials.sPRIMARY_ROLE_NAME) )
		{
			layout = this.SplendidCache.GridViewColumns(GRID_NAME, ignoreMissing);
		}
		else
		{
			layout = this.SplendidCache.GridViewColumns(GRID_NAME + '.' + this.Credentials.sPRIMARY_ROLE_NAME, true);
			if ( layout === undefined || layout == null || layout.length == 0 )
			{
				layout = this.SplendidCache.GridViewColumns(GRID_NAME, ignoreMissing);
			}
		}
		// 05/26/2019 Paul.  We will no longer lookup missing layout values if not in the cache. 
		if ( layout == null )
		{
			if ( !ignoreMissing )
			{
				// 01/08/2021 Paul.  No lnoger needed. 
				//console.warn(GRID_NAME + ' not found in ListViews');
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
	public async LoadStreamPaginated(sMODULE_NAME: string, gID: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number): Promise<any>
	{
		// 01/26/2020 Paul.  Make sure that an empty filter does not get sent as "null". 
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/GetModuleStream?ModuleName=' + sMODULE_NAME + (gID ? '&ID=' + gID : '') + '&$top=' + nTOP + '&$skip=' + nSKIP + '&$select=' + encodeURIComponent(sSELECT) + '&$filter=' + (Sql.IsEmptyString(sFILTER) ? '' : encodeURIComponent(sFILTER)), 'GET');
		json.d.__total = json.__total;
		json.d.__sql = json.__sql;
		return (json.d);
	}

	public async LoadActivitiesPaginated(sPARENT_TYPE: string, gPARENT_ID: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, archiveView: boolean): Promise<any>
	{
		// 03/01/2013 Paul.  If sSORT_FIELD is not provided, then clear sSORT_DIRECTION. 
		if (sSORT_FIELD === undefined || sSORT_FIELD == null || sSORT_FIELD == '')
		{
			sSORT_FIELD = '';
			sSORT_DIRECTION = '';
		}
		//console.log('LoadActivitiesPaginated ADMIN_MODE', bADMIN_MODE);
		// 08/17/2019 Paul.  Post version so that we can support large filter requests.  This is common with the UnifiedSearch. 
		// 01/26/2020 Paul.  Make sure that an empty filter does not get sent as "null". 
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/GetActivitiesList?IncludeRelationships=1' + (Sql.ToBoolean(archiveView) ? '&$archiveView=1' : '') + '&PARENT_TYPE=' + sPARENT_TYPE + '&PARENT_ID=' + gPARENT_ID + '&$top=' + nTOP + '&$skip=' + nSKIP + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION) + '&$select=' + encodeURIComponent(sSELECT) + '&$filter=' + (Sql.IsEmptyString(sFILTER) ? '' : encodeURIComponent(sFILTER)), 'GET');
		//xhr.SearchValues = rowSEARCH_VALUES;
		// 10/04/2011 Paul.  LoadModule returns the rows. 
		// 04/21/2017 Paul.  We need to return the total when using nTOP. 
		// 05/13/2018 Paul.  Instead of returning just the results, we will need to return everything to get the total. 
		// 05/17/2018 Paul.  Copy total to d to simplfy the return value. 
		json.d.__total = json.__total;
		json.d.__sql = json.__sql;
		return (json.d);
	}

	public async AutoComplete_ModuleMethod(sMODULE_NAME: string, sMETHOD: string, sREQUEST: any)
	{
		if ( sMODULE_NAME == 'Teams' )
			sMODULE_NAME = 'Administration/Teams';
		else if ( sMODULE_NAME == 'Tags' )
			sMODULE_NAME = 'Administration/Tags';
		// 06/07/2017 Paul.  Add NAICSCodes module. 
		else if ( sMODULE_NAME == 'NAICSCodes' )
			sMODULE_NAME = 'Administration/NAICSCodes';
		let sBody = JSON.stringify(sREQUEST);
		let json: any = await this.SplendidRequest.CreateSplendidRequest(sMODULE_NAME + '/AutoComplete.asmx/' + sMETHOD, 'POST', 'application/json; charset=utf-8', sBody);
		return (json.d);
	}

}
