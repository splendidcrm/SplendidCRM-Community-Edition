/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import Sql               from '../../../../../../scripts/Sql' ;
import L10n              from '../../../../../../scripts/L10n';
import StringBuilder     from '../../../../../../scripts/StringBuilder';
import { BindArguments } from '../../../../../../scripts/utility';

let culture: any = new Object();
culture.DateTimeFormat = new Object();
culture.DateTimeFormat.DayNames   = L10n.GetListTerms('day_names_dom'  );
culture.DateTimeFormat.MonthNames = L10n.GetListTerms('month_names_dom');

function Cron(options)
{
	this.id            = options.id           ;
	this.label         = options.label        ;
	this.description   = options.description  ;
	this.modelProperty = options.modelProperty;
	this.cron          = null;
}

Cron.prototype.AddRadio = function(parent, sID, sValue, sLabel, bSelected)
{
	let rad: any = document.createElement('input');
	parent.appendChild(rad);
	rad.id    = sID    ;
	// 06/28/2016 Paul.  Using the name causes the radio to be cleared after being set. 
	// The problem is likely a BPMN properties behavior. 
	//rad.name  = 'CronFrequency' + sID;
	rad.type  = 'radio';
	rad.value = sValue ;
	let lbl: any = document.createElement('label');
	parent.appendChild(lbl);
	lbl.for = sID;
	lbl.appendChild(document.createTextNode(sLabel));
	let br: any = document.createElement('br');
	parent.appendChild(br);
	
	rad.onchange = BindArguments(function(context, sValue)
	{
		context.FrequencyChanged(sValue);
	}, this, sValue);
}

Cron.prototype.AddSelectMinutes = function(parent, sID, arrValues, sLabel)
{
	let lbl: any = document.createElement('span')
	parent.appendChild(lbl);
	lbl.appendChild(document.createTextNode(L10n.Term('Schedulers.LBL_MINS')));
	let br: any = document.createElement('br');
	parent.appendChild( br );
	let sel: any = document.createElement('select');
	parent.appendChild( sel );
	sel.id   = name + sID;
	sel.size = 4;
	sel.multiple = 'multiple';
	for ( var i = 0; i < arrValues.length; i++ )
	{
		let opt: any = document.createElement('option');
		sel.appendChild(opt);
		opt.value = arrValues[i];
		var sDisplayValue = ( arrValues[i] < 10 ? '0' : '') + arrValues[i].toString();
		opt.appendChild(document.createTextNode(sDisplayValue));
	}

	sel.onchange = BindArguments( function ( context )
	{
		context.MinutesChanged();
	}, this );
}

Cron.prototype.AddSelectHours = function(parent, sID, arrValues, sLabel)
{
	var lbl = document.createElement( 'span' )
	parent.appendChild( lbl );
	lbl.appendChild( document.createTextNode(L10n.Term('Schedulers.LBL_HOURS')));
	var br = document.createElement( 'br' );
	parent.appendChild( br );
	let sel: any = document.createElement( 'select' );
	parent.appendChild( sel );
	sel.id = name + sID;
	sel.size = 4;
	sel.multiple = 'multiple';
	for ( var i = 0; i < arrValues.length; i++ )
	{
		let opt: any = document.createElement( 'option' );
		sel.appendChild( opt );
		opt.value = arrValues[i];
		var sDisplayValue = ( arrValues[i] < 10 ? '0' : '' ) + arrValues[i].toString();
		opt.appendChild( document.createTextNode( sDisplayValue ) );
	}

	sel.onchange = BindArguments( function ( context )
	{
		context.HoursChanged();
	}, this );
}

Cron.prototype.AddSelectDaysOfMonth = function(parent, sID, arrValues, sLabel)
{
	var lbl = document.createElement( 'span' )
	parent.appendChild( lbl );
	lbl.appendChild( document.createTextNode(L10n.Term('Schedulers.LBL_DAY_OF_MONTH')));
	var br = document.createElement( 'br' );
	parent.appendChild( br );
	let sel: any = document.createElement( 'select' );
	parent.appendChild( sel );
	sel.id = name + sID;
	sel.size = 4;
	sel.multiple = 'multiple';
	for ( var i = 0; i < arrValues.length; i++ )
	{
		var opt = document.createElement( 'option' );
		sel.appendChild( opt );
		opt.value = arrValues[i];
		var sDisplayValue = ( arrValues[i] < 10 ? '0' : '' ) + arrValues[i].toString();
		opt.appendChild( document.createTextNode( sDisplayValue ) );
	}

	sel.onchange = BindArguments( function ( context )
	{
		context.DaysOfMonthChanged();
	}, this );
}

