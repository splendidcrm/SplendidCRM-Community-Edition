/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function Terminology_LoadAllTerms(callback)
{
	var xhr = SystemCacheRequestAll('GetAllTerminology');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							//alert(dumpObj(result.d, 'd'));
							TERMINOLOGY = result.d.results;
							// 05/07/2013 Paul. Return the entire TERMINOLOGY table. 
							callback(1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
						}
						else
						{
							callback(-1, xhr.responseText);
						}
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback(-1, result.ExceptionDetail.Message);
						else
							callback(-1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback(-1, SplendidError.FormatError(e, 'Terminology_LoadAllTerms'));
				}
			});
		}
	}
	try
	{
		xhr.send();
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback(-1, SplendidError.FormatError(e, 'Terminology_LoadAllTerms'));
	}
}

function Terminology_LoadAllLists(callback)
{
	var xhr = SystemCacheRequestAll('GetAllTerminologyLists');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							//alert(dumpObj(result.d, 'd'));
							TERMINOLOGY_LISTS = result.d.results;
							// 05/07/2013 Paul. Return the entire TERMINOLOGY table. 
							callback(1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
						}
						else
						{
							callback(-1, xhr.responseText);
						}
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback(-1, result.ExceptionDetail.Message);
						else
							callback(-1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback(-1, SplendidError.FormatError(e, 'Terminology_LoadAllLists'));
				}
			});
		}
	}
	try
	{
		xhr.send();
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback(-1, SplendidError.FormatError(e, 'Terminology_LoadAllLists'));
	}
}

function Terminology_SetTerm(sMODULE_NAME, sNAME, sDISPLAY_NAME)
{
	try
	{
		if ( sMODULE_NAME == null )
			sMODULE_NAME = '';
		TERMINOLOGY[sUSER_LANG + '.' + sMODULE_NAME + '.' + sNAME] = sDISPLAY_NAME;
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'Terminology_SetTerm');
	}
}

function Terminology_SetListTerm(sLIST_NAME, sNAME, sDISPLAY_NAME)
{
	try
	{
		TERMINOLOGY[sUSER_LANG + '.' + '.' + sLIST_NAME + '.' + sNAME] = sDISPLAY_NAME;
		if ( TERMINOLOGY_LISTS[sUSER_LANG + '.' + sLIST_NAME] == null )
			TERMINOLOGY_LISTS[sUSER_LANG + '.' + sLIST_NAME] = new Array();
		TERMINOLOGY_LISTS[sUSER_LANG + '.' + sLIST_NAME].push(sNAME);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'Terminology_SetListTerm');
	}
}

function Terminology_LoadGlobal(callback)
{
	// 09/05/2011 Paul.  Include LBL_NEW_FORM_TITLE for the tab menu. 
	// 06/11/2012 Paul.  Wrap Terminology requests for Cordova. 
	var xhr = TerminologyRequest(null, null, 'NAME asc', sUSER_LANG);
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=NAME asc&$filter=' + encodeURIComponent('(LANG eq \'' + sUSER_LANG + '\' and (MODULE_NAME is null or MODULE_NAME eq \'Teams\' or NAME eq \'LBL_NEW_FORM_TITLE\'))'), 'GET');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							TERMINOLOGY[sUSER_LANG + '.' + '.Loaded'] = true;
							//alert(dumpObj(result, 'result'));
							for ( var i = 0; i < result.d.results.length; i++ )
							{
								var obj = result.d.results[i];
								if ( obj['LIST_NAME'] == null )
									Terminology_SetTerm(obj['MODULE_NAME'], obj['NAME'], obj['DISPLAY_NAME']);
								else
									Terminology_SetListTerm(obj['LIST_NAME'], obj['NAME'], obj['DISPLAY_NAME']);
							}
							// 10/04/2011 Paul. Return the entire TERMINOLOGY table. 
							callback(1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
						}
						else
						{
							callback(-1, xhr.responseText);
						}
					}
					else
					{
						if ( result.status == 0 )
							callback(0, result.ExceptionDetail.Message);
						else if ( result.ExceptionDetail !== undefined )
							callback(-1, result.ExceptionDetail.Message);
						else
							callback(-1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback(-1, SplendidError.FormatError(e, 'Terminology_LoadGlobal'));
				}
			});
		}
	}
	try
	{
		if ( TERMINOLOGY[sUSER_LANG + '.' + '.Loaded'] == null )
			xhr.send();
		else
			callback(1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback(-1, SplendidError.FormatError(e, 'Terminology_LoadGlobal'));
	}
}

