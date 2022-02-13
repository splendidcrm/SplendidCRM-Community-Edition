<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ImportDefaultsView.ascx.cs" Inherits="SplendidCRM.Users.ImportDefaultsView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divDefaultsView">
	<p></p>
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblTeam" class="tabEditView" runat="server">
				</table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabEditView" runat="server">
					<asp:TableRow>
						<asp:TableHeaderCell ColumnSpan="3"><h4><asp:Label Text='<%# L10n.Term("Users.LBL_USER_SETTINGS") %>' runat="server" /></h4></asp:TableHeaderCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Users.LBL_THEME") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="THEME" DataValueField="NAME" DataTextField="NAME" TabIndex="3" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><%= L10n.Term("Users.LBL_THEME_TEXT") %></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Users.LBL_LANGUAGE") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="LANGUAGE" DataValueField="NAME" DataTextField="NATIVE_NAME" OnSelectedIndexChanged="lstLANGUAGE_Changed" AutoPostBack="true" TabIndex="3" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><%= L10n.Term("Users.LBL_LANGUAGE_TEXT") %></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Users.LBL_DATE_FORMAT") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="DATE_FORMAT" TabIndex="3" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><%= L10n.Term("Users.LBL_DATE_FORMAT_TEXT") %></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Users.LBL_TIME_FORMAT") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="TIME_FORMAT" TabIndex="3" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><%= L10n.Term("Users.LBL_TIME_FORMAT_TEXT") %></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Users.LBL_TIMEZONE") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="TIMEZONE_ID" DataValueField="ID" DataTextField="NAME" TabIndex="3" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><%= L10n.Term("Users.LBL_TIMEZONE_TEXT") %></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Users.LBL_CURRENCY") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="CURRENCY_ID" DataValueField="ID" DataTextField="NAME_SYMBOL" TabIndex="3" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><%= L10n.Term("Users.LBL_CURRENCY_TEXT") %></asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblMain" class="tabEditView" runat="server">
					<tr>
						<th colspan="4"><h4><asp:Label Text='<%# L10n.Term("Users.LBL_USER_SETTINGS") %>' runat="server" /></h4></th>
					</tr>
				</table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblAddress" class="tabEditView" runat="server">
					<tr>
						<th colspan="4"><h4><asp:Label Text='<%# L10n.Term("Users.LBL_ADDRESS_INFORMATION") %>' runat="server" /></h4></th>
					</tr>
				</table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
</div>
