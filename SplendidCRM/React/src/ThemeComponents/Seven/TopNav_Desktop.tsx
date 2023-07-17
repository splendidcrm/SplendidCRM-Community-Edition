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
import { RouteComponentProps, withRouter }       from 'react-router-dom'                   ;
import { FontAwesomeIcon }                       from '@fortawesome/react-fontawesome'     ;
import { observer }                              from 'mobx-react'                         ;
import { Navbar, NavbarBrand, Nav, NavDropdown } from 'react-bootstrap'                    ;
// 2. Store and Types. 
import MODULE                                    from '../../types/MODULE'                 ;
import TAB_MENU                                  from '../../types/TAB_MENU'               ;
import SHORTCUT                                  from '../../types/SHORTCUT'               ;
// 3. Scripts. 
import Sql                                       from '../../scripts/Sql'                  ;
import L10n                                      from '../../scripts/L10n'                 ;
import Security                                  from '../../scripts/Security'             ;
import SplendidCache                             from '../../scripts/SplendidCache'        ;
import Credentials                               from '../../scripts/Credentials'          ;
import { TabMenu_Load }                          from '../../scripts/TabMenu'              ;
import { Crm_Config, Crm_Modules }               from '../../scripts/Crm'                  ;
import { Logout, LoginRedirect }                 from '../../scripts/Login'                ;
import { Dashboards }                            from '../../scripts/Dashboard'            ;
import { EditViewRelationships_LoadLayout }      from '../../scripts/EditViewRelationships';
import { StartsWith, EndsWith, ActiveModuleFromPath } from '../../scripts/utility'         ;
import { UpdateModule }                          from '../../scripts/ModuleUpdate'         ;
// 4. Components and Views.
import NavItem                                   from '../../components/NavItem'           ;
import ErrorComponent                            from '../../components/ErrorComponent'    ;
import DynamicButtons                            from '../../components/DynamicButtons'    ;
import DynamicEditView                           from '../../views/DynamicEditView'        ;

interface ITopNavProps extends RouteComponentProps<any>
{
}

interface ITopNavState
{
	tabMenus           : TAB_MENU[];
	quickCreate        : TAB_MENU[];
	dashboards         : any;
	homeDashboards     : any;
	adminMode          : boolean;
	isOpen             : boolean;
	txtQuickSearch     : string;
	bIsAuthenticated   : boolean;
	nMaxTabs?          : number;
	nHistoryMaxViewed? : number;
	showInlineEdit     : boolean;
	QUICK_CREATE_MODULE: string;
	item?              : any;
	dependents?        : Record<string, Array<any>>;
	error?             : any;
	activeModule       : string;
	menuChangeKey      : number;  // 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
	unifiedSearchItems : number;  // 01/10/2022 Paul.  Don't show if search panels empty. 
}

@observer
class SevenTopNav_Desktop extends React.Component<ITopNavProps, ITopNavState>
{
	private _isMounted = false;

	private dynamicButtonsTop    = React.createRef<DynamicButtons>();
	private editView             = React.createRef<DynamicEditView>();

	constructor(props: ITopNavProps)
	{
		super(props);
		let activeModule: string = ActiveModuleFromPath(this.props.location.pathname, this.constructor.name + '.constructor');
		// 01/08/2020 Paul.  Pull the current value from the URL so that we can reload after submit. 
		let txtQuickSearch: string = '';
		if ( StartsWith(props.location.pathname, '/UnifiedSearch/') )
		{
			txtQuickSearch = props.location.pathname.substr(15);
		}
		this.state =
		{
			tabMenus           : [],
			quickCreate        : [],
			dashboards         : null,
			homeDashboards     : null,
			adminMode          : Credentials.ADMIN_MODE,
			isOpen             : true,
			txtQuickSearch     : txtQuickSearch,
			bIsAuthenticated   : false,
			nMaxTabs           : 7,
			nHistoryMaxViewed  : 10,
			showInlineEdit     : false,
			QUICK_CREATE_MODULE: null,
			activeModule       ,
			menuChangeKey      : 0,
			unifiedSearchItems : 0,
		};
	}

