<%@ Control CodeBehind="ArrangeDashlets.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Home.ArrangeDashlets" %>
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
<script type="text/javascript">
function ChangeDashlet_<%= DetailViewClientName %>(sPARENT_ID, sPARENT_NAME)
{
	document.getElementById('<%= txtDASHLET_ID.ClientID %>').value = sPARENT_ID  ;
	document.forms[0].submit();
}

function DashletsPopup_<%= DetailViewClientName %>()
{
	ChangeDashlet = ChangeDashlet_<%= sDetailView.Replace('.', '_') %>;
	window.open('<%= Application["rootURL"] %>Home/PopupDashlets.aspx?Category=<%= HttpUtility.UrlEncode(sCategory) %>','PopupDashlets','<%= SplendidCRM.Crm.Config.PopupWindowOptions() %>');
}
</script>
</script>
	<asp:HiddenField ID="txtDASHLET_ID" runat="server" />
	<asp:Button Text='<%# L10n.Term("Home.LBL_ADD_DASHLETS") %>' UseSubmitBehavior="false" OnClientClick='<%# "DashletsPopup_" + DetailViewClientName + "(); return false;" %>' runat="server" />
	<asp:UpdatePanel UpdateMode="Conditional" runat="server">
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
					<asp:TemplateColumn HeaderText="Dashlets.LBL_LIST_TITLE"                               ItemStyle-Width="30%" ItemStyle-Wrap="false">
						<ItemTemplate>
							<%# L10n.Term(Sql.ToString(Eval("TITLE"))) %>
						</ItemTemplate>
					</asp:TemplateColumn>
					<asp:BoundColumn    HeaderText="Dashlets.LBL_LIST_MODULE_NAME"  DataField="MODULE_NAME"  ItemStyle-Width="14%" />
					<asp:BoundColumn    HeaderText="Dashlets.LBL_LIST_CONTROL_NAME" DataField="CONTROL_NAME" ItemStyle-Width="25%" />
					<asp:BoundColumn    HeaderText="Dashlets.LBL_LIST_DASHLET_ORDER" DataField="RELATIONSHIP_ORDER" ItemStyle-Width="5%" />
					<asp:TemplateColumn HeaderText="" ItemStyle-Width="10%" ItemStyle-Wrap="false" Visible="false">
						<ItemTemplate>
							<asp:ImageButton CommandName="Dashlets.MoveUp"   Visible='<%#  Sql.ToBoolean(Eval("DASHLET_ENABLED")) %>' CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("Dashlets.LNK_UP"  ) %>' SkinID="uparrow_inline" Runat="server" />
							<asp:LinkButton  CommandName="Dashlets.MoveUp"   Visible='<%#  Sql.ToBoolean(Eval("DASHLET_ENABLED")) %>' CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1"          Text='<%# L10n.Term("Dashlets.LNK_UP"  ) %>' Runat="server" />
							&nbsp;
							<asp:ImageButton CommandName="Dashlets.MoveDown" Visible='<%#  Sql.ToBoolean(Eval("DASHLET_ENABLED")) %>' CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("Dashlets.LNK_DOWN") %>' SkinID="downarrow_inline" Runat="server" />
							<asp:LinkButton  CommandName="Dashlets.MoveDown" Visible='<%#  Sql.ToBoolean(Eval("DASHLET_ENABLED")) %>' CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1"          Text='<%# L10n.Term("Dashlets.LNK_DOWN") %>' Runat="server" />
						</ItemTemplate>
					</asp:TemplateColumn>
					<asp:TemplateColumn HeaderText="Dashlets.LBL_LIST_DASHLET_ENABLED" ItemStyle-Width="5%" ItemStyle-Wrap="false">
						<ItemTemplate>
							<asp:Label Visible='<%#  Sql.ToBoolean(Eval("DASHLET_ENABLED")) %>' Text='<%# L10n.Term(".LBL_YES") %>' Runat="server" />
							<asp:Label Visible='<%# !Sql.ToBoolean(Eval("DASHLET_ENABLED")) %>' Text='<%# L10n.Term(".LBL_NO" ) %>' Runat="server" />
						</ItemTemplate>
					</asp:TemplateColumn>
					<asp:TemplateColumn HeaderText="" ItemStyle-Width="10%" ItemStyle-Wrap="false">
						<ItemTemplate>
							<asp:ImageButton CommandName="Dashlets.Disable"  Visible='<%#  Sql.ToBoolean(Eval("DASHLET_ENABLED")) %>' CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("Dashlets.LNK_DISABLE") %>' SkinID="minus_inline" Runat="server" />
							<asp:LinkButton  CommandName="Dashlets.Disable"  Visible='<%#  Sql.ToBoolean(Eval("DASHLET_ENABLED")) %>' CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1"          Text='<%# L10n.Term("Dashlets.LNK_DISABLE") %>' Runat="server" />
							<asp:ImageButton CommandName="Dashlets.Enable"   Visible='<%# !Sql.ToBoolean(Eval("DASHLET_ENABLED")) %>' CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("Dashlets.LNK_ENABLE" ) %>' SkinID="plus_inline" Runat="server" />
							<asp:LinkButton  CommandName="Dashlets.Enable"   Visible='<%# !Sql.ToBoolean(Eval("DASHLET_ENABLED")) %>' CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1"          Text='<%# L10n.Term("Dashlets.LNK_ENABLE" ) %>' Runat="server" />
						</ItemTemplate>
					</asp:TemplateColumn>
					<asp:TemplateColumn  HeaderText="" ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Left" ItemStyle-Wrap="false">
						<ItemTemplate>
							<asp:ImageButton CommandName="Dashlets.Delete" CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_DELETE") %>' SkinID="delete_inline" Runat="server" />
							<asp:LinkButton  CommandName="Dashlets.Delete" CommandArgument='<%# Eval("ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1"          Text='<%# L10n.Term(".LNK_DELETE") %>' Runat="server" />
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
</div>

