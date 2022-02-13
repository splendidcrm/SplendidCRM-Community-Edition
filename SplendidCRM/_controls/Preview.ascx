<%@ Control Language="c#" AutoEventWireup="false" Codebehind="Preview.ascx.cs" Inherits="SplendidCRM._controls.Preview" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
<div id="divPreviewView" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Visible="<%# !PrintView %>" Runat="Server" />

	<asp:HiddenField ID="LAYOUT_DETAIL_VIEW" Runat="server" />
	<asp:HiddenField ID="hidPREVIEW_ID"      Runat="server" />
	<asp:HiddenField ID="hidPREVIEW_MODULE"  Runat="server" />
	<table ID="tblMain" class="tabPreviewView" runat="server">
	</table>

	<SplendidCRM:SplendidGrid id="grdStream" AllowPaging="<%# !PrintView %>" EnableViewState="true" ShowHeader="false" Visible="false" runat="server">
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
						</tr>
					</table>
				</ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
</div>
