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
import { IDetailComponentProps, IDetailComponentState, DetailComponent } from '../types/DetailComponent';
// 3. Scripts. 
import Sql                   from '../scripts/Sql'                ;
import Security              from '../scripts/Security'           ;
import { FromJsonDate }      from '../scripts/Formatting'         ;
// 4. Components and Views. 

interface IJavaScriptState
{
	ID           : string;
	FIELD_INDEX  : number;
	URL_FIELD    : string;
	URL_FORMAT   : string;
	URL_TARGET   : string;
	CSS_CLASS?   : string;
}

export default class JavaScript extends React.Component<IDetailComponentProps, IJavaScriptState>
{
	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( PROPERTY_NAME == 'class' )
		{
			this.setState({ CSS_CLASS: DATA_VALUE });
		}
	}

	constructor(props: IDetailComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number = 0;
		let URL_FIELD        : string = '';
		let URL_FORMAT       : string = '';
		let URL_TARGET       : string = '';

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				URL_FIELD         = Sql.ToString (layout.URL_FIELD  );
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + URL_FIELD.replace(/\s/g, '_');
				
				if ( row != null )
				{
					if ( !Sql.IsEmptyString(URL_FORMAT) )
					{
						// 03/20/2016 Paul.  Need to protect against null strings. 
						let arrURL_FORMAT = Sql.ToString(URL_FORMAT).split(' ');
						let arrURL_FIELD  = Sql.ToString(URL_FIELD).split(' ');
						for ( let nFormatIndex = 0; nFormatIndex < arrURL_FIELD.length; nFormatIndex++ )
						{
							if ( row[arrURL_FIELD[nFormatIndex]] == null )
							{
								URL_FORMAT = Sql.ToString(URL_FORMAT).replace('{' + nFormatIndex.toString() + '}', '');
								URL_TARGET = Sql.ToString(URL_TARGET).replace('{' + nFormatIndex.toString() + '}', '');
							}
							else
							{
								let URL_VALUE: string = row[arrURL_FIELD[nFormatIndex]];
								URL_VALUE  = FromJsonDate(URL_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
								URL_FORMAT = Sql.ToString(URL_FORMAT).replace('{' + nFormatIndex.toString() + '}', Sql.EscapeJavaScript(URL_VALUE));
								URL_TARGET = Sql.ToString(URL_TARGET).replace('{' + nFormatIndex.toString() + '}', Sql.EscapeJavaScript(URL_VALUE));
							}
						}
						//eval(sURL_FORMAT);
					}
			}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + sURL_FIELD, sURL_FORMAT, row);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			ID         ,
			FIELD_INDEX,
			URL_FIELD  ,
			URL_FORMAT ,
			URL_TARGET ,
		};
	}

	componentDidMount()
	{
		const { URL_FORMAT, URL_TARGET } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount ' + URL_TARGET, URL_FORMAT, this.props.row);
		if ( !Sql.IsEmptyString(URL_FORMAT) )
		{
			try
			{
				eval(URL_FORMAT);
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			}
		}
	}

	// shouldComponentUpdate is not used with a PureComponent
	shouldComponentUpdate(nextProps: IDetailComponentProps, nextState: IJavaScriptState)
	{
		if ( nextState.CSS_CLASS != this.state.CSS_CLASS)
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		return false;
	}

	public render()
	{
		const { baseId, layout, row } = this.props;
		const { ID, FIELD_INDEX, URL_FIELD, URL_FORMAT, URL_TARGET, CSS_CLASS } = this.state;
		if ( layout == null )
		{
			return (<span>layout prop is null</span>);
		}
		else if ( Sql.IsEmptyString(URL_FIELD) )
		{
			return (<span>URL_FIELD is empty for JavaScript FIELD_INDEX { FIELD_INDEX }</span>);
		}
		else if ( row == null )
		{
			return (<span>row is null for JavaScript URL_FIELD { URL_FIELD }</span>);
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( layout.hidden )
		{
			return (<span></span>);
		}
		else
		{
			// 12/03/2009 Paul.  LinkedIn Company Profile requires a span tag to insert the link.
			if ( !Sql.IsEmptyString(URL_TARGET) )
				return (<span id={ URL_TARGET } key={ URL_TARGET } className={ CSS_CLASS }></span>);
			else
				return null;
		}
	}
}

