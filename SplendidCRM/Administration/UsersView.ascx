<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.UsersView" %>
<%@ Import Namespace="SplendidCRM.Crm" %>
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
<div id="divUsersView" visible='<%# 
(  SplendidCRM.Security.AdminUserAccess("Users"      , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("ACLRoles"   , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("UserLogins" , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Teams"      , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("AuditEvents", "access") >= 0 
) %>' runat="server">
	<p>
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Administration.LBL_USERS_TITLE" Runat="Server" />
	<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />

	<asp:Table Width="100%" CssClass="tabDetailView2" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Users", "access") >= 0 %>'>
				<asp:Image SkinID="Users" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_USERS_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_USERS_TITLE") %>' NavigateUrl="~/Users/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
				<br />
				<div align="center">
				(
				<asp:LinkButton ID="btnUserRequired" Visible='<%# !Config.require_user_assignment() %>' Text="Require"  CommandName="UserAssignement.Require"  OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
				&nbsp;
				<asp:LinkButton ID="btnUserOptional" Visible='<%#  Config.require_user_assignment() %>' Text="Optional" CommandName="UserAssignement.Optional" OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
				)
				</div>
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Users", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_USERS") %>' runat="server" /><br />
				User Assignment is <%# Config.require_user_assignment() ? "Required" : "Optional" %>
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("ACLRoles", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/ACLRoles/default.aspx") %>'>
				<asp:Image SkinID="Roles" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_ROLES_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_ROLES_TITLE") %>' NavigateUrl="~/Administration/ACLRoles/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
				<br />
				<div align="center">
				(
				<asp:LinkButton ID="btnAdminDelegationEnable"  Visible='<%# !Sql.ToBoolean(Application["CONFIG.allow_admin_roles"]) && (SplendidCRM.Security.AdminUserAccess("ACLRoles", "edit") >= 0) %>' Text='<%# L10n.Term("ACLRoles.LBL_ENABLE_ADMIN_DELEGATION" ) %>' CommandName="AdminDelegation.Enable"  OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
				&nbsp;
				<asp:LinkButton ID="btnAdminDelegationDisable" Visible='<%#  Sql.ToBoolean(Application["CONFIG.allow_admin_roles"]) && (SplendidCRM.Security.AdminUserAccess("ACLRoles", "edit") >= 0) %>' Text='<%# L10n.Term("ACLRoles.LBL_DISABLE_ADMIN_DELEGATION") %>' CommandName="AdminDelegation.Disable" OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
				)
				</div>
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("ACLRoles", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/ACLRoles/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_ROLES") %>' runat="server" /><br />
				<%# Sql.ToBoolean(Application["CONFIG.allow_admin_roles"]) ? L10n.Term("ACLRoles.LBL_ADMIN_DELEGATION_ENABLED") : L10n.Term("ACLRoles.LBL_ADMIN_DELEGATION_DISABLED") %>
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("UserLogins", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/UserLogins/default.aspx") %>'>
				<asp:Image SkinID="Users" AlternateText='<%# L10n.Term("Administration.LBL_USERS_LOGINS_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_USERS_LOGINS_TITLE") %>' NavigateUrl="~/Administration/UserLogins/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("UserLogins", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/UserLogins/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_USERS_LOGINS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Config", "access") >= 0 %>'>
				<asp:Image SkinID="Administration" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_PASSWORD_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_PASSWORD_TITLE") %>' NavigateUrl="~/Administration/PasswordManager/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Config", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_PASSWORD") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("AuditEvents", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/AuditEvents/default.aspx") %>'>
				<asp:Image SkinID="UserLogins" AlternateText='<%# L10n.Term("Administration.LBL_AUDIT_EVENTS_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_AUDIT_EVENTS_TITLE") %>' NavigateUrl="~/Administration/AuditEvents/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("AuditEvents", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/AuditEvents/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_AUDIT_EVENTS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("AuditEvents", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/AuditEvents/default.aspx") %>'></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("AuditEvents", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/AuditEvents/default.aspx") %>'></asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	</p>
</div>
