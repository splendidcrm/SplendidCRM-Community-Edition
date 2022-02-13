<%@ Control CodeBehind="Users.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Calls.Users" %>
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
<input ID="txtUSER_ID" type="hidden" Runat="server" />
<%-- 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. --%>
<%@ Register TagPrefix="SplendidCRM" Tagname="SubPanelButtons" Src="~/_controls/SubPanelButtons.ascx" %>
<SplendidCRM:SubPanelButtons ID="ctlDynamicButtons" Module="Users" SubPanel="divCallsUsers" Title="Users.LBL_MODULE_NAME" Runat="Server" />

<div id="divCallsUsers" style='<%= "display:" + (CookieValue("divCallsUsers") != "1" ? "inline" : "none") %>'>
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdSubPanelView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn  HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Left" ItemStyle-Wrap="false">
				<ItemTemplate>
					<div style="DISPLAY: <%# Sql.ToGuid(DataBinder.Eval(Container.DataItem, "CALL_ASSIGNED_USER_ID")) != Sql.ToGuid(DataBinder.Eval(Container.DataItem, "USER_ID")) ? "inline" : "none" %>">
						<span onclick="return confirm('<%= L10n.TermJavaScript("Calls.NTC_REMOVE_INVITEE") %>')">
							<%-- 10/08/2017 Paul.  Editing relationships is not allowed in ArchiveView.  --%>
							<%-- 10/31/2017 Paul.  Provide a way to inject Record level ACL. --%>
							<asp:ImageButton Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, "Calls", "remove", "CALL_ASSIGNED_USER_ID") >= 0 && !ArchiveViewExists() %>' CommandName="Users.Remove" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "USER_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_REMOVE") %>' SkinID="delete_inline" Runat="server" />
							<asp:LinkButton  Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, "Calls", "remove", "CALL_ASSIGNED_USER_ID") >= 0 && !ArchiveViewExists() %>' CommandName="Users.Remove" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "USER_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_REMOVE") %>' Runat="server" />
						</span>
					</div>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
</div>

