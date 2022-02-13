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
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.Optimization;
using System.Diagnostics;

namespace SplendidCRM.html5
{
	/// <summary>
	/// Summary description for Default.
	/// </summary>
	public class Default : SplendidPage
	{
		public Default()
		{
			this.PreInit += new EventHandler(Default_PreInit);
		}

		protected void Default_PreInit(object sender, EventArgs e)
		{
			// 11/13/2012 Paul.  Can't seem to disable theming, so just force the theme to Six as that is all that is supported. 
			// 06/18/2015 Paul.  Setting the theme to an empty string should stop the insertion of styles from the Themes folder. 
			this.Theme = "";
		}

		// 01/25/2008 Paul.  This page must be accessible without authentication. 
		override protected bool AuthenticationRequired()
		{
			return false;
		}

		public void RegisterScripts(Page Page)
		{
			try
			{
				AjaxControlToolkit.ToolkitScriptManager mgrAjax = ScriptManager.GetCurrent(Page) as AjaxControlToolkit.ToolkitScriptManager;
				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/08/2018 Paul.  Include version in url to ensure updates of combined files. 
				string sBundleName = "~/html5/StylesCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndStyles = new Bundle(sBundleName);
				bndStyles.Include("~/html5/jQuery/contextMenu-1.2.0.css"                                 );
				// 05/20/2017 Paul.  Add jqPlot. -->
				bndStyles.Include("~/html5/jQuery/jquery.jqplot.min.css"                                 );
				// 04/06/2017 Paul.  Use Bootstrap for responsive design. 
				// 07/01/2017 Paul.  Cannot combine bootstrap as it pevents automatic loading of font files. 
				//bndStyles.Include("~/html5/bootstrap/3.3.7/css/bootstrap.css"                            );
				bndStyles.Include("~/html5/bootstrap/3.3.7/css/bootstrap-theme.css"                      );
				bndStyles.Include("~/html5/FullCalendar/fullcalendar.css"                                );
				// 07/01/2017 Paul.  Cannot combine font-awesome as it pevents automatic loading of font files. 
				//bndStyles.Include("~/html5/fonts/font-awesome.css"                                       );
				bndStyles.Include("~/html5/mobile.css"                                                   );
				// 06/18/2015 Paul.  Theming was disabled so now we can control the styles. -->
				bndStyles.Include("~/html5/Themes/Six/ChatDashboard.css"                                 );
				bndStyles.Include("~/html5/Themes/Six/twitter.css"                                       );
				bndStyles.Include("~/html5/Atlantic.css"                                                 );
				// 10/27/2015 Paul.  Include Seven module header styles. 
				bndStyles.Include("~/html5/Themes/Seven/styleModuleHeader.css"                           );
				// 04/08/2017 Paul.  Use Bootstrap for responsive design. 
				bndStyles.Include("~/html5/bootstrap/datatables.net/dataTables.bootstrap.css"            );
				bndStyles.Include("~/html5/bootstrap/datatables.net-responsive/responsive.bootstrap.css" );
				bndStyles.Include("~/html5/bootstrap/gentelella/custom.css"                              );
				BundleTable.Bundles.Add(bndStyles);
				//Sql.AddStyleSheet(this.Page, sBundleName);
				
				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/08/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/html5/ScriptsCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndScripts = new Bundle(sBundleName);
				bndScripts.Include("~/html5/jQuery/jquery-1.9.1.min.js"                                  );
				bndScripts.Include("~/html5/jQuery/jquery-ui-1.9.1.custom.js"                            );
				bndScripts.Include("~/html5/jQuery/jquery-ui-timepicker-addon.js"                        );
				bndScripts.Include("~/html5/jQuery/jquery.paging.min.js"                                 );
				bndScripts.Include("~/html5/jQuery/contextMenu-1.2.0.js"                                 );
				bndScripts.Include("~/html5/jQuery/jquery.jqplot.min.js"                                 );
				bndScripts.Include("~/html5/jQuery/jquery.jqplot.plugins.min.js"                         );
				bndScripts.Include("~/html5/FullCalendar/fullcalendar.js"                                );
				bndScripts.Include("~/html5/FullCalendar/gcal.js"                                        );
				bndScripts.Include("~/html5/JSON.js"                                                     );
				bndScripts.Include("~/html5/Math.uuid.js"                                                );
				bndScripts.Include("~/html5/utility.js"                                                  );
				bndScripts.Include("~/html5/sha1.js"                                                     );
				BundleTable.Bundles.Add(bndScripts);
				//Sql.AddScriptReference(mgrAjax, sBundleName);
				
				// 04/06/2017 Paul.  Use Bootstrap for responsive design. 
				// 07/03/2017 Paul.  The Community Edition is having trouble loading the HTML5 page. 
				// 01/08/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/html5/BootstrapCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndBootstrap = new Bundle(sBundleName);
				bndBootstrap.Include("~/html5/bootstrap/3.3.7/js/bootstrap.min.js"                         );
				bndBootstrap.Include("~/html5/bootstrap/datatables.net/jquery.dataTables.js"               );
				bndBootstrap.Include("~/html5/bootstrap/datatables.net/dataTables.bootstrap.js"            );
				bndBootstrap.Include("~/html5/bootstrap/datatables.net-responsive/dataTables.responsive.js");
				bndBootstrap.Include("~/html5/bootstrap/datatables.net-responsive/responsive.bootstrap.js" );
				BundleTable.Bundles.Add(bndBootstrap);
				//Sql.AddScriptReference(mgrAjax, sBundleName);
				
				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/08/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/html5/SplendidScriptsCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndSplendidScripts = new Bundle(sBundleName);
				// 03/02/2016 Paul.  Use generic console.log to support IE9. 
				bndSplendidScripts.Include("~/html5/consolelog.min.js"                         );
				bndSplendidScripts.Include("~/html5/SplendidScripts/SplendidStorage.js"        );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Credentials.js"            );
				bndSplendidScripts.Include("~/html5/SplendidScripts/SplendidRequest.js"        );
				bndSplendidScripts.Include("~/html5/SplendidScripts/SystemCacheRequest.js"     );
				bndSplendidScripts.Include("~/html5/SplendidScripts/SplendidCache.js"          );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Application.js"            );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Login.js"                  );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Logout.js"                 );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Terminology.js"            );
				bndSplendidScripts.Include("~/html5/SplendidScripts/DetailViewRelationships.js");
				bndSplendidScripts.Include("~/html5/SplendidScripts/TabMenu.js"                );
				bndSplendidScripts.Include("~/html5/SplendidScripts/ListView.js"               );
				bndSplendidScripts.Include("~/html5/SplendidScripts/DetailView.js"             );
				bndSplendidScripts.Include("~/html5/SplendidScripts/EditView.js"               );
				bndSplendidScripts.Include("~/html5/SplendidScripts/DynamicButtons.js"         );
				// 08/20/2016 Paul.  Add Business Process buttons. 
				bndSplendidScripts.Include("~/html5/SplendidScripts/ProcessButtons.js"         );
				bndSplendidScripts.Include("~/html5/SplendidScripts/ModuleUpdate.js"           );
				bndSplendidScripts.Include("~/html5/SplendidScripts/AutoComplete.js"           );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Options.js"                );
				bndSplendidScripts.Include("~/html5/SplendidScripts/CalendarView.js"           );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Dashboard.js"              );
				BundleTable.Bundles.Add(bndSplendidScripts);
				//Sql.AddScriptReference(mgrAjax, sBundleName);
				
				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/08/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/html5/SplendidUICombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndSplendidUI = new Bundle(sBundleName);
				bndSplendidUI.Include("~/html5/SplendidUI/chrome.js"                           );
				bndSplendidUI.Include("~/html5/SplendidUI/SplendidErrorUI.js"                  );
				bndSplendidUI.Include("~/html5/SplendidUI/SearchBuilder.js"                    );
				bndSplendidUI.Include("~/html5/SplendidUI/Sql.js"                              );
				bndSplendidUI.Include("~/html5/SplendidUI/Crm.js"                              );
				bndSplendidUI.Include("~/html5/SplendidUI/Formatting.js"                       );
				bndSplendidUI.Include("~/html5/SplendidUI/TerminologyUI.js"                    );
				bndSplendidUI.Include("~/html5/SplendidUI/TabMenuUI.js"                        );
				bndSplendidUI.Include("~/html5/SplendidUI/TabMenuUI_Six.js"                    );
				bndSplendidUI.Include("~/html5/SplendidUI/TabMenuUI_Atlantic.js"               );
				bndSplendidUI.Include("~/html5/SplendidUI/TabMenuUI_Mobile.js"                 );
				bndSplendidUI.Include("~/html5/SplendidUI/TabMenuUI_OfficeAddin.js"            );
				bndSplendidUI.Include("~/html5/SplendidUI/TabMenuUI_Gentelella.js"             );
				bndSplendidUI.Include("~/html5/SplendidUI/ListViewUI.js"                       );
				bndSplendidUI.Include("~/html5/SplendidUI/PopupViewUI.js"                      );
				bndSplendidUI.Include("~/html5/SplendidUI/DetailViewUI.js"                     );
				bndSplendidUI.Include("~/html5/SplendidUI/EditViewUI.js"                       );
				bndSplendidUI.Include("~/html5/SplendidUI/SearchViewUI.js"                     );
				bndSplendidUI.Include("~/html5/SplendidUI/SplendidInitUI.js"                   );
				bndSplendidUI.Include("~/html5/SplendidUI/DynamicButtonsUI.js"                 );
				// 08/20/2016 Paul.  Add Business Process buttons. 
				bndSplendidUI.Include("~/html5/SplendidUI/ProcessButtonsUI.js"                 );
				bndSplendidUI.Include("~/html5/SplendidUI/DetailViewRelationshipsUI.js"        );
				bndSplendidUI.Include("~/html5/SplendidUI/SelectionUI.js"                      );
				bndSplendidUI.Include("~/html5/SplendidUI/LoginViewUI.js"                      );
				bndSplendidUI.Include("~/html5/SplendidUI/ArchiveEmailUI.js"                   );
				bndSplendidUI.Include("~/html5/SplendidUI/CalendarViewUI.js"                   );
				bndSplendidUI.Include("~/html5/SplendidUI/EditLineItemsViewUI.js"              );
				bndSplendidUI.Include("~/html5/SplendidUI/DashboardUI.js"                      );
				bndSplendidUI.Include("~/html5/SplendidUI/DashboardEditUI.js"                  );
				BundleTable.Bundles.Add(bndSplendidUI);
				//Sql.AddScriptReference(mgrAjax, sBundleName);
				
