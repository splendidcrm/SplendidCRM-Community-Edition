import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                    ;
import { Router, ActivatedRoute, ParamMap                          } from '@angular/router'                  ;
import { faArrowRight                                              } from '@fortawesome/free-solid-svg-icons';

import { SplendidRequestService                                    } from '../scripts/SplendidRequest'       ;
import { SplendidCacheService                                      } from '../scripts/SplendidCache'         ;
import { CredentialsService                                        } from '../scripts/Credentials'           ;
import { SecurityService                                           } from '../scripts/Security'              ;
import { L10nService                                               } from '../scripts/L10n'                  ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'                   ;
import { FormattingService                                         } from '../scripts/Formatting'            ;

import Sql                                                           from '../scripts/Sql'                   ;

@Component({
	selector: 'ExportHeader',
	templateUrl: './ExportHeader.html',
})
export class ExportHeaderComponent implements OnInit
{
	// IExportHeaderState
	public EXPORT_RANGE                   : string  = null;
	public EXPORT_FORMAT                  : string  = null;
	public EXPORT_RANGE_LIST              : any[]   = [];
	public EXPORT_FORMAT_LIST             : any[]   = [];
	public bPhoneBurnerEnabled            : boolean = null;
	public lblPhoneBurnerAuthorizedStatus : string  = null;
	public dtPhoneBurnerOAuthExpiresAt    : Date    = null;
	public sMODULE_TITLE                  : string  = null;
	public now                            : Date    = null;
	public arrowRight                               = faArrowRight;

	@Input()  MODULE_NAME        : string  = null;
	// 01/29/2021 Paul.  EditCustomFields does not require range or format. 
	@Input()  hideRange          : boolean;
	@Input()  hideFormat         : boolean;
	// 03/18/2021 Paul.  Lists without selection checkboxes should not allow Selected option. 
	@Input()  disableSelected    : boolean;

	@Output() onExport           : EventEmitter<{EXPORT_RANGE: string, EXPORT_FORMAT: string}> = new EventEmitter<{EXPORT_RANGE: string, EXPORT_FORMAT: string}>();
	@Output() Page_Command       : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();

	constructor(public router: Router, private route: ActivatedRoute, private SplendidRequest: SplendidRequestService, public SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, public Security: SecurityService, public L10n: L10nService, public Crm_Config: CrmConfigService, private Crm_Modules: CrmModulesService, public Formatting: FormattingService)
	{
	}

