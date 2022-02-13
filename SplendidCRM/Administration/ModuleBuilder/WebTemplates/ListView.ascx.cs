using System;
using System.Data;
using System.Data.Common;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.$modulename$
{
//$sqlprocs$
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected _controls.HeaderButtons ctlModuleHeader;
		protected _controls.ExportHeader ctlExportHeader;
		protected _controls.SearchView   ctlSearchView  ;
		protected _controls.CheckAll     ctlCheckAll    ;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected MassUpdate    ctlMassUpdate  ;
		protected Panel         pnlMassUpdateSeven;

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
				else if ( e.CommandName == "ToggleMassUpdate" )
				{
					pnlMassUpdateSeven.Visible = !pnlMassUpdateSeven.Visible;
				}
				else if ( e.CommandName == "MassUpdate" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						System.Collections.Stack stk = Utils.FilterByACL_Stack(m_sMODULE, "edit", arrID, SplendidCRM.Crm.Modules.TableName(m_sMODULE));
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
											$callmassupdateprocedure$
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
				else if ( e.CommandName == "MassDelete" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						System.Collections.Stack stk = Utils.FilterByACL_Stack(m_sMODULE, "delete", arrID, SplendidCRM.Crm.Modules.TableName(m_sMODULE));
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
											SqlProcs.sp$tablename$_MassDelete(sIDs, trn);
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
				else if ( e.CommandName == "MassMerge" )
				{
					Server.Transfer("merge.aspx", true);
				}
				else if ( e.CommandName == "Export" )
				{
					int nACLACCESS = SplendidCRM.Security.GetUserAccess(m_sMODULE, "export");
					if ( nACLACCESS  >= 0 )
					{
						if ( vwMain == null )
							grdMain.DataBind();
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
				else if ( e.CommandName == "Report" || e.CommandName == "ReportAll" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( e.CommandName == "ReportAll" )
					{
						if ( vwMain == null )
							grdMain.DataBind();
						if ( vwMain != null )
						{
							arrID = new string[vwMain.Count];
							for ( int i = 0; i < vwMain.Count; i++ )
							{
								arrID[i] = Sql.ToString(vwMain[i]["ID"]);
							}
						}
					}
					if ( arrID != null && arrID.Length > 0 )
					{
						if ( Sql.IsEmptyString(e.CommandArgument) )
						{
							throw(new Exception("Button CommandArgument is empty."));
						}
						string sRenderURL = "~/Reports/render.aspx?" + Sql.ToString(e.CommandArgument).Trim();
						if ( !sRenderURL.EndsWith("&") )
							sRenderURL += "&";
						string sTABLE_NAME         = SplendidCRM.Crm.Modules.TableName(m_sMODULE);
						string sMODULE_FIELD_NAME  = SplendidCRM.Crm.Modules.SingularTableName(sTABLE_NAME) + "_ID";
						sRenderURL += sMODULE_FIELD_NAME + "=" + String.Join("&" + sMODULE_FIELD_NAME + "=", arrID);
						Server.Transfer(sRenderURL);
					}
					else
					{
						throw(new Exception(L10n.Term(".LBL_NOTHING_SELECTED")));
					}
				}
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
					string sTABLE_NAME = SplendidCRM.Crm.Modules.TableName(m_sMODULE);
					cmd.CommandText = "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf
					                + "  left outer join vwSUGARFAVORITES                                       " + ControlChars.CrLf
					                + "               on vwSUGARFAVORITES.FAVORITE_RECORD_ID = ID               " + ControlChars.CrLf
					                + "              and vwSUGARFAVORITES.FAVORITE_USER_ID   = @FAVORITE_USER_ID" + ControlChars.CrLf;
					Sql.AddParameter(cmd, "@FAVORITE_USER_ID", Security.USER_ID);
					if ( this.StreamEnabled() )
					{
						cmd.CommandText += "  left outer join vwSUBSCRIPTIONS                                               " + ControlChars.CrLf;
						cmd.CommandText += "               on vwSUBSCRIPTIONS.SUBSCRIPTION_PARENT_ID = ID                   " + ControlChars.CrLf;
						cmd.CommandText += "              and vwSUBSCRIPTIONS.SUBSCRIPTION_USER_ID   = @SUBSCRIPTION_USER_ID" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@SUBSCRIPTION_USER_ID", Security.USER_ID);
						arrSelectFields.Add("SUBSCRIPTION_PARENT_ID");
					}
					Security.Filter(cmd, m_sMODULE, "list");
					ctlSearchView.SqlSearchClause(cmd);
					cmd.CommandText = "select " + (Request.Form[ctlExportHeader.ExportUniqueID] != null ? SplendidDynamic.ExportGridColumns(m_sMODULE + ".Export", arrSelectFields) : Sql.FormatSelectFields(arrSelectFields))
					                + (!this.StreamEnabled() ? "     , null as SUBSCRIPTION_PARENT_ID" + ControlChars.CrLf : String.Empty)
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
					ctlMassUpdate.Visible = ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
					ctlCheckAll  .Visible = ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				if ( SplendidCRM.Crm.Config.allow_custom_paging() && SplendidCRM.Crm.Modules.CustomPaging(m_sMODULE) )
				{
					grdMain.AllowCustomPaging = (Request.Form[ctlExportHeader.ExportUniqueID] == null || !(ctlExportHeader.ExportRange == "All" || ctlExportHeader.ExportRange == "Selected")) && !ctlCheckAll.SelectAllChecked;
					grdMain.SelectMethod     += new SelectMethodHandler(grdMain_OnSelectMethod);
					ctlCheckAll.ShowSelectAll = false;
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
						
						string sTABLE_NAME = SplendidCRM.Crm.Modules.TableName(m_sMODULE);
						cmd.CommandText = "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf
						                + "  left outer join vwSUGARFAVORITES                                       " + ControlChars.CrLf
						                + "               on vwSUGARFAVORITES.FAVORITE_RECORD_ID = ID               " + ControlChars.CrLf
						                + "              and vwSUGARFAVORITES.FAVORITE_USER_ID   = @FAVORITE_USER_ID" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@FAVORITE_USER_ID", Security.USER_ID);
						if ( this.StreamEnabled() )
						{
							cmd.CommandText += "  left outer join vwSUBSCRIPTIONS                                               " + ControlChars.CrLf;
							cmd.CommandText += "               on vwSUBSCRIPTIONS.SUBSCRIPTION_PARENT_ID = ID                   " + ControlChars.CrLf;
							cmd.CommandText += "              and vwSUBSCRIPTIONS.SUBSCRIPTION_USER_ID   = @SUBSCRIPTION_USER_ID" + ControlChars.CrLf;
							Sql.AddParameter(cmd, "@SUBSCRIPTION_USER_ID", Security.USER_ID);
							arrSelectFields.Add("SUBSCRIPTION_PARENT_ID");
						}
						Security.Filter(cmd, m_sMODULE, "list");
						ctlSearchView.SqlSearchClause(cmd);
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
							cmd.CommandText = "select " + (Request.Form[ctlExportHeader.ExportUniqueID] != null ? SplendidDynamic.ExportGridColumns(m_sMODULE + ".Export", arrSelectFields) : Sql.FormatSelectFields(arrSelectFields))
							                + (!this.StreamEnabled() ? "     , null as SUBSCRIPTION_PARENT_ID" + ControlChars.CrLf : String.Empty)
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
							ctlMassUpdate.Visible = ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
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
			ctlMassUpdate  .Command += new CommandEventHandler(Page_Command);
			ctlExportHeader.Command += new CommandEventHandler(Page_Command);
			ctlCheckAll    .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "$modulename$";
			SetMenu(m_sMODULE);
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID");
			arrSelectFields.Add("ASSIGNED_USER_ID");
			arrSelectFields.Add("FAVORITE_RECORD_ID");
			arrSelectFields.Add("PENDING_PROCESS_ID");
			this.AppendGridColumns(grdMain, m_sMODULE + "." + LayoutListView, arrSelectFields, Page_Command);
			if ( Security.GetUserAccess(m_sMODULE, "delete") < 0 && Security.GetUserAccess(m_sMODULE, "edit") < 0 )
				ctlMassUpdate.Visible = false;
			
			if ( SplendidDynamic.StackedLayout(Page.Theme) )
			{
				ctlModuleHeader.Command += new CommandEventHandler(Page_Command);
				ctlModuleHeader.AppendButtons(m_sMODULE + "." + LayoutListView, Guid.Empty, null);
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
