import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'          ;
import { NgSelectComponent                                         } from '@ng-select/ng-select'   ;

import { CrmConfigService  } from '../scripts/Crm';

@Component({
	selector: 'AutoComplete',
	template: `<ng-container>
	<div [ngStyle]="wrapperStyle">
		<ng-select
			[id]="id"
			[inputAttrs]="{'name': id}"
			[items]="items"
			bindLabel="NAME"
			[editableSearchTerm]="true"
			[(ngModel)]="value"
			[readonly]="disabled"
			[searchable]="!disabled"
			[tabIndex]="tabIndex"
			[ngStyle]="style"
			(search)="_onChange($event)"
			[keyDownFn]="_onKeyDown"
			(change)="_onSelect($event)"
			(blur)="_onBlur($event)"
			(open)="_onOpen()"
			(close)="_onClose()"
		>
			<ng-template ng-option-tmp let-item="item" let-search="searchTerm">
				<div>{{ item.NAME }}</div>
				<small><b>ID:</b> {{ item.ID }}</small>
			</ng-template>
		</ng-select>
	</div>
</ng-container>`
})
export class AutoCompleteComponent implements OnInit
{
	public    maxLength                 : number  = null;
	public    tabIndex                  : number  = null;
	public    style                     : any     = null;
	public    autoComplete              : string  = null;

	@Input()  id                        : string  = null;
	@Input()  value                     : string  = null;
	@Input()  items                     : any[]   = null;
	@Input()  inputProps                : any     = null;
	@Input()  wrapperStyle              : any     = null;
	@Input()  autoHighlight             : boolean = null;
	@Input()  disabled                  : boolean = null;
	@Output() getItemValue              : EventEmitter<{item: any}                        > = new EventEmitter<{item: any}                        >();
	@Output() onChange                  : EventEmitter<{event: any, value: string}        > = new EventEmitter<{event: any, value: string}        >();
	@Output() onSelect                  : EventEmitter<{value: string, item: any}         > = new EventEmitter<{value: string, item: any}         >();
	@Output() onMenuVisibilityChange    : EventEmitter<boolean                            > = new EventEmitter<boolean                            >();
	@Output() onKeyDown                 : EventEmitter<any                                > = new EventEmitter<any                                >();
	@Output() onTextBlur                : EventEmitter<any                                > = new EventEmitter<any                                >();

	@ViewChild(NgSelectComponent) select: NgSelectComponent;

	constructor(private Crm_Config: CrmConfigService)
	{
	}

	ngOnInit()
	{
		const { inputProps } = this;
		if ( inputProps )
		{
			if ( inputProps.maxLength    ) this.maxLength    = inputProps.maxLength   ;
			if ( inputProps.tabIndex     ) this.tabIndex     = inputProps.tabIndex    ;
			if ( inputProps.style        ) this.style        = inputProps.style       ;
			if ( inputProps.autoComplete ) this.autoComplete = inputProps.autoComplete;
		}
	}

	ngDoCheck() : void
	{
		const { id, items } = this;
		//console.log(this.constructor.name + '.ngDoCheck ' + id, this.value);
		if ( this.select )
		{
			if ( this.select.hasValue && this.value == null )
			{
				// 06/27/2022 Paul.  Cannot get ng-select to clear an incomplete search. 
				this.select.clearModel();
				this.select.detectChanges();
				this.select.blur();
				console.log(this.constructor.name + '.ngDoCheck ' + id, 'clearing value');
			}
		}
	}

	public _onChange = (obj: {term: any, items: any[]}) =>
	{
		const { id } = this;
		//console.log(this.constructor.name + '._onChange ' + id, obj);
		this.onChange.emit({event: null, value: obj.term});
	}

	public _onSelect = (item: any) =>
	{
		const { id } = this;
		//console.log(this.constructor.name + '._onSelect ' + id, item);
		if ( item != null )
		{
			this.onSelect.emit({value: item.ID, item: item});
		}
	}

	public _onBlur = (event: any) =>
	{
		console.log(this.constructor.name + '._onBlur', event);
		this.onTextBlur.emit(event);
	}

	public _onKeyDown = (event: any): boolean =>
	{
		console.log(this.constructor.name + '._onKeyDown', event);
		this.onKeyDown.emit(event);
		return true;
	}

	public _onOpen = () =>
	{
		this.onMenuVisibilityChange.emit(true);
		if ( this.items == null || this.items.length == 0 )
		{
			this.onChange.emit({event: null, value: this.value});
		}
	}

	public _onClose = () =>
	{
		this.onMenuVisibilityChange.emit(false);
	}
}
