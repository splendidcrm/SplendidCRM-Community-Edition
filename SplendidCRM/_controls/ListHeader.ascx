<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ListHeader.ascx.cs" Inherits="SplendidCRM._controls.ListHeader" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
	<asp:Table SkinID="tabFrame" CssClass="h3Row" runat="server">
		<asp:TableRow>
			<asp:TableCell Wrap="false">
				<h3>
					<span Visible="<%# !Sql.IsEmptyString(SubPanel) %>" runat="server">
						<asp:HyperLink ID="lnkShowSubPanel" NavigateUrl=<%# "javascript:ShowSubPanel(\'" + lnkShowSubPanel.ClientID + "\',\'" + lnkHideSubPanel.ClientID + "\',\'" + SubPanel + "\');" %> style=<%# "display:" + (CookieValue(SubPanel) == "1" ? "inline" : "none") %> runat="server"><asp:Image SkinID="advanced_search" runat="server" /></asp:HyperLink>
						<asp:HyperLink ID="lnkHideSubPanel" NavigateUrl=<%# "javascript:HideSubPanel(\'" + lnkShowSubPanel.ClientID + "\',\'" + lnkHideSubPanel.ClientID + "\',\'" + SubPanel + "\');" %> style=<%# "display:" + (CookieValue(SubPanel) != "1" ? "inline" : "none") %> runat="server"><asp:Image SkinID="basic_search"    runat="server" /></asp:HyperLink>
					</span>
					<asp:Image SkinID="h3Arrow" Visible="<%# Sql.IsEmptyString(SubPanel) %>" Runat="server" />
					&nbsp;<asp:Label Text='<%# L10n.Term(Title) %>' runat="server" />
				</h3>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

