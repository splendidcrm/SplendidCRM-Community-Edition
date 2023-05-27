import { Component, OnInit, Input, Output, EventEmitter, ChangeDetectorRef } from '@angular/core'                         ;
import { Router, ActivatedRoute, ParamMap                             } from '@angular/router'                       ;
import { faSpinner                                                    } from '@fortawesome/free-solid-svg-icons'     ;

import { SplendidCacheService                                         } from '../scripts/SplendidCache'              ;
import { CredentialsService                                           } from '../scripts/Credentials'                ;
import { SecurityService                                              } from '../scripts/Security'                   ;
import { L10nService                                                  } from '../scripts/L10n'                       ;
import { CrmConfigService, CrmModulesService                          } from '../scripts/Crm'                        ;
import { DetailViewService                                            } from '../scripts/DetailView'                 ;
import { isMobileDevice, isMobileLandscape, screenWidth, screenHeight } from '../scripts/utility'                    ;
import Sql                                                              from '../scripts/Sql'                        ;
import SplendidDynamic                                                  from '../scripts/SplendidDynamic'            ;
import MODULE                                                           from '../types/MODULE'                       ;
import DYNAMIC_BUTTON                                                   from '../types/DYNAMIC_BUTTON'               ;
import ACL_ACCESS                                                       from '../types/ACL_ACCESS'                   ;
import ACL_FIELD_ACCESS                                                 from '../types/ACL_FIELD_ACCESS'             ;
import DETAILVIEWS_FIELD                                                from '../types/DETAILVIEWS_FIELD'            ;

@Component({
	selector: 'SplendidDynamic_DetailView',
	templateUrl: './SplendidDynamic_DetailView.html',
})
export class SplendidDynamic_DetailViewComponent implements OnInit
{
	public    JSON                = JSON          ;

	public    error               : any     = null;
	public    spinner             = faSpinner     ;
	public    DETAIL_NAME         : string  = null;
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
	public    fragmentChildren    : any[] = [];

	@Input()  row               : any    = null;
	@Input()  layout            : DETAILVIEWS_FIELD[] = null;
	@Input()  sPanelClass       : string = null;
	@Output() Page_Command      : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();
	@Output() onFieldDidMount   : EventEmitter<{DATA_FIELD: string, component: any}>           = new EventEmitter<{DATA_FIELD: string, component: any}>          ();

	public TypeOf(data: any)
	{
		return typeof(data);
	}

	constructor(private router: Router, private changeDetectorRef: ChangeDetectorRef, public SplendidCache : SplendidCacheService, public Credentials: CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, private DetailView: DetailViewService)
	{
		//console.log(this.constructor.name + '.constructor');
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit');
		try
		{
			// 03/19/2020 Paul.  We need to dynamically create a unique baseId as the Leads.EditView.Inline and Contacts.EditView.Inline are both on the Accounts.DetailView page, leading to a naming confict. 
			this.baseId = 'ctlDetailView';
			if ( this.layout != null && this.layout.length > 0 )
			{
				this.DETAIL_NAME = Sql.ToString(this.layout[0].DETAIL_NAME );
				this.baseId      = 'ctlDetailView_' + this.DETAIL_NAME.replace(/\./g, '_');
			}

			this.sTheme               = this.Security.USER_THEME();
			this.bIsMobile            = isMobileDevice();
			this.bStackedTheme        = SplendidDynamic.StackedLayout(this.sTheme) && this.sPanelClass != 'tabPreviewView';
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
			// 04/14/2022 Paul.  Add LayoutTabs to Pacific theme. 
			this.objTabs      = {};
			this.bTabsEnabled = false;
			if ( this.sTheme == 'Pacific' )
			{
				let arrTabs: any[] = this.DetailView.GetTabList(this.layout);
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
						this.DetailView.ActivateTab(this.layout, arrTabs[0].nLayoutIndex);
					}
					this.bTabsEnabled = true;
				}
			}
			this.AppendDetailViewFields_Desktop();
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

