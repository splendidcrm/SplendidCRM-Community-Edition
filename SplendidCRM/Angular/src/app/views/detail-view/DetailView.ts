import { Component, OnInit, Input, Output, ViewChild, EventEmitter } from '@angular/core'   ;
import { Router, ActivatedRoute, ParamMap    } from '@angular/router'                       ;
import { faSpinner                           } from '@fortawesome/free-solid-svg-icons'     ;

import { ApplicationService                  } from '../../scripts/Application'             ;
import { SplendidCacheService                } from '../../scripts/SplendidCache'           ;
import { CredentialsService                  } from '../../scripts/Credentials'             ;
import { SecurityService                     } from '../../scripts/Security'                ;
import { L10nService                         } from '../../scripts/L10n'                    ;
import { CrmConfigService, CrmModulesService } from '../../scripts/Crm'                     ;
import { DetailViewService                   } from '../../scripts/DetailView'              ;
import { ModuleUpdateService                 } from '../../scripts/ModuleUpdate'            ;

import { ActiveModuleFromPath                } from '../../scripts/utility'                 ;
import Sql                                     from '../../scripts/Sql'                     ;
import DETAILVIEWS_FIELD                       from '../../types/DETAILVIEWS_FIELD'         ;
import ACL_ACCESS                              from '../../types/ACL_ACCESS'                ;

import { HeaderButtonsFactoryComponent       } from '../../Themes/HeaderButtonsFactory'     ;

@Component({
  selector: 'DetailView',
  templateUrl: './DetailView.html',
})
export class DetailViewComponent implements OnInit
{
	private lastPathname         : string  = null;
	public  bIsInitialized       : boolean = null;
	private bIsAuthenticated     : boolean = null;
	private adminMode            : boolean = null;
	private lastModule           : string  = null;
	public  spinner              = faSpinner;

	 // IDetailViewState
	public  __total              : number  = null;
	public  __sql                : string  = null;
	public  item                 : any     = null;
	public  layout               : DETAILVIEWS_FIELD[] = null;
	public  summaryLayout        : any     = null;
	public  DETAIL_NAME          : string  = null;
	public  SUB_TITLE            : any     = null;
	public  auditOpen            : boolean = null;
	public  activitiesOpen       : boolean = null;
	public  archiveView          : boolean = null;
	public  archiveExists        : boolean = null;
	public  error                : any     = null;

