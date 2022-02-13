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
    /// Implementation of <see cref="IProfileOperations"/>, providing a binding to LinkedIn's profiles-oriented REST resources.
    /// </summary>
    /// <author>Bruno Baia</author>
    class ProfileTemplate : AbstractLinkedInOperations, IProfileOperations
    {
        private const string ProfileUrl = "people/{id}:(id,first-name,last-name,headline,industry,public-profile-url,picture-url,summary,site-standard-profile-request,api-standard-profile-request)?format=json";
        private const string FullProfileUrl = "people/{id}:(id,first-name,last-name,headline,industry,public-profile-url,picture-url,summary,site-standard-profile-request,api-standard-profile-request,location,distance,num-connections,num-connections-capped,specialties,proposal-comments,associations,honors,interests,positions,skills,educations,num-recommenders,recommendations-received,phone-numbers,im-accounts,twitter-accounts,date-of-birth,main-address,member-url-resources)?format=json";
        private const string SearchUrl = "https://api.linkedin.com/v1/people-search:(people:(id,first-name,last-name,headline,industry,public-profile-url,picture-url,summary,site-standard-profile-request,api-standard-profile-request))?format=json";

        private RestTemplate restTemplate;

        public ProfileTemplate(RestTemplate restTemplate)
        {
            this.restTemplate = restTemplate;
        }

        #region IProfileOperations Members

#if NET_4_0 || SILVERLIGHT_5
        public Task<LinkedInProfile> GetUserProfileAsync()
        {
            return this.restTemplate.GetForObjectAsync<LinkedInProfile>(ProfileUrl, "~");
        }

        public Task<LinkedInProfile> GetUserProfileByIdAsync(string id)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInProfile>(ProfileUrl, "id=" + id);
        }

        public Task<LinkedInProfile> GetUserProfileByPublicUrlAsync(string url)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInProfile>(ProfileUrl, "url=" + HttpUtils.UrlEncode(url));
        }

        public Task<LinkedInFullProfile> GetUserFullProfileAsync()
        {
            return this.restTemplate.GetForObjectAsync<LinkedInFullProfile>(FullProfileUrl, "~");
        }

        public Task<LinkedInFullProfile> GetUserFullProfileByIdAsync(string id)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInFullProfile>(FullProfileUrl, "id=" + id);
        }

        public Task<LinkedInFullProfile> GetUserFullProfileByPublicUrlAsync(string url)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInFullProfile>(FullProfileUrl, "url=" + HttpUtils.UrlEncode(url));
        }

        public Task<LinkedInProfiles> SearchAsync(SearchParameters searchParams)
        {
            NameValueCollection parameters = BuildSearchParameters(searchParams);
            return this.restTemplate.GetForObjectAsync<LinkedInProfiles>(this.BuildUrl(SearchUrl, parameters));
        }
#else
#if !SILVERLIGHT
        public LinkedInProfile GetUserProfile()
        {
            return this.restTemplate.GetForObject<LinkedInProfile>(ProfileUrl, "~");
        }

        public LinkedInProfile GetUserProfileById(string id)
        {
            return this.restTemplate.GetForObject<LinkedInProfile>(ProfileUrl, "id=" + id);
        }

        public LinkedInProfile GetUserProfileByPublicUrl(string url)
        {
            return this.restTemplate.GetForObject<LinkedInProfile>(ProfileUrl, "url=" + HttpUtils.UrlEncode(url));
        }

        public LinkedInFullProfile GetUserFullProfile()
        {
            return this.restTemplate.GetForObject<LinkedInFullProfile>(FullProfileUrl, "~");
        }

        public LinkedInFullProfile GetUserFullProfileById(string id)
        {
            return this.restTemplate.GetForObject<LinkedInFullProfile>(FullProfileUrl, "id=" + id);
        }

        public LinkedInFullProfile GetUserFullProfileByPublicUrl(string url)
        {
            return this.restTemplate.GetForObject<LinkedInFullProfile>(FullProfileUrl, "url=" + HttpUtils.UrlEncode(url));
        }

        public LinkedInProfiles Search(SearchParameters searchParams)
        {
            NameValueCollection parameters = BuildSearchParameters(searchParams);
            return this.restTemplate.GetForObject<LinkedInProfiles>(this.BuildUrl(SearchUrl, parameters));
        }
