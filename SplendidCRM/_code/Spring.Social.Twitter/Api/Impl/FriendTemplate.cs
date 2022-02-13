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
    /// Implementation of <see cref="IFriendOperations"/>, providing a binding to Twitter's friends and followers-oriented REST resources.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class FriendTemplate : AbstractTwitterOperations, IFriendOperations
    {
        private RestTemplate restTemplate;

        public FriendTemplate(RestTemplate restTemplate)
        {
            this.restTemplate = restTemplate;
        }

        #region IFriendOperations Members

#if NET_4_0 || SILVERLIGHT_5
        public Task<CursoredList<TwitterProfile>> GetFriendsAsync() 
        {
            return this.GetFriendsInCursorAsync(-1);
	    }

        public Task<CursoredList<TwitterProfile>> GetFriendsInCursorAsync(long cursor)
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("friends/list.json", "cursor", cursor.ToString()));
        }

        public Task<CursoredList<TwitterProfile>> GetFriendsAsync(long userId) 
        {
            return this.GetFriendsInCursorAsync(userId, -1);
	    }

        public Task<CursoredList<TwitterProfile>> GetFriendsInCursorAsync(long userId, long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("friends/list.json", parameters));
	    }

        public Task<CursoredList<TwitterProfile>> GetFriendsAsync(string screenName) 
        {
            return this.GetFriendsInCursorAsync(screenName, -1);
	    }

        public Task<CursoredList<TwitterProfile>> GetFriendsInCursorAsync(string screenName, long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("friends/list.json", parameters));
	    }

        public Task<CursoredList<long>> GetFriendIdsAsync() 
        {
            return this.GetFriendIdsInCursorAsync(-1);
	    }

        public Task<CursoredList<long>> GetFriendIdsInCursorAsync(long cursor) 
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("friends/ids.json", "cursor", cursor.ToString()));
	    }

        public Task<CursoredList<long>> GetFriendIdsAsync(long userId) 
        {
            return this.GetFriendIdsInCursorAsync(userId, -1);
	    }

        public Task<CursoredList<long>> GetFriendIdsInCursorAsync(long userId, long cursor) 
        {
		    NameValueCollection parameters = new NameValueCollection();
		    parameters.Add("cursor", cursor.ToString());
		    parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("friends/ids.json", parameters));
	    }

        public Task<CursoredList<long>> GetFriendIdsAsync(string screenName) 
        {
            return this.GetFriendIdsInCursorAsync(screenName, -1);
	    }

        public Task<CursoredList<long>> GetFriendIdsInCursorAsync(string screenName, long cursor) 
        {
		    NameValueCollection parameters = new NameValueCollection();
		    parameters.Add("cursor", cursor.ToString());
		    parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("friends/ids.json", parameters));
	    }

        public Task<CursoredList<TwitterProfile>> GetFollowersAsync() 
        {
            return this.GetFollowersInCursorAsync(-1);
	    }

        public Task<CursoredList<TwitterProfile>> GetFollowersInCursorAsync(long cursor) 
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("followers/list.json", "cursor", cursor.ToString()));
	    }

        public Task<CursoredList<TwitterProfile>> GetFollowersAsync(long userId) 
        {
            return this.GetFollowersInCursorAsync(userId, -1);
	    }

        public Task<CursoredList<TwitterProfile>> GetFollowersInCursorAsync(long userId, long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("followers/list.json", parameters));
	    }

        public Task<CursoredList<TwitterProfile>> GetFollowersAsync(string screenName) 
        {
            return this.GetFollowersInCursorAsync(screenName, -1);
	    }

        public Task<CursoredList<TwitterProfile>> GetFollowersInCursorAsync(string screenName, long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("followers/list.json", parameters));
	    }

        public Task<CursoredList<long>> GetFollowerIdsAsync() 
        {
            return this.GetFollowerIdsInCursorAsync(-1);
	    }

        public Task<CursoredList<long>> GetFollowerIdsInCursorAsync(long cursor) 
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("followers/ids.json", "cursor", cursor.ToString()));
	    }

        public Task<CursoredList<long>> GetFollowerIdsAsync(long userId) 
        {
            return this.GetFollowerIdsInCursorAsync(userId, -1);
	    }

        public Task<CursoredList<long>> GetFollowerIdsInCursorAsync(long userId, long cursor) 
        {
		    NameValueCollection parameters = new NameValueCollection();
		    parameters.Add("cursor", cursor.ToString());
		    parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("followers/ids.json", parameters));
	    }

        public Task<CursoredList<long>> GetFollowerIdsAsync(string screenName) 
        {
            return this.GetFollowerIdsInCursorAsync(screenName, -1);
	    }

        public Task<CursoredList<long>> GetFollowerIdsInCursorAsync(string screenName, long cursor) 
        {
		    NameValueCollection parameters = new NameValueCollection();
		    parameters.Add("cursor", cursor.ToString());
		    parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("followers/ids.json", parameters));
	    }

        public Task<TwitterProfile> FollowAsync(long userId) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("friendships/create.json", request);
	    }

        public Task<TwitterProfile> FollowAsync(string screenName) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("friendships/create.json", request);
	    }

        public Task<TwitterProfile> UnfollowAsync(long userId) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("friendships/destroy.json", request);
	    }

        public Task<TwitterProfile> UnfollowAsync(string screenName) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("friendships/destroy.json", request);
	    }

        public Task EnableNotificationsAsync(long userId) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            request.Add("device", "true");
            return this.restTemplate.PostForMessageAsync("friendships/update.json", request);
	    }

        public Task EnableNotificationsAsync(string screenName) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            request.Add("device", "true");
            return this.restTemplate.PostForMessageAsync("friendships/update.json", request);
	    }

        public Task DisableNotificationsAsync(long userId) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            request.Add("device", "false");
            return this.restTemplate.PostForMessageAsync("friendships/update.json", request);
	    }

        public Task DisableNotificationsAsync(string screenName) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            request.Add("device", "false");
            return this.restTemplate.PostForMessageAsync("friendships/update.json", request);
	    }

        public Task<CursoredList<long>> GetIncomingFriendshipsAsync() 
        {
            return this.GetIncomingFriendshipsAsync(-1);
	    }

        public Task<CursoredList<long>> GetIncomingFriendshipsAsync(long cursor) 
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("friendships/incoming.json", "cursor", cursor.ToString()));
	    }

        public Task<CursoredList<long>> GetOutgoingFriendshipsAsync() 
        {
            return this.GetOutgoingFriendshipsAsync(-1);
	    }

        public Task<CursoredList<long>> GetOutgoingFriendshipsAsync(long cursor) 
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("friendships/outgoing.json", "cursor", cursor.ToString()));
	    }
