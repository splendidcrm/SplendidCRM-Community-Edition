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
	/// JSON deserializer for Post. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class PostDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Post post = null;
			if ( json != null && !json.IsNull )
			{
				post = new Post();
				post.ID          = json.ContainsName("id"          ) ? json.GetValue<string>("id"         ) : String.Empty;
				post.Message     = json.ContainsName("message"     ) ? json.GetValue<string>("message"    ) : String.Empty;
				post.Caption     = json.ContainsName("caption"     ) ? json.GetValue<string>("caption"    ) : String.Empty;
				post.Picture     = json.ContainsName("picture"     ) ? json.GetValue<string>("picture"    ) : String.Empty;
				post.Link        = json.ContainsName("link"        ) ? json.GetValue<string>("link"       ) : String.Empty;
				post.Name        = json.ContainsName("name"        ) ? json.GetValue<string>("name"       ) : String.Empty;
				post.Description = json.ContainsName("description" ) ? json.GetValue<string>("description") : String.Empty;
				post.Icon        = json.ContainsName("icon"        ) ? json.GetValue<string>("icon"       ) : String.Empty;
				post.Story       = json.ContainsName("story"       ) ? json.GetValue<string>("story"      ) : String.Empty;
				post.CreatedTime = json.ContainsName("created_time") ? JsonUtils.ToDateTime(json.GetValue<string>("created_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				post.UpdatedTime = json.ContainsName("updated_time") ? JsonUtils.ToDateTime(json.GetValue<string>("updated_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				
				// 04/15/2012 Paul.  Shares is not a simple integer.  It contains a count node. 
				if ( json.ContainsName("shares") )
				{
					JsonValue jsonShares = json.GetValue("shares");
					post.SharesCount = jsonShares.ContainsName("count") ? jsonShares.GetValue<int>("count") : 0;
				}
				
				post.Type        = TypeDeserializer(json.GetValue("type"));
				post.From        = mapper.Deserialize<Reference                      >(json.GetValue("from"       ));
				post.Application = mapper.Deserialize<Reference                      >(json.GetValue("application"));
				post.To          = mapper.Deserialize<List<Reference>                >(json.GetValue("to"         ));
				post.Likes       = mapper.Deserialize<List<Reference>                >(json.GetValue("likes"      ));
				post.Comments    = mapper.Deserialize<List<Comment  >                >(json.GetValue("comments"   ));
				post.StoryTags   = mapper.Deserialize<Dictionary<int, List<StoryTag>>>(json.GetValue("story_tags" ));
				
				post.LikeCount    = (post.Likes    != null ) ? post.Likes.Count    : 0;
				post.CommentCount = (post.Comments != null ) ? post.Comments.Count : 0;
			}
			return post;
		}

		private static Post.enumPostType TypeDeserializer(JsonValue json)
		{
			Post.enumPostType value = Post.enumPostType.POST;
			if ( json != null && !json.IsNull )
			{
				try
				{
					string code = json.GetValue<string>();
					code = code.ToUpper();
					value = (Post.enumPostType) Enum.Parse(typeof(Post.enumPostType), code);
				}
				catch
				{
				}
			}
			return value;
		}
	}
}
