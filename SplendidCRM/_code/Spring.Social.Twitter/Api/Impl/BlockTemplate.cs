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
using System.Threading;
using System.Threading.Tasks;
#endif

using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.Twitter.Api.Impl
{
    /// <summary>
    /// Implementation of <see cref="IBlockOperations"/>, providing a binding to Twitter's block REST resources.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class BlockTemplate : AbstractTwitterOperations, IBlockOperations
    {
        private RestTemplate restTemplate;

        public BlockTemplate(RestTemplate restTemplate)
        {
            this.restTemplate = restTemplate;
        }

        #region IBlockOperations Members

#if NET_4_0 || SILVERLIGHT_5
        public Task<TwitterProfile> BlockAsync(long userId) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("user_id", userId.ToString());
		    return this.restTemplate.PostForObjectAsync<TwitterProfile>("blocks/create.json", request);
	    }

        public Task<TwitterProfile> BlockAsync(string screenName) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("screen_name", screenName);
		    return this.restTemplate.PostForObjectAsync<TwitterProfile>("blocks/create.json", request);
	    }

        public Task<TwitterProfile> UnblockAsync(long userId) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("user_id", userId.ToString());
		    return this.restTemplate.PostForObjectAsync<TwitterProfile>("blocks/destroy.json", request);
	    }

        public Task<TwitterProfile> UnblockAsync(String screenName) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("screen_name", screenName);
		    return this.restTemplate.PostForObjectAsync<TwitterProfile>("blocks/destroy.json", request);
	    }

        public Task<CursoredList<TwitterProfile>> GetBlockedUsersAsync() 
        {
		    return this.GetBlockedUsersAsync(-1);
	    }

        public Task<CursoredList<TwitterProfile>> GetBlockedUsersAsync(long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("skip_status", "true");
		    parameters.Add("cursor", cursor.ToString());
		    return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("blocks/list.json", parameters));
	    }

        public Task<CursoredList<long>> GetBlockedUserIdsAsync() 
        {
            return this.GetBlockedUserIdsAsync(-1);
	    }

        public Task<CursoredList<long>> GetBlockedUserIdsAsync(long cursor)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("blocks/ids.json", parameters));
        }
#else
#if !SILVERLIGHT
        public TwitterProfile Block(long userId) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("user_id", userId.ToString());
		    return this.restTemplate.PostForObject<TwitterProfile>("blocks/create.json", request);
	    }
	
	    public TwitterProfile Block(string screenName) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("screen_name", screenName);
		    return this.restTemplate.PostForObject<TwitterProfile>("blocks/create.json", request);
	    }
	
	    public TwitterProfile Unblock(long userId) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("user_id", userId.ToString());
		    return this.restTemplate.PostForObject<TwitterProfile>("blocks/destroy.json", request);
	    }
	
	    public TwitterProfile Unblock(String screenName) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("screen_name", screenName);
		    return this.restTemplate.PostForObject<TwitterProfile>("blocks/destroy.json", request);
	    }
	
	    public CursoredList<TwitterProfile> GetBlockedUsers() 
        {
		    return this.GetBlockedUsers(-1);
	    }
	
	    public CursoredList<TwitterProfile> GetBlockedUsers(long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("skip_status", "true");
		    parameters.Add("cursor", cursor.ToString());
		    return this.restTemplate.GetForObject<CursoredList<TwitterProfile>>(this.BuildUrl("blocks/list.json", parameters));
	    }

	    public CursoredList<long> GetBlockedUserIds() 
        {
		    return this.GetBlockedUserIds(-1);
	    }

        public CursoredList<long> GetBlockedUserIds(long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            return this.restTemplate.GetForObject<CursoredList<long>>(this.BuildUrl("blocks/ids.json", parameters));
	    }
#endif

        public RestOperationCanceler BlockAsync(long userId, Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("blocks/create.json", request, operationCompleted);
        }

        public RestOperationCanceler BlockAsync(string screenName, Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("blocks/create.json", request, operationCompleted);
        }

        public RestOperationCanceler UnblockAsync(long userId, Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("blocks/destroy.json", request, operationCompleted);
        }

        public RestOperationCanceler UnblockAsync(String screenName, Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("blocks/destroy.json", request, operationCompleted);
        }

        public RestOperationCanceler GetBlockedUsersAsync(Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            return this.GetBlockedUsersAsync(-1, operationCompleted);
        }

        public RestOperationCanceler GetBlockedUsersAsync(long cursor, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("skip_status", "true");
		    parameters.Add("cursor", cursor.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("blocks/list.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetBlockedUserIdsAsync(Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.GetBlockedUserIdsAsync(-1, operationCompleted);
        }

        public RestOperationCanceler GetBlockedUserIdsAsync(long cursor, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
		    parameters.Add("cursor", cursor.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("blocks/ids.json", parameters), operationCompleted);
        }
#endif

        #endregion
    }
}