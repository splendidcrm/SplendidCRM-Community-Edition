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
using System;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Threading;
using System.Globalization;
/*
using System.Web.SessionState;
using System.Text;
using System.Xml;
using System.Diagnostics;
*/

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SplendidDefaults.
	/// </summary>
	public class SplendidDefaults
	{
		// 12/22/2007 Paul.  Inside the timer event, there is no current context, so we need to pass the application. 
		public static string Culture(HttpApplicationState Application)
		{
			string sCulture = Sql.ToString(Application["CONFIG.default_language"]);
			// 12/22/2007 Paul.  The cache is not available when we are inside the timer event. 
			// 02/18/2008 Paul.  The Languages function is now thread safe, so it can be called from the timer. 
			//if ( HttpContext.Current != null && HttpContext.Current.Cache != null )
			{
				// 01/08/2017 Paul.  We are getting an odd exception from within the workflow thread. Just ignore and continue. 
				try
				{
					DataView vwLanguages = new DataView(SplendidCache.Languages(Application));
					// 05/20/2008 Paul.  Normalize culture before lookup. 
					vwLanguages.RowFilter = "NAME = '" + L10N.NormalizeCulture(sCulture) +"'";
					if ( vwLanguages.Count > 0 )
						sCulture = Sql.ToString(vwLanguages[0]["NAME"]);
				}
				catch
				{
				}
			}
			if ( Sql.IsEmptyString(sCulture) )
				sCulture = "en-US";
			return L10N.NormalizeCulture(sCulture);
		}

		public static string Culture()
		{
			return Culture(HttpContext.Current.Application);
		}

		public static string Theme()
		{
			string sTheme = Sql.ToString(HttpContext.Current.Application["CONFIG.default_theme"]);
			// 10/16/2015 Paul.  Change default theme to our newest theme. 
			// 10/02/2016 Paul.  Make the default theme Arctic. 
			if ( Sql.IsEmptyString(sTheme) )
				sTheme = "Arctic";
			return sTheme;
		}

		public static string MobileTheme()
		{
			string sTheme = Sql.ToString(HttpContext.Current.Application["CONFIG.default_mobile_theme"]);
			if ( Sql.IsEmptyString(sTheme) )
				sTheme = "Mobile";
			return sTheme;
		}

		public static string DateFormat()
		{
			string sDateFormat = Sql.ToString(HttpContext.Current.Application["CONFIG.default_date_format"]);
			if ( Sql.IsEmptyString(sDateFormat) )
				sDateFormat = "MM/dd/yyyy";
			// 11/28/2005 Paul.  Need to make sure that the default format is valid. 
			else if ( !IsValidDateFormat(sDateFormat) )
				sDateFormat = DateFormat(sDateFormat);
			return sDateFormat;
		}

		public static bool IsValidDateFormat(string sDateFormat)
		{
			if ( sDateFormat.IndexOf("m") >= 0 || sDateFormat.IndexOf("yyyy") < 0 )
				return false;
			return true;
		}

		public static string DateFormat(string sDateFormat)
		{
			// 11/12/2005 Paul.  "m" is not valid for .NET month formatting.  Must use MM. 
			if ( sDateFormat.IndexOf("m") >= 0 )
			{
				sDateFormat = sDateFormat.Replace("m", "M");
			}
			// 11/12/2005 Paul.  Require 4 digit year.  Otherwise default date in Pipeline of 12/31/2100 would get converted to 12/31/00. 
			if ( sDateFormat.IndexOf("yyyy") < 0 )
			{
				sDateFormat = sDateFormat.Replace("yy", "yyyy");
			}
			return sDateFormat;
		}

		public static string TimeFormat()
		{
			string sTimeFormat = Sql.ToString(HttpContext.Current.Application["CONFIG.default_time_format"]);
			if ( Sql.IsEmptyString(sTimeFormat) || sTimeFormat == "H:i" )
				sTimeFormat = "h:mm tt";
			return sTimeFormat;
		}

		public static string TimeZone()
		{
			// 08/08/2006 Paul.  Pull the default timezone and fall-back to Eastern US only if empty. 
			string sDEFAULT_TIMEZONE = Sql.ToString(HttpContext.Current.Application["CONFIG.default_timezone"]);
			if ( Sql.IsEmptyGuid(sDEFAULT_TIMEZONE) )
				sDEFAULT_TIMEZONE = "BFA61AF7-26ED-4020-A0C1-39A15E4E9E0A";
			return sDEFAULT_TIMEZONE;
		}

		public static string TimeZone(int nTimez)
		{
			string sTimeZone = String.Empty;
			DataView vwTimezones = new DataView(SplendidCache.Timezones());
			vwTimezones.RowFilter = "BIAS = " + nTimez.ToString();
			if ( vwTimezones.Count > 0 )
				sTimeZone = Sql.ToString(vwTimezones[0]["ID"]);
			else
				sTimeZone = TimeZone();
			return sTimeZone;
		}

		public static string CurrencyID()
		{
			// 08/08/2006 Paul.  Pull the default currency and fall-back to Dollars only if empty. 
			string sDEFAULT_CURRENCY = Sql.ToString(HttpContext.Current.Application["CONFIG.default_currency"]);
			if ( Sql.IsEmptyGuid(sDEFAULT_CURRENCY) )
			{
				sDEFAULT_CURRENCY = "E340202E-6291-4071-B327-A34CB4DF239B";
			}
			return sDEFAULT_CURRENCY;
		}

		// 04/30/2016 Paul.  Base currency has been USD, but we should make it easy to allow a different base. 
		public static Guid BaseCurrencyID(HttpApplicationState Application)
		{
			Guid gBASE_CURRENCY = Sql.ToGuid(Application["CONFIG.base_currency"]);
			if ( Sql.IsEmptyGuid(gBASE_CURRENCY) )
				gBASE_CURRENCY = new Guid("E340202E-6291-4071-B327-A34CB4DF239B");
			return gBASE_CURRENCY;
		}

		public static string BaseCurrencyISO(HttpApplicationState Application)
		{
			string sBASE_ISO4217 = "USD";
			Guid gBASE_CURRENCY = BaseCurrencyID(Application);
			Currency C10n = Application["CURRENCY." + gBASE_CURRENCY.ToString()] as SplendidCRM.Currency;
			if ( C10n != null )
			{
				sBASE_ISO4217 = C10n.ISO4217;
				if ( Sql.IsEmptyString(sBASE_ISO4217) )
					sBASE_ISO4217 = "USD";
			}
			return sBASE_ISO4217;
		}

		public static string GroupSeparator()
		{
			// 02/29/2008 Paul.  The config value should only be used as an override.  We should default to the .NET culture value. 
			string sGROUP_SEPARATOR = Sql.ToString(HttpContext.Current.Application["CONFIG.default_number_grouping_seperator"]);
			if ( Sql.IsEmptyString(sGROUP_SEPARATOR) )
				sGROUP_SEPARATOR  = Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyGroupSeparator;
			return sGROUP_SEPARATOR;
		}

		public static string DecimalSeparator()
		{
			// 02/29/2008 Paul.  The config value should only be used as an override.  We should default to the .NET culture value. 
			string sDECIMAL_SEPARATOR = Sql.ToString(HttpContext.Current.Application["CONFIG.default_decimal_seperator"]);
			if ( Sql.IsEmptyString(sDECIMAL_SEPARATOR) )
				sDECIMAL_SEPARATOR = Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyDecimalSeparator;
			return sDECIMAL_SEPARATOR;
		}

		public static string generate_graphcolor(string sInput, int nInstance)
		{
			string sColor = String.Empty;
			if ( nInstance < 20 )
			{
				string[] arrGraphColor =
				{
					"0xFF0000"
					, "0x00FF00"
					, "0x0000FF"
					, "0xFF6600"
					, "0x42FF8E"
					, "0x6600FF"
					, "0xFFFF00"
					, "0x00FFFF"
					, "0xFF00FF"
					, "0x66FF00"
					, "0x0066FF"
					, "0xFF0066"
					, "0xCC0000"
					, "0x00CC00"
					, "0x0000CC"
					, "0xCC6600"
					, "0x00CC66"
					, "0x6600CC"
					, "0xCCCC00"
					, "0x00CCCC"
				};
				sColor = arrGraphColor[nInstance];
			}
			else
			{
				sColor = "0x00CCCC";
				//sColor = "0x" + substr(md5(sInput), 0, 6);
			}
			return sColor;
		}

	}
}

