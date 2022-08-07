import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import Sql                                                           from '../scripts/Sql'               ;

import { SplendidGridComponentBase                                 } from '../GridComponents/SplendidGridComponentBase';

@Component({
	selector: 'SplendidGridLinkButton',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for FIELD_INDEX {{ layout.FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<a href='#' (click)="_onClick($event)" style="cursor: pointer">{{ DISPLAY_NAME }}</a>
	</ng-container>`
})
export class SplendidGridLinkButtonComponent extends SplendidGridComponentBase implements OnInit
{
	public URL_FIELD        : string = null;
	public URL_FORMAT       : string = null;
	public URL_TARGET       : string = null;
	public URL_VALUE        : string = null;
	public DISPLAY_NAME     : string = null;

	@Output() Page_Command      : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules, Formatting);
	}

	ngOnInit()
	{
		const { layout, row } = this;
		let DATA_FIELD  : string = '';
		let URL_FIELD   : string = '';
		let URL_FORMAT  : string = '';
		let URL_TARGET  : string = '';
		let URL_VALUE   : string = '';
		let DISPLAY_NAME: string = '';
		try
		{
			const { layout, row } = this;
			if ( layout != null )
			{
				DATA_FIELD = Sql.ToString(layout.DATA_FIELD);
				URL_FIELD  = Sql.ToString(layout.URL_FIELD );
				URL_FORMAT = Sql.ToString(layout.URL_FORMAT);
				URL_TARGET = Sql.ToString(layout.URL_TARGET);
				URL_VALUE  = URL_FORMAT;
				if ( row )
				{
					if ( URL_FIELD.indexOf(' ') > 0 || URL_VALUE.indexOf('{') >= 0 )
					{
						let arrURL_FIELD: string[] = URL_FIELD.split(' ');
						for ( let nFormatIndex = 0; nFormatIndex < arrURL_FIELD.length; nFormatIndex++ )
						{
							URL_VALUE = URL_VALUE.replace('{' + nFormatIndex.toString() + '}', Sql.ToString(row[arrURL_FIELD[nFormatIndex]]));
						}
					}
					else
					{
						URL_VALUE = Sql.ToString(row[URL_FIELD]);
					}
					if (row[DATA_FIELD] !== undefined)
					{
						DISPLAY_NAME = Sql.ReplaceEntities(row[DATA_FIELD]);
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + URL_MODULE + ' ' + DATA_FIELD, URL);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.DATA_FIELD   = DATA_FIELD  ;
		this.URL_FIELD    = URL_FIELD   ;
		this.URL_TARGET   = URL_TARGET  ;
		this.URL_FORMAT   = URL_FORMAT  ;
		this.URL_VALUE    = URL_VALUE   ;
		this.DISPLAY_NAME = DISPLAY_NAME;
	}

	public _onClick = (e: any) =>
	{
		const { row, layout, Page_Command } = this;
		const { URL_TARGET, URL_VALUE } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClick ' + URL_TARGET, URL_VALUE);
		e.preventDefault();
		Page_Command.emit({sCommandName: URL_TARGET, sCommandArguments: URL_VALUE});
		return false;
	}

}
