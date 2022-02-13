<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Feeds.ListView" %>
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
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="Feeds" Title=".moduleList.Home" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="Feeds" Visible="<%# !PrintView %>" ShowSearchTabs="false" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Feeds.LBL_LIST_FORM_TITLE" Runat="Server" />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn  HeaderText="Feeds.LBL_TITLE" SortExpression="TITLE" ItemStyle-Width="40%" ItemStyle-CssClass="listViewTdLinkS1">
				<ItemTemplate>
					<asp:HyperLink Text='<%# DataBinder.Eval(Container.DataItem, "TITLE") %>' NavigateUrl='<%# "view.aspx?id=" + DataBinder.Eval(Container.DataItem, "ID") %>' CssClass="listViewTdLinkS1" Runat="server" />
					<div style="DISPLAY: <%# !Sql.IsEmptyGuid(DataBinder.Eval(Container.DataItem, "USERS_FEED_ID")) ? "inline" : "none" %>">
						&nbsp;&nbsp;*
					</div>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn ItemStyle-Width="60%">
				<ItemTemplate>
					<%-- 10/31/2017 Paul.  Provide a way to inject Record level ACL. --%>
					<div style="DISPLAY: <%# Sql.IsEmptyGuid(DataBinder.Eval(Container.DataItem, "USERS_FEED_ID")) ? "inline" : "none" %>">
						<asp:ImageButton Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, m_sMODULE, "edit", "ASSIGNED_USER_ID") >= 0 %>' CommandName="Feeds.Add"    CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("Feeds.LBL_ADD_FAV_BUTTON_LABEL") %>' SkinID="plus_inline" Runat="server" />
						<asp:LinkButton  Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, m_sMODULE, "edit", "ASSIGNED_USER_ID") >= 0 %>' CommandName="Feeds.Add"    CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Runat="server"><%# L10n.Term("Feeds.LBL_ADD_FAV_BUTTON_LABEL") %></asp:LinkButton>
					</div>
					<div style="DISPLAY: <%# !Sql.IsEmptyGuid(DataBinder.Eval(Container.DataItem, "USERS_FEED_ID")) ? "inline" : "none" %>">
						<asp:ImageButton Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, m_sMODULE, "remove", "ASSIGNED_USER_ID") >= 0 %>' CommandName="Feeds.Remove" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("Feeds.LBL_DELETE_FAV_BUTTON_LABEL") %>' SkinID="minus_inline" Runat="server" />
						<asp:LinkButton  Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, m_sMODULE, "remove", "ASSIGNED_USER_ID") >= 0 %>' CommandName="Feeds.Remove" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term("Feeds.LBL_DELETE_FAV_BUTTON_LABEL") %>' Runat="server" />
					</div>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

