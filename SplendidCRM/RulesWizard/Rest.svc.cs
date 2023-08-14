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
using System.Data;
using System.Data.Common;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.ServiceModel.Activation;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using System.Workflow.Activities.Rules;
using System.Collections;
using System.Diagnostics;

namespace SplendidCRM.RulesWizard
{
	[ServiceContract]
	[ServiceBehavior( IncludeExceptionDetailInFaults = true )]
	[AspNetCompatibilityRequirements( RequirementsMode = AspNetCompatibilityRequirementsMode.Required )]
	public class Rest
	{
		[OperationContract]
		public void ValidateRule(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);

			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			Guid   gRULE_ID      = Guid.NewGuid();
			string sRULE_NAME    = Guid.NewGuid().ToString();
			string sRULE_TYPE    = (dict.ContainsKey("RULE_TYPE"   ) ? Sql.ToString (dict["RULE_TYPE"   ]) : String.Empty);
			int    nPRIORITY     = (dict.ContainsKey("PRIORITY"    ) ? Sql.ToInteger(dict["PRIORITY"    ]) : 0           );
			string sREEVALUATION = (dict.ContainsKey("REEVALUATION") ? Sql.ToString (dict["REEVALUATION"]) : String.Empty);
			bool   bACTIVE       = (dict.ContainsKey("ACTIVE"      ) ? Sql.ToBoolean(dict["ACTIVE"      ]) : true        );
			string sCONDITION    = (dict.ContainsKey("CONDITION"   ) ? Sql.ToString (dict["CONDITION"   ]) : String.Empty);
			string sTHEN_ACTIONS = (dict.ContainsKey("THEN_ACTIONS") ? Sql.ToString (dict["THEN_ACTIONS"]) : String.Empty);
			string sELSE_ACTIONS = (dict.ContainsKey("ELSE_ACTIONS") ? Sql.ToString (dict["ELSE_ACTIONS"]) : String.Empty);
			if ( Sql.IsEmptyString(sRULE_TYPE) )
			{
				throw(new Exception("RULE_TYPE was not specified"));
			}
			
			SplendidRulesTypeProvider typeProvider = new SplendidRulesTypeProvider();
			Type ruleType = typeof(SplendidWizardThis);
			switch ( sRULE_TYPE )
			{
				case "Import"  :  ruleType = typeof(SplendidImportThis );  break;
				// 08/12/2023 Paul.  Should be SplendidReportThis. 
				case "Report"  :  ruleType = typeof(SplendidReportThis);  break;
				case "Business":  ruleType = typeof(SplendidControlThis);  break;
				case "Wizard"  :  ruleType = typeof(SplendidWizardThis );  break;
				default        :  throw(new Exception("Unknown rule type: " + sRULE_TYPE));
			}
			RulesUtil.RulesValidate(gRULE_ID, sRULE_NAME, nPRIORITY, sREEVALUATION, bACTIVE, sCONDITION, sTHEN_ACTIONS, sELSE_ACTIONS, ruleType, typeProvider);
		}

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

