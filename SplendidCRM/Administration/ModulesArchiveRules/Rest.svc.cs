/*
 * Copyright (C) 2013-2021 SplendidCRM Software, Inc. All Rights Reserved. 
 *
 * Any use of the contents of this file are subject to the SplendidCRM Professional Source Code License 
 * Agreement, or other written agreement between you and SplendidCRM ("License"). By installing or 
 * using this file, you have unconditionally agreed to the terms and conditions of the License, 
 * including but not limited to restrictions on the number of users therein, and you may not use this 
 * file except in compliance with the License. 
 * 
 * SplendidCRM owns all proprietary rights, including all copyrights, patents, trade secrets, and 
 * trademarks, in and to the contents of this file.  You will not link to or in any way combine the 
 * contents of this file or any derivatives with any Open Source Code in any manner that would require 
 * the contents of this file to be made available to any third party. 
 * 
 * IN NO EVENT SHALL SPLENDIDCRM BE RESPONSIBLE FOR ANY DAMAGES OF ANY KIND, INCLUDING ANY DIRECT, 
 * SPECIAL, PUNITIVE, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES.  Other limitations of liability 
 * and disclaimers set forth in the License. 
 * 
 */
using System;
using System.IO;
using System.Xml;
using System.Web;
using System.Web.SessionState;
using System.Data;
using System.Data.Common;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;
using System.ServiceModel;
using System.ServiceModel.Activation;
using System.Web.Script.Serialization;
using System.Threading;
using System.Diagnostics;

namespace SplendidCRM.Administration.ModulesArchiveRules
{
	[ServiceContract]
	[ServiceBehavior( IncludeExceptionDetailInFaults = true )]
	[AspNetCompatibilityRequirements( RequirementsMode = AspNetCompatibilityRequirementsMode.Required )]
	public class Rest
	{
		[OperationContract]
		public Guid UpdateModule(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			// http://weblogs.asp.net/hajan/archive/2010/07/23/javascriptserializer-dictionary-to-json-serialization-and-deserialization.aspx
			JavaScriptSerializer json = new JavaScriptSerializer();
			// 12/12/2014 Paul.  No reason to limit the Json result. 
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);

