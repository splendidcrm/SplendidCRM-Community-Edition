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
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Workflow.Activities.Rules;
using System.Diagnostics;

namespace SplendidCRM.RulesWizard
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		public const int nMAX_ERRORS = 200;
		
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected Reports.QueryBuilder     ctlQueryBuilder  ;
		protected _controls.TeamSelect     ctlTeamSelect    ;
		// 10/24/2010 Paul.  MultiView did not work well because it did not fire the PreRender if the particular view was not active.
		// This was a problem with the QueryBuilder as we expect it to always fire to save the RDL to the ViewState.
		protected HtmlInputHidden txtACTIVE_TAB         ;

		protected Guid            gID                   ;
		protected UniqueStringCollection arrSelectFields;
		protected string          sWizardModule         ;
		protected DataView        vwMain                ;
		protected SplendidGrid    grdMain               ;
		protected DataView        vwResults             ;
		protected SplendidGrid    grdResults            ;
		protected HiddenField     hidCURRENT_MODULE     ;
		protected DropDownList    lstMODULE             ;
		protected TextBox         txtNAME               ;
		protected TextBox         txtASSIGNED_TO        ;
		protected HtmlInputHidden txtASSIGNED_USER_ID   ;
		protected TextBox         TEAM_NAME             ;
		protected HiddenField     TEAM_ID               ;
		protected CheckBox        chkUseTransaction     ;
		protected Label           lblStatus             ;
		protected Label           lblSuccessCount       ;
		protected Label           lblFailedCount        ;
		protected RequiredFieldValidator reqNAME;

		protected DataTable       dtRules               ;
		protected DataGrid        dgRules               ;
		protected HiddenField     txtRULE_ID            ;
		protected TextBox         txtRULE_NAME          ;
		protected TextBox         txtPRIORITY           ;
		protected DropDownList    lstREEVALUATION       ;
		protected CheckBox        chkACTIVE             ;
		protected TextBox         txtCONDITION          ;
		protected TextBox         txtTHEN_ACTIONS       ;
		protected TextBox         txtELSE_ACTIONS       ;
		protected RequiredFieldValidator reqRULE_NAME   ;
		protected RequiredFieldValidator reqCONDITION   ;
		protected RequiredFieldValidator reqTHEN_ACTIONS;

		protected DataTable       dtRuleColumns  ;
		protected Repeater        ctlConditionSchemaRepeater;
		protected Repeater        ctlThenSchemaRepeater;
		protected Repeater        ctlElseSchemaRepeater;

		protected void ResetRuleText()
		{
			txtRULE_ID     .Value         = String.Empty;
			txtRULE_NAME   .Text          = String.Empty;
			txtPRIORITY    .Text          = "0";
			lstREEVALUATION.SelectedIndex = 0;
			chkACTIVE      .Checked       = true;
			txtCONDITION   .Text          = String.Empty;
			txtTHEN_ACTIONS.Text          = String.Empty;
			txtELSE_ACTIONS.Text          = String.Empty;
		}

		#region Filter Editing
		protected void RulesGet(Guid gID, ref string sRULE_NAME, ref int nPRIORITY, ref string sREEVALUATION, ref bool bACTIVE, ref string sCONDITION, ref string sTHEN_ACTIONS, ref string sELSE_ACTIONS)
		{
			DataView vwRules = new DataView(dtRules);
			vwRules.RowFilter = "ID = '" + gID.ToString() + "'";
			if ( vwRules.Count > 0 )
			{
				sRULE_NAME    = Sql.ToString (vwRules[0]["RULE_NAME"   ]);
				nPRIORITY     = Sql.ToInteger(vwRules[0]["PRIORITY"    ]);
				sREEVALUATION = Sql.ToString (vwRules[0]["REEVALUATION"]);
				bACTIVE       = Sql.ToBoolean(vwRules[0]["ACTIVE"      ]);
				sCONDITION    = Sql.ToString (vwRules[0]["CONDITION"   ]);
				sTHEN_ACTIONS = Sql.ToString (vwRules[0]["THEN_ACTIONS"]);
				sELSE_ACTIONS = Sql.ToString (vwRules[0]["ELSE_ACTIONS"]);
			}
		}

		protected void RulesUpdate(Guid gID, string sRULE_NAME, int nPRIORITY, string sREEVALUATION, bool bACTIVE, string sCONDITION, string sTHEN_ACTIONS, string sELSE_ACTIONS)
		{
			DataView vwRules = new DataView(dtRules);
			vwRules.RowFilter = "ID = '" + gID.ToString() + "'";
			try
			{
				if ( vwRules.Count > 0 )
				{
					vwRules[0]["RULE_NAME"   ] = sRULE_NAME   ;
					vwRules[0]["PRIORITY"    ] = nPRIORITY    ;
					vwRules[0]["REEVALUATION"] = sREEVALUATION;
					vwRules[0]["ACTIVE"      ] = bACTIVE      ;
					vwRules[0]["CONDITION"   ] = sCONDITION   ;
					vwRules[0]["THEN_ACTIONS"] = sTHEN_ACTIONS;
					vwRules[0]["ELSE_ACTIONS"] = sELSE_ACTIONS;
				}
				else
				{
					DataRow row = dtRules.NewRow();
					dtRules.Rows.Add(row);
					row["ID"          ] = Guid.NewGuid();
					row["RULE_NAME"   ] = sRULE_NAME   ;
					row["PRIORITY"    ] = nPRIORITY    ;
					row["REEVALUATION"] = sREEVALUATION;
					row["ACTIVE"      ] = bACTIVE      ;
					row["CONDITION"   ] = sCONDITION   ;
					row["THEN_ACTIONS"] = sTHEN_ACTIONS;
					row["ELSE_ACTIONS"] = sELSE_ACTIONS;
				}
				dgRules.DataSource = dtRules;
				dgRules.DataBind();
			}
			catch(Exception ex)
			{
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		protected void RulesDelete(Guid gID)
		{
			dgRules.EditItemIndex = -1;
			for ( int i = 0; i < dtRules.Rows.Count; i++ )
			{
				DataRow row = dtRules.Rows[i];
				if ( gID == Sql.ToGuid(row["ID"]) )
				{
					row.Delete();
					break;
				}
			}
			dtRules.AcceptChanges();
			dgRules.DataSource = dtRules;
			dgRules.DataBind();
		}
		#endregion

		protected void BindMain(bool bBind)
		{
			if ( Crm.Config.allow_custom_paging() && Crm.Modules.CustomPaging(sWizardModule) )
			{
				grdMain.AllowCustomPaging = true;
				grdMain.SelectMethod     += new SelectMethodHandler(grdMain_OnSelectMethod);
			}

			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					// 10/23/2010 Paul.  We can't use OrderByClause as we are likely in a postback. 
					//grdMain.OrderByClause("NAME", "asc");
					if ( bBind )
					{
						grdMain.SortColumn = "NAME";
						grdMain.SortOrder  = "asc" ;
					}

					
					string sTABLE_NAME = Crm.Modules.TableName(sWizardModule);
					cmd.CommandText = "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf;
					Security.Filter(cmd, sWizardModule, "list");
					if ( !Sql.IsEmptyString(ctlQueryBuilder.ReportSQL) )
					{
						cmd.CommandText += "   and ID in " + ControlChars.CrLf 
						                + "(" + ctlQueryBuilder.ReportSQL + ")" + ControlChars.CrLf;
					}
					if ( grdMain.AllowCustomPaging )
					{
						cmd.CommandText = "select count(*)" + ControlChars.CrLf
						                + cmd.CommandText;
						
						if ( bDebug && bBind )
							RegisterClientScriptBlock("SQLCodeMain", Sql.ClientScriptBlock(cmd));
						
						if ( IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(sWizardModule) )
						{
							grdMain.VirtualItemCount = Sql.ToInteger(cmd.ExecuteScalar());
							ViewState["ShowMainPreview"] = true;
						}
					}
					else
					{
						cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
						                + cmd.CommandText
						                + grdMain.OrderByClause();
						
						if ( bDebug && bBind )
							RegisterClientScriptBlock("SQLCodeMain", Sql.ClientScriptBlock(cmd));
						
						if ( IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(sWizardModule) )
						{
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									vwMain = dt.DefaultView;
									grdMain.DataSource = vwMain ;
									if ( bBind )
										grdMain.DataBind();
									ViewState["ShowMainPreview"] = true;
								}
							}
						}
					}
				}
			}
		}

		protected void lstMODULE_Changed(Object sender, EventArgs e)
		{
			sWizardModule = lstMODULE.SelectedValue;
			hidCURRENT_MODULE.Value = sWizardModule;
			
			// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
			ctlDynamicButtons.Title = L10n.Term(".moduleList." + sWizardModule);
			string sMODULE_TABLE = Sql.ToString(Application["Modules." + sWizardModule + ".TableName"]);
			// 05/24/2011 Paul.  Use the view so that custom fields will be included. 
			dtRuleColumns = SplendidCache.SqlColumns("vw" + sMODULE_TABLE + "_List").Copy();
			/*
			foreach(DataRow row in dtRuleColumns.Rows)
			{
				row["ColumnName"] = Utils.TableColumnName(L10n, sWizardModule, Sql.ToString(row["ColumnName"]));
			}
			*/
			ViewState["RULE_COLUMNS"] = dtRuleColumns;
			ctlConditionSchemaRepeater.DataSource = dtRuleColumns;
			ctlThenSchemaRepeater     .DataSource = dtRuleColumns;
			ctlElseSchemaRepeater     .DataSource = dtRuleColumns;
			ctlConditionSchemaRepeater.DataBind();
			ctlThenSchemaRepeater     .DataBind();
			ctlElseSchemaRepeater     .DataBind();
			
			ctlQueryBuilder.Modules = sWizardModule;
			ctlQueryBuilder.LoadRdl(String.Empty);
		}

		// 05/17/2021 Paul.  Convert SubmitRules to static function so that it can be called by React client. 
		public static void SubmitRules(HttpContext Context, SplendidControl Container, L10N L10n, IDbConnection con, string sMODULE_NAME, RuleSet rules, RuleValidation validation, DataTable dtData, bool bUseTransaction, ref int nSuccessCount, ref int nFailedCount, ref string sStatus)
		{
			int nFailed     = 0;
			int nRowNumber  = 0;
			IDbTransaction trn = null;
			try
			{
				string sTABLE_NAME = Sql.ToString(Context.Application["Modules." + sMODULE_NAME + ".TableName"]);
				if ( Sql.IsEmptyString(sTABLE_NAME) )
					sTABLE_NAME = sMODULE_NAME.ToUpper();
				
				IDbCommand cmdImport = null;
				cmdImport = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update");

				DataTable dtColumns = new DataTable();
				dtColumns.Columns.Add("ColumnName"  , Type.GetType("System.String"));
				dtColumns.Columns.Add("NAME"        , Type.GetType("System.String"));
				dtColumns.Columns.Add("DISPLAY_NAME", Type.GetType("System.String"));
				dtColumns.Columns.Add("ColumnType"  , Type.GetType("System.String"));
				dtColumns.Columns.Add("Size"        , Type.GetType("System.Int32" ));
				dtColumns.Columns.Add("Scale"       , Type.GetType("System.Int32" ));
				dtColumns.Columns.Add("Precision"   , Type.GetType("System.Int32" ));
				dtColumns.Columns.Add("colid"       , Type.GetType("System.Int32" ));
				dtColumns.Columns.Add("CustomField" , Type.GetType("System.Boolean"));
				for ( int i =0; i < cmdImport.Parameters.Count; i++ )
				{
					IDbDataParameter par = cmdImport.Parameters[i] as IDbDataParameter;
					DataRow row = dtColumns.NewRow();
					dtColumns.Rows.Add(row);
					row["ColumnName"  ] = par.ParameterName;
					row["NAME"        ] = Sql.ExtractDbName(cmdImport, par.ParameterName);
					row["DISPLAY_NAME"] = row["NAME"];
					row["ColumnType"  ] = par.DbType.ToString();
					row["Size"        ] = par.Size         ;
					row["Scale"       ] = par.Scale        ;
					row["Precision"   ] = par.Precision    ;
					row["colid"       ] = i                ;
					row["CustomField" ] = false            ;
				}
				string sSQL;
				sSQL = "select *                       " + ControlChars.CrLf
				     + "  from vwSqlColumns            " + ControlChars.CrLf
				     + " where ObjectName = @OBJECTNAME" + ControlChars.CrLf
				     + "   and ColumnName <> 'ID_C'    " + ControlChars.CrLf
				     + " order by colid                " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, sTABLE_NAME + "_CSTM"));
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						DataTable dtCSTM = new DataTable();
						da.Fill(dtCSTM);
						foreach ( DataRow rowCSTM in dtCSTM.Rows )
						{
							DataRow row = dtColumns.NewRow();
							row["ColumnName"  ] = Sql.ToString (rowCSTM["ColumnName"]);
							row["NAME"        ] = Sql.ToString (rowCSTM["ColumnName"]);
							row["DISPLAY_NAME"] = Sql.ToString (rowCSTM["ColumnName"]);
							row["ColumnType"  ] = Sql.ToString (rowCSTM["CsType"    ]);
							row["Size"        ] = Sql.ToInteger(rowCSTM["length"    ]);
							row["colid"       ] = dtColumns.Rows.Count;
							row["CustomField" ] = true;
							dtColumns.Rows.Add(row);
						}
					}
				}
				DataView vwColumns = new DataView(dtColumns);
				IDbCommand cmdImportCSTM = null;
				vwColumns.RowFilter = "CustomField = 1";
				if ( vwColumns.Count > 0 )
				{
					vwColumns.Sort = "colid";
					cmdImportCSTM = con.CreateCommand();
					cmdImportCSTM.CommandType = CommandType.Text;
					cmdImportCSTM.CommandText = "update " + sTABLE_NAME + "_CSTM" + ControlChars.CrLf;
					int nFieldIndex = 0;
					foreach ( DataRowView row in vwColumns )
					{
						string sNAME   = Sql.ToString(row["ColumnName"]).ToUpper();
						string sCsType = Sql.ToString(row["ColumnType"]);
						int    nMAX_SIZE = Sql.ToInteger(row["Size"]);
						if ( nFieldIndex == 0 )
							cmdImportCSTM.CommandText += "   set ";
						else
							cmdImportCSTM.CommandText += "     , ";
						cmdImportCSTM.CommandText += sNAME + " = @" + sNAME + ControlChars.CrLf;
						
						IDbDataParameter par = null;
						switch ( sCsType )
						{
							case "Guid"    :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, Guid.Empty             );  break;
							case "short"   :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, 0                      );  break;
							case "Int32"   :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, 0                      );  break;
							case "Int64"   :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, 0                      );  break;
							case "float"   :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, 0.0f                   );  break;
							case "decimal" :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, new Decimal()          );  break;
							case "bool"    :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, false                  );  break;
							case "DateTime":  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, DateTime.MinValue      );  break;
							default        :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, String.Empty, nMAX_SIZE);  break;
						}
						nFieldIndex++;
					}
					cmdImportCSTM.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
					Sql.AddParameter(cmdImportCSTM, "@ID_C", Guid.Empty);
					// 01/16/2011 Paul.  Not sure what this execute was for.  Seems to be a cut-and-paste bug. 
					//cmdImportCSTM.ExecuteNonQuery();
				}
				vwColumns.RowFilter = "";
				if ( bUseTransaction )
				{
					trn = Sql.BeginTransaction(con);
					cmdImport.Transaction = trn;
					if ( cmdImportCSTM != null )
						cmdImportCSTM.Transaction = trn;
				}
				
				foreach ( DataRow row in dtData.Rows )
				{
					// 04/27/2018 Paul.  We need to be able to generate an error message. 
					SplendidWizardThis swThis = new SplendidWizardThis(Container, L10n, sMODULE_NAME, row);
					RuleExecution exec = new RuleExecution(validation, swThis);
					rules.Execute(exec);
					if ( !Sql.IsEmptyString(swThis.ErrorMessage) )
						throw(new Exception(swThis.ErrorMessage));
					nRowNumber++;
					row["IMPORT_ROW_NUMBER"] = nRowNumber ;
					
					Guid gID = Sql.ToGuid(row["ID"]);
					try
					{
						if ( !Context.Response.IsClientConnected )
						{
							break;
						}
						foreach(IDbDataParameter par in cmdImport.Parameters)
						{
							par.Value = DBNull.Value;
						}
						if ( cmdImportCSTM != null )
						{
							foreach(IDbDataParameter par in cmdImportCSTM.Parameters)
							{
								par.Value = DBNull.Value;
							}
						}
						Sql.SetParameter(cmdImport, "@MODIFIED_USER_ID", Security.USER_ID);
						foreach ( DataColumn col in dtData.Columns )
						{
							string sName = col.ColumnName;
							if (  sName == "IMPORT_ROW_STATUS"  
							   || sName == "IMPORT_ROW_NUMBER"  
							   || sName == "IMPORT_ROW_ERROR"   
							   || sName == "IMPORT_LAST_COLUMN" 
							   )
								continue;
							row["IMPORT_ROW_STATUS" ] = true ;
							row["IMPORT_LAST_COLUMN"] = sName;
							IDbDataParameter par = Sql.FindParameter(cmdImport, sName);
							if ( par != null )
							{
								par.Value = row[col.ColumnName];
							}
							else if ( cmdImportCSTM != null )
							{
								par = Sql.FindParameter(cmdImportCSTM, sName);
								if ( par != null )
								{
									par.Value = row[col.ColumnName];
								}
							}
						}
						cmdImport.ExecuteNonQuery();
						if ( cmdImportCSTM != null )
						{
							Sql.SetParameter(cmdImportCSTM, "ID_C", gID);
							cmdImportCSTM.ExecuteNonQuery();
						}
						row["IMPORT_LAST_COLUMN"] = DBNull.Value;
					}
					catch(Exception ex)
					{
						row["IMPORT_ROW_STATUS"] = false;
						row["IMPORT_ROW_ERROR" ] = L10n.Term("RulesWizard.LBL_ERROR") + " " + Sql.ToString(row["IMPORT_LAST_COLUMN"]) + ". " + ex.Message;
						nFailed++;
						// 10/31/2006 Paul.  Abort after 200 errors. 
						if ( nFailed >= nMAX_ERRORS )
						{
							//ctlDynamicButtons.ErrorText += L10n.Term("RulesWizard.LBL_MAX_ERRORS");
							break;
						}
					}
				}
				if ( trn != null )
				{
					trn.Commit();
				}
			}
			finally
			{
				if ( trn != null )
					trn.Dispose();
			}
			if ( nFailed == 0 )
				sStatus = L10n.Term("Import.LBL_SUCCESS");
			else if ( nFailed >= nMAX_ERRORS )
				sStatus = L10n.Term("RulesWizard.LBL_MAX_ERRORS");
			else
				sStatus = L10n.Term("Import.LBL_FAIL");
			nSuccessCount = nRowNumber;
			nFailedCount  = nFailed   ;
		}

		// 01/22/2015 Paul.  We need to provide navigation of results. 
		protected void BindResults(bool bPreview)
		{
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
					using ( DataTable dt = new DataTable() )
					{
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							string sTABLE_NAME = Crm.Modules.TableName(sWizardModule);
							cmd.CommandText = "select *" + ControlChars.CrLf
							                + "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf;
							Security.Filter(cmd, sWizardModule, "list");
							if ( !Sql.IsEmptyString(ctlQueryBuilder.ReportSQL) )
							{
								cmd.CommandText += "   and ID in " + ControlChars.CrLf
								                + "(" + ctlQueryBuilder.ReportSQL + ")" + ControlChars.CrLf;
							}
							// 01/22/2015 Paul.  Fix the sort to use the grdResults value.  We cannot sort on the special columns. 
							if ( grdResults.SortColumn == "IMPORT_ROW_STATUS" || grdResults.SortColumn == "IMPORT_ROW_NUMBER" || grdResults.SortColumn == "IMPORT_ROW_ERROR" || grdResults.SortColumn == "IMPORT_LAST_COLUMN" )
								cmd.CommandText += "order by NAME asc";
							else
								cmd.CommandText += grdResults.OrderByClause();
							
							if ( bDebug )
								RegisterClientScriptBlock("SQLCodeResults", Sql.ClientScriptBlock(cmd));
							
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
							ViewState["ShowResultsPreview"] = true;
							int nRowNumber = 0;
							int nFailed    = 0;
							foreach ( DataRow row in dt.Rows )
							{
								// 01/22/2015 Paul.  Move the catch inside the loop so that we can see all the errors. 
								try
								{
									row["IMPORT_ROW_NUMBER"] = nRowNumber;
									// 04/27/2018 Paul.  We need to be able to generate an error message. 
									SplendidWizardThis swThis = new SplendidWizardThis(this, L10n, sWizardModule, row);
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
									lblSuccessCount.Text = String.Format(L10n.Term("RulesWizard.LBL_SUCCESSFULLY" ), nRowNumber);
									lblFailedCount .Text = String.Format(L10n.Term("RulesWizard.LBL_FAILED_IMPORT"), nFailed   );
								}
							}
							if ( nFailed > 0 )
								lblStatus.Text = L10n.Term("Import.LBL_FAIL");
							else
								lblStatus.Text = L10n.Term("Import.LBL_SUCCESS");
							lblSuccessCount.Text = String.Format(L10n.Term("RulesWizard.LBL_SUCCESSFULLY" ), nRowNumber);
							lblFailedCount .Text = String.Format(L10n.Term("RulesWizard.LBL_FAILED_IMPORT"), nFailed   );
						}
						else
						{
							ViewState["ShowResultsPreview"] = false;
							// 11/29/2010 Paul.  Make sure to check the access rights before applying the rules. 
							if ( SplendidCRM.Security.GetUserAccess(sWizardModule, "edit") >= 0 )
							{
								// 05/17/2021 Paul.  Convert SubmitRules to static function so that it can be called by React client. 
								int    nRowNumber = 0;
								int    nFailed    = 0;
								string sStatus    = String.Empty;
								SubmitRules(HttpContext.Current, this, L10n, con, sWizardModule, rules, validation, dt, chkUseTransaction.Checked, ref nRowNumber, ref nFailed, ref sStatus);
								lblSuccessCount.Text = String.Format(L10n.Term("RulesWizard.LBL_SUCCESSFULLY" ), nRowNumber);
								lblFailedCount .Text = String.Format(L10n.Term("RulesWizard.LBL_FAILED_IMPORT"), nFailed   );
								lblStatus.Text = sStatus;
								if ( nFailed > nMAX_ERRORS )
								{
									ctlDynamicButtons.ErrorText = sStatus;
									lblStatus.Text = L10n.Term("Import.LBL_FAIL");
								}
							}
						}
						vwResults = new DataView(dt);
						// 01/22/2015 Paul.  Here is where we sort by special columns. 
						if ( grdResults.SortColumn == "IMPORT_ROW_STATUS" || grdResults.SortColumn == "IMPORT_ROW_NUMBER" || grdResults.SortColumn == "IMPORT_ROW_ERROR" || grdResults.SortColumn == "IMPORT_LAST_COLUMN" )
							vwResults.Sort = grdResults.SortColumn + " " + grdResults.SortOrder;
						grdResults.DataSource = vwResults;
						grdResults.DataBind();
					}
				}
			}
			catch(Exception ex)
			{
				ctlDynamicButtons.ErrorText = ex.Message + ControlChars.CrLf + RulesUtil.GetValidationErrors(validation);
			}
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				// 01/22/2015 Paul.  New event when query builder is loaded. 
				if ( e.CommandName == "QueryBuilder.Loaded" )
				{
					// 01/22/2015 Paul.  Move data binding until after query builder is loaded. 
					if ( txtACTIVE_TAB.Value == "2" && Sql.ToBoolean(ViewState["ShowMainPreview"]) )
					{
						BindMain(false);
					}
					// 01/22/2015 Paul.  We need to provide navigation of results. 
					else if ( txtACTIVE_TAB.Value == "4" && Sql.ToBoolean(ViewState["ShowResultsPreview"]) )
					{
						BindResults(true);
					}
					return;
				}
				ViewState["ShowMainPreview"] = false;
				// 01/22/2015 Paul.  We need to provide navigation of results. 
				ViewState["ShowResultsPreview"] = false;
				grdMain.CurrentPageIndex = 0;
				grdMain.DataSource = null;
				grdMain.DataBind();
				grdResults.CurrentPageIndex = 0;
				grdResults.DataSource = null;
				grdResults.DataBind();
				if ( e.CommandName == "Save" )
				{
					bool bIsValid = Page.IsValid;
					if ( bIsValid )
					{
						reqNAME.Enabled = true;
						reqNAME.Validate();
						if ( !reqNAME.IsValid )
						{
							txtACTIVE_TAB.Value = "1";
							bIsValid = false;
						}
						else if ( dtRules.Rows.Count == 0 )
						{
							ctlDynamicButtons.ErrorText = L10n.Term("Rules.ERR_NO_RULES");
							txtACTIVE_TAB.Value = "3";
							bIsValid = false;
						}
					}
					if ( bIsValid )
					{
						// 12/12/2012 Paul.  For security reasons, we want to restrict the data types available to the rules wizard. 
						SplendidRulesTypeProvider typeProvider = new SplendidRulesTypeProvider();
						RuleValidation validation = new RuleValidation(typeof(SplendidWizardThis), typeProvider);
						RuleSet rules = RulesUtil.BuildRuleSet(dtRules, validation);
						
						string sXOML = RulesUtil.Serialize(rules);
						StringBuilder sbRulesXML = new StringBuilder();
						using ( StringWriter wtr = new StringWriter(sbRulesXML, System.Globalization.CultureInfo.InvariantCulture) )
						{
							dtRules.WriteXml(wtr, XmlWriteMode.WriteSchema, false);
						}
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
										Guid gTEAM_ID = Guid.Empty;
										if ( SplendidCRM.Crm.Config.enable_dynamic_teams() )
											gTEAM_ID = ctlTeamSelect.TEAM_ID;
										else
											gTEAM_ID = Sql.ToGuid(TEAM_ID.Value);
										SqlProcs.spRULES_Update
											( ref gID
											, Sql.ToGuid(txtASSIGNED_USER_ID.Value)
											, txtNAME.Text
											, lstMODULE.SelectedValue
											, "Wizard"
											, String.Empty
											, ctlQueryBuilder.ReportSQL
											, ctlQueryBuilder.ReportRDL
											, sbRulesXML.ToString()
											, sXOML
											, gTEAM_ID
											, ctlTeamSelect.TEAM_SET_LIST
											, String.Empty  // 05/25/2021 Paul.  TAG_SET_NAME. 
											, trn
											);
										// 08/26/2010 Paul.  Add new record to tracker. 
										// 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
										SqlProcs.spTRACKER_Update
											( Security.USER_ID
											, m_sMODULE
											, gID
											, txtNAME.Text
											, "save"
											, trn
											);
										trn.Commit();
									}
									catch(Exception ex)
									{
										trn.Rollback();
										SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
										ctlDynamicButtons.ErrorText = ex.Message;
										return;
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							ctlDynamicButtons.ErrorText = ex.Message;
							return;
						}
						Response.Redirect("default.aspx");
					}
				}
				else if ( e.CommandName == "Filter.Preview" )
				{
					txtACTIVE_TAB.Value = "2";
					BindMain(true);
				}
				else if ( e.CommandName == "Rules.Preview" || e.CommandName == "Rules.Submit" )
				{
					txtACTIVE_TAB.Value = "4";
					
					grdResults.SortColumn = "NAME";
					grdResults.SortOrder  = "asc";
					// 01/22/2015 Paul.  We need to provide navigation of results. 
					bool bPreview = e.CommandName == "Rules.Preview";
					BindResults(bPreview);
				}
				else if ( e.CommandName == "Rules.Cancel" )
				{
					ResetRuleText();
				}
				else if ( e.CommandName == "Rules.Add" )
				{
					ResetRuleText();
				}
				else if ( e.CommandName == "Rules.Delete" )
				{
					RulesDelete(Sql.ToGuid(e.CommandArgument));
					ResetRuleText();
				}
				else if ( e.CommandName == "Rules.Edit" )
				{
					Guid   gRULE_ID = Sql.ToGuid(e.CommandArgument);
					string sRULE_NAME    = String.Empty;
					int    nPRIORITY     = 0           ;
					string sREEVALUATION = String.Empty;
					bool   bACTIVE       = true        ;
					string sCONDITION    = String.Empty;
					string sTHEN_ACTIONS = String.Empty;
					string sELSE_ACTIONS = String.Empty;
					RulesGet(gRULE_ID, ref sRULE_NAME, ref nPRIORITY, ref sREEVALUATION, ref bACTIVE, ref sCONDITION, ref sTHEN_ACTIONS, ref sELSE_ACTIONS);
					txtRULE_ID     .Value   = gRULE_ID.ToString() ;
					txtRULE_NAME   .Text    = sRULE_NAME          ;
					txtPRIORITY    .Text    = nPRIORITY.ToString();
					chkACTIVE      .Checked = bACTIVE             ;
					txtCONDITION   .Text    = sCONDITION          ;
					txtTHEN_ACTIONS.Text    = sTHEN_ACTIONS       ;
					txtELSE_ACTIONS.Text    = sELSE_ACTIONS       ;
					Utils.SetSelectedValue(lstREEVALUATION, sREEVALUATION);
				}
				else if ( e.CommandName == "Rules.Update" )
				{
					// 12/07/2010 Paul.  There does not seem to be a compelling reason to have a rule name. 
					if ( Sql.IsEmptyString(txtRULE_NAME.Text) )
						txtRULE_NAME.Text = Guid.NewGuid().ToString();
					
					Guid   gRULE_ID      = Sql.ToGuid(txtRULE_ID.Value);
					string sRULE_NAME    = txtRULE_NAME   .Text   ;
					int    nPRIORITY     = Sql.ToInteger(txtPRIORITY.Text);
					string sREEVALUATION = lstREEVALUATION.SelectedValue;
					bool   bACTIVE       = chkACTIVE      .Checked;
					string sCONDITION    = txtCONDITION   .Text   ;
					string sTHEN_ACTIONS = txtTHEN_ACTIONS.Text   ;
					string sELSE_ACTIONS = txtELSE_ACTIONS.Text   ;
					
					//reqRULE_NAME   .Enabled = true;
					reqCONDITION   .Enabled = true;
					reqTHEN_ACTIONS.Enabled = true;
					reqRULE_NAME   .Validate();
					reqCONDITION   .Validate();
					reqTHEN_ACTIONS.Validate();
					if ( reqRULE_NAME.IsValid && reqCONDITION.IsValid && reqTHEN_ACTIONS.IsValid )
					{
						// 12/12/2012 Paul.  For security reasons, we want to restrict the data types available to the rules wizard. 
						SplendidRulesTypeProvider typeProvider = new SplendidRulesTypeProvider();
						RulesUtil.RulesValidate(gRULE_ID, sRULE_NAME, nPRIORITY, sREEVALUATION, bACTIVE, sCONDITION, sTHEN_ACTIONS, sELSE_ACTIONS, typeof(SplendidWizardThis), typeProvider);
						RulesUpdate  (gRULE_ID, sRULE_NAME, nPRIORITY, sREEVALUATION, bACTIVE, sCONDITION, sTHEN_ACTIONS, sELSE_ACTIONS);
						ResetRuleText();
						
						// 10/23/2010 Paul.  Build the ruleset so that the entire set will get validated. 
						// 12/12/2012 Paul.  For security reasons, we want to restrict the data types available to the rules wizard. 
						RuleValidation validation = new RuleValidation(typeof(SplendidWizardThis), typeProvider);
						RuleSet rules = RulesUtil.BuildRuleSet(dtRules, validation);
					}
				}
				else if ( e.CommandName == "Cancel" )
				{
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName.StartsWith("Filters.") )
				{
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		protected void grdMain_OnSelectMethod(int nCurrentPageIndex, int nPageSize)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					string sTABLE_NAME = Crm.Modules.TableName(sWizardModule);
					cmd.CommandText = "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf;
					Security.Filter(cmd, sWizardModule, "list");
					if ( !Sql.IsEmptyString(ctlQueryBuilder.ReportSQL) )
					{
						cmd.CommandText += "   and ID in " + ControlChars.CrLf 
						                + "(" + ctlQueryBuilder.ReportSQL + ")" + ControlChars.CrLf;
					}
					cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
					                + cmd.CommandText;
					if ( nPageSize > 0 )
					{
						Sql.PageResults(cmd, sTABLE_NAME, grdMain.OrderByClause(), nCurrentPageIndex, nPageSize);
					}
					else
					{
						cmd.CommandText += grdMain.OrderByClause();
					}
					
					if ( bDebug )
						RegisterClientScriptBlock("SQLPagedMain", Sql.ClientScriptBlock(cmd));
					
					// 01/13/2010 Paul.  Allow default search to be disabled. 
					if ( IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(sWizardModule) )
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
							}
						}
					}
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			// 02/17/2018 Paul.  It was incorrectly coded as list access. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				reqNAME.DataBind();
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					DataView vwModules = new DataView(SplendidCache.RulesModules());
					List<string> arrModules = new List<string>();
					foreach ( DataRowView row in vwModules )
					{
						string sMODULE_NAME = Sql.ToString(row["MODULE_NAME"]);
						if ( SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "edit") >= 0 )
						{
							arrModules.Add(sMODULE_NAME);
						}
					}
					vwModules.RowFilter = "MODULE_NAME in ('" + String.Join("', '", arrModules.ToArray()) + "')";
					vwModules.Sort      = "DISPLAY_NAME";
					lstMODULE.DataSource = vwModules;
					lstMODULE.DataBind();
					// 03/29/2012 Paul.  Add Rules Wizard support to Terminology module. 
					if ( Security.IS_ADMIN )
					{
						lstMODULE.Items.Add(new ListItem(L10n.Term(".moduleList.Terminology"), "Terminology"));
					}
					if ( !Sql.IsEmptyString(sWizardModule) )
						Utils.SetValue(lstMODULE, sWizardModule);

					lstREEVALUATION.DataSource = SplendidCache.List("rules_reevaluation_dom");
					lstREEVALUATION.DataBind();
					foreach ( DataGridColumn col in dgRules.Columns )
					{
						if ( !Sql.IsEmptyString(col.HeaderText) )
						{
							col.HeaderText = L10n.Term(col.HeaderText);
						}
					}

					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL;
							sSQL = "select *           " + ControlChars.CrLf
							     + "  from vwRULES_Edit" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								// 04/24/2018 Paul.  Provide a way to exclude the SavedSearch for areas that are global in nature. 
								Security.Filter(cmd, m_sMODULE, "edit", "ASSIGNED_USER_ID", true);
								if ( !Sql.IsEmptyGuid(gDuplicateID) )
								{
									Sql.AppendParameter(cmd, gDuplicateID, "ID", false);
									gID = Guid.Empty;
								}
								else
								{
									Sql.AppendParameter(cmd, gID, "ID", false);
								}
								con.Open();

								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

								// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											DataRow rdr = dtCurrent.Rows[0];
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											
											txtACTIVE_TAB.Value = "3";
											Guid gASSIGNED_USER_ID = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
											txtNAME.Text              = Sql.ToString(rdr["NAME"            ]);
											txtASSIGNED_USER_ID.Value = gASSIGNED_USER_ID.ToString();
											txtASSIGNED_TO.Text       = Sql.ToString(rdr["ASSIGNED_TO"     ]);
											ViewState["ASSIGNED_USER_ID"] = gASSIGNED_USER_ID;
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, gASSIGNED_USER_ID, rdr);
											
											sWizardModule = Sql.ToString(rdr["MODULE_NAME"]);
											Utils.SetSelectedValue(lstMODULE, sWizardModule);
											lstMODULE_Changed(null, null);
											
											string sFILTER_XML = Sql.ToString(rdr["FILTER_XML"]);
											ctlQueryBuilder.Modules = sWizardModule;
											ctlQueryBuilder.LoadRdl(sFILTER_XML);
											
											// 06/17/2010 Paul.  Manually manage singular Team field. 
											TEAM_NAME.Text    = Sql.ToString(rdr["TEAM_NAME"]);
											TEAM_ID.Value     = Sql.ToString(rdr["TEAM_ID"  ]);
											Guid gTEAM_SET_ID = Sql.ToGuid(rdr["TEAM_SET_ID"]);
											ctlTeamSelect.LoadLineItems(gTEAM_SET_ID, true);
											
											dtRules = new DataTable();
											string sRULES_XML = Sql.ToString(rdr["RULES_XML"]);
											using ( StringReader srdr = new StringReader(sRULES_XML) )
											{
												dtRules.ReadXml(srdr);
											}
										}
										else
										{
											// 06/17/2010 Paul.  Manually manage singular Team field. 
											TEAM_NAME.Text    = Security.TEAM_NAME;
											TEAM_ID.Value     = Security.TEAM_ID.ToString();
											ctlTeamSelect.LoadLineItems(Guid.Empty, true);
											
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
											txtACTIVE_TAB.Value = "1";
										}
									}
								}
							}
						}
					}
					else
					{
						// 10/24/2010 Paul.  If the module is not defined, then select the top of the list. 
						if ( Sql.IsEmptyString(sWizardModule) )
						{
							if ( vwModules.Count > 0 )
								sWizardModule = Sql.ToString(vwModules[0]["MODULE_NAME"]);
						}
						lstMODULE_Changed(null, null);

						txtACTIVE_TAB.Value = !Sql.IsEmptyString(Request["Module"]) ? "2" : "1";
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						TEAM_NAME.Text    = Security.TEAM_NAME;
						TEAM_ID.Value     = Security.TEAM_ID.ToString();
						ctlTeamSelect.LoadLineItems(Guid.Empty, true);
					}
					// 10/24/2010 Paul.  Just in case the security settings have changed, re-check the loaded values. 
					if ( Sql.IsEmptyString(sWizardModule) || SplendidCRM.Security.GetUserAccess(sWizardModule, "edit") < 0 )
					{
						this.Visible = false;
						return;
					}
					if ( dtRules == null )
					{
						dtRules = new DataTable();
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
					}
					ViewState["RulesDataTable"] = dtRules;

					dgRules.DataSource = dtRules;
					dgRules.DataBind();
				}
				else
				{
					dtRules = ViewState["RulesDataTable"] as DataTable;
					dgRules.DataSource = dtRules;
					dgRules.DataBind();
					//dtRuleColumns = ViewState["RULE_COLUMNS"] as DataTable;
					// 01/22/2015 Paul.  Move data binding until after query builder is loaded. 
				}
				reqRULE_NAME   .DataBind();
				reqCONDITION   .DataBind();
				reqTHEN_ACTIONS.DataBind();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_PreRender(object sender, System.EventArgs e)
		{
			ViewState["RulesDataTable"] = dtRules;
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
			this.Load                  += new System.EventHandler(this.Page_Load);
			this.PreRender             += new System.EventHandler(this.Page_PreRender);
			ctlDynamicButtons.Command  += new CommandEventHandler(Page_Command);
			ctlQueryBuilder.Command    += new CommandEventHandler(Page_Command);
			m_sMODULE = "RulesWizard";
			SetMenu(m_sMODULE);
			
			arrSelectFields = new UniqueStringCollection();
			sWizardModule = Sql.ToString(Request.Form[hidCURRENT_MODULE.UniqueID]);
			if ( Sql.IsEmptyString(sWizardModule) )
				sWizardModule = Sql.ToString(Request["Module"]);
			if ( !Sql.IsEmptyString(sWizardModule) )
			{
				ctlQueryBuilder.Modules = sWizardModule;
				this.AppendGridColumns(grdMain   , sWizardModule + ".ListView", arrSelectFields);
				this.AppendGridColumns(grdResults, sWizardModule + ".ListView", arrSelectFields);
				if ( IsPostBack )
				{
					ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				}
			}
			// 04/27/2018 Paul.  We need to be able to generate an error message. 
			if ( IsPostBack )
			{
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}
