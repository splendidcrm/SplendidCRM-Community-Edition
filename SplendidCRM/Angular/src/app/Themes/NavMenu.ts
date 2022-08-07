import { Component            } from '@angular/core';
import { SplendidCacheService } from '../scripts/SplendidCache';
import { ApplicationService   } from '../scripts/Application';

@Component({
	selector: 'NavMenu',
	templateUrl: './NavMenu.html',
})
export class NavMenuComponent
{
	public isExpanded: boolean = false;
	public theme     : string  = 'Arctic';

	constructor(private Application: ApplicationService, protected SplendidCache: SplendidCacheService)
	{
		//console.log(this.constructor.name + '.constructor', SplendidCache);
	}

	async ngOnInit() : Promise<void>
	{
		let jsonReactState: any = await this.Application.Init(this.constructor.name + '.constructor');
		this.theme = this.SplendidCache.UserTheme;
		//console.log(this.constructor.name + '.ngOnInit', this.theme, jsonReactState);
	}

	collapse()
	{
		this.isExpanded = false;
	}

	toggle()
	{
		this.isExpanded = !this.isExpanded;
	}
}
