import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import { escapeHTML                                                } from '../scripts/utility'           ;
import Sql                                                           from '../scripts/Sql'               ;

import { SplendidGridComponentBase                                 } from '../GridComponents/SplendidGridComponentBase';

@Component({
	selector: 'SplendidGridTags',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for FIELD_INDEX {{ layout.FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<div>
			<ng-container *ngFor="let tag of DATA_VALUE">
				<div class="Tags">{{ tag }}</div>
			</ng-container>
		</div>
	</ng-container>`
})
export class SplendidGridTagsComponent extends SplendidGridComponentBase implements OnInit
{
	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules, Formatting);
	}

	ngOnInit()
	{
		const { layout, row } = this;
		let DATA_FIELD : string = Sql.ToString(layout.DATA_FIELD );
		let DATA_VALUE : string[] = [];
		if ( row )
		{
			DATA_VALUE = [];
			let sDATA = row[DATA_FIELD];
			if ( !Sql.IsEmptyString(sDATA) )
			{
				let arrTAGS = sDATA.split(',');
				for ( let iTag = 0; iTag < arrTAGS.length; iTag++ )
				{
					let spnTag: string = escapeHTML(arrTAGS[iTag]);
					DATA_VALUE.push(spnTag);
				}
			}
		}
		this.DATA_FIELD = DATA_FIELD;
		this.DATA_VALUE = DATA_VALUE;
	}

}
