<%@ Page language="c#" MasterPageFile="~/PopupView.Master" Codebehind="Popup.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Audit.Popup" %>
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
<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
	<p></p>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="moduleTitle">
		<tr>
			<td valign="top"><SplendidCRM:DynamicImage ImageSkinID="<%# sModule %>" AlternateText='<%# L10n.Term(".moduleList." + sModule) %>' style="margin-top: 3px" Runat="server" />&nbsp;</td>
			<td width="100%"><h2><asp:Label ID="lblTitle" Runat="server" /></h2></td>
			<td valign="top" align="right" style="padding-top:3px; padding-left: 5px;" nowrap>
				<asp:ImageButton OnClientClick="print(); return false;" CssClass="utilsLink" AlternateText='<%# L10n.Term(".LNK_PRINT") %>' SkinID="print" Runat="server" />
				<asp:LinkButton  OnClientClick="print(); return false;" CssClass="utilsLink" Text='<%# L10n.Term(".LNK_PRINT") %>' Runat="server" />
			</td>
		</tr>
	</table>
	<p></p>

	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdPopupView" EnableViewState="true" runat="server">
		<Columns>
			<asp:BoundColumn HeaderText="Audit.LBL_FIELD_NAME" DataField="FIELD_NAME"   ItemStyle-Width="5%"  />
			<asp:BoundColumn HeaderText="Audit.LBL_OLD_NAME"   DataField="BEFORE_VALUE" ItemStyle-Width="40%" />
			<asp:BoundColumn HeaderText="Audit.LBL_NEW_VALUE"  DataField="AFTER_VALUE"  ItemStyle-Width="40%" />
			<asp:BoundColumn HeaderText="Audit.LBL_CHANGED_BY" DataField="CREATED_BY"   ItemStyle-Width="5%"  />
			<asp:BoundColumn HeaderText="Audit.LBL_LIST_DATE"  DataField="DATE_CREATED" ItemStyle-Width="10%" ItemStyle-Wrap="false" />
		</Columns>
	</SplendidCRM:SplendidGrid>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</asp:Content>

