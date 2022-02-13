<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.EmailMan.ListView" %>
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
function Refresh()
{
	window.location.href = 'default.aspx';
}
function CampaignEmailPreview(gID)
{
	return window.open('Preview.aspx?ID=' + gID, 'CampaignEmailPreview','width=600,height=800,resizable=1,scrollbars=1,status=1');
}
</script>
<div id="divListView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="EmailMan" Title="EmailMan.LBL_MODULE_TITLE" EnableModuleLabel="false" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="Search" Src="SearchBasic.ascx" %>
	<SplendidCRM:Search ID="ctlSearch" Visible="<%# !PrintView %>" Runat="server" />
	<br />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Button CommandName="SendQueued" OnCommand="Page_Command" CssClass="button" Text='<%# " " + L10n.Term(".LBL_CAMPAIGNS_SEND_QUEUED") + " " %>' ToolTip='<%# L10n.Term(".LBL_CAMPAIGNS_SEND_QUEUED") %>' AccessKey='<%# L10n.AccessKey(".LBL_SAVE_BUTTON_KEY") %>' Runat="server" />
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>

	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="EmailMan.LBL_LIST_FORM_TITLE" Runat="Server" />
	
	<%-- 06/23/2015 Paul.  MassUpdate hover needs to be in column 0. --%>
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" MassUpdateHoverColumn="0" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%">
				<ItemTemplate><%# grdMain.InputCheckbox(!PrintView, ctlCheckAll.FieldName, Sql.ToGuid(Eval("ID")), ctlCheckAll.SelectedItems) %></ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-Wrap="false">
				<ItemTemplate>
					<asp:ImageButton Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "view") >= 0 %>' OnClientClick=<%# "CampaignEmailPreview(\'" + DataBinder.Eval(Container.DataItem, "ID") + "\'); return false;" %> CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term("Campaigns.LBL_PREVIEW_BUTTON_LABEL") %>' SkinID="view_inline" Runat="server" />
					<asp:LinkButton  Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "view") >= 0 %>' OnClientClick=<%# "CampaignEmailPreview(\'" + DataBinder.Eval(Container.DataItem, "ID") + "\'); return false;" %> CssClass="listViewTdToolsS1" Text='<%# L10n.Term("Campaigns.LBL_PREVIEW_BUTTON_LABEL") %>' Runat="server" />
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:BoundColumn     HeaderText="EmailMan.LBL_LIST_CAMPAIGN"        DataField="CAMPAIGN_NAME"        SortExpression="CAMPAIGN_NAME"        ItemStyle-Width="10%" />
			<asp:BoundColumn     HeaderText="EmailMan.LBL_LIST_RECIPIENT_NAME"  DataField="RECIPIENT_NAME"       SortExpression="RECIPIENT_NAME"       ItemStyle-Width="10%" />
			<asp:BoundColumn     HeaderText="EmailMan.LBL_LIST_RECIPIENT_EMAIL" DataField="RECIPIENT_EMAIL"      SortExpression="RECIPIENT_EMAIL"      ItemStyle-Width="10%" />
			<asp:BoundColumn     HeaderText="EmailMan.LBL_LIST_MESSAGE_NAME"    DataField="EMAIL_MARKETING_NAME" SortExpression="EMAIL_MARKETING_NAME" ItemStyle-Width="10%" />
			<asp:TemplateColumn  HeaderText="EmailMan.LBL_LIST_SEND_DATE_TIME"                                   SortExpression="SEND_DATE_TIME"       ItemStyle-Width="10%">
				<ItemTemplate>
					<%# Sql.ToString(T10n.FromServerTime(DataBinder.Eval(Container.DataItem, "SEND_DATE_TIME"))) %>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:BoundColumn     HeaderText="EmailMan.LBL_LIST_SEND_ATTEMPTS"   DataField="SEND_ATTEMPTS"   SortExpression="SEND_ATTEMPTS"   ItemStyle-Width="10%" />
			<asp:BoundColumn     HeaderText="EmailMan.LBL_LIST_IN_QUEUE"        DataField="IN_QUEUE"        SortExpression="IN_QUEUE"        ItemStyle-Width="10%" />
		</Columns>
	</SplendidCRM:SplendidGrid>
	<%@ Register TagPrefix="SplendidCRM" Tagname="CheckAll" Src="~/_controls/CheckAll.ascx" %>
	<SplendidCRM:CheckAll ID="ctlCheckAll" Visible="<%# !PrintView %>" Runat="Server" />
	<%-- 06/06/2015 Paul.  MassUpdateButtons combines ListHeader and DynamicButtons. --%>
	<asp:Panel ID="pnlMassUpdateSeven" runat="server">
		<%@ Register TagPrefix="SplendidCRM" Tagname="MassUpdate" Src="MassUpdate.ascx" %>
		<SplendidCRM:MassUpdate ID="ctlMassUpdate" Runat="Server" />
	</asp:Panel>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

