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
	class UserTemplate : AbstractSalesforceOperations, IUserOperations
	{
		public UserTemplate(RestTemplate restTemplate, bool isAuthorized) : base(restTemplate, isAuthorized)
		{
		}

		#region IUserOperations Members
		public bool GetPasswordExpiration(string version, string userId)
		{
			requireAuthorization();
			JsonValue json = this.restTemplate.GetForObject<JsonValue>("/services/data/v" + version + "/sobjects/User/" + userId + "/password");
			if ( json != null && !json.IsNull && json.ContainsName("isExpired") )
			{
				return json.GetValue<bool>("isExpired");
			}
			return false;
		}

		public void SetPassword(string version, string userId, string password)
		{
			requireAuthorization();
			this.restTemplate.PostForObject<JsonValue>("/services/data/v" + version + "/sobjects/User/" + userId + "/password", "{\"NewPassword\", \"" + password + "\"}");
		}

		public string ResetPassword(string version, string userId)
		{
			requireAuthorization();
			JsonValue json = Delete<JsonValue>("/services/data/v" + version + "/sobjects/User/" + userId + "/password");
			if ( json != null && !json.IsNull && json.ContainsName("NewPassword") )
			{
				return json.GetValue<string>("NewPassword");
			}
			return String.Empty;
		}
		#endregion
	}
}