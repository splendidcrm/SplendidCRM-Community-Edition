import { Component, OnInit, Input, Output, ViewChild, EventEmitter } from '@angular/core'                         ;
import { faArrowRight                                              } from '@fortawesome/free-solid-svg-icons'     ;

import { SplendidCacheService                                      } from '../scripts/SplendidCache'              ;
import { CredentialsService                                        } from '../scripts/Credentials'                ;
import { L10nService                                               } from '../scripts/L10n'                       ;

@Component({
	selector: 'ListHeader',
	template: `<table class='h3Row' cellSpacing="1" cellPadding="0" style="width: 100%; border: none; margin-bottom: 2px">
	<tr>
		<td style="white-space: nowrap">
			<h3>
				<fa-icon [icon]='arrowRight' size='lg' style="margin-right: .5em" transform="rotate: 45"></fa-icon>
				&nbsp;<span>{{ sMODULE_TITLE }}</span>
			</h3>
		</td>
	</tr>
</table>`,
})
export class ListHeaderComponent implements OnInit
{
	public    arrowRight            = faArrowRight;
	public    sMODULE_TITLE         : string;
	public    themeURL              : string;

	@Input()  MODULE_NAME           : string  = null;
	@Input()  TITLE                 : string  = null;

	constructor(public SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, public L10n: L10nService)
	{
	}

	ngOnInit()
	{
		const { TITLE, MODULE_NAME, SplendidCache, Credentials, L10n } = this;
		this.sMODULE_TITLE = L10n.Term(TITLE ? TITLE : MODULE_NAME + '.LBL_LIST_FORM_TITLE');
		// 10/29/2020 Paul.  Add the header arrow. 
		this.themeURL      = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
	}

}
