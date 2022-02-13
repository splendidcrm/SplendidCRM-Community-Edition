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
	/// Model class representing a photo.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Photo
	{
	#if !SILVERLIGHT
		[Serializable]
	#endif
		public class Image
		{
			public Image()
			{
			}

			public Image(string source, int width, int height)
			{
				this.Source = source;
				this.Width  = width;
				this.Height = height;
			}

			public int Width { get; set; }

			public int Height { get; set; }

			public string Source { get; set; }
		}

		public Photo()
		{
		}

		// http://developers.facebook.com/docs/reference/api/photo/
		public Photo(string id, Reference from, string link, string icon, DateTime createdTime, List<Image> images)
		{
			this.ID          = id         ;
			this.From        = from       ;
			this.Link        = link       ;
			this.Icon        = icon       ;
			this.CreatedTime = createdTime;
			this.Images      = images     ;
			
			int i = 0;
			if ( images.Count >= 5 ) this.OversizedImage = images[i++];
			if ( images.Count >= 1 ) this.SourceImage    = images[i++];
			if ( images.Count >= 2 ) this.AlbumImage     = images[i++];
			if ( images.Count >= 3 ) this.SmallImage     = images[i++];
			if ( images.Count >= 4 ) this.TinyImage      = images[i++];
		}
		
		/// <summary>
		///  The photo ID
		/// </summary>
		public string ID { get; set; }
		
		/// <summary>
		///  The profile (user or page) that posted this photo
		/// </summary>
		public Reference From { get; set; }
		
		/// <summary>
		///  The tagged users and their positions in this photo
		/// </summary>
		public List<Tag> Tags { get; set; }
		
		/// <summary>
		///  The user provided caption given to this photo - do not include advertising in this field
		/// </summary>
		public string Name { get; set; }
		
		/// <summary>
		///  The icon that Facebook displays when photos are published to the Feed
		/// </summary>
		public string Icon { get; set; }
		
		/// <summary>
		///  The thumbnail-sized source of the photo
		/// </summary>
		public string Picture { get; set; }
		
		/// <summary>
		///  The source image of the photo - currently this can have a maximum width or height of 720px, increasing to 960px on 1st March 2012
		/// </summary>
		public string Source { get; set; }
		
		/// <summary>
		///  The height of the photo in pixels
		/// </summary>
		public int Height { get; set; }
		
		/// <summary>
		///  The width of the photo in pixels
		/// </summary>
		public int Width { get; set; }
		
		public List<Image> Images { get; set; }

		/// <summary>
		///  An oversized image. May be null if no oversized image was provided.
		/// </summary>
		public Image OversizedImage { get; set; }
		
		public Image SourceImage { get; set; }
		
		public Image SmallImage { get; set; }
		
		public Image AlbumImage { get; set; }
		
		public Image TinyImage { get; set; }
		
		/// <summary>
		///  A link to the photo on Facebook
		/// </summary>
		public string Link { get; set; }
		
		/// <summary>
		///  Location associated with a Photo, if any
		/// </summary>
		public Page Place { get; set; }
		
		/// <summary>
		///  The time the photo was initially published
		/// </summary>
		public DateTime? CreatedTime { get; set; }
		
		/// <summary>
		///  The last time the photo or its caption was updated
		/// </summary>
		public DateTime? UpdatedTime { get; set; }
		
		/// <summary>
		///  The position of this photo in the album
		/// </summary>
		public int Position { get; set; }
	}
}
