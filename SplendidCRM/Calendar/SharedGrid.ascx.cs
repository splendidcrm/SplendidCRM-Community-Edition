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
	///		Summary description for SharedGrid.
	/// </summary>
	public class SharedGrid : CalendarControl
	{
		protected Label          lblError         ;
		protected DateTime       dtCurrentWeek    ;
		protected PlaceHolder    plcWeekRows      ;
		protected CalendarHeader ctlCalendarHeader;
		protected ListBox        lstUSERS         ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "Shared.Previous":
					{
						dtCurrentDate = dtCurrentDate.AddDays(-7);
						dtCurrentWeek = dtCurrentDate.AddDays(DayOfWeek.Sunday - dtCurrentDate.DayOfWeek);
						ViewState["CurrentDate"] = dtCurrentDate;
						break;
					}
					case "Shared.Next":
					{
						dtCurrentDate = dtCurrentDate.AddDays(7);
						dtCurrentWeek = dtCurrentDate.AddDays(DayOfWeek.Sunday - dtCurrentDate.DayOfWeek);
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
						ViewState["CurrentDate"] = dtCurrentDate;
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
			plcWeekRows.Controls.Clear();
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					DataTable dtUsers = new DataTable();
					DateTime dtDATE_START = new DateTime(Math.Max(1753, dtCurrentWeek.Year), dtCurrentWeek.Month, dtCurrentWeek.Day, 0, 0, 0);
					DateTime dtDATE_END   = dtDATE_START.AddDays(7);
					sSQL = "select distinct                                                " + ControlChars.CrLf
					     + "       ASSIGNED_USER_ID                                        " + ControlChars.CrLf
					     + "     , ASSIGNED_FULL_NAME                                      " + ControlChars.CrLf
					     + "  from vwACTIVITIES_List                                       " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						// 11/27/2006 Paul.  Make sure to filter relationship data based on team access rights. 
						Security.Filter(cmd, "Calls", "list");
						cmd.CommandText += "   and (   DATE_START >= @DATE_START1 and DATE_START < @DATE_END1" + ControlChars.CrLf;
						cmd.CommandText += "        or DATE_END   >= @DATE_START2 and DATE_END   < @DATE_END2" + ControlChars.CrLf;
						cmd.CommandText += "        or DATE_START <  @DATE_START3 and DATE_END   > @DATE_END3" + ControlChars.CrLf;
						cmd.CommandText += "       )                                                       " + ControlChars.CrLf;
						// 03/19/2007 Paul.  Need to query activities based on server time. 
						// 08/19/2010 Paul.  Oracle does not allow the same parameter to be used more than once. 
						Sql.AddParameter(cmd, "@DATE_START1", T10n.ToServerTime(dtDATE_START));
						Sql.AddParameter(cmd, "@DATE_END1"  , T10n.ToServerTime(dtDATE_END  ));
						Sql.AddParameter(cmd, "@DATE_START2", T10n.ToServerTime(dtDATE_START));
						Sql.AddParameter(cmd, "@DATE_END2"  , T10n.ToServerTime(dtDATE_END  ));
						Sql.AddParameter(cmd, "@DATE_START3", T10n.ToServerTime(dtDATE_START));
						Sql.AddParameter(cmd, "@DATE_END3"  , T10n.ToServerTime(dtDATE_END  ));
						Sql.AppendGuids (cmd, lstUSERS     , "ASSIGNED_USER_ID");
						cmd.CommandText += " order by ASSIGNED_FULL_NAME" + ControlChars.CrLf;

						if ( bDebug )
							RegisterClientScriptBlock("vwACTIVITIES_List.Users", Sql.ClientScriptBlock(cmd));

						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtUsers);
						}
					}
					
					
					sSQL = "select *                                                       " + ControlChars.CrLf
					     + "  from vwACTIVITIES_List                                       " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						// 11/27/2006 Paul.  Make sure to filter relationship data based on team access rights. 
						Security.Filter(cmd, "Calls", "list");
						cmd.CommandText += "   and (   DATE_START >= @DATE_START1 and DATE_START < @DATE_END1" + ControlChars.CrLf;
						cmd.CommandText += "        or DATE_END   >= @DATE_START2 and DATE_END   < @DATE_END2" + ControlChars.CrLf;
						cmd.CommandText += "        or DATE_START <  @DATE_START3 and DATE_END   > @DATE_END3" + ControlChars.CrLf;
						cmd.CommandText += "       )                                                       " + ControlChars.CrLf;
						// 03/19/2007 Paul.  Need to query activities based on server time. 
						// 08/19/2010 Paul.  Oracle does not allow the same parameter to be used more than once. 
						Sql.AddParameter(cmd, "@DATE_START1", T10n.ToServerTime(dtDATE_START));
						Sql.AddParameter(cmd, "@DATE_END1"  , T10n.ToServerTime(dtDATE_END  ));
						Sql.AddParameter(cmd, "@DATE_START2", T10n.ToServerTime(dtDATE_START));
						Sql.AddParameter(cmd, "@DATE_END2"  , T10n.ToServerTime(dtDATE_END  ));
						Sql.AddParameter(cmd, "@DATE_START3", T10n.ToServerTime(dtDATE_START));
						Sql.AddParameter(cmd, "@DATE_END3"  , T10n.ToServerTime(dtDATE_END  ));
						Sql.AppendGuids (cmd, lstUSERS     , "ASSIGNED_USER_ID");
						cmd.CommandText += " order by ASSIGNED_FULL_NAME asc, DATE_START asc, NAME asc" + ControlChars.CrLf;

						if ( bDebug )
							RegisterClientScriptBlock("vwACTIVITIES_List.Data", Sql.ClientScriptBlock(cmd));

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
									foreach(DataRow rowUser in dtUsers.Rows)
									{
										Guid   gASSIGNED_USER_ID   = Sql.ToGuid  (rowUser["ASSIGNED_USER_ID"  ]);
										string sASSIGNED_FULL_NAME = Sql.ToString(rowUser["ASSIGNED_FULL_NAME"]);
										HtmlGenericControl h5User = new HtmlGenericControl("h5");
										h5User.Attributes.Add("class", "calSharedUser");
										h5User.Controls.Add(new LiteralControl(sASSIGNED_FULL_NAME));
										plcWeekRows.Controls.Add(h5User);

										HtmlTable tblUserWeek = new HtmlTable();
										plcWeekRows.Controls.Add(tblUserWeek);
										tblUserWeek.Border      = 0;
										tblUserWeek.CellPadding = 0;
										tblUserWeek.CellSpacing = 1;
										tblUserWeek.Width       = "100%";
										HtmlTableRow tr = new HtmlTableRow();
										tblUserWeek.Rows.Add(tr);
										
										CultureInfo ciEnglish = CultureInfo.CreateSpecificCulture("en-US");
										for(int iDay = 0 ; iDay < 7 ; iDay++ )
										{
											DataView vwMain = new DataView(dt);
											DateTime dtDAY_START = dtCurrentWeek;
											dtDAY_START = dtDAY_START.AddDays(iDay);
											DateTime dtDAY_END   = dtDAY_START.AddDays(1);
											// 03/19/2007 Paul.  Need to query activities based on server time. 
											DateTime dtDAY_START_ServerTime = T10n.ToServerTime(dtDAY_START);
											DateTime dtDAY_END_ServerTime   = T10n.ToServerTime(dtDAY_END  );
											
											HtmlTableCell cell = new HtmlTableCell();
											tr.Cells.Add(cell);
											cell.Width  = "14%";
											cell.VAlign = "top";
											cell.Attributes.Add("class", "dailyCalBodyItems");
											cell.Controls.Add(new LiteralControl(dtDAY_START.ToString("ddd d")));
											
											// 09/27/2005 Paul.  System.Data.DataColumn.Expression documentation has description how to define dates and strings. 
											// 01/21/2006 Paul.  Brazilian culture is having a problem with date formats.  Try using the european format. 
											// 06/13/2006 Paul.  Italian has a problem with the time separator.  Use the value from the culture from CalendarControl.SqlDateTimeFormat. 
											// 06/14/2006 Paul.  The Italian problem was that it was using the culture separator, but DataView only supports the en-US format. 
											string sDAY_START_ServerTime = dtDAY_START_ServerTime.ToString(CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat);
											string sDAY_END_ServerTime   = dtDAY_END_ServerTime  .ToString(CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat);
											vwMain.RowFilter = "ASSIGNED_USER_ID = '" + gASSIGNED_USER_ID.ToString() + "'" + ControlChars.CrLf
											                 + "and (   DATE_START >= #" + sDAY_START_ServerTime + "# and DATE_START <  #" + sDAY_END_ServerTime + "#" + ControlChars.CrLf
											                 + "     or DATE_END   >= #" + sDAY_START_ServerTime + "# and DATE_END   <= #" + sDAY_END_ServerTime + "#" + ControlChars.CrLf
											                 + "     or DATE_START <  #" + sDAY_START_ServerTime + "# and DATE_END   >  #" + sDAY_END_ServerTime + "#" + ControlChars.CrLf
											                 + "    )" + ControlChars.CrLf;
#if DEBUG
//											RegisterClientScriptBlock("vwACTIVITIES_List" + dtDAY_START.ToOADate().ToString(), Sql.EscapeJavaScript(vwMain.RowFilter));
#endif
											if ( vwMain.Count > 0 )
											{
												SharedCell ctlSharedCell = LoadControl("SharedCell.ascx") as SharedCell;
												ctlSharedCell.DataSource = vwMain;
												cell.Controls.Add(ctlSharedCell);
											}
										}
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
					// 05/29/2017 Paul.  We should be using AssignedUser() and not ActiveUsers(). 
					lstUSERS.DataSource = SplendidCache.AssignedUser();
					lstUSERS.DataBind();
					foreach(ListItem item in lstUSERS.Items)
					{
						item.Selected = true;
					}
					dtCurrentWeek = dtCurrentDate.AddDays(DayOfWeek.Sunday - dtCurrentDate.DayOfWeek);
					BindGrid();
				}
				else
				{
					dtCurrentWeek = dtCurrentDate.AddDays(DayOfWeek.Sunday - dtCurrentDate.DayOfWeek);
				}
				//// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
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

