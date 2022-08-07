import { Component, OnInit, Input } from '@angular/core';

@Component({
	selector: 'ErrorComponent',
	templateUrl: './ErrorComponent.html',
})
export class ErrorComponent implements OnInit
{
	public error$: string = null;
	@Input() set error(error: any)
	{
		if ( error != undefined && error != null )
		{
			if ( error.message !== undefined )
			{
				this.error$ = error.message;
			}
			else if ( typeof(error) == 'string' )
			{
				this.error$ = error;
			}
			else if ( typeof(error) == 'object' )
			{
				this.error$ = JSON.stringify(error);
			}
		}
	}

	constructor()
	{
	}

	ngOnInit()
	{
	}

}
