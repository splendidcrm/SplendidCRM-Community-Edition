import { Component, OnInit, ChangeDetectorRef , SimpleChanges} from '@angular/core';
import { Location                            } from '@angular/common';
import { Router                              } from '@angular/router';
import { faHouse, faSearch                   } from '@fortawesome/free-solid-svg-icons'     ;
import { SplendidCacheService                } from '../../scripts/SplendidCache'           ;
import { CredentialsService                  } from '../../scripts/Credentials'             ;
import { SecurityService                     } from '../../scripts/Security'                ;
import { L10nService                         } from '../../scripts/L10n'                    ;
import { CrmConfigService, CrmModulesService } from '../../scripts/Crm'                     ;
import { StartsWith, EndsWith, ActiveModuleFromPath, screenWidth, isTouchDevice } from '../../scripts/utility'                 ;
import Sql                                     from '../../scripts/Sql'                     ;
import MODULE                                  from '../../types/MODULE'                    ;
import TAB_MENU                                from '../../types/TAB_MENU'                  ;
import SHORTCUT                                from '../../types/SHORTCUT'                  ;


@Component({
	selector: 'PacificTopNav',
	templateUrl: './TopNav.html',
})
export class PacificTopNavComponent implements OnInit
{
	public  bIsInitialized     : boolean;
	public  lastPathname       : string = null;
	public  tabMenus           : TAB_MENU[];
	public  quickCreate        : TAB_MENU[];
	public  dashboards         : any;
	public  homeDashboards     : any;
	public  adminMode          : boolean;
	public  isOpen             : boolean;
	public  txtQuickSearch     : string = null;
	public  bIsAuthenticated   : boolean;
	public  nMaxTabs?          : number;
	public  nHistoryMaxViewed? : number;
	public  showInlineEdit     : boolean;
	public  QUICK_CREATE_MODULE: string = null;
	public  item?              : any;
	public  dependents?        : Record<string, Array<any>>;
	public  error?             : any;
	public  activeModule       : string = null;
	public  menuChangeKey      : number;  // 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
	public  actionsModule      : string = null;
	public  showUnifiedSearch  : boolean;
	public  showQuickCreate    : boolean;
	public  unifiedSearchItems : number;  // 01/10/2022 Paul.  Don't show if search panels empty. 
	public  logoTitle          : string = null;
	public  logoUrl            : string = null;
	public  logoWidth          : string = null;
	public  logoHeight         : string = null;
	public  logoStyle          : string = null;
	public  sCompanyHomeImage  : string = null;
	public  width              : number;
	public  cssTouchTab        : any = null;
	public  cssTouchImage      : any = null;

	public  tabMenuRect          : Record<string, DOMRect> = {};
	public  themeURL             : string = null;
	public  tabsPrimary          : TAB_MENU[] = [];
	public  tabsSecondary        : TAB_MENU[] = [];
	public  house                = faHouse        ;
	public  search               = faSearch       ;

	constructor(private router: Router, private location: Location, private changeDetectorRef: ChangeDetectorRef, protected SplendidCache: SplendidCacheService, public Credentials: CredentialsService, public Security: SecurityService, public L10n: L10nService, private Crm_Config: CrmConfigService, private Crm_Modules: CrmModulesService)
	{
		this.router.routeReuseStrategy.shouldReuseRoute = function()
		{
		return false;
		};
		let activeModule: string = ActiveModuleFromPath(SplendidCache, window.location.pathname, this.constructor.name + '.constructor');
		this.themeURL = Credentials.sREMOTE_SERVER + 'App_Themes/' + this.SplendidCache.UserTheme + '/';
		// 01/08/2020 Paul.  Pull the current value from the URL so that we can reload after submit. 
		let txtQuickSearch: string = '';
		if ( window.location.pathname.indexOf('/UnifiedSearch/') >= 0 )
		{
			txtQuickSearch = window.location.pathname.substr(15);
		}
		//console.log(this.constructor.name + '.constructor', activeModule, '(' + window.location.pathname + ')', '[' + txtQuickSearch + ']');
		this.bIsInitialized      = this.SplendidCache.IsInitialized;
		this.lastPathname        = window.location.pathname;
		this.tabMenus            = [];
		this.quickCreate         = [];
		this.dashboards          = null;
		this.homeDashboards      = null;
		this.adminMode           = Credentials.ADMIN_MODE;
		this.isOpen              = true;
		this.txtQuickSearch      = txtQuickSearch;
		this.bIsAuthenticated    = Credentials.bIsAuthenticated;
		this.nMaxTabs            = 7;
		this.nHistoryMaxViewed   = 10;
		this.showInlineEdit      = false;
		this.QUICK_CREATE_MODULE = null;
		this.activeModule        = activeModule;
		this.menuChangeKey       = 0;
		this.actionsModule       = null;
		this.showUnifiedSearch   = true;
		this.showQuickCreate     = true;
		this.unifiedSearchItems  = 0;
		this.logoTitle           = null;
		this.logoUrl             = null;
		this.logoWidth           = null;
		this.logoHeight          = null;
		this.logoStyle           = null;
		this.sCompanyHomeImage   = null;
		this.width               = null;
		this.cssTouchTab         = null;
		this.cssTouchImage       = null;
	}

