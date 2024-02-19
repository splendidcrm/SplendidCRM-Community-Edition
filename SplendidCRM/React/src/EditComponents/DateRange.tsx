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
import { IEditComponentProps, EditComponent } from '../types/EditComponent'  ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'          ;
import L10n                                   from '../scripts/L10n'         ;
import Security                               from '../scripts/Security'     ;
import { FromJsonDate, formatDate }           from '../scripts/Formatting'   ;
import { ValidateDateParts }                  from '../scripts/utility'      ;
// 4. Components and Views. 

interface IDateRangeState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_AFTER?      : Date | null;
	DATA_BEFORE?     : Date | null;
	DATA_FIELD       : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	DATE_FORMAT      : string;
	VALUE_MISSING    : boolean;
	resetIndexAfter  : number;
	resetIndexBefore : number;
	errorAfter?      : string;
	errorBefore?     : string;
	ENABLED          : boolean;
	CSS_CLASS?       : string;
}

export default class DateRange extends EditComponent<IEditComponentProps, IDateRangeState>
{
	private inputAfter  = React.createRef<HTMLInputElement>();
	private inputBefore = React.createRef<HTMLInputElement>();

	public get data(): any
	{
		const { DATA_FIELD, DATA_BEFORE, DATA_AFTER } = this.state;
		// 11/30/2020 Paul.  Lowercase was a bug. 
		return { key: DATA_FIELD, Before: DATA_BEFORE, After: DATA_AFTER };
	}

