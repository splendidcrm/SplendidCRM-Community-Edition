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
import { IEditComponentProps, EditComponent } from '../types/EditComponent';
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'          ;
import L10n                                   from '../scripts/L10n'         ;
import Credentials                            from '../scripts/Credentials'  ;
import SplendidCache                          from '../scripts/SplendidCache';
import StringBuilder                          from '../scripts/StringBuilder';
import { Crm_Config }                         from '../scripts/Crm'          ;
import { Trim }                               from '../scripts/utility'      ;
// 4. Components and Views. 

interface ITextBoxState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	DATA_VALUE       : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	FORMAT_SIZE      : number;
	FORMAT_MAX_LENGTH: number;
	FORMAT_ROWS      : number;
	FORMAT_COLUMNS   : number;
	VALUE_MISSING    : boolean;
	ENABLED          : boolean;
	CSS_CLASS?       : string;

	FREQUENCY        : string;
	LIST_MINUTES     : number[];
	LIST_HOURS       : number[];
	LIST_DAYOFMONTH  : number[];
	LIST_DAYOFWEEK   : string[];
	LIST_MONTHS      : string[];
	MINUTES_VALUES   : string[];
	HOURS_VALUES     : string[];
	DAYOFMONTH_VALUES: string[];
	DAYOFWEEK_VALUES : boolean[];
	MONTH_VALUES     : boolean[];
	
	CRONShow         : boolean;
	CRON_MESSAGE     : string;
	CRON_MINUTES     : string;
	CRON_HOURS       : string;
	CRON_DAYOFMONTH  : string;
	CRON_MONTHS      : string;
	CRON_DAYOFWEEK   : string;
}

