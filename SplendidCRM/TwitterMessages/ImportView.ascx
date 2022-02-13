<%@ Control CodeBehind="ImportView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.TwitterMessages.ImportView" %>
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
<div id="divImportView">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ModuleHeader" Src="~/_controls/ModuleHeader.ascx" %>
	<SplendidCRM:ModuleHeader ID="ctlModuleHeader" Module="TwitterMessages" Title=".moduleList.Home" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />

	<script type="text/javascript">
	function OAuthTokenUpdate(oauth_token, oauth_verifier)
	{
		document.getElementById('<%= txtOAUTH_TOKEN.ClientID    %>').value = oauth_token   ;
		document.getElementById('<%= txtOAUTH_VERIFIER.ClientID %>').value = oauth_verifier;
		document.getElementById('<%= btnOAuthChanged.ClientID   %>').click();
	}
	</script>

	<asp:HiddenField ID="txtOAUTH_TOKEN"         runat="server" />
	<asp:HiddenField ID="txtOAUTH_SECRET"        runat="server" />
	<asp:HiddenField ID="txtOAUTH_VERIFIER"      runat="server" />
	<asp:HiddenField ID="txtOAUTH_ACCESS_TOKEN"  runat="server" />
	<asp:HiddenField ID="txtOAUTH_ACCESS_SECRET" runat="server" />
	<asp:Button ID="btnOAuthChanged" CommandName="OAuthToken" OnCommand="Page_Command" style="display: none" Runat="server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="PayTrace.LBL_SEARCH_FORM_TITLE" Runat="Server" />
	<div id="divImportSearch">
		<asp:Table SkinID="tabSearchForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<asp:Table Width="100%" CellPadding="0" CellSpacing="0" runat="server">
						<asp:TableRow>
							<asp:TableCell CssClass="dataLabel" Wrap="false" Width="15%"><%= L10n.Term("TwitterMessages.LBL_SEARCH_TEXT") %></asp:TableCell>
							<asp:TableCell CssClass="dataField" Wrap="false" Width="85%"><asp:TextBox ID="txtSEARCH_TEXT" Width="400" runat="server" /></asp:TableCell>
						</asp:TableRow>
					</asp:Table>
					<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
					<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Visible="<%# !PrintView %>" ShowRequired="true" Runat="Server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<%= Utils.RegisterEnterKeyPress(txtSEARCH_TEXT.ClientID, ctlDynamicButtons.ButtonClientID("Search")) %>

	<SplendidCRM:ListHeader Module="TwitterMessages" Title="TwitterMessages.LBL_LIST_FORM_TITLE" Runat="Server" />
	
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-Wrap="false">
				<ItemTemplate>
					<%# grdMain.InputCheckbox(!PrintView && !IsMobile, ctlCheckAll.FieldName, Sql.ToString(Eval("TWITTER_ID")), ctlCheckAll.SelectedItems) %>
				</ItemTemplate>
			</asp:TemplateColumn>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Center" ItemStyle-Wrap="false">
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
	<%@ Register TagPrefix="SplendidCRM" Tagname="CheckAll" Src="~/_controls/CheckAll.ascx" %>
	<SplendidCRM:CheckAll ID="ctlCheckAll" Visible="<%# !PrintView && !IsMobile %>" FieldName="TWITTER_ID" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

