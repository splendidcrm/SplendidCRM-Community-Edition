<%@ Page language="c#" MasterPageFile="~/DefaultView.Master" Codebehind="SetTimezone.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Users.SetTimezone" %>
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
<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
<script type="text/javascript">
function SetBrowserDefaultTimezone()
{
	var lstTIMEZONE  = document.getElementById('<%= lstTIMEZONE.ClientID %>');
	if ( lstTIMEZONE != null )
	{
		if ( lstTIMEZONE.options.selectedIndex == 0 )
		{
			var dtJanuary = new Date((new Date()).getFullYear(), 0, 1, 0, 0, 0);
			
			var sDefaultOffset;
			if ( dtJanuary.getTimezoneOffset() > 0 )
				sDefaultOffset = '(GMT-' + ('0' +    dtJanuary.getTimezoneOffset()/60 + ':00').substring(0, 5) + ')';
			else
				sDefaultOffset = '(GMT+' + ('0' + -1*dtJanuary.getTimezoneOffset()/60 + ':00').substring(0, 5) + ')';

			for ( i = 0; i < lstTIMEZONE.options.length; i++ )
			{
				if ( lstTIMEZONE.options[i].text.substring(0, sDefaultOffset.length) == sDefaultOffset )
				{
					lstTIMEZONE.options.selectedIndex = i;
					break;
				}
			}
		}
	}
}
</script>
	<asp:Panel CssClass="button-panel" Visible="<%# !PrintView %>" runat="server">
		<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />
	</asp:Panel>
	
	
	<asp:Table Width="400" BorderWidth="1" BorderColor="#444444" CellPadding="8" CellSpacing="2" HorizontalAlign="Center" CssClass="" runat="server">
		<asp:TableRow>
			<asp:TableCell />
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell style="padding-bottom: 5px;">
				<asp:Label Text='<%# L10n.Term("Users.LBL_PICK_TZ_WELCOME") %>' runat="server" />
				<br />
				<br />
				<asp:Label Text='<%# L10n.Term("Users.LBL_PICK_TZ_DESCRIPTION") %>' runat="server" />
				<br />
				<br />
				<asp:DropDownList ID="lstTIMEZONE" DataValueField="ID" DataTextField="NAME" TabIndex="3" Runat="server" />
				&nbsp;<asp:Button ID="btnSave" CommandName="Save" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term(".LBL_SAVE_BUTTON_LABEL"  ) + "  " %>' ToolTip='<%# L10n.Term(".LBL_SAVE_BUTTON_TITLE"  ) %>' AccessKey='<%# L10n.AccessKey(".LBL_SAVE_BUTTON_KEY"  ) %>' Runat="server" /><br />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<br />
	<script type="text/javascript">
		SetBrowserDefaultTimezone();
	</script>
</asp:Content>

