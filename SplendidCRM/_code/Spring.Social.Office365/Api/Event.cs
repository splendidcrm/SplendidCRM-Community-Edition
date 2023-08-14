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
	[Serializable]
	public class Event : OutlookItem
	{
		#region Properties
		public bool?               AllowNewTimeProposals      { get; set; }
		public IList<Attendee>     Attendees                  { get; set; }
		public ItemBody            Body                       { get; set; }
		public String              BodyPreview                { get; set; }
		public DateTimeTimeZone    End                        { get; set; }
		public bool?               HasAttachments             { get; set; }
		public String              ICalUId                    { get; set; }
		public String              Importance                 { get; set; }
		public bool?               IsAllDay                   { get; set; }
		public bool?               IsCancelled                { get; set; }
		public bool?               IsDraft                    { get; set; }
		public bool?               IsOnlineMeeting            { get; set; }
		public bool?               IsOrganizer                { get; set; }
		public bool?               IsReminderOn               { get; set; }
		public Location            Location                   { get; set; }
		public IList<Location>     Locations                  { get; set; }
		public OnlineMeetingInfo   OnlineMeeting              { get; set; }
		public String              OnlineMeetingProvider      { get; set; }
		public String              OnlineMeetingUrl           { get; set; }
		public Recipient           Organizer                  { get; set; }
		public String              OriginalEndTimeZone        { get; set; }
		public DateTimeOffset?     OriginalStart              { get; set; }
		public String              OriginalStartTimeZone      { get; set; }
		public PatternedRecurrence Recurrence                 { get; set; }
		public Int32?              ReminderMinutesBeforeStart { get; set; }
		public bool?               ResponseRequested          { get; set; }
		public ResponseStatus      ResponseStatus             { get; set; }
		public String              Sensitivity                { get; set; }
		public String              SeriesMasterId             { get; set; }
		public String              ShowAs                     { get; set; }
		public DateTimeTimeZone    Start                      { get; set; }
		public String              Subject                    { get; set; }
		public String              TransactionId              { get; set; }
		public String              Type                       { get; set; }
		public String              WebLink                    { get; set; }
		public IList<Attachment>   Attachments                { get; set; }
		public Calendar            Calendar                   { get; set; }
		//public IEventExtensionsCollectionPage Extensions { get; set; }
		//public IEventInstancesCollectionPage Instances { get; set; }
		//public IEventMultiValueExtendedPropertiesCollectionPage MultiValueExtendedProperties { get; set; }
		//public IEventSingleValueExtendedPropertiesCollectionPage SingleValueExtendedProperties { get; set; }
		#endregion

		public Event()
		{
			this.ODataType = "microsoft.graph.event";
		}

		public static DataTable CreateTable()
		{
			DataTable dt = new DataTable();
			dt.Columns.Add("id"                      , System.Type.GetType("System.String"  ));
			return dt;
		}

		public void SetRow(DataRow row)
		{
			for ( int i = 0; i < row.Table.Columns.Count; i++ )
			{
				row[i] = DBNull.Value;
			}
			row["id"  ] = this.Id;
		}

		public static DataRow ConvertToRow(Message obj)
		{
			DataTable dt = Message.CreateTable();
			DataRow row = dt.NewRow();
			obj.SetRow(row);
			return row;
		}

		public static DataTable ConvertToTable(IList<Message> contacts)
		{
			DataTable dt = Message.CreateTable();
			if ( contacts != null )
			{
				foreach ( Message contact in contacts )
				{
					DataRow row = dt.NewRow();
					dt.Rows.Add(row);
					contact.SetRow(row);
				}
			}
			return dt;
		}
	}

	public class EventPagination
	{
		public IList<Event>   events         { get; set; }
		public int            count          { get; set; }
		public String         nextLink       { get; set; }
		public String         deltaLink      { get; set; }
	}
}
