import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'   ;

import { ApplicationService                  } from '../../scripts/Application'             ;
import { SplendidCacheService                } from '../../scripts/SplendidCache'           ;
import { CredentialsService                  } from '../../scripts/Credentials'             ;
import { ActiveModuleFromPath                } from '../../scripts/utility'                 ;

import { MassUpdateComponent                 } from '../../views/mass-update/MassUpdate'    ;

@Component({
	selector: 'DynamicMassUpdate',
	templateUrl: './DynamicMassUpdate.html',
})
export class DynamicMassUpdateComponent implements OnInit
{
	public    bIsInitialized        : boolean  = null;
	public    bIsAuthenticated      : boolean  = null;
	public    customView            : any      = null;
	public    error                 : any      = null;

	@Input()  MODULE_NAME           : string  = null;
	@Input()  archiveView           : boolean = null;
	@Output() onUpdateComplete      : EventEmitter<string> = new EventEmitter<string>();

	@ViewChild(MassUpdateComponent, {static: false}) updatePanel : MassUpdateComponent;

	constructor(public Application: ApplicationService, protected SplendidCache: SplendidCacheService, protected Credentials: CredentialsService)
	{
		this.bIsInitialized     = SplendidCache.IsInitialized ;
		this.bIsAuthenticated   = Credentials.bIsAuthenticated;
	}

	async ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit');
		try
		{
			let status = await this.Application.AuthenticatedMethod(null, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				// 04/19/2020 Paul.  We cannot call DynamicLayout_Module from within another DynamicLayout_Module. 
				//this.customView = await DynamicLayout_Module(MODULE_NAME, 'EditViews', 'MassUpdate');
			}
			else
			{
				this.Application.LoginRedirect(null, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.error = error;
		}
	}

	ngDoCheck(): void
	{
		const { SplendidCache, Credentials } = this;
		//console.log(this.constructor.name + '.ngDoCheck');
		let bChanged: boolean = false;
		if ( this.bIsInitialized != this.SplendidCache.IsInitialized )
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
			this.bIsInitialized     = SplendidCache.IsInitialized ;
			this.bIsAuthenticated   = Credentials.bIsAuthenticated;
		}
	}

	public SelectionChanged(value: any)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged: ' + MODULE_NAME, value);
		if ( this.updatePanel != null )
		{
			this.updatePanel.SelectionChanged(value);
		}
	}

	public Page_Command = async (sCommandName: string, sCommandArguments: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command: ' + sCommandName, sCommandArguments);
		if ( this.updatePanel != null )
		{
			this.updatePanel.Page_Command({sCommandName, sCommandArguments});
		}
	}

	public _onUpdateComplete = (sCommandName: string) =>
	{
		this.onUpdateComplete.emit(sCommandName);
	}
}
