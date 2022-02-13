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
using Spring.Http.Converters.Xml;

using Spring.Social.LinkedIn.Api.Impl.Json;

namespace Spring.Social.LinkedIn.Api.Impl
{
    /// <summary>
    /// This is the central class for interacting with LinkedIn.
    /// </summary>
    /// <author>Bruno Baia</author>
    public class LinkedInTemplate : AbstractOAuth1ApiBinding, ILinkedIn 
    {
        private static readonly Uri API_URI_BASE = new Uri("https://api.linkedin.com/v1/");

        private ICommunicationOperations communicationOperations;
        private IConnectionOperations connectionOperations;
        private IProfileOperations profileOperations;

        /// <summary>
        /// Create a new instance of <see cref="LinkedInTemplate"/>.
        /// </summary>
        /// <param name="consumerKey">The application's API key.</param>
        /// <param name="consumerSecret">The application's API secret.</param>
        /// <param name="accessToken">An access token acquired through OAuth authentication with LinkedIn.</param>
        /// <param name="accessTokenSecret">An access token secret acquired through OAuth authentication with LinkedIn.</param>
        public LinkedInTemplate(string consumerKey, string consumerSecret, string accessToken, string accessTokenSecret) 
            : base(consumerKey, consumerSecret, accessToken, accessTokenSecret)
        {
            this.InitSubApis();
	    }

        #region ILinkedIn Members

        /// <summary>
        /// Gets the portion of the LinkedIn API sending messages and connection requests.
        /// </summary>
        public ICommunicationOperations CommunicationOperations 
        {
            get { return this.communicationOperations; }
        }

        /// <summary>
        /// Gets the portion of the LinkedIn API retrieving connections.
        /// </summary>
        public IConnectionOperations ConnectionOperations 
        { 
            get { return this.connectionOperations; }
        }

        /// <summary>
        /// Gets the portion of the LinkedIn API retrieving and performing operations on profiles.
        /// </summary>
        public IProfileOperations ProfileOperations 
        {
            get { return this.profileOperations; }
        }

        /// <summary>
        /// Gets the underlying <see cref="IRestOperations"/> object allowing for consumption of LinkedIn endpoints 
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
#if !WINDOWS_PHONE
            restTemplate.RequestInterceptors.Add(new LinkedInRequestFactoryInterceptor());
#endif
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
#if NET_3_0 || SILVERLIGHT
            converters.Add(new XElementHttpMessageConverter());
            converters.Add(new DataContractHttpMessageConverter(true));
            converters.Add(new DataContractJsonHttpMessageConverter(true));
#endif
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
            jsonMapper.RegisterDeserializer(typeof(LinkedInProfile), new LinkedInProfileDeserializer());
            jsonMapper.RegisterDeserializer(typeof(LinkedInFullProfile), new LinkedInFullProfileDeserializer());
            jsonMapper.RegisterDeserializer(typeof(IList<LinkedInProfile>), new LinkedInProfileListDeserializer<LinkedInProfile>());
            jsonMapper.RegisterDeserializer(typeof(IList<LinkedInFullProfile>), new LinkedInProfileListDeserializer<LinkedInFullProfile>());
            jsonMapper.RegisterDeserializer(typeof(NetworkStatistics), new NetworkStatisticsDeserializer());
            jsonMapper.RegisterSerializer(typeof(Message), new MessageSerializer());
            jsonMapper.RegisterSerializer(typeof(Invitation), new InvitationSerializer());
            jsonMapper.RegisterDeserializer(typeof(LinkedInProfiles), new LinkedInProfilesDeserializer());
            // 04/10/2012 Paul.  We need a new deserializer for the full profile. Not sure why there is both FullProfileList and FullProfiles. 
            jsonMapper.RegisterDeserializer(typeof(IList<LinkedInFullProfile>), new LinkedInFullProfileListDeserializer<LinkedInFullProfile>());
            jsonMapper.RegisterDeserializer(typeof(LinkedInFullProfiles), new LinkedInFullProfilesDeserializer());

            return new SpringJsonHttpMessageConverter(jsonMapper);
        }

        private void InitSubApis()
        {
            this.communicationOperations = new CommunicationTemplate(this.RestTemplate);
            this.connectionOperations = new ConnectionTemplate(this.RestTemplate);
            this.profileOperations = new ProfileTemplate(this.RestTemplate);
        }
    }
}