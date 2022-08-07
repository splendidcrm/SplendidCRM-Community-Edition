import { Component, OnInit, Input, Output, EventEmitter, ViewChild, ComponentFactoryResolver, ViewContainerRef, Injector, ChangeDetectorRef } from '@angular/core';
import { faArrowUp, faArrowDown                                    } from '@fortawesome/free-solid-svg-icons'          ;

import { SplendidCacheService                                      } from '../scripts/SplendidCache'                   ;

import { SplendidGridComponentBase                                 } from '../GridComponents/SplendidGridComponentBase';
import * as possibleComponents                                       from '../GridComponents/_all'                     ;

@Component({
	selector: 'SplendidGridDynamicColumn',
	template: '<ng-container #container></ng-container>'
})
export class SplendidGridDynamicColumnComponent implements OnInit
{
	public JSON                       = JSON           ;
	public arrowUp                    = faArrowUp      ;
	public arrowDown                  = faArrowDown    ;
	public sTheme                     : string = null  ;

	@Input()  baseId                  : string  = null ;
	@Input()  MODULE_NAME             : string  = null ;
	@Input()  enableSelection         : boolean = false;
	@Input()  isPopupView             : boolean = false;
	@Input()  colIndex                : number  = 0    ;
	@Input()  column                  : any     = null ;
	@Input()  template                : any     = null ;
	@Input()  rowIndex                : number  = 0    ;
	@Input()  row                     : any     = null ;
	@Input()  hasHyperLinkCallback    : boolean = false;
	@Output() hyperLinkCallback       : EventEmitter<{MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}> = new EventEmitter<{MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}>();
	@Output() Page_Command            : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();

	@ViewChild('container', { read: ViewContainerRef }) container!: ViewContainerRef; 

	constructor(private changeDetectorRef: ChangeDetectorRef, private resolver: ComponentFactoryResolver, public viewContainerRef: ViewContainerRef, private injector: Injector, public SplendidCache: SplendidCacheService)
	{
		this.sTheme = SplendidCache.UserTheme;
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit', template);
	}

	ngDoCheck()
	{
		//console.log(this.constructor.name + '.ngDoCheck', window.location.pathname);
	}

	// Called once after the first ngDoCheck().
	ngAfterContentInit(): void
	{
		const { template } = this;
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
		const { template } = this;
		if ( template != null )
		{
			/*
			Object.keys(possibleComponents).forEach(key =>
			{
				console.log(typeof(key));
			});
			*/
			let inputComponent: any = null;
			let tagName: string = 'SplendidGrid' + template.tag + 'Component';
			Object.entries(possibleComponents).find(([key, value]) =>
			{
				if ( key === tagName )
				{
					inputComponent = value;
					return true;
				}
				return false;
			});
			if ( inputComponent )
			{
				//console.log(this.constructor.name + '.ngOnInit ' + tagName + ' ' + typeof(inputComponent), inputComponent);
				const factory: any = this.resolver.resolveComponentFactory(inputComponent);
				if ( factory != null )
				{
					if ( this.container != null )
					{
						this.container.clear();
						const componentRef = this.container.createComponent<SplendidGridComponentBase>(factory, 0, this.injector);
						componentRef.instance.baseId               = this.baseId;
						componentRef.instance.row                  = this.row   ;
						componentRef.instance.layout               = template.props.layout;
						componentRef.instance.multiLine            = template.props.multiLine;
						if ( template.tag == 'Date' )
						{
							componentRef.instance.dateOnly         = true;
						}
						if ( template.tag == 'HyperLink' && this.hasHyperLinkCallback )
						{
							componentRef.instance.hasHyperLinkCallback = this.hasHyperLinkCallback;
							componentRef.instance.hyperLinkCallback.subscribe(this._onHyperLinkCallback);
						}
						if ( template.tag == 'ImageButton' || template.tag == 'LinkButton' )
						{
							componentRef.instance.Page_Command.subscribe(this._onPage_Command);
						}
					}
					else
					{
						console.log(this.constructor.name + '.ngAfterViewInit ' + tagName, 'this.container is null');
					}
				}
				else
				{
					console.log(this.constructor.name + '.ngAfterViewInit ' + tagName, 'factory is null');
				}
			}
		}
	}

	// Called after the ngAfterViewInit() and every subsequent ngAfterContentChecked().
	ngAfterViewChecked(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewChecked headerButtons', this.headerButtons);
		// 06/19/2022 Paul.  We are having an issue with HyperLink generating the following error.  Resolved by manually checking for changes. 
		// NG0100: ExpressionChangedAfterItHasBeenCheckedError: Expression has changed after it was checked. Previous value: 'undefined'.
		this.changeDetectorRef.detectChanges();
	}

	// Called immediately before Angular destroys the directive or component.
	ngOnDestroy(): void
	{
		//console.log(this.constructor.name + '.ngOnDestroy');
	}

	public _onPage_Command = (obj: {sCommandName: string, sCommandArguments: any}) =>
	{
		console.log(this.constructor.name + '._onPage_Command', obj);
		this.Page_Command.emit(obj);
	}

	public _onHyperLinkCallback = (obj: {MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}) =>
	{
		console.log(this.constructor.name + '._onHyperLinkCallback', obj);
		this.hyperLinkCallback.emit(obj);
	}
}
