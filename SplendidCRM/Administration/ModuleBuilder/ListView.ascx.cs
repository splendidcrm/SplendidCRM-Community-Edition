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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Collections.Generic;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Xml;

namespace SplendidCRM.Administration.ModuleBuilder
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected Label           lblError                 ;
		protected Label           lblProgress              ;
		protected HtmlInputHidden txtACTIVE_TAB            ;

		protected DataTable       dtFields                 ;
		protected CheckBoxList    chkRelationships         ;
		protected GridView        grdMain                  ;

		protected TextBox         DISPLAY_NAME             ;
		protected TextBox         MODULE_NAME              ;
		protected TextBox         TABLE_NAME               ;
		protected CheckBox        TAB_ENABLED              ;
		protected CheckBox        MOBILE_ENABLED           ;
		protected CheckBox        CUSTOM_ENABLED           ;
		protected CheckBox        REPORT_ENABLED           ;
		protected CheckBox        IMPORT_ENABLED           ;
		// 09/12/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
		protected CheckBox        REST_ENABLED             ;
		protected CheckBox        IS_ADMIN                 ;
		protected CheckBox        INCLUDE_ASSIGNED_USER_ID ;
		protected CheckBox        INCLUDE_TEAM_ID          ;
		protected CheckBox        OVERWRITE_EXISTING       ;
		protected CheckBox        CREATE_CODE_BEHIND       ;
		protected RequiredFieldValidator reqDISPLAY_NAME   ;
		protected RequiredFieldValidator reqMODULE_NAME    ;
		protected RequiredFieldValidator reqTABLE_NAME     ;

		protected void DISPLAY_NAME_Changed(object sender, System.EventArgs e)
		{
			if ( DISPLAY_NAME.Text.Length > 0 )
			{
				MODULE_NAME.Text = DISPLAY_NAME.Text.Replace(" ", "" );
				TABLE_NAME .Text = DISPLAY_NAME.Text.Replace(" ", "_").Replace("-", "_").ToUpper();
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL ;
					sSQL = "select *                         " + ControlChars.CrLf
					     + "  from vwMODULES                 " + ControlChars.CrLf
					     + " where MODULE_NAME = @MODULE_NAME" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@MODULE_NAME", MODULE_NAME.Text);
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								MOBILE_ENABLED          .Checked = Sql.ToBoolean(rdr["MODULE_ENABLED"]);
								TAB_ENABLED             .Checked = Sql.ToBoolean(rdr["TAB_ENABLED"   ]);
								CUSTOM_ENABLED          .Checked = Sql.ToBoolean(rdr["CUSTOM_ENABLED"]);
								TABLE_NAME              .Text    = Sql.ToString (rdr["TABLE_NAME"    ]);
								REPORT_ENABLED          .Checked = Sql.ToBoolean(rdr["REPORT_ENABLED"]);
								IMPORT_ENABLED          .Checked = Sql.ToBoolean(rdr["IMPORT_ENABLED"]);
								// 09/12/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
								REST_ENABLED            .Checked = Sql.ToBoolean(rdr["REST_ENABLED"  ]);
								IS_ADMIN                .Checked = Sql.ToBoolean(rdr["IS_ADMIN"      ]);
								INCLUDE_ASSIGNED_USER_ID.Checked = Sql.ToBoolean(Application["Modules." + MODULE_NAME.Text + ".Teamed"  ]);
								INCLUDE_TEAM_ID         .Checked = Sql.ToBoolean(Application["Modules." + MODULE_NAME.Text + ".Assigned"]);
								rdr.Close();
								
								cmd.Parameters.Clear();
								sSQL = "select ColumnName as FIELD_NAME        " + ControlChars.CrLf
								     + "     , dbo.fnL10nTerm('en-US', @MODULE_NAME, 'LBL_'      + ColumnName) as EDIT_LABEL" + ControlChars.CrLf
								     + "     , dbo.fnL10nTerm('en-US', @MODULE_NAME, 'LBL_LIST_' + ColumnName) as LIST_LABEL" + ControlChars.CrLf
								     + "     , (case when dbo.fnSqlColumns_IsEnum(@VIEW_NAME, ColumnName, CsType) = 1 then 'Dropdown' " + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.NVarChar'                            then 'Text'     " + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.VarChar'                             then 'Text'     " + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.Text'                                then 'Text Area'" + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.NText'                               then 'Text Area'" + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.TinyInt'                             then 'Integer'  " + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.Int'                                 then 'Integer'  " + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.BigInt'                              then 'Integer'  " + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.Real'                                then 'Decimal'  " + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.Money'                               then 'Money'    " + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.Bit'                                 then 'Checkbox' " + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.DateTime'                            then 'Date'     " + ControlChars.CrLf
								     + "             when SqlDbType = 'SqlDbType.UniqueIdentifier'                    then 'Guid'     " + ControlChars.CrLf
								     + "             else CsType               " + ControlChars.CrLf
								     + "        end)      as DATA_TYPE         " + ControlChars.CrLf
								     + "     , length     as MAX_SIZE          " + ControlChars.CrLf
								     + "     , (case IsNullable when 1 then 0 else 1 end) as REQUIRED" + ControlChars.CrLf
								     + "  from vwSqlColumns                    " + ControlChars.CrLf
								     + " where ObjectName = @TABLE_NAME        " + ControlChars.CrLf
								     + " order by colid                        " + ControlChars.CrLf;
								
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@MODULE_NAME", MODULE_NAME.Text);
								// 02/20/2016 Paul.  Make sure to use upper case for Oracle. 
								Sql.AddParameter(cmd, "@VIEW_NAME"  , Sql.MetadataName(cmd, "vw" + MODULE_NAME.Text.ToUpper()));
								Sql.AddParameter(cmd, "@TABLE_NAME" , TABLE_NAME .Text);
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									dtFields = new DataTable();
									da.Fill(dtFields);
									
									// 03/27/2007 Paul.  Always add blank line to allow quick editing. 
									DataRow rowNew = dtFields.NewRow();
									dtFields.Rows.Add(rowNew);
									
									ViewState["Fields"] = dtFields;
									grdMain.DataSource = dtFields;
									// 02/03/2007 Paul.  Start with last line enabled for editing. 
									grdMain.EditIndex = dtFields.Rows.Count - 1;
									grdMain.DataBind();
								}
							}
						}
					}
					// 03/07/2010 Paul.  Update the relationship checkboxes. 
					foreach ( ListItem itm in chkRelationships.Items )
					{
						itm.Selected = false;
					}
					sSQL = "select MODULE_NAME                " + ControlChars.CrLf
					     + "  from vwDETAILVIEWS_RELATIONSHIPS" + ControlChars.CrLf
					     + " where DETAIL_NAME = @DETAIL_NAME " + ControlChars.CrLf
					     + " order by MODULE_NAME             " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@DETAIL_NAME", MODULE_NAME.Text + ".DetailView");
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								string sMODULE_NAME = Sql.ToString(rdr["MODULE_NAME"]);
								ListItem itm = chkRelationships.Items.FindByValue(sMODULE_NAME);
								if ( itm != null )
								{
									itm.Selected = true;
								}
							}
						}
					}
				}
			}
		}

		public static string CamelCase(string sName)
		{
			string[] arrName = sName.Split('_');
			for ( int i = 0; i < arrName.Length; i++ )
			{
				if( String.Compare(arrName[i], "ID", true) == 0 )
					arrName[i] = arrName[i].ToUpper();
				else
					arrName[i] = arrName[i].Substring(0, 1).ToUpper() + arrName[i].Substring(1).ToLower();
			}
			sName = String.Join(" ", arrName);
			return sName;
		}

		private static string RemoveComments(string sScript)
		{
			StringReader rdr = new StringReader(sScript);
			StringBuilder sb = new StringBuilder();
			StringWriter wtr = new StringWriter(sb);
			string sLine = null;
			while ( (sLine = rdr.ReadLine()) != null )
			{
				// 09/13/2008 Paul.  DB2 does not like any comments. 
				if ( !sLine.StartsWith("--") && !sLine.StartsWith("\t--") && !sLine.Contains("\t\t--") )
					wtr.WriteLine(sLine);
			}
			return sb.ToString();
		}

		public static void GenerateModule(HttpContext Context, string sDISPLAY_NAME, string sMODULE_NAME, string sTABLE_NAME, bool bTAB_ENABLED, bool bMOBILE_ENABLED, bool bCUSTOM_ENABLED, bool bREPORT_ENABLED, bool bIMPORT_ENABLED, bool bREST_ENABLED, bool bIS_ADMIN, bool bINCLUDE_ASSIGNED_USER_ID, bool bINCLUDE_TEAM_ID, bool bOVERWRITE_EXISTING, bool bCREATE_CODE_BEHIND, bool bREACT_ONLY, DataTable dtFields, List<string> lstRelationships, StringBuilder sbProgress)
		{
			HttpApplicationState Application = Context.Application;
			HttpServerUtility    Server      = Context.Server     ;
			HttpSessionState     Session     = Context.Session    ;
					string sDISPLAY_NAME_SINGULAR    = sDISPLAY_NAME            ;
					string sMODULE_NAME_SINGULAR     = sMODULE_NAME             ;
					string sTABLE_NAME_SINGULAR      = sTABLE_NAME              ;

					if ( sDISPLAY_NAME_SINGULAR.ToLower().EndsWith("ies") )
						sDISPLAY_NAME_SINGULAR = sDISPLAY_NAME_SINGULAR.Substring(0, sDISPLAY_NAME_SINGULAR.Length-3) + "y";
					else if ( sDISPLAY_NAME_SINGULAR.ToLower().EndsWith("s") )
						sDISPLAY_NAME_SINGULAR = sDISPLAY_NAME_SINGULAR.Substring(0, sDISPLAY_NAME_SINGULAR.Length-1);
					if ( sMODULE_NAME_SINGULAR.ToLower().EndsWith("ies") )
						sMODULE_NAME_SINGULAR = sMODULE_NAME_SINGULAR.Substring(0, sMODULE_NAME_SINGULAR.Length-3) + "y";
					else if ( sMODULE_NAME_SINGULAR.ToLower().EndsWith("s") )
						sMODULE_NAME_SINGULAR = sMODULE_NAME_SINGULAR.Substring(0, sMODULE_NAME_SINGULAR.Length-1);
					if ( sTABLE_NAME_SINGULAR.ToLower().EndsWith("ies") )
						sTABLE_NAME_SINGULAR = sTABLE_NAME_SINGULAR.Substring(0, sTABLE_NAME_SINGULAR.Length-3) + "Y";
					else if ( sTABLE_NAME_SINGULAR.ToLower().EndsWith("s") )
						sTABLE_NAME_SINGULAR = sTABLE_NAME_SINGULAR.Substring(0, sTABLE_NAME_SINGULAR.Length-1);

					// 03/08/2010 Paul.  Allow user to select Live deployment, but we still prefer the code-behind method. 
					string sWebTemplatesPath = Server.MapPath("~/Administration/ModuleBuilder/WebTemplates");
					if ( !bCREATE_CODE_BEHIND )
						sWebTemplatesPath = Server.MapPath("~/Administration/ModuleBuilder/WebTemplatesLive");
					string sSqlTemplatesPath = Server.MapPath("~/Administration/ModuleBuilder/SqlTemplates");
					// 09/12/2009 Paul.  If this is an admin module, then place in the Administration namespace. 
					string sWebModulePath    = Server.MapPath((bIS_ADMIN ? "~/Administration/" : "~/") + sMODULE_NAME);
					// 06/04/2017 Paul.  Change to SQL Scripts Custom and Build Custom.bat. 
					string sSqlScriptsPath   = Path.Combine(Server.MapPath("~/"), "..\\SQL Scripts Custom");

					try
					{
						if ( !Directory.Exists(sWebModulePath) )
						{
							Directory.CreateDirectory(sWebModulePath);
						}
					}
					catch(Exception ex)
					{
						sbProgress.AppendLine("<font class=error>Failed to create " + sWebModulePath + ":" + ex.Message + "</font><br>");
					}
					try
					{
						if ( !Directory.Exists(sSqlScriptsPath) )
						{
							Directory.CreateDirectory(sSqlScriptsPath);
						}
						// 03/07/2011 Paul.  If the Tables folder does not exist, then rebuild the batch file. 
						if ( File.Exists(Path.Combine(sSqlScriptsPath, "Build Custom.bat")) && !Directory.Exists(Path.Combine(sSqlScriptsPath, "Tables")) )
						{
							File.Delete(Path.Combine(sSqlScriptsPath, "Build Custom.bat"));
						}
						// 09/23/2009 Paul.  If we are creating the SQL Scripts folder, then also add the comment files and the build file. 
						if ( !File.Exists(Path.Combine(sSqlScriptsPath, "Build Custom.bat")) )
						{
							try
							{
								// 06/04/2017 Paul.  Must create folders first. 
								if ( !Directory.Exists(Path.Combine(sSqlScriptsPath, "BaseTables" )) ) Directory.CreateDirectory(Path.Combine(sSqlScriptsPath, "BaseTables" ));
								if ( !Directory.Exists(Path.Combine(sSqlScriptsPath, "Tables"     )) ) Directory.CreateDirectory(Path.Combine(sSqlScriptsPath, "Tables"     ));
								if ( !Directory.Exists(Path.Combine(sSqlScriptsPath, "Data"       )) ) Directory.CreateDirectory(Path.Combine(sSqlScriptsPath, "Data"       ));
								if ( !Directory.Exists(Path.Combine(sSqlScriptsPath, "Procedures" )) ) Directory.CreateDirectory(Path.Combine(sSqlScriptsPath, "Procedures" ));
								if ( !Directory.Exists(Path.Combine(sSqlScriptsPath, "Triggers"   )) ) Directory.CreateDirectory(Path.Combine(sSqlScriptsPath, "Triggers"   ));
								if ( !Directory.Exists(Path.Combine(sSqlScriptsPath, "Terminology")) ) Directory.CreateDirectory(Path.Combine(sSqlScriptsPath, "Terminology"));
								if ( !Directory.Exists(Path.Combine(sSqlScriptsPath, "Views"      )) ) Directory.CreateDirectory(Path.Combine(sSqlScriptsPath, "Views"      ));
								
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "BaseTables\\_Comment.0.sql" ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "BaseTables\\_Comment.1.sql" ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "BaseTables\\_Comment.2.sql" ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Tables\\_Comment.0.sql"     ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Tables\\_Comment.1.sql"     ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Tables\\_Comment.2.sql"     ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Data\\_Comment.0.sql"       ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Data\\_Comment.1.sql"       ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Data\\_Comment.2.sql"       ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Procedures\\_Comment.0.sql" ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Procedures\\_Comment.1.sql" ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Procedures\\_Comment.2.sql" ), "\r\n");
								// 09/26/2011 Paul.  Update triggers for auditing. 
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Triggers\\_Comment.0.sql"   ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Triggers\\_Comment.1.sql"   ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Triggers\\_Comment.2.sql"   ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Terminology\\_Comment.0.sql"), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Terminology\\_Comment.1.sql"), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Terminology\\_Comment.2.sql"), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Views\\_Comment.0.sql"      ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Views\\_Comment.1.sql"      ), "\r\n");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Views\\_Comment.2.sql"      ), "\r\n");
								
								StringBuilder sbBuild = new StringBuilder();
								sbBuild.AppendLine("del BaseTables.sql");
								sbBuild.AppendLine("del Tables.sql");
								sbBuild.AppendLine("del Views.sql");
								sbBuild.AppendLine("del Procedures.sql");
								sbBuild.AppendLine("del Triggers.sql");
								sbBuild.AppendLine("del Data.sql");
								sbBuild.AppendLine("del Terminology.sql");
								sbBuild.AppendLine("");
								sbBuild.AppendLine("copy BaseTables\\*.0.sql         + BaseTables\\*.1.sql         + BaseTables\\*.2.sql       BaseTables.sql");
								sbBuild.AppendLine("copy Tables\\*.0.sql             + Tables\\*.1.sql             + Tables\\*.2.sql           Tables.sql");
								sbBuild.AppendLine("copy Views\\*.0.sql              + Views\\*.1.sql              + Views\\*.2.sql            Views.sql");
								sbBuild.AppendLine("copy Procedures\\*.0.sql         + Procedures\\*.1.sql         + Procedures\\*.2.sql       Procedures.sql");
								// 09/26/2011 Paul.  Update triggers for auditing. 
								sbBuild.AppendLine("copy Triggers\\*.0.sql           + Triggers\\*.1.sql           + Triggers\\*.2.sql         Triggers.sql");
								sbBuild.AppendLine("copy Data\\*.0.sql               + Data\\*.1.sql               + Data\\*.2.sql             Data.sql");
								sbBuild.AppendLine("copy Terminology\\*.0.sql        + Terminology\\*.1.sql        + Terminology\\*.2.sql      Terminology.sql");
								sbBuild.AppendLine("");
								sbBuild.AppendLine("Copy BaseTables.sql + Tables.sql + Views.sql + Procedures.sql + Triggers.sql + Data.sql + Terminology.sql \"Build Custom.sql\"");
								sbBuild.AppendLine("");
								File.WriteAllText(Path.Combine(sSqlScriptsPath, "Build Custom.bat"), sbBuild.ToString());
							}
							catch
							{
							}
						}
					}
					catch(Exception ex)
					{
						sbProgress.AppendLine("<font class=error>Failed to create " + sSqlScriptsPath + ":" + ex.Message + "</font><br>");
					}

					StringBuilder sbCreateTableFields            = new StringBuilder();
					StringBuilder sbCreateTableIndexes           = new StringBuilder();
					StringBuilder sbCreateViewFields             = new StringBuilder();
					StringBuilder sbCreateViewJoins              = new StringBuilder();
					StringBuilder sbCreateProcedureParameters    = new StringBuilder();
					StringBuilder sbCreateProcedureInsertInto    = new StringBuilder();
					StringBuilder sbCreateProcedureInsertValues  = new StringBuilder();
					StringBuilder sbCreateProcedureUpdate        = new StringBuilder();
					StringBuilder sbCreateProcedureNormalizeTeams= new StringBuilder();
					StringBuilder sbCreateProcedureUpdateTeams   = new StringBuilder();
					// 03/07/2011 Paul.  We need the ability to alter a table to add new fields, just in case Assigned User and Team Management are enabled during re-generation. 
					StringBuilder sbAlterTableFields             = new StringBuilder();
					StringBuilder sbCallUpdateProcedure          = new StringBuilder();
					StringBuilder sbMassUpdateProcedureFields    = new StringBuilder();
					StringBuilder sbMassUpdateProcedureSets      = new StringBuilder();
					StringBuilder sbMassUpdateTeamNormalize      = new StringBuilder();
					StringBuilder sbMassUpdateTeamAdd            = new StringBuilder();
					StringBuilder sbMassUpdateTeamUpdate         = new StringBuilder();
					StringBuilder sbMergeProcedureUpdates        = new StringBuilder();
					StringBuilder sbModuleGridViewData           = new StringBuilder();
					StringBuilder sbModuleGridViewPopup          = new StringBuilder();
					StringBuilder sbModuleDetailViewData         = new StringBuilder();
					StringBuilder sbModuleEditViewData           = new StringBuilder();
					StringBuilder sbModuleEditViewSearchBasic    = new StringBuilder();
					StringBuilder sbModuleEditViewSearchAdvanced = new StringBuilder();
					StringBuilder sbModuleEditViewSearchPopup    = new StringBuilder();
					StringBuilder sbModuleTerminology            = new StringBuilder();
					// 08/08/2013 Paul.  Add delete and undelete of relationships. 
					StringBuilder sbDeleteProcedureUpdates       = new StringBuilder();
					StringBuilder sbUndeleteProcedureUpdates     = new StringBuilder();
					// 03/07/2010 Paul.  GridViewIndex will start at 1 to make room for the checkbox. 
					// 03/05/2011 Paul.  Start at 2 to make room for edit button. 
					int nGridViewIndex               = 2;
					int nGridViewPopupIndex          = 1;
					int nGridViewMAX                 = 3;
					int nDetailViewIndex             = 0;
					int nEditViewIndex               = 0;
					int nEditViewSearchBasicIndex    = 0;
					int nEditViewSearchAdvancedIndex = 0;
					int nEditViewSearchPopupIndex    = 0;
					int nEditViewSearchBasicMAX      = 1;

					// 03/06/2010 Paul.  Now that we have included NewRecord logic, we cannot assume that ASSIGNED_USER_ID exists on the form. 
					if ( bINCLUDE_ASSIGNED_USER_ID )
					{
						// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
						sbCallUpdateProcedure.AppendLine("									Guid gASSIGNED_USER_ID = new SplendidCRM.DynamicControl(this, rowCurrent, \"ASSIGNED_USER_ID\").ID;");
						sbCallUpdateProcedure.AppendLine("									if ( Sql.IsEmptyGuid(gASSIGNED_USER_ID) )");
						sbCallUpdateProcedure.AppendLine("										gASSIGNED_USER_ID = Security.USER_ID;");
					}
					// 03/06/2010 Paul.  Now that we have included NewRecord logic, we cannot assume that TEAM_ID exists on the form. 
					if ( bINCLUDE_TEAM_ID )
					{
						// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
						sbCallUpdateProcedure.AppendLine("									Guid gTEAM_ID          = new SplendidCRM.DynamicControl(this, rowCurrent, \"TEAM_ID\"         ).ID;");
						sbCallUpdateProcedure.AppendLine("									if ( Sql.IsEmptyGuid(gTEAM_ID) )");
						sbCallUpdateProcedure.AppendLine("										gTEAM_ID = Security.TEAM_ID;");
					}
					sbCallUpdateProcedure.AppendLine("									SqlProcs.sp" + sTABLE_NAME +"_Update");
					sbCallUpdateProcedure.AppendLine("										( ref gID");
					if ( bINCLUDE_ASSIGNED_USER_ID )
					{
						sbCreateTableFields          .AppendLine("		, ASSIGNED_USER_ID                   uniqueidentifier null");
						sbCreateTableIndexes         .AppendLine("	create index IDX_" + sTABLE_NAME + "_ASSIGNED_USER_ID on dbo." + sTABLE_NAME + " (ASSIGNED_USER_ID, DELETED, ID)");
						
						// 03/07/2011 Paul.  We need the ability to alter a table to add new fields, just in case Assigned User and Team Management are enabled during re-generation. 
						sbAlterTableFields           .AppendLine("if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = '" + sTABLE_NAME + "' and COLUMN_NAME = 'ASSIGNED_USER_ID') begin -- then");
						sbAlterTableFields           .AppendLine("	print 'alter table " + sTABLE_NAME + " add ASSIGNED_USER_ID uniqueidentifier null';");
						sbAlterTableFields           .AppendLine("	alter table " + sTABLE_NAME + " add ASSIGNED_USER_ID uniqueidentifier null;");
						sbAlterTableFields           .AppendLine("	create index IDX_" + sTABLE_NAME + "_ASSIGNED_USER_ID on dbo." + sTABLE_NAME + " (ASSIGNED_USER_ID, DELETED, ID)");
						sbAlterTableFields           .AppendLine("end -- if;");
						sbAlterTableFields           .AppendLine("");
						
						sbCreateProcedureParameters  .AppendLine("	, @ASSIGNED_USER_ID                   uniqueidentifier");
						sbCreateProcedureInsertInto  .AppendLine("			, ASSIGNED_USER_ID                   ");
						sbCreateProcedureInsertValues.AppendLine("			, @ASSIGNED_USER_ID                   ");
						sbCreateProcedureUpdate      .AppendLine("		     , ASSIGNED_USER_ID                     = @ASSIGNED_USER_ID                   ");
						
						sbMassUpdateProcedureFields  .AppendLine("	, @ASSIGNED_USER_ID  uniqueidentifier");
						sbMassUpdateProcedureSets    .AppendLine("			     , ASSIGNED_USER_ID  = isnull(@ASSIGNED_USER_ID, ASSIGNED_USER_ID)");
						
						sbCallUpdateProcedure.AppendLine("										, gASSIGNED_USER_ID");
					}
					if ( bINCLUDE_TEAM_ID )
					{
						sbCreateTableFields            .AppendLine("		, TEAM_ID                            uniqueidentifier null");
						// 09/23/2009 Paul.  TEAM_SET_ID was missing. 
						sbCreateTableFields            .AppendLine("		, TEAM_SET_ID                        uniqueidentifier null");
						// 03/07/2011 Paul.  Just in case ASSIGNED_USER_ID is not set with TEAM_ID. 
						if ( bINCLUDE_ASSIGNED_USER_ID )
						{
							sbCreateTableIndexes           .AppendLine("	create index IDX_" + sTABLE_NAME + "_TEAM_ID          on dbo." + sTABLE_NAME + " (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)");
							sbCreateTableIndexes           .AppendLine("	create index IDX_" + sTABLE_NAME + "_TEAM_SET_ID      on dbo." + sTABLE_NAME + " (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)");
						}
						else
						{
							sbCreateTableIndexes           .AppendLine("	create index IDX_" + sTABLE_NAME + "_TEAM_ID          on dbo." + sTABLE_NAME + " (TEAM_ID, DELETED, ID)");
							sbCreateTableIndexes           .AppendLine("	create index IDX_" + sTABLE_NAME + "_TEAM_SET_ID      on dbo." + sTABLE_NAME + " (TEAM_SET_ID, DELETED, ID)");
						}
						
						// 03/07/2011 Paul.  We need the ability to alter a table to add new fields, just in case Assigned User and Team Management are enabled during re-generation. 
						sbAlterTableFields             .AppendLine("if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = '" + sTABLE_NAME + "' and COLUMN_NAME = 'TEAM_ID') begin -- then");
						sbAlterTableFields             .AppendLine("	print 'alter table " + sTABLE_NAME + " add TEAM_ID uniqueidentifier null';");
						sbAlterTableFields             .AppendLine("	alter table " + sTABLE_NAME + " add TEAM_ID uniqueidentifier null;");
						if ( bINCLUDE_ASSIGNED_USER_ID )
							sbAlterTableFields             .AppendLine("	create index IDX_" + sTABLE_NAME + "_TEAM_ID          on dbo." + sTABLE_NAME + " (TEAM_ID, ASSIGNED_USER_ID, DELETED, ID)");
						else
							sbAlterTableFields             .AppendLine("	create index IDX_" + sTABLE_NAME + "_TEAM_ID          on dbo." + sTABLE_NAME + " (TEAM_ID, DELETED, ID)");
						sbAlterTableFields             .AppendLine("end -- if;");
						sbAlterTableFields             .AppendLine("");
						sbAlterTableFields             .AppendLine("if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = '" + sTABLE_NAME + "' and COLUMN_NAME = 'TEAM_SET_ID') begin -- then");
						sbAlterTableFields             .AppendLine("	print 'alter table " + sTABLE_NAME + " add TEAM_SET_ID uniqueidentifier null';");
						sbAlterTableFields             .AppendLine("	alter table " + sTABLE_NAME + " add TEAM_SET_ID uniqueidentifier null;");
						if ( bINCLUDE_ASSIGNED_USER_ID )
							sbAlterTableFields             .AppendLine("	create index IDX_" + sTABLE_NAME + "_TEAM_SET_ID      on dbo." + sTABLE_NAME + " (TEAM_SET_ID, ASSIGNED_USER_ID, DELETED, ID)");
						else
							sbAlterTableFields             .AppendLine("	create index IDX_" + sTABLE_NAME + "_TEAM_SET_ID      on dbo." + sTABLE_NAME + " (TEAM_SET_ID, DELETED, ID)");
						sbAlterTableFields             .AppendLine("end -- if;");
						sbAlterTableFields             .AppendLine("");
						
						sbCreateProcedureParameters    .AppendLine("	, @TEAM_ID                            uniqueidentifier");
						sbCreateProcedureParameters    .AppendLine("	, @TEAM_SET_LIST                      varchar(8000)");
						sbCreateProcedureInsertInto    .AppendLine("			, TEAM_ID                            ");
						sbCreateProcedureInsertInto    .AppendLine("			, TEAM_SET_ID                        ");
						sbCreateProcedureInsertValues  .AppendLine("			, @TEAM_ID                            ");
						sbCreateProcedureInsertValues  .AppendLine("			, @TEAM_SET_ID                        ");
						sbCreateProcedureUpdate        .AppendLine("		     , TEAM_ID                              = @TEAM_ID                            ");
						sbCreateProcedureUpdate        .AppendLine("		     , TEAM_SET_ID                          = @TEAM_SET_ID                        ");
						
						sbCreateProcedureNormalizeTeams.AppendLine("	declare @TEAM_SET_ID         uniqueidentifier;");
						sbCreateProcedureNormalizeTeams.AppendLine("	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;");
						
						sbMassUpdateProcedureFields    .AppendLine("	, @TEAM_ID           uniqueidentifier");
						sbMassUpdateProcedureFields    .AppendLine("	, @TEAM_SET_LIST     varchar(8000)");
						sbMassUpdateProcedureFields    .AppendLine("	, @TEAM_SET_ADD      bit");
						sbMassUpdateProcedureSets      .AppendLine("			     , TEAM_ID           = isnull(@TEAM_ID         , TEAM_ID         )");
						sbMassUpdateProcedureSets      .AppendLine("			     , TEAM_SET_ID       = isnull(@TEAM_SET_ID     , TEAM_SET_ID     )");
						
						// 09/16/2009 Paul.  Needed to define @OLD_SET_ID. 
						sbMassUpdateTeamNormalize      .AppendLine("	declare @TEAM_SET_ID  uniqueidentifier;");
						sbMassUpdateTeamNormalize      .AppendLine("	declare @OLD_SET_ID   uniqueidentifier;");
						sbMassUpdateTeamNormalize      .AppendLine("");
						sbMassUpdateTeamNormalize      .AppendLine("	exec dbo.spTEAM_SETS_NormalizeSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @TEAM_ID, @TEAM_SET_LIST;");
						
						sbMassUpdateTeamAdd            .AppendLine("		if @TEAM_SET_ADD = 1 and @TEAM_SET_ID is not null begin -- then");
						sbMassUpdateTeamAdd            .AppendLine("				select @OLD_SET_ID = TEAM_SET_ID");
						sbMassUpdateTeamAdd            .AppendLine("				     , @TEAM_ID    = isnull(@TEAM_ID, TEAM_ID)");
						sbMassUpdateTeamAdd            .AppendLine("				  from " + sTABLE_NAME);
						sbMassUpdateTeamAdd            .AppendLine("				 where ID                = @ID");
						sbMassUpdateTeamAdd            .AppendLine("				   and DELETED           = 0;");
						sbMassUpdateTeamAdd            .AppendLine("			if @OLD_SET_ID is not null begin -- then");
						sbMassUpdateTeamAdd            .AppendLine("				exec dbo.spTEAM_SETS_AddSet @TEAM_SET_ID out, @MODIFIED_USER_ID, @OLD_SET_ID, @TEAM_ID, @TEAM_SET_ID;");
						sbMassUpdateTeamAdd            .AppendLine("			end -- if;");
						sbMassUpdateTeamAdd            .AppendLine("		end -- if;");
						
						// 08/31/2009 Paul.  We are no longer going to use separate team relationship tables. 
						//sbMassUpdateTeamUpdate         .AppendLine("		if @TEAM_SET_ID is not null begin -- then");
						//sbMassUpdateTeamUpdate         .AppendLine("			exec dbo.sp" + sTABLE_NAME + "_TEAMS_Update @ID, @MODIFIED_USER_ID, @TEAM_SET_ID;");
						//sbMassUpdateTeamUpdate         .AppendLine("		end -- if;");
						
						sbCallUpdateProcedure          .AppendLine("										, gTEAM_ID");
						// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
						sbCallUpdateProcedure          .AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"TEAM_SET_LIST\"                      ).Text");
					}
					string sFIRST_TEXT_FIELD = String.Empty;
					foreach ( DataRow row in dtFields.Rows )
					{
						string sFIELD_NAME = Sql.ToString (row["FIELD_NAME"]).ToUpper();
						string sEDIT_LABEL = Sql.ToString (row["EDIT_LABEL"]);
						string sLIST_LABEL = Sql.ToString (row["LIST_LABEL"]);
						string sDATA_TYPE  = Sql.ToString (row["DATA_TYPE" ]);
						int    nMAX_SIZE   = Sql.ToInteger(row["MAX_SIZE"  ]);
						bool   bREQUIRED   = Sql.ToBoolean(row["REQUIRED"  ]);
						// 09/16/2009 Paul.  DATE_MODIFIED_UTC is a new common field used to sync. 
						if (  String.IsNullOrEmpty(sFIELD_NAME)
						   || sFIELD_NAME == "ID"              
						   || sFIELD_NAME == "DELETED"         
						   || sFIELD_NAME == "CREATED_BY"      
						   || sFIELD_NAME == "DATE_ENTERED"    
						   || sFIELD_NAME == "MODIFIED_USER_ID"
						   || sFIELD_NAME == "DATE_MODIFIED"   
						   || sFIELD_NAME == "DATE_MODIFIED_UTC"
						   || (sFIELD_NAME == "ASSIGNED_USER_ID" && bINCLUDE_ASSIGNED_USER_ID)
						   || (sFIELD_NAME == "TEAM_ID"          && bINCLUDE_TEAM_ID         )
						   || (sFIELD_NAME == "TEAM_SET_ID"      && bINCLUDE_TEAM_ID         )
						   )
						{
							continue;
						}
						string sSQL_DATA_TYPE = String.Empty;
						switch ( sDATA_TYPE )
						{
							case "Text"     :  sSQL_DATA_TYPE = "nvarchar(" + nMAX_SIZE.ToString() + ")";  break;
							// 08/17/2017 Paul.  We should be using nvarchar(max) instead of ntext. 
							case "Text Area":  sSQL_DATA_TYPE = "nvarchar(max)"   ;  break;
							case "Integer"  :  sSQL_DATA_TYPE = "int"             ;  break;
							case "bigint"   :  sSQL_DATA_TYPE = "bigint"          ;  break;
							case "Decimal"  :  sSQL_DATA_TYPE = "float"           ;  break;
							case "Money"    :  sSQL_DATA_TYPE = "money"           ;  break;
							case "Checkbox" :  sSQL_DATA_TYPE = "bit"             ;  break;
							case "Date"     :  sSQL_DATA_TYPE = "datetime"        ;  break;
							case "Dropdown" :  sSQL_DATA_TYPE = "nvarchar(50)"    ;  break;
							case "Guid"     :  sSQL_DATA_TYPE = "uniqueidentifier";  break;
						}
						sbCreateTableFields           .AppendLine("		, " + sFIELD_NAME + Strings.Space(35 - sFIELD_NAME.Length) + sSQL_DATA_TYPE + " " + (bREQUIRED ? "not null" : "null") );
						
						// 03/07/2011 Paul.  We need the ability to alter a table to add new fields, just in case Assigned User and Team Management are enabled during re-generation. 
						sbAlterTableFields           .AppendLine("if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = '" + sTABLE_NAME + "' and COLUMN_NAME = '" + sFIELD_NAME + "') begin -- then");
						sbAlterTableFields           .AppendLine("	print 'alter table " + sTABLE_NAME + " add " + sFIELD_NAME + " " + sSQL_DATA_TYPE + " null';");
						sbAlterTableFields           .AppendLine("	alter table " + sTABLE_NAME + " add " + sFIELD_NAME + " " + sSQL_DATA_TYPE + " null;");
						sbAlterTableFields           .AppendLine("end -- if;");
						sbAlterTableFields           .AppendLine("");

						if ( sFIELD_NAME == "NAME" || sFIELD_NAME == "TITLE" )
							sbCreateTableIndexes         .AppendLine("	create index IDX_" + sTABLE_NAME + "_" + sFIELD_NAME + "  on dbo." + sTABLE_NAME + " (" + sFIELD_NAME + ", DELETED, ID)");
						sbCreateViewFields            .AppendLine("     , " + sTABLE_NAME + "." + sFIELD_NAME);
						sbCreateProcedureParameters   .AppendLine("	, @" + sFIELD_NAME + Strings.Space(35 - sFIELD_NAME.Length) + sSQL_DATA_TYPE);
						sbCreateProcedureInsertInto   .AppendLine("			, "  + sFIELD_NAME + Strings.Space(35 - sFIELD_NAME.Length));
						sbCreateProcedureInsertValues .AppendLine("			, @" + sFIELD_NAME + Strings.Space(35 - sFIELD_NAME.Length));
						sbCreateProcedureUpdate       .AppendLine("		     , " + sFIELD_NAME + Strings.Space(35 - sFIELD_NAME.Length) + "  = @" + sFIELD_NAME + Strings.Space(35 - sFIELD_NAME.Length) + "");

						if ( Sql.IsEmptyString(sEDIT_LABEL) )
							sLIST_LABEL = CamelCase(sFIELD_NAME);
						if ( Sql.IsEmptyString(sEDIT_LABEL) )
							sEDIT_LABEL = sLIST_LABEL + ":";
						sbModuleTerminology.AppendLine("exec dbo.spTERMINOLOGY_InsertOnly 'LBL_"      + sFIELD_NAME + "'" + Strings.Space(50 - sFIELD_NAME.Length) + ", 'en-US', '" + sMODULE_NAME + "', null, null, '" + sEDIT_LABEL + "';");
						sbModuleTerminology.AppendLine("exec dbo.spTERMINOLOGY_InsertOnly 'LBL_LIST_" + sFIELD_NAME + "'" + Strings.Space(45 - sFIELD_NAME.Length) + ", 'en-US', '" + sMODULE_NAME + "', null, null, '" + sLIST_LABEL + "';");

						sbModuleDetailViewData.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsBound     '" + sMODULE_NAME + ".DetailView', " + nDetailViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '{0}', null;");
						nDetailViewIndex++;
						switch ( sDATA_TYPE )
						{
							case "Text":
								sbModuleEditViewData          .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound       '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, " + nMAX_SIZE.ToString() + ", 35, null;");
								// 09/04/2009 Paul.  Add Auto-Complete to the NAME search field. 
								if ( sFIELD_NAME == "NAME" )
									sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, " + nMAX_SIZE.ToString() + ", 35, '" + sMODULE_NAME + "', null;");
								else
									sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, " + nMAX_SIZE.ToString() + ", 35, null;");
								nEditViewIndex++;
								nEditViewSearchAdvancedIndex++;
								if ( nEditViewSearchBasicIndex < nEditViewSearchBasicMAX )
								{
									// 09/04/2009 Paul.  Add Auto-Complete to the NAME search field. 
									if ( sFIELD_NAME == "NAME" )
									{
										sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, " + nMAX_SIZE.ToString() + ", 35, '" + sMODULE_NAME + "', null;");
										sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, " + nMAX_SIZE.ToString() + ", 35, '" + sMODULE_NAME + "', null;");
									}
									else
									{
										sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, " + nMAX_SIZE.ToString() + ", 35, null;");
										sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, " + nMAX_SIZE.ToString() + ", 35, null;");
									}
									nEditViewSearchBasicIndex++;
									nEditViewSearchPopupIndex++;
								}
								// 03/07/2010 Paul.  GridViewIndex will start at 1 to make room for the checkbox. 
								// 03/05/2011 Paul.  Start at 2 to make room for edit button. 
								if ( nGridViewIndex == 2 )
								{
									sbModuleGridViewData .AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink '" + sMODULE_NAME + ".ListView', "  + nGridViewIndex     .ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '35%', 'listViewTdLinkS1', 'ID', '" + (bIS_ADMIN ? "~/Administration/" : "~/") + sMODULE_NAME + "/view.aspx?id={0}', null, '" + sMODULE_NAME + "', " + (bINCLUDE_ASSIGNED_USER_ID ? "'ASSIGNED_USER_ID'" : "null") + ";");
									sbModuleGridViewPopup.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink '" + sMODULE_NAME + ".PopupView', " + nGridViewPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '45%', 'listViewTdLinkS1', 'ID " + sFIELD_NAME + "', 'Select" + sMODULE_NAME_SINGULAR + "(''{0}'', ''{1}'');', null, '" + sMODULE_NAME + "', " + (bINCLUDE_ASSIGNED_USER_ID ? "'ASSIGNED_USER_ID'" : "null") + ";");
									nGridViewIndex++;
									nGridViewPopupIndex++;
								}
								else if ( nGridViewIndex < nGridViewMAX )
								{
									sbModuleGridViewData .AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sMODULE_NAME + ".ListView', "  + nGridViewIndex     .ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '20%';");
									sbModuleGridViewPopup.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sMODULE_NAME + ".PopupView', " + nGridViewPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '20%';");
									nGridViewIndex++;
									nGridViewPopupIndex++;
								}
								// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
								sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"" + sFIELD_NAME + "\"" + Strings.Space(35 - sFIELD_NAME.Length) + ").Text");
								if ( Sql.IsEmptyString(sFIRST_TEXT_FIELD) )
									sFIRST_TEXT_FIELD = sFIELD_NAME;
								break;
							case "Text Area":
								sbModuleEditViewData          .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine   '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1,   1, 70, 3;"  );
								sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine    '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1,   1, 70, 3;"  );
								nEditViewIndex++;
								nEditViewSearchAdvancedIndex++;
								if ( nEditViewSearchBasicIndex < nEditViewSearchBasicMAX )
								{
									sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine    '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1,   1, 70, 3;"  );
									sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine    '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1,   1, 70, 3;"  );
									nEditViewSearchBasicIndex++;
									nEditViewSearchPopupIndex++;
								}
								if ( nGridViewIndex == 0 )
								{
									sbModuleGridViewData.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink '" + sMODULE_NAME + ".ListView', " + nGridViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '35%', 'listViewTdLinkS1', 'ID', '" + (bIS_ADMIN ? "~/Administration/" : "~/") + sMODULE_NAME + "/view.aspx?id={0}', null, '" + sMODULE_NAME + "', " + (bINCLUDE_ASSIGNED_USER_ID ? "'ASSIGNED_USER_ID'" : "null") + ";");
									nGridViewIndex++;
								}
								else if ( nGridViewIndex < nGridViewMAX )
								{
									sbModuleGridViewData.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sMODULE_NAME + ".ListView', " + nGridViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '20%';");
									nGridViewIndex++;
								}
								// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
								sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"" + sFIELD_NAME + "\"" + Strings.Space(35 - sFIELD_NAME.Length) + ").Text");
								break;
							case "Integer":
								sbModuleEditViewData          .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound       '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
								sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
								nEditViewIndex++;
								nEditViewSearchAdvancedIndex++;
								if ( nEditViewSearchBasicIndex < nEditViewSearchBasicMAX )
								{
									sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
									sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
									nEditViewSearchBasicIndex++;
									nEditViewSearchPopupIndex++;
								}
								if ( nGridViewIndex == 0 )
								{
									sbModuleGridViewData.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink '" + sMODULE_NAME + ".ListView', " + nGridViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '35%', 'listViewTdLinkS1', 'ID', '" + (bIS_ADMIN ? "~/Administration/" : "~/") + sMODULE_NAME + "/view.aspx?id={0}', null, '" + sMODULE_NAME + "', " + (bINCLUDE_ASSIGNED_USER_ID ? "'ASSIGNED_USER_ID'" : "null") + ";");
									nGridViewIndex++;
								}
								else if ( nGridViewIndex < nGridViewMAX )
								{
									sbModuleGridViewData.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sMODULE_NAME + ".ListView', " + nGridViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '20%';");
									nGridViewIndex++;
								}
								// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
								sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"" + sFIELD_NAME + "\"" + Strings.Space(35 - sFIELD_NAME.Length) + ").IntegerValue");
								break;
							case "bigint" :
								sbModuleEditViewData          .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound       '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
								sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
								nEditViewIndex++;
								nEditViewSearchAdvancedIndex++;
								if ( nEditViewSearchBasicIndex < nEditViewSearchBasicMAX )
								{
									sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
									sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
									nEditViewSearchBasicIndex++;
									nEditViewSearchPopupIndex++;
								}
								if ( nGridViewIndex == 0 )
								{
									sbModuleGridViewData.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink '" + sMODULE_NAME + ".ListView', " + nGridViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '35%', 'listViewTdLinkS1', 'ID', '" + (bIS_ADMIN ? "~/Administration/" : "~/") + sMODULE_NAME + "/view.aspx?id={0}', null, '" + sMODULE_NAME + "', " + (bINCLUDE_ASSIGNED_USER_ID ? "'ASSIGNED_USER_ID'" : "null") + ";");
									nGridViewIndex++;
								}
								else if ( nGridViewIndex < nGridViewMAX )
								{
									sbModuleGridViewData.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sMODULE_NAME + ".ListView', " + nGridViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '" + sFIELD_NAME + "', '20%';");
									nGridViewIndex++;
								}
								// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
								sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"" + sFIELD_NAME + "\"" + Strings.Space(35 - sFIELD_NAME.Length) + ").IntegerValue");
								break;
							case "Decimal":
								sbModuleEditViewData          .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound       '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
								sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
								nEditViewIndex++;
								nEditViewSearchAdvancedIndex++;
								if ( nEditViewSearchBasicIndex < nEditViewSearchBasicMAX )
								{
									sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
									sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
									nEditViewSearchBasicIndex++;
									nEditViewSearchPopupIndex++;
								}
								// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
								sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"" + sFIELD_NAME + "\"" + Strings.Space(35 - sFIELD_NAME.Length) + ").FloatValue");
								break;
							case "Money":
								sbModuleEditViewData          .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound       '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
								sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
								nEditViewIndex++;
								nEditViewSearchAdvancedIndex++;
								if ( nEditViewSearchBasicIndex < nEditViewSearchBasicMAX )
								{
									sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
									sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 10, 10, null;");
									nEditViewSearchBasicIndex++;
									nEditViewSearchPopupIndex++;
								}
								// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
								sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"" + sFIELD_NAME + "\"" + Strings.Space(35 - sFIELD_NAME.Length) + ").DecimalValue");
								break;
							case "Checkbox"   :
								sbModuleEditViewData          .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsControl     '" + sMODULE_NAME + ".EditView', "       + nEditViewIndex.ToString()               + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 'CheckBox', null, null, null;");
								sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsControl      '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 'CheckBox', null, null, null;");
								nEditViewIndex++;
								nEditViewSearchAdvancedIndex++;
								if ( nEditViewSearchBasicIndex < nEditViewSearchBasicMAX )
								{
									sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsControl      '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 'CheckBox', null, null, null;");
									sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsControl      '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 'CheckBox', null, null, null;");
									nEditViewSearchBasicIndex++;
									nEditViewSearchPopupIndex++;
								}
								// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
								sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"" + sFIELD_NAME + "\"" + Strings.Space(35 - sFIELD_NAME.Length) + ").Checked");
								break;
							case "Date":
								sbModuleEditViewData          .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsControl     '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 'DatePicker', null, null, null;");
								sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsControl      '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 'DatePicker', null, null, null;");
								nEditViewIndex++;
								nEditViewSearchAdvancedIndex++;
								if ( nEditViewSearchBasicIndex < nEditViewSearchBasicMAX )
								{
									sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsControl      '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 'DatePicker', null, null, null;");
									sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsControl      '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, 'DatePicker', null, null, null;");
									nEditViewSearchBasicIndex++;
									nEditViewSearchPopupIndex++;
								}
								// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
								sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"" + sFIELD_NAME + "\"" + Strings.Space(35 - sFIELD_NAME.Length) + ").DateValue");
								break;
							case "Dropdown":
								sbModuleEditViewData          .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBoundList   '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, '" + sFIELD_NAME.ToLower() + "_dom', null, null;");
								sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, '" + sFIELD_NAME.ToLower() + "_dom', null, null;");
								nEditViewIndex++;
								nEditViewSearchAdvancedIndex++;
								if ( nEditViewSearchBasicIndex < nEditViewSearchBasicMAX )
								{
									sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, '" + sFIELD_NAME.ToLower() + "_dom', null, null;");
									sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, '" + sFIELD_NAME.ToLower() + "_dom', null, null;");
									nEditViewSearchBasicIndex++;
									nEditViewSearchPopupIndex++;
								}
								// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
								sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"" + sFIELD_NAME + "\"" + Strings.Space(35 - sFIELD_NAME.Length) + ").SelectedValue");
								break;
							case "Guid":
								sbModuleEditViewData          .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsChange      '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, '" + sFIELD_NAME.Substring(0, sFIELD_NAME.Length - 3) + "_NAME', 'return " + sMODULE_NAME_SINGULAR + "Popup();', null;");
								sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsChange       '" + sMODULE_NAME + ".SearchAdvanced', " + nEditViewSearchAdvancedIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, '" + sFIELD_NAME.Substring(0, sFIELD_NAME.Length - 3) + "_NAME', 'return " + sMODULE_NAME_SINGULAR + "Popup();', null;");
								nEditViewIndex++;
								nEditViewSearchAdvancedIndex++;
								if ( nEditViewSearchBasicIndex < nEditViewSearchBasicMAX )
								{
									sbModuleEditViewSearchBasic.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsChange       '" + sMODULE_NAME + ".SearchBasic', " + nEditViewSearchBasicIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, '" + sFIELD_NAME.Substring(0, sFIELD_NAME.Length - 3) + "_NAME', 'return " + sMODULE_NAME_SINGULAR + "Popup();', null;");
									sbModuleEditViewSearchPopup.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsChange       '" + sMODULE_NAME + ".SearchPopup', " + nEditViewSearchPopupIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_" + sFIELD_NAME + "', '" + sFIELD_NAME + "', " + (bREQUIRED ? 1 : 0).ToString() + ", 1, '" + sFIELD_NAME.Substring(0, sFIELD_NAME.Length - 3) + "_NAME', 'return " + sMODULE_NAME_SINGULAR + "Popup();', null;");
									nEditViewSearchBasicIndex++;
									nEditViewSearchPopupIndex++;
								}
								if ( nGridViewIndex == 0 )
								{
									sbModuleGridViewData.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink '" + sMODULE_NAME + ".ListView', " + nGridViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME.Substring(0, sFIELD_NAME.Length - 3) + "_NAME', '" + sFIELD_NAME.Substring(0, sFIELD_NAME.Length - 3) + "_NAME', '35%', 'listViewTdLinkS1', 'ID', '" + (bIS_ADMIN ? "~/Administration/" : "~/") + sMODULE_NAME + "/view.aspx?id={0}', null, '" + sMODULE_NAME + "', " + (bINCLUDE_ASSIGNED_USER_ID ? "'ASSIGNED_USER_ID'" : "null") + ";");
									nGridViewIndex++;
								}
								else if ( nGridViewIndex < nGridViewMAX )
								{
									sbModuleGridViewData.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sMODULE_NAME + ".ListView', " + nGridViewIndex.ToString() + ", '" + sMODULE_NAME + ".LBL_LIST_" + sFIELD_NAME + "', '" + sFIELD_NAME.Substring(0, sFIELD_NAME.Length - 3) + "_NAME', '" + sFIELD_NAME.Substring(0, sFIELD_NAME.Length - 3) + "_NAME', '20%';");
									nGridViewIndex++;
								}
								// 02/09/2015 Paul.  Need to prevent ambiguous reference with System.Web.DynamicData.DynamicControl when not using code-behind. 
								sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"" + sFIELD_NAME + "\"" + Strings.Space(35 - sFIELD_NAME.Length) + ").ID");
								break;
						}
					}
					if ( Sql.IsEmptyString(sFIRST_TEXT_FIELD) )
						sFIRST_TEXT_FIELD = "NAME";
					// 05/24/2017 Paul.  Need to add TAG_SET_NAME as it is used in the stored procedure. 
					sbCallUpdateProcedure.AppendLine("										, new SplendidCRM.DynamicControl(this, rowCurrent, \"TAG_SET_NAME\"                       ).Text");
					sbCallUpdateProcedure.AppendLine("										, trn");
					sbCallUpdateProcedure.AppendLine("										);");
					if ( bINCLUDE_ASSIGNED_USER_ID )
					{
						sbCreateViewFields.AppendLine("     , " + sTABLE_NAME +".ASSIGNED_USER_ID");
						sbCreateViewFields.AppendLine("     , USERS_ASSIGNED.USER_NAME    as ASSIGNED_TO");
						
						sbCreateViewJoins .AppendLine("  left outer join USERS                      USERS_ASSIGNED");
						sbCreateViewJoins .AppendLine("               on USERS_ASSIGNED.ID        = " + sTABLE_NAME +".ASSIGNED_USER_ID");
						
						// 08/26/2009 Paul.  Add support for dynamic teams. 
						sbModuleDetailViewData.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsBound     '" + sMODULE_NAME + ".DetailView', " + nDetailViewIndex.ToString() + ", '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO'                      , '{0}'        , null;");
						nDetailViewIndex++;
						// 09/23/2009 Paul.  Use new ModulePopup fort he assigned user. 
						sbModuleEditViewData  .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_USER_ID'           , 0, 1, 'ASSIGNED_TO'        , 'Users', null;");

						nEditViewIndex++;
						if ( !bINCLUDE_TEAM_ID )
						{
							sbModuleDetailViewData.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     '" + sMODULE_NAME + ".DetailView', " + nDetailViewIndex.ToString() + ", null;");
							nDetailViewIndex++;
							sbModuleEditViewData  .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBlank       '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", null;");
							nEditViewIndex++;
						}
						sbModuleEditViewSearchBasic   .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsControl      '" + sMODULE_NAME + ".SearchBasic'    , " + nEditViewSearchBasicIndex.ToString() + ", '.LBL_CURRENT_USER_FILTER', 'CURRENT_USER_ONLY', 0, null, 'CheckBox', 'return ToggleUnassignedOnly();', null, null;");
						nEditViewSearchBasicIndex++;
						sbModuleEditViewSearchAdvanced.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    '" + sMODULE_NAME + ".SearchAdvanced' , " + nEditViewSearchAdvancedIndex.ToString() + ", '.LBL_ASSIGNED_TO'     , 'ASSIGNED_USER_ID', 0, null, 'AssignedUser'    , null, 6;");
						nEditViewSearchAdvancedIndex++;

						sbModuleGridViewData .AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sMODULE_NAME + ".ListView', "  + nGridViewIndex     .ToString() + ", '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO'     , 'ASSIGNED_TO'     , '10%';");
						sbModuleGridViewPopup.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sMODULE_NAME + ".PopupView', " + nGridViewPopupIndex.ToString() + ", '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO'     , 'ASSIGNED_TO'     , '10%';");
						nGridViewIndex++;
						nGridViewPopupIndex++;
					}
					if ( bINCLUDE_TEAM_ID )
					{
						sbCreateViewFields.AppendLine("     , TEAMS.ID                    as TEAM_ID");
						sbCreateViewFields.AppendLine("     , TEAMS.NAME                  as TEAM_NAME");
						// 09/23/2009 Paul.  TEAM_SET_ID was missing. 
						sbCreateViewFields.AppendLine("     , TEAM_SETS.ID                as TEAM_SET_ID");
						sbCreateViewFields.AppendLine("     , TEAM_SETS.TEAM_SET_NAME     as TEAM_SET_NAME");
						
						sbCreateViewJoins .AppendLine("  left outer join TEAMS");
						sbCreateViewJoins .AppendLine("               on TEAMS.ID                 = " + sTABLE_NAME +".TEAM_ID");
						sbCreateViewJoins .AppendLine("              and TEAMS.DELETED            = 0");
						// 09/23/2009 Paul.  TEAM_SET_ID was missing. 
						sbCreateViewJoins .AppendLine("  left outer join TEAM_SETS");
						sbCreateViewJoins .AppendLine("               on TEAM_SETS.ID             = " + sTABLE_NAME +".TEAM_SET_ID");
						sbCreateViewJoins .AppendLine("              and TEAM_SETS.DELETED        = 0");
						
						if ( !bINCLUDE_ASSIGNED_USER_ID )
						{
							sbModuleDetailViewData.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     '" + sMODULE_NAME + ".DetailView', " + nDetailViewIndex.ToString() + ", null;");
							nDetailViewIndex++;
							sbModuleEditViewData  .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBlank       '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString() + ", null;");
							nEditViewIndex++;
						}
						// 08/26/2009 Paul.  Add support for dynamic teams. 
						// 09/23/2009 Paul.  To allow dynamic teams to be turned off, use base team in fields. 
						sbModuleDetailViewData.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsBound     '" + sMODULE_NAME + ".DetailView', " + nDetailViewIndex.ToString() + ", 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;");
						nDetailViewIndex++;
						sbModuleEditViewData  .AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup '" + sMODULE_NAME + ".EditView', " + nEditViewIndex.ToString()     + ", 'Teams.LBL_TEAM'                         , 'TEAM_ID'                    , 0, 1, 'TEAM_NAME'          , 'Teams', null;");
						nEditViewIndex++;

						sbModuleGridViewData .AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sMODULE_NAME + ".ListView', "  + nGridViewIndex     .ToString() + ", 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '5%';");
						sbModuleGridViewPopup.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sMODULE_NAME + ".PopupView', " + nGridViewPopupIndex.ToString() + ", 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'       , 'TEAM_NAME'       , '10%';");
						nGridViewIndex++;
						nGridViewPopupIndex++;
					}
					sbModuleDetailViewData.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsBound     '" + sMODULE_NAME + ".DetailView', " + nDetailViewIndex.ToString() + ", '.LBL_DATE_MODIFIED'              , 'DATE_MODIFIED .LBL_BY MODIFIED_BY', '{0} {1} {2}', null;");
					nDetailViewIndex++;
					sbModuleDetailViewData.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsBound     '" + sMODULE_NAME + ".DetailView', " + nDetailViewIndex.ToString() + ", '.LBL_DATE_ENTERED'               , 'DATE_ENTERED .LBL_BY CREATED_BY'  , '{0} {1} {2}', null;");
					nDetailViewIndex++;

					sbModuleEditViewSearchBasic.AppendLine("");

					foreach ( string sRELATED_MODULE in lstRelationships )
					{
						{
							string sRELATED_TABLE           = Sql.ToString(Application["Modules." + sRELATED_MODULE + ".TableName"]);

							sbMergeProcedureUpdates.AppendLine("	update " + sTABLE_NAME + "_" + sRELATED_TABLE);
							sbMergeProcedureUpdates.AppendLine("	   set " + sTABLE_NAME_SINGULAR + "_ID       = @ID");
							sbMergeProcedureUpdates.AppendLine("	     , DATE_MODIFIED    = getdate()");
							sbMergeProcedureUpdates.AppendLine("	     , DATE_MODIFIED_UTC= getutcdate()");
							sbMergeProcedureUpdates.AppendLine("	     , MODIFIED_USER_ID = @MODIFIED_USER_ID");
							sbMergeProcedureUpdates.AppendLine("	 where " + sTABLE_NAME_SINGULAR + "_ID       = @MERGE_ID");
							sbMergeProcedureUpdates.AppendLine("	   and DELETED          = 0;");
							sbMergeProcedureUpdates.AppendLine("");
							
							// 08/08/2013 Paul.  Add delete and undelete of relationships. 
							sbDeleteProcedureUpdates.AppendLine("	update " + sTABLE_NAME + "_" + sRELATED_TABLE);
							sbDeleteProcedureUpdates.AppendLine("	   set DELETED          = 1");
							sbDeleteProcedureUpdates.AppendLine("	     , DATE_MODIFIED    = getdate()");
							sbDeleteProcedureUpdates.AppendLine("	     , DATE_MODIFIED_UTC= getutcdate()");
							sbDeleteProcedureUpdates.AppendLine("	     , MODIFIED_USER_ID = @MODIFIED_USER_ID");
							sbDeleteProcedureUpdates.AppendLine("	  where " + sTABLE_NAME_SINGULAR + "_ID       = @ID");
							sbDeleteProcedureUpdates.AppendLine("	   and DELETED          = 0;");
							sbDeleteProcedureUpdates.AppendLine("");
							
							sbUndeleteProcedureUpdates.AppendLine("	update " + sTABLE_NAME + "_" + sRELATED_TABLE);
							sbUndeleteProcedureUpdates.AppendLine("	   set DELETED          = 1");
							sbUndeleteProcedureUpdates.AppendLine("	     , DATE_MODIFIED    = getdate()");
							sbUndeleteProcedureUpdates.AppendLine("	     , DATE_MODIFIED_UTC= getutcdate()");
							sbUndeleteProcedureUpdates.AppendLine("	     , MODIFIED_USER_ID = @MODIFIED_USER_ID");
							sbUndeleteProcedureUpdates.AppendLine("	  where " + sTABLE_NAME_SINGULAR + "_ID       = @ID");
							sbUndeleteProcedureUpdates.AppendLine("	   and DELETED          = 0;");
							sbUndeleteProcedureUpdates.AppendLine("");
						}
					}
					// 03/06/2010 Paul.  EditView inline and PopupView inline will be identical to the EditView. 
					StringBuilder sbModuleEditViewDataInline  = new StringBuilder();
					StringBuilder sbModulePopupViewDataInline = new StringBuilder();
					sbModuleEditViewDataInline .Append(sbModuleEditViewData.ToString().Replace("'" + sMODULE_NAME + ".EditView'", "'" + sMODULE_NAME + ".EditView.Inline'" ));
					sbModulePopupViewDataInline.Append(sbModuleEditViewData.ToString().Replace("'" + sMODULE_NAME + ".EditView'", "'" + sMODULE_NAME + ".PopupView.Inline'"));

					System.Text.Encoding enc = System.Text.Encoding.UTF8;
					DataTable dtSQLScripts = new DataTable();
					dtSQLScripts.Columns.Add("FOLDER"        );
					dtSQLScripts.Columns.Add("NAME"          );
					dtSQLScripts.Columns.Add("PROCEDURE_NAME");
					dtSQLScripts.Columns.Add("SQL_SCRIPT"    );
					dtSQLScripts.Columns.Add("CODE_WRAPPER"  );

					DataView vwFieldsNAME = new DataView(dtFields);
					vwFieldsNAME.RowFilter = "FIELD_NAME = 'NAME'";
					string[] arrSqlFolders = Directory.GetDirectories(sSqlTemplatesPath);
					foreach ( string sSqlFolder in arrSqlFolders )
					{
						//sbProgress.AppendLine(sSqlFolder + "<br>");
						
						string[] arrSqlFolderParts = sSqlFolder.Split(Path.DirectorySeparatorChar);
						string sFolder = arrSqlFolderParts[arrSqlFolderParts.Length - 1];
						string[] arrSqlTemplates = Directory.GetFiles(sSqlFolder, "*.sql");
						foreach ( string sSqlTemplate in arrSqlTemplates )
						{
							//sbProgress.AppendLine(sSqlTemplate + "<br>");
							if ( sSqlTemplate.IndexOf("$relatedmodule$") >= 0 || sSqlTemplate.IndexOf("$relatedtable$") >= 0 )
								continue;
							// 08/24/2009 Paul.  Skip files that are team specific. 
							if ( !bINCLUDE_TEAM_ID && sSqlTemplate.IndexOf("TEAMS") >= 0 )
								continue;
							
							string sSqlScriptName = Path.GetFileName(sSqlTemplate);
							sSqlScriptName = sSqlScriptName.Replace("$modulename$"        , sMODULE_NAME         );
							sSqlScriptName = sSqlScriptName.Replace("$modulenamesingular$", sMODULE_NAME_SINGULAR);
							sSqlScriptName = sSqlScriptName.Replace("$tablename$"         , sTABLE_NAME          );
							sSqlScriptName = sSqlScriptName.Replace("$tablenamesingular$" , sTABLE_NAME_SINGULAR );
							
							DataRow rowSQL = dtSQLScripts.NewRow();
							dtSQLScripts.Rows.Add(rowSQL);
							rowSQL["FOLDER"        ] = sFolder;
							rowSQL["NAME"          ] = sSqlScriptName;
							rowSQL["PROCEDURE_NAME"] = sSqlScriptName.Split('.')[0];
							using ( StreamReader sr = new StreamReader(sSqlTemplate, enc, true) )
							{
								string sData = sr.ReadToEnd();
								// 10/03/2010 Paul.  We need to fix any GridViews that reference ASSIGNED_USER_ID if that field does not exist. 
								// 11/25/2021 Paul.  SYSTEM_REST_TABLES also has ASSIGNED_USER_ID. 
								if ( !bINCLUDE_ASSIGNED_USER_ID && (sSqlTemplate.Contains("GRIDVIEWS_COLUMNS") || sSqlTemplate.Contains("SYSTEM_REST_TABLES")))
								{
									sData = sData.Replace("\'ASSIGNED_USER_ID\'", "null");
								}
								sData = sData.Replace("$displayname$"                  , sDISPLAY_NAME         );
								// 06/04/2015 Paul.  The abbreviated name is used by the Seven theme. 
								sData = sData.Replace("$abbreviatedname$"              , sDISPLAY_NAME.Substring(0, 3));
								sData = sData.Replace("$displaynamesingular$"          , sDISPLAY_NAME_SINGULAR);
								sData = sData.Replace("$modulename$"                   , sMODULE_NAME          );
								sData = sData.Replace("$modulenamesingular$"           , sMODULE_NAME_SINGULAR );
								sData = sData.Replace("$tablename$"                    , sTABLE_NAME           );
								sData = sData.Replace("$tablenamesingular$"            , sTABLE_NAME_SINGULAR  );

								sData = sData.Replace("$tablename$"                    , sTABLE_NAME          );
								sData = sData.Replace("$tabenabled$"                   , bTAB_ENABLED    ? "1" : "0");
								sData = sData.Replace("$mobileenabled$"                , bMOBILE_ENABLED ? "1" : "0");
								sData = sData.Replace("$customenabled$"                , bCUSTOM_ENABLED ? "1" : "0");
								sData = sData.Replace("$reportenabled$"                , bREPORT_ENABLED ? "1" : "0");
								sData = sData.Replace("$importenabled$"                , bIMPORT_ENABLED ? "1" : "0");
								// 09/12/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
								sData = sData.Replace("$restenabled$"                  , bREST_ENABLED   ? "1" : "0");
								sData = sData.Replace("$isadmin$"                      , bIS_ADMIN       ? "1" : "0");
								// 11/25/2021 Paul.  SYSTEM_REST_TABLES also has ASSIGNED_USER_ID. 
								sData = sData.Replace("$isassigned$"                   , bINCLUDE_ASSIGNED_USER_ID ? "1" : "0");
								sData = sData.Replace("$administrationfolder$"         , bIS_ADMIN       ? "Administration/" : "");
								sData = sData.Replace("$taborder$"                     , "100");

								sData = sData.Replace("$createtablefields$"            , sbCreateTableFields            .ToString());
								sData = sData.Replace("$createtableindexes$"           , sbCreateTableIndexes           .ToString());
								sData = sData.Replace("$createviewfields$"             , sbCreateViewFields             .ToString());
								sData = sData.Replace("$createprocedureparameters$"    , sbCreateProcedureParameters    .ToString());
								sData = sData.Replace("$createprocedureinsertinto$"    , sbCreateProcedureInsertInto    .ToString());
								sData = sData.Replace("$createprocedureinsertvalues$"  , sbCreateProcedureInsertValues  .ToString());
								sData = sData.Replace("$createprocedureupdate$"        , sbCreateProcedureUpdate        .ToString());
								sData = sData.Replace("$createprocedurenormalizeteams$", sbCreateProcedureNormalizeTeams.ToString());
								sData = sData.Replace("$createprocedureupdateteams$"   , sbCreateProcedureUpdateTeams   .ToString());
								sData = sData.Replace("$altertablefields$"             , sbAlterTableFields             .ToString());

								sData = sData.Replace("$createviewjoins$"              , sbCreateViewJoins              .ToString());
								sData = sData.Replace("$massupdateviewfields$"         , sbMassUpdateProcedureFields    .ToString());
								sData = sData.Replace("$massupdatesets$"               , sbMassUpdateProcedureSets      .ToString());
								sData = sData.Replace("$massupdateteamnormalize$"      , sbMassUpdateTeamNormalize      .ToString());
								sData = sData.Replace("$massupdateteamadd$"            , sbMassUpdateTeamAdd            .ToString());
								sData = sData.Replace("$massupdateteamupdate$"         , sbMassUpdateTeamUpdate         .ToString());

								sData = sData.Replace("$mergeupdaterelationship$"      , sbMergeProcedureUpdates        .ToString());

								sData = sData.Replace("$modulegridviewdata$"           , sbModuleGridViewData           .ToString());
								sData = sData.Replace("$modulegridviewpopup$"          , sbModuleGridViewPopup          .ToString());
								sData = sData.Replace("$moduledetailviewdata$"         , sbModuleDetailViewData         .ToString());
								sData = sData.Replace("$moduleeditviewdata$"           , sbModuleEditViewData           .ToString());
								sData = sData.Replace("$moduleeditviewdatainline$"     , sbModuleEditViewDataInline     .ToString());
								sData = sData.Replace("$modulepopupviewdatainline$"    , sbModulePopupViewDataInline    .ToString());
								sData = sData.Replace("$moduleeditviewsearchbasic$"    , sbModuleEditViewSearchBasic    .ToString());
								sData = sData.Replace("$moduleeditviewsearchadvanced$" , sbModuleEditViewSearchAdvanced .ToString());
								sData = sData.Replace("$moduleeditviewsearchpopup$"    , sbModuleEditViewSearchPopup    .ToString());

								sData = sData.Replace("$moduleterminology$"            , sbModuleTerminology            .ToString());
								sData = sData.Replace("$relatedterminology$"           , "");

								// 08/08/2013 Paul.  Add delete and undelete of relationships. 
								sData = sData.Replace("$deleteprocedureupdates$"       , sbDeleteProcedureUpdates       .ToString());
								sData = sData.Replace("$undeleteprocedureupdates$"     , sbUndeleteProcedureUpdates     .ToString());

								// 04/03/2012 Paul.  If the custom module has a name field, then uncomment the favorites update procedure. 
								if ( sSqlTemplate.Contains("sp$tablename$_Update.1.sql") )
								{
									if ( vwFieldsNAME.Count > 0 )
									{
										sData = sData.Replace("--exec dbo.spSUGARFAVORITES_UpdateName", "exec dbo.spSUGARFAVORITES_UpdateName");
									}
								}
								rowSQL["SQL_SCRIPT"] = sData;

								string sSqlScriptPath = Path.Combine(sSqlScriptsPath, sFolder);
								try
								{
									if ( !Directory.Exists(sSqlScriptPath) )
									{
										Directory.CreateDirectory(sSqlScriptPath);
									}
								}
								catch(Exception ex)
								{
									sbProgress.AppendLine("<font class=error>Failed to create " + sSqlScriptPath + ":" + ex.Message + "</font><br>");
								}
								
								string sSqlScriptFile = Path.Combine(sSqlScriptPath, sSqlScriptName);
								try
								{
									sbProgress.AppendLine(sSqlScriptFile + "<br>");
									if ( bOVERWRITE_EXISTING && File.Exists(sSqlScriptFile) )
										File.Delete(sSqlScriptFile);
									using(StreamWriter stm = File.CreateText(sSqlScriptFile))
									{
										stm.Write(sData);
									}
								}
								catch(Exception ex)
								{
									sbProgress.AppendLine("<font class=error>" + sSqlScriptFile + ":" + ex.Message + "</font><br>");
								}
							}
						}
					}

					foreach ( string sRELATED_MODULE in lstRelationships )
					{
						{
							string sRELATED_MODULE_SINGULAR = sRELATED_MODULE;
							string sRELATED_TABLE           = Sql.ToString(Application["Modules." + sRELATED_MODULE + ".TableName"]);
							string sRELATED_TABLE_SINGULAR  = sRELATED_TABLE;
							if ( sRELATED_MODULE_SINGULAR.ToLower().EndsWith("ies") )
								sRELATED_MODULE_SINGULAR = sRELATED_MODULE_SINGULAR.Substring(0, sRELATED_MODULE_SINGULAR.Length-3) + "Y";
							else if ( sRELATED_MODULE_SINGULAR.ToLower().EndsWith("s") )
								sRELATED_MODULE_SINGULAR = sRELATED_MODULE_SINGULAR.Substring(0, sRELATED_MODULE_SINGULAR.Length-1);
							if ( sRELATED_TABLE_SINGULAR.ToLower().EndsWith("ies") )
								sRELATED_TABLE_SINGULAR = sRELATED_TABLE_SINGULAR.Substring(0, sRELATED_TABLE_SINGULAR.Length-3) + "Y";
							else if ( sRELATED_TABLE_SINGULAR.ToLower().EndsWith("s") )
								sRELATED_TABLE_SINGULAR = sRELATED_TABLE_SINGULAR.Substring(0, sRELATED_TABLE_SINGULAR.Length-1);

							foreach ( string sSqlFolder in arrSqlFolders )
							{
								//sbProgress.AppendLine(sSqlFolder + "<br>");
								
								string[] arrSqlFolderParts = sSqlFolder.Split(Path.DirectorySeparatorChar);
								string sFolder = arrSqlFolderParts[arrSqlFolderParts.Length - 1];
								string[] arrSqlTemplates = Directory.GetFiles(sSqlFolder, "*.sql");
								foreach ( string sSqlTemplate in arrSqlTemplates )
								{
									//sbProgress.AppendLine(sSqlTemplate + "<br>");
									if ( sSqlTemplate.IndexOf("$relatedmodule$") < 0 && sSqlTemplate.IndexOf("$relatedtable$") < 0 )
										continue;
									
									string sSqlScriptName = Path.GetFileName(sSqlTemplate);
									sSqlScriptName = sSqlScriptName.Replace("$modulename$"           , sMODULE_NAME            );
									sSqlScriptName = sSqlScriptName.Replace("$modulenamesingular$"   , sMODULE_NAME_SINGULAR   );
									sSqlScriptName = sSqlScriptName.Replace("$tablename$"            , sTABLE_NAME             );
									sSqlScriptName = sSqlScriptName.Replace("$tablenamesingular$"    , sTABLE_NAME_SINGULAR    );
									sSqlScriptName = sSqlScriptName.Replace("$relatedmodule$"        , sRELATED_MODULE         );
									sSqlScriptName = sSqlScriptName.Replace("$relatedmodulesingular$", sRELATED_MODULE_SINGULAR);
									sSqlScriptName = sSqlScriptName.Replace("$relatedtable$"         , sRELATED_TABLE          );
									sSqlScriptName = sSqlScriptName.Replace("$relatedtablesingular$" , sRELATED_TABLE_SINGULAR );
									
									DataRow rowSQL = dtSQLScripts.NewRow();
									dtSQLScripts.Rows.Add(rowSQL);
									rowSQL["FOLDER"        ] = sFolder;
									rowSQL["NAME"          ] = sSqlScriptName;
									rowSQL["PROCEDURE_NAME"] = sSqlScriptName.Split('.')[0];
									using ( StreamReader sr = new StreamReader(sSqlTemplate, enc, true) )
									{
										string sData = sr.ReadToEnd();
										if ( sSqlTemplate.EndsWith("vw$tablename$_$relatedtable$.1.sql") )
										{
											// 03/03/2011 Paul.  vwDOCUMENTS table already has a DOCUMENT_NAME field. 
											if ( sRELATED_TABLE == "DOCUMENTS" )
											{
												sData = sData.Replace("     , vw$relatedtable$.NAME ", "--     , vw$relatedtable$.NAME ");
											}
											// 03/03/2011 Paul.  vwPRODUCTS table already has a PRODUCT_ID field and a PRODUCT_NAME field. 
											if ( sRELATED_TABLE == "PRODUCTS" )
											{
												sData = sData.Replace("     , vw$relatedtable$.ID   ", "--     , vw$relatedtable$.ID   ");
												sData = sData.Replace("     , vw$relatedtable$.NAME ", "--     , vw$relatedtable$.NAME ");
											}
										}
										// 03/05/2011 Paul.  Emails and Notes don't have popup pages. 
										else if ( sSqlTemplate.EndsWith("DYNAMIC_BUTTONS $modulename$.$relatedmodule$.1.sql") )
										{
											if ( sRELATED_MODULE == "Emails" || sRELATED_MODULE == "Notes" )
											{
												sData = sData.Replace("exec dbo.spDYNAMIC_BUTTONS_InsPopup  '$modulename$.$relatedmodule$', 1, '$modulename$', 'edit', '$relatedmodule$', 'list', '$relatedmodulesingular$Popup();'", "--exec dbo.spDYNAMIC_BUTTONS_InsPopup  '$modulename$.$relatedmodule$', 1, '$modulename$', 'edit', '$relatedmodule$', 'list', '$relatedmodulesingular$Popup();'");
											}
										}
										// 08/08/2013 Paul.  If this is the audit file, then also add auditing of custom field table. 
										else if ( sSqlTemplate.EndsWith("BuildAuditTable_$tablename$.1.sql") )
										{
											if ( bCUSTOM_ENABLED )
												sData += sData.Replace("$tablename$", "$tablename$_CSTM");
										}
										sData = sData.Replace("$modulename$"                 , sMODULE_NAME            );
										sData = sData.Replace("$modulenamesingular$"         , sMODULE_NAME_SINGULAR   );
										sData = sData.Replace("$tablename$"                  , sTABLE_NAME             );
										sData = sData.Replace("$tablenamesingular$"          , sTABLE_NAME_SINGULAR    );
										sData = sData.Replace("$relatedmodule$"              , sRELATED_MODULE         );
										sData = sData.Replace("$relatedmodulesingular$"      , sRELATED_MODULE_SINGULAR);
										sData = sData.Replace("$relatedtable$"               , sRELATED_TABLE          );
										sData = sData.Replace("$relatedtablesingular$"       , sRELATED_TABLE_SINGULAR );
										// 10/03/2010 Paul.  Related Assigned should only be created if related field exists. 
										if ( bINCLUDE_ASSIGNED_USER_ID )
											sData = sData.Replace("$relatedviewassigned$"        , "     , " + sTABLE_NAME + ".ASSIGNED_USER_ID as " + sTABLE_NAME_SINGULAR + "_ASSIGNED_USER_ID");
										else
											sData = sData.Replace("$relatedviewassigned$"        , String.Empty);
										rowSQL["SQL_SCRIPT"] = sData;
										
										string sSqlScriptPath = Path.Combine(sSqlScriptsPath, sFolder);
										try
										{
											if ( !Directory.Exists(sSqlScriptPath) )
											{
												Directory.CreateDirectory(sSqlScriptPath);
											}
										}
										catch(Exception ex)
										{
											sbProgress.AppendLine("<font class=error>Failed to create " + sSqlScriptPath + ":" + ex.Message + "</font><br>");
										}
										
										string sSqlScriptFile = Path.Combine(sSqlScriptPath, sSqlScriptName);
										try
										{
											sbProgress.AppendLine(sSqlScriptFile + "<br>");
											if ( bOVERWRITE_EXISTING && File.Exists(sSqlScriptFile) )
												File.Delete(sSqlScriptFile);
											using(StreamWriter stm = File.CreateText(sSqlScriptFile))
											{
												stm.Write(sData);
											}
										}
										catch(Exception ex)
										{
											sbProgress.AppendLine("<font class=error>" + sSqlScriptFile + ":" + ex.Message + "</font><br>");
										}
									}
								}
							}
						}
					}

					DataView vwSQLScripts = new DataView(dtSQLScripts);
					// 03/08/2010 Paul.  Allow user to select Live deployment, but we still prefer the code-behind method. 
					// 11/25/2021 Paul.  REACT Only will live deploy. 
					if ( !bCREATE_CODE_BEHIND || bREACT_ONLY )
					{
						// 03/06/2010 Paul.  We need to apply the SQL Scripts so that we can generate the SqlProcs code prior to generating the C# code. 
						// 09/26/2011 Paul.  Update triggers for auditing. 
						string[] arrSQLFolderTypes = new string[] { "BaseTables", "Tables", "Views", "Procedures", "Triggers", "Data", "Terminology" };
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							bool bSQLAzure = false;
							if ( Sql.IsSQLServer(con) )
							{
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = "select @@VERSION";
									string sSqlVersion = Sql.ToString(cmd.ExecuteScalar());
									// 10/13/2009 Paul.  Azure Product database has a different version than the CTP environment. 
									if ( sSqlVersion.StartsWith("Microsoft SQL Azure") || (sSqlVersion.IndexOf("SQL Server") > 0 && sSqlVersion.IndexOf("CloudDB") > 0) )
									{
										bSQLAzure = true;
									}
								}
							}
							foreach ( string sSQLFolderType in arrSQLFolderTypes )
							{
								// 09/26/2011 Paul.  Don't include the triggers folder unless this module supports auditing. 
								// 08/08/2013 Paul.  This code is wrong.  We should always create the triggers, but optionally add triggers to custom field table. 
								//if ( bCUSTOM_ENABLED && sSQLFolderType == "Triggers" )
								//	continue;
								for ( int nFolderLevel = 0; nFolderLevel <= 9; nFolderLevel++ )
								{
									vwSQLScripts.RowFilter = "FOLDER = '" + sSQLFolderType + "' and NAME like '%." + nFolderLevel.ToString() + ".sql'";
									foreach ( DataRowView row in vwSQLScripts )
									{
										string sNAME           = Sql.ToString(row["NAME"          ]);
										string sPROCEDURE_NAME = Sql.ToString(row["PROCEDURE_NAME"]);
										string sSQL_SCRIPT     = Sql.ToString(row["SQL_SCRIPT"    ]);
										try
										{
											sbProgress.AppendLine(sSQLFolderType + "\\" + sNAME + "<br>");
											if ( Sql.IsSQLServer(con) )
											{
												sSQL_SCRIPT = sSQL_SCRIPT.Replace("\r\ngo\r\n", "\r\nGO\r\n");
												sSQL_SCRIPT = sSQL_SCRIPT.Replace("\r\nGo\r\n", "\r\nGO\r\n");
												if ( bSQLAzure )
												{
													if ( sSQLFolderType == "Functions" || sSQLFolderType.StartsWith("Views") || sSQLFolderType.StartsWith("Procedures") )
													{
														sSQL_SCRIPT = sSQL_SCRIPT.Replace("\r\nwith encryption\r\n", "\r\n");
													}
												}
											}
											using ( IDbCommand cmd = con.CreateCommand() )
											{
												cmd.CommandType = CommandType.Text;
												string[] aCommands = null;
												if ( Sql.IsSQLServer(con) )
												{
													aCommands = Strings.Split(sSQL_SCRIPT, "\r\nGO\r\n", -1, CompareMethod.Text);
												}
												else if ( Sql.IsOracle(con) )
												{
													aCommands = Strings.Split(sSQL_SCRIPT, "\r\n/\r\n", -1, CompareMethod.Text);
												}
												else if ( Sql.IsMySQL(con) )
												{
													sSQL_SCRIPT = RemoveComments(sSQL_SCRIPT);
													aCommands = Strings.Split(sSQL_SCRIPT, "\r\n/\r\n", -1, CompareMethod.Text);
												}
												else if ( Sql.IsDB2(con) )
												{
													sSQL_SCRIPT = RemoveComments(sSQL_SCRIPT);
													aCommands = Strings.Split(sSQL_SCRIPT, "\r\n/\r\n", -1, CompareMethod.Text);
												}
												foreach ( string sCommand in aCommands )
												{
													if ( Sql.IsOracle(con) )
													{
														cmd.CommandText = sCommand;
														// 03/20/2006 Paul.  Oracle does not like CRLF. 
														// PLS-00103: Encountered the symbol "" when expecting one of the following:     return 
														cmd.CommandText = cmd.CommandText.Replace("\r\n", "\n");
													}
													else
														cmd.CommandText = sCommand;
													cmd.CommandText = cmd.CommandText.TrimStart(" \t\r\n".ToCharArray());
													cmd.CommandText = cmd.CommandText.TrimEnd  (" \t\r\n".ToCharArray());
													if ( cmd.CommandText.Length > 0 )
													{
														cmd.ExecuteNonQuery();
													}
												}
											}
											// 11/25/2021 Paul.  REACT Only will live deploy. 
											if ( sSQLFolderType == "Procedures" && !bREACT_ONLY )
											{
												string sSQL;
												sSQL = "select *                       " + ControlChars.CrLf
												     + "  from vwSqlColumns            " + ControlChars.CrLf
												     + " where ObjectName = @OBJECTNAME" + ControlChars.CrLf
												     + "   and ObjectType = 'P'        " + ControlChars.CrLf
												     + " order by colid                " + ControlChars.CrLf;
												using ( IDbCommand cmd = con.CreateCommand() )
												{
													cmd.CommandText = sSQL;
													Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, sPROCEDURE_NAME));
													using ( DbDataAdapter da = dbf.CreateDataAdapter() )
													{
														((IDbDataAdapter)da).SelectCommand = cmd;
														using ( DataTable dt = new DataTable() )
														{
															da.Fill(dt);
															DataRowCollection colRows = dt.Rows;
															StringBuilder sb = new StringBuilder();
															sb.AppendLine("	public partial class SqlProcs");
															sb.AppendLine("	{");
															_devtools.Procedures.BuildWrapper(ref sb, sPROCEDURE_NAME, ref colRows, false, false);
															_devtools.Procedures.BuildWrapper(ref sb, sPROCEDURE_NAME, ref colRows, false, true );
															_devtools.Procedures.BuildWrapper(ref sb, sPROCEDURE_NAME, ref colRows, true , false);
															sb.AppendLine("	}");
															string sCODE_WRAPPER = sb.ToString();
															// 03/07/2010 Paul.  When not using a code-behind, we need to prevent namespace collissions. 
															// 08/25/2010 Paul.  We only need to replace the namespace if using the Live template. 
															if ( !bCREATE_CODE_BEHIND )
															{
																sCODE_WRAPPER = sCODE_WRAPPER.Replace("DbProviderFactory"  , "SplendidCRM.DbProviderFactory"  );
																sCODE_WRAPPER = sCODE_WRAPPER.Replace("DbProviderFactories", "SplendidCRM.DbProviderFactories");
															}
															row["CODE_WRAPPER"] = sCODE_WRAPPER;
														}
													}
												}
											}
										}
										catch(Exception ex)
										{
											sbProgress.AppendLine("<font class=error>" + sNAME + ":" + ex.Message + "</font><br>");
										}
									}
								}
							}
							// 11/26/2021 Paul.  Must also update the security rules for the new module. 
							SqlProcs.spACL_ACTIONS_Initialize();
							sbProgress.AppendLine("spACL_ACTIONS_Initialize<br>");
						}
					}
				// 11/25/2021 Paul.  REACT Only will live deploy. 
				if ( !bREACT_ONLY )
				{
					string[] arrWebTemplates = Directory.GetFiles(sWebTemplatesPath);
					foreach ( string sWebTemplate in arrWebTemplates )
					{
						if ( sWebTemplate.IndexOf("$relatedmodule$") >= 0 || sWebTemplate.IndexOf("$relatedtable$") >= 0 )
							continue;
						// 03/07/2010 Paul.  The code-behind files are not used so that the generated files will be immediately accessible. 
						// 08/25/2010 Paul.  We still want to allow code-behind files. 
						//if ( sWebTemplate.EndsWith(".cs") )
						//	continue;
						
						using ( StreamReader sr = new StreamReader(sWebTemplate, enc, true) )
						{
							string sData = sr.ReadToEnd();
							// 09/12/2009 Paul.  If this is an admin module, then place in the Administration namespace. 
							if ( bIS_ADMIN )
								sData = sData.Replace("SplendidCRM.$modulename$", "SplendidCRM.Administration.$modulename$");
							sData = sData.Replace("$modulename$"        , sMODULE_NAME         );
							sData = sData.Replace("$modulenamesingular$", sMODULE_NAME_SINGULAR);
							sData = sData.Replace("$tablename$"         , sTABLE_NAME          );
							sData = sData.Replace("$tablenamesingular$" , sTABLE_NAME_SINGULAR );
							sData = sData.Replace("$firsttextfield$"    , sFIRST_TEXT_FIELD    );

							string sWebTemplateName = Path.GetFileName(sWebTemplate);
							if ( sWebTemplateName.StartsWith("DetailView.ascx") )
							{
								if ( !bINCLUDE_ASSIGNED_USER_ID )
								{
									sData = sData.Replace("Sql.ToGuid(rdr[\"ASSIGNED_USER_ID\"])", "Guid.Empty");
								}
							}
							else if ( sWebTemplateName.StartsWith("ListView.ascx") )
							{
								if ( !bINCLUDE_ASSIGNED_USER_ID )
								{
									sData = sData.Replace("Sql.ToGuid(rdr[\"ASSIGNED_USER_ID\"])", "Guid.Empty");
									// 03/05/2011 Paul. Now that we have added the edit button, we need to remove Assigned User. 
									sData = sData.Replace(", Sql.ToGuid(Eval(\"ASSIGNED_USER_ID\"))", String.Empty);
									// 03/07/2011 Paul.  Remove ASSIGNED_USER_ID from arrSelectFields. 
									sData = sData.Replace("arrSelectFields.Add(\"ASSIGNED_USER_ID\");", String.Empty);
								}
								// 05/13/2016 Paul.  Add Tags module. 
								if ( bINCLUDE_ASSIGNED_USER_ID && bINCLUDE_TEAM_ID )
									sData = sData.Replace("$callmassupdateprocedure$", "SqlProcs.sp" + sTABLE_NAME + "_MassUpdate(sIDs, ctlMassUpdate.ASSIGNED_USER_ID, ctlMassUpdate.PRIMARY_TEAM_ID, ctlMassUpdate.TEAM_SET_LIST, ctlMassUpdate.ADD_TEAM_SET, ctlMassUpdate.TAG_SET_NAME, ctlMassUpdate.ADD_TAG_SET, trn);");
								else if ( bINCLUDE_ASSIGNED_USER_ID )
									sData = sData.Replace("$callmassupdateprocedure$", "SqlProcs.sp" + sTABLE_NAME + "_MassUpdate(sIDs, ctlMassUpdate.ASSIGNED_USER_ID, ctlMassUpdate.TAG_SET_NAME, ctlMassUpdate.ADD_TAG_SET, trn);");
								else if ( bINCLUDE_TEAM_ID )
									sData = sData.Replace("$callmassupdateprocedure$", "SqlProcs.sp" + sTABLE_NAME + "_MassUpdate(sIDs, ctlMassUpdate.PRIMARY_TEAM_ID, ctlMassUpdate.TEAM_SET_LIST, ctlMassUpdate.ADD_TEAM_SET, ctlMassUpdate.TAG_SET_NAME, ctlMassUpdate.ADD_TAG_SET, trn);");
								else  // 10/12/2009 Paul.  Remove insertion if not used. 
									sData = sData.Replace("$callmassupdateprocedure$", "");
							}
							else if ( sWebTemplateName.StartsWith("ListView.ascx.cs") )
							{
								if ( !bINCLUDE_ASSIGNED_USER_ID )
								{
									// 03/07/2011 Paul.  Remove ASSIGNED_USER_ID from arrSelectFields. 
									sData = sData.Replace("arrSelectFields.Add(\"ASSIGNED_USER_ID\");", String.Empty);
								}
							}
							else if ( sWebTemplateName.StartsWith("EditView.ascx") )
							{
								sData = sData.Replace("$callupdateprocedure$", sbCallUpdateProcedure.ToString());
							}
							else if ( sWebTemplateName.StartsWith("NewRecord.ascx") )
							{
								// 06/22/2010 Paul.  The NewRecord controls do not use rowCurrent. 
								sData = sData.Replace("$callupdateprocedure$", sbCallUpdateProcedure.ToString().Replace("rowCurrent,", "null,"));
							}

							// 03/08/2010 Paul.  Allow user to select Live deployment, but we still prefer the code-behind method. 
							if ( !bCREATE_CODE_BEHIND )
							{
								// 03/06/2010 Paul.  Insert the SqlProc wrapper into each file as needed. 
								vwSQLScripts.RowFilter = "FOLDER = 'Procedures'";
								foreach ( DataRowView row in vwSQLScripts )
								{
									string sPROCEDURE_NAME = Sql.ToString(row["PROCEDURE_NAME"]);
									string sCODE_WRAPPER   = Sql.ToString(row["CODE_WRAPPER"  ]);
									if ( !Sql.IsEmptyString(sCODE_WRAPPER) )
									{
										if ( sData.IndexOf("SqlProcs." + sPROCEDURE_NAME) >= 0 )
										{
											sData = sData.Replace("//$sqlprocs$", sCODE_WRAPPER + ControlChars.CrLf + ControlChars.CrLf + "//$sqlprocs$");
										}
									}
								}
							}
							sData = sData.Replace("//$sqlprocs$", String.Empty);
							
							string sWebModuleFile = Path.Combine(sWebModulePath, sWebTemplateName);
							try
							{
								sbProgress.AppendLine(sWebModuleFile + "<br>");
								if ( bOVERWRITE_EXISTING && File.Exists(sWebModuleFile) )
									File.Delete(sWebModuleFile);
								using(StreamWriter stm = File.CreateText(sWebModuleFile))
								{
									stm.Write(sData);
								}
							}
							catch(Exception ex)
							{
								sbProgress.AppendLine("<font class=error>" + sWebTemplate + ":" + ex.Message + "</font><br>");
							}
						}
					}
					
					foreach ( string sRELATED_MODULE in lstRelationships )
					{
						{
							string sRELATED_MODULE_SINGULAR = sRELATED_MODULE;
							string sRELATED_TABLE           = Sql.ToString(Application["Modules." + sRELATED_MODULE + ".TableName"]);
							string sRELATED_TABLE_SINGULAR  = sRELATED_TABLE;
							if ( sRELATED_MODULE_SINGULAR.ToLower().EndsWith("ies") )
								sRELATED_MODULE_SINGULAR = sRELATED_MODULE_SINGULAR.Substring(0, sRELATED_MODULE_SINGULAR.Length-3) + "Y";
							else if ( sRELATED_MODULE_SINGULAR.ToLower().EndsWith("s") )
								sRELATED_MODULE_SINGULAR = sRELATED_MODULE_SINGULAR.Substring(0, sRELATED_MODULE_SINGULAR.Length-1);
							if ( sRELATED_TABLE_SINGULAR.ToLower().EndsWith("ies") )
								sRELATED_TABLE_SINGULAR = sRELATED_TABLE_SINGULAR.Substring(0, sRELATED_TABLE_SINGULAR.Length-3) + "Y";
							else if ( sRELATED_TABLE_SINGULAR.ToLower().EndsWith("s") )
								sRELATED_TABLE_SINGULAR = sRELATED_TABLE_SINGULAR.Substring(0, sRELATED_TABLE_SINGULAR.Length-1);

							foreach ( string sWebTemplate in arrWebTemplates )
							{
								if ( sWebTemplate.IndexOf("$relatedmodule$") < 0 && sWebTemplate.IndexOf("$relatedtable$") < 0 )
									continue;
								// 03/07/2010 Paul.  The code-behind files are not used so that the generated files will be immediately accessible. 
								// 08/25/2010 Paul.  We still want to allow code-behind files. 
								//if ( sWebTemplate.EndsWith(".cs") )
								//	continue;
								
								using ( StreamReader sr = new StreamReader(sWebTemplate, enc, true) )
								{
									string sData = sr.ReadToEnd();
									// 09/12/2009 Paul.  If this is an admin module, then place in the Administration namespace. 
									if ( bIS_ADMIN )
										sData = sData.Replace("SplendidCRM.$modulename$", "SplendidCRM.Administration.$modulename$");
									sData = sData.Replace("$modulename$"                 , sMODULE_NAME            );
									sData = sData.Replace("$modulenamesingular$"         , sMODULE_NAME_SINGULAR   );
									sData = sData.Replace("$tablename$"                  , sTABLE_NAME             );
									sData = sData.Replace("$tablenamesingular$"          , sTABLE_NAME_SINGULAR    );
									sData = sData.Replace("$relatedmodule$"              , sRELATED_MODULE         );
									sData = sData.Replace("$relatedmodulesingular$"      , sRELATED_MODULE_SINGULAR);
									sData = sData.Replace("$relatedtable$"               , sRELATED_TABLE          );
									sData = sData.Replace("$relatedtablesingular$"       , sRELATED_TABLE_SINGULAR );
									
									// 03/03/2011 Paul.  Project and ProjectTask need to be corrected. 
									if ( sWebTemplate.EndsWith("$relatedmodule$.ascx") )
									{
										if ( sRELATED_MODULE == "Project" )
										{
											sData = sData.Replace("~/Project/NewRecord.ascx", "~/Projects/NewRecord.ascx");
										}
										else if ( sRELATED_MODULE == "ProjectTask" )
										{
											sData = sData.Replace("~/ProjectTask/NewRecord.ascx", "~/ProjectTasks/NewRecord.ascx");
										}
									}
									if ( sWebTemplate.EndsWith("$relatedmodule$.ascx.cs") )
									{
										if ( sRELATED_MODULE == "Project" )
										{
											sData = sData.Replace("SplendidCRM.Project.NewRecord", "SplendidCRM.Projects.NewRecord");
										}
										else if ( sRELATED_MODULE == "ProjectTask" )
										{
											sData = sData.Replace("SplendidCRM.ProjectTask.NewRecord", "SplendidCRM.ProjectTasks.NewRecord");
										}
									}
									
									string sWebTemplateName = Path.GetFileName(sWebTemplate);
									sWebTemplateName = sWebTemplateName.Replace("$modulename$"           , sMODULE_NAME            );
									sWebTemplateName = sWebTemplateName.Replace("$modulenamesingular$"   , sMODULE_NAME_SINGULAR   );
									sWebTemplateName = sWebTemplateName.Replace("$tablename$"            , sTABLE_NAME             );
									sWebTemplateName = sWebTemplateName.Replace("$tablenamesingular$"    , sTABLE_NAME_SINGULAR    );
									sWebTemplateName = sWebTemplateName.Replace("$relatedmodule$"        , sRELATED_MODULE         );
									sWebTemplateName = sWebTemplateName.Replace("$relatedmodulesingular$", sRELATED_MODULE_SINGULAR);
									sWebTemplateName = sWebTemplateName.Replace("$relatedtable$"         , sRELATED_TABLE          );
									sWebTemplateName = sWebTemplateName.Replace("$relatedtablesingular$" , sRELATED_TABLE_SINGULAR );
									
									// 03/08/2010 Paul.  Allow user to select Live deployment, but we still prefer the code-behind method. 
									if ( !bCREATE_CODE_BEHIND )
									{
										// 03/06/2010 Paul.  Insert the SqlProc wrapper into each file as needed. 
										vwSQLScripts.RowFilter = "FOLDER = 'Procedures'";
										foreach ( DataRowView row in vwSQLScripts )
										{
											string sPROCEDURE_NAME = Sql.ToString(row["PROCEDURE_NAME"]);
											string sCODE_WRAPPER   = Sql.ToString(row["CODE_WRAPPER"  ]);
											if ( !Sql.IsEmptyString(sCODE_WRAPPER) )
											{
												if ( sData.IndexOf("SqlProcs." + sPROCEDURE_NAME) >= 0 )
												{
													sData = sData.Replace("//$sqlprocs$", sCODE_WRAPPER + ControlChars.CrLf + ControlChars.CrLf + "//$sqlprocs$");
												}
											}
										}
									}
									sData = sData.Replace("//$sqlprocs$", String.Empty);
									
									string sWebModuleFile = Path.Combine(sWebModulePath, sWebTemplateName);
									try
									{
										sbProgress.AppendLine(sWebModuleFile + "<br>");
										if ( bOVERWRITE_EXISTING && File.Exists(sWebModuleFile) )
											File.Delete(sWebModuleFile);
										using(StreamWriter stm = File.CreateText(sWebModuleFile))
										{
											stm.Write(sData);
										}
									}
									catch(Exception ex)
									{
										sbProgress.AppendLine("<font class=error>" + sWebTemplate + ":" + ex.Message + "</font><br>");
									}
								}
							}
						}
					}
				}
					// 03/08/2010 Paul.  Allow user to select Live deployment, but we still prefer the code-behind method. 
					// 11/25/2021 Paul.  REACT Only will live deploy. 
					if ( !bCREATE_CODE_BEHIND || bREACT_ONLY )
					{
						// 03/07/2010 Paul.  After a successful build, we need to reload the cached data. 
						SplendidInit.InitApp(HttpContext.Current);
						SplendidInit.LoadUserPreferences(Security.USER_ID, Sql.ToString(Session["USER_SETTINGS/THEME"]), Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
					}
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				lblProgress.Text = String.Empty;
				if ( e.CommandName == "Generate" )
				{
					string sDISPLAY_NAME             = DISPLAY_NAME.Text        ;
					string sMODULE_NAME              = MODULE_NAME.Text         ;
					string sTABLE_NAME               = TABLE_NAME.Text.ToUpper();
					bool   bTAB_ENABLED              = TAB_ENABLED             .Checked;
					bool   bMOBILE_ENABLED           = MOBILE_ENABLED          .Checked;
					bool   bCUSTOM_ENABLED           = CUSTOM_ENABLED          .Checked;
					bool   bREPORT_ENABLED           = REPORT_ENABLED          .Checked;
					bool   bIMPORT_ENABLED           = IMPORT_ENABLED          .Checked;
					// 09/12/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
					bool   bREST_ENABLED             = REST_ENABLED            .Checked;
					bool   bIS_ADMIN                 = IS_ADMIN                .Checked;
					bool   bINCLUDE_ASSIGNED_USER_ID = INCLUDE_ASSIGNED_USER_ID.Checked;
					bool   bINCLUDE_TEAM_ID          = INCLUDE_TEAM_ID         .Checked;
					bool   bOVERWRITE_EXISTING       = OVERWRITE_EXISTING      .Checked;
					bool   bCREATE_CODE_BEHIND       = CREATE_CODE_BEHIND      .Checked;
					
					List<string> lstRelationships = new List<string>();
					foreach ( ListItem chk in chkRelationships.Items )
					{
						if ( chk.Selected )
						{
							string sRELATED_MODULE          = chk.Value;
							lstRelationships.Add(sRELATED_MODULE);
						}
					}
					StringBuilder sbProgress = new StringBuilder();
					GenerateModule(Context, sDISPLAY_NAME, sMODULE_NAME, sTABLE_NAME, bTAB_ENABLED, bMOBILE_ENABLED, bCUSTOM_ENABLED, bREPORT_ENABLED, bIMPORT_ENABLED, bREST_ENABLED, bIS_ADMIN, bINCLUDE_ASSIGNED_USER_ID, bINCLUDE_TEAM_ID, bOVERWRITE_EXISTING, bCREATE_CODE_BEHIND, false, dtFields, lstRelationships, sbProgress);
					lblProgress.Text += sbProgress.ToString();
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblProgress.Text += "<font class=error>" + ex.Message + "</font>";
			}
		}

		#region Field Editing
		protected void grdMain_RowCreated(object sender, GridViewRowEventArgs e)
		{
			if ( e.Row.RowType == DataControlRowType.DataRow )
			{
			}
		}

		protected void grdMain_RowDataBound(object sender, GridViewRowEventArgs e)
		{
			if ( e.Row.RowType == DataControlRowType.DataRow )
			{
				// 03/05/2011 Paul.  We need to manually set the data type. 
				DropDownList lstDATA_TYPE = e.Row.FindControl("DATA_TYPE") as DropDownList;
				if ( lstDATA_TYPE != null )
				{
					try
					{
						Utils.SetValue(lstDATA_TYPE, Sql.ToString(DataBinder.Eval(e.Row.DataItem, "DATA_TYPE")) );
					}
					catch
					{
					}
				}
			}
		}

		protected void grdMain_RowEditing(object sender, GridViewEditEventArgs e)
		{
			// 02/07/2010 Paul.  Defensive programming, make sure that the fields table exists before using. 
			if ( dtFields != null )
			{
				DataRow[] aCurrentRows = dtFields.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				if ( e.NewEditIndex < aCurrentRows.Length )
				{
					DataRow row = aCurrentRows[e.NewEditIndex];
					string sFIELD_NAME = Sql.ToString(row["FIELD_NAME"]);
					// 09/16/2009 Paul.  DATE_MODIFIED_UTC is a new common field used to sync. 
					if (  sFIELD_NAME == "ID"              
					   || sFIELD_NAME == "DELETED"         
					   || sFIELD_NAME == "CREATED_BY"      
					   || sFIELD_NAME == "DATE_ENTERED"    
					   || sFIELD_NAME == "MODIFIED_USER_ID"
					   || sFIELD_NAME == "DATE_MODIFIED"   
					   || sFIELD_NAME == "DATE_MODIFIED_UTC"
					   )
					{
						lblError.Text = "This field cannot be edited.";
						return;
					}
				}
				grdMain.EditIndex = e.NewEditIndex;
				grdMain.DataSource = dtFields;
				grdMain.DataBind();
			}
		}

		protected void grdMain_RowDeleting(object sender, GridViewDeleteEventArgs e)
		{
			if ( dtFields != null )
			{
				//dtFields.Rows.RemoveAt(e.RowIndex);
				//dtFields.Rows[e.RowIndex].Delete();
				DataRow[] aCurrentRows = dtFields.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				if ( e.RowIndex < aCurrentRows.Length )
				{
					DataRow row = aCurrentRows[e.RowIndex];
					string sFIELD_NAME = Sql.ToString(row["FIELD_NAME"]);
					// 09/16/2009 Paul.  DATE_MODIFIED_UTC is a new common field used to sync. 
					if (  sFIELD_NAME == "ID"              
					   || sFIELD_NAME == "DELETED"         
					   || sFIELD_NAME == "CREATED_BY"      
					   || sFIELD_NAME == "DATE_ENTERED"    
					   || sFIELD_NAME == "MODIFIED_USER_ID"
					   || sFIELD_NAME == "DATE_MODIFIED"   
					   || sFIELD_NAME == "DATE_MODIFIED_UTC"
					   )
					{
						lblError.Text = "This field cannot be deleted.";
						return;
					}
				}
				aCurrentRows[e.RowIndex].Delete();
				
				aCurrentRows = dtFields.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				// 02/04/2007 Paul.  Always allow editing of the last empty row. Add blank row if necessary. 
				if ( aCurrentRows.Length == 0 || !Sql.IsEmptyString(aCurrentRows[aCurrentRows.Length-1]["FIELD_NAME"]) )
				{
					DataRow rowNew = dtFields.NewRow();
					dtFields.Rows.Add(rowNew);
					aCurrentRows = dtFields.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				}
				ViewState["Fields"] = dtFields;
				grdMain.DataSource = dtFields;
				// 03/15/2007 Paul.  Make sure to use the last row of the current set, not the total rows of the table.  Some rows may be deleted. 
				grdMain.EditIndex = aCurrentRows.Length - 1;
				grdMain.DataBind();
			}
		}

		protected void grdMain_RowUpdating(object sender, GridViewUpdateEventArgs e)
		{
			if ( dtFields != null )
			{
				GridViewRow gr = grdMain.Rows[e.RowIndex];
				TextBox      txtFIELD_NAME = gr.FindControl("FIELD_NAME") as TextBox;
				TextBox      txtEDIT_LABEL = gr.FindControl("EDIT_LABEL") as TextBox;
				TextBox      txtLIST_LABEL = gr.FindControl("LIST_LABEL") as TextBox;
				DropDownList lstDATA_TYPE  = gr.FindControl("DATA_TYPE" ) as DropDownList;
				TextBox      txtMAX_SIZE   = gr.FindControl("MAX_SIZE"  ) as TextBox;
				CheckBox     chkREQUIRED   = gr.FindControl("REQUIRED"  ) as CheckBox;

				DataRow row = dtFields.Rows[e.RowIndex];
				if ( txtFIELD_NAME != null ) row["FIELD_NAME"] = txtFIELD_NAME.Text;
				// 02/07/2010 Paul.  Defensive programming, was not validating txtEDIT_LABEL. 
				if ( txtEDIT_LABEL != null ) row["EDIT_LABEL"] = txtEDIT_LABEL.Text;
				if ( txtLIST_LABEL != null ) row["LIST_LABEL"] = txtLIST_LABEL.Text;
				if ( lstDATA_TYPE  != null ) row["DATA_TYPE" ] = lstDATA_TYPE.SelectedValue;
				if ( txtMAX_SIZE   != null ) row["MAX_SIZE"  ] = Sql.ToInteger(txtMAX_SIZE.Text);
				if ( chkREQUIRED   != null ) row["REQUIRED"  ] = chkREQUIRED.Checked ? 1 : 0;
				
				DataRow[] aCurrentRows = dtFields.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				// 03/30/2007 Paul.  Always allow editing of the last empty row. Add blank row if necessary. 
				if ( aCurrentRows.Length == 0 || !Sql.IsEmptyString(aCurrentRows[aCurrentRows.Length-1]["FIELD_NAME"]) )
				{
					DataRow rowNew = dtFields.NewRow();
					dtFields.Rows.Add(rowNew);
					aCurrentRows = dtFields.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				}

				ViewState["Fields"] = dtFields;
				grdMain.DataSource = dtFields;
				// 03/30/2007 Paul.  Make sure to use the last row of the current set, not the total rows of the table.  Some rows may be deleted. 
				grdMain.EditIndex = aCurrentRows.Length - 1;
				grdMain.DataBind();
			}
		}

		protected void grdMain_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
		{
			grdMain.EditIndex = -1;
			if ( dtFields != null )
			{
				DataRow[] aCurrentRows = dtFields.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				grdMain.DataSource = dtFields;
				// 03/15/2007 Paul.  Make sure to use the last row of the current set, not the total rows of the table.  Some rows may be deleted. 
				grdMain.EditIndex = aCurrentRows.Length - 1;
				grdMain.DataBind();
			}
		}
		#endregion

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			// 01/11/2006 Paul.  Only a developer/administrator should see this. 
			// 03/08/2010 Paul.  The Module Builder can now be run in production. 
			// 03/08/2010 Paul.  We now have a Web.config flag to disable the module builder. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible || Sql.ToBoolean(Utils.AppSettings["DisableModuleBuilder"]) ) // Request.ServerVariables["SERVER_NAME"] != "localhost" )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			// 10/18/2010 Paul.  The required fields need to be bound manually. 
			reqDISPLAY_NAME.DataBind();
			reqMODULE_NAME .DataBind();
			reqTABLE_NAME  .DataBind();
			if ( !IsPostBack )
			{
#if DEBUG
				// 03/08/2010 Paul.  Allow user to select Live deployment, but we still prefer the code-behind method. 
				CREATE_CODE_BEHIND.Checked = true;
#endif
				foreach ( DataControlField col in grdMain.Columns )
				{
					if ( !Sql.IsEmptyString(col.HeaderText) )
					{
						col.HeaderText = L10n.Term(col.HeaderText);
					}
					CommandField cf = col as CommandField;
					if ( cf != null )
					{
						cf.EditText   = L10n.Term(cf.EditText  );
						cf.DeleteText = L10n.Term(cf.DeleteText);
						cf.UpdateText = L10n.Term(cf.UpdateText);
						cf.CancelText = L10n.Term(cf.CancelText);
					}
				}

				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 08/15/2021 Paul.  Allow Users module to be related. 
					sSQL = "select MODULE_NAME       " + ControlChars.CrLf
					     + "     , DISPLAY_NAME      " + ControlChars.CrLf
					     + "  from vwMODULES         " + ControlChars.CrLf
					     + " where MODULE_ENABLED = 1" + ControlChars.CrLf
					     + "   and CUSTOM_ENABLED = 1" + ControlChars.CrLf
					     + "   and REPORT_ENABLED = 1" + ControlChars.CrLf
					     + "   and (IS_ADMIN       = 0 or MODULE_NAME = 'Users')" + ControlChars.CrLf
					     + " order by MODULE_NAME    " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							DataTable dtModules = new DataTable();
							da.Fill(dtModules);
							foreach(DataRow row in dtModules.Rows)
							{
								row["DISPLAY_NAME"] = L10n.Term(Sql.ToString(row["DISPLAY_NAME"]));
							}
							chkRelationships.DataSource = dtModules;
							chkRelationships.DataBind();
						}
					}
				}

				dtFields = new DataTable();
				DataColumn colFIELD_NAME = new DataColumn("FIELD_NAME", Type.GetType("System.String" ));
				DataColumn colEDIT_LABEL = new DataColumn("EDIT_LABEL", Type.GetType("System.String" ));
				DataColumn colLIST_LABEL = new DataColumn("LIST_LABEL", Type.GetType("System.String" ));
				DataColumn colDATA_TYPE  = new DataColumn("DATA_TYPE" , Type.GetType("System.String" ));
				DataColumn colMAX_SIZE   = new DataColumn("MAX_SIZE"  , Type.GetType("System.Int32"  ));
				DataColumn colREQUIRED   = new DataColumn("REQUIRED"  , Type.GetType("System.Boolean"));
				dtFields.Columns.Add(colFIELD_NAME);
				dtFields.Columns.Add(colEDIT_LABEL);
				dtFields.Columns.Add(colLIST_LABEL);
				dtFields.Columns.Add(colDATA_TYPE );
				dtFields.Columns.Add(colMAX_SIZE  );
				dtFields.Columns.Add(colREQUIRED  );
				
				DataRow rowID               = dtFields.NewRow();
				DataRow rowDELETED          = dtFields.NewRow();
				DataRow rowCREATED_BY       = dtFields.NewRow();
				DataRow rowDATE_ENTERED     = dtFields.NewRow();
				DataRow rowMODIFIED_USER_ID = dtFields.NewRow();
				DataRow rowDATE_MODIFIED    = dtFields.NewRow();
				// 11/20/2021 Paul.  Add DATE_MODIFIED_UTC. 
				DataRow rowDATE_MODIFIED_UTC= dtFields.NewRow();
				DataRow rowNAME             = dtFields.NewRow();
				rowID              ["FIELD_NAME"] = "ID"                                   ;
				rowID              ["DATA_TYPE" ] = "Guid"                                 ;
				rowID              ["REQUIRED"  ] = true                                   ;
				rowID              ["EDIT_LABEL"] = L10n.Term(".LBL_ID"     )              ;
				rowID              ["LIST_LABEL"] = L10n.Term(".LBL_LIST_ID")              ;

				rowDELETED         ["FIELD_NAME"] = "DELETED"                              ;
				rowDELETED         ["DATA_TYPE" ] = "Checkbox"                             ;
				rowDELETED         ["REQUIRED"  ] = true                                   ;
				rowDELETED         ["EDIT_LABEL"] = L10n.Term(".LBL_DELETED"     )         ;
				rowDELETED         ["LIST_LABEL"] = L10n.Term(".LBL_LIST_DELETED")         ;

				rowCREATED_BY      ["FIELD_NAME"] = "CREATED_BY"                           ;
				rowCREATED_BY      ["DATA_TYPE" ] = "Guid"                                 ;
				rowCREATED_BY      ["REQUIRED"  ] = false                                  ;
				rowCREATED_BY      ["EDIT_LABEL"] = L10n.Term(".LBL_CREATED_BY"     )      ;
				rowCREATED_BY      ["LIST_LABEL"] = L10n.Term(".LBL_LIST_CREATED_BY")      ;

				rowDATE_ENTERED    ["FIELD_NAME"] = "DATE_ENTERED"                         ;
				rowDATE_ENTERED    ["DATA_TYPE" ] = "Date"                                 ;
				rowDATE_ENTERED    ["REQUIRED"  ] = true                                   ;
				rowDATE_ENTERED    ["EDIT_LABEL"] = L10n.Term(".LBL_DATE_ENTERED"     )    ;
				rowDATE_ENTERED    ["LIST_LABEL"] = L10n.Term(".LBL_LIST_DATE_ENTERED")    ;

				rowMODIFIED_USER_ID["FIELD_NAME"] = "MODIFIED_USER_ID"                     ;
				rowMODIFIED_USER_ID["DATA_TYPE" ] = "Guid"                                 ;
				rowMODIFIED_USER_ID["REQUIRED"  ] = false                                  ;
				rowMODIFIED_USER_ID["EDIT_LABEL"] = L10n.Term(".LBL_MODIFIED_USER_ID"     );
				rowMODIFIED_USER_ID["LIST_LABEL"] = L10n.Term(".LBL_LIST_MODIFIED_USER_ID");

				rowDATE_MODIFIED   ["FIELD_NAME"] = "DATE_MODIFIED"                        ;
				rowDATE_MODIFIED   ["DATA_TYPE" ] = "Date"                                 ;
				rowDATE_MODIFIED   ["REQUIRED"  ] = true                                   ;
				rowDATE_MODIFIED   ["EDIT_LABEL"] = L10n.Term(".LBL_DATE_MODIFIED"     )   ;
				rowDATE_MODIFIED   ["LIST_LABEL"] = L10n.Term(".LBL_LIST_DATE_MODIFIED")   ;

				// 11/20/2021 Paul.  Add DATE_MODIFIED_UTC. 
				rowDATE_MODIFIED_UTC["FIELD_NAME"] = "DATE_MODIFIED_UTC"                    ;
				rowDATE_MODIFIED_UTC["DATA_TYPE" ] = "Date"                                 ;
				rowDATE_MODIFIED_UTC["REQUIRED"  ] = true                                   ;
				rowDATE_MODIFIED_UTC["EDIT_LABEL"] = L10n.Term(".LBL_DATE_MODIFIED_UTC"     );
				rowDATE_MODIFIED_UTC["LIST_LABEL"] = L10n.Term(".LBL_LIST_DATE_MODIFIED_UTC");

				rowNAME            ["FIELD_NAME"] = "NAME"                                 ;
				rowNAME            ["DATA_TYPE" ] = "Text"                                 ;
				rowNAME            ["REQUIRED"  ] = true                                   ;
				rowNAME            ["EDIT_LABEL"] = L10n.Term("Name:")                     ;
				rowNAME            ["LIST_LABEL"] = L10n.Term("Name" )                     ;
				rowNAME            ["MAX_SIZE"  ] = 150                                    ;

				dtFields.Rows.Add(rowID              );
				dtFields.Rows.Add(rowDELETED         );
				dtFields.Rows.Add(rowCREATED_BY      );
				dtFields.Rows.Add(rowDATE_ENTERED    );
				dtFields.Rows.Add(rowMODIFIED_USER_ID);
				dtFields.Rows.Add(rowDATE_MODIFIED   );
				// 11/20/2021 Paul.  Add DATE_MODIFIED_UTC. 
				dtFields.Rows.Add(rowDATE_MODIFIED_UTC);
				dtFields.Rows.Add(rowNAME            );

				// 03/27/2007 Paul.  Always add blank line to allow quick editing. 
				DataRow rowNew = dtFields.NewRow();
				dtFields.Rows.Add(rowNew);

				ViewState["Fields"] = dtFields;
				grdMain.DataSource = dtFields;
				// 02/03/2007 Paul.  Start with last line enabled for editing. 
				grdMain.EditIndex = dtFields.Rows.Count - 1;
				grdMain.DataBind();
			}
			else
			{
				dtFields = ViewState["Fields"] as DataTable;
				grdMain.DataSource = dtFields;
				// 03/31/2007 Paul.  Don't bind the grid, otherwise edits will be lost. 
				//grdMain.DataBind();
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
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			m_sMODULE = "ModuleBuilder";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

