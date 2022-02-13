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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Web.Optimization;
using System.Diagnostics;

namespace SplendidCRM.Dashboard.html5
{
	/// <summary>
	///		Summary description for DashboardView.
	/// </summary>
	public class DashboardView : SplendidControl
	{
		public void RegisterScripts(Page Page)
		{
			try
			{
				AjaxControlToolkit.ToolkitScriptManager mgrAjax = ScriptManager.GetCurrent(Page) as AjaxControlToolkit.ToolkitScriptManager;
#if DEBUG
				//mgrAjax.CombineScripts = false;
#endif
				// 07/01/2017 Paul.  We cannot bundle jquery-ui or zTreeStyle.css as it will change its relative path to images. 
				Sql.AddStyleSheet(this.Page, "~/html5/jQuery/jquery-ui-1.9.1.custom.css"                   );
				// 07/01/2017 Paul.  Cannot combine bootstrap as it pevents automatic loading of font files. 
				Sql.AddStyleSheet(this.Page, "~/html5/bootstrap/3.3.7/css/bootstrap.css"                   );
				// 07/01/2017 Paul.  Cannot combine font-awesome as it pevents automatic loading of font files. 
				Sql.AddStyleSheet(this.Page, "~/html5/fonts/font-awesome.css"                              );
				
				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				string sBundleName = "~/Dashboard/html5/StylesCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndStyles = new Bundle(sBundleName);
				bndStyles.Include("~/html5/jQuery/jquery.jqplot.min.css"                                   );
				bndStyles.Include("~/html5/bootstrap/3.3.7/css/bootstrap-theme.css"                        );
				//bndStyles.Include("~/html5/Themes/Six/style.css"                                           );
				bndStyles.Include("~/html5/Atlantic.css"                                                   );
				//bndStyles.Include("~/html5/Themes/Seven/styleModuleHeader.css"                             );
				bndStyles.Include("~/html5/bootstrap/datatables.net/dataTables.bootstrap.css"              );
				bndStyles.Include("~/html5/bootstrap/datatables.net-responsive/responsive.bootstrap.css"   );
				bndStyles.Include("~/html5/bootstrap/gentelella/custom.css"                                );
				BundleTable.Bundles.Add(bndStyles);
				Sql.AddStyleSheet(this.Page, sBundleName);
				
				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/Dashboard/html5/ScriptsCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndScripts = new Bundle(sBundleName);
				bndScripts.Include("~/html5/jQuery/jquery-ui-timepicker-addon.js"                        );
				bndScripts.Include("~/html5/jQuery/jquery.paging.min.js"                                 );
				bndScripts.Include("~/html5/jQuery/jquery.jqplot.min.js"                                 );
				bndScripts.Include("~/html5/jQuery/jquery.jqplot.plugins.min.js"                         );
				//bndScripts.Include("~/html5/FullCalendar/fullcalendar.js"                                );
				BundleTable.Bundles.Add(bndScripts);
				Sql.AddScriptReference(mgrAjax, sBundleName);

				// 04/08/2017 Paul.  Use Bootstrap for responsive design. 
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/Dashboard/html5/BootstrapCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndBootstrap = new Bundle(sBundleName);
				bndBootstrap.Include("~/html5/bootstrap/3.3.7/js/bootstrap.min.js"                         );
				bndBootstrap.Include("~/html5/bootstrap/datatables.net/jquery.dataTables.js"               );
				bndBootstrap.Include("~/html5/bootstrap/datatables.net/dataTables.bootstrap.js"            );
				bndBootstrap.Include("~/html5/bootstrap/datatables.net-responsive/dataTables.responsive.js");
				bndBootstrap.Include("~/html5/bootstrap/datatables.net-responsive/responsive.bootstrap.js" );
				BundleTable.Bundles.Add(bndBootstrap);
				Sql.AddScriptReference(mgrAjax, sBundleName);
				
				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/Dashboard/html5/SplendidScriptsCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndSplendidScripts = new Bundle(sBundleName);
				bndSplendidScripts.Include("~/html5/consolelog.min.js"                    );
				bndSplendidScripts.Include("~/html5/Utility.js"                           );
				bndSplendidScripts.Include("~/html5/SplendidScripts/SystemCacheRequest.js");
				bndSplendidScripts.Include("~/html5/SplendidScripts/SplendidCache.js"     );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Application.js"       );
				bndSplendidScripts.Include("~/html5/SplendidScripts/DetailView.js"        );
				bndSplendidScripts.Include("~/html5/SplendidScripts/ListView.js"          );
				bndSplendidScripts.Include("~/html5/SplendidScripts/EditView.js"          );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Terminology.js"       );
				bndSplendidScripts.Include("~/html5/SplendidScripts/AutoComplete.js"      );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Dashboard.js"         );
				BundleTable.Bundles.Add(bndSplendidScripts);
				Sql.AddScriptReference(mgrAjax, sBundleName);
				
				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/Dashboard/html5/SplendidUICombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndSplendidUI = new Bundle(sBundleName);
				bndSplendidUI.Include("~/html5/SplendidUI/SplendidErrorUI.js"             );
				bndSplendidUI.Include("~/html5/SplendidUI/SearchBuilder.js"               );
				bndSplendidUI.Include("~/html5/SplendidUI/Sql.js"                         );
				bndSplendidUI.Include("~/html5/SplendidUI/Crm.js"                         );
				bndSplendidUI.Include("~/html5/SplendidUI/Formatting.js"                  );
				bndSplendidUI.Include("~/html5/SplendidUI/TabMenuUI.js"                   );
				bndSplendidUI.Include("~/html5/SplendidUI/TerminologyUI.js"               );
				bndSplendidUI.Include("~/html5/SplendidUI/ListViewUI.js"                  );
				bndSplendidUI.Include("~/html5/SplendidUI/PopupViewUI.js"                 );
				bndSplendidUI.Include("~/html5/SplendidUI/EditViewUI.js"                  );
				bndSplendidUI.Include("~/html5/SplendidUI/SearchViewUI.js"                );
				bndSplendidUI.Include("~/html5/SplendidUI/SplendidInitUI.js"              );
				bndSplendidUI.Include("~/html5/SplendidUI/SelectionUI.js"                 );
				bndSplendidUI.Include("~/html5/SplendidUI/DynamicButtonsUI.js"            );
				bndSplendidUI.Include("~/html5/SplendidUI/LoginViewUI.js"                 );
				bndSplendidUI.Include("~/html5/SplendidUI/DashboardUI.js"                 );
				bndSplendidUI.Include("~/html5/SplendidUI/DashboardEditUI.js"             );
				BundleTable.Bundles.Add(bndSplendidUI);
				Sql.AddScriptReference(mgrAjax, sBundleName);
				
				// 05/19/2017 Paul.  The Dashboard uses RequireJs to load panels. 
				// 05/20/2017 Paul.  Must place require after bootstrap otherwise we get: Mismatched anonymous define() module: function ( $ )  
				Sql.AddScriptReference(mgrAjax, "~/html5/require-2.3.3.min.js"            );
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			RegisterScripts(this.Page);
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
		}
		#endregion
	}
}
