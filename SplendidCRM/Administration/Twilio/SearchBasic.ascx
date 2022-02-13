<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SearchBasic.ascx.cs" Inherits="SplendidCRM.Administration.Twilio.SearchBasic" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
<SplendidCRM:ListHeader Title="Twilio.LBL_SEARCH_FORM_TITLE" Runat="Server" />
<div id="divSearch">
	<asp:Table SkinID="tabSearchForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table Width="100%" CellPadding="0" CellSpacing="0" runat="server">
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel" Wrap="false"><%= L10n.Term("Twilio.LBL_DATE_SENT"  ) %></asp:TableCell>
						<asp:TableCell CssClass="dataField" Wrap="false"><SplendidCRM:DatePicker ID="ctlDATE_SENT" Runat="Server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel" Wrap="false"><%= L10n.Term("Twilio.LBL_FROM_NUMBER") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" Wrap="false"><asp:TextBox ID="txtFROM_NUMBER" runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel" Wrap="false"><%= L10n.Term("Twilio.LBL_TO_NUMBER"  ) %></asp:TableCell>
						<asp:TableCell CssClass="dataField" Wrap="false"><asp:TextBox ID="txtTO_NUMBER" runat="server" /></asp:TableCell>
					</asp:TableRow>
				</asp:Table>
				<%@ Register TagPrefix="SplendidCRM" Tagname="SearchButtons" Src="~/_controls/SearchButtons.ascx" %>
				<SplendidCRM:SearchButtons ID="ctlSearchButtons" Module="Payments" Visible="<%# !PrintView %>" Runat="Server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>
