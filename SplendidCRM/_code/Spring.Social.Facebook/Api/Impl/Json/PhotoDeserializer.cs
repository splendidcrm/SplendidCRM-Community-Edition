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
	/// JSON deserializer for Photo. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class PhotoDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Photo photo = null;
			if ( json != null && !json.IsNull )
			{
				photo = new Photo();
				photo.ID          = json.ContainsName("id"          ) ? json.GetValue<string>("id"      ) : String.Empty;
				photo.Name        = json.ContainsName("name"        ) ? json.GetValue<string>("name"    ) : String.Empty;
				photo.Icon        = json.ContainsName("icon"        ) ? json.GetValue<string>("icon"    ) : String.Empty;
				photo.Picture     = json.ContainsName("picture"     ) ? json.GetValue<string>("picture" ) : String.Empty;
				photo.Source      = json.ContainsName("source"      ) ? json.GetValue<string>("source"  ) : String.Empty;
				photo.Height      = json.ContainsName("height"      ) ? json.GetValue<int   >("height"  ) : 0;
				photo.Width       = json.ContainsName("width"       ) ? json.GetValue<int   >("width"   ) : 0;
				photo.Link        = json.ContainsName("link"        ) ? json.GetValue<string>("link"    ) : String.Empty;
				photo.Position    = json.ContainsName("position"    ) ? json.GetValue<int   >("position") : 0;
				photo.CreatedTime = json.ContainsName("created_time") ? JsonUtils.ToDateTime(json.GetValue<string>("created_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				photo.UpdatedTime = json.ContainsName("updated_time") ? JsonUtils.ToDateTime(json.GetValue<string>("updated_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				
				photo.From        = mapper.Deserialize<Reference>(json.GetValue("from" ));
				photo.Place       = mapper.Deserialize<Page     >(json.GetValue("place"));
				photo.Tags        = mapper.Deserialize<List<Tag>>(json.GetValue("tags" ));
				photo.Images      = mapper.Deserialize<List<Photo.Image>>(json.GetValue("images"));
				if ( photo.Images != null )
				{
					int i = 0;
					if ( photo.Images.Count >= 5 ) photo.OversizedImage = photo.Images[i++];
					if ( photo.Images.Count >= 1 ) photo.SourceImage    = photo.Images[i++];
					if ( photo.Images.Count >= 2 ) photo.AlbumImage     = photo.Images[i++];
					if ( photo.Images.Count >= 3 ) photo.SmallImage     = photo.Images[i++];
					if ( photo.Images.Count >= 4 ) photo.TinyImage      = photo.Images[i++];
				}
			}
			return photo;
		}
	}
}
