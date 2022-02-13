<%@ Control CodeBehind="ActivityStream.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.SubPanelControl" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Diagnostics" %>
<script runat="server">
		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "ActivityStream.Create":
						pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "inline");
						ctlDynamicButtons.HideAll();
						break;
					case "InsertPost":
						pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "none");
						ctlDynamicButtons.ShowAll();
						BindGrid();
						break;
					case "NewRecord.Cancel":
						pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "none");
						ctlDynamicButtons.ShowAll();
						break;
					case "NewRecord":
						Response.Redirect(Request.RawUrl);
						break;
					case "ActivityStream.Search":
						ctlSearchView.Visible = !ctlSearchView.Visible;
						break;
					case "Search":
						break;
					case "Clear":
						BindGrid();
						break;
					case "SortGrid":
						break;
					case "Preview":
						if ( Page.Master is SplendidMaster )
						{
							CommandEventArgs ePreview = new CommandEventArgs(e.CommandName, new PreviewData(m_sMODULE, Sql.ToGuid(e.CommandArgument)));
							(Page.Master as SplendidMaster).Page_Command(sender, ePreview);
						}
						break;
					default:
						throw(new Exception("Unknown command: " + e.CommandName));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		protected void BindGrid()
		{
			SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					string sTABLE_NAME = SplendidCRM.Crm.Modules.TableName(m_sMODULE);
					sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
					     + "  from vw" + sTABLE_NAME + "_STREAM" + ControlChars.CrLf;
					cmd.CommandText = sSQL;
					Security.Filter(cmd, m_sMODULE, "list");
					Sql.AppendParameter(cmd, gID, "ID");
					ctlSearchView.SqlSearchClause(cmd);
					cmd.CommandText += grdMain.OrderByClause("STREAM_DATE desc, STREAM_VERSION desc", String.Empty);

					if ( bDebug )
						RegisterClientScriptBlock("vw" + sTABLE_NAME + "_STREAM", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								this.ApplyGridViewRules("ActivityStream." + m_sMODULE, dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								grdMain.DataBind();
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						ctlDynamicButtons.ErrorText = ex.Message;
					}
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			this.Visible = this.StreamEnabled();
			if ( !this.Visible )
				return;

			gID = Sql.ToGuid(Request["ID"]);
			try
			{
				BindGrid();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}

			if ( !IsPostBack )
			{
				Guid gASSIGNED_USER_ID = Sql.ToGuid(Page.Items["ASSIGNED_USER_ID"]);
				ctlDynamicButtons.AppendButtons("ActivityStream.Subpanel", gASSIGNED_USER_ID, gID);
				ctlNewRecord.PARENT_ID = gID;
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
			ctlNewRecord.Command      += new CommandEventHandler(Page_Command);
			ctlSearchView.Command     += new CommandEventHandler(Page_Command);
			m_sMODULE = "$modulename$";
			ctlNewRecord.Module = m_sMODULE;
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"                   );
			arrSelectFields.Add("AUDIT_ID"             );
			arrSelectFields.Add("STREAM_DATE"          );
			arrSelectFields.Add("STREAM_ACTION"        );
			arrSelectFields.Add("STREAM_COLUMNS"       );
			arrSelectFields.Add("STREAM_RELATED_ID"    );
			arrSelectFields.Add("STREAM_RELATED_MODULE");
			arrSelectFields.Add("STREAM_RELATED_NAME"  );
			arrSelectFields.Add("NAME"                 );
			arrSelectFields.Add("CREATED_BY_ID"        );
			arrSelectFields.Add("CREATED_BY"           );
			arrSelectFields.Add("CREATED_BY_PICTURE"   );
			arrSelectFields.Add("ASSIGNED_USER_ID"     );
			SplendidDynamic.GridColumns(m_sMODULE + ".ActivityStream." + LayoutListView, arrSelectFields, null);
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("ActivityStream.Subpanel", Guid.Empty, Guid.Empty);
		}
		#endregion
</script>
<%@ Register TagPrefix="SplendidCRM" Tagname="SubPanelButtons" Src="~/_controls/SubPanelButtons.ascx" %>
<SplendidCRM:SubPanelButtons ID="ctlDynamicButtons" Module="ActivityStream" SubPanel="div$modulename$ActivityStream" Title=".LBL_ACTIVITY_STREAM" Runat="Server" />

<div id="div$modulename$ActivityStream" style='<%= "display:" + (CookieValue("div$modulename$ActivityStream") != "1" ? "inline" : "none") %>'>
	<asp:Panel ID="pnlNewRecordInline" Visible='<%# !Sql.ToBoolean(Application["CONFIG.disable_editview_inline"]) %>' Style="display:none" runat="server">
		<%@ Register TagPrefix="SplendidCRM" Tagname="NewRecord" Src="~/ActivityStream/NewRecord.ascx" %>
		<SplendidCRM:NewRecord ID="ctlNewRecord" Width="100%" ShowCancel="true" ShowHeader="false" Runat="Server" />
	</asp:Panel>
	
	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/ActivityStream/SearchBasic.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Visible="false" Runat="Server" />
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdSubPanelView" AllowPaging="<%# !PrintView %>" ShowHeader="false" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="100%" ItemStyle-HorizontalAlign="Left">
				<ItemTemplate>
					<table cellpadding="2" cellspacing="0" border="0" width="100%">
						<tr>
							<td width="50px">
								<div class="ActivityStreamPicture" >
									<asp:Image CssClass="ActivityStreamPicture" SkinID="ActivityStreamUser"                                Visible='<%#  Sql.IsEmptyGuid(Eval("AUDIT_ID")) &&  Sql.IsEmptyString(Eval("CREATED_BY_PICTURE")) %>' runat="server" />
									<asp:Image CssClass="ActivityStreamPicture" src='<%# Eval("CREATED_BY_PICTURE") %>'                    Visible='<%#  Sql.IsEmptyGuid(Eval("AUDIT_ID")) && !Sql.IsEmptyString(Eval("CREATED_BY_PICTURE")) %>' runat="server" />
									<asp:Panel CssClass='<%# "ModuleHeaderModule ModuleHeaderModule" + m_sMODULE + " ListHeaderModule" %>' Visible='<%# !Sql.IsEmptyGuid(Eval("AUDIT_ID")) %>' runat="server"><%# L10n.Term(m_sMODULE + ".LBL_MODULE_ABBREVIATION") %></asp:Panel>
								</div>
							</td>
							<td>
								<div class="ActivityStreamDescription"><%# SplendidCRM.ActivityStream.StreamView.StreamFormatDescription(m_sMODULE, L10n, T10n, Container.DataItem) %></div>
								<div class="ActivityStreamIdentity">
									<span class="ActivityStreamCreatedBy"><%# Eval("CREATED_BY") %></span>
									<span class="ActivityStreamDateEntered"><%# Eval("STREAM_DATE") %></span>
								</div>
							</td>
							<td width="20px">
								<asp:ImageButton Visible='<%# SplendidCRM.Security.GetUserAccess(m_sMODULE, "view") >= 0 && (Sql.ToString(Eval("STREAM_ACTION")) != "Deleted") %>' CommandName="Preview" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_PREVIEW") %>' SkinID="preview_inline" Runat="server" />
							</td>
						</tr>
					</table>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
</div>

