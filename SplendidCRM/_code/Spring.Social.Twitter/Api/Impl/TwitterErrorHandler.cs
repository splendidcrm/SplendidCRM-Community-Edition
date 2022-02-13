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
using System.Net;
using System.Text;

using Spring.Json;
using Spring.Http;
using Spring.Rest.Client;
using Spring.Rest.Client.Support;

namespace Spring.Social.Twitter.Api.Impl
{
    /// <summary>
    /// Implementation of the <see cref="IResponseErrorHandler"/> that handles errors from Twitter's REST API, 
    /// interpreting them into appropriate exceptions.
    /// <para/>
    /// <see cref="https://dev.twitter.com/docs/error-codes-responses"/>
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class TwitterErrorHandler : DefaultResponseErrorHandler
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
                if (response.StatusCode == HttpStatusCode.NotFound)
                {
                    string path = requestUri.AbsolutePath;
                    if (path.EndsWith("lists/members/show.json") ||
                        path.EndsWith("lists/subscribers/show.json"))
                    {
                        // Special cases: API binding will handle this
                        return;
                    }
                }
                this.HandleClientErrors(response);
            }
            else if (type == 5)
            {
                this.HandleServerErrors(response.StatusCode);
            }

            // if not otherwise handled, do default handling and wrap with TwitterApiException
            try
            {
                base.HandleError(requestUri, requestMethod, response);
            }
            catch (Exception ex)
            {
                throw new TwitterApiException("Error consuming Twitter REST API.", ex);
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
		    if (errorValue.ContainsName("error")) 
            {
			    errorText = errorValue.GetValue<string>("error");
		    } 
            else if(errorValue.ContainsName("errors")) 
            {
			    JsonValue errorsValue = errorValue.GetValue("errors");			
			    if (errorsValue.IsArray) 
                {
				    errorText = errorsValue.GetValue(0).GetValue<string>("message");
			    } 
                else if (errorsValue.IsString) 
                {
				    errorText = errorsValue.GetValue<string>();
			    }
		    }
            errorText = errorText ?? response.StatusDescription;

		    if (response.StatusCode == HttpStatusCode.Unauthorized) 
            {
                throw new TwitterApiException(errorText, TwitterApiError.NotAuthorized);
		    } 
            else if (response.StatusCode == HttpStatusCode.Forbidden) 
            {
                throw new TwitterApiException(errorText, TwitterApiError.OperationNotPermitted);
		    } 
            else if (response.StatusCode == HttpStatusCode.NotFound) 
            {
                throw new TwitterApiException(errorText, TwitterApiError.ResourceNotFound);
		    }
            else if (response.StatusCode == HttpStatusCode.NotAcceptable)
            {
                throw new TwitterApiException(errorText, TwitterApiError.InvalidFormat);
            }
            else if (response.StatusCode == (HttpStatusCode)429) // Too Many Requests
            {
                throw new TwitterApiException("The rate limit has been exceeded.", TwitterApiError.RateLimitExceeded);
            }
	    }

	    private void HandleServerErrors(HttpStatusCode statusCode)
        {
		    if (statusCode == HttpStatusCode.InternalServerError) 
            {
                throw new TwitterApiException(
                    "Something is broken at Twitter. Please see http://dev.twitter.com/pages/support to report the issue.", 
                    TwitterApiError.Server);
		    } 
            else if (statusCode == HttpStatusCode.BadGateway) 
            {
                throw new TwitterApiException("Twitter is down or is being upgraded.", TwitterApiError.ServerDown);
		    } 
            else if (statusCode == HttpStatusCode.ServiceUnavailable) 
            {
                throw new TwitterApiException("Twitter is overloaded with requests. Try again later.", TwitterApiError.ServerOverloaded);
		    }
            else if (statusCode == HttpStatusCode.GatewayTimeout)
            {
                throw new TwitterApiException("Twitter servers are up, but the request couldn't be serviced. Try again later.", TwitterApiError.ServerOverloaded);
            }
	    }

        private JsonValue ExtractErrorDetailsFromResponse(HttpResponseMessage<byte[]> response) 
        {
            if (response.Body == null)
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