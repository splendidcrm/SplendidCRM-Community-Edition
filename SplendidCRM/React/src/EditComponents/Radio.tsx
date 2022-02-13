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
import { IEditComponentProps, EditComponent } from '../types/EditComponent';
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'        ;
import L10n                                   from '../scripts/L10n'       ;
import { Crm_Config }                         from '../scripts/Crm'        ;
// 4. Components and Views. 

interface IRadioState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	DATA_VALUE       : string;
	DATA_FORMAT      : string;
	LIST_NAME        : string;
	LIST_VALUES      : string[];
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	FORMAT_ROWS      : number;
	VALUE_MISSING    : boolean;
	ENABLED          : boolean;
	CSS_CLASS?       : string;
}

export default class Radio extends EditComponent<IEditComponentProps, IRadioState>
{
	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		return { key: DATA_FIELD, value: DATA_VALUE };
	}

	public validate(): boolean
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, VALUE_MISSING, ENABLED } = this.state;
		let bVALUE_MISSING: boolean = false;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.props.bIsHidden )
		{
			bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE);
			if ( bVALUE_MISSING != VALUE_MISSING )
			{
				this.setState({VALUE_MISSING: bVALUE_MISSING});
			}
			if ( bVALUE_MISSING && UI_REQUIRED )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.validate ' + DATA_FIELD);
			}
		}
		return !bVALUE_MISSING;
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.setState({ DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'enabled' )
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
		// 01/11/2020.  Apply Field Level Security. 
		if ( ENABLED )
		{
			this.setState(
			{
				DATA_VALUE: null
			});
		}
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number   = 0;
		let DATA_FIELD       : string   = null;
		// 02/10/20202 Paul.  We prefer to return null instead of empty string when nothing selected. 
		let DATA_VALUE       : string   = null;
		let DATA_FORMAT      : string   = null;
		let LIST_NAME        : string   = null;
		let LIST_VALUES      : string[] = [];
		let UI_REQUIRED      : boolean  = null;
		let FORMAT_TAB_INDEX : number   = null;
		let FORMAT_ROWS      : number   = null;
		let ENABLED          : boolean  = props.bIsWriteable;

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX     );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD      );
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT     );
				LIST_NAME         = Sql.ToString (layout.LIST_NAME       );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED     ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX);
				FORMAT_ROWS       = Sql.ToInteger(layout.FORMAT_ROWS     );
				ID = baseId + '_' + DATA_FIELD;
				if ( !Sql.IsEmptyString(LIST_NAME) )
				{
					LIST_VALUES = L10n.GetList(LIST_NAME);
					if ( row != null )
					{
						DATA_VALUE = this.getValue(layout, row, DATA_FIELD);
					}
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_FIELD, row);
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
			DATA_FORMAT      ,
			LIST_NAME        ,
			LIST_VALUES      ,
			UI_REQUIRED      ,
			FORMAT_TAB_INDEX ,
			FORMAT_ROWS      ,
			VALUE_MISSING    : false,
			ENABLED          ,
			CSS_CLASS        : 'radio'
		};
		//document.components[sID] = this;
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
	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: IRadioState)
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
			//console.log((new Date()).toISOString() + ' ' + 'TextBox.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.DATA_VALUE != this.state.DATA_VALUE )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.VALUE_MISSING != this.state.VALUE_MISSING || nextState.ENABLED != this.state.ENABLED )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, VALUE_MISSING, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		return false;
	}

	componentDidCatch(error, info)
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch ' + DATA_FIELD, error, info);
	}

	private getValue = (layout: any, row: any, DATA_FIELD: string): string =>
	{
		// 02/10/20202 Paul.  We prefer to return null instead of empty string when nothing selected. 
		let DATA_VALUE : string = null;
		if ( layout != null && row != null )
		{
			if ( row[DATA_FIELD] != null )
			{
				DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue ' + DATA_FIELD, DATA_VALUE, row);
		return DATA_VALUE;
	}

	private _onChange = (value): void =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.setState({ DATA_VALUE: value }, this.validate);
				onChanged(DATA_FIELD, value);
				onUpdate (DATA_FIELD, value);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, DATA_FORMAT, LIST_NAME, LIST_VALUES, UI_REQUIRED, FORMAT_TAB_INDEX, FORMAT_ROWS, VALUE_MISSING, ENABLED, CSS_CLASS } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, DATA_VALUE, LIST_VALUES);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for Radio FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for Radio DATA_FIELD { DATA_FIELD }</span>);
			}
			else if ( Sql.IsEmptyString(LIST_NAME) )
			{
				return (<div>LIST_NAME is null for Radio DATA_FIELD { DATA_FIELD }</div>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				let cssList: any = {};
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
				let styCheckbox = {transform: 'scale(1.5)', marginTop: '2px', marginBottom: '6px'};
				if ( Crm_Config.ToBoolean('enable_legacy_icons') )
				{
					styCheckbox.transform = 'scale(1.0)';
					styCheckbox.marginBottom = '2px';
				}

				let arrOptions = [];
				for ( let i in LIST_VALUES )
				{
					let option: any = {};
					option.key = Sql.ToString(LIST_VALUES[i]);
					option.text = L10n.ListTerm(LIST_NAME, LIST_VALUES[i]);
					// 03/24/2021 Paul.  Data value may be null or a number, so we must convert to string. 
					option.checked = (Sql.ToString(DATA_VALUE) == Sql.ToString(LIST_VALUES[i]));
					arrOptions.push(option);
				}
				if ( FORMAT_ROWS > 0 )
				{
					cssList.height = FORMAT_ROWS.toString() + 'px';
					cssList.overflowY = 'auto';
				}
				return (
					<span style={ cssList }>
						<div style={ {lineHeight: '1.4em'} }>
						{
							arrOptions.map((item, index) => 
							{
								// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
								return (<div>
									<input
										style={ styCheckbox }
										type='radio'
										className={ CSS_CLASS }
										id={ID + '_' + index.toString()}
										key={ID + '_' + index.toString()}
										value={ item.key }
										checked={ item.checked }
										onClick={ () => this._onChange(item.key) }
										disabled={ !ENABLED }
									/>
									<label style={ {marginLeft: '4px'} } htmlFor={ID + '_' + index.toString()}>{ item.text }</label>
								</div>);
							})
						}
						</div>
						{ UI_REQUIRED ? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className="required" style={cssRequired} >{L10n.Term('.ERR_REQUIRED_FIELD')}</span> : null}
					</span>);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.render', error);
			return (<span>{ error.message }</span>);
		}
	}
}

