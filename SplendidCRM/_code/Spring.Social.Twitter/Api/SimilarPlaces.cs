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
using System.Collections.Generic;

namespace Spring.Social.Twitter.Api
{
    /// <summary>
    /// Represents the results of a similar places search.
    /// <para/>
    /// Includes places that match the search criteria and a <see cref="PlacePrototype"/> that can be used to create a new place.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class SimilarPlaces : List<Place>
    {
        /// <summary>
        /// Creates a new instance of the <see cref="SimilarPlaces"/> class.
        /// </summary>
        public SimilarPlaces()
            : base()
        {
        }

        /// <summary>
        /// Creates a new instance of the <see cref="SimilarPlaces"/> class.
        /// </summary>
        /// <param name="places">The collection of places that match the search criteria.</param>
        public SimilarPlaces(IEnumerable<Place> places)
            : base(places)
        {
        }

        /// <summary>
        /// A prototype place that matches the criteria for the call to FindSimilarPlaces(double, double, string), 
        /// including a create token that can be used to create the place.
        /// </summary>
        public PlacePrototype PlacePrototype { get; set; }
    }
}
