/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

function GetUserID(callback, context)
{
	var xhr = CreateSplendidRequest('Rest.svc/GetUserID');
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
							sUSER_ID = result.d;
							callback.call(context||this, 1, null);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'GetUserID'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'GetUserID'));
	}
}

function GetUserName(callback, context)
{
	var xhr = CreateSplendidRequest('Rest.svc/GetUserName');
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
							sUSER_NAME = result.d;
							callback.call(context||this, 1, null);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'GetUserName'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'GetUserName'));
	}
}

function GetTeamID(callback, context)
{
	var xhr = CreateSplendidRequest('Rest.svc/GetTeamID');
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
							sTEAM_ID = result.d;
							callback.call(context||this, 1, null);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'GetTeamID'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'GetTeamID'));
	}
}

function GetTeamName(callback, context)
{
	var xhr = CreateSplendidRequest('Rest.svc/GetTeamName');
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
							sTEAM_NAME = result.d;
							callback.call(context||this, 1, null);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'GetTeamName'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'GetTeamName'));
	}
}

function GetUserLanguage(callback, context)
{
	var xhr = CreateSplendidRequest('Rest.svc/GetUserLanguage');
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
							sUSER_LANG = result.d;
							callback.call(context||this, 1, null);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'GetUserLanguage'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'GetUserLanguage'));
	}
}

function GetUserProfile(callback, context)
{
	var xhr = CreateSplendidRequest('Rest.svc/GetUserProfile');
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
							sUSER_ID          = result.d.USER_ID  ;
							sUSER_NAME        = result.d.USER_NAME;
							sFULL_NAME        = result.d.FULL_NAME;
							// 11/25/2014 Paul.  sUSER_PICTURE is used by the ChatDashboard. 
							sPICTURE          = result.d.PICTURE  ;
							sTEAM_ID          = result.d.TEAM_ID  ;
							sTEAM_NAME        = result.d.TEAM_NAME;
							sUSER_LANG        = result.d.USER_LANG;
							// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
							sUSER_THEME       = result.d.USER_THEME      ;
							sUSER_DATE_FORMAT = result.d.USER_DATE_FORMAT;
							sUSER_TIME_FORMAT = result.d.USER_TIME_FORMAT;
							sUSER_CURRENCY_ID = result.d.USER_CURRENCY_ID;
							sUSER_TIMEZONE_ID = result.d.USER_TIMEZONE_ID;
							// 12/01/2014 Paul.  Add SignalR fields. 
							// 12/09/2014 Paul.  Can't use Sql.ToString as it will not be defined for browser extensions. 
							sUSER_EXTENSION      = result.d.USER_EXTENSION     ;
							sUSER_FULL_NAME      = result.d.USER_FULL_NAME     ;
							sUSER_PHONE_WORK     = result.d.USER_PHONE_WORK    ;
							sUSER_SMS_OPT_IN     = result.d.USER_SMS_OPT_IN    ;
							sUSER_PHONE_MOBILE   = result.d.USER_PHONE_MOBILE  ;
							sUSER_TWITTER_TRACKS = result.d.USER_TWITTER_TRACKS;
							sUSER_CHAT_CHANNELS  = result.d.USER_CHAT_CHANNELS ;
							// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
							sUSER_CurrencyDecimalDigits    = result.d.USER_CurrencyDecimalDigits   ;
							sUSER_CurrencyDecimalSeparator = result.d.USER_CurrencyDecimalSeparator;
							sUSER_CurrencyGroupSeparator   = result.d.USER_CurrencyGroupSeparator  ;
							sUSER_CurrencyGroupSizes       = result.d.USER_CurrencyGroupSizes      ;
							sUSER_CurrencyNegativePattern  = result.d.USER_CurrencyNegativePattern ;
							sUSER_CurrencyPositivePattern  = result.d.USER_CurrencyPositivePattern ;
							sUSER_CurrencySymbol           = result.d.USER_CurrencySymbol          ;
							// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
							sPRIMARY_ROLE_NAME             = result.d.PRIMARY_ROLE_NAME            ;
							callback.call(context||this, 1, null);
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'GetUserProfile'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'GetUserProfile'));
	}
}

// 07/01/2017 Paul.  Cache IsAuthenticated for 1 second. 
var lastIsAuthenticated = 0;

