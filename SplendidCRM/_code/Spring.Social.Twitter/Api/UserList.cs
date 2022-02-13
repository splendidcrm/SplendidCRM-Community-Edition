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
    /// Represents a user-defined list.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class UserList
    {
        /// <summary>
        /// Gets or sets the user-defined list ID.
        /// </summary>
        public long ID { get; set; }

        /// <summary>
        /// Gets or sets the user-defined list name.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the user-defined list full name.
        /// </summary>
        public string FullName { get; set; }

        /// <summary>
        /// Gets or sets the user-defined list path.
        /// </summary>
        public string UriPath { get; set; }

        /// <summary>
        /// Gets or sets the user-defined description.
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets the user-defined slug.
        /// </summary>
        public string Slug { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not the user-defined list is public.
        /// </summary>
        public bool IsPublic { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not the authenticated user is following the user-defined list.
        /// </summary>
        public bool IsFollowing { get; set; }

        /// <summary>
        /// Gets or sets the number of members of the user-defined list name.
        /// </summary>
        public int MemberCount { get; set; }

        /// <summary>
        /// Gets or sets the number of subscribers of the user-defined list name.
        /// </summary>
        public int SubscriberCount { get; set; }
    }
}
