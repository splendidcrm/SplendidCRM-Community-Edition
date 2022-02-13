#region License

/*
 * Copyright 2002-2012 the original author or authors.
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

using Spring.Rest.Client;

namespace Spring.Social.Facebook.Api
{
	/// <summary>
	/// Interface specifying a basic set of operations for interacting with Facebook.
	/// </summary>
	/// <author>Keith Donald</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IFacebook : IApiBinding
	{
		/// <summary>
		/// </summary>
		IUserOperations UserOperations { get; }

		/// <summary>
		/// </summary>
		IPlacesOperations PlacesOperations { get; }

		/// <summary>
		/// </summary>
		ILikeOperations LikeOperations { get; }

		/// <summary>
		/// </summary>
		IFriendOperations FriendOperations { get; }

		/// <summary>
		/// </summary>
		IFeedOperations FeedOperations { get; }

		/// <summary>
		/// </summary>
		IGroupOperations GroupOperations { get; }

		/// <summary>
		/// </summary>
		ICommentOperations CommentOperations { get; }

		/// <summary>
		/// </summary>
		IEventOperations EventOperations { get; }

		/// <summary>
		/// </summary>
		IMediaOperations MediaOperations { get; }

		/// <summary>
		/// </summary>
		IPageOperations PageOperations { get; }

		/// <summary>
		/// </summary>
		IFqlOperations FqlOperations { get; }

		/// <summary>
		/// </summary>
		IQuestionOperations QuestionOperations { get; }

		/// <summary>
		/// </summary>
		IOpenGraphOperations OpenGraphOperations { get; }

		/// <summary>
		/// Gets the underlying <see cref="IRestOperations"/> object allowing for consumption of Facebook endpoints 
		/// that may not be otherwise covered by the API binding. 
		/// </summary>
		/// <remarks>
		/// The <see cref="IRestOperations"/> object returned is configured to include an OAuth "Authorization" header on all requests.
		/// </remarks>
		IRestOperations RestOperations { get; }
	}
}
