<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SearchView.ascx.cs" Inherits="SplendidCRM._controls.SearchView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
<%@ Import Namespace="SplendidCRM._controls" %>
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
<div id="divSearchView">
	<script type="text/javascript">
		function ToggleSearch()
		{
			// 01/24/2008 Paul.  On PocketPC and SmartPhone, getElementById is not available. 
			var divSearch;
			if ( document.getElementById == undefined )
				divSearch = <%= pnlSearchPanel.ClientID %>;
			else
				divSearch = document.getElementById('<%= pnlSearchPanel.ClientID %>');
			if ( divSearch.style.display == 'inline' )
				divSearch.style.display = 'none';
			else
				divSearch.style.display = 'inline';
		}
		function ToggleSavedSearch()
		{
			var divSavedSearchPanel = document.getElementById('<%= pnlSavedSearchPanel.ClientID %>');
			var imgBasicSearch      = document.getElementById('<%= imgBasicSearch     .ClientID %>');
			var imgAdvancedSearch   = document.getElementById('<%= imgAdvancedSearch  .ClientID %>');
			if ( divSavedSearchPanel.style.display == 'inline' )
			{
				divSavedSearchPanel.style.display = 'none';
				imgBasicSearch.style.display      = 'none';
				imgAdvancedSearch.style.display   = 'inline';
			}
			else
			{
				divSavedSearchPanel.style.display = 'inline';
				imgBasicSearch.style.display      = 'inline';
				imgAdvancedSearch.style.display   = 'none';
			}
		}
		function ToggleUnassignedOnly()
		{
			var sASSIGNED_USER_ID = '<%= new SplendidCRM.DynamicControl(this, "ASSIGNED_USER_ID").ClientID %>';
			var sUNASSIGNED_ONLY  = '<%= new SplendidCRM.DynamicControl(this, "UNASSIGNED_ONLY" ).ClientID %>';
			if ( sASSIGNED_USER_ID.length > 0 && sUNASSIGNED_ONLY.length > 0 )
			{
				var lstASSIGNED_USER_ID = document.getElementById(sASSIGNED_USER_ID);
				var chkUNASSIGNED_ONLY  = document.getElementById(sUNASSIGNED_ONLY );
				if ( lstASSIGNED_USER_ID != null && chkUNASSIGNED_ONLY != null )
					lstASSIGNED_USER_ID.disabled = chkUNASSIGNED_ONLY.checked;
			}
		}
	</script>

	<asp:Panel ID="pnlMobileButtons" Visible="<%# !IsPopupSearch && IsMobile %>" runat="server">
		&nbsp;<asp:HyperLink ID="lnkSearch" NavigateUrl="javascript:ToggleSearch();void(null);" Text='<%# L10n.Term(".LBL_SEARCH_BUTTON_LABEL") %>' runat="server" />
		&nbsp;<a href="edit.aspx"><%# L10n.Term(".LBL_NEW_BUTTON_LABEL") %></a>
	</asp:Panel>
	<asp:Panel ID="pnlSearchPanel" style='<%# (!IsPopupSearch && IsMobile) ? "display: none" : "display: inline" %>' runat="server">
		<asp:Panel ID="pnlSearchTabs" Visible="<%# ShowSearchTabs && !IsMobile %>" runat="server">
			<ul class="tablist">
				<li><asp:HyperLink ID="lnkBasicSearch"     Text='<%# L10n.Term(".LNK_BASIC_SEARCH"    ) %>' CssClass=""        Runat="server" /></li>
				<li><asp:HyperLink ID="lnkAdvancedSearch"  Text='<%# L10n.Term(".LNK_ADVANCED_SEARCH" ) %>' CssClass="current" Runat="server" /></li>
				<li><asp:HyperLink ID="lnkDuplicateSearch" Text='<%# L10n.Term(".LNK_DUPLICATE_SEARCH") %>' CssClass=""        Visible="<%# ShowDuplicateSearch %>" Runat="server" /></li>
			</ul>
		</asp:Panel>
		
		<asp:Table SkinID="tabSearchForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<asp:Table Width="100%" runat="server">
						<asp:TableRow>
							<asp:TableCell Width="20%" VerticalAlign="Top" Visible="<%# nAdvanced == 2 %>">
								<asp:Label Text='<%# L10n.Term("Import.LBL_IMPORT_STEP_DUPLICATE_FILTER") %>' Font-Bold="true" runat="server" /><br />
								<asp:ListBox ID="lstDuplicateColumns" DataValueField="NAME" DataTextField="DISPLAY_NAME" Rows="10" SelectionMode="Multiple" runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="Top">
								<asp:Literal Text="<br />" Visible="<%# nAdvanced == 2 %>" runat="server" />
								<table id="tblSearch" class="tabSearchView" runat="server">
								</table>
							</asp:TableCell>
						</asp:TableRow>
					</asp:Table>
					<asp:Panel ID="pnlSearchButtons" CssClass="button-panel" style="padding-top: 4px;" Visible="<%# ShowSearchButtons %>" runat="server">
						<asp:Table ID="tblSearchButtons" Width="100%" CellPadding="0" CellSpacing="0" class="tabSavedSearch" runat="server">
							<asp:TableRow>
								<asp:TableCell>
									<asp:Button ID="btnSearch" CommandName="Search" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_SEARCH_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SEARCH_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SEARCH_BUTTON_KEY") %>' Runat="server" />&nbsp;
									<asp:Button ID="btnClear"  CommandName="Clear"  OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_CLEAR_BUTTON_LABEL" ) %>' ToolTip='<%# L10n.Term(".LBL_CLEAR_BUTTON_TITLE" ) %>' AccessKey='<%# L10n.AccessKey(".LBL_CLEAR_BUTTON_KEY" ) %>' Runat="server" />

									<span Visible="<%# ShowSearchViews && !IsPopupSearch %>" runat="server">
										<font class="white-space">&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;</font>
										<asp:Label ID="lblSavedSearch" Font-Bold="true" Text='<%# L10n.Term(".LBL_SAVED_SEARCH_SHORTCUT" ) %>' Visible='<%# !IsMobile %>' runat="server" />
										<asp:DropDownList ID="lstSavedSearches" DataValueField="ID" DataTextField="NAME" OnSelectedIndexChanged="lstSavedSearches_Changed" AutoPostBack="true" runat="server" />
										&nbsp;
										<asp:HyperLink ID="lnkToggleSavedSearch" NavigateUrl="javascript:ToggleSavedSearch();void(0);" Visible='<%# ShowSearchViews && !IsPopupSearch && !IsMobile %>' runat="server">
											<asp:Image ID="imgBasicSearch"    SkinID="basic_search"    BorderWidth="0" style="display: none;"   runat="server" />
											<asp:Image ID="imgAdvancedSearch" SkinID="advanced_search" BorderWidth="0" style="display: inline;" runat="server" />&nbsp;
											<%# L10n.Term(".LNK_SAVED_VIEWS") %>
										</asp:HyperLink>
										&nbsp;
										<asp:Label ID="lblCurrentXML" Visible="<%# false && bDebug %>" runat="server" />
									</span>
								</asp:TableCell>
							</asp:TableRow>
						</asp:Table>
					</asp:Panel>
					<asp:Panel ID="pnlSavedSearchPanel" style="display: none;" CssClass="button-panel" runat="server">
						<asp:Table Width="100%" CellPadding="0" CellSpacing="1" class="tabSavedSearch" runat="server">
							<asp:TableRow>
								<asp:TableCell Width="15%"><asp:Label Text='<%# L10n.Term("SavedSearch.LBL_ORDER_BY_COLUMNS") %>' runat="server" /></asp:TableCell>
								<asp:TableCell Width="35%"><asp:DropDownList ID="lstColumns" DataValueField="NAME" DataTextField="DISPLAY_NAME" runat="server" /></asp:TableCell>
								<asp:TableCell Width="15%"><asp:Label Text='<%# L10n.Term("SavedSearch.LBL_DIRECTION") %>' runat="server" /></asp:TableCell>
								<asp:TableCell Width="35%">
									<asp:RadioButton ID="radSavedSearchDESC" GroupName="SavedSearchDirection" Text='<%# L10n.Term("SavedSearch.LBL_DESCENDING") %>' CssClass="radio" runat="server" /><br />
									<asp:RadioButton ID="radSavedSearchASC"  GroupName="SavedSearchDirection" Text='<%# L10n.Term("SavedSearch.LBL_ASCENDING" ) %>' CssClass="radio" Checked="true" runat="server" /><br />
								</asp:TableCell>
							</asp:TableRow>
							<asp:TableRow>
								<asp:TableCell Width="15%"><asp:Label Text='<%# L10n.Term("SavedSearch.LBL_SAVE_SEARCH_AS") %>' runat="server" /></asp:TableCell>
								<asp:TableCell Width="35%">
									<asp:TextBox ID="txtSavedSearchName" runat="server" />
									&nbsp;
									<asp:Button ID="btnSavedSearchSave" CommandName="SavedSearch.Save" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_SAVE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SAVE_BUTTON_TITLE") %>' AccessKey='<%# L10n.AccessKey(".LBL_SAVE_BUTTON_KEY") %>' Runat="server" />
									<asp:Label ID="lblSavedNameRequired" Visible="false" Text='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableViewState="false" runat="server" />
								</asp:TableCell>
								<asp:TableCell Width="15%">
									<asp:Label Text='<%# L10n.Term("SavedSearch.LBL_MODIFY_CURRENT_SEARCH") %>' runat="server" />
								</asp:TableCell>
								<asp:TableCell Width="35%">
									<asp:Button ID="btnSavedSearchUpdate" CommandName="SavedSearch.Update" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_UPDATE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_UPDATE_BUTTON_TITLE") %>' Runat="server" />&nbsp;
									<asp:Button ID="btnSavedSearchDelete" CommandName="SavedSearch.Delete" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_DELETE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_DELETE_BUTTON_TITLE") %>' Runat="server" />&nbsp;
									<asp:Label ID="lblCurrentSearch" runat="server" />
								</asp:TableCell>
							</asp:TableRow>
						</asp:Table>
					</asp:Panel>
					<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</asp:Panel>
</div>

