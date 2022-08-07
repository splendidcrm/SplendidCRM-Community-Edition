import { Inject, Component, OnInit, OnDestroy, AfterContentInit, AfterContentChecked, AfterViewInit, AfterViewChecked, SimpleChanges} from '@angular/core';
import { SplendidCacheService                } from '../../scripts/SplendidCache'  ;
import { CredentialsService                  } from '../../scripts/Credentials'     ;
import { SecurityService                     } from '../../scripts/Security'        ;
import { L10nService                         } from '../../scripts/L10n'            ;
import { CrmConfigService, CrmModulesService } from '../../scripts/Crm'             ;
import { StartsWith, EndsWith, ActiveModuleFromPath } from '../../scripts/utility'                 ;
import Sql                                     from '../../scripts/Sql'                     ;
import MODULE                                  from '../../types/MODULE'                    ;
import TAB_MENU                                from '../../types/TAB_MENU'                  ;
import SHORTCUT                                from '../../types/SHORTCUT'                  ;

interface ITopNavState
{
	bIsInitialized     : boolean;
	lastPathname       : string;
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
	actionsModule      : string;
	showUnifiedSearch  : boolean;
	showQuickCreate    : boolean;
	unifiedSearchItems : number;  // 01/10/2022 Paul.  Don't show if search panels empty. 
}

@Component({
	selector: 'PacificTopNav',
	templateUrl: './TopNav.html',
})
export class PacificTopNavComponent implements OnInit, OnDestroy, AfterContentInit, AfterContentChecked, AfterViewInit, AfterViewChecked
{
	private state                : ITopNavState;
	private tabMenuRect          : Record<string, DOMRect> = {};
	private themeURL             : string;
	private tabsPrimary          : TAB_MENU[] = [];
	private tabsSecondary        : TAB_MENU[] = [];

	constructor(protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, protected Security: SecurityService, protected L10n: L10nService, private Crm_Config: CrmConfigService, private Crm_Module: CrmModulesService)
	{
		let activeModule: string = ActiveModuleFromPath(SplendidCache, window.location.pathname, this.constructor.name + '.constructor');
		this.themeURL = Credentials.sREMOTE_SERVER + 'App_Themes/' + SplendidCache.UserTheme + '/';
		// 01/08/2020 Paul.  Pull the current value from the URL so that we can reload after submit. 
		let txtQuickSearch: string = '';
		if ( window.location.pathname.indexOf('/UnifiedSearch/') >= 0 )
		{
			txtQuickSearch = window.location.pathname.substr(15);
		}
		console.log(this.constructor.name + '.constructor', activeModule, window.location.pathname, '[' + txtQuickSearch + ']');
		this.state =
		{
			bIsInitialized     : this.SplendidCache.IsInitialized,
			lastPathname       : window.location.pathname,
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
			actionsModule      : null,
			showUnifiedSearch  : true,
			showQuickCreate    : true,
			unifiedSearchItems : 0,
		};
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
		console.log(this.constructor.name + '.ngDoCheck');
	}

	// Called once after the first ngDoCheck().
	ngAfterContentInit(): void
	{
		console.log(this.constructor.name + '.ngAfterContentInit');
	}

	// Called after ngAfterContentInit() and every subsequent ngDoCheck().
	ngAfterContentChecked(): void
	{
		console.log(this.constructor.name + '.ngAfterContentChecked');
	}

	// Called once after the first ngAfterContentChecked().
	ngAfterViewInit(): void
	{
		console.log(this.constructor.name + '.ngAfterViewInit');
	}

	// Called after the ngAfterViewInit() and every subsequent ngAfterContentChecked().
	ngAfterViewChecked(): void
	{
		console.log(this.constructor.name + '.ngAfterViewChecked');
	}

	// Called immediately before Angular destroys the directive or component.
	ngOnDestroy(): void
	{
		console.log(this.constructor.name + '.ngOnDestroy');
	}
}
