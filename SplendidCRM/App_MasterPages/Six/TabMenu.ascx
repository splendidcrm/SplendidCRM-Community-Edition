<%@ Control Language="c#" AutoEventWireup="false" Codebehind="TabMenu.ascx.cs" Inherits="SplendidCRM.Themes.Six.TabMenu" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
<div id="divTabMenu">
	<table ID="tblSixMenu" class="tabFrame" cellspacing="0" cellpadding="0" runat="server" />
	<asp:Panel ID="pnlTabMenuMore" style="display: none;" runat="server">
		<table cellpadding="0" cellspacing="0" class="MoreActionsShadingTable">
			<tr>
				<td colspan="3" class="ModuleActionsShadingHorizontal"></td>
			</tr>
			<tr>
				<td class="ModuleActionsShadingVertical"></td>
				<td>
					<table cellpadding="0" cellspacing="0" class="ModuleActionsInnerTable">
						<tr>
							<td class="ModuleActionsInnerCell"><asp:PlaceHolder ID="phMoreInnerCell" runat="server" /></td>
						</tr>
					</table>
				</td>
				<td class="ModuleActionsShadingVertical"></td>
			</tr>
			<tr>
				<td colspan="3" class="ModuleActionsShadingHorizontal"></td>
			</tr>
		</table>
	</asp:Panel>
	<asp:PlaceHolder ID="phHoverControls" runat="server" />
	<%@ Register TagPrefix="SplendidCRM" Tagname="Actions" Src="../Sugar/Actions.ascx" %>
	<SplendidCRM:Actions ID="ctlActions" Visible='<%# !PrintView && SplendidCRM.Utils.SupportsTouch %>' Runat="Server" />
</div>

