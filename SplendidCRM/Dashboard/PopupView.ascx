<%@ Control CodeBehind="PopupView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Dashboard.PopupView" %>
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
<div id="divPopupView">
	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="Dashboard" IsPopupSearch="true" ShowSearchTabs="false" Visible="<%# !PrintView %>" Runat="Server" />

	<script type="text/javascript">
	function SelectDashboard(sDASHBOARD_ID, sCATEGORY)
	{
		if ( window.opener != null && window.opener.ChangeDashboard != null )
		{
			var sREPORT_ID = '<%# Request["REPORT_ID"] %>';
			window.opener.ChangeDashboard(sREPORT_ID, sDASHBOARD_ID, sCATEGORY);
			window.close();
		}
		else
		{
			alert('Original window has closed.  Dashboard cannot be assigned.' + '\n' + sDASHBOARD_ID + '\n' + sCATEGORY);
		}
		return false;
	}
	function Cancel()
	{
		window.close();
	}
	</script>

	<asp:Label ID="lblError" CssClass="error" EnableViewState="false" runat="server" />

	<asp:Panel ID="pnlMain" runat="server">
		<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
		<SplendidCRM:ListHeader Title="Dashboard.LBL_HOME_PAGE_DASHBOARDS" Runat="Server" />

		<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdPopupView" EnableViewState="true" runat="server">
			<Columns>
				<asp:TemplateColumn HeaderText="Dashboard.LBL_LIST_NAME" SortExpression="NAME" ItemStyle-Width="80%" ItemStyle-HorizontalAlign="Left">
					<ItemTemplate>
						<asp:HyperLink Text='<%# Eval("NAME") %>' NavigateUrl='<%# "javascript:SelectDashboard(null, \"" + Eval("NAME") + "\")" %>' Runat="server" />
					</ItemTemplate>
				</asp:TemplateColumn>
				<asp:BoundColumn HeaderText="Dashboard.LBL_LIST_CATEGORY" DataField="CATEGORY" ItemStyle-Width="80%" ItemStyle-HorizontalAlign="Left" />
			</Columns>
		</SplendidCRM:SplendidGrid>
	</asp:Panel>

	<asp:Panel ID="pnlHome" runat="server">
		<SplendidCRM:ListHeader Title="Dashboard.LBL_HOME_PAGE_DASHBOARDS" Runat="Server" />
		<asp:Button Text='<%# L10n.Term("Dashboard.LBL_CREATE_NEW_DASHBOARD") %>' OnClientClick='<%# "SelectDashboard(null, \"Home\")" %>' CssClass="button" style="margin-bottom: 4px;" runat="server" />

		<SplendidCRM:SplendidGrid id="grdHome" SkinID="grdPopupView" EnableViewState="true" runat="server">
			<Columns>
				<asp:TemplateColumn HeaderText="Dashboard.LBL_LIST_NAME" SortExpression="NAME" ItemStyle-Width="80%" ItemStyle-HorizontalAlign="Left">
					<ItemTemplate>
						<asp:HyperLink Text='<%# Eval("NAME") %>' NavigateUrl='<%# "javascript:SelectDashboard(\"" + Eval("ID") + "\", \"" + Eval("CATEGORY") + "\")" %>' Runat="server" />
					</ItemTemplate>
				</asp:TemplateColumn>
				<asp:BoundColumn HeaderText="Dashboard.LBL_LIST_CATEGORY" DataField="CATEGORY" ItemStyle-Width="80%" ItemStyle-HorizontalAlign="Left" />
			</Columns>
		</SplendidCRM:SplendidGrid>
	</asp:Panel>

	<asp:Panel ID="pnlDashboard" runat="server">
		<SplendidCRM:ListHeader Title="Dashboard.LBL_DASHBOARDS" Runat="Server" />
		<asp:Button Text='<%# L10n.Term("Dashboard.LBL_CREATE_NEW_DASHBOARD") %>' OnClientClick='<%# "SelectDashboard(null, \"Dashboard\")" %>' CssClass="button" style="margin-bottom: 4px;" runat="server" />

		<SplendidCRM:SplendidGrid id="grdDashboard" SkinID="grdPopupView" EnableViewState="true" runat="server">
			<Columns>
				<asp:TemplateColumn HeaderText="Dashboard.LBL_LIST_NAME" SortExpression="NAME" ItemStyle-Width="80%" ItemStyle-HorizontalAlign="Left">
					<ItemTemplate>
						<asp:HyperLink Text='<%# Eval("NAME") %>' NavigateUrl='<%# "javascript:SelectDashboard(\"" + Eval("ID") + "\", \"" + Eval("CATEGORY") + "\")" %>' Runat="server" />
					</ItemTemplate>
				</asp:TemplateColumn>
				<asp:BoundColumn HeaderText="Dashboard.LBL_LIST_CATEGORY" DataField="CATEGORY" ItemStyle-Width="80%" ItemStyle-HorizontalAlign="Left" />
			</Columns>
		</SplendidCRM:SplendidGrid>
	</asp:Panel>

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

