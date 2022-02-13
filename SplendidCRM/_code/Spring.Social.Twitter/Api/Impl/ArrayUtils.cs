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

namespace Spring.Social.Twitter.Api.Impl
{
    /// <summary>
    /// Utility methods relating to the manipulation of arrays.
    /// </summary>
    /// <author>Bruno Baia</author>
    static class ArrayUtils
    {
        /// <summary>
        /// Returns a comma delimited string representation of an array.
        /// </summary>
        /// <param name="array">The array to return as a string.</param>
        /// <returns>A String representation of the specified <paramref name="array"/>.</returns>
        public static string Join(Array array)
        {
            if (array == null)
            {
                return "";
            }
            StringBuilder stringBuilder = new StringBuilder();
            for (int index = 0; index < array.Length; index++)
            {
                object obj = array.GetValue(index);
                if (obj != null)
                {
                    stringBuilder.Append(obj.ToString());
                    if (index < array.Length - 1)
                    {
                        stringBuilder.Append(",");
                    }
                }
            }
            return stringBuilder.ToString();
        }
    }
}