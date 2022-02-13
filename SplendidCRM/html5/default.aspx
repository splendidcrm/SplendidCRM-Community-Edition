<%@ Page Language="c#" EnableTheming="false" CodeBehind="default.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.html5.Default" %>

<!--
/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
-->
<!DOCTYPE HTML>
<html id="htmlRoot" runat="server">
<head runat="server">
	<!-- 04/06/2017 Paul.  Use Bootstrap for responsive design. -->
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="apple-mobile-web-app-capable" content="yes" visible='<%# Request.UserAgent.Contains("iPad;") %>' runat="server" />
	<meta name="apple-mobile-web-app-status-bar-style" content="black" visible='<%# Request.UserAgent.Contains("iPad;") %>' runat="server" />
	<base href="<%# Application["rootURL"] %>html5/" />
	<title><%# L10n.Term(".LBL_BROWSER_TITLE") %></title>

	<!-- // 07/01/2017 Paul.  We cannot bundle jquery-ui or zTreeStyle.css as it will change its relative path to images. -->
	<link type="text/css" rel="stylesheet" href="jQuery/jquery-ui-1.9.1.custom.css" />
	<link type="text/css" rel="stylesheet" href="bootstrap/3.3.7/css/bootstrap.css" />
	<!-- // 07/01/2017 Paul.  Cannot combine font-awesome as it pevents automatic loading of font files.  -->
	<link type="text/css" rel="stylesheet" href="fonts/font-awesome.css" />
	<link id="lnkThemeStyle" type="text/css" rel="stylesheet" href="Themes/Six/style.css" />
	<!-- 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV.  Cannot be combined due to relative image. -->
	<link type="text/css" rel="stylesheet" href="jQuery/multiple-select.css" />
	<!-- 01/08/2018 Paul.  Include version in url to ensure updates of combined files. -->
	<link type="text/css" rel="stylesheet" href="StylesCombined<%= "_" + Sql.ToString(Application["SplendidVersion"]) %>" />
	<script type="text/javascript" src="ScriptsCombined<%=         "_" + Sql.ToString(Application["SplendidVersion"]) %>"></script>
	<script type="text/javascript" src="BootstrapCombined<%=       "_" + Sql.ToString(Application["SplendidVersion"]) %>"></script>
	<script type="text/javascript" src="SplendidScriptsCombined<%= "_" + Sql.ToString(Application["SplendidVersion"]) %>"></script>
	<script type="text/javascript" src="SplendidUICombined<%=      "_" + Sql.ToString(Application["SplendidVersion"]) %>"></script>

	<%
	// 09/28/2018 Paul.  SignalR may not be supported. 
	if ( Utils.CachedFileExists(Context, "~/html5/SignalR/jquery.signalR-2.4.1.min.js") )
	{
		%>
	<script type="text/javascript" src="SignalR/jquery.signalR-2.4.1.min.js"></script>
	<script type="text/javascript" src="SignalR/server.js"></script>
	<script type="text/javascript" src="SignalR/connection.start.js"></script>
	<script type="text/javascript" src="SplendidUI/ChatDashboardUI.js"></script>
		<%
	}
	%>
	<!-- 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV.  Combining causes javascript error. -->
	<script type="text/javascript" src="jQuery/multiple-select.js"></script>
	<script type="text/javascript" src="<%# Application["scriptURL"] %>ModulePopupScripts.aspx?LastModified=<%# Server.UrlEncode(Sql.ToString(Application["Modules.LastModified"])) + "&UserID=" + Security.USER_ID.ToString() %>"></script>

	<script type="text/javascript" src="adal.min.js"></script>
	<script type="text/javascript" src="default.js"></script>
	<!-- 05/19/2017 Paul.  The Dashboard uses RequireJs to load panels. -->
	<!-- 05/20/2017 Paul.  Must place require after bootstrap otherwise we get: Mismatched anonymous define() module: function ( $ )  -->
	<script type="text/javascript" src="require-2.3.3.min.js"></script>

	<%@ Register TagPrefix="SplendidCRM" TagName="LoadSplendid" Src="LoadSplendid.ascx" %>
	<SplendidCRM:LoadSplendid ID="ctlLoadSplendid" runat="Server" />

<!-- http://stackoverflow.com/questions/12770591/easy-way-to-see-the-bootstrap-grid -->
<style type="text/css">
div[class="row"]
{
	/* border: 1px dotted rgba(0, 0, 0, 0.5); */
}

