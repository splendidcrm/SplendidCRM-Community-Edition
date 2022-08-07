import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { ModuleUpdateService                                       } from '../scripts/ModuleUpdate'      ;
import Sql                                                           from '../scripts/Sql'               ;
import DYNAMIC_BUTTON                                                from '../types/DYNAMIC_BUTTON'      ;
import MODULE                                                        from '../types/MODULE'              ;

import { DynamicButtonsComponent                                   } from '../components/DynamicButtons';

@Component({
	selector: 'HeaderButtonsBase',
	template: `Header Buttons Base`,
})
export class HeaderButtonsBase implements OnInit
{
	public theme                : string  = 'Arctic';
	public helpText             : string  = null ;
	public archiveView          : boolean = false;
	public streamEnabled        : boolean = false;
	public headerError          : any     = null ;
	public localKey             : string  = null ;
	public helpOpen             : boolean = false;

	@Input()  MODULE_NAME       : string ;
	@Input()  MODULE_TITLE      : string ;
	@Input()  SUB_TITLE         : any    ;  // 12/13/2019 Paul.  Sub Title might be a data privacy pill. 
	@Input()  ID                : string ;
	@Input()  LINK_NAME         : string ;
	@Input()  showRequired      : boolean;
	@Input()  enableFavorites   : boolean;
	@Input()  enableHelp        : boolean;
	@Input()  helpName          : string ;
	@Input()  error             : any    ;
	// Button properties
	@Input()  ButtonStyle       : string ;
	@Input()  FrameStyle        : any    ;
	@Input()  ContentStyle      : any    ;
	@Input()  VIEW_NAME         : string ;
	@Input()  row               : any    ;
	@Output() Page_Command      : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();
	// 06/03/2022 Paul.  onLayoutLoaded is not needed becasue we are using the ViewChild setter.  We do this because onLayoutLoaded would otherwise fire too early. 
	//@Output() onLayoutLoaded  : EventEmitter<void> = new EventEmitter<void>();
	// 07/02/2020 Paul.  Provide a way to override the default ButtonLink behavior. 
	@Output() onButtonLink      : EventEmitter<DYNAMIC_BUTTON> = new EventEmitter<DYNAMIC_BUTTON>();
	// 06/03/2022 Paul.  We need a separate flag to determine if observed. 
	@Input()  buttonLinkObserved: boolean;
	@Input()  showButtons       : boolean;
	@Input()  showProcess       : boolean;
	@Input()  hideTitle         : boolean;

