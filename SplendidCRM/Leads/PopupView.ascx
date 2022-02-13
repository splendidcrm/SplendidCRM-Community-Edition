<%@ Control CodeBehind="PopupView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Leads.PopupView" %>
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
	<SplendidCRM:SearchView ID="ctlSearchView" Module="Leads" IsPopupSearch="true" ShowSearchTabs="false" Visible="<%# !PrintView %>" Runat="Server" />

	<script type="text/javascript">
	function SelectLead(sPARENT_ID, sPARENT_NAME)
	{
		if ( window.opener != null && window.opener.ChangeLead != null )
		{
			window.opener.ChangeLead(sPARENT_ID, sPARENT_NAME);
			window.close();
		}
		else
		{
			alert('Original window has closed.  Lead cannot be assigned.' + '\n' + sPARENT_ID + '\n' + sPARENT_NAME);
		}
	}
	function SelectChecked()
	{
		if ( window.opener != null && window.opener.ChangeLead != null )
		{
			var sSelectedItems = document.getElementById('<%= ctlCheckAll.SelectedItems.ClientID %>').value;
			window.opener.ChangeLead(sSelectedItems, '');
			window.close();
		}
		else
		{
			alert('Original window has closed.  Lead cannot be assigned.');
		}
	}
	function Clear()
	{
		if ( window.opener != null && window.opener.ChangeLead != null )
		{
			window.opener.ChangeLead('', '');
			window.close();
		}
		else
		{
			alert('Original window has closed.  Lead cannot be assigned.');
		}
	}
	function Cancel()
	{
		window.close();
	}
	</script>
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Leads.LBL_LIST_FORM_TITLE" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Runat="Server" />

	<asp:UpdatePanel UpdateMode="Conditional" Visible='<%# !Sql.ToBoolean(Application["CONFIG.disable_popupview_inline"]) %>' runat="server">
		<ContentTemplate>
			<asp:Button ID="btnCreateInline" CommandName="NewRecord.Show" OnCommand="Page_Command" Text='<%# L10n.Term(m_sMODULE + ".LNK_NEW_LEAD") %>' CssClass="button" style="margin-bottom: 4px;" Visible="<%# !this.IsMobile %>" runat="server" />
			<asp:Panel ID="pnlNewRecordInline" Style="display:none" runat="server">
				<%@ Register TagPrefix="SplendidCRM" Tagname="NewRecord" Src="NewRecord.ascx" %>
				<SplendidCRM:NewRecord ID="ctlNewRecord" Width="100%" EditView="PopupView.Inline" ShowCancel="true" Runat="Server" />
			</asp:Panel>
		</ContentTemplate>
	</asp:UpdatePanel>

	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdPopupView" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="2%">
				<ItemTemplate><%# grdMain.InputCheckbox(!PrintView && bMultiSelect, ctlCheckAll.FieldName, Sql.ToGuid(Eval("ID")), ctlCheckAll.SelectedItems) %></ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
	<%@ Register TagPrefix="SplendidCRM" Tagname="CheckAll" Src="~/_controls/CheckAll.ascx" %>
	<SplendidCRM:CheckAll ID="ctlCheckAll" Visible="<%# !PrintView && bMultiSelect %>" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>

