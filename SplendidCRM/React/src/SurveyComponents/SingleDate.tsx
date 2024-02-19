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
import moment from 'moment';
import DateTime from 'react-datetime';
import 'react-datetime/css/react-datetime.css';
import { Appear }                                  from 'react-lifecycle-appear'       ;
// 2. Store and Types. 
import ISurveyQuestionProps                        from '../types/ISurveyQuestionProps';
import SurveyQuestion                              from './SurveyQuestion'             ;
// 3. Scripts. 
import Sql                                         from '../scripts/Sql'               ;
import L10n                                        from '../scripts/L10n'              ;
import Security                                    from '../scripts/Security'          ;
import { Trim, isMobileDevice, ValidateDateParts } from '../scripts/utility'           ;
import { FromJsonDate, ToJsonDate, formatDate }    from '../scripts/Formatting'        ;
import { ListView_LoadTable }                      from '../scripts/ListView'          ;
// 4. Components and Views. 
import ErrorComponent                              from '../components/ErrorComponent' ;
import ResultsPaginateResponses                    from './ResultsPaginateResponses'   ;

interface ISingleDateState
{
	ID                     : string;
	VALUE                  : Date | null;
	DATE_FORMAT            : string;
	TIME_FORMAT            : string;
	resetIndex             : number;
	error?                 : any;
	rawData?               : any[];
	__sql?                 : string;
	nANSWERED?             : number;
	nSKIPPED?              : number;
	ANSWER_CHOICES_SUMMARY?: any[];
}

export default class SingleDate extends SurveyQuestion<ISurveyQuestionProps, ISingleDateState>
{
	private input = React.createRef<HTMLInputElement>();

