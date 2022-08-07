/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

import { Injectable                          } from '@angular/core'                      ;
import { CredentialsService                  } from '../scripts/Credentials'             ;

// 1. React and fabric. 
// 2. Store and Types. 
// 3. Scripts. 
import * as moment from 'moment';

@Injectable({
	providedIn: 'root'
})
export class FormattingService
{
	constructor(protected Credentials: CredentialsService)
	{
	}

	public formatDate(dtValue: any, sFormat: string)
	{
		if ( dtValue !== undefined && dtValue != null )
		{
			if ( dtValue instanceof Date && sFormat !== undefined && sFormat != null )
			{
				// 05/05/2013 Paul.  The FullCalendar has a better date formatting function. 
				// http://arshaw.com/fullcalendar/docs/utilities/formatDate/
				// 05/27/2018 Paul.  Moved local settings to credentials. 
				// http://momentjs.com/docs/#/i18n/changing-locale/
				//var options = 
				//	{ monthNames     : L10n.GetListTerms('month_names_dom'      )
				//	, monthNamesShort: L10n.GetListTerms('short_month_names_dom')
				//	, dayNames       : L10n.GetListTerms('day_names_dom'        )
				//	, dayNamesShort  : L10n.GetListTerms('short_day_names_dom'  )
				//	};
				// 05/18/2018 Paul.  Defer full calendar. 
				//return $.fullCalendar.formatDate(dtValue, sFormat, options);
				//return dtValue.toString();
				// http://momentjs.com/docs/#/displaying/
				// 03/20/2019 Paul.  A zero year should print as an empty string. 
				if ( dtValue.getFullYear() > 1 )
					return moment(dtValue).format(sFormat);
				else
					return '';
			}
			else
			{
				if ( moment.isMoment(dtValue) )
					return (dtValue as moment.Moment).format(sFormat);
				else
					return dtValue.toString();
			}
		}
		else
		{
			return '';
		}
	}

	// 01/20/2021 Paul.  FromJsonDate is used to parse and to format, but we need to treat them separately, so use another paramter. 
	public FromJsonDate(DATA_VALUE: any, sFormat?: string, sParseFormat?: string)
	{
		if ( typeof(DATA_VALUE) == 'string' && DATA_VALUE.substr(0, 7) == '\\/Date(' )
		{
			//alert(DATA_VALUE.substr(DATA_VALUE.length - 3, 3) + ' = ' + ')\\/');
			if ( DATA_VALUE.substr(DATA_VALUE.length - 3, 3) == ')\\/' )
			{
				DATA_VALUE = DATA_VALUE.substr(7, DATA_VALUE.length - 7 - 3);
				var utcTime = parseInt(DATA_VALUE);
				var dt = new Date(utcTime);
				// 08/28/2014 Paul.  SyncRest will return all dates as UTC and we store all dates as UTC in SQLite. 
				if ( !this.Credentials.bREMOTE_ENABLED )
				{
					var off = dt.getTimezoneOffset();
					dt.setMinutes(dt.getMinutes() + off);
				}
				if ( sFormat !== undefined )
					DATA_VALUE = this.formatDate(dt, sFormat);
				else
					DATA_VALUE = dt;
			}
		}
		else if ( typeof(DATA_VALUE) == 'object' )
		{
			if ( sFormat !== undefined )
				DATA_VALUE = this.formatDate(DATA_VALUE, sFormat);
			else if ( sParseFormat !== undefined )
				DATA_VALUE = moment(DATA_VALUE, sParseFormat).toDate();
		}
		// 01/20/2021 Paul.  Include format so that it can convert a text string. 
		else if ( typeof(DATA_VALUE) == 'string' )
		{
			if ( sParseFormat !== undefined )
				DATA_VALUE = moment(DATA_VALUE, sParseFormat).toDate();
		}
		return DATA_VALUE;
	}

