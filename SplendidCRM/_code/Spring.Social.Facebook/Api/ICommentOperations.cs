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
	/// Defines operations for reading and posting comments to Facebook.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface ICommentOperations
	{
		/// <summary>
		/// Retrieves the first 25 comments for a given object.
		/// </summary>
		/// <param name="objectId">the ID of the object</param>
		/// <returns>a list of {@link Comment}s for the specified object</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<Comment> GetComments(string objectId);

		/// <summary>
		/// Retrieves comments for a given object.
		/// </summary>
		/// <param name="objectId">the ID of the object</param>
		/// <param name="offset">the offset into the list of comments to start retrieving comments</param>
		/// <param name="limit">the maximum number of comments to retrieve</param>
		/// <returns>a list of {@link Comment}s for the specified object</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<Comment> GetComments(string objectId, int offset, int limit);

		/// <summary>
		/// Retrieves a single comment
		/// </summary>
		/// <param name="commentId">the comment ID</param>
		/// <returns>the requested {@link Comment}</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		Comment GetComment(string commentId);
	
		/// <summary>
		/// Posts a comment on an object on behalf of the authenticated user.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="objectId">the object ID</param>
		/// <param name="message">the comment message</param>
		/// <returns>the new comment's ID</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string AddComment(string objectId, string message);

		/// <summary>
		/// Deletes a comment.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="commentId">the comment ID</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void DeleteComment(string commentId);

		/// <summary>
		/// Retrieve a list of references to users who have liked a given object.
		/// </summary>
		/// <param name="objectId"></param>
		/// <returns>a list of {@link Reference}s</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<Reference> GetLikes(string objectId);
	}
}
