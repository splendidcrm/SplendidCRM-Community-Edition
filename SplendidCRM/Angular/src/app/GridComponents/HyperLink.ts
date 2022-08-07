import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import { StartsWith                                                } from '../scripts/utility'           ;
import Sql                                                           from '../scripts/Sql'               ;

import MODULE                                                        from '../types/MODULE'              ;

import { SplendidGridComponentBase                                 } from '../GridComponents/SplendidGridComponentBase';

@Component({
	selector: 'SplendidGridHyperLink',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for FIELD_INDEX {{ layout.FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyUrl()">
		<span>URL_FIELD is empty for FIELD_INDEX {{ layout.FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<ng-container *ngIf="!hasHyperLinkCallback">
			<a [id]="ID" [class]="CSSCLASS" (click)="_onClick($event)" style="cursor: pointer">{{ DISPLAY_NAME }}</a>
		</ng-container>
		<ng-container *ngIf="hasHyperLinkCallback">
			<a [id]="ID" [class]="CSSCLASS" (click)="_onClickCallback($event)" style="cursor: pointer">{{ DISPLAY_NAME }}</a>
		</ng-container>
	</ng-container>`
})
export class SplendidGridHyperLinkComponent extends SplendidGridComponentBase implements OnInit
{
	public ID               : string = null;
	public URL_FIELD        : string = null;
	public URL_MODULE       : string = null;
	public URL_VALUE        : string = null;
	// 11/29/2021 Paul.  When MODULE_TYPE is specified, then DISPLAY_NAME will be a lookup. 
	public MODULE_TYPE      : string = null;
	// 11/29/2021 Paul.  We need to allow Erased Pill. 
	public DISPLAY_NAME     : any    = null;
	public URL              : string = null;
	public CSSCLASS         : string = null;

	@Input()  hasHyperLinkCallback   : boolean = false;
	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	@Output() hyperLinkCallback      : EventEmitter<{MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}> = new EventEmitter<{MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}>();

	public IsEmptyUrl(): boolean
	{
		return this.layout != null && !Sql.IsEmptyString(this.DATA_FIELD) && Sql.IsEmptyString(this.URL_FIELD);
	}

	public IsVisible(): boolean
	{
		return this.layout != null && !Sql.IsEmptyString(this.DATA_FIELD) && !Sql.IsEmptyString(this.URL_FIELD);
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules, Formatting);
	}

	ngOnInit()
	{
		const { layout, row, SplendidCache, L10n, Crm_Config } = this;
		let ID          : string = '';
		let DATA_FIELD  : string = '';
		let URL_FIELD   : string = '';
		let URL_MODULE  : string = '';
		let URL_VALUE   : string = '';
		let URL_FORMAT  : string = '';
		let MODULE_TYPE : string = '';
		let DISPLAY_NAME: any    = '';
		let URL         : string = '';
		let CSSCLASS    : string = '';
		let QUERY_PARAMS: string = '';
		try
		{
			const { layout, row } = this;
			if ( layout != null )
			{
				DATA_FIELD        = Sql.ToString(layout.DATA_FIELD);
				URL_FIELD         = Sql.ToString(layout.URL_FIELD );
				URL_FORMAT        = Sql.ToString(layout.URL_FORMAT);
				URL_MODULE        = Sql.ToString(layout.URL_MODULE);
				MODULE_TYPE       = Sql.ToString(layout.MODULE_TYPE);
				CSSCLASS          = Sql.ToString(layout.ITEMSTYLE_CSSCLASS);
				// 04/28/2019 Paul.  A popup hyperlink will look like SelectAccount('{0}', '{1}');
				if ( URL_FIELD.indexOf(' ') > 0 )
				{
					let arrURL_FIELD: string[] = URL_FIELD.split(' ');
					URL_FIELD = arrURL_FIELD[0];
					// 11/20/2019 Paul.  Add additional parameters. 
					if ( row )
					{
						for ( let i = 1; i < arrURL_FIELD.length; i++ )
						{
							if ( row[arrURL_FIELD[i]] != null )
							{
								if ( QUERY_PARAMS.length > 0 )
								{
									QUERY_PARAMS += '&';
								}
								QUERY_PARAMS += arrURL_FIELD[i]  + '=' + encodeURIComponent(row[arrURL_FIELD[i]]);
							}
						}
					}
				}
				// 12/03/2019 Paul.  We need to separate out non-field parameters, such as ArchiveView=1. 
				if ( !Sql.IsEmptyString(URL_FORMAT) && URL_FORMAT.indexOf('?') > 0 )
				{
					let arrURL_FORMAT: string[] = URL_FORMAT.split('?')[1].split('&');
					for ( let i = 0; i < arrURL_FORMAT.length; i++ )
					{
						let arrNameValue = arrURL_FORMAT[i].split('=');
						if ( arrNameValue.length > 1 )
						{
							if ( arrNameValue[1].indexOf('{') < 0 )
							{
								if ( QUERY_PARAMS.length > 0 )
								{
									QUERY_PARAMS += '&';
								}
								QUERY_PARAMS += arrNameValue[0] + '=' + arrNameValue[1];
							}
						}
					}
				}
				if ( row )
				{
					URL_VALUE = Sql.ToGuid(row[URL_FIELD]);
					if ( StartsWith(URL_FORMAT, '~/') )
					{
						let arrURL = URL_FORMAT.split('/');
						if ( arrURL.length > 1 )
						{
							URL_MODULE = arrURL[1];
							// 10/12/2020 Paul.  Correct for admin modules. 
							if ( arrURL.length > 2 )
							{
								// 02/09/2021 Paul.  Users module has sub folders, but so do others, so lookup second item. 
								if ( URL_MODULE == 'Administration' )
								{
									URL_MODULE = arrURL[2];
									// 08/18/2021 Paul.  Correct for Azure folder. 
									if ( URL_MODULE == 'Azure' && arrURL.length > 3 )
									{
										URL_MODULE = arrURL[3];
									}
								}
								// 06/17/2022 Paul.  {0} is a clear indicator that not a module. 
								else if ( arrURL[2].indexOf('{0}') < 0 )
								{
									let module: MODULE  = SplendidCache.Module(arrURL[2], this.constructor.name + '.constructor');
									if ( module != null )
									{
										URL_MODULE = arrURL[2];
									}
								}
							}
						}
					}
					// 12/01/2012 Paul.  For activities lists, we need to convert the activity to the base module. 
					if ( URL_MODULE == 'Activities' && row['ACTIVITY_TYPE'] !== undefined )
					{
						URL_MODULE = row['ACTIVITY_TYPE'];
					}
					// 08/06/2020 Paul.  Activities with {0} should be treated as activity type. 
					if ( URL_MODULE == '{0}' && row['ACTIVITY_TYPE'] !== undefined )
					{
						URL_MODULE = row['ACTIVITY_TYPE'];
						if ( StartsWith(QUERY_PARAMS, 'ID=') )
						{
							URL_VALUE = Sql.ToGuid(row['ID']);
							QUERY_PARAMS = '';
						}
					}
					if ( URL_FORMAT.indexOf('view.aspx?') > 0 )
					{
						// 03/31/2021 Paul.  Value may be null. 
						if ( URL_VALUE != null )
						{
							// 10/20/2017 Paul.  Need the Sql.To*() functions. 
							ID = 'aMain_' + URL_VALUE.replace('-', '_');
							if ( URL_FORMAT.indexOf('/Administration/') > 0 )
							{
								URL = '/Administration/' + escape(URL_MODULE) + '/View/' + URL_VALUE;
							}
							else
							{
								URL = '/' + escape(URL_MODULE) + '/View/' + URL_VALUE;
							}
							if ( !Sql.IsEmptyString(QUERY_PARAMS) )
							{
								URL += '?' + QUERY_PARAMS;
							}
						}
					}
					else if ( URL_FORMAT.indexOf('edit.aspx?') > 0 )
					{
						// 03/31/2021 Paul.  Value may be null. 
						if ( URL_VALUE != null )
						{
							// 10/20/2017 Paul.  Need the Sql.To*() functions. 
							ID = 'aMain_' + URL_VALUE.replace('-', '_');
							if ( URL_FORMAT.indexOf('/Administration/') > 0 )
							{
								URL = '/Administration/' + escape(URL_MODULE) + '/Edit/' + URL_VALUE;
							}
							else
							{
								URL = '/' + escape(URL_MODULE) + '/Edit/' + URL_VALUE;
							}
							if ( !Sql.IsEmptyString(QUERY_PARAMS) )
							{
								URL += '?' + QUERY_PARAMS;
							}
						}
					}
					// 08/31/2014 Paul.  The offline client needs a way to jump to the module list. 
					else if ( URL_FORMAT.indexOf('Conflicts/default.aspx') > 0 && row[URL_FIELD] !== undefined )
					{
						URL_MODULE = row[URL_FIELD];
						URL        = '/' + escape(URL_MODULE) + '/ConflictView';
					}
					else if ( URL_FORMAT.indexOf('default.aspx') > 0 && row[URL_FIELD] !== undefined )
					{
						URL_MODULE = row[URL_FIELD];
						if ( URL_FORMAT.indexOf('/Administration/') > 0 )
						{
							URL = '/Administration/' + escape(URL_MODULE) + '/List';
						}
						else
						{
							URL = '/' + escape(URL_MODULE) + '/List';
						}
					}
					else if ( StartsWith(URL_FORMAT, 'Select') )
					{
						// 08/07/2019 Paul.  I don't think we need to do anything special if this is a selection popup. 
					}
					// 11/29/2021 Paul.  Old layouts may not use URL_FORMAT. 
					else if ( Sql.IsEmptyString(URL_FORMAT) && Sql.IsEmptyString(URL_MODULE) && !Sql.IsEmptyString(MODULE_TYPE) )
					{
						URL        = '/' + MODULE_TYPE + '/View/' + row[DATA_FIELD];
						URL_FIELD  = DATA_FIELD;
					}
					else
					{
						// 02/14/2020 Paul.  We need to specify something so that the display value gets underlined. 
						URL = '#';
					}
				}
				// 02/14/2020 Paul.  Allow the DISPLAY_NAME even if no URL_FIELD. 
				if ( row )
				{
					// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
					if (row[DATA_FIELD] === undefined && !Sql.IsEmptyString(row[URL_FIELD]))
					{
						// 07/04/2019 Paul.  DISPLAY_NAME will be loaded in componentDidMount() 
						//sDISPLAY_NAME = React.createElement(ItemName, { MODULE_NAME: sURL_MODULE, ID: row[sURL_FIELD] });
					}
					else if (row[DATA_FIELD] !== undefined)
					{
						// 08/24/2014 Paul.  WinRT does not like to add text with angle brackets. 
						// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
						DISPLAY_NAME = Sql.ReplaceEntities(row[DATA_FIELD]);
						// 11/28/2021 Paul.  Field may be erased. 
						if ( Sql.IsDataPrivacyErasedField(Crm_Config, row, DATA_FIELD) )
						{
							DISPLAY_NAME = Sql.DataPrivacyErasedPillElement(L10n);
						}
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + URL_MODULE + ' ' + DATA_FIELD, URL);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.ID           = ID          ;
		this.DATA_FIELD   = DATA_FIELD  ;
		this.URL_FIELD    = URL_FIELD   ;
		this.URL_MODULE   = URL_MODULE  ;
		this.URL_VALUE    = URL_VALUE   ;
		this.MODULE_TYPE  = MODULE_TYPE ;
		this.DISPLAY_NAME = DISPLAY_NAME;
		this.URL          = URL         ;
		this.CSSCLASS     = CSSCLASS    ;
	}

	public _onClickCallback = (e: any) =>
	{
		const { row, hyperLinkCallback } = this;
		const { URL_MODULE, URL_VALUE, DISPLAY_NAME, URL } = this;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClickCallback ' + URL_MODULE, URL_VALUE);
		e.preventDefault();
		// 03/11/2021 Paul.  view.aspx?ID={0} without any relative path is converted to'#'.  Null so that navigation goes to module url. 
		let sURL: string = URL;
		if ( sURL == '#' )
			sURL = null;
		// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink.
		hyperLinkCallback.emit({MODULE_NAME: URL_MODULE, ID: URL_VALUE, NAME: DISPLAY_NAME, URL: sURL, row: row});
		return false;
	}

	public _onClick(e: any)
	{
		const { router } = this;
		const { URL_MODULE, URL_VALUE, DISPLAY_NAME, URL } = this;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClick', URL);
		e.preventDefault();
		if ( StartsWith(URL, '/') )
			router.navigateByUrl('/Reset' + URL);
		else
			router.navigateByUrl(URL);
		return false;
	}

}
