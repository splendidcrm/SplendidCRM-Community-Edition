#region License

/*
 * Copyright 2002-2012 the original author or authors.
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
using System.Globalization;

using Spring.Json;

namespace Spring.Social.Facebook.Api.Impl.Json
{
	/// <summary>
	/// JSON deserializer for Account. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class AccountDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Account account = null;
			if ( json != null && !json.IsNull )
			{
				account = new Account();
				account.ID          = json.ContainsName("id"          ) ? json.GetValue<string>("id"          ) : String.Empty;
				account.Name        = json.ContainsName("name"        ) ? json.GetValue<string>("name"        ) : String.Empty;
				account.Category    = json.ContainsName("category"    ) ? json.GetValue<string>("category"    ) : String.Empty;
				account.AccessToken = json.ContainsName("access_token") ? json.GetValue<string>("access_token") : String.Empty;
			}
			return account;
		}
	}
}
