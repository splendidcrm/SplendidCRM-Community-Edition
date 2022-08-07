import { Component, OnInit, Input, Output, ViewChild, EventEmitter } from '@angular/core'   ;
import { Router, ActivatedRoute, ParamMap    } from '@angular/router'                       ;
import { faSpinner                           } from '@fortawesome/free-solid-svg-icons'     ;

import { ApplicationService                  } from '../../scripts/Application'             ;
import { SplendidCacheService                } from '../../scripts/SplendidCache'           ;
import { CredentialsService                  } from '../../scripts/Credentials'             ;
import { SecurityService                     } from '../../scripts/Security'                ;
import { L10nService                         } from '../../scripts/L10n'                    ;
import { CrmConfigService, CrmModulesService } from '../../scripts/Crm'                     ;
import { EditViewService                     } from '../../scripts/EditView'                ;
import { ModuleUpdateService                 } from '../../scripts/ModuleUpdate'            ;

import { ActiveModuleFromPath                } from '../../scripts/utility'                 ;
import Sql                                     from '../../scripts/Sql'                     ;
import EDITVIEWS_FIELD                         from '../../types/EDITVIEWS_FIELD'           ;
import ACL_ACCESS                              from '../../types/ACL_ACCESS'                ;

import { HeaderButtonsFactoryComponent       } from '../../Themes/HeaderButtonsFactory'     ;
import { SplendidDynamic_EditViewComponent   } from '../../components/SplendidDynamic_EditView';

@Component({
  selector: 'EditView',
  templateUrl: './EditView.html',
})
export class EditViewComponent implements OnInit
{
	private   lastPathname       : string  = null;
	public    bIsInitialized     : boolean = null;
	private   bIsAuthenticated   : boolean = null;
	private   adminMode          : boolean = null;
	private   lastModule         : string  = null;
	public    spinner            = faSpinner;

	public    DuplicateID        : string = null;
	public    ConvertModule      : string = null;
	public    ConvertID          : string = null;
	private   PARENT_ID          : string = null;
	private   PARENT_TYPE        : string = null;

	 // IEditViewState
	public    __total            : number  = null;
	public    __sql              : string  = null;
	public    item               : any     = null;
	public    layout             : EDITVIEWS_FIELD[];
	public    EDIT_NAME          : string  = null;
	public    DUPLICATE          : boolean = null;
	public    LAST_DATE_MODIFIED : Date    = null;
	public    SUB_TITLE          : any     = null;
	public    editedItem         : any     = null;
	public    dependents         : Record<string, Array<any>>;
	public    error              : any     = null;

