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
	/// Represents a Facebook user's profile information.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class FacebookProfile
	{
		public FacebookProfile()
		{
		}

		// http://developers.facebook.com/docs/reference/api/user/
		public FacebookProfile(string id, string username, string name, string firstName, string lastName, string gender, string locale)
		{
			this.ID        = id;
			this.Username  = username;
			this.Name      = name;
			this.FirstName = firstName;
			this.LastName  = lastName;
			this.Gender    = gender;
			this.Locale    = locale;
		}

		/// <summary>
		/// The user's Facebook ID
		/// </summary>
		public string ID { get; set; }
	
		/// <summary>
		/// The user's Facebook username
		/// </summary>
		public string Username { get; set; }

		/// <summary>
		/// The user's full name
		/// </summary>
		public string Name { get; set; }

		/// <summary>
		/// The user's first name
		/// </summary>
		public string FirstName { get; set; }

		/// <summary>
		/// The user's middle name
		/// </summary>
		public string MiddleName { get; set; }

		/// <summary>
		/// The user's last name
		/// </summary>
		public string LastName { get; set; }

		/// <summary>
		/// The user's gender
		/// </summary>
		public string Gender { get; set; }

		/// <summary>
		/// The user's locale
		/// </summary>
		public string Locale { get; set; }

		/// <summary>
		/// The user's email address.
		/// Available only with "email" permission.
		/// </summary>
		public string Email { get; set; }
	
		/// <summary>
		/// A link to the user's profile on Facebook.
		/// Available only if requested by an authenticated user.
		/// </summary>
		public string Link { get; set; }

		/// <summary>
		/// A link to the user's personal website. Available only with "user_website"
		/// or "friends_website" permission.
		/// </summary>
		public string Website { get; set; }

		/// <summary>
		/// An anonymous, but unique identifier for the user. Available only if
		/// requested by an authenticated user.
		/// </summary>
		public string ThirdPartyId { get; set; }
	
		/// <summary>
		/// The user's timezone offset from UTC.
		/// Available only for the authenticated user.
		/// </summary>
		public int Timezone { get; set; }
	
		/// <summary>
		/// The last time the user's profile was updated.
		/// </summary>
		public DateTime? UpdatedTime { get; set; }
	
		/// <summary>
		/// The user's account verification status.
		/// Available only if requested by an authenticated user.
		/// </summary>
		public Boolean Verified { get; set; }
	
		/// <summary>
		/// The user's brief about blurb.
		/// Available only with "user_about_me" permission for the authenticated user or "friends_about_me" for the authenticated user's friends.
		/// </summary>
		public string About { get; set; }

		/// <summary>
		/// The user's bio.
		/// Available only with "user_about_me" permission for the authenticated user.
		/// </summary>
		public string Bio { get; set; }
	
		/// <summary>
		/// The user's birthday.
		/// Available only with "user_birthday" permission for the authentication user or "friends_birthday" permission for the user's friends.
		/// </summary>
		public DateTime? Birthday { get; set; }
	
		/// <summary>
		/// The user's location.
		/// Available only with "user_location" or "friends_location" permission.
		/// </summary>
		public Reference Location { get; set; }
	
		/// <summary>
		/// The user's hometown.
		/// Available only with "user_hometown" or "friends_hometown" permission.
		/// </summary>
		public Reference Hometown { get; set; }
	
		/// <summary>
		/// A list of the genders the user is interested in.
		/// Available only with "user_relationship_details" or "friends_relationship_details" permission.
		/// </summary>
		public List<string> InterestedIn { get; set; }
	
		/// <summary>
		/// A list of references to people the user is inspired by.
		/// </summary>
		public List<Reference> InspirationalPeople { get; set; }
	
		/// <summary>
		/// A list of references to languages the user claims to know.
		/// </summary>
		public List<Reference> Languages { get; set; }
	
		/// <summary>
		/// A list of references to sports the user plays
		/// </summary>
		public List<Reference> Sports { get; set; }
	
		/// <summary>
		/// A list of references to the user's favorite sports teams.
		/// </summary>
		public List<Reference> FavoriteTeams { get; set; }
	
		/// <summary>
		/// A list of references to the user's favorite athletes.
		/// </summary>
		public List<Reference> FavoriteAtheletes { get; set; }

		/// <summary>
		/// The user's religion. 
		/// Available only with "user_religion_politics" or "friends_religion_politics" permission.
		/// </summary>
		public string Religion { get; set; }

		/// <summary>
		/// The user's political affiliation. 
		/// Available only with "user_religion_politics" or "friends_religion_politics" permission.
		/// </summary>
		public string Political { get; set; }

		/// <summary>
		/// The user's quotations. 
		/// Available only with "user_about_me" permission.
		/// </summary>
		public string Quotes { get; set; }

		/// <summary>
		/// The user's relationship status. 
		/// Available only with "user_relationships" or "friends_relationships" permission.
		/// </summary>
		public string RelationshipStatus { get; set; }

		/// <summary>
		/// The user's significant other. 
		/// Available only for certain relationship statuses and with "user_relationship_details" or "friends_relationship_details" permission.
		/// </summary>
		public Reference SignificantOther { get; set; }

		/// <summary>
		/// The user's work history.
		/// Available only with "user_work_history" or "friends_work_history" permission.
		/// </summary>
		public List<WorkEntry> Work { get; set; }
	
		/// <summary>
		/// The user's education history.
		/// Available only with "user_education_history" or "friends_education_history" permission.
		/// </summary>
		public List<EducationEntry> Education { get; set; }
	}
}
