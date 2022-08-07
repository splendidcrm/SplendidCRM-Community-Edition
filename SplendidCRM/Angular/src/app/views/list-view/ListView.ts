import { Component, OnInit, Input, Output, ViewChild, EventEmitter } from '@angular/core'   ;
import { Router, ActivatedRoute, ParamMap                          } from '@angular/router'                       ;
import { faSpinner                                                 } from '@fortawesome/free-solid-svg-icons'     ;

import { ApplicationService                                        } from '../../scripts/Application'             ;
import { SplendidCacheService                                      } from '../../scripts/SplendidCache'           ;
import { CredentialsService                                        } from '../../scripts/Credentials'             ;
import { SecurityService                                           } from '../../scripts/Security'                ;
import { L10nService                                               } from '../../scripts/L10n'                    ;
import { CrmConfigService, CrmModulesService                       } from '../../scripts/Crm'                     ;
import { EditViewService                                           } from '../../scripts/EditView'                ;
import { ModuleUpdateService                                       } from '../../scripts/ModuleUpdate'            ;
import { ActiveModuleFromPath, EndsWith                            } from '../../scripts/utility'                 ;
import Sql                                                           from '../../scripts/Sql'                     ;

import EDITVIEWS_FIELD                                               from '../../types/EDITVIEWS_FIELD'           ;
import ACL_ACCESS                                                    from '../../types/ACL_ACCESS'                ;
import MODULE                                                        from '../../types/MODULE'                    ;

import { HeaderButtonsFactoryComponent                             } from '../../Themes/HeaderButtonsFactory'                ;
import { SplendidGridComponent                                     } from '../../components/SplendidGrid'                    ;
import { SearchViewComponent                                       } from '../../views/search-view/SearchView'               ;
import { DynamicMassUpdateComponent                                } from '../../views/dynamic-mass-update/DynamicMassUpdate';

@Component({
	selector: 'ListView',
	templateUrl: './ListView.html',
})
export class ListViewComponent implements OnInit
{
	private   lastPathname          : string ;
	private   bIsInitialized        : boolean;
	private   bIsAuthenticated      : boolean;
	public    activeModule          : string ;
	public    MODULE_TITLE          : string ;
	public    spinner               = faSpinner;

	public    searchTabsEnabled     : boolean;
	public    duplicateSearchEnabled: boolean;
	public    searchMode            : string ;
	public    showUpdatePanel       : boolean;
	public    enableMassUpdate      : boolean;
	public    archiveView           : boolean;
	public    PREVIEW_ID            : string ;
	public    selectedItems         : any    ;
	public    error                 : any    ;
	// 04/09/2022 Paul.  Hide/show SearchView. 
	public    showSearchView        : string;


