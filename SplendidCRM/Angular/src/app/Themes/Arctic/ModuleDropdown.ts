import { Component, OnInit, ChangeDetectorRef, Input, Output, EventEmitter } from '@angular/core';
import { SplendidCacheService                } from '../../scripts/SplendidCache'  ;
import { CredentialsService                  } from '../../scripts/Credentials'     ;
import { SecurityService                     } from '../../scripts/Security'        ;
import { L10nService                         } from '../../scripts/L10n'            ;
import { CrmConfigService, CrmModulesService } from '../../scripts/Crm'             ;
import MODULE                                  from '../../types/MODULE'                    ;
import TAB_MENU                                from '../../types/TAB_MENU'                  ;
import SHORTCUT                                from '../../types/SHORTCUT'                  ;

@Component({
	selector: 'ArcticModuleDropdown',
	templateUrl: './ModuleDropdown.html',
})
export class ArcticModuleDropdown implements OnInit
{
	public bIsInitialized   : boolean = false;
	public bIsAuthenticated : boolean = false;
	public lastModule       : string  = '';
	public nHistoryMaxViewed: number  = 10;

	@Input()  MODULE_NAME           : string = '';
	@Input()  tabsSecondary         : TAB_MENU[] = [];
	@Input()  quickCreate           : TAB_MENU[] = [];
	@Output() onModuleTabMouseLeave : EventEmitter<{ event : any, MODULE_NAME : string }> = new EventEmitter<{ event : any, MODULE_NAME : string }>();
	@Output() onModuleTabClick      : EventEmitter<{ event : any, MODULE_NAME : string }> = new EventEmitter<{ event : any, MODULE_NAME : string }>();
	@Output() onQuickCreate         : EventEmitter<string                               > = new EventEmitter<string                               >();
	@Output() onAction              : EventEmitter<{ MODULE_NAME : string, item : any } > = new EventEmitter<{ MODULE_NAME : string, item : any } >();
	@Output() onFavorite            : EventEmitter<{ MODULE_NAME : string, item : any } > = new EventEmitter<{ MODULE_NAME : string, item : any } >();
	@Output() onLastViewed          : EventEmitter<{ MODULE_NAME : string, item : any } > = new EventEmitter<{ MODULE_NAME : string, item : any } >();
	@Output() onUserProfile         : EventEmitter<void                                 > = new EventEmitter<void                                 >();
	@Output() onAdminPage           : EventEmitter<void                                 > = new EventEmitter<void                                 >();
	@Output() onAbout               : EventEmitter<void                                 > = new EventEmitter<void                                 >();
	@Output() onLogout              : EventEmitter<void                                 > = new EventEmitter<void                                 >();

	constructor(private changeDetectorRef : ChangeDetectorRef, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, private Crm_Config : CrmConfigService, private Crm_Modules : CrmModulesService)
	{
		//console.log(this.constructor.name + '.constructor', this.MODULE_NAME);
		this.bIsInitialized    = SplendidCache.IsInitialized;
		this.bIsAuthenticated  = Credentials.bIsAuthenticated;
		this.lastModule        = this.MODULE_NAME;
		this.nHistoryMaxViewed = Crm_Config.ToInteger('history_max_viewed');
		if ( this.nHistoryMaxViewed == 0 )
		{
			this.nHistoryMaxViewed = 10;
		}
	}

	ngOnInit()
	{
	}

	ngDoCheck() : void
	{
		let bChanged : boolean = false;
		if ( this.lastModule != this.MODULE_NAME )
		{
			//console.log(this.constructor.name + '.ngDoCheck MODULE_NAME changed');
			bChanged = true;
		}
		else if ( this.bIsInitialized != this.SplendidCache.IsInitialized )
		{
			//console.log(this.constructor.name + '.ngDoCheck IsInitialized changed');
			bChanged = true;
		}
		else if ( this.bIsAuthenticated != this.Credentials.bIsAuthenticated )
		{
			//console.log(this.constructor.name + '.ngDoCheck bIsAuthenticated changed');
			bChanged = true;
		}
		if ( bChanged )
		{
			//console.log(this.constructor.name + '.ngDoCheck', this.MODULE_NAME);
			this.lastModule       = this.MODULE_NAME                 ;
			this.bIsInitialized   = this.SplendidCache.IsInitialized ;
			this.bIsAuthenticated = this.Credentials.bIsAuthenticated;

			//console.log(this.constructor.name + '.ngDoCheck markForCheck');
			//this.changeDetectorRef.markForCheck();
			//this.changeDetectorRef.detectChanges();
		}
	}

	public popupStyle() : any
	{
		let style : any = null;
		if (this.MODULE_NAME != null)
		{
			let element = document.getElementById('ctlSixToolbar_tabToolbar_' + this.MODULE_NAME);
			if (element != null)
			{
				let rect : any    = element.getBoundingClientRect();
				let left : string = Math.floor(rect.x + window.scrollX) + 'px';
				let top  : string = Math.floor(rect.y + rect.height + window.scrollY) + 'px';
				style = { position: 'absolute', top, zIndex: 1000 };
				if ( this.MODULE_NAME == 'userContextMenu' || this.MODULE_NAME == 'quickCreate' )
				{
					style.right = '0px';
				}
				else
				{
					style.left = left;
				}
				//console.log(this.constructor.name + '.popupStyle', rect, style);
			}
		}
		return style;
	}

	public _onModuleTabMouseLeave(event : any, MODULE_NAME : string)
	{
		//console.log(this.constructor.name + '._onModuleTabMouseLeave', MODULE_NAME);
		event.preventDefault();
		this.onModuleTabMouseLeave.emit({ event, MODULE_NAME });
	}

