<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ProcessButtons.ascx.cs" Inherits="SplendidCRM._controls.ProcessButtons" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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

<script type="text/javascript">
function ProcessPopupOptions()
{
	return '<%# SplendidCRM.Crm.Config.PopupWindowOptions() %>';
}
function SelectProcessUserPopup()
{
	var hidPROCESS_TEAM_ID = document.getElementById('<%= hidPROCESS_TEAM_ID.ClientID %>');
	var hidPROCESS_ACTION  = document.getElementById('<%= hidPROCESS_ACTION .ClientID %>');
	hidPROCESS_ACTION.value = 'ChangeProcessUser';
	var sPopupURL = '<%= Sql.ToString(Application["rootURL"]) + "Processes/SelectUserPopup.aspx?ID=" %>' + hidPROCESS_TEAM_ID.value;
	return window.open(sPopupURL, 'SelectProcessUserPopup', ProcessPopupOptions());
}
function SelectAssignedUserPopup()
{
	var hidASSIGNED_TEAM_ID = document.getElementById('<%= hidASSIGNED_TEAM_ID.ClientID %>');
	var hidPROCESS_ACTION   = document.getElementById('<%= hidPROCESS_ACTION  .ClientID %>');
	hidPROCESS_ACTION.value = 'ChangeAssignedUser';
	var sPopupURL = '<%= Sql.ToString(Application["rootURL"]) + "Processes/SelectUserPopup.aspx?ID=" %>' + hidASSIGNED_TEAM_ID.value;
	return window.open(sPopupURL, 'SelectProcessUserPopup', ProcessPopupOptions());
}
function ChangeProcessUser(sPARENT_ID, sPARENT_NAME, sPROCESS_NOTES)
{
	var hidPROCESS_USER_ID   = document.getElementById('<%= hidPROCESS_USER_ID.ClientID   %>');
	var hidPROCESS_NOTES     = document.getElementById('<%= hidPROCESS_NOTES.ClientID     %>');
	var btnChangeProcessUser = document.getElementById('<%= btnChangeProcessUser.ClientID %>');
	hidPROCESS_USER_ID.value = sPARENT_ID;
	hidPROCESS_NOTES.value   = sPROCESS_NOTES;
	btnChangeProcessUser.click();
}
function ProcessHistoryPopup()
{
	var hidPENDING_PROCESS_ID = document.getElementById('<%= hidPENDING_PROCESS_ID.ClientID %>');
	var sPopupURL = '<%= Sql.ToString(Application["rootURL"]) + "Processes/ProcessHistoryPopup.aspx?PROCESS_ID=" %>' + hidPENDING_PROCESS_ID.value;
	return window.open(sPopupURL, 'ProcessHistoryPopup', ProcessPopupOptions());
}
function ProcessNotesPopup()
{
	var hidPENDING_PROCESS_ID = document.getElementById('<%= hidPENDING_PROCESS_ID.ClientID %>');
	var sPopupURL = '<%= Sql.ToString(Application["rootURL"]) + "Processes/ProcessNotesPopup.aspx?PROCESS_ID=" %>' + hidPENDING_PROCESS_ID.value;
	return window.open(sPopupURL, 'ProcessNotesPopup', ProcessPopupOptions());
}
</script>
<asp:HiddenField ID="hidPROCESS_USER_ID"    runat="server" />
<asp:HiddenField ID="hidPROCESS_NOTES"      runat="server" />
<asp:HiddenField ID="hidPROCESS_ACTION"     runat="server" />
<asp:HiddenField ID="hidPENDING_PROCESS_ID" runat="server" />
<asp:HiddenField ID="hidASSIGNED_TEAM_ID"   runat="server" />
<asp:HiddenField ID="hidPROCESS_TEAM_ID"    runat="server" />
<asp:HiddenField ID="hidSTATUS"             runat="server" />
<asp:HiddenField ID="hidERASED_COUNT"       runat="server" />
<asp:Button      ID="btnChangeProcessUser" OnCommand="Page_Command" CommandName="Processes.ChangeUser" Text="Change User" style="display: none;" runat="server" />
<div>
	<asp:Label ID="txtProcessStatus" CssClass="ProcessStatus" Visible="false" runat="server" />
</div>
