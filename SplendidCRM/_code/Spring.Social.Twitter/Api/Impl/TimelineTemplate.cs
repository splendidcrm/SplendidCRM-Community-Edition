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
using System.Globalization;
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

using Spring.IO;
using Spring.Rest.Client;

using Spring.Social.Twitter.Api.Impl.Json;

namespace Spring.Social.Twitter.Api.Impl
{
    /// <summary>
    /// Implementation of <see cref="ITimelineOperations"/>, providing a binding to Twitter's tweet and timeline-oriented REST resources.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class TimelineTemplate : AbstractTwitterOperations, ITimelineOperations
    {
        private RestTemplate restTemplate;

        public TimelineTemplate(RestTemplate restTemplate)
        {
            this.restTemplate = restTemplate;
        }

        #region ITimelineOperations Members

#if NET_4_0 || SILVERLIGHT_5
        public Task<IList<Tweet>> GetHomeTimelineAsync()
        {
            return this.GetHomeTimelineAsync(0, 0, 0);
        }

        public Task<IList<Tweet>> GetHomeTimelineAsync(int count)
        {
            return this.GetHomeTimelineAsync(count, 0, 0);
        }

        public Task<IList<Tweet>> GetHomeTimelineAsync(int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/home_timeline.json", parameters));
        }

        public Task<IList<Tweet>> GetUserTimelineAsync()
        {
            return this.GetUserTimelineAsync(0, 0, 0);
        }

        public Task<IList<Tweet>> GetUserTimelineAsync(int count)
        {
            return this.GetUserTimelineAsync(count, 0, 0);
        }

        public Task<IList<Tweet>> GetUserTimelineAsync(int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/user_timeline.json", parameters));
        }

        public Task<IList<Tweet>> GetUserTimelineAsync(string screenName)
        {
            return this.GetUserTimelineAsync(screenName, 0, 0, 0);
        }

        public Task<IList<Tweet>> GetUserTimelineAsync(string screenName, int count)
        {
            return this.GetUserTimelineAsync(screenName, count, 0, 0);
        }

        public Task<IList<Tweet>> GetUserTimelineAsync(string screenName, int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/user_timeline.json", parameters));
        }

        public Task<IList<Tweet>> GetUserTimelineAsync(long userId)
        {
            return this.GetUserTimelineAsync(userId, 0, 0, 0);
        }

        public Task<IList<Tweet>> GetUserTimelineAsync(long userId, int count)
        {
            return this.GetUserTimelineAsync(userId, count, 0, 0);
        }

        public Task<IList<Tweet>> GetUserTimelineAsync(long userId, int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/user_timeline.json", parameters));
        }

        public Task<IList<Tweet>> GetMentionsAsync()
        {
            return this.GetMentionsAsync(0, 0, 0);
        }

        public Task<IList<Tweet>> GetMentionsAsync(int count)
        {
            return this.GetMentionsAsync(count, 0, 0);
        }

        public Task<IList<Tweet>> GetMentionsAsync(int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/mentions_timeline.json", parameters));
        }

        public Task<IList<Tweet>> GetRetweetsOfMeAsync()
        {
            return this.GetRetweetsOfMeAsync(0, 0, 0);
        }

        public Task<IList<Tweet>> GetRetweetsOfMeAsync(int count)
        {
            return this.GetRetweetsOfMeAsync(count, 0, 0);
        }

        public Task<IList<Tweet>> GetRetweetsOfMeAsync(int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/retweets_of_me.json", parameters));
        }

        public Task<Tweet> GetStatusAsync(long tweetId)
        {
            return this.restTemplate.GetForObjectAsync<Tweet>("statuses/show/{tweetId}.json", tweetId);
        }

        public Task<Tweet> UpdateStatusAsync(string status)
        {
            return this.UpdateStatusAsync(status, new StatusDetails());
        }

        public Task<Tweet> UpdateStatusAsync(string status, IResource photo)
        {
            return this.UpdateStatusAsync(status, photo, new StatusDetails());
        }

        public Task<Tweet> UpdateStatusAsync(string status, StatusDetails details)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("status", status);
            AddStatusDetailsTo(request, details);
            return this.restTemplate.PostForObjectAsync<Tweet>("statuses/update.json", request);
        }

        public Task<Tweet> UpdateStatusAsync(string status, IResource photo, StatusDetails details)
        {
            IDictionary<string, object> request = new Dictionary<string, object>();
            request.Add("status", status);
            AddStatusDetailsTo(request, details);
            request.Add("media", photo);
            return this.restTemplate.PostForObjectAsync<Tweet>("statuses/update_with_media.json", request);
        }

