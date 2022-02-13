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
import ResultsPaginateResponses                 from './ResultsPaginateResponses'   ;

const OTHER_ID: string = md5('Other');

interface ICheckboxState
{
	ID                     : string;
	VALUE:
	{
		[ID: string]:
		{
			checked: boolean,
			value: any
		}
	};
	OTHER_VALUE:
	{
		checked: boolean,
		value  : string,
	};
	ANSWER_CHOICES         : string[];
	error?                 : any;
	rawData?               : any[];
	__sql?                 : string;
	nANSWERED?             : number;
	nSKIPPED?              : number;
	ANSWER_CHOICES_SUMMARY?: any[];
	OTHER_SUMMARY?         : any[];
	sOTHER_ID?             : string ;
	bOTHER_ENABLED?        : boolean;
	bOTHER_AS_CHOICE?      : boolean;
	bSHOW_RESPONSES?       : boolean;
}

export default class Checkbox extends SurveyQuestion<ISurveyQuestionProps, ICheckboxState>
{
	private _isMounted = false;
	private inputs: any[] = [];
	private chart;

	public get data(): any
	{
		const { row } = this.props;
		const { VALUE, OTHER_VALUE, ANSWER_CHOICES } = this.state;
		let bValid  : boolean  = false;
		let arrValue: string[] = [];
		try
		{
			let nSelected: number = 0;
			let nTotal   : number = 0;
			if ( ANSWER_CHOICES )
			{
				nTotal = ANSWER_CHOICES.length;
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
					if ( VALUE[ANSWER_ID] && VALUE[ANSWER_ID].checked )
					{
						bValid = true;
						nSelected++;
						arrValue.push(VALUE[ANSWER_ID].value);
					}
				}
			}
			// 07/27/2021 Paul.  OTHER_VALUE might be null. 
			if ( Sql.ToBoolean(row.OTHER_ENABLED) && OTHER_VALUE )
			{
				if ( Sql.ToBoolean(row.OTHER_AS_CHOICE) )
				{
					if ( OTHER_VALUE.checked )
					{
						if ( !Sql.IsEmptyString(OTHER_VALUE.value) )
						{
							arrValue.push(OTHER_ID + ',' + OTHER_VALUE.value);
						}
					}
				}
				else if ( !Sql.IsEmptyString(OTHER_VALUE.value) )
				{
					arrValue.push(OTHER_ID + ',' + OTHER_VALUE.value);
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
		const { VALUE, OTHER_VALUE, ANSWER_CHOICES } = this.state;
		let bValid: boolean = false;
		let sValue: string  = '';
		try
		{
			let nSelected: number = 0;
			let nTotal   : number = 0;
			if ( !Sql.IsEmptyString(row.ANSWER_CHOICES) )
			{
				nTotal = ANSWER_CHOICES.length;
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
					let chk = VALUE[ANSWER_ID];
					if ( chk != null && chk.checked )
					{
						bValid = true;
						nSelected++;
						if (sValue.length > 0)
							sValue += '|';
						sValue += chk.value;
					}
				}
			}
			if ( Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				let otherText = '';
				let other = OTHER_VALUE;
				if ( other != null )
				{
					otherText = Trim(other.value);
				}
				if ( Sql.ToBoolean(row.OTHER_AS_CHOICE) )
				{
					if ( other != null && other.checked )
					{
						if ( Sql.IsEmptyString(otherText) )
						{
							let error: string = row.OTHER_REQUIRED_MESSAGE;
							this.setState({ error });
							// 06/09/2013 Paul.  If Other selected but not provied, then display other required message by exiting early. 
							return false;
						}
						else
						{
							bValid = this.OtherValidation(otherText);
							if ( !bValid )
							{
								let error: string = this.OtherValidationMessage();
								this.setState({ error });
								return false;
							}
							if ( sValue.length > 0 )
							{
								sValue += ',';
							}
							sValue += otherText;
						}
					}
				}
				else if (!Sql.IsEmptyString(otherText))
				{
					bValid = this.OtherValidation(otherText);
					if ( !bValid )
					{
						let error: string = this.OtherValidationMessage();
						this.setState({ error });
						return false;
					}
					if ( sValue.length > 0 )
					{
						sValue += ',';
					}
					sValue += otherText;
				}
			}
			if ( Sql.ToBoolean(row.REQUIRED) )
			{
				// 06/09/2013 Paul.  If type is blank, then use existing bValid value. 
				if ( !Sql.IsEmptyString(row.REQUIRED_TYPE) )
				{
					bValid = this.RequiredTypeValidation(nSelected, nTotal);
					if ( !bValid )
					{
						let error: string = this.RequiredTypeMessage(nTotal);
						this.setState({ error });
					}
				}
				else if ( !bValid )
				{
					let error: string = row.REQUIRED_MESSAGE;
					this.setState({ error });
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
		let VALUE         : any    = {};
		let OTHER_VALUE   : any    = null;
		let ANSWER_CHOICES: string[] = null;
		// 07/11/2021 Paul.  ID will be null in sample mode. 
		if ( row )
		{
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
			ANSWER_CHOICES = this.RandomizeAnswers();
			if ( Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				this.inputs.push(React.createRef<HTMLInputElement>());
				OTHER_VALUE =
				{
					checked: false,
					value: ''
				};
			}
		}
		if ( displayMode == 'Sample' )
		{
			ANSWER_CHOICES = 'China\r\nEurope\r\nMiddle East\r\nSouth America'.split('\r\n');
		}
		if ( ANSWER_CHOICES )
		{
			for (let i = 0; i < ANSWER_CHOICES.length; i++)
			{
				this.inputs.push(React.createRef<HTMLInputElement>());
				let ANSWER_ID = md5(ANSWER_CHOICES[i]);
				VALUE[ANSWER_ID] =
				{
					checked: false,
					value  : ANSWER_ID + ',' + ANSWER_CHOICES[i]
				};
				if ( rowQUESTION_RESULTS )
				{
					for ( let j = 0; j < rowQUESTION_RESULTS.length; j++ )
					{
						if ( ANSWER_ID == rowQUESTION_RESULTS[j].ANSWER_ID )
						{
							VALUE[ANSWER_ID].checked = true;
						}
						else if ( OTHER_ID == rowQUESTION_RESULTS[j].ANSWER_ID )
						{
							// 07/27/2021 Paul.  OTHER_VALUE might be null. 
							OTHER_VALUE = { checked: false };
							if ( Sql.ToBoolean(row.OTHER_AS_CHOICE) )
							{
								OTHER_VALUE.checked = true;
							}
							OTHER_VALUE.value = rowQUESTION_RESULTS[j].OTHER_TEXT;
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

	private _onChange = (ANSWER_ID: string): void =>
	{
		let { VALUE, OTHER_VALUE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			if ( ANSWER_ID == OTHER_ID )
			{
				// 07/27/2021 Paul.  OTHER_VALUE might be null. 
				OTHER_VALUE.checked = (OTHER_VALUE ? !OTHER_VALUE.checked : true);
				this.setState({ OTHER_VALUE });
			}
			else
			{
				VALUE[ANSWER_ID].checked = !VALUE[ANSWER_ID].checked;
				this.setState({ VALUE });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onOtherChange = (e): void =>
	{
		const { row } = this.props;
		let { VALUE, OTHER_VALUE } = this.state;
		let text: string = e.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			// 07/27/2021 Paul.  OTHER_VALUE might be null. 
			if ( OTHER_VALUE == null )
				OTHER_VALUE = { checked: false, value: null };
			OTHER_VALUE.value = text;
			// 08/15/2018 Paul.  When the user starts typing in the Other textbox, make sure to set the flag. 
			if ( Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				if ( Sql.ToBoolean(row.OTHER_AS_CHOICE) )
				{
					OTHER_VALUE.checked = true;
				}
			}
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
		const { ID, VALUE, OTHER_VALUE, ANSWER_CHOICES, error } = this.state;
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
			
			let nColumns  : number = 1;
			let nCellWidth: number = 100;
			let nChoices  : number = (ANSWER_CHOICES ? ANSWER_CHOICES.length : 1);
			if ( Sql.ToBoolean(row.OTHER_ENABLED) && Sql.ToBoolean(row.OTHER_AS_CHOICE) )
			{
				nChoices++;
			}
			let nChoicesPerColumn = Math.ceil(nChoices / nColumns);
			if ( row.DISPLAY_FORMAT == 'horizontal' )
			{
				nColumns          = nChoices;
				nCellWidth        = Math.floor(100 / nChoices);
				nChoicesPerColumn = 1;
			}
			else
			{
				nColumns = parseInt(row.DISPLAY_FORMAT);
				if ( isNaN(nColumns) )
				{
					nColumns = 1;
				}
				nCellWidth = Math.floor(100 / nColumns);
				nChoicesPerColumn = Math.ceil(nChoices / nColumns);
			}

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
			let trChildrenChildren = [];
			let tr            = React.createElement('tr', {}, trChildren);
			tbodyChildren.push(tr);
			let tdChildren    = [];
			let td            = null;
			
			let nCurrentColumn: number = 0;
			let bVerticalFill = Sql.ToBoolean(row.VERTICAL_FILL);
			if ( !bVerticalFill )
			{
				for ( let i = 0; i < nColumns; i++ )
				{
					tdChildren = [];
					td         = React.createElement('td', { verticalAlign: 'top', style: {width: nCellWidth.toString() + '%'}}, tdChildren);
					trChildren.push(td);
					trChildrenChildren.push(tdChildren);
				}
			}
			// 07/28/2021 Paul.  Move empty filter lower so that header will be displayed. 
			if ( ANSWER_CHOICES )
			{
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
					if ( bVerticalFill )
					{
						if ( td == null || (i % nChoicesPerColumn == 0) )
						{
							tdChildren = [];
							td         = React.createElement('td', { verticalAlign: 'top', style: {width: nCellWidth.toString() + '%'}}, tdChildren);
							trChildren.push(td);
							trChildrenChildren.push(tdChildren);
						}
					}
					else
					{
						td         = trChildren[nCurrentColumn];
						tdChildren = trChildrenChildren[nCurrentColumn];
						nCurrentColumn++;
						if ( nCurrentColumn >= nColumns )
						{
							nCurrentColumn = 0;
						}
					}
					let divChildren = [];
					let div         = React.createElement('div', {className: 'SurveyAnswerChoice'}, divChildren);
					tdChildren.push(div);
					let chkProps    = 
					{
						id       : ID + '_' + ANSWER_ID,
						key      : ID + '_' + ANSWER_ID,
						type     : 'checkbox',
						className: 'SurveyAnswerChoiceCheckbox',
						value    : ANSWER_ID + ',' + ANSWER_CHOICES[i],
						style    : cssStyle,
						disabled : Sql.ToBoolean(bDisable),
						checked  : VALUE[ANSWER_ID].checked,
						onChange : (e) => { this._onChange(ANSWER_ID); },
						ref      : this.inputs[i],
					};
					let chk         = React.createElement('input', chkProps, null);
					tdChildren.push(chk);
					let lab         = React.createElement('label', {htmlFor: ID + '_' + ANSWER_ID, style: {marginLeft: '10px'}}, ANSWER_CHOICES[i]);
					tdChildren.push(lab);
				}
			}
			if ( Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				let parent = (bVerticalFill ? fragmentChildren : trChildrenChildren[nCurrentColumn]);
				let divOtherChildren = [];
				let divOther         = React.createElement('div', {className: 'SurveyAnswerChoice'}, divOtherChildren);
				parent.push(divOther);
				if ( Sql.ToBoolean(row.OTHER_AS_CHOICE) )
				{
					if ( this.inputs.length <= (ANSWER_CHOICES ? ANSWER_CHOICES.length : 0) )
						this.inputs.push(React.createRef<HTMLInputElement>());
					// 07/27/2021 Paul.  OTHER_VALUE might be null. 
					let chkProps    = 
					{
						id       : ID + '_Other',
						key      : ID + '_Other',
						type     : 'checkbox',
						className: 'SurveyAnswerChoiceCheckbox',
						value    : 'Other',
						style    : cssStyle,
						disabled : Sql.ToBoolean(bDisable),
						checked  : (OTHER_VALUE ? OTHER_VALUE.checked : false),
						onChange : (e) => { this._onChange(OTHER_ID); },
						ref      : this.inputs[(ANSWER_CHOICES ? ANSWER_CHOICES.length : 0)],
					};
					let chk         = React.createElement('input', chkProps, null);
					divOtherChildren.push(chk);
					if ( Sql.ToBoolean(row.OTHER_AS_CHOICE) )
					{
						let lab         = React.createElement('label', {className: 'SurveyAnswerChoice SurveyAnswerOther', htmlFor: ID + '_Other', style: {marginLeft: '10px'}, dangerouslySetInnerHTML: {__html: Sql.ToString(row.OTHER_LABEL)}});
						divOtherChildren.push(lab);
					}
				}
				
				if ( Sql.ToInteger(row.OTHER_HEIGHT) > 1 )
				{
					if ( !Sql.ToBoolean(row.OTHER_AS_CHOICE) )
					{
						let lab         = React.createElement('label', {className: 'SurveyAnswerChoice SurveyAnswerOther', htmlFor: ID + '_OtherText', style: {marginRight: '10px'}, dangerouslySetInnerHTML: {__html: Sql.ToString(row.OTHER_LABEL)}});
						divOtherChildren.push(lab);
					}
					let cssText: any = {};
					let cols   : number = null;
					// 12/31/2015 Paul.  Ignore margins on mobile device as they make the layout terrible. 
					if ( isMobileDevice() )
						cssText.width = '100%';
					else if ( Sql.ToInteger(row.OTHER_WIDTH) > 0 )
						cols = row.OTHER_WIDTH;
					// 07/27/2021 Paul.  OTHER_VALUE might be null. 
					let txt         = React.createElement('textarea', {id: ID + '_OtherText', rows: row.OTHER_HEIGHT, cols: cols, style: cssText, value: (OTHER_VALUE ? OTHER_VALUE.value : null), disabled: bDisable, onChange: this._onOtherChange, onKeyDown: this._onKeyDown }, null);
					divOtherChildren.push(txt);
				}
				else
				{
					if ( !Sql.ToBoolean(row.OTHER_AS_CHOICE) )
					{
						let lab         = React.createElement('label', {className: 'SurveyAnswerChoice SurveyAnswerOther', htmlFor: ID + '_OtherText', style: {marginRight: '10px'}, dangerouslySetInnerHTML: {__html: Sql.ToString(row.OTHER_LABEL)}});
						divOtherChildren.push(lab);
					}
					let cssText: any = {};
					let size   : number = null;
					// 12/31/2015 Paul.  Ignore margins on mobile device as they make the layout terrible. 
					if ( isMobileDevice() )
						cssText.width = '100%';
					else if ( Sql.ToInteger(row.OTHER_WIDTH) > 0 )
						size = row.OTHER_WIDTH;
					// 07/27/2021 Paul.  OTHER_VALUE might be null. 
					let txt         = React.createElement('input', {id: ID + '_OtherText', type: 'text', size: size, style: cssText, value: (OTHER_VALUE ? OTHER_VALUE.value : null), disabled: bDisable, onChange: this._onOtherChange, onKeyDown: this._onKeyDown}, null);
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
		chart.padding(40, 40, 40, 40);
		
		let categoryAxis = chart.yAxes.push(new am4charts.CategoryAxis());
		categoryAxis.renderer.grid.template.location = 0;
		categoryAxis.renderer.labels.template.fontWeight = 'bold';
		categoryAxis.dataFields.category = 'category';
		
		let valueAxis = chart.xAxes.push(new am4charts.ValueAxis());
		valueAxis.min = 0;
		valueAxis.max = 1;
		chart.numberFormatter.numberFormat = '#%';
		
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
		let OTHER_SUMMARY         : any[]  = new Array();

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
				oSUMMARY.OTHER_SUMMARY = new Array();
				ANSWER_CHOICES_SUMMARY.push(oSUMMARY);
			}
		}
		let sOTHER_ID       : string  = md5('Other');
		let bOTHER_ENABLED  : boolean = false;
		let bOTHER_AS_CHOICE: boolean = false;
		if ( Sql.ToBoolean(this.props.row.OTHER_ENABLED) )
		{
			bOTHER_ENABLED = true;
			if ( Sql.ToBoolean(this.props.row.OTHER_AS_CHOICE) )
			{
				bOTHER_AS_CHOICE = true;
				let oSUMMARY: any = new Object();
				oSUMMARY.ANSWER_TEXT   = 'Other';
				oSUMMARY.ANSWER_ID     = sOTHER_ID;
				oSUMMARY.ANSWERED      = new Array();
				oSUMMARY.SKIPPED       = new Array();
				oSUMMARY.OTHER_SUMMARY = new Array();
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
					// 08/15/2013 Paul.  Other can still be specified even if no answer is selected. 
					if ( bOTHER_ENABLED && !bOTHER_AS_CHOICE && row['OTHER_TEXT'] != null )
					{
						OTHER_SUMMARY.push(row);
					}
					else if ( oSKIPPED[row['SURVEY_RESULT_ID']] === undefined )
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
						let oANSWER_CHOICES_SUMMARY: any = ANSWER_CHOICES_SUMMARY[j];
						if ( oANSWER_CHOICES_SUMMARY.ANSWER_ID == row['ANSWER_ID'] )
						{
							if ( row['ANSWER_TEXT'] != null )
							{
								oANSWER_CHOICES_SUMMARY.ANSWERED.push(row);
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
							if ( bOTHER_AS_CHOICE && sOTHER_ID == row['ANSWER_ID'] )
							{
								oANSWER_CHOICES_SUMMARY.OTHER_SUMMARY.push(row);
							}
						}
						if ( bOTHER_ENABLED && !bOTHER_AS_CHOICE && sOTHER_ID == row['ANSWER_ID'] )
						{
							if ( row['ANSWER_TEXT'] != null )
							{
								OTHER_SUMMARY.push(row);
							}
						}
					}
				}
			}
			let data = new Array();
			for ( let j: number = 0; j < ANSWER_CHOICES_SUMMARY.length; j++ )
			{
				let oANSWER_CHOICES_SUMMARY: any = ANSWER_CHOICES_SUMMARY[j];
				let nPercentage: number = 0;
				if ( nANSWERED > 0 )
					nPercentage = Math.ceil(oANSWER_CHOICES_SUMMARY.ANSWERED.length / nANSWERED);
				
				let item:any = {};
				data.unshift(item);
				item.category = oANSWER_CHOICES_SUMMARY.ANSWER_TEXT;
				item.value    = nPercentage;
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
			sOTHER_ID             ,
			bOTHER_ENABLED        ,
			bOTHER_AS_CHOICE      ,
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
		const { nANSWERED, nSKIPPED, ANSWER_CHOICES_SUMMARY, OTHER_SUMMARY, sOTHER_ID, bOTHER_ENABLED, bOTHER_AS_CHOICE, bSHOW_RESPONSES } = this.state;
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
				<table className='SurveyResultsCheckbox' cellPadding={ 4 } cellSpacing={ 0 } style={ {border: 'none'} }>
					<tr>
						<td className='SurveyResultsAnswerHeader' style={ {width: '65%'} }>
							{ L10n.Term('SurveyResults.LBL_ANSWER_CHOICES') }
						</td>
						<td className='SurveyResultsResponseHeader' style={ {width: '35%'} }>
							{ L10n.Term('SurveyResults.LBL_RESPONSES') }
						</td>
					</tr>
				{
					ANSWER_CHOICES_SUMMARY.map((oANSWER_CHOICES_SUMMARY, index) => 
					{
						let nPercentage: number = 0;
						if ( nANSWERED > 0 )
							nPercentage = Math.ceil(100 * oANSWER_CHOICES_SUMMARY.ANSWERED.length / nANSWERED);
						return(
						<tr>
							<td className='SurveyResultsAnswerBody' style={ {width: '65%'} }>
								<div style={ {float: 'left'} }>
									{ oANSWER_CHOICES_SUMMARY.ANSWER_TEXT }
								</div>
								{ bOTHER_AS_CHOICE && oANSWER_CHOICES_SUMMARY.ANSWER_ID == sOTHER_ID
								? <div style={ {float: 'right'} }>
									<a href='#' onClick={ (e) => { e.preventDefault(); this.toggleOtherResponses(); } }>{ L10n.Term('SurveyResults.LBL_RESPONSES') }</a>
								</div>
								: null
								}
								{ bSHOW_RESPONSES && bOTHER_AS_CHOICE && oANSWER_CHOICES_SUMMARY.ANSWER_ID == sOTHER_ID
								? <div id={ row.ID + '_' + oANSWER_CHOICES_SUMMARY.ANSWER_ID } className='SurveyResultsAllResponses' style={ {clear: 'left'} }>
									<ResultsPaginateResponses ANSWERED={ oANSWER_CHOICES_SUMMARY.OTHER_SUMMARY } DATE_ENTERED_NAME='DATE_ENTERED' ANSWER_TEXT_NAME='ANSWER_TEXT' />
								</div>
								: null
								}
							</td>
							<td className='SurveyResultsResponseBody' style={ {width: '35%'} }>
								<div style={ {float: 'left'} }>
									{ nPercentage.toString() + '%' }
								</div>
								<div style={ {float: 'right'} }>
									{ oANSWER_CHOICES_SUMMARY.ANSWERED.length }
								</div>
							</td>
						</tr>);
					})
				}
				</table>
				{ bOTHER_ENABLED && !bOTHER_AS_CHOICE
				? <div className='SurveyResultsOther'>
					<a href='#' onClick={ (e) => { e.preventDefault(); this.toggleOtherResponses(); } }>{ row.OTHER_LABEL }</a>
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

