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
import { SplendidRequestService } from './SplendidRequest';
import { SplendidCacheService   } from './SplendidCache'  ;
import { CredentialsService     } from './Credentials'     ;
import { SecurityService        } from './Security'        ;
import { DetailViewService      } from './DetailView'     ;
import { EditViewService        } from './EditView'       ;
import { Right, EndsWith        } from './utility'                 ;
import Sql                        from './Sql'                     ;
import MODULE                     from '../types/MODULE'                    ;

@Injectable({
	providedIn: 'root'
})
export class CrmConfigService
{
	constructor(protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService)
	{
	}

	public enable_team_management()
	{
		return Sql.ToBoolean(this.SplendidCache.Config('enable_team_management'));
	}

	public require_team_management()
	{
		return Sql.ToBoolean(this.SplendidCache.Config('require_team_management'));
	}
	
	public enable_dynamic_teams()
	{
		return Sql.ToBoolean(this.SplendidCache.Config('enable_dynamic_teams'));
	}
	
	// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
	public enable_dynamic_assignment()
	{
		return Sql.ToBoolean(this.SplendidCache.Config('enable_dynamic_assignment'));
	}
	
	// 04/28/2016 Paul.  Allow team hierarchy. 
	public enable_team_hierarchy()
	{
		return Sql.ToBoolean(this.SplendidCache.Config('enable_team_hierarchy'));
	}
	
	public require_user_assignment()
	{
		return Sql.ToBoolean(this.SplendidCache.Config('require_user_assignment'));
	}
	
	// 06/26/2018 Paul.  Data Privacy uses the module enabled flag. 
	// 07/01/2018 Paul.  The Data Privacy module is not returned via the REST API, so we need to simulate the flag. 
	public enable_data_privacy()
	{
		return Sql.ToBoolean(this.SplendidCache.Config('enable_data_privacy'));
	}
	
	// 08/31/2012 Paul.  Add support for speech. 
	public enable_speech()
	{
		return Sql.ToBoolean(this.SplendidCache.Config('enable_speech'));
	}
	
	public ToBoolean(sName: string)
	{
		return Sql.ToBoolean(this.SplendidCache.Config(sName));
	}
	
	public ToInteger(sName: string)
	{
		return Sql.ToInteger(this.SplendidCache.Config(sName));
	}
	
	public ToString(sName: string)
	{
		return Sql.ToString(this.SplendidCache.Config(sName));
	}

	public SiteURL()
	{
		let sSiteURL: string = Sql.ToString(this.SplendidCache.Config('site_url'));
		if ( Sql.IsEmptyString(sSiteURL) )
		{
			sSiteURL = this.Credentials.RemoteServer;
		}
		if ( !EndsWith(sSiteURL, '/') )
		{
			sSiteURL += '/';
		}
		return sSiteURL;
	}
}

@Injectable({
	providedIn: 'root'
})
export class CrmModulesService
{
	constructor(private SplendidRequest: SplendidRequestService, protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, protected Security: SecurityService, private Crm_Config: CrmConfigService, private DetailView: DetailViewService, private EditView: EditViewService)
	{
	}

	// 03/11/2021 Paul.  Provide a way to get a module from a table name. 
	public ModuleName(sTABLE_NAME: string)
	{
		if ( this.SplendidCache.MODULES != null )
		{
			for ( let sMODULE_NAME in this.SplendidCache.MODULES )
			{
				let module = this.SplendidCache.MODULES[sMODULE_NAME];
				if ( module.TABLE_NAME == sTABLE_NAME )
				{
					return sMODULE_NAME;
				}
			}
		}
		return null;
	}
	
	public TableName(sMODULE: string)
	{
		let module = this.SplendidCache.Module(sMODULE, 'Crm_Modules.TableName');
		if ( module == null )
		{
			console.warn('Crm_Modules.TableName Module not found: ' + sMODULE, this.SplendidCache.MODULES);
			throw new Error('Crm_Modules.TableName Module not found: ' + sMODULE);
		}
		return module.TABLE_NAME;
	}
	
