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
using System.Collections;
using System.Data;
using System.Data.Common;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.SessionState;
using System.Text;
using System.Xml;
using System.CodeDom.Compiler;
using System.Diagnostics;
using System.Reflection;
using System.Runtime.Versioning;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SplendidInit.
	/// </summary>
	public class SplendidInit
	{
		// 10/24/2009 Paul.  As a performance optimziation, we need a way to avoid calling spSYSTEM_TRANSACTIONS_Create for every transaction. 
		public static bool bUseSQLServerToken = false;
		public static bool bEnableACLFieldSecurity = false;

		private static void InitAppURLs(HttpContext Context)
		{
			HttpApplicationState Application = Context.Application;
			if ( Sql.IsEmptyString(Application["imageURL"]) )
			{
				Assembly asm = Assembly.GetExecutingAssembly();

				HttpRequest Request = Context.Request;
				// 12/22/2007 Paul.  We can no longer rely upon the Request object being valid as we might be inside the timer event. 
				string sServerName      = Request.ServerVariables["SERVER_NAME"];
				// 01/14/2008 Paul.  Capture the IP Address as it is harder to get inside a scheduled task. 
				string sServerIPAddress = Request.ServerVariables["LOCAL_ADDR" ];
				string sApplicationPath = Request.ApplicationPath;
				// 12/22/2007 Paul.  The DbFactory code will need the original ApplicationPath. 
				Application["SplendidVersion"    ] = asm.GetName().Version.ToString();
				// 09/24/2020 Paul.  Display ImageRuntimeVersion on SystemCheck. 
				Application["ImageRuntimeVersion"] = asm.ImageRuntimeVersion;
				try
				{
					Application["TargetFramework"] = (asm.GetCustomAttribute(typeof(TargetFrameworkAttribute)) as TargetFrameworkAttribute).FrameworkDisplayName;
				}
				catch
				{
				}
				// 12/27/2020 Paul.  We need the initial scheme when creating the default site_url. 
				Application["ServerScheme"       ] = Request.Url.Scheme;
				Application["ServerName"         ] = sServerName     ;
				Application["ServerIPAddress"    ] = sServerIPAddress;
				Application["ApplicationPath"    ] = sApplicationPath;
				if ( !sApplicationPath.EndsWith("/") )
					sApplicationPath += "/";
				Application["rootURL"  ] = sApplicationPath;
				// 07/28/2006 Paul.  Mono requires case-significant paths. 
				Application["imageURL" ] = sApplicationPath + "Include/images/";
				Application["scriptURL"] = sApplicationPath + "Include/javascript/";
				Application["chartURL" ] = sApplicationPath + "Include/charts/";
			}
		}

		public static void InitTerminology(HttpContext Context)
		{
			HttpApplicationState Application = Context.Application;
			try
			{
				// 12/03/2008 Paul.  This function can be called from a scheduled task, so we must pass the application to the GetFactory. 
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 05/20/2008 Paul.  Only load terminology from Active languages. 
					sSQL = "select NAME                " + ControlChars.CrLf
					     + "     , LANG                " + ControlChars.CrLf
					     + "     , MODULE_NAME         " + ControlChars.CrLf
					     + "     , DISPLAY_NAME        " + ControlChars.CrLf
					     + "  from vwTERMINOLOGY_Active" + ControlChars.CrLf
					     + " where LIST_NAME is null   " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
// 01/20/2006 Paul.  Enable all languages when debugging. 
//#if DEBUG
//						sSQL += "   and LANG = 'en-us'" + ControlChars.CrLf;
//#endif
						cmd.CommandText = sSQL;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								//Application[Sql.ToString(rdr["LANG"]) + "." + Sql.ToString(rdr["MODULE_NAME"]) + "." + Sql.ToString(rdr["NAME"])] = Sql.ToString(rdr["DISPLAY_NAME"]);
								string sLANG         = Sql.ToString(rdr["LANG"        ]);
								string sMODULE_NAME  = Sql.ToString(rdr["MODULE_NAME" ]);
								string sNAME         = Sql.ToString(rdr["NAME"        ]);
								string sDISPLAY_NAME = Sql.ToString(rdr["DISPLAY_NAME"]);
								// 01/20/2009 Paul.  We need to pass the Application to the Term function. 
								L10N.SetTerm(Application, sLANG, sMODULE_NAME, sNAME, sDISPLAY_NAME);
							}
						}
					}
					// 05/20/2008 Paul.  Only load terminology from Active languages. 
					sSQL = "select NAME                 " + ControlChars.CrLf
					     + "     , LANG                 " + ControlChars.CrLf
					     + "     , MODULE_NAME          " + ControlChars.CrLf
					     + "     , LIST_NAME            " + ControlChars.CrLf
					     + "     , DISPLAY_NAME         " + ControlChars.CrLf
					     + "  from vwTERMINOLOGY_Active " + ControlChars.CrLf
					     + " where LIST_NAME is not null" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
