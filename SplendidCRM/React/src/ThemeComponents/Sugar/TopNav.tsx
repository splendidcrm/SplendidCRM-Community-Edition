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
import { RouteComponentProps, withRouter }              from 'react-router-dom'                   ;
import { observer }                                     from 'mobx-react'                         ;
// 2. Store and Types. 
import MODULE                                           from '../../types/MODULE'                 ;
import TAB_MENU                                         from '../../types/TAB_MENU'               ;
import SHORTCUT                                         from '../../types/SHORTCUT'               ;
// 3. Scripts. 
import Sql                                              from '../../scripts/Sql'                  ;
import L10n                                             from '../../scripts/L10n'                 ;
import Security                                         from '../../scripts/Security'             ;
import SplendidCache                                    from '../../scripts/SplendidCache'        ;
import Credentials                                      from '../../scripts/Credentials'          ;
import { TabMenu_Load }                                 from '../../scripts/TabMenu'              ;
import { Crm_Config, Crm_Modules }                      from '../../scripts/Crm'                  ;
import { Logout, LoginRedirect }                        from '../../scripts/Login'                ;
import { Dashboards }                                   from '../../scripts/Dashboard'            ;
import { EditViewRelationships_LoadLayout }             from '../../scripts/EditViewRelationships';
import { StartsWith, EndsWith, ActiveModuleFromPath, isTouchDevice, screenWidth } from '../../scripts/utility'         ;
// 4. Components and Views.


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
	item?              : any;
	dependents?        : Record<string, Array<any>>;
	error?             : any;
	activeModule       : string;
	menuChangeKey      : number;  // 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
	actionsModule      : string;
	showUnifiedSearch  : boolean;
	showQuickCreate    : boolean;
	unifiedSearchItems : number;  // 01/10/2022 Paul.  Don't show if search panels empty. 
}

@observer
class SugarTopNav extends React.Component<ITopNavProps, ITopNavState>
{
	private _isMounted = false;

	private ctlSixToolbar        = React.createRef<HTMLDivElement>();
	private pnlTabHover          = React.createRef<HTMLDivElement>();
	private tabMenuRect          : Record<string, DOMRect> = {};
	private themeURL             : string;
	private tabsPrimary          : TAB_MENU[] = [];
	private tabsSecondary        : TAB_MENU[] = [];

	constructor(props: ITopNavProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
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
			nMaxTabs           : 12,
			nHistoryMaxViewed  : 10,
			activeModule       ,
			menuChangeKey      : 0,
			actionsModule      : null,
			showUnifiedSearch  : true,
			showQuickCreate    : true,
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
		window.addEventListener("resize", this.updateDimensions);
		window.addEventListener("mouseover", this.windowMouseOver);
	}

	componentWillUnmount()
	{
		this._isMounted = false;
		window.removeEventListener("resize", this.updateDimensions);
		window.removeEventListener("mouseover", this.windowMouseOver);
	}