#else
#if !SILVERLIGHT
        public CursoredList<TwitterProfile> GetFriends() 
        {
		    return this.GetFriendsInCursor(-1);
	    }

	    public CursoredList<TwitterProfile> GetFriendsInCursor(long cursor) 
        {
            return this.restTemplate.GetForObject<CursoredList<TwitterProfile>>(this.BuildUrl("friends/list.json", "cursor", cursor.ToString()));
	    }

	    public CursoredList<TwitterProfile> GetFriends(long userId) 
        {
		    return this.GetFriendsInCursor(userId, -1);
	    }

	    public CursoredList<TwitterProfile> GetFriendsInCursor(long userId, long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObject<CursoredList<TwitterProfile>>(this.BuildUrl("friends/list.json", parameters)); ;
	    }

	    public CursoredList<TwitterProfile> GetFriends(string screenName) 
        {
		    return this.GetFriendsInCursor(screenName, -1);
	    }
	
	    public CursoredList<TwitterProfile> GetFriendsInCursor(string screenName, long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObject<CursoredList<TwitterProfile>>(this.BuildUrl("friends/list.json", parameters));
        }
	
	    public CursoredList<long> GetFriendIds() 
        {
		    return this.GetFriendIdsInCursor(-1);
	    }
	
	    public CursoredList<long> GetFriendIdsInCursor(long cursor) 
        {
		    return this.restTemplate.GetForObject<CursoredList<long>>(this.BuildUrl("friends/ids.json", "cursor", cursor.ToString()));
	    }

	    public CursoredList<long> GetFriendIds(long userId) 
        {
		    return this.GetFriendIdsInCursor(userId, -1);
	    }
	
	    public CursoredList<long> GetFriendIdsInCursor(long userId, long cursor) 
        {
		    NameValueCollection parameters = new NameValueCollection();
		    parameters.Add("cursor", cursor.ToString());
		    parameters.Add("user_id", userId.ToString());
		    return this.restTemplate.GetForObject<CursoredList<long>>(this.BuildUrl("friends/ids.json", parameters));;
	    }

	    public CursoredList<long> GetFriendIds(string screenName) 
        {
		    return this.GetFriendIdsInCursor(screenName, -1);
	    }
	
	    public CursoredList<long> GetFriendIdsInCursor(string screenName, long cursor) 
        {
		    NameValueCollection parameters = new NameValueCollection();
		    parameters.Add("cursor", cursor.ToString());
		    parameters.Add("screen_name", screenName);
		    return this.restTemplate.GetForObject<CursoredList<long>>(this.BuildUrl("friends/ids.json", parameters));
	    }

	    public CursoredList<TwitterProfile> GetFollowers() 
        {
		    return this.GetFollowersInCursor(-1);
	    }
	
	    public CursoredList<TwitterProfile> GetFollowersInCursor(long cursor) 
        {
            return this.restTemplate.GetForObject<CursoredList<TwitterProfile>>(this.BuildUrl("followers/list.json", "cursor", cursor.ToString()));
	    }

	    public CursoredList<TwitterProfile> GetFollowers(long userId) 
        {
		    return this.GetFollowersInCursor(userId, -1);
	    }
	
	    public CursoredList<TwitterProfile> GetFollowersInCursor(long userId, long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObject<CursoredList<TwitterProfile>>(this.BuildUrl("followers/list.json", parameters));
	    }

	    public CursoredList<TwitterProfile> GetFollowers(string screenName) 
        {
		    return this.GetFollowersInCursor(screenName, -1);
	    }
	
	    public CursoredList<TwitterProfile> GetFollowersInCursor(string screenName, long cursor) 
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObject<CursoredList<TwitterProfile>>(this.BuildUrl("followers/list.json", parameters));
	    }

	    public CursoredList<long> GetFollowerIds() 
        {
		    return this.GetFollowerIdsInCursor(-1);
	    }
	
	    public CursoredList<long> GetFollowerIdsInCursor(long cursor) 
        {
		    return this.restTemplate.GetForObject<CursoredList<long>>(this.BuildUrl("followers/ids.json", "cursor", cursor.ToString()));
	    }

	    public CursoredList<long> GetFollowerIds(long userId) 
        {
		    return this.GetFollowerIdsInCursor(userId, -1);
	    }
	
	    public CursoredList<long> GetFollowerIdsInCursor(long userId, long cursor) 
        {
		    NameValueCollection parameters = new NameValueCollection();
		    parameters.Add("cursor", cursor.ToString());
		    parameters.Add("user_id", userId.ToString());
		    return this.restTemplate.GetForObject<CursoredList<long>>(this.BuildUrl("followers/ids.json", parameters));
	    }

	    public CursoredList<long> GetFollowerIds(string screenName) 
        {
		    return this.GetFollowerIdsInCursor(screenName, -1);
	    }
	
	    public CursoredList<long> GetFollowerIdsInCursor(string screenName, long cursor) 
        {
		    NameValueCollection parameters = new NameValueCollection();
		    parameters.Add("cursor", cursor.ToString());
		    parameters.Add("screen_name", screenName);
		    return this.restTemplate.GetForObject<CursoredList<long>>(this.BuildUrl("followers/ids.json", parameters));
	    }

	    public TwitterProfile Follow(long userId) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
		    return this.restTemplate.PostForObject<TwitterProfile>("friendships/create.json", request);
	    }

	    public TwitterProfile Follow(string screenName) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            return this.restTemplate.PostForObject<TwitterProfile>("friendships/create.json", request);
	    }
	
	    public TwitterProfile Unfollow(long userId) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
		    return this.restTemplate.PostForObject<TwitterProfile>("friendships/destroy.json", request);
	    }

	    public TwitterProfile Unfollow(string screenName) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
		    return this.restTemplate.PostForObject<TwitterProfile>("friendships/destroy.json", request);
	    }

        public void EnableNotifications(long userId) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            request.Add("device", "true");
            this.restTemplate.PostForMessage("friendships/update.json", request);
	    }

        public void EnableNotifications(string screenName) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            request.Add("device", "true");
            this.restTemplate.PostForMessage("friendships/update.json", request);
	    }

        public void DisableNotifications(long userId) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            request.Add("device", "false");
            this.restTemplate.PostForMessage("friendships/update.json", request);
	    }
	
	    public void DisableNotifications(string screenName) 
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            request.Add("device", "false");
            this.restTemplate.PostForMessage("friendships/update.json", request);
	    }
	
	    public CursoredList<long> GetIncomingFriendships() 
        {
		    return this.GetIncomingFriendships(-1);
	    }
	
	    public CursoredList<long> GetIncomingFriendships(long cursor) 
        {
		    return this.restTemplate.GetForObject<CursoredList<long>>(this.BuildUrl("friendships/incoming.json", "cursor", cursor.ToString()));
	    }

	    public CursoredList<long> GetOutgoingFriendships() 
        {
		    return this.GetOutgoingFriendships(-1);
	    }
	
	    public CursoredList<long> GetOutgoingFriendships(long cursor) 
        {
		    return this.restTemplate.GetForObject<CursoredList<long>>(this.BuildUrl("friendships/outgoing.json", "cursor", cursor.ToString()));
	    }