function IsAuthenticated(callback, context)
{
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
	// 07/01/2017 Paul.  Cache IsAuthenticated for 1 second. 
	if ( lastIsAuthenticated > 0 )
	{
		var diff = new Date();
		diff.setTime(diff - lastIsAuthenticated);
		var timeElapsed = diff.getTime();
		if ( timeElapsed < 1000 )
		{
			//console.log('lastIsAuthenticated cached ' + timeElapsed);
			callback.call(context||this, 1, '');
			return;
		}
	}

	var xhr = CreateSplendidRequest('Rest.svc/IsAuthenticated');
	// 12/21/2014 Paul.  Use 2 second timeout for IsAuthenticated. 
	// 07/03/2017 Paul.  We must specify timeout function otherwise we get an uncaught canceled event. Increase to 8 seconds. 
	xhr.timeout = 8000;
	xhr.ontimeout = function (e)
	{
		callback.call(context||this, -1, 'IsAuthenticated timeout');
	};
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
							if ( result.d == true )
							{
								// 07/01/2017 Paul.  Cache IsAuthenticated for 1 second. 
								lastIsAuthenticated = (new Date()).getTime();
								if ( sUSER_ID == '' )
								{
									// 05/07/2013 Paul.  Replace GetUserID and GetUserLanguage with GetUserProfile. 
									GetUserProfile(function(status, message)
									{
										if ( status == 1 )
										{
											// 11/28/2011 Paul.  Reset after getting the language. 
											// We are noticing a CONFIG is null error when transitioning from offline to online. 
											SplendidCache.Reset();
											callback.call(context||this, 1, '');
										}
										else
										{
											lastIsAuthenticated = 0;
											callback.call(context||this, status, message);
										}
									});
								}
								else
								{
									callback.call(context||this, 1, '');
								}
							}
							else
							{
								lastIsAuthenticated = 0;
								sUSER_ID = '';
								callback.call(context||this, 0, '');
							}
						}
						else
						{
							lastIsAuthenticated = 0;
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else if ( result.status == 0 && bIS_OFFLINE )
					{
						lastIsAuthenticated = 0;
						// 09/28/2011 Paul.  Instead of returning an error, offline should return success. 
						// 12/21/2014 Paul.  Need to return failure for the mobile client. 
						if ( bMOBILE_CLIENT )
							callback.call(context||this, -1, 'Offline');
						else
							callback.call(context||this, 1, 'Offline');
					}
					else
					{
						lastIsAuthenticated = 0;
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					lastIsAuthenticated = 0;
					callback.call(context||this, -1, SplendidError.FormatError(e, 'IsAuthenticated'));
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
		lastIsAuthenticated = 0;
		//alert('IsAuthenticated: ' + e.message);
		//callback.call(this, -1, SplendidError.FormatError(e, 'IsAuthenticated'));
		// 11/28/2011 Paul.  xhr.send is throwing an exception on IE8 when working offline. 
		// The download of the specified resource has failed. 
		//callback.call(this, -1, '');
		// 03/28/2012 Paul.  We need to return a status and a message, not a result object. 
		if ( sUSER_ID === undefined || sUSER_ID == '' || sUSER_ID == null )
			callback.call(context||this, 0, '');
		else
			callback.call(context||this, 1, '');
	}
}

function Login(callback, context)
{
	// 07/01/2017 Paul.  Reset IsAuthenticated immediately upon login/logout. 
	lastIsAuthenticated = 0;
	
	if ( !ValidateCredentials() )
	{
		callback.call(context||this, -1, 'Invalid connection information.');
		return;
	}
	var xhr = CreateSplendidRequest('Rest.svc/Login');
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
							if ( result.d.length == 36 )
							{
								sUSER_ID = result.d;
								// 05/07/2013 Paul.  Replace GetUserLanguage with GetUserProfile. 
								GetUserProfile(function(status, message)
								{
									if ( status == 1 )
									{
										// 09/09/2014 Paul.  Reset after getting the language. 
										SplendidCache.Reset();
										callback.call(context||this, 1, null);
									}
									else
									{
										callback.call(context||this, status, message);
									}
								});
							}
							else
								callback.call(context||this, -1, 'Login should return Guid.');
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
					callback.call(context||this, -1, SplendidError.FormatError(e, 'Login'));
				}
			});
		}
	}
	try
	{
		// 05/02/2017 Paul.  Need a separate flag for the mobile client. 
		xhr.send('{"UserName": ' + JSON.stringify(sUSER_NAME) + ', "Password": ' + JSON.stringify(sPASSWORD) + ', "Version": "6.0", "MobileClient": ' + bMOBILE_CLIENT + '}');
	}
	catch(e)
	{
		//alert('Login: ' + e.message);
		callback.call(context||this, -1, SplendidError.FormatError(e, 'Login'));
	}
}