	public validate(): boolean
	{
		// 08/06/2019 Paul.  Date range is used in search views, so there is no need to test for the required flag. 
		return true;
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( PROPERTY_NAME == 'DATA_AFTER' )
		{
			this.setState(
			{
				DATA_AFTER: (DATA_VALUE ? Sql.ToDateTime(DATA_VALUE) : null)
			});
		}
		else if ( PROPERTY_NAME == 'DATA_BEFORE' )
		{
			this.setState(
			{
				DATA_BEFORE: (DATA_VALUE ? Sql.ToDateTime(DATA_VALUE) : null)
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
				DATA_AFTER      : null, 
				DATA_BEFORE     : null, 
				errorAfter      : null, 
				errorBefore     : null, 
				resetIndexAfter : this.state.resetIndexAfter+1, 
				resetIndexBefore: this.state.resetIndexBefore+1
			});
		}
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number  = 0;
		let DATA_AFTER       : Date    = null;
		let DATA_BEFORE      : Date    = null;
		let DATA_FIELD       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let DATE_FORMAT      : string  = Security.USER_DATE_FORMAT();
		let ENABLED          : boolean = props.bIsWriteable;

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
					if ( row[DATA_FIELD] != null )
					{
						let DATA_VALUE = row[DATA_FIELD];
						if ( Array.isArray(DATA_VALUE) )
						{
							// 01/20/2021 Paul.  Include format so that it can convert a text string. 
							if ( DATA_VALUE.length >= 1 )
							{
								DATA_AFTER = FromJsonDate(DATA_VALUE[0], undefined, Security.USER_TIME_FORMAT());
							}
							if ( DATA_VALUE.length >= 2 )
							{
								DATA_BEFORE = FromJsonDate(DATA_VALUE[1], undefined, Security.USER_TIME_FORMAT());
							}
						}
						else
						{
							// 11/25/2020 Paul.  When saving DateRange, before and after are not under the Value field. 
							if ( DATA_VALUE.Value )
							{
								// 01/20/2021 Paul.  Include format so that it can convert a text string. 
								if ( DATA_VALUE.Value.after )
								{
									DATA_AFTER = FromJsonDate(DATA_VALUE.Value.after, undefined, Security.USER_TIME_FORMAT());
								}
								else if ( DATA_VALUE.Value.After )
								{
									DATA_AFTER = FromJsonDate(DATA_VALUE.Value.After, undefined, Security.USER_TIME_FORMAT());
								}
								if ( DATA_VALUE.Value.before )
								{
									DATA_BEFORE = FromJsonDate(DATA_VALUE.Value.before, undefined, Security.USER_TIME_FORMAT());
								}
								else if ( DATA_VALUE.Value.Before )
								{
									DATA_BEFORE = FromJsonDate(DATA_VALUE.Value.Before, undefined, Security.USER_TIME_FORMAT());
								}
							}
							// 11/25/2020 Paul.  React uses lowercase and the old system uses cap first. 
							else
							{
								if ( !Sql.IsEmptyString(DATA_VALUE.After) )
								{
									DATA_AFTER = moment(DATA_VALUE.After, DATE_FORMAT).toDate();
								}
								if ( !Sql.IsEmptyString(DATA_VALUE.Before) )
								{
									DATA_BEFORE = moment(DATA_VALUE.Before, DATE_FORMAT).toDate();
								}
							}
						}
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_AFTER, DATA_BEFORE, row);
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
			DATA_AFTER       ,
			DATA_BEFORE      ,
			DATA_FIELD       ,
			UI_REQUIRED      ,
			FORMAT_TAB_INDEX ,
			DATE_FORMAT      ,
			VALUE_MISSING    : false,
			ENABLED          ,
			resetIndexAfter  : 0,
			resetIndexBefore : 0,
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
	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: IDateRangeState)
	{
		const { DATA_FIELD, DATA_AFTER, DATA_BEFORE, VALUE_MISSING, ENABLED } = this.state;
		if ( nextProps.row != this.props.row )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_AFTER, DATA_BEFORE, nextProps, nextState);
			return true;
		}
		else if ( nextProps.layout != this.props.layout )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_AFTER, DATA_BEFORE, nextProps, nextState);
			return true;
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( nextProps.bIsHidden != this.props.bIsHidden )
		{
			//console.log((new Date()).toISOString() + ' ' + 'TextBox.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if (nextState.DATA_AFTER != this.state.DATA_AFTER || nextState.DATA_BEFORE != this.state.DATA_BEFORE)
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_AFTER, DATA_BEFORE, nextProps, nextState);
			return true;
		}
		else if ( nextState.VALUE_MISSING != this.state.VALUE_MISSING || nextState.ENABLED != this.state.ENABLED )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_AFTER, DATA_BEFORE, VALUE_MISSING, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		else if ( nextState.errorAfter != this.state.errorAfter || nextState.errorBefore != this.state.errorBefore )
		{
			return true;
		}
		return false;
	}

	componentDidCatch(error, info)
	{
		const { DATA_FIELD, DATA_AFTER, DATA_BEFORE } = this.state;
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch ' + DATA_FIELD, error, info);
	}

	private _onChangeAfter = (value: moment.Moment | null | undefined) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_AFTER, DATA_BEFORE, DATA_FIELD, DATE_FORMAT, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeAfter ' + DATA_FIELD, value);
		try
		{
			let mntValue: moment.Moment = null;
			if ( typeof(value) == 'string' )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeAfter string ' + DATA_FIELD, value);
				if ( Sql.IsEmptyString(value) )
				{
					// 11/17/2019 Paul.  Increment the reset index as clearing the control causes a NaN situation. 
					this.setState({ DATA_AFTER: null, errorAfter: null, resetIndexAfter: this.state.resetIndexAfter+1 }, this.validate);
					// 06/08/2021 Paul.  Must provide both values on change, otherwise clearing one would also clear the other. 
					onChanged(DATA_FIELD, { Before: DATA_BEFORE, After: null });
					//onUpdate (DATA_FIELD, { Before: DATA_BEFORE, After: null });
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
							let DATA_AFTER: Date   = mntValue.toDate();
							this.setState({ DATA_AFTER, errorAfter: null }, this.validate);
							// 11/30/2020 Paul.  Lowercase was a bug. 
							onChanged(DATA_FIELD, { Before: DATA_BEFORE, After: DATA_AFTER });
							//onUpdate (DATA_FIELD, mntValue);
						}
					}
					else
					{
						this.setState({ errorAfter: L10n.Term('.ERR_INVALID_DATE') });
					}
				}
			}
			else if ( value instanceof moment )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeAfter moment ' + DATA_FIELD, value);
				mntValue = moment(value);
				if ( mntValue.isValid() )
				{
					// 07/23/2019.  Apply Field Level Security. 
					if ( ENABLED )
					{
						let DATA_AFTER: Date   = mntValue.toDate();
						this.setState({ DATA_AFTER, errorAfter: null }, this.validate);
						// 11/30/2020 Paul.  Lowercase was a bug. 
						onChanged(DATA_FIELD, { Before: DATA_BEFORE, After: DATA_AFTER });
						//onUpdate (DATA_FIELD, mntValue);
					}
				}
				else
				{
					this.setState({ errorAfter: L10n.Term('.ERR_INVALID_DATE') });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + 'DateRange._onChange', error);
		}
	}

	private _onChangeBefore = (value: moment.Moment | null | undefined) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_AFTER, DATA_BEFORE, DATA_FIELD, DATE_FORMAT, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeBefore ' + DATA_FIELD, value);
		try
		{
			let mntValue: moment.Moment = null;
			if ( typeof(value) == 'string' )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeBefore string ' + DATA_FIELD, value);
				if ( Sql.IsEmptyString(value) )
				{
					// 11/17/2019 Paul.  Increment the reset index as clearing the control causes a NaN situation. 
					this.setState({ DATA_BEFORE: null, errorBefore: null, resetIndexBefore: this.state.resetIndexBefore+1 }, this.validate);
					// 06/08/2021 Paul.  Must provide both values on change, otherwise clearing one would also clear the other. 
					onChanged(DATA_FIELD, { Before: null, After: DATA_AFTER });
					//onUpdate (DATA_FIELD, { Before: DATA_BEFORE, After: DATA_AFTER });
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
							let DATA_BEFORE: Date   = mntValue.toDate();
							this.setState({ DATA_BEFORE, errorBefore: null }, this.validate);
							// 11/30/2020 Paul.  Lowercase was a bug. 
							onChanged(DATA_FIELD, { Before: DATA_BEFORE, After: DATA_AFTER });
							//onUpdate (DATA_FIELD, { Before: DATA_BEFORE, After: DATA_AFTER });
						}
					}
					else
					{
						this.setState({ errorBefore: L10n.Term('.ERR_INVALID_DATE') });
					}
				}
			}
			else if ( value instanceof moment )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeBefore moment ' + DATA_FIELD, value);
				mntValue = moment(value);
				if ( mntValue.isValid() )
				{
					// 07/23/2019.  Apply Field Level Security. 
					if ( ENABLED )
					{
						let DATA_BEFORE: Date   = mntValue.toDate();
						this.setState({ DATA_BEFORE, errorBefore: null }, this.validate);
						// 11/30/2020 Paul.  Lowercase was a bug. 
						onChanged(DATA_FIELD, { Before: DATA_BEFORE, After: DATA_AFTER });
						//onUpdate (DATA_FIELD, { Before: DATA_BEFORE, After: DATA_AFTER });
					}
				}
				else
				{
					this.setState({ errorBefore: L10n.Term('.ERR_INVALID_DATE') });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + 'DateRange._onChange', error);
		}
	}

	private _onBlurAfter = (event) =>
	{
		const { DATA_FIELD, DATA_AFTER, UI_REQUIRED, errorAfter } = this.state;
		//console.log((new Date()).toISOString() + ' ' + 'DatePicker._onBlurAfter ' + DATA_FIELD, DATA_AFTER);
		// 08/05/2019 Paul.  Change the key so that the control will redraw using current DATE_VALUE. 
		if ( this.inputAfter.current != null )
		{
			if ( DATA_AFTER == null )
			{
				this.inputAfter.current.value = '';
			}
			if ( !UI_REQUIRED && errorAfter )
			{
				this.setState({ errorAfter: null });
			}
		}
	}

	private _onBlurBefore = (event) =>
	{
		const { DATA_FIELD, DATA_BEFORE, UI_REQUIRED, errorBefore } = this.state;
		//console.log((new Date()).toISOString() + ' ' + 'DatePicker._onBlurBefore ' + DATA_FIELD, DATA_BEFORE);
		// 08/05/2019 Paul.  Change the key so that the control will redraw using current DATE_VALUE. 
		if ( this.inputBefore.current != null )
		{
			if ( DATA_BEFORE == null )
			{
				this.inputBefore.current.value = '';
			}
			if ( !UI_REQUIRED && errorBefore )
			{
				this.setState({ errorBefore: null });
			}
		}
	}

	private _onKeyDown = (event) =>
	{
		const { onSubmit } = this.props;
		//console.log((new Date()).toISOString() + ' ' + 'DatePicker._onKeyDown', event, event.key);
		if ( event.key == 'Enter' && onSubmit != null )
		{
			onSubmit();
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_AFTER, DATA_BEFORE, DATA_FIELD, UI_REQUIRED, DATE_FORMAT, FORMAT_TAB_INDEX, VALUE_MISSING, ENABLED, CSS_CLASS, resetIndexAfter, resetIndexBefore, errorAfter, errorBefore } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, DATA_AFTER, DATA_BEFORE, errorAfter, errorBefore);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for DateRange FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for DateRange DATA_FIELD { DATA_FIELD }</span>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				// 06/23/2020 Paul.  Make use of minimum width. 
				let inputPropsAfter: any =
				{
					type        : 'text', 
					tabIndex    : FORMAT_TAB_INDEX,
					autoComplete: 'off',
					style       : {flex: '2 0 70%', width: '100%', minWidth: '100px'},
					onKeyDown   : this._onKeyDown,
					disabled    : !ENABLED,
					className   : null,  /* 12/10/2019 Paul.  Prevent the default form-control. */
					ref         : this.inputAfter,
				};
				let inputPropsBefore: any =
				{
					type        : 'text', 
					tabIndex    : FORMAT_TAB_INDEX,
					autoComplete: 'off',
					style       : {flex: '2 0 70%', width: '100%', minWidth: '100px'},
					onKeyDown   : this._onKeyDown,
					disabled    : !ENABLED,
					className   : null,  /* 12/10/2019 Paul.  Prevent the default form-control. */
					ref         : this.inputAfter,
				};
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// https://github.com/YouCanBookMe/react-datetime
				// 11/17/2019 Paul.  Increment the reset index as clearing the control causes a NaN situation. 
				return (
					<div className={ CSS_CLASS }>
						<table>
							<tbody>
								<tr>
									<td>
										{ L10n.Term('Dashboard.LBL_SEARCH_AFTER') }
									</td>
									<td>
										{ ENABLED
										? <DateTime
											key={ ID + '_AFTER' + '_' + resetIndexAfter.toString() }
											value={ DATA_AFTER != null ? moment(DATA_AFTER) : null }
											initialViewDate={ DATA_AFTER != null ? moment(DATA_AFTER) : null }
											onChange={ this._onChangeAfter }
											onClose={ this._onBlurAfter }
											dateFormat={ DATE_FORMAT }
											timeFormat={ false }
											input={ true }
											closeOnSelect={ true }
											strictParsing={ true }
											inputProps={ inputPropsAfter }
											locale={ Security.USER_LANG().substring(0, 2) }
										/>
										: formatDate(DATA_AFTER, Security.USER_DATE_FORMAT())
										}
									</td>
									<td>
										<span style={ {paddingLeft: '4px'} }>({ DATE_FORMAT })</span>
										{ errorAfter ? <span className='error' style={ {paddingLeft: '4px'} }>{ errorAfter }</span> : null }
									</td>
								</tr>
								<tr>
									<td>
										{ L10n.Term('Dashboard.LBL_SEARCH_BEFORE') }
									</td>
									<td>
										{ ENABLED
										? <DateTime
											key={ ID + '_BEFORE' + '_' + resetIndexBefore.toString() }
											value={ DATA_BEFORE != null ? moment(DATA_BEFORE) : null }
											initialViewDate={ DATA_BEFORE != null ? moment(DATA_BEFORE) : null }
											onChange={ this._onChangeBefore }
											onClose={ this._onBlurBefore }
											dateFormat={ DATE_FORMAT }
											timeFormat={ false }
											input={ true }
											closeOnSelect={ true }
											strictParsing={ true }
											inputProps={ inputPropsBefore }
											locale={ Security.USER_LANG().substring(0, 2) }
										/>
										: formatDate(DATA_BEFORE, Security.USER_DATE_FORMAT())
										}
									</td>
									<td>
										<span style={ {paddingLeft: '4px'} }>({ DATE_FORMAT })</span>
										{ errorBefore ? <span className='error' style={ {paddingLeft: '4px'} }>{ errorBefore }</span> : null }
									</td>
								</tr>
							</tbody>
						</table>
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

