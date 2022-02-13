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
	/// Model class representing a video.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Video
	{
		public Video()
		{
		}

		// http://developers.facebook.com/docs/reference/api/video/
		public Video(string id, Reference from, string picture, string embedHtml, string icon, string source, DateTime createdTime, DateTime updatedTime)
		{
			this.ID          = id         ;
			this.From        = from       ;
			this.Picture     = picture    ;
			this.EmbedHtml   = embedHtml  ;
			this.Icon        = icon       ;
			this.Source      = source     ;
			this.CreatedTime = createdTime;
			this.UpdatedTime = updatedTime;
		}
		
		/// <summary>
		///  The video ID
		/// </summary>
		public string ID { get; set; }
		
		/// <summary>
		///  The profile (user or page) that created the video
		/// </summary>
		public Reference From { get; set; }
		
		/// <summary>
		///  The users who are tagged in this video
		/// </summary>
		public List<Tag> Tags { get; set; }
		
		/// <summary>
		///  The video title or caption
		/// </summary>
		public string Name { get; set; }
		
		/// <summary>
		///  The description of the video
		/// </summary>
		public string Description { get; set; }
		
		/// <summary>
		///  The URL for the thumbnail picture for the video
		/// </summary>
		public string Picture { get; set; }
		
		/// <summary>
		///  The html element that may be embedded in an Web page to play the video
		/// </summary>
		public string EmbedHtml { get; set; }
		
		/// <summary>
		///  The icon that Facebook displays when video are published to the Feed
		/// </summary>
		public string Icon { get; set; }
		
		/// <summary>
		///  A URL to the raw, playable video file
		/// </summary>
		public string Source { get; set; }
		
		/// <summary>
		///  The time the video was initially published
		/// </summary>
		public DateTime? CreatedTime { get; set; }
		
		/// <summary>
		///  The last time the video or its caption were updated
		/// </summary>
		public DateTime? UpdatedTime { get; set; }
		
		/// <summary>
		///  All of the comments on this video
		/// </summary>
		public List<Comment> Comments { get; set; }
	}
}
