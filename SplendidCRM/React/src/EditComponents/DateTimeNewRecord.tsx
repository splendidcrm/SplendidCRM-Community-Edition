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
import moment from 'moment';
import DateTime from 'react-datetime';
import 'react-datetime/css/react-datetime.css';
// 2. Store and Types. 
import { IEditComponentProps, EditComponent }   from '../types/EditComponent';
// 3. Scripts. 
import Sql                                      from '../scripts/Sql'        ;
import L10n                                     from '../scripts/L10n'       ;
import Security                                 from '../scripts/Security'   ;
import { FromJsonDate, ToJsonDate, formatDate } from '../scripts/Formatting' ;
import { ValidateDateParts }                    from '../scripts/utility'    ;
// 4. Components and Views. 

interface IDateTimeNewRecordState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_VALUE?      : Date | null;
	DATA_FIELD       : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	TIME_VALUE       : string;
	DATE_FORMAT      : string;
	TIME_FORMAT      : string;
	VALUE_MISSING    : boolean;
	resetIndex       : number;
	error?           : string;
	ENABLED          : boolean;
	CSS_CLASS?       : string;
}

export default class DateTimeNewRecord extends EditComponent<IEditComponentProps, IDateTimeNewRecordState>
{
	private inputDate = React.createRef<HTMLInputElement>();
	private inputTime = React.createRef<HTMLInputElement>();

	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		return { key: DATA_FIELD, value: ToJsonDate(DATA_VALUE) };
	}

	public validate(): boolean
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, VALUE_MISSING, ENABLED } = this.state;
		let bVALUE_MISSING: boolean = false;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.props.bIsHidden )
		{
			bVALUE_MISSING = (DATA_VALUE == null);
			if ( bVALUE_MISSING != VALUE_MISSING )
			{
				this.setState({ VALUE_MISSING: bVALUE_MISSING });
			}
			if ( bVALUE_MISSING && UI_REQUIRED )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.validate ' + DATA_FIELD);
			}
		}
		if ( !bVALUE_MISSING && UI_REQUIRED )
		{
			let date: moment.Moment = moment(DATA_VALUE);
			if ( !date.isValid() )
			{
				this.setState({ error: L10n.Term('.ERR_INVALID_DATE') });
				bVALUE_MISSING = true;
			}
		}
		return !bVALUE_MISSING;
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.setState(
			{
				DATA_VALUE: (DATA_VALUE ? Sql.ToDateTime(DATA_VALUE) : null)
			});
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
				DATA_VALUE: null, 
				TIME_VALUE: null, 
				error     : null, 
				resetIndex: this.state.resetIndex+1
			});
		}
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number  = 0;
		let DATA_VALUE       : Date    = null;
		let DATA_FIELD       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let TIME_VALUE       : string  = '';
		let DATE_FORMAT      : string  = Security.USER_DATE_FORMAT();
		let TIME_FORMAT      : string  = Security.USER_TIME_FORMAT();
		let ENABLED          : boolean = props.bIsWriteable;
		if ( Sql.IsEmptyString(TIME_FORMAT) )
		{
			// 11/13/2020 Paul.  Change to moment format. 
			TIME_FORMAT= 'h:mm a';
		}

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX     );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD      );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED     ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX);
				ID = baseId + '_' + DATA_FIELD;

				if ( row != null )
				{
					DATA_VALUE = this.getValue(layout, row, DATA_FIELD);
					if ( DATA_VALUE !== null )
					{
						TIME_VALUE = formatDate(DATA_VALUE, TIME_FORMAT);
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
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
			DATA_VALUE       ,
			DATA_FIELD       ,
			UI_REQUIRED      ,
			FORMAT_TAB_INDEX ,
			TIME_VALUE       ,
			DATE_FORMAT      ,
			TIME_FORMAT      ,
			VALUE_MISSING    : false,
			ENABLED          ,
			resetIndex       : 0,
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

	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: IDateTimeNewRecordState)
	{
		const { DATA_FIELD, DATA_VALUE, TIME_VALUE, VALUE_MISSING, ENABLED } = this.state;
		if ( nextProps.row != this.props.row )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, TIME_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextProps.layout != this.props.layout )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, TIME_VALUE, nextProps, nextState);
			return true;
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( nextProps.bIsHidden != this.props.bIsHidden )
		{
			//console.log((new Date()).toISOString() + ' ' + 'TextBox.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if (nextState.DATA_VALUE != this.state.DATA_VALUE || nextState.TIME_VALUE != this.state.TIME_VALUE)
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, TIME_VALUE, nextProps, nextState);
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
		else if ( nextState.error != this.state.error )
		{
			return true;
		}
		return false;
	}

	componentDidCatch(error, info)
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch ' + DATA_FIELD, error, info);
	}

	private getValue = (layout: any, row: any, DATA_FIELD: string): Date =>
	{
		let DATA_VALUE: Date = null;
		if ( layout != null && row != null )
		{
			if ( row != null )
			{
				if ( row != null && row[DATA_FIELD] != null )
				{
					// 01/20/2021 Paul.  Include format so that it can convert a text string. 
					DATA_VALUE = FromJsonDate(row[DATA_FIELD], undefined, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
					// 03/27/2019 Paul.  Return null for zero year. 
					if ( DATA_VALUE != null && DATA_VALUE.getFullYear() == 0 )
					{
						DATA_VALUE = null;
					}
				}
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue ' + DATA_FIELD, DATA_VALUE, row);
		return DATA_VALUE;
	}

	private _onDateChange = (value: moment.Moment | null | undefined) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, DATA_VALUE, TIME_VALUE, DATE_FORMAT, TIME_FORMAT, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDateChange ' + DATA_FIELD, value);
		try
		{
			// https://devhints.io/moment
			// https://momentjs.com/docs/#/parsing/
			let mntValue: moment.Moment = null;
			if ( typeof(value) == 'string' )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDateChange string ' + DATA_FIELD, value);
				if ( Sql.IsEmptyString(value) )
				{
					// 11/17/2019 Paul.  Increment the reset index as clearing the control causes a NaN situation. 
					this.setState({ DATA_VALUE: null, error: null, resetIndex: this.state.resetIndex+1 }, this.validate);
					onChanged(DATA_FIELD, null);
					onUpdate (DATA_FIELD, null);
				}
				else
				{
					let bValidDateParts: boolean = ValidateDateParts(value, DATE_FORMAT);
					// 08/05/2019 Paul.  A moment will be valid, even with a single numeric value.  So require 3 parts. 
					mntValue = moment(value, DATE_FORMAT);
					if ( bValidDateParts && mntValue.isValid() )
					{
						let dtTIME_VALUE: moment.Moment = moment(TIME_VALUE, TIME_FORMAT, true);
						mntValue.set('hour'  , dtTIME_VALUE.hour()  );
						mntValue.set('minute', dtTIME_VALUE.minute());
						// 07/23/2019.  Apply Field Level Security. 
						if ( ENABLED )
						{
							let DATA_VALUE: Date   = mntValue.toDate();
							this.setState({ DATA_VALUE, error: null }, this.validate);
							onChanged(DATA_FIELD, mntValue);
							onUpdate (DATA_FIELD, mntValue);
						}
					}
					else
					{
						this.setState({ error: L10n.Term('.ERR_INVALID_DATE') });
					}
				}
			}
			else if ( value instanceof moment )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDateChange moment ' + DATA_FIELD, value);
				mntValue = moment(value);
				if ( mntValue.isValid() )
				{
					let dtTIME_VALUE: moment.Moment = moment(TIME_VALUE, TIME_FORMAT, true);
					mntValue.set('hour'  , dtTIME_VALUE.hour()  );
					mntValue.set('minute', dtTIME_VALUE.minute());
					// 07/23/2019.  Apply Field Level Security. 
					if ( ENABLED )
					{
						let DATA_VALUE: Date   = mntValue.toDate();
						this.setState({ DATA_VALUE, error: null }, this.validate);
						onChanged(DATA_FIELD, mntValue);
						onUpdate (DATA_FIELD, mntValue);
					}
				}
				else
				{
					this.setState({ error: L10n.Term('.ERR_INVALID_DATE') });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onDateChange', error);
		}
	}

	private _onTimeChange = (e): void =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, DATA_VALUE, TIME_VALUE, DATE_FORMAT, TIME_FORMAT, ENABLED } = this.state;
		let value = e.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTimeChange ' + DATA_FIELD, value);
		try
		{
			if ( DATA_VALUE != null )
			{
				// https://devhints.io/moment
				// https://momentjs.com/docs/#/parsing/
				let dtDATE_VALUE: moment.Moment = moment(DATA_VALUE);
				let dtTIME_VALUE: moment.Moment = moment(value, TIME_FORMAT, true);
				if ( dtTIME_VALUE.isValid() )
				{
					dtDATE_VALUE.set('hour'  , dtTIME_VALUE.hour()  );
					dtDATE_VALUE.set('minute', dtTIME_VALUE.minute());
					let dtDATE_TIME = dtDATE_VALUE.toDate();
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTimeChange ' + DATA_FIELD, formatDate(dtDATE_TIME, DATE_FORMAT + ' ' + TIME_FORMAT));
					// 07/23/2019.  Apply Field Level Security. 
					if ( ENABLED )
					{
						this.setState({ DATA_VALUE: dtDATE_TIME, TIME_VALUE: value }, this.validate);
						onChanged(DATA_FIELD, dtDATE_TIME);
						onUpdate (DATA_FIELD, dtDATE_TIME);
					}
				}
				else
				{
					this.setState({ TIME_VALUE: value, error: L10n.Term('.ERR_INVALID_DATE') });
				}
			}
			else
			{
				this.setState({ TIME_VALUE: value });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTimeChange', error);
		}
	}

	private _onDateBlur = (event) =>
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, TIME_VALUE, DATE_FORMAT, TIME_FORMAT, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDateBlur ' + DATA_FIELD, DATA_VALUE);
		// 08/05/2019 Paul.  Change the key so that the control will redraw using current DATE_VALUE. 
		if ( this.inputDate.current != null )
		{
			if ( DATA_VALUE == null )
			{
				let value = this.inputDate.current.value;
				if ( !Sql.IsEmptyString(value) )
				{
					let bValidDateParts: boolean = ValidateDateParts(value, DATE_FORMAT);
					let mntValue = moment(value, DATE_FORMAT);
					// 08/06/2019 Paul.  Only clear if invalid.  We need to allow user to tab to time field. 
					if ( bValidDateParts && mntValue.isValid() )
					{
						// 01/05/2021 Paul.  Must include time value. 
						let dtTIME_VALUE: moment.Moment = moment(TIME_VALUE, TIME_FORMAT, true);
						mntValue.set('hour'  , dtTIME_VALUE.hour()  );
						mntValue.set('minute', dtTIME_VALUE.minute());

						let DATA_VALUE: Date   = mntValue.toDate();
						this.setState({ DATA_VALUE, error: null }, this.validate);
					}
					else
					{
						this.inputDate.current.value = '';
					}
				}
			}
			if ( !UI_REQUIRED && error )
			{
				this.setState({ error: null });
			}
		}
	}

	private _onTimeBlur = (event) =>
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTimeBlur ' + DATA_FIELD, DATA_VALUE);
		// 08/05/2019 Paul.  Change the key so that the control will redraw using current DATE_VALUE. 
		if ( this.inputTime.current != null )
		{
			if ( DATA_VALUE == null )
			{
				this.inputTime.current.value = '';
			}
			if ( !UI_REQUIRED && error )
			{
				this.setState({ error: null });
			}
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
		const { ID, FIELD_INDEX, DATA_VALUE, DATA_FIELD, DATE_FORMAT, UI_REQUIRED, TIME_VALUE, TIME_FORMAT, FORMAT_TAB_INDEX, VALUE_MISSING, ENABLED, CSS_CLASS, resetIndex, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, DATA_VALUE, TIME_VALUE);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for DateTimeNewRecord FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for DateTimeNewRecord DATA_FIELD { DATA_FIELD }</span>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				// 06/23/2020 Paul.  Make use of minimum width. 
				let inputProps: any =
				{
					type        : 'text', 
					tabIndex    : FORMAT_TAB_INDEX,
					autoComplete: 'off',
					style       : {flex: '2 0 70%', width: '100%', minWidth: '150px'},
					onKeyDown   : this._onKeyDown,
					disabled    : !ENABLED,
					className   : null,  /* 12/10/2019 Paul.  Prevent the default form-control. */
					ref         : this.inputDate,
				};
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				let initialPickerDate: Date = DATA_VALUE;
				if ( initialPickerDate == null || initialPickerDate.getFullYear() == 0 )
				{
					initialPickerDate = new Date();
				}
				// https://github.com/YouCanBookMe/react-datetime
				// 11/17/2019 Paul.  Increment the reset index as clearing the control causes a NaN situation. 
				return (
					<div className={ CSS_CLASS }>
						<table>
							<tbody>
								{ ENABLED || DATA_VALUE != null
								? <tr>
									<td>({ DATE_FORMAT })</td>
								</tr>
								: null
								}
								<tr>
									<td>
										{ ENABLED
										? <DateTime
											key={ ID + '_' + resetIndex.toString() }
											value={ DATA_VALUE != null ? moment(DATA_VALUE) : null }
											viewDate={ DATA_VALUE != null ? moment(DATA_VALUE) : null }
											onChange={ this._onDateChange }
											onBlur={ this._onDateBlur }
											dateFormat={ DATE_FORMAT }
											timeFormat={ false }
											input={ true }
											closeOnSelect={ true }
											strictParsing={ true }
											inputProps={ inputProps }
											locale={ Security.USER_LANG().substring(0, 2) }
										/>
										: formatDate(DATA_VALUE, Security.USER_DATE_FORMAT())
										}
									</td>
								</tr>
								{ ENABLED || DATA_VALUE != null
								? <tr>
									<td>({ formatDate(new Date(1970, 0, 1, 23, 0), TIME_FORMAT) })</td>
								</tr>
								: null
								}
								<tr>
									<td>
										{ ENABLED
										? <input
											id={ ID + '_TIME' }
											key={ ID + '_TIME' }
											value={ TIME_VALUE }
											type="text"
											onChange={ this._onTimeChange }
											onBlur={ this._onTimeBlur }
											tabIndex={ FORMAT_TAB_INDEX }
											disabled={ !ENABLED }
											ref={ this.inputTime as React.RefObject<any> }
										/>
										: formatDate(DATA_VALUE, TIME_FORMAT)
										}
									</td>
								</tr>
							</tbody>
						</table>
						<br />
						{ error ? <span className='error' style={ {paddingLeft: '4px'} }>{ error }</span> : null }
						{ UI_REQUIRED ? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className="required" style={cssRequired} >{L10n.Term('.ERR_REQUIRED_FIELD')}</span> : null}
					</div>
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

