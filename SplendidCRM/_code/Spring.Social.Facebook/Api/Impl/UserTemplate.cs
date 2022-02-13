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
using System.Net;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

using Spring.Json;
using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.Facebook.Api.Impl
{
	/// <summary>
	/// Implementation of <see cref="IUserOperations"/>, providing binding to Facebooks' user-oriented REST resources.
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class UserTemplate : AbstractFacebookOperations, IUserOperations
	{
		public UserTemplate(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized)
			: base(applicationNamespace, restTemplate, isAuthorized)
		{
		}

		#region IUserOperations Members
		public FacebookProfile GetUserProfile()
		{
			requireAuthorization();
			return GetUserProfile("me");
		}

		public FacebookProfile GetUserProfile(string facebookId)
		{
			return this.FetchObject<FacebookProfile>(facebookId);
		}
	
		public byte[] GetUserProfileImage()
		{
			requireAuthorization();
			return GetUserProfileImage("me", ImageType.NORMAL);
		}
	
		public byte[] GetUserProfileImage(string userId)
		{
			return GetUserProfileImage(userId, ImageType.NORMAL);
		}

		public byte[] GetUserProfileImage(ImageType imageType)
		{
			requireAuthorization();
			return GetUserProfileImage("me", imageType);
		}
	
		public byte[] GetUserProfileImage(string userId, ImageType imageType)
		{
			return this.FetchImage(userId, "picture", imageType);
		}

		public List<string> GetUserPermissions()
		{
			requireAuthorization();
			JsonValue responseNode = this.restTemplate.GetForObject<JsonValue>("me/permissions");
			return DeserializePermissionsNodeToList(responseNode);
		}

		public List<Reference> Search(string query)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("q"   , query);
			parameters.Add("type", "user");
			return this.FetchConnections<Reference>("search", "", parameters);
			//return DeserializeDataList<Reference>(dataNode.GetValue("data"));
		}

		
		private List<string> DeserializePermissionsNodeToList(JsonValue jsonNode)
		{
			JsonValue dataNode = jsonNode.GetValue("data");
			List<string> permissions = new List<string>();
			foreach ( JsonValue elementIt in dataNode.GetValues() )
			{
				/*
				JsonValue permissionsElement = elementIt.next();
				foreach (string fieldNamesIt in permissionsElement.GetNames() )
				{
					permissions.add(fieldNamesIt.next());
				}
				*/
			}
			return permissions;
		}
		#endregion
	}
}