	public SingularTableName(sTABLE_NAME: string)
	{
		if ( Right(sTABLE_NAME, 3) == 'IES' && sTABLE_NAME.length > 3 )
			sTABLE_NAME = sTABLE_NAME.substring(0, sTABLE_NAME.length - 3) + 'Y';
		else if ( Right(sTABLE_NAME, 1) == 'S' )
			sTABLE_NAME = sTABLE_NAME.substring(0, sTABLE_NAME.length - 1);
		return sTABLE_NAME;
	}
	
	public SingularModuleName(sMODULE: string)
	{
		if ( Right(sMODULE, 3) == 'ies' && sMODULE.length > 3 )
			sMODULE = sMODULE.substring(0, sMODULE.length - 3) + 'y';
		else if ( Right(sMODULE, 1) == 's' )
			sMODULE = sMODULE.substring(0, sMODULE.length - 1);
		return sMODULE;
	}
	
	public ExchangeFolders(sMODULE: string)
	{
		var module = this.SplendidCache.Module(sMODULE, 'Crm_Modules.ExchangeFolders');
		// 10/24/2014 Paul.  The module should not return NULL, but we don't want to generate an error here. 
		if ( module === undefined )
			return false;
		return Sql.ToBoolean(module.EXCHANGE_SYNC) && Sql.ToBoolean(module.EXCHANGE_FOLDERS);
	}
	
	public async ItemName(sMODULE_NAME: string, sID: string): Promise<any>
	{
		let d = await this.DetailView.LoadItem(sMODULE_NAME, sID, false, false);
		let item: any = d.results;
		if ( item != null )
		{
			return Sql.ToString(item['NAME']);
		}
		return null;
	}
	
