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
    /// Represents a Twitter status update (e.g., a "tweet").
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class Tweet
    {
        /// <summary>
        /// Gets or sets the tweet ID.
        /// </summary>
        public long ID { get; set; }

        /// <summary>
        /// Gets or sets the tweet message.
        /// </summary>
        public string Text { get; set; }

        /// <summary>
        /// Gets or sets the tweet created date.
        /// </summary>
        public DateTime? CreatedAt { get; set; }

        /// <summary>
        /// Gets or sets the tweet author's ID.
        /// </summary>
        [Obsolete("Use 'User.ID' instead.")]
        public long FromUserId { get; set; }

        /// <summary>
        /// Gets or sets the tweet author's screen name.
        /// </summary>
        [Obsolete("Use 'User.ScreenName' instead.")]
        public string FromUser { get; set; }

        /// <summary>
        /// Gets or sets the tweet author's profile image URL.
        /// </summary>
        [Obsolete("Use 'User.ProfileImageUrl' instead.")]
        public string ProfileImageUrl { get; set; }

        /// <summary>
        /// Gets or sets the user who posted the tweet. 
        /// </summary>
        public TwitterProfile User { get; set; }

        /// <summary>
        /// Gets or sets the user ID when replying to a user.
        /// </summary>
        [Obsolete("Use 'InReplyToUserId' instead.")]
        public long? ToUserId { get; set; }

        /// <summary>
        /// Gets or sets the user ID when replying to a user.
        /// </summary>
        public long? InReplyToUserId { get; set; }

        /// <summary>
        /// Gets or sets the user screen name when replying to a user.
        /// </summary>
        public string InReplyToUserScreenName { get; set; }

        /// <summary>
        /// Gets or sets the tweet ID when replying to a tweet.
        /// </summary>
        public long? InReplyToStatusId { get; set; }

        /// <summary>
        /// Gets or sets the tweet's language code.
        /// </summary>
        public string LanguageCode { get; set; }

        /// <summary>
        /// Gets or sets the source from where the tweet was send.
        /// </summary>
        public string Source { get; set; }

        /// <summary>
        /// Gets or sets the place that the tweet is associated to (but not necessarily originating from).
        /// </summary>
        public Place Place { get; set; }

        /// <summary>
        /// Gets or sets the number of times this tweet has been retweeted.
        /// </summary>
        public int RetweetCount { get; set; }

        /// <summary>
        /// Gets or sets the number of times this tweet has been favorited.
        /// </summary>
        public int FavoriteCount { get; set; }

        /// <summary>
        /// Gets or sets the original tweet when this is a retweet.
        /// </summary>
        public Tweet RetweetedStatus { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this tweet has been retweeted by the authenticating user.
        /// </summary>
        public bool IsRetweetedByUser { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this tweet has been favorited by the authenticating user.
        /// </summary>
        public bool IsFavoritedByUser { get; set; }

        /// <summary>
        /// Gets or sets the tweet ID of the authenticating user's own retweet.
        /// </summary>
        public long? RetweetIdByUser { get; set; }

        /// <summary>
        /// Gets or sets the metadata and additional contextual information 
        /// which have been parsed out of the text of the tweet.
        /// </summary>
        public TweetEntities Entities { get; set; }
    }
}
