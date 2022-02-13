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
// 2. Store and Types. 
import ISurveyQuestionProps from  '../types/ISurveyQuestionProps';
// 3. Scripts. 
import Sql                  from '../scripts/Sql'                ;
import L10n                 from '../scripts/L10n'               ;
import Credentials          from '../scripts/Credentials'        ;

export default abstract class SurveyQuestion<P extends ISurveyQuestionProps, S> extends React.Component<P, S>
{
	public abstract get data(): any;
	public abstract validate(): boolean;
	public abstract setFocus(): void;
	public abstract isFocused(): boolean;

	protected RandomizeAnswers()
	{
		const { row } = this.props;
		let arrANSWER_CHOICES: string[] = null;
		try
		{
			let RANDOMIZE_COUNT: number = 0;
			if ( !Sql.IsEmptyString(row.ANSWER_CHOICES) )
			{
				// http://www.w3schools.com/jsref/jsref_obj_array.asp
				arrANSWER_CHOICES = Sql.ToString(row.ANSWER_CHOICES).split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
				if ( !Sql.IsEmptyString(row.RANDOMIZE_TYPE) && row.QUESTION_TYPE != 'Demographic' )
				{
					if ( arrANSWER_CHOICES.length > 1 )
					{
						let sLastItem = null;
						if ( Sql.ToBoolean(row.RANDOMIZE_NOT_LAST) )
						{
							sLastItem = arrANSWER_CHOICES.pop();
						}
						if ( row.RANDOMIZE_TYPE == 'Randomize' )
						{
							// http://stackoverflow.com/questions/2450954/how-to-randomize-a-javascript-array
							for ( let i = arrANSWER_CHOICES.length - 1; i > 0; i-- )
							{
								let j: number = Math.floor(Math.random() * (i + 1));
								let temp = arrANSWER_CHOICES[i];
								arrANSWER_CHOICES[i] = arrANSWER_CHOICES[j];
								arrANSWER_CHOICES[j] = temp;
							}
						}
						else if ( row.RANDOMIZE_TYPE == 'Flip' )
						{
							if ( RANDOMIZE_COUNT % 2 == 0 )
							{
								arrANSWER_CHOICES.reverse();
							}
						}
						else if (row.RANDOMIZE_TYPE == 'Sort')
						{
							arrANSWER_CHOICES.sort(function (a, b)
							{
								let al = a.toLowerCase();
								let bl = b.toLowerCase();
								return al == bl ? (a == b ? 0 : (a < b ? -1 : 1)) : (al < bl ? -1 : 1);
							});
						}
						if ( sLastItem != null )
						{
							arrANSWER_CHOICES.push(sLastItem);
						}
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.RandomizeAnswers', error);
		}
		return arrANSWER_CHOICES;
	}

	protected OtherValidation(sValue)
	{
		const { row } = this.props;
		let bValid: boolean = false;
		try
		{
			switch ( row.OTHER_VALIDATION_TYPE )
			{
				case 'Date'           :
					bValid = Sql.IsDate(sValue);
					if ( bValid )
					{
						let dtMIN   = Sql.ToDateTime(row.OTHER_VALIDATION_MIN);
						let dtMAX   = Sql.ToDateTime(row.OTHER_VALIDATION_MAX);
						let dtVALUE = Sql.ToDateTime(sValue);
						bValid      = (dtVALUE >= dtMIN && dtVALUE <= dtMAX);
					}
					break;
				case 'Specific Length':
					bValid = (sValue.length         >= Sql.ToInteger(row.OTHER_VALIDATION_MIN) && sValue.length         <= Sql.ToInteger(row.OTHER_VALIDATION_MAX));
					break;
				case 'Integer'        :
					bValid = Sql.IsInteger(sValue);
					if ( bValid )
					{
						bValid = (Sql.ToInteger(sValue) >= Sql.ToInteger(row.OTHER_VALIDATION_MIN) && Sql.ToInteger(sValue) <= Sql.ToInteger(row.OTHER_VALIDATION_MAX));
					}
					break;
				case 'Decimal'        :
					bValid = Sql.IsFloat(sValue);
					if ( bValid )
					{
						bValid = (Sql.ToFloat  (sValue) >= Sql.ToFloat  (row.OTHER_VALIDATION_MIN) && Sql.ToFloat  (sValue) <= Sql.ToFloat  (row.OTHER_VALIDATION_MAX));
					}
					break;
				case 'Email'          :
					bValid = Sql.IsEmail(sValue);
					break;
				default               :
					bValid = true;
					break;
			}
		}
		catch(error)
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.OtherValidation', error);
		}
		return bValid;
	}

	protected OtherValidationMessage()
	{
		const { row } = this.props;
		let sError: string = Sql.ToString(row.OTHER_VALIDATION_MESSAGE);
		switch ( row.OTHER_VALIDATION_TYPE )
		{
			case 'Date'           :
			case 'Specific Length':
			case 'Integer'        :
			case 'Decimal'        :
				sError = sError.replace('{0}', row.OTHER_VALIDATION_MIN).replace('{1}', row.OTHER_VALIDATION_MAX);
				break;
		}
		return sError;
	}

	protected Validation(sValue)
	{
		const { row } = this.props;
		let bValid: boolean = false;
		try
		{
			switch ( row.VALIDATION_TYPE )
			{
				case 'Date'           :
				{
					let dtMIN   = Sql.ToDateTime(row.VALIDATION_MIN);
					let dtMAX   = Sql.ToDateTime(row.VALIDATION_MAX);
					let dtVALUE = Sql.ToDateTime(sValue);
					bValid      = (dtVALUE >= dtMIN && dtVALUE <= dtMAX);
					break;
				}
				case 'Specific Length':  bValid = (sValue.length         >= Sql.ToInteger(row.VALIDATION_MIN) && sValue.length         <= Sql.ToInteger(row.VALIDATION_MAX));  break;
				case 'Integer'        :  bValid = (Sql.ToInteger(sValue) >= Sql.ToInteger(row.VALIDATION_MIN) && Sql.ToInteger(sValue) <= Sql.ToInteger(row.VALIDATION_MAX));  break;
				case 'Decimal'        :  bValid = (Sql.ToFloat  (sValue) >= Sql.ToFloat  (row.VALIDATION_MIN) && Sql.ToFloat  (sValue) <= Sql.ToFloat  (row.VALIDATION_MAX));  break;
				case 'Email'          :  bValid = Sql.IsEmail(sValue);  break;
				default               :  bValid = true;  break;
			}
		}
		catch(error)
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.Validation', error);
		}
		return bValid;
	}

	protected ValidationMessage()
	{
		const { row } = this.props;
		let sError: string = Sql.ToString(row.VALIDATION_MESSAGE);
		switch ( row.VALIDATION_TYPE )
		{
			case 'Date'           :
			case 'Specific Length':
			case 'Integer'        :
			case 'Decimal'        :
				sError = sError.replace('{0}', row.VALIDATION_MIN).replace('{1}', row.VALIDATION_MAX);
				break;
		}
		return sError;
	}

	protected RequiredTypeValidation(nSelected, nTotal)
	{
		const { row } = this.props;
		let bValid: boolean = false;
		try
		{
			switch ( row.REQUIRED_TYPE )
			{
				case 'All'     :  bValid = (nSelected == nTotal);  break;
				case 'At Least':  bValid = (nSelected >= Sql.ToInteger(row.REQUIRED_RESPONSES_MIN));  break;
				case 'At Most' :  bValid = (nSelected <= Sql.ToInteger(row.REQUIRED_RESPONSES_MAX));  break;
				case 'Exactly' :  bValid = (nSelected == Sql.ToInteger(row.REQUIRED_RESPONSES_MIN));  break;
				case 'Range'   :  bValid = (nSelected >= Sql.ToInteger(row.REQUIRED_RESPONSES_MIN) && nSelected <= Sql.ToInteger(row.REQUIRED_RESPONSES_MAX));  break;
				default        :  break;
			}
		}
		catch(error)
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.RequiredTypeValidation', error);
		}
		return bValid;
	}

