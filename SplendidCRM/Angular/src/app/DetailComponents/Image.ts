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
	selector: 'DetailViewImage',
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
		<img [id]="ID" [src]="URL" [title]="DISPLAY_NAME" [class]="CSS_CLASS" [width]="WIDTH" [height]="HEIGHT" />
	</ng-container>`
})
export class DetailViewImageComponent extends DetailViewComponentBase implements OnInit
{
	public MODULE_TYPE : string  = null;
	public DISPLAY_NAME: any     = null;
	public URL         : string  = null;
	public WIDTH       : string  = null;
	public HEIGHT      : string  = null;

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.DISPLAY_NAME = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'URL' )
		{
			this.URL = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.CSS_CLASS = DATA_VALUE;
		}
		// 02/22/2022 Paul.  Allow image to be formatted. 
		else if ( PROPERTY_NAME == 'width' )
		{
			this.WIDTH = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'height' )
		{
			this.HEIGHT = DATA_VALUE;
		}
	}

	public IsVisible()
	{
		return super.IsVisible() && !Sql.IsEmptyString(this.DATA_VALUE) ;
	}

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
		let URL              : string = '';
		let DATA_FORMAT      : string = null;
		// 02/22/2022 Paul.  Allow image to be formatted. 
		let WIDTH            : string = null;
		let HEIGHT           : string = null;

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				// 02/22/2022 Paul.  Allow image to be formatted. 
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT);
				if ( !Sql.IsEmptyString(DATA_FORMAT) )
				{
					try
					{
						let arrDATA_FORMAT: string[] = DATA_FORMAT.split(';');
						for ( let i = 0; i < arrDATA_FORMAT.length; i++ )
						{
							let arrNAME_VALUE: string[] = arrDATA_FORMAT[i].split('=');
							if ( arrNAME_VALUE.length == 2 )
							{
								let sNAME : string = Trim(arrNAME_VALUE[0]);
								let sVALUE: string = Trim(arrNAME_VALUE[1]);
								if ( sNAME.toLowerCase() == "width" )
									WIDTH = sVALUE;
								else if ( sNAME.toLowerCase() == "height" )
									HEIGHT = sVALUE;
							}
						}
					}
					catch
					{
						// 02/22/2022 Paul.  Ignore any errors. 
					}
				}
				
				if ( row != null )
				{
					DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
					if ( !Sql.IsEmptyString(DATA_VALUE) )
					{
						URL = Credentials.RemoteServer + 'Images/Image.aspx?ID=' + DATA_VALUE;
					}
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID           = ID          ;
		this.FIELD_INDEX  = FIELD_INDEX ;
		this.DATA_FIELD   = DATA_FIELD  ;
		this.DATA_VALUE   = DATA_VALUE  ;
		this.DISPLAY_NAME = DATA_VALUE  ;
		this.URL          = URL         ;
		this.WIDTH        = WIDTH       ;
		this.HEIGHT       = HEIGHT      ;
	}

	async ngAfterViewInit()
	{
		const { DATA_VALUE } = this;
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		try
		{
			// 03/21/2022 Paul.  No need to get the name if the value is null. 
			if ( !Sql.IsEmptyString(DATA_VALUE) )
			{
				let value = await this.Crm_Modules.ItemName('Images', DATA_VALUE);
				this.DISPLAY_NAME = value;
			}
			this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			// 05/20/2018 Paul.  When an error is encountered, we display the error in the name. 
			// 11/17/2021 Paul.  Must use message text and not error object. 
			this.DISPLAY_NAME = error.message;
		}
	}
}
