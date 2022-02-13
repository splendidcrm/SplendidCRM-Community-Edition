<%@ Control CodeBehind="PipelineByMonthByOutcome.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Dashboard.html5.PipelineByMonthByOutcome" %>
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
<div id="divHtml5PipelineByMonthByOutcome">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ChartDatePicker" Src="~/_controls/ChartDatePicker.ascx" %>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DashletHeader" Src="~/_controls/DashletHeader.ascx" %>
	<SplendidCRM:DashletHeader ID="ctlDashletHeader" Title="Dashboard.LBL_YEAR_BY_OUTCOME" DivEditName="outcome_by_month_edit_html5" ShowCommandTitles="true" Runat="Server" />
	<p></p>
	<div ID="outcome_by_month_edit_html5" style="DISPLAY: <%= bShowEditDialog ? "inline" : "none" %>">
		<asp:Table SkinID="tabFrame" HorizontalAlign="Center" CssClass="chartForm" runat="server">
			<asp:TableRow>
				<asp:TableCell VerticalAlign="top" Wrap="false"><b><%# L10n.Term("Dashboard.LBL_YEAR") %></b><br /><span class="dateFormat">(yyyy)</span></asp:TableCell>
				<asp:TableCell VerticalAlign="top">
					<asp:TextBox ID="txtYEAR" MaxLength="10" size="12" Runat="server" />
				</asp:TableCell>
				<asp:TableCell VerticalAlign="top" Wrap="false"><b><%# L10n.Term("Dashboard.LBL_USERS") %></b></asp:TableCell>
				<asp:TableCell VerticalAlign="top">
					<asp:ListBox ID="lstASSIGNED_USER_ID" DataValueField="ID" DataTextField="USER_NAME" SelectionMode="Multiple" Rows="3" Runat="server" />
				</asp:TableCell>
				<asp:TableCell VerticalAlign="top" HorizontalAlign="Right">
					<asp:Button ID="btnSubmit" CommandName="Submit" OnCommand="Page_Command"                         CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SELECT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_SELECT_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SELECT_BUTTON_KEY") %>' runat="server" />
					<asp:Button ID="btnCancel" UseSubmitBehavior="false" OnClientClick="toggleDisplay('outcome_by_month_edit_html5'); return false;" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_CANCEL_BUTTON_KEY") %>' runat="server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<p></p>
	<div align="center">
		<asp:HiddenField ID="hidSERIES_DATA" Value="{}" runat="server" />
		<asp:HiddenField ID="hidPIPELINE_TOTAL" runat="server" />
		<%@ Register TagPrefix="SplendidCRM" Tagname="FormatDateJavaScript" Src="~/_controls/FormatDateJavaScript.ascx" %>
		<SplendidCRM:FormatDateJavaScript Runat="Server" />

		<SplendidCRM:InlineScript runat="server">
		<script type="text/javascript">
		$(document).ready(function()
		{
			var data    = $.parseJSON(document.getElementById('<%# hidSERIES_DATA.ClientID %>').value);
			var sCurrencyPrefix = '<%# GetCurrencyPrefix() %>';
			var sCurrencySuffix = '<%# GetCurrencySuffix() %>';
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
					{ barDirection: 'vertical'
					, fillToZero: true
					}
				}
			, series: 
				[ { label: '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".sales_stage_dom.", "Closed Lost"))) %>', value: 'Closed Lost' }
				, { label: '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".sales_stage_dom.", "Closed Won" ))) %>', value: 'Closed Won'  }
				, { label: '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".sales_stage_dom.", "Other"      ))) %>', value: 'Other'       }
				]
			, legend: 
				{ show: true
				, placement: 'outsideGrid'
				, location: 'e'
				}
			, axes: 
				{ xaxis: 
					{ show: true
					, tickRenderer: $.jqplot.CanvasAxisTickRenderer
					, label: ''
					, renderer: $.jqplot.CategoryAxisRenderer
					, tickOptions: 
						{ angle: -30
						}
					, ticks: ['<%# String.Join("', '", Sql.EscapeJavaScript(System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.MonthNames)) %>']
					}
				, yaxis: 
					{ show: false
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
				var nYear = parseInt(document.getElementById('<%# txtYEAR.ClientID %>').value);
				if ( nYear < 1900 )
					nYear = 1900;
				else if ( nYear > 2100 )
					nYear = 2100;
				var dtStartDate = new Date(nYear,  0,  1);
				var dtEndDate   = new Date(nYear, 11, 31);
				var sShortDatePattern = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.ShortDatePattern %>';
				var sStartDate = formatDate(dtStartDate, sShortDatePattern);
				var sEndDate   = formatDate(dtEndDate  , sShortDatePattern);
				options.axes.xaxis.label  = '<%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_DATE_RANGE")) %>';
				options.axes.xaxis.label += ' ' + sStartDate + ' ';
				options.axes.xaxis.label += '<%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_DATE_RANGE_TO")) %>';
				options.axes.xaxis.label += ' ' + sEndDate + ' ';
				options.axes.xaxis.label += '<br/><%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_OPP_SIZE") + " " + 1.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS")) %>';
				
				options.title.text  = '<%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_TOTAL_PIPELINE")) %>';
				options.title.text += ' ' + document.getElementById('<%# hidPIPELINE_TOTAL.ClientID %>').value;
				options.title.text += '<%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_OPP_THOUSANDS")) %>';
				// 01/05/2015 Paul.  DateTimeFormat.MonthNames is a 13 item array. 
				options.axes.xaxis.ticks.pop();
				var plot1 = $.jqplot('html5PipelineByMonthByOutcome', data, options);
				
				$('#html5PipelineByMonthByOutcome').bind('jqplotDataClick', function(ev, seriesIndex, pointIndex, data)
				{
					var dtDate = new Date(nYear,  pointIndex,  1);
					var sDate  = formatDate(dtDate, sShortDatePattern);
					window.location.href = sREMOTE_SERVER + 'Opportunities/default.aspx?DATE_CLOSED=' + escape(sDate) + '&SALES_STAGE=' + escape(options.series[seriesIndex].value);
				});
				$("#html5PipelineByMonthByOutcome").bind('jqplotDataHighlight', function(ev, seriesIndex, pointIndex, data)
				{
					var $this = $(this);
					var dtDate = new Date(nYear,  pointIndex,  1);
					var sDate  = formatDate(dtDate, sShortDatePattern);
					var sValue = options.axes.yaxis.tickOptions.prefix + $.jqplot.DefaultTickFormatter(options.axes.yaxis.tickOptions.formatString, data[1]) + options.axes.yaxis.tickOptions.suffix;
					$this.attr('title', options.series[seriesIndex].label + '\n' + sDate + '\n' + sValue);
				}); 
				$("#html5PipelineByMonthByOutcome").bind('jqplotDataUnhighlight', function(ev, seriesIndex, pointIndex, data)
				{
					var $this = $(this);
					$this.attr('title', '');
				});
			}
			catch(e)
			{
				var divChartError = document.getElementById('divChartError_PipelineByMonthByOutcome');
				divChartError.innerHTML = 'Chart error: ' + e.message;
			}
		});
		</script>
		</SplendidCRM:InlineScript>
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
		<div id="divChartError_PipelineByMonthByOutcome" class="error"></div>
		<div id="html5PipelineByMonthByOutcome" style="width: 700px; height: 400px; margin-top:20px; margin-left: auto; margin-right: auto; ">
		</div>
	</div>
	<span class="chartFootnote">
		<p align="center"><%# L10n.Term("Dashboard.LBL_MONTH_BY_OUTCOME_DESC") %></p>
		<p align="right"><i><%# L10n.Term("Dashboard.LBL_CREATED_ON") + T10n.FromServerTime(DateTime.Now).ToString() %></i></p>
	</span>
</div>

