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
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Net;
using System.Net.Security;
using System.Web;
using System.Web.SessionState;
using System.Xml;
using System.Diagnostics;

namespace Spring.Social.Office365
{
	public class Office365Sync
	{
		public const string scope = "openid offline_access Mail.ReadWrite Mail.Send Contacts.ReadWrite Calendars.ReadWrite MailboxSettings.ReadWrite User.Read";

		public class UserSync
		{
			public UserSync(HttpContext Context, string sEXCHANGE_ALIAS, string sEXCHANGE_EMAIL, string sMAIL_SMTPUSER, string sMAIL_SMTPPASS, Guid gUSER_ID, bool bSyncAll, bool bOFFICE365_OAUTH_ENABLED)
			{
			}

			public void Start()
			{
			}

			public static UserSync Create(HttpContext Context, Guid gUSER_ID, bool bSyncAll)
			{
				Office365Sync.UserSync User = null;
				return User;
			}
		}
	}
}

namespace Spring.Social.Office365.Api
{
	public class Recipient
	{
	}
	public class Message
	{
	}
}

namespace SplendidCRM
{
	public class Office365Utils
	{
		// 12/13/2020 Paul.  Move Office365 methods to Office365utils. 
		public static void SendTestMessage(HttpApplicationState Application, Guid gUSER_ID, string sFromAddress, string sFromName, string sToAddress, string sToName)
		{
			throw(new Exception("Office365 integration is not supported."));
		}

		public static bool ValidateExchange(HttpApplicationState Application, string sOAuthClientID, string sOAuthClientSecret, Guid gUSER_ID, string sMAILBOX, StringBuilder sbErrors)
		{
			throw(new Exception("Office365 integration is not supported."));
		}

		public static void GetMessage(HttpContext Context, Guid gMAILBOX_ID, string sUNIQUE_ID, ref string sNAME, ref string sFROM_ADDR, ref bool bIS_READ, ref int nSIZE)
		{
			throw(new Exception("Office365 integration is not supported."));
		}

		public static void MarkAsUnread(HttpContext Context, Guid gMAILBOX_ID, string sUNIQUE_ID)
		{
			throw(new Exception("Office365 integration is not supported."));
		}

		public static DataTable GetFolderMessages(Spring.Social.Office365.Office365Sync.UserSync User, string sFOLDER_ID, int nPageSize, int nPageOffset, string sSortColumn, string sSortOrder)
		{
			throw(new Exception("Office365 integration is not supported."));
		}

		public static string GetFolderId(HttpContext Context, string sUSERNAME, string sPASSWORD, Guid gMAILBOX_ID, string sMAILBOX)
		{
			throw(new Exception("Office365 integration is not supported."));
		}

		public static DataTable GetFolderMessages(HttpContext Context, string sUSERNAME, string sPASSWORD, Guid gMAILBOX_ID, string sMAILBOX, bool bONLY_SINCE, string sEXCHANGE_WATERMARK)
		{
			throw(new Exception("Office365 integration is not supported."));
		}

		public static Guid ImportInboundEmail(HttpContext Context, IDbConnection con, Guid gMAILBOX_ID, string sINTENT, Guid gGROUP_ID, Guid gGROUP_TEAM_ID, string sUNIQUE_ID, string sUNIQUE_MESSAGE_ID, string sEXCHANGE_EMAIL)
		{
			throw(new Exception("Office365 integration is not supported."));
		}
	}
}
