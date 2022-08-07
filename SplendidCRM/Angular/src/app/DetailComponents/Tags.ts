import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { XMLParser }                                                 from 'fast-xml-parser'              ;

import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { C10nService                                               } from '../scripts/C10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import Sql                                                           from '../scripts/Sql'               ;
import { StartsWith, EndsWith                                      } from '../scripts/utility'           ;
import { NormalizeDescription                                      } from '../scripts/EmailUtils'        ;
import { DetailViewComponentBase                                   } from '../DetailComponents/DetailViewComponentBase';

@Component({
	selector: 'DetailViewTags',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for Tags FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyRow()">
		<span>row is null for Tags DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<span [id]="ID">
			<ng-container *ngFor="let item of arrTAGS; let i = index">
				<span [id]="ID + '_' + i.toString()" [class]="CSS_CLASS">{{ item }}</span>
			</ng-container>
		</span>
	</ng-container>`
})
export class DetailViewTagsComponent extends DetailViewComponentBase implements OnInit
{
	public arrTAGS: string[] = [];

	public IsVisible()
	{
		return super.IsVisible() && !Sql.IsEmptyString(this.DATA_VALUE);
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n : C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	ngOnInit()
	{
		const { SplendidCache, Credentials, Security, L10n, Crm_Config } = this;
		let FIELD_INDEX      : number = 0;
		let DATA_FIELD       : string = '';
		let DATA_VALUE       : string = '';


		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				if ( row != null )
				{
					DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID          = ID         ;
		this.FIELD_INDEX = FIELD_INDEX;
		this.DATA_FIELD  = DATA_FIELD ;
		this.DATA_VALUE  = DATA_VALUE ;
		this.CSS_CLASS   = 'Tags'     ;
		if ( !Sql.IsEmptyString(this.DATA_VALUE) )
		{
			this.arrTAGS     = DATA_VALUE.split(',');
		}
	}

	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}
}
