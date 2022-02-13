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
using System.Text;
using System.Collections.Generic;
using System.Collections.Specialized;

using Spring.Json;
using Spring.Http;
using Spring.Rest.Client;
using Spring.Rest.Client.Support;

namespace Spring.Social.Salesforce.Api.Impl
{
	/// <summary>
	/// Base class for Salesforce operations.
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	abstract class AbstractSalesforceOperations : ISalesforceApi
	{
		private bool isAuthorized;
		protected RestTemplate restTemplate;

		public AbstractSalesforceOperations(RestTemplate restTemplate, bool isAuthorized) 
		{
			this.restTemplate = restTemplate;
			this.isAuthorized = isAuthorized;
		}

		protected void requireAuthorization()
		{
			EnsureIsAuthorized();
		}
		
		protected void EnsureIsAuthorized()
		{
			if ( !this.isAuthorized )
			{
				throw new SalesforceApiException("Authorization is required for the operation, but the API binding was created without authorization.", SalesforceApiError.NotAuthorized);
			}
		}

		protected string BuildUrl(string path)
		{
			NameValueCollection parameters = new NameValueCollection();
			return this.BuildUrl(path, parameters);
		}

		protected string BuildUrl(string path, string parameterName, string parameterValue)
		{
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add(parameterName, parameterValue);
			return this.BuildUrl(path, parameters);
		}

		protected string BuildUrl(string path, NameValueCollection parameters)
		{
			StringBuilder qsBuilder = new StringBuilder();
			bool isFirst = true;
			foreach ( string key in parameters )
			{
				if ( isFirst )
				{
					qsBuilder.Append('?');
					isFirst = false;
				}
				else
				{
					qsBuilder.Append('&');
				}
				qsBuilder.Append(HttpUtils.UrlEncode(key));
				qsBuilder.Append('=');
				qsBuilder.Append(HttpUtils.UrlEncode(parameters[key]));
			}
			return path + qsBuilder.ToString();
		}

		#region ISalesforceApi Methods
		public T FetchObject<T>(string objectId) where T : class
		{
			return this.restTemplate.GetForObject<T>(objectId);
		}
	
		public T FetchObject<T>(string objectId, NameValueCollection queryParameters) where T : class
		{
			return this.restTemplate.GetForObject<T>(this.BuildUrl(objectId, queryParameters));
		}

		public List<T> FetchConnections<T>(string objectId, string connectionType) where T : class
		{
			return FetchConnections<T>(objectId, connectionType, (string[]) null);
		}

		public List<T> FetchConnections<T>(string objectId, string connectionType, string[] fields) where T : class
		{
			NameValueCollection parameters = new NameValueCollection();
			if ( fields != null && fields.Length > 0)
			{
				string joinedFields = String.Join(",", fields);
				parameters.Add("fields", joinedFields);
			}
			return FetchConnections<T>(objectId, connectionType, parameters);
		}

		public List<T> FetchConnections<T>(string objectId, string connectionType, NameValueCollection queryParameters) where T : class
		{
			string connectionPath = connectionType != null && connectionType.Length > 0 ? "/" + connectionType : "";
			return this.restTemplate.GetForObject<List<T>>(this.BuildUrl(objectId + connectionPath, queryParameters));
		}

		public T Delete<T>(string objectId) where T : class
		{
			AcceptHeaderRequestCallback requestCallback = new AcceptHeaderRequestCallback(typeof(T), this.restTemplate.MessageConverters);
			MessageConverterResponseExtractor<T> responseExtractor = new MessageConverterResponseExtractor<T>(this.restTemplate.MessageConverters);
			return this.restTemplate.Execute<T>(objectId, HttpMethod.DELETE, requestCallback, responseExtractor);
		}
		#endregion
	}
}