// 01/20/2006 Paul.  Enable all languages when debugging. 
//#if DEBUG
//						sSQL += "   and LANG = 'en-us'" + ControlChars.CrLf;
//#endif
						cmd.CommandText = sSQL;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								// 01/13/2006 Paul.  Don't include MODULE_NAME when used with a list. 
								// DropDownLists are populated without the module name in the list name. 
								// 01/13/2006 Paul.  We can remove the module, but not the dot.  
								// Otherwise it breaks all other code that references a list term. 
								//Application[Sql.ToString(rdr["LANG"]) + "." + sMODULE_NAME + "." + Sql.ToString(rdr["LIST_NAME"]) + "." + Sql.ToString(rdr["NAME"])] = Sql.ToString(rdr["DISPLAY_NAME"]);
								string sLANG         = Sql.ToString(rdr["LANG"        ]);
								string sMODULE_NAME  = Sql.ToString(rdr["MODULE_NAME" ]);
								string sNAME         = Sql.ToString(rdr["NAME"        ]);
								string sLIST_NAME    = Sql.ToString(rdr["LIST_NAME"   ]);
								string sDISPLAY_NAME = Sql.ToString(rdr["DISPLAY_NAME"]);
								// 01/20/2009 Paul.  We need to pass the Application to the Term function. 
								L10N.SetTerm(Application, sLANG, sMODULE_NAME, sLIST_NAME, sNAME, sDISPLAY_NAME);
							}
						}
					}

					sSQL = "select ALIAS_NAME           " + ControlChars.CrLf
					     + "     , ALIAS_MODULE_NAME    " + ControlChars.CrLf
					     + "     , ALIAS_LIST_NAME      " + ControlChars.CrLf
					     + "     , NAME                 " + ControlChars.CrLf
					     + "     , MODULE_NAME          " + ControlChars.CrLf
					     + "     , LIST_NAME            " + ControlChars.CrLf
					     + "  from vwTERMINOLOGY_ALIASES" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								string sALIAS_NAME         = Sql.ToString(rdr["ALIAS_NAME"        ]);
								string sALIAS_MODULE_NAME  = Sql.ToString(rdr["ALIAS_MODULE_NAME" ]);
								string sALIAS_LIST_NAME    = Sql.ToString(rdr["ALIAS_LIST_NAME"   ]);
								string sNAME               = Sql.ToString(rdr["NAME"              ]);
								string sMODULE_NAME        = Sql.ToString(rdr["MODULE_NAME"       ]);
								string sLIST_NAME          = Sql.ToString(rdr["LIST_NAME"         ]);
								// 01/20/2009 Paul.  We need to pass the Application to the Term function. 
								L10N.SetAlias(Application, sALIAS_MODULE_NAME, sALIAS_LIST_NAME, sALIAS_NAME, sMODULE_NAME, sLIST_NAME, sNAME);
							}
						}
					}
					// 11/20/2009 Paul.  Move module init to a separate function. 
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), ex);
				//HttpContext.Current.Response.Write(ex.Message);
			}
		}

		public static void InitModules(HttpContext Context)
		{
			HttpApplicationState Application = Context.Application;
			try
			{
				// 12/03/2008 Paul.  This function can be called from a scheduled task, so we must pass the application to the GetFactory. 
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 07/13/2006 Paul.  The reporting module needs a quick way to translate a module name to a table name. 
					// 12/29/2007 Paul.  We need to know if the module is audited. 
					// 01/20/2010 Paul.  Order by module to ease debugging. 
					sSQL = "select *                " + ControlChars.CrLf
					     + "  from vwMODULES_AppVars" + ControlChars.CrLf
					     + " order by MODULE_NAME   " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						// 06/28/2015 Paul.  SQL Azure is timing out, so just wait. 
						cmd.CommandTimeout = 0;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							Regex r = new Regex(@"[^A-Za-z0-9_]");
							while ( rdr.Read() )
							{
								string sMODULE_NAME            = Sql.ToString (rdr["MODULE_NAME"        ]);
								string sTABLE_NAME             = Sql.ToString (rdr["TABLE_NAME"         ]);
								string sRELATIVE_PATH          = Sql.ToString (rdr["RELATIVE_PATH"      ]);
								// 05/06/2010 Paul.  Add DISPLAY_NAME for the Six theme. 
								string sDISPLAY_NAME           = Sql.ToString (rdr["DISPLAY_NAME"       ]);
								bool   bIS_AUDITED             = Sql.ToBoolean(rdr["IS_AUDITED"         ]);
								bool   bIS_TEAMED              = Sql.ToBoolean(rdr["IS_TEAMED"          ]);
								bool   bIS_ASSIGNED            = Sql.ToBoolean(rdr["IS_ASSIGNED"        ]);
								bool   bCUSTOM_PAGING          = false;
								bool   bMASS_UPDATE_ENABLED    = true ;
								bool   bDEFAULT_SEARCH_ENABLED = true ;
								bool   bEXCHANGE_SYNC          = false;
								bool   bEXCHANGE_FOLDERS       = false;
								bool   bEXCHANGE_CREATE_PARENT = false;
								bool   bIS_ADMIN               = false;
								bool   bREST_ENABLED           = false;
								bool   bDUPLICATE_CHECHING_ENABLED    = false;
								bool   bSTREAM_ENBLED                 = false;
								bool   bRECORD_LEVEL_SECURITY_ENABLED = false;
								// 03/20/2019 Paul.  Flag if custom field table exists. 
								bool   bHAS_CUSTOM                    = false;
								try
								{
									// 01/07/2010 Paul.  Ignore the error if the field does not exist. 
									// This will allow us to debug old databases. 
									bCUSTOM_PAGING       = Sql.ToBoolean(rdr["CUSTOM_PAGING"      ]);
									// 12/03/2009 Paul.  Ignore the error if the field does not exist. 
									// This will allow us to debug old databases. 
									// If the field is NULL, then assume true. 
									if ( rdr["MASS_UPDATE_ENABLED"] != DBNull.Value )
										bMASS_UPDATE_ENABLED = Sql.ToBoolean(rdr["MASS_UPDATE_ENABLED"]);
									// 01/13/2010 Paul.  Ignore the error if the field does not exist. 
									// If the field is NULL, then assume true. 
									if ( rdr["DEFAULT_SEARCH_ENABLED"] != DBNull.Value )
										bDEFAULT_SEARCH_ENABLED = Sql.ToBoolean(rdr["DEFAULT_SEARCH_ENABLED"]);
									
									// 04/04/2010 Paul.  Add EXCHANGE_SYNC so that we can enable/disable the sync buttons on the MassUpdate panels. 
									bEXCHANGE_SYNC          = Sql.ToBoolean(rdr["EXCHANGE_SYNC"         ]);
									// 04/04/2010 Paul.  Add EXCHANGE_FOLDERS so that we can enable/disable the sync buttons on the MassUpdate panels. 
									bEXCHANGE_FOLDERS       = Sql.ToBoolean(rdr["EXCHANGE_FOLDERS"      ]);
									// 04/05/2010 Paul.  Need to be able to disable Account creation. This is because the email may come from a personal email address.
									bEXCHANGE_CREATE_PARENT = Sql.ToBoolean(rdr["EXCHANGE_CREATE_PARENT"]);
									// 07/28/2010 Paul.  We will use the Admin flag in the ModuleHeader. 
									bIS_ADMIN               = Sql.ToBoolean(rdr["IS_ADMIN"              ]);
								}
								catch
								{
								}
								try
								{
									// 08/22/2011 Paul.  Add admin control to REST API. 
									bREST_ENABLED           = Sql.ToBoolean(rdr["REST_ENABLED"          ]);
								}
								catch
								{
								}
								try
								{
									// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
									bDUPLICATE_CHECHING_ENABLED = Sql.ToBoolean(rdr["DUPLICATE_CHECHING_ENABLED"]);
								}
								catch
								{
								}
								try
								{
									// 09/28/2015 Paul.  Add Stream flag for use on Seven Preview panel. 
									bSTREAM_ENBLED = Sql.ToBoolean(rdr["STREAM_ENBLED"]);
								}
								catch
								{
								}
								try
								{
									// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
									bRECORD_LEVEL_SECURITY_ENABLED = Sql.ToBoolean(rdr["RECORD_LEVEL_SECURITY_ENABLED"]);
								}
								catch
								{
								}
								try
								{
									// 03/20/2019 Paul.  Flag if custom field table exists. 
									bHAS_CUSTOM                    = Sql.ToBoolean(rdr["HAS_CUSTOM"]);
								}
								catch
								{
								}

								// 11/03/2009 Paul.  As extra precaution, make sure that the table name is valid. 
								sTABLE_NAME = r.Replace(sTABLE_NAME, "");  // Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "");
								// 10/10/2006 Paul.  After importing, we need an easy way to get back to the root of the module. 
								// 12/30/2007 Paul.  We need a dynamic way to determine if the module record can be assigned or placed in a team. 
								// Teamed and Assigned flags are automatically determined based on the existence of TEAM_ID and ASSIGNED_USER_ID fields. 
								Application["Modules." + sMODULE_NAME + ".TableName"    ] = sTABLE_NAME         ;
								Application["Modules." + sMODULE_NAME + ".RelativePath" ] = sRELATIVE_PATH      ;
								// 05/06/2010 Paul.  Add DISPLAY_NAME for the Six theme. 
								Application["Modules." + sMODULE_NAME + ".DisplayName"  ] = sDISPLAY_NAME       ;
								Application["Modules." + sMODULE_NAME + ".Audited"      ] = bIS_AUDITED         ;
								Application["Modules." + sMODULE_NAME + ".Teamed"       ] = bIS_TEAMED          ;
								Application["Modules." + sMODULE_NAME + ".Assigned"     ] = bIS_ASSIGNED        ;
								Application["Modules." + sMODULE_NAME + ".CustomPaging" ] = bCUSTOM_PAGING      ;
								// 07/28/2010 Paul.  We will use the Admin flag in the ModuleHeader. 
								Application["Modules." + sMODULE_NAME + ".IsAdmin"      ] = bIS_ADMIN           ;
								// 12/02/2009 Paul.  Add the ability to disable Mass Updates. 
								Application["Modules." + sMODULE_NAME + ".MassUpdate"   ] = bMASS_UPDATE_ENABLED;
								// 01/13/2010 Paul.  Allow default search to be disabled. 
								Application["Modules." + sMODULE_NAME + ".DefaultSearch"] = bDEFAULT_SEARCH_ENABLED;
								// 04/04/2010 Paul.  Add EXCHANGE_SYNC so that we can enable/disable the sync buttons on the MassUpdate panels. 
								Application["Modules." + sMODULE_NAME + ".ExchangeSync" ] = bEXCHANGE_SYNC;
								// 04/04/2010 Paul.  Add EXCHANGE_SYNC so that we can enable/disable the sync buttons on the MassUpdate panels. 
								Application["Modules." + sMODULE_NAME + ".ExchangeFolders"] = bEXCHANGE_FOLDERS;
								// 04/05/2010 Paul.  Need to be able to disable Account creation. This is because the email may come from a personal email address.
								Application["Modules." + sMODULE_NAME + ".ExchangeCreateParent"] = bEXCHANGE_CREATE_PARENT;
								// 11/06/2009 Paul.  We need a fast way for the offline client to detect if the files exist for a specific module. 
								// 10/27/2010 Paul.  ASP.NET files will not exist on an iPad. 
								// 02/29/2016 Paul.  Product Catalog does not have default.aspx, so also lookg for popup.aspx. 
								// 07/27/2019 Paul.  InvoicesLineItems was not existing, so check for the folder. 
								// 12/16/2020 Paul.  ~/React/Home/default.aspx does not exist, so we have to just accept any ~/React paths. 
// 10/31/2021 Paul.  All modules are available to the React client. 
#if !ReactOnlyUI
								if ( sRELATIVE_PATH.ToLower().StartsWith("~/react") )
									Application["Modules." + sMODULE_NAME + ".Exists"      ] = true;
								else
									Application["Modules." + sMODULE_NAME + ".Exists"      ] = (Sql.IsEffiProz(con) || Sql.IsEmptyString(sRELATIVE_PATH) || File.Exists(Context.Server.MapPath(sRELATIVE_PATH + "default.aspx")) || Directory.Exists(Context.Server.MapPath(sRELATIVE_PATH)) || File.Exists(Context.Server.MapPath(sRELATIVE_PATH + "popup.aspx")));
#else
									Application["Modules." + sMODULE_NAME + ".Exists"      ] = true;
#endif
								// 01/18/2010 Paul.  We need a quick test for a valid module. 
								Application["Modules." + sMODULE_NAME + ".Valid"       ] = true;
								// 01/19/2010 Paul.  In the reporting area, we need a quick way to get a Module from a Table Name. 
								if ( !Sql.IsEmptyString(sTABLE_NAME) )
									Application["Modules." + sTABLE_NAME + ".ModuleName"] = sMODULE_NAME;
								// 08/22/2011 Paul.  Add admin control to REST API. 
								Application["Modules." + sMODULE_NAME + ".RestEnabled"  ] = bREST_ENABLED;
								// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
								Application["Modules." + sMODULE_NAME + ".DuplicateCheckingEnabled"] = bDUPLICATE_CHECHING_ENABLED;
								// 09/28/2015 Paul.  Add Stream flag for use on Seven Preview panel. 
								Application["Modules." + sMODULE_NAME + ".StreamEnabled"] = bSTREAM_ENBLED;
								// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
								Application["Modules." + sMODULE_NAME + ".RecordLevelSecurity"] = bRECORD_LEVEL_SECURITY_ENABLED;
								// 03/20/2019 Paul.  Flag if custom field table exists. 
								Application["Modules." + sMODULE_NAME + ".HasCustomTable"] = bHAS_CUSTOM;
							}
						}
					}
					// 12/13/2017 Paul.  Move archive flag to app so as to prevent catastrophic failure. 
					try
					{
						string sARCHIVE_DATABASE = Sql.ToString(Application["CONFIG.Archive.Database"]);
						if ( !Sql.IsEmptyString(sARCHIVE_DATABASE) )
							sARCHIVE_DATABASE = "[" + sARCHIVE_DATABASE + "].";
						sSQL = "select MODULE_NAME      " + ControlChars.CrLf
						     + "     , (select count(*) from " + sARCHIVE_DATABASE + "INFORMATION_SCHEMA.TABLES where TABLES.TABLE_NAME = vwMODULES_AppVars.TABLE_NAME + '_ARCHIVE') as ARCHIVED_ENBLED" + ControlChars.CrLf
						     + "  from vwMODULES_AppVars" + ControlChars.CrLf
						     + " order by MODULE_NAME   " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							// 06/28/2015 Paul.  SQL Azure is timing out, so just wait. 
							cmd.CommandTimeout = 0;
							using ( IDataReader rdr = cmd.ExecuteReader() )
							{
								while ( rdr.Read() )
								{
									string sMODULE_NAME     = Sql.ToString (rdr["MODULE_NAME"    ]);
									bool   bARCHIVED_ENBLED = Sql.ToBoolean(rdr["ARCHIVED_ENBLED"]);
									// 09/26/2017 Paul.  Add Archive access right. 
									Application["Modules." + sMODULE_NAME + ".ArchiveEnabled"] = bARCHIVED_ENBLED;
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), ex);
					}
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						// 03/31/2016 Paul.  We need a way to test if the user has sufficient access to the database. 
						// vwSqlColumns will return zero columns on the accounts table when access is not high enough. 
						cmd.CommandText = "select count(*) from vwSqlColumns where ObjectName = 'ACCOUNTS'";
						int nColumns = Sql.ToInteger(cmd.ExecuteScalar());
						if ( nColumns == 0 )
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), "The connection string does not provide sufficient access to base tables.  Please make sure that the SQL user has db_owner access to the database.");
					}
					// 11/20/2009 Paul.  We need to make sure that the ModulePopupScripts.aspx file is cached by the browser, but updated when appropriate. 
					sSQL = "select max(DATE_MODIFIED_UTC)" + ControlChars.CrLf
					     + "  from vwMODULES             " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						DateTime dtLastModified = Sql.ToDateTime(cmd.ExecuteScalar());
						Application["Modules.LastModified"] = dtLastModified.ToString();
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), ex);
				//HttpContext.Current.Response.Write(ex.Message);
			}
		}

		public static void InitModuleACL(HttpContext Context)
		{
			HttpApplicationState Application = Context.Application;
			try
			{
				// 12/03/2008 Paul.  This function can be called from a scheduled task, so we must pass the application to the GetFactory. 
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 03/09/2010 Paul.  Admin roles are managed separately. 
					// 09/26/2017 Paul.  Add Archive access right. 
					sSQL = "select MODULE_NAME          " + ControlChars.CrLf
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
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								string sMODULE_NAME = Sql.ToString(rdr["MODULE_NAME"]);
								// 02/03/2009 Paul.  This function might be called from a background process. 
								Security.SetModuleAccess(Application, sMODULE_NAME, "admin" , Sql.ToInteger(rdr["ACLACCESS_ADMIN" ]));
								Security.SetModuleAccess(Application, sMODULE_NAME, "access", Sql.ToInteger(rdr["ACLACCESS_ACCESS"]));
								Security.SetModuleAccess(Application, sMODULE_NAME, "view"  , Sql.ToInteger(rdr["ACLACCESS_VIEW"  ]));
								Security.SetModuleAccess(Application, sMODULE_NAME, "list"  , Sql.ToInteger(rdr["ACLACCESS_LIST"  ]));
								Security.SetModuleAccess(Application, sMODULE_NAME, "edit"  , Sql.ToInteger(rdr["ACLACCESS_EDIT"  ]));
								Security.SetModuleAccess(Application, sMODULE_NAME, "delete", Sql.ToInteger(rdr["ACLACCESS_DELETE"]));
								Security.SetModuleAccess(Application, sMODULE_NAME, "import", Sql.ToInteger(rdr["ACLACCESS_IMPORT"]));
								Security.SetModuleAccess(Application, sMODULE_NAME, "export", Sql.ToInteger(rdr["ACLACCESS_EXPORT"]));
								// 09/26/2017 Paul.  Add Archive access right. 
								Security.SetModuleAccess(Application, sMODULE_NAME, "archive", Sql.ToInteger(rdr["ACLACCESS_ARCHIVE"]));
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

		public static void InitConfig(HttpContext Context)
		{
			HttpApplicationState Application = Context.Application;
			try
			{
				// 12/03/2008 Paul.  This function can be called from a scheduled task, so we must pass the application to the GetFactory. 
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select NAME    " + ControlChars.CrLf
					     + "     , VALUE   " + ControlChars.CrLf
					     + "  from vwCONFIG" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								Application["CONFIG." + Sql.ToString(rdr["NAME"])] = Sql.ToString(rdr["VALUE"]);
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

		// 02/26/2011 Paul.  Add Field Validators for use by browser extensions. 
		public static void InitFieldValidators(HttpContext Context)
		{
			HttpApplicationState Application = Context.Application;
			try
			{
				// 12/03/2008 Paul.  This function can be called from a scheduled task, so we must pass the application to the GetFactory. 
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select NAME              " + ControlChars.CrLf
					     + "     , REGULAR_EXPRESSION" + ControlChars.CrLf
					     + "  from vwFIELD_VALIDATORS" + ControlChars.CrLf
					     + " where VALIDATION_TYPE = 'RegularExpressionValidator'" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								Application["FIELD_VALIDATORS." + Sql.ToString(rdr["NAME"])] = Sql.ToString(rdr["REGULAR_EXPRESSION"]);
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

		public static void InitTimeZones(HttpContext Context)
		{
			HttpApplicationState Application = Context.Application;
			try
			{
				// 12/03/2008 Paul.  This function can be called from a scheduled task, so we must pass the application to the GetFactory. 
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *          " + ControlChars.CrLf
					     + "  from vwTIMEZONES" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								// 01/02/2012 Paul.  Add iCal TZID. 
								// 03/26/2013 Paul.  iCloud uses linked_timezone values from http://tzinfo.rubyforge.org/doc/. 
								string sTZID = String.Empty;
								string sLINKED_TIMEZONE = String.Empty;
								try
								{
									sTZID = Sql.ToString(rdr["TZID"]);
									sLINKED_TIMEZONE = Sql.ToString(rdr["LINKED_TIMEZONE"]);
								}
								catch
								{
								}
								TimeZone oTimeZone = new TimeZone
									( Sql.ToGuid   (rdr["ID"                   ])
									, Sql.ToString (rdr["NAME"                 ])
									, Sql.ToString (rdr["STANDARD_NAME"        ])
									, Sql.ToString (rdr["STANDARD_ABBREVIATION"])
									, Sql.ToString (rdr["DAYLIGHT_NAME"        ])
									, Sql.ToString (rdr["DAYLIGHT_ABBREVIATION"])
									, Sql.ToInteger(rdr["BIAS"                 ])
									, Sql.ToInteger(rdr["STANDARD_BIAS"        ])
									, Sql.ToInteger(rdr["DAYLIGHT_BIAS"        ])
									, Sql.ToInteger(rdr["STANDARD_YEAR"        ])
									, Sql.ToInteger(rdr["STANDARD_MONTH"       ])
									, Sql.ToInteger(rdr["STANDARD_WEEK"        ])
									, Sql.ToInteger(rdr["STANDARD_DAYOFWEEK"   ])
									, Sql.ToInteger(rdr["STANDARD_HOUR"        ])
									, Sql.ToInteger(rdr["STANDARD_MINUTE"      ])
									, Sql.ToInteger(rdr["DAYLIGHT_YEAR"        ])
									, Sql.ToInteger(rdr["DAYLIGHT_MONTH"       ])
									, Sql.ToInteger(rdr["DAYLIGHT_WEEK"        ])
									, Sql.ToInteger(rdr["DAYLIGHT_DAYOFWEEK"   ])
									, Sql.ToInteger(rdr["DAYLIGHT_HOUR"        ])
									, Sql.ToInteger(rdr["DAYLIGHT_MINUTE"      ])
									, Sql.ToBoolean(Application["CONFIG.GMT_Storage"])
									, sTZID
									);
								Application["TIMEZONE." + oTimeZone.ID.ToString()] = oTimeZone;
								// 01/02/2012 Paul.  We need quick way to convert a TZID to a GUID. 
								if ( !Sql.IsEmptyString(sTZID) )
									Application["TIMEZONE.TZID." + oTimeZone.TZID] = oTimeZone;
								// 03/26/2013 Paul.  iCloud uses linked_timezone values from http://tzinfo.rubyforge.org/doc/. 
								if ( !Sql.IsEmptyString(sLINKED_TIMEZONE) )
									Application["TIMEZONE.TZID." + sLINKED_TIMEZONE] = oTimeZone;
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

		public static void InitCurrencies(HttpContext Context)
		{
			HttpApplicationState Application = Context.Application;
			try
			{
				// 12/03/2008 Paul.  This function can be called from a scheduled task, so we must pass the application to the GetFactory. 
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *           " + ControlChars.CrLf
					     + "  from vwCURRENCIES" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								// 11/10/2008 Paul.  PayPal uses the ISO value. 
								// 04/30/2016 Paul.  Require the Application so that we can get the base currency. 
								Currency C10n = new Currency
									( Application
									, Sql.ToGuid  (rdr["ID"             ])
									, Sql.ToString(rdr["NAME"           ])
									, Sql.ToString(rdr["SYMBOL"         ])
									, Sql.ToString(rdr["ISO4217"        ])
									, Sql.ToFloat (rdr["CONVERSION_RATE"])
									);
								Application["CURRENCY." + C10n.ID.ToString()] = C10n;
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

		// 10/26/2008 Paul.  IIS7 Integrated Pipeline does not allow HttpContext access inside Application_Start. 
		public static void InitApp(HttpContext Context)
		{
			HttpApplicationState Application = Context.Application;
			try
			{
				// 05/28/2019 Paul.  We have noticed that Rest service requests are executing before InitApp completes. 
				// Try to lock the app to see if that will help. 
				Application.Lock();
				// 11/14/2005 Paul.  Force the reload of the provider and connection strings. 
				// Application.Remove("SplendidProvider");
				// 11/28/2005 Paul.  Use Clear() to clear all application variables. 
				DataTable dtSystemErrors = Application["SystemErrors"] as DataTable;

				// 11/21/2009 Paul.  InitApp will delete the sync table, so take the extra step to preserve it. 
				Hashtable hashSystemSync = new Hashtable();
				// 11/24/2009 Paul.  Application.Keys returns a string. 
				foreach ( string key in Application.Keys )
				{
					if ( key.StartsWith("SystemSync.") && !hashSystemSync.Contains(key) )
						hashSystemSync.Add(key, Application[key]);
				}
				Application.Clear();
				foreach ( object oKey in hashSystemSync )
				{
					Application[oKey.ToString()] = hashSystemSync[oKey];
				}
				hashSystemSync.Clear();
				// 11/28/2005 Paul.  Save and restore the system errors table. 
				Application["SystemErrors"] = dtSystemErrors;

				InitAppURLs(Context);
				// 08/01/2015 Paul.  The Microsoft Web Platform Installer is unable to deploy due to a timeout when applying the Build.sql file. 
				// We cannot build the database until after InitAppURLs as the domain name may be needed for SplendidRegistry. 
				SqlBuild.BuildDatabase(Context);
				// 03/06/2008 Paul.  We cannot log the application start until the the ServerName has been stored in the Application cache. 
				// 04/22/2008 Paul.  Include the version in the system log.
				// 02/10/2015 Paul.  There are a few initial items, but they are less than 20. 
				if ( Application.Count < 20 )
					SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Application start. Version " + Sql.ToString(Application["SplendidVersion"]));
				else
					SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Application restart. Version " + Sql.ToString(Application["SplendidVersion"]));

				// 11/28/2005 Paul.  Clear all cache variables as well. 
				// 02/18/2008 Paul.  HttpRuntime.Cache is a better and faster way to get to the cache. 
				foreach(DictionaryEntry oKey in HttpRuntime.Cache)
				{
					string sKey = oKey.Key.ToString();
					HttpRuntime.Cache.Remove(sKey);
				}
				// 06/03/2006 Paul.  Clear the cached data that is stored in the Session object. 
				if ( Context.Session != null )
				{
					Hashtable hashSessionKeys = new Hashtable();
					foreach(string sKey in Context.Session.Keys)
					{
						hashSessionKeys.Add(sKey, null);
					}
					// 06/03/2006 Paul.  We can't remove a key when it is used in the enumerator. 
					foreach(string sKey in hashSessionKeys.Keys )
					{
						if ( sKey.StartsWith("vwSHORTCUTS_Menu_ByUser") || sKey.StartsWith("vwMODULES_TabMenu_ByUser") )
							Context.Session.Remove(sKey);
					}
				}

				// 07/01/2008 Paul.  Allow config values to be initialized from the Web.config. 
				// This is so that the default_theme could be specified early. 
				foreach (string sConfig in System.Configuration.ConfigurationManager.AppSettings )
				{
					Application["CONFIG." + sConfig] = Sql.ToString(System.Configuration.ConfigurationManager.AppSettings[sConfig]);
				}

				// 12/03/2008 Paul.  This function can be called from a scheduled task, so we must pass the application to the GetFactory. 
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					// 07/28/2006 Paul.  Test the database connection and allow an early exit if failed. 
					con.Open();
					// 10/24/2009 Paul.  As a performance optimziation, we need a way to avoid calling spSYSTEM_TRANSACTIONS_Create for every transaction. 
					bUseSQLServerToken = false;
					// 01/17/2010 Paul.  ACL Field Security is only enabled when the vwACL_FIELD_ACCESS_ByUserAlias view exists. 
					bEnableACLFieldSecurity = false;
					if ( Sql.IsSQLServer(con) )
					{
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = "select @@VERSION";
							string sSqlVersion = Sql.ToString(cmd.ExecuteScalar());
							// 10/13/2009 Paul.  Azure Product database has a different version than the CTP environment. 
							bool bSQLAzure = false;
							if ( sSqlVersion.StartsWith("Microsoft SQL Azure") || (sSqlVersion.IndexOf("SQL Server") > 0 && sSqlVersion.IndexOf("CloudDB") > 0) )
							{
								bSQLAzure = true;
								SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Connected to Microsoft SQL Azure.");
							}
							// 01/29/2019 Paul.  One last check to see if we should use our local SYSTEM_TRANSACTIONS table. 
							// If we have restored a backup of an Azure database, then the spSqlGetTransactionToken procedure will still require Azure technique. 
							if ( ! bSQLAzure )
							{
								try
								{
									cmd.CommandText = "select object_definition(object_id(N'spSqlGetTransactionToken'))";
									sSqlVersion = Sql.ToString(cmd.ExecuteScalar());
									if ( sSqlVersion.Contains("exec dbo.spSYSTEM_TRANSACTIONS_Create @ID out, null;") )
									{
										bSQLAzure = true;
										SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Connected to Microsoft SQL Server, but using SYSTEM_TRANSACTIONS table.");
									}
								}
								catch(Exception ex)
								{
									SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), ex);
								}
							}
							bUseSQLServerToken = !bSQLAzure;
						}
					}
					// 10/27/2010 Paul.  Set the Server Token flag so that we will not waste cycles creating a transaction token. 
					// We will not use auditing on a portable device. 
					else if ( Sql.IsEffiProz(con) )
					{
						bUseSQLServerToken = true;
					}
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						// 01/17/2010 Paul.  Oracle is case-significant, and will return a view in uppercase. 
						cmd.CommandText = "select count(*) from vwSqlViews where VIEW_NAME = upper('vwACL_FIELD_ACCESS_ByUserAlias')";
						bEnableACLFieldSecurity = Sql.ToBoolean(cmd.ExecuteScalar());
					}
				}

				// 01/12/2006 Paul.  Separate out the terminology so that it can be called when importing a language pack. 
				InitTerminology(Context);
				InitConfig     (Context);
				// 11/20/2009 Paul.  Move module init to a separate function. 
				// 12/14/2017 Paul.  Init modules after config as Archive.Database is needed. 
				InitModules    (Context);
				// 02/26/2011 Paul.  Add Field Validators for use by browser extensions. 
				InitFieldValidators(Context);
				InitTimeZones  (Context);
				InitCurrencies (Context);
				// 11/18/2009 Paul.  We should have been initializing the default Module rights a long time ago. 
				InitModuleACL  (Context);

				// 08/15/2008 Paul.  If Silverlight is enabled and we are running on Linux, then disable Silverlight and enable Flash. 
				// Mono is having a problem with the inline WPF.
				// 09/22/2008 Paul.  Move Silverlight disable after InitConfig. 
				int nPlatform = (int) Environment.OSVersion.Platform;
				if ( nPlatform == 4 || nPlatform == 128 )
				{
					SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Silverlight is disabled on Mono.");
					Application["CONFIG.enable_silverlight"] = false;
					Application["CONFIG.enable_flash"      ] = true;
				}

				// 10/03/2013 Paul.  Check for .NET 4.5 so that we can better debug SignalR state. 
				// http://stackoverflow.com/questions/8517159/how-to-detect-at-runtime-that-net-version-4-5-currently-running-your-code
				bool bIsNet45OrNewer = false;
				try
				{
					bIsNet45OrNewer = (Type.GetType("System.Reflection.ReflectionContext", false) != null);
				}
				catch
				{
				}
				Application["System.NET45"] = bIsNet45OrNewer;

				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 08/02/2008 Paul.  Track the last date that we loaded the app vars. 
					sSQL = "select max(DATE_ENTERED)" + ControlChars.CrLf
					     + "  from vwSYSTEM_EVENTS  " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						DateTime dtLastUpdate = Sql.ToDateTime(cmd.ExecuteScalar());
						if ( dtLastUpdate == DateTime.MinValue )
							dtLastUpdate = DateTime.Now;
						Application["SYSTEM_EVENTS.MaxDate"] = dtLastUpdate;
						SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "System Events Last Update on " + dtLastUpdate.ToString());
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), ex);
				//HttpContext.Current.Response.Write(ex.Message);
			}
			finally
			{
				Application.UnLock();
			}
		}

		// 10/28/2008 Paul.  Log application stop so that we can track when IIS7 recycles the app. 
		public static void StopApp(HttpContext Context)
		{
			try
			{
				Guid   gUSER_ID          = Guid.Empty;
				string sUSER_NAME        = String.Empty;
				string sMACHINE          = String.Empty;
				string sASPNET_SESSIONID = String.Empty;
				string sREMOTE_HOST      = String.Empty;
				string sSERVER_HOST      = String.Empty;
				string sTARGET           = String.Empty;
				string sRELATIVE_PATH    = String.Empty;
				string sPARAMETERS       = String.Empty;
				string sFILE_NAME        = String.Empty;
				string sMETHOD           = String.Empty;
				string sERROR_TYPE       = "Warning";
				string sMESSAGE          = "Application stop.";
				Int32  nLINE_NUMBER      = 0;

				try
				{
					// 09/17/2009 Paul.  Azure does not support MachineName.  Just ignore the error. 
					sMACHINE = System.Environment.MachineName;
				}
				catch
				{
				}
				StackFrame stack = new StackTrace(true).GetFrame(0);
				if ( stack != null )
				{
					sFILE_NAME   = stack.GetFileName();
					sMETHOD      = stack.GetMethod().ToString();
					nLINE_NUMBER = stack.GetFileLineNumber();
				}
				try
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								SqlProcs.spSYSTEM_LOG_InsertOnly(gUSER_ID, sUSER_NAME, sMACHINE, sASPNET_SESSIONID, sREMOTE_HOST, sSERVER_HOST, sTARGET, sRELATIVE_PATH, sPARAMETERS, sERROR_TYPE, sFILE_NAME, sMETHOD, nLINE_NUMBER, sMESSAGE, trn);
								trn.Commit();
							}
							catch //(Exception ex)
							{
								trn.Rollback();
								// 10/26/2008 Paul.  Can't throw an exception here as it could create an endless loop. 
								//SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
							}
						}
						if ( Sql.IsEffiProz(con) )
						{
							// 12/31/2010 Irantha.  Shutdown command CheckPoints the database (remove the .log file and rewrite the .script file). 
							// If this is not done then the CheckPointing automatically happens when database is reopened next time. 
							// This would increase the next start-up time.  SplendidCRM has auto shutdown set to false in connection string. 
							// So doing a Shutdown on APPLICATION_END event would reduce the next application start-up time. 
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = "SHUTDOWN";
								cmd.ExecuteNonQuery();
							}
						}
					}
				}
				catch
				{
				}
			}
			catch//(Exception ex)
			{
				//SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), ex);
				//HttpContext.Current.Response.Write(ex.Message);
			}
		}

		public static XmlDocument InitUserPreferences(string sUSER_PREFERENCES)
		{
			XmlDocument xml = null;
			try
			{
				xml = new XmlDocument();
				// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
				// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
				// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
				xml.XmlResolver = null;
				// 01/28/2009 Paul.  Check for empty string before attempting to load preferences. 
				// 03/25/2009 Paul.  The empty string check needed a NOT condition. 
				if ( !Sql.IsEmptyString(sUSER_PREFERENCES) )
				{
					// 10/17/2009 Paul.  The XML may not start with processing instructions. 
					if ( !sUSER_PREFERENCES.StartsWith("<?xml ") && !sUSER_PREFERENCES.StartsWith("<xml>") )
					{
						sUSER_PREFERENCES = XmlUtil.ConvertFromPHP(sUSER_PREFERENCES);
					}
					xml.LoadXml(sUSER_PREFERENCES);
				}
				else
				{
					xml.AppendChild(xml.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
					xml.AppendChild(xml.CreateElement("USER_PREFERENCE"));
				}
				
				HttpApplicationState Application = HttpContext.Current.Application;
				string sCulture    = L10N.NormalizeCulture(XmlUtil.SelectSingleNode(xml, "culture"));
				string sTheme      = XmlUtil.SelectSingleNode(xml, "theme"      );
				string sDateFormat = XmlUtil.SelectSingleNode(xml, "dateformat" );
				string sTimeFormat = XmlUtil.SelectSingleNode(xml, "timeformat" );
				string sTimeZone   = XmlUtil.SelectSingleNode(xml, "timezone"   );
				string sCurrencyID = XmlUtil.SelectSingleNode(xml, "currency_id");
				if ( Sql.IsEmptyString(sCulture) )
				{
					XmlUtil.SetSingleNode(xml, "culture", SplendidDefaults.Culture());
				}
				if ( Sql.IsEmptyString(sTheme) )
				{
					XmlUtil.SetSingleNode(xml, "theme", SplendidDefaults.Theme());
				}
				if ( Sql.IsEmptyString(sDateFormat) )
				{
					XmlUtil.SetSingleNode(xml, "dateformat", SplendidDefaults.DateFormat());
				}
				// 11/12/2005 Paul.  "m" is not valid for .NET month formatting.  Must use MM. 
				// 11/12/2005 Paul.  Require 4 digit year.  Otherwise default date in Pipeline of 12/31/2100 would get converted to 12/31/00. 
				if ( SplendidDefaults.IsValidDateFormat(sDateFormat) )
				{
					XmlUtil.SetSingleNode(xml, "dateformat", SplendidDefaults.DateFormat(sDateFormat));
				}
				if ( Sql.IsEmptyString(sTimeFormat) )
				{
					XmlUtil.SetSingleNode(xml, "timeformat", SplendidDefaults.TimeFormat());
				}
				if ( Sql.IsEmptyString(sCurrencyID) )
				{
					XmlUtil.SetSingleNode(xml, "currency_id", SplendidDefaults.CurrencyID());
				}
				// 09/01/2006 Paul.  Only use timez if provided.  Otherwise we will default to GMT. 
				if ( Sql.IsEmptyString(sTimeZone) && !Sql.IsEmptyString(XmlUtil.SelectSingleNode(xml, "timez")) )
				{
					int nTimez = Sql.ToInteger(XmlUtil.SelectSingleNode(xml, "timez"));
					sTimeZone = SplendidDefaults.TimeZone(nTimez);
					XmlUtil.SetSingleNode(xml, "timezone", sTimeZone);
				}
				// 09/01/2006 Paul.  Default TimeZone was not getting set properly. 
				if ( Sql.IsEmptyString(sTimeZone) )
				{
					sTimeZone = SplendidDefaults.TimeZone();
					XmlUtil.SetSingleNode(xml, "timezone", sTimeZone);
				}
				// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
				string sSaveQuery  = XmlUtil.SelectSingleNode(xml, "save_query");
				if ( Sql.IsEmptyString(sSaveQuery) )
					XmlUtil.SetSingleNode(xml, "save_query", Sql.ToBoolean(Application["CONFIG.save_query"]).ToString());
				// 02/26/2010 Paul.  Allow users to configure use of tabs. 
				string sGroupTabs  = XmlUtil.SelectSingleNode(xml, "group_tabs");
				if ( Sql.IsEmptyString(sGroupTabs) )
					XmlUtil.SetSingleNode(xml, "group_tabs", Sql.ToBoolean(Application["CONFIG.default_group_tabs"]).ToString());
				string sSubPanelTabs  = XmlUtil.SelectSingleNode(xml, "subpanel_tabs");
				if ( Sql.IsEmptyString(sSubPanelTabs) )
					XmlUtil.SetSingleNode(xml, "subpanel_tabs", Sql.ToBoolean(Application["CONFIG.default_subpanel_tabs"]).ToString());
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
			return xml;
		}

		// 11/06/2009 Paul.  Allow preferences to be called with a context. 
		public static void LoadUserPreferences(Guid gID, string sTheme, string sCulture)
		{
			LoadUserPreferences(HttpContext.Current, gID, sTheme, sCulture);
		}

		public static void LoadUserPreferences(HttpContext Context, Guid gID, string sTheme, string sCulture)
		{
			HttpApplicationState Application = Context.Application;
			HttpSessionState     Session     = Context.Session    ;
			string sApplicationPath = Sql.ToString(Context.Application["rootURL"]);

			// 10/24/2009 Paul.  As a performance optimziation, don't lookup the user if we are just trying to initialize preferences prior to login. 
			if ( !Sql.IsEmptyGuid(gID) )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL ;
					// 03/31/2010 Paul.  We don't need to use vwUSERS_Edit as it adds ADDRESS_HTML and we don't need that field. 
					sSQL = "select *       " + ControlChars.CrLf
					     + "  from vwUSERS " + ControlChars.CrLf
					     + " where ID = @ID" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ID", gID);
						con.Open();
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
								// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
								Security.EMAIL1    = Sql.ToString(rdr["EMAIL1"   ]);
								Security.FULL_NAME = Sql.ToString(rdr["FULL_NAME"]);
								//12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
								/*
								string sUSER_PREFERENCES = Sql.ToString(rdr["USER_PREFERENCES"]);
								if ( !Sql.IsEmptyString(sUSER_PREFERENCES) )
								{
									XmlDocument xml = InitUserPreferences(sUSER_PREFERENCES);
									Session["USER_PREFERENCES"] = xml.OuterXml;
									// 11/19/2005 Paul.  Not sure why the login screen has the language, but it would seem to allow overriding the default. 
									if ( Sql.IsEmptyString(sCulture) )
									{
										sCulture = XmlUtil.SelectSingleNode(xml, "culture").Replace("_", "-");
									}
									// 11/22/2005 Paul.  The theme can be overridden as well. 
									if ( Sql.IsEmptyString(sTheme) )
									{
										sTheme = XmlUtil.SelectSingleNode(xml, "theme").Replace("_", "-");
									}
									Session["USER_SETTINGS/CULTURE"         ] = sCulture;
									Session["USER_SETTINGS/THEME"           ] = sTheme;
									// 11/30/2012 Paul.  Save the default them for the user, as specified in the preferences. 
									// This is to allow the user to go from the Mobile theme to the full site. 
									Session["USER_SETTINGS/DEFAULT_THEME"   ] = sTheme;
									// 03/07/2007 Paul.  Version 1.4 moved its themes folder to the .NET 2.0 default App_Themes. 
									// This is to support standard .NET 2.0 Themes and Skins. 
									Session["themeURL"                      ] = sApplicationPath + "App_Themes/" + sTheme + "/";
									Session["USER_SETTINGS/DATEFORMAT"      ] = XmlUtil.SelectSingleNode(xml, "dateformat"      );
									Session["USER_SETTINGS/TIMEFORMAT"      ] = XmlUtil.SelectSingleNode(xml, "timeformat"      );
									// 01/21/2006 Paul.  It is useful to have quick access to email address. 
									// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
									// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
									//Session["USER_SETTINGS/MAIL_FROMNAME"   ] = XmlUtil.SelectSingleNode(xml, "mail_fromname"   );
									//Session["USER_SETTINGS/MAIL_FROMADDRESS"] = XmlUtil.SelectSingleNode(xml, "mail_fromaddress");
									// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
									Session["USER_SETTINGS/SAVE_QUERY"      ] = XmlUtil.SelectSingleNode(xml, "save_query"      );
									// 02/26/2010 Paul.  Allow users to configure use of tabs. 
									Session["USER_SETTINGS/GROUP_TABS"      ] = XmlUtil.SelectSingleNode(xml, "group_tabs"      );
									Session["USER_SETTINGS/SUBPANEL_TABS"   ] = XmlUtil.SelectSingleNode(xml, "subpanel_tabs"   );
									
									// 01/28/2009 Paul.  If the user has not specified a Reply-To name or address, then use EMAIL1. 
									// This should reduce support calls due to the Send Email button being disabled. 
									// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
									// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
									//if ( Sql.IsEmptyString(Session["USER_SETTINGS/MAIL_FROMNAME"]) )
									//	Session["USER_SETTINGS/MAIL_FROMNAME"] = Sql.ToString(rdr["FULL_NAME"]);
									//if ( Sql.IsEmptyString(Session["USER_SETTINGS/MAIL_FROMADDRESS"]) )
									//	Session["USER_SETTINGS/MAIL_FROMADDRESS"] = Sql.ToString(rdr["EMAIL1"]);
									// 05/09/2006 Paul.  Initialize the numeric separators. 
									// 03/07/2008 Paul.  We are no longer going to allow the number separators to be customized. 
									//Session["USER_SETTINGS/GROUP_SEPARATOR"  ] = XmlUtil.SelectSingleNode(xml, "num_grp_sep"    );
									//Session["USER_SETTINGS/DECIMAL_SEPARATOR"] = XmlUtil.SelectSingleNode(xml, "dec_sep"        );
									try
									{
										Session["USER_SETTINGS/TIMEZONE"  ] = Sql.ToGuid(XmlUtil.SelectSingleNode(xml, "timezone")).ToString();
										// 10/06/2007 Paul.  Save the original timezone value so that we can display the timezone selector if necessary. 
										Session["USER_SETTINGS/TIMEZONE/ORIGINAL"] = Session["USER_SETTINGS/TIMEZONE"];
									}
									catch
									{
										SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Invalid USER_SETTINGS/TIMEZONE: " + XmlUtil.SelectSingleNode(xml, "timezone"));
									}
									try
									{
										Session["USER_SETTINGS/CURRENCY"  ] = XmlUtil.SelectSingleNode(xml, "currency_id");
									}
									catch
									{
										SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Invalid USER_SETTINGS/CURRENCY: " + XmlUtil.SelectSingleNode(xml, "currency_id"));
									}
									
									// 03/07/2008 Paul.  We should be pulling the currency symbole from the culture. 
									//DataView vwCurrencies = new DataView(SplendidCache.Currencies());
									//vwCurrencies.RowFilter = "ID = '" + XmlUtil.SelectSingleNode(xml, "currency_id") + "'";
									//if ( vwCurrencies.Count > 0 )
									//	Session["USER_SETTINGS/CURRENCY_SYMBOL"] = Sql.ToString(vwCurrencies[0]["SYMBOL"]);
								}
								*/
								//12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
								try
								{
									// 11/19/2005 Paul.  Not sure why the login screen has the language, but it would seem to allow overriding the default. 
									// 04/20/2018 Paul.  Alternate language mapping to convert en-CA to en_US. 
									Session["USER_SETTINGS/CULTURE"          ] = L10N.AlternateLanguage(Application, Sql.IsEmptyString(sCulture) ? Sql.ToString(rdr["LANG" ]) : sCulture);
									// 11/22/2005 Paul.  The theme can be overridden as well. 
									Session["USER_SETTINGS/THEME"            ] = Sql.IsEmptyString(sTheme  ) ? Sql.ToString(rdr["THEME"]) : sTheme  ;
									// 11/30/2012 Paul.  Save the default them for the user, as specified in the preferences. This is to allow the user to go from the Mobile theme to the full site. 
									Session["USER_SETTINGS/DEFAULT_THEME"    ] = sTheme;
									Session["themeURL"                       ] = sApplicationPath + "App_Themes/" + sTheme + "/";
									Session["USER_SETTINGS/DATEFORMAT"       ] = Sql.ToString(rdr["DATE_FORMAT"   ]);
									Session["USER_SETTINGS/TIMEFORMAT"       ] = Sql.ToString(rdr["TIME_FORMAT"   ]);
									// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
									Session["USER_SETTINGS/SAVE_QUERY"       ] = Sql.ToBoolean(rdr["SAVE_QUERY"   ]);
									// 02/26/2010 Paul.  Allow users to configure use of tabs. 
									Session["USER_SETTINGS/GROUP_TABS"       ] = Sql.ToBoolean(rdr["GROUP_TABS"   ]);
									Session["USER_SETTINGS/SUBPANEL_TABS"    ] = Sql.ToBoolean(rdr["SUBPANEL_TABS"]);
									Session["USER_SETTINGS/TIMEZONE"         ] = Sql.ToGuid   (rdr["TIMEZONE_ID"  ]);
									// 10/06/2007 Paul.  Save the original timezone value so that we can display the timezone selector if necessary. 
									Session["USER_SETTINGS/TIMEZONE/ORIGINAL"] = Sql.ToString (rdr["TIMEZONE_ID"  ]);
									Session["USER_SETTINGS/CURRENCY"         ] = Sql.ToString (rdr["CURRENCY_ID"  ]);
								}
								catch(Exception ex)
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
								}
								// 08/24/2013 Paul.  Add EXTENSION_C in preparation for Asterisk click-to-call. 
								// 09/20/2013 Paul.  Move EXTENSION to the main table. 
								// 09/27/2013 Paul.  SMS messages need to be opt-in. 
								try
								{
									Session["PHONE_WORK"  ] = Sql.ToString(rdr["PHONE_WORK"  ]);
									Session["EXTENSION"   ] = Sql.ToString(rdr["EXTENSION"   ]);
									Session["PHONE_MOBILE"] = Sql.ToString(rdr["PHONE_MOBILE"]);
									Session["SMS_OPT_IN"  ] = Sql.ToString(rdr["SMS_OPT_IN"  ]);
								}
								catch(Exception ex)
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
								}
								// 11/21/2014 Paul.  Add User Picture. 
								try
								{
									Security.PICTURE = Sql.ToString(rdr["PICTURE"]);
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
			// 11/21/2005 Paul.  New users may not have any settings, so we need to initialize the defaults.
			// It is best to do it here rather than wrap the variables in a function that would return the default if null.
			sCulture    = Sql.ToString(Session["USER_SETTINGS/CULTURE"   ]);
			sTheme      = Sql.ToString(Session["USER_SETTINGS/THEME"     ]);
			string sDateFormat = Sql.ToString(Session["USER_SETTINGS/DATEFORMAT"]);
			string sTimeFormat = Sql.ToString(Session["USER_SETTINGS/TIMEFORMAT"]);
			string sTimeZone   = Sql.ToString(Session["USER_SETTINGS/TIMEZONE"  ]);
			string sCurrencyID = Sql.ToString(Session["USER_SETTINGS/CURRENCY"  ]);
			if ( Sql.IsEmptyString(sCulture) )
			{
				Session["USER_SETTINGS/CULTURE"   ] = SplendidDefaults.Culture();
			}
			// 11/17/2007 Paul.  If running on a mobile device, then use the mobile theme. 
			// 04/21/2021 Paul.  The mobile theme is now deprecated as most cell phones have large screens. 
			/* if ( Utils.IsMobileDevice )
			{
				if ( Directory.Exists(Context.Server.MapPath("~/App_MasterPages/" + SplendidDefaults.MobileTheme())) )
				{
					sTheme = SplendidDefaults.MobileTheme();
					Session["USER_SETTINGS/THEME"] = sTheme;
				}
			}
			else */
			if ( Sql.IsEmptyString(sTheme) )
			{
				sTheme = SplendidDefaults.Theme();
				Session["USER_SETTINGS/THEME"] = sTheme;
			}
			// 03/07/2007 Paul.  Version 1.4 moved its themes folder to the .NET 2.0 default App_Themes. 
			Session["themeURL"] = sApplicationPath + "App_Themes/" + sTheme + "/";
			if ( Sql.IsEmptyString(sDateFormat) )
			{
				Session["USER_SETTINGS/DATEFORMAT"] = SplendidDefaults.DateFormat();
			}
			// 11/12/2005 Paul.  "m" is not valid for .NET month formatting.  Must use MM. 
			// 11/12/2005 Paul.  Require 4 digit year.  Otherwise default date in Pipeline of 12/31/2100 would get converted to 12/31/00. 
			if ( SplendidDefaults.IsValidDateFormat(sDateFormat) )
			{
				Session["USER_SETTINGS/DATEFORMAT"] = SplendidDefaults.DateFormat(sDateFormat);
			}
			if ( Sql.IsEmptyString(sTimeFormat) )
			{
				Session["USER_SETTINGS/TIMEFORMAT"] = SplendidDefaults.TimeFormat();
			}
			if ( Sql.IsEmptyString(sCurrencyID) )
			{
				Session["USER_SETTINGS/CURRENCY"  ] = SplendidDefaults.CurrencyID();
			}
			if ( Sql.IsEmptyString(sTimeZone) )
			{
				Session["USER_SETTINGS/TIMEZONE"  ] = SplendidDefaults.TimeZone();
			}

			// 05/09/2006 Paul.  Use defaults when necessary. 
			// 02/29/2008 Paul.  The config value should only be used as an override.  We should default to the .NET culture value. 
			//string sGROUP_SEPARATOR   = Sql.ToString(Session["USER_SETTINGS/GROUP_SEPARATOR"  ]);
			//string sDECIMAL_SEPARATOR = Sql.ToString(Session["USER_SETTINGS/DECIMAL_SEPARATOR"]);
			//if ( Sql.IsEmptyString(sGROUP_SEPARATOR) )
			//	Session["USER_SETTINGS/GROUP_SEPARATOR"  ] = SplendidDefaults.GroupSeparator();
			//if ( Sql.IsEmptyString(sDECIMAL_SEPARATOR) )
			//	Session["USER_SETTINGS/DECIMAL_SEPARATOR"] = SplendidDefaults.DecimalSeparator();
			// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
			string sSaveQuery  = Sql.ToString(Session["USER_SETTINGS/SAVE_QUERY"]);
			if ( Sql.IsEmptyString(sSaveQuery) )
				Session["USER_SETTINGS/SAVE_QUERY"] = Sql.ToBoolean(Application["CONFIG.save_query"]).ToString();
			// 02/27/2010 Paul.  This area will initialize fields for users created via NTLM. 
			string sGroupTabs  = Sql.ToString(Session["USER_SETTINGS/GROUP_TABS"]);
			if ( Sql.IsEmptyString(sGroupTabs) )
				Session["USER_SETTINGS/GROUP_TABS"] = Sql.ToBoolean(Application["CONFIG.default_group_tabs"]).ToString();
			string sSubPanelTabs  = Sql.ToString(Session["USER_SETTINGS/SUBPANEL_TABS"]);
			if ( Sql.IsEmptyString(sSubPanelTabs) )
				Session["USER_SETTINGS/SUBPANEL_TABS"] = Sql.ToBoolean(Application["CONFIG.default_subpanel_tabs"]).ToString();

			// 04/30/2016 Paul.  If we are connected to the currency service, then now is a good time to check for changes. 
			if ( !Sql.IsEmptyString(Application["CONFIG.CurrencyLayer.AccessKey"]) )
			{
				Guid gCURRENCY_ID = Sql.ToGuid(Session["USER_SETTINGS/CURRENCY"]);
				Currency C10n = Currency.CreateCurrency(Application, gCURRENCY_ID);
				StringBuilder sbErrors = new StringBuilder();
				float dRate = OrderUtils.GetCurrencyConversionRate(Application, C10n.ISO4217, sbErrors);
				if ( sbErrors.Length == 0 )
				{
					C10n.CONVERSION_RATE = dRate;
				}
			}
		}

		// 01/18/2010 Paul.  Provide a way to clear ACL rules so that the admin can see immediate effects of the rules (when debugging). 
		public static void ClearUserACL()
		{
			HttpContext          Context     = HttpContext.Current;
			HttpSessionState     Session     = Context.Session    ;
			
			Hashtable hashSessionKeys = new Hashtable();
			foreach(string sKey in Context.Session.Keys)
			{
				hashSessionKeys.Add(sKey, null);
			}
			// 06/03/2006 Paul.  We can't remove a key when it is used in the enumerator. 
			foreach(string sKey in hashSessionKeys.Keys )
			{
				if ( sKey.StartsWith("ACLACCESS_") || sKey.StartsWith("ACLFIELD_") )
					Context.Session.Remove(sKey);
			}
		}

		// 12/18/2015 Paul.  We need to use a special Portal ACL to block access to Import, Activity Stream. 
		public static void LoadPortalACL()
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory(HttpContext.Current.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				Guid gROLE_ID = new Guid("5B99F57A-3F86-4B44-9324-80E777D0EE04");
				// 09/26/2017 Paul.  Add Archive access right. 
				sSQL = "select MODULE_NAME          " + ControlChars.CrLf
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
					Sql.AddParameter(cmd, "@ROLE_ID", gROLE_ID);
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						while ( rdr.Read() )
						{
							string sMODULE_NAME = Sql.ToString(rdr["MODULE_NAME"]);
							Security.SetUserAccess(sMODULE_NAME, "admin" , Sql.ToInteger(rdr["ACLACCESS_ADMIN" ]));
							Security.SetUserAccess(sMODULE_NAME, "access", Sql.ToInteger(rdr["ACLACCESS_ACCESS"]));
							Security.SetUserAccess(sMODULE_NAME, "view"  , Sql.ToInteger(rdr["ACLACCESS_VIEW"  ]));
							Security.SetUserAccess(sMODULE_NAME, "list"  , Sql.ToInteger(rdr["ACLACCESS_LIST"  ]));
							Security.SetUserAccess(sMODULE_NAME, "edit"  , Sql.ToInteger(rdr["ACLACCESS_EDIT"  ]));
							Security.SetUserAccess(sMODULE_NAME, "delete", Sql.ToInteger(rdr["ACLACCESS_DELETE"]));
							Security.SetUserAccess(sMODULE_NAME, "import", Sql.ToInteger(rdr["ACLACCESS_IMPORT"]));
							Security.SetUserAccess(sMODULE_NAME, "export", Sql.ToInteger(rdr["ACLACCESS_EXPORT"]));
							// 09/26/2017 Paul.  Add Archive access right. 
							Security.SetUserAccess(sMODULE_NAME, "archive", Sql.ToInteger(rdr["ACLACCESS_ARCHIVE"]));
						}
					}
				}
				if ( bEnableACLFieldSecurity )
				{
					// 12/18/2015 Paul.  We need to filter against empty field names. 
					sSQL = "select MODULE_NAME                   " + ControlChars.CrLf
					     + "     , FIELD_NAME                    " + ControlChars.CrLf
					     + "     , ACLACCESS                     " + ControlChars.CrLf
					     + "  from vwACL_FIELD_ACCESS_ByRole     " + ControlChars.CrLf
					     + " where ROLE_ID = @ROLE_ID            " + ControlChars.CrLf
					     + "   and FIELD_NAME is not null        " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ROLE_ID", gROLE_ID);
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								string sMODULE_NAME = Sql.ToString (rdr["MODULE_NAME"]);
								string sFIELD_NAME  = Sql.ToString (rdr["FIELD_NAME" ]);
								int    nACLACCESS   = Sql.ToInteger(rdr["ACLACCESS"  ]);
								Security.SetUserFieldSecurity(sMODULE_NAME, sFIELD_NAME, nACLACCESS);
							}
						}
					}
				}
			}
		}

		// 06/09/2009 Paul.  We need to access LoadUserACL from the SOAP calls. 
		public static void LoadUserACL(Guid gUSER_ID)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory(HttpContext.Current.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 03/09/2010 Paul.  Admin roles are managed separately. 
				// 09/26/2017 Paul.  Add Archive access right. 
				sSQL = "select MODULE_NAME          " + ControlChars.CrLf
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
					Sql.AddParameter(cmd, "@USER_ID", gUSER_ID);
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						while ( rdr.Read() )
						{
							string sMODULE_NAME = Sql.ToString(rdr["MODULE_NAME"]);
							Security.SetUserAccess(sMODULE_NAME, "admin" , Sql.ToInteger(rdr["ACLACCESS_ADMIN" ]));
							Security.SetUserAccess(sMODULE_NAME, "access", Sql.ToInteger(rdr["ACLACCESS_ACCESS"]));
							Security.SetUserAccess(sMODULE_NAME, "view"  , Sql.ToInteger(rdr["ACLACCESS_VIEW"  ]));
							Security.SetUserAccess(sMODULE_NAME, "list"  , Sql.ToInteger(rdr["ACLACCESS_LIST"  ]));
							Security.SetUserAccess(sMODULE_NAME, "edit"  , Sql.ToInteger(rdr["ACLACCESS_EDIT"  ]));
							Security.SetUserAccess(sMODULE_NAME, "delete", Sql.ToInteger(rdr["ACLACCESS_DELETE"]));
							Security.SetUserAccess(sMODULE_NAME, "import", Sql.ToInteger(rdr["ACLACCESS_IMPORT"]));
							Security.SetUserAccess(sMODULE_NAME, "export", Sql.ToInteger(rdr["ACLACCESS_EXPORT"]));
							// 09/26/2017 Paul.  Add Archive access right. 
							Security.SetUserAccess(sMODULE_NAME, "archive", Sql.ToInteger(rdr["ACLACCESS_ARCHIVE"]));
						}
					}
				}
				if ( bEnableACLFieldSecurity )
				{
					sSQL = "select MODULE_NAME                   " + ControlChars.CrLf
					     + "     , FIELD_NAME                    " + ControlChars.CrLf
					     + "     , ACLACCESS                     " + ControlChars.CrLf
					     + "  from vwACL_FIELD_ACCESS_ByUserAlias" + ControlChars.CrLf
					     + " where USER_ID = @USER_ID            " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@USER_ID", gUSER_ID);
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								string sMODULE_NAME = Sql.ToString (rdr["MODULE_NAME"]);
								string sFIELD_NAME  = Sql.ToString (rdr["FIELD_NAME" ]);
								int    nACLACCESS   = Sql.ToInteger(rdr["ACLACCESS"  ]);
								Security.SetUserFieldSecurity(sMODULE_NAME, sFIELD_NAME, nACLACCESS);
							}
						}
					}
				}
			}
		}

		// 11/11/2010 Paul.  Provide quick access to ACL Roles and Teams. 
		public static void LoadACLRoles(Guid gUSER_ID)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory(HttpContext.Current.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 03/09/2010 Paul.  Admin roles are managed separately. 
				sSQL = "select ROLE_NAME            " + ControlChars.CrLf
				     + "  from vwACL_ROLES_USERS    " + ControlChars.CrLf
				     + " where USER_ID = @USER_ID   " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@USER_ID", gUSER_ID);
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						while ( rdr.Read() )
						{
							string sROLE_NAME = Sql.ToString(rdr["ROLE_NAME"]);
							Security.SetACLRoleAccess(sROLE_NAME);
						}
					}
				}
			}
		}

		public static void LoadTeams(Guid gUSER_ID)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory(HttpContext.Current.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 03/09/2010 Paul.  Admin roles are managed separately. 
				sSQL = "select distinct TEAM_NAME     " + ControlChars.CrLf
				     + "  from vwTEAM_MEMBERSHIPS_List" + ControlChars.CrLf
				     + " where USER_ID = @USER_ID     " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@USER_ID", gUSER_ID);
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						while ( rdr.Read() )
						{
							string sTEAM_NAME = Sql.ToString(rdr["TEAM_NAME"]);
							Security.SetTeamAccess(sTEAM_NAME);
						}
					}
				}
			}
		}

		// 02/20/2011 Paul.  Log the failure so that we can lockout the user. 
		// The current implementation uses the Application cache instead of a database table. 
		public static void LoginTracking(HttpApplicationState Application, string sUSER_NAME, bool bValidUser)
		{
			if ( bValidUser )
			{
				Application.Remove("Users.LoginFailures." + sUSER_NAME);
			}
			else
			{
				int nLoginFailures = Sql.ToInteger(Application["Users.LoginFailures." + sUSER_NAME]);
				Application["Users.LoginFailures." + sUSER_NAME] = nLoginFailures + 1;
			}
		}

		public static int LoginFailures(HttpApplicationState Application, string sUSER_NAME)
		{
			return Sql.ToInteger(Application["Users.LoginFailures." + sUSER_NAME]);
		}

		// 04/16/2013 Paul.  Allow system to be restricted by IP Address. 
		public static bool InvalidIPAddress(HttpApplicationState Application, string sUserHostAddress)
		{
			string sIPAddresses = Sql.ToString(Application["CONFIG.Authentication.IPAddresses"]);
			// 04/16/2013 Paul.  Allow the separator to be either a comma or a space character. 
			sIPAddresses = sIPAddresses.Replace(",", " ");
			sIPAddresses = sIPAddresses.Trim();
			// 04/16/2013 Paul.  If no IP Addresses are specified, then assume that all are valid. 
			if ( !Sql.IsEmptyString(sIPAddresses) )
			{
				string[] arrIPAddresses = sIPAddresses.Split(' ');
				foreach ( string sValidIP in arrIPAddresses )
				{
					if ( sUserHostAddress == sValidIP )
						return false;
				}
				return true;
			}
			return false;
		}

		public static bool LoginUser(string sUSER_NAME, string sPASSWORD, string sTHEME, string sLANGUAGE, string sUSER_DOMAIN, bool bIS_ADMIN)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = Context.Application;
			HttpSessionState     Session     = Context.Session    ;
			HttpRequest          Request     = Context.Request    ;

			bool bValidUser = false;
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 03/22/2006 Paul.  The user name should be case-insignificant.  The password is case-significant. 
				// 03/22/2006 Paul.  DB2 does not like lower(USER_NAME) = lower(@USER_NAME).  It returns the following error. 
				// ERROR [42610] [IBM][DB2/NT] SQL0418N A statement contains a use of a parameter marker that is not valid. SQLSTATE=42610 
				// 05/23/2006 Paul.  Use vwUSERS_Login so that USER_HASH can be removed from vwUSERS to prevent its use in reports. 
				// 11/25/2006 Paul.  Include TEAM_ID and TEAM_NAME as they will be used everywhere. 
				// 03/16/2010 Paul.  Add IS_ADMIN_DELEGATE. 
				// 03/16/2010 Paul.  Retrieve all fields to allow field errors to be caught and reported. 
				sSQL = "select *            " + ControlChars.CrLf
				     + "  from vwUSERS_Login" + ControlChars.CrLf;
				// 03/16/2010 Paul.  Stop using lower() on SQL Server to increase performance. 
				if ( Sql.IsOracle(con) || Sql.IsDB2(con) || Sql.IsPostgreSQL(con) )
					sSQL += " where lower(USER_NAME) = @USER_NAME" + ControlChars.CrLf;
				else
					sSQL += " where USER_NAME = @USER_NAME" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					// 01/15/2009 Paul.  On slow systems running Express, the first login event can take longer than expected, so just wait forever.
					cmd.CommandTimeout = 0;