function AuthenticatedMethod(callback, context)
{
	if ( !ValidateCredentials() )
	{
		ShowOptionsDialog();
	}
	else
	{
		IsAuthenticated(function(status, message)
		{
			if ( status == 1 )
			{
				// 08/30/2011 Paul.  Now may be a good time to run SplendidInit. 
				// 10/04/2011 Paul.  Return the user information for the Safari Extension. 
				// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
				// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
				callback.call(context||this, 1, { 'sUSER_ID': sUSER_ID, 'sUSER_NAME': sUSER_NAME, 'sUSER_LANG': sUSER_LANG, 'sUSER_DATE_FORMAT': sUSER_DATE_FORMAT, 'sUSER_TIME_FORMAT': sUSER_TIME_FORMAT, 'sFULL_NAME': sFULL_NAME, 'sTEAM_ID': sTEAM_ID, 'sTEAM_NAME': sTEAM_NAME, 'bIS_OFFLINE': bIS_OFFLINE, 'bENABLE_OFFLINE': bENABLE_OFFLINE, 'sUSER_THEME': sUSER_THEME, 'sPASSWORD': sPASSWORD } );
			}
			else if ( status == 0 )
			{
				// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
				// 01/01/2012 paul.  Firefox is throwing an exception on sessionStorage when called within a browser extension. 
				if ( bIS_OFFLINE && window.sessionStorage && (sPASSWORD === undefined || sPASSWORD == '' || sPASSWORD == null) )
				{
					// 11/28/2011 Paul.  We need to save the user name and password so that we can re-authenticate when the connection is restored. 
					sPASSWORD         = sessionStorage['PASSWORD'        ];
					sUSER_ID          = sessionStorage['USER_ID'         ];
					sUSER_NAME        = sessionStorage['USER_NAME'       ];
					sFULL_NAME        = sessionStorage['FULL_NAME'       ];
					// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
					sPICTURE          = sessionStorage['PICTURE'         ];
					sTEAM_ID          = sessionStorage['TEAM_ID'         ];
					sTEAM_NAME        = sessionStorage['TEAM_NAME'       ];
					sUSER_LANG        = sessionStorage['USER_LANG'       ];
					// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
					sUSER_THEME       = sessionStorage['USER_THEME'      ];
					sUSER_DATE_FORMAT = sessionStorage['USER_DATE_FORMAT'];
					sUSER_TIME_FORMAT = sessionStorage['USER_TIME_FORMAT'];
					sUSER_CURRENCY_ID = sessionStorage['USER_CURRENCY_ID'];
					sUSER_TIMEZONE_ID = sessionStorage['USER_TIMEZONE_ID'];
					// 12/01/2014 Paul.  Add SignalR fields. 
					// 12/09/2014 Paul.  Can't use Sql.ToString as it will not be defined for browser extensions. 
					sUSER_EXTENSION      = sessionStorage['USER_EXTENSION'     ];
					sUSER_FULL_NAME      = sessionStorage['USER_FULL_NAME'     ];
					sUSER_PHONE_WORK     = sessionStorage['USER_PHONE_WORK'    ];
					sUSER_SMS_OPT_IN     = sessionStorage['USER_SMS_OPT_IN'    ];
					sUSER_PHONE_MOBILE   = sessionStorage['USER_PHONE_MOBILE'  ];
					sUSER_TWITTER_TRACKS = sessionStorage['USER_TWITTER_TRACKS'];
					sUSER_CHAT_CHANNELS  = sessionStorage['USER_CHAT_CHANNELS' ];
					// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
					sUSER_CurrencyDecimalDigits    = sessionStorage['USER_CurrencyDecimalDigits'   ];
					sUSER_CurrencyDecimalSeparator = sessionStorage['USER_CurrencyDecimalSeparator'];
					sUSER_CurrencyGroupSeparator   = sessionStorage['USER_CurrencyGroupSeparator'  ];
					sUSER_CurrencyGroupSizes       = sessionStorage['USER_CurrencyGroupSizes'      ];
					sUSER_CurrencyNegativePattern  = sessionStorage['USER_CurrencyNegativePattern' ];
					sUSER_CurrencyPositivePattern  = sessionStorage['USER_CurrencyPositivePattern' ];
					sUSER_CurrencySymbol           = sessionStorage['USER_CurrencySymbol'          ];
					// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
					sPRIMARY_ROLE_NAME   = sessionStorage['PRIMARY_ROLE_NAME'  ];
					callback.call(context||this, 0, 'AuthenticatedMethod(): User restored from sessionStorage.');
				}
				// 10/14/2011 Paul.  Make sure that we do not attempt to login if we do not have a password as it will eventually lock-out the user. 
				if ( sAUTHENTICATION == 'CRM' && !(sPASSWORD === undefined || sPASSWORD == '' || sPASSWORD == null) )
				{
					Login(function(status, message)
					{
						if ( status == 1 )
						{
							// 08/30/2011 Paul.  Now may be a good time to run SplendidInit. 
							// 10/04/2011 Paul.  Return the user information for the Safari Extension. 
							// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
							// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
							// 02/28/2018 Paul.  When the session times-out and we re-authenticate, we need to load config, modules and global cache. 
							Application_Config(function(status, message)
							{
								if ( status == 0 || status == 1 )
								{
									Application_Modules(function(status, message)
									{
										if ( status == 0 || status == 1 )
										{
											Application_GetAllLayouts(function(status, message)
											{
												if ( status == 0 || status == 1 )
												{
													callback.call(context||this, 1, { 'sUSER_ID': sUSER_ID, 'sUSER_NAME': sUSER_NAME, 'sUSER_LANG': sUSER_LANG, 'sUSER_DATE_FORMAT': sUSER_DATE_FORMAT, 'sUSER_TIME_FORMAT': sUSER_TIME_FORMAT, 'sFULL_NAME': sFULL_NAME, 'sTEAM_ID': sTEAM_ID, 'sTEAM_NAME': sTEAM_NAME, 'bIS_OFFLINE': bIS_OFFLINE, 'bENABLE_OFFLINE': bENABLE_OFFLINE, 'sUSER_THEME': sUSER_THEME, 'sPICTURE': sPICTURE } );
												}
												else
												{
													callback.call(context||this, status, message);
												}
											}, context||this);
										}
										else
										{
											callback.call(context||this, status, message);
										}
									}, context||this);
								}
								else
								{
									callback.call(context||this, status, message);
								}
							}, context||this);
						}
						else
						{
							callback.call(context||this, status, message);
						}
					});
				}
				else
				{
					callback.call(context||this, status, 'Failed to authenticate. Please login again. ');
				}
			}
			else
			{
				callback.call(context||this, status, message);
			}
		}, context);
	}
}

