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
using System.Web.SessionState;
using System.Web.Script.Serialization;
using System.Workflow.Activities.Rules;
using System.Diagnostics;

namespace SplendidCRM.Import
{
	[ServiceContract]
	[ServiceBehavior( IncludeExceptionDetailInFaults = true )]
	[AspNetCompatibilityRequirements( RequirementsMode = AspNetCompatibilityRequirementsMode.Required )]
	public class Rest
	{
		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetImportSettings(string ImportModule)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;

			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

			Dictionary<string, object> d = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			results.Add("LinkedIn"        , !Sql.IsEmptyString(Application["CONFIG.LinkedIn.APIKey"            ]));
			results.Add("Twitter"         , !Sql.IsEmptyString(Application["CONFIG.Twitter.ConsumerKey"        ]));
			results.Add("Facebook"        , !Sql.IsEmptyString(Application["CONFIG.facebook.AppID"             ]));
			results.Add("Salesforce"      , !Sql.IsEmptyString(Application["CONFIG.Salesforce.ConsumerKey"     ]));
			results.Add("QuickBooks"      , !Sql.IsEmptyString(Application["CONFIG.QuickBooks.ConnectionString"]));
			results.Add("QuickBooksOnline", !Sql.IsEmptyString(Application["CONFIG.QuickBooks.OAuthClientID"   ]));
			results.Add("HubSpot"         , !Sql.IsEmptyString(Application["CONFIG.HubSpot.PortalID"           ]));

			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			string sTABLE_NAME = Sql.ToString(Application["Modules." + ImportModule + ".TableName"]);
			if ( Sql.IsEmptyString(sTABLE_NAME) )
				throw(new Exception("Unknown module: " + ImportModule));
			int nACLACCESS = Security.GetUserAccess(ImportModule, "import");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + ImportModule + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(ImportModule)));
			}
			
			DataTable dtColumns = SplendidCache.ImportColumns(ImportModule).Copy();
			dtColumns.Columns.Add("DISPLAY_NAME_NOSPACE", Type.GetType("System.String"));
			dtColumns.Columns.Add("NAME_NOUNDERSCORE"   , Type.GetType("System.String"));
			foreach ( DataRow row in dtColumns.Rows )
			{
				string sDISPLAY_NAME = Utils.TableColumnName(L10n, ImportModule, Sql.ToString(row["DISPLAY_NAME"]));
				row["DISPLAY_NAME"        ] = sDISPLAY_NAME.Trim();
				row["DISPLAY_NAME_NOSPACE"] = sDISPLAY_NAME.Replace(" ", "");
				row["NAME_NOUNDERSCORE"   ] = Sql.ToString(row["NAME"]).Replace("_", "");
			}
			DataView vwColumns = new DataView(dtColumns);
			// 08/13/2020 Paul.  Sort by display name not colid. 
			// 01/09/2021 Paul.  Sort in the app instead of with importColumns to match the ASP.Net processing lists. 
			//vwColumns.Sort = "DISPLAY_NAME";
			Guid     gTIMEZONE         = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n              = TimeZone.CreateTimeZone(gTIMEZONE);
			results.Add("importColumns", RestUtil.RowsToDictionary(String.Empty, String.Empty, vwColumns, T10n));
			// 05/20/2020 Paul.  Also provide a separate pre-sorted column lists here so that it is not case-significant. 
			vwColumns.Sort = "DISPLAY_NAME";
			results.Add("displayColumns", RestUtil.RowsToDictionary(String.Empty, String.Empty, vwColumns, T10n));

			DataTable dtRuleColumns = SplendidCache.SqlColumns("vw" + sTABLE_NAME + "_List");
			results.Add("ruleColumns", RestUtil.RowsToDictionary(String.Empty, String.Empty, dtRuleColumns, T10n));
			d.Add("d", results);
			return RestUtil.ToJsonStream(d);
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetImportMaps(string ImportModule)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			int nACLACCESS = Security.GetUserAccess(ImportModule, "import");
			if ( !Security.IsAuthenticated() || nACLACCESS < 0 )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 11/16/2014 Paul.  We need to continually update the SplendidSession so that it expires along with the ASP.NET Session. 
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			StringBuilder sbDumpSQL = new StringBuilder();
			// Accounts, Contacts, Leads, Prospects, Calls
			DataTable dt = new DataTable();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				// 03/28/2018 Paul.  Allow global. 
				sSQL = "select *                                   " + ControlChars.CrLf
				     + "  from vwIMPORT_MAPS_List                  " + ControlChars.CrLf
				     + " where MODULE           = @MODULE          " + ControlChars.CrLf
				     + "   and (ASSIGNED_USER_ID is null or ASSIGNED_USER_ID = @ASSIGNED_USER_ID)" + ControlChars.CrLf
				     + " order by NAME                             " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@MODULE"          , ImportModule   );
					Sql.AddParameter(cmd, "@ASSIGNED_USER_ID", Security.USER_ID);

					sbDumpSQL.AppendLine(Sql.ExpandParameters(cmd));

					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						da.Fill(dt);
					}
				}
			}
			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath.Replace("/GetImportMaps", "/GetImportItem");
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			
			Guid     gTIMEZONE         = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n              = TimeZone.CreateTimeZone(gTIMEZONE);
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, "Import", dt, T10n);
			dictResponse.Add("__total", dt.Rows.Count);
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
		public Stream GetImportItem(string ImportModule, Guid ID)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			
			int nACLACCESS = Security.GetUserAccess(ImportModule, "import");
			if ( !Security.IsAuthenticated() || nACLACCESS < 0 )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(ImportModule)));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			StringBuilder sbDumpSQL = new StringBuilder();
			DataTable dt = new DataTable();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				// 03/28/2018 Paul.  Allow global. 
				sSQL = "select *                                   " + ControlChars.CrLf
				     + "  from vwIMPORT_MAPS_Edit                  " + ControlChars.CrLf
				     + " where MODULE           = @MODULE          " + ControlChars.CrLf
				     + "   and ID               = @ID              " + ControlChars.CrLf
				     + "   and (ASSIGNED_USER_ID is null or ASSIGNED_USER_ID = @ASSIGNED_USER_ID)" + ControlChars.CrLf
				     + " order by NAME                             " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@MODULE"          , ImportModule    );
					Sql.AddParameter(cmd, "@ID"              , ID              );
					Sql.AddParameter(cmd, "@ASSIGNED_USER_ID", Security.USER_ID);

					sbDumpSQL.AppendLine(Sql.ExpandParameters(cmd));

					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						da.Fill(dt);
					}
				}
			}
			string sTempSampleID = String.Empty;
			if ( dt == null || dt.Rows.Count == 0 )
			{
				throw(new Exception("Item not found: IMPORT_MAPS " + ID.ToString()));
			}
			else
			{
				DataRow rdr = dt.Rows[0];
				string sXmlMapping = Sql.ToString (rdr["CONTENT"]);
				XmlDocument xmlMapping = new XmlDocument();
				xmlMapping.LoadXml(sXmlMapping);
				// 10/12/2006 Paul.  Extract the sample from the mapping. 
				XmlDocument xml = new XmlDocument();
				// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
				// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
				// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
				xml.XmlResolver = null;
				string sXmlSample = XmlUtil.SelectSingleNode(xmlMapping, "Sample");
				// 09/04/2010 Paul.  Store the sample data in the Session to prevent a huge download. 
				// We are seeing a 13M html file for an 8M import file. 
				sTempSampleID = ImportModule + ".xmlSample." + ID.ToString();
				Session[sTempSampleID] = sXmlSample;
				
				dt.Columns.Add("TempSampleID");
				rdr["TempSampleID"] = sTempSampleID;
			}
			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			
			Guid     gTIMEZONE         = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n              = TimeZone.CreateTimeZone(gTIMEZONE);
			Dictionary<string, object> dict = RestUtil.ToJson(sBaseURI, "Import", dt.Rows[0], T10n);
			
			dict.Add("TempSampleID", sTempSampleID);
			
			if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
			{
				dict.Add("__sql", sbDumpSQL.ToString());
			}
			string sResponse = json.Serialize(dict);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		private Guid GetAssignedUserID(Guid gID)
		{
			Guid gASSIGNED_USER_ID = Guid.Empty;
			if ( !Sql.IsEmptyGuid(gID) )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select ASSIGNED_USER_ID  " + ControlChars.CrLf
					     + "  from vwIMPORT_MAPS_List" + ControlChars.CrLf
					     + " where ID = @ID          " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ID", gID);
						gASSIGNED_USER_ID = Sql.ToGuid(cmd.ExecuteScalar());
					}
				}
			}
			return gASSIGNED_USER_ID;
		}

		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public void DeleteImportMap(Guid ID)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			if ( !Security.IsAuthenticated() )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			
			Guid gASSIGNED_USER_ID = GetAssignedUserID(ID);
			if ( Security.IS_ADMIN || gASSIGNED_USER_ID == Security.USER_ID )
			{
				SqlProcs.spIMPORT_MAPS_Delete(ID);
			}
		}

		private XmlDocument CreateXmlMapping(Dictionary<string, object> dict, string sImportModule, string sNAME, string sSOURCE, bool bHAS_HEADER)
		{
			XmlDocument xmlMapping = new XmlDocument();
			xmlMapping.AppendChild(xmlMapping.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xmlMapping.AppendChild(xmlMapping.CreateElement("Import"));
			XmlUtil.SetSingleNodeAttribute(xmlMapping, xmlMapping.DocumentElement, "Name", sNAME);
			XmlUtil.SetSingleNode(xmlMapping, "Module"    , sImportModule);
			XmlUtil.SetSingleNode(xmlMapping, "SourceType", sSOURCE);
			XmlUtil.SetSingleNode(xmlMapping, "HasHeader" , bHAS_HEADER.ToString());
			XmlNode xFields = xmlMapping.CreateElement("Fields");
			xmlMapping.DocumentElement.AppendChild(xFields);
			
			if ( dict.ContainsKey("importMap") )
			{
				Dictionary<string, object> importMap = dict["importMap"] as Dictionary<string, object>;
				if ( importMap != null && importMap.ContainsKey("Import") )
				{
					Dictionary<string, object> Import = importMap["Import"] as Dictionary<string, object>;
					if ( Import != null && Import.ContainsKey("Fields") )
					{
						
						Dictionary<string, object> Fields = Import["Fields"] as Dictionary<string, object>;
						if ( Fields != null && Fields.ContainsKey("Field") )
						{
							System.Collections.ArrayList lst = Fields["Field"] as System.Collections.ArrayList;
							if ( lst != null )
							{
								if ( lst.Count > 0 )
								{
									foreach ( Dictionary<string, object> Field in lst )
									{
										XmlNode xField = xmlMapping.CreateElement("Field");
										xFields.AppendChild(xField);
										if ( Field.ContainsKey("Name"           ) ) XmlUtil.SetSingleNodeAttribute(xmlMapping, xField, "Name"  , Sql.ToString(Field["Name"            ]));
										if ( Field.ContainsKey("Type"           ) ) XmlUtil.SetSingleNode(xmlMapping, xField, "Type"           , Sql.ToString(Field["Type"            ]));
										if ( Field.ContainsKey("Length"         ) ) XmlUtil.SetSingleNode(xmlMapping, xField, "Length"         , Sql.ToString(Field["Length"          ]));
										if ( Field.ContainsKey("Default"        ) ) XmlUtil.SetSingleNode(xmlMapping, xField, "Default"        , Sql.ToString(Field["Default"         ]));
										if ( Field.ContainsKey("Mapping"        ) ) XmlUtil.SetSingleNode(xmlMapping, xField, "Mapping"        , Sql.ToString(Field["Mapping"         ]));
										if ( Field.ContainsKey("DuplicateFilter") ) XmlUtil.SetSingleNode(xmlMapping, xField, "DuplicateFilter", Sql.ToBoolean(Field["DuplicateFilter"]).ToString());
									}
								}
							}
							else
							{
								// 05/19/2020 Paul.  If there is only one Field, then it will not be an array. 
								Dictionary<string, object> Field = Import["Field"] as Dictionary<string, object>;
								if ( Field != null )
								{
									XmlNode xField = xmlMapping.CreateElement("Field");
									xFields.AppendChild(xField);
									if ( Field.ContainsKey("Name"           ) ) XmlUtil.SetSingleNodeAttribute(xmlMapping, xField, "Name"  , Sql.ToString(Field["Name"            ]));
									if ( Field.ContainsKey("Type"           ) ) XmlUtil.SetSingleNode(xmlMapping, xField, "Type"           , Sql.ToString(Field["Type"            ]));
									if ( Field.ContainsKey("Length"         ) ) XmlUtil.SetSingleNode(xmlMapping, xField, "Length"         , Sql.ToString(Field["Length"          ]));
									if ( Field.ContainsKey("Default"        ) ) XmlUtil.SetSingleNode(xmlMapping, xField, "Default"        , Sql.ToString(Field["Default"         ]));
									if ( Field.ContainsKey("Mapping"        ) ) XmlUtil.SetSingleNode(xmlMapping, xField, "Mapping"        , Sql.ToString(Field["Mapping"         ]));
									if ( Field.ContainsKey("DuplicateFilter") ) XmlUtil.SetSingleNode(xmlMapping, xField, "DuplicateFilter", Sql.ToBoolean(Field["DuplicateFilter"]).ToString());
								}
							}
						}
					}
				}
				if ( xFields.ChildNodes.Count == 0 )
				{
					throw(new Exception("Missing Import/Fields/Field"));
				}
			}
			else
			{
				throw(new Exception("Missing importMap"));
			}
		return xmlMapping;
		}

		private DataTable CreateRulesTable(Dictionary<string, object> dict)
		{
			DataTable dtRules = null;
			if ( dict.ContainsKey("rulesXml") )
			{
				dtRules = new DataTable("Table1");
				DataColumn colID           = new DataColumn("ID"          , typeof(System.Guid   ));
				DataColumn colRULE_NAME    = new DataColumn("RULE_NAME"   , typeof(System.String ));
				DataColumn colPRIORITY     = new DataColumn("PRIORITY"    , typeof(System.Int32  ));
				DataColumn colREEVALUATION = new DataColumn("REEVALUATION", typeof(System.String ));
				DataColumn colACTIVE       = new DataColumn("ACTIVE"      , typeof(System.Boolean));
				DataColumn colCONDITION    = new DataColumn("CONDITION"   , typeof(System.String ));
				DataColumn colTHEN_ACTIONS = new DataColumn("THEN_ACTIONS", typeof(System.String ));
				DataColumn colELSE_ACTIONS = new DataColumn("ELSE_ACTIONS", typeof(System.String ));
				dtRules.Columns.Add(colID          );
				dtRules.Columns.Add(colRULE_NAME   );
				dtRules.Columns.Add(colPRIORITY    );
				dtRules.Columns.Add(colREEVALUATION);
				dtRules.Columns.Add(colACTIVE      );
				dtRules.Columns.Add(colCONDITION   );
				dtRules.Columns.Add(colTHEN_ACTIONS);
				dtRules.Columns.Add(colELSE_ACTIONS);
				Dictionary<string, object> rulesXml = dict["rulesXml"] as Dictionary<string, object>;
				if ( rulesXml != null && rulesXml.ContainsKey("NewDataSet") )
				{
					Dictionary<string, object> NewDataSet = rulesXml["NewDataSet"] as Dictionary<string, object>;
					if ( NewDataSet != null && NewDataSet.ContainsKey("Table1") )
					{
						System.Collections.ArrayList lst = NewDataSet["Table1"] as System.Collections.ArrayList;
						if ( lst != null )
						{
							if ( lst.Count > 0 )
							{
								foreach ( Dictionary<string, object> Table1 in lst )
								{
									DataRow row = dtRules.NewRow();
									dtRules.Rows.Add(row);
									if ( Table1.ContainsKey("ID"          ) ) row["ID"          ] = Sql.ToGuid   (Table1["ID"          ]);
									if ( Table1.ContainsKey("RULE_NAME"   ) ) row["RULE_NAME"   ] = Sql.ToString (Table1["RULE_NAME"   ]);
									if ( Table1.ContainsKey("PRIORITY"    ) ) row["PRIORITY"    ] = Sql.ToInteger(Table1["PRIORITY"    ]);
									if ( Table1.ContainsKey("REEVALUATION") ) row["REEVALUATION"] = Sql.ToString (Table1["REEVALUATION"]);
									if ( Table1.ContainsKey("ACTIVE"      ) ) row["ACTIVE"      ] = Sql.ToBoolean(Table1["ACTIVE"      ]);
									if ( Table1.ContainsKey("CONDITION"   ) ) row["CONDITION"   ] = Sql.ToString (Table1["CONDITION"   ]);
									if ( Table1.ContainsKey("THEN_ACTIONS") ) row["THEN_ACTIONS"] = Sql.ToString (Table1["THEN_ACTIONS"]);
									if ( Table1.ContainsKey("ELSE_ACTIONS") ) row["ELSE_ACTIONS"] = Sql.ToString (Table1["ELSE_ACTIONS"]);
									if ( Sql.IsEmptyGuid(row["ID"]) )
									{
										row["ID"] = Guid.NewGuid();
									}
									if ( Sql.IsEmptyString(row["RULE_NAME"]) )
									{
										row["RULE_NAME"] = Guid.NewGuid().ToString();
									}
								}
							}
						}
						else
						{
							// 05/19/2020 Paul.  If there is only one Table1, then it will not be an array. 
							Dictionary<string, object> Table1 = NewDataSet["Table1"] as Dictionary<string, object>;
							if ( Table1 != null )
							{
								DataRow row = dtRules.NewRow();
								dtRules.Rows.Add(row);
								if ( Table1.ContainsKey("ID"          ) ) row["ID"          ] = Sql.ToGuid   (Table1["ID"          ]);
								if ( Table1.ContainsKey("RULE_NAME"   ) ) row["RULE_NAME"   ] = Sql.ToString (Table1["RULE_NAME"   ]);
								if ( Table1.ContainsKey("PRIORITY"    ) ) row["PRIORITY"    ] = Sql.ToInteger(Table1["PRIORITY"    ]);
								if ( Table1.ContainsKey("REEVALUATION") ) row["REEVALUATION"] = Sql.ToString (Table1["REEVALUATION"]);
								if ( Table1.ContainsKey("ACTIVE"      ) ) row["ACTIVE"      ] = Sql.ToBoolean(Table1["ACTIVE"      ]);
								if ( Table1.ContainsKey("CONDITION"   ) ) row["CONDITION"   ] = Sql.ToString (Table1["CONDITION"   ]);
								if ( Table1.ContainsKey("THEN_ACTIONS") ) row["THEN_ACTIONS"] = Sql.ToString (Table1["THEN_ACTIONS"]);
								if ( Table1.ContainsKey("ELSE_ACTIONS") ) row["ELSE_ACTIONS"] = Sql.ToString (Table1["ELSE_ACTIONS"]);
								if ( Sql.IsEmptyGuid(row["ID"]) )
								{
									row["ID"] = Guid.NewGuid();
								}
								if ( Sql.IsEmptyString(row["RULE_NAME"]) )
								{
									row["RULE_NAME"] = Guid.NewGuid().ToString();
								}
							}
						}
					}
				}
			}
			return dtRules;
		}

		[OperationContract]
		public Guid UpdateImportMap(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
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

			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 11/16/2014 Paul.  We need to continually update the SplendindSession so that it expires along with the ASP.NET Session. 
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sImportModule     = String.Empty;
			Guid   gID               = Guid.Empty;
			string sNAME             = String.Empty;
			string sSOURCE           = String.Empty;
			bool   bHAS_HEADER       = false;
			bool   bIS_PUBLISHED     = false;
			string sTempSampleID     = String.Empty;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ImportModule":  sImportModule = Sql.ToString (dict[sColumnName]);  break;
					case "ID"          :  gID           = Sql.ToGuid   (dict[sColumnName]);  break;
					case "NAME"        :  sNAME         = Sql.ToString (dict[sColumnName]);  break;
					case "SOURCE"      :  sSOURCE       = Sql.ToString (dict[sColumnName]);  break;
					case "HAS_HEADER"  :  bHAS_HEADER   = Sql.ToBoolean(dict[sColumnName]);  break;
					case "IS_PUBLISHED":  bIS_PUBLISHED = Sql.ToBoolean(dict[sColumnName]);  break;
					case "TempSampleID":  sTempSampleID = Sql.ToString (dict[sColumnName]);  break;
				}
			}
			if ( !Sql.IsEmptyGuid(gID) )
			{
				Guid gASSIGNED_USER_ID = GetAssignedUserID(gID);
				if ( !(Security.IS_ADMIN || gASSIGNED_USER_ID == Security.USER_ID) )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
			}
			XmlDocument xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			XmlDocument xmlMapping = CreateXmlMapping(dict, sImportModule, sNAME, sSOURCE, bHAS_HEADER);
			if ( !Sql.IsEmptyString(sTempSampleID) )
			{
				if ( Session[sTempSampleID] != null )
				{
					// 10/12/2006 Paul.  Save the sample data with the mappings. 
					XmlUtil.SetSingleNode(xmlMapping, "Sample", xml.OuterXml);
				}
			}
			
			// 09/17/2013 Paul.  Add Business Rules to import. 
			DataTable dtRules = CreateRulesTable(dict);
			StringBuilder sbRulesXML = new StringBuilder();
			if ( dtRules != null && dtRules.Rows.Count > 0 )
			{
				SplendidRulesTypeProvider typeProvider = new SplendidRulesTypeProvider();
				RuleValidation validation = new RuleValidation(typeof(SplendidImportThis), typeProvider);
				RuleSet rules = RulesUtil.BuildRuleSet(dtRules, validation);
				
				string sXOML = RulesUtil.Serialize(rules);
				using ( StringWriter wtr = new StringWriter(sbRulesXML, System.Globalization.CultureInfo.InvariantCulture) )
				{
					dtRules.WriteXml(wtr, XmlWriteMode.WriteSchema, false);
				}
			}
			//Debug.WriteLine(sbRulesXML.ToString());
			//Debug.WriteLine(xmlMapping.OuterXml);
			SqlProcs.spIMPORT_MAPS_Update
				( ref gID
				, Security.USER_ID
				, sNAME
				, sSOURCE
				, sImportModule
				, bHAS_HEADER
				, bIS_PUBLISHED
				, xmlMapping.OuterXml
				, sbRulesXML.ToString()
				);
			return gID;
		}

		// 06/06/2021 Paul.  ValidateRule was moved to ~/RulesWizard/Rest.svc. 

		[OperationContract]
		public Stream UploadFile(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
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
			
			string sImportModule         = (dict.ContainsKey("ImportModule"        ) ? Sql.ToString(dict["ImportModule"        ]) : String.Empty);
			string sSOURCE               = (dict.ContainsKey("SOURCE"              ) ? Sql.ToString(dict["SOURCE"              ]) : String.Empty);
			string sCUSTOM_DELIMITER_VAL = (dict.ContainsKey("CUSTOM_DELIMITER_VAL") ? Sql.ToString(dict["CUSTOM_DELIMITER_VAL"]) : String.Empty);
			string sFILENAME             = (dict.ContainsKey("FILENAME"            ) ? Sql.ToString(dict["FILENAME"            ]) : String.Empty);
			string sFILE_EXT             = (dict.ContainsKey("FILE_EXT"            ) ? Sql.ToString(dict["FILE_EXT"            ]) : String.Empty);
			string sFILE_MIME_TYPE       = (dict.ContainsKey("FILE_MIME_TYPE"      ) ? Sql.ToString(dict["FILE_MIME_TYPE"      ]) : String.Empty);
			string sFILE_DATA            = (dict.ContainsKey("FILE_DATA"           ) ? Sql.ToString(dict["FILE_DATA"           ]) : String.Empty);
			int nACLACCESS = Security.GetUserAccess(sImportModule, "import");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + sImportModule + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(sImportModule)));
			}
			string sTABLE_NAME           = Sql.ToString(Application["Modules." + sImportModule + ".TableName"]);
			if ( Sql.IsEmptyString(sTABLE_NAME) )
				throw(new Exception("Unknown module: " + sImportModule));
			
			// 04/27/2018 Paul.  Correct the source type based on the file type. 
			if ( sFILE_EXT == ".xlsx" || sFILE_EXT == ".xls" )
				sSOURCE = "excel";
			else if ( sFILE_EXT == ".csv" )
				sSOURCE = "other";
			// 05/20/2020 Paul.  txt can be for csv or custom delimited. 
			else if ( sFILE_EXT == ".txt" )
			{
				if ( !Sql.IsEmptyString(sCUSTOM_DELIMITER_VAL) )
					sSOURCE = "custom_delimited";
				else
					sSOURCE = "other";
			}
			else if ( sFILE_EXT == ".tab" )
				sSOURCE = "other_tab";
			else if ( sFILE_EXT == ".xml" )
				sSOURCE = "xml";
			
			byte[] byFILE_DATA     = Convert.FromBase64String(sFILE_DATA);
			long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
			if ( (lUploadMaxSize > 0) && (byFILE_DATA.Length > lUploadMaxSize) )
			{
				throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
			}
			
			XmlDocument xml = null;
			using ( MemoryStream stm = new MemoryStream(byFILE_DATA) )
			{
				xml = SplendidImport.ConvertStreamToXml(sImportModule, sSOURCE, sCUSTOM_DELIMITER_VAL, stm, sFILE_EXT);
			}
			
			if ( xml.DocumentElement == null )
				throw(new Exception(L10n.Term("Import.LBL_NOTHING")));
			
			// 08/21/2006 Paul.  Don't move to next step if there is no data. 
			XmlNodeList nlRows = xml.DocumentElement.SelectNodes(sImportModule.ToLower());
			// 05/23/2020 Paul.  Try non-lower case. 
			if ( nlRows.Count == 0 )
				nlRows = xml.DocumentElement.SelectNodes(sImportModule);
			if ( nlRows.Count == 0 )
				throw(new Exception(L10n.Term("Import.LBL_NOTHING")));
			
			// 10/10/2006 Paul.  Don't store the file name in the ViewState because a hacker could find a way to access and alter it.
			// Storing the file name in the session and an ID in the view state should be sufficiently safe. 
			string sTempFileID   = Guid.NewGuid().ToString();
			string sTempFileName = Security.USER_ID.ToString() + " " + Guid.NewGuid().ToString() + " " + sFILENAME + ".xml";
			xml.Save(Path.Combine(Path.GetTempPath(), sTempFileName));
			
			Dictionary<string, object> d = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			// 01/30/2010 Paul.  Were were not storing the full path in the Session for cleanup. 
			Session["TempFile." + sTempFileID] = Path.Combine(Path.GetTempPath(), sTempFileName);
			d.Add("d", results);
			results.Add("TempFileID", sTempFileID);
			
			// 10/10/2006 Paul.  We only need to save a small portion of the imported data as a sample. 
			// Trying to save too much data in ViewState can cause memory errors. 
			// 10/31/2006 Paul.  It is taking too long to reduce the size of a large XML file. 
			// Instead, extract the three rows and attach to a new XML document. 
			XmlDocument xmlSample = new XmlDocument();
			xmlSample.AppendChild(xmlSample.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xmlSample.AppendChild(xmlSample.CreateElement("xml"));
			// 10/31/2006 Paul.  Select only the nodes that apply.  We need to make sure to skip unrelated nodes. 
			for ( int i = 0; i < nlRows.Count && i < 3 ; i++ )
			{
				XmlNode node = nlRows[i];
				xmlSample.DocumentElement.AppendChild(xmlSample.ImportNode(node, true));
			}
			// 10/31/2006 Paul.  We are getting an OutOfMemoryException.  Try to free the large XML file. 
			nlRows = null;
			xml    = xmlSample;
			GC.Collect();
			// 09/04/2010 Paul.  Store the sample data in the Session to prevent a huge download. 
			// We are seeing a 13M html file for an 8M import file. 
			string sTempSampleID = sImportModule + ".xmlSample." + sFILENAME;
			Session[sTempSampleID] = xml.OuterXml;
			results.Add("xmlSample"   , xml.OuterXml );
			results.Add("TempSampleID", sTempSampleID);
			
			return RestUtil.ToJsonStream(d);
		}

		[OperationContract]
		public Stream RunImport(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			HttpServerUtility    Server      = HttpContext.Current.Server     ;
			
			// 02/05/2010 Paul.  An ACT! import can take a long time. 
			Server.ScriptTimeout = 20 * 60;
			
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
			
			string sImportModule     = String.Empty;
			Guid   gPROSPECT_LIST_ID = Guid.Empty;
			Guid   gID               = Guid.Empty;
			string sNAME             = String.Empty;
			string sSOURCE           = String.Empty;
			bool   bHAS_HEADER       = false;
			bool   bUSE_TRANSACTION  = true;
			string sTempFileID       = String.Empty;
			bool   bPreview          = false;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ImportModule"    :  sImportModule     = Sql.ToString (dict[sColumnName]);  break;
					case "PROSPECT_LIST_ID":  gPROSPECT_LIST_ID = Sql.ToGuid   (dict[sColumnName]);  break;
					case "ID"              :  gID               = Sql.ToGuid   (dict[sColumnName]);  break;
					case "NAME"            :  sNAME             = Sql.ToString (dict[sColumnName]);  break;
					case "SOURCE"          :  sSOURCE           = Sql.ToString (dict[sColumnName]);  break;
					case "HAS_HEADER"      :  bHAS_HEADER       = Sql.ToBoolean(dict[sColumnName]);  break;
					case "USE_TRANSACTION" :  bUSE_TRANSACTION  = Sql.ToBoolean(dict[sColumnName]);  break;
					case "TempFileID"      :  sTempFileID       = Sql.ToString (dict[sColumnName]);  break;
					case "Preview"         :  bPreview          = Sql.ToBoolean(dict[sColumnName]);  break;
				}
			}
			int nACLACCESS = Security.GetUserAccess(sImportModule, "import");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + sImportModule + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(sImportModule)));
			}
			string sTABLE_NAME = Sql.ToString(Application["Modules." + sImportModule + ".TableName"]);
			if ( Sql.IsEmptyString(sTABLE_NAME) )
				throw(new Exception("Unknown module: " + sImportModule));
			string sTempFileName = Sql.ToString(Session["TempFile." + sTempFileID]);
			if ( Sql.IsEmptyString(sTempFileID) || Sql.IsEmptyString(sTempFileName) )
			{
				throw(new Exception(L10n.Term("Import.LBL_NOTHING")));
			}
			
			XmlDocument xmlMapping = CreateXmlMapping(dict, sImportModule, sNAME, sSOURCE, bHAS_HEADER);
			DataTable dtRules = CreateRulesTable(dict);
			
			int    nImported   = 0;
			int    nFailed     = 0;
			int    nDuplicates = 0;
			string sProcessedFileID   = Guid.NewGuid().ToString();
			DataTable dtProcessed = new DataTable();
			string sLayoutEditView = "EditView";
			DataTable dtColumns = SplendidCache.ImportColumns(sImportModule);
			DataView vwColumns = new DataView(dtColumns);
			StringBuilder sbImport = new StringBuilder();
			StringBuilder sbErrors = new StringBuilder();
			SplendidControl Container = new SplendidControl();
			// 09/04/2010 Paul.  Log the import time. 
			SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Begin Import");
			ImportUtils.GenerateImport(Application, L10n, Container, sImportModule, sSOURCE, vwColumns, xmlMapping, dtRules, sLayoutEditView, sTempFileName, bPreview, bHAS_HEADER, bUSE_TRANSACTION, gPROSPECT_LIST_ID, sbImport, sbErrors, sProcessedFileID, dtProcessed, ref nImported, ref nFailed, ref nDuplicates);
			SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "End Import");
			
			string sStatus = String.Empty;
			// 03/20/2011 Paul.  Include a preview indicator. 
			if ( bPreview )
				sStatus += L10n.Term("Import.LBL_PREVIEW_BUTTON_LABEL") + " ";
			if ( nFailed == 0 )
				sStatus += L10n.Term("Import.LBL_SUCCESS");
			else
				sStatus += L10n.Term("Import.LBL_FAIL"   );
			
			DataTable dtProcessedColumns = vwColumns.Table.Clone();
			for ( int i = 0; i < dtProcessed.Columns.Count; i++ )
			{
				DataColumn col = dtProcessed.Columns[i];
				if ( col.ColumnName == "IMPORT_ROW_STATUS" || col.ColumnName == "IMPORT_LAST_COLUMN" )
					continue;
				DataRow row = dtProcessedColumns.NewRow();
				dtProcessedColumns.Rows.Add(row);
				vwColumns.RowFilter = "NAME = '" + col.ColumnName + "'";
				if ( vwColumns.Count > 0 )
				{
					row["ColumnName"  ] = Sql.ToString (vwColumns[0]["ColumnName"  ]);
					row["ColumnType"  ] = Sql.ToString (vwColumns[0]["ColumnType"  ]);
					row["CustomField" ] = Sql.ToString (vwColumns[0]["CustomField" ]);
					row["DISPLAY_NAME"] = Utils.TableColumnName(L10n, sImportModule, Sql.ToString (vwColumns[0]["NAME"]));
					row["NAME"        ] = Sql.ToString (vwColumns[0]["NAME"        ]);
					row["Precision"   ] = Sql.ToInteger(vwColumns[0]["Precision"   ]);
					row["Scale"       ] = Sql.ToInteger(vwColumns[0]["Scale"       ]);
					row["Size"        ] = Sql.ToInteger(vwColumns[0]["Size"        ]);
					row["colid"       ] = Sql.ToInteger(vwColumns[0]["colid"       ]);
				}
				else if ( col.ColumnName == "IMPORT_ROW_NUMBER" )
				{
					row["ColumnName"  ] = col.ColumnName;
					row["ColumnType"  ] = col.DataType.Name;
					row["CustomField" ] = false;
					row["DISPLAY_NAME"] = L10n.Term("Import.LBL_ROW");
					row["NAME"        ] = col.ColumnName;
					row["Precision"   ] = 0;
					row["Scale"       ] = 0;
					row["Size"        ] = 100;
					row["colid"       ] = i;
				}
				else if ( col.ColumnName == "IMPORT_ROW_ERROR" )
				{
					row["ColumnName"  ] = col.ColumnName;
					row["ColumnType"  ] = col.DataType.Name;
					row["CustomField" ] = false;
					row["DISPLAY_NAME"] = L10n.Term("Import.LBL_ROW_STATUS");
					row["NAME"        ] = col.ColumnName;
					row["Precision"   ] = 0;
					row["Scale"       ] = 0;
					row["Size"        ] = 100;
					row["colid"       ] = i;
				}
				else
				{
					row["ColumnName"  ] = col.ColumnName;
					row["ColumnType"  ] = col.DataType.Name;
					row["CustomField" ] = col.ColumnName.EndsWith("_C");
					row["DISPLAY_NAME"] = Utils.TableColumnName(L10n, sImportModule, col.ColumnName);
					row["NAME"        ] = col.ColumnName;
					row["Precision"   ] = 0;
					row["Scale"       ] = 0;
					row["Size"        ] = 100;
					row["colid"       ] = i;
				}
			}

			Guid     gTIMEZONE         = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n              = TimeZone.CreateTimeZone(gTIMEZONE);
			Dictionary<string, object> d = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			results.Add("Imported"        , nImported  .ToString());
			results.Add("Failed"          , nFailed    .ToString());
			results.Add("Duplicates"      , nDuplicates.ToString());
			results.Add("Errors"          , sbErrors   .ToString());
			results.Add("Status"          , sStatus               );
			results.Add("ProcessedFileID" , sProcessedFileID      );
			results.Add("processedColumns", RestUtil.RowsToDictionary(String.Empty, String.Empty, dtProcessedColumns, T10n));
			d.Add("d", results);
			return RestUtil.ToJsonStream(d);
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetPreviewList(string ImportModule)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			
			string ModuleName = ImportModule;
			if ( Sql.IsEmptyString(ImportModule) )
				throw(new Exception("The import module must be specified."));
			int nACLACCESS = Security.GetUserAccess(ModuleName, "list");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + ModuleName + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 09/06/2017 Paul.  Include module name in error. 
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(ModuleName)));
			}
			string sTABLE_NAME = Sql.ToString(Application["Modules." + ModuleName + ".TableName"]);
			if ( Sql.IsEmptyString(sTABLE_NAME) )
				throw(new Exception("Unknown module: " + ModuleName));
			
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
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, ModuleName, dt, T10n);
			dictResponse.Add("__total", lTotalCount);
			
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}
	}
}
