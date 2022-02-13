<%@ Page language="c#" MasterPageFile="~/DefaultView.Master" Codebehind="AddDashlets.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Home.AddDashlets" %>
<%@ Register TagPrefix="SplendidCRM" Tagname="ArrangeDashlets" Src="ArrangeDashlets.ascx" %>
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
	<script type="text/javascript">
	var ChangeDashlet = null;
	</script>

	<asp:Label ID="lblUpgradeWarning" CssClass="error" Visible="false" runat="server" />
	<asp:Button CommandName="CloseDashlets" Text='<%# L10n.Term("Home.LBL_CLOSE_DASHLETS") %>' OnCommand="Page_Command" style="margin-top: 6px;" runat="server" />
	<table border="0" cellpadding="0" cellspacing="0" width="100%" Visible="<%# !this.IsMobile %>" style="margin-top: 4px;" runat="server">
		<tr>
			<td width="50%" valign="top">
				<SplendidCRM:ArrangeDashlets ID="ctlDashletsBody" DetailView="Home.DetailView.Body" Category="My Dashlets" Runat="Server" />
			</td>
			<td style="padding-left: 10px; vertical-align: top;">
				<SplendidCRM:ArrangeDashlets ID="ctlDashletsRight" DetailView="Home.DetailView.Right" Category="My Dashlets" Runat="Server" />
			</td>
		</tr>
	</table>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</asp:Content>

