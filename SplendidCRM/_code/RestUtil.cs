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
using System.IO;
using System.Xml;
using System.Web;
using System.Web.SessionState;
using System.Data;
using System.Data.Common;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.Diagnostics;

namespace SplendidCRM
{
	public enum AccessMode
	{
		list,
		edit,
		view,
		related
	};
	
	// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs
	public class RestUtil
	{
		// 04/01/2020 Paul.  Move json utils to RestUtil. 
		#region json utils
		// http://msdn.microsoft.com/en-us/library/system.datetime.ticks.aspx
		public static long UnixTicks(DateTime dt)
		{
			return (dt.Ticks - 621355968000000000) / 10000;
		}

		public static string ToJsonDate(object dt)
		{
			return "\\/Date(" + UnixTicks(Sql.ToDateTime(dt)).ToString() + ")\\/";
		}

		public static string ToJsonUniversalDate(DateTime dtServerTime)
		{
			return "\\/Date(" + UnixTicks(dtServerTime.ToUniversalTime()).ToString() + ")\\/";
		}

		// 08/03/2012 Paul.  FromJsonDate is used on Web Capture services. 
		public static DateTime FromJsonDate(string s)
		{
			DateTime dt = DateTime.MinValue;
			if ( s.StartsWith( "\\/Date(" ) && s.EndsWith( ")\\/" ) )
			{
				s = s.Replace( "\\/Date(", "" );
				s = s.Replace( ")\\/", "" );
				long lEpoch = Sql.ToLong( s );
				dt = new DateTime( lEpoch * 10000 + 621355968000000000 );
			}
			else
			{
				dt = Sql.ToDateTime( s );
			}
			return dt;
		}

		// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
		// http://schotime.net/blog/index.php/2008/07/27/dataset-datatable-to-json/
		// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
		// 03/13/2016 Paul.  This method is needed by Administration/Rest.svc
		public static Dictionary<string, object> ToJson(string sBaseURI, string sModuleName, DataTable dt, TimeZone T10n)
		{
			Dictionary<string, object> d = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			results.Add("results", RowsToDictionary(sBaseURI, sModuleName, dt, T10n));
			d.Add("d", results);
			// 04/21/2017 Paul.  Count should be returend as a number. 
			if ( dt != null )
				d.Add("__count", dt.Rows.Count);
			return d;
		}

		// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
		public static Dictionary<string, object> ToJson(string sBaseURI, string sModuleName, DataRow dr, TimeZone T10n)
		{
			Dictionary<string, object> d       = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			Dictionary<string, object> drow    = new Dictionary<string, object>();
			
			// 08/28/2021 Paul.  Azure StorageAccounts uses a non Guid ID field. 
			bool bHasID = false;
			if ( dr.Table.Columns.Contains("ID") )
			{
				DataColumn col = dr.Table.Columns["ID"];
				if ( col.DataType != null && col.DataType.FullName == "System.Guid" )
					bHasID = true;
			}
			// 06/28/2011 Paul.  Now that we have switched to using views, the results may not have an ID column. 
			if ( bHasID )
			{
				Guid gID = Sql.ToGuid(dr["ID"]);
				if ( !Sql.IsEmptyString(sBaseURI) && !Sql.IsEmptyString(sModuleName) )
				{
					Dictionary<string, object> metadata = new Dictionary<string, object>();
					metadata.Add("uri", sBaseURI + "?ModuleName=" + sModuleName + "&ID=" + gID.ToString() + "");
					metadata.Add("type", "SplendidCRM." + sModuleName);
					if ( dr.Table.Columns.Contains("DATE_MODIFIED_UTC") )
					{
						DateTime dtDATE_MODIFIED_UTC = Sql.ToDateTime(dr["DATE_MODIFIED_UTC"]);
						metadata.Add("etag", gID.ToString() + "." + dtDATE_MODIFIED_UTC.Ticks.ToString() );
					}
					drow.Add("__metadata", metadata);
				}
			}
			
			for (int i = 0; i < dr.Table.Columns.Count; i++)
			{
				if ( dr.Table.Columns[i].DataType.FullName == "System.DateTime" )
				{
					// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
					drow.Add(dr.Table.Columns[i].ColumnName, ToJsonDate(T10n.FromServerTime(dr[i])) );
				}
				else
				{
					drow.Add(dr.Table.Columns[i].ColumnName, dr[i]);
				}
			}
			
			results.Add("results", drow);
			d.Add("d", results);
			return d;
		}

		// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
		// http://schotime.net/blog/index.php/2008/07/27/dataset-datatable-to-json/
		public static List<Dictionary<string, object>> RowsToDictionary(string sBaseURI, string sModuleName, DataTable dt, TimeZone T10n)
		{
			List<Dictionary<string, object>> objs = new List<Dictionary<string, object>>();
			// 10/11/2012 Paul.  dt will be null when no results security filter applied. 
			if ( dt != null )
			{
				// 08/28/2021 Paul.  Azure StorageAccounts uses a non Guid ID field. 
				bool bHasID = false;
				if ( dt.Columns.Contains("ID") )
				{
					DataColumn col = dt.Columns["ID"];
					if ( col.DataType != null && col.DataType.FullName == "System.Guid" )
						bHasID = true;
				}
				foreach (DataRow dr in dt.Rows)
				{
					// 06/28/2011 Paul.  Now that we have switched to using views, the results may not have an ID column. 
					Dictionary<string, object> drow = new Dictionary<string, object>();
					// 08/28/2021 Paul.  Azure StorageAccounts uses a non Guid ID field. 
					if ( bHasID )
					{
						Guid gID = Sql.ToGuid(dr["ID"]);
						if ( !Sql.IsEmptyString(sBaseURI) && !Sql.IsEmptyString(sModuleName) )
						{
							Dictionary<string, object> metadata = new Dictionary<string, object>();
							metadata.Add("uri", sBaseURI + "?ModuleName=" + sModuleName + "&ID=" + gID.ToString() + "");
							metadata.Add("type", "SplendidCRM." + sModuleName);
							if ( dr.Table.Columns.Contains("DATE_MODIFIED_UTC") )
							{
								DateTime dtDATE_MODIFIED_UTC = Sql.ToDateTime(dr["DATE_MODIFIED_UTC"]);
								metadata.Add("etag", gID.ToString() + "." + dtDATE_MODIFIED_UTC.Ticks.ToString() );
							}
							drow.Add("__metadata", metadata);
						}
					}
				
					for (int i = 0; i < dt.Columns.Count; i++)
					{
						if ( dt.Columns[i].DataType.FullName == "System.DateTime" )
						{
							// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
							drow.Add(dt.Columns[i].ColumnName, ToJsonDate(T10n.FromServerTime(dr[i])) );
						}
						else
						{
							drow.Add(dt.Columns[i].ColumnName, dr[i]);
						}
					}
					objs.Add(drow);
				}
			}
			return objs;
		}

		// 05/09/2016 Paul.  Add DataView version. 
		public static List<Dictionary<string, object>> RowsToDictionary(string sBaseURI, string sModuleName, DataView dt, TimeZone T10n)
		{
			List<Dictionary<string, object>> objs = new List<Dictionary<string, object>>();
			// 10/11/2012 Paul.  dt will be null when no results security filter applied. 
			if ( dt != null )
			{
				foreach (DataRowView dr in dt)
				{
					// 06/28/2011 Paul.  Now that we have switched to using views, the results may not have an ID column. 
					Dictionary<string, object> drow = new Dictionary<string, object>();
					if ( dt.Table.Columns.Contains("ID") )
					{
						Guid gID = Sql.ToGuid(dr["ID"]);
						if ( !Sql.IsEmptyString(sBaseURI) && !Sql.IsEmptyString(sModuleName) )
						{
							Dictionary<string, object> metadata = new Dictionary<string, object>();
							metadata.Add("uri", sBaseURI + "?ModuleName=" + sModuleName + "&ID=" + gID.ToString() + "");
							metadata.Add("type", "SplendidCRM." + sModuleName);
							if ( dt.Table.Columns.Contains("DATE_MODIFIED_UTC") )
							{
								DateTime dtDATE_MODIFIED_UTC = Sql.ToDateTime(dr["DATE_MODIFIED_UTC"]);
								metadata.Add("etag", gID.ToString() + "." + dtDATE_MODIFIED_UTC.Ticks.ToString() );
							}
							drow.Add("__metadata", metadata);
						}
					}
				
					for (int i = 0; i < dt.Table.Columns.Count; i++)
					{
						if ( dt.Table.Columns[i].DataType.FullName == "System.DateTime" )
						{
							// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
							drow.Add(dt.Table.Columns[i].ColumnName, ToJsonDate(T10n.FromServerTime(dr[i])) );
						}
						else
						{
							drow.Add(dt.Table.Columns[i].ColumnName, dr[i]);
						}
					}
					objs.Add(drow);
				}
			}
			return objs;
		}

		public static Dictionary<string, object> ToJson(string sBaseURI, string sModuleName, DataView dt, TimeZone T10n)
		{
			Dictionary<string, object> d = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			results.Add("results", RowsToDictionary(sBaseURI, sModuleName, dt, T10n));
			d.Add("d", results);
			// 04/21/2017 Paul.  Count should be returend as a number. 
			if ( dt != null )
				d.Add("__count", dt.Count);
			return d;
		}

		// 08/24/2014 Paul.  We need to convert to UTC, except for DATE_MODIFIED_UTC which is already UTC. 
		// http://schotime.net/blog/index.php/2008/07/27/dataset-datatable-to-json/
		public static List<Dictionary<string, object>> RowsToDictionaryUTC(string sBaseURI, string sModuleName, DataTable dt, TimeZone T10n)
		{
			List<Dictionary<string, object>> objs = new List<Dictionary<string, object>>();
			// 10/11/2012 Paul.  dt will be null when no results security filter applied. 
			if ( dt != null )
			{
				foreach (DataRow dr in dt.Rows)
				{
					// 06/28/2011 Paul.  Now that we have switched to using views, the results may not have an ID column. 
					Dictionary<string, object> drow = new Dictionary<string, object>();
					if ( dt.Columns.Contains("ID") )
					{
						Guid gID = Sql.ToGuid(dr["ID"]);
						if ( !Sql.IsEmptyString(sBaseURI) && !Sql.IsEmptyString(sModuleName) )
						{
							Dictionary<string, object> metadata = new Dictionary<string, object>();
							metadata.Add("uri", sBaseURI + "?ModuleName=" + sModuleName + "&ID=" + gID.ToString() + "");
							metadata.Add("type", "SplendidCRM." + sModuleName);
							if ( dr.Table.Columns.Contains("DATE_MODIFIED_UTC") )
							{
								DateTime dtDATE_MODIFIED_UTC = Sql.ToDateTime(dr["DATE_MODIFIED_UTC"]);
								metadata.Add("etag", gID.ToString() + "." + dtDATE_MODIFIED_UTC.Ticks.ToString() );
							}
							drow.Add("__metadata", metadata);
						}
					}
				
					for (int i = 0; i < dt.Columns.Count; i++)
					{
						if ( dt.Columns[i].DataType.FullName == "System.DateTime" )
						{
							// 08/24/2014 Paul.  We need to convert to UTC, except for DATE_MODIFIED_UTC which is already UTC. 
							DateTime dtServerTime = Sql.ToDateTime(dr[i]);
							if ( dt.Columns[i].ColumnName == "DATE_MODIFIED_UTC" )
								dtServerTime = DateTime.SpecifyKind(dtServerTime, DateTimeKind.Utc);
							else
								dtServerTime = DateTime.SpecifyKind(dtServerTime, DateTimeKind.Local);
							drow.Add(dt.Columns[i].ColumnName, RestUtil.ToJsonUniversalDate(dtServerTime) );
						}
						else
						{
							drow.Add(dt.Columns[i].ColumnName, dr[i]);
						}
					}
					objs.Add(drow);
				}
			}
			return objs;
		}

		// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
		public static Dictionary<string, object> ToJsonUTC(string sBaseURI, string sModuleName, DataTable dt, TimeZone T10n)
		{
			Dictionary<string, object> d = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			results.Add("results", RowsToDictionaryUTC(sBaseURI, sModuleName, dt, T10n));
			d.Add("d", results);
			// 04/21/2017 Paul.  Count should be returend as a number. 
			if ( dt != null )
				d.Add("__count", dt.Rows.Count);
			return d;
		}

		// 08/24/2014 Paul.  We need to convert to UTC, except for DATE_MODIFIED_UTC which is already UTC. 
		public static Dictionary<string, object> ToJsonUTC(string sBaseURI, string sModuleName, DataRow dr, TimeZone T10n)
		{
			Dictionary<string, object> d       = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			Dictionary<string, object> drow    = new Dictionary<string, object>();
			
			// 06/28/2011 Paul.  Now that we have switched to using views, the results may not have an ID column. 
			DataTable dt = dr.Table;
			if ( dt.Columns.Contains("ID") )
			{
				Guid gID = Sql.ToGuid(dr["ID"]);
				if ( !Sql.IsEmptyString(sBaseURI) && !Sql.IsEmptyString(sModuleName) )
				{
					Dictionary<string, object> metadata = new Dictionary<string, object>();
					metadata.Add("uri", sBaseURI + "?ModuleName=" + sModuleName + "&ID=" + gID.ToString() + "");
					metadata.Add("type", "SplendidCRM." + sModuleName);
					if ( dt.Columns.Contains("DATE_MODIFIED_UTC") )
					{
						DateTime dtDATE_MODIFIED_UTC = Sql.ToDateTime(dr["DATE_MODIFIED_UTC"]);
						metadata.Add("etag", gID.ToString() + "." + dtDATE_MODIFIED_UTC.Ticks.ToString() );
					}
					drow.Add("__metadata", metadata);
				}
			}
			
			for (int i = 0; i < dt.Columns.Count; i++)
			{
				if ( dt.Columns[i].DataType.FullName == "System.DateTime" )
				{
					// 08/24/2014 Paul.  We need to convert to UTC, except for DATE_MODIFIED_UTC which is already UTC. 
					DateTime dtServerTime = Sql.ToDateTime(dr[i]);
					if ( dt.Columns[i].ColumnName == "DATE_MODIFIED_UTC" )
						dtServerTime = DateTime.SpecifyKind(dtServerTime, DateTimeKind.Utc);
					else
						dtServerTime = DateTime.SpecifyKind(dtServerTime, DateTimeKind.Local);
					drow.Add(dt.Columns[i].ColumnName, RestUtil.ToJsonUniversalDate(dtServerTime) );
				}
				else
				{
					drow.Add(dt.Columns[i].ColumnName, dr[i]);
				}
			}
			
			results.Add("results", drow);
			d.Add("d", results);
			return d;
		}

