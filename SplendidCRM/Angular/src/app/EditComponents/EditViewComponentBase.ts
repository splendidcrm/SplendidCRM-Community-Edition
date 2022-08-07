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
export class EditViewComponentBase implements OnInit
{
	public    ID                     : string   = null;
	public    FIELD_INDEX            : number   = null;
	public    DATA_FIELD             : string   = null;
	public    DATA_VALUE             : any      = null;
	public    FORMAT_TAB_INDEX       : number   = null;
	public    CSS_CLASS              : string   = null;
	public    ENABLED                : boolean  = true;
	public    UI_REQUIRED            : boolean  = null;
	public    VALIDATOR_FAILED       : boolean  = null;
	public    VALUE_MISSING          : boolean  = null;
	public    VALIDATION_TYPE        : string   = null;
	public    REGULAR_EXPRESSION     : string   = null;
	public    FIELD_VALIDATOR_MESSAGE: string   = null;

	@Input()  template               : any      = null;
	@Input()  baseId                 : string   = null;
	@Input()  row                    : any      = null;
	@Input()  layout                 : any      = null;
	@Input()  ERASED_FIELDS          : string[] = null;
	@Input()  bIsWriteable           : boolean  = true;
	// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
	@Input()  bIsHidden?             : boolean  = false;
	// 09/27/2020 Paul.  We need to be able to disable the default grow on TextBox. 
	@Input()  bDisableFlexGrow       : boolean  = false;
	@Output() onChanged              : EventEmitter<{DATA_FIELD  : string, DATA_VALUE: any, DISPLAY_FIELD?          : string, DISPLAY_VALUE?: any}> = new EventEmitter<{DATA_FIELD  : string, DATA_VALUE       : any   , DISPLAY_FIELD?: string, DISPLAY_VALUE?: any}>();
	@Output() onSubmit               : EventEmitter<void                                                                                          > = new EventEmitter<void                                                                                          >();
	@Output() onUpdate               : EventEmitter<{PARENT_FIELD: string, DATA_VALUE       : any   , item?         : any   }                     > = new EventEmitter<{PARENT_FIELD: string, DATA_VALUE       : any   , item?         : any   }                     >();
	// 06/09/2022 Paul.  createDependency is only used by ListBox, so we probably should remove from all others. 
	@Output() createDependency       : EventEmitter<{DATA_FIELD  : string, PARENT_FIELD     : string, PROPERTY_NAME?: string}                     > = new EventEmitter<{DATA_FIELD  : string, PARENT_FIELD     : string, PROPERTY_NAME?: string}                    >();
	@Output() Page_Command           : EventEmitter<{sCommandName: string, sCommandArguments: any}                                                > = new EventEmitter<{sCommandName: string, sCommandArguments: any}                                               >();
	@Output() fieldDidMount          : EventEmitter<{DATA_FIELD  : string, component        : any}                                                > = new EventEmitter<{DATA_FIELD  : string, component        : any}                                                >();

	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE } = this;
		// 06/30/2019 Paul.  Return null instead of empty string. 
		let key   = DATA_FIELD;
		let value = DATA_VALUE;
		if ( Sql.IsEmptyString(value) )
		{
			value = null;
		}
		return { key, value };
	}

	public HasValidatorFailed = (DATA_VALUE: string): boolean =>
	{
		const { ENABLED, VALIDATION_TYPE, REGULAR_EXPRESSION, FIELD_VALIDATOR_MESSAGE } = this;
		let VALIDATOR_FAILED: boolean = false;
		if ( !Sql.IsEmptyString(DATA_VALUE) && VALIDATION_TYPE == 'RegularExpressionValidator' && !Sql.IsEmptyString(REGULAR_EXPRESSION) && !Sql.IsEmptyString(FIELD_VALIDATOR_MESSAGE) && ENABLED )
		{
			let regex = new RegExp(REGULAR_EXPRESSION);
			if ( !regex.test(DATA_VALUE) )
			{
				VALIDATOR_FAILED = true;
			}
		}
		return VALIDATOR_FAILED;
	}

	public validate(): boolean
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, VALUE_MISSING, ENABLED } = this;
		let bVALUE_MISSING: boolean = false;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.bIsHidden )
		{
			bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE);
			if ( bVALUE_MISSING != VALUE_MISSING )
			{
				this.VALUE_MISSING = bVALUE_MISSING;
			}
			if ( bVALUE_MISSING && UI_REQUIRED )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.validate ' + DATA_FIELD);
			}
		}
		// 10/05/2021 Paul.  Add support for regular expression validation. 
		if ( this.HasValidatorFailed(DATA_VALUE) )
		{
			bVALUE_MISSING = true;
			this.VALUE_MISSING    = bVALUE_MISSING;
			this.VALIDATOR_FAILED = true;
		}
		return !bVALUE_MISSING;
	}

	public clear(): void
	{
		const { ENABLED } = this;
		// 01/11/2020.  Apply Field Level Security. 
		if ( ENABLED )
		{
			// 02/02/2020 Paul.  input does not update when DATA_VALUE is set to null. 
			this.DATA_VALUE       = ''   ;
			this.VALIDATOR_FAILED = false;
		}
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		// 08/09/2019 Paul.  An example of a text update is a Postal Code change updating, City, State and Country. 
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.DATA_VALUE = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'enabled' )
		{
			this.ENABLED = Sql.ToBoolean(DATA_VALUE);
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

	public IsEmptyChanged(): boolean
	{
		return !this.onChanged.observed;
	}

	public IsHidden(): boolean
	{
		return !this.IsEmptyField() && this.layout.hidden;
	}

	public IsVisible(): boolean
	{
		return !this.IsEmptyField() && !this.layout.hidden;
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
