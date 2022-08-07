import { Component, OnInit, Input, Output, EventEmitter, ChangeDetectorRef, ViewChildren, QueryList } from '@angular/core';
import { Router, ActivatedRoute, ParamMap                             } from '@angular/router'                       ;
import { faSpinner                                                    } from '@fortawesome/free-solid-svg-icons'     ;

import { SplendidCacheService                                         } from '../scripts/SplendidCache'              ;
import { CredentialsService                                           } from '../scripts/Credentials'                ;
import { SecurityService                                              } from '../scripts/Security'                   ;
import { L10nService                                                  } from '../scripts/L10n'                       ;
import { CrmConfigService, CrmModulesService                          } from '../scripts/Crm'                        ;
import { EditViewService                                            } from '../scripts/EditView'                 ;
import { isMobileDevice, isMobileLandscape, screenWidth, screenHeight } from '../scripts/utility'                    ;
import Sql                                                              from '../scripts/Sql'                        ;
import SplendidDynamic                                                  from '../scripts/SplendidDynamic'            ;
import MODULE                                                           from '../types/MODULE'                       ;
import DYNAMIC_BUTTON                                                   from '../types/DYNAMIC_BUTTON'               ;
import ACL_ACCESS                                                       from '../types/ACL_ACCESS'                   ;
import ACL_FIELD_ACCESS                                                 from '../types/ACL_FIELD_ACCESS'             ;
import EDITVIEWS_FIELD                                                  from '../types/EDITVIEWS_FIELD'              ;

@Component({
	selector: 'SplendidDynamic_EditView',
	templateUrl: './SplendidDynamic_EditView.html',
})
export class SplendidDynamic_EditViewComponent implements OnInit
{
	public    JSON                = JSON          ;

	public    error               : any     = null;
	public    spinner             = faSpinner     ;
	// 07/22/2019 Paul.  Apply ACL Field Security. 
	public    MODULE_NAME         : string =  null;
	public    EDIT_NAME           : string  = null;
	public    baseId              : string  = null;
	public    sTheme              : string  = null;
	public    bIsMobile           : boolean = false;
	public    bStackedTheme       : boolean = false;
	public    bStackedLayout      : boolean = false;
	public    bResponsiveOneColumn: boolean = false;
	public    width               : number  = 600;
	public    height              : number  = 600;
	public    objTabs             : any = {};
	public    bTabsEnabled        : boolean = false;
	public    arrPanels           : any[] = [];

	// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times.
	@Input()  CONTROL_VIEW_NAME : string  = null;
	@Input()  row               : any     = null;
	@Input()  layout            : EDITVIEWS_FIELD[] = null;
	@Input()  sPanelClass       : string  = null;
	@Input()  isSearchView      : boolean = false;
	@Output() Page_Command      : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();
	@Output() onFieldDidMount   : EventEmitter<{DATA_FIELD: string, component: any}>           = new EventEmitter<{DATA_FIELD: string, component: any}>          ();
	@Output() callback          : EventEmitter<{DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any}> = new EventEmitter<{DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any}>();
	@Output() createDependency  : EventEmitter<{DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string}> = new EventEmitter<{DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string}>();
	@Output() onChange          : EventEmitter<{DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any}> = new EventEmitter<{DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any}>();
	@Output() onUpdate          : EventEmitter<{PARENT_FIELD: string, DATA_VALUE: any, item?: any}> = new EventEmitter<{PARENT_FIELD: string, DATA_VALUE: any, item?: any}>();
	@Output() onSubmit          : EventEmitter<void> = new EventEmitter<void>();

	@ViewChildren("cell") refMap: QueryList<any>;

	public TypeOf(data: any)
	{
		return typeof(data);
	}