	protected RequiredTypeMessage(nTotal)
	{
		const { row } = this.props;
		let sError: string = Sql.ToString(row.REQUIRED_MESSAGE);
		sError = sError.replace('{REQUIRED_TYPE}', Sql.ToString(row.REQUIRED_TYPE));
		switch ( row.REQUIRED_TYPE )
		{
			case 'All'     :  sError = sError.replace('{0}', nTotal.toString());  break;
			case 'At Least':  sError = sError.replace('{0}', Sql.ToString(row.REQUIRED_RESPONSES_MIN));  break;
			case 'At Most' :  sError = sError.replace('{0}', Sql.ToString(row.REQUIRED_RESPONSES_MAX));  break;
			case 'Exactly' :  sError = sError.replace('{0}', Sql.ToString(row.REQUIRED_RESPONSES_MIN));  break;
			case 'Range'   :  sError = sError.replace('{0}', Sql.ToString(row.REQUIRED_RESPONSES_MIN)).replace('{1}', Sql.ToString(row.REQUIRED_RESPONSES_MAX));  break;
		}
		return sError;
	}

	protected ConvertFromEpocDate(nSeconds)
	{
		// 08/21/2018 Paul.  JavaScript counts months from 0 to 11. 
		// https://www.w3schools.com/js/js_dates.asp
		let dtUnixEpoc = new Date(1970, 0, 1);
		dtUnixEpoc.setSeconds(dtUnixEpoc.getSeconds() + nSeconds)
		return dtUnixEpoc;
	}

