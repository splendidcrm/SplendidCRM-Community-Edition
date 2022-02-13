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
// 2. Store and Types. 
// 3. Scripts. 
import Sql          from './Sql'        ;
import Credentials  from './Credentials';

export function LoadSurveyTheme(SURVEY_THEME_ID: string)
{
	let link = document.createElement('link');
	link.href = Credentials.RemoteServer + 'Surveys/stylesheet.aspx?ID=' + SURVEY_THEME_ID;
	link.rel  = 'stylesheet';
	link.type = 'text/css';
	
	let bStylesheetExists = false;
	let arrLinks = document.getElementsByTagName('link');
	for ( let i: number = 0; i < arrLinks.length; i++ )
	{
		let sLink: string = arrLinks[i].href;
		if ( sLink == link.href )
		{
			bStylesheetExists = true;
			break;
		}
		else if ( sLink.indexOf('Surveys/stylesheet.aspx?ID=') >= 0 )
		{
			arrLinks[i].parentNode.removeChild(arrLinks[i]);
			break;
		}
	}
	if ( !bStylesheetExists )
	{
		document.head.appendChild(link);
	}
}

export function RenumberPages(row)
{
	if ( row.RENUMBER_PAGES === undefined )
		row.RENUMBER_PAGES = true;
	if ( row.RENUMBER_PAGES )
	{
		let nQUESTION_OFFSET: number = 0;
		if ( row.SURVEY_PAGES != null )
		{
			for ( let i: number = 0; i < row.SURVEY_PAGES.length; i++ )
			{
				let rowPAGE: any = row.SURVEY_PAGES[i];
				rowPAGE.PAGE_NUMBER = i + 1;
				rowPAGE.QUESTION_OFFSET = nQUESTION_OFFSET;
			
				let nNON_QUESTIONS: number = 0;
				for ( let j: number = 0; j < rowPAGE.SURVEY_QUESTIONS.length; j++ )
				{
					let rowQUESTION: any = rowPAGE.SURVEY_QUESTIONS[j];
					// 06/13/2013 Paul.  Plain Text and Images do not get question numbers. 
					// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population. 
					if ( rowQUESTION.QUESTION_TYPE == 'Plain Text' || rowQUESTION.QUESTION_TYPE == 'Image' || rowQUESTION.QUESTION_TYPE == 'Hidden' )
						nNON_QUESTIONS++;
				}
				nQUESTION_OFFSET += rowPAGE.SURVEY_QUESTIONS.length - nNON_QUESTIONS;
			}
		}
		row.RENUMBER_PAGES = false;
	}
}

export function RenumberQuestions(row)
{
	if ( row.RENUMBER_QUESTIONS === undefined )
		row.RENUMBER_QUESTIONS = true;
	if ( row.RENUMBER_QUESTIONS )
	{
		let nNON_QUESTIONS  : number = 0;
		let nQUESTION_OFFSET: number = row.QUESTION_OFFSET;
		if ( row.SURVEY_QUESTIONS != null )
		{
			for ( let i: number = 0; i < row.SURVEY_QUESTIONS.length; i++ )
			{
				let rowQUESTION: any = row.SURVEY_QUESTIONS[i];
				// 06/13/2013 Paul.  Plain Text and Images do not get question numbers. 
				// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population. 
				if ( rowQUESTION.QUESTION_TYPE == 'Plain Text' || rowQUESTION.QUESTION_TYPE == 'Image' || rowQUESTION.QUESTION_TYPE == 'Hidden' )
				{
					nNON_QUESTIONS++;
					rowQUESTION.QUESTION_NUMBER = 0;
				}
				else
				{
					rowQUESTION.QUESTION_NUMBER = nQUESTION_OFFSET + i + 1 - nNON_QUESTIONS;
				}
			}
		}
		row.RENUMBER_QUESTIONS = false;
	}
}

