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
using System.Diagnostics;

namespace SplendidCRM.Home
{
	/// <summary>
	/// Summary description for AddDashlets.
	/// </summary>
	public class AddDashlets : SplendidPage
	{
		// 03/06/2014 Paul.  Allow AddDashlets to be used by other modules. 
		protected ArrangeDashlets ctlDashletsBody ;
		protected ArrangeDashlets ctlDashletsRight;
		protected string sModule;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "CloseDashlets" )
			{
				// 03/06/2014 Paul.  Allow AddDashlets to be used by other modules. 
				if ( !Sql.IsEmptyString(sModule) && Sql.ToBoolean(Application["Modules." + sModule + ".Valid"]) )
					Response.Redirect("~/" + sModule + "/");
				else
					// 06/15/2017 Paul.  Add support for HTML5 Home Page. 
					Response.Redirect(Sql.ToString(Application["Modules.Home.RelativePath"]));
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".LBL_BROWSER_TITLE"));
			if ( !IsPostBack )
			{
				// 03/06/2014 Paul.  Allow AddDashlets to be used by other modules. 
				if ( !Sql.IsEmptyString(sModule) && Sql.ToBoolean(Application["Modules." + sModule + ".Valid"]) )
					ctlDashletsRight.Visible = false;
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
			SetMenu("Home");
			this.Load += new System.EventHandler(this.Page_Load);
			sModule = Sql.ToString(Request["Module"]);
			// 03/06/2014 Paul.  Allow AddDashlets to be used by other modules. 
			if ( !Sql.IsEmptyString(sModule) && Sql.ToBoolean(Application["Modules." + sModule + ".Valid"]) )
				ctlDashletsBody.DetailView = sModule + ".Dashboard";
		}
		#endregion
	}
}

