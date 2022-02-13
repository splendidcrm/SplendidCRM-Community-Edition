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

namespace SplendidCRM.Themes.Seven
{
	public partial class DefaultView : SplendidMaster
	{
		protected L10N         L10n;

		protected HtmlTable          tblLoginHeader    ;
		protected System.Web.UI.WebControls.Image imgCompanyLogo;
		// 03/01/2014 Paul.  Add Preview panel. 
		protected string             m_sMODULE         ;
		// 07/10/2015 Paul.  Allow DetailView to have a different dashboard flag. 
		protected string             m_sDASHBOARD      = "Dashboard";
		protected TableCell          tdPreview         ;
		protected HiddenField        hidPreviewID      ;
		protected _controls.Preview  ctlPreview        ;
		// 03/04/2014 Paul.  Add Dashboard panel. 
		protected HiddenField        hidDashboardShow  ;
		protected ImageButton        btnDashboardHide  ;
		protected ImageButton        btnDashboardShow  ;
		protected TableCell          tdDashboard       ;
		protected PlaceHolder        plcDashboard      ;
		
		private void ShowDashboard()
		{
			// 03/09/2014 Paul.  Test for existance of each control so that this could could be used as the code-behind for multiple master pages. 
			// 07/10/2015 Paul.  Need to include the ShowPreview flag when determining the state of the Show/Hide button. 
			bool bShowPreview = false;
			if ( hidPreviewID != null )
			{
				bShowPreview = !Sql.IsEmptyString(hidPreviewID.Value) && (SplendidCRM.Security.GetUserAccess(m_sMODULE, "view") >= 0);
				if ( tdPreview  != null ) tdPreview .Visible =  bShowPreview  ;
				if ( ctlPreview != null ) ctlPreview.Visible =  bShowPreview  ;
			}
			if ( hidDashboardShow != null )
			{
				bool bShowDashboard =  Sql.ToBoolean(hidDashboardShow.Value);
				if ( tdDashboard      != null ) tdDashboard     .Visible =  bShowDashboard;
				// 07/10/2015 Paul.  Need to include the ShowPreview flag when determining the state of the Show/Hide button. 
				if ( btnDashboardHide != null ) btnDashboardHide.Visible =  (bShowDashboard || bShowPreview);
				if ( btnDashboardShow != null ) btnDashboardShow.Visible = !(bShowDashboard || bShowPreview);
			}
		}

		protected string CookieValue(string sName)
		{
			string sValue = String.Empty;
			if ( Request.Cookies[sName] != null )
			{
				sValue = Request.Cookies[sName].Value;
			}
			return sValue;
		}

