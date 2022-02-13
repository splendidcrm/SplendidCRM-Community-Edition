<%@ Control Language="c#" AutoEventWireup="false" Codebehind="MyActivitiesHeader.ascx.cs" Inherits="SplendidCRM.Activities.MyActivitiesHeader" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
<asp:Table Width="100%" BorderWidth="0" CellPadding="0" CellSpacing="0" CssClass="h3Row" runat="server">
	<asp:TableRow>
		<asp:TableCell Wrap="false">
			<h3><asp:Image SkinID="h3Arrow" Runat="server" />&nbsp;<asp:Label Text='<%# L10n.Term(sTitle) %>' runat="server" /></h3>
		</asp:TableCell>
		<asp:TableCell Wrap="false">
			&nbsp;&nbsp;
			<%= L10n.Term("Activities.LBL_TODAY") %><asp:DropDownList ID="lstTHROUGH" DataValueField="NAME" DataTextField="DISPLAY_NAME" SelectedIndexChanged="Page_Command" AutoPostBack="true" Runat="server" />
			&nbsp;
			<asp:Label ID="txtTHROUGH" Runat="server" />
		</asp:TableCell>
		<asp:TableCell HorizontalAlign="Right" Wrap="false">
			<asp:Table  BorderWidth="0" CellPadding="0" CellSpacing="0" runat="server">
				<asp:TableRow>
					<asp:TableCell Wrap="false">
						<asp:ImageButton ID="imgRefresh" CommandName="Refresh" OnCommand="Page_Command" CssClass="chartToolsLink" AlternateText='<%# L10n.Term("Dashboard.LBL_REFRESH") %>' SkinID="refresh" ImageAlign="AbsMiddle" Runat="server" />
						<asp:LinkButton  ID="bntRefresh" CommandName="Refresh" OnCommand="Page_Command" CssClass="chartToolsLink"          Text='<%# L10n.Term("Dashboard.LBL_REFRESH") %>' Visible="false" Runat="server" />
					</asp:TableCell>
					<asp:TableCell Wrap="false" Visible="<%# ShowEdit %>">
						&nbsp;
						<span onclick="toggleDisplay('<%= DivEditName %>'); return false;">
							<asp:ImageButton ID="imgEdit" CommandName="Edit" OnCommand="Page_Command" CssClass="chartToolsLink" AlternateText='<%# L10n.Term("Dashboard.LBL_EDIT"  ) %>' SkinID="edit"    ImageAlign="AbsMiddle" Runat="server" />
							<asp:LinkButton  ID="bntEdit" CommandName="Edit" OnCommand="Page_Command" CssClass="chartToolsLink"          Text='<%# L10n.Term("Dashboard.LBL_EDIT"  ) %>' Visible="false" Runat="server" />
						</span>
					</asp:TableCell>
					<asp:TableCell Wrap="false">
						&nbsp;
						<span onclick="return confirm('<%= L10n.TermJavaScript("Home.LBL_REMOVE_DASHLET_CONFIRM") %>')">
							<asp:ImageButton ID="imgRemove" CommandName="Remove" OnCommand="Page_Command" CssClass="chartToolsLink" AlternateText='<%# L10n.Term(".LBL_REMOVE") %>' SkinID="delete" ImageAlign="AbsMiddle" Runat="server" />
							<asp:LinkButton  ID="bntRemove" CommandName="Remove" OnCommand="Page_Command" CssClass="chartToolsLink"          Text='<%# L10n.Term(".LBL_REMOVE") %>' Visible="false" Runat="server" />
						</span>
					</asp:TableCell>
				</asp:TableRow>
			</asp:Table>
		</asp:TableCell>
	</asp:TableRow>
</asp:Table>

