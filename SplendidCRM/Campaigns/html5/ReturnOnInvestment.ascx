<%@ Control CodeBehind="ReturnOnInvestment.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Dashboard.html5.ReturnOnInvestment" %>
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
<div id="divHtml5ReturnOnInvestment">
	<div align="center">
		<asp:HiddenField ID="hidSERIES_DATA" Value="{}" runat="server" />

		<SplendidCRM:InlineScript runat="server">
		<script type="text/javascript">
		$(document).ready(function()
		{
			var sCurrencyPrefix = '<%# GetCurrencyPrefix() %>';
			var sCurrencySuffix = '<%# GetCurrencySuffix() %>';
			var sRevenue        = '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".roi_type_dom.", "Revenue"         ))) %>';
			var sInvestment     = '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".roi_type_dom.", "Investment"      ))) %>';
			var sExpected       = '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".roi_type_dom.", "Expected_Revenue"))) %>';
			var sBudget         = '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".roi_type_dom.", "Budget"          ))) %>';
			var data            = $.parseJSON(document.getElementById('<%# hidSERIES_DATA.ClientID %>').value);
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
				[ { label: sRevenue   , value: 'Revenue'         }
				, { label: sInvestment, value: 'Investment'      }
				, { label: sExpected  , value: 'Expected_Revenue'}
				, { label: sBudget    , value: 'Budget'          }
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
					, ticks: [sRevenue, sInvestment, sExpected, sBudget]
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
				//options.axes.xaxis.label = '<%# Sql.EscapeJavaScript(L10n.Term("Campaigns.LBL_ROLLOVER_VIEW")) %>';
				options.title.text       = '<%# Sql.EscapeJavaScript(L10n.Term("Campaigns.LBL_CAMPAIGN_RETURN_ON_INVESTMENT")) %>';
				var plot1 = $.jqplot('html5ReturnOnInvestment', data, options);
				
				$('#html5ReturnOnInvestment').bind('jqplotDataClick', function(ev, seriesIndex, pointIndex, data)
				{
					window.location.href = '#' + escape(options.series[seriesIndex].value);
				});
				$("#html5ReturnOnInvestment").bind('jqplotDataHighlight', function(ev, seriesIndex, pointIndex, data)
				{
					var $this = $(this);
					var sValue = options.axes.yaxis.tickOptions.prefix + $.jqplot.DefaultTickFormatter(options.axes.yaxis.tickOptions.formatString, data[1]) + options.axes.yaxis.tickOptions.suffix;
					$this.attr('title', options.series[seriesIndex].label + '\n' + sValue);
				}); 
				$("#html5ReturnOnInvestment").bind('jqplotDataUnhighlight', function(ev, seriesIndex, pointIndex, data)
				{
					var $this = $(this);
					$this.attr('title', '');
				});
			}
			catch(e)
			{
				var divChartError = document.getElementById('divChartError_ReturnOnInvestment');
				divChartError.innerHTML = 'Chart error: ' + e.message;
			}
		});
		</script>
		</SplendidCRM:InlineScript>
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
		<div id="divChartError_ReturnOnInvestment" class="error"></div>
		<div id="html5ReturnOnInvestment" style="width: 700px; height: 400px; margin-top:20px; margin-left: auto; margin-right: auto; ">
		</div>
	</div>
</div>

