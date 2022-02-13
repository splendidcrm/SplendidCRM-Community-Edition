<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.Terminology.Import.ListView" %>
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
<div id="divListView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="Terminology" Title=".LBL_IMPORT" EnablePrint="false" HelpName="index" EnableHelp="true" Runat="Server" />
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Administration.LBL_IMPORT_TERMINOLOGY_TITLE" Runat="Server" />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<asp:Table SkinID="tabSearchView" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Label Text='<%# L10n.Term("Terminology.LBL_IMPORT_TERMINOLOGY_INSTRUCTIONS") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<br />
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabSearchView" runat="server">
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Import.LBL_SELECT_FILE") %>&nbsp;<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField">
							<input id="fileIMPORT" type="file" size="60" MaxLength="255" TabIndex="2" runat="server" />
							<asp:RequiredFieldValidator ID="reqFILENAME" ControlToValidate="fileIMPORT" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
						</asp:TableCell>
						<asp:TableCell CssClass="dataLabel">&nbsp;</asp:TableCell>
						<asp:TableCell CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Administration.LBL_IMPORT_LANGUAGE_TRUNCATE") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:CheckBox ID="chkTruncate" CssClass="checkbox" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel">&nbsp;</asp:TableCell>
						<asp:TableCell CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Administration.LBL_IMPORT_FORCE_UTF8") %></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:CheckBox ID="chkForceUTF8" CssClass="checkbox" Checked="true" Runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel">&nbsp;</asp:TableCell>
						<asp:TableCell CssClass="dataField">&nbsp;</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<br />
	<asp:Table SkinID="tabSearchView" runat="server">
		<asp:TableRow>
			<asp:TableCell ><asp:Button ID="btnBack" CommandName="Back" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_BACK_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_BACK_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_BACK_BUTTON_KEY") %>' Enabled="False" Runat="server" /></asp:TableCell>
			<asp:TableCell HorizontalAlign="Right"><asp:Button ID="btnNext" CommandName="Next" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_NEXT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term(".LBL_NEXT_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_NEXT_BUTTON_KEY") %>' Runat="server" /></asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<asp:Table runat="server" width="100%" cellpadding="0" cellspacing="0" border="0">
		<asp:TableRow>
			<asp:TableCell><asp:Literal ID="lblImportErrors" Runat="server" /></asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<%@ Register TagPrefix="SplendidCRM" Tagname="SplendidLanguagePacks" Src="SplendidLanguagePacks.ascx" %>
	<SplendidCRM:SplendidLanguagePacks ID="ctlSplendidLanguagePacks" Runat="Server" />
	<%@ Register TagPrefix="SplendidCRM" Tagname="LanguagePacks" Src="LanguagePacks.ascx" %>
	<SplendidCRM:LanguagePacks ID="ctlLanguagePacks" Runat="Server" />
</div>

