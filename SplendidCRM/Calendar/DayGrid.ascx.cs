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
using System.Globalization;

namespace SplendidCRM.Calendar
{
	/// <summary>
	///		Summary description for DayGrid.
	/// </summary>
	public class DayGrid : CalendarControl
	{
		protected Label          lblError         ;
		protected PlaceHolder    plcDayRows       ;
		protected CalendarHeader ctlCalendarHeader;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "Day.Previous":
					{
						dtCurrentDate = dtCurrentDate.AddDays(-1);
						ViewState["CurrentDate"] = dtCurrentDate;
						// 06/15/2006 Paul.  There seems to be a conflict with binding the DayGrid inside InitializeComponent(). 
						// Binding early is required to enable the button events, but the ViewState is not available, so the query is invalid. 
						Response.Redirect("default.aspx?" + CalendarQueryString(dtCurrentDate));
						break;
					}
					case "Day.Next":
					{
						dtCurrentDate = dtCurrentDate.AddDays(1);
						ViewState["CurrentDate"] = dtCurrentDate;
						// 06/15/2006 Paul.  There seems to be a conflict with binding the DayGrid inside InitializeComponent(). 
						// Binding early is required to enable the button events, but the ViewState is not available, so the query is invalid. 
						Response.Redirect("default.aspx?" + CalendarQueryString(dtCurrentDate));
						break;
					}
					case "Day.Current":
					{
						ViewState["CurrentDate"] = dtCurrentDate;
						// 06/15/2006 Paul.  There seems to be a conflict with binding the DayGrid inside InitializeComponent(). 
						// Binding early is required to enable the button events, but the ViewState is not available, so the query is invalid. 
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
						Response.Redirect("Year.aspx?" + CalendarQueryString(dtCurrentDate));
						break;
					}
					case "Shared.Current":
					{
						Response.Redirect("Shared.aspx?" + CalendarQueryString(dtCurrentDate));
						break;
					}
					case "Save":
					{
						Response.Redirect("default.aspx?" + CalendarQueryString(dtCurrentDate));
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

		protected void BindGrid()
		{
			plcDayRows.Controls.Clear();
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select *                                                       " + ControlChars.CrLf
					     + "  from vwACTIVITIES_List                                       " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						DateTime dtDATE_START = new DateTime(Math.Max(1753, dtCurrentDate.Year), dtCurrentDate.Month, dtCurrentDate.Day, 0, 0, 0);
						DateTime dtDATE_END   = dtDATE_START.AddDays(1);
						// 11/27/2006 Paul.  Make sure to filter relationship data based on team access rights. 
						Security.Filter(cmd, "Calls", "list");
						// 01/16/2007 Paul.  Use AppendParameter so that duplicate ASSIGNED_USER_ID can be avoided. 
						// 01/19/2007 Paul.  Fix AppendParamenter.  @ should not be used in field name. 
						Sql.AppendParameter(cmd, Security.USER_ID, "ASSIGNED_USER_ID");
						cmd.CommandText += "   and (   DATE_START >= @DATE_START and DATE_START < @DATE_END" + ControlChars.CrLf;
						cmd.CommandText += "        or DATE_END   >= @DATE_START and DATE_END   < @DATE_END" + ControlChars.CrLf;
						cmd.CommandText += "        or DATE_START <  @DATE_START and DATE_END   > @DATE_END" + ControlChars.CrLf;
						cmd.CommandText += "       )                                                       " + ControlChars.CrLf;
						cmd.CommandText += " order by DATE_START asc, NAME asc                             " + ControlChars.CrLf;
						// 03/19/2007 Paul.  Need to query activities based on server time. 
						Sql.AddParameter(cmd, "@DATE_START", T10n.ToServerTime(dtDATE_START));
						Sql.AddParameter(cmd, "@DATE_END"  , T10n.ToServerTime(dtDATE_END  ));

						if ( bDebug )
							RegisterClientScriptBlock("vwACTIVITIES_List", Sql.ClientScriptBlock(cmd));

						try
						{
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									// 07/24/2005 Paul.  Since this is not a dynamic grid, we must convert the status manually. 
									foreach(DataRow row in dt.Rows)
									{
										switch ( Sql.ToString(row["ACTIVITY_TYPE"]) )
										{
											// 03/27/2008 Paul.  Correct the Call, Meeting and Task label to use the activity_dom list. 
											case "Calls"   :  row["STATUS"] = L10n.Term(".activity_dom.Call"   ) + " " + L10n.Term(".call_status_dom."   , row["STATUS"]);  break;
											case "Meetings":  row["STATUS"] = L10n.Term(".activity_dom.Meeting") + " " + L10n.Term(".meeting_status_dom.", row["STATUS"]);  break;
										}
									}

									// 04/30/2009 Paul.  The hour range should be config values so that the range can be extended. 
									int nHourMin = Sql.ToInteger(Application["CONFIG.calendar.hour_start"]);  // 8
									int nHourMax = Sql.ToInteger(Application["CONFIG.calendar.hour_end"  ]);  // 18
									if ( nHourMin < 0 )
										nHourMin = 0;
									else if ( nHourMin > 23 )
										nHourMin = 23;
									if ( nHourMax < 0 )
										nHourMax = 0;
									else if ( nHourMax > 23 )
										nHourMax = 23;
									if ( nHourMin >= nHourMax )
									{
										nHourMin = 8;
										nHourMax = 18;
									}

									if ( dt.Rows.Count > 0 )
									{
										DateTime dtMin = Sql.ToDateTime(dt.Rows[0]["DATE_START"]);
										DateTime dtMax = Sql.ToDateTime(dt.Rows[dt.Rows.Count-1]["DATE_END"]);
										nHourMin = Math.Min(dtMin.Hour, nHourMin);
										nHourMax = Math.Max(dtMax.Hour, nHourMax);
									}
									CultureInfo ciEnglish = CultureInfo.CreateSpecificCulture("en-US");
									for(int iHour = nHourMin ; iHour <= nHourMax ; iHour++ )
									{
										DataView vwMain = new DataView(dt);
										// 10/21/2008 Paul.  Protect against an invalid date. 
										DateTime dtHOUR_START = new DateTime(Math.Max(1753, dtCurrentDate.Year), dtCurrentDate.Month, dtCurrentDate.Day, iHour, 0, 0);
										DateTime dtHOUR_END   = dtHOUR_START.AddHours(1);
										DateTime dtHOUR_START_ServerTime = T10n.ToServerTime(dtHOUR_START);
										DateTime dtHOUR_END_ServerTime   = T10n.ToServerTime(dtHOUR_END  );
										// 09/27/2005 Paul.  System.Data.DataColumn.Expression documentation has description how to define dates and strings. 
										// 01/21/2006 Paul.  Brazilian culture is having a problem with date formats.  Try using the european format yyyy/MM/dd HH:mm:ss. 
										// 06/09/2006 Paul.  Fix so that a 1 hour meeting does not span two hours.  DATE_END should not allow DATE_END = HOUR_START. 
										// 06/13/2006 Paul.  Italian has a problem with the time separator.  Use the value from the culture from CalendarControl.SqlDateTimeFormat. 
										// 06/14/2006 Paul.  The Italian problem was that it was using the culture separator, but DataView only supports the en-US format. 
										string sHOUR_START_ServerTime = dtHOUR_START_ServerTime.ToString(CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat);
										string sHOUR_END_ServerTime   = dtHOUR_END_ServerTime  .ToString(CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat);
										vwMain.RowFilter = "   DATE_START >= #" + sHOUR_START_ServerTime + "# and DATE_START <  #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf
										                 + "or DATE_END   >  #" + sHOUR_START_ServerTime + "# and DATE_END   <= #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf
										                 + "or DATE_START <  #" + sHOUR_START_ServerTime + "# and DATE_END   >  #" + sHOUR_END_ServerTime + "#" + ControlChars.CrLf;
#if DEBUG
//										RegisterClientScriptBlock("vwACTIVITIES_List" + dtHOUR_START.ToOADate().ToString(), Sql.EscapeJavaScript(vwMain.RowFilter));
#endif
										DayRow ctlDayRow = LoadControl("DayRow.ascx") as DayRow;
										// 06/09/2006 Paul.  Add to controls list before bindging. 
										plcDayRows.Controls.Add(ctlDayRow);
										ctlDayRow.Command += new CommandEventHandler(Page_Command);
										
										ctlDayRow.DATE_START = dtHOUR_START;
										//ctlDayRow.DATE_END   = dtHOUR_END;
										ctlDayRow.DataSource = vwMain;
										// 06/09/2006 Paul.  Need to bind after specifying the data source. 
										ctlDayRow.DataBind();
										//ctlDayRow.DATE_START = new DateTime(dtCurrentDate.Year, dtCurrentDate.Month, dtCurrentDate.Day, iHour, 0, 0);
										//ctlDayRow.DATE_END   = ctlDayRow.DATE_START.AddHours(1);
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							lblError.Text = ex.Message;
						}
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
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Page_DataBind(object sender, System.EventArgs e)
		{
			// 03/19/2007 Paul.  We were having a problem with the calendar data appearing during print view.  We needed to rebind the data. 
			try
			{
				if ( IsPostBack )
				{
					CalendarInitDate();
					BindGrid();
				}
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
			this.DataBinding += new System.EventHandler(this.Page_DataBind);
			ctlCalendarHeader.Command += new CommandEventHandler(Page_Command);
			// 06/09/2006 Paul.  If this is a postback, then build the grid early so that we will not lose any button events. 
			if ( IsPostBack )
			{
				// 06/09/2006 Paul.  T10n has not been defined at this point, so create it. 
				GetT10n();
				BindGrid();
			}
		}
		#endregion
	}
}

