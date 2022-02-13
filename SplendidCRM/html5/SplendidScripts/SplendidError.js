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
SplendidError.bDebug = true;

SplendidError.SystemError = function(e, method)
{
	var message = this.FormatError(e, method);
}

SplendidError.SystemMessage = function(message)
{
}

SplendidError.SystemLog = function(message)
{
}

SplendidError.SystemAlert = function(e, method)
{
	alert(this.FormatError(e, method));
}

SplendidError.FormatError = function(e, method)
{
	return e.message + '\n<br>' + dumpObj(e, method);
}

