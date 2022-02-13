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

interface ITextboxNumericalState
{
	ID                     : string;
	VALUE                  : Record<string, string>;
	ANSWER_CHOICES         : string[];
	error?                 : any;
	rawData?               : any[];
	__sql?                 : string;
	nANSWERED?             : number;
	nSKIPPED?              : number;
	ANSWER_CHOICES_SUMMARY?: any[];
}

export default class TextboxNumerical extends SurveyQuestion<ISurveyQuestionProps, ITextboxNumericalState>
{
	private _isMounted = false;
	private chart;
	private inputs: any[] = [];

	public get data(): any
	{
		const { row } = this.props;
		const { VALUE, ANSWER_CHOICES } = this.state;
		let arrValue: string[] = [];
		try
		{
		if ( ANSWER_CHOICES )
		{
			for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
			{
				let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
				let sValue   : string = Trim(VALUE[ANSWER_ID]);
				// 06/19/2013 Paul.  Even if no values, log that the user saw the question. 
				//if ( sValue.length > 0 )
					arrValue.push(ANSWER_ID + ',' + sValue);
			}
		}
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
		const { VALUE, ANSWER_CHOICES } = this.state;
		let bValid: boolean = false;
		try
		{
			let nSum    : number = 0;
			let sValue  : string = '';
			let selected: number = 0;
			let total   : number = 0;
			if ( ANSWER_CHOICES )
			{
				total = ANSWER_CHOICES.length;
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
					let txtValue : string = Trim(VALUE[ANSWER_ID]);
					if ( txtValue.length > 0 )
					{
						if ( sValue.length > 0 )
						{
							sValue += ',';
						}
						sValue += txtValue;
						selected++;
						let nValue = parseInt(sValue, 10);
						bValid = !isNaN(nValue);
						if ( !bValid || nValue < 0 )
						{
							let error: string = row.INVALID_NUMBER_MESSAGE;
							this.setState({ error });
							return false;
						}
						else
						{
							nSum += nValue;
						}
					}
				}
			}
			if ( Sql.ToBoolean(row.REQUIRED) )
			{
				// 06/09/2013 Paul.  If type is blank, then use existing bValid value. 
				// 03/14/2019 Paul.  If no values provided, then required type not important. 
				if ( bValid && !Sql.IsEmptyString(row.REQUIRED_TYPE) )
				{
					bValid = this.RequiredTypeValidation(selected, total);
					if ( !bValid )
					{
						let error: string = this.RequiredTypeMessage(total);
						this.setState({ error });
					}
				}
				else if ( !bValid )
				{
					let error: string = row.REQUIRED_MESSAGE;
					this.setState({ error });
					return false;
				}
			}
			else
			{
				bValid = true;
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
		if ( this.inputs.length > 0 )
		{
			if ( this.inputs[0].current != null )
			{
				this.inputs[0].current.focus();
			}
		}
	}

	public isFocused(): boolean
	{
		let bIsFocused: boolean = false;
		if ( this.inputs.length > 0 )
		{
			for ( let i = 0; i < this.inputs.length; i++ )
			{
				if ( this.inputs[i].current != null )
				{
					if ( this.inputs[i].current.id == document.activeElement.id )
					{
						bIsFocused = true;
						break;
					}
				}
			}
		}
		return bIsFocused;
	}

	constructor(props: ISurveyQuestionProps)
	{
		super(props);
		const { displayMode, row, rowQUESTION_RESULTS } = props;
		let ID            : string = null;
		let VALUE         : Record<string, string> = {};
		let ANSWER_CHOICES: string[] = null;
		// 07/11/2021 Paul.  ID will be null in sample mode. 
		if ( row )
		{
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
			ANSWER_CHOICES = this.RandomizeAnswers();
		}
		if ( displayMode == 'Sample' )
		{
			ANSWER_CHOICES = 'Height\r\nWidth\r\nDepth'.split('\r\n');
		}
		if ( ANSWER_CHOICES )
		{
			for (let i = 0; i < ANSWER_CHOICES.length; i++)
			{
				this.inputs.push(React.createRef<HTMLInputElement>());
				let ANSWER_ID = md5(ANSWER_CHOICES[i]);
				VALUE[ANSWER_ID] = '';
				if ( rowQUESTION_RESULTS )
				{
					for ( let j = 0; j < rowQUESTION_RESULTS.length; j++ )
					{
						if ( ANSWER_ID == rowQUESTION_RESULTS[j].ANSWER_ID )
						{
							VALUE[ANSWER_ID] = rowQUESTION_RESULTS[j].ANSWER_TEXT;
							break;
						}
					}
				}
			}
		}
		this.state =
		{
			ID            ,
			VALUE         ,
			ANSWER_CHOICES,
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

	private _onChange = (ANSWER_ID: string, text: string): void =>
	{
		let { VALUE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			VALUE[ANSWER_ID] = text;
			this.setState({ VALUE });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onKeyDown = (i: number, event) =>
	{
		const { onFocusNextQuestion } = this.props;
		const { ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' )
		{
			if ( i + 1 < this.inputs.length )
			{
				this.inputs[i+1].current.focus();
			}
			else
			{
				if ( onFocusNextQuestion )
				{
					onFocusNextQuestion(ID);
				}
			}
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
		const { ID, VALUE, ANSWER_CHOICES, error } = this.state;
		// 07/28/2021 Paul.  Move empty filter lower so that header will be displayed. 
		if ( row )
		{
			let size: any = null;
			let cssStyle: any = {};
			// 12/31/2015 Paul.  Ignore margins on mobile device as they make the layout terrible. 
			if ( isMobileDevice() )
				cssStyle.width = '100%';
			// 11/11/2018 Paul.  Use size not cols. 
			else if ( Sql.ToInteger(row.BOX_WIDTH ) > 0 )
				size = Sql.ToInteger(row.BOX_WIDTH);
			let nLABEL_WIDTH = Sql.ToInteger(row.COLUMN_WIDTH);
			let nFIELD_WIDTH = 100 - nLABEL_WIDTH;
			
			let arrTableRows = [];
			// 07/28/2021 Paul.  Move empty filter lower so that header will be displayed. 
			if ( ANSWER_CHOICES )
			{
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
					let tr = (<tr>
						<td style={ {width: nLABEL_WIDTH.toString() + '%'} }>
							<div className='SurveyAnswerChoice'>
								<label htmlFor={ ID + '_' + ANSWER_ID }>{ ANSWER_CHOICES[i] }</label>
							</div>
						</td>
						<td style={ {width: nFIELD_WIDTH.toString() + '%'} }>
							<div className='SurveyAnswerChoice'>
								<input
									type='text'
									id={ ID + '_' + ANSWER_ID }
									key={ ID + '_' + ANSWER_ID }
									className='SurveyAnswerChoiceTextbox'
									style={ cssStyle }
									size={ size }
									value={ VALUE[ANSWER_ID] }
									disabled={ bDisable }
									onChange={ (e) => { this._onChange(ANSWER_ID, e.target.value); } }
									onKeyDown={ (e) => { this._onKeyDown(i, e); } }
									ref={ this.inputs[i] }
									/>
							</div>
						</td>
					</tr>);
					arrTableRows.push(tr);
				}
			}
			return (
				<React.Fragment>
					{ this.RenderHeader() }
					<table style={ {width: '100%'} } cellSpacing={ 2 } cellPadding={ 2 }>
						<tbody>
						{ arrTableRows }
						</tbody>
					</table>
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
		
		let valueAxis = chart.xAxes.push(new am4charts.ValueAxis());
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
		let sSELECT         : string = 'SURVEY_RESULT_ID, DATE_ENTERED, ANSWER_ID, ANSWER_TEXT, OTHER_TEXT';
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

		if ( !Sql.IsEmptyString(this.props.row.ANSWER_CHOICES) )
		{
			let arrANSWER_CHOICES = Sql.ToString(this.props.row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			for ( let i: number = 0; i < arrANSWER_CHOICES.length; i++ )
			{
				let oSUMMARY: any = new Object();
				oSUMMARY.ANSWER_TEXT   = arrANSWER_CHOICES[i];
				oSUMMARY.ANSWER_ID     = md5(arrANSWER_CHOICES[i]);
				oSUMMARY.ANSWERED      = new Array();
				oSUMMARY.SKIPPED       = new Array();
				oSUMMARY.TOTAL         = 0.0;
				oSUMMARY.AVERAGE       = 0.0;
				ANSWER_CHOICES_SUMMARY.push(oSUMMARY);
			}
		}
		if ( rawData != null )
		{
			for ( let i: number = rawData.length - 1; i >= 0; i-- )
			{
				let row: any = rawData[i];
				if ( row['ANSWER_ID'] == null )
				{
					if ( oSKIPPED[row['SURVEY_RESULT_ID']] === undefined )
					{
						oSKIPPED[row['SURVEY_RESULT_ID']] = true;
						nSKIPPED++;
					}
				}
				else
				{
					row['ANSWER_ID'] = Sql.ToString(row['ANSWER_ID']).replace(/-/g, '');
					for ( var j = 0; j < ANSWER_CHOICES_SUMMARY.length; j++ )
					{
						var oANSWER_CHOICES_SUMMARY = ANSWER_CHOICES_SUMMARY[j];
						if ( oANSWER_CHOICES_SUMMARY.ANSWER_ID == row['ANSWER_ID'] )
						{
							if ( row['ANSWER_TEXT'] != null )
							{
								oANSWER_CHOICES_SUMMARY.ANSWERED.push(row);
								oANSWER_CHOICES_SUMMARY.TOTAL += Sql.ToFloat(row['ANSWER_TEXT']);
								if ( oANSWERED[row['SURVEY_RESULT_ID']] === undefined )
								{
									oANSWERED[row['SURVEY_RESULT_ID']] = true;
									nANSWERED++;
								}
							}
							else
							{
								oANSWER_CHOICES_SUMMARY.SKIPPED.push(row);
								if ( oSKIPPED[row['SURVEY_RESULT_ID']] === undefined )
								{
									oSKIPPED[row['SURVEY_RESULT_ID']] = true;
									nSKIPPED++;
								}
							}
						}
					}
				}
			}
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

