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
using System.Data.Common;

namespace SplendidCRM
{
	public partial class SqlProcs
	{
		// 11/26/2021 Paul.  In order to support dynamically created modules in the React client, we need to load the procedures dynamically. 
		public static IDbCommand DynamicFactory(IDbConnection con, string sProcedureName)
		{
			HttpContext Context = HttpContext.Current;
			if ( HttpContext.Current == null || HttpContext.Current.Application == null )
				throw(new Exception("DbProviderFactory.DynamicFactory: Application cannot be NULL."));
			HttpApplicationState Application = HttpContext.Current.Application;
			
			// 11/26/2021 Paul.  Store the data table of rows instead of the command so that connection does not stay referenced. 
			DataTable dt = Application["SqlProcs." + sProcedureName] as DataTable;
			if ( dt == null )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				// 11/26/2021 Paul.  We can't use the same connection as provided as it may already be inside a transaction. 
				using ( IDbConnection con2 = dbf.CreateConnection() )
				{
					con2.Open();
					using ( IDbCommand cmd = con2.CreateCommand() )
					{
						string sSQL;
						sSQL = "select count(*)       " + ControlChars.CrLf
						     + "  from vwSqlProcedures" + ControlChars.CrLf
						     + " where name = @NAME   " + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@NAME", Sql.MetadataName(cmd, Sql.ToString(sProcedureName)));
						int nExists = Sql.ToInteger(cmd.ExecuteScalar());
						if ( nExists == 0 )
						{
							throw(new Exception("Unknown stored procedure " + sProcedureName));
						}
					}
					using ( IDbCommand cmd = con2.CreateCommand() )
					{
						string sSQL;
						sSQL = "select *                       " + ControlChars.CrLf
						     + "  from vwSqlColumns            " + ControlChars.CrLf
						     + " where ObjectName = @OBJECTNAME" + ControlChars.CrLf
						     + "   and ObjectType = 'P'        " + ControlChars.CrLf
						     + " order by colid                " + ControlChars.CrLf;
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, Sql.ToString(sProcedureName)));
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							dt = new DataTable();
							da.Fill(dt);
							Application["SqlProcs." + sProcedureName] = dt;
						}
					}
				}
			}
			
			IDbCommand cmdDynamicProcedure = null;
			cmdDynamicProcedure = con.CreateCommand();
			cmdDynamicProcedure.CommandType = CommandType.StoredProcedure;
			cmdDynamicProcedure.CommandText = Sql.MetadataName(con, Sql.ToString(sProcedureName));
			for ( int j = 0 ; j < dt.Rows.Count; j++ )
			{
				DataRow row = dt.Rows[j];
				string sName      = Sql.ToString (row["ColumnName"]);
				string sCsType    = Sql.ToString (row["CsType"    ]);
				int    nLength    = Sql.ToInteger(row["length"    ]);
				bool   bIsOutput  = Sql.ToBoolean(row["isoutparam"]);
				string sBareName  = sName.Replace("@", "");
				IDbDataParameter par = Sql.CreateParameter(cmdDynamicProcedure, sName, sCsType, nLength);
				if ( bIsOutput )
					par.Direction = ParameterDirection.InputOutput;
			}
			return cmdDynamicProcedure;
		}
	}
}

