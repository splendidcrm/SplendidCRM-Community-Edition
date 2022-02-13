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
using System.Globalization;
using System.Collections.Generic;

using Spring.Json;

namespace Spring.Social.Facebook.Api.Impl.Json
{
	/// <summary>
	/// JSON deserializer for Question. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class QuestionDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Question question = null;
			if ( json != null && !json.IsNull )
			{
				question = new Question();
				question.ID          = json.ContainsName("id"          ) ? json.GetValue<string>("id"      ) : String.Empty;
				question.Text        = json.ContainsName("question"    ) ? json.GetValue<string>("question") : String.Empty;
				question.CreatedTime = json.ContainsName("created_time") ? JsonUtils.ToDateTime(json.GetValue<string>("created_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				question.UpdatedTime = json.ContainsName("updated_time") ? JsonUtils.ToDateTime(json.GetValue<string>("updated_time"), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;

				question.From        = mapper.Deserialize<Reference           >(json.GetValue("from"   ));
				question.Options     = mapper.Deserialize<List<QuestionOption>>(json.GetValue("options"));
			}
			return question;
		}
	}
}
