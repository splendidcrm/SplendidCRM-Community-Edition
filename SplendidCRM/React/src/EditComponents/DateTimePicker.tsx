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
import { IEditComponentProps, EditComponent }        from '../types/EditComponent';
// 3. Scripts. 
import Sql                                           from '../scripts/Sql'        ;
import L10n                                          from '../scripts/L10n'       ;
import Security                                      from '../scripts/Security'   ;
import { FromJsonDate, ToJsonDate, formatDate }      from '../scripts/Formatting' ;
import { ValidateDateParts, StartsWith }             from '../scripts/utility'    ;
// 4. Components and Views. 

interface IDateTimePickerProps extends IEditComponentProps
{
	MINUTES_STEP?: number;
}

interface IDateTimePickerState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_VALUE?      : Date | null;
	DATA_FIELD       : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	DATE_FORMAT      : string;
	TIME_FORMAT      : string;
	MINUTES_STEP     : number;
	VALUE_MISSING    : boolean;
	resetIndex       : number;
	error?           : string;
	ENABLED          : boolean;
	CSS_CLASS?       : string;
	HOURS_LIST       : string[];
	MINUTES_LIST     : string[];
	MERIDIEM_LIST    : string[];
	HOUR             : string;
	MINUTE           : string;
	MERIDIEM         : string;
	b12Hour          : boolean;
}

