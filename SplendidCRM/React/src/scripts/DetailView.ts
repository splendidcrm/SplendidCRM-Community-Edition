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
// 2. Store and Types. 
import DETAILVIEWS_FIELD                            from '../types/DETAILVIEWS_FIELD';
import EDITVIEWS_FIELD                              from '../types/EDITVIEWS_FIELD'  ;
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'            ;
import L10n                                         from '../scripts/L10n'           ;
import Credentials                                  from '../scripts/Credentials'    ;
import SplendidCache                                from '../scripts/SplendidCache'  ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest';

export async function DetailView_LoadItem(MODULE_NAME: string, ID: string, ADMIN_MODE: boolean, archiveView: boolean)
{
	let admin: string = '';
	if ( ADMIN_MODE )
		admin = 'Administration/';
	let res = await CreateSplendidRequest(admin + 'Rest.svc/GetModuleItem?ModuleName=' + MODULE_NAME + '&ID=' + ID + '&$accessMode=view' + (archiveView ? '&$archiveView=1' : ''), 'GET');
	let json = await GetSplendidResult(res);
	// 11/19/2019 Paul.  Change to allow return of SQL. 
	json.d.__sql = json.__sql;
	return json.d;
}

// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
export function DetailView_LoadLayout(DETAIL_NAME: string, ignoreMissing?: boolean)
{
	let layout: any[] = null;
	if ( Sql.IsEmptyString(Credentials.sPRIMARY_ROLE_NAME) )
	{
		layout = SplendidCache.DetailViewFields(DETAIL_NAME, ignoreMissing);
	}
	else
	{
		// 07/07/2020 Paul.  Ignore missing when looking for primary role. 
		layout = SplendidCache.DetailViewFields(DETAIL_NAME + '.' + Credentials.sPRIMARY_ROLE_NAME, true);
		if ( layout === undefined || layout == null || layout.length == 0 )
		{
			layout = SplendidCache.DetailViewFields(DETAIL_NAME, ignoreMissing);
		}
	}
	// 05/26/2019 Paul.  We will no longer lookup missing layout values if not in the cache. 
	if ( layout == null )
	{
		// 02/02/2020 Paul.  Ignore missing inline as there are too many. 
		if ( !ignoreMissing )
		{
			// 01/08/2021 Paul.  No lnoger needed. 
			//console.warn((new Date()).toISOString() + ' ' + DETAIL_NAME + ' not found in DetailViews');
		}
	}
	else
	{
		// 11/02/2019 Paul.  Return a clone of the layout so that we can dynamically modify the layout. 
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		// 04/16/2022 Paul.  We need to initialize tabs for every layout. 
		let bPacificTheme: boolean = (Credentials.sUSER_THEME == 'Pacific');
		let bTabsEnabled : boolean = false;
		let newArray: any[] = [];
		layout.forEach((lay) =>
		{
			newArray.push(Object.assign({hidden: false}, lay));
			if ( bPacificTheme && !bTabsEnabled )
			{
				let FIELD_TYPE : string = lay.FIELD_TYPE;
				if ( FIELD_TYPE == 'Header' || FIELD_TYPE == 'Separator' || FIELD_TYPE == 'Line' )
				{
					let DATA_FORMAT: string = lay.DATA_FORMAT;
					if ( (DATA_FORMAT == 'tab' || DATA_FORMAT == 'tab-only' ) )
					{
						bTabsEnabled = true;
					}
				}
			}
		});
		layout = newArray;
		// 04/16/2022 Paul.  The first tab is always active by default. 
		if ( bTabsEnabled )
		{
			DetailView_ActivateTab(layout, 0);
		}
	}
	return layout;
}

export async function DetailView_LoadAudit(MODULE_NAME: string, ID: string)
{
	let res = await CreateSplendidRequest('Rest.svc/GetModuleAudit?ModuleName=' + MODULE_NAME + '&ID=' + ID, 'GET');
	let json = await GetSplendidResult(res);
	json.d.__sql = json.__sql;
	return json.d;
}

export async function DetailView_GetByAudit(MODULE_NAME: string, AUDIT_ID: string)
{
	let res = await CreateSplendidRequest('Rest.svc/GetModuleItemByAudit?ModuleName=' + MODULE_NAME + '&AUDIT_ID=' + AUDIT_ID, 'GET');
	let json = await GetSplendidResult(res);
	return json.d;
}

export async function DetailView_LoadPersonalInfo(MODULE_NAME: string, ID: string)
{
	let res = await CreateSplendidRequest('Rest.svc/GetModulePersonal?ModuleName=' + MODULE_NAME + '&ID=' + ID, 'GET');
	let json = await GetSplendidResult(res);
	return json.d;
}

export function DetailView_RemoveField(layout: DETAILVIEWS_FIELD[], DATA_FIELD: string)
{
	// 02/08/2021 Paul.  Make sure layout is not null. 
	if ( layout && layout.length > 0 )
	{
		for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
		{
			let lay = layout[nLayoutIndex];
			if ( DATA_FIELD == lay.DATA_FIELD )
			{
				layout.splice(nLayoutIndex, 1);
				break;
			}
		}
	}
}

