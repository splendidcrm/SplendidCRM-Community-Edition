<%@ Control Language="c#" AutoEventWireup="false" Codebehind="EditView.ascx.cs" Inherits="SplendidCRM.Administration.Shortcuts.EditView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="Shortcuts" EnablePrint="false" HelpName="EditView" EnableHelp="true" Runat="Server" />

	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table ID="tblMain" CssClass="tabEditView" runat="server">
					<asp:TableRow>
						<asp:TableCell width="15%" CssClass="dataLabel"><%= L10n.Term("Shortcuts.LBL_MODULE_NAME") %></asp:TableCell>
						<asp:TableCell width="35%" CssClass="dataField"><asp:DropDownList ID="MODULE_NAME" DataValueField="MODULE_NAME" DataTextField="MODULE_NAME" Runat="server" /></asp:TableCell>
						<asp:TableCell width="15%" CssClass="dataLabel"><%= L10n.Term("Shortcuts.LBL_DISPLAY_NAME") %></asp:TableCell>
						<asp:TableCell width="35%" CssClass="dataField"><asp:TextBox ID="DISPLAY_NAME" MaxLength="150" size="35" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Shortcuts.LBL_RELATIVE_PATH") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="RELATIVE_PATH" MaxLength="255" size="35" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Shortcuts.LBL_IMAGE_NAME") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="IMAGE_NAME" MaxLength="50" size="35" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Shortcuts.LBL_SHORTCUT_ORDER") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="SHORTCUT_ORDER" MaxLength="10" size="25" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Shortcuts.LBL_SHORTCUT_ENABLED") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:CheckBox ID="SHORTCUT_ENABLED" CssClass="checkbox" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Shortcuts.LBL_SHORTCUT_MODULE") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="SHORTCUT_MODULE" DataValueField="MODULE_NAME" DataTextField="MODULE_NAME" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Shortcuts.LBL_SHORTCUT_ACLTYPE") %></asp:TableCell>
						<asp:TableCell CssClass="dataField">
							<asp:DropDownList ID="SHORTCUT_ACLTYPE" Runat="server">
								<asp:ListItem Value="edit"   Text="edit"   />
								<asp:ListItem Value="list"   Text="list"   />
								<asp:ListItem Value="import" Text="import" />
								<asp:ListItem Value="view"   Text="view"   />
							</asp:DropDownList>
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !SplendidDynamic.StackedLayout(this.Page.Theme) && !PrintView %>" ShowRequired="false" Runat="Server" />
</div>

