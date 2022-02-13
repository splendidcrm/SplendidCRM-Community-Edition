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
using System.Collections.Generic;
using Spring.Rest.Client;
using Spring.Http;

namespace Spring.Social.Salesforce.Api
{
	/// <summary>
	/// http://www.salesforce.com/us/developer/docs/api_rest/index.htm
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	public interface IUserOperations
	{
		/// 04/22/2012 Paul.  These are the SOAP API methods. 
		/// SetPasswordResult          setPassword(string userId, string password);
		/// ResetPasswordResult        resetPassword(EmailHeader EmailHeader, string userId);
		/// GetUserInfoResult          getUserInfo();

		/// <summary>
		/// These methods set, reset, or get information about a user password.
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <param name="userId">User name.</param>
		/// <returns></returns>
		bool GetPasswordExpiration(string version, string userId);

		/// <summary>
		/// These methods set, reset, or get information about a user password.
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <param name="userId">User name.</param>
		/// <param name="password">Password.</param>
		/// <returns></returns>
		void SetPassword(string version, string userId, string password);

		/// <summary>
		/// These methods set, reset, or get information about a user password.
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <param name="userId">User name.</param>
		/// <returns></returns>
		string ResetPassword(string version, string userId);
	}
}
