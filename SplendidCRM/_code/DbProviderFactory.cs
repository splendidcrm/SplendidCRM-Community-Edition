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
using System.Reflection;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for DbProviderFactory.
	/// </summary>
	public class DbProviderFactory
	{
		protected string      m_sConnectionString ;
		protected Assembly    m_asmSqlClient      ;
		protected System.Type m_typSqlConnection  ;
		protected System.Type m_typSqlCommand     ;
		protected System.Type m_typSqlDataAdapter ;
		protected System.Type m_typSqlParameter   ;
		protected System.Type m_typSqlBuilder     ;

		public DbProviderFactory(string sConnectionString, string sAssemblyName, string sConnectionName, string sCommandName, string sDataAdapterName, string sParameterName, string sBuilderName)
		{
			m_sConnectionString = sConnectionString;
			#pragma warning disable 618
			m_asmSqlClient      = Assembly.LoadWithPartialName(sAssemblyName);
			#pragma warning restore 618

			// 03/06/2006 Paul.  Provide better error message if assembly cannot be loaded. 
			if ( m_asmSqlClient == null )
				throw(new Exception("Could not load " + sAssemblyName));
			m_typSqlConnection  = m_asmSqlClient.GetType(sConnectionName );
			m_typSqlCommand     = m_asmSqlClient.GetType(sCommandName    );
			// 04/21/2006 Paul.  SQL Anywhere requires a boxed data adapter that inherits DbDataAdapter.
			if ( sDataAdapterName.StartsWith("SplendidCRM.") )
				m_typSqlDataAdapter = Type.GetType(sDataAdapterName);
			else
				m_typSqlDataAdapter = m_asmSqlClient.GetType(sDataAdapterName);
			m_typSqlParameter   = m_asmSqlClient.GetType(sParameterName  );
			// 08/03/2006 Paul.  Mono does not like the CommandBuilder. 
			//m_typSqlBuilder     = m_asmSqlClient.GetType(sBuilderName    );
		}

		public IDbConnection CreateConnection()
		{
			Type[] types = new Type[1];
			types[0] = Type.GetType("System.String");
			ConstructorInfo info = m_typSqlConnection.GetConstructor(types); 
			object[] parameters = new object[1];
			parameters[0] = m_sConnectionString;
			IDbConnection con = info.Invoke(parameters) as IDbConnection; 
			// 04/21/2006 Paul.  Throw exception if NULL.  
			if ( con == null )
				throw(new Exception("Failed to invoke database connection constructor."));
			return con;
			//return new SqlConnection(sConnectionString);
		}

		public IDbCommand CreateCommand()
		{
			ConstructorInfo info = m_typSqlCommand.GetConstructor(new Type[0]); 
			IDbCommand cmd = info.Invoke(null) as IDbCommand; 
			// 04/21/2006 Paul.  Throw exception if NULL.  
			if ( cmd == null )
				throw(new Exception("Failed to invoke database command constructor."));
			return cmd;
			//return new SqlCommand();
		}

		public DbDataAdapter CreateDataAdapter()
		{
			ConstructorInfo info = m_typSqlDataAdapter.GetConstructor(new Type[0]); 
			DbDataAdapter da = info.Invoke(null) as DbDataAdapter; 
			// 04/21/2006 Paul.  Throw exception if NULL.  SQL Anywhere is having a problem. 
			if ( da == null )
				throw(new Exception("Failed to invoke database adapter constructor."));
			return da;
			//return new SqlDataAdapter();
		}

		public IDbDataParameter CreateParameter()
		{
			ConstructorInfo info = m_typSqlParameter.GetConstructor(new Type[0]); 
			IDbDataParameter par = info.Invoke(null) as IDbDataParameter; 
			// 04/21/2006 Paul.  Throw exception if NULL.  
			if ( par == null )
				throw(new Exception("Failed to invoke database parameter constructor."));
			return par;
			//return new SqlParameter();
		}

		public void DeriveParameters(IDbCommand cmd)
		{
			object[] parameters = new object[1];
			parameters[0] = cmd;
			//m_typSqlBuilder.InvokeMember("DeriveParameters", BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.Static, null, null, parameters);
		}
	}
}

