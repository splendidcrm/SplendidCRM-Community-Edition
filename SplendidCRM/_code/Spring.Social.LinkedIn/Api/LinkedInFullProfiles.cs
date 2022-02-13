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
    /// Represents the results of a LinkedIn profile search.
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
	// 04/10/2012 Paul.  We need a new deserializer for the full profile. 
    public class LinkedInFullProfiles : PaginatedResult 
    {
        /// <summary>
        /// Gets or sets the list of matching <see cref="LinkedInProfile"/>s.
        /// </summary>
        public IList<LinkedInFullProfile> Profiles { get; set; }
    }
}
