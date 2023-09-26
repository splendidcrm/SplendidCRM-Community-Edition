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
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for Default.
	/// </summary>
	public class Default : SplendidPage
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 11/06/2009 Paul.  If this is an offline client installation, then redirect to the client login page. 
			// 11/24/2009 Paul.  We only need to link to the login if not authenticated. 
			if ( Utils.IsOfflineClient && !Security.IsAuthenticated() )
				Response.Redirect("~/Users/ClientLogin.aspx");
			else
			{
				// 09/21/2008 Paul.  Mono is case significant and all default pages are lower case. 
				// 06/15/2017 Paul.  Add support for HTML5 Home Page. 
				// 09/24/2023 Paul.  Stay on ASP pages even if react enabled. 
				string sHomePage = Sql.ToString(Application["Modules.Home.RelativePath"]);
				if ( sHomePage.ToLower().StartsWith("~/react") )
				{
					sHomePage = "~/Home";
				}
				Response.Redirect(sHomePage);
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

