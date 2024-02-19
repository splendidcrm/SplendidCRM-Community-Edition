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
import { Link, RouteComponentProps, withRouter }    from '../Router5'              ;
import { observer }                                 from 'mobx-react'                    ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
import AdminModule                                  from '../types/AdminModule'          ;
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                ;
import L10n                                         from '../scripts/L10n'               ;
import Credentials                                  from '../scripts/Credentials'        ;
import SplendidCache                                from '../scripts/SplendidCache'      ;
import { Admin_GetReactState }                      from '../scripts/Application'        ;
import { Crm_Config }                               from '../scripts/Crm'                ;
import { UpdateModule, AdminProcedure }             from '../scripts/ModuleUpdate'       ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest'    ;
// 4. Components and Views. 
import ErrorComponent                               from '../components/ErrorComponent'  ;
import RecompileProgressBar                         from '../ModuleViews/Administration/EditCustomFields/RecompileProgressBar';

interface IAdministrationViewProps extends RouteComponentProps<any>
{
}

interface IAdministrationViewState
{
	ADMIN_MENU  : any;
	stateKey    : number;
	busy        : boolean;
	// 06/11/2023 Paul.  Show spinner when busy. 
	error       : any;
	recompileKey: string;
}

@observer
class AdministrationView extends React.Component<IAdministrationViewProps, IAdministrationViewState>
{
	constructor(props: IAdministrationViewProps)
	{
		super(props);
		Credentials.SetViewMode('AdministrationView');
		this.state =
		{
			ADMIN_MENU  : null,
			stateKey    : 0,
			busy       : false,
			error       : null,
			recompileKey: 'recompile',
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		
		try
		{
			if ( SplendidCache.AdminMenu == null )
			{
				await Admin_GetReactState(this.constructor.name + '.componentDidMount');
			}
			let ADMIN_MENU = SplendidCache.AdminMenu;
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', ADMIN_MENU);
			// 04/19/2020 Paul.  Set title. 
			document.title = L10n.Term("Administration.LBL_MODULE_NAME");
			// 04/26/2020 Paul.  Reset scroll every time we set the title. 
			window.scroll(0, 0);
			let TAB_MENU = [];
			if ( ADMIN_MENU )
			{
				for (let i = 0; i < ADMIN_MENU.length; i++)
				{
					let category = ADMIN_MENU[i];

					for (let j = 0; j < category.MODULES.length; j++)
					{
						if ( category.MODULES[j].MENU_ENABLED )
						{
							let item: any = new Object();
							TAB_MENU.push(item);
							item.MODULE_NAME        = category.MODULES[j].MODULE_NAME ;
							item.DISPLAY_NAME       = category.MODULES[j].DISPLAY_NAME;
							item.EDIT_LABEL         = category.MODULES[j].EDIT_LABEL  ;
							item.RELATIONSHIP_ORDER = category.MODULES[j].TAB_ORDER   ;
							item.EDIT_ACLACCESS     = (item.MODULE_NAME != 'Modules' ? 1 : 0);
						}
					}
				}
				TAB_MENU = TAB_MENU.sort((item1, item2) =>
				{
					return item1.RELATIONSHIP_ORDER - item2.RELATIONSHIP_ORDER;
				});
			}
			SplendidCache.SetDetailViewRelationships('TabMenu.Admin', TAB_MENU);
			this.setState({ ADMIN_MENU });
			// 03/05/2019 Paul.  Don't turn on admin menu until the menu has been built. 
			if ( !Credentials.ADMIN_MODE )
			{
				Credentials.SetADMIN_MODE(true);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
		}
	}

	private toggleConfigFlag = async (sFlagName) =>
	{
		const { stateKey } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.toggleConfigFlag');
		let bFlag: boolean = Crm_Config.ToBoolean(sFlagName);
		let row: any = { NAME: sFlagName, VALUE: (bFlag ? '0' : '1'), CATEGORY: 'system'}
		try
		{
			await UpdateModule('Config', row, null, true);
			SplendidCache.SetConfigValue(sFlagName, !bFlag);
			this.setState( {stateKey: stateKey + 1, error: null} );
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.toggleConfigFlag', error);
			this.setState({ error });
		}
	}

	private toggleDataPrivacy = async () =>
	{
		const { stateKey } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.toggleDataPrivacy');
		let enable_data_privacy: boolean = Crm_Config.ToBoolean('enable_data_privacy');
		let row: any = { NAME: 'enable_data_privacy', VALUE: (enable_data_privacy ? '0' : '1'), CATEGORY: 'system'}
		try
		{
			let MODULE = SplendidCache.Module('DataPrivacy');
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.toggleDataPrivacy', MODULE);
			let row: any = {};
			row.ID = MODULE.ID;
			if ( Sql.ToBoolean(MODULE['MODULE_ENABLED']) )
				await AdminProcedure('spMODULES_Disable', row);
			else
				await AdminProcedure('spMODULES_Enable', row);

			SplendidCache.SetConfigValue('enable_data_privacy', !enable_data_privacy);
			this.setState( {stateKey: stateKey + 1, error: null} );
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.toggleDataPrivacy', error);
			this.setState({ error });
		}
	}

	private onPrecompile = () =>
	{
		this.props.history.push('/Administration/_devtools/Precompile');
	}

	// 06/11/2023 Paul.  Add Purge Demo Data. 
	private onPurgeDemoData = async () =>
	{
		const { stateKey } = this.state;
		try
		{
			let row: any = {};
			this.setState({ busy: true });
			await AdminProcedure('spSqlPurgeDemoData', row);
			this.setState( {stateKey: stateKey + 1, error: null, busy: false} );
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.onPurgeDemoData', error);
			this.setState({ error, busy: false });
		}
	}

	private toggleReactClient =  async () =>
	{
		const { stateKey } = this.state;
		let RELATIVE_PATH: string = '';
		let module: any = SplendidCache.Module('Home', this.constructor.name + '.toggleReactClient');
		if ( module != null )
			RELATIVE_PATH = Sql.ToString(module.RELATIVE_PATH);
		if ( RELATIVE_PATH.toLowerCase() == '~/react/home' )
			RELATIVE_PATH = '~/Home';
		else
			RELATIVE_PATH = '~/React/Home';
		try
		{
			let row: any = {};
			row.MODULE_NAME   = 'Home';
			row.RELATIVE_PATH = RELATIVE_PATH;
			await AdminProcedure('spMODULES_UpdateRelativePath', row);
			if ( module != null )
				module.RELATIVE_PATH = RELATIVE_PATH;
			this.setState( {stateKey: stateKey + 1, error: null} );
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.toggleReactClient', error);
			this.setState({ error });
		}
	}

	private ModuleActions = (adminModule: AdminModule) =>
	{
		const { stateKey } = this.state;
		const { MODULE_NAME, ADMIN_ROUTE } = adminModule;
		// 11/11/2019 Paul.  A null module means this is a blank. 
		if ( MODULE_NAME == null )
		{
			return null;
		}
		else if ( MODULE_NAME == 'Config' )
		{
			if ( Sql.IsEmptyString(ADMIN_ROUTE) )
			{
				return (<div style={ {textAlign: 'center'} }>
					(&nbsp;
					<a href='#' 
						key={ MODULE_NAME + '_Actions_' + stateKey} 
						onClick={ (e) => { e.preventDefault(); return this.toggleConfigFlag('show_sql'); } } 
						className='tabDetailViewDL2Link'>{ Crm_Config.ToBoolean('show_sql') ? L10n.Term('Administration.LBL_HIDE_SQL') : L10n.Term('Administration.LBL_SHOW_SQL') }</a>
					&nbsp;)
				</div>
				);
			}
			// 06/11/2023 Paul.  Add Purge Demo Data. 
			else if ( ADMIN_ROUTE == 'BackupDatabase' )
			{
				return (<div style={ {textAlign: 'center'} }>
					(&nbsp;
					<a href='#' onClick={ (e) => { e.preventDefault(); return this.onPurgeDemoData(); } }  className='tabDetailViewDL2Link'>{ L10n.Term('Administration.LBL_PURGE_DEMO') }</a>
					&nbsp;)
				</div>
				);
			}
		}
		else if ( MODULE_NAME == 'Modules' )
		{
			// 07/01/2023 Paul. Should only appear on Modules, not Configure Tabs. 
			if ( ADMIN_ROUTE == 'List' )
			{
				// 07/06/2021 Paul.  Provide an quick and easy way to enable/disable React client. 
				let RELATIVE_PATH: string = '';
				let module: any = SplendidCache.Module('Home', this.constructor.name + '.ModuleStatus');
				if ( module != null )
					RELATIVE_PATH = Sql.ToString(module.RELATIVE_PATH);
				return (<div style={ {textAlign: 'center'} }>
					(&nbsp;
					<a href='#' 
						key={ MODULE_NAME + '_Actions_' + stateKey} 
						onClick={ (e) => { e.preventDefault(); return this.toggleConfigFlag('allow_custom_paging'); } } 
						className='tabDetailViewDL2Link'>{ Crm_Config.ToBoolean('allow_custom_paging') ? L10n.Term('Modules.LBL_DISABLE') : L10n.Term('Modules.LBL_ENABLE') }</a>
					{ SplendidCache.AdminUserAccess('Administration', 'access') >= 0 && !Crm_Config.ToBoolean('disable_admin_classic')
					? <span>
					&nbsp;
					&nbsp;
					<a href='#' 
						key={ MODULE_NAME + '_React_' + stateKey} 
						onClick={ (e) => { e.preventDefault(); return this.toggleReactClient(); } } 
						className='tabDetailViewDL2Link'>{ RELATIVE_PATH.toLowerCase() == '~/react/home' ? L10n.Term('Modules.LBL_REACT_CLIENT_DISABLE') : L10n.Term('Modules.LBL_REACT_CLIENT_ENABLE') }</a>
					</span>
					: null
					}
					)
				</div>
				);
			}
		}
		else if ( MODULE_NAME == 'DataPrivacy' )
		{
			return (<div style={ {textAlign: 'center'} }>
				(&nbsp;
				<a href='#' 
					key={ MODULE_NAME + '_Actions_' + stateKey} 
					onClick={ (e) => { e.preventDefault(); return this.toggleDataPrivacy(); } } 
					className='tabDetailViewDL2Link'>{ Crm_Config.ToBoolean('enable_data_privacy') ? L10n.Term('DataPrivacy.LBL_DISABLE_DATA_PRIVACY') : L10n.Term('DataPrivacy.LBL_ENABLE_DATA_PRIVACY') }</a>
				&nbsp;)
			</div>
			);
		}
		else if ( MODULE_NAME == 'ACLRoles' )
		{
			return (<div style={ {textAlign: 'center'} }>
				(&nbsp;
				<a href='#' 
					key={ MODULE_NAME + '_Actions_' + stateKey} 
					onClick={ (e) => { e.preventDefault(); return this.toggleConfigFlag('allow_admin_roles'); } } 
					className='tabDetailViewDL2Link'>{ Crm_Config.ToBoolean('allow_admin_roles') ? L10n.Term('ACLRoles.LBL_DISABLE_ADMIN_DELEGATION') : L10n.Term('ACLRoles.LBL_ENABLE_ADMIN_DELEGATION') }</a>
				&nbsp;)
			</div>
			);
		}
		else if ( MODULE_NAME == 'Users' )
		{
			return (<div style={ {textAlign: 'center'} }>
				(&nbsp;
				<a href='#' 
					key={ MODULE_NAME + '_Actions_Require_' + stateKey} 
					onClick={ (e) => { e.preventDefault(); return this.toggleConfigFlag('require_user_assignment'); } } 
					className='tabDetailViewDL2Link'>{ Crm_Config.ToBoolean('require_user_assignment') ? L10n.Term('Users.LBL_OPTIONAL') : L10n.Term('Users.LBL_REQUIRE') }</a>
				{ (Crm_Config.ToString('service_level') == 'Enterprise' || Crm_Config.ToString('service_level') == 'Ultimate')
				? <span>&nbsp; &nbsp;
				<a href='#' 
					key={ MODULE_NAME + '_Actions_Dynamic_' + stateKey} 
					onClick={ (e) => { e.preventDefault(); return this.toggleConfigFlag('enable_dynamic_assignment'); } } 
					className='tabDetailViewDL2Link'>{ Crm_Config.ToBoolean('enable_dynamic_assignment') ? L10n.Term('Users.LBL_SINGULAR') : L10n.Term('Users.LBL_DYNAMIC') }</a>
				</span>
				: null
				}
				&nbsp;)
			</div>
			);
		}
		else if ( MODULE_NAME == 'Teams' )
		{
			return (<div style={ {textAlign: 'center'} }>
				(&nbsp;
				<a href='#' 
					key={ MODULE_NAME + '_Actions_Enable_' + stateKey} 
					onClick={ (e) => { e.preventDefault(); return this.toggleConfigFlag('enable_team_management'); } } 
					className='tabDetailViewDL2Link'>{ Crm_Config.ToBoolean('enable_team_management') ? L10n.Term('Teams.LBL_DISABLE') : L10n.Term('Teams.LBL_ENABLE') }</a>
				{ Crm_Config.ToBoolean('enable_team_management')
				? <span>&nbsp; &nbsp;
					<a href='#' 
						key={ MODULE_NAME + '_Actions_Require_' + stateKey} 
						onClick={ (e) => { e.preventDefault(); return this.toggleConfigFlag('require_team_management'); } } 
						className='tabDetailViewDL2Link'>{ Crm_Config.ToBoolean('require_team_management') ? L10n.Term('Teams.LBL_OPTIONAL') : L10n.Term('Teams.LBL_REQUIRE') }</a>
					{ (Crm_Config.ToString('service_level') == 'Enterprise' || Crm_Config.ToString('service_level') == 'Ultimate')
					? <span>&nbsp; &nbsp;
					<a href='#' 
						key={ MODULE_NAME + '_Actions_Dynamic_' + stateKey} 
						onClick={ (e) => { e.preventDefault(); return this.toggleConfigFlag('enable_dynamic_teams'); } } 
						className='tabDetailViewDL2Link'>{ Crm_Config.ToBoolean('enable_dynamic_teams') ? L10n.Term('Teams.LBL_SINGULAR') : L10n.Term('Teams.LBL_DYNAMIC') }</a>
					</span>
					: null
					}
					&nbsp; &nbsp;
					<a href='#' 
						key={ MODULE_NAME + '_Actions_Hierarchy_' + stateKey} 
						onClick={ (e) => { e.preventDefault(); return this.toggleConfigFlag('enable_team_hierarchy'); } } 
						className='tabDetailViewDL2Link'>{ Crm_Config.ToBoolean('enable_team_hierarchy') ? L10n.Term('Teams.LBL_NON_HIERARCHICAL') : L10n.Term('Teams.LBL_HIERARCHICAL') }</a>
				</span>
				: null
				}
				&nbsp;)
			</div>
			);
		}
		else if ( MODULE_NAME == 'SystemCheck' )
		{
			return (<div style={ {textAlign: 'center'} }>
				(&nbsp;
				<a href='#' onClick={ (e) => { e.preventDefault(); return this.onPrecompile(); } }  className='tabDetailViewDL2Link'>Precompile</a>
				&nbsp;)
			</div>
			);
		}
		else if ( MODULE_NAME == 'EditCustomFields' )
		{
			return (<div style={ {textAlign: 'center'} }>
				(&nbsp;
					<a href='#' 
						key={ MODULE_NAME + '_recompile' }
						onClick={ (e) => { e.preventDefault(); return this.RecompileViews(); } } 
						className='tabDetailViewDL2Link'>{ 'Recompile' }</a>
					&nbsp; &nbsp;
					<a href='#' 
						key={ MODULE_NAME + '_rebuild' }
						onClick={ (e) => { e.preventDefault(); return this.RebuildAudit(); } } 
						className='tabDetailViewDL2Link'>{ 'Rebuild Audit' }</a>
				&nbsp;)
			</div>
			);
		}
		return null;
	}

	private RecompileViews = async () =>
	{
		try
		{
			let res = await CreateSplendidRequest('Administration/Rest.svc/RecompileViews', 'POST', 'application/json; charset=utf-8', null);
			let json = await GetSplendidResult(res);
			this.setState({ recompileKey: this.state.recompileKey + '.' });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.RecompileViews', error);
			this.setState({ error });
		}
	}

	private RebuildAudit = async () =>
	{
		try
		{
			let res = await CreateSplendidRequest('Administration/Rest.svc/RebuildAudit', 'POST', 'application/json; charset=utf-8', null);
			let json = await GetSplendidResult(res);
			this.setState({ recompileKey: this.state.recompileKey + '.', error: L10n.Term('.LBL_BACKGROUND_OPERATION') });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.RebuildAudit', error);
			this.setState({ error });
		}
	}

	private ModuleStatus = (adminModule: AdminModule) =>
	{
		const { stateKey } = this.state;
		const { MODULE_NAME, ADMIN_ROUTE } = adminModule;
		// 11/11/2019 Paul.  A null module means this is a blank. 
		if ( MODULE_NAME == null )
		{
			return null;
		}
		else if ( MODULE_NAME == 'Config' )
		{
			if ( Sql.IsEmptyString(ADMIN_ROUTE) )
			{
				return (<div key={ MODULE_NAME + '_Status_' + stateKey}>
					{ Crm_Config.ToBoolean('show_sql') ? L10n.Term('Administration.LBL_SHOW_SQL_ENABLED') : L10n.Term('Administration.LBL_SHOW_SQL_DISABLED') }
				</div>
				);
			}
		}
		else if ( MODULE_NAME == 'Modules' )
		{
			// 07/06/2021 Paul.  Provide an quick and easy way to enable/disable React client. 
			let RELATIVE_PATH: string = '';
			let module: any = SplendidCache.Module('Home', this.constructor.name + '.ModuleStatus');
			if ( module != null )
				RELATIVE_PATH = Sql.ToString(module.RELATIVE_PATH);
			return (<div key={ MODULE_NAME + '_Status_' + stateKey}>
				{ Crm_Config.ToBoolean('allow_custom_paging') ? L10n.Term('Modules.LBL_CUSTOM_PAGING_ENABLED') : L10n.Term('Modules.LBL_CUSTOM_PAGING_DISABLED') }<br />
				{ RELATIVE_PATH.toLowerCase() == "~/react/home" ? L10n.Term('Modules.LBL_REACT_CLIENT_IS_ENABLED') : L10n.Term('Modules.LBL_REACT_CLIENT_IS_DISABLED') }<br />
			</div>
			);
		}
		else if ( MODULE_NAME == 'DataPrivacy' )
		{
			return (<div key={ MODULE_NAME + '_Status_' + stateKey}>
				{ Crm_Config.ToBoolean('enable_data_privacy') ? L10n.Term('DataPrivacy.LBL_DATA_PRIVACY_ENABLED') : L10n.Term('DataPrivacy.LBL_DATA_PRIVACY_DISABLED') }
			</div>
			);
		}
		else if ( MODULE_NAME == 'ACLRoles' )
		{
			return (<div key={ MODULE_NAME + '_Status_' + stateKey}>
				{ Crm_Config.ToBoolean('allow_admin_roles') ? L10n.Term('ACLRoles.LBL_ADMIN_DELEGATION_ENABLED') : L10n.Term('ACLRoles.LBL_ADMIN_DELEGATION_DISABLED') }
			</div>
			);
		}
		else if ( MODULE_NAME == 'Users' )
		{
			return (<div key={ MODULE_NAME + '_Status_' + stateKey}>
				{ Crm_Config.ToBoolean('require_user_assignment') ? L10n.Term('Users.LBL_USER_ASSIGNMENT_REQUIRED') : L10n.Term('Users.LBL_USER_ASSIGNMENT_OPTIONAL') }
				{ (Crm_Config.ToString('service_level') == 'Enterprise' || Crm_Config.ToString('service_level') == 'Ultimate')
				? <span>&nbsp;
					{ Crm_Config.ToBoolean('enable_dynamic_assignment') ? L10n.Term('Users.LBL_ASSIGNMENT_DYNAMIC') : L10n.Term('Users.LBL_ASSIGNMENT_NOT_DYNAMIC') }
				</span>
				: null
				}
			</div>
			);
		}
		else if ( MODULE_NAME == 'Teams' )
		{
			return (<div key={ MODULE_NAME + '_Status_' + stateKey}>
				{ Crm_Config.ToBoolean('enable_team_management') ? L10n.Term('Teams.LBL_TEAMS_ENABLED') : L10n.Term('Teams.LBL_TEAMS_DISABLED') }
				{ Crm_Config.ToBoolean('enable_team_management') && Crm_Config.ToBoolean('require_team_management') ? L10n.Term('Teams.LBL_TEAMS_REQUIRED') : L10n.Term('Teams.LBL_TEAMS_NOT_REQUIRED') }
				{ (Crm_Config.ToString('service_level') == 'Enterprise' || Crm_Config.ToString('service_level') == 'Ultimate')
				? <span>&nbsp;
					{ Crm_Config.ToBoolean('enable_dynamic_teams') ? L10n.Term('Teams.LBL_TEAMS_DYNAMIC') : L10n.Term('Teams.LBL_TEAMS_NOT_DYNAMIC') }
				</span>
				: null
				}
				{ Crm_Config.ToBoolean('enable_team_management') && Crm_Config.ToBoolean('enable_team_hierarchy') ? L10n.Term('Teams.LBL_TEAMS_HIERARCHICAL') : L10n.Term('Teams.LBL_TEAMS_NON_HIERARCHICAL') }
			</div>
			);
		}
		return null;
	}

	private ExternalLink = (url: string, target: string, term: string) =>
	{
		return(<span>
			<a href={ url } target={ target }>{ L10n.Term(term) }</a>&nbsp;&nbsp;<FontAwesomeIcon icon='external-link-alt' color='#444444' />
		</span>
		);
	}

	private PrimaryAction = (adminModule: AdminModule) =>
	{
		const { MODULE_NAME, DISPLAY_NAME, ADMIN_ROUTE } = adminModule;
		// 11/11/2019 Paul.  A null module means this is a blank. 
		if ( MODULE_NAME == null )
		{
			return null;
		}
		else if ( ADMIN_ROUTE == 'Documentation' )
		{
			let url: string = 'https://www.splendidcrm.com/Documentation.aspx';
			return this.ExternalLink(url, 'SplendidCRM_' + ADMIN_ROUTE, DISPLAY_NAME);
		}
		else if ( ADMIN_ROUTE == 'SystemCheck' )
		{
			let url: string = Credentials.RemoteServer + 'SystemCheck.aspx';
			return this.ExternalLink(url, 'SplendidCRM_' + ADMIN_ROUTE, DISPLAY_NAME);
		}
		else if ( ADMIN_ROUTE == 'ExportDatabase' )
		{
			let url: string = Credentials.RemoteServer + 'Administration/Export/default.aspx';
			return this.ExternalLink(url, 'SplendidCRM_' + ADMIN_ROUTE, DISPLAY_NAME);
		}
		// 01/18/2021 Paul.  Add legacy links to currently unsupported admin pages. 
		else if ( MODULE_NAME == 'SimpleStorage' )
		{
			let url: string = Credentials.RemoteServer + 'Administration/SimpleStorage/default.aspx';
			return this.ExternalLink(url, 'SplendidCRM_' + MODULE_NAME, DISPLAY_NAME);
		}
		else if ( MODULE_NAME == 'SimpleEmail' )
		{
			let url: string = Credentials.RemoteServer + 'Administration/SimpleEmail/default.aspx';
			return this.ExternalLink(url, 'SplendidCRM_' + MODULE_NAME, DISPLAY_NAME);
		}
		else if ( ADMIN_ROUTE == 'AuthorizeNetCustomerListView' )
		{
			return (<Link 
				className='tabDetailViewDL2Link' 
				to={ '/Administration/' + MODULE_NAME + '/CustomerProfiles' }>
				{ L10n.Term(DISPLAY_NAME).replace('&reg;', '\u00ae') }
			</Link>);
		}
		else if ( MODULE_NAME == 'Administration' )
		{
			return (<Link 
				className='tabDetailViewDL2Link' 
				to={ '/Administration/' + ADMIN_ROUTE }>
				{ L10n.Term(DISPLAY_NAME).replace('&reg;', '\u00ae') }
			</Link>);
		}
		else
		{
			return (<Link 
				className='tabDetailViewDL2Link' 
				to={ !Sql.IsEmptyString(ADMIN_ROUTE) ? '/Administration/' + MODULE_NAME + '/' + ADMIN_ROUTE : '/Administration/' + MODULE_NAME + '/List'  }>
				{ L10n.Term(DISPLAY_NAME).replace('&reg;', '\u00ae') }
			</Link>);
		}
	}

	public render()
	{
		const { ADMIN_MENU, busy, error, recompileKey } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 06/11/2023 Paul.  Show spinner when busy. 
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			return (
			<div id="ctlAdministration">
				<h2>{ L10n.Term('Administration.LBL_MODULE_TITLE') }</h2>
				<ErrorComponent error={error} />
				{ busy
				? <div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
					<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
				</div>
				: null
				}
				{ ADMIN_MENU
				? ADMIN_MENU.map(adminPanel => (
					<div>
						{ adminPanel.NAME == 'StudioView'
						? <RecompileProgressBar key={ recompileKey } />
						: null
						}
						<div className='h3Row' style={ {display: 'flex', justifyContent: 'center', flexDirection: 'column'} }>
							<h3>{ adminPanel.TITLE }</h3>
						</div>
						<div className='tabDetailView2' style={ {width: '100%', display: 'flex', flexFlow: 'row wrap'} }>
							{ adminPanel.MODULES.map((adminModule: AdminModule) => (
								<div style={ {width: '100%', display: 'flex', flexFlow: 'row wrap', flex: '1 0 50%'} }>
									<div className='tabDetailViewDL2' style={ {width: '40%'} }>
										{ adminModule.MODULE_NAME
										? <img 
											style={ {borderWidth: '0', height: '16px', width: '16px', verticalAlign: 'text-bottom'} }
											src={ Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/' + adminModule.ICON_NAME }
										/>
										: null
										}
										&nbsp;
										{ this.PrimaryAction(adminModule) }
										{ this.ModuleActions(adminModule) }
									</div>
									<div className='tabDetailViewDF2' style={ {width: '60%'} }>
										<div>{ !Sql.IsEmptyString(adminModule.DESCRIPTION) ? L10n.Term(adminModule.DESCRIPTION) : null }</div>
										{ this.ModuleStatus(adminModule) }
									</div>
								</div>))
							}
							{ adminPanel.MODULES.length % 2 == 1
							? <div style={ {width: '100%', display: 'flex', flexFlow: 'row wrap', flex: '1 0 50%'} }>
								<div className='tabDetailViewDL2' style={ {width: '40%'} }></div>
								<div className='tabDetailViewDF2' style={ {width: '60%'} }></div>
							</div>
							: null
							}
						</div>
					</div>))
				: null
				}
			</div>
			);
		}
		else
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
			</div>);
		}
	}
}

export default withRouter(AdministrationView);
