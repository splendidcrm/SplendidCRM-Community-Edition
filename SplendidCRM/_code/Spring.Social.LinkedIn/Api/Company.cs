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
    /// Represents a LinkedIn company.
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class Company
    {
        /// <summary>
        /// Gets or sets the unique identifier for the company.
        /// </summary>
        public int ID { get; set; }

        /// <summary>
        /// Gets or sets the name of the company. 
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the industry in which the company operates.
        /// <para/>
        /// Industry codes: http://developer.linkedin.com/node/1011
        /// </summary>
        public string Industry { get; set; }

        /// <summary>
        /// Gets or sets the number of employees at the company. 
        /// </summary>
	    public string Size { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether the company is public or private.
        /// </summary>
	    public string Type { get; set; }

        /// <summary>
        /// Gets or sets the stock market name for the company, if the company type is public.
        /// </summary>
        public string Ticker { get; set; }
    }
}
