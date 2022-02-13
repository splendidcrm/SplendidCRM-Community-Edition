<%@ Page language="c#" MasterPageFile="~/PopupView.Master" Codebehind="Preview.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Administration.EmailMan.Preview" %>
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
	<script type="text/javascript">
	function UpdateParent()
	{
		if ( window.opener != null )
		{
			window.opener.Refresh();
			window.close();
		}
		else
		{
			window.close();
		}
	}
	</script>

	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true"  Module="EmailMan" EnableModuleLabel="false" EnablePrint="true" EnableHelp="false" Runat="Server" />

	<asp:Table Width="100%" BorderWidth="0" CellSpacing="0" CellPadding="0" CssClass="tabDetailView" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="15%" CssClass="tabDetailViewDL" VerticalAlign="top"><asp:Label Text='<%# L10n.Term("Emails.LBL_DATE_SENT") %>' runat="server" /></asp:TableCell>
			<asp:TableCell Width="85%" CssClass="tabDetailViewDF" VerticalAlign="top"><asp:Label ID="txtSEND_DATE_TIME" runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL" VerticalAlign="top"><asp:Label Text='<%# L10n.Term("Emails.LBL_FROM") %>' runat="server" /></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF" VerticalAlign="top"><asp:Label ID="txtFROM" runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL" VerticalAlign="top"><asp:Label Text='<%# L10n.Term("Emails.LBL_TO") %>' runat="server" /></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF" VerticalAlign="top"><asp:Label ID="txtTO" runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL" VerticalAlign="top"><asp:Label Text='<%# L10n.Term("Emails.LBL_SUBJECT") %>' runat="server" /></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF" VerticalAlign="top"><asp:Label ID="txtSUBJECT" runat="server" /></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL">&nbsp;</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF">&nbsp;</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL" VerticalAlign="top"><asp:Label Text='<%# L10n.Term("Emails.LBL_BODY") %>' runat="server" /></asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF" VerticalAlign="top"><asp:Label ID="txtBODY_HTML" runat="server" /></asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</asp:Content>