export default class DateTimePicker extends EditComponent<IDateTimePickerProps, IDateTimePickerState>
{
	private input = React.createRef<HTMLInputElement>();

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
				error     : null, 
				resetIndex: this.state.resetIndex+1
			});
		}
	}

	constructor(props: IDateTimePickerProps)
	{
		super(props);
		let FIELD_INDEX      : number  = 0;
		let DATA_VALUE       : Date    = null;
		let DATA_FIELD       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let DATE_FORMAT      : string  = Sql.ToString(Security.USER_DATE_FORMAT());
		let TIME_FORMAT      : string  = Security.USER_TIME_FORMAT();
		let MINUTES_STEP     : number  = 15;
		let ENABLED          : boolean = props.bIsWriteable;
		// 11/13/2020 Paul.  DateTimePicker uses dropdowns for time to match the old client. 
		let HOURS_LIST       : string[] = [];
		let MINUTES_LIST     : string[] = [];
		let MERIDIEM_LIST    : string[] = [];
		let HOUR             : string = '';
		let MINUTE           : string = '';
		let MERIDIEM         : string = '';

		if ( Sql.IsEmptyString(TIME_FORMAT) )
		{
			// 11/13/2020 Paul.  Change to moment format. 
			TIME_FORMAT= 'h:mm a';
		}
		let b12Hour: boolean = (TIME_FORMAT.indexOf('a') >= 0);
		if ( b12Hour )
		{
			for ( let nHour = 1 ; nHour <= 12 ; nHour++ )
			{
				let sHOUR: string = nHour.toString();
				if ( nHour < 10 )
					sHOUR = '0' + sHOUR;
				// 01/26/2008 Paul.  Make sure that 12 is first. 
				if ( nHour == 12 )
					HOURS_LIST.unshift(sHOUR);
				else
					HOURS_LIST.push(sHOUR);
			}
		}
		else
		{
			for ( let nHour = 0 ; nHour < 24 ; nHour++ )
			{
				let sHOUR: string = nHour.toString();
				if ( nHour < 10 )
					sHOUR = '0' + sHOUR;
				HOURS_LIST.push(sHOUR);
			}
		}
		for ( let nMinute = 0 ; nMinute < 60 ; nMinute += MINUTES_STEP )
		{
			let sMINUTE: string = nMinute.toString();
			if ( nMinute < 10 )
				sMINUTE = '0' + sMINUTE;
			MINUTES_LIST.push(sMINUTE);
		}
		MERIDIEM_LIST.push(formatDate(new Date(1970, 0, 1, 11, 0), 'a'));  // am
		MERIDIEM_LIST.push(formatDate(new Date(1970, 0, 1, 23, 0), 'a'));  // pm
	
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
				if ( StartsWith(layout.EDIT_NAME, 'Schedulers') )
				{
					MINUTES_STEP = 5;
				}

				if ( row != null )
				{
					DATA_VALUE = this.getValue(layout, row, DATA_FIELD);
					HOUR     = formatDate(DATA_VALUE, 'hh');
					MINUTE   = formatDate(DATA_VALUE, 'mm');
					MERIDIEM = formatDate(DATA_VALUE, 'a' );
				}
				else
				{
					HOUR     = HOURS_LIST   [0];
					MINUTE   = MINUTES_LIST [0];
					MERIDIEM = MERIDIEM_LIST[0];
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATE_FORMAT + ' ' + DATA_FIELD, DATA_VALUE, row);
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
			DATE_FORMAT      ,
			TIME_FORMAT      ,
			MINUTES_STEP     ,
			VALUE_MISSING    : false,
			ENABLED          ,
			resetIndex       : 0,
			HOURS_LIST       ,
			MINUTES_LIST     ,
			MERIDIEM_LIST    ,
			HOUR             ,
			MINUTE           ,
			MERIDIEM         ,
			b12Hour          ,
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
	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: IDateTimePickerState)
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
		else if ( nextState.DATA_VALUE != this.state.DATA_VALUE || nextState.HOUR != this.state.HOUR || nextState.MINUTE != this.state.MINUTE || nextState.MERIDIEM != this.state.MERIDIEM )
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

	private _onChange = (value: moment.Moment | string) =>
	{
		const { baseId, layout, row, onChanged, onUpdate  } = this.props;
		const { DATA_FIELD, DATE_FORMAT, ENABLED, MERIDIEM_LIST, HOUR, MINUTE, MERIDIEM, b12Hour } = this.state;
		try
		{
			let mntValue: moment.Moment = null;
			if ( typeof(value) == 'string' )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange string ' + DATA_FIELD, value);
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
						// 07/23/2019.  Apply Field Level Security. 
						if ( ENABLED )
						{
							let DATA_VALUE: Date   = mntValue.toDate();
							// 01/05/2021 Paul.  Need to apply existing time value after date change. 
							let nHour: number = parseInt(HOUR);
							if ( b12Hour )
							{
								if ( nHour == 12 )
									nHour = 0;
								if ( MERIDIEM == MERIDIEM_LIST[1] )
									nHour += 12;
							}
							DATA_VALUE.setHours(nHour);
							let nMinute: number = parseInt(MINUTE);
							DATA_VALUE.setMinutes(nMinute);

							this.setState({ DATA_VALUE, error: null }, this.validate);
							onChanged(DATA_FIELD, DATA_VALUE);
							onUpdate (DATA_FIELD, DATA_VALUE);
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
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange moment ' + DATA_FIELD, value);
				mntValue = moment(value);
				if ( mntValue.isValid() )
				{
					// 07/23/2019.  Apply Field Level Security. 
					if ( ENABLED )
					{
						let DATA_VALUE: Date   = mntValue.toDate();
						// 01/05/2021 Paul.  Need to apply existing time value after date change. 
						let nHour: number = parseInt(HOUR);
						if ( b12Hour )
						{
							if ( nHour == 12 )
								nHour = 0;
							if ( MERIDIEM == MERIDIEM_LIST[1] )
								nHour += 12;
						}
						DATA_VALUE.setHours(nHour);
						let nMinute: number = parseInt(MINUTE);
						DATA_VALUE.setMinutes(nMinute);

						this.setState({ DATA_VALUE, error: null }, this.validate);
						onChanged(DATA_FIELD, DATA_VALUE);
						onUpdate (DATA_FIELD, DATA_VALUE);
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
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onBlur = (event) =>
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBlur ' + DATA_FIELD, DATA_VALUE);
		// 08/05/2019 Paul.  Change the key so that the control will redraw using current DATE_VALUE. 
		if ( this.input.current != null )
		{
			if ( DATA_VALUE == null )
			{
				this.input.current.value = '';
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

	private _onHOUR_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD, MERIDIEM_LIST, MERIDIEM, b12Hour } = this.state;
		let { DATA_VALUE } = this.state;
		let HOUR: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHOUR_Change', HOUR);
		if ( DATA_VALUE != null )
		{
			let nHour: number = parseInt(HOUR);
			if ( b12Hour )
			{
				if ( nHour == 12 )
					nHour = 0;
				if ( MERIDIEM == MERIDIEM_LIST[1] )
					nHour += 12;
			}
			DATA_VALUE.setHours(nHour);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHOUR_Change', DATA_VALUE);

			this.setState({ DATA_VALUE, HOUR });
			onChanged(DATA_FIELD, DATA_VALUE);
			onUpdate (DATA_FIELD, DATA_VALUE);
		}
		else
		{
			this.setState({ HOUR });
		}
	}

	private _onMINUTE_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let { DATA_VALUE } = this.state;
		let MINUTE: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMINUTE_Change', MINUTE);
		if ( DATA_VALUE != null )
		{
			let nMinute: number = parseInt(MINUTE);
			DATA_VALUE.setMinutes(nMinute);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMINUTE_Change', DATA_VALUE);

			this.setState({ DATA_VALUE, MINUTE });
			onChanged(DATA_FIELD, DATA_VALUE);
			onUpdate (DATA_FIELD, DATA_VALUE);
		}
		else
		{
			this.setState({ MINUTE });
		}
	}

	private _onMERIDIEM_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD, MERIDIEM_LIST } = this.state;
		let { DATA_VALUE } = this.state;
		let MERIDIEM: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMERIDIEM_Change', MERIDIEM);
		if ( DATA_VALUE != null )
		{
			let nHour: number = parseInt(this.state.HOUR);
			if ( nHour == 12 )
				nHour = 0;
			// 01/05/2021 Paul.  Use same meridiem approach as used in hour change. 
			if ( MERIDIEM == MERIDIEM_LIST[1] )
				nHour += 12;
			DATA_VALUE.setHours(nHour);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMERIDIEM_Change', DATA_VALUE);

			this.setState({ DATA_VALUE, MERIDIEM });
			onChanged(DATA_FIELD, DATA_VALUE);
			onUpdate (DATA_FIELD, DATA_VALUE);
		}
		else
		{
			this.setState({ MERIDIEM });
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_VALUE, DATA_FIELD, UI_REQUIRED, DATE_FORMAT, TIME_FORMAT, FORMAT_TAB_INDEX, VALUE_MISSING, ENABLED, CSS_CLASS, MINUTES_STEP, resetIndex, error } = this.state;
		const { HOURS_LIST, MINUTES_LIST, MERIDIEM_LIST, HOUR, MINUTE, MERIDIEM, b12Hour } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, DATA_VALUE, error);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for DateTimePicker FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for DateTimePicker DATA_FIELD { DATA_FIELD }</span>);
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
					ref         : this.input
				};
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				let initialPickerDate: Date = DATA_VALUE;
				if ( initialPickerDate == null || initialPickerDate.getFullYear() == 0 )
				{
					initialPickerDate = new Date();
				}
				// https://github.com/YouCanBookMe/react-datetime
				// 11/17/2019 Paul.  Increment the reset index as clearing the control causes a NaN situation. 
				// 11/13/2020 Paul.  DateTimePicker uses dropdowns for time to match the old client. 
				return (
					<div className={ CSS_CLASS }>
						<table>
							<tbody>
								<tr>
									<td>
										{ ENABLED
										? <DateTime
											key={ ID + '_' + resetIndex.toString() }
											value={ DATA_VALUE != null ? moment(DATA_VALUE) : null }
											initialViewDate={ DATA_VALUE != null ? moment(DATA_VALUE) : null }
											onChange={ this._onChange }
											onClose={ this._onBlur }
											dateFormat={ DATE_FORMAT }
											timeFormat={ false }
											input={ true }
											closeOnSelect={ true }
											strictParsing={ true }
											inputProps={ inputProps }
											locale={ Security.USER_LANG().substring(0, 2) }
											timeConstraints={ {minutes: { min: 0, max: 59, step: MINUTES_STEP}} }
										/>
										: formatDate(DATA_VALUE, Security.USER_DATE_FORMAT())
										}
									</td>
									<td>
										{ ENABLED
										? <React.Fragment>
											<select
												id={ ID + '_HOUR_' + resetIndex.toString() }
												onChange={ this._onHOUR_Change }
												value={ HOUR }
												style={ {width: 'auto', margin: 2} }
												>
												{
													HOURS_LIST.map((item, index) => 
													{
														return (<option key={ ID + '_HOUR_' + index.toString() } id={ ID + '_HOUR_' + index.toString() } value={ item }>{ item }</option>);
													})
												}
											</select>
											<select
												id={ ID + '_MINUTE_' + resetIndex.toString() }
												onChange={ this._onMINUTE_Change }
												value={ MINUTE }
												style={ {width: 'auto', margin: 2} }
												>
												{
													MINUTES_LIST.map((item, index) => 
													{
														return (<option key={ ID + '_MINUTE_' + index.toString() } id={ ID + '_MINUTE_' + index.toString() } value={ item }>{ item }</option>);
													})
												}
											</select>
											{ b12Hour && MERIDIEM_LIST.length > 0
											? <select
												id={ ID + '_MERIDIEM_' + resetIndex.toString() }
												onChange={ this._onMERIDIEM_Change }
												value={ MERIDIEM }
												style={ {width: 'auto', margin: 2} }
												>
												{
													MERIDIEM_LIST.map((item, index) => 
													{
														return (<option key={ ID + '_MERIDIEM_' + index.toString() } id={ ID + '_MERIDIEM_' + index.toString() } value={ item }>{ item }</option>);
													})
												}
											</select>
											: null
											}
										</React.Fragment>
										: formatDate(DATA_VALUE, Security.USER_TIME_FORMAT())
										}
									</td>
								</tr>
							{ ENABLED || DATA_VALUE != null
							? <tr>
									<td>({ DATE_FORMAT })</td>
									<td>({ formatDate(new Date(1970, 0, 1, 23, 0), TIME_FORMAT) })</td>
								</tr>
							: null
							}
							</tbody>
						</table>
						<br />
						{ error ? <span className='error' style={ {paddingLeft: '4px'} }>{ error }</span> : null }
						{ UI_REQUIRED ? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className="required" style={ cssRequired } >{ L10n.Term('.ERR_REQUIRED_FIELD') }</span> : null}
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

