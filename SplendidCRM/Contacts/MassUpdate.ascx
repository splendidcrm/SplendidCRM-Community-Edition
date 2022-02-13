<%@ Control Language="c#" AutoEventWireup="false" Codebehind="MassUpdate.ascx.cs" Inherits="SplendidCRM.Contacts.MassUpdate" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
function MassUpdateContactPopup()
{
	return ModulePopup('Contacts', '<%= txtREPORTS_TO_ID.ClientID %>', '<%= txtREPORTS_TO_NAME.ClientID %>', null, false, null);
}
function MassUpdateAccountPopup()
{
	return ModulePopup('Accounts', '<%= txtACCOUNT_ID.ClientID %>', '<%= txtACCOUNT_NAME.ClientID %>', null, false, null);
}
</script>
<%-- 06/06/2015 Paul.  MassUpdateButtons combines ListHeader and DynamicButtons. --%>
<%@ Register TagPrefix="SplendidCRM" Tagname="MassUpdateButtons" Src="~/_controls/MassUpdateButtons.ascx" %>
<SplendidCRM:MassUpdateButtons ID="ctlDynamicButtons" SubPanel="divContactsMassUpdate" Title=".LBL_MASS_UPDATE_TITLE" Runat="Server" />

<%-- 03/26/2018 Paul.  Hide mass update fields in ArchiveView. --%>
<div id="divContactsMassUpdate" style='<%= "display:" + (CookieValue("divContactsMassUpdate") != "1" && !ArchiveView() ? "inline" : "none") %>'>
	<asp:Table Width="100%" CellPadding="0" CellSpacing="0" CssClass="tabForm tabMassUpdate" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<%@ Register TagPrefix="SplendidCRM" Tagname="TeamAssignedMassUpdate" Src="~/_controls/TeamAssignedMassUpdate.ascx" %>
				<SplendidCRM:TeamAssignedMassUpdate ID="ctlTeamAssignedMassUpdate" Runat="Server" />
				<asp:Table Width="100%" CellPadding="0" CellSpacing="0" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Contacts.LBL_LEAD_SOURCE") %>' runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField"><asp:DropDownList ID="lstLEAD_SOURCE" DataValueField="NAME" DataTextField="DISPLAY_NAME" Runat="server" /></asp:TableCell>
						<asp:TableCell Width="15%" CssClass="dataLabel">
							<asp:Label Text='<%# L10n.Term("Contacts.LBL_ACCOUNT_NAME") %>' Visible='<%# Sql.ToString(Application["CONFIG.BusinessMode"]) != "B2C" %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:TextBox     ID="txtACCOUNT_NAME" ReadOnly="True" Visible='<%# Sql.ToString(Application["CONFIG.BusinessMode"]) != "B2C" %>' Runat="server" />
							<asp:HiddenField ID="txtACCOUNT_ID" runat="server" />&nbsp;
							<asp:Button      ID="btnACCOUNT_ID" UseSubmitBehavior="false" OnClientClick="return MassUpdateAccountPopup();" Text='<%# L10n.Term(".LBL_CHANGE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CHANGE_BUTTON_TITLE") %>' CssClass="button" Visible='<%# Sql.ToString(Application["CONFIG.BusinessMode"]) != "B2C" %>' runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term(".LBL_TAG_SET_NAME") %>' runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<%@ Register TagPrefix="SplendidCRM" Tagname="TagMassUpdate" Src="~/_controls/TagMassUpdate.ascx" %>
							<SplendidCRM:TagMassUpdate ID="ctlTagMassUpdate" Runat="Server" />
						</asp:TableCell>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Contacts.LBL_REPORTS_TO") %>' runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:TextBox     ID="txtREPORTS_TO_NAME" ReadOnly="True" Runat="server" />
							<asp:HiddenField ID="txtREPORTS_TO_ID" runat="server" />&nbsp;
							<asp:Button      ID="btnREPORTS_TO_ID" UseSubmitBehavior="false" OnClientClick="return MassUpdateContactPopup();" Text='<%# L10n.Term(".LBL_CHANGE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CHANGE_BUTTON_TITLE") %>' CssClass="button" runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

