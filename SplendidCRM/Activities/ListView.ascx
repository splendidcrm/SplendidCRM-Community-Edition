<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Activities.ListView" %>
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
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="Activities" Title=".moduleList.Home" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="Activities" Visible="<%# !PrintView %>" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="ExportHeader" Src="~/_controls/ExportHeader.ascx" %>
	<SplendidCRM:ExportHeader ID="ctlExportHeader" Module="Activities" Title="Activities.LBL_LIST_FORM_TITLE" Runat="Server" />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<%-- 06/23/2015 Paul.  MassUpdate hover needs to be in column 0. --%>
	<%-- 03/15/2016 Paul.  Make better use of the activities list by showing all.  Activities cannot be udpated en-mass. --%>
	<%-- 05/24/2018 Paul.  Restore checkboxes to allow export. --%>
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" MassUpdateHoverColumn="0" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" Visible="true">
				<ItemTemplate><%# grdMain.InputCheckbox(!PrintView && !IsMobile, ctlCheckAll.FieldName, Sql.ToGuid(Eval("ID")), ctlCheckAll.SelectedItems) %></ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Center" ItemStyle-Wrap="false">
				<ItemTemplate>
					<%-- 10/31/2017 Paul.  Provide a way to inject Record level ACL. --%>
					<SplendidCRM:DynamicImage ImageSkinID='<%# Eval("ACTIVITY_TYPE") %>' runat="server" />
					<asp:HyperLink Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, Sql.ToString(Eval("ACTIVITY_TYPE")), "view", "ASSIGNED_USER_ID") >= 0 %>' NavigateUrl='<%# "~/" + Sql.ToString(Eval("ACTIVITY_TYPE")) + "/view.aspx?id=" + Eval("ID") %>' ToolTip='<%# L10n.Term(".LNK_VIEW") %>' Runat="server">
						<asp:Image SkinID="view_inline" Runat="server" />
					</asp:HyperLink>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
	<%@ Register TagPrefix="SplendidCRM" Tagname="CheckAll" Src="~/_controls/CheckAll.ascx" %>
	<SplendidCRM:CheckAll ID="ctlCheckAll" Visible="<%# true %>" Runat="Server" />
	<%-- 06/06/2015 Paul.  MassUpdateButtons combines ListHeader and DynamicButtons. --%>
	<%-- 03/15/2016 Paul.  Make better use of the activities list by showing all.  Activities cannot be udpated en-mass. --%>
	<asp:Panel ID="pnlMassUpdateSeven" Visible="false" runat="server">
		<%@ Register TagPrefix="SplendidCRM" Tagname="MassUpdate" Src="~/Calls/MassUpdate.ascx" %>
		<SplendidCRM:MassUpdate ID="ctlMassUpdate" Visible="<%# false %>" Runat="Server" />
	</asp:Panel>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

