#region License

/*
 * Copyright (C) 2012 SplendidCRM Software, Inc. All Rights Reserved. 
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
#if NET_4_0 || SILVERLIGHT_5
using System.Threading.Tasks;
#endif
#if SILVERLIGHT
using Spring.Collections.Specialized;
#else
using System.Collections.Specialized;
#endif

using Spring.Rest.Client;
using Spring.Social.OAuth2;

namespace Spring.Social.Salesforce.Connect
{
	/// <summary>
	/// Salesforce-specific extension of OAuth2Template to use a RestTemplate that recognizes form-encoded responses as "text/plain".
	/// <para/>
	/// (The OAuth 2 specification indicates that an access token response should be in JSON format)
	/// </summary>
	/// <remarks>
	/// Salesforce token responses are form-encoded results with a content type of "text/plain", 
	/// which prevents the FormHttpMessageConverter registered by default from parsing the results.
	/// </remarks>
	/// <author>SplendidCRM (.NET)</author>
	public class SalesforceOAuth2Template : OAuth2Template
	{
		/// <summary>
		/// Creates a new instance of <see cref="SalesforceOAuth2Template"/>.
		/// </summary>
		/// <param name="clientId">The client identifier.</param>
		/// <param name="clientSecret">The client secret.</param>
		public SalesforceOAuth2Template(string clientId, string clientSecret)
			: base(clientId, clientSecret, 
				"https://login.salesforce.com/services/oauth2/authorize", 
				"https://login.salesforce.com/services/oauth2/token")
		{
		}

#if NET_4_0 || SILVERLIGHT_5
		/// <summary>
		/// Asynchronously posts the request for an access grant to the provider.
		/// </summary>
		/// <remarks>
		/// The default implementation uses RestTemplate to request the access token and expects a JSON response to be bound to a dictionary.
		/// The information in the dictionary will be used to create an <see cref="AccessGrant"/>.
		/// Since the OAuth 2 specification indicates that an access token response should be in JSON format, there's often no need to override this method.
		/// If all you need to do is capture provider-specific data in the response, you should override CreateAccessGrant() instead.
		/// However, in the event of a provider whose access token response is non-JSON, 
		/// you may need to override this method to request that the response be bound to something other than a dictionary.
		/// For example, if the access token response is given as form-encoded, this method should be overridden to call RestTemplate.PostForObject() 
		/// asking for the response to be bound to a NameValueCollection (whose contents can then be used to create an <see cref="AccessGrant"/>).
		/// </remarks>
		/// <param name="accessTokenUrl">The URL of the provider's access token endpoint.</param>
		/// <param name="request">The request data to post to the access token endpoint.</param>
		/// <returns>
		/// A <code>Task&lt;AccessGrant&gt;</code> that represents the asynchronous operation that can return the OAuth2 access token.
		/// </returns>
		protected override Task<AccessGrant> PostForAccessGrantAsync(string accessTokenUrl, NameValueCollection request)
		{
			return this.RestTemplate.PostForObjectAsync<NameValueCollection>(accessTokenUrl, request)
				.ContinueWith<AccessGrant>(task =>
				{
					string expires = task.Result["expires"];
					return new AccessGrant(task.Result["access_token"], null, null, expires != null ? new Nullable<int>(Int32.Parse(expires)) : null);
				});
		}
#else
#if !SILVERLIGHT
		/// <summary>
		/// Posts the request for an access grant to the provider.
		/// </summary>
		/// <remarks>
		/// The default implementation uses RestTemplate to request the access token and expects a JSON response to be bound to a dictionary.
		/// The information in the dictionary will be used to create an <see cref="AccessGrant"/>.
		/// Since the OAuth 2 specification indicates that an access token response should be in JSON format, there's often no need to override this method.
		/// If all you need to do is capture provider-specific data in the response, you should override CreateAccessGrant() instead.
		/// However, in the event of a provider whose access token response is non-JSON, 
		/// you may need to override this method to request that the response be bound to something other than a dictionary.
		/// For example, if the access token response is given as form-encoded, this method should be overridden to call RestTemplate.PostForObject() 
		/// asking for the response to be bound to a NameValueCollection (whose contents can then be used to create an <see cref="AccessGrant"/>).
		/// </remarks>
		/// <param name="accessTokenUrl">The URL of the provider's access token endpoint.</param>
		/// <param name="request">The request data to post to the access token endpoint.</param>
		/// <returns>The OAuth2 access token.</returns>
		protected override AccessGrant PostForAccessGrant(string accessTokenUrl, NameValueCollection request)
		{
			NameValueCollection response = this.RestTemplate.PostForObject<NameValueCollection>(accessTokenUrl, request);
			string expires = response["expires"];
			return new AccessGrant(response["access_token"], null, null, expires != null ? new Nullable<int>(Int32.Parse(expires)) : null);
		}
#endif
		/// <summary>
		/// Asynchronously posts the request for an access grant to the provider.
		/// </summary>
		/// <remarks>
		/// The default implementation uses RestTemplate to request the access token and expects a JSON response to be bound to a dictionary.
		/// The information in the dictionary will be used to create an <see cref="AccessGrant"/>.
		/// Since the OAuth 2 specification indicates that an access token response should be in JSON format, there's often no need to override this method.
		/// If all you need to do is capture provider-specific data in the response, you should override CreateAccessGrant() instead.
		/// However, in the event of a provider whose access token response is non-JSON, 
		/// you may need to override this method to request that the response be bound to something other than a dictionary.
		/// For example, if the access token response is given as form-encoded, this method should be overridden to call RestTemplate.PostForObject() 
		/// asking for the response to be bound to a NameValueCollection (whose contents can then be used to create an <see cref="AccessGrant"/>).
		/// </remarks>
		/// <param name="accessTokenUrl">The URL of the provider's access token endpoint.</param>
		/// <param name="request">The request data to post to the access token endpoint.</param>
		/// <param name="operationCompleted">
		/// The <code>Action&lt;T&gt;</code> to perform when the asynchronous request completes. 
		/// Provides the OAuth2 access token.
		/// </param>
		/// <returns>
		/// A <see cref="RestOperationCanceler"/> instance that allows to cancel the asynchronous operation.
		/// </returns>
		protected override RestOperationCanceler PostForAccessGrantAsync(string accessTokenUrl, NameValueCollection request, Action<RestOperationCompletedEventArgs<AccessGrant>> operationCompleted)
		{
			return this.RestTemplate.PostForObjectAsync<NameValueCollection>(accessTokenUrl, request,
				r =>
				{
					if (r.Error == null)
					{
						string expires = r.Response["expires"];
						AccessGrant token = new AccessGrant(r.Response["access_token"], null, null, expires != null ? new Nullable<int>(Int32.Parse(expires)) : null);
						operationCompleted(new RestOperationCompletedEventArgs<AccessGrant>(token, null, false, r.UserState));
					}
					else
					{
						operationCompleted(new RestOperationCompletedEventArgs<AccessGrant>(null, r.Error, r.Cancelled, r.UserState));
					}
				});
		}
#endif
	}
}
