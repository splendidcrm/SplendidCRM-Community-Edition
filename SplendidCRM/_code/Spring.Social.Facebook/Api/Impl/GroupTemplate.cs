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
using System.Collections.Generic;
using System.Collections.Specialized;

using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.Facebook.Api.Impl
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class GroupTemplate : AbstractFacebookOperations, IGroupOperations
	{
		private string[] FULL_PROFILE_FIELDS = {"id", "username", "name", "first_name", "last_name", "gender", "locale", "education", "work", "email", "third_party_id", "link", "timezone", "updated_time", "verified", "about", "bio", "birthday", "location", "hometown", "interested_in", "religion", "political", "quotes", "relationship_status", "significant_other", "website"};

		public GroupTemplate(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized)
			: base(applicationNamespace, restTemplate, isAuthorized)
		{
		}

		#region IGroupOperations Members
		public Group GetGroup(string groupId)
		{
			return this.FetchObject<Group>(groupId);
		}
	
		public byte[] GetGroupImage(string groupId)
		{
			return GetGroupImage(groupId, ImageType.NORMAL);
		}
	
		public byte[] GetGroupImage(string groupId, ImageType imageType)
		{
			return this.FetchImage(groupId, "picture", imageType);
		}
	
		public List<GroupMemberReference> GetMembers(string groupId)
		{
			requireAuthorization();
			return this.FetchConnections<GroupMemberReference>(groupId, "members");
		}

		public List<FacebookProfile> GetMemberProfiles(string groupId)
		{
			requireAuthorization();
			return this.FetchConnections<FacebookProfile>(groupId, "members", FULL_PROFILE_FIELDS);
		}
	
		public List<GroupMembership> GetMemberships()
		{
			return GetMemberships("me");
		}
	
		public List<GroupMembership> GetMemberships(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<GroupMembership>(userId, "groups");
		}

		public List<Group> Search(string query)
		{
			return Search(query, 0, 25);
		}
	
		public List<Group> Search(string query, int offset, int limit)
		{
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("q"     , query            );
			parameters.Add("type"  , "group"          );
			parameters.Add("fields", "owner,name,description,privacy,icon,updated_time,email,version");
			parameters.Add("offset", offset.ToString());
			parameters.Add("limit" , limit .ToString());
			return this.FetchConnections<Group>("search", "", parameters);
		}	
		#endregion
	}
}