	private AppendDetailViewFields_Desktop()
	{
		let { SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules } = this;
		let { layout, row, sPanelClass, baseId, fragmentChildren, bIsMobile, bStackedLayout, bStackedTheme, bResponsiveOneColumn, bTabsEnabled, objTabs, sTheme } = this;

		//console.log(this.constructor.name + '.AppendDetailViewFields_Desktop');
		// 04/15/2022 Paul.  We need a separate panel index instead of simply using count of main children. 
		let nPanelIndex: number = 0;
		let tblMainChildren: any = [];
		let tblMainProps: any = { class: sPanelClass, id: baseId + '_tblMain' + nPanelIndex.toString(), style: {} };
		let tblMain: any = {tag: 'table', props: tblMainProps, children: tblMainChildren};
		fragmentChildren.push(tblMain);
		nPanelIndex++;
		if ( bStackedLayout )
		{
			tblMainProps.style.borderSpacing = '0px';
		}
		try
		{
			// 10/17/2012 Paul.  Exit if the Main does not exist.  This is a sign that the user has navigated elsewhere. 
			if (tblMain == null)
				return;
			let tblBodyChildren: any = [];
			let tbody: any = {tag: 'tbody', props: {}, children: tblBodyChildren};
			tblMainChildren.push(tbody);
			let trChildren: any = [];
			let tr = null;
			let nColumn = 0;
			let bEnableTeamManagement = Crm_Config.enable_team_management();
			let bEnableDynamicTeams   = Crm_Config.enable_dynamic_teams();
			// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
			let oNumberFormat = Security.NumberFormatInfo();
			// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
			let ERASED_FIELDS: string[] = [];
			if ( Crm_Config.enable_data_privacy() )
			{
				if ( row['ERASED_FIELDS'] !== undefined )
				{
					ERASED_FIELDS = Sql.ToString(row['ERASED_FIELDS']).split(',');
				}
			}
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			let themeURL   : string  = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
			let legacyIcons: boolean = Crm_Config.ToBoolean('enable_legacy_icons');
	
			// 11/12/2019 Paul.  Declare DATA_COLUMNS outside loop so that we can calculate the padding. 
			let DATA_COLUMNS        : number = 2;
			let sFlexLabelFieldWidth: string = '100%';
			for (let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++)
			{
				let lay = layout[nLayoutIndex];
				let DETAIL_NAME : string = Sql.ToString (lay.DETAIL_NAME );
				let FIELD_INDEX : number = Sql.ToInteger(lay.FIELD_INDEX );
				let FIELD_TYPE  : string = Sql.ToString (lay.FIELD_TYPE  );
				let DATA_LABEL  : string = Sql.ToString (lay.DATA_LABEL  );
				let DATA_FIELD  : string = Sql.ToString (lay.DATA_FIELD  );
				let DATA_FORMAT : string = Sql.ToString (lay.DATA_FORMAT );
				let URL_FIELD   : string = Sql.ToString (lay.URL_FIELD   );
				//let URL_FORMAT  : string = Sql.ToString (lay.URL_FORMAT  );
				//let URL_TARGET  : string = Sql.ToString (lay.URL_TARGET  );
				//let LIST_NAME   : string = Sql.ToString (lay.LIST_NAME   );
				let COLSPAN     : number = Sql.ToInteger(lay.COLSPAN     );
				let LABEL_WIDTH : string = Sql.ToString (lay.LABEL_WIDTH );
				let FIELD_WIDTH : string = Sql.ToString (lay.FIELD_WIDTH );
				//let VIEW_NAME   : string = Sql.ToString (lay.VIEW_NAME   );
				let MODULE_NAME : string = Sql.ToString (lay.MODULE_NAME );
				let TOOL_TIP    : string = Sql.ToString (lay.TOOL_TIP    );
				//let MODULE_TYPE : string = Sql.ToString (lay.MODULE_TYPE );
				//let PARENT_FIELD: string = Sql.ToString (lay.PARENT_FIELD);
				//console.log((new Date()).toISOString() + ' ' + DETAIL_NAME + '\t' + FIELD_INDEX.toString() + '\t' + FIELD_TYPE + '\t' + DATA_LABEL + '\t' + DATA_FIELD + '\t' + URL_FIELD);
				// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
				let bIsHidden   : boolean = lay.hidden;

				// 02/28/2014 Paul.  We are going to start using the data column in the Preview panel. 
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

				let sGridLabel: string = 'tabDetailViewDL';
				let sGridInput: string = 'tabDetailViewDF';
				if ( (DATA_FIELD == 'TEAM_NAME' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( !bEnableTeamManagement )
					{
						FIELD_TYPE = 'Blank';
					}
					else if ( bEnableDynamicTeams )
					{
						DATA_LABEL = '.LBL_TEAM_SET_NAME';
						DATA_FIELD = 'TEAM_SET_NAME'     ;
					}
				}
				// 04/04/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				if ( DATA_FIELD == 'EXCHANGE_FOLDER' )
				{
					// 01/09/2021 Paul.  We need to hide the EXCHANGE_FOLDER field if the user does not have Exchange enabled. 
					if ( !Crm_Modules.ExchangeFolders(MODULE_NAME) || !Security.HasExchangeAlias() )
					{
						FIELD_TYPE = 'Blank';
					}
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
						let style: any = tblMain.props.style;
						style.display = (lay.ActiveTab ? 'table' : 'none');
						nPanelIndex++;
					}
					else
					{
						tblMainChildren = [];
						tblMain = {tag: 'table', props: { class: sPanelClass, id: baseId + '_tblMain' + nPanelIndex.toString(), style: {display: (lay.ActiveTab ? 'table' : 'none')} }, children: tblMainChildren};
						fragmentChildren.push(tblMain);
						tblBodyChildren = [];
						tbody = {tag: 'tbody', props: {}, children: tblBodyChildren};
						tblMainChildren.push(tbody);
						nPanelIndex++;
					}

					nColumn = 0;
					trChildren = [];
					tr = null;
					continue;
				}
				// 09/02/2012 Paul.  A separator will create a new table. We need to match the outer and inner layout. 
				// 08/04/2019 Paul.  Line works like a Separator. 
				else if ( FIELD_TYPE == 'Separator' || FIELD_TYPE == 'Line' )
				{
					if ( sTheme != 'Pacific' )
					{
						// 10/27/2020 Paul.  Need to force a break using flex.  Requires that the container be allowed to wrap. 
						// https://tobiasahlin.com/blog/flexbox-break-to-new-row/
						let divSeparator: any = {tag: 'div', props: { style: {flexBasis: '100%', height: 0} }, children: null}
						// 04/16/20222 Paul.  Separator needs to be added to fragment (same as tblMain), otherwise it goes into the table in an invalid position. 
						fragmentChildren.push(divSeparator);
					}
					
					tblMainChildren = [];
					tblMain = {tag: 'table', props: { class: sPanelClass, id: baseId + '_tblMain' + nPanelIndex.toString(), style: {} }, children: tblMainChildren};
					// 04/16/2022 Paul.  Separators usually start a new table or division, so separators after active tab need to be treated as a set. 
					if ( bTabsEnabled )
					{
						let style: any = tblMain.props.style;
						style.display = (lay.ActiveTab ? 'table' : 'none');
						nPanelIndex++;
					}
					fragmentChildren.push(tblMain);
					tblBodyChildren = [];
					tbody = {tag: 'tbody', props: {}, children: tblBodyChildren};
					tblMainChildren.push(tbody);
					nPanelIndex++;
					nColumn = 0;
					trChildren = [];
					tr = null;
					continue;
				}
				// 08/08/2019 Paul.  We no longer force a new row every other loop, just let flex wrap with 50% columns. 
				// 04/18/2021 Paul.  Going back to old table code. 
				if ( nColumn % DATA_COLUMNS == 0 || tr == null || bIsMobile )
				{
					trChildren = [];
					// 08/25/2019 Paul.  This is the correct place to handle colspan. 
					if ( COLSPAN == 3 )
					{
						sFlexLabelFieldWidth  = '100%';
					}
					tr = {tag: 'tr', props: {}, children: trChildren};
					tblBodyChildren.push(tr);
				}
				let bIsReadable: boolean = true;
				if ( MODULE_NAME == null && layout.length > 0 )
				{
					let arrDETAIL_NAME: string[] = DETAIL_NAME.split('.');
					if ( arrDETAIL_NAME.length > 0 )
					{
						MODULE_NAME = arrDETAIL_NAME[0];
					}
				}
				// 06/16/2010 Paul.  sDATA_FIELD may be empty. 
				if ( SplendidCache.bEnableACLFieldSecurity && !Sql.IsEmptyString(DATA_FIELD) )
				{
					let gASSIGNED_USER_ID = null;
					if ( row != null )
					{
						gASSIGNED_USER_ID = Sql.ToGuid(row.ASSIGNED_USER_ID);
					}
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(SplendidCache, Security, MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}
				if ( !bIsReadable )
				{
					FIELD_TYPE = 'Blank';
				}

				// 06/21/2015 Paul.  The Seven theme has labels stacked above values. 
				let tdLabelChildren: any = [];
				let tdLabel = null;
				let tdFieldChildren: any = [];
				let tdField = null;
				let sLabelID = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex) + '_LABEL';
				let sFieldID = baseId + '_' + (!Sql.IsEmptyString(DATA_FIELD) ? DATA_FIELD : nLayoutIndex);
				// 10/29/2020 Paul.  A header needs to be able to modify the label width. 
				// 10/29/2020 Paul.  Can't seem to override the class once the element is created. 
				// 04/20/2021 Paul.  We want to match the old system so keep the style. 
				//if ( FIELD_TYPE == 'Header' )
				//	sGridLabel = null;
				let tdLabelProps: any = { id: sLabelID, class: sGridLabel, style: { width: LABEL_WIDTH } };
				// 04/16/2022 Paul.  need to move colSpan to prevent it from being attached to div tag. 
				let tdFieldProps: any = { class: sGridInput, id: sFieldID, style: { width: FIELD_WIDTH } };
				// 04/19/2021 Paul.  Manually calculate responsive features. 
				if ( bStackedLayout )
				{
					// 04/16/2022 Paul.  Remove width if using stacked. 
					tdLabelProps.style = {};
					tdFieldProps.style = {};
					let tdStackChildren: any = [];
					let tdStackProps: any = { style: {} };
					if ( bStackedTheme )
					{
						tdStackProps.class = 'tabStackedDetailViewDF';
						tdLabelProps.class = 'tabStackedDetailViewDL';
					}
					//else
					{
						tdLabelProps.style.textAlign  = 'inherit';
						tdStackProps.style.padding    = '0px';
					}
					if ( sTheme == 'Pacific' )
					{
						// 04/04/2022 Paul.  Change to css selector: .tabStackedDetailViewDF > .tabDetailViewDF
						//tdFieldProps.style.minHeight    = '2.1em';
						//tdFieldProps.style.borderBottom = '.0625rem dotted #d9d9d9';
						tdStackProps.style.paddingLeft  = '1em';
						tdStackProps.style.paddingRight = '1em';
						// 04/16/2022 Paul.  We seem to need to force the width when multiple panels are displayed. 
						tdStackProps.style.width        = sFlexLabelFieldWidth;
						if ( DATA_COLUMNS > 1 && COLSPAN <= 1 )
						{
							if ( (nColumn < DATA_COLUMNS - 1) )
							{
								tdStackProps.style.borderRight = '.0625rem solid #93a4b3';
							}
						}
					}
					if ( COLSPAN > 1 )
					{
						// 04/16/2022 Paul.  colspan is typically 3 for 2 column layout, so we need to reduce by 1 when stacked. 
						tdStackProps.colSpan = COLSPAN - 1;
					}
					let tdStack: any = {tag: 'td', tdStackProps, children: tdStackChildren};
					trChildren.push(tdStack);
					tdLabel = {tag: 'div', props: tdLabelProps, children: tdLabelChildren};
					tdStackChildren.push(tdLabel)
					tdField = {tag: 'div', props: tdFieldProps, children: tdFieldChildren};
					tdStackChildren.push(tdField);
				}
				else
				{
					if ( COLSPAN > 0 )
					{
						tdFieldProps.colSpan = COLSPAN;
					}
					// 11/12/2019 Paul.  Default top align looks terrible. 
					// 12/17/2019 Paul.  Baseline looks better than center, especially for multi-line controls such as Teams and Tags. 
					// 03/19/2020 Paul.  Remove inner span around label so that it will follow the right alignment of the style. 
					// 03/19/2020 Paul.  flex is preventing style from aligning right.  Not sure we need flex in the label. // display: 'flex', alignItems: 'baseline'
					tdLabel = {tag: 'td', props: tdLabelProps, children: tdLabelChildren};
					trChildren.push(tdLabel)
					tdField = {tag: 'td', props: tdFieldProps, children: tdFieldChildren};
					trChildren.push(tdField);
				}
				// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
				if ( !bIsHidden )
				{
					// 04/28/2019 Paul.  Header text goes in the field column, leaving the label column blank. 
					if ( DATA_LABEL != null && FIELD_TYPE != 'Header' )
					{
						if ( FIELD_TYPE != 'Blank' )
						{
							if ( DATA_LABEL.indexOf('.') >= 0 )
							{
								let txt = L10n.Term(DATA_LABEL);
								// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
								// 01/13/2020 Paul.  Allow the label to contain HTML. 
								// 03/19/2020 Paul.  Make sure that tag exists, otherwise labels will not be aligned right. 
								if ( txt.indexOf('</span>') >= 0 )
								{
									let html: any = {tag: 'span', props: { dangerouslySetInnerHTML: { __html: txt } }, children: null};
									tdLabelChildren.push(html);
								}
								else
								{
									txt = Sql.ReplaceEntities(txt);
									tdLabelChildren.push(txt);
								}
							}
							else if ( !Sql.IsEmptyString(DATA_LABEL) )
							{
								// 06/21/2015 Paul.  Label can contain raw text. 
								let sLabel = row[DATA_LABEL];
								if ( sLabel === undefined )
								{
									sLabel = Sql.ToString(DATA_LABEL);
								}
								if ( !Sql.IsEmptyString(sLabel) )
								{
									let txt = sLabel;
									// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
									txt = Sql.ReplaceEntities(txt);
									tdLabelChildren.push(txt);
								}
							}
							// 07/24/2019 Paul.  Tool tip as simple hover. 
							if ( !Sql.IsEmptyString(TOOL_TIP) )
							{
								let sTOOL_TIP: string = TOOL_TIP;
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
									icon = {tag: 'fa-icon', props: {icon: 'question' }, children: null        };
								let tip: any = {tag: 'span', props: {class: 'reactTooltip'    }, children: [icon, text]};
								tdLabelChildren.push(tip);
							}
						}
						// 04/15/2022 Paul.  Stacked layout needs nbsp for label. 
						else if ( bStackedLayout )
						{
							let nbsp: any = {tag: 'span', props: {}, children: ['\u00a0']};
							tdLabelChildren.push(nbsp);
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
						console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamicDetailView ' + DETAIL_NAME + '.' + DATA_FIELD + ' already exists in refMap.');
					}
				}
				let ref = React.createRef<DetailComponent<any, any>>();
				refMap[key] = ref;
				*/
				if ( FIELD_TYPE == 'HyperLink' )
				{
					let lnkProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let lnk: any = {tag: FIELD_TYPE, props: lnkProps, children: null};
					tdFieldChildren.push(lnk);
				}
				// 01/10/2023 Paul.  Correct the field type name, it is not ModueLink. 
				else if ( FIELD_TYPE == 'ModuleLink' )
				{
					let lnkProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let lnk: any = {tag: FIELD_TYPE, props: lnkProps, children: null};
					tdFieldChildren.push(lnk);
				}
				else if ( FIELD_TYPE == 'String' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt: any = {tag: FIELD_TYPE, props: txtProps, children: null};
					tdFieldChildren.push(txt);
				}
				else if ( FIELD_TYPE == 'TextBox' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt: any = {tag: FIELD_TYPE, props: txtProps, children: null};
					tdFieldChildren.push(txt);
				}
				// 05/27/2016 Paul.  Add support for Image type. 
				else if ( FIELD_TYPE == 'Image' )
				{
					let imgProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let img: any = {tag: FIELD_TYPE, props: imgProps, children: null};
					tdFieldChildren.push(img);
				}
				// 05/27/2016 Paul.  Add support for File type. 
				else if ( FIELD_TYPE == 'File' )
				{
					let imgProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let img: any = {tag: FIELD_TYPE, props: imgProps, children: null};
					tdFieldChildren.push(img);
				}
				else if ( FIELD_TYPE == 'CheckBox' )
				{
					let chkProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let chk: any = {tag: FIELD_TYPE, props: chkProps, children: null};
					tdFieldChildren.push(chk);
				}
				else if ( FIELD_TYPE == 'Blank' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt: any = {tag: FIELD_TYPE, props: txtProps, children: null};
					tdFieldChildren.push(txt);
				}
				// 09/03/2012 Paul.  A header is similar to a label, but without the data field. 
				else if ( FIELD_TYPE == 'Header' )
				{
					// 10/29/2020 Paul.  Match behavior of EditView that places the header in the label column. 
					tdLabelChildren.pop();
					let txtProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt: any = {tag: FIELD_TYPE, props: txtProps, children: null};
					// 10/29/2020 Paul.  Overriding the initial class does not work, so we will need to override above. 
					tdLabelProps.class   = '';
					tdLabelChildren.push(txt);
				}
				// 06/21/2015 Paul.  We are not ready to support javascript. 
				// 02/25/2016 Paul.  Add support for JavaScript for OfficeAddin. 
				else if ( FIELD_TYPE == 'JavaScript' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt: any = {tag: FIELD_TYPE, props: txtProps, children: null};
					tdFieldChildren.push(txt);
				}
				// 05/14/2016 Paul.  Add Tags module. 
				else if ( FIELD_TYPE == 'Tags' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden };
					let txt: any = {tag: FIELD_TYPE, props: txtProps, children: null};
					tdFieldChildren.push(txt);
				}
				// 07/31/2019 Paul.  Add Button module. 
				else if ( FIELD_TYPE == 'Button' )
				{
					let txtProps: any = { baseId, key, row, layout: lay, fieldDidMount: this._onFieldDidMount, ERASED_FIELDS, bIsHidden, Page_Command: this._onPage_Command };
					let txt: any = {tag: FIELD_TYPE, props: txtProps, children: null};
					tdFieldChildren.push(txt);
				}
				else
				{
					tdFieldChildren.push('Unsupported field type: ' + FIELD_TYPE);
				}
				// 04/08/2017 Paul.  Use Bootstrap for responsive design.
				// 05/17/2018 Chase. Not sure if needed.
				/*if (SplendidDynamic.BootstrapLayout()) {
					// 04/08/2017 Paul.  An empty field will cause problems for grid flow. 
					// 01/11/2018 Paul.  Adding nbsp to innerHTML is causing the hyperlinks to fail.  Instead, add text node. 
					tdLabelChildren.push(' ');
					tdFieldChildren.push(' ');
				}*/
				if ( COLSPAN > 0 )
				{
					nColumn += COLSPAN;
				}
				else if ( COLSPAN == 0 )
				{
					nColumn++;
				}
				if ( nColumn >= DATA_COLUMNS )
				{
					nColumn = 0;
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendDetailViewFields', error);
		}
	}

	public _onFieldDidMount = (obj: {DATA_FIELD: string, component: any}) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onFieldDidMount', obj);
		this.onFieldDidMount.emit(obj);
	}

	public _onPage_Command = (obj: {sCommandName: string, sCommandArguments: any}) =>
	{
	}

}
