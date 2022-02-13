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
// 4. Components and Views. 

interface IPlainTextState
{
	ID               : string;
}

export default class PlainText extends SurveyQuestion<ISurveyQuestionProps, IPlainTextState>
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
		const { displayMode, row } = props;
		let ID: string = null;
		// 07/11/2021 Paul.  ID will be null in sample mode. 
		if ( row )
		{
			// 07/28/2021 Paul.  Allow Preview mode for dynamic updates while editing question. 
			ID = (row.ID ? row.ID.replace(/-/g, '_') : null);
		}
		this.state =
		{
			ID,
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
		const { ID } = this.state;
		if ( row != null )
		{
			let html = { __html: Sql.ToString(row.DESCRIPTION) };
			// 07/13/2021 Paul.  Show the header in sample mode. 
			return (
				<React.Fragment>
					{ displayMode == 'Sample'
					? this.RenderHeader()
					: null
					}
					<div id={ ID } key={ ID } className='SurveyAnswerPlainText' dangerouslySetInnerHTML={ html } />
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

