<%@ Control Language="c#" AutoEventWireup="false" Codebehind="DetailView.ascx.cs" Inherits="SplendidCRM.Administration.Schedulers.DetailView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" Module="Schedulers" Title="Schedulers.LBL_MODULE_TITLE" EnablePrint="true" HelpName="DetailView" EnableHelp="true" Runat="Server" />

	<asp:Table Width="100%" CellPadding="0" CellSpacing="0" CssClass="tabDetailView" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="15%" VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term("Schedulers.LBL_JOB"   ) %></asp:TableCell>
			<asp:TableCell Width="35%" VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="JOB"    Runat="server" /></asp:TableCell>
			<asp:TableCell Width="15%" VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term("Schedulers.LBL_STATUS") %></asp:TableCell>
			<asp:TableCell Width="35%" VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="STATUS" Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term("Schedulers.LBL_DATE_TIME_START") %></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="DATE_TIME_START" Runat="server" /></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term("Schedulers.LBL_TIME_FROM"      ) %></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="TIME_FROM"       Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term("Schedulers.LBL_DATE_TIME_END") %></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="DATE_TIME_END" Runat="server" /></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term("Schedulers.LBL_TIME_TO"      ) %></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="TIME_TO"       Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term("Schedulers.LBL_LAST_RUN") %></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="LAST_RUN"     Runat="server" /></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term("Schedulers.LBL_INTERVAL") %></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="JOB_INTERVAL" Runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term("Schedulers.LBL_CATCH_UP"    ) %></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="CATCH_UP"     Runat="server" /></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDL">&nbsp;</asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDF">&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term(".LBL_DATE_ENTERED" ) %></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="DATE_ENTERED"  Runat="server" /></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDL"><%= L10n.Term(".LBL_DATE_MODIFIED") %></asp:TableCell>
			<asp:TableCell VerticalAlign="Top" CssClass="tabDetailViewDF"><asp:Label ID="DATE_MODIFIED" Runat="server" /></asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

