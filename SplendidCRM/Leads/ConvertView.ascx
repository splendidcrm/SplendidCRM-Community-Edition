<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ConvertView.ascx.cs" Inherits="SplendidCRM.Leads.ConvertView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="Leads" EnablePrint="false" HelpName="ConvertView" EnableHelp="true" Runat="Server" />
	<p></p>

	<asp:HiddenField ID="LAYOUT_EDIT_VIEW" Runat="server" />
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblMain" class="tabEditView" runat="server">
					<tr>
						<th colspan="4"><h4><%= L10n.Term("Leads.LNK_NEW_CONTACT") %></h4></th>
					</tr>
				</table>
				<div id="divCreateContactNoteLink">
					&nbsp;<asp:CheckBox ID="chkCreateNote" CssClass="checkbox" Runat="server" />
					&nbsp;<%= L10n.Term("Leads.LNK_NEW_NOTE") %>
				</div>
				<div id="divCreateContactNote" style="display:<%= chkCreateNote.Checked ? "inline" : "none" %>">
					<p></p>
					<%@ Register TagPrefix="SplendidCRM" Tagname="ConvertViewNote" Src="ConvertViewNote.ascx" %>
					<SplendidCRM:ConvertViewNote ID="ctlConvertViewNote" Runat="Server" />
				</div>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	
	<p></p>
	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabEditView" runat="server">
					<asp:TableRow>
						<asp:TableHeaderCell CssClass="dataLabel">
							<h4 CssClass="dataLabel"><%= L10n.Term(".LBL_RELATED_RECORDS") %></h4>
						</asp:TableHeaderCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell VerticalAlign="top">
							<%@ Register TagPrefix="SplendidCRM" Tagname="ConvertViewAccount" Src="ConvertViewAccount.ascx" %>
							<SplendidCRM:ConvertViewAccount ID="ctlConvertViewAccount" Runat="Server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell VerticalAlign="top">
							<%@ Register TagPrefix="SplendidCRM" Tagname="ConvertViewOpportunity" Src="ConvertViewOpportunity.ascx" %>
							<SplendidCRM:ConvertViewOpportunity ID="ctlConvertViewOpportunity" Runat="Server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell VerticalAlign="top">
							<%@ Register TagPrefix="SplendidCRM" Tagname="ConvertViewAppointment" Src="ConvertViewAppointment.ascx" %>
							<SplendidCRM:ConvertViewAppointment ID="ctlConvertViewAppointment" Runat="Server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

