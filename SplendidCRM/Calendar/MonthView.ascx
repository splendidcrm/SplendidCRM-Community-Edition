<%@ Control CodeBehind="MonthView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Calendar.MonthView" %>
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
<div id="divDetailView" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ModuleHeader" Src="~/_controls/ModuleHeader.ascx" %>
	<SplendidCRM:ModuleHeader ID="ctlModuleHeader" Module="Calendar" Title="Calendar.LBL_MODULE_TITLE" EnableModuleLabel="false" EnablePrint="true" HelpName="MonthView" EnableHelp="true" Runat="Server" />
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<asp:Table SkinID="tabFrame" runat="server">
		<asp:TableRow>
			<asp:TableCell VerticalAlign="Top">
				<%@ Register TagPrefix="SplendidCRM" Tagname="CalendarHeader" Src="CalendarHeader.ascx" %>
				<SplendidCRM:CalendarHeader ID="ctlCalendarHeader" ActiveTab="Month" Runat="Server" />
				
				<asp:Calendar ID="ctlCalendar" Width="100%" CssClass="monthBox" ShowGridLines="true" 
					SelectionMode="Day" OnSelectionChanged="ctlCalendar_SelectionChanged" 
					OnDayRender="ctlCalendar_DayRender" OnVisibleMonthChanged="ctlCalendar_VisibleMonthChanged"
					Runat="server">
					<TitleStyle         CssClass="monthHeader monthHeaderH3"   />
					<NextPrevStyle      CssClass="monthHeader monthFooterPrev" />
					<DayHeaderStyle     CssClass="monthCalBodyTHDay"           />
					<DayStyle           CssClass="monthCalBodyWeekDay monthCalBodyWeekDayDateLink"      VerticalAlign="Top" />
					<TodayDayStyle      CssClass="monthCalBodyTodayWeekDay monthCalBodyWeekDayDateLink" VerticalAlign="Top" />
					<WeekendDayStyle    CssClass="monthCalBodyWeekEnd monthCalBodyWeekDayDateLink"      VerticalAlign="Top" />
					<OtherMonthDayStyle CssClass="monthCalBodyWeekDay" ForeColor="#fafafa"              VerticalAlign="Top" />
				</asp:Calendar>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

