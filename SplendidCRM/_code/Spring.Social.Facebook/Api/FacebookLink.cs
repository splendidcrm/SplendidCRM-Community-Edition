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
	/// Model class representing a link to be posted to a users Facebook wall.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class FacebookLink
	{
		/// <summary>
		/// Creates a FacebookLink.
		/// </summary>
		/// <param name="link">The link's URL</param>
		/// <param name="name">The name of the link</param>
		/// <param name="caption">A caption to be displayed with the link</param>
		/// <param name="description">The description of the link</param>
		public FacebookLink(string link, string name, string caption, string description)
		{
			this.Link        = link;
			this.Name        = name;
			this.Caption     = caption;
			this.Description = description;
		}

		public string Link { get; set; }

		public string Name { get; set; }

		public string Caption { get; set; }

		public string Description { get; set; }
	}
}
