<%@ Control Language="c#" AutoEventWireup="false" Codebehind="DatePicker.ascx.cs" Inherits="SplendidCRM._controls.DatePicker" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
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
// 08/12/2014 Paul.  Add format to calendar. 
</script>
<script type="text/javascript">
function datechanged(x)
{
	alert(x);
}
</script>
<asp:Table BorderWidth="0" CellPadding="0" CellSpacing="0" runat="server">
	<asp:TableRow>
		<asp:TableCell Wrap="false">
			<asp:TextBox ID="txtDATE" size="11" MaxLength="40" Runat="server" />
			<ajaxToolkit:CalendarExtender ID="extDATE" TargetControlID="txtDATE" PopupButtonID="imgCalendar" Animated="false" Format="<%# System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.ShortDatePattern %>" runat="server" />
			&nbsp;<asp:Image ID="imgCalendar" AlternateText='<%# L10n.Term(".LBL_ENTER_DATE") %>' SkinID="Calendar" Runat="server" />
			&nbsp;
			<asp:Label ID="lblDateFormat" CssClass="dateFormat" Text="<%# System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.ShortDatePattern.ToUpper() %>" Visible="<%# ShowDateFormat %>" runat="server" />
			<!-- 08/31/2006 Paul.  We cannot use a regular expression validator because there are just too many date formats. -->
			<SplendidCRM:DateValidator  ID="valDATE" ControlToValidate="txtDATE" CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Display="dynamic" Runat="server" />
			<asp:RequiredFieldValidator ID="reqDATE" ControlToValidate="txtDATE" CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Display="dynamic" Runat="server" />
		</asp:TableCell>
	</asp:TableRow>
</asp:Table>

