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
	/// Interface defining operations that can be performed on a Facebook pages.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IPageOperations
	{
		/// <summary>
		/// Retrieves data for a page.
		/// </summary>
		/// <param name="pageId">the page ID.</param>
		/// <returns>a {@link Page}</returns>
		Page GetPage(string pageId);
	
		/// <summary>
		/// Checks whether the logged-in user for this session is an admin of the page with the given page ID.
		/// Requires "manage_pages" permission.
		/// </summary>
		/// <param name="pageId">the page ID</param>
		/// <returns>true if the authenticated user is an admin of the specified page.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "manage_pages" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		bool IsPageAdmin(string pageId);
	
		/// <summary>
		/// Retrieves a list of Account objects for the pages that the authenticated user is an administrator.
		/// Requires "manage_pages" permission.
		/// </summary>
		List<Account> GetAccounts();
	
		/// <summary>
		/// Posts a message to a page's feed as a page administrator.
		/// Requires that the application is granted "manage_pages" permission and that the authenticated user be an administrator of the page.
		/// To post to the page's feed as the authenticated user, use {@link FeedOperations#post(String, String)} instead.
		/// </summary>
		/// <param name="pageId">the page ID</param>
		/// <param name="message">the message to post</param>
		/// <returns>the ID of the new feed entry</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "manage_pages" permission.</exception>
		/// <exception cref="PageAdministrationException">if the user is not a page administrator.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string Post(string pageId, string message);
	
		/// <summary>
		/// Posts a link to the page's feed as a page administrator.
		/// Requires that the application is granted "manage_pages" permission and that the authenticated user be an administrator of the page.
		/// To post a link to the page's feed as the authenticated user, use {@link FeedOperations#postLink(String, String, FacebookLink)} instead.
		/// </summary>
		/// <param name="pageId">the page ID</param>
		/// <param name="message">a message to send with the link.</param>
		/// <param name="link">the link details</param>
		/// <returns>the ID of the new feed entry.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "manage_pages" permission.</exception>
		/// <exception cref="PageAdministrationException">if the user is not a page administrator.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string Post(string pageId, string message, FacebookLink link);

		/// <summary>
		/// Posts a photo to a page's album as the page administrator.
		/// Requires that the application is granted "manage_pages" permission and that the authenticated user be an administrator of the page.
		/// </summary>
		/// <param name="pageId">the page ID</param>
		/// <param name="albumId">the album ID</param>
		/// <param name="photo">A {@link Resource} for the photo data. The given Resource must implement the getFilename() method (such as {@link FileSystemResource} or {@link ClassPathResource}).</param>
		/// <returns>the ID of the photo.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "manage_pages" permission.</exception>
		/// <exception cref="PageAdministrationException">if the user is not a page administrator.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string PostPhoto(string pageId, string albumId, Resource photo);

		/// <summary>
		/// Posts a photo to a page's album as the page administrator.
		/// Requires that the application is granted "manage_pages" permission and that the authenticated user be an administrator of the page.
		/// </summary>
		/// <param name="pageId">the page ID</param>
		/// <param name="albumId">the album ID</param>
		/// <param name="photo">A {@link Resource} for the photo data. The given Resource must implement the getFilename() method (such as {@link FileSystemResource} or {@link ClassPathResource}).</param>
		/// <param name="caption">A caption describing the photo.</param>
		/// <returns>the ID of the photo.</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "manage_pages" permission.</exception>
		/// <exception cref="PageAdministrationException">if the user is not a page administrator.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string PostPhoto(string pageId, string albumId, Resource photo, string caption);
	}
}
