#region License

/*
 * Copyright 2010-2012 the original author or authors.
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

using Spring.Social.OAuth2;
using Spring.Social.Facebook.Api;
using Spring.Social.Facebook.Api.Impl;

namespace Spring.Social.Facebook.Connect
{
	/// <summary>
	/// Facebook <see cref="IServiceProvider"/> implementation.
	/// </summary>
	/// <author>Keith Donald</author>
	/// <author>SplendidCRM (.NET)</author>
	public class FacebookServiceProvider : AbstractOAuth2ServiceProvider<IFacebook>
	{
		/// <summary>
		/// Creates a new instance of <see cref="FacebookServiceProvider"/>.
		/// </summary>
		/// <param name="clientId">The application's API key.</param>
		/// <param name="clientSecret">The application's API secret.</param>
		public FacebookServiceProvider(string clientId, string clientSecret)
			: base(new FacebookOAuth2Template(clientId, clientSecret))
		{
		}

		/// <summary>
		/// Returns an API interface allowing the client application to access protected resources on behalf of a user.
		/// </summary>
		/// <param name="accessToken">The API access token.</param>
		/// <returns>A binding to the service provider's API.</returns>
		public override IFacebook GetApi(String accessToken)
		{
			return new FacebookTemplate(accessToken);
		}
	}
}
