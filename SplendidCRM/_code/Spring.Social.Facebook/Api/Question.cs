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
using System.Collections.Generic;

namespace Spring.Social.Facebook.Api
{
	/// <summary>
	/// Model class representing a question asked by a Facebook user.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Question
	{
		public Question()
		{
		}

		// http://developers.facebook.com/docs/reference/api/question/
		public Question(string id, String text, Reference from, DateTime createdTime, DateTime updatedTime)
		{
			this.ID          = id         ;
			this.From        = from       ;
			this.Text        = text       ;
			this.CreatedTime = createdTime;
			this.UpdatedTime = updatedTime;
		}
		
		/// <summary>
		///  Question ID
		/// </summary>
		public string ID { get; set; }
		
		/// <summary>
		///  User who asked the question
		/// </summary>
		public Reference From { get; set; }
		
		/// <summary>
		///  Text of the question
		/// </summary>
		public string Text { get; set; }
		
		/// <summary>
		///  Time when question was created
		/// </summary>
		public DateTime? CreatedTime { get; set; }
		
		/// <summary>
		///  Time when question was last updated
		/// </summary>
		public DateTime? UpdatedTime { get; set; }
		
		/// <summary>
		///  The list of options available as answers to the question
		/// </summary>
		public List<QuestionOption> Options { get; set; }
	}
}
