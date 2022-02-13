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
import { RouteComponentProps, withRouter }            from 'react-router-dom'                          ;
import { observer }                                   from 'mobx-react'                                ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'            ;
import * as am4core                                   from "@amcharts/amcharts4/core"                  ;
import * as am4charts                                 from "@amcharts/amcharts4/charts"                ;
import * as XMLParser                                 from 'fast-xml-parser'                           ;
// 2. Store and Types. 
import { HeaderButtons }                              from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                            from '../../scripts/Sql'                         ;
import L10n                                           from '../../scripts/L10n'                        ;
import C10n                                           from '../../scripts/C10n'                        ;
import Security                                       from '../../scripts/Security'                    ;
import Credentials                                    from '../../scripts/Credentials'                 ;
import SplendidCache                                  from '../../scripts/SplendidCache'               ;
import { Crm_Modules }                                from '../../scripts/Crm'                         ;
import { FromJsonDate, formatDate, formatCurrency, formatNumber } from '../../scripts/Formatting'      ;
import { CreateSplendidRequest, GetSplendidResult }   from '../../scripts/SplendidRequest'             ;
import { dumpObj, uuidFast, Trim, EndsWith }          from '../../scripts/utility'                     ;
import { jsonReactState }                             from '../../scripts/Application'                 ;
import withScreenSizeHook                             from '../../scripts/ScreenSizeHook'              ;
// 4. Components and Views. 
import ErrorComponent                                 from '../../components/ErrorComponent'           ;
import DumpSQL                                        from '../../components/DumpSQL'                  ;

let MODULE_NAME: string = 'Charts';

interface IChartViewProps extends RouteComponentProps<any>
{
	ID?                 : string ;
	screenSize          : any    ;
	CHART_NAME          : string ;
	CHART_TYPE          : string ;
	MODULE              : string ;
	RELATED             : string ;
	MODULE_COLUMN_SOURCE: string ;
	SERIES_COLUMN       : string ;
	SERIES_OPERATOR     : string ;
	CATEGORY_COLUMN     : string ;
	CATEGORY_OPERATOR   : string ;
	filterXml           : any    ;
	relatedModuleXml    : any    ;
	relationshipXml     : any    ;
}

interface IChartViewState
{
	__sql            : string ;
	error            : any    ;
	data             : any    ;
}

class ChartView extends React.Component<IChartViewProps, IChartViewState>
{
	private _isMounted     : boolean = false;
	private chart          ;
	private chartTitle     ;
	private valueAxis      ;
	private lastRequest    : string = null;

	constructor(props: IChartViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor');
		this.state =
		{
			__sql                      : null,
			error                      : null,
			data                       : null,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		this._isMounted = true;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount');
		if ( !this.chart )
		{
			this.createChart();
			await this.loadData();
		}
	}

	shouldComponentUpdate(nextProps: IChartViewProps, nextState: IChartViewState)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate');
		let shouldUpdate: boolean = false;
		if ( nextProps.CHART_TYPE != this.props.CHART_TYPE || nextProps.MODULE != this.props.MODULE || nextProps.RELATED != this.props.RELATED )
		{
			shouldUpdate = true;
		}
		else if ( nextProps.MODULE != this.props.MODULE || nextProps.RELATED != this.props.RELATED || nextProps.MODULE_COLUMN_SOURCE != this.props.MODULE_COLUMN_SOURCE )
		{
			shouldUpdate = true;
		}
		else if ( nextProps.SERIES_COLUMN != this.props.SERIES_COLUMN || nextProps.SERIES_OPERATOR != this.props.SERIES_OPERATOR )
		{
			shouldUpdate = true;
		}
		else if ( nextProps.CATEGORY_COLUMN != this.props.CATEGORY_COLUMN || nextProps.CATEGORY_OPERATOR != this.props.CATEGORY_OPERATOR )
		{
			shouldUpdate = true;
		}
		else if ( JSON.stringify(nextProps.filterXml) != JSON.stringify(this.props.filterXml) )
		{
			shouldUpdate = true;
		}
		else if ( JSON.stringify(nextProps.relatedModuleXml) != JSON.stringify(this.props.relatedModuleXml) )
		{
			shouldUpdate = true;
		}
		else if ( JSON.stringify(nextProps.relationshipXml) != JSON.stringify(this.props.relationshipXml) )
		{
			shouldUpdate = true;
		}
		else if ( JSON.stringify(nextState.data) != JSON.stringify(this.state.data) )
		{
			shouldUpdate = true;
		}
		if ( shouldUpdate )
		{
			this.loadData();
		}
		return shouldUpdate;
	}

