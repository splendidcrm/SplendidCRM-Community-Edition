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
	class QuestionTemplate : AbstractFacebookOperations, IQuestionOperations
	{
		public QuestionTemplate(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized)
			: base(applicationNamespace, restTemplate, isAuthorized)
		{
		}

		#region IQuestionOperations Members
		public string AskQuestion(string questionText)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("question", questionText);
			return this.Publish("me", "questions", parameters);
		}
	
		public string AddOption(string questionId, string optionText)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("option", optionText);
			return this.Publish(questionId, "options", parameters);
		}
	
		public List<Question> GetQuestions()
		{
			return GetQuestions("me");
		}
	
		public List<Question> GetQuestions(string userId)
		{
			requireAuthorization();
			return this.FetchConnections<Question>(userId, "questions");
		}
	
		public void DeleteQuestion(string questionId)
		{
			requireAuthorization();
			this.Delete(questionId);
		}

		public Question GetQuestion(string questionId)
		{
			requireAuthorization();
			return this.FetchObject<Question>(questionId);
		}
	
		public QuestionOption GetOption(string optionId)
		{
			requireAuthorization();
			return this.FetchObject<QuestionOption>(optionId);
		}

		public List<QuestionOption> GetOptions(string questionId)
		{
			requireAuthorization();
			return this.FetchConnections<QuestionOption>(questionId, "options");
		}
	
		public void DeleteOption(string optionId)
		{
			requireAuthorization();
			this.Delete(optionId);
		}
		#endregion
	}
}