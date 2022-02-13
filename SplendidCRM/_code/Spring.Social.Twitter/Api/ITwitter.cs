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

using Spring.Rest.Client;

namespace Spring.Social.Twitter.Api
{
    /// <summary>
    /// Interface specifying a basic set of operations for interacting with Twitter.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    public interface ITwitter : IApiBinding
    {
        /// <summary>
        /// Gets the portion of the Twitter API containing the block operations.
        /// </summary>
        IBlockOperations BlockOperations { get; }

        /// <summary>
        /// Gets the portion of the Twitter API containing the direct message operations.
        /// </summary>
        IDirectMessageOperations DirectMessageOperations { get; }

        /// <summary>
        /// Gets the portion of the Twitter API containing the friends and followers operations.
        /// </summary>
        IFriendOperations FriendOperations { get; }

        /// <summary>
        /// Gets the portion of the Twitter API containing the geo location operations.
        /// </summary>
        IGeoOperations GeoOperations { get; }

        /// <summary>
        /// Gets the portion of the Twitter API containing the user list operations.
        /// </summary>
        IListOperations ListOperations { get; }

        /// <summary>
        /// Gets the portion of the Twitter API containing the search operations.
        /// </summary>        
        ISearchOperations SearchOperations { get; }

        /// <summary>
        /// Gets the portion of the Twitter API containing the tweet and timeline operations.
        /// </summary>
        ITimelineOperations TimelineOperations { get; }

        /// <summary>
        /// Gets the portion of the Twitter API containing the user operations.
        /// </summary>
        IUserOperations UserOperations { get; }

        /// <summary>
        /// Gets the underlying <see cref="IRestOperations"/> object allowing for consumption of Twitter endpoints 
        /// that may not be otherwise covered by the API binding. 
        /// </summary>
        /// <remarks>
        /// The <see cref="IRestOperations"/> object returned is configured to include an OAuth "Authorization" header on all requests.
        /// </remarks>
        IRestOperations RestOperations { get; }
    }
}
