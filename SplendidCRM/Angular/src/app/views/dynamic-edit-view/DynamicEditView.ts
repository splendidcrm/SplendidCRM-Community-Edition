import { Component, OnInit, Input, Output, ViewChild, EventEmitter } from '@angular/core'   ;

@Component({
  selector: 'DynamicEditView',
  templateUrl: './DynamicEditView.html',
})
export class DynamicEditViewComponent implements OnInit
{
	@Input()  MODULE_NAME        : string  = null;
	@Input()  ID                 : string  = null;
	@Input()  LAYOUT_NAME        : string  = null;
	@Input()  CONTROL_VIEW_NAME  : string  = null;
	@Input()  rowDefaultSearch   : any     = null;
	@Input()  isPrecompile       : boolean = null;
	@Input()  isSearchView       : boolean = null;
	@Input()  isUpdatePanel      : boolean = null;
	@Input()  isQuickCreate      : boolean = null;
	@Input()  fromLayoutName     : string  = null;
	// 06/13/2022 Paul.  callback.observed is not sufficient to determine if this is an embedded view. 
	@Input()  hasCallback        : boolean = null;
	@Output() onLayoutLoaded     : EventEmitter<void> = new EventEmitter<void>();
	@Output() onSubmit           : EventEmitter<void> = new EventEmitter<void>();
	@Output() onComponentComplete: EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}> = new EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}>();
	@Output() callback           : EventEmitter<{key: string, newValue: any}> = new EventEmitter<{key: string, newValue: any}>();

	constructor()
	{
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit', window.location.pathname);
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
		// 06/03/2022 Paul.  this.headerButtons not ready in ngAfterViewInit() because of *ngIf that wraps it. 
		//console.log(this.constructor.name + '.ngAfterViewInit headerButtons', this.headerButtons);
	}

	// Called after the ngAfterViewInit() and every subsequent ngAfterContentChecked().
	ngAfterViewChecked(): void
	{
		// 06/03/2022 Paul.  this.headerButtons not ready in ngAfterViewInit() because of *ngIf that wraps it. 
		//console.log(this.constructor.name + '.ngAfterViewChecked headerButtons', this.headerButtons);
	}

	// Called immediately before Angular destroys the directive or component.
	ngOnDestroy(): void
	{
		//console.log(this.constructor.name + '.ngOnDestroy');
	}

	public _onLayoutLoaded = () =>
	{
		this.onLayoutLoaded.emit();
	}

	public _onSubmit = () =>
	{
		this.onSubmit.emit();
	}

	public _onComponentComplete = (obj: {MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}) =>
	{
		this.onComponentComplete.emit(obj);
	}

	public _editViewCallback = (obj: {key: string, newValue: any}) =>
	{
		this.callback.emit(obj);
	}

}
