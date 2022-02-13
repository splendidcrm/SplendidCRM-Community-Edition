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
import ISurveyQuestionProps                     from '../types/ISurveyQuestionProps';
import SurveyQuestion                           from './SurveyQuestion'             ;
// 3. Scripts. 
import Sql                                      from '../scripts/Sql'               ;
import Credentials                              from '../scripts/Credentials'       ;
// 4. Components and Views. 

interface IPlainTextState
{
	ID               : string;
	IMAGE_URL        : string;
	ANSWER_CHOICES   : string;
}

export default class Image extends SurveyQuestion<ISurveyQuestionProps, IPlainTextState>
{
	public get data(): any
	{
		return null;
	}

	public validate(): boolean
	{
		return true;
	}

	public setFocus(): void
	{
	}

	public isFocused(): boolean
	{
		return false;
	}

	constructor(props: ISurveyQuestionProps)
	{
		super(props);
		const { row, displayMode } = props;
		let ID            : string = null;
		let IMAGE_URL     : string = null;
		let ANSWER_CHOICES: string = null;
		if ( row )
		{
			// 07/11/2021 Paul.  ID will be null in sample mode. 
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
			ANSWER_CHOICES = row.ANSWER_CHOICES;
			IMAGE_URL      = Sql.ToString(row.IMAGE_URL);
			if ( displayMode == 'Sample' && Sql.IsEmptyString(IMAGE_URL) )
			{
				IMAGE_URL = '~/Include/images/SplendidCRM_Logo.gif';
			}
			IMAGE_URL = Sql.ToString(IMAGE_URL).replace('~/', Credentials.RemoteServer);
		}
		this.state =
		{
			ID            ,
			IMAGE_URL     ,
			ANSWER_CHOICES,
		};
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
		const { displayMode, row } = this.props;
		const { ID, IMAGE_URL, ANSWER_CHOICES } = this.state;
		// 11/24/2018 Paul.  Place image caption in ANSWER_CHOICES. 
		if ( row )
		{
			let html = { __html: Sql.ToString(ANSWER_CHOICES) };
			// 07/13/2021 Paul.  Show the header in sample mode. 
			return (
				<React.Fragment>
					{ displayMode == 'Sample'
					? this.RenderHeader()
					: null
					}
					{ !Sql.IsEmptyString(IMAGE_URL)
					? <img id={ ID } key={ ID } className='SurveyAnswerImage' src={ IMAGE_URL } />
					: null
					}
					{ html
					? <div id={ ID + '_caption' } key={ ID + '_caption' } className='SurveyAnswerPlainText' dangerouslySetInnerHTML={ html } />
					: null
					}
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

	public Summary = () =>
	{
		return null;
	}
}

