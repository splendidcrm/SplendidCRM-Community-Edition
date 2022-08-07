import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'      ;
import { Router, ActivatedRoute, ParamMap    } from '@angular/router'                          ;
import { faTimes                             } from '@fortawesome/free-solid-svg-icons'     ;

import { ApplicationService                  } from '../../scripts/Application'                ;
import { SplendidCacheService                } from '../../scripts/SplendidCache'              ;
import { CredentialsService                  } from '../../scripts/Credentials'                ;
import { ActiveModuleFromPath                } from '../../scripts/utility'                    ;
import { SecurityService                     } from '../../scripts/Security'                   ;
import { L10nService                         } from '../../scripts/L10n'                       ;
import { CrmConfigService, CrmModulesService } from '../../scripts/Crm'                        ;
import { EditViewService                     } from '../../scripts/EditView'                ;
import { ModuleUpdateService                 } from '../../scripts/ModuleUpdate'               ;
import Sql                                     from '../../scripts/Sql'                        ;
import SplendidDynamic                         from '../../scripts/SplendidDynamic'            ;
import MODULE                                  from '../../types/MODULE'                       ;
import ACL_ACCESS                              from '../../types/ACL_ACCESS'                   ;

import { DynamicButtonsComponent             } from '../../components/DynamicButtons'          ;
import { SplendidDynamic_EditViewComponent   } from '../../components/SplendidDynamic_EditView';

@Component({
	selector: 'MassUpdate',
	templateUrl: './MassUpdate.html',
})
export class MassUpdateComponent implements OnInit
{
	public    times                 = faTimes;
	public    bIsInitialized        : boolean  = null;
	public    bIsAuthenticated      : boolean  = null;
	// IMassUpdateState
	public    item                  : any     = null;
	public    layout                : any     = null;
	public    initialOpen           : boolean = null;
	public    bADMIN_MODE           : boolean = null;
	public    dependents            : Record<string, Array<any>> = null;
	public    selectedItems         : any     = null;
	public    error                 : any     = null;

	@Input()  MODULE_NAME           : string  = null;
	@Input()  archiveView           : boolean = null;
	@Output() onUpdateComplete      : EventEmitter<string> = new EventEmitter<string>();

	private dynamicButtons: DynamicButtonsComponent = null;
	@ViewChild('dynamicButtons') set dynamicButtonsRef(buttons: DynamicButtonsComponent)
	{
		//console.log(this.constructor.name + '.@ViewChild headerButtons', buttons);
		if ( buttons )
		{
			this.dynamicButtons = buttons;
			this._onButtonsLoaded();
		}
	};
	@ViewChild(SplendidDynamic_EditViewComponent) SplendidDynamic_EditView: SplendidDynamic_EditViewComponent;

	public IsStackedLayout()
	{
		return SplendidDynamic.StackedLayout(this.SplendidCache.UserTheme);
	}

	constructor(private router: Router, public Application: ApplicationService, protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, public Security: SecurityService, public L10n: L10nService, private Crm_Modules: CrmModulesService, private EditView: EditViewService, private ModuleUpdate: ModuleUpdateService)
	{
		this.bIsInitialized     = SplendidCache.IsInitialized ;
		this.bIsAuthenticated   = Credentials.bIsAuthenticated;
	}

