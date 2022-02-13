<%@ Control CodeBehind="EditView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.RulesWizard.EditView" %>
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
<script type="text/javascript">
function AppendConditionVariable(sID, sValue, sCsType)
{
	var fld = document.getElementById(sID);
	if ( fld != undefined )
	{
		switch ( sCsType )
		{
			case 'Guid'      :  fld.value += 'this.ToGuid(this["'     + sValue + '"]) ';  break;
			case 'short'     :  fld.value += 'this.ToShort(this["'    + sValue + '"]) ';  break;
			case 'Int32'     :  fld.value += 'this.ToInteger(this["'  + sValue + '"]) ';  break;
			case 'Int16'     :  fld.value += 'this.ToInteger(this["'  + sValue + '"]) ';  break;
			case 'Int64'     :  fld.value += 'this.ToLong(this["'     + sValue + '"]) ';  break;
			case 'float'     :  fld.value += 'this.ToFloat(this["'    + sValue + '"]) ';  break;
			case 'decimal'   :  fld.value += 'this.ToDecimal(this["'  + sValue + '"]) ';  break;
			case 'bool'      :  fld.value += 'this.ToBoolean(this["'  + sValue + '"]) ';  break;
			case 'ansistring':  fld.value += 'this.ToString(this["'   + sValue + '"]) ';  break;
			case 'string'    :  fld.value += 'this.ToString(this["'   + sValue + '"]) ';  break;
			case 'DateTime'  :  fld.value += 'this.ToDateTime(this["' + sValue + '"]) ';  break;
			case 'byte[]'    :  fld.value += 'this.ToBinary(this["'   + sValue + '"]) ';  break;
			default          :  fld.value += 'this.ToString(this["'   + sValue + '"]) ';  break;
		}
	}
}
function AppendRuleVariable(sID, sValue)
{
	var fld = document.getElementById(sID);
	if ( fld != undefined )
	{
		fld.value += 'this["' + sValue + '"] ';
	}
}

