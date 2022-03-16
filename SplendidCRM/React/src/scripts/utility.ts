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
import Credentials     from '../scripts/Credentials'    ;
import SplendidDynamic from '../scripts/SplendidDynamic';
import SplendidCache   from '../scripts/SplendidCache'  ;

let MAX_DUMP_DEPTH: number = 6;

export function dumpObj(obj, name?: string, indent?: string, depth?: number)
{
	if ( indent == undefined )
	{
		indent = '';
	}
	if ( depth == undefined )
	{
		depth = 0;
	}
	if ( depth > MAX_DUMP_DEPTH )
	{
		return indent + name + ': <Maximum Depth Reached>\n';
	}
	if ( typeof(obj) == 'object' )
	{
		let child = null;
		let output = indent + name + '\n';
		indent += '\t';
		for ( let item in obj )
		{
			try
			{
				child = obj[item];
			}
			catch(error)
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

export function Right(str: string, n: number)
{
	if ( n <= 0 )
	{
		return '';
	}
	// 06/21/2017 Paul.  If input is already a string, then don't convert. 
	else if ( typeof(str) == 'string' )
	{
		if ( n > str.length )
		{
			return str;
		}
		else
		{
			let iLen = str.length;
			return str.substring(iLen, iLen - n);
		}
	}
	else
	{
		if (n > String(str).length)
		{
			return str;
		}
		else
		{
			let iLen = String(str).length;
			return String(str).substring(iLen, iLen - n);
		}
	}
}

export function Left(str: string, n: number)
{
	if ( n <= 0 )
	{
		return '';
	}
	// 06/21/2017 Paul.  If input is already a string, then don't convert. 
	else if ( typeof(str) == 'string')
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

export function StartsWith(str1: string, str2: string)
{
	return Left(str1, str2.length) == str2;
}

export function EndsWith(str1: string, str2: string)
{
	return Right(str1, str2.length) == str2;
}

export function Trim(str: string)
{
	return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
}

export function getQuerystring(key, default_?)
{
	if ( default_ == null )
	{
		default_ = '';
	}
	key = key.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
	let regex = new RegExp("[\\?&]" + key + "=([^&#]*)");
	let qs = regex.exec(window.location.href);
	if ( qs == null )
	{
		return default_;
	}
	else
	{
		return qs[1];
	}
}

/*
export function parseEmailHeaders(msg)
{
	let arrHeaders = new Array();
	try
	{
		// 10/26/2014 Paul.  We need a better split as the header might be CRLF or just LF. 
		// https://www.andrewzammit.com/blog/node-js-splitcount-number-of-lines-unicode-compatible/
		let lines = msg.split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
		let sLastFieldName = null;
		for ( let i = 0; i < lines.length; i++ )
		{
			let line = lines[i];
			if ( line.length == 0 )
			{
				break;
			}
			else if ( line.charAt(0) != ' ' )
			{
				let nFieldEnd   = line.indexOf(': ');
				if ( nFieldEnd > 0 )
				{
					let sFieldName  = line.substring(0, nFieldEnd);
					let sFieldValue = line.substring(nFieldEnd + 2);
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
	catch(error)
	{
	}
	return arrHeaders;
}

export function geteEmailHeaders(msg)
{
	let sHeaders = '';
	try
	{
		// 10/26/2014 Paul.  We need a better split as the header might be CRLF or just LF. 
		// https://www.andrewzammit.com/blog/node-js-splitcount-number-of-lines-unicode-compatible/
		let lines = msg.split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
		let sLastFieldName = null;
		for ( let i = 0; i < lines.length; i++ )
		{
			let line = lines[i];
			if ( line.length == 0 )
			{
				break;
			}
			sHeaders += line + '\n';
		}
		sHeaders += '\n';
	}
	catch(error)
	{
	}
	return sHeaders;
}

// 03/10/2013 Paul. Add ALL_DAY_EVENT. 
export function ToggleAllDayEvent(chk)
{
	let sBaseID = chk.id.replace('ALL_DAY_EVENT', '');
	let txtDATE_START       = document.getElementById(sBaseID + 'DATE_START'            );
	let lstHOUR             = document.getElementById(sBaseID + 'DATE_START_lstHOUR'    );
	let lstMINUTE           = document.getElementById(sBaseID + 'DATE_START_lstMINUTE'  );
	let lstMERIDIEM         = document.getElementById(sBaseID + 'DATE_START_lstMERIDIEM');
	let fldDURATION_HOURS   = document.getElementById(sBaseID + 'DURATION_HOURS'        );
	let fldDURATION_MINUTES = document.getElementById(sBaseID + 'DURATION_MINUTES'      );
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
				let dtVALUE = $('#' + txtDATE_START.id).datepicker('getDate');
				if ( dtVALUE == null )
					dtVALUE = new Date();
				let sValue = ToJsonDate(dtVALUE);
				txtDATE_START.value = FromJsonDate(sValue, Security.USER_DATE_FORMAT());
			}
			catch(error)
			{
				alert('Error parsing date: ' + error.message);
			}
		}
	}
}
*/

// https://gist.github.com/jonleighton/958841
// Converts an ArrayBuffer directly to base64, without any intermediate 'convert to string then
// use window.btoa' step. According to my tests, this appears to be a faster approach:
// http://jsperf.com/encoding-xhr-image-data/5

export function base64ArrayBuffer(arrayBuffer)
{
	let base64    = '';
	let encodings = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

	let bytes         = new Uint8Array(arrayBuffer);
	let byteLength    = bytes.byteLength;
	let byteRemainder = byteLength % 3;
	let mainLength    = byteLength - byteRemainder;

	let a, b, c, d;
	let chunk;

	// Main loop deals with bytes in chunks of 3
	for ( let i = 0; i < mainLength; i = i + 3 )
	{
		// Combine the three bytes into a single integer
		chunk = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2];

		// Use bitmasks to extract 6-bit segments from the triplet
		a = (chunk & 16515072) >> 18;  // 16515072 = (2^6 - 1) << 18
		b = (chunk & 258048)   >> 12;  // 258048   = (2^6 - 1) << 12
		c = (chunk & 4032)     >>  6;  // 4032     = (2^6 - 1) << 6
		d = chunk & 63              ;  // 63       = 2^6 - 1

		// Convert the raw binary segments to the appropriate ASCII encoding
		base64 += encodings[a] + encodings[b] + encodings[c] + encodings[d];
	}

	// Deal with the remaining bytes and padding
	if ( byteRemainder == 1 )
	{
		chunk = bytes[mainLength];

		a = (chunk & 252) >> 2;  // 252 = (2^6 - 1) << 2

		// Set the 4 least significant bits to zero
		b = (chunk & 3)   << 4;  // 3   = 2^2 - 1

		base64 += encodings[a] + encodings[b] + '==';
	}
	else if ( byteRemainder == 2 )
	{
		chunk = (bytes[mainLength] << 8) | bytes[mainLength + 1];

		a = (chunk & 64512) >> 10;  // 64512 = (2^6 - 1) << 10
		b = (chunk & 1008)  >>  4;  // 1008  = (2^6 - 1) << 4

		// Set the 2 least significant bits to zero
		c = (chunk & 15)    <<  2;  // 15    = 2^4 - 1

		base64 += encodings[a] + encodings[b] + encodings[c] + '=';
	}
	return base64;
}

export function isMobileDevice()
{
	// 04/18/2017 Paul.  Use Bootstrap for responsive design.  Instead of mobile layouts. 
	if (SplendidDynamic.BootstrapLayout())
		return false;

	let iPhone  = /iPhone/i.test(navigator.userAgent);
	let iPad    = /iPad/i.test(navigator.userAgent);
	// 04/21/2021 Paul.  Android is upper case. 
	let android = /Android/i.test(navigator.userAgent);
	let webos   = /hpwos/i.test(navigator.userAgent);
	// 12/09/2014 Paul.  Don't use Sql.ToBoolean as it is not defined by this point. 
	let mobile = false;
	let sMobile = getQuerystring('mobile');
	if ( sMobile === undefined || sMobile == null )
	{
		mobile = false;
	}
	else
	{
		mobile = (sMobile == 'true' || sMobile == 'True' || sMobile == 'on' || sMobile == '1' || sMobile == true || sMobile == 1);
	}
	return iPhone || iPad || android || webos || mobile;
}

export function isMobileLandscape()
{
	// 05/14/2018 Paul.  We are not using jQuery with react. 
	let nWindowWidth = window.innerWidth;
	return (nWindowWidth >= 800);
}

export function screenWidth()
{
	let width : number = (window.innerWidth  || document.documentElement.clientWidth  || document.body.clientWidth );
	// 04/21/2021 Paul.  On a mobile device (be it phone or tablet), use the screen size as apps are full screen. 
	// We don't use the client or window sizes ase they can be scaled by the browser. 
	if ( isMobileDevice() )
	{
		width = screen.width;
	}
	return width;
}

export function screenHeight()
{
	let height: number = (window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight);
	// 04/21/2021 Paul.  On a mobile device (be it phone or tablet), use the screen size as apps are full screen. 
	// We don't use the client or window sizes ase they can be scaled by the browser. 
	if ( isMobileDevice() )
	{
		height = screen.height;
	}
	return height;
}

// http://stackoverflow.com/questions/5251520/how-do-i-escape-some-html-in-javascript
export function escapeHTML(s)
{
	return s.replace(/[&"<>]/g, function (c)
	{
		return {
			'&': "&amp;",
			'"': "&quot;",
			'<': "&lt;",
			'>': "&gt;"
		}[c];
	});
}

// https://blog.garstasio.com/you-dont-need-jquery/utils/
export function inArray(valToFind, array)
{
	let foundIndex = -1;
	for (let index = 0; index < array.length; index++)
	{
		if (array[index] === valToFind)
		{
			foundIndex = index;
			break;
		}
	}
	return foundIndex;
}
const CHARS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');

export function uuidFast()
{
	let chars = CHARS, uuid = new Array(36), rnd = 0, r;
	for ( let i = 0; i < 36; i++ )
	{
		if ( i == 8 || i == 13 || i == 18 || i == 23 )
		{
			uuid[i] = '-';
		}
		else if (i == 14)
		{
			uuid[i] = '4';
		}
		else
		{
			if ( rnd <= 0x02 )
			{
				rnd = 0x2000000 + (Math.random() * 0x1000000) | 0;
			}
			r = rnd & 0xf;
			rnd = rnd >> 4;
			uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
		}
	}
	return uuid.join('');
}

export function ValidateDateParts(value: string, DATE_FORMAT: string): boolean
{
	let nValidDateParts: number = 0;
	let arrValue       : string[] = [];
	let arrDATE_FORMAT : string[] = [];
	if ( DATE_FORMAT )
	{
		if ( DATE_FORMAT.indexOf('/') >= 0 )
		{
			arrValue = value.split('/');
			arrDATE_FORMAT = DATE_FORMAT.toUpperCase().slice().split('/');
		}
		else if ( DATE_FORMAT.indexOf('-') >= 0 )
		{
			arrValue = value.split('-');
			arrDATE_FORMAT = DATE_FORMAT.toUpperCase().slice().split('-');
		}
		if ( arrValue.length == 3 )
		{
			for ( let i = 0; i < arrDATE_FORMAT.length; i++ )
			{
				if ( arrDATE_FORMAT[i].indexOf('M') >= 0 )
				{
					let month = parseInt(arrValue[i]);
					if ( month >= 1 && month <= 12 )
					{
						nValidDateParts++;
					}
				}
				else if ( arrDATE_FORMAT[i].indexOf('D') >= 0 )
				{
					let day = parseInt(arrValue[i]);
					// 08/06/2019 Paul.  We will let the moment library finish the validation of the day of the month. 
					if ( day >= 1 && day <= 31 )
					{
						nValidDateParts++;
					}
				}
				else if ( arrDATE_FORMAT[i].indexOf('Y') >= 0 )
				{
					let year = parseInt(arrValue[i]);
					if ( year >= 1900 && year <= 2100 )
					{
						nValidDateParts++;
					}
				}
			}
		}
	}
	return nValidDateParts == 3;
}

export function ActiveModuleFromPath(pathname: string, sCaller?: string)
{
	let activeModule: string = '';
	let arrPathParts: string[] = pathname.split('/');
	if ( arrPathParts.length > 1 )
	{
		activeModule = arrPathParts[1];
		if ( activeModule == 'Reset' )
		{
			activeModule = '';
			arrPathParts.shift();
			if ( arrPathParts.length > 1 )
			{
				activeModule = arrPathParts[1];
			}
		}
		if ( activeModule == 'Reload' )
		{
			activeModule = '';
			arrPathParts.shift();
			if ( arrPathParts.length > 1 )
			{
				activeModule = arrPathParts[1];
			}
		}
		if ( activeModule == 'Administration' )
		{
			// 01/23/2021 Paul.  Show Administration tab when sitting on admin apge. 
			if ( arrPathParts.length > 2 )
			{
				if ( arrPathParts[2] != '' )
				{
					activeModule = arrPathParts[2];
					// 08/28/2021 Paul.  Azure has sub-modules. 
					if ( activeModule == 'Azure' )
					{
						if ( arrPathParts.length > 3 )
						{
							if ( arrPathParts[3] != '' )
							{
								activeModule = arrPathParts[3];
							}
						}
					}
				}
			}
		}
		// 09/17/2019 Paul.  Some entries are know non-modules. 
		if ( activeModule == 'UnifiedSearch' )
		{
			activeModule = '';
		}
		// 09/17/2019 Paul.  Calendar correction. 
		else if ( activeModule == 'BigCalendar' )
		{
			activeModule = 'Calendar';
		}
		else if ( !SplendidCache.Module(activeModule, sCaller + ' ActiveModuleFromPath') )
		{
			activeModule = '';
		}
	}
	return activeModule;
}

export function isTablet()
{
	let userAgent = navigator.userAgent;
	// 12/11/2018 Paul.  All ipads are tablets. 
	let iPad = /iPad/i.test(userAgent);
	// 11/24/2019 Paul. 
	// https://stackoverflow.com/questions/16541676/what-are-best-practices-for-detecting-pixel-ratio-density
	let devicePixelRatio = window.devicePixelRatio || 1;
	if ( iPad )
	{
		return true;
	}
	else if ( devicePixelRatio < 2 && (screen.width >= 1000 || screen.height >= 1000) )
	{
		return true;
	}
	else if ( devicePixelRatio >= 2 && (screen.width >= 1280 || screen.height >= 1280) )
	{
		return true;
	}
	return false;
}

// http://weblogs.asp.net/bleroy/archive/2008/01/18/dates-and-json.aspx
export function ToJsonDate(dt): string
{
	let sDATA_VALUE: string = null;
	// 01/19/2013 Paul.  During testing, dt was not a valid date and threw an exception on getTimezoneOffset.  
	if ( !isNaN(dt) && Object.prototype.toString.call(dt) === '[object Date]' )
	{
		// 02/21/2013 Paul.  First clone the date before modifying. 
		let temp = new Date(dt.getTime());
		let off = temp.getTimezoneOffset();
		temp.setMinutes(temp.getMinutes() - off);
		// http://www.w3schools.com/jsref/jsref_obj_date.asp
		sDATA_VALUE = '\\/Date(' + temp.getTime() + ')\\/';
	}
	return sDATA_VALUE;
}

export function UpdateApplicationTheme()
{
	try
	{
		let arrThemeStyles: string[] = [];
		let arrLinks = document.getElementsByTagName('link');
		// 08/20/2020 Paul.  The styles need to be manually added to the mobile client. 
		if ( Credentials.bMOBILE_CLIENT )
		{
			let sThemeUrl: string = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
			arrThemeStyles.push(sThemeUrl + 'ChatDashboard.css'      );
			arrThemeStyles.push(sThemeUrl + 'style.css'              );
			arrThemeStyles.push(sThemeUrl + 'styleActivityStream.css');
			arrThemeStyles.push(sThemeUrl + 'styleModuleHeader.css'  );
			arrThemeStyles.push(sThemeUrl + 'twitter.css'            );
		}
		else
		{
			for ( let i = 0; i < arrLinks.length; i++ )
			{
				let sLink: string = arrLinks[i].href;
				if ( sLink.indexOf('/App_Themes/') >= 0 )
				{
					let arrLinkParts: string[] = sLink.split('/');
					if ( arrLinkParts.length >= 3 && arrLinkParts[arrLinkParts.length - 3] == 'App_Themes' )
					{
						arrLinkParts[arrLinkParts.length - 2] = SplendidCache.UserTheme;
						//arrLinks[i].href = arrLinkParts.join('/');
						arrThemeStyles.push(arrLinkParts.join('/'));
					}
				}
			}
		}
		// 09/14/2019 Paul.  Remove in a separate loop. 
		for ( let i = arrLinks.length - 1; i >= 0 ; i-- )
		{
			// 11/02/2020 Paul.  Only remove stylesheet links, not shortcut icon. 
			if ( arrLinks[i].rel == 'stylesheet' )
			{
				//console.log('Removing link', arrLinks[i]);
				arrLinks[i].parentNode.removeChild(arrLinks[i]);
			}
		}
		// 09/14/2019 Paul.  We need to move the styles to the end of the file so that the supercede the bootstrap styles. 
		for ( let i = 0; i < arrThemeStyles.length; i++ )
		{
			let link = document.createElement('link');
			link.href = arrThemeStyles[i];
			link.rel  = 'stylesheet';
			link.type = 'text/css';
			document.head.appendChild(link);
		}
	}
	catch(error)
	{
		console.error((new Date()).toISOString() + ' ' + 'UpdateApplicationTheme', error);
	}
}

export function isEmptyObject(obj)
{
	return Object.getOwnPropertyNames(obj).length === 0;
}

// https://github.com/airbnb/is-touch-device/blob/master/src/index.js
// https://www.labnol.org/code/19616-detect-touch-screen-javascript
export function isTouchDevice()
{
	// 02/20/2022 Paul.  msMaxTouchPoints is no longer supported, so remove. 
  return (
    !!(typeof window !== 'undefined' &&
      ('ontouchstart' in window || (window.DocumentTouch && typeof document !== 'undefined' && document instanceof window.DocumentTouch))) ||
    !!(typeof navigator !== 'undefined' && (navigator.maxTouchPoints))
  );
}

// 09/05/2021 Paul.  BusinessProcesses needs old style binding. 
// https://www.damirscorner.com/blog/posts/20180216-VariableNumberOfArgumentsInTypescript.html
export function BindArguments( fn: any, ...args: any[] )
{
	return function () { return fn.apply( this, args ); };
}

