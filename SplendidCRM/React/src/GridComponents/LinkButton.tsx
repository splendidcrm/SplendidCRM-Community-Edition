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
// 3. Scripts. 
import Sql                                       from '../scripts/Sql'          ;
import { Crm_Modules }                           from '../scripts/Crm'          ;
import { StartsWith }                            from '../scripts/utility'      ;
// 4. Components and Views. 

interface ILinkButtonProps
{
	row               : any;
	layout            : any;
	Page_Command?     : (sCommandName, sCommandArguments) => void;
}

interface ILinkButtonState
{
	DATA_FIELD  : string;
	URL_FIELD   : string;
	URL_FORMAT  : string;
	URL_TARGET  : string;
	URL_VALUE   : string;
	DISPLAY_NAME: string;
}

class LinkButton extends React.PureComponent<ILinkButtonProps, ILinkButtonState>
{
	constructor(props: ILinkButtonProps)
	{
		super(props);
		let DATA_FIELD  : string = '';
		let URL_FIELD   : string = '';
		let URL_FORMAT  : string = '';
		let URL_TARGET  : string = '';
		let URL_VALUE   : string = '';
		let DISPLAY_NAME: string = '';
		try
		{
			const { layout, row } = this.props;
			if ( layout != null )
			{
				DATA_FIELD = Sql.ToString(layout.DATA_FIELD);
				URL_FIELD  = Sql.ToString(layout.URL_FIELD );
				URL_FORMAT = Sql.ToString(layout.URL_FORMAT);
				URL_TARGET = Sql.ToString(layout.URL_TARGET);
				URL_VALUE  = URL_FORMAT;
				if ( row )
				{
					if ( URL_FIELD.indexOf(' ') > 0 || URL_VALUE.indexOf('{') >= 0 )
					{
						let arrURL_FIELD: string[] = URL_FIELD.split(' ');
						for ( let nFormatIndex = 0; nFormatIndex < arrURL_FIELD.length; nFormatIndex++ )
						{
							URL_VALUE = URL_VALUE.replace('{' + nFormatIndex.toString() + '}', Sql.ToString(row[arrURL_FIELD[nFormatIndex]]));
						}
					}
					else
					{
						URL_VALUE = Sql.ToString(row[URL_FIELD]);
					}
					if (row[DATA_FIELD] !== undefined)
					{
						DISPLAY_NAME = Sql.ReplaceEntities(row[DATA_FIELD]);
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + URL_MODULE + ' ' + DATA_FIELD, URL);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			DATA_FIELD  ,
			URL_FIELD   ,
			URL_TARGET  ,
			URL_FORMAT  ,
			URL_VALUE   ,
			DISPLAY_NAME,
		};
	}

	async componentDidMount()
	{
		try
		{
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			// 05/20/2018 Paul.  When an error is encountered, we display the error in the name. 
			// 11/17/2021 Paul.  Must use message text and not error object. 
			this.setState({ DISPLAY_NAME: error.message });
		}
	}

	private _onClick = (e) =>
	{
		const { row, layout, Page_Command } = this.props;
		const { URL_TARGET, URL_VALUE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClick ' + URL_TARGET, URL_VALUE);
		e.preventDefault();
		if ( Page_Command != null )
		{
			Page_Command(URL_TARGET, URL_VALUE);
		}
		return false;
	}

	public render()
	{
		const { layout, row } = this.props;
		const { DATA_FIELD, DISPLAY_NAME } = this.state;
		if ( layout == null )
		{
			return (<div>layout prop is null</div>);
		}
		else if ( Sql.IsEmptyString(DATA_FIELD) )
		{
			return (<div>DATA_FIELD is empty for FIELD_INDEX { layout.FIELD_INDEX }</div>);
		}
		else
		{
			// 07/09/2019 Paul.  Use span instead of a tag to prevent navigation. 
			return <a href='#' onClick={ this._onClick } style={ {cursor: 'pointer'} }>{ DISPLAY_NAME }</a>;
		}
	}
}

export default LinkButton;
