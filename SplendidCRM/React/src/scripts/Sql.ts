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
// 2. Store and Types. 
import { EditComponent }     from '../types/EditComponent'  ;
// 3. Scripts. 
import L10n                  from '../scripts/L10n'         ;
import SplendidCache         from '../scripts/SplendidCache';
import { Crm_Config }        from '../scripts/Crm'          ;
import { EndsWith, inArray } from '../scripts/utility'      ;

// 04/22/2020 Paul.  Remove dependency on 'util' import. 
function isObject(arg)
{
	return typeof arg === 'object' && arg !== null;
}

function objectToString(o)
{
	return Object.prototype.toString.call(o);
}

function isDate(d)
{
	return isObject(d) && objectToString(d) === '[object Date]';
}

export default class Sql
{
	// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
	public static sEMPTY_PASSWORD: string = '**********';

	static ToString(o)
	{
		if ( o === undefined || o == null )
			return '';
		else if ( typeof(o) != 'string' )
			return o.toString();
		return o;
	}

	// 02/29/2016 Paul.  Order management requires decimals. 
	static ToDecimal(n)
	{
		// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
		if (n === undefined || n == null || n === '')
			return 0.0;
		n = parseFloat(n);
		if (isNaN(n))
			return 0.0;
		return n;
	}

	static ToFloat(n)
	{
		// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
		if (n === undefined || n == null || n === '')
			return 0.0;
		n = parseFloat(n);
		if (isNaN(n))
			return 0.0;
		return n;
	}

	static ToDouble(n)
	{
		// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
		if (n === undefined || n == null || n === '')
			return 0.0;
		n = parseFloat(n);
		if (isNaN(n))
			return 0.0;
		return n;
	}

	static ToInteger(n)
	{
		// 04/25/2013 Paul.  ToInteger should not return NaN for an empty string. 
		// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
		if (n === undefined || n == null || n === '')
			return 0;
		n = parseInt(n);
		if (isNaN(n))
			return 0;
		return n;
	}

	static IsInteger(n)
	{
		// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
		if (n === undefined || n == null || n === '')
			return false;
		n = parseInt(n);
		return !isNaN(n);
	}

	static IsFloat(f)
	{
		// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
		if (f === undefined || f == null || f === '')
			return false;
		f = parseFloat(f);
		return !isNaN(f);
	}

	static ToDateTime(sDate)
	{
		if ( sDate === undefined || sDate == null || sDate == '' )
			return new Date(1970, 1, 1);
		let dt = new Date(sDate);
		if ( !isDate(dt) )
			return new Date(1970, 1, 1);
		return dt;
	}

	static IsDate(sDate)
	{
		let dt = new Date(sDate);
		return isDate(dt);
	}

	static IsEmail(sEmail)
	{
		let filter = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
		return filter.test(sEmail);
	}

	static ToBoolean(b)
	{
		if (b === undefined || b == null)
			return false;
		return (b == 'true' || b == 'True' || b == 'on' || b == '1' || b == true || b == 1);
	}

	// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
	static replaceAll(str, find, replace)
	{
		// 07/10/2021 Paul.  Input may be a number, boolean or array. 
		if ( typeof(str) == 'string' )
			return str.replace(new RegExp(find.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'), 'g'), replace);
		else if ( str != null && str !== undefined )
			return Sql.ToString(str);
		return '';
	}
	
	// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
	static EscapeSQL(str)
	{
		if (str != null)
		{
			// 03/09/2016 Paul.  Was not assigning the result back to the current string. 
			str = Sql.replaceAll(str, '\'', '\'\'');
		}
		return str;
	}

	// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
	static EscapeSQLLike(str)
	{
		if (str != null)
		{
			str = Sql.replaceAll(str, '\\', '\\\\');
			// 06/14/2015 Paul.  We want to allow the original like syntax which uses % for any chars and _ for any single char. 
			//str = Sql.replaceAll(str, '%' , '\\%');
			//str = Sql.replaceAll(str, '_' , '\\_');
		}
		return str;
	}

	// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
	static EscapeJavaScript(str)
	{
		if (str != null)
		{
			str = Sql.replaceAll(str, '\\', '\\\\');
			str = Sql.replaceAll(str, '\'', '\\\'');
			str = Sql.replaceAll(str, '\"', '\\\"');
			str = Sql.replaceAll(str, '\t', '\\t');
			str = Sql.replaceAll(str, '\r', '\\r');
			str = Sql.replaceAll(str, '\n', '\\n');
		}
		return str;
	}

	static ReplaceEntities(str)
	{
		//console.log('Sql.ReplaceEntities', str);
		// 05/28/2018 Paul.  HTML entities will not get escaped in React.  Do a couple of them manually. 
		if ( str != null && typeof(str.indexOf) == 'function' && str.indexOf('&') >= 0 )
		{
			// https://andrew.hedges.name/experiments/entities/
			str = Sql.replaceAll(str, '&nbsp;', '\u00a0');
			str = Sql.replaceAll(str, '&amp;', '&');
			str = Sql.replaceAll(str, '&lt;', '<');
			str = Sql.replaceAll(str, '&gt;', '>');
		}
		return str;
	}

	// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
	static EscapeEmail(str)
	{
		if (str != null)
		{
			str = Sql.replaceAll(str, '&', '&amp;');
			str = Sql.replaceAll(str, '<', '&lt;');
			str = Sql.replaceAll(str, '>', '&gt;');
		}
		return str;
	}

		// 04/05/2012 Paul.  EscapeXml is needed in the SearchView. 
	static EscapeXml(str)
	{
		str = Sql.replaceAll(str, '\"', '&quot;');
		str = Sql.replaceAll(str, '\'', '&apos;');
		str = Sql.replaceAll(str, '<' , '&lt;'  );
		str = Sql.replaceAll(str, '>' , '&gt;'  );
		str = Sql.replaceAll(str, '&' , '&amp;' );
		return str;
	}

	static NormalizePhone(str)
{
	str = Sql.ToString(str)
	str = Sql.replaceAll(str," ", '');
	str = Sql.replaceAll(str,"+", '');
	str = Sql.replaceAll(str,"(", '');
	str = Sql.replaceAll(str,")", '');
	str = Sql.replaceAll(str,"-", '');
	str = Sql.replaceAll(str,".", '');
	// 08/08/2018 Paul.  Use like clause for more flexible phone number lookup. 
	str = Sql.replaceAll(str,"[", '');
	str = Sql.replaceAll(str,"]", '');
	str = Sql.replaceAll(str,"#", '');
	str = Sql.replaceAll(str,"*", '');
	str = Sql.replaceAll(str,"%", '');
	return str;
}


	static IsEmptyString(str)
	{
		// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
		if (str === undefined || str == null || str === '')
			return true;
		return false;
	}

	static ToGuid(g)
	{
		// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
		if (g === undefined || g == null || g === '' || typeof (g) != 'string')
			return null;
		return g.toLowerCase();
	}

	static IsEmptyGuid(str)
	{
		// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
		if (str === undefined || str == null || str === '' || str == '00000000-0000-0000-0000-000000000000')
			return true;
		return false;
	}

	static AppendLikeParameters(cmd, sField, oValue, bOrClause?)
	{
		let ControlChars = { CrLf: '\r\n' };
		if ( bOrClause === undefined )
		{
			bOrClause = false;
		}
		if ( Array.isArray(oValue) )  // Array test. 
		{
			if ( oValue.length > 0 )
			{
				if ( bOrClause )
					cmd.CommandText += '    or ';
				else
					cmd.CommandText += '   and ';
				cmd.CommandText += '( 1 = 1' + ControlChars.CrLf;
				for ( let i = 0; i < oValue.length; i++ )
				{
					cmd.CommandText += '        and ' + sField + ' like ' + '\'' + '%' + this.EscapeSQL(oValue[i]) + '%' + '\'' + ControlChars.CrLf;
				}
				cmd.CommandText += '       )' + ControlChars.CrLf;
			}
		}
		else
		{
			if ( bOrClause )
				cmd.CommandText += '    or ';
			else
				cmd.CommandText += '   and ';
			cmd.CommandText += sField + ' like ' + '\'' + '%' + this.EscapeSQL(oValue) + '%' + '\'' + ControlChars.CrLf;
		}
	}

	static AppendParameterWithNull(cmd, sField, oValue, bOrClause?)
	{
		let ControlChars = { CrLf: '\r\n' };
		if ( bOrClause === undefined )
		{
			bOrClause = false;
		}
		if ( Array.isArray(oValue) )  // Array test. 
		{
			if ( oValue.length > 0 )
			{
				let bIncludeNull = false;
				let sValueList = '';
				for ( let i = 0; i < oValue.length; i++ )
				{
					if (oValue[i] == null || oValue[i].length == 0)
					{
						bIncludeNull = true;
						// 05/29/2017 Paul.  vwOPPORTUNITIES_ByLeadSource converts null to empty string, so we need to include both. 
						if ( sValueList.length > 0 )
						{
							// 10/25/2020 Paul.  Place values on another line 
							sValueList += ControlChars.CrLf + '      , ';
						}
						// 01/06/2018 Paul.  ASSIGNED_USER_ID will fail compare to ''. 
						if ( EndsWith(sField, '_ID') || EndsWith(sField, '_ID_C') )
							sValueList += 'null';
						else
							sValueList += '\'\'';
					}
					else
					{
						if ( sValueList.length > 0 )
						{
							// 10/25/2020 Paul.  Place values on another line 
							sValueList += ControlChars.CrLf + '      , ';
						}
						sValueList += '\'' + this.EscapeSQL(oValue[i]) + '\'';
					}
				}
				if ( cmd.CommandText.length > 0 )
				{
					if ( bOrClause )
						cmd.CommandText += '    or ';
					else
						cmd.CommandText += '   and ';
				}
				if ( sValueList.length > 0 )
				{
					if ( bIncludeNull )
						cmd.CommandText += '(' + sField + ' is null or ' + sField + ' in (' + sValueList + '))' + ControlChars.CrLf;
					else
						cmd.CommandText += sField + ' in (' + sValueList + ')' + ControlChars.CrLf;
				}
				else if ( bIncludeNull )
				{
					cmd.CommandText += sField + ' is null' + ControlChars.CrLf;
				}
			}
		}
		else if ( oValue == null )
		{
			if ( cmd.CommandText.length > 0 )
			{
				if ( bOrClause )
					cmd.CommandText += '    or ';
				else
					cmd.CommandText += '   and ';
			}
			cmd.CommandText += sField + ' is null' + ControlChars.CrLf;
		}
		else
		{
			if ( cmd.CommandText.length > 0 )
			{
				if ( bOrClause )
					cmd.CommandText += '    or ';
				else
					cmd.CommandText += '   and ';
			}
			cmd.CommandText += sField + ' = ' + '\'' + this.EscapeSQL(oValue) + '\'' + ControlChars.CrLf;
		}
	}

	static AppendGuids(cmd, sField, oValue)
	{
		let ControlChars = { CrLf: '\r\n' };
		if ( oValue != null && Array.isArray(oValue) )  // Array test. 
		{
			if ( oValue.length > 0 )
			{
				let sValueList: string = '';
				for ( let i = 0; i < oValue.length; i++ )
				{
					if ( sValueList.length > 0 )
					{
						// 10/25/2020 Paul.  Place values on another line 
						sValueList += ControlChars.CrLf + '      , ';
					}
					sValueList += '\'' + this.EscapeSQL(oValue[i]) + '\'';
				}
				cmd.CommandText += ' and ' + sField + ' in (' + sValueList + ')' + ControlChars.CrLf;
			}
		}
	}

	static AppendParameter(cmd, sField, oValue, bOrClause?)
	{
		let ControlChars = { CrLf: '\r\n' };
		if ( bOrClause === undefined )
		{
			bOrClause = false;
		}
		// http://www.javascriptkit.com/javatutors/determinevar2.shtml
		if ( oValue == null )
		{
			if ( cmd.CommandText.length > 0 )
			{
				if ( bOrClause )
					cmd.CommandText += ' or ';
				else
					cmd.CommandText += ' and ';
			}
			cmd.CommandText += sField + ' is null' + ControlChars.CrLf;
		}
		else if (typeof (oValue) == 'number')
		{
			if ( cmd.CommandText.length > 0 )
			{
				if ( bOrClause )
					cmd.CommandText += ' or ';
				else
					cmd.CommandText += ' and ';
			}
			cmd.CommandText += sField + ' = ' + oValue + ControlChars.CrLf;
		}
		else if (typeof (oValue) == 'boolean')
		{
			if ( cmd.CommandText.length > 0 )
			{
				if ( bOrClause )
					cmd.CommandText += ' or ';
				else
					cmd.CommandText += ' and ';
			}
			cmd.CommandText += sField + ' = ' + (oValue ? '1' : '0') + ControlChars.CrLf;
		}
		else if (typeof (oValue) == 'string')
		{
			if ( cmd.CommandText.length > 0 )
			{
				if ( bOrClause )
					cmd.CommandText += ' or ';
				else
					cmd.CommandText += ' and ';
			}
			if ( oValue.length == 0 )
			{
				cmd.CommandText += sField + ' is null' + ControlChars.CrLf;
			}
			else
			{
				cmd.CommandText += sField + ' = \'' + this.EscapeSQL(oValue) + '\'' + ControlChars.CrLf;
			}
		}
		else if (typeof (oValue) == 'object')
		{
			// 11/13/2019 Paul.  Better array test. 
			if ( Array.isArray(oValue) )  // Array test. 
			{
				if ( oValue.length > 0 )
				{
					let bIncludeNull = false;
					let sValueList = '';
					for ( let i = 0; i < oValue.length; i++ )
					{
						// 11/16/2019 Paul.  TeamSelect and UserSelect will return an array of objects. 
						if ( typeof(oValue[i]) == 'object' )
						{
							if ( oValue[i].DATA_VALUE !== undefined && (EndsWith(sField, '_ID') || EndsWith(sField, '_ID_C')) )
							{
								sValueList += '\'' + this.EscapeSQL(oValue[i].DATA_VALUE) + '\'';
							}
							else if ( oValue[i].DISPLAY_VALUE !== undefined && EndsWith(sField, '_NAME') )
							{
								sValueList += '\'' + this.EscapeSQL(oValue[i].DISPLAY_VALUE) + '\'';
							}
						}
						else if (oValue[i] == null || oValue[i].length == 0)
						{
							bIncludeNull = true;
							// 05/29/2017 Paul.  vwOPPORTUNITIES_ByLeadSource converts null to empty string, so we need to include both. 
							if ( sValueList.length > 0 )
							{
								// 10/25/2020 Paul.  Place values on another line 
								sValueList += ControlChars.CrLf + '      , ';
							}
							// 01/06/2018 Paul.  ASSIGNED_USER_ID will fail compare to ''. 
							if ( EndsWith(sField, '_ID') || EndsWith(sField, '_ID_C') )
								sValueList += 'null';
							else
								sValueList += '\'\'';
						}
						else
						{
							if ( sValueList.length > 0 )
							{
								// 10/25/2020 Paul.  Place values on another line 
								sValueList += ControlChars.CrLf + '      , ';
							}
							sValueList += '\'' + this.EscapeSQL(oValue[i]) + '\'';
						}
					}
					if ( cmd.CommandText.length > 0 )
					{
						if ( bOrClause )
							cmd.CommandText += ' or ';
						else
							cmd.CommandText += ' and ';
					}
					if ( sValueList.length > 0 )
					{
						if ( bIncludeNull )
							cmd.CommandText += '(' + sField + ' is null or ' + sField + ' in (' + sValueList + '))' + ControlChars.CrLf;
						else
							cmd.CommandText += sField + ' in (' + sValueList + ')' + ControlChars.CrLf;
					}
					else if ( bIncludeNull )
					{
						cmd.CommandText += sField + ' is null' + ControlChars.CrLf;
					}
				}
			}
		}
	}

	// 06/16/2017 Paul.  Dashboard needs to parse form data. 
	static ParseFormData(sParameters)
	{
		let row = new Object();
		if (sParameters !== undefined && sParameters != null)
		{
			let arrParameters = sParameters.split('&');
			for (let n = 0; n < arrParameters.length; n++)
			{
				let arrNameValue = arrParameters[n].split('=');
				if (arrNameValue.length > 1)
					row[arrNameValue[0]] = arrNameValue[1];
				else
					row[arrNameValue[0]] = null;
			}
		}
		return row;
	}

	static DataPrivacyErasedPill()
	{
		return '<span class="Erased">' + L10n.Term('DataPrivacy.LBL_ERASED_VALUE') + '</span>';
	}

	static SelectGridColumns(layout)
	{
		let arrSelectFields = new Array();
		// 12/26/2019 Paul.  layout may be null or undefined. 
		if ( layout && layout.length > 0 )
		{
			let bEnableTeamManagement = Sql.ToBoolean(SplendidCache.Config('enable_team_management'));
			let bEnableDynamicTeams   = Sql.ToBoolean(SplendidCache.Config('enable_dynamic_teams'  ));
			for (let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++)
			{
				let lay               : any    = layout[nLayoutIndex];
				let GRID_NAME         : string = Sql.ToString(lay.GRID_NAME         );
				let SORT_EXPRESSION   : string = Sql.ToString(lay.SORT_EXPRESSION   );
				let DATA_FIELD        : string = Sql.ToString(lay.DATA_FIELD        );
				let LIST_NAME         : string = Sql.ToString(lay.LIST_NAME         );
				let DATA_FORMAT       : string = Sql.ToString(lay.DATA_FORMAT       );
				let URL_FIELD         : string = Sql.ToString(lay.URL_FIELD         );
				let URL_MODULE        : string = Sql.ToString(lay.URL_MODULE        );
				let URL_ASSIGNED_FIELD: string = Sql.ToString(lay.URL_ASSIGNED_FIELD);
				let PARENT_FIELD      : string = Sql.ToString(lay.PARENT_FIELD      );

				if ( DATA_FIELD != null && DATA_FIELD.length > 0 )
				{
					// 09/16/2014 Paul.  Need to prevent duplicate entries in array. 
					if ( inArray(DATA_FIELD, arrSelectFields) == -1 )
					{
						arrSelectFields.push(DATA_FIELD);
					}
					// 08/29/2014 Paul.  Add the team set when adding the team name as the swap will be made inline. 
					if ( bEnableTeamManagement && bEnableDynamicTeams && DATA_FIELD == 'TEAM_NAME' )
					{
						// 09/13/2019 Paul.  Exclude Teams lists. 
						if ( inArray('TEAM_SET_NAME', arrSelectFields) == -1 && GRID_NAME.indexOf('Teams') == -1 )
						{
							arrSelectFields.push('TEAM_SET_NAME');
						}
					}
				}
				if ( SORT_EXPRESSION != null && SORT_EXPRESSION.length > 0 )
				{
					if ( DATA_FIELD != SORT_EXPRESSION )
					{
						if ( inArray(SORT_EXPRESSION, arrSelectFields) == -1 )
						{
							arrSelectFields.push(SORT_EXPRESSION);
						}
					}
				}
				if ( URL_FIELD != null && URL_FIELD.length > 0 )
				{
					if ( URL_FIELD.indexOf(' ') >= 0 )
					{
						let arrURL_FIELD = URL_FIELD.split(' ');
						for ( let i = 0; i < arrURL_FIELD.length; i++ )
						{
							let s = arrURL_FIELD[i];
							if ( s.indexOf('.') == -1 && s.length > 0 )
							{
								if ( inArray(s, arrSelectFields) == -1 )
								{
									arrSelectFields.push(s);
								}
							}
						}
					}
					else if ( URL_FIELD.indexOf('.') == -1 )
					{
						if ( inArray(URL_FIELD, arrSelectFields) == -1 )
						{
							arrSelectFields.push(URL_FIELD);
						}
					}
					if ( URL_ASSIGNED_FIELD != null && URL_ASSIGNED_FIELD.length > 0 )
					{
						if ( inArray(URL_ASSIGNED_FIELD, arrSelectFields) == -1 )
						{
							arrSelectFields.push(URL_ASSIGNED_FIELD);
						}
					}
				}
				if ( PARENT_FIELD != null && PARENT_FIELD.length > 0 )
				{
					if ( inArray(PARENT_FIELD, arrSelectFields) == -1 )
					{
						arrSelectFields.push(PARENT_FIELD);
					}
				}
				// 12/01/2012 Paul.  ACTIVITY_TYPE is an implied required field for ACTIVITY views. 
				if ( LIST_NAME == 'activity_status' )
				{
					if ( inArray('ID', arrSelectFields) == -1 )
					{
						arrSelectFields.push('ID');
					}
					if ( inArray('ACTIVITY_TYPE', arrSelectFields) == -1 )
					{
						arrSelectFields.push('ACTIVITY_TYPE');
					}
					// 12/01/2012 Paul.  Direction and Status are used by Calls. 
					if ( inArray('DIRECTION', arrSelectFields) == -1 )
					{
						arrSelectFields.push('DIRECTION');
					}
					if ( inArray('STATUS', arrSelectFields) == -1 )
					{
						arrSelectFields.push('STATUS');
					}
				}
				else if ( URL_MODULE == 'Activities' )
				{
					if ( inArray('ID', arrSelectFields) == -1 )
					{
						arrSelectFields.push('ID');
					}
					if ( inArray('ACTIVITY_TYPE', arrSelectFields) == -1 )
					{
						arrSelectFields.push('ACTIVITY_TYPE');
					}
				}
			}
		}
		return arrSelectFields;
	}

	static SearchGridColumns(layout)
	{
		let arrSelectFields  = new Array();
		let arrSkippedFields = new Array();
		arrSkippedFields.push('USER_NAME'    );
		arrSkippedFields.push('ASSIGNED_TO'  );
		arrSkippedFields.push('CREATED_BY'   );
		arrSkippedFields.push('MODIFIED_BY'  );
		arrSkippedFields.push('DATE_ENTERED' );
		arrSkippedFields.push('DATE_MODIFIED');
		arrSkippedFields.push('TEAM_NAME'    );
		arrSkippedFields.push('TEAM_SET_NAME');
		// 05/15/2016 Paul.  Don't need to search ASSIGNED_TO_NAME. 
		arrSkippedFields.push('ASSIGNED_TO_NAME');
		if ( layout != null && layout.length > 0 )
		{
			for (let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++)
			{
				let lay = layout[nLayoutIndex];
				let sCOLUMN_TYPE      : string = Sql.ToString(lay.COLUMN_TYPE       );
				let DATA_FIELD        : string = Sql.ToString(lay.DATA_FIELD        );
				let DATA_FORMAT       : string = Sql.ToString(lay.DATA_FORMAT       );
				let MODULE_TYPE       : string = Sql.ToString(lay.MODULE_TYPE       );
				let URL_FIELD         : string = Sql.ToString(lay.URL_FIELD         );
				let URL_MODULE        : string = Sql.ToString(lay.URL_MODULE        );
				let URL_ASSIGNED_FIELD: string = Sql.ToString(lay.URL_ASSIGNED_FIELD);
				let PARENT_FIELD      : string = Sql.ToString(lay.PARENT_FIELD      );
				// 01/06/2021 Paul.  inArray for data field, not hard coded ACTIVITY_TYPE. 
				if ( inArray(DATA_FIELD, arrSkippedFields) >= 0 || DATA_FIELD == 'ID' || EndsWith(DATA_FIELD, '_ID') || EndsWith(DATA_FIELD, '_ID_C') )
				{
					continue;
				}
				if ( sCOLUMN_TYPE == 'TemplateColumn' )
				{
					if ( DATA_FORMAT == 'HyperLink' )
					{
						if ( !Sql.IsEmptyString(DATA_FIELD) && inArray(DATA_FIELD, arrSelectFields) == -1 )
						{
							arrSelectFields.push(DATA_FIELD);
						}
					}
					else if ( DATA_FORMAT == 'Date' || DATA_FORMAT == 'DateTime' || DATA_FORMAT == 'Currency' )
					{
						if ( !Sql.IsEmptyString(DATA_FIELD) && inArray(DATA_FIELD, arrSelectFields) == -1 )
						{
							arrSelectFields.push(DATA_FIELD);
						}
					}
					else if ( DATA_FORMAT == 'Hover' )
					{
						let sURL_FIELD = Sql.ToString (lay.URL_FIELD);
						let arrURL_FIELD = sURL_FIELD.split(' ');
						for ( let i = 0; i < arrURL_FIELD.length; i++ )
						{
							let s = arrURL_FIELD[i];
							if ( s.indexOf('.') == -1 && s.length > 0 )
							{
								if ( inArray(s, arrSelectFields) == -1 )
								{
									arrSelectFields.push(s);
								}
							}
						}
					}
					else if ( DATA_FORMAT == 'Tags' )
					{
						if ( !Sql.IsEmptyString(DATA_FIELD) && inArray(DATA_FIELD, arrSelectFields) == -1 )
						{
							arrSelectFields.push(DATA_FIELD);
						}
					}
				}
				else if ( sCOLUMN_TYPE == 'BoundColumn' )
				{
					if ( !Sql.IsEmptyString(DATA_FIELD) && inArray(DATA_FIELD, arrSelectFields) == -1 )
					{
						arrSelectFields.push(DATA_FIELD);
					}
				}
				else if ( sCOLUMN_TYPE == 'Hidden' )
				{
					if ( !Sql.IsEmptyString(DATA_FIELD) && inArray(DATA_FIELD, arrSelectFields) == -1 )
					{
						arrSelectFields.push(DATA_FIELD);
					}
				}
			}
		}
		return arrSelectFields;
	}

	// https://github.com/ykdr2017/ts-deepcopy
	// https://stackoverflow.com/questions/35504310/deep-copy-an-array-in-angular-2-typescript
	static DeepCopy = <T>(target: T): T =>
	{
		if ( target === null )
		{
			return target;
		}
		if ( target instanceof Date )
		{
			return new Date(target.getTime()) as any;
		}
		if ( target instanceof Array )
		{
			const cp = [] as any[];
			(target as any[]).forEach((v) =>
			{
				cp.push(v);
			});
			return cp.map((n: any) => Sql.DeepCopy<any>(n)) as any;
		}
		if ( typeof target === 'object' && target !== {} )
		{
			const cp = { ...(target as { [key: string]: any }) } as { [key: string]: any };
			Object.keys(cp).forEach(k =>
			{
				cp[k] = Sql.DeepCopy<any>(cp[k]);
			});
			return cp as T;
		}
		return target;
	}
	
	static IsDataPrivacyErasedField(rdr: any, sFIELD_NAME: string)
	{
		let bIsErased: boolean = false;
		if ( Crm_Config.enable_data_privacy() )
		{
			if ( rdr['ERASED_FIELDS'] !== undefined )
			{
				let sERASED_FIELDS: string = Sql.ToString(rdr['ERASED_FIELDS']);
				if ( !Sql.IsEmptyString(sERASED_FIELDS) )
				{
					let arrFields: string[] = sERASED_FIELDS.split(',');
					bIsErased = (arrFields.indexOf(sFIELD_NAME) >= 0);
				}
			}
		}
		return bIsErased;
	}

	static DataPrivacyErasedPillElement()
	{
		let pill = React.createElement('span', {className: 'Erased'}, L10n.Term('DataPrivacy.LBL_ERASED_VALUE'));
		return pill
	}

	static DataPrivacyErasedField(rdr: any, sFIELD_NAME: string)
	{
		let sDISPLAY_NAME = null;
		if ( rdr != null )
		{
			sDISPLAY_NAME = Sql.ToString(rdr[sFIELD_NAME]);
			if ( Sql.IsEmptyString(sDISPLAY_NAME) )
			{
				if ( Sql.IsDataPrivacyErasedField(rdr, sFIELD_NAME) )
				{
					sDISPLAY_NAME = Sql.DataPrivacyErasedPillElement();
				}
			}
		}
		return sDISPLAY_NAME;
	}

	static SetPageTitle(MODULE_NAME, rdr: any, sFIELD_NAME: string)
	{
		let sTITLE: string = L10n.Term('.moduleList.' + MODULE_NAME);
		if ( rdr != null && sFIELD_NAME != null )
		{
			let sDISPLAY_NAME = Sql.ToString(rdr[sFIELD_NAME]);
			if ( Sql.IsEmptyString(sDISPLAY_NAME) )
			{
				if ( Sql.IsDataPrivacyErasedField(rdr, sFIELD_NAME) )
				{
					sDISPLAY_NAME = L10n.Term('DataPrivacy.LBL_ERASED_VALUE');
				}
			}
			if ( !Sql.IsEmptyString(sDISPLAY_NAME) )
			{
				sTITLE += ' - ' + sDISPLAY_NAME;
			}
		}
		document.title = sTITLE;
		// 04/26/2020 Paul.  Reset scroll every time we set the title. 
		window.scroll(0, 0);
	}

	static IsSQLServer(con: any): boolean
	{
		return true;
	}

	static IsOracle(con: any): boolean
	{
		return false;
	}

	static IsDB2(con: any): boolean
	{
		return false;
	}

	static IsMySQL(con: any): boolean
	{
		return false;
	}

	static IsPostgreSQL(con: any): boolean
	{
		return false;
	}

	static IsSybase(con: any): boolean
	{
		return false;
	}

	static IsSqlAnywhere(con: any): boolean
	{
		return false;
	}

	static IsEffiProz(con: any): boolean
	{
		return false;
	}

	static MetadataName(con: any, sNAME: string): string
	{
		// 09/02/2008 Paul.  Tables and field names in DB2 must be in uppercase. 
		// 09/02/2008 Paul.  Tables and field names in Oracle must be in uppercase. 
		// 11/27/2009 Paul.  Truncate Oracle names to 30 characters. 
		// 06/03/2010 Paul.  Substring will throw an exception if the length is less than the end. 
		if ( Sql.IsOracle(con) )
			return sNAME.toUpperCase().substr(0, Math.min(sNAME.length, 30));
		else if ( Sql.IsDB2(con) )
			return sNAME.toUpperCase();
		// 09/02/2008 Paul.  Tables and field names in PostgreSQL must be in uppercase. 
		else if ( Sql.IsPostgreSQL(con) )
			return sNAME.toUpperCase();
		// 09/02/2008 Paul.  SQL Server and MySQL are not typically case significant, 
		// but SQL Server can be configured to be case significant.  Ignore that case for now. 
		return sNAME;
	}

	static Space(nCount: number)
	{
		let s: string = '';
		for ( let i: number = 0; i < nCount; i++ )
		{
			s += ' ';
		}
		return s;
	}
}

