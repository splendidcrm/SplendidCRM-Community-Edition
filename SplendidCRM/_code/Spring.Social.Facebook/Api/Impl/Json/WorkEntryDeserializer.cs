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
using System.Collections.Generic;

using Spring.Json;

namespace Spring.Social.Facebook.Api.Impl.Json
{
	/// <summary>
	/// JSON deserializer for WorkEntry. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class WorkEntryDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			WorkEntry entry = null;
			if ( json != null && !json.IsNull )
			{
				entry = new WorkEntry();
				entry.StartDate = json.ContainsName("start_date") ? json.GetValue<string>("start_date") : String.Empty;
				entry.EndDate   = json.ContainsName("end_date"  ) ? json.GetValue<string>("end_date"  ) : String.Empty;
				
				entry.Employer  = mapper.Deserialize<Reference>(json.GetValue("employer"));
			}
			return entry;
		}
	}
}
