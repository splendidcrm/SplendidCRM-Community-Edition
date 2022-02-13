<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ConfigView.ascx.cs" Inherits="SplendidCRM.Administration.BusinessMode.ConfigView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="Administration" Title="Administration.LBL_BUSINESS_MODE_TITLE" EnableModuleLabel="false" EnablePrint="false" EnableHelp="true" Runat="Server" />
	
	<p></p>
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="50%" VerticalAlign="Top">
				<asp:Label Text='<%# L10n.Term("Administration.LBL_BUSINESS_MODE_INSTRUCTIONS") %>' runat="server" /><br />
			</asp:TableCell>
			<asp:TableCell Width="50%" VerticalAlign="Top">
				<asp:Label Text='<%# L10n.Term("Administration.LBL_OPPORTUNITIES_MODE_INSTRUCTIONS") %>' runat="server" /><br />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell>
				<asp:RadioButton ID="radBUSINESS_MODE_B2B" GroupName="BusinessMode" Text='<%# L10n.Term("Administration.LBL_BUSINESS_MODE_B2B") %>' CssClass="radio" runat="server" /><br />
				<asp:RadioButton ID="radBUSINESS_MODE_B2C" GroupName="BusinessMode" Text='<%# L10n.Term("Administration.LBL_BUSINESS_MODE_B2C") %>' CssClass="radio" runat="server" /><br />
			</asp:TableCell>
			<asp:TableCell>
				<asp:RadioButton ID="radOPPORTUNITIES_MODE_OPPORTUNITIES" GroupName="OpportunitiesMode" Text='<%# L10n.Term("Administration.LBL_OPPORTUNITIES_MODE_OPPORTUNITIES") %>' CssClass="radio" runat="server" /><br />
				<asp:RadioButton ID="radOPPORTUNITIES_MODE_REVENUE"       GroupName="OpportunitiesMode" Text='<%# L10n.Term("Administration.LBL_OPPORTUNITIES_MODE_REVENUE"      ) %>' CssClass="radio" runat="server" /><br />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !SplendidDynamic.StackedLayout(this.Page.Theme) && !PrintView %>" ShowRequired="false" Runat="Server" />
</div>
