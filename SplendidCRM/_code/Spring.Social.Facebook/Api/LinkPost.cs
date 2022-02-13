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

namespace Spring.Social.Facebook.Api
{
	/// <summary>
	/// Model class representing a link Post to a user's wall.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class LinkPost : Post
	{
		public LinkPost()
		{
		}

		public LinkPost(string id, Reference from, DateTime createdTime, DateTime updatedTime)
			: base(id, from, createdTime, updatedTime)
		{
		}
	
		/// <summary>
		/// The ID of the object referred to in the link.
		/// As an example, an event may appear in a user's feed as a link to the event.
		/// May be null if the link doesn't refer to another Facebook object.
		/// </summary>
		public string ObjectId { get; set; }
	}
}