function IsOnline(callback, context)
{
	// 04/29/2017 Paul.  Automatically offline if the server is not defined. 
	if ( bMOBILE_CLIENT && Sql.IsEmptyString(sREMOTE_SERVER) )
	{
		callback.call(context||this, -1, 'Remote Server is not defined.');
		return;
	}

	var xhr = CreateSplendidRequest('Rest.svc/Version', 'POST');
	// 12/21/2014 Paul.  Use 2 second timeout for IsOnline. 
	xhr.timeout = 8000;
	// 07/03/2017 Paul.  We must specify timeout function otherwise we get an uncaught canceled event. Increase to 8 seconds. 
	xhr.ontimeout = function (e)
	{
		callback.call(context||this, -1, 'IsOnline timeout');
	};
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
							callback.call(context||this, 1, '');
						}
						else
						{
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else if ( result.status == 0 )
					{
						callback.call(context||this, 0, '');
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'IsOnline'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'IsOnline'));
	}
}

// 04/30/2017 Paul.  Add support for single-sign-on. 
function SingleSignOnSettings(callback, context)
{
	// 04/29/2017 Paul.  Automatically offline if the server is not defined. 
	if ( bMOBILE_CLIENT && Sql.IsEmptyString(sREMOTE_SERVER) )
	{
		callback.call(context||this, 0, 'Remote Server is not defined.');
		return;
	}

	var xhr = CreateSplendidRequest('Rest.svc/SingleSignOnSettings', 'GET');
	// 04/29/2017 Paul.  Use 2 second timeout for SingleSignOnSettings. 
	xhr.timeout = 8000;
	// 07/03/2017 Paul.  We must specify timeout function otherwise we get an uncaught canceled event. Increase to 8 seconds. 
	xhr.ontimeout = function (e)
	{
		callback.call(context||this, -1, 'SingleSignOnSettings timeout');
	};
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
							callback.call(context||this, 1, result.d);
						}
						else
						{
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else if ( result.status == 0 )
					{
						callback.call(context||this, 0, '');
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'IsOnline'));
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
			callback.call(context||this, -1, SplendidError.FormatError(e, 'SingleSignOnSettings'));
	}
}

