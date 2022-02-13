<%@ Control CodeBehind="TopicsView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Help.TopicsView" %>
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
<div id="divDetailView" runat="server">
	<asp:XmlDataSource ID="xdsViews" EnableCaching="false" runat="server" />
	<asp:TreeView ID="treeMain" ExpandDepth="1" ImageSet="XPFileExplorer" PopulateNodesFromClient="true" EnableClientScript="true" runat="server">
		<LeafNodeStyle     CssClass="leafStudioFolderLink"     />
		<ParentNodeStyle   CssClass="parentStudioFolderLink"   />
		<SelectedNodeStyle CssClass="selectedStudioFolderLink" />
		<NodeStyle         CssClass="nodeStudioFolderLink"     />
		<DataBindings>
			<asp:TreeNodeBinding DataMember="Modules" TextField="Name" Depth="0" SelectAction="None" />
			<asp:TreeNodeBinding DataMember="Module"  TextField="Name" Depth="1" SelectAction="SelectExpand" />
			<asp:TreeNodeBinding DataMember="View"    TextField="DisplayName" ValueField="Name" NavigateUrlField="URL"  />
		</DataBindings>
	</asp:TreeView>
	</div>
</div>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

