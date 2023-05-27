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
using System.Xml;
using System.Web;
using System.Web.SessionState;
using System.Data;
using System.Data.Common;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.ServiceModel.Activation;
using System.Web.Script.Serialization;
using System.Security.Cryptography;
using Google.Apis.Auth.OAuth2;
using Google.Apis.Auth.OAuth2.Flows;
using System.Threading;
using System.Diagnostics;

namespace SplendidCRM.Administration.EmailMan
{
	[ServiceContract]
	[ServiceBehavior( IncludeExceptionDetailInFaults = true )]
	[AspNetCompatibilityRequirements( RequirementsMode = AspNetCompatibilityRequirementsMode.Required )]
	public class Rest
	{
		[OperationContract]
		public string SendTestMessage(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sFROM_ADDR         = Sql.ToString (Application["CONFIG.from_addr"        ]);
			string sFROM_NAME         = Sql.ToString (Application["CONFIG.from_name"        ]);
			string sMAIL_SENDTYPE     = Sql.ToString (Application["CONFIG.mail_sendtype"    ]);
			string sMAIL_SMTPUSER     = Sql.ToString (Application["CONFIG.mail_smtpuser"    ]);
			string sMAIL_SMTPPASS     = Sql.ToString (Application["CONFIG.mail_smtppass"    ]);
			string sMAIL_SMTPSERVER   = Sql.ToString (Application["CONFIG.mail_smtpserver"  ]);
			int    nMAIL_SMTPPORT     = Sql.ToInteger(Application["CONFIG.mail_smtpport"    ]);
			bool   bMAIL_SMTPAUTH_REQ = Sql.ToBoolean(Application["CONFIG.mail_smtpauth_req"]);
			bool   bMAIL_SMTPSSL      = Sql.ToBoolean(Application["CONFIG.mail_smtpssl"     ]);
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "from_addr"        :  sFROM_ADDR         = Sql.ToString (dict[sColumnName]);  break;
					case "from_name"        :  sFROM_NAME         = Sql.ToString (dict[sColumnName]);  break;
					case "mail_sendtype"    :  sMAIL_SENDTYPE     = Sql.ToString (dict[sColumnName]);  break;
					case "mail_smtpuser"    :  sMAIL_SMTPUSER     = Sql.ToString (dict[sColumnName]);  break;
					case "mail_smtppass"    :  sMAIL_SMTPPASS     = Sql.ToString (dict[sColumnName]);  break;
					case "mail_smtpserver"  :  sMAIL_SMTPSERVER   = Sql.ToString (dict[sColumnName]);  break;
					case "mail_smtpport"    :  nMAIL_SMTPPORT     = Sql.ToInteger(dict[sColumnName]);  break;
					case "mail_smtpauth_req":  bMAIL_SMTPAUTH_REQ = Sql.ToBoolean(dict[sColumnName]);  break;
					case "mail_smtpssl"     :  bMAIL_SMTPSSL      = Sql.ToBoolean(dict[sColumnName]);  break;
				}
			}
			if ( Sql.IsEmptyString(sFROM_ADDR) )
			{
				throw(new Exception(L10n.Term("Users.ERR_EMAIL_REQUIRED_TO_TEST")));
			}

			string sENCRYPTED_EMAIL_PASSWORD = String.Empty;
			Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
			Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
			if ( Sql.IsEmptyString(sMAIL_SMTPPASS) || sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD )
			{
				sENCRYPTED_EMAIL_PASSWORD = Sql.ToString(Application["CONFIG.smtppass"]);
			}
			else if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
			{
				sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
			}
			