				// 07/01/2017 Paul.  SignalR cannot be combined. 
				//sBundleName = "~/html5/SignalRCombined";
				//Bundle bndSignalR = new Bundle(sBundleName);
				//bndSignalR.Include("~/html5/SignalR/jquery.signalR-2.4.1.min.js"       );
				//bndSignalR.Include("~/html5/SignalR/server.js"                         );
				//bndSignalR.Include("~/html5/SignalR/connection.start.js"               );
				//bndSignalR.Include("~/html5/SplendidUI/ChatDashboardUI.js"             );
				//BundleTable.Bundles.Add(bndSignalR);
				//Sql.AddScriptReference(mgrAjax, sBundleName);
				// 01/10/2017 Paul.  Add support for ADFS or Azure AD Single Sign on. 
				// 07/03/2017 Paul.  There seems to be a combining issue, so keep adal hard-coded. 
				//bndScripts.Include("~/html5/adal.min.js"                               );
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			RegisterScripts(this.Page);
			if ( !IsPostBack )
			{
				try
				{
					ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
					ChatManager.RegisterScripts(Context, mgrAjax);
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				}
			}
			if ( !Sql.ToBoolean(Request["debug"]) )
			{
				// 09/04/2013 Paul.  ASP.NET 4.5 is enforcing a rule that the root be an HtmlElement and not an HtmlGenericControl. 
				// 10/16/2016 Paul.  Remove offline ability. 
				//HtmlContainerControl htmlRoot = FindControl("htmlRoot") as HtmlContainerControl;
				//if ( htmlRoot != null )
				//	htmlRoot.Attributes.Add("manifest", "manifest.aspx");
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

