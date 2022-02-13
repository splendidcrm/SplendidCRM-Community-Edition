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
	/// Defines the operations for interacting with a user's Facebook checkins.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IPlacesOperations
	{
		/// <summary>
		/// Retrieves a list of up to 25 recent checkins for the authenticated user.
		/// Requires "user_checkins" or "friends_checkins" permission.
		/// </summary>
		/// <returns>a list {@link Checkin}s for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_checkins" or "friends_checkins" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Checkin> GetCheckins();

		/// <summary>
		/// Retrieves a list of checkins for the authenticated user.
		/// Requires "user_checkins" or "friends_checkins" permission.
		/// </summary>
		/// <param name="offset">the offset into the list of checkins</param>
		/// <param name="limit">the maximum number of checkins to return</param>
		/// <returns>a list {@link Checkin}s for the user, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_checkins" or "friends_checkins" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Checkin> GetCheckins(int offset, int limit);

		/// <summary>
		/// Retrieves a list of up to 25 recent checkins for the specified object.
		/// If the object is a user, this returns checkins for places the user has checked into.
		/// If the object is a page, then this returns checkins that the user's friends has made to the location that the page represents.
		/// Requires "user_checkins" or "friends_checkins" permission.
		/// </summary>
		/// <param name="objectId">either a Facebook user ID or page ID</param>
		/// <returns>a list {@link Checkin}s, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_checkins" or "friends_checkins" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Checkin> GetCheckins(string objectId);

		/// <summary>
		/// Retrieves a list of checkins for the specified object.
		/// If the object is a user, this returns checkins for places the user has checked into.
		/// If the object is a page, then this returns checkins that the user's friends has made to the location that the page represents.
		/// Requires "user_checkins" or "friends_checkins" permission.
		/// </summary>
		/// <param name="objectId">either a Facebook user ID or page ID</param>
		/// <param name="offset">the offset into the list of checkins</param>
		/// <param name="limit">the maximum number of checkins to return</param>
		/// <returns>a list {@link Checkin}s, or an empty list if not available.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "user_checkins" or "friends_checkins" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Checkin> GetCheckins(string objectId, int offset, int limit);

		/// <summary>
		/// Retrieves details for a single checkin.
		/// </summary>
		/// <param name="checkinId">the checkin ID</param>
		/// <returns>a {@link Checkin}</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		Checkin GetCheckin(string checkinId);
	
		/// <summary>
		/// Checks the authenticated user into the specified location.
		/// Requires "publish_checkins" permission.
		/// </summary>
		/// <param name="placeId">the ID of the place to check into.</param>
		/// <param name="latitude">the latitude of the place.</param>
		/// <param name="longitude">the longitude of the place.</param>
		/// <returns>the ID of the checkin.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_checkins" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string Checkin(string placeId, double latitude, double longitude);

		/// <summary>
		/// Checks the authenticated user into the specified location.
		/// Requires "publish_checkins" permission.
		/// </summary>
		/// <param name="placeId">the ID of the place to check into.</param>
		/// <param name="latitude">the latitude of the place.</param>
		/// <param name="longitude">the longitude of the place.</param>
		/// <param name="message">a message to post along with the checkin.</param>
		/// <param name="tags">a varargs list of user IDs to tag on the checkin.</param>
		/// <returns>the ID of the checkin.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_checkins" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string Checkin(string placeId, double latitude, double longitude, string message, string[] tags);
	
		/// <summary>
		/// Searches for places near a given coordinate.
		/// </summary>
		/// <param name="query">the search query (e.g., "Burritos")</param>
		/// <param name="latitude">the latitude of the point to search near</param>
		/// <param name="longitude">the longitude of the point to search near</param>
		/// <param name="distance">the radius to search within (in feet)</param>
		/// <returns>a list of {@link Page}s matching the search</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Page> Search(string query, double latitude, double longitude, long distance);
	}
}
