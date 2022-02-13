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

using Spring.IO;

namespace Spring.Social.Twitter.Api
{
    /// <summary>
    /// Interface defining the operations for sending and retrieving tweets.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    public interface ITimelineOperations
    {
#if NET_4_0 || SILVERLIGHT_5
        /// <summary>
        /// Asynchronously retrieves the 20 most recently posted tweets, including retweets, from the authenticating user's home timeline. 
        /// The home timeline includes tweets from the user's timeline and the timeline of anyone that they follow.
        /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s in the authenticating user's home timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetHomeTimelineAsync();

        /// <summary>
        /// Asynchronously retrieves tweets, including retweets, from the authenticating user's home timeline. 
        /// The home timeline includes tweets from the user's timeline and the timeline of anyone that they follow.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s in the authenticating user's home timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetHomeTimelineAsync(int count);

        /// <summary>
        /// Asynchronously retrieves tweets, including retweets, from the authenticating user's home timeline. 
        /// The home timeline includes tweets from the user's timeline and the timeline of anyone that they follow.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s in the authenticating user's home timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetHomeTimelineAsync(int count, long sinceId, long maxId);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets posted by the authenticating user.
        /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s that have been posted by the authenticating user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetUserTimelineAsync();

        /// <summary>
        /// Asynchronously retrieves tweets posted by the authenticating user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s that have been posted by the authenticating user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetUserTimelineAsync(int count);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the authenticating user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s that have been posted by the authenticating user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetUserTimelineAsync(int count, long sinceId, long maxId);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets posted by the given user.
        /// </summary>
        /// <param name="screenName">The screen name of the user whose timeline is being requested.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetUserTimelineAsync(string screenName);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="screenName">The screen name of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetUserTimelineAsync(string screenName, int count);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="screenName">The screen name of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetUserTimelineAsync(string screenName, int count, long sinceId, long maxId);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets posted by the given user.
        /// </summary>
        /// <param name="userId">The user ID of the user whose timeline is being requested.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetUserTimelineAsync(long userId);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="userId">The user ID of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetUserTimelineAsync(long userId, int count);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="userId">The user ID of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetUserTimelineAsync(long userId, int count, long sinceId, long maxId);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets that mention the authenticated user.
        /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s that mention the authenticated user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetMentionsAsync();

        /// <summary>
        /// Asynchronously retrieves tweets that mention the authenticated user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s that mention the authenticated user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetMentionsAsync(int count);

        /// <summary>
        /// Asynchronously retrieves tweets that mention the authenticated user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s that mention the authenticated user.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetMentionsAsync(int count, long sinceId, long maxId);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets of the authenticated user that have been retweeted by others.
        /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the authenticated user that have been retweeted by others.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetRetweetsOfMeAsync();

        /// <summary>
        /// Asynchronously retrieves tweets of the authenticated user that have been retweeted by others. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 100. 
        /// (Will return at most 100 entries, even if pageSize is greater than 100)
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the authenticated user that have been retweeted by others.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetRetweetsOfMeAsync(int count);

        /// <summary>
        /// Asynchronously retrieves tweets of the authenticated user that have been retweeted by others. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 100. 
        /// (Will return at most 100 entries, even if pageSize is greater than 100)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the authenticated user that have been retweeted by others.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetRetweetsOfMeAsync(int count, long sinceId, long maxId);

        /// <summary>
        /// Asynchronously returns a single tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the <see cref="Tweet"/> from the specified ID.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<Tweet> GetStatusAsync(long tweetId);

        /// <summary>
        /// Asynchronously updates the user's status.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the created <see cref="Tweet"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        Task<Tweet> UpdateStatusAsync(string status);

        /// <summary>
        /// Asynchronously updates the user's status along with a picture.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <param name="photo">
        /// A <see cref="IResource"/> for the photo data. It must contain GIF, JPG, or PNG data.
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the created <see cref="Tweet"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        /// <exception cref="TwitterApiException">If the photo resource isn't a GIF, JPG, or PNG.</exception>
        Task<Tweet> UpdateStatusAsync(string status, IResource photo);

        /// <summary>
        /// Asynchronously updates the user's status, including additional metadata concerning the status.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <param name="details">The metadata pertaining to the status.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the created <see cref="Tweet"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        Task<Tweet> UpdateStatusAsync(string status, StatusDetails details);

        /// <summary>
        /// Asynchronously updates the user's status, including a picture and additional metadata concerning the status.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <param name="photo">
        /// A <see cref="IResource"/> for the photo data. It must contain GIF, JPG, or PNG data.
        /// </param>
        /// <param name="details">The metadata pertaining to the status.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the created <see cref="Tweet"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        /// <exception cref="TwitterApiException">If the photo resource isn't a GIF, JPG, or PNG.</exception>
        Task<Tweet> UpdateStatusAsync(string status, IResource photo, StatusDetails details);

        /// <summary>
        /// Asynchronously removes a status entry.
        /// </summary>
        /// <param name="tweetId">The tweet's ID to be removed.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the deleted <see cref="Tweet"/>, if successful.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<Tweet> DeleteStatusAsync(long tweetId);

        /// <summary>
        /// Asynchronously posts a retweet of an existing tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID to be retweeted.</param>
        /// <returns>A <code>Task</code> that represents the asynchronous operation.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task RetweetAsync(long tweetId);

        /// <summary>
        /// Asynchronously retrieves up to 100 retweets of a specific tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the retweets of the specified tweet.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetRetweetsAsync(long tweetId);

        /// <summary>
        /// Asynchronously retrieves retweets of a specific tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <param name="count">
        /// The maximum number of retweets to return. Should be less than or equal to 100. 
        /// (Will return at most 100 entries, even if pageSize is greater than 100)
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the retweets of the specified tweet.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetRetweetsAsync(long tweetId, int count);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets favorited by the authenticated user.
        /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the specified user's favorite timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetFavoritesAsync();

        /// <summary>
        /// Asynchronously retrieves tweets favorited by the authenticated user.
        /// </summary>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="Tweet"/>s from the specified user's favorite timeline.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<Tweet>> GetFavoritesAsync(int count);

        /// <summary>
        /// Asynchronously adds a tweet to the user's collection of favorite tweets.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <returns>A <code>Task</code> that represents the asynchronous operation.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task AddToFavoritesAsync(long tweetId);

        /// <summary>
        /// Asynchronously removes a tweet from the user's collection of favorite tweets.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <returns>A <code>Task</code> that represents the asynchronous operation.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task RemoveFromFavoritesAsync(long tweetId);
#else
#if !SILVERLIGHT
        /// <summary>
        /// Retrieves the 20 most recently posted tweets, including retweets, from the authenticating user's home timeline. 
        /// The home timeline includes tweets from the user's timeline and the timeline of anyone that they follow.
        /// </summary>
        /// <returns>A list of <see cref="Tweet"/>s in the authenticating user's home timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetHomeTimeline();

        /// <summary>
        /// Retrieves tweets, including retweets, from the authenticating user's home timeline. 
        /// The home timeline includes tweets from the user's timeline and the timeline of anyone that they follow.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <returns>A list of <see cref="Tweet"/>s in the authenticating user's home timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetHomeTimeline(int count);

        /// <summary>
        /// Retrieves tweets, including retweets, from the authenticating user's home timeline. 
        /// The home timeline includes tweets from the user's timeline and the timeline of anyone that they follow.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>A list of <see cref="Tweet"/>s in the authenticating user's home timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetHomeTimeline(int count, long sinceId, long maxId);

        /// <summary>
        /// Retrieves the 20 most recent tweets posted by the authenticating user.
        /// </summary>
        /// <returns>A list of <see cref="Tweet"/>s that have been posted by the authenticating user.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetUserTimeline();

        /// <summary>
        /// Retrieves tweets posted by the authenticating user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <returns>A list of <see cref="Tweet"/>s that have been posted by the authenticating user.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetUserTimeline(int count);

        /// <summary>
        /// Retrieves tweets posted by the authenticating user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>A list of <see cref="Tweet"/>s that have been posted by the authenticating user.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetUserTimeline(int count, long sinceId, long maxId);

        /// <summary>
        /// Retrieves the 20 most recent tweets posted by the given user.
        /// </summary>
        /// <param name="screenName">The screen name of the user whose timeline is being requested.</param>
        /// <returns>A list of <see cref="Tweet"/>s from the specified user's timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetUserTimeline(string screenName);

        /// <summary>
        /// Retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="screenName">The screen name of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <returns>A list of <see cref="Tweet"/>s from the specified user's timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetUserTimeline(string screenName, int count);

        /// <summary>
        /// Retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="screenName">The screen name of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>A list of <see cref="Tweet"/>s from the specified user's timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetUserTimeline(string screenName, int count, long sinceId, long maxId);

        /// <summary>
        /// Retrieves the 20 most recent tweets posted by the given user.
        /// </summary>
        /// <param name="userId">The user ID of the user whose timeline is being requested.</param>
        /// <returns>A list of <see cref="Tweet"/>s from the specified user's timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetUserTimeline(long userId);

        /// <summary>
        /// Retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="userId">The user ID of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <returns>A list of <see cref="Tweet"/>s from the specified user's timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetUserTimeline(long userId, int count);

        /// <summary>
        /// Retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="userId">The user ID of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>A list of <see cref="Tweet"/>s from the specified user's timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetUserTimeline(long userId, int count, long sinceId, long maxId);

        /// <summary>
        /// Retrieves the 20 most recent tweets that mention the authenticated user.
        /// </summary>
        /// <returns>A list of <see cref="Tweet"/>s that mention the authenticated user.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetMentions();

        /// <summary>
        /// Retrieves tweets that mention the authenticated user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <returns>A list of <see cref="Tweet"/>s that mention the authenticated user.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetMentions(int count);

        /// <summary>
        /// Retrieves tweets that mention the authenticated user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>A list of <see cref="Tweet"/>s that mention the authenticated user.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetMentions(int count, long sinceId, long maxId);

        /// <summary>
        /// Retrieves the 20 most recent tweets of the authenticated user that have been retweeted by others.
        /// </summary>
        /// <returns>A list of <see cref="Tweet"/>s from the authenticated user that have been retweeted by others.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetRetweetsOfMe();

        /// <summary>
        /// Retrieves tweets of the authenticated user that have been retweeted by others. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 100. 
        /// (Will return at most 100 entries, even if pageSize is greater than 100)
        /// </param>
        /// <returns>A list of <see cref="Tweet"/>s from the authenticated user that have been retweeted by others.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetRetweetsOfMe(int count);

        /// <summary>
        /// Retrieves tweets of the authenticated user that have been retweeted by others. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 100. 
        /// (Will return at most 100 entries, even if pageSize is greater than 100)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>A list of <see cref="Tweet"/>s from the authenticated user that have been retweeted by others.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetRetweetsOfMe(int count, long sinceId, long maxId);

        /// <summary>
        /// Returns a single tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <returns>The <see cref="Tweet"/> from the specified ID.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Tweet GetStatus(long tweetId);

        /// <summary>
        /// Updates the user's status.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <returns>The created <see cref="Tweet"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        Tweet UpdateStatus(string status);

        /// <summary>
        /// Updates the user's status along with a picture.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <param name="photo">
        /// A <see cref="IResource"/> for the photo data. It must contain GIF, JPG, or PNG data.
        /// </param>
        /// <returns>The created <see cref="Tweet"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        /// <exception cref="TwitterApiException">If the photo resource isn't a GIF, JPG, or PNG.</exception>
        Tweet UpdateStatus(string status, IResource photo);

        /// <summary>
        /// Updates the user's status, including additional metadata concerning the status.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <param name="details">The metadata pertaining to the status.</param>
        /// <returns>The created <see cref="Tweet"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        Tweet UpdateStatus(string status, StatusDetails details);

        /// <summary>
        /// Updates the user's status, including a picture and additional metadata concerning the status.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <param name="photo">
        /// A <see cref="IResource"/> for the photo data. It must contain GIF, JPG, or PNG data.
        /// </param>
        /// <param name="details">The metadata pertaining to the status.</param>
        /// <returns>The created <see cref="Tweet"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        /// <exception cref="TwitterApiException">If the photo resource isn't a GIF, JPG, or PNG.</exception>
        Tweet UpdateStatus(string status, IResource photo, StatusDetails details);

        /// <summary>
        /// Removes a status entry.
        /// </summary>
        /// <param name="tweetId">The tweet's ID to be removed.</param>
        /// <returns>The deleted <see cref="Tweet"/>, if successful.</returns>        
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Tweet DeleteStatus(long tweetId);

        /// <summary>
        /// Posts a retweet of an existing tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID to be retweeted.</param>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        void Retweet(long tweetId);

        /// <summary>
        /// Retrieves up to 100 retweets of a specific tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <returns>The retweets of the specified tweet.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetRetweets(long tweetId);

        /// <summary>
        /// Retrieves retweets of a specific tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <param name="count">
        /// The maximum number of retweets to return. Should be less than or equal to 100. 
        /// (Will return at most 100 entries, even if pageSize is greater than 100)
        /// </param>
        /// <returns>The retweets of the specified tweet.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetRetweets(long tweetId, int count);

        /// <summary>
        /// Retrieves the 20 most recent tweets favorited by the authenticated user.
        /// </summary>
        /// <returns>A list of <see cref="Tweet"/>s from the specified user's favorite timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetFavorites();

        /// <summary>
        /// Retrieves tweets favorited by the authenticated user.
        /// </summary>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <returns>A list of <see cref="Tweet"/>s from the specified user's favorite timeline.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<Tweet> GetFavorites(int count);

        /// <summary>
        /// Adds a tweet to the user's collection of favorite tweets.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        void AddToFavorites(long tweetId);

        /// <summary>
        /// Removes a tweet from the user's collection of favorite tweets.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        void RemoveFromFavorites(long tweetId);
#endif

        /// <summary>
        /// Asynchronously retrieves the 20 most recently posted tweets, including retweets, from the authenticating user's home timeline. 
        /// The home timeline includes tweets from the user's timeline and the timeline of anyone that they follow.
        /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s in the authenticating user's home timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetHomeTimelineAsync(Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets, including retweets, from the authenticating user's home timeline. 
        /// The home timeline includes tweets from the user's timeline and the timeline of anyone that they follow.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s in the authenticating user's home timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetHomeTimelineAsync(int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets, including retweets, from the authenticating user's home timeline. 
        /// The home timeline includes tweets from the user's timeline and the timeline of anyone that they follow.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s in the authenticating user's home timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetHomeTimelineAsync(int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets posted by the authenticating user.
        /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s that have been posted by the authenticating user.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetUserTimelineAsync(Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the authenticating user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s that have been posted by the authenticating user.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetUserTimelineAsync(int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the authenticating user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s that have been posted by the authenticating user.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetUserTimelineAsync(int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets posted by the given user.
        /// </summary>
        /// <param name="screenName">The screen name of the user whose timeline is being requested.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetUserTimelineAsync(string screenName, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="screenName">The screen name of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetUserTimelineAsync(string screenName, int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="screenName">The screen name of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetUserTimelineAsync(string screenName, int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets posted by the given user.
        /// </summary>
        /// <param name="userId">The user ID of the user whose timeline is being requested.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetUserTimelineAsync(long userId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="userId">The user ID of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetUserTimelineAsync(long userId, int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets posted by the given user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="userId">The user ID of the user whose timeline is being requested.</param>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the specified user's timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetUserTimelineAsync(long userId, int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets that mention the authenticated user.
        /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s that mention the authenticated user.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetMentionsAsync(Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets that mention the authenticated user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s that mention the authenticated user.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetMentionsAsync(int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets that mention the authenticated user. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 200. 
        /// (Will return at most 200 entries, even if pageSize is greater than 200)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s that mention the authenticated user.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetMentionsAsync(int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets of the authenticated user that have been retweeted by others.
        /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the authenticated user that have been retweeted by others.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetRetweetsOfMeAsync(Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets of the authenticated user that have been retweeted by others. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 100. 
        /// (Will return at most 100 entries, even if pageSize is greater than 100)
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the authenticated user that have been retweeted by others.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetRetweetsOfMeAsync(int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets of the authenticated user that have been retweeted by others. The most recent tweets are listed first.
        /// </summary>
        /// <param name="count">
        /// The number of <see cref="Tweet"/>s to retrieve. Should be less than or equal to 100. 
        /// (Will return at most 100 entries, even if pageSize is greater than 100)
        /// </param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the authenticated user that have been retweeted by others.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetRetweetsOfMeAsync(int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously returns a single tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the <see cref="Tweet"/> from the specified ID.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetStatusAsync(long tweetId, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted);

        /// <summary>
        /// Asynchronously updates the user's status.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the created <see cref="Tweet"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        RestOperationCanceler UpdateStatusAsync(string status, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted);

        /// <summary>
        /// Asynchronously updates the user's status along with a picture.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <param name="photo">
        /// A <see cref="IResource"/> for the photo data. It must contain GIF, JPG, or PNG data.
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the created <see cref="Tweet"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        /// <exception cref="TwitterApiException">If the photo resource isn't a GIF, JPG, or PNG.</exception>
        RestOperationCanceler UpdateStatusAsync(string status, IResource photo, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted);

        /// <summary>
        /// Asynchronously updates the user's status, including additional metadata concerning the status.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <param name="details">The metadata pertaining to the status.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the created <see cref="Tweet"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        RestOperationCanceler UpdateStatusAsync(string status, StatusDetails details, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted);

        /// <summary>
        /// Asynchronously updates the user's status, including a picture and additional metadata concerning the status.
        /// </summary>
        /// <param name="status">The status message.</param>
        /// <param name="photo">
        /// A <see cref="IResource"/> for the photo data. It must contain GIF, JPG, or PNG data.
        /// </param>
        /// <param name="details">The metadata pertaining to the status.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the created <see cref="Tweet"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        /// <exception cref="TwitterApiException">If the status message duplicates a previously posted status.</exception>
        /// <exception cref="TwitterApiException">If the length of the status message exceeds Twitter's 140 character limit.</exception>
        /// <exception cref="TwitterApiException">If the photo resource isn't a GIF, JPG, or PNG.</exception>
        RestOperationCanceler UpdateStatusAsync(string status, IResource photo, StatusDetails details, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted);

        /// <summary>
        /// Asynchronously removes a status entry.
        /// </summary>
        /// <param name="tweetId">The tweet's ID to be removed.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes.
        /// Provides the deleted <see cref="Tweet"/>, if successful.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler DeleteStatusAsync(long tweetId, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted);

        /// <summary>
        /// Asynchronously posts a retweet of an existing tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID to be retweeted.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler RetweetAsync(long tweetId, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves up to 100 retweets of a specific tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the retweets of the specified tweet.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetRetweetsAsync(long tweetId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves retweets of a specific tweet.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <param name="count">
        /// The maximum number of retweets to return. Should be less than or equal to 100. 
        /// (Will return at most 100 entries, even if pageSize is greater than 100)
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the retweets of the specified tweet.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetRetweetsAsync(long tweetId, int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the 20 most recent tweets favorited by the authenticated user.
        /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the specified user's favorite timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetFavoritesAsync(Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves tweets favorited by the authenticated user.
        /// </summary>
        /// <param name="count">The number of <see cref="Tweet"/>s to retrieve.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="Tweet"/>s from the specified user's favorite timeline.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetFavoritesAsync(int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted);

        /// <summary>
        /// Asynchronously adds a tweet to the user's collection of favorite tweets.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler AddToFavoritesAsync(long tweetId, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted);

        /// <summary>
        /// Asynchronously removes a tweet from the user's collection of favorite tweets.
        /// </summary>
        /// <param name="tweetId">The tweet's ID.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler RemoveFromFavoritesAsync(long tweetId, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted);
#endif
    }
}