/*
#if DEBUG
					if ( sUSER_NAME == "paulrony" && Sql.ToString(Application["SplendidProvider"]) == "MySql.Data" )
						sUSER_NAME = "admin";
#endif
*/
					// 03/22/2006 Paul.  Convert the name to lowercase here. 
					Sql.AddParameter(cmd, "@USER_NAME", sUSER_NAME.ToLower());
					string sLOGIN_TYPE = "Windows";
					// 11/19/2005 Paul.  sUSER_DOMAIN is used to determine if NTLM is enabled. 
					if ( Sql.IsEmptyString(sUSER_DOMAIN) )
					{
						sLOGIN_TYPE = "Anonymous";
						if ( !Sql.IsEmptyString(sPASSWORD) )
						{
							string sUSER_HASH = Security.HashPassword(sPASSWORD);
							cmd.CommandText += "   and USER_HASH = @USER_HASH" + ControlChars.CrLf;
							Sql.AddParameter(cmd, "@USER_HASH", sUSER_HASH);
						}
						else
						{
							// 11/19/2005 Paul.  Handle the special case of the password stored as NULL or empty string. 
							cmd.CommandText += "   and (USER_HASH = '' or USER_HASH is null)" + ControlChars.CrLf;
						}
					}
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						//string sApplicationPath = Sql.ToString(Application["rootURL"]);
						Guid gUSER_LOGIN_ID = Guid.Empty;
						if ( rdr.Read() )
						{
							// 11/19/2005 Paul.  Clear all session values. 
							// 02/28/2007 Paul.  Centralize session reset to prepare for WebParts. 
							Security.Clear();
							Security.USER_ID     = Sql.ToGuid   (rdr["ID"         ]);
							Security.USER_NAME   = Sql.ToString (rdr["USER_NAME"  ]);
							Security.FULL_NAME   = Sql.ToString (rdr["FULL_NAME"  ]);
							Security.IS_ADMIN    = Sql.ToBoolean(rdr["IS_ADMIN"   ]);
							Security.PORTAL_ONLY = Sql.ToBoolean(rdr["PORTAL_ONLY"]);
							try
							{
								// 11/25/2006 Paul.  Keep the private team information in the Session for quick access. 
								// The private team may be replaced by the desired default in User Preferences. 
								Security.TEAM_ID        = Sql.ToGuid  (rdr["TEAM_ID"       ]);
								Security.TEAM_NAME      = Sql.ToString(rdr["TEAM_NAME"     ]);
							}
							catch(Exception ex)
							{
								// 11/25/2006 Paul.  Ignore any team related issue as this error could prevent 
								// anyone from logging in.  The CRM would then be completely dead. 
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Failed to read TEAM_ID. " + ex.Message);
								//HttpContext.Current.Response.Write("Failed to read TEAM_ID. " + ex.Message);
							}
							try
							{
								// 04/04/2010 Paul.  Add Exchange Alias so that we can enable/disable Exchange appropriately. 
								Security.EXCHANGE_ALIAS = Sql.ToString(rdr["EXCHANGE_ALIAS"]);
								// 04/07/2010 Paul.  Add Exchange Email as it will be need for Push Subscriptions. 
								Security.EXCHANGE_EMAIL = Sql.ToString(rdr["EXCHANGE_EMAIL"]);
								// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
								// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
								Security.EMAIL1 = Sql.ToString(rdr["EMAIL1"]);
							}
							catch(Exception ex)
							{
								// 11/25/2006 Paul.  Ignore any team related issue as this error could prevent 
								// anyone from logging in.  The CRM would then be completely dead. 
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Failed to read EXCHANGE_ALIAS. " + ex.Message);
								//HttpContext.Current.Response.Write("Failed to read EXCHANGE_ALIAS. " + ex.Message);
							}
							try
							{
								// 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
								Security.MAIL_SMTPUSER = Sql.ToString (rdr["MAIL_SMTPUSER"    ]);
								Security.MAIL_SMTPPASS = Sql.ToString (rdr["MAIL_SMTPPASS"    ]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Failed to read MAIL_SMTPUSER. " + ex.Message);
								//HttpContext.Current.Response.Write("Failed to read MAIL_SMTPUSER. " + ex.Message);
							}
							// 01/17/2017 Paul.  The gEXCHANGE_ID is to lookup the OAuth credentials. 
							try
							{
								Session["OFFICE365_OAUTH_ENABLED"] = Sql.ToBoolean(rdr["OFFICE365_OAUTH_ENABLED"]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Failed to read OFFICE365_OAUTH_ENABLED. " + ex.Message);
								//HttpContext.Current.Response.Write("Failed to read OFFICE365_OAUTH_ENABLED. " + ex.Message);
							}
							// 01/24/2017 Paul.  Session access to GoogleApps flag. 
							try
							{
								Session["GOOGLEAPPS_OAUTH_ENABLED"] = Sql.ToBoolean(rdr["GOOGLEAPPS_OAUTH_ENABLED"]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Failed to read GOOGLEAPPS_OAUTH_ENABLED. " + ex.Message);
								//HttpContext.Current.Response.Write("Failed to read OFFICE365_OAUTH_ENABLED. " + ex.Message);
							}
							try
							{
								// 03/16/2010 Paul.  Add IS_ADMIN_DELEGATE. 
								Security.IS_ADMIN_DELEGATE = Sql.ToBoolean(rdr["IS_ADMIN_DELEGATE"]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Failed to read IS_ADMIN_DELEGATE. " + ex.Message);
								//HttpContext.Current.Response.Write("Failed to read IS_ADMIN_DELEGATE. " + ex.Message);
							}
							// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
							try
							{
								Security.PRIMARY_ROLE_ID   = Sql.ToGuid   (rdr["PRIMARY_ROLE_ID"  ]);
								Security.PRIMARY_ROLE_NAME = Sql.ToString (rdr["PRIMARY_ROLE_NAME"]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Failed to read PRIMARY_ROLE_NAME. " + ex.Message);
								//HttpContext.Current.Response.Write("Failed to read PRIMARY_ROLE_NAME. " + ex.Message);
							}
							try
							{
								// 02/22/2011 Paul.  Add PWD_LAST_CHANGED and SYSTEM_GENERATED_PASSWORD. 
								// 02/22/2011 Paul.  Password expiration only applies to Anonymous Authentication. 
								if ( sLOGIN_TYPE == "Anonymous" )
								{
									bool     bSYSTEM_GENERATED_PASSWORD = Sql.ToBoolean (rdr["SYSTEM_GENERATED_PASSWORD"]);
									DateTime dtPWD_LAST_CHANGED         = Sql.ToDateTime(rdr["PWD_LAST_CHANGED"         ]);
									int nExpirationDays = Crm.Password.ExpirationDays(Application);
									if ( nExpirationDays > 0 )
									{
										if ( dtPWD_LAST_CHANGED == DateTime.MinValue || dtPWD_LAST_CHANGED.AddDays(nExpirationDays) < DateTime.Now )
										{
											// 02/22/2011 Paul.  Use the same System Generated flag to force the password change. 
											bSYSTEM_GENERATED_PASSWORD = true;
										}
									}
									Session["SYSTEM_GENERATED_PASSWORD"] = bSYSTEM_GENERATED_PASSWORD;
								}
							}
							catch(Exception ex)
							{
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Failed to read SYSTEM_GENERATED_PASSWORD. " + ex.Message);
								//HttpContext.Current.Response.Write("Failed to read SYSTEM_GENERATED_PASSWORD. " + ex.Message);
							}
							
							Guid gUSER_ID = Sql.ToGuid(rdr["ID"]);
							// 03/02/2008 Paul.  Log the logins. 
							// 10/27/2010 Paul.  No need to log the logins on a portable device. 
							if ( !Sql.IsEffiProz(con) )
								SqlProcs.spUSERS_LOGINS_InsertOnly(ref gUSER_LOGIN_ID, gUSER_ID, sUSER_NAME, sLOGIN_TYPE, "Succeeded", Session.SessionID, Request.UserHostName, Request.Url.Host, Request.Path, Request.AppRelativeCurrentExecutionFilePath, Request.UserAgent);
							Security.USER_LOGIN_ID = gUSER_LOGIN_ID;
							// 02/20/2011 Paul.  Log the success so that we can lockout the user. 
							SplendidInit.LoginTracking(Application, sUSER_NAME, true);

							// 08/08/2006 Paul.  Don't supply the Language as it prevents the user value from being used. 
							// This bug is a hold-over from the time we removed the Lauguage combo from the login screen. 
							LoadUserPreferences(gUSER_ID, sTHEME, String.Empty);
							LoadUserACL(gUSER_ID);
							// 11/11/2010 Paul.  Provide quick access to ACL Roles and Teams. 
							LoadACLRoles(gUSER_ID);
							LoadTeams(gUSER_ID);
							bValidUser = true;
							SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "User login.");
						}
						else if ( Security.IsWindowsAuthentication() )
						{
							rdr.Close();
							// 01/31/2022 Paul.  It is getting more difficult to determine if windows user is an admin. 
							if ( !bIS_ADMIN )
							{
								cmd.Parameters.Clear();
								cmd.CommandText = "select count(*) from vwUSERS where ID > '00000000-0000-0000-0000-0000000000ff'";
								int nUsers = Sql.ToInteger(cmd.ExecuteScalar());
								// 01/31/2022 Paul.  If this is the first windows user being created, then make them an admin. 
								if ( nUsers == 0 )
									bIS_ADMIN = true;
							}
							// 11/04/2005.  If user does not exist, then create it, but only if NTLM is used. 
							Guid gUSER_ID = Guid.Empty;
							SqlProcs.spUSERS_InsertNTLM(ref gUSER_ID, sUSER_DOMAIN, sUSER_NAME, bIS_ADMIN);

							// 11/19/2005 Paul.  Clear all session values. 
							// 02/28/2007 Paul.  Centralize session reset to prepare for WebParts. 
							Security.Clear();
							Security.USER_ID     = gUSER_ID  ;
							Security.USER_NAME   = sUSER_NAME;
							Security.IS_ADMIN    = bIS_ADMIN ;
							Security.PORTAL_ONLY = false     ;

							// 03/02/2008 Paul.  Log the logins. 
							// 10/27/2010 Paul.  No need to log the logins on a portable device. 
							if ( !Sql.IsEffiProz(con) )
								SqlProcs.spUSERS_LOGINS_InsertOnly(ref gUSER_LOGIN_ID, gUSER_ID, sUSER_NAME, sLOGIN_TYPE, "Succeeded", Session.SessionID, Request.UserHostName, Request.Url.Host, Request.Path, Request.AppRelativeCurrentExecutionFilePath, Request.UserAgent);
							Security.USER_LOGIN_ID = gUSER_LOGIN_ID;
							// 02/20/2011 Paul.  Log the success so that we can lockout the user. 
							SplendidInit.LoginTracking(Application, sUSER_NAME, true);

							// 11/25/2006 Paul.  Retrieve TEAM_ID and TEAM_NAME as they will be used everywhere. 
							sSQL = "select TEAM_ID      " + ControlChars.CrLf
							     + "     , TEAM_NAME    " + ControlChars.CrLf
							     + "  from vwUSERS_Login" + ControlChars.CrLf
							     + " where ID = @ID     " + ControlChars.CrLf;
							cmd.Parameters.Clear();
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", Security.USER_ID);
							using ( IDataReader rdrTeam = cmd.ExecuteReader() )
							{
								if ( rdrTeam.Read() )
								{
									try
									{
										// 11/25/2006 Paul.  Keep the private team information in the Session for quick access. 
										// The private team may be replaced by the desired default in User Preferences. 
										Security.TEAM_ID   = Sql.ToGuid   (rdrTeam["TEAM_ID"  ]);
										Security.TEAM_NAME = Sql.ToString (rdrTeam["TEAM_NAME"]);
									}
									catch(Exception ex)
									{
										SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Failed to read TEAM_ID. " + ex.Message);
										//HttpContext.Current.Response.Write("Failed to read TEAM_ID. " + ex.Message);
									}
								}
							}

							// 11/21/2005 Paul.  Load the preferences to initialize cuture, date, time and currency preferences.
							LoadUserPreferences(gUSER_ID, String.Empty, String.Empty);
							LoadUserACL(gUSER_ID);
							// 11/11/2010 Paul.  Provide quick access to ACL Roles and Teams. 
							LoadACLRoles(gUSER_ID);
							LoadTeams(gUSER_ID);
							bValidUser = true;
							SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "User login.");
						}
						else
						{
							// 03/02/2008 Paul.  Log the logins. 
							// 10/27/2010 Paul.  No need to log the logins on a portable device. 
							if ( !Sql.IsEffiProz(con) )
								SqlProcs.spUSERS_LOGINS_InsertOnly(ref gUSER_LOGIN_ID, Guid.Empty, sUSER_NAME, sLOGIN_TYPE, "Failed", Session.SessionID, Request.UserHostName, Request.Url.Host, Request.Path, Request.AppRelativeCurrentExecutionFilePath, Request.UserAgent);
							// 02/20/2011 Paul.  Log the failure so that we can lockout the user. 
							SplendidInit.LoginTracking(Application, sUSER_NAME, false);
							// 11/22/2005 Paul.  Initialize preferences even if login fails so that the theme gets set to the default value. 
							LoadUserPreferences(Guid.Empty, String.Empty, String.Empty);
						}
					}
				}
			}
			return bValidUser; // throw(new Exception("Users.ERR_INVALID_PASSWORD"));
		}

		// 03/19/2011 Paul.  Facebook login uses the FACEBOOK_ID field. 
		public static bool FacebookLoginUser(string sFACEBOOK_ID)
		{
			bool bValidUser = false;
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select ID                        " + ControlChars.CrLf
				     + "  from vwUSERS_Login             " + ControlChars.CrLf
				     + " where FACEBOOK_ID = @FACEBOOK_ID" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					cmd.CommandTimeout = 0;
					Sql.AddParameter(cmd, "@FACEBOOK_ID", sFACEBOOK_ID.ToLower());
					Guid gUSER_ID = Sql.ToGuid(cmd.ExecuteScalar());
					if ( !Sql.IsEmptyGuid(gUSER_ID) )
					{
						LoginUser(gUSER_ID, "facebook");
						bValidUser = true;
					}
				}
			}
			return bValidUser;
		}

		// 04/11/2011 Paul.  We need to allow a login by ID in order to support impersonation by admin. 
		public static void LoginUser(Guid gUSER_ID, string sLOGIN_TYPE)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = Context.Application;
			HttpSessionState     Session     = Context.Session    ;
			HttpRequest          Request     = Context.Request    ;

			DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select *            " + ControlChars.CrLf
				     + "  from vwUSERS_Login" + ControlChars.CrLf
				     + " where ID = @ID     " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					cmd.CommandTimeout = 0;
					Sql.AddParameter(cmd, "@ID", gUSER_ID);
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						Guid gUSER_LOGIN_ID = Guid.Empty;
						if ( rdr.Read() )
						{
							Security.Clear();
							Security.USER_ID                    = Sql.ToGuid    (rdr["ID"                       ]);
							Security.USER_NAME                  = Sql.ToString  (rdr["USER_NAME"                ]);
							Security.FULL_NAME                  = Sql.ToString  (rdr["FULL_NAME"                ]);
							Security.IS_ADMIN                   = Sql.ToBoolean (rdr["IS_ADMIN"                 ]);
							Security.PORTAL_ONLY                = Sql.ToBoolean (rdr["PORTAL_ONLY"              ]);
							Security.TEAM_ID                    = Sql.ToGuid    (rdr["TEAM_ID"                  ]);
							Security.TEAM_NAME                  = Sql.ToString  (rdr["TEAM_NAME"                ]);
							Security.EXCHANGE_ALIAS             = Sql.ToString  (rdr["EXCHANGE_ALIAS"           ]);
							Security.EXCHANGE_EMAIL             = Sql.ToString  (rdr["EXCHANGE_EMAIL"           ]);
							Security.EMAIL1                     = Sql.ToString  (rdr["EMAIL1"                   ]);
							Security.MAIL_SMTPUSER              = Sql.ToString  (rdr["MAIL_SMTPUSER"            ]);
							Security.MAIL_SMTPPASS              = Sql.ToString  (rdr["MAIL_SMTPPASS"            ]);
							Security.IS_ADMIN_DELEGATE          = Sql.ToBoolean (rdr["IS_ADMIN_DELEGATE"        ]);
							// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
							try
							{
								Security.PRIMARY_ROLE_ID   = Sql.ToGuid   (rdr["PRIMARY_ROLE_ID"  ]);
								Security.PRIMARY_ROLE_NAME = Sql.ToString (rdr["PRIMARY_ROLE_NAME"]);
							}
							catch
							{
							}
							// 01/17/2017 Paul.  The gEXCHANGE_ID is to lookup the OAuth credentials. 
							try
							{
								Session["OFFICE365_OAUTH_ENABLED"] = Sql.ToBoolean(rdr["OFFICE365_OAUTH_ENABLED"]);
							}
							catch
							{
							}
							// 01/24/2017 Paul.  Session access to GoogleApps flag. 
							try
							{
								Session["GOOGLEAPPS_OAUTH_ENABLED"] = Sql.ToBoolean(rdr["GOOGLEAPPS_OAUTH_ENABLED"]);
							}
							catch
							{
							}
							string sUSER_NAME = Security.USER_NAME;
							// 03/19/2011 Paul.  Facebook login cannot expire. 
							// 04/11/2011 Paul.  Impersonation does need to handle expiration. 
							/*
							bool     bSYSTEM_GENERATED_PASSWORD = Sql.ToBoolean (rdr["SYSTEM_GENERATED_PASSWORD"]);
							DateTime dtPWD_LAST_CHANGED         = Sql.ToDateTime(rdr["PWD_LAST_CHANGED"         ]);
							int nExpirationDays = Crm.Password.ExpirationDays(Application);
							if ( nExpirationDays > 0 )
							{
								if ( dtPWD_LAST_CHANGED == DateTime.MinValue || dtPWD_LAST_CHANGED.AddDays(nExpirationDays) < DateTime.Now )
								{
									// 02/22/2011 Paul.  Use the same System Generated flag to force the password change. 
									bSYSTEM_GENERATED_PASSWORD = true;
								}
							}
							Session["SYSTEM_GENERATED_PASSWORD"] = bSYSTEM_GENERATED_PASSWORD;
							*/
							
							if ( !Sql.IsEffiProz(con) )
								SqlProcs.spUSERS_LOGINS_InsertOnly(ref gUSER_LOGIN_ID, gUSER_ID, sUSER_NAME, sLOGIN_TYPE, "Succeeded", Session.SessionID, Request.UserHostName, Request.Url.Host, Request.Path, Request.AppRelativeCurrentExecutionFilePath, Request.UserAgent);
							Security.USER_LOGIN_ID = gUSER_LOGIN_ID;
							SplendidInit.LoginTracking(Application, sUSER_NAME, true);

							LoadUserPreferences(gUSER_ID, String.Empty, String.Empty);
							LoadUserACL(gUSER_ID);
							LoadACLRoles(gUSER_ID);
							LoadTeams(gUSER_ID);
							SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "User login.");
						}
						else
						{
							throw(new Exception("Users.ERR_INVALID_USER"));
						}
					}
				}
			}
		}

		// 04/13/2009 Paul.  We need a separate login function for portal users. 
		public static bool LoginPortalUser(string sUSER_NAME, string sPASSWORD, string sTHEME, string sLANGUAGE)
		{
			return LoginPortalUser(sUSER_NAME, sPASSWORD, sTHEME, sLANGUAGE, false);
		}
		
		// 03/19/2011 Paul.  If the facebook user has been authenticated, then all we will have is the user name. 
		public static bool LoginPortalUser(string sUSER_NAME, string sPASSWORD, string sTHEME, string sLANGUAGE, bool bFacebookLogin)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = Context.Application;
			HttpSessionState     Session     = Context.Session    ;
			HttpRequest          Request     = Context.Request    ;

			bool bValidUser = false;
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select ID                                   " + ControlChars.CrLf
				     + "     , PORTAL_NAME                          " + ControlChars.CrLf
				     + "     , FULL_NAME                            " + ControlChars.CrLf
				     + "     , TEAM_ID                              " + ControlChars.CrLf
				     + "     , TEAM_NAME                            " + ControlChars.CrLf
				     + "  from vwCONTACTS_PortalLogin               " + ControlChars.CrLf
				     + " where lower(PORTAL_NAME) = @PORTAL_NAME    " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					// 01/15/2009 Paul.  On slow systems running Express, the first login event can take longer than expected, so just wait forever.
					cmd.CommandTimeout = 0;
					// 03/22/2006 Paul.  Convert the name to lowercase here. 
					Sql.AddParameter(cmd, "@PORTAL_NAME", sUSER_NAME.ToLower());
					
					string sLOGIN_TYPE = "Anonymous";
					// 03/19/2011 Paul.  If the facebook user has been authenticated, then all we will have is the user name. 
					if ( !bFacebookLogin )
					{
						cmd.CommandText += "   and PORTAL_PASSWORD    = @PORTAL_PASSWORD" + ControlChars.CrLf;
						string sUSER_HASH = Security.HashPassword(sPASSWORD);
						Sql.AddParameter(cmd, "@PORTAL_PASSWORD", sUSER_HASH);
					}
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						Guid gUSER_LOGIN_ID = Guid.Empty;
						if ( rdr.Read() )
						{
							// 11/19/2005 Paul.  Clear all session values. 
							// 02/28/2007 Paul.  Centralize session reset to prepare for WebParts. 
							Security.Clear();
							Security.USER_ID     = Sql.ToGuid   (rdr["ID"         ]);
							Security.USER_NAME   = Sql.ToString (rdr["PORTAL_NAME"]);
							Security.FULL_NAME   = Sql.ToString (rdr["FULL_NAME"  ]);
							Security.IS_ADMIN    = false;
							Security.PORTAL_ONLY = true;
							Security.TEAM_ID     = Sql.ToGuid   (rdr["TEAM_ID"    ]);
							Security.TEAM_NAME   = Sql.ToString (rdr["TEAM_NAME"  ]);
							
							Guid gUSER_ID = Sql.ToGuid(rdr["ID"]);
							// 03/02/2008 Paul.  Log the logins. 
							// 10/27/2010 Paul.  No need to log the logins on a portable device. 
							if ( !Sql.IsEffiProz(con) )
								SqlProcs.spUSERS_LOGINS_InsertOnly(ref gUSER_LOGIN_ID, gUSER_ID, sUSER_NAME, sLOGIN_TYPE, "Succeeded", Session.SessionID, Request.UserHostName, Request.Url.Host, Request.Path, Request.AppRelativeCurrentExecutionFilePath, Request.UserAgent);
							Security.USER_LOGIN_ID = gUSER_LOGIN_ID;
							// 02/20/2011 Paul.  Log the success so that we can lockout the user. 
							SplendidInit.LoginTracking(Application, sUSER_NAME, true);

							// 08/08/2006 Paul.  Don't supply the Language as it prevents the user value from being used. 
							// This bug is a hold-over from the time we removed the Lauguage combo from the login screen. 
							LoadUserPreferences(gUSER_ID, sTHEME, String.Empty);
							LoadUserACL(gUSER_ID);
							// 12/18/2015 Paul.  We need to use a special Portal ACL to block access to Import, Activity Stream. 
							LoadPortalACL();
							// 11/11/2010 Paul.  Provide quick access to ACL Roles and Teams. 
							LoadACLRoles(gUSER_ID);
							LoadTeams(gUSER_ID);
							bValidUser = true;
							SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "User login.");
						}
						else
						{
							// 03/02/2008 Paul.  Log the logins. 
							// 10/27/2010 Paul.  No need to log the logins on a portable device. 
							if ( !Sql.IsEffiProz(con) )
								SqlProcs.spUSERS_LOGINS_InsertOnly(ref gUSER_LOGIN_ID, Guid.Empty, sUSER_NAME, sLOGIN_TYPE, "Failed", Session.SessionID, Request.UserHostName, Request.Url.Host, Request.Path, Request.AppRelativeCurrentExecutionFilePath, Request.UserAgent);
							// 02/20/2011 Paul.  Log the failure so that we can lockout the user. 
							SplendidInit.LoginTracking(Application, sUSER_NAME, false);
							// 11/22/2005 Paul.  Initialize preferences even if login fails so that the theme gets set to the default value. 
							LoadUserPreferences(Guid.Empty, String.Empty, String.Empty);
						}
					}
				}
			}
			return bValidUser; // throw(new Exception("Users.ERR_INVALID_PASSWORD"));
		}

		public static void ChangeTheme(string sTHEME, string sLANGUAGE)
		{
			// 05/04/2010 Paul.  Theme may not be available in the master page. 
			if ( !Sql.IsEmptyString(sTHEME) )
			{
				string sApplicationPath = Sql.ToString(HttpContext.Current.Application["rootURL"]);
				// 04/26/2006 Paul.  The theme variable also needs to be updated.
				HttpContext.Current.Session["USER_SETTINGS/THEME"  ] = sTHEME;
				// 03/07/2007 Paul.  Version 1.4 moved its themes folder to the .NET 2.0 default App_Themes. 
				HttpContext.Current.Session["themeURL"             ] = sApplicationPath + "App_Themes/" + sTHEME + "/";
			}
			// 05/04/2010 Paul.  Language may not be available in the master page. 
			// 04/20/2018 Paul.  Alternate language mapping to convert en-CA to en_US. 
			if ( !Sql.IsEmptyString(sLANGUAGE) )
				HttpContext.Current.Session["USER_SETTINGS/CULTURE"] = L10N.AlternateLanguage(HttpContext.Current.Application, sLANGUAGE);
		}

		public static bool LoginUser(string sUSER_NAME, string sPASSWORD, string sTHEME, string sLANGUAGE)
		{
			return LoginUser(sUSER_NAME, sPASSWORD, sTHEME, sLANGUAGE, String.Empty, false);
		}

		public static void InitSession(HttpContext Context)
		{
			InitAppURLs(Context);
			try
			{
				// 11/22/2005 Paul.  Always initialize the theme and language. 
				HttpSessionState Session = Context.Session ;
				string sTheme = SplendidDefaults.Theme();
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				Session["Browser"            ] = Context.Request.Browser.Browser;
				Session["IsMobileDevice"     ] = Context.Request.Browser.IsMobileDevice;
				Session["SupportsPopups"     ] = true;
				Session["AllowAutoComplete"  ] = true;
				Session["SupportsSpeech"     ] = false;
				Session["SupportsHandwriting"] = false;
				Session["SupportsTouch"      ] = false;
				// 05/17/2013 Paul.  We need to be able to detect draggable. 
				Session["SupportsDraggable"  ] = true;
				if ( Context.Request.Browser.Browser == "IE" )
				{
					float fVersion = 0;
					if ( float.TryParse(Context.Request.Browser.Version, out fVersion) )
					{
						if ( fVersion < 9.0 )
							Session["SupportsDraggable"  ] = false;
					}
				}
				// 07/11/2011 Paul.  UserAgent might be null, and it was causing bad XML data in the language packs. 
				string sUserAgent = Sql.ToString(Context.Request.UserAgent);
				if ( sUserAgent.Contains("Android") )
				{
					// 07/28/2012 Paul.  Android Tablet should not be treated as a mobile device. 
					// http://stackoverflow.com/questions/5341637/how-do-detect-android-tablets-in-general-useragent
					if ( sUserAgent.Contains("Mobile") )
					{
						Session["Browser"          ] = "Android Mobile";
						Session["IsMobileDevice"   ] = true;
					}
					else
					{
						Session["Browser"          ] = "Android Tablet";
						Session["IsMobileDevice"   ] = false;
					}
					Session["SupportsPopups"     ] = true;  // 11/24/2010 Paul.  Confirmed support for popups. 
					Session["AllowAutoComplete"  ] = true;  // 11/24/2010 Paul.  Confirmed support for auto-complete. 
					Session["SupportsSpeech"     ] = true;  // 08/22/2012 Paul.  Android devices should support speech. 
					Session["SupportsHandwriting"] = true;  // 08/22/2012 Paul.  Android devices should support handwriting. 
					Session["SupportsTouch"      ] = true;  // 11/14/2012 Paul.  Assume all android devices support touch. 
				}
				else if ( sUserAgent.Contains("BlackBerry") )
				{
					Session["Browser"          ] = "BlackBerry";
					Session["IsMobileDevice"   ] = true;
					Session["SupportsPopups"   ] = false;
					Session["AllowAutoComplete"] = false;
					if ( !Sql.IsEmptyString(Context.Request.Browser["supportsPopups"]) )
						Session["SupportsPopups"] = Sql.ToBoolean(Context.Request.Browser["supportsPopups"]);
					if ( !Sql.IsEmptyString(Context.Request.Browser["AjaxAutoComplete"]) )
						Session["AllowAutoComplete"] = Sql.ToBoolean(Context.Request.Browser["AjaxAutoComplete"]);
				}
				else if ( sUserAgent.Contains("IEMobile") )
				{
					Session["Browser"          ] = "IEMobile";
					Session["IsMobileDevice"   ] = true;
					Session["SupportsPopups"   ] = false;
					Session["AllowAutoComplete"] = false;
				}
				// 07/28/2012 Paul.  iPad should not be treated as a mobile device. 
				// http://www.labnol.org/tech/ipad-user-agent-string/13230/
				else if ( sUserAgent.Contains("iPad") )
				{
					Session["Browser"            ] = "iPad";
					Session["IsMobileDevice"     ] = false;
					Session["SupportsPopups"     ] = true;
					Session["AllowAutoComplete"  ] = true;
					Session["SupportsSpeech"     ] = true;  // 08/22/2012 Paul.  Apple devices should support speech. 
					Session["SupportsHandwriting"] = true;  // 08/22/2012 Paul.  Apple devices should support handwriting. 
					Session["SupportsTouch"      ] = true;  // 11/14/2012 Paul.  All iPads support touch. 
				}
				else if ( sUserAgent.Contains("iPhone") )
				{
					Session["Browser"            ] = "iPhone";
					Session["IsMobileDevice"     ] = true;
					Session["SupportsPopups"     ] = true;  // 11/24/2010 Paul.  Confirmed support for popups. 
					Session["AllowAutoComplete"  ] = true;  // 11/24/2010 Paul.  Confirmed support for auto-complete. 
					Session["SupportsSpeech"     ] = true;  // 08/22/2012 Paul.  Apple devices should support speech. 
					Session["SupportsHandwriting"] = true;  // 08/22/2012 Paul.  Apple devices should support handwriting. 
					Session["SupportsTouch"      ] = true;  // 11/14/2012 Paul.  All iPhones support touch. 
				}
				else if ( sUserAgent.Contains("iPod") )
				{
					Session["Browser"            ] = "iPod";
					Session["IsMobileDevice"     ] = true;
					Session["SupportsPopups"     ] = true;
					Session["AllowAutoComplete"  ] = true;
					Session["SupportsSpeech"     ] = true;  // 08/22/2012 Paul.  Apple devices should support speech. 
					Session["SupportsHandwriting"] = true;  // 08/22/2012 Paul.  Apple devices should support handwriting. 
					Session["SupportsTouch"      ] = true;  // 11/14/2012 Paul.  All iPods support touch. 
				}
				else if ( sUserAgent.Contains("Opera Mini") )
				{
					Session["Browser"          ] = "Opera Mini";
					Session["IsMobileDevice"   ] = true;
					Session["SupportsPopups"   ] = false;  // 11/24/2010 Paul.  Cannot confirm support. 
					Session["AllowAutoComplete"] = false;  // 11/24/2010 Paul.  Cannot confirm support. 
					if ( !Sql.IsEmptyString(Context.Request.Browser["supportsPopups"]) )
						Session["SupportsPopups"] = Sql.ToBoolean(Context.Request.Browser["supportsPopups"]);
					if ( !Sql.IsEmptyString(Context.Request.Browser["AjaxAutoComplete"]) )
						Session["AllowAutoComplete"] = Sql.ToBoolean(Context.Request.Browser["AjaxAutoComplete"]);
				}
				else if ( sUserAgent.Contains("Palm") )
				{
					Session["Browser"          ] = "Palm";
					Session["IsMobileDevice"   ] = true;
					Session["SupportsPopups"   ] = false;  // 11/24/2010 Paul.  Cannot confirm support. 
					Session["AllowAutoComplete"] = false;  // 11/24/2010 Paul.  Cannot confirm support. 
					if ( !Sql.IsEmptyString(Context.Request.Browser["supportsPopups"]) )
						Session["SupportsPopups"] = Sql.ToBoolean(Context.Request.Browser["supportsPopups"]);
					if ( !Sql.IsEmptyString(Context.Request.Browser["AjaxAutoComplete"]) )
						Session["AllowAutoComplete"] = Sql.ToBoolean(Context.Request.Browser["AjaxAutoComplete"]);
				}
				else if ( sUserAgent.Contains("Chrome") )
				{
					// 08/31/2012 Paul.  Lets just assume that all Chrome browsers now support speech and handwriting. 
					Session["SupportsSpeech"     ] = true;
					Session["SupportsHandwriting"] = true;
				}
				else if ( sUserAgent.Contains("Touch") )
				{
					Session["SupportsTouch"      ] = true;  // 11/14/2012 Paul.  Microsoft Surface has Touch in the agent string. 
				}
				// 11/17/2007 Paul.  If running on a mobile device, then use the mobile theme. 
				// 04/21/2021 Paul.  The mobile theme is now deprecated as most cell phones have large screens. 
				/* if ( Utils.IsMobileDevice )
				{
					if ( Directory.Exists(Context.Server.MapPath("~/App_MasterPages/" + SplendidDefaults.MobileTheme())) )
					{
						sTheme = SplendidDefaults.MobileTheme();
					}
				}
				*/
				Session["USER_SETTINGS/THEME"  ] = sTheme;
				Session["USER_SETTINGS/CULTURE"] = SplendidDefaults.Culture();
				// 03/07/2007 Paul.  Version 1.4 moved its themes folder to the .NET 2.0 default App_Themes. 
				Session["themeURL"             ] = Sql.ToString(Context.Application["rootURL"]) + "App_Themes/" + sTheme + "/";
				// 11/19/2005 Paul.  AUTH_USER is the clear indication that NTLM is enabled. 
				if ( Security.IsWindowsAuthentication() )
				{
					string[] arrUserName = Context.User.Identity.Name.Split('\\');
					// 11/09/2007 Paul.  The domain will not be provided when debugging anonymous. 
					string sUSER_DOMAIN = String.Empty;
					string sUSER_NAME   = String.Empty;
					string sMACHINE     = String.Empty;
					try
					{
						// 09/17/2009 Paul.  Azure does not support MachineName.  Just ignore the error. 
						sMACHINE = System.Environment.MachineName;
					}
					catch
					{
					}
					if ( arrUserName.Length > 1 )
					{
						sUSER_DOMAIN = arrUserName[0];
						sUSER_NAME   = arrUserName[1];
					}
					else
					{
						// 12/15/2007 Paul.  Use environment variable as it is always available, where as the server object is not. 
						sUSER_DOMAIN = sMACHINE;
						sUSER_NAME   = arrUserName[0];
					}
					// 08/26/2015 Paul.  A customer was having trouble with trust relationships.  The IS_ADMIN test is not critical, so we can ignore the error and continue. 
					// 10/30/2021 Paul.  IsInRole is not longer returning reliable information.  False when user clearly part of BUILTIN\\Administrators and Domain Admins.  Not critical, so ignore issue. 
					bool bIS_ADMIN = false;
					try
					{
						// 09/17/2009 Paul.  The machine or domain name may be empty, so protect against their use. 
						bIS_ADMIN = Context.User.IsInRole("BUILTIN\\Administrators") 
						              || (!Sql.IsEmptyString(sUSER_DOMAIN) && Context.User.IsInRole(sUSER_DOMAIN + "\\SplendidCRM Administrators"))
						              || (!Sql.IsEmptyString(sMACHINE    ) && Context.User.IsInRole(sMACHINE     + "\\SplendidCRM Administrators"))
						              || (!Sql.IsEmptyString(sUSER_DOMAIN) && Context.User.IsInRole(sUSER_DOMAIN + "\\Domain Admins"));
					}
					catch(Exception ex)
					{
						SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), ex);
					}
					LoginUser(sUSER_NAME, String.Empty, String.Empty, String.Empty, sUSER_DOMAIN, bIS_ADMIN);
					// 09/22/2010 Paul.  Check for redirect to allow for GenerateDemo.aspx
					string sRedirect = Sql.ToString(Context.Request["Redirect"]);
					// 09/22/2010 Paul.  Only allow virtual relative paths. 
					if ( sRedirect.StartsWith("~/") )
						Context.Response.Redirect(sRedirect);
					// 10/30/2021 Paul.  Allow the React UI to manage Admin Wizard or User Wizard.  No redirect is nessary. 
					else if ( Context.Request.AppRelativeCurrentExecutionFilePath.ToLower() == "~/react/default.aspx" )
					{
					}
					// 07/07/2010 Paul.  Redirect to the AdminWizard. 
					// 07/08/2010 Paul.  Don't run the AdminWizard on the Offline Client. 
					// 02/14/2011 Paul.  Don't run the wizard when being called from a web service. 
					else if ( bIS_ADMIN && Sql.IsEmptyString(Context.Application["CONFIG.Configurator.LastRun"]) && !Utils.IsOfflineClient && !Context.Request.Path.EndsWith(".asmx") )
						Context.Response.Redirect("~/Administration/Configurator/");
					// 10/06/2007 Paul.  Prompt the user for the timezone. 
					// 07/08/2010 Paul.  Redirect to the new User Wizard. 
					// 07/09/2010 Paul.  The user cannot be modified on the Offline Client. 
					// 02/14/2011 Paul.  Don't run the wizard when being called from a web service. 
// 11/04/201 Paul.  Always redirect to React home. 
#if !ReactOnlyUI
					else if ( Sql.IsEmptyString(Session["USER_SETTINGS/TIMEZONE/ORIGINAL"]) && !Utils.IsOfflineClient && !Context.Request.Path.EndsWith(".asmx") )
						Context.Response.Redirect("~/Users/Wizard.aspx");  //Context.Response.Redirect("~/Users/SetTimezone.aspx");
#endif
				}
				else
				{
					// 11/22/2005 Paul.  Assume portal user for the unauthenticated screen as that is the least restrictive. 
					Security.PORTAL_ONLY = true;
					LoadUserPreferences(Guid.Empty, String.Empty, String.Empty);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), ex);
				// 07/11/2011 Paul.  Do not write the error as it is causing problems with the language pack exports. 
				//Context.Response.Write(ex.Message);
			}
		}

		public static void Application_OnError(HttpContext Context)
		{
			try
			{
				HttpApplicationState Application = Context.Application;
				HttpServerUtility Server = Context.Server;
				Exception ex = Server.GetLastError();
				if ( ex != null )
				{
					while ( ex.InnerException != null )
						ex = ex.InnerException;
					string sException = ex.GetType().Name;
					StringBuilder sbMessage = new StringBuilder();
					sbMessage.Append(ex.Message);
					// 03/10/2006 Paul.  .NET 2.0 returns lowercase type names. Use typeof instead. 
					if ( ex.GetType() == typeof(FileNotFoundException) )
					{
						// We can get this error for forbidden files such as web.config and global.asa. 
						//return ; // Return would work if 404 entry was made in web.config. 
						//Response.Redirect("~/Home/FileNotFound.aspx?aspxerrorpath=" + Server.UrlEncode(Request.Path));
						sbMessage = new StringBuilder("File Not Found");
					}
					// 03/10/2006 Paul.  .NET 2.0 returns lowercase type names. Use typeof instead. 
					else if ( ex.GetType() == typeof(HttpException) )
					{
						HttpException exHttp = (HttpException) ex;
						int nHttpCode = exHttp.GetHttpCode();
						if ( nHttpCode == 403 )
						{
							//return ; // Return would work if 403 entry was made in web.config. 
							//Response.Redirect("~/Home/AccessDenied.aspx?aspxerrorpath=" + Server.UrlEncode(Request.Path));
							sbMessage = new StringBuilder("Access Denied");
						}
						else if ( nHttpCode == 404 )
						{
							//return ; // Return would work if 404 entry was made in web.config. 
							//Response.Redirect("~/Home/FileNotFound.aspx?aspxerrorpath=" + Server.UrlEncode(Request.Path));
							sbMessage = new StringBuilder("File Not Found");
						}
					}
					// 03/10/2006 Paul.  .NET 2.0 returns lowercase type names. Use typeof instead. 
					else if ( ex.GetType() == typeof(HttpCompileException) )
					{
						HttpCompileException exCompile = (HttpCompileException) ex;
						CompilerErrorCollection col = exCompile.Results.Errors;
						foreach(CompilerError err in col)
						{
							sbMessage.Append("  ");
							sbMessage.Append(err.ErrorText);
						}
					}
					SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), sbMessage.ToString());
					Server.ClearError();
					string sQueryString = String.Format("aspxerrorpath={0}&Exception={1}&Message={2}", Server.UrlEncode(Context.Request.Path), sException, Server.UrlEncode(sbMessage.ToString()));
					Context.Response.Redirect("~/Home/ServerError.aspx?" + sQueryString);
				}
			}
			catch
			{
			}
		}
	}
}

