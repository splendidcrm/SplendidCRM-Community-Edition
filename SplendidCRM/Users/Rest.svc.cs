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

namespace SplendidCRM.Users
{
	[ServiceContract]
	[ServiceBehavior( IncludeExceptionDetailInFaults = true )]
	[AspNetCompatibilityRequirements( RequirementsMode = AspNetCompatibilityRequirementsMode.Required )]
	public class Rest
	{
		private DataRow GetUser(Guid gID)
		{
			DataRow rdr = null;
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL ;
				sSQL = "select *           " + ControlChars.CrLf
				     + "  from vwUSERS_Edit" + ControlChars.CrLf
				     + " where ID = @ID    " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					// 03/31/2021 Paul.  The convention is to provide the @. 
					Sql.AddParameter(cmd, "@ID", gID);
					con.Open();

					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dtCurrent = new DataTable() )
						{
							da.Fill(dtCurrent);
							if ( dtCurrent.Rows.Count > 0 )
							{
								rdr = dtCurrent.Rows[0];
							}
						}
					}
				}
			}
			return rdr;
		}

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
			
			Guid   gID                = Guid.Empty  ;
			string sFROM_ADDR         = String.Empty;
			string sFROM_NAME         = String.Empty;
			string sMAIL_SENDTYPE     = String.Empty;
			string sMAIL_SMTPUSER     = String.Empty;
			string sMAIL_SMTPPASS     = String.Empty;
			string sMAIL_SMTPSERVER   = String.Empty;
			int    nMAIL_SMTPPORT     = 0           ;
			bool   bMAIL_SMTPAUTH_REQ = false       ;
			bool   bMAIL_SMTPSSL      = false       ;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"               :  gID                = Sql.ToGuid   (dict[sColumnName]);  break;
					case "FROM_ADDR"        :  sFROM_ADDR         = Sql.ToString (dict[sColumnName]);  break;
					case "FROM_NAME"        :  sFROM_NAME         = Sql.ToString (dict[sColumnName]);  break;
					case "MAIL_SENDTYPE"    :  sMAIL_SENDTYPE     = Sql.ToString (dict[sColumnName]);  break;
					case "MAIL_SMTPUSER"    :  sMAIL_SMTPUSER     = Sql.ToString (dict[sColumnName]);  break;
					case "MAIL_SMTPPASS"    :  sMAIL_SMTPPASS     = Sql.ToString (dict[sColumnName]);  break;
					case "MAIL_SMTPSERVER"  :  sMAIL_SMTPSERVER   = Sql.ToString (dict[sColumnName]);  break;
					case "MAIL_SMTPPORT"    :  nMAIL_SMTPPORT     = Sql.ToInteger(dict[sColumnName]);  break;
					case "MAIL_SMTPAUTH_REQ":  bMAIL_SMTPAUTH_REQ = Sql.ToBoolean(dict[sColumnName]);  break;
					case "MAIL_SMTPSSL"     :  bMAIL_SMTPSSL      = Sql.ToBoolean(dict[sColumnName]);  break;
				}
			}
			if ( Sql.IsEmptyString(sFROM_ADDR) )
			{
				throw(new Exception(L10n.Term("Users.ERR_EMAIL_REQUIRED_TO_TEST")));
			}
			
			string sENCRYPTED_EMAIL_PASSWORD = String.Empty;
			Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
			Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
			if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD && !Sql.IsEmptyGuid(gID) )
			{
				DataRow rdr = GetUser(gID);
				if ( rdr != null )
				{
					sENCRYPTED_EMAIL_PASSWORD = Sql.ToString(rdr["MAIL_SMTPPASS"]);
					if ( !Sql.IsEmptyString(sENCRYPTED_EMAIL_PASSWORD) )
					{
						sMAIL_SMTPPASS = Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
					}
				}
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
			return sStatus;
		}

		[OperationContract]
		public string iCloud_Validate(Stream input)
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
			
			Guid   gID                   = Guid.Empty  ;
			string sMAIL_SMTPUSER        = String.Empty;
			string sMAIL_SMTPPASS        = String.Empty;
			string sICLOUD_PASSWORD      = String.Empty;
			string sICLOUD_USERNAME      = String.Empty;
			string sICLOUD_SECURITY_CODE = String.Empty;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"                  :  gID                   = Sql.ToGuid   (dict[sColumnName]);  break;
					case "MAIL_SMTPUSER"       :  sMAIL_SMTPUSER        = Sql.ToString (dict[sColumnName]);  break;
					case "MAIL_SMTPPASS"       :  sMAIL_SMTPPASS        = Sql.ToString (dict[sColumnName]);  break;
					case "ICLOUD_USERNAME"     :  sICLOUD_USERNAME      = Sql.ToString (dict[sColumnName]);  break;
					case "ICLOUD_PASSWORD"     :  sICLOUD_PASSWORD      = Sql.ToString (dict[sColumnName]);  break;
					case "ICLOUD_SECURITY_CODE":  sICLOUD_SECURITY_CODE = Sql.ToString (dict[sColumnName]);  break;
				}
			}
			DataRow rdr = null;
			if ( !Sql.IsEmptyGuid(gID) )
			{
				rdr = GetUser(gID);
			}

			string sENCRYPTED_EMAIL_PASSWORD = String.Empty;
			Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
			Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
			if ( sICLOUD_PASSWORD == Sql.sEMPTY_PASSWORD && rdr != null )
			{
				sICLOUD_PASSWORD = Sql.ToString(rdr["ICLOUD_PASSWORD"]);
				if ( !Sql.IsEmptyString(sICLOUD_PASSWORD) )
					sICLOUD_PASSWORD = Security.DecryptPassword(sICLOUD_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
			}
			// 03/25/2011 Paul.  Use SMTP values if the Google values have not been provided. 
			if ( Sql.IsEmptyString(sICLOUD_USERNAME) && !Sql.IsEmptyString(sMAIL_SMTPUSER) )
			{
				sICLOUD_USERNAME = sMAIL_SMTPUSER;
			}
			if ( Sql.IsEmptyString(sICLOUD_PASSWORD) )
			{
				if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD && rdr != null )
				{
					sENCRYPTED_EMAIL_PASSWORD = Sql.ToString(rdr["MAIL_SMTPPASS"]);
					if ( !Sql.IsEmptyString(sENCRYPTED_EMAIL_PASSWORD) )
					{
						sMAIL_SMTPPASS = Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
					}
				}
				sICLOUD_PASSWORD = sMAIL_SMTPPASS;
			}
			if ( !Sql.IsEmptyString(sICLOUD_SECURITY_CODE) )
				sICLOUD_PASSWORD += sICLOUD_SECURITY_CODE;
			
			string sStatus = String.Empty;
			StringBuilder sbErrors = new StringBuilder();
			iCloudSync.Validate_iCloud(Application, sICLOUD_USERNAME, sICLOUD_PASSWORD, sbErrors);
			if ( sbErrors.Length > 0 )
			{
				sStatus = sbErrors.ToString();
			}
			else
			{
				sStatus = L10n.Term("Users.LBL_ICLOUD_TEST_SUCCESSFUL");
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
			
			Guid   gID            = Guid.Empty  ;
			string sMAIL_SENDTYPE = String.Empty;
			string sCode          = String.Empty;
			string sRedirectURL   = String.Empty;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"           :  gID           = Sql.ToGuid   (dict[sColumnName]);  break;
					case "MAIL_SENDTYPE": sMAIL_SENDTYPE = Sql.ToString (dict[sColumnName]);  break;
					case "code"         :  sCode         = Sql.ToString (dict[sColumnName]);  break;
					case "redirect_url" :  sRedirectURL  = Sql.ToString (dict[sColumnName]);  break;
				}
			}
			string sEMAIL1 = String.Empty;
			if ( gID == Security.USER_ID || Security.AdminUserAccess("Users", "edit") >= 0 )
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
					Google.Apis.Auth.OAuth2.Responses.TokenResponse token = flow.ExchangeCodeForTokenAsync(sUserID, sCode, sRedirectURL, CancellationToken.None).Result;
					// 02/03/2017 Paul.  IE11 is getting stuck due to Protected Mode for Security / Internet service. window.opener === undefined after return from Google URL. 
					string OAUTH_ACCESS_TOKEN      = token.AccessToken           ;
					string sTokenType              = token.TokenType             ;
					string OAUTH_REFRESH_TOKEN     = token.RefreshToken          ;
					string OAUTH_EXPIRES_IN        = token.ExpiresInSeconds.Value.ToString();

					DateTime dtOAUTH_EXPIRES_AT = DateTime.Now.AddSeconds(Sql.ToInteger(OAUTH_EXPIRES_IN));
					SqlProcs.spOAUTH_TOKENS_Update(gID, "GoogleApps", OAUTH_ACCESS_TOKEN, String.Empty, dtOAUTH_EXPIRES_AT, OAUTH_REFRESH_TOKEN);
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthAccessToken" ] = OAUTH_ACCESS_TOKEN;
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthRefreshToken"] = OAUTH_REFRESH_TOKEN;
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthExpiresAt"   ] = dtOAUTH_EXPIRES_AT.ToShortDateString() + " " + dtOAUTH_EXPIRES_AT.ToShortTimeString();
					// 01/19/2017 Paul.  We want an OUTBOUND_EMAILS mapping to the office365 OAuth record. 
					// 02/04/2017 Paul.  OutboundEmail NAME will be system when Gmail is the primary send type.  Otherwise this is just an older-style GoogleApps sync. 
					if ( String.Compare(sMAIL_SENDTYPE, "GoogleApps", true) == 0 )
					{
						Guid gOUTBOUND_EMAIL_ID = Guid.Empty;
						SqlProcs.spOUTBOUND_EMAILS_Update(ref gOUTBOUND_EMAIL_ID, "system", "system-override", gID, "GoogleApps", null, null, 0, null, null, false, 0, null, null, Guid.Empty, null);
					}
					//lblGoogleAuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					//btnGoogleAppsAuthorize   .Visible = false;
					//btnGoogleAppsDelete      .Visible = true ;
					//btnGoogleAppsTest        .Visible = true ;
					//btnGoogleAppsRefreshToken.Visible = true && bDebug;
					//lblGoogleAppsAuthorized  .Visible = true ;
					if ( gID == Security.USER_ID )
						Session["GOOGLEAPPS_OAUTH_ENABLED"] = true;
					// 02/09/2017 Paul.  Update the email address. 
					StringBuilder sbErrors = new StringBuilder();
					// 07/14/2020 Paul.  If email not accessible, just ignore as we have a valid token. 
					sEMAIL1 = SplendidCRM.GoogleApps.GetEmailAddress(Application, gID, sbErrors);
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
			
			Guid   gID            = Guid.Empty  ;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"           :  gID           = Sql.ToGuid   (dict[sColumnName]);  break;
				}
			}
			string sEMAIL1 = String.Empty;
			if ( gID == Security.USER_ID || Security.AdminUserAccess("Users", "edit") >= 0 )
			{
				SqlProcs.spOAUTH_TOKENS_Delete(gID, "GoogleApps");
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
			
			Guid   gID            = Guid.Empty  ;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"           :  gID           = Sql.ToGuid   (dict[sColumnName]);  break;
				}
			}
			string sStatus = String.Empty;
			if ( gID == Security.USER_ID || Security.AdminUserAccess("Users", "edit") >= 0 )
			{
				StringBuilder sbErrors = new StringBuilder();
				SplendidCRM.GoogleApps.TestAccessToken(Application, gID, sbErrors);

				DataRow rdr = GetUser(gID);
				if ( rdr != null )
				{
					string sFROM_ADDR = Sql.ToString(rdr["EMAIL1"]);
					string sFROM_NAME = Sql.ToString(rdr["FIRST_NAME"]) + " " + Sql.ToString(rdr["LAST_NAME"]);
					SplendidCRM.GoogleApps.SendTestMessage(Application, gID, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
					sStatus = sbErrors.ToString();
					if ( Sql.IsEmptyString(sStatus) )
						sStatus = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
				}
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
			
			Guid   gID            = Guid.Empty  ;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"           :  gID           = Sql.ToGuid   (dict[sColumnName]);  break;
				}
			}
			string sEMAIL1 = String.Empty;
			if ( gID == Security.USER_ID || Security.AdminUserAccess("Users", "edit") >= 0 )
			{
				SplendidCRM.GoogleApps.RefreshAccessToken(Application, gID, true);
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
			
			Guid   gID            = Guid.Empty  ;
			string sMAIL_SENDTYPE = String.Empty;
			string sCode          = String.Empty;
			string sRedirectURL   = String.Empty;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"           :  gID           = Sql.ToGuid   (dict[sColumnName]);  break;
					case "MAIL_SENDTYPE": sMAIL_SENDTYPE = Sql.ToString (dict[sColumnName]);  break;
					case "code"         :  sCode         = Sql.ToString (dict[sColumnName]);  break;
					case "redirect_url" :  sRedirectURL  = Sql.ToString (dict[sColumnName]);  break;
				}
			}
			string sEMAIL1 = String.Empty;
			if ( gID == Security.USER_ID || Security.AdminUserAccess("Users", "edit") >= 0 )
			{
				if ( !Sql.IsEmptyString(sCode) )
				{
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
					string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
					// 11/09/2019 Paul.  Pass the RedirectURL so that we can call from the React client. 
					Office365AccessToken token = SplendidCRM.ActiveDirectory.Office365AcquireAccessToken(Context, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, gID, sCode, sRedirectURL);
					// 01/19/2017 Paul.  We want an OUTBOUND_EMAILS mapping to the office365 OAuth record. 
					// 02/04/2017 Paul.  OutboundEmail NAME is "system" as it will be the primary email for the user. 
					Guid gOUTBOUND_EMAIL_ID = Guid.Empty;
					SqlProcs.spOUTBOUND_EMAILS_Update(ref gOUTBOUND_EMAIL_ID, "system", "system-override", gID, "Office365", null, null, 0, null, null, false, 0, null, null, Guid.Empty, null);
					
					if ( gID == Security.USER_ID )
						Session["OFFICE365_OAUTH_ENABLED"] = true;
					// 02/09/2017 Paul.  Use Microsoft Graph REST API to get email. 
					MicrosoftGraphProfile profile = SplendidCRM.ActiveDirectory.GetProfile(Application, token.AccessToken);
					if ( profile != null )
					{
						sEMAIL1 = Sql.ToString(profile.EmailAddress);
					}
					// 03/24/2021 Paul.  We may need to enable Exchange Sync.  Office365 is enabled in Office365_Authorize. 
					DataRow rdr = GetUser(gID);
					if ( rdr != null )
					{
						string sUSER_NAME = Sql.ToString (rdr["USER_NAME"]);
						// 04/06/2021 Paul.  Office365 may not return the email. 
						if ( Sql.IsEmptyString(sEMAIL1) )
							sEMAIL1 = Sql.ToString (rdr["EMAIL1"]);
						if ( Sql.ToBoolean(Application["CONFIG.Exchange.DefaultEnableExchangeFolders"]) && !Sql.IsEmptyString(sEMAIL1) )
						{
							string sEXCHANGE_ALIAS    = sUSER_NAME;
							string sEXCHANGE_EMAIL    = sEMAIL1   ;
							string sIMPERSONATED_TYPE = Sql.ToString(Application["CONFIG.Exchange.ImpersonatedType"]);
							Guid gEXCHNAGE_USER_ID = Guid.Empty;
							SqlProcs.spEXCHANGE_USERS_Update
								( ref gEXCHNAGE_USER_ID
								, sEXCHANGE_ALIAS
								, sEXCHANGE_EMAIL
								, sIMPERSONATED_TYPE
								, gID  // 05/01/2018 Paul.  This user. 
								);
						}
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
			
			Guid   gID            = Guid.Empty  ;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"           :  gID           = Sql.ToGuid   (dict[sColumnName]);  break;
				}
			}
			string sEMAIL1 = String.Empty;
			if ( gID == Security.USER_ID || Security.AdminUserAccess("Users", "edit") >= 0 )
			{
				SqlProcs.spOAUTH_TOKENS_Delete(gID, "Office365");
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
			
			Guid   gID            = Guid.Empty  ;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"           :  gID           = Sql.ToGuid   (dict[sColumnName]);  break;
				}
			}
			string sStatus = String.Empty;
			if ( gID == Security.USER_ID || Security.AdminUserAccess("Users", "edit") >= 0 )
			{
				StringBuilder sbErrors = new StringBuilder();
				string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
				string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
				// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
				string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
				SplendidCRM.ActiveDirectory.Office365TestAccessToken(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, gID, sbErrors);

				DataRow rdr = GetUser(gID);
				if ( rdr != null )
				{
					string sFROM_ADDR = Sql.ToString(rdr["EMAIL1"]);
					string sFROM_NAME = Sql.ToString(rdr["FIRST_NAME"]) + " " + Sql.ToString(rdr["LAST_NAME"]);
					// 12/13/2020 Paul.  Move Office365 methods to Office365utils. 
					Office365Utils.SendTestMessage(Application, gID, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
					sStatus = sbErrors.ToString();
				}
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
			
			Guid   gID            = Guid.Empty  ;
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "ID"           :  gID           = Sql.ToGuid   (dict[sColumnName]);  break;
				}
			}
			string sEMAIL1 = String.Empty;
			if ( gID == Security.USER_ID || Security.AdminUserAccess("Users", "edit") >= 0 )
			{
				string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
				string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
				// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
				string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
				SplendidCRM.ActiveDirectory.Office365RefreshAccessToken(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, gID, true);
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
		}

		[OperationContract]
		// 03/24/2021 Paul.  We may need to enable Exchange Sync.  Office365 is enabled in Office365_Authorize. 
		public void EnableExchangeSync(Stream input)
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
			
			Guid gID = Sql.ToGuid(Request["ID"]);
			if ( gID == Security.USER_ID || Security.AdminUserAccess("Users", "edit") >= 0 )
			{
				DataRow rdr = GetUser(gID);
				if ( rdr != null )
				{
					string sUSER_NAME               = Sql.ToString (rdr["USER_NAME"              ]);
					string sEMAIL1                  = Sql.ToString (rdr["EMAIL1"                 ]);
					string sMAIL_SENDTYPE           = Sql.ToString (rdr["MAIL_SENDTYPE"          ]);
					string sMAIL_SMTPUSER           = Sql.ToString (rdr["MAIL_SMTPUSER"          ]);
					string sMAIL_SMTPPASS           = Sql.ToString (rdr["MAIL_SMTPPASS"          ]);
					if ( Sql.ToBoolean(Application["CONFIG.Exchange.DefaultEnableExchangeFolders"]) && !Sql.IsEmptyString(sEMAIL1) )
					{
						if ( sMAIL_SENDTYPE == "Exchange-Password" && !Sql.IsEmptyString(sMAIL_SMTPUSER) && !Sql.IsEmptyString(sMAIL_SMTPPASS) )
						{
							string sEXCHANGE_ALIAS    = sUSER_NAME;
							string sEXCHANGE_EMAIL    = sEMAIL1   ;
							string sIMPERSONATED_TYPE = Sql.ToString(Application["CONFIG.Exchange.ImpersonatedType"]);
							Guid gEXCHNAGE_USER_ID = Guid.Empty;
							SqlProcs.spEXCHANGE_USERS_Update
								( ref gEXCHNAGE_USER_ID
								, sEXCHANGE_ALIAS
								, sEXCHANGE_EMAIL
								, sIMPERSONATED_TYPE
								, gID  // 05/01/2018 Paul.  This user. 
								);
						}
					}
				}
				else
				{
					throw(new Exception("User not found for ID " + gID.ToString()));
				}
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
		}

	}
}
