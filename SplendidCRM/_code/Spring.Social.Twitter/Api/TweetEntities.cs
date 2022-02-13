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
    /// Represents the metadata and additional contextual information found within Twitter status update (e.g., a "tweet").
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class TweetEntities
    {
        /// <summary>
        /// Gets or sets the hashtags extracted from the Tweet text.
        /// </summary>
        public IList<HashtagEntity> Hashtags { get; set; }

        /// <summary>
        /// Gets or sets the user screen names extracted from the Tweet text.
        /// </summary>
        public IList<UserMentionEntity> UserMentions { get; set; }

        /// <summary>
        /// Gets or sets the URLs extracted from the Tweet text.
        /// </summary>
        public IList<UrlEntity> Urls { get; set; }

        /// <summary>
        /// Gets or sets the list of media extracted from the Tweet text.
        /// </summary>
        public IList<MediaEntity> Media { get; set; }
    }
}
