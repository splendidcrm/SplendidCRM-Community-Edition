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
import { XMLParser, XMLBuilder }                from 'fast-xml-parser'              ;
import { Appear }                               from 'react-lifecycle-appear'       ;
// 2. Store and Types. 
import ISurveyQuestionProps                     from '../types/ISurveyQuestionProps';
import SurveyQuestion                           from './SurveyQuestion'             ;
// 3. Scripts. 
import Sql                                      from '../scripts/Sql'               ;
import L10n                                     from '../scripts/L10n'              ;
import { md5 }                                  from '../scripts/md5'               ;
import { Trim, isMobileDevice }                 from '../scripts/utility'           ;
import { Crm_Config }                           from '../scripts/Crm'               ;
import { ListView_LoadTable }                   from '../scripts/ListView'          ;
// 4. Components and Views. 
import ErrorComponent                           from '../components/ErrorComponent' ;
import ResultsPaginateResponses                 from './ResultsPaginateResponses'   ;

const OTHER_ID: string = md5('Other');

interface IDropdownMatrixState
{
	ID                     : string;
	VALUE                  : Record<string, Record<string, number>>;
	OTHER_VALUE            : string;
	ANSWER_CHOICES         : string[];
	COLUMN_CHOICES         : any[];
	columnError            : any;
	error?                 : any;
	rawData?               : any[];
	__sql?                 : string;
	nANSWERED?             : number;
	nSKIPPED?              : number;
	ANSWER_CHOICES_SUMMARY?: any[];
	COLUMN_CHOICES_SUMMARY?: any[];
	OTHER_SUMMARY?         : any[];
	bOTHER_ENABLED?        : boolean;
	bSHOW_RESPONSES?       : boolean;
	nMENU_MAX?             : number;
}

export default class DropdownMatrix extends SurveyQuestion<ISurveyQuestionProps, IDropdownMatrixState>
{
	private _isMounted = false;
	private inputs: any[] = [];