		public override void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Preview" )
				{
					Guid   gID          = Guid.Empty;
					string sMODULE_NAME = m_sMODULE ;
					// 06/29/2018 Paul.  Pass ArchiveView flag. 
					bool   bArchiveView = false     ;
					// 06/07/2015 Paul.  SubPanels will specify the Module. 
					if ( e.CommandArgument is PreviewData )
					{
						PreviewData obj = e.CommandArgument as PreviewData;
						gID          = obj.ID    ;
						sMODULE_NAME = obj.Module;
						bArchiveView = obj.ArchiveView;
					}
					else
					{
						gID = Sql.ToGuid(e.CommandArgument);
					}
					if ( !Sql.IsEmptyString(sMODULE_NAME) && !Sql.IsEmptyGuid(gID) )
					{
						if ( hidPreviewID     != null ) hidPreviewID.Value = gID.ToString();
						if ( hidDashboardShow != null ) hidDashboardShow.Value = "0";
						ShowDashboard();
						// 06/07/2015 Paul.  LoadPreview now requires the module be specified. 
						// 06/29/2018 Paul.  Pass ArchiveView flag. 
						if ( ctlPreview != null )
							ctlPreview.LoadPreview(sMODULE_NAME, gID, bArchiveView);
					}
				}
				else if ( e.CommandName == "Preview.Hide" )
				{
					if ( hidPreviewID != null ) hidPreviewID.Value = String.Empty;
					ShowDashboard();
				}
				else if ( e.CommandName == "AddDashlets" )
				{
					Response.Redirect("~/Home/AddDashlets.aspx?Module=" + m_sMODULE);
				}
				else if ( e.CommandName == "Dashboard.Hide" )
				{
					// 07/10/2015 Paul.  Allow DetailView to have a different dashboard flag. 
					HttpCookie cShowDashboard = new HttpCookie(m_sMODULE + "." + m_sDASHBOARD, "0");
					cShowDashboard.Expires = new DateTime(1980, 1, 1, 0, 0, 0, 0);
					cShowDashboard.Path    = "/";
					Response.Cookies.Add(cShowDashboard);
					
					if ( hidPreviewID     != null ) hidPreviewID.Value = String.Empty;
					if ( hidDashboardShow != null ) hidDashboardShow.Value = "0";
					ShowDashboard();
				}
				else if ( e.CommandName == "Dashboard.Show" )
				{
					// 07/10/2015 Paul.  Allow DetailView to have a different dashboard flag. 
					HttpCookie cShowDashboard = new HttpCookie(m_sMODULE + "." + m_sDASHBOARD, "1");
					cShowDashboard.Expires = new DateTime(2020, 1, 1, 0, 0, 0, 0);
					cShowDashboard.Path    = "/";
					Response.Cookies.Add(cShowDashboard);
					
					if ( hidPreviewID     != null ) hidPreviewID.Value = String.Empty;
					if ( hidDashboardShow != null ) hidDashboardShow.Value = "1";
					ShowDashboard();
					// 07/10/2015 Paul.  Transfer is causing a problem with the UpdatePanel code. 
					//Server.Transfer(Page.AppRelativeVirtualPath + (Sql.IsEmptyString(Page.ClientQueryString) ? String.Empty : "?" + Page.ClientQueryString));
					Response.Redirect(Page.AppRelativeVirtualPath + (Sql.IsEmptyString(Page.ClientQueryString) ? String.Empty : "?" + Page.ClientQueryString));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
		}

		public bool IsMobile
		{
			get
			{
				return (Page.Theme == "Mobile");
			}
		}

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
			if ( L10n == null )
			{
				L10n = Context.Items["L10n"] as L10N;
				if ( L10n == null )
				{
					string sCULTURE  = Sql.ToString(Session["USER_SETTINGS/CULTURE"]);
					L10n = new L10N(sCULTURE);
				}
			}
			return L10n;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
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
					// 03/09/2014 Paul.  Read the cookie value when the page loads. 
					if ( hidDashboardShow != null && !Sql.IsEmptyString(m_sMODULE) )
					{
						// 07/10/2015 Paul.  Allow DetailView to have a different dashboard flag. 
						hidDashboardShow.Value = CookieValue(m_sMODULE + "." + m_sDASHBOARD);
					}
					
					if ( !Security.IsAuthenticated() )
					{
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
					}
				}
				catch
				{
				}
			}
			ShowDashboard();
			
			ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
			Utils.RegisterJQuery(Page, mgrAjax);
			if ( !Sql.IsEmptyString(Session["EXTENSION"]) )
			{
				AsteriskManager.RegisterScripts(Context, mgrAjax);
				AvayaManager.RegisterScripts(Context, mgrAjax);
			}
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

			string[] arrPath = Page.AppRelativeVirtualPath.Split('/');
			if ( arrPath.Length > 1 )
			{
				m_sMODULE = arrPath[1];
				if ( m_sMODULE == "Administration" && arrPath.Length > 2 && !arrPath[2].EndsWith(".aspx") )
					m_sMODULE = arrPath[2];
				else if ( m_sMODULE == "Projects" )
					m_sMODULE = "Project";
				else if ( m_sMODULE == "ProjectTasks" )
					m_sMODULE = "ProjectTask";
			}
			if ( !Sql.IsEmptyString(m_sMODULE) )
			{
				// 06/07/2015 Paul.  The preview module will be set when the preview button is pressed. 
				//if ( ctlPreview != null )
				//	ctlPreview.Module = m_sMODULE;
				if ( plcDashboard != null && Page is SplendidPage )
				{
					// 07/10/2015 Paul.  Allow DetailView to have a different dashboard flag. 
					(Page as SplendidPage).AppendDetailViewRelationships(m_sMODULE + "." + m_sDASHBOARD, plcDashboard, Security.USER_ID);
				}
			}
			base.OnInit(e);
		}
		#endregion
	}
}