#endif

        public RestOperationCanceler GetFriendsAsync(Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            return this.GetFriendsInCursorAsync(-1, operationCompleted);
        }

        public RestOperationCanceler GetFriendsInCursorAsync(long cursor, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("friends/list.json", "cursor", cursor.ToString()), operationCompleted);
        }

        public RestOperationCanceler GetFriendsAsync(long userId, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            return this.GetFriendsInCursorAsync(userId, -1, operationCompleted);
        }

        public RestOperationCanceler GetFriendsInCursorAsync(long userId, long cursor, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("friends/list.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetFriendsAsync(string screenName, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            return this.GetFriendsInCursorAsync(screenName, -1, operationCompleted);
        }

        public RestOperationCanceler GetFriendsInCursorAsync(string screenName, long cursor, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("friends/list.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetFriendIdsAsync(Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.GetFriendIdsInCursorAsync(-1, operationCompleted);
        }

        public RestOperationCanceler GetFriendIdsInCursorAsync(long cursor, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("friends/ids.json", "cursor", cursor.ToString()), operationCompleted);
        }

        public RestOperationCanceler GetFriendIdsAsync(long userId, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.GetFriendIdsInCursorAsync(userId, -1, operationCompleted);
        }

        public RestOperationCanceler GetFriendIdsInCursorAsync(long userId, long cursor, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("friends/ids.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetFriendIdsAsync(string screenName, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.GetFriendIdsInCursorAsync(screenName, -1, operationCompleted);
        }

        public RestOperationCanceler GetFriendIdsInCursorAsync(string screenName, long cursor, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("friends/ids.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetFollowersAsync(Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            return this.GetFollowersInCursorAsync(-1, operationCompleted);
        }

        public RestOperationCanceler GetFollowersInCursorAsync(long cursor, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("followers/list.json", "cursor", cursor.ToString()), operationCompleted);
        }

        public RestOperationCanceler GetFollowersAsync(long userId, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            return this.GetFollowersInCursorAsync(userId, -1, operationCompleted);
        }

        public RestOperationCanceler GetFollowersInCursorAsync(long userId, long cursor, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("followers/list.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetFollowersAsync(string screenName, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            return this.GetFollowersInCursorAsync(screenName, -1, operationCompleted);
        }

        public RestOperationCanceler GetFollowersInCursorAsync(string screenName, long cursor, Action<RestOperationCompletedEventArgs<CursoredList<TwitterProfile>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObjectAsync<CursoredList<TwitterProfile>>(this.BuildUrl("followers/list.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetFollowerIdsAsync(Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.GetFollowerIdsInCursorAsync(-1, operationCompleted);
        }

        public RestOperationCanceler GetFollowerIdsInCursorAsync(long cursor, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("followers/ids.json", "cursor", cursor.ToString()), operationCompleted);
        }

        public RestOperationCanceler GetFollowerIdsAsync(long userId, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.GetFollowerIdsInCursorAsync(userId, -1, operationCompleted);
        }

        public RestOperationCanceler GetFollowerIdsInCursorAsync(long userId, long cursor, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("followers/ids.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetFollowerIdsAsync(string screenName, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.GetFollowerIdsInCursorAsync(screenName, -1, operationCompleted);
        }

        public RestOperationCanceler GetFollowerIdsInCursorAsync(string screenName, long cursor, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("cursor", cursor.ToString());
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("followers/ids.json", parameters), operationCompleted);
        }

        public RestOperationCanceler FollowAsync(long userId, Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("friendships/create.json", request, operationCompleted);
        }

        public RestOperationCanceler FollowAsync(string screenName, Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("friendships/create.json", request, operationCompleted);
        }

        public RestOperationCanceler UnfollowAsync(long userId, Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("friendships/destroy.json", request, operationCompleted);
        }

        public RestOperationCanceler UnfollowAsync(string screenName, Action<RestOperationCompletedEventArgs<TwitterProfile>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            return this.restTemplate.PostForObjectAsync<TwitterProfile>("friendships/destroy.json", request, operationCompleted);
        }

        public RestOperationCanceler EnableNotificationsAsync(long userId, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            request.Add("device", "true");
            return this.restTemplate.PostForMessageAsync("friendships/update.json", request, operationCompleted);
        }

        public RestOperationCanceler EnableNotificationsAsync(string screenName, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            request.Add("device", "true");
            return this.restTemplate.PostForMessageAsync("friendships/update.json", request, operationCompleted);
        }

        public RestOperationCanceler DisableNotificationsAsync(long userId, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("user_id", userId.ToString());
            request.Add("device", "false");
            return this.restTemplate.PostForMessageAsync("friendships/update.json", request, operationCompleted);
        }

        public RestOperationCanceler DisableNotificationsAsync(string screenName, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("screen_name", screenName);
            request.Add("device", "false");
            return this.restTemplate.PostForMessageAsync("friendships/update.json", request, operationCompleted);
        }

        public RestOperationCanceler GetIncomingFriendshipsAsync(Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.GetIncomingFriendshipsAsync(-1, operationCompleted);
        }

        public RestOperationCanceler GetIncomingFriendshipsAsync(long cursor, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("friendships/incoming.json", "cursor", cursor.ToString()), operationCompleted);
        }

        public RestOperationCanceler GetOutgoingFriendshipsAsync(Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.GetOutgoingFriendshipsAsync(-1, operationCompleted);
        }

        public RestOperationCanceler GetOutgoingFriendshipsAsync(long cursor, Action<RestOperationCompletedEventArgs<CursoredList<long>>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<CursoredList<long>>(this.BuildUrl("friendships/outgoing.json", "cursor", cursor.ToString()), operationCompleted);
        }
#endif

        #endregion
    }
}