Cron.prototype.AddCheckboxDaysOfWeek = function(parent, sID, arrValues, nMaxPerList)
{
	var td = document.createElement('div');
	parent.appendChild(td);
	td.style.display = 'table-cell';
	for ( var i = 0; i < arrValues.length; i++ )
	{
		if ( i == nMaxPerList )
		{
			td = document.createElement('div');
			parent.appendChild(td);
			td.style.display = 'table-cell';
		}
		var chk = document.createElement('input');
		td.appendChild(chk);
		chk.id    = sID + i.toString();
		chk.type  = 'checkbox';
		chk.value = i.toString();
		let lbl: any = document.createElement('label');
		td.appendChild(lbl);
		lbl.appendChild(document.createTextNode(arrValues[i]));
		let br: any = document.createElement('br');
		td.appendChild(br);

		chk.onclick = BindArguments( function ( context )
		{
			context.DaysOfWeekChanged();
		}, this );
	}
}

Cron.prototype.AddCheckboxMonths = function ( parent, sID, arrValues, nMaxPerList )
{
	var td = document.createElement('div');
	parent.appendChild(td);
	td.style.display = 'table-cell';
	for ( var i = 0; i < arrValues.length; i++ )
	{
		if ( i == nMaxPerList )
		{
			td = document.createElement('div');
			parent.appendChild(td);
			td.style.display = 'table-cell';
		}
		var chk = document.createElement('input');
		td.appendChild(chk);
		chk.id    = sID + i.toString();
		chk.type  = 'checkbox';
		chk.value = (i + 1).toString();
		let lbl: any = document.createElement('label');
		td.appendChild(lbl);
		lbl.appendChild(document.createTextNode(arrValues[i]));
		let br: any = document.createElement('br');
		td.appendChild(br);

		chk.onclick = BindArguments( function ( context )
		{
			context.MonthsChanged();
		}, this );
	}
}

Cron.prototype.AddRawText = function(parent, sID, sLabel)
{
	var td = document.createElement('div');
	parent.appendChild(td);
	td.style.display = 'table-cell';
	td.appendChild(document.createTextNode(sLabel));
	let br: any = document.createElement('br');
	td.appendChild(br);
	let txt: any = document.createElement('input');
	td.appendChild(txt);
	txt.id        = sID;
	txt.type      = 'text';
	txt.size      = 3;
	txt.maxLength = 25;

	txt.onchange = BindArguments( function ( context )
	{
		context.CronChanged();
	}, this);
}

Cron.prototype.GetFrequency = function()
{
	let ctlCRON_radFREQUENCY_0: any = document.getElementById(this.id + '_' + 'ctlCRON_radFREQUENCY_0');
	let ctlCRON_radFREQUENCY_1: any = document.getElementById(this.id + '_' + 'ctlCRON_radFREQUENCY_1');
	let ctlCRON_radFREQUENCY_2: any = document.getElementById(this.id + '_' + 'ctlCRON_radFREQUENCY_2');
	let ctlCRON_radFREQUENCY_3: any = document.getElementById(this.id + '_' + 'ctlCRON_radFREQUENCY_3');
	if ( ctlCRON_radFREQUENCY_0.checked )  // Daily
	{
		return 'Daily';
	}
	else if ( ctlCRON_radFREQUENCY_1.checked )  // Weekly
	{
		return 'Weekly';
	}
	else if ( ctlCRON_radFREQUENCY_2.checked )  // Monthly
	{
		return 'Monthly';
	}
	else if ( ctlCRON_radFREQUENCY_3.checked )  // Yearly
	{
		return 'Yearly';
	}
	return '';
}

