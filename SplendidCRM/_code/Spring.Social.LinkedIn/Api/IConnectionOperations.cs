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

namespace Spring.Social.LinkedIn.Api
{
    /// <summary>
    /// Interface defining the operations for retrieving authenticated user's connections.
    /// </summary>
    /// <author>Robert Drysdale</author>
    /// <author>Bruno Baia (.NET)</author>
    public interface IConnectionOperations
    {
#if NET_4_0 || SILVERLIGHT_5
        /// <summary>
        /// Asynchronously retrieves up to 500 of the 1st-degree connections from the authenticated user's network.
        /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="LinkedInProfiles"/> object representing the user's connections.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task<LinkedInProfiles> GetConnectionsAsync();

        /// <summary>
        /// Asynchronously retrieves the 1st-degree connections from the authenticated user's network.
        /// </summary>
        /// <param name="start">The starting location in the result set. Used with count for pagination.</param>
        /// <param name="count">The number of connections to return. The maximum value is 500. Used with start for pagination.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="LinkedInProfiles"/> object representing the user's connections.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task<LinkedInProfiles> GetConnectionsAsync(int start, int count);

        /// <summary>
        /// Asynchronously retrieves network statistics for the authenticated user.
        /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="NetworkStatistics"/> that contains count of 1st-degree and second degree connections.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task<NetworkStatistics> GetNetworkStatisticsAsync();
#else
#if !SILVERLIGHT
        /// <summary>
        /// Retrieves up to 500 of the 1st-degree connections from the authenticated user's network.
        /// </summary>
        /// <returns>
        /// A <see cref="LinkedInProfiles"/> object representing the user's connections.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        LinkedInProfiles GetConnections();

        /// <summary>
        /// Retrieves the 1st-degree connections from the authenticated user's network.
        /// </summary>
        /// <param name="start">The starting location in the result set. Used with count for pagination.</param>
        /// <param name="count">The number of connections to return. The maximum value is 500. Used with start for pagination.</param>
        /// <returns>
        /// A <see cref="LinkedInProfiles"/> object representing the user's connections.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        LinkedInProfiles GetConnections(int start, int count);

        /// <summary>
        /// Retrieves network statistics for the authenticated user.
        /// </summary>
        /// <returns>
        /// A <see cref="NetworkStatistics"/> that contains count of 1st-degree and second degree connections.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        NetworkStatistics GetNetworkStatistics();
#endif

        /// <summary>
        /// Asynchronously retrieves up to 500 of the 1st-degree connections from the authenticated user's network.
        /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="LinkedInProfiles"/> object representing the user's connections.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler GetConnectionsAsync(Action<RestOperationCompletedEventArgs<LinkedInProfiles>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the 1st-degree connections from the authenticated user's network.
        /// </summary>
        /// <param name="start">The starting location in the result set. Used with count for pagination.</param>
        /// <param name="count">The number of connections to return. The maximum value is 500. Used with start for pagination.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="LinkedInProfiles"/> object representing the user's connections.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler GetConnectionsAsync(int start, int count, Action<RestOperationCompletedEventArgs<LinkedInProfiles>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves network statistics for the authenticated user.
        /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="NetworkStatistics"/> that contains count of 1st-degree and second degree connections.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler GetNetworkStatisticsAsync(Action<RestOperationCompletedEventArgs<NetworkStatistics>> operationCompleted);
#endif
    }
}
