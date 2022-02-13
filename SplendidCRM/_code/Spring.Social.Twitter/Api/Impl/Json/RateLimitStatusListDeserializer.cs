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

namespace Spring.Social.Twitter.Api.Impl.Json
{
    /// <summary>
    /// JSON deserializer for rate limits. 
    /// </summary>
    /// <author>Bruno Baia</author>
    class RateLimitStatusListDeserializer : IJsonDeserializer
    {
        public object Deserialize(JsonValue value, JsonMapper mapper)
        {
            IList<RateLimitStatus> limits = new List<RateLimitStatus>();
            JsonValue resourcesValue = value.GetValue("resources");
            if (resourcesValue != null)
            {
                foreach(string resourceFamily in resourcesValue.GetNames())
                {
                    JsonValue resourceFamilyValue = resourcesValue.GetValue(resourceFamily);
                    foreach (string resourceEndpoint in resourceFamilyValue.GetNames())
                    {
                        JsonValue rateLimitValue = resourceFamilyValue.GetValue(resourceEndpoint);
                        limits.Add(new RateLimitStatus()
                            {
                                ResourceFamily = resourceFamily,
                                ResourceEndpoint = resourceEndpoint,
                                WindowLimit = rateLimitValue.GetValue<int>("limit"),
                                RemainingHits = rateLimitValue.GetValue<int>("remaining"),
                                ResetTime = FromUnixTime(rateLimitValue.GetValue<long>("reset"))
                            });
                    }
                }
            }
            return limits;
        }

        // epoch time : http://en.wikipedia.org/wiki/Unix_time
        private static DateTime FromUnixTime(long unixTime)
        {
            var epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            return epoch.AddSeconds(unixTime);
        }
    }
}