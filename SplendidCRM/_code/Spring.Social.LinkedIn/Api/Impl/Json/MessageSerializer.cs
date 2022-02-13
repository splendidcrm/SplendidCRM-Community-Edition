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
    /// JSON serializer for LinkedIn message.
    /// </summary>
    /// <author>Bruno Baia</author>
    class MessageSerializer : IJsonSerializer
    {
        public JsonValue Serialize(object obj, JsonMapper mapper)
        {
            Message message = (Message)obj;

            JsonObject result = new JsonObject();
            result.AddValue("subject", new JsonValue(message.Subject));
            result.AddValue("body", new JsonValue(message.Body));

            JsonObject recipients = new JsonObject();
            JsonArray people = new JsonArray();
            foreach (string id in message.RecipientIds)
            {
                JsonObject person = new JsonObject();
                person.AddValue("_path", new JsonValue("/people/" + id));

                JsonObject personValue = new JsonObject();
                personValue.AddValue("person", person);
                people.AddValue(personValue);
            }
            recipients.AddValue("values", people);
            result.AddValue("recipients", recipients);

            return result;
        }
    }
}