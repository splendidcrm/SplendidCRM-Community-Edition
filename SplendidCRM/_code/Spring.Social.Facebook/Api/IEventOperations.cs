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
using System.IO;
using System.Collections.Generic;
using Spring.Rest.Client;
using Spring.Http;

namespace Spring.Social.Facebook.Api
{
	/// <summary>
	/// Defines operations for creating and reading event data as well as RSVP'ing to events on behalf of a user.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IEventOperations
	{
		/// <summary>
		/// Retrieves a list of up to 25 events that the authenticated user has been invited to.
		/// Requires "user_events" or "friends_events" permission.
		/// </summary>
		/// <returns>a list {@link Invitation}s for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_events" or "friends_events" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Invitation> GetInvitations();

		/// <summary>
		/// Retrieves a list of events that the authenticated user has been invited to.
		/// Requires "user_events" or "friends_events" permission.
		/// </summary>
		/// <param name="offset">the offset into the list of events</param>
		/// <param name="limit">the maximum number of events to return</param>
		/// <returns>a list {@link Invitation}s for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_events" or "friends_events" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Invitation> GetInvitations(int offset, int limit);

		/// <summary>
		/// Retrieves a list of events that the specified user has been invited to.
		/// Requires "user_events" or "friends_events" permission.
		/// </summary>
		/// <param name="userId">the user's ID</param>
		/// <returns>a list {@link Invitation}s for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_events" or "friends_events" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Invitation> GetInvitations(string userId);

		/// <summary>
		/// Retrieves a list of events that the specified user has been invited to.
		/// Requires "user_events" or "friends_events" permission.
		/// </summary>
		/// <param name="userId">the user's ID</param>
		/// <param name="offset">the offset into the list of events</param>
		/// <param name="limit">the maximum number of events to return</param>
		/// <returns>a list {@link Invitation}s for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_events" or "friends_events" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Invitation> GetInvitations(string userId, int offset, int limit);

		/// <summary>
		/// Retrieves event data for a specified event.
		/// </summary>
		/// <param name="eventId">the event ID</param>
		/// <returns>an {@link Event} object</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		Event GetEvent(string eventId);
	
		/// <summary>
		/// Retrieves an event's image as an array of bytes. Returns the image in Facebook's "normal" type.
		/// </summary>
		/// <param name="eventId">the event ID</param>
		/// <returns>an array of bytes containing the event's image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		byte[] GetEventImage(string eventId);

		/// <summary>
		/// Retrieves an event's image as an array of bytes.
		/// </summary>
		/// <param name="eventId">the event ID</param>
		/// <param name="imageType">the image type (eg., small, normal, large. square)</param>
		/// <returns>an array of bytes containing the event's image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		byte[] GetEventImage(string eventId, ImageType imageType);
	
		/// <summary>
		/// Creates an event.
		/// Requires "create_event" permission.
		/// The string passed in for start time and end time is flexible in regard to format. Some valid examples are:
		/// <ul>
		/// <li>2011-04-01T15:30:00 (3:30PM on April 1, 2011)</li>
		/// <li>2011-04-01 (midnight on April 1, 2011)</li>
		/// <li>April 1, 2011 (midnight on April 1, 2011)</li>
		/// <li>17:00:00 (5:00PM today)</li>
		/// <li>10-11-2011 (November 10, 2012)</li>
		/// <li>10/11/2012 (October 11, 2012)</li>
		/// <li>10.11.2012 (November 10, 2012)</li>
		/// <li>Tomorrow 2PM</li>
		/// </ul>
		/// </summary>
		/// <param name="name">the name of the event</param>
		/// <param name="startTime">the start time of the event.</param>
		/// <param name="endTime">the end time of the event.</param>
		/// <returns>the newly created event's ID</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "create_event" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string CreateEvent(string name, DateTime startTime, DateTime endTime);
	
		/// <summary>
		/// Deletes an event.
		/// Requires "create_event" permission.
		/// </summary>
		/// <param name="eventId">the ID of the event</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "create_event" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void DeleteEvent(string eventId);
	
		/// <summary>
		/// Retrieves the list of an event's invitees.
		/// </summary>
		/// <param name="eventId">the event ID.</param>
		/// <returns>a list of {@link EventInvitee}s for the event.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<EventInvitee> GetInvited(string eventId);
	
		/// <summary>
		/// Retrieves the list of an event's invitees who have accepted the invitation.
		/// </summary>
		/// <param name="eventId">the event ID.</param>
		/// <returns>a list of {@link EventInvitee}s for the event.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<EventInvitee> GetAttending(string eventId);
	
		/// <summary>
		/// Retrieves the list of an event's invitees who have indicated that they may attend the event.
		/// </summary>
		/// <param name="eventId">the event ID.</param>
		/// <returns>a list of {@link EventInvitee}s for the event.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<EventInvitee> GetMaybeAttending(string eventId);
	
		/// <summary>
		/// Retrieves the list of an event's invitees who have not yet RSVP'd.
		/// </summary>
		/// <param name="eventId">the event ID.</param>
		/// <returns>a list of {@link EventInvitee}s for the event.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<EventInvitee> GetNoReplies(string eventId);
	
		/// <summary>
		/// Retrieves the list of an event's invitees who have declined the invitation.
		/// </summary>
		/// <param name="eventId">the event ID.</param>
		/// <returns>a list of {@link EventInvitee}s for the event.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<EventInvitee> GetDeclined(string eventId);

		/// <summary>
		/// Accepts an invitation to an event.
		/// Requires "rsvp_event" permission.
		/// </summary>
		/// <param name="eventId">the event ID</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "rsvp_event" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void AcceptInvitation(string eventId);
	
		/// <summary>
		/// RSVPs to an event with a maybe.
		/// Requires "rsvp_event" permission.
		/// </summary>
		/// <param name="eventId">the event ID</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "rsvp_event" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void MaybeInvitation(string eventId);
	
		/// <summary>
		/// Declines an invitation to an event.
		/// Requires "rsvp_event" permission.
		/// </summary>
		/// <param name="eventId">the event ID</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "rsvp_event" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void DeclineInvitation(string eventId);

		/// <summary>
		/// Search for events.
		/// </summary>
		/// <param name="query">the search query (e.g., "Spring User Group")</param>
		/// <returns>a list of {@link Event}s matching the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<Event> Search(string query);

		/// <summary>
		/// Search for events.
		/// </summary>
		/// <param name="query">the search query (e.g., "Spring User Group")</param>
		/// <param name="offset">the offset into the list of events</param>
		/// <param name="limit">the maximum number of events to return</param>
		/// <returns>a list of {@link Event}s matching the search query</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		List<Event> Search(string query, int offset, int limit);
	}
}
