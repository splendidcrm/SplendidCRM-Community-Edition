<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.Shortcuts.ListView" %>
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
<script type="text/javascript">
function ExportSQL()
{
		return window.open('export.aspx?NAME=<%= sMODULE_NAME %>','ExportSQL','width=1200,height=600,resizable=1,scrollbars=1');
}
</script>
<div id="divListView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="Shortcuts" Title=".moduleList.Home" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="Shortcuts" ShowSearchTabs="false" ShowSearchViews="false" Visible="<%# !PrintView %>" Runat="Server" />

	<asp:Table SkinID="tabFrame" CssClass="h3Row" runat="server">
		<asp:TableRow>
			<asp:TableCell Wrap="false">
				<h3><asp:Image SkinID="h3Arrow" Runat="server" />&nbsp;<asp:Label Text='<%# L10n.Term("Shortcuts.LBL_LIST_FORM_TITLE") %>' runat="server" /></h3>
			</asp:TableCell>
			<asp:TableCell HorizontalAlign="Right">
				<asp:Button ID="btnExport" Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "export") >= 0 %>' UseSubmitBehavior="false" OnClientClick="ExportSQL(); return false;"    CssClass="button" Text='<%# L10n.Term(".LBL_EXPORT_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_EXPORT_BUTTON_TITLE"  ) %>' Runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:UpdatePanel runat="server">
		<ContentTemplate>
			<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
				<asp:HiddenField ID="txtINDEX" Runat="server" />
				<asp:Button ID="btnINDEX_MOVE" ValidationGroup="move" style="display: none" runat="server" />
				<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
			</asp:Panel>
			
			<SplendidCRM:SplendidGrid id="grdMain" AllowPaging="false" AllowSorting="false" EnableViewState="true" runat="server">
				<Columns>
					<asp:TemplateColumn ItemStyle-CssClass="dragHandle">
						<ItemTemplate><asp:Image SkinID="blank" Width="14px" runat="server" /></ItemTemplate>
					</asp:TemplateColumn>
					<asp:BoundColumn     HeaderText="Shortcuts.LBL_LIST_MODULE_NAME"    DataField="MODULE_NAME"      SortExpression="MODULE_NAME"    ItemStyle-Width="14%" />
					<asp:TemplateColumn  HeaderText="Shortcuts.LBL_LIST_DISPLAY_NAME"   SortExpression="DISPLAY_NAME" ItemStyle-Width="35%" ItemStyle-CssClass="listViewTdLinkS1">
						<ItemTemplate>
							<asp:HyperLink Enabled='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' Text='<%# DataBinder.Eval(Container.DataItem, "DISPLAY_NAME") %>' NavigateUrl='<%# "edit.aspx?ID=" + DataBinder.Eval(Container.DataItem, "ID") %>' CssClass="listViewTdLinkS1" Runat="server" />
						</ItemTemplate>
					</asp:TemplateColumn>
					<asp:BoundColumn     HeaderText="Shortcuts.LBL_LIST_RELATIVE_PATH"  DataField="RELATIVE_PATH"    SortExpression="RELATIVE_PATH"  ItemStyle-Width="35%" />
					<asp:BoundColumn    HeaderText="" DataField="SHORTCUT_ORDER" />
					<asp:TemplateColumn HeaderText="" ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Right" ItemStyle-Wrap="false" Visible="false">
						<ItemTemplate>
							<asp:ImageButton Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="Shortcuts.MoveUp"   CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("Shortcuts.LNK_UP") %>' SkinID="uparrow_inline" Runat="server" />
							<asp:LinkButton  Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="Shortcuts.MoveUp"   CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term("Shortcuts.LNK_UP") %>' Runat="server" />
							&nbsp;
							<asp:ImageButton Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="Shortcuts.MoveDown" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("Shortcuts.LNK_DOWN") %>' SkinID="downarrow_inline" Runat="server" />
							<asp:LinkButton  Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="Shortcuts.MoveDown" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term("Shortcuts.LNK_DOWN") %>' Runat="server" />
						</ItemTemplate>
					</asp:TemplateColumn>
					<asp:TemplateColumn HeaderText="" ItemStyle-Width="14%" ItemStyle-HorizontalAlign="Right" ItemStyle-Wrap="false">
						<ItemTemplate>
							<asp:ImageButton Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="Shortcuts.Edit"     CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_EDIT") %>' SkinID="edit_inline" Runat="server" />
							<asp:LinkButton  Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="Shortcuts.Edit"     CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_EDIT") %>' Runat="server" />
							&nbsp;
							<asp:ImageButton Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "delete") >= 0 %>' CommandName="Shortcuts.Delete"   CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_DELETE") %>' SkinID="delete_inline" Runat="server" />
							<asp:LinkButton  Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "delete") >= 0 %>' CommandName="Shortcuts.Delete"   CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_DELETE") %>' Runat="server" />
						</ItemTemplate>
					</asp:TemplateColumn>
				</Columns>
			</SplendidCRM:SplendidGrid>
			
			<SplendidCRM:InlineScript runat="server">
				<script type="text/javascript">
				// http://www.isocra.com/2008/02/table-drag-and-drop-jquery-plugin/
				$(document).ready(function()
				{
					$("#<%= grdMain.ClientID %>").tableDnD
					({
						dragHandle: "dragHandle",
						onDragClass: "jQueryDragBorder",
						onDragStart: function(table, row)
						{
							var txtINDEX = document.getElementById('<%= txtINDEX.ClientID %>');
							txtINDEX.value = (row.parentNode.rowIndex-1);
						},
						onDrop: function(table, row)
						{
							var txtINDEX = document.getElementById('<%= txtINDEX.ClientID %>');
							txtINDEX.value += ',' + (row.rowIndex-1); 
							document.getElementById('<%= btnINDEX_MOVE.ClientID %>').click();
						}
					});
					$("#<%= grdMain.ClientID %> tr").hover
					(
						function()
						{
							if ( !$(this).hasClass("nodrag") )
								$(this.cells[0]).addClass('jQueryDragHandle');
						},
						function()
						{
							if ( !$(this).hasClass("nodrag") )
								$(this.cells[0]).removeClass('jQueryDragHandle');
						}
					);
				});
				</script>
			</SplendidCRM:InlineScript>
		</ContentTemplate>
	</asp:UpdatePanel>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

