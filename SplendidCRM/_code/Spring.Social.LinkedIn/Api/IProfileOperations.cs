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
    /// Interface defining the operations for retrieving and performing operations on profiles.
    /// </summary>
    /// <author>Robert Drysdale</author>
    /// <author>Bruno Baia (.NET)</author>
    public interface IProfileOperations
    {
#if NET_4_0 || SILVERLIGHT_5
	    /// <summary>
        /// Asynchronously retrieves the authenticated user's LinkedIn profile details.
	    /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="LinkedInProfile"/> object representing the user's profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
	    Task<LinkedInProfile> GetUserProfileAsync();

        /// <summary>
        /// Asynchronously retrieves a specific user's LinkedIn profile details by its ID.
        /// </summary>
        /// <param name="id">The user ID for the user whose details are to be retrieved.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="LinkedInProfile"/> object representing the user's profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task<LinkedInProfile> GetUserProfileByIdAsync(string id);

        /// <summary>
        /// Asynchronously retrieves a specific user's LinkedIn profile details by its public url.
        /// </summary>
        /// <param name="url">The user public url for the user whose details are to be retrieved.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="LinkedInProfile"/> object representing the user's profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task<LinkedInProfile> GetUserProfileByPublicUrlAsync(string url);

        /// <summary>
        /// Asynchronously retrieves the authenticated user's LinkedIn full profile details.
        /// </summary>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="LinkedInFullProfile"/> object representing the full user's profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task<LinkedInFullProfile> GetUserFullProfileAsync();

        /// <summary>
        /// Asynchronously retrieves a specific user's LinkedIn full profile details by its ID.
        /// </summary>
        /// <param name="id">The user ID for the user whose details are to be retrieved.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="LinkedInFullProfile"/> object representing the full user's profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task<LinkedInFullProfile> GetUserFullProfileByIdAsync(string id);

        /// <summary>
        /// Asynchronously retrieves a specific user's LinkedIn full profile details by its public url.
        /// </summary>
        /// <param name="url">The user public url for the user whose details are to be retrieved.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// a <see cref="LinkedInFullProfile"/> object representing the full user's profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task<LinkedInFullProfile> GetUserFullProfileByPublicUrlAsync(string url);

        /// <summary>
        /// Asynchronously searches for LinkedIn profiles based on provided parameters.
        /// </summary>
        /// <param name="parameters">The profile search parameters.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation that can return 
        /// an object containing the search results metadata and a list of matching <see cref="LinkedInProfile"/>s.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task<LinkedInProfiles> SearchAsync(SearchParameters parameters);
#else
#if !SILVERLIGHT
        /// <summary>
        /// Retrieves the authenticated user's LinkedIn profile details.
	    /// </summary>
        /// <returns>
        /// A <see cref="LinkedInProfile"/> object representing the user's profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
	    LinkedInProfile GetUserProfile();

        /// <summary>
        /// Retrieves a specific user's LinkedIn profile details by its ID.
        /// </summary>
        /// <param name="id">The user ID for the user whose details are to be retrieved.</param>
        /// <returns>
        /// A <see cref="LinkedInProfile"/> object representing the user's profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        LinkedInProfile GetUserProfileById(string id);

        /// <summary>
        /// Retrieves a specific user's LinkedIn profile details by its public url.
        /// </summary>
        /// <param name="url">The user public url for the user whose details are to be retrieved.</param>
        /// <returns>
        /// A <see cref="LinkedInProfile"/> object representing the user's profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        LinkedInProfile GetUserProfileByPublicUrl(string url);

        /// <summary>
        /// Retrieves the authenticated user's LinkedIn full profile details.
        /// </summary>
        /// <returns>
        /// A <see cref="LinkedInFullProfile"/> object representing the full user's profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        LinkedInFullProfile GetUserFullProfile();

        /// <summary>
        /// Retrieves a specific user's LinkedIn full profile details by its ID.
        /// </summary>
        /// <param name="id">The user ID for the user whose details are to be retrieved.</param>
        /// <returns>
        /// A <see cref="LinkedInFullProfile"/> object representing the user's full profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        LinkedInFullProfile GetUserFullProfileById(string id);

        /// <summary>
        /// Retrieves a specific user's LinkedIn full profile details by its public url.
        /// </summary>
        /// <param name="url">The user public url for the user whose details are to be retrieved.</param>
        /// <returns>
        /// A <see cref="LinkedInFullProfile"/> object representing the user's full profile.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        LinkedInFullProfile GetUserFullProfileByPublicUrl(string url);

        /// <summary>
        /// Searches for LinkedIn profiles based on provided parameters.
        /// </summary>
        /// <param name="parameters">The profile search parameters.</param>
        /// <returns>
        /// An object containing the search results metadata and a list of matching <see cref="LinkedInProfile"/>s.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        LinkedInProfiles Search(SearchParameters parameters);
#endif

        /// <summary>
        /// Asynchronously retrieves the authenticated user's LinkedIn profile details.
	    /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="LinkedInProfile"/> object representing the user's profile.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
	    RestOperationCanceler GetUserProfileAsync(Action<RestOperationCompletedEventArgs<LinkedInProfile>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves a specific user's LinkedIn profile details by its ID.
        /// </summary>
        /// <param name="id">The user ID for the user whose details are to be retrieved.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="LinkedInProfile"/> object representing the user's profile.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler GetUserProfileByIdAsync(string id, Action<RestOperationCompletedEventArgs<LinkedInProfile>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves the authenticated user's LinkedIn full profile details.
        /// </summary>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="LinkedInFullProfile"/> object representing the user's full profile.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler GetUserFullProfileAsync(Action<RestOperationCompletedEventArgs<LinkedInFullProfile>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves a specific user's LinkedIn full profile details by its ID.
        /// </summary>
        /// <param name="id">The user ID for the user whose details are to be retrieved.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="LinkedInFullProfile"/> object representing the user's full profile.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler GetUserFullProfileByIdAsync(string id, Action<RestOperationCompletedEventArgs<LinkedInFullProfile>> operationCompleted);
#if !WINDOWS_PHONE
        /// <summary>
        /// Asynchronously retrieves a specific user's LinkedIn profile details by its public url.
        /// </summary>
        /// <param name="url">The user public url for the user whose details are to be retrieved.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="LinkedInProfile"/> object representing the user's profile.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler GetUserProfileByPublicUrlAsync(string url, Action<RestOperationCompletedEventArgs<LinkedInProfile>> operationCompleted);

        /// <summary>
        /// Asynchronously retrieves a specific user's LinkedIn full profile details by its public url.
        /// </summary>
        /// <param name="url">The user public url for the user whose details are to be retrieved.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides a <see cref="LinkedInFullProfile"/> object representing the user's full profile.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler GetUserFullProfileByPublicUrlAsync(string url, Action<RestOperationCompletedEventArgs<LinkedInFullProfile>> operationCompleted);
#endif

        /// <summary>
        /// Asynchronously searches for LinkedIn profiles based on provided parameters.
        /// </summary>
        /// <param name="parameters">The profile search parameters.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes. 
        /// Provides an object containing the search results metadata and a list of matching <see cref="LinkedInProfile"/>s.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler SearchAsync(SearchParameters parameters, Action<RestOperationCompletedEventArgs<LinkedInProfiles>> operationCompleted);
#endif
    }
}
