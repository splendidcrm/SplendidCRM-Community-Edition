<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.RenameTabs.ListView" %>
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
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="Administration" Title="Administration.LBL_RENAME_TABS" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>

	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchBasic" Src="SearchBasic.ascx" %>
	<SplendidCRM:SearchBasic ID="ctlSearch" Runat="Server" />
	<br />
	<SplendidCRM:ListHeader ID="ctlListHeader" Title="Administration.LBL_EDIT_TABS" Visible="false" Runat="Server" />
	
	<script type="text/javascript">
	function EditItem(sKEY, sVALUE)
	{
		window.open('Popup.aspx?key=' + escape(sKEY) + '&value=' + escape(sVALUE), 'RenameTabsPopup',' width=600,height=70,resizable=1,scrollbars=1');
	}
	function ChangeItem(sKEY, sVALUE)
	{
		document.getElementById('<%= txtRENAME.ClientID %>').value = '1'   ;
		document.getElementById('<%= txtKEY.ClientID    %>').value = sKEY  ;
		document.getElementById('<%= txtVALUE.ClientID  %>').value = sVALUE;
		document.forms[0].submit();
	}
	</script>
	<input ID="txtRENAME" type="hidden" Runat="server" />
	<input ID="txtKEY"    type="hidden" Runat="server" />
	<input ID="txtVALUE"  type="hidden" Runat="server" />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<SplendidCRM:SplendidGrid id="grdMain" AllowPaging="false" AllowSorting="false" EnableViewState="true" runat="server">
		<Columns>
			<asp:BoundColumn HeaderText="Dropdown.LBL_KEY"    DataField="NAME"         ItemStyle-Width="30%" />
			<asp:TemplateColumn HeaderText="Dropdown.LBL_VALUE" ItemStyle-Width="40%">
				<ItemTemplate>
					<%# Server.HtmlEncode(DataBinder.Eval(Container.DataItem, "DISPLAY_NAME") as string) %>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="30%" ItemStyle-HorizontalAlign="Right" ItemStyle-Wrap="false">
				<ItemTemplate>
					<span onclick="EditItem('<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "NAME"))) %>', '<%# Sql.EscapeJavaScript(Sql.ToString(DataBinder.Eval(Container.DataItem, "DISPLAY_NAME"))) %>', <%# DataBinder.Eval(Container.DataItem, "LIST_ORDER") %>);return false;">
						<asp:ImageButton Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="RenameTabs.Edit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_EDIT") %>' SkinID="edit_inline" Runat="server" />
						<asp:LinkButton  Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="RenameTabs.Edit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_EDIT") %>' Runat="server" />
					</span>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

