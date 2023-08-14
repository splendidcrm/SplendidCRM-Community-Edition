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
using System.Xml;
using System.Globalization;
using Spring.Json;

namespace Spring.Social.Office365.Api
{
	/// <summary>
	/// Summary description for Sql.
	/// </summary>
	public class Sql
	{
		public static string EscapeSQL(string str)
		{
			str = str.Replace("\'", "\'\'");
			return str;
		}

		public static bool IsEmptyString(string str)
		{
			if ( str == null || str == String.Empty )
				return true;
			return false;
		}

		public static bool IsEmptyString(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return true;
			if ( obj.ToString() == String.Empty )
				return true;
			return false;
		}

		public static bool IsEmptyDateTime(DateTime? obj)
		{
			if ( obj == null || !obj.HasValue || obj.Value == DateTime.MinValue )
				return true;
			return false;
		}

		public static bool IsEmptyDateTime(DateTimeOffset? obj)
		{
			if ( obj == null || !obj.HasValue || obj.Value == DateTime.MinValue )
				return true;
			return false;
		}

		public static string ToString(string str)
		{
			if ( str == null )
				return String.Empty;
			return str;
		}

		public static string ToString(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return String.Empty;
			return obj.ToString();
		}

		public static object ToDBString(string str)
		{
			if ( str == null )
				return DBNull.Value;
			if ( str == String.Empty )
				return DBNull.Value;
			return str;
		}

		public static object ToDBString(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return DBNull.Value;
			string str = obj.ToString();
			if ( str == String.Empty )
				return DBNull.Value;
			return str ;
		}

		public static byte[] ToBinary(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return new byte[0];
			return (byte[]) obj;
		}

		public static object ToDBBinary(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return DBNull.Value;
			return obj ;
		}

		public static object ToDBBinary(byte[] aby)
		{
			if ( aby == null )
				return DBNull.Value;
			else if ( aby.Length == 0 )
				return DBNull.Value;
			return aby ;
		}

		public static DateTime ToDateTime(DateTime dt)
		{
			return dt;
		}

		public static DateTime ToDateTime(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return DateTime.MinValue;
			if ( obj.GetType() == Type.GetType("System.DateTime") )
				return Convert.ToDateTime(obj) ;
			if ( !Information.IsDate(obj) )
				return DateTime.MinValue;
			return Convert.ToDateTime(obj);
		}

		public static string ToDateString(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return String.Empty;
			if ( obj.GetType() == Type.GetType("System.DateTime") )
				return Convert.ToDateTime(obj).ToShortDateString() ;
			if ( !Information.IsDate(obj) )
				return String.Empty;
			return Convert.ToDateTime(obj).ToShortDateString();
		}

		public static string ToString(DateTime dt)
		{
			if ( dt == DateTime.MinValue )
				return String.Empty;
			return dt.ToString();
		}

		public static string ToDateString(DateTime dt)
		{
			if ( dt == DateTime.MinValue )
				return String.Empty;
			return dt.ToShortDateString();
		}

		public static string ToTimeString(DateTime dt)
		{
			if ( dt == DateTime.MinValue )
				return String.Empty;
			return dt.ToShortTimeString();
		}

		public static object ToDBDateTime(DateTime dt)
		{
			if ( dt == DateTime.MinValue )
				return DBNull.Value;
			else if ( dt.Year < 1753 )
				return DBNull.Value;
			return dt;
		}

		public static object ToDBDateTime(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return DBNull.Value;
			if ( !Information.IsDate(obj) )
				return DBNull.Value;
			DateTime dt = Convert.ToDateTime(obj);
			if ( dt == DateTime.MinValue )
				return DBNull.Value;
			return dt;
		}

		public static bool IsEmptyGuid(Guid g)
		{
			if ( g == Guid.Empty )
				return true;
			return false;
		}

		public static bool IsEmptyGuid(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return true;
			string str = obj.ToString();
			if ( str == String.Empty )
				return true;
			Guid g = XmlConvert.ToGuid(str);
			if ( g == Guid.Empty )
				return true;
			return false;
		}

		public static Guid ToGuid(Guid g)
		{
			return g;
		}

		public static Guid ToGuid(Byte[] b)
		{
			Guid g = new Guid((b[0]+(b[1]+(b[2]+b[3]*256)*256)*256),(short)(b[4]+b[5]*256),(short)(b[6]+b[7]*256),b[8],b[9],b[10],b[11],b[12],b[13],b[14],b[15]);
			return g;
		}

