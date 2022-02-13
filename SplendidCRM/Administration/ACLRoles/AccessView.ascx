<%@ Control CodeBehind="AccessView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.ACLRoles.AccessView" %>
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
<script type="text/javascript">
function toggleDisplay(sID)
{
	var fld = document.getElementById(sID);
	fld.style.display = (fld.style.display == 'none') ? 'inline' : 'none';
	var fldLink = document.getElementById(sID + 'link');
	if ( fldLink != null )
	{
		// 02/28/2008 Paul.  The linked field is the opposite of the main. 
		fldLink.style.display = (fld.style.display == 'none') ? 'inline' : 'none';
	}
}
</script>
<div id="divListView">
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<SplendidCRM:ACLGrid id="grdACL" Width="100%" CssClass="tabDetailView"
		CellPadding="0" CellSpacing="1" border="0"
		AllowPaging="false" AllowSorting="false" 
		AutoGenerateColumns="false" EnableACLEditing="false"
		EnableViewState="true" runat="server">
		<ItemStyle            CssClass="tabDetailViewDF" />
		<AlternatingItemStyle CssClass="tabDetailViewDF" />
		<HeaderStyle          CssClass="tabDetailViewDL" />
	</SplendidCRM:ACLGrid>
	
	<asp:Panel ID="pnlAdmin" runat="server">
		<br />
		<SplendidCRM:ACLGrid id="grdACL_Admin" Width="100%" CssClass="tabDetailView"
			CellPadding="0" CellSpacing="1" border="0"
			AllowPaging="false" AllowSorting="false" 
			AutoGenerateColumns="false" EnableACLEditing="false"
			EnableViewState="true" runat="server">
			<ItemStyle            CssClass="tabDetailViewDF" />
			<AlternatingItemStyle CssClass="tabDetailViewDF" />
			<HeaderStyle          CssClass="tabDetailViewDL" />
		</SplendidCRM:ACLGrid>
	</asp:Panel>
</div>

