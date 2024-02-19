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
import { md5 }                                     from '../scripts/md5'               ;
import { Trim, isMobileDevice, ValidateDateParts } from '../scripts/utility'           ;
import { FromJsonDate, ToJsonDate, formatDate }    from '../scripts/Formatting'        ;
import { ListView_LoadTable }                      from '../scripts/ListView'          ;
// 4. Components and Views. 
import ErrorComponent                              from '../components/ErrorComponent' ;
import ResultsPaginateResponses                    from './ResultsPaginateResponses'   ;

interface IDateMultipleState
{
	ID                     : string;
	VALUE                  : Record<string, Date>;
	ANSWER_CHOICES         : string[];
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

export default class DateMultiple extends SurveyQuestion<ISurveyQuestionProps, IDateMultipleState>
{
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
				let bValid: boolean = (VALUE[ANSWER_ID] != null);
				if ( bValid )
				{
					let date: moment.Moment = moment(VALUE[ANSWER_ID]);
					bValid = date.isValid();
					if ( bValid )
					{
						arrValue.push(ToJsonDate(VALUE[ANSWER_ID]));
					}
				}
				else
				{
					// 06/19/2013 Paul.  Even if no values, log that the user saw the question. 
					arrValue.push(ANSWER_ID + ',');
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
		try
		{
			let selected: number = 0;
			let total   : number = 0;
			if ( ANSWER_CHOICES )
			{
				total = ANSWER_CHOICES.length;
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
					let bValid: boolean = (VALUE[ANSWER_ID] != null);
					if ( bValid )
					{
						let date: moment.Moment = moment(VALUE);
						bValid = date.isValid();
						if ( bValid )
						{
							selected++;
							// 08/15/2013 Paul.  VALIDATION_TYPE is in row object. 
							if ( !Sql.IsEmptyString(row.VALIDATION_TYPE) )
							{
								bValid = this.Validation(VALUE[ANSWER_ID]);
								if ( !bValid )
								{
									let error: string = this.ValidationMessage();
									this.setState({ error });
									return false;
								}
							}
						}
					}
				}
			}
			if ( Sql.ToBoolean(row.REQUIRED) )
			{
				// 06/09/2013 Paul.  If type is blank, then use existing bValid value. 
				if ( !Sql.IsEmptyString(row.REQUIRED_TYPE) )
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
		let VALUE         : Record<string, Date> = {};
		let ANSWER_CHOICES: string[] = null;
		let DATE_FORMAT   : string  = Sql.ToString(Security.USER_DATE_FORMAT());
		let TIME_FORMAT   : string  = Security.USER_TIME_FORMAT();
		// 07/11/2021 Paul.  ID will be null in sample mode. 
		if ( row )
		{
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
			ANSWER_CHOICES = this.RandomizeAnswers();
		}
		if ( displayMode == 'Sample' )
		{
			ANSWER_CHOICES = 'Favorite Food?\r\nFavorite Color?'.split('\r\n');
		}
		if ( ANSWER_CHOICES )
		{
			for (let i = 0; i < ANSWER_CHOICES.length; i++)
			{
				this.inputs.push(React.createRef<HTMLInputElement>());
				let ANSWER_ID = md5(ANSWER_CHOICES[i]);
				VALUE[ANSWER_ID] = null;
				if ( rowQUESTION_RESULTS )
				{
					for ( let j = 0; j < rowQUESTION_RESULTS.length; j++ )
					{
						if ( ANSWER_ID == rowQUESTION_RESULTS[j].ANSWER_ID )
						{
							// 09/18/2016 Paul.  Answer may be null. 
							if ( rowQUESTION_RESULTS[j].ANSWER_TEXT )
							{
								VALUE[ANSWER_ID] = FromJsonDate(rowQUESTION_RESULTS[j].ANSWER_TEXT);
								if ( VALUE[ANSWER_ID].getFullYear() == 0 )
								{
									VALUE[ANSWER_ID] = null;
								}
							}
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
			DATE_FORMAT   ,
			TIME_FORMAT   ,
			resetIndex    : 0,
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

	private _onChange = (ANSWER_ID: string, value: moment.Moment | string): void =>
	{
		let { VALUE } = this.state;
		const { DATE_FORMAT } = this.state;
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
						VALUE[ANSWER_ID] = mntValue.toDate();
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
					VALUE[ANSWER_ID] = mntValue.toDate();
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

	private _onBlur = (iInput, ANSWER_ID: string, event) =>
	{
		const { VALUE, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBlur ' + DATA_FIELD, DATA_VALUE);
		// 08/05/2019 Paul.  Change the key so that the control will redraw using current DATE_VALUE. 
		if ( this.inputs[iInput].current != null )
		{
			if ( VALUE[ANSWER_ID] == null )
			{
				this.inputs[iInput].current.value = '';
			}
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
		const { ID, VALUE, ANSWER_CHOICES, resetIndex, error } = this.state;
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
			
			let arrTableRows = [];
			// 07/28/2021 Paul.  Move empty filter lower so that header will be displayed. 
			if ( ANSWER_CHOICES )
			{
				for ( let i = 0; i < ANSWER_CHOICES.length; i++ )
				{
					let inputProps: any =
					{
						type        : 'text', 
						autoComplete: 'off',
						style       : {flex: '2 0 70%', width: '100%'},
						onKeyDown   : this._onKeyDown,
						className   : null,  /* 12/10/2019 Paul.  Prevent the default form-control. */
						ref         : this.inputs[i]
					};
					let ANSWER_ID: string = md5(ANSWER_CHOICES[i]);
					let tr = (<tr>
						<td style={ {width: nLABEL_WIDTH.toString() + '%'} }>
							<div className='SurveyAnswerChoice'>
								<label htmlFor={ ID + '_' + ANSWER_ID }>{ ANSWER_CHOICES[i] }</label>
							</div>
						</td>
						<td style={ {width: nFIELD_WIDTH.toString() + '%'} }>
							<div className='SurveyAnswerChoice'>
								<DateTime
									key={ ID + '_' + ANSWER_ID + '_' + resetIndex.toString() }
									value={ VALUE[ANSWER_ID] != null ? moment(VALUE[ANSWER_ID]) : null }
									initialViewDate={ VALUE[ANSWER_ID] != null ? moment(VALUE[ANSWER_ID]) : null }
									onChange={ (value: moment.Moment | string) => { this._onChange(ANSWER_ID, value); } }
									onClose={ (event) => { this._onBlur(i, ANSWER_ID, event); } }
									dateFormat={ dateFormat }
									timeFormat={ timeFormat }
									input={ true }
									closeOnSelect={ true }
									strictParsing={ true }
									inputProps={ inputProps }
									locale={ Security.USER_LANG().substring(0, 2) }
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
				<table className='SurveyResultsDate' cellPadding={ 4 } cellSpacing={ 0 } style={ {border: 'none'} }>
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
			</div>
			: null
			}
		</div>
		);
	}
}

