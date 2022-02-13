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
#if SILVERLIGHT
using Spring.Collections.Specialized;
#else
using System.Collections.Specialized;
#endif
#if NET_4_0 || SILVERLIGHT_5
using System.Threading.Tasks;
#else
using Spring.Http;
#endif

using Spring.Rest.Client;

namespace Spring.Social.Twitter.Api.Impl
{
    /// <summary>
    /// Implementation of <see cref="ISearchOperations"/>, providing a binding to Twitter's search and trend-oriented REST resources.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class SearchTemplate : AbstractTwitterOperations, ISearchOperations
    {
        private RestTemplate restTemplate;

        public SearchTemplate(RestTemplate restTemplate)
        {
            this.restTemplate = restTemplate;
        }

        #region ISearchOperations Members

#if NET_4_0 || SILVERLIGHT_5
        public Task<SearchResults> SearchAsync(string query) 
        {
            return this.SearchAsync(query, 0, 0, 0);
	    }

        public Task<SearchResults> SearchAsync(string query, int count) 
        {
            return this.SearchAsync(query, count, 0, 0);
	    }

        public Task<SearchResults> SearchAsync(string query, int count, long sinceId, long maxId) 
        {
            NameValueCollection parameters = BuildSearchParameters(query, count, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<SearchResults>(this.BuildUrl("search/tweets.json", parameters));
	    }

        public Task<IList<SavedSearch>> GetSavedSearchesAsync() 
        {
            return this.restTemplate.GetForObjectAsync<IList<SavedSearch>>("saved_searches/list.json");
	    }

        public Task<SavedSearch> GetSavedSearchAsync(long searchId) 
        {
            return this.restTemplate.GetForObjectAsync<SavedSearch>("saved_searches/show/{searchId}.json", searchId);
	    }

        public Task<SavedSearch> CreateSavedSearchAsync(string query) 
        {		
		    NameValueCollection request = new NameValueCollection();
		    request.Add("query", query);
            return this.restTemplate.PostForObjectAsync<SavedSearch>("saved_searches/create.json", request);
	    }

        public Task<SavedSearch> DeleteSavedSearchAsync(long searchId) 
        {
            NameValueCollection request = new NameValueCollection();
            return this.restTemplate.PostForObjectAsync<SavedSearch>("saved_searches/destroy/{searchId}.json", request, searchId);
	    }

        public Task<Trends> GetTrendsAsync(long whereOnEarthId) 
        {
            return this.GetTrendsAsync(whereOnEarthId, false);
	    }

        public Task<Trends> GetTrendsAsync(long whereOnEarthId, bool excludeHashtags)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("id", whereOnEarthId.ToString());
            if (excludeHashtags)
            {
                parameters.Add("exclude", "hashtags");
            }
            return this.restTemplate.GetForObjectAsync<Trends>(this.BuildUrl("trends/place.json", parameters));
        }
#else
#if !SILVERLIGHT
        public SearchResults Search(string query) 
        {
		    return this.Search(query, 0, 0, 0);
	    }

	    public SearchResults Search(string query, int count) 
        {
		    return this.Search(query, count, 0, 0);
	    }

	    public SearchResults Search(string query, int count, long sinceId, long maxId) 
        {
            NameValueCollection parameters = BuildSearchParameters(query, count, sinceId, maxId);
            return this.restTemplate.GetForObject<SearchResults>(this.BuildUrl("search/tweets.json", parameters));
	    }

	    public IList<SavedSearch> GetSavedSearches() 
        {
            return this.restTemplate.GetForObject<IList<SavedSearch>>("saved_searches/list.json");
	    }

	    public SavedSearch GetSavedSearch(long searchId) 
        {
            return this.restTemplate.GetForObject<SavedSearch>("saved_searches/show/{searchId}.json", searchId);
	    }

	    public SavedSearch CreateSavedSearch(string query) 
        {		
		    NameValueCollection request = new NameValueCollection();
		    request.Add("query", query);
            return this.restTemplate.PostForObject<SavedSearch>("saved_searches/create.json", request);
	    }

	    public SavedSearch DeleteSavedSearch(long searchId) 
        {
            NameValueCollection request = new NameValueCollection();
            return this.restTemplate.PostForObject<SavedSearch>("saved_searches/destroy/{searchId}.json", request, searchId);
	    }

	    public Trends GetTrends(long whereOnEarthId) 
        {
		    return this.GetTrends(whereOnEarthId, false);
	    }

	    public Trends GetTrends(long whereOnEarthId, bool excludeHashtags) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("id", whereOnEarthId.ToString());
            if (excludeHashtags)
            {
                parameters.Add("exclude", "hashtags");
            }
            return this.restTemplate.GetForObject<Trends>(this.BuildUrl("trends/place.json", parameters));
	    }
#endif

        public RestOperationCanceler SearchAsync(string query, Action<RestOperationCompletedEventArgs<SearchResults>> operationCompleted)
        {
            return this.SearchAsync(query, 0, 0, 0, operationCompleted);
        }

        public RestOperationCanceler SearchAsync(string query, int count, Action<RestOperationCompletedEventArgs<SearchResults>> operationCompleted)
        {
            return this.SearchAsync(query, count, 0, 0, operationCompleted);
        }

        public RestOperationCanceler SearchAsync(string query, int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<SearchResults>> operationCompleted)
        {
            NameValueCollection parameters = BuildSearchParameters(query, count, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<SearchResults>(this.BuildUrl("search/tweets.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetSavedSearchesAsync(Action<RestOperationCompletedEventArgs<IList<SavedSearch>>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<IList<SavedSearch>>("saved_searches/list.json", operationCompleted);
        }

        public RestOperationCanceler GetSavedSearchAsync(long searchId, Action<RestOperationCompletedEventArgs<SavedSearch>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<SavedSearch>("saved_searches/show/{searchId}.json", operationCompleted, searchId);
        }

        public RestOperationCanceler CreateSavedSearchAsync(string query, Action<RestOperationCompletedEventArgs<SavedSearch>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("query", query);
            return this.restTemplate.PostForObjectAsync<SavedSearch>("saved_searches/create.json", request, operationCompleted);
        }

        public RestOperationCanceler DeleteSavedSearchAsync(long searchId, Action<RestOperationCompletedEventArgs<SavedSearch>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            return this.restTemplate.PostForObjectAsync<SavedSearch>("saved_searches/destroy/{searchId}.json", request, operationCompleted, searchId);
        }

        public RestOperationCanceler GetTrendsAsync(long whereOnEarthId, Action<RestOperationCompletedEventArgs<Trends>> operationCompleted)
        {
            return this.GetTrendsAsync(whereOnEarthId, false, operationCompleted);
        }

        public RestOperationCanceler GetTrendsAsync(long whereOnEarthId, bool excludeHashtags, Action<RestOperationCompletedEventArgs<Trends>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("id", whereOnEarthId.ToString());
            if (excludeHashtags)
            {
                parameters.Add("exclude", "hashtags");
            }
            return this.restTemplate.GetForObjectAsync<Trends>(this.BuildUrl("trends/place.json", parameters), operationCompleted);
        }
#endif

        #endregion

        #region Private Methods

        private static NameValueCollection BuildSearchParameters(string query, int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("q", query);
            if (count > 0)
            {
                parameters.Add("count", count.ToString());
            }
            if (sinceId > 0)
            {
                parameters.Add("since_id", sinceId.ToString());
            }
            if (maxId > 0)
            {
                parameters.Add("max_id", maxId.ToString());
            }
            return parameters;
        }

        #endregion
    }
}