	@Input()  MODULE_NAME        : string  = null;  // 03/01/2019 Paul.  Parents module will be converted to actual module. 
	@Input()  ID                 : string  = null;
	@Input()  LAYOUT_NAME        : string  = null;
	@Input()  isPrecompile       : boolean = false;
	@Output() onComponentComplete: EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}> = new EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}>();
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

	public IsReady()
	{
		return this.bIsInitialized && this.layout != null && this.item != null;
	}

	public ArchiveExists()
	{
		return !this.IsReady() && this.archiveExists;
	}

	public IsError()
	{
		return !this.ArchiveExists() && this.error != null;
	}

	public IsNotReady()
	{
		return !this.IsError();
	}

	constructor(private router: Router, private route: ActivatedRoute, public Application: ApplicationService, public SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, public Security: SecurityService, public L10n: L10nService, public Crm_Config: CrmConfigService, private Crm_Modules: CrmModulesService, private DetailView: DetailViewService, private ModuleUpdate: ModuleUpdateService)
	{
		this.lastModule         = ActiveModuleFromPath(SplendidCache, window.location.pathname, this.constructor.name + '.constructor');
		this.lastPathname       = window.location.pathname    ;
		this.bIsInitialized     = SplendidCache.IsInitialized ;
		this.bIsAuthenticated   = Credentials.bIsAuthenticated;
		this.adminMode          = Credentials.ADMIN_MODE      ;
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit', window.location.pathname);
		this.Reset('ngOnInit');
	}

	ngDoCheck()
	{
		//console.log(this.constructor.name + '.ngDoCheck', window.location.pathname);
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
		if ( bChanged )
		{
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
		//this.lastModule         = ActiveModuleFromPath(this.SplendidCache, window.location.pathname, this.constructor.name + '.ngDoCheck');
		this.lastModule         = this.MODULE_NAME                 ;
		this.lastPathname       = window.location.pathname         ;
		this.bIsInitialized     = this.SplendidCache.IsInitialized ;
		this.bIsAuthenticated   = this.Credentials.bIsAuthenticated;
		this.adminMode          = this.Credentials.ADMIN_MODE      ;
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
			this.LAYOUT_NAME = this.route.snapshot.paramMap.get('LAYOUT_NAME');
		}

		let archiveView: boolean = false;
		if ( window.location.pathname.indexOf('/ArchiveView') >= 0 )
		{
			archiveView = true;
		}

		let DETAIL_NAME: string = this.MODULE_NAME + (archiveView ? '.ArchiveView' : '.DetailView');
		if ( !Sql.IsEmptyString(this.LAYOUT_NAME) )
		{
			DETAIL_NAME = this.LAYOUT_NAME;
		}
		this.__total         = 0;
		this.__sql           = null;
		this.item            = null;
		this.layout          = null;
		this.summaryLayout   = null;
		this.DETAIL_NAME     = DETAIL_NAME;
		this.SUB_TITLE       = null,
		this.auditOpen       = false;
		this.activitiesOpen  = false;
		this.archiveView     = archiveView;
		this.archiveExists   = false;
		this.error           = null;

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
					this.onComponentComplete.emit({MODULE_NAME, RELATED_MODULE: null, LAYOUT_NAME: this.DETAIL_NAME, vwMain: this.item});
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
		try
		{
			const layout = this.DetailView.LoadLayout(this.DETAIL_NAME);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			this.layout        = layout;
			this.item          = null  ;
			this.summaryLayout = null  ;
			if ( sMODULE_NAME == 'Quotes' || sMODULE_NAME == 'Orders' || sMODULE_NAME == 'Invoices' )
			{
				try
				{
					let sSUMMARY_NAME = this.DETAIL_NAME.replace('.DetailView', '.SummaryView');
					const summaryLayout = this.DetailView.LoadLayout(sSUMMARY_NAME);
					this.summaryLayout = summaryLayout;
					await this.LoadItem(sMODULE_NAME, sID);
				}
				catch(error: any)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load Summary', error);
					this.error = error;
					await this.LoadItem(sMODULE_NAME, sID);
				}
			}
			else
			{
				await this.LoadItem(sMODULE_NAME, sID);
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
		const { L10n, Crm_Config, DetailView } = this;
		try
		{
			// 11/19/2019 Paul.  Change to allow return of SQL. 
			const d = await DetailView.LoadItem(sMODULE_NAME, sID, false, this.archiveView);
			let item: any = d.results;
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', d);

			// 11/23/2020 Paul.  Update document title. 
			Sql.SetPageTitle(Crm_Config, L10n, sMODULE_NAME, item, 'NAME');
			let SUB_TITLE: any = Sql.DataPrivacyErasedField(Crm_Config, L10n, item, 'NAME');
			this.item      = item     ;
			this.SUB_TITLE = SUB_TITLE;
			this.__sql     =  d.__sql ;
			// 04/29/2019 Paul.  Manually add to the list so that we do not need to request an update. 
			if ( item != null )
			{
				let sNAME = Sql.ToString(item['NAME']);
				if ( !Sql.IsEmptyString(sNAME) )
				{
					this.SplendidCache.AddLastViewed(sMODULE_NAME, sID, sNAME);
				}
			}
		}
		catch(error: any)
		{
			// 12/18/2019 Paul.  Display archived message if the record has been archived. 
			if ( !this.archiveView )
			{
				try
				{
					const d = await this.DetailView.LoadItem(sMODULE_NAME, sID, false, true);
					let item: any = d.results;
					Sql.SetPageTitle(this.Crm_Config, L10n, sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(Crm_Config, L10n, item, 'NAME');
					this.SUB_TITLE     = SUB_TITLE;
					this.__sql         = d.__sql;
					this.archiveExists = true;
					this.error         = L10n.Term('.LBL_ARCHIVED_RECORD');
				}
				catch(errorArchive)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error, errorArchive);
					// 12/18/2019 Paul.  Display original error, not the archive error. 
					this.error = error;
				}
			}
			else
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
		const { router, ModuleUpdate } = this;
		const { sCommandName, sCommandArguments } = obj;
		console.log(this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Edit':
			{
				this.router.navigateByUrl(`/Reset/${this.MODULE_NAME}/Edit/${this.ID}`);
				break;
			}
			case 'Duplicate':
			{
				this.router.navigateByUrl(`/Reset/${this.MODULE_NAME}/Duplicate/${this.ID}`);
				break;
			}
			case 'Convert':
			{
				let sNewModule: string = sCommandArguments;
				if ( !Sql.IsEmptyString(sNewModule) )
				{
					this.router.navigateByUrl(`/Reset/${sNewModule}/Convert/${this.MODULE_NAME}/${this.ID}`);
				}
				else
				{
					this.error = 'NewModule is null';
				}
				break;
			}
			// 02/10/2021 Paul.  Enable support for Archive.ViewData. 
			case 'Archive.ViewData':
			{
				this.router.navigateByUrl(`/Reset/${this.MODULE_NAME}/ArchiveView/${this.ID}`);
				break;
			}
			case 'Archive.MoveData':
			{
				await this._onArchiveMoveData();
				break;
			}
			case 'Archive.RecoverData':
			{
				await this._onArchiveRecoverData();
				break;
			}
			case 'Cancel':
			{
				this.router.navigateByUrl(`/Reset/${this.MODULE_NAME}/List`);
				break;
			}
			case 'Delete':
			{
				try
				{
					await ModuleUpdate.DeleteModuleItem(this.MODULE_NAME, this.ID);
					router.navigateByUrl(`/Reset/${this.MODULE_NAME}/List`);
				}
				catch(error: any)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
					this.error = error;
				}
				break;
			}
			case 'ViewLog':
			{
				// 05/28/2022 Paul.  TODO.  configure audit view.
				/*
				if ( this.auditView.current != null )
				{
					await this.auditView.current.loadData();
					this.auditOpen = true;
				}
				*/
				break;
			}
			case 'ViewRelatedActivities':
			{
				// 05/28/2022 Paul.  TODO.  configure activities view.
				/*
				if ( this.activitiesView.current != null )
				{
					let bIncludeRelationships: boolean = Sql.ToString(sCommandArguments).indexOf('IncludeRelationships=1') >= 0;
					await this.activitiesView.current.loadData(bIncludeRelationships);
					this.activitiesOpen = true;
				}
				*/
				break;
			}
			default:
			{
				this.error = sCommandName + ' is not supported at this time';
				break;
			}
		}
	}

	private async _onArchiveMoveData()
	{
		let arrID_LIST = [];
		arrID_LIST.push(this.ID);
		try
		{
			// 05/28/2022 Paul.  TODO.  configure header buttons.
			if ( this.headerButtons != null )
			{
				this.headerButtons.Busy();
			}
			await this.ModuleUpdate.ArchiveMoveData(this.MODULE_NAME, arrID_LIST);
			this.router.navigateByUrl(`/Reset/${this.MODULE_NAME}/ArchiveView/${this.ID}`);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveMoveData', error);
			this.error = error;
		}
		finally
		{
			// 05/28/2022 Paul.  TODO.  configure header buttons.
			if ( this.headerButtons != null )
			{
				this.headerButtons.NotBusy();
			}
		}
	}

	private async _onArchiveRecoverData()
	{
		let arrID_LIST = [];
		arrID_LIST.push(this.ID);
		try
		{
			// 05/28/2022 Paul.  TODO.  configure header buttons.
			if ( this.headerButtons != null )
			{
				this.headerButtons.Busy();
			}
			await this.ModuleUpdate.ArchiveRecoverData(this.MODULE_NAME, arrID_LIST);
			this.router.navigateByUrl(`/Reset/${this.MODULE_NAME}/View/${this.ID}`);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveRecoverData', error);
			this.error = error;
		}
		finally
		{
			// 05/28/2022 Paul.  TODO.  configure header buttons.
			if ( this.headerButtons != null )
			{
				this.headerButtons.NotBusy();
			}
		}
	}

	private ArchiveView()
	{
		return this.archiveView;
	}

	private ArchiveViewEnabled()
	{
		return this.ArchiveView() && this.Crm_Modules.ArchiveEnabled(this.MODULE_NAME);
	}

	// 06/03/2022 Paul.  This event should be called from ViewChild setter as this.headerButtons will not be available until then.
	// We do not need to wire inside the html. 
	public _onButtonsLoaded()
	{
		//console.log(this.constructor.name + '._onButtonsLoaded', this.headerButtons);
		// 08/12/2019 Paul.  Here is where we can disable buttons immediately after they were loaded.
		if ( this.headerButtons != null )
		{
			let nACLACCESS_Archive: number = this.SplendidCache.GetUserAccess(this.MODULE_NAME, 'archive', this.constructor.name + '._onButtonsLoaded');
			this.headerButtons.ShowButton('Archive.MoveData'   , (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || this.Security.IS_ADMIN) && !this.ArchiveView() && this.Crm_Modules.ArchiveEnabled(this.MODULE_NAME));
			this.headerButtons.ShowButton('Archive.RecoverData', (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || this.Security.IS_ADMIN) &&  this.ArchiveView() && this.Crm_Modules.ArchiveEnabled(this.MODULE_NAME));
			// 08/13/2019 Paul.  PersonalInfo only applies to Accounts, Contacts, Leads and Prospects. 
			this.headerButtons.ShowButton('PersonalInfo'       , this.Crm_Config.enable_data_privacy());
		}
		else
		{
		}
	}

	public _onAuditClose()
	{
		this.auditOpen = false;
	}

	public _onActivitiesClose()
	{
		this.activitiesOpen = false;
	}

	// 04/13/2022 Paul.  Add LayoutTabs to Pacific theme. 
	public _onTabChange(nActiveTabIndex: number)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTabChange', nActiveTabIndex);
		this.DetailView.ActivateTab(this.layout, nActiveTabIndex);
	}

}
