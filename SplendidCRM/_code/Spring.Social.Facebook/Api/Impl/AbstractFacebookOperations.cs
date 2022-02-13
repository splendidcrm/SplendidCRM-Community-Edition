#region License

/*
 * Copyright 2011-2012 the original author or authors.
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

namespace Spring.Social.Facebook.Api.Impl
{
	/// <summary>
	/// Base class for Facebook operations.
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	abstract class AbstractFacebookOperations : IGraphApi
	{
		//private static String GRAPH_API_URL = "https://graph.facebook.com/";
		private bool isAuthorized;
		protected RestTemplate restTemplate;
		protected string applicationNamespace;

		public AbstractFacebookOperations(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized) 
		{
			this.applicationNamespace = applicationNamespace;
			this.restTemplate = restTemplate;
			this.isAuthorized = isAuthorized;
		}

		public string ApplicationNamespace()
		{
			return applicationNamespace;
		}

		protected void requireAuthorization()
		{
			EnsureIsAuthorized();
		}
		
		protected void EnsureIsAuthorized()
		{
			if ( !this.isAuthorized )
			{
				throw new FacebookApiException("Authorization is required for the operation, but the API binding was created without authorization.", FacebookApiError.NotAuthorized);
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

		#region IGraphApi Methods
		public T FetchObject<T>(String objectId) where T : class
		{
			return this.restTemplate.GetForObject<T>(objectId);
		}
	
		public T FetchObject<T>(String objectId, NameValueCollection queryParameters) where T : class
		{
			return this.restTemplate.GetForObject<T>(this.BuildUrl(objectId, queryParameters));
		}

		public List<T> FetchConnections<T>(String objectId, String connectionType) where T : class
		{
			return FetchConnections<T>(objectId, connectionType, (string[]) null);
		}

		public List<T> FetchConnections<T>(String objectId, String connectionType, String[] fields) where T : class
		{
			NameValueCollection parameters = new NameValueCollection();
			if ( fields != null && fields.Length > 0)
			{
				String joinedFields = String.Join(",", fields);
				parameters.Add("fields", joinedFields);
			}
			return FetchConnections<T>(objectId, connectionType, parameters);
		}

		public List<T> FetchConnections<T>(String objectId, String connectionType, NameValueCollection queryParameters) where T : class
		{
			String connectionPath = connectionType != null && connectionType.Length > 0 ? "/" + connectionType : "";
			return restTemplate.GetForObject<List<T>>(this.BuildUrl(objectId + connectionPath, queryParameters));
		}

		public byte[] FetchImage(String objectId, String connectionType, ImageType type)
		{
			return restTemplate.GetForObject<byte[]>(objectId + "/" + connectionType + "?type=" + type.ToString().ToLower());
		}
	
		public String Publish(String objectId, String connectionType, Dictionary<string, object> data)
		{
			JsonValue response = restTemplate.PostForObject<JsonValue>(objectId + "/" + connectionType, data);
			return response.GetValue<string>("id");
		}
	
		public String Publish(String objectId, String connectionType, NameValueCollection data)
		{
			JsonValue response = restTemplate.PostForObject<JsonValue>(objectId + "/" + connectionType, data);
			return response.GetValue<string>("id");
		}
	
		public void Post(String objectId, String connectionType, NameValueCollection data)
		{
			restTemplate.PostForObject<string>(objectId + "/" + connectionType, data);
		}
	
		public void Delete(String objectId)
		{
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("method", "delete");
			restTemplate.PostForObject<string>(objectId, parameters);
		}
	
		public void Delete(String objectId, String connectionType)
		{
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("method", "delete");
			restTemplate.PostForObject<string>(objectId + "/" + connectionType, parameters);
		}
		#endregion

		#region Private Methods
		protected T FetchConnectionList<T>(string baseUri, int offset, int limit) where T : class
		{
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("offset", offset.ToString());
			parameters.Add("limit" , limit .ToString());
			return restTemplate.GetForObject<T>(this.BuildUrl(baseUri, parameters));
		}

		/*
		protected T DeserializePost<T>(string postType, JsonValue node)
		{
			try
			{
				if ( postType == null )
				{
					postType = DeterminePostType(node);
				}
				// Must have separate postType field for polymorphic deserialization. If we key off of the "type" field, then it will
				// be null when trying to deserialize the type property.
				node.Put("postType", postType); // used for polymorphic deserialization
				node.Put("type"    , postType); // used to set Post's type property
				return objectMapper.readValue<T>(node);
			}
			catch (Exception shouldntHappen)
			{
				// Uncategorized
				throw new  FacebookApiException("Error deserializing " + postType + " post", shouldntHappen);
			}
		}

		protected string DeterminePostType(JsonValue node)
		{
			if ( node != null && node.ContainsName("type") )
			{
				try
				{
					string type = node.GetValue<string>("type");
					Enum.Parse(typeof(Post.enumPostType), type);
					return type;
				}
				catch //(IllegalArgumentException e)
				{
					return "post";
				}
			}
			return "post";
		}
		*/
		#endregion
	}
}
