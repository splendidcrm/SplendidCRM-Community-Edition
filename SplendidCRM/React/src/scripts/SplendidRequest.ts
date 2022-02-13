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
import Sql            from '../scripts/Sql'        ;
import Credentials    from '../scripts/Credentials';
import { StartsWith } from '../scripts/utility'    ;

class CordovaHttpResponse
{
	public ok        : boolean;
	public status    : number;
	public statusText: string;
	public url       : string;
	public headers   : any;
	public data      : any;

	constructor(ok: boolean, res: any)
	{
		this.ok         = ok         ;
		this.url        = res.url    ;
		this.status     = res.status ;
		this.statusText = res.status ;
		this.headers    = res.headers;
		this.data       = res.data   ;
		if ( !ok )
		{
			this.statusText = res.error;
			if ( Sql.IsEmptyString(this.statusText) && res.status )
			{
				switch ( res.status )
				{
					case 404:  this.statusText = '404 Not Found'            ;  break;
					case 403:  this.statusText = '403 Forbidden'            ;  break;
					case 500:  this.statusText = '500 Internal Server Error';  break;
					case 503:  this.statusText = '503 Service Unavailable'  ;  break;
					case 504:  this.statusText = '504 Gateway Timeout'      ;  break;
					default:   this.statusText = 'HTTP Error ' + res.status.toString();  break;
				}
			}
			else
			{
				this.data = res.error;
			}
		}
	}

	public text = () : Promise<string> =>
	{
		return new Promise<string>((resolve, resonse) =>
		{
			resolve(this.data);
		});
	}
}

function CordovaHttpRequest(sPath: string, sMethod?: string, sContentType?: string, sBody?: string): Promise<any>
{
	let url = Credentials.RemoteServer + sPath;
	//console.log((new Date()).toISOString() + ' CordovaHttpRequest: ' + sMethod + ' ' + url, sBody);
	return new Promise((resolve, reject) =>
	{
		window.cordova.plugin.http.setDataSerializer('utf8');
		window.cordova.plugin.http.setServerTrustMode('nocheck'
		, function()  // Success
		{
			window.cordova.plugin.http.setClientAuthMode('none', {}
			, function()  // Success
			{
				let arrHeaders: any = {};
				arrHeaders["Content-Type"] = sContentType   ;
				//console.log((new Date()).toISOString() + ' CordovaHttpRequest Content-Type: ' + sContentType);

				//arrHeaders["Cookie"      ] = document.cookie;
				try
				{
					//console.log((new Date()).toISOString() + ' CordovaHttpRequest cookie: ', document.cookie);
					if ( !Sql.IsEmptyString(document.cookie) )
					{
						window.cordova.plugin.http.setCookie(url, document.cookie);
					}
				}
				catch(e)
				{
					//console.log((new Date()).toISOString() + ' CordovaHttpRequest cookie error: ', e);
				}
				if ( Credentials.sAUTHENTICATION == 'Basic' )
				{
					arrHeaders["Authorization"] = 'Basic ' + btoa(Credentials.sUSER_NAME + ':' + Credentials.sPASSWORD);
				}
				// https://github.com/silkimen/cordova-plugin-advanced-http
				let options: any =
				{
					method     : sMethod.toLowerCase(),
					headers    : arrHeaders,
					serializer : 'utf8',
				};
				// 11/16/2020 Paul.  advanced-http does not want to send null as the body. 
				// advanced-http: "data" option is configured to support only following data types: String
				if ( sMethod == 'POST' )
				{
					if ( sBody === undefined || sBody == null )
						sBody = '';
					options.data= sBody;
				}
				try
				{
					window.cordova.plugin.http.sendRequest(url, options
					, function(res)  // success
					{
						//console.log((new Date()).toISOString() + ' CordovaHttpRequest sendRequest data: ', res.data);
						let xhr = new CordovaHttpResponse(true, res);
						resolve(xhr);
					}
					, function(res)  // failure
					{
						console.error((new Date()).toISOString() + ' CordovaHttpRequest ' + sMethod + ' ' + sPath, JSON.stringify(res));
						if ( res.url !== undefined )
						{
							// 11/19/2020 Paul.  Return http errors for further processing. 
							let xhr = new CordovaHttpResponse(false, res);
							resolve(xhr);
						}
						else
						{
							// 11/19/2020 Paul. Return object errors as error. 
							reject(res.error);
						}
					});
				}
				catch(e)
				{
					console.error((new Date()).toISOString() + ' CordovaHttpRequest ' + sMethod + ' ' + sPath, e);
					reject(e.message);
				}
			}
			, function()  // failure
			{
				let res: any = { error: 'CordovaHttpRequest: validateDomainName failure' };
				console.error((new Date()).toISOString() + ' ' + res.error);
				reject(res.error);
			});
		}
		, function()  // failure
		{
			let res: any = { error: 'CordovaHttpRequest: acceptAllCerts failure' };
			console.error((new Date()).toISOString() + ' ' + res.error);
			reject(res.error);
		});
	});
}