Cron.prototype.FrequencyChanged = function(sFrequency)
{
	let ctlCRON_CRON_MINUTES   : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MINUTES'   );
	let ctlCRON_CRON_HOURS     : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_HOURS'     );
	let ctlCRON_CRON_DAYOFMONTH: any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFMONTH');
	let ctlCRON_CRON_MONTHS    : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MONTHS'    );
	let ctlCRON_CRON_DAYOFWEEK : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFWEEK' );

	switch ( sFrequency )
	{
		case 'Daily'  :
			ctlCRON_CRON_MINUTES   .value = '0';
			ctlCRON_CRON_HOURS     .value = (new Date()).getHours().toString();
			ctlCRON_CRON_DAYOFMONTH.value = '*';
			ctlCRON_CRON_DAYOFWEEK .value = '*';
			ctlCRON_CRON_MONTHS    .value = '*';
			break;
		case 'Weekly' :
			ctlCRON_CRON_MINUTES   .value = '0';
			ctlCRON_CRON_HOURS     .value = (new Date()).getHours().toString();
			ctlCRON_CRON_DAYOFMONTH.value = "*";
			ctlCRON_CRON_DAYOFWEEK .value = (new Date()).getDay().toString();
			ctlCRON_CRON_MONTHS    .value = '*';
			break;
		case 'Monthly':
			ctlCRON_CRON_DAYOFMONTH.value = (new Date()).getDate().toString();
			ctlCRON_CRON_DAYOFWEEK .value = '*';
			ctlCRON_CRON_MONTHS    .value = '*';
			break;
		case 'Yearly' :
			ctlCRON_CRON_DAYOFMONTH.value = (new Date()).getDate().toString();
			ctlCRON_CRON_DAYOFWEEK .value = '*';
			ctlCRON_CRON_MONTHS    .value = ((new Date()).getMonth() + 1).toString();
			break;
	}
	this.CronChanged();
}

Cron.prototype.BuildCronSelectValue = function(sID)
{
	var sb          = new StringBuilder();
	var nStart      = -1;
	var nEnd        = -1;
	var bRangeStart = false;
	let lst: any = document.getElementById(sID);
	for ( var i = 0; i < lst.options.length; i++ )
	{
		var item = lst.options[i];
		if ( item.selected )
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
				sb.Append(lst.options[nStart].value + "-" + lst.options[nEnd].value);
			else
				sb.Append(lst.options[nStart].value);
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
			sb.Append(lst.options[nStart].value + "-" + lst.options[nEnd].value);
		else
			sb.Append(lst.options[nStart].value);
		nStart      = -1;
		nEnd        = -1;
		bRangeStart = false;
	}
	return sb.toString();
}

