#region License

/*
 * Copyright 2011-2012 the original author or authors.
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

namespace Spring.Social.Facebook.Api
{
	/// <summary>
	/// Model class representing a Facebook page.
	/// A Facebook page could represent any number of things, including businesses, government agencies, people, organizations, etc.
	/// A page may even represent a place that a user may check into using Facebook Places, if the page has location data.
	/// The data available for a page will vary depending on the category it belongs to and what data the page administrator has entered.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Page
	{
		public Page()
		{
		}

		public Page(string id, string name, string link, string category)
		{
			this.ID       = id;
			this.Name     = name;
			this.Link     = link;
			this.Category = category;
		}

		public string ID { get; set; }

		public string Name { get; set; }
	
		public string Link { get; set; }

		public string Category { get; set; }
	
		public string Description { get; set; }
	
		public Location Location { get; set; }

		public string Website { get; set; }

		public string Picture { get; set; }

		public string Phone { get; set; }

		public string Affiliation { get; set; }

		public string CompanyOverview { get; set; }
	
		public int FanCount { get; set; }

		public int Likes { get; set; }
	
		public int Checkins { get; set; }
	}
}
