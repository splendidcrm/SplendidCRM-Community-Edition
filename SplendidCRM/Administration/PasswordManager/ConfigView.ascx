<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ConfigView.ascx.cs" Inherits="SplendidCRM.Administration.PasswordManager.ConfigView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="PasswordManager" Title="Administration.LBL_MANAGE_PASSWORD_TITLE" EnableModuleLabel="false" EnablePrint="false" EnableHelp="true" Runat="Server" />
	
	<p></p>
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabSearchView" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_PREFERRED_PASSWORD_LENGTH") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="PREFERRED_PASSWORD_LENGTH" Size="10" Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_MINIMUM_LOWER_CASE_CHARACTERS") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="MINIMUM_LOWER_CASE_CHARACTERS" Size="10" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_MINIMUM_UPPER_CASE_CHARACTERS") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="MINIMUM_UPPER_CASE_CHARACTERS" Size="10" Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_MINIMUM_NUMERIC_CHARACTERS") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="MINIMUM_NUMERIC_CHARACTERS" Size="10" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_MINIMUM_SYMBOL_CHARACTERS") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="MINIMUM_SYMBOL_CHARACTERS" Size="10" Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_SYMBOL_CHARACTERS") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="top" Wrap="false">
							<asp:TextBox ID="SYMBOL_CHARACTERS" Size="10" Runat="server" />&nbsp;<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_SYMBOL_CHARACTERS_DEFAULT") %>' runat="server" /> !@#$%^&*()&lt;&gt;?~.
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_COMPLEXITY_NUMBER") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="COMPLEXITY_NUMBER" Size="10" Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_HISTORY_MAXIMUM") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="HISTORY_MAXIMUM" Size="10" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_LOGIN_LOCKOUT_COUNT") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="LOGIN_LOCKOUT_COUNT" Size="10" Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("PasswordManager.LBL_EXPIRATION_DAYS") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="EXPIRATION_DAYS" Size="10" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !SplendidDynamic.StackedLayout(this.Page.Theme) && !PrintView %>" ShowRequired="false" Runat="Server" />
</div>
