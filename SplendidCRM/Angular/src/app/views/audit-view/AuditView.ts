import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';

@Component({
	selector: 'AuditView',
	templateUrl: './AuditView.html',
})
export class AuditViewComponent implements OnInit
{
	public layout : any    = null;
	public columns: any    = null;
	public vwMain : any    = null;
	public error  : any    = null;
	public __sql  : string = null;

	@Input()  isOpen     : boolean = false;
	@Output() callback   : EventEmitter<void> = new EventEmitter<void>();
	@Input()  MODULE_NAME: string = null;
	@Input()  NAME       : string = null;
	@Input()  ID         : string = null;

	constructor()
	{
	}

	ngOnInit()
	{
	}

}
