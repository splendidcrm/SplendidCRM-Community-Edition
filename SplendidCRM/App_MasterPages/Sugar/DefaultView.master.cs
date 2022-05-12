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

namespace SplendidCRM.Themes.Sugar
{
	// 12/22/2015 Paul.  All master pages should inherit SplendidMaster. 
	public partial class DefaultView : SplendidMaster
	{
		protected L10N         L10n;

		protected ContentPlaceHolder cntUnifiedSearch;
		protected System.Web.UI.WebControls.Image imgCompanyLogo  ;
		
		protected PlaceHolder   phFooterMenu     ;
		protected DropDownList  lstTHEME         ;
		protected DropDownList  lstLANGUAGE      ;
		protected HtmlTableRow  trFooterMenu     ;
		protected HtmlTable     tblTheme         ;
		protected TableCell     tdShortcuts      ;
		protected bool          bShowLeftCol = true;
		protected Image         imgShowHandle    ;
		protected Image         imgHideHandle    ;
		protected bool          bDebug       = false;
		protected TextBox       txtUnifiedSearch ;
		protected ImageButton   btnUnifiedSearch ;

		public bool PrintView
		{
			get
			{
				bool bPrintView = Sql.ToBoolean(Context.Items["PrintView"]);
				return bPrintView;
			}
		}
		protected void lstTHEME_Changed(Object sender, EventArgs e)
		{
			// 05/04/2010 Paul.  Language may not be available in the master page. 
			SplendidInit.ChangeTheme(lstTHEME.SelectedValue, (lstLANGUAGE != null ? lstLANGUAGE.SelectedValue : String.Empty));
			Response.Redirect(Request.RawUrl);
		}

