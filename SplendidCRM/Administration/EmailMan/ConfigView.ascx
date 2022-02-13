<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ConfigView.ascx.cs" Inherits="SplendidCRM.Administration.EmailMan.ConfigView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	function GmailDefaults()
	{
		var fldMAIL_SMTPSERVER   = document.getElementById('<%= MAIL_SMTPSERVER  .ClientID %>');
		var fldMAIL_SMTPPORT     = document.getElementById('<%= MAIL_SMTPPORT    .ClientID %>');
		var fldMAIL_SMTPAUTH_REQ = document.getElementById('<%= MAIL_SMTPAUTH_REQ.ClientID %>');
		var fldMAIL_SMTPSSL      = document.getElementById('<%= MAIL_SMTPSSL     .ClientID %>');
		// http://forums.microsoft.com/msdn/showpost.aspx?postid=7575&siteid=1&sb=0&d=1&at=7&ft=11&tf=0&pageid=1
		// Gmail Smtp has 2 ports exposed 465 and 587. 465 port is for Exchange structre and thats why the Smtp protocol doesnt work against it. 
		// We have testcases internally that try to send mail to port 587 of gmail and it has been working fine.
		if ( fldMAIL_SMTPSERVER   != null ) fldMAIL_SMTPSERVER.value     = 'smtp.gmail.com';
		if ( fldMAIL_SMTPPORT     != null ) fldMAIL_SMTPPORT.value       = '587';
		if ( fldMAIL_SMTPAUTH_REQ != null ) fldMAIL_SMTPAUTH_REQ.checked = true;
		if ( fldMAIL_SMTPSSL      != null ) fldMAIL_SMTPSSL.checked      = true;
	}
	function toggleAllSecurityOptions()
	{
		var sParentID = '<%= this.ClientID %>';
		var arrDangerousTags = '<%= sDangerousTags %>'.split('|');
		var bToggle = document.getElementById('<%= SECURITY_TOGGLE_ALL.ClientID %>').checked;
		document.getElementById('<%= SECURITY_OUTLOOK_DEFAULTS.ClientID %>').checked = false;
		for ( var i = 0; i < arrDangerousTags.length; i++ )
		{
			document.getElementById(sParentID + '_SECURITY_' + arrDangerousTags[i].toUpperCase()).checked = bToggle;
		}
	}
	function setOutlookDefaults()
	{
		var sParentID = '<%= this.ClientID %>';
		var arrDangerousTags = '<%= sDangerousTags %>'.split('|');
		var arrOutlookTags   = '<%= sOutlookTags   %>'.split('|');
		document.getElementById('<%= SECURITY_TOGGLE_ALL.ClientID %>').checked = false;
		if ( document.getElementById('<%= SECURITY_OUTLOOK_DEFAULTS.ClientID %>').checked )
		{
			for ( var i = 0; i < arrDangerousTags.length; i++ )
			{
				document.getElementById(sParentID + '_SECURITY_' + arrDangerousTags[i].toUpperCase()).checked = false;
			}
			for ( var i = 0; i < arrOutlookTags.length; i++ )
			{
				document.getElementById(sParentID + '_SECURITY_' + arrOutlookTags[i].toUpperCase()).checked = true;
			}
		}
	}

	function OAuthTokenUpdate(access_token, oauth_verifier, realmId, refresh_token, expires_in)
	{
		//var expiresDate = new Date();
		//expiresDate = new Date(expiresDate.valueOf() + expires_in * 1000);
		//var sStatus = 'access_token = '   + access_token   + '\r\n'
		//            + 'oauth_verifier = ' + oauth_verifier + '\r\n'
		//            + 'realmId = '        + realmId        + '\r\n'
		//            + 'refresh_token = '  + refresh_token  + '\r\n'
		//            + 'expires_in = '     + expires_in     + '\r\n';
		//alert(sStatus);
		document.getElementById('<%= OAUTH_ACCESS_TOKEN .ClientID %>').value = access_token  ;
		document.getElementById('<%= OAUTH_REFRESH_TOKEN.ClientID %>').value = refresh_token ;
		document.getElementById('<%= OAUTH_EXPIRES_IN   .ClientID %>').value = expires_in    ;
		var btnGoogleAuthorized = document.getElementById('<%= btnGoogleAuthorized.ClientID %>');
		btnGoogleAuthorized.click();
	}

	function OAuthTokenError(error)
	{
		var lblGoogleAuthorizedStatus = document.getElementById('<%= lblGoogleAuthorizedStatus.ClientID %>');
		lblGoogleAuthorizedStatus.innerHTML = '<%= L10n.Term("Google.LBL_TEST_FAILED") %>';
	}

	// https://console.developers.google.com
	// https://developers.google.com/oauthplayground/
	// https://developers.google.com/identity/protocols/OAuth2
	// https://developers.google.com/identity/protocols/OAuth2WebServer
	// https://developers.google.com/identity/protocols/OAuth2InstalledApp
	// https://developers.google.com/identity/protocols/OpenIDConnect#createxsrftoken
	function GoogleAppsAuthorize()
	{
		var client_id = '<%= Application["CONFIG.GoogleApps.ClientID"] %>';
		window.open('<%= Application["rootURL"] %>GoogleOAuth/default.aspx?client_id=' + client_id, 'GooglePopup', 'width=830,height=830,status=1,toolbar=0,location=0,resizable=1');
		return false;
	}

	// 01/16/2017 Paul.  Add support for Office 365 OAuth. 
	function Office365OCodeUpdate(code)
	{
		document.getElementById('<%= OAUTH_CODE.ClientID %>').value = code;
		var btnOffice365Authorized = document.getElementById('<%= btnOffice365Authorized.ClientID %>');
		btnOffice365Authorized.click();
	}

	function Office365OAuthTokenError(error)
	{
		var lblOffice365AuthorizedStatus = document.getElementById('<%= lblOffice365AuthorizedStatus.ClientID %>');
		lblOffice365AuthorizedStatus.innerHTML = error;
	}

	// https://blogs.msdn.microsoft.com/exchangedev/2014/03/25/using-oauth2-to-access-calendar-contact-and-mail-api-in-office-365-exchange-online/
	function Office365Authorize()
	{
		var state           = '<%= Guid.NewGuid().ToString() %>';
		var client_id       = '<%= Application["CONFIG.Exchange.ClientID"] %>';
		// 02/10/2017 Paul.  One endpoint to rule them all does not work with ExchangeService. https://graph.microsoft.io/en-us/
		// 02/10/2017 Paul.  Use new endpoint. https://msdn.microsoft.com/en-us/office/office365/api/use-outlook-rest-api
		var redirect_url    = '<%= Request.Url.Scheme + "://" + Request.Url.Host + Sql.ToString(Application["rootURL"]) + "OAuth/Office365Landing.aspx" %>';
		// 02/10/2017 Paul.  Change to https://login.microsoftonline.com. 
		// 12/29/2020 Paul.  Update scope to allow sync of contacts, calendars and mailbox. 
		var response_type   = 'code';
		var scope           = '<%= Spring.Social.Office365.Office365Sync.scope %>';
		var authenticateUrl = 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize'
		                    + '?response_type=' + response_type
		                    + '&client_id='     + client_id
		                    + '&redirect_uri='  + encodeURIComponent(redirect_url)
		                    + '&scope='         + escape(scope)
		                    + '&state='         + state
		                    + '&response_mode=query';
		window.open(authenticateUrl, 'Office365AuthorizePopup', 'width=830,height=830,status=1,toolbar=0,location=0,resizable=1');
		return false;
	}
