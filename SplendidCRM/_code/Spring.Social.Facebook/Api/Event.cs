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
	/// Model class representing an event.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Event
	{
		public enum enumPrivacy { OPEN, SECRET, CLOSED }

		public Event()
		{
		}

		// http://developers.facebook.com/docs/reference/api/event/
		public Event(String id, String name, Reference owner, enumPrivacy privacy, DateTime startTime, DateTime endTime, DateTime updatedTime)
		{
			this.ID          = id         ;
			this.Owner       = owner      ;
			this.Name        = name       ;
			this.StartTime   = startTime  ;
			this.EndTime     = endTime    ;
			this.Privacy     = privacy    ;
			this.UpdatedTime = updatedTime;
		}
		
		/// <summary>
		///  The event ID
		/// </summary>
		public string ID { get; set; }
		
		/// <summary>
		///  The profile that created the event
		/// </summary>
		public Reference Owner { get; set; }
		
		/// <summary>
		///  The event title
		/// </summary>
		public string Name { get; set; }
		
		/// <summary>
		///  The long-form description of the event
		/// </summary>
		public string Description { get; set; }
		
		/// <summary>
		///  The start time of the event, as you want it to be displayed on facebook
		/// </summary>
		public DateTime? StartTime { get; set; }
		
		/// <summary>
		///  The end time of the event, as you want it to be displayed on facebook
		/// </summary>
		public DateTime? EndTime { get; set; }
		
		/// <summary>
		///  The location for this event
		/// </summary>
		public string Location { get; set; }
		
		/// <summary>
		///  The location of this event
		/// </summary>
		public Location Venue { get; set; }
		
		/// <summary>
		/// The visibility of this event
		/// </summary>
		public enumPrivacy Privacy { get; set; }
		
		/// <summary>
		///  The last time the event was updated
		/// </summary>
		public DateTime? UpdatedTime { get; set; }
	}
}