	async ngOnInit()
	{
		const { route, Credentials, L10n, Crm_Config } = this;
		const { MODULE_NAME } = this;
		let EXPORT_RANGE_LIST : any[] = [];
		let EXPORT_FORMAT_LIST: any[] = [];

		EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_ENTIRE'  ), NAME: 'All'     });
		EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_CURRENT' ), NAME: 'Page'    });
		// 03/18/2021 Paul.  Lists without selection checkboxes should not allow Selected option. 
		if ( !this.disableSelected )
			EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_SELECTED'), NAME: 'Selected'});
		
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_XML_SPREADSHEET'  ), NAME: 'Excel'   });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_XML'              ), NAME: 'xml'     });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_CUSTOM_CSV'       ), NAME: 'csv'     });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_CUSTOM_TAB'       ), NAME: 'tab'     });
		
		this.EXPORT_RANGE                  = 'All'  ;
		this.EXPORT_FORMAT                 = 'Excel';
		this.EXPORT_RANGE_LIST             = EXPORT_RANGE_LIST;
		this.EXPORT_FORMAT_LIST            = EXPORT_FORMAT_LIST;
		this.bPhoneBurnerEnabled           = Crm_Config.ToBoolean('PhoneBurner.Enabled') && !Sql.IsEmptyString(Crm_Config.ToString('PhoneBurner.ClientID')) && (MODULE_NAME == Crm_Config.ToString('PhoneBurner.SyncModules'));
		this.lblPhoneBurnerAuthorizedStatus= null;
		this.dtPhoneBurnerOAuthExpiresAt   = Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT;
		this.sMODULE_TITLE                 = L10n.Term(MODULE_NAME + '.LBL_LIST_FORM_TITLE');
		this.now                           = new Date();

		try
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT);
			if ( this.bPhoneBurnerEnabled )
			{
				let dtPhoneBurnerOAuthExpiresAt = Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT;
				if ( !Sql.IsEmptyString(route.snapshot.queryParamMap.get('error')) )
				{
					this.lblPhoneBurnerAuthorizedStatus = route.snapshot.queryParamMap.get('error');
				}
				else if ( !Sql.IsEmptyString(route.snapshot.queryParamMap.get('code')) )
				{
					let code: string = route.snapshot.queryParamMap.get('code');
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem code', AUTHORIZATION_CODE);
					// 09/12/2020 Paul.  React does not have a good way to expose a method, so just redirect with the code in the url. 
					let sREDIRECT_URL   : string = Credentials.sREMOTE_SERVER + 'Administration/PhoneBurner/OAuthLanding.aspx'
					let obj: any =
					{
						code        ,
						redirect_url: sREDIRECT_URL, // (window.location.origin + window.location.pathname)
					};
					// 11/09/2019 Paul.  We cannot use ADAL because we are using the response_type=code style of authentication (confidential) that ADAL does not support. 
					let sBody: string = JSON.stringify(obj);
					let json: any = await this.SplendidRequest.CreateSplendidRequest('Administration/PhoneBurner/Rest.svc/GetAccessToken', 'POST', 'application/octet-stream', sBody);
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount token', json);
					dtPhoneBurnerOAuthExpiresAt = this.Formatting.FromJsonDate(json.d.expires_at);
					Credentials.SetPHONEBURNER_TOKEN_EXPIRES_AT(dtPhoneBurnerOAuthExpiresAt);
					this.dtPhoneBurnerOAuthExpiresAt    = dtPhoneBurnerOAuthExpiresAt;
					this.lblPhoneBurnerAuthorizedStatus = '';
					this.router.navigateByUrl('/' + MODULE_NAME);
				}
				// 09/17/2020 Paul.  We should find a way to avoid making this query every time. 
				// Wasted cycles if PhoneBurner is enabled but this user is not a member. 
				else if ( Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT == null || Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT < (new Date()) )
				{
					let json: any = await this.SplendidRequest.CreateSplendidRequest('Administration/PhoneBurner/Rest.svc/IsAuthenticated', 'POST', 'application/json; charset=utf-8', null);
					if ( !Sql.IsEmptyString(json.d) )
					{
						dtPhoneBurnerOAuthExpiresAt = this.Formatting.FromJsonDate(json.d);
						Credentials.SetPHONEBURNER_TOKEN_EXPIRES_AT(dtPhoneBurnerOAuthExpiresAt);
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', dtPhoneBurnerOAuthExpiresAt);
						this.dtPhoneBurnerOAuthExpiresAt = dtPhoneBurnerOAuthExpiresAt;
					}
				}
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.lblPhoneBurnerAuthorizedStatus = error.message;
		}
	}

	ngDoCheck() : void
	{
		this.now = new Date();
	}

	public _onEXPORT_RANGE_Change(event: any)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEXPORT_RANGE_Change', event.target.value);
		this.EXPORT_RANGE = event.target.value;
	}

	public _onEXPORT_FORMAT_Change(event: any)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEXPORT_FORMAT_Change', event.target.value);
		this.EXPORT_FORMAT = event.target.value;
	}

	public async _onExport()
	{
		const { EXPORT_RANGE, EXPORT_FORMAT } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onExport', EXPORT_RANGE, EXPORT_FORMAT);
		this.onExport.emit({EXPORT_RANGE, EXPORT_FORMAT});
	}

	public async _onAuthorize()
	{
		const { Credentials, Crm_Config } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onAuthorize');
		try
		{
			let OAUTH_CLIENT_ID : string = Crm_Config.ToString('PhoneBurner.ClientID');
			// 09/12/2020 Paul.  React does not have a good way to expose a method, so just redirect with the code in the url. 
			let sREDIRECT_URL   : string = Credentials.sREMOTE_SERVER + 'Administration/PhoneBurner/OAuthLanding.aspx'
			let authenticateUrl : string = 'https://www.phoneburner.com/oauth/index?client_id=' + OAUTH_CLIENT_ID + '&redirect_uri=' + sREDIRECT_URL + '&response_type=code';
			window.open(authenticateUrl, 'PhoneBurnerPopup', 'width=830,height=830,status=1,toolbar=0,location=0,resizable=1');
		}
		catch(error: any)
		{
			this.lblPhoneBurnerAuthorizedStatus = error.message;
		}
	}

	public async _onBeginDial()
	{
		const { MODULE_NAME, Credentials } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBeginDial');
		let dtPhoneBurnerOAuthExpiresAt = Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT;
		try
		{
			if ( Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT == null || Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT < (new Date()) )
			{
				let json: any = await this.SplendidRequest.CreateSplendidRequest('Administration/PhoneBurner/Rest.svc/IsAuthenticated', 'POST', 'application/json; charset=utf-8', null);
				if ( !Sql.IsEmptyString(json.d) )
				{
					dtPhoneBurnerOAuthExpiresAt = this.Formatting.FromJsonDate(json.d);
					Credentials.SetPHONEBURNER_TOKEN_EXPIRES_AT(dtPhoneBurnerOAuthExpiresAt);
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', dtPhoneBurnerOAuthExpiresAt);
					this.dtPhoneBurnerOAuthExpiresAt = dtPhoneBurnerOAuthExpiresAt;
				}
			}
		}
		catch(error: any)
		{
			this.lblPhoneBurnerAuthorizedStatus = error.message;
		}
		if ( !(Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT == null || Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT < (new Date())) )
		{
			this.Page_Command.emit({sCommandName: 'PhoneBurner.BeginDial', sCommandArguments: null});
		}
	}

}
