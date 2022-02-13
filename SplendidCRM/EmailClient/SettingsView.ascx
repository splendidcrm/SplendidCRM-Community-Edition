<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SettingsView.ascx.cs" Inherits="SplendidCRM.EmailClient.SettingsView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<SplendidCRM:InlineScript runat="server">
<script type="text/javascript">
function toggleUseSSL()
{
	var MAILBOX_SSL = document.getElementById('<%= new SplendidCRM.DynamicControl(this, "MAILBOX_SSL").ClientID %>');
	var PORT        = document.getElementById('<%= new SplendidCRM.DynamicControl(this, "PORT"       ).ClientID %>');
	if ( MAILBOX_SSL != null && PORT != null )
	{
		if ( MAILBOX_SSL.checked )
			PORT.value = '<%= (sSERVICE == "imap") ? "993" : ((sSERVICE == "pop3") ? "995" : String.Empty) %>';
		else
			PORT.value = '<%= (sSERVICE == "imap") ? "143" : ((sSERVICE == "pop3") ? "110" : String.Empty) %>';
	}
}
function GmailDefaults()
{
	var SERVER_URL  = document.getElementById('<%= new SplendidCRM.DynamicControl(this, "SERVER_URL" ).ClientID %>');
	var MAILBOX_SSL = document.getElementById('<%= new SplendidCRM.DynamicControl(this, "MAILBOX_SSL").ClientID %>');
	var PORT        = document.getElementById('<%= new SplendidCRM.DynamicControl(this, "PORT"       ).ClientID %>');
	if ( SERVER_URL != null && MAILBOX_SSL != null && PORT != null )
	{
		SERVER_URL.value = '<%= (sSERVICE == "imap") ? "imap.gmail.com" : ((sSERVICE == "pop3") ? "pop.gmail.com" : String.Empty) %>';
		PORT.value = '<%= (sSERVICE == "imap") ? "993" : ((sSERVICE == "pop3") ? "995" : String.Empty) %>';
		MAILBOX_SSL.checked = true;
	}
}
</script>
</SplendidCRM:InlineScript>
<div id="divEditView" runat="server">
	<p></p>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Visible="<%# !PrintView %>" ShowRequired="true" Runat="Server" />
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblMain" class="tabEditView" runat="server">
				</table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
</div>

