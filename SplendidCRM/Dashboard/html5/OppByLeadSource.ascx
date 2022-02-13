<%@ Control CodeBehind="OppByLeadSource.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Dashboard.html5.OppByLeadSource" %>
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
<div id="divHtml5OppByLeadSource">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ChartDatePicker" Src="~/_controls/ChartDatePicker.ascx" %>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DashletHeader" Src="~/_controls/DashletHeader.ascx" %>
	<SplendidCRM:DashletHeader ID="ctlDashletHeader" Title="Dashboard.LBL_LEAD_SOURCE_FORM_TITLE" DivEditName="opp_lead_source_html5" ShowCommandTitles="true" Runat="Server" />
	<p></p>
	<div ID="opp_lead_source_html5" style="DISPLAY: <%= bShowEditDialog ? "inline" : "none" %>">
		<asp:Table ID="Table1" SkinID="tabFrame" HorizontalAlign="Center" CssClass="chartForm" runat="server">
			<asp:TableRow>
				<asp:TableCell VerticalAlign="top" Wrap="false"><b><%# L10n.Term("Dashboard.LBL_LEAD_SOURCES") %></b></asp:TableCell>
				<asp:TableCell VerticalAlign="top">
					<asp:ListBox ID="lstLEAD_SOURCE" DataValueField="NAME" DataTextField="DISPLAY_NAME" SelectionMode="Multiple" Rows="3" Runat="server" />
				</asp:TableCell>
				<asp:TableCell VerticalAlign="top" Wrap="false"><b><%# L10n.Term("Dashboard.LBL_USERS") %></b></asp:TableCell>
				<asp:TableCell VerticalAlign="top">
					<asp:ListBox ID="lstASSIGNED_USER_ID" DataValueField="ID" DataTextField="USER_NAME" SelectionMode="Multiple" Rows="3" Runat="server" />
				</asp:TableCell>
				<asp:TableCell VerticalAlign="top" HorizontalAlign="Right">
					<asp:Button ID="btnSubmit" CommandName="Submit" OnCommand="Page_Command"             CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SELECT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_SELECT_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SELECT_BUTTON_KEY") %>' runat="server" />
					<asp:Button ID="btnCancel" UseSubmitBehavior="false" OnClientClick="toggleDisplay('opp_lead_source_html5'); return false;" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_CANCEL_BUTTON_KEY") %>' runat="server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<p></p>
	<div align="center">
		<asp:HiddenField ID="hidSERIES_DATA" Value="{}" runat="server" />
		<asp:HiddenField ID="hidPIPELINE_TOTAL" runat="server" />

		<SplendidCRM:InlineScript runat="server">
		<script type="text/javascript">
		$(document).ready(function()
		{
			var data    = $.parseJSON(document.getElementById('<%# hidSERIES_DATA.ClientID %>').value);
			var options = 
			{ width: 600
			, height: 600
			, title: 
				{ show: true
				}
			, seriesDefaults: 
				{ renderer: jQuery.jqplot.PieRenderer
				, rendererOptions: 
					{ showDataLabels: true
					}
				}
			, legend: 
				{ show: true
				, location: 'e'
				, placement: 'insideGrid'
				}
			};
	
			try
			{
				options.title.text  = '<%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_TOTAL_PIPELINE")) %>';
				options.title.text += ' ' + document.getElementById('<%# hidPIPELINE_TOTAL.ClientID %>').value;
				options.title.text += '<%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_OPP_THOUSANDS")) %>';
				options.title.text += '<br/><%# Sql.EscapeJavaScript(L10n.Term("Dashboard.LBL_OPP_SIZE") + " " + 1.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS")) %>';
				var plot1 = $.jqplot('html5OppByLeadSource', [data], options);
				
				$('#html5OppByLeadSource').bind('jqplotDataClick', function(ev, seriesIndex, pointIndex, data)
				{
					var sLEAD_SOURCE   = '';
					var lstLEAD_SOURCE = document.getElementById('<%# lstLEAD_SOURCE.ClientID %>');
					for ( var i = 0; i < lstLEAD_SOURCE.options.length; i++ )
					{
						if ( lstLEAD_SOURCE.options[i].text == data[0] )
						{
							sLEAD_SOURCE = lstLEAD_SOURCE.options[i].value;
						}
					}
					window.location.href = sREMOTE_SERVER + 'Opportunities/default.aspx?LEAD_SOURCE=' + escape(sLEAD_SOURCE);
				});
				$("#html5OppByLeadSource").bind('jqplotDataHighlight', function(ev, seriesIndex, pointIndex, data)
				{
					var $this = $(this);
					$this.attr('title', data[0] + '\n' + data[2] + '\n' + data[3] + '\n' + data[4]);
				}); 
				$("#html5OppByLeadSource").bind('jqplotDataUnhighlight', function(ev, seriesIndex, pointIndex, data)
				{
					var $this = $(this);
					$this.attr('title', '');
				});
			}
			catch(e)
			{
				var divChartError = document.getElementById('divChartError_OppByLeadSource');
				divChartError.innerHTML = 'Chart error: ' + e.message;
			}
		});
		</script>
		</SplendidCRM:InlineScript>
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
		<div id="divChartError_OppByLeadSource" class="error"></div>
		<div id="html5OppByLeadSource" style="width: 700px; height: 400px; margin-top:20px; margin-left: auto; margin-right: auto; ">
		</div>
	</div>
	<span class="chartFootnote">
		<p align="center"><%# L10n.Term("Dashboard.LBL_LEAD_SOURCE_FORM_DESC") %></p>
		<p align="right"><i><%# L10n.Term("Dashboard.LBL_CREATED_ON") + T10n.FromServerTime(DateTime.Now).ToString() %></i></p>
	</span>
</div>

