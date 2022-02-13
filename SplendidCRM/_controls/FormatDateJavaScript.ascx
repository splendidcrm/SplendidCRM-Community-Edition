<%@ Control Language="c#" AutoEventWireup="false" Codebehind="FormatDateJavaScript.ascx.cs" Inherits="SplendidCRM._controls.FormatDateJavaScript" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
<script runat="server">
/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
</script>
<SplendidCRM:InlineScript runat="server">
	<script type="text/javascript">
function formatDate(dtValue, sFormat)
{
	if ( dtValue instanceof Date && dtValue.getFullYear() > 1 && sFormat !== undefined && sFormat != null )
	{
		var short_months = new Array('<%# String.Join("', '", System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.AbbreviatedMonthNames) %>');
		var long_months  = new Array('<%# String.Join("', '", System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.MonthNames) %>');
		var yyyy = dtValue.getFullYear();
		var yy   = yyyy.toString().substring(2);
		var M    = dtValue.getMonth() + 1;
		var MM   = M < 10 ? '0' + M : M;
		var MMM  = short_months[M];
		var MMMM = long_months[M];
		var d    = dtValue.getDate();
		var dd   = d < 10 ? '0' + d : d;
		
		var H  = dtValue.getHours();
		var HH = H < 10 ? '0' + H : H;
		var m  = dtValue.getMinutes();
		var mm = m < 10 ? '0' + m : m;
		var s  = dtValue.getSeconds();
		var ss = s < 10 ? '0' + s : s;
		var tt = H < 12 ? 'am' : 'pm';
		var TT = H < 12 ? 'AM' : 'PM';
		var h = H;
		if ( H == 0 )
			h = 12;
		else if ( H > 12 )
			h = H - 12;
		var hh = h < 10 ? '0' + h : h;

		sFormat = sFormat.replace('HH'  , HH  );
		sFormat = sFormat.replace('H'   , H   );
		sFormat = sFormat.replace('yyyy', yyyy);
		sFormat = sFormat.replace('yy'  , yy  );
		sFormat = sFormat.replace('MMMM', MMMM);
		sFormat = sFormat.replace('MMM' , MMM );
		sFormat = sFormat.replace('MM'  , MM  );
		sFormat = sFormat.replace('M'   , M   );
		sFormat = sFormat.replace('dd'  , dd  );
		sFormat = sFormat.replace('d'   , d   );
		sFormat = sFormat.replace('hh'  , hh  );
		sFormat = sFormat.replace('h'   , h   );
		sFormat = sFormat.replace('mm'  , mm  );
		sFormat = sFormat.replace('m'   , m   );
		sFormat = sFormat.replace('ss'  , ss  );
		sFormat = sFormat.replace('s'   , s   );
		sFormat = sFormat.replace('tt'  , tt  );
		sFormat = sFormat.replace('TT'  , TT  );
		return sFormat;
	}
	else
	{
		return '';
	}
}

function FromJsonDate(sDATA_VALUE, formatString)
{
	try
	{
		if ( typeof(sDATA_VALUE) == 'string' )
		{
			// 10/30/2011 Paul.  Not sure why the leading slash is missing. 
			if ( sDATA_VALUE.substr(0, 6) == '/Date(' )
			{
				//alert(sDATA_VALUE.substr(sDATA_VALUE.length - 2, 2) + ' = ' + ')/');
				if ( sDATA_VALUE.substr(sDATA_VALUE.length - 2, 2) == ')/' )
				{
					sDATA_VALUE = sDATA_VALUE.substr(6, sDATA_VALUE.length - 6 - 2);
					var utcTime = parseInt(sDATA_VALUE);
					var dt = new Date(utcTime);
					var off = dt.getTimezoneOffset();
					dt.setMinutes(dt.getMinutes() + off);
					return formatDate(dt, formatString);
					//return dt;
				}
			}
			// 05/31/2017 Paul.  We want to still support the HTML5 method. 
			else if ( sDATA_VALUE.substr(0, 7) == '\\/Date(' )
			{
				//alert(sDATA_VALUE.substr(sDATA_VALUE.length - 3, 3) + ' = ' + ')\\/');
				if ( sDATA_VALUE.substr(sDATA_VALUE.length - 3, 3) == ')\\/' )
				{
					sDATA_VALUE = sDATA_VALUE.substr(7, sDATA_VALUE.length - 7 - 3);
					var utcTime = parseInt(sDATA_VALUE);
					var dt = new Date(utcTime);
					// 04/24/2018 Paul.  The timezone needs to be applied. 
					var off = dt.getTimezoneOffset();
					dt.setMinutes(dt.getMinutes() + off);
					if ( formatString !== undefined )
						sDATA_VALUE = formatDate(dt, formatString);
					else
						sDATA_VALUE = dt;
				}
			}
		}
	}
	catch(e)
	{
		alert(dumpObj(e, 'FromJsonDate'));
	}
	return sDATA_VALUE;
}
	</script>
</SplendidCRM:InlineScript>

