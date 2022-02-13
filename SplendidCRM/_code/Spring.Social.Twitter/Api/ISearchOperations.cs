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
    /// Interface defining the operations for searching Twitter and retrieving trending data.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    public interface ISearchOperations
    {
#if NET_4_0 || SILVERLIGHT_5
        /// <summary>
        /// Asynchronously searches Twitter, returning the first 15 matching <see cref="Tweet"/>s
        /// </summary>
        /// <param name="query">The search query string.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="SearchResults"/> containing the search results metadata and a list of matching <see cref="Tweet"/>s.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<SearchResults> SearchAsync(string query);

        /// <summary>
        /// Asynchronously searches Twitter, returning a specific page out of the complete set of results.
        /// </summary>
        /// <param name="query">The search query string.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to return, up to a maximum of 100.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="SearchResults"/> containing the search results metadata and a list of matching <see cref="Tweet"/>s.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<SearchResults> SearchAsync(string query, int count);

        /// <summary>
        /// Asynchronously searches Twitter, returning a specific page out of the complete set of results. 
        /// Results are filtered to those whose ID falls between sinceId and maxId.
        /// </summary>
        /// <param name="query">The search query string.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to return, up to a maximum of 100.</param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="SearchResults"/> containing the search results metadata and a list of matching <see cref="Tweet"/>s.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<SearchResults> SearchAsync(string query, int count, long sinceId, long maxId);

        /// <summary>
        /// Asynchronously retrieves the authenticating user's saved searches.
        /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a list of <see cref="SavedSearch"/> items.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<IList<SavedSearch>> GetSavedSearchesAsync();

        /// <summary>
        /// Asynchronously retrieves a single saved search by the saved search's ID.
        /// </summary>
        /// <param name="searchId">The ID of the saved search.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="SavedSearch"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<SavedSearch> GetSavedSearchAsync(long searchId);

        /// <summary>
        /// Asynchronously creates a new saved search for the authenticating user.
        /// </summary>
        /// <param name="query">The search query to save.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="SavedSearch"/>.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<SavedSearch> CreateSavedSearchAsync(string query);

        /// <summary>
        /// Asynchronously deletes a saved search.
        /// </summary>
        /// <param name="searchId">The ID of the saved search.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// the deleted <see cref="SavedSearch"/>, if successful.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<SavedSearch> DeleteSavedSearchAsync(long searchId);

        /// <summary>
        /// Asynchronously retrieves the top 10 trending topics for a given location, 
        /// identified by its Yahoo! "Where on Earth" (WOE) ID. 
        /// This includes hashtagged topics.
        /// <para/>
        /// See http://developer.yahoo.com/geo/geoplanet/ for more information on WOE.
        /// </summary>
        /// <param name="whereOnEarthId">
        /// The Yahoo! "Where on Earth" (WOE) ID for the location to retrieve trend data.
        /// <para/>
        /// Global information is available by using 1.
        /// </param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a Trends object with the top 10 trending topics for the location.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<Trends> GetTrendsAsync(long whereOnEarthId);

        /// <summary>
        /// Asynchronously retrieves the top 10 trending topics for a given location, 
        /// identified by its Yahoo! "Where on Earth" (WOE) ID.
        /// <para/>
        /// See http://developer.yahoo.com/geo/geoplanet/ for more information on WOE.
        /// </summary>
        /// <param name="whereOnEarthId">
        /// The Yahoo! "Where on Earth" (WOE) ID for the location to retrieve trend data.
        /// <para/>
        /// Global information is available by using 1.
        /// </param>
        /// <param name="excludeHashtags">If true, hashtagged topics will be excluded from the trends list.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a Trends object with the top 10 trending topics for the given location.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Task<Trends> GetTrendsAsync(long whereOnEarthId, bool excludeHashtags);
#else
#if !SILVERLIGHT
        /// <summary>
        /// Searches Twitter, returning the first 15 matching <see cref="Tweet"/>s
        /// </summary>
        /// <param name="query">The search query string.</param>
        /// <returns>
        /// A <see cref="SearchResults"/> containing the search results metadata and a list of matching <see cref="Tweet"/>s.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        SearchResults Search(string query);

        /// <summary>
        /// Searches Twitter, returning a specific page out of the complete set of results.
        /// </summary>
        /// <param name="query">The search query string.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to return, up to a maximum of 100.</param>
        /// <returns>
        /// A <see cref="SearchResults"/> containing the search results metadata and a list of matching <see cref="Tweet"/>s.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        SearchResults Search(string query, int count);

        /// <summary>
        /// Searches Twitter, returning a specific page out of the complete set of results. 
        /// Results are filtered to those whose ID falls between sinceId and maxId.
        /// </summary>
        /// <param name="query">The search query string.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to return, up to a maximum of 100.</param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <returns>A <see cref="SearchResults"/> containing the search results metadata and a list of matching <see cref="Tweet"/>s</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        SearchResults Search(string query, int count, long sinceId, long maxId);

        /// <summary>
        /// Retrieves the authenticating user's saved searches.
        /// </summary>
        /// <returns>A list of <see cref="SavedSearch"/> items.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        IList<SavedSearch> GetSavedSearches();

        /// <summary>
        /// Retrieves a single saved search by the saved search's ID.
        /// </summary>
        /// <param name="searchId">The ID of the saved search.</param>
        /// <returns>A <see cref="SavedSearch"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        SavedSearch GetSavedSearch(long searchId);

        /// <summary>
        /// Creates a new saved search for the authenticating user.
        /// </summary>
        /// <param name="query">The search query to save.</param>
        /// <returns>A <see cref="SavedSearch"/>.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        SavedSearch CreateSavedSearch(string query);

        /// <summary>
        /// Deletes a saved search.
        /// </summary>
        /// <param name="searchId">The ID of the saved search.</param>
        /// <returns>The deleted <see cref="SavedSearch"/>, if successful.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        SavedSearch DeleteSavedSearch(long searchId);

        /// <summary>
        /// Retrieves the top 10 trending topics for a given location, 
        /// identified by its "Where on Earth" (WOE) ID. 
        /// This includes hashtagged topics.
        /// <para/>
        /// See http://developer.yahoo.com/geo/geoplanet/ for more information on WOE.
        /// </summary>
        /// <param name="whereOnEarthId">
        /// The Yahoo! "Where on Earth" (WOE) ID for the location to retrieve trend data.
        /// <para/>
        /// Global information is available by using 1.
        /// </param>
        /// <returns>A Trends object with the top 10 trending topics for the location.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Trends GetTrends(long whereOnEarthId);

        /// <summary>
        /// Retrieves the top 10 trending topics for a given location, 
        /// identified by its "Where on Earth" (WOE) ID.
        /// <para/>
        /// See http://developer.yahoo.com/geo/geoplanet/ for more information on WOE.
        /// </summary>
        /// <param name="whereOnEarthId">
        /// The Yahoo! "Where on Earth" (WOE) ID for the location to retrieve trend data.
        /// <para/>
        /// Global information is available by using 1.
        /// </param>
        /// <param name="excludeHashtags">If true, hashtagged topics will be excluded from the trends list.</param>
        /// <returns>A Trends object with the top 10 trending topics for the given location.</returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        Trends GetTrends(long whereOnEarthId, bool excludeHashtags);
#endif

        /// <summary>
        /// Asynchronously searches Twitter, returning the first 15 matching <see cref="Tweet"/>s
        /// </summary>
        /// <param name="query">The search query string.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="SearchResults"/> containing the search results metadata and a list of matching <see cref="Tweet"/>s.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler SearchAsync(string query, Action<RestOperationCompletedEventArgs<SearchResults>> operationCompleted);

        /// <summary>
        /// Asynchronously searches Twitter, returning a specific page out of the complete set of results.
        /// </summary>
        /// <param name="query">The search query string.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to return, up to a maximum of 100.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="SearchResults"/> containing the search results metadata and a list of matching <see cref="Tweet"/>s.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler SearchAsync(string query, int count, Action<RestOperationCompletedEventArgs<SearchResults>> operationCompleted);

        /// <summary>
        /// Asynchronously searches Twitter, returning a specific page out of the complete set of results. 
        /// Results are filtered to those whose ID falls between sinceId and maxId.
        /// </summary>
        /// <param name="query">The search query string.</param>
        /// <param name="count">The number of <see cref="Tweet"/>s to return, up to a maximum of 100.</param>
        /// <param name="sinceId">The minimum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="maxId">The maximum <see cref="Tweet"/> ID to return in the results.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="SearchResults"/> containing the search results metadata and a list of matching <see cref="Tweet"/>s.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler SearchAsync(string query, int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<SearchResults>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the authenticating user's saved searches.
        /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a list of <see cref="SavedSearch"/> items.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetSavedSearchesAsync(Action<RestOperationCompletedEventArgs<IList<SavedSearch>>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves a single saved search by the saved search's ID.
        /// </summary>
        /// <param name="searchId">The ID of the saved search.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="SavedSearch"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetSavedSearchAsync(long searchId, Action<RestOperationCompletedEventArgs<SavedSearch>> operationCompleted);

        /// <summary>
        /// Asynchronously creates a new saved search for the authenticating user.
        /// </summary>
        /// <param name="query">The search query to save.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="SavedSearch"/>.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler CreateSavedSearchAsync(string query, Action<RestOperationCompletedEventArgs<SavedSearch>> operationCompleted);

        /// <summary>
        /// Asynchronously deletes a saved search.
        /// </summary>
        /// <param name="searchId">The ID of the saved search.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides the deleted <see cref="SavedSearch"/>, if successful.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler DeleteSavedSearchAsync(long searchId, Action<RestOperationCompletedEventArgs<SavedSearch>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the top 10 trending topics for a given location, 
        /// identified by its "Where on Earth" (WOE) ID. 
        /// This includes hashtagged topics.
        /// </summary>
        /// <remarks>
        /// See http://developer.yahoo.com/geo/geoplanet/ for more information on WOE.
        /// </remarks>
        /// <param name="whereOnEarthId">
        /// The Yahoo! "Where on Earth" (WOE) ID for the location to retrieve trend data.
        /// <para/>
        /// Global information is available by using 1.
        /// </param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a Trends object with the top 10 trending topics for the location.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetTrendsAsync(long whereOnEarthId, Action<RestOperationCompletedEventArgs<Trends>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the top 10 trending topics for a given location, 
        /// identified by its "Where on Earth" (WOE) ID.
        /// </summary>
        /// <remarks>
        /// See http://developer.yahoo.com/geo/geoplanet/ for more information on WOE.
        /// </remarks>
        /// <param name="whereOnEarthId">
        /// The Yahoo! "Where on Earth" (WOE) ID for the location to retrieve trend data.
        /// <para/>
        /// Global information is available by using 1.
        /// </param>
        /// <param name="excludeHashtags">If true, hashtagged topics will be excluded from the trends list.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a Trends object with the top 10 trending topics for the given location.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="TwitterApiException">If there is an error while communicating with Twitter.</exception>
        RestOperationCanceler GetTrendsAsync(long whereOnEarthId, bool excludeHashtags, Action<RestOperationCompletedEventArgs<Trends>> operationCompleted);
#endif
    }
}
