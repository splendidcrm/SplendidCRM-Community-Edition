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
using System.Web;
using System.Web.SessionState;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;
using System.Data;
using System.Data.Common;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for Security.
	/// </summary>
	public class Security
	{
		public static Guid USER_ID
		{
			get
			{
				// 02/17/2006 Paul.  Throw an exception if Session is null.  This is more descriptive error than "object is null". 
				// We will most likely see this in a SOAP call. 
				// 01/13/2008 Paul.  Return an empty guid if the session does not exist. 
				// This will allow us to reuse lots of SqlProcs code in the scheduler. 
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					return Guid.Empty;
				return  Sql.ToGuid(HttpContext.Current.Session["USER_ID"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["USER_ID"] = value;
			}
		}
		
		// 07/15/2021 Paul.  React Client needs to access the ASP.NET_SessionId. 
		public static string USER_SESSION
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					return String.Empty;
				return Security.HashPassword(Sql.ToString(HttpContext.Current.Session["USER_ID"]) + ";" + HttpContext.Current.Session.SessionID);
			}
		}
		
		// 03/02/2008 Paul.  Keep track of the login ID so that we can log them out. 
		public static Guid USER_LOGIN_ID
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					return Guid.Empty;
				return  Sql.ToGuid(HttpContext.Current.Session["USER_LOGIN_ID"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["USER_LOGIN_ID"] = value;
			}
		}
		
		public static string USER_NAME
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToString(HttpContext.Current.Session["USER_NAME"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["USER_NAME"] = value;
			}
		}
		
		public static string FULL_NAME
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToString(HttpContext.Current.Session["FULL_NAME"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["FULL_NAME"] = value;
			}
		}
		
		// 11/21/2014 Paul.  Add User Picture. 
		public static string PICTURE
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToString(HttpContext.Current.Session["PICTURE"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["PICTURE"] = value;
			}
		}
		
		public static bool IS_ADMIN
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return Sql.ToBoolean(HttpContext.Current.Session["IS_ADMIN"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["IS_ADMIN"] = value;
			}
		}
		
		public static bool IS_ADMIN_DELEGATE
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return Sql.ToBoolean(HttpContext.Current.Session["IS_ADMIN_DELEGATE"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["IS_ADMIN_DELEGATE"] = value;
			}
		}
		
		public static bool PORTAL_ONLY
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return Sql.ToBoolean(HttpContext.Current.Session["PORTAL_ONLY"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["PORTAL_ONLY"] = value;
			}
		}
		
		// 11/25/2006 Paul.  Default TEAM_ID. 
		public static Guid TEAM_ID
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToGuid(HttpContext.Current.Session["TEAM_ID"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["TEAM_ID"] = value;
			}
		}
		
		public static string TEAM_NAME
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToString(HttpContext.Current.Session["TEAM_NAME"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["TEAM_NAME"] = value;
			}
		}
		
		// 04/04/2010 Paul.  Add Exchange Alias so that we can enable/disable Exchange appropriately. 
		public static string EXCHANGE_ALIAS
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToString(HttpContext.Current.Session["EXCHANGE_ALIAS"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["EXCHANGE_ALIAS"] = value;
			}
		}

		// 04/07/2010 Paul.  Add Exchange Email as it will be need for Push Subscriptions. 
		public static string EXCHANGE_EMAIL
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToString(HttpContext.Current.Session["EXCHANGE_EMAIL"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["EXCHANGE_EMAIL"] = value;
			}
		}

		// 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
		public static string MAIL_SMTPUSER
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToString(HttpContext.Current.Session["MAIL_SMTPUSER"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["MAIL_SMTPUSER"] = value;
			}
		}

		// 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
		public static string MAIL_SMTPPASS
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToString(HttpContext.Current.Session["MAIL_SMTPPASS"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["MAIL_SMTPPASS"] = value;
			}
		}

		// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
		// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
		public static string EMAIL1
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToString(HttpContext.Current.Session["EMAIL1"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["EMAIL1"] = value;
			}
		}

		// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
		public static Guid PRIMARY_ROLE_ID
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToGuid(HttpContext.Current.Session["PRIMARY_ROLE_ID"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["PRIMARY_ROLE_ID"] = value;
			}
		}

		public static string PRIMARY_ROLE_NAME
		{
			get
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				return  Sql.ToString(HttpContext.Current.Session["PRIMARY_ROLE_NAME"]);
			}
			set
			{
				if ( HttpContext.Current == null || HttpContext.Current.Session == null )
					throw(new Exception("HttpContext.Current.Session is null"));
				HttpContext.Current.Session["PRIMARY_ROLE_NAME"] = value;
			}
		}
		
		public static bool HasExchangeAlias()
		{
			return !Sql.IsEmptyString(Security.EXCHANGE_ALIAS);
		}
		
		public static bool IsWindowsAuthentication()
		{
			// 11/06/2009 Paul.  Windows Authentication will not be supported with the Offline Client. 
			if ( Utils.IsOfflineClient )
				return false;
			// 11/19/2005 Paul.  AUTH_USER is the clear indication that NTLM is enabled. 
			string sAUTH_USER = Sql.ToString(HttpContext.Current.Request.ServerVariables["AUTH_USER"]);
			// 02/28/2007 Paul.  In order to enable WebParts, we need to set HttpContext.Current.User.Identity. 
			// Doing so will change AUTH_USER, so exclude if AUTH_USER == USER_NAME. 
			// When Windows Authentication is used, AUTH_USER will include the windows domain. 
			return !Sql.IsEmptyString(sAUTH_USER) && sAUTH_USER != USER_NAME;
		}

		public static bool IsAuthenticated()
		{
			return !Sql.IsEmptyGuid(Security.USER_ID);
		}

		public static bool IsImpersonating()
		{
			return Sql.ToBoolean(HttpContext.Current.Session["USER_IMPERSONATION"]);
		}

		// 02/28/2007 Paul.  Centralize session reset to prepare for WebParts. 
		public static void Clear()
		{
			// 01/26/2011 Paul.  .NET 4 has broken the compatibility of the browser file system. 
			// We need to make sure to retain the mobile settings. 
			HttpSessionState Session = HttpContext.Current.Session;
			string sBrowser             = Sql.ToString (Session["Browser"            ]);
			bool   bIsMobileDevice      = Sql.ToBoolean(Session["IsMobileDevice"     ]);
			bool   bSupportsPopups      = Sql.ToBoolean(Session["SupportsPopups"     ]);
			bool   bAllowAutoComplete   = Sql.ToBoolean(Session["AllowAutoComplete"  ]);
			// 08/22/2012 Paul.  Apple and Android devices should support speech and handwriting. 
			bool   bSupportsSpeech      = Sql.ToBoolean(Session["SupportsSpeech"     ]);
			bool   bSupportsHandwriting = Sql.ToBoolean(Session["SupportsHandwriting"]);
			// 11/14/2012 Paul.  Microsoft Surface has Touch in the agent string. 
			bool   bSupportsTouch       = Sql.ToBoolean(Session["SupportsTouch"      ]);
			// 05/17/2013 Paul.  We need to be able to detect draggable. 
			bool   bSupportsDraggable   = Sql.ToBoolean(Session["SupportsDraggable"  ]);
			HttpContext.Current.Session.Clear();
			Session["Browser"            ] = sBrowser            ;
			Session["IsMobileDevice"     ] = bIsMobileDevice     ;
			Session["SupportsPopups"     ] = bSupportsPopups     ;
			Session["AllowAutoComplete"  ] = bAllowAutoComplete  ;
			Session["SupportsSpeech"     ] = bSupportsSpeech     ;
			Session["SupportsHandwriting"] = bSupportsHandwriting;
			Session["SupportsTouch"      ] = bSupportsTouch      ;
			Session["SupportsDraggable"  ] = bSupportsDraggable  ;
		}

		// 11/18/2005 Paul.  SugarCRM stores an MD5 hash of the password. 
		// 11/18/2005 Paul.  SugarCRM also stores the password using the PHP Crypt() function, which is DES. 
		// Don't bother trying to duplicate the PHP Crypt() function because the result is not used in SugarCRM.  
		// The PHP function is located in D:\php-5.0.5\win32\crypt_win32.c
		public static string HashPassword(string sPASSWORD)
		{
			UTF8Encoding utf8 = new UTF8Encoding();
			byte[] aby = utf8.GetBytes(sPASSWORD);
			
			// 02/07/2010 Paul.  Defensive programming, the hash as a dispose interface, so lets use it. 
			using ( MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider() )
			{
				byte[] binMD5 = md5.ComputeHash(aby);
				return Sql.HexEncode(binMD5);
			}
		}

		// 01/08/2008 Paul.  Use the same encryption used in the SplendidCRM Plug-in for Outlook, except we will base64 encode. 
		// 01/09/2008 Paul.  Increase quality of encryption by using an robust IV.
		// 01/09/2008 Paul.  Use Rijndael instead of TripleDES because it allows 128 block and key sizes, so Guids can be used for both. 
		public static string EncryptPassword(string sPASSWORD, Guid gKEY, Guid gIV)
		{
			UTF8Encoding utf8 = new UTF8Encoding(false);

			string sResult = null;
			byte[] byPassword = utf8.GetBytes(sPASSWORD);
			using ( MemoryStream stm = new MemoryStream() )
			{
				Rijndael rij = Rijndael.Create();
				rij.Key = gKEY.ToByteArray();
				rij.IV  = gIV.ToByteArray();
				using ( CryptoStream cs = new CryptoStream(stm, rij.CreateEncryptor(), CryptoStreamMode.Write) )
				{
					cs.Write(byPassword, 0, byPassword.Length);
					cs.FlushFinalBlock();
					cs.Close();
				}
				sResult = Convert.ToBase64String(stm.ToArray());
			}
			return sResult;
		}

		// 02/06/2017 Paul.  Simplify decryption call. 
		public static string DecryptPassword(HttpApplicationState Application, string sPASSWORD)
		{
			Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
			Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
			return DecryptPassword(sPASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
		}

		public static string DecryptPassword(string sPASSWORD, Guid gKEY, Guid gIV)
		{
			UTF8Encoding utf8 = new UTF8Encoding(false);

			string sResult = null;
			// 08/12/2015 Paul.  We need a better error, other than "Padding is invalid and cannot be removed.". 
			if ( Sql.IsEmptyString(sPASSWORD) )
				throw(new Exception("Password is empty."));
			byte[] byPassword = Convert.FromBase64String(sPASSWORD);
			using ( MemoryStream stm = new MemoryStream() )
			{
				Rijndael rij = Rijndael.Create();
				rij.Key = gKEY.ToByteArray();
				rij.IV  = gIV.ToByteArray();
				using ( CryptoStream cs = new CryptoStream(stm, rij.CreateDecryptor(), CryptoStreamMode.Write) )
				{
					cs.Write(byPassword, 0, byPassword.Length);
					cs.Flush();
					cs.Close();
				}
				byte[] byResult = stm.ToArray();
				sResult = utf8.GetString(byResult, 0, byResult.Length);
			}
			return sResult;
		}

		// 02/03/2009 Paul.  This function might be called from a background process. 
		public static void SetModuleAccess(HttpApplicationState Application, string sMODULE_NAME, string sACCESS_TYPE, int nACLACCESS)
		{
			if ( Application == null )
				throw(new Exception("HttpContext.Current.Application is null"));
			// 06/04/2006 Paul.  Verify that sMODULE_NAME is not empty.  
			if ( Sql.IsEmptyString(sMODULE_NAME) )
				throw(new Exception("sMODULE_NAME should not be empty."));
			Application["ACLACCESS_" + sMODULE_NAME + "_" + sACCESS_TYPE] = nACLACCESS;
		}

		public static void SetUserAccess(string sMODULE_NAME, string sACCESS_TYPE, int nACLACCESS)
		{
			if ( HttpContext.Current == null || HttpContext.Current.Session == null )
				throw(new Exception("HttpContext.Current.Session is null"));
			// 06/04/2006 Paul.  Verify that sMODULE_NAME is not empty.  
			if ( Sql.IsEmptyString(sMODULE_NAME) )
				throw(new Exception("sMODULE_NAME should not be empty."));
			HttpContext.Current.Session["ACLACCESS_" + sMODULE_NAME + "_" + sACCESS_TYPE] = nACLACCESS;
		}

		public static int GetUserAccess(string sMODULE_NAME, string sACCESS_TYPE)
		{
			if ( HttpContext.Current == null || HttpContext.Current.Session == null )
				throw(new Exception("HttpContext.Current.Session is null"));
			// 06/04/2006 Paul.  Verify that sMODULE_NAME is not empty.  
			if ( Sql.IsEmptyString(sMODULE_NAME) )
				throw(new Exception("sMODULE_NAME should not be empty."));
			// 08/30/2009 Paul.  Don't apply admin rules when debugging so that we can test the code. 
			// 09/01/2009 Paul.  Can't skip admin rules here, otherwise too many dynamic things in the admin area will fail. 
			// 04/27/2006 Paul.  Admins have full access to the site, no matter what the role. 
			bool bIsAdmin = IS_ADMIN;
			// 12/03/2017 Paul.  Don't apply admin rules when debugging so that we can test the code. 
#if DEBUG
			bIsAdmin = false;
#endif
			if ( bIsAdmin )
			{
				// 04/21/2016 Paul.  We need to make sure that disabled modules do not show related buttons. 
				if ( Sql.ToBoolean(HttpContext.Current.Application["Modules." + sMODULE_NAME + ".Valid"]) )
					return ACL_ACCESS.FULL_ACCESS;
				else
					return ACL_ACCESS.NONE;  // 08/10/2017 Paul.  We need to return a negative number to prevent access, not zero. 
			}

			// 12/05/2006 Paul.  We need to combine Activity and Calendar related modules into a single access value. 
			int nACLACCESS = 0;
			// 08/10/2017 Paul.  We need to return a negative number to prevent access, not zero. 
			if ( !Sql.ToBoolean(HttpContext.Current.Application["Modules." + sMODULE_NAME + ".Valid"]) )
			{
				nACLACCESS = ACL_ACCESS.NONE;
			}
			else if ( sMODULE_NAME == "Calendar" )
			{
				// 12/05/2006 Paul.  The Calendar related views only combine Calls and Meetings. 
				int nACLACCESS_Calls    = GetUserAccess("Calls"   , sACCESS_TYPE);
				int nACLACCESS_Meetings = GetUserAccess("Meetings", sACCESS_TYPE);
				// 12/05/2006 Paul. Use the max value so that the Activities will be displayed if either are accessible. 
				nACLACCESS = Math.Max(nACLACCESS_Calls, nACLACCESS_Meetings);
			}
			else if ( sMODULE_NAME == "Activities" )
			{
				// 12/05/2006 Paul.  The Activities combines Calls, Meetings, Tasks, Notes and Emails. 
				int nACLACCESS_Calls    = GetUserAccess("Calls"   , sACCESS_TYPE);
				int nACLACCESS_Meetings = GetUserAccess("Meetings", sACCESS_TYPE);
				int nACLACCESS_Tasks    = GetUserAccess("Tasks"   , sACCESS_TYPE);
				int nACLACCESS_Notes    = GetUserAccess("Notes"   , sACCESS_TYPE);
				int nACLACCESS_Emails   = GetUserAccess("Emails"  , sACCESS_TYPE);
				nACLACCESS = nACLACCESS_Calls;
				nACLACCESS = Math.Max(nACLACCESS, nACLACCESS_Meetings);
				nACLACCESS = Math.Max(nACLACCESS, nACLACCESS_Tasks   );
				nACLACCESS = Math.Max(nACLACCESS, nACLACCESS_Notes   );
				nACLACCESS = Math.Max(nACLACCESS, nACLACCESS_Emails  );
			}
			else
			{
				string sAclKey = "ACLACCESS_" + sMODULE_NAME + "_" + sACCESS_TYPE;
				// 04/27/2006 Paul.  If no specific level is provided, then look to the Module level. 
				if ( HttpContext.Current.Session[sAclKey] == null )
					nACLACCESS = Sql.ToInteger(HttpContext.Current.Application[sAclKey]);
				else
					nACLACCESS = Sql.ToInteger(HttpContext.Current.Session[sAclKey]);
				if ( sACCESS_TYPE != "access" && nACLACCESS >= 0 )
				{
					// 04/27/2006 Paul.  The access type can over-ride any other type. 
					// A simple trick is to take the minimum of the two values.  
					// If either value is denied, then the result will be negative. 
					sAclKey = "ACLACCESS_" + sMODULE_NAME + "_access";
					int nAccessLevel = 0;
					if ( HttpContext.Current.Session[sAclKey] == null )
						nAccessLevel = Sql.ToInteger(HttpContext.Current.Application[sAclKey]);
					else
						nAccessLevel = Sql.ToInteger(HttpContext.Current.Session[sAclKey]);
					if ( nAccessLevel < 0 )
						nACLACCESS = nAccessLevel;
				}
			}
			return nACLACCESS;
		}
		
		// 11/11/2010 Paul.  Provide quick access to ACL Roles and Teams. 
		public static void SetACLRoleAccess(string sROLE_NAME)
		{
			HttpContext.Current.Session["ACLRoles." + sROLE_NAME] = true;
		}

		public static bool GetACLRoleAccess(string sROLE_NAME)
		{
			return Sql.ToBoolean(HttpContext.Current.Session["ACLRoles." + sROLE_NAME]);
		}

		public static void SetTeamAccess(string sTEAM_NAME)
		{
			HttpContext.Current.Session["Teams." + sTEAM_NAME] = true;
		}

		public static bool GetTeamAccess(string sTEAM_NAME)
		{
			return Sql.ToBoolean(HttpContext.Current.Session["Teams." + sTEAM_NAME]);
		}

		// 06/05/2007 Paul.  We need an easy way to determine when to allow editing or deleting in sub-panels. 
		// If the record is not assigned to any specific user, then it is accessible by everyone. 
		// 08/13/2019 Paul.  GetUserAccess was replaced by GetRecordAccess and is now no longer used. 
		/*
		public static int GetUserAccess(string sMODULE_NAME, string sACCESS_TYPE, Guid gASSIGNED_USER_ID)
		{
			int nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
			if ( nACLACCESS == ACL_ACCESS.OWNER && Security.USER_ID != gASSIGNED_USER_ID && gASSIGNED_USER_ID != Guid.Empty)
			{
				nACLACCESS = ACL_ACCESS.NONE;
			}
			return nACLACCESS;
		}
		*/

		// 10/31/2017 Paul.  Provide a way to inject Record level ACL.  Defer Assigned User Field lookup until needed. 
		// 11/01/2017 Paul.  Must define container as object, otherwise there is a method match error.  It must also be created prior to the DataRow version because of hte dynamic binding. 
		public static int GetRecordAccess(object Container, string sMODULE_NAME, string sACCESS_TYPE, string sASSIGNED_USER_ID_FIELD)
		{
			DataRow row = null;
			if ( Container is DataGridItem)
			{
				DataGridItem dgContainer = Container as DataGridItem;
				if ( dgContainer.DataItem is DataRow )
				{
					row = dgContainer.DataItem as DataRow;
				}
				else if ( dgContainer.DataItem is DataRowView )
				{
					row = (dgContainer.DataItem as DataRowView).Row;
				}
			}
			return GetRecordAccess(row, sMODULE_NAME, sACCESS_TYPE, sASSIGNED_USER_ID_FIELD);
		}

		public static int GetRecordAccess(object Container, string sMODULE_NAME, string sACCESS_TYPE)
		{
			return GetRecordAccess(Container, sMODULE_NAME, sACCESS_TYPE, String.Empty);
		}

		public static int GetRecordAccess(DataRow row, string sMODULE_NAME, string sACCESS_TYPE, string sASSIGNED_USER_ID_FIELD)
		{
			// 11/03/2017 Paul.  Remove is the same as edit.  We don't want to define another select field. 
			if ( sACCESS_TYPE == "remove" )
				sACCESS_TYPE = "edit";
			int nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
			if ( row != null )
			{
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				bool bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
				if ( nACLACCESS == ACL_ACCESS.OWNER )
				{
					// 10/31/2017 Paul.  Don't check if sASSIGNED_USER_ID_FIELD exists in table because this is a coding error that we want to catch. 
					if ( !Sql.IsEmptyString(sASSIGNED_USER_ID_FIELD) )
					{
						// 01/24/2018 Paul.  sASSIGNED_USER_ID_FIELD is either ASSIGNED_USER_ID or CREATED_BY_ID. 
						string sASSIGNED_SET_LIST_FIELD = "ASSIGNED_SET_LIST";
						if ( bEnableDynamicAssignment && (sASSIGNED_USER_ID_FIELD == "ASSIGNED_USER_ID") && row.Table.Columns.Contains(sASSIGNED_SET_LIST_FIELD) )
						{
							string sASSIGNED_SET_LIST = Sql.ToString(row[sASSIGNED_SET_LIST_FIELD]).ToUpper();
							if ( !sASSIGNED_SET_LIST.Contains(Security.USER_ID.ToString().ToUpper()) && !Sql.IsEmptyString(sASSIGNED_SET_LIST) )
								nACLACCESS = ACL_ACCESS.NONE;
						}
						else
						{
							Guid gASSIGNED_USER_ID = Sql.ToGuid(row[sASSIGNED_USER_ID_FIELD]);
							if ( Security.USER_ID != gASSIGNED_USER_ID && gASSIGNED_USER_ID != Guid.Empty )
								nACLACCESS = ACL_ACCESS.NONE;
						}
					}
				}
				// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
				if ( Sql.ToBoolean(HttpContext.Current.Application["Modules." + sMODULE_NAME + ".RecordLevelSecurity"]) )
				{
					// 10/31/2017 Paul.  FULL_ACCESS means that this is an Admin and Record ACL does not apply. 
					if ( nACLACCESS >= 0 && nACLACCESS < ACL_ACCESS.FULL_ACCESS )
					{
						string sRECORD_ACL_FIELD_NAME = "RECORD_LEVEL_SECURITY_" + sACCESS_TYPE.ToUpper();
						// 10/31/2017 Paul.  Check if field exists because it is dynamically injected. 
						if ( row.Table.Columns.Contains(sRECORD_ACL_FIELD_NAME) )
						{
							// 10/31/2017 Paul.  Record ACL only applies if it takes away rights. 
							int nRECORD_ACLACCESS = Sql.ToInteger(row[sRECORD_ACL_FIELD_NAME]);
							if ( nRECORD_ACLACCESS < nACLACCESS )
								nACLACCESS = nRECORD_ACLACCESS;
						}
					}
				}
			}
			return nACLACCESS;
		}

		public static int GetRecordAccess(DataRow row, string sMODULE_NAME, string sACCESS_TYPE)
		{
			return GetRecordAccess(row, sMODULE_NAME, sACCESS_TYPE, String.Empty);
		}

		// 03/15/2010 Paul.  New AdminUserAccess functions include Admin Delegation. 
		public static int AdminUserAccess(string sMODULE_NAME, string sACCESS_TYPE)
		{
			if ( SplendidCRM.Security.IS_ADMIN )
				return ACL_ACCESS.ALL;
			int nACLACCESS = ACL_ACCESS.NONE;
			bool bAllowAdminRoles = Sql.ToBoolean(HttpContext.Current.Application["CONFIG.allow_admin_roles"]);
			if ( bAllowAdminRoles )
			{
				if ( SplendidCRM.Security.IS_ADMIN_DELEGATE )
				{
					nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
				}
			}
			return nACLACCESS;
		}
		
		public static int AdminUserAccess(string sMODULE_NAME, string sACCESS_TYPE, Guid gASSIGNED_USER_ID)
		{
			int nACLACCESS = Security.AdminUserAccess(sMODULE_NAME, sACCESS_TYPE);
			if ( nACLACCESS == ACL_ACCESS.OWNER && Security.USER_ID != gASSIGNED_USER_ID && gASSIGNED_USER_ID != Guid.Empty)
			{
				nACLACCESS = ACL_ACCESS.NONE;
			}
			return nACLACCESS;
		}

		// 01/17/2010 Paul.  Create the class in Security as ACLFieldGrid.cs is not distributed will all editions. 
		public class ACL_FIELD_ACCESS
		{
			public const int FULL_ACCESS            = 100;
			public const int READ_WRITE             =  99;
			public const int READ_OWNER_WRITE       =  60;
			public const int READ_ONLY              =  50;
			public const int OWNER_READ_OWNER_WRITE =  40;
			public const int OWNER_READ_ONLY        =  30;
			public const int NOT_SET                =   0;
			public const int NONE                   = -99;

			protected int  nACLACCESS;
			protected bool bIsNew    ;
			protected bool bIsOwner  ;

			public int ACLACCESS
			{
				get { return nACLACCESS; }
			}
			public bool IsNew
			{
				get { return bIsNew; }
			}
			public bool IsOwner
			{
				get { return bIsOwner; }
			}

			public bool IsReadable()
			{
				if ( nACLACCESS == ACL_FIELD_ACCESS.FULL_ACCESS )
					return true;
				else if ( nACLACCESS < ACL_FIELD_ACCESS.NOT_SET )
					return false;
				if (  bIsNew
				   || bIsOwner
				   || nACLACCESS > ACL_FIELD_ACCESS.OWNER_READ_ONLY
				   )
					return true;
				return false;
			}

			public bool IsWriteable()
			{
				if ( nACLACCESS == ACL_FIELD_ACCESS.FULL_ACCESS )
					return true;
				else if ( nACLACCESS < ACL_FIELD_ACCESS.NOT_SET )
					return false;
				// 01/22/2010 Paul.  Just be cause the record is new, does not mean that the user can specify it. 
				if (  (bIsOwner && nACLACCESS == ACL_FIELD_ACCESS.OWNER_READ_OWNER_WRITE)
				   || (bIsOwner && nACLACCESS == ACL_FIELD_ACCESS.READ_OWNER_WRITE      )
				   || (            nACLACCESS >  ACL_FIELD_ACCESS.READ_OWNER_WRITE      )
				   )
					return true;
				return false;
			}

			public ACL_FIELD_ACCESS(int nACLACCESS, Guid gOWNER_ID)
			{
				this.nACLACCESS = nACLACCESS;
				this.bIsNew     = (gOWNER_ID == Guid.Empty);
				this.bIsOwner   = (Security.USER_ID == gOWNER_ID) || bIsNew;
			}
		}
		
		// 01/17/2010 Paul.  Field Security values are stored in the Session cache. 
		public static void SetUserFieldSecurity(string sMODULE_NAME, string sFIELD_NAME, int nACLACCESS)
		{
			if ( HttpContext.Current == null || HttpContext.Current.Session == null )
				throw(new Exception("HttpContext.Current.Session is null"));
			// 06/04/2006 Paul.  Verify that sMODULE_NAME is not empty.  
			if ( Sql.IsEmptyString(sMODULE_NAME) )
				throw(new Exception("SetUserFieldSecurity: sMODULE_NAME should not be empty."));
			if ( Sql.IsEmptyString(sFIELD_NAME) )
				throw(new Exception("SetUserFieldSecurity: sFIELD_NAME should not be empty."));
			// 01/17/2010 Paul.  Zero is a special value that means NOT_SET.  
			if ( nACLACCESS != 0 )
				HttpContext.Current.Session["ACLFIELD_" + sMODULE_NAME + "_" + sFIELD_NAME] = nACLACCESS;
		}
		
		protected static int GetUserFieldSecurity(string sMODULE_NAME, string sFIELD_NAME)
		{
			if ( HttpContext.Current == null || HttpContext.Current.Session == null )
				throw(new Exception("HttpContext.Current.Session is null"));
			if ( Sql.IsEmptyString(sMODULE_NAME) )
				throw(new Exception("GetUserFieldSecurity: sMODULE_NAME should not be empty."));
#if !DEBUG
			// 01/18/2010 Paul.  Disable Admin access in a debug build so that we can test the logic. 
			if ( IS_ADMIN )
				return ACL_FIELD_ACCESS.FULL_ACCESS;
#endif

			string sAclKey = "ACLFIELD_" + sMODULE_NAME + "_" + sFIELD_NAME;
			int nACLACCESS = Sql.ToInteger(HttpContext.Current.Session[sAclKey]);
			// 01/17/2010 Paul.  Zero is a special value that means NOT_SET, so grant full access. 
			if ( nACLACCESS == 0 )
				return ACL_FIELD_ACCESS.FULL_ACCESS;
			return nACLACCESS;
		}
		
		public static ACL_FIELD_ACCESS GetUserFieldSecurity(string sMODULE_NAME, string sFIELD_NAME, Guid gASSIGNED_USER_ID)
		{
			int nACLACCESS = GetUserFieldSecurity(sMODULE_NAME, sFIELD_NAME);
			ACL_FIELD_ACCESS acl = new ACL_FIELD_ACCESS(nACLACCESS, gASSIGNED_USER_ID);
			return acl;
		}

		// 01/05/2020 Paul.  Provide central location for constant. 
		public const string TeamHierarchyModule = "TeamHierarchy";

		// 02/23/2017 Paul.  Add support for Team Hierarchy. 
		public static void TeamHierarchySavedSearch(ref Guid gTEAM_ID, ref string sTEAM_NAME)
		{
			// 01/05/2020 Paul.  Provide central location for constant. 
			string sSEARCH_MODULE = Security.TeamHierarchyModule;
			DataTable dt = SplendidCache.SavedSearch(sSEARCH_MODULE);
			if ( dt != null && dt.Rows.Count > 0 )
			{
				DataRow row = dt.Rows[0];
				string sXML = Sql.ToString(row["CONTENTS"]);
				System.Xml.XmlDocument xml = new System.Xml.XmlDocument();
				xml.LoadXml(sXML);
				sTEAM_NAME = Sql.ToString(XmlUtil.SelectSingleNode(xml.DocumentElement, "SearchFields/Field[@Name='NAME']"));
				gTEAM_ID   = Sql.ToGuid  (XmlUtil.SelectSingleNode(xml.DocumentElement, "SearchFields/Field[@Name='ID'  ]"));
			}
		}
		
		public static void Filter(IDbCommand cmd, string sMODULE_NAME, string sACCESS_TYPE)
		{
			Filter(cmd, sMODULE_NAME, sACCESS_TYPE, "ASSIGNED_USER_ID");
		}
		
		// 04/24/2018 Paul.  Provide a way to exclude the SavedSearch for areas that are global in nature. 
		public static void Filter(IDbCommand cmd, string sMODULE_NAME, string sACCESS_TYPE, string sASSIGNED_USER_ID_Field)
		{
			Filter(cmd, sMODULE_NAME, sACCESS_TYPE, sASSIGNED_USER_ID_Field, false);
		}

		// 08/30/2009 Paul.  We need to know if this is an activities filter so that we can use the special activities teams view. 
		// 06/02/2016 Paul.  Activities views will use new function that accepts an array of modules. 
		// 04/24/2018 Paul.  Provide a way to exclude the SavedSearch for areas that are global in nature. 
		public static void Filter(IDbCommand cmd, string sMODULE_NAME, string sACCESS_TYPE, string sASSIGNED_USER_ID_Field, bool bExcludeSavedSearch)
		{
			// 08/04/2007 Paul.  Always wait forever for the data.  No sense in showing a timeout.
			cmd.CommandTimeout = 0;
			// 01/22/2007 Paul.  If ASSIGNED_USER_ID is null, then let everybody see it. 
			// This was added to work around a bug whereby the ASSIGNED_USER_ID was not automatically assigned to the creating user. 
			bool bShowUnassigned        = Crm.Config.show_unassigned();
			// 12/07/2006 Paul.  Not all views use ASSIGNED_USER_ID as the assigned field.  Allow an override. 
			// 11/25/2006 Paul.  Administrators should not be restricted from seeing items because of the team rights.
			// This is so that an administrator can fix any record with a bad team value. 
			// 12/30/2007 Paul.  We need a dynamic way to determine if the module record can be assigned or placed in a team. 
			// Teamed and Assigned flags are automatically determined based on the existence of TEAM_ID and ASSIGNED_USER_ID fields. 
			bool bModuleIsTeamed        = Sql.ToBoolean(HttpContext.Current.Application["Modules." + sMODULE_NAME + ".Teamed"  ]);
			bool bModuleIsAssigned      = Sql.ToBoolean(HttpContext.Current.Application["Modules." + sMODULE_NAME + ".Assigned"]);
			bool bEnableTeamManagement  = Crm.Config.enable_team_management();
			bool bRequireTeamManagement = Crm.Config.require_team_management();
			bool bRequireUserAssignment = Crm.Config.require_user_assignment();
			// 08/28/2009 Paul.  Allow dynamic teams to be turned off. 
			bool bEnableDynamicTeams    = Crm.Config.enable_dynamic_teams();
			// 04/28/2016 Paul.  Allow team hierarchy. 
			bool bEnableTeamHierarchy   = Crm.Config.enable_team_hierarchy();
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			bool bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
			bool bIsAdmin = IS_ADMIN;
			// 08/30/2009 Paul.  Don't apply admin rules when debugging so that we can test the code. 
#if DEBUG
			bIsAdmin = false;
#endif
			// 06/26/2018 Paul.  The Data Privacy Manager has admin-like access to Accounts, Contacts, Leads and Prospects. 
			if ( Security.GetACLRoleAccess("Data Privacy Manager Role") )
			{
				if ( sMODULE_NAME == "Accounts" || sMODULE_NAME == "Contacts" || sMODULE_NAME == "Leads" || sMODULE_NAME == "Prospects" )
				{
					bIsAdmin = true;
				}
			}
			if ( bModuleIsTeamed )
			{
				if ( bIsAdmin )
					bRequireTeamManagement = false;

				if ( bEnableTeamManagement )
				{
					// 11/12/2009 Paul.  Use the NextPlaceholder function so that we can call the security filter multiple times. 
					// We need this to support offline sync. 
					string sFieldPlaceholder = Sql.NextPlaceholder(cmd, "MEMBERSHIP_USER_ID");
					if ( bEnableDynamicTeams )
					{
						// 08/31/2009 Paul.  Dynamic Teams are handled just like regular teams except using a different view. 
						if ( bRequireTeamManagement )
							cmd.CommandText += "       inner ";
						else
							cmd.CommandText += "  left outer ";
						// 04/28/2016 Paul.  Allow team hierarchy. 
						if ( !bEnableTeamHierarchy )
						{
							// 11/27/2009 Paul.  Use Sql.MetadataName() so that the view name can exceed 30 characters, but still be truncated for Oracle. 
							// 11/27/2009 Paul.  vwTEAM_SET_MEMBERSHIPS_Security has a distinct clause to reduce duplicate rows. 
							cmd.CommandText += "join " + Sql.MetadataName(cmd, "vwTEAM_SET_MEMBERSHIPS_Security") + " vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
							cmd.CommandText += "               on vwTEAM_SET_MEMBERSHIPS.MEMBERSHIP_TEAM_SET_ID = TEAM_SET_ID" + ControlChars.CrLf;
							cmd.CommandText += "              and vwTEAM_SET_MEMBERSHIPS.MEMBERSHIP_USER_ID     = @" + sFieldPlaceholder + ControlChars.CrLf;
						}
						else
						{
							if ( Sql.IsOracle(cmd) )
							{
								cmd.CommandText += "join table(" + Sql.MetadataName(cmd, "fnTEAM_SET_HIERARCHY_MEMBERSHIPS") + "(@" + sFieldPlaceholder + ")) vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_SET_MEMBERSHIPS.MEMBERSHIP_TEAM_SET_ID = TEAM_SET_ID" + ControlChars.CrLf;
							}
							else
							{
								string fnPrefix = (Sql.IsSQLServer(cmd) ? "dbo." : String.Empty);
								cmd.CommandText += "join " + fnPrefix + Sql.MetadataName(cmd, "fnTEAM_SET_HIERARCHY_MEMBERSHIPS") + "(@" + sFieldPlaceholder + ") vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_SET_MEMBERSHIPS.MEMBERSHIP_TEAM_SET_ID = TEAM_SET_ID" + ControlChars.CrLf;
							}
						}
					}
					else
					{
						if ( bRequireTeamManagement )
							cmd.CommandText += "       inner ";
						else
							cmd.CommandText += "  left outer ";
						// 04/28/2016 Paul.  Allow team hierarchy. 
						if ( !bEnableTeamHierarchy )
						{
							cmd.CommandText += "join vwTEAM_MEMBERSHIPS" + ControlChars.CrLf;
							cmd.CommandText += "               on vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID = TEAM_ID" + ControlChars.CrLf;
							cmd.CommandText += "              and vwTEAM_MEMBERSHIPS.MEMBERSHIP_USER_ID = @" + sFieldPlaceholder + ControlChars.CrLf;
						}
						else
						{
							if ( Sql.IsOracle(cmd) )
							{
								cmd.CommandText += "join table(fnTEAM_HIERARCHY_MEMBERSHIPS(@" + sFieldPlaceholder + ")) vwTEAM_MEMBERSHIPS" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID = TEAM_ID" + ControlChars.CrLf;
							}
							else
							{
								string fnPrefix = (Sql.IsSQLServer(cmd) ? "dbo." : String.Empty);
								cmd.CommandText += "join " + fnPrefix + "fnTEAM_HIERARCHY_MEMBERSHIPS(@" + sFieldPlaceholder + ") vwTEAM_MEMBERSHIPS" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID = TEAM_ID" + ControlChars.CrLf;
							}
						}
					}
					Sql.AddParameter(cmd, "@" + sFieldPlaceholder, Security.USER_ID);
					// 02/23/2017 Paul.  Add support for Team Hierarchy. 
					// 06/05/2017 Paul.  The SavedSearch does not apply to the Dashboard. 
					// 04/24/2018 Paul.  Provide a way to exclude the SavedSearch for areas that are global in nature. 
					if ( bEnableTeamHierarchy && sMODULE_NAME != "Dashboard" && !bExcludeSavedSearch )
					{
						// 02/25/2017 Paul.  Using an inner join is much faster than using TEAM_ID in (select ID from ...). 
						Guid   gTEAM_ID   = Guid.Empty;
						string sTEAM_NAME = String.Empty;
						Security.TeamHierarchySavedSearch(ref gTEAM_ID, ref sTEAM_NAME);
						if ( !Sql.IsEmptyGuid(gTEAM_ID) )
						{
							string sFieldPlaceholder2 = Sql.NextPlaceholder(cmd, "TEAM_ID");
							if ( Sql.IsOracle(cmd) )
							{
								cmd.CommandText += "       inner join table(fnTEAM_HIERARCHY_ByTeam(@" + sFieldPlaceholder2 + ")) vwTEAM_HIERARCHY_ByTeam" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_HIERARCHY_ByTeam.MEMBERSHIP_TEAM_ID = TEAM_ID" + ControlChars.CrLf;
							}
							else
							{
								string fnPrefix = (Sql.IsSQLServer(cmd) ? "dbo." : String.Empty);
								cmd.CommandText += "       inner join " + fnPrefix + "fnTEAM_HIERARCHY_ByTeam(@" + sFieldPlaceholder2 + ") vwTEAM_HIERARCHY_ByTeam" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_HIERARCHY_ByTeam.MEMBERSHIP_TEAM_ID = TEAM_ID" + ControlChars.CrLf;
							}
							Sql.AddParameter(cmd, "@" + sFieldPlaceholder2, gTEAM_ID);
						}
					}
				}
			}
			int nACLACCESS = 0;
			if ( bModuleIsAssigned && !Sql.IsEmptyString(sMODULE_NAME) )
			{
				// 08/30/2009 Paul.  Since the activities view does not allow us to filter on each module type, apply the Calls ACL rules to all activities. 
				// 06/02/2016 Paul.  Activities views will use new function that accepts an array of modules. 
				//if ( bActivitiesFilter )
				//	nACLACCESS = Security.GetUserAccess("Calls", sACCESS_TYPE);
				//else
					nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
			}
			
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			string sASSIGNED_SET_ID_Field = sASSIGNED_USER_ID_Field.Replace("ASSIGNED_USER_ID", "ASSIGNED_SET_ID");
			if ( bModuleIsAssigned && bEnableDynamicAssignment )
			{
				// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
				// 01/02/2008 Paul.  Make sure owner rule does not apply to admins. 
				if ( nACLACCESS == ACL_ACCESS.OWNER || (bRequireUserAssignment && !bIsAdmin) )
				{
					string sFieldPlaceholder = Sql.NextPlaceholder(cmd, sASSIGNED_SET_ID_Field);
					if ( bRequireUserAssignment && !bShowUnassigned )
						cmd.CommandText += "       inner ";
					else
						cmd.CommandText += "  left outer ";
					cmd.CommandText += "join vwASSIGNED_SET_MEMBERSHIPS" + ControlChars.CrLf;
					cmd.CommandText += "               on vwASSIGNED_SET_MEMBERSHIPS.MEMBERSHIP_ASSIGNED_SET_ID  = " + sASSIGNED_SET_ID_Field + ControlChars.CrLf;
					cmd.CommandText += "              and vwASSIGNED_SET_MEMBERSHIPS.MEMBERSHIP_ASSIGNED_USER_ID = @" + sFieldPlaceholder + ControlChars.CrLf;
					Sql.AddParameter(cmd, "@" + sFieldPlaceholder, Security.USER_ID);
				}
			}
			
			cmd.CommandText += " where 1 = 1" + ControlChars.CrLf;
			if ( bModuleIsTeamed )
			{
				if ( bEnableTeamManagement && !bRequireTeamManagement && !bIsAdmin )
				{
					// 08/31/2009 Paul.  Dynamic Teams are handled just like regular teams except using a different view. 
					// 09/01/2009 Paul.  Don't use MEMBERSHIP_ID as it is not included in the index. 
					if ( bEnableDynamicTeams )
						cmd.CommandText += "   and (TEAM_SET_ID is null or vwTEAM_SET_MEMBERSHIPS.MEMBERSHIP_TEAM_SET_ID is not null)" + ControlChars.CrLf;
					else
						cmd.CommandText += "   and (TEAM_ID is null or vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID is not null)" + ControlChars.CrLf;
				}
			}
			if ( bModuleIsAssigned )
			{
				// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
				// 01/02/2008 Paul.  Make sure owner rule does not apply to admins. 
				if ( nACLACCESS == ACL_ACCESS.OWNER || (bRequireUserAssignment && !bIsAdmin) )
				{
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( bEnableDynamicAssignment )
					{
						if ( bShowUnassigned )
						{
							cmd.CommandText += "   and (" + sASSIGNED_SET_ID_Field + " is null or vwASSIGNED_SET_MEMBERSHIPS.MEMBERSHIP_ASSIGNED_SET_ID is not null)" + ControlChars.CrLf;
						}
					}
					else
					{
						string sFieldPlaceholder = Sql.NextPlaceholder(cmd, sASSIGNED_USER_ID_Field);
						if ( bShowUnassigned )
						{
							if ( Sql.IsOracle(cmd) || Sql.IsDB2(cmd) )
								cmd.CommandText += "   and (" + sASSIGNED_USER_ID_Field + " is null or upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + "))" + ControlChars.CrLf;
							else
								cmd.CommandText += "   and (" + sASSIGNED_USER_ID_Field + " is null or "       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder + ")"  + ControlChars.CrLf;
						}
						/*
						// 02/13/2009 Paul.  We have a problem with the NOTES table as used in Activities lists. 
						// Notes are not assigned specifically to anyone so the ACTIVITY_ASSIGNED_USER_ID may return NULL. 
						// Notes should assume the ownership of the parent record, but we are also going to allow NULL for previous SplendidCRM installations. 
						// 02/13/2009 Paul.  This issue affects Notes, Quotes, Orders, Invoices and Orders, so just rely upon fixing the views. 
						else if ( sASSIGNED_USER_ID_Field == "ACTIVITY_ASSIGNED_USER_ID" )
						{
							if ( Sql.IsOracle(cmd) || Sql.IsDB2(cmd) )
								cmd.CommandText += "   and ((ACTIVITY_ASSIGNED_USER_ID is null and ACTIVITY_TYPE = N'Notes') or (upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + ")))" + ControlChars.CrLf;
							else
								cmd.CommandText += "   and ((ACTIVITY_ASSIGNED_USER_ID is null and ACTIVITY_TYPE = N'Notes') or ("       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder  + "))" + ControlChars.CrLf;
						}
						*/
						else
						{
							if ( Sql.IsOracle(cmd) || Sql.IsDB2(cmd) )
								cmd.CommandText += "   and upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + ")" + ControlChars.CrLf;
							else
								cmd.CommandText += "   and "       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder       + ControlChars.CrLf;
						}
						Sql.AddParameter(cmd, "@" + sFieldPlaceholder, Security.USER_ID);
					}
				}
			}
		}
	
		// 12/03/2017 Paul.  Module name field needs to be a parameter because it can change between MODULE_NAME and ACTIVITY_TYPE. 
		public static void Filter(IDbCommand cmd, string[] arrModules, string sACCESS_TYPE, string sASSIGNED_USER_ID_Field, string sMODULE_NAME_Field)
		{
			cmd.CommandTimeout = 0;
			// 01/22/2007 Paul.  If ASSIGNED_USER_ID is null, then let everybody see it. 
			// This was added to work around a bug whereby the ASSIGNED_USER_ID was not automatically assigned to the creating user. 
			bool bShowUnassigned        = Crm.Config.show_unassigned();
			// 06/02/2016 Paul. Stream and Activity tables are all teamed and assigned. 
			bool bModuleIsTeamed        = true;
			bool bModuleIsAssigned      = true;
			bool bEnableTeamManagement  = Crm.Config.enable_team_management();
			bool bRequireTeamManagement = Crm.Config.require_team_management();
			bool bRequireUserAssignment = Crm.Config.require_user_assignment();
			bool bEnableDynamicTeams    = Crm.Config.enable_dynamic_teams();
			bool bEnableTeamHierarchy   = Crm.Config.enable_team_hierarchy();
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			bool bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
			bool bIsAdmin = IS_ADMIN;
#if DEBUG
			bIsAdmin = false;
#endif
			if ( bModuleIsTeamed )
			{
				if ( bIsAdmin )
					bRequireTeamManagement = false;

				if ( bEnableTeamManagement )
				{
					string sFieldPlaceholder = Sql.NextPlaceholder(cmd, "MEMBERSHIP_USER_ID");
					if ( bEnableDynamicTeams )
					{
						if ( bRequireTeamManagement )
							cmd.CommandText += "       inner ";
						else
							cmd.CommandText += "  left outer ";
						if ( !bEnableTeamHierarchy )
						{
							cmd.CommandText += "join " + Sql.MetadataName(cmd, "vwTEAM_SET_MEMBERSHIPS_Security") + " vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
							cmd.CommandText += "               on vwTEAM_SET_MEMBERSHIPS.MEMBERSHIP_TEAM_SET_ID = TEAM_SET_ID" + ControlChars.CrLf;
							cmd.CommandText += "              and vwTEAM_SET_MEMBERSHIPS.MEMBERSHIP_USER_ID     = @" + sFieldPlaceholder + ControlChars.CrLf;
						}
						else
						{
							if ( Sql.IsOracle(cmd) )
							{
								cmd.CommandText += "join table(" + Sql.MetadataName(cmd, "fnTEAM_SET_HIERARCHY_MEMBERSHIPS") + "(@" + sFieldPlaceholder + ")) vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_SET_MEMBERSHIPS.MEMBERSHIP_TEAM_SET_ID = TEAM_SET_ID" + ControlChars.CrLf;
							}
							else
							{
								string fnPrefix = (Sql.IsSQLServer(cmd) ? "dbo." : String.Empty);
								cmd.CommandText += "join " + fnPrefix + Sql.MetadataName(cmd, "fnTEAM_SET_HIERARCHY_MEMBERSHIPS") + "(@" + sFieldPlaceholder + ") vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_SET_MEMBERSHIPS.MEMBERSHIP_TEAM_SET_ID = TEAM_SET_ID" + ControlChars.CrLf;
							}
						}
					}
					else
					{
						if ( bRequireTeamManagement )
							cmd.CommandText += "       inner ";
						else
							cmd.CommandText += "  left outer ";
						if ( !bEnableTeamHierarchy )
						{
							cmd.CommandText += "join vwTEAM_MEMBERSHIPS" + ControlChars.CrLf;
							cmd.CommandText += "               on vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID = TEAM_ID" + ControlChars.CrLf;
							cmd.CommandText += "              and vwTEAM_MEMBERSHIPS.MEMBERSHIP_USER_ID = @" + sFieldPlaceholder + ControlChars.CrLf;
						}
						else
						{
							if ( Sql.IsOracle(cmd) )
							{
								cmd.CommandText += "join table(fnTEAM_HIERARCHY_MEMBERSHIPS(@" + sFieldPlaceholder + ")) vwTEAM_MEMBERSHIPS" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID = TEAM_ID" + ControlChars.CrLf;
							}
							else
							{
								string fnPrefix = (Sql.IsSQLServer(cmd) ? "dbo." : String.Empty);
								cmd.CommandText += "join " + fnPrefix + "fnTEAM_HIERARCHY_MEMBERSHIPS(@" + sFieldPlaceholder + ") vwTEAM_MEMBERSHIPS" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID = TEAM_ID" + ControlChars.CrLf;
							}
						}
					}
					Sql.AddParameter(cmd, "@" + sFieldPlaceholder, Security.USER_ID);
					// 02/23/2017 Paul.  Add support for Team Hierarchy. 
					if ( bEnableTeamHierarchy )
					{
						// 02/25/2017 Paul.  Using an inner join is much faster than using TEAM_ID in (select ID from ...). 
						Guid   gTEAM_ID   = Guid.Empty;
						string sTEAM_NAME = String.Empty;
						Security.TeamHierarchySavedSearch(ref gTEAM_ID, ref sTEAM_NAME);
						if ( !Sql.IsEmptyGuid(gTEAM_ID) )
						{
							string sFieldPlaceholder2 = Sql.NextPlaceholder(cmd, "TEAM_ID");
							if ( Sql.IsOracle(cmd) )
							{
								cmd.CommandText += "       inner join table(fnTEAM_HIERARCHY_ByTeam(@" + sFieldPlaceholder2 + ")) vwTEAM_HIERARCHY_ByTeam" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_HIERARCHY_ByTeam.MEMBERSHIP_TEAM_ID = TEAM_ID" + ControlChars.CrLf;
							}
							else
							{
								string fnPrefix = (Sql.IsSQLServer(cmd) ? "dbo." : String.Empty);
								cmd.CommandText += "       inner join " + fnPrefix + "fnTEAM_HIERARCHY_ByTeam(@" + sFieldPlaceholder2 + ") vwTEAM_HIERARCHY_ByTeam" + ControlChars.CrLf;
								cmd.CommandText += "               on vwTEAM_HIERARCHY_ByTeam.MEMBERSHIP_TEAM_ID = TEAM_ID" + ControlChars.CrLf;
							}
							Sql.AddParameter(cmd, "@" + sFieldPlaceholder2, gTEAM_ID);
						}
					}
				}
			}
			// 06/02/2016 Paul.  We need to first determine if the rules should be applied. 
			bool bApplyAssignmentRules = false;
			foreach ( string sMODULE_NAME in arrModules )
			{
				int nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
				if ( nACLACCESS == ACL_ACCESS.OWNER || (bRequireUserAssignment && !bIsAdmin) )
				{
					bApplyAssignmentRules = true;
				}
			}
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			string sASSIGNED_SET_ID_Field = sASSIGNED_USER_ID_Field.Replace("ASSIGNED_USER_ID", "ASSIGNED_SET_ID");
			if ( bModuleIsAssigned && bApplyAssignmentRules && bEnableDynamicAssignment )
			{
				// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
				// 01/02/2008 Paul.  Make sure owner rule does not apply to admins. 
				foreach ( string sMODULE_NAME in arrModules )
				{
					int nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
					if ( nACLACCESS == ACL_ACCESS.OWNER || (bRequireUserAssignment && !bIsAdmin) )
					{
						string sFieldPlaceholder = Sql.NextPlaceholder(cmd, sASSIGNED_SET_ID_Field);
						// 12/03/2017 Paul.  We need to use an outer join because there would be one join per module. 
						cmd.CommandText += "  left outer ";
						cmd.CommandText += "join vwASSIGNED_SET_MEMBERSHIPS   vwASSIGNED_SET_MEMBERSHIPS_" + sMODULE_NAME + ControlChars.CrLf;
						cmd.CommandText += "               on vwASSIGNED_SET_MEMBERSHIPS_" + sMODULE_NAME + ".MEMBERSHIP_ASSIGNED_SET_ID  = " + sASSIGNED_SET_ID_Field + ControlChars.CrLf;
						cmd.CommandText += "              and vwASSIGNED_SET_MEMBERSHIPS_" + sMODULE_NAME + ".MEMBERSHIP_ASSIGNED_USER_ID = @" + sFieldPlaceholder + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@" + sFieldPlaceholder, Security.USER_ID);
						// 12/03/2017 Paul.  The module filter will be applied below as part of the or clause. 
						//string sMODULEPlaceholder = Sql.NextPlaceholder(cmd, sMODULE_NAME_Field);
						//cmd.CommandText += "              and " + sMODULE_NAME_Field + " = @" + sMODULEPlaceholder + ControlChars.CrLf;
						//Sql.AddParameter(cmd, "@" + sMODULEPlaceholder, sMODULE_NAME);
					}
				}
			}
			
			
			cmd.CommandText += " where 1 = 1" + ControlChars.CrLf;
			if ( bModuleIsTeamed )
			{
				if ( bEnableTeamManagement && !bRequireTeamManagement && !bIsAdmin )
				{
					if ( bEnableDynamicTeams )
						cmd.CommandText += "   and (TEAM_SET_ID is null or vwTEAM_SET_MEMBERSHIPS.MEMBERSHIP_TEAM_SET_ID is not null)" + ControlChars.CrLf;
					else
						cmd.CommandText += "   and (TEAM_ID is null or vwTEAM_MEMBERSHIPS.MEMBERSHIP_TEAM_ID is not null)" + ControlChars.CrLf;
				}
			}
			if ( bModuleIsAssigned && bApplyAssignmentRules )
			{
				cmd.CommandText += "   and ( 1 = 0" + ControlChars.CrLf;
				foreach ( string sMODULE_NAME in arrModules )
				{
					string sModuleSpacer = "";
					if ( sMODULE_NAME.Length < 15 )
						sModuleSpacer = Strings.Space(15 - sMODULE_NAME.Length);
					int nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
					if ( nACLACCESS == ACL_ACCESS.OWNER || (bRequireUserAssignment && !bIsAdmin) )
					{
						// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						if ( bEnableDynamicAssignment )
						{
							if ( bShowUnassigned )
							{
								string sMODULEPlaceholder = Sql.NextPlaceholder(cmd, sMODULE_NAME_Field);
								cmd.CommandText += "         or (" + sMODULE_NAME_Field + " = @" + sMODULEPlaceholder + sModuleSpacer + " and (" + sASSIGNED_SET_ID_Field + " is null or vwASSIGNED_SET_MEMBERSHIPS_" + sMODULE_NAME + ".MEMBERSHIP_ASSIGNED_SET_ID is not null))" + ControlChars.CrLf;
								Sql.AddParameter(cmd, "@" + sMODULEPlaceholder, sMODULE_NAME);
							}
							else
							{
								string sMODULEPlaceholder = Sql.NextPlaceholder(cmd, sMODULE_NAME_Field);
								cmd.CommandText += "         or (" + sMODULE_NAME_Field + " = @" + sMODULEPlaceholder + sModuleSpacer + " and (vwASSIGNED_SET_MEMBERSHIPS_" + sMODULE_NAME + ".MEMBERSHIP_ASSIGNED_SET_ID is not null))" + ControlChars.CrLf;
								Sql.AddParameter(cmd, "@" + sMODULEPlaceholder, sMODULE_NAME);
							}
						}
						else
						{
							string sFieldPlaceholder  = Sql.NextPlaceholder(cmd, sASSIGNED_USER_ID_Field);
							string sMODULEPlaceholder = Sql.NextPlaceholder(cmd, sMODULE_NAME_Field);
							if ( bShowUnassigned )
							{
								if ( Sql.IsOracle(cmd) || Sql.IsDB2(cmd) )
									cmd.CommandText += "         or (" + sMODULE_NAME_Field + " = @" + sMODULEPlaceholder + sModuleSpacer + " and (" + sASSIGNED_USER_ID_Field + " is null or upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + ")))" + ControlChars.CrLf;
								else
									cmd.CommandText += "         or (" + sMODULE_NAME_Field + " = @" + sMODULEPlaceholder + sModuleSpacer + " and (" + sASSIGNED_USER_ID_Field + " is null or "       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder +  "))" + ControlChars.CrLf;
							}
							else
							{
								if ( Sql.IsOracle(cmd) || Sql.IsDB2(cmd) )
									cmd.CommandText += "         or (" + sMODULE_NAME_Field + " = @" + sMODULEPlaceholder + sModuleSpacer + " and upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + "))" + ControlChars.CrLf;
								else
									cmd.CommandText += "         or (" + sMODULE_NAME_Field + " = @" + sMODULEPlaceholder + sModuleSpacer + " and "       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder +  ")" + ControlChars.CrLf;
							}
							Sql.AddParameter(cmd, "@" + sFieldPlaceholder, Security.USER_ID);
							Sql.AddParameter(cmd, "@" + sMODULEPlaceholder, sMODULE_NAME);
						}
					}
					else if ( nACLACCESS > 0 )
					{
						string sMODULEPlaceholder = Sql.NextPlaceholder(cmd, sMODULE_NAME_Field);
						cmd.CommandText += "          or " + sMODULE_NAME_Field + " = @" + sMODULEPlaceholder + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@" + sMODULEPlaceholder, sMODULE_NAME);
					}
				}
				cmd.CommandText += "       )" + ControlChars.CrLf;
			}
		}

		// 06/26/2018 Paul.  New filter for Data Privacy.  Only Assigned User applies, not team mangement so that only a user that is assigned the record can edit it. 
		public static void FilterAssigned(IDbCommand cmd, string sMODULE_NAME, string sACCESS_TYPE, string sASSIGNED_USER_ID_Field)
		{
			cmd.CommandTimeout = 0;
			bool bShowUnassigned        = Crm.Config.show_unassigned();
			bool bModuleIsAssigned      = true;
			bool bRequireUserAssignment = true;
			bool bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
			bool bIsAdmin = IS_ADMIN;
//#if DEBUG
//			bIsAdmin = false;
//#endif
			// 06/26/2018 Paul.  The Data Privacy Manager has admin-like access to Accounts, Contacts, Leads and Prospects. 
			if ( Security.GetACLRoleAccess("Data Privacy Manager Role") )
			{
				if ( sMODULE_NAME == "Accounts" || sMODULE_NAME == "Contacts" || sMODULE_NAME == "Leads" || sMODULE_NAME == "Prospects" )
				{
					bIsAdmin = true;
				}
			}
			int nACLACCESS = 0;
			if ( bModuleIsAssigned && !Sql.IsEmptyString(sMODULE_NAME) )
			{
				nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
			}
			
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			string sASSIGNED_SET_ID_Field = sASSIGNED_USER_ID_Field.Replace("ASSIGNED_USER_ID", "ASSIGNED_SET_ID");
			if ( bModuleIsAssigned && bEnableDynamicAssignment )
			{
				// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
				// 01/02/2008 Paul.  Make sure owner rule does not apply to admins. 
				if ( nACLACCESS == ACL_ACCESS.OWNER || (bRequireUserAssignment && !bIsAdmin) )
				{
					string sFieldPlaceholder = Sql.NextPlaceholder(cmd, sASSIGNED_SET_ID_Field);
					if ( bRequireUserAssignment && !bShowUnassigned )
						cmd.CommandText += "       inner ";
					else
						cmd.CommandText += "  left outer ";
					cmd.CommandText += "join vwASSIGNED_SET_MEMBERSHIPS" + ControlChars.CrLf;
					cmd.CommandText += "               on vwASSIGNED_SET_MEMBERSHIPS.MEMBERSHIP_ASSIGNED_SET_ID  = " + sASSIGNED_SET_ID_Field + ControlChars.CrLf;
					cmd.CommandText += "              and vwASSIGNED_SET_MEMBERSHIPS.MEMBERSHIP_ASSIGNED_USER_ID = @" + sFieldPlaceholder + ControlChars.CrLf;
					Sql.AddParameter(cmd, "@" + sFieldPlaceholder, Security.USER_ID);
				}
			}
			
			cmd.CommandText += " where 1 = 1" + ControlChars.CrLf;
			if ( bModuleIsAssigned )
			{
				// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
				// 01/02/2008 Paul.  Make sure owner rule does not apply to admins. 
				if ( nACLACCESS == ACL_ACCESS.OWNER || (bRequireUserAssignment && !bIsAdmin) )
				{
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( bEnableDynamicAssignment )
					{
						if ( bShowUnassigned )
						{
							cmd.CommandText += "   and (" + sASSIGNED_SET_ID_Field + " is null or vwASSIGNED_SET_MEMBERSHIPS.MEMBERSHIP_ASSIGNED_SET_ID is not null)" + ControlChars.CrLf;
						}
					}
					else
					{
						string sFieldPlaceholder = Sql.NextPlaceholder(cmd, sASSIGNED_USER_ID_Field);
						if ( bShowUnassigned )
						{
							if ( Sql.IsOracle(cmd) || Sql.IsDB2(cmd) )
								cmd.CommandText += "   and (" + sASSIGNED_USER_ID_Field + " is null or upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + "))" + ControlChars.CrLf;
							else
								cmd.CommandText += "   and (" + sASSIGNED_USER_ID_Field + " is null or "       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder + ")"  + ControlChars.CrLf;
						}
						else
						{
							if ( Sql.IsOracle(cmd) || Sql.IsDB2(cmd) )
								cmd.CommandText += "   and upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + ")" + ControlChars.CrLf;
							else
								cmd.CommandText += "   and "       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder       + ControlChars.CrLf;
						}
						Sql.AddParameter(cmd, "@" + sFieldPlaceholder, Security.USER_ID);
					}
				}
			}
		}
	}
}


