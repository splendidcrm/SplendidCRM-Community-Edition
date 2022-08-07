import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { faEdit, faTimes                                           } from '@fortawesome/free-solid-svg-icons';

import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { C10nService                                               } from '../scripts/C10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import { ListViewService                                           } from '../scripts/ListView'          ;
import Sql                                                           from '../scripts/Sql'               ;
import SplendidDynamic                                               from '../scripts/SplendidDynamic'   ;
import { EditViewComponentBase                                     } from '../EditComponents/EditViewComponentBase';

@Component({
	selector: 'EditViewModulePopup',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for ModulePopup FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyChanged()">
		<span>onChanged is null for ModulePopup DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<ng-container *ngIf="tableRow">
			<tr [class]="CSS_CLASS" style="white-space: nowrap">
				<td style="width: 68%">
					<DynamicPopupView
						[isOpen]="popupOpen"
						[isSearchView]="isSearchView"
						[fromLayoutName]="EDIT_NAME"
						(callback)="this._onSelect"
						[MODULE_NAME]="MODULE_TYPE"
						[rowDefaultSearch]="rowDefaultSearch"
					></DynamicPopupView>
					<AutoComplete
						[id]="ID"
						[value]="DISPLAY_VALUE"
						[items]="items"
						[inputProps]="inputProps"
						[wrapperStyle]="wrapperStyle"
						[autoHighlight]="false"
						(getItemValue)="_onGetItemValue($event)"
						(onChange)="_onTextChange($event)"
						(onSelect)="_onTextSelect($event)"
						(onTextBlur)="_onTextBlur($event)"
						(onMenuVisibilityChange)="this._onMenuVisibilityChange($event)"
					></AutoComplete>
				</td>
				<ng-container *ngIf="((MODULE_TYPE == 'Users' || MODULE_TYPE == 'Teams') && this.layout.EDIT_NAME.indexOf('.Search') < 0)">
					<td style="width: 2%">
						<input
							type='checkbox'
							class='checkbox'
							[style]="styCheckbox"
							[checked]="primary"
							(onChange)="this._onCheckboxClick()"
							[disabled]="!ENABLED"
						/>
					</td>
				</ng-container>
				<td [class]="cssStackedClass" style="width: 30%">
					<span>
						<button
							[id]="ID + '_btnChange'"
							style="margin-left: 4px"
							(click)="this._onSelectClick()"
							class='button'
							[title]="L10n.Term('.LBL_SELECT_BUTTON_TITLE')"
						>
							<ng-container *ngIf="this.legacyIcons">
								<img [src]="this.themeURL + 'edit_inline.gif'" style="border-width: 0px" [class]="sIconClass" />
							</ng-container>
							<ng-container *ngIf="!this.legacyIcons">
								<fa-icon [icon]='edit' [class]="sIconClass"></fa-icon>
							</ng-container>
							<span [class]="sButtonClass">{{ L10n.Term('.LBL_SELECT_BUTTON_LABEL') }}</span>
						</button>
					<ng-container *ngIf="ToBoolean(showCancel)">
						<button
							[id]="ID + '_btnClear'"
							style="margin-left: 4px"
							(click)="this._onCancelClick()"
							class='button'
							[title]="L10n.Term('.LBL_CANCEL_BUTTON_TITLE')"
						>
							<ng-container *ngIf="this.legacyIcons">
								<img [src]="this.themeURL + 'decline_inline.gif'" style="border-width: 0px" [class]="sIconClass" />
							</ng-container>
							<ng-container *ngIf="!this.legacyIcons">
								<fa-icon [icon]='times' [class]="sIconClass"></fa-icon>
							</ng-container>
							<span [class]="sButtonClass">{{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }}</span>
						</button>
					</ng-container>
					<ng-container *ngIf="!ToBoolean(showCancel)">
						<ng-container *ngIf="!ToBoolean(disableClear)">
							<button
								[id]="ID + '_btnClear'"
								style="margin-left: 4px"
								(click)="this._onClearClick()"
								class='button'
								[title]="L10n.Term('.LBL_CLEAR_BUTTON_TITLE')"
							>
								<ng-container *ngIf="this.legacyIcons">
									<img [src]="this.themeURL + 'decline_inline.gif'" style="border-width: 0px" [class]="sIconClass" />
								</ng-container>
								<ng-container *ngIf="!this.legacyIcons">
									<fa-icon [icon]='times' [class]="sIconClass"></fa-icon>
								</ng-container>
								<span [class]="sButtonClass">{{ L10n.Term('.LBL_CLEAR_BUTTON_LABEL') }}</span>
							</button>
						</ng-container>
					</ng-container>
					</span>
				</td>
				<ng-container *ngIf="UI_REQUIRED">
					<span [id]="ID + '_REQUIRED'" class='required' [ngStyle]="cssRequired" >{{ L10n.Term('.ERR_REQUIRED_FIELD') }}</span>
				</ng-container>
			</tr>
		</ng-container>
		<ng-container *ngIf="!tableRow">
			<span [class]="CSS_CLASS" style="display: flex; flex-shrink: 0; flex-wrap: wrap; flex-basis: 100%; align-items: baseline">
				<DynamicPopupView
					[isOpen]="popupOpen"
					[isSearchView]="isSearchView"
					[fromLayoutName]="EDIT_NAME"
					(callback)="this._onSelect($event)"
					[MODULE_NAME]="MODULE_TYPE"
					[rowDefaultSearch]="rowDefaultSearch"
				></DynamicPopupView>
				<AutoComplete
					[id]="ID"
					[value]="DISPLAY_VALUE"
					[items]="items"
					[inputProps]="inputProps"
					[ngStyle]="wrapperStyle"
					[autoHighlight]="false"
					(getItemValue)="this._onGetItemValue($event)"
					(onChange)="this._onTextChange($event)"
					(onSelect)="this._onTextSelect($event)"
					(onTextBlur)="_onTextBlur($event)"
					(onMenuVisibilityChange)="this._onMenuVisibilityChange($event)"
					[disabled]="!ENABLED"
				></AutoComplete>
				<span [style]="buttonWrapperStyle">
					<button
						[id]="ID + '_btnChange'"
						style="margin-left: 4px"
						(click)="this._onSelectClick()"
						[disabled]="!ENABLED"
						class='button'
						[title]="L10n.Term('.LBL_SELECT_BUTTON_TITLE')"
						>
						<ng-container *ngIf="this.legacyIcons">
							 <img [sr]c="this.themeURL + 'edit_inline.gif'" style="border-width: 0px" [class]="sIconClass" />
						</ng-container>
						<ng-container *ngIf="!this.legacyIcons">
							<fa-icon [icon]='edit' [class]="sIconClass"></fa-icon>
						</ng-container>
						<span [class]="sButtonClass">{{ L10n.Term('.LBL_SELECT_BUTTON_LABEL') }}</span>
					</button>
					<ng-container *ngIf="ToBoolean(showCancel)">
						<button
							[id]="ID + '_btnCancel'"
							style="margin-left: 4px"
							(click)="this._onCancelClick()"
							[disabled]="!ENABLED"
							class='button'
							[title]="L10n.Term('.LBL_CANCEL_BUTTON_TITLE')"
						>
							<ng-container *ngIf="this.legacyIcons">
								<img [src]="this.themeURL + 'decline_inline.gif'" style="border-width: 0px" [class]="sIconClass" />
							</ng-container>
							<ng-container *ngIf="!this.legacyIcons">
								<fa-icon [icon]='times' [class]="sIconClass"></fa-icon>
							</ng-container>
							<span [class]="sButtonClass">{{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }}</span>
						</button>
					</ng-container>
					<ng-container *ngIf="!ToBoolean(showCancel)">
						<ng-container *ngIf="!ToBoolean(disableClear)">
							<button
								[id]="ID + '_btnClear'"
								style="margin-left: 4px"
								(click)="this._onClearClick()"
								[disabled]="!ENABLED"
								class='button'
								[title]="L10n.Term('.LBL_CLEAR_BUTTON_TITLE')"
							>
								<ng-container *ngIf="this.legacyIcons">
									 <img [src]="this.themeURL + 'decline_inline.gif'" style="border-width: 0px" [class]="sIconClass" />
								</ng-container>
								<ng-container *ngIf="!this.legacyIcons">
									<fa-icon [icon]='times' [class]="sIconClass"></fa-icon>
								</ng-container>
								<span [class]="sButtonClass">{{ L10n.Term('.LBL_CLEAR_BUTTON_LABEL') }}</span>
							</button>
						</ng-container>
					</ng-container>
					<ng-container *ngIf="UI_REQUIRED">
						<span [id]="ID + '_REQUIRED'" class='required' [style]="cssRequired">{{ L10n.Term('.ERR_REQUIRED_FIELD') }}</span>
					</ng-container>
				</span>
			</span>
		</ng-container>
	</ng-container>`
})
export class EditViewModulePopupComponent extends EditViewComponentBase implements OnInit
{
	public    edit              = faEdit ;
	public    times             = faTimes;
	private   LastQuery         : string  = null;
	private   PartialInput      : boolean = null;
	public    themeURL          : string  = null;
	public    legacyIcons       : boolean = false;

	public    popupOpen         : boolean = null;
	public    primary           : boolean = null;
	public    EDIT_NAME         : string  = null;
	public    FORMAT_MAX_LENGTH : number  = null;
	public    FORMAT_ROWS       : number  = null;
	public    FORMAT_COLUMNS    : number  = null;
	public    DISPLAY_FIELD     : string  = null;
	public    DISPLAY_VALUE     : string  = null;
	public    MODULE_TYPE       : string  = null;
	public    VALUE_MISSING     : boolean = null;
	public    items             : any[]   = null;
	public    ENABLED           : boolean = null;
	public    rowDefaultSearch  : null    = null;

	@Input()  tableRow          : boolean = null;
	@Output() onCheckboxClick   : EventEmitter<string> = new EventEmitter<string>();
	@Input()  isSearchView      : boolean = null;
	@Input()  showCancel        : boolean = null;
	@Input()  disableClear      : boolean = null;
	@Input()  smallButtons      : boolean = null;
	@Output() onCancel          : EventEmitter<void> = new EventEmitter<void>();
	@Output() onChanged         : EventEmitter<{DATA_FIELD  : string, DATA_VALUE: any, DISPLAY_FIELD?          : string, DISPLAY_VALUE?: any, primary?: boolean}> = new EventEmitter<{DATA_FIELD  : string, DATA_VALUE       : any   , DISPLAY_FIELD?: string, DISPLAY_VALUE?: any, primary?: boolean}>();
	@Input()  value             : any      = null;
	// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
	@Input()  allowCustomName   : boolean  = null;

	public    cssRequired       : any     = null;
	public    inputProps        : any     = null;
	public    wrapperStyle      : any     = null;
	public    buttonWrapperStyle: any     = null;
	public    styCheckbox       : any     = null;
	public    sIconClass        : string  = null;
	public    sButtonClass      : string  = null;
	public    cssStackedClass   : string  = null;

	public ToBoolean(s: any)
	{
		return Sql.ToBoolean(s);
	}

	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE, DISPLAY_VALUE } = this;
		// 06/30/2019 Paul.  Return null instead of empty string. 
		let key   = DATA_FIELD;
		let value = DATA_VALUE;
		if ( Sql.IsEmptyString(value) )
		{
			value = null;
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.data ' + DATA_FIELD, DATA_VALUE);
		// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
		if ( this.allowCustomName )
			return { key, value, name: DISPLAY_VALUE };
		else
			return { key, value };
	}

	public validate(): boolean
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, VALUE_MISSING, DISPLAY_VALUE } = this;
		let bVALUE_MISSING: boolean = false;
		let bUI_REQUIRED: boolean = UI_REQUIRED;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.bIsHidden )
		{
			bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE);
			// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
			if ( this.allowCustomName )
				bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE) && Sql.IsEmptyString(DISPLAY_VALUE);
			if ( bVALUE_MISSING != VALUE_MISSING )
			{
				this.VALUE_MISSING = bVALUE_MISSING;
			}
			if ( bVALUE_MISSING && UI_REQUIRED )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.validate ' + DATA_FIELD);
			}
		}
		return !bVALUE_MISSING;
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			let DISPLAY_VALUE: string = DATA_VALUE;
			if ( item != null )
			{
				DISPLAY_VALUE = item.NAME;
			}
			this.DATA_VALUE    = DATA_VALUE;
			this.DISPLAY_VALUE = DISPLAY_VALUE;
		}
		else if ( PROPERTY_NAME == 'ID' )
		{
			this.DATA_VALUE = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'NAME' )
		{
			this.DISPLAY_VALUE = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'enabled' )
		{
			this.ENABLED = Sql.ToBoolean(DATA_VALUE);
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.CSS_CLASS = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'rowDefaultSearch' )
		{
			this.rowDefaultSearch = DATA_VALUE;
		}
	}

	public clear(): void
	{
		const { ENABLED } = this;
		// 01/11/2020.  Apply Field Level Security. 
		if ( ENABLED )
		{
			// 02/02/2020 Paul.  input does not update when DATA_VALUE is set to null. 
			this.DATA_VALUE    = '';
			this.DISPLAY_VALUE = '';
		}
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n : C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService, public ListView: ListViewService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	async ngOnInit()
	{
		const { SplendidCache, Credentials, Security, L10n, Crm_Config } = this;
		// 11/04/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.themeURL    = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');

		let EDIT_NAME        : string  = '';
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let FORMAT_MAX_LENGTH: number  = null;
		let FORMAT_ROWS      : number  = null;
		let FORMAT_COLUMNS   : number  = null;
		let DISPLAY_FIELD    : string  = '';
		let DISPLAY_VALUE    : string  = '';
		let MODULE_TYPE      : string  = '';
		let FIELD_TYPE       : string  = '';
		let ENABLED          : boolean = this.bIsWriteable;

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged, tableRow } = this;
			if ( layout != null )
			{
				EDIT_NAME         = Sql.ToString (layout.EDIT_NAME        );
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX      );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD       );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED      ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX );
				FORMAT_MAX_LENGTH = Sql.ToInteger(layout.FORMAT_MAX_LENGTH);
				FORMAT_ROWS       = Sql.ToInteger(layout.FORMAT_ROWS      );
				FORMAT_COLUMNS    = Sql.ToInteger(layout.FORMAT_COLUMNS   );
				DISPLAY_FIELD     = Sql.ToString (layout.DISPLAY_FIELD    );
				DISPLAY_VALUE     = Sql.ToString (layout.DISPLAY_VALUE    );
				MODULE_TYPE       = Sql.ToString (layout.MODULE_TYPE      );
				FIELD_TYPE        = Sql.ToString (layout.FIELD_TYPE       );
				ID = baseId + '_' + DATA_FIELD;
				if ( Sql.IsEmptyString(MODULE_TYPE) )
				{
					switch ( FIELD_TYPE )
					{
						case 'UserSelect'     :  MODULE_TYPE = 'Users'     ;  break;
						case 'TeamSelect'     :  MODULE_TYPE = 'Teams'     ;  break;
						// 07/10/2019 Paul.  We don't need to support KBTagSelect as it was deprecated. 
						case 'TagSelect'      :  MODULE_TYPE = 'Tags'      ;  break;
						case 'NAICSCodeSelect':  MODULE_TYPE = 'NAICSCodes';  break;
					}
				}
				// 04/27/2019 Paul.  Don't prepopulate here if Dynamic Teams or Users. 
				// 07/19/2019 Paul.  Defer row loading to componentDidMount so that we can do an async ItemName lookup if necessary. 
				if ( row == null && tableRow == null )
				{
					if ( MODULE_TYPE == 'Teams' )
					{
						DATA_VALUE    = Security.TEAM_ID();
						DISPLAY_VALUE = Security.TEAM_NAME();
					}
					else if ( MODULE_TYPE == 'Users' )
					{
						DATA_VALUE    = Security.USER_ID();
						// 01/29/2011 Paul.  If Full Names have been enabled, then prepopulate with the full name. 
						if ( DISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
						{
							DISPLAY_VALUE = Security.FULL_NAME();
						}
						else
						{
							DISPLAY_VALUE = Security.USER_NAME();
						}
					}
				}
				// 08/10/2020 Paul.  Special requirement flags for Teams and Users. 
				// 12/17/2020 Paul.  Don't force the requirements flags on an update panel or search panel. 
				// 06/19/2021 Paul.  WorkflowAlertShells does not require Team or User. 
				if ( layout.EDIT_NAME.indexOf('.MassUpdate') < 0 && layout.EDIT_NAME.indexOf('.Search') < 0 && layout.EDIT_NAME.indexOf('WorkflowAlertShells') < 0 )
				{
					if ( MODULE_TYPE == 'Teams' )
					{
						let bRequireTeamManagement  : boolean = Crm_Config.require_team_management();
						// 10/08/2020 Paul.  DEFAULT_TEAM_ID on the Users.EditView.Settings layout is not required. 
						// 02/08/2021 Paul.  The field is DEFAULT_TEAM, not DEFAULT_TEAM_ID. 
						if ( bRequireTeamManagement && DATA_FIELD != 'DEFAULT_TEAM' )
						{
							UI_REQUIRED = true;
						}
					}
					else if ( MODULE_TYPE == 'Users' )
					{
						let bRequireUserAssignment  : boolean = Crm_Config.require_user_assignment();
						// 10/12/2020 Paul.  REPORTS_TO_ID on the Users.EditView.Settings layout is not required. 
						if ( bRequireUserAssignment && DATA_FIELD != 'REPORTS_TO_ID' )
						{
							UI_REQUIRED = true;
						}
					}
				}
			}
			if ( Sql.IsEmptyString(MODULE_TYPE) )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor MODULE_TYPE is null ' + FIELD_TYPE + '.' + DATA_FIELD, DATA_VALUE, DISPLAY_VALUE, row);
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, DISPLAY_VALUE);
		this.popupOpen         = false            ;
		this.primary           = false            ;
		this.ID                = ID               ;
		this.EDIT_NAME         = EDIT_NAME        ;
		this.FIELD_INDEX       = FIELD_INDEX      ;
		this.DATA_FIELD        = DATA_FIELD       ;
		this.DATA_VALUE        = DATA_VALUE       ;
		this.UI_REQUIRED       = UI_REQUIRED      ;
		this.FORMAT_TAB_INDEX  = FORMAT_TAB_INDEX ;
		this.FORMAT_MAX_LENGTH = FORMAT_MAX_LENGTH;
		this.FORMAT_ROWS       = FORMAT_ROWS      ;
		this.FORMAT_COLUMNS    = FORMAT_COLUMNS   ;
		this.DISPLAY_FIELD     = DISPLAY_FIELD    ;
		this.DISPLAY_VALUE     = DISPLAY_VALUE    ;
		this.MODULE_TYPE       = MODULE_TYPE      ;
		this.VALUE_MISSING     = false            ;
		this.ENABLED           = ENABLED          ;
		this.items             = []               ;

		try
		{
			const { layout, row } = this;
			const { DATA_FIELD, DISPLAY_FIELD, MODULE_TYPE } = this;
			if ( row != null )
			{
				let value: any = await this.getValue(layout, row, DATA_FIELD, DISPLAY_FIELD, MODULE_TYPE);
				this.DATA_VALUE    = value.DATA_VALUE   ;
				this.DISPLAY_VALUE = value.DISPLAY_VALUE;
				this.primary       = value.primary      ;
			}
			// 05/25/2020 Paul.  We need a quick way to initialize the value when editing in a multi-selection. 
			else if ( this.value )
			{
				this.DATA_VALUE    = this.value.DATA_VALUE   ;
				this.DISPLAY_VALUE = this.value.DISPLAY_VALUE;
				this.primary       = this.value.primary      ;
			}
		}
		catch(error: any)
		{
		}

		// 06/23/2020 Paul.  Make use of minimum width. 
		this.inputProps =
		{
			type        : 'text', 
			maxLength   : (FORMAT_MAX_LENGTH > 0 ? FORMAT_MAX_LENGTH : null), 
			tabIndex    : FORMAT_TAB_INDEX,
			style       : {width: '100%', marginRight: '2px', minWidth: '150px'},
			autoComplete: 'off',
			onBlur      : this._onTextBlur,
			onKeyDown   : this._onKeyDown,
		};
		// 05/05/2021 Paul.  Blur prevents the clear button from working. 
		if ( MODULE_TYPE == 'Tags' || MODULE_TYPE == 'NAICSCodes' )
		{
			this.inputProps.onBlur = null;
		}
		// 06/21/2020 Paul.  Add flex to the wrappers. 
		this.wrapperStyle = 
		{
			display   : 'inline-block',
			flexGrow  : 2, 
			flexShrink: 1, 
			flexBasis : '60%'
		};
		// 06/21/2020 Paul.  Add shrink to prevent button overflow. 
		// 11/04/2020 Paul.  Remove nowrap as it is causing overlap with following cell. 
		this.buttonWrapperStyle =
		{
			flexGrow  : 0, 
			flexShrink: 1, 
			flexBasis : '40%', 
		};
		// 08/31/2012 Paul.  Add support for speech. 
		// 04/26/2019 Paul.  Speech appears to be deprecated. 
		//let bEnableSpeech = Crm_Config.enable_speech();
		//let cssSpeech: any = { };
		//if (bEnableSpeech)
		//{
		//	cssSpeech.speech = 'speech';
		//}
		// 10/18/2011 Paul.  A custom field will not have a display name. 
		this.cssRequired = { paddingLeft: '4px', display: (this.VALUE_MISSING ? 'inline' : 'none') };
		// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
		this.styCheckbox = { transform: 'scale(1.5)', marginLeft: '6px', display: 'inline', marginTop: '2px', marginBottom: '6px' };
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		if ( Crm_Config.ToBoolean('enable_legacy_icons') )
		{
			this.styCheckbox.transform = 'scale(1.0)';
			this.styCheckbox.marginBottom = '2px';
		}
		// 11/14/2019 Paul.  Use smaller icons when on 3 column layouts. 
		this.sIconClass   = 'd-lg-none';
		this.sButtonClass = 'd-none d-lg-inline';
		if ( Sql.ToInteger(this.layout.DATA_COLUMNS) > 2 )
		{
			// https://getbootstrap.com/docs/4.3/utilities/display/
			this.sIconClass   = 'd-xl-none';
			this.sButtonClass = 'd-none d-xl-inline';
		}
		if ( Sql.ToBoolean(this.smallButtons) )
		{
			this.sIconClass                   = 'd-xs-inline';
			this.sButtonClass                 = 'd-none';
			this.wrapperStyle.flexBasis       = '75%';
			this.buttonWrapperStyle.flexBasis = '25%';
		}
		// 12/17/2019 Paul.  need a correction as class style is not getting to the edit controls. 
		this.cssStackedClass = null;
		if ( SplendidDynamic.StackedLayout(SplendidCache.UserTheme) )
		{
			this.cssStackedClass = 'tabStackedEditViewDF';
		}
		// 09/21/2019 Paul.  d-lg-none to hide when large screen. 
		// 05/25/2020 Paul.  Remove flex for wrapperStyle to prevent menu from going to the right. 
		// wrapperStyle={ {display: 'flex', flexGrow: 2, flexShrink: 1, flexBasis: '70%'} }
		// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
	}

	ngDoCheck() : void
	{
		this.cssRequired = { paddingLeft: '4px', display: (this.VALUE_MISSING ? 'inline' : 'none') };
	}

	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}

	private async getValue(layout: any, row: any, DATA_FIELD: string, DISPLAY_FIELD: string, MODULE_TYPE: string)
	{
		const { Crm_Modules, Crm_Config, Security } = this;
		let value: any = { DATA_VALUE: '', DISPLAY_VALUE: '', primary: false };
		if ( layout != null )
		{
			let EDIT_NAME = Sql.ToString(layout.EDIT_NAME);
			if ( row != null )
			{
				if ( !Sql.IsEmptyString(DISPLAY_FIELD) && row[DISPLAY_FIELD] != null )
				{
					value.DISPLAY_VALUE = Sql.ToString(row[DISPLAY_FIELD]);
				}
				else if ( row[DATA_FIELD] != null )
				{
					value.DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
					if ( row[DISPLAY_FIELD] === undefined && !Sql.IsEmptyString(value.DATA_VALUE) && !Sql.IsEmptyString(MODULE_TYPE) && layout.FIELD_TYPE == 'ModulePopup' )
					{
						// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
						try
						{
							// 03/17/2020 Paul.  Crm_Modules.ItemName
							value.DISPLAY_VALUE = await Crm_Modules.ItemName(MODULE_TYPE, value.DATA_VALUE);
						}
						catch(error: any)
						{
							// 11/17/2021 Paul.  Special case for LineItems where ID may not exist. 
							if ( this.layout && this.layout.EDIT_NAME && this.layout.EDIT_NAME.indexOf('.LineItems') && this.row && this.row.NAME )
							{
								value.DISPLAY_VALUE = this.row.NAME;
							}
							else
							{
								console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue', error, this.row, this.layout);
								value.DISPLAY_VALUE = error.message;
							}
						}
					}
				}
				// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
				// 04/14/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
				if ( Sql.ToBoolean(row['DetailViewRelationshipCreate']) )
				{
					if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'TEAM_ID' )
					{
						if ( Crm_Config.ToBoolean('inherit_team') && !Sql.IsEmptyString(row[DATA_FIELD]) )
						{
							value.DISPLAY_VALUE = row['TEAM_NAME'];
						}
						else
						{
							value.DISPLAY_VALUE = Security.TEAM_NAME();
						}
					}
					else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'ASSIGNED_USER_ID' )
					{
						if ( Crm_Config.ToBoolean('inherit_assigned_user') && !Sql.IsEmptyString(row[DATA_FIELD]) )
						{
							if ( DISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
							{
								value.DISPLAY_VALUE = row['ASSIGNED_TO_NAME'];
							}
							else
							{
								value.DISPLAY_VALUE = row['ASSIGNED_TO'];
							}
						}
						else
						{
							if ( DISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
							{
								value.DISPLAY_VALUE = Security.FULL_NAME();
							}
							else
							{
								value.DISPLAY_VALUE = Security.USER_NAME();
							}
						}
					}
				}
			}
			else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'TEAM_ID' )
			{
				value.DISPLAY_VALUE = Security.TEAM_NAME();
			}
			else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'ASSIGNED_USER_ID' )
			{
				if ( DISPLAY_FIELD == 'ASSIGNED_TO_NAME' )
				{
					value.DISPLAY_VALUE = Security.FULL_NAME();
				}
				else
				{
					value.DISPLAY_VALUE = Security.USER_NAME();
				}
			}
			if ( row != null )
			{
				if ( row[DATA_FIELD] != null )
				{
					value.DATA_VALUE = row[DATA_FIELD];
				}
				// 06/28/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
				if ( Sql.ToBoolean(row['DetailViewRelationshipCreate']) )
				{
					if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'TEAM_ID' )
					{
						if ( Crm_Config.ToBoolean('inherit_team') && !Sql.IsEmptyString(row[DATA_FIELD]) )
						{
							value.DATA_VALUE = Sql.ToString(row['TEAM_ID']);
						}
						else
						{
							// 11/05/2020 Paul.  Correct to use the ID and not the NAME. 
							value.DATA_VALUE = Security.TEAM_ID();
						}
					}
					else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'ASSIGNED_USER_ID' )
					{
						if ( Crm_Config.ToBoolean('inherit_assigned_user') && !Sql.IsEmptyString(row[DATA_FIELD]) )
						{
							value.DATA_VALUE = Sql.ToString(row['ASSIGNED_USER_ID']);
						}
						else
						{
							value.DATA_VALUE = Security.USER_ID();
						}
					}
				}
			}
			else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'TEAM_ID' && !Sql.IsEmptyGuid(Security.TEAM_ID()) )
			{
				value.DATA_VALUE = Security.TEAM_ID();
			}
			else if ( EDIT_NAME.indexOf('.Search') < 0 && DATA_FIELD == 'ASSIGNED_USER_ID' )
			{
				value.DATA_VALUE = Security.USER_ID();
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue ' + DATA_FIELD, value, row);
		return value;
	}

	public _onSelect = (value: {Action: string, ID?: string, NAME?: string, PROCESS_NOTES?: string, selectedItems?: any}) =>
	{
		const { baseId, layout, row, onChanged, onUpdate, tableRow } = this;
		const { DATA_FIELD, DISPLAY_FIELD, primary, ENABLED } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect ' + DATA_FIELD + ' ' + DISPLAY_FIELD, value);
		try
		{
			if ( value.Action == 'SingleSelect' )
			{
				// 07/23/2019.  Apply Field Level Security. 
				if ( ENABLED )
				{
					if ( tableRow )
					{
						// 07/15/2019 Paul.  If this is a dynamic list, then clear value after selection. 
						this.popupOpen     = false;
						this.DATA_VALUE    = '';
						this.DISPLAY_VALUE = '';
					}
					else
					{
						this.popupOpen     = false;
						this.DATA_VALUE    = value.ID;
						this.DISPLAY_VALUE = value.NAME;
						this.validate();
					}
					onChanged.emit({DATA_FIELD, DATA_VALUE: value.ID, DISPLAY_FIELD, DISPLAY_VALUE: value.NAME, primary});
					// 04/27/2019 Paul.  ModulePopup does not support dependent fields. 
					// 01/30/2020 Paul.  A contact may be dependent on an account. 
					// 02/04/2020 Paul.  onUpdate will be null inside ModuleMultiSelect. 
					if ( onUpdate )
					{
						onUpdate.emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE: value.ID, item: value});
					}
				}
				else
				{
					console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect ACCESS DENIED for ' + DATA_FIELD + ' ' + DISPLAY_FIELD, value);
					this.popupOpen = false;
				}
			}
			else if ( value.Action == 'Close' )
			{
				this.popupOpen = false;
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', error);
		}
	}

	public _onClearClick = (): void =>
	{
		const { baseId, layout, row, onChanged } = this;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE, ENABLED } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClearClick ' + DATA_FIELD + ' ' + DISPLAY_FIELD, DATA_VALUE, DISPLAY_VALUE, row);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.DATA_VALUE    = null;
				this.DISPLAY_VALUE = '';
				this.validate();
				// 11/17/2019 Paul.  Send update to parent. 
				this.onChanged.emit({DATA_FIELD, DATA_VALUE: null, DISPLAY_FIELD, DISPLAY_VALUE: null, primary: false});

			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onClearClick', error);
		}
	}

	public _onCancelClick = (): void =>
	{
		this.onCancel.emit();
	}

	public _onSelectClick = (): void =>
	{
		const { baseId, layout, row } = this;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE } = this;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectClick ' + DATA_FIELD + ' ' + DISPLAY_FIELD, DATA_VALUE, DISPLAY_VALUE, row);
		this.popupOpen = true;
	}

	public _onCheckboxClick = () =>
	{
		this.primary = !this.primary;
		this.onCheckboxClick.emit(this.DATA_VALUE);
	}

	public _onTextChange(obj: { event: any, value: string})
	{
		const { baseId, layout, row, onChanged, ListView } = this;
		const { DATA_FIELD, MODULE_TYPE, ENABLED } = this;
		let value: string = obj.value;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange ' + DATA_FIELD, value);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.PartialInput = true;
				this.DATA_VALUE    = null;
				this.DISPLAY_VALUE = value;
				{
					// 04/23/2019 Paul.  Try and prevent debounce by saving last query value. 
					this.LastQuery = value;
					// 04/23/2019 Paul.  Must specify at least 2 characters for search to execute. 
					if ( value.length >= 2 )
					{
						let sSORT_FIELDS: string = 'NAME';
						let sSELECT_FIELDS: string = 'ID,NAME';
						let sSEARCH_FILTER: string = 'NAME like \'' + Sql.EscapeSQLLike(value) + '%\'';
						// 04/23/2019 Paul.  Only request 12 records.  This is not configurable. 
						if ( MODULE_TYPE == 'Users' )
						{
							sSORT_FIELDS = 'USER_NAME';
							sSELECT_FIELDS = 'ID,USER_NAME';
							sSEARCH_FILTER = 'USER_NAME like \'' + Sql.EscapeSQLLike(value) + '%\'';
						}
						ListView.LoadModulePaginated(MODULE_TYPE, sSORT_FIELDS, 'asc', sSELECT_FIELDS, sSEARCH_FILTER, null, 12, 0, false, false).then((d) =>
						{
							if ( this.LastQuery == value )
							{
								if ( MODULE_TYPE == 'Users' )
								{
									for ( let nRow in d.results )
									{
										let row = d.results[nRow];
										row['NAME'] = row['USER_NAME'];
									}
								}
								//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange ' + MODULE_TYPE + ' ' + DATA_FIELD, d.results);
								this.items = d.results;
							}
						})
						.catch((error: any) =>
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange', error);
						});
					}
					else
					{
						this.items = [];
					}
				}
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange', error);
		}
	}

	public _onGetItemValue = (item: any) =>
	{
		const { DATA_FIELD } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGetItemValue ' + DATA_FIELD, item);
		return item.NAME;
	}

	public _onTextSelect = (obj: {value: string, item: any}) =>
	{
		const { value, item } = obj;
		const { onChanged, onUpdate } = this;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE, ENABLED } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect ' + DATA_FIELD, value, item);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.PartialInput = false;
				this.DATA_VALUE = item.ID;
				this.DISPLAY_VALUE = item.NAME;
				this.validate();
				onChanged.emit({DATA_FIELD, DATA_VALUE: item.ID, DISPLAY_FIELD, DISPLAY_VALUE: item.NAME, primary: false});
				// 04/27/2019 Paul.  ModulePopup does not support dependent fields. 
				// 01/30/2020 Paul.  A contact may be dependent on an account. 
				// 02/04/2020 Paul.  onUpdate will be null inside ModuleMultiSelect. 
				if ( onUpdate )
				{
					onUpdate.emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE: item.ID, item});
				}
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect', error);
		}
	}

	public _onTextBlur = (event: any) =>
	{
		const { onChanged, onUpdate, tableRow, allowCustomName } = this;
		const { DATA_FIELD, DATA_VALUE, DISPLAY_FIELD, DISPLAY_VALUE, MODULE_TYPE, items, ENABLED } = this;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextBlur ' + MODULE_TYPE + ' ' + DATA_FIELD, DATA_VALUE, DISPLAY_VALUE);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				if ( this.PartialInput )
				{
					this.PartialInput = false;
					let item = { ID: DATA_VALUE, NAME: DISPLAY_VALUE };
					// 04/26/2019 Paul.  If empty, then clear item. 
					if ( Sql.IsEmptyString(DISPLAY_VALUE) )
					{
						item = { ID: null, NAME: '' };
					}
					// 04/26/2019 Paul.  If items were found, then take the first item.  Otherwise use previous values. 
					else if ( items != null && items.length > 0 )
					{
						item = items[0];
					}
					if ( tableRow )
					{
						// 07/15/2019 Paul.  If this is a dynamic list, then clear value after selection. 
						this.DATA_VALUE    = '';
						this.DISPLAY_VALUE = '';
					}
					else
					{
						// 08/12/2019 Paul.  Tags and NAICSCodes have tableRow, so don't need to be excluded here.  If item not selected, then clear the DISPLAY_VALUE. 
						if ( Sql.IsEmptyGuid(item.ID) )
						{
							// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
							if ( !Sql.ToBoolean(allowCustomName) )
							{
								item = { ID: null, NAME: null };
							}
						}
						this.DATA_VALUE    = item.ID;
						this.DISPLAY_VALUE = item.NAME;
						this.validate();
					}
					// 08/12/2019 Paul.  Tags only send the name, not the ID.  Random NAICSCodes are not allowed, so it is not included here. 
					if ( !Sql.IsEmptyGuid(item.ID) || (MODULE_TYPE == 'Tags' && !Sql.IsEmptyGuid(item.NAME)) )
					{
						onChanged.emit({DATA_FIELD, DATA_VALUE: item.ID, DISPLAY_FIELD, DISPLAY_VALUE: item.NAME, primary: false});
					}
					// 04/27/2019 Paul.  ModulePopup does not support dependent fields. 
					// 01/30/2020 Paul.  A contact may be dependent on an account. 
					// 02/04/2020 Paul.  onUpdate will be null inside ModuleMultiSelect. 
					if ( onUpdate )
					{
						onUpdate.emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE: item.ID, item});
					}
				}
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextBlur', error);
		}
	}

	/*
	public _onRenderMenu = (children: any) =>
	{
		return(<div style={ { backgroundColor: '#efefef', border: '0 solid black'} }>
			{children}
		</div>);
	}

	public _onRenderItem = (item, isHighlighted) =>
	{
		let cssHighlighed: any = {};
		if ( isHighlighted )
			cssHighlighed = { color: 'white', backgroundColor: '#4095bf' };
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRenderItem', cssHighlighed, item);
		return (<div class='ui-menu-item' style={cssHighlighed}>
			{ item.NAME }
		</div>);
	}
	*/

	public _onMenuVisibilityChange(isOpen: any)
	{
		// 04/26/2019 Paul.  Clearn menu on exit. 
		if ( !isOpen )
		{
			this.items = [];
		}
	}

	// 08/07/2019 Paul.  Enter is the same as blur. 
	public _onKeyDown(event: any)
	{
		const { DISPLAY_VALUE } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' )
		{
			this._onTextBlur(null);
		}
	}

}
