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
import { DetailViewComponentBase                                   } from '../DetailComponents/DetailViewComponentBase';

@Component({
	selector: 'DetailViewHyperLink',
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
				<a [id]="ID" [href]="URL" [target]="URL_TARGET">{{ DISPLAY_NAME }}</a>
			</span>
		</ng-container>
		<ng-container *ngIf="!IsExternalUrl()">
			<span [id]="ID" (click)="_onClick($event)" [class]="CSS_CLASS" style="cursor: pointer">{{ DISPLAY_NAME }}</span>
		</ng-container>
	</ng-container>`
})
export class DetailViewHyperLinkComponent extends DetailViewComponentBase implements OnInit
{
	public DATA_LABEL   : string;
	public URL_FORMAT   : string;
	public URL_FIELD    : string;
	public URL_VALUE    : string;
	public MODULE_NAME  : string;
	// 11/29/2021 Paul.  When MODULE_TYPE is specified, then DISPLAY_NAME will be a lookup. 
	public MODULE_TYPE  : string;
	public URL          : string;
	public DISPLAY_NAME : string;
	public ERASED       : boolean;
	public URL_TARGET   : string;

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
	}

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
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let DATA_LABEL       : string  = '';
		let DATA_FORMAT      : string  = '';
		let URL_FORMAT       : string  = '';
		let URL_FIELD        : string  = '';
		let URL_VALUE        : string  = '';
		let MODULE_NAME      : string  = '';
		let MODULE_TYPE      : string  = '';
		let URL              : string  = '#';
		let DISPLAY_NAME     : string  = '';
		let ERASED           : boolean = false;
		let CSS_CLASS        : string  = 'tabDetailViewDFLink';
		let URL_TARGET       : string  = '';

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
				URL_TARGET        = Sql.ToString (layout.URL_TARGET);
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				if ( row != null )
				{
					// 06/18/2018 Paul.  Don't convert to string here as the old code is using undefined in its checks. 
					DATA_VALUE = row[DATA_FIELD];
					URL_VALUE  = Sql.ToString(row[URL_FIELD]);
					if ( StartsWith(URL_FORMAT, 'mailto:') && !Sql.IsEmptyString(URL_VALUE) )
					{
						URL = URL_FORMAT.replace('{0}', URL_VALUE);
					}
					// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
					if ( DATA_VALUE == null && this.ERASED_FIELDS.indexOf(DATA_FIELD) >= 0 )
					{
						ERASED = true;
					}
					// 09/27/2020 Paul.  Processes.DetailView exception. 
					if ( DATA_FIELD == 'PARENT_NAME' && URL_FIELD == 'PARENT_TYPE PARENT_ID' && URL_FORMAT == '~/{0}/view.aspx?ID={1}' )
					{
						DISPLAY_NAME = Sql.ToString(row['PARENT_NAME']);
						MODULE_NAME  = Sql.ToString(row['PARENT_TYPE']);
						URL_VALUE    = Sql.ToString(row['PARENT_ID'  ]);
						URL = '/Reset/' + MODULE_NAME + '/View/' + URL_VALUE;
					}
					// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
					// 03/03/2021 Paul.  URL_FORMAT and DATA_FORMAT will not be null because of Sql.ToString() use above. 
					else if ( !ERASED && (DATA_VALUE != null || DATA_VALUE === undefined) && !Sql.IsEmptyString(URL_FORMAT) && !Sql.IsEmptyString(DATA_FORMAT) )
					{
						let a = null;
						if ( URL_FORMAT.substr(0, 2) == '~/' )
						{
							let arrURL_FORMAT   = URL_FORMAT.split('/');
							let URL_MODULE_NAME = MODULE_NAME;
							if ( arrURL_FORMAT.length > 1 )
							{
								URL_MODULE_NAME = arrURL_FORMAT[1];
								// 11/11/2020 Paul.  Correct for admin links. 
								if ( URL_MODULE_NAME == 'Administration' && arrURL_FORMAT.length > 2 )
									URL_MODULE_NAME = arrURL_FORMAT[2];
							}
							if ( URL_MODULE_NAME == 'Parents' )
							{
								URL_MODULE_NAME = row[DATA_LABEL];
							}
							MODULE_NAME     = URL_MODULE_NAME;
							// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
							//oDetailViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, ID, function(status, message)
							// 04/20/2020 Paul.  Link may be to a file download. 
							// 09/27/2020 Paul.  Parents link should not be treated as a download. 
							if ( URL_MODULE_NAME == 'Parents' )
							{
								URL = '/Reset/' + URL_MODULE_NAME + '/View/' + URL_VALUE;
							}
							// 09/27/2020 Paul.  There are a number of module links that need to be converted to a React route. 
							else if ( URL_FORMAT.indexOf('/view.aspx?ID={0}') > 0 )
							{
								if ( URL_FORMAT.indexOf('ArchiveView=1') > 0 )
								{
									URL = URL_FORMAT.replace('/view.aspx?ID={0}', '/ArchiveView/' + URL_VALUE);
								}
								else
								{
									URL = URL_FORMAT.replace('/view.aspx?ID={0}', '/View/' + URL_VALUE);
								}
								if ( URL_FORMAT.indexOf('~/Administration/') >= 0 )
								{
									URL = URL.replace('~/Administration', '/Reset/Administration');
								}
								else
								{
									URL = URL.replace('~/', '/Reset/');
								}
							}
							// 09/27/2020 Paul.  QuickBooks links. 
							else if ( URL_FORMAT.indexOf('/view.aspx?QID={0}') > 0 )
							{
								URL = URL_FORMAT.replace('/view.aspx?ID={0}', '/View/' + URL_VALUE);
							}
							else if ( URL_FORMAT.indexOf('/edit.aspx?PARENT_ID={0}') > 0 )
							{
								URL = '/Reset/' + URL_MODULE_NAME + '/Edit/?PARENT_ID=' + URL_VALUE;
							}
							else if ( URL_FORMAT.indexOf('.aspx') > 0 )
							{
								URL = URL_FORMAT.replace('~/', Credentials.RemoteServer);
								URL = URL.replace('{0}', URL_VALUE);
							}
							else
							{
								URL = '/Reset/' + URL_MODULE_NAME + '/View/' + URL_VALUE;
							}
						}
						else if ( URL_FORMAT.indexOf('view.aspx?ID={0}') > 0 )
						{
							URL = '/Reset/' + MODULE_NAME + '/View/' + URL_VALUE;
						}
						else
						{
							URL = URL_FORMAT.replace('{0}', URL_VALUE);
						}
						// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
						if ( DATA_VALUE !== undefined )
						{
							DISPLAY_NAME = DATA_FORMAT.replace('{0}', DATA_VALUE);
						}
					}
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, URL);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
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
		this.MODULE_TYPE  = MODULE_TYPE ;
		this.URL          = URL         ;
		this.DISPLAY_NAME = DISPLAY_NAME;
		this.ERASED       = ERASED      ;
		this.CSS_CLASS    = CSS_CLASS   ;
		this.URL_TARGET   = URL_TARGET  ;
	}

	async ngAfterViewInit()
	{
		const { row, DATA_FIELD, DATA_VALUE, DATA_FORMAT, URL_FORMAT, URL_VALUE, MODULE_NAME, MODULE_TYPE, ERASED } = this;
		// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
		// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
		if ( !ERASED && (DATA_VALUE != null || DATA_VALUE === undefined) && !Sql.IsEmptyString(URL_FORMAT) && !Sql.IsEmptyString(DATA_FORMAT) )
		{
			// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
			if ( DATA_VALUE === undefined && !Sql.IsEmptyString(URL_VALUE) )
			{
				try
				{
					let value = await this.Crm_Modules.ItemName(MODULE_NAME, URL_VALUE);
					let sDISPLAY_NAME: string = '';
					if ( Sql.IsEmptyString(DATA_FORMAT) )
					{
						sDISPLAY_NAME = value;
					}
					else
					{
						sDISPLAY_NAME = DATA_FORMAT.replace('{0}', value);
					}
					this.DISPLAY_NAME = sDISPLAY_NAME;
				}
				catch(error: any)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngAfterViewInit', error);
					// 05/20/2018 Paul.  When an error is encountered, we display the error in the name. 
					// 11/17/2021 Paul.  Must use message text and not error object. 
					this.DISPLAY_NAME = error.message;
				}
			}
			// 11/29/2021 Paul.  When MODULE_TYPE is specified, then DISPLAY_NAME will be a lookup. 
			else if ( !Sql.IsEmptyString(MODULE_TYPE) && !Sql.IsEmptyString(row[DATA_FIELD]) )
			{
				try
				{
					let value = await this.Crm_Modules.ItemName(MODULE_TYPE, row[DATA_FIELD]);
					let sDISPLAY_NAME: string = '';
					if ( Sql.IsEmptyString(DATA_FORMAT) )
					{
						sDISPLAY_NAME = value;
					}
					else
					{
						sDISPLAY_NAME = DATA_FORMAT.replace('{0}', value);
					}
					this.DISPLAY_NAME = sDISPLAY_NAME;
				}
				catch(error: any)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngAfterViewInit', error);
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
