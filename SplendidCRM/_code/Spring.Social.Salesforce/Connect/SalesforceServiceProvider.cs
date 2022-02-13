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
using System.IO;
using System.Net;
using System.Collections.Generic;

using Spring.Json;
using Spring.Social.OAuth2;
using Spring.Social.Salesforce.Api;
using Spring.Social.Salesforce.Api.Impl;

namespace Spring.Social.Salesforce.Connect
{
	/// <summary>
	/// Salesforce <see cref="IServiceProvider"/> implementation.
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	public class SalesforceServiceProvider : AbstractOAuth2ServiceProvider<ISalesforce>
	{
		/// <summary>
		/// Creates a new instance of <see cref="SalesforceServiceProvider"/>.
		/// </summary>
		/// <param name="clientId">The application's API key.</param>
		/// <param name="clientSecret">The application's API secret.</param>
		public SalesforceServiceProvider(string clientId, string clientSecret) : base(new SalesforceOAuth2Template(clientId, clientSecret))
		{
		}

		/// <summary>
		/// Returns an API interface allowing the client application to access protected resources on behalf of a user.
		/// </summary>
		/// <param name="accessToken">The API access token.</param>
		/// <returns>A binding to the service provider's API.</returns>
		public override ISalesforce GetApi(string accessToken)
		{
			throw(new Exception("Not supported"));
		}

		/// <summary>
		/// Returns an API interface allowing the client application to access protected resources on behalf of a user.
		/// </summary>
		/// <param name="instanceURL">Instance URL is based on the Salseforce application.</param>
		/// <param name="accessToken">The API access token.</param>
		/// <returns>A binding to the service provider's API.</returns>
		public ISalesforce GetApi(string instanceURL, string accessToken)
		{
			return new SalesforceTemplate(instanceURL, accessToken);
		}

		/// <summary>
		/// Authenticates using Username and Password.
		/// </summary>
		/// <param name="clientId">The client identifier.</param>
		/// <param name="clientSecret">The client secret.</param>
		/// <param name="username">Username.</param>
		/// <param name="password">Password.</param>
		/// <param name="securityToken">Security Token.</param>
		public static JsonValue GetAccessToken(string clientId, string clientSecret, string username, string password, string securityToken)
		{
			// http://forums.crmsuccess.com/t5/forums/forumtopicprintpage/board-id/integration/message-id/481/print-single-message/false/page/1
			string request = String.Format("grant_type=password&client_id={0}&client_secret={1}&username={2}&password={3}&format=json", Spring.Http.HttpUtils.UrlEncode(clientId), Spring.Http.HttpUtils.UrlEncode(clientSecret),Spring.Http.HttpUtils.UrlEncode(username), Spring.Http.HttpUtils.UrlEncode(password + securityToken));
			
			HttpWebRequest objRequest = (HttpWebRequest) WebRequest.Create("https://login.salesforce.com/services/oauth2/token");
			objRequest.Method      = "POST";
			objRequest.Timeout     = 15000;  //15 seconds
			objRequest.Accept      = "*/*";
			objRequest.ContentType = "application/x-www-form-urlencoded";
			byte[] by = System.Text.Encoding.UTF8.GetBytes(request);
			objRequest.ContentLength = by.Length;
			objRequest.GetRequestStream().Write(by, 0, by.Length);

			JsonValue jsonValue = new JsonValue();
			using ( HttpWebResponse objResponse = (HttpWebResponse) objRequest.GetResponse() )
			{
				if ( objResponse != null )
				{
					if ( objResponse.StatusCode != HttpStatusCode.OK && objResponse.StatusCode != HttpStatusCode.Redirect )
					{
						throw(new Exception(objResponse.StatusCode + " " + objResponse.StatusDescription));
					}
					else
					{
						using ( StreamReader readStream = new StreamReader(objResponse.GetResponseStream(), System.Text.Encoding.UTF8) )
						{
							string sResponse = readStream.ReadToEnd();
							jsonValue = JsonValue.Parse(sResponse);
						}
					}
				}
			}
			return jsonValue;
		}
	}
}
