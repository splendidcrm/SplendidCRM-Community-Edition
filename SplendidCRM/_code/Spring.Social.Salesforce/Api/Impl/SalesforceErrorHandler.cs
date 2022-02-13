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
using System.Net;
using System.Text;

using Spring.Json;
using Spring.Http;
using Spring.Rest.Client;
using Spring.Rest.Client.Support;

namespace Spring.Social.Salesforce.Api.Impl
{
	/// <summary>
	/// Implementation of the <see cref="IResponseErrorHandler"/> that handles errors from Salesforce's REST API, 
	/// interpreting them into appropriate exceptions.
	/// </summary>
	/// <author>Bruno Baia (.NET)</author>
	/// <author>SplendidCRM (.NET)</author>
	class SalesforceErrorHandler : DefaultResponseErrorHandler
	{
		// Default encoding for JSON
		private static readonly Encoding DEFAULT_CHARSET = new UTF8Encoding(false); // Remove byte Order Mask (BOM)

		/// <summary>
		/// Handles the error in the given response. 
		/// <para/>
		/// This method is only called when HasError() method has returned <see langword="true"/>.
		/// </summary>
		/// <remarks>
		/// This implementation throws appropriate exception if the response status code 
		/// is a client code error (4xx) or a server code error (5xx). 
		/// </remarks>
		/// <param name="requestUri">The request URI.</param>
		/// <param name="requestMethod">The request method.</param>
		/// <param name="response">The response message with the error.</param>
		public override void HandleError(Uri requestUri, HttpMethod requestMethod, HttpResponseMessage<byte[]> response)
		{
			int type = (int)response.StatusCode / 100;
			if (type == 4)
			{
				/*
				if (response.StatusCode == HttpStatusCode.NotFound)
				{
					string path = requestUri.AbsolutePath;
					if ( path.EndsWith("blocks/exists.json"         ) ||
						 path.EndsWith("lists/members/show.json"    ) ||
						 path.EndsWith("lists/subscribers/show.json") )
					{
						// Special cases: API binding will handle this
						return;
					}
				}
				*/
				this.HandleClientErrors(response);
			}
			else if (type == 5)
			{
				string errorDetails = DEFAULT_CHARSET.GetString(response.Body, 0, response.Body.Length);
				this.HandleServerErrors(response.StatusCode, errorDetails);
			}

			// if not otherwise handled, do default handling and wrap with SalesforceApiException
			try
			{
				base.HandleError(requestUri, requestMethod, response);
			}
			catch (Exception ex)
			{
				throw new SalesforceApiException("Error consuming Salesforce REST API.", ex);
			}
		}

		private void HandleClientErrors(HttpResponseMessage<byte[]> response) 
		{
			JsonValue errorValue = this.ExtractErrorDetailsFromResponse(response);
			if (errorValue == null) 
			{
				return; // unexpected error body, can't be handled here
			}

			string errorText = null;
			if ( errorValue.IsArray )
			{
				errorText = errorValue.GetValue(0).GetValue<string>("message");
			}
			else if ( errorValue.IsObject && errorValue.ContainsName("message") )
			{
				errorText = errorValue.GetValue<string>("message");
			}
			else if ( errorValue.IsString )
			{
				errorText = errorValue.GetValue<string>();
			}

			if ( response.StatusCode == HttpStatusCode.Unauthorized )
			{
				if ( errorText == "Could not authenticate you." )
				{
					throw new SalesforceApiException("Authorization is required for the operation, but the API binding was created without authorization.", SalesforceApiError.NotAuthorized);
				}
				else if ( errorText == "Could not authenticate with OAuth." )
				{
					throw new SalesforceApiException("The authorization has been revoked.", SalesforceApiError.NotAuthorized);
				}
				else
				{
					throw new SalesforceApiException(errorText ?? response.StatusDescription, SalesforceApiError.NotAuthorized);
				}
			}
			else if ( response.StatusCode == HttpStatusCode.BadRequest )
			{
				throw new SalesforceApiException(errorText, SalesforceApiError.OperationNotPermitted);
			}
			else if ( response.StatusCode == HttpStatusCode.Forbidden )
			{
				throw new SalesforceApiException(errorText, SalesforceApiError.OperationNotPermitted);
			}
			else if ( response.StatusCode == HttpStatusCode.NotFound )
			{
				throw new SalesforceApiException(errorText, SalesforceApiError.ResourceNotFound);
			}
			else if ( response.StatusCode == (HttpStatusCode)420 )
			{
				throw new SalesforceApiException("The rate limit has been exceeded.", SalesforceApiError.RateLimitExceeded);
			}
		}

		private void HandleServerErrors(HttpStatusCode statusCode, string errorDetails)
		{
			if ( statusCode == HttpStatusCode.InternalServerError )
			{
				JsonValue errorValue = null;
				JsonValue.TryParse(errorDetails, out errorValue);
				if ( errorValue != null && !errorValue.IsNull && errorValue.ContainsName("errorCode") )
				{
					string errorText = errorValue.GetValue<string>("message");
					throw new SalesforceApiException(errorText, SalesforceApiError.Server);
				}
				else
				{
					//throw new SalesforceApiException("Something is broken at Salesforce. Please see http://developer.Salesforce.com/ to report the issue.", SalesforceApiError.Server);
				}
			}
			else if ( statusCode == HttpStatusCode.BadGateway )
			{
				throw new SalesforceApiException("Salesforce is down or is being upgraded.", SalesforceApiError.ServerDown);
			}
			else if ( statusCode == HttpStatusCode.ServiceUnavailable )
			{
				throw new SalesforceApiException("Salesforce is overloaded with requests. Try again later.", SalesforceApiError.ServerOverloaded);
			}
		}

		private JsonValue ExtractErrorDetailsFromResponse(HttpResponseMessage<byte[]> response)
		{
			if ( response.Body == null )
			{
				return null;
			}
			MediaType contentType = response.Headers.ContentType;
			Encoding charset = (contentType != null && contentType.CharSet != null) ? contentType.CharSet : DEFAULT_CHARSET;
			string errorDetails = charset.GetString(response.Body, 0, response.Body.Length);

			JsonValue result;
			return JsonValue.TryParse(errorDetails, out result) ? result : null;
		}
	}
}