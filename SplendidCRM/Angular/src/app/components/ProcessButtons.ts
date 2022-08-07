import { Component, OnInit, Input, Output, EventEmitter, ChangeDetectorRef } from '@angular/core'                         ;
import { Router, ActivatedRoute, ParamMap                             } from '@angular/router'                       ;
import { faSpinner                                                    } from '@fortawesome/free-solid-svg-icons'     ;

import { SplendidCacheService                                         } from '../scripts/SplendidCache'              ;
import { CredentialsService                                           } from '../scripts/Credentials'                ;
import { SecurityService                                              } from '../scripts/Security'                   ;
import { L10nService                                                  } from '../scripts/L10n'                       ;
import { CrmConfigService, CrmModulesService                          } from '../scripts/Crm'                        ;
import { ProcessButtonsService                                        } from '../scripts/ProcessButtons'             ;
import { FormattingService                                            } from '../scripts/Formatting'                 ;
import { StartsWith, isMobileDevice, isMobileLandscape                } from '../scripts/utility'                    ;
import Sql                                                              from '../scripts/Sql'                        ;
import SplendidDynamic                                                  from '../scripts/SplendidDynamic'            ;
import MODULE                                                           from '../types/MODULE'                       ;
import DYNAMIC_BUTTON                                                   from '../types/DYNAMIC_BUTTON'               ;
import ACL_ACCESS                                                       from '../types/ACL_ACCESS'                   ;

@Component({
	selector: 'ProcessButtons',
	templateUrl: './ProcessButtons.html',
})
export class ProcessButtonsComponent implements OnInit
{
	// IDynamicButtonsState
	private   lastKey                  : number          ;
	private   changeKey                : number          ;
	public    layout                   : DYNAMIC_BUTTON[];
	public    disabled                 : any             ;
	public    hidden                   : any             ;
	public    bIsPostBack              : boolean         ;
	public    busy                     : boolean         ;
	public    pnlProcessButtons        : any             ;
	public    spinner                  = faSpinner       ;
	public    JSON                     = JSON;

	// IProcessButtonsState
	public    process                  : any             ;
	public    popupOpen                : boolean         ;
	public    modalCommand             : string          ;
	public    showHistory              : boolean         ;
	public    history                  : any[]           ;
	public    historyTitle             : string          ;
	public    showNotes                : boolean         ;
	public    notes                    : any[]           ;
	public    notesTitle               : string          ;
	public    NOTE                     : string          ;
	public    notesError               : string          ;
	public    error                    : any             ;
	public    icon                     : string          ;

	@Input()  MODULE_NAME       : string ;
	@Input()  ID                : string ;
	@Input()  PENDING_PROCESS_ID: string ;
	@Input()  ButtonStyle       : string ;
	@Input()  FrameStyle        : any    ;
	@Input()  ContentStyle      : any    ;
	@Input()  VIEW_NAME         : string ;
	@Input()  row               : any    ;
	// 06/03/2022 Paul.  onLayoutLoaded is not needed becasue we are using the ViewChild setter.  We do this because onLayoutLoaded would otherwise fire too early. 
	//@Output() onLayoutLoaded    : EventEmitter<void> = new EventEmitter<void>();
	// 07/02/2020 Paul.  Provide a way to override the default ButtonLink behavior. 
	@Output() onButtonLink      : EventEmitter<DYNAMIC_BUTTON> = new EventEmitter<DYNAMIC_BUTTON>();
	// 06/03/2022 Paul.  We need a separate flag to determine if observed. 
	@Input()  buttonLinkObserved: boolean;

	public IsEmptyString(s: any): boolean
	{
		return Sql.IsEmptyString(s);
	}

	public IsEmptyGuid(s: any): boolean
	{
		return Sql.IsEmptyGuid(s);
	}

	constructor(private router: Router, private changeDetectorRef: ChangeDetectorRef, public SplendidCache : SplendidCacheService, public Credentials: CredentialsService, public Security : SecurityService, public L10n : L10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public ProcessButtons: ProcessButtonsService, public Formatting: FormattingService)
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
		this.pnlProcessButtons         = null ;

