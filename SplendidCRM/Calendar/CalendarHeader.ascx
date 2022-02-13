<%@ Control Language="c#" AutoEventWireup="false" Codebehind="CalendarHeader.ascx.cs" Inherits="SplendidCRM.Calendar.CalendarHeader" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
	<asp:Button ID="btnDay"    CommandName="Day.Current"    OnCommand="Page_Command" CssClass="button" Text='<%# " " + L10n.Term("Calendar.LBL_DAY"   ) + " " %>' ToolTip='<%# L10n.Term("Calendar.LBL_DAY"   ) %>' Runat="server" />
	<asp:Button ID="btnWeek"   CommandName="Week.Current"   OnCommand="Page_Command" CssClass="button" Text='<%# " " + L10n.Term("Calendar.LBL_WEEK"  ) + " " %>' ToolTip='<%# L10n.Term("Calendar.LBL_WEEK"  ) %>' Runat="server" />
	<asp:Button ID="btnMonth"  CommandName="Month.Current"  OnCommand="Page_Command" CssClass="button" Text='<%# " " + L10n.Term("Calendar.LBL_MONTH" ) + " " %>' ToolTip='<%# L10n.Term("Calendar.LBL_MONTH" ) %>' Runat="server" />
	<asp:Button ID="btnYear"   CommandName="Year.Current"   OnCommand="Page_Command" CssClass="button" Text='<%# " " + L10n.Term("Calendar.LBL_YEAR"  ) + " " %>' ToolTip='<%# L10n.Term("Calendar.LBL_YEAR"  ) %>' Runat="server" />
	<asp:Button ID="btnShared" CommandName="Shared.Current" OnCommand="Page_Command" CssClass="button" Text='<%# " " + L10n.Term("Calendar.LBL_SHARED") + " " %>' ToolTip='<%# L10n.Term("Calendar.LBL_SHARED") %>' Runat="server" />
</asp:Panel>

