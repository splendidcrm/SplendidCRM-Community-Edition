<%@ Control Language="c#" AutoEventWireup="false" Codebehind="NewRecord.ascx.cs" Inherits="SplendidCRM.Administration.Terminology.NewRecord" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divNewRecord">
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderLeft" Src="~/_controls/HeaderLeft.ascx" %>
	<SplendidCRM:HeaderLeft ID="ctlHeaderLeft" Title="Terminology.LBL_NEW_FORM_TITLE" Runat="Server" />

	<asp:Panel Width="100%" CssClass="leftColumnModuleS3" runat="server">
		<asp:Label        ID="lblNAME"         Text='<%# L10n.Term("Terminology.LBL_NAME"           ) %>' runat="server" />&nbsp;<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /><br />
		<asp:TextBox      ID="txtNAME"         Runat="server" /><br />
		<asp:Label        ID="lblLANGUAGE"     Text='<%# L10n.Term("Terminology.LBL_LANG"           ) %>' runat="server" />&nbsp;<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /><br />
		<asp:DropDownList ID="lstLANGUAGE"     DataValueField="NAME" DataTextField="DISPLAY_NAME" Runat="server" /><br />
		<asp:Label        ID="lblMODULE_NAME"  Text='<%# L10n.Term("Terminology.LBL_MODULE_NAME"    ) %>' runat="server" /><br />
		<asp:DropDownList ID="lstMODULE_NAME"  DataValueField="MODULE_NAME" DataTextField="MODULE_NAME" Runat="server" /><br />
		<asp:Label        ID="lblLIST_NAME"    Text='<%# L10n.Term("Terminology.LBL_LIST_NAME_LABEL") %>' runat="server" /><br />
		<asp:DropDownList ID="lstLIST_NAME"    DataValueField="LIST_NAME" DataTextField="LIST_NAME" Runat="server" /><br />
		<asp:Label        ID="lblLIST_ORDER"   Text='<%# L10n.Term("Terminology.LBL_LIST_ORDER"     ) %>' runat="server" /><br />
		<asp:TextBox      ID="txtLIST_ORDER"   Runat="server" /><br />
		<asp:Label        ID="lblDISPLAY_NAME" Text='<%# L10n.Term("Terminology.LBL_DISPLAY_NAME"   ) %>' runat="server" /><br />
		<asp:TextBox      ID="txtDISPLAY_NAME" Runat="server" /><br />
		
		<asp:Button ID="btnSave" CommandName="NewRecord" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SAVE_BUTTON_LABEL"  ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_SAVE_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SAVE_BUTTON_KEY") %>' Runat="server" /><br />
		<asp:RequiredFieldValidator ID="reqNAME"         ControlToValidate="txtNAME" ErrorMessage="(required)" CssClass="required" Enabled="false" EnableClientScript="false" EnableViewState="false" Runat="server" />
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	<%= Utils.RegisterEnterKeyPress(txtNAME.ClientID, btnSave.ClientID) %>
</div>
<script type="text/javascript">
<%
// 01/12/2006 Paul.  NewRecord is having a problem setting the value in the code-behind. 
if ( !IsPostBack )
	Response.Write("SelectOption('" + lstLANGUAGE.ClientID + "','" + L10N.NormalizeCulture(L10n.NAME) + "');");
%>
</script>

