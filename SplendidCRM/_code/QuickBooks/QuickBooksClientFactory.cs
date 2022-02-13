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
using System.Collections;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for QuickBooksClientFactory.
	/// </summary>
	public class QuickBooksClientFactory : DbProviderFactory
	{
		// 02/06/2014 Paul.  New QuickBooks factory to allow Remote and Online. 
		public QuickBooksClientFactory(string sConnectionString, string sAssemblyName, string sConnectionName, string sCommandName, string sDataAdapterName, string sParameterName, string sBuilderName)
			: base( sConnectionString
			      , sAssemblyName
			      , sConnectionName
			      , sCommandName
			      , sDataAdapterName
			      , sParameterName
			      , sBuilderName
			      )
		{
		}

		public Hashtable GetLastResult(IDbConnection con)
		{
			return m_typSqlConnection.InvokeMember("GetLastResult", BindingFlags.InvokeMethod | BindingFlags.Instance | BindingFlags.Public, Type.DefaultBinder, con, null) as Hashtable;
		}
	}
}
