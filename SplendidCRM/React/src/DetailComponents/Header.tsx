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
import L10n                  from '../scripts/L10n'               ;
// 4. Components and Views. 

interface IHeaderState
{
	ID          : string;
	FIELD_INDEX : number;
	DATA_LABEL  : string;
	DATA_VALUE  : string;
	CSS_CLASS?  : string;
}

export default class Header extends React.Component<IDetailComponentProps, IHeaderState>
{
	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.setState({ DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.setState({ CSS_CLASS: DATA_VALUE });
		}
	}

	constructor(props: IDetailComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number = 0;
		let DATA_LABEL       : string = '';
		let DATA_VALUE       : string = '';

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				// 09/03/2012 Paul.  A header is similar to a label, but without the data field. 
				DATA_LABEL        = Sql.ToString (layout.DATA_LABEL );
				ID = baseId + '_' + layout.FIELD_TYPE + '_' + layout.FIELD_INDEX;
				
				if ( row != null )
				{
					if ( DATA_LABEL.indexOf('.') >= 0 )
					{
						DATA_VALUE = L10n.Term(DATA_LABEL);
					}
					else if ( !Sql.IsEmptyString(DATA_LABEL) )
					{
						// 06/21/2015 Paul.  Label can contain raw text. 
						DATA_VALUE = DATA_LABEL;
					}
					// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
					DATA_VALUE = Sql.ReplaceEntities(DATA_VALUE);
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_LABEL, DATA_VALUE, row);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			ID         ,
			FIELD_INDEX,
			DATA_LABEL ,
			DATA_VALUE ,
		};
	}

	async componentDidMount()
	{
		const { layout } = this.props;
		if ( this.props.fieldDidMount )
		{
			this.props.fieldDidMount(layout.DATA_LABEL, this);
		}
	}

	shouldComponentUpdate(nextProps: IDetailComponentProps, nextState: IHeaderState)
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
		const { ID, FIELD_INDEX, DATA_LABEL, DATA_VALUE, CSS_CLASS } = this.state;
		if ( layout == null )
		{
			return (<span>layout prop is null</span>);
		}
		else if ( Sql.IsEmptyString(DATA_LABEL) )
		{
			return (<span>DATA_LABEL is empty for Header FIELD_INDEX { FIELD_INDEX }</span>);
		}
		else if ( row == null )
		{
			return (<span>row is null for Header DATA_LABEL { DATA_LABEL }</span>);
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( layout.hidden )
		{
			return (<span></span>);
		}
		else
		{
			return (<h4 id={ ID } key={ ID } className={ CSS_CLASS }>{ DATA_VALUE }</h4>);
		}
	}
}

