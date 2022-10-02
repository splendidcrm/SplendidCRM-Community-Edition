import { Component, OnInit, Input, Output, EventEmitter, ViewChild    } from '@angular/core'                ;
import { Router                                                       } from '@angular/router'              ;
import { faSpinner, faAngleDoubleRight, faStar as faStarSolid, faArrowAltCircleRight as faArrowAltCircleRightSolid } from '@fortawesome/free-solid-svg-icons'     ;
import { faStar as faStarRegular, faArrowAltCircleRight as faArrowAltCircleRightRegular } from '@fortawesome/free-solid-svg-icons'     ;

import { SplendidCacheService                                         } from '../../scripts/SplendidCache'  ;
import { CredentialsService                                           } from '../../scripts/Credentials'    ;
import { SecurityService                                              } from '../../scripts/Security'       ;
import { L10nService                                                  } from '../../scripts/L10n'           ;
import { CrmConfigService, CrmModulesService                          } from '../../scripts/Crm'            ;
import { ModuleUpdateService                                          } from '../../scripts/ModuleUpdate'   ;
import Sql                                                              from '../../scripts/Sql'            ;
import { screenWidth, screenHeight, isMobileDevice, isMobileLandscape } from '../../scripts/utility'        ;
import { HeaderButtonsBase                                            } from '../HeaderButtonsBase'         ;
import DYNAMIC_BUTTON                                                   from '../../types/DYNAMIC_BUTTON'   ;
import MODULE                                                           from '../../types/MODULE'           ;

@Component({
	selector: 'PacificHeaderButtons',
	templateUrl: './HeaderButtons.html',
})
export class PacificHeaderButtons extends HeaderButtonsBase implements OnInit
{
	public sMODULE_TITLE          : string  = null ;
	public themeURL               : string  = null ;
	public sError                 : string  = null ;
	public bIsMobile              : boolean = false;
	public bResponsive            : boolean = false;
	public width                  : number  = 1024 ;
	public height                 : number  = 1024 ;
	public sModuleUrl             : string  = null ;
	public sItemUrl               : string  = null ;
	public angleDoubleRight       = faAngleDoubleRight          ;
	public fasStar                = faStarSolid                 ;
	public farStar                = faStarRegular               ;
	public fasArrowAltCircleRight = faArrowAltCircleRightSolid  ;
	public farArrowAltCircleRight = faArrowAltCircleRightRegular;

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public ModuleUpdate: ModuleUpdateService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules, ModuleUpdate);
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit', this.MODULE_NAME);
		this.sMODULE_TITLE = !Sql.IsEmptyString(this.MODULE_TITLE) ? this.L10n.Term(this.MODULE_TITLE) : this.L10n.Term('.moduleList.' + this.MODULE_NAME);
		this.themeURL      = this.Credentials.RemoteServer + 'App_Themes/' + this.SplendidCache.UserTheme + '/';
		this.sError        = null;
		if ( this.error !== undefined && this.error != null )
		{
			if ( this.error.message !== undefined )
			{
				this.sError = this.error.message;
			}
			else if ( typeof(this.error) == 'string' )
			{
				this.sError = this.error;
			}
			else if ( typeof(this.error) == 'object' )
			{
				this.sError = JSON.stringify(this.error);
			}
		}
		else if ( this.headerError !== undefined && this.headerError != null )
		{
			if ( this.headerError.message !== undefined )
			{
				this.sError = this.headerError.message;
			}
			else if ( typeof(this.headerError) == 'string' )
			{
				this.sError = this.headerError;
			}
			else if ( typeof(this.headerError) == 'object' )
			{
				this.sError = JSON.stringify(this.headerError);
			}
		}
		this.bIsMobile = isMobileDevice();
		if ( isMobileLandscape() )
		{
			this.bIsMobile = false;
		}
		// 04/28/2019 Paul.  Can't use react-bootstrap Breadcrumb as it will reload the app is is therefore slow. 
		// 07/09/2019 Paul.  Use span instead of a tag to prevent navigation. 
		// 04/19/2021 Paul.  Manually calculate responsive features. 
		this.bResponsive = false;
		this.width       = screenWidth();
		this.height      = screenHeight();
		if ( this.width < 992 )
			this.bResponsive = true;
		// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
		let admin = '';
		let module: MODULE = this.SplendidCache.Module(this.MODULE_NAME, this.constructor.name + '.render');
		if ( module != null && module.IS_ADMIN )
		{
			admin = 'Administration/';
		}
		this.sModuleUrl = this.Credentials.RemoteServer + `React/${admin}${this.MODULE_NAME}/List`;
		this.sItemUrl   = this.Credentials.RemoteServer + `React/${admin}${this.MODULE_NAME}/View/${this.ID}`;
	}

	ngDoCheck() : void
	{
	}

	public IsEmptyString(s: any): boolean
	{
		return Sql.IsEmptyString(s);
	}

	public IsEmptyGuid(s: any): boolean
	{
		return Sql.IsEmptyGuid(s);
	}

	public _onPage_Command(obj: {sCommandName: string, sCommandArguments: any})
	{
		if ( this.Page_Command.observed )
		{
			this.Page_Command.emit(obj);
		}
	}

	//public _onLayoutLoaded()
	//{
	//	console.log(this.constructor.name + '._onLayoutLoaded', this.VIEW_NAME);
	//	if ( this.onLayoutLoaded.observed )
	//	{
	//		this.onLayoutLoaded.emit();
	//	}
	//}

	public _onButtonLink(lay: DYNAMIC_BUTTON)
	{
		if ( this.onButtonLink.observed )
		{
			this.onButtonLink.emit(lay);
		}
	}
}
