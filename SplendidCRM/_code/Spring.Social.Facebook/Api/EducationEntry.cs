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
using System.Collections.Generic;

namespace Spring.Social.Facebook.Api
{
	/// <summary>
	/// Model class representing an entry in a user's education history.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class EducationEntry
	{
		public EducationEntry()
		{
		}

		public EducationEntry(Reference school, Reference year, List<Reference> concentration, string type)
		{
			this.School        = school;
			this.Year          = year;
			this.Concentration = concentration;
			this.Type          = type;
		}

		public Reference School { get; set; }

		public Reference Year { get; set; }

		public List<Reference> Concentration { get; set; }

		public string Type { get; set; }
	}
}
