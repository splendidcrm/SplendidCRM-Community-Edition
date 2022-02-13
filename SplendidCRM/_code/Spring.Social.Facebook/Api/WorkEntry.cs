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
	/// Model class representing an entry in the user's work history.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class WorkEntry
	{
		public WorkEntry()
		{
		}

		public WorkEntry(Reference employer, string startDate, string endDate)
		{
			this.Employer  = employer;
			this.StartDate = startDate;
			this.EndDate   = endDate;
		}

		public Reference Employer { get; set; }

		public string StartDate { get; set; }

		public string EndDate { get; set; }
	}
}
