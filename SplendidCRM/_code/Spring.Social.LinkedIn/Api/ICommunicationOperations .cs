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
    /// Interface defining the operations for sending messages and sending connect invitations to other users on LinkedIn.
    /// </summary>
    /// <author>Robert Drysdale</author>
    /// <author>Bruno Baia (.NET)</author>
    public interface ICommunicationOperations
    {
#if NET_4_0 || SILVERLIGHT_5
        /// <summary>
        /// Asynchronously sends a textual message to a recipient specified by its ID.
        /// </summary>
        /// <param name="subject">The subject of the message.</param>
        /// <param name="body">The body or text of the message (does not support html).</param>
        /// <param name="recipientId">The recipient <see cref="LinkedInProfile"/> ID.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task SendMessageAsync(string subject, string body, string recipientId);

        /// <summary>
        /// Asynchronously sends a textual message to a list of recipients specified by their ID.
        /// </summary>
        /// <param name="subject">The subject of the message.</param>
        /// <param name="body">The body or text of the message (does not support html).</param>
        /// <param name="recipientIds">The list of recipient <see cref="LinkedInProfile"/> IDs. At least one.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task SendMessageAsync(string subject, string body, string[] recipientIds);

        /// <summary>
        /// Asynchronously sends a connect invitation message to recipient ID.
        /// </summary>
        /// <param name="subject">The subject of the invitation message.</param>
        /// <param name="body">The body or text of the invitation message (does not support html).</param>
        /// <param name="recipientId">The recipient ID.</param>
        /// <param name="recipientAuthToken">The recipient additional authorization token returned when performing a search.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task ConnectToAsync(string subject, string body, string recipientId, string recipientAuthToken);

        /// <summary>
        /// Asynchronously sends a connect invitation message to an email (for users not on LinkedIn).
        /// </summary>
        /// <param name="subject">The subject of the invitation message.</param>
        /// <param name="body">The body or text of the invitation message (does not support html).</param>
        /// <param name="email">The email address of the recipient.</param>
        /// <param name="firstName">The first name of the recipient.</param>
        /// <param name="lastName">The last name of the recipient.</param>
        /// <returns>
        /// A <code>Task</code> that represents the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        Task ConnectToAsync(string subject, string body, string email, string firstName, string lastName);
#else
#if !SILVERLIGHT
        /// <summary>
        /// Sends a textual message to a recipient specified by its ID.
        /// </summary>
        /// <param name="subject">The subject of the message.</param>
        /// <param name="body">The body or text of the message (does not support html).</param>
        /// <param name="recipientId">The recipient <see cref="LinkedInProfile"/> ID.</param>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        void SendMessage(string subject, string body, string recipientId);

        /// <summary>
        /// Sends a textual message to a list of recipients specified by their ID.
        /// </summary>
        /// <param name="subject">The subject of the message.</param>
        /// <param name="body">The body or text of the message (does not support html).</param>
        /// <param name="recipientIds">The list of recipient <see cref="LinkedInProfile"/> IDs. At least one.</param>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        void SendMessage(string subject, string body, string[] recipientIds);

        /// <summary>
        /// Sends a connect invitation message to recipient ID.
        /// </summary>
        /// <param name="subject">The subject of the invitation message.</param>
        /// <param name="body">The body or text of the invitation message (does not support html).</param>
        /// <param name="recipientId">The recipient ID.</param>
        /// <param name="recipientAuthToken">The recipient additional authorization token returned when performing a search.</param>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        void ConnectTo(string subject, string body, string recipientId, string recipientAuthToken);

        /// <summary>
        /// Sends a connect invitation message to an email (for users not on LinkedIn).
        /// </summary>
        /// <param name="subject">The subject of the invitation message.</param>
        /// <param name="body">The body or text of the invitation message (does not support html).</param>
        /// <param name="email">The email address of the recipient.</param>
        /// <param name="firstName">The first name of the recipient.</param>
        /// <param name="lastName">The last name of the recipient.</param>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        void ConnectTo(string subject, string body, string email, string firstName, string lastName);
#endif

        /// <summary>
        /// Asynchronously sends a textual message to a recipient specified by its ID.
        /// </summary>
        /// <param name="subject">The subject of the message.</param>
        /// <param name="body">The body or text of the message (does not support html).</param>
        /// <param name="recipientId">The recipient <see cref="LinkedInProfile"/> ID.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler SendMessageAsync(string subject, string body, string recipientId, Action<RestOperationCompletedEventArgs<object>> operationCompleted);

        /// <summary>
        /// Asynchronously sends a textual message to a list of recipients specified by their ID.
        /// </summary>
        /// <param name="subject">The subject of the message.</param>
        /// <param name="body">The body or text of the message (does not support html).</param>
        /// <param name="recipientIds">The list of recipient <see cref="LinkedInProfile"/> IDs. At least one.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler SendMessageAsync(string subject, string body, string[] recipientIds, Action<RestOperationCompletedEventArgs<object>> operationCompleted);

        /// <summary>
        /// Asynchronously sends a connect invitation message to recipient ID.
        /// </summary>
        /// <param name="subject">The subject of the invitation message.</param>
        /// <param name="body">The body or text of the invitation message (does not support html).</param>
        /// <param name="recipientId">The recipient ID.</param>
        /// <param name="recipientAuthToken">The recipient additional authorization token returned when performing a search.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler ConnectToAsync(string subject, string body, string recipientId, string recipientAuthToken, Action<RestOperationCompletedEventArgs<object>> operationCompleted);

        /// <summary>
        /// Asynchronously sends a connect invitation message to an email (for users not on LinkedIn).
        /// </summary>
        /// <param name="subject">The subject of the invitation message.</param>
        /// <param name="body">The body or text of the invitation message (does not support html).</param>
        /// <param name="email">The email address of the recipient.</param>
        /// <param name="firstName">The first name of the recipient.</param>
        /// <param name="lastName">The last name of the recipient.</param>
        /// <param name="operationCompleted">
        /// The <code>Action&lt;&gt;</code> to perform when the asynchronous request completes.
        /// </param>
        /// <returns>
        /// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
        /// </returns>
        /// <exception cref="LinkedInApiException">If there is an error while communicating with LinkedIn.</exception>
        RestOperationCanceler ConnectToAsync(string subject, string body, string email, string firstName, string lastName, Action<RestOperationCompletedEventArgs<object>> operationCompleted);
#endif
    }
}
