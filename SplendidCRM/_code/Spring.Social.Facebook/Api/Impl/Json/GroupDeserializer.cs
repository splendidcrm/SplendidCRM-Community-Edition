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
	/// JSON deserializer for Group. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class GroupDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Group group = null;
			if ( json != null && !json.IsNull )
			{
				group = new Group();
				group.ID           = json.ContainsName("id"          ) ? json.GetValue<string>("id"         ) : String.Empty;
				group.Version      = json.ContainsName("version"     ) ? json.GetValue<int   >("version"    ) : 0;
				group.Icon         = json.ContainsName("icon"        ) ? json.GetValue<string>("icon"       ) : String.Empty;
				group.Name         = json.ContainsName("name"        ) ? json.GetValue<string>("name"       ) : String.Empty;
				group.Description  = json.ContainsName("description" ) ? json.GetValue<string>("description") : String.Empty;
				group.Link         = json.ContainsName("link"        ) ? json.GetValue<string>("link"       ) : String.Empty;
				group.UpdatedTime  = json.ContainsName("updated_time") ? JsonUtils.ToDateTime(json.GetValue<string>("updated_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;

				group.Owner        = mapper.Deserialize<Reference>(json.GetValue("owner"  ));
				group.Privacy      = PrivacyDeserializer(json.GetValue("privacy"));
			}
			return group;
		}

		private static Group.enumPrivacy PrivacyDeserializer(JsonValue json)
		{
			Group.enumPrivacy value = Group.enumPrivacy.OPEN;
			if ( json != null && !json.IsNull )
			{
				try
				{
					string code = json.GetValue<string>();
					code = code.ToUpper();
					value = (Group.enumPrivacy) Enum.Parse(typeof(Group.enumPrivacy), code);
				}
				catch
				{
				}
			}
			return value;
		}
	}
}
