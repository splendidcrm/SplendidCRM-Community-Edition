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

namespace Spring.Social.LinkedIn.Api.Impl.Json
{
    /// <summary>
    /// JSON deserializer for LinkedIn user's profile.
    /// </summary>
    /// <author>Bruno Baia</author>
    class LinkedInProfilesDeserializer : PaginatedResultDeserializer
    {
        public override object Deserialize(JsonValue json, JsonMapper mapper)
        {
            JsonValue peopleJson = json.ContainsName("people") ? json.GetValue("people") : json;
            LinkedInProfiles profiles = (LinkedInProfiles)base.Deserialize(peopleJson, mapper);
            profiles.Profiles = mapper.Deserialize<IList<LinkedInProfile>>(peopleJson);
            return profiles;
        }

        protected override PaginatedResult CreatePaginatedResult()
        {
            return new LinkedInProfiles();
        }
    }
}