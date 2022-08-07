/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import { Injectable             } from '@angular/core'                      ;
import { SplendidRequestService } from '../scripts/SplendidRequest';
import { SplendidCacheService   } from '../scripts/SplendidCache'  ;
import { CredentialsService     } from '../scripts/Credentials'     ;
import { L10nService            } from '../scripts/L10n'            ;
import Sql                        from '../scripts/Sql'                     ;
import DETAILVIEWS_FIELD          from '../types/DETAILVIEWS_FIELD'         ;

@Injectable({
	providedIn: 'root'
})
export class DetailViewService
{
	constructor(private SplendidRequest: SplendidRequestService, protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, protected L10n: L10nService)
	{
	}

	public async LoadItem(MODULE_NAME: string, ID: string, ADMIN_MODE: boolean, archiveView: boolean)
	{
		let admin: string = '';
		if ( ADMIN_MODE )
			admin = 'Administration/';
		let json: any = await this.SplendidRequest.CreateSplendidRequest(admin + 'Rest.svc/GetModuleItem?ModuleName=' + MODULE_NAME + '&ID=' + ID + '&$accessMode=view' + (archiveView ? '&$archiveView=1' : ''), 'GET');
		// 11/19/2019 Paul.  Change to allow return of SQL. 
		json.d.__sql = json.__sql;
		return json.d;
	}

	// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
	// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
	public LoadLayout(DETAIL_NAME: string, ignoreMissing?: boolean)
	{
		let layout: any[] = null;
		if ( Sql.IsEmptyString(this.Credentials.sPRIMARY_ROLE_NAME) )
		{
			layout = this.SplendidCache.DetailViewFields(DETAIL_NAME, ignoreMissing);
		}
		else
		{
			// 07/07/2020 Paul.  Ignore missing when looking for primary role. 
			layout = this.SplendidCache.DetailViewFields(DETAIL_NAME + '.' + this.Credentials.sPRIMARY_ROLE_NAME, true);
			if ( layout === undefined || layout == null || layout.length == 0 )
			{
				layout = this.SplendidCache.DetailViewFields(DETAIL_NAME, ignoreMissing);
			}
		}
		// 05/26/2019 Paul.  We will no longer lookup missing layout values if not in the cache. 
		if ( layout == null )
		{
			// 02/02/2020 Paul.  Ignore missing inline as there are too many. 
			if ( !ignoreMissing )
			{
				// 01/08/2021 Paul.  No lnoger needed. 
				//console.warn(DETAIL_NAME + ' not found in DetailViews');
			}
		}
		else
		{
			// 11/02/2019 Paul.  Return a clone of the layout so that we can dynamically modify the layout. 
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			// 04/16/2022 Paul.  We need to initialize tabs for every layout. 
			let bPacificTheme: boolean = (this.Credentials.sUSER_THEME == 'Pacific');
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
				this.ActivateTab(layout, 0);
			}
		}
		return layout;
	}

	public async LoadAudit(MODULE_NAME: string, ID: string)
	{
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/GetModuleAudit?ModuleName=' + MODULE_NAME + '&ID=' + ID, 'GET');
		json.d.__sql = json.__sql;
		return json.d;
	}

	public async GetByAudit(MODULE_NAME: string, AUDIT_ID: string)
	{
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/GetModuleItemByAudit?ModuleName=' + MODULE_NAME + '&AUDIT_ID=' + AUDIT_ID, 'GET');
		return json.d;
	}

	public async LoadPersonalInfo(MODULE_NAME: string, ID: string)
	{
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/GetModulePersonal?ModuleName=' + MODULE_NAME + '&ID=' + ID, 'GET');
		return json.d;
	}

	public RemoveField(layout: DETAILVIEWS_FIELD[], DATA_FIELD: string)
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

	public HideField(layout: DETAILVIEWS_FIELD[], DATA_FIELD: string, hidden: boolean)
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

	public FindField(layout: DETAILVIEWS_FIELD[], DATA_FIELD: string)
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

	public GetTabList(layout: any[])
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
							DATA_LABEL = this.L10n.Term(DATA_LABEL);
						}
						arrTabs.push({ nLayoutIndex, DATA_LABEL, VIEW_NAME });
					}
				}
			}
		}
		return arrTabs;
	}

	public ActivateTab(layout: any[], nActiveTabIndex: number)
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
					//console.log((new Date()).toISOString() + this.constructor.name + '.ActivateTab: ' + nLayoutIndex.toString() + '. ' + FIELD_TYPE + ' ' + lay.DATA_FORMAT + ' ' + lay.ActiveTab.toString());
				}
			}
		}
	}

}
