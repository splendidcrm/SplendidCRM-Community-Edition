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
using System.IO;
using System.Collections.Generic;
using Spring.Rest.Client;
using Spring.Http;

namespace Spring.Social.Facebook.Api
{
	/// <summary>
	/// Defines operations for working with albums, photos, and videos.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IMediaOperations
	{
		/// <summary>
		/// Retrieves a list of albums belonging to the authenticated user.
		/// Requires "user_photos" or "friends_photos" permission.
		/// </summary>
		/// <returns>a list {@link Album}s for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Album> GetAlbums();

		/// <summary>
		/// Retrieves a list of albums belonging to the authenticated user.
		/// Requires "user_photos" or "friends_photos" permission.
		/// </summary>
		/// <param name="offset">the offset into the list of albums</param>
		/// <param name="limit">the maximum number of albums to return</param>
		/// <returns>a list {@link Album}s for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Album> GetAlbums(int offset, int limit);

		/// <summary>
		/// Retrieves a list of albums belonging to a specific owner (user, page, etc).
		/// Requires "user_photos" or "friends_photos" permission.
		/// </summary>
		/// <param name="ownerId">the album owner's ID</param>
		/// <returns>a list {@link Album}s for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Album> GetAlbums(string ownerId);

		/// <summary>
		/// Retrieves a list of albums belonging to a specific owner (user, page, etc).
		/// Requires "user_photos" or "friends_photos" permission.
		/// </summary>
		/// <param name="ownerId">the album owner's ID</param>
		/// <param name="offset">the offset into the list of albums</param>
		/// <param name="limit">the maximum number of albums to return</param>
		/// <returns>a list {@link Album}s for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Album> GetAlbums(string ownerId, int offset, int limit);

		/// <summary>
		/// Retrieves data for a specific album.
		/// Requires "user_photos" or "friends_photos" permission if the album is not public.
		/// </summary>
		/// <param name="albumId">the album ID</param>
		/// <returns>the requested {@link Album} object.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the album is not public and if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		Album GetAlbum(string albumId);
	
		/// <summary>
		/// Creates a new photo album.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="name">the name of the album.</param>
		/// <param name="description">the album's description.</param>
		/// <returns>the ID of the newly created album.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string CreateAlbum(string name, string description);

		/// <summary>
		/// Retrieves an album's image as an array of bytes. Returns the image in Facebook's "normal" type.
		/// Requires "user_photos" or "friends_photos" permission if the album is not public.
		/// </summary>
		/// <param name="albumId">the album ID</param>
		/// <returns>an array of bytes containing the album's image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the album is not public and if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		byte[] GetAlbumImage(string albumId);

		/// <summary>
		/// Retrieves an album's image as an array of bytes.
		/// Requires "user_photos" or "friends_photos" permission if the album is not public.
		/// </summary>
		/// <param name="albumId">the album ID</param>
		/// <param name="imageType">the image type (eg., small, normal, large. square)</param>
		/// <returns>an array of bytes containing the album's image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the album is not public and if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		byte[] GetAlbumImage(string albumId, ImageType imageType);

		/// <summary>
		/// Retrieves a list of up to 25 photos that the authenticated user is tagged in.
		/// Requires "user_photos" permission.
		/// </summary>
		/// <returns>a list of {@link Photo} belonging to the authenticated user.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Photo> GetPhotos();

		/// <summary>
		/// Retrieves data for up to 25 photos from a specific album or that a user is tagged in.
		/// If the objectId parameter is the ID of an album, the photos returned are the photos from that album.
		/// If the objectId parameter is the ID of a user, the photos returned are the photos that the user is tagged in.
		/// Requires "user_photos" or "friends_photos" permission if the album is not public.
		/// </summary>
		/// <param name="objectId">either an album ID or a user ID</param>
		/// <returns>a list of {@link Photo}s in the specified album.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the album is not public and if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Photo> GetPhotos(string objectId);

		/// <summary>
		/// Retrieves photo data from a specific album or that a user is tagged in.
		/// If the objectId parameter is the ID of an album, the photos returned are the photos from that album.
		/// If the objectId parameter is the ID of a user, the photos returned are the photos that the user is tagged in.
		/// Requires "user_photos" or "friends_photos" permission if the album is not public.
		/// </summary>
		/// <param name="objectId">either an album ID or a user ID</param>
		/// <param name="offset">the offset into the list of photos</param>
		/// <param name="limit">the maximum number of photos to return</param>
		/// <returns>a list of {@link Photo}s in the specified album.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the album is not public and if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Photo> GetPhotos(string objectId, int offset, int limit);

		/// <summary>
		/// Retrieve data for a specified photo.
		/// Requires "user_photos" or "friends_photos" permission if the photo is not public.
		/// </summary>
		/// <param name="photoId">the photo's ID</param>
		/// <returns>the requested {@link Photo}</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the photo is not public and if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		Photo GetPhoto(string photoId);
	
		/// <summary>
		/// Retrieves a photo's image as an array of bytes. Returns the image in Facebook's "normal" type.
		/// Requires "user_photos" or "friends_photos" permission if the photo is not public.
		/// </summary>
		/// <param name="photoId">the photo ID</param>
		/// <returns>an array of bytes containing the photo's image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the photo is not public and if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		byte[] GetPhotoImage(string photoId);

		/// <summary>
		/// Retrieves a photo's image as an array of bytes.
		/// Requires "user_photos" or "friends_photos" permission if the photo is not public.
		/// </summary>
		/// <param name="photoId">the photo ID</param>
		/// <param name="imageType">the image type (eg., small, normal, large. square)</param>
		/// <returns>an array of bytes containing the photo's image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the photo is not public and if the user has not granted "user_photos" or "friends_photos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		byte[] GetPhotoImage(string photoId, ImageType imageType);
	
		/// <summary>
		/// Uploads a photo to an album created specifically for the application.
		/// Requires "publish_stream" permission.
		/// If no album exists for the application, it will be created.
		/// </summary>
		/// <param name="photo">A {@link Resource} for the photo data. The given Resource must implement the getFilename() method (such as {@link FileSystemResource} or {@link ClassPathResource}).</param>
		/// <returns>the ID of the photo.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string PostPhoto(Resource photo);
	
		/// <summary>
		/// Uploads a photo to an album created specifically for the application.
		/// If no album exists for the application, it will be created.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="photo">A {@link Resource} for the photo data. The given Resource must implement the getFilename() method (such as {@link FileSystemResource} or {@link ClassPathResource}).</param>
		/// <param name="caption">A caption describing the photo.</param>
		/// <returns>the ID of the photo.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string PostPhoto(Resource photo, string caption);
	
		/// <summary>
		/// Uploads a photo to a specific album.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="albumId">the ID of the album to upload the photo to.</param>
		/// <param name="photo">A {@link Resource} for the photo data. The given Resource must implement the getFilename() method (such as {@link FileSystemResource} or {@link ClassPathResource}).</param>
		/// <returns>the ID of the photo.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string PostPhoto(string albumId, Resource photo);
	
		/// <summary>
		/// Uploads a photo to a specific album.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="albumId">the ID of the album to upload the photo to.</param>
		/// <param name="photo">A {@link Resource} for the photo data. The given Resource must implement the getFilename() method (such as {@link FileSystemResource} or {@link ClassPathResource}).</param>
		/// <param name="caption">A caption describing the photo.</param>
		/// <returns>the ID of the photo.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string PostPhoto(string albumId, Resource photo, string caption);
	
		/// <summary>
		/// Retrieves a list of up to 25 videos that the authenticated user is tagged in.
		/// Requires "user_videos" permission.
		/// </summary>
		/// <returns>a list of {@link Video} belonging to the authenticated user.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_videos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Video> GetVideos();

		/// <summary>
		/// Retrieves a list of videos that the authenticated user is tagged in.
		/// Requires "user_videos" permission.
		/// </summary>
		/// <param name="offset">the offset into the list of videos</param>
		/// <param name="limit">the maximum number of videos to return</param>
		/// <returns>a list of {@link Video} belonging to the authenticated user.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_videos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Video> GetVideos(int offset, int limit);

		/// <summary>
		/// Retrieves a list of up to 25 videos that a specified user is tagged in.
		/// Requires "user_videos" or "friends_videos" permission.
		/// </summary>
		/// <param name="userId">the ID of the user who is tagged in the videos</param>
		/// <returns>a list of {@link Video} which the specified user is tagged in.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_videos" or "friends_videos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Video> GetVideos(string userId);

		/// <summary>
		/// Retrieves a list of videos that a specified user is tagged in.
		/// Requires "user_videos" or "friends_videos" permission.
		/// </summary>
		/// <param name="userId">the ID of the user who is tagged in the videos</param>
		/// <param name="offset">the offset into the list of videos</param>
		/// <param name="limit">the maximum number of videos to return</param>
		/// <returns>a list of {@link Video} which the specified user is tagged in.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_videos" or "friends_videos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Video> GetVideos(string userId, int offset, int limit);

		/// <summary>
		/// Retrieves data for a specific video.
		/// Requires "user_videos" or "friends_videos" permission.
		/// </summary>
		/// <param name="videoId">the ID of the video.</param>
		/// <returns>the requested {@link Video} data.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_videos" or "friends_videos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		Video GetVideo(string videoId);
	
		/// <summary>
		/// Retrieves a video's image as an array of bytes. Returns the image in Facebook's "normal" type.
		/// Requires "user_videos" or "friends_videos" permission.
		/// </summary>
		/// <param name="videoId">the video ID</param>
		/// <returns>an array of bytes containing the video's image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_videos" or "friends_videos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		byte[] GetVideoImage(string videoId);

		/// <summary>
		/// Retrieves a video's image as an array of bytes.
		/// Requires "user_videos" or "friends_videos" permission.
		/// </summary>
		/// <param name="videoId">the video ID</param>
		/// <param name="imageType">the image type (eg., small, normal, large. square)</param>
		/// <returns>an array of bytes containing the video's image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_videos" or "friends_videos" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		byte[] GetVideoImage(string videoId, ImageType imageType);
	
		/// <summary>
		/// Uploads a video for the authenticated user.
		/// Requires "publish_stream" permission.
		/// Note that the video will not be immediately available after uploading, as Facebook performs some post-upload processing on the video.
		/// </summary>
		/// <param name="video">A {@link Resource} for the video data. The given Resource must implement the getFilename() method (such as {@link FileSystemResource} or {@link ClassPathResource}).</param>
		/// <returns>the ID of the video.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string PostVideo(Resource video);
	
		/// <summary>
		/// Uploads a video for the authenticated user.
		/// Note that the video will not be immediately available after uploading, as Facebook performs some post-upload processing on the video.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="video">A {@link Resource} for the video data. The given Resource must implement the getFilename() method (such as {@link FileSystemResource} or {@link ClassPathResource}).</param>
		/// <param name="title"></param>
		/// <param name="description"></param>
		/// <returns>the ID of the video.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string PostVideo(Resource video, string title, string description);
	}
}
