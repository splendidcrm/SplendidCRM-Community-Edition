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
	/// JSON deserializer for FacebookProfile. 
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	class FacebookProfileDeserializer : IJsonDeserializer
	{
		public object Deserialize(JsonValue json, JsonMapper mapper)
		{
			FacebookProfile profile = null;
			if ( json != null && !json.IsNull )
			{
				profile = new FacebookProfile();
				// 04/14/2012 Paul.  Should not have both id and uid. 
				profile.ID                 = json.ContainsName("id"                 ) ? json.GetValue<string>("id"                 ) : String.Empty;
				profile.ID                 = json.ContainsName("uid"                ) ? json.GetValue<string>("uid"                ) : profile.ID;
				profile.Username           = json.ContainsName("username"           ) ? json.GetValue<string>("username"           ) : String.Empty;
				profile.Name               = json.ContainsName("name"               ) ? json.GetValue<string>("name"               ) : String.Empty;
				profile.FirstName          = json.ContainsName("first_name"         ) ? json.GetValue<string>("first_name"         ) : String.Empty;
				profile.LastName           = json.ContainsName("last_name"          ) ? json.GetValue<string>("last_name"          ) : String.Empty;
				profile.Gender             = json.ContainsName("gender"             ) ? json.GetValue<string>("gender"             ) : String.Empty;
				profile.Locale             = json.ContainsName("locate"             ) ? json.GetValue<string>("locate"             ) : String.Empty;
				profile.MiddleName         = json.ContainsName("middle_name"        ) ? json.GetValue<string>("middle_name"        ) : String.Empty;
				// 04/14/2012 Paul.  Should not have both email and contact_email. 
				profile.Email              = json.ContainsName("email"              ) ? json.GetValue<string>("email"              ) : String.Empty;
				profile.Email              = json.ContainsName("contact_email"      ) ? json.GetValue<string>("contact_email"      ) : profile.Email;
				profile.Link               = json.ContainsName("link"               ) ? json.GetValue<string>("link"               ) : String.Empty;
				profile.ThirdPartyId       = json.ContainsName("third_party_id"     ) ? json.GetValue<string>("third_party_id"     ) : String.Empty;
				profile.Timezone           = json.ContainsName("timezone"           ) ? json.GetValue<int   >("timezone"           ) : 0;
				profile.Verified           = json.ContainsName("verified"           ) ? json.GetValue<bool  >("verified"           ) : false;
				profile.About              = json.ContainsName("about"              ) ? json.GetValue<string>("about"              ) : String.Empty;
				profile.About              = json.ContainsName("about_me"           ) ? json.GetValue<string>("about_me"           ) : profile.About;
				profile.Bio                = json.ContainsName("bio"                ) ? json.GetValue<string>("bio"                ) : String.Empty;
				profile.Religion           = json.ContainsName("religion"           ) ? json.GetValue<string>("religion"           ) : String.Empty;
				profile.Political          = json.ContainsName("political"          ) ? json.GetValue<string>("political"          ) : String.Empty;
				profile.Quotes             = json.ContainsName("quotes"             ) ? json.GetValue<string>("quotes"             ) : String.Empty;
				profile.RelationshipStatus = json.ContainsName("relationship_status") ? json.GetValue<string>("relationship_status") : String.Empty;
				profile.Website            = json.ContainsName("website"            ) ? json.GetValue<string>("website"            ) : String.Empty;
				// http://developers.facebook.com/docs/reference/fql/user/
				// The birthday of the user being queried. The format of this date varies based on the user's locale.
				profile.Birthday           = json.ContainsName("birthday"           ) ? JsonUtils.ToDateTime(json.GetValue<string>("birthday"     ), "MM/dd/yyyy"                  ) : DateTime.MinValue;
				// The birthday of the user being queried in MM/DD/YYYY format.
				profile.Birthday           = json.ContainsName("birthday_date"      ) ? JsonUtils.ToDateTime(json.GetValue<string>("birthday_date"), "MM/dd/yyyy"                  ) : profile.Birthday;
				profile.UpdatedTime        = json.ContainsName("updated_time"       ) ? JsonUtils.ToDateTime(json.GetValue<string>("updated_time" ), "yyyy-MM-ddTHH:mm:ss") : DateTime.MinValue;
				
				profile.Location            = mapper.Deserialize<Reference           >(json.GetValue("location"            ));
				profile.Hometown            = mapper.Deserialize<Reference           >(json.GetValue("hometown"            ));
				if ( json.ContainsName("hometown_location") )
					profile.Hometown = mapper.Deserialize<Reference>(json.GetValue("hometown_location"));
				profile.SignificantOther    = mapper.Deserialize<Reference           >(json.GetValue("significant_other"   ));
				profile.Work                = mapper.Deserialize<List<WorkEntry     >>(json.GetValue("work"                ));
				profile.Education           = mapper.Deserialize<List<EducationEntry>>(json.GetValue("education"           ));
				profile.InterestedIn        = mapper.Deserialize<List<String        >>(json.GetValue("interested_in"       ));
				profile.InspirationalPeople = mapper.Deserialize<List<Reference     >>(json.GetValue("inspirational_people"));
				profile.Languages           = mapper.Deserialize<List<Reference     >>(json.GetValue("languages"           ));
				profile.Sports              = mapper.Deserialize<List<Reference     >>(json.GetValue("sports"              ));
				profile.FavoriteTeams       = mapper.Deserialize<List<Reference     >>(json.GetValue("favorite_teams"      ));
				profile.FavoriteAtheletes   = mapper.Deserialize<List<Reference     >>(json.GetValue("favorite_athletes"   ));
			}
			return profile;
		}
	}
}
