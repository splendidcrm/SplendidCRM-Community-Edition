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
using System.Text;
using System.Collections;

// 07/31/2006 Paul.  Stop using VisualBasic library to increase compatibility with Mono. 
namespace SplendidCRM
{
	public class ControlChars
	{
		public static string CrLf
		{
			get { return "\r\n"; }
		}

			public static char Cr
		{
			get { return '\r'; }
		}

			public static char Lf
		{
			get { return '\n'; }
		}

			public static char Tab
		{
			get { return '\t'; }
		}
	}

	public enum TriState
	{
		UseDefault = -2,
		True = -1,
		False = 0,
	}
	
	public enum CompareMethod
	{
		Binary = 0,
		Text = 1,
	}

	public class Strings
	{
		public static string Space(int nCount)
		{
			return new string(' ', nCount);
		}

		public static string[] Split(string s, string sDelimiter, int nLimit, CompareMethod Compare)
		{
			ArrayList lst = new ArrayList();
			int nOffset = 0;
			if ( sDelimiter == String.Empty )
				sDelimiter = " ";
			while ( (nOffset = s.IndexOf(sDelimiter)) >= 0 )
			{
				if ( nLimit > 0 && lst.Count == nLimit-1 )
					break;
				lst.Add(s.Substring(0, nOffset));
				s = s.Substring(nOffset + sDelimiter.Length);
			}
			if ( lst.Count == 0 || s.Length > 0 )
				lst.Add(s);
			return lst.ToArray(typeof(System.String)) as string[];
		}
		
		/*
		// 03/07/2008 Paul.  Force the use of the culture-specific currency formatting. 
		public static string FormatCurrency(object o, int NumDigitsAfterDecimal, TriState IncludeLeadingDigit, TriState UseParensForNegativeNumbers, TriState GroupDigits)
		{
			// 07/31/2006 Paul.  We will always format with thousands separator and zero decimal places.
			//string sCurrencySymbol = System.Globalization.CultureInfo.CurrentCulture.NumberFormat.CurrencySymbol;
			if ( o == null || o is DateTime )
				throw(new Exception("Invalid currency expression"));
			string sValue = String.Format("{0:$#,#}", o);
			return sValue;
		}
		*/
	}

	public class Information
	{
		public static bool IsDate(object o)
		{
			if ( o == null )
				return false;
			else if ( o is DateTime )
				return true;
			else if ( o is String )
			{
				try
				{
					DateTime.Parse(o as String);
					return true;
				}
				catch
				{
				}
			}
			return false;
		}

		public static bool IsNumeric(object o)
		{
			if ( o == null || o is DateTime )
				return false;
			else if ( o is Int16 || o is Int32 || o is Int64 || o is Decimal || o is Single || o is Double )
				return true;
			else
			{
				try
				{
					if ( o is String )
						Double.Parse(o as String);
					else
						Double.Parse(o.ToString());
					return true;
				}
				catch
				{
				}
			}
			return false;
		}
	}
}

