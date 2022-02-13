<%@ Control Language="c#" AutoEventWireup="false" Codebehind="DetailButtons.ascx.cs" Inherits="SplendidCRM._controls.DetailButtons" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
<asp:Panel ID="pnlDetailButtons" CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
	<asp:Table ID="tblDetailButtons" Width="100%" CellPadding="0" CellSpacing="0" style="padding-bottom: 2px;" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Button ID="btnEdit"      CommandName="Edit"      OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_EDIT_BUTTON_LABEL"     ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_EDIT_BUTTON_TITLE"     ) %>' AccessKey='<%# L10n.AccessKey(".LBL_EDIT_BUTTON_KEY"     ) %>' Runat="server" />&nbsp;
				<asp:Button ID="btnDuplicate" CommandName="Duplicate" OnCommand="Page_Command" CssClass="button" Text='<%# " "  + L10n.Term(".LBL_DUPLICATE_BUTTON_LABEL") + " "  %>' ToolTip='<%# L10n.Term(".LBL_DUPLICATE_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_DUPLICATE_BUTTON_KEY") %>' Runat="server" />
				<span onclick="return confirm('<%= L10n.TermJavaScript(".NTC_DELETE_CONFIRMATION") %>')">
					<asp:Button ID="btnDelete"    CommandName="Delete"    OnCommand="Page_Command" CssClass="button" Text='<%# " "  + L10n.Term(".LBL_DELETE_BUTTON_LABEL"   ) + " "  %>' ToolTip='<%# L10n.Term(".LBL_DELETE_BUTTON_TITLE"   ) %>' AccessKey='<%# L10n.AccessKey(".LBL_DELETE_BUTTON_KEY"   ) %>' Runat="server" />&nbsp;
				</span>
				<asp:Button ID="btnCancel"    CommandName="Cancel"    OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL"   ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE"   ) %>' AccessKey='<%# L10n.AccessKey(".LBL_CANCEL_BUTTON_KEY"   ) %>' Visible="<%# this.IsMobile %>" Runat="server" />&nbsp;
				<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</asp:Panel>

