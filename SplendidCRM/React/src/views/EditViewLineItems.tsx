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
import AutoComplete                                 from 'react-autocomplete'                  ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'      ;
// 2. Store and Types. 
import { EditComponent }                            from '../types/EditComponent'              ;
import EDITVIEWS_FIELD                              from '../types/EDITVIEWS_FIELD'            ;
import DETAILVIEWS_FIELD                            from '../types/DETAILVIEWS_FIELD'          ;
import ACL_FIELD_ACCESS                             from '../types/ACL_FIELD_ACCESS'           ;
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                      ;
import L10n                                         from '../scripts/L10n'                     ;
import Security                                     from '../scripts/Security'                 ;
import Credentials                                  from '../scripts/Credentials'              ;
import SplendidCache                                from '../scripts/SplendidCache'            ;
import SplendidDynamic_EditView                     from '../scripts/SplendidDynamic_EditView' ;
import { AutoComplete_ModuleMethod }                from '../scripts/ListView'                 ;
import { Crm_Config }                               from '../scripts/Crm'                      ;
import { formatDate, formatCurrency, formatNumber } from '../scripts/Formatting'               ;
import { ValidateDateParts }                        from '../scripts/utility'                  ;
import { EditView_InitItem }                        from '../scripts/EditView'                 ;
// 4. Components and Views. 
import ErrorComponent                               from '../components/ErrorComponent'        ;

import TextBox                                      from '../EditComponents/TextBox'           ;
import HtmlEditor                                   from '../EditComponents/HtmlEditor'        ;
import ZipCodePopup                                 from '../EditComponents/ZipCodePopup'      ;
import CheckBox                                     from '../EditComponents/CheckBox'          ;
import CheckBoxList                                 from '../EditComponents/CheckBoxList'      ;
import Label                                        from '../EditComponents/Label'             ;
import Hidden                                       from '../EditComponents/Hidden'            ;
import DatePicker                                   from '../EditComponents/DatePicker'        ;
import DateTimeEdit                                 from '../EditComponents/DateTimeEdit'      ;
import DateTimePicker                               from '../EditComponents/DateTimePicker'    ;
import TimePicker                                   from '../EditComponents/TimePicker'        ;
import ListBox                                      from '../EditComponents/ListBox'           ;
import ModuleAutoComplete                           from '../EditComponents/ModuleAutoComplete';
import ModulePopup                                  from '../EditComponents/ModulePopup'       ;
import ChangeButton                                 from '../EditComponents/ChangeButton'      ;
import TeamSelect                                   from '../EditComponents/TeamSelect'        ;
import UserSelect                                   from '../EditComponents/UserSelect'        ;
import TagSelect                                    from '../EditComponents/TagSelect'         ;
import NAICSCodeSelect                              from '../EditComponents/NAICSCodeSelect'   ;
import SplendidFile                                 from '../EditComponents/File'              ;
import Radio                                        from '../EditComponents/Radio'             ;
import SplendidButton                               from '../EditComponents/Button'            ;

import DetailCheckBox                               from '../DetailComponents/CheckBox'        ;
import HyperLink                                    from '../DetailComponents/HyperLink'       ;
import Image                                        from '../DetailComponents/Image'           ;
import ModuleLink                                   from '../DetailComponents/ModuleLink'      ;
import SplendidString                               from '../DetailComponents/String'          ;
import DetailFile                                   from '../DetailComponents/File'            ;
import Tags                                         from '../DetailComponents/Tags'            ;
import DetailTextBox                                from '../DetailComponents/TextBox'         ;

interface IEditViewLineItemsProps
{
	MODULE_NAME       : string;
	ID                : string;
	row               : object;
	layout            : EDITVIEWS_FIELD[];
	onChanged?        : (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any) => void;
	onUpdate?         : (PARENT_FIELD: string, DATA_VALUE: any, item?: any) => void;
	onUpdateLineItem? : (lineEdited: any) => void;
	onDeleteLineItem? : (lineEdited: any) => void;
	onFieldDidMount   : (DATA_FIELD: string, component: any) => void;
	onLineEditChange? : (lineEditIndex: number, LineItems: any[]) => void;
	FieldVisibility   : (LINE_ITEM_TYPE: string, DATA_FIELD: string) => boolean;
	ConvertField      : (MODULE_NAME: string, edit: EDITVIEWS_FIELD) => DETAILVIEWS_FIELD;
	ValidateLineItem  : (MODULE_NAME: string, layout: EDITVIEWS_FIELD[], lineEdited: any) => void;
	disableComments?  : boolean;
	disableMovement?  : boolean;
	disableDefaultRow?: boolean;
	disableEdit?      : boolean;
	disableDelete?    : boolean;
}

interface IEditViewLineItemsState
{
	LineItems            : any[];
	lineEditIndex        : number;
	lineEdited           : object;
	lineError?           : any;
	dependents           : Record<string, Array<any>>;
	newLine?             : boolean;
}

export default class EditViewLineItems extends React.Component<IEditViewLineItemsProps, IEditViewLineItemsState>
{
	private _isMounted   : boolean = false;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private themeURL     : string = null;
	private legacyIcons  : boolean = false;

	public get data(): any
	{
		let obj: any = {};
		// 02/16/2020 Paul.  More than just LineItems data. 
		obj.LineItems     = this.state.LineItems    ;
		return obj;
	}

	public get LineItems(): any
	{
		return this.state.LineItems;
	}

	public get LineEdited(): any
	{
		return this.state.lineEdited;
	}

