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
import { RouteComponentProps, withRouter } from 'react-router-dom'               ;
import { observer }                        from 'mobx-react'                     ;
// https://www.amcharts.com/docs/v4/getting-started/basics/
import * as am4core                        from "@amcharts/amcharts4/core"       ;
import * as am4charts                      from "@amcharts/amcharts4/charts"     ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                 from '../../scripts/Sql'              ;
import L10n                                from '../../scripts/L10n'             ;
import Security                            from '../../scripts/Security'         ;
import { ListView_LoadTableWithAggregate } from '../../scripts/ListView'         ;
// 4. Components and Views. 
import ErrorComponent                      from '../../components/ErrorComponent';

const MODULE_NAME: string = 'Campaigns';
const TABLE_NAME : string = 'vwCAMPAIGNS_Activity';
const ORDER_BY   : string = 'LIST_ORDER, TARGET_TYPE';
const SELECT     : string = 'ACTIVITY_TYPE, LIST_ORDER, TARGET_TYPE';
const GROUP_BY   : string = 'ACTIVITY_TYPE, LIST_ORDER, TARGET_TYPE';
const AGGREGATE  : string = 'Count with sum as HIT_COUNT';

interface IResponseByRecipientActivityProps extends RouteComponentProps<any>
{
	ID               : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IResponseByRecipientActivityState
{
	DEFAULT_SETTINGS : any;
	SEARCH_FILTER    : string;
	data             : any;
	error            : any;
}

@observer
class ResponseByRecipientActivity extends React.Component<IResponseByRecipientActivityProps, IResponseByRecipientActivityState>
{
	private _isMounted = false;
	private chart;

	constructor(props: IResponseByRecipientActivityProps)
	{
		super(props);
		let ACTIVITY_TYPE = L10n.GetList('campainglog_activity_type_dom');
		let TARGET_TYPE   = L10n.GetList('campainglog_target_type_dom');
		if ( ACTIVITY_TYPE != null )
		{
			// 06/15/2018 Paul.  Use slice so that we are modifying a copy. 
			ACTIVITY_TYPE = ACTIVITY_TYPE.slice().reverse();
		}
		let objDEFAULT_SETTINGS: any = {};
		objDEFAULT_SETTINGS.ACTIVITY_TYPE = ACTIVITY_TYPE;
		objDEFAULT_SETTINGS.TARGET_TYPE   = TARGET_TYPE  ;
		this.state =
		{
			DEFAULT_SETTINGS: objDEFAULT_SETTINGS,
			SEARCH_FILTER   : 'ID eq \'' + props.ID + '\'',
			data: null,
			error: null
		}
	}

	async componentDidMount()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount');
		this._isMounted = true;
		if ( !this.chart )
		{
			this.createChart();
			await this.loadData();
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
		const { DEFAULT_SETTINGS } = this.state;
		
		// https://www.amcharts.com/docs/v4/chart-types/xy-chart/
		// https://codepen.io/team/amcharts/pen/GdQWxz?editors=1010
		let chart = am4core.create('ResponseByRecipientActivity', am4charts.XYChart);
		if ( chart == null )
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount: ' + 'ResponseByRecipientActivity' + ' not found.');
			return;
		}
		chart.cursor = new am4charts.XYCursor();
		chart.legend = new am4charts.Legend();
		chart.padding(40, 40, 40, 40);
		
		let categoryAxis = chart.yAxes.push(new am4charts.CategoryAxis());
		//categoryAxis.title.text = '';
		categoryAxis.renderer.grid.template.location = 0;
		categoryAxis.dataFields.category = 'category';
		//categoryAxis.renderer.minGridDistance = 30;
		
		let valueAxis = chart.xAxes.push(new am4charts.ValueAxis());
		valueAxis.title.text = '';
		//valueAxis.renderer.minY = 0;
		
		if ( DEFAULT_SETTINGS.TARGET_TYPE != null )
		{
			for ( let i = 0; i < DEFAULT_SETTINGS.TARGET_TYPE.length; i++ )
			{
				let series:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
				series.name                  = L10n.ListTerm('moduleList', DEFAULT_SETTINGS.TARGET_TYPE[i]);
				series.dataFields.categoryY  = 'category';
				series.dataFields.valueX     = DEFAULT_SETTINGS.TARGET_TYPE[i];
				series.tooltipText           = '{name}: [bold]{valueX}[/]';
				//series.columns.template.tooltipText   = '{name}: {valueX.value}';
				//series.columns.template.tooltipY      = 0;
				//series.columns.template.strokeOpacity = 0;
				series.stacked               = true;
			}
		}
		