	// 07/31/2021 Paul.  Use the window mouse over event to hide menu. 
	private windowMouseOver = (event) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.windowMouseOver', event);
		this.moduleTabMouseOut(event, null);
	}

	private updateDimensions = () =>
	{
		let { nMaxTabs, showUnifiedSearch, showQuickCreate } = this.state;
		let width : number = screenWidth();
		// 04/26/2021 Paul.  Always based tabs on space available. 
		//if ( width < (75 + nMaxTabs * 75 ) )
		{
			nMaxTabs = Math.floor((width - 75) / 75);
			if ( nMaxTabs < 1 )
			{
				showUnifiedSearch = false;
				showQuickCreate   = false;
				nMaxTabs = 1;
			}
		}
		this.setState(
		{
			nMaxTabs         ,
			showUnifiedSearch,
			showQuickCreate  ,
		});
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
				let nMaxTabs         : number  = Crm_Config.ToInteger('max_tabs'          );
				let nHistoryMaxViewed: number  = Crm_Config.ToInteger('history_max_viewed');
				let showUnifiedSearch: boolean = true;
				let showQuickCreate  : boolean = true;
				if ( nMaxTabs == 0 )
				{
					nMaxTabs = 7;
				}
				if ( nHistoryMaxViewed == 0 )
				{
					nHistoryMaxViewed = 10;
				}
				let width : number = screenWidth();
				// 04/25/2021 Paul.  Try and determine the maxinum number of tabs. 
				// Allocate 100 for more and 150 for unified search. 
				// 04/26/2021 Paul.  Always based tabs on space available. 
				//if ( width < (75 + nMaxTabs * 75 ) )
				{
					nMaxTabs = Math.floor((width - 75) / 75);
					if ( nMaxTabs < 1 )
					{
						showUnifiedSearch = false;
						showQuickCreate   = false;
						nMaxTabs = 1;
					}
				}
				this.setState(
				{
					bIsAuthenticated : bAuthenticated, 
					tabMenus         : [], 
					quickCreate      : [],
					nMaxTabs         ,
					nHistoryMaxViewed,
					showUnifiedSearch,
					showQuickCreate  ,
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

	private _onModuleClick = (MODULE_NAME) =>
	{
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onModuleClick');
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onModuleClick ' + MODULE_NAME, module);
		// 04/26/2021 Paul.  Reports and ReportDesigner can be used interchangeably, but only one can be in the SYSTEM_REST_TABLES. 
		if ( module == null )
		{
			if ( MODULE_NAME == 'ReportDesigner' )
			{
				module = SplendidCache.Module('Reports', this.constructor.name + '._onModuleClick');
			}
			else if ( MODULE_NAME == 'Reports' )
			{
				module = SplendidCache.Module('ReportDesigner', this.constructor.name + '._onModuleClick');
			}
		}
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
			let tabMenus: TAB_MENU[] = menus;
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
							tabMenu.DISPLAY_NAME   = L10n.Term(tabMenu.MODULE_NAME + '.LNK_NEW_' + Crm_Modules.SingularTableName(Crm_Modules.TableName(tabMenu.MODULE_NAME)));
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
		this.props.history.push('/Reset/UnifiedSearch/' + encodeURIComponent(txtQuickSearch));
	}

	private _onQuickSearchChange = (e) =>
	{
		let value = e.target.value;
		this.setState( {txtQuickSearch: value} );
	}

	private _onUserProfile = () =>
	{
		this.props.history.push('/Reset/Users/MyAccount');
	}

	private _onEmployees = () =>
	{
		this.props.history.push('/Reset/Employees');
	}

	private _onAdminPage = () =>
	{
		this.props.history.push('/Reset/Administration');
	}

	// 04/16/2021 Paul.  Provide quick acces to classic admin page. 
	private _onAdminClassicPage = () =>
	{
		window.open(Credentials.RemoteServer + 'Administration', 'SplendidClassicAdmin');
	}

	private _onSystemLog = () =>
	{
		this.props.history.push('/Reset/Administration/SystemLog');
	}

	private _onAbout = () =>
	{
		this.props.history.push('/Reset/Home/About');
	}

	private _onTrainingPortal = () =>
	{
		this.props.history.push('/Reset/Home/TrainingPortal');
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

	private lastMenuChange: number = (new Date()).getTime();

	private moduleTabMouseOver = (event, MODULE_NAME) =>
	{
		this.lastMenuChange = (new Date()).getTime();
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moduleTabMouseOver ' + MODULE_NAME, event);
		if ( this.state.actionsModule != null && (MODULE_NAME == 'leadingblank' || MODULE_NAME == 'trailingblank' || MODULE_NAME != 'more') )
		{
			this.setState({ actionsModule: null, menuChangeKey: this.state.menuChangeKey+1 });
		}
		else if ( this.state.actionsModule != MODULE_NAME && MODULE_NAME == 'more' )
		{
			this.setState({ actionsModule: MODULE_NAME, menuChangeKey: this.state.menuChangeKey+1 });
		}
	}

	private moduleTabMouseOut = (event, MODULE_NAME) =>
	{
		if ( this.state.actionsModule != null && this.ctlSixToolbar.current && this.pnlTabHover.current )
		{
			let rectMenu = this.tabMenuRect[MODULE_NAME];
			let rect = this.pnlTabHover.current.getBoundingClientRect();
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moduleTabMouseOut (' + event.clientX + ', ' + event.clientY + ')', rect, rectMenu);
			if ( event.clientY > rect.top )
			{
				if ( event.clientX < rect.left || event.clientX > rect.right || event.clientY > rect.bottom )
				{
					this.setState({ actionsModule: null, menuChangeKey: this.state.menuChangeKey+1 });
				}
			}
			else if ( event.clientY < rectMenu.top )
			{
				this.setState({ actionsModule: null, menuChangeKey: this.state.menuChangeKey+1 });
			}
		}
	}

	private moduleTabClick = (MODULE_NAME) =>
	{
		let thisMenuChange: number = (new Date()).getTime();
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moduleTabClick ' + MODULE_NAME);
		if ( this.state.actionsModule != MODULE_NAME && MODULE_NAME == 'more' )
		{
			this.setState({ actionsModule: MODULE_NAME, menuChangeKey: this.state.menuChangeKey+1 });
		}
		// 05/04/2021 Paul.  Don't close if it was just opened. On slow Samsung tablet, seems to take 111 milliseconds. 
		else if ( this.state.actionsModule == MODULE_NAME && (thisMenuChange - this.lastMenuChange > 300))
		{
			this.setState({ actionsModule: null, menuChangeKey: this.state.menuChangeKey+1 });
		}
		this.lastMenuChange = (new Date()).getTime();
	}

	private moduleTabRef = (element, MODULE_NAME) =>
	{
		if ( element != null )
		{
			let rect = element.getBoundingClientRect();
			// 07/30/2021 Paul.  No need to make corrections here as we get the rect again inside moduleDropdown. 
			this.tabMenuRect[MODULE_NAME] = rect;
		}
	}

	private moduleDropdown = (MODULE_NAME) =>
	{
		let rect = this.tabMenuRect[MODULE_NAME];
		// 07/30/2021 Paul.  dropdown is appearing in random locations, so try to get just before display. 
		let element = document.getElementById('ctlSixToolbar_tabToolbar_' + MODULE_NAME)
		if ( element  != null )
		{
			rect = element.getBoundingClientRect() as DOMRect;
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moduleDropdown ' + MODULE_NAME, rect);
		if ( rect != null )
		{
			let left: string = Math.floor(rect.x + window.scrollX) + 'px';
			let top : string = Math.floor(rect.y + rect.height + window.scrollY) + 'px';
			if ( MODULE_NAME == 'more' )
			{
				return (<div id='pnlTabMenuMore' key='pnlTabMenuMore' style={ {position: 'absolute', left, top, zIndex: 1000} } onMouseOut={ (e) => this.moduleTabMouseOut(e, MODULE_NAME) } ref={ this.pnlTabHover }>
					{
						// 06/30/2021 Paul.  Provide the URL to the module so that right-click-new-tab would navigate to the correct location. 
						// 07/08/2023 Paul.  ASP.NET Core will not have /React in the base. 
						this.tabsSecondary.map((tabMenu) => (
							<a href={ Credentials.RemoteServer + Credentials.ReactBase + tabMenu.MODULE_NAME } className='menuItem' style={ {minWidth: '10rem'} } onClick={ (e) => { e.preventDefault(); this._onModuleClick(tabMenu.MODULE_NAME); } }>{ L10n.Term(tabMenu.DISPLAY_NAME) }</a>
						))
					}
				</div>);
			}
		}
		return null;
	}

	public render()
	{
		const { quickCreate, bIsAuthenticated, txtQuickSearch, nMaxTabs, activeModule, actionsModule, showUnifiedSearch, showQuickCreate, menuChangeKey, unifiedSearchItems } = this.state;
	
		//03/06/2019. Chase. Referencing ADMIN_MODE triggers re-renders when it's updated;
		Credentials.ADMIN_MODE;
		// 04/29/2019 Paul.  When FAVORITES, LAST_VIEWED or SAVED_SEARCH changes, increment this number.  It is watched in the TopNav. 
		SplendidCache.NAV_MENU_CHANGE;

		let cssBackground: any = null;
		if ( !Sql.IsEmptyString(Crm_Config.ToString('header_background')) )
		{
			cssBackground = { backgroundImage: 'url(' + this.themeURL + Crm_Config.ToString('header_background') + ')'};
		}
		else
		{
			cssBackground = { backgroundImage: 'url(' + this.themeURL + 'images/header_bg.gif' + ')'};
		}

		// 04/28/2022 Paul.  New SplendidCRM logo. 
		let sCompanyLogo: string = Credentials.RemoteServer + 'App_Themes/Sugar/images/SplendidCRM_Logo.png';
		let sCompanyName: string = Crm_Config.ToString('company_name');
		let nLogoWidth : number = 207;
		let nLogoHeight: number =  60;
		// 08/28/2020 Paul.  Android is having trouble loading image from file system, so use base64. 
		if ( Credentials.RemoteServer == '' )
			sCompanyLogo = Credentials.SplendidCRM_Logo;
		if ( !Sql.IsEmptyString(Crm_Config.ToString('header_logo_image')) )
		{
			// 10/28/2021 Paul.  Allow logo to be stored in config table as base64. 
			if ( StartsWith(Crm_Config.ToString('header_logo_image'), 'data:image/') )
			{
				sCompanyLogo = Crm_Config.ToString('header_logo_image');
			}
			else if ( StartsWith(Crm_Config.ToString('header_logo_image'), 'http') )
			{
				sCompanyLogo = Crm_Config.ToString('header_logo_image');
			}
			else if ( StartsWith(sCompanyLogo, '~/') )
			{
				sCompanyLogo = sCompanyLogo.replace('~/', Credentials.RemoteServer);
			}
			else
			{
				sCompanyLogo = Credentials.RemoteServer + 'Include/images/' + Crm_Config.ToString('header_logo_image');
			}
			if ( !Sql.IsEmptyString(Crm_Config.ToString('header_logo_width')) )
			{
				nLogoWidth = Crm_Config.ToInteger('header_logo_width');
			}
			if ( !Sql.IsEmptyString(Crm_Config.ToString('header_logo_height')) )
			{
				nLogoHeight = Crm_Config.ToInteger('header_logo_height');
			}
		}
		let bLoading = StartsWith(this.props.location.pathname, '/Reload');
		if ( SplendidCache.IsInitialized && bIsAuthenticated && !bLoading && SplendidCache.TAB_MENU != null )
		{
			// 02/08/2022 Paul.  We need to start from the cache so that updated menus get applied immediately. 
			let tabMenus: TAB_MENU[] = SplendidCache.TAB_MENU;
			// 02/08/2022 Paul.  We need to deep copy as we modify the when showing an active module. 
			this.tabsPrimary = Sql.DeepCopy(tabMenus);
			this.tabsSecondary = [];
			if ( tabMenus.length > nMaxTabs )
			{
				this.tabsPrimary   = tabMenus.slice(0, nMaxTabs);
				this.tabsSecondary = tabMenus.slice(nMaxTabs, tabMenus.length);
			}
			// 09/16/2019 Paul.  If active module is in secondary, then remove and place at the end of the primary. 
			if ( !Sql.IsEmptyString(activeModule) )
			{
				let nPrimaryActive  : number = -1;
				let nSecondaryActive: number = -1;
				for ( let i = 0; i < this.tabsPrimary.length; i++ )
				{
					if ( this.tabsPrimary[i].MODULE_NAME == activeModule )
					{
						nPrimaryActive = i;
						break;
					}
				}
				for ( let i = 0; i < this.tabsSecondary.length; i++ )
				{
					if ( this.tabsSecondary[i].MODULE_NAME == activeModule )
					{
						nSecondaryActive = i;
						break;
					}
				}
				if ( nSecondaryActive >= 0 )
				{
					let tabActive: TAB_MENU[] = this.tabsSecondary.splice(nSecondaryActive, 1);
					if ( tabActive.length > 0 )
					{
						if ( this.tabsPrimary.length > 0 )
						{
							this.tabsSecondary.unshift(this.tabsPrimary.pop());
						}
						this.tabsPrimary.push(tabActive[0]);
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
						// 02/08/2022 Paul.  We only need to overflow if showing max tabs. 
						if ( this.tabsPrimary.length >= nMaxTabs )
						{
							if ( this.tabsPrimary.length > 0 )
							{
								this.tabsSecondary.unshift(this.tabsPrimary.pop());
							}
						}
						this.tabsPrimary.push(activeMenu);
					}
				}
			}
		}
		if ( SplendidCache.IsInitialized )
		{
			let width: number = screenWidth();
			let sTouchTabHeight: string = '4px';
			if ( isTouchDevice() )
				sTouchTabHeight = '10px';
			let cssTouchTab = {display: 'inline-block', borderWidth: '0px', height: sTouchTabHeight, width: '100%', verticalAlign: 'bottom'};
			let cssTouchImage = {borderWidth: '0px', height: sTouchTabHeight, width: '100%'};
			return (
<div id='divHeader'>
	<div style={ cssBackground }>
		<table style={ {width: '100%', borderWidth: '0px', borderSpacing: 0, padding: 0} }>
			<tr>
				<td style={ {height: '60px'} } rowSpan={ 2 }>
					<img id='imgCompanyLogo' title={ sCompanyName } src={ sCompanyLogo } style={ {borderWidth: '0px', height: nLogoHeight, width: nLogoWidth, marginLeft: '10px'} } />
				</td>
				<td align='center' rowSpan={ 2 }>
					{ Crm_Config.ToString('header_banner') }
				</td>
				<td align='right' className='myArea' style={ {verticalAlign: 'center', paddingRight: '10px'} } >
					<div>
						{ bIsAuthenticated
						? <React.Fragment>
							<span className='welcome'>{ L10n.Term('.NTC_WELCOME') }<b>{ Security.USER_NAME() }</b></span>
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated  // 07/15/2021 Paul.  Now that we are caching the ReactState, we need an end-user way to clear the cache even when using Windows authentication.  So alway show logout. 
						? <React.Fragment>
							&nbsp;
							[ <a id='lnkLogout'  className='myAreaLink' href='#' onClick={ (e) => { e.preventDefault(); this._onLogout();      } }>{ L10n.Term('.LBL_LOGOUT')     }</a> ]
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated
						? <React.Fragment>
							&nbsp;|&nbsp;
							<a id='lnkMyAccount' className='myAreaLink' href={ Credentials.RemoteServer + Credentials.ReactBase + 'Users/MyAccount' } onClick={ (e) => { e.preventDefault(); this._onUserProfile(); } }>{ L10n.Term('.LBL_MY_ACCOUNT') }</a>
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated && SplendidCache.GetUserAccess('Employees', 'access') >= 0
						? <React.Fragment>
							&nbsp;|&nbsp;
							<a id='lnkEmployees' className='myAreaLink' href={ Credentials.RemoteServer + Credentials.ReactBase + 'Employees' } onClick={ (e) => { e.preventDefault(); this._onEmployees();   } }>{ L10n.Term('.LBL_EMPLOYEES')  }</a>
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated && (Security.IS_ADMIN() || Security.IS_ADMIN_DELEGATE())
						? <React.Fragment>
							&nbsp;|&nbsp;
							<a id='lnkAdmin'     className='myAreaLink' href={ Credentials.RemoteServer + Credentials.ReactBase + 'Administration' } onClick={ (e) => { e.preventDefault(); this._onAdminPage();   } }>{ L10n.Term('.LBL_ADMIN')      }</a>
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated && (Security.IS_ADMIN() || Security.IS_ADMIN_DELEGATE()) && !Crm_Config.ToBoolean('disable_admin_classic')
						? <React.Fragment>
							&nbsp;|&nbsp;
							<a id='lnkAdmin'     className='myAreaLink' href={ Credentials.RemoteServer + '/' + 'Administration' } onClick={ (e) => { e.preventDefault(); this._onAdminClassicPage(); } }>{ L10n.Term('.LBL_ADMIN_CLASSIC')}</a>
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated && !Crm_Config.ToBoolean('hide_training') 
						? <React.Fragment>
							&nbsp;|&nbsp;
							<a id='lnkTraining'  className='myAreaLink' href={ Credentials.RemoteServer + Credentials.ReactBase + 'Home/TrainingPortal' } onClick={ (e) => { e.preventDefault(); this._onTrainingPortal(); } }>{ L10n.Term('.LBL_TRAINING') }</a>
						</React.Fragment>
						: null
						}
						&nbsp;|&nbsp;
						<a id='lnkAbout'     className='myAreaLink' href={ Credentials.RemoteServer + Credentials.ReactBase + 'Home/About' } onClick={ (e) => { e.preventDefault(); this._onAbout();       } }>{ L10n.Term('.LNK_ABOUT')      }</a>
						<br />
					</div>
				</td>
			</tr>
			<tr style={ {height: '20px'} }>
				<td align='right' className='subTabBar' style={ {verticalAlign: 'top', paddingRight: '10px'} }>
				{ showUnifiedSearch && unifiedSearchItems > 0
				? <div id='divUnifiedSearch' style={ {textAlign: 'right'} }>
					&nbsp;<b>{ L10n.Term(".LBL_SEARCH") }</b>&nbsp;
					<input type='text'
						id='txtUnifiedSearch'
						className='searchField'
						size={ 14 }
						onKeyDown={ this._onKeyDown }
						value={ txtQuickSearch }
						onChange={ this._onQuickSearchChange }
					/>
					<input type='image'
						id='btnUnifiedSearch'
						className='searchButton'
						src={ this.themeURL + 'images/searchButton.gif' }
						alt={ L10n.Term('.LBL_SEARCH') }
						onClick={ this._onUnifiedSearch }
						style={ {borderWidth: '0px', height: '20px', width: '25px', verticalAlign: 'middle'} }
						/>
					&nbsp;
				</div>
				: null
				}
				</td>
			</tr>
		</table>
		<div id='divTabMenu'  ref={ this.ctlSixToolbar }>
			<table id='ctlTabMenu_tblSixMenu' className='tabFrame' cellSpacing={ 0 } cellPadding={ 0 }>
				<tr>
					<td style={ {paddingLeft: '14px'} } className='otherTabRight'
						ref={ (element) => this.moduleTabRef(element, 'leadingblank') }
						onMouseOver={ (e) => this.moduleTabMouseOver(e, 'leadingblank') }
						onMouseOut={ (e) => this.moduleTabMouseOut(e, 'leadingblank') }
					>&nbsp;</td>
					{
						// 06/30/2021 Paul.  Provide the URL to the module so that right-click-new-tab would navigate to the correct location. 
						this.tabsPrimary.map((tabMenu) =>
						(
					<td valign='bottom'>
						<table id={ 'ctlSixToolbar_tabToolbar_' + tabMenu.MODULE_NAME } className='tabFrame' cellSpacing={ 0 } cellPadding={ 0 } style={ {height: '25px'} }
							ref={ (element) => this.moduleTabRef(element, tabMenu.MODULE_NAME) }
							onMouseOver={ (e) => this.moduleTabMouseOver(e, tabMenu.MODULE_NAME) }
							onMouseOut={ (e) => this.moduleTabMouseOut(e, tabMenu.MODULE_NAME) }
							onClick={ (e) => this.moduleTabClick(tabMenu.MODULE_NAME) }
						>
							<tr>
								<td className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'TabLeft' }><img src={ this.themeURL + 'images/blank.gif' } style={ {borderWidth: '0px', height: '25px', width: '5px'} } /></td>
								<td className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'Tab' } style={ {whiteSpace: 'nowrap', verticalAlign: 'middle'} }>
									<a href={ Credentials.RemoteServer + Credentials.ReactBase + tabMenu.MODULE_NAME } onClick={ (e) => { e.preventDefault(); this._onModuleClick(tabMenu.MODULE_NAME); } } className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'TabLink' }>{ L10n.Term(tabMenu.DISPLAY_NAME) }</a>
								</td>
								<td className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'TabRight' }><img src={ this.themeURL + 'images/blank.gif' } style={ {borderWidth: '0px', height: '25px', width: '5px'} } /></td>
							</tr>
						</table>
					</td>
						))
					}
					{ this.tabsSecondary.length > 0
					? <td valign='bottom'>
						<table id='ctlSixToolbar_tabToolbar_more' className='tabFrame' cellSpacing={ 0 } cellPadding={ 0 }
							ref={ (element) => this.moduleTabRef(element, 'more') }
							onMouseOver={ (e) => this.moduleTabMouseOver(e, 'more') }
							onMouseOut={ (e) => this.moduleTabMouseOut(e, 'more') }
							onClick={ (e) => this.moduleTabClick('more') }
						>
							<tr>
								<td className='otherTabLeft'><img src={ this.themeURL + 'images/blank.gif' } style={ {borderWidth: '0px', height: '25px', width: '5px'} } /></td>
								<td className='otherTab' style={ {verticalAlign: 'middle'} }>
									<img id='ctlTabMenu_imgTabMenuMore' src={ this.themeURL + 'images/more.gif' } style={ {borderWidth: '0px', height: '20px', width: '16px', verticalAlign: 'middle'} } />
								</td>
								<td className='otherTabRight'><img src={ this.themeURL + 'images/blank.gif' } style={ {borderWidth: '0px', height: '25px', width: '5px'} } /></td>
							</tr>
						</table>
					</td>
					: null
					}
					<td width='100%' className='tabRow'
						ref={ (element) => this.moduleTabRef(element, 'trailingblank') }
						onMouseOver={ (e) => this.moduleTabMouseOver(e, 'trailingblank') }
						onMouseOut={ (e) => this.moduleTabMouseOut(e, 'trailingblank') }
					><img src={ this.themeURL + 'images/blank.gif' } style={ {borderWidth: '0px', height: '1px', width: '1px'} } /></td>
				</tr>
			</table>
			<table className="tabFrame" cellSpacing={ 0 } cellPadding={ 0 } style={ {height: '20px'} }>
				<tr>
					<td id="subtabs"><img src={ this.themeURL + 'images/blank.gif' } style={ {borderWidth: '0px', height: '1px', width: '1px'} } /></td>
				</tr>
			</table>
		</div>
	</div>
	<div id="divLastViewed" className="lastView" style={ {width: '100%'} }>
		<b>{ L10n.Term('.LBL_LAST_VIEWED') }&nbsp;&nbsp;</b>
		{ this.LastViewed(activeModule).length > 0
		? this.LastViewed(activeModule).map((item) => 
			(
				<span style={ {whiteSpace: 'nowrap'} }><a key={ 'last_' + item.ID } className='lastViewLink' onClick={(e) => this._onLastViewed(activeModule, item)}>
					<img title={ item.NAME } src={ this.themeURL + 'images/' + activeModule + '.gif' } style={ {borderWidth: '0px', height: '16px', width: '16px', verticalAlign: 'middle'} } />&nbsp;{ item.NAME }
				</a>&nbsp;</span>
			))
		: <span>{ L10n.Term('.LBL_LINK_NONE') }</span>
		}
	</div>

	<div id="divShortcuts" className="lastView" style={ {width: '100%'} }>
		<b>{ L10n.Term('.LBL_ACTIONS') }&nbsp;&nbsp;</b>
		{
			this.Actions(activeModule).map((item) => 
			(
				<span style={ {whiteSpace: 'nowrap'} }><a key={ 'action_' + item.key } className='lastViewLink' onClick={(e) => this._onAction(activeModule, item)}>
					<img src={ this.themeURL + 'images/' + item.IMAGE_NAME } style={ {borderWidth: '0px', width: '16px', height: '16px', verticalAlign: 'middle'} } />
					&nbsp;{ item.label }</a>&nbsp;</span>
			))
		}
	</div>
	<React.Fragment key={ "actionsModule_" + menuChangeKey.toString() }>
		{ this.moduleDropdown(actionsModule) }
	</React.Fragment>
</div>
			);
		}
		else
		{
			let logoTitle : string = Sql.IsEmptyString(Crm_Config.ToString('company_name'      )) ? 'SplendidCRM Software, Inc.' : Crm_Config.ToString('company_name'      );
			let logoUrl   : string = Sql.IsEmptyString(Crm_Config.ToString('header_logo_image' )) ? '~/App_Themes/Sugar/images/SplendidCRM_Logo.png'       : Crm_Config.ToString('header_logo_image' );
			let logoWidth : string = Sql.IsEmptyString(Crm_Config.ToString('header_logo_width' )) ? '207px'                      : Crm_Config.ToString('header_logo_width' );
			let logoHeight: string = Sql.IsEmptyString(Crm_Config.ToString('header_logo_height')) ? '60px'                       : Crm_Config.ToString('header_logo_height');
			// 02/17/2020 Paul.  We do not want to parse the style at this time, so just ignore the value. 
			let logoStyle : string = Crm_Config.ToString('arctic_header_logo_style');
			if ( !StartsWith(logoUrl, '~/') && !StartsWith(logoUrl, 'http') )
			{
				logoUrl = '~/Include/images/' + logoUrl;
			}
			// 08/28/2020 Paul.  Android is having trouble loading image from file system, so use base64. 
			if ( Credentials.RemoteServer == '' )
				logoUrl = Credentials.SplendidCRM_Logo;
			else
				logoUrl = logoUrl.replace('~/', Credentials.RemoteServer);
			return (
<div id='divHeader' style={ cssBackground }>
	<table className='SixToolbarLogin' cellSpacing={ 0 } cellPadding={ 0 } style={ {border: 'collapse', width: '100%'} }>
		<tr>
			<td style={ {whiteSpace: 'nowrap'} }>
				<table id='tblLoginHeader' className='tabToolbarFrame' cellSpacing={ 0 } cellPadding={ 0 } style={ {border: 'collapse'} }>
					<tr>
						<td>
							<img id='imgCompanyLogo' title={ logoTitle } src={ logoUrl } style={ {height: logoHeight, width: logoWidth, borderWidth: '0px'} } />
						</td>
					</tr>
				</table>
			</td>
			<td>
				&nbsp;
			</td>
		</tr>
	</table>
</div>
			);
		}
	}
}

export default withRouter(SugarTopNav);

