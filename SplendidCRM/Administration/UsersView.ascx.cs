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

namespace SplendidCRM.Administration
{
	/// <summary>
	///		Summary description for UsersView.
	/// </summary>
	public class UsersView : SplendidControl
	{
		protected Label lblError;

		// 09/11/2007 Paul.  Provide quick access to team management flags. 
		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Teams.Enable"   )
				{
					SqlProcs.spCONFIG_Update("system", "enable_team_management", "true");
					Application["CONFIG.enable_team_management"] = true;
				}
				else if ( e.CommandName == "Teams.Disable"  )
				{
					SqlProcs.spCONFIG_Update("system", "enable_team_management", "false");
					Application["CONFIG.enable_team_management"] = false;
				}
				else if ( e.CommandName == "Teams.Require"  )
				{
					SqlProcs.spCONFIG_Update("system", "require_team_management", "true");
					Application["CONFIG.require_team_management"] = true;
				}
				else if ( e.CommandName == "Teams.Optional" )
				{
					SqlProcs.spCONFIG_Update("system", "require_team_management", "false");
					Application["CONFIG.require_team_management"] = false;
				}
				// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
				else if ( e.CommandName == "UserAssignement.Require"  )
				{
					SqlProcs.spCONFIG_Update("system", "require_user_assignment", "true");
					Application["CONFIG.require_user_assignment"] = true;
				}
				else if ( e.CommandName == "UserAssignement.Optional" )
				{
					SqlProcs.spCONFIG_Update("system", "require_user_assignment", "false");
					Application["CONFIG.require_user_assignment"] = false;
				}
				// 04/10/2009 Paul.  Make it easy to enable and disable admin delegation. 
				else if ( e.CommandName == "AdminDelegation.Enable"   )
				{
					SqlProcs.spCONFIG_Update("system", "allow_admin_roles", "true");
					Application["CONFIG.allow_admin_roles"] = true;
				}
				else if ( e.CommandName == "AdminDelegation.Disable"  )
				{
					SqlProcs.spCONFIG_Update("system", "allow_admin_roles", "false");
					Application["CONFIG.allow_admin_roles"] = false;
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
