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

// 10/20/2013 Paul.  Deprecated in version 2.0 M1.
#if false
using System;
using System.Collections.Generic;

using Spring.Json;

namespace Spring.Social.Twitter.Api.Impl.Json
{
    /// <summary>
    /// Base JSON deserializer for list of trends. 
    /// </summary>
    /// <author>Bruno Baia</author>
    abstract class AbstractTrendsListDeserializer : IJsonDeserializer
    {
        private static IComparer<Trends> DEFAULT_COMPARER = new TrendsComparer();

        public object Deserialize(JsonValue value, JsonMapper mapper)
        {
            List<Trends> trendsList = this.CreateTrendsList();
            JsonValue trendsValue = value.GetValue("trends");
            if (trendsValue != null)
            {
                foreach (string time in trendsValue.GetNames())
                {
                    Trends trends = new Trends();
                    trends.Time = JsonUtils.ToDateTime(time, this.GetDateFormat());
                    foreach (JsonValue jsonValue in trendsValue.GetValues(time))
                    {
                        trends.Items.Add(new Trend()
                        {
                            Name = jsonValue.GetValue<string>("name"),
                            Query = jsonValue.GetValue<string>("query")
                        });
                    }
                    trendsList.Add(trends);
                }
                trendsList.Sort(AbstractTrendsListDeserializer.DEFAULT_COMPARER);
            }
            return trendsList;
        }

        protected abstract List<Trends> CreateTrendsList();

        protected abstract string GetDateFormat();

        #region TrendsComparer class

        private class TrendsComparer : IComparer<Trends>
        {
            public int Compare(Trends x, Trends y)
            {
                if (!x.Time.HasValue && !y.Time.HasValue)
                {
                    return 0;
                }
                if (!x.Time.HasValue)
                {
                    return 1;
                }
                if (!y.Time.HasValue)
                {
                    return -1;
                }
                return x.Time.Value > y.Time.Value ? -1 : 1;
            }
        }

        #endregion
    }
}
#endif
