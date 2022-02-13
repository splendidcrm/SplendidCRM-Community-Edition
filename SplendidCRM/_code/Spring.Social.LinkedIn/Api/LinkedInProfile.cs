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

namespace Spring.Social.LinkedIn.Api
{
    /// <summary>
    /// Represents a LinkedIn user's profile information.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class LinkedInProfile 
    {
        /// <summary>
        /// Gets or sets the user's LinkedIn ID.
        /// </summary>
        public string ID { get; set; }

        /// <summary>
        /// Gets or sets the user's first name.
        /// </summary>
        public string FirstName { get; set; }

        /// <summary>
        /// Gets or sets the user's last name.
        /// </summary>
        public string LastName { get; set; }

        /// <summary>
        /// Gets or sets the user's headline.
        /// </summary>
        public string Headline { get; set; }

        /// <summary>
        /// Gets or sets the user's industry.
        /// </summary>
        public string Industry { get; set; }

        /// <summary>
        /// Gets or sets a URL to the user's profile picture.
        /// </summary>
        public string PictureUrl { get; set; }

        /// <summary>
        /// Gets or sets the user's summary.
        /// </summary>
        public string Summary { get; set; }

        /// <summary>
        /// Gets or sets a URL to the user's public profile. 
        /// <para/>
        /// The content shown at this profile is intended for public display and is determined by the user's privacy settings.
        /// <para/>
        /// May be null if the user's profile isn't public.
        /// </summary>
        public string PublicProfileUrl { get; set; }

        /// <summary>
        /// Gets or sets a URL to the user's authenticated profile.
        /// <para/>
        /// Requires a login to be viewed, unlike public profile url and 
        /// the content shown at this profile will depend upon what the requesting user is allowed to see.
        /// </summary>
        public string StandardProfileUrl { get; set; }

        /// <summary>
        /// Gets or sets an authentication token required by some API calls.
        /// </summary>
        public string AuthToken { get; set; }
    }
}
