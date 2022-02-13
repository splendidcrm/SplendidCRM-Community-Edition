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
    /// Represents an education details for a Profile on LinkedIn.
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class Education
    {
        /// <summary>
        /// Gets or sets the unique identifier for the education entry.
        /// </summary>
        public int ID { get; set; }

        /// <summary>
        /// Gets or sets the name of the school, as indicated by the member.
        /// </summary>
        public string SchoolName { get; set; }

        /// <summary>
        /// Gets or sets the field of study at the school, as indicated by the member.
        /// </summary>
        public string StudyField { get; set; }

        /// <summary>
        /// Gets or sets the year indicating when the education began.
        /// </summary>
        public LinkedInDate StartDate { get; set; }

        /// <summary>
        /// Gets or sets the year indicating when the education ended, 
        /// or <see langword="null"/> when the education is current.
        /// </summary>
        public LinkedInDate EndDate { get; set; }

        /// <summary>
        /// Gets or sets the degree, if any, received at this institution.
        /// </summary>
        public string Degree { get; set; }

        /// <summary>
        /// Gets or sets a value describing activities the member was involved in 
        /// while a student at this institution.
        /// </summary>
        public string Activities { get; set; }

        /// <summary>
        /// Gets or sets other details on the member's studies.
        /// </summary>
        public string Notes { get; set; }
    }
}
