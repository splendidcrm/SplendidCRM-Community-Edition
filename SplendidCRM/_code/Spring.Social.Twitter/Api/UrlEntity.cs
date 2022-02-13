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

namespace Spring.Social.Twitter.Api
{
    /// <summary>
    /// Represents URLs included in the text of a Tweet.
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class UrlEntity
    {
        /// <summary>
        /// Gets or sets the position of the first character of the URL in the Tweet text.
        /// </summary>
        public int BeginOffset { get; set; }

        /// <summary>
        /// Gets or sets the position of the first non-URL character after the end of the URL.
        /// </summary>
        public int EndOffset { get; set; }

        /// <summary>
        /// Gets or sets the extracted URL, corresponding to the value embedded directly into the raw Tweet text.
        /// </summary>
        public string Url { get; set; }

        /// <summary>
        /// Gets or sets the string to display instead of the URL.
        /// </summary>
        public string DisplayUrl { get; set; }

        /// <summary>
        /// Gets or sets the fully resolved URL.
        /// </summary>
        public string ExpandedUrl { get; set; }
    }
}
