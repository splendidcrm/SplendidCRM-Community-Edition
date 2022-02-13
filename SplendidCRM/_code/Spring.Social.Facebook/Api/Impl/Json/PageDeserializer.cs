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
using System.Globalization;

using Spring.Json;

namespace Spring.Social.Facebook.Api.Impl.Json
{
	/// <summary>
	/// JSON deserializer for Page. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class PageDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Page page = null;
			if ( json != null && !json.IsNull )
			{
				page = new Page();
				page.ID              = json.ContainsName("id"              ) ? json.GetValue<string>("id"              ) : String.Empty;
				page.Name            = json.ContainsName("name"            ) ? json.GetValue<string>("name"            ) : String.Empty;
				page.Link            = json.ContainsName("link"            ) ? json.GetValue<string>("link"            ) : String.Empty;
				page.Category        = json.ContainsName("category"        ) ? json.GetValue<string>("category"        ) : String.Empty;
				page.Description     = json.ContainsName("description"     ) ? json.GetValue<string>("description"     ) : String.Empty;
				page.Website         = json.ContainsName("website"         ) ? json.GetValue<string>("website"         ) : String.Empty;
				page.Picture         = json.ContainsName("picture"         ) ? json.GetValue<string>("picture"         ) : String.Empty;
				page.Phone           = json.ContainsName("phone"           ) ? json.GetValue<string>("phone"           ) : String.Empty;
				page.Affiliation     = json.ContainsName("affiliation"     ) ? json.GetValue<string>("affiliation"     ) : String.Empty;
				page.CompanyOverview = json.ContainsName("company_overview") ? json.GetValue<string>("company_overview") : String.Empty;
				page.Likes           = json.ContainsName("likes"           ) ? json.GetValue<int   >("likes"           ) : 0;
				page.Checkins        = json.ContainsName("checkins"        ) ? json.GetValue<int   >("checkins"        ) : 0;
				
				page.Location        = mapper.Deserialize<Location >(json.GetValue("location"));
			}
			return page;
		}
	}
}