	@Input()  MODULE_NAME        : string  = null;  // 03/01/2019 Paul.  Parents module will be converted to actual module. 
	@Input()  ID                 : string  = null;
	@Input()  LAYOUT_NAME        : string  = null;
	// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
	@Input()  CONTROL_VIEW_NAME  : string  = null;
	@Input()  rowDefaultSearch   : any     = null;
	@Input()  isPrecompile       : boolean = false;
	@Input()  isSearchView       : boolean = false;
	@Input()  isUpdatePanel      : boolean = false;
	@Input()  isQuickCreate      : boolean = false;
	// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
	@Input()  fromLayoutName     : string  = null;
	// 06/13/2022 Paul.  callback.observed is not sufficient to determine if this is an embedded view. 
	@Input()  hasCallback        : boolean = null;
	@Output() onLayoutLoaded     : EventEmitter<void> = new EventEmitter<void>();
	@Output() onSubmit           : EventEmitter<void> = new EventEmitter<void>();
	@Output() onComponentComplete: EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}> = new EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}>();
	@Output() callback           : EventEmitter<{key: string, newValue: any}> = new EventEmitter<{key: string, newValue: any}>();
	// 06/03/2022 Paul.  this.headerButtons not ready in ngAfterViewInit() because of *ngIf that wraps it.
	// The solution is to use the ViewChild setter.
	private headerButtons: HeaderButtonsFactoryComponent = null;
	@ViewChild('headerButtons') set headerButtonsRef(buttons: HeaderButtonsFactoryComponent)
	{
		//console.log(this.constructor.name + '.@ViewChild headerButtons', buttons);
		if ( buttons )
		{
			this.headerButtons = buttons;
			this._onButtonsLoaded();
		}
	};
	private dynamicButtonsBottom: HeaderButtonsFactoryComponent = null;
	@ViewChild('dynamicButtonsBottom') set dynamicButtonsBottomRef(buttons: HeaderButtonsFactoryComponent)
	{
		//console.log(this.constructor.name + '.@ViewChild dynamicButtonsBottom', buttons);
		if ( buttons )
		{
			this.dynamicButtonsBottom = buttons;
			this._onButtonsLoaded();
		}
	};
	@ViewChild(SplendidDynamic_EditViewComponent) SplendidDynamic_EditView: SplendidDynamic_EditViewComponent;

	public IsError()
	{
		return this.layout == null || (this.item == null && (!Sql.IsEmptyString(this.ID) || !Sql.IsEmptyString(this.DuplicateID) || !Sql.IsEmptyString(this.ConvertID)));
	}

	public IsReady()
	{
		return !this.IsError() && this.bIsInitialized;
	}

	public IsNotReady()
	{
		return !this.IsReady();
	}

	public get data (): any
	{
		let row: any = {};
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = this.SplendidDynamic_EditView.BuildDataRow(row);
		// 08/26/2019 Paul.  There does not seem to be a need to save date in DATE_TIME field here as this is used for search views. 
		if ( nInvalidFields == 0 )
		{
		}
		return row;
	}

	public validate(): boolean
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = this.SplendidDynamic_EditView.Validate();
		return (nInvalidFields == 0);
	}

	public clear(): void
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		this.SplendidDynamic_EditView.Clear();
		this.editedItem = {};
	}

	constructor(private router: Router, private route: ActivatedRoute, public Application: ApplicationService, public SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, public Security: SecurityService, public L10n: L10nService, public Crm_Config: CrmConfigService, private Crm_Modules: CrmModulesService, private EditView: EditViewService, private ModuleUpdate: ModuleUpdateService)
	{
		this.lastModule         = ActiveModuleFromPath(SplendidCache, window.location.pathname, this.constructor.name + '.constructor');
		this.lastPathname       = window.location.pathname    ;
		this.bIsInitialized     = SplendidCache.IsInitialized ;
		this.bIsAuthenticated   = Credentials.bIsAuthenticated;
		this.adminMode          = Credentials.ADMIN_MODE      ;
		this.DuplicateID        = this.route.snapshot.paramMap.get('DuplicateID'  );
		this.ConvertModule      = this.route.snapshot.paramMap.get('ConvertModule');
		this.ConvertID          = this.route.snapshot.paramMap.get('ConvertID'    );
	}

	ngOnInit()
	{
		console.log(this.constructor.name + '.ngOnInit', this.LAYOUT_NAME, this.MODULE_NAME, this.ID);
		this.Reset('ngOnInit');
	}

	ngDoCheck()
	{
		//console.log(this.constructor.name + '.ngDoCheck LAYOUT_NAME', this.LAYOUT_NAME);
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
		else if ( this.adminMode != this.Credentials.ADMIN_MODE )
		{
			console.log(this.constructor.name + '.ngDoCheck ADMIN_MODE changed');
			bChanged = true;
		}
		else if ( this.SplendidCache.IsInitialized && this.lastModule != this.MODULE_NAME )
		{
			console.log(this.constructor.name + '.ngDoCheck lastModule changed');
			bChanged = true;
		}
		else if ( !Sql.IsEmptyString(this.LAYOUT_NAME) && this.EDIT_NAME != this.LAYOUT_NAME )
		{
			console.log(this.constructor.name + '.ngDoCheck LAYOUT_NAME changed');
			bChanged = true;
		}
		if ( bChanged )
		{
			console.log(this.constructor.name + '.ngDoCheck', this.LAYOUT_NAME, this.MODULE_NAME, this.ID);
			this.Reset('ngDoCheck');
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
		// 06/03/2022 Paul.  this.headerButtons not ready in ngAfterViewInit() because of *ngIf that wraps it. 
		//console.log(this.constructor.name + '.ngAfterViewInit headerButtons', this.headerButtons);
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

	private async Reset(source: string)
	{
		//console.log(this.constructor.name + '.Reset ' + source, this.LAYOUT_NAME);
		//this.lastModule         = ActiveModuleFromPath(this.SplendidCache, window.location.pathname, this.constructor.name + '.ngDoCheck');
		this.lastModule         = this.MODULE_NAME                 ;
		this.lastPathname       = window.location.pathname         ;
		this.bIsInitialized     = this.SplendidCache.IsInitialized ;
		this.bIsAuthenticated   = this.Credentials.bIsAuthenticated;
		this.adminMode          = this.Credentials.ADMIN_MODE      ;
		if ( !this.isSearchView )
		{
			if ( Sql.IsEmptyString(this.MODULE_NAME) )
			{
				this.MODULE_NAME        = this.route.snapshot.paramMap.get('MODULE_NAME');
			}
			if ( Sql.IsEmptyString(this.ID) )
			{
				this.ID                 = this.route.snapshot.paramMap.get('ID'         );
			}
			if ( Sql.IsEmptyString(this.LAYOUT_NAME) )
			{
				this.LAYOUT_NAME        = this.route.snapshot.paramMap.get('LAYOUT_NAME');
			}
		}
		let item                = (this.rowDefaultSearch ? this.rowDefaultSearch : null);
		let EDIT_NAME: string = this.MODULE_NAME + '.EditView';
		if ( !Sql.IsEmptyString(this.LAYOUT_NAME) )
		{
			EDIT_NAME = this.LAYOUT_NAME;
		}
		this.__total            = 0;
		this.__sql              = null;
		this.item               = item;
		this.layout             = null;
		this.EDIT_NAME          = EDIT_NAME;
		this.DUPLICATE          = false;
		this.LAST_DATE_MODIFIED = null;
		this.SUB_TITLE          = null;
		this.editedItem         = null;
		this.dependents         = {};
		this.error              = null;

		try
		{
			let status = await this.Application.AuthenticatedMethod(null, this.constructor.name + '.Reset ' + source);
			if ( status == 1 )
			{
				if ( this.SplendidCache.jsonReactState == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount jsonReactState is null');
				}
				if ( this.Credentials.ADMIN_MODE )
				{
					this.Credentials.SetADMIN_MODE(false);
				}
				await this.preload();
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

	private _areRelationshipsComplete: boolean = false;

	public onRelationshipsComplete = (obj: {MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}) =>
	{
		const { MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain} = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.onRelationshipsComplete ' + LAYOUT_NAME, vwMain);
		this._areRelationshipsComplete = true;
		if ( this.onComponentComplete )
		{
			if ( this.layout != null && this.error == null )
			{
				if ( this.item != null && this._areRelationshipsComplete )
				{
					this.onComponentComplete.emit({MODULE_NAME, RELATED_MODULE: null, LAYOUT_NAME: this.EDIT_NAME, vwMain: this.item});
				}
			}
		}
	}

	private async preload()
	{
		// 01/19/2013 Paul.  A Parents module requires a lookup to get the module name. 
		try
		{
			let sMODULE_NAME = this.MODULE_NAME;
			if ( sMODULE_NAME == 'Parents' )
			{
				try
				{
					sMODULE_NAME = await this.Crm_Modules.ParentModule(this.ID);
					this.MODULE_NAME = sMODULE_NAME;
					await this.load(sMODULE_NAME, this.ID);
				}
				catch(error: any)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.preload', error);
					this.error = error;
				}
			}
			else
			{
				await this.load(sMODULE_NAME, this.ID);
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.preload', error);
			this.error = error;
		}
	}

	private async load(sMODULE_NAME: string, sID: string)
	{
		const { MODULE_NAME, ID, DuplicateID, ConvertModule, ConvertID, EDIT_NAME, route, Crm_Modules, EditView } = this;
		console.log(this.constructor.name + '.load', this.LAYOUT_NAME, sMODULE_NAME, sID);
		try
		{
			// 10/12/2019 Paul.  Add support for parent assignment during creation. 
			let rowDefaultSearch: any = this.rowDefaultSearch;
			// 10/13/2020 Paul.  Correct parent found condition. 
			let bParentFound: boolean = (rowDefaultSearch !== undefined && rowDefaultSearch != null);
			if ( !Sql.IsEmptyGuid(route.snapshot.queryParamMap.get('PARENT_ID')) )
			{
				this.PARENT_ID   = route.snapshot.queryParamMap.get('PARENT_ID');
				this.PARENT_TYPE = await Crm_Modules.ParentModule(this.PARENT_ID);
				if ( !Sql.IsEmptyString(this.PARENT_TYPE) )
				{
					rowDefaultSearch = await Crm_Modules.LoadParent(this.PARENT_TYPE, this.PARENT_ID);
					bParentFound = true;
				}
				else
				{
					this.error = 'Parent ID [' + this.PARENT_ID + '] was not found.';;
				}
			}
			// 05/28/2020 Paul.  Ignore missing SearchSubpanel. 
			const layout: any = EditView.LoadLayout(EDIT_NAME, this.isSearchView);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load ' + EDIT_NAME, layout);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			this.layout       = layout;
			this.item         = (this.rowDefaultSearch ? this.rowDefaultSearch : null);
			this.editedItem   = null;
			this.onLayoutLoaded.emit();
			if ( !Sql.IsEmptyString(DuplicateID) )
			{
				await this.LoadItem(MODULE_NAME, DuplicateID);
			}
			else if ( !Sql.IsEmptyString(ConvertID) )
			{
				await this.ConvertItem(MODULE_NAME, ConvertModule, ConvertID);
			}
			else
			{
				await this.LoadItem(MODULE_NAME, ID);
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.error = error;
		}
	}

	private async LoadItem(sMODULE_NAME: string, sID: string)
	{
		const { callback, isSearchView, isUpdatePanel } = this;
		const { L10n, Crm_Config, EditView } = this;
		console.log(this.constructor.name + '.LoadItem', this.LAYOUT_NAME, sMODULE_NAME, sID);
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView.LoadItem(sMODULE_NAME, sID);
				let item: any = d.results;
				let LAST_DATE_MODIFIED: Date = null;
				// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
				if ( item != null && item['DATE_MODIFIED'] !== undefined )
				{
					LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
				}
				Sql.SetPageTitle(Crm_Config, L10n, sMODULE_NAME, item, 'NAME');
				let SUB_TITLE: any = Sql.DataPrivacyErasedField(Crm_Config, L10n, item, 'NAME');
				this.item               = item              ;
				this.SUB_TITLE          = SUB_TITLE         ;
				this.__sql              = d.__sql           ;
				this.LAST_DATE_MODIFIED = LAST_DATE_MODIFIED;
			}
			catch(error: any)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.error = error;;
			}
		}
		else if ( !callback && !isSearchView && !isUpdatePanel )
		{
			Sql.SetPageTitle(Crm_Config, L10n, sMODULE_NAME, null, null);
		}
	}

	private async ConvertItem(sMODULE_NAME: string, sSOURCE_MODULE_NAME: string, sSOURCE_ID: string)
	{
		const { L10n, Crm_Config, EditView } = this;
		if ( !Sql.IsEmptyString(sSOURCE_ID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView.ConvertItem(sMODULE_NAME, sSOURCE_MODULE_NAME, sSOURCE_ID);
				let LAST_DATE_MODIFIED: Date = null;
				let item: any = d.results;
				Sql.SetPageTitle(Crm_Config, L10n, sMODULE_NAME, item, 'NAME');
				let SUB_TITLE: any = Sql.DataPrivacyErasedField(Crm_Config, L10n, item, 'NAME');
				this.item               = item              ;
				this.SUB_TITLE          = SUB_TITLE         ;
				this.__sql              = d.__sql           ;
				this.LAST_DATE_MODIFIED = LAST_DATE_MODIFIED;
			}
			catch(error: any)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.error = error;
			}
		}
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	public async Page_Command(obj: {sCommandName: string, sCommandArguments: any})
	{
		const { router, L10n, ModuleUpdate } = this;
		const { sCommandName, sCommandArguments } = obj;
		console.log(this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		const { ID, MODULE_NAME, LAST_DATE_MODIFIED } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row: any = null;
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					row = {
						ID: isDuplicate ? null : ID
					};
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = this.SplendidDynamic_EditView.BuildDataRow(row);
					if ( nInvalidFields == 0 )
					{
						if ( LAST_DATE_MODIFIED != null )
						{
							row['LAST_DATE_MODIFIED'] = LAST_DATE_MODIFIED;
						}
						if ( sCommandName == 'SaveDuplicate' || sCommandName == 'SaveConcurrency' )
						{
							row[sCommandName] = true;
						}
						try
						{
							if ( this.headerButtons != null )
							{
								this.headerButtons.Busy();
							}
							row.ID = await ModuleUpdate.UpdateModule(MODULE_NAME, row, isDuplicate ? null : ID);
							// 10/15/2019 Paul.  Redirect to parent if provided. 
							if ( !Sql.IsEmptyGuid(this.PARENT_ID) )
							{
								this.router.navigateByUrl(`/Reset/${this.PARENT_TYPE}/View/${this.PARENT_ID}`);
							}
							else
							{
								this.router.navigateByUrl(`/Reset/${MODULE_NAME}/View/` + row.ID);
							}
						}
						catch(error: any)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
							if ( this.headerButtons != null )
							{
								this.headerButtons.NotBusy();
							}
							if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
							{
								if ( this.headerButtons != null )
								{
									this.headerButtons.ShowButton('SaveDuplicate', true);
								}
								this.error = L10n.Term(error.message);
							}
							else if ( error.message.includes('.ERR_CONCURRENCY_OVERRIDE') )
							{
								if ( this.headerButtons != null )
								{
									this.headerButtons.ShowButton('SaveConcurrency', true);
								}
								this.error = L10n.Term(error.message);
							}
							else
							{
								this.error = null;
							}
						}
					}
					break;
				}
				case 'Cancel':
				{
					// 10/15/2019 Paul.  Redirect to parent if provided. 
					if ( !Sql.IsEmptyGuid(this.PARENT_ID) )
					{
						this.router.navigateByUrl(`/Reset/${this.PARENT_TYPE}/View/${this.PARENT_ID}`);
					}
					else if ( Sql.IsEmptyString(ID) )
					{
						this.router.navigateByUrl(`/Reset/${MODULE_NAME}/List`);
					}
					else
					{
						this.router.navigateByUrl(`/Reset/${MODULE_NAME}/View/${ID}`);
					}
					break;
				}
				default:
				{
					this.error = sCommandName + ' is not supported at this time';;
					break;
				}
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.error = error;
		}
	}

	// 06/07/2022 Paul.  _onButtonsLoaded does not do anything in a typical EditView. 
	public _onButtonsLoaded()
	{
		//console.log(this.constructor.name + '._onButtonsLoaded', this.headerButtons);
	}

	// 04/13/2022 Paul.  Add LayoutTabs to Pacific theme. 
	public _onTabChange(nActiveTabIndex: number)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTabChange', nActiveTabIndex);
		this.EditView.ActivateTab(this.layout, nActiveTabIndex);
	}

	public _onEditViewCallback(event: any)
	{
	}

}
