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
    /// JSON deserializer for direct messages. 
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class DirectMessageDeserializer : IJsonDeserializer
    {
        private const string DIRECT_MESSAGE_DATE_FORMAT = "ddd MMM dd HH:mm:ss zzz yyyy";

        public object Deserialize(JsonValue json, JsonMapper mapper)
        {
            return new DirectMessage()
            {
                ID = json.GetValue<long>("id"),
                Text = json.GetValue<string>("text"),
                Sender = mapper.Deserialize<TwitterProfile>(json.GetValue("sender")),
                Recipient = mapper.Deserialize<TwitterProfile>(json.GetValue("recipient")),
                CreatedAt = JsonUtils.ToDateTime(json.GetValue<string>("created_at"), DIRECT_MESSAGE_DATE_FORMAT)
            };
        }
    }
}