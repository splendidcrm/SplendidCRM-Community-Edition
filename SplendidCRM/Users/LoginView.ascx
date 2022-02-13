<%@ Control Language="c#" AutoEventWireup="false" Codebehind="LoginView.ascx.cs" Inherits="SplendidCRM.Users.LoginView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
window.onload = function()
{
	set_focus();
	try
	{
		// 01/08/2008 Paul.  showLeftCol does not exist on the mobile master page. 
		showLeftCol(false, false);
	}
	catch(e)
	{
	}
}
function set_focus()
{
	var user_name     = document.getElementById('<%= txtUSER_NAME.ClientID %>');
	var user_password = document.getElementById('<%= txtPASSWORD.ClientID  %>');
	if ( user_name != null )
	{
		try
		{
			if ( user_name.value != '' && user_password != null )
			{
				user_password.focus();
				user_password.select();
			}
			else
			{
				user_name.focus();
			}
		}
		catch(e)
		{
		}
	}
}
</script>
<div id="divLoginView" class="loginForm">
	<div Visible="<%# !this.IsMobile %>" style="height: 80px;" runat="server" />
	<asp:Table HorizontalAlign="Center" CellPadding="0" CellSpacing="0" CssClass="LoginActionsShadingTable" style="width: 450px;" runat="server">
		<asp:TableRow>
			<asp:TableCell ColumnSpan="3" CssClass="LoginActionsShadingHorizontal" />
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="LoginActionsShadingVertical" />
			<asp:TableCell>
				<asp:Table Width="100%" CellPadding="0" CellSpacing="0" HorizontalAlign="Center" CssClass="LoginActionsInnerTable" runat="server">
					<asp:TableRow>
						<asp:TableCell style="padding-top: 20px; padding-bottom: 20px; padding-left: 40px; padding-right: 40px;">
							<asp:Table Width="100%" BorderWidth="0" CellPadding="0" CellSpacing="2" runat="server">
								<asp:TableRow runat="server">
									<asp:TableCell style="font-family: Arial; font-size: 14pt; font-weight: bold; color: #003564;">
										SplendidCRM <%# Application["CONFIG.service_level"] %>
									</asp:TableCell>
								</asp:TableRow>
							</asp:Table>
							<asp:Table ID="tblUser" Visible="<%# !Security.IsWindowsAuthentication() %>" Width="100%" BorderWidth="0" CellPadding="0" CellSpacing="2" HorizontalAlign="Center" Runat="server">
								<asp:TableRow>
									<asp:TableCell ColumnSpan="2" style="font-size: 12px; padding-top: 5px;">
										<asp:Label ID="lblInstructions" Visible="<%# !Security.IsWindowsAuthentication() %>" Text='<%# L10n.Term(".NTC_LOGIN_MESSAGE") %>' CssClass="loginInstructions" Runat="server" />
									</asp:TableCell>
								</asp:TableRow>
								<asp:TableRow ID="trError" Visible="false" runat="server">
									<asp:TableCell ColumnSpan="2">
										<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
									</asp:TableCell>
								</asp:TableRow>
								<asp:TableRow ID="trUserName" runat="server">
									<asp:TableCell Width="30%" CssClass="dataLabel"><%# L10n.Term("Users.LBL_USER_NAME") %></asp:TableCell>
									<asp:TableCell Width="70%" CssClass="loginField">
										<asp:TextBox ID="txtUSER_NAME" placeholder='<%# Sql.ToString(Application["CONFIG.default_theme"]) == "Arctic" ? L10n.Term("Users.LBL_USER_NAME").Replace(":", "") : String.Empty %>' Runat="server" /> &nbsp;<%# (Sql.IsEmptyString(Application["CONFIG.default_user_name"]) ? String.Empty : "(" + Sql.ToString(Application["CONFIG.default_user_name"]) + ")") %>
									</asp:TableCell>
								</asp:TableRow>
								<asp:TableRow ID="trPassword" runat="server">
									<asp:TableCell Width="30%" CssClass="dataLabel"><%# L10n.Term("Users.LBL_PASSWORD") %></asp:TableCell>
									<asp:TableCell Width="70%" CssClass="loginField">
										<asp:TextBox ID="txtPASSWORD" TextMode="Password" placeholder='<%# Sql.ToString(Application["CONFIG.default_theme"]) == "Arctic" ? L10n.Term("Users.LBL_PASSWORD").Replace(":", "") : String.Empty %>' Runat="server" /> &nbsp;<%# (Sql.IsEmptyString(Application["CONFIG.default_password"]) ? String.Empty : "(" + Sql.ToString(Application["CONFIG.default_password"]) + ")") %>
									</asp:TableCell>
								</asp:TableRow>
							</asp:Table>
							<asp:Table Width="100%" BorderWidth="0" CellPadding="0" CellSpacing="2" HorizontalAlign="Center" runat="server">
								<asp:TableRow>
									<asp:TableCell Width="30%">&nbsp;</asp:TableCell>
									<asp:TableCell Width="70%" Wrap="false">
										<asp:Table Width="100%" BorderWidth="0" CellPadding="0" CellSpacing="2" runat="server">
											<asp:TableRow>
												<asp:TableCell HorizontalAlign="Left">
													<asp:Button ID="btnLogin" CommandName="Login" OnCommand="Page_Command" CssClass="button" Text='<%# " "  + L10n.Term("Users.LBL_LOGIN_BUTTON_LABEL") + " "  %>' ToolTip='<%# L10n.Term("Users.LBL_LOGIN_BUTTON_TITLE") %>' Runat="server" />
													&nbsp;
													<asp:HyperLink ID="lnkWorkOnline"  Text='<%# L10n.Term("Offline.LNK_WORK_ONLINE"  ) %>' NavigateUrl="~/Users/ClientLogin.aspx" Visible="false" runat="server" />
													<asp:HyperLink ID="lnkHTML5Client" Text='<%# L10n.Term(".LNK_MOBILE_CLIENT"       ) %>' NavigateUrl="~/html5/default.aspx"     Visible="false" runat="server" />
													<asp:HyperLink ID="lnkReactClient" Text='<%# L10n.Term(".LNK_REACT_CLIENT"        ) %>' NavigateUrl="~/React/default.aspx"     Visible="false" runat="server" />
												</asp:TableCell>
												<asp:TableCell>
													<%@ Register TagPrefix="SplendidCRM" Tagname="FacebookLogin" Src="FacebookLogin.ascx" %>
													<SplendidCRM:FacebookLogin ID="ctlFacebookLogin" Runat="Server" />
												</asp:TableCell>
											</asp:TableRow>
										</asp:Table>
									</asp:TableCell>
								</asp:TableRow>
								<asp:TableRow ID="trShowForgotPassword" Visible=<%# !Security.IsWindowsAuthentication() && !Utils.CachedFileExists(Context, "~/Users/ClientLogin.aspx") %> runat="server">
									<asp:TableCell ColumnSpan="2" HorizontalAlign="Right" style="padding-top: 10px;">
										<asp:HyperLink NavigateUrl=<%# "javascript:document.getElementById('" + txtFORGOT_USER_NAME.ClientID + "').value = document.getElementById('" + txtUSER_NAME.ClientID + "').value; toggleDisplay('" + pnlForgotPassword.ClientID + "');" %> CssClass="utilsLink" runat="server">
											<asp:Image SkinID="advanced_search" runat="server" />&nbsp;<asp:Label Text='<%# L10n.Term("Users.LBL_FORGOT_PASSWORD") %>' runat="server" />
										</asp:HyperLink>
									</asp:TableCell>
								</asp:TableRow>
							</asp:Table>
							<asp:Panel ID="pnlForgotPassword" Visible=<%# !Security.IsWindowsAuthentication() && !Utils.CachedFileExists(Context, "~/Users/ClientLogin.aspx") %> style="display:none" runat="server">
								<asp:Table Width="100%" BorderWidth="0" CellPadding="0" CellSpacing="2" HorizontalAlign="Center" Runat="server">
									<asp:TableRow ID="trForgotError" Visible="false" runat="server">
										<asp:TableCell ColumnSpan="2">
											<asp:Label ID="lblForgotError" CssClass="error" EnableViewState="false" Runat="server" />
										</asp:TableCell>
									</asp:TableRow>
									<asp:TableRow>
										<asp:TableCell Width="30%" CssClass="dataLabel"><%# L10n.Term("Users.LBL_USER_NAME") %></asp:TableCell>
										<asp:TableCell Width="70%" CssClass="loginField">
											<asp:TextBox ID="txtFORGOT_USER_NAME" placeholder='<%# Sql.ToString(Application["CONFIG.default_theme"]) == "Arctic" ? L10n.Term("Users.LBL_USER_NAME").Replace(":", "") : String.Empty %>' Runat="server" />
										</asp:TableCell>
									</asp:TableRow>
									<asp:TableRow>
										<asp:TableCell Width="30%" CssClass="dataLabel"><%# L10n.Term("Users.LBL_EMAIL") %></asp:TableCell>
										<asp:TableCell Width="70%" CssClass="loginField">
											<asp:TextBox ID="txtFORGOT_EMAIL" placeholder='<%# Sql.ToString(Application["CONFIG.default_theme"]) == "Arctic" ? L10n.Term("Users.LBL_EMAIL").Replace(":", "") : String.Empty %>' Runat="server" />
										</asp:TableCell>
									</asp:TableRow>
								</asp:Table>
								<asp:Table Width="100%" BorderWidth="0" CellPadding="0" CellSpacing="2" HorizontalAlign="Center" runat="server">
									<asp:TableRow>
										<asp:TableCell Width="30%">&nbsp;</asp:TableCell>
										<asp:TableCell Width="70%">
											<asp:Button ID="btnForgotPassword" CommandName="ForgotPassword" OnCommand="Page_Command" CssClass="button" Text='<%# " "  + L10n.Term(".LBL_SUBMIT_BUTTON_LABEL") + " "  %>' ToolTip='<%# L10n.Term(".LBL_SUBMIT_BUTTON_TITLE") %>' Runat="server" />
										</asp:TableCell>
									</asp:TableRow>
								</asp:Table>
							</asp:Panel>
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
			<asp:TableCell CssClass="LoginActionsShadingVertical" />
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell ColumnSpan="3" CssClass="LoginActionsShadingHorizontal" />
		</asp:TableRow>
	</asp:Table>
	<br />
	<br />
<%
if ( tblUser.Visible )
{
	Response.Write(Utils.RegisterEnterKeyPress(txtUSER_NAME.ClientID, btnLogin.ClientID));
	Response.Write(Utils.RegisterEnterKeyPress(txtPASSWORD.ClientID , btnLogin.ClientID));
}
if ( pnlForgotPassword.Visible )
{
	Response.Write(Utils.RegisterEnterKeyPress(txtFORGOT_USER_NAME.ClientID, btnForgotPassword.ClientID));
	Response.Write(Utils.RegisterEnterKeyPress(txtFORGOT_EMAIL.ClientID , btnForgotPassword.ClientID));
}
%>
</div>

