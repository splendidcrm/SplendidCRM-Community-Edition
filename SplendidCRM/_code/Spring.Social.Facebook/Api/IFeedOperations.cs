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
	/// Interface defining operations that can be performed on a Facebook feed.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IFeedOperations
	{
		/// <summary>
		/// Retrieves recent posts for the authenticated user.
		/// Requires "read_stream" permission to read non-public posts. 
		/// Returns up to the most recent 25 posts.
		/// </summary>
		/// <returns>a list of {@link Post}s for the authenticated user. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> GetFeed();

		/// <summary>
		/// Retrieves recent posts for the authenticated user.
		/// Requires "read_stream" permission to read non-public posts. 
		/// </summary>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of {@link Post}s for the authenticated user. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> GetFeed(int offset, int limit);

		/// <summary>
		/// Retrieves recent feed entries for a given user. 
		/// Returns up to the most recent 25 posts.
		/// Requires "read_stream" permission to read non-public posts. 
		/// </summary>
		/// <param name="ownerId">the Facebook ID or alias for the owner (user, group, event, page, etc) of the feed.</param>
		/// <returns>a list of {@link Post}s for the specified user. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> GetFeed(string ownerId);

		/// <summary>
		/// Retrieves recent feed entries for a given user. 
		/// Requires "read_stream" permission to read non-public posts.
		/// Returns up to the most recent 25 posts.
		/// </summary>
		/// <param name="ownerId">the Facebook ID or alias for the owner (user, group, event, page, etc) of the feed.</param>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of {@link Post}s for the specified user. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> GetFeed(string ownerId, int offset, int limit);

		/// <summary>
		/// Retrieves the user's home feed. This includes entries from the user's friends.
		/// Returns up to the most recent 25 posts.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <returns>a list of {@link Post}s from the authenticated user's home feed.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> GetHomeFeed();

		/// <summary>
		/// Retrieves the user's home feed. This includes entries from the user's friends.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of {@link Post}s from the authenticated user's home feed.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> GetHomeFeed(int offset, int limit);

		/// <summary>
		/// Retrieves a single post.
		/// </summary>
		/// <param name="entryId">the entry ID</param>
		/// <returns>the requested {@link Post}</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		Post GetPost(string entryId);
	
		/// <summary>
		/// Retrieves the status entries from the authenticated user's feed.
		/// Returns up to the most recent 25 posts.
		/// </summary>
		/// <returns>a list of status {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<StatusPost> GetStatuses();

		/// <summary>
		/// Retrieves the status entries from the authenticated user's feed.
		/// </summary>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of status {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<StatusPost> GetStatuses(int offset, int limit);

		/// <summary>
		/// Retrieves the status entries from the specified user's feed.
		/// Returns up to the most recent 25 posts.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="userId">the user's ID</param>
		/// <returns>a list of status {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<StatusPost> GetStatuses(string userId);

		/// <summary>
		/// Retrieves the status entries from the specified user's feed.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="userId">the user's ID</param>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of status {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<StatusPost> GetStatuses(string userId, int offset, int limit);

		/// <summary>
		/// Retrieves the link entries from the authenticated user's feed.
		/// Returns up to the most recent 25 posts.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <returns>a list of link {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<LinkPost> GetLinks();

		/// <summary>
		/// Retrieves the link entries from the authenticated user's feed.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of link {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<LinkPost> GetLinks(int offset, int limit);

		/// <summary>
		/// Retrieves the link entries from the specified owner's feed.
		/// Returns up to the most recent 25 posts.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="ownerId">the owner of the feed (could be a user, page, event, etc)</param>
		/// <returns>a list of link {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<LinkPost> GetLinks(string ownerId);

		/// <summary>
		/// Retrieves the link entries from the specified owner's feed.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="ownerId">the owner of the feed (could be a user, page, event, etc)</param>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of link {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<LinkPost> GetLinks(string ownerId, int offset, int limit);

		/// <summary>
		/// Retrieves the note entries from the authenticated user's feed.
		/// Returns up to the most recent 25 posts.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <returns>a list of note {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<NotePost> GetNotes();

		/// <summary>
		/// Retrieves the note entries from the authenticated user's feed.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of note {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<NotePost> GetNotes(int offset, int limit);

		/// <summary>
		/// Retrieves the note entries from the specified owner's feed.
		/// Returns up to the most recent 25 posts.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="ownerId">the owner of the feed (could be a user, page, event, etc)</param>
		/// <returns>a list of note {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<NotePost> GetNotes(string ownerId);

		/// <summary>
		/// Retrieves the note entries from the specified owner's feed.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="ownerId">the owner of the feed (could be a user, page, event, etc)</param>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of note {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<NotePost> GetNotes(string ownerId, int offset, int limit);

		/// <summary>
		/// Retrieves the post entries from the authenticated user's feed.
		/// Returns up to the most recent 25 posts.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <returns>a list of post {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> GetPosts();

		/// <summary>
		/// Retrieves the post entries from the authenticated user's feed.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of post {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> GetPosts(int offset, int limit);

		/// <summary>
		/// Retrieves the post entries from the specified owner's feed.
		/// Returns up to the most recent 25 posts.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="ownerId">the owner of the feed (could be a user, page, event, etc)</param>
		/// <returns>a list of post {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> GetPosts(string ownerId);

		/// <summary>
		/// Retrieves the post entries from the specified owner's feed.
		/// Requires "read_stream" permission. 
		/// </summary>
		/// <param name="ownerId">the owner of the feed (could be a user, page, event, etc)</param>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of post {@link Post}s. </returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> GetPosts(string ownerId, int offset, int limit);

		/// <summary>
		/// Posts a status update to the authenticated user's feed.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="message">the message to post.</param>
		/// <returns>the ID of the new feed entry.</returns>
		/// <exception cref="DuplicateStatusException">if the status message duplicates a previously posted status.</exception>
		/// <exception cref="RateLimitExceededException">if the per-user/per-app rate limit is exceeded.</exception>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string UpdateStatus(string message);

		/// <summary>
		/// Posts a link to the authenticated user's feed.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="message">a message to send with the link.</param>
		/// <param name="link"></param>
		/// <returns>the ID of the new feed entry.</returns>
		/// <exception cref="DuplicateStatusException">if the post duplicates a previous post.</exception>
		/// <exception cref="RateLimitExceededException">if the per-user/per-app rate limit is exceeded.</exception>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string PostLink(string message, FacebookLink link);

		/// <summary>
		/// Posts a message to a feed.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="ownerId">the feed owner ID. Could be a user ID or a page ID.</param>
		/// <param name="message">the message to post.</param>
		/// <returns>the id of the new feed entry.</returns>
		/// <exception cref="DuplicateStatusException">if the post duplicates a previous post.</exception>
		/// <exception cref="RateLimitExceededException">if the per-user/per-app rate limit is exceeded.</exception>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string Post(string ownerId, string message);
	
		/// <summary>
		/// Posts a link to a feed.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="ownerId">the feed owner ID. Could be a user ID or a page ID.</param>
		/// <param name="message">a message to send with the link.</param>
		/// <param name="link"></param>
		/// <returns>the ID of the new feed entry.</returns>
		/// <exception cref="DuplicateStatusException">if the post duplicates a previous post.</exception>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string PostLink(string ownerId, string message, FacebookLink link);

		/// <summary>
		/// Deletes a post.
		/// Requires "publish_stream" permission and the post must have been created by the same application.
		/// </summary>
		/// <param name="id">the feed entry ID</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void DeletePost(string id);

		/// <summary>
		/// Searches Facebook's public feed.
		/// Returns up to 25 posts that match the query.
		/// </summary>
		/// <param name="query">the search query (e.g., "Dr Seuss")</param>
		/// <returns>a list of {@link Post}s that match the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<Post> SearchPublicFeed(string query);

		/// <summary>
		/// Searches Facebook's public feed.
		/// </summary>
		/// <param name="query">the search query (e.g., "Dr Seuss")</param>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of {@link Post}s that match the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<Post> SearchPublicFeed(string query, int offset, int limit);

		/// <summary>
		/// Searches the authenticated user's home feed.
		/// Returns up to 25 posts that match the query.
		/// </summary>
		/// <param name="query">the search query (e.g., "Dr Seuss")</param>
		/// <returns>a list of {@link Post}s that match the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> SearchHomeFeed(string query);

		/// <summary>
		/// Searches the authenticated user's home feed.
		/// </summary>
		/// <param name="query">the search query (e.g., "Dr Seuss")</param>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of {@link Post}s that match the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> SearchHomeFeed(string query, int offset, int limit);

		/// <summary>
		/// Searches the authenticated user's feed.
		/// Returns up to 25 posts that match the query.
		/// </summary>
		/// <param name="query">the search query (e.g., "football")</param>
		/// <returns>a list of {@link Post}s that match the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> SearchUserFeed(string query);

		/// <summary>
		/// Searches the authenticated user's feed.
		/// </summary>
		/// <param name="query">the search query (e.g., "football")</param>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of {@link Post}s that match the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> SearchUserFeed(string query, int offset, int limit);

		/// <summary>
		/// Searches a specified user's feed.
		/// Returns up to 25 posts that match the query.
		/// </summary>
		/// <param name="userId">the ID of the user whose feed is to be searched</param>
		/// <param name="query">the search query (e.g., "football")</param>
		/// <returns>a list of {@link Post}s that match the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> SearchUserFeed(string userId, string query);

		/// <summary>
		/// Searches a specified user's feed.
		/// </summary>
		/// <param name="userId">the ID of the user whose feed is to be searched</param>
		/// <param name="query">the search query (e.g., "football")</param>
		/// <param name="offset">the offset into the feed to start retrieving posts.</param>
		/// <param name="limit">the maximum number of posts to return.</param>
		/// <returns>a list of {@link Post}s that match the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Post> SearchUserFeed(string userId, string query, int offset, int limit);
	}
}
