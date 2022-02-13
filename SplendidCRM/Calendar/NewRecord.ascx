<%@ Control Language="c#" AutoEventWireup="false" Codebehind="NewRecord.ascx.cs" Inherits="SplendidCRM.Calendar.NewRecord" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divNewRecord">
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderLeft" Src="~/_controls/HeaderLeft.ascx" %>
	<SplendidCRM:HeaderLeft ID="ctlHeaderLeft" Title="Calendar.LNK_NEW_APPOINTMENT" Runat="Server" />

	<asp:Panel Width="100%" CssClass="leftColumnModuleS3" runat="server">
		<asp:RadioButton ID="radScheduleCall"    GroupName="grpSchedule" class="radio" Checked="true" Runat="server" /><asp:Label Text='<%# L10n.Term("Calls.LNK_NEW_CALL"   ) %>' runat="server" /><br />
		<asp:RadioButton ID="radScheduleMeeting" GroupName="grpSchedule" class="radio"                Runat="server" /><asp:Label Text='<%# L10n.Term("Calls.LNK_NEW_MEETING") %>' runat="server" /><br />
		<asp:Label Text='<%# L10n.Term("Meetings.LBL_SUBJECT") %>' runat="server" /><asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /><br />
		<asp:TextBox ID="txtNAME" size="25" MaxLength="255" Runat="server" /><br />
		<asp:Label Text='<%# L10n.Term("Meetings.LBL_DATE") %>' runat="server" />&nbsp;<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" />&nbsp;<asp:Label ID="lblDATEFORMAT" CssClass="dateFormat" Runat="server" /><br />
		<%@ Register TagPrefix="SplendidCRM" Tagname="DatePicker" Src="~/_controls/DatePicker.ascx" %>
		<SplendidCRM:DatePicker ID="ctlDATE_START" Runat="Server" />
		<asp:Label Text='<%# L10n.Term("Meetings.LBL_TIME") %>' runat="server" />&nbsp;<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" />&nbsp;<asp:Label ID="lblTIMEFORMAT" CssClass="dateFormat" Runat="server" /><br />
		<asp:TextBox ID="txtTIME_START" size="15" MaxLength="10" Runat="server" /><br />
		
		<asp:Button ID="btnSave" CommandName="NewRecord" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SAVE_BUTTON_LABEL"  ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_SAVE_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SAVE_BUTTON_KEY") %>' Runat="server" /><br />
		<asp:RequiredFieldValidator ID="reqNAME"       ControlToValidate="txtNAME"       ErrorMessage="(required)" CssClass="required" Enabled="false" EnableClientScript="false" EnableViewState="false" Runat="server" />
		<asp:RequiredFieldValidator ID="reqTIME_START" ControlToValidate="txtTIME_START" ErrorMessage="(required)" CssClass="required" Enabled="false" EnableClientScript="false" EnableViewState="false" Runat="server" />
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	<%= Utils.RegisterEnterKeyPress(txtNAME.ClientID          , btnSave.ClientID) %>
	<%= Utils.RegisterEnterKeyPress(ctlDATE_START.DateClientID, btnSave.ClientID) %>
	<%= Utils.RegisterEnterKeyPress(txtTIME_START.ClientID    , btnSave.ClientID) %>
</div>

