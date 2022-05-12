<%@ Page language="c#" EnableTheming="true" AutoEventWireup="true" Inherits="SplendidCRM.SplendidPage" %>
<%@ Import Namespace="System.Diagnostics" %>
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

override protected bool AuthenticationRequired()
{
	return false;
}

private void Page_PreInit(object sender, EventArgs e)
{
	// 06/18/2015 Paul.  Setting the theme to an empty string should stop the insertion of styles from the Themes folder. 
	// 09/02/2019 Paul.  Going to try themes on React Client. 
	//this.Theme = "";
}

private void Page_Load(object sender, System.EventArgs e)
{
	Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
	if ( !IsPostBack )
	{
		try
		{
			//System.Web.UI.ScriptManager mgrAjax = System.Web.UI.ScriptManager.GetCurrent(this.Page);
			//ChatManager.RegisterScripts(Context, mgrAjax);
		}
		catch(Exception ex)
		{
			SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
		}
	}
}
</script>

<!DOCTYPE HTML>
<html id="htmlRoot" runat="server">

<head runat="server">
	<meta charset="UTF-8" />
	<link rel="shortcut icon" href="<%# Application["imageURL"] %>SplendidCRM_Icon.ico" />
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<base href="<%# Application["rootURL"] %>React/" />
	<title><%# L10n.Term(".LBL_BROWSER_TITLE") %></title>
</head>

<body>
	<!-- 09/08/2021 Paul.  Change to vh instead of height to allow to grow. -->
	<!-- 09/14/2021 Paul.  Remove height.  It is causing copyright to appear in the middle of a detail view. -->
	<div id="root"></div>
	<script type="text/javascript" src="dist/js/SteviaCRM.js?<%= (bDebug ? (DateTime.Now.ToFileTime().ToString()) : Sql.ToString(Application["SplendidVersion"])) %>"></script>

	<div id="divFooterCopyright" align="center" style="margin-top: 4px" class="copyRight">
		Copyright &copy; 2005-2022 <a id="lnkSplendidCRM" href="http://www.splendidcrm.com" target="_blank" class="copyRightLink">SplendidCRM Software, Inc.</a> All Rights Reserved.<br />
	</div>
</body>
</html>