		this.process                   = null ;
		this.popupOpen                 = false;
		this.modalCommand              = null ;
		this.showHistory               = false;
		this.history                   = null ;
		this.historyTitle              = null ;
		this.showNotes                 = false;
		this.notes                     = null ;
		this.notesTitle                = null ;
		this.NOTE                      = null ;
		this.notesError                = null ;
		this.error                     = null ;
		this.icon                      = this.Credentials.RemoteServer + 'Include/images/SplendidCRM_Icon.gif';
	}

	ngOnInit()
	{
		//console.log(this.constructor.name + '.ngOnInit ' + this.VIEW_NAME);
		try
		{
			this.Load();
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
			this.pnlProcessButtons = this.LoadButtons();
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

	private Load = async () =>
	{
		if ( !Sql.IsEmptyGuid(this.PENDING_PROCESS_ID) )
		{
			try
			{
				let message = await this.ProcessButtons.GetProcessStatus(this.PENDING_PROCESS_ID);
				if ( message != null && message.length > 0 )
				{
					this.process = message[0];
				}
				this.changeKey++;
				console.log(this.constructor.name + '.Load', this.process);
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Load ', error);
				this.error = error;
			}
		}
	}

	private CreateButton = (sKEY: string, sCONTROL_TYPE: string, sMODULE_NAME: string, sCONTROL_TEXT: string, sCONTROL_TOOLTIP: string, sCONTROL_CSSCLASS: string, sTEXT_FIELD: string, sARGUMENT_FIELD: string, sCOMMAND_NAME: string, sURL_FORMAT: string, sURL_TARGET: string, ONCLICK_SCRIPT: string, bHIDDEN: boolean, nMODULE_ACLACCESS: number, nTARGET_ACLACCESS: number) =>
	{
		const { L10n } = this;
		let oARGUMENT_VALUE = new Object();
		let btnProps: any = { key: sKEY, type: 'submit', style: { marginRight: '2px', marginBottom: '2px', whiteSpace: 'nowrap' } };
		btnProps.style.display = (bHIDDEN ? 'none' : 'inline');
		btnProps.class = 'button ' + sCONTROL_CSSCLASS;
		btnProps.onClick = (e: any) =>
		{
			e.preventDefault();
			this.Page_Command(sCOMMAND_NAME, oARGUMENT_VALUE);
		};
		let btn: any = {tag: 'button', props: btnProps, text: L10n.Term(sCONTROL_TEXT)};
		return btn;
	}

	private LoadButtons = () =>
	{
		const { MODULE_NAME, ID, process, SplendidCache, Security } = this;
		console.log(this.constructor.name + '.LoadButtons');
		let style : any = {};
		let sTheme: string  = SplendidCache.UserTheme;
		if ( sTheme == 'Pacific' )
		{
			style.textAlign = 'right';
		}
		let pnlProcessButtonsChildren: any[] = [];
		let pnlProcessButtons        : any = { tag: 'div', props: { id: 'pnlProcessButtons', key: 'pnlProcessButtons', class: 'button-panel', style: style }, children: pnlProcessButtonsChildren};

		try
		{
			let ProcessStatus     : string  = Sql.ToString (process['ProcessStatus'     ]);
			let ShowApprove       : boolean = Sql.ToBoolean(process['ShowApprove'       ]);
			let ShowReject        : boolean = Sql.ToBoolean(process['ShowReject'        ]);
			let ShowRoute         : boolean = Sql.ToBoolean(process['ShowRoute'         ]);
			let ShowClaim         : boolean = Sql.ToBoolean(process['ShowClaim'         ]);
			let USER_TASK_TYPE    : string  = Sql.ToString (process['USER_TASK_TYPE'    ]);
			let PROCESS_USER_ID   : string  = Sql.ToGuid   (process['PROCESS_USER_ID'   ]);
			let ASSIGNED_TEAM_ID  : string  = Sql.ToGuid   (process['ASSIGNED_TEAM_ID'  ]);
			let PROCESS_TEAM_ID   : string  = Sql.ToGuid   (process['PROCESS_TEAM_ID'   ]);

			let sVIEW_NAME = 'Processes.DetailView';
			if ( USER_TASK_TYPE == 'Route' )
			{
				sVIEW_NAME = 'Processes.DetailView.Route';
			}
			if ( Sql.IsEmptyGuid(PROCESS_USER_ID) )
			{
				sVIEW_NAME = 'Processes.DetailView.Claim';
			}

			let bEditHIDDEN = true;
			if (sVIEW_NAME == 'Processes.DetailView' || sVIEW_NAME == 'Processes.DetailView.Route')
				bEditHIDDEN = false;
			let btnEdit = this.CreateButton(
				'pnlProcessButtons_btnEdit' // sKEY: string
				, 'ButtonLink'              // sCONTROL_TYPE: string
				, MODULE_NAME               // sMODULE_NAME: string
				, '.LBL_EDIT_BUTTON_LABEL'  // sCONTROL_TEXT: string
				, '.LBL_EDIT_BUTTON_TITLE'  // sCONTROL_TOOLTIP: string
				, ''                        // sCONTROL_CSSCLASS: string
				, 'ID'                      // sTEXT_FIELD: string
				, null                      // sARGUMENT_FIELD: string
				, 'Edit'                    // sCOMMAND_NAME: string
				, null                      // sURL_FORMAT: string
				, null                      // sURL_TARGET: string
				, null                      // ONCLICK_SCRIPT: string
				, bEditHIDDEN               // bHIDDEN: boolean
				, 0                         // nMODULE_ACLACCESS: number
				, 0                         // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnEdit);

			let bCancelHIDDEN = true;
			if (sVIEW_NAME == 'Processes.DetailView.Claim')
				bCancelHIDDEN = false;
			let btnCancel = this.CreateButton(
				'pnlProcessButtons_btnCancel' // sKEY: string
				, 'ButtonLink'                // sCONTROL_TYPE: string
				, MODULE_NAME                 // sMODULE_NAME: string
				, '.LBL_CANCEL_BUTTON_LABEL'  // sCONTROL_TEXT: string
				, '.LBL_CANCEL_BUTTON_TITLE'  // sCONTROL_TOOLTIP: string
				, ''                          // sCONTROL_CSSCLASS: string
				, 'ID'                        // sTEXT_FIELD: string
				, null                        // sARGUMENT_FIELD: string
				, 'Cancel'                    // sCOMMAND_NAME: string
				, null                        // sURL_FORMAT: string
				, null                        // sURL_TARGET: string
				, null                        // ONCLICK_SCRIPT: string
				, bCancelHIDDEN               // bHIDDEN: boolean
				, 0                           // nMODULE_ACLACCESS: number
				, 0                           // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnCancel);

			let bShowHistoryHIDDEN = false;
			let btnShowHistory = this.CreateButton(
				'pnlProcessButtons_btnShowHistory' // sKEY: string
				, 'Button'                         // sCONTROL_TYPE: string
				, MODULE_NAME                      // sMODULE_NAME: string
				, 'Processes.LBL_HISTORY'          // sCONTROL_TEXT: string
				, 'Processes.LBL_HISTORY'          // sCONTROL_TOOLTIP: string
				, ''                               // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'             // sTEXT_FIELD: string
				, null                             // sARGUMENT_FIELD: string
				, 'Processes.ShowHistory'          // sCOMMAND_NAME: string
				, null                             // sURL_FORMAT: string
				, null                             // sURL_TARGET: string
				, null                             // ONCLICK_SCRIPT: string
				, bShowHistoryHIDDEN               // bHIDDEN: boolean
				, 0                                // nMODULE_ACLACCESS: number
				, 0                                // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnShowHistory);

			let bShowNotesHIDDEN = false;
			let btnShowNotes = this.CreateButton(
				'pnlProcessButtons_btnShowNotes' // sKEY: string
				, 'Button'                       // sCONTROL_TYPE: string
				, MODULE_NAME                    // sMODULE_NAME: string
				, 'Processes.LBL_NOTES'          // sCONTROL_TEXT: string
				, 'Processes.LBL_NOTES'          // sCONTROL_TOOLTIP: string
				, ''                             // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'           // sTEXT_FIELD: string
				, null                           // sARGUMENT_FIELD: string
				, 'Processes.ShowNotes'          // sCOMMAND_NAME: string
				, null                           // sURL_FORMAT: string
				, null                           // sURL_TARGET: string
				, null                           // ONCLICK_SCRIPT: string
				, bShowNotesHIDDEN               // bHIDDEN: boolean
				, 0                              // nMODULE_ACLACCESS: number
				, 0                              // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnShowNotes);

			let bSelectAssignedUserHIDDEN = true;
			if (sVIEW_NAME == 'Processes.DetailView' || sVIEW_NAME == 'Processes.DetailView.Route')
			{
				bSelectAssignedUserHIDDEN = (!Sql.IsEmptyGuid(ASSIGNED_TEAM_ID) && PROCESS_USER_ID == Security.USER_ID() ? false : true);
			}
			let btnSelectAssignedUser = this.CreateButton(
				'pnlProcessButtons_btnSelectAssignedUser' // sKEY: string
				, 'Button'                                // sCONTROL_TYPE: string
				, MODULE_NAME                             // sMODULE_NAME: string
				, 'Processes.LBL_CHANGE_ASSIGNED_USER'    // sCONTROL_TEXT: string
				, 'Processes.LBL_CHANGE_ASSIGNED_USER'    // sCONTROL_TOOLTIP: string
				, ''                                      // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'                    // sTEXT_FIELD: string
				, null                                    // sARGUMENT_FIELD: string
				, 'Processes.SelectAssignedUser'          // sCOMMAND_NAME: string
				, null                                    // sURL_FORMAT: string
				, null                                    // sURL_TARGET: string
				, null                                    // ONCLICK_SCRIPT: string
				, bSelectAssignedUserHIDDEN               // bHIDDEN: boolean
				, 0                                       // nMODULE_ACLACCESS: number
				, 0                                       // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnSelectAssignedUser);

			let bSelectProcessUserHIDDEN = true;
			if (sVIEW_NAME == 'Processes.DetailView' || sVIEW_NAME == 'Processes.DetailView.Route')
			{
				bSelectProcessUserHIDDEN = (!Sql.IsEmptyGuid(PROCESS_TEAM_ID) && PROCESS_USER_ID == Security.USER_ID() ? false : true);
			}
			let btnSelectProcessUser = this.CreateButton(
				'pnlProcessButtons_btnSelectProcessUser' // sKEY: string
				, 'Button'                               // sCONTROL_TYPE: string
				, MODULE_NAME                            // sMODULE_NAME: string
				, 'Processes.LBL_CHANGE_PROCESS_USER'    // sCONTROL_TEXT: string
				, 'Processes.LBL_CHANGE_PROCESS_USER'    // sCONTROL_TOOLTIP: string
				, ''                                     // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'                   // sTEXT_FIELD: string
				, null                                   // sARGUMENT_FIELD: string
				, 'Processes.SelectProcessUser'          // sCOMMAND_NAME: string
				, null                                   // sURL_FORMAT: string
				, null                                   // sURL_TARGET: string
				, null                                   // ONCLICK_SCRIPT: string
				, bSelectProcessUserHIDDEN               // bHIDDEN: boolean
				, 0                                      // nMODULE_ACLACCESS: number
				, 0                                      // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnSelectProcessUser);

			let bApproveHIDDEN = true;
			if (Sql.IsEmptyGuid(PROCESS_USER_ID) || PROCESS_USER_ID == Security.USER_ID())
			{
				bApproveHIDDEN = (ShowApprove ? false : true);
			}
			let btnApprove = this.CreateButton(
				'pnlProcessButtons_btnApprove' // sKEY: string
				, 'Button'                     // sCONTROL_TYPE: string
				, MODULE_NAME                  // sMODULE_NAME: string
				, 'Processes.LBL_APPROVE'      // sCONTROL_TEXT: string
				, 'Processes.LBL_APPROVE'      // sCONTROL_TOOLTIP: string
				, 'ProcessApprove'             // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'         // sTEXT_FIELD: string
				, null                         // sARGUMENT_FIELD: string
				, 'Processes.Approve'          // sCOMMAND_NAME: string
				, null                         // sURL_FORMAT: string
				, null                         // sURL_TARGET: string
				, null                         // ONCLICK_SCRIPT: string
				, bApproveHIDDEN               // bHIDDEN: boolean
				, 0                            // nMODULE_ACLACCESS: number
				, 0                            // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnApprove);

			let bRejectHIDDEN = true;
			if (Sql.IsEmptyGuid(PROCESS_USER_ID) || PROCESS_USER_ID == Security.USER_ID())
			{
				bRejectHIDDEN = (ShowReject ? false : true);
			}
			let btnReject = this.CreateButton(
				'pnlProcessButtons_btnReject' // sKEY: string
				, 'Button'                    // sCONTROL_TYPE: string
				, MODULE_NAME                 // sMODULE_NAME: string
				, 'Processes.LBL_REJECT'      // sCONTROL_TEXT: string
				, 'Processes.LBL_REJECT'      // sCONTROL_TOOLTIP: string
				, 'ProcessReject'             // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'        // sTEXT_FIELD: string
				, null                        // sARGUMENT_FIELD: string
				, 'Processes.Reject'          // sCOMMAND_NAME: string
				, null                        // sURL_FORMAT: string
				, null                        // sURL_TARGET: string
				, null                        // ONCLICK_SCRIPT: string
				, bRejectHIDDEN               // bHIDDEN: boolean
				, 0                           // nMODULE_ACLACCESS: number
				, 0                           // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnReject);

			let bRouteHIDDEN = true;
			if (Sql.IsEmptyGuid(PROCESS_USER_ID) || PROCESS_USER_ID == Security.USER_ID())
			{
				bRouteHIDDEN = (ShowRoute ? false : true);
			}
			let btnRoute = this.CreateButton(
				'pnlProcessButtons_btnRoute' // sKEY: string
				, 'Button'                   // sCONTROL_TYPE: string
				, MODULE_NAME                // sMODULE_NAME: string
				, 'Processes.LBL_ROUTE'      // sCONTROL_TEXT: string
				, 'Processes.LBL_ROUTE'      // sCONTROL_TOOLTIP: string
				, 'ProcessRoute'             // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'       // sTEXT_FIELD: string
				, null                       // sARGUMENT_FIELD: string
				, 'Processes.Route'          // sCOMMAND_NAME: string
				, null                       // sURL_FORMAT: string
				, null                       // sURL_TARGET: string
				, null                       // ONCLICK_SCRIPT: string
				, bRouteHIDDEN               // bHIDDEN: boolean
				, 0                          // nMODULE_ACLACCESS: number
				, 0                          // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnRoute);

			let bClaimHIDDEN = true;
			if (Sql.IsEmptyGuid(PROCESS_USER_ID) || PROCESS_USER_ID == Security.USER_ID())
			{
				bClaimHIDDEN = (ShowClaim ? false : true);
			}
			let btnClaim = this.CreateButton(
				'pnlProcessButtons_btnClaim' // sKEY: string
				, 'Button'                   // sCONTROL_TYPE: string
				, MODULE_NAME                // sMODULE_NAME: string
				, 'Processes.LBL_CLAIM'      // sCONTROL_TEXT: string
				, 'Processes.LBL_CLAIM'      // sCONTROL_TOOLTIP: string
				, 'ProcessClaim'             // sCONTROL_CSSCLASS: string
				, 'PENDING_PROCESS_ID'       // sTEXT_FIELD: string
				, null                       // sARGUMENT_FIELD: string
				, 'Processes.Claim'          // sCOMMAND_NAME: string
				, null                       // sURL_FORMAT: string
				, null                       // sURL_TARGET: string
				, null                       // ONCLICK_SCRIPT: string
				, bClaimHIDDEN               // bHIDDEN: boolean
				, 0                          // nMODULE_ACLACCESS: number
				, 0                          // nTARGET_ACLACCESS: number
			);
			pnlProcessButtonsChildren.push(btnClaim);

			// 08/20/2016 Paul.  Change to a span so that it can be placed side-by-side with another button panel. 
			// 06/15/2017 Paul.  Use Bootstrap for responsive design.
			//if ( !SplendidDynamic.BootstrapLayout() )
			//	pnlProcessButtons.style.display = 'inline-block';
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.ProcessStatus', ProcessStatus);
			let txtProcessStatus: any = {tag: 'div', props: { class: 'ProcessStatus', style: {display: 'block', width: '100%'}}, text: ProcessStatus };
			pnlProcessButtonsChildren.push(txtProcessStatus);
			// 04/19/2017 Paul.  The status will include HTML formatting. 
			//txtProcessStatus.appendChild(document.createTextNode(this.ProcessStatus));
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadButtons ', error);
		}
		console.log(this.constructor.name + '.LoadButtons Done', pnlProcessButtons);
		return pnlProcessButtons;
	}

	public Page_Command = async (sCommandName: string, sCommandArguments: any) =>
	{
		const { MODULE_NAME, ID, PENDING_PROCESS_ID } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments)
		if ( sCommandName == 'Edit' )
		{
			this.router.navigateByUrl(`/Reset/${MODULE_NAME}/Edit/${ID}`);
		}
		else if ( sCommandName == 'Cancel' )
		{
			this.router.navigateByUrl(`/Reset/${MODULE_NAME}/List`);
		}
		else if ( sCommandName == 'Processes.Approve' )
		{
			await this.ProcessButtons.ProcessAction('Approve', PENDING_PROCESS_ID, null, null);
			await this.Load();
		}
		else if ( sCommandName == 'Processes.Reject' )
		{
			await this.ProcessButtons.ProcessAction('Reject', PENDING_PROCESS_ID, null, null);
			await this.Load();
		}
		else if ( sCommandName == 'Processes.Route' )
		{
			await this.ProcessButtons.ProcessAction('Route', PENDING_PROCESS_ID, null, null);
			await this.Load();
		}
		else if ( sCommandName == 'Processes.Claim' )
		{
			await this.ProcessButtons.ProcessAction('Claim', PENDING_PROCESS_ID, null, null);
			await this.Load();
		}
		else if ( sCommandName == 'Processes.Cancel' )
		{
			await this.ProcessButtons.ProcessAction('Cancel', PENDING_PROCESS_ID, null, null);
			await this.Load();
		}
		else if ( sCommandName == 'Processes.SelectProcessUser' )
		{
			this.popupOpen    = true;
			this.modalCommand = sCommandName;
		}
		else if ( sCommandName == 'Processes.SelectAssignedUser' )
		{
			this.popupOpen    = true;
			this.modalCommand = sCommandName;
		}
		else if ( sCommandName == 'Processes.ShowHistory' )
		{
			try
			{
				let d: any = await this.ProcessButtons.GetProcessHistory(PENDING_PROCESS_ID);
				this.showHistory  = true;
				this.history      = d.results;
				this.historyTitle = d.__title;
			}
			catch(error: any)
			{
				this.error = error;
			}
		}
		else if ( sCommandName == 'Processes.ShowNotes' )
		{
			try
			{
				let d: any = await this.ProcessButtons.GetProcessNotes(PENDING_PROCESS_ID);
				this.showNotes  = true
				this.notes      = d.results;
				this.notesTitle = d.__title;
			}
			catch(error: any)
			{
				this.error = error;
			}
		}
		else
		{
			console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command Unknown command', sCommandName)
			this.error = sCommandName + ' not supported';
		}
	}

	public _onSelect = async (value: { Action: string, ID?: string, NAME?: string, PROCESS_NOTES?: string, selectedItems?: any }) =>
	{
		const { PENDING_PROCESS_ID } = this;
		const { modalCommand } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', value);
		if ( value.Action == 'SingleSelect' )
		{
			let sCommandName  = modalCommand;
			this.popupOpen    = false;
			this.modalCommand = null;
			try
			{
				if ( sCommandName == 'Processes.SelectProcessUser' )
				{
					await this.ProcessButtons.ProcessAction('ChangeProcessUser', PENDING_PROCESS_ID, value.ID, value.PROCESS_NOTES);
					await this.Load();
				}
				else if ( sCommandName == 'Processes.SelectAssignedUser' )
				{
					await this.ProcessButtons.ProcessAction('ChangeAssignedUser', PENDING_PROCESS_ID, value.ID, value.PROCESS_NOTES);
					await this.Load();
				}
			}
			catch(error: any)
			{
				this.error = error;
			}
		}
		else if ( value.Action == 'Close' )
		{
			this.popupOpen = false;
		}
	}

	public _onCloseHistory = () =>
	{
		this.showHistory = false;
	}

	public _onCloseNotes = () =>
	{
		this.showNotes = false;
	}

	public _onChangeNote = (e: any): void =>
	{
		let value = e.target.value;
		this.NOTE = value;
	}

	public _onDeleteNote = async (e: any, PROCESS_NOTE_ID: string) =>
	{
		e.preventDefault();
		try
		{
			await this.ProcessButtons.DeleteProcessNote(PROCESS_NOTE_ID);
			await this.Page_Command('Processes.ShowNotes', null);
		}
		catch(error: any)
		{
			this.notesError = error;
		}
		return false;
	}

	public _onAddNote = async () =>
	{
		const { PENDING_PROCESS_ID } = this;
		const { NOTE } = this;
		try
		{
			await this.ProcessButtons.AddProcessNote(PENDING_PROCESS_ID, NOTE);
			await this.Page_Command('Processes.ShowNotes', null);
			this.NOTE = '';
		}
		catch(error: any)
		{
			this.notesError = error;
		}
	}
}
