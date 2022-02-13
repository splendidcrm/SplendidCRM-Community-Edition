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
	public interface IMetadataOperations
	{
		/// 04/22/2012 Paul.  These are the SOAP API methods. 
		/// DescribeSObjectResult                      describeSObject(string sObjectType);
		/// DescribeSObjectResult[]                    describeSObjects(string[] sObjectType);
		/// DescribeGlobalResult                       describeGlobal();
		/// DescribeDataCategoryGroupResult[]          describeDataCategoryGroups(string[] sObjectType);
		/// DescribeDataCategoryGroupStructureResult[] describeDataCategoryGroupStructures(DataCategoryGroupSobjectTypePair[] pairs, bool topCategoriesOnly);
		/// DescribeLayoutResult                       describeLayout(string sObjectType, string[] recordTypeIds);
		/// DescribeSoftphoneLayoutResult              describeSoftphoneLayout();
		/// DescribeTabSetResult[]                     describeTabs();

		/// <summary>
		/// Lists the available objects and their metadata for your organization's data. In addition, it provides the organization encoding, as well as maximum batch size permitted in queries.
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <returns>Globals object.</returns>
		DescribeGlobal DescribeGlobal(string version);

		/// <summary>
		/// Completely describes the individual metadata at all levels for the specified object. For example, this can be used to retrieve the fields, URLs, and child relationships for the Account object.
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <param name="name">SObject name.</param>
		/// <returns>Globals object.</returns>
		DescribeSObject DescribeSObject(string version, string name);
	}
}
