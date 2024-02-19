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
import { FontAwesomeIcon }                      from '@fortawesome/react-fontawesome'   ;
import { faAngleDoubleUp, faAngleDoubleDown }   from '@fortawesome/free-solid-svg-icons';
import { RouteComponentProps }                  from '../Router5'                       ;
import { observer }                             from 'mobx-react'                       ;
import { XMLParser, XMLBuilder }                from 'fast-xml-parser'                  ;
// 2. Store and Types. 
import MODULE                                   from '../types/MODULE'                  ;
// 3. Scripts. 
import Sql                                      from '../scripts/Sql'                   ;
import L10n                                     from '../scripts/L10n'                  ;
import Credentials                              from '../scripts/Credentials'           ;
import Security                                 from '../scripts/Security'              ;
import SearchBuilder                            from '../scripts/SearchBuilder'         ;
import SplendidCache                            from '../scripts/SplendidCache'         ;
import SplendidDynamic                          from '../scripts/SplendidDynamic'       ;
import { Crm_Config, Crm_Modules }              from '../scripts/Crm'                   ;
import { FromJsonDate, formatDate }             from '../scripts/Formatting'            ;
import { StartsWith, EndsWith }                 from '../scripts/utility'               ;
import { EditView_LoadLayout }                  from '../scripts/EditView'              ;
import { UpdateSavedSearch, DeleteSavedSearch } from '../scripts/ModuleUpdate'          ;
// 4. Components and Views. 
import ErrorComponent                           from '../components/ErrorComponent'     ;
// 01/22/2021 Paul.  Allow the search panel to be customized. 
// 02/04/2024 Paul.  Export both types so ref can use correct type. 
import DynamicEditViewWithRouter, { DynamicEditView } from '../views/DynamicEditView'        ;

const ControlChars = { CrLf: '\r\n', Cr: '\r', Lf: '\n', Tab: '\t' };

// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
interface ISearchViewProps extends RouteComponentProps<any>
{
	EDIT_NAME             : string;
	// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
	CONTROL_VIEW_NAME?    : string;
	cbSearch              : Function;
	// 06/26/2021 Paol.  Provide a way to track search changes. 
	onChange?             : (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any) => void;
	rowDefaultSearch?     : any;
	onLayoutLoaded?       : any;
	AutoSaveSearch?       : boolean;
	ShowSearchViews?      : boolean;
	MultiSelect?          : boolean;
	// 09/13/2011 Paul.  We don't want to apply the saved search in a popup. 
	IsPopupSearch?        : boolean;
	ShowDuplicateFilter?  : boolean;
	fromLayoutName?       : string;
	// 07/02/201 Paul.  Provide a way to hide the clear button. 
	disableClear?         : boolean;
}

interface ISearchViewState
{
	item                  : any;
	SEARCH_MODULE         : string;
	SAVED_SEARCH_ID       : string;
	SAVED_SEARCH_LIST     : any[];
	SAVED_SEARCH_NAME     : string;
	SAVED_SEARCH_NEW_NAME : string;
	SAVED_SEARCH_COLUMN   : string;
	SAVED_SEARCH_DIRECTION: string;
	SAVED_PANEL           : boolean;
	MODULE_COLUMNS_LIST   : any[];
	DUPLICATE_FILTER      : string[];
	savedSearchCounter    : number;
	error?                : any;
	sDebugSQL?            : string;
	sOldSQL?              : string;
}

@observer
export default class SearchView extends React.Component<ISearchViewProps, ISearchViewState>
{
	private _isMounted = false;
	private editView = React.createRef<DynamicEditView>();

	constructor(props: ISearchViewProps)
	{
		super(props);
		let lstOptions              : any[]  = [];
		let MODULE_COLUMNS_LIST     : any[]  = [];
		let rowDefaultSearch        : any    = props.rowDefaultSearch;
		let gSAVED_SEARCH_ID        : string = '';
		let sSAVED_SEARCH_NAME      : string = '';
		let sSAVED_SEARCH_COLUMN    : string = null;
		let sSAVED_SEARCH_DIRECTION : string = null;
		let sMODULE_NAME            : string = null;
		let DUPLICATE_FILTER        : any[]  = [];
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor props', props);
		if ( props.EDIT_NAME )
		{
			sMODULE_NAME = props.EDIT_NAME.split('.')[0];
			if ( props.EDIT_NAME.indexOf('SearchHome') > 0 )
				sMODULE_NAME = props.EDIT_NAME;
		}
		if ( props.EDIT_NAME && props.AutoSaveSearch && !props.IsPopupSearch )
		{
			let search = SplendidCache.DefaultSavedSearch(sMODULE_NAME);
			if ( search != null && !Sql.IsEmptyString(search.DEFAULT_SEARCH_ID) )
			{
				gSAVED_SEARCH_ID = search.DEFAULT_SEARCH_ID;
				sSAVED_SEARCH_NAME = search.NAME;
			}

			let opt3 = { key: '', text: L10n.Term('.LBL_NONE') };
			lstOptions.push(opt3);
			let lstModuleSearches = SplendidCache.SavedSearches(sMODULE_NAME);
			if ( lstModuleSearches != null )
			{
				for ( let i = 0; i < lstModuleSearches.length; i++ )
				{
					let objSearch = lstModuleSearches[i];
					if ( gSAVED_SEARCH_ID == objSearch.ID )
					{
						sSAVED_SEARCH_NAME = objSearch.NAME;
						// 08/31/2019 Paul.  Make the saved search the current serach. 
						search = objSearch;
					}
					if ( !Sql.IsEmptyString(objSearch.NAME) )
					{
						let opt = { key: objSearch.ID, text: objSearch.NAME};
						lstOptions.push(opt);
					}
				}
			}
	
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor search', gSAVED_SEARCH_ID, search);
			if ( search != null && !Sql.IsEmptyString(search.CONTENTS) && StartsWith(search.CONTENTS, '<?xml') )
			{
				try
				{
					// https://www.npmjs.com/package/fast-xml-parser
					let options: any = 
					{
						attributeNamePrefix: '',
						// 02/18/2024 Paul.  parser v4 does not have an issue with node name as there is no value tag. 
						//  <SearchFields>
						//    <Field Name="CATEGORY_ID" Type="ListBox"></Field>
						//    <Field Name="SUBCATEGORY_ID" Type="ListBox"></Field>
						//    <Field Name="EXP_DATE" Type="DateRange">
						//      <Before>02/25/2024</Before>
						//      <After>02/18/2024</After>
						//    </Field>
						//  </SearchFields>
						textNodeName       : 'Value',
						ignoreAttributes   : false,
						ignoreNameSpace    : true,
						parseAttributeValue: true,
						trimValues         : false,

					};
					// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
					const parser = new XMLParser(options);
					let xml = parser.parse(search.CONTENTS);
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', xml);
					if ( xml.SavedSearch != null )
					{
						if ( xml.SavedSearch.SearchFields !== undefined && xml.SavedSearch.SearchFields != null )
						{
							if ( xml.SavedSearch.SortOrder )
							{
								sSAVED_SEARCH_DIRECTION = xml.SavedSearch.SortOrder;
							}
							if ( xml.SavedSearch.SortColumn )
							{
								sSAVED_SEARCH_COLUMN = xml.SavedSearch.SortColumn;
							}
							rowDefaultSearch = {};
							let xSearchFields = xml.SavedSearch.SearchFields;
							if ( xSearchFields.Field !== undefined && xSearchFields.Field != null )
							{
								let xFields: any = xSearchFields.Field;
								if ( Array.isArray(xFields) )
								{
									for ( let i = 0; i < xFields.length; i++ )
									{
										let xField = xFields[i];
										rowDefaultSearch[xField.Name] = xField.Value;
										// 11/25/2020 Paul.  DateRange is an exception in that it does not have a Value field. 
										if ( xField.Type == 'DateRange' && xField.Value === undefined )
										{
											rowDefaultSearch[xField.Name] = new Object();
											rowDefaultSearch[xField.Name].Before = xField.Before;
											rowDefaultSearch[xField.Name].After  = xField.After ;
										}
									}
								}
								// 11/27/2020 Pual.  xFields will not be an array if only one item returned. 
								else if ( xFields.Name !== undefined )
								{
									let xField = xFields;
									rowDefaultSearch[xField.Name] = xField.Value;
									// 11/25/2020 Paul.  DateRange is an exception in that it does not have a Value field. 
									if ( xField.Type == 'DateRange' && xField.Value === undefined )
									{
										rowDefaultSearch[xField.Name] = new Object();
										rowDefaultSearch[xField.Name].Before = xField.Before;
										rowDefaultSearch[xField.Name].After  = xField.After ;
									}
								}
							}
						}
						if ( xml.SavedSearch.DuplicateFields !== undefined && xml.SavedSearch.DuplicateFields != null )
						{
							let xDuplicateFields = xml.SavedSearch.DuplicateFields;
							if ( xDuplicateFields.Field !== undefined && xDuplicateFields.Field != null )
							{
								let xFields: any = xDuplicateFields.Field;
								if ( Array.isArray(xFields.Value) )
								{
									for ( let i = 0; i < xFields.Value.length; i++ )
									{
										DUPLICATE_FILTER.push(xFields.Value[i]);
									}
								}
								else
								{
									DUPLICATE_FILTER.push(xFields.Value);
								}
							}
						}
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor rowDefaultSearch', rowDefaultSearch);
					}
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
				}
			}
		}
		// 07/20/2019 Paul.  We need to pass a flag to the EditComponents to tell them not to initialize User and Team values. 
		// 10/13/2020 Paul.  Make the condition more explicit. 
		if ( rowDefaultSearch === undefined || rowDefaultSearch == null )
		{
			rowDefaultSearch = {};
		}
		this.state =
		{
			item                  : rowDefaultSearch,
			SEARCH_MODULE         : sMODULE_NAME,
			SAVED_SEARCH_ID       : gSAVED_SEARCH_ID,
			SAVED_SEARCH_LIST     : lstOptions,
			SAVED_SEARCH_NAME     : sSAVED_SEARCH_NAME,
			SAVED_SEARCH_NEW_NAME : '',
			SAVED_SEARCH_COLUMN   : sSAVED_SEARCH_COLUMN,
			SAVED_SEARCH_DIRECTION: sSAVED_SEARCH_DIRECTION,
			SAVED_PANEL           : false,
			MODULE_COLUMNS_LIST   ,
			DUPLICATE_FILTER      ,
			savedSearchCounter    : 0,
		};
	}

	componentDidMount()
	{
		const { ShowSearchViews } = this.props;
		const { SEARCH_MODULE } = this.state;
		this._isMounted = true;
		// 10/30/2019 Paul.  Module may not be available in constructor. 
		let MODULE_COLUMNS_LIST: any[] = null;
		// 02/03/2020 Paul.  No need to get the columns for SearchHome and SearchPopup as neither allow saving the search.  Only primary modules get the Save Search option. 
		if ( ShowSearchViews )
		{
			MODULE_COLUMNS_LIST = SplendidCache.ModuleColumns(SEARCH_MODULE);
		}
		if ( MODULE_COLUMNS_LIST == null )
		{
			MODULE_COLUMNS_LIST = [];
		}
		this.setState({ MODULE_COLUMNS_LIST });
	}

