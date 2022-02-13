<%@ Control Language="c#" AutoEventWireup="false" Codebehind="DetailView.ascx.cs" Inherits="SplendidCRM.Administration.CurrencyLayer.DetailView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" Module="CurrencyLayer" Title="CurrencyLayer.LBL_CurrencyLayer_SETTINGS" EnableModuleLabel="false" EnablePrint="false" EnableHelp="true" Runat="Server" />

	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell CssClass="dataLabel" VerticalAlign="top" ColumnSpan="4">
				<asp:Label Text='<%# L10n.Term("CurrencyLayer.LBL_INSTRUCTIONS") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="15%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("CurrencyLayer.LBL_ENABLED") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="35%" CssClass="dataLabel" VerticalAlign="top">
				<asp:CheckBox ID="ENABLED" CssClass="checkbox" Enabled="false" runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="15%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("CurrencyLayer.LBL_LOG_CONVERSIONS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="35%" CssClass="dataLabel" VerticalAlign="top">
				<asp:CheckBox ID="LOG_CONVERSIONS" CssClass="checkbox" Enabled="false" runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="15%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("CurrencyLayer.LBL_RATE_LIFETIME") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="35%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label ID="RATE_LIFETIME" runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="15%" CssClass="dataLabel" VerticalAlign="top">
			</asp:TableCell>
			<asp:TableCell Width="35%" CssClass="dataLabel" VerticalAlign="top">
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<div id="divDetailSubPanel">
		<asp:PlaceHolder ID="plcSubPanel" Runat="server" />
	</div>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>