	async componentDidMount()
	{
		const { bIsAuthenticated } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.props.location.pathname);
		this._isMounted = true;
		// 05/28/2019 Paul.  Use a passive IsAuthenticated check (instead of active server query), so that we do not have multiple simultaneous requests. 
		let bAuthenticated: boolean = Credentials.bIsAuthenticated;
		if ( !bAuthenticated )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount: not authenticated');
			// 05/02/2019 Paul.  Each view will be responsible for checking authenticated. 
			//if ( this.props.location.pathname != '/login' )
			//{
			//	LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			//	return;
			//}
		}
		else
		{
			// 05/26/2019 Paul.  max_tabs is an undefined User Profile value, we will use the config default_max_tabs. 
			// 05/29/2019 Paul.  We can't get these values in the constructor as the user may not be authenticated and therefore would not exist. 
			this.setState( 
			{
				bIsAuthenticated: bAuthenticated,
			}, async () =>
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount Load');
				// 05/26/2019 Paul.  Load will get called in componentWillUpdate. 
				//await this.Load('componentDidMount');
			});
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	async componentDidUpdate(prevProps: ITopNavProps)
	{
		const { txtQuickSearch } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', this.props.location.pathname, prevProps.location.pathname, txtQuickSearch);
		// 12/10/2019 Paul.  With a deep link, the cache will not be loaded, so the activeModule will not be set. 
		if ( this.props.location.pathname != prevProps.location.pathname || Sql.IsEmptyString(this.state.activeModule) )
		{
			let activeModule: string = ActiveModuleFromPath(this.props.location.pathname, this.constructor.name + '.componentDidUpdate');
			if ( activeModule != this.state.activeModule )
			{
				this.setState({ activeModule });
			}
			// 01/08/2021 Paul.  Don't clear value as it will prevent a follow-up search. 
			//if ( !Sql.IsEmptyString(txtQuickSearch) )
			//{
			//	this.setState( {txtQuickSearch: ''} );
			//	//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate clear search');
			//}
			// 08/11/2020 Paul.  If we don't hide the inline panel, we will get stuck in a endless loop. 
			if ( this.state.showInlineEdit )
			{
				this.setState({ showInlineEdit: false, QUICK_CREATE_MODULE: null });
			}
		}
	}

	/*
	shouldComponentUpdate(nextProps: ITopNavProps, nextState: ITopNavState)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate');
		return true;
	}
	*/

	// 04/29/2019 Paul.  componentWillReact?  Should be componentWillUpdate. 
	async componentWillUpdate(nextProps: ITopNavProps)
	{
		const { bIsAuthenticated, txtQuickSearch } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentWillUpdate', this.props.location.pathname, nextProps.location.pathname, txtQuickSearch);
		// 01/08/2021 Paul.  We needto prevent clearing quick search during reload of unified search. 
		// 05/10/2021 Paul.  Reset not reload. 
		if ( this.props.location.pathname != nextProps.location.pathname && !StartsWith(nextProps.location.pathname, '/UnifiedSearch') && !StartsWith(nextProps.location.pathname, '/Reset/UnifiedSearch') )
		{
			if ( !Sql.IsEmptyString(txtQuickSearch) )
			{
				this.setState( {txtQuickSearch: ''} );
			}
		}
		if ( Credentials.ADMIN_MODE != this.state.adminMode )
		{
			this.setState({ adminMode: Credentials.ADMIN_MODE });
			await this.Load('componentWillUpdate');
		}
		else
		{
			// 05/28/2019 Paul.  Use a passive IsAuthenticated check (instead of active server query), so that we do not have multiple simultaneous requests. 
			// 05/28/2019 Paul.  Track the authentication change so that we an clear the menus appropriately. 
			let bAuthenticated: boolean = Credentials.bIsAuthenticated;
			if ( bIsAuthenticated != bAuthenticated )
			{
				let nMaxTabs          = Crm_Config.ToInteger('atlantic_max_tabs' );
				let nHistoryMaxViewed = Crm_Config.ToInteger('history_max_viewed');
				if ( nMaxTabs == 0 )
				{
					nMaxTabs = 7;
				}
				if ( nHistoryMaxViewed == 0 )
				{
					nHistoryMaxViewed = 10;
				}
				this.setState(
				{
					bIsAuthenticated: bAuthenticated, 
					tabMenus: [], 
					quickCreate: [],
					nMaxTabs: nMaxTabs,
					nHistoryMaxViewed: nHistoryMaxViewed,
				}, async () =>
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentWillUpdate Load');
					await this.Load('componentWillUpdate');
				});
			}
		}
	}

	private Actions = (sMODULE_NAME: string) =>
	{
		const { dashboards, homeDashboards } = this.state;
		let links = new Array();
		let shortcuts: SHORTCUT[] = SplendidCache.Shortcuts(sMODULE_NAME);
		if ( shortcuts != null )
		{
			for ( let i = 0; i < shortcuts.length; i++ )
			{
				let shortcut: SHORTCUT = shortcuts[i];
				if ( shortcut.SHORTCUT_ACLTYPE == 'archive' )
				{
					// 09/26/2017 Paul.  If the module does not have an archive table, then hide the link. 
					let bArchiveEnabled: boolean = Crm_Modules.ArchiveEnabled(shortcut.MODULE_NAME);
					if ( !bArchiveEnabled )
						continue;
				}
				let nSHORTCUT_ACLTYPE = SplendidCache.GetUserAccess(shortcut.MODULE_NAME, shortcut.SHORTCUT_ACLTYPE, this.constructor.name + '.Actions');
				if ( nSHORTCUT_ACLTYPE >= 0 )
				{
					let sDISPLAY_NAME : string = L10n.Term(shortcut.DISPLAY_NAME);
					let sRELATIVE_PATH: string = shortcut.RELATIVE_PATH;
					sRELATIVE_PATH = sRELATIVE_PATH.replace('~/'                         , ''            );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/default.aspx?ArchiveView=1', '/ArchiveView');
					sRELATIVE_PATH = sRELATIVE_PATH.replace('~/Users/reassign.aspx'      , '/Administration/Users/Reassign');
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/default.aspx'              , '/List'       );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/edit.aspx'                 , '/Edit'       );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/import.aspx'               , '/Import'     );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/stream.aspx'               , '/Stream'     );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/sequence.aspx'             , '/Sequence'   );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/statistics.aspx'           , '/Statistics' );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/config.aspx'               , '/Config'     );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/Drafts.aspx'               , '/Drafts'     );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/MyFeeds.aspx'              , '/MyFeeds'    );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/ByUser.aspx'               , '/ByUser'     );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('.aspx'                      , ''            );
					let lnk =
					{
						label      : sDISPLAY_NAME       ,
						key        : sRELATIVE_PATH      ,
						MODULE_NAME: shortcut.MODULE_NAME,
						IMAGE_NAME : shortcut.IMAGE_NAME ,
						command    : this._onAction      ,
					};
					links.push(lnk);
				}
			}
		}
		return links;
	}

	private Favorites = (sMODULE_NAME: string) =>
	{
		let links = SplendidCache.Favorites(sMODULE_NAME);
		if ( links === undefined || links == null )
			return [];
		return links;
	}

	private LastViewed = (sMODULE_NAME: string) =>
	{
		const { nHistoryMaxViewed } = this.state;
		let links = SplendidCache.LastViewed(sMODULE_NAME);
		if ( links === undefined || links == null )
			return [];
		if ( links.length > nHistoryMaxViewed )
			links = links.slice(0, nHistoryMaxViewed);
		return links;
	}

	private ReloadDashboard = async (sCATEGORY) =>
	{
		const { bIsAuthenticated } = this.state;
		// 04/16/2019 Paul.  Must be authenticated to load dashboard. 
		if ( bIsAuthenticated )
		{
			let dashboards = await Dashboards(sCATEGORY);
			if ( sCATEGORY == 'Dashboard' )
			{
				this.setState({ dashboards: dashboards });
			}
			else if ( sCATEGORY == 'Home' )
			{
				this.setState({ homeDashboards: dashboards });
			}
			// 06/02/2017 Paul.  If last dashboard not set, then show the first default dashboard. 
			let sCURRENT_DASHBOARD_ID: string = localStorage.getItem('ReactLast' + sCATEGORY);
			if ( Sql.IsEmptyString(sCURRENT_DASHBOARD_ID) && dashboards != null && dashboards.length > 0 )
			{
				sCURRENT_DASHBOARD_ID = Sql.ToString(dashboards[0]['ID']);
				localStorage.setItem('ReactLast' + sCATEGORY, sCURRENT_DASHBOARD_ID);
			}
		}
	}

	private _onAction = (sMODULE_NAME: string, item) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onAction', item);
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
		{
			this.props.history.push('/Reset/' + item.key);
		});
	}

	private _onFavorite = (sMODULE_NAME: string, item) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onFavorite ' + sMODULE_NAME, item);
		let module:MODULE = SplendidCache.Module(sMODULE_NAME, this.constructor.name + '._onFavorite');
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
		{
			if ( module.IS_ADMIN )
			{
				this.props.history.push('/Reset/Administration/' + sMODULE_NAME + '/View/' + item.ID)
			}
			else
			{
				this.props.history.push('/Reset/' + sMODULE_NAME + '/View/' + item.ID)
			}
		});
	}

	private _onLastViewed = (sMODULE_NAME: string, item) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLastViewed ' + sMODULE_NAME, item);
		let module:MODULE = SplendidCache.Module(sMODULE_NAME, this.constructor.name + '._onLastViewed');
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
		{
			if ( module.IS_ADMIN )
				this.props.history.push('/Reset/Administration/' + sMODULE_NAME + '/View/' + item.ID)
			else
				this.props.history.push('/Reset/' + sMODULE_NAME + '/View/' + item.ID)
		});
	}

	private _onQuickCreate = (sMODULE_NAME: string) =>
	{
		this.setState(
		{
			showInlineEdit     : true,
			QUICK_CREATE_MODULE: sMODULE_NAME,
			menuChangeKey      : this.state.menuChangeKey+1
		});
	}

	private _onModuleClick = (MODULE_NAME) =>
	{
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onModuleClick');
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onModuleClick ' + MODULE_NAME, module);
		if ( module != null )
		{
			// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
			this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
			{
				// 01/23/2021 Paul.  Prevent /Administration/Administration. 
				if ( module.IS_ADMIN && MODULE_NAME != 'Administration' )
				{
					this.props.history.push(`/Reset/Administration/${MODULE_NAME}/`);
				}
				else
				{
					this.props.history.push(`/Reset/${MODULE_NAME}/`);
				}
			});
		}
		else
		{
			console.error(MODULE_NAME + ' is not accessible.');
		}
	}

	private Load = async (source) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', source);
		let sDETAIL_NAME = 'TabMenu';
		if ( Credentials.ADMIN_MODE )
		{
			sDETAIL_NAME = 'TabMenu.Admin';
		}
		let arrQuickCreate = await EditViewRelationships_LoadLayout('Home.EditView');
		let menus: TAB_MENU[] = await TabMenu_Load();
		let result = menus;
		// 05/25/2019 Paul.  The html5 menu is not longer limited to specific modules in the DetailViewRelationships TabMen list. 
		/*
		let arrDetailViewRelationship = await DetailViewRelationships_LoadLayout(sDETAIL_NAME);
		if ( Credentials.ADMIN_MODE )
		{
			result = arrDetailViewRelationship;
			for (let i = 0; i < result.length; i++)
			{
				result[i].DISPLAY_NAME = '.moduleList.' + result[i].MODULE_NAME;
				result[i].RELATIVE_PATH = '/Administration/' + result[i].MODULE_NAME + '/';
			}
		}
		let arrValidModules = new Object();
		for (let i = 0; i < arrDetailViewRelationship.length; i++)
		{
			arrValidModules[arrDetailViewRelationship[i].MODULE_NAME] = null;
		}
		*/
		//if (Object.keys(arrValidModules).length > 0)
		{
			let tabMenus: TAB_MENU[] = [];
			// 06/16/2019 Paul.  The logo is the home link. 
			if ( menus != null )
			{
				for ( let nTab = 0; nTab < menus.length; nTab++ )
				{
					var sMODULE_NAME = menus[nTab].MODULE_NAME;
					if ( sMODULE_NAME != 'Home' )
					{
						tabMenus.push(menus[nTab]);
					}
				}
			}
			/*
			let tabMenus = result.filter((tabMenu: TAB_MENU) =>
			{
				if ( arrValidModules[tabMenu.MODULE_NAME] !== undefined )
				{
					return tabMenu;
				}
			});
			*/
			let quickCreate: any[] = [];
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load arrQuickCreate', arrQuickCreate);
			// 05/27/2019 Paul.  MODULES will be null when not authenticated. 
			if ( arrQuickCreate != null && SplendidCache.MODULES != null )
			{
				for (let i = 0; i < arrQuickCreate.length; i++ )
				{
					let detailRelate = arrQuickCreate[i];
					let nSHORTCUT_ACLTYPE = SplendidCache.GetUserAccess(detailRelate.MODULE_NAME, 'edit', this.constructor.name + '.load');
					if ( nSHORTCUT_ACLTYPE >= 0 )
					{
						try
						{
							let tabMenu: any = {};
							tabMenu.MODULE_NAME    = detailRelate.MODULE_NAME;
							tabMenu.DISPLAY_NAME   = L10n.Term(tabMenu.MODULE_NAME + ".LNK_NEW_" + Crm_Modules.SingularTableName(Crm_Modules.TableName(tabMenu.MODULE_NAME)));
							tabMenu.RELATIVE_PATH  = null;
							tabMenu.EDIT_ACLACCESS = SplendidCache.GetUserAccess(detailRelate.MODULE_NAME, 'edit');
							tabMenu.EDIT_LABEL     = null;
							quickCreate.push(tabMenu);
						}
						catch(error)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Load quickCreate error', error);
						}
					}
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load tabMenus', tabMenus);
			// 01/10/2022 Paul.  Don't show if search panels empty. 
			let unifiedSearchItems: number = 0;
			let layout = SplendidCache.DetailViewRelationships('Home.UnifiedSearch');
			if ( layout != null )
				unifiedSearchItems = layout.length;
			this.setState({ tabMenus: tabMenus, quickCreate: quickCreate, unifiedSearchItems });
			if ( tabMenus != null && SplendidCache.MODULES != null )
			{
				for (let nTab = 0; nTab < tabMenus.length; nTab++)
				{
					var sMODULE_NAME = tabMenus[nTab].MODULE_NAME;
					if (sMODULE_NAME == 'Dashboard' || sMODULE_NAME == 'Home')
					{
						await this.ReloadDashboard(sMODULE_NAME);
					}
				}
			}
		}
	}

	private toggle = () =>
	{
		this.setState({
			isOpen: !this.state.isOpen
		});
	}

	private _onUnifiedSearch = () =>
	{
		const { txtQuickSearch } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUnifiedSearch', txtQuickSearch);
		// 05/10/2021 Paul.  Must reset. 
		this.props.history.push('/Reset/UnifiedSearch/' + encodeURIComponent(txtQuickSearch));
	}

	private _onQuickSearchChange = (e) =>
	{
		let value = e.target.value;
		this.setState( {txtQuickSearch: value} );
	}

	private _onUserProfile = () =>
	{
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
		{
			this.props.history.push('/Reset/Users/MyAccount');
		});
	}

	private _onEmployees = () =>
	{
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
		{
			this.props.history.push('/Reset/Employees');
		});
	}

	private _onAdminPage = () =>
	{
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
		{
			this.props.history.push('/Reset/Administration');
		});
	}

	// 04/16/2021 Paul.  Provide quick acces to classic admin page. 
	private _onAdminClassicPage = () =>
	{
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
		{
			window.open(Credentials.RemoteServer + 'Administration', 'SplendidClassicAdmin');
		});
	}

	private _onSystemLog = () =>
	{
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
		{
			this.props.history.push('/Reset/Administration/SystemLog');
		});
	}

	private _onAbout = () =>
	{
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
		{
			this.props.history.push('/Reset/Home/About');
		});
	}

	private _onTrainingPortal = () =>
	{
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
		{
			this.props.history.push('/Reset/Home/TrainingPortal');
		});
	}

	private _onLogout = async () =>
	{
		try
		{
			// 09/04/2020 Paul.  Callback not firing on android, so set state before logout. 
			this.setState(
			{
				bIsAuthenticated: false, 
				tabMenus        : [], 
				quickCreate     : [],
				menuChangeKey   : this.state.menuChangeKey+1
			});
			// 06/23/2019 Paul.  Logout will return false when ADFS performs a logout. 
			// 09/04/2020 Paul.  Even after ADFS logout, we should still go to login page. 
			let status = await Logout();
			//if ( status )
			{
				LoginRedirect(this.props.history, this.constructor.name + '._onLogout');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onLogout', error);
		}
	}

	private _onKeyDown = (event) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' )
		{
			this._onUnifiedSearch();
		}
		return false;
	}

	private _onTabTitleClick = (tabMenu) =>
	{
		let MODULE_NAME: string = tabMenu.MODULE_NAME;
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onTabTitleClick');
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTabTitleClick ' + MODULE_NAME, module);
		if ( module != null )
		{
			// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
			// 08/21/2020 Paul.  We don't want to hide the menu for the title click.  
			//this.setState({ menuChangeKey: this.state.menuChangeKey+1 }, () =>
			//{
				// 01/23/2021 Paul.  Prevent /Administration/Administration. 
				if ( module.IS_ADMIN && MODULE_NAME != 'Administration' )
				{
					this.props.history.push(`/Reset/Administration/${MODULE_NAME}/`);
				}
				else
				{
					this.props.history.push(`/Reset/${MODULE_NAME}/`);
				}
			//});
		}
		else
		{
			console.error(MODULE_NAME + ' is not accessible.');
		}
	}

	private TabTitle = (activeModule, tabMenu) =>
	{
		// 06/30/2021 Paul.  Provide the URL to the module so that right-click-new-tab would navigate to the correct location. 
		// 07/08/2023 Paul.  ASP.NET Core will not have /React in the base. 
		return <a
			className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'TabLink' }
			href={ Credentials.RemoteServer + Credentials.ReactBase + tabMenu.MODULE_NAME }
			style={ { textDecoration: 'none'} }
			onClick={ (e) => { e.preventDefault(); this._onTabTitleClick(tabMenu); } }>
			{ L10n.Term(tabMenu.DISPLAY_NAME) }
		</a>;
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { showInlineEdit } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		try
		{
			if ( this._isMounted )
			{
				if ( sCommandName == 'Create' || EndsWith(sCommandName, '.Create') )
				{
					this.setState({ showInlineEdit: !showInlineEdit, QUICK_CREATE_MODULE: null });
				}
				else if ( sCommandName == 'NewRecord' )
				{
					await this.Save();
				}
				else if ( sCommandName == 'NewRecord.Cancel' )
				{
					this.setState({ showInlineEdit: false, QUICK_CREATE_MODULE: null });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private Save = async () =>
	{
		const { QUICK_CREATE_MODULE } = this.state;
		try
		{
			if ( this.editView.current != null && this.editView.current.validate() )
			{
				let row: any = this.editView.current.data;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Save ' + QUICK_CREATE_MODULE, row);
				try
				{
					let sID = await UpdateModule(QUICK_CREATE_MODULE, row, null);
					if ( this.dynamicButtonsTop.current != null )
					{
						this.dynamicButtonsTop.current.EnableButton('NewRecord', false);
						// 06/03/2021 Paul.  Show and hide busy while saving new record. 
						this.dynamicButtonsTop.current.Busy();
					}
					if ( this._isMounted )
					{
						// 07/18/2019 Paul.  We also need to clear the input fields. 
						if ( this.editView.current != null )
						{
							this.editView.current.clear();
						}
						// 03/17/2020 Paul.  Set the state after clearing the form, otherwise this.editView.current will be null. 
						// 03/17/2020 Paul.  Clear the local item as well. 
						this.setState({ showInlineEdit: false, item: {}, QUICK_CREATE_MODULE: null });
					}
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Save', error);
					if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
					{
						if ( this.dynamicButtonsTop.current != null )
						{
							this.dynamicButtonsTop.current.ShowButton('SaveDuplicate', true);
						}
						this.setState( {error: L10n.Term(error.message) } );
					}
					else
					{
						this.setState({ error });
					}
				}
				finally
				{
					if ( this.dynamicButtonsTop.current != null )
					{
						this.dynamicButtonsTop.current.EnableButton('NewRecord', true);
						// 06/03/2021 Paul.  Show and hide busy while saving new record. 
						this.dynamicButtonsTop.current.NotBusy();
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Save', error);
			this.setState({ error });
		}
	}

	private editViewCallback = (key, newValue) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.editViewCallback ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.item;
		if ( item == null )
			item = {};
		item[key] = newValue;
		if ( this._isMounted )
		{
			this.setState({ item });
		}
	}

	public render()
	{
		const { tabMenus, quickCreate, bIsAuthenticated, txtQuickSearch, nMaxTabs, showInlineEdit, item, error, QUICK_CREATE_MODULE, activeModule, menuChangeKey, unifiedSearchItems } = this.state;
	
		//03/06/2019. Chase. Referencing ADMIN_MODE triggers re-renders when it's updated;
		Credentials.ADMIN_MODE;
		// 04/29/2019 Paul.  When FAVORITES, LAST_VIEWED or SAVED_SEARCH changes, increment this number.  It is watched in the TopNav. 
		SplendidCache.NAV_MENU_CHANGE;

		let themeURL: string = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
		let moreIcon = <span className="tabToolbarFrame" style={ {borderSpacing: 0, padding: 0} }>
			<span className="otherTab" style={ {paddingTop: 6} }>
				<span className="otherTabLink">{ L10n.Term('.LBL_MORE') }</span>
				<FontAwesomeIcon icon="sort-down" size="lg" style={ {marginLeft: '6px', marginTop: '8px'} } />
			</span>
		</span>;
		let userName = <span className="otherTab" style={ {paddingTop: 6} }>
			{ Security.IsImpersonating()
			? <span className="otherTabLink">{ L10n.Term('Users.LBL_IMPERSONATING') }<br /></span>
			: null
			}
			<span className="otherTabLink">{ Security.FULL_NAME() }</span>
			<FontAwesomeIcon icon="sort-down" size="lg" style={ {marginLeft: '6px', marginTop: '8px'} } />
		</span>;

		let cssBackground: any = null;
		if ( !Sql.IsEmptyString(Crm_Config.ToString('header_background')) )
		{
			cssBackground = { backgroundImage: 'url(' + themeURL + Crm_Config.ToString('header_background') + ')'};
		}
		let itemsNav = [];
		let moreItems = [];
		let userContextMenu: any = [];
		let quickCreateIcon = <span style={ {color: '#003564', fontSize: '13px', paddingBottom: '15px'} }>
			<FontAwesomeIcon icon="plus" size="lg" />
			<FontAwesomeIcon icon="sort-down" size="lg" style={ {paddingLeft: '2px', paddingBottom: '4px', fontSize: '20px'} } />
		</span>;
		let bLoading = StartsWith(this.props.location.pathname, '/Reload');
		if ( SplendidCache.IsInitialized && bIsAuthenticated && !bLoading && tabMenus != null )
		{
			let tabsPrimary = tabMenus;
			let tabsSecondary = [];
			if ( tabMenus.length > nMaxTabs )
			{
				tabsPrimary   = tabMenus.slice(0, nMaxTabs);
				tabsSecondary = tabMenus.slice(nMaxTabs, tabMenus.length);
			}
			// 09/16/2019 Paul.  If active module is in secondary, then remove and place at the end of the primary. 
			if ( !Sql.IsEmptyString(activeModule) )
			{
				let nPrimaryActive  : number = -1;
				let nSecondaryActive: number = -1;
				for ( let i = 0; i < tabsPrimary.length; i++ )
				{
					if ( tabsPrimary[i].MODULE_NAME == activeModule )
					{
						nPrimaryActive = i;
						break;
					}
				}
				for ( let i = 0; i < tabsSecondary.length; i++ )
				{
					if ( tabsSecondary[i].MODULE_NAME == activeModule )
					{
						nSecondaryActive = i;
						break;
					}
				}
				if ( nSecondaryActive >= 0 )
				{
					let tabActive: TAB_MENU[] = tabsSecondary.splice(nSecondaryActive, 1);
					if ( tabActive.length > 0 )
					{
						if ( tabsPrimary.length > 0 )
						{
							tabsSecondary.unshift(tabsPrimary.pop());
						}
						tabsPrimary.push(tabActive[0]);
					}
				}
				// 10/27/2019 Paul.  If not in primary or secondary, then manually add. 
				// 02/23/2020 Paul.  Don't add Home as icon on menu bar is the home link. 
				else if ( nPrimaryActive == -1 && activeModule != 'Home' )
				{
					let module: MODULE = SplendidCache.Module(activeModule, this.constructor.name + '.render');
					if ( module != null )
					{
						let activeMenu: TAB_MENU = 
						{
							MODULE_NAME   : module.MODULE_NAME,
							DISPLAY_NAME  : module.DISPLAY_NAME,
							RELATIVE_PATH : module.RELATIVE_PATH,
							EDIT_ACLACCESS: SplendidCache.GetUserAccess(module.MODULE_NAME, 'edit'),
							EDIT_LABEL    : null,
						};
						if ( tabsPrimary.length > 0 )
						{
							tabsSecondary.unshift(tabsPrimary.pop());
						}
						tabsPrimary.push(activeMenu);
					}
				}
			}
			// 09/23/2020 Paul.  tabToolbarFrame with 100% is having an issue.  Instead, just embed the styles. 
			itemsNav = tabsPrimary.map((tabMenu) =>
			(
				<table className="" style={ {border: 'none', borderCollapse: 'collapse', borderSpacing: 0, height: '45px', padding: 0} }>
					<tbody><tr>
						<td className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'Tab' } style={ {whiteSpace: 'nowrap', paddingLeft: '5px', paddingRight: '5px', paddingBottom: '15px'} }>
							<NavItem title={ this.TabTitle(activeModule, tabMenu) } id={ tabMenu.MODULE_NAME } key={ tabMenu.MODULE_NAME } className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'TabLink' }>
								<div className="ModuleActionsInnerTable" style={ {display: 'flex', flexDirection: 'row'} }>
									<div className="ModuleActionsInnerCell">
										<div className="ModuleActionsInnerHeader" style={ {fontWeight: 'bold'} }>{ L10n.Term('.LBL_ACTIONS') }</div>
										{
											this.Actions(tabMenu.MODULE_NAME).map((item) => 
											(
												<NavDropdown.Item key={ 'action_' + item.key } className="ModuleActionsMenuItems" onClick={(e) => this._onAction(item.MODULE_NAME, item)}>{ item.label }</NavDropdown.Item>
											))
										}
									</div>
									<div className="ModuleActionsInnerCell">
										<div className="ModuleActionsInnerHeader" style={ {fontWeight: 'bold'} }>{ L10n.Term('.LBL_FAVORITES') }</div>
										{ this.Favorites(tabMenu.MODULE_NAME).length > 0
										? this.Favorites(tabMenu.MODULE_NAME).map((item) => 
											(
												<NavDropdown.Item key={ 'fav_' + item.ID } className="ModuleActionsMenuItems" onClick={(e) => this._onFavorite(tabMenu.MODULE_NAME, item)}>{ item.NAME }</NavDropdown.Item>
											))
										: <span>{ L10n.Term('.LBL_LINK_NONE') }</span>
										}
									</div>
									<div className="ModuleActionsInnerCell">
										<div className="ModuleActionsInnerHeader" style={ {fontWeight: 'bold'} }>{ L10n.Term('.LBL_LAST_VIEWED') }</div>
										{ this.LastViewed(tabMenu.MODULE_NAME).length > 0
										? this.LastViewed(tabMenu.MODULE_NAME).map((item) => 
											(
												<NavDropdown.Item key={ 'last_' + item.ID } className="ModuleActionsMenuItems" onClick={(e) => this._onLastViewed(tabMenu.MODULE_NAME, item)}>{ item.NAME }</NavDropdown.Item>
											))
										: <span>{ L10n.Term('.LBL_LINK_NONE') }</span>
										}
									</div>
								</div>
							</NavItem>
						</td>
					</tr></tbody>
				</table>
			));
			// 06/30/2021 Paul.  Provide the URL to the module so that right-click-new-tab would navigate to the correct location. 
			moreItems = tabsSecondary.map((tabMenu) => (
				<a className="otherTabMoreLink" href={ Credentials.RemoteServer + Credentials.ReactBase + tabMenu.MODULE_NAME } style={ {minWidth: '10rem'} } onClick={ (e) => { e.preventDefault(); this._onModuleClick(tabMenu.MODULE_NAME); } }>{ L10n.Term(tabMenu.DISPLAY_NAME) }</a>
			));
			// 07/15/2021 Paul.  Now that we are caching the ReactState, we need an end-user way to clear the cache even when using Windows authentication.  So alway show logout. 
			userContextMenu = (
				<Nav className="ml-auto" navbar style={ {flexGrow: 0, borderLeft: '1px solid black', borderRight: '1px solid black'} }>
					<NavItem title={ userName } id="usercontextmenu" key="usercontextmenu" style={ {paddingLeft: '0px', paddingRight: '0px', paddingBottom: '15px'} }>
						{ bIsAuthenticated                                                            ? <NavDropdown.Item key="usercontext-myprofile"    className="ModuleActionsMenuItems" onClick={() => this._onUserProfile()      }>{ L10n.Term('.LBL_MY_ACCOUNT'   ) }</NavDropdown.Item> : null }
						{ bIsAuthenticated && SplendidCache.GetUserAccess("Employees", "access") >= 0 ? <NavDropdown.Item key="usercontext-employees"    className="ModuleActionsMenuItems" onClick={() => this._onEmployees()        }>{ L10n.Term('.LBL_EMPLOYEES'    ) }</NavDropdown.Item> : null }
						{ bIsAuthenticated && (Security.IS_ADMIN() || Security.IS_ADMIN_DELEGATE())   ? <NavDropdown.Item key="usercontext-admin"        className="ModuleActionsMenuItems" onClick={() => this._onAdminPage()        }>{ L10n.Term('.LBL_ADMIN'        ) }</NavDropdown.Item> : null }
						{ bIsAuthenticated && (Security.IS_ADMIN() || Security.IS_ADMIN_DELEGATE()) && !Crm_Config.ToBoolean('disable_admin_classic') ? <NavDropdown.Item key="usercontext-adminclassic" className="ModuleActionsMenuItems" onClick={() => this._onAdminClassicPage() }>{ L10n.Term('.LBL_ADMIN_CLASSIC') }</NavDropdown.Item> : null }
						{ bIsAuthenticated && !Crm_Config.ToBoolean('hide_training')                  ? <NavDropdown.Item key="usercontext-training"     className="ModuleActionsMenuItems" onClick={() => this._onTrainingPortal()   }>{ L10n.Term('.LBL_TRAINING'     ) }</NavDropdown.Item> : null }
						{ bIsAuthenticated && Security.IS_ADMIN() && false                            ? <NavDropdown.Item key="usercontext-systemlog"    className="ModuleActionsMenuItems" onClick={() => this._onSystemLog()        }>{ L10n.Term('.LBL_SYSTEM_LOG'   ) }</NavDropdown.Item> : null }
						                                                                                <NavDropdown.Item key="usercontext-about"        className="ModuleActionsMenuItems" onClick={() => this._onAbout()            }>{ L10n.Term('.LNK_ABOUT'        ) }</NavDropdown.Item>
						{ bIsAuthenticated                                                            ? <NavDropdown.Item key="usercontext-logout"       className="ModuleActionsMenuItems" onClick={() => this._onLogout()           }>{ L10n.Term('.LBL_LOGOUT'       ) }</NavDropdown.Item> : null }
					</NavItem>
				</Nav>
			);
		}
		if ( SplendidCache.IsInitialized )
		{
			// 04/16/2020 Paul.  Use logo from config. 
			let sCompanyHomeImage: string = Crm_Config.ToString('header_home_image');
			// 10/28/2021 Paul.  Allow logo to be stored in config table as base64. 
			if ( !StartsWith(sCompanyHomeImage, 'data:image/') )
			{
				if ( Sql.IsEmptyString(sCompanyHomeImage) )
					sCompanyHomeImage = '~/Include/images/SplendidCRM_Icon.gif';
				if ( StartsWith(sCompanyHomeImage, '~/' ) )
					sCompanyHomeImage = sCompanyHomeImage.replace('~/', Credentials.RemoteServer);
			}
			return (
<React.Fragment>
<div id="divHeader" style={ {height: '52px'} }>
	<div id="divSixToolbar" className='SixToolbar'>
		<Navbar key={ 'divSixToolbar_' + menuChangeKey.toString() } bg="light" variant="light" expand="md" id="topnav" style={ {padding: 0, ...cssBackground} }>
			<Navbar.Toggle onClick={ this.toggle } aria-controls="topnav-nav" />
			<Navbar.Collapse id='topnav-nav' className="otherTabRight" >
				<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onModuleClick('Home') } title={ L10n.Term('.moduleList.Home') }><img src={ sCompanyHomeImage } style={ {borderWidth: 0, width: 42, height: 42} } /></span>
				<Nav navbar>
					{ itemsNav }
				</Nav>
				{ moreItems.length > 0
				? <Navbar.Collapse id="topnav-nav-more" className='otherTabRight' style={ {flexGrow: 0, paddingLeft: '5px', paddingRight: '5px', paddingBottom: '15px'} }>
						<Nav navbar>
							<NavItem title={ moreIcon } id="moreicon" key="moreicon">
								{ moreItems }
							</NavItem>
						</Nav>
					</Navbar.Collapse>
				: null
				}
				{ unifiedSearchItems > 0
				? <div id="ctlSixToolbar_cntUnifiedSearch" style={ {flexGrow: 1} }>
					<div id="divUnifiedSearch" style={ {whiteSpace: 'nowrap'} }>
						&nbsp;
						<input name="txtUnifiedSearch"
							type="text"
							id="ctlSixToolbar_txtUnifiedSearch"
							className="searchField"
							size={ 30 }
							onKeyDown={ this._onKeyDown }
							value={ txtQuickSearch }
							onChange={ this._onQuickSearchChange }
						/>
						&nbsp;
						<input type="image"
							name="btnUnifiedSearch"
							id="ctlSixToolbar_btnUnifiedSearch"
							className="searchButton"
							src={ themeURL + "images/searchButton.gif" }
							alt={ L10n.Term(".LBL_SEARCH") }
							onClick={ this._onUnifiedSearch }
							style={ {borderWidth: '0px', height: '20px', width: '25px', verticalAlign: 'middle'} }
							/>
						&nbsp;&nbsp;&nbsp;
					</div>
				</div>
				: null
				}
				{ userContextMenu }
				{ bIsAuthenticated && !bLoading && quickCreate.length > 0
				? <Navbar.Collapse id="topnav-nav-quickcreate" style={ {flexGrow: 0, padding: 0} }>
						<Nav className="ml-auto" navbar>
							<NavItem title={ quickCreateIcon } id="quickcreate" key="quickcreate" alignRight>
							{
								quickCreate.map((item) => 
								(
									<NavDropdown.Item key={ 'quick_' + item.MODULE_NAME } onClick={() => this._onQuickCreate(item.MODULE_NAME)}>{ item.DISPLAY_NAME }</NavDropdown.Item>
								))
							}
							</NavItem>
						</Nav>
					</Navbar.Collapse>
				: null
				}
			</Navbar.Collapse>
		</Navbar>
	</div>
</div>
	{ showInlineEdit && QUICK_CREATE_MODULE
	? <div style={ {padding: '.5em'} }>
		<div style={{ marginBottom: '.2em' }}>
			<DynamicButtons
				ButtonStyle="EditHeader"
				VIEW_NAME="NewRecord.WithCancel"
				row={ null }
				Page_Command={ this.Page_Command }
				history={ this.props.history }
				location={ this.props.location }
				match={ this.props.match }
				ref={ this.dynamicButtonsTop }
			/>
			<ErrorComponent error={error} />
		</div>
		<div className='tabForm' style={ {width: '100%', marginBottom: '4px'} }>
			<h4>{ L10n.Term(QUICK_CREATE_MODULE + '.LBL_NEW_FORM_TITLE') }</h4>
			<DynamicEditView
				key={ QUICK_CREATE_MODULE + '.EditView.Inline' }
				MODULE_NAME={ QUICK_CREATE_MODULE }
				LAYOUT_NAME={ QUICK_CREATE_MODULE + '.EditView.Inline' }
				rowDefaultSearch={ item }
				isQuickCreate={ true }
				callback={ this.editViewCallback }
				history={ this.props.history }
				location={ this.props.location }
				match={ this.props.match }
				ref={ this.editView }
			/>
		</div>
	</div>
	: null
	}
	<div id="ctlReminders">
		<input type="submit" name="btnREMINDER_UPDATE" value="Update" id="ctlReminders_btnREMINDER_UPDATE" className='button' style={ {display: 'none'} } />
		<span id="ctlReminders_lblScripts"></span>
	</div>
</React.Fragment>
			);
		}
		else
		{
			let logoTitle : string = Sql.IsEmptyString(Crm_Config.ToString('company_name'      )) ? 'SplendidCRM Software, Inc.' : Crm_Config.ToString('company_name'      );
			let logoUrl   : string = Sql.IsEmptyString(Crm_Config.ToString('header_logo_image' )) ? 'SplendidCRM_Logo.gif'       : Crm_Config.ToString('header_logo_image' );
			let logoWidth : string = Sql.IsEmptyString(Crm_Config.ToString('header_logo_width' )) ? '207px'                      : Crm_Config.ToString('header_logo_width' );
			let logoHeight: string = Sql.IsEmptyString(Crm_Config.ToString('header_logo_height')) ? '60px'                       : Crm_Config.ToString('header_logo_height');
			// 02/17/2020 Paul.  We do not want to parse the style at this time, so just ignore the value. 
			let logoStyle : string = Crm_Config.ToString('arctic_header_logo_style');
			// 10/28/2021 Paul.  Allow logo to be stored in config table as base64. 
			if ( !StartsWith(logoUrl, 'data:image/') )
			{
				if ( !StartsWith(logoUrl, '~/') && !StartsWith(logoUrl, 'http') )
				{
					logoUrl = '~/Include/images/' + logoUrl;
				}
				// 08/28/2020 Paul.  Android is having trouble loading image from file system, so use base64. 
				if ( Credentials.RemoteServer == '' )
					logoUrl = Credentials.SplendidCRM_Logo;
				else
					logoUrl = logoUrl.replace('~/', Credentials.RemoteServer);
			}
			return (
<div id="ctl00_divHeader">
	<table className="SixToolbarLogin" cellSpacing="0" cellPadding="0" style={ {border: 'collapse'} }>
		<tr>
			<td style={ {whiteSpace: 'nowrap'} }>
				<table id="ctl00_tblLoginHeader" className="tabToolbarFrame" cellSpacing="0" cellPadding="0" style={ {border: 'collapse'} }>
					<tr>
						<td>
							<img id="ctl00_imgCompanyLogo" title={ logoTitle } src={ logoUrl } style={ {height: logoHeight, width: logoWidth, borderWidth: '0px'} } />
						</td>
					</tr>
				</table>
			</td>
			<td className="tabRow" style={ {width: '99%'} }>
				&nbsp;
			</td>
		</tr>
	</table>
</div>
			);
		}
	}
}

export default withRouter(SevenTopNav_Desktop);

