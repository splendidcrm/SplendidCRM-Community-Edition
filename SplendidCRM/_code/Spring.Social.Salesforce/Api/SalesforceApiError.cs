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

namespace Spring.Social.Salesforce.Api
{
	/// <summary>
	/// The <see cref="SalesforceApiError"/> enumeration is used by the <see cref="SalesforceApiException"/> class 
	/// to indicate what kind of error caused the exception.
	/// </summary>
	/// <author>Bruno Baia</author>
	/// <author>SplendidCRM (.NET)</author>
	public enum SalesforceApiError
	{
		/// <summary>
		/// Unknown.
		/// </summary>
		Unknown,

		/// <summary>
		/// Bad, expired or missing OAuth token. 
		/// </summary>
		NotAuthorized,

		/// <summary>
		/// Invalid operation attempted.
		/// </summary>
		OperationNotPermitted,

		/// <summary>
		/// Resource could not be found.
		/// </summary>
		ResourceNotFound,

		/// <summary>
		/// Requests are being rate-limited.
		/// </summary>
		RateLimitExceeded,

		/// <summary>
		/// Internal server error.
		/// </summary>
		Server,

		/// <summary>
		/// Server is down or is being upgraded.
		/// </summary>
		ServerDown,

		/// <summary>
		/// Server is experiencing high load.
		/// </summary>
		ServerOverloaded
	}
}
