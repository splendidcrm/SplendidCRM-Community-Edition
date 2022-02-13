<%@ Control CodeBehind="BugsView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.BugsView" %>
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
<div id="divBugsView" visible='<%# 
(  SplendidCRM.Security.AdminUserAccess("Releases"       , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("NumberSequences", "access") >= 0 
) %>' runat="server">

	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Administration.LBL_BUG_TITLE" Runat="Server" />
	<asp:Table Width="100%" CssClass="tabDetailView2" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2">
				<asp:Image SkinID="Releases" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_RELEASES") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_RELEASES") %>' NavigateUrl="~/Administration/Releases/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2"><asp:Label Text='<%# L10n.Term("Administration.LBL_RELEASE") %>' runat="server" /></asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2">
				<asp:Image SkinID="NumberSequences" AlternateText='<%# L10n.Term("Administration.LBL_NUMBER_SEQUENCES") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_NUMBER_SEQUENCES") %>' NavigateUrl="~/Administration/NumberSequences/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2"><asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_NUMBER_SEQUENCES") %>' runat="server" /></asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

