<%@ Control Language="c#" AutoEventWireup="false" Codebehind="NewRecord.ascx.cs" Inherits="SplendidCRM.ActivityStream.NewRecord" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
<div id="divNewRecord">
	<asp:Panel ID="pnlMain" Width="100%" CssClass="leftColumnModuleS3" runat="server">
		<asp:Table Width="100%" runat="server">
			<asp:TableRow>
				<asp:TableCell style="vertical-align: top; width: 1%;">
					<asp:Image CssClass="ActivityStreamPicture" SkinID="ActivityStreamUser"   Visible='<%#  Sql.IsEmptyString(Security.PICTURE) %>' runat="server" />
					<asp:Image CssClass="ActivityStreamPicture" src='<%# Security.PICTURE %>' Visible='<%# !Sql.IsEmptyString(Security.PICTURE) %>' runat="server" />
				</asp:TableCell>
				<asp:TableCell>
					<asp:Panel ID="pnlEdit" CssClass="" style="margin-bottom: 4px;" Width="100%" runat="server">
						<table ID="tblMain" class="tabEditView" runat="server">
						</table>
					</asp:Panel>
				</asp:TableCell>
				<asp:TableCell style="vertical-align: top; width: 5%; padding: 8px;">
					<asp:Button ID="btnSubmit" CommandName="NewRecord"        OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_SUBMIT_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_SUBMIT_BUTTON_LABEL") %>' Runat="server" /><br />
					<asp:Button ID="btnCancel" CommandName="NewRecord.Cancel" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_CANCEL_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_LABEL") %>' Runat="server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
</div>

