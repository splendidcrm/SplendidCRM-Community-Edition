/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

var MAX_DUMP_DEPTH = 2;

function dumpObj(obj, name, indent, depth)
{
	if ( indent == undefined )
		indent = '';
	if ( depth == undefined )
		depth = 0;
	if ( depth > MAX_DUMP_DEPTH )
	{
		return indent + name + ': <Maximum Depth Reached>\n';
	}
	if ( typeof obj == 'object' )
	{
		var child = null;
		var output = indent + name + '\n';
		indent += '\t';
		for ( var item in obj )
		{
			try
			{
				child = obj[item];
			}
			catch (e)
			{
				child = '<Unable to Evaluate>';
			}
			if ( typeof child == 'object' )
			{
				output += dumpObj(child, item, indent, depth + 1);
			}
			else
			{
				output += indent + item + ': ' + child + '\n';
			}
		}
		return output;
	}
	else
	{
		return obj;
	}
}

function Right(str, n)
{
	if ( n <= 0 )
	{
		return '';
	}
	// 06/21/2017 Paul.  If input is already a string, then don't convert. 
	else if ( typeof str == 'string') 
	{
		if ( n > str.length )
		{
			return str;
		}
		else
		{
			var iLen = str.length;
			return str.substring(iLen, iLen - n);
		}
	}
	else
	{
		if ( n > String(str).length )
		{
			return str;
		}
		else
		{
			var iLen = String(str).length;
			return String(str).substring(iLen, iLen - n);
		}
	}
}

function Left(str, n)
{
	if ( n <= 0 )
	{
		return '';
	}
	// 06/21/2017 Paul.  If input is already a string, then don't convert. 
	else if ( typeof str == 'string') 
	{
		if ( n > str.length )
			return str;
		else
		{
			return str.substring(0, n);
		}
	}
	else
	{
		if ( n > String(str).length )
			return str;
		else
		{
			return String(str).substring(0, n);
		}
	}
}

function StartsWith(str1, str2)
{
	return Left(str1, str2.length) == str2;
}

function EndsWith(str1, str2)
{
	return Right(str1, str2.length) == str2;
}

function Trim(str)
{
	return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
}

function getQuerystring(key, default_)
{
	if ( default_==null )
		default_ = '';
	key = key.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	var regex = new RegExp("[\\?&]"+key+"=([^&#]*)");
	var qs = regex.exec(window.location.href);
	if ( qs == null )
		return default_;
	else
		return qs[1];
}

function parseEmailHeaders(msg)
{
	var arrHeaders = new Array();
	try
	{
		// 10/26/2014 Paul.  We need a better split as the header might be CRLF or just LF. 
		// https://www.andrewzammit.com/blog/node-js-splitcount-number-of-lines-unicode-compatible/
		var lines = msg.split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
		var sLastFieldName = null;
		for ( var i = 0; i < lines.length; i++ )
		{
			var line = lines[i];
			if ( line.length == 0 )
			{
				break;
			}
			else if ( line.charAt(0) != ' ' )
			{
				var nFieldEnd   = line.indexOf(': ');
				if ( nFieldEnd > 0 )
				{
					var sFieldName  = line.substring(0, nFieldEnd);
					var sFieldValue = line.substring(nFieldEnd + 2);
					arrHeaders[sFieldName] = sFieldValue;
					sLastFieldName = sFieldName;
				}
			}
			else if ( sLastFieldName != null )
			{
				arrHeaders[sLastFieldName] += '\n' + line;
			}
		}
	}
	catch(e)
	{
	}
	return arrHeaders;
}

function geteEmailHeaders(msg)
{
	var sHeaders = '';
	try
	{
		// 10/26/2014 Paul.  We need a better split as the header might be CRLF or just LF. 
		// https://www.andrewzammit.com/blog/node-js-splitcount-number-of-lines-unicode-compatible/
		var lines = msg.split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
		var sLastFieldName = null;
		for ( var i = 0; i < lines.length; i++ )
		{
			var line = lines[i];
			if ( line.length == 0 )
			{
				break;
			}
			sHeaders += line + '\n';
		}
		sHeaders += '\n';
	}
	catch(e)
	{
	}
	return sHeaders;
}

