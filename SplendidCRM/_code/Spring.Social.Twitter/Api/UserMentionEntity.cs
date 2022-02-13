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
    /// Represents other Twitter users mentioned in the text of the Tweet.
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class UserMentionEntity
    {
        /// <summary>
        /// Gets or sets the position of the '@' character in the Tweet text string. 
        /// </summary>
        public int BeginOffset { get; set; }

        /// <summary>
        /// Gets or sets the position of the first non-screenname character following the user mention.
        /// </summary>
        public int EndOffset { get; set; }

        /// <summary>
        /// Gets or sets the ID of the mentioned user.
        /// </summary>
        public long ID { get; set; }

        /// <summary>
        /// Gets or sets the screen name of the mentioned user.
        /// </summary>
        public string ScreenName { get; set; }

        /// <summary>
        /// Gets or sets the display name of the mentioned user.
        /// </summary>
        public string Name { get; set; }
    }
}
