<%@ Control Language="c#" AutoEventWireup="false" Codebehind="DetailView.ascx.cs" Inherits="SplendidCRM.Users.DetailView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
function PasswordPopup()
{
	return window.open('Password.aspx','PasswordPopup','width=500,height=300,resizable=1,scrollbars=1');
}

function ChangePassword(sOLD_PASSWORD, sNEW_PASSWORD, sCONFIRM_PASSWORD)
{
	document.getElementById('<%= txtOLD_PASSWORD.ClientID     %>').value = sOLD_PASSWORD    ;
	document.getElementById('<%= txtNEW_PASSWORD.ClientID     %>').value = sNEW_PASSWORD    ;
	document.getElementById('<%= txtCONFIRM_PASSWORD.ClientID %>').value = sCONFIRM_PASSWORD;
	document.forms[0].submit();
}
</script>
<div id="divMain">
	<input ID="txtOLD_PASSWORD"     type="hidden" Runat="server" />
	<input ID="txtNEW_PASSWORD"     type="hidden" Runat="server" />
	<input ID="txtCONFIRM_PASSWORD" type="hidden" Runat="server" />

	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" Module="Users" EnablePrint="true" HelpName="DetailView" EnableHelp="true" Runat="Server" />

	<asp:Table SkinID="tabDetailView" runat="server">
		<asp:TableRow>
			<asp:TableCell width="15%" VerticalAlign="top" CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_NAME") %></asp:TableCell>
			<asp:TableCell width="35%" VerticalAlign="top" CssClass="tabDetailViewDF"><asp:Label ID="txtNAME" Runat="server" /></asp:TableCell>
			<asp:TableCell width="15%" VerticalAlign="top" CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_USER_NAME") %></asp:TableCell>
			<asp:TableCell width="35%" VerticalAlign="top" CssClass="tabDetailViewDF"><asp:Label ID="txtUSER_NAME" Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell VerticalAlign="top" CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_STATUS") %></asp:TableCell>
			<asp:TableCell VerticalAlign="top" CssClass="tabDetailViewDF"><asp:Label ID="txtSTATUS" Runat="server" /></asp:TableCell>
			<asp:TableCell ID="tdDEFAULT_TEAM_Label" VerticalAlign="top" CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_DEFAULT_TEAM") %></asp:TableCell>
			<asp:TableCell ID="tdDEFAULT_TEAM_Field" VerticalAlign="top" CssClass="tabDetailViewDF"><asp:Label ID="DEFAULT_TEAM_NAME" Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell VerticalAlign="top" CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_PICTURE") %></asp:TableCell>
			<asp:TableCell VerticalAlign="top" CssClass="tabDetailViewDF"><img id="imgPICTURE" style="width: 36px; height: 36px;" runat="server" /></asp:TableCell>
			<asp:TableCell VerticalAlign="top" CssClass="tabDetailViewDL"></asp:TableCell>
			<asp:TableCell VerticalAlign="top" CssClass="tabDetailViewDF"></asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

<div id="divUserSettings">
	<p></p>
	<asp:Table SkinID="tabDetailView" runat="server">
		<asp:TableRow>
			<asp:TableHeaderCell ColumnSpan="3" CssClass="dataLabel"><h4><asp:Label Text='<%# L10n.Term("Users.LBL_USER_SETTINGS") %>' runat="server" /></h4></asp:TableHeaderCell>
		</asp:TableRow>
		<asp:TableRow Visible='<%# SplendidCRM.Security.IS_ADMIN %>'>
			<asp:TableCell width="20%" CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_ADMIN") %>&nbsp;</asp:TableCell>
			<asp:TableCell width="15%" CssClass="tabDetailViewDF"><asp:CheckBox ID="chkIS_ADMIN" Enabled="false" CssClass="checkbox" Runat="server" />&nbsp;</asp:TableCell>
			<asp:TableCell width="65%" CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_ADMIN_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "view") >= 0 %>'>
			<asp:TableCell width="20%" CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_ADMIN_DELEGATE") %>&nbsp;</asp:TableCell>
			<asp:TableCell width="15%" CssClass="tabDetailViewDF"><asp:CheckBox ID="chkIS_ADMIN_DELEGATE" Enabled="false" CssClass="checkbox" Runat="server" />&nbsp;</asp:TableCell>
			<asp:TableCell width="65%" CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_ADMIN_DELEGATE_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow Visible="false">
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_PORTAL_ONLY") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:CheckBox ID="chkPORTAL_ONLY" Enabled="false" CssClass="checkbox" Runat="server" />&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_PORTAL_ONLY_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow Visible="true">
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_RECEIVE_NOTIFICATIONS") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:CheckBox ID="chkRECEIVE_NOTIFICATIONS" Enabled="false" CssClass="checkbox" Runat="server" />&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_RECEIVE_NOTIFICATIONS_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_THEME") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:Label ID="txtTHEME" Runat="server" /></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_THEME_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_LANGUAGE") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:Label ID="txtLANGUAGE" Runat="server" /></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_LANGUAGE_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_DATE_FORMAT") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:Label ID="txtDATEFORMAT" Runat="server" /></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_DATE_FORMAT_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_TIME_FORMAT") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:Label ID="txtTIMEFORMAT" Runat="server" /></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_TIME_FORMAT_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_TIMEZONE") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:Label ID="txtTIMEZONE" Runat="server" /></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_TIMEZONE_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_CURRENCY") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:Label ID="txtCURRENCY" Runat="server" /></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_CURRENCY_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow Visible="false">
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_REMINDER") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF">
				<!-- 08/05/2006 Paul.  Remove stub of unsupported code. Reminder is not supported at this time. -->
				<asp:CheckBox ID="chkREMINDER" Enabled="false" CssClass="checkbox" Runat="server" />&nbsp;
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_REMINDER_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_SAVE_QUERY") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:CheckBox ID="chkSAVE_QUERY" Enabled="false" CssClass="checkbox" Runat="server" />&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_SAVE_QUERY_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_GROUP_TABS") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:CheckBox ID="chkGROUP_TABS" Enabled="false" CssClass="checkbox" Runat="server" />&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_GROUP_TABS_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_SUBPANEL_TABS") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:CheckBox ID="chkSUBPANEL_TABS" Enabled="false" CssClass="checkbox" Runat="server" />&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_SUBPANEL_TABS_TEXT") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow Visible='<%# SplendidCRM.Security.IS_ADMIN %>'>
			<asp:TableCell CssClass="tabDetailViewDL"><%= L10n.Term("Users.LBL_SYSTEM_GENERATED_PASSWORD") %>&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><asp:CheckBox ID="chkSYSTEM_GENERATED_PASSWORD" Enabled="false" CssClass="checkbox" Runat="server" />&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF"><%= L10n.Term("Users.LBL_SYSTEM_GENERATED_PASSWORD") %>&nbsp;</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
