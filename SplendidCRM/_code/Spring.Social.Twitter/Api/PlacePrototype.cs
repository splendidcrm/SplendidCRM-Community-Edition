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
    /// Represents a new place that could be created. 
    /// </summary>
    /// This is the type returned from calls to FindSimilarPlaces(double, double, string).
    /// <para/>
    /// It is the only type that can be given to CreatePlace(PlacePrototype) to create a new place.
    /// <para/>
    /// This guarantees consistency between the query performed when finding similar places 
    /// and when creating a new place so that the create token will be valid. 
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class PlacePrototype
    {
        /// <summary>
        /// Gets or sets the token that is required for creating a new place.
        /// </summary>
        public string CreateToken { get; set; }

        /// <summary>
        /// Gets or sets the latitude.
        /// </summary>
        public double Latitude { get; set; }

        /// <summary>
        /// Gets or sets the longitude.
        /// </summary>
        public double Longitude { get; set; }

        /// <summary>
        /// Gets or sets the name that the place is known as.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the ID of the place that the place is contained within.
        /// </summary>
        public string ContainedWithin { get; set; }

        /// <summary>
        /// Gets or sets the place's street address.
        /// </summary>
        public string StreetAddress { get; set; }
    }
}
