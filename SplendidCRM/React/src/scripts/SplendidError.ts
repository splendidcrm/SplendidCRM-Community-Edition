/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import { dumpObj } from '../scripts/utility';
import { formatDate } from '../scripts/Formatting';

export class SplendidErrorStore
{
	arrErrorLog = new Array();
	sLastError = '';

	public ClearAllErrors()
	{
		this.arrErrorLog = new Array();
		this.sLastError = '';
	}

	public SystemError(e, method)
	{
		let message = this.FormatError(e, method);
		this.arrErrorLog.push(message);
		this.sLastError = message;
	}

	public SystemMessage(message)
	{
		if ( message != null && message != '' )
		{
			// 06/27/2017 Paul.  Prepend timestamp. 
			this.arrErrorLog.push(formatDate((new Date()), 'YYYY/MM/DD HH:mm:ss') + ' ' + message);
		}
		this.sLastError = message;
	}

	public SystemLog(message)
	{
		if (message != null && message != '')
		{
			this.arrErrorLog.push(formatDate((new Date()), 'YYYY/MM/DD HH:mm:ss') + ' ' + message);
		}
	}

	public SystemAlert(e, method)
	{
		let message = this.FormatError(e, method);
		this.arrErrorLog.push(message);
		alert(message);
	}

	public FormatError(e, method)
	{
		if ( typeof(e) == 'object' )
		{
			return method + ': ' + e.message + '<br>\n' + dumpObj(e, method);
		}
		else if ( typeof(e) == 'string' )
		{
			return method + ': ' + e + '<br>\n' + dumpObj(e, method);
		}
		else if ( typeof(e) != null )
		{
			return method + ': ' + e.toString() + '<br>\n' + dumpObj(e, method);
		}
		else
		{
			return method + ': ' + 'Unknown error' + '<br>\n' + dumpObj(e, method);
		}
	}
}

const splendidErrors = new SplendidErrorStore();
export default splendidErrors;
