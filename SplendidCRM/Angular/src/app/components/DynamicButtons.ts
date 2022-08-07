import { Component, OnInit, Input, Output, EventEmitter, ChangeDetectorRef } from '@angular/core'                         ;
import { Router, ActivatedRoute, ParamMap                             } from '@angular/router'                       ;
import { faSpinner                                                    } from '@fortawesome/free-solid-svg-icons'     ;

import { SplendidCacheService                                         } from '../scripts/SplendidCache'              ;
import { CredentialsService                                           } from '../scripts/Credentials'                ;
import { SecurityService                                              } from '../scripts/Security'                   ;
import { L10nService                                                  } from '../scripts/L10n'                       ;
import { CrmConfigService, CrmModulesService                          } from '../scripts/Crm'                        ;
import { StartsWith, isMobileDevice, isMobileLandscape                } from '../scripts/utility'                    ;
import Sql                                                              from '../scripts/Sql'                        ;
import SplendidDynamic                                                  from '../scripts/SplendidDynamic'            ;
import MODULE                                                           from '../types/MODULE'                       ;
import DYNAMIC_BUTTON                                                   from '../types/DYNAMIC_BUTTON'               ;
import ACL_ACCESS                                                       from '../types/ACL_ACCESS'                   ;

@Component({
	selector: 'DynamicButtons',
	templateUrl: './DynamicButtons.html',
})
export class DynamicButtonsComponent implements OnInit
{
	private   lastKey                  : number          ;
	private   changeKey                : number          ;
	public    layout                   : DYNAMIC_BUTTON[];
	public    disabled                 : any             ;
	public    hidden                   : any             ;
	public    bIsPostBack              : boolean         ;
	public    busy                     : boolean         ;
	public    error                    : any             ;
	public    pnlDynamicButtons        : any             ;
	public    pnlDynamicButtonsChildren: any[]           ;
	public    spinner                  = faSpinner       ;
	public    JSON                     = JSON;

	@Input()  ButtonStyle       : string ;
	@Input()  FrameStyle        : any    ;
	@Input()  ContentStyle      : any    ;
	@Input()  VIEW_NAME         : string ;
	@Input()  row               : any    ;
	@Output() Page_Command      : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();
	// 06/03/2022 Paul.  onLayoutLoaded is not needed becasue we are using the ViewChild setter.  We do this because onLayoutLoaded would otherwise fire too early. 
	//@Output() onLayoutLoaded    : EventEmitter<void> = new EventEmitter<void>();
	// 07/02/2020 Paul.  Provide a way to override the default ButtonLink behavior. 
	@Output() onButtonLink      : EventEmitter<DYNAMIC_BUTTON> = new EventEmitter<DYNAMIC_BUTTON>();
	// 06/03/2022 Paul.  We need a separate flag to determine if observed. 
	@Input()  buttonLinkObserved: boolean;