function Terminology_LoadList(sLIST_NAME, callback)
{
	// 06/11/2012 Paul.  Wrap Terminology requests for Cordova. 
	var xhr = TerminologyRequest(null, sLIST_NAME, 'LIST_NAME asc', sUSER_LANG);
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=LIST_NAME asc, LIST_ORDER asc, NAME asc&$filter=' + encodeURIComponent('(LANG eq \'' + sUSER_LANG + '\' and MODULE_NAME is null and LIST_NAME eq \'' + sLIST_NAME + '\')'), 'GET');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							//alert(dumpObj(result, 'result'));
							for ( var i = 0; i < result.d.results.length; i++ )
							{
								var obj = result.d.results[i];
								Terminology_SetListTerm(sLIST_NAME, obj['NAME'], obj['DISPLAY_NAME']);
							}
							// 10/04/2011 Paul. Return the entire TERMINOLOGY table. 
							callback(1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
						}
						else
						{
							callback(-1, xhr.responseText);
						}
					}
					else
					{
						if ( result.status == 0 )
							callback(0, result.ExceptionDetail.Message);
						else if ( result.ExceptionDetail !== undefined )
							callback(-1, result.ExceptionDetail.Message);
						else
							callback(-1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback(-1, SplendidError.FormatError(e, 'Terminology_LoadList'));
				}
			});
		}
	}
	try
	{
		xhr.send();
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback(-1, SplendidError.FormatError(e, 'Terminology_LoadList'));
	}
}

function Terminology_LoadCustomList(sLIST_NAME, callback)
{
	var xhr = CreateSplendidRequest('Rest.svc/GetCustomList?ListName=' + sLIST_NAME, 'GET');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							//alert(dumpObj(result, 'result'));
							for ( var i = 0; i < result.d.results.length; i++ )
							{
								var obj = result.d.results[i];
								Terminology_SetListTerm(sLIST_NAME, obj['NAME'], obj['DISPLAY_NAME']);
							}
							// 10/04/2011 Paul. Return the entire TERMINOLOGY table. 
							callback(1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
						}
						else
						{
							callback(-1, xhr.responseText);
						}
					}
					else
					{
						if ( result.status == 0 )
							callback(0, result.ExceptionDetail.Message);
						else if ( result.ExceptionDetail !== undefined )
							callback(-1, result.ExceptionDetail.Message);
						else
							callback(-1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback(-1, SplendidError.FormatError(e, 'Terminology_LoadCustomList'));
				}
			});
		}
	}
	try
	{
		xhr.send();
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback(-1, SplendidError.FormatError(e, 'Terminology_LoadCustomList'));
	}
}

function Terminology_LoadModule(sMODULE_NAME, callback, context)
{
	// 06/11/2012 Paul.  Wrap Terminology requests for Cordova. 
	var xhr = TerminologyRequest(sMODULE_NAME, null, 'NAME asc', sUSER_LANG);
	//var xhr = CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=TERMINOLOGY&$orderby=NAME asc&$filter=' + encodeURIComponent('(LANG eq \'' + sUSER_LANG + '\' and MODULE_NAME eq \'' + sMODULE_NAME + '\' and LIST_NAME is null)'), 'GET');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							TERMINOLOGY[sUSER_LANG + '.' + sMODULE_NAME + '.Loaded'] = true;
							//alert(dumpObj(result, 'result'));
							for ( var i = 0; i < result.d.results.length; i++ )
							{
								var obj = result.d.results[i];
								Terminology_SetTerm(sMODULE_NAME, obj['NAME'], obj['DISPLAY_NAME']);
							}
							// 10/04/2011 Paul. Return the entire TERMINOLOGY table. 
							callback.call(context||this, 1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
						}
						else
						{
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else
					{
						if ( result.status == 0 )
							callback.call(context||this, 0, result.ExceptionDetail.Message);
						else if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'Terminology_LoadModule'));
				}
			}, context||this);
		}
	}
	try
	{
		if ( TERMINOLOGY[sUSER_LANG + '.' + sMODULE_NAME + '.Loaded'] == null )
			xhr.send();
		else
			callback.call(context||this, 1, { 'sUSER_LANG': sUSER_LANG, 'TERMINOLOGY': TERMINOLOGY, 'TERMINOLOGY_LISTS': TERMINOLOGY_LISTS } );
	}
	catch(e)
	{
		// 03/28/2012 Paul.  IE9 is returning -2146697208 when working offline. 
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'Terminology_LoadModule'));
	}
};

