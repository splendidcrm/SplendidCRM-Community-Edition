/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
import * as React from 'react';
import { RouteComponentProps, withRouter } from '../Router5'              ;
import { FontAwesomeIcon }                 from '@fortawesome/react-fontawesome';
import { Appear }                          from 'react-lifecycle-appear'        ;
import { observer }                        from 'mobx-react'                    ;
// https://www.amcharts.com/docs/v4/getting-started/basics/
import * as am4core                        from "@amcharts/amcharts4/core"      ;
import * as am4charts                      from "@amcharts/amcharts4/charts"    ;
// 2. Store and Types. 
import IDashletProps                       from '../types/IDashletProps'        ;
// 3. Scripts. 
import Sql                                 from '../scripts/Sql'                ;
import L10n                                from '../scripts/L10n'               ;
import Security                            from '../scripts/Security'           ;
import Credentials                         from '../scripts/Credentials'        ;
import SplendidCache                       from '../scripts/SplendidCache'      ;
import { Crm_Config }                      from '../scripts/Crm'                ;
import { formatDate, formatCurrency }      from '../scripts/Formatting'         ;
import { ListView_LoadTableWithAggregate } from '../scripts/ListView'           ;
// 4. Components and Views. 
import DumpSQL                             from '../components/DumpSQL'         ;
import ErrorComponent                      from '../components/ErrorComponent'  ;
import SearchView                          from '../views/SearchView'           ;

const MODULE_NAME: string = 'Opportunities';
const TABLE_NAME : string = (Crm_Config.ToString('OpportunitiesMode') == 'Revenue' ? 'vwREVENUE_PipelineMonth' : 'vwOPPORTUNITIES_PipelineMonth');
const ORDER_BY   : string = 'MONTH_CLOSED, SALES_STAGE desc';
const SELECT     : string = 'SALES_STAGE, MONTH_CLOSED';
const GROUP_BY   : string = 'SALES_STAGE, MONTH_CLOSED';
const AGGREGATE  : string = 'AMOUNT_USDOLLAR with sum as TOTAL, Count with sum as OPPORTUNITY_COUNT';

interface IPipelineByMonthByOutcomeState
{
	DEFAULT_SETTINGS : any;
	SEARCH_FILTER    : string;
	optionsVisible   : boolean;
	data             : any;
	error            : any;
	__sql?           : any;
	dashletVisible   : boolean;
}

@observer
export default class PipelineByMonthByOutcome extends React.Component<IDashletProps, IPipelineByMonthByOutcomeState>
{
	private _isMounted = false;
	private Search;
	private LayoutLoaded;
	private chart;
	private chartTitle;
	private categoryAxis;
	private searchView = React.createRef<SearchView>();
	// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
	private themeURL   : string  = null;
	private legacyIcons: boolean = false;

	constructor(props: IDashletProps)
	{
		super(props);
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.themeURL    = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		let arrASSIGNED_USER_ID = L10n.GetList('AssignedUser');
		let objDEFAULT_SETTINGS: any = (!Sql.IsEmptyString(props.DEFAULT_SETTINGS) ? Sql.ParseFormData(props.DEFAULT_SETTINGS) : null);
		if (objDEFAULT_SETTINGS === undefined || objDEFAULT_SETTINGS == null)
		{
			objDEFAULT_SETTINGS = {};
			objDEFAULT_SETTINGS.YEAR = (new Date()).getFullYear().toString();
			objDEFAULT_SETTINGS.ASSIGNED_USER_ID = arrASSIGNED_USER_ID;
		}
		this.state =
		{
			DEFAULT_SETTINGS: objDEFAULT_SETTINGS,
			SEARCH_FILTER   : null,
			optionsVisible  : false,
			data            : null,
			error           : null,
			dashletVisible  : false,
		}
	}

	componentDidMount()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount');
		if ( !this.chart )
		{
			this.createChart();
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
		this._isMounted = true;
		if (this.chart)
		{
			this.chart.dispose();
		}
	}

