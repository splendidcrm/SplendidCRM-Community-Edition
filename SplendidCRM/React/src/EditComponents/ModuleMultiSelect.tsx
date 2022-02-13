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
import SplendidCache                          from '../scripts/SplendidCache'      ;
import SplendidDynamic                        from '../scripts/SplendidDynamic'    ;
import { Crm_Config, Crm_Teams, Crm_Users, Crm_Modules }  from '../scripts/Crm'    ;
// 4. Components and Views. 
import ModulePopup                            from './ModulePopup'                 ;
import ErrorComponent                         from '../components/ErrorComponent'  ;

interface IModuleMultiSelectState
{
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	MODULE_TYPE      : string;
	UI_REQUIRED      : boolean;
	VALUE_MISSING    : boolean;
	showAddReplace?  : boolean;
	replaceValue?    : boolean;
	selected         : Array<{ DATA_VALUE: string, DISPLAY_VALUE: string, primary: boolean }>;
	editIndex        : number;
	error?           : any;
	ENABLED          : boolean;
	CSS_CLASS?       : string;
}

export default abstract class ModuleMultiSelect extends EditComponent<IEditComponentProps, IModuleMultiSelectState>
{
	abstract Type: string;
	private modulePopup = React.createRef<ModulePopup>();

	public get data(): any
	{
		const { DATA_FIELD, selected, showAddReplace, replaceValue } = this.state;
		let sLIST_VALUE = null;
		let sPRIMARY_VALUE = null;
		// 07/05/2019 Paul.  The return value will be a comma-separated list. 
		for ( let i = 0; i < selected.length; i++ )
		{
			if ( sLIST_VALUE == null )
			{
				sLIST_VALUE = '';
			}
			else if ( sLIST_VALUE.length > 0 )
			{
				sLIST_VALUE += ',';
			}
			if ( this.Type == 'TEAM' || this.Type == 'USER' )
			{
				// 05/25/2021 Paul.  sPRIMARY_VALUE is always set to first item, otherwise Replace will not work properly as null TEAM_ID will translate to being left unchanged. 
				if ( selected[i].primary || Sql.IsEmptyString(sPRIMARY_VALUE) )
				{
					sPRIMARY_VALUE = selected[i].DATA_VALUE;
				}
			}
			// 08/09/2019 Paul.  Tags and NAICS pass the display value, not the ID. 
			if ( this.Type == 'TAG' || this.Type == 'NAICS' )
			{
				sLIST_VALUE += selected[i].DISPLAY_VALUE;
			}
			else
			{
				sLIST_VALUE += selected[i].DATA_VALUE;
			}
		}
		// 06/30/2019 Paul.  The TEAM_ID field is automatically converted to TEAM_SET_LIST. 
		let arr = [];
		if ( this.Type == 'TEAM' )
		{
			arr.push({ key: 'TEAM_ID'           , value: sPRIMARY_VALUE });
			arr.push({ key: 'TEAM_SET_LIST'     , value: sLIST_VALUE    });
			// 01/05/2020 Paul.  We save the replace value, but return the add value. 
			arr.push({ key: 'TEAM_SET_ADD'      , value: !replaceValue   });
		}
		else if ( this.Type == 'USER' )
		{
			arr.push({ key: 'ASSIGNED_USER_ID'  , value: sPRIMARY_VALUE });
			arr.push({ key: 'ASSIGNED_SET_LIST' , value: sLIST_VALUE    });
			// 01/05/2020 Paul.  We save the replace value, but return the add value. 
			arr.push({ key: 'ASSIGNED_SET_ADD'  , value: !replaceValue   });
		}
		else if ( this.Type == 'TAG' )
		{
			arr.push({ key: 'TAG_SET_NAME'      , value: sLIST_VALUE    });
			// 01/05/2020 Paul.  We save the replace value, but return the add value. 
			arr.push({ key: 'TAG_SET_ADD'       , value: !replaceValue   });
		}
		else if ( this.Type == 'NAICS' )
		{
			arr.push({ key: 'NAICS_SET_NAME'    , value: sLIST_VALUE    });
			// 01/05/2020 Paul.  We save the replace value, but return the add value. 
			arr.push({ key: 'ADD_NAICS_CODE_SET', value: !replaceValue   });
		}
		else
		{
			arr.push( { key: DATA_FIELD, value: sLIST_VALUE });
		}
		return arr;
	}

