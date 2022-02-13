<%@ Control CodeBehind="EditView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.ModulesArchiveRules.EditView" %>
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
	<asp:UpdatePanel UpdateMode="Conditional" runat="server">
		<ContentTemplate>
			<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
			<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="ModulesArchiveRules" Title=".moduleList.Home" EnablePrint="false" HelpName="Wizard" EnableHelp="true" Runat="Server" />

			<asp:HiddenField ID="hidCURRENT_MODULE" runat="server" />
			<div id="divModulesArchiveRules1">
				<asp:Table SkinID="tabForm" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("ModulesArchiveRules.LBL_NAME") %>' runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:TextBox ID="txtNAME" TabIndex="2" size="35" MaxLength="150" Runat="server" />
							&nbsp;<asp:RequiredFieldValidator ID="reqNAME" ControlToValidate="txtNAME" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("ModulesArchiveRules.LBL_MODULE_NAME") %>' runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:DropDownList ID="lstMODULE" TabIndex="1" DataValueField="MODULE_NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="lstMODULE_Changed" AutoPostBack="true" Runat="server" />
							<asp:Label ID="lblMODULE" runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell VerticalAlign="Top" CssClass="dataLabel"><%= L10n.Term("ModulesArchiveRules.LBL_DESCRIPTION") %></asp:TableCell>
						<asp:TableCell VerticalAlign="Top" CssClass="dataField"><asp:TextBox ID="txtDESCRIPTION" TextMode="MultiLine" Rows="4" Columns="60" runat="server" /></asp:TableCell>
						<asp:TableCell VerticalAlign="Top" CssClass="dataLabel"><%= L10n.Term("ModulesArchiveRules.LBL_STATUS") %> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /></asp:TableCell>
						<asp:TableCell VerticalAlign="Top" CssClass="dataField"><asp:DropDownList ID="lstSTATUS" DataValueField="NAME" DataTextField="DISPLAY_NAME" Runat="server" /></asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</div>
			<div id="divModulesArchiveRules2">
				<%@ Register TagPrefix="SplendidCRM" Tagname="QueryBuilder" Src="~/Reports/QueryBuilder.ascx" %>
				<SplendidCRM:QueryBuilder ID="ctlQueryBuilder" UserSpecific="false" ShowRelated="false" PrimaryKeyOnly="true" ShowModule="false" Runat="Server" />
				<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
				</SplendidCRM:SplendidGrid>
			</div>
			<div id="divModulesArchiveRules4">
				<asp:Label ID="lblStatus"         Font-Bold="true" runat="server" /><br />
				<br />
				<SplendidCRM:SplendidGrid id="grdResults" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
					<Columns>
						<asp:BoundColumn HeaderText="ModulesArchiveRules.LBL_LIST_IMPORT_ROW_NUMBER" DataField="IMPORT_ROW_NUMBER"  SortExpression="IMPORT_ROW_NUMBER" />
						<asp:BoundColumn HeaderText="ModulesArchiveRules.LBL_LIST_IMPORT_ROW_STATUS" DataField="IMPORT_ROW_STATUS"  SortExpression="IMPORT_ROW_STATUS" />
						<asp:BoundColumn HeaderText="ModulesArchiveRules.LBL_LIST_IMPORT_ROW_ERROR"  DataField="IMPORT_ROW_ERROR"   SortExpression="IMPORT_ROW_ERROR"  />
					</Columns>
				</SplendidCRM:SplendidGrid>
			</div>
		</ContentTemplate>
	</asp:UpdatePanel>
</div>