div[class^="col-"]
{
	/* background-color: rgba(255, 0, 0, 0.2); */
}
</style>
</head>
<body class="nav-md">
	<div class="container body">
		<div class="main_container">
			<div id="divLeftColumn" class="col-md-3 left_col">
				<div class="left_col scroll-view">
					<div id="divNavTitle" class="navbar nav_title" style="border: 0;">
					</div>
					<div class="clearfix"></div>

					<!-- menu profile quick info -->
					<div id="divProfile" class="profile" style="display: none">
						<br />
					</div>
					<!-- /menu profile quick info -->
					<div class="clearfix"></div>

					<!-- sidebar menu -->
					<div id="sidebar-menu" class="main_menu_side hidden-print main_menu">
					</div>
					<!-- /sidebar menu -->

					<!-- /menu footer buttons -->
					<!--
					<div class="sidebar-footer hidden-small">
						<a data-toggle="tooltip" data-placement="top" title="Settings">
							<span class="glyphicon glyphicon-cog" aria-hidden="true"></span>
						</a>
						<a data-toggle="tooltip" data-placement="top" title="FullScreen">
							<span class="glyphicon glyphicon-fullscreen" aria-hidden="true"></span>
						</a>
						<a data-toggle="tooltip" data-placement="top" title="Lock">
							<span class="glyphicon glyphicon-eye-close" aria-hidden="true"></span>
						</a>
						<a data-toggle="tooltip" data-placement="top" title="Logout">
							<span class="glyphicon glyphicon-off" aria-hidden="true"></span>
						</a>
					</div>
					-->
					<!-- /menu footer buttons -->
				</div>
			</div>

			<!-- top navigation -->
			<div class="top_nav">
				<div class="nav_menu">
					<nav class="" role="navigation">
						<div style="display: table; width: 100%;">
							<div style="display: table-row">
								<div style="display: table-cell; width: 5%; vertical-align: top;">
									<div class="nav toggle">
										<a id="menu_toggle"><i class="fa fa-bars"></i></a>
									</div>
								</div>
								<div style="display: table-cell; vertical-align: middle;">
									<div id="divBootstrapError" class="error">
									</div>
								</div>
								<div style="display: table-cell; width: 20%;">
									<ul id="divContextMenu" class="nav navbar-nav navbar-right">
										<li>
											<a href="javascript:;" class="user-profile dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
												<span id="divHeader_divOnlineStatus">Offline</span>
												<span class="glyphicon glyphicon-triangle-bottom" style="padding-left: 5px;">
												</span>
											</a>
										</li>
									</ul>
								</div>
							</div>
						</div>
					</nav>
				</div>
			</div>
			<!-- /top navigation -->

			<!-- page content -->
			<div id="divMainPageContent" class="right_col" role="main">
				<div class="">
					<!-- Old Splendid -->
					<div id="divOldSplendid" style="display: none;">
						<div id="ctlAtlanticToolbar"></div>
						<div id="ctlHeader"></div>
						<div width="100%" style="background-color: White">
							<div id="ctlTabMenu"></div>

							<table width="100%" cellpadding="0" cellspacing="0">
								<tr>
									<td id="tdShortcuts" class="lastViewPanel" style="display: none;">
										<div id="ctlActions"></div>
										<div id="ctlLastViewed"></div>
										<div id="ctlFavorites"></div>
									</td>
									<td width="24px" valign="top" style="display: none;">
										<div style="padding-top: 10px;">
											<asp:Image ID="imgShowHandle" SkinID="show" onclick="showLeftCol(true, true);" runat="server" />
											<asp:Image ID="imgHideHandle" SkinID="hide" onclick="showLeftCol(false, true);" runat="server" />
										</div>
									</td>
									<td>
										<div style="padding-left: 10px; padding-right: 10px; padding-bottom: 5px;">
											<!--
											<div id="divMainLayoutPanel_Header"></div>
											<div id="divMainActionsPanel" style="padding-bottom: 5px;"></div>
											<div id="divMainLayoutPanel"></div>
											-->
										</div>
									</td>
								</tr>
							</table>
						</div>
					</div>
					<div class="clearfix"></div>
					<!-- Old Splendid -->
					<div id="divMainLayoutPanel_Header"></div>
					<div id="divMainActionsPanel" style="padding-bottom: 5px;"></div>
					<div id="divMainLayoutPanel"></div>
				</div>
			</div>
			<!-- /page content -->

			<footer>
				<div id="divFooterCopyright" class="pull-right">
					Copyright &copy; 2005-2017 <a id="lnkSplendidCRM" href="http://www.splendidcrm.com" target="_blank" class="copyRightLink">SplendidCRM Software, Inc.</a> All Rights Reserved.<br />
				</div>
				<div class="clearfix"></div>
			</footer>
		</div>
	</div>
	<!-- 06/27/2017 Paul.  Custom.js must be at the bottom of body, otherwise its code will fail. -->
	<script type="text/javascript" src="bootstrap/gentelella/custom.js"></script>
</body>
</html>
