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
using System.Globalization;

using Spring.Json;

namespace Spring.Social.Salesforce.Api.Impl.Json
{
	/// <summary>
	/// JSON deserializer for Globals. 
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class DescribeGlobalSObjectDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			DescribeGlobalSObject obj = null;
			if ( json != null && !json.IsNull )
			{
				obj = new DescribeGlobalSObject();
				obj.Name                = json.ContainsName("name"               ) ? json.GetValue<string >("name"               ) : String.Empty;
				obj.Label               = json.ContainsName("label"              ) ? json.GetValue<string >("label"              ) : String.Empty;
				obj.Updateable          = json.ContainsName("updateable"         ) ? json.GetValue<bool   >("updateable"         ) : false;
				obj.KeyPrefix           = json.ContainsName("keyPrefix"          ) ? json.GetValue<string >("keyPrefix"          ) : String.Empty;
				obj.Custom              = json.ContainsName("custom"             ) ? json.GetValue<bool   >("custom"             ) : false;
				obj.Searchable          = json.ContainsName("searchable"         ) ? json.GetValue<bool   >("searchable"         ) : false;
				obj.LabelPlural         = json.ContainsName("labelPlural"        ) ? json.GetValue<string >("labelPlural"        ) : String.Empty;
				obj.Layoutable          = json.ContainsName("layoutable"         ) ? json.GetValue<bool   >("layoutable"         ) : false;
				obj.Activateable        = json.ContainsName("activateable"       ) ? json.GetValue<bool   >("activateable"       ) : false;
				obj.Createable          = json.ContainsName("createable"         ) ? json.GetValue<bool   >("createable"         ) : false;
				obj.DeprecatedAndHidden = json.ContainsName("deprecatedAndHidden") ? json.GetValue<bool   >("deprecatedAndHidden") : false;
				obj.Deletable           = json.ContainsName("deletable"          ) ? json.GetValue<bool   >("deletable"          ) : false;
				obj.CustomSetting       = json.ContainsName("customSetting"      ) ? json.GetValue<bool   >("customSetting"      ) : false;
				obj.FeedEnabled         = json.ContainsName("feedEnabled"        ) ? json.GetValue<bool   >("feedEnabled"        ) : false;
				obj.Mergeable           = json.ContainsName("mergeable"          ) ? json.GetValue<bool   >("mergeable"          ) : false;
				obj.Queryable           = json.ContainsName("queryable"          ) ? json.GetValue<bool   >("queryable"          ) : false;
				obj.Retrieveable        = json.ContainsName("retrieveable"       ) ? json.GetValue<bool   >("retrieveable"       ) : false;
				obj.Replicateable       = json.ContainsName("replicateable"      ) ? json.GetValue<bool   >("replicateable"      ) : false;
				obj.Undeletable         = json.ContainsName("undeletable"        ) ? json.GetValue<bool   >("undeletable"        ) : false;
				obj.Triggerable         = json.ContainsName("triggerable"        ) ? json.GetValue<bool   >("triggerable"        ) : false;
				JsonValue jsonUrls = json.GetValue("urls");
				if ( jsonUrls != null && !jsonUrls.IsNull )
				{
					obj.UrlSObject     = jsonUrls.ContainsName("sobject"    ) ? jsonUrls.GetValue<string >("sobject"    ) : String.Empty;
					obj.UrlDescribe    = jsonUrls.ContainsName("describe"   ) ? jsonUrls.GetValue<string >("describe"   ) : String.Empty;
					obj.UrlRowTemplate = jsonUrls.ContainsName("rowTemplate") ? jsonUrls.GetValue<string >("rowTemplate") : String.Empty;
				}
			}
			return obj;
		}
	}
}
