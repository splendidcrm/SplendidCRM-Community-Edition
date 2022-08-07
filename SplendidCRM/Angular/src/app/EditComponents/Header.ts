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
	selector: 'EditViewHeader',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyLabel()">
		<span>DATA_FIELD is empty for Header FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<h4 [id]="ID" [class]="CSS_CLASS">{{ DATA_VALUE }}</h4>
	</ng-container>`
})
export class EditViewHeaderComponent extends EditViewComponentBase implements OnInit
{
	public DATA_LABEL             : string   = null;

	public IsEmptyLabel(): boolean
	{
		return this.layout != null && Sql.IsEmptyString(this.DATA_LABEL);
	}

	public IsVisible(): boolean
	{
		return !this.IsEmptyLabel() && !this.layout.hidden;
	}

	public get data(): any
	{
		return null;
	}

	public validate(): boolean
	{
		return true;
	}

	public clear(): void
	{
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n : C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	ngOnInit()
	{
		const { SplendidCache, Credentials, Security, L10n, Crm_Config } = this;
		let FIELD_INDEX      : number = 0;
		let DATA_LABEL       : string = '';
		let DATA_VALUE       : string = '';

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_LABEL        = Sql.ToString (layout.DATA_LABEL );
				ID = baseId + '_' + layout.FIELD_TYPE + '_' + layout.FIELD_INDEX;

				if ( DATA_LABEL.indexOf('.') >= 0 )
				{
					DATA_VALUE = L10n.Term(DATA_LABEL);
				}
				else if ( !Sql.IsEmptyString(DATA_LABEL) )
				{
					// 06/21/2015 Paul.  Label can contain raw text. 
					DATA_VALUE = DATA_LABEL;
				}
				// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
				DATA_VALUE = Sql.ReplaceEntities(DATA_VALUE);
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', DATA_VALUE);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID                      = ID                     ;
		this.FIELD_INDEX             = FIELD_INDEX            ;
		this.DATA_LABEL              = DATA_LABEL             ;
		this.DATA_VALUE              = DATA_VALUE             ;
	}

	ngDoCheck() : void
	{
	}

	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}

}
