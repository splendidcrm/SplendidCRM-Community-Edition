import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';

@Component({
	selector: 'ActivitiesPopupView',
	templateUrl: './ActivitiesPopupView.html',
})
export class ActivitiesPopupViewComponent implements OnInit
{
	private defaultSearch      : any = null;
	public  error              : any = null;

	@Input()  isOpen     : boolean = false;
	@Output() callback   : EventEmitter<{Action: string}> = new EventEmitter<{Action: string}>();
	@Input()  PARENT_TYPE: string = null;
	@Input()  PARENT_ID  : string = null;

	constructor()
	{
	}

	ngOnInit()
	{
	}

}
