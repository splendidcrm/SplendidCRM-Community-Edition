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
import { DetailViewComponentBase                                   } from '../DetailComponents/DetailViewComponentBase';

@Component({
	selector: 'DetailViewTextBox',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyRow()">
		<span>row is null for DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsErased()">
		<span class="Erased">{{ L10n.Term('DataPrivacy.LBL_ERASED_VALUE') }}</span>
	</ng-container>
	<ng-container *ngIf="!IsErased() && IsVisible() && html">
		<div [innerHTML]="DATA_VALUE"></div>
	</ng-container>
	<ng-container *ngIf="!IsErased() && IsVisible() && !html">
		<ng-container *ngIf="!IsArray(DISPLAY_NAME)">
			<span [id]="ID" [class]="CSS_CLASS">{{ DISPLAY_NAME }}</span>
		</ng-container>
		<ng-container *ngIf="IsArray(DISPLAY_NAME)">
			<span [id]="ID" [class]="CSS_CLASS">
				<ng-container *ngFor="let line of DISPLAY_NAME">
					<div>{{ line.children }}</div>
				</ng-container>
			</span>
		</ng-container>
	</ng-container>`
})
export class DetailViewTextBoxComponent extends DetailViewComponentBase implements OnInit
{
	public MODULE_TYPE : string  = null;
	public DISPLAY_NAME: any     = null;
	public ERASED      : boolean = null;
	public html        : boolean = false;

	public IsArray(data: any)
	{
		return Array.isArray(data);
	}

	public IsErased()
	{
		return !this.IsHidden() && this.ERASED;
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n : C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	ngOnInit()
	{
		const { SplendidCache, Credentials, Security, L10n, Crm_Config } = this;
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let DATA_FORMAT      : string  = '';
		let ERASED           : boolean = false;
		let html             : boolean = false;

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT);
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				if ( row != null )
				{
					// 12/24/2012 Paul.  Use regex global replace flag. 
					// 05/14/2018 Paul.  id is set above. 
					//tdField.id = 'ctlDetailView_' + DATA_FIELD.replace(/\s/g, '_');
					DATA_VALUE = row[DATA_FIELD];
					// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
					if ( DATA_VALUE == null && this.ERASED_FIELDS.indexOf(DATA_FIELD) >= 0 )
					{
						ERASED = true;
					}
					// 04/29/2020 Paul.  The raw format is used in Emails.DetailView. 
					else if ( DATA_FORMAT != 'raw' )
					{
						DATA_VALUE = NormalizeDescription(DATA_VALUE);
						/// 06/06/2022 Paul.  Angular is expected escape tags, so override. 
						if ( DATA_VALUE.indexOf('<br \/>') >= 0 )
						{
							this.html = true;
						}
						/*try
						{
							tdField.innerHTML = sDATA;
						}
						catch(error)
						{
							sDATA = row[DATA_FIELD];
							sDATA = sDATA.replace(/</g, '&lt;');
							sDATA = sDATA.replace(/>/g, '&gt;');
							let pre = React.createElement('pre', {}, sDATA);
							tdFieldChildren.push(pre);
						}*/
						// 09/09/2019 Paul.  Let HTML control take care of it. 
						//DATA_VALUE = DATA_VALUE.replace(/</g, '&lt;');
						//DATA_VALUE = DATA_VALUE.replace(/>/g, '&gt;');
					}
					else if ( DATA_FORMAT == 'raw' )
					{
						html = true;
					}
				}
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID           = ID          ;
		this.FIELD_INDEX  = FIELD_INDEX ;
		this.DATA_FIELD   = DATA_FIELD  ;
		this.DATA_VALUE   = DATA_VALUE  ;
		this.ERASED       = ERASED      ;
		this.html         = html        ;
	}

	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}
}