// http://www.ejball.com/EdAtWork/2005/03/31/JavaScriptBindingFunctionArguments.aspx
function BindArguments(fn)
{
	var args = [];
	for ( var n = 1; n < arguments.length; n++ )
		args.push(arguments[n]);
	return function () { return fn.apply(this, args); };
}

function RegisterEnterKeyPress(e, sSubmitID)
{
	if ( e != null )
	{
		if ( e.which == 13 )
		{
			// 04/16/2017 Paul.  Parameter can be a function. 
			if ( $.isFunction(sSubmitID) )
			{
				sSubmitID();
			}
			else
			{
				var btnSubmit = document.getElementById(sSubmitID);
				if ( btnSubmit != null )
					btnSubmit.click();
			}
			return false;
		}
	}
	else if ( event != null )
	{
		if ( event.keyCode == 13 )
		{
			event.returnValue = false;
			event.cancel = true;
			// 04/16/2017 Paul.  Parameter can be a function. 
			if ( $.isFunction(sSubmitID) )
			{
				sSubmitID();
			}
			else
			{
				var btnSubmit = document.getElementById(sSubmitID);
				if ( btnSubmit != null )
					btnSubmit.click();
			}
		}
	}
}

function checkAll(sFieldID, value)
{
	var fld = document.getElementsByName(sFieldID);
	for (var i = 0; i < fld.length; i++)
	{
		if ( fld[i].type == 'checkbox' )
			fld[i].checked = value;
	}
}

// 02/27/2012 Paul.  Collapsible sub-panels need cookie access. 
function setCookie(name, value, days)
{
	var expires = '';
	if ( days )
	{
		var date = new Date();
		date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
		expires = '; expires=' + date.toGMTString();
	}
	document.cookie = name + '=' + value + expires + '; path=/';
}

