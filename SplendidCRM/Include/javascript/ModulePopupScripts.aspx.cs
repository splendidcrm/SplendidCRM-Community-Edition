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
using System.Web;
using System.Data;
using System.Data.Common;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace SplendidCRM.JavaScript
{
	/// <summary>
	/// Summary description for ModulePopupScripts.
	/// </summary>
	public class ModulePopupScripts : System.Web.UI.Page
	{
		protected DataView vwModulePopups;

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 11/20/2009 Paul.  The module popup scripts do not change frequently and when the do, they get a new parameter. 
			Response.Cache.SetCacheability(HttpCacheability.Public);
			Response.Cache.SetExpires(DateTime.Now.AddDays(1));
			// 03/31/2012 Paul.  Chrome is returning a warning: Resource interpreted as Script but transferred with MIME type text/html. 
			Response.ContentType = "application/x-javascript";
			try
			{
				DataTable dt = SplendidCache.ModulesPopups(HttpContext.Current);
				vwModulePopups = new DataView(dt);
				vwModulePopups.RowFilter = "HAS_POPUP = 1";
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

