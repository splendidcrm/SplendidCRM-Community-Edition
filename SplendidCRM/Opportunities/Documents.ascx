<%@ Control CodeBehind="Documents.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Opportunities.Documents" %>
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
function DocumentPopup()
{
	return ModulePopup('Documents', '<%= txtDOCUMENT_ID.ClientID %>', null, 'ClearDisabled=1', true, null);
}
</script>
<input ID="txtDOCUMENT_ID" type="hidden" Runat="server" />
<%-- 06/03/2015 Paul.  Combine ListHeader and DynamicButtons. --%>
<%@ Register TagPrefix="SplendidCRM" Tagname="SubPanelButtons" Src="~/_controls/SubPanelButtons.ascx" %>
<SplendidCRM:SubPanelButtons ID="ctlDynamicButtons" Module="Documents" SubPanel="divOpportunitiesDocuments" Title="Documents.LBL_MODULE_NAME" Runat="Server" />

<div id="divOpportunitiesDocuments" style='<%= "display:" + (CookieValue("divOpportunitiesDocuments") != "1" ? "inline" : "none") %>'>
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdSubPanelView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="8%" ItemStyle-HorizontalAlign="Left" ItemStyle-Wrap="false">
				<ItemTemplate>
					<%-- 10/08/2017 Paul.  Editing relationships is not allowed in ArchiveView.  --%>
					<%-- 10/31/2017 Paul.  Provide a way to inject Record level ACL. --%>
					<div style="DISPLAY: <%# Sql.ToString(DataBinder.Eval(Container.DataItem, "REVISION")) != Sql.ToString(DataBinder.Eval(Container.DataItem, "SELECTED_REVISION")) ? "inline" : "none" %>">
						<asp:ImageButton Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, "Opportunities", "edit", "OPPORTUNITY_ASSIGNED_USER_ID") >= 0 && !ArchiveViewExists() %>' CommandName="Documents.GetLatest" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "DOCUMENT_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_GET_LATEST") %>' SkinID="getLatestDocument" Runat="server" />
						<asp:LinkButton  Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, "Opportunities", "edit", "OPPORTUNITY_ASSIGNED_USER_ID") >= 0 && !ArchiveViewExists() %>' CommandName="Documents.GetLatest" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "DOCUMENT_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_GET_LATEST") %>' Runat="server" />
					</div>
					<asp:ImageButton Visible='<%# !bEditView && SplendidCRM.Security.GetRecordAccess(Container, m_sMODULE, "edit", "ASSIGNED_USER_ID") >= 0 && !Sql.IsProcessPending(Container) && !ArchiveViewExists() %>' CommandName="Documents.Edit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "DOCUMENT_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_EDIT") %>' SkinID="edit_inline" Runat="server" />
					<asp:LinkButton  Visible='<%# !bEditView && SplendidCRM.Security.GetRecordAccess(Container, m_sMODULE, "edit", "ASSIGNED_USER_ID") >= 0 && !Sql.IsProcessPending(Container) && !ArchiveViewExists() %>' CommandName="Documents.Edit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "DOCUMENT_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_EDIT") %>' Runat="server" />
					&nbsp;
					<span onclick="return confirm('<%= L10n.TermJavaScript(".NTC_DELETE_CONFIRMATION") %>')">
						<asp:ImageButton Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, "Opportunities", "remove", "OPPORTUNITY_ASSIGNED_USER_ID") >= 0 && !ArchiveViewExists() %>' CommandName="Documents.Remove" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "DOCUMENT_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_REMOVE") %>' SkinID="delete_inline" Runat="server" />
						<asp:LinkButton  Visible='<%# SplendidCRM.Security.GetRecordAccess(Container, "Opportunities", "remove", "OPPORTUNITY_ASSIGNED_USER_ID") >= 0 && !ArchiveViewExists() %>' CommandName="Documents.Remove" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "DOCUMENT_ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_REMOVE") %>' Runat="server" />
					</span>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
</div>
