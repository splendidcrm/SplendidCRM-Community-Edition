import { Component, OnInit, Input } from '@angular/core';

@Component({
	selector: 'DetailViewLineItems',
	templateUrl: './DetailViewLineItems.html',
})
export class DetailViewLineItemsComponent implements OnInit
{
	@Input()  MODULE_NAME: string = null;
	@Input()  ID         : string = null;

	constructor()
	{
	}

	ngOnInit() : void
	{
	}

}
