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
import * as am4core                             from "@amcharts/amcharts4/core"     ;
import * as am4charts                           from "@amcharts/amcharts4/charts"   ;
import { Appear }                               from 'react-lifecycle-appear'       ;
// 2. Store and Types. 
import ISurveyQuestionProps                     from '../types/ISurveyQuestionProps';
import SurveyQuestion                           from './SurveyQuestion'             ;
// 3. Scripts. 
import Sql                                      from '../scripts/Sql'               ;
import L10n                                     from '../scripts/L10n'              ;
import { md5 }                                  from '../scripts/md5'               ;
import { Trim, isMobileDevice }                 from '../scripts/utility'           ;
import { ListView_LoadTable }                   from '../scripts/ListView'          ;
// 4. Components and Views. 
import ErrorComponent                           from '../components/ErrorComponent' ;
import ResultsPaginateResponses                 from './ResultsPaginateResponses'   ;

interface IRangeState
{
	ID                     : string;
	VALUE                  : number;
	RANGE_MIN              : number;
	RANGE_MAX              : number;
	RANGE_STEP             : number;
	error?                 : any;
	rawData?               : any[];
	__sql?                 : string;
	nANSWERED?             : number;
	nSKIPPED?              : number;
	ANSWER_CHOICES_SUMMARY?: any[];
}

export default class Range extends SurveyQuestion<ISurveyQuestionProps, IRangeState>
{
	private _isMounted = false;
	private chart;
	private input = React.createRef<HTMLInputElement>();

	public get data(): any
	{
		const { VALUE } = this.state;
		let arrValue: string[] = [];
		try
		{
			let sValue: string = Sql.ToString(VALUE);
			arrValue.push(sValue);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.data', error);
			throw new Error(this.constructor.name + '.data: ' + error.message);
		}
		return arrValue;
	}

