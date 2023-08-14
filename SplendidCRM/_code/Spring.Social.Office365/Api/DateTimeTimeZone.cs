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
using System.Globalization;
using Spring.Json;

namespace Spring.Social.Office365.Api
{
	public class DateTimeTimeZone
	{
		// // https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings?redirectedfrom=MSDN#Roundtrip
		public const string DateTimeFormat = "o"; // "yyyy-MM-ddTHH:mm:ss.fffffffK";

		public String                ODataType            { get; set; }
		public String                DateTime             { get; set; }
		public String                TimeZone             { get; set; }
		public AdditionalData        AdditionalData       { get; set; }

		public DateTimeTimeZone()
		{
			this.ODataType = "microsoft.graph.dateTimeTimeZone";
		}

		// C:\Web.net\BackupBin Net 4.5\Microsoft Graph 3.20\msgraph-sdk-dotnet-dev\src\Microsoft.Graph\Models\Extensions\DateTimeZoneExtensions.cs
		public DateTime ToDateTime()
		{
			DateTime dateTime = System.DateTime.ParseExact(this.DateTime, DateTimeTimeZone.DateTimeFormat, CultureInfo.InvariantCulture);

			// Now we need to determine which DateTimeKind to set based on the time zone specified in the input object.
			TimeZoneInfo timeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById(this.TimeZone);

			DateTimeKind kind;
			if (timeZoneInfo.Id == TimeZoneInfo.Utc.Id)
			{
				kind = DateTimeKind.Utc;
			}
			else if (timeZoneInfo.Id == TimeZoneInfo.Local.Id)
			{
				kind = DateTimeKind.Local;
			}
			else
			{
				kind = DateTimeKind.Unspecified;
			}
			return System.DateTime.SpecifyKind(dateTime, kind);
		}

		public DateTimeOffset ToDateTimeOffset()
		{
			// The resulting DateTimeOffset will have the correct offset for the time zone specified in the input object.

			DateTime dateTime = System.DateTime.ParseExact(this.DateTime, DateTimeTimeZone.DateTimeFormat, CultureInfo.InvariantCulture);
			TimeZoneInfo timeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById(this.TimeZone);
			return this.ToDateTimeOffset(dateTime, timeZoneInfo);
		}

		internal DateTimeOffset ToDateTimeOffset(DateTime dateTime, TimeZoneInfo timeZoneInfo)
		{
			TimeSpan offset;
			if (timeZoneInfo.IsAmbiguousTime(dateTime))
			{
				// Ambiguous times happen when during backward transitions, such as the end of daylight saving time.
				// Since we were just told this time is ambiguous, there will always be exactly two offsets in the following array:
				TimeSpan[] offsets = timeZoneInfo.GetAmbiguousTimeOffsets(dateTime);

				// A reasonable common practice is to pick the first occurrence, which is always the largest offset in the array.
				// Ex: 2019-11-03T01:30:00 in the Pacific time zone occurs twice.  First at 1:30 PDT (-07:00), then an hour later
				//     at 1:30 PST (-08:00).  We choose PDT (-07:00) because it comes first sequentially.
				offset = TimeSpan.FromMinutes(Math.Max(offsets[0].TotalMinutes, offsets[1].TotalMinutes));
			}
			else if (timeZoneInfo.IsInvalidTime(dateTime))
			{
				// Invalid times happen during the gap created by a forward transition, such as the start of daylight saving time.
				// While they are not values that actually occur in correct local time, they are sometimes encountered
				// in scenarios such as a scheduled daily task.  In such cases, a reasonable common practice is to advance
				// to a valid local time by the amount of the transition gap (usually 1 hour).
				// Ex: 2019-03-10T02:30:00 does not exist in Pacific time.
				//     The local time went from 01:59:59 PST (-08:00) directly to 03:00:00 PDT (-07:00).
				//     We will advance by 1 hour to 03:30:00 which is in PDT (-07:00).

				// The gap is usually 1 hour, but not always - so it must be calculated
				TimeSpan earlierOffset = timeZoneInfo.GetUtcOffset(dateTime.AddDays(-1));
				TimeSpan laterOffset = timeZoneInfo.GetUtcOffset(dateTime.AddDays(1));
				TimeSpan gap = laterOffset - earlierOffset;

				dateTime = dateTime.Add(gap);
				offset = laterOffset;
			}
			else
			{
				dateTime = System.DateTime.SpecifyKind(dateTime, DateTimeKind.Utc);
				offset = timeZoneInfo.GetUtcOffset(dateTime);
			}

			return new DateTimeOffset(dateTime, offset);
		}

