#region License

/*
 * Copyright (C) 2012 SplendidCRM Software, Inc. All Rights Reserved. 
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

using Spring.Json;

namespace Spring.Social.Salesforce.Api.Impl.Json
{
	/// <summary>
	/// JSON deserializer for Version. 
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class RecordTypeInfoDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			RecordTypeInfo info = null;
			if ( json != null && !json.IsNull )
			{
				info = new RecordTypeInfo();
				info.Available                = json.ContainsName("available"               ) ? json.GetValue<bool  >("available"               ) : false;
				info.DefaultRecordTypeMapping = json.ContainsName("defaultRecordTypeMapping") ? json.GetValue<bool  >("defaultRecordTypeMapping") : false;
				info.Name                     = json.ContainsName("name"                    ) ? json.GetValue<string>("name"                    ) : String.Empty;
				info.RecordTypeId             = json.ContainsName("recordTypeId"            ) ? json.GetValue<string>("recordTypeId"            ) : String.Empty;
			}
			return info;
		}
	}
}