	public async ParentModule(sID: string): Promise<string>
	{
		let sTABLE_NAME    : string = 'vwPARENTS';
		let sSORT_FIELD    : string = 'PARENT_ID';
		let sSORT_DIRECTION: string = '';
		let sSELECT        : string = 'PARENT_ID, PARENT_NAME, PARENT_TYPE, PARENT_ASSIGNED_USER_ID';
		let sFILTER        : string = 'PARENT_ID eq \'' + sID + '\'';
		// 01/26/2020 Paul.  Make sure that an empty filter does not get sent as "null". 
		let json: any = await this.SplendidRequest.CreateSplendidRequest('Rest.svc/GetModuleTable?TableName=' + sTABLE_NAME + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION) + '&$select=' + encodeURIComponent(sSELECT) + '&$filter=' + (Sql.IsEmptyString(sFILTER) ? '' : encodeURIComponent(sFILTER)), 'GET');
		if (json.d !== undefined && json.d.results !== undefined && json.d.results.length > 0)
		{
			let row = json.d.results[0];
			let sMODULE_NAME = Sql.ToString(row['PARENT_TYPE']);
			return sMODULE_NAME;
		}
		throw new Error('Item not found for ID = ' + sID);
	}

	public ArchiveEnabled(MODULE: string)
	{
		let bEnabled: boolean = false;
		let module: MODULE = this.SplendidCache.Module(MODULE, 'Crm_Modules.ArchiveEnabled');
		if ( module != null )
		{
			bEnabled = Sql.ToBoolean(module.ARCHIVED_ENBLED);
		}
		return bEnabled;
	}

	// 12/03/2019 Paul.  Separate Archive View exists flag so that we can display information on DetailView. 
	public ArchiveViewExists(MODULE: string)
	{
		let bExists: boolean = false;
		let module: MODULE = this.SplendidCache.Module(MODULE, 'Crm_Modules.ArchiveViewExists');
		if ( module != null )
		{
			bExists = Sql.ToBoolean(module.ARCHIVED_ENBLED);
		}
		return bExists;
	}

	public StreamEnabled(MODULE: string)
	{
		let bEnabled: boolean = false;
		let module: MODULE = this.SplendidCache.Module(MODULE, 'Crm_Modules.StreamEnabled');
		if ( module != null )
		{
			bEnabled = Sql.ToBoolean(module.STREAM_ENBLED);
		}
		return bEnabled;
	}

	public MassUpdate(MODULE: string)
	{
		let bEnabled: boolean = false;
		let module: MODULE = this.SplendidCache.Module(MODULE, 'Crm_Modules.MassUpdate');
		if ( module != null )
		{
			bEnabled = Sql.ToBoolean(module.MASS_UPDATE_ENABLED);
		}
		return bEnabled;
	}

	public async LoadParent(sPARENT_TYPE: string, sID: string): Promise<any>
	{
		let rowDefaultSearch: any = null;
		if ( !Sql.IsEmptyString(sPARENT_TYPE) && !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await this.EditView.LoadItem(sPARENT_TYPE, sID);
				let item: any = d.results;
				if ( item != null )
				{
					rowDefaultSearch = {};
					rowDefaultSearch['PARENT_ID'            ] = item['ID'  ]    ;
					rowDefaultSearch['PARENT_NAME'          ] = item['NAME']    ;
					// 08/09/2020 Paul.  Change to PARENT_TYPE. 
					rowDefaultSearch['PARENT_TYPE'          ] = sPARENT_TYPE;
					if ( this.Crm_Config.ToBoolean('inherit_assigned_user') )
					{
						rowDefaultSearch['ASSIGNED_USER_ID' ] = item['ASSIGNED_USER_ID' ];
						rowDefaultSearch['ASSIGNED_TO'      ] = item['ASSIGNED_TO'      ];
						rowDefaultSearch['ASSIGNED_TO_NAME' ] = item['ASSIGNED_TO_NAME' ];
						rowDefaultSearch['ASSIGNED_SET_ID'  ] = item['ASSIGNED_SET_ID'  ];
						rowDefaultSearch['ASSIGNED_SET_LIST'] = item['ASSIGNED_SET_LIST'];
						rowDefaultSearch['ASSIGNED_SET_NAME'] = item['ASSIGNED_SET_NAME'];
					}
					else
					{
						// 10/12/2019 Paul.  If we are providing defaults, then we need to provide user and team defaults. 
						rowDefaultSearch['ASSIGNED_USER_ID' ]  = this.Security.USER_ID()  ;
						rowDefaultSearch['ASSIGNED_TO'      ]  = this.Security.USER_NAME();
						rowDefaultSearch['ASSIGNED_TO_NAME' ]  = this.Security.FULL_NAME();
					}
					if ( this.Crm_Config.ToBoolean('inherit_team') )
					{
						rowDefaultSearch['TEAM_ID'          ] = item['TEAM_ID'      ];
						rowDefaultSearch['TEAM_NAME'        ] = item['TEAM_NAME'    ];
						rowDefaultSearch['TEAM_SET_ID'      ] = item['TEAM_SET_ID'  ];
						rowDefaultSearch['TEAM_SET_LIST'    ] = item['TEAM_SET_LIST'];
						rowDefaultSearch['TEAM_SET_NAME'    ] = item['TEAM_SET_NAME'];
					}
					else
					{
						// 10/12/2019 Paul.  If we are providing defaults, then we need to provide user and team defaults. 
						rowDefaultSearch['TEAM_ID'          ] = this.Security.TEAM_ID()  ;
						rowDefaultSearch['TEAM_NAME'        ] = this.Security.TEAM_NAME();
						rowDefaultSearch['TEAM_SET_LIST'    ] = this.Security.TEAM_ID()  ;
						rowDefaultSearch['TEAM_SET_NAME'    ] = this.Security.TEAM_ID()  ;
					}
				}
			}
			catch(error)
			{
				console.error(this.constructor.name + '.LoadParent', error);
			}
		}
		return rowDefaultSearch;
	}
}

@Injectable({
	providedIn: 'root'
})
export class CrmTeamsService
{
	constructor(protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService)
	{
	}

	public Name(sID: string)
	{
		var rowTeam = this.SplendidCache.Team(sID);
		if ( rowTeam !== undefined && rowTeam != null )
		{
			return rowTeam.NAME;
		}
		else
		{
			// 07/10/2019 Paul.  If not in cache, return ID. 
			return sID;
		}
	}
}

@Injectable({
	providedIn: 'root'
})
export class CrmUsersService
{
	constructor(protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService)
	{
	}

	// 12/31/2017 Paul.  Add support for Dynamic Assignment. 
	public Name(sID: string)
	{
		var rowUser = this.SplendidCache.User(sID);
		if ( rowUser !== undefined && rowUser != null )
		{
			return rowUser.USER_NAME;
		}
		else
		{
			// 07/10/2019 Paul.  If not in cache, return ID. 
			return sID;
		}
	}
}

