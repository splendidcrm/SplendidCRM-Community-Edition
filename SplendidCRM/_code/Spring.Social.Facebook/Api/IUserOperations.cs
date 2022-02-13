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
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	public interface IUserOperations
	{
		/// <summary>
		/// Retrieves the profile for the authenticated user.
		/// </summary>
		/// <returns>the user's profile information.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		FacebookProfile GetUserProfile();
	
		/// <summary>
		/// Retrieves the profile for the specified user.
		/// </summary>
		/// <param name="userId">the Facebook user ID to retrieve profile data for.</param>
		/// <returns>the user's profile information.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		FacebookProfile GetUserProfile(string userId);

		/// <summary>
		/// Retrieves the user's profile image. Returns the image in Facebook's "normal" type.
		/// </summary>
		/// <returns>an array of bytes containing the user's profile image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		byte[] GetUserProfileImage();

		/// <summary>
		/// Retrieves the user's profile image. Returns the image in Facebook's "normal" type.
		/// </summary>
		/// <param name="userId">the Facebook user ID.</param>
		/// <returns>an array of bytes containing the user's profile image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		byte[] GetUserProfileImage(string userId);

		/// <summary>
		/// Retrieves the user's profile image.
		/// </summary>
		/// <param name="imageType">the image type (eg., small, normal, large. square)</param>
		/// <returns>an array of bytes containing the user's profile image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		byte[] GetUserProfileImage(ImageType imageType);

		/// <summary>
		/// Retrieves the user's profile image.
		/// </summary>
		/// <param name="userId">the Facebook user ID.</param>
		/// <param name="imageType">the image type (eg., small, normal, large. square)</param>
		/// <returns>an array of bytes containing the user's profile image.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		byte[] GetUserProfileImage(string userId, ImageType imageType);

		/// <summary>
		/// Retrieves a list of permissions that the application has been granted for the authenticated user.
		/// </summary>
		/// <returns>the permissions granted for the user.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<String> GetUserPermissions();
	
		/// <summary>
		/// Searches for users.
		/// </summary>
		/// <param name="query">the search query (e.g., "Michael Scott")</param>
		/// <returns>a list of {@link Reference}s, each representing a user who matched the given query.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Reference> Search(string query);
	}
}
