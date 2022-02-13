<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.FieldLayout.ListView" %>
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
<div id="divListView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="Administration" Title="Administration.LBL_MANAGE_LAYOUT" EnableModuleLabel="false" EnablePrint="false" HelpName="index" EnableHelp="true" Runat="Server" />
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>

	<SplendidCRM:ListHeader Title="Administration.LBL_MANAGE_LAYOUT" Runat="Server" />
	<asp:Table Width="100%" CssClass="tabDetailView2" runat="server">
		<asp:TableRow>
			<asp:TableCell width="35%" CssClass="tabDetailViewDL2">
				<asp:Image AlternateText='<%# L10n.Term("Administration.LBL_LAYOUT_DETAILVIEW_TITLE") %>' SkinID="Administration" Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_LAYOUT_DETAILVIEW_TITLE") %>' NavigateUrl="~/Administration/DynamicLayout/DetailViews/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2"><%= L10n.Term("Administration.LBL_LAYOUT_DETAILVIEW") %></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell width="35%" CssClass="tabDetailViewDL2" Wrap="false">
				<asp:Image AlternateText='<%# L10n.Term("Administration.LBL_LAYOUT_EDITVIEW_TITLE") %>' SkinID="Administration" Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_LAYOUT_EDITVIEW_TITLE") %>' NavigateUrl="~/Administration/DynamicLayout/EditViews/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2"><%= L10n.Term("Administration.LBL_LAYOUT_EDITVIEW") %></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell  width="35%" CssClass="tabDetailViewDL2">
				<asp:Image AlternateText='<%# L10n.Term("Administration.LBL_LAYOUT_GRIDVIEW_TITLE") %>' SkinID="Administration" Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_LAYOUT_GRIDVIEW_TITLE") %>' NavigateUrl="~/Administration/DynamicLayout/GridViews/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2"><%= L10n.Term("Administration.LBL_LAYOUT_GRIDVIEW") %></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell  width="35%" CssClass="tabDetailViewDL2">
				<asp:Image AlternateText='<%# L10n.Term("Administration.LBL_LAYOUT_RELATIONSHIPS_TITLE") %>' SkinID="Administration" Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_LAYOUT_RELATIONSHIPS_TITLE") %>' NavigateUrl="~/Administration/DynamicLayout/Relationships/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2"><%= L10n.Term("Administration.LBL_LAYOUT_RELATIONSHIPS") %></asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell  width="35%" CssClass="tabDetailViewDL2">
				<asp:Image AlternateText='<%# L10n.Term("Administration.LBL_LAYOUT_EDIT_RELATIONSHIPS_TITLE") %>' SkinID="Administration" Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_LAYOUT_EDIT_RELATIONSHIPS_TITLE") %>' NavigateUrl="~/Administration/DynamicLayout/EditRelationships/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2"><%= L10n.Term("Administration.LBL_LAYOUT_EDIT_RELATIONSHIPS") %></asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

