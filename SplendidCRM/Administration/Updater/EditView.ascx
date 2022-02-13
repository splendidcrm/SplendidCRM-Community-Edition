<%@ Control Language="c#" AutoEventWireup="false" Codebehind="EditView.ascx.cs" Inherits="SplendidCRM.Administration.Updater.EditView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="Administration" Title="Administration.LBL_CONFIGURE_UPDATER" EnablePrint="false" EnableHelp="true" Runat="Server" />
	
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabEditView" runat="server">
					<asp:TableRow>
						<asp:TableHeaderCell CssClass="dataLabel"><h4><asp:Label Text='<%# L10n.Term("Administration.LBL_SPLENDIDCRM_UPDATE_TITLE") %>' runat="server" /></h4></asp:TableHeaderCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell>
							<asp:Table CellPadding="4" runat="server">
								<asp:TableRow>
									<asp:TableCell Width="1%" CssClass="dataField" VerticalAlign="Top">
										<asp:CheckBox ID="SEND_USAGE_INFO" CssClass="checkbox" Runat="server" />
									</asp:TableCell>
									<asp:TableCell Width="99%" CssClass="dataField">
										<asp:Label Text='<%# L10n.Term("Administration.LBL_SEND_STAT") %>' runat="server" />
									</asp:TableCell>
								</asp:TableRow>
							</asp:Table>
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell>
							<asp:Table CellPadding="4" runat="server">
								<asp:TableRow>
									<asp:TableCell Width="1%" CssClass="dataField" VerticalAlign="Top">
										<asp:CheckBox ID="CHECK_UPDATES" CssClass="checkbox" Runat="server" />
									</asp:TableCell>
									<asp:TableCell Width="99%" CssClass="dataField">
										<asp:Label Text='<%# L10n.Term("Administration.LBL_UPDATE_CHECK_TYPE") %>' runat="server" />
									</asp:TableCell>
								</asp:TableRow>
							</asp:Table>
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell>
							<asp:Table CellPadding="4" runat="server">
								<asp:TableRow>
									<asp:TableCell CssClass="dataField">
										<asp:Button OnCommand="Page_Command" CommandName="CheckNow" Text='<%# "  " + L10n.Term("Administration.LBL_CHECK_NOW_LABEL") + "  " %>' ToolTip='<%# L10n.Term("Administration.LBL_CHECK_NOW_TITLE") %>' CssClass="buttonOn" runat="server" />
										&nbsp;
										<b>Version <%= Application["SplendidVersion"] %></b>
									</asp:TableCell>
								</asp:TableRow>
							</asp:Table>
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataField">
							<asp:Label ID="NO_UPDATES" Text='<%# L10n.Term("Administration.LBL_UPTODATE") %>' Visible="false" runat="server" />

							<SplendidCRM:SplendidGrid id="grdMain" AllowPaging="false" AllowSorting="false" EnableViewState="true" runat="server">
								<Columns>
									<asp:BoundColumn     HeaderText="Build"       DataField="Build"       ItemStyle-Width="15%" ItemStyle-Wrap="false" />
									<asp:BoundColumn     HeaderText="Date"        DataField="Date"        ItemStyle-Width="15%" ItemStyle-Wrap="false" />
									<asp:BoundColumn     HeaderText="Description" DataField="Description" ItemStyle-Width="60%" ItemStyle-Wrap="true" />
									<asp:TemplateColumn  HeaderText="" ItemStyle-Width="1%">
										<ItemTemplate>
											<asp:HyperLink  NavigateUrl='<%# Eval("URL") %>' SkinID="Backup" runat="server" />
										</ItemTemplate>
									</asp:TemplateColumn>
								</Columns>
							</SplendidCRM:SplendidGrid>
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !SplendidDynamic.StackedLayout(this.Page.Theme) && !PrintView %>" ShowRequired="false" Runat="Server" />
</div>

