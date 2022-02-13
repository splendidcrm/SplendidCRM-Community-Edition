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
using System.Diagnostics;

namespace SplendidCRM.Administration.ModulesArchiveRules
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected Reports.QueryBuilder     ctlQueryBuilder  ;
		protected _controls.TeamSelect     ctlTeamSelect    ;

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
		protected DropDownList    lstSTATUS             ;
		protected TextBox         txtDESCRIPTION        ;
		protected Label           lblStatus             ;
		protected RequiredFieldValidator reqNAME;

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
						                + "(" + ctlQueryBuilder.ReportSQL + ")" + ControlChars.CrLf
						                + "    and ID not in (select ARCHIVE_RECORD_ID from MODULES_ARCHIVE_LOG where ARCHIVE_ACTION = 'Recover' and MODULE_NAME = @MODULE_NAME)" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@MODULE_NAME", sWizardModule);
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
			
			ctlDynamicButtons.Title = L10n.Term(".moduleList." + sWizardModule);
			string sMODULE_TABLE = Sql.ToString(Application["Modules." + sWizardModule + ".TableName"]);
			
			ctlQueryBuilder.Modules = sWizardModule;
			ctlQueryBuilder.LoadRdl(String.Empty);
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "QueryBuilder.Loaded" )
				{
					if ( Sql.ToBoolean(ViewState["ShowMainPreview"]) )
					{
						BindMain(false);
					}
					return;
				}
				ViewState["ShowMainPreview"] = false;
				grdMain.CurrentPageIndex = 0;
				grdMain.DataSource = null;
				grdMain.DataBind();
				grdResults.CurrentPageIndex = 0;
				grdResults.DataSource = null;
				grdResults.DataBind();
				if ( e.CommandName == "Save" )
				{
					DataTable dtFilters = ctlQueryBuilder.ReportFilters();
					bool bIsValid = Page.IsValid;
					if ( bIsValid )
					{
						reqNAME.Enabled = true;
						reqNAME.Validate();
						if ( !reqNAME.IsValid )
						{
							bIsValid = false;
						}
						else if ( dtFilters.Rows.Count == 0 )
						{
							ctlDynamicButtons.ErrorText = L10n.Term("ModulesArchiveRules.ERR_FILTERS_REQUIRED");
							bIsValid = false;
						}
					}
					if ( bIsValid )
					{
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
										SqlProcs.spMODULES_ARCHIVE_RULES_Update
											( ref gID
											, txtNAME.Text
											, lstMODULE.SelectedValue
											, Sql.ToBoolean(lstSTATUS.SelectedValue)
											, txtDESCRIPTION.Text
											, ctlQueryBuilder.ReportSQL
											, ctlQueryBuilder.ReportRDL
											, trn
											);
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
					ctlQueryBuilder.ShowQuery = false;
					BindMain(true);
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
						                + "(" + ctlQueryBuilder.ReportSQL + ")" + ControlChars.CrLf
						                + "    and ID not in (select ARCHIVE_RECORD_ID from MODULES_ARCHIVE_LOG where ARCHIVE_ACTION = 'Recover' and MODULE_NAME = @MODULE_NAME)" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@MODULE_NAME", sWizardModule);
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
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				reqNAME.DataBind();
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					lstSTATUS.DataSource = SplendidCache.List("archive_rule_status_dom");
					lstSTATUS.DataBind();
					
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
					if ( !Sql.IsEmptyString(sWizardModule) )
						Utils.SetValue(lstMODULE, sWizardModule);

					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL;
							sSQL = "select *                      " + ControlChars.CrLf
							     + "  from vwMODULES_ARCHIVE_RULES" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Security.Filter(cmd, m_sMODULE, "edit");
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

								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											DataRow rdr = dtCurrent.Rows[0];
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											
											txtNAME       .Text = Sql.ToString(rdr["NAME"       ]);
											txtDESCRIPTION.Text = Sql.ToString(rdr["DESCRIPTION"]);
											Utils.SetSelectedValue(lstSTATUS, Sql.ToString(rdr["STATUS"]));
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
											
											sWizardModule = Sql.ToString(rdr["MODULE_NAME"]);
											Utils.SetSelectedValue(lstMODULE, sWizardModule);
											lstMODULE_Changed(null, null);
											
											string sFILTER_XML = Sql.ToString(rdr["FILTER_XML"]);
											ctlQueryBuilder.Modules = sWizardModule;
											ctlQueryBuilder.LoadRdl(sFILTER_XML);
										}
										else
										{
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
					}
					else
					{
						if ( Sql.IsEmptyString(sWizardModule) )
						{
							if ( vwModules.Count > 0 )
								sWizardModule = Sql.ToString(vwModules[0]["MODULE_NAME"]);
						}
						lstMODULE_Changed(null, null);

						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					}
					if ( Sql.IsEmptyString(sWizardModule) || SplendidCRM.Security.GetUserAccess(sWizardModule, "edit") < 0 )
					{
						this.Visible = false;
						return;
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_PreRender(object sender, System.EventArgs e)
		{
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
			m_sMODULE = "ModulesArchiveRules";
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
		}
		#endregion
	}
}
