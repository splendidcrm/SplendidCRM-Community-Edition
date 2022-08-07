import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import Sql                                                           from '../scripts/Sql'               ;

import { SplendidGridComponentBase                                 } from '../GridComponents/SplendidGridComponentBase';

@Component({
	selector: 'SplendidGridTextBox',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for FIELD_INDEX {{ layout.FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<div [id]="baseId + '_' + DATA_FIELD">{{ DATA_VALUE }}</div>
	</ng-container>`
})
export class SplendidGridTextBoxComponent extends SplendidGridComponentBase implements OnInit
{
	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules, Formatting);
	}

	ngOnInit()
	{
		const { layout, row } = this;
		let DATA_FIELD : string = Sql.ToString(layout.DATA_FIELD );
		let DATA_VALUE : string = '';
		if ( row )
		{
			DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
		}
		this.DATA_FIELD = DATA_FIELD;
		this.DATA_VALUE = DATA_VALUE;
	}

}
