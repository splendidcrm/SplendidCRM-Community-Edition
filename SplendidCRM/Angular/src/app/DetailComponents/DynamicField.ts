import { Component, OnInit, Input, Output, EventEmitter, ViewChild, ComponentFactoryResolver, ViewContainerRef, Injector, ChangeDetectorRef } from '@angular/core';

import { SplendidCacheService                                      } from '../scripts/SplendidCache'                   ;

import { DetailViewComponentBase                                   } from '../DetailComponents/DetailViewComponentBase';
import { DetailViewUnknownComponent                                } from '../DetailComponents/Unknown'                ;
import * as possibleComponents                                       from '../DetailComponents/_all'                   ;

@Component({
	selector: 'DetailViewDynamicField',
	template: ' <ng-container #container></ng-container>'
})
export class DetailViewDynamicField implements OnInit
{
	public JSON             = JSON           ;

	@Input()  template      : any      = null;
	@Output() Page_Command  : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();
	@Output() fieldDidMount : EventEmitter<{DATA_FIELD  : string, component        : any}> = new EventEmitter<{DATA_FIELD  : string, component        : any}>();

	@ViewChild('container', { read: ViewContainerRef }) container!: ViewContainerRef; 

	constructor(private changeDetectorRef: ChangeDetectorRef, private resolver: ComponentFactoryResolver, public viewContainerRef: ViewContainerRef, private injector: Injector, public SplendidCache: SplendidCacheService)
	{
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit', this.template);
	}

	ngDoCheck()
	{
		//console.log(this.constructor.name + '.ngDoCheck', window.location.pathname);
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
			let tagName: string = 'DetailView' + template.tag + 'Component';
			Object.entries(possibleComponents).find(([key, value]) =>
			{
				if ( key === tagName )
				{
					inputComponent = value;
					return true;
				}
				return false;
			});
			if ( inputComponent == null )
			{
				console.log(this.constructor.name + '.ngAfterViewInit Unknown tag ' + template.tag, template);
				inputComponent = DetailViewUnknownComponent;
			}
			if ( inputComponent )
			{
				//console.log(this.constructor.name + '.ngAfterViewInit ' + tagName + ' ' + typeof(inputComponent), inputComponent);
				const factory: any = this.resolver.resolveComponentFactory(inputComponent);
				if ( factory != null )
				{
					if ( this.container != null )
					{
						this.container.clear();
						const componentRef = this.container.createComponent<DetailViewComponentBase>(factory, 0, this.injector);
						componentRef.instance.baseId               = template.props.baseId;
						componentRef.instance.row                  = template.props.row;
						componentRef.instance.layout               = template.props.layout;
						componentRef.instance.ERASED_FIELDS        = template.props.ERASED_FIELDS;
						componentRef.instance.bIsHidden            = template.props.bIsHidden;
						componentRef.instance.fieldDidMount.subscribe(this._onFieldDidMount);
						componentRef.instance.Page_Command.subscribe (this._onPage_Command );
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
		this.Page_Command.emit(obj);
	}

	public _onFieldDidMount = (obj: {DATA_FIELD  : string, component        : any}) =>
	{
		if ( this.fieldDidMount != null )
		{
			this.fieldDidMount.emit(obj);
		}
		else
		{
			console.log(this.constructor.name + '._onFieldDidMount: this.fieldDidMount is null', this.template);
		}
	}
}
