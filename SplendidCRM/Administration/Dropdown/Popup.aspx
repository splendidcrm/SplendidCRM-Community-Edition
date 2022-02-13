<%@ Page language="c#" MasterPageFile="~/PopupView.Master" Codebehind="Popup.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Administration.Dropdown.Popup" %>
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
<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
<script type="text/javascript">
function ChangeItem()
{
	if ( window.opener != null && window.opener.ChangeItem != null )
	{
		window.opener.ChangeItem(document.getElementById('<%= txtKEY.ClientID %>').value, document.getElementById('<%= txtVALUE.ClientID %>').value, <%= nINDEX %>);
		window.close();
	}
}
function Cancel()
{
	window.close();
}
// 08/30/2006 Paul.  Fix onload to support Firefox. 
window.onload = function()
{
	document.getElementById('<%= txtKEY.ClientID %>').focus();
}
</script>

<asp:Table ID="tblMain" SkinID="tabForm" runat="server">
	<asp:TableRow>
		<asp:TableCell>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="dataLabel" noWrap><asp:Label Text='<%# L10n.Term("Dropdown.LBL_KEY"  ) %>' runat="server" />&nbsp;&nbsp;<asp:TextBox ID="txtKEY"   CssClass="dataField" Runat="server" /></td>
					<td class="dataLabel" noWrap><asp:Label Text='<%# L10n.Term("Dropdown.LBL_VALUE") %>' runat="server" />&nbsp;&nbsp;<asp:TextBox ID="txtVALUE" CssClass="dataField" Runat="server" /></td>
					<td align="right">
						<asp:Button ID="btnPopupSelect" OnClientClick="ChangeItem(); return false;" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SAVE_BUTTON_LABEL"  ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_SAVE_BUTTON_LABEL"  ) %>' AccessKey='<%# L10n.AccessKey(".LBL_SAVE_BUTTON_KEY"  ) %>' runat="server" />
						<asp:Button ID="btnPopupCancel" OnClientClick="Cancel(); return false;"     CssClass="button" Text='<%# "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_CANCEL_BUTTON_KEY") %>' runat="server" />
					</td>
				</tr>
			</table>
		</asp:TableCell>
	</asp:TableRow>
</asp:Table>
</asp:Content>