	async ngOnInit()
	{
		const { Application, SplendidCache, EditView } = this;
		//console.log(this.constructor.name + '.ngOnInit');
		// 07/20/2019 Paul.  We need to pass a flag to the EditComponents to tell them not to initialize User and Team values. 
		let rowInitialValues: any = {};
		
		let initialOpen : boolean = Sql.ToBoolean(localStorage.getItem(this.MODULE_NAME + '.MassUpdate'));
		let module      : MODULE  = SplendidCache.Module(this.MODULE_NAME, this.constructor.name + '.constructor');
		if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
			initialOpen = false;
		this.layout      = null            ;
		this.item        = rowInitialValues;
		this.dependents  = {}              ;
		this.initialOpen = initialOpen     ;
		this.bADMIN_MODE = module.IS_ADMIN ;
		this.error       = null            ;
		try
		{
			let status = await this.Application.AuthenticatedMethod(null, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				let layout = EditView.LoadLayout(this.MODULE_NAME + '.MassUpdate');
				this.layout = layout;
			}
			else
			{
				this.Application.LoginRedirect(null, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.error = error;
		}
	}

	ngDoCheck(): void
	{
		const { SplendidCache, Credentials } = this;
		//console.log(this.constructor.name + '.ngDoCheck');
		let bChanged: boolean = false;
		if ( this.bIsInitialized != this.SplendidCache.IsInitialized )
		{
			//console.log(this.constructor.name + '.ngDoCheck IsInitialized changed');
			bChanged = true;
		}
		else if ( this.bIsAuthenticated != this.Credentials.bIsAuthenticated )
		{
			console.log(this.constructor.name + '.ngDoCheck bIsAuthenticated changed');
			bChanged = true;
		}
		if ( bChanged )
		{
			this.bIsInitialized     = SplendidCache.IsInitialized ;
			this.bIsAuthenticated   = Credentials.bIsAuthenticated;
		}
	}

	public async Page_Command(obj: {sCommandName: string, sCommandArguments: any})
	{
		const { sCommandName, sCommandArguments } = obj;
		const { item } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		if ( this.error != null )
		{
			this.error = null;
		}
		try
		{
			switch ( sCommandName )
			{
				case 'RulesWizard'         :  await this._onRulesWizard      (sCommandArguments);  break;  // All modules. 
				case 'MassUpdate'          :  await this._onMassUpdate       (sCommandArguments);  break;  // All modules. 
				case 'MassDelete'          :  await this._onMassDelete       (sCommandArguments);  break;  // All modules. 
				case 'Archive.MoveData'    :  await this._onArchiveMoveData  (sCommandArguments);  break;  // All primary non-admin modules. 
				case 'Archive.RecoverData' :  await this._onArchiveRecoverData(sCommandArguments);  break;  // All primary non-admin modules. 

				case 'MassMerge'           :  await this._onMassMerge        (sCommandArguments);  break;  // Accounts, Bugs, Cases, Contacts, Leads, Opportunities, Prospects. 
				case 'MailMerge'           :  await this._onMailMerge        (sCommandArguments);  break;  // Accounts, Contacts, Leads, Prospects. 
				case 'Sync'                :  await this._onSync             (sCommandArguments);  break;  // Accounts, Bugs, Cases, Contacts, Leads, Opportunities, Project. 
				case 'Unsync'              :  await this._onUnsync           (sCommandArguments);  break;  // Accounts, Bugs, Cases, Contacts, Leads, Opportunities, Project. 

				case 'MassDisable'         :  break;  // Exchange only. 
				case 'MassEnable'          :  break;  // Exchange only. 
				case 'MassPublic'          :  break;  // SimpleStorage only. 
				case 'MassPrivate'         :  break;  // SimpleStorage only. 
				case 'Import'              :  break;  // PayPal and PayTrace. 
				case 'ToggleMassUpdate'    :  this.initialOpen = !this.initialOpen;  break;
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.error = error;
		}
	}

	public ToggleMassUpdate()
	{
		this.initialOpen = !this.initialOpen;
	}

	public onToggleCollapse(open: boolean)
	{
		const { MODULE_NAME } = this;
		if ( open )
		{
			localStorage.setItem(MODULE_NAME + '.MassUpdate', 'true');
		}
		else
		{
			localStorage.removeItem(MODULE_NAME + '.MassUpdate');
		}
	}

	public SelectionChanged(value: any)
	{
		const { MODULE_NAME } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged: ' + MODULE_NAME, value);
		this.selectedItems = value;
		this.error         = null ;
	}

	public ValidateOne()
	{
		const { selectedItems, L10n } = this;
		let nSelectedCount = 0;
		for ( let id in selectedItems )
		{
			nSelectedCount++;
		}
		if ( nSelectedCount < 1 )
		{
			this.error = L10n.Term('.LBL_LISTVIEW_NO_SELECTED');
			return false;
		}
		return true;
	}

	public ValidateTwo()
	{
		const { selectedItems, L10n } = this;
		let nSelectedCount = 0;
		for ( let id in selectedItems )
		{
			nSelectedCount++;
		}
		if ( nSelectedCount < 2 )
		{
			this.error = L10n.Term('.LBL_LISTVIEW_TWO_REQUIRED');
			return false;
		}
		return true;
	}

	public async _onRulesWizard(sCommandArguments: string)
	{
		const { MODULE_NAME, L10n } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRulesWizard', MODULE_NAME);
		// 07/30/2022 Paul.  This code is not used as the buttons typically use ButtonLink. 
		this.router.navigateByUrl('/RulesWizard/Edit?Module=' + MODULE_NAME);
		this.error = L10n.Term('.LBL_FEATURE_NOT_SUPPORTED');
	}

	public _onMassUpdate = async (sCommandArguments: string) =>
	{
		const { MODULE_NAME, onUpdateComplete, SplendidDynamic_EditView, ModuleUpdate } = this;
		const { bADMIN_MODE, item, selectedItems } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassUpdate', selectedItems, item);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons != null )
				{
					this.dynamicButtons.Busy();
				}
				let row: any = {};
				let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row);
				await ModuleUpdate.MassUpdateModule(MODULE_NAME, row, arrID_LIST, bADMIN_MODE);
				if ( onUpdateComplete != null )
				{
					onUpdateComplete.emit('MassUpdate');
				}
				// 04/25/2020 Paul.  Clear after update. 
				SplendidDynamic_EditView.Clear();
				this.item = {};
			}
			catch(error: any)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassUpdate', error);
				this.error = error;
			}
			finally
			{
				if ( this.dynamicButtons != null )
				{
					this.dynamicButtons.NotBusy();
				}
			}
		}
	}

	// 07/16/2019 Paul.  Add support for MassDelete. 
	public async _onMassDelete(sCommandArguments: string)
	{
		const { MODULE_NAME, onUpdateComplete, L10n, ModuleUpdate } = this;
		const { bADMIN_MODE, selectedItems } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassDelete', selectedItems);
		if ( this.ValidateOne() )
		{
			// 08/11/2020 Paul.  Confirm delete. 
			if ( window.confirm(L10n.Term('.NTC_DELETE_CONFIRMATION')) )
			{
				let arrID_LIST = [];
				for ( let id in selectedItems )
				{
					arrID_LIST.push(id);
				}
				try
				{
					if ( this.dynamicButtons != null )
					{
						this.dynamicButtons.Busy();
					}
					await ModuleUpdate.MassDeleteModule(MODULE_NAME, arrID_LIST, bADMIN_MODE);
					if ( onUpdateComplete != null )
					{
						onUpdateComplete.emit('MassDelete');
					}
				}
				catch(error: any)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassDelete', error);
					this.error = error;
				}
				finally
				{
					if ( this.dynamicButtons != null )
					{
						this.dynamicButtons.NotBusy();
					}
				}
			}
		}
	}

	// 07/16/2019 Paul.  Add support for Rest API for ArchiveMoveData/ArchiveRecoverData. 
	private _onArchiveMoveData = async (sCommandArguments: string) =>
	{
		const { MODULE_NAME, onUpdateComplete, ModuleUpdate } = this;
		const { selectedItems } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveMoveData', selectedItems);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons != null )
				{
					this.dynamicButtons.Busy();
				}
				await ModuleUpdate.ArchiveMoveData(MODULE_NAME, arrID_LIST);
				if ( onUpdateComplete != null )
				{
					onUpdateComplete.emit('Archive.MoveData');
				}
			}
			catch(error: any)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveMoveData', error);
				this.error = error;
			}
			finally
			{
				if ( this.dynamicButtons != null )
				{
					this.dynamicButtons.NotBusy();
				}
			}
		}
	}

	private _onArchiveRecoverData = async (sCommandArguments: string) =>
	{
		const { MODULE_NAME, onUpdateComplete, ModuleUpdate } = this;
		const { selectedItems } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveRecoverData', selectedItems);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons != null )
				{
					this.dynamicButtons.Busy();
				}
				await ModuleUpdate.ArchiveRecoverData(MODULE_NAME, arrID_LIST);
				if ( onUpdateComplete != null )
				{
					onUpdateComplete.emit('Archive.RecoverData');
				}
			}
			catch(error: any)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onArchiveRecoverData', error);
				this.error = error;
			}
			finally
			{
				if ( this.dynamicButtons != null )
				{
					this.dynamicButtons.NotBusy();
				}
			}
		}
	}

	private _onMassMerge = async (sCommandArguments: string) =>
	{
		const { selectedItems, L10n } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMassMerge', selectedItems);
		if ( this.ValidateTwo() )
		{
			this.error = L10n.Term('.LBL_FEATURE_NOT_SUPPORTED');
		}
	}

	private _onMailMerge = async (sCommandArguments: string) =>
	{
		const { MODULE_NAME } = this;
		const { selectedItems } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMailMerge', selectedItems);
		if ( this.ValidateOne() )
		{
			let arrID: string[] = [];
			for ( let id in selectedItems )
			{
				arrID.push(id);
			}
			let sID: string = arrID.join(',');
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMailMerge', sID);
			this.router.navigateByUrl(`/Reset/MailMerge/${MODULE_NAME}/` + encodeURIComponent(sID));
		}
	}

	// 07/16/2019 Paul.  Add support for Rest API for MassSync/MassUnsync. 
	private _onSync = async (sCommandArguments: string) =>
	{
		const { MODULE_NAME, onUpdateComplete, ModuleUpdate } = this;
		const { selectedItems } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSync', selectedItems);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons != null )
				{
					this.dynamicButtons.Busy();
				}
				await ModuleUpdate.MassSync(MODULE_NAME, arrID_LIST);
				if ( onUpdateComplete != null )
				{
					onUpdateComplete.emit('Sync');
				}
			}
			catch(error: any)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSync', error);
				this.error = error;
			}
			finally
			{
				if ( this.dynamicButtons != null )
				{
					this.dynamicButtons.NotBusy();
				}
			}
		}
	}

	private _onUnsync = async (sCommandArguments: string) =>
	{
		const { MODULE_NAME, ModuleUpdate } = this;
		const { selectedItems } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUnsync', selectedItems);
		if ( this.ValidateOne() )
		{
			let arrID_LIST = [];
			for ( let id in selectedItems )
			{
				arrID_LIST.push(id);
			}
			try
			{
				if ( this.dynamicButtons != null )
				{
					this.dynamicButtons.Busy();
				}
				await ModuleUpdate.MassUnsync(MODULE_NAME, arrID_LIST);
			}
			catch(error: any)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onUnsync', error);
				this.error = error;
			}
			finally
			{
				if ( this.dynamicButtons != null )
				{
					this.dynamicButtons.NotBusy();
				}
			}
		}
	}

	public editViewCallback(obj: {DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any})
	{
		const { DATA_FIELD, DATA_VALUE } = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.editViewCallback ' + DATA_FIELD, DATA_VALUE);
		let { item  } = this;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
	}

	public _onChange = (obj: {DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any})=>
	{
		const { DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE } = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		let { item } = this;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
	}

	public _createDependency = (obj: {DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string}) =>
	{
		const { DATA_FIELD, PARENT_FIELD, PROPERTY_NAME } = obj;
		let { dependents } = this;
		if ( dependents[PARENT_FIELD] )
		{
			dependents[PARENT_FIELD].push( {DATA_FIELD, PROPERTY_NAME} );
		}
		else
		{
			dependents[PARENT_FIELD] = [ {DATA_FIELD, PROPERTY_NAME} ]
		}
	}

	public _onUpdate = (obj: {PARENT_FIELD: string, DATA_VALUE: any, item?: any}) =>
	{
		const { PARENT_FIELD, DATA_VALUE, item } = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE);
		let { dependents } = this;
		if ( dependents[PARENT_FIELD] )
		{
			let dependentIds = dependents[PARENT_FIELD];
			for ( let i = 0; i < dependentIds.length; i++ )
			{
				this.SplendidDynamic_EditView.updateDependancy(dependentIds[i].DATA_FIELD, PARENT_FIELD, DATA_VALUE, dependentIds[i].PROPERTY_NAME, item);
			}
		}
	}

	public _onSubmit = () =>
	{
		console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit');
		try
		{
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.error = error;
		}
	}

	private _onButtonsLoaded = async () =>
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

}
