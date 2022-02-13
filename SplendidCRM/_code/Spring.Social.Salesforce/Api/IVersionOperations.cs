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
	public interface IVersionOperations
	{
		/// <summary>
		/// Lists summary information about each Salesforce version currently available, including the version, label, and a link to each version's root. 
		/// </summary>
		/// <returns>A list of Version objects.</returns>
		List<SalesforceVersion> GetVersions();

		/// <summary>
		/// Lists available resources for the specified API version, including resource name and URI. 
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <returns>Resources object.</returns>
		SalesforceResources GetResourcesByVersion(string version);
	}
}