		public static Guid ToGuid(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return Guid.Empty;
			if ( obj.GetType() == Type.GetType("System.Guid") )
				return (Guid) obj ;
			string str = obj.ToString();
			if ( str == String.Empty )
				return Guid.Empty;
			return XmlConvert.ToGuid(str);
		}

		public static object ToDBGuid(Guid g)
		{
			if ( g == Guid.Empty )
				return DBNull.Value;
			return g;
		}

		public static object ToDBGuid(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return DBNull.Value;
			if ( obj.GetType() == Type.GetType("System.Guid") )
				return obj;
			string str = obj.ToString();
			if ( str == String.Empty )
				return DBNull.Value;
			Guid g = XmlConvert.ToGuid(str);
			if ( g == Guid.Empty )
				return DBNull.Value;
			return g ;
		}


		public static Int32 ToInteger(Int32 n)
		{
			return n;
		}

		public static Int32 ToInteger(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return 0;
			if ( obj.GetType() == Type.GetType("System.Int32") )
				return Convert.ToInt32(obj);
			else if ( obj.GetType() == Type.GetType("System.Boolean") )
				return (Int32) (Convert.ToBoolean(obj) ? 1 : 0) ;
			else if ( obj.GetType() == Type.GetType("System.Single") )
				return Convert.ToInt32(Math.Floor((System.Single) obj)) ;
			string str = obj.ToString();
			if ( str == String.Empty )
				return 0;
			Int32 nValue = 0;
			Int32.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out nValue);
			return nValue;
		}

		public static long ToLong(long n)
		{
			return n;
		}

