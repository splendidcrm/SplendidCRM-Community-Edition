<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SearchButtons.ascx.cs" Inherits="SplendidCRM._controls.SearchButtons" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
// 07/28/2010 Paul.  Must set the CellSpacing to 1 in order to get the padding to work.  Otherwise, border-collapse will be sent by the table. 
</script>
<asp:Panel ID="pnlSearchButtons" CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
	<asp:Table ID="tblSearchButtons" Width="100%" CellPadding="0" CellSpacing="1" style="padding-top: 4px;" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Button ID="btnSearch" CommandName="Search" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_SEARCH_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SEARCH_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SEARCH_BUTTON_KEY") %>' Runat="server" />&nbsp;
				<asp:Button ID="btnClear"  CommandName="Clear"  OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_CLEAR_BUTTON_LABEL" ) %>' ToolTip='<%# L10n.Term(".LBL_CLEAR_BUTTON_TITLE" ) %>' AccessKey='<%# L10n.AccessKey(".LBL_CLEAR_BUTTON_KEY" ) %>' Runat="server" />
				<asp:Label CssClass="white-space" Text="&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;" Visible="false" runat="server" />
				<asp:Label Font-Bold="true" Text='<%# L10n.Term(".LBL_SAVED_SEARCH_SHORTCUT" ) %>' Visible="false" runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</asp:Panel>

