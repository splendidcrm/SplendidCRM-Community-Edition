<%@ Control CodeBehind="InviteesView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Calls.InviteesView" %>
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
	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchInvitees" Src="SearchInvitees.ascx" %>
	<SplendidCRM:SearchInvitees ID="ctlSearch" Runat="Server" />
	<br />
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<div id="divInvitees" visible="false" runat="server">
		<SplendidCRM:SplendidGrid id="grdMain" AllowPaging="true" AllowSorting="true" EnableViewState="true" runat="server">
			<Columns>
				<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Center">
					<ItemTemplate>
						<SplendidCRM:DynamicImage ID="DynamicImage1" ImageSkinID='<%# Eval("INVITEE_TYPE") %>' Runat="server" />
					</ItemTemplate>
				</asp:TemplateColumn>
				<asp:BoundColumn    HeaderText="Users.LBL_LIST_NAME"  DataField="NAME"  SortExpression="NAME"  ItemStyle-Width="15%" />
				<asp:TemplateColumn HeaderText="" ItemStyle-Width="50%">
					<ItemTemplate>
						<%@ Register TagPrefix="SplendidCRM" Tagname="UserSchedule" Src="~/Activities/UserSchedule.ascx" %>
						<SplendidCRM:UserSchedule ID="ctlUserSchedule" DATE_START='<%# dtDATE_START %>' DATE_END='<%# dtDATE_END %>' USER_ID='<%# Sql.ToString(Eval("INVITEE_TYPE")) == "Users" ? Sql.ToGuid(Eval("ID")) : Guid.Empty %>' Runat="Server" />
					</ItemTemplate>
				</asp:TemplateColumn>
				<asp:BoundColumn    HeaderText="Users.LBL_LIST_EMAIL" DataField="EMAIL" SortExpression="EMAIL" ItemStyle-Width="15%" />
				<asp:BoundColumn    HeaderText="Users.LBL_LIST_PHONE_WORK" DataField="PHONE" SortExpression="PHONE" ItemStyle-Width="15%" />
				<asp:TemplateColumn HeaderText="" ItemStyle-Width="4%" ItemStyle-HorizontalAlign="Center">
					<ItemTemplate>
						<asp:Button ID="Button1" CommandName="Invitees.Add" OnCommand="Page_Command" CommandArgument='<%# Eval("ID") %>' CssClass="button" Text='<%# " " + L10n.Term("Meetings.LBL_ADD_BUTTON") + " " %>' ToolTip='<%# L10n.Term("Meetings.LBL_ADD_BUTTON") %>' Enabled='<%# !IsExistingInvitee(Sql.ToString(Eval("ID"))) %>' Runat="server" />
					</ItemTemplate>
				</asp:TemplateColumn>
			</Columns>
		</SplendidCRM:SplendidGrid>
	</div>
</div>

