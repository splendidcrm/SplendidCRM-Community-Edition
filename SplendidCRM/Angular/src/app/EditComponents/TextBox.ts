import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;

import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { C10nService                                               } from '../scripts/C10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import Sql                                                           from '../scripts/Sql'               ;
import { EditViewComponentBase                                     } from '../EditComponents/EditViewComponentBase';

@Component({
	selector: 'EditViewTextBox',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for TextBox FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyChanged()">
		<span>onChanged is null for TextBox DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<ng-container *ngIf="FORMAT_ROWS == 0">
			<span [class]="CSS_CLASS" [ngStyle]="cssFlexGrow">
				<input
					[id]="ID"
					[value]="DATA_VALUE"
					[ngStyle]="cssInput"
					[maxLength]="FORMAT_MAX_LENGTH > 0 ? FORMAT_MAX_LENGTH : null"
					[tabIndex]="FORMAT_TAB_INDEX"
					[disabled]="!ENABLED"
					type="text"
					(change)="_onChange($event)"
					(keydown)="_onKeyDown($event)"
				/>
				<ng-container *ngIf="UI_REQUIRED">
					<span [id]="ID + '_REQUIRED'" class="required" [ngStyle]="cssRequired">{{ L10n.Term('.ERR_REQUIRED_FIELD') }}</span>
				</ng-container>
				<ng-container *ngIf="VALIDATOR_FAILED">
					<span [id]="ID + '_VALIDATOR'" class='required' [ngStyle]="cssRequired">{{ L10n.Term(FIELD_VALIDATOR_MESSAGE) }}</span>
				</ng-container>
			</span>
		</ng-container>
		<ng-container *ngIf="FORMAT_ROWS > 0">
			<span [class]="CSS_CLASS" [ngStyle]="cssFlexGrow">
				<textarea
					[id]="ID"
					[value]="DATA_VALUE"
					[tabIndex]="FORMAT_TAB_INDEX"
					autoComplete='off'
					[rows]="FORMAT_ROWS"
					[cols]="FORMAT_COLUMNS"
					[disabled]="!ENABLED"
					(change)="_onChange($event)"
				></textarea>
				<ng-container *ngIf="UI_REQUIRED">
					<span [id]="ID + '_REQUIRED'" class="required" [ngStyle]="cssRequired">{{ L10n.Term('.ERR_REQUIRED_FIELD') }}</span>
				</ng-container>
				<ng-container *ngIf="VALIDATOR_FAILED">
					<span [id]="ID + '_VALIDATOR'" class='required' [ngStyle]="cssRequired">{{ L10n.Term(FIELD_VALIDATOR_MESSAGE) }}</span>
				</ng-container>
			</span>
		</ng-container>
	</ng-container>`
})
export class EditViewTextBoxComponent extends EditViewComponentBase implements OnInit
{
	public FORMAT_SIZE            : number  = null;
	public FORMAT_MAX_LENGTH      : number  = null;
	public FORMAT_ROWS            : number  = null;
	public FORMAT_COLUMNS         : number  = null;
	public cssRequired            : any     = null;
	public cssFlexGrow            : any     = null;
	public cssInput               : any     = null;

	public IsArray(data: any)
	{
		return Array.isArray(data);
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n : C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	ngOnInit()
	{
		const { SplendidCache, Credentials, Security, L10n, Crm_Config } = this;
		let FIELD_INDEX            : number  = 0;
		let DATA_FIELD             : string  = '';
		let DATA_VALUE             : string  = '';
		let UI_REQUIRED            : boolean = null;
		let FORMAT_TAB_INDEX       : number  = null;
		let FORMAT_SIZE            : number  = null;
		let FORMAT_MAX_LENGTH      : number  = null;
		let FORMAT_ROWS            : number  = null;
		let FORMAT_COLUMNS         : number  = null;
		let ENABLED                : boolean = this.bIsWriteable;
		// 10/05/2021 Paul.  Add support for regular expression validation. 
		let FIELD_VALIDATOR_MESSAGE: string = null;
		let VALIDATION_TYPE        : string = null;
		let REGULAR_EXPRESSION     : string = null;

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this;
			if (layout != null)
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX      );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD       );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED      ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX );
				FORMAT_SIZE       = Sql.ToInteger(layout.FORMAT_SIZE      );
				FORMAT_MAX_LENGTH = Sql.ToInteger(layout.FORMAT_MAX_LENGTH);
				FORMAT_ROWS       = Sql.ToInteger(layout.FORMAT_ROWS      );
				FORMAT_COLUMNS    = Sql.ToInteger(layout.FORMAT_COLUMNS   );
				// 10/05/2021 Paul.  Add support for regular expression validation. 
				FIELD_VALIDATOR_MESSAGE = Sql.ToString (layout.FIELD_VALIDATOR_MESSAGE);
				VALIDATION_TYPE         = Sql.ToString (layout.VALIDATION_TYPE        );
				REGULAR_EXPRESSION      = Sql.ToString (layout.REGULAR_EXPRESSION     );
				ID = baseId + '_' + DATA_FIELD;

				if ( row != null )
				{
					DATA_VALUE = this.getValue(layout, row, DATA_FIELD);
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID                      = ID                     ;
		this.FIELD_INDEX             = FIELD_INDEX            ;
		this.DATA_FIELD              = DATA_FIELD             ;
		this.DATA_VALUE              = DATA_VALUE             ;
		this.UI_REQUIRED             = UI_REQUIRED            ;
		this.FORMAT_TAB_INDEX        = FORMAT_TAB_INDEX       ;
		this.FORMAT_SIZE             = FORMAT_SIZE            ;
		this.FORMAT_MAX_LENGTH       = FORMAT_MAX_LENGTH      ;
		this.FORMAT_ROWS             = FORMAT_ROWS            ;
		this.FORMAT_COLUMNS          = FORMAT_COLUMNS         ;
		this.VALUE_MISSING           = false                  ;
		this.ENABLED                 = ENABLED                ;
		// 10/05/2021 Paul.  Add support for regular expression validation. 
		this.FIELD_VALIDATOR_MESSAGE = FIELD_VALIDATOR_MESSAGE;
		this.VALIDATION_TYPE         = VALIDATION_TYPE        ;
		this.REGULAR_EXPRESSION      = REGULAR_EXPRESSION     ;
		this.VALIDATOR_FAILED        = false                  ;
	}

	ngDoCheck() : void
	{
		this.cssRequired = { paddingLeft: '4px', display: (this.VALUE_MISSING ? 'inline' : 'none') };
		// 09/27/2020 Paul.  We need to be able to disable the default grow on TextBox. 
		// 11/10/2020 Paul.  We are having a problem with the text field extending into the next column instead of expanding the current column. 
		this.cssFlexGrow = { flexGrow: 1, overflowX: 'hidden' };
		if ( this.bDisableFlexGrow )
		{
			this.cssFlexGrow = {};
		}
		if ( this.FORMAT_ROWS == 0 )
		{
			this.cssInput = { marginRight: '4px' };
			if ( !this.ENABLED )
			{
				this.cssInput.backgroundColor = '#DDDDDD';
			}
			// 06/23/2020 Paul.  Make use of minimum width. 
			if ( this.FORMAT_SIZE > 0 )
			{
				// 01/04/2022 Paul.  Disable flex grow will also use fixed width instead of minimum width. 
				if ( this.bDisableFlexGrow )
					this.cssInput.width = (this.FORMAT_SIZE * 5).toString() + 'px';
				else
					this.cssInput.minWidth = (this.FORMAT_SIZE * 5).toString() + 'px';
			}
		}
	}

	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}

	private getValue(layout: any, row: any, DATA_FIELD: string): string
	{
		let DATA_VALUE : string = '';
		if ( layout != null && row != null )
		{
			let FORMAT_ROWS = Sql.ToInteger(layout.FORMAT_ROWS);
			if ( FORMAT_ROWS == 0 )
			{
				// 09/10/2011 Paul.  Search fields can have multiple fields. 
				if ( row[DATA_FIELD] != null )
				{
					// 08/10/2020 Paul.  Having multiple fields does not make a difference in json as key still returns value. 
					/*
					if ( DATA_FIELD.indexOf(' ') > 0 )
					{
						let arrDATA_FIELD = DATA_FIELD.split(' ');
						for ( let nFieldIndex = 0; nFieldIndex < arrDATA_FIELD.length; nFieldIndex++ )
						{
							if ( row != null && row[arrDATA_FIELD[nFieldIndex]] != null )
							{
								DATA_VALUE = Sql.ToString(row[arrDATA_FIELD[nFieldIndex]]);
							}
						}
					}
					else
					*/
					{
						DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
					}
				}
			}
			else
			{
				if ( row[DATA_FIELD] != null )
				{
					DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
				}
			}
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getValue ' + DATA_FIELD, DATA_VALUE, row);
		return DATA_VALUE;
	}

	public _onChange(e: any)
	{
		const { baseId, layout, row, onChanged, onUpdate } = this;
		const { DATA_FIELD, ENABLED } = this;
		let DATA_VALUE: string = e.target.value;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				// 10/05/2021 Paul.  Add support for regular expression validation. 
				// 10/05/2021 Paul.  There seems to be a race condition with respect to the validator.  Perform here as well. 
				this.DATA_VALUE       = DATA_VALUE;
				this.VALIDATOR_FAILED = this.HasValidatorFailed(DATA_VALUE);
				this.validate();
				this.onChanged.emit({DATA_FIELD  : DATA_FIELD, DATA_VALUE});
				this.onUpdate .emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE});
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	public _onKeyDown(event: any)
	{
		const { onSubmit } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' && onSubmit.observed )
		{
			this.onSubmit.emit();
		}
	}

}
