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
using System.Text;
using System.Collections.Generic;
using System.Collections.Specialized;
using Spring.Json;

namespace Spring.Social.Office365.Api
{
	public class Calendar : Entity
	{
		public IList<String>         AllowedOnlineMeetingProviders { get; set; }
		public bool?                 CanEdit                       { get; set; }
		public bool?                 CanShare                      { get; set; }
		public bool?                 CanViewPrivateItems           { get; set; }
		public String                ChangeKey                     { get; set; }
		public String                Color                         { get; set; }
		public String                DefaultOnlineMeetingProvider  { get; set; }
		public String                HexColor                      { get; set; }
		public bool?                 IsDefaultCalendar             { get; set; }
		public bool?                 IsRemovable                   { get; set; }
		public bool?                 IsTallyingResponses           { get; set; }
		public String                Name                          { get; set; }
		public EmailAddress          Owner                         { get; set; }
		public IList<Event>          Events                        { get; set; }
		//public ICalendarCalendarPermissionsCollectionPage CalendarPermissions { get; set; }
		//public ICalendarCalendarViewCollectionPage CalendarView { get; set; }
		//public ICalendarMultiValueExtendedPropertiesCollectionPage MultiValueExtendedProperties { get; set; }
		//public ICalendarSingleValueExtendedPropertiesCollectionPage SingleValueExtendedProperties { get; set; }

		public Calendar()
		{
			this.ODataType = "microsoft.graph.calendar";
		}
	}
}