		public static long ToLong(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return 0;
			if ( obj.GetType() == Type.GetType("System.Int64") )
				return Convert.ToInt64(obj);
			string str = obj.ToString();
			if ( str == String.Empty )
				return 0;
			Int64 nValue = 0;
			Int64.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out nValue);
			return nValue;
		}

		public static long ToInt64(long n)
		{
			return n;
		}

		public static long ToInt64(object obj)
		{
			return ToLong(obj);
		}

		public static short ToShort(short n)
		{
			return n;
		}

		public static short ToShort(int n)
		{
			return (short) n;
		}

		public static short ToShort(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return 0;
			if ( obj.GetType() == Type.GetType("System.Int32") || obj.GetType() == Type.GetType("System.Int16") )
				return Convert.ToInt16(obj);
			string str = obj.ToString();
			if ( str == String.Empty )
				return 0;
			Int16 nValue = 0;
			Int16.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out nValue);
			return nValue;
		}

		public static object ToDBInteger(Int32 n)
		{
			return n;
		}

		public static object ToDBInteger(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return DBNull.Value;
			if ( obj.GetType() == Type.GetType("System.Int32") )
				return obj;
			string str = obj.ToString();
			if ( str == String.Empty || !Information.IsNumeric(str))
				return DBNull.Value;
			Int32 nValue = 0;
			Int32.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out nValue);
			return nValue;
		}

		public static object ToDBLong(Int32 n)
		{
			return Convert.ToInt64(n);
		}

		public static object ToDBLong(Int64 n)
		{
			return n;
		}

		public static object ToDBLong(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return DBNull.Value;
			if ( obj.GetType() == Type.GetType("System.Int64") )
				return obj;
			string str = obj.ToString();
			if ( str == String.Empty || !Information.IsNumeric(str))
				return DBNull.Value;
			Int64 nValue = 0;
			Int64.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out nValue);
			return nValue;
		}

		public static float ToFloat(float f)
		{
			return f;
		}

		public static float ToFloat(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return 0;
			if ( obj.GetType() == Type.GetType("System.Double") )
				return (float) Convert.ToSingle(obj);
			string str = obj.ToString();
			if ( str == String.Empty || !Information.IsNumeric(str) )
				return 0;
			float fValue = 0;
			float.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out fValue);
			return fValue;
		}

		public static float ToFloat(string str)
		{
			if ( str == null )
				return 0;
			if ( str == String.Empty || !Information.IsNumeric(str) )
				return 0;
			float fValue = 0;
			float.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out fValue);
			return fValue;
		}

		public static object ToDBFloat(float f)
		{
			return f;
		}

		public static object ToDBDouble(double f)
		{
			return f;
		}

		public static object ToDBFloat(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return DBNull.Value;
			if ( obj.GetType() == Type.GetType("System.Double") )
				return obj;
			string str = obj.ToString();
			if ( str == String.Empty || !Information.IsNumeric(str) )
				return DBNull.Value;
			float fValue = 0;
			float.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out fValue);
			return fValue;
		}


		public static double ToDouble(double d)
		{
			return d;
		}

		public static double ToDouble(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return 0;
			if ( obj.GetType() == Type.GetType("System.Double") )
				return Convert.ToDouble(obj);
			string str = obj.ToString();
			if ( str == String.Empty || !Information.IsNumeric(str) )
				return 0;
			double dValue = 0;
			double.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out dValue);
			return dValue;
		}

		public static double ToDouble(string str)
		{
			if ( str == null )
				return 0;
			if ( str == String.Empty || !Information.IsNumeric(str) )
				return 0;
			double dValue = 0;
			double.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out dValue);
			return dValue;
		}


		public static Decimal ToDecimal(Decimal d)
		{
			return d;
		}

		public static Decimal ToDecimal(double d)
		{
			return Convert.ToDecimal(d);
		}

		public static Decimal ToDecimal(float f)
		{
			return Convert.ToDecimal(f);
		}

		public static Decimal ToDecimal(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return 0;
			if ( obj.GetType() == Type.GetType("System.Decimal") )
				return Convert.ToDecimal(obj);
			string str = obj.ToString();
			if ( str == String.Empty )
				return 0;
			Decimal dValue = 0;
			Decimal.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out dValue);
			return dValue;
		}

		public static object ToDBDecimal(Decimal d)
		{
			return d;
		}

		public static object ToDBDecimal(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return DBNull.Value;
			if ( obj.GetType() == Type.GetType("System.Decimal") )
				return obj;
			string str = obj.ToString();
			if ( str == String.Empty || !Information.IsNumeric(str) )
				return DBNull.Value;
			Decimal dValue = 0;
			Decimal.TryParse(str, NumberStyles.Any, System.Threading.Thread.CurrentThread.CurrentCulture, out dValue);
			return dValue;
		}


		public static Boolean ToBoolean(Boolean b)
		{
			return b;
		}

		public static Boolean ToBoolean(Int32 n)
		{
			return (n == 0) ? false : true ;
		}

		public static Boolean ToBoolean(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return false;
			if ( obj.GetType() == Type.GetType("System.Int32") )
				return (Convert.ToInt32(obj) == 0) ? false : true ;
			if ( obj.GetType() == Type.GetType("System.Byte") )
				return (Convert.ToByte(obj) == 0) ? false : true ;
			if ( obj.GetType() == Type.GetType("System.SByte") )
				return (Convert.ToSByte(obj) == 0) ? false : true ;
			if ( obj.GetType() == Type.GetType("System.Int16") )
				return (Convert.ToInt16(obj) == 0) ? false : true ;
			if ( obj.GetType() == Type.GetType("System.Decimal") )
				return (Convert.ToDecimal(obj) == 0) ? false : true ;
			if ( obj.GetType() == Type.GetType("System.String") )
			{
				string s = obj.ToString().ToLower();
				return (s == "true" || s == "on" || s == "1") ? true : false ;
			}
			if ( obj.GetType() != Type.GetType("System.Boolean") )
				return false;
			bool bValue = false;
			bool.TryParse(obj.ToString(), out bValue);
			return bValue;
		}

		public static object ToDBBoolean(Boolean b)
		{
			return b ? 1 : 0;
		}

		public static object ToDBBoolean(object obj)
		{
			if ( obj == null || obj == DBNull.Value )
				return DBNull.Value;
			if ( obj.GetType() != Type.GetType("System.Boolean") )
			{
				string s = obj.ToString().ToLower();
				return (s == "true" || s == "on" || s == "1") ? 1 : 0 ;
			}
			return Convert.ToBoolean(obj) ? 1 : 0;
		}

		public static string Truncate(object oValue, int nMaxLength)
		{
			return Truncate(Sql.ToString(oValue), nMaxLength);
		}

		public static string Truncate(string sValue, int nMaxLength)
		{
			if ( sValue.Length > nMaxLength )
				sValue = sValue.Substring(0, nMaxLength);
			return sValue;
		}
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

	public class JsonUtils
	{
		public static void FaultCheck(JsonValue json)
		{
			string status = json.GetValueOrDefault<string>("status");
			if ( status == "error" )
			{
				string message = json.GetValueOrDefault<string>("message");
				throw(new Exception(message));
			}
		}
	}
}