function getCookie(name)
{
	var nameEQ = name + '=';
	var ca = document.cookie.split(';');
	for ( var i = 0; i < ca.length; i++ )
	{
		var c = ca[i];
		while ( c.charAt(0) == ' ' )
			c = c.substring(1,c.length);
		if ( c.indexOf(nameEQ) == 0 )
			return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function deleteCookie(name)
{
	setCookie(name, '', -1);
}

// 03/10/2013 Paul.  OnClick is now supported for checkboxes, so we need to support toggleDisplay as well. 
function toggleDisplay(sID)
{
	// 03/10/2013 Paul.  We cannot just toggle the reminder because the checkbox may not have been set properly. Code the logic manually. 
	// 04/24/2018 Paul.  Assignment was being used. 
	if ( sID == 'REMINDER_TIME' )
	{
		var fldREMINDER_TIME = document.getElementById('divMainLayoutPanel_ctlEditView_' + sID);
		var fldSHOULD_REMIND = document.getElementById('divMainLayoutPanel_ctlEditView_SHOULD_REMIND');
		if ( fldREMINDER_TIME != null && fldSHOULD_REMIND != null )
			fldREMINDER_TIME.style.display = fldSHOULD_REMIND.checked ? 'inline' : 'none';
	}
	else
	{
		var fld = document.getElementById(sID);
		if ( fld != null )
			fld.style.display = (fld.style.display == 'none') ? 'inline' : 'none';
	}
}

// 03/10/2013 Paul. Add ALL_DAY_EVENT. 
function ToggleAllDayEvent(chk)
{
	var sBaseID = chk.id.replace('ALL_DAY_EVENT', '');
	var txtDATE_START       = document.getElementById(sBaseID + 'DATE_START'            );
	var lstHOUR             = document.getElementById(sBaseID + 'DATE_START_lstHOUR'    );
	var lstMINUTE           = document.getElementById(sBaseID + 'DATE_START_lstMINUTE'  );
	var lstMERIDIEM         = document.getElementById(sBaseID + 'DATE_START_lstMERIDIEM');
	var fldDURATION_HOURS   = document.getElementById(sBaseID + 'DURATION_HOURS'        );
	var fldDURATION_MINUTES = document.getElementById(sBaseID + 'DURATION_MINUTES'      );
	if ( chk.checked )
	{
		if ( lstHOUR             != null ) lstHOUR            .selectedIndex = 0;
		if ( lstMINUTE           != null ) lstMINUTE          .selectedIndex = 0;
		if ( lstMERIDIEM         != null ) lstMERIDIEM        .selectedIndex = 0;
		if ( fldDURATION_MINUTES != null ) fldDURATION_MINUTES.selectedIndex = 0;
		if ( fldDURATION_HOURS   != null ) fldDURATION_HOURS  .value = 24;
		if ( txtDATE_START       != null && lstHOUR == null && lstMINUTE == null && lstMERIDIEM == null )
		{
			try
			{
				var dtVALUE = $('#' + txtDATE_START.id).datepicker('getDate');
				if ( dtVALUE == null )
					dtVALUE = new Date();
				var sValue = ToJsonDate(dtVALUE);
				txtDATE_START.value = FromJsonDate(sValue, Security.USER_DATE_FORMAT());
			}
			catch(e)
			{
				alert('Error parsing date: ' + e.message);
			}
		}
	}
}

// https://gist.github.com/jonleighton/958841
// Converts an ArrayBuffer directly to base64, without any intermediate 'convert to string then
// use window.btoa' step. According to my tests, this appears to be a faster approach:
// http://jsperf.com/encoding-xhr-image-data/5

function base64ArrayBuffer(arrayBuffer)
{
	var base64    = ''
	var encodings = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

	var bytes         = new Uint8Array(arrayBuffer)
	var byteLength    = bytes.byteLength
	var byteRemainder = byteLength % 3
	var mainLength    = byteLength - byteRemainder

	var a, b, c, d
	var chunk

	// Main loop deals with bytes in chunks of 3
	for (var i = 0; i < mainLength; i = i + 3) {
	// Combine the three bytes into a single integer
	chunk = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]

	// Use bitmasks to extract 6-bit segments from the triplet
	a = (chunk & 16515072) >> 18 // 16515072 = (2^6 - 1) << 18
	b = (chunk & 258048)   >> 12 // 258048   = (2^6 - 1) << 12
	c = (chunk & 4032)     >>  6 // 4032     = (2^6 - 1) << 6
	d = chunk & 63               // 63       = 2^6 - 1

	// Convert the raw binary segments to the appropriate ASCII encoding
	base64 += encodings[a] + encodings[b] + encodings[c] + encodings[d]
	}

	// Deal with the remaining bytes and padding
	if (byteRemainder == 1) {
	chunk = bytes[mainLength]

	a = (chunk & 252) >> 2 // 252 = (2^6 - 1) << 2

	// Set the 4 least significant bits to zero
	b = (chunk & 3)   << 4 // 3   = 2^2 - 1

	base64 += encodings[a] + encodings[b] + '=='
	} else if (byteRemainder == 2) {
	chunk = (bytes[mainLength] << 8) | bytes[mainLength + 1]

	a = (chunk & 64512) >> 10 // 64512 = (2^6 - 1) << 10
	b = (chunk & 1008)  >>  4 // 1008  = (2^6 - 1) << 4

	// Set the 2 least significant bits to zero
	c = (chunk & 15)    <<  2 // 15    = 2^4 - 1

	base64 += encodings[a] + encodings[b] + encodings[c] + '='
	}

	return base64
}

function isMobileDevice()
{
	// 04/18/2017 Paul.  Use Bootstrap for responsive design.  Instead of mobile layouts. 
	if ( SplendidDynamic.BootstrapLayout() )
		return false;

	var iPhone  = /iPhone/i.test(navigator.userAgent);
	var iPad    = /iPad/i.test(navigator.userAgent);
	var android = /android/i.test(navigator.userAgent);
	var webos   = /hpwos/i.test(navigator.userAgent);
	// 12/09/2014 Paul.  Don't use Sql.ToBoolean as it is not defined by this point. 
	var mobile  = false;
	var sMobile = getQuerystring('mobile');
	if ( sMobile === undefined || sMobile == null )
		mobile  = false;
	else
		mobile  = (sMobile == 'true' || sMobile == 'True' || sMobile == 'on' || sMobile == '1' || sMobile == true || sMobile == 1);
	return iPhone || iPad || android || webos || mobile;
}

function isMobileLandscape()
{
	var nWindowWidth = $(window).width();
	return (nWindowWidth >= 800);
}

// http://stackoverflow.com/questions/5251520/how-do-i-escape-some-html-in-javascript
function escapeHTML(s)
{
	return s.replace(/[&"<>]/g, function (c) {
		return {
			'&': "&amp;",
			'"': "&quot;",
			'<': "&lt;",
			'>': "&gt;"
		}[c];
	});
}

