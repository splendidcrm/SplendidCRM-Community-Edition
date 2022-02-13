<%@ Control Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.SplendidControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Diagnostics" %>
<script runat="server">
		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected bool          bMultiSelect   ;

		public bool MultiSelect
		{
			get { return bMultiSelect; }
			set { bMultiSelect = value; }
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" || e.CommandName == "Save" )
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
			SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
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
					// 09/18/2012 Paul.  Disable custom paging if SelectAll was checked. 
					grdMain.AllowCustomPaging = !ctlCheckAll.SelectAllChecked;
					grdMain.SelectMethod     += new SelectMethodHandler(grdMain_OnSelectMethod);
					//ctlCheckAll.ShowSelectAll = false;
				}

				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
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
</script>
<div id="divPopupView">
	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="$modulename$" IsPopupSearch="true" ShowSearchTabs="false" Visible="<%# !PrintView %>" Runat="Server" />

	<script type="text/javascript">
	function Select$modulenamesingular$(sPARENT_ID, sPARENT_NAME)
	{
		if ( window.opener != null && window.opener.Change$modulenamesingular$ != null )
		{
			window.opener.Change$modulenamesingular$(sPARENT_ID, sPARENT_NAME);
			window.close();
		}
		else
		{
			alert('Original window has closed.  $modulenamesingular$ cannot be assigned.' + '\n' + sPARENT_ID + '\n' + sPARENT_NAME);
		}
	}
	function SelectChecked()
	{
		if ( window.opener != null && window.opener.Change$modulenamesingular$ != null )
		{
			var sSelectedItems = document.getElementById('<%= ctlCheckAll.SelectedItems.ClientID %>').value;
			window.opener.Change$modulenamesingular$(sSelectedItems, '');
			window.close();
		}
		else
		{
			alert('Original window has closed.  $modulenamesingular$ cannot be assigned.');
		}
	}
	function Clear()
	{
		if ( window.opener != null && window.opener.Change$modulenamesingular$ != null )
		{
			window.opener.Change$modulenamesingular$('', '');
			window.close();
		}
		else
		{
			alert('Original window has closed.  $modulenamesingular$ cannot be assigned.');
		}
	}
	function Cancel()
	{
		window.close();
	}
	</script>
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="$modulename$.LBL_LIST_FORM_TITLE" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Runat="Server" />

	<asp:UpdatePanel UpdateMode="Conditional" Visible='<%# !Sql.ToBoolean(Application["CONFIG.disable_popupview_inline"]) %>' runat="server">
		<ContentTemplate>
			<asp:Button ID="btnCreateInline" CommandName="NewRecord.Show" OnCommand="Page_Command" Text='<%# L10n.Term(m_sMODULE + ".LNK_NEW_$tablenamesingular$") %>' CssClass="button" style="margin-bottom: 4px;" Visible="<%# !this.IsMobile %>" runat="server" />
			<asp:Panel ID="pnlNewRecordInline" Style="display:none" runat="server">
				<%@ Register TagPrefix="SplendidCRM" Tagname="NewRecord" Src="NewRecord.ascx" %>
				<SplendidCRM:NewRecord ID="ctlNewRecord" Width="100%" EditView="PopupView.Inline" ShowCancel="true" Runat="Server" />
			</asp:Panel>
		</ContentTemplate>
	</asp:UpdatePanel>

	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdPopupView" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="2%">
				<ItemTemplate><%# grdMain.InputCheckbox(!PrintView && bMultiSelect, ctlCheckAll.FieldName, Sql.ToGuid(Eval("ID")), ctlCheckAll.SelectedItems) %></ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
	<%@ Register TagPrefix="SplendidCRM" Tagname="CheckAll" Src="~/_controls/CheckAll.ascx" %>
	<SplendidCRM:CheckAll ID="ctlCheckAll" Visible="<%# !PrintView && bMultiSelect %>" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>
