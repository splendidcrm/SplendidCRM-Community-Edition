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
#if NET_4_0 || SILVERLIGHT_5
using System.Threading.Tasks;
#endif
#if SILVERLIGHT
using Spring.Collections.Specialized;
#else
using System.Collections.Specialized;
#endif

using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.LinkedIn.Api.Impl
{
    /// <summary>
    /// Implementation of <see cref="IConnectionOperations"/>, providing a binding to LinkedIn's connections-oriented REST resources.
    /// </summary>
    /// <author>Robert Drysdale</author>
    /// <author>Bruno Baia  (.NET)</author>
    class ConnectionTemplate : AbstractLinkedInOperations, IConnectionOperations
    {
        private const string ConnectionsUrl = "people/~/connections:(id,first-name,last-name,headline,industry,site-standard-profile-request,public-profile-url,picture-url,summary)?format=json";
        private const string NetworkStatsUrl = "people/~/network/network-stats?format=json";

        private RestTemplate restTemplate;

        public ConnectionTemplate(RestTemplate restTemplate)
        {
            this.restTemplate = restTemplate;
        }

        #region IConnectionOperations Members

#if NET_4_0 || SILVERLIGHT_5
        public Task<LinkedInProfiles> GetConnectionsAsync()
        {
            return this.restTemplate.GetForObjectAsync<LinkedInProfiles>(ConnectionsUrl);
        }

        public Task<LinkedInProfiles> GetConnectionsAsync(int start, int count)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("start", start.ToString());
            parameters.Add("count", count.ToString());
            return this.restTemplate.GetForObjectAsync<LinkedInProfiles>(this.BuildUrl(ConnectionsUrl, parameters));
        }

        public Task<NetworkStatistics> GetNetworkStatisticsAsync()
        {
            return this.restTemplate.GetForObjectAsync<NetworkStatistics>(NetworkStatsUrl);
        }
#else
#if !SILVERLIGHT
        public LinkedInProfiles GetConnections()
        {
            return this.restTemplate.GetForObject<LinkedInProfiles>(ConnectionsUrl);
        }

        public LinkedInProfiles GetConnections(int start, int count)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("start", start.ToString());
            parameters.Add("count", count.ToString());
            return this.restTemplate.GetForObject<LinkedInProfiles>(this.BuildUrl(ConnectionsUrl, parameters));
        }

        public NetworkStatistics GetNetworkStatistics()
        {
            return this.restTemplate.GetForObject<NetworkStatistics>(NetworkStatsUrl);
        }
#endif

        public RestOperationCanceler GetConnectionsAsync(Action<RestOperationCompletedEventArgs<LinkedInProfiles>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInProfiles>(ConnectionsUrl, operationCompleted);
        }

        public RestOperationCanceler GetConnectionsAsync(int start, int count, Action<RestOperationCompletedEventArgs<LinkedInProfiles>> operationCompleted)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("start", start.ToString());
            parameters.Add("count", count.ToString());
            return this.restTemplate.GetForObjectAsync<LinkedInProfiles>(this.BuildUrl(ConnectionsUrl, parameters), operationCompleted);
        }

        public RestOperationCanceler GetNetworkStatisticsAsync(Action<RestOperationCompletedEventArgs<NetworkStatistics>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<NetworkStatistics>(NetworkStatsUrl, operationCompleted);
        }
#endif

        #endregion
    }
}