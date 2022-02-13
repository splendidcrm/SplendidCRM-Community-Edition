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

using Spring.Rest.Client;

namespace Spring.Social.Salesforce.Api
{
	/// <summary>
	/// Interface specifying a basic set of operations for interacting with Salesforce.
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	public interface ISalesforce : IApiBinding
	{
		/// 04/22/2012 Paul.  These are the SOAP API methods. 
		/// LoginResult                login(LoginScopeHeader LoginScopeHeader, string username, string password);
		/// void                       logout();
		/// GetServerTimestampResult   getServerTimestamp();
		/// processResponse            process(processRequest1 request);
		/// InvalidateSessionsResult[] invalidateSessions(string[] sessionIds);
		/// SendEmailResult[]          sendEmail(Email[] messages);

		/// <summary>
		/// </summary>
		IVersionOperations VersionOperations { get; }

		/// <summary>
		/// </summary>
		IMetadataOperations MetadataOperations { get; }

		/// <summary>
		/// </summary>
		ISObjectOperations SObjectOperations { get; }

		/// <summary>
		/// </summary>
		ISearchOperations SearchOperations { get; }

		/// <summary>
		/// </summary>
		IUserOperations UserOperations { get; }

		/// <summary>
		/// Gets the underlying <see cref="IRestOperations"/> object allowing for consumption of Salesforce endpoints 
		/// that may not be otherwise covered by the API binding. 
		/// </summary>
		/// <remarks>
		/// The <see cref="IRestOperations"/> object returned is configured to include an OAuth "Authorization" header on all requests.
		/// </remarks>
		IRestOperations RestOperations { get; }

	}
}