</div>

<div id="divDetailView" runat="server">
	<p></p>
	<asp:HiddenField ID="LAYOUT_DETAIL_VIEW" Runat="server" />
	<table ID="tblMain" class="tabDetailView" runat="server">
		<tr>
			<th colspan="4" class="dataLabel"><h4><asp:Label Text='<%# L10n.Term("Users.LBL_USER_INFORMATION") %>' runat="server" /></h4></th>
		</tr>
	</table>
	<p></p>
</div>

<div id="divMailOptions">
	<p></p>
	<h4><asp:Label Text='<%# L10n.Term("Users.LBL_MAIL_OPTIONS_TITLE") %>' runat="server" /></h4>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlExchangeButtons" Visible="<%# !PrintView %>" Runat="Server" />
	<table ID="tblMailOptions" class="tabDetailView" runat="server">
	</table>
	<p></p>
</div>

<asp:Panel ID="pnlGoogleAppsOptions" runat="server">
	<p></p>
	<h4><asp:Label Text='<%# L10n.Term("Users.LBL_GOOGLEAPPS_OPTIONS_TITLE") %>' runat="server" /></h4>
	<SplendidCRM:DynamicButtons ID="ctlGoogleAppsButtons" Visible="<%# !PrintView %>" Runat="Server" />
	<table ID="tblGoogleAppsOptions" class="tabDetailView" runat="server">
	</table>
	<p></p>
</asp:Panel>

<asp:Panel ID="pnlICloudOptions" runat="server">
	<p></p>
	<h4><asp:Label Text='<%# L10n.Term("Users.LBL_ICLOUD_OPTIONS_TITLE") %>' runat="server" /></h4>
	<SplendidCRM:DynamicButtons ID="ctlICloudButtons" Visible="<%# !PrintView %>" Runat="Server" />
	<table ID="tblICloudOptions" class="tabDetailView" runat="server">
	</table>
	<p></p>
</asp:Panel>

<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
<SplendidCRM:ListHeader SubPanel="divAccessRights" Title="Users.LBL_ACCESS_RIGHTS" Runat="Server" />
<div id="divAccessRights" style='<%= "display:" + (CookieValue("divAccessRights") != "1" ? "inline" : "none") %>'>
	<%@ Register TagPrefix="SplendidCRM" Tagname="AccessView" Src="~/Administration/ACLRoles/AccessView.ascx" %>
	<SplendidCRM:AccessView ID="ctlAccessView" EnableACLEditing="false" Runat="Server" />
</div>

<div id="divDetailSubPanel">
	<%@ Register TagPrefix="SplendidCRM" Tagname="Signatures" Src="Signatures.ascx" %>
	<SplendidCRM:Signatures ID="ctlSignatures" Runat="Server" />
	
	<%@ Register TagPrefix="SplendidCRM" Tagname="Roles" Src="Roles.ascx" %>
	<SplendidCRM:Roles ID="ctlRoles" Runat="Server" />
	
	<%@ Register TagPrefix="SplendidCRM" Tagname="Teams" Src="Teams.ascx" %>
	<SplendidCRM:Teams ID="ctlTeams" Runat="Server" />
	
	<asp:PlaceHolder ID="plcSubPanel" Runat="server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="Logins" Src="Logins.ascx" %>
	<SplendidCRM:Logins ID="ctlLogins" Visible='<%# SplendidCRM.Security.AdminUserAccess(m_sMODULE, "view") >= 0 %>' Runat="Server" />
</div>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

