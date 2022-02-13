<%@ Control CodeBehind="MonthRow.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Calendar.MonthRow" %>
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
						<div id="divMonthRow">
							<asp:DataList ID="lstMain" Width="100%"  BorderWidth="0" CellPadding="0" CellSpacing="0" ShowBorder="False"
								RepeatDirection="Horizontal" RepeatLayout="Flow" RepeatColumns="0" 
								DataSource="<%# vwMain %>" Runat="server">
								<ItemTemplate>
									<div style="margin-top: 1px;">
									<asp:Table SkinID="tabFrame" CssClass="monthCalBodyDayItem" runat="server">
										<asp:TableRow>
											<asp:TableCell CssClass="monthCalBodyDayIconTd">
												<SplendidCRM:DynamicImage ImageSkinID='<%# DataBinder.Eval(Container.DataItem, "ACTIVITY_TYPE") %>' AlternateText='<%# L10n.Term(Sql.ToString(DataBinder.Eval(Container.DataItem, "STATUS"))) + ": " + DataBinder.Eval(Container.DataItem, "NAME") %>' Runat="server" />
											</asp:TableCell>
											<asp:TableCell Width="100%" CssClass="monthCalBodyDayItemTd">
												<asp:HyperLink Text='<%# L10n.Term(Sql.ToString(DataBinder.Eval(Container.DataItem, "STATUS"))) + ": " + DataBinder.Eval(Container.DataItem, "NAME") %>' NavigateUrl='<%# "~/" + DataBinder.Eval(Container.DataItem, "ACTIVITY_TYPE") + "/view.aspx?id=" + DataBinder.Eval(Container.DataItem, "ID") %>' CssClass="monthCalBodyDayItemLink" Runat="server" />
											</asp:TableCell>
										</asp:TableRow>
									</asp:Table>
									<div>
								</ItemTemplate>
								<SeparatorStyle Height="1px" />
							</asp:DataList>
						</div>

