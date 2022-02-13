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
using System.Net;
using System.Threading;
using System.Security.Principal;
using System.Text.RegularExpressions;
using System.Configuration;
using System.Web.Configuration;
using System.Diagnostics;

namespace SplendidCRM 
{
	/// <summary>
	/// Summary description for Global.
	/// </summary>
	public class Global : System.Web.HttpApplication
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;
// 12/03/2021 Paul.  An empty app does not support email. 
#if !SplendidApp
		private Timer tSchedulerManager = null;
		private Timer tEmailManager     = null;

		public void InitSchedulerManager()
		{
			if ( tSchedulerManager == null )
			{
				// 05/19/2008 Paul.  The timer will fire every 5 minutes.  If decreased to 1 minute, then vwSCHEDULERS_Run must be modified to round to 1 minute. 
				// 10/30/2008 Paul.  The time now requires the Context be passed. 
				tSchedulerManager = new Timer(SchedulerUtils.OnTimer, this.Context, new TimeSpan(0, 1, 0), new TimeSpan(0, 5, 0));
				SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "The Scheduler Manager timer has been activated.");
			}
		}

		// 12/25/2012 Paul.  Use a separate timer for email reminders as they are timely and cannot be stuck behind other scheduler tasks. 
		public void InitEmailManager()
		{
			if ( tEmailManager == null )
			{
				tEmailManager = new Timer(EmailUtils.OnTimer, this.Context, new TimeSpan(0, 1, 0), new TimeSpan(0, 1, 0));
				SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "The Email Manager timer has been activated.");
			}
		}
