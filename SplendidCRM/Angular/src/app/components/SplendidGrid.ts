import { Component, OnInit, Input, Output, ViewChild, EventEmitter } from '@angular/core'                      ;
import { Router, ActivatedRoute, ParamMap                          } from '@angular/router'                    ;
import { XMLParser, XMLBuilder }                                     from 'fast-xml-parser'                    ;
import { faSpinner, faFileExport, faList                           } from '@fortawesome/free-solid-svg-icons'  ;

import { ApplicationService                                        } from '../scripts/Application'             ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'           ;
import { CredentialsService                                        } from '../scripts/Credentials'             ;
import { SecurityService                                           } from '../scripts/Security'                ;
import { L10nService                                               } from '../scripts/L10n'                    ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'                     ;
import { ListViewService                                           } from '../scripts/ListView'                ;
import { ModuleUpdateService                                       } from '../scripts/ModuleUpdate'            ;
import Sql                                                           from '../scripts/Sql'                     ;
import SplendidDynamic                                               from '../scripts/SplendidDynamic'         ;
import { Trim                                                      } from '../scripts/utility'                 ;

import GRIDVIEWS_COLUMN                                              from '../types/GRIDVIEWS_COLUMN'          ;
import ACL_ACCESS                                                    from '../types/ACL_ACCESS'                ;
import ACL_FIELD_ACCESS                                              from '../types/ACL_FIELD_ACCESS'          ;
import MODULE                                                        from '../types/MODULE'                    ;

import { DynamicButtonsComponent                                   } from '../components/DynamicButtons'       ;

@Component({
	selector: 'SplendidGrid',
	templateUrl: './SplendidGrid.html',
})
export class SplendidGridComponent implements OnInit
{
	public    JSON                    = JSON        ;
	public    spinner                 = faSpinner   ;
	public    fileExport              = faFileExport;
	public    list                    = faList      ;
	// ISplendidGridProps
	@Input()  MODULE_NAME             : string  = null;
	@Input()  RELATED_MODULE          : string  = null;
	@Input()  GRID_NAME               : string  = null;
	@Input()  TABLE_NAME              : string  = null;
	@Input()  SORT_FIELD              : string  = null;
	@Input()  SORT_DIRECTION          : string  = null;
	@Input()  PRIMARY_FIELD           : string  = null;
	@Input()  PRIMARY_ID              : string  = null;
	// 10/12/2020 Paul.  ADMIN_MENU is incorrect.  Use ADMIN_MODE instead. 
	@Input()  ADMIN_MODE              : boolean = null;
	@Input()  scrollable              : boolean = null;
	@Input()  deferLoad               : boolean = null;
	@Input()  isPopupView             : boolean = null;
	@Input()  readonly                : boolean = null;
	@Input()  enableSelection         : boolean = null;
	@Input()  deleteRelated           : boolean = null;
	@Input()  disableView             : boolean = null;
	@Input()  disableEdit             : boolean = null;
	@Input()  disableRemove           : boolean = null;
	@Input()  enableFavorites         : boolean = null;
	@Input()  enableFollowing         : boolean = null;
	@Input()  archiveView             : boolean = null;
	@Input()  enableMassUpdate        : boolean = null;
	@Input()  disablePagination       : boolean = null;
	@Input()  rowRequiredSearch       : any     = null;
	@Input()  disableInitialLoading   : boolean = null;
	@Input()  ignoreMissingLayout     : boolean = null;
	@Input()  AutoSaveSearch          : boolean = null;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	@Input()  isPrecompile            : boolean = null;
	// 04/10/2022 Paul.  Move Pacific Export to pagination header. 
	@Input()  enableExportHeader      : boolean = null;

