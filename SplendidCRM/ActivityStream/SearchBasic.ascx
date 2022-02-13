<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SearchBasic.ascx.cs" Inherits="SplendidCRM.ActivityStream.SearchBasic" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divSearch">
	<asp:Table SkinID="tabSearchForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabSearchView" Width="100%" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="10%" CssClass="dataLabel" style="padding: 8px;">
							<asp:ListBox ID="lstSTREAM_ACTION" Rows="3" SelectionMode="Multiple" DataTextField="DISPLAY_NAME" DataValueField="NAME" runat="server" />
						</asp:TableCell>
						<asp:TableCell ID="tdMODULES" Width="10%" CssClass="dataLabel" style="padding: 8px;">
							<asp:ListBox ID="lstMODULES" Rows="3" SelectionMode="Multiple" DataTextField="DISPLAY_NAME" DataValueField="MODULE_NAME" runat="server" />
						</asp:TableCell>
						<asp:TableCell ID="tdNAME" Width="75%" CssClass="dataLabel" style="padding: 8px;" runat="server">
							<asp:TextBox ID="txtNAME" CssClass="dataField" Width="97%" Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="5%" style="padding: 8px;">
							<asp:Button ID="btnSearch" CommandName="Search" OnCommand="Page_Command" CssClass="EditHeaderOtherButton" Text='<%# L10n.Term(".LBL_SEARCH_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SEARCH_BUTTON_TITLE") %>' Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<%= Utils.RegisterEnterKeyPress(txtNAME.ClientID, btnSearch.ClientID) %>
</div>
