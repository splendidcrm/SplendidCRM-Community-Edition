import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import { NormalizeDescription                                      } from '../scripts/EmailUtils'        ;
import Sql                                                           from '../scripts/Sql'               ;

import { SplendidGridComponentBase                                 } from '../GridComponents/SplendidGridComponentBase';

@Component({
	selector: 'SplendidGridString',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for FIELD_INDEX {{ layout.FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<ng-container *ngIf="html">
			<div [innerHTML]="DATA_VALUE"></div>
		</ng-container>
		<ng-container *ngIf="!html">
			<div>{{ DATA_VALUE }}</div>
		</ng-container>
	</ng-container>`
})
export class SplendidGridStringComponent extends SplendidGridComponentBase implements OnInit
{
	@Input()  multiLine     : boolean  = false;
	@Input()  html          : boolean  = false;

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules, Formatting);
	}

	ngOnInit()
	{
		const { layout, row, html } = this;
		const { SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules, Formatting } = this;
		// 08/21/2022 Paul.  Don't swap TEAM_SET_NAME on Users.Teams panel.
		let GRID_NAME  : string = Sql.ToString(layout.GRID_NAME  );
		let DATA_FIELD : string = Sql.ToString(layout.DATA_FIELD );
		let DATA_LABEL : string = Sql.ToString(layout.DATA_LABEL );
		let DATA_FORMAT: string = Sql.ToString(layout.DATA_FORMAT);
		let DATA_VALUE : string = '';
		if ( row )
		{
			if ( row[DATA_FIELD] != null )
			{
				// 12/01/2012 Paul.  The activity status needs to be dynamically converted to the correct list. 
				let LIST_NAME = layout.LIST_NAME;
				if ( LIST_NAME == 'activity_status' )
				{
					let sACTIVITY_TYPE = row['ACTIVITY_TYPE'];
					switch ( sACTIVITY_TYPE )
					{
						case 'Tasks':
							LIST_NAME = 'task_status_dom';
							DATA_VALUE = L10n.ListTerm(LIST_NAME, row[DATA_FIELD]);
							break;
						case 'Meetings':
							LIST_NAME = 'meeting_status_dom';
							DATA_VALUE = L10n.ListTerm(LIST_NAME, row[DATA_FIELD]);
							break;
						case 'Calls':
							// 07/15/2006 Paul.  Call status is translated externally. 
							DATA_VALUE = L10n.ListTerm('call_direction_dom', row['DIRECTION']) + ' ' + L10n.ListTerm('call_status_dom', row['STATUS']);
							break;
						case 'Notes':
							// 07/15/2006 Paul.  Note Status is not normally as it does not have a status. 
							DATA_VALUE = L10n.Term('.activity_dom.Note');
							break;
						// 06/15/2006 Paul.  This list name for email_status does not follow the standard. 
						case 'Emails':
							LIST_NAME = 'dom_email_status';
							DATA_VALUE = L10n.ListTerm(LIST_NAME, row[DATA_FIELD]);
							break;
						// 04/21/2006 Paul.  If the activity does not have a status (such as a Note), then use activity_dom. 
						default:
							LIST_NAME = 'activity_dom';
							DATA_VALUE = L10n.ListTerm(LIST_NAME, row[DATA_FIELD]) + '[' + sACTIVITY_TYPE + ']';
							break;
					}
				}
				else if ( LIST_NAME != null )
				{
					// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
					DATA_VALUE = L10n.ListTerm(LIST_NAME, row[DATA_FIELD]);
				}
				else
				{
					// 04/03/2021 Paul.  Dynamic Teams must be managed here as well as in SplendidGrid. 
					if ( (DATA_FIELD == 'TEAM_NAME' || DATA_FIELD == 'TEAM_SET_NAME') )
					{
						let bEnableTeamManagement = Crm_Config.enable_team_management();
						if ( bEnableTeamManagement )
						{
							let bEnableDynamicTeams = Crm_Config.enable_dynamic_teams();
							// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
							// 04/03/2021 Paul.  Apply single rule. 
							// 08/21/2022 Paul.  Don't swap TEAM_SET_NAME on Users.Teams panel.
							if ( bEnableDynamicTeams && DATA_FORMAT != '1' && DATA_FORMAT.toLowerCase().indexOf('single') < 0 && GRID_NAME.indexOf('.Teams') < 0 )
							{
								DATA_LABEL = '.LBL_TEAM_SET_NAME';
								DATA_FIELD = 'TEAM_SET_NAME'     ;
							}
							else
							{
								DATA_LABEL = '.LBL_TEAM_NAME';
								DATA_FIELD = 'TEAM_NAME'     ;
							}
						}
					}
					// 04/03/2021 Paul.  Dynamic Assignment must be managed here as well as in SplendidGrid. 
					else if ( DATA_FIELD == "ASSIGNED_TO" || DATA_FIELD == "ASSIGNED_TO_NAME" || DATA_FIELD == "ASSIGNED_SET_NAME" )
					{
						// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						let bEnableDynamicAssignment = Crm_Config.enable_dynamic_assignment();
						if ( bEnableDynamicAssignment && DATA_FORMAT.toLowerCase().indexOf('single') < 0 )
						{
							DATA_LABEL = ".LBL_LIST_ASSIGNED_SET_NAME";
							DATA_FIELD = "ASSIGNED_SET_NAME";
						}
						else if ( DATA_FIELD == "ASSIGNED_SET_NAME" )
						{
							DATA_LABEL = ".LBL_LIST_ASSIGNED_USER";
							DATA_FIELD = "ASSIGNED_TO_NAME";
						}
					}
					// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
					DATA_VALUE = row[DATA_FIELD]
					if ( typeof(DATA_VALUE) == 'string' && DATA_VALUE.substr(0, 7) == '\\/Date(' )
					{
						// 08/18/2019 Paul.  We only get here if DATA_FORMAT is null, so in that case we use full date time. 
						DATA_VALUE = Formatting.FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
					}
					else if ( this.multiLine )
					{
						// 05/20/2009 Paul.  We need a way to preserve CRLF in description fields. 
						// 06/04/2010 Paul.  Try and prevent excess blank lines. 
						DATA_VALUE = NormalizeDescription(DATA_VALUE);
					}
					// 05/27/2020 Paul.  false value is displaying nothing. 
					else if ( typeof(DATA_VALUE) == 'boolean' )
					{
						DATA_VALUE = L10n.ListTerm('truefalse_dom', (DATA_VALUE ? '1' : '0'));
					}
					// 10/29/2020 Paul.  Allow numbers to be formatted. Most common is {0:N2}. 
					else if ( typeof(DATA_VALUE) == 'number' )
					{
						let oNumberFormat = Security.NumberFormatInfo();
						// 11/10/2020 Paul.  correct number issues. 
						if ( DATA_FORMAT.indexOf('{0:N') >= 0 )
						{
							DATA_FORMAT = DATA_FORMAT.replace('{0:N', '').replace('}', '');
							// 02/21/2022 Paul.  isNumber is defined in jQuery.  use !isNaN() instead. 
							if ( !isNaN(parseInt(DATA_FORMAT)) )
							{
								oNumberFormat.CurrencyDecimalDigits = parseInt(DATA_FORMAT);
							}
						}
						// 03/17/20201 Paul.  F is the ASP.NET way to format a decimal.  It is used in Currencies.ListView. 
						else if ( DATA_FORMAT.indexOf('{0:F') >= 0 )
						{
							DATA_FORMAT = DATA_FORMAT.replace('{0:F', '').replace('}', '');
							// 02/21/2022 Paul.  isNumber is defined in jQuery.  use !isNaN() instead. 
							if ( !isNaN(parseInt(DATA_FORMAT)) )
							{
								oNumberFormat.CurrencyDecimalDigits = parseInt(DATA_FORMAT);
							}
						}
						DATA_VALUE = Formatting.formatNumber(DATA_VALUE, oNumberFormat);
					}
					// 03/27/2021 Paul.  Treat string as html. 
					else if ( html )
					{
						// 03/27/2021 Paul.  Do not replace entities as string will be raw html. 
					}
					else
					{
						DATA_VALUE = Sql.ReplaceEntities(DATA_VALUE);
					}
				}
			}
		}
		this.DATA_FIELD = DATA_FIELD;
		this.DATA_VALUE = DATA_VALUE;
	}

}
