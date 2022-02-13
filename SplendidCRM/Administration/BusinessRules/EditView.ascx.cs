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
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Workflow.Activities.Rules;
using System.Workflow.ComponentModel.Compiler;
using System.Diagnostics;

namespace SplendidCRM.Administration.BusinessRules
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected _controls.DynamicButtons ctlFooterButtons ;
		protected bool   bShowTopButtons    = true ;
		protected bool   bShowBottomButtons = false;
		protected bool   bShowHeader        = true ;
		protected bool   bShowCancel        = true ;

		protected Guid            gID                   ;
		protected DropDownList    lstMODULE             ;
		protected TextBox         txtNAME               ;

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
		protected RequiredFieldValidator reqNAME        ;
		protected RequiredFieldValidator reqRULE_NAME   ;
		protected RequiredFieldValidator reqCONDITION   ;
		protected RequiredFieldValidator reqTHEN_ACTIONS;

		protected DataTable       dtRuleColumns  ;
		protected Repeater        ctlConditionSchemaRepeater;
		protected Repeater        ctlThenSchemaRepeater;
		protected Repeater        ctlElseSchemaRepeater;
		protected Repeater        ctlConditionSchemaRepeater2;
		protected Repeater        ctlThenSchemaRepeater2;
		protected Repeater        ctlElseSchemaRepeater2;

		public CommandEventHandler Command     ;

		public bool ShowTopButtons
		{
			get { return bShowTopButtons; }
			set { bShowTopButtons = value; }
		}

		public bool ShowBottomButtons
		{
			get { return bShowBottomButtons; }
			set { bShowBottomButtons = value; }
		}

		public bool ShowHeader
		{
			get { return bShowHeader; }
			set { bShowHeader = value; }
		}

		public bool ShowCancel
		{
			get { return bShowCancel; }
			set { bShowCancel = value; }
		}

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
				if ( bShowTopButtons )
					ctlDynamicButtons.ErrorText = ex.Message;
				else if ( bShowBottomButtons )
					ctlFooterButtons.ErrorText = ex.Message;
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

		protected void lstMODULE_Changed(Object sender, EventArgs e)
		{
			// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
			ctlDynamicButtons.Title = L10n.Term(".moduleList." + lstMODULE.SelectedValue);
			string sMODULE_TABLE = Sql.ToString(Application["Modules." + lstMODULE.SelectedValue + ".TableName"]);
			// 05/24/2011 Paul.  Use the view so that custom fields will be included. 
			dtRuleColumns = SplendidCache.SqlColumns("vw" + sMODULE_TABLE + "_Edit").Copy();
			/*
			foreach(DataRow row in dtRuleColumns.Rows)
			{
				row["ColumnName"] = Utils.TableColumnName(L10n, lstMODULE.SelectedValue, Sql.ToString(row["ColumnName"]));
			}
			*/
			ViewState["RULE_COLUMNS"] = dtRuleColumns;
			ctlConditionSchemaRepeater.DataSource = dtRuleColumns;
			ctlThenSchemaRepeater     .DataSource = dtRuleColumns;
			ctlElseSchemaRepeater     .DataSource = dtRuleColumns;
			ctlConditionSchemaRepeater.DataBind();
			ctlThenSchemaRepeater     .DataBind();
			ctlElseSchemaRepeater     .DataBind();

			ctlConditionSchemaRepeater2.DataSource = dtRuleColumns;
			ctlThenSchemaRepeater2     .DataSource = dtRuleColumns;
			ctlElseSchemaRepeater2     .DataSource = dtRuleColumns;
			ctlConditionSchemaRepeater2.DataBind();
			ctlThenSchemaRepeater2     .DataBind();
			ctlElseSchemaRepeater2     .DataBind();
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				// 12/05/2010 Paul.  When in a popup, the NewRecord is the same as the save event. 
				if ( e.CommandName == "Save" || e.CommandName == "NewRecord" )
				{
					bool bIsValid = Page.IsValid;
					if ( bIsValid && dtRules.Rows.Count == 0 )
					{
						if ( bShowTopButtons )
							ctlDynamicButtons.ErrorText = L10n.Term("Rules.ERR_NO_RULES");
						else if ( bShowBottomButtons )
							ctlFooterButtons.ErrorText = L10n.Term("Rules.ERR_NO_RULES");
						bIsValid = false;
					}
					if ( bIsValid )
					{
						RuleValidation validation = new RuleValidation(typeof(SplendidControlThis), null);
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
										Guid gTEAM_ID          = Guid.Empty;
										Guid gASSIGNED_USER_ID = Guid.Empty;
										SqlProcs.spRULES_Update
											( ref gID
											, gASSIGNED_USER_ID
											, txtNAME.Text
											, lstMODULE.SelectedValue
											, "Business"
											, String.Empty
											, String.Empty
											, String.Empty
											, sbRulesXML.ToString()
											, sXOML
											, gTEAM_ID
											, String.Empty
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
										if ( bShowTopButtons )
											ctlDynamicButtons.ErrorText = ex.Message;
										else if ( bShowBottomButtons )
											ctlFooterButtons.ErrorText = ex.Message;
										return;
									}
									// 06/29/2012 Paul.  Business Rules need to be cleared after saving. 
									// 03/11/2014 Paul.  This rule could be for EditView, DetailView or GridView, so we have to clear them all. 
									SplendidCache.ClearBusinessRules();
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							if ( bShowTopButtons )
								ctlDynamicButtons.ErrorText = ex.Message;
							else if ( bShowBottomButtons )
								ctlFooterButtons.ErrorText = ex.Message;
							return;
						}
						if ( Command != null )
						{
							e = new CommandEventArgs("NewRecord", gID.ToString());
							Command(sender, e);
						}
						else
							Response.Redirect("default.aspx");
					}
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
						RulesUtil.RulesValidate(gRULE_ID, sRULE_NAME, nPRIORITY, sREEVALUATION, bACTIVE, sCONDITION, sTHEN_ACTIONS, sELSE_ACTIONS, typeof(SplendidControlThis), typeProvider);
						RulesUpdate  (gRULE_ID, sRULE_NAME, nPRIORITY, sREEVALUATION, bACTIVE, sCONDITION, sTHEN_ACTIONS, sELSE_ACTIONS);
						ResetRuleText();
						
						// 10/23/2010 Paul.  Build the ruleset so that the entire set will get validated. 
						RuleValidation validation = new RuleValidation(typeof(SplendidControlThis), null);
						RuleSet rules = RulesUtil.BuildRuleSet(dtRules, validation);
					}
				}
				else if ( e.CommandName == "Cancel" )
				{
					if ( Command != null )
					{
						e = new CommandEventArgs("NewRecord.Cancel", gID.ToString());
						Command(sender, e);
					}
					else
						Response.Redirect("default.aspx");
				}
				else if ( e.CommandName.StartsWith("Filters.") )
				{
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				if ( bShowTopButtons )
					ctlDynamicButtons.ErrorText = ex.Message;
				else if ( bShowBottomButtons )
					ctlFooterButtons.ErrorText = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				Parent.DataBind();
				return;
			}

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					DataView vwModules = new DataView(SplendidCache.ReportingModules());
					List<string> arrModules = new List<string>();
					foreach ( DataRowView row in vwModules )
					{
						string sMODULE_NAME = Sql.ToString(row["MODULE_NAME"]);
						if ( SplendidCRM.Security.AdminUserAccess(sMODULE_NAME, "edit") >= 0 )
						{
							arrModules.Add(sMODULE_NAME);
						}
					}
					vwModules.RowFilter = "MODULE_NAME in ('" + String.Join("', '", arrModules.ToArray()) + "')";
					vwModules.Sort      = "DISPLAY_NAME";
					lstMODULE.DataSource = vwModules;
					lstMODULE.DataBind();
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
							     + "  from vwRULES_Edit" + ControlChars.CrLf
							     + " where 1 = 1       " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
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
											
											txtNAME.Text = Sql.ToString(rdr["NAME"]);
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
											
											string sMODULE_NAME = Sql.ToString(rdr["MODULE_NAME"]);
											Utils.SetSelectedValue(lstMODULE, sMODULE_NAME);
											lstMODULE_Changed(null, null);
											
											dtRules = new DataTable();
											string sRULES_XML = Sql.ToString(rdr["RULES_XML"]);
											using ( StringReader srdr = new StringReader(sRULES_XML) )
											{
												dtRules.ReadXml(srdr);
											}
										}
										else
										{
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlFooterButtons.DisableAll();
											if ( bShowTopButtons )
												ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
											else if ( bShowBottomButtons )
												ctlFooterButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
					}
					else
					{
						lstMODULE_Changed(null, null);

						if ( bShowCancel )
						{
							ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
							ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						}
						else
						{
							ctlDynamicButtons.AppendButtons("NewRecord.SaveOnly", Guid.Empty, Guid.Empty);
							ctlFooterButtons .AppendButtons("NewRecord.SaveOnly", Guid.Empty, Guid.Empty);
						}
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
				}
				reqNAME        .DataBind();
				reqRULE_NAME   .DataBind();
				reqCONDITION   .DataBind();
				reqTHEN_ACTIONS.DataBind();
				// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. Separate method to show/hide buttons in header. 
				ctlDynamicButtons.ShowButtons = bShowTopButtons;
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				if ( bShowTopButtons )
					ctlDynamicButtons.ErrorText = ex.Message;
				else if ( bShowBottomButtons )
					ctlFooterButtons.ErrorText = ex.Message;
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
			ctlFooterButtons .Command  += new CommandEventHandler(Page_Command);
			m_sMODULE = "BusinessRules";
			SetMenu(m_sMODULE);
			
			if ( IsPostBack )
			{
				if ( bShowCancel )
				{
					ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				}
				else
				{
					ctlDynamicButtons.AppendButtons("NewRecord.SaveOnly", Guid.Empty, Guid.Empty);
					ctlFooterButtons .AppendButtons("NewRecord.SaveOnly", Guid.Empty, Guid.Empty);
				}
			}
		}
		#endregion
	}
}
