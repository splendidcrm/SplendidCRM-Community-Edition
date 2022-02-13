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
using System.Net;
using System.Collections.Generic;
using System.Collections.Specialized;

using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.Salesforce.Api.Impl
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class SearchTemplate : AbstractSalesforceOperations, ISearchOperations
	{
		public SearchTemplate(RestTemplate restTemplate, bool isAuthorized) : base(restTemplate, isAuthorized)
		{
		}

		#region ISearchOperations Members
		public QueryResult Query(string version, string queryString)
		{
			requireAuthorization();
			return restTemplate.GetForObject<QueryResult>("/services/data/v" + version + "/query/?q=" + HttpUtils.FormEncode(queryString));
		}

		public QueryResult QueryAll(string version, string queryString)
		{
			requireAuthorization();
			QueryResult query = restTemplate.GetForObject<QueryResult>("/services/data/v" + version + "/query/?q=" + HttpUtils.FormEncode(queryString));
			if ( query != null && !query.Done && !String.IsNullOrEmpty(query.NextRecordsUrl) )
			{
				QueryResult next = null;
				do
				{
					next = this.QueryMore(query.NextRecordsUrl);
					if ( next != null && next.Records != null )
					{
						foreach ( SObject record in next.Records )
						{
							query.Records.Add(record);
						}
					}
				}
				while ( next != null && !next.Done && !String.IsNullOrEmpty(next.NextRecordsUrl) );
				query.Done           = true;
				query.NextRecordsUrl = String.Empty;
			}
			return query;
		}

		public QueryResult QueryMore(string queryLocator)
		{
			requireAuthorization();
			return restTemplate.GetForObject<QueryResult>(queryLocator);
		}

		public List<SObject> Search(string version, string searchString)
		{
			requireAuthorization();
			// http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_sosl_find.htm
			if ( !searchString.StartsWith("FIND ") )
				searchString = "FIND " + searchString;
			return restTemplate.GetForObject<List<SObject>>("/services/data/v" + version + "/search/?q=" + HttpUtils.FormEncode(searchString));
		}

		#endregion
	}
}