		public static DateTimeTimeZone ToDateTimeTimeZone(DateTime dateTime)
		{
			return DateTimeTimeZone.FromDateTime(dateTime);
		}

		public static DateTimeTimeZone ToDateTimeTimeZone(DateTime dateTime, TimeZoneInfo timeZoneInfo)
		{
			return DateTimeTimeZone.FromDateTime(dateTime, timeZoneInfo);
		}

		public static DateTimeTimeZone ToDateTimeTimeZone(DateTimeOffset dateTimeOffset)
		{
			return DateTimeTimeZone.FromDateTimeOffset(dateTimeOffset);
		}

		public static DateTimeTimeZone ToDateTimeTimeZone(DateTimeOffset dateTimeOffset, string timeZone)
		{
			return DateTimeTimeZone.FromDateTimeOffset(dateTimeOffset, timeZone);
		}

		public static DateTimeTimeZone ToDateTimeTimeZone(DateTimeOffset dateTimeOffset, TimeZoneInfo timeZoneInfo)
		{
			return DateTimeTimeZone.FromDateTimeOffset(dateTimeOffset, timeZoneInfo);
		}

		// C:\Web.net\BackupBin Net 4.5\Microsoft Graph 3.20\msgraph-sdk-dotnet-dev\src\Microsoft.Graph\Models\Extensions\DateTimeZoneExtensions.cs
		public static DateTimeTimeZone FromDateTime(DateTime dateTime)
		{
			DateTimeTimeZone dateTimeTimeZone = new DateTimeTimeZone
			{
				DateTime = dateTime.ToString(DateTimeFormat, CultureInfo.InvariantCulture),
				TimeZone = string.Empty
			};
			return dateTimeTimeZone;
		}

		public static DateTimeTimeZone FromDateTime(DateTime dateTime, string timeZone)
		{
			DateTimeTimeZone dateTimeTimeZone = new DateTimeTimeZone
			{
				DateTime = dateTime.ToString(DateTimeFormat, CultureInfo.InvariantCulture),
				TimeZone = timeZone
			};
			return dateTimeTimeZone;
		}

		public static DateTimeTimeZone FromDateTime(DateTime dateTime, TimeZoneInfo timeZoneInfo)
		{
			DateTimeTimeZone dateTimeTimeZone = new DateTimeTimeZone
			{
				DateTime = dateTime.ToString(DateTimeFormat, CultureInfo.InvariantCulture),
				TimeZone = timeZoneInfo.Id
			};
			return dateTimeTimeZone;
		}

		public static DateTimeTimeZone FromDateTimeOffset(DateTimeOffset dateTimeOffset)
		{
			DateTimeTimeZone dateTimeTimeZone = new DateTimeTimeZone
			{
				DateTime = dateTimeOffset.ToString(DateTimeFormat, CultureInfo.InvariantCulture),
				TimeZone = string.Empty
			};
			return dateTimeTimeZone;
		}

		public static DateTimeTimeZone FromDateTimeOffset(DateTimeOffset dateTimeOffset, string timeZone)
		{
			DateTimeTimeZone dateTimeTimeZone = new DateTimeTimeZone
			{
				DateTime = dateTimeOffset.ToString(DateTimeFormat, CultureInfo.InvariantCulture),
				TimeZone = timeZone
			};
			return dateTimeTimeZone;
		}

		public static DateTimeTimeZone FromDateTimeOffset(DateTimeOffset dateTimeOffset, TimeZoneInfo timeZoneInfo)
		{
			DateTimeTimeZone dateTimeTimeZone = new DateTimeTimeZone
			{
				DateTime = dateTimeOffset.ToString(DateTimeFormat, CultureInfo.InvariantCulture),
				TimeZone = timeZoneInfo.Id
			};
			return dateTimeTimeZone;
		}
	}
}
