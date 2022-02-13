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
	/// Model class representing a user checkin on Facebook Places.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Checkin
	{
		public Checkin()
		{
		}

		// http://developers.facebook.com/docs/reference/api/checkin/
		public Checkin(string id, Page place, Reference from, Reference application, DateTime createdTime)
		{
			this.ID          = id;
			this.Place       = place;
			this.From        = from;
			this.Application = application;
			this.CreatedTime = createdTime;
		}
		
		/// <summary>
		///  The checkin ID
		/// </summary>
		public string ID { get; set; }
		
		/// <summary>
		///  The ID and name of the user who made the checkin
		/// </summary>
		public Reference From { get; set; }
		
		/// <summary>
		///  The users the author tagged in the checkin
		/// </summary>
		public List<Reference> Tags { get; set; }
		
		/// <summary>
		///  Information about the Facebook Page that represents the location of the checkin
		/// </summary>
		public Page Place { get; set; }
		
		/// <summary>
		///  Information about the application that made the checkin
		/// </summary>
		public Reference Application { get; set; }
		
		/// <summary>
		///  The time the checkin was created
		/// </summary>
		public DateTime? CreatedTime { get; set; }
		
		/// <summary>
		///  Users who like the checkin
		/// </summary>
		public List<Reference> Likes { get; set; }
		
		/// <summary>
		///  The message the user added to the checkin
		/// </summary>
		public string Message { get; set; }
		
		/// <summary>
		///  All of the comments on this link
		/// </summary>
		public List<Comment> Comments { get; set; }
	}
}