			string sModuleName = "RulesWizard";
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
			string sRULE_TYPE         = String.Empty;
			Dictionary<string, object> dictFilterXml        = null;
			Dictionary<string, object> dictRelatedModuleXml = null;
			Dictionary<string, object> dictRelationshipXml  = null;
			Dictionary<string, object> dictRulesXml         = null;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"               :  gID                  = Sql.ToGuid  (dict[sColumnName]);  break;
					case "NAME"             :  sNAME                = Sql.ToString(dict[sColumnName]);  break;
					// 02/09/2022 Paul.  Keep using MODULE to match Reports. 
					case "MODULE"           :  sMODULE              = Sql.ToString(dict[sColumnName]);  break;
					// 08/01/2023 Paul.  Must keep MODULE_NAME as that is what is used by RulesWizard.EditView. 
					case "MODULE_NAME"      :  sMODULE              = Sql.ToString(dict[sColumnName]);  break;
					case "RELATED"          :  sRELATED             = Sql.ToString(dict[sColumnName]);  break;
					case "RULE_TYPE"        :  sRULE_TYPE           = Sql.ToString(dict[sColumnName]);  break;
					case "filterXml"        :  dictFilterXml        = dict[sColumnName] as Dictionary<string, object>;  break;
					case "relatedModuleXml" :  dictRelatedModuleXml = dict[sColumnName] as Dictionary<string, object>;  break;
					case "relationshipXml"  :  dictRelationshipXml  = dict[sColumnName] as Dictionary<string, object>;  break;
					case "rulesXml"         :  dictRulesXml         = dict[sColumnName] as Dictionary<string, object>;  break;
				}
			}
			if ( Sql.IsEmptyString(sRULE_TYPE) )
			{
				throw(new Exception("RULE_TYPE was not specified"));
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
			// 06/02/2021 Paul.  React client needs to share code. 
			DataTable dtRules = RulesUtil.BuildRuleDataTable(dictRulesXml);
			
			Hashtable hashAvailableModules = new Hashtable();
			StringBuilder sbErrors = new StringBuilder();
			string sReportSQL = String.Empty;
			sReportSQL = Reports.QueryBuilder.BuildReportSQL(Application, rdl, bPrimaryKeyOnly, bUseSQLParameters, bDesignChart, bUserSpecific, sMODULE, sRELATED, hashAvailableModules, sbErrors);
			if ( sbErrors.Length > 0 )
				throw(new Exception(sbErrors.ToString()));
			
			rdl.SetDataSetFields(hashAvailableModules);
			rdl.SetSingleNode("DataSets/DataSet/Query/CommandText", sReportSQL);
			
			// 12/12/2012 Paul.  For security reasons, we want to restrict the data types available to the rules wizard. 
			SplendidRulesTypeProvider typeProvider = new SplendidRulesTypeProvider();
			Type ruleType = typeof(SplendidWizardThis);
			switch ( sRULE_TYPE )
			{
				case "Import"  :  ruleType = typeof(SplendidImportThis );  break;
				// 08/12/2023 Paul.  Should be SplendidReportThis. 
				case "Report"  :  ruleType = typeof(SplendidReportThis);  break;
				case "Business":  ruleType = typeof(SplendidControlThis);  break;
				case "Wizard"  :  ruleType = typeof(SplendidWizardThis );  break;
				default        :  throw(new Exception("Unknown rule type: " + sRULE_TYPE));
			}
			RuleValidation validation = new RuleValidation(ruleType, typeProvider);
			RuleSet rules = RulesUtil.BuildRuleSet(dtRules, validation);
			
			// 05/17/2021 Paul.  Must set the table name in order to serialize.  Must be Table1. 
			dtRules.TableName = "Table1";
			string sXOML = RulesUtil.Serialize(rules);
			StringBuilder sbRulesXML = new StringBuilder();
			using ( StringWriter wtr = new StringWriter(sbRulesXML, System.Globalization.CultureInfo.InvariantCulture) )
			{
				dtRules.WriteXml(wtr, XmlWriteMode.WriteSchema, false);
			}
			// 06/06/2021 Paul.  Keys may already exist in dictionary, so assign instead. 
			dict["FILTER_SQL"] = sReportSQL           ;
			dict["FILTER_XML"] = rdl.OuterXml         ;
			dict["RULES_XML" ] = sbRulesXML.ToString();

			gID = RestUtil.UpdateTable(HttpContext.Current, sTableName, dict);
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

			string sModuleName = "RulesWizard";
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
					case "RELATED"          :  sRELATED             = Sql.ToString(dict[sColumnName]);  break;
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
			nACLACCESS = Security.GetUserAccess(sMODULE, "edit");
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

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetPreviewRules()
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			
			string sModuleName = "RulesWizard";
			int nACLACCESS = Security.GetUserAccess(sModuleName, "list");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + sModuleName + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 09/06/2017 Paul.  Include module name in error. 
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(sModuleName)));
			}
			int    nSKIP            = Sql.ToInteger(Request.QueryString["$skip"          ]);
			int    nTOP             = Sql.ToInteger(Request.QueryString["$top"           ]);
			string sORDER_BY        = Sql.ToString (Request.QueryString["$orderby"       ]);
			string sProcessedFileID = Sql.ToString (Request.QueryString["ProcessedFileID"]);

			long lTotalCount = 0;
			DataTable dt = new DataTable();
			string sProcessedFileName = Sql.ToString(Session["TempFile." + sProcessedFileID]);
			string sProcessedPathName = Path.Combine(Path.GetTempPath(), sProcessedFileName);
			if ( File.Exists(sProcessedPathName) )
			{
				DataSet dsProcessed = new DataSet();
				dsProcessed.ReadXml(sProcessedPathName);
				if ( dsProcessed.Tables.Count == 1 )
				{
					DataTable dtProcessed = dsProcessed.Tables[0];
					DataView vwProcessed = new DataView(dtProcessed);
					if ( Sql.IsEmptyString(sORDER_BY.Trim()) )
					{
						vwProcessed.Sort = "IMPORT_ROW_NUMBER";
					}
					else
					{
						vwProcessed.Sort = sORDER_BY;
					}

					lTotalCount = vwProcessed.Count;
					// 05/23/2020 Paul.  Clone the table, then add the paginated records. 
					dt = dtProcessed.Clone();
					for ( int i = nSKIP; i >= 0 && i < lTotalCount && dt.Rows.Count < nTOP; i++ )
					{
						DataRow row = vwProcessed[i].Row;
						DataRow newRow = dt.NewRow();
						dt.Rows.Add(newRow);
						for ( int j = 0; j < dtProcessed.Columns.Count; j++ )
						{
							newRow[j] = row[j];
						}
					}
				}
			}
			string sBaseURI = String.Empty;
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			
			Guid     gTIMEZONE         = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n              = TimeZone.CreateTimeZone(gTIMEZONE);
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, sModuleName, dt, T10n);
			dictResponse.Add("__total", lTotalCount);
			
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		[OperationContract]
		public Stream SubmitRules(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpResponse         Response    = HttpContext.Current.Response   ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
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

			string sModuleName = "RulesWizard";
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
			Guid   gASSIGNED_USER_ID  = Security.USER_ID;
			string sASSIGNED_SET_LIST = String.Empty;
			Guid   gTEAM_ID           = Security.TEAM_ID;
			string sTEAM_SET_LIST     = String.Empty;
			string sTAG_SET_NAME      = String.Empty;
			string sDESCRIPTION       = String.Empty;
			bool   bPreview           = false;
			bool   bUseTransaction    = false;
			Dictionary<string, object> dictFilterXml        = null;
			Dictionary<string, object> dictRelatedModuleXml = null;
			Dictionary<string, object> dictRelationshipXml  = null;
			Dictionary<string, object> dictRulesXml         = null;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "NAME"             :  sNAME                = Sql.ToString (dict[sColumnName]);  break;
					// 02/09/2022 Paul.  Keep using MODULE to match Reports. 
					case "MODULE"           :  sMODULE              = Sql.ToString(dict[sColumnName]);  break;
					// 08/12/2023 Paul.  Must keep MODULE_NAME as that is what is used by RulesWizard.EditView. 
					case "MODULE_NAME"      :  sMODULE              = Sql.ToString(dict[sColumnName]);  break;
					case "RELATED"          :  sRELATED             = Sql.ToString (dict[sColumnName]);  break;
					case "ASSIGNED_USER_ID" :  gASSIGNED_USER_ID    = Sql.ToGuid   (dict[sColumnName]);  break;
					case "ASSIGNED_SET_LIST":  sASSIGNED_SET_LIST   = Sql.ToString (dict[sColumnName]);  break;
					case "TEAM_ID"          :  gTEAM_ID             = Sql.ToGuid   (dict[sColumnName]);  break;
					case "TEAM_SET_LIST"    :  sTEAM_SET_LIST       = Sql.ToString (dict[sColumnName]);  break;
					case "TAG_SET_NAME"     :  sTAG_SET_NAME        = Sql.ToString (dict[sColumnName]);  break;
					case "DESCRIPTION"      :  sDESCRIPTION         = Sql.ToString (dict[sColumnName]);  break;
					case "Preview"          :  bPreview             = Sql.ToBoolean(dict[sColumnName]);  break;
					case "UseTransaction"   :  bUseTransaction      = Sql.ToBoolean(dict[sColumnName]);  break;
					case "filterXml"        :  dictFilterXml        = dict[sColumnName] as Dictionary<string, object>;  break;
					case "relatedModuleXml" :  dictRelatedModuleXml = dict[sColumnName] as Dictionary<string, object>;  break;
					case "relationshipXml"  :  dictRelationshipXml  = dict[sColumnName] as Dictionary<string, object>;  break;
					case "rulesXml"         :  dictRulesXml         = dict[sColumnName] as Dictionary<string, object>;  break;
				}
			}
			// 05/16/2021 Paul.  Precheck access to filter module. 
			nACLACCESS = Security.GetUserAccess(sMODULE, "edit");
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
			// 06/02/2021 Paul.  React client needs to share code. 
			DataTable dtRules = RulesUtil.BuildRuleDataTable(dictRulesXml);
			
			Hashtable hashAvailableModules = new Hashtable();
			StringBuilder sbErrors = new StringBuilder();
			string sReportSQL = String.Empty;
			sReportSQL = Reports.QueryBuilder.BuildReportSQL(Application, rdl, bPrimaryKeyOnly, bUseSQLParameters, bDesignChart, bUserSpecific, sMODULE, sRELATED, hashAvailableModules, sbErrors);
			if ( sbErrors.Length > 0 )
				throw(new Exception(sbErrors.ToString()));
			
			rdl.SetDataSetFields(hashAvailableModules);
			rdl.SetSingleNode("DataSets/DataSet/Query/CommandText", sReportSQL);
			
			string        sWizardModule = sMODULE;
			int           nSuccessCount = 0;
			int           nFailedCount  = 0;
			string        sStatus       = String.Empty;
			DataTable     dt            = new DataTable();
			StringBuilder sbDumpSQL     = new StringBuilder();
			// 12/12/2012 Paul.  For security reasons, we want to restrict the data types available to the rules wizard. 
			SplendidRulesTypeProvider typeProvider = new SplendidRulesTypeProvider();
			RuleValidation validation = new RuleValidation(typeof(SplendidWizardThis), typeProvider);
			RuleSet rules = RulesUtil.BuildRuleSet(dtRules, validation);
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						string sTABLE_NAME = Crm.Modules.TableName(sWizardModule);
						cmd.CommandText = "select *" + ControlChars.CrLf
						                + "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf;
						Security.Filter(cmd, sWizardModule, "list");
						if ( !Sql.IsEmptyString(sReportSQL) )
						{
							cmd.CommandText += "   and ID in " + ControlChars.CrLf
							                + "(" + sReportSQL + ")" + ControlChars.CrLf;
						}
						cmd.CommandText += "order by NAME asc";
						
						sbDumpSQL.Append(Sql.ClientScriptBlock(cmd));
						
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dt);
							dt.Columns.Add("IMPORT_ROW_STATUS" , typeof(System.Boolean));
							dt.Columns.Add("IMPORT_ROW_NUMBER" , typeof(System.Int32  ));
							dt.Columns.Add("IMPORT_ROW_ERROR"  , typeof(System.String ));
							dt.Columns.Add("IMPORT_LAST_COLUMN", typeof(System.String ));
						}
					}
					if ( bPreview )
					{
						int nRowNumber = 0;
						int nFailed    = 0;
						foreach ( DataRow row in dt.Rows )
						{
							// 01/22/2015 Paul.  Move the catch inside the loop so that we can see all the errors. 
							try
							{
								row["IMPORT_ROW_NUMBER"] = nRowNumber;
								// 04/27/2018 Paul.  We need to be able to generate an error message. 
								SplendidControl Container = new SplendidControl();
								SplendidWizardThis swThis = new SplendidWizardThis(Container, L10n, sWizardModule, row);
								RuleExecution exec = new RuleExecution(validation, swThis);
								// 10/25/2010 Paul.  You have to be careful with Reevaluation Always as it will re-evaluate 
								// after the Then or Else actions to see if it needs to be run again. 
								// This can cause an endless loop. 
								rules.Execute(exec);
								if ( !Sql.IsEmptyString(swThis.ErrorMessage) )
									throw(new Exception(swThis.ErrorMessage));
								nRowNumber++;
								row["IMPORT_ROW_STATUS"] = true;
							}
							catch(Exception ex)
							{
								// 01/22/2015 Paul.  Save each row error. 
								row["IMPORT_ROW_ERROR" ] = ex.Message;
								row["IMPORT_ROW_STATUS"] = false;
								nFailed++;
								nSuccessCount = nRowNumber;
								nFailedCount  = nFailed   ;
							}
						}
						if ( nFailed > 0 )
							sStatus = L10n.Term("Import.LBL_FAIL");
						else
							sStatus = L10n.Term("Import.LBL_SUCCESS");
						nSuccessCount = nRowNumber;
						nFailedCount  = nFailed   ;
					}
					else
					{
						// 11/29/2010 Paul.  Make sure to check the access rights before applying the rules. 
						if ( SplendidCRM.Security.GetUserAccess(sWizardModule, "edit") >= 0 )
						{
							// 05/17/2021 Paul.  Convert SubmitRules to static function so that it can be called by React client. 
							SplendidControl Container = new SplendidControl();
							EditView.SubmitRules(HttpContext.Current, Container, L10n, con, sWizardModule, rules, validation, dt, bUseTransaction, ref nSuccessCount, ref nFailedCount, ref sStatus);
						}
					}
				}
			}
			catch(Exception ex)
			{
				throw(new Exception(ex.Message + ControlChars.CrLf + RulesUtil.GetValidationErrors(validation)));
			}
			
			string sProcessedFileID   = Guid.NewGuid().ToString();
			string sProcessedFileName = Security.USER_ID.ToString() + " " + Guid.NewGuid().ToString() + ".xml";
			DataSet dsProcessed = new DataSet();
			dsProcessed.Tables.Add(dt);
			dsProcessed.WriteXml(Path.Combine(Path.GetTempPath(), sProcessedFileName), XmlWriteMode.WriteSchema);
			Session["TempFile." + sProcessedFileID] = sProcessedFileName;
			
			Dictionary<string, object> dictResponse = new Dictionary<string, object>();
			dictResponse.Add("SuccessCount"   , nSuccessCount   );
			dictResponse.Add("FailedCount"    , nFailedCount    );
			dictResponse.Add("Status"         , sStatus         );
			dictResponse.Add("ProcessedFileID", sProcessedFileID);
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
