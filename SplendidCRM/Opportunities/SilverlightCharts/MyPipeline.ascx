<%@ Control CodeBehind="MyPipeline.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Opportunities.SilverlightCharts.MyPipeline" %>
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
<div id="divOpportunitiesMyPipeline">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ChartDatePicker" Src="~/_controls/ChartDatePicker.ascx" %>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DashletHeader" Src="~/_controls/DashletHeader.ascx" %>
	<SplendidCRM:DashletHeader ID="ctlDashletHeader" Title="Home.LBL_PIPELINE_FORM_TITLE" DivEditName="my_pipeline_edit2" Runat="Server" />
	<p></p>
	<SplendidCRM:DatePickerValidator ID="valDATE_START" ControlToValidate="ctlDATE_START" CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Display="Dynamic" Runat="server" />
	<SplendidCRM:DatePickerValidator ID="valDATE_END"   ControlToValidate="ctlDATE_END"   CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Display="Dynamic" Runat="server" />
	<div ID="my_pipeline_edit2" style="DISPLAY: <%= bShowEditDialog ? "inline" : "none" %>">
		<asp:Table BorderWidth="0" CellPadding="0" CellSpacing="0" CssClass="chartForm" HorizontalAlign="Center" runat="server">
			<asp:TableRow>
				<asp:TableCell VerticalAlign="top" Wrap="false">
					<b><%# L10n.Term("Dashboard.LBL_DATE_START") %> </b><br />
					<asp:Label CssClass="dateFormat" Text='<%# System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.ShortDatePattern.ToUpper() %>' runat="server" />
				</asp:TableCell>
				<asp:TableCell VerticalAlign="top">
					<SplendidCRM:ChartDatePicker ID="ctlDATE_START" Runat="Server" />
				</asp:TableCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell VerticalAlign="top" Wrap="false">
					<b><%# L10n.Term("Dashboard.LBL_DATE_END") %></b><br />
					<asp:Label CssClass="dateFormat" Text='<%# System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.ShortDatePattern.ToUpper() %>' runat="server" />
				</asp:TableCell>
				<asp:TableCell VerticalAlign="top">
					<SplendidCRM:ChartDatePicker ID="ctlDATE_END" Runat="Server" />
				</asp:TableCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell VerticalAlign="top" Wrap="false"><b><%# L10n.Term("Dashboard.LBL_SALES_STAGES") %></b></asp:TableCell>
				<asp:TableCell VerticalAlign="top">
					<asp:ListBox ID="lstSALES_STAGE" DataValueField="NAME" DataTextField="DISPLAY_NAME" SelectionMode="Multiple" Rows="3" Runat="server" />
				</asp:TableCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell HorizontalAlign="Right" ColumnSpan="2">
					<asp:Button ID="btnSubmit" CommandName="Submit" OnCommand="Page_Command"                    CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SELECT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_SELECT_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SELECT_BUTTON_KEY") %>' runat="server" />
					<asp:Button ID="btnEdit"   UseSubmitBehavior="false" OnClientClick="toggleDisplay('my_pipeline_edit2'); return false;" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_CANCEL_BUTTON_KEY") %>' runat="server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<p></p>
	<div align="center">
<%@ Register TagPrefix="SplendidCRM" Tagname="MyPipelineBySalesStage" Src="~/Opportunities/xaml2/MyPipelineBySalesStage.ascx" %>
<script type="text/xaml" id="xamlMyPipelineBySalesStage2"><?xml version="1.0"?>
<SplendidCRM:MyPipelineBySalesStage Runat="Server" />
</script>
	<asp:Panel Visible="true" runat="server">
		<div id="hostMyPipelineBySalesStage2" style="width: 350px; height: 400px; padding-bottom: 2px;" align="center"></div>
<SplendidCRM:InlineScript runat="server">
			<script type="text/javascript">
			Silverlight.createObjectEx({
				source: "<%= Application["rootURL" ] %>ClientBin/SilverlightContainer.xap",
				parentElement: document.getElementById("hostMyPipelineBySalesStage2"),
				id: "SilverlightControl",
				properties:
				{
					width: "350",
					height: "400",
					version: "3.0",
					enableHtmlAccess: "true",
					isWindowless: "true" /* 05/08/2010 Paul.  The isWindowless allows HTML to appear over a silverlight app. */
				},
				events:
				{
				},
				initParams: "xamlContent=xamlMyPipelineBySalesStage2",
				context: "none"
			});
			</script>
</SplendidCRM:InlineScript>
	</asp:Panel>
	</div>
	<span class="chartFootnote">
		<p align="center"><%# L10n.Term("Dashboard.LBL_PIPELINE_FORM_TITLE_DESC") %></p>
		<p aligh="right"><i><%# L10n.Term("Dashboard.LBL_CREATED_ON") + T10n.FromServerTime(DateTime.Now).ToString() %></i></p>
	</span>
</div>

