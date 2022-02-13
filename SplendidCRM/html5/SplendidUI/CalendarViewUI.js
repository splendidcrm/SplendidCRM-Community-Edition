/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

var bSharedCalendar = false;
function ToggleSharedCalendar()
{
	try
	{
		bSharedCalendar = bSharedCalendar ? false : true;
		if ( bSharedCalendar )
			$("#divCalendar").find('span.fc-button-' + 'shared').addClass('fc-state-active');
		else
			$("#divCalendar").find('span.fc-button-' + 'shared').removeClass('fc-state-active');
		$("#divCalendar").fullCalendar('refetchEvents');
	}
	catch(e)
	{
		SplendidError.SystemMessage(SplendidError.FormatError(e, 'ToggleSharedCalendar'));
	}
}

function CalendarViewUI()
{
	this.YearMonthPattern      = L10n.Term('Calendar.YearMonthPattern');
	this.MonthDayPattern       = L10n.Term('Calendar.MonthDayPattern' );
	this.LongDatePattern       = L10n.Term('Calendar.LongDatePattern' );
	this.ShortTimePattern      = Security.USER_TIME_FORMAT();
	this.ShortDatePattern      = Security.USER_DATE_FORMAT();
	this.FirstDayOfWeek        = Sql.ToInteger(L10n.Term('Calendar.FirstDayOfWeek'));
	this.MonthNames            = L10n.GetListTerms('month_names_dom'      );
	this.AbbreviatedMonthNames = L10n.GetListTerms('short_month_names_dom');
	this.DayNames              = L10n.GetListTerms('day_names_dom'        );
	this.AbbreviatedDayNames   = L10n.GetListTerms('short_day_names_dom'  );

	if ( Sql.IsEmptyString(this.YearMonthPattern) || this.YearMonthPattern == 'Calendar.YearMonthPattern' ) this.YearMonthPattern = 'MMMM, yyyy';
	if ( Sql.IsEmptyString(this.MonthDayPattern ) || this.MonthDayPattern  == 'Calendar.MonthDayPattern'  ) this.MonthDayPattern  = 'MMMM dd';
	if ( Sql.IsEmptyString(this.LongDatePattern ) || this.LongDatePattern  == 'Calendar.LongDatePattern'  ) this.LongDatePattern  = 'dddd, MMMM dd, yyyy';
	if ( Sql.IsEmptyString(this.ShortTimePattern)                                                         ) this.ShortTimePattern = 'h:mm tt';
	if ( Sql.IsEmptyString(this.ShortDatePattern)                                                         ) this.ShortDatePattern = 'MM/dd/yyyy';
	if ( Sql.IsEmptyString(this.FirstDayOfWeek  ) || isNaN(this.FirstDayOfWeek)                           ) this.FirstDayOfWeek   = 0;
	if ( this.MonthNames            == null || this.MonthNames.length            == 0 ) this.MonthNames            = ['January','February','March','April','May','June','July','August','September','October','November','December'];
	if ( this.AbbreviatedMonthNames == null || this.AbbreviatedMonthNames.length == 0 ) this.AbbreviatedMonthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
	if ( this.DayNames              == null || this.DayNames.length              == 0 ) this.DayNames              = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
	if ( this.AbbreviatedDayNames   == null || this.AbbreviatedDayNames.length   == 0 ) this.AbbreviatedDayNames   = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
}

CalendarViewUI.prototype.Clear = function(sLayoutPanel, sActionsPanel)
{
	try
	{
		SplendidUI_Clear(sLayoutPanel, sActionsPanel);
		SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, 'Calendar', L10n.ListTerm('moduleList', 'Calendar'));
		var divCalendar = document.createElement('div');
		divCalendar.id          = 'divCalendar';
		divCalendar.style.width = '100%'       ;
		var divMainLayoutPanel = document.getElementById(sLayoutPanel);
		divMainLayoutPanel.appendChild(divCalendar);
	}
	catch(e)
	{
		SplendidError.SystemMessage(SplendidError.FormatError(e, 'CalendarViewUI.Clear'));
	}
};

