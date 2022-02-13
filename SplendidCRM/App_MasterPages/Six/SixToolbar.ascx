<%@ Control Language="c#" AutoEventWireup="false" Codebehind="SixToolbar.ascx.cs" Inherits="SplendidCRM.Themes.Six.SixToolbar" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
<div id="divSixToolbar">
	<asp:UpdatePanel UpdateMode="Conditional" runat="server">
		<ContentTemplate>
			<table cellspacing="0" cellpadding="0" border="0" class="<%# L10n.IsLanguageRTL() ? "SixToolbarRTL" : "SixToolbar" %>">
				<tr>
					<td width="45px">
						<script runat="server">
						// 05/08/2010 Paul.  We need an image button at the top be a sink for the ENTER key.
						// This will prevent the first toolbar button from getting selected inadvertantly. 
						</script>
						<asp:ImageButton SkinID="blank" Width="0" Height="0" OnClientClick="return false;" runat="server" />
					</td>
					<td nowrap>
						<asp:PlaceHolder ID="plcSubPanel" runat="server" />
						<asp:HiddenField ID="hidDynamicNewRecord" Value="" runat="server" />
					</td>
					<td align="<%# L10n.IsLanguageRTL() ? "left" : "right" %>" valign="middle">
						<asp:Panel ID="cntUnifiedSearch" runat="server">
							<div id="divUnifiedSearch">
								<script type="text/javascript">
								function UnifiedSearch()
								{
									var frm = document.forms[0];
									// 01/21/2014 Paul.  Need to escape the query value to allow for symbols in the query. 
									var sUrl = '<%= Application["rootURL"] %>Home/UnifiedSearch.aspx?txtUnifiedSearch=' + escape(frm['<%= txtUnifiedSearch.ClientID %>'].value);
									window.location.href = sUrl;
									return false;
								}
								</script>
								<nobr>
								&nbsp;<asp:TextBox ID="txtUnifiedSearch" CssClass="searchField" size="30" Text='<%# Request["txtUnifiedSearch"] %>' runat="server" />
								<asp:ImageButton ID="btnUnifiedSearch" SkinID="searchButton" AlternateText='<%# L10n.Term(".LBL_SEARCH") %>' OnClientClick="return UnifiedSearch();" CssClass="searchButton" runat="server" />
								&nbsp;
								</nobr>
							</div>
						</asp:Panel>
					</td>
				</tr>
			</table>
			<div style="height: 45px; width: 100%"></div>
			<asp:PlaceHolder ID="plcDynamicNewRecords" runat="server" />
		</ContentTemplate>
	</asp:UpdatePanel>
</div>

