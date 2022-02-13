<%@ Control CodeBehind="DetailView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Help.DetailView" %>
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
<div id="divDetailView" runat="server">
	<script type="text/javascript">
	function createBookmarkLink()
	{
		var sTitle = '<%= SplendidCRM.Sql.EscapeJavaScript(sPageTitle) %>';
		var sURL = window.location.href;
		if ( document.all )
			window.external.AddFavorite(sURL, sTitle);
		else if ( window.sidebar )
			window.sidebar.addPanel(sTitle, sURL, '');
	}
	function Cancel()
	{
		window.close();
	}

	var sApplicationSiteURL = location.protocol + '//' + location.host + '<%= Application["rootURL"] %>';
	</script>
	<!-- 01/29/2011 Paul.  Allow the help javascript to be customized. -->
	<%= Application["CONFIG.help_scripts"] %>
	<asp:Table width="100%" border="0" cellspacing="2" cellpadding="0" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="25%">
				<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
				<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Visible="<%# !PrintView %>" Runat="Server" />
			</asp:TableCell>
			<asp:TableCell Width="50%" HorizontalAlign="Center">
				<asp:HyperLink ID="lnkTOPICS" NavigateUrl="topics.aspx" Text='<%# L10n.Term("Help.LBL_TOPICS") %>' runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkTEST"   NavigateUrl="~/_devtools/TestHelp.aspx" Text='<%# L10n.Term("Help.LBL_TEST") %>' Visible='<%# Security.IS_ADMIN %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="25%" HorizontalAlign="Right">
				<asp:HyperLink ID="lnkPRINT" NavigateUrl="javascript:window.print();" Text='<%# L10n.Term("Help.LBL_HELP_PRINT") %>' runat="server" />
				-
				<asp:HyperLink ID="lnkEMAIL" NavigateUrl="#" Text='<%# L10n.Term("Help.LBL_HELP_EMAIL") %>' runat="server" />
				-
				<asp:HyperLink ID="lnkBOOKMARK" NavigateUrl="#" onmousedown="createBookmarkLink()" Text='<%# L10n.Term("Help.LBL_HELP_BOOKMARK") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Literal ID="lblDISPLAY_TEXT" runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<script type="text/javascript">
		document.getElementById('<%= new SplendidCRM.DynamicControl(this, "lnkEMAIL").ClientID %>').href = 'mailto:?subject=<%= Server.HtmlEncode(sPageTitle) %>&body=' + escape(window.location.href);
	</script>
</div>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