	public _onModuleClick(event : any, MODULE_NAME : string)
	{
		//console.log(this.constructor.name + '._onModuleClick', MODULE_NAME);
		event.preventDefault();
		this.onModuleTabClick.emit({ event, MODULE_NAME });
	}

	public _onQuickCreate(event : any, MODULE_NAME : string)
	{
		//console.log(this.constructor.name + '._onQuickCreate', MODULE_NAME);
		event.preventDefault();
		this.onQuickCreate.emit(MODULE_NAME);
	}

	public _onAction(event : any, item : any)
	{
		//console.log(this.constructor.name + '._onAction', item);
		event.preventDefault();
		this.onAction.emit({ MODULE_NAME: item.MODULE_NAME, item });
	}

	public _onFavorite(event : any, item : any)
	{
		//console.log(this.constructor.name + '._onFavorite ' + sMODULE_NAME, item);
		event.preventDefault();
		this.onFavorite.emit({ MODULE_NAME: this.MODULE_NAME, item });
	}

	public _onLastViewed(event : any, item : any)
	{
		//console.log(this.constructor.name + '._onLastViewed ' + sMODULE_NAME, item);
		event.preventDefault();
		this.onLastViewed.emit({ MODULE_NAME: this.MODULE_NAME, item });
	}

	public _onUserProfile(event : any)
	{
		//console.log(this.constructor.name + '._onLastViewed ' + sMODULE_NAME, item);
		event.preventDefault();
		this.onUserProfile.emit();
	}

	public _onAdminPage(event : any)
	{
		//console.log(this.constructor.name + '._onLastViewed ' + sMODULE_NAME, item);
		event.preventDefault();
		this.onAdminPage.emit();
	}

	public _onAbout(event : any)
	{
		//console.log(this.constructor.name + '._onLastViewed ' + sMODULE_NAME, item);
		event.preventDefault();
		this.onAbout.emit();
	}

	public _onLogout(event : any)
	{
		//console.log(this.constructor.name + '._onLastViewed ' + sMODULE_NAME, item);
		event.preventDefault();
		this.onLogout.emit();
	}


	public moduleUrl(MODULE_NAME : string, ID : any) : string
	{
		//console.log(this.constructor.name + '.moduleUrl', MODULE_NAME, ID);
		let module: MODULE = this.SplendidCache.Module(MODULE_NAME, this.constructor.name + '.moduleUrl');
		let url   : string = this.Credentials.RemoteServer;
		if ( module != null && module.IS_ADMIN )
		{
			url += 'Administration/';
		}
		url += MODULE_NAME;
		if ( ID != null && ID !== undefined )
		{
			url += '/View/' + ID;
		}
		return url;
	}

	public Actions(sMODULE_NAME : string)
	{
		let links = new Array();
		let shortcuts : SHORTCUT[] = this.SplendidCache.Shortcuts(sMODULE_NAME);
		if ( shortcuts != null )
		{
			for (let i = 0; i < shortcuts.length; i++)
			{
				let shortcut : SHORTCUT = shortcuts[ i ];
				if ( shortcut.SHORTCUT_ACLTYPE == 'archive' )
				{
					// 09/26/2017 Paul.  If the module does not have an archive table, then hide the link. 
					let bArchiveEnabled : boolean = this.Crm_Modules.ArchiveEnabled(shortcut.MODULE_NAME);
					if ( !bArchiveEnabled )
						continue;
				}
				let nSHORTCUT_ACLTYPE = this.SplendidCache.GetUserAccess(shortcut.MODULE_NAME, shortcut.SHORTCUT_ACLTYPE, this.constructor.name + '.Actions');
				if ( nSHORTCUT_ACLTYPE >= 0 )
				{
					let sDISPLAY_NAME  : string = this.L10n.Term(shortcut.DISPLAY_NAME);
					let sRELATIVE_PATH : string = shortcut.RELATIVE_PATH;
					sRELATIVE_PATH = sRELATIVE_PATH.replace('~/', '');
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/default.aspx?ArchiveView=1', '/ArchiveView'                  );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('~/Users/reassign.aspx'      , '/Administration/Users/Reassign');
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/default.aspx'              , '/List'                         );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/edit.aspx'                 , '/Edit'                         );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/import.aspx'               , '/Import'                       );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/stream.aspx'               , '/Stream'                       );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/sequence.aspx'             , '/Sequence'                     );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/statistics.aspx'           , '/Statistics'                   );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/config.aspx'               , '/Config'                       );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/Drafts.aspx'               , '/Drafts'                       );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/MyFeeds.aspx'              , '/MyFeeds'                      );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('/ByUser.aspx'               , '/ByUser'                       );
					sRELATIVE_PATH = sRELATIVE_PATH.replace('.aspx'                      , ''                              );
					let lnk: any =
					{
						label      : sDISPLAY_NAME       ,
						key        : sRELATIVE_PATH      ,
						MODULE_NAME: shortcut.MODULE_NAME,
						IMAGE_NAME : shortcut.IMAGE_NAME ,
						command    : this._onAction      ,
					};
					links.push(lnk);
				}
			}
		}
		return links;
	}

	public Favorites(sMODULE_NAME : string)
	{
		let links = this.SplendidCache.Favorites(sMODULE_NAME);
		if ( links === undefined || links == null )
			return [];
		return links;
	}

	public LastViewed(sMODULE_NAME : string)
	{
		let links = this.SplendidCache.LastViewed(sMODULE_NAME);
		if ( links === undefined || links == null )
			return [];
		if ( links.length > this.nHistoryMaxViewed )
			links = links.slice(0, this.nHistoryMaxViewed);
		return links;
	}

}
