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
    /// Represents media elements uploaded with the Tweet.
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class MediaEntity
    {
        /// <summary>
        /// Gets or sets the position of the first character of the media URL in the Tweet text.
        /// </summary>
        public int BeginOffset { get; set; }

        /// <summary>
        /// Gets or sets the position of the first non-URL character occurring after the media URL 
        /// (or the end of the string if the URL is the last part of the Tweet text).
        /// </summary>
        public int EndOffset { get; set; }

        /// <summary>
        /// Gets or sets the ID of the media.
        /// </summary>
        public long ID { get; set; }

        /// <summary>
        /// Gets or sets the extracted media URL, corresponding to the value embedded directly into the raw Tweet text.
        /// </summary>
        public string Url { get; set; }

        /// <summary>
        /// Gets or sets the string to display instead of the media URL.
        /// </summary>
        public string DisplayUrl { get; set; }

        /// <summary>
        /// Gets or sets the fully resolved media URL.
        /// </summary>
        public string ExpandedUrl { get; set; }

        /// <summary>
        /// Gets or sets the URL of the media file.
        /// </summary>
        public string MediaUrl { get; set; }

        /// <summary>
        /// Gets or sets the SSL URL of the media file.
        /// </summary>
        public string MediaHttpsUrl { get; set; }

        /// <summary>
        /// Gets or sets the original Tweet ID if the media was originally associated with a different tweet.
        /// </summary>
        public long? SourceStatusId { get; set; }
    }
}
