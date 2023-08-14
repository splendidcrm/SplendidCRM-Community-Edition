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
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
import { IEditComponentProps, EditComponent } from '../types/EditComponent'        ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                ;
import L10n                                   from '../scripts/L10n'               ;
import Security                               from '../scripts/Security'           ;
import Credentials                            from '../scripts/Credentials'        ;
import SplendidCache                          from '../scripts/SplendidCache'      ;
import { Crm_Config, Crm_Modules }            from '../scripts/Crm'                ;
// 4. Components and Views. 
// 01/21/2021 Paul.  Add support for dynamic popups to match ModulePopup. 
import DynamicPopupView                       from '../views/DynamicPopupView'     ;

// 01/21/2021 Paul.  A customer needs to know if the PopupView is being called from a SearchView or and EditView. 
interface IChangeButtonProps extends IEditComponentProps
{
	isSearchView?    : boolean;
}

interface IChangeButtonState
{
	popupOpen        : boolean;
	ID               : string;
	EDIT_NAME        : string;
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	DATA_LABEL       : string;
	DATA_VALUE       : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	FORMAT_MAX_LENGTH: number;
	FORMAT_ROWS      : number;
	FORMAT_COLUMNS   : number;
	DISPLAY_FIELD    : string;
	DISPLAY_VALUE    : string;
	MODULE_TYPE      : string;
	LIST_VALUES      : any[];
	VALUE_MISSING    : boolean;
	ENABLED          : boolean;
	CSS_CLASS?       : string;
	rowDefaultSearch?: null;
}

export default class ChangeButton extends EditComponent<IChangeButtonProps, IChangeButtonState>
{
	private themeURL: string = null;
	private legacyIcons: boolean = false;

