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
using System.Net;
using System.Collections.Generic;
#if SILVERLIGHT
using Spring.Collections.Specialized;
#else
using System.Collections.Specialized;
#endif
#if NET_4_0 || SILVERLIGHT_5
using System.Threading.Tasks;
#endif

using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.Twitter.Api.Impl
{
    /// <summary>
    /// Implementation of <see cref="IUserOperations"/>, providing binding to Twitters' user-oriented REST resources.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class UserTemplate : AbstractTwitterOperations, IUserOperations
    {
        private RestTemplate restTemplate;

        public UserTemplate(RestTemplate restTemplate)
        {
            this.restTemplate = restTemplate;
        }

        #region IUserOperations Members

#if NET_4_0 || SILVERLIGHT_5
        public Task<TwitterProfile> GetUserProfileAsync() 
        {
		    return this.restTemplate.GetForObjectAsync<TwitterProfile>("account/verify_credentials.json");
	    }

        public Task<TwitterProfile> GetUserProfileAsync(string screenName) 
        {
            return this.restTemplate.GetForObjectAsync<TwitterProfile>(this.BuildUrl("users/show.json", "screen_name", screenName));
	    }

        public Task<TwitterProfile> GetUserProfileAsync(long userId) 
        {
            return this.restTemplate.GetForObjectAsync<TwitterProfile>(this.BuildUrl("users/show.json", "user_id", userId.ToString()));
	    }

        public Task<IList<TwitterProfile>> GetUsersAsync(params long[] userIds) 
        {
		    string joinedIds = ArrayUtils.Join(userIds);
		    return this.restTemplate.GetForObjectAsync<IList<TwitterProfile>>(this.BuildUrl("users/lookup.json", "user_id", joinedIds));
	    }

        public Task<IList<TwitterProfile>> GetUsersAsync(params string[] screenNames) 
        {
		    string joinedScreenNames = ArrayUtils.Join(screenNames);
		    return this.restTemplate.GetForObjectAsync<IList<TwitterProfile>>(this.BuildUrl("users/lookup.json", "screen_name", joinedScreenNames));
	    }

        public Task<IList<TwitterProfile>> SearchForUsersAsync(string query) 
        {
		    return this.SearchForUsersAsync(query, 1, 20);
	    }

        public Task<IList<TwitterProfile>> SearchForUsersAsync(string query, int page, int pageSize) 
        {
		    NameValueCollection parameters = PagingUtils.BuildPagingParametersWithPerPage(page, pageSize, 0, 0);
		    parameters.Add("q", query);
		    return this.restTemplate.GetForObjectAsync<IList<TwitterProfile>>(this.BuildUrl("users/search.json", parameters));
	    }

        public Task<IList<SuggestionCategory>> GetSuggestionCategoriesAsync() 
        {
		    return this.restTemplate.GetForObjectAsync<IList<SuggestionCategory>>("users/suggestions.json");
	    }

        public Task<IList<TwitterProfile>> GetSuggestionsAsync(String slug) 
        {
		    return this.restTemplate.GetForObjectAsync<IList<TwitterProfile>>("users/suggestions/{slug}.json", slug);
	    }

        public Task<IList<RateLimitStatus>> GetRateLimitStatusAsync(params string[] resources) 
        {
            NameValueCollection parameters = new NameValueCollection();
            if (resources.Length > 0)
            {
                parameters.Add("resources", ArrayUtils.Join(resources));
            }
            return this.restTemplate.GetForObjectAsync<IList<RateLimitStatus>>(this.BuildUrl("application/rate_limit_status.json", parameters));
	    }
#else
#if !SILVERLIGHT
	    public TwitterProfile GetUserProfile() 
        {
		    return this.restTemplate.GetForObject<TwitterProfile>("account/verify_credentials.json");
	    }

	    public TwitterProfile GetUserProfile(string screenName) 
        {
		    return this.restTemplate.GetForObject<TwitterProfile>(this.BuildUrl("users/show.json", "screen_name", screenName));
	    }
	
	    public TwitterProfile GetUserProfile(long userId) 
        {
		    return this.restTemplate.GetForObject<TwitterProfile>(this.BuildUrl("users/show.json", "user_id", userId.ToString()));
	    }

	    public IList<TwitterProfile> GetUsers(params long[] userIds) 
        {
		    string joinedIds = ArrayUtils.Join(userIds);
		    return this.restTemplate.GetForObject<IList<TwitterProfile>>(this.BuildUrl("users/lookup.json", "user_id", joinedIds));
	    }

	    public IList<TwitterProfile> GetUsers(params string[] screenNames) 
        {
		    string joinedScreenNames = ArrayUtils.Join(screenNames);
		    return this.restTemplate.GetForObject<IList<TwitterProfile>>(this.BuildUrl("users/lookup.json", "screen_name", joinedScreenNames));
	    }

	    public IList<TwitterProfile> SearchForUsers(string query) 
        {
		    return this.SearchForUsers(query, 1, 20);
	    }

	    public IList<TwitterProfile> SearchForUsers(string query, int page, int pageSize) 
        {
		    NameValueCollection parameters = PagingUtils.BuildPagingParametersWithPerPage(page, pageSize, 0, 0);
		    parameters.Add("q", query);
		    return this.restTemplate.GetForObject<IList<TwitterProfile>>(this.BuildUrl("users/search.json", parameters));
	    }

	    public IList<SuggestionCategory> GetSuggestionCategories() 
        {
		    return this.restTemplate.GetForObject<IList<SuggestionCategory>>("users/suggestions.json");
	    }

	    public IList<TwitterProfile> GetSuggestions(String slug) 
        {
		    return this.restTemplate.GetForObject<IList<TwitterProfile>>("users/suggestions/{slug}.json", slug);
	    }

	    public IList<RateLimitStatus> GetRateLimitStatus(params string[] resources) 
        {
		    NameValueCollection parameters = new NameValueCollection();
            if (resources.Length > 0)
            {
                parameters.Add("resources", ArrayUtils.Join(resources));
            }
            return this.restTemplate.GetForObject<IList<RateLimitStatus>>(this.BuildUrl("application/rate_limit_status.json", parameters));
	    }
#endif

        public RestOperationCanceler GetUserProfileAsync(Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<TwitterProfile>("account/verify_credentials.json", operationCompleted);
        }

        public RestOperationCanceler GetUserProfileAsync(string screenName, Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<TwitterProfile>(this.BuildUrl("users/show.json", "screen_name", screenName), operationCompleted);
        }

        public RestOperationCanceler GetUserProfileAsync(long userId, Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<TwitterProfile>(this.BuildUrl("users/show.json", "user_id", userId.ToString()), operationCompleted);
        }

        public RestOperationCanceler GetUsersAsync(long[] userIds, Action<RestOperationCompletedEventArgs<IList<TwitterProfile>>> operationCompleted)
        {
            string joinedIds = ArrayUtils.Join(userIds);
            return this.restTemplate.GetForObjectAsync<IList<TwitterProfile>>(this.BuildUrl("users/lookup.json", "user_id", joinedIds), operationCompleted);
        }

        public RestOperationCanceler GetUsersAsync(string[] screenNames, Action<RestOperationCompletedEventArgs<IList<TwitterProfile>>> operationCompleted)
        {
            string joinedScreenNames = ArrayUtils.Join(screenNames);
            return this.restTemplate.GetForObjectAsync<IList<TwitterProfile>>(this.BuildUrl("users/lookup.json", "screen_name", joinedScreenNames), operationCompleted);
        }

        public RestOperationCanceler SearchForUsersAsync(string query, Action<RestOperationCompletedEventArgs<IList<TwitterProfile>>> operationCompleted)
        {
            return this.SearchForUsersAsync(query, 1, 20, operationCompleted);
        }

        public RestOperationCanceler SearchForUsersAsync(string query, int page, int pageSize, Action<RestOperationCompletedEventArgs<IList<TwitterProfile>>> operationCompleted)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithPerPage(page, pageSize, 0, 0);
            parameters.Add("q", query);
            return this.restTemplate.GetForObjectAsync<IList<TwitterProfile>>(this.BuildUrl("users/search.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetSuggestionCategoriesAsync(Action<RestOperationCompletedEventArgs<IList<SuggestionCategory>>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<IList<SuggestionCategory>>("users/suggestions.json", operationCompleted);
        }

        public RestOperationCanceler GetSuggestionsAsync(String slug, Action<RestOperationCompletedEventArgs<IList<TwitterProfile>>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<IList<TwitterProfile>>("users/suggestions/{slug}.json", operationCompleted, slug);
        }

        public RestOperationCanceler GetRateLimitStatusAsync(string[] resources, Action<RestOperationCompletedEventArgs<IList<RateLimitStatus>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            if (resources.Length > 0)
            {
                parameters.Add("resources", ArrayUtils.Join(resources));
            }
            return this.restTemplate.GetForObjectAsync<IList<RateLimitStatus>>(this.BuildUrl("application/rate_limit_status.json", parameters), operationCompleted);
        }
#endif

        #endregion
    }
}