<%@ Control CodeBehind="OppByLeadSourceByOutcome.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Dashboard.OppByLeadSourceByOutcome" %>
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
<div id="divDashboardOpportunityByLeadSourceByOutcome">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ChartDatePicker" Src="~/_controls/ChartDatePicker.ascx" %>
	<%@ Register TagPrefix="SplendidCRM" Tagname="ChartHeader" Src="~/_controls/ChartHeader.ascx" %>
	<SplendidCRM:ChartHeader Title="Dashboard.LBL_LEAD_SOURCE_BY_OUTCOME" DivEditName="lsbo_edit" Runat="Server" />
	<p></p>
	<div ID="lsbo_edit" style="DISPLAY: <%= bShowEditDialog ? "inline" : "none" %>">
		<asp:Table SkinID="tabFrame" HorizontalAlign="Center" CssClass="chartForm" runat="server">
			<asp:TableRow>
				<asp:TableCell VerticalAlign="top" Wrap="false"><b><%# L10n.Term("Dashboard.LBL_LEAD_SOURCES") %></b></asp:TableCell>
				<asp:TableCell VerticalAlign="top">
					<asp:ListBox ID="lstLEAD_SOURCE" DataValueField="NAME" DataTextField="DISPLAY_NAME" SelectionMode="Multiple" Rows="3" Runat="server" />
				</asp:TableCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell VerticalAlign="top" Wrap="false"><b><%# L10n.Term("Dashboard.LBL_USERS") %></b></asp:TableCell>
				<asp:TableCell VerticalAlign="top">
					<asp:ListBox ID="lstASSIGNED_USER_ID" DataValueField="ID" DataTextField="USER_NAME" SelectionMode="Multiple" Rows="3" Runat="server" />
				</asp:TableCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell HorizontalAlign="Right" ColumnSpan="2">
					<asp:Button ID="btnSubmit" CommandName="Submit" OnCommand="Page_Command"             CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SELECT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_SELECT_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SELECT_BUTTON_KEY") %>' Runat="server" />
					<asp:Button ID="btnCancel" UseSubmitBehavior="false" OnClientClick="toggleDisplay('lsbo_edit'); return false;" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_CANCEL_BUTTON_KEY") %>' runat="server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<p></p>
	<div Visible="<%# bDebug %>" align="center" runat="server">
		<asp:HyperLink ID="lnkXML" NavigateUrl=<%# Application["rootURL"] + "Opportunities/xml/OppByLeadSourceByOutcome.aspx?" + ViewState["OppByLeadSourceByOutcomeQueryString"] %> Text="XML" Target="xml" Visible="<%# bDebug %>" runat="server" /><br />
	</div>
	<div align="center">
<%@ Register TagPrefix="SplendidCRM" Tagname="OppByLeadSourceByOutcome" Src="~/Opportunities/xaml/OppByLeadSourceByOutcome.ascx" %>
<script type="text/xaml" id="xamlOppByLeadSourceByOutcome"><?xml version="1.0"?>
<SplendidCRM:OppByLeadSourceByOutcome CHART_LENGTH="10" Visible="<%# SplendidCRM.Crm.Config.enable_silverlight() %>" Runat="Server" />
</script>
	<asp:Panel Visible="<%# SplendidCRM.Crm.Config.enable_silverlight() %>" runat="server">
		<div id="hostOppByLeadSourceByOutcome" style="width: 800x; height: 400px; padding-bottom: 2px;" align="center"></div>
<SplendidCRM:InlineScript runat="server">
			<script type="text/javascript">
			Silverlight.createObjectEx({
				source: "#xamlOppByLeadSourceByOutcome",
				parentElement: document.getElementById("hostOppByLeadSourceByOutcome"),
				id: "SilverlightControl",
				properties: {
					width: "800",
					height: "400",
					version: "1.0",
					enableHtmlAccess: "true",
					isWindowless: "true" /* 05/08/2010 Paul.  The isWindowless allows HTML to appear over a silverlight app. */
				},
				events: {}
			});
			</script>
</SplendidCRM:InlineScript>
	</asp:Panel>
	</div>
	<div align="center" Visible="<%# SplendidCRM.Crm.Config.enable_flash() %>" runat="server">
	<object width="800" height="400" align="" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="https://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" viewastext>
		<param name="movie"   value="<%= Application["chartURL" ] %>hBarF.swf?filename=<%= Server.UrlEncode(Application["rootURL"] + "Opportunities/xml/OppByLeadSourceByOutcome.aspx?" + ViewState["OppByLeadSourceByOutcomeQueryString"]) %>">
		<param name="bgcolor" value="#FFFFFF" />
		<param name="wmode"   value="transparent" />
		<param name="quality" value="high" />
		<embed src="<%= Application["chartURL" ] %>hBarF.swf?filename=<%= Server.UrlEncode(Application["rootURL"] + "Opportunities/xml/OppByLeadSourceByOutcome.aspx?" + ViewState["OppByLeadSourceByOutcomeQueryString"]) %>" wmode="transparent" quality=high bgcolor=#FFFFFF  WIDTH="800" HEIGHT="400" NAME="hBarF" ALIGN="" TYPE="application/x-shockwave-flash" PLUGINSPAGE="https://www.macromedia.com/go/getflashplayer" />
	</object>
	</div>
	<span class="chartFootnote">
		<p align="center"><%# L10n.Term("Dashboard.LBL_LEAD_SOURCE_BY_OUTCOME_DESC") %></p>
		<p align="right"><i><%# L10n.Term("Dashboard.LBL_CREATED_ON") + T10n.FromServerTime(DateTime.Now).ToString() %></i></p>
	</span>
</div>

