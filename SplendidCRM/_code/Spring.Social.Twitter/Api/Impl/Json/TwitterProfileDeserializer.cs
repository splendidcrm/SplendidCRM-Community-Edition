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
using System.Globalization;

using Spring.Json;

namespace Spring.Social.Twitter.Api.Impl.Json
{
    /// <summary>
    /// JSON deserializer for Twitter user's profile.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    class TwitterProfileDeserializer : IJsonDeserializer
    {
        private const string DATE_FORMAT = "ddd MMM dd HH:mm:ss zzz yyyy";

        public object Deserialize(JsonValue value, JsonMapper mapper)
        {
            return new TwitterProfile()
            {
                ID = value.GetValue<long>("id"),
                ScreenName = value.GetValueOrDefault<string>("screen_name"),
                Name = value.GetValueOrDefault<string>("name"),
                Url = value.GetValueOrDefault<string>("url"),
                ProfileImageUrl = value.GetValueOrDefault<string>("profile_image_url"),
                Description = value.GetValueOrDefault<string>("description", String.Empty),
                Location = value.GetValueOrDefault<string>("location", String.Empty),
                CreatedDate = JsonUtils.ToDateTime(value.GetValueOrDefault<string>("created_at"), DATE_FORMAT),
                IsNotificationsEnabled = value.GetValueOrDefault<bool>("notifications"),
                Language = value.GetValueOrDefault<string>("lang"),
                StatusesCount = value.GetValueOrDefault<int>("statuses_count"),
                FriendsCount = value.GetValueOrDefault<int>("friends_count"),
                FollowersCount = value.GetValueOrDefault<int>("followers_count"),
                FavoritesCount = value.GetValueOrDefault<int>("favourites_count"),
                ListedCount = value.GetValueOrDefault<int>("listed_count"),
                IsFollowing = value.GetValueOrDefault<bool>("following"),
                IsFollowRequestSent = value.GetValueOrDefault<bool>("follow_request_sent"),
                IsProtected = value.GetValueOrDefault<bool>("protected"),
                IsVerified = value.GetValueOrDefault<bool>("verified"),
                IsGeoEnabled = value.GetValueOrDefault<bool>("geo_enabled"),
                IsContributorsEnabled = value.GetValueOrDefault<bool>("contributors_enabled"),
                IsTranslator = value.GetValueOrDefault<bool>("is_translator"),
                TimeZone = value.GetValueOrDefault<string>("time_zone"),
                UtcOffset = value.GetValueOrDefault<int>("utc_offset"),
                UseBackgroundImage = value.GetValueOrDefault<bool>("profile_use_background_image"),
                SidebarBorderColor = value.GetValueOrDefault<string>("profile_sidebar_border_color"),
                SidebarFillColor = value.GetValueOrDefault<string>("profile_sidebar_fill_color"),
                BackgroundColor = value.GetValueOrDefault<string>("profile_background_color"),
                BackgroundImageUrl = value.GetValueOrDefault<string>("profile_background_image_url"),
                IsBackgroundImageTiled = value.GetValueOrDefault<bool>("profile_background_tile"),
                TextColor = value.GetValueOrDefault<string>("profile_text_color"),
                LinkColor = value.GetValueOrDefault<string>("profile_link_color"),
                ShowAllInlineMedia = value.GetValueOrDefault<bool>("show_all_inline_media"),
            };
        }
    }
}