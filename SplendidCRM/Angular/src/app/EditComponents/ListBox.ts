import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { Router                                                    } from '@angular/router'              ;
import { XMLParser }                                                 from 'fast-xml-parser'              ;

import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import { CredentialsService                                        } from '../scripts/Credentials'       ;
import { SecurityService                                           } from '../scripts/Security'          ;
import { L10nService                                               } from '../scripts/L10n'              ;
import { C10nService                                               } from '../scripts/C10n'              ;
import { CrmConfigService, CrmModulesService                       } from '../scripts/Crm'               ;
import { FormattingService                                         } from '../scripts/Formatting'        ;
import Sql                                                           from '../scripts/Sql'               ;
import { StartsWith                                                } from '../scripts/utility'           ;
import { EditViewComponentBase                                     } from '../EditComponents/EditViewComponentBase';

@Component({
	selector: 'EditViewListBox',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for ListBox FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyList()">
		<div>LIST_NAME is empty for ListBox DATA_FIELD {{ DATA_FIELD }}</div>
	</ng-container>
	<ng-container *ngIf="IsEmptyChanged()">
		<span>onChanged is null for ListBox DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<ng-container *ngIf="IsCsv()">
			<span style="margin-right: 4px">
				<select
					[id]="ID"
					[value]="DATA_VALUE ? DATA_VALUE : ''"
					[tabIndex]="FORMAT_TAB_INDEX"
					[disabled]="!ENABLED"
					[class]="CSS_CLASS"
					multiselect
					(change)="_onMultiSelectChange($event)"
				>
					<option *ngFor="let item of LIST_VALUES"
						[value]="item.value"
						[selected]="IsSelected(DATA_VALUE)"
					>{{ item.label }}</option>
				</select>
				<ng-container *ngIf="UI_REQUIRED">
					<span [id]="ID + '_REQUIRED'" class="required" [ngStyle]="cssRequired">{{ L10n.Term('.ERR_REQUIRED_FIELD') }}</span>
				</ng-container>
			</span>
		</ng-container>
		<ng-container *ngIf="IsMultiple()">
			<span style="margin-right: 4px">
				<select
					[id]="ID"
					[value]="DATA_VALUE ? DATA_VALUE : ''"
					[tabIndex]="FORMAT_TAB_INDEX"
					[disabled]="!ENABLED"
					[class]="CSS_CLASS"
					multiselect
					(change)="_onMultiSelectChange($event)"
				>
					<option *ngFor="let item of LIST_VALUES"
						[value]="item.value"
						[selected]="IsSelected(DATA_VALUE)"
					>{{ item.label }}</option>
				</select>
				<ng-container *ngIf="UI_REQUIRED">
					<span [id]="ID + '_REQUIRED'" class="required" [ngStyle]="cssRequired">{{ L10n.Term('.ERR_REQUIRED_FIELD') }}</span>
				</ng-container>
			</span>
		</ng-container>
		<ng-container *ngIf="IsSingle()">
			<span style="margin-right: 4px">
				<select
					[id]="ID"
					[tabIndex]="FORMAT_TAB_INDEX"
					[disabled]="!ENABLED"
					[class]="CSS_CLASS"
					(change)="_onSelectChange($event)"
				>
					<option *ngFor="let item of LIST_VALUES"
						[value]="item.value"
						[selected]="IsSelected(DATA_VALUE)"
					>{{ item.label }}</option>
				</select>
				<ng-container *ngIf="UI_REQUIRED">
					<span [id]="ID + '_REQUIRED'" class="required" [ngStyle]="cssRequired">{{ L10n.Term('.ERR_REQUIRED_FIELD') }}</span>
				</ng-container>
			</span>
		</ng-container>
	</ng-container>`
})
export class EditViewListBoxComponent extends EditViewComponentBase implements OnInit
{
	public BIT_VALUES             : boolean[] = null;
	public DATA_FORMAT            : string    = null;
	public LIST_NAME              : string    = null;
	public LIST_VALUES            : any[]     = null;
	public PARENT_FIELD           : string    = null;
	public FORMAT_ROWS            : number    = null;
	public ONCLICK_SCRIPT         : string    = null;
	public cssRequired            : any     = null;

	public IsEmptyList()
	{
		return Sql.IsEmptyString(this.LIST_NAME) && Sql.IsEmptyString(this.PARENT_FIELD);
	}

	public IsVisible(): boolean
	{
		return !this.IsEmptyField() && !this.layout.hidden && !this.IsEmptyList();
	}

	public IsCsv(): boolean
	{
		return (Math.abs(this.FORMAT_ROWS) > 0 && (this.DATA_FORMAT == 'csv' || this.DATA_FORMAT == 'cvs'));
	}

	public IsMultiple(): boolean
	{
		return (Math.abs(this.FORMAT_ROWS) > 0 && !(this.DATA_FORMAT == 'csv' || this.DATA_FORMAT == 'cvs'));
	}

	public IsSingle(): boolean
	{
		return Math.abs(this.FORMAT_ROWS) == 0;
	}

	public IsSelected(value: string): boolean
	{
		const { DATA_VALUE, LIST_VALUES } = this;
		if ( this.IsSingle() )
		{
			return value == Sql.ToString(DATA_VALUE);
		}
		else if ( DATA_VALUE != null && Array.isArray(DATA_VALUE) )
		{
		}
		return false;
	}

	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE, DATA_FORMAT } = this;
		let value: any = DATA_VALUE;
		// 08/17/2019 Paul.  Return as CSV if required. 
		if ( Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('csv') >= 0 )
		{
			if ( value != null && Array.isArray(value) )
			{
				value = value.join(',');
			}
		}
		return { key: DATA_FIELD, value };
	}

	public validate(): boolean
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, FORMAT_ROWS, VALUE_MISSING, ENABLED } = this;
		let bVALUE_MISSING: boolean = false;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.bIsHidden )
		{
			if ( Math.abs(FORMAT_ROWS) > 0 )
			{
				bVALUE_MISSING = DATA_VALUE != null && DATA_VALUE.length > 0;
			}
			else
			{
				bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE);
			}
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
		const { layout, onChanged, onUpdate } = this;
		const { DATA_FIELD } = this;
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.DATA_VALUE = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'list' )
		{
			let LIST_NAME: string = DATA_VALUE;
			let objValue: any = this.getValues(layout, null, LIST_NAME);
			DATA_VALUE  = objValue.DATA_VALUE ;
			let BIT_VALUES       : boolean[] = objValue.BIT_VALUES ;
			let lstOptions       : any[]     = objValue.lstOptions ;
			let lstSelected      : any       = objValue.lstSelected;
			this.DATA_VALUE  = lstSelected;
			this.BIT_VALUES  = BIT_VALUES ;
			this.LIST_VALUES = lstOptions ;
			this.onChanged.emit({DATA_FIELD  : DATA_FIELD, DATA_VALUE: lstSelected});
			this.onUpdate .emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE: lstSelected});
		}
		else if ( PROPERTY_NAME == 'enabled' )
		{
			this.ENABLED = Sql.ToBoolean(DATA_VALUE);
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.CSS_CLASS = DATA_VALUE;
		}
	}

	public clear(): void
	{
		const { FORMAT_ROWS, ENABLED } = this;
		// 01/11/2020.  Apply Field Level Security. 
		if ( ENABLED )
		{
			// 10/05/2020 Paul.  Clear needs to set value to text unless it is an array. 
			if ( Math.abs(FORMAT_ROWS) > 0 )
			{
				let lstSelected: any = [];
				lstSelected.push('');
				this.DATA_VALUE = lstSelected;
			}
			else
			{
				this.DATA_VALUE = '';
			}
		}
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n : C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	ngOnInit()
	{
		const { SplendidCache, Credentials, Security, L10n, Crm_Config } = this;
		let FIELD_INDEX      : number    = 0;
		let DATA_FIELD       : string    = '';
		let DATA_LABEL       : string    = '';
		let DATA_VALUE       : any       = null;
		let BIT_VALUES       : boolean[] = [];
		let DATA_FORMAT      : string    = '';
		let LIST_NAME        : string    = '';
		let PARENT_FIELD     : string    = '';
		let UI_REQUIRED      : boolean   = false;
		let FORMAT_TAB_INDEX : number    = 0;
		let FORMAT_ROWS      : number    = 0;
		let ONCLICK_SCRIPT   : string    = '';
		let lstOptions       : any[]     = [];
		let lstSelected      : any       = null;
		let ENABLED          : boolean   = this.bIsWriteable;

		let ID: string = null;
		try
		{
		const { baseId, layout, row, onChanged } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX     );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD      );
				DATA_LABEL        = Sql.ToString (layout.DATA_LABEL      );
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT     );
				LIST_NAME         = Sql.ToString (layout.LIST_NAME       );
				PARENT_FIELD      = Sql.ToString (layout.PARENT_FIELD    );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED     ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX);
				FORMAT_ROWS       = Sql.ToInteger(layout.FORMAT_ROWS     );
				ONCLICK_SCRIPT    = Sql.ToString (layout.ONCLICK_SCRIPT  );
				ID = baseId + '_' + DATA_FIELD;
				// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
				if ( UI_REQUIRED || Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('force') >= 0 )
				{
					UI_REQUIRED = true;
				}

				// 12/13/2013 Paul.  Allow each product to have a default tax rate. 
				if ( DATA_FIELD == 'TAX_CLASS' )
				{
					// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
					// 07/22/2019 Paul.  Using Crm_Config.ToBoolean() was causing an import problem.  Just go direct. 
					let bEnableTaxLineItems: boolean = Sql.ToBoolean(SplendidCache.Config('Orders.TaxLineItems'));
					if ( bEnableTaxLineItems )
					{
						DATA_LABEL = "ProductTemplates.LBL_TAXRATE_ID";
						DATA_FIELD = "TAXRATE_ID";
						LIST_NAME  = "TaxRates";
					}
				}

				// 09/27/2012 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
				if ( !Sql.IsEmptyString(PARENT_FIELD) )
				{
					// 08/10/2019 Paul.  Establish the dependency, but then get the parent list if record is available. 
					this.createDependency.emit({DATA_FIELD, PARENT_FIELD, PROPERTY_NAME: 'list'});
					if ( row && Sql.IsEmptyString(LIST_NAME) )
					{
						LIST_NAME = Sql.ToString(row[PARENT_FIELD]);
					}
				}
				if ( !Sql.IsEmptyString(LIST_NAME) )
				{
					let objValue: any = this.getValues(layout, row, LIST_NAME);
					DATA_VALUE  = objValue.DATA_VALUE ;
					BIT_VALUES  = objValue.BIT_VALUES ;
					lstOptions  = objValue.lstOptions ;
					lstSelected = objValue.lstSelected;
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, lstSelected, row);
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID               = ID              ;
		this.FIELD_INDEX      = FIELD_INDEX     ;
		this.DATA_FIELD       = DATA_FIELD      ;
		this.DATA_VALUE       = lstSelected     ;
		this.BIT_VALUES       = BIT_VALUES      ; 
		this.LIST_NAME        = LIST_NAME       ;
		this.LIST_VALUES      = lstOptions      ;
		this.DATA_FORMAT      = DATA_FORMAT     ;
		this.PARENT_FIELD     = PARENT_FIELD    ;
		this.UI_REQUIRED      = UI_REQUIRED     ;
		this.FORMAT_TAB_INDEX = FORMAT_TAB_INDEX;
		this.FORMAT_ROWS      = FORMAT_ROWS     ;
		this.ONCLICK_SCRIPT   = ONCLICK_SCRIPT  ;
		this.VALUE_MISSING    = false           ;
		this.ENABLED          = ENABLED         ;
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

	private getValues(layout: any, row: any, LIST_NAME: string): any
	{
		const { Credentials, L10n } = this;
		let DATA_VALUE       : any       = null;
		let BIT_VALUES       : boolean[] = [];
		let lstOptions       : any[]     = [];
		let lstSelected      : any       = null;

		let DATA_FIELD       : string  = Sql.ToString (layout.DATA_FIELD      );
		let DATA_FORMAT      : string  = Sql.ToString (layout.DATA_FORMAT     );
		let FORMAT_ROWS      : number  = Sql.ToInteger(layout.FORMAT_ROWS     );
		let UI_REQUIRED      : boolean = Sql.ToBoolean(layout.UI_REQUIRED     ) || Sql.ToBoolean(layout.DATA_REQUIRED);

		let arrLIST: string[] = L10n.GetList(LIST_NAME);
		if ( arrLIST != null )
		{
			if ( row )
			{
				// 06/14/2018 Paul.  Sql.ToString will not convert an array to a string, so it is safe to use Array.isArray() below. 
				DATA_VALUE = row[DATA_FIELD];
				// 03/27/2019 Paul.  Lets not use Sql.ToString in case the behavior changes in the future. 
				// 08/19/2019 Paul.  We don't want to initialize the data value as it will cause a blank item at the bottom of the list. 
				//if ( DATA_VALUE === undefined || DATA_VALUE == null )
				//{
				//	DATA_VALUE = '';
				//}
				// 06/14/2018 Paul.  Special case where dashboard search needs to allow none. 
				// 06/14/2020 Paul.  0 was being treated as false, so explicitly test for undefined or null. 
				if ( !(DATA_VALUE === undefined || DATA_VALUE == null) )
				{
					if ( Array.isArray(DATA_VALUE) )
					{
						if ( DATA_VALUE.length >= 1 )
						{
							// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
							if ( DATA_VALUE[0] === '' )
							{
								DATA_FORMAT = 'force';
								FORMAT_ROWS = -1 * Math.abs(FORMAT_ROWS);
							}
						}
					}
				}
			}
			// 05/06/2022 Paul.  Set the default value for Currencies. 
			if ( LIST_NAME == 'Currencies' )
			{
				if ( !(row && row[DATA_FIELD] !== undefined) )
				{
					DATA_VALUE = Credentials.sUSER_CURRENCY_ID;
				}
			}
			for ( let i = 0; i < arrLIST.length; i++ )
			{
				BIT_VALUES.push(false);
			}
			// 04/23/2017 Paul.  We don't need a NONE record when using multi-selection. 
			// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
			if ( (!UI_REQUIRED || Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('force') >= 0) && FORMAT_ROWS <= 0 )
			{
				// 01/08/2018 Paul.  Some lists have the first entry as a blank. 
				if ( !(arrLIST.length > 0 && Sql.IsEmptyString(arrLIST[0])) )
				{
					let opt3 = { value: '', label: L10n.Term('.LBL_NONE') };
					lstOptions.push(opt3);
					BIT_VALUES.push(false);
					// 06/14/2020 Paul.  0 was being treated as false, so explicitly test for undefined or null. 
					if ( !(DATA_VALUE === undefined || DATA_VALUE == null) )
					{
						if ( Array.isArray(DATA_VALUE) )
						{
							if ( DATA_VALUE.length >= 1 )
							{
								// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
								if ( DATA_VALUE[0] === '' )
								{
									BIT_VALUES[0] = true;
									if ( Math.abs(FORMAT_ROWS) > 0 )
									{
										lstSelected = [];
										lstSelected.push('');
									}
									else
									{
										lstSelected = '';
									}
								}
							}
						}
						// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
						else if ( DATA_VALUE != null && DATA_VALUE === '' )
						{
							BIT_VALUES[0] = true;
							if ( Math.abs(FORMAT_ROWS) > 0 )
							{
								lstSelected = [];
								lstSelected.push('');
							}
							else
							{
								lstSelected = '';
							}
						}
					}
				}
			}
			for ( let i = 0; i < arrLIST.length; i++ )
			{
				let opt4 = { value: arrLIST[i], label: L10n.ListTerm(LIST_NAME, arrLIST[i]) };
				lstOptions.push(opt4);
			}
			// 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
			if ( Math.abs(FORMAT_ROWS) > 0 )
			{
				lstSelected = [];
				// 06/14/2020 Paul.  0 was being treated as false, so explicitly test for undefined or null. 
				if ( !(DATA_VALUE === undefined || DATA_VALUE == null) )
				{
					if ( Array.isArray(DATA_VALUE) )
					{
						let DATA_VALUES = DATA_VALUE;
						for ( let i = 0; i < arrLIST.length; i++ )
						{
							for ( let j = 0; j < DATA_VALUES.length; j++ )
							{
								// 11/10/2020 Paul.  Just in case the value is a number, we need to treat as a string. 
								// This will prevent 1/0 of yes/no from causing 1 to be added to the list because 1 != '1'. 
								if ( DATA_VALUES[j] != null && Sql.ToString(DATA_VALUES[j]) == arrLIST[i] )
								{
									BIT_VALUES[j] = true;
									lstSelected.push(arrLIST[i])
									break;
								}
							}
						}
						// 03/27/2019 Paul.  If record has value and array does not contain a match, then add the value to the list. 
						for ( let j = 0; j < DATA_VALUES.length; j++ )
						{
							// 11/11/2020 Paul.  Just in case the value is a number, we need to treat as a string. 
							if ( DATA_VALUES[j] != null && lstSelected.indexOf(Sql.ToString(DATA_VALUES[j])) < 0 )
							{
								let optMissing = { value: DATA_VALUES[j], label: DATA_VALUES[j] };
								lstOptions.push(optMissing);
								BIT_VALUES.push(true);
								lstSelected.push(DATA_VALUES[j]);
							}
						}
					}
					// 08/01/2013 Paul.  Expand XML values from CheckBoxList. 
					// 08/17/2019 Paul.  Process as XML before CSV just in case data in wrong format.  XML easy to detect. 
					else if ( StartsWith(DATA_VALUE, '<?xml') )
					{
						const parser = new XMLParser();
						let xml: any = parser.parse(DATA_VALUE);
						if ( xml.Values && xml.Values.Value && Array.isArray(xml.Values.Value) )
						{
							let DATA_VALUES: string[] = xml.Values.Value;
							for ( let i = 0; i < arrLIST.length; i++ )
							{
								for ( let j = 0; j < DATA_VALUES.length; j++ )
								{
									// 11/10/2020 Paul.  No need to convert to string here as we know xml is already string based. 
									if ( DATA_VALUES[j] != null && DATA_VALUES[j] == arrLIST[i] )
									{
										BIT_VALUES[j] = true;
										lstSelected.push(arrLIST[i])
										break;
									}
								}
							}
							// 03/27/2019 Paul.  If record has value and array does not contain a match, then add the value to the list. 
							for ( let j = 0; j < DATA_VALUES.length; j++ )
							{
								if ( DATA_VALUES[j] != null && lstSelected.indexOf(DATA_VALUES[j]) < 0 )
								{
									let optMissing = { value: DATA_VALUES[j], label: DATA_VALUES[j] };
									lstOptions.push(optMissing);
									BIT_VALUES.push(true);
									lstSelected.push(DATA_VALUES[j]);
								}
							}
						}
					}
					else if ( Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('csv') >= 0 )
					{
						let DATA_VALUES: any[] = [];
						if ( DATA_VALUE != null )
						{
							DATA_VALUES = DATA_VALUE.split(',');
						}
						for ( let i = 0; i < arrLIST.length; i++ )
						{
							for ( let j = 0; j < DATA_VALUES.length; j++ )
							{
								// 11/10/2020 Paul.  No need to convert to string here as we know csv is already string based. 
								if ( DATA_VALUES[j] != null && DATA_VALUES[j] == arrLIST[i] )
								{
									BIT_VALUES[j] = true;
									lstSelected.push(arrLIST[i])
									break;
								}
							}
						}
						// 03/27/2019 Paul.  If record has value and array does not contain a match, then add the value to the list. 
						for ( let j = 0; j < DATA_VALUES.length; j++ )
						{
							if ( DATA_VALUES[j] != null && lstSelected.indexOf(DATA_VALUES[j]) < 0 )
							{
								let optMissing = { value: DATA_VALUES[j], label: DATA_VALUES[j] };
								lstOptions.push(optMissing);
								BIT_VALUES.push(true);
								lstSelected.push(DATA_VALUES[j]);
							}
						}
						//var sALL_SELECTED = L10n.Term(".LBL_ALL_SELECTED");
						//var sCOUNT_SELECTED = L10n.Term(".LBL_COUNT_SELECTED");
						// 05/16/2018 Paul.  Defer multi select. 
						//$(lst).multipleSelect({selectAll: false, width: '100%', minimumCountSelected: 10, allSelected: sALL_SELECTED, countSelected: sCOUNT_SELECTED });
					}
					else
					{
						// 11/10/2020 Paul.  Just in case the value is a number, we need to treat as a string. 
						// This will prevent 1/0 of yes/no from causing 1 to be added to the list because 1 != '1'. 
						if ( typeof(DATA_VALUE) == 'number' )
						{
							DATA_VALUE = Sql.ToString(DATA_VALUE);
						}
						for ( let i = 0; i < arrLIST.length; i++ )
						{
							// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
							if ( DATA_VALUE != null && DATA_VALUE == arrLIST[i] )
							{
								BIT_VALUES[i] = true;
								lstSelected.push(arrLIST[i]);
							}
						}
						// 03/27/2019 Paul.  If record has value and array does not contain a match, then add the value to the list. 
						if ( DATA_VALUE != null && lstSelected.indexOf(DATA_VALUE) < 0 )
						{
							let optMissing = { value: DATA_VALUE, label: DATA_VALUE };
							lstOptions.push(optMissing);
							BIT_VALUES.push(true);
							lstSelected.push(DATA_VALUE);
						}
					}
				}
			}
			else
			{
				lstSelected = null;
				// 06/14/2020 Paul.  0 was being treated as false, so explicitly test for undefined or null. 
				if ( !(DATA_VALUE === undefined || DATA_VALUE == null) )
				{
					for ( let i = 0; i < arrLIST.length; i++ )
					{
						// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
						if ( DATA_VALUE != null && DATA_VALUE == arrLIST[i] )
						{
							lstSelected = arrLIST[i];
						}
					}
					// 03/27/2019 Paul.  If record has value and array does not contain a match, then add the value to the list. 
					if ( DATA_VALUE != null && lstSelected == null )
					{
						let optMissing = { value: DATA_VALUE, label: DATA_VALUE };
						lstOptions.push(optMissing);
						BIT_VALUES.push(true);
						lstSelected = DATA_VALUE;
					}
				}
			}
			// 06/19/2018 Paul.  The first item needs to be selected by default, unless multi-select is used. 
			if ( row == null && lstSelected != null && lstSelected.length == 0 && lstOptions.length > 0 && Math.abs(FORMAT_ROWS) == 0 )
			{
				BIT_VALUES[0] = true;
				lstSelected.push(lstOptions[0]);
			}
		}
		// 06/19/2018 Paul.  DATA_VALUE must be a scalar if list is not multiple. 
		// 03/20/2019 Paul.  lstSelected may have been already been assigned a scalar. 
		if ( Math.abs(FORMAT_ROWS) == 0 && Array.isArray(lstSelected) )
		{
			if ( lstSelected != null && lstSelected.length > 0 )
			{
				lstSelected = lstSelected[0];
			}
			else
			{
				lstSelected = null;
			}
		}
		// 03/27/2019 Paul.  If list is multiselect, then make sure that selected is an array. 
		else if ( Math.abs(FORMAT_ROWS) != 0 && !Array.isArray(lstSelected) )
		{
			if ( !Sql.IsEmptyString(lstSelected) )
			{
				let s = lstSelected;
				lstSelected = [];
				lstSelected.push(s);
			}
			else
			{
				lstSelected = [];
			}
		}
		// 03/30/2019 Paul.  `value` prop on `select` should not be null. Consider using an empty string to clear the component or `undefined` for uncontrolled components.
		if ( lstSelected == null )
		{
			lstSelected = undefined;
			// 03/30/2019 Paul.  If row is null and single selection, then this might be a SearchView that needs the default value set. 
			// 02/10/2020 Paul.  Some new records will have initial values, so row == null is not sufficient.  We need to check if field value is undefined. 
			// 10/12/2020 Paul.  List Value may be undefined or null. 
			if ( (row == null || row[DATA_FIELD] === undefined || row[DATA_FIELD] == null) && Math.abs(FORMAT_ROWS) == 0 && lstOptions != null && lstOptions.length > 0 )
			{
				lstSelected = lstOptions[0].value;
				// 04/21/2019 Paul.  We only need to initialize if there is a value. 
				// 01/26/2020 Paul.  The lstSelected value is used when initializing the list box. 
				if ( !Sql.IsEmptyString(lstSelected) )
				{
					this.onChanged.emit({DATA_FIELD, DATA_VALUE: lstSelected});
				}
				else
				{
					// 02/10/2020 Paul.  We perfer to return null if nothing selected, instead of empty string. 
					lstSelected = null
				}
			}
		}
		let objValue: any = { DATA_VALUE, BIT_VALUES, lstOptions, lstSelected};
		return objValue;
	}

	public _onSelectChange(event: any)
	{
		const { DATA_FIELD, BIT_VALUES, FORMAT_ROWS, ENABLED } = this;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectChange ' + DATA_FIELD, event);
		try
	{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				if ( Math.abs(FORMAT_ROWS) > 0 )
				{
					// 09/09/2019 Paul.  We need to modify a copy so that the shouldUpdate will fire. 
					let NEW_BIT_VALUES = BIT_VALUES.slice();
					let index = event.target.selectedIndex;
					let DATA_VALUE = null;
					let selectedOptions = event.target.selectedOptions;
					for (let i = 0; i < NEW_BIT_VALUES.length; i++)
					{
						NEW_BIT_VALUES[i] = false;
					}
					let lstSelected: any = [];
					for (let i = 0; i < selectedOptions.length; i++)
					{
						NEW_BIT_VALUES[selectedOptions[i].index] = true;
						lstSelected.push(selectedOptions[i].value);
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectChange ' + DATA_FIELD, lstSelected);
					this.DATA_VALUE = lstSelected;
					this.BIT_VALUES = NEW_BIT_VALUES;
					this.validate();
					this.onChanged.emit({DATA_FIELD  : DATA_FIELD, DATA_VALUE: lstSelected});
					this.onUpdate .emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE: lstSelected});
				}
				else
				{
					let value = event.target.value;
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
					this.DATA_VALUE = value;
					this.validate();
					this.onChanged.emit({DATA_FIELD  : DATA_FIELD, DATA_VALUE: value});
					this.onUpdate .emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE: value});
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectChange', error);
		}
	}

	public _onMultiSelectChange(event: any) // {selectedOption: any[], action: string}
	{
		const { baseId, layout, row, onChanged, onUpdate } = this;
		const { DATA_FIELD, ENABLED } = this;
		const { selectedOption, action} = event;
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMultiSelectChange ' + DATA_FIELD, event);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				// 09/09/2019 Paul.  We need to modify a copy so that the shouldUpdate will fire. 
				let lstSelected: any = [];
				if ( selectedOption != null )
				{
					for (let i = 0; i < selectedOption.length; i++)
					{
						lstSelected.push(selectedOption[i].value);
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMultiSelectChange ' + DATA_FIELD, lstSelected);
				this.DATA_VALUE = lstSelected;
				this.validate();
				this.onChanged.emit({DATA_FIELD  : DATA_FIELD, DATA_VALUE: lstSelected});
				this.onUpdate .emit({PARENT_FIELD: DATA_FIELD, DATA_VALUE: lstSelected});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onMultiSelectChange', error);
		}
	}

}
