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
	/// Defines operations for interacting with a user's friends and friend lists.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IFriendOperations
	{
		/// <summary>
		/// Retrieves a list of custom friend lists belonging to the authenticated user.
		/// Requires "read_friendlists" permission.
		/// </summary>
		/// <returns>a list {@link Reference}s, each representing a friends list for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_friendlists" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetFriendLists();

		/// <summary>
		/// Retrieves a list of custom friend lists belonging to the specified user.
		/// Requires "read_friendlists" permission.
		/// </summary>
		/// <param name="userId">the user's ID</param>
		/// <returns>a list {@link Reference}s, each representing a friends list for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "read_friendlists" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetFriendLists(string userId);

		/// <summary>
		/// Retrieves a reference to the specified friend list.
		/// </summary>
		/// <param name="friendListId">the friend list ID.</param>
		/// <returns>a {@link Reference} to the requested friend list.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		Reference GetFriendList(string friendListId);
	
		/// <summary>
		/// Retrieves references for all users who are members of the specified friend list.
		/// </summary>
		/// <param name="friendListId">the friend list ID.</param>
		/// <returns>a list of {@link Reference}, each representing a member of the friend list.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetFriendListMembers(string friendListId);

		/// <summary>
		/// Creates a new friend list for the authenticated user.
		/// Requires "manage_friendlists" permission.
		/// </summary>
		/// <param name="name">the name of the friend list.</param>
		/// <returns>the ID of the newly created friend list.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "manage_friendlists" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string CreateFriendList(string name);

		/// <summary>
		/// Creates a new friend list.
		/// Requires "manage_friendlists" permission.
		/// </summary>
		/// <param name="userId">the user ID to create the friend list for.</param>
		/// <param name="name">the name of the friend list.</param>
		/// <returns>the ID of the newly created friend list.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "manage_friendlists" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string CreateFriendList(string userId, string name);
	
		/// <summary>
		/// Deletes a friend list.
		/// Requires "manage_friendlists" permission.
		/// </summary>
		/// <param name="friendListId">the ID of the friend list to remove.</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "manage_friendlists" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void DeleteFriendList(string friendListId);

		/// <summary>
		/// Adds a friend to a friend list.
		/// Requires "manage_friendlists" permission.
		/// </summary>
		/// <param name="friendListId">the friend list ID</param>
		/// <param name="friendId">The ID of the user to add to the list. The user must be a friend of the list's owner.</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "manage_friendlists" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void AddToFriendList(string friendListId, string friendId);
	
		/// <summary>
		/// Removes a friend from a friend list.
		/// Requires "manage_friendlists" permission.
		/// </summary>
		/// <param name="friendListId">the friend list ID</param>
		/// <param name="friendId">The ID of the user to add to the list.</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "manage_friendlists" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void RemoveFromFriendList(string friendListId, string friendId);
	
		/// <summary>
		/// Retrieves a list of user references for the authenticated user's friends.
		/// </summary>
		/// <returns>a list {@link Reference}s, each representing a friend of the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetFriends();
	
		/// <summary>
		/// Retrieves a list of the authenticating user's friends' IDs.
		/// </summary>
		/// <returns>a list of Strings, where each entry is the ID of one of the user's friends.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<String> GetFriendIds();
	
		/// <summary>
		/// Retrieves profile data for up to 100 of the authenticated user's friends.
		/// For additional friend profiles, you must specify the offset and limit.
		/// The list of profiles is ordered by each user's Facebook ID.
		/// </summary>
		/// <returns>a list {@link FacebookProfile}s, each representing a friend of the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<FacebookProfile> GetFriendProfiles();

		/// <summary>
		/// Retrieves profile data for the authenticated user's friends.
		/// The list of profiles is ordered by each user's Facebook ID.
		/// </summary>
		/// <param name="offset">the offset into the friends list to start retrieving profiles.</param>
		/// <param name="limit">the maximum number of profiles to return.</param>
		/// <returns>a list {@link FacebookProfile}s, each representing a friend of the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<FacebookProfile> GetFriendProfiles(int offset, int limit);

		/// <summary>
		/// Retrieves a list of user references for the specified user's friends.
		/// The list of profiles is ordered by each user's Facebook ID.
		/// </summary>
		/// <param name="userId">the user's ID</param>
		/// <returns>a list {@link Reference}s, each representing a friend of the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetFriends(string userId);

		/// <summary>
		/// Retrieves a list of the authenticating user's friends' IDs.
		/// The list of profiles is ordered by each user's Facebook ID.
		/// </summary>
		/// <param name="userId">the user's ID</param>
		/// <returns>a list of Strings, where each entry is the ID of one of the user's friends.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<String> GetFriendIds(string userId);
	
		/// <summary>
		/// Retrieves profile data for up to 100 of the specified user's friends.
		/// The list of profiles is ordered by each user's Facebook ID.
		/// </summary>
		/// <param name="userId">the user's ID</param>
		/// <returns>a list {@link FacebookProfile}s, each representing a friend of the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<FacebookProfile> GetFriendProfiles(string userId);

		/// <summary>
		/// Retrieves profile data for the specified user's friends.
		/// The list of profiles is ordered by each user's Facebook ID.
		/// </summary>
		/// <param name="userId">the user's ID</param>
		/// <param name="offset">the offset into the friends list to start retrieving profiles.</param>
		/// <param name="limit">the maximum number of profiles to return.</param>
		/// <returns>a list {@link FacebookProfile}s, each representing a friend of the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<FacebookProfile> GetFriendProfiles(string userId, int offset, int limit);
	
		/// <summary>
		/// Retrieves a list of FamilyMember references for the authenticated user.
		/// </summary>
		/// <returns>a list of {@link FamilyMember}s, each representing a Facebook user that the user is related to.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<FamilyMember> GetFamily();
	
		/// <summary>
		/// Retrieves a list of FamilyMember references for the specified user.
		/// </summary>
		/// <param name="userId">the ID of the user to retrieve family members for.</param>
		/// <returns>a list of {@link FamilyMember}s, each representing a Facebook user that the user is related to.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<FamilyMember> GetFamily(string userId);
	
		/// <summary>
		/// Retrieves a list of user references that the authenticated user and the specified user have in common as friends.
		/// </summary>
		/// <param name="userId">the ID of the user to check for common friendships with.</param>
		/// <returns>a list of {@link Reference}s, each representing a friend that the two users have in common.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetMutualFriends(string userId);

		/// <summary>
		/// Retrieves a list of user reference for the users that the authenticated user is subscribed to.
		/// Requires "user_subscriptions" permission.
		/// </summary>
		/// <returns>a list of {@link Reference}s, each representing a Facebook user that the user is subscribed to.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetSubscribedTo();

		/// <summary>
		/// Retrieves a list of user reference for the users that the specified user is subscribed to.
		/// Requires "user_subscriptions" permission for the authenticated user or "friends_subscriptions" permission for accessing the authenticated user's friends subscriptions.
		/// </summary>
		/// <param name="userId">the ID of the user to fetch subscriptions for.</param>
		/// <returns>a list of {@link Reference}s, each representing a Facebook user that the user is subscribed to.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetSubscribedTo(string userId);

		/// <summary>
		/// Retrieves a list of user reference for the users that are subscribed to the authenticated user.
		/// Requires "user_subscriptions" permission.
		/// </summary>
		/// <returns>a list of {@link Reference}s, each representing a Facebook user that the user is subscribed to.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetSubscribers();

		/// <summary>
		/// Retrieves a list of user reference for the users that are subscribed to the specified user.
		/// Requires "user_subscriptions" permission for the authenticated user or "friends_subscriptions" permission for accessing the authenticated user's friends subscriptions.
		/// </summary>
		/// <param name="userId">the ID of the user to fetch subscriptions for.</param>
		/// <returns>a list of {@link Reference}s, each representing a Facebook user that the user is subscribed to.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> GetSubscribers(string userId);
	}
}
