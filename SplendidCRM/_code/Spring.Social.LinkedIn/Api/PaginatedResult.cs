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

namespace Spring.Social.LinkedIn.Api
{
    /// <summary>
    /// Abstract class for paginated result sets.
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public abstract class PaginatedResult
    {
        /// <summary>
        /// Gets or sets the start location within the result set for paginated returns.
        /// <para/>
        /// This is the zero-based ordinal number of the search return, not the number of the page.
        /// </summary>
        public int Start { get; set; }

        /// <summary>
        /// Gets or sets the number of results to return.
        /// </summary>
        public int Count { get; set; }

        /// <summary>
        /// Gets or sets the total number of results available.
        /// </summary>
        public int Total { get; set; }
    }
}
