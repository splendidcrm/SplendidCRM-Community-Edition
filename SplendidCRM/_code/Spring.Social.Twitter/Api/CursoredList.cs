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
    // https://dev.twitter.com/docs/misc/cursoring

    /// <summary>
    /// Represents the list that includes previous and next cursors for paging through items returned from Twitter in cursored pages.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class CursoredList<T> : List<T>
    {
        /// <summary>
        /// Gets or sets the cursor to retrieve the previous page of results.
        /// </summary>
        public long PreviousCursor { get; set; }

        /// <summary>
        /// Gets or sets the cursor to retrieve the next page of results.
        /// </summary>
        public long NextCursor { get; set; }

        /// <summary>
        /// Gets a value indicating whether or not there is a previous page of results.
        /// </summary>
        public bool HasPrevious
        {
            get
            {
                return this.PreviousCursor > 0L;
            }
        }

        /// <summary>
        /// Gets a value indicating whether or not there is a next page of results.
        /// </summary>
        public bool HasNext
        {
            get
            {
                return this.NextCursor > 0L;
            }
        }
    }
}
