<%@ Control CodeBehind="$relatedmodule$.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.$modulename$.$relatedmodule$" %>
<script type="text/javascript">
function $relatedmodulesingular$Popup()
{
	return ModulePopup('$relatedmodule$', '<%= txt$relatedtablesingular$_ID.ClientID %>', null, 'ClearDisabled=1', true, null);
}
</script>
<input ID="txt$relatedtablesingular$_ID" type="hidden" Runat="server" />
<%@ Register TagPrefix="SplendidCRM" Tagname="SubPanelButtons" Src="~/_controls/SubPanelButtons.ascx" %>
<SplendidCRM:SubPanelButtons ID="ctlDynamicButtons" Module="$relatedmodule$" SubPanel="div$modulename$$relatedmodule$" Title="$relatedmodule$.LBL_MODULE_NAME" Runat="Server" />

<div id="div$modulename$$relatedmodule$" style='<%= "display:" + (CookieValue("div$modulename$$relatedmodule$") != "1" ? "inline" : "none") %>'>
	<asp:Panel ID="pnlNewRecordInline" Visible='<%# !Sql.ToBoolean(Application["CONFIG.disable_editview_inline"]) %>' Style="display:none" runat="server">
		<%@ Register TagPrefix="SplendidCRM" Tagname="NewRecord" Src="~/$relatedmodule$/NewRecord.ascx" %>
		<SplendidCRM:NewRecord ID="ctlNewRecord" Width="100%" EditView="EditView.Inline" ShowCancel="true" ShowHeader="false" ShowFullForm="true" ShowTopButtons="true" Runat="Server" />
	</asp:Panel>
	
	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="$relatedmodule$" SearchMode="SearchSubpanel" IsSubpanelSearch="true" ShowSearchTabs="false" ShowDuplicateSearch="false" ShowSearchViews="false" Visible="false" Runat="Server" />
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdSubPanelView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Left" ItemStyle-Wrap="false">
				<ItemTemplate>
					<%-- 07/08/2021 Paul.  GetRecordAccess requires Container as first parameter. --%>
					<asp:ImageButton Visible='<%# !bEditView && SplendidCRM.Security.GetRecordAccess(Container, "$relatedmodule$", "edit", "ASSIGNED_USER_ID") >= 0 && !Sql.IsProcessPending(Container) %>' CommandName="$relatedmodule$.Edit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "$relatedtablesingular$_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_EDIT") %>' SkinID="edit_inline" Runat="server" />
					<asp:LinkButton  Visible='<%# !bEditView && SplendidCRM.Security.GetRecordAccess(Container, "$relatedmodule$", "edit", "ASSIGNED_USER_ID") >= 0 && !Sql.IsProcessPending(Container) %>' CommandName="$relatedmodule$.Edit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "$relatedtablesingular$_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_EDIT") %>' Runat="server" />
					&nbsp;
					<span onclick="return confirm('<%= L10n.TermJavaScript("$modulename$.NTC_REMOVE_$tablenamesingular$_CONFIRMATION") %>')">
						<%-- 07/08/2021 Paul.  GetRecordAccess requires Container as first parameter. --%>
						<asp:ImageButton Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, "$modulename$", "edit", "$tablenamesingular$_ASSIGNED_USER_ID") >= 0 %>' CommandName="$relatedmodule$.Remove" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "$relatedtablesingular$_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_REMOVE") %>' SkinID="delete_inline" Runat="server" />
						<asp:LinkButton  Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, "$modulename$", "edit", "$tablenamesingular$_ASSIGNED_USER_ID") >= 0 %>' CommandName="$relatedmodule$.Remove" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "$relatedtablesingular$_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_REMOVE") %>' Runat="server" />
					</span>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
</div>
