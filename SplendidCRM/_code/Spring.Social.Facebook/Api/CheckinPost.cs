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
	/// Model class representing a feed Post to announce a Checkin on a user's wall.
	/// Note that although a CheckinPost contains some details about a Checkin, it is not the Checkin object itself.
	/// To get the Checkin, get the Checkin ID by calling getCheckinId() and then call getChecking(checkinId) on CheckinOperations.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class CheckinPost : Post
	{
		public CheckinPost()
		{
		}

		public CheckinPost(string id, Reference from, DateTime createdTime, DateTime updatedTime)
			: base(id, from, createdTime, updatedTime)
		{
		}

		public Page Place { get; set; }

		public List<Tag> Tags { get; set; }

		public String CheckinId()
		{
			return this.ID.Split('_')[1];
		}
	}
}
