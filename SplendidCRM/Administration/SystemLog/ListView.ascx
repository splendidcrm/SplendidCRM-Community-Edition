<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.SystemLog.ListView" %>
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
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="SystemLog" Title="Administration.LBL_SYSTEM_LOG_TITLE" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="SystemLog" ShowSearchTabs="false" ShowSearchViews="false" Visible="<%# !PrintView %>" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="ExportHeader" Src="~/_controls/ExportHeader.ascx" %>
	<SplendidCRM:ExportHeader ID="ctlExportHeader" Module="Administration" Title="" Runat="Server" />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" OnItemCreated="grdMain_OnItemCreated" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:BoundColumn    HeaderText=".LBL_LIST_DATE_ENTERED"              DataField="DATE_ENTERED"     SortExpression="DATE_ENTERED"     ItemStyle-VerticalAlign="Top" ItemStyle-Wrap="false" />
			<asp:BoundColumn    HeaderText="SystemLog.LBL_LIST_USER_ID"          DataField="USER_ID"          SortExpression="USER_ID"          ItemStyle-VerticalAlign="Top" Visible="false" />
			<asp:BoundColumn    HeaderText="SystemLog.LBL_LIST_USER_NAME"        DataField="USER_NAME"        SortExpression="USER_NAME"        ItemStyle-VerticalAlign="Top" />
			<asp:BoundColumn    HeaderText="SystemLog.LBL_LIST_MACHINE"          DataField="MACHINE"          SortExpression="MACHINE"          ItemStyle-VerticalAlign="Top" Visible="false" />
			<asp:BoundColumn    HeaderText="SystemLog.LBL_LIST_ASPNET_SESSIONID" DataField="ASPNET_SESSIONID" SortExpression="ASPNET_SESSIONID" ItemStyle-VerticalAlign="Top" Visible="false" />
			<asp:BoundColumn    HeaderText="SystemLog.LBL_LIST_REMOTE_HOST"      DataField="REMOTE_HOST"      SortExpression="REMOTE_HOST"      ItemStyle-VerticalAlign="Top" Visible="false" />
			<asp:BoundColumn    HeaderText="SystemLog.LBL_LIST_SERVER_HOST"      DataField="SERVER_HOST"      SortExpression="SERVER_HOST"      ItemStyle-VerticalAlign="Top" Visible="false" />
			<asp:BoundColumn    HeaderText="SystemLog.LBL_LIST_TARGET"           DataField="TARGET"           SortExpression="TARGET"           ItemStyle-VerticalAlign="Top" Visible="false" />
			<asp:TemplateColumn HeaderText="SystemLog.LBL_LIST_ERROR_TYPE"                                    SortExpression="ERROR_TYPE"       ItemStyle-VerticalAlign="Top">
				<ItemTemplate>
					<div class="<%# (Sql.ToString(Eval("ERROR_TYPE")) == "Error" ? "error" : String.Empty) %>"><%# Eval("ERROR_TYPE") %></div>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="SystemLog.LBL_LIST_MESSAGE"                                       SortExpression="MESSAGE"          ItemStyle-VerticalAlign="Top" ItemStyle-Width="20%">
				<ItemTemplate>
					<div class="<%# (Sql.ToString(Eval("ERROR_TYPE")) == "Error" ? "error" : String.Empty) %>"><%# Eval("MESSAGE") %></div>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="SystemLog.LBL_LIST_FILE_NAME"                                     SortExpression="FILE_NAME"        ItemStyle-VerticalAlign="Top">
				<ItemTemplate><%# Sql.ToString(Eval("FILE_NAME")).Replace("/", "/ ") %></ItemTemplate>
			</asp:TemplateColumn>
			<asp:BoundColumn    HeaderText="SystemLog.LBL_LIST_METHOD"           DataField="METHOD"           SortExpression="METHOD"           ItemStyle-VerticalAlign="Top" />
			<asp:BoundColumn    HeaderText="SystemLog.LBL_LIST_LINE_NUMBER"      DataField="LINE_NUMBER"      SortExpression="LINE_NUMBER"      ItemStyle-VerticalAlign="Top" />
			<asp:TemplateColumn HeaderText="SystemLog.LBL_LIST_RELATIVE_PATH"                                 SortExpression="RELATIVE_PATH"    ItemStyle-VerticalAlign="Top">
				<ItemTemplate><%# Sql.ToString(Eval("RELATIVE_PATH")).Replace("/", "/ ") %></ItemTemplate>
			</asp:TemplateColumn>
			<asp:BoundColumn    HeaderText="SystemLog.LBL_LIST_PARAMETERS"       DataField="PARAMETERS"       SortExpression="PARAMETERS"       ItemStyle-VerticalAlign="Top" />
		</Columns>
	</SplendidCRM:SplendidGrid>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

