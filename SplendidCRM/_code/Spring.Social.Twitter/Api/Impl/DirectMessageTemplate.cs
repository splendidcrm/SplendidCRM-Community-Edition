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
#endif

using Spring.Rest.Client;

namespace Spring.Social.Twitter.Api.Impl
{
    /// <summary>
    /// Implementation of <see cref="IDirectMessageOperations"/>, providing a binding to Twitter's direct message-oriented REST resources.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class DirectMessageTemplate : AbstractTwitterOperations, IDirectMessageOperations
    {
        private RestTemplate restTemplate;

        public DirectMessageTemplate(RestTemplate restTemplate)
        {
            this.restTemplate = restTemplate;
        }

        #region IDirectMessageOperations Members

#if NET_4_0 || SILVERLIGHT_5
        public Task<IList<DirectMessage>> GetDirectMessagesReceivedAsync() 
        {
            return this.GetDirectMessagesReceivedAsync(1, 20, 0, 0);
	    }

        public Task<IList<DirectMessage>> GetDirectMessagesReceivedAsync(int page, int pageSize) 
        {
            return this.GetDirectMessagesReceivedAsync(page, pageSize, 0, 0);
	    }

        public Task<IList<DirectMessage>> GetDirectMessagesReceivedAsync(int page, int pageSize, long sinceId, long maxId) 
        {
		    NameValueCollection parameters = PagingUtils.BuildPagingParametersWithPageCount(page, pageSize, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<DirectMessage>>(this.BuildUrl("direct_messages.json", parameters));
	    }

        public Task<IList<DirectMessage>> GetDirectMessagesSentAsync() 
        {
            return this.GetDirectMessagesSentAsync(1, 20, 0, 0);
	    }

        public Task<IList<DirectMessage>> GetDirectMessagesSentAsync(int page, int pageSize) 
        {
            return this.GetDirectMessagesSentAsync(page, pageSize, 0, 0);
	    }

        public Task<IList<DirectMessage>> GetDirectMessagesSentAsync(int page, int pageSize, long sinceId, long maxId) 
        {
		    NameValueCollection parameters = PagingUtils.BuildPagingParametersWithPageCount(page, pageSize, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<DirectMessage>>(this.BuildUrl("direct_messages/sent.json", parameters));
	    }

        public Task<DirectMessage> GetDirectMessageAsync(long id) 
        {
            return this.restTemplate.GetForObjectAsync<DirectMessage>(this.BuildUrl("direct_messages/show.json", "id", id.ToString()));
	    }

        public Task<DirectMessage> SendDirectMessageAsync(string toScreenName, string text) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("screen_name", toScreenName);
		    request.Add("text", text);
            return this.restTemplate.PostForObjectAsync<DirectMessage>("direct_messages/new.json", request);
	    }

        public Task<DirectMessage> SendDirectMessageAsync(long toUserId, string text) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("user_id", toUserId.ToString());
		    request.Add("text", text);
            return this.restTemplate.PostForObjectAsync<DirectMessage>("direct_messages/new.json", request);
	    }

        public Task<DirectMessage> DeleteDirectMessageAsync(long messageId) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("id", messageId.ToString());
            return this.restTemplate.PostForObjectAsync<DirectMessage>("direct_messages/destroy.json", request);
	    }
#else
#if !SILVERLIGHT
        public IList<DirectMessage> GetDirectMessagesReceived() 
        {
		    return this.GetDirectMessagesReceived(1, 20, 0, 0);
	    }

	    public IList<DirectMessage> GetDirectMessagesReceived(int page, int pageSize) 
        {
		    return this.GetDirectMessagesReceived(page, pageSize, 0, 0);
	    }

	    public IList<DirectMessage> GetDirectMessagesReceived(int page, int pageSize, long sinceId, long maxId) 
        {
		    NameValueCollection parameters = PagingUtils.BuildPagingParametersWithPageCount(page, pageSize, sinceId, maxId);
		    return this.restTemplate.GetForObject<IList<DirectMessage>>(this.BuildUrl("direct_messages.json", parameters));
	    }

	    public IList<DirectMessage> GetDirectMessagesSent() 
        {
		    return this.GetDirectMessagesSent(1, 20, 0, 0);
	    }

