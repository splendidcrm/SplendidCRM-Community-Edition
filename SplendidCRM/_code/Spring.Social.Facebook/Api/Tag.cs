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
	/// Model class representing a tagged user in a video, photo, or checkin. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Tag
	{
		public Tag()
		{
		}

		public Tag(string id, string name, int x, int y, DateTime createdTime)
		{
			this.ID   = id;
			this.Name = name;
			this.X    = x;
			this.Y    = y;
			this.CreatedTime = createdTime;
		}

		public string ID { get; set; }

		public string Name { get; set; }

		public int X { get; set; }

		public int Y { get; set; }

		public DateTime? CreatedTime { get; set; }
	}
}

