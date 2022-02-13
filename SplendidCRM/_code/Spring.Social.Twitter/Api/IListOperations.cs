#region License

/*
 * Copyright 2002-2012 the original author or authors.
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
#if NET_4_0 || SILVERLIGHT_5
using System.Threading.Tasks;
#else
using Spring.Rest.Client;
using Spring.Http;
#endif

namespace Spring.Social.Twitter.Api
{
    /// <summary>
    /// Interface defining the operations for working with a user's lists.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    public interface IListOperations
    {
#if NET_4_0 || SILVERLIGHT_5
        /// <summary>
        /// Asynchronously retrieves user lists for the authenticated user.
        /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="UserList"/>s for the specified user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<UserList>> GetListsAsync();

        /// <summary>
        /// Asynchronously retrieves user lists for the given user.
        /// </summary>
        /// <param name="userId">The ID of the Twitter user.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="UserList"/>s for the specified user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<UserList>> GetListsAsync(long userId);

        /// <summary>
        /// Asynchronously retrieves user lists for the given user.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="UserList"/>s for the specified user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<UserList>> GetListsAsync(string screenName);

        /// <summary>
        /// Asynchronously retrieves a specific user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the requested <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> GetListAsync(long listId);

        /// <summary>
        /// Asynchronously retrieves a specific user list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The lists's slug.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the requested <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> GetListAsync(string screenName, string listSlug);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetListStatusesAsync(long listId);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetListStatusesAsync(long listId, int count);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetListStatusesAsync(long listId, int count, long sinceId, long maxId);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetListStatusesAsync(string screenName, string listSlug);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetListStatusesAsync(string screenName, string listSlug, int count);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetListStatusesAsync(string screenName, string listSlug, int count, long sinceId, long maxId);

        /// <summary>
        /// Asynchronously creates a new user list.
        /// </summary>
        /// <param name="name">The name of the list.</param>
        /// <param name="description">The list description.</param>
        /// <param name="isPublic">If true, the list will be public; if false the list will be private.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the newly created <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> CreateListAsync(string name, string description, bool isPublic);

        /// <summary>
        /// Asynchronously updates an existing user list
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="name">The new name of the list.</param>
        /// <param name="description">The new list description.</param>
        /// <param name="isPublic">If true, the list will be public; if false the list will be private.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the newly updated <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> UpdateListAsync(long listId, string name, string description, bool isPublic);

        /// <summary>
        /// Asynchronously removes a user list.
        /// </summary>
        /// <param name="listId">The ID of the list to be removed.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the deleted <see cref="UserList"/>, if successful.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> DeleteListAsync(long listId);

	    /// <summary>
        /// Asynchronously retrieves a list of Twitter profiles whose users are members of the list.
	    /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="TwitterProfile"/>s.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<TwitterProfile>> GetListMembersAsync(long listId);

        /// <summary>
        /// Asynchronously retrieves a list of Twitter profiles whose users are members of the list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="TwitterProfile"/>s.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<TwitterProfile>> GetListMembersAsync(string screenName, string listSlug);

        /// <summary>
        /// Asynchronously adds one or more new members to a user list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="newMemberIds">One or more profile IDs of the Twitter profiles to add to the list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> AddToListAsync(long listId, params long[] newMemberIds);

        /// <summary>
        /// Asynchronously adds one or more new members to a user list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="newMemberScreenNames">One or more profile IDs of the Twitter profiles to add to the list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> AddToListAsync(long listId, params string[] newMemberScreenNames);

	    /// <summary>
        /// Asynchronously removes a member from a user list.
	    /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="memberId">The ID of the member to be removed.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task RemoveFromListAsync(long listId, long memberId);

        /// <summary>
        /// Asynchronously removes a member from a user list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="memberScreenName">The screen name of the member to be removed.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task RemoveFromListAsync(long listId, string memberScreenName);

	    /// <summary>
        /// Asynchronously subscribes the authenticating user to a list.
	    /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> SubscribeAsync(long listId);

        /// <summary>
        /// Asynchronously subscribes the authenticating user to a list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> SubscribeAsync(string screenName, string listSlug);

        /// <summary>
        /// Asynchronously unsubscribes the authenticating user from a list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> UnsubscribeAsync(long listId);

        /// <summary>
        /// Asynchronously unsubscribes the authenticating user from a list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<UserList> UnsubscribeAsync(string screenName, string listSlug);

        /// <summary>
        /// Asynchronously retrieves the subscribers to a list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="TwitterProfile"/>s for the list's subscribers.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<TwitterProfile>> GetListSubscribersAsync(long listId);

        /// <summary>
        /// Asynchronously retrieves the subscribers to a list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="TwitterProfile"/>s for the list's subscribers.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<TwitterProfile>> GetListSubscribersAsync(string screenName, string listSlug);

	    /// <summary>
        /// Asynchronously retrieves the lists that a given user is a member of.
	    /// </summary>
        /// <param name="userId">The user ID.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="UserList"/>s that the user is a member of.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<CursoredList<UserList>> GetMembershipsAsync(long userId);

        /// <summary>
        /// Asynchronously retrieves the lists that a given user is a member of.
        /// </summary>
        /// <param name="screenName">The user's screen name.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="UserList"/>s that the user is a member of.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<CursoredList<UserList>> GetMembershipsAsync(string screenName);

        /// <summary>
        /// Asynchronously retrieves the lists that a given user is subscribed to.
        /// </summary>
        /// <param name="userId">The user ID.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="UserList"/>s that the user is subscribed to.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<CursoredList<UserList>> GetSubscriptionsAsync(long userId);

        /// <summary>
        /// Asynchronously retrieves the lists that a given user is subscribed to.
        /// </summary>
        /// <param name="screenName">The user's screen name.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="UserList"/>s that the user is subscribed to.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<CursoredList<UserList>> GetSubscriptionsAsync(string screenName);

        /// <summary>
        /// Asynchronously checks to see if a given user is a member of a given list.
        /// </summary>
        /// <param name="listId">The list ID.</param>
        /// <param name="memberId">The user ID to check for membership.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a value indicating whether or not the user is a member of the list.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<bool> IsMemberAsync(long listId, long memberId);
	
        /// <summary>
        /// Asynchronously checks to see if a given user is a member of a given list.
        /// </summary>
        /// <param name="screenName">The screen name of the list's owner.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="memberScreenName">The screenName to check for membership.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a value indicating whether or not the user is a member of the list.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<bool> IsMemberAsync(string screenName, string listSlug, string memberScreenName);

        /// <summary>
        /// Asynchronously checks to see if a given user subscribes to a given list.
        /// </summary>
        /// <param name="listId">The list ID.</param>
        /// <param name="subscriberId">The user ID to check for subscribership.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a value indicating whether or not the user subscribes to the list.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<bool> IsSubscriberAsync(long listId, long subscriberId);
	
        /// <summary>
        /// Asynchronously checks to see if a given user subscribes to a given list.
        /// </summary>
        /// <param name="screenName">The screen name of the list's owner.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="subscriberScreenName">The screenName to check for subscribership.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a value indicating whether or not the user subscribes to the list.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<bool> IsSubscriberAsync(string screenName, string listSlug, string subscriberScreenName);
#else
#if !SILVERLIGHT
        /// <summary>
        /// Retrieves user lists for the authenticated user.
        /// </summary>
        /// <returns>
        /// A list of <see cref="UserList"/>s for the specified user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<UserList> GetLists();

        /// <summary>
        /// Retrieves user lists for the given user.
        /// </summary>
        /// <param name="userId">The ID of the Twitter user.</param>
        /// <returns>
        /// A list of <see cref="UserList"/>s for the specified user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<UserList> GetLists(long userId);

        /// <summary>
        /// Retrieves user lists for the given user.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <returns>
        /// A list of <see cref="UserList"/>s for the specified user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<UserList> GetLists(string screenName);

        /// <summary>
        /// Retrieves a specific user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <returns>
        /// The requested <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList GetList(long listId);

        /// <summary>
        /// Retrieves a specific user list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The lists's slug.</param>
        /// <returns>
        /// The requested <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList GetList(string screenName, string listSlug);

        /// <summary>
        /// Retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <returns>
        /// A list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<Tweet> GetListStatuses(long listId);

        /// <summary>
        /// Retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <returns>
        /// A list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<Tweet> GetListStatuses(long listId, int count);

        /// <summary>
        /// Retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<Tweet> GetListStatuses(long listId, int count, long sinceId, long maxId);

        /// <summary>
        /// Retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <returns>
        /// A list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<Tweet> GetListStatuses(string screenName, string listSlug);

        /// <summary>
        /// Retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <returns>
        /// A list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<Tweet> GetListStatuses(string screenName, string listSlug, int count);

        /// <summary>
        /// Retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<Tweet> GetListStatuses(string screenName, string listSlug, int count, long sinceId, long maxId);

        /// <summary>
        /// Creates a new user list.
        /// </summary>
        /// <param name="name">The name of the list.</param>
        /// <param name="description">The list description.</param>
        /// <param name="isPublic">If true, the list will be public; if false the list will be private.</param>
        /// <returns>
        /// The newly created <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList CreateList(string name, string description, bool isPublic);

        /// <summary>
        /// Updates an existing user list
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="name">The new name of the list.</param>
        /// <param name="description">The new list description.</param>
        /// <param name="isPublic">If true, the list will be public; if false the list will be private.</param>
        /// <returns>
        /// The newly updated <see cref="UserList"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList UpdateList(long listId, string name, string description, bool isPublic);

        /// <summary>
        /// Removes a user list.
        /// </summary>
        /// <param name="listId">The ID of the list to be removed.</param>
        /// <returns>
        /// The deleted <see cref="UserList"/>, if successful.
        /// </returns>        
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList DeleteList(long listId);

	    /// <summary>
        /// Retrieves a list of Twitter profiles whose users are members of the list.
	    /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <returns>A list of <see cref="TwitterProfile"/>s.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<TwitterProfile> GetListMembers(long listId);

        /// <summary>
        /// Retrieves a list of Twitter profiles whose users are members of the list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <returns>A list of <see cref="TwitterProfile"/>s.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<TwitterProfile> GetListMembers(string screenName, string listSlug);

        /// <summary>
        /// Adds one or more new members to a user list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="newMemberIds">One or more profile IDs of the Twitter profiles to add to the list.</param>
        /// <returns>The <see cref="UserList"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList AddToList(long listId, params long[] newMemberIds);

        /// <summary>
        /// Adds one or more new members to a user list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="newMemberScreenNames">One or more profile IDs of the Twitter profiles to add to the list.</param>
        /// <returns>The <see cref="UserList"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList AddToList(long listId, params string[] newMemberScreenNames);

	    /// <summary>
        /// Removes a member from a user list.
	    /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="memberId">The ID of the member to be removed.</param>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    void RemoveFromList(long listId, long memberId);

        /// <summary>
        /// Removes a member from a user list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="memberScreenName">The screen name of the member to be removed.</param>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    void RemoveFromList(long listId, string memberScreenName);

	    /// <summary>
        /// Subscribes the authenticating user to a list.
	    /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <returns>The <see cref="UserList"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList Subscribe(long listId);

        /// <summary>
        /// Subscribes the authenticating user to a list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <returns>The <see cref="UserList"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList Subscribe(string screenName, string listSlug);

        /// <summary>
        /// Unsubscribes the authenticating user from a list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <returns>The <see cref="UserList"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList Unsubscribe(long listId);

        /// <summary>
        /// Unsubscribes the authenticating user from a list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <returns>The <see cref="UserList"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    UserList Unsubscribe(string screenName, string listSlug);

        /// <summary>
        /// Retrieves the subscribers to a list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <returns>
        /// A list of <see cref="TwitterProfile"/>s for the list's subscribers.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<TwitterProfile> GetListSubscribers(long listId);

        /// <summary>
        /// Retrieves the subscribers to a list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <returns>
        /// A list of <see cref="TwitterProfile"/>s for the list's subscribers.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    IList<TwitterProfile> GetListSubscribers(string screenName, string listSlug);

	    /// <summary>
        /// Retrieves the lists that a given user is a member of.
	    /// </summary>
        /// <param name="userId">The user ID.</param>
	    /// <returns>
        /// A list of <see cref="UserList"/>s that the user is a member of.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    CursoredList<UserList> GetMemberships(long userId);

        /// <summary>
        /// Retrieves the lists that a given user is a member of.
        /// </summary>
        /// <param name="screenName">The user's screen name.</param>
        /// <returns>
        /// A list of <see cref="UserList"/>s that the user is a member of.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    CursoredList<UserList> GetMemberships(string screenName);

        /// <summary>
        /// Retrieves the lists that a given user is subscribed to.
        /// </summary>
        /// <param name="userId">The user ID.</param>
        /// <returns>
        /// A list of <see cref="UserList"/>s that the user is subscribed to.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    CursoredList<UserList> GetSubscriptions(long userId);

        /// <summary>
        /// Retrieves the lists that a given user is subscribed to.
        /// </summary>
        /// <param name="screenName">The user's screen name.</param>
        /// <returns>
        /// A list of <see cref="UserList"/>s that the user is subscribed to.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    CursoredList<UserList> GetSubscriptions(string screenName);

        /// <summary>
        /// Checks to see if a given user is a member of a given list.
        /// </summary>
        /// <param name="listId">The list ID.</param>
        /// <param name="memberId">The user ID to check for membership.</param>
        /// <returns>
        /// <see langword="true"/> if the user is a member of the list; otherwise <see langword="false"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    bool IsMember(long listId, long memberId);
	
        /// <summary>
        /// Checks to see if a given user is a member of a given list.
        /// </summary>
        /// <param name="screenName">The screen name of the list's owner.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="memberScreenName">The screenName to check for membership.</param>
        /// <returns>
        /// <see langword="true"/> if the user is a member of the list; otherwise <see langword="false"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    bool IsMember(string screenName, string listSlug, string memberScreenName);

        /// <summary>
        /// Checks to see if a given user subscribes to a given list.
        /// </summary>
        /// <param name="listId">The list ID.</param>
        /// <param name="subscriberId">The user ID to check for subscribership.</param>
        /// <returns>
        /// <see langword="true"/> if the user subscribes to the list; otherwise <see langword="false"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    bool IsSubscriber(long listId, long subscriberId);
	
        /// <summary>
        /// Checks to see if a given user subscribes to a given list.
        /// </summary>
        /// <param name="screenName">The screen name of the list's owner.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="subscriberScreenName">The screenName to check for subscribership.</param>
        /// <returns>
        /// <see langword="true"/> if the user subscribes to the list; otherwise <see langword="false"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
	    bool IsSubscriber(string screenName, string listSlug, string subscriberScreenName);
#endif

        /// <summary>
        /// Asynchronously retrieves user lists for the authenticated user.
        /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="UserList"/>s for the specified user.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListsAsync(Action<RestOperationCompletedEventArgs<IList<UserList>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves user lists for the given user.
        /// </summary>
        /// <param name="userId">The ID of the Twitter user.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="UserList"/>s for the specified user.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListsAsync(long userId, Action<RestOperationCompletedEventArgs<IList<UserList>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves user lists for the given user.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="UserList"/>s for the specified user.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListsAsync(string screenName, Action<RestOperationCompletedEventArgs<IList<UserList>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves a specific user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the requested <see cref="UserList"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListAsync(long listId, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves a specific user list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The lists's slug.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the requested <see cref="UserList"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListAsync(string screenName, string listSlug, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListStatusesAsync(long listId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListStatusesAsync(long listId, int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="listId">The ID of the list to retrieve.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListStatusesAsync(long listId, int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception> 
        RestOperationCanceler GetListStatusesAsync(string screenName, string listSlug, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListStatusesAsync(string screenName, string listSlug, int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the timeline tweets for the given user list.
        /// </summary>
        /// <param name="screenName">The screen name of the Twitter user.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/> objects for the items in the user list timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListStatusesAsync(string screenName, string listSlug, int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously creates a new user list.
        /// </summary>
        /// <param name="name">The name of the list.</param>
        /// <param name="description">The list description.</param>
        /// <param name="isPublic">If true, the list will be public; if false the list will be private.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the newly created <see cref="UserList"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>     
        RestOperationCanceler CreateListAsync(string name, string description, bool isPublic, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously updates an existing user list
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="name">The new name of the list.</param>
        /// <param name="description">The new list description.</param>
        /// <param name="isPublic">If true, the list will be public; if false the list will be private.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the newly updated <see cref="UserList"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler UpdateListAsync(long listId, string name, string description, bool isPublic, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously removes a user list.
        /// </summary>
        /// <param name="listId">The ID of the list to be removed.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the deleted <see cref="UserList"/>, if successful.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>      
        RestOperationCanceler DeleteListAsync(long listId, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves a list of Twitter profiles whose users are members of the list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="TwitterProfile"/>s.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListMembersAsync(long listId, Action<RestOperationCompletedEventArgs<IList<TwitterProfile>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves a list of Twitter profiles whose users are members of the list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="TwitterProfile"/>s.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListMembersAsync(string screenName, string listSlug, Action<RestOperationCompletedEventArgs<IList<TwitterProfile>>> operationCompleted);

        /// <summary>
        /// Asynchronously adds one or more new members to a user list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="newMemberIds">One or more profile IDs of the Twitter profiles to add to the list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the <see cref="UserList"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler AddToListAsync(long listId, long[] newMemberIds, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously adds one or more new members to a user list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="newMemberScreenNames">One or more profile IDs of the Twitter profiles to add to the list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the <see cref="UserList"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler AddToListAsync(long listId, string[] newMemberScreenNames, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously removes a member from a user list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="memberId">The ID of the member to be removed.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler RemoveFromListAsync(long listId, long memberId, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted);

        /// <summary>
        /// Asynchronously removes a member from a user list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="memberScreenName">The screen name of the member to be removed.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler RemoveFromListAsync(long listId, string memberScreenName, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted);

        /// <summary>
        /// Asynchronously subscribes the authenticating user to a list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the <see cref="UserList"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler SubscribeAsync(long listId, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously subscribes the authenticating user to a list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the <see cref="UserList"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler SubscribeAsync(string screenName, string listSlug, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously unsubscribes the authenticating user from a list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the <see cref="UserList"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler UnsubscribeAsync(long listId, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously unsubscribes the authenticating user from a list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the <see cref="UserList"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler UnsubscribeAsync(string screenName, string listSlug, Action<RestOperationCompletedEventArgs<UserList>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the subscribers to a list.
        /// </summary>
        /// <param name="listId">The ID of the list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="TwitterProfile"/>s for the list's subscribers.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListSubscribersAsync(long listId, Action<RestOperationCompletedEventArgs<IList<TwitterProfile>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the subscribers to a list.
        /// </summary>
        /// <param name="screenName">The screen name of the list owner.</param>
        /// <param name="listSlug">The slug of the list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="TwitterProfile"/>s for the list's subscribers.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetListSubscribersAsync(string screenName, string listSlug, Action<RestOperationCompletedEventArgs<IList<TwitterProfile>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the lists that a given user is a member of.
        /// </summary>
        /// <param name="userId">The user ID.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="UserList"/>s that the user is a member of.
        /// </returns>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="UserList"/>s that the user is a member of.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetMembershipsAsync(long userId, Action<RestOperationCompletedEventArgs<CursoredList<UserList>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the lists that a given user is a member of.
        /// </summary>
        /// <param name="screenName">The user's screen name.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="UserList"/>s that the user is a member of.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetMembershipsAsync(string screenName, Action<RestOperationCompletedEventArgs<CursoredList<UserList>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the lists that a given user is subscribed to.
        /// </summary>
        /// <param name="userId">The user ID.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="UserList"/>s that the user is subscribed to.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetSubscriptionsAsync(long userId, Action<RestOperationCompletedEventArgs<CursoredList<UserList>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the lists that a given user is subscribed to.
        /// </summary>
        /// <param name="screenName">The user's screen name.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="UserList"/>s that the user is subscribed to.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetSubscriptionsAsync(string screenName, Action<RestOperationCompletedEventArgs<CursoredList<UserList>>> operationCompleted);

        /// <summary>
        /// Asynchronously checks to see if a given user is a member of a given list.
        /// </summary>
        /// <param name="listId">The list ID.</param>
        /// <param name="memberId">The user ID to check for membership.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a value indicating whether or not the user is a member of the list.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler IsMemberAsync(long listId, long memberId, Action<RestOperationCompletedEventArgs<bool>> operationCompleted);

        /// <summary>
        /// Asynchronously checks to see if a given user is a member of a given list.
        /// </summary>
        /// <param name="screenName">The screen name of the list's owner.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="memberScreenName">The screenName to check for membership.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a value indicating whether or not the user is a member of the list.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler IsMemberAsync(string screenName, string listSlug, string memberScreenName, Action<RestOperationCompletedEventArgs<bool>> operationCompleted);

        /// <summary>
        /// Asynchronously checks to see if a given user subscribes to a given list.
        /// </summary>
        /// <param name="listId">The list ID.</param>
        /// <param name="subscriberId">The user ID to check for subscribership.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a value indicating whether or not the user subscribes to the list.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler IsSubscriberAsync(long listId, long subscriberId, Action<RestOperationCompletedEventArgs<bool>> operationCompleted);

        /// <summary>
        /// Asynchronously checks to see if a given user subscribes to a given list.
        /// </summary>
        /// <param name="screenName">The screen name of the list's owner.</param>
        /// <param name="listSlug">The list's slug.</param>
        /// <param name="subscriberScreenName">The screenName to check for subscribership.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a value indicating whether or not the user subscribes to the list.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler IsSubscriberAsync(string screenName, string listSlug, string subscriberScreenName, Action<RestOperationCompletedEventArgs<bool>> operationCompleted);
#endif
    }
}
