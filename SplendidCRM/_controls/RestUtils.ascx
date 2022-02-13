<%@ Control Language="c#" AutoEventWireup="false" Codebehind="RestUtils.ascx.cs" Inherits="SplendidCRM._controls.RestUtils" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
<SplendidCRM:InlineScript runat="server">
	<script type="text/javascript">
// 08/25/2013 Paul.  Move sREMOTE_SERVER definition to the master pages. 
//var sREMOTE_SERVER  = '<%# Application["rootURL"] %>';
// 05/09/2016 Paul.  Move javascript objects to separate file.  Keep data initialization here. 
// 09/23/2018 Paul.  Create a multi-tenant system. 
CONFIG['enable_multi_tenant_teams'] = '<%# SplendidCRM.Crm.Config.enable_multi_tenant_teams()%>';
CONFIG['enable_team_management'   ] = '<%# SplendidCRM.Crm.Config.enable_team_management()  %>';
CONFIG['require_team_management'  ] = '<%# SplendidCRM.Crm.Config.require_team_management() %>';
CONFIG['enable_dynamic_teams'     ] = '<%# SplendidCRM.Crm.Config.enable_dynamic_teams()    %>';
CONFIG['require_user_assignment'  ] = '<%# SplendidCRM.Crm.Config.require_user_assignment() %>';
CONFIG['enable_speech'            ] = '<%# Utils.SupportsSpeech && Sql.ToBoolean(Application["CONFIG.enable_speech"]) %>';
// 06/13/2017 Paul.  Max entries is needed for the HTML5 My Dashboard. 
CONFIG['list_max_entries_per_page'] = '<%# Sql.ToInteger(Application["CONFIG.list_max_entries_per_page"]) %>';
bIS_MOBILE        = '<%# Utils.IsMobileDevice.ToString() %>';
sUSER_ID          = '<%# Security.USER_ID   %>';
sUSER_NAME        = '<%# Security.USER_NAME %>';
sTEAM_ID          = '<%# Security.TEAM_ID   %>';
sPICTURE          = '<%# Sql.EscapeJavaScript(Security.PICTURE) %>';
sUSER_TIME_FORMAT = '<%# Sql.ToString(Session["USER_SETTINGS/TIMEFORMAT"]) %>';
sUSER_DATE_FORMAT = '<%# Sql.ToString(Session["USER_SETTINGS/DATEFORMAT"]) %>';
sUSER_THEME       = '<%# Sql.ToString(Session["USER_SETTINGS/THEME"     ]) %>';
sUSER_LANG        = '<%# Sql.ToString(Session["USER_SETTINGS/CULTURE"   ]) %>';
if ( sUSER_LANG == '' )
	sUSER_LANG = 'en-US';

sUSER_CurrencyDecimalDigits    = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyDecimalDigits     %>';
sUSER_CurrencyDecimalSeparator = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyDecimalSeparator  %>';
sUSER_CurrencyGroupSeparator   = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyGroupSeparator    %>';
sUSER_CurrencyGroupSizes       = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyGroupSizes[0]     %>';
sUSER_CurrencyNegativePattern  = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyNegativePattern   %>';
sUSER_CurrencyPositivePattern  = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencyPositivePattern   %>';
sUSER_CurrencySymbol           = '<%# System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencySymbol            %>';
<%
// 01/24/2018 Paul.  The Calendar needs to determine if Calls module is enabled. 
if ( Security.IsAuthenticated() )
{
	foreach ( System.Data.DataRow row in dtModules.Rows )
	{
		string sMODULE_NAME   = Sql.ToString(row["MODULE_NAME"  ]);
		string sTABLE_NAME    = Sql.ToString(row["TABLE_NAME"   ]);
		string sDISPLAY_NAME  = Sql.ToString(row["DISPLAY_NAME" ]);
		string sRELATIVE_PATH = Sql.ToString(row["RELATIVE_PATH"]);
		Response.Write("MODULES['" + sMODULE_NAME + "'] =  { TABLE_NAME: '" + sTABLE_NAME + "', sDISPLAY_NAME: '" + sDISPLAY_NAME + "', RELATIVE_PATH: '" + sRELATIVE_PATH + "' };\r\n");
	}
}
%>

	</script>
</SplendidCRM:InlineScript>

