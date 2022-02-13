<%@ Control Language="c#" AutoEventWireup="false" Codebehind="EditView.ascx.cs" Inherits="SplendidCRM.Contacts.EditView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divEditView" runat="server">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="Contacts" EnablePrint="false" HelpName="EditView" EnableHelp="true" Runat="Server" />

	<asp:HiddenField ID="LAYOUT_EDIT_VIEW" Runat="server" />
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<%-- 03/19/2020 Paul.  Move header to layout. --%>
				<table ID="tblMain" class="tabEditView" runat="server">
				</table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:Button ID="ACCOUNT_UPDATE" Text="ACCOUNT_UPDATE" style="display: none" runat="server" />
	<asp:Panel visible='<%# Sql.ToBoolean(Application["CONFIG.portal_on"]) %>' runat="server">
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table ID="tblPortal" class="tabEditView" runat="server">
					<asp:TableRow>
						<asp:TableHeaderCell ColumnSpan="4"><h4><asp:Label Text='<%# L10n.Term("Contacts.LBL_PORTAL_INFORMATION") %>' runat="server" /></h4></asp:TableHeaderCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="top"><asp:Label Text='<%# L10n.Term("Contacts.LBL_PORTAL_NAME") %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="PORTAL_NAME" size="32" MaxLength="255" runat="server" />
							&nbsp;<asp:RequiredFieldValidator ID="PORTAL_NAME_REQUIRED" ControlToValidate="PORTAL_NAME" CssClass="required" Display="Dynamic" Enabled="false" EnableClientScript="false" EnableViewState="false" runat="server" />
						</asp:TableCell>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="top"><asp:Label Text='<%# L10n.Term("Contacts.LBL_PORTAL_ACTIVE") %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="top"><asp:CheckBox ID="PORTAL_ACTIVE" CssClass="checkbox" runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="top"><asp:Label Text='<%# L10n.Term("Contacts.LBL_PORTAL_PASSWORD") %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="PORTAL_PASSWORD" size="32" MaxLength="32" TextMode="Password" runat="server" />
							&nbsp;<asp:RequiredFieldValidator ID="PORTAL_PASSWORD_REQUIRED" ControlToValidate="PORTAL_PASSWORD" CssClass="required" Display="Dynamic" Enabled="false" EnableClientScript="false" EnableViewState="false" runat="server" />
						</asp:TableCell>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="top"><asp:Label Text='<%# L10n.Term("Contacts.LBL_CONFIRM_PORTAL_PASSWORD") %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="PORTAL_PASSWORD_CONFIRM" size="32" MaxLength="32" TextMode="Password" runat="server" />
							&nbsp;<asp:RequiredFieldValidator ID="PORTAL_PASSWORD_CONFIRM_REQUIRED" ControlToValidate="PORTAL_PASSWORD_CONFIRM" CssClass="required" Display="Dynamic" Enabled="false" EnableClientScript="false" EnableViewState="false" runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	</asp:Panel>

	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !SplendidDynamic.StackedLayout(this.Page.Theme) && !PrintView %>" ShowRequired="false" Runat="Server" />

	<div id="divEditSubPanel">
		<asp:PlaceHolder ID="plcSubPanel" Runat="server" />
	</div>
</div>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