	public get data(): any
	{
		const { row } = this.props;
		const { VALUE, OTHER_VALUE, ANSWER_CHOICES, COLUMN_CHOICES, columnError } = this.state;
		let bValid  : boolean  = false;
		let arrValue: string[] = [];
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
						let COLUMN_ID: string = md5(COLUMN_CHOICES[j].Heading);
						if ( VALUE[ANSWER_ID] && VALUE[ANSWER_ID][COLUMN_ID] > 0 )
						{
							nColumnsSelected++;
							let k           : number = VALUE[ANSWER_ID][COLUMN_ID];
							let sOptions    : string = Sql.ToString(COLUMN_CHOICES[j].Options);
							// 07/25/2021 Paul.  Just \n, not \r\n to match old system. 
							let arrOptions  : string[] = sOptions.split(/\r\n|[\n\r]/g);
							let MENU_ITEM_ID: string = md5(Sql.ToString(arrOptions[k]));
							let sValue      : string = ANSWER_ID + '_' + COLUMN_ID + '_' + MENU_ITEM_ID + ',' + ANSWER_CHOICES[i] + ',' + COLUMN_CHOICES[j].Heading + ',' + arrOptions[k]
							arrValue.push(sValue);
						}
					}
					// 06/09/2013 Paul.  Don't treat the row as selected unless all columns for the row are selected. 
					if ( nColumnsSelected == COLUMN_CHOICES.length )
					{
						nSelected++;
						bValid = true;
					}
				}
			}
			if ( !bValid && Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				let sOtherText: string = Trim(OTHER_VALUE);
				if ( !Sql.IsEmptyString(sOtherText) )
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
			let nSelected   : number = 0;
			let nTotal      : number = 0;
			if ( ANSWER_CHOICES && COLUMN_CHOICES )
			{
				nTotal = ANSWER_CHOICES.length;
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let nColumnsSelected = 0;
					let ANSWER_ID = md5(ANSWER_CHOICES[i]);
					for ( let j = 0; j < COLUMN_CHOICES.length; j++ )
					{
						let COLUMN_ID = md5(Sql.ToString(COLUMN_CHOICES[j].Heading));
						if ( VALUE[ANSWER_ID] && VALUE[ANSWER_ID][COLUMN_ID] > 0 )
						{
							nColumnsSelected++;
							if ( sValue.length > 0 )
								sValue += '|';
							sValue += VALUE[ANSWER_ID][COLUMN_ID];
							break;
						}
					}
					// 06/09/2013 Paul.  Don't treat the row as selected unless all columns for the row are selected. 
					if ( nColumnsSelected == COLUMN_CHOICES.length )
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
				this.setState({ error: null });
			}
			if ( !bValid && Sql.ToBoolean(row.OTHER_ENABLED) )
			{
				let error: string = null;
				let sOtherText = Trim(OTHER_VALUE);
				if ( !Sql.IsEmptyString(sOtherText) )
				{
					bValid = this.OtherValidation(sOtherText);
					if ( !bValid )
					{
						error = this.OtherValidationMessage();
						this.setState({ error });
						return false;
					}
				}
				this.setState({ error });
			}
			if ( Sql.ToBoolean(row.REQUIRED) )
			{
				let error: string = null;
				// 06/09/2013 Paul.  If type is blank, then use existing bValid value. 
				if ( !Sql.IsEmptyString(row.REQUIRED_TYPE) )
				{
					bValid = this.RequiredTypeValidation(nSelected, nTotal);
					if ( !bValid )
					{
						error = this.RequiredTypeMessage(nTotal);
					}
				}
				else if ( !bValid )
				{
					error = row.REQUIRED_MESSAGE;
				}
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
		let ID             : string = null;
		let VALUE          : Record<string, Record<string, number>> = {};
		let OTHER_VALUE    : string = null;
		let ANSWER_CHOICES : string[] = null;
		let COLUMN_CHOICES : any[] = null;
		let sCOLUMN_CHOICES: string = null;
		let columnError    : any = {};
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
			ANSWER_CHOICES = 'Shirts\r\nPants\r\nTies'.split('\r\n');
			sCOLUMN_CHOICES = '<?xml version="1.0" encoding="UTF-8"?><Menus><Menu><Heading>Size</Heading><Options>Small\r\nMedium\r\nLarge</Options></Menu><Menu><Heading>Color</Heading><Options>Red\r\nGreen\r\nBlue</Options></Menu></Menus>';
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', sCOLUMN_CHOICES);
		if ( !Sql.IsEmptyString(sCOLUMN_CHOICES) )
		{
			// https://www.npmjs.com/package/fast-xml-parser
			let options: any = 
			{
				attributeNamePrefix: '',
				// 02/16/2024 Paul.  parser v4 creates object for Value. 
				// 02/16/2024 Paul.  Heading and Options at same level causes confusion. 
				//textNodeName       : 'Value',
				// <Menus>
				// 	<Menu>
				// 		<Heading>Size</Heading>
				// 		<Options>Small  Medium  Large</Options>
				// 	</Menu>
				// 	<Menu>
				// 		<Heading>Color</Heading>
				// 		<Options>Red  Green  Blue</Options>
				// 	</Menu>
				// </Menus>
				ignoreAttributes   : false,
				ignoreNameSpace    : true,
				parseAttributeValue: true,
				trimValues         : false,
			};
			// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
			const parser = new XMLParser(options);
			// 07/11/2021 Paul.  should be parsing sCOLUMN_CHOICES and not props.row.COLUMN_CHOICES. 
			let xml: any = parser.parse(sCOLUMN_CHOICES);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', xml);
			if ( xml.Menus && xml.Menus.Menu )
			{
				if ( Array.isArray(xml.Menus.Menu) )
					COLUMN_CHOICES = xml.Menus.Menu;
				else if ( xml.Menus.Menu != null )
				{
					COLUMN_CHOICES = [];
					COLUMN_CHOICES.push(xml.Menus.Menu);
				}
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', COLUMN_CHOICES);
		if ( ANSWER_CHOICES && COLUMN_CHOICES )
		{
			for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
			{
				let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
				VALUE[ANSWER_ID] = {};
				for ( let j = 0; j < COLUMN_CHOICES.length; j++ )
				{
					this.inputs.push(React.createRef<HTMLInputElement>());
					let COLUMN_ID: string = md5(Sql.ToString(COLUMN_CHOICES[j].Heading));
					VALUE[ANSWER_ID][COLUMN_ID] = -1;
					
					// 07/25/2021 Paul.  Just \n, not \r\n to match old system. 
					let arrOptions = Sql.ToString(COLUMN_CHOICES[j].Options).split(/\r\n|[\n\r]/g);
					for ( let k = 0; k < arrOptions.length; k++ )
					{
						let MENU_ITEM_ID: string = md5(Sql.ToString(arrOptions[k]));
						if ( rowQUESTION_RESULTS )
						{
							for ( let m = 0; m < rowQUESTION_RESULTS.length; m++ )
							{
								if ( ANSWER_ID == rowQUESTION_RESULTS[m].ANSWER_ID && COLUMN_ID == rowQUESTION_RESULTS[m].COLUMN_ID )
								{
									// 06/16/2013 Paul.  Add 1 because of the first option is blank. 
									VALUE[ANSWER_ID][COLUMN_ID] = k + 1;
								}
							}
						}
					}
				}
			}
			if ( Sql.ToBoolean(row.OTHER_ENABLED) && !Sql.ToBoolean(row.OTHER_ONE_PER_ROW) )
			{
				OTHER_VALUE = '';
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
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	private _onChange = (ANSWER_ID: string, COLUMN_ID: string, event): void =>
	{
		const { row } = this.props;
		let { VALUE, ANSWER_CHOICES } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ', event);
		try
		{
			if ( VALUE[ANSWER_ID] )
			{
				let k: number = event.target.selectedIndex;
				VALUE[ANSWER_ID][COLUMN_ID] = k;
				this.setState({ VALUE });
			}
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onOtherChange ' + DATA_FIELD, value);
		try
		{
			OTHER_VALUE = text;
			this.setState({ OTHER_VALUE });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onOtherChange', error);
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
		const { ID, VALUE, OTHER_VALUE, ANSWER_CHOICES, COLUMN_CHOICES, columnError, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.RenderQuestion', COLUMN_CHOICES);
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
					let div = React.createElement('div', {className: 'SurveyColumnChoice'}, COLUMN_CHOICES[j].Heading);
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
							let COLUMN_ID: string = md5(Sql.ToString(COLUMN_CHOICES[j].Heading));
							tdChildren    = [];
							td            = React.createElement('td', {verticalAlign: 'top', align: 'center', style: {width: nCellWidth.toString() + '%'}}, tdChildren);
							trChildren.push(td);
					
							divChildren = [];
							div = React.createElement('div', {className: 'SurveyColumnChoice'}, divChildren);
							tdChildren.push(div);
					
							let arrSelectOptions = [];
							let sOptions   = Sql.ToString(COLUMN_CHOICES[j].Options);
							// 07/25/2021 Paul.  Just \n, not \r\n to match old system. 
							let arrOptions = sOptions.split(/\r\n|[\n\r]/g);
							arrSelectOptions.push(<option value=''></option>);
							for ( let k = 0; k < arrOptions.length; k++ )
							{
								let MENU_ITEM_ID: string = md5(Sql.ToString(arrOptions[k]));
								arrSelectOptions.push(<option value={ k.toString() } >{ arrOptions[k] }</option>);
							}
							let chkProps    = 
							{
								id           : ID + '_' + ANSWER_ID + '_' + COLUMN_ID,
								key          : ID + '_' + ANSWER_ID + '_' + COLUMN_ID,
								className    : 'SurveyColumnChoiceDropdown',
								disabled     : Sql.ToBoolean(bDisable),
								selectedIndex: VALUE[ANSWER_ID][COLUMN_ID],
								onChange     : (event) => { this._onChange(ANSWER_ID, COLUMN_ID, event); },
								ref          : this.inputs[i],
							};
							let chk         = React.createElement('select', chkProps, arrSelectOptions);
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
					let txtProps = 
					{
						id       : ID + '_OtherText', 
						rows     : row.OTHER_HEIGHT, 
						cols     : cols, style: cssText, 
						value    : OTHER_VALUE, 
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
						value    : OTHER_VALUE, 
						disabled : bDisable, 
						onChange : (e) => { this._onOtherChange(OTHER_ID, e); }, 
						onKeyDown: this._onKeyDown
					};
					let txt         = React.createElement('input', txtProps, null);
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

	private LoadData = async () =>
	{
		let sTABLE_NAME     : string = 'SURVEY_QUESTIONS_RESULTS';
		let sSORT_FIELD     : string = 'DATE_ENTERED';
		let sSORT_DIRECTION : string = 'desc';
		var sSELECT         : string = 'SURVEY_RESULT_ID, DATE_ENTERED, ANSWER_ID, ANSWER_TEXT, COLUMN_ID, COLUMN_TEXT, MENU_ID, MENU_TEXT, OTHER_TEXT';
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
		let arrCOLUMN_CHOICES     : any[]    = [];
		let nMENU_MAX             : number  = 0;

		if ( !Sql.IsEmptyString(this.props.row.ANSWER_CHOICES) && !Sql.IsEmptyString(this.props.row.COLUMN_CHOICES) )
		{
			arrANSWER_CHOICES = Sql.ToString(this.props.row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
			// <Menus><Menu><Heading></Heading><Options></Options></Menu></Menus>
			// https://www.npmjs.com/package/fast-xml-parser
			let options: any = 
			{
				attributeNamePrefix: '',
				// 02/16/2024 Paul.  parser v4 creates object for Value. 
				// 02/16/2024 Paul.  Heading and Options at same level causes confusion. 
				//textNodeName       : 'Value',
				// <Menus>
				// 	<Menu>
				// 		<Heading>Size</Heading>
				// 		<Options>Small  Medium  Large</Options>
				// 	</Menu>
				// 	<Menu>
				// 		<Heading>Color</Heading>
				// 		<Options>Red  Green  Blue</Options>
				// 	</Menu>
				// </Menus>
				ignoreAttributes   : false,
				ignoreNameSpace    : true,
				parseAttributeValue: true,
				trimValues         : false,
			};
			// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
			const parser = new XMLParser(options);
			let xml: any = parser.parse(this.props.row.COLUMN_CHOICES);
			if ( xml.Menus && xml.Menus.Menu )
			{
				if ( Array.isArray(xml.Menus.Menu) )
					arrCOLUMN_CHOICES = xml.Menus.Menu;
				else if ( xml.Menus.Menu != null )
				{
					arrCOLUMN_CHOICES = [];
					arrCOLUMN_CHOICES.push(xml.Menus.Menu);
				}
			}
			for ( let j: number = 0; j < arrCOLUMN_CHOICES.length; j++ )
			{
				// 07/25/2021 Paul.  Just \n, not \r\n to match old system. 
				arrCOLUMN_CHOICES[j].OPTIONS = Sql.ToString(arrCOLUMN_CHOICES[j]).Options.split(/\r\n|[\n\r]/g);
			}
			
			for ( let i: number = 0; i < arrANSWER_CHOICES.length; i++ )
			{
				let oSUMMARY: any = new Object();
				oSUMMARY.ANSWER_TEXT    = arrANSWER_CHOICES[i];
				oSUMMARY.ANSWER_ID      = md5(arrANSWER_CHOICES[i]);
				oSUMMARY.COLUMNS        = new Array();
				oSUMMARY.ANSWER_TOTAL   = 0;
				ANSWER_CHOICES_SUMMARY.push(oSUMMARY);
				for ( let j: number = 0; j < arrCOLUMN_CHOICES.length; j++ )
				{
					let oCOLUMN: any = new Object();
					oCOLUMN.COLUMN_TEXT = arrCOLUMN_CHOICES[j].Heading;
					oCOLUMN.COLUMN_ID   = md5(arrCOLUMN_CHOICES[j].Heading);
					oCOLUMN.OPTIONS     = arrCOLUMN_CHOICES[j].OPTIONS;
					oCOLUMN.MENUS       = new Array();
					oSUMMARY.COLUMNS.push(oCOLUMN);
					for ( let k: number = 0; k < oCOLUMN.OPTIONS.length; k++ )
					{
						let oMENU: any = new Object();
						oMENU.MENU_TEXT    = arrCOLUMN_CHOICES[j].OPTIONS[k];
						oMENU.MENU_ID      = md5(oMENU.MENU_TEXT);
						oMENU.ANSWERED     = new Array();
						oMENU.SKIPPED      = new Array();
						oMENU.ANSWER_TOTAL = 0;
						oCOLUMN.MENUS.push(oMENU);
					}
					nMENU_MAX = Math.max(nMENU_MAX, oCOLUMN.OPTIONS.length);
				}
			}
		}
		var sOTHER_ID = md5('Other');
		var bOTHER_ENABLED   = false;
		if ( Sql.ToBoolean(this.props.row.OTHER_ENABLED) )
		{
			bOTHER_ENABLED = true;
		}
		
		if ( rawData != null )
		{
			for ( let i: number = rawData.length - 1; i >= 0; i-- )
			{
				let row: any = rawData[i];
				if ( row['ANSWER_ID'] == null || row['COLUMN_ID'] == null || row['MENU_ID'] == null )
				{
					// 07/25/2021 Paul.  oCOLUMN is not defined yet, so must be wrong. 
					//oCOLUMN.SKIPPED.push(row);
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
					row['MENU_ID'  ] = Sql.ToString(row['MENU_ID'  ]).replace(/-/g, '');
					for ( let j: number = 0; j < ANSWER_CHOICES_SUMMARY.length; j++ )
					{
						let oSUMMARY: any = ANSWER_CHOICES_SUMMARY[j];
						if ( oSUMMARY.ANSWER_ID == row['ANSWER_ID'] )
						{
							if ( row['ANSWER_TEXT'] != null )
							{
								for ( let k: number = 0; k < oSUMMARY.COLUMNS.length; k++ )
								{
									let oCOLUMN: any = oSUMMARY.COLUMNS[k];
									if ( oCOLUMN.COLUMN_ID == row['COLUMN_ID'] )
									{
										if ( row['COLUMN_TEXT'] != null )
										{
											for ( let l: number = 0; l < oCOLUMN.MENUS.length; l++ )
											{
												let oMENU: any = oCOLUMN.MENUS[l];
												if ( oMENU.MENU_ID == row['MENU_ID'] )
												{
													if ( row['MENU_TEXT'] != null )
													{
														oMENU.ANSWERED.push(row);
														oMENU.ANSWER_TOTAL++;
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
					}
				}
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadData ', ANSWER_CHOICES_SUMMARY);

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
			nMENU_MAX             ,
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
		const { nANSWERED, nSKIPPED, ANSWER_CHOICES_SUMMARY, COLUMN_CHOICES_SUMMARY, OTHER_SUMMARY, bOTHER_ENABLED, bSHOW_RESPONSES, nMENU_MAX } = this.state;
		let arrCOLUMN_CHOICES: string[] = (COLUMN_CHOICES_SUMMARY ? COLUMN_CHOICES_SUMMARY : []);
		let arrMENUS         : string[] = [];
		for ( let i: number = 0; i < nMENU_MAX; i++ )
		{
			arrMENUS.push('');
		}
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
				{
					ANSWER_CHOICES_SUMMARY.map((oSUMMARY, index) => 
					{
						let nSUMMARIES       : number   = 2 * oSUMMARY.COLUMNS.length;
						let nSUMMARY_WIDTH   : number   = Math.ceil(100 / (nSUMMARIES + 2));
						return(<React.Fragment>
							<div className='SurveyResultsColumnMatrixHeader'>
								{ oSUMMARY.ANSWER_TEXT }
							</div>
							<table className='SurveyResultsRadioMatrix' cellPadding={ 4 } cellSpacing={ 0 } style={ {border: 'none'} }>
								<tr>
									<td className='SurveyResultsAnswerMatrixHeader' style={ {width: nSUMMARY_WIDTH.toString() + '%'} }>
									</td>
								{
									arrCOLUMN_CHOICES.map((COLUMN: any, index) => 
									{
										return(<React.Fragment>
											<td className='SurveyResultsResponseMatrixHeader' style={ {width: nSUMMARY_WIDTH.toString() + '%'} }>
												{ COLUMN.Heading }
											</td>
											<td className='SurveyResultsResponseMatrixHeader' style={ {width: nSUMMARY_WIDTH.toString() + '%'} }>
											</td>
										</React.Fragment>);
									})
								}
								</tr>
							{
								arrMENUS.map((o, k) => 
								{
									return(<React.Fragment>
										<tr>
											<td className='SurveyResultsAnswerMatrixBody' style={ {width: nSUMMARY_WIDTH.toString() + '%'} }>
											</td>
										{
											oSUMMARY.COLUMNS.map((oCOLUMN, index) => 
											{
												if ( k < oCOLUMN.MENUS.length )
												{
													let oMENU: any = oCOLUMN.MENUS[k];
													let nPercentage: number = 0;
													if ( oMENU.ANSWER_TOTAL > 0 )
														nPercentage = Math.ceil(100 * oMENU.ANSWERED.length / oMENU.ANSWER_TOTAL);
													return(<React.Fragment>
														<td className='SurveyResultsAnswerMatrixBody' style={ {width: nSUMMARY_WIDTH.toString() + '%'} }>
															{ oMENU.MENU_TEXT }
														</td>
														<td className='SurveyResultsResponseBody' style={ {width: nSUMMARY_WIDTH.toString() + '%'} }>
															<div style={ {float: 'left'} }>
																{ nPercentage.toString() + '%' }
															</div>
															<div style={ {float: 'right'} } className='SurveyResultsResponseMatrixBodyTotal'>
																{ oMENU.ANSWERED.length }
															</div>
														</td>
													</React.Fragment>);
												}
												else
												{
													return(<React.Fragment>
														<td className='SurveyResultsAnswerMatrixBody' style={ {width: nSUMMARY_WIDTH.toString() + '%'} }>
														</td>
														<td className='SurveyResultsResponseBody' style={ {width: nSUMMARY_WIDTH.toString() + '%'} }>
														</td>
													</React.Fragment>);
												}
											})
										}
										</tr>
									</React.Fragment>);
								})
							}
							</table>
						</React.Fragment>);
					})
				}
				{ bOTHER_ENABLED
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
		</div>
		);
	}
}

