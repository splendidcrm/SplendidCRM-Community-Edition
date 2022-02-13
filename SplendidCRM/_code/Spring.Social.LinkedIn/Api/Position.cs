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
    /// Represents a LinkedIn user's position.
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class Position
    {
        /// <summary>
        /// Gets or sets the unique identifier for the position.
        /// </summary>
        public string ID { get; set; }

        /// <summary>
        /// Gets or sets the company the member works for.
        /// </summary>
        public Company Company { get; set; }

        /// <summary>
        /// Gets or sets the job title held at the position, as indicated by the member.
        /// </summary>
        public string Title { get; set; }

        /// <summary>
        /// Gets or sets the summary of the member's position.
        /// </summary>
        public string Summary { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether the member currently holds that position.
        /// </summary>
        public bool IsCurrent { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="LinkedInDate"/> with month and year fields 
        /// indicating when the position began.
        /// </summary>
        public LinkedInDate StartDate { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="LinkedInDate"/> with month and year fields 
        /// indicating when the position ended.
        /// </summary>
        public LinkedInDate EndDate { get; set; }
    }
}
