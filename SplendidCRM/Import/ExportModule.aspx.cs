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

namespace SplendidCRM.Import
{
	/// <summary>
	/// Summary description for ExportModule.
	/// </summary>
	public class ExportModule : SplendidPage
	{
		// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs
		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				Response.Headers.Add("Cache-Control", "no-cache");
				Response.Headers.Add("Pragma", "no-cache");
				L10N L10n = new L10N(Sql.ToString(Session["USER_SETTINGS/CULTURE"]));

				string sRequest = String.Empty;
				using ( StreamReader stmRequest = new StreamReader(Request.InputStream, System.Text.Encoding.UTF8) )
				{
					sRequest = stmRequest.ReadToEnd();
				}
				// http://weblogs.asp.net/hajan/archive/2010/07/23/javascriptserializer-dictionary-to-json-serialization-and-deserialization.aspx
				JavaScriptSerializer json = new JavaScriptSerializer();
				// 12/12/2014 Paul.  No reason to limit the Json result. 
				json.MaxJsonLength = int.MaxValue;
				Dictionary<string, object> dict = new Dictionary<string, object>();
				if ( !Sql.IsEmptyString(sRequest) )
					dict = json.Deserialize<Dictionary<string, object>>(sRequest);

				string ModuleName        = Sql.ToString (Request["ModuleName"]);
				int    nSKIP             = Sql.ToInteger(Request["$skip"     ]);
				int    nTOP              = Sql.ToInteger(Request["$top"      ]);
				// 11/18/2019 Paul.  Move exclusively to SqlSearchClause. 
				// 08/11/2020 Paul.  Revert back to query string support. 
				string sFILTER           = Sql.ToString (Request["$filter"   ]);
				string sORDER_BY         = Sql.ToString (Request["$orderby"  ]);
				// 06/17/2013 Paul.  Add support for GROUP BY. 
				string sGROUP_BY         = Sql.ToString (Request["$groupby"  ]);
				// 08/03/2011 Paul.  We need a way to filter the columns so that we can be efficient. 
				string sSELECT           = Sql.ToString (Request["$select"   ]);
				// 09/09/2019 Paul.  Send duplicate filter info. 
				string sDUPLICATE_FIELDS = Sql.ToString(Request["$duplicatefields"]);
				// 12/03/2019 Paul.  The React Client needs access to archive data. 
				bool   bArchiveView      = Sql.ToBoolean(Request["$archiveView"]);
				// 08/11/2020 Paul.  Allow values in query string. 
				string jsonSEARCH_VALUES = Sql.ToString(Request["$searchvalues"]);
				Dictionary<string, object> dictSearchValues = null;
				if ( !Sql.IsEmptyString(jsonSEARCH_VALUES) )
				{
					dictSearchValues = json.Deserialize<Dictionary<string, object>>(jsonSEARCH_VALUES);
				}
			
				Regex r = new Regex(@"[^A-Za-z0-9_]");
				// 10/19/2016 Paul.  We need to filter out quoted strings. 
				string sFILTER_KEYWORDS = Sql.SqlFilterLiterals(sFILTER);
				sFILTER_KEYWORDS = (" " + r.Replace(sFILTER_KEYWORDS, " ") + " ").ToLower();
				// 10/19/2016 Paul.  Add more rules to allow select keyword to be part of the contents. 
				// We do this to allow Full-Text Search, which is implemented as a sub-query. 
				int nSelectIndex     = sFILTER_KEYWORDS.IndexOf(" select "            );
				int nFromIndex       = sFILTER_KEYWORDS.IndexOf(" from "              );
				// 11/18/2019 Paul.  Remove all support for subqueries now that we support Post with search values. 
				//int nContainsIndex   = sFILTER_KEYWORDS.IndexOf(" contains "          );
				//int nConflictedIndex = sFILTER_KEYWORDS.IndexOf(" _remote_conflicted ");
				//// 07/26/2018 Paul.  Allow a normalized phone search that used the special phone tables. 
				//int nPhoneTableIndex = sFILTER_KEYWORDS.IndexOf(" vwphone_numbers_"   );
				//int nNormalizeIndex  = sFILTER_KEYWORDS.IndexOf(" normalized_number " );
				if ( nSelectIndex >= 0 && nFromIndex > nSelectIndex )
				{
					//if ( !(nContainsIndex > nFromIndex || nConflictedIndex > nFromIndex || (nPhoneTableIndex > nFromIndex && nNormalizeIndex > nPhoneTableIndex )) )
						throw(new Exception("Subqueries are not allowed."));
				}

