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
	class PageTemplate : AbstractFacebookOperations, IPageOperations
	{
		public PageTemplate(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized)
			: base(applicationNamespace, restTemplate, isAuthorized)
		{
		}

		#region IPageOperations Members
		public Page GetPage(string pageId)
		{
			return this.FetchObject<Page>(pageId);
		}

		public bool IsPageAdmin(string pageId)
		{
			requireAuthorization();
			return GetAccount(pageId) != null;
		}
	
		public List<Account> GetAccounts()
		{
			requireAuthorization();
			return this.FetchConnections<Account>("me", "accounts");
		}

		public string Post(string pageId, string message)
		{
			requireAuthorization();
			string pageAccessToken = GetPageAccessToken(pageId);
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("message"     , message        );
			parameters.Add("access_token", pageAccessToken);
			return this.Publish(pageId, "feed", parameters);
		}
	
		public string Post(string pageId, string message, FacebookLink link)
		{
			requireAuthorization();
			string pageAccessToken = GetPageAccessToken(pageId);
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("link"        , link.Link       );
			parameters.Add("name"        , link.Name       );
			parameters.Add("caption"     , link.Caption    );
			parameters.Add("description" , link.Description);
			parameters.Add("message"     , message         );
			parameters.Add("access_token", pageAccessToken );
			return this.Publish(pageId, "feed", parameters);
		}

		public string PostPhoto(string pageId, string albumId, Resource photo)
		{
			return PostPhoto(pageId, albumId, photo, null);
		}
	
		public string PostPhoto(string pageId, string albumId, Resource photo, string caption)
		{
			requireAuthorization();
			string pageAccessToken = GetPageAccessToken(pageId);
			Dictionary<string, object> parts = new Dictionary<string, object>();
			parts.Add("source", photo);
			if ( caption != null )
			{
				parts.Add("message", caption);
			}
			parts.Add("access_token", pageAccessToken);
			return this.Publish(albumId, "photos", parts);
		}
		#endregion

		#region Private Methods
		private Dictionary<string, Account> accountCache = new Dictionary<string, Account>();
	
		private string GetPageAccessToken(string pageId)
		{
			Account account = GetAccount(pageId);
			if ( account == null )
			{
				throw new Exception("PageAdministrationException " + pageId);  //PageAdministrationException(pageId);
			}
			return account.AccessToken;
		}
	
		private Account GetAccount(string pageId)
		{
			if ( !accountCache.ContainsKey(pageId) )
			{
				// only bother fetching the account data in the event of a cache miss
				List<Account> accounts = GetAccounts();
				foreach (Account account in accounts)
				{
					accountCache[account.ID] = account;
				}
				if ( !accountCache.ContainsKey(pageId) )
					return null;
			}
			return accountCache[pageId];
		}
		#endregion
	}
}