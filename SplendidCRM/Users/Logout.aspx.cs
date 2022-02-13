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
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Users
{
	/// <summary>
	/// Summary description for Logout.
	/// </summary>
	public class Logout : SplendidPage
	{
		override protected bool AuthenticationRequired()
		{
			return false;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 02/28/2007 Paul.  Centralize session reset to prepare for WebParts. 
			//Security.Clear();
			//SplendidInit.InitSession();
			// 01/08/2008 Paul.  Clear and InitSession are not working.  The user remains authenticated.
			// Abandon works much better. 
			// 04/15/2008 Paul.  Although we are going to continue to use Abandon, the original problem 
			// was likely due to the identity being set inside Global.assx Application_AcquireRequestState
			// whereby we were setting the HttpContext.Current.User = GenericPrincipal().
			// Resetting the identity very likely would have fixed the issue with the user remaining authenticated. 
			try
			{
				Guid gUSER_LOGIN_ID = Security.USER_LOGIN_ID;
				if ( !Sql.IsEmptyGuid(gUSER_LOGIN_ID) )
					SqlProcs.spUSERS_LOGINS_Logout(gUSER_LOGIN_ID);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}

			Session.Abandon();
			// 11/15/2014 Paul.  Prevent resuse of SessionID. 
			// http://support.microsoft.com/kb/899918
			Response.Cookies.Add(new HttpCookie("ASP.NET_SessionId", ""));
			// 12/25/2018 Paul.  Logout should perform Azure or ADFS logout. 
			if ( Sql.ToBoolean(Application["CONFIG.ADFS.SingleSignOn.Enabled"]) )
			{
				string sRequestURL = ActiveDirectory.FederationServicesLogout(Context);
				Response.Redirect(sRequestURL);
			}
			else if ( Sql.ToBoolean(Application["CONFIG.Azure.SingleSignOn.Enabled"]) )
			{
				string sRequestURL = ActiveDirectory.AzureLogout(Context);
				Response.Redirect(sRequestURL);
			}
			else
			{
				Response.Redirect("Login.aspx");
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

