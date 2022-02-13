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
	class FieldDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			Field info = null;
			if ( json != null && !json.IsNull )
			{
				info = new Field();
				info.AutoNumber              = json.ContainsName("autoNumber"             ) ? json.GetValue<bool  >("autoNumber"             ) : false;
				info.ByteLength              = json.ContainsName("byteLength"             ) ? json.GetValue<int   >("byteLength"             ) : 0;
				info.Calculated              = json.ContainsName("calculated"             ) ? json.GetValue<bool  >("calculated"             ) : false;
				info.CalculatedFormula       = json.ContainsName("calculatedFormula"      ) ? json.GetValue<string>("calculatedFormula"      ) : String.Empty;
				info.CaseSensitive           = json.ContainsName("caseSensitive"          ) ? json.GetValue<bool  >("caseSensitive"          ) : false;
				info.ControllerName          = json.ContainsName("controllerName"         ) ? json.GetValue<string>("controllerName"         ) : String.Empty;
				info.Createable              = json.ContainsName("createable"             ) ? json.GetValue<bool  >("createable"             ) : false;
				info.Custom                  = json.ContainsName("custom"                 ) ? json.GetValue<bool  >("custom"                 ) : false;
				info.DefaultValueFormula     = json.ContainsName("defaultValueFormula"    ) ? json.GetValue<string>("defaultValueFormula"    ) : String.Empty;
				info.DefaultedOnCreate       = json.ContainsName("defaultedOnCreate"      ) ? json.GetValue<bool  >("defaultedOnCreate"      ) : false;
				info.DependentPicklist       = json.ContainsName("dependentPicklist"      ) ? json.GetValue<bool  >("dependentPicklist"      ) : false;
				info.DeprecatedAndHidden     = json.ContainsName("deprecatedAndHidden"    ) ? json.GetValue<bool  >("deprecatedAndHidden"    ) : false;
				info.Digits                  = json.ContainsName("digits"                 ) ? json.GetValue<int   >("digits"                 ) : 0;
				info.ExternalId              = json.ContainsName("externalId"             ) ? json.GetValue<bool  >("externalId"             ) : false;
				info.Filterable              = json.ContainsName("filterable"             ) ? json.GetValue<bool  >("filterable"             ) : false;
				info.Groupable               = json.ContainsName("groupable"              ) ? json.GetValue<bool  >("groupable"              ) : false;
				info.HtmlFormatted           = json.ContainsName("htmlFormatted"          ) ? json.GetValue<bool  >("htmlFormatted"          ) : false;
				info.IdLookup                = json.ContainsName("idLookup"               ) ? json.GetValue<bool  >("idLookup"               ) : false;
				info.InlineHelpText          = json.ContainsName("inlineHelpText"         ) ? json.GetValue<string>("inlineHelpText"         ) : String.Empty;
				info.Label                   = json.ContainsName("label"                  ) ? json.GetValue<string>("label"                  ) : String.Empty;
				info.Length                  = json.ContainsName("length"                 ) ? json.GetValue<int   >("length"                 ) : 0;
				info.Name                    = json.ContainsName("name"                   ) ? json.GetValue<string>("name"                   ) : String.Empty;
				info.NamePointing            = json.ContainsName("namePointing"           ) ? json.GetValue<bool  >("namePointing"           ) : false;
				info.Nillable                = json.ContainsName("nillable"               ) ? json.GetValue<bool  >("nillable"               ) : false;
				info.Permissionable          = json.ContainsName("permissionable"         ) ? json.GetValue<bool  >("permissionable"         ) : false;
				info.Precision               = json.ContainsName("precision"              ) ? json.GetValue<int   >("precision"              ) : 0;
				info.RelationshipName        = json.ContainsName("relationshipName"       ) ? json.GetValue<string>("relationshipName"       ) : String.Empty;
				info.RelationshipOrder       = json.ContainsName("relationshipOrder"      ) ? json.GetValue<int   >("relationshipOrder"      ) : 0;
				info.RestrictedPicklist      = json.ContainsName("restrictedPicklist"     ) ? json.GetValue<bool  >("restrictedPicklist"     ) : false;
				info.Scale                   = json.ContainsName("scale"                  ) ? json.GetValue<int   >("scale"                  ) : 0;
				info.Sortable                = json.ContainsName("sortable"               ) ? json.GetValue<bool  >("sortable"               ) : false;
				info.Unique                  = json.ContainsName("unique"                 ) ? json.GetValue<bool  >("unique"                 ) : false;
				info.Updateable              = json.ContainsName("updateable"             ) ? json.GetValue<bool  >("updateable"             ) : false;
				info.WriteRequiresMasterRead = json.ContainsName("writeRequiresMasterRead") ? json.GetValue<bool  >("writeRequiresMasterRead") : false;
				
				info.ReferenceTo             = mapper.Deserialize<List<string>       >(json.GetValue("referenceTo"   ));
				info.PicklistValues          = mapper.Deserialize<List<PicklistEntry>>(json.GetValue("picklistValues"));
				info.SoapType                = SoapTypeDeserializer (json.GetValue("soapType"));
				info.Type                    = FieldTypeDeserializer(json.GetValue("type"    ));
			}
			return info;
		}

		private static Field.enumSoapType SoapTypeDeserializer(JsonValue json)
		{
			Field.enumSoapType value = Field.enumSoapType.xsdanyType;
			if ( json != null && !json.IsNull )
			{
				try
				{
					string code = json.GetValue<string>();
					code = code.Replace(":", "");
					value = (Field.enumSoapType) Enum.Parse(typeof(Field.enumSoapType), code);
				}
				catch
				{
				}
			}
			return value;
		}

		private static Field.enumFieldType FieldTypeDeserializer(JsonValue json)
		{
			Field.enumFieldType value = Field.enumFieldType.anyType;
			if ( json != null && !json.IsNull )
			{
				try
				{
					string code = json.GetValue<string>();
					value = (Field.enumFieldType) Enum.Parse(typeof(Field.enumFieldType), code);
				}
				catch
				{
				}
			}
			return value;
		}
	}
}
