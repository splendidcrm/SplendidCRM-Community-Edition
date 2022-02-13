<%@ Control Language="c#" AutoEventWireup="false" Codebehind="DetailView.ascx.cs" Inherits="SplendidCRM.Administration.Config.DetailView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" Module="Administration" EnablePrint="true" HelpName="DetailView" EnableHelp="true" Runat="Server" />

	<table class="tabDetailView">
		<tr>
			<td width="15%"  valign="top" class="tabDetailViewDL"><%= L10n.Term("Config.LBL_NAME"    ) %></td>
			<td width="35%"  valign="top" class="tabDetailViewDF"><asp:Label ID="txtNAME"     Runat="server" /></td>
			<td width="15%"  valign="top" class="tabDetailViewDL"><%= L10n.Term("Config.LBL_CATEGORY") %></td>
			<td width="35%"  valign="top" class="tabDetailViewDF"><asp:Label ID="txtCATEGORY" Runat="server" /></td>
		</tr>
		<tr>
			<td valign="top" class="tabDetailViewDL"><%= L10n.Term("Config.LBL_VALUE") %></td>
			<td colspan="3" class="tabDetailViewDF"><asp:Label ID="txtVALUE" Runat="server" /></td>
		</tr>
	</table>
</div>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

