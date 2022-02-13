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
	/// JSON deserializer for Video. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class VideoDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Video video = null;
			if ( json != null && !json.IsNull )
			{
				video = new Video();
				video.ID          = json.ContainsName("id"          ) ? json.GetValue<string>("id"         ) : String.Empty;
				video.Name        = json.ContainsName("name"        ) ? json.GetValue<string>("name"       ) : String.Empty;
				video.Description = json.ContainsName("description" ) ? json.GetValue<string>("description") : String.Empty;
				video.Picture     = json.ContainsName("picture"     ) ? json.GetValue<string>("picture"    ) : String.Empty;
				video.EmbedHtml   = json.ContainsName("embed_html"  ) ? json.GetValue<string>("embed_html" ) : String.Empty;
				video.Icon        = json.ContainsName("icon"        ) ? json.GetValue<string>("icon"       ) : String.Empty;
				video.Source      = json.ContainsName("source"      ) ? json.GetValue<string>("source"     ) : String.Empty;
				video.CreatedTime = json.ContainsName("created_time") ? JsonUtils.ToDateTime(json.GetValue<string>("created_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				video.UpdatedTime = json.ContainsName("updated_time") ? JsonUtils.ToDateTime(json.GetValue<string>("updated_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				
				video.From        = mapper.Deserialize<Reference    >(json.GetValue("from"    ));
				video.Tags        = mapper.Deserialize<List<Tag    >>(json.GetValue("tags"    ));
				video.Comments    = mapper.Deserialize<List<Comment>>(json.GetValue("comments"));
			}
			return video;
		}
	}
}