	componentWillUnmount()
	{
		this._isMounted = false;
		if ( this.chart )
		{
			this.chart.dispose();
		}
	}

	private GetFieldTitle = (sField: string) =>
	{
		let sTitle  : string = '';
		let arrField: string[] = sField.split('.');
		if ( arrField.length >= 2 )
		{
			let sTableName: string = arrField[0];
			let sFieldName: string = arrField[1];
			sTitle = L10n.TableColumnName(Crm_Modules.ModuleName(sTableName), sFieldName);
			sTitle = sTitle.replace(':', '');
		}
		return sTitle;
	}

	private GetFieldModule = (sField: string) =>
	{
		let sModuleName  : string = '';
		let arrField: string[] = sField.split('.');
		if ( arrField.length >= 2 )
		{
			let sTableName: string = arrField[0];
			sModuleName = Crm_Modules.ModuleName(sTableName);
		}
		return sModuleName;
	}

	private createChart = () =>
	{
		const { ID, CHART_NAME, CHART_TYPE, SERIES_COLUMN, CATEGORY_COLUMN } = this.props;
		// https://www.amcharts.com/docs/v4/chart-types/pie-chart/
		
		let arrSeriesName  : string[] = SERIES_COLUMN.split('.');
		let arrCategoryName: string[] = CATEGORY_COLUMN.split('.');
		
		let chart = null;
		if ( CHART_TYPE == 'Column' )
		{
			chart = am4core.create('ChartView.' + ID, am4charts.XYChart);
			if ( chart == null )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.createChart: ' + 'ChartView.' + ID + ' not found.');
				return;
			}
			chart.cursor = new am4charts.XYCursor();
			//chart.legend = new am4charts.Legend();
			chart.padding(40, 40, 40, 40);
		
			let categoryAxis = chart.xAxes.push(new am4charts.CategoryAxis());
			categoryAxis.title.text          = this.GetFieldTitle(CATEGORY_COLUMN);
			categoryAxis.dataFields.category = 'category';
			categoryAxis.renderer.grid.template.location = 0;
			//categoryAxis.renderer.minGridDistance = 30;
		
			let valueAxis = chart.yAxes.push(new am4charts.ValueAxis());
			valueAxis.title.text    = L10n.ListTerm('moduleList', this.GetFieldModule(SERIES_COLUMN));
			//valueAxis.renderer.minY = 0;
			this.valueAxis = valueAxis;
		
			let series:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
			series.dataFields.categoryX = 'category';
			series.dataFields.valueY    = 'value';
			
			// https://www.amcharts.com/docs/v4/reference/xychart/
			let title = chart.plotContainer.createChild(am4core.Label);
			title.text             = CHART_NAME;
			title.y                = -40;
			title.x                = am4core.percent(50);
			title.fontSize         = '1.2em';
			title.verticalCenter   = 'top';
			title.textAlign        = 'middle';
			title.horizontalCenter = 'middle';
			title.fontWeight       = '800';
			this.chartTitle        = title;

			chart.data = [];
			this.chart = chart;
		}
		else if ( CHART_TYPE == 'Bar' )
		{
			chart = am4core.create('ChartView.' + ID, am4charts.XYChart);
			if ( chart == null )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.createChart: ' + 'ChartView.' + ID + ' not found.');
				return;
			}
			chart.cursor = new am4charts.XYCursor();
			//chart.legend = new am4charts.Legend();
			chart.padding(40, 40, 40, 40);
		
