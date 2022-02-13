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
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.Common;
using System.Diagnostics;
using System.Web;
using System.Web.SessionState;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Web.Caching;
using System.Xml;
using System.Xml.Serialization;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for sugarsoap.
	/// 02/17/2006 Paul.  Change class name to sugarsoap to match the namespace used by SugarCRM. 
	/// 02/18/2006 Paul.  Must use the same SugarCRM namespace in order for SugarMail to consume our services.
	/// 02/18/2006 Paul.  The correct way to change the name is to use the Name property of WebService.
	/// 02/18/2006 Paul.  Must specify [SoapRpcService] in order to be compatible with SugarCRM. 
	/// 02/18/2006 Paul.  Methods must be marked with [SoapRpcMethod] in order to be compatible with SugarCRM. 
	/// </summary>
	[SoapRpcService]
	[WebService(Namespace="http://www.sugarcrm.com/sugarcrm", Name="sugarsoap", Description="SugarCRM web services implemented in C#")]
	public class soap : System.Web.Services.WebService
	{
		public soap()
		{
			//CODEGEN: This call is required by the ASP.NET Web Services Designer
			InitializeComponent();
		}


		#region Component Designer generated code
		
		//Required by the Web Services Designer 
		private IContainer components = null;
				
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if(disposing && components != null)
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}
		
		#endregion

		#region Data Structures
		[Serializable]
		public class contact_detail
		{
			public string        email_address;
			public string        name1        ;
			public string        name2        ;
			public string        association  ;
			public string        id           ;
			public string        msi_id       ;
			public string        type         ;

			public contact_detail()
			{
				email_address = String.Empty;
				name1         = String.Empty;
				name2         = String.Empty;
				association   = String.Empty;
				id            = String.Empty;
				msi_id        = String.Empty;
				type          = String.Empty;
			}
		}

		[Serializable]
		public class document_revision
		{
			public string        id           ;
			public string        document_name;
			public string        revision     ;
			public string        filename     ;
			public string        file         ;

			public document_revision()
			{
				id            = String.Empty;
				document_name = String.Empty;
				revision      = String.Empty;
				filename      = String.Empty;
				file          = String.Empty;
			}
		}

		[Serializable]
		public class error_value
		{
			public string        number       ;
			public string        name         ;
			public string        description  ;

			public error_value()
			{
				number      = "0";
				name        = "No Error";
				description = "No Error";
			}

			public error_value(string number, string name, string description)
			{
				this.number       = number      ;
				this.name         = name        ;
				this.description  = description ;
			}
		}

		[Serializable]
		public class set_relationship_list_result
		{
			public int           created      ;
			public int           failed       ;
			public error_value   error        ;

			public set_relationship_list_result()
			{
				created = 0;
				failed  = 0;
				error   = new error_value();
			}
		}

		[Serializable]
		public class set_relationship_value
		{
			public string        module1      ;
			public string        module1_id   ;
			public string        module2      ;
			public string        module2_id   ;

			public set_relationship_value()
			{
				module1    = String.Empty;
				module1_id = String.Empty;
				module2    = String.Empty;
				module2_id = String.Empty;
			}
		}

		[Serializable]
		public class id_mod
		{
			public string        id           ;
			public string        date_modified;
			public int           deleted      ;

			public id_mod()
			{
				id            = String.Empty;
				date_modified = String.Empty;
				deleted       = 0;
			}
			public id_mod(string id, string date_modified, int deleted)
			{
				this.id            = id           ;
				this.date_modified = date_modified;
				this.deleted       = deleted      ;
			}
		}

		[Serializable]
		public class get_relationships_result
		{
			public id_mod[]      ids          ;
			public error_value   error        ;

			public get_relationships_result()
			{
				ids   = new id_mod[0];
				error = new error_value();
			}
		}

		/*
		<return xsi:type="tns:get_entry_list_result_encoded">
			<result_count xsi:type="xsd:int">0</result_count>
			<next_offset xsi:type="xsd:int">0</next_offset>
			<total_count xsi:type="xsd:int">0</total_count>
			<field_list xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="xsd:string[0]"></field_list>
			<entry_list xsi:type="xsd:string">PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48aXRlbXM+PC9pdGVtcz4=</entry_list>
			<error xsi:type="tns:error_value">
				<number xsi:type="xsd:string">0</number>
				<name xsi:type="xsd:string">No Error</name>
				<description xsi:type="xsd:string">No Error</description>
			</error>
		</return>
		*/
		// 06/19/2007 Paul.  Starting with version 4.2, SugarCRM uses a function that optimizes syncing. 
		[Serializable]
		public class get_entry_list_result_encoded
		{
			public int           result_count ;
			public int           next_offset  ;
			public int           total_count  ;
			public string[]      field_list   ;
			public string        entry_list   ;  // Defaults to base64 encoded XML, but can also be PHP encoded. 
			public error_value   error        ;

			public get_entry_list_result_encoded()
			{
				result_count = 0;
				next_offset  = 0;
				total_count  = 0;
				field_list   = new string[0];
				entry_list   = String.Empty;
				error        = new error_value();
			}
		}

		[Serializable]
		public class module_list
		{
			public string[]      modules      ;
			public error_value   error        ;

			public module_list()
			{
				modules = new string[0];
				error   = new error_value();
			}
		}

		[Serializable]
		public class name_value
		{
			public string        name         ;
			public string        value        ;

			public name_value()
			{
				name  = String.Empty;
				value = String.Empty;
			}

			public name_value(string name, string value)
			{
				this.name  = name;
				this.value = value;
			}
		}

		[Serializable]
		public class field
		{
			public string        name         ;
			public string        type         ;
			public string        label        ;
			public int           required     ;
			public name_value[]  options      ;

			public field()
			{
				name     = String.Empty;
				type     = String.Empty;
				label    = String.Empty;
				required = 0;
				options  = new name_value[0];
			}

			public field(string name, string type, string label, int required)
			{
				this.name     = name    ;
				this.type     = type    ;
				this.label    = label   ;
				this.required = required;
				options       = new name_value[0];
			}
		}

		[Serializable]
		public class module_fields
		{
			public string        module_name  ;
			public field[]       module_fields1;
			public error_value   error        ;

			public module_fields()
			{
				module_name    = String.Empty;
				module_fields1 = new field[0];
				error          = new error_value();
			}
		}

		[Serializable]
		public class note_attachment
		{
			public string        id           ;
			public string        filename     ;
			public string        file         ;

			public note_attachment()
			{
				id       = String.Empty;
				filename = String.Empty;
				file     = String.Empty;
			}
		}

		[Serializable]
		public class return_note_attachment
		{
			public note_attachment note_attachment;
			public error_value     error          ;

			public return_note_attachment()
			{
				note_attachment = new note_attachment();
				error           = new error_value();
			}
		}

		[Serializable]
		public class set_entries_result
		{
			public string[]      ids          ;
			public error_value   error        ;

			public set_entries_result()
			{
				ids   = new string[0];
				error = new error_value();
			}
		}

		[Serializable]
		public class entry_value
		{
			public string        id           ;
			public string        module_name  ;
			public name_value[]  name_value_list;

			public entry_value()
			{
				id              = String.Empty;
				module_name     = String.Empty;
				name_value_list = new name_value[0];
			}
			public entry_value(string id, string module_name, string name, string value)
			{
				this.id                 = id;
				this.module_name        = module_name ;
				this.name_value_list    = new name_value[1];
				this.name_value_list[0] = new name_value(name, value);
			}
		}

		[Serializable]
		public class get_entry_result
		{
			public field[]       field_list   ;
			public entry_value[] entry_list   ;
			public error_value   error        ;

			public get_entry_result()
			{
				field_list = new field      [0];
				entry_list = new entry_value[0];
				error      = new error_value();
			}
		}

		[Serializable]
		public class get_entry_list_result
		{
			public int           result_count ;
			public int           next_offset  ;
			public field[]       field_list   ;
			public entry_value[] entry_list   ;
			public error_value   error        ;

			public get_entry_list_result()
			{
				result_count = 0;
				next_offset  = 0;
				field_list   = new field      [0];
				entry_list   = new entry_value[0];
				error        = new error_value();
			}
		}

		[Serializable]
		public class set_entry_result
		{
			public string        id           ;
			public error_value   error        ;

			public set_entry_result()
			{
				id    = String.Empty;
				error = new error_value();
			}
		}

		[Serializable]
		public class user_auth
		{
			public string        user_name    ;
			public string        password     ;
			public string        version      ;

			public user_auth()
			{
				user_name     = String.Empty;
				password      = String.Empty;
				version       = String.Empty;
			}
		}

		[Serializable]
		public class user_detail
		{
			public string        email_address;
			public string        user_name    ;
			public string        first_name   ;
			public string        last_name    ;
			public string        department   ;
			public string        id           ;
			public string        title        ;

			public user_detail()
			{
				email_address = String.Empty;
				user_name     = String.Empty;
				first_name    = String.Empty;
				last_name     = String.Empty;
				department    = String.Empty;
				id            = String.Empty;
				title         = String.Empty;
			}
		}
		#endregion

		// 12/29/2005 Paul.  Application will be started on first service call. 
		// 02/18/2006 Paul.  Methods must be marked with [SoapRpcMethod] in order to be compatible with SugarCRM. 
		#region System Information
		[WebMethod]
		[SoapRpcMethod]
		public string get_server_version()
		{
			return Sql.ToString(HttpContext.Current.Application["CONFIG.sugar_version"]);
		}

		[WebMethod]
		[SoapRpcMethod]
		// 10/06/2009 Paul.  The Splendid Version is needed for DNN integration 
		public string get_splendid_version()
		{
			return Sql.ToString(HttpContext.Current.Application["SplendidVersion"]);
		}

		[WebMethod]
		[SoapRpcMethod]
		// 10/06/2009 Paul.  The edition is needed for DNN integration.
		// Return 'CE' -- For Community Edition 'PRO' -- For Professional 'ENT' -- For Enterprise 
		public string get_sugar_flavor()
		{
			string sServiceLevel = Sql.ToString(Application["CONFIG.service_level"]);
			if ( String.Compare(sServiceLevel, "Basic", true) == 0 || String.Compare(sServiceLevel, "Community", true) == 0 )
				return "CE";
			else if ( String.Compare(sServiceLevel, "Enterprise", true) == 0 )
				return "ENT";
			// 11/06/2015 Paul.  Add support for the Ultimate edition. 
			else if ( String.Compare(sServiceLevel, "Ultimate", true) == 0 )
				return "ULT";
			else // if ( String.Compare(sServiceLevel, "Professional", true) == 0 )
				return "PRO";
		}

		[WebMethod]
		[SoapRpcMethod]
		public int is_loopback()
		{
			if ( HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"] == HttpContext.Current.Request.ServerVariables["LOCAL_ADDR"] )
				return 1;
			return 0;
		}

		[WebMethod]
		[SoapRpcMethod]
		public string test(string s)
		{
			return s;
		}

		[WebMethod]
		[SoapRpcMethod]
		public string get_server_time()
		{
			DateTime dtNow = DateTime.Now;
			return dtNow.ToString("G");
		}

		[WebMethod]
		[SoapRpcMethod]
		public string get_gmt_time()
		{
			DateTime dtNow = DateTime.Now;
			return dtNow.ToUniversalTime().ToString("u");
		}
		#endregion

		/*
		'no_error'               =>array('number'=>0 , 'name'=>'No Error', 'description'=>'No Error'),
		'invalid_login'          =>array('number'=>10 , 'name'=>'Invalid Login', 'description'=>'Login attempt failed please check the username and password'),
		'invalid_session'        =>array('number'=>11 , 'name'=>'Invalid Session ID', 'description'=>'The session ID is invalid'),
		'no_portal'              =>array('number'=>12 , 'name'=>'Invalid Portal Client', 'description'=>'Portal Client does not have authorized access'),
		'no_module'              =>array('number'=>20 , 'name'=>'Module Does Not Exist', 'description'=>'This module is not available on this server'),
		'no_file'                =>array('number'=>21 , 'name'=>'File Does Not Exist', 'description'=>'The desired file does not exist on the server'),
		'no_module_support'      =>array('number'=>30 , 'name'=>'Module Not Supported', 'description'=>'This module does not support this feature'),
		'no_relationship_support'=>array('number'=>31 , 'name'=>'Relationship Not Supported', 'description'=>'This module does not support this relationship'),
		'no_access'              =>array('number'=>40 , 'name'=>'Access Denied', 'description'=>'You do not have access'),
		'duplicates'             =>array('number'=>50 , 'name'=>'Duplicate Records', 'description'=>'Duplicate records have been found. Please be more specific.'),
		'no_records'             =>array('number'=>51 , 'name'=>'No Records', 'description'=>'No records were found.'),
		*/

		#region Session
		public static DateTime DefaultCacheExpiration()
		{
			return DateTime.Now.AddDays(1);
		}

		private Guid GetSessionUserID(string session)
		{
			System.Web.Caching.Cache Cache = HttpRuntime.Cache;

			string sUSER_NAME  = String.Empty;
			string sTimeZone   = String.Empty;
			string sCurrencyID = String.Empty;
			Guid gUSER_ID = Sql.ToGuid(Cache.Get("soap.session.user." + session));
			if ( gUSER_ID == Guid.Empty )
			{
				// 03/06/2008 Paul.  For Windows users, just ignore the invalid session and re-authenticate. 
				if ( Security.IsWindowsAuthentication() )
				{
					gUSER_ID = LoginUser(ref sUSER_NAME, String.Empty, false);
					UserPreferences(gUSER_ID, ref sTimeZone, ref sCurrencyID);

					DateTime dtExpiration = DefaultCacheExpiration();
					Cache.Remove("soap.user.username." + gUSER_ID.ToString()  );
					Cache.Insert("soap.user.username." + gUSER_ID.ToString(), sUSER_NAME.ToLower(), null, dtExpiration, Cache.NoSlidingExpiration);
					Cache.Remove("soap.user.currency." + gUSER_ID.ToString());
					Cache.Insert("soap.user.currency." + gUSER_ID.ToString(), sCurrencyID, null, dtExpiration, Cache.NoSlidingExpiration);
					Cache.Remove("soap.user.timezone." + gUSER_ID.ToString());
					Cache.Insert("soap.user.timezone." + gUSER_ID.ToString(), sTimeZone  , null, dtExpiration, Cache.NoSlidingExpiration);
					return gUSER_ID;
				}
				else
				{
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "The session ID is invalid.  " + session);
					throw(new Exception("The session ID is invalid.  " + session));
				}
			}
			// 02/17/2006 Paul.  We do need to set the USER_ID in the session as the stored procedures use the session variable. 
			if ( Session == null )
				throw(new Exception("HttpContext.Current.Session is null"));
			HttpContext.Current.Session["USER_ID"] = gUSER_ID;

			// 09/01/2006 Paul.  On every SOAP request, we need to update the cache expiration.
			// This should only be a minor impact on performance, but it will allow the user to stay connected indefinitely
			// when the Outlook Plug-in is set to auto-sync. 
			Guid gSessionID = Sql.ToGuid(session);
			sUSER_NAME  = Sql.ToString(Cache.Get("soap.user.username." + gUSER_ID.ToString()));
			sCurrencyID = Sql.ToString(Cache.Get("soap.user.currency." + gUSER_ID.ToString()));
			sTimeZone   = Sql.ToString(Cache.Get("soap.user.timezone." + gUSER_ID.ToString()));

			// 03/04/2008 Paul.  Some customers are having a problem with cache expiration. 
			// Lets try only resetting the cache timeout if it is within 1 hour of expiring.
			DateTime dtCurrentExpiration = Sql.ToDateTime(Cache.Get("soap.user.expiration." + session.ToString()));
			if ( dtCurrentExpiration < DateTime.Now.AddHours(1) )
			{
				// 03/07/2007 Paul.  Use a single expiration value. 
				DateTime dtExpiration = DefaultCacheExpiration();
				// 03/04/2008 Paul.  Reduce the delay between remove and re-insert. 
				Cache.Remove("soap.session.user."     + gSessionID.ToString());
				Cache.Insert("soap.session.user."     + gSessionID.ToString(), gUSER_ID           , null, dtExpiration, Cache.NoSlidingExpiration);
				//Cache.Remove("soap.username.session." + sUSER_NAME.ToLower()  );
				//Cache.Insert("soap.username.session." + sUSER_NAME.ToLower()  , gSessionID         , null, dtExpiration, Cache.NoSlidingExpiration);
				// 03/06/2008 Paul.  Since we don't use the USER_NAME, don't cache it any more. 
				Cache.Remove("soap.user.username."    + gUSER_ID.ToString()  );
				Cache.Insert("soap.user.username."    + gUSER_ID.ToString()  , sUSER_NAME.ToLower(), null, dtExpiration, Cache.NoSlidingExpiration);
				Cache.Remove("soap.user.currency."    + gUSER_ID.ToString()  );
				Cache.Insert("soap.user.currency."    + gUSER_ID.ToString()  , sCurrencyID        , null, dtExpiration, Cache.NoSlidingExpiration);
				Cache.Remove("soap.user.timezone."    + gUSER_ID.ToString()  );
				Cache.Insert("soap.user.timezone."    + gUSER_ID.ToString()  , sTimeZone          , null, dtExpiration, Cache.NoSlidingExpiration);
				// 03/06/2008 Paul.  Expiration should be based on the session and not the USER_ID. 
				Cache.Remove("soap.user.expiration."  + session.ToString()  );
				Cache.Insert("soap.user.expiration."  + session.ToString()  , dtExpiration       , null, dtExpiration, Cache.NoSlidingExpiration);
			}
			return gUSER_ID;
		}

		private bool IsAdmin(Guid gUSER_ID)
		{
			bool bIS_ADMIN = false;
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select IS_ADMIN" + ControlChars.CrLf
				     + "  from vwUSERS " + ControlChars.CrLf
				     + " where ID = @ID" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@ID", gUSER_ID);
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						if ( rdr.Read() )
						{
							bIS_ADMIN = Sql.ToBoolean(rdr["IS_ADMIN"]);
						}
					}
				}
			}
			return bIS_ADMIN;
		}

		// 03/12/2007 Paul.  A number of customers are having a problem with the plug-in timing out. 
		// The problem could be that the username is blank for windows authentication. 
		// 12/10/2009 Paul.  Make the function static so that it can be accessed by ReportServiceAuthentication. 
		public static Guid LoginUser(ref string sUSER_NAME, string sPASSWORD, bool bLogEvent)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			HttpRequest          Request     = HttpContext.Current.Request    ;

			Guid gUSER_ID = Guid.Empty;
			string sNTLM = String.Empty;
			if ( Security.IsWindowsAuthentication() )
			{
				string[] arrUserName = HttpContext.Current.User.Identity.Name.Split('\\');
				string sUSER_DOMAIN = arrUserName[0];
				sUSER_NAME = arrUserName[1];
				// 09/07/2006 Paul.  Provide an indication that we are using NTLM. 
				sNTLM = " (NTLM " + sUSER_DOMAIN + ")";
			}
			else
			{
				// 02/23/2011 Paul.  SOAP service should check for lockout. 
				if ( SplendidInit.LoginFailures(Application, sUSER_NAME) >= Crm.Password.LoginLockoutCount(Application) )
				{
					L10N L10n = new L10N("en-US");
					throw(new Exception(L10n.Term("Users.ERR_USER_LOCKED_OUT")));
				}
				// 04/16/2013 Paul.  Allow system to be restricted by IP Address. 
				if ( SplendidInit.InvalidIPAddress(Application, Request.UserHostAddress) )
				{
					L10N L10n = new L10N("en-US");
					throw(new Exception(L10n.Term("Users.ERR_INVALID_IP_ADDRESS")));
				}
			}
			
			// 02/14/2019 Paul.  Add support for ADFS Single-Sign-On.  Using WS-Federation Desktop authentication (username/password). 
			string sError = String.Empty;
			if ( Sql.ToBoolean(Application["CONFIG.ADFS.SingleSignOn.Enabled"]) )
			{
				// 02/14/2019 Paul.  A mobile client will not use soap. 
				gUSER_ID = ActiveDirectory.FederationServicesValidateJwt(HttpContext.Current, sPASSWORD, false, ref sError);
				if ( !Sql.IsEmptyGuid(gUSER_ID) )
				{
					SplendidInit.LoginUser(gUSER_ID, "ASDF");
				}
			}
			else if ( Sql.ToBoolean(Application["CONFIG.Azure.SingleSignOn.Enabled"]) )
			{
				// 02/14/2019 Paul.  A mobile client will not use soap. 
				gUSER_ID = ActiveDirectory.AzureValidateJwt(HttpContext.Current, sPASSWORD, false, ref sError);
				if ( !Sql.IsEmptyGuid(gUSER_ID) )
				{
					SplendidInit.LoginUser(gUSER_ID, "Azure AD");
				}
			}
			else
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 05/23/2006 Paul.  Use vwUSERS_Login so that USER_HASH can be removed from vwUSERS to prevent its use in reports. 
					// 06/09/2009 Paul.  Add TEAM fields. 
					sSQL = "select ID                    " + ControlChars.CrLf
					     + "     , USER_NAME             " + ControlChars.CrLf
					     + "     , FULL_NAME             " + ControlChars.CrLf
					     + "     , IS_ADMIN              " + ControlChars.CrLf
					     + "     , STATUS                " + ControlChars.CrLf
					     + "     , PORTAL_ONLY           " + ControlChars.CrLf
					     + "     , TEAM_ID               " + ControlChars.CrLf
					     + "     , TEAM_NAME             " + ControlChars.CrLf
					     + "  from vwUSERS_Login         " + ControlChars.CrLf
					     + " where lower(USER_NAME) = @USER_NAME" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@USER_NAME", sUSER_NAME);
						string sLOGIN_TYPE = "Windows";
						if ( !Security.IsWindowsAuthentication() )
						{
							sLOGIN_TYPE = "Anonymous";
							if ( !Sql.IsEmptyString(sPASSWORD) )
							{
								cmd.CommandText += "   and USER_HASH = @USER_HASH" + ControlChars.CrLf;
								Sql.AddParameter(cmd, "@USER_HASH", sPASSWORD.ToLower());
							}
							else
							{
								// 11/19/2005 Paul.  Handle the special case of the password stored as NULL or empty string. 
								cmd.CommandText += "   and (USER_HASH = '' or USER_HASH is null)" + ControlChars.CrLf;
							}
						}
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							Guid gUSER_LOGIN_ID = Guid.Empty;
							if ( rdr.Read() )
							{
								// 06/09/2009 Paul.  We need to initialize all the session values.  Not sure why we were not doing this earlier. 
								Security.USER_ID     = Sql.ToGuid   (rdr["ID"         ]);
								Security.USER_NAME   = Sql.ToString (rdr["USER_NAME"  ]);
								Security.FULL_NAME   = Sql.ToString (rdr["FULL_NAME"  ]);
								Security.IS_ADMIN    = Sql.ToBoolean(rdr["IS_ADMIN"   ]);
								Security.PORTAL_ONLY = Sql.ToBoolean(rdr["PORTAL_ONLY"]);
								Security.TEAM_ID     = Sql.ToGuid   (rdr["TEAM_ID"    ]);
								Security.TEAM_NAME   = Sql.ToString (rdr["TEAM_NAME"  ]);
								gUSER_ID = Sql.ToGuid(rdr["ID"]);
								SplendidInit.LoadUserPreferences(gUSER_ID, String.Empty, String.Empty);
								// 06/09/2009 Paul.  We need to initialize the ACL session values, otherwise all the ACL rules will get ignored. 
								SplendidInit.LoadUserACL(gUSER_ID);
								
								// 03/02/2008 Paul.  Log the logins. 
								if ( bLogEvent )
								{
									SqlProcs.spUSERS_LOGINS_InsertOnly(ref gUSER_LOGIN_ID, gUSER_ID, sUSER_NAME, sLOGIN_TYPE, "Succeeded", Session.SessionID, Request.UserHostName, Request.Url.Host, Request.Path, Request.AppRelativeCurrentExecutionFilePath, Request.UserAgent);
									Security.USER_LOGIN_ID = gUSER_LOGIN_ID;
								}
								// 02/20/2011 Paul.  Log the success so that we can lockout the user. 
								SplendidInit.LoginTracking(Application, sUSER_NAME, true);
								// 09/07/2006 Paul.  Include the user name in the message. 
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "SOAP User login for " + sUSER_NAME + sNTLM);
							}
							else
							{
								// 03/02/2008 Paul.  Log the logins. 
								if ( bLogEvent )
								{
									SqlProcs.spUSERS_LOGINS_InsertOnly(ref gUSER_LOGIN_ID, Guid.Empty, sUSER_NAME, sLOGIN_TYPE, "Failed", Session.SessionID, Request.UserHostName, Request.Url.Host, Request.Path, Request.AppRelativeCurrentExecutionFilePath, Request.UserAgent);
								}
								// 02/20/2011 Paul.  Log the failure so that we can lockout the user. 
								SplendidInit.LoginTracking(Application, sUSER_NAME, false);
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "SECURITY: failed attempted login for " + sUSER_NAME + sNTLM + " using SOAP api");
							}
						}
					}
				}
			}
			if ( gUSER_ID == Guid.Empty )
			{
				SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Invalid username and/or password for " + sUSER_NAME + sNTLM);
				throw(new Exception("Invalid username and/or password for " + sUSER_NAME + sNTLM));
			}
			// 02/16/2006 Paul.  We do need to set the USER_ID in the session as the stored procedures use the session variable. 
			if ( HttpContext.Current.Session == null )
				throw(new Exception("HttpContext.Current.Session is null"));
			HttpContext.Current.Session["USER_ID"] = gUSER_ID;
			return gUSER_ID;
		}
		
		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		// 02/18/2006 Paul.  The return attribute does not tag the output with [return: System.Xml.Serialization.SoapElementAttribute("return")]. 
		// [return: XmlElement("return")]
		public string create_session(string user_name, string password)
		{
			// 06/04/2007 Paul.  Move logic to a new function that can return the Session ID.  It will be needed in other functions. 
			// 06/05/2007 Paul.  The SplendidCRM create_session function just validates the users, but does not create a session. 
			// This is because it does is no good to create a session if we are unable to access the SessionID.
			Guid gUSER_ID = LoginUser(ref user_name, password, true);
			// LoginUser will throw an exception if the user is invalid.  Let this exception bubble-up the chain and return to the calling service. 
			// 12/29/2005 Paul. SugarCRM returns Success instead of the SessionID.  The login function will return the Session ID. Very strange.
			return "Success";
		}

		private void UserPreferences(Guid gUSER_ID, ref string sTimeZone, ref string sCurrencyID)
		{
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
					Sql.AddParameter(cmd, "@ID", gUSER_ID);
					con.Open();
					using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
					{
						if ( rdr.Read() )
						{
							//12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
							/*
							string sUSER_PREFERENCES = Sql.ToString(rdr["USER_PREFERENCES"]);
							if ( !Sql.IsEmptyString(sUSER_PREFERENCES) )
							{
								XmlDocument xml = SplendidInit.InitUserPreferences(sUSER_PREFERENCES);
								try
								{
									sTimeZone = XmlUtil.SelectSingleNode(xml, "timezone");
								}
								catch
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), "Invalid USER_SETTINGS/TIMEZONE: " + XmlUtil.SelectSingleNode(xml, "timezone"));
								}
								try
								{
									sCurrencyID = XmlUtil.SelectSingleNode(xml, "currency_id");
								}
								catch
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), "Invalid USER_SETTINGS/CURRENCY: " + XmlUtil.SelectSingleNode(xml, "currency_id"));
								}
							}
							*/
							try
							{
								sTimeZone = Sql.ToString(rdr["TIMEZONE_ID"]);
							}
							catch
							{
							}
							try
							{
								sCurrencyID = Sql.ToString(rdr["CURRENCY_ID"]);
							}
							catch
							{
							}
						}
					}
				}
			}
			if ( Sql.IsEmptyString(sCurrencyID) )
			{
				// 09/01/2006 Paul.  Use system default currency if no user value is provided. 
				sCurrencyID = SplendidDefaults.CurrencyID();
			}
			if ( Sql.IsEmptyString(sTimeZone) )
			{
				// 09/01/2006 Paul.  Use system default timezone if no user value is provided. 
				sTimeZone = SplendidDefaults.TimeZone();
			}
		}

		private Guid CreateSession(string user_name, string password)
		{
			System.Web.Caching.Cache Cache = HttpRuntime.Cache;
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);
			// 12/29/2005 Paul.  If the user is valid, then try and locate an existing session. 
			
			// 06/04/2007 Paul.  Always create a new session. This is to allow multiple active sessions. 
			Guid gSessionID = Guid.Empty; // Sql.ToGuid(Cache.Get("soap.username.session." + user_name.ToLower()));
			//if ( gSessionID == Guid.Empty )
			{
				gSessionID = Guid.NewGuid();
				// 03/07/2007 Paul.  Use a single expiration value. 
				DateTime dtExpiration = DefaultCacheExpiration();
				Cache.Insert("soap.session.user."      + gSessionID.ToString(), gUSER_ID           , null, dtExpiration, Cache.NoSlidingExpiration);
				//Cache.Insert("soap.username.session."  + user_name.ToLower()  , gSessionID         , null, dtExpiration, Cache.NoSlidingExpiration);
				Cache.Insert("soap.user.username."     + gUSER_ID.ToString()  , user_name.ToLower(), null, dtExpiration, Cache.NoSlidingExpiration);
				// 03/06/2008 Paul.  Expiration should be based on the session and not the USER_ID. 
				Cache.Insert("soap.user.expiration."   + gSessionID.ToString()  , dtExpiration       , null, dtExpiration, Cache.NoSlidingExpiration);

				string sTimeZone   = String.Empty;
				string sCurrencyID = String.Empty;
				UserPreferences(gUSER_ID, ref sTimeZone, ref sCurrencyID);
				Cache.Insert("soap.user.currency." + gUSER_ID.ToString(), sTimeZone  , null, dtExpiration, Cache.NoSlidingExpiration);
				Cache.Insert("soap.user.timezone." + gUSER_ID.ToString(), sCurrencyID, null, dtExpiration, Cache.NoSlidingExpiration);
			}
			return gSessionID;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public set_entry_result login(user_auth user_auth, string application_name)
		{
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			// 03/12/2007 Paul.  If we are using NTLM, then the user_name will be blank. 
			// This could be one of the reasons why some sessions were dying.  
			if ( Security.IsWindowsAuthentication() )
			{
				string[] arrUserName = HttpContext.Current.User.Identity.Name.Split('\\');
				string sUSER_DOMAIN = arrUserName[0];
				user_auth.user_name = arrUserName[1];
			}
			else
			{
				// 02/23/2011 Paul.  SOAP service should check for lockout. 
				if ( SplendidInit.LoginFailures(Application, user_auth.user_name) >= Crm.Password.LoginLockoutCount(Application) )
				{
					L10N L10n = new L10N("en-US");
					throw(new Exception(L10n.Term("Users.ERR_USER_LOCKED_OUT")));
				}
				// 04/16/2013 Paul.  Allow system to be restricted by IP Address. 
				if ( SplendidInit.InvalidIPAddress(Application, Request.UserHostAddress) )
				{
					L10N L10n = new L10N("en-US");
					throw(new Exception(L10n.Term("Users.ERR_INVALID_IP_ADDRESS")));
				}
			}
			// 12/29/2005 Paul.  create_session returns "Suceess".  We need a separate operation to get the SessionID.
			set_entry_result result = new set_entry_result();
			// 06/04/2007 Paul.  Use new function that returns the Session ID. 
			result.id = CreateSession(user_auth.user_name, user_auth.password).ToString();
			//result.id = Sql.ToString(HttpRuntime.Cache.Get("soap.username.session." + user_auth.user_name.ToLower()));
			return result;
		}

		[WebMethod]
		[SoapRpcMethod]
		public string end_session(string user_name)
		{
			// 06/04/2007 Paul.  end_session does nothing.  The cached session will eventually expire. 
			// This was a poor design by SugarCRM. 
			/*
			System.Web.Caching.Cache Cache = HttpRuntime.Cache;
			Guid gSessionID = Sql.ToGuid(Cache.Get("soap.username.session." + user_name.ToLower()));
			if ( gSessionID != Guid.Empty )
			{
				Guid gUSER_ID = Sql.ToGuid(Cache.Get("soap.session.user." + gSessionID.ToString()));
				Cache.Remove("soap.session.user."     + gSessionID.ToString());
				Cache.Remove("soap.username.session." + user_name.ToLower()  );
				// 09/01/2006 Paul.  Remove all cached entries for this user. 
				Cache.Remove("soap.user.username."    + gUSER_ID.ToString()  );
				Cache.Remove("soap.user.currency."    + gUSER_ID.ToString()  );
				Cache.Remove("soap.user.timezone."    + gUSER_ID.ToString()  );
			}
			*/
			return "Success";
		}

		[WebMethod]
		[SoapRpcMethod]
		public int seamless_login(string session)
		{
			// 02/18/2008 Paul.  HttpRuntime.Cache is a better and faster way to get to the cache. 
			Guid gUSER_ID = Sql.ToGuid(HttpRuntime.Cache.Get("soap.session.user." + session));
			if ( gUSER_ID == Guid.Empty )
			{
				return 0;
			}
			return 1;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public error_value logout(string session)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			error_value results = new error_value();
			return results;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public string get_user_id(string session)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			return gUSER_ID.ToString();
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public string get_user_team_id(string session)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			// 06/09/2009 Paul.  Return the default team. 
			return Security.TEAM_ID.ToString();
		}
		#endregion

		#region UserName/Password-required functions

		#region Creation methods
		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public string create_contact(string user_name, string password, string first_name, string last_name, string email_address)
		{
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);

			int nACLACCESS = Security.GetUserAccess("Contacts", "edit");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			Guid gID = Guid.Empty;
			// 01/16/2012 Paul.  Assigned User ID and Team ID are now parameters. 
			SqlProcs.spCONTACTS_New
				( ref gID
				, first_name
				, last_name
				, String.Empty
				, email_address
				, Security.USER_ID
				, Security.TEAM_ID
				, String.Empty
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				, String.Empty      // ASSIGNED_SET_LIST
				);
			return "1";
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public string create_lead(string user_name, string password, string first_name, string last_name, string email_address)
		{
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);

			int nACLACCESS = Security.GetUserAccess("Leads", "edit");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			Guid gID = Guid.Empty;
			// 01/16/2012 Paul.  Assigned User ID and Team ID are now parameters. 
			SqlProcs.spLEADS_New
				( ref gID
				, first_name
				, last_name
				, String.Empty
				, email_address
				, Security.USER_ID
				, Security.TEAM_ID
				, String.Empty
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				, String.Empty      // ASSIGNED_SET_LIST
				);
			return "1";
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public string create_account(string user_name, string password, string name, string phone, string website)
		{
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);

			int nACLACCESS = Security.GetUserAccess("Accounts", "edit");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			Guid gID = Guid.Empty;
			// 01/16/2012 Paul.  Assigned User ID and Team ID are now parameters. 
			SqlProcs.spACCOUNTS_New
				( ref gID
				, name
				, phone
				, website
				, Security.USER_ID
				, Security.TEAM_ID
				, String.Empty
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				, String.Empty      // ASSIGNED_SET_LIST
				);
			return "1";
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public string create_opportunity(string user_name, string password, string name, string amount)
		{
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);

			int nACLACCESS = Security.GetUserAccess("Opportunities", "edit");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			Guid gID = Guid.Empty;
			// 01/16/2012 Paul.  Assigned User ID and Team ID are now parameters. 
			// 05/01/2013 Paul.  Add Contacts field to support B2C. 
			SqlProcs.spOPPORTUNITIES_New
				( ref gID
				, Guid.Empty
				, name
				, Sql.ToDecimal(amount)
				, Guid.Empty
				, DateTime.MinValue
				, String.Empty
				, Security.USER_ID
				, Security.TEAM_ID
				, String.Empty
				, Guid.Empty
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				, String.Empty      // ASSIGNED_SET_LIST
				);
			return "1";
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public string create_case(string user_name, string password, string name)
		{
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);

			int nACLACCESS = Security.GetUserAccess("Cases", "edit");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			Guid gID = Guid.Empty;
			// 01/16/2012 Paul.  Assigned User ID and Team ID are now parameters. 
			// 05/01/2013 Paul.  Add Contacts field to support B2C. 
			SqlProcs.spCASES_New
				( ref gID
				, name
				, String.Empty
				, Guid.Empty
				, Security.USER_ID
				, Security.TEAM_ID
				, String.Empty
				, Guid.Empty
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				, String.Empty      // ASSIGNED_SET_LIST
				);
			return "1";
		}
		#endregion

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public contact_detail[] contact_by_email(string user_name, string password, string email_address)
		{
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);

			int nACLACCESS = Security.GetUserAccess("Contacts", "list");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}

			contact_detail[] results = new contact_detail[0];
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select *                      " + ControlChars.CrLf
				     + "  from vwSOAP_Contact_By_Email" + ControlChars.CrLf;
				//     + " where 1 = 0                  " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
					Security.Filter(cmd, "Contacts", "view");
					cmd.CommandText += "   and (1 = 0" + ControlChars.CrLf;
					// 12/29/2005 Paul.  Allow multiple email addresses, separated by a semicolon. 
					email_address = email_address.Replace(" ", "");
					string[] aAddresses = email_address.Split(';');
					// 02/20/2006 Paul.  Need to use the IN clause. 
					Sql.AppendParameter(cmd, aAddresses, "EMAIL1", true);
					Sql.AppendParameter(cmd, aAddresses, "EMAIL2", true);
					cmd.CommandText += "       )" + ControlChars.CrLf;
					//if ( nACLACCESS == ACL_ACCESS.OWNER )
					//{
					//	Sql.AppendParameter(cmd, gUSER_ID, "ASSIGNED_USER_ID");
					//}
					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								if ( dt.Rows.Count > 0 )
								{
									// 02/20/2006 Paul.  First initialize the array. 
									results = new contact_detail[dt.Rows.Count];
									for ( int i=0; i < dt.Rows.Count ; i++ )
									{
										// 02/20/2006 Paul.  Then initialize each element in the array. 
										results[i] = new contact_detail();
										results[i].email_address = Sql.ToString(dt.Rows[i]["EMAIL_ADDRESS"]);
										results[i].name1         = Sql.ToString(dt.Rows[i]["NAME1"        ]);
										results[i].name2         = Sql.ToString(dt.Rows[i]["NAME2"        ]);
										results[i].association   = Sql.ToString(dt.Rows[i]["ASSOCIATION"  ]);
										results[i].id            = Sql.ToString(dt.Rows[i]["ID"           ]);
										results[i].type          = Sql.ToString(dt.Rows[i]["TYPE"         ]);
										results[i].msi_id        = (i+1).ToString();
									}
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						throw(new Exception("SOAP: Failed contact_by_email", ex));
					}
				}
			}
			return results;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public user_detail[] user_list(string user_name, string password)
		{
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);

			if ( !IsAdmin(gUSER_ID) )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}

			user_detail[] results = new user_detail[0];
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select *               " + ControlChars.CrLf
				     + "  from vwSOAP_User_List" + ControlChars.CrLf
				     + " where 1 = 1           " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								if ( dt.Rows.Count > 0 )
								{
									// 02/20/2006 Paul.  First initialize the array. 
									results = new user_detail[dt.Rows.Count];
									for ( int i=0; i < dt.Rows.Count ; i++ )
									{
										// 02/20/2006 Paul.  Then initialize each element in the array. 
										results[i] = new user_detail();
										results[i].email_address = Sql.ToString(dt.Rows[i]["EMAIL_ADDRESS"]);
										results[i].user_name     = Sql.ToString(dt.Rows[i]["USER_NAME"    ]);
										results[i].first_name    = Sql.ToString(dt.Rows[i]["FIRST_NAME"   ]);
										results[i].last_name     = Sql.ToString(dt.Rows[i]["LAST_NAME"    ]);
										results[i].department    = Sql.ToString(dt.Rows[i]["DEPARTMENT"   ]);
										results[i].id            = Sql.ToString(dt.Rows[i]["ID"           ]);
										results[i].title         = Sql.ToString(dt.Rows[i]["TITLE"        ]);
									}
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						throw(new Exception("SOAP: Failed user_list", ex));
					}
				}
			}
			return results;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public contact_detail[] search(string user_name, string password, string name)
		{
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);

			contact_detail[] results = new contact_detail[0];
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				//int nACLACCESS = 0;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					//StringBuilder sb = new StringBuilder();
					// 12/29/2005 Paul.  Names are normally separated by a semicolon.
					// Since we are using our StringBuilder, convert the semicolon to an OR clause. 
					name = name.Replace(";", " or ");
					sSQL = "select ID                     as ID           " + ControlChars.CrLf
					     + "     , FIRST_NAME             as NAME1        " + ControlChars.CrLf
					     + "     , LAST_NAME              as NAME2        " + ControlChars.CrLf
					     + "     , ACCOUNT_NAME           as ASSOCIATION  " + ControlChars.CrLf
					     + "     , N'Contact'             as TYPE         " + ControlChars.CrLf
					     + "     , EMAIL1                 as EMAIL_ADDRESS" + ControlChars.CrLf
					     + "  from vwCONTACTS_List                        " + ControlChars.CrLf;
					// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
					cmd.CommandText += sSQL;
					Security.Filter(cmd, "Contacts", "list");
					// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
					cmd.CommandText += Sql.UnifiedSearch("Contacts", name, cmd);
					//     + " where 1 = 1                                  " + ControlChars.CrLf
					//     +  Contacts.SearchContacts.UnifiedSearch(name, cmd);
					//nACLACCESS = Security.GetUserAccess("Contacts", "list");
					//if ( nACLACCESS < 0 )
					//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
					//else if ( nACLACCESS == ACL_ACCESS.OWNER )
					//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
					//sb.Append(sSQL);

					// 05/23/2006 Paul.  Add space after the query to prevent UNION ALL from touching a previous field or keyword. 
					sSQL = " union all                                    " + ControlChars.CrLf
					     + "select ID                     as ID           " + ControlChars.CrLf
					     + "     , FIRST_NAME             as NAME1        " + ControlChars.CrLf
					     + "     , LAST_NAME              as NAME2        " + ControlChars.CrLf
					     + "     , ACCOUNT_NAME           as ASSOCIATION  " + ControlChars.CrLf
					     + "     , N'Lead'                as TYPE         " + ControlChars.CrLf
					     + "     , EMAIL1                 as EMAIL_ADDRESS" + ControlChars.CrLf
					     + "  from vwLEADS_List                           " + ControlChars.CrLf;
					// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
					cmd.CommandText += sSQL;
					Security.Filter(cmd, "Leads", "list");
					// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
					cmd.CommandText += Sql.UnifiedSearch("Leads", name, cmd);
					//     + " where 1 = 1                                  " + ControlChars.CrLf
					//     +  Leads.SearchLeads.UnifiedSearch(name, cmd);
					//nACLACCESS = Security.GetUserAccess("Leads", "list");
					//if ( nACLACCESS < 0 )
					//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
					//else if ( nACLACCESS == ACL_ACCESS.OWNER )
					//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
					//sb.Append(sSQL);

					// 05/23/2006 Paul.  Add space after the query to prevent UNION ALL from touching a previous field or keyword. 
					sSQL = " union all                                    " + ControlChars.CrLf
					     + "select ID                     as ID           " + ControlChars.CrLf
					     + "     , N''                    as NAME1        " + ControlChars.CrLf
					     + "     , NAME                   as NAME2        " + ControlChars.CrLf
					     + "     , BILLING_ADDRESS_CITY   as ASSOCIATION  " + ControlChars.CrLf
					     + "     , N'Account'             as TYPE         " + ControlChars.CrLf
					     + "     , EMAIL1                 as EMAIL_ADDRESS" + ControlChars.CrLf
					     + "  from vwACCOUNTS_List                        " + ControlChars.CrLf;
					// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
					cmd.CommandText += sSQL;
					Security.Filter(cmd, "Accounts", "list");
					// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
					cmd.CommandText += Sql.UnifiedSearch("Accounts", name, cmd);
					//     + " where 1 = 1                                  " + ControlChars.CrLf
					//     +  Accounts.SearchAccounts.UnifiedSearch(name, cmd);
					//nACLACCESS = Security.GetUserAccess("Accounts", "list");
					//if ( nACLACCESS < 0 )
					//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
					//else if ( nACLACCESS == ACL_ACCESS.OWNER )
					//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
					//sb.Append(sSQL);

					// 05/23/2006 Paul.  Add space after the query to prevent UNION ALL from touching a previous field or keyword. 
					sSQL = " union all                                    " + ControlChars.CrLf
					     + "select ID                     as ID           " + ControlChars.CrLf
					     + "     , N''                    as NAME1        " + ControlChars.CrLf
					     + "     , NAME                   as NAME2        " + ControlChars.CrLf
					     + "     , ACCOUNT_NAME           as ASSOCIATION  " + ControlChars.CrLf
					     + "     , N'Case'                as TYPE         " + ControlChars.CrLf
					     + "     , N''                    as EMAIL_ADDRESS" + ControlChars.CrLf
					     + "  from vwCASES_List                           " + ControlChars.CrLf;
					// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
					cmd.CommandText += sSQL;
					Security.Filter(cmd, "Cases", "list");
					// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
					cmd.CommandText += Sql.UnifiedSearch("Cases", name, cmd);
					//     + " where 1 = 1                                  " + ControlChars.CrLf
					//     +  Cases.SearchCases.UnifiedSearch(name, cmd);
					//nACLACCESS = Security.GetUserAccess("Cases", "list");
					//if ( nACLACCESS < 0 )
					//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
					//else if ( nACLACCESS == ACL_ACCESS.OWNER )
					//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
					//sb.Append(sSQL);

					// 05/23/2006 Paul.  Add space after the query to prevent UNION ALL from touching a previous field or keyword. 
					sSQL = " union all                                    " + ControlChars.CrLf
					     + "select ID                     as ID           " + ControlChars.CrLf
					     + "     , N''                    as NAME1        " + ControlChars.CrLf
					     + "     , NAME                   as NAME2        " + ControlChars.CrLf
					     + "     , ACCOUNT_NAME           as ASSOCIATION  " + ControlChars.CrLf
					     + "     , N'Opportunity'         as TYPE         " + ControlChars.CrLf
					     + "     , N''                    as EMAIL_ADDRESS" + ControlChars.CrLf
					     + "  from vwOPPORTUNITIES_List                   " + ControlChars.CrLf;
					// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
					cmd.CommandText += sSQL;
					Security.Filter(cmd, "Opportunities", "list");
					// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
					cmd.CommandText += Sql.UnifiedSearch("Opportunities", name, cmd);
					//     + " where 1 = 1                                  " + ControlChars.CrLf
					//     +  Opportunities.SearchOpportunities.UnifiedSearch(name, cmd);
					//nACLACCESS = Security.GetUserAccess("Opportunities", "list");
					//if ( nACLACCESS < 0 )
					//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
					//else if ( nACLACCESS == ACL_ACCESS.OWNER )
					//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
					//sb.Append(sSQL);

					// 06/01/2006 Paul.  The string builder contains the full query. 
					//cmd.CommandText = sb.ToString();
					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								if ( dt.Rows.Count > 0 )
								{
									// 02/20/2006 Paul.  First initialize the array. 
									results = new contact_detail[dt.Rows.Count];
									for ( int i=0; i < dt.Rows.Count ; i++ )
									{
										// 02/20/2006 Paul.  Then initialize each element in the array. 
										results[i] = new contact_detail();
										results[i].email_address = Sql.ToString(dt.Rows[i]["EMAIL_ADDRESS"]);
										results[i].name1         = Sql.ToString(dt.Rows[i]["NAME1"        ]);
										results[i].name2         = Sql.ToString(dt.Rows[i]["NAME2"        ]);
										results[i].association   = Sql.ToString(dt.Rows[i]["ASSOCIATION"  ]);
										results[i].id            = Sql.ToString(dt.Rows[i]["ID"           ]);
										results[i].type          = Sql.ToString(dt.Rows[i]["TYPE"         ]);
										results[i].msi_id        = (i+1).ToString();
									}
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						throw(new Exception("SOAP: Failed search()", ex));
					}
				}
			}
			return results;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public get_entry_list_result search_by_module(string user_name, string password, string search_string, string[] modules, int offset, int max_results)
		{
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);

			// 02/18/2008 Paul.  HttpRuntime.Cache is a better and faster way to get to the cache. 
			Guid gTIMEZONE = Sql.ToGuid(HttpRuntime.Cache.Get("soap.user.timezone." + gUSER_ID.ToString()));
			TimeZone T10n = TimeZone.CreateTimeZone(gTIMEZONE);

			if ( offset < 0 )
				throw(new Exception("offset must be a non-negative number"));
			if ( max_results <= 0 )
				throw(new Exception("max_results must be a postive number"));

			// 05/24/2009 Paul.  Names are normally separated by a semicolon.
			// Since we are using our StringBuilder, convert the semicolon to an OR clause. 
			search_string = search_string.Replace(";", " or ");
			
			if ( modules == null || modules.Length == 0 )
			{
				modules = new string[1];
				modules[0] = "Accounts";
			}
			get_entry_list_result results = new get_entry_list_result();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				//int nACLACCESS = 0;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					//StringBuilder sb = new StringBuilder();
					foreach ( string sModule in modules )
					{
						if ( sModule == "Contacts" )
						{
							if ( cmd.CommandText.Length > 0 )
								cmd.CommandText += " union all" + ControlChars.CrLf;
							sSQL = "select ID                     as ID           " + ControlChars.CrLf
							     + "     , FIRST_NAME             as NAME1        " + ControlChars.CrLf
							     + "     , LAST_NAME              as NAME2        " + ControlChars.CrLf
							     + "     , ACCOUNT_NAME           as ASSOCIATION  " + ControlChars.CrLf
							     + "     , N'Contact'             as TYPE         " + ControlChars.CrLf
							     + "     , N'Contacts'            as MODULE_NAME  " + ControlChars.CrLf
							     + "     , EMAIL1                 as EMAIL_ADDRESS" + ControlChars.CrLf
							     + "  from vwCONTACTS_List                        " + ControlChars.CrLf;
							// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
							cmd.CommandText += sSQL;
							Security.Filter(cmd, "Contacts", "list");
							// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
							cmd.CommandText += Sql.UnifiedSearch("Contacts", search_string, cmd);
							//     + " where 1 = 1                                  " + ControlChars.CrLf
							//     +  Contacts.SearchContacts.UnifiedSearch(search_string, cmd);
							//nACLACCESS = Security.GetUserAccess("Contacts", "list");
							//if ( nACLACCESS < 0 )
							//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
							//else if ( nACLACCESS == ACL_ACCESS.OWNER )
							//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
							//sb.Append(sSQL);
						}
						else if ( sModule == "Leads" )
						{
							if ( cmd.CommandText.Length > 0 )
								cmd.CommandText += " union all" + ControlChars.CrLf;
							sSQL = "select ID                     as ID           " + ControlChars.CrLf
							     + "     , FIRST_NAME             as NAME1        " + ControlChars.CrLf
							     + "     , LAST_NAME              as NAME2        " + ControlChars.CrLf
							     + "     , ACCOUNT_NAME           as ASSOCIATION  " + ControlChars.CrLf
							     + "     , N'Lead'                as TYPE         " + ControlChars.CrLf
							     + "     , N'Leads'               as MODULE_NAME  " + ControlChars.CrLf
							     + "     , EMAIL1                 as EMAIL_ADDRESS" + ControlChars.CrLf
							     + "  from vwLEADS_List                           " + ControlChars.CrLf;
							// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
							cmd.CommandText += sSQL;
							Security.Filter(cmd, "Leads", "list");
							// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
							cmd.CommandText += Sql.UnifiedSearch("Leads", search_string, cmd);
							//     + " where 1 = 1                                  " + ControlChars.CrLf
							//     +  Leads.SearchLeads.UnifiedSearch(search_string, cmd);
							//nACLACCESS = Security.GetUserAccess("Leads", "list");
							//if ( nACLACCESS < 0 )
							//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
							//else if ( nACLACCESS == ACL_ACCESS.OWNER )
							//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
							//sb.Append(sSQL);
						}
						else if ( sModule == "Accounts" )
						{
							if ( cmd.CommandText.Length > 0 )
								cmd.CommandText += " union all" + ControlChars.CrLf;
							sSQL = "select ID                     as ID           " + ControlChars.CrLf
							     + "     , N''                    as NAME1        " + ControlChars.CrLf
							     + "     , NAME                   as NAME2        " + ControlChars.CrLf
							     + "     , BILLING_ADDRESS_CITY   as ASSOCIATION  " + ControlChars.CrLf
							     + "     , N'Account'             as TYPE         " + ControlChars.CrLf
							     + "     , N'Accounts'            as MODULE_NAME  " + ControlChars.CrLf
							     + "     , EMAIL1                 as EMAIL_ADDRESS" + ControlChars.CrLf
							     + "  from vwACCOUNTS_List                        " + ControlChars.CrLf;
							// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
							cmd.CommandText += sSQL;
							Security.Filter(cmd, "Accounts", "list");
							// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
							cmd.CommandText += Sql.UnifiedSearch("Accounts", search_string, cmd);
							//     + " where 1 = 1                                  " + ControlChars.CrLf
							//     +  Accounts.SearchAccounts.UnifiedSearch(search_string, cmd);
							//nACLACCESS = Security.GetUserAccess("Accounts", "list");
							//if ( nACLACCESS < 0 )
							//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
							//else if ( nACLACCESS == ACL_ACCESS.OWNER )
							//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
							//sb.Append(sSQL);
						}
						else if ( sModule == "Cases" )
						{
							if ( cmd.CommandText.Length > 0 )
								cmd.CommandText += " union all" + ControlChars.CrLf;
							sSQL = "select ID                     as ID           " + ControlChars.CrLf
							     + "     , N''                    as NAME1        " + ControlChars.CrLf
							     + "     , NAME                   as NAME2        " + ControlChars.CrLf
							     + "     , ACCOUNT_NAME           as ASSOCIATION  " + ControlChars.CrLf
							     + "     , N'Case'                as TYPE         " + ControlChars.CrLf
							     + "     , N'Cases'               as MODULE_NAME  " + ControlChars.CrLf
							     + "     , N''                    as EMAIL_ADDRESS" + ControlChars.CrLf
							     + "  from vwCASES_List                           " + ControlChars.CrLf;
							// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
							cmd.CommandText += sSQL;
							Security.Filter(cmd, "Cases", "list");
							// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
							cmd.CommandText += Sql.UnifiedSearch("Cases", search_string, cmd);
							//     + " where 1 = 1                                  " + ControlChars.CrLf
							//     +  Cases.SearchCases.UnifiedSearch(search_string, cmd);
							//nACLACCESS = Security.GetUserAccess("Cases", "list");
							//if ( nACLACCESS < 0 )
							//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
							//else if ( nACLACCESS == ACL_ACCESS.OWNER )
							//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
							//sb.Append(sSQL);
						}
						else if ( sModule == "Opportunities" )
						{
							if ( cmd.CommandText.Length > 0 )
								cmd.CommandText += " union all" + ControlChars.CrLf;
							sSQL = "select ID                     as ID           " + ControlChars.CrLf
							     + "     , N''                    as NAME1        " + ControlChars.CrLf
							     + "     , NAME                   as NAME2        " + ControlChars.CrLf
							     + "     , ACCOUNT_NAME           as ASSOCIATION  " + ControlChars.CrLf
							     + "     , N'Opportunity'         as TYPE         " + ControlChars.CrLf
							     + "     , N'Opportunities'       as MODULE_NAME  " + ControlChars.CrLf
							     + "     , N''                    as EMAIL_ADDRESS" + ControlChars.CrLf
							     + "  from vwOPPORTUNITIES_List                   " + ControlChars.CrLf;
							// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
							cmd.CommandText += sSQL;
							Security.Filter(cmd, "Opportunities", "list");
							// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
							cmd.CommandText += Sql.UnifiedSearch("Opportunities", search_string, cmd);
							//     + " where 1 = 1                                  " + ControlChars.CrLf
							//     +  Opportunities.SearchOpportunities.UnifiedSearch(search_string, cmd);
							//nACLACCESS = Security.GetUserAccess("Opportunities", "list");
							//if ( nACLACCESS < 0 )
							//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
							//else if ( nACLACCESS == ACL_ACCESS.OWNER )
							//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
							//sb.Append(sSQL);
						}
						else if ( sModule == "Bugs" )
						{
							if ( cmd.CommandText.Length > 0 )
								cmd.CommandText += " union all" + ControlChars.CrLf;
							sSQL = "select ID                     as ID           " + ControlChars.CrLf
							     + "     , N''                    as NAME1        " + ControlChars.CrLf
							     + "     , NAME                   as NAME2        " + ControlChars.CrLf
							     + "     , N''                    as ASSOCIATION  " + ControlChars.CrLf
							     + "     , N'Bug'                 as TYPE         " + ControlChars.CrLf
							     + "     , N'Bugs'                as MODULE_NAME  " + ControlChars.CrLf
							     + "     , N''                    as EMAIL_ADDRESS" + ControlChars.CrLf
							     + "  from vwBUGS_List                            " + ControlChars.CrLf;
							// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
							cmd.CommandText += sSQL;
							Security.Filter(cmd, "Bugs", "list");
							// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
							cmd.CommandText += Sql.UnifiedSearch("Bugs", search_string, cmd);
							//     + " where 1 = 1                                  " + ControlChars.CrLf
							//     +  Bugs.SearchBugs.UnifiedSearch(search_string, cmd);
							//nACLACCESS = Security.GetUserAccess("Bugs", "list");
							//if ( nACLACCESS < 0 )
							//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
							//else if ( nACLACCESS == ACL_ACCESS.OWNER )
							//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
							//sb.Append(sSQL);
						}
						else if ( sModule == "Projects" || sModule == "Project" )
						{
							if ( cmd.CommandText.Length > 0 )
								cmd.CommandText += " union all" + ControlChars.CrLf;
							sSQL = "select ID                     as ID           " + ControlChars.CrLf
							     + "     , N''                    as NAME1        " + ControlChars.CrLf
							     + "     , NAME                   as NAME2        " + ControlChars.CrLf
							     + "     , N''                    as ASSOCIATION  " + ControlChars.CrLf
							     + "     , N'Project'             as TYPE         " + ControlChars.CrLf
							     + "     , N'Projects'            as MODULE_NAME  " + ControlChars.CrLf
							     + "     , N''                    as EMAIL_ADDRESS" + ControlChars.CrLf
							     + "  from vwPROJECTS_List                        " + ControlChars.CrLf;
							// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
							cmd.CommandText += sSQL;
							// 06/27/2014 Paul.  Project should be singular. 
							Security.Filter(cmd, "Project", "list");
							// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
							cmd.CommandText += Sql.UnifiedSearch("Project", search_string, cmd);
							//     + " where 1 = 1                                  " + ControlChars.CrLf
							//     +  Projects.SearchProjects.UnifiedSearch(search_string, cmd);
							//nACLACCESS = Security.GetUserAccess("Project", "list");
							//if ( nACLACCESS < 0 )
							//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
							//else if ( nACLACCESS == ACL_ACCESS.OWNER )
							//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
							//sb.Append(sSQL);
						}
						// 05/18/2014 Paul.  Customer wants to be able to archive to an order. 
						else if ( sModule == "Orders" )
						{
							if ( cmd.CommandText.Length > 0 )
								cmd.CommandText += " union all" + ControlChars.CrLf;
							sSQL = "select ID                     as ID           " + ControlChars.CrLf
							     + "     , N''                    as NAME1        " + ControlChars.CrLf
							     + "     , NAME                   as NAME2        " + ControlChars.CrLf
							     + "     , N''                    as ASSOCIATION  " + ControlChars.CrLf
							     + "     , N'Order'               as TYPE         " + ControlChars.CrLf
							     + "     , N'Orders'              as MODULE_NAME  " + ControlChars.CrLf
							     + "     , N''                    as EMAIL_ADDRESS" + ControlChars.CrLf
							     + "  from vwORDERS_List                          " + ControlChars.CrLf;
							// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
							cmd.CommandText += sSQL;
							Security.Filter(cmd, "Orders", "list");
							// 05/15/2016 Paul.  Move UnifiedSearch() to Sql. 
							cmd.CommandText += Sql.UnifiedSearch("Orders", search_string, cmd);
							//     + " where 1 = 1                                  " + ControlChars.CrLf
							//     +  Orders.SearchOrders.UnifiedSearch(search_string, cmd);
							//nACLACCESS = Security.GetUserAccess("Orders", "list");
							//if ( nACLACCESS < 0 )
							//	sSQL += sSQL + "   and 1 = 0" + ControlChars.CrLf;
							//else if ( nACLACCESS == ACL_ACCESS.OWNER )
							//	sSQL += sSQL + "   and ASSIGNED_USER_ID = '" + gUSER_ID.ToString() + "'" + ControlChars.CrLf;
							//sb.Append(sSQL);
						}
					}
					//cmd.CommandText = sb.ToString();
					// 09/10/2009 Paul.  Apply custom paging. 
					if ( Crm.Config.allow_custom_paging() && (Crm.Modules.CustomPaging("Accounts") || Crm.Modules.CustomPaging("Contacts") || Crm.Modules.CustomPaging("Leads")) )
					{
						// 09/30/2009 Paul.  The use of unions and column aliases is preventing the normal windowing code to work. 
						// We need to wrap the unions in a master select. 
						cmd.CommandText = cmd.CommandText.Replace(ControlChars.CrLf, ControlChars.CrLf + "        ");
						cmd.CommandText = "select *" + ControlChars.CrLf
						                + "  from (" 
						                + cmd.CommandText + ControlChars.CrLf
						                + "       ) SEARCH_BY_MODULE" + ControlChars.CrLf;
						Sql.WindowResults(cmd, "SEARCH_BY_MODULE", " order by NAME2 asc, NAME1 asc", offset, max_results);
					}
					else
					{
						cmd.CommandText += " order by NAME2 asc, NAME1 asc";
					}
					try
					{
						CultureInfo ciEnglish = CultureInfo.CreateSpecificCulture("en-US");
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								if ( dt.Rows.Count > 0 )
								{
									// 09/10/2009 Paul.  If using custom paging, then the result count is the row count. 
									if ( Crm.Config.allow_custom_paging() && (Crm.Modules.CustomPaging("Accounts") || Crm.Modules.CustomPaging("Contacts") || Crm.Modules.CustomPaging("Leads")) )
									{
										results.result_count = dt.Rows.Count;
										results.next_offset  = offset + results.result_count;
										// 09/10/2009 Paul.  The logic below can work for custom paging if we simply clear the offset. 
										offset = 0;
									}
									else
									{
										results.result_count = Math.Min(dt.Rows.Count - offset, max_results);
										results.next_offset  = offset + results.result_count;
									}
									
									string[] select_fields = new string[dt.Columns.Count];
									for ( int i=0; i < dt.Columns.Count; i++ )
									{
										select_fields[i] = dt.Columns[i].ColumnName;
									}
									// 02/20/2006 Paul.  First initialize the array. 
									results.field_list = new field      [select_fields.Length];
									results.entry_list = new entry_value[results.result_count];
									for ( int i=0; i < select_fields.Length; i++ )
									{
										string sColumnName = select_fields[i];
										DataColumn col = dt.Columns[sColumnName];
										// 02/20/2006 Paul.  Then initialize each element in the array. 
										// 02/16/2006 Paul.  We don't have a mapping for the labels, so just return the column name. 
										// varchar, bool, datetime, int, text, blob
										results.field_list[i] = new field(sColumnName.ToLower(), col.DataType.ToString(), sColumnName, 0);
									}
									
									// 02/16/2006 Paul.  SugarCRM 3.5.1 returns all fields even though only a few were requested.  We will do the same. 
									int j = 0;
									foreach ( DataRow row in dt.Rows )
									{
										if ( j >= offset && j < offset + results.result_count )
										{
											int nItem = j - offset;
											// 02/20/2006 Paul.  Then initialize each element in the array. 
											results.entry_list[nItem] = new entry_value();
											results.entry_list[nItem].id              = Sql.ToGuid(row["ID"]).ToString();
											results.entry_list[nItem].module_name     = Sql.ToString(row["MODULE_NAME"]);
											// 02/20/2006 Paul.  First initialize the array. 
											results.entry_list[nItem].name_value_list = new name_value[dt.Columns.Count];
											int nColumn = 0;
											foreach ( DataColumn col in dt.Columns )
											{
												// 02/20/2006 Paul.  Then initialize each element in the array. 
												// 08/17/2006 Paul.  We need to convert all dates to UniversalTime. 
												// 06/07/2009 Paul.  Information.IsDate looks at the value but we need to inspect the data type. 
												if ( col.DataType == typeof(System.DateTime) )
												{
													// 08/17/2006 Paul.  The time on the server and the time in the database are both considered ServerTime. 
													DateTime dtServerTime = Sql.ToDateTime(row[col.ColumnName]);
													// 08/17/2006 Paul.  We need a special function to convert to UniversalTime because it might already be in UniversalTime, based on m_bGMTStorage flag. 
													DateTime dtUniversalTime = T10n.ToUniversalTimeFromServerTime(dtServerTime);
													results.entry_list[nItem].name_value_list[nColumn] = new name_value(col.ColumnName.ToLower(), dtUniversalTime.ToString(CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat));
												}
												else
												{
													results.entry_list[nItem].name_value_list[nColumn] = new name_value(col.ColumnName.ToLower(), Sql.ToString(row[col.ColumnName]));
												}
												nColumn++;
											}
										}
										j++;
									}
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						// 09/23/2011 Paul.  Include SQL so that we can understand the problem. 
						throw(new Exception("SOAP: Failed get_entry_list. \r\n\"" + Sql.ExpandParameters(cmd) + "\"", ex));
					}
				}
			}
			return results;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public string track_email(string user_name, string password, string parent_id, string contact_ids, DateTime date_sent, string email_subject, string email_body)
		{
			// 03/12/2007 Paul.  If using NTLM, then user_name will be updated with value from Identity object. 
			Guid gUSER_ID = LoginUser(ref user_name, password, true);
			if ( gUSER_ID != Guid.Empty )
			{
				throw(new Exception("Method not implemented."));
			}
			return String.Empty;
		}
		#endregion

		#region Session-required functions
		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public get_entry_list_result get_entry_list(string session, string module_name, string query, string order_by, int offset, string[] select_fields, int max_results, int deleted)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			// 02/18/2008 Paul.  HttpRuntime.Cache is a better and faster way to get to the cache. 
			Guid gTIMEZONE = Sql.ToGuid(HttpRuntime.Cache.Get("soap.user.timezone." + gUSER_ID.ToString()));
			TimeZone T10n = TimeZone.CreateTimeZone(gTIMEZONE);

			if ( offset < 0 )
				throw(new Exception("offset must be a non-negative number"));
			if ( max_results <= 0 )
				throw(new Exception("max_results must be a postive number"));

			string sTABLE_NAME = VerifyModuleName(module_name);
			query       = query.ToUpper();
			order_by    = order_by.ToUpper();
			query    = query   .Replace(sTABLE_NAME + ".", String.Empty);
			order_by = order_by.Replace(sTABLE_NAME + ".", String.Empty);
			
			int nACLACCESS = Security.GetUserAccess(module_name, "list");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 06/27/2014 Paul.  We need to provide security around the tables accessed by SOAP.  Use the same REST rules. 
			sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "").ToUpper();
			bool   bHAS_CUSTOM = false;
			DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false);
			if ( dtSYNC_TABLES == null || dtSYNC_TABLES.Rows.Count == 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			else
			{
				DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
				string sVIEW_NAME = Sql.ToString (rowSYNC_TABLE["VIEW_NAME" ]);
				bool   bIS_SYSTEM = Sql.ToBoolean(rowSYNC_TABLE["IS_SYSTEM" ]);
				bHAS_CUSTOM = Sql.ToBoolean(rowSYNC_TABLE["HAS_CUSTOM"]);
				// 06/27/2014 Paul.  System tables should use the view for security reasons. 
				if ( bIS_SYSTEM )
					sTABLE_NAME = sVIEW_NAME;
			}

			get_entry_list_result results = new get_entry_list_result();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 05/04/2008 Paul.  Protect against SQL Injection. A table name will never have a space character.
				// 06/09/2008 Paul.  Use Regex instead of simple replace. 
				sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "");
				sSQL = "select *" + ControlChars.CrLf
				     + "  from " + sTABLE_NAME + ControlChars.CrLf;
				//     + " where DELETED = @DELETED" + ControlChars.CrLf;
				// 03/18/2016 Paul.  Add manual join to custom field table. 
				if ( bHAS_CUSTOM )
				{
					sSQL += " inner join " + sTABLE_NAME + "_CSTM" + ControlChars.CrLf;
					sSQL += "         on " + sTABLE_NAME + "_CSTM.ID_C = " + sTABLE_NAME + ".ID" + ControlChars.CrLf;
				}
				// 04/23/2011 Paul.  For added security, wrap SOAP queries in a transaction, and rollback the transaction when done. 
				// This is to protect against SQL injection coming from a SOAP service. 
				using ( IDbTransaction trn = Sql.BeginTransaction(con) )
				{
					try
					{
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.Transaction = trn;
							cmd.CommandText = sSQL;
							// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
							Security.Filter(cmd, module_name, "view");
							// 06/27/2014 Paul.  If we are accessing a system view, then we can ignore the deleted flag. 
							if ( !sTABLE_NAME.StartsWith("vw") )
								Sql.AppendParameter(cmd, Math.Min(deleted, 1), "DELETED", false);
							if ( !Sql.IsEmptyString(query) )
							{
								// 02/16/2006 Paul.  As much as I dislike the idea of allowing a query string, 
								// I don't have the time to parse this.
								// 03/08/2006 Paul.  Prepend the AND clause. 
								// 06/27/2014 Paul.  We should append to CommandText not sSQL.  This bug was introduced on 05/18/2014 version 8.5. 
								cmd.CommandText += "   and (" + query + ")" + ControlChars.CrLf;
							}
							//Sql.AddParameter(cmd, "@DELETED", Math.Min(deleted, 1));
							//if ( nACLACCESS == ACL_ACCESS.OWNER )
							//{
							//	// 09/01/2006 Paul.  Notes do not have an ASSIGNED_USER_ID. 
							//	// 01/20/2013 Paul.  ASSIGNED_USER_ID was added to notes table on 04/02/2012. 
							//	//if ( sTABLE_NAME != "NOTES" )
							//		Sql.AppendParameter(cmd, gUSER_ID, "ASSIGNED_USER_ID");
							//}
							// 06/09/2008 Paul.  With large resultsets, sorting in ASP.NET is too slow.  Use Regex to protext against SQL-Injection. 
							if ( !Sql.IsEmptyString(order_by) )
							{
								// 11/25/2008 Paul.  Remove the " asc" as it makes it difficult for us to remove spaces.
								// We remove spaces as protection against SQL injection. 
								// 09/10/2009 Paul.  Defer concatenation to the command until after custom paging is applied. 
								if ( order_by.ToLower().EndsWith(" asc") )
								{
									order_by = order_by.Substring(0, order_by.Length - 4);
									order_by = " order by " + Regex.Replace(order_by, @"[^A-Za-z0-9_]", "");
								}
								else if ( order_by.ToLower().EndsWith(" desc") )
								{
									order_by = order_by.Substring(0, order_by.Length - 5);
									order_by = " order by " + Regex.Replace(order_by, @"[^A-Za-z0-9_]", "");
								}
								else
								{
									order_by = " order by " + Regex.Replace(order_by, @"[^A-Za-z0-9_]", "");
								}
							}
							// 09/10/2009 Paul.  Apply custom paging. 
							if ( Crm.Config.allow_custom_paging() && Crm.Modules.CustomPaging(module_name) )
							{
								Sql.WindowResults(cmd, sTABLE_NAME, order_by, offset, max_results);
							}
							else
							{
								if ( !Sql.IsEmptyString(order_by) )
									cmd.CommandText += order_by;
							}
							CultureInfo ciEnglish = CultureInfo.CreateSpecificCulture("en-US");
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									if ( dt.Rows.Count > 0 )
									{
										// 02/16/2006 Paul.  Don't sort in the database as it provides a hacker another attempt at SQL-Injection. 
										// Bad sort values will just throw an exception here. 
										// 06/09/2008 Paul.  With large resultsets, sorting in ASP.NET is too slow.  Use Regex to protext against SQL-Injection. 
										//DataView dv = new DataView(dt);
										//dv.Sort = order_by;

										// 09/10/2009 Paul.  If using custom paging, then the result count is the row count. 
										if ( Crm.Config.allow_custom_paging() && Crm.Modules.CustomPaging(module_name) )
										{
											results.result_count = dt.Rows.Count;
											results.next_offset  = offset + results.result_count;
											// 09/10/2009 Paul.  The logic below can work for custom paging if we simply clear the offset. 
											offset = 0;
										}
										else
										{
											results.result_count = Math.Min(dt.Rows.Count - offset, max_results);
											results.next_offset  = offset + results.result_count;
										}
										
										// 05/08/2008 Paul.  If no select fields provided, then build the list with all fields in the resultset. 
										if ( select_fields.Length == 0 )
										{
											select_fields = new string[dt.Columns.Count];
											for ( int i=0; i < dt.Columns.Count; i++ )
											{
												select_fields[i] = dt.Columns[i].ColumnName;
											}
										}
										// 02/20/2006 Paul.  First initialize the array. 
										results.field_list = new field      [select_fields.Length];
										results.entry_list = new entry_value[results.result_count];
										for ( int i=0; i < select_fields.Length; i++ )
										{
											string sColumnName = select_fields[i];
											DataColumn col = dt.Columns[sColumnName];
											// 02/20/2006 Paul.  Then initialize each element in the array. 
											// 02/16/2006 Paul.  We don't have a mapping for the labels, so just return the column name. 
											// varchar, bool, datetime, int, text, blob
											results.field_list[i] = new field(sColumnName.ToLower(), col.DataType.ToString(), sColumnName, 0);
										}
										
										// 02/16/2006 Paul.  SugarCRM 3.5.1 returns all fields even though only a few were requested.  We will do the same. 
										int j = 0;
										bool bASSIGNED_USER_ID_Exists = dt.Columns.Contains("ASSIGNED_USER_ID");
										foreach ( DataRow row in dt.Rows )
										{
											if ( j >= offset && j < offset + results.result_count )
											{
												int nItem = j - offset;
												// 02/20/2006 Paul.  Then initialize each element in the array. 
												results.entry_list[nItem] = new entry_value();
												results.entry_list[nItem].id              = Sql.ToGuid(row["ID"]).ToString();
												results.entry_list[nItem].module_name     = module_name;
												// 02/20/2006 Paul.  First initialize the array. 
												results.entry_list[nItem].name_value_list = new name_value[dt.Columns.Count];
												int nColumn = 0;
												// 01/18/2010 Paul.  Apply ACL Field Security. 
												Guid gASSIGNED_USER_ID = Guid.Empty;
												if ( bASSIGNED_USER_ID_Exists )
													gASSIGNED_USER_ID = Sql.ToGuid(row["ASSIGNED_USER_ID"]);
												foreach ( DataColumn col in dt.Columns )
												{
													bool bIsReadable = true;
													// 01/18/2010 Paul.  Apply ACL Field Security. 
													if ( SplendidInit.bEnableACLFieldSecurity )
													{
														Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(module_name, col.ColumnName, gASSIGNED_USER_ID);
														bIsReadable = acl.IsReadable();
													}
													if ( bIsReadable )
													{
														// 02/20/2006 Paul.  Then initialize each element in the array. 
														// 08/17/2006 Paul.  We need to convert all dates to UniversalTime. 
														// 06/07/2009 Paul.  Information.IsDate looks at the value but we need to inspect the data type. 
														if ( col.DataType == typeof(System.DateTime) )
														{
															// 08/17/2006 Paul.  The time on the server and the time in the database are both considered ServerTime. 
															DateTime dtServerTime = Sql.ToDateTime(row[col.ColumnName]);
															// 08/17/2006 Paul.  We need a special function to convert to UniversalTime because it might already be in UniversalTime, based on m_bGMTStorage flag. 
															DateTime dtUniversalTime = T10n.ToUniversalTimeFromServerTime(dtServerTime);
															results.entry_list[nItem].name_value_list[nColumn] = new name_value(col.ColumnName.ToLower(), dtUniversalTime.ToString(CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat));
														}
														else
														{
															results.entry_list[nItem].name_value_list[nColumn] = new name_value(col.ColumnName.ToLower(), Sql.ToString(row[col.ColumnName]));
														}
													}
													else
													{
														results.entry_list[nItem].name_value_list[nColumn] = new name_value(col.ColumnName.ToLower(), String.Empty);
													}
													nColumn++;
												}
											}
											j++;
										}
									}
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						throw(new Exception("SOAP: Failed get_entry_list", ex));
					}
					finally
					{
						// 04/23/2011 Paul.  This is the rollback to protect against SQL injection. 
						trn.Rollback();
					}
				}
			}
			return results;
		}

		private string VerifyModuleName(string sMODULE_NAME)
		{
			string sTABLE_NAME = String.Empty;
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select *                         " + ControlChars.CrLf
				     + "  from vwMODULES                 " + ControlChars.CrLf
				     + " where MODULE_NAME = @MODULE_NAME" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@MODULE_NAME", sMODULE_NAME);
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						if ( rdr.Read() )
						{
							sTABLE_NAME = Sql.ToString(rdr["TABLE_NAME"]);
						}
						else
						{
							throw(new Exception("This module is not available on this server"));
						}
					}
				}
			}
			return sTABLE_NAME;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public get_entry_result get_entry(string session, string module_name, string id, string[] select_fields)
		{
			Guid gUSER_ID = GetSessionUserID(session);

			string sTABLE_NAME = VerifyModuleName(module_name);
			int nACLACCESS = Security.GetUserAccess(module_name, "list");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 06/27/2014 Paul.  We need to provide security around the tables accessed by SOAP.  Use the same REST rules. 
			sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "").ToUpper();
			// 03/18/2016 Paul.  Add manual join to custom field table. 
			bool   bHAS_CUSTOM = false;
			DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false);
			if ( dtSYNC_TABLES == null || dtSYNC_TABLES.Rows.Count == 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			else
			{
				DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
				string sVIEW_NAME = Sql.ToString (rowSYNC_TABLE["VIEW_NAME" ]);
				bool   bIS_SYSTEM = Sql.ToBoolean(rowSYNC_TABLE["IS_SYSTEM" ]);
				bHAS_CUSTOM = Sql.ToBoolean(rowSYNC_TABLE["HAS_CUSTOM"]);
				// 06/27/2014 Paul.  System tables should use the view for security reasons. 
				if ( bIS_SYSTEM )
					sTABLE_NAME = sVIEW_NAME;
			}

			get_entry_result results = new get_entry_result();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 05/04/2008 Paul.  Protect against SQL Injection. A table name will never have a space character.
				sTABLE_NAME = sTABLE_NAME.Replace(" ", "");
				sSQL = "select *" + ControlChars.CrLf
				     + "  from " + sTABLE_NAME + ControlChars.CrLf;
				//     + " where ID = @ID" + ControlChars.CrLf;
				// 03/18/2016 Paul.  Add manual join to custom field table. 
				if ( bHAS_CUSTOM )
				{
					sSQL += " inner join " + sTABLE_NAME + "_CSTM" + ControlChars.CrLf;
					sSQL += "         on " + sTABLE_NAME + "_CSTM.ID_C = " + sTABLE_NAME + ".ID" + ControlChars.CrLf;
				}
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
					Security.Filter(cmd, module_name, "view");
					Sql.AppendParameter(cmd, Sql.ToGuid(id), "ID", false);
					//Sql.AddParameter(cmd, "@ID", id);
					//if ( nACLACCESS == ACL_ACCESS.OWNER )
					//{
					//	// 09/01/2006 Paul.  Notes do not have an ASSIGNED_USER_ID. 
					//	// 01/20/2013 Paul.  ASSIGNED_USER_ID was added to notes table on 04/02/2012. 
					//	//if ( sTABLE_NAME != "NOTES" )
					//		Sql.AppendParameter(cmd, gUSER_ID, "ASSIGNED_USER_ID");
					//}
					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								if ( dt.Rows.Count > 0 )
								{
									// 05/08/2008 Paul.  If no select fields provided, then build the list with all fields in the resultset. 
									if ( select_fields.Length == 0 )
									{
										select_fields = new string[dt.Columns.Count];
										for ( int i=0; i < dt.Columns.Count; i++ )
										{
											select_fields[i] = dt.Columns[i].ColumnName;
										}
									}
									// 02/20/2006 Paul.  First initialize the array. 
									results.field_list = new field      [select_fields.Length];
									results.entry_list = new entry_value[select_fields.Length];
									DataRow row = dt.Rows[0];
									
									// 01/18/2010 Paul.  Apply ACL Field Security. 
									bool bASSIGNED_USER_ID_Exists = dt.Columns.Contains("ASSIGNED_USER_ID");
									Guid gASSIGNED_USER_ID = Guid.Empty;
									if ( bASSIGNED_USER_ID_Exists )
										gASSIGNED_USER_ID = Sql.ToGuid(row["ASSIGNED_USER_ID"]);
									for ( int i=0; i < select_fields.Length; i++ )
									{
										string sColumnName = select_fields[i];
										DataColumn col = dt.Columns[sColumnName];
										// 03/18/2016 Paul.  Generate a useful error if field not found. 
										if ( col == null )
										{
											throw(new Exception(sColumnName + " does not exist in " + sTABLE_NAME));
										}
										// 02/20/2006 Paul.  Then initialize each element in the array. 
										// varchar, bool, datetime, int, text, blob
										results.field_list[i] = new field(sColumnName.ToLower(), col.DataType.ToString(), sColumnName, 0);
										
										// 01/18/2010 Paul.  Apply ACL Field Security. 
										bool bIsReadable = true;
										if ( SplendidInit.bEnableACLFieldSecurity )
										{
											Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(module_name, col.ColumnName, gASSIGNED_USER_ID);
											bIsReadable = acl.IsReadable();
										}
										if ( bIsReadable )
										{
											// 02/20/2006 Paul.  Then initialize each element in the array. 
											results.entry_list[i] = new entry_value(id, module_name, sColumnName, Sql.ToString(row[sColumnName]));
										}
										else
										{
											results.entry_list[i] = new entry_value(id, module_name, sColumnName, String.Empty);
										}
									}
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						// 03/18/2016 Paul.  Correct error message. 
						throw(new Exception("SOAP: Failed get_entry", ex));
					}
				}
			}
			return results;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public get_entry_result get_entries(string session, string module_name, string[] ids, string[] select_fields)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			// 02/18/2008 Paul.  HttpRuntime.Cache is a better and faster way to get to the cache. 
			Guid gTIMEZONE = Sql.ToGuid(HttpRuntime.Cache.Get("soap.user.timezone." + gUSER_ID.ToString()));
			TimeZone T10n = TimeZone.CreateTimeZone(gTIMEZONE);

			string sTABLE_NAME = VerifyModuleName(module_name);
			int nACLACCESS = Security.GetUserAccess(module_name, "list");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 06/27/2014 Paul.  We need to provide security around the tables accessed by SOAP.  Use the same REST rules. 
			sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "").ToUpper();
			DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false);
			if ( dtSYNC_TABLES == null || dtSYNC_TABLES.Rows.Count == 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			else
			{
				DataRow rowSYNC_TABLE = dtSYNC_TABLES.Rows[0];
				string sVIEW_NAME = Sql.ToString (rowSYNC_TABLE["VIEW_NAME"]);
				bool   bIS_SYSTEM = Sql.ToBoolean(rowSYNC_TABLE["IS_SYSTEM"]);
				// 06/27/2014 Paul.  System tables should use the view for security reasons. 
				// 06/27/2014 Paul.  Don't need to use the view here because we are hard-coding the _Edit view. 
				//if ( bIS_SYSTEM )
				//	sTABLE_NAME = sVIEW_NAME;
			}

			get_entry_result results = new get_entry_result();
			// 02/19/2006 Paul.  Exit early if nothing to get.  We need to prevent fetching all recods. 
			if ( ids.Length == 0 )
				return results;

			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 02/16/2006 Paul.  Convert the table name to a VIEW.  We can do this because we don't want deleted records. 
				// 02/18/2006 Paul.  Use the Edit view as it will include description, content, etc. 
				sSQL = "select *" + ControlChars.CrLf
				     + "  from vw" + sTABLE_NAME + "_Edit" + ControlChars.CrLf;
				//     + " where 1 = 1" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
					Security.Filter(cmd, module_name, "view");
					// 02/19/2006 Paul.  Need to filter by the IDs povided. 
					Sql.AppendParameter(cmd, ids, "ID");
					//if ( nACLACCESS == ACL_ACCESS.OWNER )
					//{
					//	// 09/01/2006 Paul.  Notes do not have an ASSIGNED_USER_ID. 
					//	// 01/20/2013 Paul.  ASSIGNED_USER_ID was added to notes table on 04/02/2012. 
					//	//if ( sTABLE_NAME != "NOTES" )
					//		Sql.AppendParameter(cmd, gUSER_ID, "ASSIGNED_USER_ID");
					//}
					try
					{
						CultureInfo ciEnglish = CultureInfo.CreateSpecificCulture("en-US");
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								if ( dt.Rows.Count > 0 )
								{
									// 05/08/2008 Paul.  If no select fields provided, then build the list with all fields in the resultset. 
									if ( select_fields.Length == 0 )
									{
										select_fields = new string[dt.Columns.Count];
										for ( int i=0; i < dt.Columns.Count; i++ )
										{
											select_fields[i] = dt.Columns[i].ColumnName;
										}
									}
									// 02/20/2006 Paul.  First initialize the array. 
									results.field_list = new field      [select_fields.Length];
									results.entry_list = new entry_value[dt.Rows.Count];
									for ( int i=0; i < select_fields.Length; i++ )
									{
										string sColumnName = select_fields[i];
										DataColumn col = dt.Columns[sColumnName];
										// 02/21/2006 Paul.  Column may not exist.  For example, we don't return a MEETINGS.TIME_START. 
										if ( col != null )
										{
											// 02/20/2006 Paul.  Then initialize each element in the array. 
											// 02/16/2006 Paul.  We don't have a mapping for the labels, so just return the column name. 
											// varchar, bool, datetime, int, text, blob
											results.field_list[i] = new field(sColumnName.ToLower(), col.DataType.ToString(), sColumnName, 0);
										}
									}
									
									// 02/16/2006 Paul.  SugarCRM 3.5.1 returns all fields even though only a few were requested.  We will do the same. 
									int nItem = 0;
									bool bASSIGNED_USER_ID_Exists = dt.Columns.Contains("ASSIGNED_USER_ID");
									foreach ( DataRow row in dt.Rows )
									{
										// 02/20/2006 Paul.  Then initialize each element in the array. 
										results.entry_list[nItem] = new entry_value();
										results.entry_list[nItem].id              = Sql.ToGuid(row["ID"]).ToString();
										results.entry_list[nItem].module_name     = module_name;
										// 02/20/2006 Paul.  First initialize the array. 
										results.entry_list[nItem].name_value_list = new name_value[dt.Columns.Count];
										int nColumn = 0;
										// 01/18/2010 Paul.  Apply ACL Field Security. 
										Guid gASSIGNED_USER_ID = Guid.Empty;
										if ( bASSIGNED_USER_ID_Exists )
											gASSIGNED_USER_ID = Sql.ToGuid(row["ASSIGNED_USER_ID"]);
										foreach ( DataColumn col in dt.Columns )
										{
											// 01/18/2010 Paul.  Apply ACL Field Security. 
											bool bIsReadable = true;
											if ( SplendidInit.bEnableACLFieldSecurity )
											{
												Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(module_name, col.ColumnName, gASSIGNED_USER_ID);
												bIsReadable = acl.IsReadable();
											}
											if ( bIsReadable )
											{
												// 02/20/2006 Paul.  Then initialize each element in the array. 
												// 08/17/2006 Paul.  We need to convert all dates to UniversalTime. 
												// 06/07/2009 Paul.  Information.IsDate looks at the value but we need to inspect the data type. 
												if ( col.DataType == typeof(System.DateTime) )
												{
													// 08/17/2006 Paul.  The time on the server and the time in the database are both considered ServerTime. 
													DateTime dtServerTime = Sql.ToDateTime(row[col.ColumnName]);
													// 08/17/2006 Paul.  We need a special function to convert to UniversalTime because it might already be in UniversalTime, based on m_bGMTStorage flag. 
													DateTime dtUniversalTime = T10n.ToUniversalTimeFromServerTime(dtServerTime);
													results.entry_list[nItem].name_value_list[nColumn] = new name_value(col.ColumnName.ToLower(), dtUniversalTime.ToString(CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat));
												}
												else
												{
													results.entry_list[nItem].name_value_list[nColumn] = new name_value(col.ColumnName.ToLower(), Sql.ToString(row[col.ColumnName]));
												}
											}
											else
											{
												results.entry_list[nItem].name_value_list[nColumn] = new name_value(col.ColumnName.ToLower(), String.Empty);
											}
											nColumn++;
										}
										nItem++;
									}
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						throw(new Exception("SOAP: Failed get_entries", ex));
					}
				}
			}
			return results;
		}

		private bool DeleteEntry(name_value[] name_value_list)
		{
			bool bDelete = false;
			for ( int j = 0; j < name_value_list.Length; j++ )
			{
				if ( String.Compare(name_value_list[j].name, "deleted", true) == 0 )
				{
					if ( name_value_list[j].value == "1" )
						bDelete = true;
				}
			}
			return bDelete;
		}

		private string EntryDateTime(name_value[] name_value_list, string sDateField, string sTimeField)
		{
			string sDateTime = String.Empty;
			string sDate     = String.Empty;
			string sTime     = String.Empty;
			for ( int j = 0; j < name_value_list.Length; j++ )
			{
				if ( String.Compare(name_value_list[j].name, sDateField, true) == 0 )
					sDate = name_value_list[j].value;
				if ( String.Compare(name_value_list[j].name, sTimeField, true) == 0 )
					sTime = name_value_list[j].value;
			}
			sDateTime = sDate + " " + sTime;
			return sDateTime;
		}

		private void InitializeParameters(IDbConnection con, string sTABLE_NAME, Guid gID, IDbCommand cmdUpdate)
		{
			String sSQL = String.Empty;
			sSQL = "select *" + ControlChars.CrLf
			     + "  from vw" + sTABLE_NAME + "_Edit" + ControlChars.CrLf
			     + " where ID = @ID" + ControlChars.CrLf;
			using ( IDbCommand cmd = con.CreateCommand() )
			{
				cmd.CommandText = sSQL;
				Sql.AddParameter(cmd, "@ID", gID);
				try
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							if ( dt.Rows.Count > 0 )
							{
								DataRow row = dt.Rows[0];
								foreach ( DataColumn col in dt.Columns )
								{
									IDbDataParameter par = Sql.FindParameter(cmdUpdate, col.ColumnName);
									if ( par != null )
									{
										par.Value = row[col.ColumnName];
									}
								}
							}
						}
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				}
			}
		}

		private Guid FindID(name_value[] name_value_list)
		{
			Guid gID = Guid.Empty;
			for ( int j = 0; j < name_value_list.Length; j++ )
			{
				if ( String.Compare(name_value_list[j].name, "id", true) == 0 )
				{
					gID = Sql.ToGuid(name_value_list[j].value);
					break;
				}
			}
			return gID;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public set_entry_result set_entry(string session, string module_name, name_value[] name_value_list)
		{
			Guid gUSER_ID  = GetSessionUserID(session);
			// 02/18/2008 Paul.  HttpRuntime.Cache is a better and faster way to get to the cache. 
			Guid gTIMEZONE = Sql.ToGuid(HttpRuntime.Cache.Get("soap.user.timezone." + gUSER_ID.ToString()));
			TimeZone T10n = TimeZone.CreateTimeZone(gTIMEZONE);

			string sTABLE_NAME = VerifyModuleName(module_name);
			int nACLACCESS = Security.GetUserAccess(module_name, "edit");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 06/27/2014 Paul.  We need to provide security around the tables accessed by SOAP.  Use the same REST rules. 
			sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "").ToUpper();
			DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, true);
			if ( dtSYNC_TABLES == null || dtSYNC_TABLES.Rows.Count == 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}

			set_entry_result results = new set_entry_result();

			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				// 02/21/2006 Paul.  Delete operations come in as set_entry with deleted = 1. 
				if ( DeleteEntry(name_value_list) )
				{
					IDbCommand cmdDelete = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Delete");
					// 10/10/2006 Paul.  Use IDbDataParameter to be consistent. 
					foreach(IDbDataParameter par in cmdDelete.Parameters)
					{
						par.Value = DBNull.Value;
					}
					Sql.SetParameter(cmdDelete, "@MODIFIED_USER_ID", gUSER_ID.ToString());
					Guid gID = FindID(name_value_list);
					if ( gID != Guid.Empty )
					{
						Sql.SetParameter(cmdDelete, "@ID", gID.ToString());
						cmdDelete.ExecuteNonQuery();
					}
				}
				else
				{
					// 02/12/2010 Paul.  Use the Import procedures so that an Account will be created for a Contact. 
					IDbCommand cmdUpdate = null;
					try
					{
						cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Import");
					}
					catch
					{
						cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update");
					}
					IDbDataParameter parID = Sql.FindParameter(cmdUpdate, "@ID");
					// 06/04/2009 Paul.  If Team is required, then make sure to initialize the TEAM_ID.  Same is true for ASSIGNED_USER_ID. 
					bool bEnableTeamManagement  = Crm.Config.enable_team_management();
					bool bRequireTeamManagement = Crm.Config.require_team_management();
					bool bRequireUserAssignment = Crm.Config.require_user_assignment();
					// 10/10/2006 Paul.  Use IDbDataParameter to be consistent. 
					foreach(IDbDataParameter par in cmdUpdate.Parameters)
					{
						// 06/04/2009 Paul.  If Team is required, then make sure to initialize the TEAM_ID.  Same is true for ASSIGNED_USER_ID. 
						// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
						string sParameterName = Sql.ExtractDbName(cmdUpdate, par.ParameterName).ToUpper();
						if ( sParameterName == "TEAM_ID" && bEnableTeamManagement ) // 02/26/2011 Paul.  Ignore the Required flag. && bRequireTeamManagement )
							par.Value = Sql.ToDBGuid(Security.TEAM_ID);  // 02/26/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
						else if ( sParameterName == "ASSIGNED_USER_ID" ) // 02/26/2011 Paul.  Always set the Assigned User ID. && bRequireUserAssignment )
							par.Value = Sql.ToDBGuid(Security.USER_ID);  // 02/26/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
						// 02/20/2013 Paul.  We need to set the MODIFIED_USER_ID. 
						else if ( sParameterName == "MODIFIED_USER_ID" )
							par.Value = Sql.ToDBGuid(Security.USER_ID);
						else
							par.Value = DBNull.Value;
					}
					// 08/31/2006 Paul.  We need to initialize the values of any fields not provided. 
					// The stored procedure always updates all fields, so we need to make sure not to clear fields that are not provided. 
					// This problem was first noticed when the Outlook Plug-in kept clearing the ASSIGNED_USER_ID field. 
					Guid gASSIGNED_USER_ID = Guid.Empty;
					Guid gID = FindID(name_value_list);
					if ( gID != Guid.Empty )
					{
						// 08/31/2006 Paul.  If the ID is not found, then this must be a new 
						InitializeParameters(con, sTABLE_NAME, gID, cmdUpdate);
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						IDbDataParameter parASSIGNED_USER_ID = Sql.FindParameter(cmdUpdate, "@ASSIGNED_USER_ID");
						if ( parASSIGNED_USER_ID != null )
						{
							gASSIGNED_USER_ID = Sql.ToGuid(parASSIGNED_USER_ID.Value);
						}
					}
					Sql.SetParameter(cmdUpdate, "@MODIFIED_USER_ID", gUSER_ID.ToString());

					for ( int j = 0; j < name_value_list.Length; j++ )
					{
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						bool bIsWriteable = true;
						if ( SplendidInit.bEnableACLFieldSecurity )
						{
							Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(module_name, name_value_list[j].name.ToUpper(), gASSIGNED_USER_ID);
							bIsWriteable = acl.IsWriteable();
						}
						if ( bIsWriteable )
						{
							// 04/04/2006 Paul.  DATE_START & TIME_START need to be combined into DATE_TIME. 
							if ( name_value_list[j].name.ToUpper() == "TIME_START" )
							{
								// 04/04/2006 Paul.  Modules that have a TIME_START field are MEETINGS, CALLS, TASKS, EMAILS, EMAIL_MARKETING, PROJECT_TASK
								string sDateTime = EntryDateTime(name_value_list, "DATE_START", "TIME_START");
								if ( sTABLE_NAME == "TASKS" || sTABLE_NAME == "PROJECT_TASK" )
								{
									Sql.SetParameter(cmdUpdate, "@DATE_TIME_START", T10n.ToServerTimeFromUniversalTime(sDateTime));
								}
								else
								{
									Sql.SetParameter(cmdUpdate, "@DATE_TIME", T10n.ToServerTimeFromUniversalTime(sDateTime));
								}
							}
							// 04/04/2006 Paul.  DATE_DUE & TIME_DUE need to be combined into DATE_TIME_DUE. 
							else if ( name_value_list[j].name.ToUpper() == "TIME_DUE" )
							{
								// 04/04/2006 Paul.  Modules that have a TIME_DUE field are TASKS, PROJECT_TASK
								string sDateTime = EntryDateTime(name_value_list, "DATE_DUE", "TIME_DUE");
								Sql.SetParameter(cmdUpdate, "@DATE_TIME_DUE", T10n.ToServerTimeFromUniversalTime(sDateTime));
							}
							else if ( name_value_list[j].name.ToUpper() == "ACCOUNT_NAME" && String.Compare(module_name, "Contacts", true) == 0 )
							{
								// 01/20/2010 Paul.  If the account name is specified, then lookup the account ID or create the account. 
								Guid   gACCOUNT_ID   = Guid.Empty;
								string sACCOUNT_NAME = Sql.ToString(name_value_list[j].value);
								sACCOUNT_NAME = sACCOUNT_NAME.Trim();
								if ( !Sql.IsEmptyString(sACCOUNT_NAME) )
								{
									string sSQL = String.Empty;
									sSQL = "select ID          " + ControlChars.CrLf
									     + "  from vwACCOUNTS  " + ControlChars.CrLf
									     + " where NAME = @NAME" + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										// 01/20/2010 Paul.  We considered applying the Security Filter, but that would lead to duplicate account records. 
										Sql.AddParameter(cmd, "@NAME", sACCOUNT_NAME);
										gACCOUNT_ID = Sql.ToGuid(cmd.ExecuteScalar());
									}
									if ( Sql.IsEmptyGuid(gACCOUNT_ID) )
									{
										// 01/16/2012 Paul.  Assigned User ID and Team ID are now parameters. 
										SqlProcs.spACCOUNTS_New
											( ref gACCOUNT_ID
											, sACCOUNT_NAME
											, String.Empty
											, String.Empty
											, Security.USER_ID
											, Security.TEAM_ID
											, String.Empty
											// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
											, String.Empty   // ASSIGNED_SET_LIST
											);
									}
									if ( !Sql.IsEmptyGuid(gACCOUNT_ID) )
										Sql.SetParameter(cmdUpdate, "@ACCOUNT_ID", gACCOUNT_ID);
								}
							}
							else
							{
								Sql.SetParameter(cmdUpdate, "@" + name_value_list[j].name, name_value_list[j].value);
							}
						}
					}
					// 03/18/2016 Paul.  Wrap operation in a transaction to include the custom fields. 
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						cmdUpdate.Transaction = trn;
						// 03/18/2016 Paul.  Add support for custom fields. 
						try
						{
							cmdUpdate.ExecuteNonQuery();
							if ( parID != null )
							{
								results.id = Sql.ToString(parID.Value);
								// 03/18/2016 Paul.  Add support for custom fields. 
								gID = Sql.ToGuid(parID.Value);
								DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
								UpdateCustomFields(name_value_list, trn, gID, sTABLE_NAME, dtCustomFields);
							}
							trn.Commit();
						}
						catch
						{
							trn.Rollback();
							throw;
						}
					}
				}
			}
			return results;
		}

		// 03/18/2016 Paul.  Add support for custom fields. 
		private static void UpdateCustomFields(name_value[] name_value_list, IDbTransaction trn, Guid gID, string sTABLE_NAME, DataTable dtCustomFields)
		{
			if ( dtCustomFields.Rows.Count > 0 )
			{
				IDbConnection con = trn.Connection;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.Transaction = trn;
					cmd.CommandType = CommandType.Text;
					cmd.CommandText = "update " + sTABLE_NAME + "_CSTM" + ControlChars.CrLf;
					int nFieldIndex = 0;
					foreach(DataRow row in dtCustomFields.Rows)
					{
						string sNAME   = Sql.ToString(row["NAME"  ]).ToUpper();
						string sCsType = Sql.ToString(row["CsType"]);
						int    nMAX_SIZE = Sql.ToInteger(row["MAX_SIZE"]);
						for ( int j = 0; j < name_value_list.Length; j++ )
						{
							if ( String.Compare(sNAME, name_value_list[j].name, true) == 0 )
							{
								if ( nFieldIndex == 0 )
									cmd.CommandText += "   set ";
								else
									cmd.CommandText += "     , ";
								cmd.CommandText += sNAME + " = @" + sNAME + ControlChars.CrLf;
							
								string sVALUE = name_value_list[j].value;
								switch ( sCsType )
								{
									case "Guid"    :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToGuid    (sVALUE));  break;
									case "short"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToInteger (sVALUE));  break;
									case "Int32"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToInteger (sVALUE));  break;
									case "Int64"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToInteger (sVALUE));  break;
									case "float"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToFloat   (sVALUE));  break;
									case "decimal" :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToDecimal (sVALUE));  break;
									case "bool"    :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToBoolean (sVALUE));  break;
									case "DateTime":  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToDateTime(sVALUE));  break;
									default        :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToString  (sVALUE), nMAX_SIZE);  break;
								}
								nFieldIndex++;
							}
						}
					}
					if ( nFieldIndex > 0 )
					{
						cmd.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@ID_C", gID);
						cmd.ExecuteNonQuery();
					}
				}
			}
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public set_entries_result set_entries(string session, string module_name, name_value[][] name_value_lists)
		{
			Guid gUSER_ID  = GetSessionUserID(session);
			// 02/18/2008 Paul.  HttpRuntime.Cache is a better and faster way to get to the cache. 
			Guid gTIMEZONE = Sql.ToGuid(HttpRuntime.Cache.Get("soap.user.timezone." + gUSER_ID.ToString()));
			TimeZone T10n = TimeZone.CreateTimeZone(gTIMEZONE);

			string sTABLE_NAME = VerifyModuleName(module_name);
			int nACLACCESS = Security.GetUserAccess(module_name, "edit");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 06/27/2014 Paul.  We need to provide security around the tables accessed by SOAP.  Use the same REST rules. 
			sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "").ToUpper();
			DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, true);
			if ( dtSYNC_TABLES == null || dtSYNC_TABLES.Rows.Count == 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}

			set_entries_result results = new set_entries_result();
			results.ids = new string[name_value_lists.Length];

			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				IDbCommand cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update");
				IDbDataParameter parID = Sql.FindParameter(cmdUpdate, "@ID");
				
				// 06/04/2009 Paul.  If Team is required, then make sure to initialize the TEAM_ID.  Same is true for ASSIGNED_USER_ID. 
				bool bEnableTeamManagement  = Crm.Config.enable_team_management();
				bool bRequireTeamManagement = Crm.Config.require_team_management();
				bool bRequireUserAssignment = Crm.Config.require_user_assignment();
				for ( int i=0; i < name_value_lists.Length ; i++ )
				{
					name_value[] name_value_list = name_value_lists[i];
					// 10/10/2006 Paul.  Use IDbDataParameter to be consistent. 
					foreach(IDbDataParameter par in cmdUpdate.Parameters)
					{
						// 06/04/2009 Paul.  If Team is required, then make sure to initialize the TEAM_ID.  Same is true for ASSIGNED_USER_ID. 
						// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
						string sParameterName = Sql.ExtractDbName(cmdUpdate, par.ParameterName).ToUpper();
						if ( sParameterName == "TEAM_ID" && bEnableTeamManagement ) // 02/26/2011 Paul.  Ignore the Required flag. && bRequireTeamManagement )
							par.Value = Sql.ToDBGuid(Security.TEAM_ID);  // 02/26/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
						else if ( sParameterName == "ASSIGNED_USER_ID" ) // 02/26/2011 Paul.  Always set the Assigned User ID. && bRequireUserAssignment )
							par.Value = Sql.ToDBGuid(Security.USER_ID);  // 02/26/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
						// 02/20/2013 Paul.  We need to set the MODIFIED_USER_ID. 
						else if ( sParameterName == "MODIFIED_USER_ID" )
							par.Value = Sql.ToDBGuid(Security.USER_ID);
						else
							par.Value = DBNull.Value;
					}
					// 08/31/2006 Paul.  We need to initialize the values of any fields not provided. 
					// The stored procedure always updates all fields, so we need to make sure not to clear fields that are not provided. 
					// This problem was first noticed when the Outlook Plug-in kept clearing the ASSIGNED_USER_ID field. 
					Guid gASSIGNED_USER_ID = Guid.Empty;
					Guid gID = FindID(name_value_list);
					if ( gID != Guid.Empty )
					{
						// 08/31/2006 Paul.  If the ID is not found, then this must be a new 
						InitializeParameters(con, sTABLE_NAME, gID, cmdUpdate);
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						IDbDataParameter parASSIGNED_USER_ID = Sql.FindParameter(cmdUpdate, "@ASSIGNED_USER_ID");
						if ( parASSIGNED_USER_ID != null )
						{
							gASSIGNED_USER_ID = Sql.ToGuid(parASSIGNED_USER_ID.Value);
						}
					}
					Sql.SetParameter(cmdUpdate, "@MODIFIED_USER_ID", gUSER_ID.ToString());

					for ( int j = 0; j < name_value_lists[i].Length; j++ )
					{
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						bool bIsWriteable = true;
						if ( SplendidInit.bEnableACLFieldSecurity )
						{
							Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(module_name, name_value_list[j].name.ToUpper(), gASSIGNED_USER_ID);
							bIsWriteable = acl.IsWriteable();
						}
						if ( bIsWriteable )
						{
							// 04/04/2006 Paul.  DATE_START & TIME_START need to be combined into DATE_TIME. 
							if ( name_value_list[j].name.ToUpper() == "TIME_START" )
							{
								// MEETINGS, CALLS, TASKS, EMAILS, EMAIL_MARKETING, PROJECT_TASK
								string sDateTime = EntryDateTime(name_value_list, "DATE_START", "TIME_START");
								if ( sTABLE_NAME == "TASKS" || sTABLE_NAME == "PROJECT_TASK" )
								{
									Sql.SetParameter(cmdUpdate, "@DATE_TIME_START", T10n.ToServerTimeFromUniversalTime(sDateTime));
								}
								else
								{
									Sql.SetParameter(cmdUpdate, "@DATE_TIME", T10n.ToServerTimeFromUniversalTime(sDateTime));
								}
							}
							// 04/04/2006 Paul.  DATE_DUE & TIME_DUE need to be combined into DATE_TIME_DUE. 
							else if ( name_value_list[j].name.ToUpper() == "TIME_DUE" )
							{
								// TASKS, PROJECT_TASK
								string sDateTime = EntryDateTime(name_value_list, "DATE_DUE", "TIME_DUE");
								Sql.SetParameter(cmdUpdate, "@DATE_TIME_DUE", T10n.ToServerTimeFromUniversalTime(sDateTime));
							}
							else if ( name_value_list[j].name.ToUpper() == "ACCOUNT_NAME" && String.Compare(module_name, "Contacts", true) == 0 )
							{
								// 01/20/2010 Paul.  If the account name is specified, then lookup the account ID or create the account. 
								Guid   gACCOUNT_ID   = Guid.Empty;
								string sACCOUNT_NAME = Sql.ToString(name_value_list[j].value);
								sACCOUNT_NAME = sACCOUNT_NAME.Trim();
								if ( !Sql.IsEmptyString(sACCOUNT_NAME) )
								{
									string sSQL = String.Empty;
									sSQL = "select ID          " + ControlChars.CrLf
									     + "  from vwACCOUNTS  " + ControlChars.CrLf
									     + " where NAME = @NAME" + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										// 01/20/2010 Paul.  We considered applying the Security Filter, but that would lead to duplicate account records. 
										Sql.AddParameter(cmd, "@NAME", sACCOUNT_NAME);
										gACCOUNT_ID = Sql.ToGuid(cmd.ExecuteScalar());
									}
									if ( Sql.IsEmptyGuid(gACCOUNT_ID) )
									{
										// 01/16/2012 Paul.  Assigned User ID and Team ID are now parameters. 
										SqlProcs.spACCOUNTS_New
											( ref gACCOUNT_ID
											, sACCOUNT_NAME
											, String.Empty
											, string.Empty
											, Security.USER_ID
											, Security.TEAM_ID
											, String.Empty
											// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
											, String.Empty      // ASSIGNED_SET_LIST
											);
									}
									if ( !Sql.IsEmptyGuid(gACCOUNT_ID) )
										Sql.SetParameter(cmdUpdate, "@ACCOUNT_ID", gACCOUNT_ID);
								}
							}
							else
							{
								Sql.SetParameter(cmdUpdate, "@" + name_value_list[j].name, name_value_list[j].value);
							}
						}
					}
					cmdUpdate.ExecuteNonQuery();

					if ( parID != null )
					{
						results.ids[i] = Sql.ToString(parID.Value);
					}
				}
			}
			return results;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public set_entry_result set_note_attachment(string session, note_attachment note)
		{
			Guid   gUSER_ID        = GetSessionUserID(session);
			Guid   gNOTE_ID        = Sql.ToGuid(note.id);
			string sFILENAME       = Path.GetFileName (note.filename);
			string sFILE_EXT       = Path.GetExtension(sFILENAME);
			string sFILE_MIME_TYPE = "application/octet-stream";
			// 04/24/2011 Paul.  Lets correct some of the most populate file types. 
			switch ( sFILE_EXT.ToLower() )
			{
				case "docx":  sFILE_MIME_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"  ;  break;
				case "xlsx":  sFILE_MIME_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"        ;  break;
				case "pptx":  sFILE_MIME_TYPE = "application/vnd.openxmlformats-officedocument.presentationml.presentation";  break;
				case "doc" :  sFILE_MIME_TYPE = "application/msword"           ;  break;
				case "xls" :  sFILE_MIME_TYPE = "application/vnd.ms-excel"     ;  break;
				case "ppt" :  sFILE_MIME_TYPE = "application/vnd.ms-powerpoint";  break;
				case "txt" :  sFILE_MIME_TYPE = "text/plain"                   ;  break;
				case "xml" :  sFILE_MIME_TYPE = "text/xml"                     ;  break;
				case "gif" :  sFILE_MIME_TYPE = "image/gif"                    ;  break;
				case "jpg" :  sFILE_MIME_TYPE = "image/jpeg"                   ;  break;
				case "png" :  sFILE_MIME_TYPE = "image/png"                    ;  break;
				case "pdf" :  sFILE_MIME_TYPE = "application/pdf"              ;  break;
			}
			
			int nACLACCESS = Security.GetUserAccess("Notes", "edit");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}

			set_entry_result result = new set_entry_result();
			byte[] byData = Convert.FromBase64String(note.file);
			// 02/20/2006 Paul.  Try and reduce the memory requirements by releasing the original data as soon as possible. 
			note.file = null;
			using ( MemoryStream stm = new System.IO.MemoryStream(byData) )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					bool bFound = false;
					//Guid gASSIGNED_USER_ID = Guid.Empty;

					// 09/01/2006 Paul.  Notes do not have an ASSIGNED_USER_ID. 
					// 01/24/2013 Paul.  ASSIGNED_USER_ID was added to notes table on 04/02/2012. 
					string sSQL = String.Empty;
					sSQL = "select *           " + ControlChars.CrLf
					     + "  from vwNOTES_Edit" + ControlChars.CrLf;
					//     + " where ID = @ID    " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						//Sql.AddParameter(cmd, "@ID", gNOTE_ID);
						// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
						Security.Filter(cmd, "Notes", "edit");
						Sql.AppendParameter(cmd, gNOTE_ID, "ID", false);
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							if ( rdr.Read() )
							{
								//gASSIGNED_USER_ID = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
								bFound = true;
							}
						}
					}
					// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
					//if ( nACLACCESS != ACL_ACCESS.OWNER || (nACLACCESS == ACL_ACCESS.OWNER  && gASSIGNED_USER_ID == gUSER_ID) )
					if ( bFound )
					{
						// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								Guid gAttachmentID = Guid.Empty;
								SqlProcs.spNOTE_ATTACHMENTS_Insert(ref gAttachmentID, gNOTE_ID, note.filename, sFILENAME, sFILE_EXT, sFILE_MIME_TYPE, trn);
								// 11/06/2010 Paul.  Move LoadFile() to Crm.NoteAttachments. 
								Crm.NoteAttachments.LoadFile(gAttachmentID, stm, trn);
								trn.Commit();
								// 04/24/2011 Paul.  Was not setting the ID. 
								result.id = gAttachmentID.ToString();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
								throw ( new Exception(ex.Message) );
							}
						}
					}
				}
			}
			byData = null;
			return result;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public return_note_attachment get_note_attachment(string session, string id)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			if ( gUSER_ID != Guid.Empty )
			{
				throw(new Exception("Method not implemented."));
			}
			return null;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public error_value relate_note_to_module(string session, string note_id, string module_name, string module_id)
		{
			Guid   gUSER_ID     = GetSessionUserID(session);
			Guid   gNOTE_ID     = Sql.ToGuid(note_id);
			string sPARENT_TYPE = module_name;
			Guid   gPARENT_ID   = Guid.Empty;
			Guid   gCONTACT_ID  = Guid.Empty;
			if ( String.Compare(sPARENT_TYPE, "Contacts", true) == 0 )
				gCONTACT_ID = Sql.ToGuid(module_id);
			else
				gPARENT_ID = Sql.ToGuid(module_id);

			int nACLACCESS = Security.GetUserAccess("Notes", "edit");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}

			error_value results = new error_value();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				bool bFound = false;
				string sNAME             = String.Empty;
				string sDESCRIPTION      = String.Empty;
				Guid   gASSIGNED_USER_ID = Guid.Empty;
				Guid   gTEAM_ID          = Guid.Empty;
				string sTEAM_SET_LIST    = String.Empty;
				string sSQL;
				sSQL = "select *           " + ControlChars.CrLf
				     + "  from vwNOTES_Edit" + ControlChars.CrLf;
				//     + " where ID = @ID    " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					//Sql.AddParameter(cmd, "@ID", gNOTE_ID);
					// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
					Security.Filter(cmd, "Notes", "edit");
					Sql.AppendParameter(cmd, gNOTE_ID, "ID", false);
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						if ( rdr.Read() )
						{
							sNAME             = Sql.ToString(rdr["NAME"            ]);
							sDESCRIPTION      = Sql.ToString(rdr["DESCRIPTION"     ]);
							// 09/01/2006 Paul.  Notes do not have an ASSIGNED_USER_ID. 
							// 01/24/2013 Paul.  ASSIGNED_USER_ID was added to notes table on 04/02/2012. 
							gASSIGNED_USER_ID = Sql.ToGuid  (rdr["ASSIGNED_USER_ID"]);
							gTEAM_ID          = Sql.ToGuid  (rdr["TEAM_ID"         ]);
							sTEAM_SET_LIST    = Sql.ToString(rdr["TEAM_SET_LIST"   ]);
							bFound = true;
						}
					}
				}
				// 05/18/2014 Paul.  Use Security.Filter() so that team management gets applied appropriately. 
				//if ( nACLACCESS != ACL_ACCESS.OWNER || (nACLACCESS == ACL_ACCESS.OWNER  && gASSIGNED_USER_ID == gUSER_ID) )
				if ( bFound )
				{
					// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
					SqlProcs.spNOTES_Update
						( ref gNOTE_ID
						, sNAME
						, sPARENT_TYPE
						, gPARENT_ID
						, gCONTACT_ID
						, sDESCRIPTION
						, gTEAM_ID
						, sTEAM_SET_LIST
						, gASSIGNED_USER_ID
						// 05/17/2017 Paul.  Add Tags module. 
						, String.Empty  // TAG_SET_NAME
						// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
						, false         // IS_PRIVATE
						// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						, String.Empty  // ASSIGNED_SET_LIST
						);
				}
			}

			return results;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public get_entry_result get_related_notes(string session, string module_name, string module_id, string[] select_fields)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			if ( gUSER_ID != Guid.Empty )
			{
				throw(new Exception("Method not implemented."));
			}
			return null;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public module_fields get_module_fields(string session, string module_name)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			if ( gUSER_ID != Guid.Empty )
			{
				// 04/23/2011 Paul.  Add support for get_module_fields() so that it can be used by the Word Plug-in. 
				module_fields lst = new module_fields();
				lst.module_name = module_name;
				
				L10N L10n = new L10N("en-US");
				string sTABLE_NAME = VerifyModuleName(module_name   );
				int nACLACCESS = Security.GetUserAccess(module_name, "list");
				if ( nACLACCESS < 0 )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				// 06/27/2014 Paul.  We need to provide security around the tables accessed by SOAP.  Use the same REST rules. 
				sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "").ToUpper();
				DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false);
				if ( dtSYNC_TABLES == null || dtSYNC_TABLES.Rows.Count == 0 )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				
				List<field> flds = new List<field>();
				// 04/23/2011 Paul.  It is important that we get the view and not the base table 
				// as that is what will be used when generating the merge. 
				DataTable dt = SplendidCache.SqlColumns("vw" + sTABLE_NAME);
				foreach ( DataRow row in dt.Rows )
				{
					bool bIsReadable = true;
					if ( SplendidInit.bEnableACLFieldSecurity )
					{
						Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(module_name, Sql.ToString(row["ColumnName"]), Guid.Empty);
						bIsReadable = acl.IsReadable();
					}
					if ( bIsReadable )
					{
						field fld = new field();
						fld.name  = Sql.ToString(row["ColumnName"]);
						fld.type  = Sql.ToString(row["CsType"    ]);
						fld.label = L10n.Term(module_name + ".LBL_" + fld.name).Replace(":", "");
						flds.Add(fld);
					}
				}
				lst.module_fields1 = flds.ToArray();
				return lst;
			}
			return null;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public module_list get_available_modules(string session)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			if ( gUSER_ID != Guid.Empty )
			{
				// 04/23/2011 Paul.  Add support for get_available_modules() so that it can be used by the Word Plug-in. 
				module_list lst = new module_list();
				lst.modules = SplendidCache.AccessibleModules(HttpContext.Current, gUSER_ID).ToArray();
				return lst;
			}
			return null;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public error_value update_portal_user(string session, string portal_name, name_value[] name_value_list)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			if ( gUSER_ID != Guid.Empty )
			{
				throw(new Exception("Method not implemented."));
			}
			return null;
		}

		// 02/16/2006 Paul.  The query string is expected to be in a very specific format. 
		// string sDateQuery = "date_start > '" + dtStartDate.ToUniversalTime().ToString("yyyy/MM/dd HH:mm:ss") + "' AND date_start < '" + dtEndDate.ToUniversalTime().ToString("yyyy/MM/dd HH:mm:ss") + "'";
		private static void ParseDateRange(string sQuery, string sField, TimeZone T10n, ref DateTime dtBeginDate, ref DateTime dtEndDate)
		{
			dtBeginDate = DateTime.MinValue;
			dtEndDate   = DateTime.MinValue;
			sQuery = sQuery.ToUpper();
			// 02/16/ 2006 Paul.  Remove excess whitespace. 
			Regex r = new Regex(@"[^\w]+");
			sQuery = r.Replace(sQuery, " ");
			// 03/19/2006 Paul.  Use VB split as the C# split will split on each character. 
			string[] aQuery = Strings.Split(sQuery, " AND ", -1, CompareMethod.Text);
			foreach ( string s in aQuery )
			{
				if ( s.StartsWith("DATE_START > ") )
				{
					string sDate = s.Substring("DATE_START > ".Length);
					sDate = sDate.Replace("\'", "");
					dtBeginDate = DateTime.Parse(sDate);
					// 04/04/2006 Paul.  Make sure to convert to server time. 
					dtBeginDate = T10n.ToServerTimeFromUniversalTime(dtBeginDate);
				}
				else if ( s.StartsWith("DATE_START < ") )
				{
					string sDate = s.Substring("DATE_START < ".Length);
					sDate = sDate.Replace("\'", "");
					dtEndDate = DateTime.Parse(sDate);
					// 04/04/2006 Paul.  Make sure to convert to server time. 
					dtEndDate = T10n.ToServerTimeFromUniversalTime(dtEndDate);
				}
			}
		}

		/*
		<tns:sync_get_modified_relationships>
			<session xsi:type="xsd:string">e7b36ceb478224f55fec23ed2febc673</session>
			<module_name xsi:type="xsd:string">Users</module_name>
			<related_module xsi:type="xsd:string">Contacts</related_module>
			<from_date xsi:type="xsd:string">2007-06-20 01:19:54</from_date>
			<to_date xsi:type="xsd:string">2007-06-20 01:21:59</to_date>
			<offset xsi:type="xsd:int">0</offset>
			<max_results xsi:type="xsd:int">3000</max_results>
			<deleted xsi:type="xsd:int">0</deleted>
			<module_id xsi:type="xsd:string">1</module_id>
			<select_fields href="#id1" />
			<ids href="#id2" />
			<relationship_name xsi:type="xsd:string">contacts_users</relationship_name>
			<deletion_date xsi:type="xsd:string">2007-06-20 01:19:52</deletion_date>
			<php_serialize xsi:type="xsd:int">0</php_serialize>
		</tns:sync_get_modified_relationships>
		<soapenc:Array id="id1" soapenc:arrayType="xsd:string[6]">
			<Item>id</Item>
			<Item>date_modified</Item>
			<Item>deleted</Item>
			<Item>first_name</Item>
			<Item>last_name</Item>
			<Item>rt.deleted synced</Item>
		</soapenc:Array>
		<soapenc:Array id="id2" soapenc:arrayType="xsd:string[0]" />
		*/
		// 06/19/2007 Paul.  Starting with version 4.2, SugarCRM uses a function that optimizes syncing. 
		// 06/19/2007 Paul.  Starting with version 4.5.1d, SugarCRM no longer allows get_relationships() to get user/contact relationships. 
		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public get_entry_list_result_encoded sync_get_modified_relationships(string session, string module_name, string related_module, string from_date, string to_date, int offset, int max_results, int deleted, string module_id, string[] select_fields, string[] ids, string relationship_name, string deletion_date, int php_serialize)
		{
			Guid gUSER_ID  = GetSessionUserID(session);
			Guid gTIMEZONE = Sql.ToGuid(HttpRuntime.Cache.Get("soap.user.timezone." + gUSER_ID.ToString()));
			TimeZone T10n = TimeZone.CreateTimeZone(gTIMEZONE);

			string sTABLE_NAME = VerifyModuleName(module_name   );
			int nACLACCESS = Security.GetUserAccess(module_name, "list");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 06/27/2014 Paul.  We need to provide security around the tables accessed by SOAP.  Use the same REST rules. 
			sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "").ToUpper();
			DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false);
			if ( dtSYNC_TABLES == null || dtSYNC_TABLES.Rows.Count == 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			
			sTABLE_NAME = VerifyModuleName(related_module);
			nACLACCESS = Security.GetUserAccess(related_module, "list");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 06/27/2014 Paul.  We need to provide security around the tables accessed by SOAP.  Use the same REST rules. 
			sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "").ToUpper();
			dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false);
			if ( dtSYNC_TABLES == null || dtSYNC_TABLES.Rows.Count == 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}

			get_entry_list_result_encoded results = new get_entry_list_result_encoded();
			results.error.name        = "not supported";
			results.error.number      = "-1";
			results.error.description = "sync_get_modified_relationships is not supported at this time";
			return results;
		}


		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public get_relationships_result get_relationships(string session, string module_name, string module_id, string related_module, string related_module_query, int deleted)
		{
			Guid gUSER_ID  = GetSessionUserID(session);
			Guid gTIMEZONE = Sql.ToGuid(HttpRuntime.Cache.Get("soap.user.timezone." + gUSER_ID.ToString()));
			TimeZone T10n = TimeZone.CreateTimeZone(gTIMEZONE);

			string sTABLE_NAME = VerifyModuleName(module_name   );
			int nACLACCESS = Security.GetUserAccess(module_name, "list");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 06/27/2014 Paul.  We need to provide security around the tables accessed by SOAP.  Use the same REST rules. 
			sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "").ToUpper();
			DataTable dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false);
			if ( dtSYNC_TABLES == null || dtSYNC_TABLES.Rows.Count == 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			
			sTABLE_NAME = VerifyModuleName(related_module);
			nACLACCESS = Security.GetUserAccess(related_module, "list");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			// 06/27/2014 Paul.  We need to provide security around the tables accessed by SOAP.  Use the same REST rules. 
			sTABLE_NAME = Regex.Replace(sTABLE_NAME, @"[^A-Za-z0-9_]", "").ToUpper();
			dtSYNC_TABLES = SplendidCache.RestTables(sTABLE_NAME, false);
			if ( dtSYNC_TABLES == null || dtSYNC_TABLES.Rows.Count == 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}

			get_relationships_result results = new get_relationships_result();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 02/16/2006 Paul.  Providing a way to directly access tables is a hacker's dream.  
				// We will not do that here.  We will require that all relationships be defined in a SQL view. 
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					switch ( module_name )
					{
						case "Contacts":
						{
							switch ( related_module )
							{
								case "Calls":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwCONTACTS_CALLS_Soap   " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										DateTime dtBeginDate = DateTime.MinValue;
										DateTime dtEndDate   = DateTime.MinValue;
										ParseDateRange(related_module_query, "DATE_START", T10n, ref dtBeginDate, ref dtEndDate);
										if ( dtBeginDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START > @BEGIN_DATE" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@BEGIN_DATE", dtBeginDate);
										}
										if ( dtEndDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START < @END_DATE  " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@END_DATE"  , dtEndDate  );
										}
									}
									break;
								}
								case "Meetings":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwCONTACTS_MEETINGS_Soap" + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										DateTime dtBeginDate = DateTime.MinValue;
										DateTime dtEndDate   = DateTime.MinValue;
										ParseDateRange(related_module_query, "DATE_START", T10n, ref dtBeginDate, ref dtEndDate);
										if ( dtBeginDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START > @BEGIN_DATE" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@BEGIN_DATE", dtBeginDate);
										}
										if ( dtEndDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START < @END_DATE  " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@END_DATE"  , dtEndDate  );
										}
									}
									break;
								}
								case "Users":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwCONTACTS_USERS_Soap   " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										throw(new Exception(String.Format("A related_module_query is not allowed at this time.", module_name, related_module)));
									}
									break;
								}
								default:
								{
									throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", module_name, related_module)));
								}
							}
							break;
						}
						case "Users":
						{
							switch ( related_module )
							{
								case "Calls":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwUSERS_CALLS_Soap      " + ControlChars.CrLf
									     + " where PRIMARY_ID  = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										DateTime dtBeginDate = DateTime.MinValue;
										DateTime dtEndDate   = DateTime.MinValue;
										ParseDateRange(related_module_query, "DATE_START", T10n, ref dtBeginDate, ref dtEndDate);
										if ( dtBeginDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START > @BEGIN_DATE" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@BEGIN_DATE", dtBeginDate);
										}
										if ( dtEndDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START < @END_DATE  " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@END_DATE"  , dtEndDate  );
										}
									}
									break;
								}
								case "Meetings":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwUSERS_MEETINGS_Soap   " + ControlChars.CrLf
									     + " where PRIMARY_ID  = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										DateTime dtBeginDate = DateTime.MinValue;
										DateTime dtEndDate   = DateTime.MinValue;
										ParseDateRange(related_module_query, "DATE_START", T10n, ref dtBeginDate, ref dtEndDate);
										if ( dtBeginDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START > @BEGIN_DATE" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@BEGIN_DATE", dtBeginDate);
										}
										if ( dtEndDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START < @END_DATE  " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@END_DATE"  , dtEndDate  );
										}
									}
									break;
								}
								case "Contacts":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwUSERS_CONTACTS_Soap   " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										throw(new Exception(String.Format("A related_module_query is not allowed at this time.", module_name, related_module)));
									}
									break;
								}
								// 02/01/2009 Paul.  Add Users/Tasks relationship for the new Outlook plug-in. 
								case "Tasks":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwUSERS_TASKS_Soap      " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										throw(new Exception(String.Format("A related_module_query is not allowed at this time.", module_name, related_module)));
									}
									break;
								}
								default:
								{
									throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", module_name, related_module)));
								}
							}
							break;
						}
						// 02/01/2009 Paul.  Add Users/Tasks relationship for the new Outlook plug-in. 
						case "Tasks":
						{
							switch ( related_module )
							{
								case "Users":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwTASKS_USERS_Soap      " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										throw(new Exception(String.Format("A related_module_query is not allowed at this time.", module_name, related_module)));
									}
									break;
								}
								default:
								{
									throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", module_name, related_module)));
								}
							}
							break;
						}
						case "Meetings":
						{
							switch ( related_module )
							{
								// 04/01/2012 Paul.  Add Calls/Leads relationship. 
								case "Leads":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwMEETINGS_LEADS_Soap   " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										DateTime dtBeginDate = DateTime.MinValue;
										DateTime dtEndDate   = DateTime.MinValue;
										ParseDateRange(related_module_query, "DATE_START", T10n, ref dtBeginDate, ref dtEndDate);
										if ( dtBeginDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START > @BEGIN_DATE" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@BEGIN_DATE", dtBeginDate);
										}
										if ( dtEndDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START < @END_DATE  " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@END_DATE"  , dtEndDate  );
										}
									}
									break;
								}
								case "Contacts":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwMEETINGS_CONTACTS_Soap" + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										DateTime dtBeginDate = DateTime.MinValue;
										DateTime dtEndDate   = DateTime.MinValue;
										ParseDateRange(related_module_query, "DATE_START", T10n, ref dtBeginDate, ref dtEndDate);
										if ( dtBeginDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START > @BEGIN_DATE" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@BEGIN_DATE", dtBeginDate);
										}
										if ( dtEndDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START < @END_DATE  " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@END_DATE"  , dtEndDate  );
										}
									}
									break;
								}
								case "Users":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwMEETINGS_USERS_Soap   " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										DateTime dtBeginDate = DateTime.MinValue;
										DateTime dtEndDate   = DateTime.MinValue;
										ParseDateRange(related_module_query, "DATE_START", T10n, ref dtBeginDate, ref dtEndDate);
										if ( dtBeginDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START > @BEGIN_DATE" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@BEGIN_DATE", dtBeginDate);
										}
										if ( dtEndDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START < @END_DATE  " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@END_DATE"  , dtEndDate  );
										}
									}
									break;
								}
								default:
								{
									throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", module_name, related_module)));
								}
							}
							break;
						}
						case "Calls":
						{
							switch ( related_module )
							{
								// 04/01/2012 Paul.  Add Calls/Leads relationship. 
								case "Leads":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwCALLS_LEADS_Soap      " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										DateTime dtBeginDate = DateTime.MinValue;
										DateTime dtEndDate   = DateTime.MinValue;
										ParseDateRange(related_module_query, "DATE_START", T10n, ref dtBeginDate, ref dtEndDate);
										if ( dtBeginDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START > @BEGIN_DATE" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@BEGIN_DATE", dtBeginDate);
										}
										if ( dtEndDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START < @END_DATE  " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@END_DATE"  , dtEndDate  );
										}
									}
									break;
								}
								case "Contacts":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwCALLS_CONTACTS_Soap   " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										DateTime dtBeginDate = DateTime.MinValue;
										DateTime dtEndDate   = DateTime.MinValue;
										ParseDateRange(related_module_query, "DATE_START", T10n, ref dtBeginDate, ref dtEndDate);
										if ( dtBeginDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START > @BEGIN_DATE" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@BEGIN_DATE", dtBeginDate);
										}
										if ( dtEndDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START < @END_DATE  " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@END_DATE"  , dtEndDate  );
										}
									}
									break;
								}
								case "Users":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwCALLS_USERS_Soap      " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										DateTime dtBeginDate = DateTime.MinValue;
										DateTime dtEndDate   = DateTime.MinValue;
										ParseDateRange(related_module_query, "DATE_START", T10n, ref dtBeginDate, ref dtEndDate);
										if ( dtBeginDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START > @BEGIN_DATE" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@BEGIN_DATE", dtBeginDate);
										}
										if ( dtEndDate != DateTime.MinValue )
										{
											cmd.CommandText += "   and DATE_START < @END_DATE  " + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@END_DATE"  , dtEndDate  );
										}
									}
									break;
								}
								default:
								{
									throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", module_name, related_module)));
								}
							}
							break;
						}
						case  "Accounts":
						{
							switch ( related_module )
							{
								case "Contacts":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwACCOUNTS_CONTACTS_Soap" + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										throw(new Exception(String.Format("A related_module_query is not allowed at this time.", module_name, related_module)));
									}
									break;
								}
								case "Users":
								{
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwACCOUNTS_USERS_Soap   " + ControlChars.CrLf
									     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
									     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
									Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
									if ( !Sql.IsEmptyString(related_module_query) )
									{
										throw(new Exception(String.Format("A related_module_query is not allowed at this time.", module_name, related_module)));
									}
									break;
								}
								default:
								{
									throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", module_name, related_module)));
								}
							}
							break;
						}
						default:
						{
							//throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", module_name, related_module)));
							
							// 05/16/2011 Paul.  The Word Plug-in needs to have access to other relationships. 
							string sMODULE_TABLE  = Crm.Modules.TableName(module_name   );
							string sRELATED_TABLE = Crm.Modules.TableName(related_module);
							sSQL = "select *                       " + ControlChars.CrLf
							     + "  from vw" + sMODULE_TABLE + "_" + sRELATED_TABLE + "_Soap" + ControlChars.CrLf
							     + " where PRIMARY_ID = @PRIMARY_ID" + ControlChars.CrLf
							     + "   and DELETED    = @DELETED   " + ControlChars.CrLf;
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@PRIMARY_ID", module_id           );
							Sql.AddParameter(cmd, "@DELETED"   , Math.Min(deleted, 1));
							if ( !Sql.IsEmptyString(related_module_query) )
							{
								throw(new Exception(String.Format("A related_module_query is not allowed at this time.", module_name, related_module)));
							}
							break;
						}
					}

					try
					{
						CultureInfo ciEnglish = CultureInfo.CreateSpecificCulture("en-US");
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								if ( dt.Rows.Count > 0 )
								{
									results.ids = new id_mod[dt.Rows.Count];
									int i = 0;
									foreach ( DataRow row in dt.Rows )
									{
										results.ids[i] = new id_mod();
										results.ids[i].id            = Sql.ToString  (row["RELATED_ID"   ]);
										results.ids[i].deleted       = Sql.ToInteger (row["DELETED"      ]);
										// 06/13/2006 Paul.  Italian has a problem with the time separator.  Use the value from the culture from CalendarControl.SqlDateTimeFormat. 
										// 06/14/2006 Paul.  The Italian problem was that it was using the culture separator, but DataView only supports the en-US format. 
										// 08/17/2006 Paul.  The time on the server and the time in the database are both considered ServerTime. 
										DateTime dtDATE_MODIFIED_ServerTime = Sql.ToDateTime(row["DATE_MODIFIED"]);
										// 08/17/2006 Paul.  We need a special function to convert to UniversalTime because it might already be in UniversalTime, based on m_bGMTStorage flag. 
										DateTime dtDATE_MODIFIED_UniversalTime = T10n.ToUniversalTimeFromServerTime(dtDATE_MODIFIED_ServerTime);
										results.ids[i].date_modified = dtDATE_MODIFIED_UniversalTime.ToString(CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat);
										i++;
									}
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						throw(new Exception("SOAP: Failed get_relationships", ex));
					}
				}
			}
			return results;
		}

		private void SetRelationship(string sMODULE1, string sMODULE1_ID, string sMODULE2, string sMODULE2_ID)
		{
			switch ( sMODULE1 )
			{
				case "Contacts":
				{
					Guid gCONTACT_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						case "Calls":
						{
							Guid gCALL_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spCALLS_CONTACTS_Update(gCALL_ID, gCONTACT_ID, false, String.Empty);
							break;
						}
						case "Meetings":
						{
							Guid gMEETING_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spMEETINGS_CONTACTS_Update(gMEETING_ID, gCONTACT_ID, false, String.Empty);
							break;
						}
						case "Users":
						{
							Guid gUSER_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not defined. 
							// 05/14/2007 Paul.  The SugarCRM plug-in technique for unsyncing a contact is to send NULL as the USER_ID. 
							// 09/15/2015 Paul.  Add SERVICE_NAME to separate Exchange Folders from Contacts Sync. 
							if ( Sql.IsEmptyGuid(gUSER_ID) )
								SqlProcs.spCONTACTS_USERS_Delete(gCONTACT_ID, Security.USER_ID, String.Empty);
							else
								SqlProcs.spCONTACTS_USERS_Update(gCONTACT_ID, gUSER_ID, String.Empty);
							break;
						}
						case "Emails":
						{
							Guid gEMAIL_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spEMAILS_CONTACTS_Update(gEMAIL_ID, gCONTACT_ID);
							break;
						}
						// 08/17/2006 Paul.  New relationships. 
						case "Accounts":
						{
							Guid gACCOUNT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spACCOUNTS_CONTACTS_Update(gACCOUNT_ID, gCONTACT_ID);
							break;
						}
						case "Bugs":
						{
							Guid gBUG_ID = Sql.ToGuid(sMODULE2_ID);
							// 10/03/2009 Paul.  The IDs were reversed, generating a foreign key error. 
							SqlProcs.spCONTACTS_BUGS_Update(gCONTACT_ID, gBUG_ID, String.Empty);
							break;
						}
						case "Cases":
						{
							Guid gCASE_ID = Sql.ToGuid(sMODULE2_ID);
							// 10/03/2009 Paul.  The IDs were reversed, generating a foreign key error. 
							SqlProcs.spCONTACTS_CASES_Update(gCONTACT_ID, gCASE_ID, String.Empty);
							break;
						}
						case "Contract":
						{
							Guid gCONTRACT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spCONTRACTS_CONTACTS_Update(gCONTRACT_ID, gCONTACT_ID);
							break;
						}
						case "Opportunities":
						{
							Guid gOPPORTUNITY_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spOPPORTUNITIES_CONTACTS_Update(gOPPORTUNITY_ID, gCONTACT_ID, String.Empty);
							break;
						}
						case "Project":
						{
							Guid gPROJECT_ID = Sql.ToGuid(sMODULE2_ID);
							// 09/08/2012 Paul.  Project Relations data for Accounts, Bugs, Cases, Contacts, Opportunities and Quotes moved to separate tables. 
							SqlProcs.spPROJECTS_CONTACTS_Update(gPROJECT_ID, gCONTACT_ID);
							break;
						}
						case "Quotes":
						{
							Guid gQUOTE_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spQUOTES_CONTACTS_Update(gQUOTE_ID, gCONTACT_ID, String.Empty);
							break;
						}
						default:
						{
							throw(new Exception(String.Format("A relationship between {0} and {1} has not been defined.", sMODULE1, sMODULE2)));
						}
					}
					break;
				}
				case "Users":
				{
					Guid gUSER_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						case "Calls":
						{
							Guid gCALL_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spCALLS_USERS_Update(gCALL_ID, gUSER_ID, false, String.Empty);
							break;
						}
						case "Meetings":
						{
							Guid gMEETING_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spMEETINGS_USERS_Update(gMEETING_ID, gUSER_ID, false, String.Empty);
							break;
						}
						case "Contacts":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							// 09/15/2015 Paul.  Add SERVICE_NAME to separate Exchange Folders from Contacts Sync. 
							SqlProcs.spCONTACTS_USERS_Update(gCONTACT_ID, gUSER_ID, String.Empty);
							break;
						}
						// 08/17/2006 Paul.  New relationships. 
						case "Emails":
						{
							Guid gEMAILS_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_USERS_Update(gEMAILS_ID, gUSER_ID);
							break;
						}
						default:
						{
							throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", sMODULE1, sMODULE2)));
						}
					}
					break;
				}
				case "Meetings":
				{
					Guid gMEETING_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						case "Contacts":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spMEETINGS_CONTACTS_Update(gMEETING_ID, gCONTACT_ID, false, String.Empty);
							break;
						}
						case "Users":
						{
							Guid gUSER_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spMEETINGS_USERS_Update(gMEETING_ID, gUSER_ID, false, String.Empty);
							break;
						}
						default:
						{
							throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", sMODULE1, sMODULE2)));
						}
					}
					break;
				}
				case "Calls":
				{
					Guid gCALL_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						case "Contacts":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spCALLS_CONTACTS_Update(gCALL_ID, gCONTACT_ID, false, String.Empty);
							break;
						}
						case "Users":
						{
							Guid gUSER_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spCALLS_USERS_Update(gCALL_ID, gUSER_ID, false, String.Empty);
							break;
						}
						// 08/17/2006 Paul.  New relationships. 
						default:
						{
							throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", sMODULE1, sMODULE2)));
						}
					}
					break;
				}
				case  "Accounts":
				{
					Guid gACCOUNT_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						case "Contacts":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spACCOUNTS_CONTACTS_Update(gACCOUNT_ID, gCONTACT_ID);
							break;
						}
						// 08/17/2006 Paul.  Relationship not defined.
						/*
						case "Users":
						{
							Guid gUSER_ID = Sql.ToGuid(sMODULE2_ID);
							break;
						}
						*/
						case "Emails":
						{
							Guid gEMAIL_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spEMAILS_ACCOUNTS_Update(gEMAIL_ID, gACCOUNT_ID);
							break;
						}
						// 08/17/2006 Paul.  New relationships. 
						case "Bugs":
						{
							Guid gBUG_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spACCOUNTS_BUGS_Update(gACCOUNT_ID, gBUG_ID);
							break;
						}
						case "Opportunities":
						{
							Guid gOPPORTUNITY_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spACCOUNTS_OPPORTUNITIES_Update(gACCOUNT_ID, gOPPORTUNITY_ID);
							break;
						}
						case "Project":
						{
							Guid gPROJECT_ID = Sql.ToGuid(sMODULE2_ID);
							// 09/08/2012 Paul.  Project Relations data for Accounts, Bugs, Cases, Contacts, Opportunities and Quotes moved to separate tables. 
							SqlProcs.spPROJECTS_ACCOUNTS_Update(gPROJECT_ID, gACCOUNT_ID);
							break;
						}
						case "Quotes":
						{
							Guid gQUOTE_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spQUOTES_ACCOUNTS_Update(gQUOTE_ID, gACCOUNT_ID, String.Empty);
							break;
						}
						default:
						{
							throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", sMODULE1, sMODULE2)));
						}
					}
					break;
				}
				case  "Leads":
				{
					Guid gLEAD_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						// 08/17/2006 Paul.  Relationship is not defined. 
						/*
						case "Contacts":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							break;
						}
						case "Users":
						{
							Guid gUSER_ID = Sql.ToGuid(sMODULE2_ID);
							break;
						}
						*/
						case "Emails":
						{
							Guid gEMAIL_ID = Sql.ToGuid(sMODULE2_ID);
							// 08/17/2006 Paul.  Relationship not previously created. 
							SqlProcs.spEMAILS_LEADS_Update(gEMAIL_ID, gLEAD_ID);
							break;
						}
						// 08/17/2006 Paul.  New relationships. 
						default:
						{
							throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", sMODULE1, sMODULE2)));
						}
					}
					break;
				}
				case "Tasks":
				{
					Guid gTASK_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						case "Users":
						{
							Guid gUSER_ID = Sql.ToGuid(sMODULE2_ID);
							// 02/01/2009 Paul.  The SugarCRM plug-in technique for unsyncing a task is to delete it. 
							if ( Sql.IsEmptyGuid(gUSER_ID) )
								SqlProcs.spTASKS_Delete(gTASK_ID);
							break;
						}
						// 08/17/2006 Paul.  New relationships. 
						case "Emails":
						{
							Guid gEMAIL_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_TASKS_Update(gEMAIL_ID, gTASK_ID);
							break;
						}
						default:
						{
							throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", sMODULE1, sMODULE2)));
						}
					}
					break;
				}
				case  "Opportunities":
				{
					Guid gOPPORTUNITY_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						// 08/17/2006 Paul.  New relationships. 
						case "Accounts":
						{
							Guid gACCOUNT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spACCOUNTS_OPPORTUNITIES_Update(gACCOUNT_ID, gOPPORTUNITY_ID);
							break;
						}
						case "Contacts":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spOPPORTUNITIES_CONTACTS_Update(gOPPORTUNITY_ID, gCONTACT_ID, String.Empty);
							break;
						}
						case "Contracts":
						{
							Guid gCONTRACT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spCONTRACTS_OPPORTUNITIES_Update(gCONTRACT_ID, gOPPORTUNITY_ID);
							break;
						}
						case "Emails":
						{
							Guid gEMAIL_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_OPPORTUNITIES_Update(gEMAIL_ID, gOPPORTUNITY_ID);
							break;
						}
						case "Project":
						{
							Guid gPROJECT_ID = Sql.ToGuid(sMODULE2_ID);
							// 09/08/2012 Paul.  Project Relations data for Accounts, Bugs, Cases, Contacts, Opportunities and Quotes moved to separate tables. 
							SqlProcs.spPROJECTS_OPPORTUNITIES_Update(gPROJECT_ID, gOPPORTUNITY_ID);
							break;
						}
						case "Quotes":
						{
							Guid gQUOTE_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spQUOTES_OPPORTUNITIES_Update(gQUOTE_ID, gOPPORTUNITY_ID);
							break;
						}
						default:
						{
							throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", sMODULE1, sMODULE2)));
						}
					}
					break;
				}
				case  "Project":
				{
					Guid gPROJECT_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						// 08/17/2006 Paul.  New relationships. 
						case "Accounts":
						{
							Guid gACCOUNT_ID = Sql.ToGuid(sMODULE2_ID);
							// 09/08/2012 Paul.  Project Relations data for Accounts, Bugs, Cases, Contacts, Opportunities and Quotes moved to separate tables. 
							SqlProcs.spPROJECTS_ACCOUNTS_Update(gPROJECT_ID, gACCOUNT_ID);
							break;
						}
						case "Contacts":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							// 09/08/2012 Paul.  Project Relations data for Accounts, Bugs, Cases, Contacts, Opportunities and Quotes moved to separate tables. 
							SqlProcs.spPROJECTS_CONTACTS_Update(gPROJECT_ID, gCONTACT_ID);
							break;
						}
						case "Opportunities":
						{
							Guid gOPPORTUNITY_ID = Sql.ToGuid(sMODULE2_ID);
							// 09/08/2012 Paul.  Project Relations data for Accounts, Bugs, Cases, Contacts, Opportunities and Quotes moved to separate tables. 
							SqlProcs.spPROJECTS_OPPORTUNITIES_Update(gPROJECT_ID, gOPPORTUNITY_ID);
							break;
						}
						case "Quotes":
						{
							Guid gQUOTE_ID = Sql.ToGuid(sMODULE2_ID);
							// 09/08/2012 Paul.  Project Relations data for Accounts, Bugs, Cases, Contacts, Opportunities and Quotes moved to separate tables. 
							SqlProcs.spPROJECTS_QUOTES_Update(gPROJECT_ID, gQUOTE_ID);
							break;
						}
						case "Emails":
						{
							Guid gEMAIL_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_PROJECTS_Update(gEMAIL_ID, gPROJECT_ID);
							break;
						}
						default:
						{
							throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", sMODULE1, sMODULE2)));
						}
					}
					break;
				}
				case "Emails":
				{
					Guid gEMAIL_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						// 08/17/2006 Paul.  New relationships. 
						case "Accounts":
						{
							Guid gACCOUNT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_ACCOUNTS_Update(gEMAIL_ID, gACCOUNT_ID);
							break;
						}
						case "Bugs":
						{
							Guid gBUG_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_BUGS_Update(gEMAIL_ID, gBUG_ID);
							break;
						}
						case "Cases":
						{
							Guid gCASE_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_CASES_Update(gEMAIL_ID, gCASE_ID);
							break;
						}
						case "Contacts":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_CONTACTS_Update(gEMAIL_ID, gCONTACT_ID);
							break;
						}
						case "Opportunities":
						{
							Guid gOPPORTUNITY_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_OPPORTUNITIES_Update(gEMAIL_ID, gOPPORTUNITY_ID);
							break;
						}
						case "Project":
						{
							Guid gPROJECT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_PROJECTS_Update(gEMAIL_ID, gPROJECT_ID);
							break;
						}
						case "Quotes":
						{
							Guid gQUOTE_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_QUOTES_Update(gEMAIL_ID, gQUOTE_ID);
							break;
						}
						case "Tasks":
						{
							Guid gTASK_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_TASKS_Update(gEMAIL_ID, gTASK_ID);
							break;
						}
						case "Users":
						{
							Guid gUSER_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_USERS_Update(gEMAIL_ID, gUSER_ID);
							break;
						}
						default:
						{
							throw(new Exception(String.Format("A relationship between {0} and {1} has not been defined.", sMODULE1, sMODULE2)));
						}
					}
					break;
				}
				// 12/07/2007 Paul.  The plug-in treats the bug as the parent when archiving an email. 
				case "Bugs":
				{
					Guid gBUG_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						case "Accounts":
						{
							Guid gACCOUNT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spACCOUNTS_BUGS_Update(gACCOUNT_ID, gBUG_ID);
							break;
						}
						case "Contacts":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							// 10/03/2009 Paul.  The IDs were reversed, generating a foreign key error. 
							SqlProcs.spCONTACTS_BUGS_Update(gCONTACT_ID, gBUG_ID, String.Empty);
							break;
						}
						case "Emails":
						{
							Guid gEMAIL_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_BUGS_Update(gEMAIL_ID, gBUG_ID);
							break;
						}
					}
					break;
				}
				// 12/07/2007 Paul.  The plug-in treats the case as the parent when archiving an email. 
				case "Cases":
				{
					Guid gCASE_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						case "Contacts":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							// 10/03/2009 Paul.  The IDs were reversed, generating a foreign key error. 
							SqlProcs.spCONTACTS_CASES_Update(gCONTACT_ID, gCASE_ID, String.Empty);
							break;
						}
						case "Emails":
						{
							Guid gEMAIL_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_CASES_Update(gEMAIL_ID, gCASE_ID);
							break;
						}
					}
					break;
				}
				// 12/07/2007 Paul.  The plug-in treats the quote as the parent when archiving an email. 
				case "Quotes":
				{
					Guid gQUOTE_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						case "Accounts":
						{
							Guid gACCOUNT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spQUOTES_ACCOUNTS_Update(gQUOTE_ID, gACCOUNT_ID, String.Empty);
							break;
						}
						case "Contact":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spQUOTES_CONTACTS_Update(gQUOTE_ID, gCONTACT_ID, String.Empty);
							break;
						}
						case "Emails":
						{
							Guid gEMAIL_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_QUOTES_Update(gEMAIL_ID, gQUOTE_ID);
							break;
						}
						case "Opportunities":
						{
							Guid gOPPORTUNITY_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spQUOTES_OPPORTUNITIES_Update(gQUOTE_ID, gOPPORTUNITY_ID);
							break;
						}
						case "Project":
						{
							Guid gPROJECT_ID = Sql.ToGuid(sMODULE2_ID);
							// 09/08/2012 Paul.  Project Relations data for Accounts, Bugs, Cases, Contacts, Opportunities and Quotes moved to separate tables. 
							SqlProcs.spPROJECTS_QUOTES_Update(gPROJECT_ID, gQUOTE_ID);
							break;
						}
					}
					break;
				}
				// 05/18/2014 Paul.  Customer wants to be able to archive to an order. 
				case "Orders":
				{
					Guid gORDER_ID = Sql.ToGuid(sMODULE1_ID);
					switch ( sMODULE2 )
					{
						case "Accounts":
						{
							Guid gACCOUNT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spORDERS_ACCOUNTS_Update(gORDER_ID, gACCOUNT_ID, String.Empty);
							break;
						}
						case "Contact":
						{
							Guid gCONTACT_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spORDERS_CONTACTS_Update(gORDER_ID, gCONTACT_ID, String.Empty);
							break;
						}
						case "Emails":
						{
							Guid gEMAIL_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spEMAILS_ORDERS_Update(gEMAIL_ID, gORDER_ID);
							break;
						}
						case "Opportunities":
						{
							Guid gOPPORTUNITY_ID = Sql.ToGuid(sMODULE2_ID);
							SqlProcs.spORDERS_OPPORTUNITIES_Update(gORDER_ID, gOPPORTUNITY_ID);
							break;
						}
					}
					break;
				}
				default:
				{
					throw(new Exception(String.Format("Relationship between {0} and {1} is not defined", sMODULE1, sMODULE2)));
				}
			}
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public error_value set_relationship(string session, set_relationship_value set_relationship_value)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			
			// 02/16/2006 Paul.  Don't need to verify the modules as it will be done inside SetRelationship();
			//VerifyModuleName(set_relationship_value.module1);
			//VerifyModuleName(set_relationship_value.module2);
			int nACLACCESS = Security.GetUserAccess(set_relationship_value.module1, "edit");
			if ( nACLACCESS < 0 )
			{
				L10N L10n = new L10N("en-US");
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}

			error_value results = new error_value();
			SetRelationship(set_relationship_value.module1, set_relationship_value.module1_id, set_relationship_value.module2, set_relationship_value.module2_id);
			return results;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public set_relationship_list_result set_relationships(string session, set_relationship_value[] set_relationship_list)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			
			set_relationship_list_result results = new set_relationship_list_result();
			results.created = 0;
			results.failed  = 0;
			for ( int i=0; i < set_relationship_list.Length; i ++ )
			{
				int nACLACCESS = Security.GetUserAccess(set_relationship_list[i].module1, "edit");
				if ( nACLACCESS < 0 )
				{
					L10N L10n = new L10N("en-US");
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				SetRelationship(set_relationship_list[i].module1, set_relationship_list[i].module1_id, set_relationship_list[i].module2, set_relationship_list[i].module2_id);
				results.created++ ;
			}
			return results;
		}

		[WebMethod(EnableSession=true)]
		[SoapRpcMethod]
		public set_entry_result set_document_revision(string session, document_revision note)
		{
			Guid gUSER_ID = GetSessionUserID(session);
			if ( gUSER_ID != Guid.Empty )
			{
				Guid   gDOCUMENT_ID    = Sql.ToGuid(note.id);
				string sDOCUMENT_NAME  = note.document_name;
				string sFILENAME       = Path.GetFileName (note.filename);
				string sFILE_EXT       = Path.GetExtension(sFILENAME);
				string sFILE_MIME_TYPE = "application/octet-stream";
				// 04/24/2011 Paul.  Lets correct some of the most populate file types. 
				// 05/11/2011 Paul.  The file extension includes the dot. 
				switch ( sFILE_EXT.ToLower() )
				{
					case ".docx":  sFILE_MIME_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"  ;  break;
					case ".xlsx":  sFILE_MIME_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"        ;  break;
					case ".pptx":  sFILE_MIME_TYPE = "application/vnd.openxmlformats-officedocument.presentationml.presentation";  break;
					case ".doc" :  sFILE_MIME_TYPE = "application/msword"           ;  break;
					case ".xls" :  sFILE_MIME_TYPE = "application/vnd.ms-excel"     ;  break;
					case ".ppt" :  sFILE_MIME_TYPE = "application/vnd.ms-powerpoint";  break;
					case ".txt" :  sFILE_MIME_TYPE = "text/plain"                   ;  break;
					case ".xml" :  sFILE_MIME_TYPE = "text/xml"                     ;  break;
					case ".gif" :  sFILE_MIME_TYPE = "image/gif"                    ;  break;
					case ".jpg" :  sFILE_MIME_TYPE = "image/jpeg"                   ;  break;
					case ".png" :  sFILE_MIME_TYPE = "image/png"                    ;  break;
					case ".pdf" :  sFILE_MIME_TYPE = "application/pdf"              ;  break;
				}
				
				int nACLACCESS = Security.GetUserAccess("Documents", "edit");
				if ( nACLACCESS < 0 )
				{
					L10N L10n = new L10N("en-US");
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}

				set_entry_result result = new set_entry_result();
				byte[] byData = Convert.FromBase64String(note.file);
				// 02/20/2006 Paul.  Try and reduce the memory requirements by releasing the original data as soon as possible. 
				note.file = null;
				using ( MemoryStream stm = new System.IO.MemoryStream(byData) )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						// 04/24/2011 Paul.  A DocumentRevision does not have an Assigned User ID. 
						Guid gASSIGNED_USER_ID = Guid.Empty;
						if ( nACLACCESS != ACL_ACCESS.OWNER || (nACLACCESS == ACL_ACCESS.OWNER  && gASSIGNED_USER_ID == gUSER_ID) )
						{
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									Guid gRevisionID = Guid.Empty;
									SqlProcs.spDOCUMENT_REVISIONS_Insert(ref gRevisionID, gDOCUMENT_ID, note.revision, String.Empty, sFILENAME, sFILE_EXT, sFILE_MIME_TYPE);
									// 04/24/2011 Paul.  Move LoadFile() to Crm.DocumentRevisions. 
									Crm.DocumentRevisions.LoadFile(gRevisionID, stm, trn);
									trn.Commit();
									result.id = gRevisionID.ToString();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									throw ( new Exception(ex.Message) );
								}
							}
						}
					}
				}
				byData = null;
				return result;
			}
			return null;
		}
		#endregion
	}
}

