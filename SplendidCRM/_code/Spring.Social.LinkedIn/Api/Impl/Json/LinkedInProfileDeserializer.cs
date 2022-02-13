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

using Spring.Json;

namespace Spring.Social.LinkedIn.Api.Impl.Json
{
    /// <summary>
    /// JSON deserializer for LinkedIn user's profile.
    /// </summary>
    /// <author>Bruno Baia</author>
    class LinkedInProfileDeserializer : IJsonDeserializer
    {
        private const string AuthTokenHeaderName = "x-li-auth-token";

        public virtual object Deserialize(JsonValue json, JsonMapper mapper)
        {
            LinkedInProfile profile = CreateLinkedInProfile();

            profile.ID = json.GetValue<string>("id");
            profile.FirstName = json.GetValue<string>("firstName");
            profile.LastName = json.GetValue<string>("lastName");
            profile.Headline = json.ContainsName("headline") ? json.GetValue<string>("headline") : "";
            profile.Industry = json.ContainsName("industry") ? json.GetValue<string>("industry") : "";
            profile.PictureUrl = json.ContainsName("pictureUrl") ? json.GetValue<string>("pictureUrl") : null;
            profile.Summary = json.ContainsName("summary") ? json.GetValue<string>("summary") : "";
            profile.PublicProfileUrl = json.ContainsName("publicProfileUrl") ? json.GetValue<string>("publicProfileUrl") : null;
            profile.StandardProfileUrl = GetSiteStandardProfileUrl(json);
            profile.AuthToken = GetAuthToken(json);

            return profile;
        }

        protected virtual LinkedInProfile CreateLinkedInProfile()
        {
            return new LinkedInProfile();
        }

        private string GetSiteStandardProfileUrl(JsonValue json)
        {
            JsonValue siteStandardProfileJson = json.GetValue("siteStandardProfileRequest");
            return siteStandardProfileJson != null ? siteStandardProfileJson.GetValue<string>("url") : null;
        }

        private string GetAuthToken(JsonValue json)
        {
            JsonValue apiStandardProfileJson = json.GetValue("apiStandardProfileRequest");
            if (apiStandardProfileJson != null)
            {
                JsonValue headerValues = apiStandardProfileJson.ContainsName("headers") ? apiStandardProfileJson.GetValue("headers").GetValue("values") : null;
                if (headerValues != null)
                {
                    foreach (JsonValue headerJson in headerValues.GetValues())
                    {
                        if (headerJson.GetValue<string>("name").Equals(AuthTokenHeaderName))
                        {
                            return headerJson.GetValue<string>("value");
                        }
                    }
                }
            }
            return null;
        }
    }
}