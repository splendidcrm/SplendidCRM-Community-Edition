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
import * as XMLParser from 'fast-xml-parser';
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

const NA_ID   : string = md5('N/A');
const OTHER_ID: string = md5('Other');

interface IRatingScaleState
{
	ID                     : string;
	VALUE                  : Record<string, Record<string, { checked: boolean, value: string }>>;
	OTHER_VALUE            : string[];
	ANSWER_CHOICES         : string[];
	COLUMN_CHOICES         : any[];
	columnError            : any;
	otherError             : any;
	error?                 : any;
	rawData?               : any[];
	__sql?                 : string;
	nANSWERED?             : number;
	nSKIPPED?              : number;
	ANSWER_CHOICES_SUMMARY?: any[];
	COLUMN_CHOICES_SUMMARY?: any[];
	OTHER_SUMMARY?         : any[];
	bOTHER_ENABLED?        : boolean;
	bOTHER_ONE_PER_ROW?    : boolean;
	bSHOW_RESPONSES?       : boolean;
}

export default class RatingScale extends SurveyQuestion<ISurveyQuestionProps, IRatingScaleState>
{
	private _isMounted = false;
	private chart;
	private inputs: any[] = [];

	public get data(): any
	{
		const { row } = this.props;
		const { VALUE, OTHER_VALUE, ANSWER_CHOICES, COLUMN_CHOICES, columnError, otherError } = this.state;
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
						let COLUMN_ID = md5(Sql.ToString(COLUMN_CHOICES[j].Label));
						if ( VALUE[ANSWER_ID] && VALUE[ANSWER_ID][COLUMN_ID] && VALUE[ANSWER_ID][COLUMN_ID].checked )
						{
							nColumnsSelected++;
							bValid = true;
							arrValue.push(VALUE[ANSWER_ID][COLUMN_ID].value);
							break;
						}
					}
					if ( Sql.ToBoolean(row.NA_ENABLED) && !Sql.IsEmptyString(row.NA_LABEL) )
					{
						if ( VALUE[ANSWER_ID] && VALUE[ANSWER_ID][NA_ID] && VALUE[ANSWER_ID][NA_ID].checked )
						{
							nColumnsSelected++;
							bValid = true;
							arrValue.push(VALUE[ANSWER_ID][NA_ID].value);
							break;
						}
					}
					if ( Sql.ToBoolean(row.OTHER_ENABLED) && Sql.ToBoolean(row.OTHER_ONE_PER_ROW) )
					{
						let sOtherText: string = Trim(OTHER_VALUE[ANSWER_ID]);
						if ( !Sql.IsEmptyString(sOtherText) )
						{
							arrValue.push(ANSWER_ID + '_' + OTHER_ID + ',' + sOtherText);
						}
					}
				}
			}
			if ( Sql.ToBoolean(row.OTHER_ENABLED) && !Sql.ToBoolean(row.OTHER_ONE_PER_ROW) && !Sql.IsEmptyString(OTHER_VALUE[OTHER_ID]) )
			{
				let sOtherText: string = Trim(OTHER_VALUE[OTHER_ID]);
				if ( !Sql.IsEmptyString(sOtherText) )
				{
					bValid = this.OtherValidation(sOtherText);
					if ( !bValid )
					{
						let error: string = this.OtherValidationMessage();
						otherError[OTHER_ID] = error;
						this.setState({ otherError, error });
					}
					else
					{
						arrValue.push(OTHER_ID + ',' + OTHER_VALUE);
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
		const { VALUE, OTHER_VALUE, ANSWER_CHOICES, COLUMN_CHOICES, columnError, otherError } = this.state;
		let bValid: boolean = false;
		let sValue: string  = '';
		try
		{
			let nSelected   : number = 0;
			let nTotal      : number = 0;
			let nOtherErrors: number = 0;
			if ( ANSWER_CHOICES && COLUMN_CHOICES )
			{
				nTotal = ANSWER_CHOICES.length;
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let nColumnsSelected = 0;
					let ANSWER_ID = md5(ANSWER_CHOICES[i]);
					for ( let j = 0; j < COLUMN_CHOICES.length; j++ )
					{
						let COLUMN_ID = md5(Sql.ToString(COLUMN_CHOICES[j].Label));
						if ( VALUE[ANSWER_ID][COLUMN_ID].checked )
						{
							nColumnsSelected++;
							if ( sValue.length > 0 )
								sValue += '|';
							sValue += VALUE[ANSWER_ID][COLUMN_ID].value;
							break;
						}
					}
					let bNA_ENABLED = Sql.ToBoolean(row.NA_ENABLED) && !Sql.IsEmptyString(row.NA_LABEL);
					if ( bNA_ENABLED )
					{
						if ( VALUE[ANSWER_ID][NA_ID].checked )
						{
							nColumnsSelected++;
							if ( sValue.length > 0 )
								sValue += '|';
							sValue += VALUE[ANSWER_ID][NA_ID].value;
						}
					}
					if ( Sql.ToBoolean(row.OTHER_ENABLED) && Sql.ToBoolean(row.OTHER_ONE_PER_ROW) )
					{
						otherError[ANSWER_ID] = null;
						let sOtherText   = Trim(OTHER_VALUE[ANSWER_ID]);
						if ( !Sql.IsEmptyString(sOtherText) )
						{
							bValid = this.OtherValidation(sOtherText);
							if ( !bValid )
							{
								nOtherErrors++;
								otherError[ANSWER_ID] = this.OtherValidationMessage();
							}
							else
							{
								nColumnsSelected++;
							}
						}
					}
					// 06/09/2013 Paul.  Any column checked will count the row as selected. 
					if ( nColumnsSelected > 0 )
					{
						nSelected++;
						bValid = true;
					}
					columnError[ANSWER_ID] = null;
					// 09/10/2018 Paul.  Must be required in order for required type to apply. 
					if ( Sql.ToString(row.REQUIRED_TYPE) == 'All' && Sql.ToBoolean(row.REQUIRED) )
					{
						columnError[ANSWER_ID] = (nColumnsSelected == 0);
					}
				}
				if ( nOtherErrors > 0 )
				{
					let error: string = this.OtherValidationMessage();
					this.setState({ otherError, error });
					return false;
				}
				this.setState({ otherError, error: null });
			}
			if ( !bValid && Sql.ToBoolean(row.OTHER_ENABLED) && !Sql.ToBoolean(row.OTHER_ONE_PER_ROW) )
			{
				otherError[OTHER_ID] = null;
				let sOtherText = Trim(OTHER_VALUE[OTHER_ID]);
				if ( !Sql.IsEmptyString(sOtherText) )
				{
					bValid = this.OtherValidation(sOtherText);
					if ( !bValid )
					{
						let error: string = this.OtherValidationMessage();
						otherError[OTHER_ID] = error;
						this.setState({ otherError, error });
						return false;
					}
				}
				this.setState({ otherError });
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
		let ID             : string = null;
		let VALUE          : Record<string, Record<string, { checked: boolean, value: string }>> = {};
		let OTHER_VALUE    : string[] = [];
		let ANSWER_CHOICES : string[] = null;
		let COLUMN_CHOICES : any[] = null;
		let sCOLUMN_CHOICES: string = null;
		let columnError    : any = {};
		let otherError     : any = {};
		// 07/11/2021 Paul.  ID will be null in sample mode. 
		if ( row )
		{
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
			ANSWER_CHOICES  = this.RandomizeAnswers();
			sCOLUMN_CHOICES = Sql.ToString(row.COLUMN_CHOICES);
			if ( Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				this.inputs.push(React.createRef<HTMLInputElement>());
			}
		}
		if ( displayMode == 'Sample' )
		{
			ANSWER_CHOICES = 'Soda\r\nCandy\r\nIce Cream'.split('\r\n');
			sCOLUMN_CHOICES = '<?xml version="1.0" encoding="UTF-8"?><Ratings><Rating><Label>1 star</Label><Weight>1</Weight></Rating><Rating><Label>2 star</Label><Weight>2</Weight></Rating><Rating><Label>3 star</Label><Weight>3</Weight></Rating><Rating><Label>4 star</Label><Weight>4</Weight></Rating><Rating><Label>5 star</Label><Weight>5</Weight></Rating></Ratings>';
		}
		if ( !Sql.IsEmptyString(sCOLUMN_CHOICES) )
		{
			// https://www.npmjs.com/package/fast-xml-parser
			let options: any = 
			{
				attributeNamePrefix: '',
				textNodeName       : 'Label',
				ignoreAttributes   : false,
				ignoreNameSpace    : true,
				parseAttributeValue: true,
				trimValues         : false,
			};
			// 07/11/2021 Paul.  should be parsing sCOLUMN_CHOICES and not props.row.COLUMN_CHOICES. 
			COLUMN_CHOICES = XMLParser.parse(sCOLUMN_CHOICES, options).Ratings.Rating;
		}
		if ( ANSWER_CHOICES && COLUMN_CHOICES )
		{
			for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
			{
				let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
				VALUE[ANSWER_ID] = {};
				for ( let j = 0; j < COLUMN_CHOICES.length; j++ )
				{
					this.inputs.push(React.createRef<HTMLInputElement>());
					let COLUMN_ID: string = md5(Sql.ToString(COLUMN_CHOICES[j].Label));
					VALUE[ANSWER_ID][COLUMN_ID] =
					{
						checked: false,
						value: ANSWER_ID + '_' + COLUMN_ID + ',' + ANSWER_CHOICES[i] + ',' + COLUMN_CHOICES[j].Label + ',' + COLUMN_CHOICES[j].Weight
					};
					if ( Sql.ToBoolean(row.NA_ENABLED) && !Sql.IsEmptyString(row.NA_LABEL) )
					{
						VALUE[ANSWER_ID][NA_ID] =
						{
							checked: false,
							value: ANSWER_ID + '_' + NA_ID + ',' + ANSWER_CHOICES[i] + ',N/A'
						};
						if ( props.row.OTHER_ONE_PER_ROW )
						{
							OTHER_VALUE[ANSWER_ID] = '';
							this.inputs.push(React.createRef<HTMLInputElement>());
						}
					}
					if ( rowQUESTION_RESULTS )
					{
						for ( let m = 0; m < rowQUESTION_RESULTS.length; m++ )
						{
							if ( ANSWER_ID == rowQUESTION_RESULTS[j].ANSWER_ID )
							{
								if ( COLUMN_ID == rowQUESTION_RESULTS[j].COLUMN_ID )
								{
									VALUE[ANSWER_ID][COLUMN_ID].checked = true;
									break;
								}
								else if (OTHER_ID == rowQUESTION_RESULTS[j].COLUMN_ID)
								{
									OTHER_VALUE[ANSWER_ID] = rowQUESTION_RESULTS[j].ANSWER_TEXT;
									break;
								}
								else if (NA_ID == rowQUESTION_RESULTS[j].COLUMN_ID)
								{
									VALUE[ANSWER_ID][NA_ID].checked = true;
									break;
								}
							}
						}
					}
				}
			}
			if ( Sql.ToBoolean(row.OTHER_ENABLED) && !Sql.ToBoolean(row.OTHER_ONE_PER_ROW) )
			{
				OTHER_VALUE[OTHER_ID] = '';
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
			otherError    ,
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

	private _onOtherChange = (OTHER_ID, e): void =>
	{
		const { row } = this.props;
		let { OTHER_VALUE } = this.state;
		let text: string = e.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			OTHER_VALUE[OTHER_ID] = text;
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
		/*
		if ( event.key == 'Enter' )
		{
			if ( onFocusNextQuestion )
			{
				onFocusNextQuestion(ID);
			}
		}
		*/
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
		const { ID, VALUE, OTHER_VALUE, ANSWER_CHOICES, COLUMN_CHOICES, columnError, otherError, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.RenderQuestion', row, COLUMN_CHOICES);
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
			
			let bNA_ENABLED : boolean = Sql.ToBoolean(row.NA_ENABLED) && !Sql.IsEmptyString(row.NA_LABEL);
			let nLABEL_WIDTH: number = Sql.ToInteger(row.COLUMN_WIDTH);
			let nFIELD_WIDTH: number = 100 - nLABEL_WIDTH;
			let nColumns    : number = (COLUMN_CHOICES ? COLUMN_CHOICES.length : 1);
			if ( bNA_ENABLED )
				nColumns++;
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
					let div = React.createElement('div', {className: 'SurveyColumnChoice'}, COLUMN_CHOICES[j].Label);
					tdChildren.push(div);
				}
			}
			if ( bNA_ENABLED )
			{
				tdChildren    = [];
				td            = React.createElement('td', {verticalAlign: 'top', align: 'center', style: {width: nCellWidth.toString() + '%'}}, tdChildren);
				trChildren.push(td);
				let div = React.createElement('div', {className: 'SurveyColumnChoice'}, row.NA_LABEL);
				tdChildren.push(div);
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
							let COLUMN_ID: string = md5(Sql.ToString(COLUMN_CHOICES[j].Label));
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
								value    : ANSWER_ID + '_' + COLUMN_ID + ',' + ANSWER_CHOICES[i] + ',' + COLUMN_CHOICES[j].Label,
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
					if ( bNA_ENABLED )
					{
						tdChildren    = [];
						td            = React.createElement('td', {verticalAlign: 'top', align: 'center', style: {width: nCellWidth.toString() + '%'}}, tdChildren);
						trChildren.push(td);
					
						let divChildren = [];
						let div = React.createElement('div', {className: 'SurveyColumnChoice'}, divChildren);
						tdChildren.push(div);
					
						let chkProps    = 
						{
							id       : ID + '_' + ANSWER_ID + '_' + NA_ID,
							key      : ID + '_' + ANSWER_ID + '_' + NA_ID,
							type     : 'radio',
							className: 'SurveyAnswerChoiceRadio',
							value    : ANSWER_ID + '_' + NA_ID + ',' + ANSWER_CHOICES[i] + ',' + 'N/A',
							style    : cssStyle,
							disabled : Sql.ToBoolean(bDisable),
							checked  : VALUE[ANSWER_ID][NA_ID].checked,
							onChange : (e) => { this._onChange(ANSWER_ID, NA_ID); },
							ref      : this.inputs[i],
						};
						let chk         = React.createElement('input', chkProps, null);
						tdChildren.push(chk);
					}
					if ( Sql.ToBoolean(row.OTHER_ONE_PER_ROW) )
					{
						let nColSpan: number = (COLUMN_CHOICES.length + 1);
						if ( bNA_ENABLED )
							nColSpan++;
						trChildren    = [];
						tr            = React.createElement('tr', {className: (i % 2 == 0 ? 'SurveyColumnOddRow' : 'SurveyColumnEvenRow')}, trChildren);
						tbodyChildren.push(tr);
					
						tdChildren    = [];
						td            = React.createElement('td', {verticalAlign: 'top', style: {width: nCellWidth.toString() + '%'}, colspan: nColSpan}, tdChildren);
						trChildren.push(td);
					
						let divOtherChildren = [];
						let divOther         = React.createElement('div', {className: 'SurveyAnswerChoice'}, divOtherChildren);
						tdChildren.push(divOther);
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
							let txtProps = 
							{
								id       : ID + '_' + ANSWER_ID + '_OtherText', 
								rows     : row.OTHER_HEIGHT, 
								cols     : cols, style: cssText, 
								value    : OTHER_VALUE[ANSWER_ID], 
								disabled : bDisable, 
								onChange : (e) => { this._onOtherChange(ANSWER_ID, e); }, 
								onKeyDown: this._onKeyDown
							};
							let txt         = React.createElement('textarea', txtProps, null);
							divOtherChildren.push(txt);
						}
						else
						{
							let lab         = React.createElement('label', {className: 'SurveyAnswerChoice SurveyAnswerOther', htmlFor: ID + '_' + ANSWER_ID + '_OtherText', style: {marginRight: '10px'}, dangerouslySetInnerHTML: {__html: Sql.ToString(row.OTHER_LABEL)}});
							divOtherChildren.push(lab);
					
							let cssText: any = {};
							let size   : number = null;
							// 12/31/2015 Paul.  Ignore margins on mobile device as they make the layout terrible. 
							if ( isMobileDevice() )
								cssText.width = '100%';
							else if ( Sql.ToInteger(row.OTHER_WIDTH) > 0 )
								size = row.OTHER_WIDTH;
							let txtProps = 
							{
								id       : ID + '_' + ANSWER_ID + '_OtherText', 
								rows     : row.OTHER_HEIGHT, 
								size     : size, 
								style    : cssText, 
								value    : OTHER_VALUE[ANSWER_ID], 
								disabled : bDisable, 
								onChange : (e) => { this._onOtherChange(ANSWER_ID, e); }, 
								onKeyDown: this._onKeyDown
							};
							let txt         = React.createElement('input', txtProps, null);
							divOtherChildren.push(txt);
						}
						if ( otherError[ANSWER_ID] )
						{
							let spnOtherError = React.createElement('span', {id: ID + '_' + ANSWER_ID + '_OtherText', className: 'SurveyQuestionError', style: {marginLeft: '10px', marginRight: '10px', backgroundColor: 'inhert'}}, otherError[ANSWER_ID]);
							divOtherChildren.push(spnOtherError);
						}
					}
				}
			}
			if ( Sql.ToBoolean(row.OTHER_ENABLED) && !Sql.ToBoolean(row.OTHER_ONE_PER_ROW) )
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
					let txtProps = 
					{
						id       : ID + '_OtherText', 
						rows     : row.OTHER_HEIGHT, 
						cols     : cols, style: cssText, 
						value    : OTHER_VALUE[OTHER_ID], 
						disabled : bDisable, 
						onChange : (e) => { this._onOtherChange(OTHER_ID, e); }, 
						onKeyDown: this._onKeyDown
					};
					let txt         = React.createElement('textarea', txtProps, null);
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
					let txtProps = 
					{
						id       : ID + '_OtherText', 
						rows     : row.OTHER_HEIGHT, 
						size     : size, 
						style    : cssText, 
						value    : OTHER_VALUE[OTHER_ID], 
						disabled : bDisable, 
						onChange : (e) => { this._onOtherChange(OTHER_ID, e); }, 
						onKeyDown: this._onKeyDown
					};
					let txt         = React.createElement('input', txtProps, null);
					divOtherChildren.push(txt);
				}
				if ( otherError[OTHER_ID] )
				{
					let spnOtherError = React.createElement('span', {id: ID + '_OtherText', className: 'SurveyQuestionError', style: {marginLeft: '10px', marginRight: '10px', backgroundColor: 'inhert'}}, otherError[OTHER_ID]);
					divOtherChildren.push(spnOtherError);
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
		chart.numberFormatter.numberFormat = '#.##';
		
		let series:am4charts.ColumnSeries = chart.series.push(new am4charts.ColumnSeries());
		series.dataFields.categoryY  = 'category';
		series.dataFields.valueX     = 'value';
		series.tooltipText           = '{name}: [bold]{valueX}[/]';
		
		chart.data = [];
		this.chart = chart;
		return chart;
	}

	private LoadData = async () =>
	{
		let sTABLE_NAME     : string = 'SURVEY_QUESTIONS_RESULTS';
		let sSORT_FIELD     : string = 'DATE_ENTERED';
		let sSORT_DIRECTION : string = 'desc';
		var sSELECT         : string = 'SURVEY_RESULT_ID, DATE_ENTERED, ANSWER_ID, ANSWER_TEXT, COLUMN_ID, COLUMN_TEXT, WEIGHT, OTHER_TEXT';
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
		let bOTHER_ENABLED        : boolean  = false;
		let bOTHER_ONE_PER_ROW    : boolean  = Sql.ToBoolean(this.props.row.OTHER_ONE_PER_ROW);
		let arrANSWER_CHOICES     : string[] = [];
		let arrCOLUMN_CHOICES     : any[]    = [];
		let bNA_ENABLED           : boolean  = Sql.ToBoolean(this.props.row.NA_ENABLED) && !Sql.IsEmptyString(this.props.row.NA_LABEL);
		let sNA_ID                : string   = md5('N/A');
		let sOTHER_ID             : string   = md5('Other');

		if ( !Sql.IsEmptyString(this.props.row.ANSWER_CHOICES) && !Sql.IsEmptyString(this.props.row.COLUMN_CHOICES) )
		{
			arrANSWER_CHOICES = Sql.ToString(this.props.row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			// <Ratings><Rating><Label></Label><Weight></Weight></Rating></Ratings>
			// https://www.npmjs.com/package/fast-xml-parser
			let options: any = 
			{
				attributeNamePrefix: '',
				textNodeName       : 'Label',
				ignoreAttributes   : false,
				ignoreNameSpace    : true,
				parseAttributeValue: true,
				trimValues         : false,
			};
			// 07/11/2021 Paul.  should be parsing sCOLUMN_CHOICES and not props.row.COLUMN_CHOICES. 
			arrCOLUMN_CHOICES = XMLParser.parse(this.props.row.COLUMN_CHOICES, options).Ratings.Rating;
			for ( let i: number = 0; i < arrANSWER_CHOICES.length; i++ )
			{
				let oSUMMARY: any = new Object();
				oSUMMARY.ANSWER_TEXT    = arrANSWER_CHOICES[i];
				oSUMMARY.ANSWER_ID      = md5(arrANSWER_CHOICES[i]);
				oSUMMARY.COLUMNS        = new Array();
				oSUMMARY.SKIPPED        = new Array();
				oSUMMARY.OTHER_SUMMARY  = new Array();
				oSUMMARY.ANSWER_TOTAL   = 0;
				oSUMMARY.WEIGHT_TOTAL   = 0.0;
				oSUMMARY.SHOW_RESPONSES = false;
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
				if ( bOTHER_ONE_PER_ROW )
				{
					let oCOLUMN: any = new Object();
					oCOLUMN.COLUMN_TEXT = 'Other';
					oCOLUMN.COLUMN_ID   = sOTHER_ID;
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
											if ( oANSWERED[row['SURVEY_RESULT_ID']] === undefined )
											{
												oANSWERED[row['SURVEY_RESULT_ID']] = true;
												nANSWERED++;
											}
											if ( bOTHER_ONE_PER_ROW && sOTHER_ID == row['COLUMN_ID'] )
											{
												oANSWER_CHOICES_SUMMARY.OTHER_SUMMARY.push(row);
											}
											else
											{
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
				}
			}
			let data = new Array();
			for ( let j: number = 0; j < ANSWER_CHOICES_SUMMARY.length; j++ )
			{
				let oANSWER_CHOICES_SUMMARY: any = ANSWER_CHOICES_SUMMARY[j];
				let item:any = {};
				data.unshift(item);
				item.category = oANSWER_CHOICES_SUMMARY.ANSWER_TEXT;
				let fAverage: number = 0;
				if ( oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL > 0 )
					fAverage = oANSWER_CHOICES_SUMMARY.WEIGHT_TOTAL / oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL;
				item.value = fAverage;
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
			COLUMN_CHOICES_SUMMARY: arrCOLUMN_CHOICES,
			OTHER_SUMMARY         ,
			bOTHER_ENABLED        ,
			bOTHER_ONE_PER_ROW    ,
		});
	}

	private toggleOtherRowResponses = (oANSWER_CHOICES_SUMMARY) =>
	{
		let { ANSWER_CHOICES_SUMMARY } = this.state;
		oANSWER_CHOICES_SUMMARY.SHOW_RESPONSES = !oANSWER_CHOICES_SUMMARY.SHOW_RESPONSES;
		this.setState({ ANSWER_CHOICES_SUMMARY });
	}

	private toggleOtherResponses = () =>
	{
		this.setState({ bSHOW_RESPONSES: !this.state.bSHOW_RESPONSES });
	}

	public Summary = () =>
	{
		const { row } = this.props;
		const { ID, error, __sql } = this.state;
		const { nANSWERED, nSKIPPED, ANSWER_CHOICES_SUMMARY, COLUMN_CHOICES_SUMMARY, OTHER_SUMMARY, bOTHER_ENABLED, bOTHER_ONE_PER_ROW, bSHOW_RESPONSES } = this.state;
		let arrCOLUMN_CHOICES: string[] = (COLUMN_CHOICES_SUMMARY ? COLUMN_CHOICES_SUMMARY : []);
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
						arrCOLUMN_CHOICES.map((COLUMN: any, index) => 
						{
							return(<td className='SurveyResultsResponseMatrixHeader' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
								{ COLUMN.Label }
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
						return(<React.Fragment>
							<tr>
								<td className='SurveyResultsAnswerMatrixBody' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
									<div>
										{ oANSWER_CHOICES_SUMMARY.ANSWER_TEXT }
									</div>
									{ bOTHER_ONE_PER_ROW
									? <React.Fragment>
										<div>
											<a href='#' onClick={ (e) => { e.preventDefault(); this.toggleOtherRowResponses(oANSWER_CHOICES_SUMMARY); } }>{ row.OTHER_LABEL }</a>
										</div>
									</React.Fragment>
									: null
									}
								</td>
								{
									oANSWER_CHOICES_SUMMARY.COLUMNS.map((oCOLUMN, index) => 
									{
										if ( !(bOTHER_ONE_PER_ROW && oCOLUMN.COLUMN_ID == OTHER_ID) )
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
										}
										else
										{
											return null;
										}
									})
								}
								<td className='SurveyResultsResponseMatrixTotal' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
									{ oANSWER_CHOICES_SUMMARY.ANSWER_TOTAL }
								</td>
								<td className='SurveyResultsResponseMatrixTotal' style={ {width: nCOLUMN_WIDTH.toString() + '%'} }>
									{ sAverage }
								</td>
							</tr>
							{
								oANSWER_CHOICES_SUMMARY.COLUMNS.map((oCOLUMN, index) => 
								{
									if ( bOTHER_ONE_PER_ROW && oCOLUMN.COLUMN_ID == OTHER_ID && oANSWER_CHOICES_SUMMARY.SHOW_RESPONSES)
									{
										return(<tr className='SurveyResultsAnswerMatrixOtherRow'>
											<td colSpan={ nCOLUMNS + 3 }>
												{ oANSWER_CHOICES_SUMMARY.SHOW_RESPONSES
												? <div id={ row.ID + '_' + oANSWER_CHOICES_SUMMARY.ANSWER_ID } className='SurveyResultsAllResponses' style={ {clear: 'left'} }>
													<ResultsPaginateResponses ANSWERED={ oANSWER_CHOICES_SUMMARY.OTHER_SUMMARY } DATE_ENTERED_NAME='DATE_ENTERED' ANSWER_TEXT_NAME='OTHER_TEXT' />
												</div>
												: null
												}
											</td>
										</tr>);
									}
									else
									{
										return null;
									}
								})
							}
						</React.Fragment>);
					})
				}
				</table>
				{ bOTHER_ENABLED && !bOTHER_ONE_PER_ROW
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

