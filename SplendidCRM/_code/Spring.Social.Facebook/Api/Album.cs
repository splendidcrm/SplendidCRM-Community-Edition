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
	/// Model class representing a Facebook photo album.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Album
	{
		public enum enumType    { NORMAL, MOBILE, PROFILE, WALL, FRIENDS_WALLS, UNKNOWN }
		public enum enumPrivacy { EVERYONE, FRIENDS_OF_FRIENDS, FRIENDS, CUSTOM } 

		public Album()
		{
		}

		// http://developers.facebook.com/docs/reference/api/album/
		public Album(String id, Reference from, String name, enumType type, String link, int count, enumPrivacy privacy, DateTime createdTime)
		{
			this.ID          = id         ;
			this.From        = from       ;
			this.Name        = name       ;
			this.Link        = link       ;
			this.Privacy     = privacy    ;
			this.Count       = count      ;
			this.Type        = type       ;
			this.CreatedTime = createdTime;
		}
		
		/// <summary>
		///  The album ID
		/// </summary>
		public string ID { get; set; }
		
		/// <summary>
		///  The profile that created this album
		/// </summary>
		public Reference From { get; set; }
		
		/// <summary>
		///  The title of the album
		/// </summary>
		public string Name { get; set; }
		
		/// <summary>
		///  The description of the album
		/// </summary>
		public string Description { get; set; }
		
		/// <summary>
		///  The location of the album
		/// </summary>
		public string Location { get; set; }
		
		/// <summary>
		///  A link to this album on Facebook
		/// </summary>
		public string Link { get; set; }
		
		/// <summary>
		/// The album cover photo ID
		/// </summary>
		public string CoverPhotoId { get; set; }
		
		/// <summary>
		///  The privacy settings for the album
		/// </summary>
		public enumPrivacy Privacy { get; set; }
		
		/// <summary>
		///  The number of photos in this album
		/// </summary>
		public int Count { get; set; }
		
		/// <summary>
		///  The type of the album: profile, mobile, wall, normal or album
		/// </summary>
		public enumType Type { get; set; }
		
		/// <summary>
		///  The time the photo album was initially created
		/// </summary>
		public DateTime? CreatedTime { get; set; }
		
		/// <summary>
		///  The last time the photo album was updated
		/// </summary>
		public DateTime? UpdatedTime { get; set; }
		
		/// <summary>
		///  Determines whether the UID can upload to the album and returns true if the user owns the album, the album is not full, and the app can add photos to the album
		/// </summary>
		public bool CanUpload { get; set; }
	}
}
