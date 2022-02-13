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
import SURVEY_QUESTION                from '../types/SURVEY_QUESTION';
// 3. Scripts. 
// 4. Components and Views. 
// 5. Questions
import SurveyQuestionPlainText        from './PlainText'             ;
import SurveyQuestionHidden           from './Hidden'                ;
import SurveyQuestionImage            from './Image'                 ;
import SurveyQuestionTextbox          from './Textbox'               ;
import SurveyQuestionSingleNumerical  from './SingleNumerical'       ;
import SurveyQuestionSingleDate       from './SingleDate'            ;
import SurveyQuestionTextArea         from './TextArea'              ;
import SurveyQuestionTextboxMultiple  from './TextboxMultiple'       ;
import SurveyQuestionTextboxNumerical from './TextboxNumerical'      ;
import SurveyQuestionDate             from './Date'                  ;
import SurveyQuestionSingleCheckbox   from './SingleCheckbox'        ;
import SurveyQuestionCheckbox         from './Checkbox'              ;
import SurveyQuestionRadio            from './Radio'                 ;
import SurveyQuestionRange            from './Range'                 ;
import SurveyQuestionDemographic      from './Demographic'           ;
import SurveyQuestionDropdown         from './Dropdown'              ;
import SurveyQuestionRanking          from './Ranking'               ;
import SurveyQuestionRadioMatrix      from './RadioMatrix'           ;
import SurveyQuestionRatingScale      from './RatingScale'           ;
import SurveyQuestionCheckboxMatrix   from './CheckboxMatrix'        ;
import SurveyQuestionDropdownMatrix   from './DropdownMatrix'        ;

export default function SurveyQuestionFactory(row: SURVEY_QUESTION)
{
	let question = null;
	switch ( row.QUESTION_TYPE )
	{
		case 'Plain Text'       :  question = SurveyQuestionPlainText       ;  break;
		// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population.
		case 'Hidden'           :  question = SurveyQuestionHidden          ;  break;
		case 'Image'            :  question = SurveyQuestionImage           ;  break;
		case 'Textbox'          :  question = SurveyQuestionTextbox         ;  break;
		// 11/07/2018 Paul.  Provide a way to get a single numerical value for lead population.
		case 'Single Numerical' :  question = SurveyQuestionSingleNumerical ;  break;
		// 11/07/2018 Paul.  Provide a way to get a single date for lead population.
		case 'Single Date'      :  question = SurveyQuestionSingleDate      ;  break;
		case 'Text Area'        :  question = SurveyQuestionTextArea        ;  break;
		case 'Textbox Multiple' :  question = SurveyQuestionTextboxMultiple ;  break;
		case 'Textbox Numerical':  question = SurveyQuestionTextboxNumerical;  break;
		case 'Date'             :  question = SurveyQuestionDate            ;  break;
		// 11/10/2018 Paul.  Provide a way to get a single checkbox for lead population.
		case 'Single Checkbox'  :  question = SurveyQuestionSingleCheckbox  ;  break;
		case 'Checkbox'         :  question = SurveyQuestionCheckbox        ;  break;
		case 'Radio'            :  question = SurveyQuestionRadio           ;  break;
		// 10/08/2014 Paul.  Add Range question type. 
		case 'Range'            :  question = SurveyQuestionRange           ;  break;
		case 'Demographic'      :  question = SurveyQuestionDemographic     ;  break;
		case 'Dropdown'         :  question = SurveyQuestionDropdown        ;  break;
		case 'Ranking'          :  question = SurveyQuestionRanking         ;  break;
		case 'Radio Matrix'     :  question = SurveyQuestionRadioMatrix     ;  break;
		case 'Rating Scale'     :  question = SurveyQuestionRatingScale     ;  break;
		case 'Checkbox Matrix'  :  question = SurveyQuestionCheckboxMatrix  ;  break;
		case 'Dropdown Matrix'  :  question = SurveyQuestionDropdownMatrix  ;  break;
	}
	if ( question == null )
	{
		console.warn((new Date()).toISOString() + ' ' + 'SurveyQuestionFactory Unsupported question type: ' + row.QUESTION_TYPE);
	}
	return question;
}

