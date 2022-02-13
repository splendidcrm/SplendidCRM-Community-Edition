<%@ Control CodeBehind="DayGrid.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Calendar.DayGrid" %>
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
<div id="divDay">
	<%@ Register TagPrefix="SplendidCRM" Tagname="CalendarHeader" Src="CalendarHeader.ascx" %>
	<SplendidCRM:CalendarHeader ID="ctlCalendarHeader" ActiveTab="Day" Runat="Server" />
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>

	<asp:Table SkinID="tabFrame" CssClass="monthBox" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabFrame" CssClass="monthHeader" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="1%" CssClass="monthHeaderPrevTd" Wrap="false">
							<asp:ImageButton CommandName="Day.Previous" OnCommand="Page_Command" CssClass="NextPrevLink" AlternateText='<%# L10n.Term("Calendar.LBL_PREVIOUS_DAY") %>' SkinID="calendar_previous" Runat="server" />&nbsp;
							<asp:LinkButton  CommandName="Day.Previous" OnCommand="Page_Command" CssClass="NextPrevLink" Text='<%# L10n.Term("Calendar.LBL_PREVIOUS_DAY") %>' Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="98%" HorizontalAlign="Center">
							<span class="monthHeaderH3"><%= dtCurrentDate.ToLongDateString() %></span>
						</asp:TableCell>
						<asp:TableCell Width="1%" HorizontalAlign="Right" CssClass="monthHeaderNextTd" Wrap="false">
							<asp:LinkButton  CommandName="Day.Next" OnCommand="Page_Command" CssClass="NextPrevLink" Text='<%# L10n.Term("Calendar.LBL_NEXT_DAY") %>' Runat="server" />&nbsp;
							<asp:ImageButton CommandName="Day.Next" OnCommand="Page_Command" CssClass="NextPrevLink" AlternateText='<%# L10n.Term("Calendar.LBL_NEXT_DAY") %>' SkinID="calendar_next" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="monthCalBody">
				<table width="100%" border="0" cellpadding="0" cellspacing="1">
					<asp:PlaceHolder ID="plcDayRows" Runat="server" />
				</table>
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabFrame" CssClass="monthFooter" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="50%" CssClass="monthFooterPrev" Wrap="false">
							<asp:ImageButton CommandName="Day.Previous" OnCommand="Page_Command" CssClass="NextPrevLink" AlternateText='<%# L10n.Term("Calendar.LBL_PREVIOUS_DAY") %>' SkinID="calendar_previous" Runat="server" />&nbsp;
							<asp:LinkButton  CommandName="Day.Previous" OnCommand="Page_Command" CssClass="NextPrevLink" Text='<%# L10n.Term("Calendar.LBL_PREVIOUS_DAY") %>' Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="50%" HorizontalAlign="Right" CssClass="monthFooterNext" Wrap="false">
							<asp:LinkButton  CommandName="Day.Next" OnCommand="Page_Command" CssClass="NextPrevLink" Text='<%# L10n.Term("Calendar.LBL_NEXT_DAY") %>' Runat="server" />&nbsp;
							<asp:ImageButton CommandName="Day.Next" OnCommand="Page_Command" CssClass="NextPrevLink" AlternateText='<%# L10n.Term("Calendar.LBL_NEXT_DAY") %>' SkinID="calendar_next" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

