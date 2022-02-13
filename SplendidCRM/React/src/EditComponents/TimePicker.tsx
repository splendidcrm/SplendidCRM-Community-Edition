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
// 2. Store and Types. 
import { IEditComponentProps, EditComponent }   from '../types/EditComponent';
// 3. Scripts. 
import Sql                                      from '../scripts/Sql'        ;
import L10n                                     from '../scripts/L10n'       ;
import Security                                 from '../scripts/Security'   ;
import { FromJsonDate, ToJsonDate, formatDate } from '../scripts/Formatting' ;
// 4. Components and Views. 

interface ITimePickerProps extends IEditComponentProps
{
	MINUTES_STEP?: number;
}

interface ITimePickerState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_VALUE?      : Date | null;
	DATA_FIELD       : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	TIME_FORMAT      : string;
	HOUR_VALUE       : string;
	MINUTE_VALUE     : string;
	MERIDIEM_VALUE   : string;
	HOUR_OPTIONS     : string[];
	MINUTE_OPTIONS   : string[];
	MERIDIEM_OPTIONS : string[];
	VALUE_MISSING    : boolean;
	ENABLED          : boolean;
	CSS_CLASS?       : string;
}

export default class TimePicker extends EditComponent<ITimePickerProps, ITimePickerState>
{
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
				DATA_VALUE    : null, 
				HOUR_VALUE    : null, 
				MINUTE_VALUE  : null, 
				MERIDIEM_VALUE: ''  ,
			});
		}
	}

	constructor(props: ITimePickerProps)
	{
		super(props);
		let FIELD_INDEX      : number   = 0;
		let DATA_VALUE       : Date     = null;
		let DATA_FIELD       : string   = '';
		let UI_REQUIRED      : boolean  = null;
		let FORMAT_TAB_INDEX : number   = null;
		let HOUR_VALUE       : string   = '';
		let MINUTE_VALUE     : string   = '';
		let MERIDIEM_VALUE   : string   = '';
		let HOUR_OPTIONS     : string[] = [];
		let MINUTE_OPTIONS   : string[] = [];
		let MERIDIEM_OPTIONS : string[] = [];
		let TIME_FORMAT      : string   = Security.USER_TIME_FORMAT();
		let MINUTES_STEP     : number   = 15;
		let ENABLED          : boolean  = props.bIsWriteable;
		if ( Sql.IsEmptyString(TIME_FORMAT) )
		{
			// 11/13/2020 Paul.  Change to moment format. 
			TIME_FORMAT= 'h:mm a';
		}

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this.props;
			if (props.layout != null)
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX     );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD      );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED     ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX);
				ID = baseId + '_' + DATA_FIELD;

				// http://www.phpeveryday.com/articles/jQuery-UI-Changing-the-date-format-for-Datepicker-P1023.html
				/*
				dayPickerStrings =
					{
						months: L10n.GetListTerms('month_names_dom'),
						shortMonths: L10n.GetListTerms('short_month_names_dom'),
						days: L10n.GetListTerms('day_names_dom'),
						shortDays: L10n.GetListTerms('short_day_names_dom'),

						goToToday: L10n.Term('Calendar.LNK_VIEW_CALENDAR'),
						//prevMonthAriaLabel: L10n.Term('Calendar.LBL_PREVIOUS_MONTH'),
						//nextMonthAriaLabel: L10n.Term('Calendar.LBL_NEXT_MONTH'),
						//prevYearAriaLabel: L10n.Term('Calendar.LBL_PREVIOUS_YEAR'),
						//nextYearAriaLabel: L10n.Term('Calendar.LBL_NEXT_YEAR'),

						//isRequiredErrorMessage: L10n.Term('.ERR_MISSING_REQUIRED_FIELDS'),
						//invalidInputErrorMessage: L10n.Term('.ERR_INVALID_DATE')
					};
				*/
				MINUTES_STEP = Sql.ToInteger(this.props.MINUTES_STEP);
				if ( MINUTES_STEP <= 0 || MINUTES_STEP > 60 )
				{
					MINUTES_STEP = 15;
				}
				if ( TIME_FORMAT.indexOf('a') > 0 )
				{
					MERIDIEM_OPTIONS.push(moment('1970-01-01T01:00').format('a'));
					MERIDIEM_OPTIONS.push(moment('1970-01-01T23:00').format('a'));
				}
				if ( MERIDIEM_OPTIONS.length > 0 )
				{
					for ( let nHour = 1; nHour <= 12; nHour++ )
					{
						let sHour = nHour.toString();
						if ( sHour.length < 2 )
						{
							sHour = '0' + sHour;
						}
						if ( nHour == 12 )
						{
							HOUR_OPTIONS.unshift(sHour);
						}
						else
						{
							HOUR_OPTIONS.push(sHour);
						}
					}
				}
				else
				{
					for ( let nHour = 0; nHour < 24; nHour++ )
					{
						let sHour = nHour.toString();
						if ( sHour.length < 2 )
						{
							sHour = '0' + sHour;
						}
						HOUR_OPTIONS.push(sHour);
					}
				}
				HOUR_OPTIONS.unshift('--');
				for ( let nMinute = 0; nMinute < 60; nMinute += MINUTES_STEP )
				{
					let sMinute = nMinute.toString();
					if ( sMinute.length < 2 )
					{
						sMinute = '0' + sMinute;
					}
					MINUTE_OPTIONS.push(sMinute);
				}
				MINUTE_OPTIONS.unshift('--');
				if ( row != null )
				{
					DATA_VALUE = this.getValue(layout, row, DATA_FIELD);
					if ( DATA_VALUE !== null )
					{
						let nHour = DATA_VALUE.getHours();
						HOUR_VALUE = nHour.toString();
						if ( MERIDIEM_OPTIONS.length > 0 )
						{
							MERIDIEM_VALUE = 'am';
							if ( nHour == 0 )
							{
								HOUR_VALUE = '12';
							}
							else if ( nHour >= 12 )
							{
								MERIDIEM_VALUE = 'pm';
								if ( nHour > 12 )
								{
									nHour -= 12;
									HOUR_VALUE = nHour.toString();
								}
							}
						}
						if ( HOUR_VALUE.length < 2 )
						{
							HOUR_VALUE = '0' + HOUR_VALUE;
						}
						MINUTE_VALUE = DATA_VALUE.getMinutes().toString();
						if ( MINUTE_VALUE.length < 2 )
						{
							MINUTE_VALUE = '0' + MINUTE_VALUE;
						}
						// 03/27/2018 Paul.  Add any missing values. 
						if ( HOUR_OPTIONS.indexOf(HOUR_VALUE) < 0 )
						{
							HOUR_OPTIONS.push(HOUR_VALUE);
						}
						if ( MINUTE_OPTIONS.indexOf(MINUTE_VALUE) < 0 )
						{
							MINUTE_OPTIONS.push(MINUTE_VALUE);
						}
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
			TIME_FORMAT      ,
			HOUR_VALUE       ,
			MINUTE_VALUE     ,
			MERIDIEM_VALUE   ,
			HOUR_OPTIONS     ,
			MINUTE_OPTIONS   ,
			MERIDIEM_OPTIONS ,
			VALUE_MISSING    : false,
			ENABLED          ,
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

	shouldComponentUpdate(nextProps: ITimePickerProps, nextState: ITimePickerState)
	{
		const { DATA_FIELD, DATA_VALUE, HOUR_VALUE, MINUTE_VALUE, MERIDIEM_VALUE, VALUE_MISSING, ENABLED } = this.state;
		if ( nextProps.row != this.props.row )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, HOUR_VALUE, MINUTE_VALUE, MERIDIEM_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextProps.layout != this.props.layout )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, HOUR_VALUE, MINUTE_VALUE, MERIDIEM_VALUE, nextProps, nextState);
			return true;
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( nextProps.bIsHidden != this.props.bIsHidden )
		{
			//console.log((new Date()).toISOString() + ' ' + 'TextBox.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if (nextState.DATA_VALUE != this.state.DATA_VALUE || nextState.HOUR_VALUE != this.state.HOUR_VALUE || nextState.MINUTE_VALUE != this.state.MINUTE_VALUE || nextState.MERIDIEM_VALUE != this.state.MERIDIEM_VALUE)
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, HOUR_VALUE, MINUTE_VALUE, MERIDIEM_VALUE, nextProps, nextState);
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
					DATA_VALUE = FromJsonDate(row[DATA_FIELD], undefined, Security.USER_TIME_FORMAT());
					// 03/27/2019 Paul.  Return null for zero year. 
					if ( DATA_VALUE.getFullYear() == 0 )
					{
						DATA_VALUE = null;
					}
				}
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue ' + DATA_FIELD, DATA_VALUE, row);
		return DATA_VALUE;
	}

	private _onHourChange = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, DATA_VALUE, HOUR_VALUE, MINUTE_VALUE, MERIDIEM_VALUE, TIME_FORMAT, ENABLED } = this.state;
		let value = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHourChange ' + DATA_FIELD, value);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				if ( value != '--' && MINUTE_VALUE != '--' )
				{
					// https://devhints.io/moment
					// https://momentjs.com/docs/#/parsing/
					let sTIME_VALUE = value + ':' + MINUTE_VALUE + ' ' + MERIDIEM_VALUE;
					let dtDATE_VALUE: moment.Moment = moment('1900-01-01');
					let dtTIME_VALUE: moment.Moment = moment(sTIME_VALUE, TIME_FORMAT);
					dtDATE_VALUE.set('hour', dtTIME_VALUE.hour());
					dtDATE_VALUE.set('minute', dtTIME_VALUE.minute());
					let dtDATE_TIME = dtDATE_VALUE.toDate();
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHourChange ' + DATA_FIELD, formatDate(dtDATE_TIME, TIME_FORMAT));
					this.setState({ DATA_VALUE: dtDATE_TIME, HOUR_VALUE: value }, this.validate);
					onChanged(DATA_FIELD, dtDATE_TIME);
					onUpdate (DATA_FIELD, dtDATE_TIME);
				}
				else
				{
					this.setState({ DATA_VALUE: null, HOUR_VALUE: value }, this.validate);
					onChanged(DATA_FIELD, null);
					onUpdate (DATA_FIELD, null);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onHourChange', error);
		}
	}

	private _onMinuteChange = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, DATA_VALUE, HOUR_VALUE, MINUTE_VALUE, MERIDIEM_VALUE, TIME_FORMAT, ENABLED } = this.state;
		let value = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMinuteChange ' + DATA_FIELD, value);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				if ( value != '--' && HOUR_VALUE != '--' )
				{
					// https://devhints.io/moment
					// https://momentjs.com/docs/#/parsing/
					let sTIME_VALUE = HOUR_VALUE + ':' + value + ' ' + MERIDIEM_VALUE;
					let dtDATE_VALUE: moment.Moment = moment('1900-01-01');
					let dtTIME_VALUE: moment.Moment = moment(sTIME_VALUE, TIME_FORMAT);
					dtDATE_VALUE.set('hour', dtTIME_VALUE.hour());
					dtDATE_VALUE.set('minute', dtTIME_VALUE.minute());
					let dtDATE_TIME = dtDATE_VALUE.toDate();
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMinuteChange ' + DATA_FIELD, formatDate(dtDATE_TIME, TIME_FORMAT));
					this.setState({ DATA_VALUE: dtDATE_TIME, MINUTE_VALUE: value }, this.validate);
					onChanged(DATA_FIELD, dtDATE_TIME);
					onUpdate (DATA_FIELD, dtDATE_TIME);
				}
				else
				{
					this.setState({ DATA_VALUE: null, MINUTE_VALUE: value }, this.validate);
					onChanged(DATA_FIELD, null);
					onUpdate (DATA_FIELD, null);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onMinuteChange', error);
		}
	}

	private _onMeridiemChange = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, DATA_VALUE, HOUR_VALUE, MINUTE_VALUE, MERIDIEM_VALUE, TIME_FORMAT, ENABLED } = this.state;
		let value = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMeridiemChange ' + DATA_FIELD, value);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				if ( HOUR_VALUE != '--' && HOUR_VALUE != '--' )
				{
					// https://devhints.io/moment
					// https://momentjs.com/docs/#/parsing/
					let sTIME_VALUE = HOUR_VALUE + ':' + MINUTE_VALUE + ' ' + value;
					let dtDATE_VALUE: moment.Moment = moment('1900-01-01');
					let dtTIME_VALUE: moment.Moment = moment(sTIME_VALUE, TIME_FORMAT);
					dtDATE_VALUE.set('hour', dtTIME_VALUE.hour());
					dtDATE_VALUE.set('minute', dtTIME_VALUE.minute());
					let dtDATE_TIME = dtDATE_VALUE.toDate();
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMeridiemChange ' + DATA_FIELD, formatDate(dtDATE_TIME, TIME_FORMAT));
					this.setState({ DATA_VALUE: dtDATE_TIME, MERIDIEM_VALUE: value }, this.validate);
					onChanged(DATA_FIELD, dtDATE_TIME);
					onUpdate (DATA_FIELD, dtDATE_TIME);
				}
				else
				{
					this.setState({ DATA_VALUE: null, MERIDIEM_VALUE: value }, this.validate);
					onChanged(DATA_FIELD, null);
					onUpdate (DATA_FIELD, null);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onMeridiemChange', error);
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_VALUE, DATA_FIELD, UI_REQUIRED, FORMAT_TAB_INDEX, HOUR_VALUE, MINUTE_VALUE, MERIDIEM_VALUE, HOUR_OPTIONS, MINUTE_OPTIONS, MERIDIEM_OPTIONS, TIME_FORMAT, VALUE_MISSING, ENABLED, CSS_CLASS } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD + ' ' + TIME_FORMAT, DATA_VALUE, HOUR_VALUE + ':' + MINUTE_VALUE + ' ' + MERIDIEM_VALUE);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for TimePicker FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for TimePicker DATA_FIELD { DATA_FIELD }</span>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// https://developer.microsoft.com/en-us/fabric#/components/datepicker
				return (
					<div className={ CSS_CLASS }>
						<table>
							<tbody>
								<tr>
									<td>
										<select
											id={ID + '_HOUR'}
											key={ID + '_HOUR'}
											tabIndex={FORMAT_TAB_INDEX}
											onChange={this._onHourChange}
											value={HOUR_VALUE}
											disabled={ !ENABLED }
										>
											{
												HOUR_OPTIONS.map((item, index) => 
												{
													return (<option id={ID + '_HOUR_' + item} key={ID + '_HOUR_' + item} value={item}>{item}</option>);
												})
											}
										</select>
									</td>
									<td>
										<select
											id={ID + '_MINUTE'}
											key={ID + '_MINUTE'}
											tabIndex={FORMAT_TAB_INDEX}
											onChange={this._onMinuteChange}
											value={MINUTE_VALUE}
											style={{ paddingLeft: '3px' }}
											disabled={ !ENABLED }
										>
											{
												MINUTE_OPTIONS.map((item, index) => 
												{
													return (<option id={ID + '_MINUTE_' + item} key={ID + '_MINUTE_' + item} value={item}>{item}</option>);
												})
											}
										</select>
									</td>
									<td>
										{
											MERIDIEM_OPTIONS.length > 0 ?
												<select
													id={ID + '_MERIDIEM'}
													key={ID + '_MERIDIEM'}
													tabIndex={FORMAT_TAB_INDEX}
													onChange={this._onMeridiemChange}
													value={MERIDIEM_VALUE}
													style={{ paddingLeft: '3px' }}
													disabled={ !ENABLED }
												>
													{
														MERIDIEM_OPTIONS.map((item, index) => 
														{
															return (<option id={ID + '_MERIDIEM_' + item} key={ID + '_MERIDIEM_' + item} value={item}>{item}</option>);
														})
													}
												</select>
												: null
										}
									</td>
								</tr>
								<tr>
									<td colSpan={3}>({ formatDate(new Date(1970, 0, 1, 23, 0), TIME_FORMAT) })</td>
								</tr>
							</tbody>
						</table><br />
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