		// https://www.amcharts.com/docs/v4/reference/xychart/
		let title = chart.plotContainer.createChild(am4core.Label);
		title.text             = L10n.Term('Campaigns.LBL_CAMPAIGN_RESPONSE_BY_RECIPIENT_ACTIVITY');
		title.y                = -40;
		title.x                = am4core.percent(50);
		title.fontSize         = '1.2em';
		title.verticalCenter   = 'top';
		title.textAlign        = 'middle';
		title.horizontalCenter = 'middle';
		title.fontWeight       = '800';

		//let axisLabel = chart.chartContainer.createChild(am4core.Label);
		//axisLabel.text = sLBL_OPP_SIZE + formatCurrency(1.0, oNumberFormat) + sLBL_OPP_THOUSANDS;
		//axisLabel.x                = am4core.percent(50);
		//axisLabel.fontSize         = '0.8em';
		//axisLabel.verticalCenter   = 'bottom';
		//axisLabel.textAlign        = 'middle';
		//axisLabel.horizontalCenter = 'middle';
		//axisLabel.fontWeight       = '400';

		let footnote = chart.chartContainer.createChild(am4core.Label);
		footnote.text             = '';
		footnote.x                = am4core.percent(50);
		footnote.fontSize         = '0.8em';
		footnote.verticalCenter   = 'bottom';
		footnote.textAlign        = 'middle';
		footnote.horizontalCenter = 'middle';
		footnote.fontWeight       = '400';

		chart.data = [];
		this.chart = chart;
		return chart;
	}

	private loadData = async (): Promise<any> =>
	{
		const { DEFAULT_SETTINGS, SEARCH_FILTER } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData ' + SEARCH_FILTER, DEFAULT_SETTINGS);

		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData SearchFilter: ' + SEARCH_FILTER);
		try
		{
			let d = await ListView_LoadTableWithAggregate(TABLE_NAME, ORDER_BY, SELECT, SEARCH_FILTER, null, GROUP_BY, AGGREGATE)
			if ( !this._isMounted )
				return;
			try
			{
				let dt = d.results;
				let data = new Array();
				if ( DEFAULT_SETTINGS.ACTIVITY_TYPE != null )
				{
					for ( let i = 0; i < DEFAULT_SETTINGS.ACTIVITY_TYPE.length; i++ )
					{
						let ACTIVITY_TYPE = DEFAULT_SETTINGS.ACTIVITY_TYPE[i];
						let ACTIVITY_TYPE_TERM = '';
						if ( !Sql.IsEmptyString(ACTIVITY_TYPE) )
						{
							ACTIVITY_TYPE_TERM = L10n.ListTerm('campainglog_activity_type_dom', ACTIVITY_TYPE);
						}
						let objLeadSource = { category: ACTIVITY_TYPE_TERM  };
						for ( let j = 0; j < DEFAULT_SETTINGS.TARGET_TYPE.length; j++ )
						{
							let TARGET_TYPE = DEFAULT_SETTINGS.TARGET_TYPE[j];
							objLeadSource[TARGET_TYPE] = 0;
						}
						data.push(objLeadSource);
					}
				}
				for ( let i = 0; i < dt.length; i++ )
				{
					let row = dt[i];
					let ACTIVITY_TYPE = Sql.ToString (row["ACTIVITY_TYPE"]);
					let TARGET_TYPE   = Sql.ToString (row["TARGET_TYPE"  ]);
					let HIT_COUNT     = Sql.ToInteger(row["HIT_COUNT"    ]);
		
					let nACTIVITY_TYPE = DEFAULT_SETTINGS.ACTIVITY_TYPE.indexOf(ACTIVITY_TYPE);
					if ( nACTIVITY_TYPE >= 0 )
					{
						data[nACTIVITY_TYPE][TARGET_TYPE]  += HIT_COUNT;
					}
					else
					{
						console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData ACTIVITY_TYPE ' + ACTIVITY_TYPE + ' not found.');
					}
				}
				if ( !this.chart )
				{
					this.chart  = this.createChart();
				}
				if ( this.chart != null )
					this.chart.data = data;
				else
					console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData: this.chart is null');
				
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData:', data);
				// 06/01/2019 Paul.  The component may be unmounted by the time the custom view is generated. 
				if ( this._isMounted )
				{
					this.setState({ data: data });
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

	public render()
	{
		const { error } = this.state;
		return (
			<div>
				<ErrorComponent error={error} />
				<div id='ResponseByRecipientActivity' style={{ width: '100%', height: '600px' }}></div>
			</div>
		);
	}
}

export default withRouter(ResponseByRecipientActivity);
