import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';

@Component({
	selector: 'DetailViewRelationships',
	templateUrl: './DetailViewRelationships.html',
})
export class DetailViewRelationshipsComponent implements OnInit
{
	@Input()  PARENT_TYPE : string  = null;
	@Input()  DETAIL_NAME : string  = null;
	@Input()  row         : any     = null;
	@Input()  isPrecompile: boolean = false;
	@Output() onComponentComplete: EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}> = new EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}>();


	constructor()
	{
	}

	ngOnInit()
	{
	}

}
