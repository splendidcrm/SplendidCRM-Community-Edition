<%@ Control Language="c#" AutoEventWireup="false" Codebehind="LastViewed.ascx.cs" Inherits="SplendidCRM._controls.LastViewed" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
	<b><asp:Label Text='<%# L10n.Term(".LBL_LAST_VIEWED") %>' runat="server" />:&nbsp;&nbsp;</b>
	<asp:Repeater id="ctlRepeater" runat="server">
		<HeaderTemplate />
		<ItemTemplate>
			<nobr>
				<asp:HyperLink NavigateUrl='<%# DataBinder.Eval(Container.DataItem, "RELATIVE_PATH") + "view.aspx?ID=" + DataBinder.Eval(Container.DataItem, "ITEM_ID") %>' 
					AccessKey='<%# DataBinder.Eval(Container.DataItem, "ROW_NUMBER") %>' CssClass="lastViewLink" Runat="server">
					<SplendidCRM:DynamicImage ImageSkinID='<%# DataBinder.Eval(Container.DataItem, "IMAGE_NAME") %>' AlternateText='<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("ITEM_SUMMARY"))) %>' runat="server" />
					</asp:HyperLink>&nbsp;
				<asp:HyperLink NavigateUrl='<%# DataBinder.Eval(Container.DataItem, "RELATIVE_PATH") + "view.aspx?ID=" + DataBinder.Eval(Container.DataItem, "ITEM_ID") %>' 
					Text='<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("ITEM_SUMMARY"))) %>' 
					ToolTip='<%# "[" + L10n.Term(".LBL_ALT_HOT_KEY") + DataBinder.Eval(Container.DataItem, "ROW_NUMBER") + "]" %>' 
					AccessKey='<%# DataBinder.Eval(Container.DataItem, "ROW_NUMBER") %>' CssClass="lastViewLink" Runat="server" />&nbsp;
			</nobr>
		</ItemTemplate>
		<FooterTemplate />
	</asp:Repeater>
	<div style="DISPLAY: <%= vwLastViewed != null && vwLastViewed.Count > 0 ? "NONE" : "INLINE" %>">
		<asp:Label Text='<%# L10n.Term(".NTC_NO_ITEMS_DISPLAY") %>' runat="server" />
	</div>
</div>

