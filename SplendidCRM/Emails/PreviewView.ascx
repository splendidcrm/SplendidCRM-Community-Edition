<%@ Control Language="c#" AutoEventWireup="false" Codebehind="PreviewView.ascx.cs" Inherits="SplendidCRM.Emails.PreviewView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divPreviewView">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ModuleHeader" Src="~/_controls/ModuleHeader.ascx" %>
	<SplendidCRM:ModuleHeader ID="ctlModuleHeader" Module="Emails" EnablePrint="true" HelpName="DetailView" EnableHelp="true" Runat="Server" />

	<table ID="tblMain" class="tabDetailView" runat="server">
	</table>
	<table ID="tblAttachments" class="tabDetailView" runat="server">
		<tr>
			<td width="15%" class="tabDetailViewDL" valign="top">
				<%= L10n.Term("Emails.LBL_ATTACHMENTS") %>
			</td>
			<td colspan="3" class="tabDetailViewDF" valign="top">
				<asp:Repeater id="ctlAttachments" runat="server">
					<HeaderTemplate />
					<ItemTemplate>
							<asp:HyperLink NavigateUrl='<%# "~/Notes/Attachment.aspx?ID=" + DataBinder.Eval(Container.DataItem, "NOTE_ATTACHMENT_ID") %>' Target="_blank" Runat="server" >
							<%# DataBinder.Eval(Container.DataItem, "FILENAME") %>
							</asp:HyperLink><br />
					</ItemTemplate>
					<FooterTemplate />
				</asp:Repeater>
			</td>
		</tr>
	</table>

	<script type="text/javascript">
	// 08/26/2010 Paul.  We need to count the visible search panels in JavaScript as we do not have an easy way to get the visible count in the code-behind. 
	var nUnifiedSearchVisibleCount = 0;
	</script>

	<br />
	<p></p>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Visible="<%# !PrintView %>" ShowRequired="true" Runat="Server" />
	<div id="divDetailSubPanel">
		<asp:PlaceHolder ID="plcSubPanel" Runat="server" />
	</div>
	<asp:Label ID="lblNoResults" Text='<%# L10n.Term(".LBL_EMAIL_SEARCH_NO_RESULTS") %>' CssClass="error" style="display:none" Runat="server" />
	<script type="text/javascript">
	if ( nUnifiedSearchVisibleCount == 0 )
	{
		var lblNoResults = document.getElementById('<%# lblNoResults.ClientID %>');
		lblNoResults.style.display = 'inline';
	}
	</script>
	<p></p>
	<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !PrintView %>" ShowRequired="false" Runat="Server" />
</div>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />

