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
import { StartsWith, EndsWith                                      } from '../scripts/utility'           ;
import { NormalizeDescription                                      } from '../scripts/EmailUtils'        ;
import { DetailViewComponentBase                                   } from '../DetailComponents/DetailViewComponentBase';

@Component({
	selector: 'DetailViewModuleLink',
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
	<ng-container *ngIf="!IsErased() && IsVisible()">
		<ng-container *ngIf="IsExternalUrl()">
			<span>
				<a [id]="ID" [href]="URL">{{ DISPLAY_NAME }}</a>
			</span>
		</ng-container>
		<ng-container *ngIf="!IsExternalUrl()">
			<span [id]="ID" (click)="_onClick($event)" [class]="CSS_CLASS" style="cursor: pointer">{{ DISPLAY_NAME }}</span>
		</ng-container>
	</ng-container>`
})
export class DetailViewModuleLinkComponent extends DetailViewComponentBase implements OnInit
{
	public DATA_LABEL   : string;
	public URL_FORMAT   : string;
	public URL_FIELD    : string;
	public URL_VALUE    : string;
	public MODULE_NAME  : string;
	public URL          : string;
	public DISPLAY_NAME : string;
	public MODULE_TYPE  : string;
	public ERASED       : boolean;

	public IsErased()
	{
		return !this.IsHidden() && this.ERASED;
	}

	public IsExternalUrl()
	{
		return !StartsWith(this.URL, '/');
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
		let DATA_LABEL       : string = '';
		let DATA_FORMAT      : string = '';
		let URL_FORMAT       : string = '';
		let URL_FIELD        : string = '';
		let URL_VALUE        : string = '';
		let MODULE_NAME      : string = '';
		let URL              : string = '#';
		let DISPLAY_NAME     : string = '';
		let MODULE_TYPE      : string = '';
		let ERASED           : boolean = false;

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				DATA_LABEL        = Sql.ToString (layout.DATA_LABEL );
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT);
				URL_FORMAT        = Sql.ToString (layout.URL_FORMAT );
				URL_FIELD         = Sql.ToString (layout.URL_FIELD  );
				MODULE_NAME       = Sql.ToString (layout.MODULE_NAME);
				MODULE_TYPE       = Sql.ToString (layout.MODULE_TYPE);
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				if ( row != null )
				{
					// 06/18/2018 Paul.  Don't convert to string here as the old code is using undefined in its checks. 
					DATA_VALUE = row[DATA_FIELD];
					URL_VALUE = Sql.ToString(row[URL_FIELD]);
					if ( StartsWith(URL_FORMAT, 'mailto:') && !Sql.IsEmptyString(URL_VALUE) )
					{
						URL = URL_FORMAT.replace('{0}', URL_VALUE);
					}
					// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
					if ( DATA_VALUE == null && this.ERASED_FIELDS.indexOf(DATA_FIELD) >= 0 )
					{
						ERASED = true;
					}
					// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
					if ( !ERASED && (DATA_VALUE != null || DATA_VALUE === undefined) && MODULE_TYPE != null )
					{
						let a = null;
						if ( URL_FORMAT.substr(0, 2) == '~/' )
						{
							let URL_MODULE_NAME = MODULE_TYPE;
							if ( URL_MODULE_NAME == 'Parents' )
							{
								URL_MODULE_NAME = row[DATA_LABEL];
							}
							MODULE_NAME = URL_MODULE_NAME;
							// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
							//oDetailViewUI.Load(sLayoutPanel, sActionsPanel, MODULE_NAME, ID, function(status, message)
							URL = '/' + URL_MODULE_NAME + '/View/' + URL_VALUE;
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
		// 10/15/2021 Paul.  Correct StartsWith call. 
		if ( !StartsWith(URL, 'http') && !StartsWith(URL, '/') )
		{
			URL = '/' + URL;
		}
		this.ID           = ID          ;
		this.FIELD_INDEX  = FIELD_INDEX ;
		this.DATA_FIELD   = DATA_FIELD  ;
		this.DATA_VALUE   = DATA_VALUE  ;
		this.DATA_LABEL   = DATA_LABEL  ;
		this.DATA_FORMAT  = DATA_FORMAT ;
		this.URL_FORMAT   = URL_FORMAT  ;
		this.URL_FIELD    = URL_FIELD   ;
		this.URL_VALUE    = URL_VALUE   ;
		this.MODULE_NAME  = MODULE_NAME ;
		this.URL          = URL         ;
		this.DISPLAY_NAME = DISPLAY_NAME;
		this.MODULE_TYPE  = MODULE_TYPE ;
		this.ERASED       = ERASED      ;
	}

	async ngAfterViewInit()
	{
		const { DATA_FIELD, DATA_VALUE, DATA_FORMAT, URL_FORMAT, URL_VALUE, MODULE_NAME, MODULE_TYPE, ERASED } = this;
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
		// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
		if ( !ERASED && (DATA_VALUE != null || DATA_VALUE === undefined) && !Sql.IsEmptyString(MODULE_TYPE) )
		{
			// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
			if ( DATA_VALUE === undefined && !Sql.IsEmptyString(URL_VALUE) )
			{
				try
				{
					let value = await this.Crm_Modules.ItemName(MODULE_NAME, URL_VALUE);
					let DISPLAY_NAME: string = '';
					if ( Sql.IsEmptyString(DATA_FORMAT) )
					{
						DISPLAY_NAME = value;
					}
					else
					{
						DISPLAY_NAME = DATA_FORMAT.replace('{0}', value);
					}
					this.DISPLAY_NAME = DISPLAY_NAME;
				}
				catch(error: any)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
					// 05/20/2018 Paul.  When an error is encountered, we display the error in the name. 
					// 11/17/2021 Paul.  Must use message text and not error object. 
					this.DISPLAY_NAME = error.message;
				}
			}
			this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
		}
	}

	public _onClick(event: any)
	{
		this.router.navigateByUrl(this.URL);
	}
}
