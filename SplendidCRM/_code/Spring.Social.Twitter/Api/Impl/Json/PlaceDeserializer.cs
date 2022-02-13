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
    /// JSON deserializer for places. 
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class PlaceDeserializer : IJsonDeserializer
    {
        public object Deserialize(JsonValue json, JsonMapper mapper)
        {
            Place place = new Place();
            place.ID = json.GetValue<string>("id");
            place.Name = json.GetValue<string>("name");
            place.FullName = json.GetValue<string>("full_name");
            JsonValue attributesValue = json.GetValue("attributes");
            if (attributesValue != null)
            {
                place.StreetAddress = attributesValue.GetValueOrDefault<string>("street_address");
            }
            place.Country = json.GetValue<string>("country");
            place.CountryCode = json.GetValue<string>("country_code");
            place.PlaceType = (PlaceType)Enum.Parse(typeof(PlaceType), json.GetValue<string>("place_type"), true);
            return place;
        }
    }
}