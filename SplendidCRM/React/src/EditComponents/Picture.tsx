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
import { FontAwesomeIcon }                           from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
import { IEditComponentProps, EditComponent }        from '../types/EditComponent'      ;
// 3. Scripts. 
import Sql                                           from '../scripts/Sql'              ;
import L10n                                          from '../scripts/L10n'             ;
import Credentials                                   from '../scripts/Credentials'      ;
import { base64ArrayBuffer, StartsWith }             from '../scripts/utility'          ;
import { Crm_Config }                                from '../scripts/Crm'              ;
// 4. Components and Views. 
import ErrorComponent                                from '../components/ErrorComponent';

interface IPictureState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	DATA_VALUE       : string;  // This is the old guid value. 
	DISPLAY_URL      : string;
	FILE_NAME?       : string;
	NAME?            : string;
	TYPE?            : string;
	DATA?            : string;
	UI_REQUIRED      : boolean;
	VALUE_MISSING    : boolean;
	error?           : any;
	ENABLED          : boolean;
	CSS_CLASS?       : string;
}

export default class Picture extends EditComponent<IEditComponentProps, IPictureState>
{
	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE, NAME, TYPE, DATA } = this.state;
		let files = new Array();
		if ( !Sql.IsEmptyString(DATA) )
		{
			let image: any = new Object();
			let arrFileParts = NAME.split('.');
			image.DATA_FIELD     = DATA_FIELD;
			image.FILENAME       = NAME;
			image.FILE_EXT       = arrFileParts[arrFileParts.length - 1];
			image.FILE_MIME_TYPE = TYPE;
			image.FILE_DATA      = DATA;
			files.push(image);
		}
		return { key: DATA_FIELD, value: DATA_VALUE, files };
	}

	public validate(): boolean
	{
		const { DATA_FIELD, DATA_VALUE, DATA, UI_REQUIRED, VALUE_MISSING, ENABLED } = this.state;
		let bVALUE_MISSING: boolean = false;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.props.bIsHidden )
		{
			bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE) && Sql.IsEmptyString(DATA);
			if ( bVALUE_MISSING != VALUE_MISSING )
			{
				this.setState({VALUE_MISSING: bVALUE_MISSING});
			}
			if ( bVALUE_MISSING && UI_REQUIRED )
			{
				//console.log((new Date()).toISOString() + ' ' + 'File.validate ' + DATA_FIELD);
			}
		}
		return !bVALUE_MISSING;
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( PROPERTY_NAME == 'enabled' )
		{
			this.setState(
			{
				ENABLED: Sql.ToBoolean(DATA_VALUE)
			});
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.setState({ CSS_CLASS: DATA_VALUE });
		}
	}

	public clear(): void
	{
		const { ENABLED } = this.state;
		// 07/23/2019.  Apply Field Level Security. 
		if ( ENABLED )
		{
				// 07/02/2020 Paul.  Setting display value to null will not clear the image.  Set to blank string. 
			this.setState(
			{
				DATA_VALUE  : null,
				DISPLAY_URL : '',
				NAME        : null,
				TYPE        : null,
				DATA        : null,
			}, this.validate);
		}
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let DISPLAY_URL      : string  = '';
		let VALUE_MISSING    : boolean = false;
		let ENABLED          : boolean = props.bIsWriteable;

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				DATA_VALUE        = Sql.ToString (layout.DATA_VALUE );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED      ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				ID = baseId + '_' + DATA_FIELD;

				if ( row != null )
				{
					DATA_VALUE  = Sql.ToString(row[DATA_FIELD]);
					DISPLAY_URL = DATA_VALUE;
				}
				VALUE_MISSING = Sql.IsEmptyString(DATA_VALUE)
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			ID               ,
			FIELD_INDEX      ,
			DATA_FIELD       ,
			DATA_VALUE       ,
			UI_REQUIRED      ,
			DISPLAY_URL      ,
			VALUE_MISSING    ,
			ENABLED          ,
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

	// shouldComponentUpdate is not used with a PureComponent
	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: IPictureState)
	{
		const { DATA_FIELD, DATA_VALUE, VALUE_MISSING, ENABLED } = this.state;
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
		else if ( nextState.FILE_NAME != this.state.FILE_NAME )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		return false;
	}

	private _onChange = (e) =>
	{
		const { DATA_FIELD, ENABLED } = this.state;
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				let FILE_NAME: string = e.target.value;
				let files = e.target.files;
				if ( files.length > 0 )
				{
					let file = files[0];
					let nMaxSize: number = Crm_Config.ToInteger('upload_maxsize');
					if ( file.size > nMaxSize )
					{
						let error = 'uploaded file was too big: max filesize: ' + nMaxSize;
						this.setState({ error });
					}
					else
					{
						// http://www.javascripture.com/FileReader
						let reader = new FileReader();
						reader.onload = () =>
						{
							let arrayBuffer = reader.result;
							let NAME     : string = file.name;
							let TYPE     : string = file.type;
							let DATA     : string = base64ArrayBuffer(arrayBuffer);
							//console.log((new Date()).toISOString() + ' ' + 'Image ' + DATA_FIELD + ' ' + FILE_NAME + ' ' + TYPE, DATA);
							this.setState({ FILE_NAME, NAME, TYPE, DATA }, this.validate);
						};
						reader.readAsArrayBuffer(file);
					}
				}
				//this.setState({ DATA_VALUE }, this.validate);
				//onChanged(DATA_FIELD, DATA_VALUE);
				// 07/25/2019 Paul.  A file does not have dependent fields. 
				//onUpdate (DATA_FIELD, DATA_VALUE);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onClearClick = (): void =>
	{
		const { ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + 'File._onClearClick ' + DATA_FIELD + ' ' + DISPLAY_FIELD, DATA_VALUE, DISPLAY_VALUE, row);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				// 07/02/2020 Paul.  Setting display value to null will not clear the image.  Set to blank string. 
				this.setState(
				{
					DATA_VALUE  : null,
					DISPLAY_URL : '',
					FILE_NAME   : null,
					NAME        : null,
					TYPE        : null,
					DATA        : null,
				}, this.validate);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onClearClick', error);
			this.setState({ error });
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, UI_REQUIRED, DISPLAY_URL, VALUE_MISSING, ENABLED, FILE_NAME, CSS_CLASS, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if (Sql.IsEmptyString(DATA_FIELD))
			{
				return (<div>DATA_FIELD is empty for Image FIELD_INDEX { FIELD_INDEX }</div>);
			}
			else if ( onChanged == null )
			{
				return (<div>onChanged is null for Image DATA_FIELD { DATA_FIELD }</div>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				let fit: any = 'scale-down';  // ObjectFitProperty
				let cssRequired = { paddingLeft: '4px', display: ( VALUE_MISSING ? 'inline' : 'none') };
				let cssImage    = { objectFit: fit, width: '36px', height: '36px', marginRight: '4px' };
				// 09/21/2019 Paul.  d-lg-none to hide when large screen. 
				return (
					<span className={ CSS_CLASS }>
						{ DISPLAY_URL
						? <img src={ DISPLAY_URL } style={ cssImage } />
						: null
						}
						<input type="file"
							id={ ID }
							key={ ID }
							value={ FILE_NAME }
							onChange={ this._onChange }
							disabled={ !ENABLED }
						/>
						{ DATA_VALUE
						? <button
							id={ ID + '_btnClear' }
							key={ ID + '_btnClear' }
							style={ {marginLeft: '4px'} }
							onClick={ this._onClearClick }
							disabled={ !ENABLED }
							className='button'>
							<FontAwesomeIcon icon="times" className="d-lg-none" />
							<span className="d-none d-lg-inline">{ L10n.Term('.LBL_CLEAR_BUTTON_LABEL') }</span>
						</button>
						: null
						}
						<ErrorComponent error={ error } />
						{ UI_REQUIRED
						? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className="required" style={ cssRequired } >{ L10n.Term('.ERR_REQUIRED_FIELD') }</span>
						: null
						}
					</span>
				);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.render', error);
			return (<span>{ error.message }</span>);
		}
	}
}

