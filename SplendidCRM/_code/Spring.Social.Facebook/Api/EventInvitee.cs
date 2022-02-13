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
	/// Model class representing someone who has been invited to an event.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class EventInvitee
	{
		public EventInvitee()
		{
		}

		public EventInvitee(String id, String name, RsvpStatus rsvpStatus)
		{
			this.ID         = id;
			this.Name       = name;
			this.RsvpStatus = rsvpStatus;
		}

		/// <summary>
		/// The invitee's user ID.
		/// </summary>
		public string ID { get; set; }

		/// <summary>
		/// The invitee's name.
		/// </summary>
		public string Name { get; set; }

		/// <summary>
		/// The invitee's RSVP status (attending, unsure, not-replied, or declined).
		/// </summary>
		public RsvpStatus RsvpStatus { get; set; }
	}
}