		public static Stream ToJsonStream(Dictionary<string, object> d)
		{
			JavaScriptSerializer json = new JavaScriptSerializer();
			// 05/05/2013 Paul.  No reason to limit the Json result. 
			json.MaxJsonLength = int.MaxValue;
			string sResponse = json.Serialize(d);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		// 05/22/2017 Paul.  Shared function to convert from Json to DB. 
		public static object DBValueFromJsonValue(DbType dbType, object oJsonValue, TimeZone T10n)
		{
			object oParamValue = DBNull.Value;
			switch ( dbType )
			{
				// 10/08/2011 Paul.  We must use Sql.ToDBDateTime, otherwise we get a an error whe DateTime.MinValue is used. 
				// SqlDateTime overflow. Must be between 1/1/1753 12:00:00 AM and 12/31/9999 11:59:59 PM.
				// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
				case DbType.Date                 :  oParamValue = Sql.ToDBDateTime(T10n.ToServerTime(FromJsonDate(Sql.ToString(oJsonValue))));  break;
				case DbType.DateTime             :  oParamValue = Sql.ToDBDateTime(T10n.ToServerTime(FromJsonDate(Sql.ToString(oJsonValue))));  break;
				case DbType.Int16                :  oParamValue = Sql.ToDBInteger(oJsonValue);  break;
				case DbType.Int32                :  oParamValue = Sql.ToDBInteger(oJsonValue);  break;
				case DbType.Int64                :  oParamValue = Sql.ToDBInteger(oJsonValue);  break;
				case DbType.UInt16               :  oParamValue = Sql.ToDBInteger(oJsonValue);  break;
				case DbType.UInt32               :  oParamValue = Sql.ToDBInteger(oJsonValue);  break;
				case DbType.UInt64               :  oParamValue = Sql.ToDBInteger(oJsonValue);  break;
				case DbType.Single               :  oParamValue = Sql.ToDBFloat  (oJsonValue);  break;
				case DbType.Double               :  oParamValue = Sql.ToDBFloat  (oJsonValue);  break;
				case DbType.Decimal              :  oParamValue = Sql.ToDBDecimal(oJsonValue);  break;
				case DbType.Currency             :  oParamValue = Sql.ToDBDecimal(oJsonValue);  break;
				case DbType.Boolean              :  oParamValue = Sql.ToDBBoolean(oJsonValue);  break;
				case DbType.Guid                 :  oParamValue = Sql.ToDBGuid   (oJsonValue);  break;
				case DbType.String               :  oParamValue = Sql.ToDBString (oJsonValue);  break;
				case DbType.StringFixedLength    :  oParamValue = Sql.ToDBString (oJsonValue);  break;
				case DbType.AnsiString           :  oParamValue = Sql.ToDBString (oJsonValue);  break;
				case DbType.AnsiStringFixedLength:  oParamValue = Sql.ToDBString (oJsonValue);  break;
			}
			return oParamValue;
		}

		public static string ConvertODataFilter(string sFILTER, IDbCommand cmd)
		{
			// Logical Operators
			sFILTER = sFILTER.Replace(" eq true" , " eq 1");
			sFILTER = sFILTER.Replace(" eq false", " eq 0");
			sFILTER = sFILTER.Replace(" ne true" , " ne 1");
			sFILTER = sFILTER.Replace(" ne false", " ne 0");
			sFILTER = sFILTER.Replace(" gt ", " > ");
			sFILTER = sFILTER.Replace(" lt ", " < ");
			sFILTER = sFILTER.Replace(" eq ", " = ");
			sFILTER = sFILTER.Replace(" ne ", " <> ");
			// Arithmetic Operators
			sFILTER = sFILTER.Replace(" add ", " + ");
			sFILTER = sFILTER.Replace(" sub ", " - ");
			sFILTER = sFILTER.Replace(" mul ", " * ");
			sFILTER = sFILTER.Replace(" div ", " / ");
			sFILTER = sFILTER.Replace(" mod ", " % ");
			// Date Functions
			// 08/28/2021 Paul.  Don't want to be required to create a command to use this function. 
			if ( cmd == null || Sql.IsSQLServer(cmd) )
			{
				//sFILTER = sFILTER.Replace("year("  , "dbo.fnDatePart('year', "  );
				//sFILTER = sFILTER.Replace("month(" , "dbo.fnDatePart('month', " );
				//sFILTER = sFILTER.Replace("day("   , "dbo.fnDatePart('day', "   );
				sFILTER = sFILTER.Replace("hour("  , "dbo.fnDatePart('hour', "  );
				sFILTER = sFILTER.Replace("minute(", "dbo.fnDatePart('minute', ");
				sFILTER = sFILTER.Replace("second(", "dbo.fnDatePart('second', ");
			}
			else
			{
				//sFILTER = sFILTER.Replace("year("  , "fnDatePart('year', "  );
				//sFILTER = sFILTER.Replace("month(" , "fnDatePart('month', " );
				//sFILTER = sFILTER.Replace("day("   , "fnDatePart('day', "   );
				sFILTER = sFILTER.Replace("hour("  , "fnDatePart('hour', "  );
				sFILTER = sFILTER.Replace("minute(", "fnDatePart('minute', ");
				sFILTER = sFILTER.Replace("second(", "fnDatePart('second', ");
			}
			// Math Functions
			int nStart = sFILTER.IndexOf("round(");
			while ( nStart > 0 )
			{
				int nEnd = sFILTER.IndexOf(")", nStart);
				if ( nEnd > 0 )
				{
					sFILTER = sFILTER.Substring(0, nEnd - 1) + ", 0" + sFILTER.Substring(nEnd - 1);
				}
				nStart = sFILTER.IndexOf("round(", nStart + 1);
			}
			// String Functions
			sFILTER = sFILTER.Replace("tolower(", "lower(");
			sFILTER = sFILTER.Replace("toupper(", "upper(");
			if ( Sql.IsSQLServer(cmd) )
			{
				sFILTER = sFILTER.Replace("length("     , "len(");
				sFILTER = sFILTER.Replace("trim("       , "dbo.fnTrim(");
				sFILTER = sFILTER.Replace("concat("     , "dbo.fnConcat(");
				sFILTER = sFILTER.Replace("startswith(" , "dbo.fnStartsWith(");
				sFILTER = sFILTER.Replace("endswith("   , "dbo.fnEndsWith(");
				sFILTER = sFILTER.Replace("indexof("    , "dbo.fnIndexOf(");
				sFILTER = sFILTER.Replace("substringof(", "dbo.fnSubstringOf(");
			}
			return sFILTER;
		}
		#endregion

		public static List<string> AccessibleModules(HttpContext Context)
		{
			List<string> lstMODULES = SplendidCache.AccessibleModules(Context, Security.USER_ID);
			if ( Crm.Config.enable_team_management() )
			{
				if ( !lstMODULES.Contains("Teams") )
					lstMODULES.Add("Teams");
			}
			// 11/08/2009 Paul.  We need to combine the two module lists into a single list. 
			// 11/22/2009 Paul.  Simplify the logic by having a local list of system modules. 
			/*
			string[] arrSystemModules = new string[] { "ACL", "ACLActions", "ACLRoles", "Audit", "Config", "Currencies", "Dashlets"
			                                         , "DocumentRevisions", "DynamicButtons", "Export", "FieldValidators", "Import"
			                                         , "Merge", "Modules", "Offline", "Releases", "Roles", "SavedSearch", "Shortcuts"
			                                         , "TeamNotices", "Terminology", "Users", "SystemSyncLog"
			                                         };
			string[] arrSystemModules = new string[] { "Currencies", "DocumentRevisions", "Releases" };
			foreach ( string sSystemModule in arrSystemModules )
				lstMODULES.Add(sSystemModule);
			*/
			lstMODULES.Add("Currencies"       );
			lstMODULES.Add("Releases"         );
			if ( Security.GetUserAccess("DocumentRevisions", "view") >= 0 )  
				lstMODULES.Add("DocumentRevisions");
			// 11/30/2012 Paul.  Activities is a supported module so that we can get Open Activities and History to display in the HTML5 Offline Client. 
			if ( Security.GetUserAccess("Activities", "view") >= 0 )  
				lstMODULES.Add("Activities"       );
			// 12/02/2014 Paul.  Offline is a supported module so that we can show terms on the Mobile Client. 
			lstMODULES.Add("Offline"          );
			// 08/20/2019 Paul.  React Client now displays audit data. 
			lstMODULES.Add("Audit"            );
			// 07/27/2019 Paul.  DashboardPanels and DetailViewsRelationships do not have folders. 
			lstMODULES.Add("DashboardPanels"         );
			lstMODULES.Add("DetailViewsRelationships");
			if ( SplendidCRM.Security.AdminUserAccess("SystemLog", "list") >= 0 )
			{
				lstMODULES.Add("SystemLog");
			}
			return lstMODULES;
		}

		public static List<string> AdminAccessibleModules()
		{
			List<string> lstMODULES = new List<string>();
			// 03/02/2019 Paul.  For admin access, start with all enabled modules. 
			DataTable dt = SplendidCache.Modules();
			foreach ( DataRow row in dt.Rows )
			{
				string sMODULE_NAME = Sql.ToString(row["MODULE_NAME"]);
				if ( SplendidCRM.Security.AdminUserAccess(sMODULE_NAME, "edit") >= 0 )
				{
					lstMODULES.Add(sMODULE_NAME);
				}
			}
			// 10/30/2020 Paul.  React Client now displays audit data. 
			lstMODULES.Add("Audit"            );
			return lstMODULES;
		}

		// https://www.visualstudio.com/en-us/docs/report/analytics/aggregated-data-analytics
		private static void AddAggregate(ref string sSQL, string sVIEW_NAME, string sAggregate)
		{
			while ( sAggregate.Contains("  ") )
			{
				sAggregate = sAggregate.Replace("  ", " ");
			}
			string[] arr = sAggregate.Trim().Split(' ');
			if ( arr.Length == 5 )
			{
				string sColumn = arr[0];
				string sWith   = arr[1];
				string sType   = arr[2];
				string sAs     = arr[3];
				string sAlias  = arr[4];
				if ( String.Compare(sWith, "with", true) != 0 && String.Compare(sAs, "as", true) != 0 )
				{
					throw(new Exception("Aggregate has an invalid syntax, missing with and/or as clauses. (" + sAggregate + ")"));
				}
				else if ( String.Compare(sType, "count", true) == 0 || String.Compare(sType, "countdistinct", true) == 0 || String.Compare(sType, "sum", true) == 0 || String.Compare(sType, "avg", true) == 0 || String.Compare(sType, "min", true) == 0 || String.Compare(sType, "max", true) == 0 )
				{
					if ( Sql.IsEmptyString(sSQL) )
						sSQL  = "select ";
					else
						sSQL += "     , ";
					if ( String.Compare(sColumn, "count", true) == 0 && (String.Compare(sType, "sum", true) == 0 || String.Compare(sType, "count", true) == 0))
						sSQL += "count(*) as " + sAlias + ControlChars.CrLf;
					else if ( String.Compare(sType, "countdistinct", true) == 0 )
						sSQL += "count(distinct " + sVIEW_NAME + "." + sColumn + ") as " + sAlias + ControlChars.CrLf;
					else
						sSQL += sType + "(" + sVIEW_NAME + "." + sColumn + ") as " + sAlias + ControlChars.CrLf;
				}
				else
				{
					throw(new Exception(sType + " is not a supported aggregate type. (" + sAggregate + ")"));
				}
			}
			else
			{
				throw(new Exception("Aggregate should have 5 parts. (" + sAggregate + ")"));
			}
		}

		// 06/17/2013 Paul.  Add support for GROUP BY. 
		// 04/21/2017 Paul.  We need to return the total when using nTOP. 
		// 05/21/2017 Paul.  HTML5 Dashboard requires aggregates. 
		// 08/01/2019 Paul.  We need a ListView and EditView flags for the Rest Client. 
		// 09/09/2019 Paul.  Send duplicate filter info. 
		// 10/26/2019 Paul.  Return the SQL to the React Client. 
		// 12/03/2019 Paul.  The React Client needs access to archive data. 
		public static DataTable GetTable(HttpContext Context, string sTABLE_NAME, int nSKIP, int nTOP, string sFILTER, string sORDER_BY, string sGROUP_BY, UniqueStringCollection arrSELECT, Guid[] arrITEMS, ref long lTotalCount, UniqueStringCollection arrAGGREGATE, AccessMode enumAccessMode, bool bArchiveView, string sDUPLICATE_FIELDS, StringBuilder sbDumpSQL)
		{
			HttpSessionState     Session     = Context.Session;
			HttpApplicationState Application = Context.Application;
			// 05/19/2018 Paul.  Capture the last command for error tracking. 
			string sLastCommand = String.Empty;
			DataTable dt = null;
			try
			{
				// 09/03/2011 Paul.  We should use the cached layout tables instead of a database lookup for performance reasons. 
				// When getting the layout tables, we typically only need the view name, so extract from the filter string. 
				// The Regex match will allow an OData query. 
				if ( Security.IsAuthenticated() )
				{
					string sMATCH_NAME = String.Empty;
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
					if ( sTABLE_NAME == "DYNAMIC_BUTTONS" )
					{
						sMATCH_NAME = "VIEW_NAME";
						Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
						if ( match.Success )
						{
							string sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
							dt = SplendidCache.DynamicButtons(sVIEW_NAME).Copy();
							if ( dt != null )
							{
								// 04/30/2017 Paul.  Compute the access rights 
								dt.Columns.Add("MODULE_ACLACCESS", typeof(System.String));
								dt.Columns.Add("TARGET_ACLACCESS", typeof(System.String));
								bool bRowsDeleted = false;
								foreach(DataRow row in dt.Rows)
								{
									string sCONTROL_TYPE       = Sql.ToString (row["CONTROL_TYPE"      ]);
									string sMODULE_NAME        = Sql.ToString (row["MODULE_NAME"       ]);
									string sMODULE_ACCESS_TYPE = Sql.ToString (row["MODULE_ACCESS_TYPE"]);
									string sTARGET_NAME        = Sql.ToString (row["TARGET_NAME"       ]);
									string sTARGET_ACCESS_TYPE = Sql.ToString (row["TARGET_ACCESS_TYPE"]);
									bool   bADMIN_ONLY         = Sql.ToBoolean(row["ADMIN_ONLY"        ]);
									// 04/30/2017 Paul.  Default to allow for backward compatibility. 
									row["MODULE_ACLACCESS"] = "0";
									row["TARGET_ACLACCESS"] = "0";
									bool bVisible = (bADMIN_ONLY && Security.IS_ADMIN || !bADMIN_ONLY);
									if ( String.Compare(sCONTROL_TYPE, "Button", true) == 0 || String.Compare(sCONTROL_TYPE, "HyperLink", true) == 0 || String.Compare(sCONTROL_TYPE, "ButtonLink", true) == 0 )
									{
										if ( bVisible && !Sql.IsEmptyString(sMODULE_NAME) && !Sql.IsEmptyString(sMODULE_ACCESS_TYPE) )
										{
											int nACLACCESS = SplendidCRM.Security.GetUserAccess(sMODULE_NAME, sMODULE_ACCESS_TYPE);
											row["MODULE_ACLACCESS"] = nACLACCESS.ToString();
											// 09/03/2011 Paul.  Can't apply Owner rights without the item record. 
											//bVisible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID == gASSIGNED_USER_ID) || (!bIsPostBack && rdr == null) || (rdr != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
											if ( bVisible && !Sql.IsEmptyString(sTARGET_NAME) && !Sql.IsEmptyString(sTARGET_ACCESS_TYPE) )
											{
												nACLACCESS = SplendidCRM.Security.GetUserAccess(sTARGET_NAME, sTARGET_ACCESS_TYPE);
												row["TARGET_ACLACCESS"] = nACLACCESS.ToString();
												// 09/03/2011 Paul.  Can't apply Owner rights without the item record. 
												//bVisible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID == gASSIGNED_USER_ID) || (!bIsPostBack && rdr == null) || (rdr != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
											}
										}
									}
									if ( !bVisible )
									{
										row.Delete();
										bRowsDeleted = true;
									}
								}
								if ( bRowsDeleted )
									dt.AcceptChanges();
							}
							return dt;
						}
					}
					else if ( sTABLE_NAME == "GRIDVIEWS_COLUMNS" )
					{
						sMATCH_NAME = "GRID_NAME";
						Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
						if ( match.Success )
						{
							string sGRID_NAME = match.Groups[sMATCH_NAME].Value;
							dt = SplendidCache.GridViewColumns(sGRID_NAME);
							// 09/03/2011 Paul.  Apply Field Level Security before sending to the client. 
							if ( dt != null && SplendidInit.bEnableACLFieldSecurity )
							{
								bool bRowsDeleted = false;
								// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
								for ( int i = 0; i < dt.Rows.Count; i++ )
								{
									DataRow row = dt.Rows[i];
									string sDATA_FIELD  = Sql.ToString (row["DATA_FIELD"]);
									string sMODULE_NAME = String.Empty;
									string[] arrGRID_NAME = sGRID_NAME.Split('.');
									if ( arrGRID_NAME.Length > 0 )
									{
										if ( arrGRID_NAME[0] == "ListView" || arrGRID_NAME[0] == "PopupView" || arrGRID_NAME[0] == "Activities" )
											sMODULE_NAME = arrGRID_NAME[0];
										else if ( Sql.ToBoolean(Application["Modules." + arrGRID_NAME[1] + ".Valid"]) )
											sMODULE_NAME = arrGRID_NAME[1];
										else
											sMODULE_NAME = arrGRID_NAME[0];
									}
									bool bIsReadable = true;
									if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sDATA_FIELD) )
									{
										Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, Guid.Empty);
										bIsReadable  = acl.IsReadable();
									}
									if ( !bIsReadable )
									{
										row.Delete();
										bRowsDeleted = true;
									}
									// 09/03/2011 Paul.  We only need one copy of the SCRIPT field in the first record. 
									if ( i > 0 )
										row["SCRIPT"] = DBNull.Value;
								}
								if ( bRowsDeleted )
									dt.AcceptChanges();
							}
							return dt;
						}
					}
					else if ( sTABLE_NAME == "EDITVIEWS_FIELDS" )
					{
						sMATCH_NAME = "EDIT_NAME";
						Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
						if ( match.Success )
						{
							string sEDIT_NAME = match.Groups[sMATCH_NAME].Value;
							// 05/05/2106 Paul.  Do not use the Primary Role here.  The REST API should always return what is requested to prevent double processing. 
							dt = SplendidCache.EditViewFields(sEDIT_NAME);
							// 09/03/2011 Paul.  Apply Field Level Security before sending to the client. 
							if ( dt != null && SplendidInit.bEnableACLFieldSecurity )
							{
								// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
								for ( int i = 0; i < dt.Rows.Count; i++ )
								{
									DataRow row = dt.Rows[i];
									string sFIELD_TYPE    = Sql.ToString (row["FIELD_TYPE"   ]);
									string sDATA_FIELD    = Sql.ToString (row["DATA_FIELD"   ]);
									string sDATA_FORMAT   = Sql.ToString (row["DATA_FORMAT"  ]);
									string sDISPLAY_FIELD = Sql.ToString (row["DISPLAY_FIELD"]);
									string sMODULE_NAME   = String.Empty;
									string[] arrEDIT_NAME = sEDIT_NAME.Split('.');
									if ( arrEDIT_NAME.Length > 0 )
										sMODULE_NAME = arrEDIT_NAME[0];
									bool bIsReadable  = true;
									bool bIsWriteable = true;
									if ( SplendidInit.bEnableACLFieldSecurity )
									{
										// 09/03/2011 Paul.  Can't apply Owner rights without the item record. 
										Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, Guid.Empty);
										bIsReadable  = acl.IsReadable();
										// 02/16/2011 Paul.  We should allow a Read-Only field to be searchable, so always allow writing if the name contains Search. 
										bIsWriteable = acl.IsWriteable() || sEDIT_NAME.Contains(".Search");
									}
									if ( !bIsReadable )
									{
										row["FIELD_TYPE"] = "Blank";
									}
									else if ( !bIsWriteable )
									{
										row["FIELD_TYPE"] = "Label";
									}
									// 09/03/2011 Paul.  We only need one copy of the SCRIPT field in the first record. 
									if ( i > 0 )
										row["SCRIPT"] = DBNull.Value;
								}
							}
							return dt;
						}
					}
					else if ( sTABLE_NAME == "DETAILVIEWS_FIELDS" )
					{
						sMATCH_NAME = "DETAIL_NAME";
						Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
						if ( match.Success )
						{
							string sDETAIL_NAME = match.Groups[sMATCH_NAME].Value;
							dt = SplendidCache.DetailViewFields(sDETAIL_NAME);
							// 09/03/2011 Paul.  Apply Field Level Security before sending to the client. 
							if ( dt != null && SplendidInit.bEnableACLFieldSecurity )
							{
								// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
								for ( int i = 0; i < dt.Rows.Count; i++ )
								{
									DataRow row = dt.Rows[i];
									string sDATA_FIELD  = Sql.ToString (row["DATA_FIELD"]);
									string sMODULE_NAME = String.Empty;
									string[] arrDETAIL_NAME = sDETAIL_NAME.Split('.');
									if ( arrDETAIL_NAME.Length > 0 )
										sMODULE_NAME = arrDETAIL_NAME[0];
									bool bIsReadable  = true;
									if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sDATA_FIELD) )
									{
										// 09/03/2011 Paul.  Can't apply Owner rights without the item record. 
										Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, Guid.Empty);
										bIsReadable  = acl.IsReadable();
									}
									if ( !bIsReadable )
									{
										row["FIELD_TYPE"] = "Blank";
									}
									// 09/03/2011 Paul.  We only need one copy of the SCRIPT field in the first record. 
									if ( i > 0 )
										row["SCRIPT"] = DBNull.Value;
								}
							}
							return dt;
						}
					}
					else if ( sTABLE_NAME == "DETAILVIEWS_RELATIONSHIPS" )
					{
						sMATCH_NAME = "DETAIL_NAME";
						Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
						if ( match.Success )
						{
							string sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
							dt = SplendidCache.DetailViewRelationships(sVIEW_NAME).Copy();
							if ( dt != null )
							{
								bool bRowsDeleted = false;
								foreach(DataRow row in dt.Rows)
								{
									string sMODULE_NAME       = Sql.ToString(row["MODULE_NAME" ]);
									string sCONTROL_NAME      = Sql.ToString(row["CONTROL_NAME"]);
									string sMODULE_TABLE_NAME = Sql.ToString(Context.Application["Modules." + sMODULE_NAME + ".TableName"]).ToUpper();
									// 10/09/2012 Paul.  Make sure to filter by modules with REST enabled. 
									// 05/09/2017 Paul.  Adding new Home to HTML5 client.  Home does not have an associated table. 
									// 05/26/2018 Paul.  Adding new Dashboard to HTML5 client. 
									if ( sMODULE_NAME != "Home" && sMODULE_NAME != "Activities" && sMODULE_NAME != "Dashboard" )
									{
										using ( DataView vwSYNC_TABLES = new DataView(SplendidCache.RestTables(sMODULE_TABLE_NAME, true)) )
										{
											bool bVisible = (SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "list") >= 0) && vwSYNC_TABLES.Count > 0;
											if ( !bVisible )
											{
												row.Delete();
												bRowsDeleted = true;
											}
										}
									}
								}
								if ( bRowsDeleted )
									dt.AcceptChanges();
							}
							return dt;
						}
					}
					// 02/14/2016 Paul.  The new layout editor needs access to Enabled falg. 
					else if ( sTABLE_NAME == "DETAILVIEWS_RELATIONSHIPS_La" || sTABLE_NAME == "DETAILVIEWS_RELATIONSHIPS_Layout" )
					{
						sMATCH_NAME = "DETAIL_NAME";
						Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
						if ( match.Success )
						{
							string sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								string sSQL = String.Empty;
								sSQL = "select *                                               " + ControlChars.CrLf
								     + "  from vwDETAILVIEWS_RELATIONSHIPS_La                  " + ControlChars.CrLf
								     + " where DETAIL_NAME = @DETAIL_NAME                      " + ControlChars.CrLf
								     + " order by RELATIONSHIP_ENABLED desc, RELATIONSHIP_ORDER" + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@DETAIL_NAME", sVIEW_NAME);
									
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										dt = new DataTable();
										da.Fill(dt);
									}
								}
							}
							return dt;
						}
					}
					else if ( sTABLE_NAME == "EDITVIEWS_RELATIONSHIPS_Layout" )
					{
						sMATCH_NAME = "EDIT_NAME";
						Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
						if ( match.Success )
						{
							string sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								string sSQL = String.Empty;
								sSQL = "select *                                               " + ControlChars.CrLf
								     + "  from vwEDITVIEWS_RELATIONSHIPS_Layout                " + ControlChars.CrLf
								     + " where EDIT_NAME = @EDIT_NAME                          " + ControlChars.CrLf
								     + " order by RELATIONSHIP_ENABLED desc, RELATIONSHIP_ORDER" + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@EDIT_NAME", sVIEW_NAME);
									
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										dt = new DataTable();
										da.Fill(dt);
									}
								}
							}
							return dt;
						}
					}
					// 02/14/2016 Paul.  The new layout editor needs access to layout events. 
					else if ( sTABLE_NAME == "DETAILVIEWS" )
					{
						sMATCH_NAME = "NAME";
						Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
						if ( match.Success )
						{
							string sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								string sSQL = String.Empty;
								sSQL = "select *            " + ControlChars.CrLf
								     + "  from vwDETAILVIEWS" + ControlChars.CrLf
								     + " where NAME = @NAME " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@NAME", sVIEW_NAME);
									
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										dt = new DataTable();
										da.Fill(dt);
									}
								}
								if ( dt != null )
								{
									bool bRowsDeleted = false;
									foreach ( DataRow row in dt.Rows )
									{
										string sMODULE_NAME       = Sql.ToString(row["MODULE_NAME" ]);
										string sMODULE_TABLE_NAME = Sql.ToString(Context.Application["Modules." + sMODULE_NAME + ".TableName"]).ToUpper();
										// 10/09/2012 Paul.  Make sure to filter by modules with REST enabled. 
										using ( DataView vwSYNC_TABLES = new DataView(SplendidCache.RestTables(sMODULE_TABLE_NAME, true)) )
										{
											bool bVisible = (SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "list") >= 0) && vwSYNC_TABLES.Count > 0;
											if ( !bVisible )
											{
												row.Delete();
												bRowsDeleted = true;
											}
										}
									}
									if ( bRowsDeleted )
										dt.AcceptChanges();
								}
							}
							return dt;
						}
					}
					else if ( sTABLE_NAME == "EDITVIEWS" )
					{
						sMATCH_NAME = "NAME";
						Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
						if ( match.Success )
						{
							string sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								string sSQL = String.Empty;
								sSQL = "select *            " + ControlChars.CrLf
								     + "  from vwEDITVIEWS  " + ControlChars.CrLf
								     + " where NAME = @NAME " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@NAME", sVIEW_NAME);
									
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										dt = new DataTable();
										da.Fill(dt);
									}
								}
								if ( dt != null )
								{
									bool bRowsDeleted = false;
									foreach ( DataRow row in dt.Rows )
									{
										string sMODULE_NAME       = Sql.ToString(row["MODULE_NAME" ]);
										string sMODULE_TABLE_NAME = Sql.ToString(Context.Application["Modules." + sMODULE_NAME + ".TableName"]).ToUpper();
										// 10/09/2012 Paul.  Make sure to filter by modules with REST enabled. 
										using ( DataView vwSYNC_TABLES = new DataView(SplendidCache.RestTables(sMODULE_TABLE_NAME, true)) )
										{
											bool bVisible = (SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "list") >= 0) && vwSYNC_TABLES.Count > 0;
											if ( !bVisible )
											{
												row.Delete();
												bRowsDeleted = true;
											}
										}
									}
									if ( bRowsDeleted )
										dt.AcceptChanges();
								}
							}
							return dt;
						}
					}
					else if ( sTABLE_NAME == "GRIDVIEWS" )
					{
						sMATCH_NAME = "NAME";
						Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
						if ( match.Success )
						{
							string sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								string sSQL = String.Empty;
								sSQL = "select *            " + ControlChars.CrLf
								     + "  from vwGRIDVIEWS  " + ControlChars.CrLf
								     + " where NAME = @NAME " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@NAME", sVIEW_NAME);
									
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										dt = new DataTable();
										da.Fill(dt);
									}
								}
								if ( dt != null )
								{
									bool bRowsDeleted = false;
									foreach ( DataRow row in dt.Rows )
									{
										string sMODULE_NAME       = Sql.ToString(row["MODULE_NAME" ]);
										string sMODULE_TABLE_NAME = Sql.ToString(Context.Application["Modules." + sMODULE_NAME + ".TableName"]).ToUpper();
										// 10/09/2012 Paul.  Make sure to filter by modules with REST enabled. 
										using ( DataView vwSYNC_TABLES = new DataView(SplendidCache.RestTables(sMODULE_TABLE_NAME, true)) )
										{
											bool bVisible = (SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "list") >= 0) && vwSYNC_TABLES.Count > 0;
											if ( !bVisible )
											{
												row.Delete();
												bRowsDeleted = true;
											}
										}
									}
									if ( bRowsDeleted )
										dt.AcceptChanges();
								}
							}
							return dt;
						}
					}
					else if ( sTABLE_NAME == "TAB_MENUS" )
					{
						dt = SplendidCache.TabMenu().Copy();
						// 04/30/2017 Paul.  Compute the access rights 
						if ( dt != null )
						{
							dt.Columns.Add("EDIT_ACLACCESS", typeof(System.String));
							foreach ( DataRow row in dt.Rows )
							{
								string sMODULE_NAME = Sql.ToString(row["MODULE_NAME"]);
								int nEDIT_ACLACCESS = SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "edit");
								row["EDIT_ACLACCESS"] = nEDIT_ACLACCESS.ToString();
							}
						}
						return dt;
					}
					Regex r = new Regex(@"[^A-Za-z0-9_]");
					sTABLE_NAME = r.Replace(sTABLE_NAME, "");
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						// 06/03/2011 Paul.  Cache the Rest Table data. 
						// 01/27/2020 Paul.  The Archive views are not duplicated in the table, so just check if the base view exists. 
						string sREST_TABLE = sTABLE_NAME;
						if ( bArchiveView && sTABLE_NAME.EndsWith("_ARCHIVE") )
						{
							sREST_TABLE = sTABLE_NAME.Substring(0, sTABLE_NAME.Length - 8);
						}
						using ( DataTable dtSYNC_TABLES = SplendidCache.RestTables(sREST_TABLE, false) )
						{
							string sSQL = String.Empty;
							if ( dtSYNC_TABLES != null && dtSYNC_TABLES.Rows.Count > 0 )
							{
								DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
								string sMODULE_NAME         = Sql.ToString (rowSYNC_TABLE["MODULE_NAME"        ]);
								string sVIEW_NAME           = Sql.ToString (rowSYNC_TABLE["VIEW_NAME"          ]);
								bool   bHAS_CUSTOM          = Sql.ToBoolean(rowSYNC_TABLE["HAS_CUSTOM"         ]);
								int    nMODULE_SPECIFIC     = Sql.ToInteger(rowSYNC_TABLE["MODULE_SPECIFIC"    ]);
								string sMODULE_FIELD_NAME   = Sql.ToString (rowSYNC_TABLE["MODULE_FIELD_NAME"  ]);
								bool   bIS_RELATIONSHIP     = Sql.ToBoolean(rowSYNC_TABLE["IS_RELATIONSHIP"    ]);
								string sMODULE_NAME_RELATED = Sql.ToString (rowSYNC_TABLE["MODULE_NAME_RELATED"]);
								// 05/15/2017 Paul.  Just started using IS_ASSIGNED flag. 
								bool    bIS_ASSIGNED         = Sql.ToBoolean(rowSYNC_TABLE["IS_ASSIGNED"        ]);
								string  sASSIGNED_FIELD_NAME = Sql.ToString (rowSYNC_TABLE["ASSIGNED_FIELD_NAME"]);
								// 09/28/2011 Paul.  Include the system flag so that we can cache only system tables. 
								bool   bIS_SYSTEM           = Sql.ToBoolean(rowSYNC_TABLE["IS_SYSTEM"          ]);
								// 11/01/2009 Paul.  Protect against SQL Injection. A table name will never have a space character.
								sTABLE_NAME        = Sql.ToString (rowSYNC_TABLE["TABLE_NAME"         ]);
								sTABLE_NAME        = r.Replace(sTABLE_NAME       , "");
								sVIEW_NAME         = r.Replace(sVIEW_NAME        , "");
								sMODULE_FIELD_NAME = r.Replace(sMODULE_FIELD_NAME, "");
								// 02/29/2016 Paul.  Special fix for product catalog. 
								if ( sTABLE_NAME == "PRODUCT_CATALOG" )
								{
									if ( Sql.ToBoolean(Application["CONFIG.ProductCatalog.EnableOptions"]) )
									{
										sVIEW_NAME = Sql.MetadataName(con, "vwPRODUCT_TEMPLATES_OptionsCatalog");
										if ( arrSELECT != null )
										{
											arrSELECT.Add("PARENT_ID"      );
											arrSELECT.Add("MINIMUM_OPTIONS");
											arrSELECT.Add("MAXIMUM_OPTIONS");
										}
									}
								}
								// 07/01/2018 Paul.  Add data privacy flag for the module. 
								bool   bIS_DATA_PRIVACY_MODULE = false;
								if ( Crm.Config.enable_data_privacy() && dtSYNC_TABLES.Columns.Contains("IS_DATA_PRIVACY_MODULE") )
								{
									bIS_DATA_PRIVACY_MODULE = Sql.ToBoolean(rowSYNC_TABLE["IS_DATA_PRIVACY_MODULE"]);
								}
								// 08/02/2019 Paul.  The React Client will need access to views that require a filter, like CAMPAIGN_ID. 
								string sREQUIRED_FIELDS = String.Empty;
								if ( dtSYNC_TABLES.Columns.Contains("REQUIRED_FIELDS") )
								{
									sREQUIRED_FIELDS = Sql.ToString (rowSYNC_TABLE["REQUIRED_FIELDS"]);
								}
								// 08/01/2019 Paul.  We need a ListView and EditView flags for the Rest Client. 
								// 09/09/2019 Paul.  The Activities module collies with the Calendar list, so we have to make an exception. 
								if ( enumAccessMode == AccessMode.list && dtSYNC_TABLES.Columns.Contains("LIST_VIEW") && sTABLE_NAME != "vwACTIVITIES" )
								{
									// 12/03/2019 Paul.  The React Client needs access to archive data. 
									if ( bArchiveView && SplendidCache.ArchiveViewExists(sVIEW_NAME) )
									{
										sVIEW_NAME += "_ARCHIVE";
									}
									else
									{
										string sLIST_VIEW = Sql.ToString (rowSYNC_TABLE["LIST_VIEW"]);
										if ( !Sql.IsEmptyString(sLIST_VIEW) )
											sVIEW_NAME = sLIST_VIEW;
									}
								}
								else if ( (enumAccessMode == AccessMode.edit || enumAccessMode == AccessMode.view) && dtSYNC_TABLES.Columns.Contains("EDIT_VIEW") )
								{
									// 12/03/2019 Paul.  The React Client needs access to archive data. 
									if ( bArchiveView && SplendidCache.ArchiveViewExists(sVIEW_NAME) )
									{
										sVIEW_NAME += "_ARCHIVE";
									}
									else
									{
										string sEDIT_VIEW = Sql.ToString (rowSYNC_TABLE["EDIT_VIEW"]);
										if ( !Sql.IsEmptyString(sEDIT_VIEW) )
											sVIEW_NAME = sEDIT_VIEW;
									}
								}
								else
								{
									// 12/03/2019 Paul.  The React Client needs access to archive data. 
									if ( bArchiveView && SplendidCache.ArchiveViewExists(sVIEW_NAME) )
									{
										sVIEW_NAME += "_ARCHIVE";
									}
								}
								// 12/05/2019 Paul.  We need to enable favorites for React Client. 
								if ( !bArchiveView && enumAccessMode == AccessMode.view && arrSELECT != null && arrAGGREGATE == null )
								{
									if ( !Sql.ToBoolean(Application["CONFIG.disable_favorites"]) )
									{
										arrSELECT.Add("FAVORITE_RECORD_ID"    );
									}
									// 02/07/2022 Paul.  Correct case of disable_following. 
									if ( !Sql.ToBoolean(Application["CONFIG.disable_following"]) && Sql.ToBoolean(Application["CONFIG.enable_activity_streams"]) && Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".StreamEnabled"]) )
									{
										arrSELECT.Add("SUBSCRIPTION_PARENT_ID");
									}
								}
								// 07/04/2020 Paul.  React Client needs access to more User data.  Allow a user to get his own data or allow an admin to get all data. 
								if ( !bArchiveView && sVIEW_NAME == "vwUSERS_Sync" && (enumAccessMode == AccessMode.edit || enumAccessMode == AccessMode.view) && ((arrITEMS != null && arrITEMS.Length == 1 && arrITEMS[0] == Security.USER_ID) || Security.AdminUserAccess("Users", (enumAccessMode == AccessMode.edit ? "edit" : "view")) >= 0) )
								{
									sVIEW_NAME = "vwUSERS_Edit";
								}
								
								// 09/28/2011 Paul.  Non-system tables should not be cached on the server because they can change at any time. 
								// 10/01/2011 Paul.  We are getting No Response on system tables and no network request is made when online. 
								//if ( !bIS_SYSTEM )
									Context.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
								
								// 08/03/2011 Paul.  We need a way to filter the columns so that we can be efficient. 
								if ( arrSELECT != null && arrSELECT.Count > 0 )
								{
									foreach ( string sColumnName in arrSELECT )
									{
										// 11/11/2020 Paul.  We have seen teh vwLEADS_CONTACTS table not have an archive view, so don't include flag in select statement. 
										if ( bArchiveView && sColumnName == "ARCHIVE_VIEW" )
										{
											if ( !sVIEW_NAME.EndsWith("_ARCHIVE") )
												continue;
										}
										if ( Sql.IsEmptyString(sSQL) )
											sSQL += "select ";
										else
											sSQL += "     , ";
										// 09/22/2019 Paul.  Add support for Favorites and Stream Subscriptions. 
										if ( String.Compare(sColumnName, "FAVORITE_RECORD_ID") == 0 || String.Compare(sColumnName, "SUBSCRIPTION_PARENT_ID") == 0 )
										{
											sSQL += sColumnName + ControlChars.CrLf;
										}
										// 08/11/2020 Paul.  An export list may contain a calculated field. 
										else if ( sColumnName.IndexOf("(") >= 0 )
										{
											sSQL += sColumnName.Trim() + ControlChars.CrLf;
										}
										else
										{
											sSQL += sVIEW_NAME + "." + sColumnName.Trim() + ControlChars.CrLf;
										}
									}
									// 05/21/2017 Paul.  HTML5 Dashboard requires aggregates. 
									if ( arrAGGREGATE != null && arrAGGREGATE.Count > 0 )
									{
										foreach ( string sAggregate in arrAGGREGATE )
										{
											AddAggregate(ref sSQL, sVIEW_NAME, sAggregate);
										}
									}
								}
								else
								{
									// 05/21/2017 Paul.  HTML5 Dashboard requires aggregates. 
									if ( arrAGGREGATE != null && arrAGGREGATE.Count > 0 )
									{
										foreach ( string sAggregate in arrAGGREGATE )
										{
											AddAggregate(ref sSQL, sVIEW_NAME, sAggregate);
										}
									}
									else
									{
										sSQL = "select " + sVIEW_NAME + ".*" + ControlChars.CrLf;
										// 12/05/2019 Paul.  We need to enable favorites for React Client. 
										if ( !bArchiveView && enumAccessMode == AccessMode.view )
										{
											if ( !Sql.ToBoolean(Application["CONFIG.disable_favorites"]) )
											{
												sSQL += "     , FAVORITE_RECORD_ID" + ControlChars.CrLf;
											}
											// 02/07/2022 Paul.  Correct case of disable_following. 
											if ( !Sql.ToBoolean(Application["CONFIG.disable_following"]) && Sql.ToBoolean(Application["CONFIG.enable_activity_streams"]) && Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".StreamEnabled"]) )
											{
												sSQL += "     , SUBSCRIPTION_PARENT_ID" + ControlChars.CrLf;
											}
										}
									}
								}
								// 11/20/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
								if ( !Sql.IsEmptyString(sMODULE_NAME_RELATED) )
									sSQL += Sql.AppendRecordLevelSecurityField(sMODULE_NAME_RELATED, "edit", sVIEW_NAME);
								else if ( !Sql.IsEmptyString(sMODULE_NAME) )
									sSQL += Sql.AppendRecordLevelSecurityField(sMODULE_NAME, "edit", sVIEW_NAME);
								// 07/01/2018 Paul.  Add data privacy flag for the module. 
								if ( bIS_DATA_PRIVACY_MODULE )
									sSQL += Sql.AppendDataPrivacyField(sVIEW_NAME);
								// 08/08/2019 Paul.  The SYNC and EXCHANGE flags require a manual and separate join. 
								if ( enumAccessMode == AccessMode.edit || enumAccessMode == AccessMode.view )
								{
									if ( sMODULE_NAME == "Accounts" )
									{
										sSQL += "     , (case when vwACCOUNTS_USERS.ACCOUNT_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf;
									}
									else if ( sMODULE_NAME == "Bugs" )
									{
										sSQL += "     , (case when vwBUGS_USERS.BUG_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf;
									}
									else if ( sMODULE_NAME == "Cases" )
									{
										sSQL += "     , (case when vwCASES_USERS.CASE_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf;
									}
									else if ( sMODULE_NAME == "Contacts" )
									{
										sSQL += "     , (case when vwCONTACTS_USERS.CONTACT_ID          is null then 0 else 1 end) as SYNC_CONTACT   " + ControlChars.CrLf;
										sSQL += "     , (case when vwCONTACTS_USERS_EXCHANGE.CONTACT_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf;
									}
									else if ( sMODULE_NAME == "Leads" )
									{
										sSQL += "     , (case when vwLEADS_USERS.LEAD_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf;
									}
									else if ( sMODULE_NAME == "Opportunities" )
									{
										sSQL += "     , (case when vwOPPORTUNITIES_USERS.OPPORTUNITY_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf;
									}
									else if ( sMODULE_NAME == "Project" )
									{
										sSQL += "     , (case when vwPROJECTS_USERS.PROJECT_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf;
									}
								}
								// 03/24/2020 Paul.  Reports require an additional scheduler join. 
								else if ( enumAccessMode == AccessMode.list )
								{
									if ( sMODULE_NAME == "Reports" || sMODULE_NAME == "ReportDesigner" )
									{
										if ( Crm.Config.WorkflowExists(Application) )
										{
											sSQL += "     , JOB_INTERVAL" + ControlChars.CrLf;
											sSQL += "     , LAST_RUN    " + ControlChars.CrLf;
										}
									}
								}
								
								// 04/21/2017 Paul.  We need to return the total when using nTOP. 
								string sSelectSQL = sSQL;
								// 06/18/2011 Paul.  The REST API tables will use the view properly, so there is no need to join to the CSTM table. 
								sSQL += "  from " + sVIEW_NAME        + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									cmd.CommandTimeout = 0;
									
									// 08/08/2019 Paul.  The SYNC and EXCHANGE flags require a manual and separate join. 
									if ( enumAccessMode == AccessMode.edit || enumAccessMode == AccessMode.view )
									{
										string m_sVIEW_NAME = sVIEW_NAME;
										if ( sMODULE_NAME == "Accounts" )
										{
											cmd.CommandText += ""
											     + "  left outer join vwACCOUNTS_USERS                                     " + ControlChars.CrLf
											     + "               on vwACCOUNTS_USERS.ACCOUNT_ID = " + m_sVIEW_NAME + ".ID" + ControlChars.CrLf
											     + "              and vwACCOUNTS_USERS.USER_ID    = @SYNC_USER_ID          " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@SYNC_USER_ID", Security.USER_ID);
										}
										else if ( sMODULE_NAME == "Bugs" )
										{
											cmd.CommandText += ""
											     + "  left outer join vwBUGS_USERS                                  " + ControlChars.CrLf
											     + "               on vwBUGS_USERS.BUG_ID  = " + m_sVIEW_NAME + ".ID" + ControlChars.CrLf
											     + "              and vwBUGS_USERS.USER_ID = @SYNC_USER_ID          " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@SYNC_USER_ID", Security.USER_ID);
										}
										else if ( sMODULE_NAME == "Cases" )
										{
											cmd.CommandText += ""
											     + "  left outer join vwCASES_USERS                                  " + ControlChars.CrLf
											     + "               on vwCASES_USERS.CASE_ID = " + m_sVIEW_NAME + ".ID" + ControlChars.CrLf
											     + "              and vwCASES_USERS.USER_ID = @SYNC_USER_ID          " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@SYNC_USER_ID", Security.USER_ID);
										}
										else if ( sMODULE_NAME == "Contacts" )
										{
											cmd.CommandText += ""
											     + "  left outer join vwCONTACTS_USERS                                                                  " + ControlChars.CrLf
											     + "               on vwCONTACTS_USERS.CONTACT_ID            = " + m_sVIEW_NAME + ".ID                  " + ControlChars.CrLf
											     + "              and vwCONTACTS_USERS.USER_ID               = @SYNC_USER_ID                            " + ControlChars.CrLf
											     + "              and vwCONTACTS_USERS.SERVICE_NAME is null                                             " + ControlChars.CrLf
											     + "  left outer join vwCONTACTS_USERS                         vwCONTACTS_USERS_EXCHANGE                " + ControlChars.CrLf
											     + "               on vwCONTACTS_USERS_EXCHANGE.CONTACT_ID   = " + m_sVIEW_NAME + ".ID                  " + ControlChars.CrLf
											     + "              and vwCONTACTS_USERS_EXCHANGE.USER_ID      = @SYNC_USER_ID                            " + ControlChars.CrLf
											     + "              and vwCONTACTS_USERS_EXCHANGE.SERVICE_NAME = N'Exchange'                              " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@SYNC_USER_ID", Security.USER_ID);
										}
										else if ( sMODULE_NAME == "Leads" )
										{
											cmd.CommandText += ""
											     + "  left outer join vwLEADS_USERS                                  " + ControlChars.CrLf
											     + "               on vwLEADS_USERS.LEAD_ID = " + m_sVIEW_NAME + ".ID" + ControlChars.CrLf
											     + "              and vwLEADS_USERS.USER_ID = @SYNC_USER_ID          " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@SYNC_USER_ID", Security.USER_ID);
										}
										else if ( sMODULE_NAME == "Opportunities" )
										{
											cmd.CommandText += ""
											     + "  left outer join vwOPPORTUNITIES_USERS                                         " + ControlChars.CrLf
											     + "               on vwOPPORTUNITIES_USERS.OPPORTUNITY_ID = " + m_sVIEW_NAME + ".ID" + ControlChars.CrLf
											     + "              and vwOPPORTUNITIES_USERS.USER_ID        = @SYNC_USER_ID          " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@SYNC_USER_ID", Security.USER_ID);
										}
										else if ( sMODULE_NAME == "Project" )
										{
											cmd.CommandText += ""
											     + "  left outer join vwPROJECTS_USERS                                     " + ControlChars.CrLf
											     + "               on vwPROJECTS_USERS.PROJECT_ID = " + m_sVIEW_NAME + ".ID" + ControlChars.CrLf
											     + "              and vwPROJECTS_USERS.USER_ID    = @SYNC_USER_ID          " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@SYNC_USER_ID", Security.USER_ID);
										}
									}
									// 03/24/2020 Paul.  Reports require an additional scheduler join. 
									else if ( enumAccessMode == AccessMode.list )
									{
										if ( sMODULE_NAME == "Reports" || sMODULE_NAME == "ReportDesigner" )
										{
											if ( Crm.Config.WorkflowExists(Application) )
											{
												cmd.CommandText += "  left outer join (select JOB_INTERVAL, LAST_RUN, PARENT_ID from vwWORKFLOWS) WORKFLOWS" + ControlChars.CrLf
												                +  "               on WORKFLOWS.PARENT_ID = ID                                             " + ControlChars.CrLf;
											}
										}
									}
									// 09/22/2019 Paul.  Add support for Favorites and Stream Subscriptions. 
									// 10/11/2019 Paul.  arrSELECT will be null for DetailView and EditView. 
									if ( arrSELECT != null )
									{
										// 10/28/2019 Paul.  The My Favorite dashlets already join to vwSUGARFAVORITES. 
										if ( arrSELECT.Contains("FAVORITE_RECORD_ID") && !cmd.CommandText.Contains("SUGARFAVORITES") )
										{
											cmd.CommandText += "  left outer join vwSUGARFAVORITES                                       " + ControlChars.CrLf;
											cmd.CommandText += "               on vwSUGARFAVORITES.FAVORITE_RECORD_ID = ID               " + ControlChars.CrLf;
											cmd.CommandText += "              and vwSUGARFAVORITES.FAVORITE_USER_ID   = @FAVORITE_USER_ID" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@FAVORITE_USER_ID", Security.USER_ID);
										}
										if ( arrSELECT.Contains("SUBSCRIPTION_PARENT_ID") )
										{
											cmd.CommandText += "  left outer join vwSUBSCRIPTIONS                                               " + ControlChars.CrLf;
											cmd.CommandText += "               on vwSUBSCRIPTIONS.SUBSCRIPTION_PARENT_ID = ID                   " + ControlChars.CrLf;
											cmd.CommandText += "              and vwSUBSCRIPTIONS.SUBSCRIPTION_USER_ID   = @SUBSCRIPTION_USER_ID" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@SUBSCRIPTION_USER_ID", Security.USER_ID);
										}
									}
									else
									{
										// 12/05/2019 Paul.  We need to enable favorites for React Client. 
										if ( !bArchiveView && enumAccessMode == AccessMode.view )
										{
											if ( !Sql.ToBoolean(Application["CONFIG.disable_favorites"]) && !cmd.CommandText.Contains("SUGARFAVORITES") )
											{
												cmd.CommandText += "  left outer join vwSUGARFAVORITES                                       " + ControlChars.CrLf;
												cmd.CommandText += "               on vwSUGARFAVORITES.FAVORITE_RECORD_ID = ID               " + ControlChars.CrLf;
												cmd.CommandText += "              and vwSUGARFAVORITES.FAVORITE_USER_ID   = @FAVORITE_USER_ID" + ControlChars.CrLf;
												Sql.AddParameter(cmd, "@FAVORITE_USER_ID", Security.USER_ID);
											}
											// 02/07/2022 Paul.  Correct case of disable_following. 
											if ( !Sql.ToBoolean(Application["CONFIG.disable_following"]) && Sql.ToBoolean(Application["CONFIG.enable_activity_streams"]) && Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".StreamEnabled"]) )
											{
												cmd.CommandText += "  left outer join vwSUBSCRIPTIONS                                               " + ControlChars.CrLf;
												cmd.CommandText += "               on vwSUBSCRIPTIONS.SUBSCRIPTION_PARENT_ID = ID                   " + ControlChars.CrLf;
												cmd.CommandText += "              and vwSUBSCRIPTIONS.SUBSCRIPTION_USER_ID   = @SUBSCRIPTION_USER_ID" + ControlChars.CrLf;
												Sql.AddParameter(cmd, "@SUBSCRIPTION_USER_ID", Security.USER_ID);
											}
										}
									}
									// 10/27/2009 Paul.  Apply the standard filters. 
									// 11/03/2009 Paul.  Relationship tables will not have Team or Assigned fields. 
									if ( bIS_RELATIONSHIP )
									{
										cmd.CommandText += " where 1 = 1" + ControlChars.CrLf;
										// 11/06/2009 Paul.  Use the relationship table to get the module information. 
										DataView vwRelationships = new DataView(SplendidCache.ReportingRelationships(Context.Application));
										vwRelationships.RowFilter = "(JOIN_TABLE = '" + sTABLE_NAME + "' and RELATIONSHIP_TYPE = 'many-to-many') or (RHS_TABLE = '" + sTABLE_NAME + "' and RELATIONSHIP_TYPE = 'one-to-many')";
										if ( vwRelationships.Count > 0 )
										{
											foreach ( DataRowView rowRelationship in vwRelationships )
											{
												string sJOIN_KEY_LHS             = Sql.ToString(rowRelationship["JOIN_KEY_LHS"            ]).ToUpper();
												string sJOIN_KEY_RHS             = Sql.ToString(rowRelationship["JOIN_KEY_RHS"            ]).ToUpper();
												string sLHS_MODULE               = Sql.ToString(rowRelationship["LHS_MODULE"              ]);
												string sRHS_MODULE               = Sql.ToString(rowRelationship["RHS_MODULE"              ]);
												string sLHS_TABLE                = Sql.ToString(rowRelationship["LHS_TABLE"               ]).ToUpper();
												string sRHS_TABLE                = Sql.ToString(rowRelationship["RHS_TABLE"               ]).ToUpper();
												string sLHS_KEY                  = Sql.ToString(rowRelationship["LHS_KEY"                 ]).ToUpper();
												string sRHS_KEY                  = Sql.ToString(rowRelationship["RHS_KEY"                 ]).ToUpper();
												string sRELATIONSHIP_TYPE        = Sql.ToString(rowRelationship["RELATIONSHIP_TYPE"       ]);
												string sRELATIONSHIP_ROLE_COLUMN = Sql.ToString(rowRelationship["RELATIONSHIP_ROLE_COLUMN"]).ToUpper();
												sJOIN_KEY_LHS = r.Replace(sJOIN_KEY_LHS, String.Empty);
												sJOIN_KEY_RHS = r.Replace(sJOIN_KEY_RHS, String.Empty);
												sLHS_MODULE   = r.Replace(sLHS_MODULE  , String.Empty);
												sRHS_MODULE   = r.Replace(sRHS_MODULE  , String.Empty);
												sLHS_TABLE    = r.Replace(sLHS_TABLE   , String.Empty);
												sRHS_TABLE    = r.Replace(sRHS_TABLE   , String.Empty);
												sLHS_KEY      = r.Replace(sLHS_KEY     , String.Empty);
												sRHS_KEY      = r.Replace(sRHS_KEY     , String.Empty);
												if ( sRELATIONSHIP_TYPE == "many-to-many" )
												{
													cmd.CommandText += "   and " + sJOIN_KEY_LHS + " in " + ControlChars.CrLf;
													cmd.CommandText += "(select " + sLHS_KEY + " from " + sLHS_TABLE + ControlChars.CrLf;
													Security.Filter(cmd, sLHS_MODULE, "list");
													cmd.CommandText += ")" + ControlChars.CrLf;
													
													// 11/12/2009 Paul.  We don't want to deal with relationships to multiple tables, so just ignore for now. 
													if ( sRELATIONSHIP_ROLE_COLUMN != "RELATED_TYPE" )
													{
														cmd.CommandText += "   and " + sJOIN_KEY_RHS + " in " + ControlChars.CrLf;
														cmd.CommandText += "(select " + sRHS_KEY + " from " + sRHS_TABLE + ControlChars.CrLf;
														Security.Filter(cmd, sRHS_MODULE, "list");
														cmd.CommandText += ")" + ControlChars.CrLf;
													}
												}
												else if ( sRELATIONSHIP_TYPE == "one-to-many" )
												{
													cmd.CommandText += "   and " + sRHS_KEY + " in " + ControlChars.CrLf;
													cmd.CommandText += "(select " + sLHS_KEY + " from " + sLHS_TABLE + ControlChars.CrLf;
													Security.Filter(cmd, sLHS_MODULE, "list");
													cmd.CommandText += ")" + ControlChars.CrLf;
												}
											}
										}
										else
										{
											// 11/12/2009 Paul.  EMAIL_IMAGES is a special table that is related to EMAILS or KBDOCUMENTS. 
											if ( sTABLE_NAME == "EMAIL_IMAGES" )
											{
												// 11/12/2009 Paul.  There does not appear to be an easy way to filter the EMAIL_IMAGES table. 
												// For now, just return the EMAIL related images. 
												cmd.CommandText += "   and PARENT_ID in " + ControlChars.CrLf;
												cmd.CommandText += "(select ID from EMAILS" + ControlChars.CrLf;
												Security.Filter(cmd, "Emails", "list");
												cmd.CommandText += "union all" + ControlChars.CrLf;
												cmd.CommandText += "select ID from KBDOCUMENTS" + ControlChars.CrLf;
												Security.Filter(cmd, "KBDocuments", "list");
												cmd.CommandText += ")" + ControlChars.CrLf;
											}
											// 11/06/2009 Paul.  If the relationship is not in the RELATIONSHIPS table, then try and build it manually. 
											// 11/05/2009 Paul.  We cannot use the standard filter on the Teams table (or TeamNotices). 
											else if ( !Sql.IsEmptyString(sMODULE_NAME) && !sMODULE_NAME.StartsWith("Team") )
											{
												// 11/05/2009 Paul.  We could query the foreign key tables to perpare the filters, but that is slow. 
												string sMODULE_TABLE_NAME   = Sql.ToString(Context.Application["Modules." + sMODULE_NAME + ".TableName"]).ToUpper();
												if ( !Sql.IsEmptyString(sMODULE_TABLE_NAME) )
												{
													// 06/04/2011 Paul.  New function to get the singular name. 
													string sMODULE_FIELD_ID = Crm.Modules.SingularTableName(sMODULE_TABLE_NAME) + "_ID";
													
													cmd.CommandText += "   and " + sMODULE_FIELD_ID + " in " + ControlChars.CrLf;
													// 03/30/2016 Paul.  Corporate database does not provide direct access to tables.  Must use view. 
													cmd.CommandText += "(select ID from " + (sMODULE_TABLE_NAME.Substring(0, 2).ToUpper() == "VW" ? sMODULE_TABLE_NAME : "vw" + sMODULE_TABLE_NAME) + ControlChars.CrLf;
													Security.Filter(cmd, sMODULE_NAME, "list");
													// 11/11/2020 Paul.  In ArchiveView, the related data may also be archived. 
													if ( bArchiveView )
													{
														string sMODULE_VIEW = (sMODULE_TABLE_NAME.Substring(0, 2).ToUpper() == "VW" ? sMODULE_TABLE_NAME : "vw" + sMODULE_TABLE_NAME);
														if ( Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".ArchiveEnabled"]) && SplendidCache.ArchiveViewExists(sMODULE_VIEW) )
														{
															string sARCHIVE_VIEW = sMODULE_VIEW + "_ARCHIVE";
															cmd.CommandText += "union all" + ControlChars.CrLf;
															cmd.CommandText += "select ID from " + sARCHIVE_VIEW + ControlChars.CrLf;
															Security.Filter(cmd, sMODULE_NAME, "list");
														}
													}
													cmd.CommandText += ")" + ControlChars.CrLf;
												}
											}
											// 11/05/2009 Paul.  We cannot use the standard filter on the Teams table. 
											if ( !Sql.IsEmptyString(sMODULE_NAME_RELATED) && !sMODULE_NAME_RELATED.StartsWith("Team") )
											{
												string sMODULE_TABLE_RELATED = Sql.ToString(Context.Application["Modules." + sMODULE_NAME_RELATED + ".TableName"]).ToUpper();
												if ( !Sql.IsEmptyString(sMODULE_TABLE_RELATED) )
												{
													// 06/04/2011 Paul.  New function to get the singular name. 
													string sMODULE_RELATED_ID = Crm.Modules.SingularTableName(sMODULE_TABLE_RELATED) + "_ID";
													
													// 11/05/2009 Paul.  Some tables use ASSIGNED_USER_ID as the relationship ID instead of the USER_ID. 
													if ( sMODULE_RELATED_ID == "USER_ID" && !Sql.IsEmptyString(sASSIGNED_FIELD_NAME) )
														sMODULE_RELATED_ID = sASSIGNED_FIELD_NAME;
													
													cmd.CommandText += "   and " + sMODULE_RELATED_ID + " in " + ControlChars.CrLf;
													// 03/30/2016 Paul.  Corporate database does not provide direct access to tables.  Must use view. 
													cmd.CommandText += "(select ID from " + (sMODULE_TABLE_RELATED.Substring(0, 2).ToUpper() == "VW" ? sMODULE_TABLE_RELATED : "vw" + sMODULE_TABLE_RELATED)  + ControlChars.CrLf;
													Security.Filter(cmd, sMODULE_NAME_RELATED, "list");
													// 11/11/2020 Paul.  In ArchiveView, the related data may also be archived. 
													if ( bArchiveView )
													{
														string sMODULE_VIEW = (sMODULE_TABLE_RELATED.Substring(0, 2).ToUpper() == "VW" ? sMODULE_TABLE_RELATED : "vw" + sMODULE_TABLE_RELATED);
														if ( Sql.ToBoolean(Application["Modules." + sMODULE_NAME_RELATED + ".ArchiveEnabled"]) && SplendidCache.ArchiveViewExists(sMODULE_VIEW) )
														{
															string sARCHIVE_VIEW = sMODULE_VIEW + "_ARCHIVE";
															cmd.CommandText += "union all" + ControlChars.CrLf;
															cmd.CommandText += "select ID from " + sARCHIVE_VIEW + ControlChars.CrLf;
															Security.Filter(cmd, sMODULE_NAME_RELATED, "list");
														}
													}
													cmd.CommandText += ")" + ControlChars.CrLf;
												}
											}
										}
									}
									// 09/18/2017 Paul.  Allow team hierarchy. 
									else if ( sTABLE_NAME == "TEAMS" )
									{
										if ( SplendidCRM.Security.AdminUserAccess("Teams", "list") >= 0 )
										{
											Security.Filter(cmd, sMODULE_NAME, "view");
										}
										else if ( !Crm.Config.enable_team_hierarchy() )
										{
											cmd.CommandText += " inner join vwTEAM_MEMBERSHIPS" + ControlChars.CrLf;
											// 08/09/2019 Paul.  We need a ListView and EditView flags for the Rest Client. 
											cmd.CommandText += "         on vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID = " + sVIEW_NAME + ".ID" + ControlChars.CrLf;
											cmd.CommandText += "        and vwTEAM_MEMBERSHIPS.MEMBERSHIP_USER_ID = @MEMBERSHIP_USER_ID" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@MEMBERSHIP_USER_ID", Security.USER_ID);
										}
										else
										{
											if ( Sql.IsOracle(con) )
											{
												cmd.CommandText += " inner join table(fnTEAM_HIERARCHY_MEMBERSHIPS(@MEMBERSHIP_USER_ID)) vwTEAM_MEMBERSHIPS" + ControlChars.CrLf;
												// 08/09/2019 Paul.  We need a ListView and EditView flags for the Rest Client. 
												cmd.CommandText += "               on vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID = " + sVIEW_NAME + ".ID" + ControlChars.CrLf;
											}
											else
											{
												string fnPrefix = (Sql.IsSQLServer(con) ? "dbo." : String.Empty);
												cmd.CommandText += " inner join " + fnPrefix + "fnTEAM_HIERARCHY_MEMBERSHIPS(@MEMBERSHIP_USER_ID) vwTEAM_MEMBERSHIPS" + ControlChars.CrLf;
												// 08/09/2019 Paul.  We need a ListView and EditView flags for the Rest Client. 
												cmd.CommandText += "               on vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID = " + sVIEW_NAME + ".ID" + ControlChars.CrLf;
											}
											cmd.CommandText += " where 1 = 1       " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@MEMBERSHIP_USER_ID", Security.USER_ID);
										}
									}
									// 08/04/2019 Paul.  vwEMAILMAN_List is associated with the Campaigns module, but does not have the fields. 
									else if ( sTABLE_NAME == "vwEMAILMAN_List" )
									{
										cmd.CommandText += " where CAMPAIGN_ID in (select ID from vwCAMPAIGNS" + ControlChars.CrLf;
										Security.Filter(cmd, "Campaigns", "list");
										cmd.CommandText += ")" + ControlChars.CrLf;
									}
									else
									{
										// 12/03/2019 Paul.  The React Client needs access to archive data. 
										// 12/03/2019 Paul.  By now, the view name already has ARCHIVE at the end. 
										if ( bArchiveView && sVIEW_NAME.EndsWith("_ARCHIVE") )
										{
											Security.Filter(cmd, sMODULE_NAME, "archive");
										}
										else if ( enumAccessMode == AccessMode.edit )
										{
											Security.Filter(cmd, sMODULE_NAME, "edit");
										}
										// 04/22/2020 Paul.  Separate list mode from view mode. 
										else if ( enumAccessMode == AccessMode.list )
										{
											Security.Filter(cmd, sMODULE_NAME, "list");
										}
										else
										{
											// 02/14/2010 Paul.  GetTable should only require read-only access. 
											// We were previously requiring Edit access, but that seems to be a high bar. 
											Security.Filter(cmd, sMODULE_NAME, "view");
										}
									}
									// 02/29/2016 Paul.  Special fix for product catalog. 
									if ( sTABLE_NAME == "PRODUCT_CATALOG" )
									{
										if ( Sql.ToBoolean(Application["CONFIG.ProductCatalog.EnableOptions"]) )
										{
											cmd.CommandText += "   and (   PARENT_ID is null" + ControlChars.CrLf;
											cmd.CommandText += "        or PARENT_ID in (select ID" + ControlChars.CrLf;
											cmd.CommandText += "                           from " + Sql.MetadataName(cmd, "vwPRODUCT_TEMPLATES_OptionsCatalog") + ControlChars.CrLf;
											Security.Filter(cmd, sMODULE_NAME, "list");
											cmd.CommandText += "                        )" + ControlChars.CrLf;
											cmd.CommandText += "       )" + ControlChars.CrLf;
										}
									}
									if ( !Sql.IsEmptyString(sMODULE_FIELD_NAME) )
									{
										List<string> lstMODULES = AccessibleModules(Context);
										
										if ( sTABLE_NAME == "MODULES" )
										{
											// 11/27/2009 Paul.  Don't filter the MODULES table. It can cause system tables to get deleted. 
											// 11/28/2009 Paul.  Keep the filter on the Modules table, but add the System Sync Tables to the list. 
											// We should make sure that the clients do not get module records for unnecessary or disabled modules. 
											Sql.AppendParameter(cmd, lstMODULES.ToArray(), sMODULE_FIELD_NAME);
											// 10/09/2012 Paul.  We need to make sure to only return modules that are available to REST. 
											cmd.CommandText += "   and MODULE_NAME in (select MODULE_NAME from vwSYSTEM_REST_TABLES)" + ControlChars.CrLf;
										}
										else if ( nMODULE_SPECIFIC == 1 )
										{
											Sql.AppendParameter(cmd, lstMODULES.ToArray(), sMODULE_FIELD_NAME);
										}
										else if ( nMODULE_SPECIFIC == 2 )
										{
											// 04/05/2012 Paul.  AppendLikeModules is a special like that assumes that the search is for a module related value 
											Sql.AppendLikeModules(cmd, lstMODULES.ToArray(), sMODULE_FIELD_NAME);
										}
										else if ( nMODULE_SPECIFIC == 3 )
										{
											cmd.CommandText += "   and ( 1 = 0" + ControlChars.CrLf;
											cmd.CommandText += "         or " + sMODULE_FIELD_NAME + " is null" + ControlChars.CrLf;
											// 11/02/2009 Paul.  There are a number of terms with undefined modules. 
											// ACL, ACLActions, Audit, Config, Dashlets, DocumentRevisions, Export, Merge, Roles, SavedSearch, Teams
											cmd.CommandText += "     ";
											Sql.AppendParameter(cmd, lstMODULES.ToArray(), sMODULE_FIELD_NAME, true);
											cmd.CommandText += "       )" + ControlChars.CrLf;
										}
										// 11/22/2009 Paul.  Make sure to only send the selected user language.  This will dramatically reduce the amount of data. 
										//if ( sTABLE_NAME == "TERMINOLOGY" || sTABLE_NAME == "TERMINOLOGY_HELP" )
										//{
										//	cmd.CommandText += "   and LANG in ('en-US', @LANG)" + ControlChars.CrLf;
										//	string sCULTURE  = Sql.ToString(Session["USER_SETTINGS/CULTURE" ]);
										//	Sql.AddParameter(cmd, "@LANG", sCULTURE);
										//}
									}
									// 05/25/2017 Paul.  arrITEMS may be empty. 
									if ( arrITEMS != null && arrITEMS.Length > 0 )
									{
										// 11/13/2009 Paul.  If a list of items is provided, then the max records field is ignored. 
										nSKIP = 0;
										nTOP = -1;
										Sql.AppendGuids(cmd, arrITEMS, "ID");
									}
									else if ( sTABLE_NAME == "IMAGES" )
									{
										// 02/14/2010 Paul.  There is no easy way to filter IMAGES table, so we are simply going to fetch 
										// images that the user has created.  Otherwise, images that are accessible to the user will 
										// need to be retrieved by ID.
										Sql.AppendParameter(cmd, Security.USER_ID, "CREATED_BY");
									}
									// 06/18/2011 Paul.  Tables that are filtered by user should have an explicit filter added. 
									// 09/13/2019 Paul.  The React Client will need to allow and admin to view user data.  The React Client will still provide the USER_ID. 
									if ( sASSIGNED_FIELD_NAME == "USER_ID" && !(Security.IS_ADMIN || Security.AdminUserAccess("Users", "view") >= 0) )
									{
										Sql.AppendParameter(cmd, Security.USER_ID, "USER_ID");
									}
									// 05/15/2017 Paul.  Just started using IS_ASSIGNED flag. 
									else if ( bIS_ASSIGNED && sASSIGNED_FIELD_NAME == "PARENT_ASSIGNED_USER_ID" )
									{
										Sql.AppendParameter(cmd, Security.USER_ID, "PARENT_ASSIGNED_USER_ID");
									}
									// 10/04/2020 Paul.  The React Client needs access to users for assigned to selection. 
									else if ( bIS_ASSIGNED && sASSIGNED_FIELD_NAME == "MEMBERSHIP_USER_ID" )
									{
										Sql.AppendParameter(cmd, Security.USER_ID, "MEMBERSHIP_USER_ID");
									}
									if ( !Sql.IsEmptyString(sFILTER) )
									{
										// 03/06/2019 Paul.  Move ConvertODataFilter to Sql so that it can be used in the Admin REST API. 
										// 04/01/2020 Paul.  Move json utils to RestUtil. 
										string sSQL_FILTER = RestUtil.ConvertODataFilter(sFILTER, cmd);
										cmd.CommandText += "   and (" + sSQL_FILTER + ")" + ControlChars.CrLf;
										// 08/02/2019 Paul.  The React Client will need access to views that require a filter, like CAMPAIGN_ID. 
										if ( !Sql.IsEmptyString(sREQUIRED_FIELDS) )
										{
											// 07/05/2021 Paul.  Allow comma as separator. 
											string[] arrREQUIRED_FIELDS = sREQUIRED_FIELDS.ToUpper().Replace(",", " ").Split(' ');
											string sSQL_FILTER_NORMALIZED = sSQL_FILTER.ToUpper().Replace(" ", "");
											string sMISSING_FIELDS = String.Empty;
											foreach ( string sREQUIRED_FIELD in arrREQUIRED_FIELDS )
											{
												if ( !sSQL_FILTER_NORMALIZED.Contains(sREQUIRED_FIELD + "=") )
												{
													if ( !Sql.IsEmptyString(sMISSING_FIELDS) )
														sMISSING_FIELDS += " ";
													sMISSING_FIELDS += sREQUIRED_FIELD;
												}
											}
											if ( !Sql.IsEmptyString(sMISSING_FIELDS) )
											{
												throw(new Exception("Missing required fields: " + sMISSING_FIELDS));
											}
										}
									}
									// 08/02/2019 Paul.  The React Client will need access to views that require a filter, like CAMPAIGN_ID. 
									else if ( !Sql.IsEmptyString(sREQUIRED_FIELDS) )
									{
										throw(new Exception("Missing required fields: " + sREQUIRED_FIELDS));
									}
									// 06/17/2013 Paul.  Add support for GROUP BY. 
									if ( !Sql.IsEmptyString(sGROUP_BY) )
									{
										// 06/18/2011 Paul.  Allow a comma in a sort expression. 
										r = new Regex(@"[^A-Za-z0-9_, ]");
										sGROUP_BY = " group by " + r.Replace(sGROUP_BY, "") + ControlChars.CrLf;
									}
									// 10/27/2015 Paul.  The HTML5 code uses encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION), so if both values are blank, we will get a string with a single space. 
									// 02/13/2018 Paul.  Order By must follow Group By. 
									if ( Sql.IsEmptyString(sORDER_BY.Trim()) )
									{
										sORDER_BY = " order by " + sVIEW_NAME + ".DATE_MODIFIED_UTC" + ControlChars.CrLf;
									}
									else
									{
										// 06/18/2011 Paul.  Allow a comma in a sort expression. 
										r = new Regex(@"[^A-Za-z0-9_, ]");
										sORDER_BY = " order by " + r.Replace(sORDER_BY, "") + ControlChars.CrLf;
									}
									//cmd.CommandText += sORDER_BY;
									//Debug.WriteLine(Sql.ExpandParameters(cmd));// 03/20/2012 Paul.  Nolonger need to debug these SQL statements. 
