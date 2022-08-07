import { Component, OnInit, OnDestroy        } from '@angular/core'                         ;
import { Router                              } from '@angular/router'                       ;
import { faSpinner                           } from '@fortawesome/free-solid-svg-icons'     ;

import { ApplicationService                  } from '../scripts/Application'        ;
import { SplendidCacheService                } from '../scripts/SplendidCache'     ;
import { CredentialsService                  } from '../scripts/Credentials'        ;
import { CrmConfigService                    } from '../scripts/Crm'                ;
import { StartsWith                          } from '../scripts/utility'                    ;
import Sql                                     from '../scripts/Sql'                        ;

@Component({
	selector: 'ResetView',
	template: `<div>{{ url }}</div>`,
})
export class ResetViewComponent implements OnInit
{
	public url: string = null;

	constructor(private router: Router, private Credentials: CredentialsService)
	{
		this.url = window.location.pathname + window.location.search;
	}

	ngOnInit() : void
	{
		console.log(this.constructor.name + '.componentDidMount', location.pathname + location.search);
		let sRedirectUrl: string = '';
		// 06/25/2019 Paul.  Remove the /Reset and continue along the path. 
		if ( location.pathname.indexOf('/Reset') >= 0 )
		{
			// 10/11/2019 Paul.  Include the query parameters. 
			sRedirectUrl = location.pathname.split('/Reset')[1] + location.search;
			console.log(this.constructor.name + '.componentDidMount sRedirectUrl', sRedirectUrl);
			if ( this.Credentials.bMOBILE_CLIENT )
			{
				if ( StartsWith(sRedirectUrl, '/android_asset/www') )
				{
					sRedirectUrl = sRedirectUrl.substring(18);
				}
				if ( sRedirectUrl == '/index.html' )
				{
					sRedirectUrl = '';
				}
			}
		}
		if ( sRedirectUrl == '' )
		{
			sRedirectUrl = '/Home';
		}
		// 06/17/2022 Paul.  Try and replace the /Reset so that the back button will work properly. 
		this.router.navigateByUrl(sRedirectUrl, {replaceUrl: true});
	}

}