	@Input()  MODULE_NAME           : string;
	@Input()  LAYOUT_NAME           : string;
	@Input()  RELATED_MODULE        : string;
	@Input()  GRID_NAME             : string;
	@Input()  TABLE_NAME            : string;
	@Input()  SORT_FIELD            : string;
	@Input()  SORT_DIRECTION        : string;
	@Input()  callback              : Function;
	@Input()  rowRequiredSearch     : any;
	// 01/24/2020 Paul.  Use of this exact code in a dynamically loaded panel throws an Invariant Violation that we cannot location. 
	// So the solution is to provide cbCustomLoad input. 
	@Input()  cbCustomLoad          : EventEmitter<{sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE?: boolean, archiveView?: boolean}> = new EventEmitter<{sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE?: boolean, archiveView?: boolean}>();
	@Input()  isPrecompile          : boolean = false;
	@Output() onComponentComplete   : EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}> = new EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}>();
	// 06/03/2022 Paul.  this.headerButtons not ready in ngAfterViewInit() because of *ngIf that wraps it.
	// The solution is to use the ViewChild setter.
	private headerButtons: HeaderButtonsFactoryComponent = null;
	@ViewChild('headerButtons') set headerButtonsRef(buttons: HeaderButtonsFactoryComponent)
	{
		//console.log(this.constructor.name + '.@ViewChild headerButtons', buttons);
		if ( buttons )
		{
			this.headerButtons = buttons;
			//this._onButtonsLoaded();
		}
	};
	@ViewChild(SearchViewComponent       , {static: false}) searchView     : SearchViewComponent       ;
	@ViewChild(SplendidGridComponent     , {static: false}) splendidGrid   : SplendidGridComponent     ;
	@ViewChild(DynamicMassUpdateComponent, {static: false}) updatePanel    : DynamicMassUpdateComponent;

	public IsReady()
	{
		return this.bIsInitialized;
	}

	public IsNotReady()
	{
		return !this.IsReady();
	}

	public IsSelectionEnabled()
	{
		return this.enableMassUpdate || this.SplendidCache.GetUserAccess(this.MODULE_NAME, 'export', this.constructor.name + '.render') >= 0;
	}

	public IsAutoSaveSearch()
	{
		return this.Credentials.bSAVE_QUERY && this.Crm_Config.ToBoolean('save_query');
	}

	constructor(private router: Router, private route: ActivatedRoute, public Application: ApplicationService, public SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, public Security: SecurityService, public L10n: L10nService, public Crm_Config: CrmConfigService, private Crm_Modules: CrmModulesService, private EditView: EditViewService, private ModuleUpdate: ModuleUpdateService)
	{
		this.activeModule       = ActiveModuleFromPath(this.SplendidCache, window.location.pathname, this.constructor.name + '.constructor');
		this.lastPathname       = window.location.pathname         ;
		this.bIsInitialized     = this.SplendidCache.IsInitialized ;
		this.bIsAuthenticated   = this.Credentials.bIsAuthenticated;
		this.MODULE_NAME        = this.route.snapshot.paramMap.get('MODULE_NAME'  );
		this.MODULE_TITLE       = (this.ArchiveViewEnabled() ? '.LBL_ARCHIVE_VIEW' : '.moduleList.Home');
	}

	ngOnInit()
	{
		this.Reset('ngOnInit');
	}

	ngDoCheck(): void
	{
		//console.log(this.constructor.name + '.ngDoCheck');
		let bChanged: boolean = false;
		if ( this.lastPathname != window.location.pathname )
		{
			console.log(this.constructor.name + '.ngDoCheck pathname changed');
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
		else if ( this.SplendidCache.IsInitialized && this.activeModule != ActiveModuleFromPath(this.SplendidCache, window.location.pathname, this.constructor.name + '.ngDoCheck') )
		{
			console.log(this.constructor.name + '.ngDoCheck activeModule changed');
			bChanged = true;
		}
		if ( bChanged )
		{
			this.Reset('ngDoCheck');
		}
	}

	private async Reset(source: string)
	{
		const { Application, SplendidCache, Credentials, L10n, Crm_Modules, EditView } = this;
		this.activeModule       = ActiveModuleFromPath(this.SplendidCache, window.location.pathname, this.constructor.name + '.Reset ' + source);
		this.lastPathname       = window.location.pathname         ;
		this.bIsInitialized     = this.SplendidCache.IsInitialized ;
		this.bIsAuthenticated   = this.Credentials.bIsAuthenticated;
		this.MODULE_NAME        = this.route.snapshot.paramMap.get('MODULE_NAME'  );
		this.MODULE_TITLE       = (this.ArchiveViewEnabled() ? '.LBL_ARCHIVE_VIEW' : '.moduleList.Home');

		let archiveView: boolean = false;
		let GRID_NAME  : string = (this.LAYOUT_NAME ? this.LAYOUT_NAME : this.GRID_NAME);
		if ( window.location.pathname.indexOf('/ArchiveView') >= 0 )
		{
			archiveView = true;
			GRID_NAME   = this.MODULE_NAME + '.ArchiveView';
		}
		// 04/09/2022 Paul.  Hide/show SearchView. 
		let showSearchView: string = 'show';
		if ( SplendidCache.UserTheme == 'Pacific' )
		{
			showSearchView = localStorage.getItem(GRID_NAME + '.showSearchView');
			if ( Sql.IsEmptyString(showSearchView) )
				showSearchView = 'hide';
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Reset ' + source, this.MODULE_NAME);
		this.GRID_NAME             = GRID_NAME;
		this.searchTabsEnabled     = false;
		this.duplicateSearchEnabled= false;
		this.searchMode            = 'Basic';
		this.showUpdatePanel       = false;
		this.enableMassUpdate      = Crm_Modules.MassUpdate(this.MODULE_NAME);
		this.archiveView           = archiveView;
		this.error                 = null;
		this.showSearchView        = showSearchView;

		try
		{
			let status = await Application.AuthenticatedMethod(null, this.constructor.name + '.Reset ' + source);
			if ( status == 1 )
			{
				const { MODULE_NAME } = this;
				if ( this.SplendidCache.jsonReactState == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Reset ' + source + ' jsonReactState is null');
				}
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
				// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
				let advancedLayout : any = EditView.LoadLayout(MODULE_NAME + '.SearchAdvanced'  , true);
				let duplicateLayout: any = EditView.LoadLayout(MODULE_NAME + '.SearchDuplicates', true);
				let showUpdatePanel: boolean = false;
				let module         : MODULE  = SplendidCache.Module(MODULE_NAME, this.constructor.name + '.Reset ' + source);
				if ( module == null )
				{
					console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.Reset ' + source + ' ' + MODULE_NAME + ' not found or accessible.');
				}
				else
				{
					showUpdatePanel = module.MASS_UPDATE_ENABLED;
				}
				document.title = L10n.Term(MODULE_NAME + ".LBL_LIST_FORM_TITLE");
				// 04/26/2020 Paul.  Reset scroll every time we set the title. 
				window.scroll(0, 0);
				this.searchTabsEnabled      = !!advancedLayout ;
				this.duplicateSearchEnabled = !!duplicateLayout;
				this.showUpdatePanel        =   showUpdatePanel;
			}
			// 06/11/2022 Paul.  Must change to check for 0 to allow for busy. 
			else if ( status == 0 )
			{
				this.Application.LoginRedirect(null, this.constructor.name + '.Reset ' + source);
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Reset ' + source, error);
			this.error = error;
		}
	}

	public _onCustomLoad = (obj: {sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE?: boolean, archiveView?: boolean}) =>
	{
		this.cbCustomLoad.emit(obj);
	}

	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	public _onComponentComplete = (obj: {MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, data: any}) =>
	{
		const { MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data } = obj;
		const { error } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME, data);
		if ( this.onComponentComplete )
		{
			if ( error == null )
			{
				this.onComponentComplete.emit({MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain: data});
			}
		}
	}

	public _onSearchTabChange(key: string)
	{
		// 04/09/2022 Paul.  Hide/show SearchView. 
		if ( key == 'Hide' )
		{
			const { GRID_NAME } = this;
			this.showSearchView = 'hide';
			localStorage.setItem(GRID_NAME + '.showSearchView', this.showSearchView);
		}
		else
		{
			// 11/03/2020 Paul.  When switching between tabs, re-apply the search as some advanced settings may not have been applied. 
			this.searchMode = key;
			if ( this.searchView != null )
			{
				this.searchView.SubmitSearch();
			}
		}
	}

	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	public _onSearchViewCallback(obj: {sFILTER: string, row: any, oSORT?: any})
	{
		const { sFILTER, row, oSORT } = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback', sFILTER, row);
		// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
		if ( this.splendidGrid != null )
		{
			this.splendidGrid.Search(sFILTER, row, oSORT);
		}
	}

	public _onGridLayoutLoaded()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGridLayoutLoaded');
		// 05/08/2019 Paul.  Once we have the Search callback, we can tell the SearchView to submit and it will get to the GridView. 
		// 07/13/2019 Paul.  Call SubmitSearch directly. It will fire _onSearchViewCallback with the filter. 
		if ( this.searchView != null )
		{
			this.searchView.SubmitSearch();
		}
	}

	public _onSelectionChanged(value: any)
	{
		const { MODULE_NAME } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged: ' + MODULE_NAME, value);
		this.selectedItems = value;
		if ( this.updatePanel != null )
		{
			this.updatePanel.SelectionChanged(value);
		}
	}

	public _onUpdateComplete(sCommandName: any)
	{
		const { MODULE_NAME } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdateComplete: ' + MODULE_NAME, sCommandName);
		if ( this.searchView != null )
		{
			// 04/26/2020 Paul.  Clear selection after update. 
			if ( sCommandName == 'MassDelete' || sCommandName == 'MassUpdate' || sCommandName == 'Sync' || sCommandName == 'Unsync' || 'Archive.MoveData' || 'Archive.RecoverData' )
			{
				if ( this.splendidGrid != null )
				{
					this.splendidGrid.onDeselectAll(null);
				}
			}
			this.searchView.SubmitSearch();
		}
	}

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	public _onHyperLinkCallback(obj: {MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any})
	{
		const { MODULE_NAME, ID, NAME, row } = obj;
		let { URL } = obj;
		const { SplendidCache } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback: ' + MODULE_NAME, ID, URL);
		if ( !Sql.IsEmptyString(URL) )
		{
			if ( URL.indexOf('ArchiveView=1') >= 0 )
			{
				URL = URL.replace('ArchiveView=1', '');
				if ( EndsWith(URL, '?') )
				{
					URL = URL.substr(0, URL.length - 1);
				}
				if ( this.ArchiveViewEnabled() )
				{
					URL = URL.replace('/View/', '/ArchiveView/');
				}
			}
			this.router.navigateByUrl(URL);
		}
		else
		{
			let admin : string = '';
			let module: MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onHyperLinkCallback');
			if ( module.IS_ADMIN )
			{
				admin = '/Administration';
			}
			if ( this.ArchiveViewEnabled() )
			{
				this.router.navigateByUrl(`/Reset${admin}/${MODULE_NAME}/ArchiveView/${ID}`);
			}
			else
			{
				this.router.navigateByUrl(`/Reset${admin}/${MODULE_NAME}/View/${ID}`);
			}
		}
	}

	public async Page_Command(obj: {sCommandName: string, sCommandArguments: any})
	{
		const { sCommandName, sCommandArguments } = obj;
		const { MODULE_NAME, SplendidCache } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Create':
			{
				let admin: string = '';
				let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onHyperLinkCallback');
				if ( module.IS_ADMIN )
				{
					admin = '/Administration';
				}
				this.router.navigateByUrl(`/Reset${admin}/${MODULE_NAME}/Edit`);
				break;
			}
			// 04/09/2022 Paul.  Hide/show SearchView. 
			case 'toggleSearchView':
			{
				const { GRID_NAME } = this;
				let showSearchView: string = (this.showSearchView == 'show' ? 'hide' : 'show');
				localStorage.setItem(GRID_NAME + '.showSearchView', showSearchView);
				this.showSearchView = showSearchView;
				break;
			}
			default:
			{
				this.error = sCommandName + ' is not supported at this time';
				break;
			}
		}
	}

	public ArchiveView(): boolean
	{
		return this.archiveView;
	}

	public ArchiveViewEnabled(): boolean
	{
		const { MODULE_NAME, Crm_Modules } = this;
		return this.ArchiveView() && Crm_Modules.ArchiveEnabled(MODULE_NAME);
	}

	public async _onExport(obj: {EXPORT_RANGE: string, EXPORT_FORMAT: string})
	{
		const { EXPORT_RANGE, EXPORT_FORMAT } = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onExport', EXPORT_RANGE, EXPORT_FORMAT);
		if ( this.splendidGrid != null )
		{
			this.splendidGrid.ExportModule(EXPORT_RANGE, EXPORT_FORMAT);
		}
	}

	public async Grid_Command(obj: {sCommandName: string, sCommandArguments: any})
	{
		const { sCommandName, sCommandArguments } = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Grid_Command', sCommandName, sCommandArguments);
		if ( sCommandName == 'Preview' )
		{
			this.PREVIEW_ID = Sql.ToString(sCommandArguments);
		}
		// 11/11/2020 Paul.  We need to send the grid sort event to the SearchView. 
		else if ( sCommandName == 'sort' )
		{
			if ( this.searchView != null && sCommandArguments != null )
			{
				this.searchView.UpdateSortState(sCommandArguments.sortField, sCommandArguments.sortOrder);
			}
		}
		else
		{
			if ( this.updatePanel != null )
			{
				this.updatePanel.Page_Command(sCommandName, sCommandArguments);
			}
		}
	}

}