	// 08/17/2018 Paul.  For date validation, we need to store time in seconds as the database field is an integer.  Convert to seconds since 1970. 
	protected RequiredDateValidation(dtSelected)
	{
		const { row } = this.props;
		let bValid: boolean = false;
		try
		{
			switch ( row.REQUIRED_TYPE )
			{
				case 'All'     :  bValid = true;  break;
				case 'At Least':  bValid = (dtSelected >= this.ConvertFromEpocDate(Sql.ToInteger(row.REQUIRED_RESPONSES_MIN)));  break;
				case 'At Most' :  bValid = (dtSelected <= this.ConvertFromEpocDate(Sql.ToInteger(row.REQUIRED_RESPONSES_MAX)));  break;
				case 'Exactly' :  bValid = (dtSelected == this.ConvertFromEpocDate(Sql.ToInteger(row.REQUIRED_RESPONSES_MIN)));  break;
				case 'Range'   :  bValid = (dtSelected >= this.ConvertFromEpocDate(Sql.ToInteger(row.REQUIRED_RESPONSES_MIN)) && dtSelected <= this.ConvertFromEpocDate(Sql.ToInteger(row.REQUIRED_RESPONSES_MAX)));  break;
				default        :  bValid = Sql.IsDate(dtSelected);  break;
			}
		}
		catch(error)
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.RequiredDateValidation', error);
		}
		return bValid;
	}

