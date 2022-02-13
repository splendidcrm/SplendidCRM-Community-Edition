<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.DynamicButtons.ListView" %>
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
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="DynamicButtons" Title=".moduleList.Home" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />

	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabSearchView" runat="server">
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel" Wrap="false">
							<%# L10n.Term("DynamicButtons.LBL_VIEW_NAME") %>&nbsp;&nbsp;
							<asp:DropDownList ID="lstVIEW_NAME" DataValueField="VIEW_NAME" DataTextField="VIEW_NAME" Runat="server" />
							<ajaxToolkit:ListSearchExtender TargetControlID="lstVIEW_NAME" PromptText='<%# L10n.Term(".LBL_TYPE_TO_SEARCH") %>' PromptCssClass="ListSearchExtenderPrompt" runat="server" />
						</asp:TableCell>
						<asp:TableCell HorizontalAlign="Right">
							<asp:Button ID="btnSearch" CommandName="Search" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_SEARCH_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SEARCH_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SEARCH_BUTTON_KEY") %>' Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:Table SkinID="tabFrame" CssClass="h3Row" runat="server">
		<asp:TableRow>
			<asp:TableCell Wrap="false">
				<h3><asp:Image SkinID="h3Arrow" Runat="server" />&nbsp;<asp:Label Text='<%# L10n.Term("DynamicButtons.LBL_LIST_FORM_TITLE") %>' runat="server" /></h3>
			</asp:TableCell>
			<asp:TableCell HorizontalAlign="Right">
				<asp:Button ID="btnExport" Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "export") >= 0 %>' UseSubmitBehavior="false" OnClientClick=<%# "window.open('export.aspx?NAME=' + document.getElementById('" + lstVIEW_NAME.ClientID + "').options[document.getElementById('" + lstVIEW_NAME.ClientID + "').selectedIndex].value, 'ExportSQL','width=1200,height=600,resizable=1,scrollbars=1'); return false;" %> CssClass="button" Text='<%# L10n.Term(".LBL_EXPORT_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_EXPORT_BUTTON_TITLE"  ) %>' Runat="server" />
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
					<asp:TemplateColumn HeaderText="DynamicButtons.LBL_LIST_CONTROL_TEXT" ItemStyle-Width="19%" ItemStyle-CssClass="listViewTdLinkS1" ItemStyle-Wrap="false">
						<ItemTemplate>
							<asp:HyperLink Enabled='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' Text='<%# L10n.Term(Sql.ToString(DataBinder.Eval(Container.DataItem, "CONTROL_TEXT"))) %>' NavigateUrl='<%# "edit.aspx?ID=" + Sql.ToString(DataBinder.Eval(Container.DataItem, "ID")) %>' runat="server" />
						</ItemTemplate>
					</asp:TemplateColumn>
					<asp:BoundColumn     HeaderText="DynamicButtons.LBL_LIST_MODULE_NAME"   DataField="MODULE_NAME"     ItemStyle-Width="10%" />
					<asp:BoundColumn     HeaderText="DynamicButtons.LBL_LIST_CONTROL_TYPE"  DataField="CONTROL_TYPE"    ItemStyle-Width="10%" />
					<asp:BoundColumn     HeaderText="DynamicButtons.LBL_LIST_COMMAND_NAME"  DataField="COMMAND_NAME"    ItemStyle-Width="10%" />
					<asp:BoundColumn     HeaderText="DynamicButtons.LBL_LIST_TEXT_FIELD"    DataField="TEXT_FIELD"      ItemStyle-Width="10%" />
					<asp:BoundColumn     HeaderText="DynamicButtons.LBL_LIST_URL_FORMAT"    DataField="URL_FORMAT"      ItemStyle-Width="30%" />
					<asp:TemplateColumn HeaderText="" ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Right" ItemStyle-Wrap="false" Visible="false">
						<ItemTemplate>
							<asp:ImageButton Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="DynamicButtons.MoveUp"   CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("DynamicButtons.LNK_UP") %>' SkinID="uparrow_inline" Runat="server" />
							<asp:LinkButton  Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="DynamicButtons.MoveUp"   CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term("DynamicButtons.LNK_UP") %>' Runat="server" />
							&nbsp;
							<asp:ImageButton Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="DynamicButtons.MoveDown" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("DynamicButtons.LNK_DOWN") %>' SkinID="downarrow_inline" Runat="server" />
							<asp:LinkButton  Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="DynamicButtons.MoveDown" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term("DynamicButtons.LNK_DOWN") %>' Runat="server" />
						</ItemTemplate>
					</asp:TemplateColumn>
					<asp:BoundColumn    HeaderText="" DataField="CONTROL_INDEX" />
					<asp:TemplateColumn HeaderText="" ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Right" ItemStyle-Wrap="false">
						<ItemTemplate>
							<asp:ImageButton Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="DynamicButtons.Edit"     CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_EDIT") %>' SkinID="edit_inline" Runat="server" />
							<asp:LinkButton  Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 %>' CommandName="DynamicButtons.Edit"     CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_EDIT") %>' Runat="server" />
							&nbsp;
							<asp:ImageButton Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "delete") >= 0 %>' CommandName="DynamicButtons.Delete"   CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_DELETE") %>' SkinID="delete_inline" Runat="server" />
							<asp:LinkButton  Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "delete") >= 0 %>' CommandName="DynamicButtons.Delete"   CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_DELETE") %>' Runat="server" />
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

