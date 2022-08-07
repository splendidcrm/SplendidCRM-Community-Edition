import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;

import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { C10nService                                               } from '../scripts/C10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import Sql                                                           from '../scripts/Sql'               ;
import { EditViewComponentBase                                     } from '../EditComponents/EditViewComponentBase';

@Component({
	selector: 'EditViewCheckBox',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for CheckBox FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyChanged()">
		<span>onChanged is null for CheckBox DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<span>
			<input
				[id]="ID"
				[checked]="DATA_VALUE"
				[tabIndex]="FORMAT_TAB_INDEX"
				type='checkbox'
				[class]="CSS_CLASS"
				[ngStyle]="styCheckbox"
				[disabled]="!ENABLED"
				(change)="_onChange($event)"
			/>
		</span>
	</ng-container>`
})
export class EditViewCheckBoxComponent extends EditViewComponentBase implements OnInit
{
	public styCheckbox            : any     = null;

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n : C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	ngOnInit()
	{
		const { SplendidCache, Credentials, Security, L10n, Crm_Config } = this;
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : boolean = false;
		let FORMAT_TAB_INDEX : number  = null;
		let ENABLED          : boolean = this.bIsWriteable;

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX     );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD      );
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX);
				ID = baseId + '_' + DATA_FIELD;

				if ( row != null )
				{
					this.DATA_VALUE = this.getValue(layout, row, DATA_FIELD);
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID                      = ID                     ;
		this.FIELD_INDEX             = FIELD_INDEX            ;
		this.DATA_FIELD              = DATA_FIELD             ;
		this.DATA_VALUE              = DATA_VALUE             ;
		this.FORMAT_TAB_INDEX        = FORMAT_TAB_INDEX       ;
		this.ENABLED                 = ENABLED                ;
		this.CSS_CLASS               = 'checkbox'             ;
	}

	ngDoCheck() : void
	{
		this.styCheckbox = { transform: 'scale(1.5)', display: 'inline', marginTop: '4px', marginBottom: '6px' };
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		if ( this.Crm_Config.ToBoolean('enable_legacy_icons') )
		{
			this.styCheckbox.transform = 'scale(1.0)';
			this.styCheckbox.marginBottom = '2px';
		}
	}

	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}

	private getValue(layout: any, row: any, DATA_FIELD: string): boolean
	{
		let DATA_VALUE: boolean = false;
		if ( layout != null && row != null )
		{
			if ( row[DATA_FIELD] != null )
			{
				DATA_VALUE = Sql.ToBoolean(row[DATA_FIELD]);
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue ' + DATA_FIELD, DATA_VALUE, row);
		return DATA_VALUE;
	}

	public _onChange(event: any)
	{
		const { DATA_FIELD, ENABLED } = this;
		let DATA_VALUE: boolean = event.target.checked;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.DATA_VALUE = DATA_VALUE;
				this.validate();
				this.onChanged.emit({DATA_FIELD  : DATA_FIELD, DATA_VALUE});
				this.onUpdate .emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

}