export function OneQuestionPerPage(SURVEY_PAGES)
{
	let MOBILE_SURVEY_PAGES: any[] = new Array();
	if ( SURVEY_PAGES != null )
	{
		for ( let i: number = 0; i < SURVEY_PAGES.length; i++ )
		{
			let rowSURVEY_PAGE = SURVEY_PAGES[i];
			if ( rowSURVEY_PAGE.SURVEY_QUESTIONS != null )
			{
				for ( let j: number = 0; j < rowSURVEY_PAGE.SURVEY_QUESTIONS.length; j++ )
				{
					let rowSURVEY_QUESTION: any = rowSURVEY_PAGE.SURVEY_QUESTIONS[j];
					let rowMOBILE_PAGE    : any = new Object();
					rowMOBILE_PAGE.ID                     = rowSURVEY_PAGE.ID                    ;
					rowMOBILE_PAGE.SURVEY_ID              = rowSURVEY_PAGE.SURVEY_ID             ;
					rowMOBILE_PAGE.NAME                   = rowSURVEY_PAGE.NAME                  ;
					rowMOBILE_PAGE.PAGE_NUMBER            = rowSURVEY_PAGE.PAGE_NUMBER           ;
					rowMOBILE_PAGE.QUESTION_RANDOMIZATION = rowSURVEY_PAGE.QUESTION_RANDOMIZATION;
					rowMOBILE_PAGE.DESCRIPTION            = rowSURVEY_PAGE.DESCRIPTION           ;
					rowMOBILE_PAGE.RANDOMIZE_COUNT        = rowSURVEY_PAGE.RANDOMIZE_COUNT       ;
					rowMOBILE_PAGE.SURVEY_QUESTIONS       = new Array();
					rowMOBILE_PAGE.SURVEY_QUESTIONS.push(rowSURVEY_QUESTION);
					rowMOBILE_PAGE.MOBILE_ID              = rowSURVEY_QUESTION.ID;
					MOBILE_SURVEY_PAGES.push(rowMOBILE_PAGE);
				}
			}
		}
	}
	return MOBILE_SURVEY_PAGES;
}

export function MergeHiddenQuestions(SURVEY_PAGES)
{
	let HIDDEN_QUESTIONS: any[] = new Array();
	if ( SURVEY_PAGES != null )
	{
		for ( let i: number = SURVEY_PAGES.length - 1; i >= 0 ; i-- )
		{
			let rowSURVEY_PAGE: any = SURVEY_PAGES[i];
			if ( rowSURVEY_PAGE.SURVEY_QUESTIONS != null )
			{
				for ( let j: number = rowSURVEY_PAGE.SURVEY_QUESTIONS.length - 1; j >= 0; j-- )
				{
					let rowSURVEY_QUESTION: any = rowSURVEY_PAGE.SURVEY_QUESTIONS[j];
					if ( rowSURVEY_QUESTION.QUESTION_TYPE == 'Hidden' )
					{
						HIDDEN_QUESTIONS.push(rowSURVEY_QUESTION);
						rowSURVEY_PAGE.SURVEY_QUESTIONS.splice(j, 1);
					}
				}
				if ( rowSURVEY_PAGE.SURVEY_QUESTIONS.length == 0 )
				{
					SURVEY_PAGES.splice(i, 1);
				}
			}
		}
	}
	if ( HIDDEN_QUESTIONS.length > 0 )
	{
		for ( let j: number = 0; j < HIDDEN_QUESTIONS.length; j++ )
		{
			let rowSURVEY_QUESTION: any = HIDDEN_QUESTIONS[j];
			SURVEY_PAGES[0].SURVEY_QUESTIONS.push(rowSURVEY_QUESTION);
		}
	}
	return SURVEY_PAGES;
}

export function RandomizePages(row)
{
	try
	{
		if ( row.RANDOMIZE_APPLIED === undefined )
			row.RANDOMIZE_APPLIED = false;
		if ( row.RANDOMIZE_COUNT === undefined )
			row.RANDOMIZE_COUNT = 0;
		if ( !row.RANDOMIZE_APPLIED )
		{
			if ( !Sql.IsEmptyString(row.PAGE_RANDOMIZATION) && row.SURVEY_PAGES != null && row.SURVEY_PAGES.length > 0 )
			{
				if ( row.SURVEY_PAGES.length > 1 )
				{
					if ( row.PAGE_RANDOMIZATION == 'Randomize' )
					{
						// http://stackoverflow.com/questions/2450954/how-to-randomize-a-javascript-array
						for ( var i = row.SURVEY_PAGES.length - 1; i > 0; i-- )
						{
							var j = Math.floor(Math.random() * (i + 1));
							var temp = row.SURVEY_PAGES[i];
							row.SURVEY_PAGES[i] = row.SURVEY_PAGES[j];
							row.SURVEY_PAGES[j] = temp;
						}
					}
					else if ( row.PAGE_RANDOMIZATION == 'Flip' )
					{
						if ( Sql.ToInteger(row.RANDOMIZE_COUNT) % 2 == 0 )
						{
							row.SURVEY_PAGES.reverse();
						}
					}
					else if ( row.PAGE_RANDOMIZATION == 'Rotate' )
					{
						var nRotateCount = Sql.ToInteger(row.RANDOMIZE_COUNT) % row.SURVEY_PAGES.length;
						for ( var i = 0; i < nRotateCount; i++ )
						{
							row.SURVEY_PAGES.push(row.SURVEY_PAGES.shift());
						}
					}
				}
			}
			row.RANDOMIZE_APPLIED = true;
		}
		this.RenumberPages();
	}
	catch(e)
	{
		throw new Error('Survey.Randomize: ' + e.message);
	}
}