Cron.prototype.BuildCronCheckboxesValue = function(sID, nMaxItems)
{
	var sb          = new StringBuilder();
	var nStart      = -1;
	var nEnd        = -1;
	var bRangeStart = false;
	var options = new Array();
	for ( var i = 0; i < nMaxItems; i++ )
	{
		let item: any = document.getElementById( sID + i.toString() );
		options.push(item.value);
	}
	for ( var i = 0; i < nMaxItems; i++ )
	{
		let item: any = document.getElementById( sID + i.toString());
		if ( item.checked )
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

Cron.prototype.SetOptionValue = function(lst, sValue)
{
	for ( var i = 0; i < lst.options.length; i++ )
	{
		var item = lst.options[i];
		if ( item.value == sValue )
		{
			item.selected = true;
			break;
		}
	}
}

Cron.prototype.SetCronSelectValue = function(sID, sValue)
{
	let lst: any = document.getElementById(sID);
	if ( sValue == '*' )
	{
		for ( var i = 0; i < lst.options.length; i++ )
		{
			var item = lst.options[i];
			item.selected = true;
		}
	}
	else
	{
		for ( var i = 0; i < lst.options.length; i++ )
		{
			var item = lst.options[i];
			item.selected = false;
		}
		var arrCommaSep = sValue.split(',');
		for ( var n in arrCommaSep )
		{
			var arrRange = arrCommaSep[n].split( '-' );
			if ( arrRange.length > 1 )
			{
				var nStart = parseInt(arrRange[0], 10);
				var nEnd   = parseInt(arrRange[1], 10);
				if ( nStart != NaN && nEnd != NaN )
				{
					if ( nStart <= nEnd )
					{
						for ( var nParam = nStart; nParam <= nEnd; nParam++ )
						{
							var sParam = nParam.toString();
							this.SetOptionValue(lst, sParam);
						}
					}
				}
			}
			else
			{
				var nParam = parseInt(arrRange[0], 10);
				if ( nParam != NaN )
				{
					var sParam = nParam.toString();
					this.SetOptionValue( lst, sParam );
				}
			}
		}
	}
}

Cron.prototype.SetCronCheckboxesValue = function(sID, sValue, nMaxItems)
{
	if ( sValue == '*' )
	{
		for ( var i = 0; i < nMaxItems; i++ )
		{
			let item: any = document.getElementById( sID + i.toString() );
			item.checked = true;
		}
	}
	else
	{
		for ( var i = 0; i < nMaxItems; i++ )
		{
			let item: any = document.getElementById( sID + i.toString() );
			item.checked = false;
		}
		var arrCommaSep = sValue.split(',');
		for ( var n in arrCommaSep )
		{
			var arrRange = arrCommaSep[n].split( '-' );
			if ( arrRange.length > 1 )
			{
				var nStart = parseInt(arrRange[0], 10);
				var nEnd   = parseInt(arrRange[1], 10);
				if ( nStart != NaN && nEnd != NaN )
				{
					if ( nStart <= nEnd )
					{
						for ( var nParam = nStart; nParam < nEnd; nParam++ )
						{
							let item: any = document.getElementById( sID + nParam.toString() );
							item.checked = true;
						}
					}
				}
			}
			else
			{
				var nParam = parseInt(arrRange[0], 10);
				if ( nParam != NaN )
				{
					let item: any = document.getElementById( sID + nParam.toString() );
					item.checked = true;
				}
			}
		}
	}
}

Cron.prototype.MinutesChanged = function ()
{
	//console.log('MinutesChanged');
	let txt: any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MINUTES');
	txt.value = this.BuildCronSelectValue(this.id + '_' + 'ctlCRON_lstMINUTES');
	if ( txt.value == '0-55' || txt.value == '' )
		txt.value = '*';
	this.SetFrequency();
	this.UpdateDescription();
}

Cron.prototype.HoursChanged = function ()
{
	//console.log('HoursChanged');
	let txt: any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_HOURS');
	txt.value = this.BuildCronSelectValue(this.id + '_' + 'ctlCRON_lstHOURS');
	if ( txt.value == '0-23' || txt.value == '' )
		txt.value = '*';
	this.SetFrequency();
	this.UpdateDescription();
}

Cron.prototype.DaysOfMonthChanged = function ()
{
	//console.log('DaysOfMonthChanged');
	let txt: any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFMONTH');
	txt.value = this.BuildCronSelectValue(this.id + '_' + 'ctlCRON_lstDAYOFMONTH');
	if ( txt.value == '0-31' || txt.value == '' )
		txt.value = '*';
	this.SetFrequency();
	this.UpdateDescription();
}

Cron.prototype.DaysOfWeekChanged = function ()
{
	//console.log('DaysOfWeekChanged');
	let txt: any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFWEEK');
	txt.value = this.BuildCronCheckboxesValue(this.id + '_' + 'ctlCRON_chkDAYOFWEEK_', 7);
	if ( txt.value == '0-6' || txt.value == '' )
		txt.value = '*';
	this.SetFrequency();
	this.UpdateDescription();
}

Cron.prototype.MonthsChanged = function ()
{
	//console.log('MonthsChanged');
	let txt: any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MONTHS');
	txt.value = this.BuildCronCheckboxesValue(this.id + '_' + 'ctlCRON_chkMONTHS_', 12);
	if ( txt.value == '1-12' || txt.value == '' )
		txt.value = '*';
	this.SetFrequency();
	this.UpdateDescription();
}

Cron.prototype.SetFrequency = function ()
{
	//console.log('SetFrequency');
	let ctlCRON_radFREQUENCY_0: any = document.getElementById(this.id + '_' + 'ctlCRON_radFREQUENCY_0');
	let ctlCRON_radFREQUENCY_1: any = document.getElementById(this.id + '_' + 'ctlCRON_radFREQUENCY_1');
	let ctlCRON_radFREQUENCY_2: any = document.getElementById(this.id + '_' + 'ctlCRON_radFREQUENCY_2');
	let ctlCRON_radFREQUENCY_3: any = document.getElementById(this.id + '_' + 'ctlCRON_radFREQUENCY_3');

	if ( document.getElementById(this.id + '_' + 'ctlCRON_CRON_MINUTES') == null )
		return;

	let ctlCRON_CRON_MINUTES   : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MINUTES'   );
	let ctlCRON_CRON_HOURS     : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_HOURS'     );
	let ctlCRON_CRON_DAYOFMONTH: any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFMONTH');
	let ctlCRON_CRON_MONTHS    : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MONTHS'    );
	let ctlCRON_CRON_DAYOFWEEK : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFWEEK' );

	var sMinutes     = ctlCRON_CRON_MINUTES   .value;
	var sHours       = ctlCRON_CRON_HOURS     .value;
	var sDaysOfMonth = ctlCRON_CRON_DAYOFMONTH.value;
	var sMonths      = ctlCRON_CRON_MONTHS    .value;
	var sDaysOfWeek  = ctlCRON_CRON_DAYOFWEEK .value;

	if ( sDaysOfMonth == '*' && sDaysOfWeek == '*' && sMonths == '*' )
	{
		ctlCRON_radFREQUENCY_0.checked = 1;  // Daily
		ctlCRON_radFREQUENCY_1.checked = 0;
		ctlCRON_radFREQUENCY_2.checked = 0;
		ctlCRON_radFREQUENCY_3.checked = 0;
	}
	else if ( sDaysOfMonth == '*' && sDaysOfWeek != '*' && sMonths == '*' )
	{
		ctlCRON_radFREQUENCY_0.checked = 0;
		ctlCRON_radFREQUENCY_1.checked = 1;  // Weekly
		ctlCRON_radFREQUENCY_2.checked = 0;
		ctlCRON_radFREQUENCY_3.checked = 0;
	}
	else if ( sDaysOfMonth != '*' && sDaysOfWeek == '*' && sMonths == '*' )
	{
		ctlCRON_radFREQUENCY_0.checked = 0;
		ctlCRON_radFREQUENCY_1.checked = 0;
		ctlCRON_radFREQUENCY_2.checked = 1;  // Monthly
		ctlCRON_radFREQUENCY_3.checked = 0;
	}
	else if ( sDaysOfMonth != '*' && sDaysOfWeek == '*' && sMonths != '*' )
	{
		ctlCRON_radFREQUENCY_0.checked = 0;
		ctlCRON_radFREQUENCY_1.checked = 0;
		ctlCRON_radFREQUENCY_2.checked = 0;
		ctlCRON_radFREQUENCY_3.checked = 1;  // Yearly
	}
	var ctlCRON_tdDAYOFMONTH = document.getElementById(this.id + '_' + 'ctlCRON_tdDAYOFMONTH');
	var ctlCRON_chkMONTHS    = document.getElementById(this.id + '_' + 'ctlCRON_chkMONTHS'   );
	var ctlCRON_chkDAYOFWEEK = document.getElementById(this.id + '_' + 'ctlCRON_chkDAYOFWEEK');
	ctlCRON_tdDAYOFMONTH.style.display = 'inline';
	ctlCRON_chkMONTHS   .style.display = 'inline';
	ctlCRON_chkDAYOFWEEK.style.display = 'inline';
	var sFrequency = this.GetFrequency();
	switch ( sFrequency )
	{
		case 'Daily':
			ctlCRON_tdDAYOFMONTH.style.display = 'none';
			ctlCRON_chkMONTHS   .style.display = 'none';
			ctlCRON_chkDAYOFWEEK.style.display = 'none';
			break;
		case 'Weekly':
			ctlCRON_chkMONTHS   .style.display = 'none';
			break;
		case 'Monthly':
			ctlCRON_chkDAYOFWEEK.style.display = 'none';
			break;
		case 'Yearly':
			ctlCRON_chkDAYOFWEEK.style.display = 'none';
			break;
	}
}

function Trim( str )
{
	return str.replace( /^\s\s*/, '' ).replace( /\s\s*$/, '' );
}

Cron.prototype.CronChanged = function ()
{
	//console.log('CronChanged');
	let ctlCRON_CRON_MINUTES   : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MINUTES'   );
	let ctlCRON_CRON_HOURS     : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_HOURS'     );
	let ctlCRON_CRON_DAYOFMONTH: any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFMONTH');
	let ctlCRON_CRON_DAYOFWEEK : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFWEEK' );
	let ctlCRON_CRON_MONTHS    : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MONTHS'    );

	ctlCRON_CRON_MINUTES   .value = Trim(ctlCRON_CRON_MINUTES   .value);
	ctlCRON_CRON_HOURS     .value = Trim(ctlCRON_CRON_HOURS     .value);
	ctlCRON_CRON_DAYOFMONTH.value = Trim(ctlCRON_CRON_DAYOFMONTH.value);
	ctlCRON_CRON_DAYOFWEEK .value = Trim(ctlCRON_CRON_DAYOFWEEK .value);
	ctlCRON_CRON_MONTHS    .value = Trim(ctlCRON_CRON_MONTHS    .value);
	if ( ctlCRON_CRON_MINUTES   .value == '' ) ctlCRON_CRON_MINUTES   .value = '*';
	if ( ctlCRON_CRON_HOURS     .value == '' ) ctlCRON_CRON_HOURS     .value = '*';
	if ( ctlCRON_CRON_DAYOFMONTH.value == '' ) ctlCRON_CRON_DAYOFMONTH.value = '*';
	if ( ctlCRON_CRON_DAYOFWEEK .value == '' ) ctlCRON_CRON_DAYOFWEEK .value = '*';
	if ( ctlCRON_CRON_MONTHS    .value == '' ) ctlCRON_CRON_MONTHS    .value = '*';
	
	this.UpdateDescription();
	this.SetCronSelectValue    (this.id + '_' + 'ctlCRON_lstMINUTES'   , ctlCRON_CRON_MINUTES   .value);
	this.SetCronSelectValue    (this.id + '_' + 'ctlCRON_lstHOURS'     , ctlCRON_CRON_HOURS     .value);
	this.SetCronSelectValue    (this.id + '_' + 'ctlCRON_lstDAYOFMONTH', ctlCRON_CRON_DAYOFMONTH.value);
	this.SetCronCheckboxesValue(this.id + '_' + 'ctlCRON_chkDAYOFWEEK_', ctlCRON_CRON_DAYOFWEEK .value,  7);
	this.SetCronCheckboxesValue(this.id + '_' + 'ctlCRON_chkMONTHS_'   , ctlCRON_CRON_MONTHS    .value, 12);
	this.SetFrequency();
}

Cron.prototype.CronDescription = function(sCRON)
{
	if ( sCRON == "*::*::*::*::*" )
		return L10n.Term("Schedulers.LBL_OFTEN");
	try
	{
		var sb                = new StringBuilder();
		var sCRON_MONTH       = "*";
		var sCRON_DAYOFMONTH  = "*";
		var sCRON_DAYOFWEEK   = "*";
		var sCRON_HOUR        = "*";
		var sCRON_MINUTE      = "*";
		var arrCRON           = sCRON.split('::');
		var arrCRON_TEMP      = new Array();
		var arrCRON_VALUE     = new Array();
		var arrDaySuffixes    = new Array();
		var nCRON_VALUE       = 0;
		var nCRON_VALUE_START = 0;
		var nCRON_VALUE_END   = 0;
		var nON_THE_MINUTE    = -1;
		for ( var n = 0; n < 32; n++ )
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
							sb.Append(culture.DateTimeFormat.MonthNames[nCRON_VALUE_START - 1]);
							sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
							sb.Append(culture.DateTimeFormat.MonthNames[nCRON_VALUE_END - 1]);
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
						sb.Append(culture.DateTimeFormat.MonthNames[nCRON_VALUE - 1]);
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
							sb.Append(culture.DateTimeFormat.DayNames[nCRON_VALUE_START]);
							sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
							sb.Append(culture.DateTimeFormat.DayNames[nCRON_VALUE_END]);
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
						sb.Append(culture.DateTimeFormat.DayNames[nCRON_VALUE]);
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

Cron.prototype.UpdateDescription = function ()
{
	var sCron = this.GetCron();
	// 06/28/2016 Paul.   We need to update the Camunda text field in order for the value to get into the BPMN. 
	let txtCamunda: any = document.getElementById('camunda-' + this.id);
	txtCamunda.value = sCron;
	
	let div: any = document.getElementById(this.id + '_' + 'ctlCRON_lblCRON_MESSAGE');
	div.innerHTML = this.CronDescription(sCron);
}

Cron.prototype.GetCron = function ()
{
	if ( document.getElementById(this.id + '_' + 'ctlCRON_CRON_MINUTES') == null )
		return '';

	let ctlCRON_CRON_MINUTES   : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MINUTES'   );
	let ctlCRON_CRON_HOURS     : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_HOURS'     );
	let ctlCRON_CRON_DAYOFMONTH: any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFMONTH');
	let ctlCRON_CRON_MONTHS    : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MONTHS'    );
	let ctlCRON_CRON_DAYOFWEEK : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFWEEK' );

	var sMinutes     = ctlCRON_CRON_MINUTES   .value;
	var sHours       = ctlCRON_CRON_HOURS     .value;
	var sDaysOfMonth = ctlCRON_CRON_DAYOFMONTH.value;
	var sMonths      = ctlCRON_CRON_MONTHS    .value;
	var sDaysOfWeek  = ctlCRON_CRON_DAYOFWEEK .value;

	var sCron = sMinutes + '::' + sHours + '::' + sDaysOfMonth + '::' + sMonths + '::' + sDaysOfWeek;
	return sCron;
}

Cron.prototype.SetCron = function(sCron)
{
	this.cron = sCron;

	var sMinutes     = '';
	var sHours       = '';
	var sDaysOfMonth = '';
	var sMonths      = '';
	var sDaysOfWeek  = '';
	var arr = this.cron.split( '::' );
	if ( arr.length >= 0 ) sMinutes     = arr[0];
	if ( arr.length >= 1 ) sHours       = arr[1];
	if ( arr.length >= 2 ) sDaysOfMonth = arr[2];
	if ( arr.length >= 3 ) sMonths      = arr[3];
	if ( arr.length >= 4 ) sDaysOfWeek  = arr[4];

	let ctlCRON_CRON_MINUTES   : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MINUTES'   );
	let ctlCRON_CRON_HOURS     : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_HOURS'     );
	let ctlCRON_CRON_DAYOFMONTH: any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFMONTH');
	let ctlCRON_CRON_MONTHS    : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_MONTHS'    );
	let ctlCRON_CRON_DAYOFWEEK : any = document.getElementById(this.id + '_' + 'ctlCRON_CRON_DAYOFWEEK' );

	ctlCRON_CRON_MINUTES   .value = sMinutes    ;
	ctlCRON_CRON_HOURS     .value = sHours      ;
	ctlCRON_CRON_DAYOFMONTH.value = sDaysOfMonth;
	ctlCRON_CRON_MONTHS    .value = sMonths     ;
	ctlCRON_CRON_DAYOFWEEK .value = sDaysOfWeek ;
	this.CronChanged();
}

Cron.prototype.Render = function (ctlCRON)
{
	var tbl = document.createElement('div');
	ctlCRON.appendChild(tbl);
	tbl.style.display = 'table';
	var tr = document.createElement('div');
	tbl.appendChild(tr);
	tr.style.display = 'table-row';

	// FREQUENCY
	var td = document.createElement('div');
	tr.appendChild(td);
	td.style.display      = 'table-cell';
	td.style.borderRight  = 'solid 1px black';
	td.style.paddingRight = '10px';
	this.AddRadio(td, this.id + '_' + 'ctlCRON_radFREQUENCY_0', 'Daily'  , L10n.Term('.scheduler_frequency_dom.Daily'  ), false);
	this.AddRadio(td, this.id + '_' + 'ctlCRON_radFREQUENCY_1', 'Weekly' , L10n.Term('.scheduler_frequency_dom.Weekly' ), false);
	this.AddRadio(td, this.id + '_' + 'ctlCRON_radFREQUENCY_2', 'Monthly', L10n.Term('.scheduler_frequency_dom.Monthly'), false);
	this.AddRadio(td, this.id + '_' + 'ctlCRON_radFREQUENCY_3', 'Yearly' , L10n.Term('.scheduler_frequency_dom.Yearly' ), false);

	var arrMinutes = new Array();
	for ( var i = 0; i < 60; i += 5 )
	{
		arrMinutes.push(i);
	}
	// MINUTES
	td = document.createElement('div');
	tr.appendChild(td);
	td.style.display = 'table-cell';
	td.style.paddingLeft = '10px';
	this.AddSelectMinutes( td, this.id + '_' + 'ctlCRON_lstMINUTES', arrMinutes);

	var arrHours = new Array();
	for ( var i = 0; i < 24; i++ )
	{
		arrHours.push(i);
	}
	// HOURS
	td = document.createElement('div');
	tr.appendChild(td);
	td.style.display = 'table-cell';
	td.style.paddingLeft = '10px';
	this.AddSelectHours( td, this.id + '_' + 'ctlCRON_lstHOURS', arrHours);

	var arrDaysOfMonth = new Array();
	for ( var i = 1; i <= 31; i++ )
	{
		arrDaysOfMonth.push( i );
	}
	// DAYOFMONTH
	td = document.createElement( 'div' );
	tr.appendChild( td );
	td.id                = this.id + '_' + 'ctlCRON_tdDAYOFMONTH';
	td.style.display     = 'table-cell';
	td.style.paddingLeft = '10px';
	this.AddSelectDaysOfMonth( td, this.id + '_' + 'ctlCRON_lstDAYOFMONTH', arrDaysOfMonth);

	// DAYOFWEEK
	var ctlCRON_chkDAYOFWEEK = document.createElement('div');
	ctlCRON.appendChild(ctlCRON_chkDAYOFWEEK);
	ctlCRON_chkDAYOFWEEK.id            = this.id + '_' + 'ctlCRON_chkDAYOFWEEK';
	ctlCRON_chkDAYOFWEEK.style.display = 'none';
	tbl = document.createElement('div');
	ctlCRON_chkDAYOFWEEK.appendChild(tbl);
	tbl.style.display = 'table';
	tr = document.createElement('div');
	tbl.appendChild(tr);
	tr.style.display = 'table-row';
	this.AddCheckboxDaysOfWeek( tr, this.id + '_' + 'ctlCRON_chkDAYOFWEEK_', culture.DateTimeFormat.DayNames, 4 );

	// MONTHS
	var ctlCRON_chkMONTHS = document.createElement('div');
	ctlCRON.appendChild(ctlCRON_chkMONTHS);
	ctlCRON_chkMONTHS.id            = this.id + '_' + 'ctlCRON_chkMONTHS';
	ctlCRON_chkMONTHS.style.display = 'none';
	tbl = document.createElement('div');
	ctlCRON_chkMONTHS.appendChild(tbl);
	tbl.style.display = 'table';
	tr = document.createElement('div');
	tbl.appendChild(tr);
	tr.style.display = 'table-row';
	this.AddCheckboxMonths( tr, this.id + '_' + 'ctlCRON_chkMONTHS_', culture.DateTimeFormat.MonthNames, 6 );

	var divDesc = document.createElement('div');
	ctlCRON.appendChild(divDesc);
	var a = document.createElement('a');
	divDesc.appendChild(a);
	a.appendChild(document.createTextNode('>>>'));
	a.href = '#';
	a.onclick = BindArguments(function(context)
	{
		let ctlCRON_RAW: any = document.getElementById(context.id + '_' + 'ctlCRON_RAW');
		ctlCRON_RAW.style.display = (ctlCRON_RAW.style.display == 'none' ? 'inline' : 'none');
	}, this);
	var spn = document.createElement('span');
	divDesc.appendChild(spn);
	spn.id = this.id + '_' + 'ctlCRON_lblCRON_MESSAGE';

	var divRaw = document.createElement('div');
	ctlCRON.appendChild(divRaw);
	divRaw.id            = this.id + '_' + 'ctlCRON_RAW';
	divRaw.style.display = 'none';
	tbl = document.createElement('div');
	divRaw.appendChild(tbl);
	tbl.style.display = 'table';
	tr = document.createElement('div');
	tbl.appendChild(tr);
	tr.style.display = 'table-row';

	this.AddRawText(tr, this.id + '_' + 'ctlCRON_CRON_MINUTES'   , L10n.Term('Schedulers.LBL_MINS'        ));
	this.AddRawText(tr, this.id + '_' + 'ctlCRON_CRON_HOURS'     , L10n.Term('Schedulers.LBL_HOURS'       ));
	this.AddRawText(tr, this.id + '_' + 'ctlCRON_CRON_DAYOFMONTH', L10n.Term('Schedulers.LBL_DAY_OF_MONTH'));
	this.AddRawText(tr, this.id + '_' + 'ctlCRON_CRON_MONTHS'    , L10n.Term('Schedulers.LBL_MONTHS'      ));
	this.AddRawText(tr, this.id + '_' + 'ctlCRON_CRON_DAYOFWEEK' , L10n.Term('Schedulers.LBL_DAY_OF_WEEK' ));

	var divCamunda = document.createElement('div');
	divRaw.appendChild(divCamunda);
	divCamunda.style.display = 'none';
	var txtCamunda = document.createElement('input');
	divCamunda.appendChild(txtCamunda);
	txtCamunda.id   = 'camunda-' + this.id;
	// 06/28/2016 Paul.  Using the name field equal to the modelProperty is required for the properties system to save the changes. 
	txtCamunda.name = this.modelProperty;
}

export default Cron;
