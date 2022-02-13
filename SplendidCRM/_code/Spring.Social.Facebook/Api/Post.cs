#region License

/*
 * Copyright 2011-2012 the original author or authors.
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
using System.Collections.Generic;

namespace Spring.Social.Facebook.Api
{
	/// <summary>
	/// Model class representing an entry in a feed. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Post
	{
		public enum enumPostType { POST, CHECKIN, LINK, NOTE, PHOTO, STATUS, VIDEO, SWF, MUSIC }

		public Post()
		{
		}

		public Post(string id, Reference from, DateTime createdTime, DateTime updatedTime)
		{
			this.ID          = id;
			this.From        = from;
			this.CreatedTime = createdTime;
			this.UpdatedTime = updatedTime;
		}

		public string ID { get; set; }

		public Reference From { get; set; }

		public List<Reference> To { get; set; }

		public string Caption { get; set; }

		public string Message { get; set; }

		public string Picture { get; set; }

		public string Link { get; set; }

		public string Name { get; set; }

		public string Description { get; set; }

		public string Icon { get; set; }

		public DateTime? CreatedTime { get; set; }

		public DateTime? UpdatedTime { get; set; }

		public Reference Application { get; set; }

		public enumPostType Type { get; set; }
	
		/// <summary>
		/// Reference for users who have liked this Post. 
		/// May not be a complete list and the size may be different than the value returned from getLikeCount().
		/// For a complete list of likes, use {@link LikeOperations#getLikes(String)}.
		/// </summary>
		public List<Reference> Likes { get; set; }
	
		/// <summary>
		/// The number of likes for this Post. May be different than the size of the list returned from getLikes().
		/// </summary>
		public int LikeCount { get; set; }
	
		public int SharesCount { get; set; }

		/// <summary>
		/// The most recent comments for the post.
		/// </summary>
		public List<Comment> Comments { get; set; }
	
		public string Story { get; set; }
	
		public Dictionary<int, List<StoryTag>> StoryTags { get; set; }

		public int CommentCount { get; set; }
	}
}