	// http://weblogs.asp.net/bleroy/archive/2008/01/18/dates-and-json.aspx
	public ToJsonDate(dt: any)
	{
		var DATA_VALUE = null;
		if ( dt == null || dt === undefined )
			return DATA_VALUE;
		// 06/29/2020 Paul.  If already a Json date, then just return. 
		if ( typeof (dt) == 'string' && dt.substr(0, 7) === '\\/Date(' )
			return dt;
		// http://momentjs.com/docs/#/displaying/as-javascript-date/
		if ( dt._isAMomentObject )
		{
			if ( dt._isUTC )
			{
				DATA_VALUE = '\\/Date(' + dt.toDate().getTime() + ')\\/';
				return DATA_VALUE;
			}
			else
			{
				dt = dt.toDate();
			}
		}
		// 01/19/2013 Paul.  During testing, dt was not a valid date and threw an exception on getTimezoneOffset.  
		// 06/30/2020 Paul.  Also use instanceof in date check. 
		 if ( !isNaN(dt) && (dt instanceof Date || Object.prototype.toString.call(dt) === '[object Date]') )
		{
			// 02/21/2013 Paul.  First clone the date before modifying. 
			var temp = new Date(dt.getTime());
			// 08/28/2014 Paul.  SyncRest will return all dates as UTC and we store all dates as UTC in SQLite. 
			if ( !this.Credentials.bREMOTE_ENABLED )
			{
				var off = temp.getTimezoneOffset();
				temp.setMinutes(temp.getMinutes() - off);
			}
			// http://www.w3schools.com/jsref/jsref_obj_date.asp
			DATA_VALUE = '\\/Date(' + temp.getTime() + ')\\/';
		}
		return DATA_VALUE;
	}

	// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
	// https://www.customd.com/articles/14/jquery-number-format-redux
	public formatNumber(number: any, oNumberFormat: any)
	{
		number = (number + '').replace(/[^0-9+\-Ee.]/g, '');
		var n    = !isFinite(+number       ) ? 0 : +number;
		var prec = oNumberFormat.CurrencyDecimalDigits   ;
		var grp  = oNumberFormat.CurrencyGroupSizes      ;
		var sep  = oNumberFormat.CurrencyGroupSeparator  ;
		var dec  = oNumberFormat.CurrencyDecimalSeparator;
		var s    = null;
		s = (prec ? n.toFixed(prec) : '' + Math.round(n)).split('.');
		if ( s[0].length > grp )
		{
			var regex = new RegExp('\\B(?=(?:\\d{' + grp + '})+(?!\\d))', 'g');
			s[0] = s[0].replace(regex, sep);
		}
		if ( (s[1] || '').length > prec )
		{
			s[1] = s[1] || '';
			s[1] += new Array(prec - s[1].length + 1).join('0');
		}
		return s.join(dec);
	}

	private arrCurrencyNegativePattern: string[] = ['($n)', '-$n', '$-n', '$n-', '(n$)', '-n$', 'n-$', 'n$-', '-n $', '-$ n', 'n $-', '$ n-', '$ -n', 'n- $', '($ n)', '(n $)'];  // https://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.currencynegativepattern(v=vs.110).aspx
	private arrCurrencyPositivePattern: string[] = ['$n', 'n$', '$ n', 'n $'];  // https://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.currencypositivepattern.aspx

	public formatCurrency(number: any, oNumberFormat: any)
	{
		let n = !isFinite(+number) ? 0 : +number;
		let s = '';
		if ( n >= 0 )
		{
			s = this.formatNumber(number, oNumberFormat);
			s = this.arrCurrencyPositivePattern[oNumberFormat.CurrencyPositivePattern].replace('n', s).replace('$', oNumberFormat.CurrencySymbol);
		}
		else
		{
			// 01/06/2021 Paul.  The negative symbol will be provided by pattern. 
			s = this.formatNumber(-number, oNumberFormat);
			s = this.arrCurrencyNegativePattern[oNumberFormat.CurrencyNegativePattern].replace('n', s).replace('$', oNumberFormat.CurrencySymbol);
		}
		return s;
	}
}