/*
	// 08/17/2018 Paul.  For date validation, we need to store time in seconds as the database field is an integer.  Convert to seconds since 1970. 
	protected RequiredDateMessage(dtValue)
	{
		const { row } = this.props;
		let sError: string = null;
		try
		{
			let sDATE_FORMAT: string = Security.USER_DATE_FORMAT();
			if ( sDATE_FORMAT === undefined )
				sDATE_FORMAT = 'mm/dd/yy';
			// 08/17/2018 Paul.  Convert Windows format to datepicker format. 
			sDATE_FORMAT = sDATE_FORMAT.replace('yyyy', 'yy');
			sDATE_FORMAT = sDATE_FORMAT.replace('MM'  , 'mm');
		
			sError = Sql.ToString(row.REQUIRED_MESSAGE);
			sError = sError.replace('{REQUIRED_TYPE}', Sql.ToString(row.REQUIRED_TYPE));
			switch ( row.REQUIRED_TYPE )
			{
				case 'All'     :  sError = sError.replace('{0}', $.datepicker.formatDate(sDATE_FORMAT, dtValue));  break;
				case 'At Least':  sError = sError.replace('{0}', $.datepicker.formatDate(sDATE_FORMAT, SurveyQuestion_ConvertFromEpocDate(Sql.ToInteger(row.REQUIRED_RESPONSES_MIN))));  break;
				case 'At Most' :  sError = sError.replace('{0}', $.datepicker.formatDate(sDATE_FORMAT, SurveyQuestion_ConvertFromEpocDate(Sql.ToInteger(row.REQUIRED_RESPONSES_MAX))));  break;
				case 'Exactly' :  sError = sError.replace('{0}', $.datepicker.formatDate(sDATE_FORMAT, SurveyQuestion_ConvertFromEpocDate(Sql.ToInteger(row.REQUIRED_RESPONSES_MIN))));  break;
				case 'Range'   :  sError = sError.replace('{0}', $.datepicker.formatDate(sDATE_FORMAT, SurveyQuestion_ConvertFromEpocDate(Sql.ToInteger(row.REQUIRED_RESPONSES_MIN)))).replace('{1}', $.datepicker.formatDate(sDATE_FORMAT, SurveyQuestion_ConvertFromEpocDate(Sql.ToInteger(row.REQUIRED_RESPONSES_MAX))));  break;
			}
		}
		catch(error)
		{
			sError = error.message;
		}
		return sError;
	}
*/

	private getExportURL = () =>
	{
		const { row } = this.props;
		return Credentials.RemoteServer + 'Surveys/exportSummary.aspx?SURVEY_ID=' + row.SURVEY_ID + '&SURVEY_PAGE_ID=' + row.SURVEY_PAGE_ID + '&SURVEY_QUESTION_ID=' + row.ID;;
	}

	protected RenderHeader()
	{
		const { displayMode, row } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.RenderHeader ' + row.QUESTION_TYPE);
		// 07/13/2021 Paul.  Show header for plain and hidden in sample mode. 
		// 07/28/2021 Paul.  Show header in preview mode even before DESCRIPTION defined. 
		if ( displayMode == 'Preview' || ((displayMode == 'Sample' || displayMode == 'Summary' || (row.QUESTION_TYPE != 'Plain Text' && row.QUESTION_TYPE != 'Hidden')) && !Sql.IsEmptyString(row.DESCRIPTION)) )
		{
			// 12/24/2015 Paul.  L10n is only available in SummaryView.ascx. This is fine because we do not want to display in non-summary mode. 
			return (
				<table cellPadding={ 0 } cellSpacing={ 0 } style={ {width: '100%', border: 'none'} }>
					<tbody>
						<tr>
							<td className='SurveyQuestionHeading' style={ {width: '90%'} }>
								{ Sql.ToBoolean(row.REQUIRED)
								? <span className='SurveyQuestionRequiredAsterisk'>*</span>
								: null
								}
								{ row.QUESTION_NUMBER > 0
								? <span className='SurveyQuestionNumber'>{ row.QUESTION_NUMBER.toString() }. </span>
								: null
								}
								<span dangerouslySetInnerHTML={ {__html: row.DESCRIPTION} }/>
							</td>
							<td valign='top' align='right' style={ {width: '10%'} }>
								{ displayMode == 'Summary'
								? <a href={ this.getExportURL() }
									className='listViewTdLinkS1'
									target={ 'SurveyResults_' + row.ID }
									onClick={ (e) => { e.preventDefault(); window.location.href = this.getExportURL(); } }
								>
									{ L10n.Term('SurveyResults.LBL_EXPORT') }
								</a>
								: null
								}
							</td>
						</tr>
					</tbody>
				</table>

			);
		}
		else
		{
			return null;
		}
	}

	protected RenderAnswered(nANSWERED: number, nSKIPPED: number)
	{
		return (<div>
			<span className='SurveyResultsSubHeader'>
				{ nANSWERED != null
				? L10n.Term("SurveyResults.LBL_ANSWERED").replace('{0}', nANSWERED.toString())
				: null
				}
			</span>
			<span className='SurveyResultsSubHeader'>
				{ nSKIPPED != null
				? L10n.Term("SurveyResults.LBL_SKIPPED").replace('{0}', nSKIPPED.toString())
				: null
				}
			</span>
		</div>
		);
	}
}