	public UpdateLineEdited(nextLineEdited: any): any
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateLineEdited', nextLineEdited);
		for ( let DATA_FIELD in this.refMap )
		{
			let ref = this.refMap[DATA_FIELD];
			if ( ref && ref.current )
			{
				if ( this.state.lineEdited[DATA_FIELD] != nextLineEdited[DATA_FIELD] )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateLineEdited ' + DATA_FIELD, nextLineEdited[DATA_FIELD]);
					// 11/12/2022 Paul.  ModulePopup is having an issue with DISPLAY_VALUE being converted to the DATA_VALUE. 
					// This happens here when DATA_VALUE is set without also providing item. 
					let item: any = null;
					// 11/12/2022 Paul.  We could call updateDependancy a second time for NAME, but seems better to provide an item instead. 
					if ( ref.current.props.layout.FIELD_TYPE == 'ModulePopup' )
					{
						item = {};
						item.NAME = nextLineEdited[ref.current.props.layout.DISPLAY_FIELD];
					}
					let DATA_VALUE = nextLineEdited[DATA_FIELD];
					ref.current.updateDependancy(DATA_FIELD, DATA_VALUE, null, item);
				}
			}
		}
		this.setState({ lineEdited: nextLineEdited });
	}

	public InsertEditRow = (rowDefault: any) =>
	{
		const { onLineEditChange } = this.props;
		let { LineItems } = this.state;
		let lineEdited: any = Object.assign(EditView_InitItem(this.props.layout), rowDefault);
		LineItems.push(lineEdited);
		
		let lineEditIndex: number = LineItems.length - 1;
		this.setState(
		{
			LineItems    ,
			lineEdited   ,
			lineEditIndex,
			newLine      : true,
		}, () =>
		{
			if ( onLineEditChange )
			{
				onLineEditChange(lineEditIndex, LineItems);
			}
		});
	}

	constructor(props: IEditViewLineItemsProps)
	{
		super(props);
		const { row } = props;
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		
		let LineItems            : any[] = [];
		let lineEdited           : any   = EditView_InitItem(props.layout);
		let lineEditIndex        : number = 0;
		if ( row != null )
		{
			LineItems     = row['LineItems'];
			if ( !LineItems )
			{
				LineItems = [];
			}
			else
			{
				LineItems     = LineItems.slice();
				lineEditIndex = LineItems.length;
			}
		}
		this.state =
		{
			LineItems            ,
			lineEditIndex        ,
			lineEdited           ,
			dependents           : {},
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private RenderHeader = () =>
	{
		const { layout } = this.props;
		// 02/16/2021 Paul.  headerClasses should be set to listViewThS1 on the bootstraptable, not the cell. 
		return (
			<tr id='ctlEditLineItemsView_grdMain' className='listViewThS1'>
				<th  style={ {whiteSpace: 'nowrap'} }>&nbsp;</th>
				<th  style={ {whiteSpace: 'nowrap'} }>&nbsp;</th>
				{ layout
				? layout.map((lay, index) => 
					{
						let DATA_LABEL: string = (lay['DATA_LABEL'] ? L10n.Term(lay['DATA_LABEL']) : null);
						let COLSPAN   : number = Sql.ToInteger(lay['COLSPAN']);
						// 11/06/2020 Paul.  Skip hidden columns. 
						if ( COLSPAN == -1 || Sql.ToBoolean(lay.hidden) || lay.FIELD_TYPE == 'Hidden' )
							return null;
						else
							return(<th style={ {whiteSpace: 'nowrap'} }>{ DATA_LABEL }</th>);
					})
				: null
				}
				<th style={ {whiteSpace: 'nowrap'} }>&nbsp;</th>
			</tr>
		);
	}

	private RenderLineItems = () =>
	{
		const { disableDefaultRow } = this.props;
		const { LineItems, lineEditIndex } = this.state;
		return (
			<table id='ctlEditLineItemsView_grdMain' style={ {width: '100%', borderWidth: '1px', borderCollapse: 'collapse'} }>
				{ this.RenderHeader() }
				{ LineItems 
				? LineItems.map((item, index) => 
					{
						return this.RenderRow(item, index);
					})
				: null
				}
				{ !disableDefaultRow
				? this.AddFinalEditRow()
				: null
				}
			</table>
		);
	}

	private _onLineItemUpdate = (lineEditIndex) =>
	{
		const { MODULE_NAME, layout, onUpdate, onUpdateLineItem, onLineEditChange } = this.props;
		let { LineItems, lineEdited } = this.state;
		try
		{
			let item: any = Object.assign({}, lineEdited);
			// 11/04/2020 Paul.  lineEdited may not be accurate, so update using the components. 
			SplendidDynamic_EditView.BuildDataRow(item, this.refMap);
			// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
			let ref = this.refMap['PRODUCT_TEMPLATE_ID'];
			if ( ref != null && ref.current != null )
			{
				// 12/13/2021 Paul.  We need to manually update the NAME field as the ModulePopup only sets the DATA_FIELD, not the DISPLAY_FIELD. 
				let data: any = ref.current.data;
				item['NAME'                 ] = data.name;
				item['PRODUCT_TEMPLATE_NAME'] = data.name;
			}

			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLineItemUpdate', lineEditIndex, lineEdited);
			this.props.ValidateLineItem(MODULE_NAME, layout, item);
			if ( lineEditIndex < LineItems.length )
			{
				LineItems[lineEditIndex] = item;
			}
			else
			{
				LineItems.push(item);
			}
			lineEditIndex = LineItems.length;
			this.setState(
			{
				LineItems    ,
				lineEdited   : EditView_InitItem(layout),
				lineEditIndex,
				lineError    : null,
				newLine      : false,
			}, () =>
			{
				if ( onUpdateLineItem )
				{
					onUpdateLineItem(item);
				}
				if ( onUpdate )
				{
					onUpdate('LineItems', null, LineItems);
				}
				if ( onLineEditChange )
				{
					onLineEditChange(lineEditIndex, LineItems);
				}
			});
		}
		catch(error)
		{
			this.setState({ lineError: error });
		}
	}

	private _onLineItemCancel = (lineEditIndex) =>
	{
		const { disableDefaultRow, onLineEditChange } = this.props;
		const { LineItems, newLine } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLineItemCancel', lineEditIndex);
		// 07/07/2020 Paul.  The edited fields are not getting cleared, so do it manually. 
		try
		{
			for ( let DATA_FIELD in this.refMap )
			{
				let ref = this.refMap[DATA_FIELD];
				if ( ref && ref.current )
				{
					ref.current.clear();
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onLineItemCancel', error);
		}
		// 07/07/2020 Paul.  If the default row has been disabled and the user cancels a new line, then
		if ( disableDefaultRow && newLine )
		{
			LineItems.splice(lineEditIndex, 1);
		}
		lineEditIndex = LineItems.length;
		this.setState(
		{
			lineEdited   : EditView_InitItem(this.props.layout),
			lineEditIndex,
			lineError    : null
		}, () =>
		{
			if ( onLineEditChange )
			{
				onLineEditChange(lineEditIndex, LineItems);
			}
		});
	}

	private _onLineItemEdit = (lineEditIndex) =>
	{
		const { onLineEditChange } = this.props;
		const { LineItems } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLineItemEdit', lineEditIndex);
		let lineEdited: any = Object.assign({}, LineItems[lineEditIndex]);
		this.setState(
		{
			lineEdited   ,
			lineEditIndex,
			newLine      : false,
		}, () =>
		{
			if ( onLineEditChange )
			{
				onLineEditChange(lineEditIndex, LineItems);
			}
		});
	}

	private _onLineItemDelete = (lineEditIndex) =>
	{
		const { onUpdate, onDeleteLineItem, onLineEditChange } = this.props;
		let { LineItems } = this.state;
		let item = LineItems[lineEditIndex];
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLineItemDelete', lineEditIndex);
		LineItems.splice(lineEditIndex, 1);
		
		lineEditIndex = LineItems.length;
		this.setState(
		{
			LineItems    ,
			lineEdited   : EditView_InitItem(this.props.layout),
			lineEditIndex,
			newLine      : false,
		}, () =>
		{
			if ( onDeleteLineItem )
			{
				onDeleteLineItem(item);
			}
			if ( onUpdate )
			{
				onUpdate('LineItems', null, LineItems);
			}
			if ( onLineEditChange )
			{
				onLineEditChange(lineEditIndex, LineItems);
			}
		});
	}

	private _onLineItemMoveUp = (nSelectedIndex: number) =>
	{
		const { onUpdate } = this.props;
		let { LineItems } = this.state;
		if ( nSelectedIndex > 0 )
		{
			let item = LineItems[nSelectedIndex];
			LineItems.splice(nSelectedIndex, 1);
			LineItems.splice(nSelectedIndex - 1, 0, item);

			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLineItemMoveUp', nSelectedIndex);
			this.setState({ LineItems }, () =>
			{
				if ( onUpdate )
				{
					onUpdate('LineItems', null, LineItems);
				}
			});
		}
	}

	private _onLineItemMoveDown = (nSelectedIndex: number) =>
	{
		const { onUpdate } = this.props;
		let { LineItems } = this.state;
		if ( nSelectedIndex < LineItems.length - 1 )
		{
			let item = LineItems[nSelectedIndex];
			LineItems.splice(nSelectedIndex, 1);
			LineItems.splice(nSelectedIndex + 1, 0, item);

			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLineItemMoveDown', nSelectedIndex);
			this.setState({ LineItems }, () =>
			{
				if ( onUpdate )
				{
					onUpdate('LineItems', null, LineItems);
				}
			});
		}
	}

	private _onLineItemAddComment = () =>
	{
		const { onUpdate } = this.props;
		let { lineEdited } = this.state;
		if ( lineEdited['LINE_ITEM_TYPE'] != 'Comment' )
		{
			lineEdited = {};
			lineEdited['LINE_ITEM_TYPE'] = 'Comment';
			this.setState({ lineEdited }, () =>
			{
				if ( onUpdate )
				{
					onUpdate('LINE_ITEM_TYPE', 'Comment');
				}
			});
		}
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		let item = this.state.lineEdited;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		if ( item == null )
		{
			item = EditView_InitItem(this.props.layout);
		}
		item[DATA_FIELD] = DATA_VALUE;
		if ( this._isMounted )
		{
			this.setState({ lineEdited: item });
		}
	}

	private _createDependency = (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string): void =>
	{
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			dependents[PARENT_FIELD].push( {DATA_FIELD, PROPERTY_NAME} );
		}
		else
		{
			dependents[PARENT_FIELD] = [ {DATA_FIELD, PROPERTY_NAME} ]
		}
		if ( this._isMounted )
		{
			this.setState({ dependents: dependents });
		}
	}

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
		const { onUpdate } = this.props;
		let { dependents } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE);
		if ( dependents[PARENT_FIELD] )
		{
			let dependentIds = dependents[PARENT_FIELD];
			for ( let i = 0; i < dependentIds.length; i++ )
			{
				let ref = this.refMap[dependentIds[i].DATA_FIELD];
				if ( ref && ref.current )
				{
					ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, dependentIds[i].PROPERTY_NAME, item);
				}
			}
		}
		if ( onUpdate )
		{
			onUpdate(PARENT_FIELD, DATA_VALUE, item);
		}
	}

	private _onFieldDidMount = (DATA_FIELD: string, component: any): void =>
	{
		if ( this.props.onFieldDidMount )
		{
			this.props.onFieldDidMount(DATA_FIELD, component);
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
	}

	private RenderEditColumns = (row: any, index: number) =>
	{
		const { MODULE_NAME, layout, FieldVisibility } = this.props;
		let bEnableTeamManagement   : boolean = Crm_Config.enable_team_management();
		let bRequireTeamManagement  : boolean = Crm_Config.require_team_management();
		let bEnableDynamicTeams     : boolean = Crm_Config.enable_dynamic_teams();
		let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();

		let arrTD          : any[] = [];
		let tdField        : any   = null;
		let tdFieldChildren: any[] = null;
		this.refMap = {};
		if ( layout )
		{
			for ( let i: number = 0; i < layout.length; i++ )
			{
				let lay: any = layout[i];
				let EDIT_NAME     : string  = lay.EDIT_NAME;
				let FIELD_TYPE    : string  = lay.FIELD_TYPE;
				let DATA_LABEL    : string  = lay.DATA_LABEL;
				let DATA_FIELD    : string  = lay.DATA_FIELD;
				let DATA_FORMAT   : string  = lay.DATA_FORMAT;
				let DISPLAY_FIELD : string  = lay.DISPLAY_FIELD;
				let UI_REQUIRED   : boolean = Sql.ToBoolean(lay.UI_REQUIRED) || Sql.ToBoolean(lay.DATA_REQUIRED);
				let ONCLICK_SCRIPT: string  = lay.ONCLICK_SCRIPT;
				let COLSPAN       : number  = Sql.ToInteger(lay.COLSPAN);
				let MODULE_TYPE   : string  = lay.MODULE_TYPE;
				let TOOL_TIP      : string  = lay.TOOL_TIP;
				let bIsHidden     : boolean = lay.hidden;
				let bIsReadable   : boolean = true;
				let bIsWriteable  : boolean = true;
				if ( SplendidCache.bEnableACLFieldSecurity )
				{
					let gASSIGNED_USER_ID: string = null;
					if ( row != null )
					{
						gASSIGNED_USER_ID = Sql.ToGuid(row.ASSIGNED_USER_ID);
					}
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
					// 02/16/2011 Paul.  We should allow a Read-Only field to be searchable, so always allow writing if the name contains Search. 
					bIsWriteable = acl.IsWriteable() || EDIT_NAME.indexOf('.Search') >= 0;
					if ( !bIsWriteable )
					{
						// 11/11/2020 Paul.  No longer need this warning. 
						//console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.RenderColumns NOT WRITEABLE', MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					}
				}
				// 11/06/2020 Paul.  Skip hidden columns. 
				if ( !bIsReadable || lay.FIELD_TYPE == 'Hidden')
				{
					bIsHidden = true;
				}
				
				if ( ( DATA_FIELD == 'TEAM_ID' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( !bEnableTeamManagement )
					{
						FIELD_TYPE = 'Blank';
						// 10/24/2012 Paul.  Clear the label to prevent a term lookup. 
						DATA_LABEL  = null;
						DATA_FIELD  = null;
						UI_REQUIRED = false;
					}
					else
					{
						if ( bEnableDynamicTeams )
						{
							// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
							// 10/20/2017 Paul.  Don't convert MyPipelineBySalesStage. 
							if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
							{
								DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								DATA_FIELD     = 'TEAM_SET_NAME';
								FIELD_TYPE     = 'TeamSelect';
								ONCLICK_SCRIPT = '';
								// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
								lay.DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								lay.DATA_FIELD     = 'TEAM_SET_NAME';
								lay.FIELD_TYPE     = 'TeamSelect';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						else
						{
							// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
							if ( FIELD_TYPE == 'TeamSelect' )
							{
								DATA_LABEL     = 'Teams.LBL_TEAM';
								DATA_FIELD     = 'TEAM_ID';
								DISPLAY_FIELD  = 'TEAM_NAME';
								FIELD_TYPE     = 'ModulePopup';
								MODULE_TYPE    = 'Teams';
								ONCLICK_SCRIPT = '';
								// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
								lay.DATA_LABEL     = 'Teams.LBL_TEAM';
								lay.DATA_FIELD     = 'TEAM_ID';
								lay.DISPLAY_FIELD  = 'TEAM_NAME';
								lay.FIELD_TYPE     = 'ModulePopup';
								lay.MODULE_TYPE    = 'Teams';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						// 11/25/2006 Paul.  Override the required flag with the system value. 
						// 01/01/2008 Paul.  If Team Management is not required, then let the admin decide. 
						// 97/06/2017 Paul.  Don't show required flag in search or popup. 
						// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
						if ( bRequireTeamManagement && EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.MassUpdate') < 0 && EDIT_NAME.indexOf('.Popup') < 0 )
						{
							UI_REQUIRED = true;
						}
					}
				}
				// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( (DATA_FIELD == 'ASSIGNED_USER_ID' || DATA_FIELD == 'ASSIGNED_SET_NAME') )
				{
					// 01/06/2018 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					if ( bEnableDynamicAssignment && DATA_FORMAT != '1' )
					{
						if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
						{
							DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							FIELD_TYPE     = 'UserSelect'            ;
							ONCLICK_SCRIPT = ''                      ;
							// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
							lay.DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							lay.DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							lay.FIELD_TYPE     = 'UserSelect'            ;
							lay.ONCLICK_SCRIPT = ''                      ;
						}
					}
					else
					{
						if ( FIELD_TYPE == 'UserSelect' )
						{
							DATA_LABEL     = '.LBL_ASSIGNED_TO';
							DATA_FIELD     = 'ASSIGNED_USER_ID';
							DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							FIELD_TYPE     = 'ModulePopup'     ;
							MODULE_TYPE    = 'Users'           ;
							ONCLICK_SCRIPT = ''                ;
							// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
							lay.DATA_LABEL     = '.LBL_ASSIGNED_TO';
							lay.DATA_FIELD     = 'ASSIGNED_USER_ID';
							lay.DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							lay.FIELD_TYPE     = 'ModulePopup'     ;
							lay.MODULE_TYPE    = 'Users'           ;
							lay.ONCLICK_SCRIPT = ''                ;
						}
					}
					if ( bRequireTeamManagement )
					{
						UI_REQUIRED = true;
					}
				}
				let baseId        : string = 'ctlEditViewLineItems' + index.toString();
				let key           : string = baseId +  '_' + DATA_FIELD + '_' + i.toString();
				let LINE_ITEM_TYPE: string = (row ? Sql.ToString(row['LINE_ITEM_TYPE']) : '');
				if ( !bIsHidden )
				{
					bIsHidden = !FieldVisibility(LINE_ITEM_TYPE, DATA_FIELD);
				}
				if ( COLSPAN >= 0 || tdField == null )
				{
					tdFieldChildren = [];
					tdField = React.createElement('td', { key: key + '_' + bIsHidden.toString(), className: 'dataField', style: {verticalAlign: 'top'} }, tdFieldChildren);
					// 11/06/2020 Paul.  Skip hidden columns. 
					if ( !bIsHidden )
					{
						arrTD.push(tdField);
					}
				}
				if ( !bIsHidden )
				{
					let ref = React.createRef<EditComponent<any, any>>();
					this.refMap[DATA_FIELD] = ref;
					try
					{
						if ( FIELD_TYPE == 'Hidden' )
						{
							// 02/28/2008 Paul.  When the hidden field is the first in the row, we end up with a blank row. 
							// Just ignore for now as IE does not have a problem with the blank row. 
							COLSPAN = -1;
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(Hidden, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'ModuleAutoComplete' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(ModuleAutoComplete, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'ModulePopup' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden, isSearchView: false, disableClear: true, smallButtons: true };
							// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
							if ( DATA_FIELD == 'PRODUCT_TEMPLATE_ID' )
							{
								txtProps.allowCustomName = true;
							}
							let txt = React.createElement(ModulePopup, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'ChangeButton' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(ChangeButton, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'TeamSelect' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(TeamSelect, txtProps);
							tdFieldChildren.push(txt);
						}
						// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						else if ( FIELD_TYPE == 'UserSelect' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(UserSelect, txtProps);
							tdFieldChildren.push(txt);
						}
						// 05/14/2016 Paul.  Add Tags module. 
						else if ( FIELD_TYPE == 'TagSelect' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(TagSelect, txtProps);
							tdFieldChildren.push(txt);
						}
						// 06/07/2017 Paul.  Add NAICSCodes module. 
						else if ( FIELD_TYPE == 'NAICSCodeSelect' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(NAICSCodeSelect, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'TextBox' )
						{
							// 11/02/2019 Paul.  layout changes are not detected, so we need to send the hidden field as a separate property. 
							// 01/04/2022 Paul.  Disable flex grow will also use fixed width instead of minimum width. 
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden, bDisableFlexGrow: true };
							let txt = React.createElement(TextBox, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'HtmlEditor' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(HtmlEditor, txtProps);
							tdFieldChildren.push(txt);
						}
						// 04/14/2016 Paul.  Add ZipCode lookup. 
						else if ( FIELD_TYPE == 'ZipCodePopup' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(ZipCodePopup, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'DatePicker' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(DatePicker, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'DateTimeEdit' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(DateTimeEdit, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'DateTimePicker' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(DateTimePicker, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'TimePicker' )
						{
							let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, onSubmit: null, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let txt = React.createElement(TimePicker, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'ListBox' )
						{
							let lstProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let lst = React.createElement(ListBox, lstProps);
							tdFieldChildren.push(lst);
						}
						// 08/01/2013 Paul.  Add support for CheckBoxList. 
						else if ( FIELD_TYPE == 'CheckBoxList' )
						{
							let lstProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let lst = React.createElement(CheckBoxList, lstProps);
							tdFieldChildren.push(lst);
						}
						// 08/01/2013 Paul.  Add support for Radio. 
						else if ( FIELD_TYPE == 'Radio' )
						{
							let chkProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let chk = React.createElement(Radio, chkProps);
							tdFieldChildren.push(chk);
						}
						else if ( FIELD_TYPE == 'CheckBox' )
						{
							let chkProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let chk = React.createElement(CheckBox, chkProps);
							tdFieldChildren.push(chk);
						}
						else if ( FIELD_TYPE == 'Label' )
						{
							let lblProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let lbl = React.createElement(Label, lblProps);
							tdFieldChildren.push(lbl);
						}
						// 05/27/2016 Paul.  Add support for File type. 
						else if ( FIELD_TYPE == 'File' )
						{
							let lblProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
							let lbl = React.createElement(SplendidFile, lblProps);
							tdFieldChildren.push(lbl);
						}
						// 11/04/2019 Paul.  Add support for Button type. 
						else if ( FIELD_TYPE == 'Button' )
						{
							let lblProps: any = { baseId, key, row, layout: lay, onChanged: this._onChange, ref, createDependency: this._createDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden, Page_Command: this.Page_Command };
							let lbl = React.createElement( SplendidButton, lblProps );
							tdFieldChildren.push( lbl );
						}
						// 06/29/2020 Paul.  A hidden field does not insert a column. 
						else if ( FIELD_TYPE == 'Hidden' )
						{
						}
						else
						{
							//08/31/2012 Paul.  Add debugging code. 
							console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.RenderEditColumns: Unsupported field type ' + FIELD_TYPE);
						}
					}
					catch(error)
					{
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.RenderEditColumns ' + FIELD_TYPE + ' ' + DATA_FIELD, error);
					}
				}
				else
				{
					tdFieldChildren.push(<span></span>);
				}
			}
		}
		return arrTD;
	}

	private RenderColumns = (row: any, index: number) =>
	{
		const { MODULE_NAME, layout, FieldVisibility } = this.props;
		let bEnableTeamManagement   : boolean = Crm_Config.enable_team_management();
		let bRequireTeamManagement  : boolean = Crm_Config.require_team_management();
		let bEnableDynamicTeams     : boolean = Crm_Config.enable_dynamic_teams();
		let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();

		let arrTD          : any[] = [];
		let tdField        : any   = null;
		let tdFieldChildren: any[] = null;
		if ( layout )
		{
			for ( let i: number = 0; i < layout.length; i++ )
			{
				let lay: any = layout[i];
				let EDIT_NAME     : string  = lay.EDIT_NAME;
				let FIELD_TYPE    : string  = lay.FIELD_TYPE;
				let DATA_LABEL    : string  = lay.DATA_LABEL;
				let DATA_FIELD    : string  = lay.DATA_FIELD;
				let DATA_FORMAT   : string  = lay.DATA_FORMAT;
				let DISPLAY_FIELD : string  = lay.DISPLAY_FIELD;
				let UI_REQUIRED   : boolean = Sql.ToBoolean(lay.UI_REQUIRED) || Sql.ToBoolean(lay.DATA_REQUIRED);
				let ONCLICK_SCRIPT: string  = lay.ONCLICK_SCRIPT;
				let COLSPAN       : number  = Sql.ToInteger(lay.COLSPAN);
				let MODULE_TYPE   : string  = lay.MODULE_TYPE;
				let TOOL_TIP      : string  = lay.TOOL_TIP;
				let bIsHidden     : boolean = lay.hidden;
				let bIsReadable   : boolean = true;
				let bIsWriteable  : boolean = true;
				if ( SplendidCache.bEnableACLFieldSecurity )
				{
					let gASSIGNED_USER_ID: string = null;
					if ( row != null )
					{
						gASSIGNED_USER_ID = Sql.ToGuid(row.ASSIGNED_USER_ID);
					}
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
					// 02/16/2011 Paul.  We should allow a Read-Only field to be searchable, so always allow writing if the name contains Search. 
					bIsWriteable = acl.IsWriteable() || EDIT_NAME.indexOf('.Search') >= 0;
					if ( !bIsWriteable )
					{
						// 11/11/2020 Paul.  No longer need this warning. 
						//console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.RenderColumns NOT WRITEABLE', MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					}
				}
				// 11/06/2020 Paul.  Skip hidden columns. 
				if ( !bIsReadable || lay.FIELD_TYPE == 'Hidden')
				{
					bIsHidden = true;
				}
				
				if ( ( DATA_FIELD == 'TEAM_ID' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( !bEnableTeamManagement )
					{
						FIELD_TYPE = 'Blank';
						// 10/24/2012 Paul.  Clear the label to prevent a term lookup. 
						DATA_LABEL  = null;
						DATA_FIELD  = null;
						UI_REQUIRED = false;
					}
					else
					{
						if ( bEnableDynamicTeams )
						{
							// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
							// 10/20/2017 Paul.  Don't convert MyPipelineBySalesStage. 
							if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
							{
								DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								DATA_FIELD     = 'TEAM_SET_NAME';
								FIELD_TYPE     = 'TeamSelect';
								ONCLICK_SCRIPT = '';
								// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
								lay.DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								lay.DATA_FIELD     = 'TEAM_SET_NAME';
								lay.FIELD_TYPE     = 'TeamSelect';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						else
						{
							// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
							if ( FIELD_TYPE == 'TeamSelect' )
							{
								DATA_LABEL     = 'Teams.LBL_TEAM';
								DATA_FIELD     = 'TEAM_ID';
								DISPLAY_FIELD  = 'TEAM_NAME';
								FIELD_TYPE     = 'ModulePopup';
								MODULE_TYPE    = 'Teams';
								ONCLICK_SCRIPT = '';
								// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
								lay.DATA_LABEL     = 'Teams.LBL_TEAM';
								lay.DATA_FIELD     = 'TEAM_ID';
								lay.DISPLAY_FIELD  = 'TEAM_NAME';
								lay.FIELD_TYPE     = 'ModulePopup';
								lay.MODULE_TYPE    = 'Teams';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						// 11/25/2006 Paul.  Override the required flag with the system value. 
						// 01/01/2008 Paul.  If Team Management is not required, then let the admin decide. 
						// 97/06/2017 Paul.  Don't show required flag in search or popup. 
						// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
						if ( bRequireTeamManagement && EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.MassUpdate') < 0 && EDIT_NAME.indexOf('.Popup') < 0 )
						{
							UI_REQUIRED = true;
						}
					}
				}
				// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( (DATA_FIELD == 'ASSIGNED_USER_ID' || DATA_FIELD == 'ASSIGNED_SET_NAME') )
				{
					// 01/06/2018 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					if ( bEnableDynamicAssignment && DATA_FORMAT != '1' )
					{
						if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
						{
							DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							FIELD_TYPE     = 'UserSelect'            ;
							ONCLICK_SCRIPT = ''                      ;
							// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
							lay.DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							lay.DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							lay.FIELD_TYPE     = 'UserSelect'            ;
							lay.ONCLICK_SCRIPT = ''                      ;
						}
					}
					else
					{
						if ( FIELD_TYPE == 'UserSelect' )
						{
							DATA_LABEL     = '.LBL_ASSIGNED_TO';
							DATA_FIELD     = 'ASSIGNED_USER_ID';
							DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							FIELD_TYPE     = 'ModulePopup'     ;
							MODULE_TYPE    = 'Users'           ;
							ONCLICK_SCRIPT = ''                ;
							// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
							lay.DATA_LABEL     = '.LBL_ASSIGNED_TO';
							lay.DATA_FIELD     = 'ASSIGNED_USER_ID';
							lay.DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							lay.FIELD_TYPE     = 'ModulePopup'     ;
							lay.MODULE_TYPE    = 'Users'           ;
							lay.ONCLICK_SCRIPT = ''                ;
						}
					}
					if ( bRequireTeamManagement )
					{
						UI_REQUIRED = true;
					}
				}
				let baseId        : string = 'ctlEditViewLineItems' + index.toString();
				let key           : string = baseId +  '_' + DATA_FIELD + '_' + i.toString();
				let LINE_ITEM_TYPE: string = (row ? Sql.ToString(row['LINE_ITEM_TYPE']) : '');
				if ( !bIsHidden )
				{
					bIsHidden = !FieldVisibility(LINE_ITEM_TYPE, DATA_FIELD);
				}

				let detail: DETAILVIEWS_FIELD = this.props.ConvertField(MODULE_NAME, lay);
				if ( COLSPAN >= 0 || tdField == null )
				{
					tdFieldChildren = [];
					tdField = React.createElement('td', { key: key + '_' + bIsHidden.toString(), className: 'dataField', style: {verticalAlign: 'top'} }, tdFieldChildren);
					// 11/06/2020 Paul.  Skip hidden columns. 
					if ( !bIsHidden )
					{
						arrTD.push(tdField);
					}
				}
				// 01/03/2022 Paul.  If this field is next to previous field, then at least add a line break. 
				else if ( COLSPAN < 0 )
				{
					let br = React.createElement('br');
					tdFieldChildren.push(br);
				}
				if ( !bIsHidden )
				{
					let ref = React.createRef<EditComponent<any, any>>();
					try
					{
						FIELD_TYPE = detail.FIELD_TYPE;
						let ERASED_FIELDS: string = '';
						if ( FIELD_TYPE == 'HyperLink' )
						{
							let lnkProps: any = { baseId, key, row, layout: detail, ref, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
							let lnk = React.createElement(HyperLink, lnkProps);
							tdFieldChildren.push(lnk);
						}
						// 01/10/2023 Paul.  Correct the field type name, it is not ModueLink. 
						else if ( FIELD_TYPE == 'ModuleLink' )
						{
							let lnkProps: any = { baseId, key, row, layout: detail, ref, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
							let lnk = React.createElement(ModuleLink, lnkProps);
							tdFieldChildren.push(lnk);
						}
						else if ( FIELD_TYPE == 'String' )
						{
							let txtProps: any = { baseId, key, row, layout: detail, ref, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
							let txt = React.createElement(SplendidString, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'Label' )
						{
							let txtProps: any = { baseId, key, row, layout: detail, ref, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
							let txt = React.createElement(SplendidString, txtProps);
							tdFieldChildren.push(txt);
						}
						else if ( FIELD_TYPE == 'TextBox' )
						{
							let txtProps: any = { baseId, key, row, layout: detail, ref, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
							let txt = React.createElement(DetailTextBox, txtProps);
							tdFieldChildren.push(txt);
						}
						// 05/27/2016 Paul.  Add support for Image type. 
						else if ( FIELD_TYPE == 'Image' )
						{
							let imgProps: any = { baseId, key, row, layout: detail, ref, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
							let img = React.createElement(Image, imgProps);
							tdFieldChildren.push(img);
						}
						// 05/27/2016 Paul.  Add support for File type. 
						else if ( FIELD_TYPE == 'File' )
						{
							let imgProps: any = { baseId, key, row, layout: detail, ref, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
							let img = React.createElement(DetailFile, imgProps);
							tdFieldChildren.push(img);
						}
						else if ( FIELD_TYPE == 'CheckBox' )
						{
							let chkProps: any = { baseId, key, row, layout: detail, ref, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
							let chk = React.createElement(DetailCheckBox, chkProps);
							tdFieldChildren.push(chk);
						}
						// 05/14/2016 Paul.  Add Tags module. 
						else if ( FIELD_TYPE == 'Tags' )
						{
							let txtProps: any = { baseId, key, row, layout: detail, ref, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
							let txt = React.createElement(Tags, txtProps);
							tdFieldChildren.push(txt);
						}
						// 06/29/2020 Paul.  A hidden field does not insert a column. 
						else if ( FIELD_TYPE == 'Hidden' )
						{
						}
						else
						{
							//08/31/2012 Paul.  Add debugging code. 
							console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.RenderColumns: Unsupported field type ' + FIELD_TYPE);
						}
					}
					catch(error)
					{
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.RenderColumns ' + FIELD_TYPE + ' ' + DATA_FIELD, error);
					}
				}
				else
				{
					tdFieldChildren.push(<span></span>);
				}
			}
		}
		return arrTD;
	}

	private RenderRowControls = (currentItem: any, index: number, bEDIT_MODE: boolean) =>
	{
		const { FieldVisibility, disableComments, disableMovement, disableEdit, disableDelete } = this.props;
		const { lineEditIndex, lineEdited } = this.state;
		let sIconClass  : string = 'd-xl-none';
		let sButtonClass: string = 'd-none d-xl-inline';
		// 01/03/2022 Paul.  Don't wrap the controls. 
		return (
		<React.Fragment>
			{ bEDIT_MODE
			? <div style={ {whiteSpace: 'nowrap'} }>
				{ this.legacyIcons
				? <img
					onClick={ () => this._onLineItemUpdate(index) }
					src={ this.themeURL + 'accept_inline.gif'}
					style={ {borderWidth: '0px', marginBottom: '.2em', marginLeft: '.5em', cursor: 'pointer'} }
					alt={ L10n.Term('.LBL_UPDATE_BUTTON_TITLE') }
				/>
				: <button
					className='button'
					onClick={ () => this._onLineItemUpdate(index) }
					style={ {marginBottom: '.2em', marginLeft: '.5em'} }
					title={ L10n.Term('.LBL_UPDATE_BUTTON_TITLE') }
					>
					<FontAwesomeIcon icon='save' className={ sIconClass } />
					<span className={ sButtonClass }>{ L10n.Term('.LBL_UPDATE_BUTTON_LABEL') }</span>
				</button>
				}
				{ this.legacyIcons
				? <img
					onClick={ () => this._onLineItemCancel(index) }
					src={ this.themeURL + 'decline_inline.gif'}
					style={ {borderWidth: '0px', marginBottom: '.2em', marginLeft: '.5em', cursor: 'pointer'} }
					alt={ L10n.Term('.LBL_CANCEL_BUTTON_TITLE') }
				/>
				: <button
					className='button'
					onClick={ () => this._onLineItemCancel(index) }
					style={ {marginBottom: '.2em', marginLeft: '.5em'} }
					title={ L10n.Term('.LBL_CANCEL_BUTTON_TITLE') }
					>
					<FontAwesomeIcon icon='times' className={ sIconClass } />
					<span className={ sButtonClass }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</span>
				</button>
				}
				{ !disableComments && lineEdited && FieldVisibility(lineEdited['LINE_ITEM_TYPE'], 'btnComment')
				? <div>
					<span onClick={ (e) => this._onLineItemAddComment() } style={ {cursor: 'pointer'} }>
						<img src={ this.themeURL + 'plus_inline.gif' } style={ {border: 'none'} } width={ 12 } height={ 12 } />
						&nbsp;{ L10n.Term('Orders.LBL_ADD_COMMENT') }
					</span>
				</div>
				: null
				}
			</div>
			: <div style={ {whiteSpace: 'nowrap'} }>
				{ !disableEdit
				? <React.Fragment>
					{ this.legacyIcons
					? <img
						onClick={ () => this._onLineItemEdit(index) }
						src={ this.themeURL + 'edit_inline.gif'}
						style={ {borderWidth: '0px', marginBottom: '.2em', marginLeft: '.5em', cursor: 'pointer'} }
						alt={ L10n.Term('.LBL_EDIT_BUTTON_LABEL') }
					/>
					: <button
						className='button'
						onClick={ () => this._onLineItemEdit(index) }
						style={ {marginBottom: '.2em', marginLeft: '.5em'} }
						title={ L10n.Term('.LBL_EDIT_BUTTON_TITLE') }
						>
						<FontAwesomeIcon icon='edit' className={ sIconClass } />
						<span className={ sButtonClass }>{ L10n.Term('.LBL_EDIT_BUTTON_LABEL') }</span>
					</button>
					}
				</React.Fragment>
				: null
				}
				{ !disableDelete
				? <React.Fragment>
					{ this.legacyIcons
					? <img
						onClick={ () => this._onLineItemDelete(index) }
						src={ this.themeURL + 'delete_inline.gif'}
						style={ {borderWidth: '0px', marginBottom: '.2em', marginLeft: '.5em', cursor: 'pointer'} }
						alt={ L10n.Term('.LBL_DELETE_BUTTON_TITLE') }
					/>
					: <button
						className='button'
						onClick={ () => this._onLineItemDelete(index) }
						style={ {marginBottom: '.2em', marginLeft: '.5em'} }
						title={ L10n.Term('.LBL_DELETE_BUTTON_TITLE') }
						>
						<FontAwesomeIcon icon='times' className={ sIconClass } />
						<span className={ sButtonClass }>{ L10n.Term('.LBL_DELETE_BUTTON_LABEL') }</span>
					</button>
					}
				</React.Fragment>
				: null
				}
			</div>
			}
		</React.Fragment>
		);
	}

	private RenderRowMovement = (currentItem: any, index: number, bEDIT_MODE: boolean) =>
	{
		const { FieldVisibility, disableComments, disableMovement, disableEdit, disableDelete } = this.props;
		const { lineEditIndex, lineEdited } = this.state;
		let sIconClass  : string = 'd-xl-none';
		let sButtonClass: string = 'd-none d-xl-inline';
		return (
		<React.Fragment>
			{ bEDIT_MODE
			? null
			: <div>
				{ !disableMovement
				? <React.Fragment>
					{ (index - 1) != lineEditIndex
					? <span>
						{ this.legacyIcons
						? <img
							onClick={ (e) => { e.preventDefault(); this._onLineItemMoveUp(index); } }
							src={ this.themeURL + 'uparrow_inline.gif'   }
							style={ {borderWidth: '0px', width: '12px', height: '12px'} }
						/>
						: <button
							className='button'
							onClick={ () => this._onLineItemMoveUp(index) }
							style={ {marginBottom: '.1em', paddingLeft: '.5em', paddingRight: '.5em'} }
							>
							<FontAwesomeIcon icon='angle-up' />
						</button>
						}
					</span>
					: null
					}
					{ (index + 1) != lineEditIndex
					? <span>
						{ this.legacyIcons
						? <img
							onClick={ (e) => { e.preventDefault(); this._onLineItemMoveDown(index); } }
							src={ this.themeURL + 'downarrow_inline.gif' }
							style={ {borderWidth: '0px', width: '12px', height: '12px'} }
						/>
						: <button
							className='button'
							onClick={ () => this._onLineItemMoveDown(index) }
							style={ {marginBottom: '.1em', paddingLeft: '.5em', paddingRight: '.5em'} }
							>
							<FontAwesomeIcon icon='angle-down' />
						</button>
						}
					</span>
					: null
					}
				</React.Fragment>
				: null
				}
			</div>
			}
		</React.Fragment>
		);
	}

	private RenderRow = (item: any, index: number) =>
	{
		const { lineEditIndex, lineEdited } = this.state;
		let bEDIT_MODE: boolean = false;
		let currentItem: any = item;
		// 10/21/2019 Paul.  item == null, then this is the bottom AddLine. 
		if ( index == lineEditIndex || item == null )
		{
			bEDIT_MODE = true;
			currentItem = lineEdited;
		}
		// 10/21/2019 Paul.  First line is the drag line. 
		return (
		<React.Fragment>
			<tr key={ 'key' + Sql.ToString(currentItem['ID']) + '_' + Sql.ToString(currentItem['LINE_ITEM_TYPE']) + '_' + index.toString() } className={ (index % 2 == 0) ? 'oddListRowS1' : 'evenListRowS1' }>
				<td className='dataField' style={ {width:  '20px', verticalAlign: 'top'} }>
					{ this.RenderRowMovement(currentItem, index, bEDIT_MODE) }
				</td>
				<td className='dataField' style={ {width:  (this.legacyIcons ? '5%' : '1%'), verticalAlign: 'top'} }>
					{ !this.legacyIcons
					? this.RenderRowControls(currentItem, index, bEDIT_MODE)
					: null
					}
				</td>
				{ bEDIT_MODE
				? this.RenderEditColumns(currentItem, index) 
				: this.RenderColumns(currentItem, index) 
				}
				<td style={ {width: (!this.legacyIcons ? '5%' : '1%'), whiteSpace: 'nowrap', verticalAlign: 'top'} }>
					{ this.legacyIcons
					? this.RenderRowControls(currentItem, index, bEDIT_MODE)
					: null
					}
				</td>
			</tr>
		</React.Fragment>
		);
	}

	private AddFinalEditRow = () =>
	{
		const { LineItems, lineEditIndex } = this.state;
		if ( lineEditIndex == LineItems.length )
		{
			return this.RenderRow(null, LineItems.length);
		}
		else
		{
			return null;
		}
	}

	public render()
	{
		const { lineError } = this.state;
		return (
			<div id='ctlEditLineItemsView_ctlLineItemsPanel'>
				{ this.RenderLineItems() }
				<ErrorComponent error={ lineError } />
			</div>
		);
	}
}

