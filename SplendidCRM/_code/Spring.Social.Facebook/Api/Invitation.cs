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
	/// Model class representing an invitation to an event.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Invitation
	{
		public Invitation()
		{
		}

		public Invitation(string eventId, string name, DateTime startTime, DateTime endTime, RsvpStatus rsvpStatus)
		{
			this.EventId    = eventId;
			this.Name       = name;
			this.StartTime  = startTime;
			this.EndTime    = endTime;
			this.RsvpStatus = rsvpStatus;
		}

		public Invitation(string eventId, string name, DateTime startTime, DateTime endTime, RsvpStatus rsvpStatus, string location)
		{
			this.EventId    = eventId;
			this.Name       = name;
			this.StartTime  = startTime;
			this.EndTime    = endTime;
			this.Location   = location;
			this.RsvpStatus = rsvpStatus;
		}

		public string EventId { get; set; }

		public string Name { get; set; }

		public DateTime? StartTime { get; set; }

		public DateTime? EndTime { get; set; }

		public string Location { get; set; }

		public RsvpStatus RsvpStatus { get; set; }
	}
}
