<%@ Control Language="c#" AutoEventWireup="false" Codebehind="QueryBuilder.ascx.cs" Inherits="SplendidCRM.Reports.QueryBuilder" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="SplendidCRM" Tagname="DatePicker" Src="~/_controls/DatePicker.ascx" %>
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
	<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />

	<script type="text/javascript">
	function SelectWizardTab(key)
	{
		for ( var i = 1; i <= 2; i++ )
		{
			var sListClass = '';
			var sLinkClass = '';
			var sListStyle = 'none';

			if ( key == i )
			{
				sListClass = 'active' ;
				sLinkClass = 'current';
				sListStyle = 'block'  ;
			}
			try
			{
				document.getElementById('liReportWizard'   + i).className     = sListClass;
				document.getElementById('linkReportWizard' + i).className     = sLinkClass;
				document.getElementById('divReportWizard'  + i).style.display = sListStyle;
			}
			catch(e)
			{
			}
		}
		document.getElementById('<%= txtACTIVE_TAB.ClientID %>').value = key;
	}
	</script>

	<input id="txtACTIVE_TAB" type="hidden" runat="server" />
	<ul class="tablist" visible='<%# bUseSQLParameters %>' runat="server">
		<li id="liReportWizard1" class="<%= txtACTIVE_TAB.Value == "1" ? "active" : "" %>"><a id="linkReportWizard1" href="javascript:SelectWizardTab(1);" class="<%= txtACTIVE_TAB.Value == "1" ? "current" : "" %>"><%= L10n.Term("Reports.LBL_TABS_FILTERS") %></a></li>
		<li id="liReportWizard2" class="<%= txtACTIVE_TAB.Value == "2" ? "active" : "" %>"><a id="linkReportWizard2" href="javascript:SelectWizardTab(2);" class="<%= txtACTIVE_TAB.Value == "2" ? "current" : "" %>"><%= bDesignChart ? L10n.Term("Charts.LBL_TABS_CHART_TYPE") : L10n.Term("Reports.LBL_TABS_COLUMNS") %></a></li>
	</ul>
	<div id="divReportWizard1" style="DISPLAY:<%= txtACTIVE_TAB.Value == "1" ? "block" : "none" %>">
		<asp:Table SkinID="tabForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<asp:Table BorderWidth="0" CellSpacing="0" CellPadding="0" runat="server">
						<asp:TableRow ID="trModule">
							<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Reports.LBL_MODULE_NAME") %>' runat="server" /></asp:TableCell>
							<asp:TableCell Width="35%" CssClass="dataField">
								<asp:DropDownList ID="lstMODULE" TabIndex="1" DataValueField="MODULE_NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="lstMODULE_Changed" AutoPostBack="true" Runat="server" />
								<asp:Label ID="lblMODULE" runat="server" />
							</asp:TableCell>
						</asp:TableRow>
						<asp:TableRow ID="trRelated" Visible="false" runat="server">
							<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Reports.LBL_RELATED") %>' runat="server" /></asp:TableCell>
							<asp:TableCell Width="35%" CssClass="dataField">
								<asp:DropDownList ID="lstRELATED" TabIndex="3" DataValueField="MODULE_NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="lstRELATED_Changed" AutoPostBack="true" Runat="server" />
								<asp:Label ID="lblRELATED" runat="server" />
							</asp:TableCell>
						</asp:TableRow>
						<asp:TableRow>
							<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Reports.LBL_FILTERS") %>' runat="server" /></asp:TableCell>
							<asp:TableCell Width="35%" CssClass="dataField">
								<asp:Button ID="btnAddFilter" CommandName="Filters.Add" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term("Reports.LBL_ADD_FILTER_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term("Reports.LBL_ADD_FILTER_BUTTON_LABEL") %>' Runat="server" />
							</asp:TableCell>
							<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Reports.LBL_SHOW_QUERY") %>' runat="server" /></asp:TableCell>
							<asp:TableCell Width="35%" CssClass="dataField"><asp:CheckBox ID="chkSHOW_QUERY" CssClass="checkbox" AutoPostBack="true" runat="server" /></asp:TableCell>
						</asp:TableRow>
					</asp:Table>
				</asp:TableCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell style="padding-top: 5px; padding-bottom: 5px;">
					<asp:DataGrid ID="dgFilters" AutoGenerateColumns="false" CellPadding="3" CellSpacing="0" 
						AllowPaging="false" AllowSorting="false" ShowHeader="true" EnableViewState="true" runat="server">
						<Columns>
							<asp:BoundColumn HeaderText="Module"   DataField="MODULE_NAME" />
							<asp:BoundColumn HeaderText="Field"    DataField="DATA_FIELD"  />
							<asp:BoundColumn HeaderText="Type"     DataField="DATA_TYPE"   />
							<asp:BoundColumn HeaderText="Operator" DataField="OPERATOR"    />
							<asp:BoundColumn HeaderText="Search"   DataField="SEARCH_TEXT" />
							<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Left" ItemStyle-Wrap="false">
								<ItemTemplate>
									<asp:Button ID="btnEditFilter" CommandName="Filters.Edit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_EDIT_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_EDIT_BUTTON_TITLE") %>' Runat="server" />
									&nbsp;
									<asp:Button ID="btnDeleteFilter" CommandName="Filters.Delete" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term("Reports.LBL_REMOVE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term("Reports.LBL_REMOVE_BUTTON_TITLE") %>' Runat="server" />
								</ItemTemplate>
							</asp:TemplateColumn>
						</Columns>
					</asp:DataGrid>
				</asp:TableCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell>
					<input id="txtFILTER_ID" type="hidden" runat="server" />
					<asp:Table SkinID="tabEditView" runat="server">
						<asp:TableRow>
							<asp:TableCell VerticalAlign="top">
								<asp:DropDownList ID="lstFILTER_COLUMN_SOURCE" TabIndex="10" DataValueField="MODULE_NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="lstFILTER_COLUMN_SOURCE_Changed" AutoPostBack="true" Runat="server" /><br />
								<asp:Label ID="lblFILTER_COLUMN_SOURCE" runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top">
								<asp:DropDownList ID="lstFILTER_COLUMN" TabIndex="11" DataValueField="NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="lstFILTER_COLUMN_Changed" AutoPostBack="true" Runat="server" /><br />
								<asp:Label ID="lblFILTER_COLUMN" runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top">
								<asp:DropDownList ID="lstFILTER_OPERATOR" TabIndex="12" DataValueField="NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="lstFILTER_OPERATOR_Changed" AutoPostBack="true" Runat="server" /><br />
								<asp:Label ID="lblFILTER_OPERATOR_TYPE" runat="server" /><asp:Image SkinID="Spacer" Width="4" runat="server" />
								<asp:Label ID="lblFILTER_OPERATOR" runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top" Wrap="false">
								<asp:Table BorderWidth="0" CellSpacing="0" CellPadding="0" runat="server">
									<asp:TableRow>
										<asp:TableCell>
											<input type="hidden" id="txtFILTER_SEARCH_ID" runat="server" />
											<input type="hidden" id="txtFILTER_SEARCH_DATA_TYPE" runat="server" />
											
											<asp:TextBox ID="txtFILTER_SEARCH_TEXT"   runat="server" />
											
											<asp:DropDownList ID="lstFILTER_SEARCH_DROPDOWN" DataValueField="NAME" DataTextField="DISPLAY_NAME" runat="server" />
											<asp:ListBox      ID="lstFILTER_SEARCH_LISTBOX"  DataValueField="NAME" DataTextField="DISPLAY_NAME" SelectionMode="Multiple" runat="server" />
											
											<SplendidCRM:DatePicker ID="ctlFILTER_SEARCH_START_DATE" EnableDateFormat="false" Runat="Server" />
										</asp:TableCell>
										<asp:TableCell>
											<asp:Label ID="lblFILTER_AND_SEPARATOR" Text='<%# L10n.Term("Schedulers.LBL_AND") %>' runat="server" />
										</asp:TableCell>
										<asp:TableCell>
											<SplendidCRM:DatePicker ID="ctlFILTER_SEARCH_END_DATE" EnableDateFormat="false" Runat="Server" />
											
											<asp:TextBox ID="txtFILTER_SEARCH_TEXT2"  runat="server" />
											
											<asp:Button ID="btnFILTER_SEARCH_SELECT" Visible="false" UseSubmitBehavior="false" OnClientClick="SearchPopup(); return false;" CssClass="button" Text='<%# L10n.Term(".LBL_SELECT_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SELECT_BUTTON_TITLE") %>' runat="server" />
										</asp:TableCell>
									</asp:TableRow>
								</asp:Table>
								<asp:Label ID="lblFILTER_ID" runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top">
								<asp:Button CommandName="Filters.Update" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_UPDATE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_UPDATE_BUTTON_TITLE") %>' Runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top">
								<asp:Button CommandName="Filters.Cancel" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_CANCEL_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' Runat="server" />
							</asp:TableCell>
							<asp:TableCell Width="80%"></asp:TableCell>
						</asp:TableRow>
					</asp:Table>
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<div id="divReportWizard2" style="DISPLAY:<%= txtACTIVE_TAB.Value == "2" ? "block" : "none" %>">
		<asp:Table SkinID="tabForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<asp:Table runat="server" border="0" cellspacing="0" cellpadding="0">
						<asp:TableRow>
							<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Reports.LBL_MODULE_NAME") %>' runat="server" /></asp:TableCell>
							<asp:TableCell CssClass="dataField">
								<asp:DropDownList ID="lstMODULE_COLUMN_SOURCE" TabIndex="1" DataValueField="MODULE_NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="lstMODULE_COLUMN_SOURCE_Changed" AutoPostBack="true" Runat="server" />
								<asp:Label ID="lblMODULE_COLUMN_SOURCE" runat="server" />
							</asp:TableCell>
						</asp:TableRow>
					</asp:Table>
					<%@ Register TagPrefix="SplendidCRM" Tagname="Chooser" Src="~/_controls/Chooser.ascx" %>
					<SplendidCRM:Chooser ID="ctlDisplayColumnsChooser" Visible="<%# !bDesignChart %>" ChooserTitle="Reports.LBL_CHOOSE_COLUMNS" LeftTitle="Reports.LBL_DISPLAY_COLUMNS" RightTitle="Reports.LBL_AVAILABLE_COLUMNS" Enabled="true" Runat="Server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
		<asp:Table SkinID="tabForm" Visible="<%# bDesignChart %>" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<asp:Table BorderWidth="0" runat="server">
						<asp:TableRow>
							<asp:TableCell>
								<%-- 05/07/2018 Paul.  Correct to match ReportBuilder 3.0. --%>
								<asp:RadioButton ID="radChartTypeColumn" GroupName="CHART_TYPE" CssClass="radio" AutoPostBack="true" OnCheckedChanged="CHART_TYPE_Changed" runat="server" /><asp:Image SkinID="ChartTypeColumn" runat="server" /><br />
								<%# L10n.Term(".dom_chart_types.Column") %>
							</asp:TableCell>
							<asp:TableCell>
								<asp:RadioButton ID="radChartTypeBar"    GroupName="CHART_TYPE" CssClass="radio" AutoPostBack="true" OnCheckedChanged="CHART_TYPE_Changed" runat="server" /><asp:Image SkinID="ChartTypeBar"    runat="server" /><br />
								<%# L10n.Term(".dom_chart_types.Bar") %>
							</asp:TableCell>
							<asp:TableCell>
								<asp:RadioButton ID="radChartTypeLine"   GroupName="CHART_TYPE" CssClass="radio" AutoPostBack="true" OnCheckedChanged="CHART_TYPE_Changed" runat="server" /><asp:Image SkinID="ChartTypeLine"   runat="server" /><br />
								<%# L10n.Term(".dom_chart_types.Line") %>
							</asp:TableCell>
							<asp:TableCell>
								<asp:RadioButton ID="radChartTypeShape"  GroupName="CHART_TYPE" CssClass="radio" AutoPostBack="true" OnCheckedChanged="CHART_TYPE_Changed" runat="server" /><asp:Image SkinID="ChartTypeShape"  runat="server" /><br />
								<%# L10n.Term(".dom_chart_types.Shape") %>
							</asp:TableCell>
						</asp:TableRow>
					</asp:Table>
				</asp:TableCell>
			</asp:TableRow>
			<asp:TableRow>
				<asp:TableCell>
					<asp:Table BorderWidth="0" runat="server">
						<asp:TableRow>
							<asp:TableCell ColumnSpan="2">
								<asp:Label Text='<%# L10n.Term("Charts.LBL_SERIES") %>' runat="server" />
							</asp:TableCell>
						</asp:TableRow>
						<asp:TableRow>
							<asp:TableCell VerticalAlign="Top">
								<asp:DropDownList ID="lstSERIES_COLUMN"   TabIndex="1" DataValueField="NAME" DataTextField="DISPLAY_NAME" AutoPostBack="true" OnSelectedIndexChanged="lstSERIES_COLUMN_Changed" runat="server" /><br />
								<asp:Label ID="lblSERIES_COLUMN" runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="Top">
								<asp:DropDownList ID="lstSERIES_OPERATOR" TabIndex="1" DataValueField="NAME" DataTextField="DISPLAY_NAME" AutoPostBack="true" OnSelectedIndexChanged="lstSERIES_OPERATOR_Changed" runat="server" /><br />
								<asp:Label ID="lblSERIES_OPERATOR_TYPE" runat="server" /><asp:Image SkinID="Spacer" Width="4" runat="server" />
								<asp:Label ID="lblSERIES_OPERATOR" runat="server" />
							</asp:TableCell>
						</asp:TableRow>
						<asp:TableRow>
							<asp:TableCell ColumnSpan="2">
								<asp:Label Text='<%# L10n.Term("Charts.LBL_CATEGORY") %>' runat="server" />
							</asp:TableCell>
						</asp:TableRow>
						<asp:TableRow>
							<asp:TableCell VerticalAlign="Top">
								<asp:DropDownList ID="lstCATEGORY_COLUMN"   TabIndex="1" DataValueField="NAME" DataTextField="DISPLAY_NAME" AutoPostBack="true" OnSelectedIndexChanged="lstCATEGORY_COLUMN_Changed" runat="server" /><br />
								<asp:Label ID="lblCATEGORY_COLUMN" runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="Top">
								<asp:DropDownList ID="lstCATEGORY_OPERATOR" TabIndex="1" DataValueField="NAME" DataTextField="DISPLAY_NAME" AutoPostBack="true" OnSelectedIndexChanged="lstCATEGORY_OPERATOR_Changed" runat="server" /><br />
								<asp:Label ID="lblCATEGORY_OPERATOR_TYPE" runat="server" /><asp:Image SkinID="Spacer" Width="4" runat="server" />
								<asp:Label ID="lblCATEGORY_OPERATOR" runat="server" />
							</asp:TableCell>
						</asp:TableRow>
					</asp:Table>
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>

	<asp:Literal ID="litREPORT_QUERY" EnableViewState="false" runat="server" />
	<asp:Literal ID="litREPORT_RDL" EnableViewState="false" runat="server" />

<script type="text/javascript">
function MoveLeftToRight(sLeftID, sRightID, bReverse)
{
	var lstLeft  = document.getElementById(sLeftID );
	var lstRight = document.getElementById(sRightID);
	var lstModule = document.getElementById('<%= lstMODULE_COLUMN_SOURCE.ClientID %>');
	var sModuleName = lstModule.options[lstModule.selectedIndex].text;
	for ( i=0; i < lstLeft.options.length ; i++ )
	{
		if ( lstLeft.options[i].selected == true )
		{
			var oOption = document.createElement("OPTION");
			if ( bReverse == 1 )
				oOption.text  = sModuleName + ': ' + lstLeft.options[i].text;
			else if ( lstLeft.options[i].text.indexOf(': ') >= 0 )
				oOption.text  = lstLeft.options[i].text.substring(lstLeft.options[i].text.indexOf(': ')+2);
			else
				oOption.text  = lstLeft.options[i].text;
			oOption.value = lstLeft.options[i].value;
			lstRight.options.add(oOption);
		}
	}
	for ( i=lstLeft.options.length-1; i >= 0  ; i-- )
	{
		if ( lstLeft.options[i].selected == true )
		{
			// 10/11/2006 Paul.  Firefox does not support options.remove(), so just set the option to null. 
			lstLeft.options[i] = null;
		}
	}
	// 08/05/2005 Paul. Don't use the sLeftID & sRightID values as they can be reversed. 
	CopyToHidden('<%= ctlDisplayColumnsChooser.lstLeft.ClientID  %>', '<%= ctlDisplayColumnsChooser.txtLeft.ClientID  %>');
	CopyToHidden('<%= ctlDisplayColumnsChooser.lstRight.ClientID %>', '<%= ctlDisplayColumnsChooser.txtRight.ClientID %>');
}
</script>
</div>


