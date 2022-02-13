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
import { BindArguments } from '../../../../../../scripts/utility';

let culture: any = new Object();
culture.DateTimeFormat = new Object();
culture.DateTimeFormat.DayNames   = L10n.GetListTerms('day_names_dom'  );
culture.DateTimeFormat.MonthNames = L10n.GetListTerms('month_names_dom');

function Duration(options)
{
	this.id            = options.id           ;
	this.label         = options.label        ;
	this.description   = options.description  ;
	this.modelProperty = options.modelProperty;
	this.duration      = null;
}

Duration.prototype.DurationChanged = function ()
{
	let sDuration: any = this.GetDuration();
	let txtCamunda: any = document.getElementById('camunda-' + this.id);
	txtCamunda.value = sDuration;
}

Duration.prototype.AddRawText = function(parent, sID, sLabel)
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
		context.DurationChanged();
	}, this);
}

Duration.prototype.GetDuration = function ()
{
	let ctlDURATION_DURATION_DAYS   : any = document.getElementById(this.id + '_' + 'ctlDURATION_DURATION_DAYS'   );
	let ctlDURATION_DURATION_HOURS  : any = document.getElementById(this.id + '_' + 'ctlDURATION_DURATION_HOURS'  );
	let ctlDURATION_DURATION_MINUTES: any = document.getElementById(this.id + '_' + 'ctlDURATION_DURATION_MINUTES');
	let ctlDURATION_DURATION_SECONDS: any = document.getElementById(this.id + '_' + 'ctlDURATION_DURATION_SECONDS');

	var sDays    = Sql.ToInteger(ctlDURATION_DURATION_DAYS   .value);
	var sHours   = Sql.ToInteger(ctlDURATION_DURATION_HOURS  .value);
	var sMinutes = Sql.ToInteger(ctlDURATION_DURATION_MINUTES.value);
	var sSeconds = Sql.ToInteger(ctlDURATION_DURATION_SECONDS.value);
	if ( sDays    < 0 ) sDays    = 0;
	if ( sHours   < 0 ) sHours   = 0;
	if ( sMinutes < 0 ) sMinutes = 0;
	if ( sSeconds < 0 ) sSeconds = 0;
	if ( sDays    < 9 ) sDays    = '0' + sDays   ;
	if ( sHours   < 9 ) sHours   = '0' + sHours  ;
	if ( sMinutes < 9 ) sMinutes = '0' + sMinutes;
	if ( sSeconds < 9 ) sSeconds = '0' + sSeconds;

	var sDuration = sDays + ':' + sHours + ':' + sMinutes + ':' + sSeconds;
	return sDuration;
}

Duration.prototype.SetDuration = function(sDuration)
{
	this.duration = sDuration;

	var nDays    = 0;
	var nHours   = 0;
	var nMinutes = 0;
	var nSeconds = 0;
	var arr = this.duration.split( ':' );
	if ( arr.length >= 0 ) nDays    = Sql.ToInteger(arr[0]);
	if ( arr.length >= 1 ) nHours   = Sql.ToInteger(arr[1]);
	if ( arr.length >= 2 ) nMinutes = Sql.ToInteger(arr[2]);
	if ( arr.length >= 3 ) nSeconds = Sql.ToInteger(arr[3]);

	let ctlDURATION_DURATION_DAYS   : any = document.getElementById(this.id + '_' + 'ctlDURATION_DURATION_DAYS'   );
	let ctlDURATION_DURATION_HOURS  : any = document.getElementById(this.id + '_' + 'ctlDURATION_DURATION_HOURS'  );
	let ctlDURATION_DURATION_MINUTES: any = document.getElementById(this.id + '_' + 'ctlDURATION_DURATION_MINUTES');
	let ctlDURATION_DURATION_SECONDS: any = document.getElementById(this.id + '_' + 'ctlDURATION_DURATION_SECONDS');
	ctlDURATION_DURATION_DAYS   .value = nDays   ;
	ctlDURATION_DURATION_HOURS  .value = nHours  ;
	ctlDURATION_DURATION_MINUTES.value = nMinutes;
	ctlDURATION_DURATION_SECONDS.value = nSeconds;
	this.DurationChanged();
}

Duration.prototype.Render = function (ctlDURATION)
{
	var tbl = document.createElement('div');
	ctlDURATION.appendChild(tbl);
	tbl.style.display = 'table';
	var tr = document.createElement('div');
	tbl.appendChild(tr);
	tr.style.display = 'table-row';

	var divRaw = document.createElement('div');
	ctlDURATION.appendChild(divRaw);
	divRaw.id            = this.id + '_' + 'ctlDURATION_RAW';
	tbl = document.createElement('div');
	divRaw.appendChild(tbl);
	tbl.style.display = 'table';
	tr = document.createElement('div');
	tbl.appendChild(tr);
	tr.style.display = 'table-row';

	this.AddRawText(tr, this.id + '_' + 'ctlDURATION_DURATION_DAYS'   , L10n.Term('Schedulers.LBL_DAYS'   ));
	this.AddRawText(tr, this.id + '_' + 'ctlDURATION_DURATION_HOURS'  , L10n.Term('Schedulers.LBL_HOURS'  ));
	this.AddRawText(tr, this.id + '_' + 'ctlDURATION_DURATION_MINUTES', L10n.Term('Schedulers.LBL_MINS'   ));
	this.AddRawText(tr, this.id + '_' + 'ctlDURATION_DURATION_SECONDS', L10n.Term('Schedulers.LBL_SECONDS'));

	var divCamunda = document.createElement('div');
	divRaw.appendChild(divCamunda);
	divCamunda.style.display = 'none';
	var txtCamunda = document.createElement('input');
	divCamunda.appendChild(txtCamunda);
	txtCamunda.id   = 'camunda-' + this.id;
	// 06/28/2016 Paul.  Using the name field equal to the modelProperty is required for the properties system to save the changes. 
	txtCamunda.name = this.modelProperty;
}

export default Duration;
