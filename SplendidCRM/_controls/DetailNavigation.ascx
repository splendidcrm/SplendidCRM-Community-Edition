<%@ Control Language="c#" AutoEventWireup="false" Codebehind="DetailNavigation.ascx.cs" Inherits="SplendidCRM._controls.DetailNavigation" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
// 07/28/2010 Paul.  The View Change Log link has been moved to a dynamic button. 
</script>
<div id="divPopupAudit">
	<script type="text/javascript">
	function PopupAudit()
	{
		window.open('<%= Application["rootURL"] %>Audit/Popup.aspx?ID=<%= gID %>&Module=<%= sModule %>', 'Audit', '<%= SplendidCRM.Crm.Config.PopupWindowOptions() %>,status=0,toolbar=0,location=0');
		return false;
	}
	function PopupPersonalInfo()
	{
		window.open('<%= Application["rootURL"] %>Audit/PopupPersonalInfo.aspx?ID=<%= gID %>&Module=<%= sModule %>', 'PersonalInfo', '<%= SplendidCRM.Crm.Config.PopupWindowOptions() %>,status=0,toolbar=0,location=0');
		return false;
	}
	</script>
	<asp:Table Width="100%" CellPadding="0" CellSpacing="0" CssClass="" Visible="false" runat="server">
		<asp:TableRow>
			<asp:TableCell CssClass="listViewPaginationTdS1">
				<asp:LinkButton ID="lnkViewChangeLog" OnClientClick="PopupAudit(); return false;" Text='<%# L10n.Term(".LNK_VIEW_CHANGE_LOG") %>' CssClass="listViewPaginationLinkS1" runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="listViewPaginationTdS1" HorizontalAlign="Right">
				<asp:HyperLink ID="lnkReturnToList" Text='<%# L10n.Term(".LNK_LIST_RETURN") %>' CssClass="listViewPaginationLinkS1" runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

