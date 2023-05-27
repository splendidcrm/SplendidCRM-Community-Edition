<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SubPanelButtons.ascx.cs" Inherits="SplendidCRM.Themes.Sugar.SubPanelButtons" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
/* 10/15/2022 Paul.  Put buttons on header bar and move +/- to the left to match React theme. */
</script>
	<asp:Table ID="tblSubPanelFrame" SkinID="tabFrame" CssClass=<%# (CookieValue(SubPanel) == "1" ? "h3Row h3RowDisabled" : "h3Row") %> runat="server">
		<asp:TableRow>
			<asp:TableCell Width="30px">
				<span Visible="<%# !Sql.IsEmptyString(SubPanel) %>" runat="server">
					<asp:HyperLink ID="lnkShowSubPanel" NavigateUrl=<%# "javascript:ShowSubPanel(\'" + lnkShowSubPanel.ClientID + "\',\'" + lnkHideSubPanel.ClientID + "\',\'" + SubPanel + "\',\'" + tblSubPanelFrame.ClientID + "\');" %> style=<%# "display:" + (CookieValue(SubPanel) == "1" ? "inline" : "none") %> runat="server"><asp:Image SkinID="subpanel_expand"   runat="server" /></asp:HyperLink>
					<asp:HyperLink ID="lnkHideSubPanel" NavigateUrl=<%# "javascript:HideSubPanel(\'" + lnkShowSubPanel.ClientID + "\',\'" + lnkHideSubPanel.ClientID + "\',\'" + SubPanel + "\',\'" + tblSubPanelFrame.ClientID + "\');" %> style=<%# "display:" + (CookieValue(SubPanel) != "1" ? "inline" : "none") %> runat="server"><asp:Image SkinID="subpanel_collapse" runat="server" /></asp:HyperLink>
				</span>
			</asp:TableCell>
			<asp:TableCell Wrap="false">
				<h3>
					<asp:Image SkinID="h3Arrow" Visible="<%# Sql.IsEmptyString(SubPanel) %>" Runat="server" />
					&nbsp;<asp:Label Text='<%# L10n.Term(Title) %>' runat="server" />
				</h3>
			</asp:TableCell>
			<asp:TableCell ID="tdButtons" Width="10%" Wrap="false">
				<div id="<%# SubPanel %>Buttons" style='<%= "display:" + (CookieValue(SubPanel) != "1" ? "inline" : "none") %>'>
					<asp:PlaceHolder ID="pnlDynamicButtons" runat="server" />
				</div>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>


<script type="text/javascript">
function ConfirmDelete()
{
	return confirm('<%= L10n.TermJavaScript(".NTC_DELETE_CONFIRMATION") %>');
}
</script>
<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
