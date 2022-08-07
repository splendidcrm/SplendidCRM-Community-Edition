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
import { Trim                                                      } from '../scripts/utility'           ;
import { DetailViewComponentBase                                   } from '../DetailComponents/DetailViewComponentBase';

@Component({
	selector: 'DetailViewiFrame',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for IFrame FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyRow()">
		<span>row is null for IFrame DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<div [id]="ID" class='embed-responsive'>
			<iframe [src]="IFRAME_SRC" [class]="CSS_CLASS" [height]="IFRAME_HEIGHT" width='100%'></iframe>
		</div>
	</ng-container>`
})
export class DetailViewiFrameComponent extends DetailViewComponentBase implements OnInit
{
	public IFRAME_HEIGHT: string;
	public IFRAME_SRC   : string;

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
		let URL_FIELD        : string = '';
		let URL_FORMAT       : string = '';
		let IFRAME_HEIGHT    : string = '';
		let IFRAME_SRC       : string = '';

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				IFRAME_HEIGHT     = Sql.ToString (layout.URL_TARGET );
				URL_FIELD         = Sql.ToString (layout.URL_FIELD  );
				URL_FORMAT        = Sql.ToString (layout.URL_FORMAT );
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				if ( Sql.IsEmptyString(IFRAME_HEIGHT) )
				{
					IFRAME_HEIGHT = '200';
				}
				if ( !Sql.IsEmptyString(URL_FIELD) )
				{
					IFRAME_SRC = URL_FORMAT;
					if ( row != null )
					{
						// 03/20/2016 Paul.  Need to protect against null strings. 
						let arrURL_FORMAT = Sql.ToString(URL_FORMAT).split(' ');
						let arrURL_FIELD  = Sql.ToString(URL_FIELD).split(' ');
						for ( let nFormatIndex = 0; nFormatIndex < arrURL_FIELD.length; nFormatIndex++ )
						{
							if ( row[arrURL_FIELD[nFormatIndex]] == null )
							{
								IFRAME_SRC = IFRAME_SRC.replace('{' + nFormatIndex.toString() + '}', '');
							}
							else
							{
								let URL_VALUE: string = row[arrURL_FIELD[nFormatIndex]];
								URL_VALUE  = this.Formatting.FromJsonDate(URL_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
								IFRAME_SRC = IFRAME_SRC.replace('{' + nFormatIndex.toString() + '}', Sql.EscapeJavaScript(URL_VALUE));
							}
						}
					}
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID            = ID           ;
		this.FIELD_INDEX   = FIELD_INDEX  ;
		this.DATA_FIELD    = DATA_FIELD   ;
		this.DATA_VALUE    = DATA_VALUE   ;
		this.IFRAME_HEIGHT = IFRAME_HEIGHT;
		this.IFRAME_SRC    = IFRAME_SRC   ;
		this.CSS_CLASS     = 'embed-responsive-item';
	}

	async ngAfterViewInit()
	{
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}
}
