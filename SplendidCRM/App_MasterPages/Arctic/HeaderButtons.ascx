<%@ Control Language="c#" AutoEventWireup="false" Codebehind="HeaderButtons.ascx.cs" Inherits="SplendidCRM.Themes.Sugar.HeaderButtons" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
	<div id="divModuleHeader<%= sModule %>">
		<SplendidCRM:InlineScript runat="server">
		<script type="text/javascript">
		function PopupHelp()
		{
			var url = document.getElementById('<%= lnkHelpText.ClientID %>').href;
			// 01/29/2011 Paul.  Allow the popup options to be customized. 
			var sOptions = '<%= Application["CONFIG.help_popup_options"] %>';
			if ( sOptions == '' )
				sOptions = 'width=600,height=600,status=0,resizable=1,scrollbars=1,toolbar=0,location=1';
			window.open(url,'helpwin',sOptions);
		}
		</script>
		</SplendidCRM:InlineScript>
		<p></p>
		<asp:Table SkinID="tabFrame" CssClass="moduleTitle" runat="server">
			<asp:TableRow>
				<asp:TableCell Width="99%">
					<h2><asp:HyperLink ID="lnkModule" Visible="false" runat="server" /><asp:Label ID="lblPointer" Text="&raquo;" CssClass="pointer" Visible="false" runat="server" /><asp:Label ID="lblTitle" Runat="server" />&nbsp;
					<%-- 10/10/2017 Paul.  Add Archive access right.  --%>
					<asp:HyperLink onclick=<%# "return SplendidCRM_ChangeFavorites(this, \'" + sModule + "\', \'" + Request["ID"] + "\')" %> Visible="<%# !this.IsMobile && bEnableFavorites && !this.ArchiveView() && !this.DisableFavorites() %>" Runat="server">
						<asp:Image ID="imgFavoritesAdd"    name='<%# "favAdd_" + Request["ID"] %>' SkinID="favorites_add"    style='<%# "display:" + ( Sql.IsEmptyGuid(gFAVORITE_RECORD_ID) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_ADD_TO_FAVORITES"     ) %>' Runat="server" />
						<asp:Image ID="imgFavoritesRemove" name='<%# "favRem_" + Request["ID"] %>' SkinID="favorites_remove" style='<%# "display:" + (!Sql.IsEmptyGuid(gFAVORITE_RECORD_ID) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_REMOVE_FROM_FAVORITES") %>' Runat="server" />
					</asp:HyperLink>
					<asp:HyperLink onclick=<%# "return SplendidCRM_ChangeFollowing(this, \'" + sModule + "\', \'" + Request["ID"] + "\')" %> Visible="<%# !this.IsMobile && bEnableFavorites && this.StreamEnabled() && !this.ArchiveView() && !this.DisableFollowing() %>" Runat="server">
						<asp:Image ID="imgFollow"    name='<%# "follow_"    + Request["ID"] %>' SkinID="follow"    style='<%# "display:" + ( Sql.IsEmptyGuid(gSUBSCRIPTION_PARENT_ID) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_FOLLOW"   ) %>' Runat="server" />
						<asp:Image ID="imgFollowing" name='<%# "following_" + Request["ID"] %>' SkinID="following" style='<%# "display:" + (!Sql.IsEmptyGuid(gSUBSCRIPTION_PARENT_ID) ? "inline" : "none") %>' ToolTip='<%# L10n.Term(".LBL_FOLLOWING") %>' Runat="server" />
					</asp:HyperLink>
					</h2>
				</asp:TableCell>
				<asp:TableCell VerticalAlign="top" HorizontalAlign="Right" style="padding-top:3px; padding-left: 5px;" Wrap="false">
					<div visible="<%# !PrintView %>" runat="server">
						<asp:ImageButton CommandName="Print" OnCommand="Page_Command" CssClass="utilsLink" AlternateText='<%# L10n.Term(".LNK_PRINT") %>' Visible="<%# bEnablePrint %>" SkinID="print" Runat="server" />
						<asp:LinkButton  CommandName="Print" OnCommand="Page_Command" CssClass="utilsLink" Text='<%# L10n.Term(".LNK_PRINT") %>' Visible="<%# bEnablePrint %>" Runat="server" />
						&nbsp;
						<asp:PlaceHolder Visible='<%# !Sql.ToBoolean(Application["CONFIG.hide_help"]) %>' runat="server">
							<asp:HyperLink ID="lnkHelpImage" onclick="PopupHelp(); return false;" CssClass="utilsLink" Target="_blank" Visible="<%# bEnableHelp %>" Runat="server">
								<asp:Image AlternateText='<%# L10n.Term(".LNK_HELP") %>' SkinID="help" Runat="server" />
							</asp:HyperLink>
							<asp:HyperLink ID="lnkHelpText" onclick="PopupHelp(); return false;" CssClass="utilsLink" Target="_blank" Visible="<%# bEnableHelp %>" Runat="server"><%# L10n.Term(".LNK_HELP") %></asp:HyperLink>
						</asp:PlaceHolder>
					</div>
					<div visible="<%# PrintView %>" runat="server">
						<asp:ImageButton CommandName="PrintOff" OnCommand="Page_Command" CssClass="utilsLink" AlternateText='<%# L10n.Term(".LBL_BACK") %>' Visible="<%# bEnablePrint %>" SkinID="print" Runat="server" />
						<asp:LinkButton  CommandName="PrintOff" OnCommand="Page_Command" CssClass="utilsLink" Text='<%# L10n.Term(".LBL_BACK") %>' Visible="<%# bEnablePrint %>" Runat="server" />
					</div>
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
		<p></p>
	</div>

<script type="text/javascript">
function ConfirmDelete()
{
	return confirm('<%= L10n.TermJavaScript(".NTC_DELETE_CONFIRMATION") %>');
}
</script>
<asp:Table SkinID="tabEditViewButtons" Visible="<%# !PrintView %>" runat="server">
	<asp:TableRow>
		<asp:TableCell ID="tdButtons" Width="10%" Wrap="false">
			<asp:Panel CssClass="button-panel" runat="server">
				<asp:PlaceHolder ID="pnlDynamicButtons" runat="server" />
				<asp:PlaceHolder ID="pnlProcessButtons" runat="server" />
			</asp:Panel>
		</asp:TableCell>
		<asp:TableCell ID="tdError">
			<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
		</asp:TableCell>
		<asp:TableCell ID="tdDynamicLinks" HorizontalAlign="Right" Wrap="false" Visible="false">
			<asp:Panel CssClass="button-panel" runat="server">
				<asp:PlaceHolder ID="pnlDynamicLinks" runat="server" />
			</asp:Panel>
		</asp:TableCell>
		<asp:TableCell ID="tdRequired" HorizontalAlign="Right" Wrap="false" Visible="false">
			<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" />
			&nbsp;
			<asp:Label Text='<%# L10n.Term(".NTC_REQUIRED") %>' Runat="server" />
		</asp:TableCell>
	</asp:TableRow>
</asp:Table>

<%@ Register TagPrefix="SplendidCRM" Tagname="ProcessButtons" Src="~/_controls/ProcessButtons.ascx" %>
<SplendidCRM:ProcessButtons ID="ctlProcessButtons" Runat="Server" />

