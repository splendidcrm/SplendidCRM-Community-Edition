import { Component, OnInit, Input, Output, EventEmitter            } from '@angular/core'                    ;
import { faXmark                                                   } from '@fortawesome/free-solid-svg-icons';

import { SplendidCacheService                                      } from '../scripts/SplendidCache'         ;
import { L10nService                                               } from '../scripts/L10n'                  ;

@Component({
	selector: 'SearchTabs',
	templateUrl: './SearchTabs.html',
})
export class SearchTabsComponent implements OnInit
{
	public    xmark                           = faXmark;

	@Input()  searchMode            : string  = null;
	@Input()  duplicateSearchEnabled: boolean = false;
	@Output() onTabChange           : EventEmitter<string> = new EventEmitter<string>();

	constructor(public SplendidCache: SplendidCacheService, public L10n: L10nService)
	{
	}

	ngOnInit()
	{
	}

	public _onSearchTabChange = (event: any, key: string) =>
	{
		event.preventDefault();
		this.onTabChange.emit(key);
		return false;
	}

}
