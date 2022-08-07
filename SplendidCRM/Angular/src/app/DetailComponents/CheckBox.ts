import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import Sql                                                           from '../scripts/Sql'               ;
import { DetailViewComponentBase                                   } from '../DetailComponents/DetailViewComponentBase';

@Component({
	selector: 'DetailViewCheckBox',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyRow()">
		<span>row is null for DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<span>
			<input [id]="ID" type='checkbox' [class]="CSS_CLASS" [style]="styCheckbox" [disabled]="true" [checked]="DATA_VALUE" />
		</span>
	</ng-container>`
})
export class DetailViewCheckBoxComponent extends DetailViewComponentBase implements OnInit
{
	public styCheckbox: any = null;

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	ngOnInit()
	{
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : boolean = false;
		let styCheckbox      : any     = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '6px' };

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				// 06/18/2011 Paul.  IE requires that the input type be defined prior to appending the field. 
				// 12/24/2012 Paul.  Use regex global replace flag. 
				// 09/25/2011 Paul.  IE does not allow you to set the type after it is added to the document. 
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				if ( row != null )
				{
					DATA_VALUE = Sql.ToBoolean(row[DATA_FIELD]);
				}
			}
			// 05/14/2018 Paul.  Defer style transform. 
			// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			if ( this.Crm_Config.ToBoolean('enable_legacy_icons') )
			{
				styCheckbox.transform    = 'scale(1.0)';
				styCheckbox.marginBottom = '2px';
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit ' + DATA_FIELD, DATA_VALUE, row);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID          = ID         ;
		this.FIELD_INDEX = FIELD_INDEX;
		this.DATA_FIELD  = DATA_FIELD ;
		this.DATA_VALUE  = DATA_VALUE ;
		this.CSS_CLASS   = 'checkbox' ;
		this.styCheckbox = styCheckbox;
	}

	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit');
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}
}
