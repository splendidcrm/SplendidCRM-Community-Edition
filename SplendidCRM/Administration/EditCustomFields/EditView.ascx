<%@ Control Language="c#" AutoEventWireup="false" Codebehind="EditView.ascx.cs" Inherits="SplendidCRM.Administration.EditCustomFields.EditView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="EditCustomFields" Title="EditCustomFields.LBL_MODULE_TITLE" EnableModuleLabel="false" EnablePrint="true" HelpName="EditView" EnableHelp="true" Runat="Server" />

	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabEditView" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel"><%= L10n.Term("EditCustomFields.COLUMN_TITLE_NAME") + ":" %><asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField"><asp:TextBox ID="txtNAME" Enabled="false" Runat="server" /></asp:TableCell>
						<asp:TableCell Width="20%" CssClass="dataLabel">&nbsp;</asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EditCustomFields.COLUMN_TITLE_LABEL") + ":" %><asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtLABEL" Enabled="false" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel">&nbsp;</asp:TableCell>
						<asp:TableCell CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EditCustomFields.COLUMN_TITLE_DATA_TYPE") + ":" %><asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField">
							<asp:DropDownList ID="lstDATA_TYPE" Enabled="false" Runat="server">
								<asp:ListItem Value="varchar">Text</asp:ListItem>
								<asp:ListItem Value="text"   >Text Area</asp:ListItem>
								<asp:ListItem Value="int"    >Integer</asp:ListItem>
								<asp:ListItem Value="float"  >Decimal</asp:ListItem>
								<asp:ListItem Value="bool"   >Checkbox</asp:ListItem>
								<asp:ListItem Value="date"   >Date</asp:ListItem>
								<asp:ListItem Value="enum"   >Dropdown</asp:ListItem>
								<asp:ListItem Value="guid"   >Guid</asp:ListItem>
							</asp:DropDownList>
						</asp:TableCell>
						<asp:TableCell CssClass="dataLabel">&nbsp;</asp:TableCell>
						<asp:TableCell CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trMAX_SIZE" Runat="server">
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EditCustomFields.COLUMN_TITLE_MAX_SIZE") + ":" %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtMAX_SIZE" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel">&nbsp;</asp:TableCell>
						<asp:TableCell CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EditCustomFields.COLUMN_TITLE_REQUIRED_OPTION") + ":" %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:CheckBox ID="chkREQUIRED" CssClass="checkbox" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel">&nbsp;</asp:TableCell>
						<asp:TableCell CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EditCustomFields.COLUMN_TITLE_DEFAULT_VALUE") + ":" %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="txtDEFAULT_VALUE" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel">&nbsp;</asp:TableCell>
						<asp:TableCell CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow Visible="false">
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EditCustomFields.COLUMN_TITLE_AUDIT") + ":" %></asp:TableCell>
						<asp:TableCell><asp:CheckBox ID="chkAUDITED" CssClass="checkbox" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trDROPDOWN_LIST" Visible="false" Runat="server">
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EditCustomFields.LBL_DROPDOWN_LIST") + ":" %></asp:TableCell>
						<asp:TableCell CssClass="dataField">
							<asp:DropDownList ID="lstDROPDOWN_LIST" OnSelectedIndexChanged="lstDROPDOWN_LIST_Changed" DataTextField="LIST_NAME" DataValueField="LIST_NAME" AutoPostBack="true" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trDROPDOWN_LIST_PREVIEW" Visible="false" Runat="server">
						<asp:TableCell ColumnSpan="4" Wrap="false">
							<asp:Table Width="100%" BorderWidth="1" CellPadding="0" CellSpacing="0" runat="server">
								<asp:TableRow>
									<asp:TableCell>
										<asp:DataGrid ID="grdPICK_LIST_VALUES" Width="100%" BorderWidth="0" CellPadding="3" CellSpacing="0" BackColor="white" 
											AutoGenerateColumns="false" AllowPaging="false" AllowSorting="false" EnableViewState="true" runat="server">
											<Columns>
												<asp:BoundColumn  DataField="NAME"         />
												<asp:BoundColumn  DataField="DISPLAY_NAME" />
											</Columns>
										</asp:DataGrid>
									</asp:TableCell>
								</asp:TableRow>
							</asp:Table>
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

