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
using System.Collections.Generic;
using System.Collections.Specialized;

using Spring.Rest.Client;

namespace Spring.Social.Facebook.Api
{
	/// <summary>
	/// Interface specifying a basic set of operations for interacting with Facebook.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IGraphApi
	{
		/// <summary>
		/// Fetches an object, extracting it into the given Java type
		/// Requires appropriate permission to fetch the object.
		/// </summary>
		/// <param name="objectId">the Facebook object's ID</param>
		/// <returns>an Java object representing the requested Facebook object.</returns>
		T FetchObject<T>(string objectId) where T : class;

		/// <summary>
		/// Fetches an object, extracting it into the given Java type
		/// Requires appropriate permission to fetch the object.
		/// </summary>
		/// <param name="objectId">the Facebook object's ID</param>
		/// <param name="queryParameters">query parameters to include in the request</param>
		/// <returns>an Java object representing the requested Facebook object.</returns>
		T FetchObject<T>(string objectId, NameValueCollection queryParameters) where T : class;

		/// <summary>
		/// Fetches connections, extracting them into a collection of the given Java type 
		/// Requires appropriate permission to fetch the object connection.
		/// </summary>
		/// <param name="objectId">the ID of the object to retrieve the connections for.</param>
		/// <param name="connectionName">the connection name.</param>
		/// <param name="fields">the fields to include in the response.</param>
		/// <returns>a list of Java objects representing the Facebook objects in the connections.</returns>
		List<T> FetchConnections<T>(string objectId, string connectionName, string[] fields) where T : class;
	
		/// <summary>
		/// Fetches connections, extracting them into a collection of the given Java type 
		/// Requires appropriate permission to fetch the object connection.
		/// </summary>
		/// <param name="objectId">the ID of the object to retrieve the connections for.</param>
		/// <param name="connectionName">the connection name.</param>
		/// <param name="queryParameters">query parameters to include in the request</param>
		/// <returns>a list of Java objects representing the Facebook objects in the connections.</returns>
		List<T> FetchConnections<T>(string objectId, string connectionName, NameValueCollection queryParameters) where T : class;
	
		/// <summary>
		/// Fetches an image as an array of bytes.
		/// </summary>
		/// <param name="objectId">the object ID</param>
		/// <param name="connectionName">the connection name</param>
		/// <param name="imageType">the type of image to retrieve (eg., small, normal, large, or square)</param>
		/// <returns>an image as an array of bytes.</returns>
		byte[] FetchImage(string objectId, string connectionName, ImageType imageType);

		/// <summary>
		/// Publishes data to an object's connection.
		/// Requires appropriate permission to publish to the object connection.
		/// </summary>
		/// <param name="objectId">the object ID to publish to.</param>
		/// <param name="connectionName">the connection name to publish to.</param>
		/// <param name="data">the data to publish to the connection.</param>
		/// <returns>the ID of the newly published object.</returns>
		String Publish(string objectId, string connectionName, NameValueCollection data);

		/// <summary>
		/// Publishes data to an object's connection. 
		/// Requires appropriate permission to publish to the object connection.
		/// This differs from publish() only in that it doesn't attempt to extract the ID from the response.
		/// This is because some publish operations do not return an ID in the response.
		/// </summary>
		/// <param name="objectId">the object ID to publish to.</param>
		/// <param name="connectionName">the connection name to publish to.</param>
		/// <param name="data">the data to publish to the connection.</param>
		void Post(string objectId, string connectionName, NameValueCollection data);
	
		/// <summary>
		/// Deletes an object.
		/// Requires appropriate permission to delete the object.
		/// </summary>
		/// <param name="objectId">/param> the object ID</param>param>
		void Delete(string objectId);
	
		/// <summary>
		/// Deletes an object connection.
		/// Requires appropriate permission to delete the object connection.
		/// </summary>
		/// <param name="objectId">the object ID</param>
		/// <param name="connectionName">the connection name</param>
		void Delete(string objectId, string connectionName);
	
		/// <summary>
		/// </summary>
		/// <returns>
		/// The application namespace associated with this GraphApi instance. Useful for interacting with Facebook's OpenGraph actions.
		/// May be null if no namespace was specified.
		/// </returns>
		string ApplicationNamespace();
	}
}
