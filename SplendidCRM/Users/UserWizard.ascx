<%@ Control CodeBehind="UserWizard.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Users.UserWizard" %>
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
<div id="divUserWizard">
	<asp:UpdatePanel UpdateMode="Conditional" runat="server">
		<ContentTemplate>
			<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
				<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
			</asp:Panel>

			<asp:Table Width="820px" CellPadding="20" HorizontalAlign="Center" runat="server">
				<asp:TableRow>
					<asp:TableCell>
						<asp:Table ID="tblUserSettings" SkinID="tabForm" Height="440px" runat="server">
							<asp:TableRow Height="20px" style="padding-top: 20px;">
								<asp:TableCell style="padding-left: 20px;"><h2><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_USER_SETTINGS_TITLE") %>' runat="server" /></h2></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow Height="10px">
								<asp:TableCell style="padding-left: 20px;"><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_USER_SETTINGS_DESC") %>' Font-Italic="true" runat="server" /></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow>
								<asp:TableCell VerticalAlign="Top" style="padding-left: 20px;">
									<asp:Table runat="server">
										<asp:TableRow>
											<asp:TableCell Width="15%"><asp:Label Text='<%# L10n.Term("Users.LBL_FIRST_NAME") %>' runat="server" /></asp:TableCell>
											<asp:TableCell Width="35%"><asp:TextBox ID="FIRST_NAME" size="25" MaxLength="30" Runat="server" /></asp:TableCell>
											<asp:TableCell Width="15%"><asp:Label Text='<%# L10n.Term("Users.LBL_LAST_NAME") %>' runat="server" />&nbsp;<asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /></asp:TableCell>
											<asp:TableCell Width="35%">
												<asp:TextBox ID="LAST_NAME" size="25" MaxLength="30" Runat="server" />
												<asp:RequiredFieldValidator ID="LAST_NAME_REQUIRED" ControlToValidate="LAST_NAME" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
											</asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_EMAIL") %>' runat="server" />&nbsp;<asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /></asp:TableCell>
											<asp:TableCell>
												<asp:TextBox ID="EMAIL1" size="25" MaxLength="100" Runat="server" />
												<asp:RequiredFieldValidator ID="EMAIL1_REQUIRED" ControlToValidate="EMAIL1" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" style="padding-left: 4px" EnableClientScript="false" EnableViewState="false" Runat="server" />
												<asp:RegularExpressionValidator ID="EMAIL1_VALIDATOR" ControlToValidate="EMAIL1" ErrorMessage='<%# L10n.Term(".ERR_INVALID_EMAIL_ADDRESS") %>' ValidationExpression="^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$" CssClass="required" style="padding-left: 4px" EnableClientScript="false" EnableViewState="false" Runat="server" />
											</asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_OFFICE_PHONE") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="PHONE_WORK" size="25" MaxLength="50" Runat="server" /></asp:TableCell>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_MOBILE_PHONE") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="PHONE_MOBILE" size="25" MaxLength="50" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_PRIMARY_ADDRESS") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="ADDRESS_STREET" TextMode="MultiLine" Rows="2" Columns="30" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_CITY") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="ADDRESS_CITY" size="25" MaxLength="100" Runat="server" /></asp:TableCell>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_STATE") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="ADDRESS_STATE" size="25" MaxLength="100" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_POSTAL_CODE") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="ADDRESS_POSTALCODE" size="10" MaxLength="9" Runat="server" /></asp:TableCell>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_COUNTRY") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="ADDRESS_COUNTRY" size="20" MaxLength="25" Runat="server" /></asp:TableCell>
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
									<asp:Button UseSubmitBehavior="true"  CommandName="Next" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_NEXT_BUTTON") + "  " %>' Runat="server" />
								</asp:TableCell>
							</asp:TableRow>
						</asp:Table>

						<asp:Table ID="tblUserLocale" SkinID="tabForm" Height="440px" runat="server">
							<asp:TableRow Height="20px" style="padding-top: 20px;">
								<asp:TableCell style="padding-left: 20px;"><h2><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_USER_LOCALE_TITLE") %>' runat="server" /></h2></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow Height="10px">
								<asp:TableCell style="padding-left: 20px;"><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_USER_LOCALE_DESC") %>' Font-Italic="true" runat="server" /></asp:TableCell>
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
								<asp:TableCell style="padding-left: 20px;"><h2><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_USER_MAIL_TITLE") %>' runat="server" /></h2></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow Height="10px">
								<asp:TableCell style="padding-left: 20px;"><asp:Label Text='<%# L10n.Term("Configurator.LBL_WIZARD_USER_MAIL_DESC") %>' Font-Italic="true" runat="server" /></asp:TableCell>
							</asp:TableRow>
							<asp:TableRow>
								<asp:TableCell VerticalAlign="Top" style="padding-left: 20px;">
									<asp:Table runat="server">
										<asp:TableRow>
											<asp:TableCell VerticalAlign="Top"><asp:Label Text='<%# L10n.Term("EmailMan.LBL_MAIL_SMTPSERVER") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:Label ID="MAIL_SMTPSERVER" runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_MAIL_SMTPUSER") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="MAIL_SMTPUSER" size="25" MaxLength="64" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell><asp:Label Text='<%# L10n.Term("Users.LBL_MAIL_SMTPPASS") %>' runat="server" /></asp:TableCell>
											<asp:TableCell><asp:TextBox ID="MAIL_SMTPPASS" size="25" MaxLength="64" TextMode="Password" Runat="server" /></asp:TableCell>
										</asp:TableRow>
										<asp:TableRow>
											<asp:TableCell ColumnSpan="4">
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
									<asp:Button UseSubmitBehavior="true"  CommandName="Finish" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Configurator.LBL_FINISH_BUTTON") + "  " %>' Runat="server" />
								</asp:TableCell>
							</asp:TableRow>
						</asp:Table>
					</asp:TableCell>
				</asp:TableRow>
			</asp:Table>
		</ContentTemplate>
	</asp:UpdatePanel>
</div>

