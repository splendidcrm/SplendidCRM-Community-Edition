/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

define(function()
{
	var sMONTHYEAR_FORMAT          = Security.USER_DATE_FORMAT();
	var oNumberFormat              = Security.NumberFormatInfo();
	var sLBL_CLOSED_LOST           = L10n.ListTerm('sales_stage_dom', 'Closed Lost');
	var sLBL_CLOSED_WON            = L10n.ListTerm('sales_stage_dom', 'Closed Won' );
	var sLBL_OTHER                 = L10n.ListTerm('sales_stage_dom', 'Other'      );
	var sLBL_OPP_SIZE              = L10n.Term('Dashboard.LBL_OPP_SIZE'             );
	var sLBL_OPP_THOUSANDS         = L10n.Term('Dashboard.LBL_OPP_THOUSANDS'        );
	var sLBL_TOTAL_PIPELINE        = L10n.Term('Dashboard.LBL_TOTAL_PIPELINE'       );
	var sLBL_DATE_RANGE            = L10n.Term('Dashboard.LBL_DATE_RANGE'           );
	var sLBL_DATE_RANGE_TO         = L10n.Term('Dashboard.LBL_DATE_RANGE_TO'        );
	var sLBL_MONTH_BY_OUTCOME_DESC = L10n.Term('Dashboard.LBL_MONTH_BY_OUTCOME_DESC');

	return {
		Render: function(sLayoutPanel, sActionsPanel, sSCRIPT_URL, sSETTINGS_EDITVIEW, sDEFAULT_SETTINGS)
		{
			var divDashboardPanel = document.getElementById(sLayoutPanel);
			if ( divDashboardPanel != null )
			{
				var divChartBody = document.createElement('div');
				divChartBody.id = sLayoutPanel + '_divChartBody';
				divChartBody.align = 'center';
				divDashboardPanel.appendChild(divChartBody);
				var divChartError = document.createElement('div');
				divChartError.id = sLayoutPanel + '_divChartError';
				divChartError.className = 'error';
				divChartBody.appendChild(divChartError);
				var divChartHTML5 = document.createElement('div');
				divChartHTML5.id = sLayoutPanel + '_divChartHTML5';
				divChartHTML5.style.width = '100%';
				divChartBody.appendChild(divChartHTML5);
				
				var divFootnote = document.createElement('div');
				divFootnote.id = sLayoutPanel + '_divFootnote';
				divFootnote.className = 'chartFootnote';
				divDashboardPanel.appendChild(divFootnote);
				
				var pFootnote = document.createElement('p');
				pFootnote.align = 'center';
				divFootnote.appendChild(pFootnote);
				pFootnote.innerHTML = sLBL_MONTH_BY_OUTCOME_DESC;
				
				var rowDefaultSearch = Sql.ParseFormData(sDEFAULT_SETTINGS);
				SearchViewUI_Load(sLayoutPanel, sActionsPanel, 'Opportunities', sSETTINGS_EDITVIEW, rowDefaultSearch, false, this.Search, function(status, message)
				{
					if ( status == 1 )
					{
						var txtYEAR = document.getElementById(sActionsPanel + '_ctlEditView_YEAR');
						if ( txtYEAR != null )
						{
							txtYEAR.value = (new Date()).getFullYear().toString();
						}
						var lstASSIGNED_USER_ID = document.getElementById(sActionsPanel + '_ctlEditView_ASSIGNED_USER_ID');
						if ( lstASSIGNED_USER_ID != null )
						{
							// 12/27/2017 Paul.  Dynamic Assignment will not use a dropdown list. 
							if ( $(lstASSIGNED_USER_ID).is('select') )
							{
								for ( var i = lstASSIGNED_USER_ID.options.length - 1; i >= 0; i-- )
								{
									lstASSIGNED_USER_ID.options[i].selected = true;
								}
							}
						}
						SearchViewUI_SearchForm(sLayoutPanel, sActionsPanel, sSETTINGS_EDITVIEW, this.Search, this);
					}
					else
					{
						$('#' + sLayoutPanel + '_divChartError').text('Chart error: ' + message);
					}
				}, this);
			}
		},
		Search: function(sLayoutPanel, sActionsPanel, sSEARCH_FILTER, rowSEARCH_VALUES)
		{
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.AuthenticatedMethod(function(status, message)
			{
				if ( status == 1 )
				{
					// 06/05/2017 Paul.  Start with current year. 
					// 02/18/2018 Paul.  Must use getFullYear() instead of getYear() due to Y2K coding. 
					var nYear = (new Date()).getFullYear();
					var txtYEAR = document.getElementById(sActionsPanel + '_ctlEditView_YEAR');
					if ( txtYEAR != null )
						nYear = parseInt(txtYEAR.value);
					if ( nYear < 1900 )
						nYear = 1900;
					else if ( nYear > 2100 )
						nYear = 2100;
					if ( txtYEAR != null )
					{
						var oSearchBuilder = new SearchBuilder();
						var sOldYearSql = oSearchBuilder.BuildQuery('', 'YEAR', txtYEAR.value);
						var sNewYearSql = "(DATE_CLOSED >= \'" + nYear.toString() + "/01/01 00:00:00\' and DATE_CLOSED < \'" + nYear.toString() + "/12/31 23:59:59\')";
						sSEARCH_FILTER = sSEARCH_FILTER.replace(sOldYearSql, sNewYearSql);
					}
					//var divChartError = document.getElementById(sLayoutPanel + '_divChartError');
					//divChartError.innerHTML = 'Search: ' + sSEARCH_FILTER;

					var divChartHTML5 = document.getElementById(sLayoutPanel + '_divChartHTML5');
					while ( divChartHTML5.childNodes.length > 0 )
					{
						divChartHTML5.removeChild(divChartHTML5.firstChild);
					}
					var arrMonthNames = L10n.GetListTerms('month_names_dom');
					// 05/29/2017 Paul.  The charge seems to be removing the last time, so just append an empty item. 
					arrMonthNames.push('');
			
					var sCurrencyPrefix = '';
					var sCurrencySuffix = '';
					switch ( oNumberFormat.CurrencyPositivePattern )
					{
						case 0:  // $n
							sCurrencyPrefix = oNumberFormat.CurrencySymbol;
							break;
						case 1:  // n$
							sCurrencySuffix = oNumberFormat.CurrencySymbol;
							break;
						case 2:  // $ n
							sCurrencyPrefix = oNumberFormat.CurrencySymbol + ' ';
							break;
						case 3:  // n $
							sCurrencySuffix = ' ' + oNumberFormat.CurrencySymbol;
							break;
					}
					oNumberFormat.CurrencyDecimalDigits = 0;
			
					var arrLeadSource = new Array();
					var lstLEAD_SOURCE = document.getElementById(sActionsPanel + '_ctlEditView_LEAD_SOURCE');
					if ( lstLEAD_SOURCE != null )
					{
						for ( var i = 0; i < lstLEAD_SOURCE.options.length; i++ )
						{
							if ( lstLEAD_SOURCE.options[i].selected )
								arrLeadSource.unshift(lstLEAD_SOURCE.options[i].text);
						}
					}
			
					// 09/21/2005 Paul.  Remove day from format. 
					sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('dd', '');
					sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('--', '-');
					sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('//', '/');
					sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('  ', ' ');
				
					var sTABLE_NAME     = 'vwOPPORTUNITIES_PipelineMonth';
					if ( Crm.Config.ToString('OpportunitiesMode') == 'Revenue' )
						sTABLE_NAME     = 'vwREVENUE_PipelineMonth';
					var sORDER_BY       = 'MONTH_CLOSED, SALES_STAGE desc';
					var sSELECT         = 'SALES_STAGE, MONTH_CLOSED';
					var sFILTER         = sSEARCH_FILTER;
					var sGROUP_BY       = 'SALES_STAGE, MONTH_CLOSED';
					var sAGGREGATE      = 'AMOUNT_USDOLLAR with sum as TOTAL, Count with sum as OPPORTUNITY_COUNT';
					var bgPage = chrome.extension.getBackgroundPage();
					bgPage.ListView_LoadTableWithAggregate(sTABLE_NAME, sORDER_BY, sSELECT, sFILTER, sGROUP_BY, sAGGREGATE, function(status, message)
					{
						if ( status == 1 )
						{
							var dt = message;
							var data    = new Array();
							var arrSeriesLost  = new Array();
							var arrSeriesWon   = new Array();
							var arrSeriesOther = new Array();
							data.push(arrSeriesLost );
							data.push(arrSeriesWon  );
							data.push(arrSeriesOther);
							for ( var i = 0; i < 12; i++ )
							{
								arrSeriesLost [i] = 0.0;
								arrSeriesWon  [i] = 0.0;
								arrSeriesOther[i] = 0.0;
							}
						
							var dPIPELINE_TOTAL = 0.0;
							for ( var i = 0; i < dt.length; i++ )
							{
								var row = dt[i];
								var nMONTH_CLOSED      = Sql.ToInteger(row["MONTH_CLOSED"     ]);
								var sSALES_STAGE       = Sql.ToString (row["SALES_STAGE"      ]);
								var dTOTAL             = Sql.ToDouble (row["TOTAL"            ]) / 1000.0;
								var nOPPORTUNITY_COUNT = Sql.ToInteger(row["OPPORTUNITY_COUNT"]);
								var dtMONTH_CLOSED     = new Date(nYear, nMONTH_CLOSED, 1);
								var sMONTH_CLOSED      = formatDate(dtMONTH_CLOSED, sMONTHYEAR_FORMAT);
							
								dPIPELINE_TOTAL += dTOTAL;
							
								switch ( sSALES_STAGE )
								{
									case "Closed Lost":  arrSeriesLost [nMONTH_CLOSED - 1] = dTOTAL;  break;
									case "Closed Won" :  arrSeriesWon  [nMONTH_CLOSED - 1] = dTOTAL;  break;
									case "Other"      :  arrSeriesOther[nMONTH_CLOSED - 1] = dTOTAL;  break;
								}
							}
							dPIPELINE_TOTAL = dPIPELINE_TOTAL;
						
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
								[ { label: sLBL_CLOSED_LOST, value: 'Closed Lost' }
								, { label: sLBL_CLOSED_WON , value: 'Closed Won'  }
								, { label: sLBL_OTHER      , value: 'Other'       }
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
									, ticks: arrMonthNames
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
								var dtStartDate = new Date(nYear,  0,  1);
								var dtEndDate   = new Date(nYear, 11, 31);
								var sShortDatePattern = Security.USER_DATE_FORMAT();
								var sStartDate = formatDate(dtStartDate, sShortDatePattern);
								var sEndDate   = formatDate(dtEndDate  , sShortDatePattern);
								options.axes.xaxis.label  = sLBL_DATE_RANGE + ' ' + sStartDate + ' ' + sLBL_DATE_RANGE_TO + ' ' + sEndDate + ' ';
								options.axes.xaxis.label += '<br/>' + sLBL_TOTAL_PIPELINE + ' ' + formatCurrency(dPIPELINE_TOTAL, oNumberFormat) + sLBL_OPP_THOUSANDS;
							
								options.title.text = sLBL_TOTAL_PIPELINE + ' ' + formatCurrency(dPIPELINE_TOTAL, oNumberFormat) + sLBL_OPP_THOUSANDS;
								// 01/05/2015 Paul.  DateTimeFormat.MonthNames is a 13 item array. 
								options.axes.xaxis.ticks.pop();
								var plot1 = $.jqplot(sLayoutPanel + '_divChartHTML5', data, options);
							
								$('#' + sLayoutPanel + '_divChartHTML5').bind('jqplotDataClick', function(ev, seriesIndex, pointIndex, data)
								{
									var dtDate = new Date(nYear,  pointIndex,  1);
									var sDate  = formatDate(dtDate, sShortDatePattern);
									// 05/20/2017 Paul.  This will need to be conditional, based on Desktop or HTML5 rendering. 
									//window.location.href = sREMOTE_SERVER + 'Opportunities/default.aspx?DATE_CLOSED=' + escape(sDate) + '&SALES_STAGE=' + escape(options.series[seriesIndex].value);
								});
								$('#' + sLayoutPanel + '_divChartHTML5').bind('jqplotDataHighlight', function(ev, seriesIndex, pointIndex, data)
								{
									var $this = $(this);
									var dtDate = new Date(nYear,  pointIndex,  1);
									var sDate  = formatDate(dtDate, sShortDatePattern);
									var sValue = options.axes.yaxis.tickOptions.prefix + $.jqplot.DefaultTickFormatter(options.axes.yaxis.tickOptions.formatString, data[1]) + options.axes.yaxis.tickOptions.suffix;
									$this.attr('title', options.series[seriesIndex].label + '\n' + sDate + '\n' + sValue);
								}); 
								$('#' + sLayoutPanel + '_divChartHTML5').bind('jqplotDataUnhighlight', function(ev, seriesIndex, pointIndex, data)
								{
									var $this = $(this);
									$this.attr('title', '');
								});
							}
							catch(e)
							{
								$('#' + sLayoutPanel + '_divChartError').text('Chart error: ' + e.message);
							}
						}
						else
						{
							$('#' + sLayoutPanel + '_divChartError').text('Chart error: ' + message);
						}
					}, this);
				}
			}, this);
		}
	};
});
