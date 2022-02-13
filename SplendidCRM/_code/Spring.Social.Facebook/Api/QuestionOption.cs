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
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class QuestionOption
	{
		public QuestionOption()
		{
		}

		// http://developers.facebook.com/docs/reference/api/question_option/
		public QuestionOption(string id, string name, Reference from, int votes, DateTime createdTime)
		{
			this.ID          = id         ;
			this.Name        = name       ;
			this.From        = from       ;
			this.Votes       = votes      ;
			this.CreatedTime = createdTime;
		}
		
		/// <summary>
		///  QuestionOption ID
		/// </summary>
		public string ID { get; set; }
		
		/// <summary>
		///  User who asked the question
		/// </summary>
		public Reference From { get; set; }
		
		/// <summary>
		///  Text name of the option
		/// </summary>
		public string Name { get; set; }
		
		/// <summary>
		///  Number of votes this option has received
		/// </summary>
		public int Votes { get; set; }
		
		/// <summary>
		///  Number of votes this option has received
		/// </summary>
		public Page Object { get; set; }
		
		/// <summary>
		///  Time when option was created
		/// </summary>
		public DateTime? CreatedTime { get; set; }
	}
}
