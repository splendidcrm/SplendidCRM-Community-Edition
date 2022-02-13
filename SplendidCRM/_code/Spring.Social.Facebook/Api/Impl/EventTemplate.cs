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
using System.Net;
using System.Collections.Generic;
using System.Collections.Specialized;

using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.Facebook.Api.Impl
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class EventTemplate : AbstractFacebookOperations, IEventOperations
	{
		public EventTemplate(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized)
			: base(applicationNamespace, restTemplate, isAuthorized)
		{
		}

		#region IEventOperations Members
		public List<Invitation> GetInvitations()
		{
			return GetInvitations("me", 0, 25);
		}

		public List<Invitation> GetInvitations(int offset, int limit)
		{
			return GetInvitations("me", offset, limit);
		}

		public List<Invitation> GetInvitations(string userId) {
			return GetInvitations(userId, 0, 25);
		}
	
		public List<Invitation> GetInvitations(string userId, int offset, int limit)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("offset", offset.ToString());
			parameters.Add("limit" , limit .ToString());
			return this.FetchConnections<Invitation>(userId, "events", parameters);
		}
	
		public Event GetEvent(string eventId)
		{
			return this.FetchObject<Event>(eventId);
		}
	
		public byte[] GetEventImage(string eventId)
		{
			return GetEventImage(eventId, ImageType.NORMAL);
		}
	
		public byte[] GetEventImage(string eventId, ImageType imageType)
		{
			return this.FetchImage(eventId, "picture", imageType);
		}
	
		public string CreateEvent(string name, DateTime startTime, DateTime endTime)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("name"      , name     );
			// 04/15/2012 Paul.  Facebook uses ISO-8601 formatted date/time "yyyy-MM-ddTHH:mm:ss". 
			parameters.Add("start_time", startTime.ToString("yyyy-MM-ddTHH:mm:ss"));
			parameters.Add("end_time"  , endTime  .ToString("yyyy-MM-ddTHH:mm:ss"));
			return this.Publish("me", "events", parameters);
		}
	
		public void DeleteEvent(string eventId)
		{
			requireAuthorization();
			this.Delete(eventId);
		}

		public List<EventInvitee> GetInvited(string eventId)
		{
			return this.FetchConnections<EventInvitee>(eventId, "invited");
		}

		public List<EventInvitee> GetAttending(string eventId)
		{
			return this.FetchConnections<EventInvitee>(eventId, "attending");
		}
	
		public List<EventInvitee> GetMaybeAttending(string eventId)
		{
			return this.FetchConnections<EventInvitee>(eventId, "maybe");
		}
	
		public List<EventInvitee> GetNoReplies(string eventId)
		{
			return this.FetchConnections<EventInvitee>(eventId, "noreply");
		}

		public List<EventInvitee> GetDeclined(string eventId)
		{
			return this.FetchConnections<EventInvitee>(eventId, "declined");
		}
	
		public void AcceptInvitation(string eventId)
		{
			requireAuthorization();
			this.Post(eventId, "attending", new NameValueCollection());
		}

		public void MaybeInvitation(string eventId)
		{
			requireAuthorization();
			this.Post(eventId, "maybe", new NameValueCollection());
		}

		public void DeclineInvitation(string eventId)
		{
			requireAuthorization();
			this.Post(eventId, "declined", new NameValueCollection());
		}
	
		public List<Event> Search(string query)
		{
			return Search(query, 0, 25);
		}
	
		public List<Event> Search(string query, int offset, int limit)
		{
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("q"     , query            );
			parameters.Add("type"  , "event"          );
			parameters.Add("offset", offset.ToString());
			parameters.Add("limit" , limit .ToString());
			return this.FetchConnections<Event>("search", null, parameters);
		}
		#endregion
	}
}