	private createChart = () =>
	{
		const { ID } = this.props;
		const sLBL_CLOSED_LOST           = L10n.ListTerm('sales_stage_dom', 'Closed Lost');
		const sLBL_CLOSED_WON            = L10n.ListTerm('sales_stage_dom', 'Closed Won' );
		const sLBL_OTHER                 = L10n.ListTerm('sales_stage_dom', 'Other'      );
		const sLBL_TOTAL_PIPELINE        = L10n.Term('Dashboard.LBL_TOTAL_PIPELINE'       );
		const sLBL_MONTH_BY_OUTCOME_DESC = L10n.Term('Dashboard.LBL_MONTH_BY_OUTCOME_DESC');
		
		// https://www.amcharts.com/docs/v4/chart-types/xy-chart/
		// https://codepen.io/team/amcharts/pen/GdQWxz?editors=1010
		let chart = am4core.create('dashlet.' + ID, am4charts.XYChart);
		if ( chart == null )
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount: ' + 'dashlet.' + ID + ' not found.');
			return;
		}
		chart.cursor = new am4charts.XYCursor();
		chart.legend = new am4charts.Legend();
		chart.padding(40, 40, 40, 40);
		
		let categoryAxis = chart.xAxes.push(new am4charts.CategoryAxis());
		categoryAxis.title.text = sLBL_TOTAL_PIPELINE;
		categoryAxis.renderer.grid.template.location = 0;
		categoryAxis.renderer.labels.template.rotation = -30;
		categoryAxis.dataFields.category = 'category';
		categoryAxis.renderer.minGridDistance = 30;
		this.categoryAxis = categoryAxis;
		
		let valueAxis = chart.yAxes.push(new am4charts.ValueAxis());
		//valueAxis.title.text = '';
		valueAxis.renderer.minY = 0;
		
		let seriesLost:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
		seriesLost.name = sLBL_CLOSED_LOST;
		seriesLost.dataFields.categoryX = 'category';
		seriesLost.dataFields.valueY = 'lost';
		seriesLost.tooltipText = '{name}: [bold]{valueY}[/]';
		//seriesLost.columns.template.tooltipText = '{name}: {valueY.value}';
		//seriesLost.columns.template.tooltipY = 0;
		//seriesLost.columns.template.strokeOpacity = 0;
		seriesLost.stacked = true;
		
		let seriesWon:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
		seriesWon.name = sLBL_CLOSED_WON;
		seriesWon.dataFields.categoryX = 'category';
		seriesWon.dataFields.valueY = 'won';
		seriesWon.tooltipText = '{name}: [bold]{valueY}[/]';
		//seriesWon.columns.template.tooltipText = '{name}: {valueY.value}';
		//seriesWon.columns.template.tooltipY = 0;
		//seriesWon.columns.template.strokeOpacity = 0;
		seriesWon.stacked = true;
		
		let seriesOther:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
		seriesOther.name = sLBL_OTHER;
		seriesOther.dataFields.categoryX = 'category';
		seriesOther.dataFields.valueY = 'other';
		seriesOther.tooltipText = '{name}: [bold]{valueY}[/]';
		//seriesOther.columns.template.tooltipText = '{name}: {valueY.value}';
		//seriesOther.columns.template.tooltipY = 0;
		//seriesOther.columns.template.strokeOpacity = 0;
		seriesOther.stacked = true;
		
		// https://www.amcharts.com/docs/v4/reference/xychart/
		let title = chart.plotContainer.createChild(am4core.Label);
		title.text = sLBL_TOTAL_PIPELINE;
		title.y = -40;
		title.x = am4core.percent(50);
		title.fontSize = '1.2em';
		title.verticalCenter = 'top';
		title.textAlign = 'middle';
		title.horizontalCenter = 'middle';
		title.fontWeight = '800';
		this.chartTitle = title;

		//let axisLabel = chart.chartContainer.createChild(am4core.Label);
		//axisLabel.text = sLBL_TOTAL_PIPELINE;
		//axisLabel.x = am4core.percent(50);
		//axisLabel.fontSize = '1.0em';
		//axisLabel.verticalCenter = 'bottom';
		//axisLabel.textAlign = 'middle';
		//axisLabel.horizontalCenter = 'middle';
		//axisLabel.fontWeight = '400';
		//this.axisLabel = axisLabel;

		let footnote = chart.chartContainer.createChild(am4core.Label);
		footnote.text = sLBL_MONTH_BY_OUTCOME_DESC;
		footnote.x = am4core.percent(50);
		footnote.fontSize = '0.8em';
		footnote.verticalCenter = 'bottom';
		footnote.textAlign = 'middle';
		footnote.horizontalCenter = 'middle';
		footnote.fontWeight = '400';