//#if DEBUG
//									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), Sql.ExpandParameters(cmd));
//#endif
									// 09/09/2019 Paul.  Send duplicate filter info. 
									string sDUPLICATE_FILTER = String.Empty;
									if ( !Sql.IsEmptyString(sDUPLICATE_FIELDS) )
									{
										string sEDIT_VIEW = sVIEW_NAME;
										if ( dtSYNC_TABLES.Columns.Contains("EDIT_VIEW") )
										{
											if ( !Sql.IsEmptyString(rowSYNC_TABLE["EDIT_VIEW"]) )
												sEDIT_VIEW = Sql.ToString(rowSYNC_TABLE["EDIT_VIEW"]);
										}

										r = new Regex(@"[^A-Za-z0-9_]");
										string[] arrDUPLICATE_FIELDS = sDUPLICATE_FIELDS.Split(',');
										for ( int i = 0; i < arrDUPLICATE_FIELDS.Length; i++ )
										{
											arrDUPLICATE_FIELDS[i] = r.Replace(arrDUPLICATE_FIELDS[i], "");
										}

										StringBuilder sb = new StringBuilder();
										sb.AppendLine("   and ID in ");
										sb.AppendLine("(");
										sb.AppendLine("select ID");
										sb.AppendLine("  from " + sEDIT_VIEW + " " + sTABLE_NAME);
										sb.AppendLine(" inner join (select " + String.Join(", ", arrDUPLICATE_FIELDS));
										sb.AppendLine("               from " + sEDIT_VIEW);
										sb.AppendLine("              group by " + String.Join(", ", arrDUPLICATE_FIELDS));
										sb.AppendLine("              having count(*) >= 2) DUPS");
										for ( int i = 0; i < arrDUPLICATE_FIELDS.Length; i++ )
										{
											if ( i == 0 )
												sb.Append("         on ");
											else
												sb.Append("        and ");
											sb.AppendLine("DUPS." + arrDUPLICATE_FIELDS[i] + " = " + sTABLE_NAME + "." + arrDUPLICATE_FIELDS[i]);
										}
										sb.AppendLine(") ");
										sDUPLICATE_FILTER = sb.ToString();
									}
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										// 11/08/2009 Paul.  The table name is required in order to serialize the DataTable. 
										dt = new DataTable(sTABLE_NAME);
										if ( nTOP > 0 )
										{
											lTotalCount = -1;
											// 04/21/2017 Paul.  We need to return the total when using nTOP. 
											//string sSelectSQL = sSQL;
											if ( cmd.CommandText.StartsWith(sSelectSQL) )
											{
												string sOriginalSQL = cmd.CommandText;
												cmd.CommandText = "select count(*) " + ControlChars.CrLf + cmd.CommandText.Substring(sSelectSQL.Length);
												// 09/09/2019 Paul.  Send duplicate filter info. 
												cmd.CommandText += sDUPLICATE_FILTER;
												sLastCommand += Sql.ExpandParameters(cmd) + ';' + ControlChars.CrLf;
												lTotalCount = Sql.ToLong(cmd.ExecuteScalar());
												cmd.CommandText = sOriginalSQL;
											}
											// 09/09/2019 Paul.  Send duplicate filter info. 
											cmd.CommandText += sDUPLICATE_FILTER;
											// 02/16/2020 Paul.  Always build the paginated result ourselves to match ASP.NET code. 
											if ( nSKIP > 0 || Sql.IsEmptyString(sGROUP_BY) )
											{
												int nCurrentPageIndex = nSKIP / nTOP;
												// 06/17/2103 Paul.  We cannot page a group result. 
												Sql.PageResults(cmd, sTABLE_NAME, sORDER_BY, nCurrentPageIndex, nTOP);
												// 05/19/2018 Paul.  Capture the last command for error tracking. 
												sLastCommand += Sql.ExpandParameters(cmd);
												da.Fill(dt);
											}
											else
											{
												// 06/17/2013 Paul.  Add support for GROUP BY. 
												cmd.CommandText += sGROUP_BY + sORDER_BY;
												using ( DataSet ds = new DataSet() )
												{
													ds.Tables.Add(dt);
													// 05/19/2018 Paul.  Capture the last command for error tracking. 
													sLastCommand = Sql.ExpandParameters(cmd);
													da.Fill(ds, 0, nTOP, sTABLE_NAME);
												}
											}
										}
										else
										{
											// 06/17/2013 Paul.  Add support for GROUP BY. 
											// 09/09/2019 Paul.  Send duplicate filter info. 
											cmd.CommandText += sDUPLICATE_FILTER + sGROUP_BY + sORDER_BY;
											// 05/19/2018 Paul.  Capture the last command for error tracking. 
											sLastCommand = Sql.ExpandParameters(cmd);
											da.Fill(dt);
											// 04/21/2017 Paul.  We need to return the total when using nTOP. 
											lTotalCount = dt.Rows.Count;
										}
										// 06/06/2017 Paul.  Make it easy to dump the SQL. 
										// 10/26/2019 Paul.  Return the SQL to the React Client. 
										// 02/16/2020 Paul.  Use existing last command to include pagination. 
										sbDumpSQL.Append(sLastCommand);
