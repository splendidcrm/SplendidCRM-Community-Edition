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
using System.Diagnostics;
using System.Threading;
using System.Globalization;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for CalendarControl.
	/// </summary>
	public class CalendarControl : SplendidControl
	{
		public static string SqlDateTimeFormat = "yyyy/MM/dd HH:mm:ss";

// 10/30/2021 Paul.  Convert CalendarControl to simple class as the control has been removed.
#if !ReactOnlyUI
		protected DateTime dtCurrentDate  = DateTime.MinValue;

		public static string CalendarQueryString(DateTime dt)
		{
			return "day=" + dt.Day + "&month=" + dt.Month + "&year=" + dt.Year;
		}

		// 09/30/2005 Paul.  Can't initialize in OnInit because ViewState is not ready. 
		// Can't initialize in a Page_Load because it will not get called in the correct sequence. 
		protected void CalendarInitDate()
		{
			if ( !IsPostBack )
			{
				int nYear  = Sql.ToInteger(Request["year" ]);
				int nMonth = Sql.ToInteger(Request["month"]);
				int nDay   = Sql.ToInteger(Request["day"  ]);
				try
				{
					if ( nYear < 1753 || nYear > 9999 || nMonth < 1 || nMonth > 12 || nDay < 1 || nDay > 31 )
						dtCurrentDate = DateTime.Today;
					else
						dtCurrentDate = new DateTime(nYear, nMonth, nDay);
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					dtCurrentDate = DateTime.Today;
				}
				// 09/30/2005 Paul.  ViewState is not available in OnInit.  Must wait for the Page_Load event. 
				ViewState["CurrentDate"] = dtCurrentDate;
			}
			else
			{
				dtCurrentDate = Sql.ToDateTime(ViewState["CurrentDate"]);
			}
		}
#endif
	}
}

