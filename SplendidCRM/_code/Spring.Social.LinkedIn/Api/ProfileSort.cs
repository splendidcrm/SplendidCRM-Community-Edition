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
    /// Defines the profile search result order.
    /// </summary>
    /// <author>Bruno Baia</author>
    public enum ProfileSort
    {
        /// <summary>
        /// Number of connections per person, from largest to smallest. Default value.
        /// </summary>
        Connections,

        /// <summary>
        /// Number of recommendations per person, from largest to smallest.
        /// </summary>
		Recommenders,

        /// <summary>
        /// Degree of separation within the member's network, from first degree, then second degree, 
        /// and then all others mixed together, including third degree and out-of-network.
        /// </summary>
		Distance,

        /// <summary>
        /// Relevance of results based on the query, from most to least relevant.
        /// </summary>
		Relevance
    }
}