export function DetailView_HideField(layout: DETAILVIEWS_FIELD[], DATA_FIELD: string, hidden: boolean)
{
	// 02/08/2021 Paul.  Make sure layout is not null. 
	if ( layout && layout.length > 0 )
	{
		for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
		{
			let lay = layout[nLayoutIndex];
			if ( DATA_FIELD == lay.DATA_FIELD )
			{
				lay.hidden = hidden;
				break;
			}
		}
	}
}

export function DetailView_FindField(layout: DETAILVIEWS_FIELD[], DATA_FIELD: string)
{
	// 02/08/2021 Paul.  Make sure layout is not null. 
	if ( layout && layout.length > 0 )
	{
		for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
		{
			let lay = layout[nLayoutIndex];
			if ( DATA_FIELD == lay.DATA_FIELD )
			{
				return lay;
			}
		}
	}
	return null;
}

export function DetailView_GetTabList(layout: any[])
{
	let arrTabs    : any[] = [];
	if ( layout && layout.length > 0 )
	{
		let VIEW_NAME: string = '';
		for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
		{
			let lay = layout[nLayoutIndex];
			let FIELD_TYPE : string = lay.FIELD_TYPE;
			// 04/16/2022 Paul.  Only a header can start a tab. 
			if ( FIELD_TYPE == 'Header' )
			{
				let DATA_FORMAT: string = lay.DATA_FORMAT;
				// 04/14/2022 Paul.  tab is for Pacific theme.  tab-only means header is not displayed unless tabs are displayed on Pacfic theme. 
				if ( (DATA_FORMAT == 'tab' || DATA_FORMAT == 'tab-only' ) )
				{
					let DATA_LABEL : string = lay.DATA_LABEL;
					if ( Sql.IsEmptyString(VIEW_NAME) )
					{
						VIEW_NAME = lay.DETAIL_NAME;
					}
					if ( DATA_LABEL != null && DATA_LABEL.indexOf('.') >= 0 )
					{
						DATA_LABEL = L10n.Term(DATA_LABEL);
					}
					arrTabs.push({ nLayoutIndex, DATA_LABEL, VIEW_NAME });
				}
			}
		}
	}
	return arrTabs;
}

export function DetailView_ActivateTab(layout: any[], nActiveTabIndex: number)
{
	if ( layout && layout.length > 0 )
	{
		let bActiveSet: boolean = false;
		for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
		{
			let lay: any = layout[nLayoutIndex];
			let FIELD_TYPE : string = lay.FIELD_TYPE;
			// 04/16/2022 Paul.  Separators usually start a new table or division, so separators after active tab need to be treated as a set. 
			if ( FIELD_TYPE == 'Header' || FIELD_TYPE == 'Separator' || FIELD_TYPE == 'Line' )
			{
				if ( nLayoutIndex == nActiveTabIndex )
				{
					lay.ActiveTab = true;
					bActiveSet = true;
				}
				else if ( FIELD_TYPE == 'Header' )
				{
					let DATA_FORMAT: string = lay.DATA_FORMAT;
					// 04/15/2022 Paul.  Turn off set once new tab reached. 
					if ( (DATA_FORMAT == 'tab' || DATA_FORMAT == 'tab-only' ) )
					{
						bActiveSet = false;
						lay.ActiveTab = false;
					}
					else if ( bActiveSet )
					{
						// 04/15/2022 Paul.  Otherwise, non tab header is part of set. 
						lay.ActiveTab = true;
					}
				}
				else if ( FIELD_TYPE == 'Separator' || FIELD_TYPE == 'Line' )
				{
					// 04/15/2022 Paul.  Separator will be part of active set. 
					lay.ActiveTab = bActiveSet;
				}
				else if ( lay.ActiveTab )
				{
					lay.ActiveTab = false;
				}
				//console.log((new Date()).toISOString() + ' DetailView_ActivateTab: ' + nLayoutIndex.toString() + '. ' + FIELD_TYPE + ' ' + lay.DATA_FORMAT + ' ' + lay.ActiveTab.toString());
			}
		}
	}
}