export default class CRON extends EditComponent<IEditComponentProps, ITextBoxState>
{
	private themeURL: string = null;

	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		// 06/30/2019 Paul.  Return null instead of empty string. 
		let key   = DATA_FIELD;
		let value = DATA_VALUE;
		if ( Sql.IsEmptyString(value) )
		{
			value = null;
		}
		return { key, value };
	}

	public validate(): boolean
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, VALUE_MISSING, ENABLED } = this.state;
		let bVALUE_MISSING: boolean = false;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.props.bIsHidden )
		{
			bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE);
			if ( bVALUE_MISSING != VALUE_MISSING )
			{
				this.setState({VALUE_MISSING: bVALUE_MISSING});
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
		// 08/09/2019 Paul.  An example of a text update is a Postal Code change updating, City, State and Country. 
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.setState({ DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'enabled' )
		{
			this.setState(
			{
				ENABLED: Sql.ToBoolean(DATA_VALUE)
			});
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.setState({ CSS_CLASS: DATA_VALUE });
		}
	}

	public clear(): void
	{
		const { ENABLED } = this.state;
		// 01/11/2020.  Apply Field Level Security. 
		if ( ENABLED )
		{
			// 02/02/2020 Paul.  input does not update when DATA_VALUE is set to null. 
			this.setState(
			{
				DATA_VALUE: ''
			});
		}
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';

		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let UI_REQUIRED      : boolean = null;
		let FORMAT_TAB_INDEX : number  = null;
		let FORMAT_SIZE      : number  = null;
		let FORMAT_MAX_LENGTH: number  = null;
		let FORMAT_ROWS      : number  = null;
		let FORMAT_COLUMNS   : number  = null;
		let ENABLED          : boolean = props.bIsWriteable;

		let FREQUENCY        : string   = 'Daily';
		let LIST_MINUTES     : number[] = [];
		let LIST_HOURS       : number[] = [];
		let LIST_DAYOFMONTH  : number[] = [];
		let LIST_DAYOFWEEK   : string[] = L10n.GetList('day_names_dom'  );
		let LIST_MONTHS      : string[] = L10n.GetList('month_names_dom');
		let MINUTES_VALUES   : string[] = [];
		let HOURS_VALUES     : string[] = [];
		let DAYOFMONTH_VALUES: string[] = [];
		let DAYOFWEEK_VALUES : boolean[] = [];
		let MONTH_VALUES     : boolean[] = [];

		let CRON_MESSAGE     : string = '';
		let CRON_MINUTES     : string = '*';
		let CRON_HOURS       : string = '*';
		let CRON_DAYOFMONTH  : string = '*';
		let CRON_MONTHS      : string = '*';
		let CRON_DAYOFWEEK   : string = '*';
		for ( let i: number = 0; i < 60; i += 5 )
		{
			LIST_MINUTES.push(i);
		}
		for ( let i: number = 0; i < 24; i++ )
		{
			LIST_HOURS.push(i);
		}
		for ( let i: number = 0; i < 31; i++ )
		{
			LIST_DAYOFMONTH.push(i + 1);
		}
		for ( let i: number = 0; i < LIST_DAYOFWEEK.length; i++ )
		{
			DAYOFWEEK_VALUES.push(false);
		}
		for ( let i: number = 0; i < LIST_MONTHS.length; i++ )
		{
			MONTH_VALUES.push(false);
		}

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this.props;
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
				ID = baseId + '_' + DATA_FIELD;

				DATA_VALUE = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
				if ( row != null )
				{
					DATA_VALUE = Sql.ToString(this.getValue(layout, row, DATA_FIELD));
					let arrDATA_VALUE = DATA_VALUE.split('::');
					if ( arrDATA_VALUE.length > 0 ) CRON_MINUTES    = arrDATA_VALUE[0];
					if ( arrDATA_VALUE.length > 1 ) CRON_HOURS      = arrDATA_VALUE[1];
					if ( arrDATA_VALUE.length > 2 ) CRON_DAYOFMONTH = arrDATA_VALUE[2];
					if ( arrDATA_VALUE.length > 3 ) CRON_MONTHS     = arrDATA_VALUE[3];
					if ( arrDATA_VALUE.length > 4 ) CRON_DAYOFWEEK  = arrDATA_VALUE[4];
				}
				FREQUENCY         = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
				MINUTES_VALUES    = this.SetCronSelectValue    (CRON_MINUTES   , LIST_MINUTES   );
				HOURS_VALUES      = this.SetCronSelectValue    (CRON_HOURS     , LIST_HOURS     );
				DAYOFMONTH_VALUES = this.SetCronSelectValue    (CRON_DAYOFMONTH, LIST_DAYOFMONTH);
				DAYOFWEEK_VALUES  = this.SetCronCheckboxesValue(CRON_DAYOFWEEK ,  7, 0);
				MONTH_VALUES      = this.SetCronCheckboxesValue(CRON_MONTHS    , 12, 1);
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		CRON_MESSAGE = CRON.CronDescription(DATA_VALUE);
		this.state =
		{
			ID               ,
			FIELD_INDEX      ,
			DATA_FIELD       ,
			DATA_VALUE       ,
			UI_REQUIRED      ,
			FORMAT_TAB_INDEX ,
			FORMAT_SIZE      ,
			FORMAT_MAX_LENGTH,
			FORMAT_ROWS      ,
			FORMAT_COLUMNS   ,
			VALUE_MISSING    : false,
			ENABLED          ,
			
			FREQUENCY        ,
			LIST_MINUTES     ,
			LIST_HOURS       ,
			LIST_DAYOFMONTH  ,
			LIST_DAYOFWEEK   ,
			LIST_MONTHS      ,
			MINUTES_VALUES   ,
			HOURS_VALUES     ,
			DAYOFMONTH_VALUES,
			DAYOFWEEK_VALUES ,
			MONTH_VALUES     ,
			
			CRONShow         : false,
			CRON_MESSAGE     ,
			CRON_MINUTES     ,
			CRON_HOURS       ,
			CRON_DAYOFMONTH  ,
			CRON_MONTHS      ,
			CRON_DAYOFWEEK   ,
		};
		//document.components[sID] = this;
	}

	componentDidCatch(error, info)
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch ' + DATA_FIELD, error, info);
	}

	// As soon as the render method has been executed the componentDidMount function is called. 
	async componentDidMount()
	{
		const { DATA_FIELD } = this.state;
		if ( this.props.fieldDidMount )
		{
			this.props.fieldDidMount(DATA_FIELD, this);
		}
	}

	// shouldComponentUpdate is not used with a PureComponent
	/*
	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: ITextBoxState)
	{
		const { DATA_FIELD, DATA_VALUE, VALUE_MISSING, ENABLED } = this.state;
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
		else if ( nextState.DATA_VALUE != this.state.DATA_VALUE )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.VALUE_MISSING != this.state.VALUE_MISSING || nextState.ENABLED != this.state.ENABLED )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, VALUE_MISSING, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		return false;
	}
	*/

	/*
	// Finally componentDidUpdate is called after the render method.
	componentDidUpdate(prevProps: IEditComponentProps, prevState: ITextBoxState)
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { DATA_FIELD, DATA_VALUE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate ' + DATA_FIELD, DATA_VALUE, prevProps, prevState);
		if ( prevProps.row != null && prevProps.row.ID === undefined )
		{
			let DATA_VALUE: string = this.getValue(layout, row, DATA_FIELD);
			// 06/03/2018 Paul.  Don't update state if it has not changed. 
			if ( DATA_VALUE != this.state.DATA_VALUE )
				this.setState({ DATA_VALUE: DATA_VALUE });
		}
	}
	*/

	private getValue = (layout: any, row: any, DATA_FIELD: string): string =>
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

	private BuildCronSelectValue = (arrVALUES: string[], arrLIST: number[]): string =>
	{
		let sb          = new StringBuilder();
		let nStart      = -1;
		let nEnd        = -1;
		let bRangeStart = false;
		for ( let i = 0; i < arrLIST.length; i++ )
		{
			let item    : string = arrLIST[i].toString();
			let selected: boolean = false;
			for ( let j = 0; j < arrVALUES.length; j++ )
			{
				if ( arrVALUES[j] == item )
				{
					selected = true;
					break;
				}
			}
			if ( selected )
			{
				if ( !bRangeStart )
				{
					nStart      = i;
					nEnd        = i;
					bRangeStart = true;
				}
				else
				{
					nEnd = i;
				}
			}
			else if ( bRangeStart )
			{
				if ( sb.length > 0 )
					sb.Append(',');
				if ( nEnd > nStart )
					sb.Append(arrLIST[nStart].toString() + "-" + arrLIST[nEnd].toString());
				else
					sb.Append(arrLIST[nStart].toString());
				nStart      = -1;
				nEnd        = -1;
				bRangeStart = false;
			}
		}
		if ( bRangeStart )
		{
			if ( sb.length > 0 )
				sb.Append(',');
			if ( nEnd > nStart )
				sb.Append(arrLIST[nStart].toString() + "-" + arrLIST[nEnd].toString());
			else
				sb.Append(arrLIST[nStart].toString());
			nStart      = -1;
			nEnd        = -1;
			bRangeStart = false;
		}
		return sb.toString();
	}

	private BuildCronCheckboxesValue = (arrVALUES, nMaxItems, nOffset) =>
	{
		let sb          = new StringBuilder();
		let nStart      = -1;
		let nEnd        = -1;
		let bRangeStart = false;
		let options = new Array();
		for ( let i = 0; i < nMaxItems; i++ )
		{
			options.push(i + nOffset);
		}
		for ( let i = 0; i < nMaxItems; i++ )
		{
			if ( arrVALUES[i] )
			{
				if ( !bRangeStart )
				{
					nStart = i;
					nEnd = i;
					bRangeStart = true;
				}
				else
				{
					nEnd = i;
				}
			}
			else if ( bRangeStart )
			{
				if ( sb.length > 0 )
					sb.Append(',');
				if ( nEnd > nStart )
					sb.Append(options[nStart] + "-" + options[nEnd]);
				else
					sb.Append(options[nStart]);
				nStart = -1;
				nEnd = -1;
				bRangeStart = false;
			}
		}
		if ( bRangeStart )
		{
			if ( sb.length > 0 )
				sb.Append(',');
			if ( nEnd > nStart )
				sb.Append(options[nStart] + "-" + options[nEnd]);
			else
				sb.Append(options[nStart]);
			nStart = -1;
			nEnd = -1;
			bRangeStart = false;
		}
		return sb.toString();
	}

	private SetCronSelectValue = (sValue: string, arrLIST: number[]): string[] =>
	{
		let arrVALUES: string[] = [];
		if ( sValue == '*' )
		{
			for ( let i = 0; i < arrLIST.length; i++ )
			{
				let item: string = arrLIST[i].toString();
				arrVALUES.push(item);
			}
		}
		else
		{
			var arrCommaSep = sValue.split(',');
			for ( let n in arrCommaSep )
			{
				let arrRange = arrCommaSep[n].split( '-' );
				if ( arrRange.length > 1 )
				{
					let nStart = parseInt(arrRange[0], 10);
					let nEnd   = parseInt(arrRange[1], 10);
					// 01/15/2024 Paul.  use isNaN() instead. 
					if ( !isNaN(nStart) && !isNaN(nEnd) )
					{
						if ( nStart <= nEnd )
						{
							for ( let nParam = nStart; nParam <= nEnd; nParam++ )
							{
								let sParam: string = nParam.toString();
								arrVALUES.push(sParam);
							}
						}
					}
				}
				else
				{
					let nParam = parseInt(arrRange[0], 10);
					// 01/15/2024 Paul.  use isNaN() instead. 
					if ( !isNaN(nParam) )
					{
						let sParam: string = nParam.toString();
						arrVALUES.push(sParam);
					}
				}
			}
		}
		return arrVALUES;
	}

	private SetCronCheckboxesValue = (sValue, nMaxItems, nOffset): boolean[] =>
	{
		let arrVALUES: boolean[] = [];
		if ( sValue == '*' )
		{
			for ( let i = 0; i < nMaxItems; i++ )
			{
				arrVALUES[i] = true;
			}
		}
		else
		{
			for ( let i = 0; i < nMaxItems; i++ )
			{
				arrVALUES[i] = false;
			}
			let arrCommaSep = sValue.split(',');
			for ( let n in arrCommaSep )
			{
				let arrRange = arrCommaSep[n].split( '-' );
				if ( arrRange.length > 1 )
				{
					let nStart = parseInt(arrRange[0], 10);
					let nEnd   = parseInt(arrRange[1], 10);
					// 01/15/2024 Paul.  use isNaN() instead. 
					if ( !isNaN(nStart) && !isNaN(nEnd) )
					{
						if ( nStart <= nEnd )
						{
							// 01/19/2024 Paul.  Include end value 
							for ( let nParam = nStart; nParam <= nEnd; nParam++ )
							{
								if ( nParam - nOffset >= 0 )
								{
									arrVALUES[nParam - nOffset] = true;
								}
							}
						}
					}
				}
				else
				{
					let nParam = parseInt(arrRange[0], 10);
					// 01/15/2024 Paul.  use isNaN() instead. 
					if ( !isNaN(nParam) )
					{
						if ( nParam - nOffset >= 0 )
						{
							arrVALUES[nParam - nOffset] = true;
						}
					}
				}
			}
		}
		return arrVALUES;
	}

	public static CronDescription = (sCRON) =>
	{
		if ( sCRON == "*::*::*::*::*" )
			return L10n.Term("Schedulers.LBL_OFTEN");
		try
		{
			let arrMonthNames     = L10n.GetListTerms('scheduler_month_dom');
			let arrDayNames       = L10n.GetListTerms('scheduler_day_dom'  );
			let sb                = new StringBuilder();
			let sCRON_MONTH       = "*";
			let sCRON_DAYOFMONTH  = "*";
			let sCRON_DAYOFWEEK   = "*";
			let sCRON_HOUR        = "*";
			let sCRON_MINUTE      = "*";
			let arrCRON           = sCRON.split('::');
			let arrCRON_TEMP      = new Array();
			let arrCRON_VALUE     = new Array();
			let arrDaySuffixes    = new Array();
			let nCRON_VALUE       = 0;
			let nCRON_VALUE_START = 0;
			let nCRON_VALUE_END   = 0;
			let nON_THE_MINUTE    = -1;
			for ( let n = 0; n < 32; n++ )
				arrDaySuffixes.push("th");
			arrDaySuffixes[0] = "";
			arrDaySuffixes[1] = "st";
			arrDaySuffixes[2] = "nd";
			arrDaySuffixes[3] = "rd";

			// minute  hour  dayOfMonth  month  dayOfWeek
			if ( arrCRON.length > 0 ) sCRON_MINUTE     = arrCRON[0];
			if ( arrCRON.length > 1 ) sCRON_HOUR       = arrCRON[1];
			if ( arrCRON.length > 2 ) sCRON_DAYOFMONTH = arrCRON[2];
			if ( arrCRON.length > 3 ) sCRON_MONTH      = arrCRON[3];
			if ( arrCRON.length > 4 ) sCRON_DAYOFWEEK  = arrCRON[4];
			if ( sCRON_MINUTE != "*" )
			{
				arrCRON_TEMP = sCRON_MINUTE.split(',');
				// 12/31/2007 Paul.  Check for either comma or dash. 
				if ( sCRON_MINUTE.split(",-").length == 1 )
				{
					nON_THE_MINUTE = Sql.ToInteger(sCRON_MINUTE);
					sb.Append(L10n.Term("Schedulers.LBL_ON_THE"));
					// 05/23/2013 Paul.  Just in case there is no space in the LBL_ON_THE term, add a space. 
					sb.Append(" ");
					if ( nON_THE_MINUTE == 0 )
					{
						sb.Append(L10n.Term("Schedulers.LBL_HOUR_SING"));
					}
					else
					{
						sb.Append((nON_THE_MINUTE < 10 ? '0' : '') + nON_THE_MINUTE.toString());
						// 05/23/2013 Paul.  Just in case there is no space in the LBL_MIN_MARK term, add a space. 
						sb.Append(" ");
						sb.Append(L10n.Term("Schedulers.LBL_MIN_MARK"));
					}
				}
				else
				{
					for ( var i = 0, nCronEntries = 0; i < arrCRON_TEMP.length; i++ )
					{
						if ( arrCRON_TEMP[i].indexOf('-') >= 0 )
						{
							arrCRON_VALUE = arrCRON_TEMP[i].split('-');
							if ( arrCRON_VALUE.length >= 2 )
							{
								nCRON_VALUE_START = Sql.ToInteger(arrCRON_VALUE[0]);
								nCRON_VALUE_END   = Sql.ToInteger(arrCRON_VALUE[1]);
								// 06/26/2010 Paul.  Minutes should range between 0 and 59. 
								if ( nCRON_VALUE_START >= 0 && nCRON_VALUE_START <= 59 && nCRON_VALUE_END >= 0 && nCRON_VALUE_END <= 59 )
								{
									if ( nCronEntries > 0 )
										sb.Append(L10n.Term("Schedulers.LBL_AND"));
									sb.Append(L10n.Term("Schedulers.LBL_FROM"));
									sb.Append(L10n.Term("Schedulers.LBL_ON_THE"));
									// 05/23/2013 Paul.  Just in case there is no space in the LBL_ON_THE term, add a space. 
									sb.Append(" ");
									if ( nCRON_VALUE_START == 0 )
									{
										sb.Append(L10n.Term("Schedulers.LBL_HOUR_SING"));
									}
									else
									{
										sb.Append(nCRON_VALUE_START.toString());
										// 05/23/2013 Paul.  Just in case there is no space in the LBL_MIN_MARK term, add a space. 
										sb.Append(" ");
										sb.Append(L10n.Term("Schedulers.LBL_MIN_MARK"));
									}
									sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
									sb.Append(L10n.Term("Schedulers.LBL_ON_THE"));
									// 05/23/2013 Paul.  Just in case there is no space in the LBL_ON_THE term, add a space. 
									sb.Append(" ");
									sb.Append(nCRON_VALUE_END.toString());
									// 05/23/2013 Paul.  Just in case there is no space in the LBL_MIN_MARK term, add a space. 
									sb.Append(" ");
									sb.Append(L10n.Term("Schedulers.LBL_MIN_MARK"));
									nCronEntries++;
								}
							}
						}
						else
						{
							nCRON_VALUE = Sql.ToInteger(arrCRON_TEMP[i]);
							// 06/26/2010 Paul.  Minutes should range between 0 and 59. 
							if ( nCRON_VALUE >= 0 && nCRON_VALUE <= 59 )
							{
								if ( nCronEntries > 0 )
									sb.Append(L10n.Term("Schedulers.LBL_AND"));
								sb.Append(L10n.Term("Schedulers.LBL_ON_THE"));
								// 05/23/2013 Paul.  Just in case there is no space in the LBL_ON_THE term, add a space. 
								sb.Append(" ");
								if ( nCRON_VALUE == 0 )
								{
									sb.Append(L10n.Term("Schedulers.LBL_HOUR_SING"));
								}
								else
								{
									sb.Append(nCRON_VALUE.toString());
									// 05/23/2013 Paul.  Just in case there is no space in the LBL_MIN_MARK term, add a space. 
									sb.Append(" ");
									sb.Append(L10n.Term("Schedulers.LBL_MIN_MARK"));
								}
								nCronEntries++;
							}
						}
					}
				}
			}
			if ( sCRON_HOUR != "*" )
			{
				if ( sb.length > 0 )
					sb.Append("; ");
				arrCRON_TEMP = sCRON_HOUR.split(',');
				for ( var i = 0, nCronEntries = 0; i < arrCRON_TEMP.length; i++ )
				{
					if ( arrCRON_TEMP[i].indexOf('-') >= 0 )
					{
						arrCRON_VALUE = arrCRON_TEMP[i].split('-');
						if ( arrCRON_VALUE.length >= 2 )
						{
							nCRON_VALUE_START = Sql.ToInteger(arrCRON_VALUE[0]);
							nCRON_VALUE_END   = Sql.ToInteger(arrCRON_VALUE[1]);
							// 06/26/2010 Paul.  Hours should range between 0 and 23. 
							if ( nCRON_VALUE_START >= 0 && nCRON_VALUE_START <= 23 && nCRON_VALUE_END >= 0 && nCRON_VALUE_END <= 23 )
							{
								if ( nCronEntries > 0 )
									sb.Append(L10n.Term("Schedulers.LBL_AND"));
								sb.Append(L10n.Term("Schedulers.LBL_FROM"));
								sb.Append(arrCRON_VALUE[0]);
								if ( nON_THE_MINUTE >= 0 )
									sb.Append(":" + (nON_THE_MINUTE < 10 ? '0' : '') + nON_THE_MINUTE);
								sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
								sb.Append(arrCRON_VALUE[1]);
								if ( nON_THE_MINUTE >= 0 )
									sb.Append(":" + (nON_THE_MINUTE < 10 ? '0' : '') + nON_THE_MINUTE);
								nCronEntries++;
							}
						}
					}
					else
					{
						nCRON_VALUE = Sql.ToInteger(arrCRON_TEMP[i]);
						// 06/26/2010 Paul.  Hours should range between 0 and 23. 
						if ( nCRON_VALUE >= 0 && nCRON_VALUE <= 23 )
						{
							if ( nCronEntries > 0 )
								sb.Append(L10n.Term("Schedulers.LBL_AND"));
							sb.Append(arrCRON_TEMP[i]);
							if ( nON_THE_MINUTE >= 0 )
								sb.Append(":" + (nON_THE_MINUTE < 10 ? '0' : '') + nON_THE_MINUTE);
							nCronEntries++;
						}
					}
				}
			}
			if ( sCRON_DAYOFMONTH != "*" )
			{
				if ( sb.length > 0 )
					sb.Append("; ");
				arrCRON_TEMP = sCRON_DAYOFMONTH.split(',');
				for ( var i = 0, nCronEntries = 0; i < arrCRON_TEMP.length; i++ )
				{
					if ( arrCRON_TEMP[i].indexOf('-') >= 0 )
					{
						arrCRON_VALUE = arrCRON_TEMP[i].split('-');
						if ( arrCRON_VALUE.length >= 2 )
						{
							nCRON_VALUE_START = Sql.ToInteger(arrCRON_VALUE[0]);
							nCRON_VALUE_END   = Sql.ToInteger(arrCRON_VALUE[1]);
							if ( nCRON_VALUE_START >= 1 && nCRON_VALUE_START <= 31 && nCRON_VALUE_END >= 1 && nCRON_VALUE_END <= 31 )
							{
								if ( nCronEntries > 0 )
									sb.Append(L10n.Term("Schedulers.LBL_AND"));
								sb.Append(L10n.Term("Schedulers.LBL_FROM"));
								sb.Append(nCRON_VALUE_START.toString() + arrDaySuffixes[nCRON_VALUE_START]);
								sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
								sb.Append(nCRON_VALUE_END.toString() + arrDaySuffixes[nCRON_VALUE_END]);
								nCronEntries++;
							}
						}
					}
					else
					{
						nCRON_VALUE = Sql.ToInteger(arrCRON_TEMP[i]);
						if ( nCRON_VALUE >= 1 && nCRON_VALUE <= 31 )
						{
							if ( nCronEntries > 0 )
								sb.Append(L10n.Term("Schedulers.LBL_AND"));
							sb.Append(nCRON_VALUE.toString() + arrDaySuffixes[nCRON_VALUE]);
							nCronEntries++;
						}
					}
				}
			}
			if ( sCRON_MONTH != "*" )
			{
				if ( sb.length > 0 )
					sb.Append("; ");
				arrCRON_TEMP = sCRON_MONTH.split(',');
				for ( var i = 0, nCronEntries = 0; i < arrCRON_TEMP.length; i++ )
				{
					if ( arrCRON_TEMP[i].indexOf('-') >= 0 )
					{
						arrCRON_VALUE = arrCRON_TEMP[i].split('-');
						if ( arrCRON_VALUE.length >= 2 )
						{
							nCRON_VALUE_START = Sql.ToInteger(arrCRON_VALUE[0]);
							nCRON_VALUE_END   = Sql.ToInteger(arrCRON_VALUE[1]);
							if ( nCRON_VALUE_START >= 1 && nCRON_VALUE_START <= 12 && nCRON_VALUE_END >= 1 && nCRON_VALUE_END <= 12 )
							{
								if ( nCronEntries > 0 )
									sb.Append(L10n.Term("Schedulers.LBL_AND"));
								sb.Append(L10n.Term("Schedulers.LBL_FROM"));
								// 08/17/2012 Paul.  LBL_FROM should have a trailing space, but it does not so fix here. 
								sb.Append(" ");
								// 08/17/2012 Paul.  Month names are 0 based. 
								sb.Append(arrMonthNames[nCRON_VALUE_START - 1]);
								sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
								sb.Append(arrMonthNames[nCRON_VALUE_END - 1]);
								nCronEntries++;
							}
						}
					}
					else
					{
						nCRON_VALUE = Sql.ToInteger(arrCRON_TEMP[i]);
						if ( nCRON_VALUE >= 1 && nCRON_VALUE <= 12 )
						{
							if ( nCronEntries > 0 )
								sb.Append(L10n.Term("Schedulers.LBL_AND"));
							// 08/17/2012 Paul.  Month names are 0 based. 
							sb.Append(arrMonthNames[nCRON_VALUE - 1]);
							nCronEntries++;
						}
					}
				}
			}
			if ( sCRON_DAYOFWEEK != "*" )
			{
				if ( sb.length > 0 )
					sb.Append("; ");
				arrCRON_TEMP = sCRON_DAYOFWEEK.split(',');
				for ( var i = 0, nCronEntries = 0; i < arrCRON_TEMP.length; i++ )
				{
					if ( arrCRON_TEMP[i].indexOf('-') >= 0 )
					{
						arrCRON_VALUE = arrCRON_TEMP[i].split('-');
						if ( arrCRON_VALUE.length >= 2 )
						{
							nCRON_VALUE_START = Sql.ToInteger(arrCRON_VALUE[0]);
							nCRON_VALUE_END   = Sql.ToInteger(arrCRON_VALUE[1]);
							if ( nCRON_VALUE_START >= 0 && nCRON_VALUE_START <= 6 && nCRON_VALUE_END >= 0 && nCRON_VALUE_END <= 6 )
							{
								if ( nCronEntries > 0 )
									sb.Append(L10n.Term("Schedulers.LBL_AND"));
								sb.Append(L10n.Term("Schedulers.LBL_FROM"));
								sb.Append(arrDayNames[nCRON_VALUE_START]);
								sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
								sb.Append(arrDayNames[nCRON_VALUE_END]);
								nCronEntries++;
							}
						}
					}
					else
					{
						nCRON_VALUE = Sql.ToInteger(arrCRON_TEMP[i]);
						if ( nCRON_VALUE >= 0 && nCRON_VALUE <= 6 )
						{
							if ( nCronEntries > 0 )
								sb.Append(L10n.Term("Schedulers.LBL_AND"));
							sb.Append(arrDayNames[nCRON_VALUE]);
							nCronEntries++;
						}
					}
				}
			}
			return sb.toString();
		}
		catch(e)
		{
			return e.message;
		}
	}

	private _onChange = (e): void =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, ENABLED } = this.state;
		let value = e.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				this.setState({ DATA_VALUE: value }, this.validate);
				onChanged(DATA_FIELD, value);
				onUpdate (DATA_FIELD, value);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onKeyDown = (event) =>
	{
		const { onSubmit } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' && onSubmit != null )
		{
			onSubmit();
		}
	}

	private _onToggleCRONShow = (e) =>
	{
		e.preventDefault();
		this.setState({ CRONShow: !this.state.CRONShow });
	}

	private _onFREQUENCY = (value) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD, LIST_MINUTES, LIST_HOURS, LIST_DAYOFMONTH } = this.state;
		let { FREQUENCY } = this.state;
		if ( value != FREQUENCY )
		{
			FREQUENCY = value;

			let CRON_MINUTES   : string = this.state.CRON_MINUTES   ;
			let CRON_HOURS     : string = this.state.CRON_HOURS     ;
			let CRON_DAYOFMONTH: string = this.state.CRON_DAYOFMONTH;
			let CRON_MONTHS    : string = this.state.CRON_MONTHS    ;
			let CRON_DAYOFWEEK : string = this.state.CRON_DAYOFWEEK ;
			switch ( FREQUENCY )
			{
				case 'Daily':
					CRON_MINUTES    = '0';
					CRON_HOURS      =  (new Date()).getHours().toString();
					CRON_DAYOFMONTH = '*';
					CRON_MONTHS     = '*';
					CRON_DAYOFWEEK  = '*';
					break;
				case 'Weekly':
					CRON_MINUTES    = '0';
					CRON_HOURS      = (new Date()).getHours().toString();
					CRON_DAYOFMONTH = '*';
					CRON_MONTHS     = '*';
					CRON_DAYOFWEEK  = (new Date()).getDay().toString();
					break;
				case 'Monthly':
					CRON_DAYOFMONTH = (new Date()).getDate().toString();
					CRON_MONTHS     = '*';
					CRON_DAYOFWEEK  = '*';
					break;
				case 'Yearly':
					CRON_DAYOFMONTH =  (new Date()).getDate().toString();
					CRON_MONTHS     = ((new Date()).getMonth() + 1).toString();
					CRON_DAYOFWEEK  = '*';
					break;
			}
			let MINUTES_VALUES   : string[]  = this.SetCronSelectValue    (CRON_MINUTES   , LIST_MINUTES   );
			let HOURS_VALUES     : string[]  = this.SetCronSelectValue    (CRON_HOURS     , LIST_HOURS     );
			let DAYOFMONTH_VALUES: string[]  = this.SetCronSelectValue    (CRON_DAYOFMONTH, LIST_DAYOFMONTH);
			let DAYOFWEEK_VALUES : boolean[] = this.SetCronCheckboxesValue(CRON_DAYOFWEEK ,  7, 0);
			let MONTH_VALUES     : boolean[] = this.SetCronCheckboxesValue(CRON_MONTHS    , 12, 1);

			let DATA_VALUE     : string = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
			let CRON_MESSAGE   : string = CRON.CronDescription(DATA_VALUE);
			this.setState({ DATA_VALUE, FREQUENCY, CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK, MINUTES_VALUES, HOURS_VALUES, DAYOFMONTH_VALUES, DAYOFWEEK_VALUES, MONTH_VALUES, CRON_MESSAGE });
			onChanged(DATA_FIELD, DATA_VALUE);
			onUpdate (DATA_FIELD, DATA_VALUE);
		}
	}

	private _onMINUTES = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let { MINUTES_VALUES } = this.state;
		MINUTES_VALUES = [];
		let selectedOptions = event.target.selectedOptions;
		for (let i = 0; i < selectedOptions.length; i++)
		{
			MINUTES_VALUES.push(selectedOptions[i].value);
		}

		let CRON_MINUTES   : string = this.BuildCronSelectValue(MINUTES_VALUES, this.state.LIST_MINUTES);
		let CRON_HOURS     : string = this.state.CRON_HOURS     ;
		let CRON_DAYOFMONTH: string = this.state.CRON_DAYOFMONTH;
		let CRON_MONTHS    : string = this.state.CRON_MONTHS    ;
		let CRON_DAYOFWEEK : string = this.state.CRON_DAYOFWEEK ;

		let DATA_VALUE     : string = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
		let FREQUENCY      : string = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
		let CRON_MESSAGE   : string = CRON.CronDescription(DATA_VALUE);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMINUTES ' + CRON_MINUTES);
		this.setState({ DATA_VALUE, FREQUENCY, CRON_MINUTES, CRON_MESSAGE, MINUTES_VALUES });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	private _onHOURS = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let { HOURS_VALUES } = this.state;
		HOURS_VALUES = [];
		let selectedOptions = event.target.selectedOptions;
		for (let i = 0; i < selectedOptions.length; i++)
		{
			HOURS_VALUES.push(selectedOptions[i].value);
		}

		let CRON_MINUTES   : string = this.state.CRON_MINUTES   ;
		let CRON_HOURS     : string = this.BuildCronSelectValue(HOURS_VALUES, this.state.LIST_HOURS);
		let CRON_DAYOFMONTH: string = this.state.CRON_DAYOFMONTH;
		let CRON_MONTHS    : string = this.state.CRON_MONTHS    ;
		let CRON_DAYOFWEEK : string = this.state.CRON_DAYOFWEEK ;

		let DATA_VALUE     : string = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
		let FREQUENCY      : string = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
		let CRON_MESSAGE   : string = CRON.CronDescription(DATA_VALUE);
		this.setState({ DATA_VALUE, FREQUENCY, CRON_HOURS, CRON_MESSAGE, HOURS_VALUES });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	private _onDAYOFMONTH = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let { DAYOFMONTH_VALUES } = this.state;
		DAYOFMONTH_VALUES = [];
		let selectedOptions = event.target.selectedOptions;
		for (let i = 0; i < selectedOptions.length; i++)
		{
			DAYOFMONTH_VALUES.push(selectedOptions[i].value);
		}

		let CRON_MINUTES   : string = this.state.CRON_MINUTES   ;
		let CRON_HOURS     : string = this.state.CRON_HOURS     ;
		let CRON_DAYOFMONTH: string = this.BuildCronSelectValue(DAYOFMONTH_VALUES, this.state.LIST_DAYOFMONTH);
		let CRON_MONTHS    : string = this.state.CRON_MONTHS    ;
		let CRON_DAYOFWEEK : string = this.state.CRON_DAYOFWEEK ;
		if ( CRON_DAYOFMONTH == '1-31' || CRON_DAYOFMONTH == '' )
			CRON_DAYOFMONTH = '*';

		let DATA_VALUE     : string = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
		let FREQUENCY      : string = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
		let CRON_MESSAGE   : string = CRON.CronDescription(DATA_VALUE);
		this.setState({ DATA_VALUE, FREQUENCY, CRON_DAYOFMONTH, CRON_MESSAGE, DAYOFMONTH_VALUES });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	private _onDAYOFWEEK = (ev: React.ChangeEvent<HTMLInputElement>, index: number) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let { DAYOFWEEK_VALUES } = this.state;
		DAYOFWEEK_VALUES[index] = ev.target.checked;

		let CRON_MINUTES   : string = this.state.CRON_MINUTES   ;
		let CRON_HOURS     : string = this.state.CRON_HOURS     ;
		let CRON_DAYOFMONTH: string = this.state.CRON_DAYOFMONTH;
		let CRON_MONTHS    : string = this.state.CRON_MONTHS    ;
		let CRON_DAYOFWEEK : string = this.BuildCronCheckboxesValue(DAYOFWEEK_VALUES, 7, 0);
		if ( CRON_DAYOFWEEK == '0-6' || CRON_DAYOFWEEK == '' )
			CRON_DAYOFWEEK = '*';

		let DATA_VALUE     : string = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
		let FREQUENCY      : string = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
		let CRON_MESSAGE   : string = CRON.CronDescription(DATA_VALUE);
		this.setState({ DATA_VALUE, FREQUENCY, CRON_DAYOFWEEK, CRON_MESSAGE, DAYOFWEEK_VALUES });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	private _onMONTH = (ev: React.ChangeEvent<HTMLInputElement>, index: number) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let { MONTH_VALUES } = this.state;
		MONTH_VALUES[index] = ev.target.checked;
		let CRON_MINUTES   : string = this.state.CRON_MINUTES   ;
		let CRON_HOURS     : string = this.state.CRON_HOURS     ;
		let CRON_DAYOFMONTH: string = this.state.CRON_DAYOFMONTH;
		let CRON_MONTHS    : string = this.BuildCronCheckboxesValue(MONTH_VALUES, 12, 1);
		let CRON_DAYOFWEEK : string = this.state.CRON_DAYOFWEEK ;
		if ( CRON_MONTHS == '1-12' || CRON_MONTHS == '' )
			CRON_MONTHS = '*';

		let DATA_VALUE     : string = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
		let FREQUENCY      : string = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
		let CRON_MESSAGE   : string = CRON.CronDescription(DATA_VALUE);
		this.setState({ DATA_VALUE, FREQUENCY, CRON_DAYOFWEEK, CRON_MESSAGE, MONTH_VALUES });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	private CronFrequency = (CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK) =>
	{
		let FREQUENCY: string = '';
		if ( CRON_DAYOFMONTH == '*' && CRON_DAYOFWEEK == '*' && CRON_MONTHS == '*' )
		{
			FREQUENCY = 'Daily';
		}
		else if ( CRON_DAYOFMONTH == '*' && CRON_DAYOFWEEK != '*' && CRON_MONTHS == '*' )
		{
			FREQUENCY = 'Weekly';
		}
		else if ( CRON_DAYOFMONTH != '*' && CRON_DAYOFWEEK == '*' && CRON_MONTHS == '*' )
		{
			FREQUENCY = 'Monthly';
		}
		else if ( CRON_DAYOFMONTH != '*' && CRON_DAYOFWEEK == '*' && CRON_MONTHS != '*' )
		{
			FREQUENCY = 'Yearly';
		}
		return FREQUENCY;
	}

	private _onChangeCRON_MINUTES = (e) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let CRON_MINUTES   : string = Trim(e.target.value)      ;
		let CRON_HOURS     : string = this.state.CRON_HOURS     ;
		let CRON_DAYOFMONTH: string = this.state.CRON_DAYOFMONTH;
		let CRON_MONTHS    : string = this.state.CRON_MONTHS    ;
		let CRON_DAYOFWEEK : string = this.state.CRON_DAYOFWEEK ;
		if ( CRON_MINUTES == '0-55' || CRON_MINUTES == '' )
			CRON_MINUTES = '*';

		let DATA_VALUE     : string   = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
		let FREQUENCY      : string   = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
		let CRON_MESSAGE   : string   = CRON.CronDescription(DATA_VALUE);
		let MINUTES_VALUES : string[] = this.SetCronSelectValue    (CRON_MINUTES   , this.state.LIST_MINUTES   );
		this.setState({ DATA_VALUE, FREQUENCY, CRON_MINUTES, CRON_MESSAGE, MINUTES_VALUES });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	private _onChangeCRON_HOURS = (e) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let CRON_MINUTES   : string = this.state.CRON_MINUTES   ;
		let CRON_HOURS     : string = Trim(e.target.value)      ;
		let CRON_DAYOFMONTH: string = this.state.CRON_DAYOFMONTH;
		let CRON_MONTHS    : string = this.state.CRON_MONTHS    ;
		let CRON_DAYOFWEEK : string = this.state.CRON_DAYOFWEEK ;
		if ( CRON_HOURS == '0-23' || CRON_HOURS == '' )
			CRON_HOURS = '*';

		let DATA_VALUE     : string   = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
		let FREQUENCY      : string   = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
		let CRON_MESSAGE   : string   = CRON.CronDescription(DATA_VALUE);
		let HOURS_VALUES   : string[] = this.SetCronSelectValue    (CRON_HOURS     , this.state.LIST_HOURS     );
		this.setState({ DATA_VALUE, FREQUENCY, CRON_HOURS, CRON_MESSAGE, HOURS_VALUES });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	private _onChangeCRON_DAYOFMONTH = (e) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let CRON_MINUTES   : string = this.state.CRON_MINUTES   ;
		let CRON_HOURS     : string = this.state.CRON_HOURS     ;
		let CRON_DAYOFMONTH: string = Trim(e.target.value)      ;
		let CRON_MONTHS    : string = this.state.CRON_MONTHS    ;
		let CRON_DAYOFWEEK : string = this.state.CRON_DAYOFWEEK ;
		if ( CRON_DAYOFMONTH == '0-31' || CRON_DAYOFMONTH == '' )
			CRON_DAYOFMONTH = '*';

		let DATA_VALUE       : string   = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
		let FREQUENCY        : string   = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
		let CRON_MESSAGE     : string   = CRON.CronDescription(DATA_VALUE);
		let DAYOFMONTH_VALUES: string[] = this.SetCronSelectValue    (CRON_DAYOFMONTH, this.state.LIST_DAYOFMONTH);
		this.setState({ DATA_VALUE, FREQUENCY, CRON_DAYOFMONTH, CRON_MESSAGE, DAYOFMONTH_VALUES });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	private _onChangeCRON_MONTHS = (e) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let CRON_MINUTES   : string = this.state.CRON_MINUTES   ;
		let CRON_HOURS     : string = this.state.CRON_HOURS     ;
		let CRON_DAYOFMONTH: string = this.state.CRON_DAYOFMONTH;
		let CRON_MONTHS    : string = Trim(e.target.value)      ;
		let CRON_DAYOFWEEK : string = this.state.CRON_DAYOFWEEK ;
		if ( CRON_MONTHS == '1-12' || CRON_MONTHS == '' )
			CRON_MONTHS = '*';

		let DATA_VALUE      : string = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
		let FREQUENCY       : string = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
		let CRON_MESSAGE    : string = CRON.CronDescription(DATA_VALUE);
		let MONTH_VALUES    : boolean[] = this.SetCronCheckboxesValue(CRON_MONTHS   , 12, 1);
		this.setState({ DATA_VALUE, FREQUENCY, CRON_MONTHS, CRON_MESSAGE, MONTH_VALUES });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	private _onChangeCRON_DAYOFWEEK = (e) =>
	{
		const { onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let CRON_MINUTES   : string = this.state.CRON_MINUTES   ;
		let CRON_HOURS     : string = this.state.CRON_HOURS     ;
		let CRON_DAYOFMONTH: string = this.state.CRON_DAYOFMONTH;
		let CRON_MONTHS    : string = this.state.CRON_MONTHS    ;
		let CRON_DAYOFWEEK : string = Trim(e.target.value)      ;
		if ( CRON_DAYOFWEEK == '0-6' || CRON_DAYOFWEEK == '' )
			CRON_DAYOFWEEK = '*';

		let DATA_VALUE      : string = CRON_MINUTES + '::' + CRON_HOURS + '::' + CRON_DAYOFMONTH + '::' + CRON_MONTHS + '::' + CRON_DAYOFWEEK;
		let FREQUENCY       : string = this.CronFrequency(CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK);
		let CRON_MESSAGE    : string = CRON.CronDescription(DATA_VALUE);
		let DAYOFWEEK_VALUES: boolean[] = this.SetCronCheckboxesValue(CRON_DAYOFWEEK,  7, 0);
		this.setState({ DATA_VALUE, FREQUENCY, CRON_DAYOFWEEK, CRON_MESSAGE, DAYOFWEEK_VALUES });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	private renderDAYOFWEEK = () =>
	{
		const { LIST_DAYOFWEEK, DAYOFWEEK_VALUES } = this.state;
		let ctlCRON_chkDAYOFWEEKChildren = [];
		let ctlCRON_chkDAYOFWEEK = React.createElement('table', { className: 'checkbox', style: {border: 'none', whiteSpace: 'nowrap', verticalAlign: 'top'} }, ctlCRON_chkDAYOFWEEKChildren);
		let tr         = null;
		let trChildren = null;
		LIST_DAYOFWEEK.map((item, index) => 
		{
			if ( index % 4 == 0 )
			{
				trChildren = [];
				tr = React.createElement('tr', {}, trChildren);
				ctlCRON_chkDAYOFWEEKChildren.push(tr);
			}
			let tdChildren = [];
			let td         = React.createElement('td', {}, tdChildren);
			trChildren.push(td);
			let input      = React.createElement('input', {id     : 'ctlCRON_chkDAYOFWEEK_' + index.toString(), type: 'checkbox', checked: DAYOFWEEK_VALUES[index], onClick: (ev: React.ChangeEvent<HTMLInputElement>) => this._onDAYOFWEEK(ev, index) });
			let label      = React.createElement('label', {htmlFor: 'ctlCRON_chkDAYOFWEEK_' + index.toString()}, L10n.ListTerm('scheduler_day_dom', index.toString()));
			tdChildren.push(input);
			tdChildren.push(label);
		});
		return ctlCRON_chkDAYOFWEEK;
	}

	private renderMONTHS = () =>
	{
		const { LIST_MONTHS, MONTH_VALUES } = this.state;
		let ctlCRON_chkDAYOFWEEKChildren = [];
		let ctlCRON_chkDAYOFWEEK = React.createElement('table', { className: 'checkbox', style: {border: 'none', whiteSpace: 'nowrap', verticalAlign: 'top'} }, ctlCRON_chkDAYOFWEEKChildren);
		let tr         = null;
		let trChildren = null;
		LIST_MONTHS.map((item, index) => 
		{
			if ( index % 4 == 0 )
			{
				trChildren = [];
				tr = React.createElement('tr', {}, trChildren);
				ctlCRON_chkDAYOFWEEKChildren.push(tr);
			}
			let tdChildren = [];
			let td         = React.createElement('td', {}, tdChildren);
			trChildren.push(td);
			let input      = React.createElement('input', {id     : 'ctlCRON_chkMONTHS_' +item, type: 'checkbox', checked: MONTH_VALUES[index], onClick: (ev: React.ChangeEvent<HTMLInputElement>) => this._onMONTH(ev, index) });
			let label      = React.createElement('label', {htmlFor: 'ctlCRON_chkMONTHS_' +item}, L10n.ListTerm('scheduler_month_dom', item));
			tdChildren.push(input);
			tdChildren.push(label);
		});
		return ctlCRON_chkDAYOFWEEK;
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE, UI_REQUIRED, FORMAT_TAB_INDEX, FORMAT_SIZE, FORMAT_MAX_LENGTH, FORMAT_ROWS, FORMAT_COLUMNS, VALUE_MISSING, ENABLED, CSS_CLASS } = this.state;
		const { FREQUENCY, LIST_MINUTES, LIST_HOURS, LIST_DAYOFMONTH } = this.state;
		const { MINUTES_VALUES, HOURS_VALUES, DAYOFMONTH_VALUES, DAYOFWEEK_VALUES, MONTH_VALUES } = this.state;
		const { CRONShow, CRON_MESSAGE, CRON_MINUTES, CRON_HOURS, CRON_DAYOFMONTH, CRON_MONTHS, CRON_DAYOFWEEK } = this.state;

		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, DATA_VALUE, row);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for TextBox FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for TextBox DATA_FIELD { DATA_FIELD }</span>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				let bEnableSpeech = Crm_Config.enable_speech();
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// 09/27/2020 Paul.  We need to be able to disable the default grow on TextBox. 
				// 11/10/2020 Paul.  We are having a problem with the text field extending into the next column instead of expanding the current column. 
				let cssFlexGrow: any = { flexGrow: 1, overflowX: 'hidden' };
				if ( this.props.bDisableFlexGrow )
				{
					cssFlexGrow = {};
				}
				let cssInput: any = { marginRight: '4px' };
				if ( !ENABLED )
				{
					cssInput.backgroundColor = '#DDDDDD';
				}
				// 06/23/2020 Paul.  Make use of minimum width. 
				if ( FORMAT_SIZE > 0 )
				{
					cssInput.minWidth = (FORMAT_SIZE * 5).toString() + 'px';
				}
				// 04/28/2019 Paul.  Speech as been deprecated. 
				// 05/16/2018 Paul.  Defer submit key. 
				//if ( sSubmitID != null )
				//{
				//	txt.onkeypress = function(e)
				//	{
				//		return RegisterEnterKeyPress(e, sSubmitID);
				//	};
				//}
				// 09/15/2019 Paul.  Stop using FormControl so that we can use the existing Theme. 
				// 10/27/2020 Paul.  size is cause text field to overflow the parent, into the label on the right. 
				// 11/12/2020 Paul.  Do not turn auto-complete off.  Some customers like it. 
				return (
					<span className={ CSS_CLASS } style={ cssFlexGrow }>
						<div>
							<table cellSpacing={ 0 } cellPadding={ 0 } style={ {border: 'none', borderCollapse: 'collapse'} }>
								<tr>
									<td valign='top' style={ {borderRight: 'solid 1px black', paddingRight: '10px', paddingTop: '5px'} }>
										<table id='ctlCRON_radFREQUENCY' className='radio'  style={ {border: 'none', whiteSpace: 'nowrap'} }>
											<tr>
												<td>
													<input id='ctlCRON_radFREQUENCY_0' type='radio' value='Daily' checked={ FREQUENCY == 'Daily' } style={ {margin: '2px'} } onClick={ () => this._onFREQUENCY('Daily') } />
													<label htmlFor='ctlCRON_radFREQUENCY_0'>Daily</label>
												</td>
											</tr>
											<tr>
												<td>
													<input id='ctlCRON_radFREQUENCY_1' type='radio' value='Weekly' checked={ FREQUENCY == 'Weekly' } style={ {margin: '2px'} } onClick={ () => this._onFREQUENCY('Weekly') } />
													<label htmlFor='ctlCRON_radFREQUENCY_1'>Weekly</label>
												</td>
											</tr>
											<tr>
												<td>
													<input id='ctlCRON_radFREQUENCY_2' type='radio' value='Monthly' checked={ FREQUENCY == 'Monthly' } style={ {margin: '2px'} } onClick={ () => this._onFREQUENCY('Monthly') } />
													<label htmlFor='ctlCRON_radFREQUENCY_2'>Monthly</label>
												</td>
											</tr>
											<tr>
												<td>
													<input id='ctlCRON_radFREQUENCY_3' type='radio' value='Yearly' checked={ FREQUENCY == 'Yearly' } style={ {margin: '2px'} } onClick={ () => this._onFREQUENCY('Yearly') } />
													<label htmlFor='ctlCRON_radFREQUENCY_3'>Yearly</label>
												</td>
											</tr>
										</table>
									</td>
									<td style={ {paddingLeft: '10px'} }>
										<table cellSpacing={ 0 } cellPadding={ 5 } style={ {border: 'none', borderCollapse: 'collapse'} }>
											<tr>
												<td valign='top'><span id='ctlCRON_lblMINUTES'>{ L10n.Term('Schedulers.LBL_MINS') }</span><br />
													<select id='ctlCRON_lstMINUTES' size={ 4 } multiple={ true } value={ MINUTES_VALUES } onChange={ this._onMINUTES }>
													{
														LIST_MINUTES.map((item, index) => 
														{
															let nValue: number = item;
															let sValue: string = nValue.toString();
															if ( sValue.length < 2 )
																sValue = '0' + sValue;
															return (
																<option value={ item }>{ sValue }</option>
															);
														})
													}
													</select>
												</td>
												<td valign='top'><span id='ctlCRON_lblHOURS'>{ L10n.Term('Schedulers.LBL_HOURS') }</span><br />
													<select id='ctlCRON_lstHOURS' size={ 4 } multiple={ true } value={ HOURS_VALUES } onChange={ this._onHOURS }>
													{
														LIST_HOURS.map((item, index) => 
														{
															let sValue: string = item.toString();
															if ( sValue.length < 2 )
																sValue = '0' + sValue;
															return (
																<option value={ item }>{ sValue }</option>
															);
														})
													}
													</select>
												</td>
												{ FREQUENCY != 'Daily'
												? <td valign='top'><span id='ctlCRON_lblDAYOFMONTH'>{ L10n.Term('Schedulers.LBL_DAY_OF_MONTH') }</span><br />
													<select id='ctlCRON_lstDAYOFMONTH' size={ 4 } multiple={ true } value={ DAYOFMONTH_VALUES } onChange={ this._onDAYOFMONTH }>
													{
														LIST_DAYOFMONTH.map((item, index) => 
														{
															let sValue: string = item.toString();
															if ( sValue.length < 2 )
																sValue = '0' + sValue;
															return (
																<option value={ item }>{ sValue }</option>
															);
														})
													}
													</select>
												</td>
												: null
												}
												<td valign='top'>
													<br />
													{ FREQUENCY == 'Weekly'
													? this.renderDAYOFWEEK()
													: null
													}
													{ FREQUENCY == 'Monthly' || FREQUENCY == 'Yearly'
													? this.renderMONTHS()
													: null
													}
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
							<table cellSpacing={ 0 } cellPadding={ 0 } style={ {border: 'none', borderCollapse: 'collapse'} }>
								<tr>
									<td valign='top' style={ {paddingRight: '5px'} }>
										<a className='utilsLink' href='#' onClick={ this._onToggleCRONShow }>
											<img src={ this.themeURL +'advanced_search.gif' } style={ {borderWidth: '0px', height: '8px', width: '8px'} } />
										</a>
										<span className='checkbox' style={ {display: 'none'} }>
											<input id='ctlCRON_chkCRONShow' type='checkbox' />
										</span>
										&nbsp;
										<span id='ctlCRON_lblCRON_MESSAGE' style={ {fontStyle: 'italic'} }>
											{ CRON_MESSAGE }
										</span><br />
									</td>
								</tr>
								<tr>
									<td valign='top'>
										<div id='ctlCRON_pnlCRONValue' style={ {display: (CRONShow ? 'inline' : 'none')} }>
											<table cellSpacing={ 0 } cellPadding={ 0 } style={ {border: 'none', borderCollapse: 'collapse'} }>
												<tr>
													<td className='dataLabel' style={ {lineHeight: '20px'} }>
														<span>{ L10n.Term('Schedulers.LBL_MINS'        ) }</span>
													</td>
													<td className='dataLabel' style={ {lineHeight: '20px'} }>
														<span>{ L10n.Term('Schedulers.LBL_HOURS'       ) }</span>
													</td>
													<td className='dataLabel' style={ {lineHeight: '20px'} }>
														<span>{ L10n.Term('Schedulers.LBL_DAY_OF_MONTH') }</span>
													</td>
													<td className='dataLabel' style={ {lineHeight: '20px'} }>
														<span>{ L10n.Term('Schedulers.LBL_MONTHS'      ) }</span>
													</td>
													<td className='dataLabel' style={ {lineHeight: '20px'} }>
														<span>{ L10n.Term('Schedulers.LBL_DAY_OF_WEEK' ) }</span>
													</td>
													<td></td>
												</tr>
												<tr>
													<td className='dataField'>
														<input id='ctlCRON_CRON_MINUTES' type='text' value={ CRON_MINUTES } maxLength={ 25 } onChange={ this._onChangeCRON_MINUTES } size={ 3 } />
													</td>
													<td className='dataField'>
														<input id='ctlCRON_CRON_HOURS' type='text' value={ CRON_HOURS } maxLength={ 25 } onChange={ this._onChangeCRON_HOURS } size={ 3 } />
													</td>
													<td className='dataField'>
														<input id='ctlCRON_CRON_DAYOFMONTH' type='text' value={ CRON_DAYOFMONTH } maxLength={ 25 } onChange={ this._onChangeCRON_DAYOFMONTH } size={ 3 } />
													</td>
													<td className='dataField'>
														<input id='ctlCRON_CRON_MONTHS' type='text' value={ CRON_MONTHS } maxLength={ 25 } onChange={ this._onChangeCRON_MONTHS } size={ 3 } />
													</td>
													<td className='dataField'>
														<input id='ctlCRON_CRON_DAYOFWEEK' type='text' value={ CRON_DAYOFWEEK } maxLength={ 25 } onChange={ this._onChangeCRON_DAYOFWEEK } size={ 3 } />
													</td>
													<td>
														{ UI_REQUIRED ? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className='required' style={cssRequired} >{L10n.Term('.ERR_REQUIRED_FIELD')}</span> : null }
													</td>
												</tr>
											</table>
										</div>
									</td>
								</tr>
							</table>
						</div>
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

