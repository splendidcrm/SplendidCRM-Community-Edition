<%@ Page language="c#" MasterPageFile="~/DefaultView.Master" Codebehind="RemoveMe.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.RemoveMe" %>
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
<asp:Content ID="cntLastViewed" ContentPlaceHolderID="cntLastViewed" runat="server" />
<asp:Content ID="cntSidebar" ContentPlaceHolderID="cntSidebar" runat="server" />

<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
	<div style="padding-top: 50px;"></div>
	<asp:Literal ID="litREMOVE_ME_HEADER" runat="server" />
	
	<asp:RadioButtonList ID="radREASON" Visible="false" DataValueField="NAME" DataTextField="DISPLAY_NAME" CssClass="radio" runat="server" />
	<asp:Button ID="btnSubmit" Visible="false" UseSubmitBehavior="false" CommandName="Submit" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SUBMIT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_SUBMIT_BUTTON_TITLE") %>' Runat="server" />
	&nbsp;<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	&nbsp;<asp:Label ID="lblWarning" CssClass="error" EnableViewState="false" Runat="server" />
	
	<asp:Literal ID="litREMOVE_ME_FOOTER" runat="server" />
</asp:Content>

