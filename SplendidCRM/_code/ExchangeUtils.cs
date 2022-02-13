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
using System.Text;
using System.Data;
using System.Net.Mail;

namespace SplendidCRM
{
	public class ExchangeUtils
	{
		public static Guid EXCHANGE_ID = new Guid("00000000-0000-0000-0000-00000000000D");

		// 12/13/2017 Paul.  Allow version to be changed. 
		public static bool ValidateExchange(HttpApplicationState Application, string sSERVER_URL, string sUSER_NAME, string sPASSWORD, bool bIGNORE_CERTIFICATE, string sIMPERSONATED_TYPE, string sEXCHANGE_VERSION, StringBuilder sbErrors)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static void SendTestMessage(HttpApplicationState Application, string sSERVER_URL, string sUSER_NAME, string sPASSWORD, string sFromAddress, string sFromName, string sToAddress, string sToName)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static void SendTestMessage(HttpApplicationState Application, Guid gOAUTH_TOKEN_ID, string sFromAddress, string sFromName, string sToAddress, string sToName)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
		/*
		public static int ValidateImpersonation(HttpApplicationState Application, string sEXCHANGE_ALIAS, string sEXCHANGE_EMAIL)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
		*/
		public static bool ValidateExchange(HttpApplicationState Application, string sOAuthClientID, string sOAuthClientSecret, Guid gUSER_ID, string sMAILBOX, StringBuilder sbErrors)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
		/*
		public static ExchangeService CreateExchangeService(HttpApplicationState Application, string sEXCHANGE_ALIAS, string sEXCHANGE_EMAIL, string sMAIL_SMTPUSER, string sMAIL_SMTPPASS, Guid gEXCHANGE_ID)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static ExchangeService CreateExchangeService(ExchangeSync.UserSync User)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		private static void UpdateFolderTreeNodeCounts(ExchangeService service, XmlNode xFolder)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static void UpdateFolderTreeNodeCounts(ExchangeSync.UserSync User, XmlNode xFolder)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		private static void GetFolderTreeFromResults(ExchangeService service, XmlNode xParent, FindFoldersResults fResults)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static XmlDocument GetFolderTree(ExchangeSync.UserSync User, ref string sInboxFolderId)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static void GetFolderCount(ExchangeSync.UserSync User, string sFOLDER_ID, ref int nTotalCount, ref int nUnreadCount)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static void DeleteMessage(ExchangeSync.UserSync User, string sUNIQUE_ID)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static DataTable GetMessage(ExchangeSync.UserSync User, string sUNIQUE_ID)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static DataTable GetMessage(HttpContext Context, ExchangeService service, string sUNIQUE_ID)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
		*/
		public static void GetMessage(HttpContext Context, Guid gMAILBOX_ID, string sUNIQUE_ID, ref string sNAME, ref string sFROM_ADDR, ref bool bIS_READ, ref int nSIZE)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
		/*
		public static void MarkAsRead(HttpContext Context, Guid gMAILBOX_ID, string sUNIQUE_ID)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
		*/
		public static void MarkAsUnread(HttpContext Context, Guid gMAILBOX_ID, string sUNIQUE_ID)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
		/*
		public static DataTable GetPost(ExchangeService service, string sUNIQUE_ID)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		// 11/06/2010 Paul.  Return the Attachments so that we can show embedded images or download the attachments. 
		public static string GetAttachments(Item email)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		// 11/23/2011 Paul.  Add MAIL_SMTPUSER and MAIL_SMTPPASS so that we can avoid impersonation. 
		public static byte[] GetAttachmentData(ExchangeSync.UserSync User, string sUNIQUE_ID, string sATTACHMENT_ID, ref string sFILENAME, ref string sCONTENT_TYPE, ref bool bINLINE)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
		*/
		// 11/23/2011 Paul.  Add MAIL_SMTPUSER and MAIL_SMTPPASS so that we can avoid impersonation. 
		public static DataTable GetFolderMessages(ExchangeSync.UserSync User, string sFOLDER_ID, int nPageSize, int nPageOffset, string sSortColumn, string sSortOrder)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static string GetFolderId(HttpContext Context, string sUSERNAME, string sPASSWORD, Guid gMAILBOX_ID, string sMAILBOX)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static DataTable GetFolderMessages(HttpContext Context, string sUSERNAME, string sPASSWORD, Guid gMAILBOX_ID, string sMAILBOX, bool bONLY_SINCE, string sEXCHANGE_WATERMARK)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
		/*
		public static Guid ImportMessage(HttpContext Context, HttpSessionState Session, ExchangeService service, IDbConnection con, string sPARENT_TYPE, Guid gPARENT_ID, string sEXCHANGE_ALIAS, Guid gUSER_ID, Guid gASSIGNED_USER_ID, Guid gTEAM_ID, string sTEAM_SET_LIST, string sREMOTE_KEY)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		// 07/31/2010 Paul.  Add support for IPM.Post import. 
		public static Guid ImportPost(HttpContext Context, HttpSessionState Session, ExchangeService service, IDbConnection con, string sPARENT_TYPE, Guid gPARENT_ID, string sEXCHANGE_ALIAS, Guid gUSER_ID, Guid gASSIGNED_USER_ID, Guid gTEAM_ID, string sTEAM_SET_LIST, string sREMOTE_KEY)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static Guid ImportMessage(ExchangeSync.UserSync User, HttpSessionState Session, string sPARENT_TYPE, Guid gPARENT_ID, Guid gASSIGNED_USER_ID, Guid gTEAM_ID, string sTEAM_SET_LIST, string sREMOTE_KEY)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static string NormalizeInternetAddressName(EmailAddress addr)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static void BuildAddressList(EmailAddress addr, StringBuilder sbTO_ADDRS, StringBuilder sbTO_ADDRS_NAMES, StringBuilder sbTO_ADDRS_EMAILS)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static Guid FindTargetTrackerKey(EmailMessage email, string sHtmlBody, string sTextBody)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}

		public static string EmbedInlineImages(EmailMessage email, string sDESCRIPTION_HTML)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
		*/
		public static Guid ImportInboundEmail(HttpContext Context, IDbConnection con, Guid gMAILBOX_ID, string sINTENT, Guid gGROUP_ID, Guid gGROUP_TEAM_ID, string sUNIQUE_ID, string sUNIQUE_MESSAGE_ID)
		{
			throw(new Exception("Exchange Server integration is not supported."));
		}
	}
}
