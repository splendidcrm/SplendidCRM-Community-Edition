<%@ Control CodeBehind="MyActivities.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Activities.MyActivities" %>
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
<div id="divActivitiesMyActivities">
	<%@ Register TagPrefix="SplendidCRM" Tagname="MyActivitiesHeader" Src="MyActivitiesHeader.ascx" %>
	<SplendidCRM:MyActivitiesHeader ID="ctlDashletHeader" Title="Activities.LBL_UPCOMING" DivEditName="my_activities_edit" Runat="Server" />

	<div ID="my_activities_edit" style="DISPLAY: <%= bShowEditDialog ? "inline" : "none" %>">
		<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
		<SplendidCRM:SearchView ID="ctlSearchView" Module="Activities" SearchMode="SearchHome" IsDashlet="true" AutoSaveSearch="true" ShowSearchTabs="false" ShowSearchViews="false" ShowDuplicateSearch="false" Visible="<%# !PrintView %>" Runat="Server" />
	</div>
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Center">
				<ItemTemplate>
					<SplendidCRM:DynamicImage ImageSkinID='<%# Eval("ACTIVITY_TYPE") %>' runat="server" />
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="Activities.LBL_LIST_CLOSE" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Center">
				<ItemTemplate>
					<%-- 10/31/2017 Paul.  Provide a way to inject Record level ACL. --%>
					<asp:HyperLink Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, Sql.ToString(Eval("ACTIVITY_TYPE")), "edit", "ASSIGNED_USER_ID") >= 0 %>' NavigateUrl='<%# "~/" + Eval("ACTIVITY_TYPE") + "/edit.aspx?id=" + Eval("ID") + "&Status=Close" %>' Runat="server">
						<asp:Image SkinID="close_inline" AlternateText='<%# L10n.Term("Activities.LBL_LIST_CLOSE") %>' Runat="server" />
					</asp:HyperLink>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn  HeaderText="Activities.LBL_LIST_DATE" SortExpression="DATE_START" ItemStyle-Width="15%" ItemStyle-Wrap="false">
				<ItemTemplate>
					<font class="<%# (Sql.ToDateTime(Eval("DATE_START")) < DateTime.Now) ? "overdueTask" : "futureTask" %>"><%# Sql.ToDateString(T10n.FromServerTime(Sql.ToDateTime(Eval("DATE_START")))) %></font>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="Activities.LBL_ACCEPT_THIS" ItemStyle-Width="5%" ItemStyle-Wrap="false">
				<ItemTemplate>
					<%-- 10/31/2017 Paul.  Provide a way to inject Record level ACL. --%>
					<div style="DISPLAY: <%# String.Compare((Eval("ACCEPT_STATUS") as string), "none", true) == 0 ? "inline" : "none" %>">
						<asp:ImageButton Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, Sql.ToString(Eval("ACTIVITY_TYPE")), "edit", "ASSIGNED_USER_ID") >= 0 %>' CommandName="Activity.Accept"    CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" AlternateText='<%# L10n.Term(".dom_meeting_accept_options.accept"   ) %>' SkinID="accept_inline"    Runat="server" />
						<asp:ImageButton Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, Sql.ToString(Eval("ACTIVITY_TYPE")), "edit", "ASSIGNED_USER_ID") >= 0 %>' CommandName="Activity.Tentative" CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" AlternateText='<%# L10n.Term(".dom_meeting_accept_options.tentative") %>' SkinID="tentative_inline" Runat="server" />
						<asp:ImageButton Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, Sql.ToString(Eval("ACTIVITY_TYPE")), "edit", "ASSIGNED_USER_ID") >= 0 %>' CommandName="Activity.Decline"   CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" AlternateText='<%# L10n.Term(".dom_meeting_accept_options.decline"  ) %>' SkinID="decline_inline"   Runat="server" />
					</div>
					<div style="DISPLAY: <%# String.Compare((Eval("ACCEPT_STATUS") as string), "none", true) != 0 ? "inline" : "none" %>">
						<%# L10n.Term(".dom_meeting_accept_status." + Eval("ACCEPT_STATUS")) %>
					</div>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Center" ItemStyle-Wrap="false">
				<ItemTemplate>
					<%-- 10/31/2017 Paul.  Provide a way to inject Record level ACL. --%>
					<asp:HyperLink Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, Sql.ToString(Eval("ACTIVITY_TYPE")), "edit", "ASSIGNED_USER_ID") >= 0 %>' NavigateUrl='<%# "~/" + Sql.ToString(Eval("ACTIVITY_TYPE")) + "/edit.aspx?id=" + Eval("ID") %>' ToolTip='<%# L10n.Term(".LNK_EDIT") %>' Runat="server">
						<asp:Image SkinID="edit_inline" Runat="server" />
					</asp:HyperLink>
					<asp:HyperLink Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, Sql.ToString(Eval("ACTIVITY_TYPE")), "view", "ASSIGNED_USER_ID") >= 0 %>' NavigateUrl='<%# "~/" + Sql.ToString(Eval("ACTIVITY_TYPE")) + "/view.aspx?id=" + Eval("ID") %>' ToolTip='<%# L10n.Term(".LNK_VIEW") %>' Runat="server">
						<asp:Image SkinID="view_inline" Runat="server" />
					</asp:HyperLink>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
	<br />
</div>