#endif

        public RestOperationCanceler GetUserProfileAsync(Action<RestOperationCompletedEventArgs<LinkedInProfile>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInProfile>(ProfileUrl, operationCompleted, "~");
        }

        public RestOperationCanceler GetUserProfileByIdAsync(string id, Action<RestOperationCompletedEventArgs<LinkedInProfile>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInProfile>(ProfileUrl, operationCompleted, "id=" + id);
        }

        public RestOperationCanceler GetUserFullProfileAsync(Action<RestOperationCompletedEventArgs<LinkedInFullProfile>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInFullProfile>(FullProfileUrl, operationCompleted, "~");
        }

        public RestOperationCanceler GetUserFullProfileByIdAsync(string id, Action<RestOperationCompletedEventArgs<LinkedInFullProfile>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInFullProfile>(FullProfileUrl, operationCompleted, "id=" + id);
        }

#if !WINDOWS_PHONE
        public RestOperationCanceler GetUserProfileByPublicUrlAsync(string url, Action<RestOperationCompletedEventArgs<LinkedInProfile>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInProfile>(ProfileUrl, operationCompleted, "url=" + HttpUtils.UrlEncode(url));
        }

        public RestOperationCanceler GetUserFullProfileByPublicUrlAsync(string url, Action<RestOperationCompletedEventArgs<LinkedInFullProfile>> operationCompleted)
        {
            return this.restTemplate.GetForObjectAsync<LinkedInFullProfile>(FullProfileUrl, operationCompleted, "url=" + HttpUtils.UrlEncode(url));
        }
#endif

        public RestOperationCanceler SearchAsync(SearchParameters searchParams, Action<RestOperationCompletedEventArgs<LinkedInProfiles>> operationCompleted)
        {
            NameValueCollection parameters = BuildSearchParameters(searchParams);
            return this.restTemplate.GetForObjectAsync<LinkedInProfiles>(this.BuildUrl(SearchUrl, parameters), operationCompleted);
        }
#endif

        #endregion

        #region Private Methods

        private static NameValueCollection BuildSearchParameters(SearchParameters searchParams)
        {
            NameValueCollection parameters = new NameValueCollection();
            if (!String.IsNullOrEmpty(searchParams.Keywords))
            {
                parameters.Add("keywords", searchParams.Keywords);
            }
            if (!String.IsNullOrEmpty(searchParams.FirstName))
            {
                parameters.Add("first-name", searchParams.FirstName);
            }
            if (!String.IsNullOrEmpty(searchParams.LastName))
            {
                parameters.Add("last-name", searchParams.LastName);
            }
            if (!String.IsNullOrEmpty(searchParams.CompanyName))
            {
                parameters.Add("company-name", searchParams.CompanyName);
            }
            if (searchParams.IsCurrentCompany.HasValue)
            {
                parameters.Add("current-company", searchParams.IsCurrentCompany.Value.ToString().ToLowerInvariant());
            }
            if (!String.IsNullOrEmpty(searchParams.Title))
            {
                parameters.Add("title", searchParams.Title);
            }
            if (searchParams.IsCurrentTitle.HasValue)
            {
                parameters.Add("current-title", searchParams.IsCurrentTitle.Value.ToString().ToLowerInvariant());
            }
            if (!String.IsNullOrEmpty(searchParams.SchoolName))
            {
                parameters.Add("school-name", searchParams.SchoolName);
            }
            if (searchParams.IsCurrentSchool.HasValue)
            {
                parameters.Add("current-school", searchParams.IsCurrentSchool.Value.ToString().ToLowerInvariant());
            }
            if (!String.IsNullOrEmpty(searchParams.CountryCode))
            {
                parameters.Add("country-code", searchParams.CountryCode.ToLowerInvariant());
            }
            if (!String.IsNullOrEmpty(searchParams.PostalCode))
            {
                parameters.Add("postal-code", searchParams.PostalCode);
            }
            if (searchParams.Distance.HasValue)
            {
                parameters.Add("distance", searchParams.Distance.Value.ToString());
            }
            if (searchParams.Start.HasValue)
            {
                parameters.Add("start", searchParams.Start.Value.ToString());
            }
            if (searchParams.Count.HasValue)
            {
                parameters.Add("count", searchParams.Count.Value.ToString());
            }
            if (searchParams.Sort.HasValue)
            {
                parameters.Add("sort", searchParams.Sort.Value.ToString().ToLowerInvariant());
            }
            return parameters;
        }

        #endregion
    }
}