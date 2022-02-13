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
    /// Represents a place that a Twitter user may send a tweet from.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class Place
    {
        /// <summary>
        /// Gets or sets the place id.
        /// </summary>
        public string ID { get; set; }

        /// <summary>
        /// Gets or sets the name that the place is known as.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the place full name.
        /// </summary>
        public string FullName { get; set; }

        /// <summary>
        /// Gets or sets the place's street address.
        /// </summary>
        public string StreetAddress { get; set; }

        /// <summary>
        /// Gets or sets the place country.
        /// </summary>
        public string Country { get; set; }

        /// <summary>
        /// Gets or sets the place country code.
        /// </summary>
        public string CountryCode { get; set; }

        /// <summary>
        /// Gets or sets the type of the place.
        /// </summary>
        public PlaceType PlaceType { get; set; }
    }
}
