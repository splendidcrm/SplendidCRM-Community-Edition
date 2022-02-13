<%@ Control CodeBehind="NetworkView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.NetworkView" %>
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
<div id="divNetworkView">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Administration.LBL_SPLENDIDCRM_NETWORK_TITLE" Runat="Server" />
	<asp:Table Width="100%" CssClass="tabDetailView2" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Wrap="false" Visible='<%# SplendidCRM.Security.IS_ADMIN %>'>
				<asp:Image SkinID="sugarupdate" AlternateText='<%# L10n.Term("Administration.LBL_SPLENDIDCRM_UPDATE_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_SPLENDIDCRM_UPDATE_TITLE") %>' NavigateUrl="~/Administration/Updater/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.IS_ADMIN %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_SPLENDIDCRM_UPDATE") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2">
				<asp:Image SkinID="OnlineDocumentation" AlternateText='<%# L10n.Term("Administration.LBL_DOCUMENTATION_TITLE") %>' Visible='<%# !Sql.ToBoolean(Application["CONFIG.hide_training"]) %>' Runat="server" />
				&nbsp;
				<asp:LinkButton Text='<%# L10n.Term("Administration.LBL_DOCUMENTATION_TITLE") %>' Visible='<%# !Sql.ToBoolean(Application["CONFIG.hide_training"]) %>' OnClientClick=<%# "window.open('https://www.splendidcrm.com/Documentation.aspx', 'helpwin', 'status=0,resizable=1,scrollbars=1,toolbar=1,location=1'); return false;" %> CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2">
				<asp:Label Text='<%# L10n.Term("Administration.LBL_DOCUMENTATION") %>' Visible='<%# !Sql.ToBoolean(Application["CONFIG.hide_training"]) %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

