<%@ Page language="c#" UnobtrusiveValidationMode="None" MasterPageFile="~/DefaultView.Master" Codebehind="config.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Administration.EmailMan.Config" %>
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
<%-- 09/24/2020 Paul.  Using .NET 4.5 or higher causes an error.  Disable on pages generating the error and possibly web.config. 
WebForms UnobtrusiveValidationMode requires a ScriptResourceMapping for 'jquery'. Please add a ScriptResourceMapping named jquery(case-sensitive).
https://stackoverflow.com/questions/16660900/webforms-unobtrusivevalidationmode-requires-a-scriptresourcemapping-for-jquery
--%>
<asp:Content ID="cntSidebar" ContentPlaceHolderID="cntSidebar" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="Shortcuts" Src="~/_controls/Shortcuts.ascx" %>
	<SplendidCRM:Shortcuts ID="ctlShortcuts" SubMenu="EmailMan" Runat="Server" />
</asp:Content>

<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ConfigView" Src="ConfigView.ascx" %>
	<SplendidCRM:ConfigView ID="ctlConfigView" Runat="Server" />
	<asp:Label ID="lblAccessError" Text='<%# L10n.Term(".LBL_UNAUTH_ADMIN") %>' Visible='<%# !ctlConfigView.Visible %>' Runat="Server" CssClass="error" EnableViewState="false" />
	<br />
</asp:Content>

