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
    /// Represents a Twitter user's profile information.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class TwitterProfile 
    {
        /// <summary>
        /// Gets or sets the user's Twitter ID
        /// </summary>
	    public long ID { get; set; }

        /// <summary>
        /// Gets or sets the user's Twitter screen name.
        /// </summary>
        public string ScreenName { get; set; }

        /// <summary>
        /// Gets or sets the user's display name.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the user's URL.
        /// </summary>
        public string Url { get; set; }

        /// <summary>
        /// Gets or sets the URL of the user's profile.
        /// </summary>
        public string ProfileUrl
        {
            get { return "http://twitter.com/" + this.ScreenName; }
        }

        /// <summary>
        /// Gets or sets the URL of the user's profile image in "normal" size (48x48).
        /// </summary>
        public string ProfileImageUrl { get; set; }

        /// <summary>
        /// Gets or sets the user's description
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets the user's location.
        /// </summary>
        public string Location { get; set; }

        /// <summary>
        /// Gets or sets the date that the Twitter profile was created.
        /// </summary>
        public DateTime? CreatedDate { get; set; }

        /// <summary>
        /// Gets or sets the user's preferred language.
        /// </summary>
        public string Language { get; set; }

        /// <summary>
        /// Gets or sets the number of tweets this user has posted.
        /// </summary>
        public int StatusesCount { get; set; }

        /// <summary>
        /// Gets or sets the number of friends the user has (the number of users this user follows).
        /// </summary>
        public int FriendsCount { get; set; }

        /// <summary>
        /// Gets or sets the number of followers the user has.
        /// </summary>
        public int FollowersCount { get; set; }

        /// <summary>
        /// Gets or sets the number of tweets that the user has marked as favorites.
        /// </summary>
        public int FavoritesCount { get; set; }

        /// <summary>
        /// Gets or sets the number of lists the user is listed on.
        /// </summary>
        public int ListedCount { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not the authenticated user is following this user.
        /// </summary>
        public bool IsFollowing { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not a request has been sent by the authenticating user to follow this user.
        /// </summary>
        public bool IsFollowRequestSent { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not the user's tweets are protected.
        /// </summary>
        public bool IsProtected { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not the user has mobile notifications enabled.
        /// </summary>
        public bool IsNotificationsEnabled { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not the user is verified with Twitter.
        /// </summary>
        /// <remarks>
        /// See http://support.twitter.com/groups/31-twitter-basics/topics/111-features/articles/119135-about-verified-accounts.
        /// </remarks>
        public bool IsVerified { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not the user has enabled their account with geo location.
        /// </summary>
        public bool IsGeoEnabled { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not this profile is enabled for contributors. 
        /// </summary>
        public bool IsContributorsEnabled { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not this user is a translator. 
        /// </summary>
        public bool IsTranslator { get; set; }

        /// <summary>
        /// Gets or sets the user's time zone. 
        /// </summary>
        public string TimeZone { get; set; }

        /// <summary>
        /// Gets or sets the user's UTC offset in seconds.
        /// </summary>
        public int UtcOffset { get; set; }

        /// <summary>
        /// Gets or sets the color of the sidebar border on the user's Twitter profile page.
        /// </summary>
        public string SidebarBorderColor { get; set; }

        /// <summary>
        /// Gets or sets the color of the sidebar fill on the user's Twitter profile page.
        /// </summary>
        public string SidebarFillColor { get; set; }

        /// <summary>
        /// Gets or sets the color of the background of the user's Twitter profile page.
        /// </summary>
        public string BackgroundColor { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not the user's Twitter profile page uses a background image.
        /// </summary>
        public bool UseBackgroundImage { get; set; }

        /// <summary>
        /// Gets or sets the URL to a background image shown on the user's Twitter profile page.
        /// </summary>
        public string BackgroundImageUrl { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not the background image is tiled.
        /// </summary>
        public bool IsBackgroundImageTiled { get; set; }

        /// <summary>
        /// Gets or sets the text color on the user's Twitter profile page.
        /// </summary>
        public string TextColor { get; set; }

        /// <summary>
        /// Gets or sets the link color on the user's Twitter profile page.
        /// </summary>
        public string LinkColor { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not the user has selected to see all inline media from everyone. 
        /// If false, they will only see inline media from the users they follow.
        /// </summary>
        public bool ShowAllInlineMedia { get; set; }
    }
}
