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
import { StartsWith, Trim                                          } from '../scripts/utility'           ;
import Sql                                                           from '../scripts/Sql'               ;
import { EditViewComponentBase                                     } from '../EditComponents/EditViewComponentBase';

@Component({
	selector: 'EditViewLabel',
	template: `<ng-container *ngIf="IsEmptyLayout()">
		<span>layout is null</span>
	</ng-container>
	<ng-container *ngIf="IsEmptyField()">
		<span>DATA_FIELD is empty for Label FIELD_INDEX {{ FIELD_INDEX }}</span>
	</ng-container>
	<ng-container *ngIf="IsHidden()">
		<span></span>
	</ng-container>
	<ng-container *ngIf="IsVisible()">
		<ng-container *ngIf="IsURL()">
			<a
				[id]="ID"
				style="margin-left: 4px"
				[class]="CSS_CLASS"
				[href]="sFullURL"
				(click)="_onClick($event)"
			>
				{{ DISPLAY_NAME }}
			</a>
		</ng-container>
		<ng-container *ngIf="IsLabel()">
			<span [id]="ID" style="margin-left: 4px" [class]="CSS_CLASS">
				{{ DISPLAY_NAME }}
			</span>
		</ng-container>
	</ng-container>`
})
export class EditViewLabelComponent extends EditViewComponentBase implements OnInit
{
	public DATA_LABEL             : string   = null;
	public DATA_FORMAT            : string   = null;
	public DISPLAY_NAME           : string   = null;
	public URL                    : string   = null;
	public sFullURL               : string   = null;

	public IsURL(): boolean
	{
		return !Sql.IsEmptyString(this.URL);
	}

	public IsLabel(): boolean
	{
		return Sql.IsEmptyString(this.URL);
	}

	public get data(): any
	{
		return null;
	}

	public validate(): boolean
	{
		return true;
	}

