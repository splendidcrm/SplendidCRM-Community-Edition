<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.Backups.ListView" %>
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
<div id="divListView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="Administration" Title="Administration.LBL_BACKUPS_TITLE" EnablePrint="false" HelpName="Backups" EnableHelp="true" Runat="Server" />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>

	<asp:Table CellPadding="0" CellSpacing="0" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<%= L10n.Term("Administration.LBL_BACKUP_DATABASE_INSTRUCTIONS") %>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<br />
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table CellPadding="0" CellSpacing="0" runat="server">
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Administration.LBL_BACKUP_FILENAME") %></asp:TableCell>
						<asp:TableCell CssClass="dataField">
							<asp:TextBox ID="NAME" size="70" MaxLength="255" Runat="server" />&nbsp;
							<asp:RequiredFieldValidator ID="NAME_REQUIRED" ControlToValidate="NAME" ErrorMessage='<%# L10n.Term("Administration.LBL_BACKUP_FILENAME_ERROR") %>' CssClass="required" EnableViewState="false" EnableClientScript="false" Enabled="false" runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<br />
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td align="left" ><asp:Button ID="btnBack" Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "access") >= 0 %>' CommandName="Back" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_BACK_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_BACK_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_BACK_BUTTON_KEY") %>' Enabled="False" Runat="server" /></td>
			<td align="right"><asp:Button ID="btnNext" Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "access") >= 0 %>' CommandName="Next" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_NEXT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_NEXT_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_NEXT_BUTTON_KEY") %>' Runat="server" /></td>
			</td>
		</tr>
	</table>

	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td><asp:Literal ID="lblImportErrors" Runat="server" /></td>
		</tr>
	</table>
</div>