	    public IList<DirectMessage> GetDirectMessagesSent(int page, int pageSize) 
        {
		    return this.GetDirectMessagesSent(page, pageSize, 0, 0);
	    }

	    public IList<DirectMessage> GetDirectMessagesSent(int page, int pageSize, long sinceId, long maxId) 
        {
		    NameValueCollection parameters = PagingUtils.BuildPagingParametersWithPageCount(page, pageSize, sinceId, maxId);
		    return this.restTemplate.GetForObject<IList<DirectMessage>>(this.BuildUrl("direct_messages/sent.json", parameters));
	    }
	
	    public DirectMessage GetDirectMessage(long id) 
        {
            return this.restTemplate.GetForObject<DirectMessage>(this.BuildUrl("direct_messages/show.json", "id", id.ToString()));
	    }

	    public DirectMessage SendDirectMessage(string toScreenName, string text) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("screen_name", toScreenName);
		    request.Add("text", text);
		    return this.restTemplate.PostForObject<DirectMessage>("direct_messages/new.json", request);
	    }

	    public DirectMessage SendDirectMessage(long toUserId, String text) 
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("user_id", toUserId.ToString());
		    request.Add("text", text);
		    return this.restTemplate.PostForObject<DirectMessage>("direct_messages/new.json", request);
	    }

	    public DirectMessage DeleteDirectMessage(long messageId) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("id", messageId.ToString());
            return this.restTemplate.PostForObject<DirectMessage>("direct_messages/destroy.json", request);
	    }
#endif

        public RestOperationCanceler GetDirectMessagesReceivedAsync(Action<RestOperationCompletedEventArgs<IList<DirectMessage>>> operationCompleted)
        {
            return this.GetDirectMessagesReceivedAsync(1, 20, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetDirectMessagesReceivedAsync(int page, int pageSize, Action<RestOperationCompletedEventArgs<IList<DirectMessage>>> operationCompleted)
        {
            return this.GetDirectMessagesReceivedAsync(page, pageSize, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetDirectMessagesReceivedAsync(int page, int pageSize, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<DirectMessage>>> operationCompleted)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithPageCount(page, pageSize, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<DirectMessage>>(this.BuildUrl("direct_messages.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetDirectMessagesSentAsync(Action<RestOperationCompletedEventArgs<IList<DirectMessage>>> operationCompleted)
        {
            return this.GetDirectMessagesSentAsync(1, 20, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetDirectMessagesSentAsync(int page, int pageSize, Action<RestOperationCompletedEventArgs<IList<DirectMessage>>> operationCompleted)
        {
            return this.GetDirectMessagesSentAsync(page, pageSize, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetDirectMessagesSentAsync(int page, int pageSize, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<DirectMessage>>> operationCompleted)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithPageCount(page, pageSize, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<DirectMessage>>(this.BuildUrl("direct_messages/sent.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetDirectMessageAsync(long id, Action<RestOperationCompletedEventArgs<DirectMessage>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<DirectMessage>(this.BuildUrl("direct_messages/show.json", "id", id.ToString()), operationCompleted);
        }

        public RestOperationCanceler SendDirectMessageAsync(string toScreenName, string text, Action<RestOperationCompletedEventArgs<DirectMessage>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", toScreenName);
            request.Add("text", text);
            return this.restTemplate.PostForObjectAsync<DirectMessage>("direct_messages/new.json", request, operationCompleted);
        }

        public RestOperationCanceler SendDirectMessageAsync(long toUserId, string text, Action<RestOperationCompletedEventArgs<DirectMessage>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", toUserId.ToString());
            request.Add("text", text);
            return this.restTemplate.PostForObjectAsync<DirectMessage>("direct_messages/new.json", request, operationCompleted);
        }

        public RestOperationCanceler DeleteDirectMessageAsync(long messageId, Action<RestOperationCompletedEventArgs<DirectMessage>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("id", messageId.ToString());
            return this.restTemplate.PostForObjectAsync<DirectMessage>("direct_messages/destroy.json", request, operationCompleted);
        }
#endif

        #endregion
    }
}