		chart.data = [];
		this.chart = chart;
		return chart;
	}

	private loadData = async (): Promise<any> =>
	{
		const { DEFAULT_SETTINGS, SEARCH_FILTER } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData ' + SEARCH_FILTER, DEFAULT_SETTINGS);

		let nYear = Sql.ToInteger(DEFAULT_SETTINGS.YEAR);
		if ( nYear < 1900 )
			nYear = 1900;
		else if ( nYear > 2100 )
			nYear = 2100;
		let sOldYearSql = "YEAR like N\'%" + nYear.toString() + "%\' escape \'\\\'";
		let sNewYearSql = "(DATE_CLOSED >= \'" + nYear.toString() + "/01/01 00:00:00\' and DATE_CLOSED < \'" + nYear.toString() + "/12/31 23:59:59\')";
		let sSEARCH_FILTER = Sql.ToString(SEARCH_FILTER);
		sSEARCH_FILTER = sSEARCH_FILTER.replace(sOldYearSql, sNewYearSql);
		
		let sMONTHYEAR_FORMAT = Security.USER_DATE_FORMAT();
		sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('dd', '');
		sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('--', '-');
		sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('//', '/');
		sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('  ', ' ');
		const sLBL_OPP_SIZE              = L10n.Term('Dashboard.LBL_OPP_SIZE'             );
		const sLBL_OPP_THOUSANDS         = L10n.Term('Dashboard.LBL_OPP_THOUSANDS'        );
		const sLBL_TOTAL_PIPELINE        = L10n.Term('Dashboard.LBL_TOTAL_PIPELINE'       );
		const sLBL_DATE_RANGE            = L10n.Term('Dashboard.LBL_DATE_RANGE'           );
		const sLBL_DATE_RANGE_TO         = L10n.Term('Dashboard.LBL_DATE_RANGE_TO'        );

		let oNumberFormat              = Security.NumberFormatInfo();
		let sCurrencyPrefix = '';
		let sCurrencySuffix = '';
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

		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData SearchFilter: ' + sSEARCH_FILTER);
		let d = await ListView_LoadTableWithAggregate(TABLE_NAME, ORDER_BY, SELECT, sSEARCH_FILTER, null, GROUP_BY, AGGREGATE);
		if ( !this._isMounted )
			return;
		try
		{
			let dt = d.results;
			let data = new Array();
			let arrMonthNames = L10n.GetListTerms('month_names_dom');
			for (let i = 0; i < 12; i++)
			{
				let monthName = arrMonthNames[i];
				let objMonth = { category: monthName, lost: 0.0, won: 0.0, other: 0.0 };
				data.push(objMonth);
			}

			let dPIPELINE_TOTAL = 0.0;
			for (let i = 0; i < dt.length; i++)
			{
				let row = dt[i];
				let nMONTH_CLOSED      = Sql.ToInteger(row["MONTH_CLOSED"     ]);
				let sSALES_STAGE       = Sql.ToString (row["SALES_STAGE"      ]);
				let dTOTAL             = Sql.ToDouble (row["TOTAL"            ]) / 1000.0;
				let nOPPORTUNITY_COUNT = Sql.ToInteger(row["OPPORTUNITY_COUNT"]);
				let dtMONTH_CLOSED     = new Date(nYear, nMONTH_CLOSED, 1);
				let sMONTH_CLOSED      = formatDate(dtMONTH_CLOSED, sMONTHYEAR_FORMAT);

				dPIPELINE_TOTAL += dTOTAL;
				let nMonthIndex = nMONTH_CLOSED - 1;
				let monthName = arrMonthNames[nMonthIndex];
				switch (sSALES_STAGE)
				{
					case "Closed Lost": data[nMonthIndex].lost  = dTOTAL; break;
					case "Closed Won" : data[nMonthIndex].won   = dTOTAL; break;
					case "Other"      : data[nMonthIndex].other = dTOTAL; break;
				}
			}
			dPIPELINE_TOTAL = dPIPELINE_TOTAL;

			let dtStartDate = new Date(nYear, 0, 1);
			let dtEndDate = new Date(nYear, 11, 31);
			let sShortDatePattern = Security.USER_DATE_FORMAT();
			let sStartDate = formatDate(dtStartDate, sShortDatePattern);
			let sEndDate = formatDate(dtEndDate, sShortDatePattern);
			// 01/20/2021 Paul.  Use \r\n instead of <br/>. 
			this.categoryAxis.title.text = sLBL_DATE_RANGE + ' ' + sStartDate + ' ' + sLBL_DATE_RANGE_TO + ' ' + sEndDate + ' ';
			                             + '\r\n' + sLBL_TOTAL_PIPELINE + ' ' + formatCurrency(dPIPELINE_TOTAL, oNumberFormat) + sLBL_OPP_THOUSANDS;
			this.chartTitle.text = sLBL_TOTAL_PIPELINE + ' ' + formatCurrency(dPIPELINE_TOTAL, oNumberFormat) + sLBL_OPP_THOUSANDS;
			
			this.chart.data = data;
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData:', data);
			// 06/01/2019 Paul.  The component may be unmounted by the time the custom view is generated. 
			if ( this._isMounted )
			{
				this.setState(
				{
					data : data,
					__sql: d.__sql
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData', error);
			this.setState({ error });
		}
	}

	private _onRefresh = async (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRefresh');
		await this.loadData();
	}

	private _onLayoutLoaded = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLayoutLoaded');
		// 07/13/2019 Paul.  Call SubmitSearch directly. 
		if ( this.searchView.current != null )
		{
			this.searchView.current.SubmitSearch();
		}
	}

	private _onSearch = (commandText: string, row: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearch(): ' + commandText, row);
		// 06/01/2019 Paul.  The component may be unmounted by the time the custom view is generated. 
		if ( this._isMounted )
		{
			this.setState({ DEFAULT_SETTINGS: row, SEARCH_FILTER: commandText }, async () =>
			{
				await this.loadData();
			});
		}
	}

	public render()
	{
		const { ID, TITLE, SETTINGS_EDITVIEW } = this.props;
		const { DEFAULT_SETTINGS, optionsVisible, data, error, __sql, dashletVisible } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', DEFAULT_SETTINGS, data);
		/*
		if ( data != null )
		{
			data.map((row, rowIndex) =>
			(
				//console.log((new Date()).toISOString() + ' ' + rowIndex, row);
			));
		}
		*/
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 01/06/2021 Paul.  AutoSaveSearch enabled. 
		// 07/30/2021 Paul.  Load when the panel appears. 
		return (
		<div style={ {display: 'flex', flexGrow: 1} }>
			<div className="card" style={ {flexGrow: 1, margin: '.5em', overflowX: 'auto'} }>
				<Appear onAppearOnce={ (ioe) => this.setState({ dashletVisible: true }) }>
					<div className="card-body DashletHeader">
						<ErrorComponent error={error} />
						<h3 style={ {float: 'left'} }>{ L10n.Term(TITLE) }</h3>
						<span
							style={ {cursor: 'pointer', float: 'right', textDecoration: 'none', marginLeft: '.5em'} }
							onClick={ (e) => this._onRefresh(e) }
						>
							{ this.legacyIcons
							? <img src={ this.themeURL + 'refresh.gif'} style={ {borderWidth: '0px'} } />
							: <FontAwesomeIcon icon="sync" size="lg" />
							}
						</span>
						<span
							style={ {cursor: 'pointer', float: 'right', textDecoration: 'none', marginLeft: '.5em'} }
							onClick={ () => this.setState({ optionsVisible: !optionsVisible }) }
						>
							{ this.legacyIcons
							? <img src={ this.themeURL + 'edit.gif'} style={ {borderWidth: '0px'} } />
							: <FontAwesomeIcon icon="cog" size="lg" />
							}
						</span>
					</div>
				</Appear>
				<div style={{ clear: 'both' }}>
					<hr />
					{ dashletVisible
					? <div style={{ display: (optionsVisible ? 'inline' : 'none') }}>
						<SearchView
							EDIT_NAME={SETTINGS_EDITVIEW}
							AutoSaveSearch={ true }
							rowDefaultSearch={DEFAULT_SETTINGS}
							cbSearch={this._onSearch}
							onLayoutLoaded={ this._onLayoutLoaded }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.searchView }
						/>
					</div>
					: null
					}
					<DumpSQL SQL={ __sql } />
					<div id={ 'dashlet.' + ID } style={{ width: '100%', height: '500px' }}></div>
				</div>
			</div>
		</div>);
	}
}
