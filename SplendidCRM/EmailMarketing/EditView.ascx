<%@ Control Language="c#" AutoEventWireup="false" Codebehind="EditView.ascx.cs" Inherits="SplendidCRM.EmailMarketing.EditView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<SplendidCRM:InlineScript runat="server">
<script type="text/javascript">
// 09/03/2012 Paul.  Must place within InlineScript to prevent error. The Controls collection cannot be modified because the control contains code blocks (i.e. ).
function EmailTemplatePopup()
{
	var fldCAMPAIGN_ID = document.getElementById('<%= CAMPAIGN_ID.ClientID %>');
	return ModulePopup('EmailTemplates', '<%= new SplendidCRM.DynamicControl(this, "TEMPLATE_ID").ClientID %>', '<%= new SplendidCRM.DynamicControl(this, "TEMPLATE_NAME").ClientID %>', 'CAMPAIGN_ID=' + fldCAMPAIGN_ID.value, false, null);
}
function EmailTemplateEdit()
{
	var fldTEMPLATE_ID = document.getElementById('<%= new SplendidCRM.DynamicControl(this, "TEMPLATE_ID").ClientID %>');
	var fldCAMPAIGN_ID = document.getElementById('<%= CAMPAIGN_ID.ClientID %>');
	return ModulePopup('EmailTemplates', '<%= new SplendidCRM.DynamicControl(this, "TEMPLATE_ID").ClientID %>', '<%= new SplendidCRM.DynamicControl(this, "TEMPLATE_NAME").ClientID %>', 'ID=' + fldTEMPLATE_ID.value + '&CAMPAIGN_ID=' + fldCAMPAIGN_ID.value, false, 'PopupEdit.aspx');
}
</script>
</SplendidCRM:InlineScript>
<div id="divEditView" runat="server">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="EmailMarketing" EnablePrint="false" HelpName="EditView" EnableHelp="true" Runat="Server" />

	<asp:HiddenField ID="LAYOUT_EDIT_VIEW" Runat="server" />
	<asp:HiddenField ID="CAMPAIGN_ID" runat="server" />
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblMain" class="tabEditView" runat="server">
				</table>
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

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

