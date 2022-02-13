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
    /// Represents a suggested user category. 
    /// A category of users that Twitter may suggest that a user follow.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class SuggestionCategory
    {
        /// <summary>
        /// Gets or sets the suggested user category name.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the short name of a category.
        /// </summary>
        public string Slug { get; set; }

        /// <summary>
        /// Gets or sets the number of users from the suggested user category.
        /// </summary>
        public int Size { get; set; }
    }
}
