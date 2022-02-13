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
	public class Group
	{
		public enum enumPrivacy { OPEN, SECRET, CLOSED }

		public Group()
		{
		}

		// http://developers.facebook.com/docs/reference/api/group/
		public Group(string id, Reference owner, string name, enumPrivacy privacy, string icon, DateTime updatedTime)
		{
			this.ID          = id         ;
			this.Owner       = owner      ;
			this.Name        = name       ;
			this.Privacy     = privacy    ;
			this.Icon        = icon       ;
			this.UpdatedTime = updatedTime;
		}
		
		/// <summary>
		/// The group ID
		/// </summary>
		public String ID { get; set; }
		
		/// <summary>
		///  A flag which indicates if the group was created prior to launch of the current groups product in October 2010
		/// </summary>
		public int Version { get; set; }
		
		/// <summary>
		///  The URL for the group's icon
		/// </summary>
		public string Icon { get; set; }
		
		/// <summary>
		///  The profile that created this group
		/// </summary>
		public Reference Owner { get; set; }
		
		/// <summary>
		///  The name of the group
		/// </summary>
		public string Name { get; set; }
		
		/// <summary>
		///  A brief description of the group
		/// </summary>
		public string Description { get; set; }
		
		/// <summary>
		///  The URL for the group's website
		/// </summary>
		public string Link { get; set; }
		
		/// <summary>
		///  The privacy setting of the group
		/// </summary>
		public enumPrivacy Privacy { get; set; }
		
		/// <summary>
		///  The last time the group was updated
		/// </summary>
		public DateTime? UpdatedTime { get; set; }
	}
}
