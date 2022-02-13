<%@ Control CodeBehind="EditView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.BusinessRules.EditView" %>
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
function AppendConditionVariable(sID, sValue, sCsType)
{
	var fld = document.getElementById(sID);
	if ( fld != undefined )
	{
		switch ( sCsType )
		{
			case 'Guid'      :  fld.value += 'this.GetDynamicControl("' + sValue + '").ID '          ;  break;
			case 'short'     :  fld.value += 'this.GetDynamicControl("' + sValue + '").IntegerValue ';  break;
			case 'Int32'     :  fld.value += 'this.GetDynamicControl("' + sValue + '").IntegerValue ';  break;
			case 'Int16'     :  fld.value += 'this.GetDynamicControl("' + sValue + '").IntegerValue ';  break;
			case 'Int64'     :  fld.value += 'this.GetDynamicControl("' + sValue + '").IntegerValue ';  break;
			case 'float'     :  fld.value += 'this.GetDynamicControl("' + sValue + '").FloatValue '  ;  break;
			case 'decimal'   :  fld.value += 'this.GetDynamicControl("' + sValue + '").DecimalValue ';  break;
			case 'bool'      :  fld.value += 'this.GetDynamicControl("' + sValue + '").Checked '     ;  break;
			case 'ansistring':  fld.value += 'this.GetDynamicControl("' + sValue + '").Text '        ;  break;
			case 'string'    :  fld.value += 'this.GetDynamicControl("' + sValue + '").Text '        ;  break;
			case 'DateTime'  :  fld.value += 'this.GetDynamicControl("' + sValue + '").DateValue '   ;  break;
			case 'byte[]'    :  fld.value += 'this.GetDynamicControl("' + sValue + '").Text '        ;  break;
			default          :  fld.value += 'this.GetDynamicControl("' + sValue + '").Text '        ;  break;
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
</script>
<div id="divEditView" runat="server">
	<asp:UpdatePanel UpdateMode="Conditional" runat="server">
		<ContentTemplate>
			<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
			<%-- 03/16/2016 Paul.  HeaderButtons must be inside UpdatePanel in order to display errors. --%>
			<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
			<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="BusinessRules" Title=".moduleList.Home" EnablePrint="false" HelpName="EditView" EnableHelp="true" Visible="<%# ShowHeader %>" Runat="Server" />

			<asp:Table SkinID="tabForm" runat="server">
				<asp:TableRow>
					<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Rules.LBL_NAME") %>' runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /></asp:TableCell>
					<asp:TableCell Width="35%" CssClass="dataField">
						<asp:TextBox ID="txtNAME" TabIndex="2" size="35" MaxLength="150" Runat="server" />
						&nbsp;<asp:RequiredFieldValidator ID="reqNAME" ControlToValidate="txtNAME" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
					</asp:TableCell>
					<asp:TableCell Width="15%" CssClass="dataLabel"></asp:TableCell>
					<asp:TableCell Width="35%" CssClass="dataField"></asp:TableCell>
				</asp:TableRow>
				<asp:TableRow>
					<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Rules.LBL_MODULE_NAME") %>' runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /></asp:TableCell>
					<asp:TableCell Width="35%" CssClass="dataField">
						<asp:DropDownList ID="lstMODULE" TabIndex="1" DataValueField="MODULE_NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="lstMODULE_Changed" AutoPostBack="true" Runat="server" />
						<asp:Label ID="lblMODULE" runat="server" />
					</asp:TableCell>
					<asp:TableCell Width="15%" CssClass="dataLabel"></asp:TableCell>
					<asp:TableCell Width="35%" CssClass="dataField"></asp:TableCell>
				</asp:TableRow>
			</asp:Table>
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
									<ajaxToolkit:HoverMenuExtender TargetControlID="imgConditionSchema" PopupControlID="pnlConditionHover" PopupPosition="Bottom" PopDelay="50" runat="server" />
									<br /><asp:Image ID="imgConditionSchema2" SkinID="Schema" runat="server" />
									<asp:Panel ID="pnlConditionHover2" style="display:none; overflow-x: auto; overflow-y: scroll; height: 350px; border: solid 1px black; background-color: White; color: Black;" runat="server">
										<asp:Repeater id="ctlConditionSchemaRepeater2" runat="server">
											<ItemTemplate>
												<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendRuleVariable(\"" + txtCONDITION.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\", \"" + Sql.ToString(Eval("CsType")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, lstMODULE.SelectedValue, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
											</ItemTemplate>
										</asp:Repeater>
									</asp:Panel>
									<ajaxToolkit:HoverMenuExtender TargetControlID="imgConditionSchema2" PopupControlID="pnlConditionHover2" PopupPosition="Bottom" PopDelay="50" runat="server" />
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
												<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendConditionVariable(\"" + txtTHEN_ACTIONS.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\", \"" + Sql.ToString(Eval("CsType")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, lstMODULE.SelectedValue, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
											</ItemTemplate>
										</asp:Repeater>
									</asp:Panel>
									<ajaxToolkit:HoverMenuExtender TargetControlID="imgThenSchema" PopupControlID="pnlThenHover" PopupPosition="Bottom" PopDelay="50" runat="server" />
									<br /><asp:Image ID="imgThenSchema2" SkinID="Schema" runat="server" />
									<asp:Panel ID="pnlThenHover2" style="display:none; overflow-x: auto; overflow-y: scroll; height: 350px; border: solid 1px black; background-color: White; color: Black;" runat="server">
										<asp:Repeater id="ctlThenSchemaRepeater2" runat="server">
											<ItemTemplate>
												<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendRuleVariable(\"" + txtTHEN_ACTIONS.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\", \"" + Sql.ToString(Eval("CsType")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, lstMODULE.SelectedValue, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
											</ItemTemplate>
										</asp:Repeater>
									</asp:Panel>
									<ajaxToolkit:HoverMenuExtender TargetControlID="imgThenSchema2" PopupControlID="pnlThenHover2" PopupPosition="Bottom" PopDelay="50" runat="server" />
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
												<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendConditionVariable(\"" + txtELSE_ACTIONS.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\", \"" + Sql.ToString(Eval("CsType")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, lstMODULE.SelectedValue, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
											</ItemTemplate>
										</asp:Repeater>
									</asp:Panel>
									<ajaxToolkit:HoverMenuExtender TargetControlID="imgElseSchema" PopupControlID="pnlElseHover" PopupPosition="Bottom" PopDelay="50" runat="server" />
									<br /><asp:Image ID="imgElseSchema2" SkinID="Schema" runat="server" />
									<asp:Panel ID="pnlElseHover2" style="display:none; overflow-x: auto; overflow-y: scroll; height: 350px; border: solid 1px black; background-color: White; color: Black;" runat="server">
										<asp:Repeater id="ctlElseSchemaRepeater2" runat="server">
											<ItemTemplate>
												<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendRuleVariable(\"" + txtELSE_ACTIONS.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\", \"" + Sql.ToString(Eval("CsType")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, lstMODULE.SelectedValue, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
											</ItemTemplate>
										</asp:Repeater>
									</asp:Panel>
									<ajaxToolkit:HoverMenuExtender TargetControlID="imgElseSchema2" PopupControlID="pnlElseHover2" PopupPosition="Bottom" PopDelay="50" runat="server" />
									<br />
								</asp:TableCell>
							</asp:TableRow>
						</asp:Table>
					</asp:TableCell>
				</asp:TableRow>
			</asp:Table>
			<%-- 06/26/2011 Paul.  InlineScript with DumpSQL is causing a JavaScript error in Chrome, Firefox and Safari. --%>
			<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
			<%-- 03/16/2016 Paul.  HeaderButtons must be inside UpdatePanel in order to display errors. --%>
			<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
			<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !SplendidDynamic.StackedLayout(this.Page.Theme) && ShowBottomButtons && !PrintView %>" ShowRequired="false" Runat="Server" />
		</ContentTemplate>
	</asp:UpdatePanel>
</div>