	// https://angular.io/guide/lifecycle-hooks
	// Called before ngOnInit() (if the component has bound inputs) and whenever one or more data-bound input properties change.
	ngOnChanges(changes: SimpleChanges): void
	{
		console.log(this.constructor.name + '.ngOnChanges', changes);
	}

	// Called once, after the first ngOnChanges(). ngOnInit() is still called even when ngOnChanges() is not (which is the case when there are no template-bound inputs).
	ngOnInit(): void
	{
		//console.log(this.constructor.name + '.ngOnInit');
	}

	// Called immediately after ngOnChanges() on every change detection run, and immediately after ngOnInit() on the first run.
	ngDoCheck(): void
	{
		//console.log(this.constructor.name + '.ngDoCheck');
		let bChanged: boolean = false;
		if ( this.lastPathname != window.location.pathname )
		{
			//console.log(this.constructor.name + '.ngDoCheck pathname changed');
			bChanged = true;
		}
		else if ( this.bIsInitialized != this.SplendidCache.IsInitialized )
		{
			//console.log(this.constructor.name + '.ngDoCheck IsInitialized changed');
			bChanged = true;
		}
		else if ( this.bIsAuthenticated != this.Credentials.bIsAuthenticated )
		{
			console.log(this.constructor.name + '.ngDoCheck bIsAuthenticated changed');
			bChanged = true;
		}
		else if ( this.adminMode != this.Credentials.ADMIN_MODE )
		{
			console.log(this.constructor.name + '.ngDoCheck ADMIN_MODE changed');
			bChanged = true;
		}
		else if ( this.SplendidCache.IsInitialized && this.activeModule != ActiveModuleFromPath(this.SplendidCache, window.location.pathname, this.constructor.name + '.ngDoCheck') )
		{
			console.log(this.constructor.name + '.ngDoCheck activeModule changed');
			bChanged = true;
		}
		if ( bChanged )
		{
			if ( this.lastPathname != window.location.pathname && !StartsWith(window.location.pathname, '/UnifiedSearch') && !StartsWith(window.location.pathname, '/UnifiedSearch') )
			{
				if ( !Sql.IsEmptyString(this.txtQuickSearch) )
				{
					//console.log(this.constructor.name + '.ngDoCheck clearing quick search');
					this.txtQuickSearch = '';
				}
			}
			this.activeModule       = ActiveModuleFromPath(this.SplendidCache, window.location.pathname, this.constructor.name + '.ngDoCheck');
			this.bIsInitialized     = this.SplendidCache.IsInitialized;
			this.lastPathname       = window.location.pathname;
			//console.log(this.constructor.name + '.ngDoCheck', this.activeModule);

			if ( this.bIsInitialized && this.Credentials.bIsAuthenticated && this.Credentials.ADMIN_MODE != this.adminMode )
			{
				this.adminMode = this.Credentials.ADMIN_MODE;
				this.Load('ngDoCheck');
			}
			else
			{
				// 05/28/2019 Paul.  Use a passive IsAuthenticated check (instead of active server query), so that we do not have multiple simultaneous requests. 
				// 05/28/2019 Paul.  Track the authentication change so that we an clear the menus appropriately. 
				let bAuthenticated: boolean = this.Credentials.bIsAuthenticated;
				if ( this.bIsAuthenticated != bAuthenticated )
				{
					let nMaxTabs         : number  = this.Crm_Config.ToInteger('atlantic_max_tabs' );
					let nHistoryMaxViewed: number  = this.Crm_Config.ToInteger('history_max_viewed');
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
					// Allocate 50 for logo in left corner, 50 for quick create menu, 100 for more and 150 for unified search. 
					// 04/26/2021 Paul.  Always based tabs on space available. 
					//if ( width < (50 + 50 + 100 + 150 + nMaxTabs * 100 ) )
					{
						nMaxTabs = Math.floor((width - 50 - 50 - 100 - 150) / 100);
						if ( nMaxTabs < 1 )
						{
							showUnifiedSearch = false;
							showQuickCreate   = false;
							nMaxTabs = Math.floor((width - 50 - 100) / 100);
							// 04/25/2021 Paul.  More dropdown not visible at 375, so drop to 1 tab if below 400. 
							if ( nMaxTabs < 1 || width < 400 )
							{
								nMaxTabs = 1;
							}
						}
					}
					this.bIsAuthenticated  = bAuthenticated   ;
					this.tabMenus          = []               ;
					this.quickCreate       = []               ;
					this.nMaxTabs          = nMaxTabs         ;
					this.nHistoryMaxViewed = nHistoryMaxViewed;
					this.showUnifiedSearch = showUnifiedSearch;
					this.showQuickCreate   = showQuickCreate  ;
					//console.log(this.constructor.name + '.componentWillUpdate Load');
					this.Load('componentWillUpdate');
				}
				//console.log(this.constructor.name + '.ngDoCheck', this);

				let bLoading = StartsWith(window.location.pathname, '/Reload');
				// 04/24/2021 Paul.  Must compute the tabs during render as the last tab may need to be replaced with the active tab. 
				this.tabsPrimary   = [];
				this.tabsSecondary = [];
				if ( this.SplendidCache.IsInitialized && this.bIsAuthenticated && !bLoading && this.SplendidCache.TAB_MENU != null )
				{
					// 02/08/2022 Paul.  We need to start from the cache so that updated menus get applied immediately. 
					let tabMenus: TAB_MENU[] = [];
					for ( let nTab = 0; nTab < this.SplendidCache.TAB_MENU.length; nTab++ )
					{
						var sMODULE_NAME = this.SplendidCache.TAB_MENU[nTab].MODULE_NAME;
						if ( sMODULE_NAME != 'Home' )
						{
							tabMenus.push(this.SplendidCache.TAB_MENU[nTab]);
						}
					}
					// 02/08/2022 Paul.  We need to deep copy as we modify the when showing an active module. 
					this.tabsPrimary = Sql.DeepCopy(tabMenus);
					if ( tabMenus.length > this.nMaxTabs )
					{
						this.tabsPrimary   = tabMenus.slice(0, this.nMaxTabs);
						this.tabsSecondary = tabMenus.slice(this.nMaxTabs, tabMenus.length);
					}
					// 09/16/2019 Paul.  If active module is in secondary, then remove and place at the end of the primary. 
					if ( !Sql.IsEmptyString(this.activeModule) )
					{
						let nPrimaryActive  : number = -1;
						let nSecondaryActive: number = -1;
						for ( let i = 0; i < this.tabsPrimary.length; i++ )
						{
							if ( this.tabsPrimary[i].MODULE_NAME == this.activeModule )
							{
								nPrimaryActive = i;
								break;
							}
						}
						for ( let i = 0; i < this.tabsSecondary.length; i++ )
						{
							if ( this.tabsSecondary[i].MODULE_NAME == this.activeModule )
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
						else if ( nPrimaryActive == -1 && this.activeModule != 'Home' )
						{
							let module: MODULE = this.SplendidCache.Module(this.activeModule, this.constructor.name + '.render');
							if ( module != null )
							{
								let activeMenu: TAB_MENU = 
								{
									MODULE_NAME   : module.MODULE_NAME,
									DISPLAY_NAME  : module.DISPLAY_NAME,
									RELATIVE_PATH : module.RELATIVE_PATH,
									EDIT_ACLACCESS: this.SplendidCache.GetUserAccess(module.MODULE_NAME, 'edit'),
									EDIT_LABEL    : null,
								};
								// 02/08/2022 Paul.  We only need to overflow if showing max tabs. 
								if ( this.tabsPrimary.length >= this.nMaxTabs )
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
				if ( this.bIsInitialized )
				{
					let sCompanyHomeImage: string = this.Crm_Config.ToString('header_home_image');
					// 10/28/2021 Paul.  Allow logo to be stored in config table as base64. 
					if ( !StartsWith(sCompanyHomeImage, 'data:image/') )
					{
						if ( Sql.IsEmptyString(sCompanyHomeImage) )
							sCompanyHomeImage = '~/Include/images/SplendidCRM_Icon.gif';
						if ( StartsWith(sCompanyHomeImage, '~/' ) )
							sCompanyHomeImage = sCompanyHomeImage.replace('~/', this.Credentials.RemoteServer);
					}
					let width: number = screenWidth();
					let sTouchTabHeight: string = '4px';
					if ( isTouchDevice() )
						sTouchTabHeight = '10px';
					let cssTouchTab  : any = { display: 'inline-block', borderWidth: '0px', height: sTouchTabHeight, width: '100%', verticalAlign: 'bottom' };
					let cssTouchImage: any = {'border-width': '0px', height: sTouchTabHeight, width: '100%' };
					this.sCompanyHomeImage = sCompanyHomeImage;
					this.width             = width        ;
					this.cssTouchTab       = cssTouchTab  ;
					this.cssTouchImage     = cssTouchImage;
				}
				else
				{
					let logoTitle : string = Sql.IsEmptyString(this.Crm_Config.ToString('company_name'      )) ? 'SplendidCRM Software, Inc.' : this.Crm_Config.ToString('company_name'      );
					let logoUrl   : string = Sql.IsEmptyString(this.Crm_Config.ToString('header_logo_image' )) ? 'SplendidCRM_Logo.gif'       : this.Crm_Config.ToString('header_logo_image' );
					let logoWidth : string = Sql.IsEmptyString(this.Crm_Config.ToString('header_logo_width' )) ? '207px'                      : this.Crm_Config.ToString('header_logo_width' );
					let logoHeight: string = Sql.IsEmptyString(this.Crm_Config.ToString('header_logo_height')) ? '60px'                       : this.Crm_Config.ToString('header_logo_height');
					// 02/17/2020 Paul.  We do not want to parse the style at this time, so just ignore the value. 
					let logoStyle : string = this.Crm_Config.ToString('arctic_header_logo_style');
					// 10/28/2021 Paul.  Allow logo to be stored in config table as base64. 
					if ( !StartsWith(logoUrl, 'data:image/') )
					{
						if ( !StartsWith(logoUrl, '~/') && !StartsWith(logoUrl, 'http') )
						{
							logoUrl = '~/Include/images/' + logoUrl;
						}
						// 08/28/2020 Paul.  Android is having trouble loading image from file system, so use base64. 
						if ( this.Credentials.RemoteServer == '' )
							logoUrl = this.Credentials.SplendidCRM_Logo;
						else
							logoUrl = logoUrl.replace('~/', this.Credentials.RemoteServer);
					}
					this.logoTitle  = logoTitle ;
					this.logoUrl    = logoUrl   ;
					this.logoWidth  = logoWidth ;
					this.logoHeight = logoHeight;
					this.logoStyle  = logoStyle ;
				}
			}
			// 05/23/2022 Paul.  Force change detection. 
			//console.log(this.constructor.name + '.ngDoCheck markForCheck');
			//this.changeDetectorRef.markForCheck();
			//this.changeDetectorRef.detectChanges();
		}
	}

	// Called once after the first ngDoCheck().
	ngAfterContentInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterContentInit');
	}

	// Called after ngAfterContentInit() and every subsequent ngDoCheck().
	ngAfterContentChecked(): void
	{
		//console.log(this.constructor.name + '.ngAfterContentChecked');
	}

	// Called once after the first ngAfterContentChecked().
	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit');
	}

	// Called after the ngAfterViewInit() and every subsequent ngAfterContentChecked().
	ngAfterViewChecked(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewChecked');
	}

	// Called immediately before Angular destroys the directive or component.
	ngOnDestroy(): void
	{
		//console.log(this.constructor.name + '.ngOnDestroy');
	}

	public Actions (sMODULE_NAME: string)
	{
		let links = new Array();
		let shortcuts: SHORTCUT[] = this.SplendidCache.Shortcuts(sMODULE_NAME);
		if ( shortcuts != null )
		{
			for ( let i = 0; i < shortcuts.length; i++ )
			{
				let shortcut: SHORTCUT = shortcuts[i];
				if ( shortcut.SHORTCUT_ACLTYPE == 'archive' )
				{
					// 09/26/2017 Paul.  If the module does not have an archive table, then hide the link. 
					let bArchiveEnabled: boolean = this.Crm_Modules.ArchiveEnabled(shortcut.MODULE_NAME);
					if ( !bArchiveEnabled )
						continue;
				}
				let nSHORTCUT_ACLTYPE = this.SplendidCache.GetUserAccess(shortcut.MODULE_NAME, shortcut.SHORTCUT_ACLTYPE, this.constructor.name + '.Actions');
				if ( nSHORTCUT_ACLTYPE >= 0 )
				{
					let sDISPLAY_NAME : string = this.L10n.Term(shortcut.DISPLAY_NAME);
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

	public Favorites(sMODULE_NAME: string)
	{
		let links = this.SplendidCache.Favorites(sMODULE_NAME);
		if ( links === undefined || links == null )
			return [];
		return links;
	}

	public LastViewed(sMODULE_NAME: string)
	{
		let links = this.SplendidCache.LastViewed(sMODULE_NAME);
		if ( links === undefined || links == null )
			return [];
		if ( links.length > this.nHistoryMaxViewed )
			links = links.slice(0, this.nHistoryMaxViewed);
		return links;
	}

	private async ReloadDashboard(sCATEGORY: string)
	{
		// 04/16/2019 Paul.  Must be authenticated to load dashboard. 
		if ( this.bIsAuthenticated )
		{
			// 05/18/2022 Paul.  Dashboards may not be needed in this area. 
			/*
			let dashboards = await Dashboards(sCATEGORY);
			if ( sCATEGORY == 'Dashboard' )
			{
				this.dashboards = dashboards;
			}
			else if ( sCATEGORY == 'Home' )
			{
				this.homeDashboards = dashboards;
			}
			// 06/02/2017 Paul.  If last dashboard not set, then show the first default dashboard. 
			let sCURRENT_DASHBOARD_ID: string = localStorage.getItem('ReactLast' + sCATEGORY);
			if ( Sql.IsEmptyString(sCURRENT_DASHBOARD_ID) && dashboards != null && dashboards.length > 0 )
			{
				sCURRENT_DASHBOARD_ID = Sql.ToString(dashboards[0]['ID']);
				localStorage.setItem('ReactLast' + sCATEGORY, sCURRENT_DASHBOARD_ID);
			}
			*/
		}
	}

	public _onAction(obj: {MODULE_NAME: string, item: any})
	{
		//console.log(this.constructor.name + '._onAction', obj);
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.actionsModule = null;
		this.menuChangeKey = this.menuChangeKey+1;
		this.router.navigateByUrl('/Reset/' + obj.item.key);
	}

	public _onFavorite(obj: {MODULE_NAME: string, item: any})
	{
		//console.log(this.constructor.name + '._onFavorite ' + obj);
		let module:MODULE = this.SplendidCache.Module(obj.MODULE_NAME, this.constructor.name + '._onFavorite');
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.actionsModule = null;
		this.menuChangeKey = this.menuChangeKey+1;
		if ( module.IS_ADMIN )
		{
			this.router.navigateByUrl('/Reset/Administration/' + obj.MODULE_NAME + '/View/' + obj.item.ID)
		}
		else
		{
			this.router.navigateByUrl('/Reset/' + obj.MODULE_NAME + '/View/' + obj.item.ID)
		}
	}

	public _onLastViewed(obj: {MODULE_NAME: string, item: any})
	{
		//console.log(this.constructor.name + '._onLastViewed ' + obj);
		let module:MODULE = this.SplendidCache.Module(obj.MODULE_NAME, this.constructor.name + '._onLastViewed');
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.actionsModule = null;
		this.menuChangeKey = this.menuChangeKey+1;
		if ( module.IS_ADMIN )
		{
			this.router.navigateByUrl('/Reset/Administration/' + obj.MODULE_NAME + '/View/' + obj.item.ID)
		}
		else
		{
			this.router.navigateByUrl('/Reset/' + obj.MODULE_NAME + '/View/' + obj.item.ID)
		}
	}

	public _onQuickCreate(sMODULE_NAME: string)
	{
		this.showInlineEdit      = true;
		this.QUICK_CREATE_MODULE = sMODULE_NAME;
		this.actionsModule       = null;
		this.menuChangeKey       = this.menuChangeKey+1;
	}

	public _onModuleTabClick(obj: {event: any, MODULE_NAME: string})
	{
		this._onModuleClick(obj.event, obj.MODULE_NAME);
	}

	public _onModuleClick(event: any, MODULE_NAME: string)
	{
		event.preventDefault();
		let module:MODULE = this.SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onModuleClick');
		// 04/26/2021 Paul.  Reports and ReportDesigner can be used interchangeably, but only one can be in the SYSTEM_REST_TABLES. 
		if ( module == null )
		{
			if ( MODULE_NAME == 'ReportDesigner' )
			{
				module = this.SplendidCache.Module('Reports', this.constructor.name + '._onModuleClick');
			}
			else if ( MODULE_NAME == 'Reports' )
			{
				module = this.SplendidCache.Module('ReportDesigner', this.constructor.name + '._onModuleClick');
			}
		}
		//console.log(this.constructor.name + '._onModuleClick ' + MODULE_NAME, module);
		if ( module != null )
		{
			// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
			this.actionsModule = null;
			this.menuChangeKey = this.menuChangeKey+1;

			console.log(this.constructor.name + '._onModuleClick', MODULE_NAME);
			// 01/23/2021 Paul.  Prevent /Administration/Administration. 
			if ( module.IS_ADMIN && MODULE_NAME != 'Administration' )
			{
				this.router.navigateByUrl(`/Reset/Administration/${MODULE_NAME}`);
			}
			else
			{
				this.router.navigateByUrl(`/Reset/${MODULE_NAME}`);
			}
		}
		else
		{
			console.error(MODULE_NAME + ' is not accessible.');
		}
	}

	private async Load(source: string)
	{
		//console.log(this.constructor.name + '.Load', source);
		let sDETAIL_NAME = 'TabMenu';
		if ( this.Credentials.ADMIN_MODE )
		{
			sDETAIL_NAME = 'TabMenu.Admin';
		}
		let arrQuickCreate = this.SplendidCache.EditViewRelationships_LoadLayout('Home.EditView');
		let menus: TAB_MENU[] = this.SplendidCache.TabMenu_Load();
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
			let tabMenus = result.filter((tabMenu: TAB_MENU)
			{
				if ( arrValidModules[tabMenu.MODULE_NAME] !== undefined )
				{
					return tabMenu;
				}
			});
			*/
			let quickCreate: any[] = [];
			//console.log(this.constructor.name + '.Load arrQuickCreate', arrQuickCreate);
			// 05/27/2019 Paul.  MODULES will be null when not authenticated. 
			if ( arrQuickCreate != null && this.SplendidCache.MODULES != null )
			{
				for (let i = 0; i < arrQuickCreate.length; i++ )
				{
					let detailRelate = arrQuickCreate[i];
					let nSHORTCUT_ACLTYPE = this.SplendidCache.GetUserAccess(detailRelate.MODULE_NAME, 'edit', this.constructor.name + '.load');
					if ( nSHORTCUT_ACLTYPE >= 0 )
					{
						try
						{
							let tabMenu: any = {};
							tabMenu.MODULE_NAME    = detailRelate.MODULE_NAME;
							tabMenu.DISPLAY_NAME   = this.L10n.Term(tabMenu.MODULE_NAME + '.LNK_NEW_' + this.Crm_Modules.SingularTableName(this.Crm_Modules.TableName(tabMenu.MODULE_NAME)));
							tabMenu.RELATIVE_PATH  = null;
							tabMenu.EDIT_ACLACCESS = this.SplendidCache.GetUserAccess(detailRelate.MODULE_NAME, 'edit');
							tabMenu.EDIT_LABEL     = null;
							quickCreate.push(tabMenu);
						}
						catch(error)
						{
							console.error(this.constructor.name + '.Load quickCreate error', error);
						}
					}
				}
			}
			//console.log(this.constructor.name + '.Load tabMenus', tabMenus);
			// 05/05/2021 Paul.  Hide quickCreate if empty. 
			let showQuickCreate: boolean = this.showQuickCreate && quickCreate.length > 0;
			// 01/10/2022 Paul.  Don't show if search panels empty. 
			let unifiedSearchItems: number = 0;
			let layout = this.SplendidCache.DetailViewRelationships('Home.UnifiedSearch');
			if ( layout != null )
				unifiedSearchItems = layout.length;
			this.tabMenus           = tabMenus          ;
			this.quickCreate        = quickCreate       ;
			this.showQuickCreate    = showQuickCreate   ;
			this.unifiedSearchItems = unifiedSearchItems;
			if ( tabMenus != null && this.SplendidCache.MODULES != null )
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

	private toggle()
	{
		this.isOpen = !this.isOpen;
	}

	public _onUnifiedSearch()
	{
		console.log(this.constructor.name + '._onUnifiedSearch', this.txtQuickSearch);
		this.router.navigateByUrl('/Reset/UnifiedSearch/' + encodeURIComponent(this.txtQuickSearch));
	}

	public _onQuickSearchChange(e: any)
	{
		let value = e.target.value;
		this.txtQuickSearch = value;
	}

	public async _onLogout()
	{
		try
		{
			// 09/04/2020 Paul.  Callback not firing on android, so set state before logout. 
			this.bIsAuthenticated = false;
			this.tabMenus         = [];
			this.quickCreate      = [];
			this.menuChangeKey    = this.menuChangeKey+1;
			// 06/23/2019 Paul.  Logout will return false when ADFS performs a logout. 
			// 09/04/2020 Paul.  Even after ADFS logout, we should still go to login page.
			// 05/18/2022 Paul.  TODO. 
			//let status = await Logout();
			//if ( status )
			{
				//LoginRedirect(this.props.history, this.constructor.name + '._onLogout');
			}
		}
		catch(error)
		{
			console.error(this.constructor.name + '._onLogout', error);
		}
	}

	public _onUserProfile()
	{
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.actionsModule = null;
		this.menuChangeKey = this.menuChangeKey+1;
		this.router.navigateByUrl('/Reset/Users/MyAccount');
	}

	public _onAdminPage()
	{
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.actionsModule = null;
		this.menuChangeKey = this.menuChangeKey+1;
		this.router.navigateByUrl('/Reset/Administration');
	}

	public _onAbout()
	{
		// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
		this.actionsModule = null;
		this.menuChangeKey = this.menuChangeKey+1;
		this.router.navigateByUrl('/Reset/Home/About');
	}

	public _onKeyDown(event: any)
	{
		//console.log(this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' )
		{
			this._onUnifiedSearch();
		}
		return false;
	}

	public _onTabTitleClick(tabMenu: TAB_MENU)
	{
		let MODULE_NAME: string = tabMenu.MODULE_NAME;
		let module:MODULE = this.SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onTabTitleClick');
		//console.log(this.constructor.name + '._onTabTitleClick ' + MODULE_NAME, module);
		if ( module != null )
		{
			// 08/21/2020 Paul.  Change to cause pop-down menu to hide. 
			// 08/21/2020 Paul.  We don't want to hide the menu for the title click.  
			//this.setState({ actionsModule: null, menuChangeKey: this.menuChangeKey+1 }, ()
			//{
				// 01/23/2021 Paul.  Prevent /Administration/Administration. 
				if ( module.IS_ADMIN && MODULE_NAME != 'Administration' )
				{
					this.router.navigateByUrl(`/Reset/Administration/${MODULE_NAME}`);
				}
				else
				{
					this.router.navigateByUrl(`/Reset/${MODULE_NAME}`);
				}
			//});
		}
		else
		{
			console.error(MODULE_NAME + ' is not accessible.');
		}
	}

	/*
	private TabTitle(activeModule, tabMenu)
	{
		// 06/30/2021 Paul.  Provide the URL to the module so that right-click-new-tab would navigate to the correct location. 
		return <a
			[class]={ (tabMenu.MODULE_NAME == activeModule ? 'current' : 'other') + 'TabLink' }
			href={ Credentials.RemoteServer + 'React/' + tabMenu.MODULE_NAME }
			style={ { textDecoration: 'none'} }
			onClick={ (e) { e.preventDefault(); this._onTabTitleClick(tabMenu); } }>
			{ L10n.Term(tabMenu.DISPLAY_NAME) }
		</a>;
	}
	*/

	private async Page_Command(sCommandName: string, sCommandArguments: any)
	{
		//console.log(this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		try
		{
			if ( sCommandName == 'Create' || EndsWith(sCommandName, '.Create') )
			{
				this.showInlineEdit      = !this.showInlineEdit;
				this.QUICK_CREATE_MODULE = null;
			}
			else if ( sCommandName == 'NewRecord' )
			{
				await this.Save();
			}
			else if ( sCommandName == 'NewRecord.Cancel' )
			{
				this.showInlineEdit      = false;
				this.QUICK_CREATE_MODULE = null;
			}
		}
		catch(error)
		{
			console.error(this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.error = error;
		}
	}

	private async Save()
	{
		try
		{
			// 05/18/2022 Paul.  TODO. 
			/*
			if ( this.editView.current != null && this.editView.current.validate() )
			{
				let row: any = this.editView.current.data;
				//console.log(this.constructor.name + '.Save ' + QUICK_CREATE_MODULE, row);
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
					console.error(this.constructor.name + '.Save', error);
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
			*/
		}
		catch(error)
		{
			console.error(this.constructor.name + '.Save', error);
			this.error = error;
		}
	}

	public editViewCallback(obj: {key: string, newValue: any})
	{
		const { key, newValue } = obj;
		//console.log(this.constructor.name + '.editViewCallback ' + DATA_FIELD, DATA_VALUE);
		let item = this.item;
		if ( item == null )
			item = {};
		item[key] = newValue;
		this.item = item;
	}

	private lastMenuChange: number = (new Date()).getTime();

	public moduleTabMouseOver(event: any, MODULE_NAME: string)
	{
		this.lastMenuChange = (new Date()).getTime();
		//console.log(this.constructor.name + '.moduleTabMouseOver ' + MODULE_NAME, event);
		// 05/07/2021 Paul.  Home does not have a dropdown menu. 
		if ( this.actionsModule != null && (MODULE_NAME == 'unifiedSearch' || MODULE_NAME == 'Home' || MODULE_NAME == 'trailingblank') )
		{
			this.actionsModule = null;
			this.menuChangeKey = this.menuChangeKey+1;
		}
		else if ( this.actionsModule != MODULE_NAME && MODULE_NAME != 'Home' )
		{
			this.actionsModule = MODULE_NAME;
			this.menuChangeKey = this.menuChangeKey+1;
		}
	}

	// 05/25/2022 Paul.  Event from module dropdown is limited to one parameter. 
	public _onModuleTabMouseLeave(obj: {event: any, MODULE_NAME: string})
	{
		//console.log(this.constructor.name + '._onModuleTabMouseLeave', obj);
		if ( this.actionsModule != null )
		{
			//console.log(this.constructor.name + '._onModuleTabMouseLeave closing', this.actionsModule);
			this.actionsModule = null;
			this.menuChangeKey = this.menuChangeKey+1;
		}
	}

	public moduleTabMouseOut(event: any, MODULE_NAME: string)
	{
		//console.log(this.constructor.name + '.moduleTabMouseOut (' + event.clientX + ', ' + event.clientY + ') ' + MODULE_NAME);
		let ctlSixToolbar: HTMLElement = document.getElementById('ctlSixToolbar');
		let pnlTabHover  : HTMLElement = document.getElementById('ctlSixToolbar_pnlTabHover');
		if ( this.actionsModule != null && ctlSixToolbar != null && pnlTabHover != null )
		{
			let rect: any = pnlTabHover.getBoundingClientRect();
			//console.log(this.constructor.name + '.moduleTabMouseOut (' + event.clientX + ', ' + event.clientY + ') ' + MODULE_NAME, rect);
			// 05/07/2021 Paul.  Home does not have a dropdown menu. 
			if ( event.clientY > rect.top || MODULE_NAME == 'unifiedSearch' || MODULE_NAME == 'Home' || MODULE_NAME == 'trailingblank' )
			{
				if ( event.clientX < rect.left || event.clientX > rect.right || event.clientY > rect.bottom )
				{
					//console.log(this.constructor.name + '.moduleTabMouseOut closing', this.actionsModule);
					this.actionsModule = null;
					this.menuChangeKey = this.menuChangeKey+1;
				}
			}
		}
	}

	public moduleTabClick (MODULE_NAME: string)
	{
		let thisMenuChange: number = (new Date()).getTime();
		//console.log(this.constructor.name + '.moduleTabClick ' + MODULE_NAME);
		if ( this.actionsModule != MODULE_NAME )
		{
			this.actionsModule = MODULE_NAME;
			this.menuChangeKey = this.menuChangeKey+1;
		}
		// 05/04/2021 Paul.  Don't close if it was just opened. On slow Samsung tablet, seems to take 111 milliseconds. 
		else if ( this.actionsModule == MODULE_NAME && (thisMenuChange - this.lastMenuChange > 300))
		{
			this.actionsModule = null;
			this.menuChangeKey = this.menuChangeKey+1;
		}
		this.lastMenuChange = (new Date()).getTime();
	}

	// 07/13/2021 Paul.  Allow right-click on menu URLs. 
	public moduleUrl(MODULE_NAME: string, ID?: string)
	{
		let module: MODULE = this.SplendidCache.Module(MODULE_NAME, this.constructor.name + '.moduleUrl');
		let url: string = this.Credentials.RemoteServer + 'React/';
		if ( module != null && module.IS_ADMIN )
			url += 'Administration/';
		url += MODULE_NAME;
		if ( ID != null && ID !== undefined )
			url += '/View/' + ID;
		return url;
	}

}
