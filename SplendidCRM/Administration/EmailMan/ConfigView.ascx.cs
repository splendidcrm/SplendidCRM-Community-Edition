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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Collections.Specialized;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;
using System.Xml;
using System.Diagnostics;
using System.Globalization;
using System.Security.Cryptography.X509Certificates;

namespace SplendidCRM.Administration.EmailMan
{
	/// <summary>
	///		Summary description for ConfigView.
	/// </summary>
	public class ConfigView : SplendidControl
	{
		#region Properties
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;

		// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
		//private const string sEMPTY_PASSWORD = "**********";
		protected TextBox      NOTIFY_FROMNAME       ;
		protected TextBox      NOTIFY_FROMADDRESS    ;
		// 11/18/2010 Paul.  NOTIFY_ON is not used. 
		protected CheckBox     NOTIFY_SEND_FROM_ASSIGNING_USER;
		protected DropDownList MAIL_SENDTYPE         ;
		protected TextBox      MAIL_SMTPSERVER       ;
		protected TextBox      MAIL_SMTPPORT         ;
		protected CheckBox     MAIL_SMTPAUTH_REQ     ;
		protected CheckBox     MAIL_SMTPSSL          ;
		protected TextBox      MAIL_SMTPUSER         ;
		protected TextBox      MAIL_SMTPPASS         ;
		// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
		protected LinkButton   btnGmailDefaults               ;
		protected Label        MAIL_SMTPSERVER_LABEL          ;
		protected Label        MAIL_SMTPSERVER_REQUIRED_SYMBOL;
		protected Label        MAIL_SMTPPORT_LABEL            ;
		protected Label        MAIL_SMTPPORT_REQUIRED_SYMBOL  ;
		protected Label        MAIL_SMTPAUTH_REQ_LABEL        ;
		protected Label        MAIL_SMTPSSL_LABEL             ;

		protected RequiredFieldValidator reqNOTIFY_FROMNAME   ;
		protected RequiredFieldValidator reqNOTIFY_FROMADDRESS;
		protected RequiredFieldValidator reqMAIL_SMTPSERVER   ;
		protected RequiredFieldValidator reqMAIL_SMTPPORT     ;
		protected RequiredFieldValidator reqMAIL_SMTPUSER     ;
		protected RequiredFieldValidator reqMAIL_SMTPPASS     ;

		protected string sDangerousTags = "html|meta|body|base|form|style|applet|object|script|embed|xml|frameset|iframe|frame|blink|link|ilayer|layer|import|xmp|bgsound";
		protected string sOutlookTags   = "base|form|style|applet|object|script|embed|frameset|iframe|frame|link|ilayer|layer|import|xmp";
		protected CheckBox    EMAIL_INBOUND_SAVE_RAW   ;
		protected CheckBox    SECURITY_TOGGLE_ALL      ;
		protected CheckBox    SECURITY_OUTLOOK_DEFAULTS;
		protected Table       tblSECURITY_TAGS         ;

		// 01/15/2017 Paul.  Add support for Office 365 OAuth. 
		protected TextBox         OAUTH_ACCESS_TOKEN              ;
		protected TextBox         OAUTH_REFRESH_TOKEN             ;
		protected TextBox         OAUTH_EXPIRES_IN                ;
		protected TextBox         OAUTH_CODE                      ;
		protected Table           tblSmtpPanel                    ;
		protected Table           tblOffice365Panel               ;
		protected HtmlTable       tblOffice365Options             ;
		protected Button          btnOffice365Authorize           ;
		protected Button          btnOffice365Delete              ;
		protected Button          btnOffice365Test                ;
		protected Button          btnOffice365Authorized          ;
		protected Button          btnOffice365RefreshToken        ;
		protected Label           lblOffice365Authorized          ;
		protected Label           lblOffice365AuthorizedStatus    ;
		protected Table           tblGoogleAppsPanel              ;
		protected HtmlTable       tblGoogleAppsOptions            ;
		protected Button          btnGoogleAppsAuthorize          ;
		protected Button          btnGoogleAppsDelete             ;
		protected Button          btnGoogleAppsTest               ;
		protected Button          btnGoogleAuthorized             ;
		protected Button          btnGoogleAppsRefreshToken       ;
		protected Label           lblGoogleAppsAuthorized         ;
		protected Label           lblGoogleAuthorizedStatus       ;
		#endregion

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				reqNOTIFY_FROMNAME   .Enabled = true;
				reqNOTIFY_FROMADDRESS.Enabled = true;
				reqNOTIFY_FROMNAME   .Validate();
				reqNOTIFY_FROMADDRESS.Validate();
				
