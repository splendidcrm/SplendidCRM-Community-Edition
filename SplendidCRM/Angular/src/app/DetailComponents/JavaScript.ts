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
	selector: 'DetailViewJavaScript',
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
	<ng-container *ngIf="IsVisible()">
		<span [id]="URL_TARGET" [class]="CSS_CLASS"></span>
	</ng-container>`
})
export class DetailViewJavaScriptComponent extends DetailViewComponentBase implements OnInit
{
	public URL_FIELD    : string;
	public URL_FORMAT   : string;
	public URL_TARGET   : string;

	public IsVisible()
	{
		return super.IsVisible() && !Sql.IsEmptyString(this.URL_TARGET) ;
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n : C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	ngOnInit()
	{
		const { SplendidCache, Credentials, Security, L10n, Crm_Config } = this;
		let FIELD_INDEX      : number = 0;
		let URL_FIELD        : string = '';
		let URL_FORMAT       : string = '';
		let URL_TARGET       : string = '';

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				URL_FIELD         = Sql.ToString (layout.URL_FIELD  );
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + URL_FIELD.replace(/\s/g, '_');
				
				if ( row != null )
				{
					if ( !Sql.IsEmptyString(URL_FORMAT) )
					{
						// 03/20/2016 Paul.  Need to protect against null strings. 
						let arrURL_FORMAT = Sql.ToString(URL_FORMAT).split(' ');
						let arrURL_FIELD  = Sql.ToString(URL_FIELD).split(' ');
						for ( let nFormatIndex = 0; nFormatIndex < arrURL_FIELD.length; nFormatIndex++ )
						{
							if ( row[arrURL_FIELD[nFormatIndex]] == null )
							{
								URL_FORMAT = Sql.ToString(URL_FORMAT).replace('{' + nFormatIndex.toString() + '}', '');
								URL_TARGET = Sql.ToString(URL_TARGET).replace('{' + nFormatIndex.toString() + '}', '');
							}
							else
							{
								let URL_VALUE: string = row[arrURL_FIELD[nFormatIndex]];
								URL_VALUE  = this.Formatting.FromJsonDate(URL_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
								URL_FORMAT = Sql.ToString(URL_FORMAT).replace('{' + nFormatIndex.toString() + '}', Sql.EscapeJavaScript(URL_VALUE));
								URL_TARGET = Sql.ToString(URL_TARGET).replace('{' + nFormatIndex.toString() + '}', Sql.EscapeJavaScript(URL_VALUE));
							}
						}
						//eval(sURL_FORMAT);
					}
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + sURL_FIELD, sURL_FORMAT, row);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID          = ID         ;
		this.FIELD_INDEX = FIELD_INDEX;
		this.URL_FIELD   = URL_FIELD  ;
		this.URL_FORMAT  = URL_FORMAT ;
		this.URL_TARGET  = URL_TARGET ;
	}

	ngAfterViewInit()
	{
		const { URL_FORMAT, URL_TARGET } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.ngAfterViewInit ' + URL_TARGET, URL_FORMAT, this.props.row);
		if ( !Sql.IsEmptyString(URL_FORMAT) )
		{
			try
			{
				eval(URL_FORMAT);
			}
			catch(error: any)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngAfterViewInit', error);
			}
		}
	}
}
