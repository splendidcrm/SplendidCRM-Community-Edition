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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration
{
	/// <summary>
	///		Summary description for SystemView.
	/// </summary>
	public class SystemView : SplendidControl
	{
		protected Label lblError;

		// 09/11/2007 Paul.  Provide quick access to team management flags. 
		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				// 10/21/2016 Paul.  Provide quicker access to ShowSQL. 
				if ( e.CommandName == "System.ShowSQL" )
				{
					SqlProcs.spCONFIG_Update("system", "show_sql", "true");
					Application["CONFIG.show_sql"] = true;
				}
				else if ( e.CommandName == "System.HideSQL" )
				{
					SqlProcs.spCONFIG_Update("system", "show_sql", "false");
					Application["CONFIG.show_sql"] = false;
				}
				else if ( e.CommandName == "System.Reload" )
				{
					// 01/18/2008 Paul.  Speed the reload by doing directly instead of going to SystemCheck page. 
					// 10/26/2008 Paul.  IIS7 Integrated Pipeline does not allow HttpContext access inside Application_Start. 
					SplendidInit.InitApp(HttpContext.Current);
					SplendidInit.LoadUserPreferences(Security.USER_ID, Sql.ToString(Session["USER_SETTINGS/THEME"]), Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
				}
				else if ( e.CommandName == "System.PurgeDemo" )
				{
					// 09/22/2010 Paul.  Provide a way to purge demo data. 
					SqlProcs.spSqlPurgeDemoData();
				}
				// 03/04/2019 Paul.  Provide a way to rebuild the archive tables. 
				else if ( e.CommandName == "System.RebuildArchive" )
				{
					if ( Sql.IsEmptyString(Context.Application["ArchiveConnectionString"]) )
					{
						SqlProcs.spMODULES_ArchiveBuildAll();
					}
				}
				Response.Redirect("default.aspx");
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
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
