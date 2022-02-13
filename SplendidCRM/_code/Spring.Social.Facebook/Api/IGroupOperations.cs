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
	/// Defines operations for retrieving data about groups and group members.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IGroupOperations
	{
		/// <summary>
		/// Retrieve data for a specified group.
		/// </summary>
		/// <param name="groupId">the ID of the group</param>
		/// <returns>a {@link Group} object</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		Group GetGroup(string groupId);
	
		/// <summary>
		/// Retrieves a group's image as an array of bytes. Returns the image in Facebook's "normal" type.
		/// </summary>
		/// <param name="groupId">the group ID</param>
		/// <returns>an array of bytes containing the group's image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		byte[] GetGroupImage(string groupId);

		/// <summary>
		/// Retrieves a group's image as an array of bytes.
		/// </summary>
		/// <param name="groupId">the group ID</param>
		/// <param name="imageType">the image type (eg., small, normal, large. square)</param>
		/// <returns>an array of bytes containing the group's image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		byte[] GetGroupImage(string groupId, ImageType imageType);
	
		/// <summary>
		/// Retrieves the members of the specified group.
		/// </summary>
		/// <param name="groupId">the ID of the group</param>
		/// <returns>a list of {@link Reference}s, one for each member of the group.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<GroupMemberReference> GetMembers(string groupId);

		/// <summary>
		/// Retrieves the profiles for the members of the specified group.
		/// </summary>
		/// <param name="groupId">the ID of the group</param>
		/// <returns>a list of {@link FacebookProfile}s, one for each member of the group.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<FacebookProfile> GetMemberProfiles(string groupId);
	
		/// <summary>
		/// Retrieves a list of group memberships for the authenticated user.
		/// Requires "user_groups" permission. 
		/// </summary>
		/// <returns>a list of {@link GroupMembership}s, one for each group the user is a member of.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_groups" permission.</exception>
		List<GroupMembership> GetMemberships();

		/// <summary>
		/// Retrieves a list of group memberships for a specific user.
		/// Requires "user_groups" or "friends_groups" permission. 
		/// </summary>
		/// <param name="userId">the user ID to retrieve memberships for.</param>
		/// <returns>a list of {@link GroupMembership}s, one for each group the user is a member of.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_groups" or "friends_groups" permission.</exception>
		List<GroupMembership> GetMemberships(string userId);
	
		/// <summary>
		/// Search for groups.
		/// Returns up to 25 groups matching the query.
		/// </summary>
		/// <param name="query">the search query (e.g., "Spring User Group")</param>
		/// <returns>a list of {@link Group}s matching the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<Group> Search(string query);

		/// <summary>
		/// Search for groups.
		/// </summary>
		/// <param name="query">the search query (e.g., "Spring User Group")</param>
		/// <param name="offset">the offset into the matching groups list</param>
		/// <param name="limit">the maximum number of groups to return</param>
		/// <returns>a list of {@link Group}s matching the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<Group> Search(string query, int offset, int limit);
	}
}