	componentDidUpdate(prevProps: ISearchViewProps)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', prevProps);
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private SqlSearchClause = (cmd, arrSearchFilter) =>
	{
		const { EDIT_NAME, IsPopupSearch, ShowSearchViews } = this.props;
		const { SEARCH_MODULE, SAVED_SEARCH_ID, item } = this.state;
		try
		{
			// 05/28/2020 Paul.  Ignore missing SearchSubpanel. 
			let layout: any[] = EditView_LoadLayout(EDIT_NAME, true);
			if ( layout != null && layout.length > 0 )
			{
				let bEnableTeamManagement   : boolean = Crm_Config.enable_team_management();
				let bEnableDynamicTeams     : boolean = Crm_Config.enable_dynamic_teams();
				let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();
				// 11/15/2019 Paul.  Create dictionary of fields used in the layout. 
				let dictEditFields          : any     = {};
				for (let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++)
				{
					let lay = layout[nLayoutIndex];
					let EDIT_NAME        : string = Sql.ToString (lay['EDIT_NAME'        ]);
					let FIELD_TYPE       : string = Sql.ToString (lay['FIELD_TYPE'       ]);
					let DATA_LABEL       : string = Sql.ToString (lay['DATA_LABEL'       ]);
					let DATA_FIELD       : string = Sql.ToString (lay['DATA_FIELD'       ]);
					// 10/19/2016 Paul.  DATA_FORMAT will be FullText to indicate full-text search. 
					let DATA_FORMAT      : string = Sql.ToString (lay['DATA_FORMAT'      ]);
					let DISPLAY_FIELD    : string = Sql.ToString (lay['DISPLAY_FIELD'    ]);
					let FORMAT_MAX_LENGTH: number = Sql.ToInteger(lay['FORMAT_MAX_LENGTH']);
					let FORMAT_ROWS      : number = Sql.ToInteger(lay['FORMAT_ROWS'      ]);
					let IS_MULTI_SELECT  : boolean = Sql.ToBoolean(lay['IS_MULTI_SELECT' ]);
					// 01/29/2021 Paul.  A list view may be required, so use first value if not provided. 
					let DATA_REQUIRED    : boolean = Sql.ToBoolean(lay['DATA_REQUIRED'   ]);
					let UI_REQUIRED      : boolean = Sql.ToBoolean(lay['UI_REQUIRED'     ]);
					let LIST_NAME        : string  = Sql.ToString (lay['LIST_NAME'       ]);
					let MODULE_NAME      : string = EDIT_NAME.split('.')[0];
					if ( Sql.IsEmptyString(DATA_FIELD) )
					{
						continue;
					}
					// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
					if ( (DATA_FIELD == 'TEAM_ID' || DATA_FIELD == 'TEAM_SET_NAME') )
					{
						if ( !bEnableTeamManagement )
						{
							FIELD_TYPE = 'Blank';
							// 10/24/2012 Paul.  Clear the label to prevent a term lookup. 
							DATA_LABEL  = null;
							DATA_FIELD  = null;
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
								}
							}
						}
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( (DATA_FIELD == 'ASSIGNED_USER_ID' || DATA_FIELD == 'ASSIGNED_SET_NAME') )
					{
						// 01/06/2018 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
						if ( bEnableDynamicAssignment && DATA_FORMAT != "1" )
						{
							if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
							{
								DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
								DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
								FIELD_TYPE     = 'UserSelect'            ;
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
							}
						}
					}
					dictEditFields[DATA_FIELD] = true;
					let oValue   : any      = item[DATA_FIELD];
					// 11/30/2020 Paul.  DateRange values are stored in After and Before. 
					if ( FIELD_TYPE == 'DateRange' )
					{
						if ( oValue === undefined || oValue == null )
						{
							continue;
						}
						let bAfterFound : boolean = true;
						let bBeforeFound: boolean = true;
						if ( oValue['After'] === undefined || oValue['After'] == null || Sql.IsEmptyString(oValue['After']) )
						{
							bAfterFound = false;
						}
						if ( oValue['Before'] === undefined || oValue['Before'] == null || Sql.IsEmptyString(oValue['Before']) )
						{
							bBeforeFound = false;
						}
						if ( !bAfterFound && !bBeforeFound )
						{
							continue;
						}
					}
					// 01/29/2021 Paul.  A list view may be required, so use first value if not provided. 
					else if ( FIELD_TYPE == 'ListBox' )
					{
						if ( (DATA_REQUIRED || UI_REQUIRED) && !IS_MULTI_SELECT )
						{
							if ( oValue === undefined )
							{
								let arrLIST: string[] = L10n.GetList(LIST_NAME);
								if ( arrLIST != null && arrLIST.length > 0 )
								{
									oValue = arrLIST[0];
								}
							}
						}
					}
					else if ( oValue === undefined || oValue == null || Sql.IsEmptyString(oValue) )
					{
						continue;
					}
					let filter: any = { FIELD_TYPE, DATA_FORMAT, MODULE_NAME, FORMAT_MAX_LENGTH, IS_MULTI_SELECT, value: oValue };
					arrSearchFilter[DATA_FIELD] = filter;
					this.SqlAppendSearch(cmd, FIELD_TYPE, DATA_FIELD, DATA_FORMAT, MODULE_NAME, FORMAT_MAX_LENGTH, IS_MULTI_SELECT, oValue);
				}
				// 09/02/2010 Paul.  We need a second pass to set values specified in the Saved Search but not available in the EditView. 
				// 09/13/2011 Paul.  We don't want to apply the saved search in a popup. 
				if ( !Sql.IsEmptyString(SAVED_SEARCH_ID) && (!IsPopupSearch && ShowSearchViews) )
				{
					let search: any = SplendidCache.GetSavedSearch(SEARCH_MODULE, SAVED_SEARCH_ID);
					if ( search != null && !Sql.IsEmptyString(search.CONTENTS) && StartsWith(search.CONTENTS, '<?xml') )
					{
						// https://www.npmjs.com/package/fast-xml-parser
						let options: any = 
						{
							attributeNamePrefix: '',
							// 02/18/2024 Paul.  parser v4 does not have an issue with node name as there is no value tag. 
							//  <SearchFields>
							//    <Field Name="CATEGORY_ID" Type="ListBox"></Field>
							//    <Field Name="SUBCATEGORY_ID" Type="ListBox"></Field>
							//    <Field Name="EXP_DATE" Type="DateRange">
							//      <Before>02/25/2024</Before>
							//      <After>02/18/2024</After>
							//    </Field>
							//  </SearchFields>
							textNodeName       : 'Value',
							ignoreAttributes   : false,
							ignoreNameSpace    : true,
							parseAttributeValue: true,
							trimValues         : false,
						};
						// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
						const parser = new XMLParser(options);
						let xml = parser.parse(search.CONTENTS);
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', xml);
						if ( xml.SavedSearch != null && xml.SavedSearch.SearchFields !== undefined && xml.SavedSearch.SearchFields != null )
						{
							let xSearchFields = xml.SavedSearch.SearchFields;
							if ( xSearchFields.Field !== undefined && xSearchFields.Field != null )
							{
								let xFields: any = xSearchFields.Field;
								if ( Array.isArray(xFields) )
								{
									for ( let i = 0; i < xFields.length; i++ )
									{
										let xField = xFields[i];
										let DATA_FIELD: string = xField.Name ;
										let FIELD_TYPE: string = xField.Type ;
										let oValue    : any    = xField.Value;
										if ( !dictEditFields[DATA_FIELD] )
										{
											let filter: any = { FIELD_TYPE, DATA_FORMAT: null, MODULE_NAME: null, FORMAT_MAX_LENGTH: 0, IS_MULTI_SELECT: false, value: oValue };
											arrSearchFilter[DATA_FIELD] = filter;
											this.SqlAppendSearch(cmd, FIELD_TYPE, DATA_FIELD, '', SEARCH_MODULE, 0, false, oValue);
										}
									}
								}
								else if ( xFields.Name !== undefined )
								{
									let DATA_FIELD: string = xFields.Name ;
									let FIELD_TYPE: string = xFields.Type ;
									let oValue    : any    = xFields.Value;
									if ( !dictEditFields[DATA_FIELD] )
									{
										let filter: any = { FIELD_TYPE, DATA_FORMAT: null, MODULE_NAME: null, FORMAT_MAX_LENGTH: 0, IS_MULTI_SELECT: false, value: oValue };
										arrSearchFilter[DATA_FIELD] = filter;
										this.SqlAppendSearch(cmd, FIELD_TYPE, DATA_FIELD, '', SEARCH_MODULE, 0, false, oValue);
									}
								}
							}
						}
					}
				}
			}
			else
			{
				//console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.SqlSearchClause: Could not find layout: ' + EDIT_NAME);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.SqlSearchClause ' + EDIT_NAME, error);
		}
		return cmd.CommandText;
	}

