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
using System.Text;
#if SILVERLIGHT
using Spring.Collections.Specialized;
#else
using System.Collections.Specialized;
#endif

using Spring.Http;

namespace Spring.Social.Twitter.Api.Impl
{
    /// <summary>
    /// Base class for Twitter operations.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    abstract class AbstractTwitterOperations
    {
        protected string BuildUrl(string path, string parameterName, string parameterValue)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add(parameterName, parameterValue);
            return this.BuildUrl(path, parameters);
        }

        protected string BuildUrl(string path, NameValueCollection parameters)
        {
            StringBuilder qsBuilder = new StringBuilder();
            bool isFirst = true;
            foreach (string key in parameters)
            {
                if (isFirst)
                {
                    qsBuilder.Append('?');
                    isFirst = false;
                }
                else
                {
                    qsBuilder.Append('&');
                }
                qsBuilder.Append(HttpUtils.UrlEncode(key));
                qsBuilder.Append('=');
                qsBuilder.Append(HttpUtils.UrlEncode(parameters[key]));
            }
            return path + qsBuilder.ToString();
	    }
    }
}