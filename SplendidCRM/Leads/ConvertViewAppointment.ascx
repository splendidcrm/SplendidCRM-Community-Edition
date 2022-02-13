<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ConvertViewAppointment.ascx.cs" Inherits="SplendidCRM.Leads.ConvertViewAppointment" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divConvertViewAppointment">
	<h5 CssClass="dataLabel">
		<asp:CheckBox ID="chkCreateAppointment" CssClass="checkbox" Runat="server" />
		<%= L10n.Term("Leads.LNK_NEW_APPOINTMENT") %>
	</h5>
	<div id="divCreateAppointment" style="display:<%= (chkCreateAppointment.Checked ? "inline" : "none") %>">
		<asp:Table CssClass="tabEditView" runat="server">
			<asp:TableRow>
				<asp:TableCell CssClass="dataLabel" width="20%">
					<asp:RadioButton ID="radScheduleCall" GroupName="grpSchedule" CssClass="radio" Runat="server" /><span class="dataLabel"><%= L10n.Term("Calls.LNK_NEW_CALL") %></span>
				</asp:TableCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell CssClass="dataLabel">
					<asp:RadioButton ID="radScheduleMeeting" GroupName="grpSchedule" CssClass="radio" Checked="true" Runat="server" /><span class="dataLabel"><%= L10n.Term("Calls.LNK_NEW_MEETING") %></span>
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
		
		<table ID="tblMain" class="tabEditView" runat="server">
		</table>
	</div>
	<br />
</div>