</script>
</SplendidCRM:InlineScript>
<div id="divEditView" runat="server">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="EmailMan" Title="EmailMan.LBL_CAMPAIGN_EMAIL_SETTINGS" EnableModuleLabel="false" EnablePrint="false" EnableHelp="true" Runat="Server" />
	
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabEditView" runat="server">
					<asp:TableHeaderRow>
						<asp:TableHeaderCell ColumnSpan="4"><h4><asp:Label Text='<%# L10n.Term("EmailMan.LBL_NOTIFY_TITLE") %>' runat="server" /></h4></asp:TableHeaderCell>
					</asp:TableHeaderRow>
					<asp:TableRow>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("EmailMan.LBL_NOTIFY_FROMNAME") %>' runat="server" /><asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:TextBox ID="NOTIFY_FROMNAME" size="50" MaxLength="128" Runat="server" />
							<asp:RequiredFieldValidator ID="reqNOTIFY_FROMNAME" ControlToValidate="NOTIFY_FROMNAME" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("EmailMan.LBL_NOTIFY_FROMADDRESS") %>' runat="server" /><asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:TextBox ID="NOTIFY_FROMADDRESS" size="50" MaxLength="128" Runat="server" />
							<asp:RequiredFieldValidator ID="reqNOTIFY_FROMADDRESS" ControlToValidate="NOTIFY_FROMADDRESS" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("EmailMan.LBL_MAIL_SENDTYPE") %>' runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:DropDownList ID="MAIL_SENDTYPE" DataValueField="NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="MAIL_SENDTYPE_SelectedIndexChanged" AutoPostBack="true" Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="15%" CssClass="dataLabel" Visible="false"><asp:Label Text='<%# L10n.Term("EmailMan.LBL_NOTIFY_SEND_FROM_ASSIGNING_USER") %>' runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField" Visible="false"><asp:CheckBox ID="NOTIFY_SEND_FROM_ASSIGNING_USER" CssClass="checkbox" Runat="server" /></asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:Table ID="tblSmtpPanel" SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblSmtp" class="tabEditView" runat="server">
					<tr>
						<th colspan="4"><h4><asp:Label Text='<%# L10n.Term("Users.LBL_SMTP_TITLE") %>' runat="server" /></h4></th>
					</tr>
					<tr>
						<td Width="15%" CssClass="dataLabel"><asp:Label ID="MAIL_SMTPSERVER_LABEL" Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPSERVER") %>' runat="server" /><asp:Label ID="MAIL_SMTPSERVER_REQUIRED_SYMBOL" CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></td>
						<td Width="35%" CssClass="dataField">
							<asp:TextBox ID="MAIL_SMTPSERVER" size="25" MaxLength="64" Runat="server" />
							&nbsp;
							<asp:LinkButton ID="btnGmailDefaults" OnClientClick="GmailDefaults(); return false;" Text='<%# L10n.Term("EmailMan.LBL_EMAIL_GMAIL_DEFAULTS") %>' runat="server" />
							<asp:RequiredFieldValidator ID="reqMAIL_SMTPSERVER" ControlToValidate="MAIL_SMTPSERVER" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
						</td>
						<td Width="15%" CssClass="dataLabel"><asp:Label ID="MAIL_SMTPPORT_LABEL" Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPPORT") %>' runat="server" /><asp:Label ID="MAIL_SMTPPORT_REQUIRED_SYMBOL" CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></td>
						<td Width="35%" CssClass="dataField">
							<asp:TextBox ID="MAIL_SMTPPORT" size="25" MaxLength="64" Runat="server" />
							<asp:RequiredFieldValidator ID="reqMAIL_SMTPPORT" ControlToValidate="MAIL_SMTPPORT" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
						</td>
					</tr>
					<tr>
						<td CssClass="dataLabel"><asp:Label ID="MAIL_SMTPAUTH_REQ_LABEL" Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPAUTH_REQ") %>' runat="server" /></td>
						<td CssClass="dataField"><asp:CheckBox ID="MAIL_SMTPAUTH_REQ" Enabled="true" CssClass="checkbox" Runat="server" /></td>
						<td CssClass="dataLabel"><asp:Label ID="MAIL_SMTPSSL_LABEL" Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPSSL") %>' runat="server" /></td>
						<td CssClass="dataField"><asp:CheckBox ID="MAIL_SMTPSSL" CssClass="checkbox" Runat="server" /></td>
					</tr>
					<tr>
						<td Width="15%" CssClass="dataLabel"><asp:Label ID="MAIL_SMTPUSER_LABEL" Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPUSER") %>' runat="server" /><asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></td>
						<td Width="35%" CssClass="dataField">
							<asp:TextBox ID="MAIL_SMTPUSER" size="25" MaxLength="64" Runat="server" />
							<asp:RequiredFieldValidator ID="reqMAIL_SMTPUSER" ControlToValidate="MAIL_SMTPUSER" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
						</td>
						<td Width="15%" CssClass="dataLabel"><asp:Label ID="MAIL_SMTPPASS_LABEL" Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPPASS") %>' runat="server" /><asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></td>
						<td Width="35%" CssClass="dataField">
							<asp:TextBox ID="MAIL_SMTPPASS" size="25" MaxLength="64" TextMode="Password" Runat="server" />
							<asp:RequiredFieldValidator ID="reqMAIL_SMTPPASS" ControlToValidate="MAIL_SMTPPASS" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
						</td>
					</tr>
				</table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:HiddenField ID="NEW_ID" runat="server" />
	<div style="display: none;">
		Access Token:       <asp:TextBox ID="OAUTH_ACCESS_TOKEN"  runat="server" />&nbsp;&nbsp;
		Refresh Token:      <asp:TextBox ID="OAUTH_REFRESH_TOKEN" runat="server" />&nbsp;&nbsp;
		Expires In:         <asp:TextBox ID="OAUTH_EXPIRES_IN"    runat="server" />&nbsp;&nbsp;
		Authorization Code: <asp:TextBox ID="OAUTH_CODE"          runat="server" />&nbsp;&nbsp;
		<asp:Button ID="btnGoogleAuthorized"    CommandName="GoogleApps.Authorize" OnCommand="Page_Command" Text="Google Apps Authorized" style="display: none;" runat="server" />
		<asp:Button ID="btnOffice365Authorized" CommandName="Office365.Authorize"  OnCommand="Page_Command" Text="Office 365 Authorized"  style="display: none;" runat="server" />
	</div>

	<asp:Table ID="tblOffice365Panel" SkinID="tabForm" Visible="false" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblOffice365Options" class="tabEditView" runat="server">
					<tr>
						<th colspan="4"><h4><asp:Label Text='<%# L10n.Term("OutboundEmail.LBL_OFFICE365_TITLE") %>' runat="server" /></h4></th>
					</tr>
				</table>
				<asp:Label ID="lblOffice365Authorized"    Visible="false" Text='<%# L10n.Term("OAuth.LBL_AUTHORIZED") %>' runat="server" />
				&nbsp;
				<asp:Button ID="btnOffice365Authorize"    Visible="false" OnClientClick="return Office365Authorize();" style="margin-top: 4px;"  CssClass="button" Text='<%# "  " + L10n.Term("OAuth.LBL_AUTHORIZE_BUTTON_LABEL") + "  " %>' Runat="server" />
				&nbsp;
				<asp:Button ID="btnOffice365Delete"       Visible="false" CommandName="Office365.Delete"       OnCommand="Page_Command" style="margin-top: 4px;"  CssClass="button" Text='<%# "  " + L10n.Term("OAuth.LBL_DELETE_BUTTON_LABEL") + "  " %>' Runat="server" />
				&nbsp;
				<asp:Button ID="btnOffice365Test"         Visible="false" CommandName="Office365.Test"         OnCommand="Page_Command" style="margin-top: 4px;"  CssClass="button" Text='<%# "  " + L10n.Term("OAuth.LBL_TEST_BUTTON_LABEL"  ) + "  " %>' Runat="server" />
				&nbsp;
				<asp:Button ID="btnOffice365RefreshToken" Visible="false" CommandName="Office365.RefreshToken" OnCommand="Page_Command" style="margin-top: 4px;"  CssClass="button" Text='<%# "  " + L10n.Term("OAuth.LBL_REFRESH_TOKEN_LABEL") + "  " %>' Runat="server" />
				&nbsp;
				<asp:Label ID="lblOffice365AuthorizedStatus" CssClass="error" EnableViewState="false" runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:Table ID="tblGoogleAppsPanel" SkinID="tabForm" Visible="false" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblGoogleAppsOptions" class="tabEditView" runat="server">
					<tr>
						<th colspan="4"><h4><asp:Label Text='<%# L10n.Term("OutboundEmail.LBL_GMAIL_TITLE") %>' runat="server" /></h4></th>
					</tr>
				</table>
				<asp:Label ID="lblGoogleAppsAuthorized"    Visible="false" Text='<%# L10n.Term("OAuth.LBL_AUTHORIZED") %>' runat="server" />
				&nbsp;
				<asp:Button ID="btnGoogleAppsAuthorize"    Visible="false" OnClientClick="return GoogleAppsAuthorize();" style="margin-top: 4px;"  CssClass="button" Text='<%# "  " + L10n.Term("OAuth.LBL_AUTHORIZE_BUTTON_LABEL") + "  " %>' Runat="server" />
				&nbsp;
				<asp:Button ID="btnGoogleAppsDelete"       Visible="false" CommandName="GoogleApps.Delete"        OnCommand="Page_Command" style="margin-top: 4px;"  CssClass="button" Text='<%# "  " + L10n.Term("OAuth.LBL_DELETE_BUTTON_LABEL") + "  " %>' Runat="server" />
				&nbsp;
				<asp:Button ID="btnGoogleAppsTest"         Visible="false" CommandName="GoogleApps.Test"          OnCommand="Page_Command" style="margin-top: 4px;"  CssClass="button" Text='<%# "  " + L10n.Term("OAuth.LBL_TEST_BUTTON_LABEL") + "  " %>' Runat="server" />
				&nbsp;
				<asp:Button ID="btnGoogleAppsRefreshToken" Visible="false"  CommandName="GoogleApps.RefreshToken" OnCommand="Page_Command" style="margin-top: 4px;"  CssClass="button" Text='<%# "  " + L10n.Term("OAuth.LBL_REFRESH_TOKEN_LABEL") + "  " %>' Runat="server" />
				&nbsp;
				<asp:Label ID="lblGoogleAuthorizedStatus" CssClass="error" EnableViewState="false" runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabEditView" runat="server">
					<asp:TableHeaderRow>
						<asp:TableHeaderCell ColumnSpan="4"><h4><asp:Label Text='<%# L10n.Term("EmailMan.LBL_SECURITY_TITLE") %>' runat="server" /></h4></asp:TableHeaderCell>
					</asp:TableHeaderRow>
					<asp:TableRow>
						<asp:TableCell ColumnSpan="4"><asp:Label Text='<%# L10n.Term("EmailMan.LBL_SECURITY_DESC") %>' runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell ColumnSpan="2">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="1%" VerticalAlign="Top">
							<asp:CheckBox ID="EMAIL_INBOUND_SAVE_RAW" CssClass="checkbox" runat="server" />
						</asp:TableCell>
						<asp:TableCell>
							<asp:Label Text='<%# L10n.Term("EmailMan.LBL_SECURITY_PRESERVE_RAW") %>' runat="server" /><br />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell ColumnSpan="2">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell VerticalAlign="Top">
							<asp:CheckBox ID="SECURITY_TOGGLE_ALL" CssClass="checkbox" onclick="toggleAllSecurityOptions();" runat="server" />
						</asp:TableCell>
						<asp:TableCell>
							<asp:Label Text='<%# L10n.Term("EmailMan.LBL_SECURITY_TOGGLE_ALL") %>' runat="server" /><br />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell ColumnSpan="2">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell VerticalAlign="Top">
							<asp:CheckBox ID="SECURITY_OUTLOOK_DEFAULTS" CssClass="checkbox" onclick="setOutlookDefaults();" runat="server" />
						</asp:TableCell>
						<asp:TableCell>
							<asp:Label Text='<%# L10n.Term("EmailMan.LBL_SECURITY_OUTLOOK_DEFAULTS") %>' runat="server" /><br />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell ColumnSpan="2">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell ColumnSpan="2">
							<asp:Table ID="tblSECURITY_TAGS" runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

