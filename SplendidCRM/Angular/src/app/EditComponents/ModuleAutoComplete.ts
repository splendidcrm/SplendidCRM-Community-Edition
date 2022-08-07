import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;

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
	selector: 'EditViewModuleAutoComplete',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for ModuleAutoComplete FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyChanged()">
		<span>onChanged is null for ModuleAutoComplete DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
			<span [class]="CSS_CLASS" style="display: flex; flex: 2 0 70%; margin-right: 2px;">
				<AutoComplete
					[id]="ID"
					[value]="DATA_VALUE"
					[items]="items"
					[inputProps]="inputProps"
					[wrapperStyle]="wrapperStyle"
					[autoHighlight]="false"
					(getItemValue)="this._onGetItemValue($event)"
					(onChange)="this._onTextChange($event)"
					(onSelect)="this._onTextSelect($event)"
					(onMenuVisibilityChange)="this._onMenuVisibilityChange($event)"
					(onKeyDown)="_onKeyDown($event)"
					[disabled]="!ENABLED"
				></AutoComplete>
				<ng-container *ngIf="UI_REQUIRED">
					<span [id]="ID + '_REQUIRED'" class='required' [style]="cssRequired">{{ L10n.Term('.ERR_REQUIRED_FIELD') }}</span>
				</ng-container>
			</span>
	</ng-container>`
})
export class EditViewModuleAutoCompleteComponent extends EditViewComponentBase implements OnInit
{
	private   LastQuery         : string  = null;
	private   PartialInput      : boolean = null;
	public    themeURL          : string  = null;
	public    legacyIcons       : boolean = false;

	public    FORMAT_MAX_LENGTH : number  = null;
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
	@Output() onChanged         : EventEmitter<{DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any}> = new EventEmitter<{DATA_FIELD  : string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any}>();
	@Output() OnUpdate          : EventEmitter<{PARENT_FIELD: string, DATA_VALUE: any, item?: any}> = new EventEmitter<{PARENT_FIELD: string, DATA_VALUE: any, item?: any}>();
	@Output() Page_Command      : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();
	@Input()  value             : any      = null;
	// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
	@Input()  allowCustomName   : boolean  = null;

	public    cssRequired       : any     = null;
	public    inputProps        : any     = null;
	public    wrapperStyle      : any     = null;

	public ToBoolean(s: any)
	{
		return Sql.ToBoolean(s);
	}

	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE } = this;
		return { key: DATA_FIELD, value: DATA_VALUE };
	}

	public validate(): boolean
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, VALUE_MISSING, ENABLED } = this;
		let bVALUE_MISSING: boolean = false;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.bIsHidden )
		{
			bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE);
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
			this.DATA_VALUE    = DATA_VALUE;
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

		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let FORMAT_MAX_LENGTH: number  = null;
		let MODULE_TYPE      : string  = null;
		let ENABLED          : boolean = this.bIsWriteable;

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX      );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD       );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED      ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX );
				FORMAT_MAX_LENGTH = Sql.ToInteger(layout.FORMAT_MAX_LENGTH);
				MODULE_TYPE       = Sql.ToString (layout.MODULE_TYPE      );
				ID = baseId + '_' + DATA_FIELD;

				if ( row != null )
				{
					DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
				}
				else if ( row == null )
				{
					DATA_VALUE = Sql.ToString(DATA_VALUE);
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.ID                = ID               ;
		this.FIELD_INDEX       = FIELD_INDEX      ;
		this.DATA_FIELD        = DATA_FIELD       ;
		this.DATA_VALUE        = DATA_VALUE       ;
		this.UI_REQUIRED       = UI_REQUIRED      ;
		this.FORMAT_TAB_INDEX  = FORMAT_TAB_INDEX ;
		this.FORMAT_MAX_LENGTH = FORMAT_MAX_LENGTH;
		this.MODULE_TYPE       = MODULE_TYPE      ;
		this.VALUE_MISSING     = false            ;
		this.ENABLED           = ENABLED          ;
		this.items             = []               ;

		// 06/23/2020 Paul.  Make use of minimum width. 
		this.inputProps =
		{
			type        : 'text', 
			maxLength   : (FORMAT_MAX_LENGTH > 0 ? FORMAT_MAX_LENGTH : null), 
			tabIndex    : FORMAT_TAB_INDEX,
			style       : {width: '100%', minWidth: '150px'},
			autoComplete: 'off',
			//onKeyDown   : this._onKeyDown,
		};
		this.wrapperStyle = 
		{
			width: '100%'
		};
		// 04/26/2019 Paul.  Speech appears to be deprecated. 
		//let bEnableSpeech = Crm_Config.enable_speech();
		//let cssSpeech = {};
		//if (bEnableSpeech)
		//{
		//	cssSpeech = { speech: 'speech' };
		//}
		// 05/16/2018 Paul.  Defer submit key. 
		//if ( sSubmitID != null )
		//{
		//	txt.onkeypress = function(e)
		//	{
		//		return RegisterEnterKeyPress(e, sSubmitID);
		//	};
		//}
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

	public _onTextChange(obj: any)
	{
		const { event, value } = obj;
		const { baseId, layout, row, onChanged, onUpdate, ListView } = this;
		const { DATA_FIELD, MODULE_TYPE, ENABLED } = this;
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.PartialInput = true;
				this.DATA_VALUE   = value;
				// 05/02/2019 Paul.  With autocomplete, partial and wildcards are still allowed, so send to parent. 
				console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextChange ' + DATA_FIELD, value);
				onChanged.emit({DATA_FIELD              , DATA_VALUE: value});
				onUpdate .emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE: value});
				// 04/23/2019 Paul.  Try and prevent debounce by saving last query value. 
				this.LastQuery = value;
				// 04/23/2019 Paul.  Must specify at least 2 characters for search to execute. 
				if ( value.length >= 2 )
				{
					let sSORT_FIELDS  : string = 'NAME';
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
		const { onChanged, onUpdate, Page_Command } = this;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, MODULE_TYPE, ENABLED } = this;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect ' + DATA_FIELD, value, item);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.PartialInput = false;
				this.DATA_VALUE   = item.NAME;
				this.validate();
				onChanged.emit({DATA_FIELD              , DATA_VALUE: item.NAME});
				onUpdate .emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE: item.NAME});
				// 11/21/2021 Paul.  Use Page_Command to send AutoComplete selection event. 
				if ( Page_Command )
				{
					Page_Command.emit({sCommandName: 'AutoComplete', sCommandArguments: { FIELD_NAME: DATA_FIELD, MODULE_NAME: MODULE_TYPE, VALUE: item.NAME} });
				}
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onTextSelect', error);
		}
	}

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
		const { onSubmit } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' && onSubmit.observed )
		{
			onSubmit.emit();
		}
	}

}
