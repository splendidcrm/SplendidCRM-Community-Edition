/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

var Sql = new Object();

Sql.ToString = function(o)
{
	if ( o === undefined || o == null )
		return '';
	return o;
}

// 02/29/2016 Paul.  Order management requires decimals. 
Sql.ToDecimal = function(n)
{
	if ( n === undefined || n == null || n == '' )
		return 0.0;
	n = parseFloat(n);
	if ( isNaN(n) )
		return 0.0;
	return n;
}

Sql.ToFloat = function(n)
{
	if ( n === undefined || n == null || n == '' )
		return 0.0;
	n = parseFloat(n);
	if ( isNaN(n) )
		return 0.0;
	return n;
}

Sql.ToDouble = function(n)
{
	if ( n === undefined || n == null || n == '' )
		return 0.0;
	n = parseFloat(n);
	if ( isNaN(n) )
		return 0.0;
	return n;
}

Sql.ToInteger = function(n)
{
	// 04/25/2013 Paul.  ToInteger should not return NaN for an empty string. 
	if ( n === undefined || n == null || n == '' )
		return 0;
	n = parseInt(n);
	if ( isNaN(n) )
		return 0;
	return n;
}

Sql.IsInteger = function(n)
{
	if ( n === undefined || n == null || n == '' )
		return false;
	n = parseInt(n);
	return !isNaN(n);
}

Sql.ToFloat = function(f)
{
	if ( f === undefined || f == null || f == '' )
		return 0;
	f = parseFloat(f);
	if ( isNaN(f) )
		return 0.0;
	return f;
}

Sql.IsFloat = function(f)
{
	if ( f === undefined || f == null || f == '' )
		return false;
	f = parseFloat(f);
	return !isNaN(f);
}

Sql.ToDateTime = function(sDate)
{
	// 08/21/2018 Paul.  JavaScript counts months from 0 to 11. 
	if ( sDate === undefined || sDate == null || sDate == '' )
		return new Date(1970, 0, 1);
	var dt = new Date(sDate);
	if ( isNaN(dt) )
		return new Date(1970, 0, 1);
	return dt;
}

Sql.IsDate = function (sDate)
{
	var dt = new Date(sDate);
	return !isNaN(dt);
}

Sql.IsEmail = function(sEmail)
{
	var filter = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
	return filter.test(sEmail);
}

Sql.ToBoolean = function(b)
{
	if ( b === undefined || b == null )
		return false;
	return (b == 'true' || b == 'True' || b == 'on' || b == '1' || b == true || b == 1);
}

// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
String.prototype.replaceAll = function (find, replace)
{
	var str = this;
	return str.replace(new RegExp(find.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'), 'g'), replace);
};

// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
Sql.EscapeSQL = function(str)
{
	if ( str != null )
	{
		// 03/09/2016 Paul.  Was not assigning the result back to the current string. 
		str = str.replaceAll('\'', '\'\'');
	}
	return str;
}

// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
Sql.EscapeSQLLike = function(str)
{
	if ( str != null )
	{
		str = str.replaceAll('\\', '\\\\');
		// 06/14/2015 Paul.  We want to allow the original like syntax which uses % for any chars and _ for any single char. 
		//str = str.replaceAll('%' , '\\%');
		//str = str.replaceAll('_' , '\\_');
	}
	return str;
}

// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
Sql.EscapeJavaScript = function(str)
{
	if ( str != null )
	{
		str = str.replaceAll('\\', '\\\\');
		str = str.replaceAll('\'', '\\\'');
		str = str.replaceAll('\"', '\\\"');
		str = str.replaceAll('\t', '\\t');
		str = str.replaceAll('\r', '\\r');
		str = str.replaceAll('\n', '\\n');
	}
	return str;
}

// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
Sql.EscapeEmail = function(str)
{
	if ( str != null )
	{
		str = str.replaceAll('&', '&amp;');
		str = str.replaceAll('<', '&lt;');
		str = str.replaceAll('>', '&gt;');
	}
	return str;
}

Sql.IsEmptyString = function(str)
{
	if ( str === undefined || str == null || str == '' )
		return true;
	return false;
}

Sql.ToGuid = function(g)
{
	if ( g === undefined || g == null || g == '' || typeof(g) != 'string' )
		return null;
	return g.toLowerCase();
}

Sql.IsEmptyGuid = function(str)
{
	if ( str === undefined || str == null || str == '' || str == '00000000-0000-0000-0000-000000000000' )
		return true;
	return false;
}

Sql.AppendParameter = function(cmd, sField, oValue, bOrClause)
{
	var ControlChars = { CrLf: '\r\n' };
	if ( bOrClause === undefined )
		bOrClause = false;
	// http://www.javascriptkit.com/javatutors/determinevar2.shtml
	if ( oValue == null )
	{
		if ( cmd.CommandText.length > 0 )
		{
			if ( bOrClause )
				cmd.CommandText += ' or ';
			else
				cmd.CommandText += ' and ';
		}
		cmd.CommandText += sField + ' is null' + ControlChars.CrLf;
	}
	else if ( typeof(oValue) == 'number' )
	{
		if ( cmd.CommandText.length > 0 )
		{
			if ( bOrClause )
				cmd.CommandText += ' or ';
			else
				cmd.CommandText += ' and ';
		}
		cmd.CommandText += sField + ' = ' + oValue + ControlChars.CrLf;
	}
	else if ( typeof(oValue) == 'boolean' )
	{
		if ( cmd.CommandText.length > 0 )
		{
			if ( bOrClause )
				cmd.CommandText += ' or ';
			else
				cmd.CommandText += ' and ';
		}
		cmd.CommandText += sField + ' = ' + (oValue ? '1' : '0') + ControlChars.CrLf;
	}
	else if ( typeof(oValue) == 'string' )
	{
		if ( cmd.CommandText.length > 0 )
		{
			if ( bOrClause )
				cmd.CommandText += ' or ';
			else
				cmd.CommandText += ' and ';
		}
		if ( oValue.length == 0 )
		{
			cmd.CommandText += sField + ' is null' + ControlChars.CrLf;
		}
		else
		{
			cmd.CommandText += sField + ' = \'' + this.EscapeSQL(oValue) + '\'' + ControlChars.CrLf;
		}
	}
	else if ( typeof(oValue) == 'object' )
	{
		if ( oValue.length )  // Array test. 
		{
			if ( oValue.length > 0 )
			{
				var bIncludeNull = false;
				var sValueList   = '';
				for ( var i = 0; i < oValue.length; i++ )
				{
					if ( oValue[i] == null || oValue[i].length == 0 )
					{
						bIncludeNull = true;
						// 05/29/2017 Paul.  vwOPPORTUNITIES_ByLeadSource converts null to empty string, so we need to include both. 
						if ( sValueList.length > 0 )
							sValueList += ', ';
						// 01/06/2018 Paul.  ASSIGNED_USER_ID will fail compare to ''. 
						if ( EndsWith(sField, '_ID') || EndsWith(sField, '_ID_C') )
							sValueList += 'null';
						else
							sValueList += '\'\'';
					}
					else
					{
						if ( sValueList.length > 0 )
							sValueList += ', ';
						sValueList += '\'' + this.EscapeSQL(oValue[i]) + '\'';
					}
				}
				if ( cmd.CommandText.length > 0 )
				{
					if ( bOrClause )
						cmd.CommandText += ' or ';
					else
						cmd.CommandText += ' and ';
				}
				if ( sValueList.length > 0 )
				{
					if ( bIncludeNull )
						cmd.CommandText += '(' + sField + ' is null or ' + sField + ' in (' + sValueList + '))' + ControlChars.CrLf;
					else
						cmd.CommandText += sField + ' in (' + sValueList + ')' + ControlChars.CrLf;
				}
				else if ( bIncludeNull )
				{
					cmd.CommandText += sField + ' is null' + ControlChars.CrLf;
				}
			}
		}
	}
}

// 06/16/2017 Paul.  Dashboard needs to parse form data. 
Sql.ParseFormData = function(sParameters)
{
	var row = new Object();
	if ( sParameters !== undefined && sParameters != null )
	{
		var arrParameters = sParameters.split('&');
		for ( var n in arrParameters )
		{
			var arrNameValue = arrParameters[n].split('=');
			if ( arrNameValue.length > 1 )
				row[arrNameValue[0]] = arrNameValue[1];
			else
				row[arrNameValue[0]] = null;
		}
	}
	return row;
}

// 07/01/2018 Paul.  Add ERASED_FIELDS when data privacy enabled. 
Sql.DataPrivacyErasedPill = function()
{
	return '<span class=\"Erased\">' + L10n.Term('DataPrivacy.LBL_ERASED_VALUE') + '</span>';
}

// 06/18/2015 Paul.  Add support for Seven theme. 
var SplendidDynamic = new Object();

SplendidDynamic.StackedLayout = function(sTheme, sViewName)
{
	if ( sViewName === undefined || sViewName == null )
		sViewName = '';
	return sTheme === 'Seven' && !EndsWith(sViewName, '.Preview');
}

// 08/18/2018 Paul.  We are having a problem with the creation of this function in the Survey DetailView page.  If it fails, just create returning faluse. 
try
{
	// 04/08/2017 Paul.  Use Bootstrap for responsive design.
	SplendidDynamic.BootstrapLayout = function()
	{
		// 06/24/2017 Paul.  We need a way to turn off bootstrap for BPMN, ReportDesigner and ChatDashboard. 
		return !bDESKTOP_LAYOUT && sPLATFORM_LAYOUT != '.OfficeAddin';
	}
}
catch(e)
{
	SplendidDynamic.BootstrapLayout = function()
	{
		return false;
	}
}
