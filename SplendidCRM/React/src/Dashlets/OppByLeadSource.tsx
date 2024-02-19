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
import C10n                                from '../scripts/C10n'               ;
import Security                            from '../scripts/Security'           ;
import Credentials                         from '../scripts/Credentials'        ;
import SplendidCache                       from '../scripts/SplendidCache'      ;
import { Crm_Config }                      from '../scripts/Crm'                ;
import { FromJsonDate, formatDate, formatCurrency, formatNumber } from '../scripts/Formatting';
import { ListView_LoadTableWithAggregate } from '../scripts/ListView'           ;
// 4. Components and Views. 
import DumpSQL                             from '../components/DumpSQL'         ;
import ErrorComponent                      from '../components/ErrorComponent'  ;
import SearchView                          from '../views/SearchView'           ;


const MODULE_NAME: string = 'Opportunities';
const TABLE_NAME : string = (Crm_Config.ToString('OpportunitiesMode') == 'Revenue' ? 'vwREVENUE_ByLeadSource' : 'vwOPPORTUNITIES_ByLeadSource');
const ORDER_BY   : string = 'LIST_ORDER';
const SELECT     : string = 'LEAD_SOURCE, LIST_ORDER';
const GROUP_BY   : string = 'LEAD_SOURCE, LIST_ORDER';
const AGGREGATE  : string = 'AMOUNT_USDOLLAR with sum as TOTAL, Count with sum as OPPORTUNITY_COUNT';

interface IOppByLeadSourceState
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
export default class OppByLeadSource extends React.Component<IDashletProps, IOppByLeadSourceState>
{
	private _isMounted = false;
	private Search;
	private LayoutLoaded;
	private chart;
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
		let arrLEAD_SOURCE = L10n.GetList('lead_source_dom');
		if ( arrLEAD_SOURCE != null )
		{
			// 06/15/2018 Paul.  Use slice so that we are modifying a copy. 
			arrLEAD_SOURCE = arrLEAD_SOURCE.slice();
			arrLEAD_SOURCE.unshift('');
		}
		let arrASSIGNED_USER_ID = L10n.GetList('AssignedUser');
		let objDEFAULT_SETTINGS: any = (!Sql.IsEmptyString(props.DEFAULT_SETTINGS) ? Sql.ParseFormData(props.DEFAULT_SETTINGS) : null);
		if (objDEFAULT_SETTINGS === undefined || objDEFAULT_SETTINGS == null)
		{
			objDEFAULT_SETTINGS = {};
			objDEFAULT_SETTINGS.LEAD_SOURCE = arrLEAD_SOURCE;
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
		let sLBL_LEAD_SOURCE_FORM_DESC = L10n.Term('Dashboard.LBL_LEAD_SOURCE_FORM_DESC');
			
		// https://www.amcharts.com/docs/v4/chart-types/pie-chart/
		let chart = am4core.create('dashlet.' + ID, am4charts.PieChart);
		if ( chart == null )
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount: ' + 'dashlet.' + ID + ' not found.');
			return;
		}
		//chart.legend = new am4charts.Legend();
		//chart.legend.position = 'right';
		//chart.innerRadius = am4core.percent(25);
		chart.padding(40, 40, 40, 40);
		
		let oNumberFormat = Security.NumberFormatInfo();
		let series = chart.series.push(new am4charts.PieSeries());
		series.dataFields.category = 'category';
		series.dataFields.value = 'value';
		series.tooltipText = '{name}: [bold]{valueX}[/]';
		
		let title = chart.chartContainer.createChild(am4core.Label);
		title.text = '';
		title.y = -40;
		title.x = am4core.percent(50);
		title.fontSize = '1.2em';
		title.verticalCenter = 'top';
		title.textAlign = 'middle';
		title.horizontalCenter = 'middle';
		title.fontWeight = '800';
		this.chartTitle = title;

		let footnote = chart.chartContainer.createChild(am4core.Label);
		footnote.text = sLBL_LEAD_SOURCE_FORM_DESC;
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
		let sLBL_OPPS_IN_LEAD_SOURCE   = L10n.Term('Dashboard.LBL_OPPS_IN_LEAD_SOURCE'  );

		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData SearchFilter: ' + SEARCH_FILTER);
		let d = await ListView_LoadTableWithAggregate(TABLE_NAME, ORDER_BY, SELECT, SEARCH_FILTER, null, GROUP_BY, AGGREGATE);
		if ( !this._isMounted )
			return;
		try
		{
			let dt = d.results;
			let data = new Array();
			let dPIPELINE_TOTAL = 0.0;
			for ( let i = 0; i < dt.length; i++ )
			{
				let row = dt[i];
				dPIPELINE_TOTAL += Sql.ToDouble(row['TOTAL']) / 1000.0;
			}
			
			for ( let i = 0; i < dt.length; i++ )
			{
				let row = dt[i];
				let sLEAD_SOURCE       = Sql.ToString (row['LEAD_SOURCE'      ]);
				let dTOTAL             = Sql.ToDouble (row['TOTAL'            ]) / 1000.0;
				let nOPPORTUNITY_COUNT = Sql.ToInteger(row['OPPORTUNITY_COUNT']);
				let sLEAD_SOURCE_TERM  = '';
				if ( Sql.IsEmptyString(sLEAD_SOURCE) )
					sLEAD_SOURCE_TERM = L10n.Term('.LBL_NONE_VALUE');
				else
					sLEAD_SOURCE_TERM = L10n.ListTerm('lead_source_dom', sLEAD_SOURCE)
				// 10/16/2021 Paul.  Add support for user currency. 
				dTOTAL = C10n.ToCurrency(dTOTAL);
				
				let slice:any = {};
				slice.category = sLEAD_SOURCE_TERM;
				slice.value = dTOTAL;
				slice.name = formatCurrency(dTOTAL, oNumberFormat);
				slice.percentage = formatNumber(dTOTAL * 100 / dPIPELINE_TOTAL, oNumberFormat) + ' %';
				slice.description = nOPPORTUNITY_COUNT.toString() + ' ' + sLBL_OPPS_IN_LEAD_SOURCE + ' ' + sLEAD_SOURCE_TERM;
				data.push(slice);
			}
			if ( dt.length == 0 )
			{
				let arrRow = new Array();
				arrRow.push(null);
				data.push(arrRow)
			}
			if ( !this.chart )
			{
				this.chart  = this.createChart();
			}
			if ( this.chartTitle != null )
			{
				// 01/20/2021 Paul.  Use \r\n instead of <br/>. 
				this.chartTitle.text = sLBL_TOTAL_PIPELINE + ' ' + formatCurrency(dPIPELINE_TOTAL, oNumberFormat) + sLBL_OPP_THOUSANDS;
				                     + '\r\n' + sLBL_OPP_SIZE + formatCurrency(1.0, oNumberFormat) + sLBL_OPP_THOUSANDS;
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
