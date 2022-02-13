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

namespace Spring.Social.Twitter.Api
{
    /// <summary>
    /// Represents the results of a Twitter search, 
    /// including matching <see cref="Tweet"/>s and any metadata associated with that search.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class SearchResults
    {
        /// <summary>
        /// Gets or sets the list of matching <see cref="Tweet"/>s.
        /// </summary>
        public IList<Tweet> Tweets { get; set; }

        /// <summary>
        /// Gets or sets the maximum <see cref="Tweet"/> ID in the search results
        /// </summary>
        public long MaxId { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="Tweet"/> ID after which all of the matching <see cref="Tweet"/>s were created.
        /// </summary>
        public long SinceId { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not this is the last page of matching <see cref="Tweet"/>s.
        /// </summary>
        public bool IsLastPage { get; set; }
    }
}
