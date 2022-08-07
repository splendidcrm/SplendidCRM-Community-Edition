import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'           ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache';
import { ArcticHeaderButtons                                       } from './Arctic/HeaderButtons'  ;
import { PacificHeaderButtons                                      } from './Pacific/HeaderButtons' ;
import DYNAMIC_BUTTON                                                from '../types/DYNAMIC_BUTTON';

@Component({
	selector: 'HeaderButtonsFactory',
	templateUrl: './HeaderButtonsFactory.html',
})
export class HeaderButtonsFactoryComponent implements OnInit
{
	public theme                : string  = 'Arctic';

	@Input()  MODULE_NAME     : string;
	@Input()  MODULE_TITLE?   : string;
	@Input()  SUB_TITLE?      : any;  // 12/13/2019 Paul.  Sub Title might be a data privacy pill. 
	@Input()  ID?             : string;
	@Input()  LINK_NAME?      : string;
	@Input()  showRequired?   : boolean;
	@Input()  enableFavorites?: boolean;
	@Input()  enableHelp?     : boolean;
	@Input()  helpName?       : string;
	@Input()  error           : any;
	// Button properties
	@Input()  ButtonStyle     : string;
	@Input()  FrameStyle?     : any;
	@Input()  ContentStyle?   : any;
	@Input()  VIEW_NAME       : string;
	@Input()  row             : object;
	@Output() Page_Command    : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();
	// 06/03/2022 Paul.  onLayoutLoaded is not needed becasue we are using the ViewChild setter.  We do this because onLayoutLoaded would otherwise fire too early. 
	//@Output() onLayoutLoaded  : EventEmitter<void> = new EventEmitter<void>();
	// 07/02/2020 Paul.  Provide a way to override the default ButtonLink behavior. 
	@Output() onButtonLink?   : EventEmitter<DYNAMIC_BUTTON> = new EventEmitter<DYNAMIC_BUTTON>();
	@Input()  showButtons     : boolean;
	@Input()  showProcess?    : boolean;
	@Input()  hideTitle?      : boolean;

	@ViewChild(ArcticHeaderButtons , {static: false}) arcticButtons : ArcticHeaderButtons ;
	@ViewChild(PacificHeaderButtons, {static: false}) pacificButtons: PacificHeaderButtons;

	constructor(protected SplendidCache: SplendidCacheService)
	{
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit');
		this.theme = this.SplendidCache.UserTheme;
	}

	// Called once after the first ngDoCheck().
	ngAfterContentInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterContentInit');
	}

	// Called after ngAfterContentInit() and every subsequent ngDoCheck().
	ngAfterContentChecked(): void
	{
		//console.log(this.constructor.name + '.ngAfterContentChecked');
	}

	// Called once after the first ngAfterContentChecked().
	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit');
	}

	// Called after the ngAfterViewInit() and every subsequent ngAfterContentChecked().
	ngAfterViewChecked(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewChecked');
	}

	// Called immediately before Angular destroys the directive or component.
	ngOnDestroy(): void
	{
		//console.log(this.constructor.name + '.ngOnDestroy');
	}

	public _onPage_Command(obj: {sCommandName: string, sCommandArguments: any})
	{
		console.log(this.constructor.name + '._onPage_Command ' + this.Page_Command.observed.toString(), obj);
		if ( this.Page_Command.observed )
		{
			this.Page_Command.emit(obj);
		}
	}

	// 06/03/2022 Paul.  onLayoutLoaded is not needed becasue we are using the ViewChild setter.  We do this because onLayoutLoaded would otherwise fire too early. 
	//public _onLayoutLoaded()
	//{
	//	console.log(this.constructor.name + '._onLayoutLoaded');
	//	if ( this.onLayoutLoaded.observed )
	//	{
	//		this.onLayoutLoaded.emit();
	//	}
	//}

	public _onButtonLink(obj: DYNAMIC_BUTTON)
	{
		console.log(this.constructor.name + '._onButtonLink', obj);
		if ( this.onButtonLink.observed )
		{
			this.onButtonLink.emit(obj);
		}
	}

	public Busy(): void
	{
		if ( this.arcticButtons != null )
		{
			this.arcticButtons.Busy();
		}
		if ( this.pacificButtons != null )
		{
			this.pacificButtons.Busy();
		}
	}

	public NotBusy(): void
	{
		if ( this.arcticButtons != null )
		{
			this.arcticButtons.NotBusy();
		}
		if ( this.pacificButtons != null )
		{
			this.pacificButtons.NotBusy();
		}
	}

	// 01/08/2020 Paul.  No need for the following to be abstract as they are identical across all derived header classes. 
	public DisableAll(): void
	{
		if ( this.arcticButtons != null )
		{
			this.arcticButtons.DisableAll();
		}
		if ( this.pacificButtons != null )
		{
			this.pacificButtons.DisableAll();
		}
	}

	public EnableAll(): void
	{
		if ( this.arcticButtons != null )
		{
			this.arcticButtons.EnableAll();
		}
		if ( this.pacificButtons != null )
		{
			this.pacificButtons.EnableAll();
		}
	}

	public HideAll(): void
	{
		if ( this.arcticButtons != null )
		{
			this.arcticButtons.HideAll();
		}
		if ( this.pacificButtons != null )
		{
			this.pacificButtons.HideAll();
		}
	}

	public ShowAll(): void
	{
		if ( this.arcticButtons != null )
		{
			this.arcticButtons.ShowAll();
		}
		if ( this.pacificButtons != null )
		{
			this.pacificButtons.ShowAll();
		}
	}

	public EnableButton(COMMAND_NAME: string, enabled: boolean): void
	{
		if ( this.arcticButtons != null )
		{
			this.arcticButtons.EnableButton(COMMAND_NAME, enabled);
		}
		if ( this.pacificButtons != null )
		{
			this.pacificButtons.EnableButton(COMMAND_NAME, enabled);
		}
	}

	public ShowButton(COMMAND_NAME: string, visible: boolean): void
	{
		if ( this.arcticButtons != null )
		{
			this.arcticButtons.ShowButton(COMMAND_NAME, visible);
		}
		if ( this.pacificButtons != null )
		{
			this.pacificButtons.ShowButton(COMMAND_NAME, visible);
		}
	}

	public ShowHyperLink(URL: string, visible: boolean): void
	{
		if ( this.arcticButtons != null )
		{
			this.arcticButtons.ShowHyperLink(URL, visible);
		}
		if ( this.pacificButtons != null )
		{
			this.pacificButtons.ShowHyperLink(URL, visible);
		}
	}

	// 04/05/2021 Paul.  DataPrivacy module needs to set the button class. 
	public SetControlClass(COMMAND_NAME: string, CONTROL_CSSCLASS: string): void
	{
		if ( this.arcticButtons != null )
		{
			this.arcticButtons.SetControlClass(COMMAND_NAME, CONTROL_CSSCLASS);
		}
		if ( this.pacificButtons != null )
		{
			this.pacificButtons.SetControlClass(COMMAND_NAME, CONTROL_CSSCLASS);
		}
	}
}
