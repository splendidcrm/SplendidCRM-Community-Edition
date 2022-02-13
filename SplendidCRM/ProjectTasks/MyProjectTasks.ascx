<%@ Control CodeBehind="MyProjectTasks.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.ProjectTasks.MyProjectTasks" %>
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
<div id="divProjectTasksMyProjectTasks">
	<%@ Register TagPrefix="SplendidCRM" Tagname="DashletHeader" Src="~/_controls/DashletHeader.ascx" %>
	<SplendidCRM:DashletHeader ID="ctlDashletHeader" Title="ProjectTask.LBL_LIST_MY_PROJECT_TASKS" DivEditName="my_projecttasks_edit" Runat="Server" />
	
	<div ID="my_projecttasks_edit" style="DISPLAY: <%= bShowEditDialog ? "inline" : "none" %>">
		<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
		<SplendidCRM:SearchView ID="ctlSearchView" Module="ProjectTask" SearchMode="SearchHome" IsDashlet="true" AutoSaveSearch="true" ShowSearchTabs="false" ShowSearchViews="false" ShowDuplicateSearch="false" Visible="<%# !PrintView %>" Runat="Server" />
	</div>
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="ProjectTask.LBL_LIST_CLOSE" SortExpression="STATUS" ItemStyle-Width="1%">
				<ItemTemplate>
					<asp:ImageButton CommandName="ProjectTask.Close" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" AlternateText='<%# L10n.Term("ProjectTask.LBL_LIST_CLOSE") %>' SkinID="close_inline" Runat="server" />
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Center" ItemStyle-Wrap="false">
				<ItemTemplate>
					<%-- 10/31/2017 Paul.  Provide a way to inject Record level ACL. --%>
					<asp:HyperLink Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, m_sMODULE, "edit", "ASSIGNED_USER_ID") >= 0 %>' NavigateUrl='<%# "~/ProjectTasks/edit.aspx?id=" + Eval("ID") %>' ToolTip='<%# L10n.Term(".LNK_EDIT") %>' Runat="server">
						<asp:Image SkinID="edit_inline" Runat="server" />
					</asp:HyperLink>
					<asp:HyperLink Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, m_sMODULE, "view", "ASSIGNED_USER_ID") >= 0 %>' NavigateUrl='<%# "~/ProjectTasks/view.aspx?id=" + Eval("ID") %>' ToolTip='<%# L10n.Term(".LNK_VIEW") %>' Runat="server">
						<asp:Image SkinID="view_inline" Runat="server" />
					</asp:HyperLink>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
</div>
<br />

