/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

var SplendidError = new Object();
SplendidError.divAlert    = null;
SplendidError.bDebug      = true;
SplendidError.arrErrorLog = new Array();
SplendidError.sLastError  = '';

SplendidError.ClearAllErrors = function()
{
	SplendidError.arrErrorLog = new Array();
	SplendidError.sLastError  = '';
}

SplendidError.ClearError = function()
{
	if ( ctlActiveMenu != null && ctlActiveMenu.divError() != null )
	{
		// 04/20/2017 Paul.  Use method to get error 
		var lblError = ctlActiveMenu.divError();
		if ( lblError != null )
		{
			while ( lblError.childNodes.length > 0 )
			{
				lblError.removeChild(lblError.firstChild);
			}
		}
	}
}

SplendidError.ClearAlert = function()
{
	if ( SplendidError.divAlert != null )
	{
		while ( SplendidError.divAlert.childNodes.length > 0 )
		{
			SplendidError.divAlert.removeChild(SplendidError.divAlert.firstChild);
		}
	}
}

SplendidError.SystemError = function(e, method)
{
	var message = SplendidError.FormatError(e, method);
	SplendidError.arrErrorLog.push(message);
	if ( ctlActiveMenu != null && ctlActiveMenu.divError() != null )
	{
		//ctlActiveMenu.divError.innerHTML = message;
		SplendidError.ClearError();
		// 04/20/2017 Paul.  Use method to get error 
		var lblError = ctlActiveMenu.divError();
		if ( lblError != null )
			lblError.appendChild(document.createTextNode(message));
	}
	SplendidError.sLastError = message;
}

// 08/23/2014 Paul.  A status message does not add to the error log. 
SplendidError.SystemStatus = function(message)
{
	if ( ctlActiveMenu != null && ctlActiveMenu.divError() != null )
	{
		var lblError = document.getElementById('lblError');
		// 04/20/2017 Paul.  Use method to get error 
		var lblError = ctlActiveMenu.divError();
		if ( lblError != null )
		{
			while ( lblError.childNodes.length > 0 )
			{
				lblError.removeChild(lblError.firstChild);
			}
			lblError.appendChild(document.createTextNode(message));
		}
	}
}

SplendidError.SystemMessage = function(message)
{
	//if ( message != null )
	{
		if ( message != null && message != '' )
		{
			// 06/27/2017 Paul.  Prepend timestamp. 
			SplendidError.arrErrorLog.push(formatDate((new Date()), 'yyyy/MM/dd HH:mm:ss') + ' ' + message);
			// 06/27/2017 Paul.  Dynamically update the popup. 
			var divSystemLog = document.getElementById('divSystemLog');
			if ( divSystemLog != null )
			{
				divSystemLog.innerHTML = '<table border=0 cellpadding=2 cellspacing=0><tr><td>' + SplendidError.arrErrorLog.join('</td></tr><tr><td>\n') + '</td></tr></table>';
			}

		}
		if ( ctlActiveMenu != null && ctlActiveMenu.divError() != null )
		{
			//ctlActiveMenu.divError.innerHTML = message;
			SplendidError.ClearError();
			// 04/20/2017 Paul.  Use method to get error 
			var lblError = ctlActiveMenu.divError();
			if ( lblError != null )
				lblError.appendChild(document.createTextNode(message));
		}
	}
	SplendidError.sLastError = message;
}

SplendidError.SystemLog = function(message)
{
	if ( message != null && message != '' )
	{
		SplendidError.arrErrorLog.push(formatDate((new Date()), 'yyyy/MM/dd HH:mm:ss') + ' ' + message);
	}
}

SplendidError.SystemDebug = function(message)
{
	//if ( message != null )
	{
		if ( message != null && message != '' )
		{
			SplendidError.arrErrorLog.push(message);
		}
		if ( ctlActiveMenu != null && ctlActiveMenu.divError() != null && bDebug )
		{
			//ctlActiveMenu.divError.innerHTML = message;
			SplendidError.ClearError();
			// 04/20/2017 Paul.  Use method to get error 
			var lblError = ctlActiveMenu.divError();
			if ( lblError != null )
				lblError.appendChild(document.createTextNode(message));
		}
	}
	SplendidError.sLastError = message;
}

SplendidError.SystemAlert = function(e, method)
{
	var message = SplendidError.FormatError(e, method);
	SplendidError.arrErrorLog.push(message);
	alert(message);
}

SplendidError.FormatError = function(e, method)
{
	return e.message + '<br>\n' + dumpObj(e, method);
}

SplendidError.DebugSQL = function(sSQL)
{
	if ( Crm.Config.ToBoolean('show_sql') )
	{
		var divDebugSQL = document.getElementById('divDebugSQL');
		if ( divDebugSQL != null )
		{
			// 12/31/2014 Paul.  Firefox does not like innerText. Use createTextNode. 
			while ( divDebugSQL.childNodes.length > 0 )
				divDebugSQL.removeChild(divDebugSQL.firstChild);
			divDebugSQL.appendChild(document.createTextNode(sSQL));
		}
	}
}

