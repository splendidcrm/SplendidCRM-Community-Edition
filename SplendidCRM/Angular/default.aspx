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

	protected string sMain      = "main.js"     ;
	protected string sPolyfills = "polyfills.js";
	protected string sScripts   = "scripts.js"  ;
	protected string sRuntime   = "runtime.js"  ;
	protected string sStyles    = "styles.css"  ;

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
		if ( !Sql.IsEmptyString(Application["Angular_main"]) )
		{
			sMain      = Sql.ToString(Application["Angular_main"     ]);
			sPolyfills = Sql.ToString(Application["Angular_polyfills"]);
			sScripts   = Sql.ToString(Application["Angular_scripts"  ]);
			sRuntime   = Sql.ToString(Application["Angular_runtime"  ]);
			sStyles    = Sql.ToString(Application["Angular_styles"   ]);
		}
		else
		{
			string sIndexPath = Server.MapPath("~/Angular/dist/js/index.html");
			if ( System.IO.File.Exists(sIndexPath) )
			{
				string sIndexHtml = System.IO.File.ReadAllText(sIndexPath);
				string sName  = "<script src=\"runtime.";
				int    nStart = sIndexHtml.IndexOf(sName);
				if ( nStart > 0 )
				{
					nStart += 13;
					int nEnd = sIndexHtml.IndexOf("\"", nStart + 1);
					sRuntime = sIndexHtml.Substring(nStart, nEnd - nStart);
				}
				sName  = "<script src=\"polyfills.";
				nStart = sIndexHtml.IndexOf(sName);
				if ( nStart > 0 )
				{
					nStart += 13;
					int nEnd = sIndexHtml.IndexOf("\"", nStart + 1);
					sPolyfills = sIndexHtml.Substring(nStart, nEnd - nStart);
				}
				sName  = "<script src=\"scripts.";
				nStart = sIndexHtml.IndexOf(sName);
				if ( nStart > 0 )
				{
					nStart += 13;
					int nEnd = sIndexHtml.IndexOf("\"", nStart + 1);
					sScripts = sIndexHtml.Substring(nStart, nEnd - nStart);
				}
				sName  = "<script src=\"main.";
				nStart = sIndexHtml.IndexOf(sName);
				if ( nStart > 0 )
				{
					nStart += 13;
					int nEnd = sIndexHtml.IndexOf("\"", nStart + 1);
					sMain = sIndexHtml.Substring(nStart, nEnd - nStart);
				}
				sName = "<link rel=\"stylesheet\" href=\"styles.";
				nStart = sIndexHtml.IndexOf(sName);
				if ( nStart > 0 )
				{
					nStart += 29;
					int nEnd = sIndexHtml.IndexOf("\"", nStart + 1);
					sStyles = sIndexHtml.Substring(nStart, nEnd - nStart);
				}
			}
			Application["Angular_main"     ] = sMain     ;
			Application["Angular_polyfills"] = sPolyfills;
			Application["Angular_scripts"  ] = sScripts  ;
			Application["Angular_runtime"  ] = sRuntime  ;
			Application["Angular_styles"   ] = sStyles   ;
		}
	}
</script>

<!DOCTYPE HTML>
<html id="htmlRoot" runat="server">

<head runat="server">
	<meta charset="UTF-8" />
	<link rel="shortcut icon" href="<%# Application["imageURL"] %>SplendidCRM_Icon.ico" />
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<base href="<%# Application["rootURL"] %>Angular/" />
	<title><%# L10n.Term(".LBL_BROWSER_TITLE") %></title>
	<style>@charset "UTF-8";:root{--bs-blue:#0d6efd;--bs-indigo:#6610f2;--bs-purple:#6f42c1;--bs-pink:#d63384;--bs-red:#dc3545;--bs-orange:#fd7e14;--bs-yellow:#ffc107;--bs-green:#198754;--bs-teal:#20c997;--bs-cyan:#0dcaf0;--bs-white:#fff;--bs-gray:#6c757d;--bs-gray-dark:#343a40;--bs-gray-100:#f8f9fa;--bs-gray-200:#e9ecef;--bs-gray-300:#dee2e6;--bs-gray-400:#ced4da;--bs-gray-500:#adb5bd;--bs-gray-600:#6c757d;--bs-gray-700:#495057;--bs-gray-800:#343a40;--bs-gray-900:#212529;--bs-primary:#0d6efd;--bs-secondary:#6c757d;--bs-success:#198754;--bs-info:#0dcaf0;--bs-warning:#ffc107;--bs-danger:#dc3545;--bs-light:#f8f9fa;--bs-dark:#212529;--bs-primary-rgb:13, 110, 253;--bs-secondary-rgb:108, 117, 125;--bs-success-rgb:25, 135, 84;--bs-info-rgb:13, 202, 240;--bs-warning-rgb:255, 193, 7;--bs-danger-rgb:220, 53, 69;--bs-light-rgb:248, 249, 250;--bs-dark-rgb:33, 37, 41;--bs-white-rgb:255, 255, 255;--bs-black-rgb:0, 0, 0;--bs-body-color-rgb:33, 37, 41;--bs-body-bg-rgb:255, 255, 255;--bs-font-sans-serif:system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", "Liberation Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";--bs-font-monospace:SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;--bs-gradient:linear-gradient(180deg, rgba(255, 255, 255, .15), rgba(255, 255, 255, 0));--bs-body-font-family:var(--bs-font-sans-serif);--bs-body-font-size:1rem;--bs-body-font-weight:400;--bs-body-line-height:1.5;--bs-body-color:#212529;--bs-body-bg:#fff}*,*:before,*:after{box-sizing:border-box}@media (prefers-reduced-motion: no-preference){:root{scroll-behavior:smooth}}body{margin:0;font-family:var(--bs-body-font-family);font-size:var(--bs-body-font-size);font-weight:var(--bs-body-font-weight);line-height:var(--bs-body-line-height);color:var(--bs-body-color);text-align:var(--bs-body-text-align);background-color:var(--bs-body-bg);-webkit-text-size-adjust:100%;-webkit-tap-highlight-color:rgba(0,0,0,0)}</style>
	<link rel="stylesheet" href="<%# "dist/js/" + sStyles %>">
</head>

<body>
	<app-root></app-root>
	<script src="dist/js/<%# sRuntime   %>" type="module"></script>
	<script src="dist/js/<%# sPolyfills %>" type="module"></script>
	<script src="dist/js/<%# sScripts   %>" defer></script>
	<script src="dist/js/<%# sMain      + "?" + (bDebug ? (DateTime.Now.ToFileTime().ToString()) : Sql.ToString(Application["SplendidVersion"])) %>" type="module"></script>

	<div id="divFooterCopyright" align="center" style="margin-top: 4px" class="copyRight">
		Copyright &copy; 2005-2022 <a id="lnkSplendidCRM" href="http://www.splendidcrm.com" target="_blank" class="copyRightLink">SplendidCRM Software, Inc.</a> All Rights Reserved.<br />
	</div>
</body>
</html>
