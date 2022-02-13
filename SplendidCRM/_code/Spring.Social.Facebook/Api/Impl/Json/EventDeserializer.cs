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
	/// JSON deserializer for Event. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class EventDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Event evt = null;
			if ( json != null && !json.IsNull )
			{
				evt = new Event();
				evt.ID           = json.ContainsName("id"          ) ? json.GetValue<string>("id"         ) : String.Empty;
				evt.Name         = json.ContainsName("name"        ) ? json.GetValue<string>("name"       ) : String.Empty;
				evt.Description  = json.ContainsName("description" ) ? json.GetValue<string>("description") : String.Empty;
				evt.Location     = json.ContainsName("location"    ) ? json.GetValue<string>("location"   ) : String.Empty;
				// 04/15/2012 Paul.  Facebook uses ISO-8601 formatted date/time "yyyy-MM-ddTHH:mm:ss". 
				evt.StartTime    = json.ContainsName("start_time"  ) ? JsonUtils.ToDateTime(json.GetValue<string>("start_time"  ), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				evt.EndTime      = json.ContainsName("end_time"    ) ? JsonUtils.ToDateTime(json.GetValue<string>("end_time"    ), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				evt.UpdatedTime  = json.ContainsName("updated_time") ? JsonUtils.ToDateTime(json.GetValue<string>("updated_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;

				evt.Owner        = mapper.Deserialize<Reference>(json.GetValue("owner"));
				evt.Venue        = mapper.Deserialize<Location >(json.GetValue("venue"));
				evt.Privacy      = PrivacyDeserializer(json.GetValue("privacy"));
			}
			return evt;
		}

		private static Event.enumPrivacy PrivacyDeserializer(JsonValue json)
		{
			Event.enumPrivacy value = Event.enumPrivacy.OPEN;
			if ( json != null && !json.IsNull )
			{
				try
				{
					string code = json.GetValue<string>();
					code = code.ToUpper();
					value = (Event.enumPrivacy) Enum.Parse(typeof(Event.enumPrivacy), code);
				}
				catch
				{
				}
			}
			return value;
		}
	}
}
