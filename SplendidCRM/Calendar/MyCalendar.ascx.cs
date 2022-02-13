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
using System.Data.Common;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Calendar
{
	/// <summary>
	///		Summary description for MyCalendar.
	/// </summary>
	public class MyCalendar : DashletControl
	{
		protected System.Web.UI.WebControls.Calendar ctlCalendar;

		protected void ctlCalendar_SelectionChanged(Object sender, EventArgs e) 
		{
			// 08/31/2006 Paul.  The date needs to be separated into day, month, year fields to avoid localization issues. 
			Response.Redirect("~/Calendar/default.aspx?" + CalendarControl.CalendarQueryString(ctlCalendar.SelectedDate));
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 09/09/2007 Paul.  We are having trouble dynamically adding user controls to the WebPartZone. 
			// Instead, control visibility manually here.  This approach as the added benefit of hiding the 
			// control even if the WebPartManager has moved it to an alternate zone. 
			// 07/10/2009 Paul.  The end-user will be able to hide or show the Dashlet controls. 
			/*
			if ( this.Visible && !Sql.IsEmptyString(sDetailView) )
			{
				// 01/17/2008 Paul.  We need to use the sDetailView property and not the hard-coded view name. 
				DataView vwFields = new DataView(SplendidCache.DetailViewRelationships(sDetailView));
				vwFields.RowFilter = "CONTROL_NAME = '~/Calendar/MyCalendar'";
				this.Visible = vwFields.Count > 0;
			}
			*/
			if ( !this.Visible )
				return;

			ctlCalendar.NextPrevFormat = NextPrevFormat.CustomText ;
			ctlCalendar.PrevMonthText  = "<div class=\"monthFooterPrev\"><img src=\"" + Session["themeURL"] + "images/calendar_previous.gif\" width=\"6\" height=\"9\" alt=\"" + L10n.Term("Calendar.LBL_PREVIOUS_MONTH") + "\" align=\"absmiddle\" border=\"0\">&nbsp;&nbsp;" + L10n.Term("Calendar.LBL_PREVIOUS_MONTH").Replace(" ", "&nbsp;") + "</div>";
			ctlCalendar.NextMonthText  = "<div class=\"monthFooterNext\">" + L10n.Term("Calendar.LBL_NEXT_MONTH").Replace(" ", "&nbsp;") + "&nbsp;&nbsp;<img src=\"" + Session["themeURL"] + "images/calendar_next.gif\" width=\"6\" height=\"9\" alt=\"" + L10n.Term("Calendar.LBL_NEXT_MONTH") + "\" align=\"absmiddle\" border=\"0\"></div>";
			if ( Information.IsDate(Request["Date"]) )
			{
				ctlCalendar.VisibleDate  = Sql.ToDateTime(Request["Date"]);
				ctlCalendar.SelectedDate = Sql.ToDateTime(Request["Date"]);
			}
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}

