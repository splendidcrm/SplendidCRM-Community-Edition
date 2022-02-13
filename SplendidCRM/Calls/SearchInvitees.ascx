<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SearchInvitees.ascx.cs" Inherits="SplendidCRM.Calls.SearchInvitees" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divSearchInvitees">
	<br />
	<h5 CssClass="listViewSubHeadS1"><%= L10n.Term("Calls.LBL_ADD_INVITEE") %></h5>
	<asp:Table SkinID="tabSearchForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabSearchView" runat="server">
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel" Wrap="false"><%= L10n.Term("Calls.LBL_FIRST_NAME") %>&nbsp;&nbsp;<asp:TextBox ID="txtFIRST_NAME"   CssClass="dataField" size="10" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel" Wrap="false"><%= L10n.Term("Calls.LBL_LAST_NAME" ) %>&nbsp;&nbsp;<asp:TextBox ID="txtLAST_NAME"    CssClass="dataField" size="10" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel" Wrap="false"><%= L10n.Term("Calls.LBL_EMAIL"     ) %>&nbsp;&nbsp;<asp:TextBox ID="txtEMAIL"        CssClass="dataField" size="15" Runat="server" /></asp:TableCell>
						<asp:TableCell HorizontalAlign="Right">
							<asp:Button ID="btnSearch" CommandName="Search" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_SEARCH_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SEARCH_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SEARCH_BUTTON_KEY") %>' Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<%= Utils.RegisterEnterKeyPress(txtFIRST_NAME.ClientID, btnSearch.ClientID) %>
	<%= Utils.RegisterEnterKeyPress(txtLAST_NAME.ClientID , btnSearch.ClientID) %>
	<%= Utils.RegisterEnterKeyPress(txtEMAIL.ClientID     , btnSearch.ClientID) %>
</div>

