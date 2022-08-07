import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;

import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { C10nService                                               } from '../scripts/C10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import { EditViewComponentBase                                     } from '../EditComponents/EditViewComponentBase';

@Component({
	selector: 'EditViewSpan',
	template: `<span [class]="CSS_CLASS">
	<ng-container *ngFor="let item of DATA_VALUE">{{ item }}</ng-container>
</span>`
})
export class EditViewspanComponent extends EditViewComponentBase implements OnInit
{
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
		const { template } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', this.template);
		if ( template && template.props )
		{
			this.CSS_CLASS  = template.props['class'];
			this.DATA_VALUE = template.children;
		}
	}

	ngDoCheck() : void
	{
	}

}