				string     sExportFormat    = Sql.ToString(Request["$exportformat" ]);
				string     sExportRange     = Sql.ToString(Request["$exportrange"  ]);
				string     sSelecteditems   = Sql.ToString(Request["$selecteditems"]);
				List<Guid> arrSelectedItems = new List<Guid>();
				if ( !Sql.IsEmptyString(sSelecteditems) )
				{
					string[] arr = sSelecteditems.Split(',');
					for ( int i = 0; i < arr.Length; i++ )
					{
						Guid g =Sql.ToGuid(arr[i]);
						if ( !Sql.IsEmptyGuid(g) )
						{
							arrSelectedItems.Add(g);
						}
					}
				}
				// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
				Guid     gTIMEZONE = Sql.ToGuid  (Session["USER_SETTINGS/TIMEZONE"]);
				TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
				try
				{
					foreach ( string sName in dict.Keys )
					{
						switch ( sName )
						{
							case "ModuleName"      :  ModuleName        = Sql.ToString (dict[sName]);  break;
							case "$skip"           :  nSKIP             = Sql.ToInteger(dict[sName]);  break;
							case "$top"            :  nTOP              = Sql.ToInteger(dict[sName]);  break;
							case "$filter"         :  sFILTER           = Sql.ToString (dict[sName]);  break;
							case "$orderby"        :  sORDER_BY         = Sql.ToString (dict[sName]);  break;
							case "$groupby"        :  sGROUP_BY         = Sql.ToString (dict[sName]);  break;
							case "$select"         :  sSELECT           = Sql.ToString (dict[sName]);  break;
							case "$duplicatefields":  sDUPLICATE_FIELDS = Sql.ToString (dict[sName]);  break;
							case "$archiveView"    :  bArchiveView      = Sql.ToBoolean(dict[sName]);  break;
							case "$searchvalues"   :  dictSearchValues  = dict[sName] as Dictionary<string, object>;  break;
							case "$exportformat"   :  sExportFormat     = Sql.ToString (dict[sName]);  break;
							case "$exportrange"    :  sExportRange      = Sql.ToString (dict[sName]);  break;
							case "$selecteditems"  :
							{
								sSelecteditems = Sql.ToString (dict[sName]);
								if ( !Sql.IsEmptyString(sSelecteditems) )
								{
									string[] arr = sSelecteditems.Split(',');
									for ( int i = 0; i < arr.Length; i++ )
									{
										Guid g =Sql.ToGuid(arr[i]);
										if ( !Sql.IsEmptyGuid(g) )
										{
											arrSelectedItems.Add(g);
										}
									}
								}
								break;
							}
						}
					}
					if ( dictSearchValues != null )
					{
						string sSEARCH_VALUES = Sql.SqlSearchClause(Application, T10n, dictSearchValues);
						// 11/18/2019 Paul.  We need to combine sFILTER with sSEARCH_VALUES. 
						if ( !Sql.IsEmptyString(sSEARCH_VALUES) )
						{
							// 11/18/2019 Paul.  The search clause will always start with an "and" if it exists. 
							if ( !Sql.IsEmptyString(sFILTER) )
							{
								sFILTER = sFILTER + sSEARCH_VALUES;
							}
							else
							{
								sFILTER = "1 = 1 " + sSEARCH_VALUES;
							}
						}
					}
				}
				catch(Exception ex)
				{
					Debug.WriteLine(ex.Message);
					throw;
				}
				if ( Sql.IsEmptyString(ModuleName) )
					throw(new Exception("The module name must be specified."));
				if ( Sql.IsEmptyString(sExportFormat) )
					throw(new Exception("The export format must be specified."));
				if ( Sql.IsEmptyString(sExportRange) )
					throw(new Exception("The export range must be specified."));
				if ( sExportRange == "All" )
				{
					nSKIP = 0;
					nTOP = -1;
				}
				else if ( sExportRange == "Page" )
				{
					arrSelectedItems.Clear();
				}
				else if ( sExportRange == "Selected" )
				{
					// 10/17/2006 Paul.  There must be one selected record to continue. 
					if ( arrSelectedItems.Count == 0 )
						throw(new Exception(L10n.Term(".LBL_LISTVIEW_NO_SELECTED")));
				}
				else
				{
					throw(new Exception("The valid export range must be specified."));
				}
				// 12/15/2019 Paul.  Export has a layout list. 
				UniqueStringCollection arrSelectFields = new UniqueStringCollection();
				sSELECT = SplendidDynamic.ExportGridColumns(ModuleName + ".Export", arrSelectFields);

