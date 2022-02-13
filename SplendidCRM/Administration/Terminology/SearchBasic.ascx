<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SearchBasic.ascx.cs" Inherits="SplendidCRM.Administration.Terminology.SearchBasic" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
<SplendidCRM:ListHeader Title="Terminology.LBL_SEARCH_FORM_TITLE" Runat="Server" />
<div id="divSearch">
	<asp:Table SkinID="tabSearchForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabSearchView" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel"><%= L10n.Term("Terminology.LBL_NAME"        ) %></asp:TableCell>
						<asp:TableCell Width="25%" CssClass="dataField"><asp:TextBox ID="txtNAME"         TabIndex="1" Size="25" MaxLength="50" Runat="server" /></asp:TableCell>
						<asp:TableCell Width="20%" CssClass="dataLabel"><%= L10n.Term("Terminology.LBL_LANG"       ) %></asp:TableCell>
						<asp:TableCell Width="25%" CssClass="dataField"><asp:DropDownList ID="lstLANGUAGE" TabIndex="2" DataValueField="NAME" DataTextField="DISPLAY_NAME" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Terminology.LBL_MODULE_NAME") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="lstMODULE_NAME" TabIndex="4" DataValueField="MODULE_NAME" DataTextField="MODULE_NAME" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel"><asp:CheckBox ID="chkGLOBAL_TERMS" TabIndex="5" OnCheckedChanged="chkGLOBAL_TERMS_CheckedChanged" AutoPostBack="True" CssClass="checkbox" Runat="server" />&nbsp;<%= L10n.Term("Terminology.LBL_GLOBAL_TERMS") %></asp:TableCell>
						<asp:TableCell CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Terminology.LBL_LIST_NAME_LABEL") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:DropDownList ID="lstLIST_NAME" TabIndex="6" DataValueField="LIST_NAME" DataTextField="LIST_NAME" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel"><asp:CheckBox ID="chkINCLUDE_LISTS" TabIndex="7" OnCheckedChanged="chkINCLUDE_LISTS_CheckedChanged" AutoPostBack="True" CssClass="checkbox" Runat="server" />&nbsp;<%= L10n.Term("Terminology.LBL_INCLUDE_LISTS") %></asp:TableCell>
						<asp:TableCell CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Terminology.LBL_DISPLAY_NAME") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" ColumnSpan="3"><asp:TextBox ID="txtDISPLAY_NAME" TabIndex="3" TextMode="MultiLine" Columns="90" Rows="2" Runat="server" /></asp:TableCell>
					</asp:TableRow>
				</asp:Table>
				<%@ Register TagPrefix="SplendidCRM" Tagname="SearchButtons" Src="~/_controls/SearchButtons.ascx" %>
				<SplendidCRM:SearchButtons ID="ctlSearchButtons" Visible="<%# !PrintView %>" Runat="Server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<%= Utils.RegisterEnterKeyPress(txtNAME.ClientID        , ctlSearchButtons.SearchClientID) %>
	<%= Utils.RegisterEnterKeyPress(txtDISPLAY_NAME.ClientID, ctlSearchButtons.SearchClientID) %>
</div>

