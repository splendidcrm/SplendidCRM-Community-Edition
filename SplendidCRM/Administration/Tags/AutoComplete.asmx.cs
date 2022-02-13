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
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.ComponentModel;
using SplendidCRM;

namespace SplendidCRM.Administration.Tags
{
	// 10/31/2021 Paul.  Moved Tag.Get to ModuleUtils. 

	/// <summary>
	/// Summary description for AutoComplete
	/// </summary>
	[WebService(Namespace = "http://tempuri.org/")]
	[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
	[System.Web.Script.Services.ScriptService]
	[ToolboxItem(false)]
	public class AutoComplete : System.Web.Services.WebService
	{
		// 10/31/2021 Paul.  Moved Tag.Get to ModuleUtils. 
		[WebMethod(EnableSession=true)]
		public ModuleUtils.Tag TAGS_TAG_NAME_Get(string sNAME)
		{
			ModuleUtils.Tag item = ModuleUtils.Tag.Get(Application, sNAME);
			return item;
		}

		// 10/31/2021 Paul.  Moved Tag.Get to ModuleUtils. 
		[WebMethod(EnableSession=true)]
		public ModuleUtils.Tag[] TAGS_TAG_NAME_MultiSelect(string sNAMES)
		{
			List<ModuleUtils.Tag> lstTags = new List<ModuleUtils.Tag>();
			//try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));

				// 05/12/2016 Paul.  Instead of using a SQL in clause, look up each tag so that we can create ones that are new. 
				string[] arrNAME = sNAMES.Split(',');
				foreach ( string sNAME in arrNAME )
				{
					if ( !Sql.IsEmptyString(sNAME) )
					{
						ModuleUtils.Tag item = ModuleUtils.Tag.Get(Application, sNAME);
						if ( item != null )
							lstTags.Add(item);
					}
				}
			}
			//catch
			{
				// 05/12/2016 Paul.  Don't catch the exception.  
				// It is a web service, so the exception will be handled properly by the AJAX framework. 
			}
			return lstTags.ToArray();
		}

		[WebMethod(EnableSession=true)]
		public string[] TAGS_TAG_NAME_List(string prefixText, int count)
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
					sSQL = "select NAME          " + ControlChars.CrLf
					     + "  from vwTAGS_List   " + ControlChars.CrLf
					     + " where 1 = 1         " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
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

		[WebMethod(EnableSession=true)]
		public string[] TAGS_NAME_List(string prefixText, int count)
		{
			return TAGS_TAG_NAME_List(prefixText, count);
		}
	}
}

