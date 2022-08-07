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

import { SplendidGridComponentBase                                 } from '../GridComponents/SplendidGridComponentBase';

@Component({
	selector: 'SplendidGridCurrency',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for FIELD_INDEX {{ layout.FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<div>{{ DATA_VALUE }}</div>
	</ng-container>`
})
export class SplendidGridCurrencyComponent extends SplendidGridComponentBase implements OnInit
{
	@Input()  numberFormat  : any      = null;

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n: C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules, Formatting);
	}

	ngOnInit()
	{
		const { layout, row, numberFormat, C10n, Formatting } = this;
		let DATA_FIELD : string = Sql.ToString(layout.DATA_FIELD );
		let DATA_VALUE : string = '';
		if ( row )
		{
			// 10/16/2021 Paul.  Add support for user currency. 
			let dConvertedValue = C10n.ToCurrency(Sql.ToDecimal(row[DATA_FIELD]));
			DATA_VALUE = Formatting.formatCurrency(dConvertedValue, numberFormat);
		}
		this.DATA_FIELD = DATA_FIELD;
		this.DATA_VALUE = DATA_VALUE;
	}

}
