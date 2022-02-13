<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SearchBasic.ascx.cs" Inherits="SplendidCRM.Administration.Undelete.SearchBasic" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="SplendidCRM" Tagname="DatePicker" Src="~/_controls/DatePicker.ascx" %>
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
<div id="divSearch">
	<asp:Table SkinID="tabSearchForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table Width="100%" CellPadding="0" CellSpacing="0" runat="server">
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="Top" Wrap="false"><%= L10n.Term("Undelete.LBL_NAME"  ) %></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="Top" Wrap="false"><asp:TextBox ID="txtNAME" CssClass="dataField" size="30" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="Top"><%= L10n.Term("Undelete.LBL_MODULE_NAME") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="Top"><asp:DropDownList ID="lstMODULE_NAME" DataValueField="MODULE_NAME" DataTextField="MODULE_NAME" AutoPostBack="true" OnSelectedIndexChanged="lstMODULE_NAME_Changed" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="Top" Wrap="false"><%= L10n.Term("Undelete.LBL_AUDIT_DATE") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="Top" Wrap="false" RowSpan="2">
							<asp:Table runat="server">
								<asp:TableRow>
									<asp:TableCell><%= L10n.Term("SavedSearch.LBL_SEARCH_AFTER" ) %></asp:TableCell>
									<asp:TableCell><SplendidCRM:DatePicker ID="ctlSTART_DATE" Runat="Server" /></asp:TableCell>
								</asp:TableRow>
								<asp:TableRow>
									<asp:TableCell><%= L10n.Term("SavedSearch.LBL_SEARCH_BEFORE") %></asp:TableCell>
									<asp:TableCell><SplendidCRM:DatePicker ID="ctlEND_DATE"   Runat="Server" /></asp:TableCell>
								</asp:TableRow>
							</asp:Table>
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="Top" Wrap="false"><%= L10n.Term("Undelete.LBL_AUDIT_TOKEN") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="Top" Wrap="false"><asp:TextBox ID="txtAUDIT_TOKEN" CssClass="dataField" size="30" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="Top"><%= L10n.Term("Undelete.LBL_MODIFIED_BY") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="Top"><asp:DropDownList ID="lstUSERS" DataValueField="ID" DataTextField="USER_NAME" AutoPostBack="true" OnSelectedIndexChanged="lstUSERS_Changed" Runat="server" /></asp:TableCell>
					</asp:TableRow>
				</asp:Table>
				<asp:Panel ID="pnlSearchButtons" CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
					<asp:Table ID="tblSearchButtons" Width="100%" CellPadding="0" CellSpacing="1" style="padding-top: 4px;" runat="server">
						<asp:TableRow>
							<asp:TableCell>
								<asp:Button ID="btnSearch"   CommandName="Search"   OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_SEARCH_BUTTON_LABEL"          ) %>' ToolTip='<%# L10n.Term(".LBL_SEARCH_BUTTON_TITLE"             ) %>' Runat="server" />&nbsp;
								<asp:Button ID="btnClear"    CommandName="Clear"    OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_CLEAR_BUTTON_LABEL"           ) %>' ToolTip='<%# L10n.Term(".LBL_CLEAR_BUTTON_TITLE"              ) %>' Runat="server" />&nbsp;
								<asp:Button ID="btnUndelete" CommandName="Undelete" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term("Undelete.LBL_UNDELETE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term("Undelete.LBL_UNDELETE_BUTTON_UNDELETE") %>' Runat="server" />&nbsp;
								<asp:CheckBox ID="chkBackground" Text='<%# L10n.Term("Undelete.LBL_BACKGROUND_OPERATION") %>' CssClass="checkbox" runat="server" />
							</asp:TableCell>
						</asp:TableRow>
					</asp:Table>
				</asp:Panel>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<%= Utils.RegisterEnterKeyPress(txtNAME.ClientID , btnSearch.ClientID) %>
	<%= Utils.RegisterEnterKeyPress(txtAUDIT_TOKEN.ClientID , btnSearch.ClientID) %>
</div>