	@ViewChild(DynamicButtonsComponent, {static: false}) dynamicButtons    : DynamicButtonsComponent;

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public ModuleUpdate: ModuleUpdateService)
	{
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit');
		// 06/01/2022 Paul.  Best to initialize here as input MODULE_NAME not defined in constructor. 
		this.theme = this.SplendidCache.UserTheme;
		let nACLACCESS_Help: number = this.SplendidCache.GetUserAccess("Help", 'edit');
		let helpText       : string = (nACLACCESS_Help >= 0 && this.Crm_Config.ToBoolean('enable_help_wiki') ? this.L10n.Term('.LNK_HELP_WIKI') : this.L10n.Term('.LNK_HELP') );
		let streamEnabled  : boolean = this.Crm_Modules.StreamEnabled(this.MODULE_NAME);
		let archiveView    : boolean = false;

		if ( window.location.pathname.indexOf('/ArchiveView') >= 0 )
		{
			archiveView = true;
		}
		this.helpText      = helpText     ;
		this.archiveView   = archiveView  ;
		this.streamEnabled = streamEnabled;
		this.headerError   = null         ;
		this.localKey      = ''           ;
		this.helpOpen      = false        ;
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

	public _onClickModule(e: any)
	{
		// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
		e.preventDefault();
		let admin = '';
		let module:MODULE = this.SplendidCache.Module(this.MODULE_NAME, this.constructor.name + '._onClickModule');
		if ( module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		let sModuleUrl = `/Reset${admin}/${this.MODULE_NAME}/List`;
		this.router.navigateByUrl(sModuleUrl);
		return false;
	}

	public _onClickItem(e: any)
	{
		// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
		e.preventDefault();
		let admin = '';
		let module:MODULE = this.SplendidCache.Module(this.MODULE_NAME, this.constructor.name + '._onClickItem');
		if ( module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		let sModuleUrl = `/Reset${admin}/${this.MODULE_NAME}/View/${this.ID}`;
		this.router.navigateByUrl(sModuleUrl);
		return false;
	}

	public async _onClickHelp(e: any)
	{
		e.preventDefault();
		// 06/01/2022 Paul.  TODO.  Add support for Help popup. 
		//await this.helpView.loadData();
		this.helpOpen = true;
		return false;
	}

	public _onHelpClose()
	{
		this.helpOpen = false;
	}

	public async _onChangeFavorites(e: any)
	{
		e.preventDefault();
		try
	{
			if ( Sql.IsEmptyGuid(this.row['FAVORITE_RECORD_ID']) )
			{
				// Include/javascript/Utilities.asmx/AddToFavorites
				await this.ModuleUpdate.AddToFavorites(this.MODULE_NAME, this.ID);
				this.row['FAVORITE_RECORD_ID'] = this.ID;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.localKey    = this.localKey + '*';;
			}
			else
			{
				await this.ModuleUpdate.RemoveFromFavorites(this.MODULE_NAME, this.ID);
				this.row['FAVORITE_RECORD_ID'] = null;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.headerError = null;
				this.localKey    = this.localKey + '*';;
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeFavorites', error);
			this.headerError = error;
			this.localKey    = this.localKey + '*';;
		}
		return false;
	}

	public async _onChangeFollowing(e: any)
	{
		e.preventDefault();
		try
		{
			if ( Sql.IsEmptyGuid(this.row['SUBSCRIPTION_PARENT_ID']) )
			{
				// Include/javascript/Utilities.asmx/AddSubscription
				await this.ModuleUpdate.AddSubscription(this.MODULE_NAME, this.ID);
				this.row['SUBSCRIPTION_PARENT_ID'] = this.ID;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.localKey    = this.localKey + '*';;
			}
			else
			{
				await this.ModuleUpdate.RemoveSubscription(this.MODULE_NAME, this.ID);
				this.row['SUBSCRIPTION_PARENT_ID'] = null;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.headerError = null;
				this.localKey    = this.localKey + '*';;
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeFollowing', error);
			this.headerError = error;
			this.localKey    = this.localKey + '*';;
		}
		return false;
	}

	public Busy(): void
	{
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.Busy();
		}
	}

	public NotBusy(): void
	{
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.NotBusy();
		}
	}

	// 01/08/2020 Paul.  No need for the following to be abstract as they are identical across all derived header classes. 
	public DisableAll(): void
	{
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.DisableAll();
		}
	}

	public EnableAll(): void
	{
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.EnableAll();
		}
	}

	public HideAll(): void
	{
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.HideAll();
		}
	}

	public ShowAll(): void
	{
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.ShowAll();
		}
	}

	public EnableButton(COMMAND_NAME: string, enabled: boolean): void
	{
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.EnableButton(COMMAND_NAME, enabled);
		}
	}

	public ShowButton(COMMAND_NAME: string, visible: boolean): void
	{
		//console.log(this.constructor.name + '.ShowButton ' + COMMAND_NAME, visible);
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.ShowButton(COMMAND_NAME, visible);
		}
	}

	public ShowHyperLink(URL: string, visible: boolean): void
	{
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.ShowHyperLink(URL, visible);
		}
	}

	// 04/05/2021 Paul.  DataPrivacy module needs to set the button class. 
	public SetControlClass(COMMAND_NAME: string, CONTROL_CSSCLASS: string): void
	{
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.SetControlClass(COMMAND_NAME, CONTROL_CSSCLASS);
		}
	}
}