export async function CreateSplendidRequest(sPath: string, sMethod?: string, sContentType?: string, sBody?: string)
{
	if ( sMethod === undefined )
	{
		sMethod = 'POST';
	}
	if ( sContentType === undefined )
	{
		sContentType = 'application/json; charset=utf-8';
	}
	// 11/16/2020 Paul.  iOS will not allow json requests due to CORS.  Instead, use cordova-plugin-http. 
	if ( window.cordova && (window.cordova.platformId == 'ios' || window.cordova.platformId == 'android') && window.cordova.plugin && window.cordova.plugin.http )
	{
		let xhr = null;
		try
		{
			xhr = await CordovaHttpRequest(sPath, sMethod, sContentType, sBody);
		}
		catch(error)
		{
			console.error('CreateSplendidRequest/CordovaHttpRequest ' + sMethod + ' ' + sPath, error);
			throw new Error(error);
		}
		//console.log((new Date()).toISOString() + ' CreateSplendidRequest/CordovaHttpRequest', xhr);
		return xhr;
	}
	else
	{
		let arrHeaders = new Headers();
		arrHeaders.append("Content-Type", sContentType   );
		arrHeaders.append("Cookie"      , document.cookie);
		if ( Credentials.sAUTHENTICATION == 'Basic' )
		{
			arrHeaders.append("Authorization", 'Basic ' + btoa(Credentials.sUSER_NAME + ':' + Credentials.sPASSWORD));
		}
		let body: any = sBody;
		// toUTF8Array
		// https://gist.github.com/joni/3760795
		let url = Credentials.RemoteServer;
		//console.log((new Date()).toISOString() + ' ' + sMethod + ' ' + url + sPath, sBody);
		let xhr = null;
		try
		{
			let options: any =
			{
				method     : sMethod,
				headers    : arrHeaders,
				credentials: 'include',
				body       : body
			};
			// 01/03/2019 Paul.  Root of web site ends at the React path. 
			xhr = await fetch(url + sPath, options);
		}
		catch(error)
		{
			console.error('CreateSplendidRequest ' + sMethod + ' ' + sPath, error);
			throw new Error(error);
		}
		return xhr;
	}
}

export async function GetSplendidResult(res: Response)
{
	let responseText = await res.text();
	var json = null;
	if ( !res.ok )
	{
		if ( Sql.IsEmptyString(responseText) )
		{
			responseText = res.statusText;
			if ( Sql.IsEmptyString(responseText) )
			{
				switch ( res.status )
				{
					case 404:  responseText = '404 Not Found'            ;  break;
					case 403:  responseText = '403 Forbidden'            ;  break;
					case 500:  responseText = '500 Internal Server Error';  break;
					case 503:  responseText = '503 Service Unavailable'  ;  break;
					case 504:  responseText = '504 Gateway Timeout'      ;  break;
					default:   responseText = 'HTTP Error ' + res.status.toString();  break;
				}
			}
		}
		else if (StartsWith(responseText, '<?xml'))
		{
			// https://stackoverflow.com/questions/10585029/parse-an-html-string-with-js
			let doc = document.implementation.createHTMLDocument('');
			doc.documentElement.innerHTML = responseText;
			let body: any = doc.getElementsByTagName('body');
			if (body != null && body.length > 0)
				responseText = body[0].innerText;
			else
				responseText = doc.documentElement.innerText;
		}
		else if (StartsWith(responseText, '{'))
		{
			json = JSON.parse(responseText);
			if (json !== undefined && json != null)
			{
				if (json.ExceptionDetail !== undefined)
				{
					console.error(json.ExceptionDetail.Message);
					throw new Error(json.ExceptionDetail.Message);
				}
			}
		}
		console.error(responseText);
		throw new Error(responseText);
	}
	if (StartsWith(responseText, '<html>'))
	{
		throw (res.url + ' is not a avlid service URL.');
	}
	//console.log('GetSplendidResult', responseText);
	if ( StartsWith(responseText, '{') )
	{
		json = JSON.parse(responseText);
		if (json !== undefined && json != null)
		{
			if (json.ExceptionDetail !== undefined)
			{
				console.error(json.ExceptionDetail.Message);
				throw new Error(json.ExceptionDetail.Message);
			}
		}
	}
	else
	{
		json = responseText;
	}
	return json;
}
