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
import { Crm_Config }                           from '../scripts/Crm'               ;
// 4. Components and Views. 
import ErrorComponent                           from '../components/ErrorComponent' ;
import ResultsPaginateResponses                 from './ResultsPaginateResponses'   ;

interface ISingleCheckboxState
{
	ID                     : string;
	VALUE                  : boolean;
	ANSWER_CHOICES         : string;
	error?                 : any;
	rawData?               : any[];
	__sql?                 : string;
	nANSWERED?             : number;
	nSKIPPED?              : number;
	ANSWER_CHOICES_SUMMARY?: any[];
}

export default class SingleCheckbox extends SurveyQuestion<ISurveyQuestionProps, ISingleCheckboxState>
{
	private input = React.createRef<HTMLInputElement>();

	public get data(): any
	{
		const { VALUE } = this.state;
		let arrValue: string[] = [];
		try
		{
			if ( VALUE )
			{
				arrValue.push('1');
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
		let bValid: boolean = VALUE;
		try
		{
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
		let ID            : string  = null;
		let VALUE         : boolean = false;
		let ANSWER_CHOICES: string = null;
		// 07/11/2021 Paul.  ID will be null in sample mode. 
		if ( row )
		{
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
			ANSWER_CHOICES = row.ANSWER_CHOICES;
		}
		if ( displayMode == 'Sample' )
		{
			ANSWER_CHOICES = 'Yes?';
		}
		if ( rowQUESTION_RESULTS )
		{
			for ( let j: number = 0; j < rowQUESTION_RESULTS.length; j++ )
			{
				// 09/18/2016 Paul.  Answer may be null. 
				if ( rowQUESTION_RESULTS[j].ANSWER_TEXT )
				{
					VALUE = Sql.ToBoolean(rowQUESTION_RESULTS[j].ANSWER_TEXT);
				}
				break;
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

	private _onChange = (ev: React.ChangeEvent<HTMLInputElement>) =>
	{
		let VALUE: boolean = ev.target.checked;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			this.setState({ VALUE });
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
			return (
				<React.Fragment>
					{ this.RenderHeader() }
					<input
						type='checkbox'
						id={ ID }
						key={ ID }
						className='SurveyAnswerChoice SurveyAnswerChoiceCheckbox'
						style={ cssStyle }
						checked={ VALUE }
						disabled={ bDisable }
						onChange={ this._onChange }
						ref={ this.input }
						/>
					&nbsp;&nbsp;
					<label htmlFor={ ID } dangerouslySetInnerHTML={ { __html: Sql.ToString(row.ANSWER_CHOICES) } } />
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

