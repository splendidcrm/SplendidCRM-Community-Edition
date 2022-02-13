<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.FullTextSearch.ListView" %>
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
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="FullTextSearch" Title=".moduleList.Home" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="FullTextSearch.LBL_SEARCH_FORM_TITLE" Runat="Server" />
	<div id="divSearch">
		<asp:Table SkinID="tabSearchForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<asp:Table SkinID="tabSearchView" Width="100%" runat="server">
						<asp:TableRow>
							<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_TABLE_NAME") %>' runat="server" /></asp:TableCell>
							<asp:TableCell Width="35%" CssClass="dataField"><asp:ListBox ID="lstTABLES" Rows="4" Width="250" runat="server" /></asp:TableCell>
							<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_SEARCH_TEXT") %>' runat="server" /></asp:TableCell>
							<asp:TableCell Width="35%" CssClass="dataField"><asp:TextBox ID="txtSEARCH_TEXT" CssClass="dataField" size="55" Runat="server" /></asp:TableCell>
						</asp:TableRow>
					</asp:Table>
					<%@ Register TagPrefix="SplendidCRM" Tagname="SearchButtons" Src="~/_controls/SearchButtons.ascx" %>
					<SplendidCRM:SearchButtons ID="ctlSearchButtons" Visible="<%# !PrintView %>" Runat="Server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
		<%= Utils.RegisterEnterKeyPress(txtSEARCH_TEXT.ClientID, ctlSearchButtons.SearchClientID) %>
	</div>

	<SplendidCRM:ListHeader Title="FullTextSearch.LBL_LIST_FORM_TITLE" Runat="Server" />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Center">
				<ItemTemplate>
					<SplendidCRM:DynamicImage ImageSkinID='<%# Eval("MODULE_NAME") %>' runat="server" />
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn  HeaderText="FullTextSearch.LBL_LIST_NAME" SortExpression="NAME" ItemStyle-CssClass="listViewTdLinkS1">
				<ItemTemplate>
					<asp:HyperLink Text='<%# Eval("NAME") %>' NavigateUrl='<%# "~/" + Eval("MODULE_NAME") + "/view.aspx?ID=" + Eval("ID") %>' CssClass="listViewTdLinkS1" Runat="server" />
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

