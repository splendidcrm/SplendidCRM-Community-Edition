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

namespace Spring.Social.Twitter.Api.Impl.Json
{
    /// <summary>
    /// JSON deserializer for user-defined lists. 
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class UserListDeserializer : IJsonDeserializer
    {
        private const string DIRECT_MESSAGE_DATE_FORMAT = "ddd MMM dd HH:mm:ss zzz yyyy";

        public object Deserialize(JsonValue json, JsonMapper mapper)
        {
            return new UserList()
            {
                ID = json.GetValue<long>("id"),
                Name = json.GetValue<string>("name"),
                FullName = json.GetValue<string>("full_name"),
                UriPath = json.GetValue<string>("uri"),
                Description = json.GetValue<string>("description"),
                Slug = json.GetValue<string>("slug"),
                IsPublic = (json.GetValue<string>("mode") == "public"),
                IsFollowing = json.GetValue<bool>("following"),
                MemberCount = json.GetValue<int>("member_count"),
                SubscriberCount = json.GetValue<int>("subscriber_count")
            };
        }
    }
}