import { Component, OnInit, OnDestroy        } from '@angular/core'                         ;
import { Router                              } from '@angular/router'                       ;
import { faSpinner                           } from '@fortawesome/free-solid-svg-icons'     ;

import { ApplicationService                  } from '../scripts/Application'                ;
import { SplendidCacheService                } from '../scripts/SplendidCache'              ;
import { CredentialsService                  } from '../scripts/Credentials'                ;
import { CrmConfigService                    } from '../scripts/Crm'                        ;
import { StartsWith                          } from '../scripts/utility'                    ;
import Sql                                     from '../scripts/Sql'                        ;

@Component({
	selector: 'ReloadView',
	template: `<div style="text-align: center">
			<fa-icon [icon]="spinner" size='5x' [spin]="true"></fa-icon>
		</div>`,
})
export class ReloadViewComponent implements OnInit
{
	public  spinner     = faSpinner;
	private timerID     : any    = null;
	private sRedirectUrl: string = '';
	private resetCount  : number = 0;

	constructor(private router: Router, private Application: ApplicationService, private SplendidCache: SplendidCacheService, private Credentials: CredentialsService, private Crm_Config: CrmConfigService)
	{
		//console.log(this.constructor.name + '.constructor');
	}

	async ngOnInit(): Promise<void>
	{
		console.log(this.constructor.name + '.componentDidMount', location.pathname + location.search);
		// 06/25/2019 Paul.  Remove the /Reload and continue along the path. 
		if ( location.pathname.indexOf('/Reload') >= 0 )
		{
			// 10/11/2019 Paul.  Include the query parameters.
			this.sRedirectUrl = location.pathname.split('/Reload')[1] + location.search;
			// 07/30/2022 Paul.  Base may be included in pathname, so we need to remove. 
			let sBaseUrl: string = this.Credentials.sBASE_URL;
			if ( StartsWith(this.sRedirectUrl, sBaseUrl) && sBaseUrl.length > 1 )
			{
				this.sRedirectUrl = this.sRedirectUrl.substr(sBaseUrl.length - 1);
			}
			console.log(this.constructor.name + '.componentDidMount sRedirectUrl', this.sRedirectUrl);
			if ( this.Credentials.bMOBILE_CLIENT )
			{
				if ( StartsWith(this.sRedirectUrl, '/android_asset/www') )
				{
					this.sRedirectUrl = this.sRedirectUrl.substring(18);
				}
				if ( this.sRedirectUrl == '/index.html' )
				{
					this.sRedirectUrl = '';
				}
			}
		}
		if ( this.sRedirectUrl == '' )
		{
			this.sRedirectUrl = '/Home';
		}
		if ( this.SplendidCache.IsInitialized )
		{
			this.router.navigateByUrl(this.sRedirectUrl);
		}
		else
		{
			//console.log(this.constructor.name + '.componentDidMount Start', location.pathname);
			//console.log(this.constructor.name + '.componentDidMount sRedirectUrl', this.sRedirectUrl);
			let status = await this.Application.Init('ReloadView ' + this.sRedirectUrl);
			//SplendidCache.VerifyReactState();
			if ( status )
			{
				//console.log(this.constructor.name + '.componentDidMount Done', this.sRedirectUrl);
				//let status = await IsAuthenticated('ReloadView.componentDidMount');
				//console.log(this.constructor.name + '.componentDidMount IsAuthenticated', status);
				// 06/28/2019 Paul.  Still having an issue whereby terminology is not fully loaded before we redirect.  Try to bounce through reset. 
				// 08/05/2019 Paul.  Try and replace the /Reset so that the back button will work properly. 
				// 11/03/2021 Paul.  It is not worth the effort to try to run the Admin Wizard, so keep that code in ASP.Net code. 
				//if ( Security.IS_ADMIN() && Sql.IsEmptyString(Crm_Config.ToString("Configurator.LastRun")) )
				//{
				//	this.router.navigateByUrl('/Administration/Configurator');
				//}
				//else
				// 11/03/2021 Paul.  Do run the User Wizard if a new user. 
				if ( Sql.IsEmptyString(this.Credentials.sORIGINAL_TIMEZONE_ID) && !this.Crm_Config.ToBoolean("disableUserWizard") )
				{
					this.router.navigateByUrl('/Users/Wizard');
				}
				else
				{
					this.router.navigateByUrl('/Reset' + this.sRedirectUrl);
				}
			}
			else
			{
				//console.log(this.constructor.name + '.componentDidMount Init returned not ready, auto-reset in 5 seconds');
				// 01/21/2020 Paul.  Give it 5 more seconds. 
				// 10/31/2021 Paul.  Reduce to 1 second, but repeat 5 times. 
				this.resetCount = 0;
				// 05/30/2022 Paul.  Must wrap timmer call to ensure proper this within. 
				this.timerID = setInterval(() =>
				{
					this.ResetTimer();
				}, 1000);
			}
		}
	}

	ngOnDestroy()
	{
		if ( this.timerID != null )
		{
			clearInterval(this.timerID);
			this.timerID = null;
		}
	}

	private ResetTimer()
	{
		try
		{
			this.resetCount++;
			// 10/31/2021 Paul.  Reduce to 1 second, but repeat 5 times. 
			//console.log(this.constructor.name + '.ReseTimer', this.resetCount, this.SplendidCache.IsInitialized);
			if ( this.resetCount >= 5 || this.SplendidCache.IsInitialized )
			{
				clearInterval(this.timerID);
				this.timerID = null;
				//console.log(this.constructor.name + '.ReseTimer sORIGINAL_TIMEZONE_ID', Credentials.sORIGINAL_TIMEZONE_ID);
				// 11/03/2021 Paul.  It is not worth the effort to try to run the Admin Wizard, so keep that code in ASP.Net code. 
				//if ( SplendidCache.IsInitialized && Security.IS_ADMIN() && Sql.IsEmptyString(Crm_Config.ToString("Configurator.LastRun")) )
				//{
				//	this.router.navigateByUrl('/Administration/Configurator');
				//}
				//else
				// 11/03/2021 Paul.  Do run the User Wizard if a new user. 
				if ( this.SplendidCache.IsInitialized && Sql.IsEmptyString(this.Credentials.sORIGINAL_TIMEZONE_ID) && !this.Crm_Config.ToBoolean("disableUserWizard") )
				{
					this.router.navigateByUrl('/Users/Wizard');
				}
				else
				{
					this.router.navigateByUrl('/Reset' + this.sRedirectUrl);
				}
			}
		}
		catch(error: any)
		{
			console.error(this.constructor.name + '.ResetTimer', error);
		}
	}

}