	private SqlAppendSearch = (cmd: any, FIELD_TYPE: string, DATA_FIELD: string, DATA_FORMAT: string, MODULE_NAME: string, FORMAT_MAX_LENGTH: number, IS_MULTI_SELECT: boolean, oValue: any) =>
	{
		const { item } = this.state;
		// 04/09/2011 Paul.  Change the field to a hidden field so that we can add Report Parameters. 
		if ( FIELD_TYPE == 'Hidden' )
		{
			Sql.AppendParameter(cmd, DATA_FIELD, oValue);
		}
		// 04/05/2012 Paul.  Add searching support for checkbox list. 
		else if ( FIELD_TYPE == 'CheckBoxList' )
		{
			if ( Array.isArray(oValue) && oValue.length > 0 )
			{
				let arr: string[] = [];
				for ( let i = 0; i < oValue.length; i++ )
				{
					if ( !Sql.IsEmptyString(oValue[i]) )
					{
						arr.push('<Value>' + Sql.EscapeXml(oValue[i]) + '</Value>');
					}
					else
					{
						// 10/13/2011 Paul.  A multi-selection list box does not have NULL, so look for any empty value. 
						arr.push('<Value></Value>');
					}
				}
				Sql.AppendLikeParameters(cmd, DATA_FIELD, arr);
			}
		}
		else if ( FIELD_TYPE == 'Radio' )
		{
			Sql.AppendParameter(cmd, DATA_FIELD, oValue);
		}
		else if ( FIELD_TYPE == 'ListBox' )
		{
			if ( Array.isArray(oValue) )
			{
				let arrFields: string[] = DATA_FIELD.split(' ');
				if ( oValue.length == 1 && Sql.IsEmptyString(oValue[0]) && !(DATA_FIELD == 'TEAM_ID' && Crm_Config.enable_dynamic_teams() || DATA_FIELD == 'ASSIGNED_USER_ID' && Crm_Config.enable_dynamic_assignment() ) )
				{
					if ( cmd.CommandText.length > 0 )
					{
						cmd.CommandText += ' and ';
					}
					if ( arrFields.length > 1 )
					{
						cmd.CommandText += '(1 = 0' + ControlChars.CrLf;
						for ( let iField = 0; iField < arrFields.length; iField++ )
						{
							cmd.CommandText += '        or ' + arrFields[iField] + ' is null' + ControlChars.CrLf;
						}
						cmd.CommandText += '       )' + ControlChars.CrLf;
					}
					else
					{
						cmd.CommandText += DATA_FIELD + ' is null' + ControlChars.CrLf;
					}
				}
				else if ( oValue.length > 0 )
				{
					if ( arrFields.length > 1 )
					{
						if ( cmd.CommandText.length > 0 )
						{
							cmd.CommandText += ' and ';
						}
						cmd.CommandText += '(1 = 0' + ControlChars.CrLf;
						for ( let iField = 0; iField < arrFields.length; iField++ )
						{
							// 03/04/2009 Paul.  Need to allow NULL or the selected values. 
							// 10/13/2011 Paul.  Special list of EditViews for the search area with IS_MULTI_SELECT. 
							if ( IS_MULTI_SELECT )
							{
								let arr: string[] = [];
								for ( let i = 0; i < oValue.length; i++ )
								{
									if ( !Sql.IsEmptyString(oValue[i]) )
									{
										// 04/05/2012 Paul.  Enclose in tags so that the search is more exact. 
										arr.push('<Value>' + Sql.EscapeXml(oValue[i]) + '</Value>');
									}
									else
									{
										// 10/13/2011 Paul.  A multi-selection list box does not have NULL, so look for any empty value. 
										arr.push('<Value></Value>');
									}
								}
								cmd.CommandText += '     ';
								Sql.AppendLikeParameters(cmd, arrFields[iField], arr, true);
							}
							else
							{
								cmd.CommandText += '     ';
								Sql.AppendParameterWithNull(cmd, arrFields[iField], oValue, true);
							}
						}
						cmd.CommandText += '       )' + ControlChars.CrLf;
					}
					// 08/25/2009 Paul.  Add support for dynamic teams. 
					else if ( DATA_FIELD == 'TEAM_ID' )
					{
						if ( Crm_Config.enable_dynamic_teams() )
						{
							if ( cmd.CommandText.length > 0 )
							{
								cmd.CommandText += ' and ';
							}
							cmd.CommandText += 'TEAM_SET_ID in (select MEMBERSHIP_TEAM_SET_ID' + ControlChars.CrLf;
							cmd.CommandText += '                       from vwTEAM_SET_MEMBERSHIPS' + ControlChars.CrLf;
							cmd.CommandText += '                      where 1 = 1                 ' + ControlChars.CrLf;
							cmd.CommandText += '                     ';
							Sql.AppendParameterWithNull(cmd, 'MEMBERSHIP_TEAM_ID', oValue);
							cmd.CommandText += '                    )' + ControlChars.CrLf;
						}
						// 05/11/2010 Paul.  If we are in a list, then it does not make sense to get a single ID. 
						//else if ( !Sql.IsEmptyGuid(ctl.ID) )
						//{
						//	Sql.AppendParameter(cmd, ctl.ID, DATA_FIELD);
						//}
						else
						{
							Sql.AppendParameterWithNull(cmd, DATA_FIELD, oValue);
						}
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( DATA_FIELD == "ASSIGNED_USER_ID" )
					{
						if ( Crm_Config.enable_dynamic_assignment() )
						{
							if ( cmd.CommandText.length > 0 )
							{
								cmd.CommandText += ' and ';
							}
							cmd.CommandText += 'ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID' + ControlChars.CrLf;
							cmd.CommandText += '                           from vwASSIGNED_SET_MEMBERSHIPS' + ControlChars.CrLf;
							cmd.CommandText += '                          where 1 = 1                     ' + ControlChars.CrLf;
							cmd.CommandText += '                         ';
							Sql.AppendParameterWithNull(cmd, 'MEMBERSHIP_ASSIGNED_USER_ID', oValue);
							cmd.CommandText += '                        )' + ControlChars.CrLf;
						}
						else
						{
							Sql.AppendParameterWithNull(cmd, DATA_FIELD, oValue);
						}
					}
					// 04/25/2013 Paul.  Special list of EditViews for the search area with IS_MULTI_SELECT. 
					else if ( IS_MULTI_SELECT )
					{
						let arr: string[] = [];
						for ( let i = 0; i < oValue.length; i++ )
						{
							if ( !Sql.IsEmptyString(oValue[i]) )
							{
								// 04/05/2012 Paul.  Enclose in tags so that the search is more exact. 
								arr.push('<Value>' + Sql.EscapeXml(oValue[i]) + '</Value>');
							}
							else
							{
								// 10/13/2011 Paul.  A multi-selection list box does not have NULL, so look for any empty value. 
								arr.push('<Value></Value>');
							}
						}
						Sql.AppendLikeParameters(cmd, DATA_FIELD, arr);
					}
					else
					{
						// 03/04/2009 Paul.  Need to allow NULL or the selected values. 
						Sql.AppendParameterWithNull(cmd, DATA_FIELD, oValue);
					}
				}
			}
			else
			{
				Sql.AppendParameter(cmd, DATA_FIELD, oValue);
			}
		}
		else if ( FIELD_TYPE == 'DatePicker' )
		{
			let arrFields: string[] = DATA_FIELD.split(' ');
			if ( arrFields.length > 1 )
			{
				if ( cmd.CommandText.length > 0 )
				{
					cmd.CommandText += ' and ';
				}
				cmd.CommandText += '(1 = 0' + ControlChars.CrLf;
				for ( let iField = 0; iField < arrFields.length; iField++ )
				{
					cmd.CommandText += '      or ' + arrFields[iField] + ' = \'' + formatDate(oValue, 'YYYY/MM/DD') + '\'' + ControlChars.CrLf;
				}
				cmd.CommandText += '     )' + ControlChars.CrLf;
			}
			else
			{
				Sql.AppendParameter(cmd, DATA_FIELD, formatDate(oValue, 'YYYY/MM/DD'));
			}
		}
		else if ( FIELD_TYPE == 'DateRange' )
		{
			let oValue = item[DATA_FIELD];
			if ( oValue != null )
			{
				if ( oValue.After !== undefined && oValue.After != null )
				{
					if ( cmd.CommandText.length > 0 )
					{
						cmd.CommandText += ' and ';
					}
					cmd.CommandText += DATA_FIELD + ' >= \'' + formatDate(oValue.After, 'YYYY/MM/DD') + '\'' + ControlChars.CrLf;
				}
				if ( oValue.Before !== undefined && oValue.Before != null )
				{
					if ( cmd.CommandText.length > 0 )
					{
						cmd.CommandText += ' and ';
					}
					cmd.CommandText += DATA_FIELD + ' <= \'' + formatDate(oValue.Before, 'YYYY/MM/DD') + '\'' + ControlChars.CrLf;
				}
			}
		}
		else if ( FIELD_TYPE == 'CheckBox' )
		{
			let checked: boolean = Sql.ToBoolean(oValue);
			// 12/02/2007 Paul.  Only search for checked fields if they are checked. 
			if ( checked )
			{
				// 12/02/2007 Paul.  Unassigned checkbox has a special meaning. 
				if ( DATA_FIELD == 'UNASSIGNED_ONLY' )
				{
					if ( cmd.CommandText.length > 0 )
					{
						cmd.CommandText += ' and ';
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( Crm_Config.enable_dynamic_assignment() )
					{
						cmd.CommandText += 'ASSIGNED_SET_ID is null' + ControlChars.CrLf;
					}
					else
					{
						// 10/04/2006 Paul.  Add flag to show only records that are not assigned. 
						cmd.CommandText += 'ASSIGNED_USER_ID is null' + ControlChars.CrLf;
					}
				}
				else if ( DATA_FIELD == 'CURRENT_USER_ONLY' )
				{
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( Crm_Config.enable_dynamic_assignment() )
					{
						if ( cmd.CommandText.length > 0 )
						{
							cmd.CommandText += ' and ';
						}
						cmd.CommandText += 'ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID' + ControlChars.CrLf;
						cmd.CommandText += '                           from vwASSIGNED_SET_MEMBERSHIPS' + ControlChars.CrLf;
						cmd.CommandText += '                          where 1 = 1                     ' + ControlChars.CrLf;
						cmd.CommandText += '                            ';
						Sql.AppendParameter(cmd, 'MEMBERSHIP_ASSIGNED_USER_ID', Security.USER_ID());
						cmd.CommandText += '                        )' + ControlChars.CrLf;
					}
					else
					{
						Sql.AppendParameter(cmd, 'ASSIGNED_USER_ID', Security.USER_ID(), false);
					}
				}
				// 03/31/2012 Paul.  FAVORITE_RECORD_ID has a special meaning. 
				else if ( DATA_FIELD == 'FAVORITE_RECORD_ID' )
				{
					if ( cmd.CommandText.length > 0 )
					{
						cmd.CommandText += ' and ';
					}
					cmd.CommandText += 'FAVORITE_RECORD_ID is not null' + ControlChars.CrLf;
				}
				else
				{
					// 04/27/2008 Paul.  The boolean AppendParameter now requires the IsEmpty flag. 
					// In this case, it is false when the value is checked. 
					Sql.AppendParameter(cmd, DATA_FIELD, checked, !checked);
				}
			}
		}
		else if ( FIELD_TYPE == 'TextBox' )
		{
			let oSearchBuilder = new SearchBuilder();
			oSearchBuilder.Init(oValue);
			let arrFields: string[] = DATA_FIELD.split(' ');
			// 10/19/2016 Paul.  Check for Full-Text Search. 
			if ( StartsWith(DATA_FORMAT.toLowerCase(), 'fulltext') )
			{
				let arrDATA_FORMAT  : string[] = DATA_FORMAT.split(' ');
				// 05/21/2018 Paul.  String.Empty does not exist in JavaScript. 
				let sFULL_TEXT_TABLE: string = '';
				let sFULL_TEXT_FIELD: string = '';
				let sFULL_TEXT_KEY  : string = '';
				if ( arrDATA_FORMAT.length >= 2 )
				{
					sFULL_TEXT_TABLE = arrDATA_FORMAT[1];
				}
				if ( sFULL_TEXT_TABLE.toLowerCase() == 'documents' )
				{
					sFULL_TEXT_TABLE = 'DOCUMENT_REVISIONS';
					sFULL_TEXT_FIELD = 'CONTENT'           ;
					sFULL_TEXT_KEY   = 'DOCUMENT_ID'       ;
				}
				else if ( sFULL_TEXT_TABLE.toLowerCase() == 'notes' )
				{
					sFULL_TEXT_TABLE = 'NOTE_ATTACHMENTS';
					sFULL_TEXT_FIELD = 'ATTACHMENT'      ;
					sFULL_TEXT_KEY   = 'NOTE_ID'         ;
				}
				// 10/24/2016 Paul.  KBDocuments use the NOTE_ATTACHMENTS table for attachments and EMAIL_IMAGES table for images. 
				else if ( sFULL_TEXT_TABLE.toLowerCase() == 'kbdocuments' )
				{
					sFULL_TEXT_TABLE = 'NOTE_ATTACHMENTS';
					sFULL_TEXT_FIELD = 'ATTACHMENT'      ;
					sFULL_TEXT_KEY   = 'NOTE_ID'         ;
				}
				else if ( arrDATA_FORMAT.length >= 4 )
				{
					sFULL_TEXT_FIELD = arrDATA_FORMAT[2];
					sFULL_TEXT_KEY   = arrDATA_FORMAT[3];
				}
				if ( !Sql.IsEmptyString(oValue) && !Sql.IsEmptyString(sFULL_TEXT_TABLE) && !Sql.IsEmptyString(sFULL_TEXT_FIELD) && !Sql.IsEmptyString(sFULL_TEXT_KEY) )
				{
					if ( cmd.CommandText.length > 0 )
					{
						cmd.CommandText += ' and ';
					}
					cmd.CommandText += 'ID in (select ' + sFULL_TEXT_KEY + ' from ' + sFULL_TEXT_TABLE + ' where contains(' + sFULL_TEXT_FIELD + ', \'' + Sql.EscapeSQL(oValue) + '\'))' + ControlChars.CrLf;
				}
			}
			// 07/26/2018 Paul.  Allow a normalized phone search that used the special phone tables. 
			else if ( StartsWith(DATA_FORMAT.toLowerCase(), 'normalizedphone') && (MODULE_NAME == 'Accounts' || MODULE_NAME == 'Contacts' || MODULE_NAME == 'Leads' || MODULE_NAME == 'Prospects') )
			{
				if ( !Sql.IsEmptyString(oValue) )
				{
					if ( cmd.CommandText.length > 0 )
					{
						cmd.CommandText += ' and ';
					}
					let sNORMALIZED_NUMBER: string = Sql.NormalizePhone(oValue) + '%';
					let vwNORMALIZED_VIEW : string = 'vwPHONE_NUMBERS_' + Crm_Modules.TableName(MODULE_NAME);
					// 08/08/2018 Paul.  Use like clause for more flexible phone number lookup. 
					cmd.CommandText += 'ID in (select ID from ' + vwNORMALIZED_VIEW + ' where NORMALIZED_NUMBER like \'' + sNORMALIZED_NUMBER + '\')' + ControlChars.CrLf;
				}
			}
			// 09/20/2022 Paul.  Need a way to default to exact search.  Exclude if text contains any search builder token, including space. 
			else if ( StartsWith(DATA_FORMAT.toLowerCase(), 'exact') && !Sql.IsEmptyString(oValue) && !(/[=\"+\-\<\>\!\s;,\*]/.test(oValue)) )
			{
				cmd.CommandText += oSearchBuilder.BuildQuery(' and ', DATA_FIELD, '=' + oValue) + ControlChars.CrLf;
			}
			else if ( arrFields.length > 1 )
			{
				if ( cmd.CommandText.length > 0 )
				{
					cmd.CommandText += ' and ';
				}
				cmd.CommandText += '(1 = 0' + ControlChars.CrLf;
				for ( let iField = 0; iField < arrFields.length; iField++ )
				{
					cmd.CommandText += oSearchBuilder.BuildQuery('        or ', arrFields[iField], oValue) + ControlChars.CrLf;
				}
				cmd.CommandText += '     )' + ControlChars.CrLf;
			}
			else
			{
				cmd.CommandText += oSearchBuilder.BuildQuery(' and ', DATA_FIELD, oValue) + ControlChars.CrLf;
			}
		}
		else if ( FIELD_TYPE == 'ZipCodePopup' )
		{
			let oSearchBuilder = new SearchBuilder();
			oSearchBuilder.Init(oValue);
			let arrFields: string[] = DATA_FIELD.split(' ');
			if ( arrFields.length > 1 )
			{
				if ( cmd.CommandText.length > 0 )
				{
					cmd.CommandText += ' and ';
				}
				cmd.CommandText += '(1 = 0' + ControlChars.CrLf;
				for ( let iField = 0; iField < arrFields.length; iField++ )
				{
					cmd.CommandText += oSearchBuilder.BuildQuery('        or ', arrFields[iField], oValue) + ControlChars.CrLf;
				}
				cmd.CommandText += '     )' + ControlChars.CrLf;
			}
			else
			{
				cmd.CommandText += oSearchBuilder.BuildQuery(' and ', DATA_FIELD, oValue) + ControlChars.CrLf;
			}
		}
		else if ( FIELD_TYPE == 'ChangeButton' || FIELD_TYPE == 'ModulePopup' )
		{
			// 09/05/2010 Paul.  Also allow for a custom field to be treated as an ID. 
			if ( FORMAT_MAX_LENGTH == 0 && (EndsWith(DATA_FIELD, '_ID') || EndsWith(DATA_FIELD, '_ID_C')) )
			{
				if ( !Sql.IsEmptyGuid(oValue) )
				{
					// 08/25/2009 Paul.  Add support for dynamic teams. 
					if ( DATA_FIELD == 'TEAM_ID' || DATA_FIELD == 'TEAM_SET_NAME' )
					{
						if ( Crm_Config.enable_dynamic_teams() )
						{
							if ( cmd.CommandText.length > 0 )
							{
								cmd.CommandText += ' and ';
							}
							cmd.CommandText += 'TEAM_SET_ID in (select MEMBERSHIP_TEAM_SET_ID' + ControlChars.CrLf;
							cmd.CommandText += '                       from vwTEAM_SET_MEMBERSHIPS' + ControlChars.CrLf;
							cmd.CommandText += '                      where 1 = 1                 ' + ControlChars.CrLf;
							cmd.CommandText += '                     ';
							Sql.AppendParameter(cmd, 'MEMBERSHIP_TEAM_ID', oValue);
							cmd.CommandText += '                    )' + ControlChars.CrLf;
						}
						else
						{
							Sql.AppendParameter(cmd, DATA_FIELD, oValue);
						}

					}
					else
					{
						Sql.AppendParameter(cmd, DATA_FIELD, oValue);
					}
				}
			}
			else
			{
				let oSearchBuilder = new SearchBuilder();
				oSearchBuilder.Init(oValue);
				cmd.CommandText += oSearchBuilder.BuildQuery(' and ', DATA_FIELD, oValue) + ControlChars.CrLf;
			}
		}
		else if ( FIELD_TYPE == 'TeamSelect' )
		{
			if ( Crm_Config.enable_dynamic_teams() )
			{
				// 09/01/2009 Paul.  Make sure not to filter if nothing is selected. 
				if ( Array.isArray(oValue) && oValue.length > 0 )
				{
					let arr: string[] = [];
					for ( let iTeam = 0; iTeam < oValue.length; iTeam++ )
					{
						arr.push(oValue[iTeam].DATA_VALUE);
					}
					if ( cmd.CommandText.length > 0 )
					{
						cmd.CommandText += ' and ';
					}
					cmd.CommandText += 'TEAM_SET_ID in (select MEMBERSHIP_TEAM_SET_ID' + ControlChars.CrLf;
					cmd.CommandText += '                       from vwTEAM_SET_MEMBERSHIPS' + ControlChars.CrLf;
					cmd.CommandText += '                      where 1 = 1                 ' + ControlChars.CrLf;
					cmd.CommandText += '                     ';
					Sql.AppendGuids(cmd, 'MEMBERSHIP_TEAM_ID', arr);
					cmd.CommandText += '                    )' + ControlChars.CrLf;
				}
			}
			else
			{
				// 04/18/2010 Paul.  Make sure not to filter if nothing is selected. 
				if ( !Sql.IsEmptyGuid(oValue) )
					Sql.AppendParameter(cmd, 'TEAM_ID', oValue);
			}
		}
		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		else if ( FIELD_TYPE == 'UserSelect' )
		{
			if ( Crm_Config.enable_dynamic_assignment() )
			{
				if ( Array.isArray(oValue) && oValue.length > 0 )
				{
					let arr: string[] = [];
					for ( let iUser = 0; iUser < oValue.length; iUser++ )
					{
						arr.push(oValue[iUser].DATA_VALUE);
					}
					if ( cmd.CommandText.length > 0 )
					{
						cmd.CommandText += ' and ';
					}
					cmd.CommandText += 'ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID' + ControlChars.CrLf;
					cmd.CommandText += '                           from vwASSIGNED_SET_MEMBERSHIPS' + ControlChars.CrLf;
					cmd.CommandText += '                          where 1 = 1                     ' + ControlChars.CrLf;
					cmd.CommandText += '                            ';
					Sql.AppendGuids(cmd, 'MEMBERSHIP_ASSIGNED_USER_ID', arr);
					cmd.CommandText += '                        )' + ControlChars.CrLf;
				}
			}
			else
			{
				// 11/30/2017 Paul.  Make sure not to filter if nothing is selected. 
				if ( !Sql.IsEmptyGuid(oValue) )
				{
					Sql.AppendParameter(cmd, 'USER_ID', oValue);
				}
			}
		}
		// 05/12/2016 Paul.  Add Tags module. 
		else if ( FIELD_TYPE == 'TagSelect' )
		{
			if ( Array.isArray(oValue) && oValue.length > 0 )
			{
				let arr: string[] = [];
				for (let iTag = 0; iTag < oValue.length; iTag++ )
				{
					arr.push(oValue[iTag].DISPLAY_VALUE);
				}
				if ( cmd.CommandText.length > 0 )
				{
					cmd.CommandText += ' and ';
				}
				cmd.CommandText += 'ID in (select BEAN_ID       ' + ControlChars.CrLf;
				cmd.CommandText += '              from vwTAG_BEAN_REL' + ControlChars.CrLf;
				cmd.CommandText += '             where 1 = 0         ' + ControlChars.CrLf;
				cmd.CommandText += '                ';
				Sql.AppendParameter(cmd, 'TAG_NAME', arr, true);
				cmd.CommandText += '           )' + ControlChars.CrLf;
			}
		}
		// 06/07/2017 Paul.  Add NAICSCodes module. 
		else if ( FIELD_TYPE == 'NAICSCodeSelect' )
		{
			if ( Array.isArray(oValue) && oValue.length > 0 )
			{
				let arr: string[] = [];
				for (let iTag = 0; iTag < oValue.length; iTag++ )
				{
					arr.push(oValue[iTag].DISPLAY_VALUE);
				}
				if ( cmd.CommandText.length > 0 )
				{
					cmd.CommandText += ' and ';
				}
				cmd.CommandText += 'ID in (select PARENT_ID            ' + ControlChars.CrLf;
				cmd.CommandText += '              from vwNAICS_CODES_RELATED' + ControlChars.CrLf;
				cmd.CommandText += '             where 1 = 0                ' + ControlChars.CrLf;
				cmd.CommandText += '                ';
				Sql.AppendParameter(cmd, 'NAICS_CODE_NAME', arr, true);
				cmd.CommandText += '           )' + ControlChars.CrLf;
			}
		}
		else if ( FIELD_TYPE == 'ModuleAutoComplete' )
		{
			let oSearchBuilder = new SearchBuilder();
			oSearchBuilder.Init(oValue);
			cmd.CommandText += oSearchBuilder.BuildQuery(' and ', DATA_FIELD, oValue) + ControlChars.CrLf;
		}
		else
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.SqlAppendSearch: Unknown field type: ' + FIELD_TYPE);
		}
	}

	// 11/11/2020 Paul.  We need to send the grid sort event to the SearchView. 
	public UpdateSortState(sortField: string, sortOrder: string)
	{
		this.setState(
		{
			SAVED_SEARCH_COLUMN   : sortField,
			SAVED_SEARCH_DIRECTION: sortOrder,
		});
	}

	// 07/13/2019 Paul.  Make search method public so that it can be called from a reference. 
	// 01/19/2020 Paul.  This should not be an async function.  The array needs to be fully rendered, not promised. 
	public SubmitSearch = () =>
	{
		const { EDIT_NAME, AutoSaveSearch, IsPopupSearch, ShowDuplicateFilter, cbSearch } = this.props;
		const { item, SAVED_SEARCH_ID, SAVED_SEARCH_COLUMN, SAVED_SEARCH_DIRECTION, DUPLICATE_FILTER } = this.state;
		const ControlChars = { CrLf: '\r\n', Cr: '\r', Lf: '\n', Tab: '\t' };
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.SubmitSearch');
		let arrSavedSearchFields = new Array();
		try
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.SubmitSearch', cmd.CommandText);
			// 10/24/2012 Paul.  rowSEARCH_VALUES is the field data used to build the SQL sFILTER string. 
			if ( cbSearch !== undefined && cbSearch != null )
			{
				let cmd: any = new Object();
				cmd.CommandText = '';
				let arrSearchFilter: any = {};
				let sDebugSQL: string = this.SqlSearchClause(cmd, arrSearchFilter);
				if ( !IsPopupSearch && ShowDuplicateFilter && DUPLICATE_FILTER )
				{
					arrSearchFilter['DUPLICATE_FILTER'] = DUPLICATE_FILTER;
				}
				for ( let DATA_FIELD in arrSearchFilter )
				{
					let objField: any = new Object();
					arrSavedSearchFields.push(objField);
					objField['@Name'] = DATA_FIELD;
					objField['@Type'] = arrSearchFilter[DATA_FIELD].FIELD_TYPE;
					objField.Value    = arrSearchFilter[DATA_FIELD].value;
					// 11/30/2020 Paul.  Need to update the search fields earlier in the process. 
					if ( objField['@Type'] == 'DatePicker' )
					{
						if ( typeof(objField.Value) == 'object' )
						{
							// 11/30/2020 Paul.  Save date as string. 
							objField.Value = formatDate(objField.Value, Security.USER_DATE_FORMAT());
						}
					}
					else if ( objField['@Type']  == 'DateTimePicker' || objField['@Type']  == 'DateTimeEdit' || objField['@Type']  == 'DateTimeNewRecord' )
					{
						if ( typeof(objField.Value) == 'object' )
						{
							// 11/30/2020 Paul.  Save date as string. 
							objField.Value = formatDate(objField.Value, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
						}
					}
					else if ( objField['@Type']  == 'DateRange' && objField.Value )
					{
						// 11/25/2020 Paul.  When saving DateRange, before and after are not under the Value field. 
						if ( objField.Value.before )
						{
							objField.Before = objField.Value.before;
						}
						if ( objField.Value.Before )
						{
							objField.Before = objField.Value.Before;
						}
						if ( objField.Value.after )
						{
							objField.After = objField.Value.after;
						}
						if ( objField.Value.After )
						{
							objField.After = objField.Value.After;
						}
						if ( typeof(objField.Before) == 'object' )
						{
							// 11/30/2020 Paul.  Save date as string. 
							objField.Before = formatDate(objField.Before, Security.USER_DATE_FORMAT());
						}
						if ( typeof(objField.After) == 'object' )
						{
							// 11/30/2020 Paul.  Save date as string. 
							objField.After = formatDate(objField.After, Security.USER_DATE_FORMAT());
						}
						delete objField.Value;
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.SubmitSearch', cmd.CommandText, arrSavedSearchFields, arrSearchFilter);
				// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
				let oSORT: any = null;
				// 11/09/2020 Paul.  In order to sort using the default search, we cannot filter on SAVED_SEARCH_ID. 
				if ( !Sql.IsEmptyString(SAVED_SEARCH_COLUMN) && !Sql.IsEmptyString(SAVED_SEARCH_DIRECTION) )
				{
					oSORT = { SORT_FIELD: SAVED_SEARCH_COLUMN, SORT_DIRECTION: SAVED_SEARCH_DIRECTION};
				}
				cbSearch(cmd.CommandText, arrSearchFilter, oSORT);
				this.setState({ sDebugSQL, sOldSQL: cmd.CommandText });
			}
			else
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.SubmitSearch ' + EDIT_NAME, 'cbSearch is not defined');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.SubmitSearch ' + EDIT_NAME, error);
		}
		return arrSavedSearchFields;
	}

	private _onSubmit = async (e) =>
	{
		const { EDIT_NAME, AutoSaveSearch, IsPopupSearch, ShowDuplicateFilter } = this.props;
		const { SEARCH_MODULE, SAVED_SEARCH_ID, DUPLICATE_FILTER, item, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', item);
		if (e)
		{
			e.preventDefault();
		}
		try
		{
			// 11/25/2020 Paul.  Copy search fields so that we can save date as text. 
			let arrSavedSearchFields = Sql.DeepCopy(this.SubmitSearch());
			// 11/30/2020 Paul.  Need to update the search fields earlier in the process. 
			if ( AutoSaveSearch && !IsPopupSearch )
			{
				let objSavedSearch: any = new Object();
				objSavedSearch.SavedSearch                    = new Object();
				objSavedSearch.SavedSearch.SortColumn         = new Object();
				objSavedSearch.SavedSearch.SortColumn.Value   = 'NAME';
				objSavedSearch.SavedSearch.SortOrder          = new Object();
				objSavedSearch.SavedSearch.SortOrder.Value    = 'asc';
				objSavedSearch.SavedSearch.SearchFields       = new Object();
				objSavedSearch.SavedSearch.SearchFields.Field = arrSavedSearchFields;
				if ( ShowDuplicateFilter )
				{
					objSavedSearch.SavedSearch.DuplicateFields = new Object();
					
					let objField: any = new Object();
					objSavedSearch.SavedSearch.DuplicateFields.Field = objField;
					objField['@Name'] = 'lstDuplicateColumns';
					objField['@Type'] = 'ListBox';
					objField.Value = DUPLICATE_FILTER;
				}
				// 07/31/2019 Paul.  Pull the default sort from the module. 
				let module:MODULE = SplendidCache.Module(SEARCH_MODULE, this.constructor.name + '._onSubmit');
				if ( module != null )
				{
					let DEFAULT_SORT = Sql.ToString(module.DEFAULT_SORT);
					if ( !Sql.IsEmptyString(DEFAULT_SORT) )
					{
						let arrDEFAULT_SORT = DEFAULT_SORT.split(' ');
						if ( arrDEFAULT_SORT.length > 1 )
						{
							objSavedSearch.SavedSearch.SortColumn.Value   = arrDEFAULT_SORT[0];
							objSavedSearch.SavedSearch.SortOrder.Value    = arrDEFAULT_SORT[1];
						}
					}
				}

				// https://www.npmjs.com/package/fast-xml-parser
				let options: any = 
				{
					attributeNamePrefix: '@',
					textNodeName       : 'Value',
					ignoreAttributes   : false,
					ignoreNameSpace    : true,
					parseAttributeValue: true,
					trimValues         : false,
					format             : true,
					// 02/17/2024 Paul.  parser v4 requires suppressBooleanAttributes, otherwise Visible does not include ="true"
					allowBooleanAttributes: true,
					suppressBooleanAttributes: false,
				};
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				const builder = new XMLBuilder(options);
				let sXML: string = '<?xml version="1.0" encoding="UTF-8"?>' + builder.build(objSavedSearch);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', sXML);

				await UpdateSavedSearch(null, SEARCH_MODULE, sXML, null, SAVED_SEARCH_ID);
				if ( !Sql.IsEmptyString(error) && this._isMounted )
				{
					this.setState({ error: null });
				}
				// 05/15/2019 Paul.  Update cache afterward in case there is an error. 
				SplendidCache.UpdateDefaultSavedSearch(SEARCH_MODULE, sXML, SAVED_SEARCH_ID);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	private _onClear = async (e) =>
	{
		const { EDIT_NAME, AutoSaveSearch, IsPopupSearch } = this.props;
		const { SEARCH_MODULE, item } = this.state;
		let { SAVED_SEARCH_COLUMN, SAVED_SEARCH_DIRECTION } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClear', item);
		if (e)
		{
			e.preventDefault();
		}
		try
		{
			let arrFields = [];
			if ( AutoSaveSearch )
			{
				let objSavedSearch: any = new Object();
				objSavedSearch.SavedSearch                    = new Object();
				objSavedSearch.SavedSearch.SortColumn         = new Object();
				objSavedSearch.SavedSearch.SortColumn.Value   = 'NAME';
				objSavedSearch.SavedSearch.SortOrder          = new Object();
				objSavedSearch.SavedSearch.SortOrder.Value    = 'asc';
				objSavedSearch.SavedSearch.SearchFields       = new Object();
				objSavedSearch.SavedSearch.SearchFields.Field = arrFields;
				// 07/31/2019 Paul.  Pull the default sort from the module. 
				let module:MODULE = SplendidCache.Module(SEARCH_MODULE, this.constructor.name + '._onClear');
				if ( module != null )
				{
					let DEFAULT_SORT = Sql.ToString(module.DEFAULT_SORT);
					if ( !Sql.IsEmptyString(DEFAULT_SORT) )
					{
						let arrDEFAULT_SORT = DEFAULT_SORT.split(' ');
						if ( arrDEFAULT_SORT.length > 1 )
						{
							objSavedSearch.SavedSearch.SortColumn.Value   = arrDEFAULT_SORT[0];
							objSavedSearch.SavedSearch.SortOrder.Value    = arrDEFAULT_SORT[1];
						}
					}
				}
				// 11/11/2020 Paul.  We need to save the new sort in order for it to get sent to the ListView. 
				SAVED_SEARCH_COLUMN    = objSavedSearch.SavedSearch.SortColumn.Value;
				SAVED_SEARCH_DIRECTION = objSavedSearch.SavedSearch.SortOrder.Value ;

				// https://www.npmjs.com/package/fast-xml-parser
				let options: any = 
				{
					attributeNamePrefix: '@',
					textNodeName       : 'Value',
					ignoreAttributes   : false,
					ignoreNameSpace    : true,
					parseAttributeValue: true,
					trimValues         : false,
					format             : true,
					// 02/17/2024 Paul.  parser v4 requires suppressBooleanAttributes, otherwise Visible does not include ="true"
					allowBooleanAttributes: true,
					suppressBooleanAttributes: false,
				};
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				const builder = new XMLBuilder(options);
				let sXML: string = '<?xml version="1.0" encoding="UTF-8"?>' + builder.build(objSavedSearch);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClear', sXML);

				await UpdateSavedSearch(null, SEARCH_MODULE, sXML, null, null);
				// 05/15/2019 Paul.  Update cache afterward in case there is an error. 
				SplendidCache.UpdateDefaultSavedSearch(SEARCH_MODULE, sXML, null);
				//this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
			}
			// 07/18/2019 Paul.  Instead of reset, just clear the fields and re-submit the search. 
			if ( this.editView.current != null )
			{
				this.editView.current.clear();
			}
			// 08/10/2020 Paul.  Clear the search list. 
			this.setState(
			{
				item: {}, 
				SAVED_SEARCH_ID: ''   ,
				SAVED_SEARCH_COLUMN   ,
				SAVED_SEARCH_DIRECTION,
			}, async () =>
			{
				await this._onSubmit(null);
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onClear', error);
			this.setState({ error });
		}
	}

	private editViewCallback = (key, newValue) =>
	{
		const { onChange } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.editViewCallback ' + key, newValue);
		let item = this.state.item;
		item[key] = newValue;
		try
		{
			if ( this._isMounted )
			{
				this.setState({ item });
			}
			// 06/26/2021 Paol.  Provide a way to track search changes. 
			if ( onChange )
			{
				onChange(key, newValue, null, null);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.editViewCallback', error);
			this.setState({ error });
		}
	}

	private _onLayoutLoaded = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLayoutLoaded', this.props.onLayoutLoaded, this.state.item);
		if ( this.props.onLayoutLoaded )
		{
			this.props.onLayoutLoaded();
		}
		//this.SubmitSearch();
	}

	private _onSelectChange = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { SEARCH_MODULE, savedSearchCounter } = this.state;
		let value = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectChange', value);

		let rowDefaultSearch       : any    = {};
		let gSAVED_SEARCH_ID       : string = value;
		let sSAVED_SEARCH_NAME     : string = '';
		let sSAVED_SEARCH_COLUMN   : string = 'NAME';
		let sSAVED_SEARCH_DIRECTION: string = 'asc';
		let search                 : any    = null;
		if ( !Sql.IsEmptyString(gSAVED_SEARCH_ID) )
		{
			search = SplendidCache.GetSavedSearch(SEARCH_MODULE, gSAVED_SEARCH_ID);
		}
		if ( search != null && !Sql.IsEmptyString(search.CONTENTS) && StartsWith(search.CONTENTS, '<?xml') )
		{
			sSAVED_SEARCH_NAME = search.NAME;
			try
			{
				// https://www.npmjs.com/package/fast-xml-parser
				let options: any = 
				{
					attributeNamePrefix: '',
					// 02/18/2024 Paul.  parser v4 does not have an issue with node name as there is no value tag. 
					//  <SearchFields>
					//    <Field Name="CATEGORY_ID" Type="ListBox"></Field>
					//    <Field Name="SUBCATEGORY_ID" Type="ListBox"></Field>
					//    <Field Name="EXP_DATE" Type="DateRange">
					//      <Before>02/25/2024</Before>
					//      <After>02/18/2024</After>
					//    </Field>
					//  </SearchFields>
					textNodeName       : 'Value',
					ignoreAttributes   : false,
					ignoreNameSpace    : true,
					parseAttributeValue: true,
					trimValues         : false,
				};
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				const parser = new XMLParser(options);
				let xml = parser.parse(search.CONTENTS);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', xml);
				if ( xml.SavedSearch != null && xml.SavedSearch.SearchFields !== undefined && xml.SavedSearch.SearchFields != null )
				{
					if ( xml.SavedSearch.SortOrder )
					{
						sSAVED_SEARCH_DIRECTION = xml.SavedSearch.SortOrder;
					}
					if ( xml.SavedSearch.SortColumn )
					{
						sSAVED_SEARCH_COLUMN = xml.SavedSearch.SortColumn;
					}
					rowDefaultSearch = {};
					let xSearchFields = xml.SavedSearch.SearchFields;
					if ( xSearchFields.Field !== undefined && xSearchFields.Field != null )
					{
						let xFields: any = xSearchFields.Field;
						if ( Array.isArray(xFields) )
						{
							for ( let i = 0; i < xFields.length; i++ )
							{
								let xField = xFields[i];
								rowDefaultSearch[xField.Name] = xField.Value;
								// 11/25/2020 Paul.  DateRange is an exception in that it does not have a Value field. 
								if ( xField.Type == 'DateRange' && xField.Value === undefined )
								{
									rowDefaultSearch[xField.Name] = new Object();
									rowDefaultSearch[xField.Name].Before = xField.Before;
									rowDefaultSearch[xField.Name].After  = xField.After ;
								}
							}
						}
						else if ( xFields.Name !== undefined )
						{
							let xField = xFields[0];
							rowDefaultSearch[xField.Name] = xField.Value;
							// 11/25/2020 Paul.  DateRange is an exception in that it does not have a Value field. 
							if ( xField.Type == 'DateRange' && xField.Value === undefined )
							{
								rowDefaultSearch[xField.Name] = new Object();
								rowDefaultSearch[xField.Name].Before = xField.Before;
								rowDefaultSearch[xField.Name].After  = xField.After ;
							}
						}
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor rowDefaultSearch', rowDefaultSearch);
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
			}
		}

		// 05/14/2019 Paul.  Clear will reset and will use the last saved ID, so we need to clear the default search as well. 
		if ( Sql.IsEmptyString(value) )
		{
			this._onClear(null);
		}
		else if ( this._isMounted )
		{
			// 05/15/2019 Paul.  The savedSearchCounter will be incremented anytime the list changes so that an error will not stop functionality. 
			this.setState({
				item                  : rowDefaultSearch,
				SAVED_SEARCH_ID       : gSAVED_SEARCH_ID,
				SAVED_SEARCH_NAME     : sSAVED_SEARCH_NAME,
				SAVED_SEARCH_NEW_NAME : '',
				SAVED_SEARCH_COLUMN   : sSAVED_SEARCH_COLUMN,
				SAVED_SEARCH_DIRECTION: sSAVED_SEARCH_DIRECTION,
				savedSearchCounter    : savedSearchCounter+1,
				error                 : null
			}, () =>
			{
				this._onSubmit(null);
			});
		}
	}

	private _onNameChange = (e) =>
	{
		let value = e.target.value;
		if ( this._isMounted )
		{
			this.setState({ SAVED_SEARCH_NEW_NAME: value, error: null });
		}
	}

	private _onSave = async (e) =>
	{
		const { EDIT_NAME, AutoSaveSearch, IsPopupSearch, ShowDuplicateFilter } = this.props;
		const { SEARCH_MODULE, SAVED_SEARCH_ID, SAVED_SEARCH_NAME, SAVED_SEARCH_NEW_NAME, SAVED_SEARCH_COLUMN, SAVED_SEARCH_DIRECTION, DUPLICATE_FILTER, savedSearchCounter } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', item);
		if (e)
		{
			e.preventDefault();
		}
		try
		{
			// 11/25/2020 Paul.  Copy search fields so that we can save date as text. 
			let arrSavedSearchFields = Sql.DeepCopy(this.SubmitSearch());
			if ( arrSavedSearchFields )
			{
				for ( let i: number = 0; i < arrSavedSearchFields.length; i++ )
				{
					let search: any = arrSavedSearchFields[i];
					if ( search['@Type'] == 'DatePicker' )
					{
						if ( typeof(search.value) == 'object' )
						{
							search.value = formatDate(search.value, Security.USER_DATE_FORMAT());
						}
					}
					else if ( search['@Type'] == 'DateTimePicker' || search['@Type'] == 'DateTimeEdit' || search['@Type'] == 'DateTimeNewRecord' )
					{
						if ( typeof(search.value) == 'object' )
						{
							search.value = formatDate(search.value, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
						}
					}
					else if ( search['@Type'] == 'DateRange' && search.Value )
					{
						// 11/25/2020 Paul.  When saving DateRange, before and after are not under the Value field. 
						if ( search.Value.before )
						{
							search.Before = formatDate(search.Value.before, Security.USER_DATE_FORMAT());
						}
						if ( search.Value.after )
						{
							search.After = formatDate(search.Value.after, Security.USER_DATE_FORMAT());
						}
						delete search.Value;
					}
				}
			}
			if ( AutoSaveSearch && !IsPopupSearch )
			{
				let objSavedSearch: any                       = new Object();
				objSavedSearch.SavedSearch                    = new Object();
				objSavedSearch.SavedSearch.SortColumn         = new Object();
				objSavedSearch.SavedSearch.SortColumn.Value   = SAVED_SEARCH_COLUMN;
				objSavedSearch.SavedSearch.SortOrder          = new Object();
				objSavedSearch.SavedSearch.SortOrder.Value    = SAVED_SEARCH_DIRECTION;
				objSavedSearch.SavedSearch.SearchFields       = new Object();
				objSavedSearch.SavedSearch.SearchFields.Field = arrSavedSearchFields;
				if ( ShowDuplicateFilter )
				{
					objSavedSearch.SavedSearch.DuplicateFields = new Object();
					
					let objField: any = new Object();
					objSavedSearch.SavedSearch.DuplicateFields.Field = objField;
					objField['@Name'] = 'lstDuplicateColumns';
					objField['@Type'] = 'ListBox';
					objField.Value = DUPLICATE_FILTER;
				}
				// https://www.npmjs.com/package/fast-xml-parser
				let options: any = 
				{
					attributeNamePrefix: '@',
					textNodeName       : 'Value',
					ignoreAttributes   : false,
					ignoreNameSpace    : true,
					parseAttributeValue: true,
					trimValues         : false,
					format             : true,
					// 02/17/2024 Paul.  parser v4 requires suppressBooleanAttributes, otherwise Visible does not include ="true"
					allowBooleanAttributes: true,
					suppressBooleanAttributes: false,
				};
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				const builder = new XMLBuilder(options);
				let sXML: string = '<?xml version="1.0" encoding="UTF-8"?>' + builder.build(objSavedSearch);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', sXML);

				let gID = await UpdateSavedSearch(null, SEARCH_MODULE, sXML, SAVED_SEARCH_NEW_NAME, null);
				let search: any = {};
				search.ID                = gID;
				// 09/25/2020 Paul.  Should be CONTENTS, not CONTENT. 
				search.CONTENTS          = sXML;
				search.NAME              = SAVED_SEARCH_NEW_NAME;
				search.DEFAULT_SEARCH_ID = null;
				SplendidCache.AddSavedSearch(SEARCH_MODULE, gID, search);

				let lstOptions = [];
				let opt3 = { key: '', text: L10n.Term('.LBL_NONE') };
				lstOptions.push(opt3);
				let lstModuleSearches = SplendidCache.SavedSearches(SEARCH_MODULE);
				if ( lstModuleSearches != null )
				{
					for ( let i = 0; i < lstModuleSearches.length; i++ )
					{
						let objSearch = lstModuleSearches[i];
						if ( !Sql.IsEmptyString(objSearch.NAME) )
						{
							let opt = { key: objSearch.ID, text: objSearch.NAME};
							lstOptions.push(opt);
						}
					}
				}
				// 09/25/2020 Paul.  Should be CONTENTS, not CONTENT. 
				SplendidCache.UpdateDefaultSavedSearch(SEARCH_MODULE, search.CONTENTS, search.ID);
				if ( this._isMounted )
				{
					// 05/15/2019 Paul.  The savedSearchCounter will be incremented anytime the list changes so that an error will not stop functionality. 
					this.setState(
					{
						SAVED_SEARCH_ID      : search.id,
						SAVED_SEARCH_NAME    : search.NAME,
						SAVED_SEARCH_NEW_NAME: '',
						SAVED_SEARCH_LIST    : lstOptions,
						savedSearchCounter   : savedSearchCounter+1,
						error                : null,
					}, () =>
					{
						this._onSubmit(null);
					});
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', error);
			this.setState({ error });
		}
	}

	private _onUpdate = async (e) =>
	{
		const { EDIT_NAME, AutoSaveSearch, IsPopupSearch, ShowDuplicateFilter } = this.props;
		const { SEARCH_MODULE, SAVED_SEARCH_ID, SAVED_SEARCH_NAME, SAVED_SEARCH_NEW_NAME, SAVED_SEARCH_COLUMN, SAVED_SEARCH_DIRECTION, DUPLICATE_FILTER, savedSearchCounter } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', item);
		if (e)
		{
			e.preventDefault();
		}
		try
		{
			// 11/25/2020 Paul.  Copy search fields so that we can save date as text. 
			let arrSavedSearchFields = Sql.DeepCopy(this.SubmitSearch());
			if ( arrSavedSearchFields )
			{
				for ( let i: number = 0; i < arrSavedSearchFields.length; i++ )
				{
					let search: any = arrSavedSearchFields[i];
					if ( search['@Type'] == 'DatePicker' )
					{
						if ( typeof(search.value) == 'object' )
						{
							search.value = formatDate(search.value, Security.USER_DATE_FORMAT());
						}
					}
					else if ( search['@Type'] == 'DateTimePicker' || search['@Type'] == 'DateTimeEdit' || search['@Type'] == 'DateTimeNewRecord' )
					{
						if ( typeof(search.value) == 'object' )
						{
							search.value = formatDate(search.value, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
						}
					}
					else if ( search['@Type'] == 'DateRange' && search.Value )
					{
						// 11/25/2020 Paul.  When saving DateRange, before and after are not under the Value field. 
						if ( search.Value.before )
						{
							search.Before = formatDate(search.Value.before, Security.USER_DATE_FORMAT());
						}
						if ( search.Value.after )
						{
							search.After = formatDate(search.Value.after, Security.USER_DATE_FORMAT());
						}
						delete search.Value;
					}
				}
			}
			if ( AutoSaveSearch && !IsPopupSearch )
			{
				let objSavedSearch: any                       = new Object();
				objSavedSearch.SavedSearch                    = new Object();
				objSavedSearch.SavedSearch.SortColumn         = new Object();
				objSavedSearch.SavedSearch.SortColumn.Value   = SAVED_SEARCH_COLUMN;
				objSavedSearch.SavedSearch.SortOrder          = new Object();
				objSavedSearch.SavedSearch.SortOrder.Value    = SAVED_SEARCH_DIRECTION;
				objSavedSearch.SavedSearch.SearchFields       = new Object();
				objSavedSearch.SavedSearch.SearchFields.Field = arrSavedSearchFields;
				if ( ShowDuplicateFilter )
				{
					objSavedSearch.SavedSearch.DuplicateFields = new Object();
					
					let objField: any = new Object();
					objSavedSearch.SavedSearch.DuplicateFields.Field = objField;
					objField['@Name'] = 'lstDuplicateColumns';
					objField['@Type'] = 'ListBox';
					objField.Value = DUPLICATE_FILTER;
				}
				// https://www.npmjs.com/package/fast-xml-parser
				let options: any = 
				{
					attributeNamePrefix: '@',
					textNodeName       : 'Value',
					ignoreAttributes   : false,
					ignoreNameSpace    : true,
					parseAttributeValue: true,
					trimValues         : false,
					format             : true,
					// 02/17/2024 Paul.  parser v4 requires suppressBooleanAttributes, otherwise Visible does not include ="true"
					allowBooleanAttributes: true,
					suppressBooleanAttributes: false,
				};
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				const builder = new XMLBuilder(options);
				let sXML: string = '<?xml version="1.0" encoding="UTF-8"?>' + builder.build(objSavedSearch);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', sXML);

				// 05/08/2019 Paul.  Before resetting, update the cached version. 
				let gID = null;
				let search = null;
				let sSAVED_SEARCH_NAME = SAVED_SEARCH_NAME;
				if ( !Sql.IsEmptyString(SAVED_SEARCH_NEW_NAME) )
					sSAVED_SEARCH_NAME = SAVED_SEARCH_NEW_NAME;
				if ( !Sql.IsEmptyGuid(SAVED_SEARCH_ID) )
				{
					search = SplendidCache.GetSavedSearch(SEARCH_MODULE, SAVED_SEARCH_ID);
					if ( search != null )
					{
						gID = search.ID;
						search.NAME     = sSAVED_SEARCH_NAME;
						search.CONTENTS = sXML;
					}
				}
				await UpdateSavedSearch(gID, SEARCH_MODULE, sXML, sSAVED_SEARCH_NAME, null);
				SplendidCache.UpdateDefaultSavedSearch(SEARCH_MODULE, sXML, gID);

				let lstOptions = [];
				let opt3 = { key: '', text: L10n.Term('.LBL_NONE') };
				lstOptions.push(opt3);
				let lstModuleSearches = SplendidCache.SavedSearches(SEARCH_MODULE);
				if ( lstModuleSearches != null )
				{
					for ( let i = 0; i < lstModuleSearches.length; i++ )
					{
						let objSearch = lstModuleSearches[i];
						if ( !Sql.IsEmptyString(objSearch.NAME) )
						{
							let opt = { key: objSearch.ID, text: objSearch.NAME};
							lstOptions.push(opt);
						}
					}
				}
				// 05/15/2019 Paul.  The savedSearchCounter will be incremented anytime the list changes so that an error will not stop functionality. 
				if ( this._isMounted )
				{
					this.setState({ 
						SAVED_SEARCH_LIST: lstOptions,
						savedSearchCounter: savedSearchCounter+1, 
						error: null
					});
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', error);
			this.setState({ error });
		}
	}

	private _onDelete = async (e) =>
	{
		const { SEARCH_MODULE, SAVED_SEARCH_ID, savedSearchCounter } = this.state;
		try
		{
			await DeleteSavedSearch(SAVED_SEARCH_ID, SEARCH_MODULE);
			SplendidCache.RemoveSavedSearch(SEARCH_MODULE, SAVED_SEARCH_ID); 
			// 08/06/2020 Paul.  Update saved list. 
			let lstOptions = [];
			let opt3 = { key: '', text: L10n.Term('.LBL_NONE') };
			lstOptions.push(opt3);
			let lstModuleSearches = SplendidCache.SavedSearches(SEARCH_MODULE);
			if ( lstModuleSearches != null )
			{
				for ( let i = 0; i < lstModuleSearches.length; i++ )
				{
					let objSearch = lstModuleSearches[i];
					if ( !Sql.IsEmptyString(objSearch.NAME) )
					{
						let opt = { key: objSearch.ID, text: objSearch.NAME};
						lstOptions.push(opt);
					}
				}
			}
			// 08/06/2019 Paul.  The savedSearchCounter will be incremented anytime the list changes so that an error will not stop functionality. 
			if ( this._isMounted )
			{
				// 09/26/2020 Paul.  Clear search name after delete. 
				this.setState(
				{
					SAVED_SEARCH_ID   : null,
					SAVED_SEARCH_NAME : '',
					SAVED_SEARCH_LIST : lstOptions,
					savedSearchCounter: savedSearchCounter+1, 
					error: null
				});
			}
			this._onClear(null);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onDelete', error);
			this.setState({ error });
		}
	}

	private _onShowPanel = async() =>
	{
		const { SAVED_PANEL } = this.state;
		if ( this._isMounted )
		{
			this.setState({ SAVED_PANEL: !SAVED_PANEL, error: null });
		}
	}

	private _onDirectionChange = (value) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDirectionChange', value);
		if ( this._isMounted )
		{
			this.setState({ SAVED_SEARCH_DIRECTION: value, error: null });
		}
	}

	private _onSearchColumnChange = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		if ( this._isMounted )
		{
			this.setState({ SAVED_SEARCH_COLUMN: event.target.value });
		}
	}

	private _onDuplicateChange = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { SEARCH_MODULE, savedSearchCounter } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDuplicateChange', value);
		let selectedOptions = event.target.selectedOptions;
		let DUPLICATE_FILTER: string[] = [];
		for (let i = 0; i < selectedOptions.length; i++)
		{
			DUPLICATE_FILTER.push(selectedOptions[i].value);
		}
		if ( this._isMounted )
		{
			this.setState({
				DUPLICATE_FILTER,
				error: null
			});
		}
	}

	public render()
	{
		// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
		// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
		const { EDIT_NAME, CONTROL_VIEW_NAME, ShowSearchViews, IsPopupSearch, ShowDuplicateFilter, fromLayoutName, disableClear } = this.props;
		const { item, SAVED_SEARCH_ID, SAVED_SEARCH_LIST, SAVED_SEARCH_NAME, SAVED_SEARCH_NEW_NAME, SAVED_SEARCH_COLUMN, SAVED_SEARCH_DIRECTION, SAVED_PANEL, MODULE_COLUMNS_LIST, DUPLICATE_FILTER, savedSearchCounter, error, sDebugSQL, sOldSQL } = this.state;
		let sMODULE_NAME: string = !Sql.IsEmptyString(EDIT_NAME) ? EDIT_NAME.split('.')[0] : '';
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + EDIT_NAME, item);
		// 05/15/2019 Paul.  The savedSearchCounter will be incremented anytime the list changes so that an error will not stop functionality. 
		if ( SplendidCache.IsInitialized && Credentials.bIsAuthenticated )
		{
			let sTheme: string = SplendidCache.UserTheme;
			let sButtonClass: string = (SplendidDynamic.StackedLayout(sTheme) ? 'EditHeaderOtherButton' : 'button');
			// 07/09/2019 Paul.  Use span instead of a tag to prevent navigation. 
			// 07/10/2019 Paul.  Use DynamicEditView so that SearchViews can be customized. 
			// 07/10/2019 Paul.  Cannot use DynamicEditView as it causes any file that includes SearchView, PopupView to fail to load in DynamicLayout, including SplendidDynamic_EditView. 
			// 10/27/2020 Paul.  Must allow wrap, otherwise the separator will not work. 
			// 04/11/2022 Paul.  Change Clear type to button so it can be styled differently. 
			return (
				<div className="tabSearchForm" style={ {width: '100%'} }>
					<div className="tabSearchView" style={ {display: 'flex', flexWrap: 'wrap', width: '100%'} } >
						{ !IsPopupSearch && ShowDuplicateFilter
						? <div>
								<div style={ {fontWeight: 'bold'} }>{ L10n.Term('Import.LBL_IMPORT_STEP_DUPLICATE_FILTER') }</div>
								<select
									key={ 'lstDuplicateColumns' }
									multiple={ true }
									size={ 10 }
									onChange={ this._onDuplicateChange }
									value={ DUPLICATE_FILTER }
									style={ {display: 'inline', width: 'auto', marginLeft: '.5em', marginRight: '.5em'} }
									>
									{
										MODULE_COLUMNS_LIST.map((item, index) => 
										{
											return (<option key={ 'lstDuplicateColumns_' + EDIT_NAME + '_' + index.toString() } id={ 'lstDuplicateColumns_' + EDIT_NAME + '_' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
										})
									}
								</select>
						</div>
						: null
						}
						<DynamicEditViewWithRouter
							key={ EDIT_NAME + '_' + Sql.ToString(SAVED_SEARCH_ID) + '_' + savedSearchCounter.toString()}
							MODULE_NAME={ sMODULE_NAME }
							LAYOUT_NAME={ EDIT_NAME }
							CONTROL_VIEW_NAME={ CONTROL_VIEW_NAME }
							rowDefaultSearch={ item }
							callback={ this.editViewCallback }
							onLayoutLoaded={ this._onLayoutLoaded }
							onSubmit={ this._onSubmit }
							isSearchView={ true }
							fromLayoutName={ fromLayoutName }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							withRef={ this.editView }
						/>
					</div>
					<div>
						<div className="tabSavedSearch" style={ {display: 'flex', flexWrap: 'wrap', width: '100%'} } >
							<input
								type='submit'
								key={ 'btnSubmit_' + EDIT_NAME }
								onClick={ this._onSubmit }
								className={ sButtonClass }
								style={ {marginBottom: '.2em'} }
								value={ L10n.Term('.LBL_SEARCH_BUTTON_LABEL') }
							/>
							{ !disableClear
							? <input
								type='button'
								key={ 'btnClear_'  + EDIT_NAME }
								onClick={ this._onClear  }
								className={ sButtonClass }
								style={ {marginBottom: '.2em', marginLeft: '.5em'} }
								value={ L10n.Term('.LBL_CLEAR_BUTTON_LABEL') }
							/>
							: null
							}
							{ ShowSearchViews && !IsPopupSearch
							? <span>
								<span className="white-space">&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;</span>
								<label key={ 'lstSavedSearches_' + EDIT_NAME + '_Label' } style={ {fontWeight: 'bold'} }>{ L10n.Term(".LBL_SAVED_SEARCH_SHORTCUT") }</label>
								<select
									key={ 'lstSavedSearches_' + EDIT_NAME }
									onChange={ this._onSelectChange }
									value={ SAVED_SEARCH_ID }
									style={ {display: 'inline', width: 'auto', marginLeft: '.5em', marginRight: '.5em'} }
									>
									{
										SAVED_SEARCH_LIST.map((item, index) => 
										{
											return (<option key={ 'optSavedSearches_' + EDIT_NAME + '_' + item.key } id={ 'optSavedSearches_' + EDIT_NAME + '_' + item.key } value={ item.key }>{ item.text }</option>);
										})
									}
								</select>
								<span key={ 'lnkSavedSearches_' + EDIT_NAME } onClick={ this._onShowPanel } style={ {cursor: 'pointer'} }>
									<FontAwesomeIcon icon={ (SAVED_PANEL ? faAngleDoubleUp : faAngleDoubleDown) } style={ {marginRight: '.5em'} } />
									{ L10n.Term('.LNK_SAVED_VIEWS') }
								</span>
							</span>
							: null
							}
							<div style={ {flex: '1 0 30%', marginLeft: '1em'} }>
								<ErrorComponent error={error} />
							</div>
						</div>
						{ ShowSearchViews && !IsPopupSearch && SAVED_PANEL
						? <div className="tabSavedSearch" style={ {display: 'flex', flexWrap: 'wrap', width: '100%'} } >
							<div style={ {display: 'flex', flexWrap: 'wrap', flex: '1 0 50%', paddingTop: '4px'} } >
								<label key={ 'lstColumns_' + EDIT_NAME + '_Label' } className="control-label" style={ {width: '33%'} }>{ L10n.Term('SavedSearch.LBL_ORDER_BY_COLUMNS') }</label>
								<span>
									<select
										key={ 'lstColumns_' + EDIT_NAME }
										onChange={ this._onSearchColumnChange }
										value={ SAVED_SEARCH_COLUMN }
										style={ {width: 'auto'} }
										>
										{
											MODULE_COLUMNS_LIST.map((item, index) => 
											{
												return (<option key={ 'lstSearchColumns_' + EDIT_NAME + '_' + index.toString() } id={ 'lstSearchColumns_' + EDIT_NAME + '_' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
											})
										}
									</select>
								</span>
							</div>
							<div style={ {display: 'flex', flexWrap: 'wrap', flex: '1 0 50%'} } >
								<label key={ 'radSavedSearchDirection' + EDIT_NAME + '_Label' } className="control-label" style={ {width: '33%'} }>{ L10n.Term('SavedSearch.LBL_DIRECTION') }</label>
								<div style={ {display: 'block', width: '66%', marginBottom: '.2em'} }>
									<div>
										<input key={ 'radSavedSearchDirection' + EDIT_NAME + '_desc' } id={ 'radSavedSearchDirection' + EDIT_NAME + '_desc' } type="radio" style={ {verticalAlign: 'top'} } className="radio" value="asc" checked={ SAVED_SEARCH_DIRECTION == 'desc' } onChange={ () => this._onDirectionChange('desc') } />
										&nbsp;<label key={ 'radSavedSearchDirection' + EDIT_NAME + '_desc_Label' } htmlFor={'radSavedSearchDirection' + EDIT_NAME + '_desc' } style={ {verticalAlign: 'top'} }>{ L10n.Term("SavedSearch.LBL_DESCENDING") }</label>
									</div>
									<div>
										<input key={ 'radSavedSearchDirection' + EDIT_NAME + '_asc' } id={ 'radSavedSearchDirection' + EDIT_NAME + '_asc' } type="radio" style={ {verticalAlign: 'top'} } className="radio" value="asc" checked={ SAVED_SEARCH_DIRECTION == 'asc' } onChange={ () => this._onDirectionChange('asc') } />
										&nbsp;<label key={ 'radSavedSearchDirection' + EDIT_NAME + '_asc_Label' } htmlFor={'radSavedSearchDirection' + EDIT_NAME + '_asc' } style={ {verticalAlign: 'top'} }>{ L10n.Term("SavedSearch.LBL_ASCENDING") }</label>
									</div>
								</div>
							</div>
							<div style={ {display: 'flex', flexWrap: 'wrap', flex: '1 0 50%'} } >
								<label key={ 'txtSavedSearchName_' + EDIT_NAME + '_Label' } className="control-label" style={ {width: '33%'} }>{ L10n.Term('SavedSearch.LBL_SAVE_SEARCH_AS') }</label>
								<input
									id={ 'txtSavedSearchName_' + EDIT_NAME }
									key={ 'txtSavedSearchName_' + EDIT_NAME }
									value={ SAVED_SEARCH_NEW_NAME }
									type="text"
									autoComplete='off'
									style={ {width: '50%'} }
									onChange={ this._onNameChange }
								/>
								<input
									type='submit'
									key={ 'btnSavedSearchNew_' + EDIT_NAME }
									onClick={ this._onSave }
									className={ sButtonClass }
									style={ {marginBottom: '.2em', marginLeft: '.5em'} }
									disabled={ Sql.IsEmptyString(SAVED_SEARCH_NEW_NAME) }
									value={ L10n.Term('.LBL_SAVE_BUTTON_LABEL') }
								/>
							</div>
							<div style={ {display: 'flex', flexWrap: 'nowrap', flex: '1 0 50%'} } >
								<label key={ 'btnSearchUpdate_' + EDIT_NAME + '_Label' } className="control-label" style={ {width: '33%'} }>{ L10n.Term('SavedSearch.LBL_MODIFY_CURRENT_SEARCH') }</label>
								<span style={ {width: '66%'} }>
									<input
										type='submit'
										key={ 'btnSearchUpdate_' + EDIT_NAME }
										onClick={ this._onUpdate }
										className={ sButtonClass }
										style={ {marginBottom: '.2em'} }
										disabled={ Sql.IsEmptyGuid(SAVED_SEARCH_ID) }
										value={ L10n.Term('.LBL_UPDATE_BUTTON_LABEL') }
									/>
									<input
										type='submit'
										key={ 'btnSearchDelete_' + EDIT_NAME }
										onClick={ this._onDelete }
										className={ sButtonClass }
										style={ {marginBottom: '.2em', marginLeft: '.5em', marginRight: '.5em'} }
										disabled={ Sql.IsEmptyGuid(SAVED_SEARCH_ID) }
										value={ L10n.Term('.LBL_DELETE_BUTTON_LABEL') }
									/>
									<label key={ 'lblSearchName_'   + EDIT_NAME }>
										{ !Sql.IsEmptyString(SAVED_SEARCH_NAME) ? '\"' + SAVED_SEARCH_NAME + '\"' : null }
									</label>
								</span>
							</div>
						</div>
						: null
						}
					</div>
				</div>
			);
		}
		else
		{
			return null;
		}
	}
}

// 07/13/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 
