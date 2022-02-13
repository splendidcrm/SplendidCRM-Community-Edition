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
using System.Data;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.Optimization;
using System.Diagnostics;
using System.Globalization;

namespace SplendidCRM.ChatDashboard
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected string sUSER_CHAT_CHANNELS;
		protected string[] arrRecordType = new string[]{};

		public DateTimeFormatInfo DateTimeFormat
		{
			get { return System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat; }
		}
		
		// 05/09/2016 Paul.  Move AddScriptReference and AddStyleSheet to Sql object. 
		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_MODULE_NAME"));
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
				sUSER_CHAT_CHANNELS = SplendidCache.MyChatChannels();
				ChatManager.RegisterScripts(Context, mgrAjax);

				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				string sBundleName = "~/ChatDashboard/SplendidScriptsCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndSplendidScripts = new Bundle(sBundleName);
				bndSplendidScripts.Include("~/html5/consolelog.min.js"                    );
				// 12/01/2014 Paul.  Must register SignalR before ChatDashboardUI. 
				bndSplendidScripts.Include("~/html5/Utility.js"                           );
				bndSplendidScripts.Include("~/html5/FullCalendar/fullcalendar.js"         );
				// 01/18/2015 Paul.  Missing references used by Add Related popup. 
				bndSplendidScripts.Include("~/html5/SplendidScripts/SystemCacheRequest.js");
				bndSplendidScripts.Include("~/html5/SplendidScripts/AutoComplete.js"      );
				bndSplendidScripts.Include("~/html5/SplendidScripts/ListView.js"          );
				bndSplendidScripts.Include("~/html5/SplendidScripts/EditView.js"          );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Terminology.js"       );
				BundleTable.Bundles.Add(bndSplendidScripts);
				Sql.AddScriptReference(mgrAjax, sBundleName);
				
				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/ChatDashboard/SplendidUICombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndSplendidUI = new Bundle(sBundleName);
				bndSplendidUI.Include("~/html5/SplendidUI/EditViewUI.js"                  );
				bndSplendidUI.Include("~/html5/SplendidUI/SearchViewUI.js"                );
				bndSplendidUI.Include("~/html5/SplendidUI/PopupViewUI.js"                 );
				bndSplendidUI.Include("~/html5/SplendidUI/Formatting.js"                  );
				bndSplendidUI.Include("~/html5/SplendidUI/Sql.js"                         );
				bndSplendidUI.Include("~/html5/SplendidUI/SplendidInitUI.js"              );
				bndSplendidUI.Include("~/html5/SplendidUI/SearchBuilder.js"               );
				bndSplendidUI.Include("~/html5/SplendidUI/ChatDashboardUI.js"             );
				BundleTable.Bundles.Add(bndSplendidUI);
				Sql.AddScriptReference(mgrAjax, sBundleName);
				
				List<string> lstRecordType = new List<string>();
				DataTable dtRecordType = SplendidCache.List("record_type_display");
				foreach ( DataRow row in dtRecordType.Rows )
				{
					// 01/18/2015 Paul.  Make sure the user has access to the module before including in the list. 
					string sNAME = Sql.ToString(row["NAME"]);
					int nACLACCESS = Security.GetUserAccess(sNAME, "list");
					if ( Sql.ToBoolean(Application["Modules." + sNAME + ".RestEnabled"]) && nACLACCESS > 0 )
						lstRecordType.Add(sNAME);
				}
				arrRecordType = lstRecordType.ToArray();
				// 11/19/2014 Paul.  We need to rebind to that the record type will get applied. 
				Page.DataBind();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
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
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			m_sMODULE = "ChatDashboard";
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

