/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import { Injectable, Inject      } from '@angular/core'                      ;
import { throwError, of          } from 'rxjs'                               ;
import { catchError              } from 'rxjs/operators'                     ;
import { HttpClient, HttpHeaders } from '@angular/common/http'               ;
import { CredentialsService      } from '../scripts/Credentials'             ;
// 05/16/2022 Paul.  Version 8 uses lastValueFrom. 
//import { lastValueFrom      } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SplendidRequestService
{
	constructor(private http: HttpClient, protected Credentials: CredentialsService)
	{
		//console.log(this.constructor.name + '.constructor');
	}

	public async AdminRequestAll(sMethodName: string): Promise<any>
	{
		let sUrl = 'Administration/Rest.svc/' + sMethodName;
		let json: any = await this.CreateSplendidRequest(sUrl, "GET");
		return json;
	}

	public async SystemCacheRequestAll(sMethodName: string) : Promise<any>
	{
		let sUrl: string = 'Rest.svc/' + sMethodName;
		let json: any = await this.CreateSplendidRequest(sUrl, "GET");
		return json;
	}

	// 06/11/2012 Paul.  Wrap System Cache requests for Cordova. 
	public async SystemCacheRequest(sTableName: string, sOrderBy: string, sSelectFields?: string, sFilterField?: string, sFilterValue?: string, bDefaultView?: boolean): Promise<any>
	{
		let sUrl: string = 'Rest.svc/GetModuleTable?TableName=' + sTableName;
		if (sSelectFields !== undefined && sSelectFields != null)
		{
			sUrl += '&$select=' + sSelectFields;
		}
		if (sOrderBy !== undefined && sOrderBy != null)
		{
			sUrl += '&$orderby=' + sOrderBy;
		}
		if (sFilterField !== undefined && sFilterField != null && sFilterValue !== undefined && sFilterValue != null)
		{
			// 09/19/2016 Paul.  The entire filter string needs to be encoded. 
			let filter: string = '(' + sFilterField + ' eq \'' + sFilterValue + '\'';
			if (bDefaultView !== undefined && bDefaultView === true)
				filter += ' and DEFAULT_VIEW eq 0';
			filter += ')';
			sUrl += '&$filter=' + encodeURIComponent(filter);
		}
		let json: any = await this.CreateSplendidRequest(sUrl, "GET");
		return json;
	}

	// 06/11/2012 Paul.  Wrap Terminology requests for Cordova. 
	public async TerminologyRequest(sMODULE_NAME: string, sLIST_NAME: string, sOrderBy: string, sUSER_LANG: string): Promise<any>
	{
		let sUrl: string = 'Rest.svc/GetModuleTable?TableName=TERMINOLOGY';
		if (sOrderBy !== undefined && sOrderBy != null)
		{
			sUrl += '&$orderby=' + sOrderBy;
		}
		if (sMODULE_NAME == null && sLIST_NAME == null)
		{
			sUrl += '&$filter=' + encodeURIComponent('(LANG eq \'' + sUSER_LANG + '\' and (MODULE_NAME is null or MODULE_NAME eq \'Teams\' or NAME eq \'LBL_NEW_FORM_TITLE\'))');
		}
		else
		{
			// 09/19/2016 Paul.  The entire filter string needs to be encoded. 
			let filter: string = '(LANG eq \'' + sUSER_LANG + '\'';
			if (sMODULE_NAME != null)
				filter += ' and MODULE_NAME eq \'' + sMODULE_NAME + '\'';
			else
				filter += ' and MODULE_NAME is null';
			if (sLIST_NAME != null)
				filter += ' and LIST_NAME eq \'' + sLIST_NAME + '\'';
			else
				filter += ' and LIST_NAME is null';
			filter += ')';
			sUrl += '&$filter=' + encodeURIComponent(filter);
		}
		let json: any = this.CreateSplendidRequest(sUrl, "GET");
		return json;
	}

	public async SystemSqlColumns(sMODULE_NAME: string, sMODE: string): Promise<any>
	{
		let sUrl = 'Rest.svc/GetSqlColumns?ModuleName=' + sMODULE_NAME + '&Mode=' + sMODE;
		let json: any = await this.CreateSplendidRequest(sUrl, "GET");
		return json.d;
	}

	public async CreateSplendidRequest(sPath: string, sMethod?: string, sContentType?: string, sBody?: string): Promise<any>
	{
		if ( sMethod === undefined )
		{
			sMethod = 'POST';
		}
		if ( sContentType === undefined )
		{
			sContentType = 'application/json; charset=utf-8';
		}

		const options: any =
		{
			responseType: 'json' as const,
			headers: new HttpHeaders(
			{
				'Content-Type': sContentType,
				// 07/06/2022 Paul.  Can't set cookie.  Should not need to anyway. 
				//'Cookie'      : document.cookie
			}),
			withCredentials: true
		};
		if ( this.Credentials.sAUTHENTICATION == 'Basic' )
		{
			options.headers.set('Authorization', 'Basic ' + btoa(this.Credentials.sUSER_NAME + ':' + this.Credentials.sPASSWORD));
		}
		let json: any = null;
		try
		{
			if ( sMethod == 'GET' )
			{
				json = await this.http.get<any>(this.Credentials.sREMOTE_SERVER + sPath, options)
					.pipe(catchError(this.handleError))
					.toPromise();
			}
			else if ( sMethod == 'POST' )
			{
				json = await this.http.post<any>(this.Credentials.sREMOTE_SERVER + sPath, sBody, options)
					.pipe(catchError(this.handleError))
					.toPromise();
			}
		}
		catch(error: any)
		{
			console.error(this.constructor.name + '.CreateSplendidRequest ' + sMethod + ' ' + sPath, error);
			throw new Error(error);
		}
		// 05/16/2022 Paul.  Version 8 uses lastValueFrom. 
		//let json: any = await lastValueFrom(this.http.get<any>(this.Credentials.sREMOTE_SERVER + sPath));
		return json;
	}

	// https://rollbar.com/blog/error-handling-with-angular-8-tips-and-best-practices/
	// https://blog.angular-university.io/rxjs-error-handling/
	private  handleError(error: any)
	{
		let errorMessage = '';
		if (error.error instanceof ErrorEvent)
		{
			// client-side error
			errorMessage = error.error.message;
		}
		else
		{
			// server-side error
			errorMessage = error.message;
		}
		return throwError(errorMessage);
	}
}
