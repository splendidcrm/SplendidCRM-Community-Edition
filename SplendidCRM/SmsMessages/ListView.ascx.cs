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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.SmsMessages
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		// 06/05/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlModuleHeader;
		protected _controls.ExportHeader ctlExportHeader;
		protected _controls.SearchView   ctlSearchView  ;
		protected _controls.CheckAll     ctlCheckAll    ;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected MassUpdate    ctlMassUpdate  ;
		// 06/06/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected Panel         pnlMassUpdateSeven;
		// 04/03/2018 Paul.  Enable Dynamic Mass Update.
		protected _controls.DynamicMassUpdate ctlDynamicMassUpdate;
		protected string        sTYPE          ;

		public string Type
		{
			get
			{
				return sTYPE;
			}
			set
			{
				sTYPE = value;
			}
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" )
				{
					grdMain.CurrentPageIndex = 0;
					grdMain.DataBind();
				}
				else if ( e.CommandName == "SortGrid" )
				{
					grdMain.SetSortFields(e.CommandArgument as string[]);
					arrSelectFields.AddFields(grdMain.SortColumn);
				}
				else if ( e.CommandName == "SelectAll" )
				{
					if ( vwMain == null )
						grdMain.DataBind();
					ctlCheckAll.SelectAll(vwMain, "ID");
					grdMain.DataBind();
				}
				// 06/06/2015 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
				else if ( e.CommandName == "ToggleMassUpdate" )
				{
					pnlMassUpdateSeven.Visible = !pnlMassUpdateSeven.Visible;
				}
				else if ( e.CommandName == "MassUpdate" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						System.Collections.Stack stk = Utils.FilterByACL_Stack(m_sMODULE, "edit", arrID, Crm.Modules.TableName(m_sMODULE));
						if ( stk.Count > 0 )
						{
							DbProviderFactory dbf = DbProviderFactories.GetFactory();
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								using ( IDbTransaction trn = Sql.BeginTransaction(con) )
								{
									try
									{
										while ( stk.Count > 0 )
										{
											string sIDs = Utils.BuildMassIDs(stk);
											// 06/29/2018 Paul.  Placeholders for ASSIGNED_SET_LIST and ASSIGNED_SET_ADD. 
											SqlProcs.spSMS_MESSAGES_MassUpdate(sIDs, ctlMassUpdate.ASSIGNED_USER_ID, ctlMassUpdate.PRIMARY_TEAM_ID, ctlMassUpdate.TEAM_SET_LIST, ctlMassUpdate.ADD_TEAM_SET, String.Empty, false, trn);
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
							Response.Redirect("default.aspx");
						}
					}
				}
				// 04/03/2018 Paul.  Enable Dynamic Mass Update.
				else if ( e.CommandName == "DynamicMassUpdate" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						System.Collections.Stack stk = Utils.FilterByACL_Stack(m_sMODULE, "edit", arrID, Crm.Modules.TableName(m_sMODULE));
						if ( stk.Count > 0 )
						{
							ctlDynamicMassUpdate.Update(stk);
							Response.Redirect("default.aspx");
						}
					}
				}
				else if ( e.CommandName == "MassDelete" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						System.Collections.Stack stk = Utils.FilterByACL_Stack(m_sMODULE, "delete", arrID, Crm.Modules.TableName(m_sMODULE));
						if ( stk.Count > 0 )
						{
							DbProviderFactory dbf = DbProviderFactories.GetFactory();
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								using ( IDbTransaction trn = Sql.BeginTransaction(con) )
								{
									try
									{
										while ( stk.Count > 0 )
										{
											string sIDs = Utils.BuildMassIDs(stk);
											SqlProcs.spSMS_MESSAGES_MassDelete(sIDs, trn);
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
							Response.Redirect("default.aspx");
						}
					}
				}
				else if ( e.CommandName == "Export" )
				{
					int nACLACCESS = SplendidCRM.Security.GetUserAccess(m_sMODULE, "export");
					if ( nACLACCESS  >= 0 )
					{
						if ( vwMain == null )
							grdMain.DataBind();
						// 07/06/2017 Paul.  If there is still no view, then there was an error in the select. 
						if ( vwMain != null )
						{
							if ( nACLACCESS == ACL_ACCESS.OWNER )
								vwMain.RowFilter = "ASSIGNED_USER_ID = '" + Security.USER_ID.ToString() + "'";
							string[] arrID = ctlCheckAll.SelectedItemsArray;
							SplendidExport.Export(vwMain, m_sMODULE, ctlExportHeader.ExportFormat, ctlExportHeader.ExportRange, grdMain.CurrentPageIndex, grdMain.PageSize, arrID, grdMain.AllowCustomPaging);
						}
						else
						{
							lblError.Text += ControlChars.CrLf + "vwMain is null.";
						}
					}
				}
				// 09/26/2017 Paul.  Add Archive access right. 
				else if ( e.CommandName == "Archive.MoveData" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					ArchiveUtils archive = new ArchiveUtils(Context);
					lblError.Text = archive.MoveData(m_sMODULE, arrID);
					if ( Sql.IsEmptyString(lblError.Text) )
						Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "Archive.RecoverData" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					ArchiveUtils archive = new ArchiveUtils(Context);
					lblError.Text = archive.RecoverData(m_sMODULE, arrID);
					if ( Sql.IsEmptyString(lblError.Text) )
						Response.Redirect("default.aspx?ArchiveView=1");
				}
				// 03/08/2014 Paul.  Add support for Preview button. 
				else
				{
					grdMain.DataBind();
					if ( Page.Master is SplendidMaster )
						(Page.Master as SplendidMaster).Page_Command(sender, e);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
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
					string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
					// 09/26/2017 Paul.  Add Archive access right. 
					// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
					m_sVIEW_NAME = (ArchiveViewEnabled() ? "vw" + sTABLE_NAME + "_ARCHIVE" : "vw" + sTABLE_NAME + "_List");
					cmd.CommandText = "  from " + m_sVIEW_NAME + ControlChars.CrLf
					                + "  left outer join vwSUGARFAVORITES                                       " + ControlChars.CrLf
					                + "               on vwSUGARFAVORITES.FAVORITE_RECORD_ID = ID               " + ControlChars.CrLf
					                + "              and vwSUGARFAVORITES.FAVORITE_USER_ID   = @FAVORITE_USER_ID" + ControlChars.CrLf;
					Sql.AddParameter(cmd, "@FAVORITE_USER_ID", Security.USER_ID);
					// 09/26/2017 Paul.  Add Archive access right. 
					Security.Filter(cmd, m_sMODULE, (ArchiveViewEnabled() ? "archive" : "list"));
					ctlSearchView.SqlSearchClause(cmd);
					if ( !Sql.IsEmptyString(sTYPE) )
						Sql.AppendParameter(cmd, sTYPE, 25, Sql.SqlFilterMode.Exact, "TYPE");
					// 09/23/2015 Paul.  Paginated results still need to specify export fields. 
					// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
					cmd.CommandText = "select " + (Request.Form[ctlExportHeader.ExportUniqueID] != null ? SplendidDynamic.ExportGridColumns(m_sMODULE + ".Export", arrSelectFields) : Sql.FormatSelectFields(arrSelectFields))
					                + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
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
						RegisterClientScriptBlock("SQLPaged", Sql.ClientScriptBlock(cmd));
					
					if ( PrintView || IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(m_sMODULE) )
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								foreach(DataRow row in dt.Rows)
								{
									row["TYPE_TERM"] = L10n.Term(row["TYPE_TERM"] as string);
									if ( row["NAME"] == DBNull.Value )
										row["NAME"] = "(no subject)";
								}
								this.ApplyGridViewRules(m_sMODULE + "." + LayoutListView, dt);
								
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
							}
						}
						ctlExportHeader.Visible = true;
					}
					else
					{
						ctlExportHeader.Visible = false;
					}
					// 04/03/2018 Paul.  Enable Dynamic Mass Update. 
					ctlMassUpdate       .Visible = !SplendidCRM.Crm.Config.enable_dynamic_mass_update() && ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
					ctlDynamicMassUpdate.Visible =  SplendidCRM.Crm.Config.enable_dynamic_mass_update() && ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
					// 06/06/2015 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
					ctlCheckAll  .Visible = ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			// 09/26/2017 Paul.  Add Archive access right. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, (ArchiveViewEnabled() ? "archive" : "list")) >= 0);
			if ( !this.Visible )
				return;

			try
			{
				if ( Crm.Config.allow_custom_paging() && Crm.Modules.CustomPaging(m_sMODULE) )
				{
					// 01/24/2018 Paul.  Disable custom paging if Selected Records is used as selection can cross pages. 
					grdMain.AllowCustomPaging = (Request.Form[ctlExportHeader.ExportUniqueID] == null || ctlExportHeader.ExportRange == "Page") && !ctlCheckAll.SelectAllChecked;
					grdMain.SelectMethod     += new SelectMethodHandler(grdMain_OnSelectMethod);
				}

				if ( this.IsMobile && grdMain.Columns.Count > 0 )
					grdMain.Columns[0].Visible = false;
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						grdMain.OrderByClause("NAME", "asc");
						
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						// 09/26/2017 Paul.  Add Archive access right. 
						// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
						m_sVIEW_NAME = (ArchiveViewEnabled() ? "vw" + sTABLE_NAME + "_ARCHIVE" : "vw" + sTABLE_NAME + "_List");
						cmd.CommandText = "  from " + m_sVIEW_NAME + ControlChars.CrLf
						                + "  left outer join vwSUGARFAVORITES                                       " + ControlChars.CrLf
						                + "               on vwSUGARFAVORITES.FAVORITE_RECORD_ID = ID               " + ControlChars.CrLf
						                + "              and vwSUGARFAVORITES.FAVORITE_USER_ID   = @FAVORITE_USER_ID" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@FAVORITE_USER_ID", Security.USER_ID);
						// 09/26/2017 Paul.  Add Archive access right. 
						Security.Filter(cmd, m_sMODULE, (ArchiveViewEnabled() ? "archive" : "list"));
						ctlSearchView.SqlSearchClause(cmd);
						if ( !Sql.IsEmptyString(sTYPE) )
							Sql.AppendParameter(cmd, sTYPE, 25, Sql.SqlFilterMode.Exact, "TYPE");
						if ( grdMain.AllowCustomPaging )
						{
							cmd.CommandText = "select count(*)" + ControlChars.CrLf
							                + cmd.CommandText;
							
							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
							
							if ( PrintView || IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(m_sMODULE) )
							{
								grdMain.VirtualItemCount = Sql.ToInteger(cmd.ExecuteScalar());
							}
						}
						else
						{
							// 09/23/2015 Paul.  Need to include the data grid fields as it will be bound using the same data set. 
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							cmd.CommandText = "select " + (Request.Form[ctlExportHeader.ExportUniqueID] != null ? SplendidDynamic.ExportGridColumns(m_sMODULE + ".Export", arrSelectFields) : Sql.FormatSelectFields(arrSelectFields))
							                + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
							                + cmd.CommandText
							                + grdMain.OrderByClause();
							
							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
							
							if ( PrintView || IsPostBack || SplendidCRM.Crm.Modules.DefaultSearch(m_sMODULE) )
							{
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dt = new DataTable() )
									{
										da.Fill(dt);
										foreach(DataRow row in dt.Rows)
										{
											row["TYPE_TERM"] = L10n.Term(row["TYPE_TERM"] as string);
											if ( row["NAME"] == DBNull.Value )
												row["NAME"] = "(no subject)";
										}
										this.ApplyGridViewRules(m_sMODULE + "." + LayoutListView, dt);
										
										vwMain = dt.DefaultView;
										grdMain.DataSource = vwMain ;
									}
								}
								ctlExportHeader.Visible = true;
							}
							else
							{
								ctlExportHeader.Visible = false;
							}
							// 04/03/2018 Paul.  Enable Dynamic Mass Update. 
							ctlMassUpdate       .Visible = !SplendidCRM.Crm.Config.enable_dynamic_mass_update() && ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
							ctlDynamicMassUpdate.Visible =  SplendidCRM.Crm.Config.enable_dynamic_mass_update() && ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
							// 06/06/2015 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
							ctlCheckAll  .Visible = ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
						}
					}
				}
				if ( !IsPostBack )
				{
					grdMain.DataBind();
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
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
			ctlSearchView  .Command += new CommandEventHandler(Page_Command);
			ctlExportHeader.Command += new CommandEventHandler(Page_Command);
			ctlMassUpdate  .Command += new CommandEventHandler(Page_Command);
			ctlCheckAll    .Command += new CommandEventHandler(Page_Command);
			// 04/03/2018 Paul.  Enable Dynamic Mass Update.
			ctlDynamicMassUpdate.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "SmsMessages";
			SetMenu(m_sMODULE);
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("NAME"              );
			arrSelectFields.Add("TYPE_TERM"         );
			arrSelectFields.Add("ATTACHMENT_COUNT"  );
			arrSelectFields.Add("ASSIGNED_USER_ID"  );
			arrSelectFields.Add("FAVORITE_RECORD_ID");
			// 03/08/2014 Paul.  Add support for Preview button. 
			// 09/26/2017 Paul.  Add Archive access right. 
			ctlModuleHeader.Title = (ArchiveViewEnabled() ? ".LBL_ARCHIVE_VIEW" : ".moduleList.Home");
			this.AppendGridColumns(grdMain, m_sMODULE + "." + (ArchiveViewEnabled() ? "ArchiveView" : LayoutListView), arrSelectFields, Page_Command);
			if ( Security.GetUserAccess(m_sMODULE, "delete") < 0 && Security.GetUserAccess(m_sMODULE, "edit") < 0 )
			{
				ctlMassUpdate.Visible = false;
				// 04/03/2018 Paul.  Enable Dynamic Mass Update.
				ctlDynamicMassUpdate.Visible = false;
			}
			
			// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
			if ( SplendidDynamic.StackedLayout(Page.Theme) )
			{
				ctlModuleHeader.Command += new CommandEventHandler(Page_Command);
				ctlModuleHeader.AppendButtons(m_sMODULE + "." + LayoutListView, Guid.Empty, null);
				// 06/05/2015 Paul.  Move MassUpdate buttons to the SplendidGrid. 
				grdMain.IsMobile       = this.IsMobile;
				grdMain.MassUpdateView = m_sMODULE + ".MassUpdate";
				grdMain.Command       += new CommandEventHandler(Page_Command);
				if ( !IsPostBack )
					pnlMassUpdateSeven.Visible = false;
			}
		}
		#endregion
	}
}

