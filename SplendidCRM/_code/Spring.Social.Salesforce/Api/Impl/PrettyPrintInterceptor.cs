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

using Spring.Http.Client.Interceptor;

namespace Spring.Social.OAuth2
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	public class PrettyPrintInterceptor : IClientHttpRequestBeforeInterceptor
	{
		/// <summary>
		/// Adds the X-PrettyPrint header. 
		/// </summary>
		public PrettyPrintInterceptor()
		{
		}

		#region IClientHttpRequestBeforeInterceptor Members

		/// <summary>
		/// The callback method before the given request is executed.
		/// </summary>
		/// <remarks>
		/// This implementation sets the 'Authorization' header.
		/// </remarks>
		/// <param name="request">The request context.</param>
		public void BeforeExecute(IClientHttpRequestContext request)
		{
			request.Headers["X-PrettyPrint"] = "1";
		}

		#endregion
	}
}
