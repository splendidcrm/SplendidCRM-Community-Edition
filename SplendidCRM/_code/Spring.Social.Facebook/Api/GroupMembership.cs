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
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class GroupMembership
	{
		public GroupMembership()
		{
		}

		public GroupMembership(String id, String name, int version, int bookmarkOrder, bool administrator)
		{
			this.ID            = id           ;
			this.Name          = name         ;
			this.Version       = version      ;
			this.BookmarkOrder = bookmarkOrder;
			this.Administrator = administrator;
		}
	
		/// <summary>
		/// The group ID
		/// </summary>
		public string ID { get; set; }

		/// <summary>
		/// The group name
		/// </summary>
		public string Name { get; set; }

		/// <summary>
		/// The group version (either 0 or 1)
		/// </summary>
		public int Version { get; set; }

		/// <summary>
		/// The position of the group in the user's group bookmarks (or 999999999 if not positioned)
		/// </summary>
		public int BookmarkOrder { get; set; }

		/// <summary>
		/// Returns true if the user is an administrator of the group.
		/// </summary>
		public bool Administrator { get; set; }
	
		/// <summary>
		/// The count of group updates that the user has not yet read.
		/// </summary>
		public int Unread { get; set; }
	}
}
