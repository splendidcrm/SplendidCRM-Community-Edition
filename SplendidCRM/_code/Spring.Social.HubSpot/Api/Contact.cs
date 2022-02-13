/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
using System;
using System.Data;
using System.Collections.Generic;
using System.Collections.Specialized;

namespace Spring.Social.HubSpot.Api
{
	[Serializable]
	public class Contact
	{
		// http://knowledge.hubspot.com/contacts-user-guide/how-to-use-contact-properties
		public int?      id                                            { get; set; }
		public String    firstname                                     { get; set; }
		public String    lastname                                      { get; set; }
		public String    salutation                                    { get; set; }
		public String    email                                         { get; set; }
		public String    phone                                         { get; set; }
		public String    mobilephone                                   { get; set; }
		public String    fax                                           { get; set; }
		public String    address                                       { get; set; }
		public String    city                                          { get; set; }
		public String    state                                         { get; set; }
		public String    zip                                           { get; set; }
		public String    country                                       { get; set; }
		public String    jobtitle                                      { get; set; }
		public DateTime? closedate                                     { get; set; }
		public String    lifecyclestage                                { get; set; }
		public String    website                                       { get; set; }
		public String    company                                       { get; set; }
		public String    message                                       { get; set; }
		public String    photo                                         { get; set; }
		public String    numemployees                                  { get; set; }
		public String    annualrevenue                                 { get; set; }
		public String    industry                                      { get; set; }
		public String    hs_persona                                    { get; set; }
		public String    hs_facebookid                                 { get; set; }
		public String    hs_googleplusid                               { get; set; }
		public String    hs_linkedinid                                 { get; set; }
		public String    hs_twitterid                                  { get; set; }
		public String    twitterhandle                                 { get; set; }
		public String    twitterprofilephoto                           { get; set; }
		public String    linkedinbio                                   { get; set; }
		public String    twitterbio                                    { get; set; }
		public String    blog_default_hubspot_blog_subscription        { get; set; }
		public int?      followercount                                 { get; set; }
		public int?      linkedinconnections                           { get; set; }
		public int?      kloutscoregeneral                             { get; set; }
		public int?      associatedcompanyid                           { get; set; }  // this is the companyId. 

		public static DataTable ConvertToTable(IList<Contact> contacts)
		{
			throw(new Exception("Not implemented"));
		}
	}
}
