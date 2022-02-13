<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ConfigView.ascx.cs" Inherits="SplendidCRM.Administration.FullTextSearch.ConfigView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="FullTextSearch" Title="FullTextSearch.LBL_FULLTEXTSEARCH_SETTINGS" EnableModuleLabel="false" EnablePrint="false" EnableHelp="true" Runat="Server" />
	
	<p></p>
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_FULLTEXT_SUPPORTED") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label ID="FULLTEXT_SUPPORTED" Text='<%# L10n.Term(".LBL_NO") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell ColumnSpan="2" CssClass="dataField" VerticalAlign="Middle">
				<asp:Label ID="SUPPORTED_INSTRUCTIONS" Text='<%# L10n.Term("FullTextSearch.LBL_SUPPORTED_INSTRUCTIONS") %>' runat="server" /><br />
				<asp:Label ID="SQL_SERVER_VERSION" runat="server" /><br />
				<asp:Label ID="SQL_SERVER_EDITION" runat="server" /><br />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_FULLTEXT_INSTALLED") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label ID="FULLTEXT_INSTALLED" Text='<%# L10n.Term(".LBL_NO") %>' Runat="server" />
			</asp:TableCell>
			<asp:TableCell ColumnSpan="2" CssClass="dataField" VerticalAlign="Middle">
				<asp:Label ID="INSTALLED_INSTRUCTIONS" Text='<%# L10n.Term("FullTextSearch.LBL_INSTALLED_INSTRUCTIONS") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_OFFICE_SUPPORTED") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label ID="OFFICE_SUPPORTED" Text='<%# L10n.Term(".LBL_NO") %>' Runat="server" />
			</asp:TableCell>
			<asp:TableCell ColumnSpan="2" CssClass="dataField" VerticalAlign="Middle">
				<asp:Label ID="OFFICE_INSTRUCTIONS" Text='<%# L10n.Term("FullTextSearch.LBL_OFFICE_INSTRUCTIONS") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_PDF_SUPPORTED") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label ID="PDF_SUPPORTED" Text='<%# L10n.Term(".LBL_NO") %>' Runat="server" />
			</asp:TableCell>
			<asp:TableCell ColumnSpan="2" CssClass="dataField" VerticalAlign="Middle">
				<asp:Label ID="PDF_INSTRUCTIONS" Text='<%# L10n.Term("FullTextSearch.LBL_PDF_INSTRUCTIONS") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_FULLTEXT_CATALOG_EXISTS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label ID="FULLTEXT_CATALOG_EXISTS" Text='<%# L10n.Term(".LBL_NO") %>' Runat="server" />
			</asp:TableCell>
			<asp:TableCell ColumnSpan="2" CssClass="dataField" VerticalAlign="Middle">
				<asp:Label ID="CATALOG_INSTRUCTIONS" Text='<%# L10n.Term("FullTextSearch.LBL_CATALOG_INSTRUCTIONS") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_SUPPORTED_DOCUMENT_TYPES") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
				<asp:TextBox ID="DOCUMENT_TYPES" TextMode="MultiLine" Rows="6" ReadOnly="true" Columns="10" runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_INDEXED_TABLES") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
				<asp:TextBox ID="INDEXED_TABLES" TextMode="MultiLine" Rows="6" ReadOnly="true" Columns="30" runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_POPULATION_STATUS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label ID="POPULATION_STATUS" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_POPULATION_COUNT") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label ID="POPULATION_COUNT" Runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_LAST_POPULATION_DATE") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
				<asp:Label ID="LAST_POPULATION_DATE" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="top">
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="dataField" VerticalAlign="top">
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
</div>
