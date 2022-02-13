<%@ Control CodeBehind="Tasks.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Calendar.Tasks" %>
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
<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
<SplendidCRM:ListHeader SubPanel="divCalendarTasks" Title="Tasks.LBL_LIST_FORM_TITLE" Runat="Server" />

<div id="divCalendarTasks" style='<%= "display:" + (CookieValue("divCalendarTasks") != "1" ? "inline" : "none") %>'>
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:HyperLinkColumn HeaderText="Tasks.LBL_LIST_STATUS"     DataTextField="STATUS"       SortExpression="STATUS"       ItemStyle-Width="30%" ItemStyle-Wrap="false" />
			<asp:HyperLinkColumn HeaderText="Tasks.LBL_LIST_SUBJECT"    DataTextField="NAME"         SortExpression="NAME"         ItemStyle-Width="60%" ItemStyle-CssClass="listViewTdLinkS1" DataNavigateUrlField="ID"         DataNavigateUrlFormatString="~/Tasks/view.aspx?id={0}" />
			<asp:TemplateColumn  HeaderText="Tasks.LBL_LIST_DUE_DATE"                                SortExpression="DATE_DUE"     ItemStyle-Width="10%">
				<ItemTemplate>
					<%# Sql.ToDateString(T10n.FromServerTime(DataBinder.Eval(Container.DataItem, "DATE_DUE"))) %>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
</div>

