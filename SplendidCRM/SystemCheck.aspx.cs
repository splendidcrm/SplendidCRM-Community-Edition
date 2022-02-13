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
using System.Web;
using System.Diagnostics;
using System.Reflection;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SystemCheck.
	/// </summary>
	public class SystemCheck : System.Web.UI.Page
	{
		protected string sMachineName = String.Empty;
		protected string sSqlVersion  = String.Empty;
		protected System.Web.Configuration.ProcessModelSection processModel;

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				// 09/17/2009 Paul.  Azure does not support MachineName.  Just ignore the error. 
				sMachineName = System.Environment.MachineName;
				// 09/20/2015 Paul.  Add process information. 
				// http://www.williablog.net/williablog/post/2008/12/02/Increase-ASPNET-Scalability-Instantly.aspx
				processModel = new System.Web.Configuration.ProcessModelSection();
			}
			catch
			{
			}
			
			// 01/20/2006 Paul.  Expire immediately. 
			Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			try
			{
				// 11/20/2005 Paul.  ASP.NET 2.0 has a namespace conflict, so we need the full name for the SplendidCRM factory. 
				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					// 09/27/2009 Paul.  Show SQL version. 
					if ( Sql.IsSQLServer(con) )
					{
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = "select @@VERSION";
							sSqlVersion = Sql.ToString(cmd.ExecuteScalar());
							sSqlVersion = sSqlVersion.Replace("\n", "<br>\n");
						}
					}
				}
			}
			catch(Exception ex)
			{
				// 01/27/2009 Paul.  By removing this app variable, the application will reload itself on the next page request. 
				Application.Remove("imageURL");
				//SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				// 06/21/2007 Paul.  Display inner exception if exists. 
				if ( ex.InnerException != null )
					Response.Write(ex.InnerException.Message + "<br>");
				Response.Write(ex.Message + "<br>");
			}
			
			try
			{
				// 08/17/2006 Paul.  A customer reported a problem with a view missing columns.  
				// Provide a way to recompile the views. 
				if ( Request.QueryString["Recompile"] == "1" || Request.QueryString["Reload"] == "1" || Sql.IsEmptyString(Application["imageURL"]) )
				{
					// 12/20/2005 Paul.  Require admin rights to reload. 
					if ( SplendidCRM.Security.IS_ADMIN )
					{
						if ( Request.QueryString["Recompile"] == "1" )
						{
							Utils.RefreshAllViews();
						}
						// 10/26/2008 Paul.  IIS7 Integrated Pipeline does not allow HttpContext access inside Application_Start. 
						SplendidInit.InitApp(HttpContext.Current);
						// 11/17/2007 Paul.  New function to determine if user is authenticated. 
						if ( Security.IsAuthenticated() )
							SplendidInit.LoadUserPreferences(Security.USER_ID, Sql.ToString(Session["USER_SETTINGS/THEME"]), Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
					}
					else
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), "You must be an administrator to reload the application.");
						Response.Write("You must be an administrator to reload the application." + "<br>");
					}
				}
				// 11/20/2009 Paul.  Provide a way to turn on or off the mobile theme. 
				if ( Request.QueryString["Mobile"] == "1" )
				{
					string sTheme = SplendidDefaults.MobileTheme();
					if ( System.IO.Directory.Exists(Context.Server.MapPath("~/App_MasterPages/" + sTheme)) )
					{
						// 11/30/2012 Paul.  Update the themeURL. 
						string sApplicationPath = Sql.ToString(HttpContext.Current.Application["rootURL"]);
						Session["USER_SETTINGS/THEME"] = sTheme;
						Session["themeURL"           ] = sApplicationPath + "App_Themes/" + sTheme + "/";
					}
				}
				else if ( Request.QueryString["Mobile"] == "0" )
				{
					// 11/30/2012 Paul.  Save the default them for the user, as specified in the preferences. 
					// This is to allow the user to go from the Mobile theme to the full site. 
					string sTheme = Sql.ToString(Session["USER_SETTINGS/DEFAULT_THEME"]);
					if ( Sql.IsEmptyString(sTheme) )
						sTheme = SplendidDefaults.Theme();
					if ( System.IO.Directory.Exists(Context.Server.MapPath("~/App_MasterPages/" + sTheme)) )
					{
						// 11/30/2012 Paul.  Update the themeURL. 
						string sApplicationPath = Sql.ToString(HttpContext.Current.Application["rootURL"]);
						Session["USER_SETTINGS/THEME"] = sTheme;
						Session["themeURL"           ] = sApplicationPath + "App_Themes/" + sTheme + "/";
					}
				}
			}
			catch(Exception ex)
			{
				//SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.Write(ex.Message + "<br>");
			}
			Page.DataBind();
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

