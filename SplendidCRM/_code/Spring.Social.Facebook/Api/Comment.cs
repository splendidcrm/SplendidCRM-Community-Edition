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
	/// Model class representing a comment.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Comment
	{
		public Comment()
		{
		}

		// http://developers.facebook.com/docs/reference/api/Comment/
		public Comment(string id, Reference from, string message, DateTime createdTime)
		{
			this.ID          = id         ;
			this.From        = from       ;
			this.Message     = message    ;
			this.CreatedTime = createdTime;
		}
		
		/// <summary>
		/// The Facebook ID of the comment
		/// </summary>
		public String ID { get; set; }
		
		/// <summary>
		/// The user that created the comment
		/// </summary>
		public Reference From { get; set; }
		
		/// <summary>
		/// The comment text
		/// </summary>
		public String Message { get; set; }
		
		/// <summary>
		/// The timedate the comment was created
		/// </summary>
		public DateTime? CreatedTime { get; set; }
		
		/// <summary>
		/// The number of times this comment was liked
		/// </summary>
		public int LikesCount { get; set; }
		
		/// <summary>
		/// A list of references to users who liked this comment.
		/// May be null, as Facebook often sends only a count of likes.
		/// In some cases (such as a comment on a checkin) the likes will be a list of references.
		/// </summary>
		public List<Reference> Likes { get; set; }
	}
}
