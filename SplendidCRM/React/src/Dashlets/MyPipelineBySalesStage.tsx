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
import { RouteComponentProps, withRouter } from 'react-router-dom'              ;
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
import { FromJsonDate, formatCurrency }    from '../scripts/Formatting'         ;
import { ListView_LoadTableWithAggregate } from '../scripts/ListView'           ;
// 4. Components and Views. 
import DumpSQL                             from '../components/DumpSQL'         ;
import ErrorComponent                      from '../components/ErrorComponent'  ;
import SearchView                          from '../views/SearchView'           ;

const MODULE_NAME: string = 'Opportunities';
const TABLE_NAME : string = (Crm_Config.ToString('OpportunitiesMode') == 'Revenue' ? 'vwREVENUE_Pipeline' : 'vwOPPORTUNITIES_Pipeline');
const ORDER_BY   : string = 'USER_NAME';
const SELECT     : string = 'USER_NAME';
const GROUP_BY   : string = 'USER_NAME';
const AGGREGATE  : string = 'Count with sum as OPPORTUNITY_COUNT';

interface IMyPipelineBySalesStageState
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
export default class MyPipelineBySalesStage extends React.Component<IDashletProps, IMyPipelineBySalesStageState>
{
	private _isMounted = false;
	private Search;
	private LayoutLoaded;
	private chart;
	private valueAxis;
	private chartTitle;
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
		let arrSALES_STAGE = L10n.GetList('sales_stage_dom');
		let arrASSIGNED_USER_ID = [Security.USER_ID()];

