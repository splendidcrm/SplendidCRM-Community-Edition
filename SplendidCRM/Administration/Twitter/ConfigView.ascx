<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ConfigView.ascx.cs" Inherits="SplendidCRM.Administration.Twitter.ConfigView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divEditView" runat="server">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="Twitter" Title="Twitter.LBL_MANAGE_TWITTER_TITLE" EnableModuleLabel="false" EnablePrint="false" EnableHelp="true" Runat="Server" />
	
	<p></p>
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Label Text='<%# L10n.Term("Twitter.LBL_APP_INSTRUCTIONS").Replace("~/", Request.Url.Scheme + "://" + Request.Url.Host + Sql.ToString(Application["rootURL"])) %>' runat="server" />
				<asp:Table SkinID="tabSearchView" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("Twitter.LBL_TWITTER_CONSUMER_KEY") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="80%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="TWITTER_CONSUMER_KEY" Size="80" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("Twitter.LBL_TWITTER_SECRET_KEY") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="80%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="TWITTER_CONSUMER_SECRET" Size="80" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label ID="Label1" Text='<%# L10n.Term("Twitter.LBL_ACCESS_TOKEN") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="80%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="ACCESS_TOKEN" Size="80" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label ID="Label2" Text='<%# L10n.Term("Twitter.LBL_ACCESS_TOKEN_SECRET") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="80%" CssClass="dataField" VerticalAlign="top">
							<asp:TextBox ID="ACCESS_TOKEN_SECRET" Size="80" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label Text='<%# L10n.Term("Twitter.LBL_ENABLE_TRACKING") %>' runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="80%" CssClass="dataField" VerticalAlign="top">
							<asp:CheckBox ID="ENABLE_TRACKING" class="checkbox" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !SplendidDynamic.StackedLayout(this.Page.Theme) && !PrintView %>" ShowRequired="false" Runat="Server" />
</div>
