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
    /// Carries optional metadata pertaining to a Twitter status update.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class StatusDetails
    {
        /// <summary>
        /// Gets or sets the ID of an existing status that this status is in reply to. 
        /// Will be ignored unless the text of this status includes the author of the existing status (e.g., "@author"). 
        /// </summary>
        public long? InReplyToStatusId { get; set; }

        /// <summary>
        /// Gets or sets the location of the status update in latitude. 
        /// Latitude values must be between -90.0 (south) and +90.0 (north).
        /// </summary>
        public float? Latitude { get; set; }

        /// <summary>
        /// Gets or sets the location of the status update in longitude. 
        /// Longitude values must be between -180.0 (west) and +180.0 (east).
        /// </summary>
        public float? Longitude { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not Twitter should pinpoint the location precisely when displaying it on a map. 
        /// </summary>
        /// <remarks>
        /// By default, Twitter will display the status along with a map showing the general area where the tweet came from. 
        /// If display coordinates is true, however, it will display a map with a pin indicating the precise location of the status update.
        /// </remarks>
        public bool DisplayCoordinates { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether or not any valid URL found in the body 
        /// will automatically be wrapped with the Twitter's 't.co' link wrapper.
        /// </summary>
        public bool WrapLinks { get; set; }
    }
}
