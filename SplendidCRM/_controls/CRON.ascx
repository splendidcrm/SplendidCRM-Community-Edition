<%@ Control Language="c#" AutoEventWireup="false" Codebehind="CRON.ascx.cs" Inherits="SplendidCRM._controls.CRON" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<asp:Table CellPadding="0" CellSpacing="0" runat="server">
	<asp:TableRow>
		<asp:TableCell VerticalAlign="Top" style="border-right: solid 1px black; padding-right: 10px; padding-top: 5px;">
			<asp:RadioButtonList ID="radFREQUENCY" DataValueField="NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="radFREQUENCY_SelectedIndexChanged" AutoPostBack="true" CssClass="radio" style="white-space: nowrap;" runat="server" />
		</asp:TableCell>
		<asp:TableCell style="padding-left: 10px;">
			<asp:Table CellPadding="5" CellSpacing="0" runat="server">
				<asp:TableRow>
					<asp:TableCell VerticalAlign="Top">
						<asp:Label ID="lblMINUTES" Text='<%# L10n.Term("Schedulers.LBL_MINS"        ) %>' runat="server" /><br />
						<asp:ListBox ID="lstMINUTES" SelectionMode="Multiple" Rows="4" OnSelectedIndexChanged="lstMINUTES_SelectedIndexChanged" AutoPostBack="true" runat="server" />
					</asp:TableCell>
					<asp:TableCell VerticalAlign="Top">
						<asp:Label ID="lblHOURS" Text='<%# L10n.Term("Schedulers.LBL_HOURS"       ) %>' runat="server" /><br />
						<asp:ListBox ID="lstHOURS" SelectionMode="Multiple" Rows="4" OnSelectedIndexChanged="lstHOURS_SelectedIndexChanged" AutoPostBack="true" runat="server" />
					</asp:TableCell>
					<asp:TableCell VerticalAlign="Top">
						<asp:Label ID="lblDAYOFMONTH" Text='<%# L10n.Term("Schedulers.LBL_DAY_OF_MONTH") %>' runat="server" /><br />
						<asp:ListBox ID="lstDAYOFMONTH" SelectionMode="Multiple" Rows="4" OnSelectedIndexChanged="lstDAYOFMONTH_SelectedIndexChanged" AutoPostBack="true" runat="server" />
					</asp:TableCell>
					<asp:TableCell VerticalAlign="Top">
						<br />
						<asp:CheckBoxList ID="chkDAYOFWEEK" DataValueField="NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="chkDAYOFWEEK_SelectedIndexChanged" RepeatColumns="4" AutoPostBack="true" CssClass="checkbox" RepeatDirection="Horizontal" style="white-space: nowrap; vertical-align: top;" runat="server" />
						<asp:CheckBoxList ID="chkMONTHS"    DataValueField="NAME" DataTextField="DISPLAY_NAME" OnSelectedIndexChanged="chkMONTHS_SelectedIndexChanged"    RepeatColumns="4" AutoPostBack="true" CssClass="checkbox" RepeatDirection="Horizontal" style="white-space: nowrap; vertical-align: top; padding-bottom: 10px;" runat="server" />
					</asp:TableCell>
				</asp:TableRow>
			</asp:Table>
		</asp:TableCell>
	</asp:TableRow>
</asp:Table>

<SplendidCRM:InlineScript runat="server">
<script type="text/javascript">
function ToggleCRONShow()
{
	try
	{
		var chkCRONShow = document.getElementById('<%# chkCRONShow.ClientID %>');
		chkCRONShow.checked = !chkCRONShow.checked;
		toggleDisplay('<%# pnlCRONValue.ClientID  %>');
	}
	catch(e)
	{
		alert(e.message);
	}
}
</script>
</SplendidCRM:InlineScript>
<asp:Table CellPadding="0" CellSpacing="0" runat="server">
	<asp:TableRow>
		<asp:TableCell VerticalAlign="Top" style="padding-right: 5px;">
			<asp:HyperLink NavigateUrl="javascript: ToggleCRONShow();" CssClass="utilsLink" runat="server">
				<asp:Image SkinID="advanced_search" runat="server" />
			</asp:HyperLink>
			<asp:CheckBox ID="chkCRONShow" style="display:none" CssClass="checkbox" runat="server" />
			&nbsp;<asp:Label ID="lblCRON_MESSAGE" Font-Italic="true" runat="server" /><br />
		</asp:TableCell>
	</asp:TableRow>
	<asp:TableRow>
		<asp:TableCell VerticalAlign="Top">
			<asp:Panel ID="pnlCRONValue" style='<%# (chkCRONShow.Checked ? "display:inline" : "display:none") %>' runat="server">
				<asp:Table CellPadding="0" CellSpacing="0" runat="server">
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Schedulers.LBL_MINS"        ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Schedulers.LBL_HOURS"       ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Schedulers.LBL_DAY_OF_MONTH") %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Schedulers.LBL_MONTHS"      ) %>' runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataLabel"><asp:Label Text='<%# L10n.Term("Schedulers.LBL_DAY_OF_WEEK" ) %>' runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="CRON_MINUTES"    Text="0"  size="3" MaxLength="25" OnTextChanged="CRON_Changed" AutoPostBack="true" runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="CRON_HOURS"      Text="23" size="3" MaxLength="25" OnTextChanged="CRON_Changed" AutoPostBack="true" runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="CRON_DAYOFMONTH" Text="*"  size="3" MaxLength="25" OnTextChanged="CRON_Changed" AutoPostBack="true" runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="CRON_MONTHS"     Text="*"  size="3" MaxLength="25" OnTextChanged="CRON_Changed" AutoPostBack="true" runat="server" /></asp:TableCell>
						<asp:TableCell CssClass="dataField"><asp:TextBox ID="CRON_DAYOFWEEK"  Text="*"  size="3" MaxLength="25" OnTextChanged="CRON_Changed" AutoPostBack="true" runat="server" /></asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:Panel>
		</asp:TableCell>
	</asp:TableRow>
</asp:Table>

