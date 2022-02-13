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

namespace SplendidCRM.Contacts
{
	public class Contact
	{
		public Guid    ID  ;
		public string  LAST_NAME;

		public Contact()
		{
			ID   = Guid.Empty  ;
			LAST_NAME = String.Empty;
		}
	}

	public class ContactName
	{
		public Guid    ID  ;
		public string  NAME;

		public ContactName()
		{
			ID   = Guid.Empty  ;
			NAME = String.Empty;
		}
	}

	/// <summary>
	/// Summary description for AutoComplete
	/// </summary>
	[WebService(Namespace = "http://tempuri.org/")]
	[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
	[System.Web.Script.Services.ScriptService]
	[ToolboxItem(false)]
	public class AutoComplete : System.Web.Services.WebService
	{
		[WebMethod(EnableSession=true)]
		public Contact CONTACTS_CONTACT_LAST_NAME_Get(string sLAST_NAME)
		{
			Contact item = new Contact();
			//try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));

				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select ID        " + ControlChars.CrLf
					     + "     , LAST_NAME " + ControlChars.CrLf
					     + "  from vwCONTACTS" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Contacts", "list");
						// 07/12/2010 Paul.  Allow fuzzy searching during AutoComplete. 
						Sql.AppendParameter(cmd, sLAST_NAME, (Sql.ToBoolean(Application["CONFIG.AutoComplete.Contains"]) ? Sql.SqlFilterMode.Contains : Sql.SqlFilterMode.StartsWith), "LAST_NAME");
						// 07/02/2007 Paul.  Sort is important so that the first match is selected. 
						cmd.CommandText += " order by LAST_NAME" + ControlChars.CrLf;
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								item.ID   = Sql.ToGuid   (rdr["ID"  ]);
								item.LAST_NAME = Sql.ToString (rdr["LAST_NAME"]);
							}
						}
					}
				}
				if ( Sql.IsEmptyGuid(item.ID) )
				{
					string sCULTURE = Sql.ToString (Session["USER_SETTINGS/CULTURE"]);
					L10N L10n = new L10N(sCULTURE);
					throw(new Exception(L10n.Term("Contacts.ERR_CONTACT_NOT_FOUND")));
				}
			}
			//catch
			{
				// 02/04/2007 Paul.  Don't catch the exception.  
				// It is a web service, so the exception will be handled properly by the AJAX framework. 
			}
			return item;
		}

		// 03/30/2007 Paul.  Enable sessions so that we can require authentication to access the data. 
		// 03/29/2007 Paul.  In order for AutoComplete to work, the parameter names must be "prefixText" and "count". 
		[WebMethod(EnableSession=true)]
		public string[] CONTACTS_CONTACT_LAST_NAME_List(string prefixText, int count)
		{
			string[] arrItems = new string[0];
			try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));

				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					// 10/08/2010 Paul.  Since we are only returning the name, it is useful to return a distinct list. 
					sSQL = "select distinct  " + ControlChars.CrLf
					     + "       LAST_NAME " + ControlChars.CrLf
					     + "  from vwCONTACTS" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Contacts", "list");
						// 07/12/2010 Paul.  Allow fuzzy searching during AutoComplete. 
						Sql.AppendParameter(cmd, prefixText, (Sql.ToBoolean(Application["CONFIG.AutoComplete.Contains"]) ? Sql.SqlFilterMode.Contains : Sql.SqlFilterMode.StartsWith), "LAST_NAME");
						cmd.CommandText += " order by LAST_NAME" + ControlChars.CrLf;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(0, count, dt);
								arrItems = new string[dt.Rows.Count];
								for ( int i=0; i < dt.Rows.Count; i++ )
									arrItems[i] = Sql.ToString(dt.Rows[i]["LAST_NAME"]);
							}
						}
					}
				}
			}
			catch
			{
			}
			return arrItems;
		}

		// 09/03/2009 Paul.  The list can be retrived for the base module, or for a ModulePopup, 
		// so the field name can be NAME or CONTACT_NAME. 
		[WebMethod(EnableSession=true)]
		public string[] CONTACTS_LAST_NAME_List(string prefixText, int count)
		{
			return CONTACTS_CONTACT_LAST_NAME_List(prefixText, count);
		}

		// 07/27/2010 Paul.  Since we are using the ContextKey for the AutoComplete, we need to also use the Account Name with the Get. 
		// It is also important to return the name and not just the full name so that it will match the value used in the view. 
		// 09/16/2010 Paul.  Having trouble with the final step of AutoComplete. 
		[WebMethod(EnableSession=true)]
		public ContactName CONTACTS_CONTACT_NAME_Get(string sNAME)
		{
			ContactName item = new ContactName();
			//try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));

				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select ID        " + ControlChars.CrLf
					     + "     , NAME      " + ControlChars.CrLf
					     + "  from vwCONTACTS" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Contacts", "list");
						// 07/12/2010 Paul.  Allow fuzzy searching during AutoComplete. 
						Sql.AppendParameter(cmd, sNAME, (Sql.ToBoolean(Application["CONFIG.AutoComplete.Contains"]) ? Sql.SqlFilterMode.Contains : Sql.SqlFilterMode.StartsWith), "NAME");
						// 07/02/2007 Paul.  Sort is important so that the first match is selected. 
						cmd.CommandText += " order by NAME" + ControlChars.CrLf;
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								item.ID   = Sql.ToGuid   (rdr["ID"  ]);
								item.NAME = Sql.ToString (rdr["NAME"]);
							}
						}
					}
				}
				if ( Sql.IsEmptyGuid(item.ID) )
				{
					string sCULTURE = Sql.ToString (Session["USER_SETTINGS/CULTURE"]);
					L10N L10n = new L10N(sCULTURE);
					throw(new Exception(L10n.Term("Contacts.ERR_CONTACT_NOT_FOUND")));
				}
			}
			//catch
			{
				// 02/04/2007 Paul.  Don't catch the exception.  
				// It is a web service, so the exception will be handled properly by the AJAX framework. 
			}
			return item;
		}

		// 07/27/2010 Paul.  Add methods to be used by Quotes, Orders and Invoices. 
		// 07/27/2010 Paul.  We need to specify additional parameters, so use the contextKey. 
		// http://www.aspdotnetcodes.com/AutoComplete_Textbox_Addtional_Parameters.aspx
		[WebMethod(EnableSession=true)]
		public string[] CONTACTS_CONTACT_NAME_List(string prefixText, int count)
		{
			string[] arrItems = new string[0];
			try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));

				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					// 10/08/2010 Paul.  Since we are only returning the name, it is useful to return a distinct list. 
					sSQL = "select distinct  " + ControlChars.CrLf
					     + "       NAME      " + ControlChars.CrLf
					     + "  from vwCONTACTS" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Contacts", "list");
						// 07/12/2010 Paul.  Allow fuzzy searching during AutoComplete. 
						Sql.AppendParameter(cmd, prefixText, (Sql.ToBoolean(Application["CONFIG.AutoComplete.Contains"]) ? Sql.SqlFilterMode.Contains : Sql.SqlFilterMode.StartsWith), "NAME");
						cmd.CommandText += " order by NAME" + ControlChars.CrLf;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(0, count, dt);
								arrItems = new string[dt.Rows.Count];
								for ( int i=0; i < dt.Rows.Count; i++ )
									arrItems[i] = Sql.ToString(dt.Rows[i]["NAME"]);
							}
						}
					}
				}
			}
			catch
			{
			}
			return arrItems;
		}

		// 10/11/2010 Paul.  The list can be retrived for the base module, or for a ModulePopup, 
		// so the field name can be NAME or CONTACT_NAME. 
		[WebMethod(EnableSession=true)]
		public string[] CONTACTS_NAME_List(string prefixText, int count)
		{
			return CONTACTS_CONTACT_NAME_List(prefixText, count);
		}

		// 09/16/2010 Paul.  We need separate functions for CONTACTS_CONTACT_NAME_Get, and CONTACTS_BILLING_CONTACT_NAME_Get. 
		[WebMethod(EnableSession=true)]
		public ContactName CONTACTS_BILLING_CONTACT_NAME_Get(string sNAME, string contextKey)
		{
			ContactName item = new ContactName();
			//try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));

				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select ID        " + ControlChars.CrLf
					     + "     , NAME      " + ControlChars.CrLf
					     + "  from vwCONTACTS" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Contacts", "list");
						if ( !Sql.IsEmptyString(contextKey) )
							Sql.AppendParameter(cmd, contextKey, "ACCOUNT_NAME");
						// 07/12/2010 Paul.  Allow fuzzy searching during AutoComplete. 
						Sql.AppendParameter(cmd, sNAME, (Sql.ToBoolean(Application["CONFIG.AutoComplete.Contains"]) ? Sql.SqlFilterMode.Contains : Sql.SqlFilterMode.StartsWith), "NAME");
						// 07/02/2007 Paul.  Sort is important so that the first match is selected. 
						cmd.CommandText += " order by NAME" + ControlChars.CrLf;
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								item.ID   = Sql.ToGuid   (rdr["ID"  ]);
								item.NAME = Sql.ToString (rdr["NAME"]);
							}
						}
					}
				}
				if ( Sql.IsEmptyGuid(item.ID) )
				{
					string sCULTURE = Sql.ToString (Session["USER_SETTINGS/CULTURE"]);
					L10N L10n = new L10N(sCULTURE);
					throw(new Exception(L10n.Term("Contacts.ERR_CONTACT_NOT_FOUND")));
				}
			}
			//catch
			{
				// 02/04/2007 Paul.  Don't catch the exception.  
				// It is a web service, so the exception will be handled properly by the AJAX framework. 
			}
			return item;
		}

		[WebMethod(EnableSession=true)]
		public string[] CONTACTS_BILLING_CONTACT_NAME_List(string prefixText, int count, string contextKey)
		{
			string[] arrItems = new string[0];
			try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));

				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select ID        " + ControlChars.CrLf
					     + "     , NAME      " + ControlChars.CrLf
					     + "  from vwCONTACTS" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Contacts", "list");
						Sql.AppendParameter(cmd, contextKey, "ACCOUNT_NAME");
						// 07/12/2010 Paul.  Allow fuzzy searching during AutoComplete. 
						Sql.AppendParameter(cmd, prefixText, (Sql.ToBoolean(Application["CONFIG.AutoComplete.Contains"]) ? Sql.SqlFilterMode.Contains : Sql.SqlFilterMode.StartsWith), "NAME");
						cmd.CommandText += " order by NAME" + ControlChars.CrLf;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(0, count, dt);
								arrItems = new string[dt.Rows.Count];
								for ( int i=0; i < dt.Rows.Count; i++ )
									arrItems[i] = Sql.ToString(dt.Rows[i]["NAME"]);
							}
						}
					}
				}
			}
			catch
			{
			}
			return arrItems;
		}
		// 07/27/2010 Paul.  JavaScript seems to have a problem with function overloading. 
		// Instead of trying to use function overloading, use a DataFormat flag to check the UseContextKey AutoComplete flag. 
		/*
		[WebMethod(EnableSession=true)]
		public string[] CONTACTS_BILLING_CONTACT_NAME_List(string prefixText, int count)
		{
			return CONTACTS_CONTACT_NAME_List(prefixText, count, String.Empty);
		}
		*/

		// 09/16/2010 Paul.  We need separate functions for CONTACTS_CONTACT_NAME_Get, and CONTACTS_BILLING_CONTACT_NAME_Get. 
		[WebMethod(EnableSession=true)]
		public ContactName CONTACTS_SHIPPING_CONTACT_NAME_Get(string sNAME, string contextKey)
		{
			return CONTACTS_BILLING_CONTACT_NAME_Get(sNAME, contextKey);
		}

		[WebMethod(EnableSession=true)]
		public string[] CONTACTS_SHIPPING_CONTACT_NAME_List(string prefixText, int count, string contextKey)
		{
			return CONTACTS_BILLING_CONTACT_NAME_List(prefixText, count, contextKey);
		}
		/*
		[WebMethod(EnableSession=true)]
		public string[] CONTACTS_SHIPPING_CONTACT_NAME_List(string prefixText, int count)
		{
			return CONTACTS_CONTACT_NAME_List(prefixText, count, String.Empty);
		}
		*/

		// 03/10/2016 Paul.  Missing lookup for Reports To Name. 
		[WebMethod(EnableSession=true)]
		public ContactName CONTACTS_REPORTS_TO_NAME_Get(string sNAME)
		{
			return CONTACTS_CONTACT_NAME_Get(sNAME);
		}

		[WebMethod(EnableSession=true)]
		public string[] CONTACTS_REPORTS_TO_NAME_List(string prefixText, int count)
		{
			return CONTACTS_CONTACT_NAME_List(prefixText, count);
		}
	}
}


