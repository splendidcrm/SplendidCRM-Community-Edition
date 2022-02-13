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
import { Crm_Config }                           from '../scripts/Crm'               ;
// 4. Components and Views. 
import ErrorComponent                           from '../components/ErrorComponent' ;

const OTHER_ID: string = md5('Other');
const CHARACTER_WIDTH: number = 10;

interface IRankingState
{
	ID                     : string;
	VALUE                  : Record<string, string>;
	ANSWER_CHOICES         : string[];
	dropdownWidth          : number;
	error?                 : any;
	rawData?               : any[];
	__sql?                 : string;
	nANSWERED?             : number;
	nSKIPPED?              : number;
	ANSWER_CHOICES_SUMMARY?: any[];
	OTHER_SUMMARY?         : any[];
	bOTHER_ENABLED?        : boolean;
	bSHOW_RESPONSES?       : boolean;
}

export default class Ranking extends SurveyQuestion<ISurveyQuestionProps, IRankingState>
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
					let nValue   : number = Sql.ToInteger(VALUE[ANSWER_ID]);
					if ( nValue > 0 )
					{
						arrValue.push(ANSWER_ID + ',' + ANSWER_CHOICES[i] + ',' + VALUE[ANSWER_ID]);
					}
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
		let sValue: string  = '';
		try
		{
			bValid = true;
			for ( var i = 0; i < ANSWER_CHOICES.length; i++ )
			{
				bValid = true;
				let ANSWER_ID = md5(ANSWER_CHOICES[i]);
				if ( VALUE[ANSWER_ID] )
				{
					if ( sValue.length > 0 )
						sValue += '|';
					sValue += VALUE[ANSWER_ID];
				}
				else
				{
					// 06/09/2013 Paul.  If any one item is blank, then the whole question is invalid. 
					bValid = false;
					break;
				}
			}
			if ( !bValid && Sql.ToBoolean(row.REQUIRED) )
			{
				let error: string = row.REQUIRED_MESSAGE;
				this.setState({ error });
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ', row);

		let ID            : string = null;
		let VALUE         : Record<string, string> = {};
		let ANSWER_CHOICES: string[] = null;
		let dropdownWidth : number = 200;
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
		if ( displayMode == 'Sample' )
		{
			ANSWER_CHOICES = 'Small\r\nMedium\r\nLarge'.split('\r\n');
		}
		if ( ANSWER_CHOICES )
		{
			// 08/19/2018 Paul.  After question reload, we need to re-order the choices based on value. 
			for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
			{
				this.inputs.push(React.createRef<HTMLSelectElement>());
				let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
				VALUE[ANSWER_ID] = undefined;
				if ( rowQUESTION_RESULTS )
				{
					for ( let m = 0; m < rowQUESTION_RESULTS.length; m++ )
					{
						if ( ANSWER_ID == rowQUESTION_RESULTS[m].ANSWER_ID )
						{
							VALUE[ANSWER_ID] = rowQUESTION_RESULTS[m].WEIGHT;
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
			dropdownWidth ,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
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
		this._isMounted = false;
		if ( this.chart )
		{
			this.chart.dispose();
		}
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	private getAnswerIndex = (ANSWER_ID) =>
	{
		let { ANSWER_CHOICES } = this.state;
		for (let i = 0; i < ANSWER_CHOICES.length; i++)
		{
			if ( ANSWER_ID == md5(ANSWER_CHOICES[i]) )
			{
				return i;
			}
		}
		return -1;
	}

	private _onSelectChange = (ANSWER_ID, val) =>
	{
		let { VALUE, ANSWER_CHOICES } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			if ( val == '-1' )
			{
				val = ANSWER_CHOICES.length.toString();
			}
			VALUE[ANSWER_ID] = val;
			// SurveyQuestion_Helper_RankingChange
			let oldIndex = this.getAnswerIndex(ANSWER_ID);
			if ( oldIndex >= 0 )
			{
				let oANSWER = ANSWER_CHOICES[oldIndex];
				if ( val == 'N/A' )
				{
					ANSWER_CHOICES.splice(oldIndex, 1);
					ANSWER_CHOICES.push(oANSWER);
				}
				else
				{
					var nValue = Sql.ToInteger(val) - 1;
					// 06/10/2013 Paul.  Place before any N/A cells. 
					while ( nValue > 0 && VALUE[md5(ANSWER_CHOICES[nValue])] == 'N/A' )
					{
						nValue--;
					}
					ANSWER_CHOICES.splice(oldIndex, 1);
					ANSWER_CHOICES.splice(nValue, 0, oANSWER);
				}
			}
			// 06/10/2013 Paul.  If there are any items without a ranking, then fix them. 
			for ( let j = 0; j < ANSWER_CHOICES.length; j++ )
			{
				let ANSWER_ID = md5(ANSWER_CHOICES[j]);
				if ( VALUE[ANSWER_ID] != 'N/A' )
				{
					VALUE[ANSWER_ID] = (j + 1).toString();
				}
			}
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
		const { ID, VALUE, ANSWER_CHOICES, error } = this.state;
		// 07/28/2021 Paul.  Move empty filter lower so that header will be displayed. 
		if ( row )
		{
			let cssStyle : any    = {};
			let size     : number = null;
			// 12/31/2015 Paul.  Ignore margins on mobile device as they make the layout terrible. 
			if ( isMobileDevice() )
				cssStyle.width = '100%';
			else if ( Sql.ToInteger(row.OTHER_WIDTH) > 0 )
				size = row.OTHER_WIDTH;
			
			let arrOptions = [];
			arrOptions.push(<option value=''></option>);
			if ( ANSWER_CHOICES )
			{
				for (let i = 0; i < ANSWER_CHOICES.length; i++)
				{
					let ANSWER_ID = md5(ANSWER_CHOICES[i]);
					arrOptions.push(<option value={ (i + 1).toString() }>{ (i + 1).toString() }</option>);
				}
			}
			if ( Sql.ToBoolean(row.NA_ENABLED) && !Sql.IsEmptyString(row.NA_LABEL) )
			{
				arrOptions.push(<option key="N/A" value="N/A">{ row.NA_LABEL }</option>);
			}
			return (
				<React.Fragment>
					{ this.RenderHeader() }
					{ ANSWER_CHOICES
					? <ul className='SurveyAnswerChoiceRanking'>
						{
							ANSWER_CHOICES.map((ANSWER_CHOICE, i) =>
							{
								let ANSWER_ID: string = md5(ANSWER_CHOICE);
								return(<li className='SurveyAnswerChoiceRanking ui-state-default'>
									<select
										id={ ID + '_' + ANSWER_ID }
										key={ ID + '_' + ANSWER_ID }
										className='SurveyAnswerChoiceRanking'
										value={ VALUE[ANSWER_ID] }
										disabled={ bDisable }
										onChange={ (event: React.ChangeEvent<HTMLSelectElement>) => { this._onSelectChange(ANSWER_ID, i); } }
										ref={ this.inputs[i] }
										>
										{ arrOptions }
									</select>
									&nbsp;&nbsp;
									<label htmlFor={ ID + '_' + ANSWER_ID } className='SurveyAnswerChoiceRanking'>{ ANSWER_CHOICE }</label>
								</li>)
							})
						}
					</ul>
					: null
					}
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
		chart.legend = new am4charts.Legend();
		chart.padding(40, 40, 40, 40);
		
		let categoryAxis = chart.yAxes.push(new am4charts.CategoryAxis());
		categoryAxis.renderer.grid.template.location = 0;
		categoryAxis.renderer.labels.template.fontWeight = 'bold';
		categoryAxis.dataFields.category = 'category';
		
		let valueAxis = chart.xAxes.push(new am4charts.ValueAxis());
		valueAxis.min = 0;
		valueAxis.max = 1;
		chart.numberFormatter.numberFormat = '#.%';
		
		let bNA_ENABLED: boolean  = Sql.ToBoolean(this.props.row.NA_ENABLED) && !Sql.IsEmptyString(this.props.row.NA_LABEL);
		if ( !Sql.IsEmptyString(this.props.row.ANSWER_CHOICES) )
		{
			let arrANSWER_CHOICES: string[] = Sql.ToString(this.props.row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			let arrCOLUMN_CHOICES: any[]    = [];
			for ( let i: number = 0; i < arrANSWER_CHOICES.length; i++ )
			{
				let oColumnChoice: any = new Object();
				oColumnChoice.Label  = (i + 1).toString();
				oColumnChoice.Weight = (i + 1);
				arrCOLUMN_CHOICES.push(oColumnChoice);
			}
			if ( bNA_ENABLED )
			{
				let oColumnChoice: any = new Object();
				oColumnChoice.Label  = L10n.Term('SurveyResults.LBL_NA');
				oColumnChoice.Weight = 0;
				arrCOLUMN_CHOICES.push(oColumnChoice);
			}
			for ( let j: number = arrCOLUMN_CHOICES.length - 1; j >= 0; j-- )
			{
				let oColumnChoice: any = arrCOLUMN_CHOICES[j];
				let series:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
				series.dataFields.categoryY  = 'category';
				series.dataFields.valueX     = 'column' + j.toString();
				series.tooltipText           = '{name}: [bold]{valueX}[/]';
				series.stacked               = false;
				series.name                  = oColumnChoice.Label;
			}
		}
		
		chart.data = [];
		this.chart = chart;
		return chart;
	}

	private LoadData = async () =>
	{
		let sTABLE_NAME     : string = 'SURVEY_QUESTIONS_RESULTS';
		let sSORT_FIELD     : string = 'DATE_ENTERED';
		let sSORT_DIRECTION : string = 'desc';
		let sSELECT         : string = 'SURVEY_RESULT_ID, DATE_ENTERED, ANSWER_ID, ANSWER_TEXT, WEIGHT';
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
		let arrANSWER_CHOICES     : string[] = [];
		let arrCOLUMN_CHOICES     : any[]    = [];
		let bNA_ENABLED           : boolean  = Sql.ToBoolean(this.props.row.NA_ENABLED) && !Sql.IsEmptyString(this.props.row.NA_LABEL);
		let sNA_ID                : string   = md5('N/A');

		if ( !Sql.IsEmptyString(this.props.row.ANSWER_CHOICES) )
		{
			arrANSWER_CHOICES = Sql.ToString(this.props.row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			for ( let i: number = 0; i < arrANSWER_CHOICES.length; i++ )
			{
				let oColumnChoice: any = new Object();
				oColumnChoice.Label  = (i + 1).toString();
				oColumnChoice.Weight = (i + 1);
				arrCOLUMN_CHOICES.push(oColumnChoice);
			}
			for ( let i: number = 0; i < arrANSWER_CHOICES.length; i++ )
			{
				let oSUMMARY: any = new Object();
				oSUMMARY.ANSWER_TEXT    = arrANSWER_CHOICES[i];
				oSUMMARY.ANSWER_ID      = md5(arrANSWER_CHOICES[i]);
				oSUMMARY.COLUMNS        = new Array();
				oSUMMARY.SKIPPED        = new Array();
				oSUMMARY.ANSWER_TOTAL   = 0;
				oSUMMARY.WEIGHT_TOTAL   = 0.0;
				ANSWER_CHOICES_SUMMARY.push(oSUMMARY);
				for ( let j: number = 0; j < arrCOLUMN_CHOICES.length; j++ )
				{
					let oCOLUMN: any = new Object();
					oCOLUMN.COLUMN_TEXT = arrCOLUMN_CHOICES[j].Label;
					oCOLUMN.COLUMN_ID   = md5(arrCOLUMN_CHOICES[j].Label);
					oCOLUMN.WEIGHT      = arrCOLUMN_CHOICES[j].Weight;
					oCOLUMN.ANSWERED    = new Array();
					oSUMMARY.COLUMNS.push(oCOLUMN);
				}
				if ( bNA_ENABLED )
				{
					let oCOLUMN: any = new Object();
					oCOLUMN.COLUMN_TEXT = L10n.Term('SurveyResults.LBL_NA');
					oCOLUMN.COLUMN_ID   = sNA_ID;
					oCOLUMN.WEIGHT      = 0;
					oCOLUMN.ANSWERED    = new Array();
					oSUMMARY.COLUMNS.push(oCOLUMN);
				}
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
					for ( let j: number = 0; j < ANSWER_CHOICES_SUMMARY.length; j++ )
					{
						let oANSWER_CHOICES_SUMMARY: any = ANSWER_CHOICES_SUMMARY[j];
						if ( oANSWER_CHOICES_SUMMARY.ANSWER_ID == row['ANSWER_ID'] )
						{
							if ( row['ANSWER_TEXT'] != null )
							{
								for ( let k: number = 0; k < oANSWER_CHOICES_SUMMARY.COLUMNS.length; k++ )
								{
									let oCOLUMN: any = oANSWER_CHOICES_SUMMARY.COLUMNS[k];
									if ( oCOLUMN.WEIGHT == row['WEIGHT'] )
									{
										if ( oANSWERED[row['SURVEY_RESULT_ID']] === undefined )
										{
											oANSWERED[row['SURVEY_RESULT_ID']] = true;
											nANSWERED++;
										}
										oCOLUMN.ANSWERED.push(row);
										oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL++;
										oANSWER_CHOICES_SUMMARY.WEIGHT_TOTAL += Sql.ToFloat(row['WEIGHT']);
									}
								}
							}
						}
					}
				}
			}
			let data = new Array();
			for ( let j: number = 0; j < ANSWER_CHOICES_SUMMARY.length; j++ )
			{
				let oANSWER_CHOICES_SUMMARY: any = ANSWER_CHOICES_SUMMARY[j];
				let item:any = {};
				data.unshift(item);
				item.category = oANSWER_CHOICES_SUMMARY.ANSWER_TEXT;
				for ( let k: number = 0; k < oANSWER_CHOICES_SUMMARY.COLUMNS.length; k++ )
				{
					let oCOLUMN: any = oANSWER_CHOICES_SUMMARY.COLUMNS[k];
					let nPercentage: number = 0;
					if ( oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL > 0 )
						nPercentage = oCOLUMN.ANSWERED.length / oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL;
					
					item['column' + k.toString()] = nPercentage;
				}
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
			//this.chart.data = data;
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

	private toggleOtherResponses = () =>
	{
		this.setState({ bSHOW_RESPONSES: !this.state.bSHOW_RESPONSES });
	}

	public Summary = () =>
	{
		const { row } = this.props;
		const { ID, error, __sql } = this.state;
		const { nANSWERED, nSKIPPED, ANSWER_CHOICES_SUMMARY, OTHER_SUMMARY, bOTHER_ENABLED, bSHOW_RESPONSES } = this.state;
		let arrCOLUMN_CHOICES: string[] = [];
		let arrANSWER_CHOICES: string[] = Sql.ToString(row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
		for ( let i: number = 0; i < arrANSWER_CHOICES.length; i++ )
		{
			arrCOLUMN_CHOICES.push((i + 1).toString());
		}
		let bNA_ENABLED  : boolean = Sql.ToBoolean(row.NA_ENABLED) && !Sql.IsEmptyString(row.NA_LABEL);
		let nCOLUMNS     : number = arrCOLUMN_CHOICES.length + (bNA_ENABLED ? 1 : 0);
		let nCOLUMN_WIDTH: number = (nCOLUMNS > 0 ? Math.ceil(100 / (nCOLUMNS + 3)) : 30);
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
				<table className='SurveyResultsRatingScale' cellPadding={ 4 } cellSpacing={ 0 } style={ {border: 'none'} }>
					<tr>
						<td className='SurveyResultsResponseMatrixHeader' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
						</td>
					{
						arrCOLUMN_CHOICES.map((COLUMN, index) => 
						{
							return(<td className='SurveyResultsResponseMatrixHeader' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
								{ COLUMN }
							</td>);
						})
					}
					{ bNA_ENABLED
					? <td className='SurveyResultsResponseMatrixHeader' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
						{ L10n.Term('SurveyResults.LBL_NA') }
					</td>
					: null
					}
						<td className='SurveyResultsResponseMatrixHeaderTotal' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
							{ L10n.Term('SurveyResults.LBL_RESPONSES') }
						</td>
						<td className='SurveyResultsResponseMatrixHeaderTotal' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
							{ L10n.Term('SurveyResults.LBL_AVERAGE_RATING') }
						</td>
					</tr>
				{
					ANSWER_CHOICES_SUMMARY.map((oANSWER_CHOICES_SUMMARY, index) => 
					{
						let sAverage: string = '0.00';
						if ( oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL > 0 )
							sAverage = (oANSWER_CHOICES_SUMMARY.WEIGHT_TOTAL / oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL).toFixed(2);
						return(
						<tr>
							<td className='SurveyResultsAnswerMatrixBody' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
								{ oANSWER_CHOICES_SUMMARY.ANSWER_TEXT }
							</td>
							{
								oANSWER_CHOICES_SUMMARY.COLUMNS.map((oCOLUMN, index) => 
								{
									let nPercentage: number = 0;
									if ( oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL > 0 )
										nPercentage = Math.ceil(100 * oCOLUMN.ANSWERED.length / oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL);
									return(<React.Fragment>
										<td className='SurveyResultsResponseBody' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
											<div style={ {float: 'left'} }>
												{ nPercentage.toString() + '%' }
											</div>
											<div style={ {float: 'right'} } className='SurveyResultsResponseMatrixBodyTotal'>
												{ oCOLUMN.ANSWERED.length }
											</div>
										</td>
									</React.Fragment>);
								})
							}
							<td className='SurveyResultsResponseMatrixTotal' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
								{ oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL }
							</td>
							<td className='SurveyResultsResponseMatrixTotal' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
								{ sAverage }
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

