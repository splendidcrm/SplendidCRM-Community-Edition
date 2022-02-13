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
using System.Web;
using System.Data;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace SplendidCRM
{
	public class GoogleApps
	{
		public static bool GoogleAppsEnabled(HttpApplicationState Application)
		{
			return false;
		}

		public static Google.Apis.Auth.OAuth2.Responses.TokenResponse RefreshAccessToken(HttpApplicationState Application, Guid gUSER_ID, bool bForceRefresh)
		{
			throw(new Exception("GoogleApps integration is not supported."));
		}

		public static bool TestAccessToken(HttpApplicationState Application, Guid gUSER_ID, StringBuilder sbErrors)
		{
			throw(new Exception("GoogleApps integration is not supported."));
		}

		public static string GetEmailAddress(HttpApplicationState Application, Guid gUSER_ID, StringBuilder sbErrors)
		{
			throw(new Exception("GoogleApps integration is not supported."));
		}

		public static bool TestMailbox(HttpApplicationState Application, Guid gUSER_ID, string sMAILBOX, StringBuilder sbErrors)
		{
			throw(new Exception("GoogleApps integration is not supported."));
		}

		public static void SendTestMessage(HttpApplicationState Application, Guid gOAUTH_TOKEN_ID, string sFromAddress, string sFromName, string sToAddress, string sToName)
		{
			throw(new Exception("GoogleApps integration is not supported."));
		}

		public static MimeKit.MimeMessage GetMimeMessage(HttpContext Context, Guid gUSER_ID, string sUNIQUE_ID)
		{
			throw(new Exception("GoogleApps integration is not supported."));
		}

		public static void MarkAsRead(HttpContext Context, Guid gUSER_ID, string sUNIQUE_ID)
		{
			throw(new Exception("GoogleApps integration is not supported."));
		}

		public static void MarkAsUnread(HttpContext Context, Guid gUSER_ID, string sUNIQUE_ID)
		{
			throw(new Exception("GoogleApps integration is not supported."));
		}

		public static DataTable GetFolderMessages(HttpContext Context, Guid gUSER_ID, string sFOLDER_ID, bool bONLY_SINCE, long nLAST_EMAIL_UID, int nMaxRecords)
		{
			throw(new Exception("GoogleApps integration is not supported."));
		}
	}
}

namespace Google.Apis.Auth.OAuth2
{
	public class ClientSecrets
	{
		public string ClientId                 { get; set; }
		public string ClientSecret             { get; set; }
	}
}

	namespace Google.Apis.Auth.OAuth2.Responses
{
	public class TokenResponse
	{
		public string AccessToken              { get; set; }
		public string TokenType                { get; set; }
		public string RefreshToken             { get; set; }
		public long?  ExpiresInSeconds         { get; set; }
	}
}

namespace Google.Apis.Contacts.v3.Data
{
	public class StructuredPostalAddress
	{
		public string         Rel              { get; set; }
		public Nullable<bool> Primary          { get; set; }
		public string         Agent            { get; set; }
		public string         HouseName        { get; set; }
		public string         Street           { get; set; }
		public string         POBox            { get; set; }
		public string         Neighborhood     { get; set; }
		public string         City             { get; set; }
		public string         County           { get; set; }
		public string         State            { get; set; }
		public string         PostalCode       { get; set; }
		public string         Country          { get; set; }
		public string         FormattedAddress { get; set; }
	}
}

namespace Google.Apis.Auth.OAuth2.Flows
{
	public class AuthorizationCodeFlow
	{
		public class Initializer
		{
			public ClientSecrets ClientSecrets { get; set; }
			public IEnumerable<string> Scopes  { get; set; }
		}
	}

	public class GoogleAuthorizationCodeFlow
	{
		public GoogleAuthorizationCodeFlow(GoogleAuthorizationCodeFlow.Initializer initializer)
		{
		}

		public Task<Responses.TokenResponse> ExchangeCodeForTokenAsync(string userId, string code, string redirectUri, CancellationToken taskCancellationToken)
		{
			throw(new Exception("GoogleApps integration is not supported."));
		}

		public class Initializer : AuthorizationCodeFlow.Initializer
		{
			public Initializer()
			{
			}
		}
	}
}

