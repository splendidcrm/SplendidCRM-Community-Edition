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
	///		Summary description for YearGrid.
	/// </summary>
	public class YearGrid : CalendarControl
	{
		protected Label          lblError         ;
		protected HtmlTable      tblDailyCalTable ;
		protected CalendarHeader ctlCalendarHeader;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "Year.Previous":
					{
						dtCurrentDate = dtCurrentDate.AddYears(-1);
						ViewState["CurrentDate"] = dtCurrentDate;
						break;
					}
					case "Year.Next":
					{
						dtCurrentDate = dtCurrentDate.AddYears(1);
						ViewState["CurrentDate"] = dtCurrentDate;
						break;
					}
					case "Day.Current":
					{
						Response.Redirect("default.aspx?" + CalendarQueryString(dtCurrentDate));
						break;
					}
					case "Week.Current":
					{
						Response.Redirect("Week.aspx?" + CalendarQueryString(dtCurrentDate));
						break;
					}
					case "Month.Current":
					{
						Response.Redirect("Month.aspx?" + CalendarQueryString(dtCurrentDate));
						break;
					}
					case "Year.Current":
					{
						ViewState["CurrentDate"] = dtCurrentDate;
						break;
					}
					case "Shared.Current":
					{
						Response.Redirect("Shared.aspx?" + CalendarQueryString(dtCurrentDate));
						break;
					}
				}
				BindGrid();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		protected void ctlCalendar_SelectionChanged(Object sender, EventArgs e) 
		{
			System.Web.UI.WebControls.Calendar ctlCalendar = sender as System.Web.UI.WebControls.Calendar;
			Response.Redirect("~/Calendar/default.aspx?" + CalendarQueryString(ctlCalendar.SelectedDate));
			//BindGrid();
		}

		/*
				<asp:Calendar ID="ctlCalendar" Width="100%" CssClass="monthBox" ShowGridLines="true" 
					CalendarSelectionMode="DayWeek" OnSelectionChanged="ctlCalendar_SelectionChanged" OnDayRender="ctlCalendar_DayRender" 
					Runat="server">
					<TitleStyle         CssClass="monthHeader monthHeaderH3"   />
					<NextPrevStyle      CssClass="monthHeader monthFooterPrev" />
					<DayHeaderStyle     CssClass="monthCalBodyTHDay"           />
					<DayStyle           CssClass="monthCalBodyWeekDay monthCalBodyWeekDayDateLink"      VerticalAlign="Top" />
					<TodayDayStyle      CssClass="monthCalBodyTodayWeekDay monthCalBodyWeekDayDateLink" VerticalAlign="Top" />
					<WeekendDayStyle    CssClass="monthCalBodyWeekEnd monthCalBodyWeekDayDateLink"      VerticalAlign="Top" />
					<OtherMonthDayStyle CssClass="monthCalBodyWeekDay" ForeColor="#fafafa"              VerticalAlign="Top" />
				</asp:Calendar>
		*/
		protected void BindGrid()
		{
			try
			{
				tblDailyCalTable.Rows.Clear();
				for(int nQuarter = 0; nQuarter < 4; nQuarter++)
				{
					HtmlTableRow tr = new HtmlTableRow();
					tblDailyCalTable.Rows.Add(tr);
					for(int nQMonth = 1; nQMonth <= 3; nQMonth++)
					{
						HtmlTableCell td = new HtmlTableCell();
						tr.Cells.Add(td);
						td.VAlign = "top";
						td.Align  = "center";
						td.Attributes.Add("class", "yearCalBodyMonth");

						DateTime dtCurrentMonth = new DateTime(dtCurrentDate.Year, 3 * nQuarter + nQMonth, 1);
						try
						{
							// 09/30/2005 Paul.  Attempt to keep the day, but prevent a date overflow. 
							if ( dtCurrentDate.Day <= dtCurrentMonth.AddMonths(1).AddDays(-1).Day )
								dtCurrentMonth = dtCurrentMonth.AddDays(dtCurrentDate.Day-1);
							else
								dtCurrentMonth = dtCurrentMonth.AddMonths(1).AddDays(-1);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						HyperLink lnkMonth = new HyperLink();
						td.Controls.Add(lnkMonth);
						lnkMonth.CssClass    = "yearCalBodyMonthLink";
						lnkMonth.Text        = dtCurrentMonth.ToString("MMMM");
						lnkMonth.NavigateUrl = "Month.aspx?" + CalendarQueryString(dtCurrentMonth);

						System.Web.UI.WebControls.Calendar cal = new System.Web.UI.WebControls.Calendar();
						td.Controls.Add(cal);
						cal.VisibleDate = new DateTime(dtCurrentDate.Year, 3 * nQuarter + nQMonth, 1);
						cal.Width                        = new Unit(100, UnitType.Percentage);
						cal.CssClass                     = "monthBox";
						cal.ShowGridLines                = true;
						cal.ShowTitle                    = false;
						cal.ShowNextPrevMonth            = false;
						cal.SelectionMode                = CalendarSelectionMode.Day;
						cal.TitleStyle.CssClass          = "monthHeader monthHeaderH3";
						cal.DayHeaderStyle.CssClass      = "monthCalBodyTHDay";
						cal.DayStyle.CssClass            = "monthCalBodyWeekDay monthCalBodyWeekDayDateLink";
						cal.TodayDayStyle.CssClass       = "monthCalBodyTodayWeekDay monthCalBodyWeekDayDateLink";
						cal.WeekendDayStyle.CssClass     = "monthCalBodyWeekEnd monthCalBodyWeekDayDateLink";
						cal.OtherMonthDayStyle.CssClass  = "monthCalBodyWeekDay";
						cal.OtherMonthDayStyle.ForeColor = System.Drawing.Color.FromArgb(0xfa, 0xfa, 0xfa);//"#fafafa";
						cal.SelectionChanged += new EventHandler(ctlCalendar_SelectionChanged);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				CalendarInitDate();
				if ( !IsPostBack )
				{
					BindGrid();
				}
				else
				{
					// 09/30/2005 Paul. Need to rebind in order for the calendar event to fire. 
					BindGrid();
				}
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
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
			ctlCalendarHeader.Command += new CommandEventHandler(Page_Command);
		}
		#endregion
	}
}

