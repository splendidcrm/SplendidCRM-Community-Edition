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
import { StartsWith, EndsWith                                      } from '../scripts/utility'           ;
import { DetailViewComponentBase                                   } from '../DetailComponents/DetailViewComponentBase';

@Component({
	selector: 'DetailViewString',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout prop is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyRow()">
		<span>row is null for DATA_FIELD {{ DATA_FIELD }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsErased()">
		<span class="Erased">{{ L10n.Term('DataPrivacy.LBL_ERASED_VALUE') }}</span>
	</ng-container>
	<ng-container *ngIf="!IsErased() && IsVisible() && html">
		<div [innerHTML]="DATA_VALUE"></div>
	</ng-container>
	<ng-container *ngIf="!IsErased() && IsVisible() && !html">
		<ng-container *ngIf="!IsArray(DISPLAY_NAME)">
			<span [id]="ID" [class]="CSS_CLASS">{{ DISPLAY_NAME }}</span>
		</ng-container>
		<ng-container *ngIf="IsArray(DISPLAY_NAME)">
			<span [id]="ID" [class]="CSS_CLASS">
				<ng-container *ngFor="let line of DISPLAY_NAME">
					<div>{{ line.children }}</div>
				</ng-container>
			</span>
		</ng-container>
	</ng-container>`
})
export class DetailViewStringComponent extends DetailViewComponentBase implements OnInit
{
	public MODULE_TYPE : string  = null;
	public DISPLAY_NAME: any     = null;
	public ERASED      : boolean = null;
	// 03/29/2021 Paul.  Treat string as html. 
	@Input()  html     : boolean = false;

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		//console.log(this.constructor.name + '.updateDependancy ' + PROPERTY_NAME, DATA_VALUE);
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.DATA_VALUE = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.CSS_CLASS = DATA_VALUE;
		}
		// 03/29/2021 Paul.  Treat string as html. 
		else if ( PROPERTY_NAME == 'html' )
		{
			this.html = DATA_VALUE;
		}
	}

	public IsArray(data: any)
	{
		return Array.isArray(data);
	}

	public IsErased()
	{
		return !this.IsHidden() && this.ERASED;
	}

	constructor(public router: Router, public SplendidCache : SplendidCacheService, public Credentials : CredentialsService, public Security : SecurityService, public L10n : L10nService, public C10n : C10nService, public Crm_Config : CrmConfigService, public Crm_Modules : CrmModulesService, public Formatting: FormattingService)
	{
		super(router, SplendidCache, Credentials, Security, L10n, Crm_Config, Crm_Modules);
	}

	ngOnInit()
	{
		const { SplendidCache, Credentials, Security, L10n, Crm_Config } = this;
		let FIELD_INDEX      : number  = 0;
		let FIELD_TYPE       : string  = '';
		let DATA_FIELD       : string  = '';
		let DATA_LABEL       : string  = '';
		let DATA_VALUE       : string  = '';
		let DATA_FORMAT      : string  = '';
		let LIST_NAME        : string  = '';
		let MODULE_TYPE      : string  = '';
		let DISPLAY_NAME     : any     = null;
		let ERASED           : boolean = false;
		let html             : boolean = this.html;

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				// 10/14/2021 Paul.  FIELD_TYPE should be a string, not an integer. 
				FIELD_TYPE        = Sql.ToString (layout.FIELD_TYPE );
				DATA_LABEL        = Sql.ToString (layout.DATA_LABEL );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT);
				LIST_NAME         = Sql.ToString (layout.LIST_NAME  );
				MODULE_TYPE       = Sql.ToString (layout.MODULE_TYPE);
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				let oNumberFormat = Security.NumberFormatInfo();
				if ( row != null )
				{
					// 08/08/2019 Paul.  Correct for the team configuration. 
					if ( (DATA_FIELD == 'TEAM_NAME' || DATA_FIELD == 'TEAM_SET_NAME') )
					{
						let bEnableTeamManagement = Crm_Config.enable_team_management();
						let bEnableDynamicTeams   = Crm_Config.enable_dynamic_teams();
						if ( !bEnableTeamManagement )
						{
							FIELD_TYPE = 'Blank';
						}
						else if ( bEnableDynamicTeams )
						{
							// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
							// 04/03/2021 Paul.  Apply single rule. 
							if ( DATA_FORMAT != '1' && DATA_FORMAT.toLowerCase().indexOf('single') < 0 )
							{
								DATA_LABEL = '.LBL_TEAM_SET_NAME';
								DATA_FIELD = 'TEAM_SET_NAME'     ;
							}
							else
							{
								DATA_LABEL = '.LBL_TEAM_NAME';
								DATA_FIELD = 'TEAM_NAME'     ;
							}
						}
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					// 04/03/2021 Paul.  Dynamic Assignment must be managed here as well as in SplendidGrid. 
					else if ( DATA_FIELD == "ASSIGNED_TO" || DATA_FIELD == "ASSIGNED_TO_NAME" || DATA_FIELD == "ASSIGNED_SET_NAME" )
					{
						// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						let bEnableDynamicAssignment = Crm_Config.enable_dynamic_assignment();
						if ( bEnableDynamicAssignment && DATA_FORMAT.toLowerCase().indexOf('single') < 0 )
						{
							DATA_LABEL = '.LBL_LIST_ASSIGNED_SET_NAME';
							DATA_FIELD = 'ASSIGNED_SET_NAME';
						}
						else if ( DATA_FIELD == "ASSIGNED_SET_NAME" )
						{
							DATA_LABEL = '.LBL_LIST_ASSIGNED_USER';
							DATA_FIELD = 'ASSIGNED_TO_NAME';
						}
					}
					// 12/13/2013 Paul.  Allow each product to have a default tax rate. 
					else if ( DATA_FIELD == 'TAX_CLASS' )
					{
						let bEnableTaxLineItems = Crm_Config.ToBoolean('Orders.TaxLineItems');
						if ( bEnableTaxLineItems )
						{
							// 08/28/2009 Paul.  If dynamic teams are enabled, then always use the set name. 
							DATA_LABEL = 'ProductTemplates.LBL_TAXRATE_ID';
							DATA_FIELD = 'TAXRATE_ID';
							LIST_NAME  = 'TaxRates';
						}
					}
					// 03/03/2021 Paul.  DATA_FORMAT will not be null because of Sql.ToString() use above. 
					if ( Sql.IsEmptyString(DATA_FORMAT) )
					{
						// 01/09/2006 Paul.  Allow DATA_FORMAT to be optional.   If missing, write data directly. 
						DISPLAY_NAME = '';
						let arrDATA_FIELD = DATA_FIELD.split(' ');
						for ( let nFormatIndex = 0; nFormatIndex < arrDATA_FIELD.length; nFormatIndex++ )
						{
							DATA_VALUE = Sql.ToString(row[arrDATA_FIELD[nFormatIndex]]);
							if ( !Sql.IsEmptyString(DISPLAY_NAME) )
								DISPLAY_NAME += ' ';
							DISPLAY_NAME += DATA_VALUE;
						}
					}
					else
					{
						DATA_VALUE   = Sql.ToString(row[DATA_FIELD]);
						DISPLAY_NAME = DATA_VALUE;
						try
						{
							// 02/25/2016 Paul.  Fix bug.  Check for multiple data fields not format entries. 
							if ( DATA_FIELD.indexOf(' ') > 0 )
							{
								//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, row);
								let bPARTIAL_ERASED: boolean = false;
								let arrDATA_FIELD = DATA_FIELD.split(' ');
								for ( let nFormatIndex = 0; nFormatIndex < arrDATA_FIELD.length; nFormatIndex++ )
								{
									if ( arrDATA_FIELD[nFormatIndex].indexOf('.') >= 0 )
									{
										DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', L10n.Term(arrDATA_FIELD[nFormatIndex]));
									}
									else
									{
										//console.log((new Date()).toISOString() + ' ' + arrDATA_FIELD[nFormatIndex] + ' ' + row[arrDATA_FIELD[nFormatIndex]]);
										if ( row[arrDATA_FIELD[nFormatIndex]] == null )
										{
											// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
											if ( this.ERASED_FIELDS && this.ERASED_FIELDS.length > 0 && this.ERASED_FIELDS.indexOf(arrDATA_FIELD[nFormatIndex]) >= 0 )
											{
												DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', Sql.DataPrivacyErasedPill(L10n));
												bPARTIAL_ERASED = true;
												// 06/06/2022 Paul.  Pill needs to be treated as html. 
												this.html = true;
											}
											else if (arrDATA_FIELD[nFormatIndex] == 'PICTURE')
											{
												DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', Credentials.RemoteServer + 'App_Themes/Six/images/ActivityStreamUser.gif');
												this.html = true;
											}
											else
											{
												DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', '');
											}
										}
										else
										{
											DATA_VALUE = row[arrDATA_FIELD[nFormatIndex]];
											//console.log((new Date()).toISOString() + ' ' + nFormatIndex + ', ' + arrDATA_FIELD[nFormatIndex] + ': ' + DATA_VALUE);
											//DATA_VALUE = FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
											//DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', DATA_VALUE);
											// 03/19/2016 Paul.  Handle currency and date formatting. 
											if ( DATA_FORMAT.indexOf('{' + nFormatIndex.toString() + ':d}') >= 0 )
											{
												DATA_VALUE  = this.Formatting.FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT());
												DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + ':d}', DATA_VALUE);
											}
											else if ( DATA_FORMAT.indexOf('{' + nFormatIndex.toString() + ':c}') >= 0 )
											{
												//console.log((new Date()).toISOString() + ' ' + DATA_VALUE + ' = ' + formatCurrency(DATA_VALUE, oNumberFormat));
												// 10/16/2021 Paul.  Add support for user currency. 
												let dConvertedValue = this.C10n.ToCurrency(Sql.ToDecimal(DATA_VALUE));
												DATA_VALUE  = this.Formatting.formatCurrency(dConvertedValue, oNumberFormat);
												DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + ':c}', DATA_VALUE);
											}
											else if ( DATA_FORMAT.indexOf('{' + nFormatIndex.toString() + ';') >= 0 )
											{
												let nStartListName = DATA_FORMAT.indexOf('{' + nFormatIndex.toString() + ';');
												if (  nStartListName > 0 )
												{
													let nEndListName = DATA_FORMAT.indexOf('}', nStartListName);
													if ( nEndListName > nStartListName )
													{
														let sPLACEHOLDER = DATA_FORMAT.substring(nStartListName, nEndListName + 1);
														//console.log((new Date()).toISOString() + ' ' + sPLACEHOLDER);
														LIST_NAME   = DATA_FORMAT.substring(nStartListName + ('{' + nFormatIndex.toString() + ';').length, nEndListName);
														DATA_VALUE  = L10n.ListTerm(LIST_NAME, DATA_VALUE);
														DATA_FORMAT = DATA_FORMAT.replace(sPLACEHOLDER, DATA_VALUE);
													}
												}
											}
											// 10/03/2011 Paul.  If the data value is an integer, then substr() will throw an exception. 
											else if ( typeof (DATA_VALUE) == 'string' && DATA_VALUE.substr(0, 7) === '\\/Date(' )
											{
												//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor() Date', DATA_VALUE);
												DATA_VALUE = this.Formatting.FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
												DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', DATA_VALUE);
											}
											// 06/30/2020 Paul.  If moment object, then format as date. 
											// http://momentjs.com/docs/#/displaying/as-javascript-date/
											else if ( typeof (row[arrDATA_FIELD[nFormatIndex]]) == 'object' && (row[arrDATA_FIELD[nFormatIndex]] instanceof Date || row[arrDATA_FIELD[nFormatIndex]]._isAMomentObject) )
											{
												DATA_VALUE   = this.Formatting.FromJsonDate(row[arrDATA_FIELD[nFormatIndex]], Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
												DISPLAY_NAME = DATA_FORMAT.replace('{0}', DATA_VALUE);
											}
											else
											{
												DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', DATA_VALUE);
											}
										}
									}
								}
								// 12/24/2012 Paul.  Use regex global replace flag. 
								// 05/14/2018 Paul.  id is set when created. 
								//tdField.id = 'ctlDetailView_' + DATA_FIELD.replace(/\s/g, '_');
								// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
								DISPLAY_NAME = Sql.ReplaceEntities(DATA_FORMAT);
								// 09/09/2019 Paul.  We need to convert a partially erased field into react components. 
								if ( bPARTIAL_ERASED )
								{
									let arrNEW_NAME: any[] = [];
									let sPill: string = Sql.DataPrivacyErasedPill(L10n);
									let nStartIndex: number = 0;
									let nPillIndex: number = DISPLAY_NAME.indexOf(sPill, nStartIndex);
									while ( nPillIndex >= 0 )
									{
										let s = DISPLAY_NAME.substring(nStartIndex, nPillIndex);
										arrNEW_NAME.push(s);
										arrNEW_NAME.push('<span class="Erased">' + L10n.Term('DataPrivacy.LBL_ERASED_VALUE') + '</span>');
										nStartIndex = nPillIndex + sPill.length;
										nPillIndex = DISPLAY_NAME.indexOf(sPill, nStartIndex);
									}
									if ( nStartIndex < DISPLAY_NAME.length )
									{
										let s = DISPLAY_NAME.substring(nStartIndex);
										arrNEW_NAME.push(s);
									}
									DISPLAY_NAME = arrNEW_NAME;
								}
							}
							else if ( row[DATA_FIELD] != null )
							{
								// 12/24/2012 Paul.  Use regex global replace flag. 
								// 05/14/2018 Paul.  id is set when created. 
								//tdField.id = 'ctlDetailView_' + DATA_FIELD.replace(/\s/g, '_');
								if ( !Sql.IsEmptyString(LIST_NAME) )
								{
									DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
									// 08/01/2013 Paul.  Expand XML values from CheckBoxList. 
									if ( StartsWith(DATA_VALUE, '<?xml') )
									{
										let sVALUES = '';
										// 05/14/2018 Paul.  Defer parsing of xml. 
										/*
										let xmlVALUES = $.parseXML(DATA_VALUE);
										$(xmlVALUES).find('Value').each(function()
										{
											if ( sVALUES.length > 0 )
												sVALUES += ', ';
											sVALUES += L10n.ListTerm(LIST_NAME, $(this).text());
										});
										*/
										// 11/24/2019 Paul.  New xml parsing method.
										const parser = new XMLParser();
										let xml: any = parser.parse(DATA_VALUE);
										if ( xml.Values && xml.Values.Value && Array.isArray(xml.Values.Value) )
										{
											let xmlVALUES: string[] = xml.Values.Value;
											for ( let i = 0; i < xmlVALUES.length; i++ )
											{
												if ( sVALUES.length > 0 )
													sVALUES += ', ';
												sVALUES += L10n.ListTerm(LIST_NAME, xmlVALUES[i]);
											}
										}
										DATA_VALUE = sVALUES;
									}
									else
									{
										// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
										DATA_VALUE = L10n.ListTerm(LIST_NAME, DATA_VALUE);
									}
									// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
									DISPLAY_NAME = Sql.ReplaceEntities(DATA_FORMAT.replace('{0}', DATA_VALUE));
								}
								else
								{
									DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
									try
									{
										// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
										// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
										if ( DATA_VALUE === '' && this.ERASED_FIELDS.length > 0 && this.ERASED_FIELDS.indexOf(DATA_FIELD) >= 0 )
										{
											ERASED = true;
										}
										else if ( DATA_FORMAT.indexOf('{0:d}') >= 0 )
										{
											// 07/31/2020 Paul.  Use row[DATA_FIELD] instead of DATA_VALUE as we want to have access to a moment object. 
											DATA_VALUE   = this.Formatting.FromJsonDate(row[DATA_FIELD], Security.USER_DATE_FORMAT());
											DISPLAY_NAME = DATA_FORMAT.replace('{0:d}', DATA_VALUE);
											// 09/09/2019 Paul.  An empty date value will be "\/Date(-62135596800000)\/" before we convert to a date. 
											// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
											if ( DATA_VALUE === '' && this.ERASED_FIELDS.length > 0 && this.ERASED_FIELDS.indexOf(DATA_FIELD) >= 0 )
											{
												ERASED = true;
											}
										}
										else if ( DATA_FORMAT.indexOf('{0:c}') >= 0 )
										{
											//console.log((new Date()).toISOString() + ' ' + DATA_VALUE + ' = ' + formatCurrency(DATA_VALUE, oNumberFormat));
											// 03/30/2007 Paul.  Convert DetailView currencies on the fly. 
											// 05/05/2007 Paul.  In an earlier step, we convert NULLs to empty strings. 
											// Attempts to convert to decimal will generate an error: Input string was not in a correct format.
											// 04/19/2020 Paul.  Null value is no longer converted to an empty string. 
											// 10/16/2021 Paul.  Add support for user currency. 
											let dConvertedValue = this.C10n.ToCurrency(Sql.ToDecimal(DATA_VALUE));
											DATA_VALUE   = this.Formatting.formatCurrency(dConvertedValue, oNumberFormat);
											DISPLAY_NAME = DATA_FORMAT.replace('{0:c}', DATA_VALUE);
										}
										// 03/19/2019 Paul.  Add support for floating point numbers. 
										else if ( DATA_FORMAT.indexOf('{0:f') >= 0 )
										{
											let nStartListName = DATA_FORMAT.indexOf('{0:f');
											if ( nStartListName >= 0 )
											{
												let nEndListName = DATA_FORMAT.indexOf('}', nStartListName);
												if ( nEndListName > nStartListName )
												{
													let sPLACEHOLDER = DATA_FORMAT.substring(nStartListName, nEndListName + 1);
													try
													{
													// 10/11/2020 Paul.  .NET defaults to 2 digit float. 
														let nFixed: number = 2;
														if ( DATA_FORMAT != '{0:f}' )
															nFixed= parseInt(DATA_FORMAT.substring(nStartListName + ('{0:f').length, nEndListName));
														if ( DATA_VALUE != null )
														{
															// 03/19/2019 Paul.  Typescript is having trouble treating the toFixed result as a string if assigned back to DATA_VALUE. 
															let s: string = parseFloat(DATA_VALUE).toFixed(nFixed);
															DISPLAY_NAME = DATA_FORMAT.replace(sPLACEHOLDER, s);
														}
													}
													catch(error: any)
													{
														DISPLAY_NAME = DATA_FORMAT.replace(sPLACEHOLDER, error.message);
													}
												}
											}
										}
										// 03/19/2019 Paul.  Add support for floating point numbers. 
										else if ( DATA_FORMAT.indexOf('{0:F') >= 0 )
										{
											let nStartListName = DATA_FORMAT.indexOf('{0:F');
											if ( nStartListName >= 0 )
											{
												let nEndListName = DATA_FORMAT.indexOf('}', nStartListName);
												if ( nEndListName > nStartListName )
												{
													let sPLACEHOLDER = DATA_FORMAT.substring(nStartListName, nEndListName + 1);
													try
													{
														let nFixed: number = parseInt(DATA_FORMAT.substring(nStartListName + ('{0:F').length, nEndListName));
														if ( DATA_VALUE != null )
														{
															// 03/19/2019 Paul.  Typescript is having trouble treating the toFixed result as a string if assigned back to DATA_VALUE. 
															let s: string = parseFloat(DATA_VALUE).toFixed(nFixed);
															DISPLAY_NAME = DATA_FORMAT.replace(sPLACEHOLDER, s);
														}
													}
													catch(error: any)
													{
														DISPLAY_NAME = DATA_FORMAT.replace(sPLACEHOLDER, error.message);
													}
												}
											}
										}
										// 10/03/2011 Paul.  If the data value is an integer, then substr() will throw an exception. 
										else if ( typeof (DATA_VALUE) == 'string' && DATA_VALUE.substr(0, 7) == '\\/Date(' )
										{
											DATA_VALUE   = this.Formatting.FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
											DISPLAY_NAME = DATA_FORMAT.replace('{0}', DATA_VALUE);
										}
										// 06/30/2020 Paul.  If moment object, then format as date. 
										// http://momentjs.com/docs/#/displaying/as-javascript-date/
										else if ( typeof (row[DATA_FIELD]) == 'object' && (row[DATA_FIELD] instanceof Date || row[DATA_FIELD]._isAMomentObject) )
										{
											DATA_VALUE   = this.Formatting.FromJsonDate(row[DATA_FIELD], Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
											DISPLAY_NAME = DATA_FORMAT.replace('{0}', DATA_VALUE);
										}
										// 11/30/2012 Paul.  Special formatting for Address HTML fields are normally provided by special _Edit view.
										else if ( DATA_FORMAT == '{0}' && EndsWith(DATA_FIELD, 'ADDRESS_HTML') )
										{
											// 'PRIMARY_ADDRESS_HTML'
											// 'ALT_ADDRESS_HTML'
											// 'BILLING_ADDRESS_HTML'
											// 'SHIPPING_ADDRESS_HTML'
											let ADDRESS_BASE      : string = DATA_FIELD.replace('_HTML', '_');
											let ADDRESS_STREET    : string = Sql.ToString(row[ADDRESS_BASE + 'STREET'    ]);
											let ADDRESS_CITY      : string = Sql.ToString(row[ADDRESS_BASE + 'CITY'      ]);
											let ADDRESS_STATE     : string = Sql.ToString(row[ADDRESS_BASE + 'STATE'     ]);
											let ADDRESS_POSTALCODE: string = Sql.ToString(row[ADDRESS_BASE + 'POSTALCODE']);
											let ADDRESS_COUNTRY   : string = Sql.ToString(row[ADDRESS_BASE + 'COUNTRY'   ]);
											//let sADDRESS_HTML = sADDRESS_STREET + '<br />'
											//	+ sADDRESS_CITY + ' '
											//	+ sADDRESS_STATE + ' &nbsp;&nbsp;'
											//	+ sADDRESS_POSTALCODE + '<br />'
											//	+ sADDRESS_COUNTRY + ' ';
											// 05/28/2018 Paul.  React does not like HTML tags in its text, so build using div elements. 
											DISPLAY_NAME = [];
											DISPLAY_NAME.push({tag: 'div', props: { key: baseId + '_' + DATA_FIELD + '_STREET'  }, children: ADDRESS_STREET });
											DISPLAY_NAME.push({tag: 'div', props: { key: baseId + '_' + DATA_FIELD + '_POSTAL'  }, children: ADDRESS_CITY + ' ' + ADDRESS_STATE + ' \u00a0\u00a0' + ADDRESS_POSTALCODE});
											DISPLAY_NAME.push({tag: 'div', props: { key: baseId + '_' + DATA_FIELD + '_COUNTRY' }, children: ADDRESS_COUNTRY});
										}
										// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
										// 02/16/2010 Paul.  Move ToGuid to the function so that it can be captured if invalid. 
										// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
										else if ( !Sql.IsEmptyString(MODULE_TYPE) )
										{
											// 01/13/2020 Paul.  Due to async requirement, defer to loading after componentDidMount. 
											//DISPLAY_NAME = Crm_Modules.ItemName(MODULE_TYPE, DATA_VALUE);
											if ( DATA_VALUE.length == 36 )
											{
												// 01/13/2020 Paul.  Setting the display name to null is our clue that it needs to be dynamically loaded. 
												DISPLAY_NAME = null;
											}
										}
										// 03/29/2021 Paul.  Treat string as html. 
										else if ( html )
										{
											// 03/29/2021 Paul.  Do not replace entities as string will be raw html. 
											DISPLAY_NAME = DATA_FORMAT.replace('{0}', DATA_VALUE);
										}
										else
										{
											// 08/26/2014 Paul.  Text with angle brackets (such as an email), will generate an error when used with innerHTML. 
											//tdField.innerHTML = DATA_FORMAT.replace('{0}', DATA_VALUE);
											// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
											DISPLAY_NAME = Sql.ReplaceEntities(DATA_FORMAT.replace('{0}', DATA_VALUE));
										}
									}
									catch(error: any)
									{
										console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
									}
								}
							}
							// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
							else if ( this.ERASED_FIELDS.length > 0 && this.ERASED_FIELDS.indexOf(DATA_FIELD) >= 0 )
							{
								ERASED = true;
							}
						}
						catch(error: any)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
							this.DISPLAY_NAME = error.message;
						}
					}
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DISPLAY_NAME, row);
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID           = ID          ;
		this.FIELD_INDEX  = FIELD_INDEX ;
		this.DATA_FIELD   = DATA_FIELD  ;
		this.DATA_VALUE   = DATA_VALUE  ;
		this.MODULE_TYPE  = MODULE_TYPE ;
		this.DISPLAY_NAME = DISPLAY_NAME;
		this.ERASED       = ERASED      ;
		this.html         = html        ;
	}

	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}
}
