<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Calendar.html5.ListView" %>
<script runat="server">
/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
</script>
<div id="divListView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="Calendar" Title="Calendar.LBL_MODULE_TITLE" EnableModuleLabel="false" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />
	
	<%@ Register TagPrefix="SplendidCRM" Tagname="RestUtils" Src="~/_controls/RestUtils.ascx" %>
	<SplendidCRM:RestUtils Runat="Server" />

	<div id="divError" class="error"></div>
	<div id="divMainPageContent">
		<div id="divCalendar" style="width: 100%" align="center"></div>
	</div>

	<SplendidCRM:InlineScript runat="server">
		<script type="text/javascript">
// 06/24/2017 Paul.  We need a way to turn off bootstrap for BPMN, ReportDesigner and ChatDashboard. 
bDESKTOP_LAYOUT  = true;
// 11/06/2013 Paul.  Make sure to JavaScript escape the text as the various languages may introduce accents. 
TERMINOLOGY['.LBL_NONE'                      ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_NONE"                      )) %>';
TERMINOLOGY['Calendar.LNK_VIEW_CALENDAR'     ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LNK_VIEW_CALENDAR"     )) %>';
TERMINOLOGY['Calendar.LBL_MONTH'             ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LBL_MONTH"             )) %>';
TERMINOLOGY['Calendar.LBL_WEEK'              ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LBL_WEEK"              )) %>';
TERMINOLOGY['Calendar.LBL_DAY'               ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LBL_DAY"               )) %>';
TERMINOLOGY['Calendar.LBL_SHARED'            ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LBL_SHARED"            )) %>';
TERMINOLOGY['Calendar.LBL_ALL_DAY'           ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LBL_ALL_DAY"           )) %>';
TERMINOLOGY['Calendar.YearMonthPattern'      ] = '<%# Sql.EscapeJavaScript(DateTimeFormat.YearMonthPattern             ) %>';
TERMINOLOGY['Calendar.MonthDayPattern'       ] = '<%# Sql.EscapeJavaScript(DateTimeFormat.MonthDayPattern              ) %>';
TERMINOLOGY['Calendar.LongDatePattern'       ] = '<%# Sql.EscapeJavaScript(DateTimeFormat.LongDatePattern              ) %>';
TERMINOLOGY['Calendar.FirstDayOfWeek'        ] = '<%# (int) DateTimeFormat.FirstDayOfWeek       %>';
TERMINOLOGY['Calendar.LNK_NEW_APPOINTMENT'   ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LNK_NEW_APPOINTMENT"   )) %>';
TERMINOLOGY['Calls.LNK_NEW_CALL'             ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LNK_NEW_CALL"             )) %>';
TERMINOLOGY['Calls.LNK_NEW_MEETING'          ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LNK_NEW_MEETING"          )) %>';
TERMINOLOGY['Calls.LBL_SUBJECT'              ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LBL_SUBJECT"              )) %>';
TERMINOLOGY['Calls.LBL_DATE_TIME'            ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LBL_DATE_TIME"            )) %>';
TERMINOLOGY['Calls.LBL_DURATION'             ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LBL_DURATION"             )) %>';
TERMINOLOGY['Calls.LBL_HOURS_MINUTES'        ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LBL_HOURS_MINUTES"        )) %>';
TERMINOLOGY['Calls.LBL_ALL_DAY'              ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LBL_ALL_DAY"              )) %>';
TERMINOLOGY['Calls.LBL_DESCRIPTION'          ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LBL_DESCRIPTION"          )) %>';
TERMINOLOGY['.LBL_REQUIRED_SYMBOL'           ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_REQUIRED_SYMBOL"           )) %>';
TERMINOLOGY['.ERR_REQUIRED_FIELD'            ] = '<%# Sql.EscapeJavaScript(L10n.Term(".ERR_REQUIRED_FIELD"            )) %>';
TERMINOLOGY['.LBL_SAVE_BUTTON_LABEL'         ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_SAVE_BUTTON_LABEL"         )) %>';
TERMINOLOGY['.LBL_SAVE_BUTTON_TITLE'         ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_SAVE_BUTTON_TITLE"         )) %>';
TERMINOLOGY['.LBL_CANCEL_BUTTON_LABEL'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_CANCEL_BUTTON_LABEL"       )) %>';
TERMINOLOGY['.LBL_CANCEL_BUTTON_TITLE'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_CANCEL_BUTTON_TITLE"       )) %>';
TERMINOLOGY_LISTS['month_names_dom'          ] = ['<%# String.Join("', '", Sql.EscapeJavaScript(DateTimeFormat.MonthNames           )) %>'];
TERMINOLOGY_LISTS['short_month_names_dom'    ] = ['<%# String.Join("', '", Sql.EscapeJavaScript(DateTimeFormat.AbbreviatedMonthNames)) %>'];
TERMINOLOGY_LISTS['day_names_dom'            ] = ['<%# String.Join("', '", Sql.EscapeJavaScript(DateTimeFormat.DayNames             )) %>'];
TERMINOLOGY_LISTS['short_day_names_dom'      ] = ['<%# String.Join("', '", Sql.EscapeJavaScript(DateTimeFormat.AbbreviatedDayNames  )) %>'];
TERMINOLOGY_LISTS['repeat_type_dom'          ] = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
TERMINOLOGY['.repeat_type_dom.Daily'         ] = '<%# Sql.EscapeJavaScript(L10n.Term(".repeat_type_dom.Daily"         )) %>';
TERMINOLOGY['.repeat_type_dom.Weekly'        ] = '<%# Sql.EscapeJavaScript(L10n.Term(".repeat_type_dom.Weekly"        )) %>';
TERMINOLOGY['.repeat_type_dom.Monthly'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".repeat_type_dom.Monthly"       )) %>';
TERMINOLOGY['.repeat_type_dom.Yearly'        ] = '<%# Sql.EscapeJavaScript(L10n.Term(".repeat_type_dom.Yearly"        )) %>';

TERMINOLOGY['Calendar.LBL_REPEAT_TAB'        ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LBL_REPEAT_TAB"        )) %>';
TERMINOLOGY['Calendar.LBL_REPEAT_END_AFTER'  ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LBL_REPEAT_END_AFTER"  )) %>';
TERMINOLOGY['Calendar.LBL_REPEAT_OCCURRENCES'] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LBL_REPEAT_OCCURRENCES")) %>';
TERMINOLOGY['Calendar.LBL_REPEAT_INTERVAL'   ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calendar.LBL_REPEAT_INTERVAL"   )) %>';
TERMINOLOGY['Calls.LBL_REPEAT_TYPE'          ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LBL_REPEAT_TYPE"          )) %>';
TERMINOLOGY['Calls.LBL_REPEAT_UNTIL'         ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LBL_REPEAT_UNTIL"         )) %>';
TERMINOLOGY['Calls.LBL_REPEAT_DOW'           ] = '<%# Sql.EscapeJavaScript(L10n.Term("Calls.LBL_REPEAT_DOW"           )) %>';
// 01/30/2016 Paul.  Add Parent and Description. 
TERMINOLOGY['.LBL_SELECT_BUTTON_LABEL'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_SELECT_BUTTON_LABEL"       )) %>';
TERMINOLOGY['.LBL_SELECT_BUTTON_TITLE'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_SELECT_BUTTON_TITLE"       )) %>';
TERMINOLOGY['.LBL_CLEAR_BUTTON_LABEL'        ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_CLEAR_BUTTON_LABEL"        )) %>';
TERMINOLOGY['.LBL_CLEAR_BUTTON_TITLE'        ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_CLEAR_BUTTON_TITLE"        )) %>';
TERMINOLOGY['.LBL_SEARCH_BUTTON_LABEL'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_SEARCH_BUTTON_LABEL"       )) %>';
TERMINOLOGY['.LBL_SEARCH_BUTTON_TITLE'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_SEARCH_BUTTON_TITLE"       )) %>';
TERMINOLOGY['.LBL_LIST_TEAM_SET_NAME'        ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_LIST_TEAM_SET_NAME"        )) %>';
TERMINOLOGY['.LBL_LIST_ASSIGNED_USER'        ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_LIST_ASSIGNED_USER"        )) %>';
// 01/24/2018 Paul.  The Calendar needs to determine if Calls module is enabled. 
TERMINOLOGY['Meetings.LNK_NEW_CALL'          ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LNK_NEW_CALL"          )) %>';
TERMINOLOGY['Meetings.LNK_NEW_MEETING'       ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LNK_NEW_MEETING"       )) %>';
TERMINOLOGY['Meetings.LBL_SUBJECT'           ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LBL_SUBJECT"           )) %>';
TERMINOLOGY['Meetings.LBL_DATE_TIME'         ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LBL_DATE_TIME"         )) %>';
TERMINOLOGY['Meetings.LBL_DURATION'          ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LBL_DURATION"          )) %>';
TERMINOLOGY['Meetings.LBL_HOURS_MINUTES'     ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LBL_HOURS_MINUTES"     )) %>';
TERMINOLOGY['Meetings.LBL_ALL_DAY'           ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LBL_ALL_DAY"           )) %>';
TERMINOLOGY['Meetings.LBL_DESCRIPTION'       ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LBL_DESCRIPTION"       )) %>';
TERMINOLOGY['Meetings.LBL_REPEAT_TYPE'       ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LBL_REPEAT_TYPE"       )) %>';
TERMINOLOGY['Meetings.LBL_REPEAT_UNTIL'      ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LBL_REPEAT_UNTIL"      )) %>';
TERMINOLOGY['Meetings.LBL_REPEAT_DOW'        ] = '<%# Sql.EscapeJavaScript(L10n.Term("Meetings.LBL_REPEAT_DOW"        )) %>';
// 01/28/2018 Paul.  We need to paginate the popup to support large data sets. 
TERMINOLOGY['.LNK_LIST_PREVIOUS'             ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LNK_LIST_PREVIOUS"             )) %>';
TERMINOLOGY['.LBL_LIST_OF'                   ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_LIST_OF"                   )) %>';
TERMINOLOGY['.LNK_LIST_NEXT'                 ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LNK_LIST_NEXT"                 )) %>';

<%# BuildTerminologyListScripts() %>

CONFIG['calendar.hour_start'                 ] = '<%# Sql.EscapeJavaScript(Application["CONFIG.calendar.hour_start"            ]) %>';
CONFIG['GoogleCalendar.HolidayCalendars'     ] = '<%# Sql.EscapeJavaScript(Application["CONFIG.GoogleCalendar.HolidayCalendars"]) %>';

background.CalendarView_GetCalendar = function(dtDATE_START, dtDATE_END, gASSIGNED_USER_ID, callback, context)
{
	var xhr = CreateSplendidRequest('Rest.svc/GetCalendar?DATE_START=' + encodeURIComponent(dtDATE_START) + '&DATE_END=' + encodeURIComponent(dtDATE_END)  + '&ASSIGNED_USER_ID=' + encodeURIComponent(gASSIGNED_USER_ID), 'GET');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						if ( result.d !== undefined )
						{
							callback.call(context||this, 1, result.d.results);
						}
						else
						{
							callback.call(context||this, -1, xhr.responseText);
						}
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'CalendarView_GetCalendar'));
				}
			}, context||this);
		}
	}
	try
	{
		xhr.send();
	}
	catch(e)
	{
		if ( e.number != -2146697208 )
			callback.call(context||this, -1, SplendidError.FormatError(e, 'CalendarView_GetCalendar'));
	}
};

// 01/28/2018 Paul.  AutoComplete_ModuleMethod is needed for parent popup. 
background.AutoComplete_ModuleMethod = function(sMODULE_NAME, sMETHOD, sREQUEST, callback, context)
{
	if ( sMODULE_NAME == 'Teams' )
		sMODULE_NAME = 'Administration/Teams';
	else if ( sMODULE_NAME == 'Tags' )
		sMODULE_NAME = 'Administration/Tags';
	// 06/07/2017 Paul.  Add NAICSCodes module. 
	else if ( sMODULE_NAME == 'NAICSCodes' )
		sMODULE_NAME = 'Administration/NAICSCodes';
	var xhr = CreateSplendidRequest(sMODULE_NAME + '/AutoComplete.asmx/' + sMETHOD);
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						callback.call(context||this, 1, result.d);
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							callback.call(context||this, -1, result.ExceptionDetail.Message);
						else
							callback.call(context||this, -1, xhr.responseText);
					}
				}
				catch(e)
				{
					callback.call(context||this, -1, SplendidError.FormatError(e, 'AutoComplete_ModuleMethod'));
				}
			});
		}
	}
	try
	{
		xhr.send(sREQUEST);
	}
	catch(e)
	{
		callback.call(context||this, -1, SplendidError.FormatError(e, 'AutoComplete_ModuleMethod'));
	}
}

$(document).ready(function()
{
	var oCalendarViewUI = new CalendarViewUI();
	oCalendarViewUI.Render(null, null, function(status, message)
	{
	}, oCalendarViewUI);
});
		</script>
	</SplendidCRM:InlineScript>
</div>

