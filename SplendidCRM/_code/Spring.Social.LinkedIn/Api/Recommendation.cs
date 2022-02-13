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
    /// Represents a LinkedIn recommendation.
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class Recommendation
    {
        /// <summary>
        /// Gets or sets the unique identifier for the recommendation.
        /// </summary>
        public int ID { get; set; }

        /// <summary>
        /// Gets or sets the recommendation text.
        /// </summary>
        public string Text { get; set; }

        /// <summary>
        /// Gets or sets the type of recommendation that was selected by the person making the recommendation.
        /// </summary>
        public RecommendationType Type { get; set; }

        /// <summary>
        /// Gets or sets the person who made the recommendation. 
        /// </summary>
        public LinkedInProfile Recommender { get; set; }

/*
        /// <summary>
        /// Gets or sets the 
        /// </summary>
        public string RecommendationSnippet { get; set; }

        /// <summary>
        /// Gets or sets the 
        /// </summary>
        public string RecommendationText { get; set; }

        /// <summary>
        /// Gets or sets the 
        /// </summary>
        public LinkedInProfile Recommendee { get; set; }
*/
    }
}
