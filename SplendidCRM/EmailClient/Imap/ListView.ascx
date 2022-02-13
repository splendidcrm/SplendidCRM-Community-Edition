<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ListView.ascx.cs" Inherits="SplendidCRM.EmailClient.Imap.ListView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<script type="text/javascript">
function InboxMessageClickSubmitButton(sRowID)
{
	// alert('InboxMessageClickSubmitButton(' + sRowID + ')');
	var tr = document.getElementById(sRowID);
	// 03/12/2012 Paul.  There seems to be some unexpected text before the cell, so childNodes[0] stopped working.  Use cells instead. 
	var td = tr.cells[0];
	var btn = td.childNodes[0];
	if ( btn.type == 'submit' )
		btn.click();
	else
		alert('Could not find the Select button');
	
}
// 01/23/2017 Paul.  Resize the layout. 
function LayoutResize()
{
	try
	{
		var divDynamicLayoutSearchBasic  = document.getElementById('<%# tblEmailView.ClientID %>');
		if ( divDynamicLayoutSearchBasic != null )
		{
			rect = divDynamicLayoutSearchBasic.getBoundingClientRect();
			nHeight = $(window).height() - rect.top;
			nHeight -= 42;
			divDynamicLayoutSearchBasic.style.height = nHeight.toString() + 'px';
			var divMain = document.getElementById('<%# divMain.ClientID %>');
			if ( divMain != null )
			{
				nHeight = (nHeight * 6) / 10;
				divMain.style.height = nHeight.toString() + 'px';
			}
		}
	}
	catch(e)
	{
		alert('LayoutResize: ' + e.message);
	}
}
window.onload = function()
{
	//LayoutResize();
	$(window).resize(LayoutResize);
}
Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(LayoutResize);
</script>
<div id="divListView">
	<asp:UpdatePanel UpdateMode="Conditional" runat="server">
		<ContentTemplate>
			<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
			<%-- 03/16/2016 Paul.  HeaderButtons must be inside UpdatePanel in order to display errors. --%>
			<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
			<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" Module="EmailClient" Title="<%# Security.EXCHANGE_ALIAS %>" EnableModuleLabel="true" EnablePrint="false" HelpName="index" EnableHelp="true" Runat="Server" />

			<asp:Table ID="tblEmailView" Width="100%" Height="550" BorderWidth="1" runat="server">
				<asp:TableRow>
					<asp:TableCell BorderWidth="1" VerticalAlign="Top" Width="200">
						<asp:XmlDataSource ID="xdsFolders" EnableCaching="false" runat="server" />
						<asp:TreeView ID="treeMain" ExpandDepth="1" ImageSet="Inbox" PopulateNodesFromClient="true" EnableClientScript="true" runat="server">
							<LeafNodeStyle     CssClass="leafEmailFolderLink"     />
							<ParentNodeStyle   CssClass="parentEmailFolderLink"   />
							<SelectedNodeStyle CssClass="selectedEmailFolderLink" />
							<NodeStyle         CssClass="nodeEmailFolderLink"     />
							<DataBindings>
								<asp:TreeNodeBinding DataMember="Folders" TextField="DisplayName" Depth="0" SelectAction="None" />
								<asp:TreeNodeBinding DataMember="Folder"  TextField="DisplayName" ValueField="Id" />
							</DataBindings>
						</asp:TreeView>
					</asp:TableCell>
					<asp:TableCell BorderWidth="1" VerticalAlign="Top">
						<div id="divMain" style="overflow-x: auto; overflow-y: scroll; height: 350px; border-bottom: 1px solid black;" runat="server">
							<asp:Label ID="lblFolderTitle" Font-Bold="true" runat="server" />
							<div style="width: 95%;">
								<asp:UpdatePanel UpdateMode="Conditional" runat="server">
									<ContentTemplate>
										<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="true" EnableViewState="true" runat="server">
											<Columns>
												<asp:TemplateColumn ItemStyle-Width="1%">
													<ItemTemplate><asp:Button Text='<%# Eval("UNIQUE_ID") %>' CommandName="Select" CommandArgument='<%# Eval("UNIQUE_ID") %>' style="display: none;" runat="server" />
														<asp:Image SkinID="attachment" Visible='<%# Sql.ToBoolean(Eval("HAS_ATTACHMENTS")) %>' runat="server" />
													</ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn     HeaderText="EmailClient.LBL_LIST_FROM"      SortExpression="FROM" ItemStyle-Width="20%" ItemStyle-Wrap="true">
													<ItemTemplate><asp:Label Font-Bold='<%# !Sql.ToBoolean(Eval("IS_READ")) %>' Text='<%# HttpUtility.HtmlEncode(Eval("FROM") )%>' runat="server" /></ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn     HeaderText="EmailClient.LBL_LIST_SUBJECT"   SortExpression="NAME" ItemStyle-Width="29%" ItemStyle-Wrap="true" >
													<ItemTemplate><asp:Label Font-Bold='<%# !Sql.ToBoolean(Eval("IS_READ")) %>' Text='<%# HttpUtility.HtmlEncode(Eval("NAME")) %>' runat="server" /></ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn     HeaderText="EmailClient.LBL_LIST_DATE_RECEIVED" SortExpression="DATE_START" ItemStyle-Width="20%" ItemStyle-Wrap="false">
													<ItemTemplate><asp:Label Font-Bold='<%# !Sql.ToBoolean(Eval("IS_READ")) %>' Text='<%# (Eval("DATE_START") != DBNull.Value) ? Sql.ToDateTime(Eval("DATE_START")).ToString("g") : String.Empty %>' runat="server" /></ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn     HeaderText="EmailClient.LBL_LIST_TO"        SortExpression="TO_ADDRS" ItemStyle-Width="20%" ItemStyle-Wrap="true" >
													<ItemTemplate><asp:Label Font-Bold='<%# !Sql.ToBoolean(Eval("IS_READ")) %>' Text='<%# HttpUtility.HtmlEncode(Eval("TO_ADDRS")) %>' runat="server" /></ItemTemplate>
												</asp:TemplateColumn>
												<asp:TemplateColumn     HeaderText="EmailClient.LBL_LIST_SIZE"      SortExpression="SIZE" ItemStyle-Width="10%" ItemStyle-Wrap="false">
													<ItemTemplate><asp:Label Font-Bold='<%# !Sql.ToBoolean(Eval("IS_READ")) %>' Text='<%# Eval("SIZE_STRING") %>' runat="server" /></ItemTemplate>
												</asp:TemplateColumn>
											</Columns>
										</SplendidCRM:SplendidGrid>
									</ContentTemplate>
								</asp:UpdatePanel>
							</div>
						</div>
						<asp:UpdatePanel runat="server">
							<ContentTemplate>
								<asp:HiddenField ID="hidQuickCreateModule" runat="server" />
								<asp:PlaceHolder ID="plcQuickCreate" runat="server" />
								<%@ Register TagPrefix="SplendidCRM" Tagname="ImportView" Src="~/EmailClient/ImportView.ascx" %>
								<SplendidCRM:ImportView ID="ctlImportView" Visible="false" Runat="Server" />
								<%@ Register TagPrefix="SplendidCRM" Tagname="EditView" Src="~/EmailClient/EditView.ascx" %>
								<SplendidCRM:EditView ID="ctlEditView" Visible="false" Runat="Server" />

								<div id="UpdatePanelProgressDiv" style="display: none;">
									<asp:Label Text='<%# L10n.Term("EmailClient.LBL_EMAIL_LOADING") %>' CssClass="warning" runat="server" />
								</div>
								
								<asp:HiddenField ID="hidSelectedUniqueID" runat="server" />
								<%@ Register TagPrefix="SplendidCRM" Tagname="DetailView" Src="~/EmailClient/DetailView.ascx" %>
								<SplendidCRM:DetailView ID="ctlDetailView" Visible="false" Runat="Server" />
							</ContentTemplate>
						</asp:UpdatePanel>
						&nbsp;
					</asp:TableCell>
				</asp:TableRow>
			</asp:Table>
			
			<%@ Register TagPrefix="SplendidCRM" Tagname="SettingsView" Src="~/EmailClient/SettingsView.ascx" %>
			<SplendidCRM:SettingsView ID="ctlSettingsView" Visible="false" Service="imap" Runat="Server" />
		</ContentTemplate>
	</asp:UpdatePanel>
</div>

