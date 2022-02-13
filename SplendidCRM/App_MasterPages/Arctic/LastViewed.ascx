<%@ Control Language="c#" AutoEventWireup="false" Codebehind="LastViewed.ascx.cs" Inherits="SplendidCRM.SplendidControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
<div id="divLastViewed" width="100%" class="lastView">
	<h1><asp:Label Text='<%# L10n.Term(".LBL_LAST_VIEWED") %>' Visible='<%# SplendidCache.LastViewed(Sql.ToString(Page.Items["ActiveTabMenu"])).Rows.Count > 0 %>'  runat="server" /></h1>
	<asp:Repeater id="ctlRepeater" DataSource='<%# SplendidCache.LastViewed(Sql.ToString(Page.Items["ActiveTabMenu"])) %>' runat="server">
		<HeaderTemplate />
		<ItemTemplate>
			<div class="lastViewRecentViewed" onclick="window.location.href='<%# Sql.ToString(Eval("RELATIVE_PATH")).Replace("~/", Sql.ToString(Application["rootURL"])) + "view.aspx?ID=" + Eval("ITEM_ID") %>'" style="cursor: pointer;">
				<asp:HyperLink NavigateUrl='<%# Eval("RELATIVE_PATH") + "view.aspx?ID=" + Eval("ITEM_ID") %>' ToolTip='<%# Eval("ITEM_SUMMARY") %>' CssClass="lastViewLink" Runat="server">
					<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("ITEM_SUMMARY"))) %>
				</asp:HyperLink>
			</div>
		</ItemTemplate>
		<FooterTemplate />
	</asp:Repeater>
</div>

