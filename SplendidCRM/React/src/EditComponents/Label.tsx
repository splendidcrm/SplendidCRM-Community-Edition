/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
import * as React from 'react';
import * as XMLParser from 'fast-xml-parser';
// 2. Store and Types. 
import { IEditComponentProps, EditComponent } from '../types/EditComponent'  ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'          ;
import L10n                                   from '../scripts/L10n'         ;
import C10n                                   from '../scripts/C10n'         ;
import Security                               from '../scripts/Security'     ;
import Credentials                            from '../scripts/Credentials'  ;
import { StartsWith, EndsWith, Trim }         from '../scripts/utility'      ;
import { FromJsonDate, formatCurrency }       from '../scripts/Formatting'   ;
// 4. Components and Views. 

interface ILabelState
{
	ID               : string ;
	FIELD_INDEX      : number ;
	DATA_FIELD       : string ;
	DATA_LABEL       : string ;
	DATA_FORMAT      : string ;
	DISPLAY_NAME     : string ;
	CSS_CLASS?       : string;
	// 11/24/2021 Paul.  Provide a way to turn text into a hyperlink. 
	URL?             : string;
}

export default class Label extends React.PureComponent<IEditComponentProps, ILabelState>
{
	public get data(): any
	{
		return null;
	}

	public validate(): boolean
	{
		return true;
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.updateDependancy ' + PROPERTY_NAME, DATA_VALUE);
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.setState({ DISPLAY_NAME: DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.setState({ CSS_CLASS: DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'URL' )
		{
			this.setState({ URL: DATA_VALUE });
		}
	}

	public clear(): void
	{
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
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
			const { baseId, layout, row, onChanged } = this.props;
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
											DATA_VALUE  = FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT());
											DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + ':d}', DATA_VALUE);
										}
										else if ( DATA_FORMAT.indexOf('{' + nFormatIndex.toString() + ':c}') >= 0 )
										{
											//console.log((new Date()).toISOString() + ' ' + DATA_VALUE + ' = ' + formatCurrency(DATA_VALUE, oNumberFormat));
											// 10/16/2021 Paul.  Add support for user currency. 
											let dConvertedValue = C10n.ToCurrency(Sql.ToDecimal(DATA_VALUE));
											DATA_VALUE  = formatCurrency(dConvertedValue, oNumberFormat);
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
											DATA_VALUE = FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
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
									let xml = XMLParser.parse(DATA_VALUE);
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
										DATA_VALUE   = FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT());
										DISPLAY_NAME = DATA_FORMAT.replace('{0:d}', DATA_VALUE);
									}
									else if ( DATA_FORMAT.indexOf('{0:c}') >= 0 )
									{
										//console.log((new Date()).toISOString() + ' ' + DATA_VALUE + ' = ' + formatCurrency(DATA_VALUE, oNumberFormat));
										// 03/30/2007 Paul.  Convert DetailView currencies on the fly. 
										// 05/05/2007 Paul.  In an earlier step, we convert NULLs to empty strings. 
										// Attempts to convert to decimal will generate an error: Input string was not in a correct format.
										// 10/16/2021 Paul.  Add support for user currency. 
										let dConvertedValue = C10n.ToCurrency(Sql.ToDecimal(DATA_VALUE));
										DATA_VALUE   = formatCurrency(dConvertedValue, oNumberFormat);
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
												catch(error)
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
												catch(error)
												{
													DISPLAY_NAME = DATA_FORMAT.replace(sPLACEHOLDER, error.message);
												}
											}
										}
									}
									// 10/03/2011 Paul.  If the data value is an integer, then substr() will throw an exception. 
									else if ( typeof (DATA_VALUE) == 'string' && DATA_VALUE.substr(0, 7) == '\\/Date(' )
									{
										DATA_VALUE   = FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
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
					catch(error)
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
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			ID          ,
			FIELD_INDEX ,
			DATA_FIELD  ,
			DATA_LABEL  ,
			DATA_FORMAT ,
			DISPLAY_NAME,
			CSS_CLASS   ,
		};
	}

	async componentDidMount()
	{
		const { DATA_FIELD } = this.state;
		if ( this.props.fieldDidMount )
		{
			this.props.fieldDidMount(DATA_FIELD, this);
		}
	}

	// shouldComponentUpdate is not used with a PureComponent
	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: ILabelState)
	{
		if ( nextProps.row != this.props.row )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextProps.layout != this.props.layout )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( nextProps.bIsHidden != this.props.bIsHidden )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.DISPLAY_NAME != this.state.DISPLAY_NAME )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.URL != this.state.URL )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		return false;
	}

	// 11/24/2021 Paul.  Provide a way to turn text into a hyperlink. 
	public _onClick = () =>
	{
		const { URL } = this.state;
		if ( StartsWith(URL, '/Reset/') )
		{
			// 06/10/2022 Paul.  We don't have the history, so just navigate directly. 
			window.location.href = URL.replace('/Reset/', Credentials.RemoteServer + 'React/');
		}
		else
		{
			window.location.href = URL;
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_LABEL, DISPLAY_NAME, CSS_CLASS, URL } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, URL);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<div>DATA_FIELD is empty for Label FIELD_INDEX { FIELD_INDEX }</div>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			// 11/24/2021 Paul.  Provide a way to turn text into a hyperlink. 
			else if ( !Sql.IsEmptyString(URL) )
			{
				let sFullURL: string = URL;
				if ( StartsWith(URL, '/Reset/') )
				{
					sFullURL = URL.replace('/Reset/', Credentials.RemoteServer + 'React/');
				}
				return (<a
					id={ ID }
					key={ ID }
					style={ {marginLeft: '4px'} }
					className={ CSS_CLASS }
					href={ sFullURL }
					onClick={ (e) => { e.preventDefault(); this._onClick(); } }
				>
					{ DISPLAY_NAME }
				</a>);
			}
			else
			{
				return (
					<span id={ ID } key={ ID } style={ {marginLeft: '4px'} } className={ CSS_CLASS }>
						{ DISPLAY_NAME }
					</span>
				);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.render', error);
			return (<span>{ error.message }</span>);
		}
	}
}

