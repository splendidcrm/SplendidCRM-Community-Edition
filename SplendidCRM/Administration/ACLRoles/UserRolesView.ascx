<%@ Control CodeBehind="UserRolesView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.ACLRoles.UserRolesView" %>
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
<script type="text/javascript">
function ChangeRole(sPARENT_ID, sPARENT_NAME)
{
	document.getElementById('<%= txtROLE_ID.ClientID   %>').value = sPARENT_ID  ;
	document.forms[0].submit();
}
function RoleMultiSelect()
{
	return window.open('PopupMultiSelect.aspx', 'RolePopup', '<%= SplendidCRM.Crm.Config.PopupWindowOptions() %>');
}
</script>
<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
<SplendidCRM:ListHeader Visible="<%# !PrintView %>" Title="ACLRoles.LBL_SEARCH_FORM_TITLE" Runat="Server" />
<div id="divSearch">
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabSearchView" runat="server">
					<asp:TableRow>
						<asp:TableCell width="20%" CssClass="dataLabel"><%= L10n.Term(".LBL_ASSIGNED_TO") %></asp:TableCell>
						<asp:TableCell width="70%" CssClass="dataField"><asp:DropDownList ID="lstUSERS" DataValueField="ID" DataTextField="USER_NAME" TabIndex="1" AutoPostBack="True" Runat="server" /></asp:TableCell>
						<asp:TableCell width="10%" CssClass="dataLabel" HorizontalAlign="Right" Wrap="false">
							<asp:Button ID="btnSearch" CommandName="Search" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_SEARCH_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SEARCH_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SEARCH_BUTTON_KEY") %>' Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>
<br />

<div id="divAccessRights">
	<%@ Register TagPrefix="SplendidCRM" Tagname="AccessView" Src="AccessView.ascx" %>
	<SplendidCRM:AccessView ID="ctlAccessView" EnableACLEditing="false" Runat="Server" />
</div>

<div id="divUsersRoles">
	<input ID="txtROLE_ID" type="hidden" Runat="server" />
	<br />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Button ID="btnSelectRole" UseSubmitBehavior="false" OnClientClick="RoleMultiSelect(); return false;" CssClass="button" Text='<%# L10n.Term(".LBL_SELECT_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SELECT_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SELECT_BUTTON_KEY") %>' Runat="server" />
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>

	<SplendidCRM:SplendidGrid id="grdMain" AllowPaging="false" AllowSorting="false" EnableViewState="true" runat="server">
		<Columns>
			<asp:HyperLinkColumn HeaderText="ACLRoles.LBL_NAME"        DataTextField="ROLE_NAME" ItemStyle-Width="60%" ItemStyle-CssClass="listViewTdLinkS1" DataNavigateUrlField="ROLE_ID" DataNavigateUrlFormatString="~/Administration/ACLRoles/view.aspx?id={0}" />
			<asp:BoundColumn     HeaderText="ACLRoles.LBL_DESCRIPTION" DataField="DESCRIPTION"   ItemStyle-Width="30%" />
			<asp:TemplateColumn  HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Left" ItemStyle-Wrap="false">
				<ItemTemplate>
					<asp:ImageButton CommandName="Roles.Edit"   CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ROLE_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" SkinID="edit_inline" AlternateText='<%# L10n.Term(".LNK_EDIT") %>' Runat="server" />
					<asp:LinkButton  CommandName="Roles.Edit"   CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ROLE_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Runat="server"><%# L10n.Term(".LNK_EDIT") %></asp:LinkButton>
					&nbsp;
					<asp:ImageButton CommandName="Roles.Remove" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ROLE_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_REMOVE") %>' SkinID="delete_inline" Runat="server" />
					<asp:LinkButton  CommandName="Roles.Remove" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ROLE_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_REMOVE") %>' Runat="server" />
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

