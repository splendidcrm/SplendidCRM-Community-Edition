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
using System.ServiceModel;
using System.ServiceModel.Web;
using System.ServiceModel.Activation;
using System.Web.Script.Serialization;
using System.Diagnostics;

namespace SplendidCRM.Administration
{
	[ServiceContract]
	[ServiceBehavior(IncludeExceptionDetailInFaults=true)]
	[AspNetCompatibilityRequirements(RequirementsMode=AspNetCompatibilityRequirementsMode.Required)]
	public class Rest
	{
		// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
		//public const string sEMPTY_PASSWORD = "**********";

		public class ViewNode
		{
			public string ViewName   ;
			public string DisplayName;
			public string LayoutType ;
		}

		public class ModuleNode
		{
			public string       ModuleName      ;
			public string       DisplayName     ;
			public bool         IsAdmin         ;
			public List<object> EditViews       ;
			public List<object> Search          ;
			public List<object> DetailViews     ;
			public List<object> ListViews       ;
			public List<object> SubPanels       ;
			public List<object> Relationships   ;
			public List<object> Terminology     ;
			// 03/17/2020 Paul.  Add TerminologyLists. 
			public List<object> TerminologyLists;

			public ModuleNode()
			{
				this.EditViews        = new List<object>();
				this.Search           = new List<object>();
				this.DetailViews      = new List<object>();
				this.ListViews        = new List<object>();
				this.SubPanels        = new List<object>();
				this.Relationships    = new List<object>();
				this.Terminology      = new List<object>();
				// 03/17/2020 Paul.  Add TerminologyLists. 
				this.TerminologyLists = new List<object>();
			}
		}

		public class LayoutField
		{
			public string ColumnName        ;
			public string ColumnType        ;
			public string CsType            ;
			public int    length            ;
			public string FIELD_TYPE        ;
			public string DATA_LABEL        ;
			public string DATA_FIELD        ;
			public string MODULE_TYPE       ;
			public string LIST_NAME         ;
			public string DATA_FORMAT       ;
			public int    FORMAT_MAX_LENGTH ;
			public string URL_FIELD         ;
			public string URL_FORMAT        ;
			public string COLUMN_TYPE       ;
			public string HEADER_TEXT       ;
			public string SORT_EXPRESSION   ;
			public string URL_ASSIGNED_FIELD;
		}

