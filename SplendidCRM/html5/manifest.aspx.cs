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
using System;
using System.IO;
using System.Collections.Specialized;
using System.Web.UI.WebControls;
using System.Reflection;

namespace SplendidCRM.html5
{
	/// <summary>
	/// Summary description for Manifest.
	/// </summary>
	public class Manifest : SplendidPage
	{
		protected StringCollection lstNetworkFiles;
		protected StringCollection lstCacheFiles  ;

		// 09/27/2011 Paul.  This page must be accessible without authentication. 
		override protected bool AuthenticationRequired()
		{
			return false;
		}

		void PrecompileDirectoryTree(string strDirectory, string strRootURL)
		{
			string[] arrFiles = Directory.GetFiles(strDirectory);
			for ( int i = 0 ; i < arrFiles.Length ; i++ )
			{
				FileInfo objInfo = new FileInfo(arrFiles[i]);
				if (  String.Compare(objInfo.Extension, ".aspx", true) == 0 
				   || String.Compare(objInfo.Extension, ".css" , true) == 0
				   || String.Compare(objInfo.Extension, ".gif" , true) == 0
				   || String.Compare(objInfo.Extension, ".jpg" , true) == 0
				   || String.Compare(objInfo.Extension, ".png" , true) == 0
				   || String.Compare(objInfo.Extension, ".js"  , true) == 0
				   )
				{
					// https://developer.mozilla.org/en/Offline_resources_in_Firefox
					// Important: Do not specify the manifest itself in the cache manifest file otherwise it will be nearly impossible to inform the browser a new manifest is available.
					if ( objInfo.Name != "manifest.aspx" )
					{
						lstCacheFiles.Add(strRootURL + objInfo.Name);
					}
				}
			}

			string[] arrDirectories = Directory.GetDirectories(strDirectory);
			for ( int i = 0 ; i < arrDirectories.Length ; i++ )
			{
				FileInfo objInfo = new FileInfo(arrDirectories[i]);
				if ( String.Compare(objInfo.Name, "_sgbak", true) != 0 )
				{
					PrecompileDirectoryTree(objInfo.FullName, strRootURL + objInfo.Name + "/");
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			Response.ContentType = "text/cache-manifest";
			lstCacheFiles = Application["html5.manifest.CacheFiles"] as StringCollection;
			if ( lstCacheFiles == null )
			{
				lstCacheFiles = new StringCollection();
				
				PrecompileDirectoryTree(Server.MapPath("."), "");
				
				lstCacheFiles.Add("../Include/images/blank.gif"               );
				lstCacheFiles.Add("../Include/images/SplendidCRM_Icon.gif"    );
				lstCacheFiles.Add("../Include/images/SplendidCRM_Logo.gif"    );
				// 06/18/2015 Paul.  Theming was disabled so now we can control the styles. 
				//lstCacheFiles.Add("../App_Themes/Six/style.css"               );
				lstCacheFiles.Add("../App_Themes/Six/images/arrow.gif"        );
				lstCacheFiles.Add("../App_Themes/Six/images/arrow_down.gif"   );
				lstCacheFiles.Add("../App_Themes/Six/images/arrow_up.gif"     );
				lstCacheFiles.Add("../App_Themes/Six/images/bgGray.gif"       );
				lstCacheFiles.Add("../App_Themes/Six/images/bgGrayForm.gif"   );
				lstCacheFiles.Add("../App_Themes/Six/images/blank.gif"        );
				lstCacheFiles.Add("../App_Themes/Six/images/currentTab.gif"   );
				lstCacheFiles.Add("../App_Themes/Six/images/delete_inline.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/edit_inline.gif"  );
				lstCacheFiles.Add("../App_Themes/Six/images/header_bg.gif"    );
				lstCacheFiles.Add("../App_Themes/Six/images/otherTab.gif"     );
				lstCacheFiles.Add("../App_Themes/Six/images/view_inline.gif"  );
				lstCacheFiles.Add("../App_Themes/Six/images/accept_inline.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/decline_inline.gif");
				// 10/08/2012 Paul.  Missing images. 
				lstCacheFiles.Add("../App_Themes/Six/images/h3Arrow.gif"        );
				lstCacheFiles.Add("../App_Themes/Atlantic/images/bgGrayForm.gif");
				lstCacheFiles.Add("../App_Themes/Atlantic/images/bgGray.gif"    );
				lstCacheFiles.Add("../App_Themes/Atlantic/images/more.gif"      );
				lstCacheFiles.Add("../App_Themes/Atlantic/images/ToolbarQuickCreate.gif");
				// 11/13/2012 Paul.  Not sure why atlantic style was being included. 
				//lstCacheFiles.Add("../App_Themes/Atlantic/style.css"            );
				// 11/13/2012 Paul.  tabPopdown. 
				lstCacheFiles.Add("../App_Themes/Six/images/tabPopdown.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/advanced_search.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/basic_search.gif");
				// 11/25/2014 Paul.  Add the Mime Types for the Chat Dashboard. 
				// 06/18/2015 Paul.  Theming was disabled so now we can control the styles. 
				//lstCacheFiles.Add("../App_Themes/Six/twitter.css");
				lstCacheFiles.Add("../App_Themes/Six/images/ChatDashboard.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-bmp.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-doc.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-exe.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-gif.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-htm.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-html.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-jpg.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-msi.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-pdf.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-png.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-ppt.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-rar.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-rtf.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-txt.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-wmv.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-xls.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-xml.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/mime-zip.gif");
				// 09/26/2016 Paul.  set inline buttons. 
				lstCacheFiles.Add("../App_Themes/Six/images/set_update_inline.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/set_cancel_inline.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/set_delete_inline.gif");
				lstCacheFiles.Add("../App_Themes/Six/images/set_edit_inline.gif"  );
				
				Application["html5.manifest.CacheFiles"] = lstCacheFiles;
			}
			lstNetworkFiles = Application["html5.manifest.NetworkFiles"] as StringCollection;
			if ( lstNetworkFiles == null )
			{
				lstNetworkFiles = new StringCollection();

				// 11/25/2014 Paul.  Wildcards do not work in the URL, so we can only allow everything. 
				lstNetworkFiles.Add("*");
				/*
				MethodInfo[] arrMethods = typeof(Rest).GetMethods();
				foreach ( MethodInfo m in arrMethods )
				{
					if ( m.Module.ScopeName != "CommonLanguageRuntimeLibrary" )
						lstNetworkFiles.Add("../Rest.svc/" + m.Name);
				}
				// 11/25/2014 Paul.  SignalR files. 
				lstNetworkFiles.Add("../signalr/hubs");
				lstNetworkFiles.Add("../signalr/negotiate?*");
				lstNetworkFiles.Add("../Include/javascript/jquery.signalR-2.4.1.min.js");
				lstNetworkFiles.Add("../Include/javascript/connection.start.js");
				// 11/25/2014 Paul.  There is no reason to have teh Chat hub code in a file separate from ChatDashboardUI.js. 
				//lstNetworkFiles.Add("../Include/javascript/ChatManagerHubJS.aspx");
				lstNetworkFiles.Add("../Notes/attachment.aspx?ID=*");
				*/
				Application["html5.manifest.NetworkFiles"] = lstNetworkFiles;
			}
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}

