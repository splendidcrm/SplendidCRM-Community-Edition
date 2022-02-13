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
	/// JSON deserializer for Comment. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class CommentDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Comment comment = null;
			if ( json != null && !json.IsNull )
			{
				comment = new Comment();
				comment.ID          = json.ContainsName("id"          ) ? json.GetValue<string>("id"     ) : String.Empty;
				comment.Message     = json.ContainsName("message"     ) ? json.GetValue<string>("message") : String.Empty;
				comment.CreatedTime = json.ContainsName("created_time") ? JsonUtils.ToDateTime(json.GetValue<string>("created_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;

				comment.From        = mapper.Deserialize<Reference      >(json.GetValue("from" ));
				// 04/12/2012 Paul.  Likes is a connection object, so make sure that this is not the same likes property value. 
				// 04/15/2012 Paul.  Likes can be a number or an array. 
				JsonValue jsonLikes = json.GetValue("likes");
				if ( jsonLikes != null && !jsonLikes.IsNull )
				{
					if ( jsonLikes.IsArray )
					{
						comment.Likes       = mapper.Deserialize<List<Reference>>(jsonLikes);
						comment.LikesCount  = (comment.Likes != null) ? comment.Likes.Count : 0;
					}
					else if ( jsonLikes.IsNumber )
					{
						comment.LikesCount = jsonLikes.GetValue<int>();
					}
				}
			}
			return comment;
		}
	}
}
