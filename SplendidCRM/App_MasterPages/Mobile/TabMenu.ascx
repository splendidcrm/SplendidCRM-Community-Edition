<%@ Control Language="c#" AutoEventWireup="false" Codebehind="TabMenu.ascx.cs" Inherits="SplendidCRM.Themes.Mobile.TabMenu" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
<%@ Import Namespace="System.Data" %>
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
<%
int nRow = 0;
int nDisplayedTabs = 0;
int nMaxTabs = Sql.ToInteger(Session["max_tabs"]);
if ( nMaxTabs == 0 )
	nMaxTabs = Sql.ToInteger(Application["CONFIG.default_max_tabs"]);
if ( nMaxTabs == 0 )
	nMaxTabs = 12;
for ( ; nRow < dtMenu.Rows.Count; nRow++ )
{
	DataRow row = dtMenu.Rows[nRow];
	string sMODULE_NAME   = Sql.ToString(row["MODULE_NAME"  ]);
	string sRELATIVE_PATH = Sql.ToString(row["RELATIVE_PATH"]);
	string sDISPLAY_NAME  = L10n.Term(Sql.ToString(row["DISPLAY_NAME"]));
	if ( SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "access") >= 0 )
	{
		if ( nDisplayedTabs < nMaxTabs )
		{
			if ( nDisplayedTabs > 0 )
				Response.Write("&nbsp;|&nbsp;");
			nDisplayedTabs++;
				%>
<a href="<%= sRELATIVE_PATH.Replace("~/", sApplicationPath) %>"><%= sDISPLAY_NAME %></a>
				<%
		}
	}
}
%>

