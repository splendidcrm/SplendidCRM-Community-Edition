import { Component, OnInit, Input, Output, EventEmitter, ViewChild, ComponentFactoryResolver, ViewContainerRef, Injector, ChangeDetectorRef } from '@angular/core';

import { SplendidCacheService                                      } from '../scripts/SplendidCache'                   ;

import { EditViewComponentBase                                     } from '../EditComponents/EditViewComponentBase'    ;
import { EditViewUnknownComponent                                  } from '../EditComponents/Unknown'                  ;
import * as possibleComponents                                       from '../EditComponents/_all'                     ;

@Component({
	selector: 'EditViewDynamicField',
	template: ' <ng-container #container></ng-container>'
})
export class EditViewDynamicField implements OnInit
{
	public JSON                   = JSON           ;

	@Input()  template            : any      = null;
	@Output() onChanged           : EventEmitter<{DATA_FIELD  : string, DATA_VALUE: any, DISPLAY_FIELD?          : string, DISPLAY_VALUE?: any}> = new EventEmitter<{DATA_FIELD  : string, DATA_VALUE       : any   , DISPLAY_FIELD?: string, DISPLAY_VALUE?: any}>();
	@Output() onSubmit            : EventEmitter<void                                                                                          > = new EventEmitter<void                                                                                          >();
	@Output() onUpdate            : EventEmitter<{PARENT_FIELD: string, DATA_VALUE       : any   , item?         : any   }                     > = new EventEmitter<{PARENT_FIELD: string, DATA_VALUE       : any   , item?         : any   }                     >();
	// 06/09/2022 Paul.  createDependency is only used by ListBox, so we probably should remove from all others. 
	@Output() createDependency    : EventEmitter<{DATA_FIELD  : string, PARENT_FIELD     : string, PROPERTY_NAME?: string}                     > = new EventEmitter<{DATA_FIELD  : string, PARENT_FIELD     : string, PROPERTY_NAME?: string}                     >();
	@Output() Page_Command        : EventEmitter<{sCommandName: string, sCommandArguments: any}                                                > = new EventEmitter<{sCommandName: string, sCommandArguments: any}                                                >();
	@Output() fieldDidMount       : EventEmitter<{DATA_FIELD  : string, component        : any}                                                > = new EventEmitter<{DATA_FIELD  : string, component        : any}                                                >();

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
			let tagName: string = 'EditView' + template.tag + 'Component';
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
				inputComponent = EditViewUnknownComponent;
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
						const componentRef = this.container.createComponent<EditViewComponentBase>(factory, 0, this.injector);
						componentRef.instance.template             = template;
						componentRef.instance.baseId               = template.props.baseId;
						componentRef.instance.row                  = template.props.row;
						componentRef.instance.layout               = template.props.layout;
						componentRef.instance.ERASED_FIELDS        = template.props.ERASED_FIELDS;
						componentRef.instance.bIsHidden            = template.props.bIsHidden;
						componentRef.instance.onChanged.subscribe       (this._onChanged         );
						componentRef.instance.onSubmit.subscribe        (this._onSubmit          );
						componentRef.instance.onUpdate.subscribe        (this._onUpdate          );
						componentRef.instance.fieldDidMount.subscribe   (this._onFieldDidMount   );
						componentRef.instance.createDependency.subscribe(this._onCreateDependency);
						componentRef.instance.Page_Command.subscribe    (this._onPage_Command    );
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

	public _onChanged = (obj: {DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any}) =>
	{
		this.onChanged.emit(obj);
	}

	public _onSubmit = () =>
	{
		this.onSubmit.emit();
	}

	public _onUpdate = (obj: {PARENT_FIELD: string, DATA_VALUE: any, item?: any}) =>
	{
		this.onUpdate.emit(obj);
	}

	public _onCreateDependency = (obj: {DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string}) =>
	{
		this.createDependency.emit(obj);
	}

	public _onPage_Command = (obj: {sCommandName: string, sCommandArguments: any}) =>
	{
		this.Page_Command.emit(obj);
	}

	public _onFieldDidMount = (obj: {DATA_FIELD  : string, component        : any}) =>
	{
		this.fieldDidMount.emit(obj);
	}

}
