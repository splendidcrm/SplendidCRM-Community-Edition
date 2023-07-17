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
import { FontAwesomeIcon }                  from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
import ACL_FIELD_ACCESS                     from '../types/ACL_FIELD_ACCESS';
// 3. Scripts. 
import Sql                                  from '../scripts/Sql'           ;
import L10n                                 from '../scripts/L10n'          ;
import C10n                                 from '../scripts/C10n'          ;
import Security                             from '../scripts/Security'      ;
import Credentials                          from '../scripts/Credentials'   ;
import SplendidCache                        from '../scripts/SplendidCache' ;
import { Crm_Config }                       from '../scripts/Crm'           ;
import { FromJsonDate, formatCurrency }     from '../scripts/Formatting'    ;
// 4. Components and Views. 

interface IHoverProps
{
	row   : any;
	layout: any;
}

interface IHoverState
{
	DISPLAY_NAME: string;
}

class Hover extends React.PureComponent<IHoverProps, IHoverState>
{
	private themeURL: string = null;
	private legacyIcons: boolean = false;

	constructor(props: IHoverProps)
	{
		super(props);
		const { row, layout } = this.props;
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');

		let DISPLAY_NAME: any = '';
		if ( layout != null )
		{
			let MODULE_NAME     : string   = SplendidCache.GetGridModule(layout);
			let DATA_FIELD      : string   = Sql.ToString(layout.URL_FIELD );
			let DATA_FORMAT     : string   = Sql.ToString(layout.URL_FORMAT);
			let arrERASED_FIELDS: string[] = row['arrERASED_FIELDS'];
			if ( !Sql.IsEmptyString(DATA_FIELD) && !Sql.IsEmptyString(DATA_FORMAT) )
			{
				let oNumberFormat = Security.NumberFormatInfo();
				let gASSIGNED_USER_ID: string = null;
				let bPARTIAL_ERASED: boolean = false;
				let arrDATA_FIELD = DATA_FIELD.split(' ');
				// 06/19/2022 Paul.  Move Field Security lower. 
				if ( SplendidCache.bEnableACLFieldSecurity )
				{
					for ( let i = 0; i < arrDATA_FIELD.length; i++ )
					{
						// 02/11/2016 Paul.  Exclude terminology. 
						if ( arrDATA_FIELD[i].indexOf('.') < 0 )
						{
							// 02/11/2016 Paul.  Fix cut-and-paste error.  We were testing sDATA_FIELD and not arrURL_FIELD[i]. 
							let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
							if ( !acl.IsReadable() )
								arrDATA_FIELD[i] = '.';
						}
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, row);
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
							if ( arrERASED_FIELDS && arrERASED_FIELDS.length > 0 && arrERASED_FIELDS.indexOf(arrDATA_FIELD[nFormatIndex]) >= 0 )
							{
								DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', Sql.DataPrivacyErasedPill());
								bPARTIAL_ERASED = true;
							}
							else
							{
								DATA_FORMAT = Sql.replaceAll(DATA_FORMAT, '{' + nFormatIndex.toString() + '}', '');
							}
						}
						else
						{
							let DATA_VALUE: string = row[arrDATA_FIELD[nFormatIndex]];
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
										let LIST_NAME: string = DATA_FORMAT.substring(nStartListName + ('{' + nFormatIndex.toString() + ';').length, nEndListName);
										DATA_VALUE  = L10n.ListTerm(LIST_NAME, DATA_VALUE);
										DATA_FORMAT = DATA_FORMAT.replace(sPLACEHOLDER, DATA_VALUE);
									}
								}
							}
							// 10/03/2011 Paul.  If the data value is an integer, then substr() will throw an exception. 
							else if ( typeof (DATA_VALUE) == 'string' && DATA_VALUE.substr(0, 7) === '\\/Date(' )
							{
								//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor() Date', DATA_VALUE);
								DATA_VALUE = FromJsonDate(DATA_VALUE, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
								DATA_FORMAT = DATA_FORMAT.replace('{' + nFormatIndex.toString() + '}', DATA_VALUE);
							}
							else
							{
								DATA_FORMAT = Sql.replaceAll(DATA_FORMAT, '{' + nFormatIndex.toString() + '}', DATA_VALUE);
							}
						}
					}
				}
				// 12/24/2012 Paul.  Use regex global replace flag. 
				// 05/14/2018 Paul.  id is set when created. 
				//tdField.id = 'ctlDetailView_' + DATA_FIELD.replace(/\s/g, '_');
				// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
				DISPLAY_NAME = Sql.ReplaceEntities(DATA_FORMAT);
				DISPLAY_NAME = DISPLAY_NAME.replace('view.aspx?ID=', 'View/');
				DISPLAY_NAME = DISPLAY_NAME.replace('edit.aspx?ID=', 'Edit/');
				// 07/08/2023 Paul.  ASP.NET Core will not have /React in the base. 
				DISPLAY_NAME = DISPLAY_NAME.replace('~/' , Credentials.RemoteServer + Credentials.ReactBase);
				DISPLAY_NAME = DISPLAY_NAME.replace('../', Credentials.RemoteServer + Credentials.ReactBase);
				// 09/09/2019 Paul.  We need to convert a partially erased field into react components. 
				// 12/25/2019 Paul.  Simple conversion will not work as the format typically includes HTML. 
				/*
				if ( bPARTIAL_ERASED )
				{
					let arrNEW_NAME: any[] = [];
					let sPill: string = Sql.DataPrivacyErasedPill();
					let nStartIndex: number = 0;
					let nPillIndex: number = DISPLAY_NAME.indexOf(sPill, nStartIndex);
					while ( nPillIndex >= 0 )
					{
						let s = DISPLAY_NAME.substring(nStartIndex, nPillIndex);
						arrNEW_NAME.push(s);
						arrNEW_NAME.push(<span className="Erased">{ L10n.Term('DataPrivacy.LBL_ERASED_VALUE') }</span>);
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
				*/
			}
		}
		this.state =
		{
			DISPLAY_NAME,
		};
	}

	public render()
	{
		const { layout, row } = this.props;
		const { DISPLAY_NAME } = this.state;
		let URL_FIELD = Sql.ToString(layout.URL_FIELD);
		if ( layout == null )
		{
			return (<div>layout prop is null</div>);
		}
		else if ( Sql.IsEmptyString(URL_FIELD) )
		{
			return (<div>URL_FIELD is empty for FIELD_INDEX { layout.FIELD_INDEX }</div>);
		}
		else
		{
			return(<span className='hoverTooltip'>
				{ this.legacyIcons
				? <img src={ this.themeURL + 'info_inline.gif'} style={ {borderWidth: '0px'} } />
				: <FontAwesomeIcon icon={ {prefix: 'fas', iconName: 'info'} } />
				}
				<span className='hoverTooltipText' dangerouslySetInnerHTML={ {__html: DISPLAY_NAME} } />
			</span>);
		}
	}
}

export default Hover;
