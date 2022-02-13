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
	/// Defines operations for working with a user's likes and interests.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface ILikeOperations
	{
		/// <summary>
		/// Retrieves a list of references to users who have liked the specified object.
		/// </summary>
		/// <param name="objectId">the object ID (an Album, Checkin, Comment, Note, Photo, Post, or Video).</param>
		/// <returns>a list of {@link Reference} objects for the users who have liked the object.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetLikes(string objectId);
	
		/// <summary>
		/// Retrieves a list of pages that the authenticated user has liked.
		/// Requires "user_likes" permission. Returns an empty list if permission isn't granted.
		/// </summary>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetPagesLiked();

		/// <summary>
		/// Retrieves a list of pages that the given user has liked. 
		/// Requires "user_likes" permission for the authenticated user and "friends_likes" for the authenticated user's friends. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <param name="userId">the ID of the user</param>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" or "friends_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetPagesLiked(string userId);

		/// <summary>
		/// Like an object on behalf of the authenticated user.
		/// The type of object to be liked is limited to Album, Checkin, Comment, Note, Photo, Post, or Video.
		/// You cannot like a Facebook Page through this API.
		/// Requires "publish_stream" permission and permission to access the object being liked.
		/// </summary>
		/// <param name="objectId">the object ID</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission or if the user does not have permission to access the object.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void Like(string objectId);

		/// <summary>
		/// Unlike an object on behalf of the authenticated user.
		/// The type of object to be liked is limited to Album, Checkin, Comment, Note, Photo, Post, or Video.
		/// You cannot unlike a Facebook Page through this API.
		/// Requires "publish_stream" permission and permission to access the object being liked.
		/// </summary>
		/// <param name="objectId">the object ID</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission or if the user does not have permission to access the object.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void Unlike(string objectId);

		/// <summary>
		/// Retrieves a list of books that the authenticated user likes. 
		/// Requires "user_likes" permission. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetBooks();

		/// <summary>
		/// Retrieves a list of books that the given user has liked. Requires
		/// "user_likes" permission for the authenticated user and "friends_likes"
		/// for the authenticated user's friends. Returns an empty list if permission
		/// isn't granted.
		/// </summary>
		/// <param name="userId">the ID of the user</param>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetBooks(string userId);

		/// <summary>
		/// Retrieves a list of movies that the authenticated user likes. 
		/// Requires "user_likes" permission. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetMovies();

		/// <summary>
		/// Retrieves a list of movies that the given user has liked. 
		/// Requires "user_likes" permission for the authenticated user and "friends_likes" for the authenticated user's friends. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <param name="userId">the ID of the user</param>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetMovies(string userId);

		/// <summary>
		/// Retrieves a list of music that the authenticated user likes. 
		/// Requires "user_likes" permission. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetMusic();

		/// <summary>
		/// Retrieves a list of music that the given user has liked. 
		/// Requires "user_likes" permission for the authenticated user and "friends_likes" for the authenticated user's friends. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <param name="userId">the ID of the user</param>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetMusic(string userId);

		/// <summary>
		/// Retrieves a list of television shows that the authenticated user likes.
		/// Requires "user_likes" permission. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetTelevision();

		/// <summary>
		/// Retrieves a list of television shows that the given user has liked.
		/// Requires "user_likes" permission for the authenticated user and "friends_likes" for the authenticated user's friends. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <param name="userId">the ID of the user</param>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" or "friends_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetTelevision(string userId);

		/// <summary>
		/// Retrieves a list of activities that the authenticated user likes.
		/// Requires "user_activities" permission. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_activities" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetActivities();

		/// <summary>
		/// Retrieves a list of activities that the given user likes. 
		/// Requires "user_activities" permission for the authenticated user and "friends_activities" for the authenticated user's friends. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <param name="userId">the ID of the user</param>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_activities" or "friends_activities" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetActivities(string userId);

		/// <summary>
		/// Retrieves a list of interests that the authenticated user likes. 
		/// Requires "user_interests" permission. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_interests" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetInterests();

		/// <summary>
		/// Retrieves a list of interests that the given user likes. 
		/// Requires "user_interests" permission for the authenticated user and "friends_interests" for the authenticated user's friends. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <param name="userId">the ID of the user</param>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_interests" or "friends_interests" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetInterests(string userId);

		/// <summary>
		/// Retrieves a list of games that the authenticated user likes. 
		/// Requires "user_likes" permission. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetGames();

		/// <summary>
		/// Retrieves a list of games that the given user likes. 
		/// Requires "user_likes" permission for the authenticated user and "friends_likes" for the authenticated user's friends. 
		/// Returns an empty list if permission isn't granted.
		/// </summary>
		/// <param name="userId">the ID of the user</param>
		/// <returns>a list of {@link Page} objects</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_likes" or "friends_likes" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> GetGames(string userId);
	}
}