	@Output() selectionChanged        : EventEmitter<any                                                                          > = new EventEmitter<any                                                                          >();
	@Output() onLayoutLoaded          : EventEmitter<void                                                                         > = new EventEmitter<void                                                                         >();
	@Output() cbRemove?               : EventEmitter<any                                                                          > = new EventEmitter<any                                                                          >();
	@Output() cbShowRemove?           : EventEmitter<any                                                                          > = new EventEmitter<any                                                                          >();
	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	@Output() hyperLinkCallback       : EventEmitter<{MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}      > = new EventEmitter<{MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}      >();
	@Output() cbCustomLoad            : EventEmitter<{sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE?: boolean, archiveView?: boolean}> = new EventEmitter<{sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE?: boolean, archiveView?: boolean}>();
	@Output() cbCustomColumns         : EventEmitter<{sLIST_MODULE_NAME: string, layout: any, sPRIMARY_MODULE: string, sPRIMARY_ID: string}> = new EventEmitter<{sLIST_MODULE_NAME: string, layout: any, sPRIMARY_MODULE: string, sPRIMARY_ID: string}>();
	@Output() Page_Command            : EventEmitter<{sCommandName: string, sCommandArguments: any}                               > = new EventEmitter<{sCommandName: string, sCommandArguments: any}                               >();
	@Output() onComponentComplete     : EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, data: any}> = new EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, data: any}>();

	public lastPathname              : string = null;
	public themeURL                  : string = null;
	public legacyIcons               : boolean = false;
	public searchCount               : number  = 0;
	public chkPacificSelection       : HTMLInputElement = null;
	public dynamicButtons            : DynamicButtonsComponent = null;
	@ViewChild('dynamicButtons') set dynamicButtonsRef(buttons: DynamicButtonsComponent)
	{
		//console.log(this.constructor.name + '.@ViewChild headerButtons', buttons);
		if ( buttons )
		{
			this.dynamicButtons = buttons;
			//this._onButtonsLoaded();
		}
	};

	// ISplendidGridState
	public layout                  : any      = null;
	public layoutAvailable         : any      = null;
	public vwMain                  : any      = null;
	public columns                 : any      = null;
	public __total                 : number   = null;
	public __sql                   : string   = null;
	public SEARCH_FILTER           : string   = null;
	public SEARCH_VALUES           : any      = null;
	public SELECT_FIELDS           : any      = null;
	//public OnMainClicked           : Function;
	// 08/31/2014 Paul.  Provide a way for the Offline Client to hide View and Edit buttons. 
	//HIDE_VIEW_EDIT          : boolean;
	// 02/27/2016 Paul.  Provide a way to hide the delete for LineItems. 
	//HIDE_DELETE             : boolean;
	public SHOW_CONFLICTS          : boolean  = null;
	public loaded                  : boolean  = null;
	public activePage              : number   = null;
	public selectedItems           : any      = null;
	public selectedKeys            : string[] = null;
	public checkedCount            : number   = null;
	public allChecked              : boolean  = null;
	public TOP                     : number   = null;
	public error                   : any;
	// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
	public tableKey                : string;
	public loading                 : boolean  = null;
	public exporting               : boolean  = null;
	public isOpenFieldChooser      : boolean  = null;
	public columnsChangedKey       : number   = null;
	public nSelectionKey           : number   = null;
	// 04/10/2022 Paul.  Move Pacific Export to pagination header. 
	public EXPORT_RANGE            : string   = null;
	public EXPORT_FORMAT           : string   = null;
	public EXPORT_RANGE_LIST       : any[]    = null;
	public EXPORT_FORMAT_LIST      : any[]    = null;

	public sTheme                  : string   = null;

	public IsReady()
	{
		return this.SplendidCache.IsInitialized && this.vwMain;
	}

	public IsError()
	{
		return !this.IsReady() && this.error != null;
	}

	public IsLoading()
	{
		return !this.IsReady() && this.error != null && this.loading;
	}

	public min(a: number, b: number)
	{
		return Math.min(a, b);
	}

	constructor(private router: Router, private route: ActivatedRoute, public Application: ApplicationService, public SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, public Security: SecurityService, public L10n: L10nService, public Crm_Config: CrmConfigService, private Crm_Modules: CrmModulesService, private ListView: ListViewService, private ModuleUpdate: ModuleUpdateService)
	{
	}

	ngOnInit()
	{
		const { SplendidCache, Credentials, L10n, Crm_Config, Crm_Modules } = this;
		let nTOP = Crm_Config.ToInteger('list_max_entries_per_page');
		if ( nTOP <= 0 )
		{
			nTOP = 25;
		}
		let enableFavorites: boolean = this.enableFavorites && !Crm_Config.ToBoolean('disable_favorites');
		// 08/06/2020 Paul.  Flag should be all lower case. 
		let enableFollowing: boolean = this.enableFollowing && !Crm_Config.ToBoolean('disable_following') && Crm_Config.ToBoolean('enable_activity_streams') && Crm_Modules.StreamEnabled(this.MODULE_NAME);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		this.sTheme = SplendidCache.UserTheme;

		// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
		let SORT_FIELD    : string = (this.SORT_FIELD     ? this.SORT_FIELD     : 'NAME');
		let SORT_DIRECTION: string = (this.SORT_DIRECTION ? this.SORT_DIRECTION : 'asc' );
		let GRID_NAME     : string = (this.GRID_NAME      ? this.GRID_NAME      : this.MODULE_NAME + (!!this.isPopupView ? '.PopupView' : '.ListView'));
		let GRIDVIEW      : any    = SplendidCache.GridViews(GRID_NAME, true);
		if ( GRIDVIEW )
		{
			if ( Sql.IsEmptyString(this.SORT_FIELD) && !Sql.IsEmptyString(GRIDVIEW.SORT_FIELD) )
			{
				SORT_FIELD     = GRIDVIEW.SORT_FIELD    ;
				SORT_DIRECTION = GRIDVIEW.SORT_DIRECTION;
			}
		}
		// 04/10/2022 Paul.  Move Pacific Export to pagination header. 
		let EXPORT_RANGE            : string = 'All'  ;
		let EXPORT_FORMAT           : string = 'Excel';
		let EXPORT_RANGE_LIST       : any[]  = [];
		let EXPORT_FORMAT_LIST      : any[]  = [];
		EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_ENTIRE'  ), NAME: 'All'     });
		EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_CURRENT' ), NAME: 'Page'    });
		// 03/18/2021 Paul.  Lists without selection checkboxes should not allow Selected option. 
		if ( this.enableSelection )
			EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_SELECTED'), NAME: 'Selected'});
		
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_XML_SPREADSHEET'  ), NAME: 'Excel'   });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_XML'              ), NAME: 'xml'     });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_CUSTOM_CSV'       ), NAME: 'csv'     });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_CUSTOM_TAB'       ), NAME: 'tab'     });
		this.layout             = null;
		this.vwMain             = null;
		this.columns            = [];
		this.__total            = 0;
		this.__sql              = null;
		this.SORT_FIELD         = SORT_FIELD;
		this.SORT_DIRECTION     = SORT_DIRECTION;
		this.GRID_NAME          = GRID_NAME;
		this.SELECT_FIELDS      = {};
		this.SEARCH_FILTER      = '';
		this.SEARCH_VALUES      = null;
		//this.OnMainClicked      = null;
		this.TABLE_NAME         = Sql.ToString(this.TABLE_NAME     );
		this.RELATED_MODULE     = Sql.ToString(this.RELATED_MODULE);
		this.PRIMARY_FIELD      = Sql.ToString(this.PRIMARY_FIELD  );
		this.PRIMARY_ID         = Sql.ToString(this.PRIMARY_ID     );
		//this.HIDE_VIEW_EDIT   = : false;
		//this.HIDE_DELETE      = : false;
		this.SHOW_CONFLICTS     = false;
		this.loaded             = false;
		this.activePage         = 1;
		this.selectedItems      = {};
		this.selectedKeys       = [];
		this.checkedCount       = 0;
		this.allChecked         = false;
		this.TOP                = nTOP;
		this.enableFavorites    = enableFavorites;
		this.enableFollowing    = enableFollowing;
		this.error              = null;
		this.tableKey           = this.GRID_NAME;
		this.loading            = !Sql.ToBoolean(this.disableInitialLoading);
		this.exporting          = false;
		this.isOpenFieldChooser = false;
		this.columnsChangedKey  = 0;
		this.nSelectionKey      = 0,
		this.EXPORT_RANGE       = EXPORT_RANGE      ;
		this.EXPORT_FORMAT      = EXPORT_FORMAT     ;
		this.EXPORT_RANGE_LIST  = EXPORT_RANGE_LIST ;
		this.EXPORT_FORMAT_LIST = EXPORT_FORMAT_LIST;
	}

	async ngDoCheck()
	{
		const { SplendidCache, L10n, Crm_Config, MODULE_NAME, isPopupView } = this;
		//console.log(this.constructor.name + '.ngDoCheck', MODULE_NAME);
		let bChanged: boolean = false;
		if ( this.lastPathname != window.location.pathname )
		{
			//console.log(this.constructor.name + '.ngDoCheck ' + MODULE_NAME + ' pathname changed');
			bChanged = true;
		}
		if ( bChanged )
		{
			this.lastPathname = window.location.pathname;
			let GRID_NAME      = (this.GRID_NAME      ? this.GRID_NAME      : MODULE_NAME + (isPopupView ? '.PopupView' : '.ListView'));
			let SORT_FIELD     = (this.SORT_FIELD     ? this.SORT_FIELD     : 'NAME');
			let SORT_DIRECTION = (this.SORT_DIRECTION ? this.SORT_DIRECTION : 'asc' );
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', GRID_NAME);
			// 05/27/2018 Paul.  If the location changes, then we need an all new state. 
			let nTOP = Crm_Config.ToInteger('list_max_entries_per_page');
			this.layout                  = null;
			this.vwMain                  = null;
			this.columns                 = [];
			this.__total                 = 0;
			this.SORT_FIELD              = SORT_FIELD;
			this.SORT_DIRECTION          = SORT_DIRECTION;
			this.GRID_NAME               = GRID_NAME;
			this.SELECT_FIELDS           = {};
			this.SEARCH_FILTER           = '';
			this.SEARCH_VALUES           = null;
			//this.OnMainClicked           = null;
			this.TABLE_NAME              = Sql.ToString(this.TABLE_NAME    );
			this.RELATED_MODULE          = Sql.ToString(this.RELATED_MODULE);
			this.PRIMARY_FIELD           = Sql.ToString(this.PRIMARY_FIELD );
			this.PRIMARY_ID              = Sql.ToString(this.PRIMARY_ID    );
			//this.HIDE_VIEW_EDIT        = : false;
			//this.HIDE_DELETE           = : false;
			this.SHOW_CONFLICTS          = false;
			this.loaded                  = false;
			this.activePage              = 1;
			this.selectedItems           = {};
			this.selectedKeys            = [];
			this.allChecked              = false;
			this.TOP                     = nTOP;
			// 06/24/2019 Paul.  When changing between list views, componentDidMount will fire, so we need the same preload. 
			await this.preload();
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
		const { MODULE_NAME, RELATED_MODULE, GRID_NAME, vwMain } = this;
		// 06/03/2022 Paul.  this.headerButtons not ready in ngAfterViewInit() because of *ngIf that wraps it. 
		//console.log(this.constructor.name + '.ngAfterViewInit headerButtons', this.headerButtons);
		if ( this.onComponentComplete.observed )
		{
			const { GRID_NAME, layout, vwMain, error } = this;
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + GRID_NAME, vwMain);
			if ( layout != null && vwMain != null && error == null )
			{
				this.onComponentComplete.emit({MODULE_NAME, RELATED_MODULE, LAYOUT_NAME: GRID_NAME, data: vwMain});
			}
		}
	}

	// Called after the ngAfterViewInit() and every subsequent ngAfterContentChecked().
	ngAfterViewChecked(): void
	{
		// 06/03/2022 Paul.  this.headerButtons not ready in ngAfterViewInit() because of *ngIf that wraps it. 
		//console.log(this.constructor.name + '.ngAfterViewChecked headerButtons', this.headerButtons);
	}

	// Called immediately before Angular destroys the directive or component.
	ngOnDestroy(): void
	{
		//console.log(this.constructor.name + '.ngOnDestroy');
	}

	public async preload()
	{
		const { MODULE_NAME } = this;
		const { GRID_NAME } = this;
		try
		{
			let status = await this.Application.AuthenticatedMethod(null, this.constructor.name + '.preload');
			if ( status == 1 )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.preload Authenticated', MODULE_NAME);
				await this.Load(MODULE_NAME, GRID_NAME);
			}
			else
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.preload Not authenticated, redirect to login', MODULE_NAME);
				this.Application.LoginRedirect(null, this.constructor.name + '.preload');
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.preload ', error);
			this.error = error;
		}
	}

	public async Load(sMODULE_NAME: string, GRID_NAME: string)
	{
		const { ignoreMissingLayout, ListView } = this;
		const { SORT_FIELD, SORT_DIRECTION, RELATED_MODULE } = this;
		let sSORT_FIELD = SORT_FIELD;
		let sSORT_DIRECTION = SORT_DIRECTION;
		/*
		this.setState({ MODULE_NAME: sMODULE_NAME, GRID_NAME: GRID_NAME, SEARCH_FILTER: '', SEARCH_VALUES: null });
		*/
		// 07/29/2019 Pa8l.  I don't recall the reason for this correction. 
		if ( Sql.IsEmptyString(sSORT_FIELD) && Sql.IsEmptyString(RELATED_MODULE) )
		{
			if ( sMODULE_NAME == 'Quotes' )
			{
				sSORT_FIELD         = 'QUOTE_NUM';
				sSORT_DIRECTION     = 'desc';
				this.SORT_FIELD     = sSORT_FIELD;
				this.SORT_DIRECTION = sSORT_DIRECTION;
			}
			else if ( sMODULE_NAME == 'Orders' )
			{
				sSORT_FIELD         = 'ORDER_NUM';
				sSORT_DIRECTION     = 'desc';
				this.SORT_FIELD     = sSORT_FIELD;
				this.SORT_DIRECTION = sSORT_DIRECTION;
			}
			else if ( sMODULE_NAME == 'Invoices' )
			{
				sSORT_FIELD         = 'INVOICE_NUM';
				sSORT_DIRECTION     = 'desc';
				this.SORT_FIELD     = sSORT_FIELD;
				this.SORT_DIRECTION = sSORT_DIRECTION;
			}
		}
		//this.OnMainClicked = bLIST_VIEW_ENABLE_SELECTION ? SelectionUI_chkMain_Clicked : null;

		try
		{
			const layout = ListView.LoadLayout(GRID_NAME, ignoreMissingLayout);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load layout ' + GRID_NAME, layout);
			// 03/25/2022 Paul.  Add support for field chooser. 
			const layoutAvailable = ListView.LoadLayout(GRID_NAME + '.Available', true);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load layoutAvailable', GRID_NAME + '.Available', layoutAvailable);
			// 06/19/2018 Paul.  Make sure to clear the data when loading the layout. 
			let SELECT_FIELDS = this.GridColumns(layout);
			let columns: any[] = null;
			if ( this.cbCustomColumns.observed )
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Load cbCustomColumns.observed');
				// 06/14/2022 Paul.  TODO.  Support custom columns. 
				//columns = this.cbCustomColumns.emit({sLIST_MODULE_NAME: GRID_NAME, layout: layout, sPRIMARY_MODULE: sMODULE_NAME, sPRIMARY_ID: null});
			}
			else
			{
				columns = this.BootstrapColumns(GRID_NAME, layout, sMODULE_NAME, null);
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', arrSELECT_FIELDS, columns);
			this.layout          = layout;
			this.layoutAvailable = layoutAvailable;
			this.__total         = 0;
			this.vwMain          = null;
			this.SELECT_FIELDS   = SELECT_FIELDS;
			this.columns         = columns;
			if ( this.onLayoutLoaded.observed )
			{
				this.onLayoutLoaded.emit();
			}
			// 04/27/2019 Paul.  Always defer load, otherwise the main lists will query twice. 
			if ( !this.deferLoad )
			{
				await this.Sort(sSORT_FIELD, sSORT_DIRECTION);
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', error);
			this.error = error;
		}
	}

	public GridColumns(layout: any)
	{
		const { MODULE_NAME, TABLE_NAME, SplendidCache, Crm_Modules } = this;
		// 08/06/2020 Paul.  Additional conditions applied to flags. 
		const { enableFavorites, enableFollowing } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.GridColumns', layout);
		let arrSelectFields = Sql.SelectGridColumns(SplendidCache, layout);

		// 05/01/2019 Paul.  The Edit button will be hidden if a process is pending. 
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '.GridColumns');
		if ( module != null )
		{
			if ( Sql.ToBoolean(module.PROCESS_ENABLED) )
			{
				if ( TABLE_NAME == Crm_Modules.TableName(MODULE_NAME) )
				{
					arrSelectFields.push('PENDING_PROCESS_ID');
				}
			}
		}
		else
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.GridColumns module not found', MODULE_NAME);
		}
		if ( enableFavorites )
		{
			arrSelectFields.push('FAVORITE_RECORD_ID');
		}
		if ( enableFollowing )
		{
			arrSelectFields.push('SUBSCRIPTION_PARENT_ID');
		}
		return arrSelectFields.join(',');
	}

	public formatKey(ID: string, i: number)
	{
		return ID + '_' + i.toString();
	}

	public createKeys = (results: Array<any>) =>
	{
		const { selectedItems, Crm_Config } = this;
		// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
		let selectedKeys: string[] = [];
		if ( results != null )
		{
			for ( let i = 0; i < results.length; i++ )
			{
				let row = results[i];
				// 12/25/2019 Paul.  For performance, we will want to pre-process each row and create arrERASED_FIELDS for each row. 
				if ( Crm_Config.enable_data_privacy() )
				{
					if ( row['ERASED_FIELDS'] !== undefined )
					{
						let arrERASED_FIELDS: string[] = Sql.ToString(row['ERASED_FIELDS']).split(',');
						row['arrERASED_FIELDS'] = arrERASED_FIELDS;
					}
				}
				row.ID_key = this.formatKey(row.ID, i);
				// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
				if ( selectedItems[row.ID] )
				{
					selectedKeys.push(row.ID_key);
				}
			}
		}
		return selectedKeys;
	}

	public boundColumnFormatter = (cell: any, row: any, rowIndex: number, formatExtraData: any) =>
	{
		// 05/27/2018 Paul.  We will need all the layout fields in the render function. 
		let lay = formatExtraData.data.layout;
		return {tag: 'String', props: { layout: lay, row: row, multiLine: false }};
	}

	public templateColumnFormatter = (cell: any, row: any, rowIndex: number, formatExtraData: any) =>
	{
		const { hyperLinkCallback, ADMIN_MODE, isPopupView, Page_Command, Security, Crm_Config } = this;
		// 05/27/2018 Paul.  We will need all the layout fields in the render function.  
		let lay = formatExtraData.data.layout;
		let COLUMN_TYPE                = lay.COLUMN_TYPE;
		let COLUMN_INDEX               = lay.COLUMN_INDEX;
		let HEADER_TEXT                = lay.HEADER_TEXT;
		let SORT_EXPRESSION            = lay.SORT_EXPRESSION;
		let ITEMSTYLE_WIDTH            = lay.ITEMSTYLE_WIDTH;
		let ITEMSTYLE_CSSCLASS         = lay.ITEMSTYLE_CSSCLASS;
		let ITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN;
		let ITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN;
		// 10/30/2020 Paul.  ITEMSTYLE_WRAP defaults to true. 
		let ITEMSTYLE_WRAP             = (lay.ITEMSTYLE_WRAP == null ? true : lay.ITEMSTYLE_WRAP);
		let DATA_FIELD                 = lay.DATA_FIELD;
		let DATA_FORMAT                = lay.DATA_FORMAT;
		let URL_FIELD                  = lay.URL_FIELD;
		let URL_FORMAT                 = lay.URL_FORMAT;
		let URL_TARGET                 = lay.URL_TARGET;
		let LIST_NAME                  = lay.LIST_NAME;
		let URL_MODULE                 = lay.URL_MODULE;
		let URL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD;
		let VIEW_NAME                  = lay.VIEW_NAME;
		let MODULE_NAME                = lay.MODULE_NAME;
		let MODULE_TYPE                = lay.MODULE_TYPE;
		let PARENT_FIELD               = lay.PARENT_FIELD;

		let DATA_VALUE = '';
		if ( row[DATA_FIELD] != null || row[DATA_FIELD] === undefined )
		{
			// 12/01/2012 Paul.  Users cannot be viewed or edited. 
			// 12/04/2012 Paul.  We are going to allow users to be viewed and edited. 
			// 12/05/2012 Paul.  Only allow Users module if in Admin mode. 
			// 07/09/2019 Paul.  User selection is allowed in a popup. 
			try
			{
				// 10/12/2020 Paul.  ADMIN_MENU is incorrect.  Use ADMIN_MODE instead. 
				// 10/14/2020 Paul.  An admin can click on a user link. 
				if ( DATA_FORMAT == 'HyperLink' && (isPopupView || ADMIN_MODE || Security.IS_ADMIN() || URL_MODULE != 'Users') )
				{
					return {tag: 'HyperLink', props: { layout: lay, row: row, hyperLinkCallback }};
				}
				else if ( DATA_FORMAT == 'Date' )
				{
					return {tag: 'DateTime', props: { layout: lay, row: row, dateOnly: true }};
				}
				else if ( DATA_FORMAT == 'DateTime' )
				{
					return {tag: 'DateTime', props: { layout: lay, row: row, dateOnly: false }};
				}
				else if ( DATA_FORMAT == 'Currency' )
				{
					let oNumberFormat = Security.NumberFormatInfo();
					if ( Crm_Config.ToString('currency_format') == 'c0' )
					{
						oNumberFormat.CurrencyDecimalDigits = 0;
					}
					return {tag: 'Currency', props: { layout: lay, row: row, numberFormat: oNumberFormat }};
				}
				else if ( DATA_FORMAT == 'MultiLine' )
				{
					return {tag: 'String', props: { layout: lay, row: row, multiLine: true }};
				}
				else if ( DATA_FORMAT == 'Image' )
				{
					return {tag: 'Image', props: { layout: lay, row: row }};
				}
				else if ( DATA_FORMAT == 'JavaScript' )
				{
					return {tag: 'JavaScript', props: { layout: lay, row: row }};
				}
				else if ( DATA_FORMAT == 'Hover' )
				{
					return {tag: 'Hover', props: { layout: lay, row: row }};
				}
				else if ( DATA_FORMAT == 'ImageButton' )
				{
					return {tag: 'ImageButton', props: { layout: lay, row: row, Page_Command: Page_Command }};
				}
				// 01/18/2020 Paul.  New LinkButton is only supported in React Client. 
				else if ( DATA_FORMAT == 'LinkButton' )
				{
					return {tag: 'LinkButton', props: { layout: lay, row: row, Page_Command: Page_Command }};
				}
				// 11/10/2020 Paul.  New CheckBox is only supported in React Client. 
				else if ( DATA_FORMAT == 'CheckBox' )
				{
					return {tag: 'CheckBox', props: { layout: lay, row: row }};
				}
				// 05/15/2016 Paul.  Add Tags module. 
				else if ( DATA_FORMAT == 'Tags' )
				{
					return {tag: 'Tags', props: { layout: lay, row: row }};
				}
				else
				{
					return {tag: 'String', props: { layout: lay, row: row, multiLine: false }};
				}
			}
			catch(error: any)
			{
				DATA_VALUE = error.message;
			}
		}
		return DATA_VALUE;
	}

	public _onEdit(row: any)
	{
		const { router, MODULE_NAME, ADMIN_MODE, SplendidCache } = this;
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onEdit');
		if ( module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		router.navigateByUrl(`/Reset${admin}/${MODULE_NAME}/Edit/${row.ID}`);
		return false;
	}

	public _onView(row: any)
	{
		const { router, MODULE_NAME, ADMIN_MODE, SplendidCache } = this;
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onView');
		if ( module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		router.navigateByUrl(`/Reset${admin}/${MODULE_NAME}/View/${row.ID}`);
		return false;
	}

	// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
	public getEditUrl(row: any): string
	{
		const { MODULE_NAME, ADMIN_MODE, SplendidCache, Credentials } = this;
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '.getEditUrl');
		if ( module.IS_ADMIN )
		{
			admin = 'Administration/';
		}
		let url: string = Credentials.RemoteServer + `React/${admin}${MODULE_NAME}/Edit/${row.ID}`;
		return url;
	}

	public getViewUrl(row: any): string
	{
		const { MODULE_NAME, ADMIN_MODE, SplendidCache, Credentials } = this;
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onView');
		if ( module.IS_ADMIN )
		{
			admin = 'Administration/';
		}
		let url: string = Credentials.RemoteServer + `React/${admin}${MODULE_NAME}/View/${row.ID}`;
		return url;
	}

	public async _onChangeFavorites(row: any, rowIndex: number)
	{
		const { MODULE_NAME, ModuleUpdate } = this;
		let { vwMain } = this;
		try
	{
			if ( Sql.IsEmptyGuid(row['FAVORITE_RECORD_ID']) )
			{
				// Include/javascript/Utilities.asmx/AddToFavorites
				await ModuleUpdate.AddToFavorites(MODULE_NAME, row['ID']);
				vwMain[rowIndex]['FAVORITE_RECORD_ID'] = row['ID'];
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.vwMain   = vwMain;
				this.tableKey = this.tableKey + '*';
			}
			else
			{
				await ModuleUpdate.RemoveFromFavorites(MODULE_NAME, row['ID']);
				vwMain[rowIndex]['FAVORITE_RECORD_ID'] = null;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.vwMain   = vwMain;
				this.tableKey = this.tableKey + '*';
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeFavorites', error);
			this.error = error;
		}
		return false;
	}

	public async _onChangeFollowing(row: any, rowIndex: number)
	{
		const { MODULE_NAME, ModuleUpdate } = this;
		let { vwMain } = this;
		try
		{
			if ( Sql.IsEmptyGuid(row['SUBSCRIPTION_PARENT_ID']) )
			{
				// Include/javascript/Utilities.asmx/AddSubscription
				await ModuleUpdate.AddSubscription(MODULE_NAME, row['ID']);
				vwMain[rowIndex]['SUBSCRIPTION_PARENT_ID'] = row['ID'];
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.vwMain   = vwMain;
				this.tableKey = this.tableKey + '*';
			}
			else
			{
				await ModuleUpdate.RemoveSubscription(MODULE_NAME, row['ID']);
				vwMain[rowIndex]['SUBSCRIPTION_PARENT_ID'] = null;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.vwMain   = vwMain;
				this.tableKey = this.tableKey + '*';
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeFollowing', error);
			this.error = error;
		}
		return false;
	}

	public editviewColumnFormatter = (cell: any, row: any, rowIndex: number, formatExtraData: any) =>
	{
		// 04/13/2021 Paul.  Disable edit in archiveView. 
		const { MODULE_NAME, disableView, disableEdit, archiveView, SplendidCache } = this;
		// 08/06/2020 Paul.  Additional conditions applied to flags. 
		const { enableFavorites, enableFollowing } = this;
		// 05/01/2019 Paul.  The edit button should be hidden if a process is pending on the record. 
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 08/11/2019 Paul.  Make sure the user has permission to create a record before loading the layout. 
		// sASSIGNED_USER_ID_FIELD is almost always ASSIGNED_USER_ID, but it is ACITIVTY_ASSIGNED_USER_ID for activities. 
		// Another exception is when using delete or remove with a relationship whereby the parent module assigned field is used. 
		let nVIEW_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, MODULE_NAME, "view"  , 'ASSIGNED_USER_ID');
		let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, MODULE_NAME, "edit"  , 'ASSIGNED_USER_ID');
		// 11/02/2020 Paul.  We don't want to combine favorites and disableView. 
		//if ( disableView )
		//{
		//	nVIEW_ACLACCESS = -1;
		//}
		//if ( disableEdit )
		//{
		//	nEDIT_ACLACCESS = -1;
		//}
		// 10/23/2020 Paul.  Show activity type icon. 
		let ACTIVITY_TYPE: string = null;
		if ( MODULE_NAME == 'Activities' )
		{
			ACTIVITY_TYPE = Sql.ToString(row['ACTIVITY_TYPE']);
		}
/*
		// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
		return (
			<span style={ { whiteSpace: 'nowrap'} }>
				{ MODULE_NAME == 'Activities' && !Sql.IsEmptyString(ACTIVITY_TYPE)
				? <img src={ this.themeURL + ACTIVITY_TYPE + '.gif'} alt={ L10n.ListTerm('moduleList', ACTIVITY_TYPE) } style={ {padding: '3px', borderWidth: '0px'} } />
				: null
				}
				{ nVIEW_ACLACCESS >= 0 && enableFavorites && Sql.IsEmptyGuid(row['FAVORITE_RECORD_ID'])
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onChangeFavorites(row, rowIndex) } title={ L10n.Term('.LBL_ADD_TO_FAVORITES'     ) }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'favorites_add.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon={ { prefix: 'far', iconName: 'star' } } size="lg" color='#FFB518' />
					}
				</span>
				: null
				}
				{ nVIEW_ACLACCESS >= 0 && enableFavorites && !Sql.IsEmptyGuid(row['FAVORITE_RECORD_ID'])
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onChangeFavorites(row, rowIndex) } title={ L10n.Term('.LBL_REMOVE_FROM_FAVORITES') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'favorites_remove.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon={ { prefix: 'fas', iconName: 'star' } } size='lg' color='#FFB518' />
					}
				</span>
				: null
				}
				{ nVIEW_ACLACCESS >= 0 && enableFollowing && Sql.IsEmptyGuid(row['SUBSCRIPTION_PARENT_ID'])
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onChangeFollowing(row, rowIndex) } title={ L10n.Term('.LBL_FOLLOW'   ) }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'follow.png'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon={ { prefix: 'far', iconName: 'arrow-alt-circle-right' } } size="lg" color='#EF7B00' />
					}
				</span>
				: null
				}
				{ nVIEW_ACLACCESS >= 0 && enableFollowing && !Sql.IsEmptyGuid(row['SUBSCRIPTION_PARENT_ID'])
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onChangeFollowing(row, rowIndex) } title={ L10n.Term('.LBL_FOLLOWING') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'following.png'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon={ { prefix: 'fas', iconName: 'arrow-alt-circle-right' } } size='lg' color='#EF7B00' />
					}
				</span>
				: null
				}
				{ !disableView && nVIEW_ACLACCESS >= 0
				? <a href={ this.getViewUrl(row) } style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ (e) => { e.preventDefault(); this._onView(row); } } title={ L10n.Term('.LNK_VIEW') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'view_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon [icon]='file' size='lg' />
					}
				</a>
				: null
				}
				{ !(disableEdit || archiveView) && nEDIT_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID)
				? <a href={ this.getEditUrl(row) } style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ (e) => { e.preventDefault(); this._onEdit(row); } } title={ L10n.Term('.LNK_EDIT') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon [icon]='edit' size='lg' />
					}
				</a>
				: null
				}
			</span>
		);
*/
	}

	public _onEditRelated = (row: any) =>
	{
		const { router, SplendidCache, RELATED_MODULE, ADMIN_MODE } = this;
		let admin = '';
		let module:MODULE = SplendidCache.Module(RELATED_MODULE, this.constructor.name + '._onEditRelated');
		if ( module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		router.navigateByUrl(`/Reset${admin}/${RELATED_MODULE}/Edit/${row.ID}`);
		return false;
	}

	public _onViewRelated(row: any)
	{
		const { router, SplendidCache, RELATED_MODULE, ADMIN_MODE } = this;
		let admin = '';
		let module:MODULE = SplendidCache.Module(RELATED_MODULE, this.constructor.name + '._onViewRelated');
		if ( module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		router.navigateByUrl(`/Reset${admin}/${RELATED_MODULE}/View/${row.ID}`);
		return false;
	}

	public _onRemoveRelated = (row: any) =>
	{
		const { cbRemove } = this;
		if ( cbRemove.observed )
		{
			cbRemove.emit(row);
		}
		return false;
	}

	// 08/18/2019 Paul.  A related view will have separate access rigths based on the related module and related assigned field. 
	public editviewRelatedFormatter = (cell: any, row: any, rowIndex: number, formatExtraData: any) =>
	{
		// 04/13/2021 Paul.  Disable edit in archiveView. 
		const { RELATED_MODULE, disableView, disableEdit, disableRemove, cbRemove, deleteRelated, cbShowRemove, archiveView, SplendidCache, L10n, Crm_Modules } = this;
		// 05/01/2019 Paul.  The edit button should be hidden if a process is pending on the record. 
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 08/11/2019 Paul.  Make sure the user has permission to create a record before loading the layout. 
		// sASSIGNED_USER_ID_FIELD is almost always ASSIGNED_USER_ID, but it is ACITIVTY_ASSIGNED_USER_ID for activities. 
		// Another exception is when using delete or remove with a relationship whereby the parent module assigned field is used. 
		// 11/04/2020 Paul.  Should default to ASSIGNED_USER_ID. 
		let sASSIGNED_USER_ID_FIELD: string = 'ASSIGNED_USER_ID';
		if ( RELATED_MODULE == 'Activities' )
		{
			sASSIGNED_USER_ID_FIELD = Crm_Modules.SingularTableName(Crm_Modules.TableName(RELATED_MODULE)) + '_ASSIGNED_USER_ID';
		}
		let nVIEW_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "view"  , sASSIGNED_USER_ID_FIELD);
		let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "edit"  , sASSIGNED_USER_ID_FIELD);
		let nDELETE_ACLACCESS: number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "remove", sASSIGNED_USER_ID_FIELD);
		// 08/18/2019 Paul.  Activities are deleted not removed. 
		if ( RELATED_MODULE == 'Activities' )
		{
			nDELETE_ACLACCESS = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "delete", sASSIGNED_USER_ID_FIELD);
		}
		// 11/02/2020 Paul.  We don't want to combine favorites and disableView. 
		//if ( disableView )
		//{
		//	nVIEW_ACLACCESS = -1;
		//}
		//if ( disableEdit )
		//{
		//	nEDIT_ACLACCESS = -1;
		//}
		if ( disableRemove )
		{
			nDELETE_ACLACCESS = -1;
		}
		let sRemoveTitle: string = L10n.Term('.LNK_REMOVE');
		if ( deleteRelated )
		{
			sRemoveTitle = L10n.Term('.LNK_DELETE');
		}
		// 10/12/2020 Paul.  Add activity type. 
		let ACTIVITY_TYPE: string = null;
		if ( RELATED_MODULE == 'Activities' )
		{
			ACTIVITY_TYPE = Sql.ToString(row['ACTIVITY_TYPE']);
		}