			string sStatus = String.Empty;
			if ( String.Compare(sMAIL_SENDTYPE, "smtp", true) == 0 )
			{
				// 02/02/2017 Paul.  Global values are only used if server left blank. 
				if ( Sql.IsEmptyString(sMAIL_SMTPSERVER) )
				{
					sMAIL_SMTPSERVER   = Sql.ToString (Application["CONFIG.smtpserver"  ]);
					nMAIL_SMTPPORT     = Sql.ToInteger(Application["CONFIG.smtpport"    ]);
					bMAIL_SMTPAUTH_REQ = Sql.ToBoolean(Application["CONFIG.smtpauth_req"]);
					bMAIL_SMTPSSL      = Sql.ToBoolean(Application["CONFIG.smtpssl"     ]);
				}
				EmailUtils.SendTestMessage(Application, sMAIL_SMTPSERVER, nMAIL_SMTPPORT, bMAIL_SMTPAUTH_REQ, bMAIL_SMTPSSL, sMAIL_SMTPUSER, sMAIL_SMTPPASS, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
				sStatus = L10n.Term("Users.LBL_SEND_SUCCESSFUL");
			}
			// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
			else if ( String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0 )
			{
				string sIMPERSONATED_TYPE        = Sql.ToString (Application["CONFIG.Exchange.ImpersonatedType"]);
				string sSERVER_URL               = Sql.ToString (Application["CONFIG.Exchange.ServerURL"       ]);
				ExchangeUtils.SendTestMessage(Application, sSERVER_URL, sMAIL_SMTPUSER, sENCRYPTED_EMAIL_PASSWORD, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
				sStatus = L10n.Term("Users.LBL_SEND_SUCCESSFUL");
			}
			else
			{
				throw(new Exception(sMAIL_SENDTYPE + " is not supported in this area."));
			}
			return sStatus;
		}

		[OperationContract]
		public string GoogleApps_Authorize(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sCode          = String.Empty;
			string sRedirectURL   = String.Empty;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "code"         :  sCode         = Sql.ToString (dict[sColumnName]);  break;
					case "redirect_url" :  sRedirectURL  = Sql.ToString (dict[sColumnName]);  break;
				}
			}
			string sEMAIL1 = String.Empty;
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("EmailMan", "edit") >= 0 )
			{
				if ( !Sql.IsEmptyString(sCode) )
				{
					string[] arrScopes = new string[]
					{
						"https://www.googleapis.com/auth/calendar",
						"https://www.googleapis.com/auth/tasks",
						"https://mail.google.com/",
						"https://www.google.com/m8/feeds"
					};
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.GoogleApps.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.GoogleApps.ClientSecret"]);
					GoogleAuthorizationCodeFlow flow = new GoogleAuthorizationCodeFlow(new GoogleAuthorizationCodeFlow.Initializer
					{
						//DataStore = new SessionDataStore(Session),
						ClientSecrets = new ClientSecrets
						{
							ClientId     = sOAuthClientID,
							ClientSecret = sOAuthClientSecret
						},
						Scopes = arrScopes
					});
					string sUserID = Security.USER_ID.ToString();
					// 09/25/2015 Paul.  Redirect URL must match those allowed in Google Developer Console. https://console.developers.google.com/project/_/apiui/credential
					/*Google.Apis.Auth.OAuth2.Responses.TokenResponse*/var token = flow.ExchangeCodeForTokenAsync(sUserID, sCode, sRedirectURL, CancellationToken.None).Result;
					// 02/03/2017 Paul.  IE11 is getting stuck due to Protected Mode for Security / Internet service. window.opener === undefined after return from Google URL. 
					string OAUTH_ACCESS_TOKEN      = token.AccessToken           ;
					string sTokenType              = token.TokenType             ;
					string OAUTH_REFRESH_TOKEN     = token.RefreshToken          ;
					string OAUTH_EXPIRES_IN        = token.ExpiresInSeconds.Value.ToString();

					DateTime dtOAUTH_EXPIRES_AT = DateTime.Now.AddSeconds(Sql.ToInteger(OAUTH_EXPIRES_IN));
					SqlProcs.spOAUTH_TOKENS_Update(EmailUtils.CAMPAIGN_MANAGER_ID, "GoogleApps", OAUTH_ACCESS_TOKEN, String.Empty, dtOAUTH_EXPIRES_AT, OAUTH_REFRESH_TOKEN);
					Application["CONFIG.GoogleApps." + EmailUtils.CAMPAIGN_MANAGER_ID.ToString() + ".OAuthAccessToken" ] = OAUTH_ACCESS_TOKEN;
					Application["CONFIG.GoogleApps." + EmailUtils.CAMPAIGN_MANAGER_ID.ToString() + ".OAuthRefreshToken"] = OAUTH_REFRESH_TOKEN;
					Application["CONFIG.GoogleApps." + EmailUtils.CAMPAIGN_MANAGER_ID.ToString() + ".OAuthExpiresAt"   ] = dtOAUTH_EXPIRES_AT.ToShortDateString() + " " + dtOAUTH_EXPIRES_AT.ToShortTimeString();
					// 01/19/2017 Paul.  We want an OUTBOUND_EMAILS mapping to the office365 OAuth record. 
					// 02/04/2017 Paul.  OutboundEmail NAME will be system when Gmail is the primary send type.  Otherwise this is just an older-style GoogleApps sync. 
					Guid gOUTBOUND_EMAIL_ID = Guid.Empty;
					SqlProcs.spOUTBOUND_EMAILS_Update(ref gOUTBOUND_EMAIL_ID, "system", "system-override", EmailUtils.CAMPAIGN_MANAGER_ID, "GoogleApps", null, null, 0, null, null, false, 0, null, null, Guid.Empty, null);
					//lblGoogleAuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					//btnGoogleAppsAuthorize   .Visible = false;
					//btnGoogleAppsDelete      .Visible = true ;
					//btnGoogleAppsTest        .Visible = true ;
					//btnGoogleAppsRefreshToken.Visible = true && bDebug;
					//lblGoogleAppsAuthorized  .Visible = true ;
					// 02/09/2017 Paul.  Update the email address. 
					StringBuilder sbErrors = new StringBuilder();
					// 07/14/2020 Paul.  If email not accessible, just ignore as we have a valid token. 
					sEMAIL1 = SplendidCRM.GoogleApps.GetEmailAddress(Application, EmailUtils.CAMPAIGN_MANAGER_ID, sbErrors);
					if ( sbErrors.Length > 0 )
						throw(new Exception(sbErrors.ToString()));
				}
				else
				{
					throw(new Exception("missing OAuth code"));
				}
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			return sEMAIL1;
		}

		[OperationContract]
		public void GoogleApps_Delete(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("EmailMan", "edit") >= 0 )
			{
				SqlProcs.spOAUTH_TOKENS_Delete(EmailUtils.CAMPAIGN_MANAGER_ID, "GoogleApps");
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
		}

		[OperationContract]
		public string GoogleApps_Test(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sStatus = String.Empty;
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("EmailMan", "edit") >= 0 )
			{
				StringBuilder sbErrors = new StringBuilder();
				SplendidCRM.GoogleApps.TestAccessToken(Application, EmailUtils.CAMPAIGN_MANAGER_ID, sbErrors);
				sStatus = sbErrors.ToString();
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			return sStatus;
		}

		[OperationContract]
		public void GoogleApps_RefreshToken(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("EmailMan", "edit") >= 0 )
			{
				SplendidCRM.GoogleApps.RefreshAccessToken(Application, EmailUtils.CAMPAIGN_MANAGER_ID, true);
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
		}

		[OperationContract]
		public string Office365_Authorize(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sCode          = String.Empty;
			string sRedirectURL   = String.Empty;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "code"         :  sCode         = Sql.ToString (dict[sColumnName]);  break;
					case "redirect_url" :  sRedirectURL  = Sql.ToString (dict[sColumnName]);  break;
				}
			}
			string sEMAIL1 = String.Empty;
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("EmailMan", "edit") >= 0 )
			{
				if ( !Sql.IsEmptyString(sCode) )
				{
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
					string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
					// 11/09/2019 Paul.  Pass the RedirectURL so that we can call from the React client. 
					Office365AccessToken token = SplendidCRM.ActiveDirectory.Office365AcquireAccessToken(Context, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, EmailUtils.CAMPAIGN_MANAGER_ID, sCode, sRedirectURL);
					// 01/19/2017 Paul.  We want an OUTBOUND_EMAILS mapping to the office365 OAuth record. 
					// 02/04/2017 Paul.  OutboundEmail NAME is "system" as it will be the primary email for the user. 
					Guid gOUTBOUND_EMAIL_ID = Guid.Empty;
					SqlProcs.spOUTBOUND_EMAILS_Update(ref gOUTBOUND_EMAIL_ID, "system", "system-override", EmailUtils.CAMPAIGN_MANAGER_ID, "Office365", null, null, 0, null, null, false, 0, null, null, Guid.Empty, null);
					
					// 02/09/2017 Paul.  Use Microsoft Graph REST API to get email. 
					MicrosoftGraphProfile profile = SplendidCRM.ActiveDirectory.GetProfile(Application, token.AccessToken);
					if ( profile != null )
					{
						sEMAIL1 = Sql.ToString(profile.EmailAddress);
					}
				}
				else
				{
					throw(new Exception("missing OAuth code"));
				}
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			return sEMAIL1;
		}

		[OperationContract]
		public void Office365_Delete(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("EmailMan", "edit") >= 0 )
			{
				SqlProcs.spOAUTH_TOKENS_Delete(EmailUtils.CAMPAIGN_MANAGER_ID, "Office365");
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
		}

		[OperationContract]
		public string Office365_Test(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sFROM_ADDR = Sql.ToString(Application["CONFIG.fromaddress"]);
			string sFROM_NAME = Sql.ToString(Application["CONFIG.fromname"  ]);
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "fromname"   :  sFROM_NAME = Sql.ToString (dict[sColumnName]);  break;
					case "fromaddress":  sFROM_ADDR = Sql.ToString (dict[sColumnName]);  break;
				}
			}
			if ( Sql.IsEmptyString(sFROM_NAME) )
				sFROM_NAME = Sql.ToString(Application["CONFIG.fromname"  ]);
			if ( Sql.IsEmptyString(sFROM_ADDR) )
				sFROM_ADDR = Sql.ToString(Application["CONFIG.fromaddress"]);

			string sStatus = String.Empty;
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("EmailMain", "edit") >= 0 )
			{
				StringBuilder sbErrors = new StringBuilder();
				string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
				string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
				// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
				string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
				SplendidCRM.ActiveDirectory.Office365TestAccessToken(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, EmailUtils.CAMPAIGN_MANAGER_ID, sbErrors);

				// 12/13/2020 Paul.  Move Office365 methods to Office365utils. 
				Office365Utils.SendTestMessage(Application, EmailUtils.CAMPAIGN_MANAGER_ID, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
				sStatus = sbErrors.ToString();
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			return sStatus;
		}

		[OperationContract]
		public void Office365_RefreshToken(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sEMAIL1 = String.Empty;
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("EmailMan", "edit") >= 0 )
			{
				string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
				string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
				// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
				string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
				SplendidCRM.ActiveDirectory.Office365RefreshAccessToken(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, EmailUtils.CAMPAIGN_MANAGER_ID, true);
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetStatus()
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || SplendidCRM.Security.AdminUserAccess("EmailMan", "edit") < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sMAIL_SENDTYPE = Sql.ToString(Application["CONFIG.mail_sendtype"]);
			bool bOFFICE365_OAUTH_ENABLED  = sMAIL_SENDTYPE == "Office365"  && !Sql.IsEmptyString(Application["CONFIG.Office365." + EmailUtils.CAMPAIGN_MANAGER_ID.ToString() + ".OAuthAccessToken" ]);
			bool bGOOGLEAPPS_OAUTH_ENABLED = sMAIL_SENDTYPE == "GoogleApps" && !Sql.IsEmptyString(Application["CONFIG.GoogleApps." + EmailUtils.CAMPAIGN_MANAGER_ID.ToString() + ".OAuthAccessToken" ]);

			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			
			Guid     gTIMEZONE         = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone T10n              = TimeZone.CreateTimeZone(gTIMEZONE);


			Dictionary<string, object> dict = new Dictionary<string, object>();
			Dictionary<string, object> d = new Dictionary<string, object>();
			List<Dictionary<string, object>> results = new List<Dictionary<string, object>>();
			dict.Add( "d", d );
			d.Add("OFFICE365_OAUTH_ENABLED" , bOFFICE365_OAUTH_ENABLED );
			d.Add("GOOGLEAPPS_OAUTH_ENABLED", bGOOGLEAPPS_OAUTH_ENABLED);
			string sResponse = json.Serialize(dict);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		[OperationContract]
		public void SendQueued(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("EmailMan", "edit") >= 0 )
			{
				// 12/20/2007 Paul.  Send all queued emails, regardless of send date. 
				// 02/22/2015 Paul.  SendQueued can timeout, so wrap in a background thread. 
#if DEBUG
				EmailUtils.SendQueued(HttpContext.Current, Guid.Empty, Guid.Empty, true);
#else
				ListView.CampaignModule campaign = new ListView.CampaignModule(Context);
				System.Threading.Thread t = new System.Threading.Thread(campaign.Start);
				t.Start();
				throw(new Exception(L10n.Term("Campaigns.LBL_SENDING_IN_BACKGROUND")));
#endif
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
		}

	}
}