#if DEBUG
										//Debug.WriteLine(sLastCommand);
#endif
										// 02/24/2013 Paul.  Manually add the Calendar entries. 
										if ( sTABLE_NAME == "TERMINOLOGY" && (sFILTER.Contains("MODULE_NAME eq 'Calendar'") || sFILTER.Contains("MODULE_NAME = 'Calendar'")) )
										{
											string sLANG  = Sql.ToString(Session["USER_SETTINGS/CULTURE" ]);
											DataRow row = null;
											row = dt.NewRow();
											row["LANG"        ] = sLANG;
											row["NAME"        ] = "YearMonthPattern";
											row["MODULE_NAME" ] = "Calendar";
											row["DISPLAY_NAME"] = System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.YearMonthPattern;
											dt.Rows.Add(row);
											row = dt.NewRow();
											row["LANG"        ] = sLANG;
											row["NAME"        ] = "MonthDayPattern";
											row["MODULE_NAME" ] = "Calendar";
											row["DISPLAY_NAME"] = System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.MonthDayPattern;
											dt.Rows.Add(row);
											row = dt.NewRow();
											row["LANG"        ] = sLANG;
											row["NAME"        ] = "LongDatePattern";
											row["MODULE_NAME" ] = "Calendar";
											row["DISPLAY_NAME"] = System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.LongDatePattern;
											dt.Rows.Add(row);
											row = dt.NewRow();
											row["LANG"        ] = sLANG;
											row["NAME"        ] = "ShortTimePattern";
											row["MODULE_NAME" ] = "Calendar";
											row["DISPLAY_NAME"] = Sql.ToString(Session["USER_SETTINGS/TIMEFORMAT"]);
											dt.Rows.Add(row);
											row = dt.NewRow();
											row["LANG"        ] = sLANG;
											row["NAME"        ] = "ShortDatePattern";
											row["MODULE_NAME" ] = "Calendar";
											row["DISPLAY_NAME"] = Sql.ToString(Session["USER_SETTINGS/DATEFORMAT"]);
											dt.Rows.Add(row);
											row = dt.NewRow();
											row["LANG"        ] = sLANG;
											row["NAME"        ] = "FirstDayOfWeek";
											row["MODULE_NAME" ] = "Calendar";
											row["DISPLAY_NAME"] = ((int) System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.FirstDayOfWeek).ToString();
											dt.Rows.Add(row);
										}
										// 07/01/2018 Paul.  The Data Privacy module is not returned via the REST API, so we need to simulate the flag. 
										if ( sTABLE_NAME == "CONFIG" )
										{
											DataRow row = null;
											row = dt.NewRow();
											dt.Rows.Add(row);
											row["NAME"        ] = "enable_data_privacy";
											row["VALUE"       ] = Crm.Config.enable_data_privacy();
										}
										// 01/18/2010 Paul.  Apply ACL Field Security. 
										// 02/01/2010 Paul.  System tables may not have a valid Module name, so Field Security will not apply. 
										if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sMODULE_NAME) )
										{
											bool bApplyACL = false;
											bool bASSIGNED_USER_ID_Exists = dt.Columns.Contains("ASSIGNED_USER_ID");
											foreach ( DataRow row in dt.Rows )
											{
												Guid gASSIGNED_USER_ID = Guid.Empty;
												if ( bASSIGNED_USER_ID_Exists )
													gASSIGNED_USER_ID = Sql.ToGuid(row["ASSIGNED_USER_ID"]);
												foreach ( DataColumn col in dt.Columns )
												{
													Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, col.ColumnName, gASSIGNED_USER_ID);
													if ( !acl.IsReadable() )
													{
														row[col.ColumnName] = DBNull.Value;
														bApplyACL = true;
													}
												}
											}
											if ( bApplyACL )
												dt.AcceptChanges();
										}
										if ( sTABLE_NAME == "USERS" )
										{
											// 05/24/2014 Paul.  Provide a way to customize the list of available field names for the Users table. 
											UniqueStringCollection arrUSERS_FIELDS = new UniqueStringCollection();
											string sUSERS_FIELDS = Sql.ToString(Application["CONFIG.rest.Users.Fields"]);
											sUSERS_FIELDS = sUSERS_FIELDS.Replace(",", " ").Trim();
											// 07/04/2020 Paul.  React Client needs access to more User data.  Allow a user to get his own data or allow an admin to get all data. 
											if ( Sql.IsEmptyString(sUSERS_FIELDS) && !bArchiveView && (sVIEW_NAME == "vwUSERS_Sync" || sVIEW_NAME == "vwUSERS_Edit") && (enumAccessMode == AccessMode.edit || enumAccessMode == AccessMode.view) && ((arrITEMS != null && arrITEMS.Length == 1 && arrITEMS[0] == Security.USER_ID) || Security.AdminUserAccess("Users", (enumAccessMode == AccessMode.edit ? "edit" : "view")) >= 0) )
											{
												foreach ( DataRow row in dt.Rows )
												{
													foreach ( DataColumn col in dt.Columns )
													{
														if ( col.ColumnName == "GOOGLEAPPS_PASSWORD" || col.ColumnName == "ICLOUD_PASSWORD" || col.ColumnName == "MAIL_SMTPPASS" )
														{
															if ( !Sql.IsEmptyString(row[col.ColumnName]) )
																row[col.ColumnName] = Sql.sEMPTY_PASSWORD;
														}
													}
												}
											}
											else
											{
												if ( Sql.IsEmptyString(sUSERS_FIELDS) )
												{
													arrUSERS_FIELDS.Add("ID"               );
													arrUSERS_FIELDS.Add("DELETED"          );
													arrUSERS_FIELDS.Add("CREATED_BY"       );
													arrUSERS_FIELDS.Add("DATE_ENTERED"     );
													arrUSERS_FIELDS.Add("MODIFIED_USER_ID" );
													arrUSERS_FIELDS.Add("DATE_MODIFIED"    );
													arrUSERS_FIELDS.Add("DATE_MODIFIED_UTC");
													// 03/17/2020 Paul.  We need to allow the NAME field for CrmModules.ItemName query. 
													arrUSERS_FIELDS.Add("NAME"             );
													arrUSERS_FIELDS.Add("USER_NAME"        );
													arrUSERS_FIELDS.Add("FIRST_NAME"       );
													arrUSERS_FIELDS.Add("LAST_NAME"        );
													arrUSERS_FIELDS.Add("REPORTS_TO_ID"    );
													arrUSERS_FIELDS.Add("EMAIL1"           );
													arrUSERS_FIELDS.Add("STATUS"           );
													arrUSERS_FIELDS.Add("IS_GROUP"         );
													arrUSERS_FIELDS.Add("PORTAL_ONLY"      );
													arrUSERS_FIELDS.Add("EMPLOYEE_STATUS"  );
													// 01/07/2018 Paul.  The default user popup requires FULL_NAME and DEPARTMENT. 
													arrUSERS_FIELDS.Add("FULL_NAME"        );
													arrUSERS_FIELDS.Add("DEPARTMENT"       );
												}
												else
												{
													foreach ( string sField in sUSERS_FIELDS.Split(' ') )
													{
														if ( !Sql.IsEmptyString(sField) )
															arrUSERS_FIELDS.Add(sField.ToUpper());
													}
												}
												// 11/12/2009 Paul.  For the USERS table, we are going to limit the data return to the client. 
												foreach ( DataRow row in dt.Rows )
												{
													if ( Sql.ToGuid(row["ID"]) != Security.USER_ID )
													{
														foreach ( DataColumn col in dt.Columns )
														{
															// 11/12/2009 Paul.  Allow auditing fields and basic user info. 
															if ( !arrUSERS_FIELDS.Contains(col.ColumnName) )
															{
																row[col.ColumnName] = DBNull.Value;
															}
														}
													}
												}
												dt.AcceptChanges();
											}
										}
										// 07/08/2020 Paul.  We need to prevent passwords from being returned from API. 
										else if ( sTABLE_NAME == "CONTACTS" )
										{
											foreach ( DataRow row in dt.Rows )
											{
												foreach ( DataColumn col in dt.Columns )
												{
													if ( col.ColumnName == "PORTAL_PASSWORD" )
													{
														if ( !Sql.IsEmptyString(row[col.ColumnName]) )
															row[col.ColumnName] = Sql.sEMPTY_PASSWORD;
													}
												}
											}
											dt.AcceptChanges();
										}
									}
								}
							}
							else
							{
								// 08/02/2019 Paul.  We want to see the error in the React Client. 
								string sMessage = sTABLE_NAME + " cannot be accessed.";
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), sMessage);
								throw(new Exception(sMessage));
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				// 12/01/2012 Paul.  We need a more descriptive error message. 
				//SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				string sMessage = "GetTable(" + sTABLE_NAME + ", " + sFILTER + ", " + sORDER_BY + ") " + ex.Message;
				SplendidError.SystemMessage("Error", new StackTrace(true).GetFrame(0), sMessage);
				// 05/19/2018 Paul.  Capture the last command for error tracking. 
				if ( ex.Message.Contains("The server supports a maximum of 2100 parameters") )
					SplendidError.SystemMessage("Error", new StackTrace(true).GetFrame(0), sLastCommand);
				throw(new Exception(sMessage));
			}
			return dt;
		}

		private static void PostprocessAdminTable(string sTABLE_NAME, DataTable dt)
		{
			if ( sTABLE_NAME == "CONFIG" )
			{
				foreach ( DataRow row in dt.Rows )
				{
					string sNAME = Sql.ToString(row["NAME"]).ToLower();
					// 11/02/2019 Paul.  It think it would be helpful to show the user name. 
					if ( sNAME.Contains("password"      )
						|| sNAME.Contains("smtppass"    )
						//|| sNAME.Contains("smtpuser"    )
						//|| sNAME.Contains("username"    )
						|| sNAME.Contains("login"       )
						|| sNAME.Contains("token"       )
						|| sNAME.Contains("key"         )
						|| sNAME.Contains("appid"       )
						|| sNAME.Contains("api"         )
						|| sNAME.Contains("secret"      )
						// 11/06/2019 Paul.  The ClientId is needed to authorize. 
						//|| sNAME.Contains("clientid"    )
						|| sNAME.Contains("certificate" )
						|| sNAME.Contains("x509"        )
						// 11/08/2019 Paul.  No reason to hide the expired date. 
						|| (sNAME.Contains("oauth"       ) && !sNAME.Contains("oauthexpiresat") && !sNAME.Contains("oauthscope"))
						|| sNAME.Contains("creditcard"  )
						|| sNAME.Contains("inboundemail")
						// 11/12/2019 Paul.  Show the twilio AccountsId. 
						//|| sNAME.Contains("accountsid"  )
						)
					{
						// 04/08/2019 Paul.  Exceptions to the security values. 
						// 10/27/2019 Paul.  Password manager values are not confidential.  We need to be able to see in order to edit. 
						// 06/19/2023 Paul.  Twilio.LogInboundMessages looks like "login". 
						if ( !sNAME.Contains("logincomingmissedcalls") && !sNAME.Contains("loginboundmessages") && !Sql.ToString(row["NAME"]).StartsWith("Password.") )
						{
							string sVALUE = Sql.ToString(row["VALUE"]);
							if ( !Sql.IsEmptyString(sVALUE) )
							{
								// 03/7/2019 Paul.  If special value, then return empty password. 
								row["VALUE"] = Sql.sEMPTY_PASSWORD;
							}
						}
					}
				}
				dt.AcceptChanges();
			}
			else if ( sTABLE_NAME == "USERS" )
			{
				// 03/06/2019 Paul.  For the USERS table, we are going to limit the data return to the client. 
				foreach ( DataRow row in dt.Rows )
				{
					foreach ( DataColumn col in dt.Columns )
					{
						if ( col.ColumnName == "USER_PASSWORD" || col.ColumnName == "USER_HASH" || col.ColumnName == "GOOGLEAPPS_PASSWORD" || col.ColumnName == "ICLOUD_PASSWORD" || col.ColumnName == "SYSTEM_GENERATED_PASSWORD" )
						{
							string sVALUE = Sql.ToString(row[col.ColumnName]);
							if ( !Sql.IsEmptyString(sVALUE) )
								row[col.ColumnName] = Sql.sEMPTY_PASSWORD;
						}
					}
				}
				dt.AcceptChanges();
			}
			else if ( sTABLE_NAME == "INBOUND_EMAILS" )
			{
				// 03/06/2019 Paul.  For the INBOUND_EMAILS table, we are going to limit the data return to the client. 
				foreach ( DataRow row in dt.Rows )
				{
					foreach ( DataColumn col in dt.Columns )
					{
						if ( col.ColumnName == "EMAIL_PASSWORD" )
						{
							string sVALUE = Sql.ToString(row[col.ColumnName]);
							if ( !Sql.IsEmptyString(sVALUE) )
								row[col.ColumnName] = Sql.sEMPTY_PASSWORD;
						}
						else if ( col.ColumnName == "EXCHANGE_WATERMARK" )
						{
							row[col.ColumnName] = DBNull.Value;
						}
					}
				}
				dt.AcceptChanges();
			}
			else if ( sTABLE_NAME == "OUTBOUND_EMAILS" )
			{
				// 03/06/2019 Paul.  For the INBOUND_EMAILS table, we are going to limit the data return to the client. 
				foreach ( DataRow row in dt.Rows )
				{
					foreach ( DataColumn col in dt.Columns )
					{
						if ( col.ColumnName == "MAIL_SMTPPASS" )
						{
							string sVALUE = Sql.ToString(row[col.ColumnName]);
							if ( !Sql.IsEmptyString(sVALUE) )
								row[col.ColumnName] = Sql.sEMPTY_PASSWORD;
						}
					}
				}
				dt.AcceptChanges();
			}
			else if ( sTABLE_NAME == "PAYMENT_GATEWAYS" )
			{
				// 03/06/2019 Paul.  For the PAYMENT_GATEWAYS table, we are going to limit the data return to the client. 
				foreach ( DataRow row in dt.Rows )
				{
					foreach ( DataColumn col in dt.Columns )
					{
						if ( col.ColumnName == "PASSWORD" )
						{
							string sVALUE = Sql.ToString(row[col.ColumnName]);
							if ( !Sql.IsEmptyString(sVALUE) )
								row[col.ColumnName] = Sql.sEMPTY_PASSWORD;
						}
					}
				}
				dt.AcceptChanges();
			}
			else if ( sTABLE_NAME == "CREDIT_CARDS" )
			{
				foreach ( DataRow row in dt.Rows )
				{
					foreach ( DataColumn col in dt.Columns )
					{
						if ( col.ColumnName == "CARD_NUMBER" )
						{
							string sVALUE = Sql.ToString(row[col.ColumnName]);
							if ( !Sql.IsEmptyString(sVALUE) )
								row[col.ColumnName] = Sql.sEMPTY_PASSWORD;
						}
					}
				}
				dt.AcceptChanges();
			}
		}

		// 10/16/2020 Paul.  Use AccessMode.list so that we use the _List view if available. 
		public static DataTable GetAdminTable(HttpContext Context, string sTABLE_NAME, int nSKIP, int nTOP, string sFILTER, string sORDER_BY, string sGROUP_BY, UniqueStringCollection arrSELECT, Guid[] arrITEMS, ref long lTotalCount, UniqueStringCollection arrAGGREGATE, AccessMode enumAccessMode, StringBuilder sbDumpSQL)
		{
			HttpApplicationState Application = Context.Application;
			// 05/19/2018 Paul.  Capture the last command for error tracking. 
			string sLastCommand = String.Empty;
			DataTable dt = null;
			try
			{
				// 09/03/2011 Paul.  We should use the cached layout tables instead of a database lookup for performance reasons. 
				// When getting the layout tables, we typically only need the view name, so extract from the filter string. 
				// The Regex match will allow an OData query. 
				if ( Security.IsAuthenticated() )
				{
					string sMATCH_NAME = String.Empty;
					Regex r = new Regex(@"[^A-Za-z0-9_]");
					sTABLE_NAME = r.Replace(sTABLE_NAME, "");
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL = String.Empty;
						
						string sMODULE_NAME         = Sql.ToString (Application["Modules." + sTABLE_NAME + ".ModuleName"]);
						string sVIEW_NAME           = "vw" + sTABLE_NAME;
						using ( DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false) )
						{
							if ( dtSYNC_TABLES != null && dtSYNC_TABLES.Rows.Count > 0 )
							{
								// 10/16/2020 Paul.  Use list specific view if available. 
								if ( enumAccessMode == AccessMode.list && dtSYNC_TABLES.Columns.Contains("LIST_VIEW") )
								{
									DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
									string sLIST_VIEW = Sql.ToString (rowSYNC_TABLE["LIST_VIEW"]);
									if ( !Sql.IsEmptyString(sLIST_VIEW) )
										sVIEW_NAME = sLIST_VIEW;
								}
								else if ( (enumAccessMode == AccessMode.edit || enumAccessMode == AccessMode.view) && dtSYNC_TABLES.Columns.Contains("EDIT_VIEW") )
								{
									DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
									string sLIST_VIEW = Sql.ToString (rowSYNC_TABLE["EDIT_VIEW"]);
									if ( !Sql.IsEmptyString(sLIST_VIEW) )
										sVIEW_NAME = sLIST_VIEW;
								}
								// 11/26/2020 Paul.  React Client needs access to more User data.  Allow a user to get his own data or allow an admin to get all data. 
								if ( sVIEW_NAME == "vwUSERS_Sync" && (enumAccessMode == AccessMode.edit || enumAccessMode == AccessMode.view) && (Security.AdminUserAccess("Users", (enumAccessMode == AccessMode.edit ? "edit" : "view")) >= 0) )
								{
									sVIEW_NAME = "vwUSERS_Edit";
								}
								// 11/26/2020 Paul.  React Client needs to access inactive users. 
								else if ( sVIEW_NAME == "vwUSERS_Sync" && enumAccessMode == AccessMode.list && Security.AdminUserAccess("Users", "list") >= 0 )
								{
									sVIEW_NAME = "vwUSERS_List";
								}
							}
						}
						// 03/19/2019 Paul.  Some views have special fields. 
						if ( nSKIP == 0 && nTOP == 1 )
						{
							switch ( sMODULE_NAME )
							{
								case "Currencies":  sVIEW_NAME = "vwCURRENCIES_Edit";  break;
							}
						}
						else
						{
							switch ( sMODULE_NAME )
							{
								case "Currencies":  sVIEW_NAME = "vwCURRENCIES_List";  break;
							}
						}
						
						// 08/03/2011 Paul.  We need a way to filter the columns so that we can be efficient. 
						if ( arrSELECT != null && arrSELECT.Count > 0 )
						{
							foreach ( string sColumnName in arrSELECT )
							{
								if ( Sql.IsEmptyString(sSQL) )
									sSQL += "select " + sVIEW_NAME + "." + sColumnName + ControlChars.CrLf;
								else
									sSQL += "     , " + sVIEW_NAME + "." + sColumnName + ControlChars.CrLf;
							}
						}
						else
						{
							sSQL = "select " + sVIEW_NAME + ".*" + ControlChars.CrLf;
						}
						// 04/21/2017 Paul.  We need to return the total when using nTOP. 
						string sSelectSQL = sSQL;
						// 06/18/2011 Paul.  The REST API tables will use the view properly, so there is no need to join to the CSTM table. 
						sSQL += "  from " + sVIEW_NAME        + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							cmd.CommandTimeout = 0;
							cmd.CommandText += " where 1 = 1" + ControlChars.CrLf;
							// 05/25/2017 Paul.  arrITEMS may be empty. 
							if ( arrITEMS != null && arrITEMS.Length > 0 )
							{
								// 11/13/2009 Paul.  If a list of items is provided, then the max records field is ignored. 
								nSKIP = 0;
								nTOP = -1;
								Sql.AppendGuids(cmd, arrITEMS, "ID");
							}
							if ( !Sql.IsEmptyString(sFILTER) )
							{
								// 04/01/2020 Paul.  Move json utils to RestUtil. 
								string sSQL_FILTER = RestUtil.ConvertODataFilter(sFILTER, cmd);
								cmd.CommandText += "   and (" + sSQL_FILTER + ")" + ControlChars.CrLf;
								// 09/14/2021 Paul.  Instead of adding audit tables to SYSTEM_REST_TABLES, just allow to follow access of base table. 
								if ( sTABLE_NAME.EndsWith("_AUDIT") && sFILTER.Contains("and AUDIT_ACTION = '-1'") )
								{
									string sBASE_TABLE = sTABLE_NAME.Substring(0, sTABLE_NAME.Length - 6);
									cmd.CommandText += "   and ID in (select ID from " + sBASE_TABLE + "  where DELETED = 1 and " + sBASE_TABLE + ".ID = " + sVIEW_NAME + ".ID)" + ControlChars.CrLf;
								}
							}
							if ( Sql.IsEmptyString(sORDER_BY.Trim()) )
							{
								sORDER_BY = " order by " + sVIEW_NAME + ".DATE_MODIFIED" + ControlChars.CrLf;
							}
							else
							{
								// 06/18/2011 Paul.  Allow a comma in a sort expression. 
								r = new Regex(@"[^A-Za-z0-9_, ]");
								sORDER_BY = " order by " + r.Replace(sORDER_BY, "") + ControlChars.CrLf;
							}
							//cmd.CommandText += sORDER_BY;
							//Debug.WriteLine(Sql.ExpandParameters(cmd));// 03/20/2012 Paul.  Nolonger need to debug these SQL statements. 

							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								// 11/08/2009 Paul.  The table name is required in order to serialize the DataTable. 
								dt = new DataTable(sTABLE_NAME);
								if ( nTOP > 0 )
								{
									lTotalCount = -1;
									// 04/21/2017 Paul.  We need to return the total when using nTOP. 
									//string sSelectSQL = sSQL;
									if ( cmd.CommandText.StartsWith(sSelectSQL) )
									{
										string sOriginalSQL = cmd.CommandText;
										cmd.CommandText = "select count(*) " + ControlChars.CrLf + cmd.CommandText.Substring(sSelectSQL.Length);
										sLastCommand += Sql.ExpandParameters(cmd) + ";" + ControlChars.CrLf;
										lTotalCount = Sql.ToLong(cmd.ExecuteScalar());
										cmd.CommandText = sOriginalSQL;
									}
									// 02/16/2020 Paul.  Always build the paginated result ourselves to match ASP.NET code. 
									if ( nSKIP > 0 || Sql.IsEmptyString(sGROUP_BY) )
									{
										int nCurrentPageIndex = nSKIP / nTOP;
										// 06/17/2103 Paul.  We cannot page a group result. 
										Sql.PageResults(cmd, sTABLE_NAME, sORDER_BY, nCurrentPageIndex, nTOP);
										// 05/19/2018 Paul.  Capture the last command for error tracking. 
										sLastCommand += Sql.ExpandParameters(cmd);
										da.Fill(dt);
									}
									else
									{
										// 06/17/2013 Paul.  Add support for GROUP BY. 
										cmd.CommandText += sGROUP_BY + sORDER_BY;
										using ( DataSet ds = new DataSet() )
										{
											ds.Tables.Add(dt);
											// 05/19/2018 Paul.  Capture the last command for error tracking. 
											// 05/16/2021 Paul.  Append additional command. 
											sLastCommand += Sql.ExpandParameters(cmd);
											da.Fill(ds, 0, nTOP, sTABLE_NAME);
										}
									}
								}
								else
								{
									// 06/17/2013 Paul.  Add support for GROUP BY. 
									cmd.CommandText += sGROUP_BY + sORDER_BY;
									// 05/19/2018 Paul.  Capture the last command for error tracking. 
									sLastCommand = Sql.ExpandParameters(cmd);
									da.Fill(dt);
									// 04/21/2017 Paul.  We need to return the total when using nTOP. 
									lTotalCount = dt.Rows.Count;
								}
								// 06/06/2017 Paul.  Make it easy to dump the SQL. 
								// 10/26/2019 Paul.  Return the SQL to the React Client. 
								// 02/16/2020 Paul.  Use existing last command to include pagination. 
								sbDumpSQL.Append(sLastCommand);
#if DEBUG
								Debug.WriteLine(sLastCommand);
#endif
								// 03/07/2019 Paul.  Security values should not be returned to the client .
								PostprocessAdminTable(sTABLE_NAME, dt);
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				// 12/01/2012 Paul.  We need a more descriptive error message. 
				//SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				string sMessage = "GetAdminTable(" + sTABLE_NAME + ", " + sFILTER + ", " + sORDER_BY + ") " + ex.Message;
				SplendidError.SystemMessage("Error", new StackTrace(true).GetFrame(0), sMessage);
				// 05/19/2018 Paul.  Capture the last command for error tracking. 
				if ( ex.Message.Contains("The server supports a maximum of 2100 parameters") )
					SplendidError.SystemMessage("Error", new StackTrace(true).GetFrame(0), sLastCommand);
				throw(new Exception(sMessage));
			}
			return dt;
		}

		private static void LineItemSetRowField(DataRow row, string sFieldName, object oValue)
		{
			if ( row.Table.Columns.Contains(sFieldName) )
				row[sFieldName] = oValue;
		}

		private static object LineItemGetRowField(DataRow row, string sFieldName)
		{
			object oValue = String.Empty;
			if ( row.Table.Columns.Contains(sFieldName) )
				oValue = row[sFieldName];
			return oValue;
		}

		// 03/04/2016 Paul.  Line items will be included with Quotes, Orders and Invoices. 
		private static void UpdateLineItemsTable(HttpContext Context, DbProviderFactory dbf, IDbTransaction trn, TimeZone T10n, string sLINE_ITEM_TABLE_NAME, DataRow row)
		{
			IDbConnection con = trn.Connection;
			// 03/05/2016 Paul.  Re-apply the line item rules as the data may be from an uncertified source. 
			bool bEnableSalesTax     = Sql.ToBoolean(Context.Application["CONFIG.Orders.EnableSalesTax"]);
			bool bEnableTaxLineItems = Sql.ToBoolean(Context.Application["CONFIG.Orders.TaxLineItems"  ]);
			string sLINE_ITEM_TYPE = String.Empty;
			// 02/10/2020 Paul.  Dynamically generated table may not contain the field. 
			if ( row.Table.Columns.Contains("LINE_ITEM_TYPE") )
				sLINE_ITEM_TYPE = Sql.ToString(row["LINE_ITEM_TYPE"]);
			if ( sLINE_ITEM_TYPE == "Comment" )
			{
				LineItemSetRowField(row, "NAME"               , DBNull.Value);
				LineItemSetRowField(row, "MFT_PART_NUM"       , DBNull.Value);
				LineItemSetRowField(row, "VENDOR_PART_NUM"    , DBNull.Value);
				LineItemSetRowField(row, "PRODUCT_TEMPLATE_ID", DBNull.Value);
				LineItemSetRowField(row, "PARENT_TEMPLATE_ID" , DBNull.Value);
				LineItemSetRowField(row, "LINE_GROUP_ID"      , DBNull.Value);
				LineItemSetRowField(row, "TAX_CLASS"          , DBNull.Value);
				LineItemSetRowField(row, "TAXRATE_ID"         , DBNull.Value);
				LineItemSetRowField(row, "TAX"                , DBNull.Value);
				LineItemSetRowField(row, "QUANTITY"           , DBNull.Value);
				LineItemSetRowField(row, "COST_PRICE"         , DBNull.Value);
				LineItemSetRowField(row, "LIST_PRICE"         , DBNull.Value);
				LineItemSetRowField(row, "UNIT_PRICE"         , DBNull.Value);
				LineItemSetRowField(row, "EXTENDED_PRICE"     , DBNull.Value);
				LineItemSetRowField(row, "DISCOUNT_ID"        , DBNull.Value);
				LineItemSetRowField(row, "DISCOUNT_PRICE"     , DBNull.Value);
				LineItemSetRowField(row, "PRICING_FORMULA"    , DBNull.Value);
				LineItemSetRowField(row, "PRICING_FACTOR"     , DBNull.Value);
				if ( sLINE_ITEM_TABLE_NAME == "OPPORTUNITIES_LINE_ITEMS" || sLINE_ITEM_TABLE_NAME == "REVENUE_LINE_ITEMS" )
				{
					LineItemSetRowField(row, "DATE_CLOSED"     , DBNull.Value);
					LineItemSetRowField(row, "OPPORTUNITY_TYPE", DBNull.Value);
					LineItemSetRowField(row, "LEAD_SOURCE"     , DBNull.Value);
					LineItemSetRowField(row, "NEXT_STEP"       , DBNull.Value);
					LineItemSetRowField(row, "SALES_STAGE"     , DBNull.Value);
					LineItemSetRowField(row, "PROBABILITY"     , DBNull.Value);
				}
			}
			else
			{
				if ( bEnableSalesTax )
				{
					if ( bEnableTaxLineItems )
					{
						LineItemSetRowField(row, "TAX_CLASS", DBNull.Value);
					}
					else
					{
						LineItemSetRowField(row, "TAXRATE_ID"  , DBNull.Value);
						LineItemSetRowField(row, "TAX"         , DBNull.Value);
					}
				}
				else
				{
					LineItemSetRowField(row, "TAX_CLASS"   , DBNull.Value);
					LineItemSetRowField(row, "TAXRATE_ID"  , DBNull.Value);
					LineItemSetRowField(row, "TAX"         , DBNull.Value);
				}
				Guid   gDISCOUNT_ID     = Sql.ToGuid   (LineItemGetRowField(row, "DISCOUNT_ID"   ));
				Decimal nQUANTITY       = Sql.ToDecimal(LineItemGetRowField(row, "QUANTITY"      ));
				Decimal dUNIT_PRICE     = Sql.ToDecimal(LineItemGetRowField(row, "UNIT_PRICE"    ));
				Decimal dDISCOUNT_VALUE = Sql.ToDecimal(LineItemGetRowField(row, "DISCOUNT_PRICE"));
				Decimal dEXTENDED_PRICE = nQUANTITY * dUNIT_PRICE;
				LineItemSetRowField(row ,"EXTENDED_PRICE", dEXTENDED_PRICE);
				if ( !Sql.IsEmptyGuid(gDISCOUNT_ID) )
				{
					string  sDISCOUNT_NAME   = String.Empty;
					string  sPRICING_FORMULA = String.Empty;
					float   fPRICING_FACTOR  = 0;
					OrderUtils.DiscountValue(gDISCOUNT_ID, dUNIT_PRICE, dUNIT_PRICE, ref dDISCOUNT_VALUE, ref sDISCOUNT_NAME, ref sPRICING_FORMULA, ref fPRICING_FACTOR);
					dDISCOUNT_VALUE = (nQUANTITY * dDISCOUNT_VALUE);
					LineItemSetRowField(row ,"PRICING_FORMULA", sPRICING_FORMULA);
					LineItemSetRowField(row ,"DISCOUNT_PRICE" , dDISCOUNT_VALUE );
					LineItemSetRowField(row, "PRICING_FACTOR" , fPRICING_FACTOR );
				}
				else
				{
					string sPRICING_FORMULA = Sql.ToString (LineItemGetRowField(row, "PRICING_FORMULA"));
					if ( !Sql.IsEmptyString(sPRICING_FORMULA) )
					{
						float fPRICING_FACTOR = Sql.ToFloat  (LineItemGetRowField(row, "PRICING_FACTOR"));
						dDISCOUNT_VALUE = Decimal.Zero;
						OrderUtils.DiscountValue(sPRICING_FORMULA, fPRICING_FACTOR, dEXTENDED_PRICE, dEXTENDED_PRICE, ref dDISCOUNT_VALUE);
						LineItemSetRowField(row, "DISCOUNT_PRICE", dDISCOUNT_VALUE);
					}
					else
					{
						LineItemSetRowField(row, "PRICING_FACTOR", DBNull.Value);
					}
				}
				if ( bEnableSalesTax && bEnableTaxLineItems )
				{
					LineItemSetRowField(row, "TAX"         , DBNull.Value);
					Guid gTAXRATE_ID = Sql.ToGuid(LineItemGetRowField(row, "TAXRATE_ID"));
					if ( !Sql.IsEmptyGuid(gTAXRATE_ID) )
					{
						DataTable dtTAX_RATE = SplendidCache.TaxRates();
						DataRow[] rowTaxRate = dtTAX_RATE.Select("ID = '" + gTAXRATE_ID.ToString() + "'");
						if ( rowTaxRate.Length == 1 )
						{
							LineItemSetRowField(row, "TAX", (Sql.ToDecimal(LineItemGetRowField(row, "EXTENDED_PRICE")) - Sql.ToDecimal(LineItemGetRowField(row, "DISCOUNT_PRICE"))) * Sql.ToDecimal(rowTaxRate[0]["VALUE"]) / 100);
						}
					}
				}
			}

			bool      bRecordExists = false;
			DataRow   rowCurrent    = null;
			DataTable dtCurrent     = new DataTable();
			Guid      gID           = Guid.Empty;
			if ( row.Table.Columns.Contains("ID") )
				gID = Sql.ToGuid(row["ID"]);
			if ( !Sql.IsEmptyGuid(gID) )
			{
				string sSQL;
				sSQL = "select *"                          + ControlChars.CrLf
				     + "  from vw" + sLINE_ITEM_TABLE_NAME + ControlChars.CrLf
				     + " where 1 = 1"                      + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.Transaction = trn;
					cmd.CommandText = sSQL;
					Sql.AppendParameter(cmd, gID, "ID");
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						try
						{
							da.Fill(dtCurrent);
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex.Message + ": " + Sql.ExpandParameters(cmd));
							throw;
						}
						if ( dtCurrent.Rows.Count > 0 )
						{
							rowCurrent = dtCurrent.Rows[0];
							bRecordExists = true;
						}
					}
				}
			}
			IDbCommand cmdUpdate = SqlProcs.Factory(con, "sp" + sLINE_ITEM_TABLE_NAME + "_Update");
			cmdUpdate.Transaction = trn;
			foreach(IDbDataParameter par in cmdUpdate.Parameters)
			{
				// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
				string sParameterName = Sql.ExtractDbName(cmdUpdate, par.ParameterName).ToUpper();
				if ( sParameterName == "MODIFIED_USER_ID" )
					par.Value = Sql.ToDBGuid(Security.USER_ID);
				else
					par.Value = DBNull.Value;
			}
			if ( bRecordExists )
			{
				// 11/11/2009 Paul.  If the record already exists, then the current values are treated as default values. 
				foreach ( DataColumn col in rowCurrent.Table.Columns )
				{
					IDbDataParameter par = Sql.FindParameter(cmdUpdate, col.ColumnName);
					// 11/26/2009 Paul.  The UTC modified date should be set to Now. 
					// 09/28/2020 Paul.  We need to make sure that the record is marked as being edited by the updating user, not the current user. 
					if ( par != null && String.Compare(col.ColumnName, "DATE_MODIFIED_UTC", true) != 0 && String.Compare(col.ColumnName, "MODIFIED_USER_ID", true) != 0 )
						par.Value = rowCurrent[col.ColumnName];
				}
			}
			
			foreach ( DataColumn col in row.Table.Columns )
			{
				// 03/05/2016 Paul.  We are not supporting field security on line items. 
				//bool bIsWriteable = true;
				//if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sMODULE_NAME) )
				//{
				//	Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, col.ColumnName, Guid.Empty);
				//	bIsWriteable = acl.IsWriteable();
				//}
				//if ( bIsWriteable )
				{
					IDbDataParameter par = Sql.FindParameter(cmdUpdate, col.ColumnName);
					if ( par != null )
					{
						// 05/22/2017 Paul.  Shared function to convert from Json to DB. 
						// 04/01/2020 Paul.  Move json utils to RestUtil. 
						par.Value = RestUtil.DBValueFromJsonValue(par.DbType, row[col.ColumnName], T10n);
					}
				}
			}
			cmdUpdate.ExecuteScalar();
			IDbDataParameter parID = Sql.FindParameter(cmdUpdate, "@ID");
			if ( parID != null )
			{
				gID = Sql.ToGuid(parID.Value);
				DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sLINE_ITEM_TABLE_NAME);
				SplendidDynamic.UpdateCustomFields(row, trn, gID, sLINE_ITEM_TABLE_NAME, dtCustomFields);
			}
		}

		// 04/01/2020 Paul.  Move UpdateTable to RestUtil. 
		// 06/21/2021 Paul.  Move bExcludeSystemTables to method parameter so that it can be used by admin REST methods. 
		public static Guid UpdateTable(HttpContext Context, string sTABLE_NAME, Dictionary<string, object> dict)
		{
			return UpdateTable(Context, sTABLE_NAME, dict, true);
		}

		// 06/21/2021 Paul.  Move bExcludeSystemTables to method parameter so that it can be used by admin REST methods. 
		public static Guid UpdateTable(HttpContext Context, string sTABLE_NAME, Dictionary<string, object> dict, bool bExcludeSystemTables)
		{
			HttpApplicationState Application = Context.Application;
			HttpSessionState     Session     = Context.Session;
			Guid gID = Guid.Empty;
			try
			{
				// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
				Guid     gTIMEZONE = Sql.ToGuid  (Session["USER_SETTINGS/TIMEZONE"]);
				TimeZone T10n      = TimeZone.CreateTimeZone(Application, gTIMEZONE);
				// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
				bool bSaveDuplicate   = false;
				bool bSaveConcurrency = false;
				DateTime dtLAST_DATE_MODIFIED = DateTime.MinValue;
				DataTable dtUPDATE = new DataTable(sTABLE_NAME);
				// 03/04/2016 Paul.  Line items will be included with Quotes, Orders and Invoices. 
				DataTable dtLINE_ITEMS = new DataTable(sTABLE_NAME + "_LINE_ITEMS");
				DataTable dtFILES      = new DataTable("IMAGES");
				// 05/22/2017 Paul.  DashboardPanels will be included with Dashboard. 
				DataTable dtDASHBOARDS_PANELS = new DataTable("DASHBOARDS_PANELS");
				// 07/09/2020 Paul.  We need access ot the ID very early to determine if this is a new record as the User Password can only be created if the record is new. 
				foreach ( string sColumnName in dict.Keys )
				{
					if ( String.Compare(sColumnName, "ID") == 0 )
					{
						gID = Sql.ToGuid(dict[sColumnName]);
						break;
					}
				}
				bool bNewRecord = Sql.IsEmptyGuid(gID);
				foreach ( string sColumnName in dict.Keys )
				{
					// 03/16/2014 Paul.  Don't include Save Overrides as column names. 
					if ( String.Compare(sColumnName, "SaveDuplicate") == 0 )
						bSaveDuplicate = true;
					else if ( String.Compare(sColumnName, "SaveConcurrency") == 0 )
						bSaveConcurrency = true;
					else if ( String.Compare(sColumnName, "LAST_DATE_MODIFIED") == 0 )
					{
						// 04/01/2020 Paul.  Move json utils to RestUtil. 
						dtLAST_DATE_MODIFIED = T10n.ToServerTime(RestUtil.FromJsonDate(Sql.ToString(dict[sColumnName])));
					}
					// 03/04/2016 Paul.  Line items will be included with Quotes, Orders and Invoices. 
					else if ( String.Compare(sColumnName, "LineItems") == 0 )
					{
						System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
						if ( lst != null )
						{
							foreach ( Dictionary<string, object> lineitem in lst )
							{
								foreach ( string sLineItemColumnName in lineitem.Keys )
								{
									dtLINE_ITEMS.Columns.Add(sLineItemColumnName);
								}
								break;
							}
						}
					}
					// 05/27/2016 Paul.  Files may be in any module as it can be a custom field. 
					else if ( String.Compare(sColumnName, "Files") == 0 )
					{
						System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
						if ( lst != null )
						{
							foreach ( Dictionary<string, object> file in lst )
							{
								foreach ( string sFileColumnName in file.Keys )
								{
									dtFILES.Columns.Add(sFileColumnName);
								}
								break;
							}
						}
					}
					// 05/22/2017 Paul.  DashboardPanels will be included with Dashboard. 
					else if ( String.Compare(sColumnName, "DashboardPanels") == 0 )
					{
						System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
						if ( lst != null )
						{
							foreach ( Dictionary<string, object> panel in lst )
							{
								foreach ( string sPanelColumnName in panel.Keys )
								{
									dtDASHBOARDS_PANELS.Columns.Add(sPanelColumnName);
								}
								break;
							}
						}
					}
					// 07/08/2020 Paul.  Don't add field if it is the empty password.  That way old value will automatically be used. 
					else if ( sTABLE_NAME == "USERS")
					{
						if ( String.Compare(sColumnName, "MAIL_SMTPPASS") == 0 || String.Compare(sColumnName, "GOOGLEAPPS_PASSWORD") == 0 || String.Compare(sColumnName, "ICLOUD_PASSWORD") == 0 )
						{
							string sPASSWORD = Sql.ToString(dict[sColumnName]);
							// 07/08/2020 Paul.  Make sure to add when empty string so a password can be cleared. 
							if ( Sql.IsEmptyString(sPASSWORD) || sPASSWORD != Sql.sEMPTY_PASSWORD )
							{
								dtUPDATE.Columns.Add(sColumnName);
							}
						}
						else if ( String.Compare(sColumnName, "PASSWORD") == 0 )
						{
							if ( bNewRecord )
							{
								dtUPDATE.Columns.Add(sColumnName);
							}
						}
						else
						{
							dtUPDATE.Columns.Add(sColumnName);
						}
					}
					else if ( sTABLE_NAME == "CONTACTS")
					{
						if ( String.Compare(sColumnName, "PORTAL_PASSWORD") == 0 )
						{
							string sPASSWORD = Sql.ToString(dict[sColumnName]);
							// 07/08/2020 Paul.  Make sure to add when empty string so a password can be cleared. 
							if ( Sql.IsEmptyString(sPASSWORD) || sPASSWORD != Sql.sEMPTY_PASSWORD )
							{
								dtUPDATE.Columns.Add(sColumnName);
							}
						}
						else
						{
							dtUPDATE.Columns.Add(sColumnName);
						}
					}
					else
					{
						dtUPDATE.Columns.Add(sColumnName);
					}
				}
				DataRow row = dtUPDATE.NewRow();
				dtUPDATE.Rows.Add(row);
				foreach ( string sColumnName in dict.Keys )
				{
					// 09/09/2011 Paul.  Multi-selection list boxes will come in as an ArrayList. 
					if ( dict[sColumnName] is System.Collections.ArrayList )
					{
						System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
						// 03/04/2016 Paul.  Line items will be included with Quotes, Orders and Invoices. 
						if ( String.Compare(sColumnName, "LineItems") == 0 )
						{
							if ( lst != null )
							{
								foreach ( Dictionary<string, object> lineitem in lst )
								{
									DataRow rowLineItem = dtLINE_ITEMS.NewRow();
									dtLINE_ITEMS.Rows.Add(rowLineItem);
									foreach ( string sLineItemColumnName in lineitem.Keys )
									{
										rowLineItem[sLineItemColumnName] = lineitem[sLineItemColumnName];
									}
								}
							}
						}
						// 05/27/2016 Paul.  Images may be in any module as it can be a custom field. 
						else if ( String.Compare(sColumnName, "Files") == 0 )
						{
							if ( lst != null )
							{
								foreach ( Dictionary<string, object> fileitem in lst )
								{
									DataRow rowFile = dtFILES.NewRow();
									dtFILES.Rows.Add(rowFile);
									foreach ( string sFileColumnName in fileitem.Keys )
									{
										rowFile[sFileColumnName] = fileitem[sFileColumnName];
									}
								}
							}
						}
						// 05/22/2017 Paul.  DashboardPanels will be included with Dashboard. 
						else if ( String.Compare(sColumnName, "DashboardPanels") == 0 )
						{
							if ( lst != null )
							{
								foreach ( Dictionary<string, object> panel in lst )
								{
									DataRow rowLineItem = dtDASHBOARDS_PANELS.NewRow();
									dtDASHBOARDS_PANELS.Rows.Add(rowLineItem);
									foreach ( string sPanelColumnName in panel.Keys )
									{
										rowLineItem[sPanelColumnName] = panel[sPanelColumnName];
									}
								}
							}
						}
						else
						{
							XmlDocument xml = new XmlDocument();
							xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
							xml.AppendChild(xml.CreateElement("Values"));
							if ( lst.Count > 0 )
							{
								// 08/25/2019 Paul.  If an array of booleans is sent, it will not automatically be converted to string. 
								foreach ( object item in lst )
								{
									XmlNode xValue = xml.CreateElement("Value");
									xml.DocumentElement.AppendChild(xValue);
									xValue.InnerText = Sql.ToString(item);
								}
							}
							row[sColumnName] = xml.OuterXml;
						}
					}
					else if ( sColumnName != "SaveDuplicate" && sColumnName != "SaveConcurrency" && sColumnName != "LAST_DATE_MODIFIED" )
					{
						// 07/08/2020 Paul.  Encrypt passwords. 
						if ( sTABLE_NAME == "USERS")
						{
							if ( (String.Compare(sColumnName, "MAIL_SMTPPASS") == 0 || String.Compare(sColumnName, "GOOGLEAPPS_PASSWORD") == 0 || String.Compare(sColumnName, "ICLOUD_PASSWORD") == 0) && dtUPDATE.Columns.Contains(sColumnName) )
							{
								string sPASSWORD = Sql.ToString(dict[sColumnName]);
								if ( !Sql.IsEmptyString(sPASSWORD) && sPASSWORD != Sql.sEMPTY_PASSWORD )
								{
									Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
									Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
									string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sPASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
									if ( Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sPASSWORD )
										throw(new Exception("Decryption failed"));
									row[sColumnName] = sENCRYPTED_EMAIL_PASSWORD;
								}
							}
							// 07/09/2020 Paul.  Hash User password during creation. 
							else if ( String.Compare(sColumnName, "PASSWORD") == 0 && dtUPDATE.Columns.Contains(sColumnName) )
							{
								string sPASSWORD = Sql.ToString(dict[sColumnName]);
								if ( !Sql.IsEmptyString(sPASSWORD) && sPASSWORD != Sql.sEMPTY_PASSWORD && (SplendidCRM.Security.AdminUserAccess("Users", "edit") >= 0) )
								{
									row[sColumnName] = Security.HashPassword(sPASSWORD);
								}
							}
							else if ( dtUPDATE.Columns.Contains(sColumnName) )
							{
								row[sColumnName] = dict[sColumnName];
							}
						}
						else if ( sTABLE_NAME == "CONTACTS")
						{
							// 07/08/2020 Paul.  Hash portal password. 
							if ( String.Compare(sColumnName, "PORTAL_PASSWORD") == 0 && dtUPDATE.Columns.Contains(sColumnName) )
							{
								string sPASSWORD = Sql.ToString(dict[sColumnName]);
								if ( !Sql.IsEmptyString(sPASSWORD) && sPASSWORD != Sql.sEMPTY_PASSWORD )
								{
									row[sColumnName] = Security.HashPassword(sPASSWORD);
								}
							}
							else if ( dtUPDATE.Columns.Contains(sColumnName) )
							{
								row[sColumnName] = dict[sColumnName];
							}
						}
						else if ( dtUPDATE.Columns.Contains(sColumnName) )
						{
							row[sColumnName] = dict[sColumnName];
						}
					}
				}
				//dtResults.Columns.Add("SPLENDID_SYNC_STATUS" , typeof(System.String));
				//dtResults.Columns.Add("SPLENDID_SYNC_MESSAGE", typeof(System.String));
				if ( Security.IsAuthenticated() )
				{
					string sCULTURE = Sql.ToString (Session["USER_SETTINGS/CULTURE"]);
					L10N   L10n     = new L10N(sCULTURE);
					Regex  r        = new Regex(@"[^A-Za-z0-9_]");
					sTABLE_NAME = r.Replace(sTABLE_NAME, "").ToUpper();
					
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						// 06/03/2011 Paul.  Cache the Rest Table data. 
						// 11/26/2009 Paul.  System tables cannot be updated. 
						// 07/09/2020 Paul.  Special exception with User update to allow user to update their own profile or an administrator to create a user. 
						// 06/21/2021 Paul.  Move bExcludeSystemTables to method parameter so that it can be used by admin REST methods. 
						if ( sTABLE_NAME == "USERS" )
						{
							if ( SplendidCRM.Security.AdminUserAccess("Users", "edit") >= 0 )
							{
								bExcludeSystemTables = false;
							}
							else if ( gID == Security.USER_ID )
							{
								bExcludeSystemTables = false;
							}
						}
						// 11/21/2020 Paul.  Tags is another special module that allows that typical user to create record. 
						else if ( sTABLE_NAME == "TAGS" )
						{
							// 11/21/2020 Paul.  But we don't want to allow a typically user to modify an existing tag.  
							if ( Sql.IsEmptyGuid(gID) && SplendidCRM.Security.AdminUserAccess("Tags", "edit") >= 0 )
							{
								bExcludeSystemTables = false;
							}
						}
						using ( DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, bExcludeSystemTables) )
						{
							string sSQL = String.Empty;
							if ( dtSYNC_TABLES != null && dtSYNC_TABLES.Rows.Count > 0 )
							{
								DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
								string sMODULE_NAME = Sql.ToString (rowSYNC_TABLE["MODULE_NAME"]);
								string sVIEW_NAME   = Sql.ToString (rowSYNC_TABLE["VIEW_NAME"  ]);
								bool   bHAS_CUSTOM  = Sql.ToBoolean(rowSYNC_TABLE["HAS_CUSTOM" ]);
								// 02/14/2010 Paul.  GetUserAccess requires a non-null sMODULE_NAME. 
								// Lets catch the exception here so that we can throw a meaningful error. 
								if ( Sql.IsEmptyString(sMODULE_NAME) )
								{
									throw(new Exception("sMODULE_NAME should not be empty for table " + sTABLE_NAME));
								}
								// 02/22/2013 Paul.  Make sure the ID column exists before retrieving. It is optional. 
								//if ( row.Table.Columns.Contains("ID") )
								//	gID = Sql.ToGuid(row["ID"]);
								int nACLACCESS = SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "edit");
								// 11/11/2009 Paul.  First check if the user has access to this module. 
								// 07/05/2020 Paul.  Some update operations are restricted, like admin module updates. 
								bool bRestricted = false;
								if ( Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".IsAdmin"]) )
								{
									if ( Security.AdminUserAccess(sMODULE_NAME, "edit") < 0 )
									{
										// 07/05/2020 Paul.  Allow a non-admin user to update his own profile information. 
										if ( sMODULE_NAME == "Users" && gID == Security.USER_ID )
										{
											if ( dtUPDATE.Columns.Contains("IS_ADMIN"                 ) ) dtUPDATE.Columns.Remove("IS_ADMIN"                 );
											if ( dtUPDATE.Columns.Contains("IS_ADMIN_DELEGATE"        ) ) dtUPDATE.Columns.Remove("IS_ADMIN_DELEGATE"        );
											if ( dtUPDATE.Columns.Contains("SYSTEM_GENERATED_PASSWORD") ) dtUPDATE.Columns.Remove("SYSTEM_GENERATED_PASSWORD");
										}
										// 01/05/2020 Paul.  Tags is an admin module that everyone can edit. 
										else if ( sMODULE_NAME != "Tags" )
										{
											bRestricted = true;
										}
									}
								}
								if ( nACLACCESS >= 0 && !bRestricted )
								{
									bool      bRecordExists              = false;
									bool      bAccessAllowed             = false;
									Guid      gLOCAL_ASSIGNED_USER_ID    = Guid.Empty;
									DataRow   rowCurrent                 = null;
									DataTable dtCurrent                  = new DataTable();
									
									if ( !Sql.IsEmptyGuid(gID) )
									{
										// 10/08/2020 Paul.  Users are special.  Use vwUSERS_Edit instead of the vwUSERS_Sync view provided by SYSTEM_REST_TABLES. 
										if ( sTABLE_NAME == "USERS" )
										{
											sSQL = "select *"              + ControlChars.CrLf
											     + "  from vwUSERS_Edit"   + ControlChars.CrLf
											     + " where 1 = 1"          + ControlChars.CrLf;
										}
										// 10/05/2021 Paul.  When portal is on, we need to use vwCONTACTS_Edit so that PORTAL_PASSWORD will be included in the current row. 
										else if ( sTABLE_NAME == "CONTACTS" && Sql.ToBoolean(Application["CONFIG.portal_on"]) )
										{
											sSQL = "select *"              + ControlChars.CrLf
											     + "  from vwCONTACTS_Edit"+ ControlChars.CrLf
											     + " where 1 = 1"          + ControlChars.CrLf;
										}
										else
										{
											// 10/05/2020 Paul.  Must use view not table. 
											// 10/08/2020 Paul.  We should be initializing the data with the view, not the table. 
											sSQL = "select *"              + ControlChars.CrLf
											     + "  from " + sVIEW_NAME  + ControlChars.CrLf
											     + " where 1 = 1"          + ControlChars.CrLf;
										}
										using ( IDbCommand cmd = con.CreateCommand() )
										{
											cmd.CommandText = sSQL;
											Sql.AppendParameter(cmd, gID, "ID");
											using ( DbDataAdapter da = dbf.CreateDataAdapter() )
											{
												((IDbDataAdapter)da).SelectCommand = cmd;
												// 11/27/2009 Paul.  It may be useful to log the SQL during errors at this location. 
												try
												{
													da.Fill(dtCurrent);
												}
												catch
												{
													SplendidError.SystemError(new StackTrace(true).GetFrame(0), Sql.ExpandParameters(cmd));
													throw;
												}
												if ( dtCurrent.Rows.Count > 0 )
												{
													rowCurrent = dtCurrent.Rows[0];
													// 03/16/2014 Paul.  Throw an exception if the record has been edited since the last load. 
													// 03/16/2014 Paul.  Enable override of concurrency error. 
													if ( Sql.ToBoolean(Application["CONFIG.enable_concurrency_check"])  && !bSaveConcurrency && dtLAST_DATE_MODIFIED != DateTime.MinValue && Sql.ToDateTime(rowCurrent["DATE_MODIFIED"]) > dtLAST_DATE_MODIFIED )
													{
														throw(new Exception(String.Format(L10n.Term(".ERR_CONCURRENCY_OVERRIDE"), dtLAST_DATE_MODIFIED) + ".ERR_CONCURRENCY_OVERRIDE"));
													}
													bRecordExists = true;
													// 01/18/2010 Paul.  Apply ACL Field Security. 
													if ( dtCurrent.Columns.Contains("ASSIGNED_USER_ID") )
													{
														gLOCAL_ASSIGNED_USER_ID = Sql.ToGuid(rowCurrent["ASSIGNED_USER_ID"]);
													}
												}
											}
										}
									}
									// 06/04/2011 Paul.  We are not ready to handle conflicts. 
									//if ( !bConflicted )
									{
										if ( bRecordExists )
										{
											sSQL = "select count(*)"       + ControlChars.CrLf
											     + "  from " + sTABLE_NAME + ControlChars.CrLf;
											using ( IDbCommand cmd = con.CreateCommand() )
											{
												cmd.CommandText = sSQL;
												Security.Filter(cmd, sMODULE_NAME, "edit");
												Sql.AppendParameter(cmd, gID, "ID");
												try
												{
													if ( Sql.ToInteger(cmd.ExecuteScalar()) > 0 )
													{
														if ( (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && Security.USER_ID == gLOCAL_ASSIGNED_USER_ID) || !dtCurrent.Columns.Contains("ASSIGNED_USER_ID") )
															bAccessAllowed = true;
													}
												}
												catch
												{
													SplendidError.SystemError(new StackTrace(true).GetFrame(0), Sql.ExpandParameters(cmd));
													throw;
												}
											}
										}
										if ( !bRecordExists || bAccessAllowed )
										{
											// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
											bool bDUPLICATE_CHECHING_ENABLED = Sql.ToBoolean(Application["CONFIG.enable_duplicate_check"]) && Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".DuplicateCheckingEnabled"]) && !bSaveDuplicate;
											if ( bDUPLICATE_CHECHING_ENABLED )
											{
												if ( Utils.DuplicateCheck(Application, con, sMODULE_NAME, gID, row, rowCurrent) > 0 )
												{
													// 03/16/2014 Paul.  Put the error name at the end so that we can detect the event. 
													throw(new Exception(L10n.Term(".ERR_DUPLICATE_EXCEPTION") + ".ERR_DUPLICATE_EXCEPTION"));
												}
											}
											DataTable dtMetadata = SplendidCache.SqlColumns(sTABLE_NAME);
											using ( IDbTransaction trn = Sql.BeginTransaction(con) )
											{
												try
												{
													bool bEnableTeamManagement  = Crm.Config.enable_team_management();
													bool bRequireTeamManagement = Crm.Config.require_team_management();
													bool bRequireUserAssignment = Crm.Config.require_user_assignment();
													// 06/04/2011 Paul.  Unlike the Sync service, we want to use the stored procedures to update records. 
													// 10/27/2012 Paul.  Relationship tables start with vw. 
													IDbCommand cmdUpdate = null;
													// 11/23/2014 Paul.  NOTE_ATTACHMENTS does not have an _Update procedure.  Fallback to _Insert. 
													try
													{
														// 11/23/2014 Paul.  Table name is converted to upper case. 
														if ( sTABLE_NAME.StartsWith("vw") || sTABLE_NAME.StartsWith("VW") )
															cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME.Substring(2) + "_Update");
														else
															cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update");
													}
													catch
													{
														if ( sTABLE_NAME.StartsWith("vw") || sTABLE_NAME.StartsWith("VW") )
															cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME.Substring(2) + "_Insert");
														else
															cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Insert");
													}
													cmdUpdate.Transaction = trn;
													foreach(IDbDataParameter par in cmdUpdate.Parameters)
													{
														// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
														string sParameterName = Sql.ExtractDbName(cmdUpdate, par.ParameterName).ToUpper();
														if ( sParameterName == "TEAM_ID" && bEnableTeamManagement )
															par.Value = Sql.ToDBGuid(Security.TEAM_ID);  // 02/26/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
														else if ( sParameterName == "ASSIGNED_USER_ID" )
															par.Value = Sql.ToDBGuid(Security.USER_ID);  // 02/26/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
														else if ( sParameterName == "MODIFIED_USER_ID" )
															par.Value = Sql.ToDBGuid(Security.USER_ID);
														else
															par.Value = DBNull.Value;
													}
													if ( bRecordExists )
													{
														// 11/11/2009 Paul.  If the record already exists, then the current values are treated as default values. 
														foreach ( DataColumn col in rowCurrent.Table.Columns )
														{
															IDbDataParameter par = Sql.FindParameter(cmdUpdate, col.ColumnName);
															// 11/26/2009 Paul.  The UTC modified date should be set to Now. 
															// 09/28/2020 Paul.  We need to make sure that the record is marked as being edited by the updating user, not the current user. 
															if ( par != null && String.Compare(col.ColumnName, "DATE_MODIFIED_UTC", true) != 0 && String.Compare(col.ColumnName, "MODIFIED_USER_ID", true) != 0 )
																par.Value = rowCurrent[col.ColumnName];
														}
													}
													DataView vwFiles = new DataView(dtFILES);
													foreach ( DataColumn col in row.Table.Columns )
													{
														// 01/18/2010 Paul.  Apply ACL Field Security. 
														// 02/01/2010 Paul.  System tables may not have a valid Module name, so Field Security will not apply. 
														bool bIsWriteable = true;
														if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sMODULE_NAME) )
														{
															Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, col.ColumnName, Guid.Empty);
															bIsWriteable = acl.IsWriteable();
														}
														if ( bIsWriteable )
														{
															IDbDataParameter par = Sql.FindParameter(cmdUpdate, col.ColumnName);
															// 11/26/2009 Paul.  The UTC modified date should be set to Now. 
															if ( par != null )
															{
																// 05/22/2017 Paul.  Shared function to convert from Json to DB. 
																// 04/01/2020 Paul.  Move json utils to RestUtil. 
																par.Value = RestUtil.DBValueFromJsonValue(par.DbType, row[col.ColumnName], T10n);
															}
														}
													}
													// 02/13/2018 Paul.  Azure can timeout, so lets wait for an hour. 
													cmdUpdate.CommandTimeout = 60 * 60;
													// 02/13/2018 Paul.  We should be using ExecuteNonQuery instead of ExecuateScalar. 
													cmdUpdate.ExecuteNonQuery();
													IDbDataParameter parID = Sql.FindParameter(cmdUpdate, "@ID");
													if ( parID != null )
													{
														gID = Sql.ToGuid(parID.Value);
														if ( bHAS_CUSTOM )
														{
															DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
															if ( vwFiles.Count > 0 )
															{
																foreach ( DataRow rowCustomField in dtCustomFields.Rows )
																{
																	string sCUSTOM_FIELD_NAME = Sql.ToString(rowCustomField["NAME"]);
																	// 03/18/2020 Paul.  Make sure column exists before filtering on the column 
																	if ( vwFiles.Table.Columns.Contains("DATA_FIELD") )
																	{
																		vwFiles.RowFilter = "DATA_FIELD = '" + sCUSTOM_FIELD_NAME + "'";
																		// 05/27/2016 Paul.  Images may be in any module as it can be a custom field. 
																		// We need to insert the images first so that the ID can be set in the primary table. 
																		if ( vwFiles.Count > 0 )
																		{
																			DataRowView rowFile = vwFiles[0];
																			string sDATA_FIELD     = Sql.ToString(rowFile["DATA_FIELD"    ]);
																			string sFILENAME       = Sql.ToString(rowFile["FILENAME"      ]);
																			string sFILE_EXT       = Sql.ToString(rowFile["FILE_EXT"      ]);
																			string sFILE_MIME_TYPE = Sql.ToString(rowFile["FILE_MIME_TYPE"]);
																			string sFILE_DATA      = Sql.ToString(rowFile["FILE_DATA"     ]);
																			byte[] byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
																			long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
																			if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
																			{
																				throw(new Exception("ERROR: uploaded file for " + sDATA_FIELD + " was too big: max filesize: " + lUploadMaxSize.ToString()));
																			}
																			Guid gImageID = Guid.Empty;
																			SqlProcs.spIMAGES_Insert
																				( ref gImageID
																				, gID
																				, sFILENAME
																				, sFILE_EXT
																				, sFILE_MIME_TYPE
																				, trn
																				);
																			Crm.Images.LoadFile(gImageID, byFILE_DATA, trn);
																			row[sCUSTOM_FIELD_NAME] = gImageID;
																		}
																	}
																}
															}
															SplendidDynamic.UpdateCustomFields(row, trn, gID, sTABLE_NAME, dtCustomFields);
														}
													}
													// 07/09/2020 Paul.  Hash User password during creation. 
													if ( sTABLE_NAME == "USERS" )
													{
														if ( dtUPDATE.Columns.Contains("PASSWORD") && bNewRecord )
														{
															string sPASSWORD = Sql.ToString(row["PASSWORD"]);
															if ( !Sql.IsEmptyString(sPASSWORD) && sPASSWORD != Sql.sEMPTY_PASSWORD && (SplendidCRM.Security.AdminUserAccess("Users", "edit") >= 0) )
															{
																// 11/11/2021 Paul.  The password is already being hashed above, so don't hash here. 
																SqlProcs.spUSERS_PasswordUpdate(gID, sPASSWORD, trn);
															}
														}
													}
													// 07/29/2021 Paul.  SqlProcs.spCONTACTS_PortalUpdate inside RestUtils.UpdateTable(). 
													else if ( sTABLE_NAME == "CONTACTS" )
													{
														if ( Sql.ToBoolean(Application["CONFIG.portal_on"]) )
														{
															string sPORTAL_NAME     = String.Empty;
															string sPORTAL_PASSWORD = String.Empty;
															bool   bPORTAL_ACTIVE    = false;
															if ( rowCurrent != null )
															{
																sPORTAL_NAME   = Sql.ToString (rowCurrent["PORTAL_NAME"  ]);
																bPORTAL_ACTIVE = Sql.ToBoolean(rowCurrent["PORTAL_ACTIVE"]);
															}
															if ( dtUPDATE.Columns.Contains("PORTAL_NAME"    ) ) sPORTAL_NAME     = Sql.ToString (row["PORTAL_NAME"    ]);
															if ( dtUPDATE.Columns.Contains("PORTAL_ACTIVE"  ) ) bPORTAL_ACTIVE   = Sql.ToBoolean(row["PORTAL_ACTIVE"  ]);
															// 07/29/2021 Paul.  New password already updated above. 
															if ( dtUPDATE.Columns.Contains("PORTAL_PASSWORD") ) sPORTAL_PASSWORD = Sql.ToString (row["PORTAL_PASSWORD"]);
															// 03/05/2009 Paul.  If password has not changed, then restore old password.
															// 10/26/2009 Paul.  A password field cannot be set, so it will not be sEMPTY_PASSWORD. 
															// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
															if ( sPORTAL_PASSWORD == Sql.sEMPTY_PASSWORD || sPORTAL_PASSWORD == String.Empty )
															{
																if ( rowCurrent != null )
																	sPORTAL_PASSWORD = Sql.ToString(rowCurrent["PORTAL_PASSWORD"]);
															}
															SqlProcs.spCONTACTS_PortalUpdate(gID, bPORTAL_ACTIVE, sPORTAL_NAME, sPORTAL_PASSWORD, trn);
														}
													}
													// 05/27/2016 Paul.  Move FILE_DATA inside main transaction. 
													else if ( sTABLE_NAME == "VWNOTE_ATTACHMENTS" )
													{
														if ( dict.ContainsKey("FILE_DATA") )
														{
															string sFILE_DATA = Sql.ToString(dict["FILE_DATA"]);
															byte[] byFILE_DATA  = Convert.FromBase64String(sFILE_DATA);
															long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
															if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
															{
																throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
															}
															Crm.NoteAttachments.LoadFile(gID, byFILE_DATA, trn);
														}
													}
													// 05/27/2016 Paul.  Documents module includes the document in the Images object. 
													else if ( sTABLE_NAME == "DOCUMENTS" )
													{
														// 03/18/2020 Paul.  Make sure column exists before filtering on the column 
														if ( vwFiles.Table.Columns.Contains("DATA_FIELD") )
														{
															vwFiles.RowFilter = "DATA_FIELD = 'CONTENT'";
															if ( vwFiles.Count > 0 )
															{
																DataRowView rowFile = vwFiles[0];
																string sFILENAME       = Sql.ToString(rowFile["FILENAME"      ]);
																string sFILE_EXT       = Sql.ToString(rowFile["FILE_EXT"      ]);
																string sFILE_MIME_TYPE = Sql.ToString(rowFile["FILE_MIME_TYPE"]);
																string sFILE_DATA      = Sql.ToString(rowFile["FILE_DATA"     ]);
																byte[] byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
																long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
																if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
																{
																	throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
																}
																Guid gRevisionID = Guid.Empty;
																SqlProcs.spDOCUMENT_REVISIONS_Insert
																	( ref gRevisionID
																	, gID
																	, Sql.ToString(row["REVISION"])
																	, "Document Created"
																	, sFILENAME
																	, sFILE_EXT
																	, sFILE_MIME_TYPE
																	, trn
																	);
																Crm.DocumentRevisions.LoadFile(gRevisionID, byFILE_DATA, trn);
															}
														}
														// 10/15/2022 Paul.  Must manually add Documents relationship. 
														if ( dict.ContainsKey("PARENT_ID") )
														{
															Guid   gPARENT_ID   = Sql.ToGuid(dict["PARENT_ID"]);
															string sMODULE      = String.Empty;
															string sPARENT_TYPE = String.Empty;
															string sPARENT_NAME = String.Empty;
															SqlProcs.spPARENT_Get(ref gPARENT_ID, ref sMODULE, ref sPARENT_TYPE, ref sPARENT_NAME, trn);
															SqlProcs.spDOCUMENTS_InsRelated(gID, sMODULE, gPARENT_ID, trn);
														}
													}
													// 11/24/2021 Paul.  Document Revisions also need to pull the file data separately. 
													else if ( sTABLE_NAME == "DOCUMENT_REVISIONS" )
													{
														if ( vwFiles.Count > 0 )
														{
															DataRowView rowFile = vwFiles[0];
															string sFILENAME       = Sql.ToString(rowFile["FILENAME"      ]);
															string sFILE_EXT       = Sql.ToString(rowFile["FILE_EXT"      ]);
															string sFILE_MIME_TYPE = Sql.ToString(rowFile["FILE_MIME_TYPE"]);
															string sFILE_DATA      = Sql.ToString(rowFile["FILE_DATA"     ]);
															byte[] byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
															long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
															if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
															{
																throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
															}
															Crm.DocumentRevisions.LoadFile(gID, byFILE_DATA, trn);
														}
													}
													// 05/27/2016 Paul.  Notes module includes the attachment. 
													else if ( sTABLE_NAME == "NOTES" )
													{
														// 03/18/2020 Paul.  Make sure column exists before filtering on the column 
														if ( vwFiles.Table.Columns.Contains("DATA_FIELD") )
														{
															vwFiles.RowFilter = "DATA_FIELD = 'ATTACHMENT'";
															if ( vwFiles.Count > 0 )
															{
																DataRowView rowFile = vwFiles[0];
																string sFILENAME       = Sql.ToString(rowFile["FILENAME"      ]);
																string sFILE_EXT       = Sql.ToString(rowFile["FILE_EXT"      ]);
																string sFILE_MIME_TYPE = Sql.ToString(rowFile["FILE_MIME_TYPE"]);
																string sFILE_DATA      = Sql.ToString(rowFile["FILE_DATA"     ]);
																byte[] byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
																long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
																if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
																{
																	throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
																}
																Guid gAttachmentID = Guid.Empty;
																SqlProcs.spNOTE_ATTACHMENTS_Insert
																	( ref gAttachmentID
																	, gID
																	, sFILENAME
																	, sFILENAME
																	, sFILE_EXT
																	, sFILE_MIME_TYPE
																	, trn
																	);
																Crm.NoteAttachments.LoadFile(gAttachmentID, byFILE_DATA, trn);
															}
														}
													}
													// 05/13/2020 Paul.  The React Client supports KBDocuments with attachments. 
													else if ( sTABLE_NAME == "KBDOCUMENTS" )
													{
														foreach ( string sColumnName in dict.Keys )
														{
															if ( String.Compare(sColumnName, "KB_ATTACHMENTS") == 0 )
															{
																System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
																if ( lst != null )
																{
																	long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
																	foreach ( Dictionary<string, object> file in lst )
																	{
																		string sFILENAME           = String.Empty;
																		string sFILE_EXT           = String.Empty;
																		string sFILE_MIME_TYPE     = String.Empty;
																		string sFILE_DATA          = String.Empty;
																		byte[] byFILE_DATA         = null;
																		bool   bDELETED            = false;
																		Guid   gNOTE_ATTACHMENT_ID = Guid.Empty;
																		foreach ( string sFileColumnName in file.Keys )
																		{
																			switch ( sFileColumnName )
																			{
																				case "FILENAME"      :  sFILENAME           = Sql.ToString (file["FILENAME"      ]);  break;
																				case "FILE_EXT"      :  sFILE_EXT           = Sql.ToString (file["FILE_EXT"      ]);  break;
																				case "FILE_MIME_TYPE":  sFILE_MIME_TYPE     = Sql.ToString (file["FILE_MIME_TYPE"]);  break;
																				case "FILE_DATA"     :  sFILE_DATA          = Sql.ToString (file["FILE_DATA"     ]);  break;
																				case "deleted"       :  bDELETED            = Sql.ToBoolean(file["deleted"       ]);  break;
																				case "ID"            :  gNOTE_ATTACHMENT_ID = Sql.ToGuid   (file["ID"            ]);  break;
																			}
																		}
																		// 05/08/2020 Paul.  For existing attachments, we just need to watch for deleted. 
																		if ( bDELETED && !Sql.IsEmptyGuid(gNOTE_ATTACHMENT_ID) )
																		{
																			if ( !Sql.IsEmptyGuid(gNOTE_ATTACHMENT_ID) )
																				SqlProcs.spNOTE_ATTACHMENTS_Delete(gNOTE_ATTACHMENT_ID, trn);
																		}
																		else if ( !Sql.IsEmptyString(sFILE_DATA) )
																		{
																			byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
																			if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
																			{
																				throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
																			}
																			Guid gATTACHMENT_ID = Guid.Empty;
																			SqlProcs.spKBDOCUMENTS_ATTACHMENTS_Insert(ref gATTACHMENT_ID, gID, sFILENAME, sFILE_EXT, sFILE_MIME_TYPE, trn);
																			using ( MemoryStream stm = new MemoryStream(byFILE_DATA) )
																			{
																				// 10/26/2009 Paul.  Move blob logic to LoadFile. 
																				KBDocuments.EditView.LoadAttachmentFile(gATTACHMENT_ID, stm, trn);
																			}
																		}
																	}
																}
															}
															else if ( String.Compare(sColumnName, "IMAGES") == 0 )
															{
																System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
																if ( lst != null )
																{
																	long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
																	foreach ( Dictionary<string, object> file in lst )
																	{
																		string sFILENAME           = String.Empty;
																		string sFILE_EXT           = String.Empty;
																		string sFILE_MIME_TYPE     = String.Empty;
																		string sFILE_DATA          = String.Empty;
																		byte[] byFILE_DATA         = null;
																		bool   bDELETED            = false;
																		Guid   gNOTE_ATTACHMENT_ID = Guid.Empty;
																		foreach ( string sFileColumnName in file.Keys )
																		{
																			switch ( sFileColumnName )
																			{
																				case "FILENAME"      :  sFILENAME           = Sql.ToString (file["FILENAME"      ]);  break;
																				case "FILE_EXT"      :  sFILE_EXT           = Sql.ToString (file["FILE_EXT"      ]);  break;
																				case "FILE_MIME_TYPE":  sFILE_MIME_TYPE     = Sql.ToString (file["FILE_MIME_TYPE"]);  break;
																				case "FILE_DATA"     :  sFILE_DATA          = Sql.ToString (file["FILE_DATA"     ]);  break;
																				case "deleted"       :  bDELETED            = Sql.ToBoolean(file["deleted"       ]);  break;
																				case "ID"            :  gNOTE_ATTACHMENT_ID = Sql.ToGuid   (file["ID"            ]);  break;
																			}
																		}
																		// 05/08/2020 Paul.  For existing attachments, we just need to watch for deleted. 
																		if ( bDELETED && !Sql.IsEmptyGuid(gNOTE_ATTACHMENT_ID) )
																		{
																			if ( !Sql.IsEmptyGuid(gNOTE_ATTACHMENT_ID) )
																				SqlProcs.spNOTE_ATTACHMENTS_Delete(gNOTE_ATTACHMENT_ID, trn);
																		}
																		else if ( !Sql.IsEmptyString(sFILE_DATA) )
																		{
																			byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
																			if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
																			{
																				throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
																			}
																			Guid gIMAGE_ID = Guid.Empty;
																			SqlProcs.spKBDOCUMENTS_IMAGES_Insert(ref gIMAGE_ID, gID, sFILENAME, sFILE_EXT, sFILE_MIME_TYPE, trn);
																			using ( MemoryStream stm = new MemoryStream(byFILE_DATA) )
																			{
																				// 10/26/2009 Paul.  Move blob logic to LoadFile. 
																				KBDocuments.EditView.LoadImageFile(gIMAGE_ID, stm, trn);
																			}
																		}
																	}
																}
															}
														}
													}
													// 05/08/2020 Paul.  The React Client supports emails with attachments. 
													else if ( sTABLE_NAME == "EMAILS" )
													{
														foreach ( string sColumnName in dict.Keys )
														{
															if ( String.Compare(sColumnName, "KB_ATTACHMENTS") == 0 )
															{
																System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
																if ( lst != null )
																{
																	foreach ( Dictionary<string, object> file in lst )
																	{
																		foreach ( string sFileColumnName in file.Keys )
																		{
																			if ( sFileColumnName == "ID" )
																			{
																				Guid gNOTE_ID = Guid.Empty;
																				Guid gCOPY_ID = Sql.ToGuid(row["ID"]);
																				SqlProcs.spKBDOCUMENTS_ATTACHMENTS_CreateNote(ref gNOTE_ID, gCOPY_ID, "Emails", gID, trn);
																			}
																		}
																	}
																}
															}
															else if ( String.Compare(sColumnName, "TEMPLATE_ATTACHMENTS") == 0 )
															{
																System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
																if ( lst != null )
																{
																	foreach ( Dictionary<string, object> file in lst )
																	{
																		foreach ( string sFileColumnName in file.Keys )
																		{
																			if ( sFileColumnName == "ID" )
																			{
																				Guid gNOTE_ID = Guid.Empty;
																				Guid gCOPY_ID = Sql.ToGuid(file["ID"]);
																				SqlProcs.spNOTES_Copy(ref gNOTE_ID, gCOPY_ID, "Emails", gID, trn);
																			}
																		}
																	}
																}
															}
															else if ( String.Compare(sColumnName, "ATTACHMENTS") == 0 )
															{
																System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
																if ( lst != null )
																{
																	long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
																	foreach ( Dictionary<string, object> file in lst )
																	{
																		string sFILENAME       = String.Empty;
																		string sFILE_EXT       = String.Empty;
																		string sFILE_MIME_TYPE = String.Empty;
																		string sFILE_DATA      = String.Empty;
																		byte[] byFILE_DATA     = null;
																		bool   bDELETED        = false;
																		Guid   gNOTE_ID        = Guid.Empty;
																		foreach ( string sFileColumnName in file.Keys )
																		{
																			switch ( sFileColumnName )
																			{
																				case "FILENAME"      :  sFILENAME       = Sql.ToString (file["FILENAME"      ]);  break;
																				case "FILE_EXT"      :  sFILE_EXT       = Sql.ToString (file["FILE_EXT"      ]);  break;
																				case "FILE_MIME_TYPE":  sFILE_MIME_TYPE = Sql.ToString (file["FILE_MIME_TYPE"]);  break;
																				case "FILE_DATA"     :  sFILE_DATA      = Sql.ToString (file["FILE_DATA"     ]);  break;
																				case "deleted"       :  bDELETED        = Sql.ToBoolean(file["deleted"       ]);  break;
																				case "ID"            :  gNOTE_ID        = Sql.ToGuid   (file["ID"            ]);  break;
																			}
																		}
																		// 05/08/2020 Paul.  For existing attachments, we just need to watch for deleted. 
																		if ( bDELETED && !Sql.IsEmptyGuid(gNOTE_ID) )
																		{
																			if ( !Sql.IsEmptyGuid(gNOTE_ID) )
																				SqlProcs.spNOTES_Delete(gNOTE_ID, trn);
																		}
																		else if ( !Sql.IsEmptyString(sFILE_DATA) )
																		{
																			byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
																			if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
																			{
																				throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
																			}
																			Guid   gTEAM_ID           = Guid.Empty;
																			string sTEAM_SET_LIST     = String.Empty;
																			Guid   gASSIGNED_USER_ID  = Guid.Empty;
																			string sASSIGNED_SET_LIST = String.Empty;
																			foreach(IDbDataParameter par in cmdUpdate.Parameters)
																			{
																				string sParameterName = Sql.ExtractDbName(cmdUpdate, par.ParameterName).ToUpper();
																				switch ( sParameterName )
																				{
																					case "TEAM_ID"          :  gTEAM_ID           = Sql.ToGuid  (par.Value);  break;
																					case "TEAM_SET_LIST"    :  sTEAM_SET_LIST     = Sql.ToString(par.Value);  break;
																					case "ASSIGNED_USER_ID" :  gASSIGNED_USER_ID  = Sql.ToGuid  (par.Value);  break;
																					case "ASSIGNED_SET_LIST":  sASSIGNED_SET_LIST = Sql.ToString(par.Value);  break;
																				}
																			}
																			SqlProcs.spNOTES_Update
																				( ref gNOTE_ID
																				, L10n.Term("Emails.LBL_EMAIL_ATTACHMENT") + ": " + sFILENAME
																				, "Emails"   // Parent Type
																				, gID        // Parent ID
																				, Guid.Empty
																				, String.Empty
																				, gTEAM_ID
																				, sTEAM_SET_LIST
																				, gASSIGNED_USER_ID
																				, String.Empty  // TAG_SET_NAME
																				, false         // IS_PRIVATE
																				, sASSIGNED_SET_LIST
																				, trn
																				);
																			// 03/01/2021 Paul.  spNOTE_ATTACHMENTS_Insert points to gNOTE_ID, not gID. 
																			Guid gNOTE_ATTACHMENT_ID = Guid.Empty;
																			SqlProcs.spNOTE_ATTACHMENTS_Insert
																				( ref gNOTE_ATTACHMENT_ID
																				, gNOTE_ID
																				, sFILENAME
																				, sFILENAME
																				, sFILE_EXT
																				, sFILE_MIME_TYPE
																				, trn
																				);
																			Crm.NoteAttachments.LoadFile(gNOTE_ATTACHMENT_ID, byFILE_DATA, trn);
																		}
																	}
																}
															}
														}
														// 03/18/2020 Paul.  Make sure column exists before filtering on the column 
														if ( vwFiles.Table.Columns.Contains("DATA_FIELD") )
														{
															vwFiles.RowFilter = "DATA_FIELD = 'ATTACHMENT'";
															if ( vwFiles.Count > 0 )
															{
																DataRowView rowFile = vwFiles[0];
																string sFILENAME       = Sql.ToString(rowFile["FILENAME"      ]);
																string sFILE_EXT       = Sql.ToString(rowFile["FILE_EXT"      ]);
																string sFILE_MIME_TYPE = Sql.ToString(rowFile["FILE_MIME_TYPE"]);
																string sFILE_DATA      = Sql.ToString(rowFile["FILE_DATA"     ]);
																byte[] byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
																long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
																if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
																{
																	throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
																}
																Guid gAttachmentID = Guid.Empty;
																SqlProcs.spNOTE_ATTACHMENTS_Insert
																	( ref gAttachmentID
																	, gID
																	, sFILENAME
																	, sFILENAME
																	, sFILE_EXT
																	, sFILE_MIME_TYPE
																	, trn
																	);
																Crm.NoteAttachments.LoadFile(gAttachmentID, byFILE_DATA, trn);
															}
														}
													}
													// 05/08/2020 Paul.  The React Client supports email templates with attachments. 
													else if ( sTABLE_NAME == "EMAIL_TEMPLATES" )
													{
														// 05/13/2020 Paul.  Make sure to clear the cache. 
														SplendidCache.ClearEmailTemplates();
														foreach ( string sColumnName in dict.Keys )
														{
															if ( String.Compare(sColumnName, "ATTACHMENTS") == 0 )
															{
																System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
																if ( lst != null )
																{
																	long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
																	foreach ( Dictionary<string, object> file in lst )
																	{
																		string sFILENAME       = String.Empty;
																		string sFILE_EXT       = String.Empty;
																		string sFILE_MIME_TYPE = String.Empty;
																		string sFILE_DATA      = String.Empty;
																		byte[] byFILE_DATA     = null;
																		bool   bDELETED        = false;
																		Guid   gNOTE_ID        = Guid.Empty;
																		foreach ( string sFileColumnName in file.Keys )
																		{
																			switch ( sFileColumnName )
																			{
																				case "FILENAME"      :  sFILENAME       = Sql.ToString (file["FILENAME"      ]);  break;
																				case "FILE_EXT"      :  sFILE_EXT       = Sql.ToString (file["FILE_EXT"      ]);  break;
																				case "FILE_MIME_TYPE":  sFILE_MIME_TYPE = Sql.ToString (file["FILE_MIME_TYPE"]);  break;
																				case "FILE_DATA"     :  sFILE_DATA      = Sql.ToString (file["FILE_DATA"     ]);  break;
																				case "deleted"       :  bDELETED        = Sql.ToBoolean(file["deleted"       ]);  break;
																				case "ID"            :  gNOTE_ID        = Sql.ToGuid   (file["ID"            ]);  break;
																			}
																		}
																		// 05/08/2020 Paul.  For existing attachments, we just need to watch for deleted. 
																		if ( bDELETED && !Sql.IsEmptyGuid(gNOTE_ID) )
																		{
																			if ( !Sql.IsEmptyGuid(gNOTE_ID) )
																				SqlProcs.spNOTES_Delete(gNOTE_ID, trn);
																		}
																		else if ( !Sql.IsEmptyString(sFILE_DATA) )
																		{
																			byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
																			if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
																			{
																				throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
																			}
																			Guid   gTEAM_ID           = Guid.Empty;
																			string sTEAM_SET_LIST     = String.Empty;
																			Guid   gASSIGNED_USER_ID  = Guid.Empty;
																			string sASSIGNED_SET_LIST = String.Empty;
																			foreach(IDbDataParameter par in cmdUpdate.Parameters)
																			{
																				string sParameterName = Sql.ExtractDbName(cmdUpdate, par.ParameterName).ToUpper();
																				switch ( sParameterName )
																				{
																					case "TEAM_ID"          :  gTEAM_ID           = Sql.ToGuid  (par.Value);  break;
																					case "TEAM_SET_LIST"    :  sTEAM_SET_LIST     = Sql.ToString(par.Value);  break;
																					case "ASSIGNED_USER_ID" :  gASSIGNED_USER_ID  = Sql.ToGuid  (par.Value);  break;
																					case "ASSIGNED_SET_LIST":  sASSIGNED_SET_LIST = Sql.ToString(par.Value);  break;
																				}
																			}
																			SqlProcs.spNOTES_Update
																				( ref gNOTE_ID
																				, L10n.Term("EmailTemplates.LBL_EMAIL_ATTACHMENT") + ": " + sFILENAME
																				, "EmailTemplates"   // Parent Type
																				, gID        // Parent ID
																				, Guid.Empty
																				, String.Empty
																				, gTEAM_ID
																				, sTEAM_SET_LIST
																				, gASSIGNED_USER_ID
																				, String.Empty  // TAG_SET_NAME
																				, false         // IS_PRIVATE
																				, sASSIGNED_SET_LIST
																				, trn
																				);
																			// 03/11/2021 Paul.  spNOTE_ATTACHMENTS_Insert points to gNOTE_ID, not gID. 
																			Guid gNOTE_ATTACHMENT_ID = Guid.Empty;
																			SqlProcs.spNOTE_ATTACHMENTS_Insert
																				( ref gNOTE_ATTACHMENT_ID
																				, gNOTE_ID
																				, sFILENAME
																				, sFILENAME
																				, sFILE_EXT
																				, sFILE_MIME_TYPE
																				, trn
																				);
																			Crm.NoteAttachments.LoadFile(gNOTE_ATTACHMENT_ID, byFILE_DATA, trn);
																		}
																	}
																}
															}
														}
														// 03/18/2020 Paul.  Make sure column exists before filtering on the column 
														if ( vwFiles.Table.Columns.Contains("DATA_FIELD") )
														{
															vwFiles.RowFilter = "DATA_FIELD = 'ATTACHMENT'";
															if ( vwFiles.Count > 0 )
															{
																DataRowView rowFile = vwFiles[0];
																string sFILENAME       = Sql.ToString(rowFile["FILENAME"      ]);
																string sFILE_EXT       = Sql.ToString(rowFile["FILE_EXT"      ]);
																string sFILE_MIME_TYPE = Sql.ToString(rowFile["FILE_MIME_TYPE"]);
																string sFILE_DATA      = Sql.ToString(rowFile["FILE_DATA"     ]);
																byte[] byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
																long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
																if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
																{
																	throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
																}
																Guid gAttachmentID = Guid.Empty;
																SqlProcs.spNOTE_ATTACHMENTS_Insert
																	( ref gAttachmentID
																	, gID
																	, sFILENAME
																	, sFILENAME
																	, sFILE_EXT
																	, sFILE_MIME_TYPE
																	, trn
																	);
																Crm.NoteAttachments.LoadFile(gAttachmentID, byFILE_DATA, trn);
															}
														}
													}
													// 05/27/2016 Paul.  Bugs module includes the attachment. 
													else if ( sTABLE_NAME == "BUGS" )
													{
														// 03/18/2020 Paul.  Make sure column exists before filtering on the column 
														if ( vwFiles.Table.Columns.Contains("DATA_FIELD") )
														{
															vwFiles.RowFilter = "DATA_FIELD = 'ATTACHMENT'";
															if ( vwFiles.Count > 0 )
															{
																DataRowView rowFile = vwFiles[0];
																string sFILENAME       = Sql.ToString(rowFile["FILENAME"      ]);
																string sFILE_EXT       = Sql.ToString(rowFile["FILE_EXT"      ]);
																string sFILE_MIME_TYPE = Sql.ToString(rowFile["FILE_MIME_TYPE"]);
																string sFILE_DATA      = Sql.ToString(rowFile["FILE_DATA"     ]);
																byte[] byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
																long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
																if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
																{
																	throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
																}
																// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
																string sTEAM_SET_LIST     = String.Empty;
																string sASSIGNED_SET_LIST = String.Empty;
																if ( row.Table.Columns.Contains("TEAM_SET_LIST") )
																	sTEAM_SET_LIST = Sql.ToString(row["TEAM_SET_LIST"]);
																if ( row.Table.Columns.Contains("ASSIGNED_SET_LIST") )
																	sASSIGNED_SET_LIST = Sql.ToString(row["ASSIGNED_SET_LIST"]);
															
																Guid gAttachmentID = Guid.Empty;
																SqlProcs.spBUG_ATTACHMENTS_Insert
																	( ref gAttachmentID
																	, gID
																	, sFILENAME
																	, sFILENAME
																	, sFILE_EXT
																	, sFILE_MIME_TYPE
																	, Sql.ToGuid  (row["TEAM_ID"      ])
																	, sTEAM_SET_LIST
																	// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
																	, sASSIGNED_SET_LIST
																	, trn
																	);
																Crm.BugAttachments.LoadFile(gAttachmentID, byFILE_DATA, trn);
															}
														}
													}
													// 05/06/2022 Paul.  When PARENT_ID is provided, spINVOICES_PAYMENTS_Update gets called. 
													else if ( sTABLE_NAME == "PAYMENTS" )
													{
														// 10/09/2022 Paul.  Keep old code while adding support for Payment Line Items, which are just Invoices. 
														if ( dict.ContainsKey("PARENT_ID") && dict.ContainsKey("AMOUNT") )
														{
															IDbCommand cmdINVOICES_PAYMENTS_Update = SqlProcs.Factory(con, "spINVOICES_PAYMENTS_Update");
															cmdINVOICES_PAYMENTS_Update.Transaction = trn;
															foreach(IDbDataParameter par in cmdINVOICES_PAYMENTS_Update.Parameters)
															{
																// 05/22/2017 Paul.  Correct source proce. 
																string sParameterName = Sql.ExtractDbName(cmdINVOICES_PAYMENTS_Update, par.ParameterName).ToUpper();
																if ( sParameterName == "MODIFIED_USER_ID" )
																	par.Value = Sql.ToDBGuid(Security.USER_ID);
																else if ( sParameterName == "PAYMENT_ID" )
																	par.Value = gID;
																else if ( sParameterName == "INVOICE_ID" )
																	par.Value = Sql.ToGuid(dict["PARENT_ID"]);
																else if ( sParameterName == "AMOUNT" )
																	par.Value = Sql.ToDecimal(dict["AMOUNT"]);
																else
																	par.Value = DBNull.Value;
															}
															cmdINVOICES_PAYMENTS_Update.ExecuteNonQuery();
														}
														// 10/09/2022 Paul.  Add Payments.SummaryView to React Client. 
														else
														{
															List<Guid> lstCurrentLineItems = new List<Guid>();
															sSQL = "select ID"                          + ControlChars.CrLf
																 + "  from vwPAYMENTS_INVOICES"         + ControlChars.CrLf
																 + " where PAYMENT_ID = @PAYMENT_ID"    + ControlChars.CrLf;
															try
															{
																using ( IDbCommand cmd = con.CreateCommand() )
																{
																	cmd.Transaction = trn;
																	cmd.CommandText = sSQL;
																	Sql.AddParameter(cmd, "@PAYMENT_ID", gID);
																	using ( DbDataAdapter da = dbf.CreateDataAdapter() )
																	{
																		((IDbDataAdapter)da).SelectCommand = cmd;
																		using ( DataTable dtcurrentLineItems = new DataTable() )
																		{
																			da.Fill(dtcurrentLineItems);
																			foreach ( DataRow rowLineItems in dtcurrentLineItems.Rows )
																			{
																				lstCurrentLineItems.Add(Sql.ToGuid(rowLineItems["ID"]));
																			}
																		}
																	}
																}
															}
															catch(Exception ex)
															{
																SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex.Message + ": " + sSQL);
															}
															// 03/09/2016 Paul.  We need to make sure to set the relationship key. 
															string sPRIMARY_FIELD_NAME = Crm.Modules.SingularTableName(sTABLE_NAME) + "_ID";
															if ( !dtLINE_ITEMS.Columns.Contains(sPRIMARY_FIELD_NAME) )
																dtLINE_ITEMS.Columns.Add(sPRIMARY_FIELD_NAME);
														
															IDbCommand spINVOICES_PAYMENTS_Update = SqlProcs.Factory(con, "spINVOICES_PAYMENTS_Update");
															spINVOICES_PAYMENTS_Update.Transaction = trn;
															foreach ( DataRow rowLineItem in dtLINE_ITEMS.Rows )
															{
																Guid gLINE_ITEM_ID = Guid.Empty;
																// 02/10/2020 Paul.  Dynamically generated table may not contain the field. 
																if ( dtLINE_ITEMS.Columns.Contains("ID") )
																	gLINE_ITEM_ID = Sql.ToGuid(rowLineItem["ID"]);
																if ( !Sql.IsEmptyGuid(gLINE_ITEM_ID) && lstCurrentLineItems.Contains(gLINE_ITEM_ID) )
																	lstCurrentLineItems.Remove(gLINE_ITEM_ID);
															
																foreach(IDbDataParameter par in spINVOICES_PAYMENTS_Update.Parameters)
																{
																	string sParameterName = Sql.ExtractDbName(spINVOICES_PAYMENTS_Update, par.ParameterName).ToUpper();
																	if      ( sParameterName == "MODIFIED_USER_ID" ) par.Value = Sql.ToDBGuid   (Security.USER_ID        ) ;
																	else if ( sParameterName == "ID"               ) par.Value = gLINE_ITEM_ID                             ;
																	else if ( sParameterName == "PAYMENT_ID"       ) par.Value = gID                                       ;
																	else if ( sParameterName == "INVOICE_ID"       ) par.Value = Sql.ToDBGuid   (rowLineItem["INVOICE_ID"]);
																	else if ( sParameterName == "AMOUNT"           ) par.Value = Sql.ToDBDecimal(rowLineItem["AMOUNT"    ]);
																}
																spINVOICES_PAYMENTS_Update.ExecuteNonQuery();
															}
															IDbCommand spINVOICES_PAYMENTS_Delete = SqlProcs.Factory(con, "spINVOICES_PAYMENTS_Delete");
															spINVOICES_PAYMENTS_Delete.Transaction = trn;
															foreach ( Guid gLINE_ITEM_ID in lstCurrentLineItems )
															{
																// 05/22/2017 Paul.  Correct source proce. 
																foreach(IDbDataParameter par in spINVOICES_PAYMENTS_Delete.Parameters)
																{
																	string sParameterName = Sql.ExtractDbName(spINVOICES_PAYMENTS_Delete, par.ParameterName).ToUpper();
																	if ( sParameterName == "MODIFIED_USER_ID" )
																		par.Value = Sql.ToDBGuid(Security.USER_ID);
																	else if ( sParameterName == "ID" )
																		par.Value = gLINE_ITEM_ID;
																}
																spINVOICES_PAYMENTS_Delete.ExecuteNonQuery();
															}
														}
													}
													// 03/04/2016 Paul.  Line items will be included with Quotes, Orders and Invoices. 
													else if ( sTABLE_NAME == "QUOTES" || sTABLE_NAME == "ORDERS" || sTABLE_NAME == "INVOICES" || (sTABLE_NAME == "OPPORTUNITIES" && Sql.ToString(Application["CONFIG.OpportunitiesMode"]) == "Revenue" ) )
													{
														List<Guid> lstCurrentLineItems = new List<Guid>();
														string sLINE_ITEMS_TABLE_NAME = (sTABLE_NAME == "OPPORTUNITIES" ? "REVENUE_LINE_ITEMS" : sTABLE_NAME + "_LINE_ITEMS");
														sSQL = "select ID"                          + ControlChars.CrLf
														     + "  from vw" + sLINE_ITEMS_TABLE_NAME + ControlChars.CrLf
														     + " where 1 = 1"                       + ControlChars.CrLf;
														try
														{
															using ( IDbCommand cmd = con.CreateCommand() )
															{
																cmd.Transaction = trn;
																cmd.CommandText = sSQL;
																Sql.AppendParameter(cmd, gID, Crm.Modules.SingularTableName(sTABLE_NAME) + "_ID");
																using ( DbDataAdapter da = dbf.CreateDataAdapter() )
																{
																	((IDbDataAdapter)da).SelectCommand = cmd;
																	using ( DataTable dtcurrentLineItems = new DataTable() )
																	{
																		da.Fill(dtcurrentLineItems);
																		foreach ( DataRow rowLineItems in dtcurrentLineItems.Rows )
																		{
																			lstCurrentLineItems.Add(Sql.ToGuid(rowLineItems["ID"]));
																		}
																	}
																}
															}
														}
														catch(Exception ex)
														{
															SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex.Message + ": " + sSQL);
														}
														// 03/09/2016 Paul.  We need to make sure to set the relationship key. 
														string sPRIMARY_FIELD_NAME = Crm.Modules.SingularTableName(sTABLE_NAME) + "_ID";
														if ( !dtLINE_ITEMS.Columns.Contains(sPRIMARY_FIELD_NAME) )
															dtLINE_ITEMS.Columns.Add(sPRIMARY_FIELD_NAME);
														foreach ( DataRow rowLineItem in dtLINE_ITEMS.Rows )
														{
															Guid gLINE_ITEM_ID = Guid.Empty;
															// 02/10/2020 Paul.  Dynamically generated table may not contain the field. 
															if ( dtLINE_ITEMS.Columns.Contains("ID") )
																gLINE_ITEM_ID = Sql.ToGuid(rowLineItem["ID"]);
															if ( !Sql.IsEmptyGuid(gLINE_ITEM_ID) && lstCurrentLineItems.Contains(gLINE_ITEM_ID) )
																lstCurrentLineItems.Remove(gLINE_ITEM_ID);
															// 02/10/2020 Paul.  Dynamically generated table may not contain the field. 
															if ( dtLINE_ITEMS.Columns.Contains(sPRIMARY_FIELD_NAME) && Sql.IsEmptyString(rowLineItem[sPRIMARY_FIELD_NAME]) )
																rowLineItem[sPRIMARY_FIELD_NAME] = gID.ToString();
															UpdateLineItemsTable(Context, dbf, trn, T10n, sLINE_ITEMS_TABLE_NAME, rowLineItem);
														}
														IDbCommand cmdLineItemDelete = SqlProcs.Factory(con, "sp" + sLINE_ITEMS_TABLE_NAME + "_Delete");
														cmdLineItemDelete.Transaction = trn;
														foreach ( Guid gLINE_ITEM_ID in lstCurrentLineItems )
														{
															// 05/22/2017 Paul.  Correct source proce. 
															foreach(IDbDataParameter par in cmdLineItemDelete.Parameters)
															{
																string sParameterName = Sql.ExtractDbName(cmdLineItemDelete, par.ParameterName).ToUpper();
																if ( sParameterName == "MODIFIED_USER_ID" )
																	par.Value = Sql.ToDBGuid(Security.USER_ID);
																else if ( sParameterName == "ID" )
																	par.Value = gLINE_ITEM_ID;
															}
															cmdLineItemDelete.ExecuteNonQuery();
														}
														IDbCommand cmdUpdateTotals = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_UpdateTotals");
														cmdUpdateTotals.Transaction = trn;
														foreach(IDbDataParameter par in cmdUpdateTotals.Parameters)
														{
															// 05/22/2017 Paul.  Correct source proce. 
															string sParameterName = Sql.ExtractDbName(cmdUpdateTotals, par.ParameterName).ToUpper();
															if ( sParameterName == "MODIFIED_USER_ID" )
																par.Value = Sql.ToDBGuid(Security.USER_ID);
															else if ( sParameterName == "ID" )
																par.Value = gID;
														}
														cmdUpdateTotals.ExecuteNonQuery();
													}
													// 05/22/2017 Paul.  DashboardPanels will be included with Dashboard. 
													else if ( sTABLE_NAME == "DASHBOARDS" )
													{
														List<Guid> lstCurrentPanels = new List<Guid>();
														sSQL = "select ID                 " + ControlChars.CrLf
														     + "  from vwDASHBOARDS_PANELS" + ControlChars.CrLf
														     + " where 1 = 1              " + ControlChars.CrLf;
														try
														{
															using ( IDbCommand cmd = con.CreateCommand() )
															{
																cmd.Transaction = trn;
																cmd.CommandText = sSQL;
																Sql.AppendParameter(cmd, gID, Crm.Modules.SingularTableName(sTABLE_NAME) + "_ID");
																using ( DbDataAdapter da = dbf.CreateDataAdapter() )
																{
																	((IDbDataAdapter)da).SelectCommand = cmd;
																	using ( DataTable dtCurrentPanels = new DataTable() )
																	{
																		da.Fill(dtCurrentPanels);
																		foreach ( DataRow rowPanels in dtCurrentPanels.Rows )
																		{
																			lstCurrentPanels.Add(Sql.ToGuid(rowPanels["ID"]));
																		}
																	}
																}
															}
														}
														catch(Exception ex)
														{
															SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex.Message + ": " + sSQL);
														}
														IDbCommand spDASHBOARDS_PANELS_Update = SqlProcs.Factory(con, "spDASHBOARDS_PANELS_Update");
														spDASHBOARDS_PANELS_Update.Transaction = trn;
														foreach ( DataRow rowPanel in dtDASHBOARDS_PANELS.Rows )
														{
															Guid gPANEL_ID = Sql.ToGuid(rowPanel["ID"]);
															if ( lstCurrentPanels.Contains(gPANEL_ID) )
																lstCurrentPanels.Remove(gPANEL_ID);
															// 06/08/2021 Paul.  If Dashboard does not exist, then we may be creating a new from a default, so clear the panel ID. 
															else if ( !bRecordExists )
																gPANEL_ID = Guid.Empty;
															foreach ( IDbDataParameter par in spDASHBOARDS_PANELS_Update.Parameters )
															{
																string sParameterName = Sql.ExtractDbName(spDASHBOARDS_PANELS_Update, par.ParameterName).ToUpper();
																if ( sParameterName == "MODIFIED_USER_ID" )
																	par.Value = Sql.ToDBGuid(Security.USER_ID);
																else if ( sParameterName == "ID" )
																	par.Value = Sql.ToDBGuid(gPANEL_ID);
																else if ( sParameterName == "DASHBOARD_ID" )
																	par.Value = gID;
																else if ( dtDASHBOARDS_PANELS.Columns.Contains(sParameterName) )
																{
																	// 04/01/2020 Paul.  Move json utils to RestUtil. 
																	par.Value = RestUtil.DBValueFromJsonValue(par.DbType, rowPanel[sParameterName], T10n);
																}
																else
																	par.Value = DBNull.Value;
															}
															spDASHBOARDS_PANELS_Update.ExecuteNonQuery();
														}
														IDbCommand spDASHBOARDS_PANELS_Delete = SqlProcs.Factory(con, "spDASHBOARDS_PANELS_Delete");
														spDASHBOARDS_PANELS_Delete.Transaction = trn;
														foreach ( Guid gPANEL_ID in lstCurrentPanels )
														{
															foreach ( IDbDataParameter par in spDASHBOARDS_PANELS_Delete.Parameters )
															{
																string sParameterName = Sql.ExtractDbName(spDASHBOARDS_PANELS_Delete, par.ParameterName).ToUpper();
																if ( sParameterName == "MODIFIED_USER_ID" )
																	par.Value = Sql.ToDBGuid(Security.USER_ID);
																else if ( sParameterName == "ID" )
																	par.Value = gPANEL_ID;
															}
															spDASHBOARDS_PANELS_Delete.ExecuteNonQuery();
														}
														// 05/26/2019 Paul.  Clear the dashboard panels. 
														// 11/24/2021 Paul.  Only clear when updating dashboards. 
														Session.Remove("vwDASHBOARDS.ReactClient"       );
														Session.Remove("vwDASHBOARDS_PANELS.ReactClient");
													}
													// 10/08/2022 Paul.  All modules can potentiallys support merge.  A supported module will have a _Merge stored procedure. 
													if ( dict.ContainsKey("MergeIDs") )
													{
														nACLACCESS = SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "delete");
														if ( nACLACCESS < 0 )
														{
															throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + sMODULE_NAME + " merge"));
														}
														System.Collections.ArrayList arrID = dict["MergeIDs"] as System.Collections.ArrayList;
														if ( arrID != null )
														{
															using ( IDbCommand cmdMerge = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Merge") )
															{
																cmdMerge.Transaction = trn;
																Sql.SetParameter(cmdMerge, "@ID"              , gID             );
																Sql.SetParameter(cmdMerge, "@MODIFIED_USER_ID", Security.USER_ID);
																foreach ( object sMERGE_ID in arrID )
																{
																	Guid gMERGE_ID = Sql.ToGuid(sMERGE_ID);
																	if ( gMERGE_ID != gID )
																	{
																		Sql.SetParameter(cmdMerge, "@MERGE_ID", gMERGE_ID);
																		// 06/02/2009 Paul.  Only execute if not the primary record. 
																		cmdMerge.ExecuteNonQuery();
																	}
																}
															}
														}
													}
													trn.Commit();
												}
												catch(Exception ex)
												{
													// 02/13/2017 Paul.  Capture this error as the following can generate an "This SqlTransaction has completed" error on Azure. 
													try
													{
														trn.Rollback();
													}
													catch
													{
													}
													SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
													throw;
												}
											}
											// 10/08/2020 Paul.  Update current user session data. 
											if ( sTABLE_NAME == "USERS" && gID == Security.USER_ID )
											{
												string sPREV_EXTENSION = String.Empty;
												string sTHEME          = String.Empty;
												string sLANG           = String.Empty;
												string sEXTENSION      = String.Empty;
												Guid   gDEFAULT_TEAM   = Guid.Empty  ;
												if ( rowCurrent != null && rowCurrent.Table.Columns.Contains("EXTENSION") )
												{
													sPREV_EXTENSION = Sql.ToString(rowCurrent["EXTENSION"]);
												}
												sSQL = "select *"        + ControlChars.CrLf
												     + "  from vwUSERS"  + ControlChars.CrLf
												     + " where ID = @ID" + ControlChars.CrLf;
												using ( DataTable dtUser = new DataTable() )
												{
													using ( IDbCommand cmd = con.CreateCommand() )
													{
														cmd.CommandText = sSQL;
														Sql.AddParameter(cmd, "@ID", gID);
														using ( DbDataAdapter da = dbf.CreateDataAdapter() )
														{
															((IDbDataAdapter)da).SelectCommand = cmd;
															// 11/27/2009 Paul.  It may be useful to log the SQL during errors at this location. 
															da.Fill(dtUser);
															if ( dtUser.Rows.Count > 0 )
															{
																DataRow rowUser = dtUser.Rows[0];
																sTHEME        = Sql.ToString(rowUser["THEME"       ]);
																sLANG         = Sql.ToString(rowUser["LANG"        ]);
																sEXTENSION    = Sql.ToString(rowUser["EXTENSION"   ]);
																gDEFAULT_TEAM = Sql.ToGuid  (rowUser["DEFAULT_TEAM"]);
																if ( Sql.IsEmptyString(sTHEME) )
																	sTHEME = SplendidDefaults.Theme();
																// 09/04/2022 Paul.  sTHEME was getting set to the culture. 
																if ( Sql.IsEmptyString(sLANG) )
																	sLANG = SplendidDefaults.Culture();
															}
														}
													}
												}
												SplendidInit.LoadUserPreferences(gID, sTHEME, sLANG);
												if ( !Sql.IsEmptyString(sEXTENSION) )
												{
													Application["Users.EXTENSION." + sEXTENSION + ".USER_ID"] = gID;
													Application["Users.EXTENSION." + sEXTENSION + ".TEAM_ID"] = gDEFAULT_TEAM;
												}
												if ( sEXTENSION != sPREV_EXTENSION && !Sql.IsEmptyString(sPREV_EXTENSION) )
												{
													Application.Remove("Users.EXTENSION." + sPREV_EXTENSION + ".USER_ID");
													Application.Remove("Users.EXTENSION." + sPREV_EXTENSION + ".TEAM_ID");
												}
											}
											// 05/06/2021 Paul.  Update the cached data so that signature becomes live immediately. 
											if ( sTABLE_NAME == "USERS_SIGNATURES" )
											{
												SplendidCache.ClearUserSignatures();
											}
											// 11/23/2014 Paul.  Attachments require a separate step of inserting the content. 
											// 05/27/2016 Paul.  Move FILE_DATA inside main transaction. 
											/*
											if ( sTABLE_NAME == "VWNOTE_ATTACHMENTS" )
											{
												if ( dict.ContainsKey("FILE_DATA") )
												{
													string sFILE_DATA = Sql.ToString(dict["FILE_DATA"]);
													byte[] byFILE_DATA  = Convert.FromBase64String(sFILE_DATA);
													using ( IDbTransaction trn = Sql.BeginTransaction(con) )
													{
														try
														{
															Crm.NoteAttachments.LoadFile(gID, byFILE_DATA, trn);
															trn.Commit();
														}
														catch(Exception ex)
														{
															trn.Rollback();
															SplendidError.SystemError(new StackTrace(true).GetFrame(0),  Utils.ExpandException(ex));
														}
													}
												}
											}
											*/
											// 11/18/2014 Paul.  Send a SignalR alert if created. 
											if ( sTABLE_NAME == "CHAT_MESSAGES" )
											{
												/*
												// 11/19/2014 Paul.  A chat message can include an attachment.  We want to create the attachment prior sending the SignalR alert. 
												string sFILENAME       = String.Empty;
												string sFILE_MIME_TYPE = String.Empty;
												string sFILE_DATA      = String.Empty;
												foreach ( string sColumnName in dict.Keys )
												{
													// 03/16/2014 Paul.  Don't include Save Overrides as column names. 
													if ( String.Compare(sColumnName, "FILE_NAME") == 0 )
														sFILENAME = Sql.ToString(dict[sColumnName]);
													else if ( String.Compare(sColumnName, "FILE_TYPE") == 0 )
														sFILE_MIME_TYPE = Sql.ToString(dict[sColumnName]);
													else if ( String.Compare(sColumnName, "FILE_DATA") == 0 )
														sFILE_DATA = Sql.ToString(dict[sColumnName]);
												}
												if ( !Sql.IsEmptyString(sFILENAME) && !Sql.IsEmptyString(sFILE_DATA) )
												{
													try
													{
														byte[] byFILE_DATA  = Convert.FromBase64String(sFILE_DATA);
														string sFILE_EXT    = Path.GetExtension(sFILENAME);
														long lFileSize      = byFILE_DATA.Length;
														long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
														if ( (lUploadMaxSize > 0) && (lFileSize > lUploadMaxSize) )
														{
															throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
														}
														Guid   gTEAM_ID          = Security.TEAM_ID;
														Guid   gASSIGNED_USER_ID = Security.USER_ID;
														Guid   gMODIFIED_USER_ID = Security.USER_ID;
														string sTEAM_SET_LIST    = String.Empty;
														foreach ( DataColumn col in row.Table.Columns )
														{
															switch ( col.ColumnName.ToUpper() )
															{
																case "TEAM_ID"         :  gTEAM_ID          = Sql.ToGuid  (row[col.ColumnName]);  break;
																case "ASSIGNED_USER_ID":  gASSIGNED_USER_ID = Sql.ToGuid  (row[col.ColumnName]);  break;
																case "TEAM_SET_LIST"   :  sTEAM_SET_LIST    = Sql.ToString(row[col.ColumnName]);  break;
															}
														}
														
														using ( IDbTransaction trn = Sql.BeginTransaction(con) )
														{
															try
															{
																Guid gNOTE_ID = Guid.Empty;
																SqlProcs.spNOTES_Update
																	( ref gNOTE_ID
																	, L10n.Term("ChatMessages.LBL_ATTACHMENT") + sFILENAME
																	, "ChatMessages"  // Parent Type
																	, gID             // Parent ID
																	, Guid.Empty
																	, String.Empty
																	, gTEAM_ID
																	, sTEAM_SET_LIST
																	, gASSIGNED_USER_ID
																	// 05/17/2017 Paul.  Add Tags module. 
																	, String.Empty  // TAG_SET_NAME
																	// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
																	, false         // IS_PRIVATE
																	// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
																	, String.Empty  // ASSIGNED_SET_LIST
																	, trn
																	);
																Guid gNOTE_ATTACHMENT_ID = Guid.Empty;
																SqlProcs.spNOTE_ATTACHMENTS_Insert(ref gNOTE_ATTACHMENT_ID, gNOTE_ID, sFILENAME, sFILENAME, sFILE_EXT, sFILE_MIME_TYPE, trn);
																Crm.NoteAttachments.LoadFile(gNOTE_ATTACHMENT_ID, byFILE_DATA, trn);
																trn.Commit();
															}
															catch(Exception ex)
															{
																trn.Rollback();
																SplendidError.SystemError(new StackTrace(true).GetFrame(0),  Utils.ExpandException(ex));
															}
														}
													}
													catch(Exception ex)
													{
														SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
													}
												}
												*/
												// 08/05/2021 Paul.  ChatManager may not have been initialized. 
												if ( !bRecordExists && !Sql.ToBoolean(Application["CONFIG.SignalR.Disabled"]) && ChatManager.Instance != null )
												{
													ChatManager.Instance.NewMessage(gID);
												}
											}
											// 11/22/2023 Paul.  When unsyncing, we need to immediately clear the remote flag. 
											if ( sTABLE_NAME == "CONTACTS" )
											{
												if ( rowCurrent != null && rowCurrent.Table.Columns.Contains("SYNC_CONTACT") && dict.ContainsKey("SYNC_CONTACT") )
												{
													bool bSYNC_CONTACT_old = Sql.ToBoolean(rowCurrent["SYNC_CONTACT"]);
													bool bSYNC_CONTACT_new = Sql.ToBoolean(dict      ["SYNC_CONTACT"]);
													if ( bSYNC_CONTACT_old && !bSYNC_CONTACT_new )
													{
														ExchangeSync.UnsyncContact(Context, Security.USER_ID, gID);
													}
												}
											}
										}
										else
										{
											//DataRow rowError = dtResults.NewRow();
											//dtResults.Rows.Add(rowError);
											//rowError["ID"                   ] = gID;
											//rowError["SPLENDID_SYNC_STATUS" ] = "Access Denied";
											//rowError["SPLENDID_SYNC_MESSAGE"] = L10n.Term("ACL.LBL_NO_ACCESS");
											throw(new Exception(L10n.Term("ACL.LBL_NO_ACCESS")));
										}
									}
								}
								else
								{
									throw(new Exception(L10n.Term("ACL.LBL_NO_ACCESS")));
								}
							}
							else
							{
								// 06/21/2021 Paul.  Also throw if not rest enabled. 
								throw(new Exception(sTABLE_NAME + " does not exist in SYSTEM_REST_TABLES"));
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
			return gID;
		}

	}
}

