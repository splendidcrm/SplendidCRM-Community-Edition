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
import Security                               from '../scripts/Security'           ;
import Credentials                            from '../scripts/Credentials'        ;
import SplendidCache                          from '../scripts/SplendidCache'      ;
import SplendidDynamic                        from '../scripts/SplendidDynamic'    ;
import { Crm_Config, Crm_Modules }            from '../scripts/Crm'                ;
import { ListView_LoadModulePaginated }       from '../scripts/ListView'           ;
// 4. Components and Views. 
import DynamicPopupView                       from '../views/DynamicPopupView'     ;

// 04/23/2020 Paul.  A customer needs to know if the PopupView is being called from a SearchView or and EditView. 
interface IMoudlePopupProps extends IEditComponentProps
{
	//type?            : string;
	tableRow?        : boolean;
	onCheckboxClick? : any;
	onChanged        : (DATA_FIELD: string, DATA_VALUE: string, DISPLAY_FIELD: string, DISPLAY_VALUE: string, primary?: boolean ) => void;
	isSearchView?    : boolean;
	showCancel?      : boolean;
	disableClear?    : boolean;
	smallButtons?    : boolean;
	onCancel?        : () => void;
	value?           : any;
	// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
	allowCustomName? : boolean;
}

interface IModulePopupState
{
	popupOpen        : boolean;
	primary          : boolean;
	ID               : string;
	EDIT_NAME        : string;
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	DATA_VALUE       : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	FORMAT_MAX_LENGTH: number;
	FORMAT_ROWS      : number;
	FORMAT_COLUMNS   : number;
	DISPLAY_FIELD    : string;
	DISPLAY_VALUE    : string;
	MODULE_TYPE      : string;
	VALUE_MISSING    : boolean;
	items            : any[];
	ENABLED          : boolean;
	CSS_CLASS?       : string;
	rowDefaultSearch?: null;
}

