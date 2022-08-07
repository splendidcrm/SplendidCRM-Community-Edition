import { Component, OnInit, Input, Output, EventEmitter, ViewChild, ComponentFactoryResolver, ViewContainerRef, Injector, ChangeDetectorRef } from '@angular/core';

import { PopupViewComponent } from '../popup-view/PopupView';

@Component({
  selector: 'DynamicPopupView',
  template: `<ng-container #container></ng-container>`,
})
export class DynamicPopupViewComponent implements OnInit
{
	private   lastOpen              : boolean = false;
	@Input()  MODULE_NAME           : string  = null;
	@Input()  rowDefaultSearch      : any     = null;
	@Input()  isOpen                : boolean = null;
	@Input()  showProcessNotes      : boolean = null;
	@Input()  multiSelect           : boolean = null;
	@Input()  ClearDisabled         : boolean = null;
	@Input()  isSearchView          : boolean = null;
	@Input()  fromLayoutName        : string  = null;
	@Input()  isPrecompile          : boolean = null;
	@Output() onComponentComplete   : EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}> = new EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}>();
	@Output() callback              : EventEmitter<{Action: string, ID?: string, NAME?: string, PROCESS_NOTES?: string, selectedItems?: any}> = new EventEmitter<{Action: string, ID?: string, NAME?: string, PROCESS_NOTES?: string, selectedItems?: any}>();

	@ViewChild('container', { read: ViewContainerRef }) container!: ViewContainerRef;

	constructor(private changeDetectorRef: ChangeDetectorRef, private resolver: ComponentFactoryResolver, public viewContainerRef: ViewContainerRef, private injector: Injector)
	{
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit', window.location.pathname);
	}

	ngDoCheck()
	{
		const { container } = this;
		//console.log(this.constructor.name + '.ngDoCheck', window.location.pathname);
		if ( container )
		{
			if ( this.isOpen && !this.lastOpen )
			{
				const factory: any = this.resolver.resolveComponentFactory(PopupViewComponent);
				if ( factory != null )
				{
					const componentRef = this.container.createComponent<PopupViewComponent>(factory, 0, this.injector);
					componentRef.instance.MODULE_NAME      = this.MODULE_NAME     ;
					componentRef.instance.rowDefaultSearch = this.rowDefaultSearch;
					componentRef.instance.isOpen           = this.isOpen          ;
					componentRef.instance.showProcessNotes = this.showProcessNotes;
					componentRef.instance.multiSelect      = this.multiSelect     ;
					componentRef.instance.ClearDisabled    = this.ClearDisabled   ;
					componentRef.instance.isSearchView     = this.isSearchView    ;
					componentRef.instance.fromLayoutName   = this.fromLayoutName  ;
					componentRef.instance.isPrecompile     = this.isPrecompile    ;
					componentRef.instance.onComponentComplete.subscribe(this.onComponentComplete);
					componentRef.instance.callback.subscribe           (this.callback           );
					this.lastOpen = true;
				}
			}
			else if ( !this.isOpen && this.lastOpen )
			{
				this.container.clear();
				this.lastOpen = false;
			}
		}
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
		//console.log(this.constructor.name + '.ngAfterViewInit headerButtons', this.headerButtons);
	}

	// Called after the ngAfterViewInit() and every subsequent ngAfterContentChecked().
	ngAfterViewChecked(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewChecked headerButtons', this.headerButtons);
		this.changeDetectorRef.detectChanges();
	}

	// Called immediately before Angular destroys the directive or component.
	ngOnDestroy(): void
	{
		//console.log(this.constructor.name + '.ngOnDestroy');
	}

	public _onComponentComplete = (obj: {MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}) =>
	{
		this.onComponentComplete.emit(obj);
	}

	public _onCallback = (obj: {Action: string, ID?: string, NAME?: string, PROCESS_NOTES?: string, selectedItems?: any}) =>
	{
		this.callback.emit(obj);
	}

}
