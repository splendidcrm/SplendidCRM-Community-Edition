<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.ProspectLists.ListView" %>
<script runat="server">
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
</script>
<div id="divListView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="ProspectLists" Title=".moduleList.Home" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="ProspectLists" ShowSearchTabs="false" Visible="<%# !PrintView %>" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="ExportHeader" Src="~/_controls/ExportHeader.ascx" %>
	<SplendidCRM:ExportHeader ID="ctlExportHeader" Module="ProspectLists" Title="ProspectLists.LBL_LIST_FORM_TITLE" Runat="Server" />
	
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
					<asp:HyperLink onclick=<%# "return SplendidCRM_ChangeFavorites(this, \'" + m_sMODULE + "\', \'" + Sql.ToString(Eval("ID")) + "\')" %> Visible="<%# !this.IsMobile && !this.DisableFavorites() %>" Runat="server">
						<asp:Image name='<%# "favAdd_" + Sql.ToString(Eval("ID")) %>' SkinID="favorites_add"    style='<%# "display:" + ( Sql.IsEmptyGuid(Eval("FAVORITE_RECORD_ID")) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_ADD_TO_FAVORITES"     ) %>' Runat="server" />
						<asp:Image name='<%# "favRem_" + Sql.ToString(Eval("ID")) %>' SkinID="favorites_remove" style='<%# "display:" + (!Sql.IsEmptyGuid(Eval("FAVORITE_RECORD_ID")) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_REMOVE_FROM_FAVORITES") %>' Runat="server" />
					</asp:HyperLink>
					<asp:HyperLink onclick=<%# "return SplendidCRM_ChangeFollowing(this, \'" + m_sMODULE + "\', \'" + Sql.ToString(Eval("ID")) + "\')" %> Visible="<%# !this.IsMobile && this.StreamEnabled() && !this.DisableFollowing() %>" Runat="server">
						<asp:Image name='<%# "follow_"    + Sql.ToString(Eval("ID")) %>' SkinID="follow"    style='<%# "display:" + ( Sql.IsEmptyGuid(Eval("SUBSCRIPTION_PARENT_ID")) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_FOLLOW"   ) %>' Runat="server" />
						<asp:Image name='<%# "following_" + Sql.ToString(Eval("ID")) %>' SkinID="following" style='<%# "display:" + (!Sql.IsEmptyGuid(Eval("SUBSCRIPTION_PARENT_ID")) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_FOLLOWING") %>' Runat="server" />
					</asp:HyperLink>
					<%-- 10/31/2017 Paul.  Provide a way to inject Record level ACL. --%>
					<asp:HyperLink Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, m_sMODULE, "edit", "ASSIGNED_USER_ID") >= 0 && !Sql.IsProcessPending(Container) %>' NavigateUrl='<%# "~/" + m_sMODULE + "/edit.aspx?id=" + Eval("ID") %>' ToolTip='<%# L10n.Term(".LNK_EDIT") %>' Runat="server">
						<asp:Image SkinID="edit_inline" Runat="server" />
					</asp:HyperLink>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
	<%@ Register TagPrefix="SplendidCRM" Tagname="CheckAll" Src="~/_controls/CheckAll.ascx" %>
	<SplendidCRM:CheckAll ID="ctlCheckAll" Visible="<%# !PrintView && !IsMobile && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE) %>" Runat="Server" />
	<%-- 06/06/2015 Paul.  MassUpdateButtons combines ListHeader and DynamicButtons. --%>
	<asp:Panel ID="pnlMassUpdateSeven" runat="server">
		<%@ Register TagPrefix="SplendidCRM" Tagname="MassUpdate" Src="MassUpdate.ascx" %>
		<SplendidCRM:MassUpdate ID="ctlMassUpdate" Visible="<%# !SplendidCRM.Crm.Config.enable_dynamic_mass_update() && !PrintView && !IsMobile && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE) %>" Runat="Server" />
		<%-- 04/03/2018 Paul.  Enable Dynamic Mass Update. --%>
		<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicMassUpdate" Src="~/_controls/DynamicMassUpdate.ascx" %>
		<SplendidCRM:DynamicMassUpdate ID="ctlDynamicMassUpdate" Module="ProspectLists" Visible="<%# SplendidCRM.Crm.Config.enable_dynamic_mass_update() && !PrintView && !IsMobile && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE) %>" runat="Server" />
	</asp:Panel>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

