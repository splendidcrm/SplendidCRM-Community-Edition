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
import EDITVIEWS_FIELD                              from '../types/EDITVIEWS_FIELD'  ;
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'            ;
import L10n                                         from '../scripts/L10n'           ;
import Credentials                                  from '../scripts/Credentials'    ;
import SplendidCache                                from '../scripts/SplendidCache'  ;
import { EndsWith }                                 from '../scripts/utility'        ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest';

export async function EditView_LoadItem(sMODULE_NAME, sID, ADMIN_MODE?)
{
	// 10/07/2011 Paul.  We want to allow an empty ID to return a valid empty result. 
	// 10/10/2011 Paul.  Sql object is not available in the background page. 
	if ( sID === undefined || sID == null || sID == '' )
	{
		let d: any = {};
		d.row = {};
		d.row['ID'] = null;
		return d;
	}
	else
	{
		let admin = '';
		if ( ADMIN_MODE )
			admin = 'Administration/';
		let res = await CreateSplendidRequest(admin + 'Rest.svc/GetModuleItem?ModuleName=' + sMODULE_NAME + '&ID=' + sID + '&$accessMode=edit', 'GET');
		let json = await GetSplendidResult(res);
		// 11/19/2019 Paul.  Change to allow return of SQL. 
		json.d.__sql = json.__sql;
		return json.d;
	}
}

// 03/30/2016 Paul.  Convert requires special processing. 
export async function EditView_ConvertItem(sMODULE_NAME, sSOURCE_MODULE_NAME, sSOURCE_ID, ADMIN_MODE?)
{
	if ( sSOURCE_ID === undefined || sSOURCE_ID == null || sSOURCE_ID == '' )
	{
		let d: any = {};
		d.row = {};
		d.row['ID'] = null;
		return d;
	}
	else
	{
		let admin = '';
		if ( ADMIN_MODE )
			admin = 'Administration/';
		let res = await CreateSplendidRequest(admin + 'Rest.svc/ConvertModuleItem?ModuleName=' + sMODULE_NAME + '&SourceModuleName=' + sSOURCE_MODULE_NAME + '&SourceID=' + sSOURCE_ID, 'GET');
		let json = await GetSplendidResult(res);
		// 11/19/2019 Paul.  Change to allow return of SQL. 
		json.d.__sql = json.__sql;
		return json.d;
	}
}

// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
export function EditView_LoadLayout(EDIT_NAME, ignoreMissing?: boolean)
{
	let layout: any[] = null;
	if ( Sql.IsEmptyString(Credentials.sPRIMARY_ROLE_NAME) )
	{
		layout = SplendidCache.EditViewFields(EDIT_NAME, ignoreMissing);
	}
	else
	{
		// 07/07/2020 Paul.  Ignore missing when looking for primary role. 
		layout = SplendidCache.EditViewFields(EDIT_NAME + '.' + Credentials.sPRIMARY_ROLE_NAME, true);
		if ( layout === undefined || layout == null || layout.length == 0 )
		{
			layout = SplendidCache.EditViewFields(EDIT_NAME, ignoreMissing);
		}
	}
	// 05/26/2019 Paul.  We will no longer lookup missing layout values if not in the cache. 
	if ( layout == null )
	{
		// 02/02/2020 Paul.  Ignore missing inline as there are too many. 
		if ( !ignoreMissing )
		{
			// 01/08/2021 Paul.  No lnoger needed. 
			//console.warn((new Date()).toISOString() + ' ' + EDIT_NAME + ' not found in EditViews');
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
			EditView_ActivateTab(layout, 0);
		}
	}
	return layout;
}

// 04/21/2020 Paul.  Shared function to hide fields based on REPEAT_TYPE. 
export function EditView_UpdateREPEAT_TYPE(layout: any[], REPEAT_TYPE: string)
{
	// 02/08/2021 Paul.  Make sure layout is not null. 
	if ( layout && layout.length > 0 )
	{
		for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
		{
			let lay = layout[nLayoutIndex];
			let DATA_FIELD = lay.DATA_FIELD;
			switch ( DATA_FIELD )
			{
				case 'REPEAT_INTERVAL'                :  lay.hidden = Sql.IsEmptyString(REPEAT_TYPE);  break;
				case 'REPEAT_COUNT'                   :  lay.hidden = Sql.IsEmptyString(REPEAT_TYPE);  break;
				case 'REPEAT_UNTIL'                   :  lay.hidden = Sql.IsEmptyString(REPEAT_TYPE);  break;
				case 'Calendar.LBL_REPEAT_OCCURRENCES':  lay.hidden = Sql.IsEmptyString(REPEAT_TYPE);  break;
				case 'REPEAT_DOW'                     :  lay.hidden = REPEAT_TYPE != 'Weekly'       ;  break;
			}
		}
	}
}

export function EditView_RemoveField(layout: EDITVIEWS_FIELD[], DATA_FIELD: string)
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

export function EditView_HideField(layout: EDITVIEWS_FIELD[], DATA_FIELD: string, hidden: boolean)
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

export function EditView_FindField(layout: EDITVIEWS_FIELD[], DATA_FIELD: string)
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

	// 06/27/2020 Paul.  We need to set the default value for requried dropdowns. 
export function EditView_InitItem(layout: EDITVIEWS_FIELD[])
{
	let item: any = {};
	if ( layout )
	{
		for ( let i: number = 0; i < layout.length; i++ )
		{
			let lay: any = layout[i];
			let FIELD_TYPE    : string  = lay.FIELD_TYPE;
			let DATA_FIELD    : string  = lay.DATA_FIELD;
			let LIST_NAME     : string  = lay.LIST_NAME ;
			let UI_REQUIRED   : boolean = Sql.ToBoolean(lay.UI_REQUIRED) || Sql.ToBoolean(lay.DATA_REQUIRED);
			let bIsHidden     : boolean = lay.hidden;
			if ( FIELD_TYPE == 'ListBox' )
			{
				if ( !Sql.IsEmptyString(LIST_NAME) && UI_REQUIRED && !bIsHidden )
				{
					let arrLIST: string[] = L10n.GetList(LIST_NAME);
					if ( arrLIST != null && arrLIST.length > 0 )
					{
						item[DATA_FIELD] = arrLIST[0];
					}
				}
			}
		}
	}
	return item;
}

export function EditView_GetTabList(layout: any[])
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
						VIEW_NAME = lay.EDIT_NAME;
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

export function EditView_ActivateTab(layout: any[], nActiveTabIndex: number)
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
				//console.log((new Date()).toISOString() + ' EditView_ActivateTab: ' + nLayoutIndex.toString() + '. ' + FIELD_TYPE + ' ' + lay.DATA_FORMAT + ' ' + lay.ActiveTab.toString());
			}
		}
	}
}