		#region Get
		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAdminLayoutModules()
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpApplicationState Application = HttpContext.Current.Application;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			Dictionary<string, ModuleNode> dict = new Dictionary<string, ModuleNode>();
			List<ModuleNode> lstModules = new List<ModuleNode>();
			
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				DataTable dtLANGUAGES = new DataTable();
				sSQL = "select NAME                                   " + ControlChars.CrLf
				     + "     , DISPLAY_NAME                           " + ControlChars.CrLf
				     + "  from vwLANGUAGES                            " + ControlChars.CrLf
				     + " where ACTIVE = 1                             " + ControlChars.CrLf
				     + "   and NAME not in ('en-AU', 'en-GB', 'en-CA')" + ControlChars.CrLf
				     + " order by NAME                                " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						da.Fill(dtLANGUAGES);
					}
				}
				// 04/06/2016 Paul.  Exclude disabled modules. 
				Dictionary<string, bool> dictAllModules = new Dictionary<string,bool>();
				sSQL = "select MODULE_NAME                            " + ControlChars.CrLf
				     + "     , MODULE_ENABLED                         " + ControlChars.CrLf
				     + "  from vwMODULES_Edit                         " + ControlChars.CrLf
				     + " order by MODULE_NAME                         " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							foreach ( DataRow row in dt.Rows )
							{
								string sMODULE_NAME    = Sql.ToString (row["MODULE_NAME"   ]);
								bool   bMODULE_ENABLED = Sql.ToBoolean(row["MODULE_ENABLED"]);
								if ( !dictAllModules.ContainsKey(sMODULE_NAME) )
									dictAllModules[sMODULE_NAME] = bMODULE_ENABLED;
							}
						}
					}
				}
				ViewNode view = null;
				ModuleNode dictMODULE = new ModuleNode();
				lstModules.Add(dictMODULE);
				dictMODULE.ModuleName  = String.Empty;
				dictMODULE.IsAdmin     = false;
				dictMODULE.DisplayName = "Global";
				foreach ( DataRow rowLang in dtLANGUAGES.Rows )
				{
					view = new ViewNode();
					view.ViewName    = Sql.ToString(rowLang["NAME"]);
					view.LayoutType  = "Terminology";
					view.DisplayName = Sql.ToString(rowLang["DISPLAY_NAME"]);
					dictMODULE.Terminology.Add(view);
				}
				// 03/17/2020 Paul.  Add TerminologyLists. 
				sSQL = "select LIST_NAME             " + ControlChars.CrLf
				     + "  from vwTERMINOLOGY_PickList" + ControlChars.CrLf
				     + " order by LIST_NAME          " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							foreach ( DataRow rowLang in dt.Rows )
							{
								view = new ViewNode();
								view.ViewName    = Sql.ToString(rowLang["LIST_NAME"]);
								view.LayoutType  = "TerminologyList";
								view.DisplayName = Sql.ToString(rowLang["LIST_NAME"]);
								dictMODULE.TerminologyLists.Add(view);
							}
						}
					}
				}

				sSQL = "select NAME                                   " + ControlChars.CrLf
				     + "     , MODULE_NAME                            " + ControlChars.CrLf
				     + "     , 'EditView'               as LAYOUT_TYPE" + ControlChars.CrLf
				     + "  from vwEDITVIEWS                            " + ControlChars.CrLf
				     + "union all                                     " + ControlChars.CrLf
				     + "select NAME                                   " + ControlChars.CrLf
				     + "     , MODULE_NAME                            " + ControlChars.CrLf
				     + "     , 'DetailView'             as LAYOUT_TYPE" + ControlChars.CrLf
				     + "  from vwDETAILVIEWS                          " + ControlChars.CrLf
				     + "union all                                     " + ControlChars.CrLf
				     + "select NAME                                   " + ControlChars.CrLf
				     + "     , MODULE_NAME                            " + ControlChars.CrLf
				     + "     , 'ListView'               as LAYOUT_TYPE" + ControlChars.CrLf
				     + "  from vwGRIDVIEWS                            " + ControlChars.CrLf
				     + "union all                                     " + ControlChars.CrLf
				     + "select distinct DETAIL_NAME            as NAME" + ControlChars.CrLf
				     + "     , DETAIL_NAME              as MODULE_NAME" + ControlChars.CrLf
				     + "     , 'DetailViewRelationship'               " + ControlChars.CrLf
				     + "  from vwDETAILVIEWS_RELATIONSHIPS_La         " + ControlChars.CrLf
				     + "union all                                     " + ControlChars.CrLf
				     + "select distinct EDIT_NAME              as NAME" + ControlChars.CrLf
				     + "     , EDIT_NAME               as  MODULE_NAME" + ControlChars.CrLf
				     + "     , 'EditViewRelationship'                 " + ControlChars.CrLf
				     + "  from " + Sql.MetadataName(con, "vwEDITVIEWS_RELATIONSHIPS_Layout") + ControlChars.CrLf
				     + " order by MODULE_NAME, NAME                   " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							foreach ( DataRow row in dt.Rows )
							{
								string sNAME        = Sql.ToString(row["NAME"       ]);
								string sMODULE_NAME = Sql.ToString(row["MODULE_NAME"]);
								string sLAYOUT_TYPE = Sql.ToString(row["LAYOUT_TYPE"]);
								if ( sLAYOUT_TYPE == "DetailViewRelationship" || sLAYOUT_TYPE == "EditViewRelationship" )
								{
									string[] arrMODULE_NAME = sMODULE_NAME.Split('.');
									sMODULE_NAME = arrMODULE_NAME[0];
								}
								// 04/06/2016 Paul.  Exclude disabled modules. 
								if ( dictAllModules.ContainsKey(sMODULE_NAME) && !dictAllModules[sMODULE_NAME] )
									continue;
								try
								{
									if ( !dict.ContainsKey(sMODULE_NAME) )
									{
										dictMODULE = new ModuleNode();
										dict.Add(sMODULE_NAME, dictMODULE);
										lstModules.Add(dictMODULE);
										dictMODULE.ModuleName  = sMODULE_NAME;
										dictMODULE.IsAdmin     = Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".IsAdmin"]);
										dictMODULE.DisplayName = L10n.Term(".moduleList." + sMODULE_NAME);
										if ( dictMODULE.DisplayName.StartsWith(".moduleList.") )
											dictMODULE.DisplayName = sMODULE_NAME;
										
										foreach ( DataRow rowLang in dtLANGUAGES.Rows )
										{
											view = new ViewNode();
											view.ViewName    = Sql.ToString(rowLang["NAME"]);
											view.LayoutType  = "Terminology";
											view.DisplayName = Sql.ToString(rowLang["DISPLAY_NAME"]);
											dictMODULE.Terminology.Add(view);
										}
									}
									else
									{
										dictMODULE = dict[sMODULE_NAME] as ModuleNode;
									}
									view = new ViewNode();
									view.ViewName    = sNAME       ;
									view.LayoutType  = sLAYOUT_TYPE;
									view.DisplayName = sNAME       ;
									if ( sNAME.StartsWith(sMODULE_NAME + ".") )
										view.DisplayName = sNAME.Substring(sMODULE_NAME.Length + 1);
									switch ( sLAYOUT_TYPE )
									{
										case "EditView"  :
											if ( sNAME.Contains(".Search") )
												dictMODULE.Search.Add(view);
											else
												dictMODULE.EditViews.Add(view);
											break;
										case "DetailView":
											dictMODULE.DetailViews.Add(view);
											break;
										case "ListView"  :
											// 10/19/2017 Paul.  ArchiveView should be part of the main list. 
											// 11/07/2021 Paul.  Subpanel ArchiveViews should not be in main list. 
											if ( sNAME.StartsWith(sMODULE_NAME + ".ArchiveView") || sNAME.StartsWith(sMODULE_NAME + ".ListView") || sNAME.StartsWith(sMODULE_NAME + ".PopupView") || sNAME.StartsWith(sMODULE_NAME + ".Export") || sNAME.Contains("." + sMODULE_NAME) )
												dictMODULE.ListViews.Add(view);
											else
												dictMODULE.SubPanels.Add(view);
											break;
										case "DetailViewRelationship":
											dictMODULE.Relationships.Add(view);
											break;
										case "EditViewRelationship":
											dictMODULE.Relationships.Add(view);
											break;
									}
								}
								catch(Exception ex)
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
								}
							}
						}
					}
				}
			}
			
			Dictionary<string, object> d = new Dictionary<string, object>();
			d.Add("d", lstModules);
			JavaScriptSerializer json = new JavaScriptSerializer();
			string sResponse = json.Serialize(d);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}
		
		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
		public Stream GetAdminLayoutModuleFields(string ModuleName, string LayoutType, string LayoutName)
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			if ( Sql.IsEmptyString(ModuleName) )
				throw(new Exception("The module name must be specified."));
			string sTABLE_NAME = Sql.ToString(Application["Modules." + ModuleName + ".TableName"]);
			string sVIEW_NAME  = "vw" + sTABLE_NAME;
			// 04/06/2016 Paul.  Some modules do not have a table name, but are still valid. 
			bool   bValid      = Sql.ToBoolean(Application["Modules." + ModuleName + ".Valid"]);
			if ( Sql.IsEmptyString(sTABLE_NAME) && !bValid )
				throw(new Exception("Unknown module: " + ModuleName));
			
			List<LayoutField> lstFields = new List<LayoutField>();
			if ( LayoutType != "EditView" && LayoutType != "DetailView" && LayoutType != "ListView" )
			{
				LayoutType = "EditView";
			}
			// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
			if ( Sql.IsEmptyString(LayoutName) )
			{
				LayoutName = ModuleName + "." + LayoutType;
			}
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				DataTable dtDefaultView = new DataTable();
				if ( LayoutType == "EditView" )
				{
					sSQL = "select *                        " + ControlChars.CrLf
					     + "  from vwEDITVIEWS_FIELDS       " + ControlChars.CrLf
					     + " where EDIT_NAME = @LAYOUT_NAME " + ControlChars.CrLf
					     + "   and DEFAULT_VIEW = 1         " + ControlChars.CrLf
					     + " order by FIELD_INDEX           " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@LAYOUT_NAME", LayoutName);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtDefaultView);
							if ( dtDefaultView.Rows.Count == 0 )
							{
								sSQL = "select *                        " + ControlChars.CrLf
								     + "  from vwEDITVIEWS_FIELDS       " + ControlChars.CrLf
								     + " where EDIT_NAME = @LAYOUT_NAME " + ControlChars.CrLf
								     + "   and DEFAULT_VIEW = 0         " + ControlChars.CrLf
								     + " order by FIELD_INDEX           " + ControlChars.CrLf;
								da.Fill(dtDefaultView);
							}
						}
					}
					// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
					sSQL = "select VIEW_NAME          " + ControlChars.CrLf
					     + "  from vwEDITVIEWS        " + ControlChars.CrLf
					     + " where NAME = @LAYOUT_NAME" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@LAYOUT_NAME", LayoutName);
						sVIEW_NAME = Sql.ToString(cmd.ExecuteScalar());
						if ( Sql.IsEmptyString(sVIEW_NAME) )
							sVIEW_NAME  = "vw" + sTABLE_NAME + "_Edit";
					}
				}
				else if ( LayoutType == "DetailView" )
				{
					sSQL = "select *                         " + ControlChars.CrLf
					     + "  from vwDETAILVIEWS_FIELDS      " + ControlChars.CrLf
					     + " where DETAIL_NAME = @LAYOUT_NAME" + ControlChars.CrLf
					     + "   and DEFAULT_VIEW = 1          " + ControlChars.CrLf
					     + " order by FIELD_INDEX            " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@LAYOUT_NAME", LayoutName);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtDefaultView);
							if ( dtDefaultView.Rows.Count == 0 )
							{
								sSQL = "select *                         " + ControlChars.CrLf
								     + "  from vwDETAILVIEWS_FIELDS      " + ControlChars.CrLf
								     + " where DETAIL_NAME = @LAYOUT_NAME" + ControlChars.CrLf
								     + "   and DEFAULT_VIEW = 0          " + ControlChars.CrLf
								     + " order by FIELD_INDEX            " + ControlChars.CrLf;
								da.Fill(dtDefaultView);
							}
						}
					}
					// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
					sSQL = "select VIEW_NAME          " + ControlChars.CrLf
					     + "  from vwDETAILVIEWS      " + ControlChars.CrLf
					     + " where NAME = @LAYOUT_NAME" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@LAYOUT_NAME", LayoutName);
						sVIEW_NAME = Sql.ToString(cmd.ExecuteScalar());
						if ( Sql.IsEmptyString(sVIEW_NAME) )
							sVIEW_NAME  = "vw" + sTABLE_NAME + "_Edit";
					}
				}
				else if ( LayoutType == "ListView" )
				{
					sSQL = "select *                        " + ControlChars.CrLf
					     + "  from vwGRIDVIEWS_COLUMNS      " + ControlChars.CrLf
					     + " where GRID_NAME = @LAYOUT_NAME " + ControlChars.CrLf
					     + "   and DEFAULT_VIEW = 1         " + ControlChars.CrLf
					     + " order by COLUMN_INDEX          " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@LAYOUT_NAME", LayoutName);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtDefaultView);
							if ( dtDefaultView.Rows.Count == 0 )
							{
								sSQL = "select *                        " + ControlChars.CrLf
								     + "  from vwGRIDVIEWS_COLUMNS      " + ControlChars.CrLf
								     + " where GRID_NAME = @LAYOUT_NAME " + ControlChars.CrLf
								     + "   and DEFAULT_VIEW = 0         " + ControlChars.CrLf
								     + " order by COLUMN_INDEX          " + ControlChars.CrLf;
								da.Fill(dtDefaultView);
							}
						}
					}
					// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
					sSQL = "select VIEW_NAME          " + ControlChars.CrLf
					     + "  from vwGRIDVIEWS        " + ControlChars.CrLf
					     + " where NAME = @LAYOUT_NAME" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@LAYOUT_NAME", LayoutName);
						sVIEW_NAME = Sql.ToString(cmd.ExecuteScalar());
						if ( Sql.IsEmptyString(sVIEW_NAME) )
							sVIEW_NAME  = "vw" + sTABLE_NAME + "_List";
					}
				}
				DataView vwDefaultView = new DataView(dtDefaultView);
				
				// 05/09/2016 Paul.  DetailView and ListView needs access to all fields, not just those being updated in the stored procedure. 
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
					if ( LayoutType == "EditView" && !LayoutName.Contains(".Search") )
					{
						// 08/30/2017 Paul.  Provide a way to show all fields and not just editable fields.  This will allow read-only fields to be added to an EditView. 
						if ( Sql.ToBoolean (Application["CONFIG.LayoutEditor.EditView.AllFields"]) )
						{
							sSQL = "select *                        " + ControlChars.CrLf
							     + "  from vwSqlColumns             " + ControlChars.CrLf
							     + " where ObjectName = @OBJECTNAME " + ControlChars.CrLf
							     + " order by ColumnName            " + ControlChars.CrLf;
							cmd.CommandText = sSQL;
							if ( !Sql.IsEmptyString(sVIEW_NAME) )
							{
								Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, sVIEW_NAME));
							}
							else
							{
								Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, "vw" + sTABLE_NAME));
							}
						}
						else
						{
							sSQL = "select *                        " + ControlChars.CrLf
							     + "  from vwSqlColumns             " + ControlChars.CrLf
							     + " where ObjectName = @OBJECTNAME " + ControlChars.CrLf
							     + "   and ObjectType = 'P'         " + ControlChars.CrLf
							     + " union all                      " + ControlChars.CrLf
							     + "select *                        " + ControlChars.CrLf
							     + "  from vwSqlColumns             " + ControlChars.CrLf
							     + " where ObjectName = @CUSTOMNAME " + ControlChars.CrLf
							     + "   and ObjectType = 'U'         " + ControlChars.CrLf;
							// 02/20/2016 Paul.  Oracle does not allow order by after union all. 
							// 03/20/2016 Paul.  We still want an alphabetical sort. 
							if ( Sql.IsOracle(con) )
							{
								sSQL = "select *" + ControlChars.CrLf
								     + " from (" + sSQL + ControlChars.CrLf
								     + "      ) vwSqlColumns" + ControlChars.CrLf
								     + " order by ColumnName" + ControlChars.CrLf;
							}
							else
							{
								sSQL += " order by ColumnName" + ControlChars.CrLf;
							}
							cmd.CommandText = sSQL;
							// 05/09/2016 Paul.  DetailView and ListView needs access to all fields, not just those being updated in the stored procedure. 
							Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, "sp" + sTABLE_NAME + "_Update"));
							Sql.AddParameter(cmd, "@CUSTOMNAME", Sql.MetadataName(cmd, sTABLE_NAME + "_CSTM"));
						}
					}
					else
					{
						sSQL = "select *" + ControlChars.CrLf
						     + "  from vwSqlColumns             " + ControlChars.CrLf
						     + " where ObjectName = @OBJECTNAME " + ControlChars.CrLf
						     + " order by ColumnName            " + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						// 10/19/2016 Paul.  Specify the LayoutName so that we can search the fields added in a _List view. 
						if ( !Sql.IsEmptyString(sVIEW_NAME) )
						{
							Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, sVIEW_NAME));
						}
						else if ( LayoutType == "ListView" )
						{
							Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, "vw" + sTABLE_NAME + "_List"));
						}
						else
						{
							Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, "vw" + sTABLE_NAME));
						}
					}
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							if ( !dt.Columns.Contains("FIELD_TYPE"        ) ) dt.Columns.Add("FIELD_TYPE"        , typeof(System.String));
							// 02/20/2016 Paul.  EditView columns. 
							if ( !dt.Columns.Contains("DATA_LABEL"        ) ) dt.Columns.Add("DATA_LABEL"        , typeof(System.String));
							if ( !dt.Columns.Contains("DATA_FIELD"        ) ) dt.Columns.Add("DATA_FIELD"        , typeof(System.String));
							if ( !dt.Columns.Contains("DISPLAY_FIELD"     ) ) dt.Columns.Add("DISPLAY_FIELD"     , typeof(System.String));
							if ( !dt.Columns.Contains("MODULE_TYPE"       ) ) dt.Columns.Add("MODULE_TYPE"       , typeof(System.String));
							if ( !dt.Columns.Contains("LIST_NAME"         ) ) dt.Columns.Add("LIST_NAME"         , typeof(System.String));
							if ( !dt.Columns.Contains("DATA_FORMAT"       ) ) dt.Columns.Add("DATA_FORMAT"       , typeof(System.String));
							if ( !dt.Columns.Contains("FORMAT_MAX_LENGTH" ) ) dt.Columns.Add("FORMAT_MAX_LENGTH" , typeof(System.Int32 ));
							// 02/15/2016 Paul.  DetailView columns. 
							if ( !dt.Columns.Contains("URL_FIELD"         ) ) dt.Columns.Add("URL_FIELD"         , typeof(System.String));
							if ( !dt.Columns.Contains("URL_FORMAT"        ) ) dt.Columns.Add("URL_FORMAT"        , typeof(System.String));
							// 02/15/2016 Paul.  ListView columns. 
							if ( !dt.Columns.Contains("COLUMN_TYPE"       ) ) dt.Columns.Add("COLUMN_TYPE"       , typeof(System.String));
							if ( !dt.Columns.Contains("HEADER_TEXT"       ) ) dt.Columns.Add("HEADER_TEXT"       , typeof(System.String));
							if ( !dt.Columns.Contains("SORT_EXPRESSION"   ) ) dt.Columns.Add("SORT_EXPRESSION"   , typeof(System.String));
							if ( !dt.Columns.Contains("URL_ASSIGNED_FIELD") ) dt.Columns.Add("URL_ASSIGNED_FIELD", typeof(System.String));
							foreach ( DataRow row in dt.Rows )
							{
								string sColumnName = Sql.ToString (row["ColumnName"]);
								if ( sColumnName.StartsWith("@") )
									sColumnName = sColumnName.Replace("@", String.Empty);
								else if ( sColumnName.StartsWith("ID_") && Sql.IsOracle(cmd) )
									sColumnName = sColumnName.Substring(3);
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								// 12/08/2017 Paul.  We want to see the ID on the export. 
								if ( (sColumnName == "ID" && !LayoutName.Contains(".Export")) || sColumnName == "ID_C" || sColumnName == "MODIFIED_USER_ID" || sColumnName == "TEAM_SET_LIST" || sColumnName == "ASSIGNED_SET_LIST" )
								{
									row.Delete();
									continue;
								}
								row["ColumnName" ] = sColumnName ;
								row["DATA_LABEL" ] = Utils.BuildTermName(ModuleName, sColumnName);
								row["DATA_FIELD" ] = sColumnName;
								if ( LayoutType == "EditView" )
								{
									row["FIELD_TYPE" ] = "TextBox";
									vwDefaultView.RowFilter = "DATA_FIELD = '" + sColumnName + "'";
									if ( vwDefaultView.Count > 0 )
									{
										row["FIELD_TYPE"       ] = Sql.ToString (vwDefaultView[0]["FIELD_TYPE"       ]);
										row["DISPLAY_FIELD"    ] = Sql.ToString (vwDefaultView[0]["DISPLAY_FIELD"    ]);
										row["LIST_NAME"        ] = Sql.ToString (vwDefaultView[0]["LIST_NAME"        ]);
										row["DATA_FORMAT"      ] = Sql.ToString (vwDefaultView[0]["DATA_FORMAT"      ]);
										row["FORMAT_MAX_LENGTH"] = Sql.ToInteger(vwDefaultView[0]["FORMAT_MAX_LENGTH"]);
										row["MODULE_TYPE"      ] = Sql.ToString (vwDefaultView[0]["MODULE_TYPE"      ]);
									}
								}
								else if ( LayoutType == "DetailView" )
								{
									row["FIELD_TYPE" ] = "String";
									row["DATA_FORMAT"] = "{0}";
									vwDefaultView.RowFilter = "DATA_FIELD = '" + sColumnName + "'";
									if ( vwDefaultView.Count > 0 )
									{
										row["FIELD_TYPE" ] = Sql.ToString(vwDefaultView[0]["FIELD_TYPE" ]);
										row["LIST_NAME"  ] = Sql.ToString(vwDefaultView[0]["LIST_NAME"  ]);
										row["DATA_FORMAT"] = Sql.ToString(vwDefaultView[0]["DATA_FORMAT"]);
										row["URL_FIELD"  ] = Sql.ToString(vwDefaultView[0]["URL_FIELD"  ]);
										row["URL_FORMAT" ] = Sql.ToString(vwDefaultView[0]["URL_FORMAT" ]);
										row["MODULE_TYPE"] = Sql.ToString(vwDefaultView[0]["MODULE_TYPE"]);
									}
								}
								else if ( LayoutType == "ListView" )
								{
									row["COLUMN_TYPE"    ] = "BoundColumn";
									row["DATA_FORMAT"    ] = String.Empty;
									row["SORT_EXPRESSION"] = sColumnName;
									// 07/18/2018 Paul.  We need to check for the subpanel, so that the terms for Contacts are used for the Accounts.Contacts layout. 
									string sMODULE_NAME = ModuleName;
									string[] arrNAME = LayoutName.Split('.');
									if ( arrNAME.Length > 1 && Sql.ToBoolean(Application["Modules." + arrNAME[1] + ".Valid"]) )
									{
										sMODULE_NAME = arrNAME[1];
									}
									row["HEADER_TEXT"    ] = Utils.BuildTermName(sMODULE_NAME, sColumnName).Replace(".LBL_", ".LBL_LIST_");
									vwDefaultView.RowFilter = "DATA_FIELD = '" + sColumnName + "'";
									if ( vwDefaultView.Count > 0 )
									{
										row["COLUMN_TYPE"       ] = Sql.ToString(vwDefaultView[0]["COLUMN_TYPE"       ]);
										row["DATA_FORMAT"       ] = Sql.ToString(vwDefaultView[0]["DATA_FORMAT"       ]);
										row["HEADER_TEXT"       ] = Sql.ToString(vwDefaultView[0]["HEADER_TEXT"       ]);
										row["SORT_EXPRESSION"   ] = Sql.ToString(vwDefaultView[0]["SORT_EXPRESSION"   ]);
										row["LIST_NAME"         ] = Sql.ToString(vwDefaultView[0]["LIST_NAME"         ]);
										row["URL_FIELD"         ] = Sql.ToString(vwDefaultView[0]["URL_FIELD"         ]);
										row["URL_FORMAT"        ] = Sql.ToString(vwDefaultView[0]["URL_FORMAT"        ]);
										row["MODULE_TYPE"       ] = Sql.ToString(vwDefaultView[0]["MODULE_TYPE"       ]);
										row["URL_ASSIGNED_FIELD"] = Sql.ToString(vwDefaultView[0]["URL_ASSIGNED_FIELD"]);
									}
								}
							}
							dt.AcceptChanges();
							DataView vw = new DataView(dt);
							vw.Sort = "DATA_FIELD asc";
							foreach ( DataRow row in dt.Rows )
							{
								LayoutField lay = new LayoutField();
								lay.ColumnName         = Sql.ToString (row["ColumnName"        ]);
								lay.ColumnType         = Sql.ToString (row["ColumnType"        ]);
								lay.CsType             = Sql.ToString (row["CsType"            ]);
								lay.length             = Sql.ToInteger(row["length"            ]);
								lay.FIELD_TYPE         = Sql.ToString (row["FIELD_TYPE"        ]);
								lay.DATA_LABEL         = Sql.ToString (row["DATA_LABEL"        ]);
								lay.DATA_FIELD         = Sql.ToString (row["DATA_FIELD"        ]);
								lay.MODULE_TYPE        = Sql.ToString (row["MODULE_TYPE"       ]);
								lay.LIST_NAME          = Sql.ToString (row["LIST_NAME"         ]);
								lay.DATA_FORMAT        = Sql.ToString (row["DATA_FORMAT"       ]);
								if ( lay.CsType == "string" )
									lay.FORMAT_MAX_LENGTH  = Sql.ToInteger(row["FORMAT_MAX_LENGTH" ]);
								lay.URL_FIELD          = Sql.ToString (row["URL_FIELD"         ]);
								lay.URL_FORMAT         = Sql.ToString (row["URL_FORMAT"        ]);
								lay.COLUMN_TYPE        = Sql.ToString (row["COLUMN_TYPE"       ]);
								lay.HEADER_TEXT        = Sql.ToString (row["HEADER_TEXT"       ]);
								lay.SORT_EXPRESSION    = Sql.ToString (row["SORT_EXPRESSION"   ]);
								lay.URL_ASSIGNED_FIELD = Sql.ToString (row["URL_ASSIGNED_FIELD"]);
								lstFields.Add(lay);
							}
						}
					}
				}
			}
			
			Dictionary<string, object> d = new Dictionary<string, object>();
			d.Add("d", lstFields);
			JavaScriptSerializer json = new JavaScriptSerializer();
			string sResponse = json.Serialize(d);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAdminLayoutRelationshipFields(string TableName, string ModuleName)
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			if ( Sql.IsEmptyString(TableName) )
				throw(new Exception("The table name must be specified."));
			if ( !TableName.StartsWith("vw") )
				throw(new Exception("The table name is not in the correct format."));
			Regex r = new Regex(@"[^A-Za-z0-9_]");
			string sTABLE_NAME = r.Replace(TableName, "");
			
			List<LayoutField> lstFields = new List<LayoutField>();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				sSQL = "select *                        " + ControlChars.CrLf
				     + "  from vwSqlColumns             " + ControlChars.CrLf
				     + " where ObjectName = @OBJECTNAME " + ControlChars.CrLf
				     + "   and ObjectType = 'V'         " + ControlChars.CrLf
				     + " order by ColumnName            " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					// 02/20/2016 Paul.  Make sure to use upper case for Oracle. 
					Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, sTABLE_NAME));
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							dt.Columns.Add("FIELD_TYPE"        , typeof(System.String));
							dt.Columns.Add("DATA_LABEL"        , typeof(System.String));
							dt.Columns.Add("DATA_FIELD"        , typeof(System.String));
							foreach ( DataRow row in dt.Rows )
							{
								string sColumnName = Sql.ToString (row["ColumnName"]);
								row["ColumnName" ] = sColumnName ;
								row["DATA_LABEL" ] = Utils.BuildTermName(ModuleName, sColumnName);
								row["DATA_FIELD" ] = sColumnName;
							}
							DataView vw = new DataView(dt);
							vw.Sort = "DATA_FIELD asc";

							foreach ( DataRow row in dt.Rows )
							{
								LayoutField lay = new LayoutField();
								lay.ColumnName  = Sql.ToString (row["ColumnName" ]);
								lay.ColumnType  = Sql.ToString (row["ColumnType" ]);
								lay.CsType      = Sql.ToString (row["CsType"     ]);
								lay.length      = Sql.ToInteger(row["length"     ]);
								lay.DATA_LABEL  = Sql.ToString (row["DATA_LABEL" ]);
								lay.DATA_FIELD  = Sql.ToString (row["DATA_FIELD" ]);
								lstFields.Add(lay);
							}
						}
					}
				}
			}
			
			Dictionary<string, object> d = new Dictionary<string, object>();
			d.Add("d", lstFields);
			JavaScriptSerializer json = new JavaScriptSerializer();
			string sResponse = json.Serialize(d);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAdminLayoutTerminologyLists()
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpContext          Context     = HttpContext.Current;
			HttpSessionState     Session     = HttpContext.Current.Session;
			HttpApplicationState Application = HttpContext.Current.Application;
			
			L10N L10n = new L10N(Session["USER_SETTINGS/CULTURE"] as string);
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			Dictionary<string, object> d       = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			Dictionary<string, object> objs    = new Dictionary<string, object>();
			results.Add("results", objs);
			d.Add("d", results);
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					List<string> vwTERMINOLOGY_PickList = new List<string>();
					sSQL = "select LIST_NAME             " + ControlChars.CrLf
					     + "  from vwTERMINOLOGY_PickList" + ControlChars.CrLf
					     + " order by LIST_NAME          " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								foreach ( DataRow row in dt.Rows )
								{
									string sNAME = Sql.ToString(row["LIST_NAME"]);
									vwTERMINOLOGY_PickList.Add(sNAME);
								}
							}
						}
					}
					for ( int i = 0; i < SplendidCache.CustomCaches.Count; i++ )
					{
						vwTERMINOLOGY_PickList.Add(SplendidCache.CustomCaches[i].Name);
					}
					objs.Add("vwTERMINOLOGY_PickList", vwTERMINOLOGY_PickList);
					
					List<string> FIELD_VALIDATORS = new List<string>();
					sSQL = "select ID                " + ControlChars.CrLf
					     + "     , NAME              " + ControlChars.CrLf
					     + "  from vwFIELD_VALIDATORS" + ControlChars.CrLf
					     + " order by NAME           " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								foreach ( DataRow row in dt.Rows )
								{
									string sNAME = Sql.ToString(row["ID"]);
									FIELD_VALIDATORS.Add(sNAME);
								}
							}
						}
					}
					objs.Add("FIELD_VALIDATORS", FIELD_VALIDATORS);
					
					DataTable dtModules = SplendidCache.ModulesPopups(Context);
					DataView vwModules = new DataView(dtModules);
					vwModules.RowFilter = "HAS_POPUP = 1";
					List<string> MODULE_TYPES = new List<string>();
					foreach ( DataRowView row in vwModules )
					{
						string sNAME = Sql.ToString(row["MODULE_NAME"]);
						MODULE_TYPES.Add(sNAME);
					}
					objs.Add("MODULE_TYPES", MODULE_TYPES);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
			// 04/21/2017 Paul.  Count should be returend as a number. 
			d.Add("__count", objs.Count);
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			return RestUtil.ToJsonStream(d);
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAdminLayoutTerminology()
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpContext          Context     = HttpContext.Current;
			HttpSessionState     Session     = HttpContext.Current.Session;
			HttpApplicationState Application = HttpContext.Current.Application;
			
			L10N L10n = new L10N(Session["USER_SETTINGS/CULTURE"] as string);
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			Dictionary<string, object>       d       = new Dictionary<string, object>();
			Dictionary<string, object>       results = new Dictionary<string, object>();
			List<Dictionary<string, object>> objs    = new List<Dictionary<string, object>>();
			results.Add("results", objs);
			d.Add("d", results);
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select NAME                         " + ControlChars.CrLf
					     + "     , MODULE_NAME                  " + ControlChars.CrLf
					     + "     , DISPLAY_NAME                 " + ControlChars.CrLf
					     + "  from vwTERMINOLOGY                " + ControlChars.CrLf
					     + " where MODULE_NAME in ('DynamicLayout', 'BusinessRules')" + ControlChars.CrLf
					     + "   and LANG = @LANG                 " + ControlChars.CrLf
					     + " order by NAME                      " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						string sLANG  = Sql.ToString(Session["USER_SETTINGS/CULTURE" ]);
						Sql.AddParameter(cmd, "@LANG", sLANG);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								foreach ( DataRow row in dt.Rows )
								{
									Dictionary<string, object> drow = new Dictionary<string, object>();
									drow.Add("NAME"        , Sql.ToString(row["NAME"        ]));
									drow.Add("LIST_NAME"   , null                             );
									drow.Add("MODULE_NAME" , Sql.ToString(row["MODULE_NAME" ]));
									drow.Add("DISPLAY_NAME", Sql.ToString(row["DISPLAY_NAME"]));
									objs.Add(drow);
								}
							}
						}
					}
					sSQL = "select MODULE_NAME                  " + ControlChars.CrLf
					     + "     , DISPLAY_NAME                 " + ControlChars.CrLf
					     + "  from vwMODULES                    " + ControlChars.CrLf
					     + " order by MODULE_NAME               " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								foreach ( DataRow row in dt.Rows )
								{
									string sMODULE_NAME  = Sql.ToString(row["MODULE_NAME" ]);
									string sDISPLAY_NAME = Sql.ToString(row["DISPLAY_NAME"]);
									Dictionary<string, object> drow = new Dictionary<string, object>();
									drow.Add("NAME"        , "LBL_MODULE_NAME" );
									drow.Add("LIST_NAME"   , null              );
									drow.Add("MODULE_NAME" , sMODULE_NAME      );
									drow.Add("DISPLAY_NAME", L10n.Term(sMODULE_NAME + ".LBL_MODULE_NAME"));
									objs.Add(drow);
									drow = new Dictionary<string, object>();
									drow.Add("NAME"        , "LBL_NEW_FORM_TITLE" );
									drow.Add("LIST_NAME"   , null              );
									drow.Add("MODULE_NAME" , sMODULE_NAME      );
									drow.Add("DISPLAY_NAME", L10n.Term(sMODULE_NAME + ".LBL_NEW_FORM_TITLE"));
									objs.Add(drow);
									if ( sMODULE_NAME == "Activities" )
									{
										drow = new Dictionary<string, object>();
										drow.Add("NAME"        , "LBL_HISTORY"        );
										drow.Add("LIST_NAME"   , null                 );
										drow.Add("MODULE_NAME" , sMODULE_NAME         );
										drow.Add("DISPLAY_NAME", L10n.Term(sMODULE_NAME + ".LBL_HISTORY"));
										objs.Add(drow);
										drow = new Dictionary<string, object>();
										drow.Add("NAME"        , "LBL_OPEN_ACTIVITIES");
										drow.Add("LIST_NAME"   , null                 );
										drow.Add("MODULE_NAME" , sMODULE_NAME         );
										drow.Add("DISPLAY_NAME", L10n.Term(sMODULE_NAME + ".LBL_OPEN_ACTIVITIES"));
										objs.Add(drow);
									}
									if ( sDISPLAY_NAME.StartsWith(".moduleList.") )
									{
										drow = new Dictionary<string, object>();
										drow.Add("NAME"        , sDISPLAY_NAME.Replace(".moduleList.", ""));
										drow.Add("LIST_NAME"   , "moduleList" );
										drow.Add("MODULE_NAME" , null         );
										drow.Add("DISPLAY_NAME", sDISPLAY_NAME);
										objs.Add(drow);
									}
								}
							}
						}
					}
					sSQL = "select ID                " + ControlChars.CrLf
					     + "     , NAME              " + ControlChars.CrLf
					     + "  from vwFIELD_VALIDATORS" + ControlChars.CrLf
					     + " order by NAME           " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								foreach ( DataRow row in dt.Rows )
								{
									Dictionary<string, object> drow = new Dictionary<string, object>();
									drow.Add("NAME"        , Sql.ToString(row["ID"  ]));
									drow.Add("LIST_NAME"   , "FIELD_VALIDATORS"       );
									drow.Add("MODULE_NAME" , null                     );
									drow.Add("DISPLAY_NAME", Sql.ToString(row["NAME"]));
									objs.Add(drow);
								}
							}
						}
					}
				}
				objs.Add(CreateGlobalTerm(L10n, "LBL_SELECT_BUTTON_LABEL"     ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_CLEAR_BUTTON_LABEL"      ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_SAVE_BUTTON_LABEL"       ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_CANCEL_BUTTON_LABEL"     ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_EXPORT_BUTTON_LABEL"     ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_DEFAULTS_BUTTON_LABEL"   ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_DELETE"                  ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_ID"                      ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_DELETED"                 ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_CREATED_BY"              ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_CREATED_BY_ID"           ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_CREATED_BY_NAME"         ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_DATE_ENTERED"            ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_MODIFIED_USER_ID"        ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_DATE_MODIFIED"           ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_DATE_MODIFIED_UTC"       ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_MODIFIED_BY"             ));
				// 04/19/2018 Paul.  MODIFIED_BY_ID is not the correct name, use MODIFIED_USER_ID instead. 
				objs.Add(CreateGlobalTerm(L10n, "LBL_MODIFIED_USER_ID"        ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_MODIFIED_BY_NAME"        ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_ASSIGNED_USER_ID"        ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_ASSIGNED_TO"             ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_ASSIGNED_TO_NAME"        ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_TEAM_ID"                 ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_TEAM_NAME"               ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_TEAM_SET_ID"             ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_TEAM_SET_NAME"           ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_TEAM_SET_LIST"           ));
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				objs.Add(CreateGlobalTerm(L10n, "LBL_ASSIGNED_SET_ID"         ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_ASSIGNED_SET_NAME"       ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_ASSIGNED_SET_LIST"       ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_ID_C"                    ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LAST_ACTIVITY_DATE"      ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_ID"                 ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_DELETED"            ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_CREATED_BY"         ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_CREATED_BY_ID"      ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_CREATED_BY_NAME"    ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_DATE_ENTERED"       ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_MODIFIED_USER_ID"   ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_DATE_MODIFIED"      ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_DATE_MODIFIED_UTC"  ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_MODIFIED_BY"        ));
				// 04/19/2018 Paul.  MODIFIED_BY_ID is not the correct name, use MODIFIED_USER_ID instead. 
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_MODIFIED_USER_ID"   ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_MODIFIED_BY_NAME"   ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_ASSIGNED_USER_ID"   ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_ASSIGNED_TO"        ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_ASSIGNED_TO_NAME"   ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_TEAM_ID"            ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_TEAM_NAME"          ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_TEAM_SET_ID"        ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_TEAM_SET_NAME"      ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_TEAM_SET_LIST"      ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_ID_C"               ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_LAST_ACTIVITY_DATE" ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_ACTIVITY_STREAM"         ));
				// 05/13/2016 Paul.  LBL_TAG_SET_NAME should be global. 
				objs.Add(CreateGlobalTerm(L10n, "LBL_TAG_SET_NAME"            ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_TAG_SET_NAME"       ));
				// 08/20/2016 Paul.  PENDING_PROCESS_ID should be a global term. 
				objs.Add(CreateGlobalTerm(L10n, "LBL_PENDING_PROCESS_ID"      ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_PENDING_PROCESS_ID" ));
				// 07/18/2018 Paul.  Add Archive terms. 
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_ARCHIVE_BY"         ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_ARCHIVE_BY_NAME"    ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_ARCHIVE_DATE_UTC"   ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_ARCHIVE_USER_ID"    ));
				objs.Add(CreateGlobalTerm(L10n, "LBL_LIST_ARCHIVE_VIEW"       ));
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
			// 04/21/2017 Paul.  Count should be returend as a number. 
			d.Add("__count", objs.Count);
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			return RestUtil.ToJsonStream(d);
		}

		private Dictionary<string, object> CreateGlobalTerm(L10N L10n, string sTerm)
		{
			Dictionary<string, object> drow = new Dictionary<string, object>();
			drow.Add("NAME"        , sTerm       );
			drow.Add("LIST_NAME"   , null        );
			drow.Add("MODULE_NAME" , String.Empty);
			drow.Add("DISPLAY_NAME", L10n.Term("." + sTerm));
			return drow;
		}

		public class RecompileStatus
		{
			public string   StartDate       ;
			public bool     Restart         ;
			public int      CurrentPass     ;
			public int      TotalPasses     ;
			public int      CurrentView     ;
			public int      TotalViews      ;
			public string   CurrentViewName ;
			public int      ElapseSeconds   ;
			public int      ViewsPerSecond  ;
			public int      RemainingSeconds;
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public RecompileStatus GetRecompileStatus()
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpApplicationState Application = HttpContext.Current.Application;
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			RecompileStatus oStatus = null;
			if ( !Sql.IsEmptyString(Application["System.Recompile.StartDate"]) )
			{
				oStatus = new RecompileStatus();
				oStatus.StartDate       = Sql.ToString  (Application["System.Recompile.StartDate"      ]);
				oStatus.Restart         = Sql.ToBoolean (Application["System.Recompile.Restart"        ]);
				oStatus.CurrentPass     = Sql.ToInteger (Application["System.Recompile.CurrentPass"    ]);
				oStatus.TotalPasses     = Sql.ToInteger (Application["System.Recompile.TotalPasses"    ]);
				oStatus.CurrentView     = Sql.ToInteger (Application["System.Recompile.CurrentView"    ]);
				oStatus.TotalViews      = Sql.ToInteger (Application["System.Recompile.TotalViews"     ]);
				oStatus.CurrentViewName = Sql.ToString  (Application["System.Recompile.CurrentViewName"]);
				
				DateTime dtStartDate = Sql.ToDateTime(Application["System.Recompile.StartDate"]);
				TimeSpan ts = DateTime.Now - dtStartDate;
				oStatus.ElapseSeconds = Convert.ToInt32(ts.TotalSeconds);
				if ( oStatus.ElapseSeconds > 0 )
				{
					oStatus.ViewsPerSecond   = ((oStatus.CurrentPass - 1) * oStatus.TotalViews + oStatus.CurrentView) / oStatus.ElapseSeconds;
					if ( oStatus.ViewsPerSecond > 0 )
						oStatus.RemainingSeconds = (oStatus.TotalPasses * oStatus.TotalViews - ((oStatus.CurrentPass - 1) * oStatus.TotalViews + oStatus.CurrentView)) / oStatus.ViewsPerSecond;
				}
			}
			return oStatus;
		}

		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public void RecompileViews()
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			if ( Application["System.Recompile.Start"] == null )
			{
				// 10/31/2021 Paul.  Moved RecompileViews to ModuleUtils. 
				System.Threading.Thread t = new System.Threading.Thread(ModuleUtils.EditCustomFields.RecompileViews);
				t.Start(HttpContext.Current);
			}
			else
			{
				Application["System.Recompile.Restart"] = true;
			}
		}

		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public void RebuildAudit()
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			if ( Application["System.RebuildAudit.Start"] == null )
			{
				System.Threading.Thread t = new System.Threading.Thread(Utils.BuildAllAuditTables);
				t.Start(HttpContext.Current);
			}
			else
			{
				throw(new Exception("Already started at " + Sql.ToString(Application["System.RebuildAudit.Start"])));
			}
		}

		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public void BuildModuleArchive(Guid ID)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbTransaction trn = Sql.BeginTransaction(con) )
				{
					try
					{
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.Transaction = trn;
							cmd.CommandType = CommandType.StoredProcedure;
							cmd.CommandText = "spMODULES_ArchiveBuild";
							// 10/18/2017 Paul.  We need to prevent a timeout. 
							cmd.CommandTimeout = 0;
							IDbDataParameter parID               = Sql.AddParameter(cmd, "@ID"              , ID                 );
							IDbDataParameter parMODIFIED_USER_ID = Sql.AddParameter(cmd, "@MODIFIED_USER_ID",  Security.USER_ID  );
							cmd.ExecuteNonQuery();
						}
						trn.Commit();
					}
					catch
					{
						trn.Rollback();
						throw;
					}
				}
			}
		}

		[OperationContract]
		public Stream PostAdminTable(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

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

			string TableName = Sql.ToString (Request["TableName"]);
			int    nSKIP     = Sql.ToInteger(Request["$skip"    ]);
			int    nTOP      = Sql.ToInteger(Request["$top"     ]);
			string sFILTER   = Sql.ToString (Request["$filter"  ]);
			string sORDER_BY = Sql.ToString (Request["$orderby" ]);
			// 06/17/2013 Paul.  Add support for GROUP BY. 
			string sGROUP_BY = Sql.ToString (Request["$groupby" ]);
			// 08/03/2011 Paul.  We need a way to filter the columns so that we can be efficient. 
			string sSELECT   = Sql.ToString (Request["$select"  ]);
			long lTotalCount = 0;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			Regex r = new Regex(@"[^A-Za-z0-9_]");
			// 10/19/2016 Paul.  We need to filter out quoted strings. 
			string sFILTER_KEYWORDS = Sql.SqlFilterLiterals(sFILTER);
			sFILTER_KEYWORDS = (" " + r.Replace(sFILTER_KEYWORDS, " ") + " ").ToLower();
			int nSelectIndex     = sFILTER_KEYWORDS.IndexOf(" select "            );
			int nFromIndex       = sFILTER_KEYWORDS.IndexOf(" from "              );
			if ( nSelectIndex >= 0 && nFromIndex > nSelectIndex )
			{
				throw(new Exception("Subqueries are not allowed."));
			}

			// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
			Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
			Dictionary<string, object> dictSearchValues = null;
			try
			{
				foreach ( string sName in dict.Keys )
				{
					switch ( sName )
					{
						case "TableName"       :  TableName        = Sql.ToString (dict[sName]);  break;
						case "$skip"           :  nSKIP            = Sql.ToInteger(dict[sName]);  break;
						case "$top"            :  nTOP             = Sql.ToInteger(dict[sName]);  break;
						case "$filter"         :  sFILTER          = Sql.ToString (dict[sName]);  break;
						case "$orderby"        :  sORDER_BY        = Sql.ToString (dict[sName]);  break;
						case "$groupby"        :  sGROUP_BY        = Sql.ToString (dict[sName]);  break;
						case "$select"         :  sSELECT          = Sql.ToString (dict[sName]);  break;
						case "$searchvalues"   :  dictSearchValues = dict[sName] as Dictionary<string, object>;  break;
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

			// 10/26/2019 Paul.  Return the SQL to the React Client. 
			StringBuilder sbDumpSQL = new StringBuilder();
			DataTable dt = new DataTable();
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			string sMODULE_NAME = Sql.ToString (Application["Modules." + TableName + ".ModuleName"]);
			// 03/06/2019 Paul.  For security reasons, the OAUTH tables will never be returned. 
			if ( !Sql.IsEmptyString(sMODULE_NAME) && !TableName.StartsWith("OAUTH") && !TableName.StartsWith("USERS_PASSWORD") && !TableName.EndsWith("_AUDIT") && !TableName.EndsWith("_STREAM") )
			{
				bool bIsAdmin = Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".IsAdmin"]);
				if ( bIsAdmin && SplendidCRM.Security.AdminUserAccess(sMODULE_NAME, "access") >= 0 )
				{
					// 10/26/2019 Paul.  Return the SQL to the React Client. 
					// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs
					// 10/16/2020 Paul.  Use AccessMode.list so that we use the _List view if available. 
					// 03/10/2021 Paul.  We should still require that the table/module be registered in order to return results. 
					using ( DataTable dtSYNC_TABLES = SplendidCache.RestTables(TableName, false) )
					{
						if ( dtSYNC_TABLES != null && dtSYNC_TABLES.Rows.Count > 0 )
						{
							dt = RestUtil.GetAdminTable(Context, TableName, nSKIP, nTOP, sFILTER, sORDER_BY, sGROUP_BY, arrSELECT, null, ref lTotalCount, null, AccessMode.list, sbDumpSQL);
						}
						else
						{
							throw(new Exception("Unsupported table: " + TableName));
						}
					}
				}
				else
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
			}
			// 09/14/2021 Paul.  Instead of adding audit tables to SYSTEM_REST_TABLES, just allow to follow access of base table. 
			else if ( TableName.EndsWith("_AUDIT") )
			{
				TableName = TableName.Substring(0, TableName.Length - 6);
				using ( DataTable dtSYNC_TABLES = SplendidCache.RestTables(TableName, false) )
				{
					if ( dtSYNC_TABLES != null && dtSYNC_TABLES.Rows.Count > 0 )
					{
						TableName += "_AUDIT";
						DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
						string sMODULE_NAME_PRIMARY = Sql.ToString (rowSYNC_TABLE["MODULE_NAME"        ]);
						string sMODULE_NAME_RELATED = Sql.ToString (rowSYNC_TABLE["MODULE_NAME_RELATED"]);
						bool   bIS_RELATIONSHIP     = Sql.ToBoolean(rowSYNC_TABLE["IS_RELATIONSHIP"    ]);
						if ( SplendidCRM.Security.AdminUserAccess(sMODULE_NAME_PRIMARY, "access") >= 0 )
						{
							if ( bIS_RELATIONSHIP )
							{
								if ( SplendidCRM.Security.AdminUserAccess(sMODULE_NAME_RELATED, "access") >= 0 )
								{
									dt = RestUtil.GetAdminTable(Context, TableName, nSKIP, nTOP, sFILTER, sORDER_BY, sGROUP_BY, arrSELECT, null, ref lTotalCount, null, AccessMode.list, sbDumpSQL);
								}
								else
								{
									throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
								}
							}
							else
							{
								dt = RestUtil.GetAdminTable(Context, TableName, nSKIP, nTOP, sFILTER, sORDER_BY, sGROUP_BY, arrSELECT, null, ref lTotalCount, null, AccessMode.list, sbDumpSQL);
							}
						}
						else
						{
							throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
						}
					}
					else
					{
						throw(new Exception("Unsupported table: " + TableName));
					}
				}
			}
			else
			{
				// 01/19/2021 Paul.  If it is not a module-based table, then we need to lookup it up from the REST tables. 
				using ( DataTable dtSYNC_TABLES = SplendidCache.RestTables(TableName, false) )
				{
					if ( dtSYNC_TABLES != null && dtSYNC_TABLES.Rows.Count > 0 )
					{
						DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
						string sMODULE_NAME_PRIMARY = Sql.ToString (rowSYNC_TABLE["MODULE_NAME"        ]);
						string sMODULE_NAME_RELATED = Sql.ToString (rowSYNC_TABLE["MODULE_NAME_RELATED"]);
						bool   bIS_RELATIONSHIP     = Sql.ToBoolean(rowSYNC_TABLE["IS_RELATIONSHIP"    ]);
						if ( SplendidCRM.Security.AdminUserAccess(sMODULE_NAME_PRIMARY, "access") >= 0 )
						{
							if ( bIS_RELATIONSHIP )
							{
								if ( SplendidCRM.Security.AdminUserAccess(sMODULE_NAME_RELATED, "access") >= 0 )
								{
									dt = RestUtil.GetAdminTable(Context, TableName, nSKIP, nTOP, sFILTER, sORDER_BY, sGROUP_BY, arrSELECT, null, ref lTotalCount, null, AccessMode.list, sbDumpSQL);
								}
								else
								{
									throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
								}
							}
							else
							{
								dt = RestUtil.GetAdminTable(Context, TableName, nSKIP, nTOP, sFILTER, sORDER_BY, sGROUP_BY, arrSELECT, null, ref lTotalCount, null, AccessMode.list, sbDumpSQL);
							}
						}
						else
						{
							throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
						}
					}
					else
					{
						throw(new Exception("Unsupported table: " + TableName));
					}
				}
			}
			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, dt, T10n);
			dictResponse.Add("__total", lTotalCount);
			// 10/26/2019 Paul.  Return the SQL to the React Client. 
			if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
			{
				dictResponse.Add("__sql", sbDumpSQL.ToString());
			}
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		// 12/15/2019 Paul.  Export needs to follow the same parsing rules as PostModuleList. 
		[OperationContract]
		public Stream ExportAdminModule(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));

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

			string ModuleName        = Sql.ToString (Request["ModuleName"]);
			int    nSKIP             = Sql.ToInteger(Request["$skip"     ]);
			int    nTOP              = Sql.ToInteger(Request["$top"      ]);
			// 11/18/2019 Paul.  Move exclusively to SqlSearchClause. 
			string sFILTER           = String.Empty;  // Sql.ToString (Request["$filter"   ]);
			string sORDER_BY         = Sql.ToString (Request["$orderby"  ]);
			// 06/17/2013 Paul.  Add support for GROUP BY. 
			string sGROUP_BY         = Sql.ToString (Request["$groupby"  ]);
			// 08/03/2011 Paul.  We need a way to filter the columns so that we can be efficient. 
			string sSELECT           = Sql.ToString (Request["$select"   ]);
			// 09/09/2019 Paul.  Send duplicate filter info. 
			string sDUPLICATE_FIELDS = String.Empty;
			// 12/03/2019 Paul.  The React Client needs access to archive data. 
			bool   bArchiveView      = Sql.ToBoolean(Request["$archiveView"]);
			
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

			string     sExportFormat    = String.Empty;
			string     sExportRange     = String.Empty;
			List<Guid> arrSelectedItems = new List<Guid>();
			// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
			Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
			Dictionary<string, object> dictSearchValues = null;
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
							System.Collections.ArrayList arr = dict[sName] as System.Collections.ArrayList;
							if ( arr != null )
							{
								for ( int i = 0; i < arr.Count; i++ )
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
			
			// 06/17/2013 Paul.  Add support for GROUP BY. 
			// 04/21/2017 Paul.  We need to return the total when using nTOP. 
			long lTotalCount = 0;
			// 05/21/2017 Paul.  HTML5 Dashboard requires aggregates. 
			// 08/01/2019 Paul.  We need a ListView and EditView flags for the Rest Client. 
			// 09/09/2019 Paul.  Send duplicate filter info. 
			// 10/26/2019 Paul.  Return the SQL to the React Client. 
			StringBuilder sbDumpSQL = new StringBuilder();
			DataTable dt = new DataTable();
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			// 03/06/2019 Paul.  For security reasons, the OAUTH tables will never be returned. 
			if ( !Sql.IsEmptyString(ModuleName) && !sTABLE_NAME.StartsWith("OAUTH") && !sTABLE_NAME.StartsWith("USERS_PASSWORD") && !sTABLE_NAME.EndsWith("_AUDIT") && !sTABLE_NAME.EndsWith("_STREAM") )
			{
				bool bIsAdmin = Sql.ToBoolean(Application["Modules." + ModuleName + ".IsAdmin"]);
				if ( bIsAdmin && SplendidCRM.Security.AdminUserAccess(ModuleName, "access") >= 0 )
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
			DataView vwMain = new DataView(dt);
			
			// 12/14/2019 Paul.  I'm not sure why this was necessary in the ListView code, but we are going to rely upon the Security.Filter() to manage. 
			//if ( nACLACCESS == ACL_ACCESS.OWNER )
			//	vwMain.RowFilter = "ASSIGNED_USER_ID = '" + Security.USER_ID.ToString() + "'";
			int    nStartRecord        = 0;
			int    nEndRecord          = vwMain.Count;
			string sExportTempFileName = String.Empty;
			string sExportTempPathName = String.Empty;
			string sContentType        = String.Empty;
			string sTempPath           = Path.GetTempPath();
			sTempPath = Path.Combine(sTempPath, "Splendid");
			// 12/15/2019 Paul.  The Splendid folder may not exist. 
			if ( !Directory.Exists(sTempPath) )
			{
				Directory.CreateDirectory(sTempPath);
			}
			switch ( sExportFormat )
			{
				case "csv"  :
				{
					sContentType = "text/csv";
					sExportTempFileName = Guid.NewGuid().ToString() + "_" + ModuleName + ".csv";
					sExportTempPathName = Path.Combine(sTempPath, sExportTempFileName);
					HttpContext.Current.Session["TempFile." + sExportTempFileName] = sExportTempPathName;
					// 08/06/2008 yxy21969.  Make sure to encode all URLs. 
					// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
					using ( FileStream stm = File.Create(sExportTempPathName) )
					{
						SplendidExport.ExportDelimited(stm, vwMain, ModuleName, nStartRecord, nEndRecord, ',' );
					}
					break;
				}
				case "tab"  :
				{
					sContentType = "text/txt";
					sExportTempFileName = Guid.NewGuid().ToString() + "_" + ModuleName + ".txt";
					sExportTempPathName = Path.Combine(sTempPath, sExportTempFileName);
					HttpContext.Current.Session["TempFile." + sExportTempFileName] = sExportTempPathName;
					// 08/06/2008 yxy21969.  Make sure to encode all URLs. 
					// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
					using ( FileStream stm = File.Create(sExportTempPathName) )
					{
						SplendidExport.ExportDelimited(stm, vwMain, ModuleName, nStartRecord, nEndRecord, '\t');
					}
					break;
				}
				case "xml"  :
				{
					sContentType = "text/xml";
					sExportTempFileName = Guid.NewGuid().ToString() + "_" + ModuleName + ".xml";
					sExportTempPathName = Path.Combine(sTempPath, sExportTempFileName);
					HttpContext.Current.Session["TempFile." + sExportTempFileName] = sExportTempPathName;
					// 08/06/2008 yxy21969.  Make sure to encode all URLs. 
					// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
					using ( FileStream stm = File.Create(sExportTempPathName) )
					{
						SplendidExport.ExportXml(stm, vwMain, ModuleName, nStartRecord, nEndRecord);
					}
					break;
				}
				//case "Excel":
				default     :
				{
					// 08/25/2012 Paul.  Change Excel export type to use Open XML as the previous format is not supported on Office 2010. 
					sContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";  //"application/vnd.ms-excel";
					sExportTempFileName = Guid.NewGuid().ToString() + "_" + ModuleName + ".xlsx";
					sExportTempPathName = Path.Combine(sTempPath, sExportTempFileName);
					HttpContext.Current.Session["TempFile." + sExportTempFileName] = sExportTempPathName;
					// 08/25/2012 Paul.  Change Excel export type to use Open XML as the previous format is not supported on Office 2010. 
					// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
					using ( FileStream stm = File.Create(sExportTempPathName) )
					{
						SplendidExport.ExportExcelOpenXML(stm, vwMain, ModuleName, nStartRecord, nEndRecord);
					}
					break;
				}
			}
			Dictionary<string, object> dictResponse = new Dictionary<string, object>();
			Dictionary<string, object> d = new Dictionary<string, object>();
			dictResponse.Add("d", d);
#if DEBUG
			d.Add("ExportPathName", sExportTempPathName);
#endif
			d.Add("ExportFileName", sExportTempFileName);
			d.Add("ContentType"   , sContentType);

			dictResponse.Add("__total", lTotalCount);
			// 10/26/2019 Paul.  Return the SQL to the React Client. 
			if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
			{
				dictResponse.Add("__sql", sbDumpSQL.ToString());
			}
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		// 03/13/2016 Paul.  We need a special version that of the module get so that we can avoid any CRM caching. 
		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAdminTable(string TableName)
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			TableName = TableName.ToUpper();
			int    nSKIP     = Sql.ToInteger(Request.QueryString["$skip"   ]);
			int    nTOP      = Sql.ToInteger(Request.QueryString["$top"    ]);
			string sFILTER   = Sql.ToString (Request.QueryString["$filter" ]);
			string sORDER_BY = Sql.ToString (Request.QueryString["$orderby"]);
			// 06/17/2013 Paul.  Add support for GROUP BY. 
			string sGROUP_BY = Sql.ToString (Request.QueryString["$groupby"]);
			// 08/03/2011 Paul.  We need a way to filter the columns so that we can be efficient. 
			string sSELECT   = Sql.ToString (Request.QueryString["$select" ]);
			long lTotalCount = 0;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			// 10/26/2019 Paul.  Return the SQL to the React Client. 
			StringBuilder sbDumpSQL = new StringBuilder();
			DataTable dt = new DataTable();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL          = String.Empty;
				string sVIEW_NAME    = String.Empty;
				string sDEFAULT_VIEW = String.Empty;
				string sMATCH_NAME   = "DEFAULT_VIEW";
				Match match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
				if ( match.Success )
					sDEFAULT_VIEW = match.Groups[sMATCH_NAME].Value;
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				if ( TableName == "DYNAMIC_BUTTONS" && SplendidCRM.Security.AdminUserAccess("DynamicButtons", "access") >= 0 )
				{
					sMATCH_NAME = "VIEW_NAME";
					match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
					if ( match.Success )
						sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
					// 04/01/2019 Paul.  Allow Admin API to retrieve all dynamic buttons. 
					sSQL = "select *                           " + ControlChars.CrLf
					     + "  from vwDYNAMIC_BUTTONS           " + ControlChars.CrLf
					     + " where 1 = 1                       " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						if ( !Sql.IsEmptyString(sVIEW_NAME) )
							Sql.AppendParameter(cmd, sVIEW_NAME, "VIEW_NAME");
						if ( !Sql.IsEmptyString(sDEFAULT_VIEW) )
							Sql.AppendParameter(cmd, Sql.ToBoolean(sDEFAULT_VIEW), "DEFAULT_VIEW", false);
						cmd.CommandText += " order by CONTROL_INDEX            " + ControlChars.CrLf;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dt);
							lTotalCount = dt.Rows.Count;
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							string sDumbSQL = Sql.ExpandParameters(cmd);
							sbDumpSQL.Append(sDumbSQL);
						}
					}
				}
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				else if ( TableName == "EDITVIEWS_FIELDS" && SplendidCRM.Security.AdminUserAccess("DynamicLayout", "access") >= 0 )
				{
					sMATCH_NAME = "EDIT_NAME";
					match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
					if ( match.Success )
						sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
					sSQL = "select *                           " + ControlChars.CrLf
					     + "  from vwEDITVIEWS_FIELDS          " + ControlChars.CrLf
					     + " where EDIT_NAME    = @VIEW_NAME   " + ControlChars.CrLf
					     + "   and DEFAULT_VIEW = @DEFAULT_VIEW" + ControlChars.CrLf
					     + " order by FIELD_INDEX              " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@VIEW_NAME"   , sVIEW_NAME);
						Sql.AddParameter(cmd, "@DEFAULT_VIEW", Sql.ToBoolean(sDEFAULT_VIEW));
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dt);
							lTotalCount = dt.Rows.Count;
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							string sDumbSQL = Sql.ExpandParameters(cmd);
							sbDumpSQL.Append(sDumbSQL);
						}
					}
				}
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				else if ( TableName == "DETAILVIEWS_FIELDS" && SplendidCRM.Security.AdminUserAccess("DynamicLayout", "access") >= 0 )
				{
					sMATCH_NAME = "DETAIL_NAME";
					match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
					if ( match.Success )
						sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
					sSQL = "select *                           " + ControlChars.CrLf
					     + "  from vwDETAILVIEWS_FIELDS        " + ControlChars.CrLf
					     + " where DETAIL_NAME  = @VIEW_NAME   " + ControlChars.CrLf
					     + "   and DEFAULT_VIEW = @DEFAULT_VIEW" + ControlChars.CrLf
					     + " order by FIELD_INDEX              " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@VIEW_NAME"   , sVIEW_NAME);
						Sql.AddParameter(cmd, "@DEFAULT_VIEW", Sql.ToBoolean(sDEFAULT_VIEW));
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dt);
							lTotalCount = dt.Rows.Count;
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							string sDumbSQL = Sql.ExpandParameters(cmd);
							sbDumpSQL.Append(sDumbSQL);
						}
					}
				}
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				else if ( TableName == "GRIDVIEWS_COLUMNS" && SplendidCRM.Security.AdminUserAccess("DynamicLayout", "access") >= 0 )
				{
					sMATCH_NAME = "GRID_NAME";
					match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
					if ( match.Success )
						sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
					sSQL = "select *                           " + ControlChars.CrLf
					     + "  from vwGRIDVIEWS_COLUMNS         " + ControlChars.CrLf
					     + " where GRID_NAME    = @VIEW_NAME   " + ControlChars.CrLf
					     + "   and DEFAULT_VIEW = @DEFAULT_VIEW" + ControlChars.CrLf
					     + " order by COLUMN_INDEX             " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@VIEW_NAME"   , sVIEW_NAME);
						Sql.AddParameter(cmd, "@DEFAULT_VIEW", Sql.ToBoolean(sDEFAULT_VIEW));
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dt);
							lTotalCount = dt.Rows.Count;
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							string sDumbSQL = Sql.ExpandParameters(cmd);
							sbDumpSQL.Append(sDumbSQL);
						}
					}
				}
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				else if ( TableName == "EDITVIEWS" && SplendidCRM.Security.AdminUserAccess("DynamicLayout", "access") >= 0 )
				{
					sMATCH_NAME = "NAME";
					match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
					if ( match.Success )
						sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
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
							lTotalCount = dt.Rows.Count;
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							string sDumbSQL = Sql.ExpandParameters(cmd);
							sbDumpSQL.Append(sDumbSQL);
						}
					}
				}
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				else if ( TableName == "DETAILVIEWS" && SplendidCRM.Security.AdminUserAccess("DynamicLayout", "access") >= 0 )
				{
					sMATCH_NAME = "NAME";
					match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
					if ( match.Success )
						sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
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
							lTotalCount = dt.Rows.Count;
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							string sDumbSQL = Sql.ExpandParameters(cmd);
							sbDumpSQL.Append(sDumbSQL);
						}
					}
				}
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				else if ( TableName == "GRIDVIEWS" && SplendidCRM.Security.AdminUserAccess("DynamicLayout", "access") >= 0 )
				{
					sMATCH_NAME = "NAME";
					match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
					if ( match.Success )
						sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
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
							lTotalCount = dt.Rows.Count;
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							string sDumbSQL = Sql.ExpandParameters(cmd);
							sbDumpSQL.Append(sDumbSQL);
						}
					}
				}
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				else if ( TableName == "EDITVIEWS_RELATIONSHIPS" && SplendidCRM.Security.AdminUserAccess("DynamicLayout", "access") >= 0 )
				{
					sMATCH_NAME = "EDIT_NAME";
					match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
					if ( match.Success )
						sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
					sSQL = "select *                                                       " + ControlChars.CrLf
					     + "  from vwEDITVIEWS_RELATIONSHIPS_Layout                        " + ControlChars.CrLf
					     + " where EDIT_NAME    = @VIEW_NAME                               " + ControlChars.CrLf
					     + " order by RELATIONSHIP_ENABLED, RELATIONSHIP_ORDER, MODULE_NAME" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@VIEW_NAME"   , sVIEW_NAME);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dt);
							lTotalCount = dt.Rows.Count;
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							string sDumbSQL = Sql.ExpandParameters(cmd);
							sbDumpSQL.Append(sDumbSQL);
						}
					}
				}
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				else if ( TableName == "DETAILVIEWS_RELATIONSHIPS" && SplendidCRM.Security.AdminUserAccess("DynamicLayout", "access") >= 0 && SplendidCRM.Security.AdminUserAccess("DetailViewsRelationships", "access") >= 0 )
				{
					sMATCH_NAME = "DETAIL_NAME";
					match = Regex.Match(sFILTER, "\\b" + sMATCH_NAME + "\\s*(=|eq)\\s*\'(?<" + sMATCH_NAME + ">([^(\'|\\s)]*))", RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase);
					if ( match.Success )
						sVIEW_NAME = match.Groups[sMATCH_NAME].Value;
					sSQL = "select *                                                       " + ControlChars.CrLf
					     + "  from vwDETAILVIEWS_RELATIONSHIPS_La                          " + ControlChars.CrLf
					     + " where DETAIL_NAME  = @VIEW_NAME                               " + ControlChars.CrLf
					     + " order by RELATIONSHIP_ENABLED, RELATIONSHIP_ORDER, MODULE_NAME" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@VIEW_NAME"   , sVIEW_NAME);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dt);
							lTotalCount = dt.Rows.Count;
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							string sDumbSQL = Sql.ExpandParameters(cmd);
							sbDumpSQL.Append(sDumbSQL);
						}
					}
				}
				else
				{
					UniqueStringCollection arrSELECT = new UniqueStringCollection();
					sSELECT = sSELECT.Replace(" ", "");
					if ( !Sql.IsEmptyString(sSELECT) )
					{
						Regex r = new Regex(@"[^A-Za-z0-9_]");
						foreach ( string s in sSELECT.Split(',') )
						{
							string sColumnName = r.Replace(s, "");
							if ( !Sql.IsEmptyString(sColumnName) )
								arrSELECT.Add(sColumnName);
						}
					}
					// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
					string sMODULE_NAME = Sql.ToString (Application["Modules." + TableName + ".ModuleName"]);
					// 03/06/2019 Paul.  For security reasons, the OAUTH tables will never be returned. 
					if ( !Sql.IsEmptyString(sMODULE_NAME) && !TableName.StartsWith("OAUTH") && !TableName.StartsWith("USERS_PASSWORD") && !TableName.EndsWith("_AUDIT") && !TableName.EndsWith("_STREAM") )
					{
						bool bIsAdmin = Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".IsAdmin"]);
						if ( bIsAdmin && SplendidCRM.Security.AdminUserAccess(sMODULE_NAME, "access") >= 0 )
						{
							// 10/26/2019 Paul.  Return the SQL to the React Client. 
							// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs
							// 10/16/2020 Paul.  Use AccessMode.list so that we use the _List view if available. 
							dt = RestUtil.GetAdminTable(Context, TableName, nSKIP, nTOP, sFILTER, sORDER_BY, sGROUP_BY, arrSELECT, null, ref lTotalCount, null, AccessMode.list, sbDumpSQL);
						}
						else
						{
							throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
						}
					}
					else
					{
						// 01/19/2021 Paul.  If it is not a module-based table, then we need to lookup it up from the REST tables. 
						using ( DataTable dtSYNC_TABLES = SplendidCache.RestTables(TableName, false) )
						{
							if ( dtSYNC_TABLES != null && dtSYNC_TABLES.Rows.Count > 0 )
							{
								DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
								string sMODULE_NAME_PRIMARY = Sql.ToString (rowSYNC_TABLE["MODULE_NAME"        ]);
								string sMODULE_NAME_RELATED = Sql.ToString (rowSYNC_TABLE["MODULE_NAME_RELATED"]);
								bool   bIS_RELATIONSHIP     = Sql.ToBoolean(rowSYNC_TABLE["IS_RELATIONSHIP"    ]);
								if ( SplendidCRM.Security.AdminUserAccess(sMODULE_NAME_PRIMARY, "access") >= 0 )
								{
									if ( bIS_RELATIONSHIP )
									{
										if ( SplendidCRM.Security.AdminUserAccess(sMODULE_NAME_RELATED, "access") >= 0 )
										{
											dt = RestUtil.GetAdminTable(Context, TableName, nSKIP, nTOP, sFILTER, sORDER_BY, sGROUP_BY, arrSELECT, null, ref lTotalCount, null, AccessMode.list, sbDumpSQL);
										}
										else
										{
											throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
										}
									}
									else
									{
										dt = RestUtil.GetAdminTable(Context, TableName, nSKIP, nTOP, sFILTER, sORDER_BY, sGROUP_BY, arrSELECT, null, ref lTotalCount, null, AccessMode.list, sbDumpSQL);
									}
								}
								else
								{
									throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
								}
							}
							else
							{
								throw(new Exception("Unsupported table: " + TableName));
							}
						}
					}
				}
			}
			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			
			Guid     gTIMEZONE         = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n              = TimeZone.CreateTimeZone(gTIMEZONE);
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, dt, T10n);
			dictResponse.Add("__total", lTotalCount);
			// 10/26/2019 Paul.  Return the SQL to the React Client. 
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
		public Stream GetTeamTree(Guid ID)
		{
			HttpContext Context = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			// 07/17/2016 Paul.  Stop letting IIS cache the response. 
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			// 03/09/2019 Paul.  Allow admin delegate to access admin api. 
			if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			StringBuilder sbDumpSQL = new StringBuilder();
			Dictionary<string, object> d = new Dictionary<string, object>();
			try
			{
				XmlDocument xml = new XmlDocument();
				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					if ( Sql.IsSQLServer(con) )
					{
						string sSQL;
						sSQL = "select ID                          as '@ID'       " + ControlChars.CrLf
						     + "     , replace(NAME, '&', '&amp;') as '@NAME'     " + ControlChars.CrLf
						     + "     , PARENT_ID                   as '@PARENT_ID'" + ControlChars.CrLf
						     + "     , dbo.fnTEAM_HIERARCHY_ChildrenXml(ID)       " + ControlChars.CrLf
						     + "  from vwTEAMS                                    " + ControlChars.CrLf
						     + " where ID = @ID                                   " + ControlChars.CrLf
						     + " order by '@NAME'                                 " + ControlChars.CrLf
						     + "   for xml path('TEAM'), type      " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", ID);
							sbDumpSQL.Append(Sql.ExpandParameters(cmd));

							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								StringBuilder sbXML = new StringBuilder();
								// 05/20/2016 Paul.  Do not select single row as it will return an incomplete XML. 
								using ( IDataReader rdr = cmd.ExecuteReader() )
								{
									while ( rdr.Read() )
									{
										sbXML.Append(Sql.ToString(rdr[0]));
									}
								}
								string sXML = sbXML.ToString();
								if ( !Sql.IsEmptyString(sXML) )
								{
									xml.LoadXml(sXML);
								}
							}
						}
					}
					// 05/20/2016 Paul.  Oracle supports hierarchical queries. 
					// http://docs.oracle.com/cd/E11882_01/server.112/e41084/queries003.htm#SQLRF52335
					else if ( Sql.IsOracle(con) )
					{
						string sSQL;
						sSQL = "select ID, NAME, PARENT_ID      " + ControlChars.CrLf
						     + "  from vwTEAMS                  " + ControlChars.CrLf
						     + " start with ID = @ID            " + ControlChars.CrLf
						     + " connect by prior ID = PARENT_ID" + ControlChars.CrLf
						     + " order siblings by NAME         " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", ID);
							sbDumpSQL.Append(Sql.ExpandParameters(cmd));

							xml.AppendChild(xml.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
							xml.AppendChild(xml.CreateElement("xml"));
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( IDataReader rdr = cmd.ExecuteReader() )
								{
									while ( rdr.Read() )
									{
										Guid   gTEAM_ID   = Sql.ToGuid  (rdr["ID"       ]);
										string sNAME      = Sql.ToString(rdr["NAME"     ]);
										Guid   gPARENT_ID = Sql.ToGuid  (rdr["PARENT_ID"]);
										// 05/20/2016 Paul.  The leading // means to search all child nodes. 
										XmlNode xPARENT_ID = xml.DocumentElement.SelectSingleNode("//TEAM[@ID='" + gPARENT_ID.ToString() + "']");
										if ( xPARENT_ID == null )
										{
											XmlNode xTEAM = xml.CreateElement("TEAM");
											xml.DocumentElement.AppendChild(xTEAM);
											XmlAttribute attrID = xml.CreateAttribute("ID");
											attrID.Value = gTEAM_ID.ToString();
											xTEAM.Attributes.SetNamedItem(attrID);
											XmlAttribute attrNAME = xml.CreateAttribute("NAME");
											attrNAME.Value = sNAME;
											xTEAM.Attributes.SetNamedItem(attrNAME);
										}
										else
										{
											XmlNode xTEAM = xml.CreateElement("TEAM");
											xPARENT_ID.AppendChild(xTEAM);
											XmlAttribute attrID = xml.CreateAttribute("ID");
											attrID.Value = gTEAM_ID.ToString();
											xTEAM.Attributes.SetNamedItem(attrID);
											XmlAttribute attrNAME = xml.CreateAttribute("NAME");
											attrNAME.Value = sNAME;
											xTEAM.Attributes.SetNamedItem(attrNAME);
											XmlAttribute attrPARENT_ID = xml.CreateAttribute("PARENT_ID");
											attrPARENT_ID.Value = gPARENT_ID.ToString();
											xTEAM.Attributes.SetNamedItem(attrPARENT_ID);
										}
									}
								}
							}
						}
					}
					//XmlNodeList nlTeams = xml.DocumentElement.ChildNodes;
					//foreach ( XmlNode xTEAM in nlTeams )
					//{
						SplendidCache.ReactTeam team = new SplendidCache.ReactTeam();
						team.ProcessNodes(xml.DocumentElement);
						d.Add("d", team);
						//lstTeams.Add(team);
					//}
				}
				if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
				{
					d.Add("__sql", sbDumpSQL.ToString());
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
			return RestUtil.ToJsonStream(d);
		}
		
		// 10/26/2019 Paul.  Return the SQL to the React Client. 
		// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetModuleItem(string ModuleName, Guid ID)
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;

			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			// 03/09/2019 Paul.  Allow admin delegate to access admin api. 
			if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sTABLE_NAME = Sql.ToString(Application["Modules." + ModuleName + ".TableName"]);
			// 02/02/2021 Paul.  Special table name for EditCustomFields. 
			if ( ModuleName == "EditCustomFields" )
				sTABLE_NAME = "FIELDS_META_DATA";
			// 06/06/2021 Paul.  BusinessRules is based off of RULES table, but that is also used by RulesWizard and ReportRules. 
			else if ( ModuleName == "BusinessRules" )
				sTABLE_NAME = "vwBUSINESS_RULES";
			if ( !Sql.IsEmptyString(ModuleName) && !sTABLE_NAME.StartsWith("OAUTH") && !sTABLE_NAME.StartsWith("USERS_PASSWORD") && !sTABLE_NAME.EndsWith("_AUDIT") && !sTABLE_NAME.EndsWith("_STREAM") )
			{
				bool bIsAdmin = Sql.ToBoolean(Application["Modules." + ModuleName + ".IsAdmin"]);
				if ( bIsAdmin && SplendidCRM.Security.AdminUserAccess(ModuleName, "access") >= 0 )
				{
					Guid[] arrITEMS = new Guid[1] { ID };
					long lTotalCount = 0;
					// 10/26/2019 Paul.  Return the SQL to the React Client. 
					StringBuilder sbDumpSQL = new StringBuilder();
					// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs
					// 10/16/2020 Paul.  Use AccessMode.list so that we use the _List view if available. 
					DataTable dt = RestUtil.GetAdminTable(Context, sTABLE_NAME, 0, 1, String.Empty, String.Empty, String.Empty, null, arrITEMS, ref lTotalCount, null, AccessMode.edit, sbDumpSQL);
					if ( dt == null || dt.Rows.Count == 0 )
						throw(new Exception("Item not found: " + ModuleName + " " + ID.ToString()));
			
					string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
					JavaScriptSerializer json = new JavaScriptSerializer();
					json.MaxJsonLength = int.MaxValue;
			
					Guid     gTIMEZONE         = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
					TimeZone T10n              = TimeZone.CreateTimeZone(gTIMEZONE);
					// 04/01/2020 Paul.  Move json utils to RestUtil. 
					Dictionary<string, object> dict = RestUtil.ToJson(sBaseURI, ModuleName, dt.Rows[0], T10n);
					
					if ( sTABLE_NAME == "WORKFLOW_ALERT_TEMPLATES")
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							Dictionary<string, object> d       = dict["d"] as Dictionary<string, object>;
							Dictionary<string, object> results = d["results"] as Dictionary<string, object>;
							try
							{
								string sSQL = String.Empty;
								sSQL = "select *                                     " + ControlChars.CrLf
								     + "  from vwEMAIL_TEMPLATES_Attachments         " + ControlChars.CrLf
								     + " where EMAIL_TEMPLATE_ID = @EMAIL_TEMPLATE_ID" + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@EMAIL_TEMPLATE_ID", ID);
									sbDumpSQL.Append(";" + ControlChars.CrLf + Sql.ExpandParameters(cmd));
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										using ( DataTable dtSubPanel = new DataTable() )
										{
											da.Fill(dtSubPanel);
											results.Add("ATTACHMENTS", RestUtil.RowsToDictionary(sBaseURI, "vwEMAIL_TEMPLATES_Attachments", dtSubPanel, T10n));
										}
									}
								}
							}
							catch(Exception ex)
							{
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							}
						}
					}
					
					// 10/26/2019 Paul.  Return the SQL to the React Client. 
					if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
					{
						dict.Add("__sql", sbDumpSQL.ToString());
					}
					string sResponse = json.Serialize(dict);
					byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
					return new MemoryStream(byResponse);
				}
				else
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
			}
			else
			{
				throw(new Exception("Unsupported table: " + sTABLE_NAME));
			}
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream CheckVersion(string CHECK_UPDATES)
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			DataTable dt = Utils.CheckVersion(Context.Application);
			DataView vwMain = dt.DefaultView;
			vwMain.Sort      = "Build desc";
			if ( Sql.ToBoolean(CHECK_UPDATES) && vwMain.Count > 0 )
			{
				Application["available_version"            ] = Sql.ToString(vwMain[0]["Build"      ]);
				Application["available_version_description"] = Sql.ToString(vwMain[0]["Description"]);
			}
			else
			{
				Application.Remove("available_version"            );
				Application.Remove("available_version_description");
			}
			vwMain.RowFilter = "New = '1'";
			long lTotalCount = vwMain.Count;

			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			
			Guid     gTIMEZONE         = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n              = TimeZone.CreateTimeZone(gTIMEZONE);
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, vwMain, T10n);
			dictResponse.Add("__total", lTotalCount);
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}
		#endregion

		#region Admin Menu
		public class AdminModule
		{
			public string MODULE_NAME ;
			public string DISPLAY_NAME;
			public string DESCRIPTION ;
			public string EDIT_LABEL  ;
			public bool   MENU_ENABLED;
			public int    TAB_ORDER   ;
			public string ADMIN_ROUTE ;
			public string ICON_NAME   ;

			public AdminModule(L10N L10n, string sMODULE_NAME, string sDISPLAY_NAME, string sDESCRIPTION, int nDEFAULT_TAB_ORDER, Dictionary<string, int> dictModuleTabOrder, string sEDIT_LABEL, string sICON_NAME)
			{
				this.MODULE_NAME  = sMODULE_NAME ;
				if ( !Sql.IsEmptyString(this.MODULE_NAME) )
				{
					this.DISPLAY_NAME = (!Sql.IsEmptyString(sDISPLAY_NAME) ? sDISPLAY_NAME : sMODULE_NAME + ".LBL_MANAGE_" + sMODULE_NAME.ToUpper() + "_TITLE");
					this.DESCRIPTION  = (!Sql.IsEmptyString(sDESCRIPTION ) ? sDESCRIPTION  : sMODULE_NAME + ".LBL_MANAGE_" + sMODULE_NAME.ToUpper()           );
					this.EDIT_LABEL   = (!Sql.IsEmptyString(sEDIT_LABEL  ) ? sEDIT_LABEL   : sMODULE_NAME + ".LBL_NEW_FORM_TITLE"                             );
					this.MENU_ENABLED = true;
					if ( dictModuleTabOrder.ContainsKey(sMODULE_NAME) )
						this.TAB_ORDER = dictModuleTabOrder[sMODULE_NAME];
					if ( this.TAB_ORDER == 0 )
						this.TAB_ORDER = nDEFAULT_TAB_ORDER;
					this.ICON_NAME    = sICON_NAME   ;
				}
			}

			public AdminModule(L10N L10n, string sMODULE_NAME, string sDISPLAY_NAME, string sDESCRIPTION, int nDEFAULT_TAB_ORDER, Dictionary<string, int> dictModuleTabOrder, string sEDIT_LABEL)
			{
				this.MODULE_NAME  = sMODULE_NAME ;
				if ( !Sql.IsEmptyString(this.MODULE_NAME) )
				{
					this.DISPLAY_NAME = (!Sql.IsEmptyString(sDISPLAY_NAME) ? sDISPLAY_NAME : sMODULE_NAME + ".LBL_MANAGE_" + sMODULE_NAME.ToUpper() + "_TITLE");
					this.DESCRIPTION  = (!Sql.IsEmptyString(sDESCRIPTION ) ? sDESCRIPTION  : sMODULE_NAME + ".LBL_MANAGE_" + sMODULE_NAME.ToUpper()           );
					this.EDIT_LABEL   = (!Sql.IsEmptyString(sEDIT_LABEL  ) ? sEDIT_LABEL   : sMODULE_NAME + ".LBL_NEW_FORM_TITLE"                             );
					this.MENU_ENABLED = true;
					if ( dictModuleTabOrder.ContainsKey(sMODULE_NAME) )
						this.TAB_ORDER = dictModuleTabOrder[sMODULE_NAME];
					if ( this.TAB_ORDER == 0 )
						this.TAB_ORDER = nDEFAULT_TAB_ORDER;
					this.ICON_NAME    = sMODULE_NAME + ".gif";
				}
			}

			public AdminModule(L10N L10n, string sMODULE_NAME, string sDISPLAY_NAME, string sDESCRIPTION, string sADMIN_ROUTE, string sICON_NAME)
			{
				this.MODULE_NAME  = sMODULE_NAME ;
				if ( !Sql.IsEmptyString(this.MODULE_NAME) )
				{
					this.DISPLAY_NAME = (!Sql.IsEmptyString(sDISPLAY_NAME) ? sDISPLAY_NAME : sMODULE_NAME + ".LBL_MANAGE_" + sMODULE_NAME.ToUpper() + "_TITLE");
					this.DESCRIPTION  = (!Sql.IsEmptyString(sDESCRIPTION ) ? sDESCRIPTION  : sMODULE_NAME + ".LBL_MANAGE_" + sMODULE_NAME.ToUpper()           );
					this.MENU_ENABLED = false;
					this.ADMIN_ROUTE  = sADMIN_ROUTE ;
					this.ICON_NAME    = sICON_NAME   ;
				}
			}

			public AdminModule(L10N L10n, string sMODULE_NAME, string sDISPLAY_NAME, string sDESCRIPTION, string sADMIN_ROUTE)
			{
				this.MODULE_NAME  = sMODULE_NAME ;
				if ( !Sql.IsEmptyString(this.MODULE_NAME) )
				{
					this.DISPLAY_NAME = (!Sql.IsEmptyString(sDISPLAY_NAME) ? sDISPLAY_NAME : sMODULE_NAME + ".LBL_MANAGE_" + sMODULE_NAME.ToUpper() + "_TITLE");
					this.DESCRIPTION  = (!Sql.IsEmptyString(sDESCRIPTION ) ? sDESCRIPTION  : sMODULE_NAME + ".LBL_MANAGE_" + sMODULE_NAME.ToUpper()           );
					this.MENU_ENABLED = false;
					this.ADMIN_ROUTE  = sADMIN_ROUTE ;
					this.ICON_NAME    = sMODULE_NAME + ".gif";
				}
			}
		}

		// 04/01/2020 Paul.  Move json utils to RestUtil. 

		private List<Dictionary<string, object>> GetAdminMenu(Dictionary<string, int> dictModuleTabOrder)
		{
			HttpContext          Context     = HttpContext.Current            ;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			L10N L10n = new L10N(Sql.ToString(Context.Session["USER_SETTINGS/CULTURE"]));
			List<Dictionary<string, object>> objs    = new List<Dictionary<string, object>>();
			try
			{
				// 08/16/2021 Paul.  Use DetailViewRelationships so that the panels can be reordered or hidden. 
				DataTable dtFields = SplendidCache.DetailViewRelationships("Administration.ListView");
				foreach(DataRow row in dtFields.Rows)
				{
					// 12/03/2009 Paul.  The Title is used for the tabbed subpanels. 
					string sCONTROL_NAME = Sql.ToString(row["CONTROL_NAME"]);
					string sTITLE        = Sql.ToString(row["TITLE"       ]);
					switch ( sCONTROL_NAME )
					{
						case "NetworkView":
						{
							// NetworkView
							AdminModule[] arrNetworkView = new AdminModule[]
							{ new AdminModule(L10n, "Config"                , "Administration.LBL_SPLENDIDCRM_UPDATE_TITLE"      , "Administration.LBL_SPLENDIDCRM_UPDATE"     , "Updater"               , "sugarupdate.gif"                           )
							, new AdminModule(L10n, "Config"                , "Administration.LBL_DOCUMENTATION_TITLE"           , "Administration.LBL_DOCUMENTATION"          , "Documentation"         , "OnlineDocumentation.gif"                   )
							};
							BuildAdminModules(L10n, objs, "NetworkView", "Administration.LBL_SPLENDIDCRM_NETWORK_TITLE", arrNetworkView);
							break;
						}
						case "SystemView":
						{
							// SystemView
							AdminModule[] arrSystemView = new AdminModule[]
							{ new AdminModule(L10n, "Config"                , "Administration.LBL_CONFIGURE_SETTINGS_TITLE"      , "Administration.LBL_CONFIGURE_SETTINGS"      , 10, dictModuleTabOrder , "Config.LNK_NEW_CONFIG"                     )
							, new AdminModule(L10n, "SystemCheck"           , "Administration.LBL_SYSTEM_CHECK_TITLE"            , "Administration.LBL_SYSTEM_CHECK"            , "SystemCheck"          )
							, new AdminModule(L10n, "Currencies"            , "Administration.LBL_MANAGE_CURRENCIES"             , "Administration.LBL_CURRENCY"                , 12, dictModuleTabOrder , "Currencies.LNK_NEW_CURRENCY"               )
							// 12/11/2019 Paul.  SystemLog has a custom list view. 
							, new AdminModule(L10n, "SystemLog"             , "Administration.LBL_SYSTEM_LOG_TITLE"              , "Administration.LBL_SYSTEM_LOG"              , "List"                 )
							, new AdminModule(L10n, "Import"                , "Administration.LBL_IMPORT_DATABASE_TITLE"         , "Administration.LBL_IMPORT_DATABASE"         , "ImportDatabase"       )
							, new AdminModule(L10n, "Import"                , "Administration.LBL_EXPORT_DATABASE_TITLE"         , "Administration.LBL_EXPORT_DATABASE"         , "ExportDatabase"       )
							, new AdminModule(L10n, "Schedulers"            , "Administration.LBL_SUGAR_SCHEDULER_TITLE"         , "Administration.LBL_SUGAR_SCHEDULER"         , "List"                 )
							, new AdminModule(L10n, "Config"                , "Administration.LBL_BACKUPS_TITLE"                 , "Administration.LBL_BACKUPS"                 , "BackupDatabase"       , "Backups.gif")
							, new AdminModule(L10n, "PaymentGateway"        , "Administration.LBL_PAYMENT_GATEWAY_TITLE"         , "Administration.LBL_PAYMENT_GATEWAY"         , 15, dictModuleTabOrder , "PaymentGateway.LNK_NEW_PAYMENT_GATEWAY"    )
							, new AdminModule(L10n, "Config"                , "Administration.LBL_BUSINESS_MODE_TITLE"           , "Administration.LBL_BUSINESS_MODE"           , "BusinessMode"         )
							, new AdminModule(L10n, "Administration"        , "Administration.LBL_CONFIGURATOR_TITLE"            , "Administration.LBL_CONFIGURATOR"            , "Configurator"         , "Administration.gif")
							, new AdminModule(L10n, "Undelete"              , "Administration.LBL_UNDELETE_TITLE"                , "Administration.LBL_UNDELETE"                , "AdminUndeleteListView")
							, new AdminModule(L10n, "ZipCodes"              , "Administration.LBL_ZIPCODES_TITLE"                , "Administration.LBL_ZIPCODES"                , 16, dictModuleTabOrder , "ZipCodes.LNK_NEW_ZIPCODE"                  , "Administration.gif")
							, new AdminModule(L10n, "NAICSCodes"            , "Administration.LBL_MANAGE_NAICS_CODES_TITLE"      , "Administration.LBL_MANAGE_NAICS_CODES"      , 17, dictModuleTabOrder , "NAICSCodes.LNK_NEW_NAICS_CODE"             , "Administration.gif")
							, new AdminModule(L10n, "ModulesArchiveRules"   , "Administration.LBL_MODULE_ARCHIVE_RULES_TITLE"    , "Administration.LBL_MODULE_ARCHIVE_RULES"    , 18, dictModuleTabOrder , "ModulesArchiveRules.LNK_NEW_ARCHIVE_RULE"  , "Backups.gif")
							};
							BuildAdminModules(L10n, objs, "SystemView", "Administration.LBL_ADMINISTRATION_HOME_TITLE", arrSystemView);
							break;
						}
						case "UsersView":
						{
							AdminModule[] arrUsersView = new AdminModule[]
							{ new AdminModule(L10n, "Users"                 , "Administration.LBL_MANAGE_USERS_TITLE"            , "Administration.LBL_MANAGE_USERS"            ,  1, dictModuleTabOrder , "Users.LNK_NEW_USER"                        )
							, new AdminModule(L10n, "ACLRoles"              , "Administration.LBL_MANAGE_ROLES_TITLE"            , "Administration.LBL_MANAGE_ROLES"            ,  3, dictModuleTabOrder , "ACLRoles.LBL_CREATE_ROLE"                  )
							, new AdminModule(L10n, "UserLogins"            , "Administration.LBL_USERS_LOGINS_TITLE"            , "Administration.LBL_USERS_LOGINS"            , "List"                 )
							, new AdminModule(L10n, "Teams"                 , "Administration.LBL_TEAMS_TITLE"                   , "Administration.LBL_TEAMS_DESC"              ,  2, dictModuleTabOrder , "Teams.LNK_NEW_TEAM"                        )
							, new AdminModule(L10n, "AuditEvents"           , "Administration.LBL_AUDIT_EVENTS_TITLE"            , "Administration.LBL_AUDIT_EVENTS"            , "ReadOnlyListView"     , "UserLogins.gif")
							, new AdminModule(L10n, "Config"                , "Administration.LBL_MANAGE_PASSWORD_TITLE"         , "Administration.LBL_MANAGE_PASSWORD"         , "PasswordManager"      )
							};
							BuildAdminModules(L10n, objs, "UserView", "Administration.LBL_USERS_TITLE", arrUsersView);
							break;
						}
						case "StudioView":
						{
							AdminModule[] arrStudioView = new AdminModule[]
							{ new AdminModule(L10n, "DynamicLayout"         , "Administration.LBL_MANAGE_LAYOUT"                 , "Administration.LBL_MANAGE_LAYOUT"           , "AdminDynamicLayout"   , "Layout.gif")
							, new AdminModule(L10n, "Dropdown"              , "Administration.LBL_DROPDOWN_EDITOR"               , "Administration.DESC_DROPDOWN_EDITOR"        , "List"                 )
							, new AdminModule(L10n, "EditCustomFields"      , "Administration.LBL_EDIT_CUSTOM_FIELDS"            , "Administration.DESC_EDIT_CUSTOM_FIELDS"     , "List"                 )
							// 02/22/2022 Paul.  ConfigureTabs modifies the Modules table. 
							, new AdminModule(L10n, "Modules"               , "Administration.LBL_CONFIGURE_TABS"                , "Administration.LBL_CHOOSE_WHICH"            , "ConfigureTabs"        , "ConfigureTabs.gif"                         )
							, new AdminModule(L10n, "Terminology"           , "Administration.LBL_RENAME_TABS"                   , "Administration.LBL_CHANGE_NAME_TABS"        , "RenameTabs"           , "RenameTabs.gif"                            )
							, new AdminModule(L10n, "iFrames"               , "Administration.LBL_IFRAME"                        , "Administration.DESC_IFRAME"                 , 22, dictModuleTabOrder , "iFrames.LBL_ADD_SITE"                      )
							, new AdminModule(L10n, "Terminology"           , "Administration.LBL_MANAGE_TERMINOLOGY_TITLE"      , "Administration.LBL_MANAGE_TERMINOLOGY"      , 23, dictModuleTabOrder , String.Empty                                )
							, new AdminModule(L10n, "Modules"               , "Administration.LBL_MODULES_TITLE"                 , "Administration.LBL_MODULES"                 , "List"                 , "Administration.gif"                        )
							, new AdminModule(L10n, "Shortcuts"             , "Administration.LBL_MANAGE_SHORTCUTS_TITLE"        , "Administration.LBL_MANAGE_SHORTCUTS"        , 25, dictModuleTabOrder , "Shortcuts.LNK_NEW_SHORTCUT"                )
							, new AdminModule(L10n, "Languages"             , "Administration.LBL_MANAGE_LANGUAGES"              , "Administration.LBL_MANAGE_LANGUAGES"        , "List"                 , "LanguagePacks.gif"                         )
							, new AdminModule(L10n, "DynamicButtons"        , "Administration.LBL_MANAGE_DYNAMIC_BUTTONS_TITLE"  , "Administration.LBL_MANAGE_DYNAMIC_BUTTONS"  , 26, dictModuleTabOrder , "DynamicButtons.LNK_NEW_DYNAMIC_BUTTON"     )
							, new AdminModule(L10n, "Terminology"           , "Administration.LBL_IMPORT_TERMINOLOGY_TITLE"      , "Administration.LBL_IMPORT_TERMINOLOGY_TITLE", "TerminologyImport"    , "Terminology.gif"                           )
							, new AdminModule(L10n, "FieldValidators"       , "Administration.LBL_MANAGE_FIELD_VALIDATORS_TITLE" , "Administration.LBL_MANAGE_FIELD_VALIDATORS" , 27, dictModuleTabOrder , "FieldValidators.LNK_NEW_FIELD_VALIDATOR"   , "Administration.gif")
							, new AdminModule(L10n, "Tags"                  , "Administration.LBL_MANAGE_TAGS_TITLE"             , "Administration.LBL_MANAGE_TAGS"             , 28, dictModuleTabOrder , "Tags.LNK_NEW_TAG"                          , "Tags.png")
							, new AdminModule(L10n, "FullTextSearch"        , "FullTextSearch.LBL_MANAGE_FULLTEXT_SEARCH_TITLE"  , "FullTextSearch.LBL_MANAGE_FULLTEXT_SEARCH"  , "ConfigView"           , "Administration.gif"                        )
							// 11/17/2021 Paul.  Add support for module builder. 
							, new AdminModule(L10n, "ModuleBuilder"         , "Administration.LBL_MODULE_BUILDER_TITLE"          , "Administration.LBL_MODULE_BUILDER"          , "EditView"             , "Administration.gif"                        )
							};
							BuildAdminModules(L10n, objs, "StudioView", "Administration.LBL_STUDIO_TITLE", arrStudioView);
							break;
						}
						case "ProductsView":
						{
							AdminModule[] arrProductsView = new AdminModule[]
							{ new AdminModule(L10n, "ProductTemplates"      , "Administration.LBL_PRODUCT_TEMPLATES_TITLE"       , "Administration.LBL_PRODUCT_TEMPLATES_DESC"  , 30, dictModuleTabOrder , "ProductTemplates.LNK_NEW_PRODUCT_TEMPLATE" )
							, new AdminModule(L10n, "Manufacturers"         , "Administration.LBL_MANUFACTURERS_TITLE"           , "Administration.LBL_MANUFACTURERS_DESC"      , 31, dictModuleTabOrder , "Manufacturers.LNK_NEW_MANUFACTURER"        )
							, new AdminModule(L10n, "ProductCategories"     , "Administration.LBL_PRODUCT_CATEGORIES_TITLE"      , "Administration.LBL_PRODUCT_CATEGORIES_DESC" , 32, dictModuleTabOrder , "ProductCategories.LNK_NEW_PRODUCT_CATEGORY")
							, new AdminModule(L10n, "Shippers"              , "Administration.LBL_SHIPPERS_TITLE"                , "Administration.LBL_SHIPPERS_DESC"           , 33, dictModuleTabOrder , "Shippers.LNK_NEW_SHIPPER"                  )
							, new AdminModule(L10n, "ProductTypes"          , "Administration.LBL_PRODUCT_TYPES_TITLE"           , "Administration.LBL_PRODUCT_TYPES_DESC"      , 34, dictModuleTabOrder , "ProductTypes.LNK_NEW_PRODUCT_TYPE"         )
							, new AdminModule(L10n, "TaxRates"              , "Administration.LBL_TAX_RATES_TITLE"               , "Administration.LBL_TAX_RATES_DESC"          , 35, dictModuleTabOrder , "TaxRates.LNK_NEW_TAX_RATE"                 )
							, new AdminModule(L10n, "Discounts"             , "Administration.LBL_DISCOUNTS_TITLE"               , "Administration.LBL_DISCOUNTS_DESC"          , 36, dictModuleTabOrder , "Discounts.LNK_NEW_DISCOUNT"                )
							, new AdminModule(L10n, "Regions"               , "Administration.LBL_REGIONS_TITLE"                 , "Administration.LBL_REGIONS_DESC"            , 37, dictModuleTabOrder , "Regions.LNK_NEW_REGION"                    )
							, new AdminModule(L10n, "PaymentTypes"          , "Administration.LBL_PAYMENT_TYPES_TITLE"           , "Administration.LBL_PAYMENT_TYPES_DESC"      , 38, dictModuleTabOrder , "PaymentTypes.LNK_NEW_PAYMENT_TYPE"         , "ProductTypes.gif")
							, new AdminModule(L10n, "PaymentTerms"          , "Administration.LBL_PAYMENT_TERMS_TITLE"           , "Administration.LBL_PAYMENT_TERMS_DESC"      , 39, dictModuleTabOrder , "PaymentTerms.LNK_NEW_PAYMENT_TERM"         , "ProductTypes.gif")
							};
							BuildAdminModules(L10n, objs, "ProductsView", "Administration.LBL_PRODUCTS_QUOTES_TITLE", arrProductsView);
							break;
						}
						case "EmailsView":
						{
							AdminModule[] arrEmailsView = new AdminModule[]
							{ new AdminModule(L10n, "EmailMan"              , "Administration.LBL_MASS_EMAIL_CONFIG_TITLE"       , "Administration.LBL_MASS_EMAIL_CONFIG_DESC"  , "ConfigView"           )
							, new AdminModule(L10n, "EmailMan"              , "Administration.LBL_MASS_EMAIL_MANAGER_TITLE"      , "Administration.LBL_MASS_EMAIL_MANAGER_DESC" , "List"                 )
							, new AdminModule(L10n, "InboundEmail"          , "Administration.LBL_INBOUND_EMAIL_TITLE"           , "Administration.LBL_MAILBOX_DESC"            , 40, dictModuleTabOrder , "InboundEmail.LNK_LIST_CREATE_NEW"          )
							, new AdminModule(L10n, "EmailMan"              , "Administration.LBL_CAMPAIGN_EMAIL_TITLE"          , "Administration.LBL_CAMPAIGN_EMAIL_DESC"     , "AdminCampaignEditView", "Campaigns.gif")
							, new AdminModule(L10n, "OutboundEmail"         , "Administration.LBL_OUTBOUND_EMAIL_TITLE"          , "Administration.LBL_OUTBOUND_EMAIL_DESC"     , 41, dictModuleTabOrder , "OutboundEmail.LNK_NEW_OUTBOUND_EMAIL"      , "InboundEmail.gif")
							};
							BuildAdminModules(L10n, objs, "EmailsView", "Administration.LBL_EMAIL_TITLE", arrEmailsView);
							break;
						}
						case "BugsView":
						{
							AdminModule[] arrBugsView = new AdminModule[]
							{ new AdminModule(L10n, "Releases"              , "Administration.LBL_MANAGE_RELEASES"               , "Administration.LBL_RELEASE"                 , 50, dictModuleTabOrder , "Releases.LNK_NEW_RELEASE"                  )
							, new AdminModule(L10n, "NumberSequences"       , "Administration.LBL_NUMBER_SEQUENCES"              , "Administration.LBL_MANAGE_NUMBER_SEQUENCES" , "List"                 , "Releases.gif")
							};
							BuildAdminModules(L10n, objs, "BugsView", "Administration.LBL_BUG_TITLE", arrBugsView);
							break;
						}
						case "ContractsView":
						{
							AdminModule[] arrContractsView = new AdminModule[]
							{ new AdminModule(L10n, "ContractTypes"         , "Administration.LBL_CONTRACT_TYPES_TITLE"          , "Administration.LBL_CONTRACT_TYPES_DESC"     , 60, dictModuleTabOrder , "ContractTypes.LNK_NEW_CONTRACT_TYPE"       , "Contracts.gif")
							};
							BuildAdminModules(L10n, objs, "ContractsView", "Administration.LBL_CONTRACTS_TITLE", arrContractsView);
							break;
						}
						case "ForumsView":
						{
							AdminModule[] arrForumsView = new AdminModule[]
							{ new AdminModule(L10n, "ForumTopics"           , "Administration.LBL_FORUM_TOPICS"                  , "Administration.LBL_FORUM_TOPICS_DESC"       , 70, dictModuleTabOrder , "Forums.LNK_NEW_FORUM"                      )
							};
							BuildAdminModules(L10n, objs, "ForumsView", "Administration.LBL_FORUM_TOPICS_TITLE", arrForumsView);
							break;
						}
						case "WorkflowView":
						{
							AdminModule[] arrWorkflowView = new AdminModule[]
							{ new AdminModule(L10n, "Workflows"             , "Administration.LBL_MANAGE_WORKFLOW_TITLE"          , "Administration.LBL_MANAGE_WORKFLOW"          , 80, dictModuleTabOrder , "Workflows.LNK_NEW_WORKFLOW"                , "Workflow.gif")
							, new AdminModule(L10n, "WorkflowEventLog"      , "Administration.LBL_WORKFLOW_EVENT_LOG_TITLE"       , "Administration.LBL_WORKFLOW_EVENT_LOG"       , "List"                 )
							, new AdminModule(L10n, "BusinessRules"         , "BusinessRules.LBL_BUSINESS_RULES_TITLE"            , "BusinessRules.LBL_BUSINESS_RULES"            , 83, dictModuleTabOrder , "BusinessRules.LBL_CREATE_BUTTON_LABEL"     , "Rules.gif")
							, new AdminModule(L10n, "WorkflowAlertTemplates", "Administration.LBL_WORKFLOW_ALERT_TEMPLATES_TITLE" , "Administration.LBL_WORKFLOW_ALERT_TEMPLATES" , 82, dictModuleTabOrder , "Workflows.LNK_NEW_ALERT_TEMPLATE"          , "AlertEmailTemplates.gif")
							, new AdminModule(L10n, "BusinessProcesses"     , "Administration.LBL_MANAGE_BUSINESS_PROCESSES_TITLE", "Administration.LBL_MANAGE_BUSINESS_PROCESSES", 84, dictModuleTabOrder , "BusinessProcesses.LNK_NEW_BUSINESS_PROCESS")
							, new AdminModule(L10n, "BusinessProcessesLog"  , "Administration.LBL_BUSINESS_PROCESS_LOG_TITLE"     , "Administration.LBL_BUSINESS_PROCESS_LOG"     , "List"                 )
							, new AdminModule(L10n, "MachineLearningModels" , "Administration.LBL_MACHINE_LEARNING_MODELS_TITLE"  , "Administration.LBL_MACHINE_LEARNING_MODELS"  , 85, dictModuleTabOrder , "MachineLearningModels.LNK_NEW_MACHINE_LEARNING_MODEL", "MachineLearningModels.png")
							};
							// 06/29/2020 Paul.  Community and Professional will not define Administration.LBL_WORKFLOW_TITLE. 
							if ( L10n.Term("Administration.LBL_WORKFLOW_TITLE") == "Administration.LBL_WORKFLOW_TITLE" )
								BuildAdminModules(L10n, objs, "WorkflowView", "BusinessRules.LBL_BUSINESS_RULES_TITLE", arrWorkflowView);
							else
								BuildAdminModules(L10n, objs, "WorkflowView", "Administration.LBL_WORKFLOW_TITLE", arrWorkflowView);
							break;
						}
						case "AmazonView":
						{
							AdminModule[] arrAmazonView = new AdminModule[]
							{ new AdminModule(L10n, "SimpleStorage"         , "Administration.LBL_AMAZON_S3"                     , "Administration.LBL_AMAZON_S3_DESC"          , "ConfigView"           )
							, new AdminModule(L10n, "SimpleEmail"           , "Administration.LBL_AMAZON_SIMPLE_EMAIL"           , "Administration.LBL_AMAZON_SIMPLE_EMAIL_DESC", "ConfigView"           )
							};
							BuildAdminModules(L10n, objs, "AmazonView", "Administration.LBL_AMAZON_WEB_SERVICES_TITLE", arrAmazonView);
							break;
						}
						case "ExchangeView":
						{
							AdminModule[] arrExchangeView = new AdminModule[]
							{ new AdminModule(L10n, "Exchange"              , "Exchange.LBL_EXCHANGE_USERS"                      , "Exchange.LBL_EXCHANGE_USERS_DESC"           , "List"                 , "Exchange.gif")
							, new AdminModule(L10n, "Exchange"              , "Exchange.LBL_EXCHANGE_SETTINGS"                   , "Exchange.LBL_EXCHANGE_SETTINGS_DESC"        , "ConfigView"           )
							, new AdminModule(L10n, "SystemSyncLog"         , "Exchange.LBL_SYSTEM_SYNC_LOG"                     , "Exchange.LBL_SYSTEM_SYNC_LOG_DESC"          , "List"                 , "SystemLog.gif")
							};
							BuildAdminModules(L10n, objs, "ExchangeView", "Exchange.LBL_EXCHANGE_TITLE", arrExchangeView);
							break;
						}
						case "CloudView":
						{
							AdminModule[] arrCloudView = new AdminModule[]
							{ new AdminModule(L10n, "Facebook"              , "Facebook.LBL_MANAGE_FACEBOOK_TITLE"               , "Facebook.LBL_MANAGE_FACEBOOK"               , "ConfigView"           )
							, new AdminModule(L10n, "Google"                , "Google.LBL_MANAGE_GOOGLE_TITLE"                   , "Google.LBL_MANAGE_GOOGLE"                   , "ConfigView"           )
							, new AdminModule(L10n, "LinkedIn"              , "LinkedIn.LBL_MANAGE_LINKEDIN_TITLE"               , "LinkedIn.LBL_MANAGE_LINKEDIN"               , "ConfigView"           )
							, new AdminModule(L10n, "Twitter"               , "Twitter.LBL_MANAGE_TWITTER_TITLE"                 , "Twitter.LBL_MANAGE_TWITTER"                 , "ConfigView"           )
							, new AdminModule(L10n, "Salesforce"            , "Salesforce.LBL_MANAGE_SALESFORCE_TITLE"           , "Salesforce.LBL_MANAGE_SALESFORCE"           , "ConfigView"           )
							, new AdminModule(L10n, "QuickBooks"            , "QuickBooks.LBL_MANAGE_QUICKBOOKS_TITLE"           , "QuickBooks.LBL_MANAGE_QUICKBOOKS"           , "DetailView"           )
							, new AdminModule(L10n, "Twilio"                , "Twilio.LBL_TWILIO_SETTINGS"                       , "Twilio.LBL_TWILIO_SETTINGS_DESC"            , "ConfigView"           )
							, new AdminModule(L10n, "Twilio"                , "Twilio.LBL_TWILIO_MESSAGES"                       , "Twilio.LBL_TWILIO_MESSAGES_DESC"            , "List"                 )
							, new AdminModule(L10n, "OutboundSms"           , "OutboundSms.LBL_MANAGE_OUTBOUND_SMS"              , "OutboundSms.LBL_MANAGE_OUTBOUND_SMS_DESC"   , "List"                 , "InboundEmail.gif"   )
							, new AdminModule(L10n, "HubSpot"               , "HubSpot.LBL_MANAGE_HUBSPOT_TITLE"                 , "HubSpot.LBL_MANAGE_HUBSPOT"                 , "DetailView"           , "HubSpot.png"        )
							, new AdminModule(L10n, "iContact"              , "iContact.LBL_MANAGE_ICONTACT_TITLE"               , "iContact.LBL_MANAGE_ICONTACT"               , "DetailView"           , "iContact.png"       )
							, new AdminModule(L10n, "ConstantContact"       , "ConstantContact.LBL_MANAGE_CONSTANTCONTACT_TITLE" , "ConstantContact.LBL_MANAGE_CONSTANTCONTACT" , "DetailView"           , "ConstantContact.png")
							, new AdminModule(L10n, "Marketo"               , "Marketo.LBL_MANAGE_MARKETO_TITLE"                 , "Marketo.LBL_MANAGE_MARKETO"                 , "DetailView"           , "Marketo.png"        )
							, new AdminModule(L10n, "MailChimp"             , "MailChimp.LBL_MANAGE_MAILCHIMP_TITLE"             , "MailChimp.LBL_MANAGE_MAILCHIMP"             , "DetailView"           , "MailChimp.png"      )
							, new AdminModule(L10n, "CurrencyLayer"         , "CurrencyLayer.LBL_MANAGE_CURRENCYLAYER_TITLE"     , "CurrencyLayer.LBL_MANAGE_CURRENCYLAYER"     , "DetailView"           , "CurrencyLayer.png"  )
							, new AdminModule(L10n, "GetResponse"           , "GetResponse.LBL_MANAGE_GETRESPONSE_TITLE"         , "GetResponse.LBL_MANAGE_GETRESPONSE"         , "DetailView"           , "GetResponse.png"    )
							, new AdminModule(L10n, "Pardot"                , "Pardot.LBL_MANAGE_PARDOT_TITLE"                   , "Pardot.LBL_MANAGE_PARDOT"                   , "DetailView"           , "Pardot.png"         )
							, new AdminModule(L10n, "Watson"                , "Watson.LBL_MANAGE_WATSON_TITLE"                   , "Watson.LBL_MANAGE_WATSON"                   , "DetailView"           , "Watson.png"         )
							, new AdminModule(L10n, "PhoneBurner"           , "PhoneBurner.LBL_MANAGE_PHONEBURNER_TITLE"         , "PhoneBurner.LBL_MANAGE_PHONEBURNER"         , "DetailView"           , "PhoneBurner.png"    )
							};
							BuildAdminModules(L10n, objs, "CloudView", "Administration.LBL_CLOUD_SERVICES_TITLE", arrCloudView);
							break;
						}
						case "SurveysView":
						{
							AdminModule[] arrSurveysView = new AdminModule[]
							{ new AdminModule(L10n, "SurveyThemes"          , "Surveys.LBL_SURVEY_THEMES_TITLE"                  , "Surveys.LBL_SURVEY_THEMES_DESC"             , 90, dictModuleTabOrder , "SurveyThemes.LNK_NEW_SURVEY_THEME")
							};
							BuildAdminModules(L10n, objs, "SurveysView", "Surveys.LBL_SURVEYS_TITLE", arrSurveysView);
							break;
						}
						case "PaymentView":
						{
							AdminModule[] arrPaymentView = new AdminModule[]
							{ new AdminModule(L10n, "AuthorizeNet"          , "AuthorizeNet.LBL_AUTHORIZENET_SETTINGS"           , "AuthorizeNet.LBL_AUTHORIZENET_SETTINGS_DESC"         , "ConfigView"           )
							, new AdminModule(L10n, "AuthorizeNet"          , "AuthorizeNet.LBL_AUTHORIZENET_TRANSACTIONS"       , "AuthorizeNet.LBL_AUTHORIZENET_TRANSACTIONS_DESC"     , "List"                 )
							, new AdminModule(L10n, null                    , null                                               , null                                                  , null                   )
							, new AdminModule(L10n, "AuthorizeNet"          , "AuthorizeNet.LBL_AUTHORIZENET_CUSTOMER_PROFILES"  , "AuthorizeNet.LBL_AUTHORIZENET_CUSTOMER_PROFILES_DESC", "AuthorizeNetCustomerListView")
							, new AdminModule(L10n, "PayPal"                , "PayPal.LBL_PAYPAL_SETTINGS"                       , "PayPal.LBL_PAYPAL_SETTINGS_DESC"                     , "ConfigView"           )
							, new AdminModule(L10n, "PayPal"                , "PayPal.LBL_PAYPAL_TRANSACTIONS"                   , "Administration.LBL_PAYPAL_DESC"                      , "List"                 )
							, new AdminModule(L10n, "PayTrace"              , "PayTrace.LBL_PAYTRACE_SETTINGS"                   , "PayTrace.LBL_PAYTRACE_SETTINGS_DESC"                 , "ConfigView"           )
							, new AdminModule(L10n, "PayTrace"              , "PayTrace.LBL_PAYTRACE_TRANSACTIONS"               , "PayTrace.LBL_PAYTRACE_TRANSACTIONS_DESC"             , "List"                 )
							};
							// 06/29/2020 Paul.  Payment services do not exist in Community Edition. 
							if ( L10n.Term("Administration.LBL_PAYMENT_SERVICES_TITLE") != "Administration.LBL_PAYMENT_SERVICES_TITLE" )
								BuildAdminModules(L10n, objs, "PaymentView", "Administration.LBL_PAYMENT_SERVICES_TITLE", arrPaymentView);
							break;
						}
						case "VoIPView":
						{
							AdminModule[] arrVoipView = new AdminModule[]
							{ new AdminModule(L10n, "Asterisk"              , "Asterisk.LBL_ASTERISK_SETTINGS"                   , "Asterisk.LBL_ASTERISK_SETTINGS_DESC"                 , "ConfigView"           )
							, new AdminModule(L10n, "Asterisk"              , "Asterisk.LBL_CALL_DATA_RECORDS"                   , "Asterisk.LBL_CALL_DATA_RECORDS_DESC"                 , "List"                 )
							, new AdminModule(L10n, "Avaya"                 , "Avaya.LBL_AVAYA_SETTINGS"                         , "Avaya.LBL_AVAYA_SETTINGS_DESC"                       , "ConfigView"           )
							, new AdminModule(L10n, "Avaya"                 , "Avaya.LBL_CALL_DATA_RECORDS"                      , "Avaya.LBL_CALL_DATA_RECORDS_DESC"                    , "List"                 )
							};
							BuildAdminModules(L10n, objs, "VoipView", "Administration.LBL_VOIP_SERVICES_TITLE", arrVoipView);
							break;
						}
						case "DataPrivacyView":
						{
							AdminModule[] arrDataPrivacyView = new AdminModule[]
							{ new AdminModule(L10n, "DataPrivacy"           , "DataPrivacy.LBL_DATA_PRIVACY_TITLE"               , "DataPrivacy.LBL_DATA_PRIVACY_DESC"          , 100, dictModuleTabOrder, "DataPrivacy.LNK_NEW_DATA_PRIVACY"              )
							};
							BuildAdminModules(L10n, objs, "DataPrivacyView", "DataPrivacy.LBL_DATA_PRIVACY_TITLE", arrDataPrivacyView);
							break;
						}
						case "~/Administration/Azure/AzureServicesView":
						{
							AdminModule[] arrAzureView = new AdminModule[]
							{ new AdminModule(L10n, "Azure"                 , "Azure.LBL_AZURE_SETTINGS"                         , "Azure.LBL_AZURE_SETTINGS_DESC"              , "ConfigView"           , "AzureSettings.png"       )
							, new AdminModule(L10n, "AzureRegions"          , "Azure.LBL_AZURE_REGIONS_TITLE"                    , "Azure.LBL_AZURE_REGIONS_DESCRIPTION"        , 110, dictModuleTabOrder, "AzureRegions.LNK_NEW_AZURE_REGION"             , "Azure.png"               )
							// 04/27/2022 Paul.  Separate link for Azure Overview vs Settings.
							, new AdminModule(L10n, "Azure"                 , "Azure.LBL_AZURE_OVERVIEW"                         , "Azure.LBL_AZURE_OVERVIEW_DESC"              , "Overview"             , "AzureSettings.png"       )
							, new AdminModule(L10n, "AzureAppPrices"        , "Azure.LBL_AZURE_APP_PRICES_TITLE"                 , "Azure.LBL_AZURE_APP_PRICES_DESCRIPTION"     , 110, dictModuleTabOrder, "AzureAppPrices.LNK_NEW_AZURE_APP_PRICE"        , "AzureWebApps.png"        )
							, new AdminModule(L10n, "AzureOrders"           , "Azure.LBL_AZURE_ORDERS_TITLE"                     , "Azure.LBL_AZURE_ORDERS_DESCRIPTION"         , 110, dictModuleTabOrder, "AzureOrders.LNK_NEW_AZURE_ORDER"               , "AzureOrders.png"         )
							, new AdminModule(L10n, "AzureAppUpdates"       , "Azure.LBL_AZURE_APP_UPDATES_TITLE"                , "Azure.LBL_AZURE_APP_UPDATES_DESCRIPTION"    , 110, dictModuleTabOrder, "AzureAppPrices.LNK_NEW_AZURE_APP_PRICE"        , "AzureWebApps.png"        )
							, new AdminModule(L10n, "AzureServiceLevels"    , "Azure.LBL_AZURE_SERVICE_LEVELS_TITLE"             , "Azure.LBL_AZURE_SERVICE_LEVELS_DESCRIPTION" , 110, dictModuleTabOrder, "AzureServiceLevels.LNK_NEW_AZURE_SERVICE_LEVEL", "AzureServiceLevels.png"  )
							, new AdminModule(L10n, "AzureSqlPrices"        , "Azure.LBL_AZURE_SQL_PRICES_TITLE"                 , "Azure.LBL_AZURE_SQL_PRICES_DESCRIPTION"     , 110, dictModuleTabOrder, "AzureSqlPrices.LNK_NEW_AZURE_SQL_PRICE"        , "AzureSQLServers.png"     )
							, new AdminModule(L10n, "AzureVmPrices"         , "Azure.LBL_AZURE_VM_PRICES_TITLE"                  , "Azure.LBL_AZURE_VM_PRICES_DESCRIPTION"      , 110, dictModuleTabOrder, "AzureVmPrices.LNK_NEW_AZURE_VM_PRICE"          , "AzureVirtualMachines.png")
							, new AdminModule(L10n, "AzureSystemLog"        , "Azure.LBL_AZURE_SYSTEM_LOG_TITLE"                 , "Azure.LBL_AZURE_SYSTEM_LOG_DESCRIPTION"     , 110, dictModuleTabOrder, null                                            , "AzureSystemLog.png"      )
							};
							BuildAdminModules(L10n, objs, "AzureView", "Azure.LBL_AZURE_SERVICES_TITLE", arrAzureView);

							AdminModule[] arrAzureMonitoring = new AdminModule[]
							{ new AdminModule(L10n, "DnsNames"              , "Azure.LBL_DNS_NAMES_TITLE"                        , "Azure.LBL_DNS_NAMES_DESCRIPTION"            , 110, dictModuleTabOrder, "DnsNames.LBL_NEW_FORM_TITLE"                   , "AzureDNSNames.png"       )
							, new AdminModule(L10n, "VirtualMachines"       , "Azure.LBL_VIRTUAL_MACHINES_TITLE"                 , "Azure.LBL_VIRTUAL_MACHINES_DESCRIPTION"     , 110, dictModuleTabOrder, "VirtualMachines.LBL_NEW_FORM_TITLE"            , "AzureVirtualMachines.png")
							, new AdminModule(L10n, "SqlDatabases"          , "Azure.LBL_SQL_DATABASES_TITLE"                    , "Azure.LBL_SQL_DATABASES_DESCRIPTION"        , 110, dictModuleTabOrder, "SqlDatabases.LBL_NEW_FORM_TITLE"               , "AzureSQLDatabases.png"   )
							, new AdminModule(L10n, "SqlServers"            , "Azure.LBL_SQL_SERVERS_TITLE"                      , "Azure.LBL_SQL_SERVERS_DESCRIPTION"          , 110, dictModuleTabOrder, "SqlServers.LBL_NEW_FORM_TITLE"                 , "AzureSQLServers.png"     )
							, new AdminModule(L10n, "ResourceGroups"        , "Azure.LBL_AZURE_RESOURCE_GROUPS_TITLE"            , "Azure.LBL_AZURE_RESOURCE_GROUPS_DESCRIPTION", 110, dictModuleTabOrder, "ResourceGroups.LBL_NEW_FORM_TITLE"             , "AzureResourceGroups.png" )
							, new AdminModule(L10n, "StorageAccounts"       , "Azure.LBL_STORAGE_ACCOUNTS_TITLE"                 , "Azure.LBL_STORAGE_ACCOUNTS_DESCRIPTION"     , 110, dictModuleTabOrder, "StorageAccounts.LBL_NEW_FORM_TITLE"            , "AzureStorageAccounts.png")
							};
							BuildAdminModules(L10n, objs, "AzureMonitoring", "Azure.LBL_AZURE_MONITORING_TITLE", arrAzureMonitoring);
							break;
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
			return objs;
		}

		private void BuildAdminModules(L10N L10n, List<Dictionary<string, object>> objs, string sCategory, string sCategoryTitle, AdminModule[] arrModules)
		{
			HttpContext Context = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			List<AdminModule> modules = new List<AdminModule>();
			foreach ( AdminModule module in arrModules )
			{
				// 03/04/2019 Paul.  Excluded disabled modules, in part because terminology not provided. 
				string sModuleName = module.MODULE_NAME;
				// 11/11/2019 Paul.  A null module means this is a blank. 
				if ( sModuleName == null )
					modules.Add(module);
				// 04/09/2019 Paul.  There is no Google module, but we need a layout for it. 
				else if ( sModuleName == "Google" || sModuleName == "LinkedIn" || sModuleName == "Twitter" || sModuleName == "Salesforce" )
					sModuleName = "Config";
				// 02/18/2021 Paul.  Azure modules. 
				else if ( sModuleName == "CloudServices" || sModuleName == "DnsNames" || sModuleName == "ResourceGroups" || sModuleName == "SqlDatabases" || sModuleName == "SqlServers" || sModuleName == "StorageAccounts" || sModuleName == "VirtualMachines" )
					sModuleName = "Azure";
				// 09/04/2022 Paul.  We want to hide Cloud Services by disabling the module.  
				bool bValid = (Sql.ToBoolean(Application["Modules." + sModuleName + ".Valid"]) && Sql.ToBoolean(Application["Modules." + module.MODULE_NAME + ".Valid"])) || sModuleName == "SystemCheck";
				// 09/09/2021 Paul.  Allow documentation link to be hidden. 
				if ( bValid && module.ADMIN_ROUTE == "Documentation" )
					bValid = !Sql.ToBoolean(Application["CONFIG.hide_training"]);
				if ( bValid && SplendidCRM.Security.AdminUserAccess(sModuleName, "edit") >= 0 )
				{
					if ( module.MODULE_NAME == "Users" || sModuleName == "SystemCheck" || sModuleName == "Administration" )
					{
						modules.Add(module);
					}
					else
					{
						string sFolder = "~/Administration/" + module.MODULE_NAME;
						if ( module.MODULE_NAME == "PayPal" )
							sFolder = "~/Administration/PayPalTransactions";
						else if ( sModuleName == "iFrames" )
							sFolder = "~/" + module.MODULE_NAME;
						// 08/16/2021 Paul.  Special rules for Azure modules. 
						else if ( sModuleName.StartsWith("Azure") && sModuleName != "Azure" )
							sFolder = "~/Administration/Azure/" + module.MODULE_NAME;
						else if ( module.MODULE_NAME == "CloudServices"
						       || module.MODULE_NAME == "DnsNames"
						       || module.MODULE_NAME == "ResourceGroups"
						       || module.MODULE_NAME == "SqlDatabases"
						       || module.MODULE_NAME == "SqlServers"
						       || module.MODULE_NAME == "StorageAccounts"
						       || module.MODULE_NAME == "VirtualMachines"
						       )
						{
							sFolder = "~/Administration/Azure/" + module.MODULE_NAME;
						}
						bool bModuleExists = true;
// 10/31/2021 Paul.  All modules are available to the React client. 
#if !ReactOnlyUI
						bModuleExists = Utils.CachedFileExists(Context, sFolder + "/default.aspx");
#endif
						if ( bModuleExists )
						{
							modules.Add(module);
						}
						else
						{
							Debug.WriteLine("BuildAdminModules: Could not find module " + module.MODULE_NAME);
						}
					}
				}
			}
			if ( modules.Count > 0 )
			{
				Dictionary<string, object> category = new Dictionary<string, object>();
				objs.Add(category);
				category.Add("NAME"   , sCategory);
				category.Add("TITLE"  , L10n.Term(sCategoryTitle));
				category.Add("MODULES", modules);
			}
		}
		#endregion

		#region Get System Layout
		// 02/27/2016 Paul.  Combine all layout gets. 
		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAllLayouts()
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpContext          Context     = HttpContext.Current            ;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			L10N L10n = new L10N(Sql.ToString(Context.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			Dictionary<string, object> d       = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			d.Add("d", results);
			
			// 03/02/2019 Paul.  Functions are now static and take modules list input so that they can be used in the Admin API. 
			// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs
			List<string> lstMODULES = RestUtil.AdminAccessibleModules();
			// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
			Dictionary<string, object> GRIDVIEWS = SplendidCache.GetAllGridViews(Context, lstMODULES);
			results.Add("GRIDVIEWS", GRIDVIEWS);
			
			Dictionary<string, object> GRIDVIEWS_COLUMNS = SplendidCache.GetAllGridViewsColumns(Context, lstMODULES);
			results.Add("GRIDVIEWS_COLUMNS", GRIDVIEWS_COLUMNS);
			
			Dictionary<string, object> DETAILVIEWS_FIELDS = SplendidCache.GetAllDetailViewsFields(Context, lstMODULES);
			results.Add("DETAILVIEWS_FIELDS", DETAILVIEWS_FIELDS);
			
			Dictionary<string, object> EDITVIEWS_FIELDS = SplendidCache.GetAllEditViewsFields(Context, lstMODULES);
			results.Add("EDITVIEWS_FIELDS", EDITVIEWS_FIELDS);
			
			Dictionary<string, object> DETAILVIEWS_RELATIONSHIPS = SplendidCache.GetAllDetailViewsRelationships(Context, lstMODULES);
			results.Add("DETAILVIEWS_RELATIONSHIPS", DETAILVIEWS_RELATIONSHIPS);
			
			Dictionary<string, object> EDITVIEWS_RELATIONSHIPS = SplendidCache.GetAllEditViewsRelationships(Context, lstMODULES);
			results.Add("EDITVIEWS_RELATIONSHIPS", EDITVIEWS_RELATIONSHIPS);
			
			Dictionary<string, object> DYNAMIC_BUTTONS = SplendidCache.GetAllDynamicButtons(Context, lstMODULES);
			results.Add("DYNAMIC_BUTTONS", DYNAMIC_BUTTONS);
			
			// 03/26/2019 Paul.  Admin has more custom lists. 
			Dictionary<string, object> TERMINOLOGY_LISTS = SplendidCache.GetAllTerminologyLists(Context, true);
			results.Add("TERMINOLOGY_LISTS", TERMINOLOGY_LISTS);
			
			// 03/26/2019 Paul.  Admin has more custom lists. 
			Dictionary<string, object> TERMINOLOGY = SplendidCache.GetAllTerminology(Context, lstMODULES, true);
			results.Add("TERMINOLOGY", TERMINOLOGY);
			
			Dictionary<string, object> TAX_RATES = SplendidCache.GetAllTaxRates(Context);
			results.Add("TAX_RATES", TAX_RATES);
			
			Dictionary<string, object> DISCOUNTS = SplendidCache.GetAllDiscounts(Context);
			results.Add("DISCOUNTS", DISCOUNTS);
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			return RestUtil.ToJsonStream(d);
		}
		#endregion

		// 05/27/2019 Paul.  Separate call for the React client state. 
		#region React State
		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetReactState()
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpContext          Context     = HttpContext.Current            ;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			L10N L10n = new L10N(Sql.ToString(Context.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			Dictionary<string, object> d       = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			d.Add("d", results);
			
			// 03/02/2019 Paul.  Functions are now static and take modules list input so that they can be used in the Admin API. 
			// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs
			List<string> lstMODULES = RestUtil.AdminAccessibleModules();
			// 10/27/2019 Paul.  React Client needs access to faux modules in admin. 
			lstMODULES.Add("PasswordManager");
			lstMODULES.Add("BusinessMode"   );
			lstMODULES.Add("Twilio"         );
			lstMODULES.Add("Updater"        );
			
			// 05/27/2019 Paul.  Move GetUserProfile to cache for React client. 
			SplendidCache.UserProfile profile = SplendidCache.GetUserProfile();
			results.Add("USER_PROFILE", profile);
			
			// 12/23/2019 Paul.  Return the team tree as an object tree instead of XML. 
			results.Add("TEAM_TREE", SplendidCache.GetUserTeamTree());
			
			// 07/21/2019 Paul.  We need UserAccess control for buttons. 
			Dictionary<string, object> MODULE_ACL_ACCESS = SplendidCache.GetModuleAccess(Context, lstMODULES);
			results.Add("MODULE_ACL_ACCESS", MODULE_ACL_ACCESS);
			
			Dictionary<string, object> ACL_ACCESS = SplendidCache.GetUserAccess(Context, lstMODULES);
			results.Add("ACL_ACCESS", ACL_ACCESS);
			
			Dictionary<string, object> ACL_FIELD_ACCESS = SplendidCache.GetUserFieldSecurity(Context, lstMODULES);
			results.Add("ACL_FIELD_ACCESS", ACL_FIELD_ACCESS);
			
			// 01/22/2021 Paul.  Some customizations may be dependent on role name. 
			List<Dictionary<string, object>>  ACL_ROLES = SplendidCache.GetUserACLRoles(Context);
			results.Add("ACL_ROLES", ACL_ROLES);
			
			// 05/17/2019 Paul.  Return the modules so that we don't need a separate request for it later. 
			Dictionary<string, object> CONFIG = SplendidCache.GetAllConfig(Context);
			results.Add("CONFIG", CONFIG);
			
			Dictionary<string, int> dictModuleTabOrder = new Dictionary<string, int>();
			Dictionary<string, object> MODULES = SplendidCache.GetAdminModules(Context, dictModuleTabOrder);
			results.Add("MODULES", MODULES);
			
			Dictionary<string, object> MODULE_COLUMNS = SplendidCache.GetAllSearchColumns(Context, lstMODULES);
			results.Add("MODULE_COLUMNS", MODULE_COLUMNS);
			
			// 05/26/2019 Paul.  Return Users and Teams in GetAllLayouts. 
			Dictionary<string, object> USERS = SplendidCache.GetAllUsers(Context);
			results.Add("USERS", USERS);
			
			Dictionary<string, object> TEAMS = SplendidCache.GetAllTeams(Context);
			results.Add("TEAMS", TEAMS);
			
			// 05/16/2019 Paul.  Return the tab menu so that we don't need a separate request for it later. 
			List<object> TAB_MENU = SplendidCache.GetAllTabMenus(Context);
			results.Add("TAB_MENU", TAB_MENU);

			List<Dictionary<string, object>> ADMIN_MENU = GetAdminMenu(dictModuleTabOrder);
			results.Add("ADMIN_MENU", ADMIN_MENU);
			
			// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
			Dictionary<string, object> GRIDVIEWS = SplendidCache.GetAllGridViews(Context, lstMODULES);
			results.Add("GRIDVIEWS", GRIDVIEWS);
			
			Dictionary<string, object> GRIDVIEWS_COLUMNS = SplendidCache.GetAllGridViewsColumns(Context, lstMODULES);
			results.Add("GRIDVIEWS_COLUMNS", GRIDVIEWS_COLUMNS);
			
			Dictionary<string, object> DETAILVIEWS_FIELDS = SplendidCache.GetAllDetailViewsFields(Context, lstMODULES);
			results.Add("DETAILVIEWS_FIELDS", DETAILVIEWS_FIELDS);
			
			Dictionary<string, object> EDITVIEWS_FIELDS = SplendidCache.GetAllEditViewsFields(Context, lstMODULES);
			results.Add("EDITVIEWS_FIELDS", EDITVIEWS_FIELDS);
			
			Dictionary<string, object> DETAILVIEWS_RELATIONSHIPS = SplendidCache.GetAllDetailViewsRelationships(Context, lstMODULES);
			results.Add("DETAILVIEWS_RELATIONSHIPS", DETAILVIEWS_RELATIONSHIPS);
			
			Dictionary<string, object> EDITVIEWS_RELATIONSHIPS = SplendidCache.GetAllEditViewsRelationships(Context, lstMODULES);
			results.Add("EDITVIEWS_RELATIONSHIPS", EDITVIEWS_RELATIONSHIPS);
			
			Dictionary<string, object> DYNAMIC_BUTTONS = SplendidCache.GetAllDynamicButtons(Context, lstMODULES);
			results.Add("DYNAMIC_BUTTONS", DYNAMIC_BUTTONS);
			
			// 08/15/2019 Paul.  Add support for menu shortcuts. 
			Dictionary<string, object> SHORTCUTS = SplendidCache.GetAllShortcuts(Context, lstMODULES);
			results.Add("SHORTCUTS", SHORTCUTS);
			
			// 03/26/2019 Paul.  Admin has more custom lists. 
			Dictionary<string, object> TERMINOLOGY_LISTS = SplendidCache.GetAllTerminologyLists(Context, true);
			results.Add("TERMINOLOGY_LISTS", TERMINOLOGY_LISTS);
			
			// 03/26/2019 Paul.  Admin has more custom lists. 
			Dictionary<string, object> TERMINOLOGY = SplendidCache.GetAllTerminology(Context, lstMODULES, true);
			results.Add("TERMINOLOGY", TERMINOLOGY);
			
			// 07/01/2019 Paul.  The SubPanelsView needs to understand how to manage all relationships. 
			Dictionary<string, object> RELATIONSHIPS = SplendidCache.GetAllRelationships(Context);
			results.Add("RELATIONSHIPS", RELATIONSHIPS);
			
			Dictionary<string, object> TAX_RATES = SplendidCache.GetAllTaxRates(Context);
			results.Add("TAX_RATES", TAX_RATES);
			
			Dictionary<string, object> DISCOUNTS = SplendidCache.GetAllDiscounts(Context);
			results.Add("DISCOUNTS", DISCOUNTS);
			
			// 09/12/2019 Paul.  User Profile needs the timezones and currencies. 
			Dictionary<string, object> TIMEZONES = SplendidCache.GetAllTimezones(Context);
			results.Add("TIMEZONES", TIMEZONES);
			
			Dictionary<string, object> CURRENCIES = SplendidCache.GetAllCurrencies(Context);
			results.Add("CURRENCIES", CURRENCIES);
			
			Dictionary<string, object> LANGUAGES = SplendidCache.GetAllLanguages(Context);
			results.Add("LANGUAGES", LANGUAGES);
			
			// 04/28/2019 Paul.  Flag to include Favorites and LastViewed for the React client. 
			Dictionary<string, object> FAVORITES = SplendidCache.GetAllFavorites(Context);
			results.Add("FAVORITES", FAVORITES);
			
			Dictionary<string, object> LAST_VIEWED = SplendidCache.GetAllLastViewed(Context);
			results.Add("LAST_VIEWED", LAST_VIEWED);
			
			Dictionary<string, object> SAVED_SEARCH = SplendidCache.GetAllSavedSearch(Context, lstMODULES);
			results.Add("SAVED_SEARCH", SAVED_SEARCH);
			
			// 05/24/2019 Paul.  Return Dashboar in GetAllLayouts. 
			Dictionary<string, object> DASHBOARDS = SplendidCache.GetAllDashboards(Context);
			results.Add("DASHBOARDS", DASHBOARDS);
			
			Dictionary<string, object> DASHBOARDS_PANELS = SplendidCache.GetAllDashboardPanels(Context, lstMODULES);
			results.Add("DASHBOARDS_PANELS", DASHBOARDS_PANELS);
			
			// 05/03/2020 Paul.  Emails.EditView should use cached list of signatures. 
			Dictionary<string, object> SIGNATURES = SplendidCache.GetUserSignatures(Context);
			results.Add("SIGNATURES", SIGNATURES);
			
			// 05/05/2020 Paul.  Emails.EditView should use cached list of OutboundMail. 
			Dictionary<string, object> OUTBOUND_EMAILS = SplendidCache.GetOutboundMail(Context);
			results.Add("OUTBOUND_EMAILS", OUTBOUND_EMAILS);
			
			// 05/05/2020 Paul.  Emails.EditView should use cached list of OutboundSms. 
			// 09/24/2021 Paul.  Wrong lis was being used. 
			Dictionary<string, object> OUTBOUND_SMS = SplendidCache.GetOutboundSms(Context);
			results.Add("OUTBOUND_SMS", OUTBOUND_SMS);
			
			// 08/09/2020 Paul.  Convert to comma separated string. 
			string sModuleList = String.Join(",", lstMODULES.ToArray());
			Dictionary<string, object> objs = HttpRuntime.Cache.Get("ReactCustomViews.Admin." + sModuleList) as Dictionary<string, object>;
#if DEBUG
			objs = null;
#endif
			if ( objs == null )
			{
				objs = new Dictionary<string, object>();
				// 12/07/2022 Paul.  Allow the LoginView to be customized. 
				SplendidCache.GetAllReactCustomViews(Context, objs, lstMODULES, "~/React/src/CustomViewsJS"     , false, false);
				SplendidCache.GetAllReactCustomViews(Context, objs, lstMODULES, "~/React/src/AdminCustomViewsJS", true , false);
				// 05/23/2019 Paul.  Include Dashlet views, but we do not yet have a way to separate by module. 
				SplendidCache.GetAllReactDashletViews(Context, objs, lstMODULES, "~/React/src/DashletsJS");
				HttpRuntime.Cache.Insert("ReactCustomViews.Admin." + sModuleList, objs, null, SplendidCache.DefaultCacheExpiration(), System.Web.Caching.Cache.NoSlidingExpiration);
			}
			results.Add("REACT_CUSTOM_VIEWS", objs);
			// 07/12/2021 Paul.  Attempt to track timeout so that we can determine stale React state. 
			results.Add("SessionStateTimeout", HttpContext.Current.Session.Timeout);
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			return RestUtil.ToJsonStream(d);
		}

		// 02/20/2021 Paul.  GetReactMenu() is primarily used by Admin ConfigureTabs page. 
		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetReactMenu()
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpContext          Context     = HttpContext.Current            ;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			L10N L10n = new L10N(Sql.ToString(Context.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			Dictionary<string, object> d       = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			d.Add("d", results);
			
			Session.Remove("vwMODULES.TabMenu.ReactClient");
			List<object> TAB_MENU = SplendidCache.GetAllTabMenus(Context);
			results.Add("TAB_MENU", TAB_MENU);

			return RestUtil.ToJsonStream(d);
		}

		/*
		// 02/25/2019 Paul.  New method to fetch the React Custom Views. 
		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAllReactCustomViews()
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			
			Dictionary<string, object> d       = new Dictionary<string, object>();
			Dictionary<string, object> results = new Dictionary<string, object>();
			
			// 12/16/2019 Paul.  Moved GetTable to ~/_code/RestUtil.cs
			List<string> lstMODULES = RestUtil.AdminAccessibleModules();
			// 08/09/2020 Paul.  Convert to comma separated string. 
			string sModuleList = String.Join(",", lstMODULES.ToArray());
			Dictionary<string, object> objs = HttpRuntime.Cache.Get("ReactCustomViews.Admin." + sModuleList) as Dictionary<string, object>;
#if DEBUG
			objs = null;
#endif
			if ( objs == null )
			{
				objs = new Dictionary<string, object>();
				SplendidCache.GetAllReactCustomViews(objs, lstMODULES, "~/React/src/CustomViewsJS");
				SplendidCache.GetAllReactCustomViews(objs, lstMODULES, "~/React/src/AdminCustomViewsJS");
				// 05/23/2019 Paul.  Include Dashlet views, but we do not yet have a way to separate by module. 
				SplendidCache.GetAllReactDashletViews(objs, lstMODULES, "~/React/src/DashletsJS");
				HttpRuntime.Cache.Insert("ReactCustomViews.Admin." + sModuleList, objs, null, SplendidCache.DefaultCacheExpiration(), System.Web.Caching.Cache.NoSlidingExpiration);
			}
			results.Add("results", objs);
			d.Add("d", results);
			d.Add("__count", objs.Count);
			return ToJsonStream(d);
		}
		*/
		#endregion

		#region Update
		[OperationContract]
		public void UpdateAdminLayout(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sTableName = Sql.ToString(Request.QueryString["TableName"]);
			if ( Sql.IsEmptyString(sTableName) )
				throw(new Exception("The table name must be specified."));
			
			// 02/20/2016 Paul.  Module name is included in ViewName, or is blank when updating globals. 
			string sViewName = Sql.ToString(Request.QueryString["ViewName"]);
			if ( Sql.IsEmptyString(sViewName) && sTableName != "TERMINOLOGY" )
				throw(new Exception("The layout view name must be specified."));
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			switch ( sTableName )
			{
				case "EDITVIEWS_FIELDS"         :  UpdateAdminLayoutTable("EDITVIEWS"  , "EDITVIEWS_FIELDS"         , "EDIT_NAME"  , "FIELD_INDEX"       , "FIELD_TYPE" , true , sViewName, dict);  SplendidCache.ClearEditView  (sViewName);  break;
				case "DETAILVIEWS_FIELDS"       :  UpdateAdminLayoutTable("DETAILVIEWS", "DETAILVIEWS_FIELDS"       , "DETAIL_NAME", "FIELD_INDEX"       , "FIELD_TYPE" , true , sViewName, dict);  SplendidCache.ClearDetailView(sViewName);  break;
				case "GRIDVIEWS_COLUMNS"        :  UpdateAdminLayoutTable("GRIDVIEWS"  , "GRIDVIEWS_COLUMNS"        , "GRID_NAME"  , "COLUMN_INDEX"      , "COLUMN_TYPE", false, sViewName, dict);  SplendidCache.ClearGridView  (sViewName);  break;
				case "DETAILVIEWS_RELATIONSHIPS":  UpdateAdminTableLayoutName("DETAILVIEWS_RELATIONSHIPS", "DETAIL_NAME", sViewName, dict);  SplendidCache.ClearDetailViewRelationships(sViewName);  break;
				case "EDITVIEWS_RELATIONSHIPS"  :  UpdateAdminTableLayoutName("EDITVIEWS_RELATIONSHIPS"  , "EDIT_NAME"  , sViewName, dict);  SplendidCache.ClearEditViewRelationships  (sViewName);  break;
				case "TERMINOLOGY"              :  UpdateAdminTableLayoutName("TERMINOLOGY"              , "MODULE_NAME", sViewName, dict);  ReloadTerminology(HttpContext.Current, sViewName);  break;
				default:  throw(new Exception("Unsupported table: " + sTableName));
			}
		}

		private void ReloadTerminology(HttpContext Context, string sMODULE_NAME)
		{
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select NAME                " + ControlChars.CrLf
					     + "     , LANG                " + ControlChars.CrLf
					     + "     , MODULE_NAME         " + ControlChars.CrLf
					     + "     , DISPLAY_NAME        " + ControlChars.CrLf
					     + "  from vwTERMINOLOGY       " + ControlChars.CrLf
					     + " where LIST_NAME is null   " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						if ( Sql.IsEmptyString(sMODULE_NAME) )
							sSQL += "   and MODULE_NAME is null " + ControlChars.CrLf;
						else
							Sql.AppendParameter(cmd, sMODULE_NAME, "MODULE_NAME");
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								string sLANG         = Sql.ToString(rdr["LANG"        ]);
								string sNAME         = Sql.ToString(rdr["NAME"        ]);
								string sDISPLAY_NAME = Sql.ToString(rdr["DISPLAY_NAME"]);
								L10N.SetTerm(Context.Application, sLANG, sMODULE_NAME, sNAME, sDISPLAY_NAME);
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), ex);
				//HttpContext.Current.Response.Write(ex.Message);
			}
		}

		private void ClearLayoutTable(DbProviderFactory dbf, IDbTransaction trn, string sTABLE_NAME, string sLAYOUT_NAME_FIELD, string sVIEW_NAME)
		{
			IDbConnection con = trn.Connection;
			IDbCommand cmdDelete = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Delete");
			cmdDelete.Transaction = trn;
			Sql.SetParameter(cmdDelete, "MODIFIED_USER_ID", Security.USER_ID);
			
			string sSQL = String.Empty;
			sSQL = "select ID"                    + ControlChars.CrLf
			     + "  from vw" + sTABLE_NAME      + ControlChars.CrLf
			     + " where " + sLAYOUT_NAME_FIELD + " = @" + sLAYOUT_NAME_FIELD + ControlChars.CrLf
			     + "   and DEFAULT_VIEW = 0"      + ControlChars.CrLf;
			using ( IDbCommand cmd = con.CreateCommand() )
			{
				cmd.CommandText = sSQL;
				cmd.Transaction = trn;
				Sql.AddParameter(cmd, "@" + sLAYOUT_NAME_FIELD, sVIEW_NAME);
				using ( DbDataAdapter da = dbf.CreateDataAdapter() )
				{
					((IDbDataAdapter)da).SelectCommand = cmd;
					using ( DataTable dt = new DataTable() )
					{
						da.Fill(dt);
						foreach ( DataRow row in dt.Rows )
						{
							Guid gID = Sql.ToGuid(row["ID"]);
							Sql.SetParameter(cmdDelete, "ID", gID);
							cmdDelete.ExecuteNonQuery();
						}
					}
				}
			}
		}

		private void UpdateLayoutEvents(DbProviderFactory dbf, IDbTransaction trn, string sTABLE_NAME, string sVIEW_NAME, Dictionary<string, object> dict)
		{
			if ( dict.ContainsKey(sTABLE_NAME) )
			{
				IDbConnection con = trn.Connection;
				IDbCommand cmdUpdateEvents = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_UpdateEvents");
				cmdUpdateEvents.Transaction = trn;
				// 11/25/2020 Paul.  Clear all unset values. 
				foreach ( IDbDataParameter par in cmdUpdateEvents.Parameters )
				{
					par.Value = DBNull.Value;
				}
				// 11/26/2020 Paul.  Now initialize with previous values so that unset values do not get nulled. 
				try
				{
					string sSQL;
					sSQL = "select *"                + ControlChars.CrLf
					     + "  from vw" + sTABLE_NAME + ControlChars.CrLf
					     + " where NAME = @NAME"     + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@NAME", sVIEW_NAME);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtCurrent = new DataTable() )
							{
								da.Fill(dtCurrent);
								if ( dtCurrent.Rows.Count > 0 )
								{
									DataRow rowCurrent = dtCurrent.Rows[0];
									foreach ( IDbDataParameter par in cmdUpdateEvents.Parameters )
									{
										string sParameterName = Sql.ExtractDbName(cmdUpdateEvents, par.ParameterName).ToUpper();
										if ( dtCurrent.Columns.Contains(sParameterName) )
										{
											par.Value = rowCurrent[sParameterName];
										}
									}
								}
							}
						}
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				}
				
				Sql.SetParameter(cmdUpdateEvents, "NAME", sVIEW_NAME);
				Sql.SetParameter(cmdUpdateEvents, "MODIFIED_USER_ID", Security.USER_ID);
				
				Dictionary<string, object> dictTable = dict[sTABLE_NAME] as Dictionary<string, object>;
				foreach ( string sFieldName in dictTable.Keys )
				{
					if ( sFieldName != "NAME" && sFieldName != "MODIFIED_USER_ID" )
					{
						IDbDataParameter par = Sql.FindParameter(cmdUpdateEvents, sFieldName);
						if ( par != null )
						{
							switch ( par.DbType )
							{
								case DbType.Guid    :  par.Value = Sql.ToDBGuid    (dictTable[sFieldName]);  break;
								case DbType.Int16   :  par.Value = Sql.ToDBInteger (dictTable[sFieldName]);  break;
								case DbType.Int32   :  par.Value = Sql.ToDBInteger (dictTable[sFieldName]);  break;
								case DbType.Int64   :  par.Value = Sql.ToDBInteger (dictTable[sFieldName]);  break;
								case DbType.Double  :  par.Value = Sql.ToDBFloat   (dictTable[sFieldName]);  break;
								case DbType.Decimal :  par.Value = Sql.ToDBDecimal (dictTable[sFieldName]);  break;
								case DbType.Byte    :  par.Value = Sql.ToDBBoolean (dictTable[sFieldName]);  break;
								case DbType.DateTime:  par.Value = Sql.ToDBDateTime(dictTable[sFieldName]);  break;
								default             :  par.Value = Sql.ToDBString  (dictTable[sFieldName]);  break;
							}
						}
					}
				}
				cmdUpdateEvents.ExecuteNonQuery();
			}
		}

		// 05/04/2016 Paul.  A copied view will need the root EDITVIEWS, DETAILVIEWS or GRIDVIEWS record. 
		private void CreateParentTable(DbProviderFactory dbf, IDbTransaction trn, string sTABLE_NAME, string sVIEW_NAME, Dictionary<string, object> dict)
		{
			if ( dict.ContainsKey(sTABLE_NAME) )
			{
				IDbConnection con = trn.Connection;
				IDbCommand cmdInsertOnly = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_InsertOnly");
				cmdInsertOnly.Transaction = trn;
				Sql.SetParameter(cmdInsertOnly, "NAME", sVIEW_NAME);
				Sql.SetParameter(cmdInsertOnly, "MODIFIED_USER_ID", Security.USER_ID);
				
				Dictionary<string, object> dictTable = dict[sTABLE_NAME] as Dictionary<string, object>;
				foreach ( string sFieldName in dictTable.Keys )
				{
					if ( sFieldName != "NAME" && sFieldName != "MODIFIED_USER_ID" )
					{
						IDbDataParameter par = Sql.FindParameter(cmdInsertOnly, sFieldName);
						if ( par != null )
						{
							switch ( par.DbType )
							{
								case DbType.Guid    :  par.Value = Sql.ToDBGuid    (dictTable[sFieldName]);  break;
								case DbType.Int16   :  par.Value = Sql.ToDBInteger (dictTable[sFieldName]);  break;
								case DbType.Int32   :  par.Value = Sql.ToDBInteger (dictTable[sFieldName]);  break;
								case DbType.Int64   :  par.Value = Sql.ToDBInteger (dictTable[sFieldName]);  break;
								case DbType.Double  :  par.Value = Sql.ToDBFloat   (dictTable[sFieldName]);  break;
								case DbType.Decimal :  par.Value = Sql.ToDBDecimal (dictTable[sFieldName]);  break;
								case DbType.Byte    :  par.Value = Sql.ToDBBoolean (dictTable[sFieldName]);  break;
								case DbType.DateTime:  par.Value = Sql.ToDBDateTime(dictTable[sFieldName]);  break;
								default             :  par.Value = Sql.ToDBString  (dictTable[sFieldName]);  break;
							}
						}
					}
				}
				cmdInsertOnly.ExecuteNonQuery();
			}
		}

		private void UpdateLayoutTable(DbProviderFactory dbf, IDbTransaction trn, string sTABLE_NAME, string sLAYOUT_NAME_FIELD, string sLAYOUT_INDEX_FIELD, string sVIEW_NAME, Dictionary<string, object> dict)
		{
			if ( dict.ContainsKey(sTABLE_NAME) )
			{
				IDbConnection con = trn.Connection;
				IDbCommand cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update");
				cmdUpdate.Transaction = trn;
				IDbDataParameter parMODIFIED_USER_ID = Sql.FindParameter(cmdUpdate, "@MODIFIED_USER_ID");
				
				System.Collections.ArrayList lst = dict[sTABLE_NAME] as System.Collections.ArrayList;
				for ( int i = 0; i < lst.Count; i++ )
				{
					foreach(IDbDataParameter par in cmdUpdate.Parameters)
					{
						par.Value = DBNull.Value;
					}
					if ( parMODIFIED_USER_ID != null )
						parMODIFIED_USER_ID.Value = Security.USER_ID;
					
					Dictionary<string, object> dictRow = lst[i] as Dictionary<string, object>;
					Sql.SetParameter(cmdUpdate, "ID"               , Guid.Empty);
					Sql.SetParameter(cmdUpdate, sLAYOUT_NAME_FIELD , sVIEW_NAME);
					foreach ( string sFieldName in dictRow.Keys )
					{
						if ( sFieldName != sLAYOUT_NAME_FIELD && sFieldName != "ID" && sFieldName != "MODIFIED_USER_ID" )
						{
							IDbDataParameter par = Sql.FindParameter(cmdUpdate, sFieldName);
							if ( par != null )
							{
								switch ( par.DbType )
								{
									case DbType.Guid    :  par.Value = Sql.ToDBGuid    (dictRow[sFieldName]);  break;
									case DbType.Int16   :  par.Value = Sql.ToDBInteger (dictRow[sFieldName]);  break;
									case DbType.Int32   :  par.Value = Sql.ToDBInteger (dictRow[sFieldName]);  break;
									case DbType.Int64   :  par.Value = Sql.ToDBInteger (dictRow[sFieldName]);  break;
									case DbType.Double  :  par.Value = Sql.ToDBFloat   (dictRow[sFieldName]);  break;
									case DbType.Decimal :  par.Value = Sql.ToDBDecimal (dictRow[sFieldName]);  break;
									case DbType.Byte    :  par.Value = Sql.ToDBBoolean (dictRow[sFieldName]);  break;
									case DbType.DateTime:  par.Value = Sql.ToDBDateTime(dictRow[sFieldName]);  break;
									default             :  par.Value = Sql.ToDBString  (dictRow[sFieldName]);  break;
								}
							}
						}
					}
					cmdUpdate.ExecuteNonQuery();
				}
			}
		}

		private void CheckDuplicates(DbProviderFactory dbf, IDbTransaction trn, string sTABLE_NAME, string sLAYOUT_NAME_FIELD, string sLAYOUT_TYPE_FIELD, string sVIEW_NAME)
		{
			IDbConnection con = trn.Connection;

			string sSQL = String.Empty;
			sSQL = "select DATA_FIELD"                                          + ControlChars.CrLf
			     + "  from vw" + sTABLE_NAME                                    + ControlChars.CrLf
			     + " where DATA_FIELD is not null"                              + ControlChars.CrLf
			     + "   and " + sLAYOUT_NAME_FIELD + " = @" + sLAYOUT_NAME_FIELD + ControlChars.CrLf
			     + "   and " + sLAYOUT_TYPE_FIELD + " <> 'JavaScript'"          + ControlChars.CrLf
			     + "   and DEFAULT_VIEW = 0"                                    + ControlChars.CrLf
			     + " group by DATA_FIELD"                                       + ControlChars.CrLf
			     + " having count(*) > 1"                                       + ControlChars.CrLf
			     + " order by DATA_FIELD"                                       + ControlChars.CrLf;
			using ( IDbCommand cmd = con.CreateCommand() )
			{
				cmd.CommandText = sSQL;
				cmd.Transaction = trn;
				Sql.AddParameter(cmd, "@" + sLAYOUT_NAME_FIELD, sVIEW_NAME);
				using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
				{
					StringBuilder sbDuplicateFields = new StringBuilder();
					while ( rdr.Read() )
					{
						if ( sbDuplicateFields.Length > 0 )
							sbDuplicateFields.Append(", ");
						sbDuplicateFields.Append(Sql.ToString(rdr["DATA_FIELD"]));
					}
					if ( sbDuplicateFields.Length > 0 )
					{
						throw(new Exception("Duplicate fields: " + sbDuplicateFields.ToString()));
					}
				}
			}
		}

		private void UpdateAdminLayoutTable(string sPARENT_TABLE, string sTABLE_NAME, string sLAYOUT_NAME_FIELD, string sLAYOUT_INDEX_FIELD, string sLAYOUT_TYPE_FIELD, bool bCheckDuplicates, string sVIEW_NAME, Dictionary<string, object> dict)
		{
			HttpSessionState Session = HttpContext.Current.Session;
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						try
						{
							ClearLayoutTable  (dbf, trn, sTABLE_NAME  , sLAYOUT_NAME_FIELD, sVIEW_NAME);
							// 05/04/2016 Paul.  A copied view will need the root EDITVIEWS, DETAILVIEWS or GRIDVIEWS record. 
							CreateParentTable (dbf, trn, sPARENT_TABLE  , sVIEW_NAME, dict);
							UpdateLayoutTable (dbf, trn, sTABLE_NAME  , sLAYOUT_NAME_FIELD, sLAYOUT_INDEX_FIELD, sVIEW_NAME, dict);
							if ( !Sql.IsEmptyString(sPARENT_TABLE) )
								UpdateLayoutEvents(dbf, trn, sPARENT_TABLE, sVIEW_NAME, dict);
							if ( bCheckDuplicates )
								CheckDuplicates(dbf, trn, sTABLE_NAME, sLAYOUT_NAME_FIELD, sLAYOUT_TYPE_FIELD, sVIEW_NAME);
							trn.Commit();
						}
						catch(Exception ex)
						{
							trn.Rollback();
							throw(new Exception("Failed to update, transaction aborted; " + ex.Message, ex));
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}

		// 03/20/2019 Paul.  Change function name to be more specific to layout view. 
		private void UpdateAdminTableLayoutName(string sTABLE_NAME, string sLAYOUT_NAME_FIELD, string sVIEW_NAME, Dictionary<string, object> dict)
		{
			HttpSessionState Session = HttpContext.Current.Session;
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						try
						{
							if ( dict.ContainsKey(sTABLE_NAME) )
							{
								IDbCommand cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update");
								cmdUpdate.Transaction = trn;
								IDbDataParameter parMODIFIED_USER_ID = Sql.FindParameter(cmdUpdate, "@MODIFIED_USER_ID");
								
								System.Collections.ArrayList lst = dict[sTABLE_NAME] as System.Collections.ArrayList;
								for ( int i = 0; i < lst.Count; i++ )
								{
									foreach(IDbDataParameter par in cmdUpdate.Parameters)
									{
										par.Value = DBNull.Value;
									}
									if ( parMODIFIED_USER_ID != null )
										parMODIFIED_USER_ID.Value = Security.USER_ID;
									
									Dictionary<string, object> dictRow = lst[i] as Dictionary<string, object>;
									Sql.SetParameter(cmdUpdate, sLAYOUT_NAME_FIELD , sVIEW_NAME);
									foreach ( string sFieldName in dictRow.Keys )
									{
										if ( sFieldName != sLAYOUT_NAME_FIELD && sFieldName != "MODIFIED_USER_ID" )
										{
											IDbDataParameter par = Sql.FindParameter(cmdUpdate, sFieldName);
											if ( par != null )
											{
												switch ( par.DbType )
												{
													case DbType.Guid    :  par.Value = Sql.ToDBGuid    (dictRow[sFieldName]);  break;
													case DbType.Int16   :  par.Value = Sql.ToDBInteger (dictRow[sFieldName]);  break;
													case DbType.Int32   :  par.Value = Sql.ToDBInteger (dictRow[sFieldName]);  break;
													case DbType.Int64   :  par.Value = Sql.ToDBInteger (dictRow[sFieldName]);  break;
													case DbType.Double  :  par.Value = Sql.ToDBFloat   (dictRow[sFieldName]);  break;
													case DbType.Decimal :  par.Value = Sql.ToDBDecimal (dictRow[sFieldName]);  break;
													case DbType.Byte    :  par.Value = Sql.ToDBBoolean (dictRow[sFieldName]);  break;
													case DbType.DateTime:  par.Value = Sql.ToDBDateTime(dictRow[sFieldName]);  break;
													default             :  par.Value = Sql.ToDBString  (dictRow[sFieldName]);  break;
												}
											}
										}
									}
									cmdUpdate.ExecuteNonQuery();
								}
							}
							trn.Commit();
						}
						catch(Exception ex)
						{
							trn.Rollback();
							throw(new Exception("Failed to update, transaction aborted; " + ex.Message, ex));
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}

		private Guid UpdateAdminTable(string sMODULE_NAME, string sTABLE_NAME, Dictionary<string, object> dict)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			Guid gID = Guid.Empty;
			try
			{
				// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
				Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
				TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
				// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
				bool bSaveDuplicate   = false;
				bool bSaveConcurrency = false;
				DateTime dtLAST_DATE_MODIFIED = DateTime.MinValue;
				DataTable dtUPDATE = new DataTable(sTABLE_NAME);
				foreach ( string sColumnName in dict.Keys )
				{
					// 03/16/2014 Paul.  Don't include Save Overrides as column names. 
					if ( sColumnName == "SaveDuplicate" )
						bSaveDuplicate = true;
					else if ( sColumnName == "SaveConcurrency" )
						bSaveConcurrency = true;
					else if ( sColumnName == "LAST_DATE_MODIFIED" )
					{
						// 04/01/2020 Paul.  Move json utils to RestUtil. 
						dtLAST_DATE_MODIFIED = T10n.ToServerTime(RestUtil.FromJsonDate(Sql.ToString(dict[sColumnName])));
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
						XmlDocument xml = new XmlDocument();
						xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
						xml.AppendChild(xml.CreateElement("Values"));
						if ( lst.Count > 0 )
						{
							foreach ( string item in lst )
							{
								XmlNode xValue = xml.CreateElement("Value");
								xml.DocumentElement.AppendChild(xValue);
								xValue.InnerText = item;
							}
						}
						row[sColumnName] = xml.OuterXml;
					}
					else if ( sColumnName != "SaveDuplicate" && sColumnName != "SaveConcurrency" && sColumnName != "LAST_DATE_MODIFIED" )
					{
						row[sColumnName] = dict[sColumnName];
					}
				}
				if ( Security.IsAuthenticated() )
				{
					string sCULTURE = Sql.ToString (Session["USER_SETTINGS/CULTURE"]);
					L10N   L10n     = new L10N(sCULTURE);
					Regex  r        = new Regex(@"[^A-Za-z0-9_]");
					sTABLE_NAME = r.Replace(sTABLE_NAME, "").ToUpper();
					
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL = String.Empty;
						bool   bHAS_CUSTOM  = Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".HasCustomTable"]);
						
						int nACLACCESS = SplendidCRM.Security.AdminUserAccess(sMODULE_NAME, "edit");
						// 11/11/2009 Paul.  First check if the user has access to this module. 
						if ( nACLACCESS >= 0 )
						{
							bool      bRecordExists              = false;
							bool      bAccessAllowed             = false;
							Guid      gLOCAL_ASSIGNED_USER_ID    = Guid.Empty;
							DataRow   rowCurrent                 = null;
							DataTable dtCurrent                  = new DataTable();
							
							// 02/22/2013 Paul.  Make sure the ID column exists before retrieving. It is optional. 
							if ( row.Table.Columns.Contains("ID") )
								gID = Sql.ToGuid(row["ID"]);
							if ( !Sql.IsEmptyGuid(gID) )
							{
								sSQL = "select *"              + ControlChars.CrLf
								     + "  from " + sTABLE_NAME + ControlChars.CrLf
								     + " where ID = @ID"       + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@ID", gID);
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
											if ( Sql.ToBoolean(HttpContext.Current.Application["CONFIG.enable_concurrency_check"])  && !bSaveConcurrency && dtLAST_DATE_MODIFIED != DateTime.MinValue && Sql.ToDateTime(rowCurrent["DATE_MODIFIED"]) > dtLAST_DATE_MODIFIED )
											{
												throw(new Exception(String.Format(L10n.Term(".ERR_CONCURRENCY_OVERRIDE"), dtLAST_DATE_MODIFIED) + ".ERR_CONCURRENCY_OVERRIDE"));
											}
											bRecordExists = true;
											bAccessAllowed = true;
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
													SplendidDynamic.UpdateCustomFields(row, trn, gID, sTABLE_NAME, dtCustomFields);
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
									// 10/26/2019 Paul.  If the config table update was successful, then upldate the cached value. 
									if ( sMODULE_NAME == "Config" )
									{
										string sNAME  = Sql.ToString(row["NAME"]);
										string sVALUE = Crm.Config.Value(sNAME);
										Application["CONFIG." + sNAME] = sVALUE;
										// 10/26/2019 Paul.  Clear React cache. 
										HttpRuntime.Cache.Remove("vwCONFIG.ReactClient");
										
										// 04/08/2021 Paul.  spCONFIG_Update does not have an ID parameter, so we must get the ID if this is a new setting. 
										if ( Sql.IsEmptyGuid(gID) )
										{
											sSQL = "select ID          " + ControlChars.CrLf
											     + "  from vwCONFIG    " + ControlChars.CrLf
											     + " where NAME = @NAME" + ControlChars.CrLf;
											using ( IDbCommand cmd = con.CreateCommand() )
											{
												cmd.CommandText = sSQL;
												Sql.AddParameter(cmd, "@NAME", sNAME);
												gID = Sql.ToGuid(cmd.ExecuteScalar());
											}
										}
										
										// 04/08/2021 Paul.  We need to duplicate the config management to match ASP.NET code. 
										// 10/10/2015 Paul.  Provide a way to disable streams.  When disabled, just remove the triggers and keep the data. 
										if ( String.Compare(sNAME, "enable_activity_streams") == 0 )
										{
											if ( Sql.ToBoolean(Application["CONFIG.enable_activity_streams"]) )
												SqlProcs.spSqlBuildAllStreamTriggers();
											else
												SqlProcs.spSqlDropAllStreamTriggers();
										}
										// 12/12/2017 Paul.  If the archive database changes, then rebuild the module settings. 
										if ( String.Compare(sNAME, "Archive.Database") == 0 )
										{
											SqlProcs.spSqlDropAllArchiveViews();
											SplendidInit.InitModules(HttpContext.Current);
										}
									}
								}
								else
								{
									throw(new Exception(L10n.Term("ACL.LBL_NO_ACCESS")));
								}
							}
						}
						else
						{
							throw(new Exception(L10n.Term("ACL.LBL_NO_ACCESS")));
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

		private void PreprocessAdminData(string sTABLE_NAME, Dictionary<string, object> dict)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			// 04/09/2019 Paul.  Error when saving a secured value when not changed. 
			if ( sTABLE_NAME == "CONFIG" )
			{
				if ( dict.ContainsKey("NAME") && dict.ContainsKey("VALUE") )
				{
					string sNAME  = Sql.ToString(dict["NAME" ]);
					string sVALUE = Sql.ToString(dict["VALUE"]);
					if ( sVALUE == Sql.sEMPTY_PASSWORD )
					{
						L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
						throw(new Exception(L10n.Term("Config.ERR_SECURED_VALUE_UNCHANGED")));
					}
					else if ( sNAME.EndsWith(".Encrypted") )
					{
						Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
						Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
						string sENCRYPTED_VALUE = Security.EncryptPassword(sVALUE, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						if ( Security.DecryptPassword(sENCRYPTED_VALUE, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sVALUE )
							throw(new Exception("Decryption failed"));
						sVALUE = sENCRYPTED_VALUE;
						dict["VALUE"] = sVALUE;
					}
				}
			}
			else if ( sTABLE_NAME == "INBOUND_EMAILS" )
			{
				if ( dict.ContainsKey("EMAIL_PASSWORD") )
				{
					string sVALUE = Sql.ToString(dict["EMAIL_PASSWORD"]);
					if ( !Sql.IsEmptyString(sVALUE) && sVALUE != Sql.sEMPTY_PASSWORD )
					{
						Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
						Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
						string sENCRYPTED_VALUE = Security.EncryptPassword(sVALUE, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						if ( Security.DecryptPassword(sENCRYPTED_VALUE, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sVALUE )
							throw(new Exception("Decryption failed"));
						sVALUE = sENCRYPTED_VALUE;
						dict["EMAIL_PASSWORD"] = sVALUE;
					}
				}
			}
			else if ( sTABLE_NAME == "OUTBOUND_EMAILS" )
			{
				if ( dict.ContainsKey("MAIL_SMTPPASS") )
				{
					string sVALUE = Sql.ToString(dict["MAIL_SMTPPASS"]);
					if ( !Sql.IsEmptyString(sVALUE) && sVALUE != Sql.sEMPTY_PASSWORD )
					{
						Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
						Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
						string sENCRYPTED_VALUE = Security.EncryptPassword(sVALUE, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						if ( Security.DecryptPassword(sENCRYPTED_VALUE, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sVALUE )
							throw(new Exception("Decryption failed"));
						sVALUE = sENCRYPTED_VALUE;
						dict["MAIL_SMTPPASS"] = sVALUE;
					}
				}
			}
			else if ( sTABLE_NAME == "USERS" )
			{
				if ( dict.ContainsKey("MAIL_SMTPPASS") )
				{
					string sVALUE = Sql.ToString(dict["MAIL_SMTPPASS"]);
					if ( !Sql.IsEmptyString(sVALUE) && sVALUE != Sql.sEMPTY_PASSWORD )
					{
						Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
						Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
						string sENCRYPTED_VALUE = Security.EncryptPassword(sVALUE, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						if ( Security.DecryptPassword(sENCRYPTED_VALUE, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sVALUE )
							throw(new Exception("Decryption failed"));
						sVALUE = sENCRYPTED_VALUE;
						dict["MAIL_SMTPPASS"] = sVALUE;
					}
				}
			}
			else if ( sTABLE_NAME == "CREDIT_CARDS" )
			{
				if ( dict.ContainsKey("CARD_NUMBER") )
				{
					string sCARD_NUMBER = Sql.ToString(dict["CARD_NUMBER"]);
					if ( !Sql.IsEmptyString(sCARD_NUMBER) && sCARD_NUMBER != Sql.sEMPTY_PASSWORD )
					{
						string sCARD_NUMBER_DISPLAY = "";
						// 04/09/2019 Paul.  We need to get the last 4 digits before the card number is encrypted. 
						if ( sCARD_NUMBER.Length > 4 )
							sCARD_NUMBER_DISPLAY = "****" + sCARD_NUMBER.Substring(sCARD_NUMBER.Length - 4, 4);
						else
							sCARD_NUMBER_DISPLAY = "****" + sCARD_NUMBER;
						dict["CARD_NUMBER_DISPLAY"] = sCARD_NUMBER_DISPLAY;
						
						Guid gCREDIT_CARD_KEY = Sql.ToGuid(Application["CONFIG.CreditCardKey"]);
						Guid gCREDIT_CARD_IV  = Sql.ToGuid(Application["CONFIG.CreditCardIV" ]);
						string sENCRYPTED_VALUE = Security.EncryptPassword(sCARD_NUMBER, gCREDIT_CARD_KEY, gCREDIT_CARD_IV);
						if ( Security.DecryptPassword(sENCRYPTED_VALUE, gCREDIT_CARD_KEY, gCREDIT_CARD_IV) != sCARD_NUMBER )
							throw(new Exception("Decryption failed"));
						sCARD_NUMBER = sENCRYPTED_VALUE;
						dict["CARD_NUMBER"] = sCARD_NUMBER;
					}
				}
			}
		}

		// 02/22/2021 Paul.  MassUpdateAdminModule is a simplified version of UpdateAdminModule. 
		[OperationContract]
		public void MassUpdateAdminModule(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState Session = HttpContext.Current.Session;
			
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

			string sModuleName = Sql.ToString(Request.QueryString["ModuleName"]);
			if ( Sql.IsEmptyString(sModuleName) )
				throw(new Exception("The module name must be specified."));
			// 08/22/2011 Paul.  Add admin control to REST API. 
			int nACLACCESS = Security.AdminUserAccess(sModuleName, "edit");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + sModuleName + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 09/06/2017 Paul.  Include module name in error. 
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + sModuleName));
			}
			// 11/16/2014 Paul.  We need to continually update the SplendidSession so that it expires along with the ASP.NET Session. 
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sTABLE_NAME = Sql.ToString(Application["Modules." + sModuleName + ".TableName"]);
			if ( Sql.IsEmptyString(sTABLE_NAME) )
				throw(new Exception("Unknown module: " + sModuleName));
			
			try
			{
				string   sCULTURE  = Sql.ToString (Session["USER_SETTINGS/CULTURE"]);
				L10N     L10n      = new L10N(sCULTURE);
				Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
				TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
				DataTable dtUPDATE = new DataTable(sTABLE_NAME);
				foreach ( string sColumnName in dict.Keys )
				{
					if ( sColumnName != "ID" && sColumnName != "ID_LIST")
					{
						// 01/20/2021 Paul.  We need to filter out empty or null values before SplendidDynamic.UpdateCustomFields() as there is no filter on empty fields in that method. 
						if ( dict[sColumnName] is System.Collections.ArrayList )
						{
							System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
							if ( lst.Count > 0 )
							{
								dtUPDATE.Columns.Add(sColumnName.ToUpper());
							}
						}
						else
						{
							if ( !Sql.IsEmptyString(dict[sColumnName]) )
							{
								dtUPDATE.Columns.Add(sColumnName.ToUpper());
							}
						}
					}
				}
				List<Guid> arrID_LIST = new List<Guid>();
				DataRow row = dtUPDATE.NewRow();
				dtUPDATE.Rows.Add(row);
				foreach ( string sColumnName in dict.Keys )
				{
					// 09/09/2011 Paul.  Multi-selection list boxes will come in as an ArrayList. 
					if ( dict[sColumnName] is System.Collections.ArrayList )
					{
						System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
						if ( sColumnName == "ID_LIST" )
						{
							if ( lst.Count > 0 )
							{
								foreach ( string item in lst )
								{
									arrID_LIST.Add(new Guid(item));
								}
							}
						}
						else
						{
							// 03/04/2016 Paul.  Line items will be included with Quotes, Orders and Invoices. 
							{
								XmlDocument xml = new XmlDocument();
								xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
								xml.AppendChild(xml.CreateElement("Values"));
								if ( lst.Count > 0 )
								{
									foreach ( string item in lst )
									{
										XmlNode xValue = xml.CreateElement("Value");
										xml.DocumentElement.AppendChild(xValue);
										xValue.InnerText = item;
									}
								}
								// 01/20/2021 Paul.  Column may not exist now that we filter empty. 
								if ( dtUPDATE.Columns.Contains(sColumnName) )
								{
									row[sColumnName] = xml.OuterXml;
								}
							}
						}
					}
					else if ( sColumnName != "ID" && sColumnName != "ID_LIST")
					{
						// 01/20/2021 Paul.  Column may not exist now that we filter empty. 
						if ( dtUPDATE.Columns.Contains(sColumnName) )
						{
							row[sColumnName] = dict[sColumnName];
						}
					}
				}
				
				if ( arrID_LIST.Count == 0 )
				{
					throw(new Exception(L10n.Term(".LBL_LISTVIEW_NO_SELECTED")));
				}
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false) )
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
							
							bool bEnableTeamManagement  = Crm.Config.enable_team_management();
							bool bRequireTeamManagement = Crm.Config.require_team_management();
							bool bRequireUserAssignment = Crm.Config.require_user_assignment();
							DataTable dtMetadata     = SplendidCache.SqlColumns(sTABLE_NAME);
							DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									IDbCommand cmdUpdate = null;
									cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update");
									cmdUpdate.Transaction = trn;
									// 02/13/2018 Paul.  Azure can timeout, so lets wait for an hour. 
									cmdUpdate.CommandTimeout = 60 * 60;
									foreach ( Guid gID in arrID_LIST )
									{
										bool      bRecordExists              = false;
										bool      bAccessAllowed             = false;
										Guid      gLOCAL_ASSIGNED_USER_ID    = Guid.Empty;
										DataRow   rowCurrent                 = null;
										DataTable dtCurrent                  = new DataTable();
										// 10/05/2020 Paul.  Must use view not table. 
										sSQL = "select *"              + ControlChars.CrLf
										     + "  from " + sVIEW_NAME  + ControlChars.CrLf
										     + " where 1 = 1"          + ControlChars.CrLf;
										using ( IDbCommand cmd = con.CreateCommand() )
										{
											cmd.CommandText = sSQL;
											cmd.Transaction = trn;
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
													bRecordExists = true;
													// 01/18/2010 Paul.  Apply ACL Field Security. 
													if ( dtCurrent.Columns.Contains("ASSIGNED_USER_ID") )
													{
														gLOCAL_ASSIGNED_USER_ID = Sql.ToGuid(rowCurrent["ASSIGNED_USER_ID"]);
													}
												}
											}
										}
										if ( bRecordExists )
										{
											// 07/17/2019 Paul.  Now perform a request to determine with access rights applied. 
											// 10/05/2020 Paul.  Must use view not table. 
											sSQL = "select count(*)"       + ControlChars.CrLf
											     + "  from " + sVIEW_NAME  + ControlChars.CrLf;
											using ( IDbCommand cmd = con.CreateCommand() )
											{
												cmd.CommandText = sSQL;
												cmd.Transaction = trn;
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
										if ( bRecordExists && bAccessAllowed )
										{
											// 10/05/2020 Paul.  We need to manually hande Replace/Add of users, teams and tags. 
											string sASSIGNED_SET_LIST = rowCurrent.Table.Columns.Contains("ASSIGNED_SET_LIST") ? Sql.ToString(rowCurrent["ASSIGNED_SET_LIST"]) : String.Empty;
											string sTEAM_SET_LIST     = rowCurrent.Table.Columns.Contains("TEAM_SET_LIST"    ) ? Sql.ToString(rowCurrent["TEAM_SET_LIST"    ]) : String.Empty;
											string sTAG_SET_NAME      = rowCurrent.Table.Columns.Contains("TAG_SET_NAME"     ) ? Sql.ToString(rowCurrent["TAG_SET_NAME"     ]) : String.Empty;
											string sNAICS_SET_NAME    = rowCurrent.Table.Columns.Contains("NAICS_SET_NAME"   ) ? Sql.ToString(rowCurrent["NAICS_SET_NAME"   ]) : String.Empty;
											if ( row.Table.Columns.Contains("ASSIGNED_SET_LIST") && !Sql.IsEmptyString(row["ASSIGNED_SET_LIST"]) )
											{
												if ( row.Table.Columns.Contains("ASSIGNED_SET_ADD") && Sql.ToBoolean(row["ASSIGNED_SET_ADD"]) )
												{
													if ( !Sql.IsEmptyString(sASSIGNED_SET_LIST) )
														sASSIGNED_SET_LIST += ",";
													sASSIGNED_SET_LIST += Sql.ToString(row["ASSIGNED_SET_LIST"]);
												}
												else
												{
													sASSIGNED_SET_LIST = Sql.ToString(row["ASSIGNED_SET_LIST"]);
												}
											}
											if ( row.Table.Columns.Contains("TEAM_SET_LIST") && !Sql.IsEmptyString(row["TEAM_SET_LIST"]) )
											{
												if ( row.Table.Columns.Contains("TEAM_SET_ADD") && Sql.ToBoolean(row["TEAM_SET_ADD"]) )
												{
													if ( !Sql.IsEmptyString(sTEAM_SET_LIST) )
														sTEAM_SET_LIST += ",";
													sTEAM_SET_LIST += Sql.ToString(row["TEAM_SET_LIST"]);
												}
												else
												{
													sTEAM_SET_LIST = Sql.ToString(row["TEAM_SET_LIST"]);
												}
											}
											if ( row.Table.Columns.Contains("TAG_SET_NAME") && !Sql.IsEmptyString(row["TAG_SET_NAME"]) )
											{
												if ( row.Table.Columns.Contains("TAG_SET_ADD") && Sql.ToBoolean(row["TAG_SET_ADD"]) )
												{
													if ( !Sql.IsEmptyString(sTAG_SET_NAME) )
														sTAG_SET_NAME += ",";
													sTAG_SET_NAME += Sql.ToString(row["TAG_SET_NAME"]);
												}
												else
												{
													sTAG_SET_NAME = Sql.ToString(row["TAG_SET_NAME"]);
												}
											}
											if ( row.Table.Columns.Contains("NAICS_SET_NAME") && !Sql.IsEmptyString(row["NAICS_SET_NAME"]) )
											{
												if ( row.Table.Columns.Contains("ADD_NAICS_CODE_SET") && Sql.ToBoolean(row["ADD_NAICS_CODE_SET"]) )
												{
													if ( !Sql.IsEmptyString(sNAICS_SET_NAME) )
														sNAICS_SET_NAME += ",";
													sNAICS_SET_NAME += Sql.ToString(row["NAICS_SET_NAME"]);
												}
												else
												{
													sNAICS_SET_NAME = Sql.ToString(row["NAICS_SET_NAME"]);
												}
											}

											// 07/17/2019 Paul.  We need to null all procedure parameters. 
											foreach(IDbDataParameter par in cmdUpdate.Parameters)
											{
												string sParameterName = Sql.ExtractDbName(cmdUpdate, par.ParameterName).ToUpper();
												if ( sParameterName == "ID" )
													par.Value = gID;
												// 10/09/2020 Paul.  Not sure why were were not setting modified user. 
												else if ( sParameterName == "MODIFIED_USER_ID" )
													par.Value = Sql.ToDBGuid(Security.USER_ID);
												else
													par.Value = DBNull.Value;
											}
											// 07/17/2019 Paul.  Now initialize values with current record values. 
											foreach ( DataColumn col in rowCurrent.Table.Columns )
											{
												IDbDataParameter par = Sql.FindParameter(cmdUpdate, col.ColumnName);
												// 11/26/2009 Paul.  The UTC modified date should be set to Now. 
												// 10/09/2020 Paul.  Not sure why were were not setting modified user. 
												if ( par != null && String.Compare(col.ColumnName, "MODIFIED_USER_ID", true) != 0 && String.Compare(col.ColumnName, "DATE_MODIFIED_UTC", true) != 0 )
													par.Value = rowCurrent[col.ColumnName];
											}
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
													// 10/05/2020 Paul.  Do not update values that are null. 
													if ( par != null && row[col.ColumnName] != null && row[col.ColumnName] != DBNull.Value && !Sql.IsEmptyString(row[col.ColumnName]) )
													{
														// 10/05/2020 Paul.  We need to manually hande Replace/Add of users, teams and tags. 
														if ( col.ColumnName == "ASSIGNED_SET_LIST" && !Sql.IsEmptyString(sASSIGNED_SET_LIST) )
														{
															par.Value = sASSIGNED_SET_LIST;
														}
														else if ( col.ColumnName == "TEAM_SET_LIST" && !Sql.IsEmptyString(sTEAM_SET_LIST) )
														{
															par.Value = sTEAM_SET_LIST;
														}
														else if ( col.ColumnName == "TAG_SET_NAME" && !Sql.IsEmptyString(sTAG_SET_NAME) )
														{
															par.Value = sTAG_SET_NAME;
														}
														else if ( col.ColumnName == "NAICS_SET_NAME" && !Sql.IsEmptyString(sNAICS_SET_NAME) )
														{
															par.Value = sNAICS_SET_NAME;
														}
														else
														{
															// 05/22/2017 Paul.  Shared function to convert from Json to DB. 
															// 04/01/2020 Paul.  Move json utils to RestUtil. 
															par.Value = RestUtil.DBValueFromJsonValue(par.DbType, row[col.ColumnName], T10n);
														}
													}
												}
											}
											// 02/13/2018 Paul.  We should be using ExecuteNonQuery instead of ExecuateScalar. 
											cmdUpdate.ExecuteNonQuery();
											if ( bHAS_CUSTOM )
											{
												SplendidDynamic.UpdateCustomFields(row, trn, gID, sTABLE_NAME, dtCustomFields);
											}
										}
										else
										{
											throw(new Exception(L10n.Term("ACL.LBL_NO_ACCESS")));
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
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}

		[OperationContract]
		public Guid UpdateAdminModule(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			try
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 03/09/2019 Paul.  Allow admin delegate to access admin api. 
				if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				SplendidSession.CreateSession(HttpContext.Current.Session);
				
				string sRequest = String.Empty;
				using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
				{
					sRequest = stmRequest.ReadToEnd();
				}
				JavaScriptSerializer json = new JavaScriptSerializer();
				json.MaxJsonLength = int.MaxValue;
				Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
				
				string sModuleName = Sql.ToString(Request.QueryString["ModuleName"]);
				string sTableName  = Sql.ToString(Application["Modules." + sModuleName + ".TableName"]);
				if ( !Sql.IsEmptyString(sModuleName) && !Sql.IsEmptyString(sTableName) && sTableName != "AUDIT_EVENTS" && sTableName != "USERS_LOGINS" && sTableName != "WORKFLOW_RUN" && !sTableName.StartsWith("SYSTEM_") )
				{
					bool bIsAdmin = Sql.ToBoolean(Application["Modules." + sModuleName + ".IsAdmin"]);
					if ( bIsAdmin && SplendidCRM.Security.AdminUserAccess(sModuleName, "edit") >= 0 )
					{
						PreprocessAdminData(sTableName, dict);
						Guid gID = UpdateAdminTable(sModuleName, sTableName, dict);
						return gID;
					}
					else
					{
						throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
					}
				}
				else
				{
					throw(new Exception("Unsupported table: " + sTableName));
				}
			}
			catch(Exception ex)
			{
				// 03/20/2019 Paul.  Catch and log all failures, including insufficient access. 
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}

		// 04/08/2019 Paul.  Config has security rules that may apply to other modules, such as Asterisk.* settings. 
		[OperationContract]
		public void UpdateAdminConfig(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			try
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 03/09/2019 Paul.  Allow admin delegate to access admin api. 
				if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				SplendidSession.CreateSession(HttpContext.Current.Session);
				
				string sRequest = String.Empty;
				using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
				{
					sRequest = stmRequest.ReadToEnd();
				}
				JavaScriptSerializer json = new JavaScriptSerializer();
				json.MaxJsonLength = int.MaxValue;
				Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
				
				// 04/08/2019 Paul.  First pass to validate access rights. 
				foreach ( string sKey in dict.Keys )
				{
					if ( sKey.Contains(".") )
					{
						string sModuleName = sKey.Split('.')[0];
						if ( Sql.ToBoolean(Application["Modules." + sModuleName + ".Valid"]) )
						{
							if ( SplendidCRM.Security.AdminUserAccess(sModuleName, "edit") < 0 )
							{
								throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + sKey));
							}
						}
					}
					else if ( !Security.IS_ADMIN )
					{
						throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + sKey));
					}
				}
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						try
						{
							// 04/08/2019 Paul.  Now update all settings in a single transaction. 
							foreach ( string sKey in dict.Keys )
							{
								string sValue = Sql.ToString(dict[sKey]);
								if ( !Sql.IsEmptyString(sValue) && sValue != Sql.sEMPTY_PASSWORD )
								{
									if ( sKey.EndsWith(".Encrypted")
									  || sKey == "Asterisk.Password"
									  || sKey == "Avaya.Password"
									  || sKey == "smtppass"
									  || sKey == "Exchange.Password"
									   )
									{
										Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
										Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
										string sENCRYPTED = Security.EncryptPassword(sValue, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
										if ( Security.DecryptPassword(sValue, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sValue )
											throw(new Exception("Decryption failed"));
										sValue = sENCRYPTED;
									}
									else if ( sKey == "AuthorizeNet.TransactionKey"
									       || sKey == "Pardot.ApiPassword"
									       || sKey == "PayTrace.Password"
									       || sKey == "SalesFusion.Password"
									        )
									{
										Guid gCREDIT_CARD_KEY = Sql.ToGuid(Application["CONFIG.CreditCardKey"]);
										Guid gCREDIT_CARD_IV  = Sql.ToGuid(Application["CONFIG.CreditCardIV" ]);
										string sENCRYPTED = Security.EncryptPassword(sValue, gCREDIT_CARD_KEY, gCREDIT_CARD_IV);
										if ( Security.DecryptPassword(sValue, gCREDIT_CARD_KEY, gCREDIT_CARD_IV) != sValue )
											throw(new Exception("Decryption failed"));
										sValue = sENCRYPTED;
									}
								}
								SqlProcs.spCONFIG_Update("System", sKey, sValue, trn);
							}
							trn.Commit();
							// 04/08/2019 Paul.  If successful, then update cached values. 
							foreach ( string sKey in dict.Keys )
							{
								string sValue = Sql.ToString(dict[sKey]);
								if ( sValue != Sql.sEMPTY_PASSWORD )
								{
									Application["CONFIG." + sKey] = sValue;
								}
							}
						}
						catch(Exception ex)
						{
							trn.Rollback();
							throw(new Exception("Failed to update, transaction aborted; " + ex.Message, ex));
						}
					}
				}
			}
			catch(Exception ex)
			{
				// 03/20/2019 Paul.  Catch and log all failures, including insufficient access. 
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}

		// 11/10/2020 Paul.  Admin needs ability to make a role primary. 
		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public void UserRoleMakeDefault(Guid USER_ID, Guid ROLE_ID)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			try
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 03/09/2019 Paul.  Allow admin delegate to access admin api. 
				if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				SplendidSession.CreateSession(HttpContext.Current.Session);
				
				SqlProcs.spUSERS_UpdatePrimaryRole(USER_ID, ROLE_ID);
			}
			catch(Exception ex)
			{
				// 03/20/2019 Paul.  Catch and log all failures, including insufficient access. 
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}

		// 11/25/2020 Paul.  We need a way to call a generic procedure.  Security is still managed through SYSTEM_REST_TABLES. 
		[OperationContract]
		public Stream AdminProcedure(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			try
			{
				L10N L10n = new L10N(Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
				if ( !Security.IsAuthenticated() || !(Security.IS_ADMIN || SplendidCRM.Security.IS_ADMIN_DELEGATE) )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				SplendidSession.CreateSession(HttpContext.Current.Session);
				
				string sRequest = String.Empty;
				using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
				{
					sRequest = stmRequest.ReadToEnd();
				}
				JavaScriptSerializer json = new JavaScriptSerializer();
				json.MaxJsonLength = int.MaxValue;
				Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
				
				string sProcedureName = Sql.ToString(Request.QueryString["ProcedureName"]);
				Guid     gTIMEZONE = Sql.ToGuid  (Session["USER_SETTINGS/TIMEZONE"]);
				TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
				DataTable dtUPDATE = new DataTable(sProcedureName);
				foreach ( string sColumnName in dict.Keys )
				{
					dtUPDATE.Columns.Add(sColumnName);
				}
				DataRow row = dtUPDATE.NewRow();
				dtUPDATE.Rows.Add(row);
				foreach ( string sColumnName in dict.Keys )
				{
					// 09/09/2011 Paul.  Multi-selection list boxes will come in as an ArrayList. 
					if ( dict[sColumnName] is System.Collections.ArrayList )
					{
						System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
						XmlDocument xml = new XmlDocument();
						xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
						xml.AppendChild(xml.CreateElement("Values"));
						if ( lst.Count > 0 )
						{
							foreach ( string item in lst )
							{
								XmlNode xValue = xml.CreateElement("Value");
								xml.DocumentElement.AppendChild(xValue);
								xValue.InnerText = item;
							}
						}
						row[sColumnName] = xml.OuterXml;
					}
					else
					{
						row[sColumnName] = dict[sColumnName];
					}
				}
				Dictionary<string, object> d = new Dictionary<string, object>();
				StringBuilder sbDumpSQL = new StringBuilder();
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( DataTable dtSYNC_TABLES = SplendidCache.RestProcedures(sProcedureName, false) )
				{
					string sSQL = String.Empty;
					if ( dtSYNC_TABLES != null && dtSYNC_TABLES.Rows.Count > 0 )
					{
						DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
						string sPROCEDURE_NAME       = Sql.ToString (rowSYNC_TABLE["TABLE_NAME"         ]);
						string sMODULE_NAME          = Sql.ToString (rowSYNC_TABLE["MODULE_NAME"        ]);
						string sREQUIRED_FIELDS      = Sql.ToString (rowSYNC_TABLE["REQUIRED_FIELDS"    ]);
						bool   bIS_SYSTEM            = Sql.ToBoolean(rowSYNC_TABLE["IS_SYSTEM"          ]);
						bool   bEnableTeamManagement = Crm.Config.enable_team_management();
						
						int nACLACCESS = SplendidCRM.Security.AdminUserAccess(sMODULE_NAME, "edit");
						if ( nACLACCESS >= 0 && bIS_SYSTEM )
						{
							if ( !Sql.IsEmptyString(sREQUIRED_FIELDS) )
							{
								// 07/05/2021 Paul.  Allow comma as separator. 
								string[] arrREQUIRED_FIELDS = sREQUIRED_FIELDS.ToUpper().Replace(",", " ").Split(' ');
								string sMISSING_FIELDS = String.Empty;
								foreach ( string sREQUIRED_FIELD in arrREQUIRED_FIELDS )
								{
									if ( !dtUPDATE.Columns.Contains(sREQUIRED_FIELD) )
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

							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								bool bEnableTransaction = true;
								// 09/09/2021 Paul.  Database backup cannot run in a transaction. 
								if ( sPROCEDURE_NAME == "spSqlBackupDatabase" )
									bEnableTransaction = false;
								if ( bEnableTransaction )
								{
									using ( IDbTransaction trn = Sql.BeginTransaction(con) )
									{
										try
										{
											IDbCommand cmd = SqlProcs.Factory(con, sPROCEDURE_NAME);
											cmd.Transaction = trn;
											foreach(IDbDataParameter par in cmd.Parameters)
											{
												// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
												string sParameterName = Sql.ExtractDbName(cmd, par.ParameterName).ToUpper();
												if ( sParameterName == "TEAM_ID" && bEnableTeamManagement )
													par.Value = Sql.ToDBGuid(Security.TEAM_ID);
												else if ( sParameterName == "ASSIGNED_USER_ID" )
													par.Value = Sql.ToDBGuid(Security.USER_ID);
												else if ( sParameterName == "MODIFIED_USER_ID" )
													par.Value = Sql.ToDBGuid(Security.USER_ID);
												else
													par.Value = DBNull.Value;
											}
											foreach ( DataColumn col in row.Table.Columns )
											{
												IDbDataParameter par = Sql.FindParameter(cmd, col.ColumnName);
												if ( par != null )
												{
													// 05/22/2017 Paul.  Shared function to convert from Json to DB. 
													par.Value = RestUtil.DBValueFromJsonValue(par.DbType, row[col.ColumnName], T10n);
												}
											}
											sbDumpSQL.Append(Sql.ExpandParameters(cmd));
											// 02/09/2008 Paul.  A database backup can take a long time.  Don't timeout. 
											if ( sPROCEDURE_NAME == "spSqlBackupDatabase" )
												cmd.CommandTimeout = 0;
											cmd.ExecuteNonQuery();
											trn.Commit();
											foreach(IDbDataParameter par in cmd.Parameters)
											{
												if ( par.Direction == ParameterDirection.InputOutput || par.Direction == ParameterDirection.Output )
												{
													string sParameterName = Sql.ExtractDbName(cmd, par.ParameterName).ToUpper();
													d.Add(sParameterName, par.Value);
												}
											}
											// 02/21/2021 Paul.  Special handling for languages. 
											if ( sProcedureName == "spLANGUAGES_Enable" )
											{
												// 12/22/2008 Paul.  Reload the terminology cache after enabling. 
												SplendidInit.InitTerminology(HttpContext.Current);
												SplendidCache.ClearLanguages();
											}
											else if ( sProcedureName == "spLANGUAGES_Disable" || sProcedureName == "spLANGUAGES_Delete" )
											{
												SplendidCache.ClearLanguages();
											}
											// 07/06/2021 Paul.  Provide an quick and easy way to enable/disable React client. 
											else if ( sProcedureName == "spMODULES_UpdateRelativePath" )
											{
												SplendidInit.InitModules(HttpContext.Current);
											}
										}
										catch
										{
											// 02/13/2017 Paul.  Capture this error as the following can generate an "This SqlTransaction has completed" error on Azure. 
											try
											{
												trn.Rollback();
											}
											catch
											{
											}
											throw;
										}
									}
								}
								else
								{
									IDbCommand cmd = SqlProcs.Factory(con, sPROCEDURE_NAME);
									foreach(IDbDataParameter par in cmd.Parameters)
									{
										// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
										string sParameterName = Sql.ExtractDbName(cmd, par.ParameterName).ToUpper();
										if ( sParameterName == "TEAM_ID" && bEnableTeamManagement )
											par.Value = Sql.ToDBGuid(Security.TEAM_ID);
										else if ( sParameterName == "ASSIGNED_USER_ID" )
											par.Value = Sql.ToDBGuid(Security.USER_ID);
										else if ( sParameterName == "MODIFIED_USER_ID" )
											par.Value = Sql.ToDBGuid(Security.USER_ID);
										else
											par.Value = DBNull.Value;
									}
									foreach ( DataColumn col in row.Table.Columns )
									{
										IDbDataParameter par = Sql.FindParameter(cmd, col.ColumnName);
										if ( par != null )
										{
											// 05/22/2017 Paul.  Shared function to convert from Json to DB. 
											par.Value = RestUtil.DBValueFromJsonValue(par.DbType, row[col.ColumnName], T10n);
										}
									}
									sbDumpSQL.Append(Sql.ExpandParameters(cmd));
									// 02/09/2008 Paul.  A database backup can take a long time.  Don't timeout. 
									if ( sPROCEDURE_NAME == "spSqlBackupDatabase" )
										cmd.CommandTimeout = 0;
									cmd.ExecuteNonQuery();
									foreach(IDbDataParameter par in cmd.Parameters)
									{
										if ( par.Direction == ParameterDirection.InputOutput || par.Direction == ParameterDirection.Output )
										{
											string sParameterName = Sql.ExtractDbName(cmd, par.ParameterName).ToUpper();
											d.Add(sParameterName, par.Value);
										}
									}
								}
							}
						}
						else
						{
							throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
						}
					}
				}
				
				Dictionary<string, object> dictResponse = new Dictionary<string, object>();
				dictResponse.Add("d", d);
				if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
				{
					dictResponse.Add("__sql", sbDumpSQL.ToString());
				}
				string sResponse = json.Serialize(dictResponse);
				byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
				return new MemoryStream(byResponse);
			}
			catch(Exception ex)
			{
				// 03/20/2019 Paul.  Catch and log all failures, including insufficient access. 
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}

		[OperationContract]
		public void UndeleteModule(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			// http://weblogs.asp.net/hajan/archive/2010/07/23/javascriptserializer-dictionary-to-json-serialization-and-deserialization.aspx
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);

			string sModuleName = "Undelete";
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || Security.AdminUserAccess(sModuleName, "edit") < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + sModuleName));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			try
			{
				string     sMODULE_NAME          = String.Empty;
				bool       bBACKGROUND_OPERATION = false;
				List<string> arrID_LIST          = new List<string>();
				foreach ( string sColumnName in dict.Keys )
				{
					switch ( sColumnName )
					{
						case "MODULE_NAME"         :  sMODULE_NAME          = Sql.ToString (dict[sColumnName]);  break;
						case "BACKGROUND_OPERATION":  bBACKGROUND_OPERATION = Sql.ToBoolean(dict[sColumnName]);  break;
					}
				}
				foreach ( string sColumnName in dict.Keys )
				{
					if ( dict[sColumnName] is System.Collections.ArrayList )
					{
						System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
						if ( sColumnName == "ID_LIST" )
						{
							if ( lst.Count > 0 )
							{
								foreach ( string item in lst )
								{
									arrID_LIST.Add(item);
								}
							}
						}
					}
				}
				if ( arrID_LIST.Count == 0 )
				{
					throw(new Exception(L10n.Term("Undelete.LBL_NOTHING_SELECTED")));
				}
				// 08/10/2013 Paul.  Perform a test lookup of the delete procedure.  An exception will be thrown if it does not exist. 
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sTABLE_NAME = Crm.Modules.TableName(sMODULE_NAME);
					// 08/07/2013 Paul.  Use the factory early so that the exception will be display to the user. 
					SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Undelete");
				}
				
				// 10/30/2021 Paul.  Move UndeleteModule to ModuleUtils. 
				ModuleUtils.UndeleteModule undelete = new ModuleUtils.UndeleteModule(Context, sMODULE_NAME, arrID_LIST.ToArray(), Security.USER_ID);
				if ( bBACKGROUND_OPERATION )
				{
					System.Threading.Thread t = new System.Threading.Thread(undelete.Start);
					t.Start();
				}
				else
				{
					undelete.Start();
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}

		#endregion

		#region Delete
		[OperationContract]
		public void DeleteAdminLayout(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sTableName = Sql.ToString(Request.QueryString["TableName"]);
			if ( Sql.IsEmptyString(sTableName) )
				throw(new Exception("The table name must be specified."));
			
			// 02/20/2016 Paul.  Module name is included in ViewName, or is blank when updating globals. 
			string sViewName = Sql.ToString(Request.QueryString["ViewName"]);
			if ( Sql.IsEmptyString(sViewName) && sTableName != "TERMINOLOGY" )
				throw(new Exception("The layout view name must be specified."));
			
			switch ( sTableName )
			{
				case "EDITVIEWS_FIELDS"         :  DeleteAdminLayoutTable("EDITVIEWS"  , "EDITVIEWS_FIELDS"  , "EDIT_NAME"  , sViewName);  SplendidCache.ClearEditView  (sViewName);  break;
				case "DETAILVIEWS_FIELDS"       :  DeleteAdminLayoutTable("DETAILVIEWS", "DETAILVIEWS_FIELDS", "DETAIL_NAME", sViewName);  SplendidCache.ClearDetailView(sViewName);  break;
				case "GRIDVIEWS_COLUMNS"        :  DeleteAdminLayoutTable("GRIDVIEWS"  , "GRIDVIEWS_COLUMNS" , "GRID_NAME"  , sViewName);  SplendidCache.ClearGridView  (sViewName);  break;
				default:  throw(new Exception("Unsupported table: " + sTableName));
			}
		}

		private void DeleteParentTable(DbProviderFactory dbf, IDbTransaction trn, string sTABLE_NAME, string sLAYOUT_NAME)
		{
			IDbConnection con = trn.Connection;
			IDbCommand cmdDelete = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Delete");
			cmdDelete.Transaction = trn;
			Sql.SetParameter(cmdDelete, "MODIFIED_USER_ID", Security.USER_ID);
			
			string sSQL = String.Empty;
			sSQL = "select ID"               + ControlChars.CrLf
			     + "  from vw" + sTABLE_NAME + ControlChars.CrLf
			     + " where NAME = @NAME"     + ControlChars.CrLf;
			using ( IDbCommand cmd = con.CreateCommand() )
			{
				cmd.CommandText = sSQL;
				cmd.Transaction = trn;
				Sql.AddParameter(cmd, "@NAME", sLAYOUT_NAME);
				using ( DbDataAdapter da = dbf.CreateDataAdapter() )
				{
					((IDbDataAdapter)da).SelectCommand = cmd;
					using ( DataTable dt = new DataTable() )
					{
						da.Fill(dt);
						foreach ( DataRow row in dt.Rows )
						{
							Guid gID = Sql.ToGuid(row["ID"]);
							Sql.SetParameter(cmdDelete, "ID", gID);
							cmdDelete.ExecuteNonQuery();
						}
					}
				}
			}
		}

		private void DeleteAdminLayoutTable(string sPARENT_TABLE, string sTABLE_NAME, string sLAYOUT_NAME_FIELD, string sVIEW_NAME)
		{
			HttpSessionState Session = HttpContext.Current.Session;
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						try
						{
							ClearLayoutTable(dbf, trn, sTABLE_NAME, sLAYOUT_NAME_FIELD, sVIEW_NAME);
							DeleteParentTable(dbf, trn, sPARENT_TABLE, sVIEW_NAME);
							trn.Commit();
						}
						catch(Exception ex)
						{
							trn.Rollback();
							throw(new Exception("Failed to update, transaction aborted; " + ex.Message, ex));
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}

		// 3.2 Method Tunneling through POST. 
		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public void DeleteAdminModuleItem(string ModuleName, Guid ID)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			if ( Sql.IsEmptyString(ModuleName) )
				throw(new Exception("The module name must be specified."));
			string sTABLE_NAME = Sql.ToString(Application["Modules." + ModuleName + ".TableName"]);
			if ( Sql.IsEmptyString(sTABLE_NAME) )
				throw(new Exception("Unknown module: " + ModuleName));
			// 08/22/2011 Paul.  Add admin control to REST API. 
			// 01/04/2020 Paul.  SplendidCache.RestTables() does not typically include entries for admin tables, so we use Security.AdminUserAccess(). 
			int nACLACCESS = Security.AdminUserAccess(ModuleName, "delete");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + ModuleName + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 09/06/2017 Paul.  Include module name in error. 
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(ModuleName)));
			}
			
			// 07/16/2019 Paul.  Add support for MassDelete. 
			Guid[] arrID_LIST = new Guid[1] { ID };
			DeleteAdminTableItems(ModuleName, sTABLE_NAME, arrID_LIST, false);
		}

		// 07/16/2019 Paul.  Add support for MassDelete. 
		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public void MassDeleteAdminModule(string ModuleName, Guid[] ID_LIST)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			if ( Sql.IsEmptyString(ModuleName) )
				throw(new Exception("The module name must be specified."));
			string sTABLE_NAME = Sql.ToString(Application["Modules." + ModuleName + ".TableName"]);
			if ( Sql.IsEmptyString(sTABLE_NAME) )
				throw(new Exception("Unknown module: " + ModuleName));
			// 01/04/2020 Paul.  SplendidCache.RestTables() does not typically include entries for admin tables, so we use Security.AdminUserAccess(). 
			int nACLACCESS = Security.AdminUserAccess(ModuleName, "delete");
			if ( !Security.IsAuthenticated() || !Sql.ToBoolean(Application["Modules." + ModuleName + ".RestEnabled"]) || nACLACCESS < 0 )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(ModuleName)));
			}
			
			DeleteAdminTableItems(ModuleName, sTABLE_NAME, ID_LIST, false);
		}

		// 07/16/2019 Paul.  Add support for MassDelete. 
		// 08/10/2020 Paul.  Separate method to delete recurrences. 
		private void DeleteAdminTableItems(string sMODULE_NAME, string sTABLE_NAME, Guid[] arrID_LIST, bool bDeleteRecurrences)
		{
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			try
			{
				if ( Security.IsAuthenticated() )
				{
					string sCULTURE = Sql.ToString (Session["USER_SETTINGS/CULTURE"]);
					L10N   L10n     = new L10N(sCULTURE);
					Regex  r        = new Regex(@"[^A-Za-z0-9_]");
					sTABLE_NAME = r.Replace(sTABLE_NAME, "").ToUpper();
					
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						// 06/03/2011 Paul.  Cache the Rest Table data. 
						// 11/26/2009 Paul.  System tables cannot be updated. 
						// 01/04/2020 Paul.  SplendidCache.RestTables() does not typically include entries for admin tables, so we use Security.AdminUserAccess(). 
						//using ( DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false) )
						{
							string sSQL = String.Empty;
							//if ( dtSYNC_TABLES != null && dtSYNC_TABLES.Rows.Count > 0 )
							{
								//DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
								//string sMODULE_NAME = Sql.ToString (rowSYNC_TABLE["MODULE_NAME"]);
								//string sVIEW_NAME   = Sql.ToString (rowSYNC_TABLE["VIEW_NAME"  ]);
								if ( Sql.IsEmptyString(sMODULE_NAME) )
								{
									throw(new Exception("sMODULE_NAME should not be empty for table " + sTABLE_NAME));
								}
								int nACLACCESS = SplendidCRM.Security.AdminUserAccess(sMODULE_NAME, "edit");
								// 11/11/2009 Paul.  First check if the user has access to this module. 
								if ( nACLACCESS >= 0 )
								{
									// 07/16/2019 Paul.  Add support for MassDelete. 
									using ( IDbTransaction trn = Sql.BeginTransaction(con) )
									{
										try
										{
											IDbCommand cmdDelete = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Delete");
											cmdDelete.Transaction = trn;
											foreach ( Guid gID in arrID_LIST )
											{
												bool      bRecordExists              = false;
												bool      bAccessAllowed             = false;
												Guid      gLOCAL_ASSIGNED_USER_ID    = Guid.Empty;
												DataRow   rowCurrent                 = null;
												DataTable dtCurrent                  = new DataTable();
												sSQL = "select *"              + ControlChars.CrLf
												     + "  from " + sTABLE_NAME + ControlChars.CrLf
												     + " where 1 = 1"          + ControlChars.CrLf;
												using ( IDbCommand cmd = con.CreateCommand() )
												{
													cmd.CommandText = sSQL;
													cmd.Transaction = trn;
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
															bRecordExists = true;
															// 01/18/2010 Paul.  Apply ACL Field Security. 
															if ( dtCurrent.Columns.Contains("ASSIGNED_USER_ID") )
															{
																gLOCAL_ASSIGNED_USER_ID = Sql.ToGuid(rowCurrent["ASSIGNED_USER_ID"]);
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
															cmd.Transaction = trn;
															Security.Filter(cmd, sMODULE_NAME, "delete");
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
													if ( bAccessAllowed )
													{
														// 07/16/2019 Paul.  Add support for MassDelete. 
														foreach(IDbDataParameter par in cmdDelete.Parameters)
														{
															string sParameterName = Sql.ExtractDbName(cmdDelete, par.ParameterName).ToUpper();
															if ( sParameterName == "ID" )
																par.Value = gID;
															else if ( sParameterName == "MODIFIED_USER_ID" )
																par.Value = Sql.ToDBGuid(Security.USER_ID);
															else
																par.Value = DBNull.Value;
														}
														cmdDelete.ExecuteScalar();
													}
													else
													{
														throw(new Exception(L10n.Term("ACL.LBL_NO_ACCESS")));
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
								}
								else
								{
									throw(new Exception(L10n.Term("ACL.LBL_NO_ACCESS")));
								}
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
		}

		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public void DeleteAdminEditCustomField(Guid ID)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			string ModuleName = "EditCustomFields";
			// 08/22/2011 Paul.  Add admin control to REST API. 
			// 01/04/2020 Paul.  SplendidCache.RestTables() does not typically include entries for admin tables, so we use Security.AdminUserAccess(). 
			int nACLACCESS = Security.AdminUserAccess(ModuleName, "delete");
			if ( !Security.IsAuthenticated() || nACLACCESS < 0 )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 09/06/2017 Paul.  Include module name in error. 
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(ModuleName)));
			}
			
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
				using ( IDbTransaction trn = Sql.BeginTransaction(con) )
				{
					try
					{
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.Transaction = trn;
							cmd.CommandType = CommandType.StoredProcedure;
							cmd.CommandText = "spFIELDS_META_DATA_Delete";
							// 07/18/2006 Paul.  Tripple the default timeout.  The operation was timing-out on QA machines and on the demo server. 
							// 02/03/2007 Paul.  Increase timeout to 5 minutes.  It should not take that long, but some users are reporting a timeout. 
							// 07/01/2008 Paul.  Let the function run forever. 
							// 04/18/2016 Paul.  Recompile in the background, then update the Semantic Model. 
							cmd.CommandTimeout = 0;
							IDbDataParameter parID               = Sql.AddParameter(cmd, "@ID"              , ID                 );
							IDbDataParameter parMODIFIED_USER_ID = Sql.AddParameter(cmd, "@MODIFIED_USER_ID",  Security.USER_ID  );
							IDbDataParameter parDISABLE_RECOMPILE= Sql.AddParameter(cmd, "@DISABLE_RECOMPILE", true              );
							cmd.ExecuteNonQuery();
						}
						trn.Commit();
					}
					catch(Exception ex)
					{
						trn.Rollback();
						throw(new Exception(ex.Message, ex.InnerException));
					}
				}
			}
			if ( Application["System.Recompile.Start"] == null )
			{
				// 10/31/2021 Paul.  Moved RecompileViews to ModuleUtils. 
				System.Threading.Thread t = new System.Threading.Thread(ModuleUtils.EditCustomFields.RecompileViews);
				t.Start(HttpContext.Current);
			}
			else
			{
				Application["System.Recompile.Restart"] = true;
			}
		}

		[OperationContract]
		public void InsertAdminEditCustomField(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			// 12/12/2014 Paul.  No reason to limit the Json result. 
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);

			string ModuleName = "EditCustomFields";
			// 08/22/2011 Paul.  Add admin control to REST API. 
			// 01/04/2020 Paul.  SplendidCache.RestTables() does not typically include entries for admin tables, so we use Security.AdminUserAccess(). 
			int nACLACCESS = Security.AdminUserAccess(ModuleName, "edit");
			if ( !Security.IsAuthenticated() || nACLACCESS < 0 )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 09/06/2017 Paul.  Include module name in error. 
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(ModuleName)));
			}
			
			string sNAME            = String.Empty;
			string sLABEL           = String.Empty;
			string sLABEL_TERM      = String.Empty;
			string sCUSTOM_MODULE   = String.Empty;
			string sDATA_TYPE       = String.Empty;
			Int32  nMAX_SIZE        = 0           ;
			bool   bREQUIRED        = false       ;
			bool   bAUDITED         = false       ;
			string sDEFAULT_VALUE   = String.Empty;
			string sDROPDOWN_LIST   = String.Empty;
			bool   bMASS_UPDATE     = false       ;
			foreach ( string sName in dict.Keys )
			{
				switch ( sName )
				{
					case "NAME"          :  sNAME           = Sql.ToString (dict[sName]);  break;
					case "LABEL"         :  sLABEL          = Sql.ToString (dict[sName]);  break;
					case "CUSTOM_MODULE" :  sCUSTOM_MODULE  = Sql.ToString (dict[sName]);  break;
					case "DATA_TYPE"     :  sDATA_TYPE      = Sql.ToString (dict[sName]);  break;
					case "MAX_SIZE"      :  nMAX_SIZE       = Sql.ToInteger(dict[sName]);  break;
					case "REQUIRED"      :  bREQUIRED       = Sql.ToBoolean(dict[sName]);  break;
					case "AUDITED"       :  bAUDITED        = Sql.ToBoolean(dict[sName]);  break;
					case "DEFAULT_VALUE" :  sDEFAULT_VALUE  = Sql.ToString (dict[sName]);  break;
					case "DROPDOWN_LIST" :  sDROPDOWN_LIST  = Sql.ToString (dict[sName]);  break;
					case "MASS_UPDATE"   :  bMASS_UPDATE    = Sql.ToBoolean(dict[sName]);  break;
				}
			}
			sNAME  = sNAME .Trim();
			sLABEL = sLABEL.Trim();
			if ( Sql.IsEmptyString(sCUSTOM_MODULE) )
			{
				throw(new Exception("The module name must be specified."));
			}
			string sTABLE_NAME = Sql.ToString (Application["Modules." + sCUSTOM_MODULE + ".TableName"]);
			bool   bValid      = Sql.ToBoolean(Application["Modules." + sCUSTOM_MODULE + ".Valid"]);
			if ( Sql.IsEmptyString(sTABLE_NAME) && !bValid )
			{
				throw(new Exception("Unknown module: " + sCUSTOM_MODULE));
			}
			if ( Sql.IsEmptyString(sNAME) )
			{
				throw(new Exception("The field name must be specified."));
			}
			if ( Sql.IsEmptyString(sLABEL) )
				sLABEL = sNAME;
			Regex r = new Regex(@"[^\w]+");
			sNAME = r.Replace(sNAME, "_");
			r = new Regex(@"^[A-Za-z_]\w*");
			if ( !r.IsMatch(sNAME) )
			{
				throw(new Exception("invalid field name"));
			}

			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
				using ( IDbTransaction trn = Sql.BeginTransaction(con) )
				{
					try
					{
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.Transaction = trn;
							cmd.CommandType = CommandType.StoredProcedure;
							cmd.CommandText = "spFIELDS_META_DATA_Insert";
							// 07/18/2006 Paul.  Tripple the default timeout.  The operation was timing-out on QA machines and on the demo server. 
							// 02/03/2007 Paul.  Increase timeout to 5 minutes.  It should not take that long, but some users are reporting a timeout. 
							// 07/01/2008 Paul.  Let the function run forever. 
							// 03/11/2016 Paul.  Allow disable recompile so that we can do in the background. 
							cmd.CommandTimeout = 0;
							IDbDataParameter parID               = Sql.AddParameter(cmd, "@ID"              , Guid.Empty         );
							IDbDataParameter parMODIFIED_USER_ID = Sql.AddParameter(cmd, "@MODIFIED_USER_ID",  Security.USER_ID  );
							IDbDataParameter parNAME             = Sql.AddParameter(cmd, "@NAME"            , sNAME              , 255);
							IDbDataParameter parLABEL            = Sql.AddParameter(cmd, "@LABEL"           , sLABEL             , 255);
							IDbDataParameter parLABEL_TERM       = Sql.AddParameter(cmd, "@LABEL_TERM"      , sLABEL_TERM        , 255);
							IDbDataParameter parCUSTOM_MODULE    = Sql.AddParameter(cmd, "@CUSTOM_MODULE"   , sCUSTOM_MODULE     , 255);
							IDbDataParameter parDATA_TYPE        = Sql.AddParameter(cmd, "@DATA_TYPE"       , sDATA_TYPE         , 255);
							IDbDataParameter parMAX_SIZE         = Sql.AddParameter(cmd, "@MAX_SIZE"        , nMAX_SIZE          );
							IDbDataParameter parREQUIRED         = Sql.AddParameter(cmd, "@REQUIRED"        , bREQUIRED          );
							IDbDataParameter parAUDITED          = Sql.AddParameter(cmd, "@AUDITED"         , bAUDITED           );
							IDbDataParameter parDEFAULT_VALUE    = Sql.AddParameter(cmd, "@DEFAULT_VALUE"   , sDEFAULT_VALUE     , 255);
							IDbDataParameter parDROPDOWN_LIST    = Sql.AddParameter(cmd, "@DROPDOWN_LIST"   , sDROPDOWN_LIST     ,  50);
							IDbDataParameter parMASS_UPDATE      = Sql.AddParameter(cmd, "@MASS_UPDATE"     , bMASS_UPDATE       );
							IDbDataParameter parDISABLE_RECOMPILE= Sql.AddParameter(cmd, "@DISABLE_RECOMPILE", true              );
							parID.Direction = ParameterDirection.InputOutput;
							cmd.ExecuteNonQuery();
						}
						trn.Commit();
					}
					catch(Exception ex)
					{
						trn.Rollback();
						throw(new Exception(ex.Message, ex.InnerException));
					}
				}
			}
			if ( Application["System.Recompile.Start"] == null )
			{
				// 10/31/2021 Paul.  Moved RecompileViews to ModuleUtils. 
				System.Threading.Thread t = new System.Threading.Thread(ModuleUtils.EditCustomFields.RecompileViews);
				t.Start(HttpContext.Current);
			}
			else
			{
				Application["System.Recompile.Restart"] = true;
			}
		}

		[OperationContract]
		public void UpdateAdminEditCustomField(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			// 12/12/2014 Paul.  No reason to limit the Json result. 
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);

			string ModuleName = "EditCustomFields";
			// 08/22/2011 Paul.  Add admin control to REST API. 
			// 01/04/2020 Paul.  SplendidCache.RestTables() does not typically include entries for admin tables, so we use Security.AdminUserAccess(). 
			int nACLACCESS = Security.AdminUserAccess(ModuleName, "edit");
			if ( !Security.IsAuthenticated() || nACLACCESS < 0 )
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 09/06/2017 Paul.  Include module name in error. 
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS") + ": " + Sql.ToString(ModuleName)));
			}
			Guid   gID              = Guid.Empty;
			Int32  nMAX_SIZE        = 0           ;
			bool   bREQUIRED        = false       ;
			bool   bAUDITED         = false       ;
			string sDEFAULT_VALUE   = String.Empty;
			string sDROPDOWN_LIST   = String.Empty;
			bool   bMASS_UPDATE     = false       ;
			foreach ( string sName in dict.Keys )
			{
				switch ( sName )
				{
					case "ID"            :  gID             = Sql.ToGuid   (dict[sName]);  break;
					case "MAX_SIZE"      :  nMAX_SIZE       = Sql.ToInteger(dict[sName]);  break;
					case "REQUIRED"      :  bREQUIRED       = Sql.ToBoolean(dict[sName]);  break;
					case "AUDITED"       :  bAUDITED        = Sql.ToBoolean(dict[sName]);  break;
					case "DEFAULT_VALUE" :  sDEFAULT_VALUE  = Sql.ToString (dict[sName]);  break;
					case "DROPDOWN_LIST" :  sDROPDOWN_LIST  = Sql.ToString (dict[sName]);  break;
					case "MASS_UPDATE"   :  bMASS_UPDATE    = Sql.ToBoolean(dict[sName]);  break;
				}
			}
			if ( Sql.IsEmptyGuid(gID) )
			{
				throw(new Exception("The ID must be specified."));
			}
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
				using ( IDbTransaction trn = Sql.BeginTransaction(con) )
				{
					try
					{
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.Transaction = trn;
							cmd.CommandType = CommandType.StoredProcedure;
							cmd.CommandText = "spFIELDS_META_DATA_Update";
							// 01/06/2006 Paul.  Tripple the default timeout.  The operation was timing-out on QA machines and on the demo server. 
							// 02/03/2007 Paul.  Increase timeout to 5 minutes.  It should not take that long, but some users are reporting a timeout. 
							// 07/01/2008 Paul.  Let the function run forever. 
							// 04/18/2016 Paul.  Recompile in the background, then update the Semantic Model. 
							cmd.CommandTimeout = 0;
							IDbDataParameter parID               = Sql.AddParameter(cmd, "@ID"              , gID                );
							IDbDataParameter parMODIFIED_USER_ID = Sql.AddParameter(cmd, "@MODIFIED_USER_ID",  Security.USER_ID  );
							IDbDataParameter parMAX_SIZE         = Sql.AddParameter(cmd, "@MAX_SIZE"        , nMAX_SIZE          );
							IDbDataParameter parREQUIRED         = Sql.AddParameter(cmd, "@REQUIRED"        , bREQUIRED          );
							IDbDataParameter parAUDITED          = Sql.AddParameter(cmd, "@AUDITED"         , bAUDITED           );
							IDbDataParameter parDEFAULT_VALUE    = Sql.AddParameter(cmd, "@DEFAULT_VALUE"   , sDEFAULT_VALUE     , 255);
							// 01/10/2007 Paul.  DROPDOWN_LIST was added as it can be modified. 
							IDbDataParameter parDROPDOWN_LIST    = Sql.AddParameter(cmd, "@DROPDOWN_LIST"   , sDROPDOWN_LIST     ,  50);
							IDbDataParameter parMASS_UPDATE      = Sql.AddParameter(cmd, "@MASS_UPDATE"     , bMASS_UPDATE       );
							IDbDataParameter parDISABLE_RECOMPILE= Sql.AddParameter(cmd, "@DISABLE_RECOMPILE", true              );
							cmd.ExecuteNonQuery();
						}
						trn.Commit();
					}
					catch(Exception ex)
					{
						trn.Rollback();
						throw(new Exception(ex.Message, ex.InnerException));
					}
				}
			}
			if ( Application["System.Recompile.Start"] == null )
			{
				// 10/31/2021 Paul.  Moved RecompileViews to ModuleUtils. 
				System.Threading.Thread t = new System.Threading.Thread(ModuleUtils.EditCustomFields.RecompileViews);
				t.Start(HttpContext.Current);
			}
			else
			{
				Application["System.Recompile.Restart"] = true;
			}
		}

		#endregion

		#region ACL Access
		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAclAccessByUser(Guid USER_ID)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			// 07/05/2020 Paul.  Allow yourself to access ACL. 
			if ( !Security.IsAuthenticated() || !(Security.AdminUserAccess("Users", "view") >= 0 || USER_ID == Security.USER_ID) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			StringBuilder sbDumpSQL = new StringBuilder();
			DataTable dt = new DataTable();
			Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
			long lTotalCount = 0;
			bool bIS_ADMIN_DELEGATE = false;
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 03/09/2010 Paul.  Admin roles are managed separately. 
				// 09/26/2017 Paul.  Add Archive access right. 
				sSQL = "select MODULE_NAME          " + ControlChars.CrLf
				     + "     , DISPLAY_NAME         " + ControlChars.CrLf
				     + "     , ACLACCESS_ADMIN      " + ControlChars.CrLf
				     + "     , ACLACCESS_ACCESS     " + ControlChars.CrLf
				     + "     , ACLACCESS_VIEW       " + ControlChars.CrLf
				     + "     , ACLACCESS_LIST       " + ControlChars.CrLf
				     + "     , ACLACCESS_EDIT       " + ControlChars.CrLf
				     + "     , ACLACCESS_DELETE     " + ControlChars.CrLf
				     + "     , ACLACCESS_IMPORT     " + ControlChars.CrLf
				     + "     , ACLACCESS_EXPORT     " + ControlChars.CrLf
				     + "     , ACLACCESS_ARCHIVE    " + ControlChars.CrLf
				     + "     , IS_ADMIN             " + ControlChars.CrLf
				     + "  from vwACL_ACCESS_ByUser  " + ControlChars.CrLf
				     + " where USER_ID = @USER_ID   " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@USER_ID", USER_ID);
					// 05/29/2020 Paul.  An admin can get any user, but otherwise, filter by self. 
					if ( SplendidCRM.Security.AdminUserAccess("Users", "edit") < 0 )
					{
						Sql.AppendParameter(cmd, Security.USER_ID, "USER_ID");
					}
					cmd.CommandText += " order by MODULE_NAME" + ControlChars.CrLf;

					sbDumpSQL.Append(Sql.ExpandParameters(cmd));
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						da.Fill(dt);
					}
				}
				if ( Sql.ToBoolean(Application["CONFIG.allow_admin_roles"]) && SplendidCRM.Security.AdminUserAccess("Users", "view") >= 0 )
				{
					sSQL = "select IS_ADMIN_DELEGATE" + ControlChars.CrLf
					     + "  from vwUSERS          " + ControlChars.CrLf
					     + " where ID = @USER_ID    " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@USER_ID", USER_ID);
						bIS_ADMIN_DELEGATE = Sql.ToBoolean(cmd.ExecuteScalar());
					}
				}
			}

			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, dt, T10n);
			dictResponse.Add("__total", lTotalCount);
			dictResponse.Add("IS_ADMIN_DELEGATE", bIS_ADMIN_DELEGATE);
			// 10/26/2019 Paul.  Return the SQL to the React Client. 
			if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
			{
				dictResponse.Add("__sql", sbDumpSQL.ToString());
			}
			
			JavaScriptSerializer json = new JavaScriptSerializer();
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAclAccessByRole(Guid ROLE_ID)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			if ( !Security.IsAuthenticated() || !(Security.AdminUserAccess("ACLRoles", "view") >= 0 || Security.AdminUserAccess("ACLRoles", "edit") >= 0) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			StringBuilder sbDumpSQL = new StringBuilder();
			DataTable dt = new DataTable();
			Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
			long lTotalCount = 0;
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 03/09/2010 Paul.  Admin roles are managed separately. 
				// 09/26/2017 Paul.  Add Archive access right. 
				sSQL = "select MODULE_NAME          " + ControlChars.CrLf
				     + "     , DISPLAY_NAME         " + ControlChars.CrLf
				     + "     , ACLACCESS_ADMIN      " + ControlChars.CrLf
				     + "     , ACLACCESS_ACCESS     " + ControlChars.CrLf
				     + "     , ACLACCESS_VIEW       " + ControlChars.CrLf
				     + "     , ACLACCESS_LIST       " + ControlChars.CrLf
				     + "     , ACLACCESS_EDIT       " + ControlChars.CrLf
				     + "     , ACLACCESS_DELETE     " + ControlChars.CrLf
				     + "     , ACLACCESS_IMPORT     " + ControlChars.CrLf
				     + "     , ACLACCESS_EXPORT     " + ControlChars.CrLf
				     + "     , ACLACCESS_ARCHIVE    " + ControlChars.CrLf
				     + "     , IS_ADMIN             " + ControlChars.CrLf
				     + "  from vwACL_ACCESS_ByRole  " + ControlChars.CrLf
				     + " where ROLE_ID = @ROLE_ID   " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@ROLE_ID", ROLE_ID);
					cmd.CommandText += " order by MODULE_NAME" + ControlChars.CrLf;

					sbDumpSQL.Append(Sql.ExpandParameters(cmd));
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						da.Fill(dt);
					}
				}
			}

			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, dt, T10n);
			dictResponse.Add("__total", lTotalCount);
			// 10/26/2019 Paul.  Return the SQL to the React Client. 
			if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
			{
				dictResponse.Add("__sql", sbDumpSQL.ToString());
			}
			
			JavaScriptSerializer json = new JavaScriptSerializer();
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAclAccessByModule()
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			if ( !Security.IsAuthenticated() || !(Security.AdminUserAccess("ACLRoles", "view") >= 0 || Security.AdminUserAccess("ACLRoles", "edit") >= 0) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			StringBuilder sbDumpSQL = new StringBuilder();
			DataTable dt = new DataTable();
			Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
			long lTotalCount = 0;
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 03/09/2010 Paul.  Admin roles are managed separately. 
				// 09/26/2017 Paul.  Add Archive access right. 
				sSQL = "select MODULE_NAME          " + ControlChars.CrLf
				     + "     , DISPLAY_NAME         " + ControlChars.CrLf
				     + "     , ACLACCESS_ADMIN      " + ControlChars.CrLf
				     + "     , ACLACCESS_ACCESS     " + ControlChars.CrLf
				     + "     , ACLACCESS_VIEW       " + ControlChars.CrLf
				     + "     , ACLACCESS_LIST       " + ControlChars.CrLf
				     + "     , ACLACCESS_EDIT       " + ControlChars.CrLf
				     + "     , ACLACCESS_DELETE     " + ControlChars.CrLf
				     + "     , ACLACCESS_IMPORT     " + ControlChars.CrLf
				     + "     , ACLACCESS_EXPORT     " + ControlChars.CrLf
				     + "     , ACLACCESS_ARCHIVE    " + ControlChars.CrLf
				     + "     , IS_ADMIN             " + ControlChars.CrLf
				     + "  from vwACL_ACCESS_ByModule" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					cmd.CommandText += " order by MODULE_NAME" + ControlChars.CrLf;

					sbDumpSQL.Append(Sql.ExpandParameters(cmd));
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						da.Fill(dt);
					}
				}
			}

			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, dt, T10n);
			dictResponse.Add("__total", lTotalCount);
			// 10/26/2019 Paul.  Return the SQL to the React Client. 
			if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
			{
				dictResponse.Add("__sql", sbDumpSQL.ToString());
			}
			
			JavaScriptSerializer json = new JavaScriptSerializer();
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		[OperationContract]
		public Guid UpdateAclAccess(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

			Guid gID = Guid.Empty;
			try
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				if ( !Security.IsAuthenticated() || (Security.AdminUserAccess("ACLRoles", "edit") < 0) )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				SplendidSession.CreateSession(HttpContext.Current.Session);
				
				string sRequest = String.Empty;
				using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
				{
					sRequest = stmRequest.ReadToEnd();
				}
				JavaScriptSerializer json = new JavaScriptSerializer();
				json.MaxJsonLength = int.MaxValue;
				Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
				
				// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
				Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
				TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
				// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
				bool bSaveDuplicate   = false;
				bool bSaveConcurrency = false;
				DateTime dtLAST_DATE_MODIFIED = DateTime.MinValue;
				DataTable dtUPDATE = new DataTable("ACL_ROLES");
				foreach ( string sColumnName in dict.Keys )
				{
					// 03/16/2014 Paul.  Don't include Save Overrides as column names. 
					if ( sColumnName == "SaveDuplicate" )
						bSaveDuplicate = true;
					else if ( sColumnName == "SaveConcurrency" )
						bSaveConcurrency = true;
					else if ( sColumnName == "LAST_DATE_MODIFIED" )
					{
						// 04/01/2020 Paul.  Move json utils to RestUtil. 
						dtLAST_DATE_MODIFIED = T10n.ToServerTime(RestUtil.FromJsonDate(Sql.ToString(dict[sColumnName])));
					}
					else if ( sColumnName != "AccessRights" )
					{
						dtUPDATE.Columns.Add(sColumnName);
					}
				}
				DataRow row = dtUPDATE.NewRow();
				dtUPDATE.Rows.Add(row);
				foreach ( string sColumnName in dict.Keys )
				{
					if ( sColumnName == "AccessRights" )
					{
						continue;
					}
					// 09/09/2011 Paul.  Multi-selection list boxes will come in as an ArrayList. 
					else if ( dict[sColumnName] is System.Collections.ArrayList )
					{
						System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
						XmlDocument xml = new XmlDocument();
						xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
						xml.AppendChild(xml.CreateElement("Values"));
						if ( lst.Count > 0 )
						{
							foreach ( string item in lst )
							{
								XmlNode xValue = xml.CreateElement("Value");
								xml.DocumentElement.AppendChild(xValue);
								xValue.InnerText = item;
							}
						}
						row[sColumnName] = xml.OuterXml;
					}
					else if ( sColumnName != "SaveDuplicate" && sColumnName != "SaveConcurrency" && sColumnName != "LAST_DATE_MODIFIED" )
					{
						row[sColumnName] = dict[sColumnName];
					}
				}
				
				string sTABLE_NAME  = "ACL_ROLES";
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL = String.Empty;
					bool   bHAS_CUSTOM  = Sql.ToBoolean(Application["Modules.ACLRoles.HasCustomTable"]);
					
					bool      bRecordExists              = false;
					bool      bAccessAllowed             = false;
					Guid      gLOCAL_ASSIGNED_USER_ID    = Guid.Empty;
					DataRow   rowCurrent                 = null;
					DataTable dtCurrent                  = new DataTable();
					
					// 02/22/2013 Paul.  Make sure the ID column exists before retrieving. It is optional. 
					if ( row.Table.Columns.Contains("ID") )
						gID = Sql.ToGuid(row["ID"]);
					if ( !Sql.IsEmptyGuid(gID) )
					{
						sSQL = "select *"              + ControlChars.CrLf
						     + "  from " + sTABLE_NAME + ControlChars.CrLf
						     + " where ID = @ID"       + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", gID);
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
									if ( Sql.ToBoolean(HttpContext.Current.Application["CONFIG.enable_concurrency_check"])  && !bSaveConcurrency && dtLAST_DATE_MODIFIED != DateTime.MinValue && Sql.ToDateTime(rowCurrent["DATE_MODIFIED"]) > dtLAST_DATE_MODIFIED )
									{
										throw(new Exception(String.Format(L10n.Term(".ERR_CONCURRENCY_OVERRIDE"), dtLAST_DATE_MODIFIED) + ".ERR_CONCURRENCY_OVERRIDE"));
									}
									bRecordExists = true;
									bAccessAllowed = true;
									// 01/18/2010 Paul.  Apply ACL Field Security. 
									if ( dtCurrent.Columns.Contains("ASSIGNED_USER_ID") )
									{
										gLOCAL_ASSIGNED_USER_ID = Sql.ToGuid(rowCurrent["ASSIGNED_USER_ID"]);
									}
								}
							}
						}
					}
					DataTable dtACLACCESS = new DataTable();
					sSQL = "select MODULE_NAME          " + ControlChars.CrLf
					     + "     , DISPLAY_NAME         " + ControlChars.CrLf
					     + "     , ACLACCESS_ADMIN      " + ControlChars.CrLf
					     + "     , ACLACCESS_ACCESS     " + ControlChars.CrLf
					     + "     , ACLACCESS_VIEW       " + ControlChars.CrLf
					     + "     , ACLACCESS_LIST       " + ControlChars.CrLf
					     + "     , ACLACCESS_EDIT       " + ControlChars.CrLf
					     + "     , ACLACCESS_DELETE     " + ControlChars.CrLf
					     + "     , ACLACCESS_IMPORT     " + ControlChars.CrLf
					     + "     , ACLACCESS_EXPORT     " + ControlChars.CrLf
					     + "     , ACLACCESS_ARCHIVE    " + ControlChars.CrLf
					     + "     , IS_ADMIN             " + ControlChars.CrLf
					     + "  from vwACL_ACCESS_ByModule" + ControlChars.CrLf
					     + " order by MODULE_NAME       " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtACLACCESS);
						}
					}
					if ( !bRecordExists || bAccessAllowed )
					{
						// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
						bool bDUPLICATE_CHECHING_ENABLED = Sql.ToBoolean(Application["CONFIG.enable_duplicate_check"]) && Sql.ToBoolean(Application["Modules.ACLRoles.DuplicateCheckingEnabled"]) && !bSaveDuplicate;
						if ( bDUPLICATE_CHECHING_ENABLED )
						{
							if ( Utils.DuplicateCheck(Application, con, "ACLRoles", gID, row, rowCurrent) > 0 )
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
								IDbCommand cmdUpdate = SqlProcs.Factory(con, "spACL_ROLES_Update");
								cmdUpdate.Transaction = trn;
								foreach(IDbDataParameter par in cmdUpdate.Parameters)
								{
									string sParameterName = Sql.ExtractDbName(cmdUpdate, par.ParameterName).ToUpper();
									par.Value = DBNull.Value;
								}
								if ( bRecordExists )
								{
									foreach ( DataColumn col in rowCurrent.Table.Columns )
									{
										IDbDataParameter par = Sql.FindParameter(cmdUpdate, col.ColumnName);
										if ( par != null && String.Compare(col.ColumnName, "DATE_MODIFIED_UTC", true) != 0 && String.Compare(col.ColumnName, "MODIFIED_USER_ID", true) != 0 )
											par.Value = rowCurrent[col.ColumnName];
									}
								}
								foreach ( DataColumn col in row.Table.Columns )
								{
									IDbDataParameter par = Sql.FindParameter(cmdUpdate, col.ColumnName);
									if ( par != null )
									{
										par.Value = RestUtil.DBValueFromJsonValue(par.DbType, row[col.ColumnName], T10n);
									}
								}
								cmdUpdate.CommandTimeout = 60 * 60;
								cmdUpdate.ExecuteNonQuery();
								IDbDataParameter parID = Sql.FindParameter(cmdUpdate, "@ID");
								if ( parID != null )
								{
									gID = Sql.ToGuid(parID.Value);
									if ( bHAS_CUSTOM )
									{
										DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
										SplendidDynamic.UpdateCustomFields(row, trn, gID, sTABLE_NAME, dtCustomFields);
									}
									if ( dict.ContainsKey("AccessRights") )
									{
										DataView vwMain = new DataView(dtACLACCESS);
										System.Collections.ArrayList lst = dict["AccessRights"] as System.Collections.ArrayList;
										for ( int i = 0; i < lst.Count; i++ )
										{
											Dictionary<string, object> right = lst[i] as Dictionary<string, object>;
											string sMODULE_NAME = Sql.ToString(right["MODULE_NAME"]);
											
											// 03/09/2010 Paul.  Admin roles are managed separately. 
											vwMain.RowFilter = "IS_ADMIN = 0 and MODULE_NAME <> 'Teams'";
											if ( vwMain.Count > 0 )
											{
												Guid gActionAccessID = Guid.Empty;
												Guid gActionViewID   = Guid.Empty;
												Guid gActionListID   = Guid.Empty;
												Guid gActionEditID   = Guid.Empty;
												Guid gActionDeleteID = Guid.Empty;
												Guid gActionImportID = Guid.Empty;
												Guid gActionExportID = Guid.Empty;
												// 09/26/2017 Paul.  Add Archive access right. 
												Guid gActionArchiveID = Guid.Empty;
												if ( right.ContainsKey("ACLACCESS_ACCESS") ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionAccessID, gID, "access", sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_ACCESS"]), trn);
												if ( right.ContainsKey("ACLACCESS_VIEW"  ) ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionViewID  , gID, "view"  , sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_VIEW"  ]), trn);
												if ( right.ContainsKey("ACLACCESS_LIST"  ) ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionListID  , gID, "list"  , sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_LIST"  ]), trn);
												if ( right.ContainsKey("ACLACCESS_EDIT"  ) ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionEditID  , gID, "edit"  , sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_EDIT"  ]), trn);
												if ( right.ContainsKey("ACLACCESS_DELETE") ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionDeleteID, gID, "delete", sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_DELETE"]), trn);
												if ( right.ContainsKey("ACLACCESS_IMPORT") ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionImportID, gID, "import", sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_IMPORT"]), trn);
												if ( right.ContainsKey("ACLACCESS_EXPORT") ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionExportID, gID, "export", sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_EXPORT"]), trn);
												// 09/26/2017 Paul.  Add Archive access right. 
												if ( right.ContainsKey("ACLACCESS_ARCHIVE") ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionArchiveID, gID, "archive", sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_ARCHIVE"]), trn);
											}
											// 03/09/2010 Paul.  Admin roles are managed separately. 
											bool bAllowAdminRoles = Sql.ToBoolean(Application["CONFIG.allow_admin_roles"]);
											if ( bAllowAdminRoles )
											{
												vwMain.RowFilter = "IS_ADMIN = 1 or MODULE_NAME = 'Teams'";
												if ( vwMain.Count > 0 )
												{
													Guid gActionAccessID = Guid.Empty;
													Guid gActionViewID   = Guid.Empty;
													Guid gActionListID   = Guid.Empty;
													Guid gActionEditID   = Guid.Empty;
													Guid gActionDeleteID = Guid.Empty;
													Guid gActionImportID = Guid.Empty;
													Guid gActionExportID = Guid.Empty;
													// 09/26/2017 Paul.  Add Archive access right. 
													Guid gActionArchiveID = Guid.Empty;
													if ( right.ContainsKey("ACLACCESS_ACCESS") ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionAccessID, gID, "access", sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_ACCESS"]), trn);
													if ( right.ContainsKey("ACLACCESS_VIEW"  ) ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionViewID  , gID, "view"  , sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_VIEW"  ]), trn);
													if ( right.ContainsKey("ACLACCESS_LIST"  ) ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionListID  , gID, "list"  , sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_LIST"  ]), trn);
													if ( right.ContainsKey("ACLACCESS_EDIT"  ) ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionEditID  , gID, "edit"  , sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_EDIT"  ]), trn);
													if ( right.ContainsKey("ACLACCESS_DELETE") ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionDeleteID, gID, "delete", sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_DELETE"]), trn);
													if ( right.ContainsKey("ACLACCESS_IMPORT") ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionImportID, gID, "import", sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_IMPORT"]), trn);
													if ( right.ContainsKey("ACLACCESS_EXPORT") ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionExportID, gID, "export", sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_EXPORT"]), trn);
													// 09/26/2017 Paul.  Add Archive access right. 
													if ( right.ContainsKey("ACLACCESS_ARCHIVE") ) SqlProcs.spACL_ROLES_ACTIONS_Update(ref gActionArchiveID, gID, "archive", sMODULE_NAME, Sql.ToInteger(right["ACLACCESS_ARCHIVE"]), trn);
												}
											}
										}
									}
								}
								trn.Commit();
								// 03/17/2010 Paul.  We can only reset the current user. 
								SplendidInit.ClearUserACL();
								SplendidInit.LoadUserACL(Security.USER_ID);
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
					}
					else
					{
						throw(new Exception(L10n.Term("ACL.LBL_NO_ACCESS")));
					}
				}
			}
			catch(Exception ex)
			{
				// 03/20/2019 Paul.  Catch and log all failures, including insufficient access. 
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
			return gID;
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAclAccessFieldSecurity(Guid ROLE_ID, string MODULE_NAME)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			if ( !Security.IsAuthenticated() || !(Security.AdminUserAccess("ACLRoles", "view") >= 0 || Security.AdminUserAccess("ACLRoles", "edit") >= 0) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			StringBuilder sbDumpSQL = new StringBuilder();
			DataTable dt = new DataTable();
			Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
			long lTotalCount = 0;
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select *                            " + ControlChars.CrLf
				     + "  from vwACL_FIELD_ACCESS_RoleFields" + ControlChars.CrLf
				     + " where ROLE_ID = @ROLE_ID           " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@ROLE_ID", ROLE_ID);
					if ( !Sql.IsEmptyString(MODULE_NAME) )
					{
						Sql.AddParameter(cmd, "@MODULE_NAME", MODULE_NAME);
						cmd.CommandText += "   and MODULE_NAME = @MODULE_NAME   " + ControlChars.CrLf;
					}
					else
					{
						cmd.CommandText += "   and ACLACCESS is not null" + ControlChars.CrLf;
					}
					cmd.CommandText += " order by FIELD_NAME" + ControlChars.CrLf;

					sbDumpSQL.Append(Sql.ExpandParameters(cmd));
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						da.Fill(dt);
					}
				}
			}

			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, dt, T10n);
			dictResponse.Add("__total", lTotalCount);
			// 10/26/2019 Paul.  Return the SQL to the React Client. 
			if ( Sql.ToBoolean(Application["CONFIG.show_sql"]) )
			{
				dictResponse.Add("__sql", sbDumpSQL.ToString());
			}
			
			JavaScriptSerializer json = new JavaScriptSerializer();
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		[OperationContract]
		public void UpdateAclAccessFieldSecurity(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

			try
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
				if ( !Security.IsAuthenticated() || (Security.AdminUserAccess("ACLRoles", "edit") < 0) )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				SplendidSession.CreateSession(HttpContext.Current.Session);
				
				string sRequest = String.Empty;
				using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
				{
					sRequest = stmRequest.ReadToEnd();
				}
				JavaScriptSerializer json = new JavaScriptSerializer();
				json.MaxJsonLength = int.MaxValue;
				Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
				
				// 05/05/2013 Paul.  We need to convert the date to the user's timezone. 
				Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
				TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
				Guid   gROLE_ID     = (dict.ContainsKey("ROLE_ID"    ) ? Sql.ToGuid  (dict["ROLE_ID"    ]) : Guid.Empty  );
				string sMODULE_NAME = (dict.ContainsKey("MODULE_NAME") ? Sql.ToString(dict["MODULE_NAME"]) : String.Empty);
				if ( Sql.IsEmptyGuid(gROLE_ID) )
				{
					throw(new Exception("Missing ROLE_ID parameter"));
				}
				if ( Sql.IsEmptyString(sMODULE_NAME) )
				{
					throw(new Exception("Missing MODULE_NAME parameter"));
				}
				
				string sTABLE_NAME  = "ACL_ROLES";
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL = String.Empty;
					
					DataTable dtACLACCESS = new DataTable();
					sSQL = "select MODULE_NAME                  " + ControlChars.CrLf
					     + "     , DISPLAY_NAME                 " + ControlChars.CrLf
					     + "     , FIELD_NAME                   " + ControlChars.CrLf
					     + "     , ACLACCESS                    " + ControlChars.CrLf
					     + "  from vwACL_FIELD_ACCESS_RoleFields" + ControlChars.CrLf
					     + " where ROLE_ID     = @ROLE_ID       " + ControlChars.CrLf
					     + "   and MODULE_NAME = @MODULE_NAME   " + ControlChars.CrLf
					     + " order by FIELD_NAME                " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ROLE_ID"    , gROLE_ID    );
						Sql.AddParameter(cmd, "@MODULE_NAME", sMODULE_NAME);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtACLACCESS);
						}
					}
					
					DataTable dtMetadata = SplendidCache.SqlColumns(sTABLE_NAME);
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						try
						{
							if ( dict.ContainsKey("AccessRights") )
							{
								DataView vwMain = new DataView(dtACLACCESS);
								System.Collections.ArrayList lst = dict["AccessRights"] as System.Collections.ArrayList;
								for ( int i = 0; i < lst.Count; i++ )
								{
									Dictionary<string, object> right = lst[i] as Dictionary<string, object>;
									string sFIELD_NAME = Sql.ToString (right["FIELD_NAME"]);
									int    nACLACCESS  = Sql.ToInteger(right["ACLACCESS" ]);
									vwMain.RowFilter = "FIELD_NAME = '" + Sql.EscapeSQL(sFIELD_NAME) + "'";
									if ( vwMain.Count > 0 )
									{
										Guid gPermissionID = Guid.Empty;
										SqlProcs.spACL_FIELDS_Update(ref gPermissionID, gROLE_ID, sFIELD_NAME, sMODULE_NAME, nACLACCESS, trn);
									}
								}
							}
							trn.Commit();
							// 03/17/2010 Paul.  We can only reset the current user. 
							SplendidInit.ClearUserACL();
							SplendidInit.LoadUserACL(Security.USER_ID);
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
				}
			}
			catch(Exception ex)
			{
				// 03/20/2019 Paul.  Catch and log all failures, including insufficient access. 
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetAclFieldAliases()
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");

			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			// 03/02/2019 Paul.  Allow admin delegate to access admin api. 
			if ( !Security.IsAuthenticated() || !(Security.AdminUserAccess("ACLRoles", "view") >= 0 || Security.AdminUserAccess("ACLRoles", "edit") >= 0) )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			DataTable dt = SplendidCache.ACLFieldAliases(HttpContext.Current);
			Guid     gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
			long lTotalCount = 0;
			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, dt, T10n);
			dictResponse.Add("__total", lTotalCount);
			dictResponse.Add("__sql"  , String.Empty);
			
			JavaScriptSerializer json = new JavaScriptSerializer();
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		#endregion
	}
}
