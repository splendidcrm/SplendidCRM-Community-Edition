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
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Security.Principal;
using System.Web.Caching;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SplendidCache.
	/// </summary>
	public class PortalCache
	{
		public static bool IsPortal()
		{
			return false;
		}

		public static DataTable TabMenu()
		{
			//System.Web.Caching.Cache Cache = HttpRuntime.Cache;
			// 04/28/2006 Paul.  The menu is now cached in the Session, so it will only get cleared when the user logs out. 
			HttpSessionState Session = HttpContext.Current.Session;
			// 04/28/2006 Paul.  Include the GUID in the USER_ID to that the user does not have to log-out in order to get the correct menu. 
			DataTable dt = Session["vwMODULES_PortalMenu_ByUser." + Security.USER_ID.ToString()] as DataTable;
			if ( dt == null )
			{
				dt = new DataTable();
				try
				{
					// 11/17/2007 Paul.  New function to determine if user is authenticated. 
					if ( Security.IsAuthenticated() )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sSQL;
							// 06/23/2010 Paul.  Allow tabs for Contracts, Quotes, Orders and Invoices. 
							// This is still manual as the code must be added for a tab to function. 
							// 09/13/2012 Paul.  Use a separate view so that Portal tabs can be different than CRM tabs. 
							sSQL = "select MODULE_NAME                            " + ControlChars.CrLf
							     + "     , DISPLAY_NAME                           " + ControlChars.CrLf
							     + "     , RELATIVE_PATH                          " + ControlChars.CrLf
							     + "  from vwMODULES_PortalMenu_ByUser            " + ControlChars.CrLf
							     + " where (USER_ID = @USER_ID or USER_ID is null)" + ControlChars.CrLf
							     + "   and MODULE_NAME in (N'Home', N'Bugs', N'Cases', N'KBDocuments', N'Contracts', N'Quotes', N'Orders', N'Invoices')" + ControlChars.CrLf
							     + " order by TAB_ORDER                           " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@USER_ID", Security.USER_ID);
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									da.Fill(dt);
									Session["vwMODULES_PortalMenu_ByUser." + Security.USER_ID.ToString()] = dt;
								}
							}
						}
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					// 11/21/2005 Paul. Ignore error, but then we need to find a way to display the connection error. 
					// The most likely failure here is a connection failure. 
				}
			}
			return dt;
		}

		public static DataTable MobileMenu()
		{
			//System.Web.Caching.Cache Cache = HttpRuntime.Cache;
			// 04/28/2006 Paul.  The menu is now cached in the Session, so it will only get cleared when the user logs out. 
			HttpSessionState Session = HttpContext.Current.Session;
			// 04/28/2006 Paul.  Include the GUID in the USER_ID to that the user does not have to log-out in order to get the correct menu. 
			DataTable dt = Session["vwMODULES_MobileMenu_ByUser." + Security.USER_ID.ToString()] as DataTable;
			if ( dt == null )
			{
				dt = new DataTable();
				try
				{
					// 11/17/2007 Paul.  New function to determine if user is authenticated. 
					if ( Security.IsAuthenticated() )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sSQL;
							sSQL = "select MODULE_NAME                " + ControlChars.CrLf
							     + "     , DISPLAY_NAME               " + ControlChars.CrLf
							     + "     , RELATIVE_PATH              " + ControlChars.CrLf
							     + "  from vwMODULES_MobileMenu_ByUser" + ControlChars.CrLf
							     + " where (USER_ID = @USER_ID or USER_ID is null)    " + ControlChars.CrLf
							     + "   and MODULE_NAME in (N'Home', N'Bugs', N'Cases')" + ControlChars.CrLf
							     + " order by TAB_ORDER               " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@USER_ID", Security.USER_ID);
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									da.Fill(dt);
									Session["vwMODULES_MobileMenu_ByUser." + Security.USER_ID.ToString()] = dt;
								}
							}
						}
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					// 11/21/2005 Paul. Ignore error, but then we need to find a way to display the connection error. 
					// The most likely failure here is a connection failure. 
				}
			}
			return dt;
		}
	}
}
