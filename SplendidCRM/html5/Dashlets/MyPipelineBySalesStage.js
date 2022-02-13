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
	var oNumberFormat                 = Security.NumberFormatInfo();
	var sLBL_OPP_SIZE                 = L10n.Term('Dashboard.LBL_OPP_SIZE'                );
	var sLBL_OPP_THOUSANDS            = L10n.Term('Dashboard.LBL_OPP_THOUSANDS'           );
	var sLBL_TOTAL_PIPELINE           = L10n.Term('Dashboard.LBL_TOTAL_PIPELINE'          );
	var sLBL_DATE_RANGE               = L10n.Term('Dashboard.LBL_DATE_RANGE'              );
	var sLBL_DATE_RANGE_TO            = L10n.Term('Dashboard.LBL_DATE_RANGE_TO'           );
	var sLBL_PIPELINE_FORM_TITLE_DESC = L10n.Term('Dashboard.LBL_PIPELINE_FORM_TITLE_DESC');

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
				pFootnote.innerHTML = sLBL_PIPELINE_FORM_TITLE_DESC;
				
				var rowDefaultSearch = Sql.ParseFormData(sDEFAULT_SETTINGS);
				SearchViewUI_Load(sLayoutPanel, sActionsPanel, 'Opportunities', sSETTINGS_EDITVIEW, rowDefaultSearch, false, this.Search, function(status, message)
				{
					if ( status == 1 )
					{
						// 05/29/2017 Paul.  Set default values. 
						var lstSALES_STAGE = document.getElementById(sActionsPanel + '_ctlEditView_SALES_STAGE');
						if ( lstSALES_STAGE != null )
						{
							for ( var i = lstSALES_STAGE.options.length - 1; i >= 0; i-- )
							{
								lstSALES_STAGE.options[i].selected = true;
							}
						}
						var dtDate = new Date();
						var sShortDatePattern = Security.USER_DATE_FORMAT();
						var ctlDATE_START = document.getElementById(sActionsPanel + '_ctlEditView_DATE_CLOSED_AFTER');
						if ( ctlDATE_START != null )
						{
							ctlDATE_START.value = formatDate(dtDate, sShortDatePattern);
						}
						var ctlDATE_END   = document.getElementById(sActionsPanel + '_ctlEditView_DATE_CLOSED_BEFORE');
						if ( ctlDATE_END != null )
						{
							dtDate = new Date(dtDate.getFullYear() + 5, 0, 1)
							ctlDATE_END.value = formatDate(dtDate, sShortDatePattern);
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
					if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
						sSEARCH_FILTER += ' and ';
					sSEARCH_FILTER += "ASSIGNED_USER_ID = \'" + Security.USER_ID() + "\'";
					//var divChartError = document.getElementById(sLayoutPanel + '_divChartError');
					//divChartError.innerHTML = 'Search: ' + sSEARCH_FILTER;

					var divChartHTML5 = document.getElementById(sLayoutPanel + '_divChartHTML5');
					while ( divChartHTML5.childNodes.length > 0 )
					{
						divChartHTML5.removeChild(divChartHTML5.firstChild);
					}
			
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
			
					var sStartDate = '';
					var sEndDate   = '';
					if ( $.isArray(rowSEARCH_VALUES['DATE_CLOSED']) )
					{
						var oValue = rowSEARCH_VALUES['DATE_CLOSED'];
						if ( oValue.length >= 1 && oValue[0] != null )
							sStartDate = FromJsonDate(rowSEARCH_VALUES['DATE_CLOSED'][0], Security.USER_DATE_FORMAT());
						if ( oValue.length >= 2 && oValue[1] != null )
							sEndDate   = FromJsonDate(rowSEARCH_VALUES['DATE_CLOSED'][1], Security.USER_DATE_FORMAT());
					}
			
					var arrSALES_STAGE = new Array();
					var lstSALES_STAGE = document.getElementById(sActionsPanel + '_ctlEditView_SALES_STAGE');
					if ( lstSALES_STAGE != null )
					{
						for ( var i = 0; i < lstSALES_STAGE.options.length; i++ )
						{
							if ( lstSALES_STAGE.options[i].selected )
								arrSALES_STAGE.push(lstSALES_STAGE.options[i].value);
						}
					}
					if ( arrSALES_STAGE == null || arrSALES_STAGE.length == 0 )
					{
						arrSALES_STAGE = L10n.GetList('sales_stage_dom');
					}
				
					var arrSalesStage   = new Array();
					var arrActiveStages = new Array();
					var arrActiveUsers  = new Array();
					for ( var i = 0; i < arrSALES_STAGE.length; i++ )
					{
						var sSALES_STAGE = arrSALES_STAGE[i];
						var sSALES_STAGE_TERM = L10n.ListTerm('sales_stage_dom', arrSALES_STAGE[i]);
						arrActiveStages.unshift(sSALES_STAGE);
						arrSalesStage.unshift(sSALES_STAGE_TERM);
					}
				
					var sTABLE_NAME     = 'vwOPPORTUNITIES_Pipeline';
					if ( Crm.Config.ToString('OpportunitiesMode') == 'Revenue' )
						sTABLE_NAME     = 'vwREVENUE_Pipeline';
					var sORDER_BY       = 'USER_NAME';
					var sSELECT         = 'USER_NAME';
					var sFILTER         = sSEARCH_FILTER;
					var sGROUP_BY       = 'USER_NAME';
					var sAGGREGATE      = 'Count with sum as OPPORTUNITY_COUNT';
					var bgPage = chrome.extension.getBackgroundPage();
					bgPage.ListView_LoadTableWithAggregate(sTABLE_NAME, sORDER_BY, sSELECT, sFILTER, sGROUP_BY, sAGGREGATE, function(status, message)
					{
						if ( status == 1 )
						{
							var dt = message;
							var arrSeriesData = new Array();
							for ( var i = 0; i < dt.length; i++ )
							{
								var row = dt[i];
								var sUSER_NAME = Sql.ToString(row['USER_NAME']);
								arrActiveUsers.push(sUSER_NAME);
								// 01/09/2015 Paul.  This is where we create the data matrix. 
								var arrStageSeries = new Array();
								for ( var j = 0; j < arrSALES_STAGE.length; j++ )
								{
									arrStageSeries.push(0.0);
								}
								arrSeriesData.push(arrStageSeries);
							}
							// 01/12/2015 Paul.  If no data, we still need to show an empty grid. 
							if ( dt.length == 0 )
							{
								arrActiveUsers.push(Security.USER_NAME());
								var arrStageSeries = new Array();
								for ( var j = 0; j < arrSALES_STAGE.length; j++ )
								{
									arrStageSeries.push(0.0);
								}
								arrSeriesData.push(arrStageSeries);
							}
						
							var arrSeriesUsers = new Array();
							if ( $.isArray(arrActiveUsers) )
							{
								for ( var i = 0; i < arrActiveUsers.length; i++ )
								{
									var user = new Object();
									user.label = arrActiveUsers[i];
									arrSeriesUsers.push(user);
								}
							}
						
							sORDER_BY       = 'LIST_ORDER, USER_NAME';
							sSELECT         = 'SALES_STAGE, LIST_ORDER, ASSIGNED_USER_ID, USER_NAME';
							sGROUP_BY       = 'SALES_STAGE, LIST_ORDER, ASSIGNED_USER_ID, USER_NAME';
							sAGGREGATE      = 'AMOUNT_USDOLLAR with sum as TOTAL, Count with sum as OPPORTUNITY_COUNT';
							bgPage.ListView_LoadTableWithAggregate(sTABLE_NAME, sORDER_BY, sSELECT, sFILTER, sGROUP_BY, sAGGREGATE, function(status, message)
							{
								if ( status == 1 )
								{
									var dt = message;
									var dPIPELINE_TOTAL = 0.0;
									for ( var i = 0; i < dt.length; i++ )
									{
										var row = dt[i];
										var sSALES_STAGE       = Sql.ToString (row["SALES_STAGE"      ]);
										var dTOTAL             = Sql.ToDouble (row["TOTAL"            ]) / 1000.0;
										var nOPPORTUNITY_COUNT = Sql.ToInteger(row["OPPORTUNITY_COUNT"]);
										var gASSIGNED_USER_ID  = Sql.ToGuid   (row["ASSIGNED_USER_ID" ]);
										var sUSER_NAME         = Sql.ToString (row["USER_NAME"        ]);
										dPIPELINE_TOTAL += dTOTAL;
							
										var nSALES_STAGE   = arrActiveStages.indexOf(sSALES_STAGE);
										var nUSER_NAME     = arrActiveUsers.indexOf (sUSER_NAME  );
										if ( nUSER_NAME >= 0 && nUSER_NAME < arrSeriesData.length )
										{
											var arrStageSeries = arrSeriesData[nUSER_NAME];
											if ( nSALES_STAGE >= 0 && nSALES_STAGE < arrStageSeries.length )
												arrStageSeries[nSALES_STAGE] += dTOTAL;
										}
									}
									dPIPELINE_TOTAL = dPIPELINE_TOTAL;
									var data = arrSeriesData;
							
									// 05/31/2017 Paul.  My Pipeline does not need to show the legend. 
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
										options.axes.xaxis.label  = sLBL_DATE_RANGE + ' ' + sStartDate + ' ' + sLBL_DATE_RANGE_TO + ' ' + sEndDate + ' ';
										options.axes.xaxis.label += '<br/>' + sLBL_OPP_SIZE + formatCurrency(1.0, oNumberFormat) + sLBL_OPP_THOUSANDS;
							
										options.title.text = sLBL_TOTAL_PIPELINE + ' ' + formatCurrency(dPIPELINE_TOTAL, oNumberFormat) + sLBL_OPP_THOUSANDS;
										var plot1 = $.jqplot(sLayoutPanel + '_divChartHTML5', data, options);
							
										$('#' + sLayoutPanel + '_divChartHTML5').bind('jqplotDataClick', function(ev, seriesIndex, pointIndex, data)
										{
											var sSALES_STAGE        = '';
											var sASSIGNED_USER_ID   = Security.USER_ID();
											var lstSALES_STAGE = document.getElementById(sActionsPanel + '_ctlEditView_SALES_STAGE');
											if ( lstSALES_STAGE != null )
											{
												for ( var i = 0; i < lstSALES_STAGE.options.length; i++ )
												{
													if ( lstSALES_STAGE.options[i].text == arrSalesStage[pointIndex] )
													{
														sSALES_STAGE = lstSALES_STAGE.options[i].value;
													}
												}
											}
											// 05/20/2017 Paul.  This will need to be conditional, based on Desktop or HTML5 rendering. 
											//window.location.href = sREMOTE_SERVER + 'Opportunities/default.aspx?SALES_STAGE=' + escape(sSALES_STAGE) + '&ASSIGNED_USER_ID=' + escape(sASSIGNED_USER_ID);
										});
										$('#' + sLayoutPanel + '_divChartHTML5').bind('jqplotDataHighlight', function(ev, seriesIndex, pointIndex, data)
										{
											var $this = $(this);
											var sValue = options.axes.xaxis.tickOptions.prefix + $.jqplot.DefaultTickFormatter(options.axes.xaxis.tickOptions.formatString, data[0]) + options.axes.xaxis.tickOptions.suffix;
											$this.attr('title', sValue + '\n' + options.series[seriesIndex].label + '\n' + arrSalesStage[pointIndex]);
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
