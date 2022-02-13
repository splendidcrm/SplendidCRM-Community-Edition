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

using Spring.Json;
using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.Facebook.Api.Impl
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class FriendTemplate : AbstractFacebookOperations, IFriendOperations
	{
		private string FULL_PROFILE_FIELDS = "id,username,name,first_name,last_name,gender,locale,education,work,email,third_party_id,link,timezone,updated_time,verified,about,bio,birthday,location,hometown,interested_in,religion,political,quotes,relationship_status,significant_other,website";

		public FriendTemplate(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized)
			: base(applicationNamespace, restTemplate, isAuthorized)
		{
		}

		#region IFriendOperations Members
		public List<Reference> GetFriendLists()
		{
			return GetFriendLists("me");
		}

		public List<Reference> GetFriendLists(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Reference>(userId, "friendlists");
		}
	
		public Reference GetFriendList(string friendListId)
		{
			requireAuthorization();
			return this.FetchObject<Reference>(friendListId);
		}
	
		public List<Reference> GetFriendListMembers(string friendListId)
		{
			requireAuthorization();
			return this.FetchConnections<Reference>(friendListId, "members");
		}

		public string CreateFriendList(string name)
		{
			return CreateFriendList("me", name);
		}
	
		public string CreateFriendList(string userId, string name)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("name", name);
			return this.Publish(userId, "friendlists", parameters);
		}
	
		public void DeleteFriendList(string friendListId)
		{
			requireAuthorization();
			this.Delete(friendListId);
		}

		public void AddToFriendList(string friendListId, string friendId)
		{
			requireAuthorization();
			this.Post(friendListId, "members/" + friendId, new NameValueCollection());
		}
	
		public void RemoveFromFriendList(string friendListId, string friendId)
		{
			requireAuthorization();
			restTemplate.Delete(friendListId + "/members/" + friendId);
		}
	
		public List<Reference> GetFriends()
		{
			return GetFriends("me");
		}
	
		public List<string> GetFriendIds()
		{
			return GetFriendIds("me");
		}
	
		public List<FacebookProfile> GetFriendProfiles()
		{
			return GetFriendProfiles("me", 0, 100);
		}

		public List<FacebookProfile> GetFriendProfiles(int offset, int limit)
		{
			return GetFriendProfiles("me", offset, limit);
		}
	
		public List<Reference> GetFriends(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Reference>(userId, "friends");
		}
	
		public List<string> GetFriendIds(string userId)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("fields", "id");
			JsonValue response = restTemplate.GetForObject<JsonValue>(this.BuildUrl(userId + "/friends", parameters));
			
			List<string> idList = new List<string>();
			if ( response != null && !response.IsNull )
			{
				JsonValue entryList = response.GetValue("data");
				if ( entryList != null && !entryList.IsNull )
				{
					foreach ( JsonValue entry in entryList.GetValues() )
					{
						idList.Add(entry.GetValue<string>("id"));
					}
				}
			}
			return idList;
		}
	
		public List<FacebookProfile> GetFriendProfiles(string userId)
		{
			return GetFriendProfiles(userId, 0, 100);
		}

		public List<FacebookProfile> GetFriendProfiles(string userId, int offset, int limit)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("offset", offset.ToString()  );
			parameters.Add("limit" , limit .ToString()  );
			parameters.Add("fields", FULL_PROFILE_FIELDS);
			return this.FetchConnections<FacebookProfile>(userId, "friends", parameters);
		}

		public List<FamilyMember> GetFamily()
		{
			requireAuthorization();
			return this.FetchConnections<FamilyMember>("me", "family");
		}

		public List<FamilyMember> GetFamily(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<FamilyMember>(userId, "family");
		}

		public List<Reference> GetMutualFriends(string userId)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("user", userId);
			return this.FetchConnections<Reference>("me", "mutualfriends", parameters);
		}
	
		public List<Reference> GetSubscribedTo()
		{
			return GetSubscribedTo("me");
		}
	
		public List<Reference> GetSubscribedTo(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Reference>(userId, "subscribedTo");
		}
	
		public List<Reference> GetSubscribers()
		{
			return GetSubscribers("me");
		}
	
		public List<Reference> GetSubscribers(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Reference>(userId, "subscribers");
		}
		#endregion
	}
}