export default class ModulePopup extends EditComponent<IMoudlePopupProps, IModulePopupState>
{
	private LastQuery: string;
	private PartialInput: boolean;
	private themeURL: string = null;
	private legacyIcons: boolean = false;

	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE, DISPLAY_VALUE } = this.state;
		// 06/30/2019 Paul.  Return null instead of empty string. 
		let key   = DATA_FIELD;
		let value = DATA_VALUE;
		if ( Sql.IsEmptyString(value) )
		{
			value = null;
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.data ' + DATA_FIELD, DATA_VALUE);
		// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
		if ( this.props.allowCustomName )
			return { key, value, name: DISPLAY_VALUE };
		else
			return { key, value };
	}

	public validate(): boolean
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, VALUE_MISSING, DISPLAY_VALUE } = this.state;
		let bVALUE_MISSING: boolean = false;
		let bUI_REQUIRED: boolean = UI_REQUIRED;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.props.bIsHidden )
		{
			bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE);
			// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
			if ( this.props.allowCustomName )
				bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE) && Sql.IsEmptyString(DISPLAY_VALUE);
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
			let DISPLAY_VALUE: string = DATA_VALUE;
			if ( item != null )
			{
				DISPLAY_VALUE = item.NAME;
			}
			this.setState({ DATA_VALUE, DISPLAY_VALUE });
		}
		else if ( PROPERTY_NAME == 'ID' )
		{
			this.setState({ DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'NAME' )
		{
			this.setState({ DISPLAY_VALUE: DATA_VALUE });
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
				DATA_VALUE   : '',
				DISPLAY_VALUE: '',
			});
		}
	}

	constructor(props: IMoudlePopupProps)
	{
		super(props);
		// 11/04/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');

		let EDIT_NAME        : string  = '';
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let FORMAT_MAX_LENGTH: number  = null;
		let FORMAT_ROWS      : number  = null;
		let FORMAT_COLUMNS   : number  = null;
		let DISPLAY_FIELD    : string  = '';
		let DISPLAY_VALUE    : string  = '';
		let MODULE_TYPE      : string  = '';
		let FIELD_TYPE       : string  = '';
		let ENABLED          : boolean = props.bIsWriteable;

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged, tableRow } = this.props;
			if ( layout != null )
			{
				EDIT_NAME         = Sql.ToString (layout.EDIT_NAME        );
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX      );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD       );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED      ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX );
				FORMAT_MAX_LENGTH = Sql.ToInteger(layout.FORMAT_MAX_LENGTH);
				FORMAT_ROWS       = Sql.ToInteger(layout.FORMAT_ROWS      );
				FORMAT_COLUMNS    = Sql.ToInteger(layout.FORMAT_COLUMNS   );
				DISPLAY_FIELD     = Sql.ToString (layout.DISPLAY_FIELD    );
				DISPLAY_VALUE     = Sql.ToString (layout.DISPLAY_VALUE    );
				MODULE_TYPE       = Sql.ToString (layout.MODULE_TYPE      );
				FIELD_TYPE        = Sql.ToString (layout.FIELD_TYPE       );
				ID = baseId + '_' + DATA_FIELD;
				if ( Sql.IsEmptyString(MODULE_TYPE) )
				{
					switch ( FIELD_TYPE )
					{
						case 'UserSelect'     :  MODULE_TYPE = 'Users'     ;  break;
						case 'TeamSelect'     :  MODULE_TYPE = 'Teams'     ;  break;
						// 07/10/2019 Paul.  We don't need to support KBTagSelect as it was deprecated. 
						case 'TagSelect'      :  MODULE_TYPE = 'Tags'      ;  break;
						case 'NAICSCodeSelect':  MODULE_TYPE = 'NAICSCodes';  break;
					}
				}
				// 04/27/2019 Paul.  Don't prepopulate here if Dynamic Teams or Users. 
				// 07/19/2019 Paul.  Defer row loading to componentDidMount so that we can do an async ItemName lookup if necessary. 
				if ( row == null && tableRow == null )
				{
					if ( MODULE_TYPE == 'Teams' )
					{
						DATA_VALUE    = Security.TEAM_ID();
						DISPLAY_VALUE = Security.TEAM_NAME();
					}
					else if ( MODULE_TYPE == 'Users' )
					{
						DATA_VALUE    = Security.USER_ID();
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
				// 06/19/2021 Paul.  WorkflowAlertShells does not require Team or User. 
				if ( layout.EDIT_NAME.indexOf('.MassUpdate') < 0 && layout.EDIT_NAME.indexOf('.Search') < 0 && layout.EDIT_NAME.indexOf('WorkflowAlertShells') < 0 )
				{
					if ( MODULE_TYPE == 'Teams' )
					{
						let bRequireTeamManagement  : boolean = Crm_Config.require_team_management();
						// 10/08/2020 Paul.  DEFAULT_TEAM_ID on the Users.EditView.Settings layout is not required. 
						// 02/08/2021 Paul.  The field is DEFAULT_TEAM, not DEFAULT_TEAM_ID. 
						if ( bRequireTeamManagement && DATA_FIELD != 'DEFAULT_TEAM' )
						{
							UI_REQUIRED = true;
						}
					}
					else if ( MODULE_TYPE == 'Users' )
					{
						let bRequireUserAssignment  : boolean = Crm_Config.require_user_assignment();
						// 10/12/2020 Paul.  REPORTS_TO_ID on the Users.EditView.Settings layout is not required. 
						if ( bRequireUserAssignment && DATA_FIELD != 'REPORTS_TO_ID' )
						{
							UI_REQUIRED = true;
						}
					}
				}
			}
			if ( Sql.IsEmptyString(MODULE_TYPE) )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor MODULE_TYPE is null ' + FIELD_TYPE + '.' + DATA_FIELD, DATA_VALUE, DISPLAY_VALUE, row);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, DISPLAY_VALUE);
		this.state =
		{
			popupOpen        : false,
			primary          : false,
			ID               ,
			EDIT_NAME        ,
			FIELD_INDEX      ,
			DATA_FIELD       ,
			DATA_VALUE       ,
			UI_REQUIRED      ,
			FORMAT_TAB_INDEX ,
			FORMAT_MAX_LENGTH,
			FORMAT_ROWS      ,
			FORMAT_COLUMNS   ,
			DISPLAY_FIELD    ,
			DISPLAY_VALUE    ,
			MODULE_TYPE      ,
			VALUE_MISSING    : false,
			ENABLED          ,
			items            : [],
		};
		//document.components[sID] = this;
	}

	async componentDidMount()
	{
		const { layout, row } = this.props;
		const { DATA_FIELD, DISPLAY_FIELD, MODULE_TYPE } = this.state;
		try
		{
			if ( row != null )
			{
				let value: any = await this.getValue(layout, row, DATA_FIELD, DISPLAY_FIELD, MODULE_TYPE);
				let DATA_VALUE    = value.DATA_VALUE   ;
				let DISPLAY_VALUE = value.DISPLAY_VALUE;
				let primary       = value.primary      ;
				this.setState(
				{
					DATA_VALUE   ,
					DISPLAY_VALUE,
					primary      ,
				});
			}
			// 05/25/2020 Paul.  We need a quick way to initialize the value when editing in a multi-selection. 
			else if ( this.props.value )
			{
				let DATA_VALUE    = this.props.value.DATA_VALUE   ;
				let DISPLAY_VALUE = this.props.value.DISPLAY_VALUE;
				let primary       = this.props.value.primary      ;
				this.setState(
				{
					DATA_VALUE   ,
					DISPLAY_VALUE,
					primary      ,
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

	shouldComponentUpdate(nextProps: IMoudlePopupProps, nextState: IModulePopupState)
	{
		const { DATA_FIELD, DATA_VALUE, VALUE_MISSING, items } = this.state;
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
		else if ( nextState.primary != this.state.primary )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, primary, nextProps, nextState);
			return true;
		}
		else if ( JSON.stringify(nextState.items) != JSON.stringify(this.state.items) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, items, nextProps, nextState);
			return true;
		}
		else if ( nextState.VALUE_MISSING != this.state.VALUE_MISSING || nextState.ENABLED != this.state.ENABLED )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, ENABLED, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		else if ( JSON.stringify(nextState.rowDefaultSearch) != JSON.stringify(this.state.rowDefaultSearch) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, rowDefaultSearch, nextProps, nextState);
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
		let value: any = { DATA_VALUE: '', DISPLAY_VALUE: '', primary: false };
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
					if ( row[DISPLAY_FIELD] === undefined && !Sql.IsEmptyString(value.DATA_VALUE) && !Sql.IsEmptyString(MODULE_TYPE) && layout.FIELD_TYPE == 'ModulePopup' )
					{
						// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
						try
						{
							// 03/17/2020 Paul.  Crm_Modules.ItemName
							value.DISPLAY_VALUE = await Crm_Modules.ItemName(MODULE_TYPE, value.DATA_VALUE);
						}
						catch(error)
						{
							// 11/17/2021 Paul.  Special case for LineItems where ID may not exist. 
							if ( this.props.layout && this.props.layout.EDIT_NAME && this.props.layout.EDIT_NAME.indexOf('.LineItems') && this.props.row && this.props.row.NAME )
							{
								value.DISPLAY_VALUE = this.props.row.NAME;
							}
							else
							{
								console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue', error, this.props.row, this.props.layout);
								value.DISPLAY_VALUE = error.message;
							}
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
						if ( Crm_Config.ToBoolean('inherit_assigned_user') && !Sql.IsEmptyString(row[DATA_FIELD]) )
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
							// 11/05/2020 Paul.  Correct to use the ID and not the NAME. 
							value.DATA_VALUE = Security.TEAM_ID();
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
			else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'ASSIGNED_USER_ID' )
			{
				value.DATA_VALUE = Security.USER_ID();
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue ' + DATA_FIELD, value, row);
		return value;
	}

	private _onSelect = (value: { Action: string, ID: string, NAME: string }) =>
	{
		const { baseId, layout, row, onChanged, onUpdate, tableRow } = this.props;
		const { DATA_FIELD, DISPLAY_FIELD, primary, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect ' + DATA_FIELD + ' ' + DISPLAY_FIELD, value);
		try
		{
			if ( value.Action == 'SingleSelect' )
			{
				// 07/23/2019.  Apply Field Level Security. 
				if ( ENABLED )
				{
					if ( tableRow )
					{
						// 07/15/2019 Paul.  If this is a dynamic list, then clear value after selection. 
						this.setState({ popupOpen: false, DATA_VALUE: '', DISPLAY_VALUE: '' });
					}
					else
					{
						this.setState({ popupOpen: false, DATA_VALUE: value.ID, DISPLAY_VALUE: value.NAME }, this.validate);
					}
					onChanged(DATA_FIELD, value.ID, DISPLAY_FIELD, value.NAME, primary);
					// 04/27/2019 Paul.  ModulePopup does not support dependent fields. 
					// 01/30/2020 Paul.  A contact may be dependent on an account. 
					// 02/04/2020 Paul.  onUpdate will be null inside ModuleMultiSelect. 
					if ( onUpdate )
					{
						onUpdate (DATA_FIELD, value.ID, value);
					}
				}
				else
				{
					console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect ACCESS DENIED for ' + DATA_FIELD + ' ' + DISPLAY_FIELD, value);
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

	private _onClearClick = (): void =>
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClearClick ' + DATA_FIELD + ' ' + DISPLAY_FIELD, DATA_VALUE, DISPLAY_VALUE, row);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.setState({ DATA_VALUE: null, DISPLAY_VALUE: '' }, this.validate);
				// 11/17/2019 Paul.  Send update to parent. 
				onChanged(DATA_FIELD, null, DISPLAY_FIELD, null, false);

			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onClearClick', error);
		}
	}

	private _onCancelClick = (): void =>
	{
		if ( this.props.onCancel )
		{
			this.props.onCancel();
		}
	}

	private _onSelectClick = (): void =>
	{
		const { baseId, layout, row } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectClick ' + DATA_FIELD + ' ' + DISPLAY_FIELD, DATA_VALUE, DISPLAY_VALUE, row);
		this.setState({ popupOpen: true });
	}

	private _onCheckboxClick = () =>
	{
		this.setState({
			primary: !this.state.primary
		});
		if (this.props.onCheckboxClick)
		{
			this.props.onCheckboxClick(this.state.DATA_VALUE);
		}
	}

	private _onTextChange = (event, value) =>
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { DATA_FIELD, MODULE_TYPE, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange ' + DATA_FIELD, value);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.PartialInput = true;
				this.setState({ DATA_VALUE: null, DISPLAY_VALUE: value }, () =>
				{
					// 04/23/2019 Paul.  Try and prevent debounce by saving last query value. 
					this.LastQuery = value;
					// 04/23/2019 Paul.  Must specify at least 2 characters for search to execute. 
					if ( value.length >= 2 )
					{
						let sSORT_FIELDS: string = 'NAME';
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
		const { onChanged, onUpdate } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect ' + DATA_FIELD, value, item);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.PartialInput = false;
				this.setState({ DATA_VALUE: item.ID, DISPLAY_VALUE: item.NAME }, this.validate);
				onChanged(DATA_FIELD, item.ID, DISPLAY_FIELD, item.NAME, false);
				// 04/27/2019 Paul.  ModulePopup does not support dependent fields. 
				// 01/30/2020 Paul.  A contact may be dependent on an account. 
				// 02/04/2020 Paul.  onUpdate will be null inside ModuleMultiSelect. 
				if ( onUpdate )
				{
					onUpdate (DATA_FIELD, item.ID, item);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect', error);
		}
	}

	private _onTextBlur = (event) =>
	{
		const { onChanged, onUpdate, tableRow, allowCustomName } = this.props;
		const { DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE, items, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextBlur ' + MODULE_TYPE + ' ' + DATA_FIELD, DATA_VALUE, DISPLAY_VALUE);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				if ( this.PartialInput )
				{
					this.PartialInput = false;
					let item = { ID: DATA_VALUE, NAME: DISPLAY_VALUE };
					// 04/26/2019 Paul.  If empty, then clear item. 
					if ( Sql.IsEmptyString(DISPLAY_VALUE) )
					{
						item = { ID: null, NAME: '' };
					}
					// 04/26/2019 Paul.  If items were found, then take the first item.  Otherwise use previous values. 
					else if ( items != null && items.length > 0 )
					{
						item = items[0];
					}
					if ( tableRow )
					{
						// 07/15/2019 Paul.  If this is a dynamic list, then clear value after selection. 
						this.setState({ DATA_VALUE: '', DISPLAY_VALUE: '' });
					}
					else
					{
						// 08/12/2019 Paul.  Tags and NAICSCodes have tableRow, so don't need to be excluded here.  If item not selected, then clear the DISPLAY_VALUE. 
						if ( Sql.IsEmptyGuid(item.ID) )
						{
							// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
							if ( !Sql.ToBoolean(allowCustomName) )
							{
								item = { ID: null, NAME: '' };
							}
						}
						this.setState({ DATA_VALUE: item.ID, DISPLAY_VALUE: item.NAME }, this.validate);
					}
					// 08/12/2019 Paul.  Tags only send the name, not the ID.  Random NAICSCodes are not allowed, so it is not included here. 
					if ( !Sql.IsEmptyGuid(item.ID) || (MODULE_TYPE == 'Tags' && !Sql.IsEmptyGuid(item.NAME)) )
					{
						onChanged(DATA_FIELD, item.ID, DISPLAY_FIELD, item.NAME, false);
					}
					// 04/27/2019 Paul.  ModulePopup does not support dependent fields. 
					// 01/30/2020 Paul.  A contact may be dependent on an account. 
					// 02/04/2020 Paul.  onUpdate will be null inside ModuleMultiSelect. 
					if ( onUpdate )
					{
						onUpdate (DATA_FIELD, item.ID, item);
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
		const { DISPLAY_VALUE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' )
		{
			this._onTextBlur(null);
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged, tableRow, onCheckboxClick, isSearchView, showCancel, disableClear, smallButtons } = this.props;
		const { popupOpen, EDIT_NAME, ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE, UI_REQUIRED, FORMAT_TAB_INDEX, FORMAT_MAX_LENGTH, VALUE_MISSING, ENABLED, CSS_CLASS, items, primary, rowDefaultSearch } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRender ' + MODULE_TYPE + ' ' + DATA_FIELD + ' ' + DISPLAY_FIELD, DATA_VALUE, DISPLAY_VALUE, row);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for ModulePopup FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for ModulePopup DATA_FIELD { DATA_FIELD }</span>);
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
					style       : {width: '100%', marginRight: '2px', minWidth: '150px'},
					autoComplete: 'off',
					onBlur      : this._onTextBlur,
					onKeyDown   : this._onKeyDown,
				};
				// 05/05/2021 Paul.  Blur prevents the clear button from working. 
				if ( MODULE_TYPE == 'Tags' || MODULE_TYPE == 'NAICSCodes' )
				{
					inputProps.onBlur = null;
				}
				// 06/21/2020 Paul.  Add flex to the wrappers. 
				let wrapperStyle: any = 
				{
					display   : 'inline-block',
					flexGrow  : 2, 
					flexShrink: 1, 
					flexBasis : '60%'
				};
				// 06/21/2020 Paul.  Add shrink to prevent button overflow. 
				// 11/04/2020 Paul.  Remove nowrap as it is causing overlap with following cell. 
				let buttonWrapperStyle: any =
				{
					flexGrow  : 0, 
					flexShrink: 1, 
					flexBasis : '40%', 
				};
				// 08/31/2012 Paul.  Add support for speech. 
				// 04/26/2019 Paul.  Speech appears to be deprecated. 
				//let bEnableSpeech = Crm_Config.enable_speech();
				//let cssSpeech: any = { };
				//if (bEnableSpeech)
				//{
				//	cssSpeech.speech = 'speech';
				//}
				// 10/18/2011 Paul.  A custom field will not have a display name. 
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
				let styCheckbox = { transform: 'scale(1.5)', marginLeft: '6px', display: 'inline', marginTop: '2px', marginBottom: '6px' };
				// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
				if ( Crm_Config.ToBoolean('enable_legacy_icons') )
				{
					styCheckbox.transform = 'scale(1.0)';
					styCheckbox.marginBottom = '2px';
				}
				// 11/14/2019 Paul.  Use smaller icons when on 3 column layouts. 
				let sIconClass  : string = 'd-lg-none';
				let sButtonClass: string = 'd-none d-lg-inline';
				if ( Sql.ToInteger(this.props.layout.DATA_COLUMNS) > 2 )
				{
					// https://getbootstrap.com/docs/4.3/utilities/display/
					sIconClass   = 'd-xl-none';
					sButtonClass = 'd-none d-xl-inline';
				}
				if ( Sql.ToBoolean(smallButtons) )
				{
					sIconClass   = 'd-xs-inline';
					sButtonClass = 'd-none';
					wrapperStyle.flexBasis = '75%';
					buttonWrapperStyle.flexBasis = '25%';
				}
				if ( tableRow )
				{
					// 12/17/2019 Paul.  need a correction as class style is not getting to the edit controls. 
					let cssStackedClass: string = null;
					if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
					{
						cssStackedClass = 'tabStackedEditViewDF';
					}
					// 09/21/2019 Paul.  d-lg-none to hide when large screen. 
					// 05/25/2020 Paul.  Remove flex for wrapperStyle to prevent menu from going to the right. 
					// wrapperStyle={ {display: 'flex', flexGrow: 2, flexShrink: 1, flexBasis: '70%'} }
					// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
					return (
						<tr className={ CSS_CLASS} style={ {whiteSpace: 'nowrap'} }>
							<td style={ {width: '68%'} }>
								<DynamicPopupView
									isOpen={ popupOpen }
									isSearchView={ isSearchView }
									fromLayoutName={ EDIT_NAME }
									callback={ this._onSelect }
									MODULE_NAME={ MODULE_TYPE }
									rowDefaultSearch={ rowDefaultSearch }
								/>
								<AutoComplete
									id={ ID }
									key={ ID }
									value={ DISPLAY_VALUE ? DISPLAY_VALUE : '' }
									items={ items }
									inputProps={ inputProps }
									wrapperStyle={ wrapperStyle }
									autoHighlight={ false }
									getItemValue={ this._onGetItemValue }
									onChange={ this._onTextChange }
									onSelect={ this._onTextSelect }
									renderMenu={ this._onRenderMenu }
									renderItem={ this._onRenderItem }
									onMenuVisibilityChange={ this._onMenuVisibilityChange }
								/>
							</td>
							{ ((MODULE_TYPE == 'Users' || MODULE_TYPE == 'Teams') && this.props.layout.EDIT_NAME.indexOf('.Search') < 0)
								? <td style={ {width: '2%'} }>
									<input type='checkbox'
										className='checkbox'
										style={ styCheckbox }
										checked={ primary }
										onChange={ this._onCheckboxClick }
										disabled={ !ENABLED }
									/>
								</td>
								: null
							}
							<td className={ cssStackedClass } style={ {width: '30%'} }>
								<span>
									<button
										id={ ID + '_btnChange' }
										key={ ID + '_btnChange' }
										style={ {marginLeft: '4px'} }
										onClick={ this._onSelectClick }
										className='button'
										title={ L10n.Term('.LBL_SELECT_BUTTON_TITLE') }
										>
										{ this.legacyIcons
										? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
										: <FontAwesomeIcon icon='edit' className={ sIconClass } />
										}
										<span className={ sButtonClass }>{ L10n.Term('.LBL_SELECT_BUTTON_LABEL') }</span>
									</button>
								{ Sql.ToBoolean(showCancel)
								? <button
									id={ ID + '_btnClear' }
									key={ ID + '_btnClear' }
									style={ {marginLeft: '4px'} }
									onClick={ this._onCancelClick }
									className='button'
									title={ L10n.Term('.LBL_CANCEL_BUTTON_TITLE') }
									>
									{ this.legacyIcons
									? <img src={ this.themeURL + 'decline_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
									: <FontAwesomeIcon icon='times' className={ sIconClass } />
									}
									<span className={ sButtonClass }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</span>
								</button>
								: !Sql.ToBoolean(disableClear)
								? <button
									id={ ID + '_btnClear' }
									key={ ID + '_btnClear' }
									style={ {marginLeft: '4px'} }
									onClick={ this._onClearClick }
									className='button'
									title={ L10n.Term('.LBL_CLEAR_BUTTON_TITLE') }
									>
									{ this.legacyIcons
									? <img src={ this.themeURL + 'decline_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
									: <FontAwesomeIcon icon='times' className={ sIconClass } />
									}
									<span className={ sButtonClass }>{ L10n.Term('.LBL_CLEAR_BUTTON_LABEL') }</span>
								</button>
								: null
								}
								</span>
							</td>
							{ UI_REQUIRED ? <span id={ ID + '_REQUIRED' } key={ ID + '_REQUIRED' } className='required' style={ cssRequired } >{ L10n.Term('.ERR_REQUIRED_FIELD') }</span> : null }
						</tr>
					);
				}
				else
				{
					// 09/21/2019 Paul.  d-lg-none to hide when large screen. 
					// 11/12/2019 Paul.  Use flexShrink: 1 to prevent overflow into next cell. 
					// 05/25/2020 Paul.  Remove flex for wrapperStyle to prevent menu from going to the right. 
					// wrapperStyle={ {flexGrow: 2, flexShrink: 1, flexBasis: '65%'} }
					// 11/04/2020 Paul.  Enable flexWrap as it is causing overlap with following cell. 
					// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
					return (
						<span className={ CSS_CLASS } style={ {display: 'flex', flexShrink: 0, flexWrap: 'wrap', flexBasis: '100%', alignItems: 'baseline'} }>
							<DynamicPopupView
								isOpen={ popupOpen }
								isSearchView={ isSearchView }
								fromLayoutName={ EDIT_NAME }
								callback={ this._onSelect }
								MODULE_NAME={ MODULE_TYPE }
								rowDefaultSearch={ rowDefaultSearch }
							/>
							<AutoComplete
								id={ ID }
								key={ ID }
								value={ DISPLAY_VALUE ? DISPLAY_VALUE : '' }
								items={ items }
								inputProps={ inputProps }
								wrapperStyle={ wrapperStyle }
								autoHighlight={ false }
								getItemValue={ this._onGetItemValue }
								onChange={ this._onTextChange }
								onSelect={ this._onTextSelect }
								renderMenu={ this._onRenderMenu }
								renderItem={ this._onRenderItem }
								onMenuVisibilityChange={ this._onMenuVisibilityChange }
								disabled={ !ENABLED }
							/>
							<span style={ buttonWrapperStyle }>
								<button
									id={ ID + '_btnChange' }
									key= {ID + '_btnChange' }
									style={ {marginLeft: '4px'} }
									onClick={ this._onSelectClick }
									disabled={ !ENABLED }
									className='button'
									title={ L10n.Term('.LBL_SELECT_BUTTON_TITLE') }
									>
									{ this.legacyIcons
									? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
									: <FontAwesomeIcon icon='edit' className={ sIconClass } />
									}
									<span className={ sButtonClass }>{ L10n.Term('.LBL_SELECT_BUTTON_LABEL') }</span>
								</button>
								{ Sql.ToBoolean(showCancel)
								? <button
									id={ ID + '_btnCancel' }
									key= {ID + '_btnCancel' }
									style={ {marginLeft: '4px'} }
									onClick={ this._onCancelClick }
									disabled={ !ENABLED }
									className='button'
									title={ L10n.Term('.LBL_CANCEL_BUTTON_TITLE') }
									>
									{ this.legacyIcons
									? <img src={ this.themeURL + 'decline_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
									: <FontAwesomeIcon icon='times' className={ sIconClass } />
									}
									<span className={ sButtonClass }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</span>
								</button>
								: !Sql.ToBoolean(disableClear)
								? <button
									id={ ID + '_btnClear' }
									key= {ID + '_btnClear' }
									style={ {marginLeft: '4px'} }
									onClick={ this._onClearClick }
									disabled={ !ENABLED }
									className='button'
									title={ L10n.Term('.LBL_CLEAR_BUTTON_TITLE') }
									>
									{ this.legacyIcons
									? <img src={ this.themeURL + 'decline_inline.gif'} style={ {borderWidth: '0px'} } className={ sIconClass } />
									: <FontAwesomeIcon icon='times' className={ sIconClass } />
									}
									<span className={ sButtonClass }>{ L10n.Term('.LBL_CLEAR_BUTTON_LABEL') }</span>
								</button>
								: null
								}
								{ UI_REQUIRED ? <span id={ ID + '_REQUIRED' } key={ ID + '_REQUIRED' } className='required' style={ cssRequired } >{ L10n.Term('.ERR_REQUIRED_FIELD') }</span> : null }
							</span>
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
