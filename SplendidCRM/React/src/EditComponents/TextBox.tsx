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
import Security                               from '../scripts/Security'   ;
import { Crm_Config }                         from '../scripts/Crm'        ;
import { formatCurrency, formatNumber }       from '../scripts/Formatting' ;
// 4. Components and Views. 

interface ITextBoxState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	DATA_VALUE       : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	FORMAT_SIZE      : number;
	FORMAT_MAX_LENGTH: number;
	FORMAT_ROWS      : number;
	FORMAT_COLUMNS   : number;
	VALUE_MISSING    : boolean;
	ENABLED          : boolean;
	CSS_CLASS?       : string;
	// 10/05/2021 Paul.  Add support for regular expression validation. 
	FIELD_VALIDATOR_MESSAGE: string;
	VALIDATION_TYPE        : string;
	REGULAR_EXPRESSION     : string;
	VALIDATOR_FAILED       : boolean;
}

export default class TextBox extends EditComponent<IEditComponentProps, ITextBoxState>
{
	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		// 06/30/2019 Paul.  Return null instead of empty string. 
		let key   = DATA_FIELD;
		let value = DATA_VALUE;
		if ( Sql.IsEmptyString(value) )
		{
			value = null;
		}
		return { key, value };
	}

	private HasValidatorFailed = (DATA_VALUE: string): boolean =>
	{
		const { ENABLED, VALIDATION_TYPE, REGULAR_EXPRESSION, FIELD_VALIDATOR_MESSAGE } = this.state;
		let VALIDATOR_FAILED: boolean = false;
		if ( !Sql.IsEmptyString(DATA_VALUE) && VALIDATION_TYPE == 'RegularExpressionValidator' && !Sql.IsEmptyString(REGULAR_EXPRESSION) && !Sql.IsEmptyString(FIELD_VALIDATOR_MESSAGE) && ENABLED )
		{
			let regex = new RegExp(REGULAR_EXPRESSION);
			if ( !regex.test(DATA_VALUE) )
			{
				VALIDATOR_FAILED = true;
			}
		}
		return VALIDATOR_FAILED;
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
		// 10/05/2021 Paul.  Add support for regular expression validation. 
		if ( this.HasValidatorFailed(DATA_VALUE) )
		{
			bVALUE_MISSING = true;
			this.setState({VALUE_MISSING: bVALUE_MISSING, VALIDATOR_FAILED: true});
		}
		return !bVALUE_MISSING;
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		// 08/09/2019 Paul.  An example of a text update is a Postal Code change updating, City, State and Country. 
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
			// 02/02/2020 Paul.  input does not update when DATA_VALUE is set to null. 
			this.setState(
			{
				DATA_VALUE: '',
				VALIDATOR_FAILED: false,
			});
		}
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let FORMAT_SIZE      : number  = null;
		let FORMAT_MAX_LENGTH: number  = null;
		let FORMAT_ROWS      : number  = null;
		let FORMAT_COLUMNS   : number  = null;
		let ENABLED          : boolean = props.bIsWriteable;
		// 10/05/2021 Paul.  Add support for regular expression validation. 
		let FIELD_VALIDATOR_MESSAGE: string = null;
		let VALIDATION_TYPE        : string = null;
		let REGULAR_EXPRESSION     : string = null;

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this.props;
			if (layout != null)
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX      );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD       );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED      ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX );
				FORMAT_SIZE       = Sql.ToInteger(layout.FORMAT_SIZE      );
				FORMAT_MAX_LENGTH = Sql.ToInteger(layout.FORMAT_MAX_LENGTH);
				FORMAT_ROWS       = Sql.ToInteger(layout.FORMAT_ROWS      );
				FORMAT_COLUMNS    = Sql.ToInteger(layout.FORMAT_COLUMNS   );
				// 10/05/2021 Paul.  Add support for regular expression validation. 
				FIELD_VALIDATOR_MESSAGE = Sql.ToString (layout.FIELD_VALIDATOR_MESSAGE);
				VALIDATION_TYPE         = Sql.ToString (layout.VALIDATION_TYPE        );
				REGULAR_EXPRESSION      = Sql.ToString (layout.REGULAR_EXPRESSION     );
				ID = baseId + '_' + DATA_FIELD;

				if ( row != null )
				{
					DATA_VALUE = this.getValue(layout, row, DATA_FIELD);
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
			ID               ,
			FIELD_INDEX      ,
			DATA_FIELD       ,
			DATA_VALUE       ,
			UI_REQUIRED      ,
			FORMAT_TAB_INDEX ,
			FORMAT_SIZE      ,
			FORMAT_MAX_LENGTH,
			FORMAT_ROWS      ,
			FORMAT_COLUMNS   ,
			VALUE_MISSING    : false,
			ENABLED          ,
			// 10/05/2021 Paul.  Add support for regular expression validation. 
			FIELD_VALIDATOR_MESSAGE,
			VALIDATION_TYPE        ,
			REGULAR_EXPRESSION     ,
			VALIDATOR_FAILED : false,
		};
		//document.components[sID] = this;
	}

	componentDidCatch(error, info)
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch ' + DATA_FIELD, error, info);
	}

	// As soon as the render method has been executed the componentDidMount function is called. 
	async componentDidMount()
	{
		const { DATA_FIELD } = this.state;
		if ( this.props.fieldDidMount )
		{
			this.props.fieldDidMount(DATA_FIELD, this);
		}
	}

	// shouldComponentUpdate is not used with a PureComponent
	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: ITextBoxState)
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

	/*
	// Finally componentDidUpdate is called after the render method.
	componentDidUpdate(prevProps: IEditComponentProps, prevState: ITextBoxState)
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { DATA_FIELD, DATA_VALUE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate ' + DATA_FIELD, DATA_VALUE, prevProps, prevState);
		if ( prevProps.row != null && prevProps.row.ID === undefined )
		{
			let DATA_VALUE: string = this.getValue(layout, row, DATA_FIELD);
			// 06/03/2018 Paul.  Don't update state if it has not changed. 
			if ( DATA_VALUE != this.state.DATA_VALUE )
				this.setState({ DATA_VALUE: DATA_VALUE });
		}
	}
	*/

	private getValue = (layout: any, row: any, DATA_FIELD: string): string =>
	{
		let DATA_VALUE : string = '';
		if ( layout != null && row != null )
		{
			let FORMAT_ROWS = Sql.ToInteger(layout.FORMAT_ROWS);
			if ( FORMAT_ROWS == 0 )
			{
				// 09/10/2011 Paul.  Search fields can have multiple fields. 
				if ( row[DATA_FIELD] != null )
				{
					// 08/10/2020 Paul.  Having multiple fields does not make a difference in json as key still returns value. 
					/*
					if ( DATA_FIELD.indexOf(' ') > 0 )
					{
						let arrDATA_FIELD = DATA_FIELD.split(' ');
						for ( let nFieldIndex = 0; nFieldIndex < arrDATA_FIELD.length; nFieldIndex++ )
						{
							if ( row != null && row[arrDATA_FIELD[nFieldIndex]] != null )
							{
								DATA_VALUE = Sql.ToString(row[arrDATA_FIELD[nFieldIndex]]);
							}
						}
					}
					else
					*/
					{
						// 12/12/2022 Paul.  Need to format currencies. 
						let oNumberFormat = Security.NumberFormatInfo();
						if ( layout.DATA_FORMAT == '{0:c}' )
						{
							DATA_VALUE = formatNumber(row[DATA_FIELD], oNumberFormat);
						}
						// 12/12/2022 Paul.  ZipCode LONGITUDE/LATITUDE have format of 0.000000. 
						else if ( !Sql.IsEmptyString(layout.DATA_FORMAT) && layout.DATA_FORMAT.indexOf('0') >= 0 && layout.DATA_FORMAT.indexOf('.') >= 0 )
						{
							oNumberFormat.CurrencyDecimalDigits = layout.DATA_FORMAT.split('.')[1].length;
							DATA_VALUE = formatNumber(row[DATA_FIELD], oNumberFormat);
						}
						else
							DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
					}
				}
			}
			else
			{
				if ( row[DATA_FIELD] != null )
				{
					DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
				}
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue ' + DATA_FIELD, DATA_VALUE, row);
		return DATA_VALUE;
	}

	private _onChange = (e): void =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, ENABLED } = this.state;
		let value = e.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				// 10/05/2021 Paul.  Add support for regular expression validation. 
				// 10/05/2021 Paul.  There seems to be a race condition with respect to the validator.  Perform here as well. 
				this.setState({ DATA_VALUE: value, VALIDATOR_FAILED: this.HasValidatorFailed(value) }, this.validate);
				onChanged(DATA_FIELD, value);
				onUpdate (DATA_FIELD, value);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onKeyDown = (event) =>
	{
		const { onSubmit } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' && onSubmit != null )
		{
			onSubmit();
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		// 10/05/2021 Paul.  Add support for regular expression validation. 
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, UI_REQUIRED, FORMAT_TAB_INDEX, FORMAT_SIZE, FORMAT_MAX_LENGTH, FORMAT_ROWS, FORMAT_COLUMNS, VALUE_MISSING, ENABLED, CSS_CLASS, FIELD_VALIDATOR_MESSAGE, VALIDATOR_FAILED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, DATA_VALUE, row);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for TextBox FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for TextBox DATA_FIELD { DATA_FIELD }</span>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				let bEnableSpeech = Crm_Config.enable_speech();
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// 09/27/2020 Paul.  We need to be able to disable the default grow on TextBox. 
				// 11/10/2020 Paul.  We are having a problem with the text field extending into the next column instead of expanding the current column. 
				let cssFlexGrow: any = { flexGrow: 1, overflowX: 'hidden' };
				if ( this.props.bDisableFlexGrow )
				{
					cssFlexGrow = {};
				}
				if ( FORMAT_ROWS == 0 )
				{
					let cssInput: any = { marginRight: '4px' };
					if ( !ENABLED )
					{
						cssInput.backgroundColor = '#DDDDDD';
					}
					// 06/23/2020 Paul.  Make use of minimum width. 
					if ( FORMAT_SIZE > 0 )
					{
						// 01/04/2022 Paul.  Disable flex grow will also use fixed width instead of minimum width. 
						if ( this.props.bDisableFlexGrow )
							cssInput.width = (FORMAT_SIZE * 5).toString() + 'px';
						else
							cssInput.minWidth = (FORMAT_SIZE * 5).toString() + 'px';
					}
					// 04/28/2019 Paul.  Speech as been deprecated. 
					// 05/16/2018 Paul.  Defer submit key. 
					//if ( sSubmitID != null )
					//{
					//	txt.onkeypress = function(e)
					//	{
					//		return RegisterEnterKeyPress(e, sSubmitID);
					//	};
					//}
					// 09/15/2019 Paul.  Stop using FormControl so that we can use the existing Theme. 
					// 10/27/2020 Paul.  size is cause text field to overflow the parent, into the label on the right. 
					// 11/12/2020 Paul.  Do not turn auto-complete off.  Some customers like it. 
					return (
						<span className={ CSS_CLASS } style={ cssFlexGrow }>
							<input
								id={ ID }
								key={ ID }
								value={ DATA_VALUE }
								style={ cssInput }
								maxLength={ FORMAT_MAX_LENGTH > 0 ? FORMAT_MAX_LENGTH : null }
								tabIndex={ FORMAT_TAB_INDEX }
								type="text"
								onChange={ this._onChange }
								onKeyDown={ this._onKeyDown }
								disabled={ !ENABLED }
							/>
							{ UI_REQUIRED ? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className="required" style={cssRequired} >{L10n.Term('.ERR_REQUIRED_FIELD')}</span> : null }
							{ VALIDATOR_FAILED ? <span id={ ID + '_VALIDATOR' } key={ ID + '_VALIDATOR' } className='required' style={ cssRequired } >{ L10n.Term(FIELD_VALIDATOR_MESSAGE) }</span> : null }
						</span>
					);
				}
				else
				{
					// 08/31/2012 Paul.  Add support for speech. 
					// 04/28/2019 Paul.  Speech as been deprecated. 
					//let cssSpeech = { width: '15px', height: '20px', border: '0px', backgroundColor: 'transparent', verticalAlign: 'top', speech: 'speech', display: 'none' };
					// 03/19/2019 Paul.  Cannot specify maxLength as it is zero for multiline fields. 
					// 09/15/2019 Paul.  Stop using FormControl so that we can use the existing Theme. 
					return (
						<span className={ CSS_CLASS } style={ cssFlexGrow }>
							<textarea
								id={ ID }
								key={ ID }
								value={ DATA_VALUE }
								tabIndex={ FORMAT_TAB_INDEX }
								autoComplete='off'
								rows={ FORMAT_ROWS }
								cols={ FORMAT_COLUMNS }
								onChange={ this._onChange }
								disabled={ !ENABLED }
							/>
							{ UI_REQUIRED ? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className="required" style={cssRequired} >{L10n.Term('.ERR_REQUIRED_FIELD')}</span> : null }
							{ VALIDATOR_FAILED ? <span id={ ID + '_VALIDATOR' } key={ ID + '_VALIDATOR' } className='required' style={ cssRequired } >{ L10n.Term(FIELD_VALIDATOR_MESSAGE) }</span> : null }
						</span>
					);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.render', error);
			return (<span>{ error.message }</span>);
		}
	}
}

