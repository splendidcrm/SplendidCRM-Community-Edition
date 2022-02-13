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

namespace Spring.Social.LinkedIn.Api.Impl.Json
{
    /// <summary>
    /// JSON deserializer for LinkedIn full user's profile.
    /// </summary>
    /// <author>Bruno Baia</author>
    class LinkedInFullProfileDeserializer : LinkedInProfileDeserializer
    {
		public override object Deserialize(JsonValue json, JsonMapper mapper)
		{
			LinkedInFullProfile profile = (LinkedInFullProfile)base.Deserialize(json, mapper);

			// 04/10/2012 Paul.  Each field must be checked for existance first. 
			profile.Associations             = json.ContainsName("associations"        ) ? json.GetValue<string>("associations"        ) : String.Empty;
			profile.ConnectionsCount         = json.ContainsName("numConnections"      ) ? json.GetValue<int>   ("numConnections"      ) : 0;
			profile.Distance                 = json.ContainsName("distance"            ) ? json.GetValue<int>   ("distance"            ) : 0;
			profile.Honors                   = json.ContainsName("honors"              ) ? json.GetValue<string>("honors"              ) : String.Empty;
			profile.Interests                = json.ContainsName("interests"           ) ? json.GetValue<string>("interests"           ) : String.Empty;
			profile.IsConnectionsCountCapped = json.ContainsName("numConnectionsCapped") ? json.GetValue<bool>  ("numConnectionsCapped") : false;
			profile.MainAddress              = json.ContainsName("mainAddress"         ) ? json.GetValue<string>("mainAddress"         ) : String.Empty;
			profile.ProposalComments         = json.ContainsName("proposalComments"    ) ? json.GetValue<string>("proposalComments"    ) : String.Empty;
			profile.RecommendersCount        = json.ContainsName("numRecommenders"     ) ? json.GetValue<int?>  ("numRecommenders"     ) : null;
			profile.Specialties              = json.ContainsName("specialties"         ) ? json.GetValue<string>("specialties"         ) : String.Empty;
			if ( json.ContainsName("location") )
			{
				JsonValue locationJson           = json.GetValue("location");
				profile.CountryCode              = locationJson.GetValue("country").GetValue<string>("code");
				profile.Location                 = locationJson.GetValue<string>("name");
			}

			profile.BirthDate                = DeserializeLinkedInDate   (json.GetValue("dateOfBirth"            ));
			profile.Educations               = DeserializeEducations     (json.GetValue("educations"             ));
			profile.ImAccounts               = DeserializeImAccounts     (json.GetValue("imAccounts"             ));
			profile.PhoneNumbers             = DeserializePhoneNumbers   (json.GetValue("phoneNumbers"           ));
			profile.Positions                = DeserializePositions      (json.GetValue("positions"              ));
			profile.Skills                   = DeserializeSkills         (json.GetValue("skills"                 ));
			profile.Recommendations          = DeserializeRecommendations(json.GetValue("recommendationsReceived"), mapper);
			profile.TwitterAccounts          = DeserializeTwitterAccounts(json.GetValue("twitterAccounts"        ));
			profile.UrlResources             = DeserializeUrlResources   (json.GetValue("memberUrlResources"     ));
			return profile;
		}

        protected override LinkedInProfile CreateLinkedInProfile()
        {
            return new LinkedInFullProfile();
        }

        private static LinkedInDate DeserializeLinkedInDate(JsonValue json)
        {
            if (json != null)
            {
                return new LinkedInDate()
                {
                    Year = json.ContainsName("year") ? json.GetValue<int?>("year") : null,
                    Month = json.ContainsName("month") ? json.GetValue<int?>("month") : null,
                    Day = json.ContainsName("day") ? json.GetValue<int?>("day") : null
                };
            }
            return null;
        }

        private static IList<string> DeserializeSkills(JsonValue json)
        {
            IList<string> skills = new List<string>();
            if (json != null)
            {
                JsonValue valuesJson = json.GetValue("values");
                if (valuesJson != null)
                {
                    foreach (JsonValue itemJson in valuesJson.GetValues())
                    {
                        skills.Add(itemJson.GetValue("skill").GetValue<string>("name"));
                    }
                }
            }
            return skills;
        }

        private static IList<ImAccount> DeserializeImAccounts(JsonValue json)
        {
            IList<ImAccount> imAccounts = new List<ImAccount>();
            if (json != null)
            {
                JsonValue valuesJson = json.GetValue("values");
                if (valuesJson != null)
                {
                    foreach (JsonValue itemJson in valuesJson.GetValues())
                    {
                        imAccounts.Add(new ImAccount()
                        {
                            Type = itemJson.GetValue<string>("imAccountType"),
                            Name = itemJson.GetValue<string>("imAccountName")
                        });
                    }
                }
            }
            return imAccounts;
        }

        private static IList<PhoneNumber> DeserializePhoneNumbers(JsonValue json)
        {
            IList<PhoneNumber> phoneNumbers = new List<PhoneNumber>();
            if (json != null)
            {
                JsonValue valuesJson = json.GetValue("values");
                if (valuesJson != null)
                {
                    foreach (JsonValue itemJson in valuesJson.GetValues())
                    {
                        phoneNumbers.Add(new PhoneNumber()
                        {
                            Type = itemJson.GetValue<string>("phoneType"),
                            Number = itemJson.GetValue<string>("phoneNumber")
                        });
                    }
                }
            }
            return phoneNumbers;
        }