			let categoryAxis = chart.yAxes.push(new am4charts.CategoryAxis());
			categoryAxis.title.text          = this.GetFieldTitle(CATEGORY_COLUMN);
			categoryAxis.dataFields.category = 'category';
			categoryAxis.renderer.grid.template.location = 0;
			//categoryAxis.renderer.minGridDistance = 30;
		
			let valueAxis = chart.xAxes.push(new am4charts.ValueAxis());
			valueAxis.title.text    = L10n.ListTerm('moduleList', this.GetFieldModule(SERIES_COLUMN));
			//valueAxis.renderer.minY = 0;
			this.valueAxis = valueAxis;
		
			let series:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
			series.dataFields.categoryY = 'category';
			series.dataFields.valueX    = 'value';
			
			// https://www.amcharts.com/docs/v4/reference/xychart/
			let title = chart.plotContainer.createChild(am4core.Label);
			title.text             = CHART_NAME;
			title.y                = -40;
			title.x                = am4core.percent(50);
			title.fontSize         = '1.2em';
			title.verticalCenter   = 'top';
			title.textAlign        = 'middle';
			title.horizontalCenter = 'middle';
			title.fontWeight       = '800';
			this.chartTitle        = title;

			chart.data = [];
			this.chart = chart;
		}
		else if ( CHART_TYPE == 'Line' )
		{
			chart = am4core.create('ChartView.' + ID, am4charts.XYChart);
			if ( chart == null )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.createChart: ' + 'ChartView.' + ID + ' not found.');
				return;
			}
			chart.cursor = new am4charts.XYCursor();
			//chart.legend = new am4charts.Legend();
			chart.padding(40, 40, 40, 40);
		
			let categoryAxis = chart.xAxes.push(new am4charts.CategoryAxis());
			categoryAxis.title.text          = this.GetFieldTitle(CATEGORY_COLUMN);
			categoryAxis.dataFields.category = 'category';
			categoryAxis.renderer.grid.template.location = 0;
			//categoryAxis.renderer.minGridDistance = 30;
		
			let valueAxis = chart.yAxes.push(new am4charts.ValueAxis());
			valueAxis.title.text    = L10n.ListTerm('moduleList', this.GetFieldModule(SERIES_COLUMN));
			//valueAxis.renderer.minY = 0;
			this.valueAxis = valueAxis;
		
			let series:am4charts.ColumnSeries = chart.series.push(new am4charts.LineSeries());
			series.dataFields.categoryX = 'category';
			series.dataFields.valueY    = 'value';
			
			// https://www.amcharts.com/docs/v4/reference/xychart/
			let title = chart.plotContainer.createChild(am4core.Label);
			title.text             = CHART_NAME;
			title.y                = -40;
			title.x                = am4core.percent(50);
			title.fontSize         = '1.2em';
			title.verticalCenter   = 'top';
			title.textAlign        = 'middle';
			title.horizontalCenter = 'middle';
			title.fontWeight       = '800';
			this.chartTitle        = title;

			chart.data = [];
			this.chart = chart;
		}
		else if ( CHART_TYPE == 'Shape' )
		{
			chart = am4core.create('ChartView.' + ID, am4charts.PieChart);
			if ( chart == null )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.createChart: ' + 'ChartView.' + ID + ' not found.');
				return;
			}
			//chart.legend          = new am4charts.Legend();
			//chart.legend.position = 'right';
			//chart.innerRadius     = am4core.percent(25);
			chart.padding(40, 40, 40, 40);
		
			let series = chart.series.push(new am4charts.PieSeries());
			series.dataFields.category = 'category';
			series.dataFields.value    = 'value';
			series.tooltipText         = '{name}: [bold]{valueX}[/]';
		
			let title = chart.chartContainer.createChild(am4core.Label);
			title.text             = CHART_NAME;
			title.y                = -40;
			title.x                = am4core.percent(50);
			title.fontSize         = '1.2em';
			title.verticalCenter   = 'top';
			title.textAlign        = 'middle';
			title.horizontalCenter = 'middle';
			title.fontWeight       = '800';
			this.chartTitle = title;

			chart.data = [];
			this.chart = chart;
		}
		return chart;
	}

	private loadData = async (): Promise<any> =>
	{
		const { CHART_NAME, CHART_TYPE, MODULE, RELATED, MODULE_COLUMN_SOURCE, SERIES_COLUMN, SERIES_OPERATOR, CATEGORY_COLUMN, CATEGORY_OPERATOR, filterXml, relatedModuleXml, relationshipXml } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData', filterXml);
		try
		{
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
			if ( !Sql.IsEmptyString(CHART_TYPE) && !Sql.IsEmptyString(MODULE) && !Sql.IsEmptyString(MODULE_COLUMN_SOURCE) )
			{
				// 02/09/2022 Paul.  Keep using MODULE to match Reports. 
				let row: any = { CHART_TYPE, MODULE, RELATED, MODULE_COLUMN_SOURCE, SERIES_COLUMN, SERIES_OPERATOR, CATEGORY_COLUMN, CATEGORY_OPERATOR, filterXml, relatedModuleXml, relationshipXml }
				let sBody: string = JSON.stringify(row);
				// 05/29/2021 Paul.  We don't need to update the request with every change. 
				if ( this.lastRequest != sBody )
				{
					this.lastRequest = sBody;
					
					let sUrl : string = 'Charts/Rest.svc/GetChartData';
					let res = await CreateSplendidRequest(sUrl, 'POST', 'application/octet-stream', sBody);
					let json = await GetSplendidResult(res);
					if ( !this._isMounted )
						return;
					
					let dt = json.d.results;
					let data = new Array();
					if ( CHART_TYPE == 'Column' || CHART_TYPE == 'Bar' || CHART_TYPE == 'Line' )
					{
						for ( let i = 0; i < dt.length; i++ )
						{
							let row: any = dt[i];
							let sNAME : string = Sql.ToString(row[CATEGORY_COLUMN]);
							let dTOTAL: number = Sql.ToDouble(row[SERIES_COLUMN  ]);
							let series:any = {};
							series.category    = sNAME;
							series.value       = dTOTAL;
							data.push(series);
						}
					}
					else if ( CHART_TYPE == 'Shape' )
					{
						let dCHART_TOTAL = 0.0;
						for ( let i = 0; i < dt.length; i++ )
						{
							let row = dt[i];
							dCHART_TOTAL += Sql.ToDouble(row[SERIES_COLUMN]);
						}
						
						for ( let i = 0; i < dt.length; i++ )
						{
							let row: any = dt[i];
							let sNAME : string = Sql.ToString(row[CATEGORY_COLUMN]);
							let dTOTAL: number = Sql.ToDouble(row[SERIES_COLUMN  ]);
							// 10/16/2021 Paul.  Add support for user currency. 
							dTOTAL = C10n.ToCurrency(dTOTAL);
							
							let slice:any = {};
							slice.category    = sNAME;
							slice.value       = dTOTAL;
							slice.name        = formatCurrency(dTOTAL, oNumberFormat);
							slice.percentage  = formatNumber(dTOTAL * 100 / dCHART_TOTAL, oNumberFormat) + ' %';
							slice.description = dTOTAL.toString() + ' ' + sNAME;
							data.push(slice);
						}
						if ( dt.length == 0 )
						{
							let arrRow = new Array();
							arrRow.push(null);
							data.push(arrRow)
						}
					}
					if ( !this.chart )
					{
						this.chart  = this.createChart();
					}
					if ( this.chartTitle != null )
					{
						this.chartTitle.text = CHART_NAME;
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
							__sql: json.__sql
						});
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData', error);
			this.setState({ error });
		}
	}

	public render()
	{
		const { ID, screenSize } = this.props;
		const { __sql, error, data } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', data);
		if ( SplendidCache.IsInitialized )
		{
			let height     : number = screenSize.height - 180;
			height = screenSize.height - 220;
			return (
			<React.Fragment>
				<DumpSQL SQL={ __sql } />
				<div id={ 'ChartView.' + ID } style={{ width: '100%', height: height }}></div>
			</React.Fragment>
			);
		}
		else if ( error )
		{
			return (<ErrorComponent error={error} />);
		}
		return null;
	}
}

export default withRouter(withScreenSizeHook(ChartView));
