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
	public interface ISObjectOperations
	{
		/// 04/22/2012 Paul.  These are the SOAP API methods. 
		/// createResponse          create(createRequest request);
		/// updateResponse          update(updateRequest request);
		/// upsertResponse          upsert(upsertRequest request);
		/// mergeResponse           merge(mergeRequest1 request);
		/// deleteResponse          delete(deleteRequest request);
		/// undeleteResponse        undelete(undeleteRequest request);
		/// GetDeletedResult        getDeleted(string sObjectType, System.DateTime startDate, System.DateTime endDate);
		/// GetUpdatedResult        getUpdated(string sObjectType, System.DateTime startDate, System.DateTime endDate);
		/// sObject[]               retrieve(QueryOptions QueryOptions, string fieldList, string sObjectType, string[] ids);
		/// EmptyRecycleBinResult[] emptyRecycleBin(string[] ids);
		/// convertLeadResponse     convertLead(convertLeadRequest request);

		/// <summary>
		/// Describes the individual metadata for the specified object. For example, this can be used to retrieve the metadata for the Account object or post a new Account object.
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <param name="name">SObject name.</param>
		/// <returns>Globals object.</returns>
		BasicSObject GetBasicSObject(string version, string name);

		/// <summary>
		/// Accesses records based on the specified object ID. Retrieves, creates, updates, or deletes records.
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <param name="name">SObject name.</param>
		/// <param name="id">SObject ID.</param>
		/// <returns>Globals object.</returns>
		SObject GetSObject(string version, string name, string id);

		/// <summary>
		/// Accesses records based on the specified object ID. Retrieves, creates, updates, or deletes records.
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <param name="name">SObject name.</param>
		/// <param name="id">SObject ID.</param>
		/// <param name="fields">Fields to retrive.</param>
		/// <returns>Globals object.</returns>
		SObject GetSObject(string version, string name, string id, string[] fields);

		/// <summary>
		/// Retrieves the specified blob field from an individual record.
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <param name="name">SObject name.</param>
		/// <param name="id">SObject ID.</param>
		/// <param name="field">Field to retrive.</param>
		/// <returns>Globals object.</returns>
		byte[] GetSObjectBlob(string version, string name, string id, string field);

		/// <summary>
		/// Accesses records based on the specified object ID. Retrieves, creates, updates, or deletes records.
		/// </summary>
		/// <param name="version">Version number.</param>
		/// <param name="name">SObject name.</param>
		/// <param name="id">SObject ID.</param>
		/// <returns>Globals object.</returns>
		void DeleteSObject(string version, string name, string id);
	}
}
