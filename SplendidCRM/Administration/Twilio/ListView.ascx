<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.Twilio.ListView" %>
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
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="Twilio" Title=".moduleList.Home" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />
	
	<table ID="tblMain" width="100%" border="0" cellspacing="0" cellpadding="0" class="tabDetailView" runat="server">
	</table>
	
	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchBasic" Src="SearchBasic.ascx" %>
	<SplendidCRM:SearchBasic ID="ctlSearchBasic" Runat="Server" />
	<asp:Label ID="lblError" ForeColor="Red" EnableViewState="false" Runat="server" />
	
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Module="Twilio" Title="Twilio.LBL_LIST_FORM_TITLE" Runat="Server" />
	
	<asp:DataGrid id="grdMain" Width="100%" CssClass="listView"
		CellPadding="3" CellSpacing="0" border="0"
		AllowPaging="<%# !PrintView %>" AllowSorting="false" 
		AutoGenerateColumns="false" 
		EnableViewState="true" runat="server">
		<ItemStyle            CssClass="oddListRowS1"  />
		<AlternatingItemStyle CssClass="evenListRowS1" />
		<HeaderStyle          CssClass="listViewThS1"  />
		<PagerStyle HorizontalAlign="Right" Mode="NumericPages" PageButtonCount="6" Position="Top" CssClass="listViewPaginationTdS1" PrevPageText="Previous" NextPageText="Next" />
		<Columns>
			<asp:BoundColumn HeaderText="Date Sent" DataField="DateSent" SortExpression="DateSent" ItemStyle-Width="15%" />
			<asp:BoundColumn HeaderText="From"      DataField="From"     SortExpression="From"     ItemStyle-Width="15%" />
			<asp:BoundColumn HeaderText="To"        DataField="To"       SortExpression="To"       ItemStyle-Width="15%" />
			<asp:BoundColumn HeaderText="Status"    DataField="Status"   SortExpression="Status"   ItemStyle-Width="15%" />
			<asp:BoundColumn HeaderText="Body"      DataField="Body"     SortExpression="Body"     ItemStyle-Width="40%" />
		</Columns>
	</asp:DataGrid>
	<br />
</div>
