<%@ Control CodeBehind="PipelineBySalesStage.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Dashboard.html5.PipelineBySalesStage" %>
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
<div id="divHtml5PipelineBySalesStage">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ChartDatePicker" Src="~/_controls/ChartDatePicker.ascx" %>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DashletHeader" Src="~/_controls/DashletHeader.ascx" %>
	<SplendidCRM:DashletHeader ID="ctlDashletHeader" Title="Dashboard.LBL_SALES_STAGE_FORM_TITLE" DivEditName="pipeline_by_sales_stage_edit_html5" ShowCommandTitles="true" Runat="Server" />
	<p></p>
	<div ID="pipeline_by_sales_stage_edit_html5" style="DISPLAY: <%= bShowEditDialog ? "inline" : "none" %>">
		<asp:Table ID="Table1" SkinID="tabFrame" HorizontalAlign="Center" CssClass="chartForm" runat="server">
			<asp:TableRow>
				<asp:TableCell VerticalAlign="top" Wrap="false">
					<b><%# L10n.Term("Dashboard.LBL_DATE_START") %></b><br />
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
				<asp:TableCell VerticalAlign="top" Wrap="false"><b><%# L10n.Term("Dashboard.LBL_USERS") %></b></asp:TableCell>
				<asp:TableCell VerticalAlign="top">
					<asp:ListBox ID="lstASSIGNED_USER_ID" DataValueField="ID" DataTextField="USER_NAME" SelectionMode="Multiple" Rows="3" Runat="server" />
				</asp:TableCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell HorizontalAlign="Right" ColumnSpan="2">
					<asp:Button ID="btnSubmit" CommandName="Submit" OnCommand="Page_Command"                                CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SELECT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_SELECT_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SELECT_BUTTON_KEY") %>' runat="server" />
					<asp:Button ID="btnCancel" UseSubmitBehavior="false" OnClientClick="toggleDisplay('pipeline_by_sales_stage_edit2'); return false;" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_CANCEL_BUTTON_KEY") %>' runat="server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<p></p>
	<div align="center">
		<asp:HiddenField ID="hidSERIES_DATA" Value="{}" runat="server" />
		<asp:HiddenField ID="hidACTIVE_USERS" runat="server" />
		<asp:HiddenField ID="hidPIPELINE_TOTAL" runat="server" />
		<%@ Register TagPrefix="SplendidCRM" Tagname="FormatDateJavaScript" Src="~/_controls/FormatDateJavaScript.ascx" %>
		<SplendidCRM:FormatDateJavaScript Runat="Server" />

		<SplendidCRM:InlineScript runat="server">
		<script type="text/javascript">
		$(document).ready(function()
		{
			var arrSalesStage = new Array();
			var lstSALES_STAGE = document.getElementById('<%# lstSALES_STAGE.ClientID %>');
			for ( var i = 0; i < lstSALES_STAGE.options.length; i++ )
			{
				if ( lstSALES_STAGE.options[i].selected )
					arrSalesStage.unshift(lstSALES_STAGE.options[i].text);
			}

			var sCurrencyPrefix = '<%# GetCurrencyPrefix() %>';
			var sCurrencySuffix = '<%# GetCurrencySuffix() %>';
			var data    = $.parseJSON(document.getElementById('<%# hidSERIES_DATA.ClientID %>').value);
			var users   = $.parseJSON(document.getElementById('<%# hidACTIVE_USERS.ClientID %>').value);
			var arrSeriesUsers = new Array();
			if ( $.isArray(users) )
			{
				for ( var i = 0; i < users.length; i++ )
				{
					var user = new Object();
					user.label = users[i];
					arrSeriesUsers.push(user);
				}
			}

			var options = 
			{ stackSeries: true
			, width: 600
			, height: 600
			, title: 
				{ show: true
				}
			, cursor: 
				{ show: true
				, zoom: true
				}
			, seriesDefaults: 
				{ renderer: $.jqplot.BarRenderer
				, rendererOptions: 
					{ barDirection: 'horizontal'
					, fillToZero: true
					}
				}
			, series: arrSeriesUsers
			, legend: 
				{ show: true
				, placement: 'outsideGrid'
				, location: 'e'
				}
			, axes: 
				{ yaxis: 
					{ show: true
					, tickRenderer: $.jqplot.CanvasAxisTickRenderer
					, label: ''
					, renderer: $.jqplot.CategoryAxisRenderer
					, ticks: arrSalesStage
					}
				, xaxis: 
					{ show: false
					, label: ''
					, tickOptions: 
						{ formatString: '%.1f'
						, prefix: sCurrencyPrefix
						, suffix: sCurrencySuffix
						}
					}
				}
			};
	
			try
			{
				var sStartDate = document.getElementById('<%# ctlDATE_START.DateClientID %>').value;
				var sEndDate   = document.getElementById('<%# ctlDATE_END.DateClientID   %>').value;
				options.axes.xaxis.label  = '<%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_DATE_RANGE")) %>';
				options.axes.xaxis.label += ' ' + sStartDate + ' ';
				options.axes.xaxis.label += '<%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_DATE_RANGE_TO")) %>';
				options.axes.xaxis.label += ' ' + sEndDate + ' ';
				options.axes.xaxis.label += '<br/><%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_OPP_SIZE") + " " + 1.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS")) %>';
				
				options.title.text  = '<%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_TOTAL_PIPELINE")) %>';
				options.title.text += ' ' + document.getElementById('<%# hidPIPELINE_TOTAL.ClientID %>').value;
				options.title.text += '<%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_OPP_THOUSANDS")) %>';
				var plot1 = $.jqplot('html5PipelineBySalesStage', data, options);
				
				$('#html5PipelineBySalesStage').bind('jqplotDataClick', function(ev, seriesIndex, pointIndex, data)
				{
					var sSALES_STAGE        = '';
					var sASSIGNED_USER_ID   = '';
					var lstSALES_STAGE      = document.getElementById('<%# lstSALES_STAGE.ClientID      %>');
					var lstASSIGNED_USER_ID = document.getElementById('<%# lstASSIGNED_USER_ID.ClientID %>');
					for ( var i = 0; i < lstSALES_STAGE.options.length; i++ )
					{
						if ( lstSALES_STAGE.options[i].text == arrSalesStage[pointIndex] )
						{
							sSALES_STAGE = lstSALES_STAGE.options[i].value;
						}
					}
					for ( var i = 0; i < lstASSIGNED_USER_ID.options.length; i++ )
					{
						if ( lstASSIGNED_USER_ID.options[i].text == options.series[seriesIndex].label )
						{
							sASSIGNED_USER_ID = lstASSIGNED_USER_ID.options[i].value;
						}
					}
					window.location.href = sREMOTE_SERVER + 'Opportunities/default.aspx?SALES_STAGE=' + escape(sSALES_STAGE) + '&ASSIGNED_USER_ID=' + escape(sASSIGNED_USER_ID);
				});
				$("#html5PipelineBySalesStage").bind('jqplotDataHighlight', function(ev, seriesIndex, pointIndex, data)
				{
					var $this = $(this);
					var sValue = options.axes.xaxis.tickOptions.prefix + $.jqplot.DefaultTickFormatter(options.axes.xaxis.tickOptions.formatString, data[0]) + options.axes.xaxis.tickOptions.suffix;
					$this.attr('title', sValue + '\n' + options.series[seriesIndex].label + '\n' + arrSalesStage[pointIndex]);
				}); 
				$("#html5PipelineBySalesStage").bind('jqplotDataUnhighlight', function(ev, seriesIndex, pointIndex, data)
				{
					var $this = $(this);
					$this.attr('title', '');
				});
			}
			catch(e)
			{
				var divChartError = document.getElementById('divChartError_PipelineBySalesStage');
				divChartError.innerHTML = 'Chart error: ' + e.message;
			}
		});
		</script>
		</SplendidCRM:InlineScript>
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
		<div id="divChartError_PipelineBySalesStage" class="error"></div>
		<div id="html5PipelineBySalesStage" style="width: 700px; height: 400px; margin-top:20px; margin-left: auto; margin-right: auto; ">
		</div>
	</div>
	<span class="chartFootnote">
		<p align="center"><%# L10n.Term("Dashboard.LBL_PIPELINE_FORM_TITLE_DESC") %></p>
		<p align="right"><i><%# L10n.Term("Dashboard.LBL_CREATED_ON") + T10n.FromServerTime(DateTime.Now).ToString() %></i></p>
	</span>
</div>

