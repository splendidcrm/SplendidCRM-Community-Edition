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
using System.Globalization;

using Spring.Json;

namespace Spring.Social.Salesforce.Api.Impl.Json
{
	/// <summary>
	/// JSON deserializer for Version. 
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class SalesforceVersionDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			SalesforceVersion version = null;
			if ( json != null && !json.IsNull )
			{
				version = new SalesforceVersion();
				version.Label   = json.ContainsName("label"  ) ? json.GetValue<string>("label"  ) : String.Empty;
				version.Version = json.ContainsName("version") ? json.GetValue<string>("version") : String.Empty;
				version.Url     = json.ContainsName("url"    ) ? json.GetValue<string>("url"    ) : String.Empty;
			}
			return version;
		}
	}
}
