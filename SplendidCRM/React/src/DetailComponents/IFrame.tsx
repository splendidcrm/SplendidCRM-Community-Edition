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

interface IFrameState
{
	ID            : string;
	FIELD_INDEX   : number;
	DATA_FIELD?   : string;
	DATA_VALUE?   : string;
	IFRAME_HEIGHT?: string;
	IFRAME_SRC?   : string;
	CSS_CLASS?    : string;
}

export default class IFrame extends React.Component<IDetailComponentProps, IFrameState>
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
		let DATA_FIELD       : string = '';
		let DATA_VALUE       : string = '';
		let URL_FIELD        : string = '';
		let URL_FORMAT       : string = '';
		let IFRAME_HEIGHT    : string = '';
		let IFRAME_SRC       : string = '';

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				IFRAME_HEIGHT     = Sql.ToString (layout.URL_TARGET );
				URL_FIELD         = Sql.ToString (layout.URL_FIELD  );
				URL_FORMAT        = Sql.ToString (layout.URL_FORMAT );
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				if ( Sql.IsEmptyString(IFRAME_HEIGHT) )
				{
					IFRAME_HEIGHT = '200';
				}
				if ( !Sql.IsEmptyString(URL_FIELD) )
				{
					IFRAME_SRC = URL_FORMAT;
					if ( row != null )
					{
						// 03/20/2016 Paul.  Need to protect against null strings. 
						let arrURL_FORMAT = Sql.ToString(URL_FORMAT).split(' ');
						let arrURL_FIELD  = Sql.ToString(URL_FIELD).split(' ');
						for ( let nFormatIndex = 0; nFormatIndex < arrURL_FIELD.length; nFormatIndex++ )
						{
							if ( row[arrURL_FIELD[nFormatIndex]] == null )
							{
								IFRAME_SRC = IFRAME_SRC.replace('{' + nFormatIndex.toString() + '}', '');
							}
							else
							{
								let URL_VALUE: string = row[arrURL_FIELD[nFormatIndex]];
								URL_VALUE  = FromJsonDate(URL_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
								IFRAME_SRC = IFRAME_SRC.replace('{' + nFormatIndex.toString() + '}', Sql.EscapeJavaScript(URL_VALUE));
							}
						}
					}
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			ID           ,
			FIELD_INDEX  ,
			DATA_FIELD   ,
			DATA_VALUE   ,
			IFRAME_HEIGHT,
			IFRAME_SRC   ,
			CSS_CLASS    : 'embed-responsive-item',
		};
	}

	async componentDidMount()
	{
		const { DATA_FIELD } = this.state;
		if ( this.props.fieldDidMount )
		{
			this.props.fieldDidMount(DATA_FIELD, this);
		}
	}

	shouldComponentUpdate(nextProps: IDetailComponentProps, nextState: IFrameState)
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		if ( nextProps.row != this.props.row )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextProps.layout != this.props.layout )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( nextProps.bIsHidden != this.props.bIsHidden )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.DATA_VALUE != this.state.DATA_VALUE)
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS)
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		return false;
	}

	public render()
	{
		const { baseId, layout, row } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, IFRAME_HEIGHT, IFRAME_SRC, CSS_CLASS } = this.state;
		if ( layout == null )
		{
			return (<span>layout prop is null</span>);
		}
		else if ( Sql.IsEmptyString(DATA_FIELD) )
		{
			return (<span>DATA_FIELD is empty for IFrame FIELD_INDEX { FIELD_INDEX }</span>);
		}
		else if ( row == null )
		{
			return (<span>row is null for IFrame DATA_FIELD { DATA_FIELD }</span>);
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( layout.hidden )
		{
			return (<span></span>);
		}
		else
		{
			return (
			<div id={ ID } key={ ID } className='embed-responsive'>
					<iframe src={ IFRAME_SRC } className={ CSS_CLASS } height={ IFRAME_HEIGHT } width='100%' />
			</div>
			);
		}
	}
}