		let dtDATE_START = new Date();
		let dtDATE_END = new Date(dtDATE_START.getFullYear() + 5, 0, 1)
		let objDEFAULT_SETTINGS: any = (!Sql.IsEmptyString(props.DEFAULT_SETTINGS) ? Sql.ParseFormData(props.DEFAULT_SETTINGS) : null);
		if (objDEFAULT_SETTINGS === undefined || objDEFAULT_SETTINGS == null)
		{
			objDEFAULT_SETTINGS = {};
			objDEFAULT_SETTINGS.SALES_STAGE = arrSALES_STAGE;
			objDEFAULT_SETTINGS.DATE_CLOSED = [dtDATE_START, dtDATE_END];
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
		};
	}

	componentDidMount()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount');
		this._isMounted = true;
		if ( !this.chart )
		{
			this.createChart();
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
		if (this.chart)
		{
			this.chart.dispose();
		}
	}
	
	private createChart = () =>
	{
		const { ID } = this.props;
		const { DEFAULT_SETTINGS } = this.state;
		let sLBL_OPP_SIZE                 = L10n.Term('Dashboard.LBL_OPP_SIZE'                );
		let sLBL_OPP_THOUSANDS            = L10n.Term('Dashboard.LBL_OPP_THOUSANDS'           );
		let sLBL_TOTAL_PIPELINE           = L10n.Term('Dashboard.LBL_TOTAL_PIPELINE'          );
		let sLBL_DATE_RANGE               = L10n.Term('Dashboard.LBL_DATE_RANGE'              );
		let sLBL_DATE_RANGE_TO            = L10n.Term('Dashboard.LBL_DATE_RANGE_TO'           );
		let sLBL_PIPELINE_FORM_TITLE_DESC = L10n.Term('Dashboard.LBL_PIPELINE_FORM_TITLE_DESC');
			
		// https://www.amcharts.com/docs/v4/chart-types/xy-chart/
		// https://codepen.io/team/amcharts/pen/GdQWxz?editors=1010
		let chart = am4core.create('dashlet.' + ID, am4charts.XYChart);
		if ( chart == null )
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount: ' + 'dashlet.' + ID + ' not found.');
			return;
		}
		chart.cursor = new am4charts.XYCursor();
		//chart.legend = new am4charts.Legend();
		chart.padding(40, 40, 40, 40);
		
		let oNumberFormat = Security.NumberFormatInfo();
		let categoryAxis = chart.yAxes.push(new am4charts.CategoryAxis());
		//categoryAxis.title.text = '';
		categoryAxis.renderer.grid.template.location = 0;
		categoryAxis.dataFields.category = 'category';
		//categoryAxis.renderer.minGridDistance = 30;
		
		let valueAxis = chart.xAxes.push(new am4charts.ValueAxis());
		//valueAxis.title.text = '';
		//valueAxis.renderer.minY = 0;
		this.valueAxis = valueAxis;
		
		let arrASSIGNED_USER_ID = [Security.USER_ID()];
		for ( let i = 0; i < arrASSIGNED_USER_ID.length; i++ )
		{
			let series:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
			series.name = L10n.ListTerm('AssignedUser', arrASSIGNED_USER_ID[i]);
			series.dataFields.categoryY = 'category';
			series.dataFields.valueX = L10n.ListTerm('AssignedUser', arrASSIGNED_USER_ID[i]);
			series.tooltipText = '{name}: [bold]{valueX}[/]';
			series.stacked = true;
		}
		
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

		let axisLabel = chart.chartContainer.createChild(am4core.Label);
		axisLabel.text = sLBL_OPP_SIZE + formatCurrency(1.0, oNumberFormat) + sLBL_OPP_THOUSANDS;
		axisLabel.x = am4core.percent(50);
		axisLabel.fontSize = '0.8em';
		axisLabel.verticalCenter = 'bottom';
		axisLabel.textAlign = 'middle';
		axisLabel.horizontalCenter = 'middle';
		axisLabel.fontWeight = '400';

		let footnote = chart.chartContainer.createChild(am4core.Label);
		footnote.text = sLBL_PIPELINE_FORM_TITLE_DESC;
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

		let sMONTHYEAR_FORMAT = Security.USER_DATE_FORMAT();
		sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('dd', '');
		sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('--', '-');
		sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('//', '/');
		sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.replace('  ', ' ');
		const sLBL_DATE_RANGE            = L10n.Term('Dashboard.LBL_DATE_RANGE'           );
		const sLBL_DATE_RANGE_TO         = L10n.Term('Dashboard.LBL_DATE_RANGE_TO'        );
		const sLBL_OPP_SIZE              = L10n.Term('Dashboard.LBL_OPP_SIZE'             );
		const sLBL_OPP_THOUSANDS         = L10n.Term('Dashboard.LBL_OPP_THOUSANDS'        );
		const sLBL_TOTAL_PIPELINE        = L10n.Term('Dashboard.LBL_TOTAL_PIPELINE'       );

		let oNumberFormat = Security.NumberFormatInfo();
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

		let sStartDate = '';
		let sEndDate   = '';
		if ( Array.isArray(DEFAULT_SETTINGS['DATE_CLOSED']) )
		{
			let oValue = DEFAULT_SETTINGS['DATE_CLOSED'];
			if ( oValue.length >= 1 && oValue[0] != null )
				sStartDate = FromJsonDate(DEFAULT_SETTINGS['DATE_CLOSED'][0], Security.USER_DATE_FORMAT());
			if ( oValue.length >= 2 && oValue[1] != null )
				sEndDate   = FromJsonDate(DEFAULT_SETTINGS['DATE_CLOSED'][1], Security.USER_DATE_FORMAT());
		}

		let arrSALES_STAGE = new Array();
		if ( DEFAULT_SETTINGS.SALES_STAGE != null )
		{
			for ( let i = 0; i < DEFAULT_SETTINGS.SALES_STAGE.length; i++ )
			{
				arrSALES_STAGE.push(DEFAULT_SETTINGS.SALES_STAGE[i]);
			}
		}
		if ( arrSALES_STAGE == null || arrSALES_STAGE.length == 0 )
		{
			arrSALES_STAGE = L10n.GetList('sales_stage_dom');
		}
	
		let arrSalesStage   = new Array();
		let arrActiveStages = new Array();
		let arrActiveUsers  = new Array();
		for ( let i = 0; i < arrSALES_STAGE.length; i++ )
		{
			let sSALES_STAGE = arrSALES_STAGE[i];
			let sSALES_STAGE_TERM = L10n.ListTerm('sales_stage_dom', arrSALES_STAGE[i]);
			arrActiveStages.unshift(sSALES_STAGE);
			arrSalesStage.unshift(sSALES_STAGE_TERM);
		}
		let sSEARCH_FILTER = SEARCH_FILTER;
		if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
			sSEARCH_FILTER += ' and ';
		sSEARCH_FILTER += "ASSIGNED_USER_ID = \'" + Security.USER_ID() + "\'";
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData SearchFilter: ' + sSEARCH_FILTER);
		let d = await ListView_LoadTableWithAggregate(TABLE_NAME, ORDER_BY, SELECT, sSEARCH_FILTER, null, GROUP_BY, AGGREGATE);
		if ( !this._isMounted )
			return;
		try
		{
			let dt = d.results;
			let arrSeriesData = new Array();
			for ( let i = 0; i < dt.length; i++ )
			{
				let row = dt[i];
				let sUSER_NAME = Sql.ToString(row['USER_NAME']);
				arrActiveUsers.push(sUSER_NAME);
				// 01/09/2015 Paul.  This is where we create the data matrix. 
				let arrStageSeries = new Array();
				for ( let j = 0; j < arrSALES_STAGE.length; j++ )
				{
					arrStageSeries.push(0.0);
				}
				arrSeriesData.push(arrStageSeries);
			}
			// 01/12/2015 Paul.  If no data, we still need to show an empty grid. 
			if ( dt.length == 0 )
			{
				arrActiveUsers.push(Security.USER_NAME());
				let arrStageSeries = new Array();
				for ( let j = 0; j < arrSALES_STAGE.length; j++ )
				{
					arrStageSeries.push(0.0);
				}
				arrSeriesData.push(arrStageSeries);
			}
		
			let arrSeriesUsers = new Array();
			if ( Array.isArray(arrActiveUsers) )
			{
				for ( let i = 0; i < arrActiveUsers.length; i++ )
				{
					let user: any = new Object();
					user.label = arrActiveUsers[i];
					arrSeriesUsers.push(user);
				}
			}
		
			let sORDER_BY       = 'LIST_ORDER, USER_NAME';
			let sSELECT         = 'SALES_STAGE, LIST_ORDER, ASSIGNED_USER_ID, USER_NAME';
			let sGROUP_BY       = 'SALES_STAGE, LIST_ORDER, ASSIGNED_USER_ID, USER_NAME';
			let sAGGREGATE      = 'AMOUNT_USDOLLAR with sum as TOTAL, Count with sum as OPPORTUNITY_COUNT';
			d = await ListView_LoadTableWithAggregate(TABLE_NAME, sORDER_BY, sSELECT, sSEARCH_FILTER, null, sGROUP_BY, sAGGREGATE);
			if ( !this._isMounted )
				return;
			try
			{
				let dt = d.results;
				let dPIPELINE_TOTAL = 0.0;
				for ( let i = 0; i < dt.length; i++ )
				{
					let row = dt[i];
					let sSALES_STAGE       = Sql.ToString (row["SALES_STAGE"      ]);
					let dTOTAL             = Sql.ToDouble (row["TOTAL"            ]) / 1000.0;
					let nOPPORTUNITY_COUNT = Sql.ToInteger(row["OPPORTUNITY_COUNT"]);
					let gASSIGNED_USER_ID  = Sql.ToGuid   (row["ASSIGNED_USER_ID" ]);
					let sUSER_NAME         = Sql.ToString (row["USER_NAME"        ]);
					dPIPELINE_TOTAL += dTOTAL;
		
					let nSALES_STAGE   = arrActiveStages.indexOf(sSALES_STAGE);
					let nUSER_NAME     = arrActiveUsers.indexOf (sUSER_NAME  );
					if ( nUSER_NAME >= 0 && nUSER_NAME < arrSeriesData.length )
					{
						let arrStageSeries = arrSeriesData[nUSER_NAME];
						if ( nSALES_STAGE >= 0 && nSALES_STAGE < arrStageSeries.length )
							arrStageSeries[nSALES_STAGE] += dTOTAL;
					}
				}
				let data = new Array();
				for ( let nSALES_STAGE = 0; nSALES_STAGE < arrActiveStages.length; nSALES_STAGE++ )
				{
					let item:any = {};
					data.push(item);
					item.category = arrActiveStages[nSALES_STAGE];
					for ( let nUSER_NAME = 0; nUSER_NAME < arrActiveUsers.length; nUSER_NAME++ )
					{
						if ( nUSER_NAME < arrSeriesData.length )
						{
							let arrStageSeries = arrSeriesData[nUSER_NAME];
							if ( nSALES_STAGE < arrStageSeries.length )
							{
								item[arrActiveUsers[nUSER_NAME]] = arrStageSeries[nSALES_STAGE];
							}
						}
					}
				}

				if ( !this.chart )
				{
					this.chart  = this.createChart();
				}
				if ( this.valueAxis != null )
				{
					this.valueAxis.title.text = sLBL_DATE_RANGE + ' ' + sStartDate + ' ' + sLBL_DATE_RANGE_TO + ' ' + sEndDate + ' ';
				}
				if ( this.chartTitle != null )
				{
					this.chartTitle.text = sLBL_TOTAL_PIPELINE + ' ' + formatCurrency(dPIPELINE_TOTAL, oNumberFormat) + sLBL_OPP_THOUSANDS;
				}
				if ( this.chart != null )
				{
					this.chart.data = data;
				}
				else
				{
					console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData: this.chart is null');
				}
				
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
