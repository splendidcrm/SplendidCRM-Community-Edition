import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import Sql                                                           from '../scripts/Sql'               ;

import ACL_FIELD_ACCESS                                              from '../types/ACL_FIELD_ACCESS'    ;

import { SplendidGridComponentBase                                 } from '../GridComponents/SplendidGridComponentBase';

@Component({
	selector: 'SplendidGridJavaImage',
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
export class SplendidGridJavaImageComponent extends SplendidGridComponentBase implements OnInit
{
	public bIsReadable: boolean = false;

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules, Formatting);
	}

	ngOnInit()
	{
		const { layout, row, SplendidCache, Security } = this;
		let bIsReadable: boolean = true;
		if ( layout != null )
		{
			let DATA_FIELD  : string = Sql.ToString(layout.DATA_FIELD);
			let MODULE_NAME : string = SplendidCache.GetGridModule(layout);
			if ( SplendidCache.bEnableACLFieldSecurity && !Sql.IsEmptyString(DATA_FIELD) )
			{
				let gASSIGNED_USER_ID: string = null;
				let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(SplendidCache, Security, MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
				bIsReadable  = acl.IsReadable();
			}
		}
		// 06/16/2022 Paul.  bIsReadable is not used. 
		this.bIsReadable = bIsReadable;
	}

}
