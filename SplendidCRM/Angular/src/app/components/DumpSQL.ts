import { Component, OnInit, Input } from '@angular/core'          ;
import { CrmConfigService  } from '..//scripts/Crm';

@Component({
	selector: 'DumpSQL',
	template: `<ng-container *ngIf="show_sql && SQL != null">
	<pre (click)="onToggleSql()" [ngStyle]="cssSql">{{ SQL }}</pre>
</ng-container>`
})
export class DumpSQLComponent implements OnInit
{
	public show_sql  : boolean = false;
	public expand_sql: boolean = false;
	public cssSql    : any     = {};
	@Input() SQL: string = null;

	constructor(private Crm_Config: CrmConfigService)
	{
		this.show_sql = Crm_Config.ToBoolean('show_sql');
		this.cssSql = { height: '1em', cursor: 'pointer', marginBottom: 0, overflowX: 'hidden' };
	}

	ngOnInit()
	{
	}

	public onToggleSql()
	{
		this.expand_sql = !this.expand_sql;
		if ( this.expand_sql )
		{
			this.cssSql = { cursor: 'pointer', marginBottom: 0 };
		}
		else
		{
			this.cssSql = { height: '1em', cursor: 'pointer', marginBottom: 0, overflowX: 'hidden' };
		}
	}
}
