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
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Themes.Six
{
	// 12/22/2015 Paul.  All master pages should inherit SplendidMaster. 
	public partial class DefaultView : SplendidMaster
	{
		protected L10N         L10n;

		protected System.Web.UI.WebControls.Image imgCompanyLogo  ;
		
		protected bool          bDebug       = false;

		public bool PrintView
		{
			get
			{
				bool bPrintView = Sql.ToBoolean(Context.Items["PrintView"]);
				return bPrintView;
			}
		}
		public L10N GetL10n()
		{
			// 08/30/2005 Paul.  Attempt to get the L10n & T10n objects from the parent page. 
			// If that fails, then just create them because they are required. 
			if ( L10n == null )
			{
				// 04/30/2006 Paul.  Use the Context to store pointers to the localization objects.
				// This is so that we don't need to require that the page inherits from SplendidPage. 
				// A port to DNN prompted this approach. 
				L10n = Context.Items["L10n"] as L10N;
				if ( L10n == null )
				{
					string sCULTURE  = Sql.ToString(Session["USER_SETTINGS/CULTURE" ]);
					L10n = new L10N(sCULTURE);
				}
			}
			return L10n;
		}

		// 12/22/2015 Paul.  All master pages should inherit SplendidMaster. 
		public override void Page_Command(object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Admin.Reload" )
			{
				if( Security.IS_ADMIN )
				{
					// 10/26/2008 Paul.  IIS7 Integrated Pipeline does not allow HttpContext access inside Application_Start. 
					SplendidInit.InitApp(HttpContext.Current);
					// 11/17/2007 Paul.  New function to determine if user is authenticated. 
					if ( Security.IsAuthenticated() )
						SplendidInit.LoadUserPreferences(Security.USER_ID, Sql.ToString(Session["USER_SETTINGS/THEME"]), Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
					// 06/30/2007 Paul.  Perform a redirect so that the entire page will reload and rebind. 
					Response.Redirect(Request.RawUrl);
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
#if DEBUG
			bDebug = true;
#endif
			if ( !IsPostBack )
			{
				if ( imgCompanyLogo != null )
				{
					// 02/23/2009 Paul.  We need to catch all possible errors since this is user-input data. 
					try
					{
						// 04/16/2006 Paul.  Company logo can be customized. 
						if ( !Sql.IsEmptyString(Application["CONFIG.header_logo_image"]) )
						{
							// 02/23/2009 Paul.  Allow the logo to be any URL. 
							string sImageUrl = Sql.ToString(Application["CONFIG.header_logo_image"]);
							if ( sImageUrl.StartsWith("http", true, System.Threading.Thread.CurrentThread.CurrentCulture) )
								imgCompanyLogo.ImageUrl = sImageUrl;
							// 08/09/2009 Paul.  Allow the image to be relative to the application. 
							else if ( sImageUrl.StartsWith("~/") )
								imgCompanyLogo.ImageUrl = sImageUrl;
							else
								imgCompanyLogo.ImageUrl = "~/Include/images/" + sImageUrl;
							
							if ( Sql.ToInteger(Application["CONFIG.header_logo_width"]) > 0 )
								imgCompanyLogo.Width    = Sql.ToInteger(Application["CONFIG.header_logo_width" ]);
							if ( Sql.ToInteger(Application["CONFIG.header_logo_height"]) > 0 )
								imgCompanyLogo.Height   = Sql.ToInteger(Application["CONFIG.header_logo_height"]);
							if ( !Sql.IsEmptyString(Application["CONFIG.header_logo_style"]) )
								imgCompanyLogo.Attributes.Add("style", Sql.ToString(Application["CONFIG.header_logo_style"]));
							// 11/27/2008 Paul.  Company logo is a config value, not a term. 
							// 07/07/2010 Paul.  Fix company name.  The logo is a URL. 
							// 08/18/2010 Paul.  IE8 does not support alt any more, so we need to use ToolTip instead. 
							imgCompanyLogo.ToolTip = Sql.ToString(Application["CONFIG.company_name"]);
						}
						else
						{
							imgCompanyLogo.ImageUrl = "~/Include/images/SplendidCRM_Logo.gif";
							imgCompanyLogo.Width    = 207;
							imgCompanyLogo.Height   =  60;
							imgCompanyLogo.Attributes.Add("style", "margin-left: 10px");
							// 12/04/2008 Paul.  Company logo is a config value, not a term. 
							// 07/07/2010 Paul.  Fix company name.  The logo is a URL. 
							// 08/18/2010 Paul.  IE8 does not support alt any more, so we need to use ToolTip instead. 
							imgCompanyLogo.ToolTip = Sql.ToString(Application["CONFIG.company_name"]);
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					}
				}
			}

			if ( !IsPostBack )
			{
				try
				{
					// http://www.i18nguy.com/temp/rtl.html
					// 09/04/2013 Paul.  ASP.NET 4.5 is enforcing a rule that the root be an HtmlElement and not an HtmlGenericControl. 
					HtmlContainerControl htmlRoot = FindControl("htmlRoot") as HtmlContainerControl;
					if ( htmlRoot != null )
					{
						if ( L10n.IsLanguageRTL() )
						{
							htmlRoot.Attributes.Add("dir", "rtl");
						}
					}
				}
				catch
				{
				}
			}
			// 04/27/2012 Paul.  Need to add support for favorites as the icons are visible. 
			ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
			// 08/30/2013 Paul.  Move jQuery registration to Utils class. 
			Utils.RegisterJQuery(Page, mgrAjax);
			// 08/25/2013 Paul.  Register Asterisk and Signal-R scripts. 
			// 09/20/2013 Paul.  Move EXTENSION to the main table. 
			if ( !Sql.IsEmptyString(Session["EXTENSION"]) )
			{
				AsteriskManager.RegisterScripts(Context, mgrAjax);
				// 12/03/2013 Paul.  Add support for Avaya. 
				AvayaManager.RegisterScripts(Context, mgrAjax);
			}
			// 09/27/2013 Paul.  SMS messages need to be opt-in. 
			if ( Sql.ToString(Session["SMS_OPT_IN"]) == "yes" )
				TwilioManager.RegisterScripts(Context, mgrAjax);
			// 09/09/2020 Paul.  Add PhoneBurner SignalR support. 
			PhoneBurnerManager.RegisterScripts(Context, mgrAjax);
		}

		#region Web Form Designer generated code
		protected override void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			GetL10n();
			this.Load += new System.EventHandler(this.Page_Load);
			base.OnInit(e);
		}
		#endregion
	}
}

