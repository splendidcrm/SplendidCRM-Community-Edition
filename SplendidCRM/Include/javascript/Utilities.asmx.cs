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
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Web.Services;
using System.ComponentModel;
using SplendidCRM;

namespace SplendidCRM.Utilities
{
	/// <summary>
	/// Summary description for Modules
	/// </summary>
	[WebService(Namespace = "http://tempuri.org/")]
	[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
	[System.Web.Script.Services.ScriptService]
	[ToolboxItem(false)]
	public class Modules : System.Web.Services.WebService
	{
		[WebMethod(EnableSession=true)]
		public bool AddToFavorites(string sMODULE, Guid gID)
		{
			bool bSucceeded = false;
			//try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));
				
				// 03/31/2012 Paul.  Use the standard filter to verify that the user can view the record. 
				if ( !Sql.IsEmptyString(sMODULE) && !Sql.IsEmptyGuid(gID) && SplendidCRM.Security.GetUserAccess(sMODULE, "view") >= 0 )
				{
					string sTABLE_NAME = Crm.Modules.TableName(sMODULE);
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL ;
						sSQL = "select NAME           " + ControlChars.CrLf
						    + "  from vw" + sTABLE_NAME + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Security.Filter(cmd, sMODULE, "view");
							Sql.AppendParameter(cmd, gID, "ID", false);
							con.Open();

							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									if ( dt.Rows.Count > 0 )
									{
										DataRow rdr = dt.Rows[0];
										string sNAME = Sql.ToString(rdr["NAME"]);
										SqlProcs.spSUGARFAVORITES_Update(Security.USER_ID, sMODULE, gID, sNAME);
										SplendidCache.ClearFavorites();
										bSucceeded = true;
									}
								}
							}
						}
					}
				}
			}
			//catch
			{
				// 02/04/2007 Paul.  Don't catch the exception.  
				// It is a web service, so the exception will be handled properly by the AJAX framework. 
			}
			return bSucceeded;
		}

		[WebMethod(EnableSession=true)]
		public bool RemoveFromFavorites(string sMODULE, Guid gID)
		{
			bool bSucceeded = false;
			//try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));
				
				// 03/31/2012 Paul.  No need to validate on remove as the item would not be in the list if the user did not have access to it. 
				if ( !Sql.IsEmptyString(sMODULE) && !Sql.IsEmptyGuid(gID) && SplendidCRM.Security.GetUserAccess(sMODULE, "view") >= 0 )
				{
					SqlProcs.spSUGARFAVORITES_Delete(Security.USER_ID, gID);
					SplendidCache.ClearFavorites();
					bSucceeded = true;
				}
			}
			//catch
			{
				// 02/04/2007 Paul.  Don't catch the exception.  
				// It is a web service, so the exception will be handled properly by the AJAX framework. 
			}
			return bSucceeded;
		}

		// 10/09/2015 Paul.  Add methods to manage subscriptions. 
		[WebMethod(EnableSession=true)]
		public bool AddSubscription(string sMODULE, Guid gID)
		{
			bool bSucceeded = false;
			//try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));
				
				// 03/31/2012 Paul.  Use the standard filter to verify that the user can view the record. 
				if ( !Sql.IsEmptyString(sMODULE) && !Sql.IsEmptyGuid(gID) && SplendidCRM.Security.GetUserAccess(sMODULE, "view") >= 0 )
				{
					string sTABLE_NAME = Crm.Modules.TableName(sMODULE);
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL ;
						sSQL = "select NAME           " + ControlChars.CrLf
						    + "  from vw" + sTABLE_NAME + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Security.Filter(cmd, sMODULE, "view");
							Sql.AppendParameter(cmd, gID, "ID", false);
							con.Open();

							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									if ( dt.Rows.Count > 0 )
									{
										DataRow rdr = dt.Rows[0];
										string sNAME = Sql.ToString(rdr["NAME"]);
										SqlProcs.spSUBSCRIPTIONS_Update(Security.USER_ID, sMODULE, gID);
										SplendidCache.ClearSubscriptions();
										bSucceeded = true;
									}
								}
							}
						}
					}
				}
			}
			//catch
			{
				// 02/04/2007 Paul.  Don't catch the exception.  
				// It is a web service, so the exception will be handled properly by the AJAX framework. 
			}
			return bSucceeded;
		}

		// 10/09/2015 Paul.  Add methods to manage subscriptions. 
		[WebMethod(EnableSession=true)]
		public bool RemoveSubscription(string sMODULE, Guid gID)
		{
			bool bSucceeded = false;
			//try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));
				
				// 03/31/2012 Paul.  No need to validate on remove as the item would not be in the list if the user did not have access to it. 
				if ( !Sql.IsEmptyString(sMODULE) && !Sql.IsEmptyGuid(gID) && SplendidCRM.Security.GetUserAccess(sMODULE, "view") >= 0 )
				{
					SqlProcs.spSUBSCRIPTIONS_Delete(Security.USER_ID, gID);
					SplendidCache.ClearSubscriptions();
					bSucceeded = true;
				}
			}
			//catch
			{
				// 02/04/2007 Paul.  Don't catch the exception.  
				// It is a web service, so the exception will be handled properly by the AJAX framework. 
			}
			return bSucceeded;
		}
	}
}


