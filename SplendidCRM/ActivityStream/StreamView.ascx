<%@ Control CodeBehind="StreamView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.ActivityStream.StreamView" %>
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
	<div style="DISPLAY: <%= bShowHeader ? "inline" : "none" %>">
		<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
		<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Title=".LBL_ACTIVITY_STREAM" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />
	</div>

	<div ID="my_activitystream_edit" style="DISPLAY: <%= bShowSearchDialog ? "inline" : "none" %>">
		<%@ Register TagPrefix="SplendidCRM" Tagname="SearchBasic" Src="SearchBasic.ascx" %>
		<SplendidCRM:SearchBasic ID="ctlSearchBasic" Visible="<%# !PrintView %>" Runat="Server" />
	</div>

	<asp:Panel ID="pnlNewRecordInline" runat="server">
		<%@ Register TagPrefix="SplendidCRM" Tagname="NewRecord" Src="NewRecord.ascx" %>
		<SplendidCRM:NewRecord ID="ctlNewRecord" Visible="<%# !PrintView %>" Runat="Server" />
	</asp:Panel>

	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<asp:HiddenField ID="LAYOUT_LIST_VIEW" Runat="server" />
	<SplendidCRM:SplendidGrid id="grdMain" AllowPaging="<%# !PrintView %>" EnableViewState="true" ShowHeader="false" runat="server">
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
									<asp:Panel CssClass='<%# "ModuleHeaderModule ModuleHeaderModule" + Sql.ToString(Eval("MODULE_NAME")) + " ListHeaderModule" %>' Visible='<%# Sql.IsEmptyGuid(Eval("CREATED_BY_ID")) %>' runat="server"><%# L10n.Term(Sql.ToString(Eval("MODULE_NAME")) + ".LBL_MODULE_ABBREVIATION") %></asp:Panel>
								</div>
							</td>
							<td>
								<div class="ActivityStreamDescription"><%# StreamFormatDescription(Sql.ToString(Eval("MODULE_NAME")), L10n, T10n, Container.DataItem) %></div>
								<div class="ActivityStreamIdentity">
									<span class="ActivityStreamCreatedBy"><%# Eval("CREATED_BY") %></span>
									<span class="ActivityStreamDateEntered"><%# Eval("STREAM_DATE") %></span>
								</div>
							</td>
							<td width="20px">
								<asp:ImageButton Visible='<%# SplendidCRM.Security.GetUserAccess(Sql.ToString(Eval("MODULE_NAME")), "view") >= 0 && (Sql.ToString(Eval("STREAM_ACTION")) != "Deleted") %>' CommandName="Preview" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_PREVIEW") %>' SkinID="preview_inline" Runat="server" />
							</td>
						</tr>
					</table>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

