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
using System.Text;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for RestUtils.
	/// </summary>
	public class RestUtils : SplendidControl
	{
		protected DataTable dtModules;

		// 05/09/2016 Paul.  Move AddScriptReference and AddStyleSheet to Sql object. 
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/19/2016 Paul.  Move Ajax registration ot RestUtils.ascx. 
			AjaxControlToolkit.ToolkitScriptManager mgrAjax = ScriptManager.GetCurrent(Page) as AjaxControlToolkit.ToolkitScriptManager;
			// 01/28/2018 Paul.  We need to paginate the popup to support large data sets. 
			Sql.AddScriptReference(mgrAjax, "~/html5/jQuery/jquery.paging.min.js");
			// 05/09/2016 Paul.  Move javascript objects to separate file. 
			Sql.AddScriptReference(mgrAjax, "~/include/javascript/RestUtils.js");
			Sql.AddScriptReference(mgrAjax, "~/html5/SplendidUI/Formatting.js");
			Sql.AddScriptReference(mgrAjax, "~/html5/SplendidUI/Sql.js"       );
			// 01/28/2018 Paul.  SearchBuilder is needed for parent popup. 
			Sql.AddScriptReference(mgrAjax, "~/html5/SplendidUI/SearchBuilder.js");
			
			// 01/24/2018 Paul.  The Calendar needs to determine if Calls module is enabled. 
			dtModules = SplendidCache.AccessibleModulesTable(HttpContext.Current, Security.USER_ID);
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

