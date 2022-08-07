import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;

import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { C10nService                                               } from '../scripts/C10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import Sql                                                           from '../scripts/Sql'               ;
import { NormalizeDescription                                      } from '../scripts/EmailUtils'        ;
import { EditViewComponentBase                                     } from '../EditComponents/EditViewComponentBase';

@Component({
	selector: 'EditViewHidden',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for Hidden FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyChanged()">
		<span>onChanged is null for TextBox DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<span style="display: none">
			<input
				[id]="ID"
				[value]="DATA_VALUE"
				type="hidden"
				(change)="_onChange($event)"
			/>
		</span>
	</ng-container>`
})
export class EditViewHiddenComponent extends EditViewComponentBase implements OnInit
{
	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n : C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	ngOnInit()
	{
		const { SplendidCache, Credentials, Security, L10n, Crm_Config } = this;
		let FIELD_INDEX      : number = 0;
		let DATA_FIELD       : string = '';
		let DATA_VALUE       : string = '';

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				ID = baseId + '_' + DATA_FIELD;

				if ( row != null )
				{
					if ( !Sql.IsEmptyString(DATA_FIELD) && row[DATA_FIELD] != null )
					{
						DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
					}
					// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
					// 04/14/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
					if ( Sql.ToBoolean(row['DetailViewRelationshipCreate']) )
					{
						if ( DATA_FIELD == 'TEAM_ID' )
						{
							if ( Crm_Config.ToBoolean('inherit_team') && !Sql.IsEmptyString(row[DATA_FIELD]) )
							{
								DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
							}
							else
							{
								DATA_VALUE = Security.TEAM_ID();
							}
						}
						else if ( DATA_FIELD == 'ASSIGNED_USER_ID' )
						{
							if ( Crm_Config.ToBoolean('inherit_assigned_user') && !Sql.IsEmptyString(row[DATA_FIELD]) )
							{
								DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
							}
							else
							{
								DATA_VALUE = Security.USER_ID();
							}
						}
					}
				}
				else if ( DATA_FIELD == 'TEAM_ID' )
				{
					DATA_VALUE = Security.TEAM_ID();
				}
				else if ( DATA_FIELD == 'ASSIGNED_USER_ID' )
				{
					DATA_VALUE = Security.USER_ID();
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID                      = ID                     ;
		this.FIELD_INDEX             = FIELD_INDEX            ;
		this.DATA_FIELD              = DATA_FIELD             ;
		this.DATA_VALUE              = DATA_VALUE             ;
	}

	ngDoCheck() : void
	{
	}

	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}

	public _onChange(e: any)
	{
		const { baseId, layout, row, onChanged, onUpdate } = this;
		const { DATA_FIELD, ENABLED } = this;
		let DATA_VALUE: string = e.target.value;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		try
		{
			this.DATA_VALUE       = DATA_VALUE;
			this.onChanged.emit({DATA_FIELD  : DATA_FIELD, DATA_VALUE});
			this.onUpdate .emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE});
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

}
