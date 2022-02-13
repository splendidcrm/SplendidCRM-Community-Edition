<%@ Control CodeBehind="AdminWizard.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.Configurator.AdminWizard" %>
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
function SetBrowserDefaultTimezone()
{
	var lstTIMEZONE  = document.getElementById('<%= lstTIMEZONE.ClientID %>');
	if ( lstTIMEZONE != null )
	{
		if ( lstTIMEZONE.options.selectedIndex == 0 )
		{
			var dtJanuary = new Date((new Date()).getFullYear(), 0, 1, 0, 0, 0);
			
			var sDefaultOffset;
			if ( dtJanuary.getTimezoneOffset() > 0 )
				sDefaultOffset = '(GMT-' + ('0' +    dtJanuary.getTimezoneOffset()/60 + ':00').substring(0, 5) + ')';
			else
				sDefaultOffset = '(GMT+' + ('0' + -1*dtJanuary.getTimezoneOffset()/60 + ':00').substring(0, 5) + ')';

			for ( i = 0; i < lstTIMEZONE.options.length; i++ )
			{
				if ( lstTIMEZONE.options[i].text.substring(0, sDefaultOffset.length) == sDefaultOffset )
				{
					lstTIMEZONE.options.selectedIndex = i;
					break;
				}
			}
		}
	}
}
</script>
<div id="divAdminWizard">
	<script runat="server">
	// 07/09/2010 Paul.  There is a documented issue with a FileUpload control inside an UpdatePanel. 
	// The solution is to set the postback control that submits the file to be a PostBackTrigger for the panel. 
	</script>
	<asp:UpdatePanel UpdateMode="Conditional" runat="server">
		<Triggers>
			<asp:PostBackTrigger ControlID="btnUploadImage" />
			<asp:PostBackTrigger ControlID="btnUploadAtlanticImage" />
			<asp:PostBackTrigger ControlID="btnSystemNameNext" />
		</Triggers>
		<ContentTemplate>
			<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
				<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
			</asp:Panel>

			<asp:Table Width="820px" CellPadding="20" HorizontalAlign="Center" runat="server">
				<asp:TableRow>
					<asp:TableCell>
						<asp:Table ID="tblSystemName" SkinID="tabForm" Height="440px" runat="server">
							<asp:TableRow Height="20px" style="padding-top: 20px;">
								<asp:TableCell style="padding-left: 20px;"><h2><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_SYSTEM_TITLE") %>' runat="server" /></h2></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow Height="10px">
								<asp:TableCell style="padding-left: 20px;"><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_SYSTEM_DESC") %>' Font-Italic="true" runat="server" /></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow>
								<asp:TableCell VerticalAlign="Top" style="padding-left: 20px;">
									<asp:Table runat="server">
										<asp:TableRow>
											<asp:TableCell Width="15%"><asp:Label Text='<%# L10n.Term("Configurator.LBL_COMPANY_NAME") %>' runat="server" /></asp:TableCell>
											<asp:TableCell Width="35%"><asp:TextBox ID="COMPANY_NAME" size="40" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell Width="15%"><asp:Label Text='<%# L10n.Term("Configurator.LBL_HEADER_LOGO_IMAGE") %>' runat="server" /></asp:TableCell>
											<asp:TableCell Width="35%"><asp:TextBox ID="HEADER_LOGO_IMAGE" size="40" Runat="server" /></asp:TableCell>
											<asp:TableCell Width="50%">
												<asp:FileUpload ID="UPLOAD_LOGO_IMAGE" size="30" runat="server" />
												&nbsp;
												<asp:Button ID="btnUploadImage" UseSubmitBehavior="false" CommandName="Upload.Image" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_UPLOAD_BUTTON") + "  " %>' Runat="server" />
											</asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Configurator.LBL_HEADER_LOGO_WIDTH") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="HEADER_LOGO_WIDTH" size="10" Runat="server" /></asp:TableCell>
											<asp:TableCell RowSpan="3"><asp:Image ID="imgCompanyLogo" runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Configurator.LBL_HEADER_LOGO_HEIGHT") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="HEADER_LOGO_HEIGHT" size="10" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Configurator.LBL_HEADER_LOGO_STYLE") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="HEADER_LOGO_STYLE" size="20" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label  Text='<%# L10n.Term("Configurator.LBL_ATLANTIC_HOME_IMAGE") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="ATLANTIC_HOME_IMAGE" size="40" Runat="server" /></asp:TableCell>
											<asp:TableCell Width="50%">
												<asp:FileUpload ID="UPLOAD_ATLANTIC_IMAGE" size="30" runat="server" />
												&nbsp;
												<asp:Button ID="btnUploadAtlanticImage" UseSubmitBehavior="false" CommandName="Upload.AtlanticImage" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_UPLOAD_BUTTON") + "  " %>' Runat="server" />
											</asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell>&nbsp;</asp:TableCell>
											<asp:TableCell>&nbsp;</asp:TableCell>
											<asp:TableCell RowSpan="3"><asp:Image ID="imgAtlanticLogo" runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
										</asp:TableRow>
									</asp:Table>
								</asp:TableCell>
							</asp:TableRow>
							<asp:TableRow Height="20px">
								<asp:TableCell VerticalAlign="Bottom" HorizontalAlign="Right" style="padding-right: 20px;">
									<asp:Button UseSubmitBehavior="false" CommandName="Skip" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_SKIP_BUTTON") + "  " %>' Visible="<%# nWizardPanel == 0 %>" Runat="server" />
									<asp:Button UseSubmitBehavior="false" CommandName="Back" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_BACK_BUTTON") + "  " %>' Visible="<%# nWizardPanel > 0  %>" Runat="server" />
									&nbsp;
									<asp:Button ID="btnSystemNameNext" UseSubmitBehavior="true" CommandName="Next" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_NEXT_BUTTON") + "  " %>' Runat="server" />
								</asp:TableCell>
							</asp:TableRow>
						</asp:Table>

						<asp:Table ID="tblSystemLocale" SkinID="tabForm" Height="440px" runat="server">
							<asp:TableRow Height="20px" style="padding-top: 20px;">
								<asp:TableCell style="padding-left: 20px;"><h2><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_LOCALE_TITLE") %>' runat="server" /></h2></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow Height="10px">
								<asp:TableCell style="padding-left: 20px;"><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_LOCALE_DESC") %>' Font-Italic="true" runat="server" /></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow>
								<asp:TableCell VerticalAlign="Top" style="padding-left: 20px;">
									<asp:Table runat="server">
										<asp:TableRow>
											<asp:TableCell Width="15%" VerticalAlign="Top"><asp:Label Text='<%# L10n.Term("Users.LBL_LANGUAGE") %>' runat="server" /></asp:TableCell>
											<asp:TableCell Width="35%"><asp:DropDownList ID="lstLANGUAGE" DataValueField="NAME" DataTextField="NATIVE_NAME" OnSelectedIndexChanged="lstLANGUAGE_Changed" AutoPostBack="true" Runat="server" /></asp:TableCell>
											<asp:TableCell Width="15%"><asp:Label Text='<%# L10n.Term("Users.LBL_CURRENCY") %>' runat="server" /></asp:TableCell>
											<asp:TableCell Width="35%"><asp:DropDownList ID="lstCURRENCY" DataValueField="ID" DataTextField="NAME_SYMBOL" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_DATE_FORMAT") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:DropDownList ID="lstDATE_FORMAT" Runat="server" /></asp:TableCell>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_TIME_FORMAT") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:DropDownList ID="lstTIME_FORMAT" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_TIMEZONE") %>' runat="server" /></asp:TableCell>
											<asp:TableCell>
												<asp:DropDownList ID="lstTIMEZONE" DataValueField="ID" DataTextField="NAME" Runat="server" />
												<SplendidCRM:InlineScript runat="server">
													<script type="text/javascript">
														SetBrowserDefaultTimezone();
													</script>
												</SplendidCRM:InlineScript>
											</asp:TableCell>
										</asp:TableRow>
									</asp:Table>
								</asp:TableCell>
							</asp:TableRow>
							<asp:TableRow Height="20px">
								<asp:TableCell VerticalAlign="Bottom" HorizontalAlign="Right" style="padding-right: 20px;">
									<asp:Button UseSubmitBehavior="false" CommandName="Back" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_BACK_BUTTON") + "  " %>' Runat="server" />
									&nbsp;
									<asp:Button UseSubmitBehavior="true"  CommandName="Next" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_NEXT_BUTTON") + "  " %>' Runat="server" />
								</asp:TableCell>
							</asp:TableRow>
						</asp:Table>

						<asp:Table ID="tblMailSettings" SkinID="tabForm" Height="440px" runat="server">
							<asp:TableRow Height="20px" style="padding-top: 20px;">
								<asp:TableCell style="padding-left: 20px;"><h2><asp:Label Text='<%# L10n.Term("Configurator.LBL_MAIL_SMTP_SETTINGS") %>' runat="server" /></h2></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow Height="10px">
								<asp:TableCell style="padding-left: 20px;"><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_SMTP_DESC") %>' Font-Italic="true" runat="server" /></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow>
								<asp:TableCell VerticalAlign="Top" style="padding-left: 20px;">
									<asp:Table runat="server">
										<asp:TableRow>
											<asp:TableCell ColumnSpan="4">
												<asp:Button UseSubmitBehavior="false" CommandName="SmtpType.Gmail" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_SMTPTYPE_GMAIL") + "  " %>' Runat="server" />
												&nbsp;
												<asp:Button UseSubmitBehavior="false" CommandName="SmtpType.Yahoo" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_SMTPTYPE_YAHOO") + "  " %>' Runat="server" />
												&nbsp;
												<asp:Button UseSubmitBehavior="false" CommandName="SmtpType.Other" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_SMTPTYPE_OTHER") + "  " %>' Runat="server" />
											</asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell Width="15%" VerticalAlign="Top"><asp:Label Text='<%# L10n.Term("EmailMan.LBL_NOTIFY_FROMNAME") %>' runat="server" /></asp:TableCell>
											<asp:TableCell Width="35%"><asp:TextBox ID="NOTIFY_FROMNAME" size="25" MaxLength="128" runat="server" /></asp:TableCell>
											<asp:TableCell Width="15%"><asp:Label Text='<%# L10n.Term("EmailMan.LBL_NOTIFY_FROMADDRESS") %>' runat="server" /></asp:TableCell>
											<asp:TableCell Width="35%"><asp:TextBox ID="NOTIFY_FROMADDRESS" size="25" MaxLength="128" runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell Width="15%" VerticalAlign="Top"><asp:Label Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPSERVER") %>' runat="server" /></asp:TableCell>
											<asp:TableCell Width="35%"><asp:TextBox ID="MAIL_SMTPSERVER" size="25" MaxLength="64" runat="server" /></asp:TableCell>
											<asp:TableCell Width="15%"><asp:Label Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPPORT") %>' runat="server" /></asp:TableCell>
											<asp:TableCell Width="35%"><asp:TextBox ID="MAIL_SMTPPORT" size="10" MaxLength="10" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPAUTH_REQ") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:CheckBox ID="MAIL_SMTPAUTH_REQ" CssClass="checkbox" Runat="server" /></asp:TableCell>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPSSL") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:CheckBox ID="MAIL_SMTPSSL" CssClass="checkbox" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPUSER") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="MAIL_SMTPUSER" size="25" MaxLength="64" Runat="server" /></asp:TableCell>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPPASS") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="MAIL_SMTPPASS" size="25" MaxLength="64" TextMode="Password" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell ColumnSpan="4">
												<asp:Button UseSubmitBehavior="false" CommandName="Smtp.Clear" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_CLEAR_BUTTON_TITLE") + "  " %>' Runat="server" />
												&nbsp;
												<asp:Button UseSubmitBehavior="false" CommandName="Smtp.Test"  OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_EMAIL_TEST_OUTBOUND_SETTINGS") + "  " %>' Runat="server" />
											</asp:TableCell>
										</asp:TableRow>
									</asp:Table>
								</asp:TableCell>
							</asp:TableRow>
							<asp:TableRow Height="20px">
								<asp:TableCell VerticalAlign="Bottom" HorizontalAlign="Right" style="padding-right: 20px;">
									<asp:Button UseSubmitBehavior="false" CommandName="Back" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_BACK_BUTTON") + "  " %>' Runat="server" />
									&nbsp;
									<asp:Button UseSubmitBehavior="true" CommandName="Continue" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_CONTINUE_BUTTON") + "  " %>' Runat="server" />
								</asp:TableCell>
							</asp:TableRow>
						</asp:Table>
					</asp:TableCell>
				</asp:TableRow>
			</asp:Table>
		</ContentTemplate>
	</asp:UpdatePanel>
</div>

