<%@ Control CodeBehind="Mailbox.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.InboundEmail.Mailbox" %>
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
<div id="divProductTemplatesProductTemplates">
	<br />
	<%-- 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="SubPanelButtons" Src="~/_controls/SubPanelButtons.ascx" %>
	<SplendidCRM:SubPanelButtons ID="ctlDynamicButtons" Module="InboundEmail" Title="InboundEmail.LBL_MAILBOX_DEFAULT" Runat="Server" />

	<SplendidCRM:SplendidGrid id="grdMain" AllowPaging="true" AllowSorting="true" EnableViewState="true" AutoGenerateColumns="false" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="EmailClient.LBL_LIST_FROM" SortExpression="From" ItemStyle-VerticalAlign="Top" ItemStyle-Width="15%" >
				<ItemTemplate>
					<%# Eval("From") %>
					<span Visible='<%# Sql.ToString(Eval("From")) != Sql.ToString(Eval("Sender")) %>' runat="server"><br /><%# Eval("Sender") %></span>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:BoundColumn HeaderText="EmailClient.LBL_LIST_TO"            DataField="To"           SortExpression="To"           ItemStyle-VerticalAlign="Top" ItemStyle-Width="10%" />
			<asp:BoundColumn HeaderText="EmailClient.LBL_LIST_CC"            DataField="CC"           SortExpression="CC"           ItemStyle-VerticalAlign="Top" ItemStyle-Width="10%" />
			<asp:BoundColumn HeaderText="EmailClient.LBL_LIST_SUBJECT"       DataField="Subject"      SortExpression="Subject"      ItemStyle-VerticalAlign="Top" ItemStyle-Width="25%" />
			<asp:BoundColumn HeaderText="EmailClient.LBL_LIST_DATE_RECEIVED" DataField="DeliveryDate" SortExpression="DeliveryDate" ItemStyle-VerticalAlign="Top" ItemStyle-Width="10%" ItemStyle-Wrap="false" />
			<asp:BoundColumn HeaderText="EmailClient.LBL_LIST_SIZE"          DataField="Size"         SortExpression="Size"         ItemStyle-VerticalAlign="Top" ItemStyle-Width="5%" />
			<asp:BoundColumn HeaderText="EmailClient.LBL_LIST_HEADERS"       DataField="Headers"      SortExpression="Headers"      ItemStyle-VerticalAlign="Top" ItemStyle-Width="25%" />
			<asp:BoundColumn HeaderText="EmailClient.LBL_LIST_PRIORITY"      DataField="Priority"     SortExpression="Priority"     ItemStyle-VerticalAlign="Top" ItemStyle-Width="10%" Visible="false" />
			<asp:BoundColumn HeaderText="EmailClient.LBL_LIST_BCC"           DataField="Bcc"          SortExpression="Bcc"          ItemStyle-VerticalAlign="Top" ItemStyle-Width="10%" Visible="false" />
			<asp:BoundColumn HeaderText="EmailClient.LBL_LIST_MESSAGEID"     DataField="MessageID"    SortExpression="MessageID"    ItemStyle-VerticalAlign="Top" ItemStyle-Width="10%" Visible="false" />
		</Columns>
	</SplendidCRM:SplendidGrid>
</div>

