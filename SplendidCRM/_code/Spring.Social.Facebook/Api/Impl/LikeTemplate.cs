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
	class LikeTemplate : AbstractFacebookOperations, ILikeOperations
	{
		private string[] PAGE_FIELDS = {"id", "name", "category", "description", "location", "website", "picture", "phone", "affiliation", "company_overview", "likes", "checkins"};

		public LikeTemplate(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized)
			: base(applicationNamespace, restTemplate, isAuthorized)
		{
		}

		#region ILikeOperations Members
		public void Like(string objectId)
		{
			requireAuthorization();
			this.Post(objectId, "likes", new NameValueCollection());
		}

		public void Unlike(string objectId)
		{
			requireAuthorization();
			this.Delete(objectId, "likes");
		}

		public List<Reference> GetLikes(string objectId)
		{
			requireAuthorization();
			return this.FetchConnections<Reference>(objectId, "likes");
		}
	
		public List<Page> GetPagesLiked()
		{
			return GetPagesLiked("me");
		}

		public List<Page> GetPagesLiked(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Page>(userId, "likes", PAGE_FIELDS);
		}
	
		public List<Page> GetBooks()
		{
			return GetBooks("me");
		}

		public List<Page> GetBooks(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Page>(userId, "books", PAGE_FIELDS);
		}

		public List<Page> GetMovies()
		{
			return GetMovies("me");
		}

		public List<Page> GetMovies(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Page>(userId, "movies", PAGE_FIELDS);
		}

		public List<Page> GetMusic()
		{
			return GetMusic("me");
		}

		public List<Page> GetMusic(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Page>(userId, "music", PAGE_FIELDS);
		}

		public List<Page> GetTelevision()
		{
			return GetTelevision("me");
		}

		public List<Page> GetTelevision(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Page>(userId, "television", PAGE_FIELDS);
		}

		public List<Page> GetActivities()
		{
			return GetActivities("me");
		}

		public List<Page> GetActivities(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Page>(userId, "activities", PAGE_FIELDS);
		}

		public List<Page> GetInterests()
		{
			return GetInterests("me");
		}

		public List<Page> GetInterests(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Page>(userId, "interests", PAGE_FIELDS);
		}

		public List<Page> GetGames()
		{
			return GetGames("me");
		}

		public List<Page> GetGames(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Page>(userId, "games", PAGE_FIELDS);
		}
		#endregion
	}
}