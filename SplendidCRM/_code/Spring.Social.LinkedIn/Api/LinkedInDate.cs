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

namespace Spring.Social.LinkedIn.Api
{
    /// <summary>
    /// Represents a LinkedIn Date which just contains year, month and day.
    /// </summary>
    /// <author>Robert Drysdale</author>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class LinkedInDate
    {
        /// <summary>
        /// Gets or sets the year component of the date, if provided. 
        /// </summary>
        public int? Year { get; set; }

        /// <summary>
        /// Gets or sets the month component of the date, if provided. 
        /// </summary>
        public int? Month { get; set; }

        /// <summary>
        /// Gets or sets the day component of the date, if provided. 
        /// </summary>
        public int? Day { get; set; }
    }
}
