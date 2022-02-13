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
	/// JSON deserializer for GroupMembership. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class GroupMembershipDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			GroupMembership group = null;
			if ( json != null && !json.IsNull )
			{
				group = new GroupMembership();
				group.ID            = json.ContainsName("id"            ) ? json.GetValue<string>("id"            ) : String.Empty;
				group.Name          = json.ContainsName("name"          ) ? json.GetValue<string>("name"          ) : String.Empty;
				group.Version       = json.ContainsName("version"       ) ? json.GetValue<int   >("version"       ) : 0;
				group.BookmarkOrder = json.ContainsName("bookmark_order") ? json.GetValue<int   >("bookmark_order") : 0;
				group.Administrator = json.ContainsName("administrator" ) ? json.GetValue<bool  >("administrator" ) : false;
				group.Unread        = json.ContainsName("unread"        ) ? json.GetValue<int   >("unread"        ) : 0;
			}
			return group;
		}
	}
}