	public validate(): boolean
	{
		const { DATA_FIELD, selected, UI_REQUIRED, VALUE_MISSING, ENABLED } = this.state;
		let bVALUE_MISSING: boolean = false;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.props.bIsHidden )
		{
			bVALUE_MISSING = (this.state.selected == null || this.state.selected.length == 0);
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
			this.setState({ selected: DATA_VALUE });
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
				selected: []
			});
		}
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number = 0;
		let DATA_FIELD       : string = '';
		let DISPLAY_FIELD    : string = '';
		let MODULE_TYPE      : string = '';
		let FIELD_TYPE       : string = '';
		let UI_REQUIRED      : boolean = false;
		let bShowAddReplace  : boolean = false;
		let ENABLED          : boolean = props.bIsWriteable;

		let selected = [];
		try
		{
			const { baseId, layout, row, onChanged } = this.props;
			if (layout != null)
			{
				FIELD_INDEX    = Sql.ToInteger(layout.FIELD_INDEX  );
				DATA_FIELD     = Sql.ToString (layout.DATA_FIELD   );
				DISPLAY_FIELD  = Sql.ToString (layout.DISPLAY_FIELD);
				MODULE_TYPE    = Sql.ToString (layout.MODULE_TYPE  );
				FIELD_TYPE     = Sql.ToString (layout.FIELD_TYPE   );
				UI_REQUIRED    = Sql.ToBoolean(layout.UI_REQUIRED  ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				bShowAddReplace = (layout.EDIT_NAME.indexOf('.MassUpdate') >= 0);
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
				// 07/10/2019 Paul.  Correct the data field as the layout will likey still be ASSIGNED_USER_ID and TEAM_ID. 
				if ( MODULE_TYPE == 'Users' )
				{
					DATA_FIELD  = 'ASSIGNED_SET_NAME';
				}
				else if ( MODULE_TYPE == 'Teams' )
				{
					DATA_FIELD  = 'TEAM_SET_NAME';
				}
				// 08/10/2020 Paul.  Special requirement flags for Teams and Users. 
				// 12/17/2020 Paul.  Don't force the requirements flags on an update panel or search panel. 
				// 06/19/2021 Paul.  WorkflowAlertShells does not require Team or User. 
				if ( layout.EDIT_NAME.indexOf('.MassUpdate') < 0 && layout.EDIT_NAME.indexOf('.Search') < 0 && layout.EDIT_NAME.indexOf('WorkflowAlertShells') < 0 )
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
				// 03/19/2019 Paul.  row will be null for new record. 
				if ( row == null )
				{
					if ( MODULE_TYPE == 'Teams' )
					{
						selected =
						[
							{
								DATA_VALUE: Security.TEAM_ID(),
								DISPLAY_VALUE: Security.TEAM_NAME(),
								primary: true
							}
						];
					}
					else if ( MODULE_TYPE == 'Users' )
					{
						selected =
						[
							{
								DATA_VALUE: Security.USER_ID(),
								DISPLAY_VALUE: Security.USER_NAME(),
								primary: true
							}
						];
					}
				}
				else
				{
					if ( MODULE_TYPE == 'Users' )
					{
						let sASSIGNED_SET_LIST = row['ASSIGNED_SET_LIST'];
						if ( !Sql.IsEmptyString(sASSIGNED_SET_LIST) )
						{
							let arrASSIGNED_SET_LIST = sASSIGNED_SET_LIST.split(',');
							for ( let i = 0; i < arrASSIGNED_SET_LIST.length; i++ )
							{
								let sASSIGNED_USER_ID = arrASSIGNED_SET_LIST[i];
								selected.push(
								{
									DATA_VALUE: sASSIGNED_USER_ID,
									DISPLAY_VALUE: Crm_Users.Name(sASSIGNED_USER_ID),
									primary: (i == 0)
								});
							}
						}
					}
					else if ( MODULE_TYPE == 'Teams' )
					{
						let sTEAM_SET_LIST = row['TEAM_SET_LIST'];
						if ( !Sql.IsEmptyString(sTEAM_SET_LIST) )
						{
							let arrTEAM_SET_LIST = sTEAM_SET_LIST.split(',');
							for ( let i = 0; i < arrTEAM_SET_LIST.length; i++ )
							{
								let sTEAM_ID = arrTEAM_SET_LIST[i];
								selected.push(
								{
									DATA_VALUE: sTEAM_ID,
									DISPLAY_VALUE: Crm_Teams.Name(sTEAM_ID),
									primary: (i == 0)
								});
							}
						}
					}
					else if ( MODULE_TYPE == 'Tags' )
					{
						let sTAG_SET_NAME = row['TAG_SET_NAME'];
						if ( !Sql.IsEmptyString(sTAG_SET_NAME) )
						{
							let arrTAG_SET_NAME = sTAG_SET_NAME.split(',');
							for ( let i = 0; i < arrTAG_SET_NAME.length; i++ )
							{
								let sTAG_NAME = arrTAG_SET_NAME[i];
								selected.push(
								{
									DATA_VALUE: sTAG_NAME,
									DISPLAY_VALUE: sTAG_NAME,
								});
							}
						}
					}
					else if ( MODULE_TYPE == 'NAICSCodes' )
					{
						let sNAICS_SET_NAME = row['NAICS_SET_NAME'];
						if ( !Sql.IsEmptyString(sNAICS_SET_NAME) )
						{
							let arrNAICS_SET_NAME = sNAICS_SET_NAME.split(',');
							for ( let i = 0; i < arrNAICS_SET_NAME.length; i++ )
							{
								let sNAICS_CODE_NAME = arrNAICS_SET_NAME[i];
								selected.push(
								{
									DATA_VALUE: sNAICS_CODE_NAME,
									DISPLAY_VALUE: sNAICS_CODE_NAME,
								});
							}
						}
					}
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + FIELD_TYPE + '.' + DATA_FIELD, selected, row);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			FIELD_INDEX      ,
			DATA_FIELD       ,
			MODULE_TYPE      ,
			UI_REQUIRED      ,
			VALUE_MISSING    : false,
			ENABLED          ,
			showAddReplace   : bShowAddReplace,
			replaceValue     : true,
			selected         ,
			editIndex        : -1,
			error            : null,
		};
	}

	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: IModuleMultiSelectState)
	{
		const { DATA_FIELD, selected } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, selected, nextProps, nextState);
		if ( nextProps.row != this.props.row )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, selected, nextProps, nextState);
			return true;
		}
		else if ( nextProps.layout != this.props.layout )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, selected, nextProps, nextState);
			return true;
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( nextProps.bIsHidden != this.props.bIsHidden )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, selected, nextProps, nextState);
			return true;
		}
		// 11/03/2019 Paul.  Use stringify to compare arrays. 
		else if ( nextState.editIndex != this.state.editIndex || JSON.stringify(nextState.selected) != JSON.stringify(this.state.selected) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, selected, nextProps, nextState);
			return true;
		}
		else if ( nextState.replaceValue != this.state.replaceValue )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, selected, replaceValue, nextProps, nextState);
			return true;
		}
		else if ( nextState.VALUE_MISSING != this.state.VALUE_MISSING || nextState.ENABLED != this.state.ENABLED )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, selected, VALUE_MISSING, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		return false;
	}

	async componentDidMount()
	{
		const { DATA_FIELD } = this.state;
		if ( this.props.fieldDidMount )
		{
			this.props.fieldDidMount(DATA_FIELD, this);
		}
	}

	protected renderItem = (item: { DATA_VALUE: string, DISPLAY_VALUE: string, primary: boolean }) =>
	{
		return item.DISPLAY_VALUE;
	}

	private _onDeleteClick = (index) =>
	{
		const { onChanged } = this.props;
		const { DATA_FIELD, ENABLED } = this.state;
		// 11/03/2019 Paul.  Make copy so that when shouldComponentUpdate is called, there will be a noticeable change. 
		let selected = this.state.selected.slice();
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				selected.splice(index, 1);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDeleteClick ' + DATA_FIELD, selected);
				this.setState({ selected, editIndex: -1 }, this.validate);
				onChanged(DATA_FIELD, selected);
				// 07/23/2019 Paul.  ModuleMultiSelect does not support dependent fields. 
				//onUpdate (DATA_FIELD, selected);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onDeleteClick', error);
		}
	}

	private _onEditClick = (index) =>
	{
		const { DATA_FIELD, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEditClick ' + DATA_FIELD, index);
		if ( ENABLED )
		{
			this.setState({ editIndex: index });
		}
	}

	private _onEditCancel = () =>
	{
		const { DATA_FIELD, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEditCancel' + DATA_FIELD);
		if ( ENABLED )
		{
			this.setState({ editIndex: -1 });
		}
	}

	private _onCheckboxChange = (index) =>
	{
		const { onChanged } = this.props;
		const { DATA_FIELD, ENABLED } = this.state;
		// 11/03/2019 Paul.  Make copy so that when shouldComponentUpdate is called, there will be a noticeable change. 
		// 11/04/2019 Paul.  It must be a deep copy as contained objects change, not just the list itself. 
		let selected = Sql.DeepCopy(this.state.selected);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				for ( let i = 0; i < selected.length; i++ )
				{
					if ( i == index )
					{
						selected[i].primary = !selected[i].primary;
					}
					else
					{
						selected[i].primary = false;
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onCheckboxChange ' + DATA_FIELD, selected);
				this.setState({ selected }, this.validate);
				onChanged(DATA_FIELD, selected);
				// 07/23/2019 Paul.  ModuleMultiSelect does not support dependent fields. 
				//onUpdate (DATA_FIELD, selected);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onCheckboxChange', error);
		}
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: string, DISPLAY_FIELD: string, DISPLAY_VALUE: string, primary?: boolean) =>
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ENABLED, editIndex } = this.state;
		// 11/03/2019 Paul.  Make copy so that when shouldComponentUpdate is called, there will be a noticeable change. 
		let selected = this.state.selected.slice();
		let item = { DATA_VALUE, DISPLAY_VALUE, primary };
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, item);
		try
		{
			// 11/21/2020 Paul.  If a TAG, then a new tag will create a record. 
			if ( this.Type == 'TAG' && DATA_VALUE == null && !Sql.IsEmptyString(DISPLAY_VALUE) )
			{
				DATA_VALUE = DISPLAY_VALUE;
			}
			// 07/23/2019 Paul.  Apply Field Level Security. 
			if ( ENABLED && DATA_VALUE != null )
			{
				// 05/25/2020 Paul.  Prevent duplicate entries. 
				let nFoundIndex: number = -1;
				for ( let i: number = 0; i < selected.length; i++ )
				{
					if ( DATA_VALUE == selected[i].DATA_VALUE )
					{
						nFoundIndex = i;
						break;
					}
				}
				if ( nFoundIndex == -1 )
				{
					if ( editIndex == -1 )
					{
						selected.push( item );
					}
					else
					{
						selected[editIndex] = item;
					}
					this.setState({ selected }, this.validate);
					// 04/27/2019 Paul.  this.state.DATA_FIELD is not the same as the parameter to this method. 
					onChanged(this.state.DATA_FIELD, selected);
					// 07/23/2019 Paul.  ModuleMultiSelect does not support dependent fields. 
					//onUpdate (this.state.DATA_FIELD, selected);
				}
				else
				{
					if ( editIndex >= 0 )
					{
						if ( nFoundIndex != editIndex )
						{
							selected[editIndex] = item;
							selected.splice(nFoundIndex, 1);
							this.setState({ selected }, this.validate);
						}
					}
				}
				if ( editIndex >= 0 )
				{
					this.setState({ editIndex: -1 });
				}
				// 05/25/2020 Paul.  After value is provided, clear it. 
				if ( this.modulePopup.current )
				{
					this.modulePopup.current.clear();
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onReplaceChange = (replaceValue) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onReplaceChange', replaceValue);
		this.setState({ replaceValue });
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { MODULE_TYPE, DATA_FIELD, showAddReplace, replaceValue, selected, editIndex, error, ENABLED, CSS_CLASS } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + (layout ? layout.DATA_FIELD : ''), selected);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<div>DATA_FIELD is empty for FIELD_INDEX {layout.FIELD_INDEX}</div>);
			}
			else if ( onChanged == null )
			{
				return (<div>onChanged is null for DATA_FIELD {layout.DATA_FIELD}</div>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
				let styCheckbox = { transform: 'scale(1.5)', marginLeft: '6px', display: 'inline', marginTop: '2px', marginBottom: '6px' };
				// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
				if ( Crm_Config.ToBoolean('enable_legacy_icons') )
				{
					styCheckbox.transform = 'scale(1.0)';
					styCheckbox.marginBottom = '2px';
				}
				// 04/16/2019 Paul.  Primary checkbox only applies to Users and Teams. 
				let sREPLACE_LABEL: string = '';
				let sADD_LABEL    : string = '';
				if ( showAddReplace )
				{
					let sSingularTable = Crm_Modules.SingularTableName(Crm_Modules.TableName(MODULE_TYPE));
					if ( MODULE_TYPE == 'NAICSCodes' )
					{
						sSingularTable = 'NAICS';
					}
					sREPLACE_LABEL = L10n.Term(MODULE_TYPE + '.LBL_REPLACE_' + sSingularTable + '_SET');
					sADD_LABEL     = L10n.Term(MODULE_TYPE + '.LBL_ADD_'     + sSingularTable + '_SET');
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
				// 12/17/2019 Paul.  need a correction as class style is not getting to the edit controls. 
				let cssStackedClass: string = null;
				if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
				{
					cssStackedClass = 'tabStackedEditViewDF';
				}
				// 11/14/2019 Paul.  We don't need the primary checkboxes on the search panel. 
				if ( (MODULE_TYPE == 'Users' || MODULE_TYPE == 'Teams') && this.props.layout.EDIT_NAME.indexOf('.Search') < 0 )
				{
					// 09/21/2019 Paul.  d-lg-none to hide when large screen. 
					return (
						<div className={ CSS_CLASS } style={{ width: '100%' }}>
							<ErrorComponent error={ error } />
							{ showAddReplace
							? <div>
								<input
									type="radio"
									className="radio"
									id={ DATA_FIELD + '_Replace' }
									key={ DATA_FIELD + '_Replace' }
									checked={ replaceValue }
									value='replace'
									onClick={ () => this._onReplaceChange(true) }
									disabled={ !ENABLED }
								/>
								&nbsp;&nbsp;
								<label htmlFor={ DATA_FIELD + '_Replace' }>{ sREPLACE_LABEL }</label>
								&nbsp; &nbsp;
								<input
									type="radio" className="radio"
									id={ DATA_FIELD + '_Add'     }
									key={ DATA_FIELD + '_Add'     }
									checked={ !replaceValue }
									value='add'
									onClick={ () => this._onReplaceChange(false) }
									disabled={ !ENABLED }
								/>
								&nbsp;&nbsp;
								<label htmlFor={ DATA_FIELD + '_Add'     }>{ sADD_LABEL }</label>
							</div>
							: null
							}
							<table className='listView' style={{ width: '100%' }}>
								<tbody>
									<tr className='listViewThS1'>
										<th />
										<th style={ {borderLeft: '1px solid white', borderRight: '1px solid white', paddingLeft: '4px', paddingRight: '4px'} }>
											<small>{ L10n.Term(MODULE_TYPE + '.LBL_LIST_PRIMARY_' + this.Type) }</small>
										</th>
										<th />
									</tr>
									{ selected.map((item, index) =>
									(
										editIndex == index
										? <ModulePopup
											baseId={ this.props.baseId + '_new' }
											row={ null }
											value={ item }
											layout={ this.props.layout }
											onChanged={ this._onChange }
											bIsWriteable={ ENABLED }
											tableRow
											showCancel={ true }
											onCancel={ this._onEditCancel }
											ref={ this.modulePopup }
										/>
										: <tr key={ index } className={ index % 2 ? 'evenListRowS1' : 'oddListRowS1' }>
											<td>{ this.renderItem(item) }</td>
											<td>
												<input
													type="checkbox"
													style={ styCheckbox }
													checked={ item.primary }
													onChange={() => this._onCheckboxChange(index)}
													disabled={ !ENABLED }
												/>
											</td>
											<td className={ cssStackedClass } >
												<button
													key={ item.DATA_VALUE + '_Edit' }
													style={ {marginLeft: '4px'} }
													onClick={ () => this._onEditClick(index) }
													disabled={ !ENABLED }
													className='button'
													title={ L10n.Term('.LBL_EDIT_BUTTON_TITLE') }
													>
													<FontAwesomeIcon icon='edit' className={ sIconClass } />
													<span className={ sButtonClass }>{ L10n.Term('.LBL_EDIT_BUTTON_LABEL') }</span>
												</button>
												<button
													key={ item.DATA_VALUE }
													style={ {marginLeft: '4px'} }
													onClick={ () => this._onDeleteClick(index) }
													disabled={ !ENABLED }
													className='button'
													title={ L10n.Term('.LBL_DELETE_BUTTON_TITLE') }
													>
													<FontAwesomeIcon icon="times" className={ sIconClass } />
													<span className={ sButtonClass }>{L10n.Term('.LBL_DELETE_BUTTON_LABEL')}</span>
												</button>
											</td>
										</tr>
									))}
									{ editIndex == -1
									? <ModulePopup
										baseId={ this.props.baseId + '_new' }
										row={ null }
										layout={ this.props.layout }
										onChanged={ this._onChange }
										bIsWriteable={ ENABLED }
										tableRow
										ref={ this.modulePopup }
									/>
									: null
									}
								</tbody>
							</table>
						</div>
					);
				}
				else
				{
					// 09/21/2019 Paul.  d-lg-none to hide when large screen. 
					return (
						<div className={ CSS_CLASS } style={{ width: '100%' }}>
							<ErrorComponent error={ error } />
							{ showAddReplace
							? <div>
								<input
									type='radio'
									className='radio'
									style={ styCheckbox }
									id={ DATA_FIELD + '_Replace' }
									key={ DATA_FIELD + '_Replace' }
									checked={  replaceValue }
									onClick={ () => this._onReplaceChange(true) }
									disabled={ !ENABLED }
								/>
								&nbsp;&nbsp;
								<label htmlFor={ DATA_FIELD + '_Replace' }>{ sREPLACE_LABEL }</label>
								&nbsp;&nbsp;
								<input
									type='radio'
									className='radio'
									style={ styCheckbox }
									id={ DATA_FIELD + '_Add'     }
									key={ DATA_FIELD + '_Add'     }
									checked={ !replaceValue }
									onClick={ () => this._onReplaceChange(false) }
									disabled={ !ENABLED }
								/>
								&nbsp;&nbsp;
								<label htmlFor={ DATA_FIELD + '_Add'     }>{ sADD_LABEL }</label>
							</div>
							: null
							}
							<table className='listView' style={{ width: '100%' }}>
								<tbody>
									{ selected.map((item, index) =>
									(
										editIndex == index
										? <ModulePopup
											baseId={ this.props.baseId + '_new' }
											row={ null }
											value={ item }
											layout={ this.props.layout }
											onChanged={ this._onChange }
											bIsWriteable={ ENABLED }
											tableRow
											showCancel={ true }
											onCancel={ this._onEditCancel }
											ref={ this.modulePopup }
										/>
										: <tr key={ index } className={ index % 2 ? 'evenListRowS1' : 'oddListRowS1' }>
											<td>{ this.renderItem(item) }</td>
											<td className={ cssStackedClass } >
												<button
													key={ item.DATA_VALUE + '_Edit' }
													style={ {marginLeft: '4px'} }
													onClick={ () => this._onEditClick(index) }
													disabled={ !ENABLED }
													className='button'
													title={ L10n.Term('.LBL_EDIT_BUTTON_TITLE') }
													>
													<FontAwesomeIcon icon='edit' className={ sIconClass } />
													<span className={ sButtonClass }>{ L10n.Term('.LBL_EDIT_BUTTON_LABEL') }</span>
												</button>
												<button
													key={ item.DATA_VALUE + '_Delete' }
													style={ {marginLeft: '4px'} }
													onClick={ () => this._onDeleteClick(index) }
													disabled={ !ENABLED }
													className='button'
													title={ L10n.Term('.LBL_DELETE_BUTTON_TITLE') }
													>
													<FontAwesomeIcon icon='times' className={ sIconClass } />
													<span className={ sButtonClass }>{L10n.Term('.LBL_DELETE_BUTTON_LABEL')}</span>
												</button>
											</td>
										</tr>
									))}
									{ editIndex == -1
									? <ModulePopup
										baseId={ this.props.baseId + '_new' }
										row={ null }
										layout={ this.props.layout }
										onChanged={ this._onChange }
										bIsWriteable={ ENABLED }
										tableRow
										ref={ this.modulePopup }
									/>
									: null
									}
								</tbody>
							</table>
						</div>
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