/*
		return (
			<span style={ {whiteSpace: 'nowrap'} }>
				{ RELATED_MODULE == 'Activities' && !Sql.IsEmptyString(ACTIVITY_TYPE)
				? <img src={ this.themeURL + ACTIVITY_TYPE + '.gif'} alt={ L10n.ListTerm('moduleList', ACTIVITY_TYPE) } style={ {padding: '3px', borderWidth: '0px'} } />
				: null
				}
				{ !disableView && nVIEW_ACLACCESS >= 0
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onViewRelated(row) } title={ L10n.Term('.LNK_VIEW') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'view_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon [icon]='file' size='lg' />
					}
				</span>
				: null
				}
				{ !this.legacyIcons && !(disableEdit || archiveView) && nEDIT_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID)
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onEditRelated(row) } title={ L10n.Term('.LNK_EDIT') }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon [icon]='edit' size='lg' />
					}
				</span>
				: null
				}
				{ !this.legacyIcons && nDELETE_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID) && cbRemove && (!cbShowRemove || cbShowRemove(row))
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={() => this._onRemoveRelated(row) } title={ sRemoveTitle }>
					{ this.legacyIcons
					? <img src={ this.themeURL + 'delete_inline.gif'} style={ {borderWidth: '0px'} } />
					: <fa-icon [icon]='times' size='lg'></fa-icon>
					}
				</span>
				: null
				}
			</span>
		);
*/
	}

	// 11/04/2020 Paul.  Legacy icons means that the remove is on the right. 
	public editviewRelatedFormatterLegacy = (cell: any, row: any, rowIndex: number, formatExtraData: any) =>
	{
		// 04/13/2021 Paul.  Disable edit in archiveView. 
		const { RELATED_MODULE, disableView, disableEdit, disableRemove, cbRemove, deleteRelated, cbShowRemove, archiveView, SplendidCache, L10n, Crm_Modules } = this;
		// 05/01/2019 Paul.  The edit button should be hidden if a process is pending on the record. 
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 08/11/2019 Paul.  Make sure the user has permission to create a record before loading the layout. 
		// sASSIGNED_USER_ID_FIELD is almost always ASSIGNED_USER_ID, but it is ACITIVTY_ASSIGNED_USER_ID for activities. 
		// Another exception is when using delete or remove with a relationship whereby the parent module assigned field is used. 
		// 11/04/2020 Paul.  Should default to ASSIGNED_USER_ID. 
		let sASSIGNED_USER_ID_FIELD: string = 'ASSIGNED_USER_ID';
		if ( RELATED_MODULE == 'Activities' )
		{
			sASSIGNED_USER_ID_FIELD = Crm_Modules.SingularTableName(Crm_Modules.TableName(RELATED_MODULE)) + '_ASSIGNED_USER_ID';
		}
		let nVIEW_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "view"  , sASSIGNED_USER_ID_FIELD);
		let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "edit"  , sASSIGNED_USER_ID_FIELD);
		let nDELETE_ACLACCESS: number = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "remove", sASSIGNED_USER_ID_FIELD);
		// 08/18/2019 Paul.  Activities are deleted not removed. 
		if ( RELATED_MODULE == 'Activities' )
		{
			nDELETE_ACLACCESS = SplendidCache.GetRecordAccess(row, RELATED_MODULE, "delete", sASSIGNED_USER_ID_FIELD);
		}
		// 11/02/2020 Paul.  We don't want to combine favorites and disableView. 
		//if ( disableView )
		//{
		//	nVIEW_ACLACCESS = -1;
		//}
		//if ( disableEdit )
		//{
		//	nEDIT_ACLACCESS = -1;
		//}
		if ( disableRemove )
		{
			nDELETE_ACLACCESS = -1;
		}
		let sRemoveTitle: string = L10n.Term('.LNK_REMOVE');
		if ( deleteRelated )
		{
			sRemoveTitle = L10n.Term('.LNK_DELETE');
		}
		// 10/12/2020 Paul.  Add activity type. 
		let ACTIVITY_TYPE: string = null;
		if ( RELATED_MODULE == 'Activities' )
		{
			ACTIVITY_TYPE = Sql.ToString(row['ACTIVITY_TYPE']);
		}