@Injectable({
	providedIn: 'root'
})
export class CrmPasswordService
{
	constructor(protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, private Crm_Config: CrmConfigService)
	{
	}

	public enable_team_management()
	{
		return Sql.ToBoolean(this.SplendidCache.Config('enable_team_management'));
	}

	public get PreferredPasswordLength(): number
	{
		let sValue: string = Sql.ToString(this.Crm_Config.ToString("Password.PreferredPasswordLength"));
		if ( Sql.IsEmptyString(sValue) )
			sValue = "6";
		return Sql.ToInteger(sValue);
	}

	public get MinimumLowerCaseCharacters(): number
	{
		let sValue: string = Sql.ToString(this.Crm_Config.ToString("Password.MinimumLowerCaseCharacters"));
		if ( Sql.IsEmptyString(sValue) )
			sValue = "1";
		return Sql.ToInteger(sValue);
	}

	public get MinimumUpperCaseCharacters(): number
	{
		let sValue: string = Sql.ToString(this.Crm_Config.ToString("Password.MinimumUpperCaseCharacters"));
		if ( Sql.IsEmptyString(sValue) )
			sValue = "0";
		return Sql.ToInteger(sValue);
	}

	public get MinimumNumericCharacters(): number
	{
		let sValue: string = Sql.ToString(this.Crm_Config.ToString("Password.MinimumNumericCharacters"));
		if ( Sql.IsEmptyString(sValue) )
			sValue = "1";
		return Sql.ToInteger(sValue);
	}

	public get MinimumSymbolCharacters(): number
	{
		let sValue: string = Sql.ToString(this.Crm_Config.ToString("Password.MinimumSymbolCharacters"));
		if ( Sql.IsEmptyString(sValue) )
			sValue = "0";
		return Sql.ToInteger(sValue);
	}

	public get PrefixText(): string
	{
		let sValue: string = Sql.ToString(this.Crm_Config.ToString("Password.PrefixText"));
		// 02/19/2011 Paul.  The default is a blank string. 
		return sValue;
	}

	public get TextStrengthDescriptions(): string
	{
		let sValue: string = Sql.ToString(this.Crm_Config.ToString("Password.TextStrengthDescriptions"));
		// 02/19/2011 Paul.  The default is not to display strength descriptions. 
		if ( Sql.IsEmptyString(sValue) )
			sValue = ";;;;;;";
		return sValue;
	}

	public get SymbolCharacters(): string
	{
		let sValue: string = Sql.ToString(this.Crm_Config.ToString("Password.SymbolCharacters"));
		if ( Sql.IsEmptyString(sValue) )
			sValue = "!@#$%^&*()<>?~.";
		return sValue;
	}

	public get ComplexityNumber(): number
	{
		let sValue: string = Sql.ToString(this.Crm_Config.ToString("Password.ComplexityNumber"));
		if ( Sql.IsEmptyString(sValue) )
			sValue = "2";
		return Sql.ToInteger(sValue);
	}

	public get HistoryMaximum(): number
	{
		let sValue: string = Sql.ToString(this.Crm_Config.ToString("Password.HistoryMaximum"));
		if ( Sql.IsEmptyString(sValue) )
			sValue = "0";
		return Sql.ToInteger(sValue);
	}

	public get LoginLockoutCount(): number
	{
		let nValue: number = Sql.ToInteger(this.Crm_Config.ToString("Password.LoginLockoutCount"));
		// 03/04/2011 Paul.  We cannot allow a lockout count of zero as it would prevent all logins. 
		if ( nValue <= 0 )
		{
			nValue = 5;
			// 03/05/2011 Paul.  Save the default value so as to reduce the conversion for each login. 
			this.SplendidCache.SetConfigValue("Password.LoginLockoutCount", nValue);
		}
		return nValue;
	}

	public get ExpirationDays(): number
	{
		let nValue: number = Sql.ToInteger(this.Crm_Config.ToString("Password.ExpirationDays"));
		if ( nValue < 0 )
		{
			nValue = 0;
			// 03/05/2011 Paul.  Save the default value so as to reduce the conversion for each login. 
			this.SplendidCache.SetConfigValue("Password.ExpirationDays", nValue);
		}
		return nValue;
	}
}
