<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SearchBasic.ascx.cs" Inherits="SplendidCRM.Administration.DynamicLayout._controls.SearchBasic" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<asp:Table SkinID="tabSearchForm" Visible="false" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabSearchView" runat="server">
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel" Wrap="false"><%= L10n.Term("DynamicLayout.LBL_LAYOUT_VIEW") %>&nbsp;&nbsp;<asp:DropDownList ID="lstLAYOUT_VIEWS" DataValueField="NAME" DataTextField="DISPLAY_NAME" AutoPostBack="True" Runat="server" /></asp:TableCell>
						<asp:TableCell HorizontalAlign="Right">
							<asp:Button ID="btnSearch" CommandName="Search" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_SEARCH_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SEARCH_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SEARCH_BUTTON_KEY") %>' Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader ID="ctlListHeader" Title="DynamicLayout.LBL_LAYOUT_VIEW" Runat="Server" />
	<div id="divDynamicLayoutSearchBasic" style="height: 600px; overflow-y: auto;">
	<asp:XmlDataSource ID="xdsViews" EnableCaching="true" runat="server" />
	<asp:TreeView ID="treeMain" ExpandDepth="1" ImageSet="XPFileExplorer" PopulateNodesFromClient="true" EnableClientScript="true" runat="server">
		<LeafNodeStyle     CssClass="leafStudioFolderLink"     />
		<ParentNodeStyle   CssClass="parentStudioFolderLink"   />
		<SelectedNodeStyle CssClass="selectedStudioFolderLink" />
		<NodeStyle         CssClass="nodeStudioFolderLink"     />
		<DataBindings>
			<asp:TreeNodeBinding DataMember="Modules" TextField="Name" Depth="0" SelectAction="None" />
			<asp:TreeNodeBinding DataMember="Module"  TextField="Name" Depth="1" SelectAction="SelectExpand" />
			<asp:TreeNodeBinding DataMember="View"    TextField="DisplayName" ValueField="Name"  />
		</DataBindings>
	</asp:TreeView>
	</div>
	<asp:Image SkinID="blank" Width="200" Height="1" runat="server" />
</div>