		protected void lstLANGUAGE_Changed(Object sender, EventArgs e)
		{
			// 05/04/2010 Paul.  Theme may not be available in the master page. 
			SplendidInit.ChangeTheme((lstTHEME != null ? lstTHEME.SelectedValue : String.Empty), lstLANGUAGE.SelectedValue);
			Response.Redirect(Request.RawUrl);
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
			if ( imgHideHandle != null || imgShowHandle != null || tdShortcuts != null )
			{
				if ( Request.Cookies["showLeftCol"] != null )
				{
					bShowLeftCol = Sql.ToBoolean(Request.Cookies["showLeftCol"].Value);
				}
				else
				{
					HttpCookie cShowLeftCol = new HttpCookie("showLeftCol", bShowLeftCol ? "true" : "false");
					cShowLeftCol.Expires = DateTime.Now.AddDays(30);
					cShowLeftCol.Path    = "/";
					Response.Cookies.Add(cShowLeftCol);
				}
			}
			// 12/26/2009 Paul.  The objects may not exist, so catch any errors. 
			try
			{
				if ( imgHideHandle != null )
				{
					imgHideHandle.Style.Remove("display");
					imgHideHandle.Style.Add("display",  bShowLeftCol ? "inline" : "none");
				}
				if ( imgShowHandle != null )
				{
					imgShowHandle.Style.Remove("display");
					imgShowHandle.Style.Add("display", !bShowLeftCol ? "inline" : "none");
				}
				if ( tdShortcuts != null )
				{
					tdShortcuts  .Style.Remove("display");
					tdShortcuts  .Style.Add("display",  bShowLeftCol ? "inline" : "none");
				}
			}
			catch
			{
			}
			if ( !IsPostBack )
			{
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
				// 04/28/2006 Paul.  If the user has not authenticated, then this must be during login.  Disable the search. 
				// 11/17/2007 Paul.  New function to determine if user is authenticated. 
				if ( !Security.IsAuthenticated() )
				{
					// 12/26/2009 Paul.  The objects may not exist, so catch any errors. 
					try
					{
						if ( cntUnifiedSearch != null )
						{
							cntUnifiedSearch.Visible = false;
						}
					}
					catch
					{
					}
				}
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
							imgCompanyLogo.ImageUrl = "~/App_Themes/Sugar/images/SplendidCRM_Logo.png";
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

			// 06/21/2009 Paul.  Move EnterKey processing to code-behind.  We don't need to use the AJAX Script manager because this code will not be part of an UpdatePanel. 
			// 06/21/2009 Paul.  Use RegisterStartupScript instead of RegisterClientScriptBlock so that the script will run after the control has been created. 
			// 07/14/2009 Paul.  Make sure not to register if the txtUnifiedSearch is not visible, otherwise a client-side exception will be thrown on the login page. 
			// 12/26/2009 Paul.  The objects may not exist, so catch any errors. 
			try
			{
				if ( cntUnifiedSearch != null && txtUnifiedSearch != null && btnUnifiedSearch != null )
				{
					if ( cntUnifiedSearch.Visible )
					{
						Page.ClientScript.RegisterStartupScript(typeof(System.String), txtUnifiedSearch.ClientID + "_EnterKey", Utils.RegisterEnterKeyPress(txtUnifiedSearch.ClientID, btnUnifiedSearch.ClientID));
						// 08/31/2012 Paul.  Apple and Android devices should support speech and handwriting. 
						if ( Utils.SupportsSpeech && Sql.ToBoolean(Application["CONFIG.enable_speech"]) )
						{
							txtUnifiedSearch.Attributes.Add("speech", "speech");
							txtUnifiedSearch.Attributes.Add("x-webkit-speech", "x-webkit-speech");
						}
					}
				}
			}
			catch
			{
			}

			DataTable dt = SplendidCache.TabMenu();
			// 05/04/2010 Paul.  The footer menu will not exist in the new theme. 
			if ( phFooterMenu != null )
			{
				string sSeparator = "  ";
				// 12/26/2009 Paul.  The objects may not exist, so catch any errors. 
				try
				{
					// 04/28/2006 Paul.  Hide the footer menu if there is no menu to display. 
					if ( dt.Rows.Count == 0 )
					{
						if ( trFooterMenu != null )
							trFooterMenu.Visible = false;
						if ( tblTheme != null )
							tblTheme    .Visible = false;
					}
					int nRow = 0;
					int nDisplayedTabs = 0;
					int nMaxTabs = Sql.ToInteger(Session["max_tabs"]);
					// 09/24/2007 Paul.  Max tabs is a config variable and needs the CONFIG in front of the name. 
					if ( nMaxTabs == 0 )
						nMaxTabs = Sql.ToInteger(Application["CONFIG.default_max_tabs"]);
					if ( nMaxTabs == 0 )
						nMaxTabs = 12;
					for ( ; nRow < dt.Rows.Count; nRow++ )
					{
						DataRow row = dt.Rows[nRow];
						Literal litSeparator = new Literal();
						litSeparator.Text = sSeparator;
						phFooterMenu.Controls.Add(litSeparator);
						
						HyperLink lnk = new HyperLink();
						// 05/31/2007 Paul.  Don't specify an ID for the control.  
						// A customer reported an error with a duplicate entry.
						//lnk.ID          = "lnkFooter" + Sql.ToString(row["DISPLAY_NAME"]) ;
						lnk.NavigateUrl = Sql.ToString(row["RELATIVE_PATH"]);
						lnk.Text        = L10n.Term(Sql.ToString(row["DISPLAY_NAME"]));
						lnk.CssClass    = "footerLink";
						phFooterMenu.Controls.Add(lnk);
						
						nDisplayedTabs++;
						if ( nDisplayedTabs % nMaxTabs == 0 )
							sSeparator = "\r\n<br />\r\n";
						else
							sSeparator = "\r\n| ";
					}
				}
				catch
				{
				}
			}
			// 04/28/2006 Paul.  No need to populate the lists if they are not going to be displayed. 
			if ( !IsPostBack && dt.Rows.Count > 0 )
			{
				try
				{
					// 05/04/2010 Paul.  Language may not be available in the master page. 
					if ( lstLANGUAGE != null )
					{
						lstLANGUAGE.DataSource = SplendidCache.Languages();
						lstLANGUAGE.DataBind();
					}
					// 05/04/2010 Paul.  Theme may not be available in the master page. 
					if ( lstTHEME != null )
					{
						lstTHEME.DataSource = SplendidCache.Themes();
						lstTHEME.DataBind();
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetSelectedValue(lstTHEME, Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/THEME"]));
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				}

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
				try
				{
					// 05/04/2010 Paul.  Language may not be available in the master page. 
					if ( lstLANGUAGE != null )
					{
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetSelectedValue(lstLANGUAGE, L10n.NAME);
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

