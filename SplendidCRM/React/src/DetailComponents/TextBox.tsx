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
import Sql                      from '../scripts/Sql'                ;
import L10n                     from '../scripts/L10n'               ;
import { NormalizeDescription } from '../scripts/EmailUtils'         ;
// 4. Components and Views. 

interface ISplendidTextBoxState
{
	ID          : string;
	FIELD_INDEX : number;
	DATA_FIELD  : string;
	DATA_VALUE  : string;
	ERASED      : boolean;
	CSS_CLASS?  : string;
}

export default class TextBox extends React.Component<IDetailComponentProps, ISplendidTextBoxState>
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
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let DATA_FORMAT      : string  = '';
		let ERASED           : boolean = false;

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT);
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				if ( row != null )
				{
					// 12/24/2012 Paul.  Use regex global replace flag. 
					// 05/14/2018 Paul.  id is set above. 
					//tdField.id = 'ctlDetailView_' + DATA_FIELD.replace(/\s/g, '_');
					DATA_VALUE = row[DATA_FIELD];
					// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
					if ( DATA_VALUE == null && props.ERASED_FIELDS.indexOf(DATA_FIELD) >= 0 )
					{
						ERASED = true;
					}
					// 04/29/2020 Paul.  The raw format is used in Emails.DetailView. 
					else if ( DATA_FORMAT != 'raw' )
					{
						DATA_VALUE = NormalizeDescription(DATA_VALUE);
						/*try
						{
							tdField.innerHTML = sDATA;
						}
						catch(error)
						{
							sDATA = row[DATA_FIELD];
							sDATA = sDATA.replace(/</g, '&lt;');
							sDATA = sDATA.replace(/>/g, '&gt;');
							let pre = React.createElement('pre', {}, sDATA);
							tdFieldChildren.push(pre);
						}*/
						// 09/09/2019 Paul.  Let HTML control take care of it. 
						//DATA_VALUE = DATA_VALUE.replace(/</g, '&lt;');
						//DATA_VALUE = DATA_VALUE.replace(/>/g, '&gt;');
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
			ID         ,
			FIELD_INDEX,
			DATA_FIELD ,
			DATA_VALUE ,
			ERASED     ,
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

	shouldComponentUpdate(nextProps: IDetailComponentProps, nextState: ISplendidTextBoxState)
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
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, ERASED, CSS_CLASS } = this.state;
		if ( layout == null )
		{
			return (<span>layout prop is null</span>);
		}
		else if ( Sql.IsEmptyString(DATA_FIELD) )
		{
			return (<span>DATA_FIELD is empty for TextBox FIELD_INDEX { FIELD_INDEX }</span>);
		}
		else if ( row == null )
		{
			return (<span>row is null for TextBox DATA_FIELD { DATA_FIELD }</span>);
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( layout.hidden )
		{
			return (<span></span>);
		}
		else if ( ERASED )
		{
			return (<span className="Erased">{ L10n.Term('DataPrivacy.LBL_ERASED_VALUE') }</span>);
		}
		else
		{
			let html = { __html: DATA_VALUE };
			return (<span id={ ID } key={ ID } dangerouslySetInnerHTML={ html } className={ CSS_CLASS } style={ {width: '100%', height: '100%'} } />);
		}
	}
}

