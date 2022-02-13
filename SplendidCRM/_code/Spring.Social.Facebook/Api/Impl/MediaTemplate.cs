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
using System.Net;
using System.Collections.Generic;
using System.Collections.Specialized;

using Spring.Json;
using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.Facebook.Api.Impl
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class MediaTemplate : AbstractFacebookOperations, IMediaOperations
	{
		public MediaTemplate(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized)
			: base(applicationNamespace, restTemplate, isAuthorized)
		{
		}

		#region IMediaOperations Members
		public List<Album> GetAlbums()
		{
			return GetAlbums("me", 0, 25);
		}

		public List<Album> GetAlbums(int offset, int limit)
		{
			return GetAlbums("me", offset, limit);
		}

		public List<Album> GetAlbums(string userId)
		{
			return GetAlbums(userId, 0, 25);
		}
	
		public List<Album> GetAlbums(string userId, int offset, int limit)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("offset", offset.ToString());
			parameters.Add("limit" , limit .ToString());
			return this.FetchConnections<Album>(userId, "albums", parameters);
		}

		public Album GetAlbum(string albumId)
		{
			requireAuthorization();
			return this.FetchObject<Album>(albumId);
		}
	
		public string CreateAlbum(string name, string description)
		{
			requireAuthorization();
			return CreateAlbum("me", name, description);
		}
	
		public string CreateAlbum(string ownerId, string name, string description)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("name"   , name       );
			parameters.Add("message", description);
			return this.Publish(ownerId, "albums", parameters);
		}
	
		public byte[] GetAlbumImage(string albumId)
		{
			// 04/15/2012 Paul.  Default to small as normal might not exit. 
			// Unsupported type, 'normal'.  Supported types: thumbnail, small, album
			return GetAlbumImage(albumId, ImageType.SMALL);
		}
	
		public byte[] GetAlbumImage(string albumId, ImageType imageType)
		{
			requireAuthorization();
			return this.FetchImage(albumId, "picture", imageType);
		}
	
		public List<Photo> GetPhotos()
		{
			return GetPhotos("me", 0, 25);
		}
	
		public List<Photo> GetPhotos(string objectId)
		{
			return GetPhotos(objectId, 0, 25);
		}
	
		public List<Photo> GetPhotos(string objectId, int offset, int limit)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("offset", offset.ToString());
			parameters.Add("limit" , limit .ToString());
			return this.FetchConnections<Photo>(objectId, "photos", parameters);
		}
	
		public Photo GetPhoto(string photoId)
		{
			requireAuthorization();
			return this.FetchObject<Photo>(photoId);
		}
	
		public byte[] GetPhotoImage(string photoId)
		{
			return GetPhotoImage(photoId, ImageType.NORMAL);
		}
	
		public byte[] GetPhotoImage(string photoId, ImageType imageType)
		{
			requireAuthorization();
			return this.FetchImage(photoId, "picture", imageType);
		}

		public string PostPhoto(Resource photo)
		{
			requireAuthorization();
			Dictionary<string, object> parts = new Dictionary<string, object>();
			parts.Add("source", photo);
			return this.Publish("me", "photos", parts);
		}
	
		public string PostPhoto(Resource photo, string caption)
		{
			requireAuthorization();
			Dictionary<string, object> parts = new Dictionary<string, object>();
			parts.Add("source" , photo  );
			parts.Add("message", caption);
			return this.Publish("me", "photos", parts);
		}
	
		public string PostPhoto(string albumId, Resource photo)
		{
			requireAuthorization();
			Dictionary<string, object> parts = new Dictionary<string, object>();
			parts.Add("source", photo);
			return this.Publish(albumId, "photos", parts);
		}
	
		public string PostPhoto(string albumId, Resource photo, string caption)
		{
			requireAuthorization();
			Dictionary<string, object> parts = new Dictionary<string, object>();
			parts.Add("source" , photo  );
			parts.Add("message", caption);
			return this.Publish(albumId, "photos", parts);
		}
	
		public List<Video> GetVideos()
		{
			return GetVideos("me", 0, 25);
		}

		public List<Video> GetVideos(int offset, int limit)
		{
			return GetVideos("me", offset, limit);
		}

		public List<Video> GetVideos(string userId)
		{
			return GetVideos(userId, 0, 25);
		}
	
		public List<Video> GetVideos(string userId, int offset, int limit)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("offset", offset.ToString());
			parameters.Add("limit" , limit .ToString());
			return this.FetchConnections<Video>(userId, "videos", parameters);
		}
	
		public Video GetVideo(string videoId)
		{
			requireAuthorization();
			return this.FetchObject<Video>(videoId);
		}
	
		public byte[] GetVideoImage(string videoId)
		{
			// 04/15/2012 Paul.  Default to small as normal might not exit. 
			// Unsupported type, 'normal'.  Supported types: thumbnail, small, album
			return GetVideoImage(videoId, ImageType.SMALL);
		}
	
		public byte[] GetVideoImage(string videoId, ImageType imageType)
		{
			requireAuthorization();
			return this.FetchImage(videoId, "picture", imageType);
		}
	
		public string PostVideo(Resource video)
		{
			requireAuthorization();
			Dictionary<string, object> parts = new Dictionary<string, object>();
			parts.Add("file", video);
			JsonValue response = restTemplate.PostForObject<JsonValue>("me/videos", parts);
			return response.GetValue<string>("id");
		}
	
		public string PostVideo(Resource video, string title, string description)
		{
			requireAuthorization();
			Dictionary<string, object> parts = new Dictionary<string, object>();
			parts.Add("file"       , video      );
			parts.Add("title"      , title      );
			parts.Add("description", description);
			JsonValue response = restTemplate.PostForObject<JsonValue>("me/videos", parts);
			return response.GetValue<string>("id");
		}
		#endregion
	}
}