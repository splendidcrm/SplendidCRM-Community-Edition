using System;
using System.Data;
using System.Data.Common;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.$modulename$
{
	/// <summary>
	///		Summary description for PopupView.
	/// </summary>
	public class PopupView : SplendidControl
	{
		protected _controls.SearchView     ctlSearchView    ;
		protected _controls.DynamicButtons ctlDynamicButtons;
		protected _controls.CheckAll       ctlCheckAll      ;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected bool          bMultiSelect   ;
		protected Button        btnCreateInline   ;
		protected Panel         pnlNewRecordInline;
		protected NewRecord     ctlNewRecord      ;

		public bool MultiSelect
		{
			get { return bMultiSelect; }
			set { bMultiSelect = value; }
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
				else if ( e.CommandName == "NewRecord.Show" )
				{
					btnCreateInline   .Visible = false;
					pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "inline");
				}
				else if ( e.CommandName == "NewRecord.Cancel" )
				{
					btnCreateInline   .Visible = true;
					pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "none");
				}
				else if ( e.CommandName == "NewRecord" )
				{
					ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
					if ( mgrAjax != null )
					{
						Guid   gID   = Sql.ToGuid(e.CommandArgument);
						string sNAME = SplendidCRM.Crm.Modules.ItemName(Application, m_sMODULE, gID);
						ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "NewRecord", "Select$modulenamesingular$('" + gID.ToString() + "', '" + Sql.EscapeJavaScript(sNAME) + "');", true);
					}
					else
					{
						Response.Redirect(Request.RawUrl);
					}
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
					string sTABLE_NAME = SplendidCRM.Crm.Modules.TableName(m_sMODULE);
					cmd.CommandText = "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf;
					Security.Filter(cmd, m_sMODULE, "list");
					ctlSearchView.SqlSearchClause(cmd);
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
						RegisterClientScriptBlock("SQLPaged", Sql.ClientScriptBlock(cmd));
					
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
					grdMain.AllowCustomPaging = !ctlCheckAll.SelectAllChecked;
					grdMain.SelectMethod     += new SelectMethodHandler(grdMain_OnSelectMethod);
				}

				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						grdMain.OrderByClause("NAME", "asc");
						
						string sTABLE_NAME = SplendidCRM.Crm.Modules.TableName(m_sMODULE);
						cmd.CommandText = "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf;
						Security.Filter(cmd, m_sMODULE, "list");
						ctlSearchView.SqlSearchClause(cmd);
						if ( grdMain.AllowCustomPaging )
						{
							cmd.CommandText = "select count(*)" + ControlChars.CrLf
							                + cmd.CommandText;
							
							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
							
							grdMain.VirtualItemCount = Sql.ToInteger(cmd.ExecuteScalar());
						}
						else
						{
							cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
							                + cmd.CommandText
							                + grdMain.OrderByClause();
							
							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
							
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
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlSearchView    .Command += new CommandEventHandler(Page_Command);
			ctlNewRecord     .Command += new CommandEventHandler(Page_Command);
			ctlCheckAll      .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "$modulename$";
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("NAME");
			this.AppendGridColumns(grdMain, m_sMODULE + ".PopupView", arrSelectFields);
			ctlDynamicButtons.AppendButtons(m_sMODULE + ".Popup" + (bMultiSelect ? "MultiSelect" : "View"), Guid.Empty, Guid.Empty);
			if ( !IsPostBack && !bMultiSelect )
				ctlDynamicButtons.ShowButton("Clear", !Sql.ToBoolean(Request["ClearDisabled"]));
		}
		#endregion
	}
}
