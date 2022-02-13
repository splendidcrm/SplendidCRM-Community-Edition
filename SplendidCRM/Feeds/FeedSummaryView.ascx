<%@ Control CodeBehind="FeedSummaryView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Feeds.FeedSummaryView" %>
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
	<p></p>
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<asp:Table SkinID="tabFrame" runat="server">
		<asp:TableRow>
			<asp:TableCell HorizontalAlign="Right">
				<nobr>
				<asp:ImageButton CommandName="MoveUp"   CommandArgument='<%# gID.ToString() %>' OnCommand="Page_Command" AlternateText='<%# L10n.Term("Feeds.LBL_MOVE_UP"                ) %>' SkinID="uparrow"   Runat="server" />
				<asp:ImageButton CommandName="MoveDown" CommandArgument='<%# gID.ToString() %>' OnCommand="Page_Command" AlternateText='<%# L10n.Term("Feeds.LBL_MOVE_DOWN"              ) %>' SkinID="downarrow" Runat="server" />
				<asp:ImageButton CommandName="Delete"   CommandArgument='<%# gID.ToString() %>' OnCommand="Page_Command" AlternateText='<%# L10n.Term("Feeds.LBL_DELETE_FAV_BUTTON_LABEL") %>' SkinID="delete"    CssClass="listViewTdToolsS1" Runat="server" />
				</nobr>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:Table SkinID="tabFrame" CssClass="listView" runat="server">
		<asp:TableRow Height="20">
			<asp:TableCell Width="100%" CssClass="listViewThS1">
				<asp:HyperLink Text='<%# sChannelTitle %>' NavigateUrl='<%# "view.aspx?id=" + gID.ToString() %>' CssClass="listViewThLinkS1" Runat="server" />
				-
				<asp:HyperLink Text='<%# "(" + L10n.Term("Feeds.LBL_VISIT_WEBSITE") + ")" %>' NavigateUrl='<%# sChannelLink %>' CssClass="listViewThLinkS1" Target="_new" Runat="server" />
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:Label ID="lblLastBuildDate" Runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell BackColor="#f1f1f1" CssClass="evenListRowS1" ColumnSpan="10">
				<asp:Repeater ID="rpFeed" Runat="server">
					<ItemTemplate>
						<li><asp:HyperLink Text='<%# DataBinder.Eval(Container.DataItem, "title") %>' NavigateUrl='<%# DataBinder.Eval(Container.DataItem, "link") %>' CssClass="listViewTdLinkS1" Target="_new" Runat="server" />
						&nbsp;&nbsp;<asp:Label Text='<%# DataBinder.Eval(Container.DataItem, "pubDate") %>' CssClass="rssItemDate" runat="server" />
					</ItemTemplate>
				</asp:Repeater>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
</div>

