#region License

/*
 * Copyright (C) 2012 SplendidCRM Software, Inc. All Rights Reserved. 
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#endregion

using System;
using System.Collections.Generic;
using System.Collections.Specialized;

using Spring.Rest.Client;

namespace Spring.Social.Salesforce.Api
{
	/// <summary>
	/// Interface specifying a basic set of operations for interacting with Salesforce.
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	public interface ISalesforceApi
	{
		/// <summary>
		/// Fetches an object, extracting it into the given Java type
		/// Requires appropriate permission to fetch the object.
		/// </summary>
		/// <param name="objectId">the Salesforce object's ID</param>
		/// <returns>an Java object representing the requested Salesforce object.</returns>
		T FetchObject<T>(string objectId) where T : class;

		/// <summary>
		/// Fetches an object, extracting it into the given Java type
		/// Requires appropriate permission to fetch the object.
		/// </summary>
		/// <param name="objectId">the Salesforce object's ID</param>
		/// <param name="queryParameters">query parameters to include in the request</param>
		/// <returns>an Java object representing the requested Salesforce object.</returns>
		T FetchObject<T>(string objectId, NameValueCollection queryParameters) where T : class;

		/// <summary>
		/// Fetches connections, extracting them into a collection of the given Java type 
		/// Requires appropriate permission to fetch the object connection.
		/// </summary>
		/// <param name="objectId">the ID of the object to retrieve the connections for.</param>
		/// <param name="connectionName">the connection name.</param>
		/// <param name="fields">the fields to include in the response.</param>
		/// <returns>a list of Java objects representing the Salesforce objects in the connections.</returns>
		List<T> FetchConnections<T>(string objectId, string connectionName, string[] fields) where T : class;
	
		/// <summary>
		/// Fetches connections, extracting them into a collection of the given Java type 
		/// Requires appropriate permission to fetch the object connection.
		/// </summary>
		/// <param name="objectId">the ID of the object to retrieve the connections for.</param>
		/// <param name="connectionName">the connection name.</param>
		/// <param name="queryParameters">query parameters to include in the request</param>
		/// <returns>a list of Java objects representing the Salesforce objects in the connections.</returns>
		List<T> FetchConnections<T>(string objectId, string connectionName, NameValueCollection queryParameters) where T : class;
	}
}
