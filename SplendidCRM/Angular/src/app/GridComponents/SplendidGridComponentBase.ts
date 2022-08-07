import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import Sql                                                           from '../scripts/Sql'               ;

@Component({
	selector: 'SplendidGridComponentBase',
	template: `SplendidGrid Component Base`,
})
export class SplendidGridComponentBase implements OnInit
{
	public DATA_FIELD                 : string   = null;
	public DATA_VALUE                 : any      = null;

	@Input()  baseId                  : string   = null;
	@Input()  row                     : any      = null;
	@Input()  layout                  : any      = null;
	@Input()  multiLine               : boolean  = null;
	@Input()  dateOnly                : boolean  = null;

	@Input()  hasHyperLinkCallback    : boolean = false;
	@Output() hyperLinkCallback       : EventEmitter<{MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}> = new EventEmitter<{MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}>();
	@Output() Page_Command            : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();

	public IsEmptyLayout(): boolean
	{
		return this.layout == null;
	}

	public IsEmptyField(): boolean
	{
		return this.layout != null && Sql.IsEmptyString(this.DATA_FIELD);
	}

	public IsVisible(): boolean
	{
		return this.layout != null && !Sql.IsEmptyString(this.DATA_FIELD);
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
	}

	ngOnInit()
	{
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
}
