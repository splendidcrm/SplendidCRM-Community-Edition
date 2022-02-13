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
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IQuestionOperations
	{
		/// <summary>
		/// Publishes a question.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="questionText">the question text</param>
		/// <returns> * @return the ID of the newly created question</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string AskQuestion(string questionText);
	
		/// <summary>
		/// Adds an option to a question.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="questionId">the question to add the option to</param>
		/// <param name="optionText">the text of the option</param>
		/// <returns>the ID of the newly created option</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		string AddOption(string questionId, string optionText);

		/// <summary>
		/// Retrieves a question.
		/// Requires "user_questions" permission to retrieve a question from the authenticated user and "friends_questions" to retrieve a question
		/// from one of the authenticated user's friends.
		/// </summary>
		/// <param name="questionId">the ID of the question</param>
		/// <returns>the {@link Question}</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		Question GetQuestion(string questionId);
	
		/// <summary>
		/// Retrieves all questions asked by the authenticated user.
		/// Requires "user_questions" permission to retrieve questions from the authenticated user.
		/// </summary>
		/// <returns>a list of {@link Question}s</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Question> GetQuestions();

		/// <summary>
		/// Retrieves all questions asked by the specified user.
		/// Requires "user_questions" permission to retrieve questions from the authenticated user and "friends_questions" to retrieve questions
		/// from one of the authenticated user's friends.
		/// </summary>
		/// <returns>a list of {@link Question}s</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<Question> GetQuestions(string userId);

		/// <summary>
		/// Removes a question.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="questionId">@param questionId the ID of the question to delete</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void DeleteQuestion(string questionId);
	
		/// <summary>
		/// Retrieves a question option.
		/// Requires "user_questions" permission to retrieve an option from the authenticated user and "friends_questions" to retrieve an option
		/// from one of the authenticated user's friends.
		/// </summary>
		/// <param name="optionId">the ID of the option</param>
		/// <returns>the {@link QuestionOption}</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		QuestionOption GetOption(string optionId);

		/// <summary>
		/// Retrieves all options for a specified question.
		/// Requires "user_questions" permission to retrieve options from the authenticated user and "friends_questions" to retrieve options
		/// from one of the authenticated user's friends.
		/// </summary>
		/// <param name="questionId">the ID of the question to retrieve options for</param>
		/// <returns>a list of {@link QuestionOption}s</returns>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		List<QuestionOption> GetOptions(string questionId);

		/// <summary>
		/// Removes a question option.
		/// Requires "publish_stream" permission.
		/// </summary>
		/// <param name="optionId">the ID of the option to delete</param>
		/// <exception cref="ApiException">if there is an error while communicating with Facebook.</exception>
		/// <exception cref="InsufficientPermissionException">if the user has not granted "publish_stream" permission.</exception>
		/// <exception cref="MissingAuthorizationException">if FacebookTemplate was not created with an access token.</exception>
		void DeleteOption(string optionId);
	}
}
