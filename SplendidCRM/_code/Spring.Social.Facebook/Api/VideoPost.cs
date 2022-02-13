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
	/// Model class representing a Post announcing a Video to a feed. This is not the Video itself.
	/// To get the Video object, get the video's ID by calling getVideoId() then pass it to MediaOperations.getVideo(videoId).
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class VideoPost : Post
	{
		public VideoPost()
		{
		}

		public VideoPost(string id, Reference from, DateTime createdTime, DateTime updatedTime)
			: base(id, from, createdTime, updatedTime)
		{
		}
	
		public string Source { get; set; }
	
		public string VideoId { get; set; }
	
		public List<Tag> Tags { get; set; }
	}
}
