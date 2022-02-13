<%@ Page language="c#" MasterPageFile="~/DefaultView.Master" Codebehind="PhoneSearch.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Home.PhoneSearch" %>
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
</asp:Content>

<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
	<script type="text/javascript">
	// 08/26/2010 Paul.  We need to count the visible search panels in JavaScript as we do not have an easy way to get the visible count in the code-behind. 
	var nPhoneSearchVisibleCount = 0;
	var sPhoneSearchURL = '';
	</script>
	<div id="divListView">
		<%@ Register TagPrefix="SplendidCRM" Tagname="ModuleHeader" Src="~/_controls/ModuleHeader.ascx" %>
		<SplendidCRM:ModuleHeader ID="ctlModuleHeader" Module="Search" Title="Home.LBL_SEARCH_RESULTS" EnableModuleLabel="false" EnablePrint="true" EnableHelp="true" Runat="Server" />
		
		<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
			<asp:Label ID="lblWarning" CssClass="error" EnableViewState="false" Runat="server" />
		</asp:Panel>
		
		<div id="divDetailSubPanel">
			<asp:PlaceHolder ID="plcSubPanel" Runat="server" />
		</div>
		<asp:Label ID="lblNoResults" Text='<%# L10n.Term(".LBL_EMAIL_SEARCH_NO_RESULTS") %>' CssClass="error" style="display:none" Runat="server" />
		<script type="text/javascript">
		if ( nPhoneSearchVisibleCount == 0 )
		{
			var lblNoResults = document.getElementById('<%# lblNoResults.ClientID %>');
			lblNoResults.style.display = 'inline';
		}
		// 07/08/2012 Paul.  If there is only one record found, then navigate to that record. 
		else if ( nPhoneSearchVisibleCount == 1 )
		{
			window.location.href = sPhoneSearchURL;
		}
		</script>

		<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
		<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
	</div>
</asp:Content>

