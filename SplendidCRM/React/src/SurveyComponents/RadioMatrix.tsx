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
import ResultsPaginateResponses                 from './ResultsPaginateResponses'   ;

const OTHER_ID: string = md5('Other');

interface IRadioMatrixState
{
	ID                     : string;
	VALUE                  : Record<string, Record<string, { checked: boolean, value: string }>>;
	OTHER_VALUE            : string;
	ANSWER_CHOICES         : string[];
	COLUMN_CHOICES         : string[];
	columnError            : any;
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

export default class RadioMatrix extends SurveyQuestion<ISurveyQuestionProps, IRadioMatrixState>
{
	private _isMounted = false;
	private inputs: any[] = [];
	private chart;

	public get data(): any
	{
		const { row } = this.props;
		const { VALUE, OTHER_VALUE, ANSWER_CHOICES, COLUMN_CHOICES, columnError } = this.state;
		let bValid  : boolean  = false;
		let arrValue: string[] = [];
		try
		{
			if ( ANSWER_CHOICES && COLUMN_CHOICES )
			{
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let nColumnsSelected: number = 0;
					let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
					for ( let j = 0; j < COLUMN_CHOICES.length; j++ )
					{
						let COLUMN_ID: string = md5(COLUMN_CHOICES[j]);
						if ( VALUE[ANSWER_ID] && VALUE[ANSWER_ID][COLUMN_ID] && VALUE[ANSWER_ID][COLUMN_ID].checked )
						{
							nColumnsSelected++;
							bValid = true;
							arrValue.push(VALUE[ANSWER_ID][COLUMN_ID].value);
							break;
						}
					}
					// 06/09/2013 Paul.  Any column checked will count the row as selected. 
					if ( nColumnsSelected > 0 )
					{
						bValid = true;
					}
					// 09/10/2018 Paul.  Must be required in order for required type to apply. 
					if ( Sql.ToString(row.REQUIRED_TYPE) == 'All' && Sql.ToBoolean(row.REQUIRED) )
					{
						columnError[ANSWER_ID] = (nColumnsSelected == 0);
					}
				}
			}
			if ( !bValid && Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				if ( !Sql.IsEmptyString(OTHER_VALUE) )
				{
					arrValue.push(OTHER_ID + ',' + OTHER_VALUE);
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
		const { VALUE, OTHER_VALUE, ANSWER_CHOICES, COLUMN_CHOICES, columnError } = this.state;
		let bValid: boolean = false;
		let sValue: string  = '';
		try
		{
			let nSelected: number = 0;
			let nTotal   : number = 0;
			if ( ANSWER_CHOICES && COLUMN_CHOICES )
			{
				nTotal = ANSWER_CHOICES.length;
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let nColumnsSelected: number = 0;
					let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
					for ( let j = 0; j < COLUMN_CHOICES.length; j++ )
					{
						let COLUMN_ID: string = md5(COLUMN_CHOICES[j]);
						if ( VALUE[ANSWER_ID] && VALUE[ANSWER_ID][COLUMN_ID] && VALUE[ANSWER_ID][COLUMN_ID].checked )
						{
							nColumnsSelected++;
							bValid = true;
 							break;
						}
					}
					// 06/09/2013 Paul.  Any column checked will count the row as selected. 
					if ( nColumnsSelected > 0 )
					{
						nSelected++;
					}
					// 09/10/2018 Paul.  Must be required in order for required type to apply. 
					if ( Sql.ToString(row.REQUIRED_TYPE) == 'All' && Sql.ToBoolean(row.REQUIRED) )
					{
						columnError[ANSWER_ID] = (nColumnsSelected == 0);
					}
				}
			}
			if ( Sql.ToBoolean(row.REQUIRED) )
			{
				if ( nSelected == 0 || (Sql.ToString(row.REQUIRED_TYPE) == 'All' && nSelected < nTotal) )
				{
					bValid = false;
				}
			}
			if ( !bValid && Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				let otherText = '';
				let other = OTHER_VALUE;
				if ( other != null )
				{
					otherText = Trim(other);
				}
				if ( !Sql.IsEmptyString(otherText) )
				{
					bValid = this.OtherValidation(otherText);
					if ( !bValid )
					{
						let error: string = this.OtherValidationMessage();
						this.setState({ error });
						return false;
					}
					sValue += otherText;
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
		let ID            : string = null;
		let VALUE         : Record<string, Record<string, { checked: boolean, value: string }>> = {};
		let OTHER_VALUE   : string = null;
		let ANSWER_CHOICES: string[] = null;
		let COLUMN_CHOICES: string[] = null;
		let columnError   : any = {};
		// 07/11/2021 Paul.  ID will be null in sample mode. 
		if ( row )
		{
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
			ANSWER_CHOICES = this.RandomizeAnswers();
			COLUMN_CHOICES = Sql.ToString(row.COLUMN_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			if ( Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				this.inputs.push(React.createRef<HTMLInputElement>());
				OTHER_VALUE = '';
			}
		}
		if ( displayMode == 'Sample' )
		{
			ANSWER_CHOICES = 'Taste\r\nSmell\r\nLooks'.split('\r\n');
			COLUMN_CHOICES = 'Bad\r\nAverage\r\nGood\r\nExcellent'.split('\r\n');
		}
		if ( ANSWER_CHOICES )
		{
			for (let i = 0; i < ANSWER_CHOICES.length; i++)
			{
				this.inputs.push(React.createRef<HTMLInputElement>());
				let ANSWER_ID = md5(ANSWER_CHOICES[i]);
				VALUE[ANSWER_ID] = {};
				columnError[ANSWER_ID] = false;
				for (let j = 0; j < COLUMN_CHOICES.length; j++)
				{
					let COLUMN_ID = md5(COLUMN_CHOICES[j]);
					VALUE[ANSWER_ID][COLUMN_ID] =
					{
						checked: false,
						value: ANSWER_ID + '_' + COLUMN_ID + ',' + ANSWER_CHOICES[i] + ',' + COLUMN_CHOICES[j]
					};
					if ( rowQUESTION_RESULTS )
					{
						for ( let j = 0; j < rowQUESTION_RESULTS.length; j++ )
						{
							if ( ANSWER_ID == rowQUESTION_RESULTS[j].ANSWER_ID || COLUMN_ID == rowQUESTION_RESULTS[j].COLUMN_ID )
							{
								VALUE[ANSWER_ID][COLUMN_ID].checked = true;
							}
							else if ( OTHER_ID == rowQUESTION_RESULTS[j].ANSWER_ID  && !row.OTHER_AS_CHOICE )
							{
								OTHER_VALUE = rowQUESTION_RESULTS[j].OTHER_TEXT;
							}
						}
					}
				}
			}
		}
		this.state =
		{
			ID            ,
			VALUE         ,
			OTHER_VALUE   ,
			ANSWER_CHOICES,
			COLUMN_CHOICES,
			columnError   ,
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

	private _onChange = (ANSWER_ID: string, COLUMN_ID: string): void =>
	{
		const { row } = this.props;
		let { VALUE, ANSWER_CHOICES } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			if ( !VALUE[ANSWER_ID][COLUMN_ID].checked )
			{
				const COLUMNS = Object.keys(VALUE[ANSWER_ID]);
				for ( let key of COLUMNS )
				{
					if ( key == COLUMN_ID )
					{
						VALUE[ANSWER_ID][COLUMN_ID].checked = true;
					}
					else
					{
						VALUE[ANSWER_ID][key].checked = false;
					}
				}
				// 08/24/2018 Paul.  When forced ranking is enabled, there can only be one value selected per column. 
				if ( Sql.ToBoolean(row.FORCED_RANKING) )
				{
					for (let i = 0; i < ANSWER_CHOICES.length; i++)
					{
						let key = md5(ANSWER_CHOICES[i]);
						if ( key != ANSWER_ID )
						{
							if ( VALUE[key][COLUMN_ID].checked )
							{
								VALUE[key][COLUMN_ID].checked = false;
							}
						}
					}
				}
			}
			this.setState({ VALUE });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onOtherChange = (e): void =>
	{
		const { row } = this.props;
		let { OTHER_VALUE } = this.state;
		let text: string = e.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			OTHER_VALUE = text;
			this.setState({ OTHER_VALUE });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onKeyDown = (event) =>
	{
		const { onFocusNextQuestion } = this.props;
		const { ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' )
		{
			if ( onFocusNextQuestion )
			{
				onFocusNextQuestion(ID);
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
		const { ID, VALUE, OTHER_VALUE, ANSWER_CHOICES, COLUMN_CHOICES, columnError, error } = this.state;
		// 07/28/2021 Paul.  Move empty filter lower so that header will be displayed. 
		if ( row )
		{
			// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
			let cssStyle : any    = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '6px' };
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			if ( Crm_Config.ToBoolean('enable_legacy_icons') )
			{
				cssStyle.transform = 'scale(1.0)';
				cssStyle.marginBottom = '2px';
			}
			// 12/31/2015 Paul.  Ignore margins on mobile device as they make the layout terrible. 
			if ( isMobileDevice() )
				cssStyle.width = '100%';
			
			let nLABEL_WIDTH: number = Sql.ToInteger(row.COLUMN_WIDTH);
			let nFIELD_WIDTH: number = 100 - nLABEL_WIDTH;
			let nColumns    : number = (COLUMN_CHOICES ? COLUMN_CHOICES.length : 1);
			let nCellWidth  : number = Math.floor(nFIELD_WIDTH / nColumns);

			let fragmentChildren = [];
			let fragment        = React.createElement(React.Fragment, null, fragmentChildren);
			fragmentChildren.push(this.RenderHeader());
			let tableChildren = [];
			let table         = React.createElement('table', {cellSpacing: 0, cellPadding: 0, border: 0, style: {width: '100%'}}, tableChildren);
			fragmentChildren.push(table);
			let tbodyChildren = [];
			let tbody         = React.createElement('tbody', {}, tbodyChildren);
			tableChildren.push(tbody);
			let trChildren    = [];
			let tr            = React.createElement('tr', {}, trChildren);
			tbodyChildren.push(tr);
			let tdChildren    = [];
			let td            = React.createElement('td', {verticalAlign: 'top', style: {width: nLABEL_WIDTH.toString() + '%'}}, tdChildren);
			trChildren.push(td);
			
			// 07/28/2021 Paul.  Move empty filter lower so that header will be displayed. 
			if ( COLUMN_CHOICES )
			{
				for ( let j = 0; j < COLUMN_CHOICES.length; j++ )
				{
					tdChildren    = [];
					td            = React.createElement('td', {verticalAlign: 'top', align: 'center', style: {width: nCellWidth.toString() + '%'}}, tdChildren);
					trChildren.push(td);
					let div = React.createElement('div', {className: 'SurveyColumnChoice'}, COLUMN_CHOICES[j]);
					tdChildren.push(div);
				}
			}
			// 07/28/2021 Paul.  Move empty filter lower so that header will be displayed. 
			if ( ANSWER_CHOICES )
			{
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
					trChildren    = [];
					tr            = React.createElement('tr', {className: (i % 2 == 0 ? 'SurveyColumnOddRow' : 'SurveyColumnEvenRow')}, trChildren);
					tbodyChildren.push(tr);
				
					tdChildren    = [];
					td            = React.createElement('td', {verticalAlign: 'top', style: {width: nLABEL_WIDTH.toString() + '%'}}, tdChildren);
					trChildren.push(td);
				
					let divChildren = [];
					let div = React.createElement('div', {className: 'SurveyColumnChoice'}, divChildren);
					tdChildren.push(div);
					divChildren.push(ANSWER_CHOICES[i]);
					if ( Sql.ToString(row.REQUIRED_TYPE) == 'All' )
					{
						if ( columnError[ANSWER_ID] )
						{
							let spnRequiredMessage = React.createElement('span', {className: 'SurveyQuestionError', style: {marginLeft: '10px', marginRight: '10px', backgroundColor: 'inherit'}}, row.REQUIRED_MESSAGE);
							divChildren.push(spnRequiredMessage);
						}
					}
					// 07/28/2021 Paul.  Move empty filter lower so that header will be displayed. 
					if ( COLUMN_CHOICES )
					{
						for ( let j = 0; j < COLUMN_CHOICES.length; j++ )
						{
							let COLUMN_ID: string = md5(COLUMN_CHOICES[j]);
							tdChildren    = [];
							td            = React.createElement('td', {verticalAlign: 'top', align: 'center', style: {width: nCellWidth.toString() + '%'}}, tdChildren);
							trChildren.push(td);

							divChildren = [];
							div = React.createElement('div', {className: 'SurveyColumnChoice'}, divChildren);
							tdChildren.push(div);

							let chkProps    = 
							{
								id       : ID + '_' + ANSWER_ID + '_' + COLUMN_ID,
								key      : ID + '_' + ANSWER_ID + '_' + COLUMN_ID,
								type     : 'radio',
								className: 'SurveyAnswerChoiceRadio',
								value    : ANSWER_ID + '_' + COLUMN_ID + ',' + ANSWER_CHOICES[i] + ',' + COLUMN_CHOICES[j],
								style    : cssStyle,
								disabled : Sql.ToBoolean(bDisable),
								checked  : VALUE[ANSWER_ID][COLUMN_ID].checked,
								onChange : (e) => { this._onChange(ANSWER_ID, COLUMN_ID); },
								ref      : this.inputs[i],
							};
							let chk         = React.createElement('input', chkProps, null);
							tdChildren.push(chk);
						}
					}
				}
			}
			if ( Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				let parent = fragmentChildren;
				let divOtherChildren = [];
				let divOther         = React.createElement('div', {className: 'SurveyAnswerChoice'}, divOtherChildren);
				parent.push(divOther);
				if ( Sql.ToInteger(row.OTHER_HEIGHT) > 1 )
				{
					let lab         = React.createElement('label', {className: 'SurveyAnswerChoice SurveyAnswerOther', htmlFor: ID + '_OtherText', style: {marginRight: '10px'}, dangerouslySetInnerHTML: {__html: Sql.ToString(row.OTHER_LABEL)}});
					divOtherChildren.push(lab);
					
					let cssText: any = {};
					let cols   : number = null;
					// 12/31/2015 Paul.  Ignore margins on mobile device as they make the layout terrible. 
					if ( isMobileDevice() )
						cssText.width = '100%';
					else if ( Sql.ToInteger(row.OTHER_WIDTH) > 0 )
						cols = row.OTHER_WIDTH;
					let txt         = React.createElement('textarea', {id: ID + '_OtherText', rows: row.OTHER_HEIGHT, cols: cols, style: cssText, value: OTHER_VALUE, disabled: bDisable, onChange: this._onOtherChange, onKeyDown: this._onKeyDown }, null);
					divOtherChildren.push(txt);
				}
				else
				{
					let lab         = React.createElement('label', {className: 'SurveyAnswerChoice SurveyAnswerOther', htmlFor: ID + '_OtherText', style: {marginRight: '10px'}, dangerouslySetInnerHTML: {__html: Sql.ToString(row.OTHER_LABEL)}});
					divOtherChildren.push(lab);
					
					let cssText: any = {};
					let size   : number = null;
					// 12/31/2015 Paul.  Ignore margins on mobile device as they make the layout terrible. 
					if ( isMobileDevice() )
						cssText.width = '100%';
					else if ( Sql.ToInteger(row.OTHER_WIDTH) > 0 )
						size = row.OTHER_WIDTH;
					let txt         = React.createElement('input', {id: ID + '_OtherText', type: 'text', size: size, style: cssText, value: OTHER_VALUE, disabled: bDisable, onChange: this._onOtherChange, onKeyDown: this._onKeyDown}, null);
					divOtherChildren.push(txt);
				}
			}
			return fragment;
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
		
		if ( !Sql.IsEmptyString(this.props.row.COLUMN_CHOICES) )
		{
			let arrCOLUMN_CHOICES     : string[] = Sql.ToString(this.props.row.COLUMN_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			for ( let j: number = arrCOLUMN_CHOICES.length - 1; j >= 0; j-- )
			{
				let series:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
				series.dataFields.categoryY  = 'category';
				series.dataFields.valueX     = 'column' + j.toString();
				series.tooltipText           = '{name}: [bold]{valueX}[/]';
				series.stacked               = false;
				series.name                  = arrCOLUMN_CHOICES[j];
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
		let sSELECT         : string = 'SURVEY_RESULT_ID, DATE_ENTERED, ANSWER_ID, ANSWER_TEXT, COLUMN_ID, COLUMN_TEXT, OTHER_TEXT';
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
		let OTHER_SUMMARY         : any[]  = new Array();
		let arrANSWER_CHOICES     : string[] = [];
		let arrCOLUMN_CHOICES     : string[] = [];

		if ( !Sql.IsEmptyString(this.props.row.ANSWER_CHOICES) && !Sql.IsEmptyString(this.props.row.COLUMN_CHOICES) )
		{
			arrANSWER_CHOICES = Sql.ToString(this.props.row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			arrCOLUMN_CHOICES = Sql.ToString(this.props.row.COLUMN_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			for ( let i: number = 0; i < arrANSWER_CHOICES.length; i++ )
			{
				let oSUMMARY: any = new Object();
				oSUMMARY.ANSWER_TEXT   = arrANSWER_CHOICES[i];
				oSUMMARY.ANSWER_ID     = md5(arrANSWER_CHOICES[i]);
				oSUMMARY.COLUMNS       = new Array();
				oSUMMARY.SKIPPED       = new Array();
				oSUMMARY.ANSWER_TOTAL  = 0;
				ANSWER_CHOICES_SUMMARY.push(oSUMMARY);
				for ( let j: number = 0; j < arrCOLUMN_CHOICES.length; j++ )
				{
					let oCOLUMN: any = new Object();
					oCOLUMN.COLUMN_TEXT = arrCOLUMN_CHOICES[j];
					oCOLUMN.COLUMN_ID   = md5(arrCOLUMN_CHOICES[j]);
					oCOLUMN.ANSWERED    = new Array();
					oSUMMARY.COLUMNS.push(oCOLUMN);
				}
			}
		}
		let sOTHER_ID       : string  = md5('Other');
		let bOTHER_ENABLED  : boolean = false;
		if ( Sql.ToBoolean(this.props.row.OTHER_ENABLED) )
		{
			bOTHER_ENABLED = true;
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
					if ( bOTHER_ENABLED && sOTHER_ID == row['ANSWER_ID'] )
					{
						if ( row['OTHER_TEXT'] != null )
						{
							OTHER_SUMMARY.push(row);
						}
					}
				}
				else
				{
					row['ANSWER_ID'] = Sql.ToString(row['ANSWER_ID']).replace(/-/g, '');
					row['COLUMN_ID'] = Sql.ToString(row['COLUMN_ID']).replace(/-/g, '');
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
									if ( oCOLUMN.COLUMN_ID == row['COLUMN_ID'] )
									{
										if ( row['COLUMN_TEXT'] != null )
										{
											oCOLUMN.ANSWERED.push(row);
											oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL++;
											if ( oANSWERED[row['SURVEY_RESULT_ID']] === undefined )
											{
												oANSWERED[row['SURVEY_RESULT_ID']] = true;
												nANSWERED++;
											}
										}
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
			OTHER_SUMMARY         ,
			bOTHER_ENABLED        ,
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
		let arrCOLUMN_CHOICES = Sql.ToString(row.COLUMN_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
		let nCOLUMNS          = arrCOLUMN_CHOICES.length;
		let nCOLUMN_WIDTH     = Math.ceil(100 / (nCOLUMNS + 2));
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
				<table className='SurveyResultsRadioMatrix' cellPadding={ 4 } cellSpacing={ 0 } style={ {border: 'none'} }>
					<tr>
						<td className='SurveyResultsAnswerMatrixHeader' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
						</td>
					{
						arrCOLUMN_CHOICES.map((COLUMN, index) => 
						{
							return(<td className='SurveyResultsAnswerMatrixHeader' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
								{ COLUMN }
							</td>);
						})
					}
						<td className='SurveyResultsResponseMatrixHeaderTotal' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
							{ L10n.Term('SurveyResults.LBL_RESPONSES') }
						</td>
					</tr>
				{
					ANSWER_CHOICES_SUMMARY.map((oANSWER_CHOICES_SUMMARY, index) => 
					{
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
						</tr>);
					})
				}
				</table>
				{ bOTHER_ENABLED
				? <div className='SurveyResultsOther'>
					<div>
						<a href='#' onClick={ (e) => { e.preventDefault(); this.toggleOtherResponses(); } }>{ row.OTHER_LABEL }</a>
					</div>
					{ bSHOW_RESPONSES
					? <div className='SurveyResultsAllResponses'>
						<ResultsPaginateResponses ANSWERED={ OTHER_SUMMARY } DATE_ENTERED_NAME='DATE_ENTERED' ANSWER_TEXT_NAME='OTHER_TEXT' />
					</div>
					: null
					}
				</div>
				: null
				}
			</div>
			: null
			}
			<div id={ this.props.row.SURVEY_ID + '_' + this.props.row.SURVEY_PAGE_ID + '_' + this.props.row.ID } style={{ width: '100%', height: '400px' }}></div>
		</div>
		);
	}
}

