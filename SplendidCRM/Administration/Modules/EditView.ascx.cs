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
using System.Data;
using System.Data.Common;
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.Modules
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		// 01/13/2010 Paul.  Add footer buttons. 
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected Guid            gID                             ;
		protected HtmlTable       tblMain                         ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			// 03/15/2014 Paul.  Enable override of concurrency error. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveConcurrency" )
			{
				try
				{
					// 01/16/2006 Paul.  Enable validator before validating page. 
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView);
					if ( Page.IsValid )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							DataRow   rowCurrent = null;
							DataTable dtCurrent  = new DataTable();
							if ( !Sql.IsEmptyGuid(gID) )
							{
								string sSQL ;
								// 09/08/2010 Paul.  We need a separate view for the list as the default view filters by MODULE_ENABLED 
								// and we don't want to filter by that flag in the ListView, DetailView or EditView. 
								sSQL = "select *             " + ControlChars.CrLf
								     + "  from vwMODULES_Edit" + ControlChars.CrLf
								     + " where 1 = 1         " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AppendParameter(cmd, gID, "ID", false);
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											rowCurrent = dtCurrent.Rows[0];
											DateTime dtLAST_DATE_MODIFIED = Sql.ToDateTime(ViewState["LAST_DATE_MODIFIED"]);
											// 03/15/2014 Paul.  Enable override of concurrency error. 
											if ( Sql.ToBoolean(Application["CONFIG.enable_concurrency_check"])  && (e.CommandName != "SaveConcurrency") && dtLAST_DATE_MODIFIED != DateTime.MinValue && Sql.ToDateTime(rowCurrent["DATE_MODIFIED"]) > dtLAST_DATE_MODIFIED )
											{
												ctlDynamicButtons.ShowButton("SaveConcurrency", true);
												ctlFooterButtons .ShowButton("SaveConcurrency", true);
												throw(new Exception(String.Format(L10n.Term(".ERR_CONCURRENCY_OVERRIDE"), dtLAST_DATE_MODIFIED)));
											}
										}
										else
										{
											gID = Guid.Empty;
										}
									}
								}
							}

							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									// 12/02/2009 Paul.  Add the ability to disable Mass Updates. 
									// 04/01/2010 Paul.  Add Exchange Sync flag. 
									// 04/04/2010 Paul.  Add Exchange Folders flag. 
									// 04/05/2010 Paul.  Need to be able to disable Account creation. This is because the email may come from a personal email address.
									// 09/12/2011 Paul.  Add REST_ENABLED. 
									// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
									// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
									SqlProcs.spMODULES_Update
										( ref gID
										, new DynamicControl(this, rowCurrent, "MODULE_NAME"           ).Text
										, new DynamicControl(this, rowCurrent, "DISPLAY_NAME"          ).Text
										, new DynamicControl(this, rowCurrent, "RELATIVE_PATH"         ).Text
										, new DynamicControl(this, rowCurrent, "MODULE_ENABLED"        ).Checked
										, new DynamicControl(this, rowCurrent, "TAB_ENABLED"           ).Checked
										, new DynamicControl(this, rowCurrent, "MOBILE_ENABLED"        ).Checked
										, new DynamicControl(this, rowCurrent, "TAB_ORDER"             ).IntegerValue
										, new DynamicControl(this, rowCurrent, "PORTAL_ENABLED"        ).Checked
										, new DynamicControl(this, rowCurrent, "CUSTOM_ENABLED"        ).Checked
										, new DynamicControl(this, rowCurrent, "REPORT_ENABLED"        ).Checked
										, new DynamicControl(this, rowCurrent, "IMPORT_ENABLED"        ).Checked
										, new DynamicControl(this, rowCurrent, "SYNC_ENABLED"          ).Checked
										, new DynamicControl(this, rowCurrent, "IS_ADMIN"              ).Checked
										, new DynamicControl(this, rowCurrent, "CUSTOM_PAGING"         ).Checked
										, new DynamicControl(this, rowCurrent, "TABLE_NAME"            ).Text
										, new DynamicControl(this, rowCurrent, "MASS_UPDATE_ENABLED"   ).Checked
										, new DynamicControl(this, rowCurrent, "DEFAULT_SEARCH_ENABLED").Checked
										, new DynamicControl(this, rowCurrent, "EXCHANGE_SYNC"         ).Checked
										, new DynamicControl(this, rowCurrent, "EXCHANGE_FOLDERS"      ).Checked
										, new DynamicControl(this, rowCurrent, "EXCHANGE_CREATE_PARENT").Checked
										, new DynamicControl(this, rowCurrent, "REST_ENABLED"          ).Checked
										, new DynamicControl(this, rowCurrent, "DUPLICATE_CHECHING_ENABLED"   ).Checked
										, new DynamicControl(this, rowCurrent, "RECORD_LEVEL_SECURITY_ENABLED").Checked
										, trn
										);
									trn.Commit();

									// 11/20/2009 Paul.  Move module init to a separate function. 
									// This will provide a central location to manage the LastModified, which is needed for ModulePopupScripts. 
									SplendidInit.InitModules  (Context);
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
								// 10/24/2009 Paul.  Clear menus just in case a module has been disabled or enabled. 
								SplendidCache.ClearTabMenu();
							}
						}
						Response.Redirect("view.aspx?ID=" + gID.ToString());
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				if ( Sql.IsEmptyGuid(gID) )
					Response.Redirect("default.aspx");
				else
					Response.Redirect("view.aspx?ID=" + gID.ToString());
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							// 09/08/2010 Paul.  We need a separate view for the list as the default view filters by MODULE_ENABLED 
							// and we don't want to filter by that flag in the ListView, DetailView or EditView. 
							sSQL = "select *             " + ControlChars.CrLf
							     + "  from vwMODULES_Edit" + ControlChars.CrLf
							     + " where 1 = 1         " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AppendParameter(cmd, gID, "ID", false);
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
											ctlDynamicButtons.Title = Sql.ToString(rdr["MODULE_NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											
											this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, rdr);
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
										}
										else
										{
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlFooterButtons .DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
					}
					else
					{
						this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					}
				}
				else
				{
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Modules";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
			}
		}
		#endregion
	}
}

