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
import AutoComplete                           from 'react-autocomplete'            ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
import { IEditComponentProps, EditComponent } from '../types/EditComponent'        ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                ;
import L10n                                   from '../scripts/L10n'               ;
import Credentials                            from '../scripts/Credentials'        ;
import SplendidCache                          from '../scripts/SplendidCache'      ;
import { Crm_Config, Crm_Modules }            from '../scripts/Crm'                ;
import { ListView_LoadModulePaginated }       from '../scripts/ListView'           ;
// 4. Components and Views. 
import PopupView                              from '../views/PopupView'            ;

interface IZipCodePopupState
{
	popupOpen        : boolean;
	ID               : string;
	FIELD_INDEX      : number;
	DATA_VALUE       : string;
	DATA_FIELD       : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	FORMAT_MAX_LENGTH: number;
	VALUE_MISSING    : boolean;
	items            : any[];
	ENABLED          : boolean;
	CSS_CLASS?       : string;
	// 10/05/2021 Paul.  Add support for regular expression validation. 
	FIELD_VALIDATOR_MESSAGE: string;
	VALIDATION_TYPE        : string;
	REGULAR_EXPRESSION     : string;
	VALIDATOR_FAILED       : boolean;
}

export default class ZipCodePopup extends EditComponent<IEditComponentProps, IZipCodePopupState>
{
	private LastQuery: string;
	private PartialInput: boolean;
	private themeURL: string = null;
	private legacyIcons: boolean = false;

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
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, VALUE_MISSING, ENABLED, VALIDATION_TYPE, REGULAR_EXPRESSION, FIELD_VALIDATOR_MESSAGE } = this.state;
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
		// 11/04/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');

		let FIELD_INDEX      : number  = 0;
		let DATA_VALUE       : string  = '';
		let DATA_FIELD       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let FORMAT_MAX_LENGTH: number  = null;
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
				FORMAT_MAX_LENGTH = Sql.ToInteger(layout.FORMAT_MAX_LENGTH);
				// 10/05/2021 Paul.  Add support for regular expression validation. 
				FIELD_VALIDATOR_MESSAGE = Sql.ToString (layout.FIELD_VALIDATOR_MESSAGE);
				VALIDATION_TYPE         = Sql.ToString (layout.VALIDATION_TYPE        );
				REGULAR_EXPRESSION      = Sql.ToString (layout.REGULAR_EXPRESSION     );
				ID = baseId + '_' + DATA_FIELD;
				if ( row != null )
				{
					if ( row[DATA_FIELD] != null )
					{
						DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			popupOpen        : false,
			ID               ,
			FIELD_INDEX      ,
			DATA_VALUE       ,
			DATA_FIELD       ,
			UI_REQUIRED      ,
			FORMAT_TAB_INDEX ,
			FORMAT_MAX_LENGTH,
			VALUE_MISSING    : false,
			ENABLED          ,
			items            : [],
			// 10/05/2021 Paul.  Add support for regular expression validation. 
			FIELD_VALIDATOR_MESSAGE,
			VALIDATION_TYPE        ,
			REGULAR_EXPRESSION     ,
			VALIDATOR_FAILED : false,
		};
		//document.components[sID] = this;
	}
	
	componentWillUnmount()
	{
		//delete document.components[this.state.ID];
	}

	async componentDidMount()
	{
		const { DATA_FIELD } = this.state;
		if ( this.props.fieldDidMount )
		{
			this.props.fieldDidMount(DATA_FIELD, this);
		}
	}

	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: IZipCodePopupState)
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
		else if ( nextState.items != this.state.items )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, items, nextProps, nextState);
			return true;
		}
		else if ( nextState.popupOpen != this.state.popupOpen )
		{
			return true;
		}
		return false;
	}

	private _onChange = (value): void =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD + ' = ' + Sql.ToString(value));
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

	private _onSelect = (value: { Action: string, ID: string, NAME: string }) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect ' + DATA_FIELD + ' ' + DISPLAY_FIELD, value);
		try
		{
			if ( value.Action == 'SingleSelect' )
			{
				// 07/23/2019.  Apply Field Level Security. 
				if ( ENABLED )
				{
					this.setState({ popupOpen: false, DATA_VALUE: value.NAME }, this.validate);
					// 08/09/2019 Paul.  After seleciton, do a lookup to get all the fields we need to update dependent items. 
					let sSORT_FIELDS  : string = 'NAME';
					let sSELECT_FIELDS: string = 'ID,NAME,CITY,STATE,COUNTRY';
					let sSEARCH_FILTER: string = 'ID = \'' + value.ID + '\'';
					ListView_LoadModulePaginated('ZipCodes', sSORT_FIELDS, 'asc', sSELECT_FIELDS, sSEARCH_FILTER, null, 1, 0, false, false).then((d) =>
					{
						if ( d.results.length == 1 )
						{
							let item = d.results[0];
							//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect ' + DATA_FIELD, item);
							onChanged(DATA_FIELD, value.NAME);
							onUpdate (DATA_FIELD, value.NAME, item);
						}
					})
					.catch((error) =>
					{
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', error);
					});
				}
				else
				{
					console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect ACCESS DENIED for ' + DATA_FIELD, value);
					this.setState({ popupOpen: false });
				}
			}
			else if ( value.Action == 'Close' )
			{
				this.setState({ popupOpen: false });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', error);
		}
	}

	private _onSelectClick = (): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectClick ' + DATA_FIELD + ' ' + DISPLAY_FIELD, DATA_VALUE, DISPLAY_VALUE, row);
		this.setState({ popupOpen: true });
	}

	private _onTextChange = (event, value) =>
	{
		const { ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange ' + DATA_FIELD, value);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.PartialInput = true;
				this.setState({ DATA_VALUE: value }, () =>
				{
					// 04/23/2019 Paul.  Try and prevent debounce by saving last query value. 
					this.LastQuery = value;
					// 08/09/2019 Paul.  As the zipcode database is not that large, we are going to search after first character. 
					if ( value.length >= 1 )
					{
						let sSORT_FIELDS  : string = 'NAME';
						let sSELECT_FIELDS: string = 'ID,NAME,CITY,STATE,COUNTRY';
						let sSEARCH_FILTER: string = 'NAME like \'' + Sql.EscapeSQLLike(value) + '%\'';
						// 04/23/2019 Paul.  Only request 12 records.  This is not configurable. 
						ListView_LoadModulePaginated('ZipCodes', sSORT_FIELDS, 'asc', sSELECT_FIELDS, sSEARCH_FILTER, null, 12, 0, false, false).then((d) =>
						{
							if ( this.LastQuery == value )
							{
								//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange ' + MODULE_TYPE + ' ' + DATA_FIELD, d.results);
								this.setState({ items: d.results });
							}
						})
						.catch((error) =>
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange', error);
						});
					}
					else
					{
						this.setState({ items: [] });
					}
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange', error);
		}
	}

	private _onGetItemValue = (item) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGetItemValue ' + DATA_FIELD, item);
		return item.NAME;
	}

	private _onTextSelect = (value, item) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect ' + DATA_FIELD, value, item);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.PartialInput = false;
				this.setState({ DATA_VALUE: item.NAME }, this.validate);
				// 08/09/2019 Paul.  After seleciton, do a lookup to get all the fields we need to update dependent items. 
				let sSORT_FIELDS  : string = 'NAME';
				let sSELECT_FIELDS: string = 'ID,NAME,CITY,STATE,COUNTRY';
				let sSEARCH_FILTER: string = 'NAME = \'' + item.NAME + '\'';
				ListView_LoadModulePaginated('ZipCodes', sSORT_FIELDS, 'asc', sSELECT_FIELDS, sSEARCH_FILTER, null, 1, 0, false, false).then((d) =>
				{
					if ( d.results.length > 0 )
					{
						let item = d.results[0];
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect ' + DATA_FIELD, item);
						onChanged(DATA_FIELD, item.NAME);
						onUpdate (DATA_FIELD, item.NAME, item);
					}
				})
				.catch((error) =>
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect', error);
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect', error);
		}
	}

	private _onTextBlur = (event) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD, DATA_VALUE, items, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextBlur ' + DATA_FIELD, event);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				if ( this.PartialInput )
				{
					this.PartialInput = false;
					let item: any = { NAME: DATA_VALUE };
					// 04/26/2019 Paul.  If empty, then clear item. 
					if ( Sql.IsEmptyString(DATA_VALUE) )
					{
						item = { NAME: '' };
					}
					// 04/26/2019 Paul.  If items were found, then take the first item.  Otherwise use previous values. 
					else if ( items != null && items.length > 0 )
					{
						item = items[0];
					}
					this.setState({ DATA_VALUE: item.NAME }, this.validate);
					if ( !Sql.IsEmptyString(item.NAME) )
					{
						// 08/09/2019 Paul.  After seleciton, do a lookup to get all the fields we need to update dependent items. 
						let sSORT_FIELDS  : string = 'NAME';
						let sSELECT_FIELDS: string = 'ID,NAME,CITY,STATE,COUNTRY';
						let sSEARCH_FILTER: string = 'NAME = \'' + item.NAME + '\'';
						ListView_LoadModulePaginated('ZipCodes', sSORT_FIELDS, 'asc', sSELECT_FIELDS, sSEARCH_FILTER, null, 1, 0, false, false).then((d) =>
						{
							if ( d.results.length == 1 )
							{
								item = d.results[0];
								//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextBlur ' + DATA_FIELD, item);
								onChanged(DATA_FIELD, item.NAME);
								onUpdate (DATA_FIELD, item.NAME, item);
							}
						})
						.catch((error) =>
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect', error);
						});
					}
					else
					{
						onChanged(DATA_FIELD, item.NAME);
						onUpdate (DATA_FIELD, item.NAME, item);
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextBlur', error);
		}
	}

	private _onRenderMenu = (children) =>
	{
		return(<div style={ { backgroundColor: '#efefef', border: '0 solid black'} }>
			{children}
		</div>);
	}

	private _onRenderItem = (item, isHighlighted) =>
	{
		let cssHighlighed: any = {};
		if ( isHighlighted )
			cssHighlighed = { color: 'white', backgroundColor: '#4095bf' };
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRenderItem', cssHighlighed, item);
		return (<div key={ item.ID } className='ui-menu-item' style={cssHighlighed}>
			{ item.NAME }
		</div>);
	}

	private _onMenuVisibilityChange = (isOpen) =>
	{
		// 04/26/2019 Paul.  Clearn menu on exit. 
		if ( !isOpen )
		{
			this.setState({ items: [] });
		}
	}

	// 08/07/2019 Paul.  Enter is the same as blur. 
	private _onKeyDown = (event) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' )
		{
			this._onTextBlur(null);
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged  } = this.props;
		// 10/05/2021 Paul.  Add support for regular expression validation. 
		const { ID, FIELD_INDEX, DATA_VALUE, DATA_FIELD, UI_REQUIRED, FORMAT_TAB_INDEX, FORMAT_MAX_LENGTH, VALUE_MISSING, ENABLED, CSS_CLASS, items, popupOpen, FIELD_VALIDATOR_MESSAGE, VALIDATOR_FAILED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for ZipCodePopup FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for ZipCodePopup DATA_FIELD { DATA_FIELD }</span>);
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
					maxLength   : (FORMAT_MAX_LENGTH > 0 ? FORMAT_MAX_LENGTH : null), 
					tabIndex    : FORMAT_TAB_INDEX,
					style       : {flex: '2 0 70%', width: '100%', marginRight: '2px', minWidth: '150px'},
					autoComplete: 'off',
					onBlur      : this._onTextBlur,
					onKeyDown   : this._onKeyDown,
				};
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// 04/24/2019 Paul.  Speech has been deprecated. 
				// 09/21/2019 Paul.  d-lg-none to hide when large screen. 
				// 11/14/2019 Paul.  Use smaller icons when on 3 column layouts. 
				let sIconClass  : string = 'd-lg-none';
				let sButtonClass: string = 'd-none d-lg-inline';
				if ( Sql.ToInteger(this.props.layout.DATA_COLUMNS) > 2 )
				{
					// https://getbootstrap.com/docs/4.3/utilities/display/
					sIconClass   = 'd-xl-none';
					sButtonClass = 'd-none d-xl-inline';
				}
				// 11/04/2020 Paul.  Enable flexWrap as it is causing overlap with following cell. 
				return (
					<span className={ CSS_CLASS } style={ {display: 'flex', flexWrap: 'wrap', flexBasis: '100%', alignItems: 'baseline'} }>
						<PopupView
							isOpen={ popupOpen }
							callback={ this._onSelect }
							MODULE_NAME='ZipCodes'
						/>
						<AutoComplete
							id={ ID }
							key={ ID }
							value={ DATA_VALUE ? DATA_VALUE : '' }
							items={ items }
							inputProps={ inputProps }
							wrapperStyle={ {} }
							autoHighlight={ false }
							getItemValue={ this._onGetItemValue }
							onChange={ this._onTextChange }
							onSelect={ this._onTextSelect }
							renderMenu={ this._onRenderMenu }
							renderItem={ this._onRenderItem }
							onMenuVisibilityChange={ this._onMenuVisibilityChange }
							disabled={ !ENABLED }
						/>
						<button
							id={ ID + '_btnChange' }
							key={ ID + '_btnChange' }
							style={ {marginLeft: '4px'} }
							onClick={ this._onSelectClick }
							disabled={ !ENABLED }
							className='button'>
							{ this.legacyIcons
							? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
							: <FontAwesomeIcon icon='edit' className={ sIconClass } />
							}
							<span className={ sButtonClass }>{ L10n.Term('ZipCodes.LBL_LOOKUP_BUTTON_LABEL') }</span>
						</button>
						{ UI_REQUIRED ? <span id={ ID + '_REQUIRED' } key={ ID + '_REQUIRED' } className='required' style={ cssRequired } >{ L10n.Term('.ERR_REQUIRED_FIELD') }</span> : null }
						{ VALIDATOR_FAILED ? <span id={ ID + '_VALIDATOR' } key={ ID + '_VALIDATOR' } className='required' style={ cssRequired } >{ L10n.Term(FIELD_VALIDATOR_MESSAGE) }</span> : null }
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

