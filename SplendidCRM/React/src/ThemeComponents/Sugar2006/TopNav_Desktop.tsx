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
import {  Navbar, NavbarBrand, Nav, NavDropdown }       from 'react-bootstrap'                    ;
import { FontAwesomeIcon }                              from '@fortawesome/react-fontawesome'     ;
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
import { StartsWith, ActiveModuleFromPath }             from '../../scripts/utility'              ;
// 4. Components and Views.
import NavItem                                          from '../../components/NavItem'           ;

interface ITopNavProps extends RouteComponentProps<any>
{
}

interface ITopNavState
{
	tabMenus          : TAB_MENU[];
	dashboards        : any;
	homeDashboards    : any;
	adminMode         : boolean;
	isOpen            : boolean;
	txtQuickSearch    : string;
	bIsAuthenticated  : boolean;
	nMaxTabs?         : number;
	nHistoryMaxViewed?: number;
	activeModule      : string;
	unifiedSearchItems : number;  // 01/10/2022 Paul.  Don't show if search panels empty. 
}

@observer
class Sugar2006TopNav_Desktop extends React.Component<ITopNavProps, ITopNavState>
{
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
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.location.pathname, '[' + txtQuickSearch + ']');
		this.state =
		{
			tabMenus         : [],
			dashboards       : null,
			homeDashboards   : null,
			adminMode        : Credentials.ADMIN_MODE,
			isOpen           : true,
			txtQuickSearch     : txtQuickSearch,
			bIsAuthenticated : false,
			nMaxTabs         : 7,
			nHistoryMaxViewed: 10,
			activeModule     ,
			unifiedSearchItems: 0,
	};
	}

	async componentDidMount()
	{
		const { bIsAuthenticated } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.props.location.pathname);
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
				let nMaxTabs          = Crm_Config.ToInteger('default_max_tabs'  );
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
		this.props.history.push('/Reset/' + item.key);
	}

	private _onLastViewed = (sMODULE_NAME: string, item) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLastViewed ' + sMODULE_NAME, item);
		let module:MODULE = SplendidCache.Module(sMODULE_NAME, this.constructor.name + '._onLastViewed');
		if ( module.IS_ADMIN )
			this.props.history.push('/Reset/Administration/' + sMODULE_NAME + '/View/' + item.ID)
		else
			this.props.history.push('/Reset/' + sMODULE_NAME + '/View/' + item.ID)
	}

	private _onModuleClick = (MODULE_NAME) =>
	{
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onModuleClick');
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onModuleClick ' + MODULE_NAME, module);
		if ( module != null )
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
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load tabMenus', tabMenus);
			// 01/10/2022 Paul.  Don't show if search panels empty. 
			let unifiedSearchItems: number = 0;
			let layout = SplendidCache.DetailViewRelationships('Home.UnifiedSearch');
			if ( layout != null )
				unifiedSearchItems = layout.length;
			this.setState({ tabMenus: tabMenus, unifiedSearchItems });
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

	public render()
	{
		const { tabMenus, bIsAuthenticated, txtQuickSearch, nMaxTabs, activeModule, unifiedSearchItems } = this.state;
	
		//03/06/2019. Chase. Referencing ADMIN_MODE triggers re-renders when it's updated;
		Credentials.ADMIN_MODE;
		// 04/29/2019 Paul.  When FAVORITES, LAST_VIEWED or SAVED_SEARCH changes, increment this number.  It is watched in the TopNav. 
		SplendidCache.NAV_MENU_CHANGE;

		let themeURL: string = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
		let moreIcon = <FontAwesomeIcon icon='angle-double-right' size='lg' />;

		let cssBackground: any = null;
		if ( !Sql.IsEmptyString(Crm_Config.ToString('header_background')) )
		{
			cssBackground = { backgroundImage: 'url(' + themeURL + Crm_Config.ToString('header_background') + ')'};
		}

		let sCompanyLogo: string = Credentials.RemoteServer + 'Include/images/SplendidCRM_Logo.gif';
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
		let itemsNav = [];
		let moreItems = [];
		let lastViewed = [];
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
				let nActive: number = -1;
				for ( let i = 0; i < tabsSecondary.length; i++ )
				{
					if ( tabsSecondary[i].MODULE_NAME == activeModule )
					{
						nActive = i;
						break;
					}
				}
				if ( nActive >= 0 )
				{
					let tabActive: TAB_MENU[] = tabsSecondary.splice(nActive, 1);
					if ( tabActive.length > 0 )
					{
						if ( tabsPrimary.length > 0 )
						{
							tabsSecondary.unshift(tabsPrimary.pop());
						}
						tabsPrimary.push(tabActive[0]);
					}
				}
			}
			itemsNav = tabsPrimary.map((tabMenu) =>
			(
				<table className="tabFrame" cellPadding={ 0 } cellSpacing={ 0 } style={ {borderSpacing: 0, padding: 0, height: '25px'} }>
					<tbody><tr>
						<td className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'TabLeft' } style={ {width: '5px', padding: 0, margin: 0} }><img src={ themeURL + 'images/blank.gif' } style={ {margin: '0px', borderWidth: '0px', height: '25px', width: '4px', padding: '0px'} } /></td>
						<td className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'Tab' } style={ {whiteSpace: 'nowrap'} }><a className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'TabLink' } href="#" onClick={ (e) => { e.preventDefault(); this._onModuleClick(tabMenu.MODULE_NAME); } }>{ L10n.Term(tabMenu.DISPLAY_NAME) }</a></td>
						<td className={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'TabRight' } style={ {width: '2px', padding: 0, margin: 0} }><img src={ themeURL + 'images/blank.gif' } style={ {margin: '0px', borderWidth: '0px', height: '25px', width: '2px', padding: '0px'} } /></td>
					</tr></tbody>
				</table>
			));
			// 06/30/2021 Paul.  Provide the URL to the module so that right-click-new-tab would navigate to the correct location. 
			// 07/08/2023 Paul.  ASP.NET Core will not have /React in the base. 
			moreItems = tabsSecondary.map((tabMenu) => (
				<a className="menuItem" href={ Credentials.RemoteServer + Credentials.ReactBase + tabMenu.MODULE_NAME } style={ {minWidth: '10rem', fontWeight: 'normal'} } onClick={ (e) => { e.preventDefault(); this._onModuleClick(tabMenu.MODULE_NAME); } }>{ L10n.Term(tabMenu.DISPLAY_NAME) }</a>
			));
			lastViewed = this.LastViewed(activeModule).map((item) => 
			(
				<span style={ {whiteSpace: 'nowrap'} }>
					<a className="lastViewLink" href="#" onClick={ (e) => { e.preventDefault(); this._onLastViewed(activeModule, item); } }>
						<img title={ item.NAME } src={ themeURL + 'images/' + activeModule + '.gif' } style={ {marginLeft: 'auto', marginRight: 'auto', borderWidth: '0px', height: '16px', width: '16px'} } />
						&nbsp;{ item.NAME }</a>&nbsp;
				</span>
			));
		}
		if ( SplendidCache.IsInitialized )
		{
			return (
<div id="divHeader">
	<div id="ctlReminders">
		<input type="submit" name="btnREMINDER_UPDATE" value="Update" id="ctlReminders_btnREMINDER_UPDATE" className='button' style={ {display: 'none'} } />
		<span id="ctlReminders_lblScripts"></span>
	</div>
	<div style={ cssBackground }>
		<table style={ {width: '100%', borderWidth: '0px', borderSpacing: 0, padding: 0} }>
			<tbody><tr>
				<td style={ {height: '60px'} }>
					<img id="imgCompanyLogo" title={ sCompanyName } src={ sCompanyLogo } style={ {borderWidth: '0px', height: nLogoHeight, width: nLogoWidth, marginLeft: '10px'} } />
				</td>
				<td align="center">
					{ Crm_Config.ToString('header_banner') }
				</td>
				<td align="right" className="myArea" style={ {verticalAlign: 'top', paddingRight: '10px'} } >
					<div>
						{ bIsAuthenticated  // 07/15/2021 Paul.  Now that we are caching the ReactState, we need an end-user way to clear the cache even when using Windows authentication.  So alway show logout. 
						? <React.Fragment>
							&nbsp;
							[ <a id="lnkLogout"  className="myAreaLink" href="#" onClick={ (e) => { e.preventDefault(); this._onLogout();      } }>{ L10n.Term('.LBL_LOGOUT')     }</a> ]
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated
						? <React.Fragment>
							<a id="lnkMyAccount" className="myAreaLink" href={ Credentials.RemoteServer + Credentials.ReactBase + 'Users/MyAccount' } onClick={ (e) => { e.preventDefault(); this._onUserProfile(); } }>{ L10n.Term('.LBL_MY_ACCOUNT') }</a>
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated && SplendidCache.GetUserAccess("Employees", "access") >= 0
						? <React.Fragment>
							&nbsp;|&nbsp;
							<a id="lnkEmployees" className="myAreaLink" href={ Credentials.RemoteServer + Credentials.ReactBase + 'Employees' } onClick={ (e) => { e.preventDefault(); this._onEmployees();   } }>{ L10n.Term('.LBL_EMPLOYEES')  }</a>
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated && (Security.IS_ADMIN() || Security.IS_ADMIN_DELEGATE())
						? <React.Fragment>
							&nbsp;|&nbsp;
							<a id="lnkAdmin"     className="myAreaLink" href={ Credentials.RemoteServer + Credentials.ReactBase + 'Administration' } onClick={ (e) => { e.preventDefault(); this._onAdminPage();   } }>{ L10n.Term('.LBL_ADMIN')      }</a>
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated && (Security.IS_ADMIN() || Security.IS_ADMIN_DELEGATE()) && !Crm_Config.ToBoolean('disable_admin_classic')
						? <React.Fragment>
							&nbsp;|&nbsp;
							<a id="lnkAdmin"     className="myAreaLink" href={ Credentials.RemoteServer + '/' + 'Administration' } onClick={ (e) => { e.preventDefault(); this._onAdminClassicPage(); } }>{ L10n.Term('.LBL_ADMIN_CLASSIC') }</a>
						</React.Fragment>
						: null
						}
						{ bIsAuthenticated && !Crm_Config.ToBoolean('hide_training') 
						? <React.Fragment>
							&nbsp;|&nbsp;
							<a id="lnkTraining"  className="myAreaLink" href={ Credentials.RemoteServer + Credentials.ReactBase + 'Home/TrainingPortal' } onClick={ (e) => { e.preventDefault(); this._onTrainingPortal(); } }>{ L10n.Term('.LBL_TRAINING') }</a>
						</React.Fragment>
						: null
						}
						&nbsp;|&nbsp;
						<a id="lnkAbout"     className="myAreaLink" href={ Credentials.RemoteServer + Credentials.ReactBase + 'Home/About' } onClick={ (e) => { e.preventDefault(); this._onAbout();       } }>{ L10n.Term('.LNK_ABOUT')      }</a>
						<br />
					</div>
					{ unifiedSearchItems > 0
					? <table style={ {borderWidth: '0px', borderSpacing: 0, padding: 0, marginTop: '20px'} }>
						<tbody><tr style={ {height: '20px'} }>
							<td className="subTabBar" style={ {height: '20px', verticalAlign: 'top'} }>
								<div id="divUnifiedSearch">
									&nbsp;<b>{ L10n.Term(".LBL_SEARCH") }</b>&nbsp;
									<input name="txtUnifiedSearch"
										type="text"
										id="cntUnifiedSearch_txtUnifiedSearch"
										className="searchField" size={ 14 }
										onKeyDown={ this._onKeyDown }
										value={ txtQuickSearch }
										onChange={ this._onQuickSearchChange }
									/>
								</div>
							</td>
							<td className="subTabBar" style={ {height: '20px', verticalAlign: 'top'} }>
								<input type="image"
									name="btnUnifiedSearch"
									id="cntUnifiedSearch_btnUnifiedSearch"
									className="searchButton"
									src={ themeURL + 'images/searchButton.gif' }
									alt={ L10n.Term(".LBL_SEARCH") }
									onClick={ this._onUnifiedSearch } style={ {textAlign: 'center', borderWidth: '0px', height: '17px', width: '25px'} }
								/>
							</td>
						</tr></tbody>
					</table>
					: null
					}
				</td>
			</tr></tbody>
		</table>
		<Navbar bg="light" variant="light" expand="md" id="topnav" style={ {padding: 0, ...cssBackground} }>
			<Navbar.Toggle onClick={this.toggle} aria-controls="topnav-nav" />
			<Navbar.Collapse id="topnav-nav">
				<span className='otherTabRight' style={ {paddingLeft: '14px', height: '28px'} }>&nbsp;</span>
				<Nav navbar>
					{ itemsNav }
				</Nav>
				{ moreItems.length > 0
				? <Navbar.Collapse id="topnav-nav-more" className='otherTab' style={ {height: '28px'} }>
						<Nav navbar>
							<NavItem title={ moreIcon } id="moreicon" key="moreicon">
								{ moreItems }
							</NavItem>
						</Nav>
					</Navbar.Collapse>
				: null
				}
			</Navbar.Collapse>
		</Navbar>
	</div>
	<div id="divLastViewed" className="lastView" style={ {width: '100%'} }>
		<b>{ L10n.Term(".LBL_LAST_VIEWED") }:&nbsp;&nbsp;</b>
		{ lastViewed }
	</div>
</div>
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
<div id="ctl00_divHeader" style={ cssBackground }>
	<table className="SixToolbarLogin" cellSpacing="0" cellPadding="0" style={ {border: 'collapse', width: '100%'} }>
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
			<td style={ {width: '99%'} }>
				&nbsp;
			</td>
		</tr>
	</table>
</div>
			);
		}
	}
}

export default withRouter(Sugar2006TopNav_Desktop);

