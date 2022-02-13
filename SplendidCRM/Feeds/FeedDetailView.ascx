<%@ Control CodeBehind="FeedDetailView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Feeds.FeedDetailView" %>
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
	<asp:Table SkinID="tabFrame" CssClass="tabDetailView" runat="server">
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDF">
				<asp:Table SkinID="tabFrame" CssClass="mod" runat="server">
					<asp:TableRow>
						<asp:TableCell bgcolor="aaaaaa">
							<asp:Table Width="100%" BorderWidth="0" CellPadding="2" CellSpacing="0" runat="server">
								<asp:TableRow>
									<asp:TableCell CssClass="modtitle" width="98%">
										<asp:HyperLink Text='<%# sChannelTitle %>' NavigateUrl='<%# sChannelLink %>' Runat="server" />
									</asp:TableCell>
								</asp:TableRow>
							</asp:Table>
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell>
							<asp:DataGrid id="grdMain" Width="100%" CellPadding="3" CellSpacing="0" border="0"
								AllowPaging="false" AllowSorting="false" AutoGenerateColumns="false" 
								ShowHeader="false" EnableViewState="false" runat="server">
								<Columns>
									<asp:TemplateColumn>
										<ItemTemplate>
											<asp:Table CellPadding="0" CellSpacing="2" runat="server">
												<asp:TableRow>
													<asp:TableCell CssClass="itemtitle">
														<asp:HyperLink Text='<%# DataBinder.Eval(Container.DataItem, "title") %>' NavigateUrl='<%# DataBinder.Eval(Container.DataItem, "link") %>' Target="_new" Runat="server" />
													</asp:TableCell>
												</asp:TableRow>
												<asp:TableRow><asp:TableCell CssClass="itemdate"><%# DataBinder.Eval(Container.DataItem, "pubDate"    ) %></asp:TableCell></asp:TableRow>
												<asp:TableRow><asp:TableCell CssClass="itemdesc"><%# DataBinder.Eval(Container.DataItem, "description") %></asp:TableCell></asp:TableRow>
											</asp:Table>
										</ItemTemplate>
									</asp:TemplateColumn>
								</Columns>
							</asp:DataGrid>
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<br />
</div>

