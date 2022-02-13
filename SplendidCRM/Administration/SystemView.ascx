<%@ Control CodeBehind="SystemView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.SystemView" %>
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
<div id="divSystemView" visible='<%# 
(  SplendidCRM.Security.AdminUserAccess("Config"        , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Currencies"    , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("SystemLog"     , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Administration", "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Import"        , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Schedulers"    , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("PaymentGateway", "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Undelete"      , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("ZipCodes"      , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("NAICSCodes"    , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("ModulesArchiveRules", "access") >= 0 
) %>' runat="server">
	<p>
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Administration.LBL_ADMINISTRATION_HOME_TITLE" Runat="Server" />
	<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />

	<asp:Table Width="100%" CssClass="tabDetailView2" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Wrap="false" Visible='<%# SplendidCRM.Security.AdminUserAccess("Config", "access") >= 0 %>'>
				<asp:Image SkinID="Administration" AlternateText='<%# L10n.Term("Administration.LBL_CONFIGURE_SETTINGS_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_CONFIGURE_SETTINGS_TITLE") %>' NavigateUrl="~/Administration/Config/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
				<br />
				<div align="center">
				(
					<asp:LinkButton ID="btnShowSQL" Visible='<%# !Sql.ToBoolean(Application["CONFIG.show_sql"]) %>' Text='<%# L10n.Term("Administration.LBL_SHOW_SQL") %>' CommandName="System.ShowSQL" OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
					<asp:LinkButton ID="btnHideSQL" Visible='<%#  Sql.ToBoolean(Application["CONFIG.show_sql"]) %>' Text='<%# L10n.Term("Administration.LBL_HIDE_SQL") %>' CommandName="System.HideSQL" OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
				)
				</div>
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Config", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_CONFIGURE_SETTINGS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Administration", "access") >= 0 %>'>
				<asp:Image SkinID="SystemCheck" AlternateText='<%# L10n.Term("Administration.LBL_UPGRADE_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_SYSTEM_CHECK_TITLE") %>' NavigateUrl="~/SystemCheck.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
				<br />
				<div align="center">
				(
				<asp:LinkButton Text="Reload"     CommandName="System.Reload" OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
				&nbsp;
				<asp:HyperLink  Text='Precompile' NavigateUrl="~/_devtools/Precompile.aspx" CssClass="tabDetailViewDL2Link" Target="PrecompileSplendidCRM" Runat="server" />
				)
				</div>
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Administration", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_SYSTEM_CHECK") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Currencies", "access") >= 0 %>'>
				<asp:Image SkinID="Currencies" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_CURRENCIES") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_CURRENCIES") %>' NavigateUrl="~/Administration/Currencies/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Currencies", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_CURRENCY") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("SystemLog", "access") >= 0 %>'>
				<asp:Image SkinID="Upgrade" AlternateText='<%# L10n.Term("Administration.LBL_SYSTEM_LOG_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_SYSTEM_LOG_TITLE") %>' NavigateUrl="~/Administration/SystemLog/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("SystemLog", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_SYSTEM_LOG") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Import", "access") >= 0 %>'>
				<asp:Image SkinID="Import" AlternateText='<%# L10n.Term("Administration.LBL_IMPORT_DATABASE_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_IMPORT_DATABASE_TITLE") %>' NavigateUrl="~/Administration/Import/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Import", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_IMPORT_DATABASE") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Import", "export") >= 0 %>'>
				<asp:Image SkinID="Export" AlternateText='<%# L10n.Term("Administration.LBL_EXPORT_DATABASE_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_EXPORT_DATABASE_TITLE") %>' NavigateUrl="~/Administration/Export/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Import", "export") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_EXPORT_DATABASE") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Schedulers", "access") >= 0 %>'>
				<asp:Image SkinID="Schedulers" AlternateText='<%# L10n.Term("Administration.LBL_SUGAR_SCHEDULER_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_SUGAR_SCHEDULER_TITLE") %>' NavigateUrl="~/Administration/Schedulers/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Schedulers", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_SUGAR_SCHEDULER") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.IS_ADMIN %>'>
				<asp:Image SkinID="Backups" AlternateText='<%# L10n.Term("Administration.LBL_BACKUPS_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_BACKUPS_TITLE") %>' NavigateUrl="~/Administration/Backups/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
				<div align="center">
				(
				<asp:LinkButton Text='<%# L10n.Term("Administration.LBL_PURGE_DEMO") %>' CommandName="System.PurgeDemo" OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
				)
				</div>
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.IS_ADMIN %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_BACKUPS") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Config", "access") >= 0 %>'>
				<asp:Image SkinID="Administration" AlternateText='<%# L10n.Term("Administration.LBL_CONFIGURATOR_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_CONFIGURATOR_TITLE") %>' NavigateUrl="~/Administration/Configurator/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Config", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_CONFIGURATOR") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Undelete", "access") >= 0 %>'>
				<asp:Image SkinID="Delete" AlternateText='<%# L10n.Term("Administration.LBL_UNDELETE_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_UNDELETE_TITLE") %>' NavigateUrl="~/Administration/Undelete/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Undelete", "access") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_UNDELETE") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<%-- 03/10/2019 Paul.  ZipCodes and NAICSCodes module to Community.  --%>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("ZipCodes", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/ZipCodes/default.aspx") %>'>
				<asp:Image SkinID="Administration" AlternateText='<%# L10n.Term("Administration.LBL_ZIPCODES_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_ZIPCODES_TITLE") %>' NavigateUrl="~/Administration/ZipCodes/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("ZipCodes", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/ZipCodes/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_ZIPCODES") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("NAICSCodes", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/NAICSCodes/default.aspx") %>'>
				<asp:Image SkinID="Administration" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_NAICS_CODES_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_NAICS_CODES_TITLE") %>' NavigateUrl="~/Administration/NAICSCodes/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("NAICSCodes", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/NAICSCodes/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_NAICS_CODES") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<%-- 03/04/2019 Paul.  ModulesArchiveRules module to Community.  --%>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.IS_ADMIN && Utils.CachedFileExists(Context, "~/Administration/ModulesArchiveRules/default.aspx") %>'>
				<asp:Image SkinID="Backups" AlternateText='<%# L10n.Term("Administration.LBL_MODULE_ARCHIVE_RULES_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MODULE_ARCHIVE_RULES_TITLE") %>' NavigateUrl="~/Administration/ModulesArchiveRules/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
				<asp:Panel Visible='<%# Sql.IsEmptyString(Context.Application["ArchiveConnectionString"]) %>' runat="server">
					<br />
					<div align="center">
					(
					<asp:LinkButton Text="Rebuild Archive" CommandName="System.RebuildArchive"   OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
					)
					</div>
				</asp:Panel>
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.IS_ADMIN && Utils.CachedFileExists(Context, "~/Administration/ModulesArchiveRules/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MODULE_ARCHIVE_RULES") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.IS_ADMIN && Utils.CachedFileExists(Context, "~/Administration/ModulesArchiveRules/default.aspx") %>'></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.IS_ADMIN && Utils.CachedFileExists(Context, "~/Administration/ModulesArchiveRules/default.aspx") %>'></asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	</p>
</div>
