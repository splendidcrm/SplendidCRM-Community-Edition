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
	/// JSON deserializer for Invitation. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class InvitationDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Invitation invite = null;
			if ( json != null && !json.IsNull )
			{
				invite = new Invitation();
				invite.EventId    = json.ContainsName("id"        ) ? json.GetValue<string>("id"  ) : String.Empty;
				invite.Name       = json.ContainsName("name"      ) ? json.GetValue<string>("name") : String.Empty;
				invite.StartTime  = json.ContainsName("start_time") ? JsonUtils.ToDateTime(json.GetValue<string>("start_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				invite.EndTime    = json.ContainsName("end_time"  ) ? JsonUtils.ToDateTime(json.GetValue<string>("end_time"  ), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				invite.RsvpStatus = RsvpStatusDeserializer(json.GetValue("rsvp_status"));
			}
			return invite;
		}

		private static RsvpStatus RsvpStatusDeserializer(JsonValue json)
		{
			RsvpStatus value = RsvpStatus.UNSURE;
			if ( json != null && !json.IsNull )
			{
				try
				{
					string code = json.GetValue<string>();
					code = code.ToUpper();
					value = (RsvpStatus) Enum.Parse(typeof(RsvpStatus), code);
				}
				catch
				{
				}
			}
			return value;
		}
	}
}