			string sModuleName = "ModulesArchiveRules";
			L10N L10n       = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			int  nACLACCESS = Security.GetUserAccess(sModuleName, "edit");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + sModuleName + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				// 09/06/2017 Paul.  Include module name in error. 
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + sModuleName));
			}
			// 11/16/2014 Paul.  We need to continually update the SplendidSession so that it expires along with the ASP.NET Session. 
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sTableName = Sql.ToString(Application["Modules." + sModuleName + ".TableName"]);
			if ( Sql.IsEmptyString(sTableName) )
				throw(new Exception("Unknown module: " + sModuleName));

			bool bPrimaryKeyOnly   = true ;
			bool bUseSQLParameters = false;
			bool bDesignChart      = false;
			bool bUserSpecific     = false;
			RdlDocument rdl = new RdlDocument(String.Empty, String.Empty, bDesignChart);
			Guid   gID                = Guid.Empty  ;
			string sNAME              = String.Empty;
			string sMODULE            = String.Empty;
			string sRELATED           = String.Empty;
			Dictionary<string, object> dictFilterXml        = null;
			Dictionary<string, object> dictRelatedModuleXml = null;
			Dictionary<string, object> dictRelationshipXml  = null;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"               :  gID                  = Sql.ToGuid  (dict[sColumnName]);  break;
					case "NAME"             :  sNAME                = Sql.ToString(dict[sColumnName]);  break;
					// 02/09/2022 Paul.  Keep using MODULE to match Reports. 
					case "MODULE"           :  sMODULE              = Sql.ToString(dict[sColumnName]);  break;
					// 08/12/2023 Paul.  Must keep MODULE_NAME as that is what is used by RulesWizard.EditView. 
					case "MODULE_NAME"      :  sMODULE              = Sql.ToString(dict[sColumnName]);  break;
					case "filterXml"        :  dictFilterXml        = dict[sColumnName] as Dictionary<string, object>;  break;
					case "relatedModuleXml" :  dictRelatedModuleXml = dict[sColumnName] as Dictionary<string, object>;  break;
					case "relationshipXml"  :  dictRelationshipXml  = dict[sColumnName] as Dictionary<string, object>;  break;
				}
			}
			// 05/16/2021 Paul.  Precheck access to filter module. 
			nACLACCESS = Security.GetUserAccess(sMODULE, "edit");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + sMODULE + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + sMODULE));
			}
			rdl.SetCustomProperty             ("Module"        , sMODULE     );
			rdl.SetCustomProperty             ("Related"       , sRELATED    );
			// 06/02/2021 Paul.  React client needs to share code. 
			rdl.SetFiltersCustomProperty      (dictFilterXml       );
			rdl.SetRelatedModuleCustomProperty(dictRelatedModuleXml);
			rdl.SetRelationshipCustomProperty (dictRelationshipXml );
			
			Hashtable hashAvailableModules = new Hashtable();
			StringBuilder sbErrors = new StringBuilder();
			string sReportSQL = String.Empty;
			sReportSQL = Reports.QueryBuilder.BuildReportSQL(Application, rdl, bPrimaryKeyOnly, bUseSQLParameters, bDesignChart, bUserSpecific, sMODULE, sRELATED, hashAvailableModules, sbErrors);
			if ( sbErrors.Length > 0 )
				throw(new Exception(sbErrors.ToString()));
			
			rdl.SetDataSetFields(hashAvailableModules);
			rdl.SetSingleNode("DataSets/DataSet/Query/CommandText", sReportSQL);
			// 06/06/2021 Paul.  Keys may already exist in dictionary, so assign instead. 
			dict["FILTER_SQL"] = sReportSQL  ;
			dict["FILTER_XML"] = rdl.OuterXml;

			// 06/21/2021 Paul.  Move bExcludeSystemTables to method parameter so that it can be used by admin REST methods. 
			gID = RestUtil.UpdateTable(HttpContext.Current, sTableName, dict, false);
			if ( dict.ContainsKey("NAME") )
			{
				string sName = String.Empty;
				if ( dict.ContainsKey("NAME") )
					sName = Sql.ToString(dict["NAME"]);
				try
				{
					if ( !Sql.IsEmptyString(sName) )
						SqlProcs.spTRACKER_Update(Security.USER_ID, sModuleName, gID, sName, "save");
				}
				catch(Exception ex)
				{
					// 04/28/2019 Paul.  There is no compelling reason to send this error to the user. 
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				}
			}
			return gID;
		}

		[OperationContract]
		public Stream GetPreviewFilter(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			// http://weblogs.asp.net/hajan/archive/2010/07/23/javascriptserializer-dictionary-to-json-serialization-and-deserialization.aspx
			JavaScriptSerializer json = new JavaScriptSerializer();
			// 12/12/2014 Paul.  No reason to limit the Json result. 
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);

			string sModuleName = "ModulesArchiveRules";
			L10N L10n       = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			int  nACLACCESS = Security.GetUserAccess(sModuleName, "edit");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + sModuleName + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				// 09/06/2017 Paul.  Include module name in error. 
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + sModuleName));
			}
			// 11/16/2014 Paul.  We need to continually update the SplendidSession so that it expires along with the ASP.NET Session. 
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sTableName = Sql.ToString(Application["Modules." + sModuleName + ".TableName"]);
			if ( Sql.IsEmptyString(sTableName) )
				throw(new Exception("Unknown module: " + sModuleName));

			bool bPrimaryKeyOnly   = true ;
			bool bUseSQLParameters = false;
			bool bDesignChart      = false;
			bool bUserSpecific     = false;
			RdlDocument rdl = new RdlDocument(String.Empty, String.Empty, bDesignChart);
			Guid   gID                = Guid.Empty  ;
			string sNAME              = String.Empty;
			string sMODULE            = String.Empty;
			string sRELATED           = String.Empty;
			Dictionary<string, object> dictFilterXml        = null;
			Dictionary<string, object> dictRelatedModuleXml = null;
			Dictionary<string, object> dictRelationshipXml  = null;
			int    nSKIP              = Sql.ToInteger(Request["$skip"     ]);
			int    nTOP               = Sql.ToInteger(Request["$top"      ]);
			string sORDER_BY          = Sql.ToString (Request["$orderby"  ]);
			string sSELECT            = Sql.ToString (Request["$select"   ]);
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "NAME"             :  sNAME                = Sql.ToString(dict[sColumnName]);  break;
					// 02/09/2022 Paul.  Keep using MODULE to match Reports. 
					case "MODULE"           :  sMODULE              = Sql.ToString(dict[sColumnName]);  break;
					// 08/12/2023 Paul.  Must keep MODULE_NAME as that is what is used by RulesWizard.EditView. 
					case "MODULE_NAME"      :  sMODULE              = Sql.ToString(dict[sColumnName]);  break;
					case "filterXml"        :  dictFilterXml        = dict[sColumnName] as Dictionary<string, object>;  break;
					case "relatedModuleXml" :  dictRelatedModuleXml = dict[sColumnName] as Dictionary<string, object>;  break;
					case "relationshipXml"  :  dictRelationshipXml  = dict[sColumnName] as Dictionary<string, object>;  break;
					case "$skip"            :  nSKIP                = Sql.ToInteger(dict[sColumnName]);  break;
					case "$top"             :  nTOP                 = Sql.ToInteger(dict[sColumnName]);  break;
					case "$orderby"         :  sORDER_BY            = Sql.ToString (dict[sColumnName]);  break;
					case "$select"          :  sSELECT              = Sql.ToString (dict[sColumnName]);  break;
				}
			}
			// 05/16/2021 Paul.  Precheck access to filter module. 
			nACLACCESS = Security.AdminUserAccess(sMODULE, "edit");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + sMODULE + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + sMODULE));
			}
			rdl.SetCustomProperty              ("Module"        , sMODULE );
			rdl.SetCustomProperty              ("Related"       , sRELATED);
			// 06/02/2021 Paul.  React client needs to share code. 
			rdl.SetFiltersCustomProperty       (dictFilterXml       );
			rdl.SetRelatedModuleCustomProperty (dictRelatedModuleXml);
			rdl.SetRelationshipCustomProperty  (dictRelationshipXml );
			
			Hashtable hashAvailableModules = new Hashtable();
			StringBuilder sbErrors = new StringBuilder();
			string sReportSQL = String.Empty;
			sReportSQL = Reports.QueryBuilder.BuildReportSQL(Application, rdl, bPrimaryKeyOnly, bUseSQLParameters, bDesignChart, bUserSpecific, sMODULE, sRELATED, hashAvailableModules, sbErrors);
			if ( sbErrors.Length > 0 )
				throw(new Exception(sbErrors.ToString()));
			
			long     lTotalCount = 0;
			Guid     gTIMEZONE   = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n        = TimeZone.CreateTimeZone(gTIMEZONE);
			string   sBaseURI    = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath.Replace("/GetModuleList", "/GetModuleItem");
			
			Regex r = new Regex(@"[^A-Za-z0-9_]");
			UniqueStringCollection arrSELECT = new UniqueStringCollection();
			sSELECT = sSELECT.Replace(" ", "");
			if ( !Sql.IsEmptyString(sSELECT) )
			{
				foreach ( string s in sSELECT.Split(',') )
				{
					string sColumnName = r.Replace(s, "");
					if ( !Sql.IsEmptyString(sColumnName) )
						arrSELECT.Add(sColumnName);
				}
			}
			
			string sLastCommand = String.Empty;
			StringBuilder sbDumpSQL = new StringBuilder();
			DataTable dt = new DataTable();
			string sTABLE_NAME = Crm.Modules.TableName(sMODULE);
			string sVIEW_NAME = "vw" + sTABLE_NAME + "_List";
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					string sSelectSQL = String.Empty;
					if ( arrSELECT != null && arrSELECT.Count > 0 )
					{
						foreach ( string sColumnName in arrSELECT )
						{
							if ( Sql.IsEmptyString(sSelectSQL) )
								sSelectSQL += "select " + sVIEW_NAME + "." + sColumnName + ControlChars.CrLf;
							else
								sSelectSQL += "     , " + sVIEW_NAME + "." + sColumnName + ControlChars.CrLf;
						}
					}
					else
					{
						sSelectSQL = "select " + sVIEW_NAME + ".*" + ControlChars.CrLf;
					}
					cmd.CommandText = sSelectSQL;
					cmd.CommandText += "  from " + sVIEW_NAME + ControlChars.CrLf;
					Security.Filter(cmd, sMODULE, "list");
					if ( !Sql.IsEmptyString(sReportSQL) )
					{
						cmd.CommandText += "   and ID in " + ControlChars.CrLf 
						                + "(" + sReportSQL + ")" + ControlChars.CrLf;
					}
					if ( Sql.IsEmptyString(sORDER_BY.Trim()) )
					{
						sORDER_BY = " order by " + sVIEW_NAME + ".DATE_MODIFIED_UTC" + ControlChars.CrLf;
					}
					else
					{
						r = new Regex(@"[^A-Za-z0-9_, ]");
						sORDER_BY = " order by " + r.Replace(sORDER_BY, "") + ControlChars.CrLf;
					}
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						dt = new DataTable(sTABLE_NAME);
						if ( nTOP > 0 )
						{
							lTotalCount = -1;
							if ( cmd.CommandText.StartsWith(sSelectSQL) )
							{
								string sOriginalSQL = cmd.CommandText;
								cmd.CommandText = "select count(*) " + ControlChars.CrLf + cmd.CommandText.Substring(sSelectSQL.Length);
								sLastCommand += Sql.ExpandParameters(cmd) + ';' + ControlChars.CrLf;
								lTotalCount = Sql.ToLong(cmd.ExecuteScalar());
								cmd.CommandText = sOriginalSQL;
							}
							if ( nSKIP > 0 )
							{
								int nCurrentPageIndex = nSKIP / nTOP;
								Sql.PageResults(cmd, sTABLE_NAME, sORDER_BY, nCurrentPageIndex, nTOP);
								sLastCommand += Sql.ExpandParameters(cmd);
								da.Fill(dt);
							}
							else
							{
								cmd.CommandText += sORDER_BY;
								using ( DataSet ds = new DataSet() )
								{
									ds.Tables.Add(dt);
									sLastCommand += Sql.ExpandParameters(cmd);
									da.Fill(ds, 0, nTOP, sTABLE_NAME);
								}
							}
						}
						else
						{
							cmd.CommandText += sORDER_BY;
							sLastCommand = Sql.ExpandParameters(cmd);
							da.Fill(dt);
							lTotalCount = dt.Rows.Count;
						}
						sbDumpSQL.Append(sLastCommand);
					}
				}
			}
			
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, sMODULE, dt, T10n);
			dictResponse.Add("__total", lTotalCount);
			if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
			{
				dictResponse.Add("__sql", sbDumpSQL.ToString());
			}
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}
	}
}
