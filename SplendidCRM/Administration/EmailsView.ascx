<%@ Control CodeBehind="EmailsView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.EmailsView" %>
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
<div id="divEmailsView" visible='<%# 
(  SplendidCRM.Security.AdminUserAccess("EmailMan"     , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("InboundEmail" , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("OutboundEmail", "access") >= 0 
) %>' runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Administration.LBL_EMAIL_TITLE" Runat="Server" />
	<asp:Table Width="100%" CssClass="tabDetailView2" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("EmailMan", "edit") >= 0 %>'>
				<asp:Image SkinID="EmailMan" AlternateText='<%# L10n.Term("Administration.LBL_MASS_EMAIL_CONFIG_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MASS_EMAIL_CONFIG_TITLE") %>' NavigateUrl="~/Administration/EmailMan/config.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("EmailMan", "edit") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MASS_EMAIL_CONFIG_DESC") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("EmailMan", "list") >= 0 %>'>
				<asp:Image SkinID="EmailMan" AlternateText='<%# L10n.Term("Administration.LBL_MASS_EMAIL_MANAGER_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MASS_EMAIL_MANAGER_TITLE") %>' NavigateUrl="~/Administration/EmailMan/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("EmailMan", "list") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MASS_EMAIL_MANAGER_DESC") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("InboundEmail", "access") >= 0 %>'>
				<asp:Image SkinID="InboundEmail" AlternateText='<%# L10n.Term("Administration.LBL_INBOUND_EMAIL_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_INBOUND_EMAIL_TITLE") %>' NavigateUrl="~/Administration/InboundEmail/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("InboundEmail", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MAILBOX_DESC") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("EmailMan", "edit") >= 0 %>'>
				<asp:Image SkinID="Campaigns" AlternateText='<%# L10n.Term("Administration.LBL_CAMPAIGN_EMAIL_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_CAMPAIGN_EMAIL_TITLE") %>' NavigateUrl="~/Administration/EmailMan/edit.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("EmailMan", "edit") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_CAMPAIGN_EMAIL_DESC") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("OutboundEmail", "access") >= 0 %>'>
				<asp:Image ID="imgOutboundEmail" SkinID="OutboundEmail" AlternateText='<%# L10n.Term("Administration.LBL_OUTBOUND_EMAIL_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkOutboundEmail" Text='<%# L10n.Term("Administration.LBL_OUTBOUND_EMAIL_TITLE") %>' NavigateUrl="~/Administration/OutboundEmail/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("OutboundEmail", "access") >= 0 %>'>
				<asp:Label ID="lblOutboundEmail" Text='<%# L10n.Term("Administration.LBL_OUTBOUND_EMAIL_DESC") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2"></asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2"></asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

