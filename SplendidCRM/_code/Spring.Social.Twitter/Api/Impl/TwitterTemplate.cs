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

using Spring.Json;
using Spring.Rest.Client;
using Spring.Social.OAuth1;
using Spring.Http.Converters;
using Spring.Http.Converters.Json;

using Spring.Social.Twitter.Api.Impl.Json;

namespace Spring.Social.Twitter.Api.Impl
{
    /// <summary>
    /// This is the central class for interacting with Twitter.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Most (not all) Twitter operations require OAuth authentication. 
    /// To perform such operations, <see cref="TwitterTemplate"/> must be constructed 
    /// with the minimal amount of information required to sign requests to Twitter's API 
    /// with an OAuth <code>Authorization</code> header.
    /// </para>
    /// <para>
    /// There are some operations, such as searching, that do not require OAuth authentication. 
    /// In those cases, you may use a <see cref="TwitterTemplate"/> that is created through 
    /// the default constructor and without any OAuth details.
    /// Attempts to perform secured operations through such an instance, however, 
    /// will result in <see cref="TwitterApiException"/> being thrown.
    /// </para>
    /// </remarks>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    public class TwitterTemplate : AbstractOAuth1ApiBinding, ITwitter 
    {
        private static readonly Uri API_URI_BASE = new Uri("https://api.twitter.com/1.1/");

        private IBlockOperations blockOperations;
        private IDirectMessageOperations directMessageOperations;
        private IFriendOperations friendOperations;
        private IGeoOperations geoOperations;
        private IListOperations listOperations;
        private ISearchOperations searchOperations;
        private ITimelineOperations timelineOperations;
        private IUserOperations userOperations;

        /// <summary>
        /// Create a new instance of <see cref="TwitterTemplate"/>.
        /// </summary>
        /// <param name="consumerKey">The application's API key.</param>
        /// <param name="consumerSecret">The application's API secret.</param>
        /// <param name="accessToken">An access token acquired through OAuth authentication with Twitter.</param>
        /// <param name="accessTokenSecret">An access token secret acquired through OAuth authentication with Twitter.</param>
        public TwitterTemplate(string consumerKey, string consumerSecret, string accessToken, string accessTokenSecret) 
            : base(consumerKey, consumerSecret, accessToken, accessTokenSecret)
        {
            this.InitSubApis();
	    }

        #region ITwitter Members

        /// <summary>
        /// Gets the portion of the Twitter API containing the block operations.
        /// </summary>
        public IBlockOperations BlockOperations
        {
            get { return this.blockOperations; }
        }

        /// <summary>
        /// Gets the portion of the Twitter API containing the direct message operations.
        /// </summary>
        public IDirectMessageOperations DirectMessageOperations
        {
            get { return this.directMessageOperations; }
        }

        /// <summary>
        /// Gets the portion of the Twitter API containing the friends and followers operations.
        /// </summary>
        public IFriendOperations FriendOperations
        {
            get { return this.friendOperations; }
        }

        /// <summary>
        /// Gets the portion of the Twitter API containing the geo location operations.
        /// </summary>
        public IGeoOperations GeoOperations
        {
            get { return this.geoOperations; }
        }

        /// <summary>
        /// Gets the portion of the Twitter API containing the user list operations.
        /// </summary>
        public IListOperations ListOperations
        {
            get { return this.listOperations; }
        }

        /// <summary>
        /// Gets the portion of the Twitter API containing the search operations.
        /// </summary>        
        public ISearchOperations SearchOperations
        {
            get { return this.searchOperations; }
        }

        /// <summary>
        /// Gets the portion of the Twitter API containing the tweet and timeline operations.
        /// </summary>
        public ITimelineOperations TimelineOperations
        {
            get { return this.timelineOperations; }
        }

        /// <summary>
        /// Gets the portion of the Twitter API containing the user operations.
        /// </summary>
        public IUserOperations UserOperations
        {
            get { return this.userOperations; }
        }

        /// <summary>
        /// Gets the underlying <see cref="IRestOperations"/> object allowing for consumption of Twitter endpoints 
        /// that may not be otherwise covered by the API binding. 
        /// </summary>
        /// <remarks>
        /// The <see cref="IRestOperations"/> object returned is configured to include an OAuth "Authorization" header on all requests.
        /// </remarks>
        public IRestOperations RestOperations
        {
            get { return this.RestTemplate; }
        }

        #endregion

        /// <summary>
        /// Enables customization of the <see cref="RestTemplate"/> used to consume provider API resources.
        /// </summary>
        /// <remarks>
        /// An example use case might be to configure a custom error handler. 
        /// Note that this method is called after the RestTemplate has been configured with the message converters returned from GetMessageConverters().
        /// </remarks>
        /// <param name="restTemplate">The RestTemplate to configure.</param>
        protected override void ConfigureRestTemplate(RestTemplate restTemplate)
        {
            restTemplate.BaseAddress = API_URI_BASE;
            restTemplate.ErrorHandler = new TwitterErrorHandler();
        }

        /// <summary>
        /// Returns a list of <see cref="IHttpMessageConverter"/>s to be used by the internal <see cref="RestTemplate"/>.
        /// </summary>
        /// <remarks>
        /// This implementation adds <see cref="SpringJsonHttpMessageConverter"/> and <see cref="ByteArrayHttpMessageConverter"/> to the default list.
        /// </remarks>
        /// <returns>
        /// The list of <see cref="IHttpMessageConverter"/>s to be used by the internal <see cref="RestTemplate"/>.
        /// </returns>
        protected override IList<IHttpMessageConverter> GetMessageConverters()
        {
            IList<IHttpMessageConverter> converters = base.GetMessageConverters();
            converters.Add(new ByteArrayHttpMessageConverter());
            converters.Add(this.GetJsonMessageConverter());
            return converters;
        }

        /// <summary>
        /// Returns a <see cref="SpringJsonHttpMessageConverter"/> to be used by the internal <see cref="RestTemplate"/>.
        /// <para/>
        /// Override to customize the message converter (for example, to set a custom object mapper or supported media types).
        /// </summary>
        /// <returns>The configured <see cref="SpringJsonHttpMessageConverter"/>.</returns>
        protected virtual SpringJsonHttpMessageConverter GetJsonMessageConverter()
        {
            JsonMapper jsonMapper = new JsonMapper();
            jsonMapper.RegisterDeserializer(typeof(Tweet), new TweetDeserializer());
            jsonMapper.RegisterDeserializer(typeof(IList<Tweet>), new TweetListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(TwitterProfile), new TwitterProfileDeserializer());
            jsonMapper.RegisterDeserializer(typeof(IList<TwitterProfile>), new TwitterProfileListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(CursoredList<TwitterProfile>), new CursoredTwitterProfileListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(IList<long>), new LongListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(SearchResults), new SearchResultsDeserializer());
            jsonMapper.RegisterDeserializer(typeof(SavedSearch), new SavedSearchDeserializer());
            jsonMapper.RegisterDeserializer(typeof(IList<SavedSearch>), new SavedSearchListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(Trends), new TrendsDeserializer());
            jsonMapper.RegisterDeserializer(typeof(IList<RateLimitStatus>), new RateLimitStatusListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(IList<SuggestionCategory>), new SuggestionCategoryListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(DirectMessage), new DirectMessageDeserializer());
            jsonMapper.RegisterDeserializer(typeof(IList<DirectMessage>), new DirectMessageListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(Place), new PlaceDeserializer());
            jsonMapper.RegisterDeserializer(typeof(IList<Place>), new PlaceListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(SimilarPlaces), new SimilarPlacesDeserializer());
            jsonMapper.RegisterDeserializer(typeof(CursoredList<long>), new CursoredLongListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(UserList), new UserListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(IList<UserList>), new UserListListDeserializer());
            jsonMapper.RegisterDeserializer(typeof(CursoredList<UserList>), new CursoredUserListListDeserializer());

            return new SpringJsonHttpMessageConverter(jsonMapper);
        }

        private void InitSubApis()
        {
            this.blockOperations = new BlockTemplate(this.RestTemplate);
            this.directMessageOperations = new DirectMessageTemplate(this.RestTemplate);
            this.friendOperations = new FriendTemplate(this.RestTemplate);
            this.geoOperations = new GeoTemplate(this.RestTemplate);
            this.listOperations = new ListTemplate(this.RestTemplate);
            this.searchOperations = new SearchTemplate(this.RestTemplate);
            this.timelineOperations = new TimelineTemplate(this.RestTemplate);
            this.userOperations = new UserTemplate(this.RestTemplate);
        }
    }
}