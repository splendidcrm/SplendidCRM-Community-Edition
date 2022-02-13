<%@ Control Language="c#" AutoEventWireup="false" Codebehind="LayoutButtons.ascx.cs" Inherits="SplendidCRM.Administration.DynamicLayout._controls.LayoutButtons" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
// 07/14/2010 Paul.  We need to use InlineScript because this user control is inside an UpdatePanel 
// and the JavaScript needs to be registered when made visible. 
</script>
<SplendidCRM:InlineScript runat="server">
	<script type="text/javascript">
	function ExportSQL()
	{
			return window.open('export.aspx?NAME=<%= sVIEW_NAME %>','ExportSQL','width=1200,height=600,resizable=1,scrollbars=1');
	}
	</script>
</SplendidCRM:InlineScript>
<asp:Table Width="100%" CellPadding="0" CellSpacing="0" style="padding-bottom: 2px;" CssClass="button-panel" runat="server">
	<asp:TableRow>
		<asp:TableCell HorizontalAlign="Left">
			<asp:Button   ID="btnSave"       CommandName="Save"        OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term(".LBL_SAVE_BUTTON_LABEL"             ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_SAVE_BUTTON_TITLE"             ) %>' Runat="server" />
			<asp:Button   ID="btnCancel"     CommandName="Cancel"      OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term(".LBL_CANCEL_BUTTON_LABEL"           ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE"           ) %>' Runat="server" />
			<asp:Button   ID="btnNew"        CommandName="New"         OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term(".LBL_NEW_BUTTON_LABEL"              ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_NEW_BUTTON_TITLE"              ) %>' Runat="server" />
			<asp:Button   ID="btnCopyLayout" CommandName="Layout.Copy" OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term("DynamicLayout.LBL_COPY_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term("DynamicLayout.LBL_COPY_BUTTON_TITLE") %>' Runat="server" />
			<asp:TextBox  ID="txtCopyLayout" Visible="false" Width="200"                                          style="margin-right: 3px;" Runat="server" />
			<asp:Button   ID="btnDefaults"   CommandName="Defaults"    OnCommand="Page_Command" CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term(".LBL_DEFAULTS_BUTTON_LABEL"         ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_DEFAULTS_BUTTON_TITLE"         ) %>' Runat="server" />
			<asp:Button   ID="btnExport"     OnClientClick="ExportSQL(); return false;"         CssClass="button" style="margin-right: 3px;" Text='<%# "  " + L10n.Term(".LBL_EXPORT_BUTTON_LABEL"           ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_EXPORT_BUTTON_TITLE"           ) %>' UseSubmitBehavior="false" Runat="server" />
			<asp:Checkbox ID="chkPreview"    Text='<%# L10n.Term("DynamicLayout.LBL_PREVIEW") %>' OnCheckedChanged="chkPreview_CheckedChanged" CssClass="checkbox" AutoPostBack="true" runat="server" />
			<asp:HiddenField ID="hidPreviousPreview" runat="server" />
			<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
		</asp:TableCell>
		<asp:TableCell HorizontalAlign="Right" Wrap="false">
			<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" />
			&nbsp;
			<asp:Label Text='<%# L10n.Term(".NTC_REQUIRED") %>' runat="server" />
		</asp:TableCell>
	</asp:TableRow>
</asp:Table>

