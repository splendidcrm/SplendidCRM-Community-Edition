import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';
@Component({
  selector: 'HelpView',
  templateUrl: './HelpView.html',
})
export class HelpViewComponent implements OnInit
{
	@Input()  isOpen     : boolean = false;
	@Input()  MODULE_NAME: string  = null ;
	@Input()  helpName   : string  = null ;
	@Output() callback   : EventEmitter<void> = new EventEmitter<void>();

	constructor()
	{
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit', window.location.pathname);
	}
}
