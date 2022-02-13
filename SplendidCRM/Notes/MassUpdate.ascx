<%@ Control Language="c#" AutoEventWireup="false" Codebehind="MassUpdate.ascx.cs" Inherits="SplendidCRM.Notes.MassUpdate" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<%-- 06/06/2015 Paul.  MassUpdateButtons combines ListHeader and DynamicButtons. --%>
<%@ Register TagPrefix="SplendidCRM" Tagname="MassUpdateButtons" Src="~/_controls/MassUpdateButtons.ascx" %>
<SplendidCRM:MassUpdateButtons ID="ctlDynamicButtons" SubPanel="divNotesMassUpdate" Title=".LBL_MASS_UPDATE_TITLE" Runat="Server" />

<%-- 03/26/2018 Paul.  Hide mass update fields in ArchiveView. --%>
<div id="divNotesMassUpdate" style='<%= "display:" + (CookieValue("divNotesMassUpdate") != "1" && !ArchiveView() ? "inline" : "none") %>'>
	<asp:Table Width="100%" CellPadding="0" CellSpacing="0" CssClass="tabForm tabMassUpdate" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<%@ Register TagPrefix="SplendidCRM" Tagname="TeamAssignedMassUpdate" Src="~/_controls/TeamAssignedMassUpdate.ascx" %>
				<SplendidCRM:TeamAssignedMassUpdate ID="ctlTeamAssignedMassUpdate" ShowAssigned="false" Runat="Server" />
				<asp:Table Width="100%" CellPadding="0" CellSpacing="0" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:DropDownList ID="lstPARENT_TYPE" DataValueField="NAME" DataTextField="DISPLAY_NAME" onChange=<%# "ClearModuleType('', '" + txtPARENT_ID.ClientID + "', '" + txtPARENT_NAME.ClientID + "', false);" %> Runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:TextBox     ID="txtPARENT_NAME" ReadOnly="True" Runat="server" />
							<asp:HiddenField ID="txtPARENT_ID" runat="server" />&nbsp;
							<asp:Button      ID="btnPARENT_ID" UseSubmitBehavior="false" OnClientClick=<%# "return ModulePopup(document.getElementById('" + lstPARENT_TYPE.ClientID + "').options[document.getElementById('" + lstPARENT_TYPE.ClientID + "').options.selectedIndex].value, '" + txtPARENT_ID.ClientID + "', '" + txtPARENT_NAME.ClientID + "', null, false, null);" %> Text='<%# L10n.Term(".LBL_CHANGE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CHANGE_BUTTON_TITLE") %>' CssClass="button" runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Contacts.LBL_CONTACT") %>' runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:TextBox     ID="txtCONTACT_NAME" ReadOnly="True" Runat="server" />
							<asp:HiddenField ID="txtCONTACT_ID" runat="server" />&nbsp;
							<asp:Button      ID="btnCONTACT_ID" UseSubmitBehavior="false" OnClientClick=<%# "return ModulePopup('Contacts', '" + txtCONTACT_ID.ClientID + "', '" + txtCONTACT_NAME.ClientID + "', null, false, null);" %> Text='<%# L10n.Term(".LBL_CHANGE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CHANGE_BUTTON_TITLE") %>' CssClass="button" runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

