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
	var oNumberFormat              = Security.NumberFormatInfo();
	var sLBL_OPP_SIZE              = L10n.Term('Dashboard.LBL_OPP_SIZE'             );
	var sLBL_OPP_THOUSANDS         = L10n.Term('Dashboard.LBL_OPP_THOUSANDS'        );
	var sLBL_TOTAL_PIPELINE        = L10n.Term('Dashboard.LBL_TOTAL_PIPELINE'       );
	var sLBL_OPPS_IN_LEAD_SOURCE   = L10n.Term('Dashboard.LBL_OPPS_IN_LEAD_SOURCE'  );
	var sLBL_LEAD_SOURCE_FORM_DESC = L10n.Term('Dashboard.LBL_LEAD_SOURCE_FORM_DESC');

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
				pFootnote.innerHTML = sLBL_LEAD_SOURCE_FORM_DESC;
				
				var rowDefaultSearch = Sql.ParseFormData(sDEFAULT_SETTINGS);
				SearchViewUI_Load(sLayoutPanel, sActionsPanel, 'Opportunities', sSETTINGS_EDITVIEW, rowDefaultSearch, false, this.Search, function(status, message)
				{
					if ( status == 1 )
					{
						// 05/29/2017 Paul.  Set default values. 
						var lstLEAD_SOURCE = document.getElementById(sActionsPanel + '_ctlEditView_LEAD_SOURCE');
						if ( lstLEAD_SOURCE != null )
						{
							var optNone = document.createElement('option');
							optNone.setAttribute('value', '');
							optNone.innerHTML = L10n.Term('.LBL_NONE');
							if ( lstLEAD_SOURCE.options.length > 0 )
								lstLEAD_SOURCE.insertBefore(optNone, lstLEAD_SOURCE.firstChild);
							else
								lstLEAD_SOURCE.appendChild(optNone);
							
							for ( var i = lstLEAD_SOURCE.options.length - 1; i >= 0; i-- )
							{
								lstLEAD_SOURCE.options[i].selected = true;
							}
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
			
					var sTABLE_NAME     = 'vwOPPORTUNITIES_ByLeadSource';
					if ( Crm.Config.ToString('OpportunitiesMode') == 'Revenue' )
						sTABLE_NAME     = 'vwREVENUE_ByLeadSource';
					var sORDER_BY       = 'LIST_ORDER';
					var sSELECT         = 'LEAD_SOURCE, LIST_ORDER';
					var sFILTER         = sSEARCH_FILTER;
					var sGROUP_BY       = 'LEAD_SOURCE, LIST_ORDER';
					var sAGGREGATE      = 'AMOUNT_USDOLLAR with sum as TOTAL, Count with sum as OPPORTUNITY_COUNT';
					var bgPage = chrome.extension.getBackgroundPage();
					bgPage.ListView_LoadTableWithAggregate(sTABLE_NAME, sORDER_BY, sSELECT, sFILTER, sGROUP_BY, sAGGREGATE, function(status, message)
					{
						if ( status == 1 )
						{
							var dt = message;
							var data    = new Array();
							var dPIPELINE_TOTAL = 0.0;
							for ( var i = 0; i < dt.length; i++ )
							{
								var row = dt[i];
								dPIPELINE_TOTAL += Sql.ToDouble(row['TOTAL']) / 1000.0;
							}
							dPIPELINE_TOTAL = dPIPELINE_TOTAL;
							for ( var i = 0; i < dt.length; i++ )
							{
								var row = dt[i];
								var sLEAD_SOURCE       = Sql.ToString (row['LEAD_SOURCE'      ]);
								var dTOTAL             = Sql.ToDouble (row['TOTAL'            ]) / 1000.0;
								var nOPPORTUNITY_COUNT = Sql.ToInteger(row['OPPORTUNITY_COUNT']);
								var sLEAD_SOURCE_TERM  = '';
								if ( Sql.IsEmptyString(sLEAD_SOURCE) )
									sLEAD_SOURCE_TERM = L10n.Term('.LBL_NONE_VALUE');
								else
									sLEAD_SOURCE_TERM = L10n.ListTerm('lead_source_dom', sLEAD_SOURCE)
							
								var arrRow = new Array();
								arrRow.push(sLEAD_SOURCE_TERM);
								arrRow.push(dTOTAL           );
								arrRow.push(formatCurrency(dTOTAL, oNumberFormat));
								arrRow.push( formatNumber(dTOTAL * 100 / dPIPELINE_TOTAL, oNumberFormat) + ' %');
								arrRow.push(nOPPORTUNITY_COUNT.toString() + ' ' + sLBL_OPPS_IN_LEAD_SOURCE + ' ' + sLEAD_SOURCE_TERM);
								data.push(arrRow);
							}
							if ( dt.length == 0 )
							{
								var arrRow = new Array();
								arrRow.push(null);
								data.push(arrRow)
							}
					
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
								options.title.text  = sLBL_TOTAL_PIPELINE + ' ' + formatCurrency(dPIPELINE_TOTAL, oNumberFormat) + sLBL_OPP_THOUSANDS;
								options.title.text += '<br/>' + sLBL_OPP_SIZE + formatCurrency(1.0, oNumberFormat) + sLBL_OPP_THOUSANDS;
								var plot1 = $.jqplot(sLayoutPanel + '_divChartHTML5', [data], options);
							
								$('#' + sLayoutPanel + '_divChartHTML5').bind('jqplotDataClick', function(ev, seriesIndex, pointIndex, data)
								{
									var sLEAD_SOURCE   = '';
									var lstLEAD_SOURCE = document.getElementById(sActionsPanel + '_ctlEditView_LEAD_SOURCE');
									if ( lstLEAD_SOURCE != null )
									{
										for ( var i = 0; i < lstLEAD_SOURCE.options.length; i++ )
										{
											if ( lstLEAD_SOURCE.options[i].text == arrLeadSource[pointIndex] )
											{
												sLEAD_SOURCE = lstLEAD_SOURCE.options[i].value;
											}
										}
									}
									// 05/20/2017 Paul.  This will need to be conditional, based on Desktop or HTML5 rendering. 
									//window.location.href = sREMOTE_SERVER + 'Opportunities/default.aspx?LEAD_SOURCE=' + escape(sLEAD_SOURCE);
								});
								$('#' + sLayoutPanel + '_divChartHTML5').bind('jqplotDataHighlight', function(ev, seriesIndex, pointIndex, data)
								{
									var $this = $(this);
									$this.attr('title', data[0] + '\n' + data[2] + '\n' + data[3] + '\n' + data[4]);
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
