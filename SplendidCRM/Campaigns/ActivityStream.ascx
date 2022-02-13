<%@ Control CodeBehind="ActivityStream.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Campaigns.ActivityStream" %>
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
<%@ Register TagPrefix="SplendidCRM" Tagname="SubPanelButtons" Src="~/_controls/SubPanelButtons.ascx" %>
<SplendidCRM:SubPanelButtons ID="ctlDynamicButtons" Module="ActivityStream" SubPanel="divCampaignsActivityStream" Title=".LBL_ACTIVITY_STREAM" Runat="Server" />

<div id="divCampaignsActivityStream" style='<%= "display:" + (CookieValue("divCampaignsActivityStream") != "1" ? "inline" : "none") %>'>
	<asp:Panel ID="pnlNewRecordInline" Visible='<%# !Sql.ToBoolean(Application["CONFIG.disable_editview_inline"]) %>' Style="display:none" runat="server">
		<%@ Register TagPrefix="SplendidCRM" Tagname="NewRecord" Src="~/ActivityStream/NewRecord.ascx" %>
		<SplendidCRM:NewRecord ID="ctlNewRecord" Width="100%" ShowCancel="true" ShowHeader="false" Runat="Server" />
	</asp:Panel>
	
	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/ActivityStream/SearchBasic.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Visible="false" Runat="Server" />
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdSubPanelView" AllowPaging="<%# !PrintView %>" ShowHeader="false" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="100%" ItemStyle-HorizontalAlign="Left">
				<ItemTemplate>
					<table cellpadding="2" cellspacing="0" border="0" width="100%">
						<tr>
							<td width="50px">
								<div class="ActivityStreamPicture" >
									<%-- 01/17/2018 Paul.  Use CREATED_BY_ID to determine of person created the event. --%>
									<asp:Image CssClass="ActivityStreamPicture" SkinID="ActivityStreamUser"                                Visible='<%# !Sql.IsEmptyGuid(Eval("CREATED_BY_ID")) &&  Sql.IsEmptyString(Eval("CREATED_BY_PICTURE")) %>' runat="server" />
									<asp:Image CssClass="ActivityStreamPicture" src='<%# Eval("CREATED_BY_PICTURE") %>'                    Visible='<%# !Sql.IsEmptyGuid(Eval("CREATED_BY_ID")) && !Sql.IsEmptyString(Eval("CREATED_BY_PICTURE")) %>' runat="server" />
									<asp:Panel CssClass='<%# "ModuleHeaderModule ModuleHeaderModule" + m_sMODULE + " ListHeaderModule" %>' Visible='<%#  Sql.IsEmptyGuid(Eval("CREATED_BY_ID")) %>' runat="server"><%# L10n.Term(m_sMODULE + ".LBL_MODULE_ABBREVIATION") %></asp:Panel>
								</div>
							</td>
							<td>
								<div class="ActivityStreamDescription"><%# SplendidCRM.ActivityStream.StreamView.StreamFormatDescription(m_sMODULE, L10n, T10n, Container.DataItem) %></div>
								<div class="ActivityStreamIdentity">
									<span class="ActivityStreamCreatedBy"><%# Eval("CREATED_BY") %></span>
									<span class="ActivityStreamDateEntered"><%# Eval("STREAM_DATE") %></span>
								</div>
							</td>
							<td width="20px">
								<asp:ImageButton Visible='<%# SplendidCRM.Security.GetUserAccess(m_sMODULE, "view") >= 0 && (Sql.ToString(Eval("STREAM_ACTION")) != "Deleted") %>' CommandName="Preview" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_PREVIEW") %>' SkinID="preview_inline" Runat="server" />
							</td>
						</tr>
					</table>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
</div>

