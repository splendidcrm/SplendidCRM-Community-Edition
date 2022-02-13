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
    // Code comments from REST API documentation

    /// <summary>
    /// Represents profile search parameters.
    /// </summary>
    /// <author>Robert Drysdale</author>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class SearchParameters
    {
        /// <summary>
        /// Gets or sets the space delimited keywords.
        /// </summary>
        public string Keywords { get; set; }

        /// <summary>
        /// Gets or sets the first name to match exactly.
        /// </summary>
        public string FirstName { get; set; }

        /// <summary>
        /// Gets or sets the last name to match exactly.
        /// </summary>
        public string LastName { get; set; }

        /// <summary>
        /// Gets or sets the company name to match.
        /// <para/>
        /// Can be combined with the IsCurrentCompany property to specify 
        /// whether the person is or is not still working at the company.
        /// </summary>
        public string CompanyName { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether to match members 
        /// who currently work at the company specified in the CompanyName property.
        /// </summary>
        public bool? IsCurrentCompany { get; set; }

        /// <summary>
        /// Gets or sets the profile title to match.
        /// <para/>
        /// Can be combined with the IsCurrentTitle property to specify 
        /// whether the member currently or once had that title.
        /// </summary>
        public string Title { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether to match members 
        /// who currently or once had the title specified in the Title property.
        /// </summary>
        public bool? IsCurrentTitle { get; set; }

        /// <summary>
        /// Gets or sets the school name to match.
        /// <para/>
        /// Can be combined with the IsCurrentSchool property to specify 
        /// whether the member is or is not still at the school.
        /// </summary>
        public string SchoolName { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether to match members 
        /// who currently attend the school specified in the SchoolName property.
        /// </summary>
        public bool? IsCurrentSchool { get; set; }

        /// <summary>
        /// Gets or sets the location in a specific country to match. 
        /// <para/>
        /// Values are defined in by ISO 3166 standard.
        /// </summary>
        public string CountryCode { get; set; }

        /// <summary>
        /// Gets or sets the postal code to match. 
        /// <para/>
        /// Can be combined with the CountryCode property (Not supported for all countries).
        /// </summary>
        public string PostalCode { get; set; }

        /// <summary>
        /// Gets or sets the distance (in miles) from a central point to match. 
        /// <para/>
        /// This is best used in combination with both CountryCode and PostalCode properties.
        /// </summary>
        public int? Distance { get; set; }

        /// <summary>
        /// Gets or sets the start location within the result set for paginated returns.
        /// <para/>
        /// This is the zero-based ordinal number of the search return, not the number of the page.
        /// <para/>
        /// The default value is 0.
        /// </summary>
        public int? Start { get; set; }

        /// <summary>
        /// Gets or sets the number of profiles to return. Values can range between 0 and 25.
        /// <para/>
        /// The default value is 10.
        /// </summary>
        public int? Count { get; set; }

        /// <summary>
        /// Gets or sets the profile search result order.
        /// </summary>
        public ProfileSort? Sort { get; set; }
    }
}
