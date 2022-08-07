import { Component, OnInit, Input            } from '@angular/core'                         ;
import { SplendidCacheService                } from '../../scripts/SplendidCache'           ;
import { CredentialsService                  } from '../../scripts/Credentials'             ;
import { ActiveModuleFromPath                } from '../../scripts/utility'                 ;

@Component({
	selector: 'PreviewDashboard',
	templateUrl: './PreviewDashboard.html',
})
export class PreviewDashboardComponent implements OnInit
{
	@Input()  MODULE_NAME: string = null;
	@Input()  ID         : string = null;

	constructor(protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService)
	{
	}

	ngOnInit()
	{
	}

	ngDoCheck(): void
	{
		//console.log(this.constructor.name + '.ngDoCheck');
	}
}