	public get data(): any
	{
		const { VALUE } = this.state;
		let arrValue: string[] = [];
		try
		{
			let bValid: boolean = (VALUE != null);
			if ( bValid )
			{
				let date: moment.Moment = moment(VALUE);
				bValid = date.isValid();
				if ( bValid )
				{
					arrValue.push(ToJsonDate(VALUE));
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
		const { VALUE } = this.state;
		let bValid: boolean = (VALUE != null);
		try
		{
			if ( bValid )
			{
				let date: moment.Moment = moment(VALUE);
				bValid = date.isValid();
				if ( bValid )
				{
					let error: string = row.INVALID_DATE_MESSAGE;
					this.setState({ error });
					return false;
				}
			}
			if ( bValid && !Sql.IsEmptyString(row.VALIDATION_TYPE) )
			{
				bValid = this.Validation(VALUE);
				if ( !bValid )
				{
					let error: string = this.ValidationMessage();
					this.setState({ error });
					return false;
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
		let ID         : string = null;
		let VALUE      : Date = null;
		let DATE_FORMAT: string  = Sql.ToString(Security.USER_DATE_FORMAT());
		let TIME_FORMAT: string  = Security.USER_TIME_FORMAT();
		// 07/11/2021 Paul.  ID will be null in sample mode. 
		if ( row )
		{
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
		}
		if ( rowQUESTION_RESULTS )
		{
			for ( let j: number = 0; j < rowQUESTION_RESULTS.length; j++ )
			{
				// 09/18/2016 Paul.  Answer may be null. 
				if ( rowQUESTION_RESULTS[j].ANSWER_TEXT )
				{
					VALUE = FromJsonDate(rowQUESTION_RESULTS[j].ANSWER_TEXT);
					if ( VALUE.getFullYear() == 0 )
					{
						VALUE = null;
					}
				}
				break;
			}
		}
		this.state =
		{
			ID         ,
			VALUE      ,
			DATE_FORMAT,
			TIME_FORMAT,
			resetIndex : 0,
		};
	}

	async componentDidMount()
	{
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
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	private _onChange = (value: moment.Moment | string) =>
	{
		const { VALUE, DATE_FORMAT } = this.state;
		try
		{
			let mntValue: moment.Moment = null;
			if ( typeof(value) == 'string' )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange string ' + DATA_FIELD, value);
				if ( Sql.IsEmptyString(value) )
				{
					// 11/17/2019 Paul.  Increment the reset index as clearing the control causes a NaN situation. 
					this.setState({ VALUE: null, error: null, resetIndex: this.state.resetIndex+1 }, this.validate);
					//onChanged(DATA_FIELD, null);
				}
				else
				{
					let bValidDateParts: boolean = ValidateDateParts(value, DATE_FORMAT);
					// 08/05/2019 Paul.  A moment will be valid, even with a single numeric value.  So require 3 parts. 
					mntValue = moment(value, DATE_FORMAT);
					if ( bValidDateParts && mntValue.isValid() )
					{
						let VALUE: Date   = mntValue.toDate();
						this.setState({ VALUE, error: null }, this.validate);
						//onChanged(DATA_FIELD, VALUE);
					}
					else
					{
						this.setState({ error: L10n.Term('.ERR_INVALID_DATE') });
					}
				}
			}
			else if ( value instanceof moment )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange moment ' + DATA_FIELD, value);
				mntValue = moment(value);
				if ( mntValue.isValid() )
				{
					let VALUE: Date   = mntValue.toDate();
					this.setState({ VALUE, error: null }, this.validate);
					//onChanged(DATA_FIELD, VALUE);
				}
				else
				{
					this.setState({ error: L10n.Term('.ERR_INVALID_DATE') });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onBlur = (event) =>
	{
		const { VALUE, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBlur ' + DATA_FIELD, DATA_VALUE);
		// 08/05/2019 Paul.  Change the key so that the control will redraw using current DATE_VALUE. 
		if ( this.input.current != null )
		{
			if ( VALUE == null )
			{
				this.input.current.value = '';
			}
		}
	}

	private _onKeyDown = (event) =>
	{
		const { onFocusNextQuestion } = this.props;
		const { ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' && onFocusNextQuestion )
		{
			onFocusNextQuestion(ID);
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
		const { ID, VALUE, resetIndex, error } = this.state;
		if ( row )
		{
			let cssStyle : any    = {};
			let size     : any    = null;
			let maxLength: number = null;
			if ( row.VALIDATION_TYPE == 'Specific Length' )
				maxLength = Sql.ToInteger(row.VALIDATION_MAX);
			// 12/31/2015 Paul.  Ignore margins on mobile device as they make the layout terrible. 
			if ( isMobileDevice() )
				cssStyle.width = '100%';
			// 11/11/2018 Paul.  Use size not cols. 
			else if ( Sql.ToInteger(row.BOX_WIDTH ) > 0 )
				size = Sql.ToInteger(row.BOX_WIDTH);
			let inputProps: any =
			{
				type        : 'text', 
				autoComplete: 'off',
				style       : {flex: '2 0 70%', width: '100%'},
				onKeyDown   : this._onKeyDown,
				className   : null,  /* 12/10/2019 Paul.  Prevent the default form-control. */
				ref         : this.input
			};
			// 11/24/2019 Paul.  Assume Date only. 
			let dateFormat: boolean = true;
			let timeFormat: boolean = false;
			if ( row.DISPLAY_FORMAT == 'DateTime' )
			{
				dateFormat = true;
				timeFormat = true;
			}
			else if ( row.DISPLAY_FORMAT == 'Time' )
			{
				dateFormat = false;
				timeFormat = true;
			}
			return (
				<React.Fragment>
					{ this.RenderHeader() }
					<DateTime
						key={ ID + '_' + resetIndex.toString() }
						value={ VALUE != null ? moment(VALUE) : null }
						initialViewDate={ VALUE != null ? moment(VALUE) : null }
						onChange={ this._onChange }
						onClose={ this._onBlur }
						dateFormat={ dateFormat }
						timeFormat={ timeFormat }
						input={ true }
						closeOnSelect={ true }
						strictParsing={ true }
						inputProps={ inputProps }
						locale={ Security.USER_LANG().substring(0, 2) }
					/>
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

		if ( rawData != null )
		{
			for ( let i: number = rawData.length - 1; i >= 0; i-- )
			{
				let row: any = rawData[i];
				if ( row['ANSWER_TEXT'] != null )
				{
					nANSWERED++;
				}
				else
				{
					nSKIPPED++;
					rawData.splice(i, 1);
				}
			}
		}
		this.setState(
		{
			rawData               ,
			__sql                 ,
			nANSWERED             ,
			nSKIPPED              ,
			ANSWER_CHOICES_SUMMARY: rawData,
		});
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
				<ResultsPaginateResponses ANSWERED={ ANSWER_CHOICES_SUMMARY } DATE_ENTERED_NAME='DATE_ENTERED' ANSWER_TEXT_NAME='ANSWER_TEXT' tableClasses='SurveyResultsTextArea' dateColumnClasses='SurveyResultsTextboxDate' textColumnClasses='SurveyResultsTextboxText' viewColumnClasses='SurveyResultsTextboxView' />
			</div>
			: null
			}
		</div>
		);
	}
}

