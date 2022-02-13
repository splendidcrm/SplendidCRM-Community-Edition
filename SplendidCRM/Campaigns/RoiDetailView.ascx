<%@ Control Language="c#" AutoEventWireup="false" Codebehind="RoiDetailView.ascx.cs" Inherits="SplendidCRM.Campaigns.RoiDetailView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divRoiDetailView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" Module="Campaigns" EnablePrint="true" HelpName="RoiDetailView" EnableHelp="true" Runat="Server" />

	<table ID="tblMain" class="tabDetailView" runat="server">
	</table>

	<div Visible="false" runat="server">
		<asp:HyperLink ID="lnkXML" NavigateUrl=<%# Application["rootURL"] + "Campaigns/xml/ReturnOnInvestment.aspx?ID=" + Request["ID"] + "&" %> Text="XML" Target="xml" Visible="<%# bDebug %>" runat="server" /><br />
	</div>
	<p></p>
	<%@ Register TagPrefix="SplendidCRM" Tagname="ReturnOnInvestmentHtml5" Src="~/Campaigns/html5/ReturnOnInvestment.ascx" %>
	<SplendidCRM:ReturnOnInvestmentHtml5 Runat="Server" />

<%@ Register TagPrefix="SplendidCRM" Tagname="ReturnOnInvestment" Src="~/Campaigns/xaml/ReturnOnInvestment.ascx" %>
<script type="text/xaml" id="xamlReturnOnInvestment"><?xml version="1.0"?>
<SplendidCRM:ReturnOnInvestment Visible="<%# false && SplendidCRM.Crm.Config.enable_silverlight() %>" Runat="Server" />
</script>
	<asp:Panel Visible="<%# false && SplendidCRM.Crm.Config.enable_silverlight() %>" runat="server">
		<div id="hostReturnOnInvestment" style="width: 800x; height: 400px; padding-bottom: 2px;" align="center"></div>
<SplendidCRM:InlineScript runat="server">
			<script type="text/javascript">
			Silverlight.createObjectEx({
				source: "#xamlReturnOnInvestment",
				parentElement: document.getElementById("hostReturnOnInvestment"),
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
	<p></p>
	<div Visible="<%# false && SplendidCRM.Crm.Config.enable_flash() %>" runat="server">
	<object id="vBarF" width="900" height="400" align="" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="https://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" viewastext>
		<param name="movie"   value="<%= Application["chartURL" ] %>vBarF.swf?filename=<%= Server.UrlEncode(Application["rootURL"] + "Campaigns/xml/ReturnOnInvestment.aspx?ID=" + gID.ToString() + "&") %>">
		<param name="bgcolor" value="#FFFFFF" />
		<param name="wmode"   value="transparent" />
		<param name="quality" value="high" />
		<embed src="<%= Application["chartURL" ] %>vBarF.swf?filename=<%= Server.UrlEncode(Application["rootURL"] + "Campaigns/xml/ReturnOnInvestment.aspx?ID=" + gID.ToString() + "&") %>" wmode="transparent" quality="high" bgcolor="#FFFFFF" height="400" width="900" name="vBarF" align="" type="application/x-shockwave-flash" pluginspage="https://www.macromedia.com/go/getflashplayer" />
	</object>
	</div>

	<div id="divDetailSubPanel">
		<asp:PlaceHolder ID="plcSubPanel" Runat="server" />
	</div>
</div>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

