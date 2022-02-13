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
    /// Represents an IM (Instant Messenger) account details for a profile on LinkedIn.
    /// </summary>
    /// <author>Bruno Baia</author>
#if !SILVERLIGHT
    [Serializable]
#endif
    public class ImAccount
    {
        /// <summary>
        /// Gets or sets the type of IM account. 
        /// <para/>
        /// Possible values are: aim, gtalk, icq, msn, skype, and yahoo.
        /// </summary>
        public string Type { get; set; }

        /// <summary>
        /// Gets or sets the name of the IM account.
        /// </summary>
        public string Name { get; set; }
    }
}