CalendarViewUI.prototype.Render = function(sLayoutPanel, sActionsPanel, callback, context)
{
	var sCalendarDefaultView = '';
	if ( window.localStorage )
		sCalendarDefaultView = localStorage['CalendarDefaultView'];
	else
		sCalendarDefaultView = getCookie('CalendarDefaultView');
	if ( Sql.IsEmptyString(sCalendarDefaultView) )
		sCalendarDefaultView = 'agendaDay';
	
	// 12/14/2014 Paul.  Header is too large on a mobile device. Remove the title. 
	var bIsMobile = isMobileDevice();
	if ( isMobileLandscape() )
		bIsMobile = false;

	var bgPage = chrome.extension.getBackgroundPage();
	// http://arshaw.com/fullcalendar/docs/
	var calendar = $('#divCalendar').fullCalendar
	({
		header:
		{
			  left  : 'agendaDay,agendaWeek,month {shared:ToggleSharedCalendar}'
			, center: (bIsMobile ? '' : 'title')
			, right : 'today prev,next'
		}
		, buttonText:
		{
			  prev    : '&nbsp;&#9668;&nbsp;'  // left triangle
			, next    : '&nbsp;&#9658;&nbsp;'  // right triangle
			, prevYear: '&nbsp;&lt;&lt;&nbsp;' // <<
			, nextYear: '&nbsp;&gt;&gt;&nbsp;' // >>
			, today   : L10n.Term("Calendar.LNK_VIEW_CALENDAR")
			, month   : L10n.Term("Calendar.LBL_MONTH"        )
			, week    : L10n.Term("Calendar.LBL_WEEK"         )
			, day     : L10n.Term("Calendar.LBL_DAY"          )
			, shared  : L10n.Term("Calendar.LBL_SHARED"       )
		}
		, titleFormat:
		{
			  month   : this.YearMonthPattern
			, week    : this.MonthDayPattern + "[ yyyy]{ '&#8212;' " + this.MonthDayPattern + ' yyyy}'
			, day     : this.LongDatePattern
		}
		// 05/24/2018 Paul.  Make sure that the axis uses the correct format. 
		, axisFormat: this.ShortTimePattern
		, timeFormat:
		{
			  agenda  : this.ShortTimePattern + '{ - ' + this.ShortTimePattern + '}'
			, ''      : this.ShortTimePattern 
		}
		, columnFormat:
		{
			  month   : 'ddd'
			, week    : 'ddd '  + Trim(this.ShortDatePattern.replace('yyyy', '').replace(new RegExp(/\//g), ' ')).replace(new RegExp(/ /g), '/').replace('MM', 'M').replace('dd', 'd')
			, day     : 'dddd ' + Trim(this.ShortDatePattern.replace('yyyy', '').replace(new RegExp(/\//g), ' ')).replace(new RegExp(/ /g), '/').replace('MM', 'M').replace('dd', 'd')
		}
		// 05/08/2017 Paul.  Use Bootstrap for responsive design.
		//, height             : ($(window).height() > 0 ? $(window).height() - 180 : 800)
		, height             : $('#divMainPageContent').height() > 0 ? $('#divMainPageContent').height() - 180 : 800
		, defaultView        : sCalendarDefaultView
		, editable           : true
		, selectable         : true
		, selectHelper       : true
		, allDaySlot         : true
		, allDayText         : L10n.Term("Calendar.LBL_ALL_DAY")
		, slotMinutes        : 30
		, defaultEventMinutes: 60
		, firstHour          : Sql.ToInteger(bgPage.SplendidCache.Config('calendar.hour_start'))
		, firstDay           : this.FirstDayOfWeek       
		, monthNames         : this.MonthNames           
		, monthNamesShort    : this.AbbreviatedMonthNames
		, dayNames           : this.DayNames             
		, dayNamesShort      : this.AbbreviatedDayNames  
		, select: function(start, end, allDay)
		{
			// 02/24/2013 Paul.  Until we can support allDay events, when clicking on a day of the month, change to the day view. 
			if ( Math.round((end - start)/1000) == 0 )
			{
				var view = calendar.fullCalendar('getView');
				if ( view.name == 'month' )
				{
					calendar.fullCalendar('changeView', 'agendaDay');
					calendar.fullCalendar('gotoDate', start.getFullYear(), start.getMonth(), start.getDate());
					return;
				}
			}
			var $dialog = $('<div id="divNewAppointmentPopup"></div>');
			$dialog.dialog(
			{
				  modal    : true
				, resizable: true
				, width    : ($(window).height() > 0 ? 640 : 680)
				, height   : ($(window).height() > 0 ? 560 : 660)
				, title    : L10n.Term("Calendar.LNK_NEW_APPOINTMENT")
				, create: function(event, ui)
				{
					var TOTAL_SECONDS    = Math.round((end - start)/1000);
					var TOTAL_MINUTES    = Math.round(TOTAL_SECONDS/60);
					var DURATION_HOURS   = Math.floor(TOTAL_MINUTES/60);
					var DURATION_MINUTES = TOTAL_MINUTES % 60;
					// 03/10/2013 Paul.  Add ALL_DAY_EVENT. 
					var ALL_DAY_EVENT    = allDay;
					if ( ALL_DAY_EVENT )
					{
						DURATION_HOURS   = 24;
						DURATION_MINUTES = 0;
					}
					
					var divNewAppointmentPopup = document.getElementById('divNewAppointmentPopup');
					// sHTML += '<table class="tabEditView">';
					var tblEditView = document.createElement('table');
					tblEditView.className = 'tabEditView';
					divNewAppointmentPopup.appendChild(tblEditView);
					var col = document.createElement('col');
					tblEditView.appendChild(col);
					col.setAttribute('width', '25%');
					col = document.createElement('col');
					tblEditView.appendChild(col);
					col.setAttribute('width', '35%');
					col = document.createElement('col');
					tblEditView.appendChild(col);
					col.setAttribute('width', '30%');
					col = document.createElement('col');
					tblEditView.appendChild(col);
					col.setAttribute('width', '10%');
					var tbody = document.createElement('tbody');
					tblEditView.appendChild(tbody);
					
					var tr  = null;
					var td  = null;
					var txt = null;
					var spn = null;
					var nbsp = String.fromCharCode(160);
					
					// sHTML += '	<tr>';
					// sHTML += '		<td>';
					// sHTML += '			<input ID="divNewAppointmentPopup_radScheduleCall"    Name="grpSchedule" type="radio" class="radio" value="Calls" checked /> ' + L10n.Term("Calls.LNK_NEW_CALL"   );
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			<input ID="divNewAppointmentPopup_radScheduleMeeting" Name="grpSchedule" type="radio" class="radio" value="Meetings"      /> ' + L10n.Term("Calls.LNK_NEW_MEETING");
					// sHTML += '		</td>';
					// sHTML += '		<td />';
					// sHTML += '		<td />';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);

					// 01/09/2018 Paul.  Allow Calls or meetings to be disabled. 
					var divScheduleCall = document.createElement('div');
					td.appendChild(divScheduleCall);
					var divNewAppointmentPopup_radScheduleCall = document.createElement('input');
					divNewAppointmentPopup_radScheduleCall.id           = 'divNewAppointmentPopup_radScheduleCall';
					divNewAppointmentPopup_radScheduleCall.name         = 'grpSchedule';
					divNewAppointmentPopup_radScheduleCall.type         = 'radio'      ;
					divNewAppointmentPopup_radScheduleCall.value        = 'Calls'      ;
					divNewAppointmentPopup_radScheduleCall.className    = 'radio'      ;
					divScheduleCall.appendChild(divNewAppointmentPopup_radScheduleCall);
					divNewAppointmentPopup_radScheduleCall.checked      = true;
					txt = document.createTextNode(L10n.Term('Calls.LNK_NEW_CALL') + nbsp + nbsp);
					divScheduleCall.appendChild(txt);
					
					td = document.createElement('td');
					tr.appendChild(td);
					var divScheduleMeeting = document.createElement('div');
					td.appendChild(divScheduleMeeting);
					var divNewAppointmentPopup_radScheduleMeeting = document.createElement('input');
					// 01/28/2018 Paul.  Correct id, should be divNewAppointmentPopup_radScheduleMeeting. 
					divNewAppointmentPopup_radScheduleMeeting.id        = 'divNewAppointmentPopup_radScheduleMeeting';
					divNewAppointmentPopup_radScheduleMeeting.name      = 'grpSchedule';
					divNewAppointmentPopup_radScheduleMeeting.type      = 'radio'      ;
					divNewAppointmentPopup_radScheduleMeeting.value     = 'Meetings'   ;
					divNewAppointmentPopup_radScheduleMeeting.className = 'radio'      ;
					divScheduleMeeting.appendChild(divNewAppointmentPopup_radScheduleMeeting);
					txt = document.createTextNode(L10n.Term('Meetings.LNK_NEW_MEETING'));
					divScheduleMeeting.appendChild(txt);
					
					// 01/09/2018 Paul.  If Calls disabled, use the Meetings module for the labels. 
					var sModuleLabel = 'Calls';
					if ( bgPage.SplendidCache.Module('Calls') === undefined )
					{
						sModuleLabel = 'Meetings';
						divNewAppointmentPopup_radScheduleCall.checked      = false;
						divNewAppointmentPopup_radScheduleMeeting.checked   = true;
						divScheduleCall.style.display = 'none';
					}
					else if ( bgPage.SplendidCache.Module('Meetings') === undefined )
					{
						divScheduleMeeting.style.display = 'none';
					}

					td = document.createElement('td');
					tr.appendChild(td);
					td = document.createElement('td');
					tr.appendChild(td);

					// sHTML += '	<tr>';
					// sHTML += '		<td colspan="4" height="5px"></td>';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					td.setAttribute('colspan', '4'  );
					td.setAttribute('height' , '5px');
					
					// sHTML += '	<tr>';
					// sHTML += '		<td>';
					// sHTML += '			' + L10n.Term("Calls.LBL_SUBJECT") + ' <span class="required">' + L10n.Term(".LBL_REQUIRED_SYMBOL") + '</>';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			<input type="text" ID="divNewAppointmentPopup_txtNAME" size="30" maxlength="255" />';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			<span ID="divNewAppointmentPopup_reqNAME" class="required" style="display:none">' + L10n.Term(".ERR_REQUIRED_FIELD") + '</span>';
					// sHTML += '		</td>';
					// sHTML += '		<td />';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					txt = document.createTextNode(L10n.Term(sModuleLabel + '.LBL_SUBJECT'));
					td.appendChild(txt);
					spn = document.createElement('span');
					spn.className = 'required';
					td.appendChild(spn);
					txt = document.createTextNode(L10n.Term('.LBL_REQUIRED_SYMBOL'));
					spn.appendChild(txt);
					td = document.createElement('td');
					tr.appendChild(td);
					td.setAttribute('colspan', '3'  );
					var divNewAppointmentPopup_txtNAME = document.createElement('input');
					divNewAppointmentPopup_txtNAME.id            = 'divNewAppointmentPopup_txtNAME';
					divNewAppointmentPopup_txtNAME.type          = 'text' ;
					divNewAppointmentPopup_txtNAME.maxLength     = '255'  ;
					divNewAppointmentPopup_txtNAME.style.width   = '100%' ;
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						divNewAppointmentPopup_txtNAME.className = 'form-control';
					td.appendChild(divNewAppointmentPopup_txtNAME);

					td = document.createElement('td');
					tr.appendChild(td);
					var divNewAppointmentPopup_reqNAME = document.createElement('span');
					divNewAppointmentPopup_reqNAME.id            = 'divNewAppointmentPopup_reqNAME';
					divNewAppointmentPopup_reqNAME.className     = 'required';
					divNewAppointmentPopup_reqNAME.style.display = 'none';
					td.appendChild(divNewAppointmentPopup_reqNAME);
					txt = document.createTextNode(nbsp + nbsp + L10n.Term('.ERR_REQUIRED_FIELD'));
					divNewAppointmentPopup_reqNAME.appendChild(txt);
					td = document.createElement('td');
					tr.appendChild(td);
					
					// sHTML += '	</tr>';
					// sHTML += '		<td>';
					// sHTML += '			' + L10n.Term("Calls.LBL_DATE_TIME") + ' <span class="required">' + L10n.Term(".LBL_REQUIRED_SYMBOL") + '</>';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			<input type="text" ID="divNewAppointmentPopup_txtDATE_START" size="15" readonly="true" />';
					// sHTML += '		</td>';
					// sHTML += '		<td />';
					// sHTML += '		<td />';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					txt = document.createTextNode(L10n.Term(sModuleLabel + '.LBL_DATE_TIME'));
					td.appendChild(txt);
					spn = document.createElement('span');
					spn.className = 'required';
					td.appendChild(spn);
					txt = document.createTextNode(L10n.Term('.LBL_REQUIRED_SYMBOL'));
					spn.appendChild(txt);
					td = document.createElement('td');
					tr.appendChild(td);
					var divNewAppointmentPopup_txtDATE_START = document.createElement('input');
					divNewAppointmentPopup_txtDATE_START.id          = 'divNewAppointmentPopup_DATE_START';
					divNewAppointmentPopup_txtDATE_START.type        = 'text';
					divNewAppointmentPopup_txtDATE_START.readOnly    = true  ;
					divNewAppointmentPopup_txtDATE_START.style.width = '100%';
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						divNewAppointmentPopup_txtDATE_START.className = 'form-control';
					td.appendChild(divNewAppointmentPopup_txtDATE_START);
					td = document.createElement('td');
					tr.appendChild(td);
					
					// 03/10/2013 Paul.  Add ALL_DAY_EVENT. 
					//if ( ALL_DAY_EVENT )
					var chkALL_DAY_EVENT = document.createElement('input');
					chkALL_DAY_EVENT.id        = 'divNewAppointmentPopup_ALL_DAY_EVENT';
					chkALL_DAY_EVENT.type      = 'checkbox';
					chkALL_DAY_EVENT.className = 'checkbox';
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						chkALL_DAY_EVENT.className = 'form-control';
					td.appendChild(chkALL_DAY_EVENT);
					// 03/10/2013 Paul.  The checked flag must be set after adding. 
					chkALL_DAY_EVENT.checked   = ALL_DAY_EVENT;
					chkALL_DAY_EVENT.onclick   = function()
					{
						if ( chkALL_DAY_EVENT.checked )
						{
							divNewAppointmentPopup_lstDURATION_MINUTES.selectedIndex = 0;
							divNewAppointmentPopup_txtDURATION_HOURS.value = 24;
							divNewAppointmentPopup_txtDATE_START.value = $.fullCalendar.formatDate(start, context.ShortDatePattern);
						}
						else
						{
							divNewAppointmentPopup_txtDATE_START.value = $.fullCalendar.formatDate(start, context.ShortDatePattern) + ' ' + $.fullCalendar.formatDate(start, context.ShortTimePattern);
							divNewAppointmentPopup_txtDURATION_HOURS.value = 1;
						}
					};
					td = document.createElement('td');
					tr.appendChild(td);
					txt = document.createTextNode(nbsp + nbsp + L10n.Term(sModuleLabel + '.LBL_ALL_DAY'));
					td.appendChild(txt);
					td = document.createElement('td');
					tr.appendChild(td);
					
					// sHTML += '	<tr>';
					// sHTML += '		<td>';
					// sHTML += '			' + L10n.Term("Calls.LBL_DURATION") + ' <span class="required">' + L10n.Term(".LBL_REQUIRED_SYMBOL") + '</>';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			<input type="text" ID="divNewAppointmentPopup_txtDURATION_HOURS"   size="5" />';
					// sHTML += '			<select ID="divNewAppointmentPopup_lstDURATION_MINUTES">';
					// sHTML += '				<option value="0">0</option>';
					// sHTML += '				<option value="15">15</option>';
					// sHTML += '				<option value="30">30</option>';
					// sHTML += '				<option value="45">45</option>';
					// sHTML += '			</select>';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			&nbsp;' + L10n.Term("Calls.LBL_HOURS_MINUTES");
					// sHTML += '		</td>';
					// sHTML += '		<td />';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					txt = document.createTextNode(L10n.Term(sModuleLabel + '.LBL_DURATION'));
					td.appendChild(txt);
					spn = document.createElement('span');
					spn.className = 'required';
					td.appendChild(spn);
					txt = document.createTextNode(L10n.Term('.LBL_REQUIRED_SYMBOL'));
					spn.appendChild(txt);
					td = document.createElement('td');
					tr.appendChild(td);
					td.setAttribute('colspan', '3'  );
					
					// 01/09/2018 Paul.  Need to fix buttons when running bootstrap. 
					var spnInputs = document.createElement('div');
					td.appendChild(spnInputs);
					var divNewAppointmentPopup_txtDURATION_HOURS = document.createElement('input');
					divNewAppointmentPopup_txtDURATION_HOURS.id            = 'divNewAppointmentPopup_DURATION_HOURS';
					divNewAppointmentPopup_txtDURATION_HOURS.type          = 'text';
					divNewAppointmentPopup_txtDURATION_HOURS.style.width   = '50px';
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
					{
						divNewAppointmentPopup_txtDURATION_HOURS.className = 'form-control';
						td.className = 'input-group';
					}
					spnInputs.appendChild(divNewAppointmentPopup_txtDURATION_HOURS);

					txt = document.createTextNode(nbsp + nbsp);
					spnInputs.appendChild(txt);
					var divNewAppointmentPopup_lstDURATION_MINUTES = document.createElement('select');
					divNewAppointmentPopup_lstDURATION_MINUTES.id          = 'divNewAppointmentPopup_DURATION_MINUTES';
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						divNewAppointmentPopup_lstDURATION_MINUTES.className = 'form-control';
					spnInputs.appendChild(divNewAppointmentPopup_lstDURATION_MINUTES);
					
					for ( var nMinutes = 0; nMinutes < 60; nMinutes += 15 )
					{
						var opt = document.createElement('option');
						divNewAppointmentPopup_lstDURATION_MINUTES.appendChild(opt);
						opt.setAttribute('value', nMinutes.toString());
						opt.innerHTML = nMinutes.toString();
						if ( nMinutes == DURATION_MINUTES )
							opt.setAttribute('selected', 'selected');
					}
					td = document.createElement('td');
					tr.appendChild(td);
					txt = document.createTextNode(nbsp + nbsp + L10n.Term(sModuleLabel + '.LBL_HOURS_MINUTES') + nbsp + nbsp);
					td.appendChild(txt);
					
					// 01/30/2016 Paul.  Add Parent and Description. 
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					td.vAlign = 'top';
					var divNewAppointmentPopup_lstPARENT_TYPE = document.createElement('select');
					divNewAppointmentPopup_lstPARENT_TYPE.id = 'divNewAppointmentPopup_lstPARENT_TYPE';
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						divNewAppointmentPopup_lstPARENT_TYPE.className = 'form-control';
					td.appendChild(divNewAppointmentPopup_lstPARENT_TYPE);
					try
					{
						var sLIST_NAME = 'record_type_display';
						var arrLIST = L10n.GetList(sLIST_NAME);
						if ( arrLIST != null )
						{
							var lst = divNewAppointmentPopup_lstPARENT_TYPE;
							for ( var i = 0; i < arrLIST.length; i++ )
							{
								var opt = document.createElement('option');
								lst.appendChild(opt);
								opt.setAttribute('value', arrLIST[i]);
								opt.innerHTML = L10n.ListTerm(sLIST_NAME, arrLIST[i]);
							}
						}
					}
					catch(e)
					{
						alert(e.Message);
					}
					td = document.createElement('td');
					td.setAttribute('colspan', '3'  );
					
					// 01/09/2018 Paul.  Need to fix buttons when running bootstrap. 
					spnInputs = document.createElement('div');
					td.appendChild(spnInputs);
					var divNewAppointmentPopup_txtPARENT_NAME = document.createElement('input');
					divNewAppointmentPopup_txtPARENT_NAME.id            = 'divNewAppointmentPopup_txtPARENT_NAME';
					divNewAppointmentPopup_txtPARENT_NAME.type          = 'text' ;
					divNewAppointmentPopup_txtPARENT_NAME.maxLength     = '255'  ;
					divNewAppointmentPopup_txtPARENT_NAME.style.width   = '200px';
					divNewAppointmentPopup_txtPARENT_NAME.readOnly      = true;
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						divNewAppointmentPopup_txtPARENT_NAME.className = 'form-control';
					spnInputs.appendChild(divNewAppointmentPopup_txtPARENT_NAME);
					var divNewAppointmentPopup_txtPARENT_ID = document.createElement('input');
					divNewAppointmentPopup_txtPARENT_ID.id              = 'divNewAppointmentPopup_txtPARENT_ID';
					divNewAppointmentPopup_txtPARENT_ID.type            = 'text' ;
					divNewAppointmentPopup_txtPARENT_ID.style.display   = 'none' ;
					spnInputs.appendChild(divNewAppointmentPopup_txtPARENT_ID);
					txt = document.createTextNode(nbsp);
					spnInputs.appendChild(txt);
					
					// 01/09/2018 Paul.  Need to fix buttons when running bootstrap. 
					var divNewAppointmentPopup_btnParentSelect = null;
					if ( !SplendidDynamic.BootstrapLayout() )
					{
						divNewAppointmentPopup_btnParentSelect = document.createElement('input');
						divNewAppointmentPopup_btnParentSelect.id          = 'divNewAppointmentPopup_btnParentSelect';
						divNewAppointmentPopup_btnParentSelect.type        = 'button';
						divNewAppointmentPopup_btnParentSelect.className   = 'button';
						divNewAppointmentPopup_btnParentSelect.value       = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
						divNewAppointmentPopup_btnParentSelect.title       = L10n.Term('.LBL_SELECT_BUTTON_TITLE');
						divNewAppointmentPopup_btnParentSelect.style.marginTop = '10px';
						spnInputs.appendChild(divNewAppointmentPopup_btnParentSelect);
						txt = document.createTextNode(nbsp);
						spnInputs.appendChild(txt);
					}
					else
					{
						spnInputs.className = 'input-group';
						divNewAppointmentPopup_btnParentSelect = document.createElement('button');
						spnInputs.appendChild(divNewAppointmentPopup_btnParentSelect);
						divNewAppointmentPopup_btnParentSelect.id        = 'divNewAppointmentPopup_btnParentSelect';
						divNewAppointmentPopup_btnParentSelect.className = 'btn btn-default';
						var glyph = document.createElement('span');
						glyph.className = 'glyphicon glyphicon-edit';
						divNewAppointmentPopup_btnParentSelect.appendChild(glyph);
					}
					// 01/09/2018 Paul.  Need to fix buttons when running bootstrap. 
					var divNewAppointmentPopup_btnParentClear = null;
					if ( !SplendidDynamic.BootstrapLayout() )
					{
						divNewAppointmentPopup_btnParentClear = document.createElement('input');
						divNewAppointmentPopup_btnParentClear.id        = 'divNewAppointmentPopup_btnParentClear';
						divNewAppointmentPopup_btnParentClear.type      = 'button';
						divNewAppointmentPopup_btnParentClear.className = 'button';
						divNewAppointmentPopup_btnParentClear.value     = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
						divNewAppointmentPopup_btnParentClear.title     = L10n.Term('.LBL_CLEAR_BUTTON_TITLE');
						spnInputs.appendChild(divNewAppointmentPopup_btnParentClear);
					}
					else
					{
						divNewAppointmentPopup_btnParentClear = document.createElement('button');
						spnInputs.appendChild(divNewAppointmentPopup_btnParentClear);
						divNewAppointmentPopup_btnParentClear.id        = 'divNewAppointmentPopup_btnParentClear';
						divNewAppointmentPopup_btnParentClear.className = 'btn btn-default';
						var glyph = document.createElement('span');
						glyph.className = 'glyphicon glyphicon-remove';
						divNewAppointmentPopup_btnParentClear.appendChild(glyph);
					}
					tr.appendChild(td);
					divNewAppointmentPopup_btnParentSelect.onclick = BindArguments(function(txt, hid, lstField)
					{
						var sMODULE_TYPE = lstField.options[lstField.options.selectedIndex].value;
						var $dialog = $('<div id="' + hid.id + '_divPopup"><div id="divPopupActionsPanel" /><div id="divPopupLayoutPanel" /></div>');
						$dialog.dialog(
						{
							  modal    : true
							, resizable: true
							// 04/13/2017 Paul.  Use Bootstrap for responsive design.
							, position : { of: '#divMainPageContent' }
							, width    : $('#divMainPageContent').width() > 0 ? ($('#divMainPageContent').width() - 60) : 800
							// 04/26/2017 Paul.  Use Bootstrap for responsive design.
							//, height   : (navigator.userAgent.indexOf('iPad') > 0 ? 'auto' : ($(window).height() > 0 ? $(window).height() - 60 : 800))
							// 07/19/2018 Paul.  Laptop windows are smaller, so we need to use that as the max. 
							//, height   : $('#divMainPageContent').height() > 0 ? $('#divMainPageContent').height() - 60 : 800
							, height   : $(window).height() > 0 ? $(window).height() - 60 : 800
							, title    : L10n.Term(sMODULE_TYPE + '.LBL_LIST_FORM_TITLE')
							, create   : function(event, ui)
							{
								try
								{
									var oPopupViewUI = new PopupViewUI();
									oPopupViewUI.Load('divPopupLayoutPanel', 'divPopupActionsPanel', sMODULE_TYPE, false, function(status, message)
									{
										if ( status == 1 )
										{
											hid.value = message.ID  ;
											txt.value = message.NAME;
											// 02/21/2013 Paul.  Use close instead of destroy. 
											$dialog.dialog('close');
										}
										else if ( status == -2 )
										{
											// 02/21/2013 Paul.  Use close instead of destroy. 
											$dialog.dialog('close');
										}
										else if ( status == -1 )
										{
											SplendidError.SystemMessage(message);
										}
									});
								}
								catch(e)
								{
									SplendidError.SystemError(e, 'PopupViewUI dialog');
								}
							}
							, close    : function(event, ui)
							{
								$dialog.dialog('destroy');
								// 10/17/2011 Paul.  We have to remove the new HTML, otherwise there will be multiple definitions for divPopupLayoutPanel. 
								var divPopup = document.getElementById(hid.id + '_divPopup');
								divPopup.parentNode.removeChild(divPopup);
							}
						});
					}, divNewAppointmentPopup_txtPARENT_NAME, divNewAppointmentPopup_txtPARENT_ID, divNewAppointmentPopup_lstPARENT_TYPE);
					divNewAppointmentPopup_btnParentClear.onclick = function()
					{
						var divNewAppointmentPopup_txtPARENT_NAME = document.getElementById('divNewAppointmentPopup_txtPARENT_NAME');
						var divNewAppointmentPopup_txtPARENT_ID   = document.getElementById('divNewAppointmentPopup_txtPARENT_ID'  );
						divNewAppointmentPopup_txtPARENT_NAME.value = '';
						divNewAppointmentPopup_txtPARENT_ID  .value = '';
					};
					divNewAppointmentPopup_lstPARENT_TYPE.onchange = function(e)
					{
						var sMODULE_TYPE = divNewAppointmentPopup_lstPARENT_TYPE.options[divNewAppointmentPopup_lstPARENT_TYPE.options.selectedIndex].value;
						var divNewAppointmentPopup_txtPARENT_NAME = document.getElementById('divNewAppointmentPopup_txtPARENT_NAME');
						var divNewAppointmentPopup_txtPARENT_ID   = document.getElementById('divNewAppointmentPopup_txtPARENT_ID'  );
						divNewAppointmentPopup_txtPARENT_NAME.value = '';
						divNewAppointmentPopup_txtPARENT_ID  .value = '';
					};
					
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					txt = document.createTextNode(L10n.Term(sModuleLabel + '.LBL_DESCRIPTION'));
					td.appendChild(txt);
					td = document.createElement('td');
					td.setAttribute('colspan', '3'  );
					var divNewAppointmentPopup_txtDESCRIPTION = document.createElement('textarea');
					divNewAppointmentPopup_txtDESCRIPTION.id   = 'divNewAppointmentPopup_txtDESCRIPTION';
					divNewAppointmentPopup_txtDESCRIPTION.rows = '2' ;
					divNewAppointmentPopup_txtDESCRIPTION.style.width = '100%';
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						divNewAppointmentPopup_txtDESCRIPTION.className = 'form-control';
					td.appendChild(divNewAppointmentPopup_txtDESCRIPTION);
					tr.appendChild(td);
					
					// sHTML += '	<tr>';
					// sHTML += '		<td>';
					// sHTML += '			' + L10n.Term("Calendar.LBL_REPEAT_TAB") + '</>';
					// sHTML += '		</td>';
					// sHTML += '		<td />';
					// sHTML += '		<td />';
					// sHTML += '		<td />';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					var h4 = document.createElement('h4');
					td.appendChild(h4);
					txt = document.createTextNode(L10n.Term('Calendar.LBL_REPEAT_TAB'));
					h4.appendChild(txt);
					h4.style.marginTop = '10px';
					td = document.createElement('td');
					tr.appendChild(td);
					td = document.createElement('td');
					tr.appendChild(td);
					td = document.createElement('td');
					tr.appendChild(td);

					// sHTML += '	<tr>';
					// sHTML += '		<td>';
					// sHTML += '			' + L10n.Term("Calls.LBL_REPEAT_TYPE") + '</>';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			<input type="text" ID="divNewAppointmentPopup_txtREPEAT_TYPE" size="30" maxlength="255" />';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			' + L10n.Term("Calendar.LBL_REPEAT_END_AFTER") + '</>';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			<input type="text" ID="divNewAppointmentPopup_txtREPEAT_COUNT" size="30" maxlength="255" />';
					// sHTML += '		</td>';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					txt = document.createTextNode(L10n.Term(sModuleLabel + '.LBL_REPEAT_TYPE'));
					td.appendChild(txt);
					td = document.createElement('td');
					tr.appendChild(td);
					var divNewAppointmentPopup_lstREPEAT_TYPE = document.createElement('select');
					divNewAppointmentPopup_lstREPEAT_TYPE.id = 'divNewAppointmentPopup_lstREPEAT_TYPE';
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						divNewAppointmentPopup_lstREPEAT_TYPE.className = 'form-control';
					td.appendChild(divNewAppointmentPopup_lstREPEAT_TYPE);
					
					try
					{
						var sLIST_NAME = 'repeat_type_dom';
						var arrLIST = L10n.GetList(sLIST_NAME);
						if ( arrLIST != null )
						{
							var lst = divNewAppointmentPopup_lstREPEAT_TYPE;
							var opt = document.createElement('option');
							lst.appendChild(opt);
							opt.setAttribute('value', '');
							opt.innerHTML = L10n.Term('.LBL_NONE');
							for ( var i = 0; i < arrLIST.length; i++ )
							{
								var opt = document.createElement('option');
								lst.appendChild(opt);
								opt.setAttribute('value', arrLIST[i]);
								opt.innerHTML = L10n.ListTerm(sLIST_NAME, arrLIST[i]);
							}
						}
					}
					catch(e)
					{
						alert(e.Message);
					}
					
					td = document.createElement('td');
					tr.appendChild(td);
					var divNewAppointmentPopup_divREPEAT_COUNT_LABEL = document.createElement('div');
					divNewAppointmentPopup_divREPEAT_COUNT_LABEL.id = 'divNewAppointmentPopup_divREPEAT_COUNT_LABEL';
					divNewAppointmentPopup_divREPEAT_COUNT_LABEL.style.display = 'none';
					td.appendChild(divNewAppointmentPopup_divREPEAT_COUNT_LABEL);
					txt = document.createTextNode(L10n.Term('Calendar.LBL_REPEAT_END_AFTER'));
					divNewAppointmentPopup_divREPEAT_COUNT_LABEL.appendChild(txt);
					
					td = document.createElement('td');
					tr.appendChild(td);
					var divNewAppointmentPopup_divREPEAT_COUNT = document.createElement('div');
					divNewAppointmentPopup_divREPEAT_COUNT.id = 'divNewAppointmentPopup_divREPEAT_COUNT';
					divNewAppointmentPopup_divREPEAT_COUNT.style.display = 'none';
					td.appendChild(divNewAppointmentPopup_divREPEAT_COUNT);
					var divNewAppointmentPopup_txtREPEAT_COUNT = document.createElement('input');
					divNewAppointmentPopup_txtREPEAT_COUNT.id            = 'divNewAppointmentPopup_txtREPEAT_COUNT';
					divNewAppointmentPopup_txtREPEAT_COUNT.type          = 'text' ;
					divNewAppointmentPopup_txtREPEAT_COUNT.style.width   = '50px';
					divNewAppointmentPopup_divREPEAT_COUNT.appendChild(divNewAppointmentPopup_txtREPEAT_COUNT);
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						divNewAppointmentPopup_txtREPEAT_COUNT.className = 'form-control';
					txt = document.createTextNode(nbsp + nbsp + L10n.Term('Calendar.LBL_REPEAT_OCCURRENCES'));
					divNewAppointmentPopup_divREPEAT_COUNT.appendChild(txt);

					// sHTML += '	<tr>';
					// sHTML += '		<td>';
					// sHTML += '			' + L10n.Term("Calendar.LBL_REPEAT_INTERVAL") + '</>';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			<input type="text" ID="divNewAppointmentPopup_txtREPEAT_INTERVAL" size="30" maxlength="255" />';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			' + L10n.Term("Calls.LBL_REPEAT_UNTIL") + '</>';
					// sHTML += '		</td>';
					// sHTML += '		<td>';
					// sHTML += '			<input type="text" ID="divNewAppointmentPopup_txtREPEAT_UNTIL" size="30" maxlength="255" />';
					// sHTML += '		</td>';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					var divNewAppointmentPopup_divREPEAT_INTERVAL_LABEL = document.createElement('div');
					divNewAppointmentPopup_divREPEAT_INTERVAL_LABEL.id = 'divNewAppointmentPopup_divREPEAT_INTERVAL_LABEL';
					divNewAppointmentPopup_divREPEAT_INTERVAL_LABEL.style.display = 'none';
					td.appendChild(divNewAppointmentPopup_divREPEAT_INTERVAL_LABEL);
					txt = document.createTextNode(L10n.Term('Calendar.LBL_REPEAT_INTERVAL'));
					divNewAppointmentPopup_divREPEAT_INTERVAL_LABEL.appendChild(txt);
					td = document.createElement('td');
					tr.appendChild(td);
					var divNewAppointmentPopup_divREPEAT_INTERVAL = document.createElement('div');
					divNewAppointmentPopup_divREPEAT_INTERVAL.id = 'divNewAppointmentPopup_divREPEAT_INTERVAL';
					divNewAppointmentPopup_divREPEAT_INTERVAL.style.display = 'none';
					td.appendChild(divNewAppointmentPopup_divREPEAT_INTERVAL);
					var divNewAppointmentPopup_txtREPEAT_INTERVAL = document.createElement('input');
					divNewAppointmentPopup_txtREPEAT_INTERVAL.id            = 'divNewAppointmentPopup_txtREPEAT_INTERVAL';
					divNewAppointmentPopup_txtREPEAT_INTERVAL.type          = 'text' ;
					divNewAppointmentPopup_txtREPEAT_INTERVAL.style.width   = '50px';
					divNewAppointmentPopup_divREPEAT_INTERVAL.appendChild(divNewAppointmentPopup_txtREPEAT_INTERVAL);
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						divNewAppointmentPopup_txtREPEAT_INTERVAL.className = 'form-control';
					
					td = document.createElement('td');
					tr.appendChild(td);
					var divNewAppointmentPopup_divREPEAT_UNTIL_LABEL = document.createElement('div');
					divNewAppointmentPopup_divREPEAT_UNTIL_LABEL.id = 'divNewAppointmentPopup_divREPEAT_UNTIL_LABEL';
					divNewAppointmentPopup_divREPEAT_UNTIL_LABEL.style.display = 'none';
					td.appendChild(divNewAppointmentPopup_divREPEAT_UNTIL_LABEL);
					txt = document.createTextNode(L10n.Term(sModuleLabel + '.LBL_REPEAT_UNTIL'));
					divNewAppointmentPopup_divREPEAT_UNTIL_LABEL.appendChild(txt);
					td = document.createElement('td');
					tr.appendChild(td);
					var divNewAppointmentPopup_divREPEAT_UNTIL = document.createElement('div');
					divNewAppointmentPopup_divREPEAT_UNTIL.id = 'divNewAppointmentPopup_divREPEAT_UNTIL';
					divNewAppointmentPopup_divREPEAT_UNTIL.style.display = 'none';
					td.appendChild(divNewAppointmentPopup_divREPEAT_UNTIL);
					var divNewAppointmentPopup_txtREPEAT_UNTIL = document.createElement('input');
					divNewAppointmentPopup_txtREPEAT_UNTIL.id            = 'divNewAppointmentPopup_txtREPEAT_UNTIL';
					divNewAppointmentPopup_txtREPEAT_UNTIL.type          = 'text';
					divNewAppointmentPopup_txtREPEAT_UNTIL.style.width   = '80px';
					divNewAppointmentPopup_divREPEAT_UNTIL.appendChild(divNewAppointmentPopup_txtREPEAT_UNTIL);
					// 01/09/2018 Paul.  Use Bootstrap for responsive design.
					if ( SplendidDynamic.BootstrapLayout() )
						divNewAppointmentPopup_divREPEAT_UNTIL.className = 'form-control';
					var sDATE_FORMAT = Security.USER_DATE_FORMAT();
					var sTIME_FORMAT = Security.USER_TIME_FORMAT();
					sDATE_FORMAT = sDATE_FORMAT.replace('yyyy', 'yy');
					sDATE_FORMAT = sDATE_FORMAT.replace('MM'  , 'mm');
					//var bAMPM        = (sTIME_FORMAT.indexOf('t') >= 0) || (sTIME_FORMAT.indexOf('T') >= 0);
					//$('#' + divNewAppointmentPopup_txtREPEAT_UNTIL.id).datetimepicker( { dateFormat: sDATE_FORMAT, timeFormat: sTIME_FORMAT, ampm: bAMPM } );
					$('#' + divNewAppointmentPopup_txtREPEAT_UNTIL.id).datepicker( { dateFormat: sDATE_FORMAT } );
					
					// sHTML += '	<tr>';
					// sHTML += '		<td>';
					// sHTML += '			' + L10n.Term("Calls.LBL_REPEAT_DOW") + '</>';
					// sHTML += '		</td>';
					// sHTML += '		<td colspan="3">';
					// sHTML += '			<input type="checkbox" ID="divNewAppointmentPopup_chkSunday"    value="0" class="checkbox" />';
					// sHTML += '			<input type="checkbox" ID="divNewAppointmentPopup_chkMonday"    value="1" class="checkbox" />';
					// sHTML += '			<input type="checkbox" ID="divNewAppointmentPopup_chkTuesday"   value="2" class="checkbox" />';
					// sHTML += '			<input type="checkbox" ID="divNewAppointmentPopup_chkWednesday" value="3" class="checkbox" />';
					// sHTML += '			<input type="checkbox" ID="divNewAppointmentPopup_chkThursday"  value="4" class="checkbox" />';
					// sHTML += '			<input type="checkbox" ID="divNewAppointmentPopup_chkFriday"    value="5" class="checkbox" />';
					// sHTML += '			<input type="checkbox" ID="divNewAppointmentPopup_chkSaturday"  value="6" class="checkbox" />';
					// sHTML += '		</td>';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					var divNewAppointmentPopup_divREPEAT_DOW_LABEL = document.createElement('div');
					divNewAppointmentPopup_divREPEAT_DOW_LABEL.id = 'divNewAppointmentPopup_divREPEAT_DOW_LABEL';
					divNewAppointmentPopup_divREPEAT_DOW_LABEL.style.display = 'none';
					td.appendChild(divNewAppointmentPopup_divREPEAT_DOW_LABEL);
					txt = document.createTextNode(L10n.Term(sModuleLabel + '.LBL_REPEAT_DOW'));
					divNewAppointmentPopup_divREPEAT_DOW_LABEL.appendChild(txt);
					td = document.createElement('td');
					tr.appendChild(td);
					td.setAttribute('colspan', '3'  );
					td.style.whiteSpace = 'nowrap';
					var divNewAppointmentPopup_divREPEAT_DOW = document.createElement('table');
					divNewAppointmentPopup_divREPEAT_DOW.id = 'divNewAppointmentPopup_divREPEAT_DOW';
					divNewAppointmentPopup_divREPEAT_DOW.style.display = 'none';
					divNewAppointmentPopup_divREPEAT_DOW.style.width = '100%';
					td.appendChild(divNewAppointmentPopup_divREPEAT_DOW);
					var tbodyNewAppointmentPopup_divREPEAT_DOW = document.createElement('tbody');
					divNewAppointmentPopup_divREPEAT_DOW.appendChild(tbodyNewAppointmentPopup_divREPEAT_DOW);
					tr = document.createElement('tr');
					tbodyNewAppointmentPopup_divREPEAT_DOW.appendChild(tr);

					arrLIST = L10n.GetListTerms('short_day_names_dom');
					var divNewAppointmentPopup_chkSunday = document.createElement('input');
					divNewAppointmentPopup_chkSunday.id        = 'divNewAppointmentPopup_chkSunday';
					divNewAppointmentPopup_chkSunday.type      = 'checkbox';
					divNewAppointmentPopup_chkSunday.className = (SplendidDynamic.BootstrapLayout() ? 'form-control' : 'checkbox');
					divNewAppointmentPopup_chkSunday.value     = '0';
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(divNewAppointmentPopup_chkSunday);
					txt = document.createTextNode(nbsp + arrLIST[0] + nbsp + nbsp);
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(txt);

					var divNewAppointmentPopup_chkMonday = document.createElement('input');
					divNewAppointmentPopup_chkMonday.id        = 'divNewAppointmentPopup_chkMonday';
					divNewAppointmentPopup_chkMonday.type      = 'checkbox';
					divNewAppointmentPopup_chkMonday.className = (SplendidDynamic.BootstrapLayout() ? 'form-control' : 'checkbox');
					divNewAppointmentPopup_chkMonday.value     = '1';
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(divNewAppointmentPopup_chkMonday);
					txt = document.createTextNode(nbsp + arrLIST[1] + nbsp + nbsp);
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(txt);

					var divNewAppointmentPopup_chkTuesday = document.createElement('input');
					divNewAppointmentPopup_chkTuesday.id        = 'divNewAppointmentPopup_chkTuesday';
					divNewAppointmentPopup_chkTuesday.type      = 'checkbox';
					divNewAppointmentPopup_chkTuesday.className = (SplendidDynamic.BootstrapLayout() ? 'form-control' : 'checkbox');
					divNewAppointmentPopup_chkTuesday.value     = '2';
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(divNewAppointmentPopup_chkTuesday);
					txt = document.createTextNode(nbsp + arrLIST[2] + nbsp + nbsp);
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(txt);

					var divNewAppointmentPopup_chkWednesday = document.createElement('input');
					divNewAppointmentPopup_chkWednesday.id        = 'divNewAppointmentPopup_chkWednesday';
					divNewAppointmentPopup_chkWednesday.type      = 'checkbox';
					divNewAppointmentPopup_chkWednesday.className = (SplendidDynamic.BootstrapLayout() ? 'form-control' : 'checkbox');
					divNewAppointmentPopup_chkWednesday.value     = '3';
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(divNewAppointmentPopup_chkWednesday);
					txt = document.createTextNode(nbsp + arrLIST[3] + nbsp + nbsp);
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(txt);

					var divNewAppointmentPopup_chkThursday = document.createElement('input');
					divNewAppointmentPopup_chkThursday.id        = 'divNewAppointmentPopup_chkThursday';
					divNewAppointmentPopup_chkThursday.type      = 'checkbox';
					divNewAppointmentPopup_chkThursday.className = (SplendidDynamic.BootstrapLayout() ? 'form-control' : 'checkbox');
					divNewAppointmentPopup_chkThursday.value     = '4';
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(divNewAppointmentPopup_chkThursday);
					txt = document.createTextNode(nbsp + arrLIST[4] + nbsp + nbsp);
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(txt);

					var divNewAppointmentPopup_chkFriday = document.createElement('input');
					divNewAppointmentPopup_chkFriday.id        = 'divNewAppointmentPopup_chkFriday';
					divNewAppointmentPopup_chkFriday.type      = 'checkbox';
					divNewAppointmentPopup_chkFriday.className = (SplendidDynamic.BootstrapLayout() ? 'form-control' : 'checkbox');
					divNewAppointmentPopup_chkFriday.value     = '5';
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(divNewAppointmentPopup_chkFriday);
					txt = document.createTextNode(nbsp + arrLIST[5] + nbsp + nbsp);
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(txt);

					var divNewAppointmentPopup_chkSaturday = document.createElement('input');
					divNewAppointmentPopup_chkSaturday.id        = 'divNewAppointmentPopup_chkSaturday';
					divNewAppointmentPopup_chkSaturday.type      = 'checkbox';
					divNewAppointmentPopup_chkSaturday.className = (SplendidDynamic.BootstrapLayout() ? 'form-control' : 'checkbox');
					divNewAppointmentPopup_chkSaturday.value     = '6';
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(divNewAppointmentPopup_chkSaturday);
					txt = document.createTextNode(nbsp + arrLIST[6] + nbsp + nbsp);
					td = document.createElement('td');
					tr.appendChild(td);
					td.appendChild(txt);
					if ( SplendidDynamic.BootstrapLayout() )
					{
						divNewAppointmentPopup_chkSunday   .style.transform = 'scale(1.5)';
						divNewAppointmentPopup_chkMonday   .style.transform = 'scale(1.5)';
						divNewAppointmentPopup_chkTuesday  .style.transform = 'scale(1.5)';
						divNewAppointmentPopup_chkWednesday.style.transform = 'scale(1.5)';
						divNewAppointmentPopup_chkThursday .style.transform = 'scale(1.5)';
						divNewAppointmentPopup_chkFriday   .style.transform = 'scale(1.5)';
						divNewAppointmentPopup_chkSaturday .style.transform = 'scale(1.5)';
					}
					
					// sHTML += '	<tr>';
					// sHTML += '		<td></td>';
					// sHTML += '		<td>';
					// sHTML += '			<input type="button" ID="divNewAppointmentPopup_btnSave"   value="' + "  " + L10n.Term(".LBL_SAVE_BUTTON_LABEL"  ) + "  " + '" title="' + L10n.Term(".LBL_SAVE_BUTTON_TITLE"  ) + '" class="button" />';
					// sHTML += '			<input type="button" ID="divNewAppointmentPopup_btnCancel" value="' + "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL") + "  " + '" title="' + L10n.Term(".LBL_CANCEL_BUTTON_TITLE") + '" class="button" />';
					// sHTML += '		</td>';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					td = document.createElement('td');
					tr.appendChild(td);
					
					// 01/09/2018 Paul.  Need to fix buttons when running bootstrap. 
					spnInputs = document.createElement('div');
					td.appendChild(spnInputs);
					var divNewAppointmentPopup_btnSave = null;
					if ( !SplendidDynamic.BootstrapLayout() )
					{
						divNewAppointmentPopup_btnSave = document.createElement('input');
						divNewAppointmentPopup_btnSave.id          = 'divNewAppointmentPopup_btnSave';
						divNewAppointmentPopup_btnSave.type        = 'button';
						divNewAppointmentPopup_btnSave.className   = 'button';
						divNewAppointmentPopup_btnSave.value       = L10n.Term('.LBL_SAVE_BUTTON_LABEL');
						divNewAppointmentPopup_btnSave.title       = L10n.Term('.LBL_SAVE_BUTTON_TITLE');
						divNewAppointmentPopup_btnSave.style.marginTop = '10px';
						spnInputs.appendChild(divNewAppointmentPopup_btnSave);
						txt = document.createTextNode(nbsp);
						spnInputs.appendChild(txt);
					}
					else
					{
						spnInputs.className = 'btn-group';
						divNewAppointmentPopup_btnSave = document.createElement('button');
						spnInputs.appendChild(divNewAppointmentPopup_btnSave );
						divNewAppointmentPopup_btnSave.id        = 'divNewAppointmentPopup_btnSave';
						divNewAppointmentPopup_btnSave.type      = 'button';
						divNewAppointmentPopup_btnSave.className = 'btn btn-primary btn-lg-text';
						divNewAppointmentPopup_btnSave.style.marginRight = '3px';
						divNewAppointmentPopup_btnSave.appendChild(document.createTextNode(L10n.Term('.LBL_SAVE_BUTTON_LABEL')));
					}
					// 01/09/2018 Paul.  Need to fix buttons when running bootstrap. 
					var divNewAppointmentPopup_btnCancel = null;
					if ( !SplendidDynamic.BootstrapLayout() )
					{
						divNewAppointmentPopup_btnCancel = document.createElement('input');
						divNewAppointmentPopup_btnCancel.id        = 'divNewAppointmentPopup_btnCancel';
						divNewAppointmentPopup_btnCancel.type      = 'button';
						divNewAppointmentPopup_btnCancel.className = 'button';
						divNewAppointmentPopup_btnCancel.value     = L10n.Term('.LBL_CANCEL_BUTTON_LABEL');
						divNewAppointmentPopup_btnCancel.title     = L10n.Term('.LBL_CANCEL_BUTTON_TITLE');
						spnInputs.appendChild(divNewAppointmentPopup_btnCancel);
					}
					else
					{
						divNewAppointmentPopup_btnCancel = document.createElement('button');
						spnInputs.appendChild(divNewAppointmentPopup_btnCancel);
						divNewAppointmentPopup_btnCancel.id        = 'divNewAppointmentPopup_btnCancel';
						divNewAppointmentPopup_btnCancel.type      = 'button';
						divNewAppointmentPopup_btnCancel.className = 'btn btn-primary btn-lg-text';
						divNewAppointmentPopup_btnCancel.style.marginRight = '3px';
						divNewAppointmentPopup_btnCancel.appendChild(document.createTextNode(L10n.Term('.LBL_CANCEL_BUTTON_LABEL')));
					}
					td = document.createElement('td');
					tr.appendChild(td);
					td = document.createElement('td');
					tr.appendChild(td);
					
					// sHTML += '	<tr>';
					// sHTML += '		<td></td>';
					// sHTML += '		<td><div id="divNewAppointmentPopup_divError" class="error"></div></td>';
					// sHTML += '	</tr>';
					tr = document.createElement('tr');
					tbody.appendChild(tr);
					td = document.createElement('td');
					tr.appendChild(td);
					td = document.createElement('td');
					tr.appendChild(td);
					td.setAttribute('colspan', '3'  );
					var divNewAppointmentPopup_divError = document.createElement('div');
					divNewAppointmentPopup_divError.id        = 'divNewAppointmentPopup_divError';
					divNewAppointmentPopup_divError.className = 'error';
					td.appendChild(divNewAppointmentPopup_divError);
					
					// 03/10/2013 Paul.  Add ALL_DAY_EVENT. 
					if ( ALL_DAY_EVENT )
						divNewAppointmentPopup_txtDATE_START.value         = $.fullCalendar.formatDate(start, context.ShortDatePattern);
					else
						divNewAppointmentPopup_txtDATE_START.value         = $.fullCalendar.formatDate(start, context.ShortDatePattern) + ' ' + $.fullCalendar.formatDate(start, context.ShortTimePattern);
					divNewAppointmentPopup_txtDURATION_HOURS.value   = DURATION_HOURS.toString();
					divNewAppointmentPopup_lstDURATION_MINUTES.value = DURATION_MINUTES.toString();

					divNewAppointmentPopup_lstREPEAT_TYPE.onchange = function(e)
					{
						// 03/30/2013 Paul.  Chrome, Firefox and Safari do not like to hide and show table rows or columns.  Use divisions for the cell contents instead. 
						var REPEAT_TYPE = divNewAppointmentPopup_lstREPEAT_TYPE.options[divNewAppointmentPopup_lstREPEAT_TYPE.options.selectedIndex].value;
						divNewAppointmentPopup_divREPEAT_INTERVAL_LABEL.style.display = (REPEAT_TYPE != ''       ? 'inline' : 'none');
						divNewAppointmentPopup_divREPEAT_INTERVAL.style.display       = (REPEAT_TYPE != ''       ? 'inline' : 'none');
						divNewAppointmentPopup_divREPEAT_COUNT_LABEL.style.display    = (REPEAT_TYPE != ''       ? 'inline' : 'none');
						divNewAppointmentPopup_divREPEAT_COUNT.style.display          = (REPEAT_TYPE != ''       ? 'inline' : 'none');
						divNewAppointmentPopup_divREPEAT_INTERVAL_LABEL.style.display = (REPEAT_TYPE != ''       ? 'inline' : 'none');
						divNewAppointmentPopup_divREPEAT_INTERVAL.style.display       = (REPEAT_TYPE != ''       ? 'inline' : 'none');
						divNewAppointmentPopup_divREPEAT_UNTIL_LABEL.style.display    = (REPEAT_TYPE != ''       ? 'inline' : 'none');
						divNewAppointmentPopup_divREPEAT_UNTIL.style.display          = (REPEAT_TYPE != ''       ? 'inline' : 'none');
						divNewAppointmentPopup_divREPEAT_DOW_LABEL.style.display      = (REPEAT_TYPE == 'Weekly' ? 'inline' : 'none');
						divNewAppointmentPopup_divREPEAT_DOW.style.display            = (REPEAT_TYPE == 'Weekly' ? 'inline' : 'none');
					}
					
					divNewAppointmentPopup_txtNAME.onkeypress = function(e)
					{
						return RegisterEnterKeyPress(e, 'divNewAppointmentPopup_btnSave');
					};
					divNewAppointmentPopup_btnSave.onclick = function()
					{
						divNewAppointmentPopup_txtNAME.value = $.trim(divNewAppointmentPopup_txtNAME.value);
						divNewAppointmentPopup_reqNAME.style.display = (divNewAppointmentPopup_txtNAME.value.length > 0) ? 'none' : 'inline';
						if ( divNewAppointmentPopup_txtNAME.value.length > 0 )
						{
							var MODULE_NAME      = divNewAppointmentPopup_radScheduleMeeting.checked ? 'Meetings' : 'Calls';
							var DURATION_HOURS   = Sql.ToInteger(divNewAppointmentPopup_txtDURATION_HOURS.value);
							var DURATION_MINUTES = divNewAppointmentPopup_lstDURATION_MINUTES.options[divNewAppointmentPopup_lstDURATION_MINUTES.options.selectedIndex].value;
							if ( isNaN(DURATION_MINUTES) )
								DURATION_MINUTES = 0;
							if ( isNaN(DURATION_HOURS) )
								DURATION_HOURS = 0;
							if ( chkALL_DAY_EVENT.checked )
							{
								DURATION_HOURS   = 24;
								DURATION_MINUTES = 0;
							}
							
							var REPEAT_TYPE     = divNewAppointmentPopup_lstREPEAT_TYPE.options[divNewAppointmentPopup_lstREPEAT_TYPE.options.selectedIndex].value;
							var REPEAT_COUNT    = Sql.ToInteger(divNewAppointmentPopup_txtREPEAT_COUNT.value);
							var REPEAT_INTERVAL = Sql.ToInteger(divNewAppointmentPopup_txtREPEAT_INTERVAL.value);
							// 04/25/2013 Paul.  ToJsonDate requires a date value not a string. 
							var REPEAT_UNTIL    = ToJsonDate($('#' + divNewAppointmentPopup_txtREPEAT_UNTIL.id).datepicker('getDate'));
							var REPEAT_DOW      = '';
							if ( REPEAT_TYPE == 'Weekly' )
							{
								if ( divNewAppointmentPopup_chkSunday.checked    ) REPEAT_DOW += '0';
								if ( divNewAppointmentPopup_chkMonday.checked    ) REPEAT_DOW += '1';
								if ( divNewAppointmentPopup_chkTuesday.checked   ) REPEAT_DOW += '2';
								if ( divNewAppointmentPopup_chkWednesday.checked ) REPEAT_DOW += '3';
								if ( divNewAppointmentPopup_chkThursday.checked  ) REPEAT_DOW += '4';
								if ( divNewAppointmentPopup_chkFriday.checked    ) REPEAT_DOW += '5';
								if ( divNewAppointmentPopup_chkSaturday.checked  ) REPEAT_DOW += '6';
							}
							
							var row = new Object();
							row.NAME             = divNewAppointmentPopup_txtNAME.value;
							row.DATE_TIME        = ToJsonDate(start);
							row.DURATION_HOURS   = DURATION_HOURS   ;
							row.DURATION_MINUTES = DURATION_MINUTES ;
							row.ALL_DAY_EVENT    = chkALL_DAY_EVENT.checked;
							row.DIRECTION        = 'Outbound'       ;
							row.STATUS           = 'Planned'        ;
							row.ASSIGNED_USER_ID = Security.USER_ID();
							row.TEAM_ID          = Security.TEAM_ID();
							row.REPEAT_TYPE      = REPEAT_TYPE      ;
							row.REPEAT_COUNT     = REPEAT_COUNT     ;
							row.REPEAT_INTERVAL  = REPEAT_INTERVAL  ;
							row.REPEAT_UNTIL     = REPEAT_UNTIL     ;
							row.REPEAT_DOW       = REPEAT_DOW       ;
							// 01/30/2016 Paul.  Add Parent and Description. 
							row.DESCRIPTION      = divNewAppointmentPopup_txtDESCRIPTION.value;
							row.PARENT_TYPE      = divNewAppointmentPopup_lstPARENT_TYPE.options[divNewAppointmentPopup_lstPARENT_TYPE.options.selectedIndex].value;
							row.PARENT_ID        = divNewAppointmentPopup_txtPARENT_ID.value;
							
							var bgPage = chrome.extension.getBackgroundPage();
							bgPage.UpdateModule(MODULE_NAME, row, null, function(status, message)
							{
								try
								{
									if ( status == 1 || status == 3 )
									{
										$dialog.dialog('close');
										calendar.fullCalendar('refetchEvents');
									}
									else
									{
										var divNewAppointmentPopup_divError = document.getElementById('divNewAppointmentPopup_divError');
										divNewAppointmentPopup_divError.innerHTML =message;
									}
								}
								catch(e)
								{
									var divNewAppointmentPopup_divError = document.getElementById('divNewAppointmentPopup_divError');
									divNewAppointmentPopup_divError.innerHTML =message;
								}
							}, context);
						}
					};
					divNewAppointmentPopup_btnCancel.onclick = function()
					{
						$dialog.dialog('close');
					};
				}
				, open: function(event, ui)
				{
					var divNewAppointmentPopup_txtNAME = document.getElementById('divNewAppointmentPopup_txtNAME');
					divNewAppointmentPopup_txtNAME.focus();
				}
				, close: function(event, ui)
				{
					$dialog.dialog('destroy');
					var divPopup = document.getElementById('divNewAppointmentPopup');
					divPopup.parentNode.removeChild(divPopup);
					calendar.fullCalendar('unselect');
				}
			});
		}
		, eventClick: function(event)
		{
			if ( event.url !== undefined && event.url != null )
			{
				//if ( event.url.indexOf('google.com/calendar') >= 0 )
				//	window.open(event.url, 'gcalevent', 'width=700,height=600');
				// 01/07/2014 Paul.  Use ../../ instead of ~/ so that raw URL will work as expected. 
				if ( event.url.substr(0, 6) == '../../' )
				{
					var sURL = event.url.replace('../../', '~/');
					var arrURL = sURL.split('/');
					if ( arrURL.length > 2 )
					{
						var sMODULE_NAME = arrURL[1];
						var sID          = arrURL[2].replace('view.aspx?ID=', '');
						var oDetailViewUI = new DetailViewUI();
						oDetailViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, sID, function(status, message)
						{
							if ( status == 1 )
							{
								SplendidError.SystemMessage('');
							}
							else
							{
								SplendidError.SystemMessage(message);
							}
						});
					}
				}
			}
			return false;
		}
		, eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view)
		{
			var TOTAL_SECONDS    = Math.round((event.end - event.start)/1000);
			var TOTAL_MINUTES    = Math.round(TOTAL_SECONDS/60);
			var DURATION_HOURS   = Math.floor(TOTAL_MINUTES/60);
			var DURATION_MINUTES = TOTAL_MINUTES % 60;
			var row = new Object();
			row.ID               = event.id               ;
			row.DATE_TIME        = ToJsonDate(event.start);
			row.DURATION_HOURS   = DURATION_HOURS         ;
			row.DURATION_MINUTES = DURATION_MINUTES       ;
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.UpdateModule(event.MODULE_NAME, row, event.id, function(status, message)
			{
				try
				{
					if ( status == 1 || status == 3 )
					{
					}
					else
					{
						revertFunc();
						SplendidError.SystemMessage(message);
					}
				}
				catch(e)
				{
					revertFunc();
					SplendidError.SystemAlert(e, 'UpdateModule');
				}
			}, context);
		}
		, eventResize: function(event, dayDelta, minuteDelta, revertFunc, jsEvent, ui, view)
		{
			var TOTAL_SECONDS    = Math.round((event.end - event.start)/1000);
			var TOTAL_MINUTES    = Math.round(TOTAL_SECONDS/60);
			var DURATION_HOURS   = Math.floor(TOTAL_MINUTES/60);
			var DURATION_MINUTES = TOTAL_MINUTES % 60;
			var row = new Object();
			row.ID               = event.id               ;
			row.DATE_TIME        = ToJsonDate(event.start);
			row.DURATION_HOURS   = DURATION_HOURS         ;
			row.DURATION_MINUTES = DURATION_MINUTES       ;
			var bgPage = chrome.extension.getBackgroundPage();
			bgPage.UpdateModule(event.MODULE_NAME, row, event.id, function(status, message)
			{
				try
				{
					if ( status == 1 || status == 3 )
					{
					}
					else
					{
						revertFunc();
						SplendidError.SystemMessage(message);
					}
				}
				catch(e)
				{
					revertFunc();
					SplendidError.SystemAlert(e, 'UpdateModule');
				}
			}, context);
		}
		, loading: function(bool)
		{
		}
		, viewDisplay: function(view)
		{
			try
			{
				// 02/22/2013 Paul.  Save the last view. 
				if ( window.localStorage )
					localStorage['CalendarDefaultView'] = view.name;
				else
					setCookie('CalendarDefaultView', view.name, 180);
			}
			catch(e)
			{
				// 03/10/2013 Paul.  IE9 is throwing an out-of-memory error. Just ignore the error. 
				//if ( window.localStorage.remainingSpace !== undefined )
				//	alert('remainingSpace = ' + window.localStorage.remainingSpace);
				SplendidError.SystemLog('CalendarDefaultView: ' + e.message);
			}
		}
	});
	var sGoogleHolidayURL = bgPage.SplendidCache.Config('GoogleCalendar.HolidayCalendars');
	if ( !Sql.IsEmptyString(sGoogleHolidayURL) )
	{
		var arrGoogleHolidayURL = sGoogleHolidayURL.split(',');
		for ( var i = 0; i < arrGoogleHolidayURL.length; i++ )
		{
			// 01/30/2014 Paul.  Chrome and Firefox require that the protocol match.  IE seems to be more flexible. 
			if ( window.location.protocol == 'https:' )
				arrGoogleHolidayURL[i] = arrGoogleHolidayURL[i].replace('http:', window.location.protocol);
			calendar.fullCalendar('addEventSource', arrGoogleHolidayURL[i]);
		}
	}
	calendar.fullCalendar('addEventSource', function(start, end, cbCalendar)
	{
		var dtDATE_START      = ToJsonDate(start);
		var dtDATE_END        = ToJsonDate(end  );
		var gASSIGNED_USER_ID = (bSharedCalendar ? '' : Security.USER_ID());
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.CalendarView_GetCalendar(dtDATE_START, dtDATE_END, gASSIGNED_USER_ID, function(status, message)
		{
			if ( status == 1 )
			{
				var rows = message;
				var events = new Array();
				for ( var i in rows )
				{
					var row = rows[i];
					var event = new Object();
					event.id          = row.ID;
					event.title       = row.STATUS + ': ' + row.NAME;
					event.MODULE_NAME = row.ACTIVITY_TYPE;
					event.start       = FromJsonDate(row.DATE_START).getTime()/1000;
					event.end         = FromJsonDate(row.DATE_END  ).getTime()/1000;
					event.editable    = true;
					// 02/20/2013 Paul.  Must set allDay in order for event to appear on agenda view. 
					// 03/10/2013 Paul.  Add ALL_DAY_EVENT. 
					event.allDay      = Sql.ToBoolean(row.ALL_DAY_EVENT);
					// 03/10/2013 Paul.  We set duration to 24 hours for all day events for iCal synching, but it makes FullCalendar span days in the Week view. 
					if ( event.allDay )
						event.end = event.start;
					// 01/07/2014 Paul.  Use ../../ instead of ~/ so that raw URL will work as expected. 
					event.url         = '../../' + row.ACTIVITY_TYPE + '/view.aspx?ID=' + row.ID;
					events.push(event);
				}
				cbCalendar(events);
				callback(1, null);
			}
			else
			{
				callback(status, message);
			}
		}, context);
	});
};

CalendarViewUI.prototype.Load = function(sLayoutPanel, sActionsPanel, callback)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.AuthenticatedMethod(function(status, message)
		{
			if ( status == 1 )
			{
				bgPage.Terminology_LoadModule('Calendar', function(status, message)
				{
					bgPage.Terminology_LoadModule('Calls', function(status, message)
					{
						if ( status == 0 || status == 1 )
						{
							// 12/06/2014 Paul.  LayoutMode is used on the Mobile view. 
							ctlActiveMenu.ActivateTab('Calendar', null, 'CalendarView');
							this.Render(sLayoutPanel, sActionsPanel, callback, this);
							// 03/10/2013 Paul.  Always load the global layout cache if it has not been loaded. 
							SplendidUI_Cache(function(status, message)
							{
								if ( status == 2 )
								{
									SplendidError.SystemMessage(message);
								}
							});
						}
						else
						{
							callback(status, message);
						}
					}, this);
				}, this);
			}
			else
			{
				callback(-1, message);
			}
		}, this);
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'CalendarViewUI.Load'));
	}
};