				string sTABLE_NAME = Sql.ToString(Application["Modules." + ModuleName + ".TableName"]);
				// 02/29/2016 Paul.  Product Catalog is different than Product Templates. 
				if ( ModuleName == "ProductCatalog" )
					sTABLE_NAME = "PRODUCT_CATALOG";
				// 09/09/2019 Paul.  The Activities module collies with the Calendar list, so we have to make an exception. 
				if ( ModuleName == "Activities" )
					sTABLE_NAME = "vwACTIVITIES";
				// 09/09/2019 Paul.  The Employees module refers to the USERS table, so correct. 
				if ( ModuleName == "Employees" )
					sTABLE_NAME = "vwEMPLOYEES_Sync";
				if ( Sql.IsEmptyString(sTABLE_NAME) )
					throw(new Exception("Unknown module: " + ModuleName));
				// 08/22/2011 Paul.  Add admin control to REST API. 
				int nACLACCESS = Security.GetUserAccess(ModuleName, "export");
				if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + ModuleName + ".RestEnabled"]) || nACLACCESS < 0 )
				{
					// 09/06/2017 Paul.  Include module name in error. 
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(ModuleName)));
				}
				UniqueStringCollection arrSELECT = new UniqueStringCollection();
				// 08/11/2020 Paul.  We don't need to remove spaces as the string comes from SplendidDynamic.ExportGridColumns(). 
				//sSELECT = sSELECT.Replace(" ", "");
				if ( !Sql.IsEmptyString(sSELECT) )
				{
					foreach ( string s in sSELECT.Split(',') )
					{
						//string sColumnName = r.Replace(s, "");
						if ( !Sql.IsEmptyString(s) )
							arrSELECT.Add(s);
					}
				}
			
				// 06/17/2013 Paul.  Add support for GROUP BY. 
				// 04/21/2017 Paul.  We need to return the total when using nTOP. 
				long lTotalCount = 0;
				// 05/21/2017 Paul.  HTML5 Dashboard requires aggregates. 
				// 08/01/2019 Paul.  We need a ListView and EditView flags for the Rest Client. 
				// 09/09/2019 Paul.  Send duplicate filter info. 
				// 10/26/2019 Paul.  Return the SQL to the React Client. 
				StringBuilder sbDumpSQL = new StringBuilder();
				// 12/03/2019 Paul.  The React Client needs access to archive data. 
				// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs
				DataTable dt = new DataTable();
				bool bIsAdmin = Sql.ToBoolean(Application["Modules." + ModuleName + ".IsAdmin"]);
				if ( bIsAdmin )
				{
					if ( !Sql.IsEmptyString(ModuleName) && !sTABLE_NAME.StartsWith("OAUTH") && !sTABLE_NAME.StartsWith("USERS_PASSWORD") && !sTABLE_NAME.EndsWith("_AUDIT") && !sTABLE_NAME.EndsWith("_STREAM") )
					{
						if ( SplendidCRM.Security.AdminUserAccess(ModuleName, "access") >= 0 )
						{
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs
							// 10/16/2020 Paul.  Use AccessMode.list so that we use the _List view if available. 
							dt = RestUtil.GetAdminTable(Context, sTABLE_NAME, nSKIP, nTOP, sFILTER, sORDER_BY, sGROUP_BY, arrSELECT, arrSelectedItems.ToArray(), ref lTotalCount, null, AccessMode.list, sbDumpSQL);
						}
						else
						{
							throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
						}
					}
					else
					{
						throw(new Exception("Unsupported module: " + ModuleName));
					}
				}
				else
				{
					dt = RestUtil.GetTable(Context, sTABLE_NAME, nSKIP, nTOP, sFILTER, sORDER_BY, sGROUP_BY, arrSELECT, arrSelectedItems.ToArray(), ref lTotalCount, null, AccessMode.list, bArchiveView, sDUPLICATE_FIELDS, sbDumpSQL);
				}
				DataView vwMain = new DataView(dt);
				// 12/14/2019 Paul.  I'm not sure why this was necessary in the ListView code, but we are going to rely upon the Security.Filter() to manage. 
				//if ( nACLACCESS == ACL_ACCESS.OWNER )
				//	vwMain.RowFilter = "ASSIGNED_USER_ID = '" + Security.USER_ID.ToString() + "'";

				//SplendidExport.Export(vwMain, ModuleName, sExportFormat, sExportRange, 0, nTOP, null, true);
				int    nStartRecord        = 0;
				int    nEndRecord          = vwMain.Count;

				switch ( sExportFormat )
				{
					case "csv"  :
					{
						Response.ContentType = "text/csv";
						// 08/06/2008 yxy21969.  Make sure to encode all URLs. 
						// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
						Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(HttpContext.Current.Request.Browser, ModuleName + ".csv"));
						SplendidExport.ExportDelimited(Response.OutputStream, vwMain, ModuleName, nStartRecord, nEndRecord, ',' );
						// 10/28/2020 Paul.  Response.End() is causing an exception and "Thread was being aborted." to be appended. 
						//Response.End();
						break;
					}
					case "tab"  :
					{
						// 08/17/2024 Paul.  The correct MIME type is text/plain. 
						Response.ContentType = "text/plain";
						// 08/06/2008 yxy21969.  Make sure to encode all URLs. 
						// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
						Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(HttpContext.Current.Request.Browser, ModuleName + ".txt"));
						SplendidExport.ExportDelimited(Response.OutputStream, vwMain, ModuleName, nStartRecord, nEndRecord, '\t');
						// 10/28/2020 Paul.  Response.End() is causing an exception and "Thread was being aborted." to be appended. 
						//Response.End();
						break;
					}
					case "xml"  :
					{
						Response.ContentType = "text/xml";
						// 08/06/2008 yxy21969.  Make sure to encode all URLs. 
						// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
						Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(HttpContext.Current.Request.Browser, ModuleName + ".xml"));
						SplendidExport.ExportXml(Response.OutputStream, vwMain, ModuleName, nStartRecord, nEndRecord);
						// 10/28/2020 Paul.  Response.End() is causing an exception and "Thread was being aborted." to be appended. 
						//Response.End();
						break;
					}
					//case "Excel":
					default     :
					{
						// 08/25/2012 Paul.  Change Excel export type to use Open XML as the previous format is not supported on Office 2010. 
						Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";  //"application/vnd.ms-excel";
						// 08/25/2012 Paul.  Change Excel export type to use Open XML as the previous format is not supported on Office 2010. 
						// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
						Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(HttpContext.Current.Request.Browser, ModuleName + ".xlsx"));
						SplendidExport.ExportExcelOpenXML(Response.OutputStream, vwMain, ModuleName, nStartRecord, nEndRecord);
						// 08/11/2020 Paul.  Flush is critical, otherwise we get extra bytes and Excel reports the file as corrupt. 
						Response.Flush();
						// 10/28/2020 Paul.  Response.End() is causing an exception and "Thread was being aborted." to be appended. 
						//Response.End();
						break;
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.ContentType = "text/plain";
				Response.Write(ex.Message);
			}
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}