// 10/08/2022 Paul.  MergeView may need to convert an unmapped field to DetailView
export function ConvertToDetailView(layEditView: EDITVIEWS_FIELD)
{
	let layDetailView: DETAILVIEWS_FIELD =
	{
		ID          : null,
		DELETED     : null,
		DETAIL_NAME : null,
		FIELD_INDEX : null,
		FIELD_TYPE  : null,
		DEFAULT_VIEW: null,
		DATA_LABEL  : null,
		DATA_FIELD  : null,
		DATA_FORMAT : null,
		URL_FIELD   : null,
		URL_FORMAT  : null,
		URL_TARGET  : null,
		LIST_NAME   : null,
		COLSPAN     : null,
		LABEL_WIDTH : null,
		FIELD_WIDTH : null,
		DATA_COLUMNS: null,
		VIEW_NAME   : null,
		MODULE_NAME : null,
		TOOL_TIP    : null,
		MODULE_TYPE : null,
		PARENT_FIELD: null,
		SCRIPT      : null,
		hidden      : null,
	};
	switch ( layEditView.FIELD_TYPE )
	{
		case 'TextBox'            :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'HtmlEditor'         :
			layDetailView.FIELD_TYPE   = 'TextBox';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'Label'              :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'ListBox'            :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.LIST_NAME    = layEditView.LIST_NAME   ;
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'Radio'              :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.LIST_NAME    = layEditView.LIST_NAME   ;
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'CheckBox'           :
			layDetailView.FIELD_TYPE   = 'CheckBox';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = null;
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'CheckBoxList'       :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'ChangeButton'       :
			layDetailView.FIELD_TYPE   = 'HyperLink';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL   ;
			layDetailView.DATA_FIELD   = layEditView.DISPLAY_FIELD;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.URL_FIELD    = layEditView.DATA_FIELD   ;
			layDetailView.URL_FORMAT   = '~/' + layEditView.MODULE_TYPE + '/view.aspx?ID={0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN      ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP     ;
			break;
		case 'ModulePopup'        :
			layDetailView.FIELD_TYPE   = 'HyperLink';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL   ;
			layDetailView.DATA_FIELD   = layEditView.DISPLAY_FIELD;
			layDetailView.DATA_FORMAT  = '{0}';
			// 10/08/2022 Paul.  Only include MODULE_TYPE if we are forced to lookup the name. 
			if ( Sql.IsEmptyString(layEditView.DISPLAY_FIELD) )
				layDetailView.MODULE_TYPE  = layEditView.MODULE_TYPE  ;
			layDetailView.URL_FIELD    = layEditView.DATA_FIELD   ;
			layDetailView.URL_FORMAT   = '~/' + layEditView.MODULE_TYPE + '/view.aspx?ID={0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN      ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP     ;
			//console.log((new Date()).toISOString() + ' ' + 'ConvertToDetailView', layEditView, layDetailView);
			break;
		case 'ModuleAutoComplete' :
			layDetailView.FIELD_TYPE   = 'HyperLink';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL   ;
			layDetailView.DATA_FIELD   = layEditView.DISPLAY_FIELD;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.URL_FIELD    = layEditView.DATA_FIELD   ;
			layDetailView.URL_FORMAT   = '~/' + layEditView.MODULE_TYPE + '/view.aspx?ID={0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN      ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP     ;
			break;
		case 'TeamSelect'         :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		case 'UserSelect'         :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		// 05/12/2016 Paul.  Add Tags module. 
		case 'TagSelect'          :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'DatePicker'         :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'DateTimeEdit'       :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'DateTimeNewRecord'  :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'DateTimePicker'     :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'Image'              :
			layDetailView.FIELD_TYPE   = 'Image';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'Blank'              :
			layDetailView.FIELD_TYPE   = layEditView.FIELD_TYPE  ;
			break;
		case 'Separator'          :
			layDetailView.FIELD_TYPE   = layEditView.FIELD_TYPE  ;
			break;
		case 'Header'             :
			layDetailView.FIELD_TYPE   = layEditView.FIELD_TYPE  ;
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			break;
		case 'ZipCodePopup'       :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'File'               :
			layDetailView.FIELD_TYPE   = 'File';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'RelatedListBox'     :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.LIST_NAME    = layEditView.LIST_NAME   ;
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'RelatedCheckBoxList':
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'RelatedSelect'      :
			layDetailView.FIELD_TYPE   = 'HyperLink';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL   ;
			layDetailView.DATA_FIELD   = layEditView.DISPLAY_FIELD;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.MODULE_TYPE  = layEditView.MODULE_TYPE  ;
			layDetailView.URL_FIELD    = layEditView.DATA_FIELD   ;
			layDetailView.URL_FORMAT   = '~/' + layEditView.MODULE_TYPE + '/view.aspx?ID={0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN      ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP     ;
			break;
		case 'Hidden'             :
			layDetailView.FIELD_TYPE   = layEditView.FIELD_TYPE  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			break;
		case 'DateRange'          :
			layDetailView.FIELD_TYPE   = 'String';
			layDetailView.DATA_LABEL   = layEditView.DATA_LABEL  ;
			layDetailView.DATA_FIELD   = layEditView.DATA_FIELD  ;
			layDetailView.DATA_FORMAT  = '{0}';
			layDetailView.COLSPAN      = layEditView.COLSPAN     ;
			layDetailView.TOOL_TIP     = layEditView.TOOL_TIP    ;
			break;
		case 'Password'           :
			break;
		case 'AddressButtons'     :
			break;
		default:
			// 10/08/2022 Paul.  Return null so that we can detect this situation. 
			layDetailView = null;
			break;
	}
	return layDetailView;
}
