import { Component, OnInit, Input, Output, EventEmitter            } from '@angular/core';
import { Router, ActivatedRoute, ParamMap                          } from '@angular/router'                       ;
import { faSpinner                                                 } from '@fortawesome/free-solid-svg-icons'     ;
import { ApplicationService                                        } from '../../scripts/Application'             ;
import { SplendidCacheService                                      } from '../../scripts/SplendidCache'           ;
import { CredentialsService                                        } from '../../scripts/Credentials'             ;
import { SecurityService                                           } from '../../scripts/Security'                ;
import Sql                                                           from '../../scripts/Sql'                     ;

@Component({
  selector: 'HomeView',
  templateUrl: './HomeView.html',
})
export class HomeViewComponent implements OnInit
{
	private   lastPathname          : string ;
	private   bIsInitialized        : boolean;
	private   bIsAuthenticated      : boolean;
	public    spinner               = faSpinner;

	public    error                 : any     = null;

	public IsReady()
	{
		return this.bIsInitialized;
	}

	public IsNotReady()
	{
		return !this.IsReady();
	}

	public IsError()
	{
		return !Sql.IsEmptyString(this.error);
	}

	constructor(private router: Router, private route: ActivatedRoute, public Application: ApplicationService, public SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, public Security: SecurityService)
	{
		this.lastPathname       = window.location.pathname         ;
		this.bIsInitialized     = this.SplendidCache.IsInitialized ;
		this.bIsAuthenticated   = this.Credentials.bIsAuthenticated;
	}

	ngOnInit()
	{
		this.Reset('ngOnInit');
	}

	ngDoCheck(): void
	{
		//console.log(this.constructor.name + '.ngDoCheck');
		let bChanged: boolean = false;
		if ( this.lastPathname != window.location.pathname )
		{
			console.log(this.constructor.name + '.ngDoCheck pathname changed');
			bChanged = true;
		}
		else if ( this.bIsInitialized != this.SplendidCache.IsInitialized )
		{
			//console.log(this.constructor.name + '.ngDoCheck IsInitialized changed');
			bChanged = true;
		}
		else if ( this.bIsAuthenticated != this.Credentials.bIsAuthenticated )
		{
			console.log(this.constructor.name + '.ngDoCheck bIsAuthenticated changed');
			bChanged = true;
		}
		if ( bChanged )
		{
			this.Reset('ngDoCheck');
		}
	}

	private async Reset(source: string)
	{
		const { Application, SplendidCache, Credentials } = this;
		this.lastPathname       = window.location.pathname         ;
		this.bIsInitialized     = this.SplendidCache.IsInitialized ;
		this.bIsAuthenticated   = this.Credentials.bIsAuthenticated;
	}
}
