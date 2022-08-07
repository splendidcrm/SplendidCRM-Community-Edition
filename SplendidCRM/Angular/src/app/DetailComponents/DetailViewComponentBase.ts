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
	selector: 'DetailViewComponentBase',
	template: `DetailView Component Base`,
})
export class DetailViewComponentBase implements OnInit
{
	public ID               : string    = null;
	public FIELD_INDEX      : number    = null;
	public DATA_FIELD       : string    = null;
	public DATA_VALUE       : any       = null;
	public DATA_FORMAT      : string    = null;
	public CSS_CLASS        : string    = null;

	@Input()  baseId        : string   = null;
	@Input()  row           : any      = null;
	@Input()  layout        : any      = null;
	@Input()  ERASED_FIELDS : string[] = null;
	// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
	@Input()  bIsHidden?    : boolean;
	@Output() Page_Command  : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();
	@Output() fieldDidMount : EventEmitter<{DATA_FIELD  : string, component        : any}> = new EventEmitter<{DATA_FIELD  : string, component        : any}>();

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.DATA_VALUE = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.CSS_CLASS = DATA_VALUE;
		}
	}

	public IsEmptyLayout(): boolean
	{
		return this.layout == null;
	}

	public IsEmptyField(): boolean
	{
		return this.layout != null && Sql.IsEmptyString(this.DATA_FIELD);
	}

	public IsEmptyRow(): boolean
	{
		return this.layout != null && !Sql.IsEmptyString(this.DATA_FIELD) && this.row == null;
	}

	public IsHidden(): boolean
	{
		return this.layout != null && !Sql.IsEmptyString(this.DATA_FIELD) && this.row != null && this.layout.hidden;
	}

	public IsVisible(): boolean
	{
		return this.layout != null && !Sql.IsEmptyString(this.DATA_FIELD) && this.row != null && !this.layout.hidden;
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService)
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
