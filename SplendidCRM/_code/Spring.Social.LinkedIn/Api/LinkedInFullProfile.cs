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
    /// Represents a LinkedIn full user's profile information.
    /// </summary>
    /// <author>Bruno Baia</author>
    /// <author>Robert Drysdale</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class LinkedInFullProfile : LinkedInProfile
    {
        /// <summary>
        /// Gets or sets the collection of positions a member has had.
        /// </summary>
        public IList<Position> Positions { get; set; }

        /// <summary>
        /// Gets or sets the collection of positions a member currently holds, limited to three.
        /// </summary>
        public IList<Position> ThreeCurrentPositions { get; set; }

        /// <summary>
        /// Gets or sets the collection of positions a member formerly held, limited to the three most recent
        /// </summary>
        public IList<Position> ThreePastPositions { get; set; }

        /// <summary>
        /// Gets or sets the collection of recommendations a member has received. 
        /// </summary>
        public IList<Recommendation> Recommendations { get; set; }

        /// <summary>
        /// Gets or sets the collection of instant messenger accounts.
        /// </summary>
        public IList<ImAccount> ImAccounts { get; set; }

        /// <summary>
        /// Gets or sets the collection of Twitter accounts.
        /// </summary>
        public IList<TwitterAccount> TwitterAccounts { get; set; }

        /// <summary>
        /// Gets or sets the collection of URLs the member has chosen to share on their LinkedIn profile.
        /// </summary>
        public IList<LinkedInUrl> UrlResources { get; set; }

        /// <summary>
        /// Gets or sets the collection of phone numbers. 
        /// </summary>
        public IList<PhoneNumber> PhoneNumbers { get; set; }

        /// <summary>
        /// Gets or sets the collection of skills held by this member.
        /// </summary>
        public IList<string> Skills { get; set; }

        /// <summary>
        /// Gets or sets the collection of education institutions a member has attended.
        /// </summary>
        public IList<Education> Educations { get; set; }

        /// <summary>
        /// Gets or sets the short-form text area describing how the member approaches proposals.
        /// </summary>
        public string ProposalComments { get; set; }

        /// <summary>
        /// Gets or sets the short-form text area where the member enumerates their specialties.
        /// </summary>
        public string Specialties { get; set; }

        /// <summary>
        /// Gets or sets the number of connections the member has.
        /// </summary>
        public int ConnectionsCount { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether the number of connections has been capped at 500.
        /// </summary>
        public bool IsConnectionsCountCapped { get; set; }

        /// <summary>
        /// Gets or sets the number of recommendations the member has.
        /// </summary>
        public int? RecommendersCount { get; set; }

        /// <summary>
        /// Gets or sets the member's main address. Could be home, work, etc.
        /// </summary>
        public string MainAddress { get; set; }

        /// <summary>
        /// Gets or sets the short-form text area enumerating the associations a member has.
        /// </summary>
        public string Associations { get; set; }

        /// <summary>
        /// Gets or sets the generic name of the location of the LinkedIn member.
        /// </summary>
        public string Location { get; set; }

        /// <summary>
        /// Gets or sets the country code (ISO 3166-1 alpha-2 standard) for the LinkedIn member.
        /// </summary>
        public string CountryCode { get; set; }

        /// <summary>
        /// Gets or sets the short-form text area describing the member's interests.
        /// </summary>
        public string Interests { get; set; }

        /// <summary>
        /// Gets or sets a short-form text area describing what Honors the member may have.
        /// </summary>
        public string Honors { get; set; }

        /// <summary>
        /// Gets or sets the degree distance of the fetched profile from the member who fetched the profile.
        /// </summary>
        /// <remarks>
        /// Possible values are:
        /// <list type="bullet">
        /// <item>description>0: the member</item>
        /// <item>1, 2, and 3: # of degrees apart</item>
        /// <item>-1: out of network</item>
        /// <item>100: share a group, but not within 3 degrees (will get 1-3 instead)</item>
        /// </list>
        /// </remarks>
        public int Distance { get; set; }

        /// <summary>
        /// Gets or sets the member's birth date.
        /// <para/>
        /// May return only month and day, but not year, or all three, depending on information provided.
        /// </summary>
        public LinkedInDate BirthDate { get; set; }

/*
        /// <summary>
        /// Gets or sets the member's current share, if set.
        /// </summary>
        public CurrentShare CurrentShare { get; set; }
 */
    }
}
