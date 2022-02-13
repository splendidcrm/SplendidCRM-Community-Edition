<%@ Page language="c#" MasterPageFile="~/DefaultView.Master" Codebehind="default.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Home.Default" %>
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
<asp:Content ID="cntSidebar" ContentPlaceHolderID="cntSidebar" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="Shortcuts" Src="~/_controls/Shortcuts.ascx" %>
	<SplendidCRM:Shortcuts ID="ctlShortcuts" SubMenu="Home" Title=".LBL_SHORTCUTS" Runat="Server" />
	<asp:PlaceHolder ID="plcSubPanelLeft" Runat="server" />
	<%= Application["CONFIG.home_left_banner"] %>
</asp:Content>

<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
	<asp:Table Width="100%" BorderStyle="None" BorderWidth="0" CellPadding="2" CellSpacing="0" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="90%">
				<asp:Button ID="btnAddDashlets" CommandName="AddDashlets" Text='<%# L10n.Term("Home.LBL_ADD_DASHLETS") %>' OnCommand="Page_Command" Visible='<%# !this.IsMobile && !Sql.ToBoolean(Application["CONFIG.disable_add_dashlets"]) %>' runat="server" />
				&nbsp;
				<asp:PlaceHolder Visible='<%# !Sql.ToBoolean(Application["CONFIG.hide_upgrade_warning"]) %>' runat="server">
					<asp:Label ID="lblUpgradeWarning" CssClass="error" Visible="false" runat="server" />
				</asp:PlaceHolder>
			</asp:TableCell>
			<asp:TableCell Width="10%" HorizontalAlign="Right" Wrap="false">
				<script type="text/javascript">
				function PopupHelp()
				{
					var url = document.getElementById('<%= lnkHelpText.ClientID %>').href;
					window.open(url,'helpwin','width=600,height=600,status=0,resizable=1,scrollbars=1,toolbar=0,location=1');
				}
				</script>
				<asp:PlaceHolder Visible='<%# !Sql.ToBoolean(Application["CONFIG.hide_help"]) %>' runat="server">
					<asp:HyperLink ID="lnkHelpImage" onclick="PopupHelp(); return false;" CssClass="utilsLink" Target="_blank" Runat="server">
						<asp:Image AlternateText='<%# L10n.Term(".LNK_HELP") %>' SkinID="help" Runat="server" />
					</asp:HyperLink>
					<asp:HyperLink ID="lnkHelpText" onclick="PopupHelp(); return false;" CssClass="utilsLink" Target="_blank" Runat="server"><%# L10n.Term(".LNK_HELP") %></asp:HyperLink>
				</asp:PlaceHolder>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" Visible="<%# !this.IsMobile %>" runat="server">
		<tr>
			<td width="60%" valign="top">
				<asp:PlaceHolder ID="plcSubPanelBody" Runat="server" />
			</td>
			<td style="padding-left: 10px; vertical-align: top;">
				<asp:PlaceHolder ID="plcSubPanelRight" Runat="server" />
				<%= Application["CONFIG.home_right_banner"] %>
			</td>
		</tr>
	</table>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</asp:Content>

