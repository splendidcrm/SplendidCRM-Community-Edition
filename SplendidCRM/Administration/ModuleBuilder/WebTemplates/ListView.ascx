<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.$modulename$.ListView" %>
<div id="divListView">
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="$modulename$" Title=".moduleList.Home" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="$modulename$" ShowDuplicateSearch="true" Visible="<%# !PrintView %>" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="ExportHeader" Src="~/_controls/ExportHeader.ascx" %>
	<SplendidCRM:ExportHeader ID="ctlExportHeader" Module="$modulename$" Title="$modulename$.LBL_LIST_FORM_TITLE" Runat="Server" />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<asp:HiddenField ID="LAYOUT_LIST_VIEW" Runat="server" />
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%">
				<ItemTemplate><%# grdMain.InputCheckbox(!PrintView && !IsMobile && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE), ctlCheckAll.FieldName, Sql.ToGuid(Eval("ID")), ctlCheckAll.SelectedItems) %></ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Center" ItemStyle-Wrap="false">
				<ItemTemplate>
					<asp:HyperLink onclick=<%# "return SplendidCRM_ChangeFavorites(this, \'" + m_sMODULE + "\', \'" + Sql.ToString(Eval("ID")) + "\')" %> Visible="<%# !this.IsMobile %>" Runat="server">
						<asp:Image name='<%# "favAdd_" + Sql.ToString(Eval("ID")) %>' SkinID="favorites_add"    style='<%# "display:" + ( Sql.IsEmptyGuid(Eval("FAVORITE_RECORD_ID")) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_ADD_TO_FAVORITES"     ) %>' Runat="server" />
						<asp:Image name='<%# "favRem_" + Sql.ToString(Eval("ID")) %>' SkinID="favorites_remove" style='<%# "display:" + (!Sql.IsEmptyGuid(Eval("FAVORITE_RECORD_ID")) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_REMOVE_FROM_FAVORITES") %>' Runat="server" />
					</asp:HyperLink>
					<asp:HyperLink onclick=<%# "return SplendidCRM_ChangeFollowing(this, \'" + m_sMODULE + "\', \'" + Sql.ToString(Eval("ID")) + "\')" %> Visible="<%# !this.IsMobile && this.StreamEnabled() %>" Runat="server">
						<asp:Image name='<%# "follow_"    + Sql.ToString(Eval("ID")) %>' SkinID="follow"    style='<%# "display:" + ( Sql.IsEmptyGuid(Eval("SUBSCRIPTION_PARENT_ID")) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_FOLLOW"   ) %>' Runat="server" />
						<asp:Image name='<%# "following_" + Sql.ToString(Eval("ID")) %>' SkinID="following" style='<%# "display:" + (!Sql.IsEmptyGuid(Eval("SUBSCRIPTION_PARENT_ID")) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_FOLLOWING") %>' Runat="server" />
					</asp:HyperLink>
					<asp:HyperLink Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, m_sMODULE, "edit", "ASSIGNED_USER_ID") >= 0 && !Sql.IsProcessPending(Container) %>' NavigateUrl='<%# "~/" + m_sMODULE + "/edit.aspx?id=" + Eval("ID") %>' ToolTip='<%# L10n.Term(".LNK_EDIT") %>' Runat="server">
						<asp:Image SkinID="edit_inline" Runat="server" />
					</asp:HyperLink>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
	<%@ Register TagPrefix="SplendidCRM" Tagname="CheckAll" Src="~/_controls/CheckAll.ascx" %>
	<SplendidCRM:CheckAll ID="ctlCheckAll" Visible="<%# !PrintView && !IsMobile && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE) %>" Runat="Server" />
	<asp:Panel ID="pnlMassUpdateSeven" runat="server">
		<%@ Register TagPrefix="SplendidCRM" Tagname="MassUpdate" Src="MassUpdate.ascx" %>
		<SplendidCRM:MassUpdate ID="ctlMassUpdate" Visible="<%# !PrintView && !IsMobile && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE) %>" Runat="Server" />
	</asp:Panel>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>
