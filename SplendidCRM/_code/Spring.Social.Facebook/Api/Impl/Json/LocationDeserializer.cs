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
	/// JSON deserializer for Location. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class LocationDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Location location  = null;
			if ( json != null && !json.IsNull )
			{
				location = new Location();
				location.Latitude  = json.ContainsName("latitude" ) ? json.GetValue<double>("latitude" ) : 0.0;
				location.Longitude = json.ContainsName("longitude") ? json.GetValue<double>("longitude") : 0.0;
				location.Street    = json.ContainsName("street"   ) ? json.GetValue<string>("street"   ) : String.Empty;
				location.City      = json.ContainsName("city"     ) ? json.GetValue<string>("city"     ) : String.Empty;
				location.State     = json.ContainsName("state"    ) ? json.GetValue<string>("state"    ) : String.Empty;
				location.Country   = json.ContainsName("country"  ) ? json.GetValue<string>("country"  ) : String.Empty;
				location.Zip       = json.ContainsName("zip"      ) ? json.GetValue<string>("zip"      ) : String.Empty;
			}
			return location;
		}
	}
}
