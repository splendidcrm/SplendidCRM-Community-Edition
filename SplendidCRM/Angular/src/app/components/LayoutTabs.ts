import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';

@Component({
	selector: 'LayoutTabs',
	templateUrl: './LayoutTabs.html',
})
export class LayoutTabsComponent implements OnInit
{
	@Input()  layout     : any = null;
	@Output() onTabChange: EventEmitter<number> = new EventEmitter<number>();

	constructor()
	{
	}

	ngOnInit()
	{
	}

}
