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

using Spring.Json;

namespace Spring.Social.LinkedIn.Api.Impl.Json
{
    /// <summary>
    /// JSON deserializer for LinkedIn paginated result sets.
    /// </summary>
    /// <author>Bruno Baia</author>
    abstract class PaginatedResultDeserializer : IJsonDeserializer
    {
        public virtual object Deserialize(JsonValue json, JsonMapper mapper)
        {
            PaginatedResult paginatedResult = this.CreatePaginatedResult();

            paginatedResult.Total = json.GetValue<int>("_total");
            paginatedResult.Start = json.ContainsName("_start") ? json.GetValue<int>("_start") : 0;
            paginatedResult.Count = json.ContainsName("_count") ? json.GetValue<int>("_count") : paginatedResult.Total;            

            return paginatedResult;
        }

        protected abstract PaginatedResult CreatePaginatedResult();
    }
}