// 12/05/2011 Paul.  Changed method name so that it does not conflict with method in QueryBuilder.ascx. 
// 12/05/2011 Paul.  Changed control names from ReportWizard to RulesWizard as well. 
function SelectRulesWizardTab(key)
{
	for ( var i = 1; i <= 4; i++ )
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
		document.getElementById('liRulesWizard'   + i).className     = sListClass;
		document.getElementById('linkRulesWizard' + i).className     = sLinkClass;
		document.getElementById('divRulesWizard'  + i).style.display = sListStyle;
	}
	document.getElementById('<%= txtACTIVE_TAB.ClientID %>').value = key;
}
</script>

	<asp:UpdatePanel UpdateMode="Conditional" runat="server">
		<ContentTemplate>
			<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
			<%-- 03/16/2016 Paul.  HeaderButtons must be inside UpdatePanel in order to display errors. --%>
			<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
			<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="RulesWizard" Title=".moduleList.Home" EnablePrint="false" HelpName="Wizard" EnableHelp="true" Runat="Server" />

			<input id="txtACTIVE_TAB" type="hidden" runat="server" />
			<ul class="tablist">
				<li id="liRulesWizard1" class="<%= txtACTIVE_TAB.Value == "1" ? "active" : "" %>"><a id="linkRulesWizard1" href="javascript:SelectRulesWizardTab(1);" class="<%= txtACTIVE_TAB.Value == "1" ? "current" : "" %>"><%= L10n.Term("RulesWizard.LBL_WIZARD_STEP1") %></a></li>
				<li id="liRulesWizard2" class="<%= txtACTIVE_TAB.Value == "2" ? "active" : "" %>"><a id="linkRulesWizard2" href="javascript:SelectRulesWizardTab(2);" class="<%= txtACTIVE_TAB.Value == "2" ? "current" : "" %>"><%= L10n.Term("RulesWizard.LBL_WIZARD_STEP2") %></a></li>
				<li id="liRulesWizard3" class="<%= txtACTIVE_TAB.Value == "3" ? "active" : "" %>"><a id="linkRulesWizard3" href="javascript:SelectRulesWizardTab(3);" class="<%= txtACTIVE_TAB.Value == "3" ? "current" : "" %>"><%= L10n.Term("RulesWizard.LBL_WIZARD_STEP3") %></a></li>
				<li id="liRulesWizard4" class="<%= txtACTIVE_TAB.Value == "4" ? "active" : "" %>"><a id="linkRulesWizard4" href="javascript:SelectRulesWizardTab(4);" class="<%= txtACTIVE_TAB.Value == "4" ? "current" : "" %>"><%= L10n.Term("RulesWizard.LBL_WIZARD_STEP4") %></a></li>
			</ul>
			<asp:HiddenField ID="hidCURRENT_MODULE" runat="server" />
			<div id="divRulesWizard1" style="DISPLAY:<%= txtACTIVE_TAB.Value == "1" ? "block" : "none" %>">
				<asp:Table SkinID="tabForm" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Rules.LBL_MODULE_NAME") %>' runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:DropDownList ID="lstMODULE" TabIndex="1" DataValueField="MODULE_NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="lstMODULE_Changed" AutoPostBack="true" Runat="server" />
							<asp:Label ID="lblMODULE" runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Rules.LBL_NAME") %>' runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<asp:TextBox ID="txtNAME" TabIndex="2" size="35" MaxLength="150" Runat="server" />
							&nbsp;<asp:RequiredFieldValidator ID="reqNAME" ControlToValidate="txtNAME" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell VerticalAlign="Top" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Teams.LBL_TEAM") %>' Visible="<%# SplendidCRM.Crm.Config.enable_team_management() %>" runat="server" /></asp:TableCell>
						<asp:TableCell VerticalAlign="Top" CssClass="dataField">
							<asp:Panel Visible="<%# SplendidCRM.Crm.Config.enable_team_management() && !SplendidCRM.Crm.Config.enable_dynamic_teams() %>" runat="server">
								<asp:TextBox     ID="TEAM_NAME"     ReadOnly="True" Runat="server" />
								<asp:HiddenField ID="TEAM_ID"       runat="server" />&nbsp;
								<asp:Button      ID="btnChangeTeam" UseSubmitBehavior="false" OnClientClick=<%# "return ModulePopup('Teams', '" + TEAM_ID.ClientID + "', '" + TEAM_NAME.ClientID + "', null, false, null);" %> Text='<%# L10n.Term(".LBL_CHANGE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CHANGE_BUTTON_TITLE") %>' CssClass="button" runat="server" />
							</asp:Panel>
							<%@ Register TagPrefix="SplendidCRM" Tagname="TeamSelect" Src="~/_controls/TeamSelect.ascx" %>
							<SplendidCRM:TeamSelect ID="ctlTeamSelect" Visible="<%# SplendidCRM.Crm.Config.enable_team_management() && SplendidCRM.Crm.Config.enable_dynamic_teams() %>" Runat="Server" />
						</asp:TableCell>
						<asp:TableCell VerticalAlign="Top" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term(".LBL_ASSIGNED_USER_ID") %>' runat="server" /></asp:TableCell>
						<asp:TableCell VerticalAlign="Top" CssClass="dataField">
							<asp:TextBox ID="txtASSIGNED_TO" ReadOnly="True" Runat="server" />
							<input ID="txtASSIGNED_USER_ID" type="hidden" runat="server" />
							<input ID="btnChangeUser" type="button" CssClass="button" onclick="return ModulePopup('Users', '<%= txtASSIGNED_USER_ID.ClientID %>', '<%= txtASSIGNED_TO.ClientID %>', 'ClearDisabled=1', true, null);" title="<%# L10n.Term(".LBL_CHANGE_BUTTON_TITLE") %>" AccessKey="<%# L10n.AccessKey(".LBL_CHANGE_BUTTON_KEY") %>" value="<%# L10n.Term(".LBL_CHANGE_BUTTON_LABEL") %>" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</div>
			<div id="divRulesWizard2" style="DISPLAY:<%= txtACTIVE_TAB.Value == "2" ? "block" : "none" %>">
				<%@ Register TagPrefix="SplendidCRM" Tagname="QueryBuilder" Src="~/Reports/QueryBuilder.ascx" %>
				<SplendidCRM:QueryBuilder ID="ctlQueryBuilder" UserSpecific="false" ShowRelated="true" PrimaryKeyOnly="true" ShowModule="true" Runat="Server" />
				<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
				</SplendidCRM:SplendidGrid>
			</div>
			<div id="divRulesWizard3" style="DISPLAY:<%= txtACTIVE_TAB.Value == "3" ? "block" : "none" %>">
				<asp:Table SkinID="tabForm" runat="server">
					<asp:TableRow>
						<asp:TableCell style="padding-top: 5px; padding-bottom: 5px;">
							<asp:DataGrid ID="dgRules" AutoGenerateColumns="false" CellPadding="3" CellSpacing="0" 
								AllowPaging="false" AllowSorting="false" ShowHeader="true" EnableViewState="true" runat="server">
								<Columns>
									<asp:BoundColumn HeaderText="Rules.LBL_LIST_ID"           DataField="ID"           Visible="false" />
									<asp:BoundColumn HeaderText="Rules.LBL_LIST_RULE_NAME"    DataField="RULE_NAME"    Visible="false" />
									<asp:BoundColumn HeaderText="Rules.LBL_LIST_PRIORITY"     DataField="PRIORITY"     />
									<asp:BoundColumn HeaderText="Rules.LBL_LIST_REEVALUATION" DataField="REEVALUATION" Visible="false" />
									<asp:BoundColumn HeaderText="Rules.LBL_LIST_ACTIVE"       DataField="ACTIVE"       />
									<asp:BoundColumn HeaderText="Rules.LBL_LIST_CONDITION"    DataField="CONDITION"    />
									<asp:BoundColumn HeaderText="Rules.LBL_LIST_THEN_ACTIONS" DataField="THEN_ACTIONS" />
									<asp:BoundColumn HeaderText="Rules.LBL_LIST_ELSE_ACTIONS" DataField="ELSE_ACTIONS" />
									<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Left" ItemStyle-Wrap="false">
										<ItemTemplate>
											<asp:Button ID="btnEditFilter" CommandName="Rules.Edit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_EDIT_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_EDIT_BUTTON_TITLE") %>' Runat="server" />
											&nbsp;
											<asp:Button ID="btnDeleteFilter" CommandName="Rules.Delete" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term("Rules.LBL_REMOVE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term("Rules.LBL_REMOVE_BUTTON_TITLE") %>' Runat="server" />
										</ItemTemplate>
									</asp:TemplateColumn>
								</Columns>
							</asp:DataGrid>
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
				<asp:Table SkinID="tabForm" runat="server">
					<asp:TableRow>
						<asp:TableCell>
							<asp:HiddenField ID="txtRULE_ID" runat="server" />
							<asp:Table SkinID="tabEditView" runat="server">
								<asp:TableRow>
									<asp:TableCell VerticalAlign="top" Visible="false">
										<asp:Label Text='<%# L10n.Term("Rules.LBL_RULE_NAME") %>' CssClass="dataLabel" runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /><br />
										<asp:TextBox      ID="txtRULE_NAME"    TabIndex="10" Columns="40" Runat="server" />
										&nbsp;<asp:RequiredFieldValidator ID="reqRULE_NAME" ControlToValidate="txtRULE_NAME" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Display="dynamic" Runat="server" />
									</asp:TableCell>
									<asp:TableCell VerticalAlign="top">
										<asp:Label Text='<%# L10n.Term("Rules.LBL_PRIORITY") %>' CssClass="dataLabel" runat="server" /><br />
										<asp:TextBox      ID="txtPRIORITY"     TabIndex="11" Columns="10" Runat="server" />
									</asp:TableCell>
									<asp:TableCell VerticalAlign="top" Visible="false">
										<asp:Label Text='<%# L10n.Term("Rules.LBL_REEVALUATION") %>' CssClass="dataLabel" runat="server" /><br />
										<script runat="server">
											// 10/25/2010 Paul.  You have to be careful with Reevaluation Always as it will re-evaluate 
											// after the Then or Else actions to see if it needs to be run again. This can cause an endless loop. 
										</script>
										<asp:DropDownList ID="lstREEVALUATION" TabIndex="12" DataValueField="NAME" DataTextField="DISPLAY_NAME" Enabled="false" Runat="server" />
									</asp:TableCell>
									<asp:TableCell VerticalAlign="top">
										<asp:Label Text='<%# L10n.Term("Rules.LBL_ACTIVE") %>' CssClass="dataLabel" runat="server" /><br />
										<asp:CheckBox     ID="chkACTIVE"       TabIndex="13" CssClass="checkbox" Checked="true" Runat="server" />
									</asp:TableCell>
									<asp:TableCell VerticalAlign="top">
										<br />
										<asp:Button CommandName="Rules.Update" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_UPDATE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_UPDATE_BUTTON_TITLE") %>' Runat="server" />
									</asp:TableCell>
									<asp:TableCell VerticalAlign="top">
										<br />
										<asp:Button CommandName="Rules.Cancel" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_CANCEL_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' Runat="server" />
									</asp:TableCell>
									<asp:TableCell Width="80%"></asp:TableCell>
								</asp:TableRow>
								<asp:TableRow>
									<asp:TableCell VerticalAlign="top" ColumnSpan="4">
										<asp:Label Text='<%# L10n.Term("Rules.LBL_CONDITION") %>' CssClass="dataLabel" runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /><br />
										<asp:TextBox      ID="txtCONDITION"    TabIndex="14" TextMode="MultiLine" Rows="2" Columns="140" Runat="server" />
									</asp:TableCell>
									<asp:TableCell VerticalAlign="top" ColumnSpan="2">
										<br /><asp:Image ID="imgConditionSchema" SkinID="Schema" runat="server" />
										<asp:Panel ID="pnlConditionHover" style="display:none; overflow-x: auto; overflow-y: scroll; height: 350px; border: solid 1px black; background-color: White; color: Black;" runat="server">
											<asp:Repeater id="ctlConditionSchemaRepeater" runat="server">
												<ItemTemplate>
													<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendConditionVariable(\"" + txtCONDITION.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\", \"" + Sql.ToString(Eval("CsType")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, lstMODULE.SelectedValue, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
												</ItemTemplate>
											</asp:Repeater>
										</asp:Panel>
										<ajaxToolkit:HoverMenuExtender ID="hovCondition" TargetControlID="imgConditionSchema" PopupControlID="pnlConditionHover" PopupPosition="Bottom" PopDelay="50" runat="server" />
										<br />&nbsp;<asp:RequiredFieldValidator ID="reqCONDITION" ControlToValidate="txtCONDITION" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Display="dynamic" Runat="server" />
									</asp:TableCell>
								</asp:TableRow>
								<asp:TableRow>
									<asp:TableCell VerticalAlign="top" ColumnSpan="4">
										<asp:Label Text='<%# L10n.Term("Rules.LBL_THEN_ACTIONS") %>' CssClass="dataLabel" runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /><br />
										<asp:TextBox      ID="txtTHEN_ACTIONS" TabIndex="15" TextMode="MultiLine" Rows="3" Columns="140" Runat="server" />
									</asp:TableCell>
									<asp:TableCell VerticalAlign="top" ColumnSpan="2">
										<br /><asp:Image ID="imgThenSchema" SkinID="Schema" runat="server" />
										<asp:Panel ID="pnlThenHover" style="display:none; overflow-x: auto; overflow-y: scroll; height: 350px; border: solid 1px black; background-color: White; color: Black;" runat="server">
											<asp:Repeater id="ctlThenSchemaRepeater" runat="server">
												<ItemTemplate>
													<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendRuleVariable(\"" + txtTHEN_ACTIONS.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, lstMODULE.SelectedValue, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
												</ItemTemplate>
											</asp:Repeater>
										</asp:Panel>
										<ajaxToolkit:HoverMenuExtender TargetControlID="imgThenSchema" PopupControlID="pnlThenHover" PopupPosition="Bottom" PopDelay="50" runat="server" />
										<br />&nbsp;<asp:RequiredFieldValidator ID="reqTHEN_ACTIONS" ControlToValidate="txtTHEN_ACTIONS" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Display="dynamic" Runat="server" />
									</asp:TableCell>
								</asp:TableRow>
								<asp:TableRow>
									<asp:TableCell VerticalAlign="top" ColumnSpan="4">
										<asp:Label Text='<%# L10n.Term("Rules.LBL_ELSE_ACTIONS") %>' CssClass="dataLabel" runat="server" /><br />
										<asp:TextBox      ID="txtELSE_ACTIONS" TabIndex="16" TextMode="MultiLine" Rows="3" Columns="140" Runat="server" />
									</asp:TableCell>
									<asp:TableCell VerticalAlign="top" ColumnSpan="2">
										<br /><asp:Image ID="imgElseSchema" SkinID="Schema" runat="server" />
										<asp:Panel ID="pnlElseHover" style="display:none; overflow-x: auto; overflow-y: scroll; height: 350px; border: solid 1px black; background-color: White; color: Black;" runat="server">
											<asp:Repeater id="ctlElseSchemaRepeater" runat="server">
												<ItemTemplate>
													<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendRuleVariable(\"" + txtELSE_ACTIONS.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, lstMODULE.SelectedValue, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
												</ItemTemplate>
											</asp:Repeater>
										</asp:Panel>
										<ajaxToolkit:HoverMenuExtender TargetControlID="imgElseSchema" PopupControlID="pnlElseHover" PopupPosition="Bottom" PopDelay="50" runat="server" />
										<br />
									</asp:TableCell>
								</asp:TableRow>
							</asp:Table>
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</div>
			<div id="divRulesWizard4" style="DISPLAY:<%= txtACTIVE_TAB.Value == "4" ? "block" : "none" %>">
				<asp:Label ID="lblStatus"         Font-Bold="true" runat="server" /><br />
				<asp:Label ID="lblSuccessCount"   runat="server" /><br />
				<asp:Label ID="lblFailedCount"    runat="server" /><br />
				<br />
				<%= L10n.Term("RulesWizard.LBL_USE_TRANSACTION") %><asp:CheckBox ID="chkUseTransaction" Checked="True" CssClass="checkbox" runat="server" />
				<br />
				<SplendidCRM:SplendidGrid id="grdResults" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
					<Columns>
						<asp:BoundColumn HeaderText="RulesWizard.LBL_LIST_IMPORT_ROW_NUMBER" DataField="IMPORT_ROW_NUMBER"  SortExpression="IMPORT_ROW_NUMBER" />
						<asp:BoundColumn HeaderText="RulesWizard.LBL_LIST_IMPORT_ROW_STATUS" DataField="IMPORT_ROW_STATUS"  SortExpression="IMPORT_ROW_STATUS" />
						<asp:BoundColumn HeaderText="RulesWizard.LBL_LIST_IMPORT_ROW_ERROR"  DataField="IMPORT_ROW_ERROR"   SortExpression="IMPORT_ROW_ERROR"  />
					</Columns>
				</SplendidCRM:SplendidGrid>
			</div>
			<!-- 06/26/2011 Paul.  InlineScript with DumpSQL is causing a JavaScript error in Chrome, Firefox and Safari. -->
		</ContentTemplate>
	</asp:UpdatePanel>
</div>
