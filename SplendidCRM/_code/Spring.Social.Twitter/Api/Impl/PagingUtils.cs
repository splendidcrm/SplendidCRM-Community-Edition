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

#if SILVERLIGHT
using Spring.Collections.Specialized;
#else
using System.Collections.Specialized;
#endif

namespace Spring.Social.Twitter.Api.Impl
{
    /// <summary>
    /// Utility methods for creating paging parameters for Twitter requests supporting paging.
    /// </summary>
    /// <author>Craig Walls</author>
    /// <author>Bruno Baia (.NET)</author>
    static class PagingUtils
    {
        public static NameValueCollection BuildPagingParametersWithPageCount(int page, int pageSize, long sinceId, long maxId)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("page", page.ToString());
            parameters.Add("count", pageSize.ToString());
            if (sinceId > 0)
            {
                parameters.Add("since_id", sinceId.ToString());
            }
            if (maxId > 0)
            {
                parameters.Add("max_id", maxId.ToString());
            }
            return parameters;
        }

        public static NameValueCollection BuildPagingParametersWithPerPage(int page, int pageSize, long sinceId, long maxId)
        {
            NameValueCollection parameters = new NameValueCollection();
            parameters.Add("page", page.ToString());
            parameters.Add("per_page", pageSize.ToString());
            if (sinceId > 0)
            {
                parameters.Add("since_id", sinceId.ToString());
            }
            if (maxId > 0)
            {
                parameters.Add("max_id", maxId.ToString());
            }
            return parameters;
        }

        public static NameValueCollection BuildPagingParametersWithCount(int count, long sinceId, long maxId)
        {
            NameValueCollection parameters = new NameValueCollection();
            if (count > 0)
            {
                parameters.Add("count", count.ToString());
            }
            if (sinceId > 0)
            {
                parameters.Add("since_id", sinceId.ToString());
            }
            if (maxId > 0)
            {
                parameters.Add("max_id", maxId.ToString());
            }
            return parameters;
        }
    }
}