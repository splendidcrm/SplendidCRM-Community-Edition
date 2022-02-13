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
using System.IO;
using System.Collections.Generic;
using Spring.Rest.Client;
using Spring.Http;

namespace Spring.Social.Salesforce.Api
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	public interface ISearchOperations
	{
		/// 04/22/2012 Paul.  These are the SOAP API methods. 
		/// QueryResult  query(QueryOptions QueryOptions, MruHeader MruHeader, string queryString);
		/// QueryResult  queryAll(QueryOptions QueryOptions, string queryString);
		/// QueryResult  queryMore(QueryOptions QueryOptions, string queryLocator);
		/// SearchResult search(string searchString);

		/// <summary>
		/// Performs an Search query, returning a list of results.
		/// </summary>
		/// <param name="version"></param>
		/// <param name="queryString">The SOQL query</param>
		/// <returns>a list of objects of type</returns>
		QueryResult Query(string version, string queryString);

		/// <summary>
		/// Performs an Search query, returning a list of results.
		/// </summary>
		/// <param name="version"></param>
		/// <param name="queryString">The SOQL query</param>
		/// <returns>a list of objects of type</returns>
		QueryResult QueryAll(string version, string queryString);

		/// <summary>
		/// If the initial query returns only part of the results, the end of the response will contain a field called nextRecordsUrl
		/// </summary>
		/// <param name="queryLocator"></param>
		/// <returns>a list of objects of type</returns>
		QueryResult QueryMore(string queryLocator);

		/// <summary>
		/// Performs an Search query, returning a list of results.
		/// </summary>
		/// <param name="version"></param>
		/// <param name="searchString">The SOQL query</param>
		/// <returns>a list of objects of type</returns>
		List<SObject> Search(string version, string searchString);
	}
}
