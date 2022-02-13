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
import { Appear }                               from 'react-lifecycle-appear'       ;
// 2. Store and Types. 
import ISurveyQuestionProps                     from '../types/ISurveyQuestionProps';
import SurveyQuestion                           from './SurveyQuestion'             ;
// 3. Scripts. 
import Sql                                      from '../scripts/Sql'               ;
import L10n                                     from '../scripts/L10n'              ;
import { Trim, isMobileDevice }                 from '../scripts/utility'           ;
import { ListView_LoadTable }                   from '../scripts/ListView'          ;
// 4. Components and Views. 
import ErrorComponent                           from '../components/ErrorComponent' ;
import ResultsPaginateResponses                 from './ResultsPaginateResponses'   ;

interface ITextAreaState
{
	ID                     : string;
	VALUE                  : string;
	error?                 : any;
	rawData?               : any[];
	__sql?                 : string;
	nANSWERED?             : number;
	nSKIPPED?              : number;
	ANSWER_CHOICES_SUMMARY?: any[];
}

export default class TextArea extends SurveyQuestion<ISurveyQuestionProps, ITextAreaState>
{
	private input    = React.createRef<HTMLInputElement>();
	private textarea = React.createRef<HTMLTextAreaElement>();

	public get data(): any
	{
		const { VALUE } = this.state;
		let arrValue: string[] = [];
		try
		{
			let sValue: string = Trim(Sql.ToString(VALUE));
			let bValid: boolean = !Sql.IsEmptyString(sValue);
			if ( bValid )
			{
				arrValue.push(sValue);
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
		let sValue: string  = Trim(Sql.ToString(VALUE));
		let bValid: boolean = !Sql.IsEmptyString(sValue);
		try
		{
			// 08/15/2013 Paul.  VALIDATION_TYPE is in row object. 
			if ( bValid && !Sql.IsEmptyString(row.VALIDATION_TYPE))
			{
				bValid = this.Validation(sValue);
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
		else if ( this.textarea.current != null )
		{
			this.textarea.current.focus();
		}
	}

	public isFocused(): boolean
	{
		let bIsFocused: boolean = false;
		if ( this.input.current != null )
		{
			bIsFocused = (this.input.current.id == document.activeElement.id);
		}
		else if ( this.textarea.current != null )
		{
			bIsFocused = (this.textarea.current.id == document.activeElement.id);
		}
		return bIsFocused;
	}

	constructor(props: ISurveyQuestionProps)
	{
		super(props);
		const { displayMode, row, rowQUESTION_RESULTS } = props;
		let ID   : string = null;
		let VALUE: string = '';
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
					VALUE = rowQUESTION_RESULTS[j].ANSWER_TEXT;
				}
				break;
			}
		}
		this.state =
		{
			ID   ,
			VALUE,
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

	private _onChange = (e): void =>
	{
		let value = e.target.value;
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
		const { ID, VALUE, error } = this.state;
		if ( row )
		{
			let cssStyle: any = {};
			// 12/31/2015 Paul.  Ignore margins on mobile device as they make the layout terrible. 
			if ( isMobileDevice() )
				cssStyle.width = '100%';
			if ( Sql.ToInteger(row.BOX_HEIGHT) == 1 )
			{
				let size     : any    = null;
				let maxLength: number = null;
				// 11/11/2018 Paul.  Use size not cols. 
				if ( !isMobileDevice() && Sql.ToInteger(row.BOX_WIDTH ) > 0 )
					size = Sql.ToInteger(row.BOX_WIDTH);
				if ( row.VALIDATION_TYPE == 'Specific Length' )
					maxLength = Sql.ToInteger(row.VALIDATION_MAX);
				return (
					<React.Fragment>
						{ this.RenderHeader() }
						<input
							type='text'
							id={ ID }
							key={ ID }
							className='SurveyAnswerChoice SurveyAnswerTextbox'
							style={ cssStyle }
							size={ size }
							value={ VALUE }
							disabled={ bDisable }
							maxLength={ maxLength }
							onChange={ this._onChange }
							onKeyDown={ this._onKeyDown }
							ref={ this.input }
							/>
						<ErrorComponent error={error} />
					</React.Fragment>
				);
			}
			else
			{
				return (
					<React.Fragment>
						{ this.RenderHeader() }
						<textarea
							id={ ID }
							key={ ID }
							className='SurveyAnswerChoice SurveyAnswerTextArea'
							style={ cssStyle }
							value={ VALUE }
							disabled={ bDisable }
							cols={ Sql.ToInteger(row.BOX_WIDTH ) > 0 ? Sql.ToInteger(row.BOX_WIDTH ): null }
							rows={ Sql.ToInteger(row.BOX_HEIGHT) > 0 ? Sql.ToInteger(row.BOX_HEIGHT): null }
							onChange={ this._onChange }
							ref={ this.textarea }
							/>
						<ErrorComponent error={error} />
					</React.Fragment>
				);
			}
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