        private static IList<LinkedInUrl> DeserializeUrlResources(JsonValue json)
        {
            IList<LinkedInUrl> urlResources = new List<LinkedInUrl>();
            if (json != null)
            {
                JsonValue valuesJson = json.GetValue("values");
                if (valuesJson != null)
                {
                    foreach (JsonValue itemJson in valuesJson.GetValues())
                    {
                        if (itemJson.ContainsName("url"))
                        {
                            urlResources.Add(new LinkedInUrl()
                            {
                                Name = itemJson.GetValue<string>("name"),
                                Url = itemJson.GetValue<string>("url")
                            });
                        }
                    }
                }
            }
            return urlResources;
        }

        private static IList<TwitterAccount> DeserializeTwitterAccounts(JsonValue json)
        {
            IList<TwitterAccount> twitterAccounts = new List<TwitterAccount>();
            if (json != null)
            {
                JsonValue valuesJson = json.GetValue("values");
                if (valuesJson != null)
                {
                    foreach (JsonValue itemJson in valuesJson.GetValues())
                    {
                        twitterAccounts.Add(new TwitterAccount()
                        {
                            ID = itemJson.GetValue<string>("providerAccountId"),
                            Name = itemJson.GetValue<string>("providerAccountName")
                        });
                    }
                }
            }
            return twitterAccounts;
        }

        private static IList<Education> DeserializeEducations(JsonValue json)
        {
            IList<Education> educations = new List<Education>();
            if (json != null)
            {
                JsonValue valuesJson = json.GetValue("values");
                if (valuesJson != null)
                {
                    foreach (JsonValue itemJson in valuesJson.GetValues())
                    {
                        educations.Add(new Education()
                        {
                            ID = itemJson.GetValue<int>("id"),
                            SchoolName = itemJson.GetValue<string>("schoolName"),
                            StudyField = itemJson.ContainsName("fieldOfStudy") ? itemJson.GetValue<string>("fieldOfStudy") : "",
                            StartDate = DeserializeLinkedInDate(itemJson.GetValue("startDate")),
                            EndDate = DeserializeLinkedInDate(itemJson.GetValue("endDate")),
                            Degree = itemJson.ContainsName("degree") ? itemJson.GetValue<string>("degree") : "",
                            Activities = itemJson.ContainsName("activities") ? itemJson.GetValue<string>("activities") : "",
                            Notes = itemJson.ContainsName("notes") ? itemJson.GetValue<string>("notes") : ""
                        });
                    }
                }
            }
            return educations;
        }

        private static IList<Recommendation> DeserializeRecommendations(JsonValue json, JsonMapper mapper)
        {
            IList<Recommendation> recommendations = new List<Recommendation>();
            if (json != null)
            {
                JsonValue valuesJson = json.GetValue("values");
                if (valuesJson != null)
                {
                    foreach (JsonValue itemJson in valuesJson.GetValues())
                    {
                        recommendations.Add(new Recommendation()
                        {
                            ID = itemJson.GetValue<int>("id"),
                            Text = itemJson.GetValue<string>("recommendationText"),
                            Type = DeserializeRecommendationType(itemJson.GetValue("recommendationType")),
                            Recommender = mapper.Deserialize<LinkedInProfile>(itemJson.GetValue("recommender"))
                        });
                    }
                }
            }
            return recommendations;
        }

        private static RecommendationType DeserializeRecommendationType(JsonValue json)
        {
            if (json != null)
            {
                string code = json.GetValue<string>("code");
                switch (code.ToLowerInvariant())
                {
                    case "business-partner": return RecommendationType.BusinessPartner;
                    case "colleague": return RecommendationType.Colleague;
                    case "education": return RecommendationType.Education;
                    case "service-provider": return RecommendationType.ServiceProvider;
                }
            }
            return RecommendationType.Unknown;
        }

        private static IList<Position> DeserializePositions(JsonValue json)
        {
            IList<Position> positions = new List<Position>();
            if (json != null)
            {
                JsonValue valuesJson = json.GetValue("values");
                if (valuesJson != null)
                {
                    foreach (JsonValue itemJson in valuesJson.GetValues())
                    {
                        positions.Add(new Position()
                        {
                            ID = itemJson.GetValue<string>("id"),
                            Company = itemJson.ContainsName("company") ? DeserializeCompany(itemJson.GetValue("company")) : null,
                            Title = itemJson.ContainsName("title") ? itemJson.GetValue<string>("title") : "",
                            Summary = itemJson.ContainsName("summary") ? itemJson.GetValue<string>("summary") : "",
                            IsCurrent = itemJson.GetValue<bool>("isCurrent"),
                            StartDate = DeserializeLinkedInDate(itemJson.GetValue("startDate")),
                            EndDate = DeserializeLinkedInDate(itemJson.GetValue("endDate"))
                        });
                    }
                }
            }
            return positions;
        }

        private static Company DeserializeCompany(JsonValue json)
        {
            return new Company()
            {
                ID = json.ContainsName("id") ? json.GetValue<int>("id") : 0,
                Name = json.GetValue<string>("name"),
                Industry = json.GetValue<string>("industry"),
                Size = json.ContainsName("size") ? json.GetValue<string>("size") : null,
                Type = json.ContainsName("type") ? json.GetValue<string>("type") : null,
                Ticker = json.ContainsName("ticker") ? json.GetValue<string>("ticker") : null
            };
        }
    }
}