        public Task<Tweet> DeleteStatusAsync(long tweetId)
        {
            NameValueCollection request = new NameValueCollection();
            return this.restTemplate.PostForObjectAsync<Tweet>("statuses/destroy/{tweetId}.json", request, tweetId);
        }

        public Task RetweetAsync(long tweetId)
        {
            NameValueCollection request = new NameValueCollection();
            return this.restTemplate.PostForMessageAsync("statuses/retweet/{tweetId}.json", request, tweetId);
        }

        public Task<IList<Tweet>> GetRetweetsAsync(long tweetId)
        {
            return this.GetRetweetsAsync(tweetId, 100);
        }

        public Task<IList<Tweet>> GetRetweetsAsync(long tweetId, int count)
        {
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>("statuses/retweets/{tweetId}.json?count={count}", tweetId, count);
        }

        public Task<IList<Tweet>> GetFavoritesAsync()
        {
            return this.GetFavoritesAsync(0);
        }

        public Task<IList<Tweet>> GetFavoritesAsync(int count)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, 0, 0);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("favorites/list.json", parameters));
        }

        public Task AddToFavoritesAsync(long tweetId)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("id", tweetId.ToString());
            return this.restTemplate.PostForMessageAsync("favorites/create.json", request);
        }

        public Task RemoveFromFavoritesAsync(long tweetId)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("id", tweetId.ToString());
            return this.restTemplate.PostForMessageAsync("favorites/destroy.json", request);
        }
#else
#if !SILVERLIGHT
        public IList<Tweet> GetHomeTimeline()
        {
            return this.GetHomeTimeline(0, 0, 0);
        }

        public IList<Tweet> GetHomeTimeline(int count)
        {
            return this.GetHomeTimeline(count, 0, 0);
        }

        public IList<Tweet> GetHomeTimeline(int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObject<IList<Tweet>>(this.BuildUrl("statuses/home_timeline.json", parameters));
        }

        public IList<Tweet> GetUserTimeline()
        {
            return this.GetUserTimeline(0, 0, 0);
        }

        public IList<Tweet> GetUserTimeline(int count)
        {
            return this.GetUserTimeline(count, 0, 0);
        }

        public IList<Tweet> GetUserTimeline(int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObject<IList<Tweet>>(this.BuildUrl("statuses/user_timeline.json", parameters));
        }

        public IList<Tweet> GetUserTimeline(string screenName)
        {
            return this.GetUserTimeline(screenName, 0, 0, 0);
        }

        public IList<Tweet> GetUserTimeline(string screenName, int count)
        {
            return this.GetUserTimeline(screenName, count, 0, 0);
        }

        public IList<Tweet> GetUserTimeline(string screenName, int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObject<IList<Tweet>>(this.BuildUrl("statuses/user_timeline.json", parameters));
        }

        public IList<Tweet> GetUserTimeline(long userId)
        {
            return this.GetUserTimeline(userId, 0, 0, 0);
        }

        public IList<Tweet> GetUserTimeline(long userId, int count)
        {
            return this.GetUserTimeline(userId, count, 0, 0);
        }

        public IList<Tweet> GetUserTimeline(long userId, int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObject<IList<Tweet>>(this.BuildUrl("statuses/user_timeline.json", parameters));
        }

        public IList<Tweet> GetMentions()
        {
            return this.GetMentions(0, 0, 0);
        }

        public IList<Tweet> GetMentions(int count)
        {
            return this.GetMentions(count, 0, 0);
        }

        public IList<Tweet> GetMentions(int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObject<IList<Tweet>>(this.BuildUrl("statuses/mentions_timeline.json", parameters));
        }

        public IList<Tweet> GetRetweetsOfMe()
        {
            return this.GetRetweetsOfMe(0, 0, 0);
        }

        public IList<Tweet> GetRetweetsOfMe(int count)
        {
            return this.GetRetweetsOfMe(count, 0, 0);
        }

        public IList<Tweet> GetRetweetsOfMe(int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObject<IList<Tweet>>(this.BuildUrl("statuses/retweets_of_me.json", parameters));
        }

        public Tweet GetStatus(long tweetId)
        {
            return this.restTemplate.GetForObject<Tweet>("statuses/show/{tweetId}.json", tweetId);
        }

        public Tweet UpdateStatus(string status)
        {
            return this.UpdateStatus(status, new StatusDetails());
        }

        public Tweet UpdateStatus(string status, IResource photo)
        {
            return this.UpdateStatus(status, photo, new StatusDetails());
        }

        public Tweet UpdateStatus(string status, StatusDetails details)
        {
		    NameValueCollection request = new NameValueCollection();
		    request.Add("status", status);
		    AddStatusDetailsTo(request, details);
		    return this.restTemplate.PostForObject<Tweet>("statuses/update.json", request);
        }

        public Tweet UpdateStatus(string status, IResource photo, StatusDetails details)
        {
		    IDictionary<string, object> request = new Dictionary<string, object>();
		    request.Add("status", status);
            AddStatusDetailsTo(request, details);
		    request.Add("media", photo);
		    return this.restTemplate.PostForObject<Tweet>("statuses/update_with_media.json", request);
        }

        public Tweet DeleteStatus(long tweetId)
        {
            NameValueCollection request = new NameValueCollection();
            return this.restTemplate.PostForObject<Tweet>("statuses/destroy/{tweetId}.json", request, tweetId);
        }

        public void Retweet(long tweetId)
        {
		    NameValueCollection request = new NameValueCollection();
		    this.restTemplate.PostForMessage("statuses/retweet/{tweetId}.json", request, tweetId);
        }

        public IList<Tweet> GetRetweets(long tweetId)
        {
            return this.GetRetweets(tweetId, 100);
        }

        public IList<Tweet> GetRetweets(long tweetId, int count)
        {
		    return this.restTemplate.GetForObject<IList<Tweet>>("statuses/retweets/{tweetId}.json?count={count}", tweetId, count);
        }

        public IList<Tweet> GetFavorites()
        {
            return this.GetFavorites(0);
        }

        public IList<Tweet> GetFavorites(int count)
        {
		    NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, 0, 0);
		    return this.restTemplate.GetForObject<IList<Tweet>>(this.BuildUrl("favorites/list.json", parameters));
        }

        public void AddToFavorites(long tweetId)
        {
		    NameValueCollection request = new NameValueCollection();
            request.Add("id", tweetId.ToString());
		    this.restTemplate.PostForMessage("favorites/create.json", request);
        }

        public void RemoveFromFavorites(long tweetId)
        {
		    NameValueCollection request = new NameValueCollection();
            request.Add("id", tweetId.ToString());
            this.restTemplate.PostForMessage("favorites/destroy.json", request);
        }