	public clear(): void
	{
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		// 08/09/2019 Paul.  An example of a text update is a Postal Code change updating, City, State and Country. 
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.DATA_VALUE = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'enabled' )
		{
			this.ENABLED = Sql.ToBoolean(DATA_VALUE);
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.CSS_CLASS = DATA_VALUE;
		}
		else if ( PROPERTY_NAME == 'URL' )
		{
			this.URL = DATA_VALUE;
			this.sFullURL = this.URL;
			if ( StartsWith(this.URL, '/Reset/') )
			{
				this.sFullURL = this.URL.replace('/Reset/', this.Credentials.RemoteServer + '/');
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
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let DATA_LABEL       : string  = '';
		let DATA_FORMAT      : string  = '';
		let LIST_NAME        : string  = '';
		let DISPLAY_NAME     : any     = null;
		let CSS_CLASS        : string = 'dataLabel';

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_LABEL        = Sql.ToString (layout.DATA_LABEL );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT);
				LIST_NAME         = Sql.ToString (layout.LIST_NAME  );
				ID = baseId + '_' + layout.FIELD_TYPE + '_' + layout.FIELD_INDEX;

				let oNumberFormat = Security.NumberFormatInfo();
				if ( row == null )
				{
					// 09/28/2020 Paul.  On a new record, we still need to insert the label. 
					if ( DATA_FIELD.indexOf(' ') > 0 )
					{
						DISPLAY_NAME = '';
						let arrDATA_FIELD = DATA_FIELD.split(' ');
						for ( let nFormatIndex = 0; nFormatIndex < arrDATA_FIELD.length; nFormatIndex++ )
						{
							if ( arrDATA_FIELD[nFormatIndex].indexOf('.') >= 0 )
							{
								DISPLAY_NAME += L10n.Term(arrDATA_FIELD[nFormatIndex]);
							}
							else
							{
								DISPLAY_NAME += ' ';
							}
						}
					}
					else
					{
						if ( !Sql.IsEmptyString(DATA_FIELD) && DATA_FIELD.indexOf('.') >= 0 )
						{
							DISPLAY_NAME = L10n.Term(DATA_FIELD);
						}
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
							let arrDATA_FIELD = DATA_FIELD.split(' ');
							// 10/31/2019 Paul.  If data format empty, then just combine all data fields. 
							if ( Sql.IsEmptyString(DATA_FORMAT) )
							{
								DATA_FORMAT = '';
								for ( let nFormatIndex = 0; nFormatIndex < arrDATA_FIELD.length; nFormatIndex++ )
								{
									if ( !Sql.IsEmptyString(DATA_FORMAT) )
									{
										DATA_FORMAT += ' ';
									}
									DATA_FORMAT += '{' + nFormatIndex.toString() + '}';
								}
							}
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
										if ( arrDATA_FIELD[nFormatIndex] == 'PICTURE' )
										{
											DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', Credentials.RemoteServer + 'App_Themes/Six/images/ActivityStreamUser.gif');
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
											//console.log((new Date()).toISOString() + ' ' + 'SplendidString.constructor() Date', DATA_VALUE);
											DATA_VALUE = this.Formatting.FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
											DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', DATA_VALUE);
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
						}
						else if ( row[DATA_FIELD] != null )
						{
							// 10/31/2019 Paul.  If data format empty, then just combine all data fields. 
							if ( Sql.IsEmptyString(DATA_FORMAT) )
							{
								DATA_FORMAT = '{0}';
							}
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
									if ( DATA_FORMAT.indexOf('{0:d}') >= 0 )
									{
										DATA_VALUE   = this.Formatting.FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT());
										DISPLAY_NAME = DATA_FORMAT.replace('{0:d}', DATA_VALUE);
									}
									else if ( DATA_FORMAT.indexOf('{0:c}') >= 0 )
									{
										//console.log((new Date()).toISOString() + ' ' + DATA_VALUE + ' = ' + formatCurrency(DATA_VALUE, oNumberFormat));
										// 03/30/2007 Paul.  Convert DetailView currencies on the fly. 
										// 05/05/2007 Paul.  In an earlier step, we convert NULLs to empty strings. 
										// Attempts to convert to decimal will generate an error: Input string was not in a correct format.
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
													let nFixed: number = parseInt(DATA_FORMAT.substring(nStartListName + ('{0:f').length, nEndListName));
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
									else
									{
										// 08/26/2014 Paul.  Text with angle brackets (such as an email), will generate an error when used with innerHTML. 
										//tdField.innerHTML = DATA_FORMAT.replace('{0}', DATA_VALUE);
										// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
										DISPLAY_NAME = Sql.ReplaceEntities(DATA_FORMAT.replace('{0}', DATA_VALUE));
									}
								}
								catch(error)
								{
									console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
								}
							}
						}
						// 03/18/2020 Paul.  Label is in DATA_FIELD. 
						else if ( !Sql.IsEmptyString(layout.DATA_FIELD) && layout.DATA_FIELD.indexOf('.') >= 0 )
						{
							DISPLAY_NAME = L10n.Term(layout.DATA_FIELD);
						}
					}
					catch(error: any)
					{
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
						DISPLAY_NAME = error.message;
					}
				}
				// 10/12/2020 Paul.  There is a special case where we are show a date and a user name. 
				if ( DATA_FIELD && DATA_FIELD.indexOf('.LBL_BY') > 0 )
				{
					let arrDATA_FIELD = DATA_FIELD.split(' ');
					if ( arrDATA_FIELD.length == 3 && Trim(DISPLAY_NAME) == L10n.Term('.LBL_BY') )
						DISPLAY_NAME = '';
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DISPLAY_NAME, row);
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ngOnInit', error);
		}
		this.ID           = ID          ;
		this.FIELD_INDEX  = FIELD_INDEX ;
		this.DATA_FIELD   = DATA_FIELD  ;
		this.DATA_LABEL   = DATA_LABEL  ;
		this.DATA_FORMAT  = DATA_FORMAT ;
		this.DISPLAY_NAME = DISPLAY_NAME;
		this.CSS_CLASS    = CSS_CLASS   ;
	}

	ngDoCheck() : void
	{
	}

	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit', this);
		this.fieldDidMount.emit({ DATA_FIELD: this.DATA_FIELD, component: this });
	}

	// 11/24/2021 Paul.  Provide a way to turn text into a hyperlink. 
	public _onClick(event: any)
	{
		const { URL } = this;
		event.preventDefault()
		if ( StartsWith(URL, '/Reset/') )
		{
			this.router.navigateByUrl(URL);
		}
		else
		{
			window.location.href = URL;
		}
	}

}
