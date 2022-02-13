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
using System.Data.Common;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Web.Optimization;
using System.Diagnostics;

namespace SplendidCRM.Administration.DynamicLayout.html5
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		// 05/09/2016 Paul.  Move AddScriptReference and AddStyleSheet to Sql object. 
		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Administration.LBL_STUDIO_TITLE"));
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				Parent.DataBind();
				return;
			}
			try
			{
				AjaxControlToolkit.ToolkitScriptManager mgrAjax = ScriptManager.GetCurrent(Page) as AjaxControlToolkit.ToolkitScriptManager;

				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				string sBundleName = "~/Administration/DynamicLayout/html5/SplendidScriptsCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndSplendidScripts = new Bundle(sBundleName);
				// 03/02/2016 Paul.  Use generic console.log to support IE9. 
				bndSplendidScripts.Include("~/html5/consolelog.min.js"                         );
				bndSplendidScripts.Include("~/html5/Utility.js"                                );
				bndSplendidScripts.Include("~/html5/SplendidUI/Formatting.js"                  );
				bndSplendidScripts.Include("~/html5/SplendidUI/Sql.js"                         );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Application.js"            );
				bndSplendidScripts.Include("~/html5/SplendidScripts/DetailView.js"             );
				bndSplendidScripts.Include("~/html5/SplendidScripts/ListView.js"               );
				bndSplendidScripts.Include("~/html5/SplendidScripts/EditView.js"               );
				bndSplendidScripts.Include("~/html5/SplendidScripts/Terminology.js"            );
				bndSplendidScripts.Include("~/html5/SplendidScripts/DetailViewRelationships.js");
				bndSplendidScripts.Include("~/html5/SplendidScripts/EditViewRelationships.js"  );
				BundleTable.Bundles.Add(bndSplendidScripts);
				Sql.AddScriptReference(mgrAjax, sBundleName);
				
#if DEBUG
				Sql.AddScriptReference(mgrAjax, "~/Administration/DynamicLayout/html5/AdminLayout.js"                   );
				Sql.AddScriptReference(mgrAjax, "~/Administration/DynamicLayout/html5/AdminLayoutUI.js"                 );
				Sql.AddScriptReference(mgrAjax, "~/Administration/DynamicLayout/html5/LayoutEditViewUI.js"              );
				Sql.AddScriptReference(mgrAjax, "~/Administration/DynamicLayout/html5/LayoutDetailViewUI.js"            );
				Sql.AddScriptReference(mgrAjax, "~/Administration/DynamicLayout/html5/LayoutListViewUI.js"              );
				Sql.AddScriptReference(mgrAjax, "~/Administration/DynamicLayout/html5/LayoutTerminologyUI.js"           );
				Sql.AddScriptReference(mgrAjax, "~/Administration/DynamicLayout/html5/LayoutEditViewRelationshipUI.js"  );
				Sql.AddScriptReference(mgrAjax, "~/Administration/DynamicLayout/html5/LayoutDetailViewRelationshipUI.js");
#else
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				sBundleName = "~/Administration/DynamicLayout/html5/DynamicLayoutCombined" + "_" + Sql.ToString(Application["SplendidVersion"]);
				Bundle bndDynamicLayout = new Bundle(sBundleName);
				bndDynamicLayout.Include("~/Administration/DynamicLayout/html5/AdminLayout.js"                   );
				bndDynamicLayout.Include("~/Administration/DynamicLayout/html5/AdminLayoutUI.js"                 );
				bndDynamicLayout.Include("~/Administration/DynamicLayout/html5/LayoutEditViewUI.js"              );
				bndDynamicLayout.Include("~/Administration/DynamicLayout/html5/LayoutDetailViewUI.js"            );
				bndDynamicLayout.Include("~/Administration/DynamicLayout/html5/LayoutListViewUI.js"              );
				bndDynamicLayout.Include("~/Administration/DynamicLayout/html5/LayoutTerminologyUI.js"           );
				bndDynamicLayout.Include("~/Administration/DynamicLayout/html5/LayoutEditViewRelationshipUI.js"  );
				bndDynamicLayout.Include("~/Administration/DynamicLayout/html5/LayoutDetailViewRelationshipUI.js");
				BundleTable.Bundles.Add(bndDynamicLayout);
				Sql.AddScriptReference(mgrAjax, sBundleName);
#endif
#if DEBUG
				Sql.AddScriptReference(mgrAjax, "~/Include/javascript/jquery.ztree.all-3.5.js"      );
#else
				Sql.AddScriptReference(mgrAjax, "~/Include/javascript/jquery.ztree.all-3.5.min.js"  );
#endif
				// 07/01/2017 Paul.  We cannot bundle jquery-ui or zTreeStyle.css as it will change its relative path to images. 
				Sql.AddStyleSheet(this.Page, "~/html5/jQuery/jquery-ui-1.9.1.custom.css");
				Sql.AddStyleSheet(this.Page, "~/Include/javascript/zTreeStyle.css"      );
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
			m_sMODULE = "DynamicLayout";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