/*
		return (
			<span style={ {whiteSpace: 'nowrap'} }>
				{ !(disableEdit || archiveView) && nEDIT_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID)
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onEditRelated(row) } title={ L10n.Term('.LNK_EDIT') }>
					{ L10n.Term('.LNK_EDIT') }
					&nbsp;
					{ this.legacyIcons
					? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon [icon]='edit' size='lg' />
					}
				</span>
				: null
				}
				{ nDELETE_ACLACCESS >= 0 && Sql.IsEmptyGuid(row.PENDING_PROCESS_ID) && cbRemove && (!cbShowRemove || cbShowRemove(row))
				? <span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={() => this._onRemoveRelated(row) } title={ sRemoveTitle }>
					{ sRemoveTitle }
					&nbsp;
					{ this.legacyIcons
					? <img src={ this.themeURL + 'delete_inline.gif'} style={ {borderWidth: '0px'} } />
					: <fa-icon [icon]='times' size='lg'></fa-icon>
					}
				</span>
				: null
				}
			</span>
		);
*/
	}

	public async _onButtonsLoaded()
	{
		const { MODULE_NAME, archiveView, SplendidCache, Security, Crm_Modules } = this;
		if ( this.dynamicButtons != null )
		{
			let nACLACCESS_Archive: number = SplendidCache.GetUserAccess(MODULE_NAME, 'archive', this.constructor.name + '_onButtonsLoaded');
			let nACLACCESS_Delete : number = SplendidCache.GetUserAccess(MODULE_NAME, 'delete' , this.constructor.name + '_onButtonsLoaded');
			let nACLACCESS_Edit   : number = SplendidCache.GetUserAccess(MODULE_NAME, 'edit'   , this.constructor.name + '_onButtonsLoaded');
			this.dynamicButtons.ShowButton('MassUpdate'         , nACLACCESS_Edit   >= 0);
			this.dynamicButtons.ShowButton('MassDelete'         , nACLACCESS_Delete >= 0);
			this.dynamicButtons.ShowButton('Archive.MoveData'   , (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) && !archiveView && Crm_Modules.ArchiveEnabled(MODULE_NAME));
			this.dynamicButtons.ShowButton('Archive.RecoverData', (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) &&  archiveView && Crm_Modules.ArchiveEnabled(MODULE_NAME));
			this.dynamicButtons.ShowButton('Sync'               , Crm_Modules.ExchangeFolders(MODULE_NAME) && Security.HasExchangeAlias());
			this.dynamicButtons.ShowButton('Unsync'             , Crm_Modules.ExchangeFolders(MODULE_NAME) && Security.HasExchangeAlias());
		}
	}

	public renderHeader(column: any, colIndex: number, obj: { sortElement: any, filterElement: any })
	{
		const { sortElement, filterElement } = obj;
		const { MODULE_NAME, enableSelection, enableMassUpdate, Page_Command, archiveView, isPopupView, SplendidCache } = this;
/*
		if ( enableSelection && colIndex == 0 )
		{
			// 04/07/2022 Paul.  MassUpdate buttons have been moved to pagination line for the Pacific theme. 
			let sTheme: string = SplendidCache.UserTheme;
			if ( enableMassUpdate && Page_Command && SplendidDynamic.StackedLayout(sTheme) && sTheme != 'Pacific' )
			{
				// 10/28/2020 Paul.  Must use ArchiveView buttons when in archive view. 
				return (<DynamicButtons
					ButtonStyle='DataGrid'
					VIEW_NAME={ MODULE_NAME + '.MassUpdate' + (archiveView ? '.ArchiveView' : '') }
					row={ null }
					Page_Command={ Page_Command }
					onLayoutLoaded={ this._onButtonsLoaded }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.dynamicButtons }
				/>);
			}
			// 07/03/2021 Paul.  SurveyQuestions.PopupView is not showing the header of the first column. 
			else if ( isPopupView && column.text != null )
			{
				if ( column.text != null && column.text.indexOf('<br') >= 0 )
				{
					// 01/18/2020 Paul.  Allow the <br/> tag. 
					return (<div><span dangerouslySetInnerHTML={ {__html: column.text} } /> { sortElement }</div>);
				}
				else
				{
					return (<div>{ column.text} { sortElement }</div>);
				}
			}
			else
			{
				return (<div></div>);
			}
		}
		else
		{
			if ( column.text != null && column.text.indexOf('<br') >= 0 )
			{
				// 01/18/2020 Paul.  Allow the <br/> tag. 
				return (<div><span dangerouslySetInnerHTML={ {__html: column.text} } /> { sortElement }</div>);
			}
			else
			{
				return (<div>{ column.text} { sortElement }</div>);
			}
		}
*/
	}

	public BootstrapColumns(sLIST_MODULE_NAME: string, layout: any, sPRIMARY_MODULE: string, sPRIMARY_ID: string)
	{
		const { readonly, isPopupView, RELATED_MODULE, disableView, disableEdit, disableRemove, SplendidCache, L10n, Security, Crm_Config } = this;
		// 04/20/2017 Paul.  Build DataTables columns. 
		let arrDataTableColumns = [];
		let objDataColumn: any = {};
		if ( !readonly && !isPopupView )
		{
			// 05/28/2020 Paul.  Use RELATED_MODULE instead of cbRemove to determine of the related formatter is used. 
			if ( !Sql.IsEmptyString(RELATED_MODULE) )
			{
				// 06/19/2020 Paul.  Don't create column in related view and 
				// 10/12/2020 Paul.  Add width attribute. 
				if ( !disableView || !disableEdit || !disableRemove )
				{
					objDataColumn =
					{
						key            : 'editview',
						text           : null,
						dataField      : 'empty1',
						formatter      : this.editviewRelatedFormatter,
						headerClasses  : 'listViewThS2',
						headerStyle    : {padding: 0, margin: 0},
						headerFormatter: this.renderHeader,
						sort           : false,
						isDummyField   : true,
						attrs          : { width: '1%' },
						formatExtraData:
						{
							data:
							{
								GRID_NAME: sLIST_MODULE_NAME,
								DATA_FIELD: null,
								fnRender: null,
								layout: layout
							}
						}
					};
					// 01/07/2018 Paul.  Force first column to be displayed. 
					arrDataTableColumns.push(objDataColumn);
				}
			}
			else
			{
				objDataColumn =
				{
					key            : 'editview',
					text           : null,
					dataField      : 'empty1',
					formatter      : this.editviewColumnFormatter,
					headerClasses  : 'listViewThS2',
					headerStyle    : {padding: 0, margin: 0},
					headerFormatter: this.renderHeader,
					sort           : false,
					isDummyField   : true,
					attrs          : { width: '1%' },
					formatExtraData:
					{
						data:
						{
							GRID_NAME: sLIST_MODULE_NAME,
							DATA_FIELD: null,
							fnRender: null,
							layout: layout
						}
					}
				};
				// 01/07/2018 Paul.  Force first column to be displayed. 
				arrDataTableColumns.push(objDataColumn);
			}
		}

		let bEnableTeamManagement = Crm_Config.enable_team_management();
		let bEnableDynamicTeams = Crm_Config.enable_dynamic_teams();
		let bEnableDynamicAssignment = Crm_Config.enable_dynamic_assignment();
		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		let oNumberFormat = Security.NumberFormatInfo();
		if ( Crm_Config.ToString('currency_format') == 'c0' )
		{
			oNumberFormat.CurrencyDecimalDigits = 0;
		}
		let sTheme: string = SplendidCache.UserTheme;
		if ( layout != null )
		{
			for ( let nLayoutIndex = 0; layout != null && nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				// 08/21/2022 Paul.  Don't swap TEAM_SET_NAME on Users.Teams panel.
				let GRID_NAME                  = lay.GRID_NAME                 ;
				let COLUMN_TYPE                = lay.COLUMN_TYPE               ;
				let COLUMN_INDEX               = lay.COLUMN_INDEX              ;
				let HEADER_TEXT                = lay.HEADER_TEXT               ;
				let SORT_EXPRESSION            = lay.SORT_EXPRESSION           ;
				let ITEMSTYLE_WIDTH            = lay.ITEMSTYLE_WIDTH           ;
				// 11/02/2020 Paul.  Apply layout defined style. 
				let ITEMSTYLE_CSSCLASS         = Sql.ToString(lay.ITEMSTYLE_CSSCLASS);
				let ITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN;
				let ITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN  ;
				// 10/30/2020 Paul.  ITEMSTYLE_WRAP defaults to true. 
				let ITEMSTYLE_WRAP             = (lay.ITEMSTYLE_WRAP == null ? true : lay.ITEMSTYLE_WRAP);
				let DATA_FIELD                 = lay.DATA_FIELD                ;
				let DATA_FORMAT                = lay.DATA_FORMAT               ;
				let URL_FIELD                  = lay.URL_FIELD                 ;
				let URL_FORMAT                 = lay.URL_FORMAT                ;
				let URL_TARGET                 = lay.URL_TARGET                ;
				let LIST_NAME                  = lay.LIST_NAME                 ;
				let URL_MODULE                 = lay.URL_MODULE                ;
				let URL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD        ;
				let VIEW_NAME                  = lay.VIEW_NAME                 ;
				let MODULE_NAME                = lay.MODULE_NAME               ;
				let MODULE_TYPE                = lay.MODULE_TYPE               ;
				let PARENT_FIELD               = lay.PARENT_FIELD              ;

				if ( (DATA_FIELD == 'TEAM_NAME' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( bEnableTeamManagement )
					{
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						// 04/03/2021 Paul.  Apply single rule. 
						// 08/21/2022 Paul.  Don't swap TEAM_SET_NAME on Users.Teams panel.
						if ( bEnableDynamicTeams && DATA_FORMAT != '1' && Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('single') < 0 && GRID_NAME.indexOf('.Teams') < 0 )
						{
							HEADER_TEXT = '.LBL_LIST_TEAM_SET_NAME';
							DATA_FIELD  = 'TEAM_SET_NAME';
						}
						else
						{
							HEADER_TEXT = '.LBL_LIST_TEAM_NAME';
							DATA_FIELD  = 'TEAM_NAME';
						}
					}
					else
					{
						// 10/24/2012 Paul.  Clear the sort so that there would be no term lookup. 
						HEADER_TEXT     = null;
						SORT_EXPRESSION = null;
						COLUMN_TYPE     = 'Hidden';
					}
				}
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				// 04/03/2021 Paul.  Dynamic Assignment must be managed here as well as in SplendidGrid. 
				else if ( DATA_FIELD == 'ASSIGNED_TO' || DATA_FIELD == 'ASSIGNED_TO_NAME' || DATA_FIELD == 'ASSIGNED_SET_NAME' )
				{
					// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
					if ( bEnableDynamicAssignment && Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('single') < 0 )
					{
						HEADER_TEXT = '.LBL_LIST_ASSIGNED_SET_NAME';
						DATA_FIELD  = 'ASSIGNED_SET_NAME';
					}
					else if ( DATA_FIELD == 'ASSIGNED_SET_NAME' )
					{
						HEADER_TEXT = '.LBL_LIST_ASSIGNED_USER';
						DATA_FIELD  = 'ASSIGNED_TO_NAME';
					}
				}
				// 01/18/2010 Paul.  A field is either visible or not.  At this time, we will not only show a field to its owner. 
				let bIsReadable: boolean = true;
				// 08/02/2010 Paul.  The JavaScript and Hover fields will not have a data field. 
				if ( SplendidCache.bEnableACLFieldSecurity && !Sql.IsEmptyString(DATA_FIELD) )
				{
					let gASSIGNED_USER_ID: string = null;
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(SplendidCache, Security, MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}

				if (   COLUMN_TYPE == 'BoundColumn'
				  && ( DATA_FORMAT == 'Date'
					|| DATA_FORMAT == 'DateTime'
					|| DATA_FORMAT == 'Currency'
					|| DATA_FORMAT == 'Image'
					|| DATA_FORMAT == 'MultiLine'
					// 08/26/2014 Paul.  Ignore ImageButton. 
					|| DATA_FORMAT == 'ImageButton'
				   )
				)
				{
					COLUMN_TYPE = 'TemplateColumn';
				}
				if ( DATA_FORMAT == 'ImageButton' && URL_FORMAT == 'Preview' )
				{
					// 04/06/2022 Paul.  Only Seven theme supports preview at this time. 
					bIsReadable = bIsReadable && SplendidDynamic.StackedLayout(SplendidCache.UserTheme) && sTheme == 'Seven';
				}
				// 08/20/2016 Paul.  The hidden field is a DATA_FORMAT, not a COLUMN_TYPE, but keep COLUMN_TYPE just in case anyone used it. 
				// 07/22/2019 Paul.  Apply ACL Field Security. 
				if ( !bIsReadable || COLUMN_TYPE == 'Hidden' || DATA_FORMAT == 'Hidden' )
				{
					continue;  // 04/23/2017 Paul.  Return instead of continue as we are in a binding function. 
				}
				if ( COLUMN_TYPE == 'TemplateColumn' )
				{
					// 04/20/2017 Paul.  Build DataTables columns. 
					// 01/22/2020 Paul.  Apply wrap flag. 
					// 11/02/2020 Paul.  Apply layout defined style. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : ITEMSTYLE_CSSCLASS,
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: this.renderHeader,
						formatter      : this.templateColumnFormatter,
						sort           : (SORT_EXPRESSION != null),
						isDummyField   : false,
						formatExtraData:
						{
							data:
							{
								GRID_NAME   : sLIST_MODULE_NAME,
								DATA_FIELD  : DATA_FIELD,
								COLUMN_INDEX: COLUMN_INDEX,
								layout      : lay
							}
						}
					};
					// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
					// 04/24/2022 Paul.  Move Arctic style override to style.css. 
					//if ( SplendidCache.UserTheme == 'Arctic' )
					//{
					//	objDataColumn.headerStyle.paddingTop    = '10px';
					//	objDataColumn.headerStyle.paddingBottom = '10px';
					//}
					if ( ITEMSTYLE_HORIZONTAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_HORIZONTAL_ALIGN;
					}
					if ( ITEMSTYLE_VERTICAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_VERTICAL_ALIGN;
					}
					if ( ITEMSTYLE_WIDTH != null )
					{
						objDataColumn.attrs = { width: ITEMSTYLE_WIDTH };
					}
					// 07/25/2017 Paul.  Try and force the NAME column to always be displayed on mobile portrait mode. 
					// https://datatables.net/extensions/responsive/classes
					if ( DATA_FIELD == "NAME" )
					{
						objDataColumn.classes = ' all';
					}
					objDataColumn.classes = Trim(objDataColumn.classes);

					arrDataTableColumns.push(objDataColumn);
				}
				else if ( COLUMN_TYPE == 'BoundColumn' )
				{
					// 04/20/2017 Paul.  Build DataTables columns. 
					// 01/22/2020 Paul.  Apply wrap flag. 
					// 11/02/2020 Paul.  Apply layout defined style. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : ITEMSTYLE_CSSCLASS,
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: this.renderHeader,
						formatter      : this.boundColumnFormatter,
						sort           : (SORT_EXPRESSION != null),
						isDummyField   : false,
						formatExtraData: {
							data: {
								GRID_NAME   : sLIST_MODULE_NAME,
								DATA_FIELD  : DATA_FIELD,
								COLUMN_INDEX: COLUMN_INDEX,
								layout      : lay
							}
						}
					};
					// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
					// 04/24/2022 Paul.  Move Arctic style override to style.css. 
					//if ( SplendidCache.UserTheme == 'Arctic' )
					//{
					//	objDataColumn.headerStyle.paddingTop    = '10px';
					//	objDataColumn.headerStyle.paddingBottom = '10px';
					//}
					if ( ITEMSTYLE_HORIZONTAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_HORIZONTAL_ALIGN;
					}
					if ( ITEMSTYLE_VERTICAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_VERTICAL_ALIGN;
					}
					if ( ITEMSTYLE_WIDTH != null )
					{
						objDataColumn.attrs = { width: ITEMSTYLE_WIDTH };
					}
					objDataColumn.classes = Trim(objDataColumn.classes);
					arrDataTableColumns.push(objDataColumn);
				}
			}
			// 05/17/2018 Paul.  Defer finalize. 
			//if ( this.BootstrapColumnsFinalize != null )
			//	arrDataTableColumns = this.BootstrapColumnsFinalize(sLIST_MODULE_NAME, arrDataTableColumns);
		}
		
		// 11/04/2020 Paul.  Legacy icons means that the remove is on the right. 
		if ( !readonly && !isPopupView && this.legacyIcons )
		{
			// 05/28/2020 Paul.  Use RELATED_MODULE instead of cbRemove to determine of the related formatter is used. 
			if ( !Sql.IsEmptyString(RELATED_MODULE) )
			{
				// 06/19/2020 Paul.  Don't create column in related view and 
				// 10/12/2020 Paul.  Add width attribute. 
				if ( !disableView || !disableEdit || !disableRemove )
				{
					objDataColumn =
					{
						key            : 'editview',
						text           : null,
						dataField      : 'empty1',
						formatter      : this.editviewRelatedFormatterLegacy,
						headerClasses  : 'listViewThS2',
						headerStyle    : {padding: 0, margin: 0},
						headerFormatter: this.renderHeader,
						sort           : false,
						isDummyField   : true,
						attrs          : { width: '1%' },
						formatExtraData:
						{
							data:
							{
								GRID_NAME: sLIST_MODULE_NAME,
								DATA_FIELD: null,
								fnRender: null,
								layout: layout
							}
						}
					};
					// 01/07/2018 Paul.  Force first column to be displayed. 
					arrDataTableColumns.push(objDataColumn);
				}
			}
		}
		return arrDataTableColumns;
	}

	public _onChangeSort(obj: {sSORT_FIELD: string, sSORT_DIRECTION: string})
	{
		const { sSORT_FIELD, sSORT_DIRECTION } = obj;
		this.Sort(sSORT_FIELD, sSORT_DIRECTION);
	}

	public async Sort(sSORT_FIELD: string, sSORT_DIRECTION: string)
	{
		const { MODULE_NAME, ADMIN_MODE, cbCustomLoad, archiveView, rowRequiredSearch, Application, SplendidCache, ListView } = this;
		const { layout, SEARCH_FILTER, SELECT_FIELDS, SEARCH_VALUES, RELATED_MODULE, TABLE_NAME, PRIMARY_FIELD, PRIMARY_ID, TOP } = this;
		// 02/23/2021 Paul.  The activePage state value will not be updated locally, so use a local variable instead to prevent stale page number. 
		let activePage: number = 1;
		// 05/06/2021 Paul.  Track browser history changes so that we can determine if last event was a POP event. 
		if ( this.searchCount == 0 && SplendidCache.lastHistoryAction == 'POP' && this.GRID_NAME.indexOf('.ListView') >= 0 )
		{
			activePage = SplendidCache.getGridLastPage(this.GRID_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort ' + this.state.GRID_NAME + ' Last Page = ' + activePage);
		}
		else
		{
			SplendidCache.setGridLastPage(this.GRID_NAME, activePage);
		}
		this.searchCount++;
		// 08/10/2020 Paul.  Convert to sort expression. 
		if ( layout )
		{
			for ( let i: number = 0; i < layout.length; i++ )
			{
				if ( layout[i].DATA_FIELD == sSORT_FIELD )
				{
					sSORT_FIELD = layout[i].SORT_EXPRESSION;
					break;
				}
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort', SEARCH_FILTER);
		this.activePage      = activePage     ;
		this.SORT_FIELD      = sSORT_FIELD    ;
		this.SORT_DIRECTION  = sSORT_DIRECTION;
		this.loading         = true           ;
		try
		{
			let status = await Application.AuthenticatedMethod(null, this.constructor.name + '.Sort');
			if ( status == 1 )
			{
				// 06/10/2018 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
				let rowSEARCH_VALUES: any = SEARCH_VALUES;
				// 01/20/2020 Paul.  Required values are always applied. 
				if ( rowRequiredSearch )
				{
					rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
					if ( rowSEARCH_VALUES == null )
					{
						rowSEARCH_VALUES = {};
					}
					for ( let sField in rowRequiredSearch )
					{
						rowSEARCH_VALUES[sField] =
						{
							FIELD_TYPE : 'Hidden',
							DATA_FORMAT: null,
							value      : rowRequiredSearch[sField]
						};
					}
				}
				// 01/30/2013 Paul.  Sorting a relationship view tasks extra effort.  We need to clear the layout panel and render again as a relationship panel. 
				// 06/10/2018 Paul.  If TABLE_NAME is specified, then use the LoadTable function. 
				// 08/30/2019 Paul.  ActivitiesPopup needs to use a custom load method. 
				if ( cbCustomLoad.observed )
				{
					// 06/23/2020 Paul.  Use table name if provided. 
					if ( !Sql.IsEmptyString(TABLE_NAME) )
					{
						// 06/23/2020 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
						if ( !Sql.IsEmptyString(RELATED_MODULE) )
						{
							//if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
							//	sSEARCH_FILTER += ' and ';
							//sSEARCH_FILTER += PRIMARY_FIELD + ' eq \'' + PRIMARY_ID + '\'';
							// 11/18/2019 Paul.  Best to send Search Filter or Search Values, but not both. 
							rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
							if ( rowSEARCH_VALUES == null )
							{
								rowSEARCH_VALUES = {};
							}
							rowSEARCH_VALUES[PRIMARY_FIELD] = { FIELD_TYPE: 'Hidden', value: PRIMARY_ID };
						}
						let d: any = await cbCustomLoad.emit({sMODULE_NAME: TABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT: SELECT_FIELDS, sFILTER: null, rowSEARCH_VALUES, nTOP: TOP, nSKIP: (TOP * (activePage - 1)), bADMIN_MODE: ADMIN_MODE, archiveView});
						// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
						let selectedKeys = this.createKeys(d.results);
						// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
						this.__total      = d.__total          ;
						this.__sql        = d.__sql            ;
						this.vwMain       = d.results          ;
						this.loading      = false              ;
						this.tableKey     = this.tableKey + '*';
						this.selectedKeys = selectedKeys       ;
					}
					else
					{
						let d: any = await cbCustomLoad.emit({sMODULE_NAME: MODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT: SELECT_FIELDS, sFILTER: null, rowSEARCH_VALUES, nTOP: TOP, nSKIP: (TOP * (activePage - 1)), bADMIN_MODE: ADMIN_MODE, archiveView});
						// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
						let selectedKeys = this.createKeys(d.results);
						// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
						this.__total      = d.__total          ;
						this.__sql        = d.__sql            ;
						this.vwMain       = d.results          ;
						this.loading      = false              ;
						this.tableKey     = this.tableKey + '*';
						this.selectedKeys = selectedKeys       ;
					}
				}
				else if ( !Sql.IsEmptyString(TABLE_NAME) )
				{
					//let sSEARCH_FILTER = SEARCH_FILTER;
					// 06/10/2018 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
					if ( !Sql.IsEmptyString(RELATED_MODULE) )
					{
						//if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
						//	sSEARCH_FILTER += ' and ';
						//sSEARCH_FILTER += PRIMARY_FIELD + ' eq \'' + PRIMARY_ID + '\'';
						// 11/18/2019 Paul.  Best to send Search Filter or Search Values, but not both. 
						rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
						if ( rowSEARCH_VALUES == null )
						{
							rowSEARCH_VALUES = {};
						}
						rowSEARCH_VALUES[PRIMARY_FIELD] = { FIELD_TYPE: 'Hidden', value: PRIMARY_ID };
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort: ' + SELECT_FIELDS, sSEARCH_FILTER);
					let d = await ListView.LoadTablePaginated(TABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
					// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
					let selectedKeys = this.createKeys(d.results);
					// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
					this.__total      = d.__total          ;
					this.__sql        = d.__sql            ;
					this.vwMain       = d.results          ;
					this.loading      = false              ;
					this.tableKey     = this.tableKey + '*';
					this.selectedKeys = selectedKeys       ;
				}
				else
				{
					// 05/21/2018 Paul.  SEARCH_FILTER is not getting quickly enough. 
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort: ' + SELECT_FIELDS, SEARCH_FILTER);
					try
					{
						let d = await ListView.LoadModulePaginated(MODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
						// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
						let selectedKeys = this.createKeys(d.results);
						// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
						this.__total      = d.__total          ;
						this.__sql        = d.__sql            ;
						this.vwMain       = d.results          ;
						this.loading      = false              ;
						this.tableKey     = this.tableKey + '*';
						this.selectedKeys = selectedKeys       ;
					}
					catch(error: any)
					{
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort', error);
						this.error   = this.constructor.name + '.Sort: ' + error.message;
						this.loading = false;;
					}
				}
			}
			else
			{
				Application.LoginRedirect(null, this.constructor.name + '.Sort');
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Sort ', error);
			this.error   = this.constructor.name + '.Sort: ' + error.message;
			this.loading = false;
		}
	}

	// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	public async Search(sSEARCH_FILTER: string, rowSEARCH_VALUES: any, oSORT?: any)
	{
		const { MODULE_NAME, ADMIN_MODE, cbCustomLoad, archiveView, rowRequiredSearch, Application, SplendidCache, ListView } = this;
		const { layout, SEARCH_FILTER, SEARCH_VALUES, SELECT_FIELDS, RELATED_MODULE, TABLE_NAME, PRIMARY_FIELD, PRIMARY_ID, TOP } = this;
		// 02/23/2021 Paul.  The activePage state value will not be updated locally, so use a local variable instead to prevent stale page number. 
		let activePage: number = 1;
		// 05/06/2021 Paul.  Track browser history changes so that we can determine if last event was a POP event. 
		if ( this.searchCount == 0 && SplendidCache.lastHistoryAction == 'POP' && this.GRID_NAME.indexOf('.ListView') >= 0 )
		{
			activePage = SplendidCache.getGridLastPage(this.GRID_NAME);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search ' + this.state.GRID_NAME + ' Last Page = ' + activePage);
		}
		else
		{
			SplendidCache.setGridLastPage(this.GRID_NAME, activePage);
		}
		this.searchCount++;
		let { SORT_FIELD, SORT_DIRECTION } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search', sSEARCH_FILTER, rowSEARCH_VALUES);
		this.activePage    = activePage      ;
		this.SEARCH_FILTER = sSEARCH_FILTER  ;
		this.SEARCH_VALUES = rowSEARCH_VALUES;
		this.loading       = true            ;
		try
		{
			let status = await Application.AuthenticatedMethod(null, this.constructor.name + '.Search');
			if ( status == 1 )
			{
				// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
				if ( oSORT )
				{
					SORT_FIELD     = oSORT.SORT_FIELD    ;
					SORT_DIRECTION = oSORT.SORT_DIRECTION;
				}
				// 01/20/2020 Paul.  Required values are always applied. 
				if ( rowRequiredSearch )
				{
					rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
					if ( rowSEARCH_VALUES == null )
					{
						rowSEARCH_VALUES = {};
					}
					for ( let sField in rowRequiredSearch )
					{
						rowSEARCH_VALUES[sField] =
						{
							FIELD_TYPE : 'Hidden',
							DATA_FORMAT: null,
							value      : rowRequiredSearch[sField]
						};
					}
				}
				// 01/30/2013 Paul.  Sorting a relationship view tasks extra effort.  We need to clear the layout panel and render again as a relationship panel. 
				// 06/10/2018 Paul.  If TABLE_NAME is specified, then use the LoadTable function. 
				// 08/30/2019 Paul.  ActivitiesPopup needs to use a custom load method. 
				if ( cbCustomLoad.observed )
				{
					let d: any = await cbCustomLoad.emit({sMODULE_NAME: MODULE_NAME, sSORT_FIELD: SORT_DIRECTION, sSORT_DIRECTION: SORT_DIRECTION, sSELECT: SELECT_FIELDS, sFILTER: null, rowSEARCH_VALUES, nTOP: TOP, nSKIP: (TOP * (activePage - 1)), bADMIN_MODE: ADMIN_MODE, archiveView});
					// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
					let selectedKeys = this.createKeys(d.results);
					// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
					this.__total        = d.__total          ;
					this.__sql          = d.__sql            ;
					this.vwMain         = d.results          ;
					this.loading        = false              ;
					this.tableKey       = this.tableKey + '*';
					this.SORT_FIELD     = SORT_FIELD         ;
					this.SORT_DIRECTION = SORT_DIRECTION     ;
					this.selectedKeys   = selectedKeys       ;
				}
				else if (!Sql.IsEmptyString(TABLE_NAME))
				{
					// 06/10/2018 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
					if ( !Sql.IsEmptyString(RELATED_MODULE) )
					{
						// 05/21/2018 Paul.  SEARCH_FILTER is not getting quickly enough, so use parameters. 
						//if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
						//	sSEARCH_FILTER += ' and ';
						//sSEARCH_FILTER += PRIMARY_FIELD + ' eq \'' + PRIMARY_ID + '\'';
						// 11/18/2019 Paul.  Best to send Search Filter or Search Values, but not both. 
						rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
						if ( rowSEARCH_VALUES == null )
						{
							rowSEARCH_VALUES = [];
						}
						rowSEARCH_VALUES[PRIMARY_FIELD] = { FIELD_TYPE: 'Hidden', value: PRIMARY_ID };
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search: ' + SELECT_FIELDS, sSEARCH_FILTER);
					let d = await ListView.LoadTablePaginated(TABLE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
					// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
					let selectedKeys = this.createKeys(d.results);
					// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
					// 05/06/2021 Paul.  activePage may not have been set to 1. 
					this.__total        = d.__total          ;
					this.__sql          = d.__sql            ;
					this.vwMain         = d.results          ;
					this.activePage     = activePage         ;
					this.loading        = false              ;
					this.tableKey       = this.tableKey + '*';
					this.SORT_FIELD     = SORT_FIELD         ;
					this.SORT_DIRECTION = SORT_DIRECTION     ;
					this.selectedKeys   = selectedKeys       ;
				}
				else
				{
					// 05/21/2018 Paul.  SEARCH_FILTER is not getting quickly enough, so use parameters. 
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Search: ' + SELECT_FIELDS, sSEARCH_FILTER);
					let d = await ListView.LoadModulePaginated(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView);
					// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
					let selectedKeys = this.createKeys(d.results);
					// 11/17/2020 Paul.  Update the tableKey so that the sort indicator will change. 
					// 05/06/2021 Paul.  activePage may not have been set to 1. 
					this.__total        = d.__total          ;
					this.__sql          = d.__sql            ;
					this.vwMain         = d.results          ;
					this.activePage     = activePage         ;
					this.loading        = false              ;
					this.tableKey       = this.tableKey + '*';
					this.SORT_FIELD     = SORT_FIELD         ;
					this.SORT_DIRECTION = SORT_DIRECTION     ;
					this.selectedKeys   = selectedKeys       ;
				}
			}
			else
			{
				Application.LoginRedirect(null, this.constructor.name + '.Search');
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Search', error);
			this.error   = error;
			this.loading = false;
		}
	}

	// https://github.com/react-bootstrap-table/react-bootstrap-table2/tree/master/docs#onTableChange
	public handleTableChange(type: string, obj: { sortField: string, sortOrder: string })
	{
		const { sortField, sortOrder } = obj;
		const { MODULE_NAME, AutoSaveSearch, Page_Command, SplendidCache, ModuleUpdate } = this;
		const { SORT_FIELD, SORT_DIRECTION, SEARCH_VALUES } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handleTableChange', sortField, SEARCH_VALUES);
		if ( type == 'sort' )
		{
			// 05/08/2019 Paul.  Block sort event if values have not changed. 
			// This should prevent the double query when list first loaded. 
			if ( SORT_FIELD != sortField || SORT_DIRECTION != sortOrder)
			{
				this.Sort(sortField, sortOrder);
				// 11/11/2020 Paul.  We need to send the grid sort event to the SearchView. 
				if ( Page_Command )
				{
					Page_Command.emit({sCommandName: 'sort', sCommandArguments: { sortField, sortOrder } });
				}
				// 11/09/2020 Paul.  Auto save the search with the new sort field. 
				if ( AutoSaveSearch )
				{
					let arrSearchFilter = SEARCH_VALUES;
					let arrSavedSearchFields = new Array();
					for ( let DATA_FIELD in arrSearchFilter )
					{
						let objField: any = new Object();
						arrSavedSearchFields.push(objField);
						objField['@Name'] = DATA_FIELD;
						objField['@Type'] = arrSearchFilter[DATA_FIELD].FIELD_TYPE;
						objField.Value    = arrSearchFilter[DATA_FIELD].value;
					}

					let objSavedSearch: any = new Object();
					objSavedSearch.SavedSearch                    = new Object();
					objSavedSearch.SavedSearch.SortColumn         = new Object();
					objSavedSearch.SavedSearch.SortColumn.Value   = 'NAME';
					objSavedSearch.SavedSearch.SortOrder          = new Object();
					objSavedSearch.SavedSearch.SortOrder.Value    = 'asc';
					objSavedSearch.SavedSearch.SearchFields       = new Object();
					objSavedSearch.SavedSearch.SearchFields.Field = arrSavedSearchFields;
					objSavedSearch.SavedSearch.SortColumn.Value   = sortField;
					objSavedSearch.SavedSearch.SortOrder.Value    = sortOrder;

					// https://www.npmjs.com/package/fast-xml-parser
					let options: any = 
					{
						attributeNamePrefix: '@',
						textNodeName       : 'Value',
						ignoreAttributes   : false,
						ignoreNameSpace    : true,
						parseAttributeValue: true,
						trimValues         : false,

					};
					let parser = new XMLBuilder(options);  // j2xParser renamed to XMLBuilder.
					let sXML: string = '<?xml version="1.0" encoding="UTF-8"?>' + parser.build(objSavedSearch);
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handleTableChange', sortField, SEARCH_VALUES, sXML);
					try
					{
						ModuleUpdate.UpdateSavedSearch(null, MODULE_NAME, sXML, null, null);
					}
					catch(e)
					{
					}
					// 05/15/2019 Paul.  Update cache afterward in case there is an error. 
					SplendidCache.UpdateDefaultSavedSearch(MODULE_NAME, sXML, null);
				}
			}
		}
	}

	public async _onPageChange(page: number, sizePerPage: number)
	{
		const { MODULE_NAME, ADMIN_MODE, cbCustomLoad, archiveView, rowRequiredSearch, SplendidCache, ListView } = this;
		const { layout, SORT_FIELD, SORT_DIRECTION, SEARCH_FILTER, SEARCH_VALUES, SELECT_FIELDS, RELATED_MODULE, TABLE_NAME, PRIMARY_FIELD, PRIMARY_ID, TOP } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onPageChange', page);
		// 05/06/2021 Paul.  Track browser history changes so that we can determine if last event was a POP event. 
		SplendidCache.setGridLastPage(this.GRID_NAME, page);
		this.activePage = page;
		this.loading    = true;
		try
		{
			let rowSEARCH_VALUES: any = SEARCH_VALUES;
			// 01/20/2020 Paul.  Required values are always applied. 
			if ( rowRequiredSearch )
			{
				rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
				if ( rowSEARCH_VALUES == null )
				{
					rowSEARCH_VALUES = {};
				}
				for ( let sField in rowRequiredSearch )
				{
					rowSEARCH_VALUES[sField] =
					{
						FIELD_TYPE : 'Hidden',
						DATA_FORMAT: null,
						value      : rowRequiredSearch[sField]
					};
				}
			}
			// 06/10/2018 Paul.  If TABLE_NAME is specified, then use the LoadTable function. 
			// 08/30/2019 Paul.  ActivitiesPopup needs to use a custom load method. 
			if ( cbCustomLoad.observed )
			{
				let d: any = await cbCustomLoad.emit({sMODULE_NAME: TABLE_NAME, sSORT_FIELD: SORT_FIELD, sSORT_DIRECTION: SORT_DIRECTION, sSELECT: SELECT_FIELDS, sFILTER: null, rowSEARCH_VALUES, nTOP: TOP, nSKIP: (TOP * (page - 1)), bADMIN_MODE: ADMIN_MODE, archiveView});
				// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
				let selectedKeys = this.createKeys(d.results);
				this.__total      = d.__total   ;
				this.__sql        = d.__sql     ;
				this.vwMain       = d.results   ;
				this.loading      = false       ;
				this.selectedKeys = selectedKeys;
			}
			else if ( !Sql.IsEmptyString(TABLE_NAME) )
			{
				//let sSEARCH_FILTER: string = SEARCH_FILTER;
				// 06/10/2018 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
				if ( !Sql.IsEmptyString(RELATED_MODULE) )
				{
					//if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
					//	sSEARCH_FILTER += ' and ';
					//sSEARCH_FILTER += PRIMARY_FIELD + ' eq \'' + PRIMARY_ID + '\'';
					// 11/18/2019 Paul.  Best to send Search Filter or Search Values, but not both. 
					rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
					if ( rowSEARCH_VALUES == null )
					{
						rowSEARCH_VALUES = {};
					}
					rowSEARCH_VALUES[PRIMARY_FIELD] = { FIELD_TYPE: 'Hidden', value: PRIMARY_ID };
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handlePaginationChange: ' + SELECT_FIELDS, sSEARCH_FILTER);
				let d = await ListView.LoadTablePaginated(TABLE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (page - 1), ADMIN_MODE, archiveView);
				// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
				let selectedKeys = this.createKeys(d.results);
				this.__total      = d.__total   ;
				this.__sql        = d.__sql     ;
				this.vwMain       = d.results   ;
				this.loading      = false       ;
				this.selectedKeys = selectedKeys;
			}
			else
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handlePaginationChange: ' + SELECT_FIELDS, SEARCH_FILTER);
				let d = await ListView.LoadModulePaginated(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (page - 1), ADMIN_MODE, archiveView);
				// 03/02/2021 Paul.  We need to re-calculate the selectedKeys after every submit as the sort may change and the ID_key would then be different. 
				let selectedKeys = this.createKeys(d.results);
				this.__total      = d.__total   ;
				this.__sql        = d.__sql     ;
				this.vwMain       = d.results   ;
				this.loading      = false       ;
				this.selectedKeys = selectedKeys;
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '. handlePaginationChange', error);
			this.error   = error;
			this.loading = false;
		}
	}

	public _onNextPage()
	{
		const { activePage, TOP, __total } = this;

		if ( activePage * TOP < __total )
		{
			this._onPageChange(activePage + 1, null);
		}
	}

	public _onPrevPage()
	{
		const { activePage } = this;
		if ( activePage > 1 )
		{
			this._onPageChange(activePage - 1, null);
		}
	}

	public _onSelectionChanged(row: any, isSelect: number, rowIndex: number, e: any)
	{
		const { selectionChanged } = this;
		let { selectedItems, selectedKeys } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged ' + isSelect.toString(), row);
		if ( isSelect )
		{
			selectedItems[row.ID] = true;
			if ( !selectedKeys.find(x => x == row.ID_key) )
			{
				selectedKeys.push(row.ID_key);
			}
		}
		else
		{
			delete selectedItems[row.ID];
			selectedKeys = selectedKeys.filter(x => x !== row.ID_key);
		}
		// 03/15/2021 Paul.  selectedKeys only lists items on current page, not total count. 
		let checkedCount = Object.keys(selectedItems).length;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged', selectedKeys);
		this.checkedCount  = checkedCount ;
		if ( selectionChanged.observed )
		{
			selectionChanged.emit(selectedItems);
		}
		return true;
	}

	public _onBootstrapSelectPage(isSelect: any, rows: any[], e: any)
	{
		const { selectionChanged } = this;
		const { vwMain } = this;
		let { selectedItems, selectedKeys } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBootstrapSelectPage ' + isSelect.toString(), rows);
		if ( vwMain != null )
		{
			for ( let i = 0; i < rows.length; i++ )
			{
				let row = rows[i];
				if ( isSelect )
				{
					selectedItems[row.ID] = true;
					if ( !selectedKeys.find(x => x == row.ID_key) )
					{
						selectedKeys.push(row.ID_key);
					}
				}
				else
				{
					delete selectedItems[row.ID];
					selectedKeys = selectedKeys.filter(x => x !== row.ID_key);
				}
			}
		}
		// 03/15/2021 Paul.  selectedKeys only lists items on current page, not total count. 
		let checkedCount = Object.keys(selectedItems).length;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBootstrapSelectPage', selectedKeys);
		this.checkedCount = checkedCount;
		if ( selectionChanged.observed )
		{
			selectionChanged.emit(selectedItems);
		}
	}

	public _onSelectPage(e: any)
	{
		const { selectionChanged } = this;
		const { vwMain } = this;
		let { nSelectionKey } = this;
		let { selectedItems, selectedKeys } = this;
		// 04/07/2022 Paul.  e may be null. 
		if ( e != null )
		{
			e.preventDefault();
		}
		if ( vwMain != null )
		{
			for ( let i = 0; i < vwMain.length; i++ )
			{
				let row = vwMain[i];
				selectedItems[row.ID] = true;
				if ( !selectedKeys.find(x => x == row.ID_key) )
				{
					selectedKeys.push(row.ID_key);
				}
			}
		}
		// 03/15/2021 Paul.  selectedKeys only lists items on current page, not total count. 
		let checkedCount = Object.keys(selectedItems).length;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectPage', selectedKeys);
		// 04/07/2022 Paul.  Use selection key to force checkbox to update. 
		nSelectionKey++;
		this.checkedCount  = checkedCount ;
		if ( selectionChanged.observed )
		{
			selectionChanged.emit(selectedItems);
		}
	}

	public async _onSelectAll(e: any)
	{
		const { MODULE_NAME, ADMIN_MODE, cbCustomLoad, archiveView, rowRequiredSearch, selectionChanged, ListView } = this;
		const { layout, SORT_FIELD, SORT_DIRECTION, SEARCH_FILTER, SEARCH_VALUES, RELATED_MODULE, TABLE_NAME, PRIMARY_FIELD, PRIMARY_ID, TOP, __total } = this;
		let { nSelectionKey } = this;
		e.preventDefault();
		try
		{
			let selectedItems: any = {};
			let selectedKeys : string[] = [];
			let nPageTotal = __total / TOP;
			let SELECT_FIELDS = 'ID';
			// 07/15/2019 Paul.  To select all, we need to to fetch all pages so that we can re-format the row keys. 
			this.loading = true;
			// 11/27/2020 Paul.  +1 to get the last page. 
			for ( let page = 1; page <= (nPageTotal + 1); page++ )
			{
				let rowSEARCH_VALUES: any = SEARCH_VALUES;
				// 01/20/2020 Paul.  Required values are always applied. 
				if ( rowRequiredSearch )
				{
					rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
					if ( rowSEARCH_VALUES == null )
					{
						rowSEARCH_VALUES = {};
					}
					for ( let sField in rowRequiredSearch )
					{
						rowSEARCH_VALUES[sField] =
						{
							FIELD_TYPE : 'Hidden',
							DATA_FORMAT: null,
							value      : rowRequiredSearch[sField]
						};
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectAll page ' + page);
				let results = null;
				// 06/10/2018 Paul.  If TABLE_NAME is specified, then use the LoadTable function. 
				// 08/30/2019 Paul.  ActivitiesPopup needs to use a custom load method. 
				if ( cbCustomLoad.observed )
				{
					let d: any = await cbCustomLoad.emit({sMODULE_NAME: MODULE_NAME, sSORT_FIELD: SORT_FIELD, sSORT_DIRECTION: SORT_DIRECTION, sSELECT: SELECT_FIELDS, sFILTER: null, rowSEARCH_VALUES, nTOP: TOP, nSKIP: (TOP * (page - 1)), bADMIN_MODE: ADMIN_MODE, archiveView});
					// 11/27/2020 Paul.  Must set local results for selected items to get counted. 
					results = d.results;
					// 11/27/2020 Paul.  SelectAll should not change the current page. 
					//await this.setStateAsync({ __total: d.__total, __sql: d.__sql, vwMain: d.results });
				}
				else if ( !Sql.IsEmptyString(TABLE_NAME) )
				{
					//let sSEARCH_FILTER: string = SEARCH_FILTER;
					// 06/10/2018 Paul.  If RELATED_MODULE is specified, then we need to filter by PRIMARY_FIELD. 
					if ( !Sql.IsEmptyString(RELATED_MODULE) )
					{
						//if ( !Sql.IsEmptyString(sSEARCH_FILTER) )
						//	sSEARCH_FILTER += ' and ';
						//sSEARCH_FILTER += PRIMARY_FIELD + ' eq \'' + PRIMARY_ID + '\'';
						rowSEARCH_VALUES = Sql.DeepCopy(rowSEARCH_VALUES);
						if ( rowSEARCH_VALUES == null )
						{
							rowSEARCH_VALUES = {};
						}
						rowSEARCH_VALUES[PRIMARY_FIELD] = { FIELD_TYPE: 'Hidden', value: PRIMARY_ID };
					}
					let d = await ListView.LoadTablePaginated(TABLE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (page - 1), ADMIN_MODE, archiveView);
					results = d.results;
				}
				else
				{
					let d = await ListView.LoadModulePaginated(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, null, rowSEARCH_VALUES, TOP, TOP * (page - 1), ADMIN_MODE, archiveView);
					results = d.results;
				}
				if ( results != null )
				{
					for ( let i = 0; i < results.length; i++ )
					{
						let row = results[i];
						row.ID_key = this.formatKey(row.ID, i);
						selectedItems[row.ID] = true;
						selectedKeys.push(row.ID_key);
					}
				}
			}
			// 11/27/2020 Paul.  Update selected count. 
			// 03/15/2021 Paul.  selectedKeys only lists items on current page, not total count. 
			let checkedCount = Object.keys(selectedItems).length;
			// 12/01/2020 Paul.  Must alert container that the selection has changed. 
			// 04/07/2022 Paul.  Use selection key to force checkbox to update. 
			nSelectionKey++;
			this.selectedItems = selectedItems;
			this.selectedKeys  = selectedKeys ;
			this.checkedCount  = checkedCount ;
			this.loading       = false        ;
			if ( selectionChanged.observed )
			{
				selectionChanged.emit(selectedItems);
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectAll', error);
			this.error   = error;
			this.loading = false;
		}
	}

	// 07/18/2019 Paul.  This method can be called externally. 
	public onDeselectAll(e: any)
	{
		const { selectionChanged } = this;
		let { nSelectionKey } = this;
		if ( e != null )
		{
			e.preventDefault();
		}
		// 04/07/2022 Paul.  Use selection key to force checkbox to update. 
		nSelectionKey++;
		this.selectedItems = {};
		this.selectedKeys  = [];
		this.checkedCount  = 0 ;
		if ( selectionChanged.observed )
		{
			selectionChanged.emit({});
		}
	}

	public rowClasses(row: any, rowIndex: number)
	{
		return (rowIndex % 2 ? 'evenListRowS1' : 'oddListRowS1');
	}

	public async ExportModule(EXPORT_RANGE: string, EXPORT_FORMAT: string)
	{
		const { MODULE_NAME, ADMIN_MODE, archiveView, ListView } = this;
		const { SORT_FIELD, SORT_DIRECTION, TOP, SELECT_FIELDS, SEARCH_VALUES, activePage, selectedItems } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.ExportModule', EXPORT_RANGE, EXPORT_FORMAT);
		try
		{
			let sFILTER       : string   = null;
			let SELECTED_ITEMS: string[] = [];
			for ( let id in selectedItems )
			{
				SELECTED_ITEMS.push(id);
			}
			// 11/02/2020 Paul.  Provide spinner to export. 
			this.exporting = true;
			let d: any = await ListView.ExportModule(MODULE_NAME, SORT_FIELD, SORT_DIRECTION, SELECT_FIELDS, sFILTER, SEARCH_VALUES, TOP, TOP * (activePage - 1), ADMIN_MODE, archiveView, EXPORT_RANGE, EXPORT_FORMAT, SELECTED_ITEMS);
			//await this.setStateAsync({ __total: d.__total, __sql: d.__sql });
			//window.open(Credentials.RemoteServer + 'Import/ExportFile.aspx?FileID=' + d.ExportFileName);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onExport', d);
			// 11/10/2020 Paul.  Clear export error after success. 
			this.error     = null;
			this.exporting = false;
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ExportModule', error);
			this.error     = error;
			this.exporting = false;
		}
	}

	// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
	// https://www.gitmemory.com/issue/react-bootstrap-table/react-bootstrap-table2/793/465645955
	public selectionRenderer( sel: any )
	{
		const { mode, checked, disabled, rowIndex, rowKey } = sel;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.selectionRenderer', sel);
		let sClass: string = 'selection-input-4';
		let styCheckbox: any = {};
		if ( this.legacyIcons )
		{
			styCheckbox.transform = 'scale(1.0)';
		}
		return { tag: 'input', props: { type: mode, checked, disabled, class: sClass, style: styCheckbox, onChange: function onChange() {} }};
	}
	
	public selectionHeaderRenderer( sel: any )
	{
		const { mode, checked, indeterminate } = sel;
		const { SplendidCache } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.selectionHeaderRenderer', sel);
		let sTheme: string = SplendidCache.UserTheme;
		if ( sTheme == 'Pacific' )
		{
			return null;
		}
		else
		{
			let sClass: string = 'selection-input-4';
			let styCheckbox: any = {};
			if ( this.legacyIcons )
			{
				styCheckbox.transform = 'scale(1.0)';
			}
			return {tag: 'input', props: { type: mode, checked, class: sClass, style: styCheckbox, ref: function ref(input: any)
			{
				if ( input )
					input.indeterminate = indeterminate;
			}}};
		}
	}

	// 03/25/2022 Paul.  Add field chooser. 
	public _onChooseColumns()
	{
		this.isOpenFieldChooser = true;
	}

	public _onFieldChooserCallback(action: string, layoutDisplay: any, layoutHidden: any)
	{
		const { MODULE_NAME } = this;
		const { GRID_NAME, SORT_FIELD, SORT_DIRECTION } = this;
		if ( action == 'Cancel' )
		{
			this.isOpenFieldChooser = false;
		}
		else if ( action == 'Save' )
		{
			let layout          = layoutDisplay;
			let layoutAvailable = layoutHidden ;
			let SELECT_FIELDS   = this.GridColumns(layout);
			let columns: any[]  = null;
			if ( this.cbCustomColumns.observed )
			{
				// 06/14/2022 Paul.  TODO.  Support custom columns. 
				//columns = this.cbCustomColumns.emit({sLIST_MODULE_NAME: GRID_NAME, layout, sPRIMARY_MODULE: MODULE_NAME, sPRIMARY_ID: null});
			}
			else
			{
				columns = this.BootstrapColumns(GRID_NAME, layout, MODULE_NAME, null);
			}
			this.layout             = layout         ;
			this.layoutAvailable    = layoutAvailable;
			this.__total            = 0              ;
			this.vwMain             = null           ;
			this.SELECT_FIELDS      = SELECT_FIELDS  ;
			this.columns            = columns        ;
			this.isOpenFieldChooser = false          ;
			this.columnsChangedKey++;
			if ( this.onLayoutLoaded.observed )
			{
				this.onLayoutLoaded.emit();
			}
			if ( !this.deferLoad )
			{
				this.Sort(SORT_FIELD, SORT_DIRECTION);
			}
		}
	}

	public isPageSelected()
	{
		const { vwMain, selectedItems } = this;
		let pageSelectionCount: number = 0;
		if ( vwMain != null )
		{
			for ( let i = 0; i < vwMain.length; i++ )
			{
				let row = vwMain[i];
				if ( selectedItems[row.ID] )
				{
					pageSelectionCount++;
				}
			}
		}
		let isPageSelected: boolean = pageSelectionCount > 0 && pageSelectionCount == vwMain.length;
		return isPageSelected;
	}

	public _onPacificSelection(e: any)
	{
		const { enableSelection } = this;
		const { vwMain, selectedItems } = this;
		if ( enableSelection )
		{
			let isPageSelected: boolean = this.isPageSelected();
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onPacificSelection', isPageSelected);
			if ( isPageSelected )
				this.onDeselectAll(null);
			else
				this._onSelectPage(null);
		}
	}

	public refPacificSelection(element: any)
	{
		const { enableSelection } = this;
		const { vwMain, selectedItems } = this;
		this.chkPacificSelection = element;
		if ( this.chkPacificSelection != null && enableSelection )
		{
			// 04/07/2022 Paul.  The chkPacificSelection indicates if all items on current page are selected. 
			let pageCount: number = 0;
			if ( vwMain != null )
			{
				for ( let i = 0; i < vwMain.length; i++ )
				{
					let row = vwMain[i];
					if ( selectedItems[row.ID] )
					{
						pageCount++;
					}
				}
			}

			let checked      : boolean = pageCount > 0 && pageCount == vwMain.length;
			let indeterminate: boolean = pageCount > 0 && pageCount <  vwMain.length;
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.refPacificSelection ' + checked.toString(), indeterminate);
			//this.chkPacificSelection.checked       = checked;
			this.chkPacificSelection.indeterminate = indeterminate;
		}
	}

	// 04/10/2022 Paul.  Move Pacific Export to pagination header. 
	public _onEXPORT_RANGE_Change(event: any)
	{
		let EXPORT_RANGE: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEXPORT_RANGE_Change', EXPORT_RANGE);
		this.EXPORT_RANGE = EXPORT_RANGE;
	}

	public _onEXPORT_FORMAT_Change(event: any)
	{
		let EXPORT_FORMAT: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEXPORT_FORMAT_Change', EXPORT_FORMAT);
		this.EXPORT_FORMAT = EXPORT_FORMAT;
	}

	public async _onExport(e: any)
	{
		const { EXPORT_RANGE, EXPORT_FORMAT } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onExport', EXPORT_RANGE, EXPORT_FORMAT);
		this.ExportModule(EXPORT_RANGE, EXPORT_FORMAT);
	}

	// 04/23/2022 Paul.  Add no data indicator. 
	public emptyDataMessage()
	{
		/*
		return (
			<div style={ {fontSize: '1.5em'} }>{ L10n.Term('.LBL_NO_DATA') }</div>
		);
		*/
	}

	public _onPage_Command = (obj: {sCommandName: string, sCommandArguments: any}) =>
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onPage_Command', obj);
		this.Page_Command.emit(obj);
	}

	public _onHyperLinkCallback = (obj: {MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}) =>
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback', obj);
		this.hyperLinkCallback.emit(obj);
	}
}
