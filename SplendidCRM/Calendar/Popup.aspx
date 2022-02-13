<%@ Page language="c#" Codebehind="Popup.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Calendar.Popup" %>
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
<!DOCTYPE HTML>
<html>
<head runat="server">
	<title>Calendar</title>
	<base target="_self" />
</head>
<script type="text/javascript">
function SelectDate(sDATE)
{
	if ( window.opener != null && window.opener.ChangeDate != null )
	{
		window.opener.ChangeDate(sDATE);
		window.close();
	}
	else
	{
		alert('Original window has closed.  Date cannot be set.');
	}
}
</script>
<body leftmargin="0" topmargin="0" rightmargin="0" bottommargin="0">
	<form id="frm" method="post" runat="server">
		<asp:Calendar ID="ctlCalendar" OnSelectionChanged="ctlCalendar_SelectionChanged" CssClass="Calendar" Runat="server">
			<TitleStyle         CssClass="CalendarTitle" />
			<DayHeaderStyle     CssClass="CalendarDayHeader" />
			<DayStyle           CssClass="CalendarDay" />
			<OtherMonthDayStyle CssClass="CalendarOtherMonthDay" />
			<NextPrevStyle      CssClass="" />
			<SelectedDayStyle   CssClass="" />
			<SelectorStyle      CssClass="" />
			<TodayDayStyle      CssClass="CalendarToday" />
			<WeekendDayStyle    CssClass="CalendarWeekendDay" />
		</asp:Calendar>
	</form>
</body>
</html>

