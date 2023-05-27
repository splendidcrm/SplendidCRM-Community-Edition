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

using MimeKit;
using MailKit;
using MailKit.Net.Pop3;
using MailKit.Net.Imap;

namespace SplendidCRM.Administration.InboundEmail
{
	[ServiceContract]
	[ServiceBehavior( IncludeExceptionDetailInFaults = true )]
	[AspNetCompatibilityRequirements( RequirementsMode = AspNetCompatibilityRequirementsMode.Required )]
	public class Rest
	{
		private DataRow GetRecord(Guid gID)
		{
			DataRow rdr = null;
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL ;
				sSQL = "select *                " + ControlChars.CrLf
				     + "  from vwINBOUND_EMAILS " + ControlChars.CrLf
				     + " where ID = @ID         " + ControlChars.CrLf;
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
		public string CheckMailbox(Stream input)
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
			
			string sStatus = String.Empty;
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
			{
				Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
				Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
				string sSERVICE        = String.Empty;
				string sSERVER_URL     = String.Empty;
				int    nPORT           = 0;
				bool   bMAILBOX_SSL    = false;
				string sEMAIL_USER     = String.Empty;
				string sEMAIL_PASSWORD = String.Empty;
				string sMAILBOX        = String.Empty;
				string sENCRYPTED_EMAIL_PASSWORD = String.Empty;
				Guid gID = Sql.ToGuid(Request["ID"]);
				if ( !Sql.IsEmptyGuid(gID) )
				{
					DataRow rdr = GetRecord(gID);
					if ( rdr != null )
					{
						sSERVICE        = Sql.ToString (rdr["SERVICE"       ]);
						sSERVER_URL     = Sql.ToString (rdr["SERVER_URL"    ]);
						nPORT           = Sql.ToInteger(rdr["PORT"          ]);
						bMAILBOX_SSL    = Sql.ToBoolean(rdr["MAILBOX_SSL"   ]);
						sEMAIL_USER     = Sql.ToString (rdr["EMAIL_USER"    ]);
						sEMAIL_PASSWORD = Sql.ToString (rdr["EMAIL_PASSWORD"]);
						sMAILBOX        = Sql.ToString (rdr["MAILBOX"       ]);
						sENCRYPTED_EMAIL_PASSWORD = sEMAIL_PASSWORD;
						if ( !Sql.IsEmptyString(sENCRYPTED_EMAIL_PASSWORD) )
						{
							sEMAIL_PASSWORD = Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						}
					}
					else
					{
						throw(new Exception("Record not found for ID " + gID.ToString()));
					}
				}
				else
				{
					throw(new Exception("missing ID"));
				}
				foreach ( string sColumnName in dict.Keys )
				{
					switch ( sColumnName )
					{
						case "SERVICE"       :  sSERVICE        = Sql.ToString (dict[sColumnName]);  break;
						case "SERVER_URL"    :  sSERVER_URL     = Sql.ToString (dict[sColumnName]);  break;
						case "PORT"          :  nPORT           = Sql.ToInteger(dict[sColumnName]);  break;
						case "MAILBOX_SSL"   :  bMAILBOX_SSL    = Sql.ToBoolean(dict[sColumnName]);  break;
						case "MAILBOX"       :  sMAILBOX        = Sql.ToString (dict[sColumnName]);  break;
						case "EMAIL_USER"    :  sEMAIL_USER     = Sql.ToString (dict[sColumnName]);  break;
						case "EMAIL_PASSWORD":
						{
							sEMAIL_PASSWORD     = Sql.ToString (dict[sColumnName]);
						
							if ( !(Sql.IsEmptyString(sEMAIL_PASSWORD) || sEMAIL_PASSWORD == Sql.sEMPTY_PASSWORD) )
							{
								sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
							}
			
							break;
						}
					}
				}
				StringBuilder sbErrors = new StringBuilder();
				if ( String.Compare(sSERVICE, "pop3", true) == 0 )
				{
					PopUtils.Validate(Context, sSERVER_URL, nPORT, bMAILBOX_SSL, sEMAIL_USER, sEMAIL_PASSWORD, sbErrors);
					sStatus = sbErrors.ToString();
				}
				else if ( String.Compare(sSERVICE, "imap", true) == 0 )
				{
					ImapUtils.Validate(Context, sSERVER_URL, nPORT, bMAILBOX_SSL, sEMAIL_USER, sEMAIL_PASSWORD, sMAILBOX, sbErrors);
					sStatus = sbErrors.ToString();
				}
				// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
				else if ( String.Compare(sSERVICE, "Exchange-Password", true) == 0 )
				{
					sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
					string sIMPERSONATED_TYPE        = Sql.ToString (Application["CONFIG.Exchange.ImpersonatedType" ]);
					sSERVER_URL = Sql.ToString (Application["CONFIG.Exchange.ServerURL"]);
					// 12/13/2017 Paul.  Allow version to be changed. 
					string sEXCHANGE_VERSION = Sql.ToString(Application["CONFIG.Exchange.Version"]);
					ExchangeUtils.ValidateExchange(Application, sSERVER_URL, sEMAIL_USER, sENCRYPTED_EMAIL_PASSWORD, true, sIMPERSONATED_TYPE, sEXCHANGE_VERSION, sbErrors);
					sStatus = sbErrors.ToString();
				}
				else
				{
					throw(new Exception("This is not the correct button to test this service: " + sSERVICE));
				}
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
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
			
			Guid   gID            = Sql.ToGuid(Request["ID"]);
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
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
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
					// 09/25/2015 Paul.  Redirect URL must match those allowed in Google Developer Console. https://console.developers.google.com/project/_/apiui/credential
					/*Google.Apis.Auth.OAuth2.Responses.TokenResponse*/var token = flow.ExchangeCodeForTokenAsync(gID.ToString(), sCode, sRedirectURL, CancellationToken.None).Result;
					string OAUTH_ACCESS_TOKEN      = token.AccessToken           ;
					string sTokenType              = token.TokenType             ;
					string OAUTH_REFRESH_TOKEN     = token.RefreshToken          ;
					string OAUTH_EXPIRES_IN        = token.ExpiresInSeconds.Value.ToString();

					DateTime dtOAUTH_EXPIRES_AT = DateTime.Now.AddSeconds(Sql.ToInteger(OAUTH_EXPIRES_IN));
					SqlProcs.spOAUTH_TOKENS_Update(gID, "GoogleApps", OAUTH_ACCESS_TOKEN, String.Empty, dtOAUTH_EXPIRES_AT, OAUTH_REFRESH_TOKEN);
					SqlProcs.spOAUTH_TOKENS_Update(gID, "GoogleApps", OAUTH_ACCESS_TOKEN, String.Empty, dtOAUTH_EXPIRES_AT, OAUTH_REFRESH_TOKEN);
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthAccessToken" ] = OAUTH_ACCESS_TOKEN ;
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthRefreshToken"] = OAUTH_REFRESH_TOKEN;
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthExpiresAt"   ] = dtOAUTH_EXPIRES_AT.ToShortDateString() + " " + dtOAUTH_EXPIRES_AT.ToShortTimeString();
					StringBuilder sbErrors = new StringBuilder();
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
			
			Guid gID = Sql.ToGuid(Request["ID"]);
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
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
			
			string sStatus            = String.Empty;
			Guid   gID                = Sql.ToGuid(Request["ID"]);
			string sMAILBOX           = String.Empty;
			string sFROM_NAME         = String.Empty;
			if ( !Sql.IsEmptyGuid(gID) )
			{
				DataRow rdr = GetRecord(gID);
				if ( rdr != null )
				{
					sMAILBOX = Sql.ToString (rdr["MAILBOX"]);
				}
				else
				{
					throw(new Exception("Record not found for ID " + gID.ToString()));
				}
			}
			else
			{
				throw(new Exception("missing ID"));
			}
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "MAILBOX":
						if ( !Sql.IsEmptyString(dict[sColumnName]) )
							sMAILBOX = Sql.ToString (dict[sColumnName]);
						break;
				}
			}
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
			{
				StringBuilder sbErrors = new StringBuilder();
				SplendidCRM.GoogleApps.TestMailbox(Application, gID, sMAILBOX, sbErrors);
				sStatus = sbErrors.ToString();
				if ( Sql.IsEmptyString(sStatus) )
					sStatus = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
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
			
			Guid gID = Sql.ToGuid(Request["ID"]);
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
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
			
			Guid   gID            = Sql.ToGuid(Request["ID"]);
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
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
			{
				if ( !Sql.IsEmptyString(sCode) )
				{
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
					string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
					// 11/09/2019 Paul.  Pass the RedirectURL so that we can call from the React client. 
					Office365AccessToken token = SplendidCRM.ActiveDirectory.Office365AcquireAccessToken(Context, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, gID, sCode, sRedirectURL);
					
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
			
			Guid gID = Sql.ToGuid(Request["ID"]);
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
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
			
			Guid   gID      = Sql.ToGuid(Request["ID"]);
			string sMAILBOX = String.Empty;
			if ( !Sql.IsEmptyGuid(gID) )
			{
				DataRow rdr = GetRecord(gID);
				if ( rdr != null )
				{
					sMAILBOX = Sql.ToString (rdr["MAILBOX"]);
				}
				else
				{
					throw(new Exception("Record not found for ID " + gID.ToString()));
				}
			}
			else
			{
				throw(new Exception("missing ID"));
			}
			foreach ( string sColumnName in dict.Keys )
			{
				switch ( sColumnName )
				{
					case "MAILBOX":
						if ( !Sql.IsEmptyString(dict[sColumnName]) )
							sMAILBOX = Sql.ToString (dict[sColumnName]);
						break;
				}
			}

			string sStatus = String.Empty;
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
			{
				StringBuilder sbErrors = new StringBuilder();
				string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
				string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
				// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
				string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
				// 12/13/2020 Paul.  Move Office365 methods to Office365utils. 
				Office365Utils.ValidateExchange(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, gID, sMAILBOX, sbErrors);
#if DEBUG
				Office365AccessToken token = SplendidCRM.ActiveDirectory.Office365RefreshAccessToken(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, gID, false);
				// 02/09/2017 Paul.  Use Microsoft Graph REST API to get email. 
				MicrosoftGraphProfile profile = SplendidCRM.ActiveDirectory.GetProfile(Application, token.AccessToken);
				if ( profile != null )
					Debug.WriteLine(Sql.ToString(profile.EmailAddress));
#endif
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
			
			Guid   gID     = Sql.ToGuid(Request["ID"]);
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
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
		public void CheckBounce(Stream input)
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
			
			Guid   gID     = Sql.ToGuid(Request["ID"]);
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
			{
				EmailUtils.CheckInbound(HttpContext.Current, gID, true);
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
		}

		[OperationContract]
		public void CheckInbound(Stream input)
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
			
			Guid   gID     = Sql.ToGuid(Request["ID"]);
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
			{
				EmailUtils.CheckInbound(HttpContext.Current, gID, false);
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
		}

		[OperationContract]
		public Stream GetMail(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			HttpServerUtility    Server      = HttpContext.Current.Server     ;
			
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
			
			Guid      gID       = Sql.ToGuid(Request["ID"]);
			Guid      gTIMEZONE = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone  T10n      = TimeZone.CreateTimeZone(gTIMEZONE);
			DataTable dtMain    = new DataTable();
			if ( Security.IsAuthenticated() && Security.AdminUserAccess("InboundEmail", "edit") >= 0 )
			{
				Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
				Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
				string sSERVICE                  = String.Empty;
				string sSERVER_URL               = String.Empty;
				int    nPORT                     = 0;
				bool   bMAILBOX_SSL              = false;
				string sEMAIL_USER               = String.Empty;
				string sEMAIL_PASSWORD           = String.Empty;
				string sMAILBOX                  = String.Empty;
				bool   bOFFICE365_OAUTH_ENABLED  = false;
				bool   bGOOGLEAPPS_OAUTH_ENABLED = false;
				if ( !Sql.IsEmptyGuid(gID) )
				{
					DataRow rdr = GetRecord(gID);
					if ( rdr != null )
					{
						sSERVICE                  = Sql.ToString (rdr["SERVICE"                 ]);
						sSERVER_URL               = Sql.ToString (rdr["SERVER_URL"              ]);
						nPORT                     = Sql.ToInteger(rdr["PORT"                    ]);
						bMAILBOX_SSL              = Sql.ToBoolean(rdr["MAILBOX_SSL"             ]);
						sEMAIL_USER               = Sql.ToString (rdr["EMAIL_USER"              ]);
						sEMAIL_PASSWORD           = Sql.ToString (rdr["EMAIL_PASSWORD"          ]);
						sMAILBOX                  = Sql.ToString (rdr["MAILBOX"                 ]);
						bOFFICE365_OAUTH_ENABLED  = Sql.ToBoolean(rdr["OFFICE365_OAUTH_ENABLED" ]);
						bGOOGLEAPPS_OAUTH_ENABLED = Sql.ToBoolean(rdr["GOOGLEAPPS_OAUTH_ENABLED"]);
					}
					else
					{
						throw(new Exception("Record not found for ID " + gID.ToString()));
					}
				}
				else
				{
					throw(new Exception("missing ID"));
				}

				dtMain.Columns.Add("From"        , typeof(System.String  ));
				dtMain.Columns.Add("Sender"      , typeof(System.String  ));
				dtMain.Columns.Add("ReplyTo"     , typeof(System.String  ));
				dtMain.Columns.Add("To"          , typeof(System.String  ));
				dtMain.Columns.Add("CC"          , typeof(System.String  ));
				dtMain.Columns.Add("Bcc"         , typeof(System.String  ));
				dtMain.Columns.Add("Subject"     , typeof(System.String  ));
				dtMain.Columns.Add("DeliveryDate", typeof(System.DateTime));
				dtMain.Columns.Add("Priority"    , typeof(System.String  ));
				dtMain.Columns.Add("Size"        , typeof(System.Int32   ));
				dtMain.Columns.Add("ContentID"   , typeof(System.String  ));
				dtMain.Columns.Add("MessageID"   , typeof(System.String  ));
				dtMain.Columns.Add("Headers"     , typeof(System.String  ));

				// 01/16/2017 Paul.  Add support for Office 365 OAuth. 
				if ( bOFFICE365_OAUTH_ENABLED )
				{
					// 12/13/2020 Paul.  Move Office365 methods to Office365utils. 
					Spring.Social.Office365.Office365Sync.UserSync User = new Spring.Social.Office365.Office365Sync.UserSync(Context, String.Empty, String.Empty, String.Empty, String.Empty, gID, false, bOFFICE365_OAUTH_ENABLED);
					string sFOLDER_ID = Office365Utils.GetFolderId(Context, String.Empty, String.Empty, gID, sMAILBOX);
					if ( Sql.IsEmptyString(sFOLDER_ID) )
						throw(new Exception("Could not find folder " + sMAILBOX));
						
					DataTable dt = Office365Utils.GetFolderMessages(User, sFOLDER_ID, 200, 0, "DATE_START", "desc");
					foreach ( DataRow row in dt.Rows )
					{
						DataRow rowMain = dtMain.NewRow();
						dtMain.Rows.Add(rowMain);
						rowMain["From"        ] = row["FROM"            ];
						rowMain["Sender"      ] = String.Empty;
						rowMain["ReplyTo"     ] = String.Empty;
						rowMain["To"          ] = row["TO_ADDRS"        ];
						rowMain["CC"          ] = row["CC_ADDRS"        ];
						rowMain["Bcc"         ] = String.Empty;
						rowMain["Subject"     ] = row["NAME"            ];
						rowMain["DeliveryDate"] = row["DATE_START"      ];
						rowMain["Priority"    ] = String.Empty;
						rowMain["Size"        ] = row["SIZE"            ];
						rowMain["ContentID"   ] = row["UNIQUE_ID"       ];
						rowMain["MessageID"   ] = row["MESSAGE_ID"      ];
						rowMain["Headers"     ] = row["INTERNET_HEADERS"];
					}
				}
				// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
				else if ( String.Compare(sSERVICE, "Exchange-Password", true) == 0 )
				{
					try
					{
						ExchangeSync.UserSync User = new ExchangeSync.UserSync(Context, String.Empty, String.Empty, sEMAIL_USER, sEMAIL_PASSWORD, Guid.Empty, String.Empty, false, false);
						string sFOLDER_ID = ExchangeUtils.GetFolderId(Context, sEMAIL_USER, sEMAIL_PASSWORD, Guid.Empty, sMAILBOX);
						if ( Sql.IsEmptyString(sFOLDER_ID) )
							throw(new Exception("Could not find folder " + sMAILBOX));
						
						DataTable dt = ExchangeUtils.GetFolderMessages(User, sFOLDER_ID, 200, 0, "DATE_START", "desc");
						foreach ( DataRow row in dt.Rows )
						{
							DataRow rowMain = dtMain.NewRow();
							dtMain.Rows.Add(rowMain);
							rowMain["From"        ] = row["FROM"            ];
							rowMain["Sender"      ] = String.Empty;
							rowMain["ReplyTo"     ] = String.Empty;
							rowMain["To"          ] = row["TO_ADDRS"        ];
							rowMain["CC"          ] = row["CC_ADDRS"        ];
							rowMain["Bcc"         ] = String.Empty;
							rowMain["Subject"     ] = row["NAME"            ];
							rowMain["DeliveryDate"] = row["DATE_START"      ];
							rowMain["Priority"    ] = String.Empty;
							rowMain["Size"        ] = row["SIZE"            ];
							rowMain["ContentID"   ] = row["UNIQUE_ID"       ];
							rowMain["MessageID"   ] = row["MESSAGE_ID"      ];
							rowMain["Headers"     ] = row["INTERNET_HEADERS"];
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						throw;
					}
				}
				else if ( bGOOGLEAPPS_OAUTH_ENABLED )
				{
					DataTable dt = GoogleApps.GetFolderMessages(Context, gID, sMAILBOX, false, 0, 200);
					foreach ( DataRow row in dt.Rows )
					{
						DataRow rowMain = dtMain.NewRow();
						dtMain.Rows.Add(rowMain);
						rowMain["From"        ] = row["FROM"            ];
						rowMain["Sender"      ] = String.Empty;
						rowMain["ReplyTo"     ] = String.Empty;
						rowMain["To"          ] = row["TO_ADDRS"        ];
						rowMain["CC"          ] = row["CC_ADDRS"        ];
						rowMain["Bcc"         ] = String.Empty;
						rowMain["Subject"     ] = row["NAME"            ];
						rowMain["DeliveryDate"] = row["DATE_START"      ];
						rowMain["Priority"    ] = String.Empty;
						rowMain["Size"        ] = row["SIZE"            ];
						rowMain["ContentID"   ] = row["UNIQUE_ID"       ];
						rowMain["MessageID"   ] = row["MESSAGE_ID"      ];
						rowMain["Headers"     ] = row["INTERNET_HEADERS"];
					}
				}
				// 10/28/2010 Paul.  Add support for IMAP. 
				else if ( String.Compare(sSERVICE, "imap", true) == 0 )
				{
					// 01/08/2008 Paul.  Decrypt at the last minute to ensure that an unencrypted password is never sent to the browser. 
					sEMAIL_PASSWORD = Security.DecryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
					try
					{
						if ( Sql.IsEmptyString(sMAILBOX) )
							sMAILBOX = "INBOX";
						//using ( ImapConnect connection = new ImapConnect(sSERVER_URL, nPORT, bMAILBOX_SSL) )
						using ( ImapClient imap = new ImapClient() )
						{
							imap.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
							imap.AuthenticationMechanisms.Remove ("XOAUTH2");
							// 01/22/2017 Paul.  There is a bug with NTLM. 
							// http://stackoverflow.com/questions/39573233/mailkit-authenticate-to-imap-fails
							imap.AuthenticationMechanisms.Remove ("NTLM");
							imap.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
							IMailFolder mailbox = imap.GetFolder(sMAILBOX);
							if ( mailbox != null )
							{
								mailbox.Open(FolderAccess.ReadOnly);
								// 01/21/2017 Paul.  Limit the messages to 200 to prevent a huge loop. 
								int nStartIndex = Math.Max(mailbox.Count - 200, 0);
								// All is a macro for Envelope, Flags, InternalDate, and MessageSize. 
								IList<IMessageSummary> lstMessages = mailbox.Fetch(nStartIndex, -1, MessageSummaryItems.All | MessageSummaryItems.UniqueId);
								for ( int i = 0; i < lstMessages.Count ; i++ )
								{
									IMessageSummary summary = lstMessages[i];
									string sHeaders = String.Empty;
									if ( summary.Headers != null )
									{
										using ( MemoryStream mem = new MemoryStream() )
										{
											summary.Headers.WriteTo(mem);
											mem.Position = 0;
											using ( StreamReader rdr = new StreamReader(mem) )
											{
												sHeaders = rdr.ReadToEnd();
											}
										}
									}
										
									DataRow row = dtMain.NewRow();
									dtMain.Rows.Add(row);
									row["From"        ] = Server.HtmlEncode(summary.Envelope.From    != null ? summary.Envelope.From   .ToString() : String.Empty);
									row["Sender"      ] = Server.HtmlEncode(summary.Envelope.Sender  != null ? summary.Envelope.Sender .ToString() : String.Empty);
									row["ReplyTo"     ] = Server.HtmlEncode(summary.Envelope.ReplyTo != null ? summary.Envelope.ReplyTo.ToString() : String.Empty);
									row["To"          ] = Server.HtmlEncode(summary.Envelope.To      != null ? summary.Envelope.To     .ToString() : String.Empty);
									row["CC"          ] = Server.HtmlEncode(summary.Envelope.Cc      != null ? summary.Envelope.Cc     .ToString() : String.Empty);
									row["Bcc"         ] = Server.HtmlEncode(summary.Envelope.Bcc     != null ? summary.Envelope.Bcc    .ToString() : String.Empty);
									row["Subject"     ] = Server.HtmlEncode(summary.Envelope.Subject);
									// 01/23/2008 Paul.  DateTime in the email is in universal time. 
									row["DeliveryDate"] = summary.Date.DateTime.ToLocalTime();
									row["Priority"    ] = DBNull.Value;
									if ( summary.Size.HasValue )
										row["Size"    ] = summary.Size;
									row["ContentId"   ] = DBNull.Value;
									row["MessageId"   ] = summary.Envelope.MessageId;
									row["Headers"     ] = "<pre>" + Server.HtmlEncode(sHeaders) + "</pre>";
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						throw;
					}
				}
				else if ( String.Compare(sSERVICE, "pop3", true) == 0 )
				{
					// 01/08/2008 Paul.  Decrypt at the last minute to ensure that an unencrypted password is never sent to the browser. 
					sEMAIL_PASSWORD = Security.DecryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						
					//Pop3.Pop3MimeClient pop = new Pop3.Pop3MimeClient(sSERVER_URL, nPORT, bMAILBOX_SSL, sEMAIL_USER, sEMAIL_PASSWORD);
					try
					{
						using ( Pop3Client pop = new Pop3Client() )
						{
							pop.Timeout = 60 * 1000; //give pop server 60 seconds to answer
							pop.Connect(sSERVER_URL, nPORT, (bMAILBOX_SSL ? MailKit.Security.SecureSocketOptions.SslOnConnect : MailKit.Security.SecureSocketOptions.Auto));
							pop.AuthenticationMechanisms.Remove ("XOAUTH2");
							pop.Authenticate (sEMAIL_USER, sEMAIL_PASSWORD);
								
							int nTotalEmails = pop.Count;
							int nStartIndex  = nTotalEmails - 200;
							if ( nStartIndex < 0 )
								nStartIndex = 0;
							IList<int> lstMessageSizes = pop.GetMessageSizes();
							// 01/22/2017 Paul.  Get headers only. 
							IList<Stream> lstHeaders = pop.GetStreams(nStartIndex, nTotalEmails - nStartIndex, true);
							for ( int i = 0; i < lstHeaders.Count; i++ )
							{
								string sRawContent = String.Empty;
								MimeMessage mm = MimeMessage.Load(lstHeaders[i]);
								using ( MemoryStream mem = new MemoryStream() )
								{
									mm.WriteTo(mem);
									mem.Position = 0;
									using ( StreamReader rdr = new StreamReader(mem) )
									{
										sRawContent = rdr.ReadToEnd();
									}
								}
									
								DataRow row = dtMain.NewRow();
								dtMain.Rows.Add(row);
								if ( mm.From    != null ) row["From"        ] = Server.HtmlEncode(mm.From   .ToString());
								if ( mm.Sender  != null ) row["Sender"      ] = Server.HtmlEncode(mm.Sender .ToString());
								if ( mm.ReplyTo != null ) row["ReplyTo"     ] = Server.HtmlEncode(mm.ReplyTo.ToString());
								if ( mm.To      != null ) row["To"          ] = Server.HtmlEncode(mm.To     .ToString());
								if ( mm.Cc      != null ) row["CC"          ] = Server.HtmlEncode(mm.Cc     .ToString());
								if ( mm.Bcc     != null ) row["Bcc"         ] = Server.HtmlEncode(mm.Bcc    .ToString());
								if ( mm.Subject != null ) row["Subject"     ] = Server.HtmlEncode(mm.Subject);
								if ( mm.Date    != null ) row["DeliveryDate"] = T10n.FromUniversalTime(mm.Date.DateTime);
								row["Priority"    ] = mm.Priority.ToString();
								if ( nStartIndex + i < lstMessageSizes.Count )
									row["Size"        ] = lstMessageSizes[nStartIndex + i];
								row["MessageId"   ] = mm.MessageId   ;
								row["Headers"     ] = "<pre>" + Server.HtmlEncode(sRawContent) + "</pre>";
								//row["ContentId"   ] = mm.ContentId   ;
								//row["Body"        ] = mm.Body        ;
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						throw;
					}
				}
			}
			else
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			
			int lTotalCount = dtMain.Rows.Count;
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, dtMain, T10n);
			dictResponse.Add("__total", lTotalCount);
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}
	}
}