	public get data(): any
	{
		const { DATA_FIELD, DATA_LABEL, DATA_VALUE, MODULE_TYPE } = this.state;
		let arr = [];
		if ( DATA_LABEL == 'PARENT_TYPE' )
		{
			// 08/25/2019 Paul.  If no value selected, then don't return the parent type. 
			if ( Sql.IsEmptyGuid(DATA_VALUE) )
			{
				arr.push({ key: DATA_LABEL, value: null });
			}
			else
			{
				arr.push({ key: DATA_LABEL, value: MODULE_TYPE });
			}
		}
		arr.push({ key: DATA_FIELD, value: DATA_VALUE });
		return arr;
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
		// 08/07/2023 Paul.  Match ModulePopup update features. 
		else if ( PROPERTY_NAME == 'ID' )
		{
			this.setState({ DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'NAME' )
		{
			this.setState({ DISPLAY_VALUE: DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'MODULE_TYPE' )
		{
			this.setState({ MODULE_TYPE: DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'LIST_VALUES' )
		{
			this.setState({ LIST_VALUES: DATA_VALUE });
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
		let { MODULE_TYPE } = this.state;
		const { DATA_LABEL, LIST_VALUES, ENABLED } = this.state;
		// 01/11/2020.  Apply Field Level Security. 
		if ( ENABLED )
		{
			if ( DATA_LABEL == 'PARENT_TYPE' )
			{
				if ( LIST_VALUES != null && LIST_VALUES.length > 0 )
				{
					MODULE_TYPE = LIST_VALUES[0].key;
				}
			}
			this.setState(
			{
				DATA_VALUE   : null, 
				DISPLAY_VALUE: '', 
				MODULE_TYPE  , 
			});
		}
	}

	constructor(props: IChangeButtonProps)
	{
		super(props);
		// 11/04/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');

		let EDIT_NAME        : string  = '';
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_LABEL       : string  = '';
		let DATA_VALUE       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let FORMAT_MAX_LENGTH: number  = null;
		let FORMAT_ROWS      : number  = null;
		let FORMAT_COLUMNS   : number  = null;
		let DISPLAY_FIELD    : string  = '';
		let DISPLAY_VALUE    : string  = '';
		let MODULE_TYPE      : string  = '';
		let LIST_VALUES      : any[]   = [];
		let ENABLED          : boolean = props.bIsWriteable;

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this.props;
			if ( layout != null )
			{
				EDIT_NAME         = Sql.ToString (layout.EDIT_NAME        );
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX      );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD       );
				DATA_LABEL        = Sql.ToString (layout.DATA_LABEL       );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED      ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX );
				FORMAT_MAX_LENGTH = Sql.ToInteger(layout.FORMAT_MAX_LENGTH);
				FORMAT_ROWS       = Sql.ToInteger(layout.FORMAT_ROWS      );
				FORMAT_COLUMNS    = Sql.ToInteger(layout.FORMAT_COLUMNS   );
				DISPLAY_FIELD     = Sql.ToString (layout.DISPLAY_FIELD    );
				DISPLAY_VALUE     = Sql.ToString (layout.DISPLAY_VALUE    );
				MODULE_TYPE       = Sql.ToString (layout.MODULE_TYPE      );
				ID = baseId + '_' + DATA_FIELD;

				// 07/19/2019 Paul.  Defer row loading to componentDidMount so that we can do an async ItemName lookup if necessary. 
				if ( row == null )
				{
					if ( MODULE_TYPE == 'Teams' )
					{
						DATA_VALUE    = Security.TEAM_ID();
						DISPLAY_VALUE = Security.TEAM_NAME();
					}
					else if ( MODULE_TYPE == 'Users' )
					{
						DATA_VALUE    = Security.USER_ID()
						// 01/29/2011 Paul.  If Full Names have been enabled, then prepopulate with the full name. 
						if ( DISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
						{
							DISPLAY_VALUE = Security.FULL_NAME();
						}
						else
						{
							DISPLAY_VALUE = Security.USER_NAME();
						}
					}
				}
				// 08/10/2020 Paul.  Special requirement flags for Teams and Users. 
				// 12/17/2020 Paul.  Don't force the requirements flags on an update panel or search panel. 
				if ( layout.EDIT_NAME.indexOf('.MassUpdate') < 0 && layout.EDIT_NAME.indexOf('.Search') < 0  )
				{
					if ( MODULE_TYPE == 'Teams' )
					{
						let bRequireTeamManagement  : boolean = Crm_Config.require_team_management();
						if ( bRequireTeamManagement )
						{
							UI_REQUIRED = true;
						}
					}
					else if ( MODULE_TYPE == 'Users' )
					{
						let bRequireUserAssignment  : boolean = Crm_Config.require_user_assignment();
						if ( bRequireUserAssignment )
						{
							UI_REQUIRED = true;
						}
					}
				}
				if ( DATA_LABEL == 'PARENT_TYPE' )
				{
					let LIST_NAME: string = 'record_type_display';
					let arrLIST: string[] = L10n.GetList(LIST_NAME);
					if ( arrLIST != null )
					{
						for ( let i = 0; i < arrLIST.length; i++ )
						{
							let opt4 = { key: arrLIST[i], text: L10n.ListTerm(LIST_NAME, arrLIST[i]) };
							LIST_VALUES.push(opt4);
							// 03/17/2020 Paul.  Module Type is not optional, so we have to default to the first item. 
							if ( i == 0 )
							{
								MODULE_TYPE = arrLIST[i];
							}
						}
					}
				}
				// 11/18/2021 Paul.  Old layouts do not specify MODULE_TYPE, so we need to extract from ONCLICK_SCRIPT. 
				else if ( Sql.IsEmptyString(MODULE_TYPE) && !Sql.IsEmptyString(layout.ONCLICK_SCRIPT) )
				{
					let ONCLICK_SCRIPT: string = layout.ONCLICK_SCRIPT;
					ONCLICK_SCRIPT = ONCLICK_SCRIPT.replace('return Search' , '');
					ONCLICK_SCRIPT = ONCLICK_SCRIPT.replace('return Billing', '');
					ONCLICK_SCRIPT = ONCLICK_SCRIPT.replace('return ' , '' );
					ONCLICK_SCRIPT = ONCLICK_SCRIPT.replace('Popup();', 's');
					ONCLICK_SCRIPT = ONCLICK_SCRIPT.replace('ProductCatalogs', 'ProductCatalog');
					MODULE_TYPE = ONCLICK_SCRIPT;
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
			popupOpen        : false,
			ID               ,
			EDIT_NAME        ,
			FIELD_INDEX      ,
			DATA_FIELD       ,
			DATA_LABEL       ,
			DATA_VALUE       ,
			UI_REQUIRED      ,
			FORMAT_TAB_INDEX ,
			FORMAT_MAX_LENGTH,
			FORMAT_ROWS      ,
			FORMAT_COLUMNS   ,
			DISPLAY_FIELD    ,
			DISPLAY_VALUE    ,
			MODULE_TYPE      ,
			LIST_VALUES      ,
			VALUE_MISSING    : false,
			ENABLED          ,
		};
		//document.components[ID] = this;
	}

	async componentDidMount()
	{
		const { layout, row } = this.props;
		const { DATA_FIELD, DATA_LABEL, DISPLAY_FIELD, MODULE_TYPE, LIST_VALUES } = this.state;
		try
		{
			if ( row != null )
			{
				let sMODULE_TYPE: string = MODULE_TYPE;
				if ( DATA_LABEL == 'PARENT_TYPE' )
				{
					sMODULE_TYPE = Sql.ToString(row[DATA_LABEL]);
					// 03/17/2020 Paul.  Module Type is not optional, so we have to default to the first item. 
					if ( Sql.IsEmptyString(sMODULE_TYPE) && LIST_VALUES != null && LIST_VALUES.length > 0 )
					{
						sMODULE_TYPE = LIST_VALUES[0].key;
					}
				}
				let value: any = await this.getValue(layout, row, DATA_FIELD, DISPLAY_FIELD, sMODULE_TYPE);
				this.setState(
				{
					DATA_VALUE   : value.DATA_VALUE   ,
					DISPLAY_VALUE: value.DISPLAY_VALUE,
					MODULE_TYPE  : value.MODULE_TYPE  ,
				});
			}
			if ( this.props.fieldDidMount )
			{
				this.props.fieldDidMount(DATA_FIELD, this);
			}
		}
		catch(error)
		{
		}
	}
	
	componentWillUnmount()
	{
		//delete document.components[this.state.ID];
	}

	shouldComponentUpdate(nextProps: IChangeButtonProps, nextState: IChangeButtonState)
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
		else if ( nextState.DISPLAY_VALUE != this.state.DISPLAY_VALUE )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.MODULE_TYPE != this.state.MODULE_TYPE )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.VALUE_MISSING != this.state.VALUE_MISSING || nextState.ENABLED != this.state.ENABLED )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, VALUE_MISSING, nextProps, nextState);
			return true;
		}
		// 01/08/2020 Paul.  Use stringify to compare arrays. 
		else if ( JSON.stringify(nextState.LIST_VALUES) != JSON.stringify(this.state.LIST_VALUES) || JSON.stringify(nextState.rowDefaultSearch) != JSON.stringify(this.state.rowDefaultSearch) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, LIST_VALUES, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		else if ( nextState.popupOpen != this.state.popupOpen )
		{
			return true;
		}
		return false;
	}

	private getValue = async (layout: any, row: any, DATA_FIELD: string, DISPLAY_FIELD: string, MODULE_TYPE: string) =>
	{
		let value: any = { DATA_VALUE: null, DISPLAY_VALUE: '', MODULE_TYPE: MODULE_TYPE };
		if ( layout != null )
		{
			let EDIT_NAME = Sql.ToString(layout.EDIT_NAME);
			if ( row != null )
			{
				if ( !Sql.IsEmptyString(DISPLAY_FIELD) && row[DISPLAY_FIELD] != null )
				{
					value.DISPLAY_VALUE = Sql.ToString(row[DISPLAY_FIELD]);
				}
				else if ( row[DATA_FIELD] != null )
				{
					value.DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
					if ( row[DISPLAY_FIELD] === undefined && !Sql.IsEmptyString(value.DATA_VALUE) && !Sql.IsEmptyString(MODULE_TYPE) )
					{
						// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
						try
						{
							value.DISPLAY_VALUE = await Crm_Modules.ItemName(MODULE_TYPE, value.DATA_VALUE);
						}
						catch(error)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue', error);
							value.DISPLAY_VALUE = error.message;
						}
					}
				}
				// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
				// 04/14/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
				if ( Sql.ToBoolean(row['DetailViewRelationshipCreate']) )
				{
					if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'TEAM_ID' )
					{
						if ( Crm_Config.ToBoolean('inherit_team') && !Sql.IsEmptyString(row[DATA_FIELD]) )
						{
							value.DISPLAY_VALUE = row['TEAM_NAME'];
						}
						else
						{
							value.DISPLAY_VALUE = Security.TEAM_NAME();
						}
					}
					else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'ASSIGNED_USER_ID' )
					{
						if (Crm_Config.ToBoolean('inherit_assigned_user') && !Sql.IsEmptyString(row[DATA_FIELD]))
						{
							if ( DISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
							{
								value.DISPLAY_VALUE = row['ASSIGNED_TO_NAME'];
							}
							else
							{
								value.DISPLAY_VALUE = row['ASSIGNED_TO'];
							}
						}
						else
						{
							if ( DISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
							{
								value.DISPLAY_VALUE = Security.FULL_NAME();
							}
							else
							{
								value.DISPLAY_VALUE = Security.USER_NAME();
							}
						}
					}
				}
			}
			else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'TEAM_ID' )
			{
				value.DISPLAY_VALUE = Security.TEAM_NAME();
			}
			else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'ASSIGNED_USER_ID' )
			{
				if ( DISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
				{
					value.DISPLAY_VALUE = Security.FULL_NAME();
				}
				else
				{
					value.DISPLAY_VALUE = Security.USER_NAME();
				}
			}
			if ( row != null )
			{
				if ( row[DATA_FIELD] != null )
				{
					value.DATA_VALUE = row[DATA_FIELD];
				}
				// 06/28/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
				if ( Sql.ToBoolean(row['DetailViewRelationshipCreate']) )
				{
					if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'TEAM_ID' )
					{
						if ( Crm_Config.ToBoolean('inherit_team') && !Sql.IsEmptyString(row[DATA_FIELD]) )
						{
							value.DATA_VALUE = Sql.ToString(row['TEAM_ID']);
						}
						else
						{
							value.DATA_VALUE = Security.TEAM_NAME();
						}
					}
					else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'ASSIGNED_USER_ID' )
					{
						if ( Crm_Config.ToBoolean('inherit_assigned_user') && !Sql.IsEmptyString(row[DATA_FIELD]) )
						{
							value.DATA_VALUE = Sql.ToString(row['ASSIGNED_USER_ID']);
						}
						else
						{
							value.DATA_VALUE = Security.USER_ID();
						}
					}
				}
			}
			else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'TEAM_ID' && !Sql.IsEmptyGuid(Security.TEAM_ID()) )
			{
				value.DATA_VALUE = Security.TEAM_ID();
			}
			else if (EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'ASSIGNED_USER_ID')
			{
				value.DATA_VALUE = Security.USER_ID();
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue ' + DATA_FIELD, value, row);
		return value;
	}

	private _onChange = (value: { Action: string, ID: string, NAME: string }) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_LABEL, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, row);
		if ( value.Action == 'SingleSelect' )
		{
			try
			{
				// 07/23/2019.  Apply Field Level Security. 
				if ( ENABLED )
				{
					this.setState({ popupOpen: false, DATA_VALUE: value.ID, DISPLAY_VALUE: value.NAME }, this.validate);
					onChanged(layout.DATA_FIELD   , value.ID  );
					onChanged(layout.DISPLAY_FIELD, value.NAME);
					if ( DATA_LABEL == 'PARENT_TYPE' )
					{
						onChanged(DATA_LABEL, MODULE_TYPE);
					}
					// 01/30/2020 Paul.  A contact may be dependent on an account. 
					onUpdate (DATA_FIELD, value.ID, value);
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
			}
		}
		else if (value.Action == 'Close')
		{
			this.setState({ popupOpen: false });
		}
	}

	private _onClear = (): void =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_LABEL, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClear ' + DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, row);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.clear();
				onChanged(DATA_FIELD   , null);
				onChanged(DISPLAY_FIELD, null);
				if ( DATA_LABEL == 'PARENT_TYPE' )
				{
					onChanged(DATA_LABEL, '');
				}
				// 01/30/2020 Paul.  A contact may be dependent on an account. 
				onUpdate (DATA_FIELD, null, {});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onClear', error);
		}
	}

	private _onSelect = (): void =>
	{
		const { ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect ' + DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, row);
		// 07/23/2019.  Apply Field Level Security. 
		if ( ENABLED )
		{
			this.setState({ popupOpen: true });
		}
	}

	private _onSelectChange = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, DATA_LABEL, DISPLAY_FIELD, ENABLED } = this.state;
		try
	{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				let value = event.target.value;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectChange ' + DATA_FIELD, value);
				// 08/25/2019 Paul.  Primary values will get reset when the module changes. 
				this.setState({ DATA_VALUE: null, DISPLAY_VALUE: '', MODULE_TYPE: value }, this.validate);
				onChanged(DATA_LABEL   , value);
				onChanged(DATA_FIELD   , null);
				onChanged(DISPLAY_FIELD, null);
				// 01/30/2020 Paul.  A contact may be dependent on an account. 
				onUpdate (DATA_FIELD, null, {});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectChange', error);
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged, isSearchView } = this.props;
		const { popupOpen, EDIT_NAME, ID, FIELD_INDEX, DATA_FIELD, DATA_LABEL, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE, UI_REQUIRED, FORMAT_TAB_INDEX, FORMAT_MAX_LENGTH, VALUE_MISSING, LIST_VALUES, ENABLED, CSS_CLASS, rowDefaultSearch } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, MODULE_TYPE, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, row);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for ChangeButton FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for ChangeButton DATA_FIELD { DATA_FIELD }</span>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				// 10/18/2011 Paul.  A custom field will not have a display name. 
				var sTEMP_DISPLAY_FIELD = baseId + '_' + (Sql.IsEmptyString(DISPLAY_FIELD) ? DATA_FIELD + '_NAME' : DISPLAY_FIELD);
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// 11/14/2019 Paul.  Use smaller icons when on 3 column layouts. 
				let sIconClass  : string = 'd-lg-none';
				let sButtonClass: string = 'd-none d-lg-inline';
				if ( Sql.ToInteger(this.props.layout.DATA_COLUMNS) > 2 )
				{
					// https://getbootstrap.com/docs/4.3/utilities/display/
					sIconClass   = 'd-xl-none';
					sButtonClass = 'd-none d-xl-inline';
				}
				if ( DATA_LABEL == 'PARENT_TYPE' )
				{
					let LABEL_WIDTH : string = layout.LABEL_WIDTH;
					let FIELD_WIDTH : string = layout.FIELD_WIDTH;
					let DATA_COLUMNS: number = Sql.ToInteger(layout.DATA_COLUMNS);
					let nLABEL_WIDTH: number = parseInt(LABEL_WIDTH.replace('%', ''));
					let nFIELD_WIDTH: number = parseInt(FIELD_WIDTH.replace('%', ''));
					LABEL_WIDTH = (nLABEL_WIDTH * DATA_COLUMNS) + '%';
					FIELD_WIDTH = (nFIELD_WIDTH * DATA_COLUMNS) + '%';
					// 09/21/2019 Paul.  d-lg-none to hide when large screen. 
					// 01/08/2020 Paul.  Remove display: flex from div around select as it causes it to be very tall. 
					// 10/29/2020 Paul.  Reduce width to 60% to match ModulePopup. 
					// 11/04/2020 Paul.  Enable flexWrap as it is causing overlap with following cell. 
					// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
					// 05/07/2021 Paul.  Now that we are using tables instead of flex, we need to flex wrap the PARENT_TYPE. 
					return (
						<div style={ {display: 'flex'} }>
							<div className={ CSS_CLASS } style={ {flexFlow: 'row wrap', flex: '1 0 30%'} }>
								<select
									id={ ID + '_PARENT_TYPE' }
									key={ ID + '_PARENT_TYPE' }
									tabIndex={ FORMAT_TAB_INDEX }
									onChange={ this._onSelectChange }
									value={ MODULE_TYPE ? MODULE_TYPE : '' }
									disabled={ !ENABLED }
								>
									{
										LIST_VALUES.map((item, index) => 
										{
											return (<option id={ID + '_PARENT_TYPE' + '_' + index.toString()} key={ID + '_PARENT_TYPE' + '_' + index.toString()} value={item.key}>{item.text}</option>);
										})
									}
								</select>
							</div>
							<div className={ CSS_CLASS } style={ {display: 'flex', flexFlow: 'wrap', flexGrow: 1, flexShrink: 1, flexBasis: '70%', alignItems: 'baseline'} }>
								<DynamicPopupView
									isOpen={ popupOpen }
									isSearchView={ isSearchView }
									fromLayoutName={ EDIT_NAME }
									callback={ this._onChange }
									MODULE_NAME={ MODULE_TYPE }
									rowDefaultSearch={ rowDefaultSearch }
								/>
								<input
									id={ sTEMP_DISPLAY_FIELD }
									key={ sTEMP_DISPLAY_FIELD }
									value={ DISPLAY_VALUE }
									type='text'
									style={ {flexGrow: 2, flexShrink: 1, flexBasis: '60%', minWidth: '100px'} }
									maxLength={ FORMAT_MAX_LENGTH > 0 ? FORMAT_MAX_LENGTH : null }
									tabIndex={ FORMAT_TAB_INDEX }
									readOnly={ true }
								/>
								<span style={ {flexGrow: 0, flexShrink: 1, flexBasis: '40%'} }>
									<button
										id={ ID + '_btnChange' }
										key={ ID + '_btnChange' }
										style={ {marginLeft: '4px'} }
										onClick={ this._onSelect }
										disabled={ !ENABLED }
										className='button'
									>
										{ this.legacyIcons
										? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
										: <FontAwesomeIcon icon='edit' className={ sIconClass } />
										}
										<span className={ sButtonClass }>{ L10n.Term('.LBL_SELECT_BUTTON_LABEL') }</span>
									</button>
									<button
										id={ ID + '_btnClear' }
										key={ ID + '_btnClear' }
										style={ {marginLeft: '4px'} }
										onClick={ this._onClear }
										disabled={ !ENABLED }
										className='button'
									>
										{ this.legacyIcons
										? <img src={ this.themeURL + 'decline_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
										: <FontAwesomeIcon icon='times' className={ sIconClass } />
										}
										<span className={ sButtonClass }>{L10n.Term('.LBL_CLEAR_BUTTON_LABEL')}</span>
									</button>
									{ UI_REQUIRED ? <span id={ ID + '_REQUIRED' } key={ ID + '_REQUIRED' } className='required' style={ cssRequired } > {L10n.Term('.ERR_REQUIRED_FIELD') }</span> : null}
								</span>
							</div>
						</div>
					);
				}
				else
				{
					// 11/12/2019 Paul.  Use flexShrink: 1 to prevent overflow into next cell. 
					// 06/23/2020 Paul.  Make use of minimum width. 
					// 11/04/2020 Paul.  Enable flexWrap as it is causing overlap with following cell. 
					// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
					return (
						<span className={ CSS_CLASS } style={ {display: 'flex', flexShrink: 0, flexWrap: 'wrap', flexBasis: '100%', alignItems: 'baseline'} }>
							<DynamicPopupView
								isOpen={ popupOpen }
								isSearchView={ isSearchView }
								fromLayoutName={ EDIT_NAME }
								callback={ this._onChange }
								MODULE_NAME={ MODULE_TYPE }
								rowDefaultSearch={ rowDefaultSearch }
							/>
							<input
								id={ sTEMP_DISPLAY_FIELD }
								key={ sTEMP_DISPLAY_FIELD }
								value={ DISPLAY_VALUE }
								type='text'
								style={ {flex: '2 0 60%', minWidth: '100px'} }
								maxLength={ FORMAT_MAX_LENGTH > 0 ? FORMAT_MAX_LENGTH : null }
								tabIndex={ FORMAT_TAB_INDEX }
								readOnly={ true }
							/>
							<span style={ {flexGrow: 0, flexShrink: 1, flexBasis: '40%'} }>
								<button
									id={ ID + '_btnChange' }
									key={ ID + '_btnChange' }
									style={ {marginLeft: '4px'} }
									onClick={ this._onSelect }
									disabled={ !ENABLED }
									className='button'
								>
									{ this.legacyIcons
									? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
									: <FontAwesomeIcon icon='edit' className={ sIconClass } />
									}
									<span className={ sButtonClass }>{ L10n.Term('.LBL_SELECT_BUTTON_LABEL') }</span>
								</button>
								<button
									id={ ID + '_btnClear' }
									key={ ID + '_btnClear' }
									style={ {marginLeft: '4px'} }
									onClick={ this._onClear }
									disabled={ !ENABLED }
									className='button'
								>
									{ this.legacyIcons
									? <img src={ this.themeURL + 'decline_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
									: <FontAwesomeIcon icon='times' className={ sIconClass } />
									}
									<span className={ sButtonClass }>{L10n.Term('.LBL_CLEAR_BUTTON_LABEL')}</span>
								</button>
								{ UI_REQUIRED ? <span id={ ID + '_REQUIRED' } key={ ID + '_REQUIRED' } className='required' style={ cssRequired } > {L10n.Term('.ERR_REQUIRED_FIELD') }</span> : null}
							</span>
						</span>
					);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
			return (<span>{ error.message }</span>);
		}
	}
}

