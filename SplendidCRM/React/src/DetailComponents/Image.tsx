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
import Credentials           from '../scripts/Credentials'        ;
import { Crm_Modules }       from '../scripts/Crm'                ;
import { Trim, inArray }     from '../scripts/utility'            ;
// 4. Components and Views. 

interface IImageState
{
	ID          : string;
	FIELD_INDEX : number;
	DATA_FIELD  : string;
	DATA_VALUE  : string;
	DISPLAY_NAME: string;
	URL         : string;
	CSS_CLASS?  : string;
	WIDTH       : string;
	HEIGHT      : string;
}

export default class Image extends React.Component<IDetailComponentProps, IImageState>
{
	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.setState({ DISPLAY_NAME: DATA_VALUE });
		}
		if ( PROPERTY_NAME == 'URL' )
		{
			this.setState({ URL: DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.setState({ CSS_CLASS: DATA_VALUE });
		}
		// 02/22/2022 Paul.  Allow image to be formatted. 
		else if ( PROPERTY_NAME == 'width' )
		{
			this.setState({ WIDTH: DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'height' )
		{
			this.setState({ HEIGHT: DATA_VALUE });
		}
	}

	constructor(props: IDetailComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number = 0;
		let DATA_FIELD       : string = '';
		let DATA_VALUE       : string = '';
		let URL              : string = '';
		let DATA_FORMAT      : string = null;
		// 02/22/2022 Paul.  Allow image to be formatted. 
		let WIDTH            : string = null;
		let HEIGHT           : string = null;

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				// 02/22/2022 Paul.  Allow image to be formatted. 
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT);
				if ( !Sql.IsEmptyString(DATA_FORMAT) )
				{
					try
					{
						let arrDATA_FORMAT: string[] = DATA_FORMAT.split(';');
						for ( let i = 0; i < arrDATA_FORMAT.length; i++ )
						{
							let arrNAME_VALUE: string[] = arrDATA_FORMAT[i].split('=');
							if ( arrNAME_VALUE.length == 2 )
							{
								let sNAME : string = Trim(arrNAME_VALUE[0]);
								let sVALUE: string = Trim(arrNAME_VALUE[1]);
								if ( sNAME.toLowerCase() == "width" )
									WIDTH = sVALUE;
								else if ( sNAME.toLowerCase() == "height" )
									HEIGHT = sVALUE;
							}
						}
					}
					catch
					{
						// 02/22/2022 Paul.  Ignore any errors. 
					}
				}
				
				if ( row != null )
				{
					DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
					if ( !Sql.IsEmptyString(DATA_VALUE) )
					{
						URL = Credentials.RemoteServer + 'Images/Image.aspx?ID=' + DATA_VALUE;
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
			ID          ,
			FIELD_INDEX ,
			DATA_FIELD  ,
			DATA_VALUE  ,
			DISPLAY_NAME: DATA_VALUE,
			URL         ,
			WIDTH       ,
			HEIGHT      ,
		};
	}

	async componentDidMount()
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		try
		{
			// 03/21/2022 Paul.  No need to get the name if the value is null. 
			if ( !Sql.IsEmptyString(DATA_VALUE) )
			{
				let value = await Crm_Modules.ItemName('Images', DATA_VALUE);
				this.setState({ DISPLAY_NAME: value });
			}
			if ( this.props.fieldDidMount )
			{
				this.props.fieldDidMount(DATA_FIELD, this);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			// 05/20/2018 Paul.  When an error is encountered, we display the error in the name. 
			// 11/17/2021 Paul.  Must use message text and not error object. 
			this.setState({ DISPLAY_NAME: error.message });
		}
	}

	shouldComponentUpdate(nextProps: IDetailComponentProps, nextState: IImageState)
	{
		const { DATA_FIELD, DATA_VALUE, DISPLAY_NAME } = this.state;
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
			//console.log((new Date()).toISOString() + ' ' + 'TextBox.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.DATA_VALUE != this.state.DATA_VALUE )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.DISPLAY_NAME != this.state.DISPLAY_NAME )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DISPLAY_NAME, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS)
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		// 02/22/2022 Paul.  Allow image to be formatted. 
		else if ( nextState.WIDTH != this.state.WIDTH || nextState.HEIGHT != this.state.HEIGHT )
		{
			return true;
		}
		return false;
	}

	public render()
	{
		const { baseId, layout, row } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, DISPLAY_NAME, URL, CSS_CLASS, WIDTH, HEIGHT } = this.state;
		if ( layout == null )
		{
			return (<span>layout prop is null</span>);
		}
		else if ( Sql.IsEmptyString(DATA_FIELD) )
		{
			return (<span>DATA_FIELD is empty for Image FIELD_INDEX { FIELD_INDEX }</span>);
		}
		else if ( row == null )
		{
			return (<span>row is null for Image DATA_FIELD { DATA_FIELD }</span>);
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( layout.hidden )
		{
			return (<span></span>);
		}
		else if ( !Sql.IsEmptyString(DATA_VALUE) )
		{
			// 02/22/2022 Paul.  Allow image to be formatted. 
			return (<img id={ ID } key={ ID } src={ URL } title={ DISPLAY_NAME } className={ CSS_CLASS } width={ WIDTH } height={ HEIGHT } />);
		}
		else
		{
			return null;
		}
	}
}

