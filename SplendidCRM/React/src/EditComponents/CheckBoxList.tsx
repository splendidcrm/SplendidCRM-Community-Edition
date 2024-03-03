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
import { Form } from 'react-bootstrap';
import * as XMLParser from 'fast-xml-parser';
// 2. Store and Types. 
import { IEditComponentProps, EditComponent } from '../types/EditComponent';
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'        ;
import L10n                                   from '../scripts/L10n'       ;
import { StartsWith }                         from '../scripts/utility'    ;
import { Crm_Config }                         from '../scripts/Crm'        ;
// 4. Components and Views. 

interface ICheckBoxListState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	DATA_VALUE       : boolean[];
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

export default class CheckBoxList extends EditComponent<IEditComponentProps, ICheckBoxListState>
{
	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		if ( DATA_FIELD == 'REPEAT_DOW' )
		{
			let DOW_VALUE = '';
			for ( let i = 0; i < DATA_VALUE.length; i++ )
			{
				if ( DATA_VALUE[i] )
				{
					DOW_VALUE += i.toString();
				}
			}
			return { key: DATA_FIELD, value: DOW_VALUE };
		}
		else
		{
			return { key: DATA_FIELD, value: DATA_VALUE };
		}
	}

	public validate(): boolean
	{
		return true;
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
				DATA_VALUE: []
			});
		}
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number    = 0;
		let DATA_FIELD       : string    = '';
		let DATA_VALUE       : boolean[] = [];
		let DATA_FORMAT      : string    = '';
		let LIST_NAME        : string    = '';
		let LIST_VALUES      : string[]  = [];
		let UI_REQUIRED      : boolean   = null;
		let FORMAT_TAB_INDEX : number    = null;
		let FORMAT_ROWS      : number    = null;
		let ENABLED          : boolean = props.bIsWriteable;

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
					for ( let i = 0; i < LIST_VALUES.length; i++ )
					{
						DATA_VALUE.push(false);
					}
					if ( row != null )
					{
						DATA_VALUE = this.getValue(layout, row, DATA_FIELD, LIST_NAME);
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, LIST_VALUES, DATA_VALUE, row);
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
			DATA_FORMAT      ,
			LIST_NAME        ,
			LIST_VALUES      ,
			UI_REQUIRED      ,
			FORMAT_TAB_INDEX ,
			FORMAT_ROWS      ,
			VALUE_MISSING    : false,
			ENABLED          ,
		};
		//document.components[ID] = this;
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
	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: ICheckBoxListState)
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
		// 11/03/2019 Paul.  Use stringify to compare arrays. 
		else if ( JSON.stringify(nextState.DATA_VALUE) != JSON.stringify(this.state.DATA_VALUE) )
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

	private getValue = (layout: any, row: any, DATA_FIELD: string, LIST_NAME: string): boolean[] =>
	{
		let DATA_VALUE: boolean[] = [];
		if ( layout != null && row != null && !Sql.IsEmptyString(LIST_NAME) )
		{
			let LIST_VALUES: string[] = L10n.GetList(LIST_NAME);
			for ( let i = 0; i < LIST_VALUES.length; i++ )
			{
				DATA_VALUE.push(false);
			}
			if ( row[DATA_FIELD] != null )
			{
				// 08/10/2020 Paul.  Fix issue with duplicate field name. 
				let sDATA_VALUE: string = Sql.ToString(row[DATA_FIELD]);
				if ( !Sql.IsEmptyString(sDATA_VALUE) )
				{
					// 06/03/2018 Paul.  REPEAT_DOW is a special list that returns 0 = sunday, 1 = monday, etc. 
					if ( DATA_FIELD == 'REPEAT_DOW' )
					{
						for ( let i = 0; i < sDATA_VALUE.length; i++ )
						{
							let n = parseInt(sDATA_VALUE[i]);
							if ( n < DATA_VALUE.length )
							{
								DATA_VALUE[n] = true;
							}
						}
					}
					// 08/01/2013 Paul.  Expand XML values from CheckBoxList. 
					else if ( StartsWith(sDATA_VALUE, '<?xml') )
					{
						let xml = XMLParser.parse(sDATA_VALUE);
						if ( xml.Values && xml.Values.Value && Array.isArray(xml.Values.Value) )
						{
							let arrDATA_VALUES: string[] = xml.Values.Value;
							for ( let i = 0; i < arrDATA_VALUES.length; i++ )
							{
								let sValue = arrDATA_VALUES[i];
								let n = LIST_VALUES.indexOf(sValue);
								if ( n > -1 )
								{
									DATA_VALUE[n] = true;
								}
							}
						}
					}
				}
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue ' + DATA_FIELD, DATA_VALUE, row);
		return DATA_VALUE;
	}

	private _onChange = (ev: React.ChangeEvent<HTMLInputElement>, item: string, index: number) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, DATA_VALUE, LIST_VALUES, ENABLED } = this.state;
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				// 09/09/2019 Paul.  We need to modify a copy so that the shouldUpdate will fire. 
				let NEW_DATA_VALUE = DATA_VALUE.slice();
				// 06/04/2018 Paul.  Use slice so that we get a copy.  We should never update the state value directly. 
				if ( index < DATA_VALUE.length )
				{
					NEW_DATA_VALUE[index] = ev.target.checked;
				}
				if ( DATA_FIELD == 'REPEAT_DOW' )
				{
					let DOW_VALUE = '';
					for ( let i = 0; i < NEW_DATA_VALUE.length; i++ )
					{
						if ( NEW_DATA_VALUE[i] )
						{
							DOW_VALUE += i.toString();
						}
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, NEW_DATA_VALUE, DOW_VALUE);
					this.setState({ DATA_VALUE: NEW_DATA_VALUE }, this.validate);
					onChanged(DATA_FIELD, DOW_VALUE);
					onUpdate (DATA_FIELD, DOW_VALUE);
				}
				else
				{
					let SELECTED_VALUES: string[] = [];
					for ( let i = 0; i < DATA_VALUE.length; i++ )
					{
						if ( DATA_VALUE[i] && i < LIST_VALUES.length )
						{
							SELECTED_VALUES.push(LIST_VALUES[i]);
						}
					}
					// 06/08/2018 Paul.  We don't need to convert to XML, just return the array of values. 
					/*
					if ( arrSELECTED_VALUES.length > 0 )
					{
						// 06/04/2018 Paul.  Build XML string as the value. 
						DATA_VALUE = '<?xml version=\"1.0\" encoding=\"utf-8\"?>';
						DATA_VALUE += '<Values>';
						for ( let i = 0; i < arrSELECTED_VALUES.length; i++ )
						{
							DATA_VALUE += '<Value>' + Sql.EscapeEmail(arrSELECTED_VALUES[i]) + '</Value>';
						}
						DATA_VALUE += '</Values>';
					}
					*/
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, SELECTED_VALUES);
					this.setState({ DATA_VALUE }, this.validate);
					onChanged(DATA_FIELD, SELECTED_VALUES);
					onUpdate (DATA_FIELD, SELECTED_VALUES);
				}
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, DATA_VALUE);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for CheckBoxList FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for CheckBoxList DATA_FIELD { DATA_FIELD }</span>);
			}
			else if ( Sql.IsEmptyString(LIST_NAME) )
			{
				return (<div>LIST_NAME is null for CheckBoxList DATA_FIELD { DATA_FIELD }</div>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				let styList: any = {};
				// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
				let styCheckbox = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '6px' };
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
				if ( Crm_Config.ToBoolean('enable_legacy_icons') )
				{
					styCheckbox.transform = 'scale(1.0)';
					styCheckbox.marginBottom = '2px';
				}
				if (FORMAT_ROWS > 0)
				{
					styList.height = FORMAT_ROWS.toString() + 'px';
					styList.overflowY = 'auto';
				}
				return (
					<span id={ ID } style={ styList } className={ CSS_CLASS }>
						{
							LIST_VALUES.map((item, index) => 
							{
								//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD + '[' + item + '] ' + index + ' = ' + DATA_VALUE[index]);
								if (DATA_FORMAT != '1')
								{
									return (<div>
										<Form.Check
											id={ ID + '_' + item.toString() }
											key={ ID + '_' + item.toString() }
											label={ L10n.ListTerm(LIST_NAME, LIST_VALUES[index]) }
											checked={ DATA_VALUE[index] }
											style={ styCheckbox }
											onChange={ (ev: React.ChangeEvent<HTMLInputElement>) => this._onChange(ev, item, index) }
											disabled={ !ENABLED }
										/><br />
									</div>);
								}
								else
								{
									return (
										<Form.Check
											id={ ID + '_' + item.toString() }
											key={ ID + '_' + item.toString() }
											label={ L10n.ListTerm(LIST_NAME, LIST_VALUES[index]) }
											checked={ DATA_VALUE[index] }
											style={ styCheckbox }
											onChange={ (ev: React.ChangeEvent<HTMLInputElement>) => this._onChange(ev, item, index) }
											disabled={ !ENABLED }
										/>);
								}
							})
						}
						{ UI_REQUIRED ? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className="required" style={cssRequired} >{L10n.Term('.ERR_REQUIRED_FIELD')}</span> : null}
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

