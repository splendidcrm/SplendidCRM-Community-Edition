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
using System.Data;
using System.Data.Common;
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Xml;
using System.Globalization;
using System.Threading;

namespace SplendidCRM.Administration.Configurator
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class AdminWizard : SplendidControl
	{
		protected Label        lblError              ;
		
		protected int          nWizardPanel          ;
		protected Table        tblSystemName         ;
		protected Table        tblSystemLocale       ;
		protected Table        tblMailSettings       ;

		// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
		//private const string sEMPTY_PASSWORD = "**********";
		protected TextBox      COMPANY_NAME          ;
		protected TextBox      HEADER_LOGO_IMAGE     ;
		protected TextBox      HEADER_LOGO_WIDTH     ;
		protected TextBox      HEADER_LOGO_HEIGHT    ;
		protected TextBox      HEADER_LOGO_STYLE     ;
		protected FileUpload   UPLOAD_LOGO_IMAGE     ;
		protected System.Web.UI.WebControls.Image imgCompanyLogo;

		// 01/26/2014 Paul.  Atlantic theme header logo. 
		protected TextBox      ATLANTIC_HOME_IMAGE   ;
		protected FileUpload   UPLOAD_ATLANTIC_IMAGE ;
		protected System.Web.UI.WebControls.Image imgAtlanticLogo;

		protected DropDownList lstLANGUAGE           ;
		protected DropDownList lstDATE_FORMAT        ;
		protected DropDownList lstTIME_FORMAT        ;
		protected DropDownList lstCURRENCY           ;
		protected DropDownList lstTIMEZONE           ;
		
		protected TextBox      NOTIFY_FROMNAME       ;
		protected TextBox      NOTIFY_FROMADDRESS    ;
		protected TextBox      MAIL_SMTPSERVER       ;
		protected TextBox      MAIL_SMTPPORT         ;
		protected CheckBox     MAIL_SMTPAUTH_REQ     ;
		protected CheckBox     MAIL_SMTPSSL          ;
		protected TextBox      MAIL_SMTPUSER         ;
		protected TextBox      MAIL_SMTPPASS         ;

		private bool UploadImage()
		{
			bool bSucceeded = true;
			if ( UPLOAD_LOGO_IMAGE.HasFile )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						try
						{
							Guid   gImageID  = Guid.Empty;
							string sFILENAME = String.Empty;
							SplendidCRM.FileBrowser.FileWorkerUtils.LoadImage(ref gImageID, ref sFILENAME, UPLOAD_LOGO_IMAGE.UniqueID, trn);
							if ( !Sql.IsEmptyGuid(gImageID) )
							{
								HEADER_LOGO_IMAGE.Text = "~/Images/EmailImage.aspx?ID=" + gImageID.ToString();
								
								imgCompanyLogo.ImageUrl = HEADER_LOGO_IMAGE.Text;
								if ( Sql.ToInteger(HEADER_LOGO_WIDTH.Text) > 0 )
									imgCompanyLogo.Width    = Sql.ToInteger(HEADER_LOGO_WIDTH.Text);
								if ( Sql.ToInteger(HEADER_LOGO_HEIGHT.Text) > 0 )
									imgCompanyLogo.Height   = Sql.ToInteger(HEADER_LOGO_HEIGHT.Text);
								if ( !Sql.IsEmptyString(HEADER_LOGO_STYLE.Text) )
									imgCompanyLogo.Attributes.Add("style", Sql.ToString(HEADER_LOGO_STYLE.Text));
								// 08/18/2010 Paul.  IE8 does not support alt any more, so we need to use ToolTip instead. 
								imgCompanyLogo.ToolTip = Sql.ToString(COMPANY_NAME.Text);
							}
							trn.Commit();
						}
						catch(Exception ex)
						{
							trn.Rollback();
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							lblError.Text = ex.Message;
							bSucceeded = false;
						}
					}
				}
			}
			return bSucceeded;
		}

		// 01/26/2014 Paul.  Atlantic theme header logo. 
		private bool UploadAtlanticImage()
		{
			bool bSucceeded = true;
			if ( UPLOAD_ATLANTIC_IMAGE.HasFile )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						try
						{
							Guid   gImageID  = Guid.Empty;
							string sFILENAME = String.Empty;
							SplendidCRM.FileBrowser.FileWorkerUtils.LoadImage(ref gImageID, ref sFILENAME, UPLOAD_ATLANTIC_IMAGE.UniqueID, trn);
							if ( !Sql.IsEmptyGuid(gImageID) )
							{
								ATLANTIC_HOME_IMAGE.Text = "~/Images/EmailImage.aspx?ID=" + gImageID.ToString();
								imgAtlanticLogo.ImageUrl = ATLANTIC_HOME_IMAGE.Text;
							}
							trn.Commit();
						}
						catch(Exception ex)
						{
							trn.Rollback();
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							lblError.Text = ex.Message;
							bSucceeded = false;
						}
					}
				}
			}
			return bSucceeded;
		}

		protected void lstLANGUAGE_Changed(Object sender, EventArgs e)
		{
			if ( lstLANGUAGE.SelectedValue.Length > 0 )
			{
				CultureInfo oldCulture   = Thread.CurrentThread.CurrentCulture   ;
				CultureInfo oldUICulture = Thread.CurrentThread.CurrentUICulture ;
				Thread.CurrentThread.CurrentCulture   = CultureInfo.CreateSpecificCulture(lstLANGUAGE.SelectedValue);
				Thread.CurrentThread.CurrentUICulture = new CultureInfo(lstLANGUAGE.SelectedValue);

				DateTime dtNow = T10n.FromServerTime(DateTime.Now);
				DateTimeFormatInfo oDateInfo   = Thread.CurrentThread.CurrentCulture.DateTimeFormat;
				NumberFormatInfo   oNumberInfo = Thread.CurrentThread.CurrentCulture.NumberFormat  ;

				String[] aDateTimePatterns = oDateInfo.GetAllDateTimePatterns();

				lstDATE_FORMAT.Items.Clear();
				lstTIME_FORMAT.Items.Clear();
				foreach ( string sPattern in aDateTimePatterns )
				{
					// 11/12/2005 Paul.  Only allow patterns that have a full year. 
					// 10/15/2013 Paul.  Allow 2-digit year. 
					if ( sPattern.IndexOf("yy") >= 0 && sPattern.IndexOf("dd") >= 0 && sPattern.IndexOf("mm") <  0 )
						lstDATE_FORMAT.Items.Add(new ListItem(sPattern + "   " + dtNow.ToString(sPattern), sPattern));
					if ( sPattern.IndexOf("yy") <  0 && sPattern.IndexOf("mm") >= 0 )
						lstTIME_FORMAT.Items.Add(new ListItem(sPattern + "   " + dtNow.ToString(sPattern), sPattern));
				}
				Thread.CurrentThread.CurrentCulture = oldCulture  ;
				Thread.CurrentThread.CurrentCulture = oldUICulture;
			}
		}

		protected void SaveSystemName()
		{
			Application["CONFIG.company_name"        ] = COMPANY_NAME      .Text;
			Application["CONFIG.header_logo_image"   ] = HEADER_LOGO_IMAGE .Text;
			Application["CONFIG.header_logo_width"   ] = HEADER_LOGO_WIDTH .Text;
			Application["CONFIG.header_logo_height"  ] = HEADER_LOGO_HEIGHT.Text;
			Application["CONFIG.header_logo_style"   ] = HEADER_LOGO_STYLE .Text;
			Application["CONFIG.Configurator.LastRun"] = DateTime.Now.ToString();

			SqlProcs.spCONFIG_Update("company", "company_name"        , Sql.ToString(Application["CONFIG.company_name"        ]));
			SqlProcs.spCONFIG_Update("system" , "header_logo_image"   , Sql.ToString(Application["CONFIG.header_logo_image"   ]));
			SqlProcs.spCONFIG_Update("system" , "header_logo_width"   , Sql.ToString(Application["CONFIG.header_logo_width"   ]));
			SqlProcs.spCONFIG_Update("system" , "header_logo_height"  , Sql.ToString(Application["CONFIG.header_logo_height"  ]));
			SqlProcs.spCONFIG_Update("system" , "header_logo_style"   , Sql.ToString(Application["CONFIG.header_logo_style"   ]));
			// 07/07/2010Paul.  Use the last-run to determine if the AdminWizard should be run. 
			SqlProcs.spCONFIG_Update("system" , "Configurator.LastRun", Sql.ToString(Application["CONFIG.Configurator.LastRun"]));
			// 01/26/2014 Paul.  Atlantic theme header logo. 
			Application["CONFIG.header_home_image"   ] = ATLANTIC_HOME_IMAGE.Text;
			SqlProcs.spCONFIG_Update("system" , "header_home_image"   , Sql.ToString(Application["CONFIG.header_home_image"   ]));
		}

		protected void SaveSystemLocale()
		{
			Application["CONFIG.default_language"   ] = lstLANGUAGE   .SelectedValue;
			Application["CONFIG.default_date_format"] = lstDATE_FORMAT.SelectedValue;
			Application["CONFIG.default_time_format"] = lstTIME_FORMAT.SelectedValue;
			Application["CONFIG.default_currency"   ] = lstCURRENCY   .SelectedValue;
			Application["CONFIG.default_timezone"   ] = lstTIMEZONE   .SelectedValue;
			
			SqlProcs.spCONFIG_Update("system" , "default_language"   , Sql.ToString(Application["CONFIG.default_language"   ]));
			SqlProcs.spCONFIG_Update("system" , "default_date_format", Sql.ToString(Application["CONFIG.default_date_format"]));
			SqlProcs.spCONFIG_Update("system" , "default_time_format", Sql.ToString(Application["CONFIG.default_time_format"]));
			SqlProcs.spCONFIG_Update("system" , "default_currency"   , Sql.ToString(Application["CONFIG.default_currency"   ]));
			SqlProcs.spCONFIG_Update("system" , "default_timezone"   , Sql.ToString(Application["CONFIG.default_timezone"   ]));
		}

		protected void SaveMailSettings()
		{
			Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
			Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
			string sMAIL_SMTPPASS = MAIL_SMTPPASS.Text;
			// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
			if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD )
			{
				sMAIL_SMTPPASS = Sql.ToString (Application["CONFIG.smtppass"]);
			}
			else if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
			{
				string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
				if ( Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sMAIL_SMTPPASS )
					throw(new Exception("Decryption failed"));
				sMAIL_SMTPPASS = sENCRYPTED_EMAIL_PASSWORD;
			}

			int nMAIL_SMTPPORT = Sql.ToInteger(MAIL_SMTPPORT.Text);
			Application["CONFIG.fromname"    ] = NOTIFY_FROMNAME   .Text;
			Application["CONFIG.fromaddress" ] = NOTIFY_FROMADDRESS.Text;
			Application["CONFIG.smtpserver"  ] = MAIL_SMTPSERVER   .Text;
			Application["CONFIG.smtpport"    ] = nMAIL_SMTPPORT    .ToString();
			Application["CONFIG.smtpuser"    ] = MAIL_SMTPUSER     .Text;
			Application["CONFIG.smtppass"    ] = sMAIL_SMTPPASS;
			Application["CONFIG.smtpauth_req"] = MAIL_SMTPAUTH_REQ .Checked;
			Application["CONFIG.smtpssl"     ] = MAIL_SMTPSSL      .Checked;

			SqlProcs.spCONFIG_Update("notify", "fromname"    , Sql.ToString(Application["CONFIG.fromname"    ]));
			SqlProcs.spCONFIG_Update("notify", "fromaddress" , Sql.ToString(Application["CONFIG.fromaddress" ]));
			SqlProcs.spCONFIG_Update("mail"  , "smtpserver"  , Sql.ToString(Application["CONFIG.smtpserver"  ]));
			SqlProcs.spCONFIG_Update("mail"  , "smtpport"    , Sql.ToString(Application["CONFIG.smtpport"    ]));
			SqlProcs.spCONFIG_Update("mail"  , "smtpuser"    , Sql.ToString(Application["CONFIG.smtpuser"    ]));
			SqlProcs.spCONFIG_Update("mail"  , "smtppass"    , Sql.ToString(Application["CONFIG.smtppass"    ]));
			SqlProcs.spCONFIG_Update("mail"  , "smtpauth_req", Sql.ToString(Application["CONFIG.smtpauth_req"]));
			SqlProcs.spCONFIG_Update("mail"  , "smtpssl"     , Sql.ToString(Application["CONFIG.smtpssl"     ]));
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Skip" )
				{
					// 06/15/2017 Paul.  Add support for HTML5 Home Page. 
					Response.Redirect(Sql.ToString(Application["Modules.Home.RelativePath"]));
				}
				else if ( e.CommandName == "Continue" )
				{
					// 07/29/2010 Paul.  The Mail Settings is the last page, so we will get a Continue event and not a Next event. 
					if ( tblMailSettings.Visible )
					{
						SaveMailSettings();
					}
					// 07/08/2010 Paul.  Redirect to the new User Wizard. 
// 10/31/201 Paul.  Wizard is handled by React Client.
#if !ReactOnlyUI
					if ( Sql.IsEmptyString(Session["USER_SETTINGS/TIMEZONE/ORIGINAL"]) )
						Response.Redirect("~/Users/Wizard.aspx");  // Response.Redirect("~/Users/SetTimezone.aspx");
					else
#endif
						// 06/15/2017 Paul.  Add support for HTML5 Home Page. 
						Response.Redirect(Sql.ToString(Application["Modules.Home.RelativePath"]));
				}
				else if ( e.CommandName == "Next" )
				{
					if ( tblSystemName.Visible )
					{
						if ( !UploadImage() )
							return;
						// 01/26/2014 Paul.  Atlantic theme header logo. 
						if ( !UploadAtlanticImage() )
							return;
						SaveSystemName();
					}
					else if ( tblSystemLocale.Visible )
					{
						SaveSystemLocale();
					}
					else if ( tblMailSettings.Visible )
					{
						SaveMailSettings();
					}
					nWizardPanel++;
					ActivatePanel();
					ViewState["WizardPanel"] = nWizardPanel;
				}
				else if ( e.CommandName == "Back" )
				{
					if ( nWizardPanel > 0 )
					{
						nWizardPanel--;
						ActivatePanel();
						ViewState["WizardPanel"] = nWizardPanel;
					}
				}
				else if ( e.CommandName == "SmtpType.Gmail" )
				{
					MAIL_SMTPSERVER  .Text    = "smtp.gmail.com";
					MAIL_SMTPPORT    .Text    = "587";
					MAIL_SMTPAUTH_REQ.Checked = true;
					MAIL_SMTPSSL     .Checked = true;
				}
				else if ( e.CommandName == "SmtpType.Yahoo" )
				{
					MAIL_SMTPSERVER  .Text    = "plus.smtp.mail.yahoo.com";
					MAIL_SMTPPORT    .Text    = "465";
					MAIL_SMTPAUTH_REQ.Checked = true;
					MAIL_SMTPSSL     .Checked = true;
				}
				else if ( e.CommandName == "SmtpType.Other" )
				{
					MAIL_SMTPSERVER  .Text    = String.Empty;
					MAIL_SMTPPORT    .Text    = "25";
				}
				else if ( e.CommandName == "Smtp.Clear" )
				{
					MAIL_SMTPSERVER  .Text    = String.Empty;
					MAIL_SMTPPORT    .Text    = "25";
					MAIL_SMTPAUTH_REQ.Checked = true;
					MAIL_SMTPSSL     .Checked = false;
					MAIL_SMTPUSER    .Text    = String.Empty;
					MAIL_SMTPPASS    .Text    = String.Empty;
				}
				else if ( e.CommandName == "Upload.Image" )
				{
					UploadImage();
				}
				// 01/26/2014 Paul.  Atlantic theme header logo. 
				else if ( e.CommandName == "Upload.AtlanticImage" )
				{
					UploadAtlanticImage();
				}
				else if ( e.CommandName == "Smtp.Test" )
				{
					Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
					Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
					string sMAIL_SMTPPASS = MAIL_SMTPPASS.Text;
					// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
					if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD )
					{
						sMAIL_SMTPPASS = Sql.ToString (Application["CONFIG.smtppass"]);
						sMAIL_SMTPPASS = Security.DecryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
					}
					string sSmtpServer      = MAIL_SMTPSERVER  .Text;
					int    nSmtpPort        = Sql.ToInteger(MAIL_SMTPPORT.Text);
					bool   bSmtpAuthReq     = MAIL_SMTPAUTH_REQ.Checked;
					bool   bSmtpSSL         = MAIL_SMTPSSL     .Checked;
					string sSmtpUser        = MAIL_SMTPUSER    .Text;
					string sSmtpPassword    = sMAIL_SMTPPASS;
					string sFromName        = NOTIFY_FROMNAME.Text;
					string sFromAddress     = NOTIFY_FROMADDRESS.Text;
					if ( Sql.IsEmptyString(sSmtpServer) )
					{
						sSmtpServer = "127.0.0.1";
						MAIL_SMTPSERVER.Text = sSmtpServer;
					}
					if ( nSmtpPort == 0 )
					{
						nSmtpPort = 25;
						MAIL_SMTPPORT.Text = nSmtpPort.ToString();
					}
					EmailUtils.SendTestMessage(Application, sSmtpServer, nSmtpPort, bSmtpAuthReq, bSmtpSSL, sSmtpUser, sSmtpPassword, sFromAddress, sFromName, sFromAddress, sFromName);
					lblError.Text = "Send was successful.";
					// 07/29/2010 Paul.  If the password is provided, then we need to save it as the text field will be cleared in the response. 
					if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
					{
						string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						if ( Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sMAIL_SMTPPASS )
							throw(new Exception("Decryption failed"));
						Application["CONFIG.smtppass"] = sENCRYPTED_EMAIL_PASSWORD;
						// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
						MAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void ActivatePanel()
		{
			tblSystemName  .Visible = (nWizardPanel == 0);
			tblSystemLocale.Visible = (nWizardPanel == 1);
			tblMailSettings.Visible = (nWizardPanel == 2);
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Administration.LBL_ADMIN_WIZARD"));
			this.Visible = SplendidCRM.Security.IS_ADMIN;
			if ( !this.Visible )
			{
				// 06/15/2017 Paul.  Add support for HTML5 Home Page. 
				Response.Redirect(Sql.ToString(Application["Modules.Home.RelativePath"]));
				return;
			}
			if ( !IsPostBack )
			{
					COMPANY_NAME      .Text = Sql.ToString(Application["CONFIG.company_name"      ]);
					HEADER_LOGO_IMAGE .Text = Sql.ToString(Application["CONFIG.header_logo_image" ]);
					HEADER_LOGO_WIDTH .Text = Sql.ToString(Application["CONFIG.header_logo_width" ]);
					HEADER_LOGO_HEIGHT.Text = Sql.ToString(Application["CONFIG.header_logo_height"]);
					HEADER_LOGO_STYLE .Text = Sql.ToString(Application["CONFIG.header_logo_style" ]);
					
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
						// 08/18/2010 Paul.  IE8 does not support alt any more, so we need to use ToolTip instead. 
						imgCompanyLogo.ToolTip = Sql.ToString(Application["CONFIG.company_name"]);
					}
					else
					{
						HEADER_LOGO_IMAGE .Text = "~/Include/images/SplendidCRM_Logo.gif";
						HEADER_LOGO_WIDTH .Text = "207";
						HEADER_LOGO_HEIGHT.Text = "60";
						HEADER_LOGO_STYLE .Text = "margin-left: 10px";
						
						imgCompanyLogo.ImageUrl = HEADER_LOGO_IMAGE.Text;
						imgCompanyLogo.Width    = 207;
						imgCompanyLogo.Height   =  60;
						imgCompanyLogo.Attributes.Add("style", HEADER_LOGO_STYLE.Text);
						// 08/18/2010 Paul.  IE8 does not support alt any more, so we need to use ToolTip instead. 
						imgCompanyLogo.ToolTip = Sql.ToString(Application["CONFIG.company_name"]);
					}
					
					// 01/26/2014 Paul.  Atlantic theme header logo. 
					ATLANTIC_HOME_IMAGE.Text = Sql.ToString(Application["CONFIG.header_home_image"]);
					if ( Sql.IsEmptyString(ATLANTIC_HOME_IMAGE.Text) )
						ATLANTIC_HOME_IMAGE.Text = "~/Include/images/SplendidCRM_Icon.gif";
					imgAtlanticLogo.CssClass = "otherHome";
					imgAtlanticLogo.ImageUrl = ATLANTIC_HOME_IMAGE.Text;
					
					lstLANGUAGE.DataSource = SplendidCache.Languages();
					lstLANGUAGE.DataBind();
					lstCURRENCY.DataSource = SplendidCache.Currencies();
					lstCURRENCY.DataBind();
					lstTIMEZONE.DataSource = SplendidCache.TimezonesListbox();
					lstTIMEZONE.DataBind();
					try
					{
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetValue(lstLANGUAGE, L10N.NormalizeCulture(Sql.ToString(Application["CONFIG.default_language"])));
						lstLANGUAGE_Changed(null, null);
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}
					try
					{
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetValue(lstDATE_FORMAT, Sql.ToString(Application["CONFIG.default_date_format"]));
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}
					try
					{
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetValue(lstTIME_FORMAT, Sql.ToString(Application["CONFIG.default_time_format"]));
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}
					try
					{
						string sCURRENCY = Sql.ToString(Application["CONFIG.default_currency"]);
						if ( !Sql.IsEmptyString(sCURRENCY) )
						{
							// 07/09/2010 Paul.  Normalize the GUID so that there will not be a case significant issue. 
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetValue(lstCURRENCY, Sql.ToGuid(sCURRENCY).ToString());
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}
					try
					{
						string sTIMEZONE = Sql.ToString(Application["CONFIG.default_timezone"]);
						if ( !Sql.IsEmptyString(sTIMEZONE) )
						{
							// 07/09/2010 Paul.  Normalize the GUID so that there will not be a case significant issue. 
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetValue(lstTIMEZONE, Sql.ToGuid(sTIMEZONE).ToString());
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}

					// 01/08/2008 Paul.  If the encryption key does not exist, then we must create it and we must save it back to the database. 
					// 01/08/2008 Paul.  SugarCRM uses blowfish for the inbound email encryption, but we will not since .NET 2.0 does not support blowfish natively. 
					Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
					if ( Sql.IsEmptyGuid(gINBOUND_EMAIL_KEY) )
					{
						gINBOUND_EMAIL_KEY = Guid.NewGuid();
						SqlProcs.spCONFIG_Update("mail", "InboundEmailKey", gINBOUND_EMAIL_KEY.ToString());
						Application["CONFIG.InboundEmailKey"] = gINBOUND_EMAIL_KEY;
					}
					Guid gINBOUND_EMAIL_IV = Sql.ToGuid(Application["CONFIG.InboundEmailIV"]);
					if ( Sql.IsEmptyGuid(gINBOUND_EMAIL_IV) )
					{
						gINBOUND_EMAIL_IV = Guid.NewGuid();
						SqlProcs.spCONFIG_Update("mail", "InboundEmailIV", gINBOUND_EMAIL_IV.ToString());
						Application["CONFIG.InboundEmailIV"] = gINBOUND_EMAIL_IV;
					}
					NOTIFY_FROMNAME   .Text    = Sql.ToString (Application["CONFIG.fromname"                ]);
					NOTIFY_FROMADDRESS.Text    = Sql.ToString (Application["CONFIG.fromaddress"             ]);
					MAIL_SMTPSERVER   .Text    = Sql.ToString (Application["CONFIG.smtpserver"              ]);
					MAIL_SMTPPORT     .Text    = Sql.ToString (Application["CONFIG.smtpport"                ]);
					MAIL_SMTPUSER     .Text    = Sql.ToString (Application["CONFIG.smtpuser"                ]);
					MAIL_SMTPAUTH_REQ .Checked = Sql.ToBoolean(Application["CONFIG.smtpauth_req"            ]);
					MAIL_SMTPSSL      .Checked = Sql.ToBoolean(Application["CONFIG.smtpssl"                 ]);
					string sMAIL_SMTPPASS = Sql.ToString (Application["CONFIG.smtppass"]);
					if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
					{
						// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
						//MAIL_SMTPPASS.Text = Sql.sEMPTY_PASSWORD;
						MAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
					}

				ViewState["WizardPanel"] = 0;
				ActivatePanel();
			}
			nWizardPanel = Sql.ToInteger(ViewState["WizardPanel"]);
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

