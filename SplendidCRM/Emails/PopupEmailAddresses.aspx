<%@ Page language="c#" MasterPageFile="~/PopupView.Master" Codebehind="PopupEmailAddresses.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Emails.PopupEmailAddresses" %>
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
<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="Emails" IsPopupSearch="true" ShowSearchTabs="false" Visible="<%# !PrintView %>" Runat="Server" />

<script type="text/javascript">
function SelectContact(sCONTACT_ID, sCONTACT_NAME, sCONTACT_EMAIL)
{
	if ( window.opener != null && window.opener.ChangeContactEmail != null )
	{
		window.opener.ChangeContactEmail(sCONTACT_ID, sCONTACT_NAME, sCONTACT_EMAIL);
		window.close();
	}
	else
	{
		alert('Original window has closed.  Contact cannot be assigned.' + '\n' + sPARENT_ID + '\n' + sPARENT_NAME);
	}
}
function Clear()
{
	// 11/20/2005 Paul.  Clear does nothing on SugarCRM 3.5.1. 
	if ( window.opener != null && window.opener.ChangeContactEmail != null )
	{
		window.opener.ChangeContactEmail('', '', '');
		window.close();
	}
	else
	{
		alert('Original window has closed.  Contact cannot be assigned.');
	}
}
function Cancel()
{
	window.close();
}
</script>
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Contacts.LBL_LIST_FORM_TITLE" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Runat="Server" />
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdPopupView" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="Contacts.LBL_LIST_NAME" SortExpression="NAME" ItemStyle-Width="30%">
				<ItemTemplate>
					<a name="CONTACT_ID" id="CONTACT_ID_<%# DataBinder.Eval(Container.DataItem, "ID") %>" class="listViewTdLinkS1" href="#" onclick="SelectContact('<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "ID"))) %>', '<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "NAME"))) %>', '<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "EMAIL1"))) %>');"><%# DataBinder.Eval(Container.DataItem, "NAME") %></a>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="Contacts.LBL_LIST_EMAIL_ADDRESS" SortExpression="EMAIL1" ItemStyle-Width="20%">
				<ItemTemplate>
					<a name="CONTACT_ID_EMAIL" id="CONTACT_ID_EMAIL_<%# DataBinder.Eval(Container.DataItem, "ID") %>" class="listViewTdLinkS1" href="#" onclick="SelectContact('<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "ID"))) %>', '<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "NAME"))) %>', '<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "EMAIL1"))) %>');"><%# DataBinder.Eval(Container.DataItem, "EMAIL1") %></a>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="Contacts.LBL_LIST_EMAIL_ADDRESS" SortExpression="EMAIL2" ItemStyle-Width="20%">
				<ItemTemplate>
					<a name="CONTACT_ID_EMAIL" id="CONTACT_ID_EMAIL_<%# DataBinder.Eval(Container.DataItem, "ID") %>" class="listViewTdLinkS1" href="#" onclick="SelectContact('<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "ID"))) %>', '<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "NAME"))) %>', '<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "EMAIL2"))) %>');"><%# DataBinder.Eval(Container.DataItem, "EMAIL2") %></a>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:BoundColumn    HeaderText="Contacts.LBL_LIST_ACCOUNT_NAME"  DataField="ACCOUNT_NAME"     SortExpression="ACCOUNT_NAME" ItemStyle-Width="20%" />
			<asp:TemplateColumn HeaderText="Emails.LBL_LIST_TYPE"                                         SortExpression="ADDRESS_TYPE" ItemStyle-Width="10%">
				<ItemTemplate>
					<%# L10n.Term(".moduleListSingular.", DataBinder.Eval(Container.DataItem, "ADDRESS_TYPE")) %>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</asp:Content>

