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
	/// JSON deserializer for StoryTag. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class StoryTagDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			StoryTag video = null;
			if ( json != null && !json.IsNull )
			{
				video = new StoryTag();
				video.ID     = json.ContainsName("id"    ) ? json.GetValue<string>("id"    ) : String.Empty;
				video.Name   = json.ContainsName("name"  ) ? json.GetValue<string>("name"  ) : String.Empty;
				video.Offset = json.ContainsName("offset") ? json.GetValue<int   >("offset") : 0;
				video.Length = json.ContainsName("length") ? json.GetValue<int   >("length") : 0;
			}
			return video;
		}
	}
}