	constructor(private router: Router, private changeDetectorRef: ChangeDetectorRef, public SplendidCache : SplendidCacheService, public Credentials: CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService)
	{
		//console.log(this.constructor.name + '.constructor');
		this.lastKey                   = 0    ;
		this.changeKey                 = 0    ;
		this.layout                    = null ;
		this.disabled                  = {}   ;
		this.hidden                    = {}   ;
		this.bIsPostBack               = false;
		this.busy                      = false;
		this.error                     = null ;
		this.pnlDynamicButtons         = {}   ;
		this.pnlDynamicButtonsChildren = []   ;
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit ' + this.VIEW_NAME);
		try
		{
			// 05/04/2019 Paul.  Search views do not have dynamic buttons. 
			if ( this.VIEW_NAME && this.VIEW_NAME.indexOf('.Search') < 0 )
			{
				let layout: DYNAMIC_BUTTON[] = this.SplendidCache.DynamicButtons_LoadLayout(this.VIEW_NAME);
				this.layout = layout;
				this.changeKey++;
				// 06/03/2022 Paul.  This is too early to fire layout loaded as DetailView does not yet have headerButtons defined. 
				//this.onLayoutLoaded.emit();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.error = error;;
		}
	}

	ngDoCheck() : void
	{
		//console.log(this.constructor.name + '.ngDoCheck', this.changeKey);
		if ( this.lastKey != this.changeKey )
		{
			this.LoadButtons();
			this.lastKey = this.changeKey;
		}
	}

	ngAfterViewChecked(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewChecked');
		if ( this.layout != null )
		{
			// 06/03/2022 Paul.  onLayoutLoaded is not needed becasue we are using the ViewChild setter.  We do this because onLayoutLoaded would otherwise fire too early. 
			//this.onLayoutLoaded.emit();
		}
	}

	public LoadButtons(): void
	{
		//console.log(this.constructor.name + '.LoadButtons');
		this.pnlDynamicButtons         = {}   ;
		this.pnlDynamicButtonsChildren = []   ;
		if ( this.layout == null || this.layout.length == 0 )
		{
			return;
		}
		let bIsMobile: boolean = isMobileDevice();
		if ( isMobileLandscape() )
		{
			bIsMobile = false;
		}
		let gASSIGNED_USER_ID: string = null;
		if ( this.row != null )
		{
			gASSIGNED_USER_ID = Sql.ToGuid(this.row['ASSIGNED_USER_ID']);
		}
		let sTheme                   : string  = this.SplendidCache.UserTheme;
		let bShowUnassigned          : boolean = this.Crm_Config.ToBoolean('show_unassigned');
		let bMoreListItems           : boolean = false;
		let style                    : any     = (this.ContentStyle ? this.ContentStyle : {});
		style.display                          = (this.ButtonStyle == 'ModuleHeader' ? 'block' : 'inline-block');
		style.marginTop                        = '6px';
		style.marginBottom                     = '2px';
		let nButtonStart             : number  = 0;
		let themeURL                 : string  = this.Credentials.RemoteServer + 'App_Themes/' + this.SplendidCache.UserTheme + '/';
		if ( SplendidDynamic.StackedLayout(sTheme) && (this.ButtonStyle == 'ModuleHeader' || this.ButtonStyle == 'ListHeader' || this.ButtonStyle == 'MassUpdateHeader') )
		{
			if ( sTheme == 'Pacific' && this.ButtonStyle == 'ListHeader' )
			{
				// 05/06/2022 Paul.  If only one button, then no need for Actions dropdown. 
				if ( this.layout.length == 1 )
				{
					this.pnlDynamicButtons = {tag: 'div', props: { id: 'pnlDynamicButtons', key: 'pnlDynamicButtons', alignRight: true, style: { paddingRight: '1em'}, children: null}, children: this.pnlDynamicButtonsChildren};
				}
				else
				{
					let actionTitleChildren: any[] = [];
					let actionTitle        : any = {tag: 'div' , props: {class: this.ButtonStyle + 'FirstButton', style: {}}, children: actionTitleChildren};
					let actions            : any = {tag: 'span', props: {style: {}}, children: [this.L10n.Term('.LBL_ACTIONS')]};
					actionTitleChildren.push(actions);
					let iDown              : any = {tag: 'fa-icon', props: { icon: 'caret-down' }, children: []};
					let more               : any = {tag: 'span'   , props: {class: this.ButtonStyle + 'MoreButton', style: {}}, children: [iDown]};
					actionTitleChildren.push(more);
					let navItem            : any = {tag: 'NavItem', props: { id: 'pnlDynamicButtons', key: 'pnlDynamicButtons', title: actionTitle, alignRight: true, style: { paddingRight: '1em'}, children: null}, children: this.pnlDynamicButtonsChildren};
					this.pnlDynamicButtons = navItem;
				}
			}
			else
			{
				// 10/26/2021 Paul.  Several buttons may be hidden, so loop until we find the first available button. 
				while ( this.layout.length > nButtonStart )
				{
					// 10/26/2021 Paul.  For the Seven theme, we need to account for the first button possibly being hidden. 
					let lay: DYNAMIC_BUTTON = this.layout[nButtonStart];
					let CONTROL_TYPE       : string  = Sql.ToString (lay.CONTROL_TYPE      );
					let MODULE_NAME        : string  = Sql.ToString (lay.MODULE_NAME       );
					let MODULE_ACCESS_TYPE : string  = Sql.ToString (lay.MODULE_ACCESS_TYPE);
					let TARGET_NAME        : string  = Sql.ToString (lay.TARGET_NAME       );
					let TARGET_ACCESS_TYPE : string  = Sql.ToString (lay.TARGET_ACCESS_TYPE);
					let MOBILE_ONLY        : boolean = Sql.ToBoolean(lay.MOBILE_ONLY       );
					let ADMIN_ONLY         : boolean = Sql.ToBoolean(lay.ADMIN_ONLY        );
					let CONTROL_TEXT       : string  = Sql.ToString (lay.CONTROL_TEXT      );
					let HIDDEN             : boolean = Sql.ToBoolean(lay.HIDDEN            );
					let EXCLUDE_MOBILE     : boolean = Sql.ToBoolean(lay.EXCLUDE_MOBILE    );
					let COMMAND_NAME       : string = Sql.ToString (lay.COMMAND_NAME);
					let MODULE_ACLACCESS  = (Sql.IsEmptyString(lay.MODULE_ACLACCESS) ? 0 : Sql.ToInteger(lay.MODULE_ACLACCESS));
					let nTARGET_ACLACCESS = (Sql.IsEmptyString(lay.TARGET_ACLACCESS) ? 0 : Sql.ToInteger(lay.TARGET_ACLACCESS));
					if ( MODULE_ACLACCESS < 0 || nTARGET_ACLACCESS < 0 )
					{
						nButtonStart++;
						continue;
					}
					let bVisible: boolean = true;
					bVisible = (!EXCLUDE_MOBILE || !bIsMobile) && (MOBILE_ONLY && bIsMobile || !MOBILE_ONLY) && (ADMIN_ONLY && this.Security.IS_ADMIN() || !ADMIN_ONLY) && (!HIDDEN || Sql.ToInteger(this.hidden[COMMAND_NAME]) <= 0);
					if ( bVisible && !Sql.IsEmptyString(MODULE_NAME) && !Sql.IsEmptyString(MODULE_ACCESS_TYPE) )
					{
						let nACLACCESS = this.SplendidCache.GetUserAccess(MODULE_NAME, MODULE_ACCESS_TYPE, this.constructor.name + '.LoadButtons');
						bVisible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((this.Security.USER_ID() == gASSIGNED_USER_ID) || (!this.bIsPostBack && this.row == null) || (this.row != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
						if ( bVisible && !Sql.IsEmptyString(TARGET_NAME) && !Sql.IsEmptyString(TARGET_ACCESS_TYPE) )
						{
							nACLACCESS = this.SplendidCache.GetUserAccess(TARGET_NAME, TARGET_ACCESS_TYPE, this.constructor.name + '.LoadButtons');
							bVisible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((this.Security.USER_ID() == gASSIGNED_USER_ID) || (!this.bIsPostBack && this.row == null) || (this.row != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
						}
					}
					if ( !bVisible || (this.hidden[COMMAND_NAME] == null && HIDDEN) || Sql.ToInteger(this.hidden[COMMAND_NAME]) > 0 )
					{
						nButtonStart++;
						continue;
					}
					else if ( Sql.IsEmptyString(COMMAND_NAME) && !Sql.IsEmptyString(CONTROL_TEXT) && (!bVisible || (this.hidden[CONTROL_TEXT] == null && HIDDEN) || Sql.ToInteger(this.hidden[CONTROL_TEXT]) > 0) )
					{
						nButtonStart++;
						continue;
					}
					lay = this.layout[nButtonStart];
					let sCONTROL_TEXT: string = '  ' + this.L10n.Term(lay.CONTROL_TEXT) + '  ';
					if ( this.ButtonStyle == 'ListHeader' && (COMMAND_NAME.indexOf('.Create') > 0) )
					{
						sCONTROL_TEXT = '  +  ';
					}
					let titleChildren: any[] = [];
					let title: any = {tag: 'span', props: {style: {verticalAlign: 'bottom'}}, children: titleChildren};
					// 12/13/2019 Paul.  Only change search to icon for Seven theme. 
					// 01/05/2022 Paul.  First button might be a button link. 
					let onClick = this._onButtonClick;
					if ( CONTROL_TYPE == 'ButtonLink' )
					{
						if ( this.buttonLinkObserved )
							onClick = (lay: any) => this.onButtonLink.emit(lay);
						else
							onClick = this._onButtonLink;
					}

					if ( this.ButtonStyle == 'ListHeader' && COMMAND_NAME.indexOf('.Search') > 0 )
					{
						let iNavSearch: any = {tag: 'fa-icon', props: { icon: 'search' }, children: []};
						// 01/05/2022 Paul.  First button might be a button link. 
						let first: any = {tag: 'input', props: {type: 'button', class: this.ButtonStyle + 'FirstButton', style: {}, onClick: (e: any) => onClick(lay)}, children: [iNavSearch]};
						titleChildren.push(first);
					}
					else
					{
						// 01/05/2022 Paul.  First button might be a button link. 
						let first: any = {tag: 'input', props: {type: 'submit', class: this.ButtonStyle + 'FirstButton', style: {}, value: sCONTROL_TEXT, onClick: (e: any) => onClick(lay)}, children: []};
						titleChildren.push(first);
					}
					if ( this.layout.length > 1 )
					{
						if ( sTheme == 'Pacific' && this.ButtonStyle == 'ModuleHeader' )
						{
							// 04/02/2022 Paul.  Create an outer div to include the first button and the action navItem. 
							let pacificChildren: any[] = [];
							let pacific        : any   = {tag: 'div', props: {style: {display: 'flex', flexDirection: 'row', flexWrap: 'nowrap'}}, children: pacificChildren};
							// 04/02/2022 Paul.  Write title in a div to correct spacing alignment issues. 
							let firstDivChildren: any[] = [];
							let firstDiv        : any   = {tag: 'div', props: {}, children: firstDivChildren};
							pacificChildren.push(firstDiv);
							firstDivChildren.push(title);
							
							let actionTitleChildren: any[] = [];
							let actionTitle        : any   = {tag: 'div', props: {class: this.ButtonStyle + 'FirstButton', style: {}}, children: actionTitleChildren};
							let actions            : any   = {tag: 'span', props: {style: {}}, children: [this.L10n.Term('.LBL_ACTIONS')]};
							actionTitleChildren.push(actions);
							let iDown              : any   = {tag: 'fa-icon', props: { icon: 'caret-down' }, children: []};
							let more               : any   = {tag: 'span', props: {class: this.ButtonStyle + 'MoreButton', style: {}}, children: [iDown]};
							actionTitleChildren.push(more);
							let navItem            : any   = {tag: 'NavItem', props: { id: 'pnlDynamicButtons', key: 'pnlDynamicButtons', title: actionTitle, alignRight: true, children: null}, children: this.pnlDynamicButtonsChildren};
							pacificChildren.push(navItem);
							this.pnlDynamicButtons = pacific;
						}
						else
						{
							if ( this.ButtonStyle == 'ListHeader' )
							{
								let more: any = {tag: 'input', props: {type: 'image', class: this.ButtonStyle + 'MoreButton', style: {verticalAlign: 'bottom', height: '26px'}, src: themeURL + 'images/subpanel_more.gif', onClick: (e: any) => { e.preventDefault() }}, children: []};
								titleChildren.push(more);
							}
							else
							{
								let more: any = {tag: 'input', props: {type: 'image', class: this.ButtonStyle + 'MoreButton', style: {verticalAlign: 'bottom'}, src: themeURL + 'images/moreWhite.gif', onClick: (e: any) => { e.preventDefault() }}, children: []};
								titleChildren.push(more);
							}
							// 02/25/2022 Paul.  NavDropdownProps requires children parameter, though it does not seem to be used.  This error appeared with bootstrap 5. 
							let navItem: any = {tag: 'NavItem', props: { id: 'pnlDynamicButtons', key: 'pnlDynamicButtons', title: title, alignRight: true, children: null}, children: this.pnlDynamicButtonsChildren};
							//this.pnlDynamicButtons = React.createElement(Nav, {class: 'ml-auto', navbar: true}, [navItem]);
							this.pnlDynamicButtons = navItem;
						}
					}
					else
					{
						this.pnlDynamicButtons = title;
					}
					bMoreListItems = true;
					nButtonStart++;
					break;
				}
			}
		}
		else if ( SplendidDynamic.StackedLayout(sTheme) && (this.ButtonStyle == 'DataGrid') )
		{
			if ( this.layout.length > 0 )
			{
				let more: any = null
				if ( sTheme == 'Pacific' )
				{
					more =
					{
						tag: 'div',
						props: {class: 'GridBulkAction'},
						children:
						[
							{tag: 'span'     , props: {style: {'margin-right': '10px'} }, children: [this.L10n.Term('.LBL_BULK_ACTION')]},
							{tag: 'font-icon', props: {icon: 'caret-down', size: 'lg'}, children: []}
						]
					};
				}
				else
				{
					let titleChildren: any [] = [];
					let title        : any    = {tag: 'span', props: {style: {'vertical-align': 'top'}}, children: titleChildren};
					more = {tag: 'input', props: {type: 'image', class: this.ButtonStyle + 'MoreButton', style: {'vertical-align': 'top', width: '20px', height: '20px'}, src: themeURL + 'images/datagrid_more.gif', onClick: (e: any) => { e.preventDefault() }}, children: []};
					titleChildren.push(more);
				}
				// 02/25/2022 Paul.  NavDropdownProps requires children parameter, though it does not seem to be used.  This error appeared with bootstrap 5. 
				let navItem: any = {tag: 'NavItem', props: { id: 'pnlDynamicButtons', key: 'pnlDynamicButtons', title: more, style: {textAlign: 'left', verticalAlign: 'top', padding: 0, margin: 0} }, children: this.pnlDynamicButtonsChildren};
				//this.pnlDynamicButtons = React.createElement(Nav, {class: 'ml-auto', navbar: true}, [navItem]);
				this.pnlDynamicButtons = navItem;
			}
		}
		else
		{
			this.pnlDynamicButtons = {tag: 'div', props: { id: 'pnlDynamicButtons', class: 'button-panel', role: 'group', key: 'pnlDynamicButtons', style }, children: this.pnlDynamicButtonsChildren};
		}
		for ( let iButton = nButtonStart; iButton < this.layout.length; iButton++ )
		{
			let lay: DYNAMIC_BUTTON = this.layout[iButton];
			// 03/06/2016 Paul.  COMMAND_NAME might be null, so we have to use Sql.ToString() so that we can use indexOf. 
			let VIEW_NAME          : string  = Sql.ToString (lay.VIEW_NAME         );
			let CONTROL_TYPE       : string  = Sql.ToString (lay.CONTROL_TYPE      );
			let MODULE_NAME        : string  = Sql.ToString (lay.MODULE_NAME       );
			let MODULE_ACCESS_TYPE : string  = Sql.ToString (lay.MODULE_ACCESS_TYPE);
			let TARGET_NAME        : string  = Sql.ToString (lay.TARGET_NAME       );
			let TARGET_ACCESS_TYPE : string  = Sql.ToString (lay.TARGET_ACCESS_TYPE);
			let MOBILE_ONLY        : boolean = Sql.ToBoolean(lay.MOBILE_ONLY       );
			let ADMIN_ONLY         : boolean = Sql.ToBoolean(lay.ADMIN_ONLY        );
			let CONTROL_TEXT       : string  = Sql.ToString (lay.CONTROL_TEXT      );
			let CONTROL_TOOLTIP    : string  = Sql.ToString (lay.CONTROL_TOOLTIP   );
			let CONTROL_CSSCLASS   : string  = Sql.ToString (lay.CONTROL_CSSCLASS  );
			let TEXT_FIELD         : string  = Sql.ToString (lay.TEXT_FIELD        );
			let ARGUMENT_FIELD     : string  = Sql.ToString (lay.ARGUMENT_FIELD    );
			let COMMAND_NAME       : string  = Sql.ToString (lay.COMMAND_NAME      );
			let URL_FORMAT         : string  = Sql.ToString (lay.URL_FORMAT        );
			let URL_TARGET         : string  = Sql.ToString (lay.URL_TARGET        );
			let ONCLICK_SCRIPT     : string  = Sql.ToString (lay.ONCLICK_SCRIPT    );
			// 03/14/2014 Paul.  Allow hidden buttons to be created. 
			let HIDDEN             : boolean = Sql.ToBoolean(lay.HIDDEN            );
			// 07/28/2010 Paul.  We need a flag to exclude a button from a mobile device. 
			let EXCLUDE_MOBILE     : boolean = Sql.ToBoolean(lay.EXCLUDE_MOBILE    );
			// 04/30/2017 Paul.  Apply access rights. 
			let MODULE_ACLACCESS  = (Sql.IsEmptyString(lay.MODULE_ACLACCESS) ? 0 : Sql.ToInteger(lay.MODULE_ACLACCESS));
			let nTARGET_ACLACCESS = (Sql.IsEmptyString(lay.TARGET_ACLACCESS) ? 0 : Sql.ToInteger(lay.TARGET_ACLACCESS));
			if ( MODULE_ACLACCESS < 0 || nTARGET_ACLACCESS < 0 )
			{
				continue;
			}
			let sCONTROL_ID = '';
			if ( !Sql.IsEmptyString(COMMAND_NAME) )
			{
				sCONTROL_ID = 'btnDynamicButtons_' + COMMAND_NAME;
			}
			else if ( !Sql.IsEmptyString(CONTROL_TEXT) )
			{
				sCONTROL_ID = 'btnDynamicButtons_' + CONTROL_TEXT;
				if ( CONTROL_TEXT.indexOf('.') >= 0 )
				{
					sCONTROL_ID = CONTROL_TEXT.split('.')[1];
					sCONTROL_ID = sCONTROL_ID.replace('LBL_', '');
					sCONTROL_ID = sCONTROL_ID.replace('_BUTTON_LABEL', '');
				}
			}
			// 06/06/2015 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
			if ( this.ButtonStyle == 'DataGrid' && COMMAND_NAME == 'MassUpdate' )
			{
				CONTROL_TEXT       = this.L10n.Term('.LBL_MASS_UPDATE_TITLE');
				CONTROL_TOOLTIP    = this.L10n.Term('.LBL_MASS_UPDATE_TITLE');
				COMMAND_NAME       = 'ToggleMassUpdate';
				ONCLICK_SCRIPT     = null;
				MODULE_ACCESS_TYPE = null;
				// 05/07/2017 Paul.  Don't display MassUpdate toggle if it is disabled for the module. 
				let MODULE = VIEW_NAME.split('.')[0];
				if ( !Sql.IsEmptyString(MODULE) && !(!bIsMobile && this.Crm_Modules.MassUpdate(MODULE)) )
					HIDDEN = true;
			}
			if ( !Sql.IsEmptyString(sCONTROL_ID) )
			{
				//sCONTROL_ID = sCONTROL_ID.Trim();
				// 12/24/2012 Paul.  Use regex global replace flag. 
				sCONTROL_ID = sCONTROL_ID.replace(/\s/g, '_');
				sCONTROL_ID = sCONTROL_ID.replace(/\./g, '_');
			}
			try
			{
				let btnChildren: any[] = [];
				// 10/11/2019 Paul.  Manually add spacing around buttons so that the do not look like one solid botton. 
				let btnProps   : any = { style: { marginRight: '2px', marginBottom: '2px' }, key: this.ButtonStyle + MODULE_NAME + iButton };
				let btn        : any = null;
				// 04/02/2022 Paul.  Bottom margin leaves white line with Pacific theme. 
				if ( sTheme == 'Pacific' && (this.ButtonStyle == 'ListHeader' || this.ButtonStyle == 'DataGrid') )
				{
					btnProps.style.marginBottom = '0px';
				}

				// 11/21/2008 Paul.  On post back, we need to re-create the buttons, but don't change the visiblity flag. 
				// The problem is that we don't have the record at this early stage, so we cannot properly evaluate gASSIGNED_USER_ID. 
				// This is not an issue because .NET will restore the previous visibility state on post back. 
				let bVisible   : boolean = true;
				// 07/28/2010 Paul.  We need a flag to exclude a button from a mobile device. 
				// 03/14/2014 Paul.  Allow hidden buttons to be created. 
				// 10/30/2020 Paul.  Need to counter the HIDDEN value with the dynamic hidden[] setting. 
				bVisible         = (!EXCLUDE_MOBILE || !bIsMobile) && (MOBILE_ONLY && bIsMobile || !MOBILE_ONLY) && (ADMIN_ONLY && this.Security.IS_ADMIN() || !ADMIN_ONLY) && (!HIDDEN || Sql.ToInteger(this.hidden[COMMAND_NAME]) <= 0);
				if ( bVisible && !Sql.IsEmptyString(MODULE_NAME) && !Sql.IsEmptyString(MODULE_ACCESS_TYPE) )
				{
					let nACLACCESS = this.SplendidCache.GetUserAccess(MODULE_NAME, MODULE_ACCESS_TYPE, this.constructor.name + '.LoadButtons');
					// 08/11/2008 John.  Fix owner access rights. 
					// 10/27/2008 Brian.  Only show button if show_unassigned is enabled.
					// 11/21/2008 Paul.  We need to make sure that an owner can create a new record. 
					bVisible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((this.Security.USER_ID() == gASSIGNED_USER_ID) || (!this.bIsPostBack && this.row == null) || (this.row != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
					if ( bVisible && !Sql.IsEmptyString(TARGET_NAME) && !Sql.IsEmptyString(TARGET_ACCESS_TYPE) )
					{
						// 08/11/2008 John.  Fix owner access rights.
						nACLACCESS = this.SplendidCache.GetUserAccess(TARGET_NAME, TARGET_ACCESS_TYPE, this.constructor.name + '.LoadButtons');
						// 11/21/2008 Paul.  We need to make sure that an owner can create a new record. 
						bVisible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((this.Security.USER_ID() == gASSIGNED_USER_ID) || (!this.bIsPostBack && this.row == null) || (this.row != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
					}
				}
				if ( CONTROL_TYPE == 'Button' )
				{
					if ( Sql.IsEmptyString(COMMAND_NAME) )
					{
						COMMAND_NAME = ONCLICK_SCRIPT.replace('return false;', '');
						COMMAND_NAME = COMMAND_NAME.replace('Popup();', 's.Select');
						COMMAND_NAME = COMMAND_NAME.replace('Opportunitys', 'Opportunities');
					}
					if ( COMMAND_NAME.indexOf('.Create') > 0 || COMMAND_NAME.indexOf('.Select') > 0 )
					{
						ARGUMENT_FIELD = 'ID,NAME';
					}
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
					{
						btnProps.id = sCONTROL_ID;
					}
					// 03/14/2014 Paul.  Allow hidden buttons to be created. 
					// 08/18/2019 Paul.  Only use original HIDDEN field the first time. 
					// 04/28/2020 Paul.  Apply visibility flag. 
					if ( !bVisible || (this.hidden[COMMAND_NAME] == null && HIDDEN) || Sql.ToInteger(this.hidden[COMMAND_NAME]) > 0 )
					{
						btnProps.style.display = 'none';
					}
					// 07/05/2020 Paul.  Some buttons are identified with the CONTROL_TEXT
					else if ( Sql.IsEmptyString(COMMAND_NAME) && !Sql.IsEmptyString(CONTROL_TEXT) && (!bVisible || (this.hidden[CONTROL_TEXT] == null && HIDDEN) || Sql.ToInteger(this.hidden[CONTROL_TEXT]) > 0) )
					{
						btnProps.style.display = 'none';
					}

					btnProps.disabled = (Sql.ToInteger(this.disabled[COMMAND_NAME]) > 0);
					btnProps.onClick = () =>
					{
						this._onButtonClick(lay);
					}
					{
						if ( bMoreListItems )
						{
							let props: any =
							{
								type: 'submit',
								class: this.ButtonStyle + 'OtherButton',
								value: this.L10n.Term(CONTROL_TEXT),
								onClick: (e: any) => { e.preventDefault(); this._onButtonClick(lay); }
							};
							if ( (this.hidden[COMMAND_NAME] == null && HIDDEN) || Sql.ToInteger(this.hidden[COMMAND_NAME]) > 0 )
							{
								// 11/29/2021 Paul.  style was not previously defined. 
								props.style = {};
								props.style.display = 'none';
							}
							let li: any = {tag: 'input', props, children: []};
							this.pnlDynamicButtonsChildren.push(li);
						}
						else
						{
							// 04/05/2021 Paul.  Use class property instead of hard coded 'button'. 
							btnProps.class = CONTROL_CSSCLASS;
							if ( SplendidDynamic.StackedLayout(sTheme) )
							{
								if ( sTheme == 'Pacific' && this.layout.length == 1 )
									btnProps.class = this.ButtonStyle + 'FirstButton';
								else
									btnProps.class = this.ButtonStyle + 'OtherButton';
							}
							//btnProps.size = 'tiny';
							if ( CONTROL_TEXT == '+' )
							{
								let glyph: any = {tag: 'fa-icon', props: { icon: 'plus' }, children: []};
								btnChildren.push(glyph);
								btn = {tag: 'button', props: btnProps, children: btnChildren};
								this.pnlDynamicButtonsChildren.push(btn);
							}
							else
							{
								// 12/10/2019 Paul.  Button does not look right.  Use input type submit. 
								btnProps.type  = 'submit';
								btnProps.value = '  ' + this.L10n.Term(CONTROL_TEXT) + '  ';
								btn = {tag: 'input', props: btnProps, children: []};
								this.pnlDynamicButtonsChildren.push(btn);
							}
						}
					}
				}
				else if ( CONTROL_TYPE == 'HyperLink' )
				{
					let lnkProps: any = {};
					let lnk     : any = null;
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
					{
						lnkProps.id = sCONTROL_ID;
					}
					lnkProps.toolTip   = (CONTROL_TOOLTIP.length > 0) ? this.L10n.Term(CONTROL_TOOLTIP) : '';
					lnkProps.class = CONTROL_CSSCLASS;
					//lnk.href            = String_Format(URL_FORMAT, objTEXT_FIELD);
					//btn.Command        += Page_Command;
					lnkProps.CommandName = COMMAND_NAME;
					//btn.OnClientClick   = ONCLICK_SCRIPT;
					lnkProps.href  = '#';
					lnkProps.style = {};
					lnkProps.style.marginRight = '3px';
					lnkProps.style.marginLeft  = '3px';
					if ( Sql.ToInteger(this.hidden[COMMAND_NAME]) > 0 )
					{
						lnkProps.style.display = 'none';
					}
					if ( !(Sql.ToInteger(this.disabled[URL_FORMAT]) > 0) )
					{
						lnkProps.style.cursor = 'pointer';
						lnkProps.onClick = (e: any) =>
						{
							e.preventDefault();
							this._onHyperLink(lay);
						}
					}
					// 04/28/2020 Paul.  Apply visibility flag. 
					if ( !bVisible || (this.hidden[COMMAND_NAME] == null && HIDDEN) || Sql.ToInteger(this.hidden[COMMAND_NAME]) > 0 )
					{
						btnProps.style.display = 'none';
					}
					if ( bMoreListItems )
					{
						let props: any =
						{
							type: 'submit',
							class: this.ButtonStyle + 'OtherButton',
							value: this.L10n.Term(CONTROL_TEXT),
							onClick: (e: any) => { e.preventDefault(); this._onHyperLink(lay); }
						};
						lnk = {tag: 'input', props: props, children: []};
					}
					else
					{
						lnk = {tag: 'a', props: lnkProps, children: [this.L10n.Term(CONTROL_TEXT)] };
					}
					this.pnlDynamicButtonsChildren.push(lnk);
				}
				else if ( CONTROL_TYPE == 'ButtonLink' )
				{
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
					{
						btnProps.id = sCONTROL_ID;
					}
					btnProps.onClick = (event: any) =>
					{
						event.preventDefault();
						// 07/02/2020 Paul.  Provide a way to override the default ButtonLink behavior. 
						if ( this.buttonLinkObserved )
							this.onButtonLink.emit(lay);
						else
							this._onButtonLink(lay);
					}
					// 04/28/2020 Paul.  Apply visibility flag. 
					if ( !bVisible || (this.hidden[COMMAND_NAME] == null && HIDDEN) || Sql.ToInteger(this.hidden[COMMAND_NAME]) > 0 )
					{
						btnProps.style.display = 'none';
					}
					if ( bMoreListItems )
					{
						let props: any =
						{
							type: 'submit',
							class: this.ButtonStyle + 'OtherButton',
							value: this.L10n.Term(CONTROL_TEXT),
							onClick: (e: any) => { e.preventDefault(); this._onButtonLink(lay); }
						};
						let li: any = {tag: 'input', props: props, children: []};
						this.pnlDynamicButtonsChildren.push(li);
					}
					else
					{
						//btnProps.size = 'tiny';
						// 04/05/2021 Paul.  Use class property instead of hard coded 'button'. 
						btnProps.class = CONTROL_CSSCLASS;
						if ( SplendidDynamic.StackedLayout(sTheme) )
						{
							btnProps.class = this.ButtonStyle + 'OtherButton';
						}
						// 12/10/2019 Paul.  Button does not look right.  Use input type submit. 
						btnProps.type  = 'submit';
						btnProps.value = '  ' + this.L10n.Term(CONTROL_TEXT) + '  ';
						btn = {tag: 'input', props: btnProps, children: []};
						this.pnlDynamicButtonsChildren.push(btn);
					}
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadButtons ' + CONTROL_TEXT, error);
				this.error = error;
			}
		}
	}

	private ReplaceTextValues(URL: string, TEXT_FIELD: string): string
	{
		if ( !Sql.IsEmptyString(URL) )
		{
			let arrTEXT_FIELD = new Array();
			let objTEXT_FIELD = new Array();
			if ( !Sql.IsEmptyString(TEXT_FIELD) )
			{
				arrTEXT_FIELD = TEXT_FIELD.split(' ');
				objTEXT_FIELD = TEXT_FIELD.split(' ');
				for ( let i = 0; i < arrTEXT_FIELD.length; i++ )
				{
					if ( arrTEXT_FIELD[i].length > 0 )
					{
						objTEXT_FIELD[i] = '';
						if ( this.row != null )
						{
							if ( this.row[arrTEXT_FIELD[i]] != null )
							{
								objTEXT_FIELD[i] = this.row[arrTEXT_FIELD[i]];
							}
						}
					}
				}
			}
			for ( let i = 0; i <objTEXT_FIELD.length; i++ )
			{
				URL = URL.replace('{' + i + '}', objTEXT_FIELD[i]);
			}
		}
		return URL;
	}

	private _onButtonClick(lay: DYNAMIC_BUTTON)
	{
		console.log(this.constructor.name + '._onButtonClick', lay);
		let COMMAND_NAME  : string  = Sql.ToString(lay.COMMAND_NAME   );
		let MODULE_NAME   : string  = Sql.ToString (lay.MODULE_NAME   );
		let ARGUMENT_FIELD: string  = Sql.ToString(lay.ARGUMENT_FIELD );
		let ONCLICK_SCRIPT: string  = Sql.ToString (lay.ONCLICK_SCRIPT);
		if ( this.ButtonStyle == 'DataGrid' && COMMAND_NAME == 'MassUpdate' )
		{
			COMMAND_NAME       = 'ToggleMassUpdate';
		}
		if ( Sql.IsEmptyString(COMMAND_NAME) )
		{
			COMMAND_NAME = ONCLICK_SCRIPT.replace('return false;', '');
			COMMAND_NAME = COMMAND_NAME.replace('Popup();', 's.Select');
			COMMAND_NAME = COMMAND_NAME.replace('Opportunitys', 'Opportunities');
		}
		if ( COMMAND_NAME.indexOf('.Create') > 0 || COMMAND_NAME.indexOf('.Select') > 0 )
		{
			ARGUMENT_FIELD = 'ID,NAME';
		}
		let oARGUMENT_VALUE: any = null;
		if ( !Sql.IsEmptyString(ARGUMENT_FIELD) )
		{
			oARGUMENT_VALUE = new Object();
			oARGUMENT_VALUE['PARENT_MODULE'] = MODULE_NAME;
			// 04/14/2016 Paul.  In order to inherit assigned user and team, might as well send the entire row. 
			oARGUMENT_VALUE['PARENT_row'] = this.row;
			let arrFields = ARGUMENT_FIELD.split(',');
			for ( let n = 0; n < arrFields.length; n++ )
			{
				if ( this.row[arrFields[n]] != null )
				{
					oARGUMENT_VALUE[arrFields[n]] = this.row[arrFields[n]];
					//btn.CommandArgument = oARGUMENT_VALUE;
				}
			}
		}
		// 08/06/2020 Paul.  Confirm delete. 
		if ( ONCLICK_SCRIPT.indexOf('ConfirmDelete()') >= 0 )
		{
			if ( window.confirm(this.L10n.Term('.NTC_DELETE_CONFIRMATION')) )
			{
				this.Page_Command.emit({sCommandName: COMMAND_NAME, sCommandArguments: oARGUMENT_VALUE});
			}
		}
		else
		{
			this.Page_Command.emit({sCommandName: COMMAND_NAME, sCommandArguments: oARGUMENT_VALUE});
		}
	}

	private _onHyperLink = (lay: DYNAMIC_BUTTON) =>
	{
		console.log(this.constructor.name + '._onHyperLink', lay);
		let URL_FORMAT: string   = lay.URL_FORMAT;
		let TEXT_FIELD: string   = lay.TEXT_FIELD;
		let URL       : string   = Sql.ToString(URL_FORMAT);
		let arrURL    : string[] = URL.split('/');
		let URL_MODULE: string   = null;
		if ( arrURL.length > 1 )
		{
			URL_MODULE = arrURL[1];
		}
		if ( !Sql.IsEmptyString(URL_MODULE) )
		{
			// ~/Administration/QuickBooks/default.aspx?ShowSynchronized=1
			URL = URL.replace('default.aspx?ShowSynchronized=1', 'Synchronized');
			URL = URL.replace('~/'           , ''     );
			URL = URL.replace('default.aspx' , 'List' );
			URL = URL.replace('view.aspx?ID=', 'View/');
			URL = URL.replace('edit.aspx?ID=', 'Edit/');
			URL = URL.replace('.aspx?ID='    , '/'    );
			URL = this.ReplaceTextValues(URL, TEXT_FIELD);
			this.router.navigateByUrl('/Reset/' + URL);
		}
		else
		{
			let error: string = 'Unknown URL: ' + URL;
			this.error = error;
		}
	}

	private _onButtonLink = (lay: DYNAMIC_BUTTON) =>
	{
		console.log(this.constructor.name + '._onButtonLink', lay);
		let VIEW_NAME     : string   = lay.VIEW_NAME     ;
		let TARGET_NAME   : string   = lay.TARGET_NAME   ;
		let COMMAND_NAME  : string   = lay.COMMAND_NAME  ;
		let URL_FORMAT    : string   = lay.URL_FORMAT    ;
		let TEXT_FIELD    : string   = lay.TEXT_FIELD    ;
		let ONCLICK_SCRIPT: string   = lay.ONCLICK_SCRIPT;
		let URL           : string     = Sql.ToString(URL_FORMAT);
		let URL_MODULE    : string   = null;
		let VIEW_MODULE   : string   = null;
		let arrVIEW_NAME  : string[] = VIEW_NAME.split('.');
		VIEW_MODULE = arrVIEW_NAME[0];

		URL = URL.replace('../../', '~/');
		URL = URL.replace('../'   , '~/');
		// 10/11/2019 Paul.  Check against URL so that we don't have to also check URL_FORMAT. 
		if ( StartsWith(URL, '~/') )
		{
			let arrURL: string[] = URL.split('/');
			URL_MODULE = arrURL[1];
		}
		else if ( !Sql.IsEmptyString(URL_FORMAT) && URL_FORMAT != '#' )
		{
			URL_MODULE = VIEW_MODULE;
			// 04/26/2020 Paul.  Must check for Admin module. 
			let module: MODULE = this.SplendidCache.Module(URL_MODULE, this.constructor.name + '._onButtonLink');
			if ( module.IS_ADMIN )
			{
				URL = '~/Administration/' + URL_MODULE + '/' + URL;
			}
			else
			{
				URL = '~/' + URL_MODULE + '/' + URL;
			}
		}
		if ( !Sql.IsEmptyString(URL_MODULE) )
		{
			if ( URL.indexOf('convert.aspx?ID=') >= 0 )
			{
				// 09/18/2019 Paul.  Use Target. 
				URL = TARGET_NAME + '/Convert/' + VIEW_MODULE + '/{0}';
			}
			else if ( URL.indexOf('ChatMessages/default.aspx') >= 0 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('default.aspx?PARENT_ID={0}&PARENT_TYPE=', '') + '/{0}';
			}
			// 10/11/2019 Paul.  Remove default.aspx. 
			else if ( URL.indexOf('RulesWizard/') >= 0 )
			{
				URL = URL.replace('~/'                     , ''           );
				// 05/01/2021 Paul.   Keep the Module= query parameter. 
				URL = URL.replace('edit.aspx'              , 'Edit'       );
				// 06/14/2021 Paul.  Still need to convert Cancel to a page command. 
				if ( COMMAND_NAME == 'Cancel' )
				{
					this.Page_Command.emit({sCommandName: COMMAND_NAME, sCommandArguments: null});
					return;
				}
			}
			else if ( URL.indexOf('Reports/view.aspx') >= 0 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('view.aspx?ID='          , 'View/'      );
				URL = URL.replace('&'                      , '/'          );
				URL = URL.replace('='                      , '/'          );
			}
			else if ( URL.indexOf('Reports/attachment.aspx') >= 0 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('attachment.aspx?ID='    , 'Attachment/');
				let ID: string = (this.row ? this.row['ID'] : '00000000-0000-0000-0000-000000000000');
				URL = URL.replace('&'                      , '/' + VIEW_MODULE + '/' + ID + '/?');
			}
			else if ( URL.indexOf('Reports/SignaturePopup.aspx') >= 0 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('SignaturePopup.aspx?ID=', 'Signature/' );
				let ID: string = (this.row ? this.row['ID'] : '00000000-0000-0000-0000-000000000000');
				URL = URL.replace('&'                      , '/' + VIEW_MODULE + '/' + ID + '/?');
			}
			else if ( URL.indexOf('EditMyAccount.aspx') >= 0 )
			{
				// 10/08/2020 Paul.  MyAccount editing is no longer under Administration.
				//URL = URL.replace('~/'                     , ''           );
				//URL = URL.replace('.aspx'                  , ''           );
				URL = 'Users/EditMyAccount';
			}
			else if ( URL.indexOf('edit.aspx?UID=') >= 0 && arrVIEW_NAME.length == 3 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('edit.aspx?UID='         , arrVIEW_NAME[2] + '/Edit/');
			}
			else if ( URL.indexOf('edit.aspx?HID=') >= 0 && arrVIEW_NAME.length == 3 )
			{
				URL = URL.replace('~/'                     , ''           );
				URL = 'Administration/' + URL.replace('edit.aspx?HID='    , arrVIEW_NAME[2] + '/Edit/');
			}
			else if ( URL.indexOf('export.aspx?ID={0}') >= 0 )
			{
				URL = URL.replace('~/'                     , this.Credentials.RemoteServer);
				URL = this.ReplaceTextValues(URL, TEXT_FIELD);
				window.location.href = URL;
				// 08/29/2019 Paul.  Must return to prevent command being cancelled and internal routing to occur. 
				return;
			}
			// ../Reports/render.aspx?ID=F40989FE-24F5-4352-BB32-A23713EA6EC8&ORDER_ID={0}
			else if ( URL_FORMAT.indexOf('Reports/render.aspx?ID=') >= 0 )
			{
				URL = URL.replace('~/'                     , this.Credentials.RemoteServer);
				URL = this.ReplaceTextValues(URL, TEXT_FIELD);
				//console.log((new Date()).toISOString() + ' ' + URL);
				window.location.href = URL;
				// 08/29/2019 Paul.  Must return to prevent command being cancelled and internal routing to occur. 
				return;
			}
			else if ( URL_FORMAT.indexOf('vCard.aspx?ID=') >= 0 )
			{
				URL = this.Credentials.RemoteServer + TARGET_NAME + '/vCard.aspx?ID={0}';
				URL = this.ReplaceTextValues(URL, TEXT_FIELD);
				//console.log((new Date()).toISOString() + ' ' + URL);
				window.location.href = URL;
				// 08/29/2019 Paul.  Must return to prevent command being cancelled and internal routing to occur. 
				return;
			}
			else if ( VIEW_NAME.indexOf('.MassUpdate') >= 0 )
			{
				this.Page_Command.emit({sCommandName: COMMAND_NAME, sCommandArguments: URL_FORMAT});
				return;
			}
			else if ( COMMAND_NAME == 'ViewRelatedActivities' )
			{
				this.Page_Command.emit({sCommandName: COMMAND_NAME, sCommandArguments: URL_FORMAT});
				return;
			}
			// 10/29/2020 Paul.  Import cancel needs to go back to the ImportView so that it can redirect to the base module. 
			else if ( COMMAND_NAME == 'Cancel' && VIEW_MODULE == 'Import' )
			{
				this.Page_Command.emit({sCommandName: COMMAND_NAME, sCommandArguments: null});
				return;
			}
			/*
			~/Administration/Azure/AzureAppUpdates/edit.aspx?AZURE_APP_PRICE_ID={0}
			~/Activities/popup.aspx?PARENT_ID={0}&IncludeRelationships=1
			../Posts/edit.aspx?THREAD_ID={0}
			../Posts/edit.aspx?QUOTE=1&THREAD_ID={0}
			../Orders/edit.aspx?OPPORTUNITY_ID={0}
			../Invoices/edit.aspx?ORDER_ID={0}
			../Emails/edit.aspx?KBDOCUMENT_ID={0}
			*/
			else
			{
				URL = URL.replace('~/'                     , ''           );
				URL = URL.replace('default.aspx'           , 'List'       );
				URL = URL.replace('view.aspx?ID='          , 'View/'      );
				URL = URL.replace('edit.aspx?ID='          , 'Edit/'      );
				URL = URL.replace('edit.aspx?DuplicateID=' , 'Duplicate/' );
				URL = URL.replace('edit.aspx'              , 'Edit'       );
				URL = URL.replace('.aspx?ID='              , '/'          );
			}

			URL = this.ReplaceTextValues(URL, TEXT_FIELD);
			//if ( ONCLICK_SCRIPT != null && ONCLICK_SCRIPT.length > 0 )
			//	btn.OnClientClick   = String.Format(ONCLICK_SCRIPT, objTEXT_FIELD);
			//else
			//	btn.OnClientClick   = 'window.location.href='' + Sql.EscapeJavaScript(String_Format(URL_FORMAT, objTEXT_FIELD)) + ''; return false;';
			//btn.onclick = new Function('function('' + sLayoutPanel + '', '' + COMMAND_NAME + '', null)');
			this.router.navigateByUrl('/Reset/' + URL);
		}
		else
		{
			let error: string = 'Unknown URL: ' + URL;
			this.error = error;
		}
	}

	// 10/30/2020 Paul.  We need a busy indicator for long-running tasks such as Archive. 
	public Busy()
	{
		this.DisableAll();
		this.busy = true;
		this.changeKey++;
	}

	public NotBusy()
	{
		this.EnableAll();
		this.busy = false;
		this.changeKey++;
	}

	public DisableAll()
	{
		if ( this.layout != null )
		{
			for (let iButton = 0; iButton < this.layout.length; iButton++)
			{
				let lay: DYNAMIC_BUTTON = this.layout[iButton];
				let COMMAND_NAME = Sql.ToString(lay.COMMAND_NAME);
				this.disabled[COMMAND_NAME] = Sql.ToInteger(this.disabled[COMMAND_NAME]) + 1;
			}
			this.bIsPostBack = true;
			this.changeKey++;
		}
	}

	public EnableAll()
	{
		if ( this.layout != null )
		{
			for (let iButton = 0; iButton < this.layout.length; iButton++)
			{
				let lay: DYNAMIC_BUTTON = this.layout[iButton];
				let COMMAND_NAME = Sql.ToString(lay.COMMAND_NAME);
				this.disabled[COMMAND_NAME] = Sql.ToInteger(this.disabled[COMMAND_NAME]) - 1;
			}
			this.bIsPostBack = true;
			this.changeKey++;
		}
	}

	public EnableButton(COMMAND_NAME: string, bEnabled: boolean)
	{
		if ( this.layout != null )
		{
			this.disabled[COMMAND_NAME] = (bEnabled ? 0 : 1);
			this.bIsPostBack = true;
			this.changeKey++;
		}
	}

	public HideAll()
	{
		if ( this.layout != null )
		{
			for (let iButton = 0; iButton < this.layout.length; iButton++)
			{
				let lay: DYNAMIC_BUTTON = this.layout[iButton];
				let COMMAND_NAME  : string = Sql.ToString(lay.COMMAND_NAME);
				let ONCLICK_SCRIPT: string = Sql.ToString(lay.ONCLICK_SCRIPT);
				// 07/05/2020 paul.  Need to use the OnClick name if command is empty. 
				if ( Sql.IsEmptyString(COMMAND_NAME) )
				{
					COMMAND_NAME = ONCLICK_SCRIPT.replace('return false;', '');
					COMMAND_NAME = COMMAND_NAME.replace('Popup();', 's.Select');
					COMMAND_NAME = COMMAND_NAME.replace('Opportunitys', 'Opportunities');
				}
				this.hidden[COMMAND_NAME] = Sql.ToInteger(this.hidden[COMMAND_NAME]) + 1;
			}
			this.bIsPostBack = true;
			this.changeKey++;
		}
	}

	public ShowAll()
	{
		if ( this.layout != null )
		{
			for (let iButton = 0; iButton < this.layout.length; iButton++)
			{
				let lay: DYNAMIC_BUTTON = this.layout[iButton];
				let COMMAND_NAME: string = Sql.ToString(lay.COMMAND_NAME);
				let ONCLICK_SCRIPT: string = Sql.ToString(lay.ONCLICK_SCRIPT);
				// 07/05/2020 paul.  Need to use the OnClick name if command is empty. 
				if ( Sql.IsEmptyString(COMMAND_NAME) )
				{
					COMMAND_NAME = ONCLICK_SCRIPT.replace('return false;', '');
					COMMAND_NAME = COMMAND_NAME.replace('Popup();', 's.Select');
					COMMAND_NAME = COMMAND_NAME.replace('Opportunitys', 'Opportunities');
				}
				this.hidden[COMMAND_NAME] = Sql.ToInteger(this.hidden[COMMAND_NAME]) - 1;
			}
			this.bIsPostBack = true;
			this.changeKey++;
		}
	}

	public ShowButton(COMMAND_NAME: string, bVisible: boolean)
	{
		//console.log(this.constructor.name + '.ShowButton ' + COMMAND_NAME, bVisible);
		if ( this.layout != null )
		{
			this.hidden[COMMAND_NAME] = (bVisible ? 0 : 1);
			this.bIsPostBack = true;
			this.changeKey++;
		}
	}

	public ShowHyperLink(sURL: string, bVisible: boolean)
	{
		if ( this.layout != null )
		{
			for (let iButton = 0; iButton < this.layout.length; iButton++)
			{
				let lay: DYNAMIC_BUTTON = this.layout[iButton];
				let URL_FORMAT = Sql.ToString(lay.URL_FORMAT);
				if ( URL_FORMAT == sURL )
				{
					this.hidden[URL_FORMAT] = (bVisible ? 0 : 1);
					break;
				}
			}
			this.bIsPostBack = true;
			this.changeKey++;
		}
	}

	public SetControlClass(COMMAND_NAME: string, CONTROL_CSSCLASS: string)
	{
		if ( this.layout != null )
		{
			for (let iButton = 0; iButton < this.layout.length; iButton++)
			{
				let lay: DYNAMIC_BUTTON = this.layout[iButton];
				let sCOMMAND_NAME = Sql.ToString(lay.COMMAND_NAME);
				if ( COMMAND_NAME == sCOMMAND_NAME )
				{
					lay.CONTROL_CSSCLASS = CONTROL_CSSCLASS;
					break;
				}
			}
			// 06/01/2022 Paul.  Change may not be detected from array item. 
			this.changeDetectorRef.markForCheck();
			this.changeDetectorRef.detectChanges();
			this.changeKey++;
		}
	}

}
