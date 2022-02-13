<%@ Control CodeBehind="PopupDashletsView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Home.PopupDashletsView" %>
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
<div id="divPopupDashlets">
	<script type="text/javascript">
	function SelectDashlet(sPARENT_ID, sPARENT_NAME)
	{
		if ( window.opener != null && window.opener.ChangeDashlet != null )
		{
			window.opener.ChangeDashlet(sPARENT_ID, sPARENT_NAME);
			window.close();
		}
		else
		{
			alert('Original window has closed.  Dashlet cannot be assigned.' + '\n' + sPARENT_ID + '\n' + sPARENT_NAME);
		}
	}
	function SelectChecked()
	{
		if ( window.opener != null && window.opener.ChangeDashlet != null )
		{
			var sSelectedItems = document.getElementById('<%= ctlCheckAll.SelectedItems.ClientID %>').value;
			window.opener.ChangeDashlet(sSelectedItems, '');
			window.close();
		}
		else
		{
			alert('Original window has closed.  Dashlet cannot be assigned.');
		}
	}
	function Clear()
	{
		if ( window.opener != null && window.opener.ChangeDashlet != null )
		{
			window.opener.ChangeDashlet('', '');
			window.close();
		}
		else
		{
			alert('Original window has closed.  Dashlet cannot be assigned.');
		}
	}
	function Cancel()
	{
		window.close();
	}
	</script>
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Home.LBL_ADD_DASHLETS" Runat="Server" />

	<asp:Button Text='<%# L10n.Term(".LBL_SELECT_CHECKED_BUTTON_LABEL") %>' UseSubmitBehavior="false" OnClientClick="SelectChecked(); return false;" runat="server" />
	<asp:Button Text='<%# L10n.Term(".LBL_DONE_BUTTON_LABEL"          ) %>' UseSubmitBehavior="false" OnClientClick="Cancel(); return false;"        runat="server" />

	<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />

	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdPopupView" EnableViewState="true" PageSize="100" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="2%">
				<ItemTemplate><%# grdMain.InputCheckbox(!PrintView && bMultiSelect, ctlCheckAll.FieldName, Sql.ToGuid(Eval("ID")), ctlCheckAll.SelectedItems) %></ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="Dashlets.LBL_LIST_TITLE" ItemStyle-Width="25%">
				<ItemTemplate>
					<a id="DASHLET_ID_TITLE_<%# DataBinder.Eval(Container.DataItem, "ID") %>" class="listViewTdLinkS1" href="#" onclick="SelectDashlet('<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "ID"))) %>', '<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "MODULE_NAME"))) %>');"><%# L10n.Term(Sql.ToString(DataBinder.Eval(Container.DataItem, "TITLE"))) %></a>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="Dashlets.LBL_LIST_MODULE_NAME" ItemStyle-Width="30%" ItemStyle-Wrap="false">
				<ItemTemplate>
					<%# L10n.Term(".moduleList.", Sql.ToString(DataBinder.Eval(Container.DataItem, "MODULE_NAME"))) %>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:BoundColumn DataField="CONTROL_NAME" HeaderText="Dashlets.LBL_LIST_CONTROL_NAME" ItemStyle-Width="25%"></asp:BoundColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
	<%@ Register TagPrefix="SplendidCRM" Tagname="CheckAll" Src="~/_controls/CheckAll.ascx" %>
	<SplendidCRM:CheckAll ID="ctlCheckAll" Visible="<%# !PrintView && bMultiSelect %>" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

