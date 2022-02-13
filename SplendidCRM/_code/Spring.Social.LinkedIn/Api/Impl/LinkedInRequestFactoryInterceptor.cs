#if !WINDOWS_PHONE
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
using System.Reflection;

using Spring.Http.Client;
using Spring.Http.Client.Interceptor;

namespace Spring.Social.LinkedIn.Api.Impl
{
    // http://connect.microsoft.com/VisualStudio/feedback/details/94109/

    /// <summary>
    /// Intercepts HTTP requests creation to leave URI dots and slashes escaped.
    /// </summary>
    /// <author>Bruno Baia</author>
    class LinkedInRequestFactoryInterceptor : IClientHttpRequestFactoryInterceptor
    {
        public IClientHttpRequest Create(IClientHttpRequestFactoryCreation creation)
        {
            string requestUri = creation.Uri.ToString();
            if (requestUri.Contains("people/url=")) // ProfileOperations.GetUserProfileByPublicUrl
            {
                LeaveDotsAndSlashesEscaped(creation.Uri);
            }
            return creation.Create();
        }

        // from http://grootveld.com/archives/21/url-encoded-slashes-in-systemuri

        static readonly FieldInfo SyntaxField = typeof(Uri).GetField("m_Syntax", BindingFlags.Instance | BindingFlags.NonPublic);
        static readonly FieldInfo FlagsField = typeof(UriParser).GetField("m_Flags", BindingFlags.Instance | BindingFlags.NonPublic);

        // System.UriSyntaxFlags is internal, so let's duplicate the flag privately
        const int UnEscapeDotsAndSlashes = 0x2000000;

        static void LeaveDotsAndSlashesEscaped(Uri uri)
        {
            if (SyntaxField == null)
            {
                throw new MissingFieldException(String.Format("Field '{0}.{1}' not found,", typeof(Uri).FullName, "m_Syntax"));
            }
            if (FlagsField == null)
            {
                throw new MissingFieldException(String.Format("Field '{0}.{1}' not found,", typeof(UriParser).FullName, "m_Flags"));
            }
            object uriParser = SyntaxField.GetValue(uri);
            object uriSyntaxFlags = FlagsField.GetValue(uriParser);

            // Clear the flag that we don't want
            uriSyntaxFlags = (int)uriSyntaxFlags & ~UnEscapeDotsAndSlashes;

            FlagsField.SetValue(uriParser, uriSyntaxFlags);
        }
    }
}
#endif