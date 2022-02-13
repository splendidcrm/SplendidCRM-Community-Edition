<%@ Control CodeBehind="ListView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.ChatDashboard.ListView" %>
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
<div id="divListView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlModuleHeader" Module="ChatDashboard" Title="ChatDashboard.LBL_MODULE_NAME" EnableModuleLabel="false" EnablePrint="true" HelpName="index" EnableHelp="true" Runat="Server" />
	
	<%@ Register TagPrefix="SplendidCRM" Tagname="RestUtils" Src="~/_controls/RestUtils.ascx" %>
	<SplendidCRM:RestUtils Runat="Server" />

	<div id="divError" class="error"></div>
	<div id="divMainPageContent">
		<div id="divMainLayoutPanel"></div>
	</div>

	<SplendidCRM:InlineScript runat="server">
		<script type="text/javascript">
var ctlActiveMenu = null;
// 06/24/2017 Paul.  We need a way to turn off bootstrap for BPMN, ReportDesigner and ChatDashboard. 
bDESKTOP_LAYOUT   = true;
sUSER_CHAT_CHANNELS = '<%# sUSER_CHAT_CHANNELS %>';
TERMINOLOGY['Calendar.YearMonthPattern'      ] = '<%# Sql.EscapeJavaScript(DateTimeFormat.YearMonthPattern          ) %>';
TERMINOLOGY['Calendar.MonthDayPattern'       ] = '<%# Sql.EscapeJavaScript(DateTimeFormat.MonthDayPattern           ) %>';
TERMINOLOGY['Calendar.LongDatePattern'       ] = '<%# Sql.EscapeJavaScript(DateTimeFormat.LongDatePattern           ) %>';
TERMINOLOGY['Calendar.FirstDayOfWeek'        ] = '<%# (int) DateTimeFormat.FirstDayOfWeek                             %>';
TERMINOLOGY['ChatMessages.LBL_PARENT_NAME'   ] = '<%# Sql.EscapeJavaScript(L10n.Term("ChatMessages.LBL_PARENT_NAME")) %>';
TERMINOLOGY['ChatMessages.LBL_UPLOAD_FILE'   ] = '<%# Sql.EscapeJavaScript(L10n.Term("ChatMessages.LBL_UPLOAD_FILE")) %>';
TERMINOLOGY['ChatDashboard.LBL_MORE'         ] = '<%# Sql.EscapeJavaScript(L10n.Term("ChatDashboard.LBL_MORE"      )) %>';
TERMINOLOGY['ChatDashboard.LBL_LESS'         ] = '<%# Sql.EscapeJavaScript(L10n.Term("ChatDashboard.LBL_LESS"      )) %>';
TERMINOLOGY['.LBL_SUBMIT_BUTTON_LABEL'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_SUBMIT_BUTTON_LABEL"    )) %>';
TERMINOLOGY['.LBL_SELECT_BUTTON_LABEL'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_SELECT_BUTTON_LABEL"    )) %>';
TERMINOLOGY['.LBL_CLEAR_BUTTON_LABEL'        ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_CLEAR_BUTTON_LABEL"     )) %>';
TERMINOLOGY['.LBL_SEARCH_BUTTON_LABEL'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_SEARCH_BUTTON_LABEL"    )) %>';
TERMINOLOGY['.LBL_CANCEL_BUTTON_LABEL'       ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_CANCEL_BUTTON_LABEL"    )) %>';
TERMINOLOGY['.LBL_LIST_TEAM_SET_NAME'        ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_LIST_TEAM_SET_NAME"     )) %>';
TERMINOLOGY['.LBL_LIST_ASSIGNED_USER'        ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_LIST_ASSIGNED_USER"     )) %>';
// 06/24/2017 Paul.  Teams.LBL_LIST_TEAM is needed for Professional Edition. 
TERMINOLOGY['Teams.LBL_LIST_TEAM'            ] = '<%# Sql.EscapeJavaScript(L10n.Term("Teams.LBL_LIST_TEAM"         )) %>';
// 05/13/2016 Paul.  LBL_TAG_SET_NAME should be global. 
TERMINOLOGY['.LBL_LIST_TAG_SET_NAME'         ] = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_LIST_TAG_SET_NAME"      )) %>';
TERMINOLOGY_LISTS['month_names_dom'          ] = ['<%# String.Join("', '", Sql.EscapeJavaScript(DateTimeFormat.MonthNames           )) %>'];
TERMINOLOGY_LISTS['short_month_names_dom'    ] = ['<%# String.Join("', '", Sql.EscapeJavaScript(DateTimeFormat.AbbreviatedMonthNames)) %>'];
TERMINOLOGY_LISTS['day_names_dom'            ] = ['<%# String.Join("', '", Sql.EscapeJavaScript(DateTimeFormat.DayNames             )) %>'];
TERMINOLOGY_LISTS['short_day_names_dom'      ] = ['<%# String.Join("', '", Sql.EscapeJavaScript(DateTimeFormat.AbbreviatedDayNames  )) %>'];
TERMINOLOGY_LISTS['record_type_display'      ] = ['<%= String.Join("', '", Sql.EscapeJavaScript(arrRecordType                       )) %>'];
<%
foreach ( System.Data.DataRow row in SplendidCache.List("record_type_display").Rows )
{
	string sNAME = Sql.ToString(row["NAME"]);
	int nACLACCESS = Security.GetUserAccess(sNAME, "list");
	if ( Sql.ToBoolean(Application["Modules." + sNAME + ".RestEnabled"]) && nACLACCESS > 0 )
		Response.Write("TERMINOLOGY['.record_type_display." + sNAME + "'] = '" + Sql.EscapeJavaScript(L10n.Term(".record_type_display." + sNAME)) + "';\n");
}
%>
CONFIG['upload_maxsize'] = <%# Sql.ToLong(Application["CONFIG.upload_maxsize"]) %>;

$(document).ready(function()
{
	var oChatDashboardUI = new ChatDashboardUI();
	oChatDashboardUI.Render('divMainLayoutPanel', null, function(status, message)
	{
	}, oChatDashboardUI);
});

		</script>

	</SplendidCRM:InlineScript>
</div>