	constructor(private router: Router, private changeDetectorRef: ChangeDetectorRef, public SplendidCache : SplendidCacheService, public Credentials: CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, private EditView: EditViewService)
	{
		//console.log(this.constructor.name + '.constructor');
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit');
		try
		{
			// 03/19/2020 Paul.  We need to dynamically create a unique baseId as the Leads.EditView.Inline and Contacts.EditView.Inline are both on the Accounts.DetailView page, leading to a naming confict. 
			this.baseId = 'ctlEditView';
			if ( !Sql.IsEmptyString(this.CONTROL_VIEW_NAME) )
			{
				this.baseId += '_' + this.CONTROL_VIEW_NAME;
			}
			if ( this.layout != null && this.layout.length > 0 )
			{
				this.EDIT_NAME  = Sql.ToString(this.layout[0].EDIT_NAME );
				// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
				this.baseId    += '_' + this.EDIT_NAME.replace(/\./g, '_');
				let arrEDIT_NAME: string[] = this.EDIT_NAME.split('.');
				if ( arrEDIT_NAME.length > 0 )
				{
					this.MODULE_NAME = arrEDIT_NAME[0];
				}
			}
			if ( this.layout != null && this.layout.length > 0 )
			{
				this.EDIT_NAME = Sql.ToString(this.layout[0].EDIT_NAME );
				this.baseId      = 'ctlEditView_' + this.EDIT_NAME.replace(/\./g, '_');
			}

			this.sTheme               = this.Security.USER_THEME();
			this.bIsMobile            = isMobileDevice();
			this.bStackedTheme        = SplendidDynamic.StackedLayout(this.sTheme);
			this.bStackedLayout       = this.bStackedTheme;
			// 04/19/2021 Paul.  Manually calculate responsive features. 
			this.bResponsiveOneColumn = false;
			this.width                = screenWidth();
			this.height               = screenHeight();
			if ( this.height > this.width )
			{
				// portrait
				if ( this.width < 992 )
				{
					this.bResponsiveOneColumn = true;
				}
				if ( this.width < 540 )
				{
					this.bStackedLayout       = true;
				}
			}
			else
			{
				// landscape 
				if ( this.width < 900 )
				{
					this.bResponsiveOneColumn = true;
				}
				if ( this.width < 540 )
				{
					this.bStackedLayout       = true;
				}
			}
			this.objTabs      = {};
			this.bTabsEnabled = false;
			// 04/14/2022 Paul.  Add LayoutTabs to Pacific theme. 
			if ( this.sTheme == 'Pacific' )
			{
				let arrTabs: any[] = this.EditView.GetTabList(this.layout);
				if ( arrTabs != null && arrTabs.length > 0 )
				{
					let nActiveTabs: number = 0;
					for ( let i: number = 0; i < arrTabs.length; i++ )
					{
						let tab: any = arrTabs[i];
						this.objTabs[tab.nLayoutIndex] = tab;
						// 04/14/2022 Paul.  Make sure at least one tab is active. 
						if ( this.layout[tab.nLayoutIndex].ActiveTab )
						{
							nActiveTabs++;
						}
					}
					if ( nActiveTabs == 0 )
					{
						this.EditView.ActivateTab(this.layout, arrTabs[0].nLayoutIndex);
					}
					this.bTabsEnabled = true;
				}
			}
			this.AppendEditViewFields_Desktop();
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
	}

	ngAfterViewChecked(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewChecked');
	}

	// 04/23/2020 Paul.  A customer needs to know if the PopupView is being called from a SearchView or and EditView. 
	// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
	private AppendEditViewFields_Desktop()
	{
		let { SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules } = this;
		let { CONTROL_VIEW_NAME, layout, row, sPanelClass, isSearchView, MODULE_NAME, baseId, arrPanels, bIsMobile, bStackedLayout, bStackedTheme, bResponsiveOneColumn, bTabsEnabled, objTabs, sTheme } = this;

		//console.log(this.constructor.name + '.AppendDetailViewFields_Desktop');

		//console.log('AppendEditViewFields_Desktop (' +  width + ', ' + height + ') ' + (bIsMobile ? 'mobile' : ''));
		// 04/15/2022 Paul.  We need a separate panel index instead of simply using count of main children. 
		let nPanelIndex: number = 0;
		let tabFormChildren: any = [];
		let tabForm: any = {tag: 'div', props: { style: {display: 'inherit', width: '100%'}, class: (sPanelClass == 'tabForm' ? sPanelClass : '')}, children: tabFormChildren};
		arrPanels.push(tabForm);
		// 11/13/2019 Paul.  The width is in the skin, so we need to apply manually. 
		let tblMainChildren: any = [];
		let tblMainProps: any = { class: (sPanelClass == 'tabForm' ? 'tabEditView' : ''), id: baseId + '_tblMain' + nPanelIndex.toString(), style: { width: '100%' } };
		let tblMain: any = {tag: 'table', props: tblMainProps, children: tblMainChildren};
		tabFormChildren.push(tblMain);
		nPanelIndex++;
		if ( bStackedLayout )
		{
			tblMainProps.style.borderSpacing = '0px';
		}
		if ( layout == null )
		{
			return arrPanels;
		}
		try
		{
			let tblBodyChildren: any = [];
			let tbody: any = {tag: 'tbody', props: {}, children: tblBodyChildren};
			tblMainChildren.push(tbody);

			let trChildren              : any[]   = null;
			let tr                      : any     = null;
			let nColIndex               : number  = 0;
			let tdLabelChildren         : any[]   = [];
			let tdLabelProps            : any     = {};
			let tdLabel                 : any     = null;
			let tdFieldChildren         : any[]   = [];
			let tdFieldProps            : any     = { style: {} };
			let tdField                 : any     = null;
			let bEnableTeamManagement   : boolean = Crm_Config.enable_team_management();
			let bRequireTeamManagement  : boolean = Crm_Config.require_team_management();
			let bEnableDynamicTeams     : boolean = Crm_Config.enable_dynamic_teams();
			// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();
			let bRequireUserAssignment  : boolean = Crm_Config.require_user_assignment();
			// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 

			// 08/31/2012 Paul.  Add support for speech. 
			let bEnableSpeech           : boolean = Crm_Config.enable_speech();
			let sUSER_AGENT             : string  = navigator.userAgent;
			if ( sUSER_AGENT == 'Chrome' || sUSER_AGENT.indexOf('Android') > 0 || sUSER_AGENT.indexOf('iPad') > 0 || sUSER_AGENT.indexOf('iPhone') > 0 )
			{
				bEnableSpeech = Crm_Config.enable_speech();
			}
			// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
			let oNumberFormat : any    = Security.NumberFormatInfo();
			// 05/30/2018 Paul.  Make sure to use let so that callbacks get the proper scope variable. 
			// https://www.pluralsight.com/guides/javascript-callbacks-variable-scope-problem
			// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
			let bEnableTaxLineItems: boolean = Crm_Config.ToBoolean('Orders.TaxLineItems');
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			let themeURL   : string  = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
			let legacyIcons: boolean = Crm_Config.ToBoolean('enable_legacy_icons');

			// 11/12/2019 Paul.  Declare DATA_COLUMNS outside loop so that we can calculate the padding. 
			let DATA_COLUMNS        : number = 2;
			let sFlexLabelFieldWidth: string = '100%';
			for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				//alert(dumpObj(lay, 'EditViewUI.LoadView layout'));
				let EDIT_NAME                  = lay.EDIT_NAME;
				let FIELD_TYPE                 = lay.FIELD_TYPE;
				let DATA_LABEL                 = lay.DATA_LABEL;
				let DATA_FIELD                 = lay.DATA_FIELD;
				let DATA_FORMAT                = lay.DATA_FORMAT;
				let DISPLAY_FIELD              = lay.DISPLAY_FIELD;
				//let CACHE_NAME                 = lay.CACHE_NAME;
				//let LIST_NAME                  = lay.LIST_NAME;
				// 12/05/2012 Paul.  UI_REQUIRED is not used on SQLite, so use the DATA_REQUIRED value. 
				let UI_REQUIRED                = Sql.ToBoolean(lay.UI_REQUIRED) || Sql.ToBoolean(lay.DATA_REQUIRED);
				let ONCLICK_SCRIPT             = lay.ONCLICK_SCRIPT;
				//let FORMAT_SCRIPT              = lay.FORMAT_SCRIPT;
				//let FORMAT_TAB_INDEX           = Sql.ToInteger(lay.FORMAT_TAB_INDEX);
				//let FORMAT_MAX_LENGTH          = Sql.ToInteger(lay.FORMAT_MAX_LENGTH);
				//let FORMAT_SIZE                = Sql.ToInteger(lay.FORMAT_SIZE);
				//let FORMAT_ROWS                = Sql.ToInteger(lay.FORMAT_ROWS);
				//let FORMAT_COLUMNS             = Sql.ToInteger(lay.FORMAT_COLUMNS);
				let COLSPAN                    = Sql.ToInteger(lay.COLSPAN);
				//let ROWSPAN                    = Sql.ToInteger(lay.ROWSPAN);
				let LABEL_WIDTH                = lay.LABEL_WIDTH;
				let FIELD_WIDTH                = lay.FIELD_WIDTH;
				//let VIEW_NAME                  = lay.VIEW_NAME;
				//let FIELD_VALIDATOR_ID         = lay.FIELD_VALIDATOR_ID;
				//let FIELD_VALIDATOR_MESSAGE    = lay.FIELD_VALIDATOR_MESSAGE;
				//let UI_VALIDATOR               = lay.UI_VALIDATOR;
				//let VALIDATION_TYPE            = lay.VALIDATION_TYPE;
				//let REGULAR_EXPRESSION         = lay.REGULAR_EXPRESSION;
				//let DATA_TYPE                  = lay.DATA_TYPE;
				//let MININUM_VALUE              = lay.MININUM_VALUE;
				//let MAXIMUM_VALUE              = lay.MAXIMUM_VALUE;
				//let COMPARE_OPERATOR           = lay.COMPARE_OPERATOR;
				let MODULE_TYPE                = lay.MODULE_TYPE;
				//let FIELD_VALIDATOR_NAME       = lay.FIELD_VALIDATOR_NAME;
				let TOOL_TIP                   = lay.TOOL_TIP;
				//let VALID_RELATED              = false;
				//let RELATED_SOURCE_MODULE_NAME = lay.RELATED_SOURCE_MODULE_NAME;
				//let RELATED_SOURCE_VIEW_NAME   = lay.RELATED_SOURCE_VIEW_NAME;
				//let RELATED_SOURCE_ID_FIELD    = lay.RELATED_SOURCE_ID_FIELD;
				//let RELATED_SOURCE_NAME_FIELD  = lay.RELATED_SOURCE_NAME_FIELD;
				//let RELATED_VIEW_NAME          = lay.RELATED_VIEW_NAME;
				//let RELATED_ID_FIELD           = lay.RELATED_ID_FIELD;
				//let RELATED_NAME_FIELD         = lay.RELATED_NAME_FIELD;
				//let RELATED_JOIN_FIELD         = lay.RELATED_JOIN_FIELD;
				//let PARENT_FIELD               = lay.PARENT_FIELD;
				// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
				let bIsHidden: boolean            = lay.hidden;
				
				DATA_COLUMNS = Sql.ToInteger(lay.DATA_COLUMNS);
				if ( DATA_COLUMNS == 0 )
				{
					DATA_COLUMNS = 2;
				}
				if ( bResponsiveOneColumn )
				{
					DATA_COLUMNS = 1;
					COLSPAN      = 0;
				}
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				// 04/19/2019 Paul.  Calculate flex width. 
				sFlexLabelFieldWidth = Math.floor(100 / DATA_COLUMNS) + '%';
				// 04/19/2019 Paul.  Convert to single sell width by multiplying by columns. 
				let nLABEL_WIDTH = parseInt(LABEL_WIDTH.replace('%', ''));
				let nFIELD_WIDTH = parseInt(FIELD_WIDTH.replace('%', ''));
				// 08/25/2019 Paul.  With COLSPAN 3, we need to assume that it is the only field on the row. 
				if ( COLSPAN == 3 )
				{
					LABEL_WIDTH = nLABEL_WIDTH + '%';
					FIELD_WIDTH = (nLABEL_WIDTH * (DATA_COLUMNS - 1) + nFIELD_WIDTH * DATA_COLUMNS) + '%';
				}
				else
				{
					LABEL_WIDTH = nLABEL_WIDTH + '%';
					FIELD_WIDTH = nFIELD_WIDTH + '%';
				}

				let sGridLabel = 'dataLabel';
				let sGridInput = 'dataField';
				let bIsReadable  : boolean = true;
				let bIsWriteable : boolean = true;
				if ( SplendidCache.bEnableACLFieldSecurity )
				{
					let gASSIGNED_USER_ID: string = null;
					if ( row != null )
					{
						gASSIGNED_USER_ID = Sql.ToGuid(row.ASSIGNED_USER_ID);
					}
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(SplendidCache, Security, MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
					// 02/16/2011 Paul.  We should allow a Read-Only field to be searchable, so always allow writing if the name contains Search. 
					bIsWriteable = acl.IsWriteable() || EDIT_NAME.indexOf(".Search") >= 0;
					if ( !bIsWriteable )
					{
						// 11/11/2020 Paul.  No longer need this warning. 
						//console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView NOT WRITEABLE', MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					}
				}
				if ( !bIsReadable )
				{
					FIELD_TYPE = 'Blank';
				}
				
				if ( ( DATA_FIELD == 'TEAM_ID' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( !bEnableTeamManagement )
					{
						FIELD_TYPE = 'Blank';
						// 10/24/2012 Paul.  Clear the label to prevent a term lookup. 
						DATA_LABEL  = null;
						DATA_FIELD  = null;
						UI_REQUIRED = false;
					}
					else
					{
						if ( bEnableDynamicTeams )
						{
							// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
							// 10/20/2017 Paul.  Don't convert MyPipelineBySalesStage. 
							if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
							{
								DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								DATA_FIELD     = 'TEAM_SET_NAME';
								FIELD_TYPE     = 'TeamSelect';
								ONCLICK_SCRIPT = '';
								// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
								lay.DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								lay.DATA_FIELD     = 'TEAM_SET_NAME';
								lay.FIELD_TYPE     = 'TeamSelect';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						else
						{
							// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
							if ( FIELD_TYPE == 'TeamSelect' )
							{
								DATA_LABEL     = 'Teams.LBL_TEAM';
								DATA_FIELD     = 'TEAM_ID';
								DISPLAY_FIELD  = 'TEAM_NAME';
								FIELD_TYPE     = 'ModulePopup';
								MODULE_TYPE    = 'Teams';
								ONCLICK_SCRIPT = '';
								// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
								lay.DATA_LABEL     = 'Teams.LBL_TEAM';
								lay.DATA_FIELD     = 'TEAM_ID';
								lay.DISPLAY_FIELD  = 'TEAM_NAME';
								lay.FIELD_TYPE     = 'ModulePopup';
								lay.MODULE_TYPE    = 'Teams';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						// 11/25/2006 Paul.  Override the required flag with the system value. 
						// 01/01/2008 Paul.  If Team Management is not required, then let the admin decide. 
						// 97/06/2017 Paul.  Don't show required flag in search or popup. 
						// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
						// 06/19/2021 Paul.  WorkflowAlertShells does not require Team or User. 
						if ( bRequireTeamManagement && EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.MassUpdate') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('WorkflowAlertShells') < 0 )
						{
							UI_REQUIRED = true;
						}
					}
				}
				// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( (DATA_FIELD == 'ASSIGNED_USER_ID' || DATA_FIELD == 'ASSIGNED_SET_NAME') )
				{
					// 01/06/2018 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					if ( bEnableDynamicAssignment && DATA_FORMAT != "1" )
					{
						if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
						{
							DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							FIELD_TYPE     = 'UserSelect'            ;
							ONCLICK_SCRIPT = ''                      ;
							// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
							lay.DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							lay.DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							lay.FIELD_TYPE     = 'UserSelect'            ;
							lay.ONCLICK_SCRIPT = ''                      ;
						}
					}
					else
					{
						if ( FIELD_TYPE == 'UserSelect' )
						{
							DATA_LABEL     = '.LBL_ASSIGNED_TO';
							DATA_FIELD     = 'ASSIGNED_USER_ID';
							DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							FIELD_TYPE     = 'ModulePopup'     ;
							MODULE_TYPE    = 'Users'           ;
							ONCLICK_SCRIPT = ''                ;
							// 11/15/2019 Paul.  We need to correct the layout object so that we don't need to correct the edit components. 
							lay.DATA_LABEL     = '.LBL_ASSIGNED_TO';
							lay.DATA_FIELD     = 'ASSIGNED_USER_ID';
							lay.DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							lay.FIELD_TYPE     = 'ModulePopup'     ;
							lay.MODULE_TYPE    = 'Users'           ;
							lay.ONCLICK_SCRIPT = ''                ;
						}
					}
					// 06/19/2021 Paul.  bRequireUserAssignment is the correct flag here, not bRequireTeamManagement, but also, same rules for not in Search, MassUpdate or Popup. 
					// 06/19/2021 Paul.  WorkflowAlertShells does not require Team or User. 
					if ( bRequireUserAssignment && EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.MassUpdate') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('WorkflowAlertShells') < 0 )
					{
						UI_REQUIRED = true;
					}
				}
				// 04/04/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				else if ( DATA_FIELD == 'EXCHANGE_FOLDER' )
				{
					// 01/09/2021 Paul.  We need to hide the EXCHANGE_FOLDER field if the user does not have Exchange enabled. 
					if ( !Crm_Modules.ExchangeFolders(MODULE_NAME) || !Security.HasExchangeAlias() )
					{
						FIELD_TYPE = 'Blank';
						DATA_LABEL = '';
					}
				}
				// 12/13/2013 Paul.  Allow each product to have a default tax rate. 
				else if ( DATA_FIELD == 'TAX_CLASS' )
				{
					if ( bEnableTaxLineItems )
					{
						// 07/22/2019 Paul.  Also correct these values in the ListBox component as changing the cache here will make no difference. 
						DATA_LABEL = "ProductTemplates.LBL_TAXRATE_ID";
						DATA_FIELD = "TAXRATE_ID";
						//CACHE_NAME = "TaxRates";
					}
				}
				
				if ( FIELD_TYPE == 'Blank' )
				{
					UI_REQUIRED = false;
				}
				// 04/14/2022 Paul.  Add LayoutTabs to Pacific theme. 
				if ( !bTabsEnabled && FIELD_TYPE == 'Header' && DATA_FORMAT == 'tab-only' )
				{
					// 04/14/2022 Paul.  Ignore the layout field if tabs not enabled (i.e. not Pacific) and this is only to be used as a tab. 
					continue;
				}
				else if ( bTabsEnabled && objTabs[nLayoutIndex] )
				{
					// 04/14/2022 Paul.  We don't want an empty panel, so if current panel is empty, then continue to use and correct the display style. 
					if ( nLayoutIndex == 0 )
					{
						let style: any = tabForm.props.style;
						style.display = (lay.ActiveTab ? 'inherit' : 'none');
						nPanelIndex++;
					}
					else
					{
						tabFormChildren = [];
						tabForm         = {tag: 'div', props: { style: {width: '100%', display: (lay.ActiveTab ? 'inherit' : 'none')}, class: (sPanelClass == 'tabForm' ? sPanelClass : '')}, children: tabFormChildren};
						arrPanels.push(tabForm);
						tblMainChildren = [];
						tblMainProps    = { class: (sPanelClass == 'tabForm' ? 'tabEditView' : ''), id: baseId + '_tblMain' + nPanelIndex.toString(), style: {width: '100%', marginTop: '5px'} };
						tblMain         = {tag: 'table', props: tblMainProps, children: tblMainChildren};
						tabFormChildren.push(tblMain);
						if ( bStackedLayout )
						{
							tblMainProps.style.borderSpacing = '0px';
						}
						tblBodyChildren = [];
						tbody           = {tag: 'tbody', props: {}, children: tblBodyChildren};
						tblMainChildren.push(tbody);
						nPanelIndex++;
					}
					nColIndex = 0;
					tr = null;
					continue;
				}
				// 09/02/2012 Paul.  A separator will create a new table. We need to match the outer and inner layout. 
				else if ( FIELD_TYPE == 'Separator' )
				{
					// 11/12/2019 Paul.  Add remaining cells. 
					// 04/19/2021 Paul.  This does not apply to desktop mode. 
					/*
					for ( let i = 0; i < tblBodyChildren.length % DATA_COLUMNS; i++ )
					{
						trChildren = [];
						tr = React.createElement('tr', trChildren);
						tblBodyChildren.push(tr);
					}
					*/
					
					tabFormChildren = [];
					tabForm         = {tag: 'div', props: { style: {display: 'inherit', width: '100%'}, class: (sPanelClass == 'tabForm' ? sPanelClass : '')}, children: tabFormChildren};
					// 04/16/2022 Paul.  Separators usually start a new table or division, so separators after active tab need to be treated as a set. 
					if ( bTabsEnabled )
					{
						let style: any = tabForm.props.style;
						style.display = (lay.ActiveTab ? 'inherit' : 'none');
					}
					arrPanels.push(tabForm);
					tblMainChildren = [];
					tblMainProps    = { class: (sPanelClass == 'tabForm' ? 'tabEditView' : ''), id: baseId + '_tblMain' + nPanelIndex.toString(), style: {width: '100%', marginTop: '5px'} };
					tblMain         = {tag: 'table', props: tblMainProps, children: tblMainChildren};
					tabFormChildren.push(tblMain);
					if ( bStackedLayout )
					{
						tblMainProps.style.borderSpacing = '0px';
					}
					// 04/16/2022 Paul.  Separators usually start a new table or division, so separators after active tab need to be treated as a set. 
					if ( bTabsEnabled )
					{
						tblMainProps.style.display = (lay.ActiveTab ? 'table' : 'none');
						nPanelIndex++;
					}
					tblBodyChildren = [];
					tbody           = {tag: 'tbody', props: {}, children: tblBodyChildren};
					tblMainChildren.push(tbody);
					nColIndex = 0;
					tr = null;
					continue;
				}
				// 09/03/2012 Paul.  We are going to ignore address buttons. 
				else if ( FIELD_TYPE == 'AddressButtons' )
				{
					continue;
				}
				// 11/17/2007 Paul.  On a mobile device, each new field is on a new row. 
				// 12/02/2005 Paul.  COLSPAN == -1 means that a new column should not be created. 
				// 12/06/2014 Paul.  Use new mobile flag. 
				// 02/26/2016 Paul.  We do not want the 1 column layout for the search panel on an OfficeAddin. 
				if ( (COLSPAN >= 0 && nColIndex == 0) || tr == null || (bIsMobile && EDIT_NAME.indexOf('.SearchSubpanel.OfficeAddin') < 0) )
				{
					// 11/25/2005 Paul.  Don't pre-create a row as we don't want a blank
					// row at the bottom.  Add rows just before they are needed. 
					trChildren = [];
					// 08/25/2019 Paul.  This is the correct place to handle colspan. 
					// 04/04/2022 Paul.  sFlexLabelFieldWidth is only used for Stacked layout. 
					//if ( COLSPAN == 3 )
					//{
					//	sFlexLabelFieldWidth  = '100%';
					//}
					tr         = {tag: 'tr', props: {}, children: trChildren};
					tblBodyChildren.push(tr);
				}
				// 06/20/2009 Paul.  The label and the field will be on separate rows for a NewRecord form. 
				let trLabelChildren = trChildren;
				let trLabel = tr;
				let trFieldChildren = trChildren;
				let trField = tr;
				if ( COLSPAN >= 0 || tdLabel == null || tdField == null )
				{
					// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
					if ( bStackedLayout )
					{
						tdLabelProps = { class: sGridLabel, style: {} };
						tdFieldProps = { class: sGridInput, style: {} };
						
						tdLabelChildren = [];
						tdLabelProps.id  = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						tdLabelProps.key = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						
						tdFieldChildren = [];
						tdFieldProps.key = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						tdFieldProps.id  = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						
						let tdStackChildren: any = [];
						let tdStackProps: any = { style: {} };
						if ( bStackedTheme )
						{
							// 04/04/2022 Paul.  Columns are not getting equal width. 
							tdStackProps.style.width = sFlexLabelFieldWidth;
							tdStackProps.class   = 'tabStackedEditViewDF';
							tdLabelProps.class   = 'tabStackedEditViewDL';
							// 04/04/2022 Paul.  Can't seem to select the Serach view with existing css, so add new class. 
							if ( sTheme == 'Pacific' && isSearchView )
							{
								tdStackProps.class = 'tabStackedEditViewDF tabStackedEditViewDFSearch';
								tdLabelProps.class = 'tabStackedEditViewDL tabStackedEditViewDLSearch';
							}
							// 04/04/2022 Paul.  Must support colspan in the normal way. 
							if ( COLSPAN > 0 )
							{
								tdStackProps.colSpan = (COLSPAN + 1) / 2;
							}
						}
						//else
						{
							tdLabelProps.style.lineHeight = 'inherit';
							tdLabelProps.style.textAlign  = 'inherit';
							tdStackProps.style.padding    = '0px';
						}
						if ( sTheme == 'Pacific' && !isSearchView )
						{
							tdStackProps.style.paddingLeft  = '1em';
							tdStackProps.style.paddingRight = '1em';
							// 04/16/2022 Paul.  We seem to need to force the width when multiple panels are displayed. 
							tdStackProps.style.width        = sFlexLabelFieldWidth;
							if ( DATA_COLUMNS > 1 && COLSPAN <= 1 )
							{
								if ( (nColIndex < DATA_COLUMNS - 1) )
								{
									tdStackProps.style.borderRight = '.0625rem solid #93a4b3';
								}
							}
						}
						// 03/19/2020 Paul.  Center instead of baseline or top. 
						
						let tdStack: any = {tag: 'td', props: tdStackProps, children: tdStackChildren};
						trChildren.push(tdStack);
						// 08/25/2019 Paul.  For ChangeButton with PARENT_TYPE, we need to have the control handle it as there is an interaction between label and field. 
						if ( !(FIELD_TYPE == 'ChangeButton' && DATA_LABEL == 'PARENT_TYPE') )
						{
							tdLabel = {tag: 'div', props: tdLabelProps, children: tdLabelChildren};
							tdStackChildren.push(tdLabel);
						}

						tdField = {tag: 'div', props: tdFieldProps, children: tdFieldChildren};
						if ( FIELD_TYPE != 'Header' )
						{
							tdStackChildren.push(tdField);
						}
					}
					else
					{
						tdLabelChildren = [];
						tdLabelProps = { style: {} };
						tdLabelProps.id  = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						tdLabelProps.key = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
						tdLabelProps.class = sGridLabel;
						// 11/12/2019 Paul.  Default top align looks terrible. 
						// 12/17/2019 Paul.  Baseline looks better than center, especially for multi-line controls such as Teams and Tags. 
						// 03/19/2020 Paul.  Center instead of baseline or top. 
						tdLabelProps.style = { width: LABEL_WIDTH };
						if ( FIELD_TYPE == 'Header' )
						{
							if ( !bStackedLayout )
								tdLabelProps.colSpan = 2;
						}
						
						tdFieldChildren = [];
						tdFieldProps = { style: {} };
						// 08/25/2019 Paul.  For ChangeButton with PARENT_TYPE, we need to have the control handle it as there is an interaction between label and field. 
						if ( !(FIELD_TYPE == 'ChangeButton' && DATA_LABEL == 'PARENT_TYPE') )
						{
							tdLabel = {tag: 'td', props: tdLabelProps, children: tdLabelChildren};
							trLabelChildren.push(tdLabel);
						}
						else
						{
							// 08/25/2019 Paul.  And give 100% of the cell to the control to manage. 
							//FIELD_WIDTH = (nFIELD_WIDTH + nLABEL_WIDTH).toString() + '%';
							// 05/06/2021 Paul.  Need to force the span as the label and field use the same cell. 
							COLSPAN = 3;
						}

						tdFieldProps.key = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						tdFieldProps.id  = FIELD_TYPE + 'tdfield' + nLayoutIndex;
						tdFieldProps.class = sGridInput;
						if ( COLSPAN > 0 )
						{
							tdFieldProps.colSpan = (COLSPAN + 1) / 2;
						}
						// 11/28/2005 Paul.  Don't use the field width if COLSPAN is specified as we want it to take the rest of the table.  The label width will be sufficient. 
						if ( COLSPAN == 0 )
						{
							tdFieldProps.style = { width: FIELD_WIDTH };
						}
						tdField = {tag: 'td', props: tdFieldProps, children: tdFieldChildren};
						if ( FIELD_TYPE != 'Header' )
						{
							trLabelChildren.push(tdField);
						}
					}
					// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
					if ( !bIsHidden )
					{
						// 04/28/2019 Paul.  Header text goes in the field column, leaving the label column blank. 
						if ( DATA_LABEL != null && FIELD_TYPE != 'Header' )
						{
							if ( DATA_LABEL.indexOf('.') >= 0 )
							{
								let txt = L10n.Term(DATA_LABEL);
								// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
								// 01/29/2020 Paul.  Allow the label to contain HTML. 
								// 03/19/2020 Paul.  Make sure that tag exists, otherwise labels will not be aligned right. 
								if ( txt.indexOf('</span>') >= 0 )
								{
									let html: any = {tag: 'span', props: {innerHTML: txt}, children: null};
									tdLabelChildren.push(html);
								}
								else
								{
									txt = Sql.ReplaceEntities(txt);
									tdLabelChildren.push(txt);
								}
							}
							else if ( !Sql.IsEmptyString(DATA_LABEL) && row != null )
							{
								// 06/21/2015 Paul.  Label can contain raw text. 
								let sLabel = row[DATA_LABEL];
								if ( sLabel === undefined )
								{
									sLabel = Sql.ToString(DATA_LABEL);
								}
								else
								{
									sLabel = Sql.ToString(sLabel) + ':';
								}
								// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
								let txt = Sql.ReplaceEntities(sLabel);
								tdLabelChildren.push(txt);
							}
							// 07/24/2019 Paul.  Tool tip as simple hover. 
							if ( !Sql.IsEmptyString(TOOL_TIP) )
							{
								let sTOOL_TIP = TOOL_TIP;
								if ( TOOL_TIP.indexOf('.') >= 0 )
								{
									sTOOL_TIP = L10n.Term(TOOL_TIP);
								}
								let text: any = {tag: 'span', props: {class: 'reactTooltipText'}, children: [sTOOL_TIP]};
								// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
								let icon: any = null;
								if ( legacyIcons )
									icon = {tag: 'img', props: {src: (themeURL + 'tooltip_inline.gif')}, children: null};
								else
									icon = {tag: 'fa-icon', props: {icon: 'question' }, children: null};
								let tip: any  = {tag: 'span', props: {class: 'reactTooltip'}, children: [icon, text]};
								tdLabelChildren.push(tip);
							}
						}
						// 08/06/2020 Paul.  Hidden fields cannot be required. 
						if ( UI_REQUIRED && FIELD_TYPE != 'Hidden' )
						{
							let lblRequired: any = {tag: 'span', props: { class: 'required'}, children: [L10n.Term('.LBL_REQUIRED_SYMBOL')]};
							tdLabelChildren.push(lblRequired);
						}
					}
				}
				let key = baseId + '_FieldIndex_' + lay.FIELD_INDEX;
				// 06/04/2022 Paul.  I don't think we will use refMap.
				/*
				if ( !Sql.IsEmptyString(DATA_FIELD) )
				{
					if ( refMap[DATA_FIELD] == null )
					{
						key = DATA_FIELD;
					}
					else
					{
						console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView ' + EDIT_NAME + '.' + DATA_FIELD + ' already exists in refMap.');
					}
				}
				let ref = React.createRef<EditComponent<any, any>>();
				refMap[key] = ref;
				*/
				//alert(DATA_FIELD);
				try
				{

					if ( FIELD_TYPE == 'Blank' )
					{
						tdLabelChildren.push('\u00a0');
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'Blank', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					// 09/03/2012 Paul.  A header is similar to a label, but without the data field. 
					else if ( FIELD_TYPE == 'Header' )
					{
						tdLabelChildren.pop();
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'Header', props: txtProps, children: null};
						// 04/18/2021 Paul.  Remove this from Desktop mode. 
						//tdLabelProps.style.width = (nLABEL_WIDTH + nFIELD_WIDTH * 2) + '%';
						tdLabelChildren.push(txt);
						// 08/08/2019 Paul.  We need to reset the table so that the next field will start on a new line. 
						// 10/31/2019 Paul.  A header does not force a new line.  This is so a header can be at the top of each column, like Billing and Shipping for Quotes. 
						// 04/20/2021 Paul.  Reset the row. 
						if ( COLSPAN == 3 )
						{
							tr = null;
							nColIndex = 0;
						}
					}
					else if ( FIELD_TYPE == 'Hidden' )
					{
						// 02/28/2008 Paul.  When the hidden field is the first in the row, we end up with a blank row. 
						// Just ignore for now as IE does not have a problem with the blank row. 
						COLSPAN = -1;
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'Hidden', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ModuleAutoComplete' )
					{
						// 11/21/2021 Paul.  Use Page_Command to send AutoComplete selection event. 
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden, Page_Command: this._onPage_Command };
						let txt: any = {tag: 'ModuleAutoComplete', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ModulePopup' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden, isSearchView };
						// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
						if ( DATA_FIELD == 'PRODUCT_TEMPLATE_ID' )
						{
							txtProps.allowCustomName = true;
						}
						let txt: any = {tag: 'ModulePopup', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ChangeButton' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'ChangeButton', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'TeamSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'TeamSelect', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( FIELD_TYPE == 'UserSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'UserSelect', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					// 05/14/2016 Paul.  Add Tags module. 
					else if ( FIELD_TYPE == 'TagSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'TagSelect', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					// 06/07/2017 Paul.  Add NAICSCodes module. 
					else if ( FIELD_TYPE == 'NAICSCodeSelect' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'NAICSCodeSelect', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'TextBox' )
					{
						// 11/02/2019 Paul.  layout changes are not detected, so we need to send the hidden field as a separate property. 
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						// 09/27/2020 Paul.  We need to be able to disable the default grow on TextBox. 
						if ( nLayoutIndex+1 < layout.length )
						{
							let layNext = layout[nLayoutIndex + 1];
							if ( Sql.ToInteger(layNext.COLSPAN) == -1 )
							{
								txtProps.bDisableFlexGrow = true;
							}
						}
						let txt: any = {tag: 'TextBox', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'HtmlEditor' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'HtmlEditor', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					// 04/14/2016 Paul.  Add ZipCode lookup. 
					else if ( FIELD_TYPE == 'ZipCodePopup' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'ZipCodePopup', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					// 05/24/2017 Paul.  Need support for DateRange for new Dashboard. 
					else if ( FIELD_TYPE == 'DateRange' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'DateRange', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DatePicker' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'DatePicker', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DateTimeEdit' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'DateTimeEdit', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DateTimeNewRecord' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'DateTimeNewRecord', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'DateTimePicker' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'DateTimePicker', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'TimePicker' )
					{
						let txtProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, onSubmit: this._onSubmit, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let txt: any = {tag: 'TimePicker', props: txtProps, children: null};
						tdFieldChildren.push(txt);
					}
					else if ( FIELD_TYPE == 'ListBox' )
					{
						let lstProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let lst: any = {tag: 'ListBox', props: lstProps, children: null};
						tdFieldChildren.push(lst);
					}
					// 08/01/2013 Paul.  Add support for CheckBoxList. 
					else if ( FIELD_TYPE == 'CheckBoxList' )
					{
						let lstProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let lst: any = {tag: 'CheckBoxList', props: lstProps, children: null};
						tdFieldChildren.push(lst);
					}
					// 08/01/2013 Paul.  Add support for Radio. 
					else if ( FIELD_TYPE == 'Radio' )
					{
						let chkProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let chk: any = {tag: 'Radio', props: chkProps, children: null};
						tdFieldChildren.push(chk);
					}
					else if ( FIELD_TYPE == 'CheckBox' )
					{
						let chkProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let chk: any = {tag: 'CheckBox', props: chkProps, children: null};
						tdFieldChildren.push(chk);
					}
					else if ( FIELD_TYPE == 'Label' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let lbl: any = {tag: 'Label', props: lblProps, children: null};
						tdFieldChildren.push(lbl);
					}
					// 05/27/2016 Paul.  Add support for File type. 
					else if ( FIELD_TYPE == 'File' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let lbl: any = {tag: 'SplendidFile', props: lblProps, children: null};
						tdFieldChildren.push(lbl);
					}
					// 11/04/2019 Paul.  Add support for Button type. 
					else if ( FIELD_TYPE == 'Button' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden, Page_Command: this._onPage_Command };
						let lbl: any = {tag: 'SplendidButton', props: lblProps, children: null};
						tdFieldChildren.push( lbl );
					}
					// 07/01/2020 Paul.  Add support for Image type. 
					else if ( FIELD_TYPE == 'Image' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let lbl: any = {tag: 'SplendidImage', props: lblProps, children: null};
						tdFieldChildren.push(lbl);
					}
					// 07/02/2020 Paul.  Add support for Picture type. 
					else if ( FIELD_TYPE == 'Picture' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let lbl: any = {tag: 'Picture', props: lblProps, children: null};
						tdFieldChildren.push(lbl);
					}
					// 07/04/2020 Paul.  Add support for Password type. 
					else if ( FIELD_TYPE == 'Password' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let lbl: any = {tag: 'Password', props: lblProps, children: null};
						tdFieldChildren.push(lbl);
					}
					// 03/28/2021 Paul.  Add support for CRON type. 
					else if ( FIELD_TYPE == 'CRON' )
					{
						let lblProps: any = { baseId, key, row, layout: lay, onChanged: this._onChanged, createDependency: this._onCreateDependency, fieldDidMount: this._onFieldDidMount, onUpdate: this._onUpdate, bIsWriteable, bIsHidden };
						let lbl: any = {tag: 'CRON', props: lblProps, children: null};
						tdFieldChildren.push(lbl);
					}
					else
					{
						//08/31/2012 Paul.  Add debugging code. 
						console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView.AppendEditViewFields() Unknown field type: ' + FIELD_TYPE);
					}
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendEditViewFields ' + FIELD_TYPE + ' ' + DATA_FIELD, error);
				}
				// 12/02/2007 Paul.  Each view can now have its own number of data columns. 
				// This was needed so that search forms can have 4 data columns. The default is 2 columns. 
				if ( COLSPAN > 0 )
				{
					nColIndex += COLSPAN;
				}
				else if ( COLSPAN == 0 )
				{
					nColIndex++;
				}
				if ( nColIndex >= DATA_COLUMNS )
				{
					nColIndex = 0;
				}
			}
			// 11/12/2019 Paul.  Add remaining cells. 
			// 04/18/2021 Paul.  Not needed for desktop layout. 
			/*
			for ( let i = 0; i < tblBodyChildren.length % DATA_COLUMNS; i++ )
			{
				trChildren = [];
				if ( SplendidDynamic.StackedLayout(sTheme) )
					tr: any = {tag: 'div', props: { class: 'tabStackedEditViewDF', style: { flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '1px 5px' } }, trChildren);
				else
					tr: any = {tag: 'div', props: { style: { display: 'flex', flexDirection: 'row', flexWrap: 'wrap', flex: '1 0 ' + sFlexLabelFieldWidth, padding: '1px 5px' } }, trChildren);
				tblBodyChildren.push(tr);
			}
			*/
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendEditViewFields', error);
		}
		return arrPanels;
	}

	public _onFieldDidMount = (obj: {DATA_FIELD: string, component: any}) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onFieldDidMount', obj);
		this.onFieldDidMount.emit(obj);
	}

	public _onCreateDependency = (obj: {DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string}) =>
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onCreateDependency', obj);
		this.createDependency.emit(obj);
	}

	public _onChanged = (obj: {DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any}) =>
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChanged', obj);
		if ( this.callback.observed )
		{
			this.callback.emit(obj);
		}
		else
		{
			this.onChange.emit(obj);
		}
	}

	public _onUpdate = (obj: {PARENT_FIELD: string, DATA_VALUE: any, item?: any}) =>
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate', obj);
		this.onUpdate.emit(obj);
	}

	public _onSubmit = () =>
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit');
		this.onSubmit.emit();
	}

	public _onPage_Command = (obj: {sCommandName: string, sCommandArguments: any}) =>
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onPage_Command', obj);
		this.Page_Command.emit(obj);
	}

	public BuildDataRow(row: any): number
	{
		const { refMap } = this;
		let nInvalidFields: number = 0;
		refMap.forEach(ref =>
		{
			if ( !ref.validate() )
			{
				nInvalidFields++;
			}
			else
			{
				let data = ref.data;
				// 07/05/2019 Paul.  Data may be an array of key/value pairs.  This is true of TeamSelect and UserSelect. 
				if ( data )
				{
					if ( Array.isArray(data) )
					{
						for ( let i = 0; i < data.length; i++  )
						{
							if ( data[i].key )
							{
								row[data[i].key] = data[i].value;
							}
						}
					}
					else if ( data.key )
					{
						row[data.key] = data.value;
						if ( data.files && Array.isArray(data.files) )
						{
							if ( row.Files === undefined )
							{
								row.Files = new Array();
							}
							for ( let i = 0; i < data.files.length; i++ )
							{
								row.Files.push(data.files[i]);
							}
						}
					}
				}
			}
		});
		return nInvalidFields;
	}

	public Validate(): number
	{
		const { refMap } = this;
		let nInvalidFields = 0;
		refMap.forEach(ref =>
		{
			if ( !ref.validate() )
			{
				nInvalidFields++;
			}
		});
		return nInvalidFields;
	}

	public Clear(): void
	{
		const { refMap } = this;
		refMap.forEach(ref =>
		{
			ref.clear();
		});
	}

	public updateDependancy(DATA_FIELD: string, PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		const { refMap } = this;
		refMap.forEach(ref =>
		{
			if ( ref.DATA_FIELD == DATA_FIELD )
			{
				ref.updateDependancy(PARENT_FIELD, DATA_VALUE, PROPERTY_NAME, item);
			}
		});
	}
}
