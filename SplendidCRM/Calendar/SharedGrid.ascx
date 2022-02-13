<%@ Control CodeBehind="SharedGrid.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Calendar.SharedGrid" %>
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
<div id="SharedGrid">
	<%@ Register TagPrefix="SplendidCRM" Tagname="CalendarHeader" Src="CalendarHeader.ascx" %>
	<SplendidCRM:CalendarHeader ID="ctlCalendarHeader" ActiveTab="Shared" Runat="Server" />

	<p></p>
	<asp:Table SkinID="tabFrame" runat="server">
		<asp:TableRow>
			<asp:TableCell Wrap="false">
				<h3><asp:Image SkinID="h3Arrow" Runat="server" />&nbsp;<%= L10n.Term("Calendar.LBL_SHARED_CAL_TITLE") %></h3>
			</asp:TableCell>
			<asp:TableCell HorizontalAlign="Right" Wrap="false">
				<span onclick="toggleDisplay('shared_cal_edit'); return false;">
					<asp:ImageButton CommandName="Edit" OnCommand="Page_Command" CssClass="chartToolsLink" AlternateText='<%# L10n.Term("Calendar.LBL_EDIT") %>' SkinID="edit" Runat="server" />&nbsp;
					<asp:LinkButton  CommandName="Edit" OnCommand="Page_Command" CssClass="chartToolsLink" Text='<%# L10n.Term("Calendar.LBL_EDIT") %>' Runat="server" />
				</span>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>

	<div ID="shared_cal_edit" style="DISPLAY: none">
		<asp:Table SkinID="tabFrame" HorizontalAlign="Center" runat="server">
			<asp:TableRow>
				<asp:TableHeaderCell VerticalAlign="Top" HorizontalAlign="Center" ColumnSpan="2"><%= L10n.Term("Calendar.LBL_SELECT_USERS") %></asp:TableHeaderCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell>
					<asp:Table BorderWidth="0" CellPadding="1" CellSpacing="1" HorizontalAlign="Center" CssClass="chartForm" runat="server">
						<asp:TableRow>
							<asp:TableCell VerticalAlign="Top" Wrap="false"><b><%= L10n.Term("Calendar.LBL_USERS") %></b></asp:TableCell>
							<asp:TableCell VerticalAlign="Top">
								<asp:ListBox ID="lstUSERS" DataValueField="ID" DataTextField="USER_NAME" SelectionMode="Multiple" Rows="3" Runat="server" />
							</asp:TableCell>
						</asp:TableRow>
						<asp:TableRow>
							<asp:TableCell HorizontalAlign="Right" ColumnSpan="2">
								<asp:Button ID="btnSubmit" CommandName="Submit" OnCommand="Page_Command"                   CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SELECT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_SELECT_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SELECT_BUTTON_KEY") %>' runat="server" />&nbsp;
								<asp:Button ID="btnCancel" UseSubmitBehavior="false" OnClientClick="toggleDisplay('shared_cal_edit'); return false;" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_CANCEL_BUTTON_KEY") %>' runat="server" />
							</asp:TableCell>
						</asp:TableRow>
					</asp:Table>
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>

	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<asp:Table SkinID="tabFrame" CssClass="monthBox" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabFrame" CssClass="monthHeader" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="1%" CssClass="monthHeaderPrevTd" Wrap="false">
							<asp:ImageButton CommandName="Shared.Previous" OnCommand="Page_Command" CssClass="NextPrevLink" AlternateText='<%# L10n.Term(".LNK_LIST_PREVIOUS") %>' SkinID="calendar_previous" Runat="server" />&nbsp;
							<asp:LinkButton  CommandName="Shared.Previous" OnCommand="Page_Command" CssClass="NextPrevLink" Text='<%# L10n.Term(".LNK_LIST_PREVIOUS") %>' Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="98%" HorizontalAlign="Center">
							<span class="monthHeaderH3"><%= dtCurrentWeek.ToLongDateString() + " - " + dtCurrentWeek.AddDays(6).ToLongDateString() %></span>
						</asp:TableCell>
						<asp:TableCell Width="1%" HorizontalAlign="Right" CssClass="monthHeaderNextTd" Wrap="false">
							<asp:LinkButton  CommandName="Shared.Next" OnCommand="Page_Command" CssClass="NextPrevLink" Text='<%# L10n.Term(".LBL_NEXT_BUTTON_LABEL") %>' Runat="server" />
							<asp:ImageButton CommandName="Shared.Next" OnCommand="Page_Command" CssClass="NextPrevLink" AlternateText='<%# L10n.Term(".LBL_NEXT_BUTTON_LABEL") %>' SkinID="calendar_next" Runat="server" />&nbsp;
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="monthCalBody">
				<asp:PlaceHolder ID="plcWeekRows" Runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabFrame" CssClass="monthFooter" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="50%" CssClass="monthFooterPrev" Wrap="false">
							<asp:ImageButton CommandName="Shared.Previous" OnCommand="Page_Command" CssClass="NextPrevLink" AlternateText='<%# L10n.Term(".LNK_LIST_PREVIOUS") %>' SkinID="calendar_previous" Runat="server" />&nbsp;
							<asp:LinkButton  CommandName="Shared.Previous" OnCommand="Page_Command" CssClass="NextPrevLink" Text='<%# L10n.Term(".LNK_LIST_PREVIOUS") %>' Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="50%" HorizontalAlign="Right" CssClass="monthFooterNext" Wrap="false">
							<asp:LinkButton  CommandName="Shared.Next" OnCommand="Page_Command" CssClass="NextPrevLink" Text='<%# L10n.Term(".LBL_NEXT_BUTTON_LABEL") %>' Runat="server" />
							<asp:ImageButton CommandName="Shared.Next" OnCommand="Page_Command" CssClass="NextPrevLink" AlternateText='<%# L10n.Term(".LBL_NEXT_BUTTON_LABEL") %>' SkinID="calendar_next" Runat="server" />&nbsp;
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

