<%@ Control Language="c#" AutoEventWireup="false" Codebehind="EditView.ascx.cs" Inherits="SplendidCRM.SmsMessages.EditView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="SmsMessages" EnablePrint="false" HelpName="EditView" EnableHelp="true" Runat="Server" />

	<asp:HiddenField ID="txtTO_NUMBER_ID"     runat="server" />
	<asp:HiddenField ID="hidREMOVE_LABEL"     Value='<%# L10n.Term(".LBL_REMOVE") %>' runat="server" />
	<asp:HiddenField ID="hidATTACHMENT_COUNT" Value="0" runat="server" />

	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabEditView" runat="server">
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel">
							<asp:Label Text='<%# L10n.Term("SmsMessages.LBL_FROM_NUMBER") %>' runat="server" />
							<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' EnableViewState="False" Runat="server" />
						</asp:TableCell>
						<asp:TableCell CssClass="dataField">
							<asp:DropDownList ID="MAILBOX_ID" DataValueField="ID" DataTextField="DISPLAY_NAME" TabIndex="0" Runat="server" />&nbsp;
							<SplendidCRM:RequiredFieldValidatorForDropDownList ID="reqMAILBOX_ID" ControlToValidate="MAILBOX_ID" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" Enabled="false" EnableClientScript="false" EnableViewState="false" Runat="server" />
						</asp:TableCell>
						<asp:TableCell CssClass="dataLabel">
							<asp:DropDownList ID="lstPARENT_TYPE" DataValueField="NAME" DataTextField="DISPLAY_NAME" TabIndex="3" onChange=<%# "ClearModuleType('', '" + txtPARENT_ID.ClientID + "', '" + txtPARENT_NAME.ClientID + "', false);" %> Runat="server" />
						</asp:TableCell>
						<asp:TableCell CssClass="dataField" Wrap="false">
							<asp:TextBox ID="txtPARENT_NAME" ReadOnly="True" Runat="server" />
							<asp:HiddenField ID="txtPARENT_ID" runat="server" />&nbsp;
							<asp:Button      ID="btnChangeParent" UseSubmitBehavior="false" OnClientClick=<%# "return ModulePopup(document.getElementById('" + lstPARENT_TYPE.ClientID + "').options[document.getElementById('" + lstPARENT_TYPE.ClientID + "').options.selectedIndex].value, '" + txtPARENT_ID.ClientID + "', '" + txtPARENT_NAME.ClientID + "', null, false, null);" %> Text='<%# L10n.Term(".LBL_SELECT_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SELECT_BUTTON_TITLE") %>' CssClass="button" runat="server" />&nbsp;
							<asp:Button      ID="btnClearParent"  UseSubmitBehavior="false" OnClientClick=<%# "return ClearModuleType('', '" + txtPARENT_ID.ClientID + "', '" + txtPARENT_NAME.ClientID + "', false);" %> Text='<%# L10n.Term(".LBL_CLEAR_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CLEAR_BUTTON_TITLE") %>' CssClass="button" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel">
							<asp:Label Text='<%# L10n.Term("SmsMessages.LBL_TO_NUMBER") %>' runat="server" />
							<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' EnableViewState="False" Runat="server" />
						</asp:TableCell>
						<asp:TableCell CssClass="dataField">
							<asp:TextBox ID="txtTO_NUMBER" TabIndex="0" Columns="30" Runat="server" />&nbsp;
							<asp:Button ID="btnChangeTO"  UseSubmitBehavior="false" OnClientClick=<%# "sChangeContactSmsNUMBER='" + txtTO_NUMBER.ClientID  + "'; sChangeContactSmsNUMBER_ID='" + txtTO_NUMBER_ID.ClientID  + "'; window.open('PopupSmsNumbers.aspx', 'SmsNumbersPopup', '" + SplendidCRM.Crm.Config.PopupWindowOptions() + "'); return false;" %> Text='<%# L10n.Term(".LBL_SELECT_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SELECT_BUTTON_TITLE") %>' CssClass="button" TabIndex="3" runat="server" />&nbsp;
							<asp:RequiredFieldValidator ID="reqTO_NUMBER" ControlToValidate="txtTO_NUMBER" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="20%" CssClass="dataLabel" VerticalAlign="top">
							<asp:Label ID="lblDATE_START" Text='<%# L10n.Term("SmsMessages.LBL_DATE_START") %>' Runat="server" />
						</asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<%@ Register TagPrefix="SplendidCRM" Tagname="DateTimeEdit" Src="~/_controls/DateTimeEdit.ascx" %>
							<SplendidCRM:DateTimeEdit ID="ctlDATE_START" EnableNone="false" Runat="Server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell ColumnSpan="4">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel">
							<asp:Label Text='<%# L10n.Term("SmsMessages.LBL_NAME") %>' runat="server" />
							<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' EnableViewState="False" Runat="server" />
						</asp:TableCell>
						<asp:TableCell CssClass="dataField" ColumnSpan="3">
							<asp:TextBox ID="txtNAME" TabIndex="0" TextMode="MultiLine" Columns="100" Rows="2" Runat="server" />&nbsp;
							<asp:RequiredFieldValidator ID="reqNAME" ControlToValidate="txtNAME" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell ColumnSpan="4">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="Top"><%= L10n.Term("SmsMessages.LBL_ATTACHMENT") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="Top" ColumnSpan="3">
							<asp:Repeater id="ctlTemplateAttachments" runat="server">
								<HeaderTemplate />
								<ItemTemplate>
									<asp:HyperLink Text='<%# DataBinder.Eval(Container.DataItem, "FILENAME") %>' NavigateUrl='<%# "~/Images/EmailImage.aspx?ID=" + Eval("ID") %>' Target="_blank" Runat="server" />
									&nbsp;<asp:ImageButton OnCommand="Page_Command" CommandName="TemplateAttachments.Delete" CommandArgument='<%# Eval("ID") %>' ImageUrl='<%# Session["themeURL"] + "images/delete_inline.gif"  %>' ImageAlign="Middle" runat="server" /><br />
								</ItemTemplate>
								<FooterTemplate />
							</asp:Repeater>
							<asp:Repeater id="ctlAttachments" runat="server">
								<HeaderTemplate />
								<ItemTemplate>
									<asp:HyperLink Text='<%# DataBinder.Eval(Container.DataItem, "FILENAME") %>' NavigateUrl='<%# "~/Images/EmailImage.aspx?ID=" + Eval("ID") %>' Target="_blank" Runat="server" />
									&nbsp;<asp:ImageButton OnCommand="Page_Command" CommandName="Attachments.Delete" CommandArgument='<%# Eval("ID") %>' ImageUrl='<%# Session["themeURL"] + "images/delete_inline.gif"  %>' ImageAlign="Middle" runat="server" /><br />
								</ItemTemplate>
								<FooterTemplate />
							</asp:Repeater>
							<div id="<%= this.ClientID %>_attachments_div"></div>
							<div style="display: none">
								<input id="dummy_email_attachment" type="file" tabindex="0" size="40" runat="server" />
							</div>
							<asp:Button UseSubmitBehavior="false" OnClientClick=<%# "AddFile(\'" + this.ClientID + "\', \'" + hidREMOVE_LABEL.ClientID + "\', \'" + hidATTACHMENT_COUNT.ClientID + "\'); return false;" %> Text='<%# L10n.Term("Emails.LBL_ADD_FILE") %>' CssClass="button" runat="server" />
							<br />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell ColumnSpan="4">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="top"><%= L10n.Term(".LBL_ASSIGNED_TO") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="top">
							<asp:Panel Visible="<%# !SplendidCRM.Crm.Config.enable_dynamic_assignment() %>" runat="server">
								<asp:TextBox ID="ASSIGNED_TO" ReadOnly="True" Runat="server" />
								<asp:HiddenField ID="ASSIGNED_USER_ID" runat="server" />&nbsp;
								<asp:Button      ID="btnChangeAssigned" UseSubmitBehavior="false" OnClientClick=<%# "return ModulePopup('Users', '" + ASSIGNED_USER_ID.ClientID + "', '" + ASSIGNED_TO.ClientID + "', null, false, null);" %> Text='<%# L10n.Term(".LBL_CHANGE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CHANGE_BUTTON_TITLE") %>' CssClass="button" Runat="server" />
							</asp:Panel>
							<%@ Register TagPrefix="SplendidCRM" Tagname="UserSelect" Src="~/_controls/UserSelect.ascx" %>
							<SplendidCRM:UserSelect ID="ctlUserSelect" Visible="<%# SplendidCRM.Crm.Config.enable_dynamic_assignment() %>" Runat="Server" />
						</asp:TableCell>
						<asp:TableCell CssClass="dataLabel" VerticalAlign="top"><div id="divTEAM_LABEL" style="DISPLAY: <%= SplendidCRM.Crm.Config.enable_team_management() ? "INLINE" : "NONE" %>"><%= L10n.Term("Teams.LBL_TEAM") %></div></asp:TableCell>
						<asp:TableCell CssClass="dataField" VerticalAlign="top">
							<asp:Panel Visible="<%# SplendidCRM.Crm.Config.enable_team_management() && !SplendidCRM.Crm.Config.enable_dynamic_teams() %>" runat="server">
								<asp:TextBox     ID="TEAM_NAME"     ReadOnly="True" Runat="server" />
								<asp:HiddenField ID="TEAM_ID"       runat="server" />&nbsp;
								<asp:Button      ID="btnChangeTeam" UseSubmitBehavior="false" OnClientClick=<%# "return ModulePopup('Teams', '" + TEAM_ID.ClientID + "', '" + TEAM_NAME.ClientID + "', null, false, null);" %> Text='<%# L10n.Term(".LBL_CHANGE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CHANGE_BUTTON_TITLE") %>' CssClass="button" runat="server" />
							</asp:Panel>
							<%@ Register TagPrefix="SplendidCRM" Tagname="TeamSelect" Src="~/_controls/TeamSelect.ascx" %>
							<SplendidCRM:TeamSelect ID="ctlTeamSelect" Visible="<%# SplendidCRM.Crm.Config.enable_team_management() && SplendidCRM.Crm.Config.enable_dynamic_teams() %>" Runat="Server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !SplendidDynamic.StackedLayout(this.Page.Theme) && !PrintView %>" ShowRequired="false" Runat="Server" />

	<div id="divEditSubPanel">
		<asp:PlaceHolder ID="plcSubPanel" Runat="server" />
	</div>
</div>

<script type="text/javascript">
//AddFile('<%= this.ClientID %>', '<%= hidREMOVE_LABEL.ClientID %>', '<%= hidATTACHMENT_COUNT.ClientID %>');
</script>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

