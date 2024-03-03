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

interface IDemographicState
{
	ID                     : string;
	VALUE                  : Record<string, string>;
	COLUMN_ERRORS          : Record<string, boolean>;
	COLUMN_CHOICES         : any[];
	error?                 : any;
	rawData?               : any[];
	__sql?                 : string;
	nANSWERED?             : number;
	nSKIPPED?              : number;
	ANSWER_CHOICES_SUMMARY?: any[];
}

export default class Demographic extends SurveyQuestion<ISurveyQuestionProps, IDemographicState>
{
	private inputs: any[] = [];

	public get data(): any
	{
		const { row } = this.props;
		const { VALUE, COLUMN_CHOICES } = this.state;
		let arrValue: string[] = [];
		try
		{
		if ( COLUMN_CHOICES )
		{
			for ( let i = 0; i < COLUMN_CHOICES.length; i++ )
			{
				if ( Sql.ToBoolean(COLUMN_CHOICES[i].Visible) )
				{
					let COLUMN_ID: string = md5(COLUMN_CHOICES[i].Name);
					let sValue   : string = Trim(VALUE[COLUMN_ID]);
					arrValue.push(COLUMN_ID + ',' + sValue);
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
		const { VALUE, COLUMN_CHOICES } = this.state;
		let bValid       : boolean = false;
		let error        : string = null;
		let COLUMN_ERRORS: Record<string, boolean> = {};
		try
		{
			let sValue  : string = '';
			if ( COLUMN_CHOICES && COLUMN_CHOICES.length > 0 )
			{
				bValid = true;
				for ( let i = 0; i < COLUMN_CHOICES.length; i++ )
				{
					let COLUMN_ID: string = md5(COLUMN_CHOICES[i].Name);
					if ( Sql.ToBoolean(COLUMN_CHOICES[i].Visible) && Sql.ToBoolean(COLUMN_CHOICES[i].Required) )
					{
						var sTxtValue = Trim(VALUE[COLUMN_ID]);
						var bTxtValid = (sTxtValue.length > 0);
						if ( bTxtValid && COLUMN_CHOICES[i].Name == 'EMAIL_ADDRESS' )
						{
							bTxtValid = Sql.IsEmail(sTxtValue);
						}
						if ( !bTxtValid )
						{
							error = row.REQUIRED_MESSAGE;
							COLUMN_ERRORS[COLUMN_ID] = true;
							bValid = false;
						}
					}
				}
			}
			this.setState({ COLUMN_ERRORS, error });
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
		let VALUE          : Record<string, string> = {};
		let COLUMN_ERRORS  : Record<string, boolean> = {};
		let sCOLUMN_CHOICES: string = null;
		let COLUMN_CHOICES : any[]  = null;
		// 07/11/2021 Paul.  ID will be null in sample mode. 
		if ( row )
		{
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
			sCOLUMN_CHOICES = Sql.ToString(row.COLUMN_CHOICES);
		}
		if ( displayMode == 'Sample' )
		{
			sCOLUMN_CHOICES = '<?xml version="1.0" encoding="UTF-8"?><Demographic>';
			sCOLUMN_CHOICES += '<Field Name="NAME" Visible="True" Required="False">Name:</Field>';
			sCOLUMN_CHOICES += '<Field Name="COMPANY" Visible="True" Required="False">Company:</Field>';
			//sCOLUMN_CHOICES += '<Field Name="ADDRESS1" Visible="True" Required="False">Address 1:</Field>';
			//sCOLUMN_CHOICES += '<Field Name="ADDRESS2" Visible="True" Required="False">Address 2:</Field>';
			//sCOLUMN_CHOICES += '<Field Name="CITY" Visible="True" Required="False">City:</Field>';
			//sCOLUMN_CHOICES += '<Field Name="STATE" Visible="True" Required="False">State/Province:</Field>';
			//sCOLUMN_CHOICES += '<Field Name="POSTAL_CODE" Visible="True" Required="False">Postal Code:</Field>';
			//sCOLUMN_CHOICES += '<Field Name="COUNTRY" Visible="True" Required="False">Country:</Field>';
			sCOLUMN_CHOICES += '<Field Name="EMAIL_ADDRESS" Visible="True" Required="False">Email Address:</Field>';
			sCOLUMN_CHOICES += '<Field Name="PHONE_NUMBER" Visible="True" Required="False">Phone Number:</Field>';
			sCOLUMN_CHOICES += '</Demographic>';
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
			let arrCOLUMN_CHOICES = XMLParser.parse(sCOLUMN_CHOICES, options).Demographic.Field;
			COLUMN_CHOICES = new Array();
			for ( let i = 0; i < arrCOLUMN_CHOICES.length; i++ )
			{
				if ( Sql.ToBoolean(arrCOLUMN_CHOICES[i].Visible) )
				{
					this.inputs.push(React.createRef<HTMLInputElement>());
					COLUMN_CHOICES.push(arrCOLUMN_CHOICES[i]);
					
					let COLUMN_ID: string = md5(arrCOLUMN_CHOICES[i].Name);
					VALUE        [COLUMN_ID] = '';
					COLUMN_ERRORS[COLUMN_ID] = false;
					if ( rowQUESTION_RESULTS )
					{
						for ( let j = 0; j < rowQUESTION_RESULTS.length; j++ )
						{
							if ( COLUMN_ID == rowQUESTION_RESULTS[j].ANSWER_ID )
							{
								VALUE[COLUMN_ID] = rowQUESTION_RESULTS[j].ANSWER_TEXT;
								break;
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
			COLUMN_ERRORS ,
			COLUMN_CHOICES,
		};
	}

	private _onChange = (COLUMN_ID: string, text: string): void =>
	{
		let { VALUE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			VALUE[COLUMN_ID] = text;
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
		const { ID, VALUE, COLUMN_ERRORS, COLUMN_CHOICES, error } = this.state;
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
			if ( COLUMN_CHOICES )
			{
				for ( let i = 0; i < COLUMN_CHOICES.length; i++ )
				{
					if ( Sql.ToBoolean(COLUMN_CHOICES[i].Visible) )
					{
						let COLUMN_ID: string = md5(COLUMN_CHOICES[i].Name);
						let tr = (<tr>
							<td style={ {width: nLABEL_WIDTH.toString() + '%'} }>
								<div className='SurveyAnswerChoice'>
									<label htmlFor={ ID + '_' + COLUMN_ID }>
										{ COLUMN_CHOICES[i].Label }
										{ Sql.ToBoolean(COLUMN_CHOICES[i].Required)
										? <span style={ {color: 'red'} }>*</span>
										: null
										}
										{ COLUMN_ERRORS[COLUMN_ID]
										? <span className='SurveyQuestionError' style={ {marginLeft: '10px', marginRight: '10px', backgroundColor: 'inherit'} }>{ row.REQUIRED_MESSAGE }</span>
										: null
										}
									</label>
								</div>
							</td>
							<td style={ {width: nFIELD_WIDTH.toString() + '%'} }>
								<div className='SurveyAnswerChoice'>
									<input
										type='text'
										id={ ID + '_' + COLUMN_ID }
										key={ ID + '_' + COLUMN_ID }
										className='SurveyAnswerChoiceTextbox'
										style={ cssStyle }
										size={ size }
										value={ VALUE[COLUMN_ID] }
										disabled={ bDisable }
										onChange={ (e) => { this._onChange(COLUMN_ID, e.target.value); } }
										onKeyDown={ (e) => { this._onKeyDown(i, e); } }
										ref={ this.inputs[i] }
										/>
								</div>
							</td>
						</tr>);
						arrTableRows.push(tr);
					}
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
		let sSELECT         : string = 'SURVEY_RESULT_ID, DATE_ENTERED, ANSWER_ID, ANSWER_TEXT';
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

		if ( !Sql.IsEmptyString(this.props.row.COLUMN_CHOICES) )
		{
			// <Demographic><Field Name="NAME" Visible="" Required="">Name:</Field></Demographic>
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
			let arrCOLUMN_CHOICES = XMLParser.parse(this.props.row.COLUMN_CHOICES, options).Demographic.Field;
			for ( var i = 0; i < arrCOLUMN_CHOICES.length; i++ )
			{
				if ( Sql.ToBoolean(arrCOLUMN_CHOICES[i].Visible) )
				{
					let oSUMMARY: any = new Object();
					oSUMMARY.ANSWER_TEXT = arrCOLUMN_CHOICES[i].Label;
					oSUMMARY.ANSWER_ID   = md5(arrCOLUMN_CHOICES[i].Name);
					oSUMMARY.ANSWERED    = new Array();
					oSUMMARY.SKIPPED     = new Array();
					ANSWER_CHOICES_SUMMARY.push(oSUMMARY);
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
				<table className='SurveyResultsDemographic' cellPadding={ 4 } cellSpacing={ 0 } style={ {border: 'none'} }>
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