				// 01/20/2017 Paul.  Add support for Office365 and GoogleApps. 
				string sMAIL_SENDTYPE = MAIL_SENDTYPE.SelectedValue;
				if ( Sql.IsEmptyString(sMAIL_SENDTYPE) )
					sMAIL_SENDTYPE = "smtp";
				if ( String.Compare(sMAIL_SENDTYPE, "smtp", true) == 0 )
				{
					reqMAIL_SMTPSERVER   .Enabled = true;
					reqMAIL_SMTPPORT     .Enabled = true;
					// 10/27/2008 Paul.  Allow the authentication to be optional. 
					reqMAIL_SMTPUSER     .Enabled = MAIL_SMTPAUTH_REQ.Checked;
					reqMAIL_SMTPPASS     .Enabled = MAIL_SMTPAUTH_REQ.Checked;
					reqMAIL_SMTPSERVER   .Validate();
					reqMAIL_SMTPPORT     .Validate();
					reqMAIL_SMTPUSER     .Validate();
					reqMAIL_SMTPPASS     .Validate();
				}
				// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
				else if ( String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0 )
				{
					reqMAIL_SMTPSERVER   .Enabled = false;
					reqMAIL_SMTPPORT     .Enabled = false;
					reqMAIL_SMTPUSER     .Enabled = true;
					reqMAIL_SMTPPASS     .Enabled = true;
					reqMAIL_SMTPUSER     .Validate();
					reqMAIL_SMTPPASS     .Validate();
					MAIL_SMTPSERVER  .Text    = String.Empty;
					MAIL_SMTPPORT    .Text    = String.Empty;
					MAIL_SMTPAUTH_REQ.Checked = false;
					MAIL_SMTPSSL     .Checked = false;
				}
				else
				{
					MAIL_SMTPSERVER  .Text    = String.Empty;
					MAIL_SMTPPORT    .Text    = String.Empty;
					MAIL_SMTPUSER    .Text    = String.Empty;
					MAIL_SMTPPASS    .Text    = String.Empty;
					MAIL_SMTPAUTH_REQ.Checked = false;
					MAIL_SMTPSSL     .Checked = false;
				}
				if ( Page.IsValid )
				{
					try
					{
						string sMAIL_SMTPPASS = String.Empty;
						int    nMAIL_SMTPPORT = 0;
						// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
						if ( String.Compare(sMAIL_SENDTYPE, "smtp", true) == 0 || String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0 )
						{
							// 01/08/2008 Paul.  If the encryption key does not exist, then we must create it and we must save it back to the database. 
							// 01/08/2008 Paul.  SugarCRM uses blowfish for the inbound email encryption, but we will not since .NET 2.0 does not support blowfish natively. 
							Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
							Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
							sMAIL_SMTPPASS = MAIL_SMTPPASS.Text;
							// 07/08/2010 Paul.  We want to save the password for later use. 
							// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
							if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD )
							{
								sMAIL_SMTPPASS = Sql.ToString(ViewState["smtppass"]);
							}
							else if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
							{
								string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
								if ( Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sMAIL_SMTPPASS )
									throw(new Exception("Decryption failed"));
								sMAIL_SMTPPASS = sENCRYPTED_EMAIL_PASSWORD;
								// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
								MAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
							}
						
							nMAIL_SMTPPORT = Sql.ToInteger(MAIL_SMTPPORT.Text);
						}
						else if ( String.Compare(sMAIL_SENDTYPE, "Office365", true) == 0 )
						{
							string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
							string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
							// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
							string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
							SplendidCRM.ActiveDirectory.Office365RefreshAccessToken(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, EmailUtils.CAMPAIGN_MANAGER_ID, false);
						}
						else if ( String.Compare(sMAIL_SENDTYPE, "GoogleApps", true) == 0 )
						{
							SplendidCRM.GoogleApps.RefreshAccessToken(Application, EmailUtils.CAMPAIGN_MANAGER_ID, false);
						}
						
						Application["CONFIG.fromname"                       ] = NOTIFY_FROMNAME                .Text;
						Application["CONFIG.fromaddress"                    ] = NOTIFY_FROMADDRESS             .Text;
						Application["CONFIG.notify_send_from_assigning_user"] = NOTIFY_SEND_FROM_ASSIGNING_USER.Checked;
						Application["CONFIG.mail_sendtype"                  ] = MAIL_SENDTYPE                  .SelectedValue;
						Application["CONFIG.smtpserver"                     ] = MAIL_SMTPSERVER                .Text;
						Application["CONFIG.smtpport"                       ] = nMAIL_SMTPPORT                 .ToString();
						Application["CONFIG.smtpuser"                       ] = MAIL_SMTPUSER                  .Text;
						Application["CONFIG.smtppass"                       ] = sMAIL_SMTPPASS;
						Application["CONFIG.smtpauth_req"                   ] = MAIL_SMTPAUTH_REQ              .Checked;
						Application["CONFIG.smtpssl"                        ] = MAIL_SMTPSSL                   .Checked;
						Application["CONFIG.email_inbound_save_raw"         ] = EMAIL_INBOUND_SAVE_RAW         .Checked;

						StringBuilder sbEMAIL_XSS = new StringBuilder();
						foreach ( string sTag in sDangerousTags.Split('|') )
						{
							CheckBox chk = FindControl("SECURITY_" + sTag.ToUpper()) as CheckBox;
							if ( chk.Checked )
							{
								if ( sbEMAIL_XSS.Length > 0 ) sbEMAIL_XSS.Append("|");
								sbEMAIL_XSS.Append(sTag);
							}
						}
						Application["CONFIG.email_xss"] = sbEMAIL_XSS.ToString();

						SqlProcs.spCONFIG_Update("notify", "fromname"                , Sql.ToString(Application["CONFIG.fromname"                ]));
						SqlProcs.spCONFIG_Update("notify", "fromaddress"             , Sql.ToString(Application["CONFIG.fromaddress"             ]));
						SqlProcs.spCONFIG_Update("notify", "send_from_assigning_user", Sql.ToString(Application["CONFIG.send_from_assigning_user"]));
						// 03/14/2021 Paul.  Not sure why, but mail_sendtype was not being saved. 
						SqlProcs.spCONFIG_Update("mail"  , "mail_sendtype"           , Sql.ToString(Application["CONFIG.mail_sendtype"           ]));
						SqlProcs.spCONFIG_Update("mail"  , "smtpserver"              , Sql.ToString(Application["CONFIG.smtpserver"              ]));
						SqlProcs.spCONFIG_Update("mail"  , "smtpport"                , Sql.ToString(Application["CONFIG.smtpport"                ]));
						SqlProcs.spCONFIG_Update("mail"  , "smtpuser"                , Sql.ToString(Application["CONFIG.smtpuser"                ]));
						SqlProcs.spCONFIG_Update("mail"  , "smtppass"                , Sql.ToString(Application["CONFIG.smtppass"                ]));
						SqlProcs.spCONFIG_Update("mail"  , "smtpauth_req"            , Sql.ToString(Application["CONFIG.smtpauth_req"            ]));
						SqlProcs.spCONFIG_Update("mail"  , "smtpssl"                 , Sql.ToString(Application["CONFIG.smtpssl"                 ]));
						SqlProcs.spCONFIG_Update("mail"  , "email_inbound_save_raw"  , Sql.ToString(Application["CONFIG.email_inbound_save_raw"  ]));
						SqlProcs.spCONFIG_Update("mail"  , "email_xss"               , Sql.ToString(Application["CONFIG.email_xss"               ]));
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						ctlDynamicButtons.ErrorText = ex.Message;
						return;
					}
					Response.Redirect("../default.aspx");
				}
			}
			else if ( e.CommandName == "Test" )
			{
				string sMAIL_SENDTYPE = new DynamicControl(this, "MAIL_SENDTYPE").SelectedValue;
				if ( Sql.IsEmptyString(sMAIL_SENDTYPE) )
					sMAIL_SENDTYPE = "smtp";
				if ( String.Compare(sMAIL_SENDTYPE, "smtp", true) == 0 )
				{
					reqMAIL_SMTPSERVER   .Enabled = true;
					reqMAIL_SMTPPORT     .Enabled = true;
					reqMAIL_SMTPSERVER   .Validate();
					reqMAIL_SMTPPORT     .Validate();
					// 10/27/2008 Paul.  Allow the authentication to be optional. 
					reqMAIL_SMTPUSER     .Enabled = MAIL_SMTPAUTH_REQ.Checked;
					reqMAIL_SMTPPASS     .Enabled = MAIL_SMTPAUTH_REQ.Checked;
					reqMAIL_SMTPUSER     .Validate();
					reqMAIL_SMTPPASS     .Validate();
				}
				// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
				else if ( String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0 )
				{
					reqMAIL_SMTPSERVER   .Enabled = false;
					reqMAIL_SMTPPORT     .Enabled = false;
					reqMAIL_SMTPUSER     .Enabled = true;
					reqMAIL_SMTPPASS     .Enabled = true;
					reqMAIL_SMTPUSER     .Validate();
					reqMAIL_SMTPPASS     .Validate();
				}
				reqNOTIFY_FROMNAME   .Enabled = true;
				reqNOTIFY_FROMADDRESS.Enabled = true;
				reqNOTIFY_FROMNAME   .Validate();
				reqNOTIFY_FROMADDRESS.Validate();
				if ( Page.IsValid )
				{
					try
					{
						Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
						Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
						string sMAIL_SMTPPASS = MAIL_SMTPPASS.Text;
						// 07/08/2010 Paul.  We want to save the password for later use. 
						// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
						if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD )
						{
							sMAIL_SMTPPASS = Sql.ToString(ViewState["smtppass"]);
							if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
								sMAIL_SMTPPASS = Security.DecryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						}
						else if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
						{
							string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
							ViewState["smtppass"] = sENCRYPTED_EMAIL_PASSWORD;
							// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
							MAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
						}
						string sMAIL_SMTPUSER = MAIL_SMTPUSER     .Text;
						string sFROM_NAME     = NOTIFY_FROMNAME   .Text;
						string sFROM_ADDR     = NOTIFY_FROMADDRESS.Text;
						if ( String.Compare(sMAIL_SENDTYPE, "smtp", true) == 0 )
						{
							string ssMAIL_SMTPSERVER  = MAIL_SMTPSERVER  .Text;
							int    nMAIL_SMTPPORT     = Sql.ToInteger(MAIL_SMTPPORT.Text);
							bool   bMAIL_SMTPAUTH_REQ = MAIL_SMTPAUTH_REQ.Checked;
							bool   bMAIL_SMTPSSL      = MAIL_SMTPSSL     .Checked;
							if ( Sql.IsEmptyString(ssMAIL_SMTPSERVER) )
							{
								ssMAIL_SMTPSERVER = "127.0.0.1";
								MAIL_SMTPSERVER.Text = ssMAIL_SMTPSERVER;
							}
							if ( nMAIL_SMTPPORT == 0 )
							{
								nMAIL_SMTPPORT = 25;
								MAIL_SMTPPORT.Text = nMAIL_SMTPPORT.ToString();
							}
							EmailUtils.SendTestMessage(Application, ssMAIL_SMTPSERVER, nMAIL_SMTPPORT, bMAIL_SMTPAUTH_REQ, bMAIL_SMTPSSL, sMAIL_SMTPUSER, sMAIL_SMTPPASS, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
							ctlDynamicButtons.ErrorText = "Send was successful.";
						}
						// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
						else if ( String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0 )
						{
							string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
							string sIMPERSONATED_TYPE        = Sql.ToString (Application["CONFIG.Exchange.ImpersonatedType"]);
							string sSERVER_URL               = Sql.ToString (Application["CONFIG.Exchange.ServerURL"       ]);
							ExchangeUtils.SendTestMessage(Application, sSERVER_URL, sMAIL_SMTPUSER, sENCRYPTED_EMAIL_PASSWORD, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
							ctlDynamicButtons.ErrorText = "Send was successful.";
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						ctlDynamicButtons.ErrorText = ex.Message;
						return;
					}
				}
			}
			// 01/20/2017 Paul.  Google now uses OAuth 2.0. 
			else if ( e.CommandName == "GoogleApps.Test" )
			{
				try
				{
					lblGoogleAuthorizedStatus.Text = "Test is not supported.  Use Authorize instead.";
				}
				catch(Exception ex)
				{
					lblGoogleAuthorizedStatus.Text = ex.Message;
				}
			}
			else if ( e.CommandName == "GoogleApps.Authorize" )
			{
				try
				{
					DateTime dtOAUTH_EXPIRES_AT = DateTime.Now.AddSeconds(Sql.ToInteger(OAUTH_EXPIRES_IN.Text));
					// 01/19/2017 Paul.  Name must match SEND_TYPE. 
					SqlProcs.spOAUTH_TOKENS_Update(EmailUtils.CAMPAIGN_MANAGER_ID, "GoogleApps", OAUTH_ACCESS_TOKEN.Text, String.Empty, dtOAUTH_EXPIRES_AT, OAUTH_REFRESH_TOKEN.Text);
					Application["CONFIG.GoogleApps." + EmailUtils.CAMPAIGN_MANAGER_ID.ToString() + ".OAuthAccessToken" ] = OAUTH_ACCESS_TOKEN.Text ;
					Application["CONFIG.GoogleApps." + EmailUtils.CAMPAIGN_MANAGER_ID.ToString() + ".OAuthRefreshToken"] = OAUTH_REFRESH_TOKEN.Text;
					Application["CONFIG.GoogleApps." + EmailUtils.CAMPAIGN_MANAGER_ID.ToString() + ".OAuthExpiresAt"   ] = dtOAUTH_EXPIRES_AT.ToShortDateString() + " " + dtOAUTH_EXPIRES_AT.ToShortTimeString();
					lblGoogleAuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					btnGoogleAppsAuthorize   .Visible = false;
					btnGoogleAppsDelete      .Visible = true ;
					btnGoogleAppsTest        .Visible = true ;
					btnGoogleAppsRefreshToken.Visible = true && bDebug;
					lblGoogleAppsAuthorized  .Visible = true ;
				}
				catch(Exception ex)
				{
					lblGoogleAuthorizedStatus.Text = ex.Message;
				}
			}
			else if ( e.CommandName == "GoogleApps.Delete" )
			{
				try
				{
					// 01/19/2017 Paul.  Name must match SEND_TYPE. 
					SqlProcs.spOAUTH_TOKENS_Delete(EmailUtils.CAMPAIGN_MANAGER_ID, "GoogleApps");
					btnGoogleAppsAuthorize   .Visible = true ;
					btnGoogleAppsDelete      .Visible = false;
					btnGoogleAppsTest        .Visible = false;
					btnGoogleAppsRefreshToken.Visible = false;
					lblGoogleAppsAuthorized  .Visible = false;
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "GoogleApps.RefreshToken" )
			{
				try
				{
					SplendidCRM.GoogleApps.RefreshAccessToken(Application, Security.USER_ID, true);
					lblGoogleAuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
				}
				catch(Exception ex)
				{
					lblGoogleAuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			// 01/16/2017 Paul.  Add support for Office 365 OAuth. 
			else if ( e.CommandName == "Office365.Authorize" )
			{
				try
				{
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
					string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
					// 11/09/2019 Paul.  Pass the RedirectURL so that we can call from the React client. 
					SplendidCRM.ActiveDirectory.Office365AcquireAccessToken(Context, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, EmailUtils.CAMPAIGN_MANAGER_ID, OAUTH_CODE.Text, String.Empty);
					lblOffice365AuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					btnOffice365Authorize   .Visible = false;
					btnOffice365Delete      .Visible = true ;
					btnOffice365Test        .Visible = true ;
					btnOffice365RefreshToken.Visible = true && bDebug;
					lblOffice365Authorized  .Visible = true ;
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "Office365.RefreshToken" )
			{
				try
				{
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
					string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
					SplendidCRM.ActiveDirectory.Office365RefreshAccessToken(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, EmailUtils.CAMPAIGN_MANAGER_ID, true);
					lblOffice365AuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "Office365.Delete" )
			{
				try
				{
					SqlProcs.spOAUTH_TOKENS_Delete(EmailUtils.CAMPAIGN_MANAGER_ID, "Office365");
					btnOffice365Authorize   .Visible = true ;
					btnOffice365Delete      .Visible = false;
					btnOffice365Test        .Visible = false;
					btnOffice365RefreshToken.Visible = false;
					lblOffice365Authorized  .Visible = false;
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "Office365.Test" )
			{
				try
				{
					StringBuilder sbErrors = new StringBuilder();
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
					string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
					SplendidCRM.ActiveDirectory.Office365TestAccessToken(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, EmailUtils.CAMPAIGN_MANAGER_ID, sbErrors);
					lblOffice365AuthorizedStatus.Text = sbErrors.ToString();
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				Response.Redirect("../default.aspx");
			}
		}

		private void BuildSecurityTags()
		{
			// 01/21/2008 Paul.  We must always build the table, but on postback, we must do it inside init. 
			StringDictionary dictEMAIL_XSS = new StringDictionary();
			if ( !IsPostBack )
			{
				string sEMAIL_XSS = Sql.ToString(Application["CONFIG.email_xss"]);
				sEMAIL_XSS = sEMAIL_XSS.ToLower();
				foreach ( string sTag in sEMAIL_XSS.Split('|') )
				{
					dictEMAIL_XSS.Add(sTag, sTag);
				}
			}

			int nTagIndex = 0;
			TableRow tr = null;
			foreach ( string sTag in sDangerousTags.Split('|') )
			{
				if ( nTagIndex % 2 == 0 )
				{
					tr = new TableRow();
					tblSECURITY_TAGS.Rows.Add(tr);
				}
				TableCell td1 = new TableCell();
				CheckBox  chk = new CheckBox();
				tr.Cells.Add(td1);
				td1.Controls.Add(chk);
				td1.VerticalAlign = VerticalAlign.Bottom;
				chk.ID   = "SECURITY_" + sTag.ToUpper();
				chk.Text = "&lt;" + sTag + "&gt;";
				chk.CssClass = "checkbox";

				if ( !IsPostBack )
					chk.Checked = dictEMAIL_XSS.ContainsKey(sTag);

				TableCell td2 = new TableCell();
				Label     lbl = new Label();
				tr.Cells.Add(td2);
				td2.Controls.Add(lbl);
				td2.VerticalAlign = VerticalAlign.Bottom;
				if ( !IsPostBack )
					lbl.Text = L10n.Term("EmailMan.LBL_SECURITY_" + sTag.ToUpper());
				nTagIndex++;
			}
		}

		protected void MAIL_SENDTYPE_SelectedIndexChanged(object sender, EventArgs e)
		{
			DropDownList lstMAIL_SENDTYPE = FindControl("MAIL_SENDTYPE") as DropDownList;
			if ( lstMAIL_SENDTYPE != null )
			{
				string sMAIL_SENDTYPE = lstMAIL_SENDTYPE.SelectedValue;
				bool bSmtp = (String.Compare(sMAIL_SENDTYPE, "smtp", true) == 0 || sMAIL_SENDTYPE == String.Empty);
				// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
				bool bExchange = (String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0);
				tblSmtpPanel.Visible = bSmtp || bExchange;
				btnGmailDefaults.Visible = bSmtp;
				MAIL_SMTPSERVER                .Visible = bSmtp;
				MAIL_SMTPSERVER_LABEL          .Visible = bSmtp;
				MAIL_SMTPSERVER_REQUIRED_SYMBOL.Visible = bSmtp;
				MAIL_SMTPPORT                  .Visible = bSmtp;
				MAIL_SMTPPORT_LABEL            .Visible = bSmtp;
				MAIL_SMTPPORT_REQUIRED_SYMBOL  .Visible = bSmtp;
				MAIL_SMTPAUTH_REQ              .Visible = bSmtp;
				MAIL_SMTPAUTH_REQ_LABEL        .Visible = bSmtp;
				MAIL_SMTPSSL                   .Visible = bSmtp;
				MAIL_SMTPSSL_LABEL             .Visible = bSmtp;
				if ( reqMAIL_SMTPSERVER != null )
				{
					reqMAIL_SMTPSERVER.Enabled = bSmtp;
					reqMAIL_SMTPSERVER.EnableClientScript = bSmtp;
				}
				if ( reqMAIL_SMTPPORT != null )
				{
					reqMAIL_SMTPPORT.Enabled = bSmtp;
					reqMAIL_SMTPPORT.EnableClientScript = bSmtp;
				}

				tblOffice365Panel .Visible = (String.Compare(sMAIL_SENDTYPE, "Office365" , true) == 0);
				tblGoogleAppsPanel.Visible = (String.Compare(sMAIL_SENDTYPE, "GoogleApps", true) == 0);
				ctlDynamicButtons.ShowButton("Test", bSmtp || bExchange);

				if ( Sql.IsEmptyString(Application["CONFIG.Exchange.ClientID"]) || Sql.IsEmptyString(Application["CONFIG.Exchange.ClientSecret"]) )
				{
					lblOffice365AuthorizedStatus.Text = L10n.Term("OutboundEmail.LBL_OFFICE365_NOT_ENABLED");
					lblOffice365AuthorizedStatus.CssClass = "error";
				}
				if ( !Sql.ToBoolean(Context.Application["CONFIG.GoogleApps.Enabled"]) )
				{
					lblGoogleAuthorizedStatus.Text = L10n.Term("OutboundEmail.LBL_GOOGLEAPPS_NOT_ENABLED");
					lblGoogleAuthorizedStatus.CssClass = "error";
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("EmailMan.LBL_CAMPAIGN_EMAIL_SETTINGS"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			try
			{
				reqNOTIFY_FROMNAME   .DataBind();
				reqNOTIFY_FROMADDRESS.DataBind();
				reqMAIL_SMTPSERVER   .DataBind();
				reqMAIL_SMTPPORT     .DataBind();
				reqMAIL_SMTPUSER     .DataBind();
				reqMAIL_SMTPPASS     .DataBind();
				if ( !IsPostBack )
				{
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
					NOTIFY_FROMNAME                .Text    = Sql.ToString (Application["CONFIG.fromname"                       ]);
					NOTIFY_FROMADDRESS             .Text    = Sql.ToString (Application["CONFIG.fromaddress"                    ]);
					NOTIFY_SEND_FROM_ASSIGNING_USER.Checked = Sql.ToBoolean(Application["CONFIG.notify_send_from_assigning_user"]);
					MAIL_SMTPSERVER                .Text    = Sql.ToString (Application["CONFIG.smtpserver"                     ]);
					MAIL_SMTPPORT                  .Text    = Sql.ToString (Application["CONFIG.smtpport"                       ]);
					MAIL_SMTPUSER                  .Text    = Sql.ToString (Application["CONFIG.smtpuser"                       ]);
					//MAIL_SMTPPASS                  .Text    = Sql.ToString (Application["CONFIG.smtppass"                       ]);
					MAIL_SMTPAUTH_REQ              .Checked = Sql.ToBoolean(Application["CONFIG.smtpauth_req"                   ]);
					MAIL_SMTPSSL                   .Checked = Sql.ToBoolean(Application["CONFIG.smtpssl"                        ]);
					// 01/20/2008 Paul.  We are going to deviate from SugarCRM and associate the Preserve text with save raw. 
					EMAIL_INBOUND_SAVE_RAW.Checked = Sql.ToBoolean(Application["CONFIG.email_inbound_save_raw"]);
					
					NOTIFY_SEND_FROM_ASSIGNING_USER.Checked = false;
					// 10/27/2008 Paul. Allow the authentication to be optional. 
					//MAIL_SMTPAUTH_REQ              .Checked = true ;
					
					string sMAIL_SMTPPASS = Sql.ToString (Application["CONFIG.smtppass"]);
					// 01/08/2008 Paul.  Don't display the password. 
					// 01/08/2008 Paul.  Browsers don't display passwords. 
					// 07/08/2010 Paul.  We want to save the password for later use. 
					if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
					{
						// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
						//MAIL_SMTPPASS.Text = Sql.sEMPTY_PASSWORD;
						MAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
						ViewState["smtppass"] = sMAIL_SMTPPASS;
					}
					// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
					ctlDynamicButtons.AppendButtons(m_sMODULE + ".ConfigView", Guid.Empty, null);
					BuildSecurityTags();

					// 01/20/2017 Paul.  Add support for Office365 and GoogleApps. 
					MAIL_SENDTYPE.DataSource = SplendidCache.List("outbound_send_type");
					MAIL_SENDTYPE.DataBind();
					string sMAIL_SENDTYPE = Sql.ToString(Application["CONFIG.mail_sendtype"]);
					if ( sMAIL_SENDTYPE == "SMTP" || sMAIL_SENDTYPE == String.Empty )
						sMAIL_SENDTYPE = "smtp";
					try
					{
						Utils.SetSelectedValue(MAIL_SENDTYPE, sMAIL_SENDTYPE);
					}
					catch
					{
					}
					
					MAIL_SENDTYPE_SelectedIndexChanged(null, null);
					btnOffice365Authorize .Visible = true;
					// 03/20/2021 Paul.  Check for Office365 access token to determine if enabled. 
					bool bOFFICE365_OAUTH_ENABLED = sMAIL_SENDTYPE == "Office365" && !Sql.IsEmptyString(Application["CONFIG.Office365." + EmailUtils.CAMPAIGN_MANAGER_ID.ToString() + ".OAuthAccessToken" ]);
					btnOffice365Authorize   .Visible = !bOFFICE365_OAUTH_ENABLED && !Sql.IsEmptyString(Application["CONFIG.Exchange.ClientID"]) && !Sql.IsEmptyString(Application["CONFIG.Exchange.ClientSecret"]);
					btnOffice365Delete      .Visible =  bOFFICE365_OAUTH_ENABLED;
					btnOffice365Test        .Visible =  bOFFICE365_OAUTH_ENABLED;
					btnOffice365RefreshToken.Visible =  bOFFICE365_OAUTH_ENABLED && bDebug;
					lblOffice365Authorized  .Visible =  bOFFICE365_OAUTH_ENABLED;
					// 03/20/2021 Paul.  Check for GoogleApps access token to determine if enabled. 
					bool bGOOGLEAPPS_OAUTH_ENABLED = sMAIL_SENDTYPE == "GoogleApps" && !Sql.IsEmptyString(Application["CONFIG.GoogleApps." + EmailUtils.CAMPAIGN_MANAGER_ID.ToString() + ".OAuthAccessToken" ]);
					btnGoogleAppsAuthorize   .Visible = !bGOOGLEAPPS_OAUTH_ENABLED && Sql.ToBoolean(Context.Application["CONFIG.GoogleApps.Enabled"]);
					btnGoogleAppsDelete      .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
					btnGoogleAppsTest        .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
					btnGoogleAppsRefreshToken.Visible =  bGOOGLEAPPS_OAUTH_ENABLED && bDebug;
					lblGoogleAppsAuthorized  .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
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
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			// 05/20/2007 Paul.  The m_sMODULE field must be set in order to allow default export handling. 
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "EmailMan";
			if ( IsPostBack )
			{
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".ConfigView", Guid.Empty, null);
				BuildSecurityTags();
			}
		}
		#endregion
	}
}