#endif

        public RestOperationCanceler GetHomeTimelineAsync(Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetHomeTimelineAsync(0, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetHomeTimelineAsync(int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetHomeTimelineAsync(count, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetHomeTimelineAsync(int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/home_timeline.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetUserTimelineAsync(Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetUserTimelineAsync(1, 20, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetUserTimelineAsync(int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetUserTimelineAsync(count, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetUserTimelineAsync(int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/user_timeline.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetUserTimelineAsync(string screenName, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetUserTimelineAsync(screenName, 0, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetUserTimelineAsync(string screenName, int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetUserTimelineAsync(screenName, count, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetUserTimelineAsync(string screenName, int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            parameters.Add("screen_name", screenName);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/user_timeline.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetUserTimelineAsync(long userId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetUserTimelineAsync(userId, 0, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetUserTimelineAsync(long userId, int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetUserTimelineAsync(userId, count, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetUserTimelineAsync(long userId, int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            parameters.Add("user_id", userId.ToString());
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/user_timeline.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetMentionsAsync(Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetMentionsAsync(0, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetMentionsAsync(int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetMentionsAsync(count, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetMentionsAsync(int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/mentions_timeline.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetRetweetsOfMeAsync(Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetRetweetsOfMeAsync(0, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetRetweetsOfMeAsync(int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetRetweetsOfMeAsync(count, 0, 0, operationCompleted);
        }

        public RestOperationCanceler GetRetweetsOfMeAsync(int count, long sinceId, long maxId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, sinceId, maxId);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("statuses/retweets_of_me.json", parameters), operationCompleted);
        }

        public RestOperationCanceler GetStatusAsync(long tweetId, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<Tweet>("statuses/show/{tweetId}.json", operationCompleted, tweetId);
        }

        public RestOperationCanceler UpdateStatusAsync(string status, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted)
        {
            return this.UpdateStatusAsync(status, new StatusDetails(), operationCompleted);
        }

        public RestOperationCanceler UpdateStatusAsync(string status, IResource photo, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted)
        {
            return this.UpdateStatusAsync(status, photo, new StatusDetails(), operationCompleted);
        }

        public RestOperationCanceler UpdateStatusAsync(string status, StatusDetails details, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("status", status);
            AddStatusDetailsTo(request, details);
            return this.restTemplate.PostForObjectAsync<Tweet>("statuses/update.json", request, operationCompleted);
        }

        public RestOperationCanceler UpdateStatusAsync(string status, IResource photo, StatusDetails details, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted)
        {
            IDictionary<string, object> request = new Dictionary<string, object>();
            request.Add("status", status);
            AddStatusDetailsTo(request, details);
            request.Add("media", photo);
            return this.restTemplate.PostForObjectAsync<Tweet>("statuses/update_with_media.json", request, operationCompleted);
        }

        public RestOperationCanceler DeleteStatusAsync(long tweetId, Action<RestOperationCompletedEventArgs<Tweet>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            return this.restTemplate.PostForObjectAsync<Tweet>("statuses/destroy/{tweetId}.json", request, operationCompleted, tweetId);
        }

        public RestOperationCanceler RetweetAsync(long tweetId, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            return this.restTemplate.PostForMessageAsync("statuses/retweet/{tweetId}.json", request, operationCompleted, tweetId);
        }

        public RestOperationCanceler GetRetweetsAsync(long tweetId, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetRetweetsAsync(tweetId, 100, operationCompleted);
        }

        public RestOperationCanceler GetRetweetsAsync(long tweetId, int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>("statuses/retweets/{tweetId}.json?count={count}", operationCompleted, tweetId, count);
        }

        public RestOperationCanceler GetFavoritesAsync(Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            return this.GetFavoritesAsync(0, operationCompleted);
        }

        public RestOperationCanceler GetFavoritesAsync(int count, Action<RestOperationCompletedEventArgs<IList<Tweet>>> operationCompleted)
        {
            NameValueCollection parameters = PagingUtils.BuildPagingParametersWithCount(count, 0, 0);
            return this.restTemplate.GetForObjectAsync<IList<Tweet>>(this.BuildUrl("favorites/list.json", parameters), operationCompleted);
        }

        public RestOperationCanceler AddToFavoritesAsync(long tweetId, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("id", tweetId.ToString());
            return this.restTemplate.PostForMessageAsync("favorites/create.json", request, operationCompleted);
        }

        public RestOperationCanceler RemoveFromFavoritesAsync(long tweetId, Action<RestOperationCompletedEventArgs<HttpResponseMessage>> operationCompleted)
        {
            NameValueCollection request = new NameValueCollection();
            request.Add("id", tweetId.ToString());
            return this.restTemplate.PostForMessageAsync("favorites/destroy.json", request, operationCompleted);
        }
#endif

        #endregion

        #region Private Methods

        private static void AddStatusDetailsTo(NameValueCollection parameters, StatusDetails details)
        {
            if (details.Latitude.HasValue && details.Longitude.HasValue)
            {
                parameters.Add("lat", details.Latitude.Value.ToString(CultureInfo.InvariantCulture));
                parameters.Add("long", details.Longitude.Value.ToString(CultureInfo.InvariantCulture));
            }
            if (details.DisplayCoordinates)
            {
                parameters.Add("display_coordinates", "true");
            }
            if (details.InReplyToStatusId.HasValue)
            {
                parameters.Add("in_reply_to_status_id", details.InReplyToStatusId.Value.ToString());
            }
            if (details.WrapLinks)
            {
                parameters.Add("wrap_links", "true");
            }
        }

        private static void AddStatusDetailsTo(IDictionary<string, object> parameters, StatusDetails details)
        {
            if (details.Latitude.HasValue && details.Longitude.HasValue)
            {
                parameters.Add("lat", details.Latitude.Value.ToString(CultureInfo.InvariantCulture));
                parameters.Add("long", details.Longitude.Value.ToString(CultureInfo.InvariantCulture));
            }
            if (details.DisplayCoordinates)
            {
                parameters.Add("display_coordinates", "true");
            }
            if (details.InReplyToStatusId.HasValue)
            {
                parameters.Add("in_reply_to_status_id", details.InReplyToStatusId.Value.ToString());
            }
            if (details.WrapLinks)
            {
                parameters.Add("wrap_links", "true");
            }
        }

        #endregion
    }
}