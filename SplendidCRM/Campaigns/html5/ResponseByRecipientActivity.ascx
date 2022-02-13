<%@ Control CodeBehind="ResponseByRecipientActivity.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Dashboard.html5.ResponseByRecipientActivity" %>
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
<div id="divHtml5ResponseByRecipientActivity">
	<div align="center">
		<asp:HiddenField ID="hidSERIES_DATA" Value="{}" runat="server" />
		<div style="display: none">
			<asp:ListBox ID="lstACTIVITY_TYPE" DataValueField="NAME" DataTextField="DISPLAY_NAME" SelectionMode="Multiple" Rows="3" Runat="server" />
		</div>

		<SplendidCRM:InlineScript runat="server">
		<script type="text/javascript">
		$(document).ready(function()
		{
			var arrActivityType = new Array();
			var arrActivityTypeValue = new Array();
			var lstACTIVITY_TYPE = document.getElementById('<%# lstACTIVITY_TYPE.ClientID %>');
			for ( var i = 0; i < lstACTIVITY_TYPE.options.length; i++ )
			{
				if ( lstACTIVITY_TYPE.options[i].selected )
				{
					arrActivityType.unshift(lstACTIVITY_TYPE.options[i].text);
					arrActivityTypeValue.unshift(lstACTIVITY_TYPE.options[i].value);
				}
			}

			var data    = $.parseJSON(document.getElementById('<%# hidSERIES_DATA.ClientID %>').value);

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
				, pointLabels: 
					{ show: true
					, stackedValue: true
					, edgeTolerence: -15
					}
				}
			, series: 
				[ { label: '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".moduleList.", "Contacts" ))) %>', value: 'Contacts' }
				, { label: '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".moduleList.", "Leads"    ))) %>', value: 'Leads'    }
				, { label: '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".moduleList.", "Prospects"))) %>', value: 'Prospects'}
				, { label: '<%# Sql.EscapeJavaScript(Sql.ToString(L10n.Term(".moduleList.", "Users"    ))) %>', value: 'Users'    }
				]
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
					, ticks: arrActivityType
					}
				, xaxis: 
					{ show: false
					, tickOptions: 
						{ formatString: '%d'
						}
					}
				}
			};
	
			try
			{
				//options.axes.xaxis.label = '<%# Sql.EscapeJavaScript(L10n.Term("Campaigns.LBL_ROLLOVER_VIEW")) %>';
				options.title.text       = '<%# Sql.EscapeJavaScript(L10n.Term("Campaigns.LBL_CAMPAIGN_RESPONSE_BY_RECIPIENT_ACTIVITY")) %>';
				var plot1 = $.jqplot('html5ResponseByRecipientActivity', data, options);
				
				$('#html5ResponseByRecipientActivity').bind('jqplotDataClick', function(ev, seriesIndex, pointIndex, data)
				{
					window.location.href = '#CampaignBookmark_' + arrActivityTypeValue[pointIndex].replace(' ', '_');
				});
				$("#html5ResponseByRecipientActivity").bind('jqplotDataHighlight', function(ev, seriesIndex, pointIndex, data)
				{
					var $this = $(this);
					var sValue = $.jqplot.DefaultTickFormatter(options.axes.xaxis.tickOptions.formatString, data[0]);
					$this.attr('title', sValue + '\n' + options.series[seriesIndex].label + '\n' + arrActivityType[pointIndex]);
				}); 
				$("#html5ResponseByRecipientActivity").bind('jqplotDataUnhighlight', function(ev, seriesIndex, pointIndex, data)
				{
					var $this = $(this);
					$this.attr('title', '');
				});
			}
			catch(e)
			{
				var divChartError = document.getElementById('divChartError_ResponseByRecipientActivity');
				divChartError.innerHTML = 'Chart error: ' + e.message;
			}
		});
		</script>
		</SplendidCRM:InlineScript>
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
		<div id="divChartError_ResponseByRecipientActivity" class="error"></div>
		<div id="html5ResponseByRecipientActivity" style="width: 700px; height: 400px; margin-top:20px; margin-left: auto; margin-right: auto; ">
		</div>
	</div>
</div>