	public validate(): boolean
	{
		const { row } = this.props;
		const { VALUE } = this.state;
		let bValid: boolean = true;
		try
		{
			if ( !bValid && Sql.ToBoolean(row.REQUIRED) )
			{
				let error: string = row.REQUIRED_MESSAGE;
				this.setState({ error });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.validate', error);
			this.setState({ error });
			bValid = false;
		}
		return bValid;
	}

	public setFocus(): void
	{
		if ( this.input.current != null )
		{
			this.input.current.focus();
		}
	}

	public isFocused(): boolean
	{
		let bIsFocused: boolean = false;
		if ( this.input.current != null )
		{
			bIsFocused = (this.input.current.id == document.activeElement.id);
		}
		return bIsFocused;
	}

	constructor(props: ISurveyQuestionProps)
	{
		super(props);
		const { displayMode, row, rowQUESTION_RESULTS } = props;
		let ID        : string = null;
		let VALUE     : number = 0;
		let RANGE_MIN : number = 0;
		let RANGE_MAX : number = 100;
		let RANGE_STEP: number = 1;
		let ANSWER_CHOICES: string[] = null;
		// 07/11/2021 Paul.  ID will be null in sample mode. 
		if ( row )
		{
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
			if ( row.ANSWER_CHOICES != null )
			{
				ANSWER_CHOICES = Sql.ToString(row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			}
		}
		if ( ANSWER_CHOICES )
		{
			RANGE_MIN = Sql.ToInteger(ANSWER_CHOICES[0]);
			if ( ANSWER_CHOICES != null &&  ANSWER_CHOICES.length > 0 )
			{
				RANGE_MAX = Sql.ToInteger(ANSWER_CHOICES[1]);
			}
			if ( ANSWER_CHOICES != null &&  ANSWER_CHOICES.length > 1 )
			{
				RANGE_STEP = Sql.ToInteger(ANSWER_CHOICES[2]);
			}
		}
		if ( rowQUESTION_RESULTS )
		{
			for ( let j: number = 0; j < rowQUESTION_RESULTS.length; j++ )
			{
				// 09/18/2016 Paul.  Answer may be null. 
				if ( rowQUESTION_RESULTS[j].ANSWER_TEXT != null )
				{
					VALUE = Sql.ToInteger(rowQUESTION_RESULTS[j].ANSWER_TEXT);
				}
				break;
			}
		}
		this.state =
		{
			ID        ,
			VALUE     ,
			RANGE_MIN ,
			RANGE_MAX ,
			RANGE_STEP,
		};
	}

	async componentDidMount()
	{
		try
		{
			if ( this.props.displayMode == 'Summary' )
			{
				if ( !this.chart )
				{
					this.createChart();
				}
				// 07/25/2021 Paul.  Loaded when panel appears. 
				//this.LoadData();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	componentWillUnmount()
	{
		if ( this.chart )
		{
			this.chart.dispose();
		}
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	private _onChange = (e): void =>
	{
		let value = Sql.ToInteger(e.target.value);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			this.setState({ VALUE: value });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	public render()
	{
		const { displayMode } = this.props;
		if ( displayMode == 'Report' )
		{
			return this.Report();
		}
		else if ( displayMode == 'Summary' )
		{
			return this.Summary();
		}
		else
		{
			return this.RenderQuestion(false);
		}
	}

	public RenderQuestion = (bDisable: boolean) =>
	{
		const { row } = this.props;
		const { ID, VALUE, RANGE_MIN, RANGE_MAX, RANGE_STEP, error } = this.state;
		if ( row )
		{
			// orient={ row.DISPLAY_FORMAT == 'vertical' ? 'vertical' : null }
			return (
				<React.Fragment>
					{ this.RenderHeader() }
					<span className='SurveyAnswerChoice SurveyAnswerRange' style={ {paddingRight: '4px'} }>{ RANGE_MIN }</span>
						<input
							type='range'
							id={ ID }
							key={ ID }
							className={ 'SurveyAnswerChoice SurveyAnswerRange' + (row.DISPLAY_FORMAT == 'vertical' ? ' SurveyAnswerRangeVertical' : '') }
							value={ VALUE }
							min={ RANGE_MIN }
							max={ RANGE_MAX }
							step={ RANGE_STEP }
							disabled={ bDisable }
							onChange={ this._onChange }
							ref={ this.input }
							/>
					<span className='SurveyAnswerChoice SurveyAnswerRange' style={ {paddingLeft: '4px'} }>{ RANGE_MAX }</span>
					<ErrorComponent error={error} />
				</React.Fragment>
			);
		}
		else
		{
			return null;
		}
	}

	public Report = () =>
	{
		return this.RenderQuestion(true);
	}

	private createChart = () =>
	{
		// https://www.amcharts.com/docs/v4/chart-types/xy-chart/
		// https://codepen.io/team/amcharts/pen/GdQWxz?editors=1010
		let chart = am4core.create(this.props.row.SURVEY_ID + '_' + this.props.row.SURVEY_PAGE_ID + '_' + this.props.row.ID, am4charts.XYChart);
		if ( chart == null )
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.createChart: ' + this.props.row.SURVEY_ID + '_' + this.props.row.SURVEY_PAGE_ID + '_' + this.props.row.ID + ' not found.');
			return;
		}
		chart.cursor = new am4charts.XYCursor();
		chart.padding(40, 40, 40, 40);
		
		let categoryAxis = chart.yAxes.push(new am4charts.CategoryAxis());
		categoryAxis.renderer.grid.template.location = 0;
		categoryAxis.renderer.labels.template.fontWeight = 'bold';
		categoryAxis.dataFields.category = 'category';
		
		let nRANGE_MIN            : number = 0  ;
		let nRANGE_MAX            : number = 100;
		let nRANGE_STEP           : number = 1  ;
		if ( !Sql.IsEmptyString(this.props.row.ANSWER_CHOICES) )
		{
			let arrANSWER_CHOICES = Sql.ToString(this.props.row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			nRANGE_MIN  = Sql.ToInteger(arrANSWER_CHOICES[0]);
			nRANGE_MAX  = 100;
			nRANGE_STEP = 1;
			if ( arrANSWER_CHOICES.length > 0 )
				nRANGE_MAX  = Sql.ToInteger(arrANSWER_CHOICES[1]);
			if ( arrANSWER_CHOICES.length > 1 )
				nRANGE_STEP = Sql.ToInteger(arrANSWER_CHOICES[2]);
			if ( nRANGE_STEP == 0 )
				nRANGE_STEP = 1;
			// 12/26/2015 Paul.  We will have a loop creating summary rows, so we need to make sure the values are valid. 
			if ( nRANGE_STEP > 0 )
			{
				if ( nRANGE_MIN > nRANGE_MAX )
				{
					nRANGE_MIN  = 0  ;
					nRANGE_MAX  = 100;
				}
			}
			else
			{
				if ( nRANGE_MIN < nRANGE_MAX )
				{
					nRANGE_MIN  = 0  ;
					nRANGE_MAX  = 100;
				}
			}
		}
		let valueAxis = chart.xAxes.push(new am4charts.ValueAxis());
		valueAxis.min  = nRANGE_MIN;
		valueAxis.max  = nRANGE_MAX;
		chart.numberFormatter.numberFormat = '#.##';
		
		let series:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
		series.dataFields.categoryY  = 'category';
		series.dataFields.valueX     = 'value';
		series.tooltipText           = '{name}: [bold]{valueX}[/]';
		series.stacked               = false;
		
		chart.data = [];
		this.chart = chart;
		return chart;
	}

	private LoadData = async () =>
	{
		let sTABLE_NAME     : string = 'SURVEY_QUESTIONS_RESULTS';
		let sSORT_FIELD     : string = 'DATE_ENTERED';
		let sSORT_DIRECTION : string = 'desc';
		let sSELECT         : string = 'SURVEY_RESULT_ID, DATE_ENTERED, ANSWER_ID, ANSWER_TEXT';
		let sFILTER         : string = 'SURVEY_ID eq \'' + this.props.row.SURVEY_ID + '\' and SURVEY_PAGE_ID eq \'' + this.props.row.SURVEY_PAGE_ID + '\' and SURVEY_QUESTION_ID eq \'' + this.props.row.ID + '\'';
		let rowSEARCH_VALUES: any = null;
		let d = await ListView_LoadTable(sTABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, false);
		
		let rawData               : any    = d.results;
		let __sql                 : string = d.__sql;
		let nANSWERED             : number = 0;
		let nSKIPPED              : number = 0;
		let oANSWERED             : any    = new Object();
		let oSKIPPED              : any    = new Object();
		let ANSWER_CHOICES_SUMMARY: any[]  = new Array();
		let nRANGE_MIN            : number = 0  ;
		let nRANGE_MAX            : number = 100;
		let nRANGE_STEP           : number = 1  ;

		if ( !Sql.IsEmptyString(this.props.row.ANSWER_CHOICES) )
		{
			let arrANSWER_CHOICES = Sql.ToString(this.props.row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			nRANGE_MIN  = Sql.ToInteger(arrANSWER_CHOICES[0]);
			nRANGE_MAX  = 100;
			nRANGE_STEP = 1;
			if ( arrANSWER_CHOICES.length > 0 )
				nRANGE_MAX  = Sql.ToInteger(arrANSWER_CHOICES[1]);
			if ( arrANSWER_CHOICES.length > 1 )
				nRANGE_STEP = Sql.ToInteger(arrANSWER_CHOICES[2]);
			if ( nRANGE_STEP == 0 )
				nRANGE_STEP = 1;
			// 12/26/2015 Paul.  We will have a loop creating summary rows, so we need to make sure the values are valid. 
			if ( nRANGE_STEP > 0 )
			{
				if ( nRANGE_MIN > nRANGE_MAX )
				{
					nRANGE_MIN  = 0  ;
					nRANGE_MAX  = 100;
				}
			}
			else
			{
				if ( nRANGE_MIN < nRANGE_MAX )
				{
					nRANGE_MIN  = 0  ;
					nRANGE_MAX  = 100;
				}
			}
		}
		if ( rawData != null )
		{
			for ( let i: number = rawData.length - 1; i >= 0; i-- )
			{
				let row: any = rawData[i];
				if ( row['ANSWER_TEXT'] == null )
				{
					if ( oSKIPPED[row['SURVEY_RESULT_ID']] === undefined )
					{
						oSKIPPED[row['SURVEY_RESULT_ID']] = true;
						nSKIPPED++;
					}
				}
				else
				{
					let bFound: boolean = false;
					for ( var j: number = 0; j < ANSWER_CHOICES_SUMMARY.length; j++ )
					{
						let oANSWER_CHOICES_SUMMARY: any = ANSWER_CHOICES_SUMMARY[j];
						if ( oANSWER_CHOICES_SUMMARY.ANSWER_TEXT == Sql.ToString(row['ANSWER_TEXT']) )
						{
							oANSWER_CHOICES_SUMMARY.ANSWERED.push(row);
							oANSWER_CHOICES_SUMMARY.TOTAL += Sql.ToFloat(row['ANSWER_TEXT']);
							if ( oANSWERED[row['SURVEY_RESULT_ID']] === undefined )
							{
								oANSWERED[row['SURVEY_RESULT_ID']] = true;
								nANSWERED++;
							}
							bFound = true;
						}
					}
					if ( !bFound )
					{
						let oSUMMARY: any = new Object();
						oSUMMARY.ANSWER_TEXT = Sql.ToString(row['ANSWER_TEXT']);
						oSUMMARY.ANSWER_ID   = '';
						oSUMMARY.ANSWERED    = new Array();
						oSUMMARY.SKIPPED     = new Array();
						oSUMMARY.TOTAL       = Sql.ToFloat(row['ANSWER_TEXT']);
						oSUMMARY.ANSWERED.push(row);
						ANSWER_CHOICES_SUMMARY.push(oSUMMARY);
						if ( oANSWERED[row['SURVEY_RESULT_ID']] === undefined )
						{
							oANSWERED[row['SURVEY_RESULT_ID']] = true;
							nANSWERED++;
						}
					}
				}
			}
			if ( ANSWER_CHOICES_SUMMARY.length > 0 )
			{
				ANSWER_CHOICES_SUMMARY.sort(function(a, b)
				{
					let al: number = Sql.ToFloat(a);
					let bl: number = Sql.ToFloat(b);
					return al == bl ? (a == b ? 0 : (a < b ? 1 : -1)) : (al < bl ? 1 : -1);
				});
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadData', ANSWER_CHOICES_SUMMARY);
			
			let data = new Array();
			for ( let j: number = 0; j < ANSWER_CHOICES_SUMMARY.length; j++ )
			{
				var oANSWER_CHOICES_SUMMARY = ANSWER_CHOICES_SUMMARY[j];
				let fAverage: number = oANSWER_CHOICES_SUMMARY.TOTAL / nANSWERED;
				oANSWER_CHOICES_SUMMARY.AVERAGE = fAverage.toFixed(2);
				
				let item:any = {};
				data.unshift(item);
				item.category = oANSWER_CHOICES_SUMMARY.ANSWER_TEXT;
				item.value    = fAverage;
			}
			if ( !this.chart )
			{
				this.chart  = this.createChart();
			}
			if ( this.chart != null )
			{
				this.chart.data = data;
			}
			else
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData: this.chart is null');
			}
		}
		this.setState(
		{
			rawData               ,
			__sql                 ,
			nANSWERED             ,
			nSKIPPED              ,
			ANSWER_CHOICES_SUMMARY,
		});
	}

	private toggleOtherResponses = (oANSWER_CHOICES_SUMMARY) =>
	{
		let { ANSWER_CHOICES_SUMMARY } = this.state;
		oANSWER_CHOICES_SUMMARY.SHOW_RESPONSES = !oANSWER_CHOICES_SUMMARY.SHOW_RESPONSES;
		this.setState({ ANSWER_CHOICES_SUMMARY });
	}

	public Summary = () =>
	{
		const { row } = this.props;
		const { ID, error, __sql } = this.state;
		const { nANSWERED, nSKIPPED, ANSWER_CHOICES_SUMMARY } = this.state;
		return (
		<div className='SurveyQuestionContent'>
			<Appear onAppearOnce={ (ioe) => this.LoadData() }>
				<div id={ ID + '_Error' } className='SurveyQuestionError'>
					{ error }
				</div>
				<div id={ ID + '_Heading' } className='SurveyQuestionHeading'>
					{ this.RenderHeader() }
					{ this.RenderAnswered(nANSWERED, nSKIPPED) }
				</div>
			</Appear>
			{ ANSWER_CHOICES_SUMMARY
			? <div id={ ID + '_Body' } className='SurveyQuestionBody'>
				<table className='SurveyResultsTextboxNumerical' cellPadding={ 4 } cellSpacing={ 0 } style={ {border: 'none'} }>
					<tr>
						<td className='SurveyResultsAnswerHeader' style={ {width: '55%'} }>
							{ L10n.Term('SurveyResults.LBL_ANSWER_CHOICES') }
						</td>
						<td className='SurveyResultsResponseHeader' style={ {width: '15%'} }>
							{ L10n.Term('SurveyResults.LBL_AVERAGE') }
						</td>
						<td className='SurveyResultsResponseHeader' style={ {width: '15%'} }>
							{ L10n.Term('SurveyResults.LBL_TOTAL') }
						</td>
						<td className='SurveyResultsResponseHeader' style={ {width: '15%'} }>
							{ L10n.Term('SurveyResults.LBL_RESPONSES') }
						</td>
					</tr>
				{
					ANSWER_CHOICES_SUMMARY.map((oANSWER_CHOICES_SUMMARY, index) => 
					{
						return(
						<tr>
							<td className='SurveyResultsAnswerBody' style={ {width: '55%'} }>
								<div style={ {float: 'left'} }>
									{ oANSWER_CHOICES_SUMMARY.ANSWER_TEXT }
								</div>
								<div style={ {float: 'right'} }>
									<a href='#' onClick={ (e) => { e.preventDefault(); this.toggleOtherResponses(oANSWER_CHOICES_SUMMARY); } }>{ L10n.Term('SurveyResults.LBL_RESPONSES') }</a>
								</div>
								{ oANSWER_CHOICES_SUMMARY.SHOW_RESPONSES
								? <div id={ row.ID + '_' + oANSWER_CHOICES_SUMMARY.ANSWER_ID } className='SurveyResultsAllResponses' style={ {clear: 'left'} }>
									<ResultsPaginateResponses ANSWERED={ oANSWER_CHOICES_SUMMARY.ANSWERED } DATE_ENTERED_NAME='DATE_ENTERED' ANSWER_TEXT_NAME='ANSWER_TEXT' />
								</div>
								: null
								}
							</td>
							<td className='SurveyResultsResponseBody' style={ {width: '15%'} } align='right'>
								{ oANSWER_CHOICES_SUMMARY.AVERAGE }
							</td>
							<td className='SurveyResultsResponseBody' style={ {width: '15%'} } align='right'>
								{ oANSWER_CHOICES_SUMMARY.TOTAL }
							</td>
							<td className='SurveyResultsResponseBody' style={ {width: '15%'} } align='right'>
								{ oANSWER_CHOICES_SUMMARY.ANSWERED.length }
							</td>
						</tr>);
					})
				}
				</table>
			</div>
			: null
			}
			<div id={ this.props.row.SURVEY_ID + '_' + this.props.row.SURVEY_PAGE_ID + '_' + this.props.row.ID } style={{ width: '100%', height: '400px' }}></div>
		</div>
		);
	}
}

