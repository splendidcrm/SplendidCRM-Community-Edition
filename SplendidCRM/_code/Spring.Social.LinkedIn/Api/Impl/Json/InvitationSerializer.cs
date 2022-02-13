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
    /// JSON serializer for LinkedIn invitation.
    /// </summary>
    /// <author>Bruno Baia</author>
    class InvitationSerializer : IJsonSerializer
    {
        public JsonValue Serialize(object obj, JsonMapper mapper)
        {
            Invitation invitation = (Invitation)obj;

            JsonObject result = new JsonObject();
            result.AddValue("subject", new JsonValue(invitation.Subject));
            result.AddValue("body", new JsonValue(invitation.Body));

            JsonObject recipients = new JsonObject();
            JsonArray people = new JsonArray();
            JsonObject person = new JsonObject();
            if (invitation.Recipient.ID != null)
            {
                person.AddValue("_path", new JsonValue("/people/" + invitation.Recipient.ID));
            }
            else
            {
                person.AddValue("_path", new JsonValue("/people/email=" + invitation.Recipient.Email));
                person.AddValue("first-name", new JsonValue(invitation.Recipient.FirstName));
                person.AddValue("last-name", new JsonValue(invitation.Recipient.LastName));
            }
            JsonObject personValue = new JsonObject();
            personValue.AddValue("person", person);
            people.AddValue(personValue);
            recipients.AddValue("values", people);
            result.AddValue("recipients", recipients);

            JsonObject itemContent = new JsonObject();
            JsonObject request = new JsonObject();
            request.AddValue("connect-type", new JsonValue("friend"));
            if (invitation.Recipient.AuthToken != null)
            {
                string[] authToken = invitation.Recipient.AuthToken.Split(':');
                JsonObject authorization = new JsonObject();
                authorization.AddValue("name", new JsonValue(authToken[0]));
                authorization.AddValue("value", new JsonValue(authToken[1]));
                request.AddValue("authorization", authorization);
            }
            itemContent.AddValue("invitation-request", request);
            result.AddValue("item-content", itemContent);

            return result;
        }
    }
}