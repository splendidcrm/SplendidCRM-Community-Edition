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

using Spring.Json;
using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.Salesforce.Api.Impl
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class SObjectTemplate : AbstractSalesforceOperations, ISObjectOperations
	{
		public SObjectTemplate(RestTemplate restTemplate, bool isAuthorized) : base(restTemplate, isAuthorized)
		{
		}

		#region SObjectOperations Members
		public BasicSObject GetBasicSObject(string version, string name)
		{
			requireAuthorization();
			return FetchObject<BasicSObject>("/services/data/v" + version + "/sobjects/" + name + "/");
		}

		public SObject GetSObject(string version, string name, string id)
		{
			requireAuthorization();
			return FetchObject<SObject>("/services/data/v" + version + "/sobjects/" + name + "/" + id);
		}

		public SObject GetSObject(string version, string name, string id, string[] fields)
		{
			requireAuthorization();
			NameValueCollection queryParameters = new NameValueCollection();
			if ( fields != null )
				queryParameters.Add("fields", String.Join(",", fields));
			return FetchObject<SObject>("/services/data/v" + version + "/sobjects/" + name + "/" + id, queryParameters);
		}

		public byte[] GetSObjectBlob(string version, string name, string id, string field)
		{
			requireAuthorization();
			return FetchObject<byte[]>("/services/data/v" + version + "/sobjects/" + name + "/" + id + "/" + field);
		}

		public void DeleteSObject(string version, string name, string id)
		{
			requireAuthorization();
			this.restTemplate.Delete("/services/data/v" + version + "/sobjects/" + name + "/" + id);
		}
		#endregion
	}
}