#endif
		public Global()
		{
			InitializeComponent();
		}

		protected void Application_OnError(Object sender, EventArgs e)
		{
			//SplendidInit.Application_OnError();
		}
		
		protected void Application_Start(Object sender, EventArgs e)
		{
			// 11/04/2008 Paul.  IIS7 does not provide access to Request object, so we cannot determine the database connection from the URL. 
			// 09/02/2013 Paul.  SignalR may throw exceptions and we need to make sure that they don't crash the entire app. 
			System.Threading.Tasks.TaskScheduler.UnobservedTaskException += new EventHandler<System.Threading.Tasks.UnobservedTaskExceptionEventArgs>(TaskScheduler_UnobservedTaskException);
			// 03/06/2020 Paul.  TLS12 is now required by all cloud services. 
			if ( !ServicePointManager.SecurityProtocol.HasFlag(SecurityProtocolType.Tls12) )
			{
				ServicePointManager.SecurityProtocol = ServicePointManager.SecurityProtocol | SecurityProtocolType.Tls12;
			}
		}

		private void TaskScheduler_UnobservedTaskException(object sender, System.Threading.Tasks.UnobservedTaskExceptionEventArgs e)
		{
			e.SetObserved();
		}

		// https://techcommunity.microsoft.com/t5/iis-support-blog/samesite-in-code-for-your-asp-net-applications/ba-p/1156361
		private bool DisallowsSameSiteNone(string userAgent)
		{
			// check if the user agent is null or empty
			if ( String.IsNullOrWhiteSpace(userAgent) )
				return false;

			// Cover all iOS based browsers here. This includes:
			// - Safari on iOS 12 for iPhone, iPod Touch, iPad
			// - WkWebview on iOS 12 for iPhone, iPod Touch, iPad
			// - Chrome on iOS 12 for iPhone, iPod Touch, iPad
			// All of which are broken by SameSite=None, because they use the iOS networking stack.
			if ( userAgent.Contains("CPU iPhone OS 12") || userAgent.Contains("iPad; CPU OS 12") )
			{
				return true;
			}

			// Cover Mac OS X based browsers that use the Mac OS networking stack. 
			// This includes:
			// - Safari on Mac OS X.
			// This does not include:
			// - Chrome on Mac OS X
			// Because they do not use the Mac OS networking stack.
			if ( userAgent.Contains("Macintosh; Intel Mac OS X 10_14") && userAgent.Contains("Version/") && userAgent.Contains("Safari") )
			{
				return true;
			}

			// Cover Chrome 50-69, because some versions are broken by SameSite=None, 
			// and none in this range require it.
			// Note: this covers some pre-Chromium Edge versions, 
			// but pre-Chromium Edge does not require SameSite=None.
			// https://www.chromium.org/updates/same-site/incompatible-clients
			if ( userAgent.Contains("Chrome/5") || userAgent.Contains("Chrome/6") || userAgent.Contains("Android 6") )
			{
				return true;
			}
			return false;
		}
		
		protected void Session_Start(Object sender, EventArgs e)
		{
			// 08/05/2020 Paul.  Add support for SameSite using ASP.Net 4.7.2. 
			// https://techcommunity.microsoft.com/t5/iis-support-blog/samesite-in-code-for-your-asp-net-applications/ba-p/1156361
			// get the useragent for the request
			string currentUserAgent = HttpContext.Current.Request.UserAgent;

			// decide if we need to strip off the same site attribute for older browsers
			bool dissallowSameSiteFlag = DisallowsSameSiteNone(currentUserAgent);

			// get the name of the cookie, if not defined default to the "ASP.NET_SessionID" value
			SessionStateSection sessionStateSection = (SessionStateSection) ConfigurationManager.GetSection("system.web/sessionState");
			string sessionCookieName;
			if ( sessionStateSection != null )
			{
				// read the name from the configuration
				sessionCookieName = sessionStateSection.CookieName;
			}
			else
			{
				sessionCookieName = "ASP.NET_SessionId";
			}

			// while we're at it lets also make it secure
			// 08/07/2020 Paul.  Requires .NET 4.8 for SameSite=None to be sent. 
			if ( Request.IsSecureConnection )
				Response.Cookies[sessionCookieName].Secure = true;
			
			// should the flag be positioned to true, then remove the attribute by setting
			// value to SameSiteMode.None
			// 08/05/2020 Paul.  ASP.Net 4.7.2 or higher is required to support SameSite property. 
			if ( dissallowSameSiteFlag )
				Response.Cookies[sessionCookieName].SameSite = (SameSiteMode)(-1);
			// 08/07/2020 Paul.  SameSiteMode.None requires a secure connection. 
			else if ( Request.IsSecureConnection )
				Response.Cookies[sessionCookieName].SameSite = SameSiteMode.None;
			else
				Response.Cookies[sessionCookieName].SameSite = SameSiteMode.Lax;
			// 12/29/2020 Paul.  Path is not getting set.  Not sure if this is a new .NET 4.8 issue or older, but seems likely due to SameSite changes. 
			Response.Cookies[sessionCookieName].Path = Request.ApplicationPath;
			SplendidInit.InitSession(this.Context);
		}

		protected void Application_BeginRequest(Object sender, EventArgs e)
		{
			// 11/04/2008 Paul.  IIS7 does not provide access to Request object from Application_Start. Move code to Application_BeginRequest. 
			if ( Application.Count == 0 )
			{
				SplendidInit.InitApp(this.Context);
// 12/03/2021 Paul.  An empty app does not support email or SignalR. 
#if !SplendidApp
				WorkflowInit.StartRuntime(this.Application);
				InitSchedulerManager();
				InitEmailManager();
				// 09/02/2018 Paul.  We have seen routing error and SignalR is the only routing change.  So provide a way to disable. 
				// [NullReferenceException: Object reference not set to an instance of an object.]
				// System.Web.Routing.RouteCollection.GetRouteData(HttpContextBase httpContext) +247
				if ( !Sql.ToBoolean(this.Context.Application["CONFIG.SignalR.Disabled"]) )
				{
					// 08/28/2013 Paul.  Add support for Twilio and SignalR. 
					TwilioManager.InitApp(this.Context);
					// 11/10/2014 Paul.  Add ChatManager support. 
					ChatManager.InitApp(this.Context);
					SignalRUtils.InitApp();
				}
#endif
			}
			// 09/24/2011 Paul.  We need to define a privacy policy so that cookies will not get rejected when SplendidCRM is used in an iframe. 
			// http://petesbloggerama.blogspot.com/2007/08/aspnet-loss-of-session-cookies-with.html
			string sP3P = Sql.ToString(Application["CONFIG.p3p"]);
			if ( Sql.IsEmptyString(sP3P) )
				sP3P = "CP=\"CAO PSA OUR\"";
			HttpContext.Current.Response.AddHeader("p3p", sP3P);
			// 11/15/2020 Paul.  Apple iOS requires CORS support. 
			// Instead of installing the IIS CORS Module, just allow any outside requests. 
			// https://www.iis.net/downloads/microsoft/iis-cors-module
			// 11/16/2020 Paul.  Now that we are using cordova-plugin-advanced-http, we no longer need to support CORS response headers. 
			/*
			//if ( HttpContext.Current.Request.HttpMethod == "OPTIONS" )
			{
				string sOrigin = "*";
				Debug.WriteLine(HttpContext.Current.Request.HttpMethod + " " + HttpContext.Current.Request.Path);
				foreach ( string sKey in HttpContext.Current.Request.Headers )
				{
					if ( sKey == "Origin" )
					{
						if ( HttpContext.Current.Request.Headers[sKey] == "null" )
						{
							sOrigin = HttpContext.Current.Request.Headers[sKey];
						}
						//Debug.WriteLine(sKey + ": " + HttpContext.Current.Request.Headers[sKey] );
					}
					//if ( sKey.StartsWith("Access-Control") )
					{
						Debug.WriteLine(sKey + ": " + HttpContext.Current.Request.Headers[sKey] );
					}
				}
				Debug.WriteLine("");
				HttpContext.Current.Response.AddHeader("Access-Control-Allow-Origin"     , sOrigin);
				HttpContext.Current.Response.AddHeader("Access-Control-Allow-Methods"    , "GET, POST, DELETE");
				HttpContext.Current.Response.AddHeader("Access-Control-Allow-Headers"    , "Content-Type, Accept, X-Requested-With");
				HttpContext.Current.Response.AddHeader("Access-Control-Allow-Credentials", "true");
				//HttpContext.Current.Response.AddHeader("Access-Control-Max-Age"          , "86400");  // 24 hours. 
			}
			*/

			// 12/29/2005 Paul.  vCalendar support is not going to be easy.
			// Outlook will automatically use FrontPage extensions to place the file. 
			// When connecting to a Apache server, it will make HTTP GET/PUT requests. 
			/*
			string sPath = HttpContext.Current.Request.Path.ToLower();
			Regex regex = new Regex("/vcal_server/(\\w+)", RegexOptions.IgnoreCase);
			MatchCollection matches = regex.Matches(sPath);
			//if ( sPath.IndexOf("/vcal_server/") >= 0 )
			if ( matches.Count > 0 )
			{
				//sPath = sPath.Replace("/vcal_server/", "/vcal_server.aspx?");
				sPath = "~/vcal_server.aspx?" + matches[0].Groups[1].ToString();
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), sPath);
				HttpContext.Current.RewritePath(sPath);
			}
			*/
			// 06/18/2019 Paul.  Rewrite the path so that any React parameters are ignored. 
			// 06/18/2019 Paul.  Try and be as efficient as possible as every request and every url will be checked. 
			// 06/18/2019 Paul.  We are just trying to allow the React style routing to be ignored by the web server, so any file extension url can be ignored. 
			if ( this.Context.Request.RequestType == "GET" )
			{
				string url = this.Context.Request.Path;
				if ( !url.Contains(".") )
				{
					url = url.ToLower();
					if ( url.Contains("/react/") )
					{
						string sApplicationPath = this.Request.ApplicationPath.ToLower();
						if ( !sApplicationPath.EndsWith("/") )
							sApplicationPath += "/";
						string sReactPath = sApplicationPath + "react/";
						if ( url.StartsWith(sReactPath) )
						{
							url = sReactPath + "default.aspx";
							//Debug.WriteLine("Rewrite " + this.Context.Request.Path + " to " + url);
							this.Context.RewritePath(url);
						}
					}
				}
			}
		}

		protected void Application_EndRequest(Object sender, EventArgs e)
		{

		}

		protected void Application_AuthenticateRequest(Object sender, EventArgs e)
		{

		}

		protected void Application_AcquireRequestState(Object sender, EventArgs e)
		{
			// 03/04/2007 Paul.  The Session will be NULL during web service calls. 
			// We noticed this problem when AJAX failed in ScriptResource.axd. 
			if ( HttpContext.Current.Session != null )
			{
				// 02/28/2007 Paul.  Although Application_AuthenticateRequest might seem like the best place for this code,
				// we have to wait until the Session variables have been initialized to determine if the user has been authenticated. 
				if ( !Sql.IsEmptyString(HttpContext.Current.Session["USER_NAME"]) )
				{
					// 02/28/2007 Paul.  WebParts requires a valid User identity.  
					// We must store the USER_NAME as this will be the lookup key when updating preferences. 
					if ( !HttpContext.Current.User.Identity.IsAuthenticated )
						HttpContext.Current.User = new GenericPrincipal(new GenericIdentity(Security.USER_NAME, "Forms"), null);
				}
			}
		}

		protected void Application_Error(Object sender, EventArgs e)
		{

		}

		protected void Session_End(Object sender, EventArgs e)
		{
			// 03/02/2008 Paul.  Log the logout. 
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

			// 10/29/2006 Paul.  Delete temp files. 
			foreach ( string sKey in Session.Keys )
			{
				if ( sKey.StartsWith("TempFile.") )
				{
					string sTempFileName = Sql.ToString(Session[sKey]);
					string sTempPathName = Path.Combine(Path.GetTempPath(), sTempFileName);
					if ( File.Exists(sTempPathName) )
					{
						try
						{
							File.Delete(sTempPathName);
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), "Could not delete temp file: " + sTempPathName + ControlChars.CrLf + ex.Message);
						}
					}
				}
			}
		}

		protected void Application_End(Object sender, EventArgs e)
		{
// 12/03/2021 Paul.  An empty app does not support email. 
#if !SplendidApp
			if ( tSchedulerManager != null )
				tSchedulerManager.Dispose();
			if ( tEmailManager != null )
				tEmailManager.Dispose();
			WorkflowInit.StopRuntime(this.Application);
#endif
			SplendidInit.StopApp(this.Context);
		}
			
		#region Web Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.components = new System.ComponentModel.Container();
		}
		#endregion
	}
}

