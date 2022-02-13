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
import AutoComplete                           from 'react-autocomplete'      ;
// 2. Store and Types. 
import { IEditComponentProps, EditComponent } from '../types/EditComponent'  ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'          ;
import L10n                                   from '../scripts/L10n'         ;
import { ListView_LoadModulePaginated }       from '../scripts/ListView'     ;
// 4. Components and Views. 

interface IModuleAutoCompleteProps extends IEditComponentProps
{
	DATA_VALUE?       : string;
}

interface IModuleAutoCompleteState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	DATA_VALUE       : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	FORMAT_MAX_LENGTH: number;
	MODULE_TYPE      : string;
	VALUE_MISSING    : boolean;
	items            : any[];
	ENABLED          : boolean;
	CSS_CLASS?       : string;
	rowDefaultSearch?: null;
}

export default class ModuleAutoComplete extends EditComponent<IModuleAutoCompleteProps, IModuleAutoCompleteState>
{
	private LastQuery: string;
	private PartialInput: boolean;
	private input = React.createRef<HTMLInputElement>();

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
		else if ( PROPERTY_NAME == 'rowDefaultSearch' )
		{
			this.setState({ rowDefaultSearch: DATA_VALUE });
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
				DATA_VALUE: ''
			});
		}
	}

	constructor(props: IModuleAutoCompleteProps)
	{
		super(props);
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let FORMAT_MAX_LENGTH: number  = null;
		let MODULE_TYPE      : string  = null;
		let ENABLED          : boolean = props.bIsWriteable;

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX      );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD       );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED      ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX );
				FORMAT_MAX_LENGTH = Sql.ToInteger(layout.FORMAT_MAX_LENGTH);
				MODULE_TYPE       = Sql.ToString (layout.MODULE_TYPE      );
				ID = baseId + '_' + DATA_FIELD;

				if ( row != null )
				{
					DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
				}
				else if ( row == null )
				{
					DATA_VALUE = Sql.ToString(props.DATA_VALUE);
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
			FORMAT_MAX_LENGTH,
			MODULE_TYPE      ,
			VALUE_MISSING    : false,
			ENABLED          ,
			items            : [],
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

	shouldComponentUpdate(nextProps: IModuleAutoCompleteProps, nextState: IModuleAutoCompleteState)
	{
		const { DATA_FIELD, DATA_VALUE, VALUE_MISSING, items } = this.state;
		if ( nextProps.row != this.props.row )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, DISPLAY_VALUE,nextProps, nextState);
			return true;
		}
		else if ( nextProps.layout != this.props.layout )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, DISPLAY_VALUE,nextProps, nextState);
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
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, DISPLAY_VALUE, nextProps, nextState);
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
		else if ( JSON.stringify(nextState.rowDefaultSearch) != JSON.stringify(this.state.rowDefaultSearch) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, rowDefaultSearch, nextProps, nextState);
			return true;
		}
		return false;
	}

	componentDidCatch(error, info)
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch ' + DATA_FIELD, error, info);
	}

	private _onTextChange = (event, value) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, MODULE_TYPE, ENABLED } = this.state;
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.PartialInput = true;
				this.setState({ DATA_VALUE: value }, () =>
				{
					// 05/02/2019 Paul.  With autocomplete, partial and wildcards are still allowed, so send to parent. 
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange ' + DATA_FIELD, value);
					onChanged(DATA_FIELD, value);
					onUpdate (DATA_FIELD, value);
					// 04/23/2019 Paul.  Try and prevent debounce by saving last query value. 
					this.LastQuery = value;
					// 04/23/2019 Paul.  Must specify at least 2 characters for search to execute. 
					if ( value.length >= 2 )
					{
						let sSORT_FIELDS  : string = 'NAME';
						let sSELECT_FIELDS: string = 'ID,NAME';
						let sSEARCH_FILTER: string = 'NAME like \'' + Sql.EscapeSQLLike(value) + '%\'';
						// 04/23/2019 Paul.  Only request 12 records.  This is not configurable. 
						if ( MODULE_TYPE == 'Users' )
						{
							sSORT_FIELDS = 'USER_NAME';
							sSELECT_FIELDS = 'ID,USER_NAME';
							sSEARCH_FILTER = 'USER_NAME like \'' + Sql.EscapeSQLLike(value) + '%\'';
						}
						ListView_LoadModulePaginated(MODULE_TYPE, sSORT_FIELDS, 'asc', sSELECT_FIELDS, sSEARCH_FILTER, null, 12, 0, false, false).then((d) =>
						{
							if ( this.LastQuery == value )
							{
								if ( MODULE_TYPE == 'Users' )
								{
									for ( let nRow in d.results )
									{
										let row = d.results[nRow];
										row['NAME'] = row['USER_NAME'];
									}
								}
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
		const { DATA_FIELD } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGetItemValue ' + DATA_FIELD, item);
		return item.NAME;
	}

	private _onTextSelect = (value, item) =>
	{
		const { onChanged, onUpdate, Page_Command } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, MODULE_TYPE, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect ' + DATA_FIELD, value, item);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.PartialInput = false;
				this.setState({ DATA_VALUE: item.NAME }, this.validate);
				onChanged(DATA_FIELD, item.NAME);
				onUpdate (DATA_FIELD, item.NAME);
				// 11/21/2021 Paul.  Use Page_Command to send AutoComplete selection event. 
				if ( Page_Command )
				{
					Page_Command('AutoComplete', { FIELD_NAME: DATA_FIELD, MODULE_NAME: MODULE_TYPE, VALUE: item.NAME} );
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect', error);
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
		return (<div key={ item.ID } className="ui-menu-item" style={cssHighlighed}>
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

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, MODULE_TYPE, UI_REQUIRED, FORMAT_TAB_INDEX, FORMAT_MAX_LENGTH, VALUE_MISSING, ENABLED, CSS_CLASS, items } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, DATA_VALUE, row);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for ModuleAutoComplete FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for ModuleAutoComplete DATA_FIELD { DATA_FIELD }</span>);
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
					autoComplete: 'off',
					style       : {width: '100%', minWidth: '150px'},
					onKeyDown   : this._onKeyDown
					//onBlur: this._onTextBlur
				};
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// 04/26/2019 Paul.  Speech appears to be deprecated. 
				//let bEnableSpeech = Crm_Config.enable_speech();
				//let cssSpeech = {};
				//if (bEnableSpeech)
				//{
				//	cssSpeech = { speech: 'speech' };
				//}
				// 05/16/2018 Paul.  Defer submit key. 
				//if ( sSubmitID != null )
				//{
				//	txt.onkeypress = function(e)
				//	{
				//		return RegisterEnterKeyPress(e, sSubmitID);
				//	};
				//}

				// https://developer.microsoft.com/en-us/fabric#/components/pickers
				return (
					<span className={ CSS_CLASS } style={ { flex: '2 0 70%', marginRight: '2px' } }>
						<AutoComplete
							id={ ID }
							key={ ID }
							ref={ this.input }
							value={ DATA_VALUE ? DATA_VALUE : '' }
							items={ items }
							inputProps={ inputProps }
							wrapperStyle={ {width: '100%'} }
							autoHighlight={ false }
							getItemValue={ this._onGetItemValue }
							onChange={ this._onTextChange }
							onSelect={ this._onTextSelect }
							renderMenu={ this._onRenderMenu }
							renderItem={ this._onRenderItem }
							onMenuVisibilityChange={ this._onMenuVisibilityChange }
							disabled={ !ENABLED }
						/>
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

